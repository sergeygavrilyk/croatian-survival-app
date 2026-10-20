-- =====================================================================
-- Тести M16 + тексти для читання A0 (вивіски) і A2 (reading_a0_v1, reading_a2_v1) · 2026-10-15
-- Запускати ПІСЛЯ M16, 20261015_reading_a0_v1.sql і обох частин 20261015_reading_a2_v1_part*.sql.
-- Проходить і до, і після публікації A2 (20261015_reading_a2_publish.sql).
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
-- Запуск: Supabase → SQL Editor → вставити файл → Run. Успіх: «ALL TESTS PASSED».
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

create or replace function pg_temp.raises(q text) returns boolean language plpgsql as $$
begin
  execute q;
  return false;
exception when others then
  return true;
end $$;

-- ---------------------------------------------------------------- M16
select pg_temp.ok((select pg_get_constraintdef(oid) from pg_constraint where conname = 'reading_texts_text_type_check') like '%''sign''%',
  'M16: вид тексту «sign» дозволено');
select pg_temp.ok(pg_temp.raises($q$insert into public.reading_texts (code, cefr, text_type, title_ua, title_hr, body_hr, body_ua)
  values ('RD-A0-999', 'A0', 'poster', 'Тест', 'Test', 'Ovo je test tekst za provjeru.', 'Це тестовий текст для перевірки.')$q$),
  'M16: невідомий вид тексту й далі заборонено');

-- ---------------------------------------------------------------- A0: вивіски
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where source = 'claude_reading_a0_v1' and cefr = 'A0' and status = 'PUBLISHED'$q$) = 20,
  'A0: 20 опублікованих текстів (вивіски, цінники, розклади, записки)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where source = 'claude_reading_a0_v1' and text_type = 'sign'$q$) >= 15,
  'A0: щонайменше 15 наборів вивісок (вид «sign»)');
select pg_temp.ok(pg_temp.n($q$select distinct module_order from public.reading_texts where source = 'claude_reading_a0_v1'$q$) = 10,
  'A0: тексти є для кожного з 10 модулів A0');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where source = 'claude_reading_a0_v1'
  and (code !~ '^RD-A0-[0-9]{3}$' or word_count not between 6 and 40
       or known_ratio < 0.4)$q$) = 0,
  'A0: коди RD-A0-NNN, 6–40 слів, ≥ 40 % слів з уроків A0');

-- ---------------------------------------------------------------- A2
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where source = 'claude_reading_a2_v1' and cefr = 'A2'$q$) = 20,
  'A2: 20 текстів');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where source = 'claude_reading_a2_v1' and status not in ('DRAFT', 'PUBLISHED')$q$) = 0,
  'A2: статус DRAFT (до рішення власника) або PUBLISHED (після 20261015_reading_a2_publish.sql)');
select pg_temp.ok(pg_temp.n($q$select distinct module_order from public.reading_texts where source = 'claude_reading_a2_v1'$q$) = 10,
  'A2: тексти є для кожної з 10 тем A2');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where source = 'claude_reading_a2_v1'
  and (code !~ '^RD-A2-[0-9]{3}$' or word_count not between 60 and 200 or known_ratio < 0.7 or text_type = 'sign')$q$) = 0,
  'A2: коди RD-A2-NNN, 60–200 слів, ≥ 70 % слів з уроків A0–A1, без вивісок');
select pg_temp.ok(pg_temp.n($q$select distinct text_type from public.reading_texts where source = 'claude_reading_a2_v1'$q$) >= 7,
  'A2: щонайменше 7 видів текстів (історія, чат, лист, інструкція, стаття, новини, діалог, оголошення)');

-- ---------------------------------------------------------------- обидва рівні: питання, словничок, граматика
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r
  where r.source in ('claude_reading_a0_v1', 'claude_reading_a2_v1')
    and (jsonb_array_length(r.questions) <> 3 or body_ua !~ '[Ѐ-ӿ]' or body_hr ~ '[Ѐ-ӿ]')$q$) = 0,
  '3 питання, хорватський текст латиницею, переклад українською');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r, jsonb_array_elements(r.questions) q
  where r.source in ('claude_reading_a0_v1', 'claude_reading_a2_v1')
    and (not (q->'options') ? (q->>'answer') or jsonb_array_length(q->'options') <> 3)$q$) = 0,
  'у кожному питанні 3 варіанти, правильна відповідь серед них');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r, jsonb_array_elements(r.glossary) g
  where r.source in ('claude_reading_a0_v1', 'claude_reading_a2_v1')
    and (coalesce(g->>'form', '') = '' or coalesce(g->>'lemma', '') = '' or coalesce(g->>'ua', '') !~ '[А-Яа-яІіЇїЄєҐґ]'
         or lower(g->>'ua') in ('переклад', 'translation', 'todo'))$q$) = 0,
  'словничок: форма, лема й справжній переклад українською (без заглушок)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r, jsonb_array_elements(r.glossary) g
  where r.source in ('claude_reading_a0_v1', 'claude_reading_a2_v1')
    and (coalesce(g->>'pos', '') !~ '[А-Яа-яІіЇїЄєҐґ]'
         or g->>'form' <> lower(g->>'lemma') and coalesce(g->>'gram', '') !~ '[А-Яа-яІіЇїЄєҐґ]')$q$) = 0,
  'граматика (§56): у кожного слова — частина мови, у кожної зміненої форми — підказка');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r
  where r.source in ('claude_reading_a0_v1', 'claude_reading_a2_v1')
    and not exists (select 1 from public.content_reviews c where c.entity_type = 'reading_text' and c.entity_id = r.id)$q$) = 0,
  'журнал перевірки має запис для кожного тексту A0 і A2');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r
  where r.source = 'claude_reading_a2_v1' and r.status = 'PUBLISHED'
    and not exists (select 1 from public.content_reviews c where c.entity_id = r.id and c.to_status = 'PUBLISHED' and c.reviewer_kind = 'human')$q$) = 0,
  'опублікований текст A2 має запис рішення власника в журналі');

-- ---------------------------------------------------------------- видимість: гість бачить лише опубліковане
set local role anon;
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where source = 'claude_reading_a0_v1'$q$) = 20,
  'гість бачить усі 20 текстів A0');
reset role;
-- скільки A2 опубліковано (без тимчасових таблиць: SQL Editor їх не тримає) — у налаштуванні транзакції
select set_config('rd.a2_published',
  (select count(*)::text from public.reading_texts where source = 'claude_reading_a2_v1' and status = 'PUBLISHED'), true);
set local role anon;
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where source = 'claude_reading_a2_v1'$q$)
  = current_setting('rd.a2_published')::bigint, 'гість бачить лише опубліковані тексти A2 (чернетки — ні)');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
