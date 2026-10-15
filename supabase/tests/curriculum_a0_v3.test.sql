-- =====================================================================
-- Тести доповнення A0 (curriculum_a0_v3): +17 уроків, тема «Порядок слів», наскрізні номери.
-- Запускати ПІСЛЯ 20261013_curriculum_a0_v3.sql.
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

-- ---------------------------------------------------------------- структура
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A0' and status = 'PUBLISHED'$q$) = 47,
  'A0: 47 опублікованих уроків');
select pg_temp.ok(pg_temp.n($q$select u.id from public.units u join public.modules m on m.id = u.module_id
  join public.lessons l on l.unit_id = u.id where m.level_code = 'A0'
  group by u.id having count(*) not between 4 and 5 or max(l.order_index) <> count(*) or min(l.order_index) <> 1$q$) = 0,
  'у кожному модулі A0 4–5 уроків, номери 1…N без пропусків');
select pg_temp.ok(pg_temp.n($q$select 1 from (
    select l.title_ua, l.title_hr, row_number() over (order by m.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where l.level_code = 'A0' and l.status = 'PUBLISHED') t
  where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%'$q$) = 0,
  'номери в назвах уроків A0 йдуть підряд (укр. і хорв.)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_versions where entity_type = 'lesson'
  and change_reason like 'curriculum_a0_v3: новий номер уроку%'$q$) > 0,
  'старі назви перенумерованих уроків збережено в content_versions');

-- ---------------------------------------------------------------- нові уроки
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l where l.level_code = 'A0' and l.order_index >= 4
  and ((select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') <> 12
    or (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'lexeme') not between 10 and 12
    or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
    or not exists (select 1 from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'grammar')
    or estimated_minutes is distinct from 12)
  and not exists (select 1 from public.content_reviews r where r.entity_id = l.id and r.notes like '%curriculum_a0_v4%')$q$) = 0,
  'кожен новий урок: 10–12 слів, 2 діалоги, граматика, 12 вправ, 12 хв (крім перебудованих за темою)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l where l.level_code = 'A0' and l.order_index >= 4
  and (select count(distinct e.exercise_type) from public.lesson_items i join public.exercises e on e.id = i.item_id
       where i.lesson_id = l.id and i.item_type = 'exercise') < 6$q$) = 0,
  'у кожному новому уроці всі 6 типів вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.lesson_items i on i.lesson_id = l.id
  join public.lexemes x on x.id = i.item_id where l.level_code = 'A0' and i.item_type = 'lexeme' and lower(x.lemma) = 'jučer'$q$) > 0,
  'у модулі про час є «jučer»');
select pg_temp.ok(pg_temp.n($q$select distinct lower(x.lemma) from public.lessons l join public.lesson_items i on i.lesson_id = l.id
  join public.lexemes x on x.id = i.item_id where l.level_code = 'A0' and i.item_type = 'lexeme'
  and lower(x.lemma) in ('siječanj', 'veljača', 'ožujak', 'travanj', 'svibanj', 'lipanj', 'srpanj', 'kolovoz', 'rujan', 'listopad', 'studeni', 'prosinac')$q$) = 12,
  'в уроках A0 є всі 12 місяців');

-- ---------------------------------------------------------------- граматика й словник
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_topics g where g.cefr = 'A0' and g.status = 'PUBLISHED'
  and g.title_ua = 'Порядок слів' and (select count(*) from public.grammar_rules r where r.topic_id = g.id) >= 3$q$) = 1,
  'тема A0 «Порядок слів» з правилами');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma in ('mUP', 'hrvat', 'ukrajinac')
  or (lower(lemma) = 'evo' and ukrainian_translation = 'тут')$q$) = 0, 'виправлено MUP, Hrvat, Ukrajinac, evo');

-- ---------------------------------------------------------------- гість
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A0'$q$) = 47, 'гість бачить 47 уроків A0');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.title_ua = 'Порядок слів'$q$) >= 3, 'гість бачить правила «Порядок слів»');

reset role;
select 'ALL TESTS PASSED' as result;
rollback;
