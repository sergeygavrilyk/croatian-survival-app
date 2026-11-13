-- =====================================================================
-- Тести: стандартні відповідники (standard_lexeme_id) і переклади без позначок · 2026-11-13
-- Запускати ПІСЛЯ supabase/data_fixes/20261113_lexeme_standard_links.sql.
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK. Успіх: «ALL TESTS PASSED».
-- Пари, слів яких немає в базі (локальна копія — не весь словник), пропускаються; pomidor, kapula, šugaman,
-- apoteka, kompjuter, kila — є і в локальній базі, тому перевіряються завжди.
-- =====================================================================
begin;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

-- лема стандартного відповідника слова (null — зв'язку немає)
create or replace function pg_temp.std(k text) returns text language sql as $$
  select s.lemma from public.lexemes l join public.lexemes s on s.id = l.standard_lexeme_id where lower(l.lemma) = k
$$;

-- ---------------------------------------------------------------- зв'язки
select pg_temp.ok(pg_temp.std('pomidor') = 'rajčica' and pg_temp.std('kapula') = 'luk' and pg_temp.std('šugaman') = 'ručnik'
  and pg_temp.std('apoteka') = 'ljekarna' and pg_temp.std('kompjuter') = 'računalo' and pg_temp.std('kila') = 'kilogram',
  'pomidor → rajčica, kapula → luk, šugaman → ručnik, apoteka → ljekarna, kompjuter → računalo, kila → kilogram');

select pg_temp.ok(not exists (
  select 1 from (values ('ae', 'da'), ('cura', 'djevojka'), ('pegla', 'glačalo'), ('tastatura', 'tipkovnica'),
                        ('tegla', 'staklenka'), ('kusur', 'ostatak'), ('mušterija', 'kupac'), ('mail', 'e-pošta'),
                        ('kvart', 'gradska četvrt'), ('marenda', 'užina'), ('kesa', 'vrećica'),
                        ('da li govorite engleski', 'govorite li engleski')) as p(k, s)
   where exists (select 1 from public.lexemes where lower(lemma) = p.k)
     and exists (select 1 from public.lexemes where lower(lemma) = p.s and status = 'PUBLISHED')
     and pg_temp.std(p.k) is distinct from p.s),
  'решта пар (ae → da, tegla → staklenka, kvart → gradska četvrt…) — зв''язані, якщо обидва слова є в базі');

select pg_temp.ok((select count(*) from public.lexemes l join public.lexemes s on s.id = l.standard_lexeme_id
                    where s.status <> 'PUBLISHED' or s.register <> 'standard' or s.regionality <> 'general') = 0,
  'відповідник — опубліковане стандартне загальне слово');
select pg_temp.ok((select count(*) from public.lexemes
                    where standard_lexeme_id is not null and register = 'standard' and regionality = 'general') = 0,
  'зв''язок лише від нестандартного чи регіонального слова');
select pg_temp.ok((select count(*) from public.lexemes where standard_lexeme_id is not null) >= 13,
  'зв''язків щонайменше 13 (локальна база; у робочій — 18)');

-- ---------------------------------------------------------------- переклади без позначок
select pg_temp.ok((select ukrainian_translation from public.lexemes where lemma = 'pomidor') = 'помідор'
  and (select ukrainian_translation from public.lexemes where lemma = 'ae') = 'так, ага'
  and (select ukrainian_translation from public.lexemes where lemma = 'onak') = 'ну, типу; якось так'
  and (select ukrainian_translation from public.lexemes where lemma = 'kila') = 'кілограм'
  and (select ukrainian_translation from public.lexemes where lemma = 'gablec') = 'гарячий обід на роботі',
  'переклад — лише значення: pomidor «помідор», ae «так, ага», onak, kila, gablec');

select pg_temp.ok((select count(*) from public.lexemes
                    where ukrainian_translation ~ '\([^)]*(регіональн|стандартно|хорватською —|сербськ|сленг)[^)]*\)'
                       or ukrainian_translation ~ '\((загреб|далм|істр)\.\)'
                       or (ukrainian_translation ~ '\((розм\.?|розмовн[оеаий])\)'
                           and regexp_replace(ukrainian_translation, '\([^)]*\)', '', 'g') !~ ';')) = 0,
  'у перекладах немає позначок, що дублюють мітки (як translation_markers у scripts/lexeme_checks.py)');

select pg_temp.ok((select ukrainian_translation from public.lexemes where lemma = 'kvadrat') ~ '\(розмовно\); '
  and (select ukrainian_translation from public.lexemes where lemma = 'pauk') ~ '\(розм\.\); ',
  'позначку одного зі значень (kvadrat, pauk) не прибрано');

select pg_temp.ok((select count(*) from public.lexemes
                    where lower(lemma) in ('pomidor', 'kapula', 'šugaman', 'apoteka', 'kompjuter')
                      and ukrainian_explanation ~ '(rajčica|luk|ručnik|ljekarna|računalo)') = 5,
  'пояснення зі стандартним словом не змінено');

-- ---------------------------------------------------------------- вправи
select pg_temp.ok((select count(*) from public.exercises
                    where coalesce(correct_answer, '') || coalesce(question_text, '') || coalesce(options::text, '')
                          ~ '(\(загреб\.\)|кілограм \(розм\.\)|нотаріус \(розм\.\)|регіонально: Далмація)') = 0,
  'у вправах немає старих перекладів з позначкою');
select pg_temp.ok(exists (select 1 from public.exercises where correct_answer = 'гарячий обід на роботі'),
  'вправа «Що означає gablec?» — новий переклад');

-- ---------------------------------------------------------------- версії
select pg_temp.ok(not exists (
  select 1 from public.lexemes x where x.standard_lexeme_id is not null
     and not exists (select 1 from public.content_versions v where v.entity_type = 'lexeme' and v.entity_id = x.id
                       and v.change_reason like 'lexeme_standard_links 2026-11-13%')),
  'стара версія кожного зміненого слова — у content_versions');
select pg_temp.ok(exists (select 1 from public.content_versions v join public.lexemes x on x.id = v.entity_id
                           where x.lemma = 'pomidor' and v.payload ->> 'ukrainian_translation' like '%стандартно — rajčica%'),
  'старий переклад pomidor — у content_versions');
select pg_temp.ok(not exists (
  select 1 from public.exercises e where e.correct_answer = 'гарячий обід на роботі'
     and not exists (select 1 from public.content_versions v where v.entity_type = 'exercise' and v.entity_id = e.id)),
  'стара версія вправи — у content_versions');

select pg_temp.ok(exists (select 1 from backup.lexemes_standard_links_20261113 where lemma = 'pomidor'
                           and ukrainian_translation like '%стандартно — rajčica%')
  and exists (select 1 from backup.exercises_standard_links_20261113 where correct_answer like '%(загреб.)%'),
  'копія рядків до зміни — у backup (слова й вправи)');

select 'ALL TESTS PASSED' as result;
rollback;
