-- =====================================================================
-- M8 · Говоріння (VS-003, §49, §122, §126) · 2026-10-12
-- Адитивна, ідемпотентна.
--
--   * speaking_sessions — заняття говорінням (де, в якому режимі, скільки спроб).
--   * speaking_attempts — кожна спроба: очікувана фраза, розпізнаний текст, вердикт.
--     АУДІО НЕ ЗБЕРІГАЄМО (§97): лише текст, який повернув розпізнавач.
--   * RLS: користувач бачить і пише лише своє; спроби — лише додавання.
-- =====================================================================

create table if not exists public.speaking_sessions (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  source          text not null check (source in ('situation', 'lesson', 'free')),
  situation       text check (situation is null or situation ~ '^[a-z][a-z_]{1,39}$'),
  lesson_id       uuid references public.lessons(id) on delete set null,
  mode            text not null check (mode in ('repeat', 'produce')),
  provider        text not null default 'web_speech' check (provider ~ '^[a-z0-9_.-]{2,40}$'),
  started_at      timestamptz not null default now(),
  ended_at        timestamptz,
  attempts_count  integer not null default 0 check (attempts_count >= 0)
);

create index if not exists idx_speaking_sessions_user on public.speaking_sessions (user_id, started_at desc);

create table if not exists public.speaking_attempts (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null default auth.uid() references auth.users(id) on delete cascade,
  session_id    uuid references public.speaking_sessions(id) on delete cascade,
  phrase_id     uuid references public.phrases(id) on delete set null,
  target_text   text not null check (length(target_text) between 1 and 300),
  mode          text not null check (mode in ('repeat', 'produce')),
  transcript    text check (transcript is null or length(transcript) <= 500),
  verdict       text not null check (verdict in ('great', 'understandable', 'almost', 'retry', 'no_speech')),
  match_score   numeric(4, 3) check (match_score is null or match_score between 0 and 1),
  missed_words  text[] not null default '{}',
  retry_number  integer not null default 0 check (retry_number between 0 and 50),
  duration_ms   integer check (duration_ms is null or duration_ms between 0 and 120000),
  provider      text not null default 'web_speech' check (provider ~ '^[a-z0-9_.-]{2,40}$'),
  created_at    timestamptz not null default now()
);

create index if not exists idx_speaking_attempts_user on public.speaking_attempts (user_id, created_at desc);
create index if not exists idx_speaking_attempts_session on public.speaking_attempts (session_id);

alter table public.speaking_sessions enable row level security;
alter table public.speaking_attempts enable row level security;

-- Сесії: свої — створити, бачити, завершити (оновити)
drop policy if exists "Users can insert own speaking sessions" on public.speaking_sessions;
create policy "Users can insert own speaking sessions" on public.speaking_sessions
  for insert to authenticated with check (user_id = (select auth.uid()));
drop policy if exists "Users can view own speaking sessions" on public.speaking_sessions;
create policy "Users can view own speaking sessions" on public.speaking_sessions
  for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists "Users can update own speaking sessions" on public.speaking_sessions;
create policy "Users can update own speaking sessions" on public.speaking_sessions
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- Спроби: свої, лише додавання; сесія теж має бути своя
drop policy if exists "Users can insert own speaking attempts" on public.speaking_attempts;
create policy "Users can insert own speaking attempts" on public.speaking_attempts
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and (session_id is null or exists (
      select 1 from public.speaking_sessions s
      where s.id = speaking_attempts.session_id and s.user_id = (select auth.uid())))
  );
drop policy if exists "Users can view own speaking attempts" on public.speaking_attempts;
create policy "Users can view own speaking attempts" on public.speaking_attempts
  for select to authenticated using (user_id = (select auth.uid()));

-- Адмін бачить усе (якість розпізнавання, складні фрази)
drop policy if exists "Admins can view all speaking sessions" on public.speaking_sessions;
create policy "Admins can view all speaking sessions" on public.speaking_sessions
  for select to authenticated using ((select public.is_admin()));
drop policy if exists "Admins can view all speaking attempts" on public.speaking_attempts;
create policy "Admins can view all speaking attempts" on public.speaking_attempts
  for select to authenticated using ((select public.is_admin()));

revoke delete, truncate on public.speaking_sessions from anon, authenticated;
revoke update, delete, truncate on public.speaking_attempts from anon, authenticated;
