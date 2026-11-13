-- =====================================================================
-- M24 · Маркування живої лексики: register / regionality / usage_tags + стандартний відповідник · 2026-11-13
-- Модель — docs/LEARNING_SPEC.md §18 (рішення власника 2026-11-12, уточнення затверджено 2026-11-13,
-- тег offensive — 2026-11-13); план переходу — docs/proposals/2026-11-12_b1_b2_dialogues_reading_situations.md §4.3, крок 1.
-- Адитивна, ідемпотентна. Наявні дані не змінює й не видаляє.
--
--   * lexemes.usage_tags text[] — додаткові ознаки ('{}' — ознак немає); lexemes.standard_lexeme_id — стандартний
--     відповідник (інша лексема; on delete set null; не сама на себе).
--   * phrases: register, regionality, usage_tags — ті самі переліки, що в lexemes.
--   * CHECK переліків. Порожнє (null) поки дозволено й означає «ще не розмічено» (крок 2 — розмітка всіх слів
--     і речень; крок 3 — VALIDATE і NOT NULL без default).
--   * lexemes_register_check — NOT VALID: у базі ще 4 старі значення (regional ×3, non_standard ×1), їх нормалізує
--     пакет кроку 2; нові й змінені рядки перевіряються вже зараз. Решта CHECK — звичайні: наявні значення
--     (regionality — лише Dalmatia / Zagreb, нові колонки — порожні) їм відповідають.
-- Нових таблиць немає (RLS — як і раніше: читати лише PUBLISHED).
-- =====================================================================

-- ---------------------------------------------------------------- 1. lexemes: нові колонки
alter table public.lexemes add column if not exists usage_tags text[];
alter table public.lexemes add column if not exists standard_lexeme_id uuid;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'lexemes_standard_lexeme_id_fkey'
                   and conrelid = 'public.lexemes'::regclass) then
    alter table public.lexemes add constraint lexemes_standard_lexeme_id_fkey
      foreign key (standard_lexeme_id) references public.lexemes (id) on delete set null;
  end if;
end $$;

create index if not exists idx_lexemes_standard_lexeme on public.lexemes (standard_lexeme_id)
  where standard_lexeme_id is not null;

-- ---------------------------------------------------------------- 2. lexemes: переліки
alter table public.lexemes drop constraint if exists lexemes_register_check;
alter table public.lexemes add constraint lexemes_register_check
  check (register is null or register = any (array['standard', 'formal', 'informal', 'colloquial', 'slang', 'vulgar']))
  not valid;

alter table public.lexemes drop constraint if exists lexemes_regionality_check;
alter table public.lexemes add constraint lexemes_regionality_check
  check (regionality is null or regionality = any (array['general', 'Zagreb', 'Zagorje', 'Dalmatia', 'Istria', 'Kvarner',
                                                         'Slavonia', 'Lika', 'Dubrovnik']));

alter table public.lexemes drop constraint if exists lexemes_usage_tags_check;
alter table public.lexemes add constraint lexemes_usage_tags_check
  check (usage_tags is null
         or (array_position(usage_tags, null) is null
             and usage_tags <@ array['youth_slang', 'internet_slang', 'professional_jargon', 'anglicism', 'italianism',
                                     'germanism', 'turkism', 'idiom', 'kajkavian', 'chakavian', 'offensive']::text[]));

alter table public.lexemes drop constraint if exists lexemes_standard_not_self_check;
alter table public.lexemes add constraint lexemes_standard_not_self_check
  check (standard_lexeme_id is null or standard_lexeme_id <> id);

-- ---------------------------------------------------------------- 3. phrases: ті самі мітки
alter table public.phrases add column if not exists register text;
alter table public.phrases add column if not exists regionality text;
alter table public.phrases add column if not exists usage_tags text[];

alter table public.phrases drop constraint if exists phrases_register_check;
alter table public.phrases add constraint phrases_register_check
  check (register is null or register = any (array['standard', 'formal', 'informal', 'colloquial', 'slang', 'vulgar']));

alter table public.phrases drop constraint if exists phrases_regionality_check;
alter table public.phrases add constraint phrases_regionality_check
  check (regionality is null or regionality = any (array['general', 'Zagreb', 'Zagorje', 'Dalmatia', 'Istria', 'Kvarner',
                                                         'Slavonia', 'Lika', 'Dubrovnik']));

alter table public.phrases drop constraint if exists phrases_usage_tags_check;
alter table public.phrases add constraint phrases_usage_tags_check
  check (usage_tags is null
         or (array_position(usage_tags, null) is null
             and usage_tags <@ array['youth_slang', 'internet_slang', 'professional_jargon', 'anglicism', 'italianism',
                                     'germanism', 'turkism', 'idiom', 'kajkavian', 'chakavian', 'offensive']::text[]));

-- ---------------------------------------------------------------- 4. Опис колонок
comment on column public.lexemes.register is
  'Як уживають (LEARNING_SPEC §18): standard | formal | informal | colloquial | slang | vulgar. '
  'null — ще не розмічено (до кроку 3 плану маркування, потім NOT NULL).';
comment on column public.lexemes.regionality is
  'Де уживають: general | Zagreb | Zagorje | Dalmatia | Istria | Kvarner | Slavonia | Lika | Dubrovnik. null — ще не розмічено.';
comment on column public.lexemes.usage_tags is
  'Додаткові ознаки: youth_slang, internet_slang, professional_jargon, anglicism, italianism, germanism, turkism, idiom, '
  'kajkavian, chakavian, offensive; ''{}'' — ознак немає; null — ще не розмічено.';
comment on column public.lexemes.standard_lexeme_id is
  'Стандартний відповідник — інша лексема (kužiti → razumjeti); null — відповідника немає або не вказано.';
comment on column public.phrases.register is 'Як lexemes.register (LEARNING_SPEC §18).';
comment on column public.phrases.regionality is 'Як lexemes.regionality.';
comment on column public.phrases.usage_tags is 'Як lexemes.usage_tags.';
