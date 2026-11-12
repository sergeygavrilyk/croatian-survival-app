-- =====================================================================
-- Тести: вправа «Прослухайте діалог чи оголошення» (M23) і пілот в уроці A1 90 · 2026-11-12
-- Запускати ПІСЛЯ міграції 20261112100000_m23_listening_dialogue.sql і пакета 20261112_listening_pilot.sql.
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK. Успіх: «ALL TESTS PASSED».
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

create or replace function pg_temp.raises(q text) returns boolean language plpgsql as $$
begin
  execute q;
  return false;
exception when others then
  return true;
end $$;

-- ---------------------------------------------------------------- M23: тип і завдання
select pg_temp.ok(not pg_temp.raises($q$insert into public.exercises (exercise_type, question_text, correct_answer, task) values
  ('listening_dialogue', 'x', 'x', '{"kind": "dialogue", "situation_ua": "Розмова", "script": [{"hr": "Dobar dan.", "ua": "Добрий день."}],
    "questions": [{"q_ua": "Що?", "options": ["a", "b"], "correct": 0}]}')$q$), 'listening_dialogue з коректним завданням — можна');
select pg_temp.ok(pg_temp.raises($q$insert into public.exercises (exercise_type, question_text, correct_answer, task)
  values ('listening_dialogue', 'x', 'x', null)$q$), 'listening_dialogue без завдання — ні');
select pg_temp.ok(pg_temp.raises($q$insert into public.exercises (exercise_type, question_text, correct_answer, task) values
  ('listening_dialogue', 'x', 'x', '{"kind": "song", "situation_ua": "x", "script": [{"hr": "a", "ua": "б"}], "questions": [{"q_ua": "?"}]}')$q$),
  'невідомий вид запису — ні');
select pg_temp.ok(pg_temp.raises($q$insert into public.exercises (exercise_type, question_text, correct_answer, task) values
  ('listening_dialogue', 'x', 'x', '{"kind": "dialogue", "situation_ua": "x", "script": [], "questions": [{"q_ua": "?"}]}')$q$),
  'порожній запис — ні');
select pg_temp.ok(pg_temp.raises($q$insert into public.exercises (exercise_type, question_text, correct_answer, task) values
  ('listening_dialogue', 'x', 'x', '{"kind": "dialogue", "situation_ua": "x", "script": [{"hr": "a", "ua": "б"}], "questions": []}')$q$),
  'без запитань — ні');
select pg_temp.ok(pg_temp.raises($q$insert into public.exercises (exercise_type, question_text, correct_answer, task)
  values ('listening', 'x', 'x', '{"kind": "dialogue"}')$q$), 'звичайне аудіювання із завданням — ні (як і раніше)');
select pg_temp.ok(pg_temp.raises($q$insert into public.exercises (exercise_type, question_text, correct_answer)
  values ('podcast', 'x', 'x')$q$), 'невідомий тип вправи — ні');
select pg_temp.ok(not pg_temp.raises($q$insert into public.exercises (exercise_type, question_text, correct_answer, task) values
  ('write_message', 'x', 'x', '{"situation_ua": "x", "points": [{"ua": "x", "keys": [["a"]]}], "models": ["A."]}')$q$),
  'письмо (M19) — як і раніше');

-- ---------------------------------------------------------------- пілот: урок A1 90
create temp view pilot as
select li.order_index as item_order, li.required, e.id, e.exercise_type, e.status, e.task
from public.lesson_items li join public.exercises e on e.id = li.item_id
where li.lesson_id = '71ab330d-abbe-57a7-870e-77e59daf3627' and li.item_type = 'exercise';

select pg_temp.ok(pg_temp.n($q$select 1 from pilot where required and status = 'PUBLISHED'$q$) = 15, 'в уроці 90 — 15 обов’язкових вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pilot where exercise_type = 'listening_dialogue'$q$) = 1
  and pg_temp.n($q$select 1 from pilot where exercise_type = 'listening'$q$) = 1, 'одна «складіть на слух» замінена на «прослухайте оголошення»');
select pg_temp.ok((select item_order from pilot where exercise_type = 'listening_dialogue') = 28, 'нова вправа — на місці старої');
select pg_temp.ok(pg_temp.n($q$select 1 from pilot p, jsonb_array_elements(p.task -> 'script') l
  where p.exercise_type = 'listening_dialogue' and (length(l ->> 'hr') > 180 or l ->> 'hr' ~ '[Ѐ-ӿ]' or l ->> 'ua' !~ '[Ѐ-ӿ]')$q$) = 0,
  'репліки ≤ 180 знаків, хорватською, переклад українською');
select pg_temp.ok(pg_temp.n($q$select 1 from pilot p, jsonb_array_elements(p.task -> 'questions') q
  where p.exercise_type = 'listening_dialogue'
    and ((q ->> 'correct')::int < 0 or (q ->> 'correct')::int >= jsonb_array_length(q -> 'options'))$q$) = 0
  and (select jsonb_array_length(task -> 'questions') from pilot where exercise_type = 'listening_dialogue') = 3,
  '3 запитання, правильна відповідь серед варіантів');
select pg_temp.ok(exists (select 1 from backup.lesson_items_20261112 where item_id = '640a2f04-03dd-503e-8ae9-8b347259a081')
  and exists (select 1 from public.exercises where id = '640a2f04-03dd-503e-8ae9-8b347259a081'), 'стара вправа в базі, зв’язок — у backup');
select pg_temp.ok(exists (select 1 from public.content_reviews r join pilot p on p.id = r.entity_id
  where p.exercise_type = 'listening_dialogue' and r.notes like 'listening_pilot 2026-11-12%'), 'запис у журналі перевірок');

-- гість бачить нову вправу (як усі опубліковані вправи уроку)
set local role anon;
select pg_temp.ok(exists (select 1 from public.exercises where exercise_type = 'listening_dialogue' and status = 'PUBLISHED'), 'гість бачить опубліковану вправу');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
