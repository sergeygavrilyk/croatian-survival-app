-- =====================================================================
-- Тести: чистка словника A0 / A1 і готові вирази «htio bih» · 2026-11-04
-- Запускати ПІСЛЯ supabase/data_fixes/20261104_vocab_cleanup.sql.
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

create temp view lw as
select le.id lesson_id, le.title_ua, lower(x.lemma) lemma, x.status
from public.lesson_items li
join public.lessons le on le.id = li.lesson_id and le.status = 'PUBLISHED'
join public.lexemes x on x.id = li.item_id
where li.item_type = 'lexeme';

select pg_temp.ok(pg_temp.n($q$select 1 from lw where lemma in ('htio bih', 'htjela bih') and title_ua like '%У кафе'$q$) = 2,
  'htio bih і htjela bih — в уроці A0 «У кафе»');
select pg_temp.ok(exists (select 1 from lw where lemma = 'ja bih' and title_ua like '%У ресторані'), 'ja bih — в уроці «У ресторані»');
select pg_temp.ok(exists (select 1 from lw where lemma = 'biste li mogli' and title_ua like '%На касі'), 'biste li mogli — в уроці «На касі»');
select pg_temp.ok((select cefr from public.lexemes where lemma = 'htio bih') = 'A0'
  and (select ukrainian_explanation from public.lexemes where lemma = 'htio bih') like '%A2%', 'htio bih: A0, пояснення «граматика — на A2»');
select pg_temp.ok(pg_temp.n($q$select 1 from lw where lemma = 'obaveza'$q$) = 0 and exists (select 1 from lw where lemma = 'obveza')
  and exists (select 1 from backup.lesson_items_20261104), 'obaveza — в жодному уроці (зв’язок — у backup), obveza — в уроці A0');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises ex join public.lesson_items li on li.item_type = 'exercise' and li.item_id = ex.id
  where ex.status = 'PUBLISHED' and (ex.question_text || coalesce(ex.correct_answer, '') || coalesce(ex.options::text, '')) ~* 'obavez'$q$) = 0,
  'у вправах уроків немає obaveza / obavezno');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where status = 'PUBLISHED' and lower(lemma) in
  ('obaveza', 'njen', 'ona (pl)', 'nulti', 'gdje je banka', 'trebam taksi', 'ja sam gladan')$q$) = 0,
  'obaveza, njen, ona (pl), nulti, леми-речення — не опубліковані');
select pg_temp.ok(pg_temp.n($q$select 1 from lw where status <> 'PUBLISHED'$q$) = 0, 'усі слова уроків опубліковані');
select pg_temp.ok((select forms -> 'present' ->> '1s' from public.lexemes where lemma = 'htjeti') = 'hoću', 'htjeti: hoću (а не želim)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes x where x.status = 'DEPRECATED' and lower(x.lemma) = 'obaveza'
  and not exists (select 1 from public.content_versions v where v.entity_type = 'lexeme' and v.entity_id = x.id)$q$) = 0,
  'стара версія obaveza — у content_versions');
select pg_temp.ok(pg_temp.n($q$select lesson_id from lw group by 1 having count(*) > 25$q$) = 0, 'в уроці ≤ 25 слів');

select 'ALL TESTS PASSED' as result;
rollback;
