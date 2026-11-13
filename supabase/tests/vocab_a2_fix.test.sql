-- =====================================================================
-- Тести: сумнівні слова запасу A2 / B1 · 2026-11-12
-- Запускати ПІСЛЯ supabase/data_fixes/20261112_vocab_a2_fix.sql.
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK. Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

create or replace function pg_temp.pub(l text) returns boolean language sql as $$
  select exists (select 1 from public.lexemes where lower(lemma) = l and status = 'PUBLISHED')
$$;

select pg_temp.ok(not pg_temp.pub('utisak') and pg_temp.pub('dojam')
  and (select forms ->> 'gen' from public.lexemes where lemma = 'dojam') = 'dojma', 'utisak → dojam (родовий dojma)');
select pg_temp.ok(not pg_temp.pub('talenat') and pg_temp.pub('talent'), 'talenat → talent');
select pg_temp.ok(pg_temp.pub('dogoditi se') and pg_temp.pub('događati se') and pg_temp.pub('baviti se')
  and not pg_temp.pub('dogoditi') and not pg_temp.pub('događati') and not pg_temp.pub('baviti'), 'dogoditi / događati / baviti — з se');
select pg_temp.ok((select normalized from public.lexemes where lemma = 'događati se') = 'dogadati se', 'normalized без діакритики');
select pg_temp.ok((select count(*) from public.lexemes where lemma in ('klasično', 'moderno') and status = 'PUBLISHED' and part_of_speech = 'adverb') = 2,
  'klasično, moderno — прислівники');
select pg_temp.ok((select count(*) from public.lexemes where lower(lemma) in ('apoteka', 'kompjuter', 'da li govorite engleski', 'sistem',
  'dijaloz -> dijalog', 'podaci', 'usluge', 'družiti', 'navići', 'smijeti', 'posati') and status = 'PUBLISHED') = 0, '11 дублікатів — не опубліковані');
select pg_temp.ok(pg_temp.pub('ljekarna') and pg_temp.pub('računalo') and pg_temp.pub('sustav') and pg_temp.pub('usluga')
  and pg_temp.pub('družiti se') and pg_temp.pub('smjeti'), 'стандартні слова лишаються опублікованими');
-- 2026-11-13 (рішення власника «Ок, замінюй»): позначка «регіонально» й «стандартно — rajčica» переїхали з перекладу
-- в мітки (register, regionality) і зв'язок standard_lexeme_id (пакет 20261113_lexeme_standard_links.sql)
select pg_temp.ok((select count(*) from public.lexemes where lower(lemma) in ('pomidor', 'kapula', 'šugaman', 'ae', 'onak')
  and status = 'PUBLISHED' and register in ('colloquial', 'slang') and regionality <> 'general') = 5,
  'pomidor, kapula, šugaman, ae, onak — розмовні / сленг, регіональні (мітки)');
select pg_temp.ok((select s.lemma from public.lexemes l join public.lexemes s on s.id = l.standard_lexeme_id
                    where l.lemma = 'pomidor') = 'rajčica', 'pomidor: стандартно — rajčica (standard_lexeme_id)');
select pg_temp.ok(not exists (select 1 from public.lexemes x where x.status = 'DEPRECATED' and lower(x.lemma) in ('apoteka', 'kompjuter', 'sistem')
  and not exists (select 1 from public.content_versions v where v.entity_type = 'lexeme' and v.entity_id = x.id)), 'стара версія — у content_versions');
select pg_temp.ok(not exists (select 1 from public.lexemes x where x.lemma = 'dojam'
  and not exists (select 1 from public.content_versions v where v.entity_id = x.id and v.payload ->> 'lemma' = 'utisak')), 'dojam: стара лема utisak — у content_versions');
select pg_temp.ok(not exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id
  where li.item_type = 'lexeme' and x.status <> 'PUBLISHED'), 'усі слова уроків опубліковані');

select 'ALL TESTS PASSED' as result;
rollback;
