-- =====================================================================
-- Тести: програма A1 v3 (структура з 13 модулів + перебудовані модулі) · 2026-10-26
-- Запускати ПІСЛЯ 20261026_curriculum_a1_v3_structure.sql і SQL модулів (20261026_curriculum_a1_v3_m01.sql …).
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

-- уроки, перебудовані або створені за програмою A1 v3 (мають діалоги пакета v3)
create temp view v3_lessons as
  select distinct c.lesson_id as id from public.conversations c where c.source = 'claude_curriculum_a1_v3' and c.status = 'PUBLISHED';

-- ---------------------------------------------------------------- структура
select pg_temp.ok(pg_temp.n($q$select 1 from public.modules where level_code = 'A1' and status = 'PUBLISHED'
  and title_ua = 'Модуль A1.' || order_index || ' — ' || split_part(title_ua, ' — ', 2) and order_index between 1 and 13$q$) = 13,
  'A1: 13 модулів «Модуль A1.N — …» на місцях 1…13');
select pg_temp.ok(pg_temp.n($q$select 1 from public.modules where (id, order_index) in
  (('e4b28ab0-2aa7-5d37-885b-6908dc14e17b'::uuid, 8), ('4fae6fe1-6bf2-5eef-9023-f7425b151c9e'::uuid, 9),
   ('4a99a045-1da4-5ac1-be05-74811dd7d630'::uuid, 10), ('34064af4-9715-5f07-b87c-a5e28eb8127b'::uuid, 13),
   ('09e7c668-b622-56b2-82e9-b1c0c0db54c6'::uuid, 7))$q$) = 5,
  'id модуля лишився з темою: «Здоров’я» — A1.8, «Люди» — A1.9, «Хорватія» — A1.10, «Підсумок» — A1.13; новий A1.7');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments a join public.modules m on m.id = a.module_id
  where a.cefr = 'A1' and a.kind = 'module' and a.slug <> 'a1-m' || lpad(m.order_index::text, 2, '0')$q$) = 0,
  'перевірка модуля A1 має адресу за новим номером модуля (a1-m08 = «Здоров’я»)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where l.id in ('08e31e8b-f8f7-5a80-89ed-093bc68dae03', '31bbedca-4b51-5478-8513-df5cb996ffd9', 'f1b2093d-9699-59af-92b9-ed7bdf7fad49',
                 '42c31cfb-8680-5450-8453-245f3abd475a', 'fc1baff0-0e48-5676-bd3c-47d88d31e582')
    and (l.id, m.order_index, l.order_index) in
        (('08e31e8b-f8f7-5a80-89ed-093bc68dae03'::uuid, 8, 1), ('31bbedca-4b51-5478-8513-df5cb996ffd9'::uuid, 7, 2),
         ('f1b2093d-9699-59af-92b9-ed7bdf7fad49'::uuid, 11, 2), ('42c31cfb-8680-5450-8453-245f3abd475a'::uuid, 12, 1),
         ('fc1baff0-0e48-5676-bd3c-47d88d31e582'::uuid, 13, 1))$q$) = 5,
  'уроки на місцях програми: «Запис до лікаря» A1.8.1, «Магазин електроніки» A1.7.2, «Хорватська кухня» A1.11.2, «Садок» A1.12.1, «Про себе» A1.13.1');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where cefr = 'A1' and module_order in (7, 11, 12)
    and source <> 'claude_reading_a1_v3'$q$) = 0
  and pg_temp.n($q$select 1 from public.reading_texts where cefr = 'A1' and module_order = 13$q$) > 0,
  'тексти A1 — за своїм модулем (старі A1.7–A1.10 → A1.8–A1.10, A1.13; у 7, 11, 12 — лише нові тексти 2026-11-04)');
select pg_temp.ok(pg_temp.n($q$select 1 from backup.modules_a1_20261026$q$) = 10 and pg_temp.n($q$select 1 from backup.units_a1_20261026$q$) = 10,
  'стара версія 10 модулів і юнітів A1 — у backup');

-- ---------------------------------------------------------------- модуль A1.1
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join v3_lessons v on v.id = l.id
  where l.unit_id = '893000a6-3e62-528c-8ecf-e644f677823c' and l.order_index between 1 and 10$q$) = 10,
  'A1.1: 10 уроків за програмою v3 на місцях 1…10 (9 перебудованих + «Корисні слова»)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id = 'ad0bc1f4-2808-5b24-969d-9da64d4a7a4d'
  and title_ua like 'Урок 10: Корисні слова%' and status = 'PUBLISHED'$q$) = 1, 'новий урок «Корисні слова» — урок 10');

-- ---------------------------------------------------------------- модуль A1.2
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join v3_lessons v on v.id = l.id
  where l.unit_id = '54c21ee3-db66-5d1e-9eca-7223a2e6f6e4' and l.order_index between 1 and 11$q$) = 11,
  'A1.2: 11 уроків за програмою v3 (10 перебудованих + «Посуд і сервірування»)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id = '213ab10f-63a4-5e1c-8b2e-156c433de874'
  and title_ua like 'Урок 16: Посуд і сервірування' and status = 'PUBLISHED'$q$) = 1, 'новий урок «Посуд і сервірування» — урок 16');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and g.title_ua = 'Числа й кількість: dva kruha, pet jaja' and g.status = 'PUBLISHED' and jsonb_array_length(r.examples) >= 4$q$) = 3
  and pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and g.title_ua = 'Знахідний відмінок'$q$) >= 4,
  'нова тема «Числа й кількість» (3 правила) і правило «Знахідний відмінок: множина»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma = 'kava za van' and ukrainian_translation = 'кава з собою'$q$) = 1,
  'виправлено переклад kava za van');

-- ---------------------------------------------------------------- модуль A1.3
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join v3_lessons v on v.id = l.id
  where l.unit_id = '480b3ca1-58c7-5b6f-8a52-eff47d53b3e4' and l.order_index between 1 and 8$q$) = 8,
  'A1.3: 8 уроків за програмою v3 (5 перебудованих + 3 нові)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where status = 'PUBLISHED' and (id, title_ua) in (
  ('9a979d32-2f4b-5127-bc22-7292763c7de4', 'Урок 22: Подобається чи ні?'),
  ('7fb1b6e5-93b4-5776-b82b-25e7769fd32d', 'Урок 24: У приміряльні: розмір і фасон'),
  ('86d268a5-7193-53c5-955b-cf6cc69116f1', 'Урок 26: Прикраси й подарунки'))$q$) = 3, 'нові уроки A1.3 — 22, 24, 26');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and g.title_ua = 'Короткі форми давального: sviđa mi se' and g.status = 'PUBLISHED' and jsonb_array_length(r.examples) >= 4$q$) = 4
  and pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and g.title_ua = 'Ступені порівняння'$q$) >= 4,
  'нова тема «Короткі форми давального» (4 правила), правила «Прикметник + іменник» і «bolji, veći, manji»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where (lemma, ukrainian_translation) in
  (('svidjeti se', 'сподобатися'), ('stajati', 'стояти; коштувати; личити (stoji ti dobro)'), ('isti', 'той самий; однаковий'))$q$) = 3,
  'уточнено переклади svidjeti se, stajati, isti');

-- ---------------------------------------------------------------- модуль A1.4
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join v3_lessons v on v.id = l.id
  where l.unit_id = '72a3eec1-fb04-5e99-a0ea-da4f6bc07ed5' and l.order_index between 1 and 10$q$) = 10,
  'A1.4: 10 уроків за програмою v3 (9 перебудованих + «Куди йдемо?»)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id = '12012395-7359-503b-89c9-ee1807f89d6b'
  and title_ua = 'Урок 30: Куди йдемо? Kamo чи gdje?' and status = 'PUBLISHED'$q$) = 1, 'новий урок «Куди йдемо?» — урок 30');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_topics g where g.cefr = 'A1' and g.status = 'PUBLISHED'
  and g.title_ua in ('Kamo? і Gdje?: u grad — u gradu', 'Орудний відмінок: autobusom, s prijateljem')
  and (select count(*) from public.grammar_rules r where r.topic_id = g.id and jsonb_array_length(r.examples) >= 4) = 4$q$) = 2,
  'нові теми «Kamo? і Gdje?» і «Орудний відмінок» (по 4 правила)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.lesson_grammar lg on lg.lesson_id = l.id
  join public.grammar_topics g on g.id = lg.grammar_topic_id
  where l.id = '0ef458c5-53cf-530a-99cf-4ccd6e0132e5' and g.title_ua like 'Орудний%'$q$) = 1,
  'урок 31 «У трамваї й автобусі» — граматика «Орудний відмінок»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where (lemma, ukrainian_translation) in
  (('kuda', 'куди, якою дорогою'), ('pumpa', 'заправка (АЗС); насос'))$q$) = 2, 'уточнено переклади kuda, pumpa');

-- ---------------------------------------------------------------- модуль A1.5
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join v3_lessons v on v.id = l.id
  where l.unit_id = 'c80b7070-95f0-54de-b4dd-90d024f5b830' and l.order_index between 1 and 10$q$) = 10,
  'A1.5: 10 уроків за програмою v3 (9 перебудованих + «Мій район»)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id = '3ea9520d-2baa-56b2-aa85-402e3e3ecb9b'
  and title_ua = 'Урок 41: Мій район: що поруч?' and status = 'PUBLISHED'$q$) = 1, 'новий урок «Мій район» — урок 41');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and r.title_ua in ('Прикметник у місцевому: u novom stanu, na prvom katu',
    'Blizu, pokraj, preko puta, nasuprot, oko + родовий') and jsonb_array_length(r.examples) >= 4$q$) = 2,
  'нові правила: місцевий із прикметником, прийменники + родовий');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma = 'blizina' and ukrainian_translation = 'близькість (u blizini — поруч)'$q$) = 1,
  'уточнено переклад blizina');

-- ---------------------------------------------------------------- модуль A1.6
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join v3_lessons v on v.id = l.id
  where l.unit_id = '874caaa6-f5e5-5c4f-acf4-cfdb0e510116' and l.order_index between 1 and 9$q$) = 9,
  'A1.6: 9 уроків за програмою v3');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and g.title_ua = 'Минулий час: radio sam, bila sam' and g.status = 'PUBLISHED' and jsonb_array_length(r.examples) >= 4$q$) >= 4
  and pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and r.title_ua = 'Ne moraš і ne smiješ'$q$) = 1,
  'нова тема «Минулий час» (4 правила) і правило «Ne moraš і ne smiješ»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.lesson_grammar lg on lg.lesson_id = l.id
  join public.grammar_topics g on g.id = lg.grammar_topic_id
  where l.id in ('92858dbe-ede1-5bc5-b80a-c796c5598019', '2c56a486-dbbb-5102-b7cb-754c59cf94c3') and g.title_ua like 'Минулий час%'$q$) = 2,
  'уроки 53 і 55 — граматика «Минулий час»');

-- ---------------------------------------------------------------- модуль A1.7
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join v3_lessons v on v.id = l.id
  where l.unit_id = 'f5b3441e-2c2a-52bf-825e-a316aae00588' and l.order_index between 1 and 7$q$) = 7,
  'A1.7: 7 уроків за програмою v3 (3 перенесені + 4 нові)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where status = 'PUBLISHED' and (id, title_ua) in (
  ('8e08a8e3-8969-52fc-bc82-5a403dd7ad35', 'Урок 59: Комп’ютер і телефон'),
  ('f355be7d-c423-5651-938e-71b8ca970a62', 'Урок 63: Акаунт і пароль: я забув пароль'))$q$) = 2, 'нові уроки A1.7 — 59 і 63');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and g.title_ua = 'Минулий час: radio sam, bila sam'$q$) >= 6,
  'тема «Минулий час» — щонайменше 6 правил (+ «Poslao sam ti ga», «Pisala sam і napisala sam»)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug = 'a1-m07' and a.kind = 'module' and a.status = 'PUBLISHED' and i.status = 'PUBLISHED'$q$) = 10,
  'новий тест a1-m07 — 10 завдань');

-- ---------------------------------------------------------------- модуль A1.8
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join v3_lessons v on v.id = l.id
  where l.unit_id = '2eec2289-6a8a-5fb2-9988-e52433d5a242' and l.order_index between 1 and 10$q$) = 10,
  'A1.8: 10 уроків за програмою v3 (9 перебудованих + «Внутрішні органи»)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id = 'b6859b5e-db71-543a-8d05-db9b43811d8a'
  and title_ua = 'Урок 67: Внутрішні органи' and status = 'PUBLISHED'$q$) = 1, 'новий урок «Внутрішні органи» — урок 67');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and r.title_ua in ('«Давайте»: uzmimo, idemo; neka uzme', 'Se в минулому: ozlijedio sam se, on se ozlijedio')$q$) = 2,
  'нові правила: наказовий для «ми» й neka; se в минулому часі');

-- ---------------------------------------------------------------- модуль A1.9
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join v3_lessons v on v.id = l.id
  where l.unit_id = '0df70119-403a-517e-af33-8073d14fca03' and l.order_index between 1 and 10$q$) = 10,
  'A1.9: 10 уроків за програмою v3 (8 перебудованих + 2 нові)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where status = 'PUBLISHED' and (id, title_ua) in (
  ('6df343ef-4a40-5dfb-9100-7ab47fb1667d', 'Урок 76: Як звернутися? Dašo! Gospodine!'),
  ('3f440ad8-f057-5898-b773-6aa8816fa8a3', 'Урок 83: Хтось, щось, десь'))$q$) = 2, 'нові уроки A1.9 — 76 і 83');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_topics g where g.cefr = 'A1' and g.status = 'PUBLISHED'
  and g.title_ua in ('Кличний відмінок: Dašo! Ivane! Gospodine!', 'Неозначені займенники: netko, nešto, negdje')
  and (select count(*) from public.grammar_rules r where r.topic_id = g.id and jsonb_array_length(r.examples) >= 4) = 4$q$) = 2
  and pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and g.title_ua = 'Сполучники' and r.title_ua like 'Da, kad, ako%'$q$) = 1,
  'нові теми «Кличний відмінок» і «Неозначені займенники» (по 4 правила), правило «Da, kad, ako»');

-- ---------------------------------------------------------------- модуль A1.10
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join v3_lessons v on v.id = l.id
  where l.unit_id = '704b6312-30cc-5a3c-94ff-c2a2dfd1b17c' and l.order_index between 1 and 7$q$) = 7,
  'A1.10: 7 уроків за програмою v3 (4 перебудовані + 3 нові)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where status = 'PUBLISHED' and level_code = 'A1'
  and title_ua in ('Урок 87: Плани на відпустку', 'Урок 89: Далмація: Задар', 'Урок 92: Дикі тварини')$q$) = 3,
  'нові уроки A1.10 — 87, 89 і 92 (Далмація одразу після «Краї Хорватії»)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and g.status = 'PUBLISHED' and g.title_ua = 'Майбутній час: ići ću, bit će' and jsonb_array_length(r.examples) >= 4$q$) = 4
  and pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and g.title_ua = 'Ступені порівняння' and r.title_ua = 'Najljepši u…, jedan od najljepših'$q$) = 1,
  'нова тема «Майбутній час» (4 правила), правило «jedan od najljepših»');

-- ---------------------------------------------------------------- модуль A1.11
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join v3_lessons v on v.id = l.id
  where l.unit_id = '1fb51162-343f-5587-89cf-d2594a3091db' and l.order_index between 1 and 5$q$) = 5,
  'A1.11: 5 уроків за програмою v3 (новий модуль «Хорватська культура», уроки 93–97)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where status = 'PUBLISHED' and (id, title_ua) in (
  ('d9ef1de4-f4db-590e-bafd-474f84c8e03f', 'Урок 93: Старе місто: екскурсія'),
  ('f67bd38c-a41c-51df-b9c0-081737600fce', 'Урок 96: Святкуємо: Різдво, Великдень'))$q$) = 2
  and pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug = 'a1-m11' and i.status = 'PUBLISHED'$q$) = 10,
  'A1.11: нові назви уроків, перевірка модуля a1-m11 — 10 завдань');

-- ---------------------------------------------------------------- модуль A1.12
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join v3_lessons v on v.id = l.id
  where l.unit_id = 'e0fc94e0-c41d-5f59-adf7-db0c97c4575c' and l.order_index between 1 and 8$q$) = 8,
  'A1.12: 8 уроків за програмою v3 (6 перебудованих + 2 нові)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where status = 'PUBLISHED' and level_code = 'A1'
  and title_ua in ('Урок 99: Школа: класи, уроки, розклад', 'Урок 100: Шкільне приладдя', 'Урок 98: Дитячий садок')$q$) = 3
  and pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug = 'a1-m12' and i.status = 'PUBLISHED'$q$) = 10,
  'нові уроки A1.12 — «Школа» й «Шкільне приладдя»; «Дитячий садок» окремо; перевірка a1-m12 — 10 завдань');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and r.title_ua in ('Родовий часу: prije, poslije, od … do, tijekom', 'Svoj: svoju torbu, svoga sina')
  and jsonb_array_length(r.examples) >= 4$q$) = 2,
  'нові правила: родовий часу й svoj');

-- ---------------------------------------------------------------- модуль A1.13
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join v3_lessons v on v.id = l.id
  where l.unit_id = '90bce36b-b9de-5168-b120-49d8e33aa6cf' and l.order_index between 1 and 3$q$) = 3
  and pg_temp.n($q$select 1 from public.lessons where status = 'PUBLISHED' and level_code = 'A1'
  and title_ua in ('Урок 106: Розкажіть про себе', 'Урок 107: Як усе почалося: мій перший рік', 'Урок 108: Нове життя: мої плани')$q$) = 3,
  'A1.13: 3 підсумкові уроки 106–108; усього в A1 — 108 уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where m.level_code = 'A1' and l.status = 'PUBLISHED'$q$) = 108, 'рівень A1 — 108 опублікованих уроків');

-- ---------------------------------------------------------------- середина рівня A1
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug = 'a1-mid' and i.status = 'PUBLISHED'$q$) = 20
  and pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  join public.lessons l on l.id = i.lesson_id join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where a.slug = 'a1-mid' and i.status = 'PUBLISHED' and m.order_index > 6$q$) = 0,
  'середина A1 — 20 завдань лише з модулів A1.1–A1.6');

-- ---------------------------------------------------------------- фінал рівня A1
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug = 'a1-final' and i.status = 'PUBLISHED'$q$) = 30
  and (select count(distinct m.order_index) from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  join public.lessons l on l.id = i.lesson_id join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where a.slug = 'a1-final' and i.status = 'PUBLISHED') >= 12,
  'фінал A1 — 30 завдань з усіх 13 модулів (завдання на читання — без уроку, тож за уроками видно щонайменше 12)');

-- ---------------------------------------------------------------- склад уроків v3
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join v3_lessons v on v.id = l.id
  where (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'lexeme') not between 10 and 25
     or (select count(*) from public.lesson_items i join public.exercises e on e.id = i.item_id
          where i.lesson_id = l.id and i.item_type = 'exercise' and e.status = 'PUBLISHED' and i.required) <> 15
     or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
     or (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'grammar') <> 1
     or (select count(*) from public.lesson_grammar g where g.lesson_id = l.id) <> 1
     or l.estimated_minutes <> 15 or jsonb_array_length(l.objectives) < 2$q$) = 0,
  'урок v3: 10–25 слів, 15 вправ, 2 діалоги, 1 тема граматики, 15 хв, цілі');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations c join v3_lessons v on v.id = c.lesson_id
  where c.status = 'PUBLISHED' and (select count(*) from public.conversation_turns t where t.conversation_id = c.id) not between 4 and 6$q$) = 0,
  'у кожному діалозі v3 4–6 реплік');
select pg_temp.ok(pg_temp.n($q$select x.id from v3_lessons v join public.lesson_items i on i.lesson_id = v.id and i.item_type = 'lexeme'
  join public.lexemes x on x.id = i.item_id group by x.id having count(*) > 1$q$) = 0,
  'слова уроків v3 не повторюються між уроками');
select pg_temp.ok(pg_temp.n($q$select v.id from v3_lessons v join public.lesson_items i on i.lesson_id = v.id and i.item_type = 'lexeme'
  where i.item_id in (select i0.item_id from public.lesson_items i0 join public.lessons l0 on l0.id = i0.lesson_id
                      where l0.level_code = 'A0' and l0.status = 'PUBLISHED' and i0.item_type = 'lexeme')
  group by v.id having count(*) > 2$q$) = 0,
  '90–95 % нових слів: з уроків A0 — не більше 2 слів на урок v3');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversation_turns t join public.conversations c on c.id = t.conversation_id
  where c.source = 'claude_curriculum_a1_v3' and (t.speaker_name in ('Daša', 'Darja') or t.hr_text ~ 'Daš[oa]')$q$) >= 20,
  'у діалогах v3 часто Даша / Дар’я');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e join public.lesson_items i on i.item_id = e.id and i.item_type = 'exercise'
  join v3_lessons v on v.id = i.lesson_id
  where e.exercise_type in ('multiple_choice', 'fill_in_the_blank')
    and (jsonb_array_length(e.options) <> 4 or not e.options ? e.correct_answer
         or (select count(distinct x) from jsonb_array_elements_text(e.options) x) <> 4)$q$) = 0,
  'вправи v3 з вибором: 4 різні варіанти, серед них правильний');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e join public.lesson_items i on i.item_id = e.id and i.item_type = 'exercise'
  join v3_lessons v on v.id = i.lesson_id
  where e.exercise_type = 'type_answer' and not exists (select 1 from public.lexemes x where x.id = e.lexeme_id and x.lemma = e.correct_answer)$q$) = 0,
  '«напишіть»: відповідь — лема пов’язаного слова');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_versions where entity_type = 'lesson'
  and change_reason like 'curriculum_a1_v3: урок перебудовано%'$q$) >= 9,
  'стара версія перебудованих уроків — у content_versions');

-- ---------------------------------------------------------------- граматика
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and g.title_ua = 'Зворотні дієслова: se' and g.status = 'PUBLISHED' and jsonb_array_length(r.examples) >= 4$q$) = 4,
  'нова тема «Зворотні дієслова: se»: 4 правила по ≥ 4 приклади');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and g.title_ua = 'Теперішній час'$q$) >= 5
  and pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A1' and g.title_ua = 'Заперечення'$q$) >= 4,
  'нові правила: «Теперішній час» (-ovati / -nuti / -ći, частота) і «Заперечення» (još ne, više ne)');
select pg_temp.ok(pg_temp.n($q$select r.topic_id, r.order_index from public.grammar_rules r group by 1, 2 having count(*) > 1$q$) = 0,
  'номери правил у темі не повторюються');

-- ---------------------------------------------------------------- словник
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a1_v3' and status = 'PUBLISHED' and cefr = 'A1'$q$) >= 707,
  'нові слова A1 v3 опубліковано (A1.1 — 73, A1.2 — 87, A1.3 — 68, A1.4 — 60, A1.5 — 58, A1.6 — 43, A1.7 — 43, A1.8 — 48, A1.9 — 43, A1.10 — 58, A1.11 — 51, A1.12 — 60, A1.13 — 15)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lower(lemma) = 'pelena'$q$) = 0
  and pg_temp.n($q$select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id and li.item_type = 'lexeme'
                   where li.lesson_id = 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2' and x.lemma = 'pelene'$q$) = 1,
  'нове слово не дублює наявне за формою (pelene, а не нове pelena)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a1_v3'
  and (normalized <> translate(lower(lemma), 'čćđšž', 'ccdsz') or lemma ~ '[Ѐ-ӿ]' or ukrainian_translation !~ '[Ѐ-ӿ]'
       or jsonb_array_length(examples) <> 1 or (examples->>0) ~ '[Ѐ-ӿ]'
       or (part_of_speech = 'verb' and coalesce(forms->>'aspect', '') not in ('ipfv', 'pfv', 'biasp'))
       or (part_of_speech = 'noun' and coalesce(forms->>'gender', '') not in ('m', 'f', 'n', 'm_pl', 'f_pl', 'n_pl')))$q$) = 0,
  'нові слова: normalized без діакритики, лема латиницею, переклад українською, один приклад, вид / рід');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma = 'Uglavnom'$q$) = 0
  and pg_temp.n($q$select 1 from public.lexemes where lemma = 'čuvati' and ukrainian_translation like '%доглядати%'$q$) = 1
  and pg_temp.n($q$select 1 from public.content_versions where entity_type = 'lexeme' and change_reason like 'curriculum_a1_v3: виправлено слово%'$q$) >= 3,
  'виправлено: Uglavnom → uglavnom, čuvati, ponovno (стара версія — у content_versions)');

-- ---------------------------------------------------------------- гість
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id = 'ad0bc1f4-2808-5b24-969d-9da64d4a7a4d'$q$) = 1,
  'гість бачить новий урок A1.1 «Корисні слова»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.modules where level_code = 'A1'$q$) = 13, 'гість бачить 13 модулів A1');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Зворотні дієслова: se'$q$) = 1,
  'гість бачить нову тему граматики');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
