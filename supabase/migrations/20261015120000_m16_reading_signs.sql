-- =====================================================================
-- M16 · Читання: вид тексту «sign» (вивіски й написи A0) · 2026-10-15
-- Адитивна, ідемпотентна: до переліку видів тексту додається 'sign'; наявні тексти не змінюються.
-- Потрібна M15 (reading_texts).
-- =====================================================================

do $$
begin
  if to_regclass('public.reading_texts') is null then
    raise exception 'Спершу запустіть міграцію M15 (20261014100000_m15_reading.sql)';
  end if;
end $$;

alter table public.reading_texts drop constraint if exists reading_texts_text_type_check;
alter table public.reading_texts add constraint reading_texts_text_type_check check (text_type in (
  'message', 'chat', 'email', 'notice', 'ad', 'menu', 'instruction',
  'form', 'story', 'article', 'news', 'dialogue', 'sign'));

comment on column public.reading_texts.text_type is
  'Вид тексту: message, chat, email, notice, ad, menu, instruction, form, story, article, news, dialogue, sign (вивіски A0: кожен рядок — окрема табличка)';
