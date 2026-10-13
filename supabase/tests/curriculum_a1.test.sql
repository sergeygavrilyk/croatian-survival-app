-- =====================================================================
-- Тести програми A1 (curriculum_a1_v1): 10 модулів, ≥ 49 уроків, 13 тем граматики.
-- Запускати ПІСЛЯ обох частин: 20261013_curriculum_a1_v1_part1.sql і _part2.sql.
-- Після доповнення (curriculum_a1_v2) теж має проходити; окремі перевірки доповнення — curriculum_a1_v2.test.sql.
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

-- ---------------------------------------------------------------- структура
select pg_temp.ok(pg_temp.n($q$select 1 from public.modules where level_code = 'A1' and status = 'PUBLISHED'$q$) = 10,
  'A1: 10 опублікованих модулів');
select pg_temp.ok(pg_temp.n($q$select 1 from public.modules m where m.level_code = 'A1'
  and (select count(*) from public.units u where u.module_id = m.id and u.status = 'PUBLISHED') <> 1$q$) = 0,
  'у кожному модулі A1 один опублікований юніт');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id
  join public.modules m on m.id = u.module_id where m.level_code = 'A1' and l.status = 'PUBLISHED'$q$) >= 49,
  'A1: щонайменше 49 опублікованих уроків');
select pg_temp.ok(pg_temp.n($q$select u.id from public.units u join public.modules m on m.id = u.module_id
  join public.lessons l on l.unit_id = u.id where m.level_code = 'A1'
  group by u.id having count(*) not between 3 and 9 or max(l.order_index) <> count(*) or min(l.order_index) <> 1$q$) = 0,
  'у кожному юніті A1 3–9 уроків, номери 1…N без пропусків');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_topics g where g.cefr = 'A1'
  and (g.status <> 'PUBLISHED' or (select count(*) from public.grammar_rules r where r.topic_id = g.id) < 2)$q$) = 0,
  'усі 13 тем граматики A1 опубліковано, у кожній ≥ 2 правила');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and jsonb_array_length(r.examples) < 2$q$) = 0,
  'у кожному правилі A1 щонайменше 2 приклади');

-- ---------------------------------------------------------------- урок
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l where l.level_code = 'A1' and l.status = 'PUBLISHED'
  and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'lexeme') not between 10 and 14$q$) = 0,
  'у кожному уроці A1 10–14 слів');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l where l.level_code = 'A1' and l.status = 'PUBLISHED'
  and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') <> 12$q$) = 0,
  'у кожному уроці A1 12 вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l where l.level_code = 'A1' and l.status = 'PUBLISHED'
  and (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2$q$) = 0,
  'у кожному уроці A1 два діалоги');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l where l.level_code = 'A1' and l.status = 'PUBLISHED'
  and not exists (select 1 from public.lesson_items i join public.grammar_topics g on g.id = i.item_id
                  where i.lesson_id = l.id and i.item_type = 'grammar' and g.status = 'PUBLISHED')$q$) = 0,
  'у кожному уроці A1 є опублікована граматика');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l where l.level_code = 'A1' and l.status = 'PUBLISHED'
  and (select count(distinct e.exercise_type) from public.lesson_items i join public.exercises e on e.id = i.item_id
       where i.lesson_id = l.id and i.item_type = 'exercise') < 6$q$) = 0,
  'у кожному уроці A1 усі 6 типів вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A1' and status = 'PUBLISHED'
  and (estimated_minutes is distinct from 12 or jsonb_array_length(objectives) < 2)$q$) = 0,
  'урок A1: 12 хвилин і мета уроку');
select pg_temp.ok(pg_temp.n($q$select lesson_id, item_type, item_id from public.lesson_items i
  join public.lessons l on l.id = i.lesson_id where l.level_code = 'A1' group by 1, 2, 3 having count(*) > 1$q$) = 0,
  'жоден елемент не повторюється в уроці A1');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations c where c.level = 'A1' and c.status = 'PUBLISHED'
  and c.lesson_id is not null
  and (c.situation is null or (select count(*) from public.conversation_turns t where t.conversation_id = c.id) < 4)$q$) = 0,
  'у кожного діалогу A1 є ситуація і ≥ 4 репліки');

-- ---------------------------------------------------------------- вміст вправ
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises where level = 'A1' and exercise_type in ('multiple_choice', 'fill_in_the_blank')
  and (jsonb_array_length(options) <> 4 or not options ? correct_answer
       or (select count(distinct x) from jsonb_array_elements_text(options) x) <> 4)$q$) = 0,
  'вибір і «вставте слово»: 4 різні варіанти, серед них правильний');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e where e.level = 'A1' and e.exercise_type in ('sentence_builder', 'listening')
  and (select array_agg(x order by x) from jsonb_array_elements_text(e.options) x)
   <> (select array_agg(x order by x) from unnest(string_to_array(e.correct_answer, ' ')) x)$q$) = 0,
  'плитки = слова відповіді');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e where e.level = 'A1' and e.exercise_type = 'type_answer'
  and not exists (select 1 from public.lexemes x where x.id = e.lexeme_id and x.lemma = e.correct_answer)$q$) = 0,
  '«напишіть»: відповідь — лема пов’язаного слова');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises where level = 'A1'
  and exercise_type in ('type_answer', 'speaking', 'sentence_builder', 'listening') and correct_answer ~ '[Ѐ-ӿ]'$q$) = 0,
  'відповіді у вправах A1 — хорватською');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lower(lemma) in ('luk', 'slobodno vrijeme', 'vozačka dozvola')
  and (ukrainian_translation in ('цибуля / часник', 'віільний час') or lemma = 'Vozačka dozvola')$q$) = 0,
  'виправлено luk, slobodno vrijeme і написання vozačka dozvola');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where ukrainian_translation in ('вхо', 'Будьмо! (Тост)') or lemma in ('Mobilno bankarstvo', 'Prtljažnik')$q$) = 0,
  'виправлено uho, živjeli, mobilno bankarstvo, prtljažnik');

-- ---------------------------------------------------------------- гість
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A1'$q$) >= 49, 'гість бачить усі (≥ 49) уроки A1');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1'$q$) >= 26, 'гість бачить правила граматики A1');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversation_turns t join public.conversations c on c.id = t.conversation_id
  join public.lessons l on l.id = c.lesson_id where l.id = '4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d'$q$) >= 8,
  'гість бачить обидва діалоги уроку A1.10.3');
select pg_temp.ok(pg_temp.n($q$select 1 from public.modules where level_code = 'A2'$q$) = 0, 'гість не бачить чернеток A2');

reset role;
select 'ALL TESTS PASSED' as result;
rollback;
