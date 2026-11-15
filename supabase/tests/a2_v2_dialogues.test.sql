-- =====================================================================
-- Тести пакета 20261115_a2_v2_dialogues_6_turns.sql: діалоги A2 v2 — не менше 6 реплік.
-- Запускати ПІСЛЯ пакетів 20261112_curriculum_a2_v2_* і 20261115_a2_v2_dialogues_6_turns.sql.
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK. Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

create temp view a2_dialogues as
  select c.id, c.status, (select count(*) from public.conversation_turns t where t.conversation_id = c.id) as n,
         (select max(t.order_index) from public.conversation_turns t where t.conversation_id = c.id) as last_order,
         (select count(distinct t.order_index) from public.conversation_turns t where t.conversation_id = c.id) as orders
    from public.conversations c join public.lessons l on l.id = c.lesson_id
   where l.level_code = 'A2' and c.source = 'claude_curriculum_a2_v2';

select pg_temp.ok((select count(*) from a2_dialogues) = 172, 'A2 v2: 172 діалоги (2 на кожен з 86 уроків)');
select pg_temp.ok((select count(*) from a2_dialogues where n < 6) = 0, 'A2 v2: немає діалогів коротших за 6 реплік');
select pg_temp.ok((select count(*) from a2_dialogues where n > 8) = 0, 'A2 v2: немає діалогів довших за 8 реплік');
select pg_temp.ok((select sum(n) from a2_dialogues) = 1032, 'A2 v2: 1032 репліки (914 + 118 нових)');
select pg_temp.ok((select count(*) from a2_dialogues where last_order <> n or orders <> n) = 0,
  'A2 v2: порядок реплік у кожному діалозі — 1…N без пропусків і повторів');
select pg_temp.ok((select count(*) from public.conversation_turns t join a2_dialogues d on d.id = t.conversation_id
                   where t.hr_text ~ '[а-яіїєґА-ЯІЇЄҐ]' or t.ua_translation !~ '[а-яіїєґА-ЯІЇЄҐ]'
                      or btrim(t.hr_text) = '' or btrim(t.speaker_name) = '') = 0,
  'A2 v2: репліки — хорватське латиницею, переклад українською, мовець є');
select pg_temp.ok((select count(*) from public.conversation_turns t join a2_dialogues d on d.id = t.conversation_id
                   where t.hr_text ~* '\m(da li|treba da|biti ću)\M') = 0, 'A2 v2: у репліках немає «da li», «treba da», «biti ću»');
select pg_temp.ok((select count(distinct r.entity_id) from public.content_reviews r
                   where r.entity_type = 'conversation' and r.notes like 'a2_v2_dialogues:%') = 97,
  'A2 v2: запис перевірки для кожного з 97 доповнених діалогів');
select pg_temp.ok(exists (select 1 from public.conversation_turns where hr_text = 'Nema na čemu. Laku noć!'),
  'A2 v2: нова репліка в діалозі «Buka navečer» на місці');

select 'ALL TESTS PASSED' as result;
rollback;
