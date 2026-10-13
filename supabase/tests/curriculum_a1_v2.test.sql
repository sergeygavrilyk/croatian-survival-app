-- =====================================================================
-- Тести доповнення A1 (curriculum_a1_v2): +40 уроків, по 4 у кожен модуль → 89 уроків A1, ~1000 слів.
-- Запускати ПІСЛЯ всіх чотирьох частин: 20261013_curriculum_a1_v2_part1.sql … _part4.sql.
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

-- нові уроки — ті, у яких діалоги з пакета curriculum_a1_v2
create temp view v2_lessons as
  select distinct c.lesson_id as id from public.conversations c where c.source = 'claude_curriculum_a1_v2';

-- ---------------------------------------------------------------- структура
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A1' and status = 'PUBLISHED'$q$) = 89,
  'A1: 89 опублікованих уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from v2_lessons$q$) = 40, '40 нових уроків з двома діалогами пакета v2');
select pg_temp.ok(pg_temp.n($q$select u.id from public.units u join public.modules m on m.id = u.module_id
  join public.lessons l on l.unit_id = u.id where m.level_code = 'A1'
  group by u.id having count(*) not between 8 and 9 or max(l.order_index) <> count(*) or min(l.order_index) <> 1$q$) = 0,
  'у кожному модулі A1 8–9 уроків, місця 1…N без пропусків');
select pg_temp.ok(pg_temp.n($q$select 1 from (
    select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where m.level_code = 'A1') t
  where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%'$q$) = 0,
  'назви уроків A1 пронумеровано підряд: «Урок 1» … «Урок 89»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_versions
  where entity_type = 'lesson' and change_reason like 'curriculum_a1_v2: новий номер уроку%'$q$) >= 40,
  'стара назва перенумерованих уроків збережена в content_versions');

-- ---------------------------------------------------------------- нові уроки
select pg_temp.ok(pg_temp.n($q$select 1 from v2_lessons v where
  (select count(*) from public.lesson_items i where i.lesson_id = v.id and i.item_type = 'lexeme') <> 14$q$) = 0,
  'у кожному новому уроці 14 слів');
select pg_temp.ok(pg_temp.n($q$select 1 from v2_lessons v where
  (select count(*) from public.lesson_items i where i.lesson_id = v.id and i.item_type = 'exercise') <> 12
  or not exists (select 1 from public.content_reviews r where r.entity_id = v.id and r.notes like '%curriculum_a1_v2%')$q$) = 0,
  'у кожному новому уроці 12 вправ і запис у журналі перевірок');
select pg_temp.ok(pg_temp.n($q$select x.id from v2_lessons v join public.lesson_items i on i.lesson_id = v.id and i.item_type = 'lexeme'
  join public.lexemes x on x.id = i.item_id group by x.id having count(*) > 1$q$) = 0,
  'слова нових уроків не повторюються між уроками');
select pg_temp.ok(pg_temp.n($q$select distinct i.item_id from public.lesson_items i join public.lessons l on l.id = i.lesson_id
  where l.level_code = 'A1' and i.item_type = 'lexeme'
  and i.item_id not in (select i0.item_id from public.lesson_items i0 join public.lessons l0 on l0.id = i0.lesson_id
                        where l0.level_code = 'A0' and i0.item_type = 'lexeme')$q$) >= 990,
  'в уроках A1 ≥ 990 слів, яких немає в уроках A0 (план ТЗ ~1000)');

-- ---------------------------------------------------------------- словник
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a1_v2'
  and status = 'PUBLISHED' and cefr = 'A1'$q$) = 305, '305 нових слів A1 опубліковано');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a1_v2'
  and (normalized <> translate(lower(lemma), 'čćđšž', 'ccdsz') or lemma ~ '[Ѐ-ӿ]'
       or ukrainian_translation !~ '[Ѐ-ӿ]' or jsonb_array_length(examples) <> 1)$q$) = 0,
  'нові слова: normalized без діакритики, лема латиницею, переклад українською, є приклад');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma in ('Kvačilo', 'Povodac', 'Obiteljski liječnik')
  or ukrainian_translation in ('екрані / дисплей', 'з''єднання', 'випікати, смажити')$q$) = 0,
  'виправлено kvačilo, povodac, obiteljski liječnik, ekran, spoj, peći');

-- ---------------------------------------------------------------- гість
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A1'$q$) = 89, 'гість бачить 89 уроків A1');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations where source = 'claude_curriculum_a1_v2'$q$) = 80,
  'гість бачить 80 нових діалогів');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
