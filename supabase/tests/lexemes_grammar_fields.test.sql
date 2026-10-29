-- =====================================================================
-- Тести: граматичні поля словника (lexemes_quality_20261021) · 2026-10-21
-- Запускати ПІСЛЯ supabase/data_fixes/20261021_lexemes_grammar_fields.sql.
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

-- Загальні правила для всього словника (крім DEPRECATED)
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where status <> 'DEPRECATED'
  and (part_of_speech is null or part_of_speech not in ('noun', 'verb', 'adjective', 'adverb', 'pronoun', 'preposition',
       'conjunction', 'particle', 'interjection', 'number', 'phrase'))$q$) = 0,
  'у кожного слова є справжня частина мови (без порожніх, word, other, formulaic, chunk)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where status <> 'DEPRECATED' and part_of_speech = 'verb'
  and coalesce(forms->>'aspect', '') not in ('ipfv', 'pfv', 'biasp')$q$) = 0,
  'у кожного дієслова є вид: ipfv / pfv / biasp');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where status <> 'DEPRECATED' and part_of_speech = 'noun'
  and coalesce(forms->>'gender', '') not in ('m', 'f', 'n', 'm_pl', 'f_pl', 'n_pl')$q$) = 0,
  'у кожного іменника є рід');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where status <> 'DEPRECATED'
  and normalized is distinct from translate(lower(btrim(lemma)), 'čćđšž', 'ccdsz')$q$) = 0,
  'normalized = лема малими без діакритик (як normalizeCroatian)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where status <> 'DEPRECATED' and part_of_speech not in ('noun', 'phrase')
  and forms ? 'gender'$q$) = 0,
  'рід лише в іменників і виразів');

-- Конкретні виправлення з PROJECT_STATE
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma = 'čuvati' and part_of_speech = 'verb' and forms->>'aspect' = 'ipfv'$q$) = 1,
  'čuvati — дієслово недоконаного виду (було «noun»)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma = 'četrdeset' and part_of_speech = 'number' and not forms ? 'gender'$q$) = 1,
  'četrdeset — числівник (було «noun»)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma = 'domaćin' and normalized = 'domacin'$q$) = 1
  and pg_temp.n($q$select 1 from public.lexemes where lemma = 'hitna pomoć' and normalized = 'hitna pomoc'$q$) = 1,
  'normalized: domaćin → domacin, hitna pomoć → hitna pomoc');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma = 'dogovarati' and forms->>'aspect' = 'ipfv'$q$) = 1
  and pg_temp.n($q$select 1 from public.lexemes where lemma = 'čestitati' and forms->>'aspect' = 'biasp'$q$) = 1
  and pg_temp.n($q$select 1 from public.lexemes where lemma = 'baciti' and forms->>'aspect' = 'pfv'$q$) = 1,
  'вид: dogovarati pfv → ipfv, čestitati impfv → biasp, baciti unspecified → pfv');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma = 'devizni račun' and ukrainian_translation = 'валютний рахунок'
  and part_of_speech = 'phrase'$q$) = 1, '«Devizni račun» → «devizni račun», вираз');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma = 'uzdahnuti' and ukrainian_translation = 'зітхнути'
  and forms->>'aspect' = 'pfv'$q$) = 1, 'vzdahnuti → uzdahnuti («зітхнути»)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma = 'sretan Božić' and ukrainian_translation = 'щасливого Різдва'$q$) = 1,
  'sretan Božić — з великої Б');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where (lemma, part_of_speech, forms->>'gender') in
  (('administracija', 'noun', 'f'), ('vijesti', 'noun', 'f_pl'), ('smisao', 'noun', 'm'), ('korist', 'noun', 'f'))$q$) = 4,
  'рід: administracija f, vijesti f_pl, smisao m, korist f');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where (lemma, part_of_speech) in
  (('dobro', 'adverb'), ('gdje je izlaz', 'phrase'), ('pametan', 'adjective'), ('diviti se', 'verb'))$q$) = 4,
  'dobro — прислівник, gdje je izlaz — вираз, pametan — прикметник, diviti se — дієслово');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma = 'bojati se' and forms->>'aspect' = 'ipfv'$q$) = 1,
  'зворотне дієслово bojati se — вид ipfv');

-- Журнал
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_versions v join public.lexemes l on l.id = v.entity_id
  where v.entity_type = 'lexeme' and v.change_reason like 'lexemes_quality_20261021%' and l.lemma = 'čuvati'
    and v.payload->>'part_of_speech' = 'noun'$q$) = 1, 'стара версія čuvati («noun») — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from backup.lexemes_20261021 where lemma = 'čuvati'$q$) = 1,
  'копія таблиці до змін — backup.lexemes_20261021');

set local role anon;
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma = 'čuvati' and part_of_speech = 'verb'$q$) = 1,
  'гість бачить виправлену частину мови');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
