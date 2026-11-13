-- =====================================================================
-- Тести: регістр наявних слів словника (informal / colloquial / slang) · 2026-11-12
-- Запускати ПІСЛЯ supabase/data_fixes/20261112_lexeme_register.sql.
-- Оновлено 2026-11-13 (пакет 20261113_lexeme_labels.sql, рішення власника «явні значення в усіх словах»): стандартне слово —
-- register = 'standard' (було «порожньо»); старе regional → colloquial; у переліку — standard, без старих значень.
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK. Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

create or replace function pg_temp.reg(l text) returns text language sql as $$
  select register from public.lexemes where lower(lemma) = l and status = 'PUBLISHED'
$$;

-- Визначення власника: informal — bok, Kako si? (замість Kako ste?); colloquial — розмовне; slang — мова групи
select pg_temp.ok(pg_temp.reg('bok') = 'informal', 'bok — informal');
select pg_temp.ok(pg_temp.reg('kako si') = 'informal', 'Kako si? — informal');
select pg_temp.ok(pg_temp.reg('kako ste') = 'standard', 'Kako ste? — standard');
-- molim te є в робочій базі, але не в локальній / CI (там його немає в пакетах) — тоді перевірка лише molim vas
select pg_temp.ok((pg_temp.reg('molim te') = 'informal'
  or not exists (select 1 from public.lexemes where lower(lemma) = 'molim te' and status = 'PUBLISHED'))
  and pg_temp.reg('molim vas') = 'standard', 'molim te — informal, molim vas — standard');
select pg_temp.ok(pg_temp.reg('odakle si') = 'informal' and pg_temp.reg('oprosti') = 'informal', 'звертання на «ти» — informal');
select pg_temp.ok(pg_temp.reg('nikad ne reci nikad') = 'standard', 'прислів''я з «ти» в загальному значенні — standard');
select pg_temp.ok(pg_temp.reg('kila') = 'colloquial' and pg_temp.reg('fjaka') = 'colloquial', 'kila, fjaka — colloquial');
select pg_temp.ok(pg_temp.reg('dućan') = 'standard' and pg_temp.reg('pauk') = 'standard', 'сумнівні (dućan, pauk) — standard, питання носію');
-- Повний перегляд 2026-11-13: наказовий спосіб на «ти» без займенника, розмовні слова поза першим списком
select pg_temp.ok(pg_temp.reg('drži se') = 'informal' and pg_temp.reg('pozdravi') = 'informal' and pg_temp.reg('zdravo') = 'informal',
  'drži se, pozdravi, zdravo — informal');
select pg_temp.ok(pg_temp.reg('klima') = 'colloquial' and pg_temp.reg('kvart') = 'colloquial', 'klima, kvart — colloquial');
select pg_temp.ok(pg_temp.reg('doktor') = 'standard' and pg_temp.reg('pumpa') = 'standard', 'сумнівні (doktor, pumpa) — standard, питання носію');
-- Наявні значення не змінено
select pg_temp.ok(pg_temp.reg('ae') = 'slang' and pg_temp.reg('onak') = 'slang', 'ae, onak — slang, як і було');
select pg_temp.ok(pg_temp.reg('pomidor') = 'colloquial', 'pomidor — colloquial (було regional, пакет 20261113_lexeme_labels)');
select pg_temp.ok((select regionality from public.lexemes where lower(lemma) = 'onak' and status = 'PUBLISHED') = 'Zagreb', 'regionality не змінено');
-- Лише дозволені значення
select pg_temp.ok(not exists (select 1 from public.lexemes where status = 'PUBLISHED' and register is not null
  and register not in ('standard', 'formal', 'informal', 'colloquial', 'slang', 'vulgar')), 'register — лише з переліку (без старих значень)');
select pg_temp.ok((select count(*) from public.lexemes where status = 'PUBLISHED' and register in ('informal', 'colloquial')) >= 50,
  'позначено щонайменше 50 слів informal / colloquial');
-- Стара версія й запис перевірки
select pg_temp.ok(not exists (select 1 from public.lexemes x where x.status = 'PUBLISHED' and x.register in ('informal', 'colloquial')
  and lower(x.lemma) in ('bok', 'kako si', 'kila')
  and not exists (select 1 from public.content_versions v where v.entity_type = 'lexeme' and v.entity_id = x.id
                   and v.change_reason like 'lexeme_register 2026-11-12%' and v.payload ->> 'register' is null)), 'стара версія (без register) — у content_versions');
select pg_temp.ok(not exists (select 1 from public.lexemes x where lower(x.lemma) = 'bok' and x.status = 'PUBLISHED'
  and not exists (select 1 from public.content_reviews r where r.entity_id = x.id and r.reviewer_kind = 'script' and r.notes like 'lexeme_register%')),
  'запис у content_reviews');

select 'ALL TESTS PASSED' as result;
rollback;
