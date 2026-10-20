-- =====================================================================
-- Тести: уроки A0 за темою (curriculum_a0_v4) · модуль A0.3 «Brojevi» · 2026-10-19
-- Запускати ПІСЛЯ supabase/data_fixes/20261019_curriculum_a0_v4_m03.sql.
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

-- уроки модуля A0.3 у новому порядку (id, місце)
create or replace function pg_temp.m3() returns table (lid uuid, o int) language sql as $$
  select * from (values ('c0941bd8-57b5-5e7e-981f-9be423f24208'::uuid, 1), ('e30c65f2-1a30-5b51-85e7-6a460cd1799f'::uuid, 2), ('ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'::uuid, 3), ('c0d7b467-acb2-581a-975b-497e63f45aa7'::uuid, 4), ('1f41cb75-1ce5-57ba-a56f-58561ee1d983'::uuid, 5), ('40f7c64a-ad42-5fe2-a230-7b1e98607112'::uuid, 6), ('ba35964d-f0d8-5d15-9566-ef44d37e6d12'::uuid, 7), ('22dd7878-4fa8-5e1c-909e-71c70ffd9918'::uuid, 8), ('4c5db9c0-aa58-55c5-b647-7f7cfc8396c2'::uuid, 9), ('427e5058-7381-58a0-8f21-bd170866dbae'::uuid, 10)) as t(lid, o)
$$;

-- ---------------------------------------------------------------- модуль і порядок
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where m.level_code = 'A0' and m.order_index = 3 and l.status = 'PUBLISHED'$q$) = 10, 'у модулі A0.3 — 10 опублікованих уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m3() t join public.lessons l on l.id = t.lid and l.order_index = t.o$q$) = 10,
  'уроки A0.3 стоять у новому порядку (5 наявних + 5 нових)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A0' and status = 'PUBLISHED'$q$) >= 56, 'A0: щонайменше 56 уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from (
    select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where l.level_code = 'A0' and l.status = 'PUBLISHED') t
  where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%'$q$) = 0,
  'назви уроків A0 пронумеровано підряд');
select pg_temp.ok((select title_ua from public.lessons where id = 'c0941bd8-57b5-5e7e-981f-9be423f24208') = 'Урок 14: Числа від 0 до 10'
  and (select title_ua from public.lessons where id = '427e5058-7381-58a0-8f21-bd170866dbae') = 'Урок 23: Скільки це коштує?', 'модуль A0.3 — уроки 14–23');

-- ---------------------------------------------------------------- склад уроків
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m3() v
  where (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'lexeme') not between 12 and 20$q$) = 0,
  'у кожному уроці 12–20 слів (числа — особливий модуль, рішення власника 2026-10-19)');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m3() v
  where (select count(*) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
     or (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'exercise') <> 15$q$) = 0,
  'у кожному уроці 15 опублікованих вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m3() v
  where (select count(distinct e.exercise_type) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise') < 6$q$) = 0, 'у кожному уроці всі 6 типів вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m3() v
  where (select count(*) from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source = 'claude_curriculum_a0_v4') <> 2
     or exists (select 1 from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source is distinct from 'claude_curriculum_a0_v4')
     or (select count(*) from public.conversation_turns t join public.conversations c on c.id = t.conversation_id
         where c.lesson_id = v.lid and c.status = 'PUBLISHED') not between 8 and 12$q$) = 0,
  'у кожному уроці 2 нові діалоги по 4–6 реплік, старі не показуються');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in (select lid from pg_temp.m3())
  and (estimated_minutes <> 15 or jsonb_array_length(objectives) < 2 or status <> 'PUBLISHED')$q$) = 0, 'урок — 15 хвилин, щонайменше 2 цілі');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m3() v
  where not exists (select 1 from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'grammar')
     or not exists (select 1 from public.lesson_grammar g where g.lesson_id = v.lid)$q$) = 0,
  'у кожному уроці є тема граматики (у «Скільки вам років?» і «Скільки це коштує?» додано «Числа 0–100»)');
select pg_temp.ok(pg_temp.n($q$select i.item_id from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m3()) and i.item_type = 'lexeme' group by 1 having count(*) > 1$q$) = 0,
  'жодне слово не повторюється в різних уроках модуля');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m3()) and i.item_type = 'lexeme'
    and i.item_id in (select i1.item_id from public.lesson_items i1 join public.lessons l on l.id = i1.lesson_id
                       join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                      where m.level_code = 'A0' and m.order_index in (1, 2) and i1.item_type = 'lexeme')$q$) = 0,
  'слова A0.3 не повторюють слів A0.1 і A0.2');

-- ---------------------------------------------------------------- числа повністю
select pg_temp.ok(pg_temp.n($q$select distinct lower(x.lemma) from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id in (select lid from pg_temp.m3()) and i.item_type = 'lexeme'
    and lower(x.lemma) in ('nula', 'jedan', 'dva', 'dvije', 'deset', 'jedanaest', 'devetnaest', 'dvadeset', 'trideset', 'devedeset', 'sto',
                           'dvjesto', 'tristo', 'četiristo', 'petsto', 'šesto', 'sedamsto', 'osamsto', 'devetsto', 'tisuća',
                           'milijun', 'milijarda')$q$) = 22,
  'у модулі всі опорні числа: 0–10, 11–19, десятки, сто, сотні 200–900, тисяча, мільйон, мільярд');
select pg_temp.ok(pg_temp.n($q$select distinct lower(x.lemma) from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id in (select lid from pg_temp.m3()) and i.item_type = 'lexeme'
    and lower(x.lemma) in ('prvi', 'drugi', 'treći', 'deseti', 'zadnji', 'plus', 'minus', 'puta', 'podijeljeno s', 'jednako',
                           'pola', 'trećina', 'četvrtina', 'posto', 'desetak', 'otprilike')$q$) = 16,
  'порядкові числа, арифметика, частини, відсотки й «приблизно»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id in ('427e5058-7381-58a0-8f21-bd170866dbae', '4c5db9c0-aa58-55c5-b647-7f7cfc8396c2') and i.item_type = 'lexeme' and lower(x.lemma) in ('kava', 'sok', 'kruh', 'pekara', 'pas')$q$) = 0,
  'уроки ціни й віку — без «кава», «сік», «хліб», «пекарня», «собака»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_topics g where g.id in ('79f431d7-62d7-59ca-b963-62893eb2209e', '6b94be82-6b25-5565-86d8-d4c0e429c627') and g.status = 'PUBLISHED' and g.cefr = 'A0'
  and (select count(*) from public.grammar_rules r where r.topic_id = g.id and jsonb_array_length(r.examples) >= 3) >= 3$q$) = 2,
  'дві нові теми граматики (великі числа, порядкові) з правилами й прикладами');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a0_v4' and status = 'PUBLISHED' and cefr = 'A0'
  and normalized !~ '[čćđšž]' and normalized = lower(normalized) and lemma !~ '[Ѐ-ӿ]' and ukrainian_translation ~ '[Ѐ-ӿ]'
  and jsonb_array_length(examples) = 1 and lower(lemma) in ('dvije', 'koliko vas je', 'pozivni broj', 'krivi broj', 'stotina', 'četiristo', 'šesto', 'sedamsto', 'osamsto', 'devetsto', 'kilometar', 'metar', 'gram', 'iznos', 'udaljenost', 'milijarda', 'stanovništvo', 'godišnje', 'dvadeseti', 'stoti', 'zadnji', 'redni broj', 'na redu', 'prvo', 'plus', 'minus', 'puta', 'podijeljeno s', 'jednako', 'koliko je', 'zbrojiti', 'oduzeti', 'pomnožiti', 'paran broj', 'neparan broj', 'kalkulator', 'desetak', 'dvadesetak', 'stotinjak', 'nekoliko', 'par', 'trećina', 'četvrtina', 'posto', 'najviše', 'koliko imaš godina', 'stariji', 'mlađi', 'godište', 'punoljetan', 'maloljetan', 'odrastao', 'ostatak')$q$) = 53,
  '53 нових слів і виразів A0.3: без кирилиці в лемі, normalized без діакритики, переклад і приклад');

-- ---------------------------------------------------------------- стара версія збережена
select pg_temp.ok(pg_temp.n($q$select 1 from (values ('c0941bd8-57b5-5e7e-981f-9be423f24208'::uuid), ('e30c65f2-1a30-5b51-85e7-6a460cd1799f'::uuid), ('ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'::uuid), ('4c5db9c0-aa58-55c5-b647-7f7cfc8396c2'::uuid), ('427e5058-7381-58a0-8f21-bd170866dbae'::uuid)) v(lid)
  where not exists (select 1 from public.content_versions cv where cv.entity_type = 'lesson' and cv.entity_id = v.lid
                    and cv.change_reason like 'curriculum_a0_v4: урок перебудовано%' and jsonb_array_length(cv.payload->'items') > 0)$q$) = 0,
  'стара версія кожного перебудованого уроку — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations c
  where c.id in (select jsonb_array_elements_text(v.payload->'conversations')::uuid from public.content_versions v
                 where v.change_reason like 'curriculum_a0_v4%' and v.entity_id in ('c0941bd8-57b5-5e7e-981f-9be423f24208', 'e30c65f2-1a30-5b51-85e7-6a460cd1799f', 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a', '4c5db9c0-aa58-55c5-b647-7f7cfc8396c2', '427e5058-7381-58a0-8f21-bd170866dbae'))
    and c.status <> 'DEPRECATED'$q$) = 0, 'старі діалоги — DEPRECATED (не видалені)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e
  where e.id in (select b.item_id from backup.lesson_items_20261015 b where b.item_type = 'exercise' and b.lesson_id in ('c0941bd8-57b5-5e7e-981f-9be423f24208', 'e30c65f2-1a30-5b51-85e7-6a460cd1799f', 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a', '4c5db9c0-aa58-55c5-b647-7f7cfc8396c2', '427e5058-7381-58a0-8f21-bd170866dbae'))
    and e.status <> 'DEPRECATED'$q$) = 0, 'старі вправи — DEPRECATED (не видалені)');

-- ---------------------------------------------------------------- видимість
set local role anon;
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations where source = 'claude_curriculum_a0_v4' and lesson_id in (select lid from pg_temp.m3())$q$) = 20,
  'гість бачить 20 нових діалогів A0.3');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in ('c0d7b467-acb2-581a-975b-497e63f45aa7', '1f41cb75-1ce5-57ba-a56f-58561ee1d983', '40f7c64a-ad42-5fe2-a230-7b1e98607112', 'ba35964d-f0d8-5d15-9566-ef44d37e6d12', '22dd7878-4fa8-5e1c-909e-71c70ffd9918')$q$) = 5, 'гість бачить 5 нових уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules where topic_id in ('79f431d7-62d7-59ca-b963-62893eb2209e', '6b94be82-6b25-5565-86d8-d4c0e429c627')$q$) = 8, 'гість бачить 8 нових правил граматики');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
