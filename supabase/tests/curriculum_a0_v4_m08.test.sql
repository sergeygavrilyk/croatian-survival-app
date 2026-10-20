-- =====================================================================
-- Тести: уроки A0 за темою (curriculum_a0_v4) · модуль A0.8 «Kupovina» · 2026-10-19
-- Запускати ПІСЛЯ supabase/data_fixes/20261019_curriculum_a0_v4_m08.sql.
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

-- уроки модуля A0.8 у новому порядку (id, місце)
create or replace function pg_temp.m8() returns table (lid uuid, o int) language sql as $$
  select * from (values ('e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0'::uuid, 1), ('0e925295-2766-5931-b031-2412682bc6f8'::uuid, 2), ('28913ad6-490f-5d89-bad7-9b303c673fcd'::uuid, 3), ('b01e2f67-3e7a-5ab6-99bb-fae374f431e0'::uuid, 4), ('288e7610-99c8-5696-989a-86f60ce38b0a'::uuid, 5), ('6836e57c-030c-59f8-9818-b44c08b126a6'::uuid, 6)) as t(lid, o)
$$;

-- ---------------------------------------------------------------- модуль і порядок
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where m.level_code = 'A0' and m.order_index = 8 and l.status = 'PUBLISHED'$q$) = 6, 'у модулі A0.8 — 6 опублікованих уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m8() t join public.lessons l on l.id = t.lid and l.order_index = t.o$q$) = 6,
  'уроки A0.8 стоять у новому порядку (5 наявних' || ' + 1 новий' || ')');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A0' and status = 'PUBLISHED'$q$) >= 64, 'A0: щонайменше 64 уроки');
select pg_temp.ok(pg_temp.n($q$select 1 from (
    select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where l.level_code = 'A0' and l.status = 'PUBLISHED') t
  where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%'$q$) = 0,
  'назви уроків A0 пронумеровано підряд');
select pg_temp.ok((select title_ua from public.lessons where id = 'e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0') = 'Урок 49: На ринку'
  and (select title_ua from public.lessons where id = '6836e57c-030c-59f8-9818-b44c08b126a6') = 'Урок 54: Можна дешевше?', 'модуль A0.8 — уроки 49–54');

-- ---------------------------------------------------------------- склад уроків
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m8() v
  where (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'lexeme') not between 20 and 25$q$) = 0,
  'у кожному уроці 20–25 слів і виразів');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m8() v
  where (select count(*) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
     or (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'exercise') <> 15$q$) = 0,
  'у кожному уроці 15 опублікованих вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m8() v
  where (select count(distinct e.exercise_type) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise') < 6$q$) = 0, 'у кожному уроці всі 6 типів вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m8() v
  where (select count(*) from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source = 'claude_curriculum_a0_v4') <> 2
     or exists (select 1 from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source is distinct from 'claude_curriculum_a0_v4')
     or (select count(*) from public.conversation_turns t join public.conversations c on c.id = t.conversation_id
         where c.lesson_id = v.lid and c.status = 'PUBLISHED') not between 8 and 12$q$) = 0,
  'у кожному уроці 2 нові діалоги по 4–6 реплік, старі не показуються');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in (select lid from pg_temp.m8())
  and (estimated_minutes <> 15 or jsonb_array_length(objectives) < 2 or status <> 'PUBLISHED')$q$) = 0, 'урок — 15 хвилин, щонайменше 2 цілі');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i
  where i.lesson_id in ('6836e57c-030c-59f8-9818-b44c08b126a6') and i.item_type = 'grammar'$q$) = 1
  and pg_temp.n($q$select 1 from public.lesson_grammar g where g.lesson_id in ('6836e57c-030c-59f8-9818-b44c08b126a6')$q$) = 1,
  'новий урок має тему граматики');
select pg_temp.ok(pg_temp.n($q$select i.item_id from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m8()) and i.item_type = 'lexeme' group by 1 having count(*) > 1$q$) = 0,
  'жодне слово не повторюється в різних уроках модуля');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m8()) and i.item_type = 'lexeme'
    and i.item_id in (select i1.item_id from public.lesson_items i1 join public.lessons l on l.id = i1.lesson_id
                       join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                      where m.level_code = 'A0' and m.order_index in (1, 2, 3, 4, 5, 6, 7) and i1.item_type = 'lexeme')$q$) = 0,
  'слова A0.8 не повторюють слів A0.1–A0.7');

-- ---------------------------------------------------------------- тема модуля
select pg_temp.ok(pg_temp.n($q$select distinct lower(x.lemma) from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id in (select lid from pg_temp.m8()) and i.item_type = 'lexeme'
    and lower(x.lemma) in ('tržnica', 'voće', 'povrće', 'kila', 'deka', 'blagajna', 'račun', 'kartica', 'gotovina', 'majica', 'hlače',
                           'veličina', 'boja', 'crven', 'popust')$q$) = 15,
  'у модулі ринок, кількості, каса, одяг, кольори, знижки');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = '6836e57c-030c-59f8-9818-b44c08b126a6' and i.item_type = 'lexeme'
    and lower(x.lemma) in ('popust', 'jeftiniji', 'skuplji', 'jeftinije', 'zadnja cijena', 'spustiti cijenu', 'dogovoreno', 'cjenkati se')$q$) = 8,
  'урок «Можна дешевше?»: знижка, дешевший / дорожчий, остання ціна, знизити ціну, домовилися, торгуватися');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_grammar lg join public.grammar_topics g on g.id = lg.grammar_topic_id
  where lg.lesson_id = '6836e57c-030c-59f8-9818-b44c08b126a6' and g.title_ua = 'Дешевше чи дорожче? Порівняння' and g.cefr = 'A0' and g.status = 'PUBLISHED'$q$) = 1
  and pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
                  where g.cefr = 'A0' and g.title_ua = 'Дешевше чи дорожче? Порівняння' and jsonb_array_length(r.examples) = 3$q$) = 4
  and pg_temp.n($q$select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Дешевше чи дорожче? Порівняння'$q$) = 1,
  'нова тема граматики «Порівняння»: одна, 4 правила по 3 приклади, у новому уроці');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a0_v4' and status = 'PUBLISHED' and cefr = 'A0'
  and normalized !~ '[čćđšž]' and normalized = lower(normalized) and lemma !~ '[Ѐ-ӿ]' and ukrainian_translation ~ '[Ѐ-ӿ]'
  and jsonb_array_length(examples) = 1 and lower(lemma) in ('šljiva', 'krastavac', 'pola kile', 'limenka', 'staklenka', 'narezati', 'još nešto', 'to je sve', 'samoposlužna blagajna', 'kupovina', 'beskontaktno', 'podići novac', 'trebate li vrećicu', 'pristajati', 'prevelik', 'premalen', 'kakve je boje', 'tamnoplav', 'svijetloplav', 'bež', 'zlatan', 'srebrn', 'na pruge', 'na točkice', 'jeftiniji', 'skuplji', 'jeftinije', 'skuplje', 'zadnja cijena', 'spustiti cijenu', 'ponuditi', 'dogovoreno', 'cjenkati se', 'rabljen', 'buvljak', 'isplatiti se')$q$) = 36,
  '36 нових слів і виразів A0.8: без кирилиці в лемі, normalized без діакритики, переклад і приклад');

-- ---------------------------------------------------------------- стара версія збережена
select pg_temp.ok(pg_temp.n($q$select 1 from (values ('e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0'::uuid), ('0e925295-2766-5931-b031-2412682bc6f8'::uuid), ('28913ad6-490f-5d89-bad7-9b303c673fcd'::uuid), ('b01e2f67-3e7a-5ab6-99bb-fae374f431e0'::uuid), ('288e7610-99c8-5696-989a-86f60ce38b0a'::uuid)) v(lid)
  where not exists (select 1 from public.content_versions cv where cv.entity_type = 'lesson' and cv.entity_id = v.lid
                    and cv.change_reason like 'curriculum_a0_v4: урок перебудовано%' and jsonb_array_length(cv.payload->'items') > 0)$q$) = 0,
  'стара версія кожного перебудованого уроку — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations c
  where c.id in (select jsonb_array_elements_text(v.payload->'conversations')::uuid from public.content_versions v
                 where v.change_reason like 'curriculum_a0_v4%' and v.entity_id in ('e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0', '0e925295-2766-5931-b031-2412682bc6f8', '28913ad6-490f-5d89-bad7-9b303c673fcd', 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0', '288e7610-99c8-5696-989a-86f60ce38b0a'))
    and c.status <> 'DEPRECATED'$q$) = 0, 'старі діалоги — DEPRECATED (не видалені)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e
  where e.id in (select b.item_id from backup.lesson_items_20261015 b where b.item_type = 'exercise' and b.lesson_id in ('e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0', '0e925295-2766-5931-b031-2412682bc6f8', '28913ad6-490f-5d89-bad7-9b303c673fcd', 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0', '288e7610-99c8-5696-989a-86f60ce38b0a'))
    and e.status <> 'DEPRECATED'$q$) = 0, 'старі вправи — DEPRECATED (не видалені)');

-- ---------------------------------------------------------------- видимість
set local role anon;
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations where source = 'claude_curriculum_a0_v4' and lesson_id in (select lid from pg_temp.m8())$q$) = 12,
  'гість бачить 12 нових діалогів A0.8');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id = '6836e57c-030c-59f8-9818-b44c08b126a6'$q$) = 1, 'гість бачить новий урок');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
