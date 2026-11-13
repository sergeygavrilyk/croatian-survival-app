-- =====================================================================
-- Тест пакета 20261113_ucitelj_explanation_fix.sql: пояснення до «učitelj» (nastavnik — середня школа).
-- Запускати ПІСЛЯ пакета (і після 20261113_ucitelj_lesson.sql). БЕЗПЕЧНО для робочої бази: транзакція, у кінці ROLLBACK.
-- Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

select pg_temp.ok((select ukrainian_explanation like '%У середній школі офіційно кажуть nastavnik%'
    and ukrainian_explanation not like '%старіше слово%'
  from public.lexemes where lemma = 'učitelj' and status = 'PUBLISHED'), 'пояснення: nastavnik — середня школа, без «старіше слово»');
select pg_temp.ok((select ukrainian_translation = 'учитель (в основній школі)' and register = 'standard' and regionality = 'general'
  from public.lexemes where lemma = 'učitelj'), 'переклад і мітки učitelj не змінилися');
select pg_temp.ok((select count(*) from public.content_versions v join public.lexemes l on l.id = v.entity_id
  where v.entity_type = 'lexeme' and l.lemma = 'učitelj' and v.change_reason like 'ucitelj_explanation_fix 2026-11-13:%'
    and v.payload->>'ukrainian_explanation' like '%старіше слово%') = 1, 'попереднє пояснення — у content_versions (один раз)');
select pg_temp.ok((select count(*) from public.content_reviews r join public.lexemes l on l.id = r.entity_id
  where r.entity_type = 'lexeme' and l.lemma = 'učitelj' and r.notes like 'ucitelj_explanation_fix 2026-11-13:%') = 1, 'запис у журналі перевірки');

select 'ALL TESTS PASSED';
rollback;
