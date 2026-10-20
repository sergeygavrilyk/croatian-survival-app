-- =====================================================================
-- Тести: уроки A0 за темою (curriculum_a0_v4) · модуль A0.7 «Hrana» · 2026-10-19
-- Запускати ПІСЛЯ supabase/data_fixes/20261019_curriculum_a0_v4_m07.sql.
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

-- уроки модуля A0.7 у новому порядку (id, місце)
create or replace function pg_temp.m7() returns table (lid uuid, o int) language sql as $$
  select * from (values ('7bbaf7ff-10bb-512a-91c5-798b59ec92a5'::uuid, 1), ('c9e045fb-91ff-52a2-9916-1b698d30eb19'::uuid, 2), ('8b30911e-4e57-5648-9ff6-bd11c1b0e27e'::uuid, 3), ('77d640c4-4190-544a-8094-4e699f9a0a10'::uuid, 4), ('e6925fe5-e7fb-5594-9d3f-87fab1b5598d'::uuid, 5)) as t(lid, o)
$$;

-- ---------------------------------------------------------------- модуль і порядок
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where m.level_code = 'A0' and m.order_index = 7 and l.status = 'PUBLISHED'$q$) = 5, 'у модулі A0.7 — 5 опублікованих уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m7() t join public.lessons l on l.id = t.lid and l.order_index = t.o$q$) = 5,
  'уроки A0.7 стоять у новому порядку (5 наявних' || '' || ')');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A0' and status = 'PUBLISHED'$q$) >= 63, 'A0: щонайменше 63 уроки');
select pg_temp.ok(pg_temp.n($q$select 1 from (
    select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where l.level_code = 'A0' and l.status = 'PUBLISHED') t
  where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%'$q$) = 0,
  'назви уроків A0 пронумеровано підряд');
select pg_temp.ok((select title_ua from public.lessons where id = '7bbaf7ff-10bb-512a-91c5-798b59ec92a5') = 'Урок 44: Я голодний'
  and (select title_ua from public.lessons where id = 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d') = 'Урок 48: Що на вечерю?', 'модуль A0.7 — уроки 44–48');

-- ---------------------------------------------------------------- склад уроків
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m7() v
  where (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'lexeme') not between 20 and 25$q$) = 0,
  'у кожному уроці 20–25 слів і виразів');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m7() v
  where (select count(*) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
     or (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'exercise') <> 15$q$) = 0,
  'у кожному уроці 15 опублікованих вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m7() v
  where (select count(distinct e.exercise_type) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise') < 6$q$) = 0, 'у кожному уроці всі 6 типів вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m7() v
  where (select count(*) from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source = 'claude_curriculum_a0_v4') <> 2
     or exists (select 1 from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source is distinct from 'claude_curriculum_a0_v4')
     or (select count(*) from public.conversation_turns t join public.conversations c on c.id = t.conversation_id
         where c.lesson_id = v.lid and c.status = 'PUBLISHED') not between 8 and 12$q$) = 0,
  'у кожному уроці 2 нові діалоги по 4–6 реплік, старі не показуються');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in (select lid from pg_temp.m7())
  and (estimated_minutes <> 15 or jsonb_array_length(objectives) < 2 or status <> 'PUBLISHED')$q$) = 0, 'урок — 15 хвилин, щонайменше 2 цілі');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where m.level_code = 'A0' and m.order_index = 7 and l.id not in (select lid from pg_temp.m7())$q$) = 0, 'нових уроків у модулі немає — лише 5 перебудованих');
select pg_temp.ok(pg_temp.n($q$select i.item_id from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m7()) and i.item_type = 'lexeme' group by 1 having count(*) > 1$q$) = 0,
  'жодне слово не повторюється в різних уроках модуля');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m7()) and i.item_type = 'lexeme'
    and i.item_id in (select i1.item_id from public.lesson_items i1 join public.lessons l on l.id = i1.lesson_id
                       join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                      where m.level_code = 'A0' and m.order_index in (1, 2, 3, 4, 5, 6) and i1.item_type = 'lexeme')$q$) = 0,
  'слова A0.7 не повторюють слів A0.1–A0.6');

-- ---------------------------------------------------------------- тема модуля
select pg_temp.ok(pg_temp.n($q$select distinct lower(x.lemma) from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id in (select lid from pg_temp.m7()) and i.item_type = 'lexeme'
    and lower(x.lemma) in ('gladan', 'doručak', 'ručak', 'večera', 'kruh', 'kava', 'čaj', 'jelovnik', 'molim račun', 'napojnica',
                           'voda', 'pivo', 'vino', 'meso', 'riba')$q$) = 15,
  'у модулі прийоми їжі, кафе, меню, рахунок, напої, м’ясо й риба');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d' and i.item_type = 'lexeme'
    and lower(x.lemma) in ('slan', 'sladak', 'kiseo', 'gorak', 'pikantan', 'ukusan', 'okus')$q$) = 7,
  'урок «Що на вечерю?»: смаки — солоний, солодкий, кислий, гіркий, гострий');
select pg_temp.ok((select ukrainian_translation from public.lexemes where lower(lemma) = 'ljut') = 'злий, сердитий; гострий (про їжу)'
  and pg_temp.n($q$select 1 from public.content_versions v join public.lexemes x on x.id = v.entity_id
                  where v.entity_type = 'lexeme' and lower(x.lemma) = 'ljut' and v.payload->>'ukrainian_translation' = 'злий / сердитий'$q$) >= 1,
  'ljut: переклад «гострий (про їжу)» додано, стара версія — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id in (select lid from pg_temp.m7()) and i.item_type = 'lexeme' and lower(x.lemma) = 'ljut'$q$) = 0,
  'ljut («злий») більше не в уроці про їжу — він в уроці емоцій A0.2');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a0_v4' and status = 'PUBLISHED' and cefr = 'A0'
  and normalized !~ '[čćđšž]' and normalized = lower(normalized) and lemma !~ '[Ѐ-ӿ]' and ukrainian_translation ~ '[Ѐ-ӿ]'
  and jsonb_array_length(examples) = 1 and lower(lemma) in ('sit', 'obrok', 'džem', 'bijela kava', 'torta', 'kroasan', 'kuglica', 'šlag', 'što želite', 'za van', 'još jedan', 'stol za dvoje', 'zajedno ili odvojeno', 'častiti', 'izvrstan', 'gazirani sok', 'crno vino', 'bijelo vino', 'gemišt', 'bevanda', 'bezalkoholno piće', 'slamka', 'lignje', 'škampi', 'na žaru', 'pržen', 'gorak', 'pikantan')$q$) = 28,
  '28 нових слів і виразів A0.7: без кирилиці в лемі, normalized без діакритики, переклад і приклад');

-- ---------------------------------------------------------------- стара версія збережена
select pg_temp.ok(pg_temp.n($q$select 1 from (values ('7bbaf7ff-10bb-512a-91c5-798b59ec92a5'::uuid), ('c9e045fb-91ff-52a2-9916-1b698d30eb19'::uuid), ('8b30911e-4e57-5648-9ff6-bd11c1b0e27e'::uuid), ('77d640c4-4190-544a-8094-4e699f9a0a10'::uuid), ('e6925fe5-e7fb-5594-9d3f-87fab1b5598d'::uuid)) v(lid)
  where not exists (select 1 from public.content_versions cv where cv.entity_type = 'lesson' and cv.entity_id = v.lid
                    and cv.change_reason like 'curriculum_a0_v4: урок перебудовано%' and jsonb_array_length(cv.payload->'items') > 0)$q$) = 0,
  'стара версія кожного перебудованого уроку — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations c
  where c.id in (select jsonb_array_elements_text(v.payload->'conversations')::uuid from public.content_versions v
                 where v.change_reason like 'curriculum_a0_v4%' and v.entity_id in ('7bbaf7ff-10bb-512a-91c5-798b59ec92a5', 'c9e045fb-91ff-52a2-9916-1b698d30eb19', '8b30911e-4e57-5648-9ff6-bd11c1b0e27e', '77d640c4-4190-544a-8094-4e699f9a0a10', 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d'))
    and c.status <> 'DEPRECATED'$q$) = 0, 'старі діалоги — DEPRECATED (не видалені)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e
  where e.id in (select b.item_id from backup.lesson_items_20261015 b where b.item_type = 'exercise' and b.lesson_id in ('7bbaf7ff-10bb-512a-91c5-798b59ec92a5', 'c9e045fb-91ff-52a2-9916-1b698d30eb19', '8b30911e-4e57-5648-9ff6-bd11c1b0e27e', '77d640c4-4190-544a-8094-4e699f9a0a10', 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d'))
    and e.status <> 'DEPRECATED'$q$) = 0, 'старі вправи — DEPRECATED (не видалені)');

-- ---------------------------------------------------------------- видимість
set local role anon;
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations where source = 'claude_curriculum_a0_v4' and lesson_id in (select lid from pg_temp.m7())$q$) = 10,
  'гість бачить 10 нових діалогів A0.7');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
