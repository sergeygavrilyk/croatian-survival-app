-- =====================================================================
-- M9 · Рольова гра з AI (VS-004, §50–52, §87, §115, §122) · 2026-10-12
-- Адитивна, ідемпотентна. Потребує M3 (is_admin()).
--
--   * ai_conversations — ситуація, рівень, кількість реплік, підсумок, кінець розмови.
--   * ai_messages — переклад репліки AI і виправлення репліки користувача;
--     повідомлення лише додаються (змінювати не можна).
--   * user_errors — помилки користувача для повторення (§19, §115), лише свої.
-- =====================================================================

-- 1. Розмови
alter table public.ai_conversations add column if not exists situation   text;
alter table public.ai_conversations add column if not exists level       text;
alter table public.ai_conversations add column if not exists user_turns  integer not null default 0;
alter table public.ai_conversations add column if not exists goal_reached boolean not null default false;
alter table public.ai_conversations add column if not exists summary     jsonb;
alter table public.ai_conversations add column if not exists ended_at    timestamptz;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'ai_conversations_situation_check') then
    alter table public.ai_conversations add constraint ai_conversations_situation_check
      check (situation is null or situation ~ '^[a-z][a-z_]{1,39}$');
  end if;
  if not exists (select 1 from pg_constraint where conname = 'ai_conversations_level_check') then
    alter table public.ai_conversations add constraint ai_conversations_level_check
      check (level is null or level in ('A0', 'A1', 'A2', 'B1', 'B2'));
  end if;
  if not exists (select 1 from pg_constraint where conname = 'ai_conversations_user_turns_check') then
    alter table public.ai_conversations add constraint ai_conversations_user_turns_check
      check (user_turns between 0 and 100);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'ai_conversations_summary_check') then
    alter table public.ai_conversations add constraint ai_conversations_summary_check
      check (summary is null or jsonb_typeof(summary) = 'object');
  end if;
end $$;

create index if not exists idx_ai_conversations_user on public.ai_conversations (user_id, created_at desc);

-- Розмова належить користувачу і не передається іншому (with check)
drop policy if exists "Users can manage own ai_conversations" on public.ai_conversations;
create policy "Users can manage own ai_conversations" on public.ai_conversations
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- 2. Повідомлення
alter table public.ai_messages add column if not exists translation_ua text;
alter table public.ai_messages add column if not exists correction     jsonb;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'ai_messages_role_check') then
    alter table public.ai_messages add constraint ai_messages_role_check
      check (role in ('user', 'assistant', 'system')) not valid;
  end if;
  if not exists (select 1 from pg_constraint where conname = 'ai_messages_correction_check') then
    alter table public.ai_messages add constraint ai_messages_correction_check
      check (correction is null or jsonb_typeof(correction) = 'object');
  end if;
  if not exists (select 1 from pg_constraint where conname = 'ai_messages_content_length_check') then
    alter table public.ai_messages add constraint ai_messages_content_length_check
      check (length(content) <= 2000) not valid;
  end if;
end $$;

create index if not exists idx_ai_messages_conversation on public.ai_messages (conversation_id, created_at);

revoke update, delete, truncate on public.ai_messages from anon, authenticated;

drop policy if exists "Admins can view all ai_messages" on public.ai_messages;
create policy "Admins can view all ai_messages" on public.ai_messages
  for select to authenticated using ((select public.is_admin()));
drop policy if exists "Admins can view all ai_conversations" on public.ai_conversations;
create policy "Admins can view all ai_conversations" on public.ai_conversations
  for select to authenticated using ((select public.is_admin()));

-- 3. Помилки користувача для повторення (§19, §115)
create table if not exists public.user_errors (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null default auth.uid() references auth.users(id) on delete cascade,
  source           text not null check (source in ('roleplay', 'speaking', 'writing', 'exercise')),
  conversation_id  uuid references public.ai_conversations(id) on delete set null,
  situation        text check (situation is null or situation ~ '^[a-z][a-z_]{1,39}$'),
  original_text    text not null check (length(original_text) between 1 and 300),
  corrected_text   text not null check (length(corrected_text) between 1 and 300),
  explanation_ua   text check (explanation_ua is null or length(explanation_ua) <= 300),
  error_type       text not null default 'other'
                     check (error_type in ('grammar', 'vocabulary', 'word_order', 'spelling', 'register', 'pronunciation', 'other')),
  resolved_at      timestamptz,
  created_at       timestamptz not null default now()
);

create index if not exists idx_user_errors_user on public.user_errors (user_id, created_at desc);

alter table public.user_errors enable row level security;

drop policy if exists "Users can insert own errors" on public.user_errors;
create policy "Users can insert own errors" on public.user_errors
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and (conversation_id is null or exists (
      select 1 from public.ai_conversations c
      where c.id = user_errors.conversation_id and c.user_id = (select auth.uid())))
  );
drop policy if exists "Users can view own errors" on public.user_errors;
create policy "Users can view own errors" on public.user_errors
  for select to authenticated using (user_id = (select auth.uid()));
-- Позначити помилку засвоєною (resolved_at) — лише свою
drop policy if exists "Users can update own errors" on public.user_errors;
create policy "Users can update own errors" on public.user_errors
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
drop policy if exists "Admins can view all errors" on public.user_errors;
create policy "Admins can view all errors" on public.user_errors
  for select to authenticated using ((select public.is_admin()));

revoke delete, truncate on public.user_errors from anon, authenticated;
