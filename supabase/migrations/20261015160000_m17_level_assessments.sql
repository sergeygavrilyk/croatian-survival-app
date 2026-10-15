-- =====================================================================
-- M17 · Оцінювання рівня (§60 ТЗ): тести модуля, середини й кінця рівня · 2026-10-15
-- Адитивна, ідемпотентна, зворотно сумісна (§128). Потребує M7 (assessments).
--
-- Рішення власника 2026-10-15: тест не блокує уроки; пройдено = ≥ 70 % загалом і ≥ 50 %
-- у кожній навичці; говоріння можна пропустити; завдання A0/A1 — бета (PUBLISHED).
--
--   * assessments: рівень, модуль, порядок, поріг проходження, хвилини, опис.
--   * assessment_items:
--       - навичка ТЗ §60 (area): understand «розумію» · produce «кажу» · interact «спілкуюся» · mediate «переказую»;
--       - нові типи: type_answer (написати), sentence_builder (скласти речення), speaking (сказати вголос);
--       - audio_hr (фраза, яку чути, але не видно), passage_hr / passage_ua (текст і його переклад),
--         answer_text (правильна відповідь для завдань без варіантів), lesson_id (урок-джерело: «що повторити»);
--       - правила для варіантів відповіді тепер залежать від типу (для тесту рівня нічого не змінюється).
--   * assessment_attempts: score (частка), passed, area_scores (бали за навичками).
-- Тест рівня (placement-v1) продовжує працювати без змін: його питання — multiple_choice.
-- =====================================================================

-- 1. Тест: рівень, модуль, поріг
alter table public.assessments add column if not exists cefr              text;
alter table public.assessments add column if not exists module_id         uuid references public.modules(id) on delete set null;
alter table public.assessments add column if not exists order_index       integer not null default 0;
alter table public.assessments add column if not exists pass_ratio        numeric(3,2) not null default 0.70;
alter table public.assessments add column if not exists area_min_ratio    numeric(3,2) not null default 0.50;
alter table public.assessments add column if not exists estimated_minutes integer;
alter table public.assessments add column if not exists description_ua    text;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'assessments_cefr_check' and conrelid = 'public.assessments'::regclass) then
    alter table public.assessments add constraint assessments_cefr_check
      check (cefr is null or cefr in ('A0', 'A1', 'A2', 'B1', 'B2'));
  end if;
  if not exists (select 1 from pg_constraint where conname = 'assessments_ratios_check' and conrelid = 'public.assessments'::regclass) then
    alter table public.assessments add constraint assessments_ratios_check
      check (pass_ratio > 0 and pass_ratio <= 1 and area_min_ratio >= 0 and area_min_ratio <= 1);
  end if;
  -- Тест модуля прив'язаний до модуля; тест середини / кінця — до рівня
  if not exists (select 1 from pg_constraint where conname = 'assessments_level_kind_check' and conrelid = 'public.assessments'::regclass) then
    alter table public.assessments add constraint assessments_level_kind_check
      check (kind not in ('module', 'mid', 'final') or (cefr is not null and (kind <> 'module' or module_id is not null)));
  end if;
end $$;

create index if not exists idx_assessments_level on public.assessments (cefr, kind, order_index);

comment on column public.assessments.pass_ratio is 'Пройдено, якщо частка правильних ≥ pass_ratio (рішення власника 2026-10-15: 0.70)';
comment on column public.assessments.area_min_ratio is '… і в кожній навичці (area) з відповідями ≥ area_min_ratio (0.50)';

-- 2. Завдання: навички §60, нові типи, аудіо / текст, урок-джерело
alter table public.assessment_items add column if not exists area        text;
alter table public.assessment_items add column if not exists audio_hr    text;
alter table public.assessment_items add column if not exists passage_hr  text;
alter table public.assessment_items add column if not exists passage_ua  text;
alter table public.assessment_items add column if not exists answer_text text;
alter table public.assessment_items add column if not exists lesson_id   uuid references public.lessons(id) on delete set null;

-- correct_index потрібен лише для завдань з варіантами
alter table public.assessment_items alter column correct_index drop not null;

alter table public.assessment_items drop constraint if exists assessment_items_skill_check;
alter table public.assessment_items add constraint assessment_items_skill_check
  check (skill in ('vocabulary', 'grammar', 'reading', 'listening', 'speaking', 'writing', 'interaction', 'mediation'));

alter table public.assessment_items drop constraint if exists assessment_items_item_type_check;
alter table public.assessment_items add constraint assessment_items_item_type_check
  check (item_type in ('multiple_choice', 'type_answer', 'sentence_builder', 'speaking'));

-- Варіанти: вибір — 2–6 варіантів і правильний індекс; «склади» — 2–16 плиток і відповідь;
-- «напиши» / «скажи» — без варіантів, з відповіддю. Для наявних питань тесту рівня правило те саме, що й було.
alter table public.assessment_items drop constraint if exists assessment_items_options_check;
alter table public.assessment_items drop constraint if exists assessment_items_check;
alter table public.assessment_items drop constraint if exists assessment_items_answer_shape_check;
alter table public.assessment_items add constraint assessment_items_answer_shape_check check (
  jsonb_typeof(options) = 'array' and (
    (item_type = 'multiple_choice' and jsonb_array_length(options) between 2 and 6
       and correct_index is not null and correct_index < jsonb_array_length(options))
    or (item_type = 'sentence_builder' and jsonb_array_length(options) between 2 and 16
       and correct_index is null and coalesce(answer_text, '') <> '')
    or (item_type in ('type_answer', 'speaking') and jsonb_array_length(options) = 0
       and correct_index is null and coalesce(answer_text, '') <> '')
  ));

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'assessment_items_area_check' and conrelid = 'public.assessment_items'::regclass) then
    alter table public.assessment_items add constraint assessment_items_area_check
      check (area is null or area in ('understand', 'produce', 'interact', 'mediate'));
  end if;
  -- Хорватське — латиницею (кирилиця в хорватському полі — помилка контенту)
  if not exists (select 1 from pg_constraint where conname = 'assessment_items_hr_latin_check' and conrelid = 'public.assessment_items'::regclass) then
    alter table public.assessment_items add constraint assessment_items_hr_latin_check
      check (coalesce(audio_hr, '') !~ '[Ѐ-ӿ]' and coalesce(passage_hr, '') !~ '[Ѐ-ӿ]'
             and (item_type = 'multiple_choice' or coalesce(answer_text, '') !~ '[Ѐ-ӿ]'));
  end if;
end $$;

comment on column public.assessment_items.area is 'Навичка §60: understand (розумію), produce (кажу), interact (спілкуюся), mediate (переказую). null — тест рівня';
comment on column public.assessment_items.audio_hr is 'Хорватська фраза, яку озвучують (текст не показують до відповіді)';
comment on column public.assessment_items.answer_text is 'Правильна відповідь для type_answer / sentence_builder / speaking (перевіряє сервер)';
comment on column public.assessment_items.lesson_id is 'Урок, з якого взято завдання: результат радить, що повторити';

-- 3. Спроба: бал, «пройдено», бали за навичками
alter table public.assessment_attempts add column if not exists score       numeric(4,3);
alter table public.assessment_attempts add column if not exists passed      boolean;
alter table public.assessment_attempts add column if not exists area_scores jsonb not null default '{}'::jsonb;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'assessment_attempts_score_check' and conrelid = 'public.assessment_attempts'::regclass) then
    alter table public.assessment_attempts add constraint assessment_attempts_score_check
      check ((score is null or score between 0 and 1) and jsonb_typeof(area_scores) = 'object');
  end if;
end $$;

create index if not exists idx_assessment_attempts_user_assessment
  on public.assessment_attempts (user_id, assessment_id, completed_at desc);

comment on column public.assessment_attempts.area_scores is
  'Бали за навичками §60: {"understand": {"correct": n, "total": n}, …}; пропущене говоріння не рахується';
