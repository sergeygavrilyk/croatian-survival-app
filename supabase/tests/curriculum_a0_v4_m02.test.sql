-- =====================================================================
-- Тести: уроки A0 за темою (curriculum_a0_v4) · модуль A0.2 «Ja sam…» · 2026-10-19
-- Запускати ПІСЛЯ supabase/data_fixes/20261019_curriculum_a0_v4_m02.sql, 20261019_assessments_a0_v4.sql
-- і 20261019_reading_known_a0v4_part1…3.sql.
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

-- уроки модуля A0.2 у новому порядку (id, місце)
create or replace function pg_temp.m2() returns table (lid uuid, o int) language sql as $$
  select * from (values ('2b6ed342-cc80-5bd9-baf0-b66109624d62'::uuid, 1), ('8abb83d8-ec02-5921-ac9b-814489816fcd'::uuid, 2), ('8f6439a9-c6ac-5271-99c8-1f0adc5d7599'::uuid, 3), ('04167753-db83-5163-a91c-9f71dac18ab5'::uuid, 4), ('479784bc-54ab-522d-9c77-55887ae68e33'::uuid, 5), ('a9944193-2dfb-5944-b94c-41c41fdb7ca1'::uuid, 6), ('adf335ee-0cba-5c9a-b86a-8baac868edbc'::uuid, 7), ('2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'::uuid, 8), ('3b51b1bf-47f4-5709-96d9-c518d36440e6'::uuid, 9)) as t(lid, o)
$$;

-- ---------------------------------------------------------------- модуль і порядок
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where m.level_code = 'A0' and m.order_index = 2 and l.status = 'PUBLISHED'$q$) = 9, 'у модулі A0.2 — 9 опублікованих уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m2() t join public.lessons l on l.id = t.lid and l.order_index = t.o$q$) = 9,
  'уроки A0.2 стоять у новому порядку (5 наявних + 4 нові)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A0' and status = 'PUBLISHED'$q$) >= 51, 'A0: щонайменше 51 опублікований урок (далі модулі додають уроки)');
select pg_temp.ok(pg_temp.n($q$select 1 from (
    select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where l.level_code = 'A0' and l.status = 'PUBLISHED') t
  where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%'$q$) = 0,
  'назви уроків A0 пронумеровано підряд');
select pg_temp.ok((select title_ua from public.lessons where id = '3b51b1bf-47f4-5709-96d9-c518d36440e6') = 'Урок 13: Як ви почуваєтеся?',
  'останній урок модуля — «Урок 13: Як ви почуваєтеся?»');

-- ---------------------------------------------------------------- склад уроків
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m2() v
  where (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'lexeme') not between 20 and 25$q$) = 0,
  'у кожному уроці 20–25 слів і виразів');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m2() v
  where (select count(*) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
     or (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'exercise') <> 15$q$) = 0,
  'у кожному уроці 15 опублікованих вправ (старих посилань не лишилось)');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m2() v
  where (select count(distinct e.exercise_type) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise') < 6$q$) = 0,
  'у кожному уроці всі 6 типів вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m2() v
  where (select count(*) from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source = 'claude_curriculum_a0_v4') <> 2
     or exists (select 1 from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source is distinct from 'claude_curriculum_a0_v4')$q$) = 0,
  'у кожному уроці 2 нові діалоги, старі не показуються');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m2() v
  where (select count(*) from public.conversation_turns t join public.conversations c on c.id = t.conversation_id
         where c.lesson_id = v.lid and c.status = 'PUBLISHED') not between 8 and 12$q$) = 0,
  'у діалогах уроку 8–12 реплік (2 × 4–6)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in (select lid from pg_temp.m2())
  and (estimated_minutes <> 15 or jsonb_array_length(objectives) < 2 or status <> 'PUBLISHED')$q$) = 0,
  'урок — 15 хвилин, щонайменше 2 цілі, опубліковано');
select pg_temp.ok(pg_temp.n($q$select i.item_id from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m2()) and i.item_type = 'lexeme' group by 1 having count(*) > 1$q$) = 0,
  'жодне слово не повторюється в різних уроках модуля');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m2()) and i.item_type = 'lexeme'
    and i.item_id in (select i1.item_id from public.lesson_items i1 join public.lessons l on l.id = i1.lesson_id
                       join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                      where m.level_code = 'A0' and m.order_index = 1 and i1.item_type = 'lexeme')$q$) = 0,
  'слова A0.2 не повторюють слів A0.1');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m2() v
  where not exists (select 1 from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'grammar')
    and (exists (select 1 from backup.lesson_items_20261015 b where b.lesson_id = v.lid and b.item_type = 'grammar')
         or v.lid in ('8abb83d8-ec02-5921-ac9b-814489816fcd', '8f6439a9-c6ac-5271-99c8-1f0adc5d7599', '479784bc-54ab-522d-9c77-55887ae68e33', '3b51b1bf-47f4-5709-96d9-c518d36440e6'))$q$) = 0,
  'тема граматики наявного уроку збереглася; у нових уроках вона є');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_grammar where lesson_id in ('8abb83d8-ec02-5921-ac9b-814489816fcd', '8f6439a9-c6ac-5271-99c8-1f0adc5d7599', '479784bc-54ab-522d-9c77-55887ae68e33', '3b51b1bf-47f4-5709-96d9-c518d36440e6')$q$) = 4,
  'нові уроки мають тему граматики (lesson_grammar)');

-- ---------------------------------------------------------------- слова за темою
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = '2b6ed342-cc80-5bd9-baf0-b66109624d62' and i.item_type = 'lexeme' and lower(x.lemma) in ('bok', 'ja', 'ti', 'vi')$q$) = 0,
  'урок 5 «Як тебе звати?»: без «bok» (є в A0.1) і займенників (окремий урок)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = 'adf335ee-0cba-5c9a-b86a-8baac868edbc' and i.item_type = 'lexeme' and lower(x.lemma) in ('tisuća', 'drag', 'susjed')$q$) = 0,
  'урок 11 «Де ви живете?»: без «тисяча», «дорогий»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b' and i.item_type = 'lexeme' and lower(x.lemma) in ('škola', 'odlično', 'hrvatski', 'učiti')$q$) = 0,
  'урок 12 «Ким ви працюєте?»: без «школа», «відмінно», «хорватська»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a0_v4' and status = 'PUBLISHED' and cefr = 'A0'
  and normalized !~ '[čćđšž]' and normalized = lower(normalized) and lemma !~ '[Ѐ-ӿ]' and ukrainian_translation ~ '[Ѐ-ӿ]'
  and jsonb_array_length(examples) = 1 and lower(lemma) in ('nadimak', 'gospođica', 'posjetnica', 'upoznavanje', 'kako ste rekli', 'i meni', 'ovo je', 'susjeda', 'svi', 'kakav', 'je li', 'od kada', 'do kada', 'koliko dugo', 'što je to', 'odakle si', 'rodom', 'rođen', 'rodni grad', 'preseliti se', 'kontinent', 'europa', 'azija', 'afrika', 'amerika', 'australija', 'poljska', 'italija', 'austrija', 'slovenija', 'mađarska', 'srbija', 'bosna i hercegovina', 'francuska', 'španjolska', 'narodnost', 'strankinja', 'materinski jezik', 'tečno', 'na hrvatskom', 'gdje živite', 'prizemlje', 'predgrađe', 'stanovati', 'podstanar', 'čime se bavite', 'prodavačica', 'frizer', 'kako se osjećaš', 'veseo', 'pospan', 'dosadno mi je', 'hladno mi je', 'loše mi je', 'strah me je', 'nedostaje mi', 'bolje', 'boli me glava')$q$) = 58,
  '58 нових слів і виразів A0.2: без кирилиці в лемі, normalized без діакритики, переклад і приклад');

-- ---------------------------------------------------------------- стара версія збережена
select pg_temp.ok(pg_temp.n($q$select 1 from (values ('2b6ed342-cc80-5bd9-baf0-b66109624d62'::uuid), ('04167753-db83-5163-a91c-9f71dac18ab5'::uuid), ('a9944193-2dfb-5944-b94c-41c41fdb7ca1'::uuid), ('adf335ee-0cba-5c9a-b86a-8baac868edbc'::uuid), ('2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'::uuid)) v(lid)
  where not exists (select 1 from public.content_versions cv where cv.entity_type = 'lesson' and cv.entity_id = v.lid
                    and cv.change_reason like 'curriculum_a0_v4: урок перебудовано%' and jsonb_array_length(cv.payload->'items') > 0)$q$) = 0,
  'стара версія кожного перебудованого уроку (кроки, діалоги, місце) — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from backup.lesson_items_20261015 where lesson_id in ('2b6ed342-cc80-5bd9-baf0-b66109624d62', '04167753-db83-5163-a91c-9f71dac18ab5', 'a9944193-2dfb-5944-b94c-41c41fdb7ca1', 'adf335ee-0cba-5c9a-b86a-8baac868edbc', '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b')$q$) > 0,
  'копія старих кроків — у backup.lesson_items_20261015');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations c
  where c.id in (select jsonb_array_elements_text(v.payload->'conversations')::uuid from public.content_versions v
                 where v.change_reason like 'curriculum_a0_v4%' and v.entity_id in ('2b6ed342-cc80-5bd9-baf0-b66109624d62', '04167753-db83-5163-a91c-9f71dac18ab5', 'a9944193-2dfb-5944-b94c-41c41fdb7ca1', 'adf335ee-0cba-5c9a-b86a-8baac868edbc', '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'))
    and c.status <> 'DEPRECATED'$q$) = 0, 'старі діалоги — DEPRECATED (не видалені)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e
  where e.id in (select b.item_id from backup.lesson_items_20261015 b where b.item_type = 'exercise' and b.lesson_id in ('2b6ed342-cc80-5bd9-baf0-b66109624d62', '04167753-db83-5163-a91c-9f71dac18ab5', 'a9944193-2dfb-5944-b94c-41c41fdb7ca1', 'adf335ee-0cba-5c9a-b86a-8baac868edbc', '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'))
    and e.status <> 'DEPRECATED'$q$) = 0, 'старі вправи — DEPRECATED (не видалені)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_versions where entity_type = 'lesson' and change_reason like 'curriculum_a0_v4: новий номер уроку%'$q$) >= 38,
  'старі назви перенумерованих уроків (14–51) — у content_versions');

-- ---------------------------------------------------------------- перевірки модулів і читання
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments a join public.assessment_items i on i.assessment_id = a.id
  where a.slug in ('a0-m01', 'a0-m02') and i.status = 'PUBLISHED'$q$) = 20, 'перевірки модулів A0.1 і A0.2 — по 10 опублікованих завдань');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments a join public.assessment_items i on i.assessment_id = a.id
  where a.slug = 'a0-m02' and i.status = 'PUBLISHED' and i.lesson_id is not null
    and i.lesson_id not in (select lid from pg_temp.m2())$q$) = 0, 'завдання перевірки A0.2 — з уроків модуля A0.2');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments a join public.assessment_items i on i.assessment_id = a.id
  where a.slug in ('a0-m01', 'a0-m02') and i.status = 'PUBLISHED' and i.lesson_id is not null
    and not exists (select 1 from public.lessons l where l.id = i.lesson_id and l.status = 'PUBLISHED')$q$) = 0,
  'завдання перевірок посилаються на опубліковані уроки');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments a join public.assessment_items i on i.assessment_id = a.id
  where a.slug in ('a0-m01', 'a0-m02') and i.status = 'DEPRECATED'$q$) = 20, 'старі завдання перевірок — DEPRECATED (не видалені)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r
  where exists (select 1 from jsonb_array_elements(r.glossary) e where e->>'lemma' = 'biti' and (e->>'lesson')::boolean)$q$) > 0,
  'читання: форми «biti» (je, sam…) тепер позначено як слово з уроків');

-- ---------------------------------------------------------------- видимість
set local role anon;
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations where source = 'claude_curriculum_a0_v4' and lesson_id in (select lid from pg_temp.m2())$q$) = 18,
  'гість бачить 18 нових діалогів A0.2');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in ('8abb83d8-ec02-5921-ac9b-814489816fcd', '8f6439a9-c6ac-5271-99c8-1f0adc5d7599', '479784bc-54ab-522d-9c77-55887ae68e33', '3b51b1bf-47f4-5709-96d9-c518d36440e6')$q$) = 4, 'гість бачить 4 нові уроки');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
