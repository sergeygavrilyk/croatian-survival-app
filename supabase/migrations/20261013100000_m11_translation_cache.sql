-- =====================================================================
-- M11 · Збережені переклади «Мені потрібно сказати…» · 2026-10-13
-- Адитивна, ідемпотентна.
--
--   * Ту саму фразу користувач не перекладає через AI вдруге: береться збережений
--     переклад (швидше, дешевше, працює, коли AI перевантажений).
--   * Кеш ОСОБИСТИЙ: кожен бачить і змінює лише свої переклади. Спільний кеш дозволив би
--     одному користувачу підмінити переклад для всіх — тому ні.
--   * Ключ — нормалізований текст (lib/phrase-match.ts → cacheKey), до 300 символів.
-- =====================================================================

create table if not exists public.translation_cache (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  source_norm     text not null check (length(source_norm) between 1 and 300),
  source_text     text not null check (length(source_text) between 1 and 300),
  translation_hr  text not null check (length(translation_hr) between 1 and 500),
  model           text check (model is null or length(model) <= 80),
  hits            integer not null default 0 check (hits >= 0),
  created_at      timestamptz not null default now(),
  last_used_at    timestamptz not null default now(),
  unique (user_id, source_norm)
);

create index if not exists idx_translation_cache_user_used on public.translation_cache (user_id, last_used_at desc);

alter table public.translation_cache enable row level security;

drop policy if exists "Users can view own translations" on public.translation_cache;
drop policy if exists "Users can insert own translations" on public.translation_cache;
drop policy if exists "Users can update own translations" on public.translation_cache;
drop policy if exists "Users can delete own translations" on public.translation_cache;

create policy "Users can view own translations" on public.translation_cache
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "Users can insert own translations" on public.translation_cache
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "Users can update own translations" on public.translation_cache
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Users can delete own translations" on public.translation_cache
  for delete to authenticated using ((select auth.uid()) = user_id);

revoke all on public.translation_cache from anon;
