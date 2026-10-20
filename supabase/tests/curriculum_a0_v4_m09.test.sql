-- =====================================================================
-- Тести: уроки A0 за темою (curriculum_a0_v4) · модуль A0.9 «Grad» · 2026-10-19
-- Запускати ПІСЛЯ supabase/data_fixes/20261019_curriculum_a0_v4_m09.sql.
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

-- уроки модуля A0.9 у новому порядку (id, місце)
create or replace function pg_temp.m9() returns table (lid uuid, o int) language sql as $$
  select * from (values ('0addd5be-230b-582f-baed-a5d18eb1d619'::uuid, 1), ('55af257e-e4d1-51ed-9637-388a7e0b4baf'::uuid, 2), ('1e0384e5-6097-56ed-ab56-cf530f02ab73'::uuid, 3), ('e5b81eb1-8ea8-5ff4-a987-e5e46421302b'::uuid, 4), ('e0b9d742-0418-597b-9482-b6e2d82469da'::uuid, 5)) as t(lid, o)
$$;

-- ---------------------------------------------------------------- модуль і порядок
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where m.level_code = 'A0' and m.order_index = 9 and l.status = 'PUBLISHED'$q$) = 5, 'у модулі A0.9 — 5 опублікованих уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m9() t join public.lessons l on l.id = t.lid and l.order_index = t.o$q$) = 5,
  'уроки A0.9 стоять у новому порядку (5 наявних' || '' || ')');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A0' and status = 'PUBLISHED'$q$) >= 64, 'A0: щонайменше 64 уроки');
select pg_temp.ok(pg_temp.n($q$select 1 from (
    select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where l.level_code = 'A0' and l.status = 'PUBLISHED') t
  where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%'$q$) = 0,
  'назви уроків A0 пронумеровано підряд');
select pg_temp.ok((select title_ua from public.lessons where id = '0addd5be-230b-582f-baed-a5d18eb1d619') = 'Урок 55: Місця в місті'
  and (select title_ua from public.lessons where id = 'e0b9d742-0418-597b-9482-b6e2d82469da') = 'Урок 59: Таксі, авто чи велосипед?', 'модуль A0.9 — уроки 55–59');

-- ---------------------------------------------------------------- склад уроків
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m9() v
  where (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'lexeme') not between 20 and 25$q$) = 0,
  'у кожному уроці 20–25 слів і виразів');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m9() v
  where (select count(*) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
     or (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'exercise') <> 15$q$) = 0,
  'у кожному уроці 15 опублікованих вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m9() v
  where (select count(distinct e.exercise_type) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise') < 6$q$) = 0, 'у кожному уроці всі 6 типів вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m9() v
  where (select count(*) from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source = 'claude_curriculum_a0_v4') <> 2
     or exists (select 1 from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source is distinct from 'claude_curriculum_a0_v4')
     or (select count(*) from public.conversation_turns t join public.conversations c on c.id = t.conversation_id
         where c.lesson_id = v.lid and c.status = 'PUBLISHED') not between 8 and 12$q$) = 0,
  'у кожному уроці 2 нові діалоги по 4–6 реплік, старі не показуються');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in (select lid from pg_temp.m9())
  and (estimated_minutes <> 15 or jsonb_array_length(objectives) < 2 or status <> 'PUBLISHED')$q$) = 0, 'урок — 15 хвилин, щонайменше 2 цілі');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where m.level_code = 'A0' and m.order_index = 9 and l.id not in (select lid from pg_temp.m9())$q$) = 0, 'нових уроків у модулі немає — лише 5 перебудованих');
select pg_temp.ok(pg_temp.n($q$select i.item_id from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m9()) and i.item_type = 'lexeme' group by 1 having count(*) > 1$q$) = 0,
  'жодне слово не повторюється в різних уроках модуля');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m9()) and i.item_type = 'lexeme'
    and i.item_id in (select i1.item_id from public.lesson_items i1 join public.lessons l on l.id = i1.lesson_id
                       join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                      where m.level_code = 'A0' and m.order_index in (1, 2, 3, 4, 5, 6, 7, 8) and i1.item_type = 'lexeme')$q$) = 0,
  'слова A0.9 не повторюють слів A0.1–A0.8');

-- ---------------------------------------------------------------- тема модуля
select pg_temp.ok(pg_temp.n($q$select distinct lower(x.lemma) from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id in (select lid from pg_temp.m9()) and i.item_type = 'lexeme'
    and lower(x.lemma) in ('pošta', 'banka', 'trg', 'ravno', 'skrenuti', 'preko puta', 'katedrala', 'muzej', 'autobus', 'tramvaj',
                           'vlak', 'karta', 'taksi', 'bicikl', 'parkiralište')$q$) = 15,
  'у модулі місця в місті, дорога, пам’ятки, громадський транспорт, таксі й велосипед');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = '55af257e-e4d1-51ed-9637-388a7e0b4baf' and i.item_type = 'lexeme'
    and lower(x.lemma) in ('kako doći do', 'ravno', 'preko puta', 'skrenuti', 'raskrižje', 'semafor', 'do kraja ulice')$q$) = 7,
  'урок «Як пройти?» — показати дорогу: ravno, preko puta, skrenuti, raskrižje, do kraja ulice');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id in (select lid from pg_temp.m9()) and i.item_type = 'lexeme'
    and lower(x.lemma) in ('policija', 'ljekarna', 'hotel', 'lijevo', 'desno', 'daleko', 'ulica')$q$) = 0,
  'слова для A0.10 (policija, ljekarna, hotel) і вже вивчені (lijevo, desno, daleko, ulica) — не в A0.9');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a0_v4' and status = 'PUBLISHED' and cefr = 'A0'
  and normalized !~ '[čćđšž]' and normalized = lower(normalized) and lemma !~ '[Ѐ-ӿ]' and ukrainian_translation ~ '[Ѐ-ӿ]'
  and jsonb_array_length(examples) = 1 and lower(lemma) in ('zoološki vrt', 'naselje', 'u blizini', 'najbliži', 'kako doći do', 'do kraja ulice', 'nedaleko', 'koliko je daleko', 'stari grad', 'obilazak', 'fontana', 'karta grada', 'suvenir', 'mjesečna karta', 'presjesti', 'kontrolor')$q$) = 16,
  '16 нових слів і виразів A0.9: без кирилиці в лемі, normalized без діакритики, переклад і приклад');

-- ---------------------------------------------------------------- стара версія збережена
select pg_temp.ok(pg_temp.n($q$select 1 from (values ('0addd5be-230b-582f-baed-a5d18eb1d619'::uuid), ('55af257e-e4d1-51ed-9637-388a7e0b4baf'::uuid), ('1e0384e5-6097-56ed-ab56-cf530f02ab73'::uuid), ('e5b81eb1-8ea8-5ff4-a987-e5e46421302b'::uuid), ('e0b9d742-0418-597b-9482-b6e2d82469da'::uuid)) v(lid)
  where not exists (select 1 from public.content_versions cv where cv.entity_type = 'lesson' and cv.entity_id = v.lid
                    and cv.change_reason like 'curriculum_a0_v4: урок перебудовано%' and jsonb_array_length(cv.payload->'items') > 0)$q$) = 0,
  'стара версія кожного перебудованого уроку — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations c
  where c.id in (select jsonb_array_elements_text(v.payload->'conversations')::uuid from public.content_versions v
                 where v.change_reason like 'curriculum_a0_v4%' and v.entity_id in ('0addd5be-230b-582f-baed-a5d18eb1d619', '55af257e-e4d1-51ed-9637-388a7e0b4baf', '1e0384e5-6097-56ed-ab56-cf530f02ab73', 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b', 'e0b9d742-0418-597b-9482-b6e2d82469da'))
    and c.status <> 'DEPRECATED'$q$) = 0, 'старі діалоги — DEPRECATED (не видалені)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e
  where e.id in (select b.item_id from backup.lesson_items_20261015 b where b.item_type = 'exercise' and b.lesson_id in ('0addd5be-230b-582f-baed-a5d18eb1d619', '55af257e-e4d1-51ed-9637-388a7e0b4baf', '1e0384e5-6097-56ed-ab56-cf530f02ab73', 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b', 'e0b9d742-0418-597b-9482-b6e2d82469da'))
    and e.status <> 'DEPRECATED'$q$) = 0, 'старі вправи — DEPRECATED (не видалені)');

-- ---------------------------------------------------------------- видимість
set local role anon;
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations where source = 'claude_curriculum_a0_v4' and lesson_id in (select lid from pg_temp.m9())$q$) = 10,
  'гість бачить 10 нових діалогів A0.9');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
