-- =====================================================================
-- Тест пакета 20261113_ucitelj_lesson.sql: «učitelj» в уроці A1 99 «Школа: класи, уроки, розклад».
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

select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items li join public.lexemes l on l.id = li.item_id
  where li.lesson_id = '7c8e16ec-03f3-55dd-a61a-fb59c2401692' and li.item_type = 'lexeme' and l.lemma = 'učitelj' and l.status = 'PUBLISHED'$q$) = 1,
  'učitelj — серед слів уроку A1 99 «Школа: класи, уроки, розклад»');
select pg_temp.ok((select a.order_index + 1 = b.order_index
  from public.lesson_items a join public.lexemes la on la.id = a.item_id and la.lemma = 'učiteljica',
       public.lesson_items b join public.lexemes lb on lb.id = b.item_id and lb.lemma = 'učitelj'
  where a.lesson_id = '7c8e16ec-03f3-55dd-a61a-fb59c2401692' and b.lesson_id = a.lesson_id), 'učitelj стоїть одразу після učiteljica');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items where lesson_id = '7c8e16ec-03f3-55dd-a61a-fb59c2401692' and item_type = 'lexeme'$q$) = 21,
  'в уроці A1 99 — 21 слово (було 20, правило A1 — до 25)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items where lesson_id = '7c8e16ec-03f3-55dd-a61a-fb59c2401692' and item_type = 'exercise'$q$) = 15
  and pg_temp.n($q$select 1 from public.lesson_items where lesson_id = '7c8e16ec-03f3-55dd-a61a-fb59c2401692' and item_type = 'grammar'$q$) = 1,
  'вправи (15) і граматика уроку на місці');
select pg_temp.ok((select min(order_index) = 1 and max(order_index) = count(*) from public.lesson_items where lesson_id = '7c8e16ec-03f3-55dd-a61a-fb59c2401692'),
  'порядок елементів уроку без пропусків і повторів');
select pg_temp.ok((select ukrainian_translation = 'учитель (в основній школі)'
    and examples = '["Moj sin ima dobrog učitelja.", "Učitelj nam je zadao zadaću za ponedjeljak."]'::jsonb
  from public.lexemes where lemma = 'učitelj'), 'učitelj: переклад відрізняє від nastavnik, приклади — повні речення');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_versions v join public.lexemes l on l.id = v.entity_id
  where v.entity_type = 'lexeme' and l.lemma = 'učitelj' and v.change_reason like 'ucitelj_lesson 2026-11-13:%'$q$) = 1,
  'стара версія слова — у content_versions');
select pg_temp.ok(pg_temp.n($q$select l.id from public.lessons l join public.lesson_items i on i.lesson_id = l.id and i.item_type = 'lexeme'
  join public.lexemes x on x.id = i.item_id where x.lemma = 'učitelj' and l.status = 'PUBLISHED'$q$) >= 1,
  'učitelj є хоча б в одному опублікованому уроці');

select 'ALL TESTS PASSED';
rollback;
