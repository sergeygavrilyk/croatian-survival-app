-- =====================================================================
-- Перевірки модулів A0 під уроки за темою (curriculum_a0_v4) · 2026-10-20
-- Згенеровано: python3 -B scripts/gen_assessment_a0_v4.py (не редагуйте вручну).
--
-- Тести: a0-m10 — по 10 завдань із нових діалогів і вправ модулів A0.10.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A0). Середину й фінал рівня A0 не змінено.
--   * Потрібні: 20261015_assessments_a0_v1.sql і уроки curriculum_a0_v4 модуля A0.10 (20261020_curriculum_a0_v4_m10.sql).
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A0.10 · Модуль A0.10 — Survival Croatian (виживання)
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a0-m10';
  if v_aid is null then raise exception 'Немає тесту a0-m10 — спершу 20261015_assessments_a0_v1.sql'; end if;
  if exists (select 1 from public.assessment_items where id = 'a3996002-af23-5716-9fa7-156978a65948') then return; end if;  -- уже оновлено
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'curriculum_a0_v4: перевірку модуля оновлено під нові уроки — старі завдання');
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + 100
   where assessment_id = v_aid and status = 'PUBLISHED' and order_index <= 100;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('a3996002-af23-5716-9fa7-156978a65948', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Перепрошую, можете мені допомогти? Я заблукав.", "Заяву схвалено. Рішення можна забрати у віконці номер три.", "Прошу. Приймайте його тричі на день після їжі."]'::jsonb, 2, null, 'Izvolite. Uzimajte ga tri puta dnevno nakon jela.', null, null, 'Прозвучало: «Izvolite. Uzimajte ga tri puta dnevno nakon jela.» — «Прошу. Приймайте його тричі на день після їжі.».', (select id from public.lessons where id = 'fbc71f82-e715-5bab-a990-b8542fb0fe01'), 'PUBLISHED', 'claude_assessment_v1'),
  ('ca6df188-4ef1-5c52-b99c-bf69d1357901', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["До готелю «Парк», але в мене вимкнувся телефон.", "Копія, але засвідчена.", "Перепрошую! Зараз вам їх принесу."]'::jsonb, 2, null, 'Ispričavam se! Odmah ću vam ih donijeti.', null, null, 'Прозвучало: «Ispričavam se! Odmah ću vam ih donijeti.» — «Перепрошую! Зараз вам їх принесу.».', (select id from public.lessons where id = 'edbae9ca-c4f4-575d-b876-d50b0a1fd9b5'), 'PUBLISHED', 'claude_assessment_v1'),
  ('77ab2718-13e6-57d9-a882-6faf37751081', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Що означає «ZABRANJENO PUŠENJE»?', 'Zabrane i upozorenja', '["Місце для паління", "Палити заборонено", "Можна палити"]'::jsonb, 1, null, null, 'ZABRANJENO PUŠENJE
PAZI, PAS!
GURAJ
VUCI
NE NAGINJI SE KROZ PROZOR', 'ПАЛИТИ ЗАБОРОНЕНО
ОБЕРЕЖНО, СОБАКА!
ВІД СЕБЕ (штовхайте)
НА СЕБЕ (тягніть)
НЕ ВИХИЛЯЙТЕСЯ З ВІКНА', 'Текст «Заборони й попередження». Правильна відповідь: «Палити заборонено».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('bf314911-4358-55aa-8304-646696b8b2b1', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'U obrascu imam jednu pogrešku. Mogu li je ispraviti?', '["Tvrd je, ali je unutra prostran.", "Otprilike četiristo.", "Možete, ali bolje ispunite novi."]'::jsonb, 2, null, 'U obrascu imam jednu pogrešku. Mogu li je ispraviti?', null, null, 'Діалог «Копія чи оригінал?»: «U obrascu imam jednu pogrešku. Mogu li je ispraviti?» (У бланку в мене одна помилка. Можна її виправити?) — «Možete, ali bolje ispunite novi.» (Можна, але краще заповніть новий.).', (select id from public.lessons where id = 'b095637e-0644-507e-8f3d-d323483dd3e4'), 'PUBLISHED', 'claude_assessment_v1'),
  ('17d4dad9-146a-59de-ae29-592ae85c537d', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Centar 112, izvolite. Što se dogodilo?', '["Dogodila se prometna nesreća! Jedan čovjek je ozlijeđen.", "Vani, ispred zgrade.", "Otprilike četiristo."]'::jsonb, 0, null, 'Centar 112, izvolite. Što se dogodilo?', null, null, 'Діалог «Дзвінок на 112»: «Centar 112, izvolite. Što se dogodilo?» (Центр 112, слухаю. Що сталося?) — «Dogodila se prometna nesreća! Jedan čovjek je ozlijeđen.» (Сталася ДТП! Один чоловік поранений.).', (select id from public.lessons where id = '48f26e9d-96c5-5189-8ec6-db1f9d58e200'), 'PUBLISHED', 'claude_assessment_v1'),
  ('9bb76e9e-ec6a-5418-a4cb-afcfa3b2b427', v_aid, 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Naravno. Kamo trebate ići?', '["Обережно, тут небезпечно переходити дорогу. Ходімо до світлофора.", "Дуже дякую, ви дуже люб’язні.", "До готелю «Парк», але в мене вимкнувся телефон."]'::jsonb, 2, null, null, 'Andrij: Oprostite, možete li mi pomoći? Izgubio sam se.
Gospođa: Naravno. Kamo trebate ići?
Andrij: Do hotela Park, ali mobitel mi se ugasio.
Gospođa: Pazite, ovdje je opasno prelaziti cestu. Idemo do semafora.
Andrij: Hvala vam puno, jako ste ljubazni.', 'Andrij: Перепрошую, можете мені допомогти? Я заблукав.
Gospođa: Звісно. Куди вам треба?
Andrij: До готелю «Парк», але в мене вимкнувся телефон.
Gospođa: Обережно, тут небезпечно переходити дорогу. Ходімо до світлофора.
Andrij: Дуже дякую, ви дуже люб’язні.', 'Діалог «Я заблукав»: «Naravno. Kamo trebate ići?» — «Do hotela Park, ali mobitel mi se ugasio.», тобто «До готелю «Парк», але в мене вимкнувся телефон.».', (select id from public.lessons where id = '48f26e9d-96c5-5189-8ec6-db1f9d58e200'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e7656054-336a-56c2-a403-7cd6c582d17c', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «У мене бронювання». Що ви скажете?', null, '["Imam rezervaciju.", "Imam prehladu.", "Mogu li ostaviti stvari na recepciji?"]'::jsonb, 0, null, null, null, null, '«У мене бронювання.» — «Imam rezervaciju.».', (select id from public.lessons where id = 'edbae9ca-c4f4-575d-b876-d50b0a1fd9b5'), 'PUBLISHED', 'claude_assessment_v1'),
  ('f7591b56-74bb-5993-8289-489e976c4739', v_aid, 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «засвідчити (печаткою, у нотаріуса)»', null, '[]'::jsonb, null, 'ovjeriti', null, null, null, '«засвідчити (печаткою, у нотаріуса)» — ovjeriti.', (select id from public.lessons where id = 'b095637e-0644-507e-8f3d-d323483dd3e4'), 'PUBLISHED', 'claude_assessment_v1'),
  ('344cb98a-e790-55e1-9b78-9546c9dde338', v_aid, 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «У мене алергія на пеніцилін.»', null, '["Imam", "alergiju", "penicilin.", "na"]'::jsonb, null, 'Imam alergiju na penicilin.', null, null, null, '«У мене алергія на пеніцилін.» — «Imam alergiju na penicilin.».', (select id from public.lessons where id = 'fbc71f82-e715-5bab-a990-b8542fb0fe01'), 'PUBLISHED', 'claude_assessment_v1'),
  ('32b9bff2-e98a-5045-ba66-cc570e092118', v_aid, 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Де мені підписатися?»', null, '[]'::jsonb, null, 'Gdje se trebam potpisati?', null, null, null, '«Де мені підписатися?» — «Gdje se trebam potpisati?».', (select id from public.lessons where id = 'b095637e-0644-507e-8f3d-d323483dd3e4'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під уроки за темою (curriculum_a0_v4) — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('a3996002-af23-5716-9fa7-156978a65948', 'ca6df188-4ef1-5c52-b99c-bf69d1357901', '77ab2718-13e6-57d9-a882-6faf37751081', 'bf314911-4358-55aa-8304-646696b8b2b1', '17d4dad9-146a-59de-ae29-592ae85c537d', '9bb76e9e-ec6a-5418-a4cb-afcfa3b2b427', 'e7656054-336a-56c2-a403-7cd6c582d17c', 'f7591b56-74bb-5993-8289-489e976c4739', '344cb98a-e790-55e1-9b78-9546c9dde338', '32b9bff2-e98a-5045-ba66-cc570e092118') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a0-m10')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'
                     and i.id not in ('a3996002-af23-5716-9fa7-156978a65948', 'ca6df188-4ef1-5c52-b99c-bf69d1357901', '77ab2718-13e6-57d9-a882-6faf37751081', 'bf314911-4358-55aa-8304-646696b8b2b1', '17d4dad9-146a-59de-ae29-592ae85c537d', '9bb76e9e-ec6a-5418-a4cb-afcfa3b2b427', 'e7656054-336a-56c2-a403-7cd6c582d17c', 'f7591b56-74bb-5993-8289-489e976c4739', '344cb98a-e790-55e1-9b78-9546c9dde338', '32b9bff2-e98a-5045-ba66-cc570e092118')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірки модулів a0-m10 оновлено — % нових завдань', v_new;
end $$;

commit;
