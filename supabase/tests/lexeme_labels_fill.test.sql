-- =====================================================================
-- Тести: розмітка всіх слів і речень (крок 2 плану маркування) · 2026-11-13
-- Запускати ПІСЛЯ supabase/data_fixes/20261113_lexeme_labels.sql (і міграції M24).
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK. Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

create or replace function pg_temp.raises(q text) returns boolean language plpgsql as $$
begin
  execute q;
  return false;
exception when others then
  return true;
end $$;

-- Мітки слова: 'register|regionality|tag1,tag2' (теги за абеткою)
create or replace function pg_temp.lab(l text) returns text language sql as $$
  select register || '|' || regionality || '|' || coalesce((select string_agg(t, ',' order by t) from unnest(usage_tags) t), '')
    from public.lexemes where lower(lemma) = l
$$;

-- ---------------------------------------------------------------- повнота
select pg_temp.ok((select count(*) from public.lexemes where register is null or regionality is null or usage_tags is null) = 0,
  'у кожному слові (PUBLISHED і DEPRECATED) — усі три мітки');
select pg_temp.ok((select count(*) from public.phrases where register is null or regionality is null or usage_tags is null) = 0,
  'у кожному реченні — усі три мітки');
select pg_temp.ok(not exists (select 1 from public.lexemes where register in ('regional', 'non_standard')),
  'старих значень regional / non_standard немає');
select pg_temp.ok(not pg_temp.raises('alter table public.lexemes validate constraint lexemes_register_check'),
  'перевірку register можна зробити чинною (VALIDATE) — крок 3 «замок» пройде');

-- ---------------------------------------------------------------- правила
select pg_temp.ok(pg_temp.lab('hvala') = 'standard|general|', 'hvala — standard / general / {}');
select pg_temp.ok(pg_temp.lab('kako ste') = 'standard|general|', 'Kako ste? — standard');
select pg_temp.ok(pg_temp.lab('bok') = 'informal|general|', 'bok — informal (як і було)');
select pg_temp.ok(pg_temp.lab('kapula') = 'colloquial|Dalmatia|italianism'
  and pg_temp.lab('pomidor') = 'colloquial|Dalmatia|italianism'
  and pg_temp.lab('šugaman') = 'colloquial|Dalmatia|italianism', 'regional → colloquial + Dalmatia + italianism');
select pg_temp.ok(pg_temp.lab('da li govorite engleski') = 'colloquial|general|', 'non_standard → colloquial (DEPRECATED теж)');
select pg_temp.ok(pg_temp.lab('gablec') = 'colloquial|Zagreb|germanism,kajkavian', 'gablec — colloquial, Zagreb, germanism + kajkavian');
select pg_temp.ok(pg_temp.lab('vikend') = 'standard|general|anglicism' and pg_temp.lab('laptop') = 'standard|general|anglicism',
  'vikend, laptop — anglicism');
select pg_temp.ok(pg_temp.lab('burek') = 'standard|general|turkism', 'burek — turkism');
select pg_temp.ok(pg_temp.lab('izaći na kraj') = 'standard|general|idiom' and pg_temp.lab('na licu mjesta') = 'standard|general|idiom',
  'izaći na kraj, na licu mjesta — idiom');
select pg_temp.ok(pg_temp.lab('dućan') = 'standard|general|', 'сумнівне dućan — standard (питання носію у звіті)');
select pg_temp.ok((select regionality from public.lexemes where lower(lemma) = 'onak') = 'Zagreb'
  and (select register from public.lexemes where lower(lemma) = 'onak') = 'slang', 'наявні мітки (onak — slang, Zagreb) не змінено');

-- ---------------------------------------------------------------- версії й журнал
select pg_temp.ok(not exists (select 1 from public.lexemes x where lower(x.lemma) in ('hvala', 'kapula', 'gablec', 'vikend')
  and not exists (select 1 from public.content_versions v where v.entity_type = 'lexeme' and v.entity_id = x.id
                   and v.change_reason like 'lexeme_labels 2026-11-13%' and v.payload -> 'usage_tags' = 'null'::jsonb)),
  'стара версія (до міток) — у content_versions');
select pg_temp.ok(not exists (select 1 from public.lexemes x where lower(x.lemma) in ('hvala', 'kapula')
  and not exists (select 1 from public.content_reviews r where r.entity_type = 'lexeme' and r.entity_id = x.id
                   and r.reviewer_kind = 'script' and r.notes like 'lexeme_labels 2026-11-13%')),
  'запис у content_reviews');
select pg_temp.ok((select payload ->> 'register' from public.content_versions v join public.lexemes x on x.id = v.entity_id
                   where v.entity_type = 'lexeme' and lower(x.lemma) = 'pomidor' and v.change_reason like 'lexeme_labels 2026-11-13%'
                   order by v.version desc limit 1) = 'regional', 'у старій версії pomidor — regional');

select 'ALL TESTS PASSED';
rollback;
