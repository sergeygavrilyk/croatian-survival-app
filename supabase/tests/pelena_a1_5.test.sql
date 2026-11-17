-- =====================================================================
-- Тест пакета 20261117_pelena_a1_5.sql: урок A1 5 «З дитиною вдома» — лема pelena, форма pelene — DEPRECATED.
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

select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where id = 'fb9bb831-7279-4185-94e7-012eefef7d9d' and lemma = 'pelena'
  and status = 'PUBLISHED' and ukrainian_translation = 'підгузок' and forms->>'plural' = 'pelene' and forms->>'gender' = 'f'
  and register = 'standard' and regionality = 'general' and usage_tags = '{}'$q$) = 1,
  'pelena — опублікована лема: «підгузок», жін. рід, множина pelene, мітки standard / general / {}');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id
  where li.lesson_id = 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2' and li.item_type = 'lexeme' and x.lemma = 'pelena' and li.order_index = 3$q$) = 1,
  'урок A1 5: pelena — на 3-му місці (там, де була pelene)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id where x.lemma = 'pelene'$q$) = 0
  and pg_temp.n($q$select 1 from public.lexemes where lemma = 'pelene' and status <> 'DEPRECATED'$q$) = 0,
  'pelene — ні в жодному уроці, DEPRECATED');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e join public.lexemes x on x.id = e.lexeme_id
  where e.id = '1d5daffe-3020-54c1-84fa-24022a8e56c9' and e.status = 'PUBLISHED' and x.lemma = 'pelena' and e.correct_answer = 'pelena'
    and e.question_text = 'Як хорватською «підгузок»?' and jsonb_array_length(e.options) = 4 and e.options ? 'pelena'$q$) = 1,
  'вправа уроку — «Як хорватською «підгузок»?», відповідь pelena серед 4 варіантів');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items where lesson_id = 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2' and item_type = 'lexeme'$q$) between 10 and 25,
  'кількість слів уроку не змінилась (10–25)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lower(lemma) in ('pelena', 'pelene') and status = 'PUBLISHED'$q$) = 1,
  'для «підгузок» — одна опублікована лема');

select 'ALL TESTS PASSED';
rollback;
