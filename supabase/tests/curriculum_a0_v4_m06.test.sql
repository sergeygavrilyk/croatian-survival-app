-- =====================================================================
-- Тести: уроки A0 за темою (curriculum_a0_v4) · модуль A0.6 «Moj dom» · 2026-10-19
-- Запускати ПІСЛЯ supabase/data_fixes/20261019_curriculum_a0_v4_m06.sql.
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

-- уроки модуля A0.6 у новому порядку (id, місце)
create or replace function pg_temp.m6() returns table (lid uuid, o int) language sql as $$
  select * from (values ('78f28f85-dd8b-5e81-8a52-1b2dbce4eb34'::uuid, 1), ('1436c20e-0aea-550a-b66d-fb3149a1c2e2'::uuid, 2), ('32f5d97b-d6c0-57af-9e48-86f9ee9a932d'::uuid, 3), ('0ecb6f19-2630-533d-9f1b-85102442af08'::uuid, 4), ('e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9'::uuid, 5), ('f51692d8-cb95-5f2e-8263-f3728f5e10c0'::uuid, 6)) as t(lid, o)
$$;

-- ---------------------------------------------------------------- модуль і порядок
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where m.level_code = 'A0' and m.order_index = 6 and l.status = 'PUBLISHED'$q$) = 6, 'у модулі A0.6 — 6 опублікованих уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m6() t join public.lessons l on l.id = t.lid and l.order_index = t.o$q$) = 6,
  'уроки A0.6 стоять у новому порядку (4 наявні + 2 нові)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A0' and status = 'PUBLISHED'$q$) >= 63, 'A0: щонайменше 63 уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from (
    select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where l.level_code = 'A0' and l.status = 'PUBLISHED') t
  where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%'$q$) = 0,
  'назви уроків A0 пронумеровано підряд');
select pg_temp.ok((select title_ua from public.lessons where id = '78f28f85-dd8b-5e81-8a52-1b2dbce4eb34') = 'Урок 38: Моя квартира'
  and (select title_ua from public.lessons where id = 'f51692d8-cb95-5f2e-8263-f3728f5e10c0') = 'Урок 43: Велике й маленьке', 'модуль A0.6 — уроки 38–43');

-- ---------------------------------------------------------------- склад уроків
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m6() v
  where (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'lexeme') not between 20 and 25$q$) = 0,
  'у кожному уроці 20–25 слів і виразів');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m6() v
  where (select count(*) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
     or (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'exercise') <> 15$q$) = 0,
  'у кожному уроці 15 опублікованих вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m6() v
  where (select count(distinct e.exercise_type) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise') < 6$q$) = 0, 'у кожному уроці всі 6 типів вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m6() v
  where (select count(*) from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source = 'claude_curriculum_a0_v4') <> 2
     or exists (select 1 from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source is distinct from 'claude_curriculum_a0_v4')
     or (select count(*) from public.conversation_turns t join public.conversations c on c.id = t.conversation_id
         where c.lesson_id = v.lid and c.status = 'PUBLISHED') not between 8 and 12$q$) = 0,
  'у кожному уроці 2 нові діалоги по 4–6 реплік, старі не показуються');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in (select lid from pg_temp.m6())
  and (estimated_minutes <> 15 or jsonb_array_length(objectives) < 2 or status <> 'PUBLISHED')$q$) = 0, 'урок — 15 хвилин, щонайменше 2 цілі');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i
  where i.lesson_id in ('32f5d97b-d6c0-57af-9e48-86f9ee9a932d', 'f51692d8-cb95-5f2e-8263-f3728f5e10c0') and i.item_type = 'grammar'$q$) = 2
  and pg_temp.n($q$select 1 from public.lesson_grammar g where g.lesson_id in ('32f5d97b-d6c0-57af-9e48-86f9ee9a932d', 'f51692d8-cb95-5f2e-8263-f3728f5e10c0')$q$) = 2,
  'кожен новий урок має тему граматики');
select pg_temp.ok(pg_temp.n($q$select i.item_id from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m6()) and i.item_type = 'lexeme' group by 1 having count(*) > 1$q$) = 0,
  'жодне слово не повторюється в різних уроках модуля');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m6()) and i.item_type = 'lexeme'
    and i.item_id in (select i1.item_id from public.lesson_items i1 join public.lessons l on l.id = i1.lesson_id
                       join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                      where m.level_code = 'A0' and m.order_index in (1, 2, 3, 4, 5) and i1.item_type = 'lexeme')$q$) = 0,
  'слова A0.6 не повторюють слів A0.1–A0.5');

-- ---------------------------------------------------------------- тема модуля
select pg_temp.ok(pg_temp.n($q$select distinct lower(x.lemma) from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id in (select lid from pg_temp.m6()) and i.item_type = 'lexeme'
    and lower(x.lemma) in ('stan', 'soba', 'kuhinja', 'kupaonica', 'spavaća soba', 'najamnina', 'režije', 'krevet', 'stol', 'ormar',
                           'ključ', 'vrata', 'prozor', 'hladnjak', 'perilica')$q$) = 15,
  'у модулі кімнати, оренда, меблі, ключі, двері, вікна, техніка');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = '32f5d97b-d6c0-57af-9e48-86f9ee9a932d' and i.item_type = 'lexeme'
    and lower(x.lemma) in ('ispod', 'iznad', 'pored', 'ispred', 'iza', 'između', 'lijevo', 'desno', 'gore', 'dolje')$q$) = 10,
  'урок «Прийменники місця»: під, над, поруч, перед, за, між, ліворуч, праворуч, нагорі, унизу');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = 'f51692d8-cb95-5f2e-8263-f3728f5e10c0' and i.item_type = 'lexeme'
    and lower(x.lemma) in ('velik', 'mali', 'čist', 'prljav', 'težak', 'lagan', 'svijetao', 'taman', 'pun', 'prazan')$q$) = 10,
  'урок «Велике й маленьке»: пари протилежностей');

select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_grammar lg join public.grammar_topics g on g.id = lg.grammar_topic_id
  where (lg.lesson_id = '32f5d97b-d6c0-57af-9e48-86f9ee9a932d' and g.title_ua = 'Де? Прийменники місця')
     or (lg.lesson_id = 'f51692d8-cb95-5f2e-8263-f3728f5e10c0' and g.title_ua = 'Прикметники: узгодження з іменником')$q$) = 2,
  'нові уроки: прийменники місця — «Де? Прийменники місця», протилежності — узгодження прикметника');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a0_v4' and status = 'PUBLISHED' and cefr = 'A0'
  and normalized !~ '[čćđšž]' and normalized = lower(normalized) and lemma !~ '[Ѐ-ӿ]' and ukrainian_translation ~ '[Ѐ-ӿ]'
  and jsonb_array_length(examples) = 1 and lower(lemma) in ('unajmiti', 'kvadrat', 'dvosoban stan', 'garsonijera', 'kaucija', 'noćni ormarić', 'radni stol', 'uz', 'u kutu', 'na vrhu', 'na dnu', 'na sredini', 'daljinski upravljač', 'glačalo', 'bojler', 'topla voda', 'glasan')$q$) = 17,
  '17 нових слів і виразів A0.6: без кирилиці в лемі, normalized без діакритики, переклад і приклад');

-- ---------------------------------------------------------------- стара версія збережена
select pg_temp.ok(pg_temp.n($q$select 1 from (values ('78f28f85-dd8b-5e81-8a52-1b2dbce4eb34'::uuid), ('1436c20e-0aea-550a-b66d-fb3149a1c2e2'::uuid), ('0ecb6f19-2630-533d-9f1b-85102442af08'::uuid), ('e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9'::uuid)) v(lid)
  where not exists (select 1 from public.content_versions cv where cv.entity_type = 'lesson' and cv.entity_id = v.lid
                    and cv.change_reason like 'curriculum_a0_v4: урок перебудовано%' and jsonb_array_length(cv.payload->'items') > 0)$q$) = 0,
  'стара версія кожного перебудованого уроку — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations c
  where c.id in (select jsonb_array_elements_text(v.payload->'conversations')::uuid from public.content_versions v
                 where v.change_reason like 'curriculum_a0_v4%' and v.entity_id in ('78f28f85-dd8b-5e81-8a52-1b2dbce4eb34', '1436c20e-0aea-550a-b66d-fb3149a1c2e2', '0ecb6f19-2630-533d-9f1b-85102442af08', 'e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9'))
    and c.status <> 'DEPRECATED'$q$) = 0, 'старі діалоги — DEPRECATED (не видалені)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e
  where e.id in (select b.item_id from backup.lesson_items_20261015 b where b.item_type = 'exercise' and b.lesson_id in ('78f28f85-dd8b-5e81-8a52-1b2dbce4eb34', '1436c20e-0aea-550a-b66d-fb3149a1c2e2', '0ecb6f19-2630-533d-9f1b-85102442af08', 'e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9'))
    and e.status <> 'DEPRECATED'$q$) = 0, 'старі вправи — DEPRECATED (не видалені)');

-- ---------------------------------------------------------------- видимість
set local role anon;
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations where source = 'claude_curriculum_a0_v4' and lesson_id in (select lid from pg_temp.m6())$q$) = 12,
  'гість бачить 12 нових діалогів A0.6');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in ('32f5d97b-d6c0-57af-9e48-86f9ee9a932d', 'f51692d8-cb95-5f2e-8263-f3728f5e10c0')$q$) = 2, 'гість бачить 2 нові уроки');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
