-- =====================================================================
-- M7 · Онбординг і тест рівня (§59, §90, §116, §123 ТЗ) · 2026-10-12
-- Адитивна, ідемпотентна. Потребує M2/M3 (статуси, is_admin()).
--
--   * profiles: мета, щоденна ціль, рівень, часовий пояс, ознака завершеного онбордингу.
--   * assessments / assessment_items — контент тесту (статуси як у всього контенту:
--     користувач бачить лише PUBLISHED, адмін — усе).
--   * assessment_attempts — спроби користувача: лише свої, лише додавання;
--     результат завжди «оцінка застосунку», не офіційний сертифікат (is_official = false).
-- =====================================================================

-- 1. Профіль (§116)
alter table public.profiles add column if not exists native_language text not null default 'uk';
alter table public.profiles add column if not exists current_level text;
alter table public.profiles add column if not exists daily_goal_minutes integer;
alter table public.profiles add column if not exists learning_goals text[] not null default '{}';
alter table public.profiles add column if not exists timezone text;
alter table public.profiles add column if not exists onboarding_completed boolean not null default false;
alter table public.profiles add column if not exists onboarding_completed_at timestamptz;
alter table public.profiles add column if not exists updated_at timestamptz not null default now();

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'profiles_current_level_check') then
    alter table public.profiles add constraint profiles_current_level_check
      check (current_level is null or current_level in ('A0', 'A1', 'A2', 'B1', 'B2'));
  end if;
  if not exists (select 1 from pg_constraint where conname = 'profiles_daily_goal_check') then
    alter table public.profiles add constraint profiles_daily_goal_check
      check (daily_goal_minutes is null or daily_goal_minutes in (5, 15, 30, 60));
  end if;
  if not exists (select 1 from pg_constraint where conname = 'profiles_learning_goals_check') then
    alter table public.profiles add constraint profiles_learning_goals_check
      check (learning_goals <@ array['daily_life', 'work', 'documents', 'social', 'travel']::text[]);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'profiles_timezone_check') then
    alter table public.profiles add constraint profiles_timezone_check
      check (timezone is null or timezone ~ '^[A-Za-z_]+(/[A-Za-z0-9_+-]+){0,2}$');
  end if;
end $$;

-- Користувач змінює лише свій профіль (і не може переписати id)
drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile" on public.profiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- 2. Тести (§123)
create table if not exists public.assessments (
  id          uuid primary key default gen_random_uuid(),
  slug        text not null unique check (slug ~ '^[a-z0-9_-]{3,60}$'),
  kind        text not null check (kind in ('placement', 'diagnostic', 'module', 'mid', 'final')),
  title_ua    text not null,
  version     integer not null default 1,
  status      text not null default 'DRAFT'
                check (status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED', 'PUBLISHED', 'DEPRECATED')),
  source      text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table if not exists public.assessment_items (
  id             uuid primary key default gen_random_uuid(),
  assessment_id  uuid not null references public.assessments(id) on delete cascade,
  order_index    integer not null,
  cefr           text not null check (cefr in ('A0', 'A1', 'A2', 'B1', 'B2')),
  skill          text not null check (skill in ('vocabulary', 'grammar', 'reading', 'listening', 'speaking')),
  item_type      text not null default 'multiple_choice' check (item_type in ('multiple_choice')),
  prompt_ua      text not null,
  prompt_hr      text,
  options        jsonb not null check (jsonb_typeof(options) = 'array' and jsonb_array_length(options) between 2 and 6),
  correct_index  integer not null check (correct_index >= 0),
  explanation_ua text,
  weight         numeric not null default 1 check (weight > 0),
  status         text not null default 'DRAFT'
                   check (status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED', 'PUBLISHED', 'DEPRECATED')),
  version        integer not null default 1,
  source         text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  unique (assessment_id, order_index),
  check (correct_index < jsonb_array_length(options))
);

create index if not exists idx_assessment_items_assessment on public.assessment_items (assessment_id, order_index);

create table if not exists public.assessment_attempts (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid not null default auth.uid() references auth.users(id) on delete cascade,
  assessment_id      uuid not null references public.assessments(id) on delete cascade,
  started_at         timestamptz,
  completed_at       timestamptz not null default now(),
  answers            jsonb not null default '[]'::jsonb check (jsonb_typeof(answers) = 'array'),
  score_by_level     jsonb not null default '{}'::jsonb check (jsonb_typeof(score_by_level) = 'object'),
  skill_profile      jsonb not null default '{}'::jsonb check (jsonb_typeof(skill_profile) = 'object'),
  estimated_cefr     text not null check (estimated_cefr in ('A0', 'A1', 'A2', 'B1', 'B2')),
  confidence         text not null check (confidence in ('low', 'medium', 'high')),
  recommended_start  text not null check (recommended_start in ('A0', 'A1', 'A2', 'B1', 'B2')),
  is_official        boolean not null default false check (is_official = false),
  created_at         timestamptz not null default now()
);

create index if not exists idx_assessment_attempts_user on public.assessment_attempts (user_id, completed_at desc);

alter table public.assessments enable row level security;
alter table public.assessment_items enable row level security;
alter table public.assessment_attempts enable row level security;

-- Контент тесту: користувач — лише PUBLISHED; адмін — усе (як у M2/M3)
do $$
declare
  t text;
begin
  foreach t in array array['assessments', 'assessment_items']
  loop
    execute format('drop policy if exists "Read published %1$s" on public.%1$I', t);
    execute format('create policy "Read published %1$s" on public.%1$I for select using (status = ''PUBLISHED'')', t);
    execute format('drop policy if exists "Admins can read all %1$s" on public.%1$I', t);
    execute format('create policy "Admins can read all %1$s" on public.%1$I for select to authenticated using ((select public.is_admin()))', t);
    execute format('drop policy if exists "Admins can insert %1$s" on public.%1$I', t);
    execute format('create policy "Admins can insert %1$s" on public.%1$I for insert to authenticated with check ((select public.is_admin()))', t);
    execute format('drop policy if exists "Admins can update %1$s" on public.%1$I', t);
    execute format('create policy "Admins can update %1$s" on public.%1$I for update to authenticated using ((select public.is_admin())) with check ((select public.is_admin()))', t);
  end loop;
end $$;

-- Спроби: лише свої, лише додавання (змінити чи видалити результат не можна)
drop policy if exists "Users can insert own attempts" on public.assessment_attempts;
create policy "Users can insert own attempts" on public.assessment_attempts
  for insert to authenticated with check (user_id = (select auth.uid()));
drop policy if exists "Users can view own attempts" on public.assessment_attempts;
create policy "Users can view own attempts" on public.assessment_attempts
  for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists "Admins can view all attempts" on public.assessment_attempts;
create policy "Admins can view all attempts" on public.assessment_attempts
  for select to authenticated using ((select public.is_admin()));

revoke update, delete, truncate on public.assessment_attempts from anon, authenticated;

-- 3. Журнал рев'ю й версій (M2) приймає також тести
do $$
declare
  t text;
begin
  foreach t in array array['content_reviews', 'content_versions']
  loop
    execute format('alter table public.%I drop constraint if exists %I', t, t || '_entity_type_check');
    execute format(
      'alter table public.%I add constraint %I check (entity_type in (''lexeme'', ''phrase'', ''conversation'', ''conversation_turn'', ''lesson'', ''exercise'', ''grammar_topic'', ''grammar_rule'', ''assessment'', ''assessment_item''))',
      t, t || '_entity_type_check');
  end loop;
end $$;
