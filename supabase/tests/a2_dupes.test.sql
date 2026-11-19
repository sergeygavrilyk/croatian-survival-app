-- =====================================================================
-- Тест пакетів 20261119_a2_dupes_1_lessons.sql і _2_tests_*.sql — дублі A2 (план «Дублі й сенс уроків», PR 4) і перевірки
-- рівнів A1 і A2 наново: Д1 (27), Д2 (9), Д5 (38), Д6 (29), Д7 (70 → 71), Д8 (33 і 44); новий урок A2.11 «Далмація: Задар
-- і околиці» (70); 6 назв діалогів; уроків A2 — 87; усі 31 тест A1 і A2 — наново (v5, схема 2026-11-07).
-- Запускати ПІСЛЯ обох пакетів. БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK. Успіх: «ALL TESTS PASSED».
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

-- уроки пакета: 9, 27, 29, 33, 38, 44, 71 (був 70), новий 70
create or replace function pg_temp.les() returns table (lid uuid, n int) language sql as $$
  select * from (values ('8190831a-549a-544a-962b-4f716a895a32'::uuid, 9), ('f029711f-710e-5327-be4d-2310435e6eac'::uuid, 27),
                        ('5252662a-abfc-517a-9bde-8683121a53c5'::uuid, 29), ('0e0d07a2-2a6c-5090-ab84-3089f20a48b8'::uuid, 33),
                        ('bf43b6bd-d547-596b-8981-55a4043cf238'::uuid, 38), ('8f08356b-8efa-5ebc-906e-f409fbaadaf3'::uuid, 44),
                        ('7d3c3501-a381-5b3c-a0a2-b269f3dff137'::uuid, 71), ('185cee8e-46a7-58b2-bc82-166ba74dc272'::uuid, 70)) as t(lid, n)
$$;

-- ---------------------------------------------------------------- нумерація і модуль A2.11
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A2' and status = 'PUBLISHED'$q$) = 87
  and pg_temp.n($q$select 1 from (select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A2' and l.status = 'PUBLISHED') t
     where t.title_ua !~ ('^Урок ' || t.n || ':') or t.title_hr !~ ('^Lekcija ' || t.n || ':')$q$) = 0,
  'уроків A2 — 87 (було 86), номери 1…87 українською й хорватською без пропусків');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where unit_id = '3fbc4d9b-4366-5f0f-b785-eb3f750240be' and status = 'PUBLISHED'
       and (order_index, title_ua) in ((4, 'Урок 69: Загреб і Загор’є'), (5, 'Урок 70: Далмація: Задар і околиці'),
            (6, 'Урок 71: Звичаї й етикет: як поводитися'), (7, 'Урок 72: Клапа, тамбурица й спадщина ЮНЕСКО'))$q$) = 4
  and pg_temp.n($q$select 1 from public.lessons where unit_id = '3fbc4d9b-4366-5f0f-b785-eb3f750240be' and status = 'PUBLISHED'$q$) = 7
  and (select title_hr from public.lessons where id = '185cee8e-46a7-58b2-bc82-166ba74dc272') = 'Lekcija 70: Dalmacija: Zadar i okolica',
  'A2.11 — 7 уроків: «Далмація: Задар і околиці» (70) — одразу після «Загреб і Загор’є», далі етикет (71) і клапа (72)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join pg_temp.les() t on t.lid = l.id
   where l.status = 'PUBLISHED' and l.title_ua ~ ('^Урок ' || t.n || ':')$q$) = 8
  and pg_temp.n($q$select 1 from public.lessons where status = 'PUBLISHED' and (id, title_ua, title_hr) in (
    ('5252662a-abfc-517a-9bde-8683121a53c5'::uuid, 'Урок 29: Сусіди: збори й шкода', 'Lekcija 29: Susjedi: sastanak stanara i šteta'),
    ('0e0d07a2-2a6c-5090-ab84-3089f20a48b8'::uuid, 'Урок 33: Відпустка й вихідні дні', 'Lekcija 33: Godišnji odmor i slobodni dani'))$q$) = 2,
  'номери уроків пакета — нові; нові назви уроків 29 і 33 (обидві мови)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations c join public.lessons l on l.id = c.lesson_id
  where l.level_code = 'A2' and l.status = 'PUBLISHED' and c.status = 'PUBLISHED'
    and c.order_index / 10 <> 500 + substring(l.title_ua from '^Урок ([0-9]+):')::int$q$) = 0,
  'порядок діалогів A2 — за новим номером уроку (5000 + N·10 + k)');

-- ---------------------------------------------------------------- склад уроків пакета
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.les() t
  where (select count(*) from public.lesson_items li where li.lesson_id = t.lid and li.item_type = 'lexeme') not between 20 and 25
     or (select count(*) from public.conversations c where c.lesson_id = t.lid and c.status = 'PUBLISHED') <> 2
     or exists (select 1 from public.conversations c where c.lesson_id = t.lid and c.status = 'PUBLISHED'
                 and (select count(*) from public.conversation_turns x where x.conversation_id = c.id) not between 6 and 8)
     or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
          where li.lesson_id = t.lid and li.item_type = 'exercise' and e.status = 'PUBLISHED' and li.required) <> 15
     or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
          where li.lesson_id = t.lid and li.item_type = 'exercise' and e.status = 'PUBLISHED' and not li.required
            and e.exercise_type in ('write_message', 'mediation')) <> 2
     or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
          where li.lesson_id = t.lid and e.exercise_type = 'listening_dialogue' and e.status = 'PUBLISHED') <> 1
     or exists (select 1 from public.lesson_items li join public.exercises e on e.id = li.item_id
                 where li.lesson_id = t.lid and li.item_type = 'exercise' and e.status <> 'PUBLISHED')$q$) = 0,
  'уроки пакета: 20–25 слів, 2 діалоги по 6–8 реплік, 15 обов’язкових вправ, «на слух», письмо й переказ — усе опубліковане');
select pg_temp.ok(pg_temp.n($q$select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
  where l.level_code = 'A2' and l.status = 'PUBLISHED' and li.item_type = 'lexeme' group by 1 having count(*) > 1$q$) = 0,
  'слова уроків A2 не повторюються між уроками');

-- Д1 (27): без «згоден / не згоден / ти правий», + аргументація
select pg_temp.ok((select count(*) from pg_temp.w('f029711f-710e-5327-be4d-2310435e6eac') w
                    where w in ('slagati se', 'ne slažem se', 'u pravu si', 'nisi u pravu', 'po meni')) = 0
  and (select count(*) from pg_temp.w('f029711f-710e-5327-be4d-2310435e6eac') w
        where w in ('uvjerljiv', 'popustiti', 'inzistirati', 'opravdan', 'dokaz')) = 5,
  'урок 27: без 5 виразів згоди (вони в A1 «Що ти думаєш?»), + uvjerljiv, popustiti, inzistirati, opravdan, dokaz');
-- Д2 (9): без запису на курс
select pg_temp.ok((select count(*) from pg_temp.w('8190831a-549a-544a-962b-4f716a895a32') w
                    where w in ('početni tečaj', 'napredni tečaj', 'test razine', 'upisivati', 'upisati se', 'polaznica')) = 0
  and (select count(*) from pg_temp.w('8190831a-549a-544a-962b-4f716a895a32') w
        where w in ('razina znanja', 'konverzacija', 'zaostajati', 'sudjelovati', 'ispravljati', 'samostalno učiti')) = 6
  and exists (select 1 from public.conversations where lesson_id = '8190831a-549a-544a-962b-4f716a895a32' and status = 'PUBLISHED' and title_hr = 'Kako napredujem?')
  and (select status from public.conversations where id = 'd198b0f9-0676-53cf-87d3-3c1468482649') = 'DEPRECATED',
  'урок 9: без 6 слів запису на курс (запис — в A1-105), + прогрес і розмовна практика; «Upis na tečaj» → «Kako napredujem?»');
-- Д6 (29), Д5 (38), Д7 (71)
select pg_temp.ok((select count(*) from pg_temp.w('5252662a-abfc-517a-9bde-8683121a53c5') w where w in ('glasna glazba', 'lupati', 'smetati', 'utišati')) = 0
  and (select count(*) from pg_temp.w('5252662a-abfc-517a-9bde-8683121a53c5') w where w in ('procuriti', 'fasada', 'popravak krova', 'nadoknada štete')) = 4
  and exists (select 1 from public.conversations where lesson_id = '5252662a-abfc-517a-9bde-8683121a53c5' and status = 'PUBLISHED' and title_hr = 'Poplavio nas je susjed'),
  'урок 29: без шуму (він в A1-48), + шкода й ремонт; «Buka navečer» → «Poplavio nas je susjed»');
select pg_temp.ok((select count(*) from pg_temp.w('bf43b6bd-d547-596b-8981-55a4043cf238') w where w in ('kapati', 'iskočio je osigurač', 'začepiti se')) = 0
  and (select count(*) from pg_temp.w('bf43b6bd-d547-596b-8981-55a4043cf238') w where w in ('rok završetka', 'kašnjenje radova', 'plaćanje gotovinom')) = 3
  and pg_temp.n($q$select 1 from public.conversations where lesson_id = 'bf43b6bd-d547-596b-8981-55a4043cf238' and status = 'PUBLISHED'
       and title_hr in ('Mijenjamo bravu', 'Predračun za pločice')$q$) = 2,
  'урок 38: без «тече кран» і «немає світла» (A1-45), + термін, затримка, оплата; 2 нові діалоги');
select pg_temp.ok((select count(*) from pg_temp.w('7d3c3501-a381-5b3c-a0a2-b269f3dff137') w where w in ('persirati', 'tikati')) = 0
  and (select count(*) from pg_temp.w('7d3c3501-a381-5b3c-a0a2-b269f3dff137') w where w in ('gostoprimstvo', 'nutkati')) = 2
  and exists (select 1 from public.conversations where lesson_id = '7d3c3501-a381-5b3c-a0a2-b269f3dff137' and status = 'PUBLISHED' and title_hr = 'Ručak kod Ivaninih roditelja')
  and not exists (select 1 from public.lesson_items li join public.exercises e on e.id = li.item_id
                   where li.lesson_id = '7d3c3501-a381-5b3c-a0a2-b269f3dff137' and e.status = 'PUBLISHED'
                     and (e.correct_answer || coalesce(e.task::text, '')) ~* '(persira|tika)'),
  'урок 71: без «ти чи Ви» (A1-77) — ні в словах, ні у вправах; «Ti ili Vi?» → «Ručak kod Ivaninih roditelja»');
-- Д8 (33 → 44)
select pg_temp.ok((select count(*) from pg_temp.w('0e0d07a2-2a6c-5090-ab84-3089f20a48b8') w
                    where w in ('otvoriti bolovanje', 'zatvoriti bolovanje', 'biti na bolovanju', 'javiti se bolestan')) = 0
  and (select count(*) from pg_temp.w('8f08356b-8efa-5ebc-906e-f409fbaadaf3') w
        where w in ('otvoriti bolovanje', 'zatvoriti bolovanje', 'javiti se bolestan')) = 3
  and (select count(*) from pg_temp.w('8f08356b-8efa-5ebc-906e-f409fbaadaf3') w where w in ('povraćati', 'proljev')) = 0
  and (select count(*) from pg_temp.w('0e0d07a2-2a6c-5090-ab84-3089f20a48b8') w
        where w in ('zamjena smjene', 'kolektivni godišnji odmor', 'prenijeti dane', 'pravo na godišnji')) = 4
  and (select count(*) from public.lesson_items where lesson_id = '8f08356b-8efa-5ebc-906e-f409fbaadaf3' and item_type = 'lexeme') = 22,
  'Д8: лікарняний — в уроці 44 (22 слова, без симптомів A1-74), урок 33 — лише відпустка');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations where status = 'DEPRECATED' and id in (
    'd198b0f9-0676-53cf-87d3-3c1468482649', '318010bf-019c-5e76-86ff-4cb83577f32c', 'b5b1477b-4b6a-54e0-84a7-be89bf1dd927',
    'c590ba13-4ead-5ddf-a528-f7ed37bbf8be', '3b36368a-5bfe-5451-a5a1-b345a714350f', '83c1bbe5-d130-5039-bf75-94e1be89f88a',
    '4b330410-5e4a-5b9e-9470-0f20bcc5f475')$q$) = 7,
  '7 старих діалогів — DEPRECATED, не видалені');
-- у вправах уроків пакета немає прибраних слів
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items li join pg_temp.les() t on t.lid = li.lesson_id
  join public.exercises e on e.id = li.item_id and e.status = 'PUBLISHED' join public.lexemes x on x.id = e.lexeme_id
  where lower(x.lemma) in ('slagati se', 'ne slažem se', 'u pravu si', 'nisi u pravu', 'po meni', 'početni tečaj', 'napredni tečaj', 'test razine',
                           'upisivati', 'upisati se', 'polaznica', 'glasna glazba', 'lupati', 'smetati', 'utišati', 'biti na bolovanju',
                           'kapati', 'iskočio je osigurač', 'začepiti se', 'povraćati', 'proljev', 'persirati', 'tikati')$q$) = 0,
  'немає вправ на прибрані слова');

-- ---------------------------------------------------------------- новий урок «Далмація: Задар і околиці»
select pg_temp.ok((select count(*) from public.lesson_items where lesson_id = '185cee8e-46a7-58b2-bc82-166ba74dc272' and item_type = 'lexeme') = 23
  and (select count(*) from pg_temp.w('185cee8e-46a7-58b2-bc82-166ba74dc272') w
        where w in ('morske orgulje', 'pozdrav suncu', 'forum', 'maraskino', 'fjaka', 'poluotok', 'otočje', 'kanjon')) = 0
  and pg_temp.n($q$select 1 from public.conversations where lesson_id = '185cee8e-46a7-58b2-bc82-166ba74dc272' and status = 'PUBLISHED'
       and title_hr in ('Vikend u Ninu', 'Živjeti u Zadru')$q$) = 2,
  'новий урок 70: 23 слова без слів A1-90 «Задар», 2 діалоги («Vikend u Ninu», «Živjeti u Zadru»)');
select pg_temp.ok((select li.target_skill from public.lesson_items li join public.lexemes x on x.id = li.item_id
                    where li.lesson_id = '185cee8e-46a7-58b2-bc82-166ba74dc272' and lower(x.lemma) = 'đir') = 'recognition'
  and (select count(*) from public.lesson_items li where li.lesson_id = '185cee8e-46a7-58b2-bc82-166ba74dc272'
        and li.item_type = 'lexeme' and li.target_skill = 'recognition') = 1
  and exists (select 1 from public.lexemes where lemma = 'đir' and register = 'colloquial' and regionality = 'Dalmatia'
               and usage_tags = array['italianism'] and status = 'PUBLISHED')
  and not exists (select 1 from public.lesson_items li join public.exercises e on e.id = li.item_id
                   where li.lesson_id = '185cee8e-46a7-58b2-bc82-166ba74dc272' and e.exercise_type <> 'listening_dialogue'
                     and (e.correct_answer || ' ' || e.question_text || ' ' || coalesce(e.options::text, '')) ~* '\mđir\M'),
  'đir — лише впізнавати (target_skill = recognition; розмовне, Далмація, італізм), вправ на нього немає');
select pg_temp.ok((select count(*) from public.exercises e join public.lesson_items li on li.item_id = e.id
                    where li.lesson_id = '185cee8e-46a7-58b2-bc82-166ba74dc272' and e.exercise_type = 'listening_dialogue'
                      and (select count(*) from jsonb_array_elements(e.task -> 'questions') q where q ? 'answer_text') = 1) = 1,
  '«на слух» у новому уроці (A2.11): рівно одне питання з короткою відповіддю');

-- ---------------------------------------------------------------- нові слова
select pg_temp.ok((select count(*) from public.lexemes where source = 'claude_a2_dupes' and status = 'PUBLISHED' and cefr = 'A2'
                    and register is not null and regionality is not null and usage_tags is not null) = 43
  and (select count(*) from public.lexemes where source = 'claude_a2_dupes' and normalized ~ '[čćđšž]') = 0
  and (select count(*) from public.lexemes where lower(lemma) in ('dokaz', 'ispravljati', 'sudjelovati', 'morska sol')
        and status = 'PUBLISHED' and cefr = 'A2') = 4,
  '43 нові слова (A2, з мітками, normalized без діакритики); 4 наявні слова без уроку — рівень A2');

-- ---------------------------------------------------------------- діалоги
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations where status = 'PUBLISHED' and (id, title_hr) in (
    ('2c8cd7ee-e3d3-58d3-8ffe-420bf19fdb8e'::uuid, 'Prijava u hotel'), ('9140c599-ceba-5bbb-8214-54c16f55a70c'::uuid, 'Pogreška u računu'),
    ('dc69dcd8-ddd4-5c6c-b7c8-2d9b9d770f84'::uuid, 'Rang-lista'), ('14d9a946-c3e1-58cf-bff8-0c2cca867149'::uuid, 'Dobio sam otkaz'),
    ('82cdf22b-ae0c-5783-898e-bed827a54a1e'::uuid, 'Zamjena vozačke dozvole'), ('b4dd1542-9a39-5b6b-b285-9b12c3a68061'::uuid, 'Rad od kuće: za i protiv'))$q$) = 6
  and pg_temp.n($q$select 1 from public.conversations c join public.lessons l on l.id = c.lesson_id
       where c.status = 'PUBLISHED' and l.status = 'PUBLISHED' and l.level_code in ('A0', 'A1', 'A2')
       group by lower(c.title_hr) having count(*) > 1$q$) = 0,
  '6 нових назв діалогів; однакових назв діалогів в A0–A2 більше немає');

-- ---------------------------------------------------------------- старе не втрачено
select pg_temp.ok((select count(distinct lesson_id) from backup.lesson_items_a2dupes_20261119) = 7
  and pg_temp.n($q$select 1 from public.content_versions where entity_type = 'lesson' and change_reason like 'a2_dupes: %— стара версія'
       and entity_id in (select lid from pg_temp.les())$q$) >= 7
  and pg_temp.n($q$select 1 from public.content_versions where entity_type = 'conversation' and change_reason like 'a2_dupes: нова назва%'$q$) = 6,
  'склад 7 уроків — у backup.lesson_items_a2dupes_20261119; старі версії уроків і назви діалогів — у content_versions');

-- ---------------------------------------------------------------- перевірки рівнів A1 і A2 наново
create temp view rb as
select a.slug, a.kind, a.module_id, i.* from public.assessment_items i join public.assessments a on a.id = i.assessment_id
 where a.cefr in ('A1', 'A2') and a.status = 'PUBLISHED' and i.status = 'PUBLISHED' and i.cefr = a.cefr;
select pg_temp.ok(pg_temp.n($q$select 1 from rb$q$) = 562
  and pg_temp.n($q$select 1 from rb where cefr = 'A1'$q$) = 302 and pg_temp.n($q$select 1 from rb where cefr = 'A2'$q$) = 260
  and pg_temp.n($q$select distinct slug from rb$q$) = 31
  and pg_temp.n($q$select 1 from public.content_versions where entity_type = 'assessment' and change_reason like 'assessment_rebuild_20261119:%'$q$) = 31,
  'усі 31 тест A1 (302 завдання) і A2 (260) — наново; стара версія кожного — у content_versions');
select pg_temp.ok(pg_temp.n($q$select slug from rb group by slug, kind, module_id
  having count(*) <> case kind when 'module' then greatest(12, least(20, 2 * (select count(*) from public.lessons l join public.units u on u.id = l.unit_id
                                                                                where u.module_id = rb.module_id and l.status = 'PUBLISHED')))
                               when 'mid' then 30 else 48 end$q$) = 0
  and pg_temp.n($q$select 1 from rb where slug = 'a2-m11'$q$) = 14,
  'схема 2026-11-07: модуль — 2 завдання на урок (12–20; a2-m11 — 14), середина — 30, фінал — 48');
select pg_temp.ok(pg_temp.n($q$select 1 from rb join public.lessons l on l.id = rb.lesson_id join public.units u on u.id = l.unit_id
  where rb.kind = 'module' and u.module_id <> rb.module_id$q$) = 0
  and pg_temp.n($q$select 1 from rb left join public.lessons l on l.id = rb.lesson_id
       where rb.lesson_id is not null and (l.id is null or l.status <> 'PUBLISHED' or l.level_code <> rb.cefr)$q$) = 0,
  'завдання — з опублікованих уроків свого рівня; тест модуля — лише з уроків цього модуля');
select pg_temp.ok(pg_temp.n($q$select 1 from rb x join rb y on y.cefr = x.cefr and y.kind = 'module' and x.kind <> 'module'
  where coalesce(x.audio_hr, x.answer_text) is not null
    and lower(coalesce(x.audio_hr, x.answer_text)) in (lower(y.audio_hr), lower(y.answer_text), lower(y.prompt_hr))$q$) = 0,
  'репліки й відповіді середини та фіналу не повторюють перевірок модулів');
-- хибні варіанти й тексти завдань — лише з того, що є в курсі: не з прибраних діалогів (DEPRECATED, і їхньої репліки немає в опублікованих)
select pg_temp.ok(pg_temp.n($q$select 1 from rb, lateral (select jsonb_array_elements_text(case when jsonb_typeof(rb.options) = 'array' then rb.options else '[]'::jsonb end) o
                                                          union all select rb.audio_hr union all select rb.answer_text) s(t)
  where s.t in (select t.hr_text from public.conversation_turns t join public.conversations c on c.id = t.conversation_id
                 join public.lessons l on l.id = c.lesson_id where c.status = 'DEPRECATED' and l.level_code in ('A1', 'A2'))
    and s.t not in (select t.hr_text from public.conversation_turns t join public.conversations c on c.id = t.conversation_id where c.status = 'PUBLISHED')$q$) = 0,
  'у перевірках A1 / A2 немає реплік з прибраних діалогів (і як хибних варіантів)');
select pg_temp.ok(pg_temp.n($q$select 1 from rb where coalesce(audio_hr, '') || coalesce(answer_text, '') || coalesce(passage_hr, '')
  || array_to_string(answer_alternatives, ' ') ~ '[Ѐ-ӿ]'$q$) = 0
  and pg_temp.n($q$select 1 from rb where item_type = 'sentence_builder'
       and (select string_agg(o, ' ' order by o) from jsonb_array_elements_text(options) o)
           <> (select string_agg(w, ' ' order by w) from regexp_split_to_table(trim(answer_text), '\s+') w)$q$) = 0,
  'хорватське без кирилиці; «Складіть» — плитки рівно зі слів відповіді');

select 'ALL TESTS PASSED' as result;
rollback;
