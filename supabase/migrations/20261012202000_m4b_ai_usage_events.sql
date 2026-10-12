-- =====================================================================
-- M4b · Облік викликів AI і мовлення (§74, §122, §126 ТЗ) · 2026-10-12
-- Адитивна, ідемпотентна. Потребує M3 (is_admin()).
--
-- Кожен виклик AI / TTS / STT записує одну подію: функція, провайдер, модель,
-- токени чи символи, затримка, успіх. Вартість (cost_usd) — коли відома.
-- Журнал append-only: користувач додає й читає лише свої події, адмін читає всі.
-- =====================================================================

create table if not exists public.ai_usage_events (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid references auth.users(id) on delete set null default auth.uid(),
  occurred_at    timestamptz not null default now(),
  feature        text not null check (feature in (
                   'quick_translate', 'what_do_i_say', 'what_did_i_hear', 'chat', 'roleplay',
                   'tts', 'stt', 'pronunciation', 'content_generation', 'other')),
  provider       text not null check (provider ~ '^[a-z0-9_.-]{2,40}$'),
  model          text check (model is null or length(model) <= 80),
  input_tokens   integer check (input_tokens is null or input_tokens >= 0),
  output_tokens  integer check (output_tokens is null or output_tokens >= 0),
  characters     integer check (characters is null or characters >= 0),
  audio_ms       integer check (audio_ms is null or audio_ms >= 0),
  latency_ms     integer check (latency_ms is null or latency_ms >= 0),
  cost_usd       numeric(12, 6) check (cost_usd is null or cost_usd >= 0),
  success        boolean not null default true,
  error_code     text check (error_code is null or length(error_code) <= 80),
  properties     jsonb not null default '{}'::jsonb
                   check (jsonb_typeof(properties) = 'object' and pg_column_size(properties) <= 4096)
);

create index if not exists idx_ai_usage_occurred on public.ai_usage_events (occurred_at desc);
create index if not exists idx_ai_usage_user on public.ai_usage_events (user_id, occurred_at desc);
create index if not exists idx_ai_usage_feature on public.ai_usage_events (feature, occurred_at desc);

alter table public.ai_usage_events enable row level security;

drop policy if exists "Users can insert own ai usage" on public.ai_usage_events;
create policy "Users can insert own ai usage" on public.ai_usage_events
  for insert to authenticated with check (user_id = (select auth.uid()));

drop policy if exists "Users can view own ai usage" on public.ai_usage_events;
create policy "Users can view own ai usage" on public.ai_usage_events
  for select to authenticated using (user_id = (select auth.uid()));

drop policy if exists "Admins can view all ai usage" on public.ai_usage_events;
create policy "Admins can view all ai usage" on public.ai_usage_events
  for select to authenticated using ((select public.is_admin()));

revoke update, delete, truncate on public.ai_usage_events from anon, authenticated;
