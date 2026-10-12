-- =====================================================================
-- M4 · Аналітика подій (§71–73, §125 ТЗ) · 2026-10-12
-- Append-only журнал подій навчання. Адитивна, ідемпотентна.
-- Облік витрат на AI (ai_usage_events, §74) — окремою міграцією, коли з'явиться AI-рантайм.
-- =====================================================================

create table if not exists public.analytics_events (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade,   -- §97: дані видаляються разом з користувачем
  session_id   uuid,
  event_name   text not null check (event_name ~ '^[a-z][a-z0-9_]{2,63}$'),
  -- Поширені властивості §72 — окремими колонками для швидких метрик.
  -- Без FK: журнал не повинен ламатися, якщо контент видалили.
  lesson_id    uuid,
  lexeme_id    uuid,
  level        text check (level is null or level in ('A0', 'A1', 'A2', 'B1', 'B2')),
  success      boolean,
  duration_ms  integer check (duration_ms is null or duration_ms >= 0),
  device       text,
  app_version  text,
  properties   jsonb not null default '{}'::jsonb check (jsonb_typeof(properties) = 'object'),
  occurred_at  timestamptz not null default now(),   -- час події на клієнті/сервері застосунку
  created_at   timestamptz not null default now()    -- час запису в БД
);

create index if not exists idx_analytics_events_user_time  on public.analytics_events (user_id, occurred_at);
create index if not exists idx_analytics_events_name_time  on public.analytics_events (event_name, occurred_at);
create index if not exists idx_analytics_events_session    on public.analytics_events (session_id) where session_id is not null;

alter table public.analytics_events enable row level security;

-- Користувач може лише додавати свої події і читати їх. Оновлювати й видаляти — ніхто (append-only).
drop policy if exists "Users can insert own analytics events" on public.analytics_events;
drop policy if exists "Users can view own analytics events"   on public.analytics_events;

create policy "Users can insert own analytics events" on public.analytics_events
  for insert with check (auth.uid() = user_id);
create policy "Users can view own analytics events" on public.analytics_events
  for select using (auth.uid() = user_id);

revoke update, delete, truncate on public.analytics_events from anon, authenticated;
