-- =====================================================================
-- Слова «лише впізнавати» (LEARNING_SPEC §18, 2026-11-13; перевірка — 2026-11-16).
-- У жодному опублікованому уроці немає «Напишіть» / «Скажіть уголос» до слова, яке в цьому уроці лише
-- впізнають (lesson_items.target_skill = 'recognition'), і жодного «Напишіть» до нецензурного слова (vulgar).
-- Запобіжник для нових пакетів (B1, B2, «Сленг», «18+»); застосунок теж прибирає такі вправи (lib/recognition.ts).
-- БЕЗПЕЧНО для робочої бази: транзакція, у кінці ROLLBACK. Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

-- «Напишіть» / «Скажіть» до слова «лише впізнавати» в тому самому уроці (за exercises.lexeme_id)
create or replace function pg_temp.recognition_violations() returns bigint language sql as $$
  select count(*)
  from public.lesson_items w
  join public.lessons l on l.id = w.lesson_id and l.status = 'PUBLISHED'
  join public.lesson_items x on x.lesson_id = w.lesson_id and x.item_type = 'exercise'
  join public.exercises e on e.id = x.item_id and e.status = 'PUBLISHED'
  where w.item_type = 'lexeme' and w.target_skill = 'recognition'
    and e.exercise_type in ('type_answer', 'speaking') and e.lexeme_id = w.item_id
$$;

select pg_temp.ok((select count(*) from public.lesson_items
  where target_skill is not null
    and target_skill not in ('vocabulary', 'recognition', 'grammar', 'listening', 'speaking', 'writing', 'mediation')) = 0,
  'target_skill — лише відомі значення (recognition пишеться саме так)');

select pg_temp.ok(pg_temp.recognition_violations() = 0,
  'немає «Напишіть» / «Скажіть» до слова, яке в уроці лише впізнають');

select pg_temp.ok((select count(*)
  from public.exercises e
  join public.lexemes v on v.id = e.lexeme_id and v.register = 'vulgar'
  join public.lesson_items x on x.item_type = 'exercise' and x.item_id = e.id
  join public.lessons l on l.id = x.lesson_id and l.status = 'PUBLISHED'
  where e.status = 'PUBLISHED' and e.exercise_type in ('type_answer', 'speaking')) = 0,
  'немає «Напишіть» / «Скажіть» до нецензурного слова (модуль «18+» — лише впізнавати)');

-- Сама перевірка ловить порушення: позначимо слово наявної вправи «Напишіть» як «лише впізнавати»
update public.lesson_items w set target_skill = 'recognition'
from (
  select x.lesson_id, e.lexeme_id
  from public.lesson_items x
  join public.exercises e on e.id = x.item_id and e.status = 'PUBLISHED' and e.exercise_type = 'type_answer' and e.lexeme_id is not null
  join public.lessons l on l.id = x.lesson_id and l.status = 'PUBLISHED'
  join public.lesson_items lw on lw.lesson_id = x.lesson_id and lw.item_type = 'lexeme' and lw.item_id = e.lexeme_id
  where x.item_type = 'exercise'
  limit 1
) t
where w.lesson_id = t.lesson_id and w.item_type = 'lexeme' and w.item_id = t.lexeme_id;

select pg_temp.ok(
  not exists (select 1 from public.lesson_items where item_type = 'lexeme' and target_skill = 'recognition')
  or pg_temp.recognition_violations() >= 1,
  'перевірка помічає «Напишіть» до слова «лише впізнавати» (у тестовій зміні, яку відкочуємо)');

select 'ALL TESTS PASSED';
rollback;
