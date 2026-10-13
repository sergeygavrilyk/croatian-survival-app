-- =====================================================================
-- M13 · Нові типи вправ уроку: «напишіть слово» і «скажіть уголос»
-- 2026-10-13 · Адитивна, ідемпотентна. Дані не змінює й не видаляє.
--
--   * exercises.exercise_type: + 'type_answer' (написати хорватське слово за перекладом,
--     перевірка — lib/answer.ts) і 'speaking' (сказати фразу вголос, перевірка — lib/speaking.ts).
--   * Наявні типи (fill_in_the_blank, sentence_builder, listening, multiple_choice) лишаються.
--   * Перевірка вмісту: у варіантах «вибору» є правильна відповідь; у нових типах варіантів немає.
--   * Потрібна для supabase/data_fixes/20261013_curriculum_a0_v2.sql.
-- =====================================================================

alter table public.exercises drop constraint if exists exercises_type_check;
alter table public.exercises add constraint exercises_type_check
  check (exercise_type = any (array['fill_in_the_blank', 'sentence_builder', 'listening', 'multiple_choice', 'type_answer', 'speaking']));

-- Вправа з вибором має містити правильну відповідь серед варіантів.
-- not valid: наявні рядки не перевіряються заднім числом (їх перевіряє тест), нові — так.
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'exercises_choice_has_answer' and conrelid = 'public.exercises'::regclass) then
    alter table public.exercises add constraint exercises_choice_has_answer
      check (exercise_type <> 'multiple_choice' or (jsonb_typeof(options) = 'array' and options ? correct_answer)) not valid;
  end if;
end $$;

comment on column public.exercises.exercise_type is
  'fill_in_the_blank | multiple_choice — вибір; sentence_builder | listening — плитки (options = слова відповіді); '
  'type_answer — написати correct_answer за question_text; speaking — сказати correct_answer вголос (question_text — переклад)';
