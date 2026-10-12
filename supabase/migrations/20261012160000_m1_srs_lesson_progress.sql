-- =====================================================================
-- M1 · Полагодити SRS і прогрес уроку (2026-10-12)
-- Адитивна, зворотно сумісна, ідемпотентна (можна запускати повторно).
-- Див. docs/DB_GAP_ANALYSIS.md → «Код не збігається з базою».
-- =====================================================================

-- 1. user_progress: одна картка на пару (користувач, лексема) + поля для SRS
alter table public.user_progress add column if not exists lapses     integer     not null default 0;
alter table public.user_progress add column if not exists updated_at timestamptz not null default now();

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'user_progress_user_id_lexeme_id_key' and conrelid = 'public.user_progress'::regclass
  ) then
    alter table public.user_progress
      add constraint user_progress_user_id_lexeme_id_key unique (user_id, lexeme_id);
  end if;
end $$;

-- Швидкий пошук карток «на сьогодні»
create index if not exists idx_user_progress_due on public.user_progress (user_id, next_review_date);
create index if not exists idx_srs_reviews_user_created on public.srs_reviews (user_id, created_at);

-- 2. Прогрес уроку (код сторінки уроку вже пише сюди)
create table if not exists public.lesson_progress (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) on delete cascade,
  lesson_id     uuid not null references public.lessons(id) on delete cascade,
  status        text not null default 'in_progress' check (status in ('in_progress', 'completed')),
  started_at    timestamptz not null default now(),
  completed_at  timestamptz,
  updated_at    timestamptz not null default now(),
  unique (user_id, lesson_id)
);

alter table public.lesson_progress enable row level security;

drop policy if exists "Users can view own lesson progress"   on public.lesson_progress;
drop policy if exists "Users can insert own lesson progress" on public.lesson_progress;
drop policy if exists "Users can update own lesson progress" on public.lesson_progress;

create policy "Users can view own lesson progress"   on public.lesson_progress
  for select using (auth.uid() = user_id);
create policy "Users can insert own lesson progress" on public.lesson_progress
  for insert with check (auth.uid() = user_id);
create policy "Users can update own lesson progress" on public.lesson_progress
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 3. Зламана функція: посилалась на неіснуючі topic_progress і vocabulary.
--    Її роль тепер виконує server action completeLesson (app/actions/progress.ts).
drop function if exists public.complete_lesson_and_start_srs(uuid, uuid);
