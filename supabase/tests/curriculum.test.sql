-- =====================================================================
-- Тести M10 + програми A0 (curriculum_a0_v1): порядок уроків і що бачить користувач.
-- Запускати ПІСЛЯ M10 і 20261012_curriculum_a0_v1.sql.
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

-- ---------------------------------------------------------------- структура (як адмін бази)
select pg_temp.ok(pg_temp.n($q$select 1 from public.modules where level_code = 'A0' and status = 'PUBLISHED'$q$) = 10,
  'A0: 10 опублікованих модулів');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id
  join public.modules m on m.id = u.module_id where m.level_code = 'A0' and l.status = 'PUBLISHED'$q$) = 30,
  'A0: 30 опублікованих уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where order_index is null$q$) = 0,
  'у кожного уроку є номер');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l where l.level_code = 'A0' and l.status = 'PUBLISHED'
  and not exists (select 1 from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise')$q$) = 0,
  'у кожному уроці A0 є вправи');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i where i.item_type = 'lexeme'
  and not exists (select 1 from public.lexemes x where x.id = i.item_id and x.status = 'PUBLISHED')$q$) = 0,
  'усі слова уроків існують і опубліковані');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i where i.item_type = 'exercise'
  and not exists (select 1 from public.exercises e where e.id = i.item_id and e.status = 'PUBLISHED')$q$) = 0,
  'усі вправи уроків існують і опубліковані');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e where e.exercise_type in ('sentence_builder', 'listening')
  and (select array_agg(x order by x) from jsonb_array_elements_text(e.options) x)
   <> (select array_agg(x order by x) from unnest(string_to_array(e.correct_answer, ' ')) x)$q$) = 0,
  'у «склади речення» і «аудіюванні» плитки = слова відповіді');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e where e.exercise_type = 'fill_in_the_blank'
  and not (e.options ? e.correct_answer)$q$) = 0,
  'у «встав слово» правильна відповідь є серед варіантів');
select pg_temp.ok(pg_temp.n($q$select 1 from public.modules where level_code in ('A1', 'A2', 'B1', 'B2') and status = 'PUBLISHED'
  and not exists (select 1 from public.units u where u.module_id = modules.id)$q$) = 0,
  'порожні модулі A1–B2 не опубліковані');

-- ---------------------------------------------------------------- M10: номер уроку
insert into public.lessons (id, unit_id, level_code, title_ua, status)
select '10000000-0000-4000-8000-0000000000aa', u.id, 'A0', 'тест: урок без номера', 'DRAFT'
from public.units u join public.modules m on m.id = u.module_id where m.level_code = 'A0' and m.order_index = 2 and u.order_index = 1;
select pg_temp.ok((select order_index from public.lessons where id = '10000000-0000-4000-8000-0000000000aa') = 4,
  'новий урок без номера стає в кінець юніту');
select pg_temp.ok(pg_temp.raises($q$insert into public.lessons (unit_id, level_code, title_ua, order_index)
  select unit_id, 'A0', 'тест: дубль', 1 from public.lessons where id = '10000000-0000-4000-8000-0000000000aa'$q$),
  'два уроки на одному місці — заборонено');
select pg_temp.ok(pg_temp.raises($q$update public.lessons set order_index = 0 where id = '10000000-0000-4000-8000-0000000000aa'$q$),
  'номер уроку ≥ 1');

-- ---------------------------------------------------------------- гість бачить опублікований урок повністю
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A0'$q$) = 30,
  'гість бачить 30 уроків A0 (чернетку — ні)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.modules where level_code = 'A1'$q$) = 0,
  'гість не бачить чернеток A1');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lessons l on l.id = i.lesson_id
  where l.title_ua like 'Урок 30:%'$q$) > 0, 'гість бачить склад уроку 30');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversation_turns t join public.conversations c on c.id = t.conversation_id
  join public.lessons l on l.id = c.lesson_id where l.title_ua like 'Урок 30:%'$q$) >= 4, 'гість бачить діалог уроку 30');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A0'$q$) > 0, 'гість бачить правила граматики A0');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_topics where cefr = 'B2'$q$) = 0,
  'гість не бачить чернеток граматики B2');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_reviews$q$) = 0, 'гість не бачить журнал перевірок');

reset role;
select 'ALL TESTS PASSED' as result;
rollback;
