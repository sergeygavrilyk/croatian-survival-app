-- =====================================================================
-- M23 · Вправа «Прослухайте діалог чи оголошення» (listening_dialogue) · 2026-11-12
-- Рішення власника 2026-11-12 (docs/proposals/2026-11-12_listening_dialogue.md): так; замінює одну з двох
-- «Прослухайте і складіть фразу» в уроці; до 3 прослуховувань і «Повільніше»; запитання українською,
-- коротка відповідь — з A2.8; пізніше — і в кінець A1.
-- Адитивна, ідемпотентна. Наявні дані не змінює й не видаляє.
--
--   * exercises.exercise_type: + 'listening_dialogue'.
--   * exercises.task для listening_dialogue: {kind, situation_ua, script: [{speaker?, hr, ua}], questions:
--     [{q_ua, options[], correct} | {q_ua, answer_text, accept[]}], max_plays?}. Перевірка відповіді — lib/listening.ts.
--   * exercises_task_check (M19) — та сама перевірка письма й переказу + перевірка listening_dialogue (not valid:
--     наявні рядки не перевіряються, нові й змінені — так).
-- Нових таблиць немає: результат — у подіях exercise_completed (§71), як інші вправи уроку.
-- =====================================================================

alter table public.exercises drop constraint if exists exercises_type_check;
alter table public.exercises add constraint exercises_type_check
  check (exercise_type = any (array['fill_in_the_blank', 'sentence_builder', 'listening', 'multiple_choice', 'type_answer', 'speaking',
                                    'write_message', 'mediation', 'listening_dialogue']));

alter table public.exercises drop constraint if exists exercises_task_check;
alter table public.exercises add constraint exercises_task_check
  check (
    (exercise_type not in ('write_message', 'mediation', 'listening_dialogue') and task is null)
    or (exercise_type in ('write_message', 'mediation') and jsonb_typeof(task) = 'object'
        and jsonb_typeof(task -> 'points') = 'array' and jsonb_array_length(task -> 'points') between 1 and 5
        and jsonb_typeof(task -> 'models') = 'array' and jsonb_array_length(task -> 'models') >= 1
        and (exercise_type <> 'mediation' or task ->> 'direction' in ('hr_ua', 'ua_hr')))
    or (exercise_type = 'listening_dialogue' and jsonb_typeof(task) = 'object'
        and task ->> 'kind' in ('dialogue', 'announcement', 'voicemail', 'forecast', 'news')
        and coalesce(task ->> 'situation_ua', '') <> ''
        and jsonb_typeof(task -> 'script') = 'array' and jsonb_array_length(task -> 'script') between 1 and 12
        and jsonb_typeof(task -> 'questions') = 'array' and jsonb_array_length(task -> 'questions') between 1 and 4)
  ) not valid;

comment on column public.exercises.task is
  'write_message / mediation: {situation_ua, source_hr?, friend_ua?, direction?: hr_ua | ua_hr, '
  'points: [{ua, keys: [["stem", …], …]}], hints: [hr], models: [text]} — lib/writing.ts. '
  'listening_dialogue: {kind, situation_ua, script: [{speaker?, hr, ua}], questions: [{q_ua, options, correct} | '
  '{q_ua, answer_text, accept}], max_plays?} — lib/listening.ts';
