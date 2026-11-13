-- =====================================================================
-- Тести: 36 нових текстів для читання A2 і 56 фраз A2 (програма A2 v2) · 2026-11-13
-- Запускати ПІСЛЯ 20261113_reading_a2_v2_part1…3.sql і 20261113_phrases_a2_v2.sql
-- (і після пакетів A2 v2: 20261112_curriculum_a2_v2_*.sql розкладає 20 наявних текстів по нових модулях).
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK. Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

create or replace function pg_temp.n(q text) returns bigint language plpgsql as $$
declare r bigint;
begin
  execute 'select count(*) from (' || q || ') s' into r;
  return r;
end $$;

-- ---------------------------------------------------------------- тексти
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where source = 'claude_reading_a2_v2'
  and cefr = 'A2' and status = 'PUBLISHED' and published_at is not null$q$) = 36,
  'A2 v2: 36 нових опублікованих текстів');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where source = 'claude_reading_a2_v2'
  and code ~ '^RD-A2-0(2[1-9]|[34][0-9]|5[0-6])$' and order_index = substr(code, 7)::int$q$) = 36,
  'коди RD-A2-021…056, порядок = номер коду');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where source = 'claude_reading_a2_v1' and cefr = 'A2'$q$) = 20,
  '20 наявних текстів A2 на місці (пакет їх не чіпає)');
select pg_temp.ok(pg_temp.n($q$select m.n from generate_series(1, 14) m(n)
  left join public.reading_texts r on r.cefr = 'A2' and r.status = 'PUBLISHED' and r.module_order = m.n
  group by m.n having count(r.id) = 4$q$) = 14,
  'у кожному з 14 модулів A2 — рівно 4 тексти (56 разом)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where source = 'claude_reading_a2_v2'
  and module_order in (2, 8, 11, 12)$q$) = 16,
  'модулі A2.2, A2.8, A2.11, A2.12 (текстів не було) — по 4 нові тексти');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where source = 'claude_reading_a2_v2'
  and (known_ratio < 0.9 or word_count not between 60 and 140)$q$) = 0,
  'знайомих слів ≥ 90 %, довжина 60–140 слів');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where source = 'claude_reading_a2_v2'
  and (body_hr ~ '[А-Яа-яІіЇїЄєҐґ]' or body_ua !~ '[А-Яа-яІіЇїЄєҐґ]' or title_hr ~ '[А-Яа-яІіЇїЄєҐґ]' or title_ua !~ '[А-Яа-яІіЇїЄєҐґ]')$q$) = 0,
  'хорватський текст без кирилиці, переклад і назва — українською');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r where source = 'claude_reading_a2_v2'
  and (jsonb_array_length(r.questions) <> 3
       or exists (select 1 from jsonb_array_elements(r.questions) qq
                  where jsonb_array_length(qq->'options') <> 3 or not (qq->'options') ? (qq->>'answer')))$q$) = 0,
  '3 питання на текст, у кожного 3 варіанти й правильна відповідь серед них');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r, jsonb_array_elements(r.glossary) e
  where r.source = 'claude_reading_a2_v2'
    and (coalesce(e->>'ua', '') !~ '[А-Яа-яІіЇїЄєҐґ]' or e->>'pos' is null
         or (e->>'gram' is null and e->>'form' <> lower(e->>'lemma')))$q$) = 0,
  'словничок: переклад, частина мови, граматика для кожної зміненої форми');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r where source = 'claude_reading_a2_v2'
  and jsonb_array_length(r.glossary) < 30$q$) = 0,
  'словничок не порожній (≥ 30 форм на текст)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r where source = 'claude_reading_a2_v2'
  and situation is not null and situation not in ('basics', 'shopping', 'cafe_restaurant', 'transport', 'car_service',
    'housing', 'health', 'vet', 'administration', 'bank', 'border', 'work', 'it_work', 'travel', 'small_talk')$q$) = 0,
  'ситуація тексту — код з lib/situations.ts');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r where source = 'claude_reading_a2_v2'
  and not exists (select 1 from public.content_reviews c where c.entity_type = 'reading_text' and c.entity_id = r.id)$q$) = 0,
  'журнал перевірки (content_reviews) — для кожного нового тексту');

-- ---------------------------------------------------------------- фрази
select pg_temp.ok(pg_temp.n($q$select 1 from public.phrases where source = 'claude_phrases_a2_v2'
  and cefr = 'A2' and status = 'PUBLISHED' and published_at is not null$q$) = 56,
  'фрази A2: 56 опублікованих');
select pg_temp.ok(pg_temp.n($q$select 1 from public.phrases where source = 'claude_phrases_a2_v2'
  and situation not in ('basics', 'shopping', 'cafe_restaurant', 'transport', 'car_service', 'housing', 'health', 'vet',
    'administration', 'bank', 'border', 'work', 'it_work', 'travel', 'small_talk')$q$) = 0,
  'ситуація фрази — код з lib/situations.ts');
select pg_temp.ok(pg_temp.n($q$select 1 from public.phrases where source = 'claude_phrases_a2_v2'
  and (register is null or regionality is null or usage_tags is null
       or register not in ('standard', 'formal', 'informal', 'colloquial', 'slang', 'vulgar') or regionality <> 'general')$q$) = 0,
  'мітки фраз: register з переліку, regionality = general, usage_tags заповнено');
select pg_temp.ok(pg_temp.n($q$select 1 from public.phrases where source = 'claude_phrases_a2_v2'
  and (phrase_type = 'question') <> (text_hr like '%?')$q$) = 0,
  'тип фрази: question — лише для питань');
select pg_temp.ok(pg_temp.n($q$select 1 from public.phrases where source = 'claude_phrases_a2_v2'
  and (text_hr ~ '[А-Яа-яІіЇїЄєҐґ]' or ukrainian_translation !~ '[А-Яа-яІіЇїЄєҐґ]'
       or normalized ~ '[čćđšžČĆĐŠŽA-Z]')$q$) = 0,
  'фраза без кирилиці, переклад українською, normalized — малими й без діакритики');
select pg_temp.ok(pg_temp.n($q$select lower(text_hr) from public.phrases group by 1 having count(*) > 1$q$) = 0,
  'фрази не повторюються');
select pg_temp.ok(pg_temp.n($q$select 1 from public.phrases p where source = 'claude_phrases_a2_v2'
  and not exists (select 1 from public.content_reviews c where c.entity_type = 'phrase' and c.entity_id = p.id)$q$) = 0,
  'журнал перевірки (content_reviews) — для кожної нової фрази');
select pg_temp.ok(pg_temp.n($q$select distinct situation from public.phrases where source = 'claude_phrases_a2_v2'$q$) >= 8,
  'фрази A2 покривають щонайменше 8 ситуацій');

select 'ALL TESTS PASSED' as result;
rollback;
