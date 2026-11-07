-- =====================================================================
-- M19 · Письмо й переказ в уроці (§57, §58, §123) · 2026-11-05
-- Адитивна, ідемпотентна. Наявні дані не змінює й не видаляє.
--
--   * exercises.exercise_type: + 'write_message' («Напишіть повідомлення») і 'mediation' («Перекажіть другу»).
--   * exercises.task jsonb — завдання цих вправ: ситуація, пункти з ключами для перевірки без AI, підказки, зразки,
--     напрям переказу (hr_ua / ua_hr). Для інших типів — null.
--   * writing_attempts, mediation_attempts — спроби користувача: ЛИШЕ ТЕКСТ (без аудіо, рішення власника 2026-11-05),
--     скільки пунктів виконано, результат (correct / wrong / skipped). RLS: свої — додати й бачити; адмін бачить усе.
--     Видалення — разом з акаунтом (on delete cascade).
-- Вправи читає lib/writing.ts; перевірка — без AI (рішення власника 2026-11-05).
-- =====================================================================

alter table public.exercises drop constraint if exists exercises_type_check;
alter table public.exercises add constraint exercises_type_check
  check (exercise_type = any (array['fill_in_the_blank', 'sentence_builder', 'listening', 'multiple_choice', 'type_answer', 'speaking',
                                    'write_message', 'mediation']));

alter table public.exercises add column if not exists task jsonb;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'exercises_task_check' and conrelid = 'public.exercises'::regclass) then
    alter table public.exercises add constraint exercises_task_check
      check (
        (exercise_type not in ('write_message', 'mediation') and task is null)
        or (exercise_type in ('write_message', 'mediation') and jsonb_typeof(task) = 'object'
            and jsonb_typeof(task -> 'points') = 'array' and jsonb_array_length(task -> 'points') between 1 and 5
            and jsonb_typeof(task -> 'models') = 'array' and jsonb_array_length(task -> 'models') >= 1
            and (exercise_type <> 'mediation' or task ->> 'direction' in ('hr_ua', 'ua_hr')))
      ) not valid;
  end if;
end $$;

comment on column public.exercises.task is
  'write_message / mediation: {situation_ua, source_hr?, friend_ua?, direction?: hr_ua | ua_hr, '
  'points: [{ua, keys: [["stem", …], …]}], hints: [hr], models: [text]}. Перевірка — lib/writing.ts';

-- ---------------------------------------------------------------- спроби
create table if not exists public.writing_attempts (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null default auth.uid() references auth.users(id) on delete cascade,
  exercise_id   uuid references public.exercises(id) on delete set null,
  lesson_id     uuid references public.lessons(id) on delete set null,
  text          text not null check (length(text) between 1 and 1000),
  points_total  smallint not null check (points_total between 0 and 10),
  points_ok     smallint not null check (points_ok between 0 and points_total),
  outcome       text not null check (outcome in ('correct', 'wrong', 'skipped')),
  input_mode    text not null default 'typed' check (input_mode in ('typed', 'voice')),
  created_at    timestamptz not null default now()
);

create table if not exists public.mediation_attempts (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null default auth.uid() references auth.users(id) on delete cascade,
  exercise_id   uuid references public.exercises(id) on delete set null,
  lesson_id     uuid references public.lessons(id) on delete set null,
  direction     text not null check (direction in ('hr_ua', 'ua_hr')),
  text          text not null check (length(text) between 1 and 1000),
  points_total  smallint not null check (points_total between 0 and 10),
  points_ok     smallint not null check (points_ok between 0 and points_total),
  outcome       text not null check (outcome in ('correct', 'wrong', 'skipped')),
  input_mode    text not null default 'typed' check (input_mode in ('typed', 'voice')),
  created_at    timestamptz not null default now()
);

create index if not exists idx_writing_attempts_user on public.writing_attempts (user_id, created_at desc);
create index if not exists idx_mediation_attempts_user on public.mediation_attempts (user_id, created_at desc);

alter table public.writing_attempts enable row level security;
alter table public.mediation_attempts enable row level security;

drop policy if exists "Users can insert own writing attempts" on public.writing_attempts;
create policy "Users can insert own writing attempts" on public.writing_attempts
  for insert to authenticated with check (user_id = (select auth.uid()));
drop policy if exists "Users can view own writing attempts" on public.writing_attempts;
create policy "Users can view own writing attempts" on public.writing_attempts
  for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists "Admins can view all writing attempts" on public.writing_attempts;
create policy "Admins can view all writing attempts" on public.writing_attempts
  for select to authenticated using ((select public.is_admin()));

drop policy if exists "Users can insert own mediation attempts" on public.mediation_attempts;
create policy "Users can insert own mediation attempts" on public.mediation_attempts
  for insert to authenticated with check (user_id = (select auth.uid()));
drop policy if exists "Users can view own mediation attempts" on public.mediation_attempts;
create policy "Users can view own mediation attempts" on public.mediation_attempts
  for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists "Admins can view all mediation attempts" on public.mediation_attempts;
create policy "Admins can view all mediation attempts" on public.mediation_attempts
  for select to authenticated using ((select public.is_admin()));

revoke all on public.writing_attempts, public.mediation_attempts from anon;
grant select, insert on public.writing_attempts, public.mediation_attempts to authenticated;
