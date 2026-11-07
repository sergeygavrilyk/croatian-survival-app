-- =====================================================================
-- Тести: тексти для читання A1 після аудиту A0 / A1 (задача 2) · 2026-11-04
-- Запускати ПІСЛЯ 20261104_reading_a1_v3_new.sql, 20261104_reading_a1_rewrite.sql і 20261104_reading_known_core_part1–3.sql.
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

create temp view a1 as select * from public.reading_texts where cefr = 'A1' and status = 'PUBLISHED';

select pg_temp.ok(pg_temp.n($q$select 1 from a1$q$) >= 52, '≥ 52 опублікованих текстів A1');
select pg_temp.ok(pg_temp.n($q$select module_order from a1 where module_order in (7, 11, 12) group by 1 having count(*) >= 4$q$) = 3,
  'у модулях A1.7, A1.11, A1.12 — щонайменше по 4 тексти');
select pg_temp.ok(pg_temp.n($q$select 1 from a1 where known_ratio < 0.9$q$) = 0, 'у кожному тексті A1 ≥ 90 % знайомих слів (§56)');
select pg_temp.ok(pg_temp.n($q$select 1 from a1 where code between 'RD-A1-041' and 'RD-A1-052'
  and (jsonb_array_length(questions) <> 3 or jsonb_array_length(glossary) < 10 or body_hr ~ '[Ѐ-ӿ]' or body_ua !~ '[Ѐ-ӿ]')$q$) = 0,
  'нові тексти: 3 питання, словничок, хорватське без кирилиці, переклад українською');
select pg_temp.ok(pg_temp.n($q$select 1 from a1, jsonb_array_elements(glossary) e
  where e ->> 'pos' is null or (e ->> 'gram' is null and e ->> 'form' <> lower(e ->> 'lemma'))$q$) = 0,
  'у словничку кожне слово має частину мови, а змінена форма — граматичну підказку');
select pg_temp.ok(pg_temp.n($q$select 1 from a1 where code in ('RD-A1-010', 'RD-A1-018', 'RD-A1-020', 'RD-A1-021', 'RD-A1-023',
  'RD-A1-027', 'RD-A1-030', 'RD-A1-033', 'RD-A1-034', 'RD-A1-035', 'RD-A1-037')
  and not exists (select 1 from public.content_versions v where v.entity_type = 'reading_text' and v.entity_id = a1.id
                  and v.payload ? 'body_hr')$q$) = 0,
  'стара редакція переписаних текстів збережена в content_versions');
select pg_temp.ok((select body_hr from a1 where code = 'RD-A1-021') like '%Iskustvo nije važno%', 'RD-A1-021 — нова редакція');
select pg_temp.ok(pg_temp.n($q$select 1 from a1 a join a1 b on a.id < b.id and a.order_index = b.order_index$q$) = 0,
  'порядок текстів A1 не повторюється');

select 'ALL TESTS PASSED' as result;
rollback;
