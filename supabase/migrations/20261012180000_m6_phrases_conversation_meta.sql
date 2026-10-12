-- =====================================================================
-- M6 · Фрази (§118 ТЗ) і метадані діалогів · 2026-10-12
-- Адитивна, ідемпотентна.
--   * public.phrases — корисні фрази й речення («Gdje je blagajna?»), які не є лексемами.
--   * conversations — рівень, ситуація, статус: діалоги можуть існувати без уроку
--     (бібліотека ситуацій для рольових ігор і майбутніх уроків).
-- =====================================================================

-- 1. Фрази
create table if not exists public.phrases (
  id                     uuid primary key default gen_random_uuid(),
  text_hr                text not null,
  normalized             text not null,
  ukrainian_translation  text not null,
  cefr                   text check (cefr is null or cefr in ('A0', 'A1', 'A2', 'B1', 'B2')),
  situation              text,                  -- shopping, cafe_restaurant, transport, housing, health, …
  phrase_type            text not null default 'phrase'
                           check (phrase_type in ('phrase', 'question', 'filler', 'chunk')),
  examples               jsonb not null default '[]'::jsonb check (jsonb_typeof(examples) = 'array'),
  audio_url              text,
  status                 text not null default 'DRAFT'
                           check (status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED', 'PUBLISHED', 'DEPRECATED')),
  version                integer not null default 1,
  source                 text,                  -- звідки фраза (напр. migrated_from_lexemes)
  source_lexeme_id       uuid,                  -- для простежуваності, без FK
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);

create unique index if not exists phrases_lower_text_key on public.phrases (lower(text_hr));
create index if not exists idx_phrases_situation on public.phrases (situation, cefr);

alter table public.phrases enable row level security;
-- Читати можна лише опубліковані фрази. Писати — лише власник БД / сервер (політик на запис немає).
drop policy if exists "Read published phrases" on public.phrases;
create policy "Read published phrases" on public.phrases for select using (status = 'PUBLISHED');

-- 2. Метадані діалогів
alter table public.conversations add column if not exists level      text;
alter table public.conversations add column if not exists situation  text;
alter table public.conversations add column if not exists status     text not null default 'PUBLISHED';
alter table public.conversations add column if not exists source     text;
alter table public.conversations add column if not exists updated_at timestamptz not null default now();

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'conversations_level_check') then
    alter table public.conversations add constraint conversations_level_check
      check (level is null or level in ('A0', 'A1', 'A2', 'B1', 'B2'));
  end if;
  if not exists (select 1 from pg_constraint where conname = 'conversations_status_check') then
    alter table public.conversations add constraint conversations_status_check
      check (status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED', 'PUBLISHED', 'DEPRECATED'));
  end if;
end $$;

create index if not exists idx_conversations_situation on public.conversations (situation, level);
