-- =====================================================================
-- Тест пакетів 20261117_a1_dupes_1_lessons.sql і _2_tests.sql — дублі A1 (план «Дублі й сенс уроків», PR 3):
-- урок 105 «Надзвичайні ситуації» → A1.8 (76); Д3 (54), Д12 (70), Д13 (93 → 94), Д2 (101 → 105); 3 нові уроки A1.11 (99–101);
-- 9 назв діалогів; svjedodžba → A2-11, porez і platna lista → A2-34; тести a1-m06, m08, m11, m12 і фінал a1-final наново.
-- Уроків A1 — 111. Запускати ПІСЛЯ обох пакетів. БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
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

-- уроки пакета: 54, 70, 94 (був 93), 105 (був 101), нові 99–101
create or replace function pg_temp.les() returns table (lid uuid, n int) language sql as $$
  select * from (values ('4d6f3498-2cc5-54a0-b4e4-c66add71ef12'::uuid, 54), ('123e68fa-291f-5ad6-8403-51db7020d641'::uuid, 70),
                        ('d9ef1de4-f4db-590e-bafd-474f84c8e03f'::uuid, 94), ('11b565a4-1e2a-50d2-8d9d-c05e84371402'::uuid, 105),
                        ('5ae02c5f-7ba1-5b59-be71-f744d6e9b169'::uuid, 99), ('b026f1b1-879d-59b5-8506-ee99e128c9c1'::uuid, 100),
                        ('8bb4331d-c7c0-5039-acf9-756684424039'::uuid, 101)) as t(lid, n)
$$;

-- ---------------------------------------------------------------- нумерація і модулі
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A1' and status = 'PUBLISHED'$q$) = 111
  and pg_temp.n($q$select 1 from (select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A1' and l.status = 'PUBLISHED') t
     where t.title_ua !~ ('^Урок ' || t.n || ':') or t.title_hr !~ ('^Lekcija ' || t.n || ':')$q$) = 0,
  'уроків A1 — 111 (було 108), номери 1…111 українською й хорватською без пропусків');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id = '692e9310-7a5b-5adf-9f0a-a66b72fc5459'
    and unit_id = '2eec2289-6a8a-5fb2-9988-e52433d5a242' and order_index = 11 and title_ua = 'Урок 76: Надзвичайні ситуації'$q$) = 1
  and pg_temp.n($q$select 1 from public.lessons where unit_id = '2eec2289-6a8a-5fb2-9988-e52433d5a242' and status = 'PUBLISHED'$q$) = 11
  and pg_temp.n($q$select 1 from public.lessons where unit_id = 'e0fc94e0-c41d-5f59-adf7-db0c97c4575c' and status = 'PUBLISHED'$q$) = 7,
  'урок «Надзвичайні ситуації» — у модулі A1.8 на місці 11 (урок 76); в A1.8 — 11 уроків, в A1.12 — 7');
select pg_temp.ok((select title_ua from public.lessons where id = '692e9310-7a5b-5adf-9f0a-a66b72fc5459') = 'Урок 76: Надзвичайні ситуації'
  and (select l.title_ua from public.lessons l join public.units u on u.id = l.unit_id where u.id = '2eec2289-6a8a-5fb2-9988-e52433d5a242'
        and l.order_index = 10) = 'Урок 75: Здоровий спосіб життя'
  and exists (select 1 from public.content_versions v where v.entity_type = 'lesson' and v.entity_id = '692e9310-7a5b-5adf-9f0a-a66b72fc5459'
               and v.payload->>'unit_id' = 'e0fc94e0-c41d-5f59-adf7-db0c97c4575c'),
  'одразу після «Здоровий спосіб життя» (75); старе місце (модуль A1.12) — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join pg_temp.les() t on t.lid = l.id
   where l.status = 'PUBLISHED' and l.title_ua ~ ('^Урок ' || t.n || ':')$q$) = 7
  and pg_temp.n($q$select 1 from public.lessons where unit_id = '1fb51162-343f-5587-89cf-d2594a3091db' and status = 'PUBLISHED'
       and (order_index, title_ua, title_hr) in ((6, 'Урок 99: Символи й винаходи', 'Lekcija 99: Simboli i izumi'),
            (7, 'Урок 100: Фестивалі й карнавали', 'Lekcija 100: Festivali i karnevali'),
            (8, 'Урок 101: Казки й легенди', 'Lekcija 101: Bajke i legende'))$q$) = 3
  and pg_temp.n($q$select 1 from public.lessons where unit_id = '1fb51162-343f-5587-89cf-d2594a3091db' and status = 'PUBLISHED'$q$) = 8,
  'A1.11 «Хорватська культура» — 8 уроків: нові «Символи й винаходи» (99), «Фестивалі й карнавали» (100), «Казки й легенди» (101)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations c join public.lessons l on l.id = c.lesson_id
   where l.level_code = 'A1' and l.status = 'PUBLISHED' and c.status = 'PUBLISHED'
     and c.order_index / 10 <> 300 + substring(l.title_ua from '^Урок ([0-9]+):')::int$q$) = 0,
  'порядок діалогів уроків A1 v3 — 3000 + N·10 + k за новим номером');

-- ---------------------------------------------------------------- склад змінених і нових уроків
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.les() t
   where (select count(*) from public.conversations c where c.lesson_id = t.lid and c.status = 'PUBLISHED') <> 2
      or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
           where li.lesson_id = t.lid and li.item_type = 'exercise' and li.required and e.status = 'PUBLISHED') <> 15
      or exists (select 1 from public.lesson_items li join public.exercises e on e.id = li.item_id
                  where li.lesson_id = t.lid and li.item_type = 'exercise' and e.status <> 'PUBLISHED')
      or exists (select 1 from public.conversations c where c.lesson_id = t.lid and c.status = 'PUBLISHED'
                  and (select count(*) from public.conversation_turns x where x.conversation_id = c.id) not between 4 and 6)$q$) = 0,
  '7 уроків пакета: 2 опубліковані діалоги (по 4–6 реплік), 15 обов’язкових опублікованих вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.les() t where t.n between 99 and 101
     and ((select count(*) from pg_temp.w(t.lid)) not between 20 and 25
          or exists (select 1 from public.conversations c where c.lesson_id = t.lid and c.status = 'PUBLISHED'
                      and ((select count(*) from public.conversation_turns x where x.conversation_id = c.id) <> 6 or c.situation is null))
          or (select count(*) from public.lesson_grammar g where g.lesson_id = t.lid) <> 1)$q$) = 0
  and (select count(*) from pg_temp.w('5ae02c5f-7ba1-5b59-be71-f744d6e9b169')) = 22
  and (select count(*) from pg_temp.w('b026f1b1-879d-59b5-8506-ee99e128c9c1')) = 22
  and (select count(*) from pg_temp.w('8bb4331d-c7c0-5039-acf9-756684424039')) = 23,
  'нові уроки: 22, 22 і 23 слова (рішення 2026-10-15: 20–25), діалоги по 6 реплік з ситуацією, 1 тема граматики');
select pg_temp.ok(pg_temp.n($q$select x.id from public.lesson_items li join public.lessons l on l.id = li.lesson_id and l.status = 'PUBLISHED'
   join public.lexemes x on x.id = li.item_id
  where li.item_type = 'lexeme' and l.level_code in ('A0', 'A1', 'A2')
    and li.lesson_id in (select lid from pg_temp.les() where n between 99 and 101)
    and exists (select 1 from public.lesson_items o join public.lessons ol on ol.id = o.lesson_id and ol.status = 'PUBLISHED'
                 where o.item_type = 'lexeme' and o.item_id = li.item_id and o.lesson_id <> li.lesson_id)$q$) = 0,
  'слова нових уроків не повторюють слів жодного іншого уроку A0–A2');

-- ---------------------------------------------------------------- Д3, Д12, Д13, Д2
select pg_temp.ok((select count(*) from pg_temp.w('4d6f3498-2cc5-54a0-b4e4-c66add71ef12')) = 16
  and (select array_agg(w order by convert_to(w, 'UTF8')) from pg_temp.w('4d6f3498-2cc5-54a0-b4e4-c66add71ef12') w
        where w in ('potpisati ugovor', 'raditi vikendom', 'ugovor o radu', 'opis posla', 'uvjeti rada', 'bruto', 'neto', 'porez', 'doprinosi', 'platna lista'))
      = array['opis posla', 'potpisati ugovor', 'raditi vikendom', 'ugovor o radu', 'uvjeti rada']
  and pg_temp.n($q$select 1 from public.conversations where lesson_id = '4d6f3498-2cc5-54a0-b4e4-c66add71ef12' and status = 'PUBLISHED'
       and title_hr in ('Potpisujemo ugovor', 'Pitanja o ugovoru')$q$) = 2
  and (select status from public.conversations where id = 'd683d4c9-6d44-5479-966f-dfd350782ec6') = 'DEPRECATED',
  'Д3, урок 54: без bruto, neto, porez, doprinosi, platna lista — 5 слів про умови роботи; «Prva plaća» → «Pitanja o ugovoru» (16 слів)');
select pg_temp.ok((select count(*) from pg_temp.w('123e68fa-291f-5ad6-8403-51db7020d641')) = 15
  and not exists (select 1 from pg_temp.w('123e68fa-291f-5ad6-8403-51db7020d641') w where w in ('tableta', 'lijek protiv bolova'))
  and (select count(*) from pg_temp.w('123e68fa-291f-5ad6-8403-51db7020d641') w where w in ('prije jela', 'dvaput dnevno')) = 2,
  'Д12, урок 70: без tableta, lijek protiv bolova — prije jela, dvaput dnevno (15 слів)');
select pg_temp.ok((select count(*) from pg_temp.w('d9ef1de4-f4db-590e-bafd-474f84c8e03f')) = 15
  and not exists (select 1 from pg_temp.w('d9ef1de4-f4db-590e-bafd-474f84c8e03f') w where w in ('katedrala', 'zidine'))
  and (select count(*) from pg_temp.w('d9ef1de4-f4db-590e-bafd-474f84c8e03f') w where w in ('gotički', 'renesansni')) = 2,
  'Д13, урок 94: без katedrala, zidine — gotički, renesansni (15 слів); katedrala, zidine лишаються в A0 «Старе місто»');
select pg_temp.ok((select count(*) from pg_temp.w('11b565a4-1e2a-50d2-8d9d-c05e84371402')) = 16
  and not exists (select 1 from pg_temp.w('11b565a4-1e2a-50d2-8d9d-c05e84371402') w
                   where w in ('polagati', 'položiti', 'svjedodžba', 'uvjerenje', 'priznavanje'))
  and (select count(*) from pg_temp.w('11b565a4-1e2a-50d2-8d9d-c05e84371402') w
        where w in ('upisati se', 'test razine', 'početni tečaj', 'rječnik', 'vježba')) = 5
  and pg_temp.n($q$select 1 from public.conversations where lesson_id = '11b565a4-1e2a-50d2-8d9d-c05e84371402' and status = 'PUBLISHED'
       and title_hr in ('U školi stranih jezika', 'Prvi sat')$q$) = 2
  and (select status from public.conversations where id = '8334cf71-db86-5617-87b7-e8a7d9921162') = 'DEPRECATED',
  'Д2, урок 105: запис на курс і перше заняття — без іспиту й визнання; «Poslije ispita» → «Prvi sat» (16 слів)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items li join public.lessons l on l.id = li.lesson_id and l.level_code = 'A1' and l.status = 'PUBLISHED'
   join public.lexemes x on x.id = li.item_id
  where li.item_type = 'lexeme' and lower(x.lemma) in ('bruto', 'neto', 'porez', 'doprinosi', 'platna lista', 'tableta', 'lijek protiv bolova',
        'katedrala', 'zidine', 'polagati', 'položiti', 'svjedodžba', 'uvjerenje', 'priznavanje')$q$) = 0,
  'прибраних слів немає в жодному уроці A1');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items li join public.lessons l on l.id = li.lesson_id and l.status = 'PUBLISHED'
   join public.lexemes x on x.id = li.item_id where li.item_type = 'lexeme'
    and ((l.id = 'dd6c5f39-f66e-5acb-8255-932f822ddcc5' and lower(x.lemma) = 'svjedodžba')
      or (l.id = 'b9bcea21-08a3-56cf-be72-edf6b6c7b03f' and lower(x.lemma) in ('porez', 'platna lista')))$q$) = 3
  and (select count(*) from pg_temp.w('dd6c5f39-f66e-5acb-8255-932f822ddcc5')) = 22
  and (select count(*) from pg_temp.w('b9bcea21-08a3-56cf-be72-edf6b6c7b03f')) = 24
  and pg_temp.n($q$select 1 from public.lesson_items li join public.lessons l on l.id = li.lesson_id and l.level_code in ('A0', 'A2') and l.status = 'PUBLISHED'
   join public.lexemes x on x.id = li.item_id where li.item_type = 'lexeme'
    and lower(x.lemma) in ('polagati', 'položiti', 'uvjerenje', 'katedrala', 'zidine', 'tableta')$q$) >= 6,
  'слово не зникає з курсу: svjedodžba → A2-11 (22 слова), porez і platna lista → A2-34 (24); polagati, položiti, uvjerenje — A2; katedrala, zidine, tableta — A0');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.les() t join public.lesson_items li on li.lesson_id = t.lid and li.item_type = 'exercise'
   join public.exercises e on e.id = li.item_id
  where e.exercise_type in ('sentence_builder', 'listening', 'speaking')
    and (e.correct_answer ~* '(bruto|neto |porez|doprinos|platn|zidin|katedral|tablet|polož|polag|uvjeren|svjedodž|priznavan)'
         or e.question_text ~* '(брутто|нетто|податк|внеск|мури|собор|таблетк|скласти іспит|свідоцтв|визнанн)')$q$) = 0
  and pg_temp.n($q$select 1 from pg_temp.les() t join public.lesson_items li on li.lesson_id = t.lid and li.item_type = 'exercise'
   join public.exercises e on e.id = li.item_id join public.lexemes x on x.id = e.lexeme_id
  where lower(x.lemma) in ('bruto', 'neto', 'porez', 'doprinosi', 'platna lista', 'tableta', 'lijek protiv bolova', 'katedrala', 'zidine',
        'polagati', 'položiti', 'svjedodžba', 'uvjerenje', 'priznavanje')$q$) = 0,
  'у змінених уроках немає вправ на прибрані слова й речень з ними');
select pg_temp.ok(pg_temp.n($q$select 1 from backup.lesson_items_a1dupes_20261117 where lesson_id in ('4d6f3498-2cc5-54a0-b4e4-c66add71ef12',
     '123e68fa-291f-5ad6-8403-51db7020d641', 'd9ef1de4-f4db-590e-bafd-474f84c8e03f', '11b565a4-1e2a-50d2-8d9d-c05e84371402',
     'dd6c5f39-f66e-5acb-8255-932f822ddcc5', 'b9bcea21-08a3-56cf-be72-edf6b6c7b03f')$q$) = 205
  and pg_temp.n($q$select 1 from public.content_versions where change_reason like 'a1_dupes:%'$q$) >= 70,
  'копія складу змінених уроків — backup.lesson_items_a1dupes_20261117; старі версії — у content_versions');

-- ---------------------------------------------------------------- нові слова й рівні
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a1_dupes' and status = 'PUBLISHED' and cefr = 'A1'
     and register = 'standard' and regionality = 'general' and usage_tags is not null$q$) = 60
  and (select array_agg(lower(lemma) || ':' || array_to_string(usage_tags, ',') order by convert_to(lower(lemma), 'UTF8')) from public.lexemes
        where source = 'claude_curriculum_a1_dupes' and cardinality(usage_tags) > 0) = array['maskenbal:germanism', 'maškare:italianism'],
  '60 нових слів — PUBLISHED (бета) A1, з мітками; ознаки — лише maškare (italianism) і maskenbal (germanism)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lower(lemma) in ('kravata', 'vojnik', 'izum', 'izumitelj', 'znanstvenik', 'otkriće',
     'slavan', 'ponos', 'ples', 'šala', 'smijeh', 'priča', 'junak', 'hrabar', 'zlo', 'rječnik', 'vježba', 'ugovor o radu',
     'upisati se', 'test razine', 'početni tečaj') and status = 'PUBLISHED' and cefr = 'A1'$q$) = 21
  and pg_temp.n($q$select 1 from public.lexemes where lower(lemma) in ('polagati', 'položiti', 'uvjerenje', 'svjedodžba', 'porez', 'platna lista')
     and status = 'PUBLISHED' and cefr = 'A2'$q$) = 6,
  'рівень слів: 21 слово, яке тепер учать в A1, — A1; 6 прибраних з A1, які вчать в A2, — A2');

-- ---------------------------------------------------------------- назви діалогів
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations where status = 'PUBLISHED' and (id, title_hr) in (
     ('1515f889-130f-5476-8851-938106d3700a'::uuid, 'Tobogan i ljuljačka'), ('6a218fb4-4e02-5825-8744-f5d9813cffa4'::uuid, 'Najkraćim putem'),
     ('1344654b-470d-5676-b47e-b0001240b17d'::uuid, 'Stan s potkrovljem'), ('514923a7-f17e-52bd-bf86-ddfff3e51b51'::uuid, 'Garnitura na akciji'),
     ('14858aec-7921-527f-b3c3-e839da3fb494'::uuid, 'Tko gdje radi?'), ('0a6b020d-ea8a-52dd-9cba-22cda92936e5'::uuid, 'Gdje ste radili prije?'),
     ('fe918e0d-21ff-5dc9-b37a-fbf2af2bfccd'::uuid, 'Mišići i zglobovi'), ('b2e86525-a790-5cf3-87ce-734d9e063a43'::uuid, 'Dođi na moj rođendan!'),
     ('b9fa04a2-e778-57c5-95d9-106b6058ad98'::uuid, 'Recite nam nešto o sebi'))$q$) = 9
  and pg_temp.n($q$select lower(c.title_hr) from public.conversations c join public.lessons l on l.id = c.lesson_id and l.status = 'PUBLISHED'
       where c.status = 'PUBLISHED' and l.level_code in ('A0', 'A1') group by 1 having count(*) > 1$q$) = 0,
  '9 діалогів A1 з новими назвами; у A0–A1 немає двох діалогів з однаковою назвою');

-- ---------------------------------------------------------------- перевірки
select pg_temp.ok(pg_temp.n($q$select a.slug from public.assessments a join public.assessment_items i on i.assessment_id = a.id and i.status = 'PUBLISHED'
   where a.cefr = 'A1' and a.slug in ('a1-m06', 'a1-m08', 'a1-m11', 'a1-m12', 'a1-final')
   group by a.slug having count(*) = case a.slug when 'a1-m06' then 18 when 'a1-m08' then 20 when 'a1-m11' then 16 when 'a1-m12' then 14 else 48 end$q$) = 5,
  'перевірки: a1-m06 — 18, a1-m08 — 20 (11 уроків, щонайбільше 20), a1-m11 — 16, a1-m12 — 14, a1-final — 48');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id and a.cefr = 'A1' and a.kind = 'module'
   join public.lessons l on l.id = i.lesson_id join public.units u on u.id = l.unit_id
  where i.status = 'PUBLISHED' and u.module_id is distinct from a.module_id$q$) = 0
  and pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
   where a.slug = 'a1-m08' and i.status = 'PUBLISHED' and i.lesson_id = '692e9310-7a5b-5adf-9f0a-a66b72fc5459'$q$) >= 1
  and pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
   where a.slug = 'a1-m11' and i.status = 'PUBLISHED' and i.lesson_id in ('5ae02c5f-7ba1-5b59-be71-f744d6e9b169',
         'b026f1b1-879d-59b5-8506-ee99e128c9c1', '8bb4331d-c7c0-5039-acf9-756684424039')$q$) >= 3,
  'завдання тестів модулів — з уроків свого модуля; в a1-m08 є «Надзвичайні ситуації», в a1-m11 — нові уроки');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id and a.cefr = 'A1'
   where i.status = 'PUBLISHED' and lower(coalesce(i.answer_text, '')) in ('bruto', 'neto', 'porez', 'doprinosi', 'platna lista', 'tableta',
         'lijek protiv bolova', 'katedrala', 'zidine', 'polagati', 'položiti', 'svjedodžba', 'uvjerenje', 'priznavanje')$q$) = 0
  and pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id and a.cefr = 'A1'
   where i.status = 'PUBLISHED' and i.passage_hr like '%Bravo! Što ćeš sada?%'$q$) = 0,
  'у перевірках A1 немає завдань на прибрані слова й діалоги');
select pg_temp.ok((select count(distinct m.order_index) from public.assessment_items i join public.assessments a on a.id = i.assessment_id
    join public.lessons l on l.id = i.lesson_id join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
   where a.slug = 'a1-final' and a.cefr = 'A1' and i.status = 'PUBLISHED') = 13,
  'фінал A1 — завдання з усіх 13 модулів');

select 'ALL TESTS PASSED';
rollback;
