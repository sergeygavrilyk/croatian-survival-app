-- =====================================================================
-- Тест пакетів 20261117_a0_dupes_1_lessons.sql, _2_reading.sql, _3_tests.sql — дублі A0 (план «Дублі й сенс уроків», PR 2б):
-- урок 68 «У лікаря й в аптеці» → «У лікаря» (68) і новий «В аптеці» (69); Д4 (64), Д9 (58), Д10 (30), Д11 (69 → 70);
-- назва діалогу уроку 26; 2 тексти A0.6; тести a0-m09, a0-m11 і фінал a0-final наново. Уроків A0 — 73.
-- Запускати ПІСЛЯ трьох пакетів. БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
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

-- слова уроку (нижній регістр)
create or replace function pg_temp.w(p_lesson uuid) returns setof text language sql as $$
  select lower(x.lemma) from public.lesson_items li join public.lexemes x on x.id = li.item_id
   where li.lesson_id = p_lesson and li.item_type = 'lexeme'
$$;

-- уроки пакета: 30, 58, 64, 68, новий 69 «В аптеці», 70 «Допоможіть!»
create or replace function pg_temp.les() returns table (lid uuid, n int) language sql as $$
  select * from (values ('d7cf3059-0d92-5215-8ef4-ad699e317b10'::uuid, 30), ('b01e2f67-3e7a-5ab6-99bb-fae374f431e0'::uuid, 58),
                        ('e5b81eb1-8ea8-5ff4-a987-e5e46421302b'::uuid, 64), ('fbc71f82-e715-5bab-a990-b8542fb0fe01'::uuid, 68),
                        ('a4455f67-27c7-5ad7-a454-771a94ca4e02'::uuid, 69), ('48f26e9d-96c5-5189-8ec6-db1f9d58e200'::uuid, 70)) as t(lid, n)
$$;

-- ---------------------------------------------------------------- нумерація і модуль A0.11
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A0' and status = 'PUBLISHED'$q$) = 73
  and pg_temp.n($q$select 1 from (select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A0' and l.status = 'PUBLISHED') t
     where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%'$q$) = 0,
  'A0: 73 уроки, пронумеровані підряд');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.les() t join public.lessons l on l.id = t.lid and l.status = 'PUBLISHED'
                               and l.title_ua like 'Урок ' || t.n || ':%'$q$) = 6
  and (select title_ua || ' / ' || title_hr from public.lessons where id = 'fbc71f82-e715-5bab-a990-b8542fb0fe01') = 'Урок 68: У лікаря / Lekcija 68: Kod liječnika'
  and (select title_ua || ' / ' || title_hr from public.lessons where id = 'a4455f67-27c7-5ad7-a454-771a94ca4e02') = 'Урок 69: В аптеці / Lekcija 69: U ljekarni'
  and (select order_index from public.lessons where id = 'a4455f67-27c7-5ad7-a454-771a94ca4e02') = 4
  and pg_temp.n($q$select 1 from public.lessons where unit_id = '7c5becd1-c264-59f4-972e-fd095492d394' and status = 'PUBLISHED'$q$) = 8,
  'модуль A0.11: 8 уроків, 68 — «У лікаря», 69 — «В аптеці» (місце 4), 70 — «Допоможіть!»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_versions where entity_type = 'lesson' and change_reason like 'a0_dupes: новий номер уроку%'$q$) = 4,
  'уроки 69–72 → 70–73: старі назви — у content_versions');

-- ---------------------------------------------------------------- склад уроків
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.les() t
  where (select count(*) from public.lesson_items li where li.lesson_id = t.lid and li.item_type = 'lexeme') not between 20 and 25
     or (select count(*) from public.conversations c where c.lesson_id = t.lid and c.status = 'PUBLISHED') <> 2
     or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
          where li.lesson_id = t.lid and li.item_type = 'exercise' and li.required and e.status = 'PUBLISHED') <> 15
     or exists (select 1 from public.lesson_items li join public.exercises e on e.id = li.item_id
                 where li.lesson_id = t.lid and li.item_type = 'exercise' and e.status <> 'PUBLISHED')
     or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
          where li.lesson_id = t.lid and li.item_type = 'exercise' and not li.required and e.exercise_type in ('write_message', 'mediation')) <> 2$q$) = 0,
  'кожен урок пакета: 20–25 слів, 2 діалоги, 15 вправ (усі опубліковані), письмо й переказ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.les() t, public.conversations c
  where c.lesson_id = t.lid and c.status = 'PUBLISHED'
    and ((select count(*) from public.conversation_turns x where x.conversation_id = c.id) not between 5 and 8
         or c.situation is null or c.title_hr ~ '[Ѐ-ӿ]' or c.title_ua !~ '[Ѐ-ӿ]')$q$) = 0
  and pg_temp.n($q$select 1 from public.conversations c where c.id in ('b94fcb8f-1649-5cd5-9f2c-ffcb4577e160', '4f4b48e8-c309-5b8e-9098-67cfc15dbf87',
                   'e3b826c8-f59b-5bc5-b354-0a286eb4838f', 'ea8c847f-01ba-523c-a989-9b6e824734c6') and c.status = 'PUBLISHED'
                   and (select count(*) from public.conversation_turns x where x.conversation_id = c.id) >= 6$q$) = 4,
  'діалоги: 5–8 реплік, з ситуацією; 4 нові діалоги — щонайменше по 6 реплік');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items li join public.exercises e on e.id = li.item_id
  where li.lesson_id in (select lid from pg_temp.les()) and li.item_type = 'exercise' and e.exercise_type in ('sentence_builder', 'listening')
    and (select array_agg(x order by x) from jsonb_array_elements_text(e.options) x)
        <> (select array_agg(x order by x) from unnest(string_to_array(e.correct_answer, ' ')) x)$q$) = 0
  and pg_temp.n($q$select 1 from public.lesson_items li join public.exercises e on e.id = li.item_id
  where li.lesson_id in (select lid from pg_temp.les()) and li.item_type = 'exercise' and e.exercise_type = 'multiple_choice'
    and not (e.options ? e.correct_answer and jsonb_array_length(e.options) = 4)$q$) = 0,
  'вправи: плитки «складіть / прослухайте» = слова відповіді; у виборі — 4 варіанти з правильним');

-- Д10: урок 30 — лише привітання
select pg_temp.ok((select count(*) from pg_temp.w('d7cf3059-0d92-5215-8ef4-ad699e317b10') w where w in ('dan državnosti', 'neradni dan', 'pisanica')) = 0
  and (select count(*) from pg_temp.w('d7cf3059-0d92-5215-8ef4-ad699e317b10') w where w in ('hvala na čestitki', 'poželjeti', 'zaželjeti želju')) = 3
  and (select status from public.conversations where id = '131ad945-b721-555a-9dcd-bb89a6d97acd') = 'DEPRECATED'
  and (select title_hr from public.conversations where id = 'b94fcb8f-1649-5cd5-9f2c-ffcb4577e160') = 'Sretan rođendan, Dašo!',
  'Д10: урок 30 без Dan državnosti, neradni dan, pisanica; + 3 привітання; «Prije Božića» → «Sretan rođendan, Dašo!»');
-- Д9: урок 58 — без приміряльні
select pg_temp.ok((select count(*) from pg_temp.w('b01e2f67-3e7a-5ab6-99bb-fae374f431e0') w where w in ('kabina', 'probati', 'pristajati', 'prevelik', 'premalen')) = 0
  and (select count(*) from pg_temp.w('b01e2f67-3e7a-5ab6-99bb-fae374f431e0') w where w in ('obući', 'izlog', 'bluza', 'odijelo', 'donje rublje')) = 5
  and (select status from public.conversations where id = '0119ff02-cf85-577b-8109-b72609a0212e') = 'DEPRECATED'
  and pg_temp.n($q$select 1 from public.lesson_items li join public.exercises e on e.id = li.item_id
                   where li.lesson_id = 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0' and li.item_type = 'exercise'
                     and (e.correct_answer ~* 'kabin|probati|pristaj|prevelik|premalen' or e.question_text ~* 'kabin|приміроч')$q$) = 0,
  'Д9: урок 58 без kabina, probati, pristajati, prevelik, premalen (і без вправ на них); «U trgovini odjećom» → «Ispred izloga»');
-- Д4: урок 64 — без проїзного й пересадки
select pg_temp.ok((select count(*) from pg_temp.w('e5b81eb1-8ea8-5ff4-a987-e5e46421302b') w where w in ('mjesečna karta', 'presjesti', 'kontrolor')) = 0
  and (select count(*) from pg_temp.w('e5b81eb1-8ea8-5ff4-a987-e5e46421302b') w where w in ('sljedeća stanica', 'automat za karte', 'slobodno mjesto')) = 3
  and (select status from public.conversations where id = 'd7497f57-33d8-51d1-bb45-c01cad0a2698') = 'DEPRECATED'
  and pg_temp.n($q$select 1 from public.lesson_items li join public.exercises e on e.id = li.item_id
                   where li.lesson_id = 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b' and li.item_type = 'exercise' and e.correct_answer ~* 'presjest|kontrolor|mjesečn'$q$) = 0,
  'Д4: урок 64 без mjesečna karta, presjesti, kontrolor; «Kojim tramvajem?» → «Koja je sljedeća stanica?»');
-- Д12: урок 68 «У лікаря» і новий 69 «В аптеці»
select pg_temp.ok((select count(*) from pg_temp.w('fbc71f82-e715-5bab-a990-b8542fb0fe01') w
                    where w in ('ljekarna', 'ljekarnik', 'recept', 'lijek', 'tableta', 'sirup', 'protiv bolova', 'dnevno')) = 0
  and (select count(*) from pg_temp.w('a4455f67-27c7-5ad7-a454-771a94ca4e02') w
        where w in ('ljekarna', 'ljekarnik', 'recept', 'lijek', 'tableta', 'sirup', 'protiv bolova', 'dnevno')) = 8
  and (select count(*) from pg_temp.w('fbc71f82-e715-5bab-a990-b8542fb0fe01') w
        where w in ('liječnik', 'pregled', 'uputnica', 'bolovanje', 'glavobolja', 'dežurni liječnik', 'ostati u krevetu')) = 7
  and (select lesson_id from public.conversations where id = '1e4899ae-60f8-5de7-91fb-9517b913cbda') = 'a4455f67-27c7-5ad7-a454-771a94ca4e02'
  and pg_temp.n($q$select 1 from public.lesson_grammar lg join public.grammar_topics g on g.id = lg.grammar_topic_id
                   where lg.lesson_id = 'a4455f67-27c7-5ad7-a454-771a94ca4e02' and g.title_ua = 'Ввічливість: ti і Vi'$q$) = 1,
  'Д12: 8 слів аптеки й діалог «U ljekarni» — у новому уроці «В аптеці» (тема «ti і Vi»); в уроці 68 — слова про лікаря');
-- Д11: урок 70 «Допоможіть!»
select pg_temp.ok((select count(*) from pg_temp.w('48f26e9d-96c5-5189-8ec6-db1f9d58e200') w where w in ('zovite vatrogasce', 'požar', 'upomoć')) = 3,
  'Д11: урок «Допоможіть!» лишає «Upomoć!» і «požar», + zovite vatrogasce');
-- слова не зникають з курсу
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id
  where li.lesson_id = '7fb1b6e5-93b4-5776-b82b-25e7769fd32d' and li.item_type = 'lexeme' and lower(x.lemma) in ('kabina', 'probati', 'pristajati')$q$) = 3
  and pg_temp.n($q$select 1 from public.lesson_items li where li.lesson_id = '7fb1b6e5-93b4-5776-b82b-25e7769fd32d' and li.item_type = 'lexeme'$q$) = 20
  and pg_temp.n($q$select 1 from public.lexemes where lower(lemma) in ('kabina', 'probati', 'pristajati', 'prevelik', 'premalen', 'pisanica', 'dan državnosti', 'neradni dan')
                   and status = 'PUBLISHED' and cefr = 'A1'$q$) = 8
  and pg_temp.n($q$select 1 from public.lesson_items li join public.lessons l on l.id = li.lesson_id and l.status = 'PUBLISHED' and l.level_code = 'A1'
                   join public.lexemes x on x.id = li.item_id where li.item_type = 'lexeme'
                    and lower(x.lemma) in ('prevelik', 'premalen', 'pisanica', 'dan državnosti', 'neradni dan', 'mjesečna pokazna karta', 'presjedati', 'kontrolor karata')$q$) = 8,
  'прибрані з A0 слова — в уроках A1 (kabina, probati, pristajati — тепер в A1-24, 20 слів), рівень слова — A1');

-- ---------------------------------------------------------------- нові слова
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a0_dupes' and status = 'PUBLISHED' and cefr = 'A0'
  and register = 'standard' and regionality = 'general' and usage_tags = '{}'::text[]
  and normalized !~ '[čćđšž]' and normalized = lower(normalized) and lemma !~ '[Ѐ-ӿ]' and ukrainian_translation ~ '[Ѐ-ӿ]'
  and jsonb_array_length(examples) = 1 and examples::text !~ '[Ѐ-ӿ]'$q$) = 25,
  '25 нових слів і виразів: опубліковані, з мітками, без кирилиці в лемі й прикладі, normalized без діакритики');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a0_dupes'
  and ((part_of_speech = 'noun' and forms->>'gender' is null) or (part_of_speech = 'verb' and forms->>'aspect' is null))$q$) = 0
  and pg_temp.n($q$select 1 from public.lexemes where lower(lemma) in ('odijelo', 'glavobolja', 'bolest', 'slab', 'jak', 'izmjeriti', 'sredstvo')
                   and status = 'PUBLISHED' and cefr = 'A0'$q$) = 7,
  'іменники — з родом, дієслова — з видом; 7 наявних слів, які вперше вчать в A0, — рівень A0');

-- ---------------------------------------------------------------- нічого не видалено
select pg_temp.ok(pg_temp.n($q$select 1 from backup.lesson_items_a0dupes_20261117$q$) >= 150
  and pg_temp.n($q$select 1 from public.content_versions where entity_type = 'lesson' and change_reason like 'a0_dupes: урок%стара версія'$q$) = 5
  and pg_temp.n($q$select 1 from public.content_versions where entity_type = 'lesson' and change_reason like 'a0_dupes: + %стара версія'$q$) = 1
  and pg_temp.n($q$select 1 from public.exercises e where e.id in (select b.item_id from backup.lesson_items_a0dupes_20261117 b where b.item_type = 'exercise')
                   and not exists (select 1 from public.lesson_items li where li.item_type = 'exercise' and li.item_id = e.id)
                   and e.status <> 'DEPRECATED'$q$) = 0,
  'склад уроків до змін — у backup, старі версії — у content_versions; замінені вправи — DEPRECATED (не видалені)');
select pg_temp.ok((select title_hr from public.conversations where id = '31f40ede-635a-54e2-9a86-c6b199479205') = 'Vlak za Rijeku'
  and exists (select 1 from public.content_versions where entity_type = 'conversation' and entity_id = '31f40ede-635a-54e2-9a86-c6b199479205'
              and payload->>'title_hr' = 'Na kolodvoru'),
  'діалог уроку 26 «Na kolodvoru» → «Vlak za Rijeku» (стара назва — у content_versions)');

-- ---------------------------------------------------------------- тексти A0.6
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where code in ('RD-A0-021', 'RD-A0-022') and cefr = 'A0' and module_order = 6
  and status = 'PUBLISHED' and jsonb_array_length(questions) = 3 and known_ratio >= 0.8 and word_count between 10 and 40
  and not exists (select 1 from jsonb_array_elements(glossary) e where e->>'pos' is null or coalesce(e->>'ua', '') !~ '[Ѐ-ӿ]'
                                                                    or (e->>'gram' is null and e->>'form' <> lower(e->>'lemma')))
  and not exists (select 1 from jsonb_array_elements(questions) x where not (x->'options' ? (x->>'answer')))$q$) = 2,
  '2 тексти модуля A0.6: 3 питання, словничок з граматикою й перекладом, ≥ 80 % знайомих слів');

-- ---------------------------------------------------------------- перевірки
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug = 'a0-m09' and a.cefr = 'A0' and i.status = 'PUBLISHED'$q$) = 12
  and pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug = 'a0-m11' and a.cefr = 'A0' and i.status = 'PUBLISHED'$q$) = 16
  and pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug = 'a0-final' and a.cefr = 'A0' and i.status = 'PUBLISHED'$q$) = 48,
  'a0-m09 — 12 завдань, a0-m11 — 16 (8 уроків), a0-final — 48');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  join public.lessons l on l.id = i.lesson_id join public.units u on u.id = l.unit_id
  where a.slug in ('a0-m09', 'a0-m11') and i.status = 'PUBLISHED' and u.module_id <> a.module_id$q$) = 0
  and pg_temp.n($q$select distinct m.order_index from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  join public.lessons l on l.id = i.lesson_id join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where a.slug = 'a0-final' and a.cefr = 'A0' and i.status = 'PUBLISHED'$q$) = 11
  and exists (select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
              where a.slug = 'a0-m11' and i.status = 'PUBLISHED' and i.lesson_id = 'a4455f67-27c7-5ad7-a454-771a94ca4e02'),
  'тести модулів — з уроків свого модуля (a0-m11 — і з «В аптеці»); фінал — з усіх 11 модулів');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug in ('a0-m09', 'a0-m11', 'a0-final') and a.cefr = 'A0' and i.status = 'PUBLISHED'
    and (i.audio_hr in (select hr_text from public.conversation_turns t join public.conversations c on c.id = t.conversation_id where c.status = 'DEPRECATED')
         and i.audio_hr not in (select hr_text from public.conversation_turns t join public.conversations c on c.id = t.conversation_id where c.status = 'PUBLISHED'))$q$) = 0
  and pg_temp.n($q$select 1 from public.content_versions where entity_type = 'assessment' and change_reason like 'a0_dupes:%'$q$) = 3,
  'завдання не з прибраних діалогів; старі завдання трьох тестів — у content_versions');

-- ---------------------------------------------------------------- гість бачить нове
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id = 'a4455f67-27c7-5ad7-a454-771a94ca4e02'$q$) = 1
  and pg_temp.n($q$select 1 from public.conversations where id = '131ad945-b721-555a-9dcd-bb89a6d97acd'$q$) = 0
  and pg_temp.n($q$select 1 from public.reading_texts where code in ('RD-A0-021', 'RD-A0-022')$q$) = 2,
  'гість бачить урок «В аптеці» і тексти A0.6, а старих діалогів — ні');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
