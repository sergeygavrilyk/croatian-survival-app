-- =====================================================================
-- M25 · «Замок» маркування: мітки слів і речень обов'язкові (VALIDATE + NOT NULL, без default) · 2026-11-13
-- Рішення власника 2026-11-13: «Даю Ок на кінцевий стан: усі поля обов'язкові й без значення за замовчуванням,
-- окремої колонки з варіанта Г немає. Варіант В — лише на час переходу». План — docs/proposals/
-- 2026-11-12_b1_b2_dialogues_reading_situations.md §4.3, крок 3. Модель — docs/LEARNING_SPEC.md §18.
--
-- ПОТРІБНО спершу: пакет даних supabase/data_fixes/20261113_lexeme_labels.sql (PR #26) — уже запущений у базі.
-- «Apply SQL» запускає migrations/ раніше за data_fixes/, тож цей PR мерджити лише ПІСЛЯ Approve PR #26.
-- Якщо порожні мітки ще є — міграція зупиняється з поясненням і нічого не змінює.
--
--   * lexemes_register_check — VALIDATE (тепер перевіряє всі рядки, не лише нові й змінені).
--   * lexemes.register / regionality / usage_tags і phrases.register / regionality / usage_tags — NOT NULL, без default:
--     вставка слова чи речення без трьох міток не пройде (звичайне слово — standard / general / '{}').
-- Ідемпотентна (повторний запуск нічого не змінює). Даних не змінює. Нових таблиць немає.
-- =====================================================================

do $$
declare
  n_lex int;
  n_phr int;
  n_old int;
begin
  select count(*) into n_lex from public.lexemes where register is null or regionality is null or usage_tags is null;
  select count(*) into n_phr from public.phrases where register is null or regionality is null or usage_tags is null;
  select count(*) into n_old from public.lexemes where register in ('regional', 'non_standard');
  if n_lex + n_phr + n_old > 0 then
    raise exception 'M25: спершу пакет data_fixes/20261113_lexeme_labels.sql (PR #26) — без міток слів %, речень %, старих значень register %',
      n_lex, n_phr, n_old;
  end if;
end $$;

alter table public.lexemes validate constraint lexemes_register_check;

alter table public.lexemes alter column register drop default;
alter table public.lexemes alter column regionality drop default;
alter table public.lexemes alter column usage_tags drop default;
alter table public.lexemes alter column register set not null;
alter table public.lexemes alter column regionality set not null;
alter table public.lexemes alter column usage_tags set not null;

alter table public.phrases alter column register drop default;
alter table public.phrases alter column regionality drop default;
alter table public.phrases alter column usage_tags drop default;
alter table public.phrases alter column register set not null;
alter table public.phrases alter column regionality set not null;
alter table public.phrases alter column usage_tags set not null;

comment on column public.lexemes.register is
  'Як уживають (LEARNING_SPEC §18): standard | formal | informal | colloquial | slang | vulgar. Обов''язкове (M25), без default.';
comment on column public.lexemes.regionality is
  'Де уживають: general | Zagreb | Zagorje | Dalmatia | Istria | Kvarner | Slavonia | Lika | Dubrovnik. Обов''язкове (M25).';
comment on column public.lexemes.usage_tags is
  'Додаткові ознаки: youth_slang, internet_slang, professional_jargon, anglicism, italianism, germanism, turkism, idiom, '
  'kajkavian, chakavian, offensive; ''{}'' — ознак немає. Обов''язкове (M25).';
comment on column public.phrases.register is 'Як lexemes.register (LEARNING_SPEC §18). Обов''язкове (M25).';
comment on column public.phrases.regionality is 'Як lexemes.regionality. Обов''язкове (M25).';
comment on column public.phrases.usage_tags is 'Як lexemes.usage_tags. Обов''язкове (M25).';
