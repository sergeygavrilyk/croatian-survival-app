-- =====================================================================
-- Тести: приклади для слів без прикладів (lexemes_examples_20261021) · 2026-10-21
-- Запускати ПІСЛЯ supabase/data_fixes/20261021_lexemes_examples_a0_a1.sql (і, якщо власник погодив, _a2_b1.sql).
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

select pg_temp.ok(pg_temp.n($q$select 1 from public.content_reviews r join public.lexemes l on l.id = r.entity_id
  where r.notes like 'Приклад додано 2026-10-21%' and jsonb_array_length(l.examples) < 1$q$) = 0,
  'кожне слово з пакета має приклад (з 2026-11-04 у базових словах — по 2)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_reviews where notes like 'Приклад додано 2026-10-21 (A0 / A1%'$q$) > 0,
  'пакет A0 / A1 запущено');
-- Довідково (не тест): слова A0 / A1 без прикладу. У робочій базі після пакета — лише nulti.
select string_agg(lemma, ', ') as a0_a1_without_examples from public.lexemes
 where status <> 'DEPRECATED' and examples = '[]'::jsonb and cefr in ('A0', 'A1');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes l, jsonb_array_elements_text(l.examples) e
  where e ~ '[Ѐ-ӿ]'$q$) = 0, 'у прикладах немає кирилиці');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma = 'dobro' and examples = '["Hvala, dobro sam."]'::jsonb$q$) = 1,
  'dobro → «Hvala, dobro sam.»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_versions
  where entity_type = 'lexeme' and change_reason like 'lexemes_examples_20261021_%'$q$) > 0,
  'стара версія слів — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes l join public.content_versions v on v.entity_id = l.id
  where v.change_reason like 'lexemes_examples_20261021_%' and v.payload->'examples' <> '[]'::jsonb$q$) = 0,
  'приклад додано лише словам, у яких прикладів не було (наявні не перезаписано)');

-- Довідково (не тест): слова A2 / B1 без прикладу. Після пакета A2 / B1 у робочій базі — лише дублікати й форми слів,
-- що чекають рішення власника (dijaloz -> dijalog, posati, smijeti, da li govorite engleski, prometna, restoranu, novom, onom).
select string_agg(lemma, ', ') as a2_b1_without_examples from public.lexemes
 where status <> 'DEPRECATED' and examples = '[]'::jsonb and cefr in ('A2', 'B1', 'B2');

set local role anon;
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma = 'dobro' and jsonb_array_length(examples) = 1$q$) = 1,
  'гість бачить приклад');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
