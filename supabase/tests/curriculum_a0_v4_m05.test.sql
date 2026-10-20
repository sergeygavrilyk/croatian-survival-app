-- =====================================================================
-- Тести: уроки A0 за темою (curriculum_a0_v4) · модуль A0.5 «Obitelj» · 2026-10-19
-- Запускати ПІСЛЯ supabase/data_fixes/20261019_curriculum_a0_v4_m05.sql.
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

-- уроки модуля A0.5 у новому порядку (id, місце)
create or replace function pg_temp.m5() returns table (lid uuid, o int) language sql as $$
  select * from (values ('4e003796-1ce0-5a02-8a2d-59a0de38f3dd'::uuid, 1), ('18efed0f-53a5-5717-9c4e-319627da2360'::uuid, 2), ('f9ca38e4-3a61-56a6-b5f5-060933516c9a'::uuid, 3), ('cec08ff0-a97d-5847-88cc-dee22fed2f8c'::uuid, 4), ('2b0e9742-99e1-57e1-a574-67ffb78d2607'::uuid, 5), ('60130364-d731-5f5a-8b12-ac4d8d6d92e9'::uuid, 6), ('40b9da1d-1686-5b78-8317-0439067d5f8e'::uuid, 7)) as t(lid, o)
$$;

-- ---------------------------------------------------------------- модуль і порядок
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where m.level_code = 'A0' and m.order_index = 5 and l.status = 'PUBLISHED'$q$) = 7, 'у модулі A0.5 — 7 опублікованих уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m5() t join public.lessons l on l.id = t.lid and l.order_index = t.o$q$) = 7,
  'уроки A0.5 стоять у новому порядку (4 наявні + 3 нові)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A0' and status = 'PUBLISHED'$q$) >= 61, 'A0: щонайменше 61 уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from (
    select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where l.level_code = 'A0' and l.status = 'PUBLISHED') t
  where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%'$q$) = 0,
  'назви уроків A0 пронумеровано підряд');
select pg_temp.ok((select title_ua from public.lessons where id = '4e003796-1ce0-5a02-8a2d-59a0de38f3dd') = 'Урок 31: Моя сім’я'
  and (select title_ua from public.lessons where id = '40b9da1d-1686-5b78-8317-0439067d5f8e') = 'Урок 37: Домашні тварини', 'модуль A0.5 — уроки 31–37');

-- ---------------------------------------------------------------- склад уроків
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m5() v
  where (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'lexeme') not between 20 and 25$q$) = 0,
  'у кожному уроці 20–25 слів і виразів');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m5() v
  where (select count(*) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
     or (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'exercise') <> 15$q$) = 0,
  'у кожному уроці 15 опублікованих вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m5() v
  where (select count(distinct e.exercise_type) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise') < 6$q$) = 0, 'у кожному уроці всі 6 типів вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m5() v
  where (select count(*) from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source = 'claude_curriculum_a0_v4') <> 2
     or exists (select 1 from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source is distinct from 'claude_curriculum_a0_v4')
     or (select count(*) from public.conversation_turns t join public.conversations c on c.id = t.conversation_id
         where c.lesson_id = v.lid and c.status = 'PUBLISHED') not between 8 and 12$q$) = 0,
  'у кожному уроці 2 нові діалоги по 4–6 реплік, старі не показуються');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in (select lid from pg_temp.m5())
  and (estimated_minutes <> 15 or jsonb_array_length(objectives) < 2 or status <> 'PUBLISHED')$q$) = 0, 'урок — 15 хвилин, щонайменше 2 цілі');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i
  where i.lesson_id in ('18efed0f-53a5-5717-9c4e-319627da2360', '60130364-d731-5f5a-8b12-ac4d8d6d92e9', '40b9da1d-1686-5b78-8317-0439067d5f8e') and i.item_type = 'grammar'$q$) = 3
  and pg_temp.n($q$select 1 from public.lesson_grammar g where g.lesson_id in ('18efed0f-53a5-5717-9c4e-319627da2360', '60130364-d731-5f5a-8b12-ac4d8d6d92e9', '40b9da1d-1686-5b78-8317-0439067d5f8e')$q$) = 3,
  'кожен новий урок має тему граматики');
select pg_temp.ok(pg_temp.n($q$select i.item_id from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m5()) and i.item_type = 'lexeme' group by 1 having count(*) > 1$q$) = 0,
  'жодне слово не повторюється в різних уроках модуля');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m5()) and i.item_type = 'lexeme'
    and i.item_id in (select i1.item_id from public.lesson_items i1 join public.lessons l on l.id = i1.lesson_id
                       join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                      where m.level_code = 'A0' and m.order_index in (1, 2, 3, 4) and i1.item_type = 'lexeme')$q$) = 0,
  'слова A0.5 не повторюють слів A0.1–A0.4');

-- ---------------------------------------------------------------- тема модуля
select pg_temp.ok(pg_temp.n($q$select distinct lower(x.lemma) from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id in (select lid from pg_temp.m5()) and i.item_type = 'lexeme'
    and lower(x.lemma) in ('obitelj', 'majka', 'otac', 'brat', 'sestra', 'sin', 'kći', 'baka', 'djed', 'muž', 'supruga', 'dijete', 'djeca',
                           'teta', 'ujak', 'bratić', 'sestrična', 'prijatelj', 'pas', 'mačka')$q$) = 20,
  'у модулі основні слова сім’ї, родичі, діти, друзі, собака й кішка');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = '18efed0f-53a5-5717-9c4e-319627da2360' and i.item_type = 'lexeme'
    and lower(x.lemma) in ('moj', 'tvoj', 'njegov', 'njezin', 'naš', 'vaš', 'njihov', 'svoj')$q$) = 8,
  'урок «Чиє це?»: усі присвійні займенники');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = '60130364-d731-5f5a-8b12-ac4d8d6d92e9' and i.item_type = 'lexeme'
    and lower(x.lemma) in ('visok', 'nizak', 'mršav', 'kosa', 'oko', 'pametan', 'strpljiv', 'lijen')$q$) = 8,
  'урок «Зовнішність і характер»: зріст, волосся, очі, риси характеру');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = '40b9da1d-1686-5b78-8317-0439067d5f8e' and i.item_type = 'lexeme'
    and lower(x.lemma) in ('kućni ljubimac', 'pas', 'mačka', 'ptica', 'hrčak', 'veterinar', 'šetati', 'hraniti')$q$) = 8,
  'урок «Домашні тварини»: тварини, ветеринар, вигулювати, годувати');

select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_topics g where g.id = '4fea3ec1-5230-5d19-b044-f402c1ca6f56' and g.status = 'PUBLISHED' and g.cefr = 'A0'
  and (select count(*) from public.grammar_rules r where r.topic_id = g.id and jsonb_array_length(r.examples) >= 3) = 4$q$) = 1,
  'нова тема граматики «Присвійні займенники» — 4 правила з прикладами');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_grammar lg join public.grammar_topics g on g.id = lg.grammar_topic_id
  where (lg.lesson_id = '18efed0f-53a5-5717-9c4e-319627da2360' and g.id = '4fea3ec1-5230-5d19-b044-f402c1ca6f56')
     or (lg.lesson_id = '60130364-d731-5f5a-8b12-ac4d8d6d92e9' and g.title_ua = 'Прикметники: узгодження з іменником')
     or (lg.lesson_id = '40b9da1d-1686-5b78-8317-0439067d5f8e' and g.title_ua = 'Дієслово «imati» (мати)')$q$) = 3,
  'нові уроки: «Чиє це?» — присвійні займенники, «Зовнішність» — узгодження прикметника, «Тварини» — imati');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a0_v4' and status = 'PUBLISHED' and cefr = 'A0'
  and normalized !~ '[čćđšž]' and normalized = lower(normalized) and lemma !~ '[Ѐ-ӿ]' and ukrainian_translation ~ '[Ѐ-ӿ]'
  and jsonb_array_length(examples) = 1 and lower(lemma) in ('braća', 'jedinac', 'jedinica', 'blizanci', 'najstariji', 'najmlađi', 'čije je ovo', 'vlasnica', 'tuđ', 'osobni', 'kod mene', 'kod nas', 'razveden', 'zaručnik', 'zaručnica', 'vjenčati se', 'oženiti se', 'udati se', 'samac', 'udovica', 'stric', 'tetak', 'ujna', 'strina', 'nećak', 'nećakinja', 'svekrva', 'svekar', 'punica', 'punac', 'šogor', 'šogorica', 'zet', 'snaha', 'kum', 'kuma', 'tinejdžer', 'odgojiteljica', 'najbolji prijatelj', 'družiti se', 'mršav', 'kovrčav', 'brada', 'brkovi', 'mače', 'papiga', 'ribica', 'hrčak', 'zec', 'kornjača', 'maziti', 'ugristi')$q$) = 52,
  '52 нових слів і виразів A0.5: без кирилиці в лемі, normalized без діакритики, переклад і приклад');

-- ---------------------------------------------------------------- стара версія збережена
select pg_temp.ok(pg_temp.n($q$select 1 from (values ('4e003796-1ce0-5a02-8a2d-59a0de38f3dd'::uuid), ('f9ca38e4-3a61-56a6-b5f5-060933516c9a'::uuid), ('cec08ff0-a97d-5847-88cc-dee22fed2f8c'::uuid), ('2b0e9742-99e1-57e1-a574-67ffb78d2607'::uuid)) v(lid)
  where not exists (select 1 from public.content_versions cv where cv.entity_type = 'lesson' and cv.entity_id = v.lid
                    and cv.change_reason like 'curriculum_a0_v4: урок перебудовано%' and jsonb_array_length(cv.payload->'items') > 0)$q$) = 0,
  'стара версія кожного перебудованого уроку — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations c
  where c.id in (select jsonb_array_elements_text(v.payload->'conversations')::uuid from public.content_versions v
                 where v.change_reason like 'curriculum_a0_v4%' and v.entity_id in ('4e003796-1ce0-5a02-8a2d-59a0de38f3dd', 'f9ca38e4-3a61-56a6-b5f5-060933516c9a', 'cec08ff0-a97d-5847-88cc-dee22fed2f8c', '2b0e9742-99e1-57e1-a574-67ffb78d2607'))
    and c.status <> 'DEPRECATED'$q$) = 0, 'старі діалоги — DEPRECATED (не видалені)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e
  where e.id in (select b.item_id from backup.lesson_items_20261015 b where b.item_type = 'exercise' and b.lesson_id in ('4e003796-1ce0-5a02-8a2d-59a0de38f3dd', 'f9ca38e4-3a61-56a6-b5f5-060933516c9a', 'cec08ff0-a97d-5847-88cc-dee22fed2f8c', '2b0e9742-99e1-57e1-a574-67ffb78d2607'))
    and e.status <> 'DEPRECATED'$q$) = 0, 'старі вправи — DEPRECATED (не видалені)');

-- ---------------------------------------------------------------- видимість
set local role anon;
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations where source = 'claude_curriculum_a0_v4' and lesson_id in (select lid from pg_temp.m5())$q$) = 14,
  'гість бачить 14 нових діалогів A0.5');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in ('18efed0f-53a5-5717-9c4e-319627da2360', '60130364-d731-5f5a-8b12-ac4d8d6d92e9', '40b9da1d-1686-5b78-8317-0439067d5f8e')$q$) = 3, 'гість бачить 3 нові уроки');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules where topic_id = '4fea3ec1-5230-5d19-b044-f402c1ca6f56'$q$) = 4, 'гість бачить 4 нові правила граматики');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
