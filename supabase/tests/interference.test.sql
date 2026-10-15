-- =====================================================================
-- Тести M14 + interference_v1: каталог типових помилок українців (§19) і зв'язок з особистими помилками.
-- Запускати ПІСЛЯ міграції M14 і 20261013_interference_v1.sql.
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
-- Запуск: Supabase → SQL Editor → вставити файл → Run. Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.raises(q text) returns boolean language plpgsql as $$
begin
  execute q;
  return false;
exception when others then
  return true;
end $$;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

create or replace function pg_temp.n(q text) returns bigint language plpgsql as $$
declare r bigint;
begin
  execute 'select count(*) from (' || q || ') s' into r;
  return r;
end $$;

-- ---------------------------------------------------------------- каталог
select pg_temp.ok((select relrowsecurity from pg_class where oid = 'public.linguistic_errors'::regclass), 'RLS увімкнено');
select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors where status = 'PUBLISHED'$q$) >= 74, 'опубліковано ≥ 74 типові помилки');
select pg_temp.ok(pg_temp.n($q$select distinct category from public.linguistic_errors where status = 'PUBLISHED'$q$) = 12,
  'усі 12 категорій ТЗ мають записи');
select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors where status = 'PUBLISHED'
  and (code !~ '^UKR-HR-[0-9]{4}$' or jsonb_array_length(examples) < 2 or explanation_ua !~ '[Ѐ-ӿ]')$q$) = 0,
  'код UKR-HR-NNNN, ≥ 2 приклади, пояснення українською');
select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors where status = 'PUBLISHED'
  and category not in ('pronunciation', 'stress') and (incorrect_text ~ '[Ѐ-ӿ]' or correct_text ~ '[Ѐ-ӿ]')$q$) = 0,
  '«неправильно / правильно» хорватською (кирилиця лише у вимові й наголосі)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors e join public.grammar_topics g on g.id = e.grammar_topic_id
  where e.status = 'PUBLISHED' and g.cefr not in ('A0', 'A1')$q$) = 0, 'помилки прив''язано до тем граматики A0/A1');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_topics g where g.cefr = 'A1'
  and exists (select 1 from public.linguistic_errors e where e.grammar_topic_id = g.id and e.status = 'PUBLISHED')$q$) >= 10,
  'щонайменше 10 тем граматики A1 мають картку типової помилки');
select pg_temp.ok(pg_temp.raises($q$insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua)
  values ('UKR-HR-9999', 'idioms', 'A1', 'Тест', 'a', 'b', 'Невідома категорія')$q$), 'невідома категорія — заборонено');
select pg_temp.ok(pg_temp.raises($q$insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua)
  values ('UKR-HR-9998', 'gender', 'A1', 'Тест', 'isto', 'isto', 'Однакові тексти')$q$), '«неправильно» = «правильно» — заборонено');
select pg_temp.ok(pg_temp.raises($q$insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua)
  values ('BAD-1', 'gender', 'A1', 'Тест', 'a', 'b', 'Неправильний код')$q$), 'код не за форматом — заборонено');

-- чернетка для перевірки видимості
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, status)
values ('UKR-HR-9990', 'gender', 'A1', 'Чернетка', 'x1', 'x2', 'Чернетка для тесту видимості', 'DRAFT');

insert into auth.users (id, email) values
  ('a1400000-0000-4000-8000-0000000000a1', 'm14-user-a@example.invalid'),
  ('b1400000-0000-4000-8000-0000000000b1', 'm14-user-b@example.invalid');

-- ---------------------------------------------------------------- гість
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors$q$) >= 74, 'гість бачить опубліковані помилки');
select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors where code = 'UKR-HR-9990'$q$) = 0, 'гість не бачить чернетки');
select pg_temp.ok(pg_temp.raises($q$insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, status)
  values ('UKR-HR-9991', 'gender', 'A1', 'Гість', 'a', 'b', 'Гість не може писати', 'PUBLISHED')$q$), 'гість не може додати помилку');

-- ---------------------------------------------------------------- користувач A
reset role;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a1400000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
select pg_temp.ok(pg_temp.raises($q$update public.linguistic_errors set title_ua = 'Зламано' where code = 'UKR-HR-0001'$q$)
  or (select title_ua from public.linguistic_errors where code = 'UKR-HR-0001') <> 'Зламано', 'користувач не може змінити каталог');
insert into public.user_errors (user_id, source, original_text, corrected_text, explanation_ua, error_type, linguistic_error_id)
select 'a1400000-0000-4000-8000-0000000000a1', 'exercise', incorrect_text, correct_text, title_ua, 'grammar', id
from public.linguistic_errors where code = 'UKR-HR-0001';
select pg_temp.ok(pg_temp.n($q$select 1 from public.user_errors where linguistic_error_id is not null$q$) = 1,
  'A додає типову помилку у свої помилки');
select pg_temp.ok(pg_temp.raises($q$insert into public.user_errors (user_id, source, original_text, corrected_text, error_type, linguistic_error_id)
  select 'a1400000-0000-4000-8000-0000000000a1', 'exercise', 'x', 'y', 'grammar', id from public.linguistic_errors where code = 'UKR-HR-0001'$q$),
  'та сама типова помилка вдруге не дублюється');
select pg_temp.ok(pg_temp.raises($q$insert into public.user_errors (user_id, source, original_text, corrected_text, error_type, linguistic_error_id)
  select 'b1400000-0000-4000-8000-0000000000b1', 'exercise', 'x', 'y', 'grammar', id from public.linguistic_errors where code = 'UKR-HR-0002'$q$),
  'A не може додати помилку від імені B');

-- ---------------------------------------------------------------- користувач B
reset role;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"b1400000-0000-4000-8000-0000000000b1","role":"authenticated"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.user_errors$q$) = 0, 'B не бачить помилок A');

reset role;
select 'ALL TESTS PASSED' as result;
rollback;
