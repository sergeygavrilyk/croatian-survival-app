-- =====================================================================
-- Тести: уроки A0 за темою (curriculum_a0_v4) · модуль A0.1 · 2026-10-15
-- Запускати ПІСЛЯ supabase/data_fixes/20261015_curriculum_a0_v4_m01.sql.
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

-- перебудовані уроки модуля A0.1 (за записом у журналі перевірки)
create or replace function pg_temp.v4() returns setof uuid language sql as $$
  select l.id from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 1
     and exists (select 1 from public.content_reviews r where r.entity_id = l.id and r.notes like '%curriculum_a0_v4%')
$$;

-- ---------------------------------------------------------------- склад уроків
select pg_temp.ok((select count(*) from pg_temp.v4()) = 4, 'усі 4 уроки модуля A0.1 перебудовано за темою');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.v4() v(lid)
  where (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'lexeme') not between 20 and 25$q$) = 0,
  'у кожному уроці 20–25 слів і виразів');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.v4() v(lid)
  where (select count(*) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
     or (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'exercise') <> 15$q$) = 0,
  'у кожному уроці 15 опублікованих вправ (старих посилань не лишилось)');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.v4() v(lid)
  where (select count(distinct e.exercise_type) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise') < 6$q$) = 0,
  'у кожному уроці всі 6 типів вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.v4() v(lid)
  where (select count(*) from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source = 'claude_curriculum_a0_v4') <> 2
     or exists (select 1 from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source is distinct from 'claude_curriculum_a0_v4')$q$) = 0,
  'у кожному уроці 2 нові діалоги, старі не показуються');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.v4() v(lid)
  where not exists (select 1 from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'grammar')
    and exists (select 1 from backup.lesson_items_20261015 b where b.lesson_id = v.lid and b.item_type = 'grammar')$q$) = 0,
  'тема граматики уроку збереглася');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in (select * from pg_temp.v4())
  and (estimated_minutes <> 15 or jsonb_array_length(objectives) < 2)$q$) = 0, 'урок — 15 хвилин, щонайменше 2 цілі');
select pg_temp.ok(pg_temp.n($q$select lesson_id, item_type, item_id from public.lesson_items
  where lesson_id in (select * from pg_temp.v4()) group by 1, 2, 3 having count(*) > 1$q$) = 0, 'у межах уроку нічого не повторюється');
select pg_temp.ok(pg_temp.n($q$select i.item_id from public.lesson_items i
  where i.lesson_id in (select * from pg_temp.v4()) and i.item_type = 'lexeme' group by 1 having count(*) > 1$q$) = 0,
  'жодне слово не повторюється в різних уроках модуля');

-- ---------------------------------------------------------------- слова за темою
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = 'd8cffb46-8a62-538a-b864-e227a6d8b863' and i.item_type = 'lexeme'
    and lower(x.lemma) in ('kava', 'ključ', 'soba', 'rezervacija', 'izvolite')$q$) = 0,
  'урок 2 «Добрий день і до побачення»: немає «кава», «ключ», «кімната», «бронювання»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b' and i.item_type = 'lexeme' and lower(x.lemma) = 'vrećica'$q$) = 0,
  'урок 3 «Вибачте, я не розумію»: немає «пакет»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = 'd8cffb46-8a62-538a-b864-e227a6d8b863' and i.item_type = 'lexeme'
    and lower(x.lemma) in ('dobro jutro', 'dobar dan', 'dobra večer', 'laku noć', 'doviđenja', 'vidimo se kasnije', 'do sutra')$q$) = 7,
  'урок 2: привітання протягом дня і прощання');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a0_v4' and status = 'PUBLISHED'
  and normalized !~ '[čćđšž]' and lemma !~ '[Ѐ-ӿ]' and ukrainian_translation ~ '[Ѐ-ӿ]' and jsonb_array_length(examples) = 1$q$) = 27,
  '27 нових слів і виразів: без кирилиці в лемі, normalized без діакритики, переклад і приклад');

-- ---------------------------------------------------------------- стара версія збережена
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.v4() v(lid)
  where not exists (select 1 from public.content_versions cv where cv.entity_type = 'lesson' and cv.entity_id = v.lid
                    and cv.change_reason like 'curriculum_a0_v4%' and jsonb_array_length(cv.payload->'items') > 0)$q$) = 0,
  'стара версія кожного уроку (кроки, діалоги) — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from backup.lesson_items_20261015 where lesson_id in (select * from pg_temp.v4())$q$) > 0,
  'копія старих кроків — у backup.lesson_items_20261015');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations c
  where c.id in (select jsonb_array_elements_text(v.payload->'conversations')::uuid from public.content_versions v
                 where v.change_reason like 'curriculum_a0_v4%')
    and c.status <> 'DEPRECATED'$q$) = 0, 'старі діалоги — DEPRECATED (не видалені)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e
  where e.id in (select b.item_id from backup.lesson_items_20261015 b where b.item_type = 'exercise')
    and e.status <> 'DEPRECATED'$q$) = 0, 'старі вправи — DEPRECATED (не видалені)');

-- ---------------------------------------------------------------- видимість
set local role anon;
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations where source = 'claude_curriculum_a0_v4'$q$) = 8,
  'гість бачить 8 нових діалогів');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations where status = 'DEPRECATED'$q$) = 0,
  'гість не бачить застарілих діалогів');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
