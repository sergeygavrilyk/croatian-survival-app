-- =====================================================================
-- Тести: проблемні слова словника A0 виправлено (lexemes_fix_20261020) · 2026-10-20
-- Запускати ПІСЛЯ supabase/data_fixes/20261020_lexemes_a0_problem_words.sql.
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

select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where ukrainian_translation ilike '%базовий термін%'$q$) = 0,
  'у словнику немає заглушок «базовий термін»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes
  where lower(lemma) in ('bijela mačka', 'crna mačka', 'mali pas', 'veliki pas', 'novi auto', 'stari auto', 'brzi auto', 'spori auto')
    and status = 'PUBLISHED' and cefr = 'A0' and vocabulary_type = 'collocation' and normalized !~ '[čćđšž]'
    and ukrainian_translation ~ '[Ѐ-ӿ]' and jsonb_array_length(examples) = 1 and forms ? 'gender'$q$) = 8,
  '8 колишніх заглушок: переклад, приклад, рід, normalized без діакритики');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes
  where lower(lemma) in ('pomidor', 'kapula', 'šugaman', 'apoteka', 'kompjuter', 'da li govorite engleski', 'ae', 'onak')
    and status = 'PUBLISHED' and cefr = 'A2' and register is not null and ukrainian_explanation is not null
    and ukrainian_translation ~ '(діалект|розмовне|сербська|сленг)'$q$) = 8,
  '8 діалектних / розмовних / сербських слів: позначка в перекладі, register, пояснення, рівень A2 (не A0)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lower(lemma) in ('pomidor', 'kapula', 'šugaman', 'apoteka', 'kompjuter')
  and ukrainian_translation !~ '(rajčica|luk|ručnik|ljekarna|računalo)'$q$) = 0,
  'у перекладі названо стандартне хорватське слово (rajčica, luk, ručnik, ljekarna, računalo)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma = 'Onak'$q$) = 0
  and pg_temp.n($q$select 1 from public.lexemes where lemma = 'onak' and regionality = 'Zagreb'$q$) = 1, '«Onak» → «onak» (лема з малої), Загреб');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_versions
  where entity_type = 'lexeme' and change_reason like 'lexemes_fix_20261020%'$q$) >= 16, 'стара версія 16 слів — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes x join public.lesson_items i on i.item_id = x.id and i.item_type = 'lexeme'
  join public.lessons l on l.id = i.lesson_id and l.level_code = 'A0'
  where lower(x.lemma) in ('pomidor', 'kapula', 'šugaman', 'apoteka', 'kompjuter', 'da li govorite engleski', 'ae', 'onak')$q$) = 0,
  'діалектних і сербських слів немає в уроках A0');

set local role anon;
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lower(lemma) = 'bijela mačka' and ukrainian_translation = 'біла кішка'$q$) = 1,
  'гість бачить виправлений переклад');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_versions$q$) = 0, 'гість не бачить історію змін');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
