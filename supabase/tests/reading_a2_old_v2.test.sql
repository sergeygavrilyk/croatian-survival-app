-- =====================================================================
-- Тести пакета 20261115_reading_a2_old_v2.sql: 20 старих текстів A2 під програму A2 v2.
-- Запускати ПІСЛЯ пакетів читання A2 (20261015_reading_a2_v1_*, 20261113_reading_a2_v2_*) і 20261115_reading_a2_old_v2.sql.
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK. Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

create temp view a2_texts as select * from public.reading_texts where cefr = 'A2' and status = 'PUBLISHED';
create temp view a2_rewritten as
  select * from a2_texts where code in ('RD-A2-007', 'RD-A2-008', 'RD-A2-010', 'RD-A2-013', 'RD-A2-018', 'RD-A2-019');

select pg_temp.ok((select count(*) from a2_texts) = 56, 'A2: 56 опублікованих текстів');
select pg_temp.ok((select count(*) from a2_texts where known_ratio < 0.9 or known_ratio is null) = 0,
  'A2: у кожному тексті ≥ 90 % знайомих слів (уроки A0–A1 і A2 до модуля тексту)');
select pg_temp.ok((select count(*) from (select module_order from a2_texts group by module_order having count(*) = 4) m) = 14,
  'A2: по 4 тексти в кожному з 14 модулів');
select pg_temp.ok((select count(*) from a2_rewritten) = 6, 'A2: 6 переписаних текстів на місці (той самий код)');
select pg_temp.ok((select count(*) from a2_rewritten r
                   where r.body_hr like 'Želite otvoriti tekući račun%' or r.body_hr like '%urudžbeni broj predmeta%'
                      or r.body_hr like '%izabranog liječnika%' or r.body_hr like '%vodoinstalatera%'
                      or r.body_hr like '%čini mi se da%' or r.body_hr like '%Prema najavi%') = 6,
  'A2: 6 текстів — нова редакція (слова уроків A2)');
select pg_temp.ok((select count(*) from a2_rewritten
                   where jsonb_array_length(questions) <> 3 or word_count not between 60 and 140
                      or body_ua !~ '[а-яіїєґ]' or body_hr ~ '[а-яіїєґА-ЯІЇЄҐ]') = 0,
  'A2: у переписаних текстах 3 питання, 60–140 слів, переклад українською, хорватське латиницею');
select pg_temp.ok((select count(*) from a2_rewritten r, jsonb_array_elements(r.glossary) e
                   where coalesce(e->>'ua', '') = '' or e->>'pos' is null
                      or (e->>'gram' is null and e->>'form' <> lower(e->>'lemma'))) = 0,
  'A2: словничок переписаних текстів — переклад, частина мови, граматика форми');
select pg_temp.ok((select count(*) from public.content_versions v join a2_rewritten r on r.id = v.entity_id
                   where v.entity_type = 'reading_text' and v.change_reason like 'reading_a2_old_v2%') = 6,
  'A2: стара редакція 6 текстів — у content_versions');
select pg_temp.ok((select count(*) from a2_texts t, jsonb_array_elements(t.glossary) e
                   where t.code between 'RD-A2-001' and 'RD-A2-020' and e->>'lemma' = 'dokaz' and (e->>'lesson')::boolean) = 0,
  'A2: позначка «з уроків» — за поточними уроками (dokaz більше не в уроках)');
select pg_temp.ok((select count(*) from a2_texts t, jsonb_array_elements(t.glossary) e
                   where t.code = 'RD-A2-009' and e->>'lemma' = 'prehladiti se' and (e->>'lesson')::boolean) = 1,
  'A2: слово уроків A2 (prehladiti se) у старому тексті — «з уроків»');

select 'ALL TESTS PASSED' as result;
rollback;
