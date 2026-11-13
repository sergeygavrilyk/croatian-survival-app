-- =====================================================================
-- Тест пакета 20261113_interference_v2.sql: типові помилки v2 (вид дієслова, артиклі, вимова) і виправлення UKR-HR-0060.
-- Запускати ПІСЛЯ пакета. БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
-- Успіх: «ALL TESTS PASSED».
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

select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors where source = 'claude_interference_v2' and status = 'PUBLISHED'
  and code between 'UKR-HR-0075' and 'UKR-HR-0086'$q$) = 12, '12 нових типових помилок UKR-HR-0075…0086');
select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors where status = 'PUBLISHED'$q$) >= 86, 'у каталозі ≥ 86 помилок');
select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors where status = 'PUBLISHED' and category = 'aspect'$q$) >= 8,
  'вид дієслова: ≥ 8 (було 2)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors where status = 'PUBLISHED' and category = 'articles'$q$) >= 4,
  'артиклі: ≥ 4 (було 1)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors where status = 'PUBLISHED' and category = 'pronunciation'$q$) >= 8,
  'вимова: ≥ 8 (було 5)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors where source = 'claude_interference_v2'
  and grammar_topic_id is null and lexeme_id is null$q$) = 0, 'кожна нова помилка прив''язана до теми граматики або слова (картка в уроці)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors e join public.grammar_topics g on g.id = e.grammar_topic_id
  where e.source = 'claude_interference_v2' and (g.cefr not in ('A0', 'A1') or g.status <> 'PUBLISHED')$q$) = 0,
  'теми граматики — опубліковані A0 / A1');
select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors e join public.lexemes l on l.id = e.lexeme_id
  where e.source = 'claude_interference_v2' and (l.status <> 'PUBLISHED'
    or not exists (select 1 from public.lesson_items li where li.item_type = 'lexeme' and li.item_id = l.id))$q$) = 0,
  'слова, до яких прив''язано помилки, — опубліковані й стоять в уроках');
select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors where source = 'claude_interference_v2'
  and (jsonb_array_length(examples) <> 2 or explanation_ua !~ '[Ѐ-ӿ]'
       or exists (select 1 from jsonb_array_elements(examples) x where x->>'hr' ~ '[Ѐ-ӿ]' or x->>'ua' !~ '[Ѐ-ӿ]' or x->>'hr' !~ '[.!?]$'))$q$) = 0,
  '2 приклади-речення: хорватське без кирилиці, переклад українською');
select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors where source = 'claude_interference_v2'
  and category not in ('pronunciation', 'stress') and (incorrect_text ~ '[Ѐ-ӿ]' or correct_text ~ '[Ѐ-ӿ]')$q$) = 0,
  '«неправильно / правильно» хорватською (кирилиця лише у вимові)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.linguistic_errors where status = 'PUBLISHED'
  and category in ('pronunciation', 'stress') and split_part(correct_text, ' — ', 1) ~ '[Ѐ-ӿ]'$q$) = 0,
  'підказка вимови починається з хорватського слова (його озвучує 🔊)');
select pg_temp.ok((select correct_text = 'kuća — м’якше «ч» (між «ч» і «ть»)' and version >= 2 from public.linguistic_errors where code = 'UKR-HR-0060'),
  'UKR-HR-0060: підказка без «кутя»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_versions v join public.linguistic_errors e on e.id = v.entity_id
  where v.entity_type = 'linguistic_error' and e.code = 'UKR-HR-0060' and v.payload->>'correct_text' like '%кутя%'$q$) = 1,
  'стара версія UKR-HR-0060 — у content_versions (один раз)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_reviews r join public.linguistic_errors e on e.id = r.entity_id
  where e.source = 'claude_interference_v2'$q$) = 12, 'журнал перевірки — один запис на нову помилку');

select 'ALL TESTS PASSED';
rollback;
