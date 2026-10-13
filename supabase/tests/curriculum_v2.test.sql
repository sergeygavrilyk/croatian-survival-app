-- =====================================================================
-- Тести M13 + розширення уроків A0 (curriculum_a0_v2).
-- Запускати ПІСЛЯ M13 і 20261013_curriculum_a0_v2.sql.
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

-- ---------------------------------------------------------------- обсяг уроків
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l where l.level_code = 'A0' and l.status = 'PUBLISHED'
  and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') < 12$q$) = 0,
  'у кожному уроці A0 щонайменше 12 вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l where l.level_code = 'A0' and l.status = 'PUBLISHED'
  and (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') < 2$q$) = 0,
  'у кожному уроці A0 дві сцени діалогу');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l where l.level_code = 'A0' and l.status = 'PUBLISHED'
  and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'lexeme') not between 8 and 12$q$) = 0,
  'у кожному уроці A0 8–12 слів');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A0' and status = 'PUBLISHED'
  and estimated_minutes is distinct from 12$q$) = 0, 'урок A0 розрахований на 12 хвилин');
select pg_temp.ok(pg_temp.n($q$select lesson_id, item_type, item_id from public.lesson_items
  group by 1, 2, 3 having count(*) > 1$q$) = 0, 'жоден елемент не повторюється в уроці');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l where l.level_code = 'A0' and l.status = 'PUBLISHED'
  and (select count(distinct e.exercise_type) from public.lesson_items i join public.exercises e on e.id = i.item_id
       where i.lesson_id = l.id and i.item_type = 'exercise') < 5$q$) = 0,
  'у кожному уроці A0 щонайменше 5 різних типів вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations where level = 'A0' and status = 'PUBLISHED'
  and (situation is null or not exists (select 1 from public.conversation_turns t where t.conversation_id = conversations.id))$q$) = 0,
  'у кожного діалогу A0 є ситуація й репліки');

-- ---------------------------------------------------------------- вміст вправ
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises where exercise_type = 'multiple_choice'
  and (jsonb_array_length(options) <> 4 or not options ? correct_answer
       or (select count(distinct x) from jsonb_array_elements_text(options) x) <> 4)$q$) = 0,
  '«вибір»: 4 різні варіанти, серед них правильний');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises where exercise_type in ('type_answer', 'speaking')
  and (options is not null or correct_answer ~ '[Ѐ-ӿ]' or question_text !~ '[Ѐ-ӿ]')$q$) = 0,
  '«напишіть» і «скажіть»: завдання українською, відповідь хорватською, без варіантів');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e where e.exercise_type = 'type_answer'
  and not exists (select 1 from public.lexemes x where x.id = e.lexeme_id and x.lemma = e.correct_answer)$q$) = 0,
  '«напишіть»: відповідь — це лема пов’язаного слова');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lower(lemma) in ('skupo', 'jeftino', 'piće')
  and ukrainian_translation in ('дороге', 'дешеве', 'напої')$q$) = 0, 'переклади skupo / jeftino / piće виправлено');

-- ---------------------------------------------------------------- M13: обмеження
select pg_temp.ok(not pg_temp.raises($q$insert into public.exercises (exercise_type, question_text, correct_answer, status)
  values ('speaking', 'Добрий день.', 'Dobar dan.', 'DRAFT')$q$), 'тип speaking дозволено');
select pg_temp.ok(not pg_temp.raises($q$insert into public.exercises (exercise_type, question_text, correct_answer, status)
  values ('type_answer', 'Напишіть: «кава»', 'kava', 'DRAFT')$q$), 'тип type_answer дозволено');
select pg_temp.ok(pg_temp.raises($q$insert into public.exercises (exercise_type, question_text, correct_answer, status)
  values ('essay', 'тест', 'x', 'DRAFT')$q$), 'невідомий тип вправи — заборонено');
select pg_temp.ok(pg_temp.raises($q$insert into public.exercises (exercise_type, question_text, correct_answer, options, status)
  values ('multiple_choice', 'тест', 'kava', '["čaj", "voda"]', 'DRAFT')$q$), '«вибір» без правильної відповіді серед варіантів — заборонено');

-- ---------------------------------------------------------------- гість бачить розширений урок
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations c join public.lessons l on l.id = c.lesson_id
  where l.id = 'b095637e-0644-507e-8f3d-d323483dd3e4'$q$) = 2, 'гість бачить обидві сцени уроку A0.10.3');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e join public.lesson_items i on i.item_id = e.id
  join public.lessons l on l.id = i.lesson_id where l.id = 'b095637e-0644-507e-8f3d-d323483dd3e4'
  and e.exercise_type in ('speaking', 'type_answer', 'multiple_choice')$q$) = 7, 'гість бачить нові вправи уроку 30');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_versions$q$) = 0, 'гість не бачить історію змін контенту');

reset role;
select 'ALL TESTS PASSED' as result;
rollback;
