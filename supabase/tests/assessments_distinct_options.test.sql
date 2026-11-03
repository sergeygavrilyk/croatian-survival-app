-- =====================================================================
-- Тести: хибні варіанти в перевірках рівня A0 / A1 не повторюються в тесті · 2026-11-03
-- Запускати ПІСЛЯ supabase/data_fixes/20261103_assessments_distinct_options.sql.
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
-- Запуск: Supabase → SQL Editor → вставити файл → Run. Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

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

-- Опубліковані завдання тестів модулів, середини й фіналу A0 / A1
create temp view tst as
select a.slug, i.*
from public.assessment_items i
join public.assessments a on a.id = i.assessment_id
where a.status = 'PUBLISHED' and i.status = 'PUBLISHED' and a.kind in ('module', 'mid', 'final') and a.cefr in ('A0', 'A1');

-- Хибні варіанти (крім «прочитайте»: там варіанти — із запитання до тексту)
create temp view wrong as
select t.slug, t.id, t.order_index, lower(btrim(e)) as opt
from tst t, jsonb_array_elements_text(t.options) with ordinality as x(e, n)
where t.item_type = 'multiple_choice' and n - 1 <> t.correct_index and t.skill <> 'reading';

create temp view answers as
select t.slug, t.id, lower(btrim(case when t.item_type = 'multiple_choice' then t.options ->> t.correct_index else t.answer_text end)) as ans
from tst t;

select pg_temp.ok(pg_temp.n($q$select 1 from tst$q$) > 0, 'перевірки A0 / A1 є');
select pg_temp.ok(pg_temp.n($q$select slug, opt from wrong group by slug, opt having count(*) > 1$q$) = 0,
  'хибний варіант не повторюється у двох завданнях одного тесту');
select pg_temp.ok(pg_temp.n($q$select 1 from wrong w join answers c on c.slug = w.slug and c.id <> w.id and c.ans = w.opt$q$) = 0,
  'хибний варіант не є правильною відповіддю іншого завдання того самого тесту');
select pg_temp.ok(pg_temp.n($q$select 1 from tst where item_type = 'multiple_choice'
  and (correct_index is null or correct_index >= jsonb_array_length(options) or jsonb_array_length(options) < 3)$q$) = 0,
  'вибір: щонайменше 3 варіанти, правильний індекс у межах');
select pg_temp.ok(pg_temp.n($q$select t.id from tst t, jsonb_array_elements_text(t.options) e
  where t.item_type = 'multiple_choice' group by t.id having count(*) <> count(distinct lower(btrim(e)))$q$) = 0,
  'варіанти одного завдання різні');
-- «Спілкуюся» й «кажу хорватською» — варіанти хорватською (без кирилиці); «на слух» і «переказую» — українською
select pg_temp.ok(pg_temp.n($q$select 1 from tst t, jsonb_array_elements_text(t.options) e
  where t.item_type = 'multiple_choice' and t.skill = 'interaction' and e ~ '[Ѐ-ӿ]'$q$) = 0,
  'відповіді в розмові — хорватською');
select pg_temp.ok(pg_temp.n($q$select 1 from tst t, jsonb_array_elements_text(t.options) e
  where t.item_type = 'multiple_choice' and t.skill = 'listening' and e !~ '[Ѐ-ӿ]'$q$) = 0,
  'варіанти «на слух» — українською');

-- Пакет 2026-11-03 змінює лише варіанти: id, місце й правильна відповідь лишаються (старі спроби чинні)
select pg_temp.ok(pg_temp.n($q$select 1 from tst where id in ('adb9f6f3-4143-52da-96b4-efac02ed3b3a', '0fd92cef-7905-521f-bfcd-6d8f2a652b39')$q$) = 2,
  'виправлені завдання a0-final #12 і a1-m02 #7 на своїх місцях');
select pg_temp.ok((select options ->> correct_index from tst where id = 'adb9f6f3-4143-52da-96b4-efac02ed3b3a') = 'Ne, nazvali ste krivi broj.',
  'a0-final #12: правильна відповідь та сама');
select pg_temp.ok((select options ->> correct_index from tst where id = '0fd92cef-7905-521f-bfcd-6d8f2a652b39') = 'Što je danas sezonsko?',
  'a1-m02 #7: правильна відповідь та сама');

select 'ALL TESTS PASSED' as result;
rollback;
