-- =====================================================================
-- Перевірки модулів A0 під уроки за темою (curriculum_a0_v4) · 2026-10-19
-- Згенеровано: python3 -B scripts/gen_assessment_a0_v4.py (не редагуйте вручну).
--
-- Тести: a0-m05 — по 10 завдань із нових діалогів і вправ модулів A0.5.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A0). Середину й фінал рівня A0 не змінено.
--   * Потрібні: 20261015_assessments_a0_v1.sql і уроки curriculum_a0_v4 модуля A0.5 (20261019_curriculum_a0_v4_m05.sql).
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A0.5 · Модуль A0.5 — Obitelj (сім’я)
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a0-m05';
  if v_aid is null then raise exception 'Немає тесту a0-m05 — спершу 20261015_assessments_a0_v1.sql'; end if;
  if exists (select 1 from public.assessment_items where id = '6b408b81-12dc-54a9-861d-88a0911831f5') then return; end if;  -- уже оновлено
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
  ('6b408b81-12dc-54a9-861d-88a0911831f5', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Можливо. Її квартира на нашому поверсі.", "Так, у садочок біля школи. Виховательки дуже милі.", "Вона дуже терпляча й розумна."]'::jsonb, 0, null, 'Možda. Njezin stan je na našem katu.', null, null, 'Прозвучало: «Možda. Njezin stan je na našem katu.» — «Можливо. Її квартира на нашому поверсі.».', (select id from public.lessons where id = '18efed0f-53a5-5717-9c4e-319627da2360'), 'PUBLISHED', 'claude_assessment_v1'),
  ('2b6897ed-c57a-5b5f-a4dc-25addbc6fc89', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Дашо, що робиш на цих вихідних?", "Добрий день! Що сталося з вашим собакою?", "Дашо, у тебе є домашній улюбленець?"]'::jsonb, 2, null, 'Dašo, imaš li kućnog ljubimca?', null, null, 'Прозвучало: «Dašo, imaš li kućnog ljubimca?» — «Дашо, у тебе є домашній улюбленець?».', (select id from public.lessons where id = '40b9da1d-1686-5b78-8317-0439067d5f8e'), 'PUBLISHED', 'claude_assessment_v1'),
  ('2d366294-67b3-5f74-9ad6-756d66e58ab8', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Хто пише листівку?', 'Čestitka za rođendan', '["Мама", "Ана і Марко", "Тільки Ана"]'::jsonb, 1, null, null, 'Draga mama,
sretan rođendan!
Volimo te puno.
Tvoji Ana i Marko', 'Люба мамо,
з днем народження!
Ми тебе дуже любимо.
Твої Ана і Марко', 'Текст «Листівка на день народження». Правильна відповідь: «Ана і Марко».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('4bafdcce-57be-572e-ac08-b1ca147e0b45', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Imaju li puno unuka?', '["Sok od naranče, molim.", "Iz Ukrajine. Moj rodni grad je Lviv.", "Imaju četiri unuka i dvije unuke."]'::jsonb, 2, null, 'Imaju li puno unuka?', null, null, 'Діалог «Бабуся й дідусь»: «Imaju li puno unuka?» (У них багато онуків?) — «Imaju četiri unuka i dvije unuke.» (Четверо онуків і дві онучки.).', (select id from public.lessons where id = '4e003796-1ce0-5a02-8a2d-59a0de38f3dd'), 'PUBLISHED', 'claude_assessment_v1'),
  ('581abacb-7ddf-5a73-9775-e0c441e6c772', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Onaj dječak u plavoj majici. Ide li Lea u vrtić?', '["Iz Ukrajine, iz Harkiva.", "Ide, u vrtić pored škole. Odgojiteljice su jako drage.", "Nula devet osam, pedeset tri, sedamdeset dva, devedeset jedan."]'::jsonb, 1, null, 'Onaj dječak u plavoj majici. Ide li Lea u vrtić?', null, null, 'Діалог «На дитячому майданчику»: «Onaj dječak u plavoj majici. Ide li Lea u vrtić?» (Он той хлопчик у синій футболці. Леа ходить у садочок?) — «Ide, u vrtić pored škole. Odgojiteljice su jako drage.» (Так, у садочок біля школи. Виховательки дуже милі.).', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v1'),
  ('a8009b41-001a-521b-9af6-cb565be65445', v_aid, 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Divno! Gdje ćete se vjenčati?', '["У церкві в Задарі. Звісно, ти теж запрошена!", "Мій хлопець Петар. Весілля в червні.", "Дашо, у мене велика новина. Я заручена!"]'::jsonb, 0, null, null, 'Ivana: Dašo, imam veliku vijest. Zaručena sam!
Daša: Čestitam! Tko je sretnik?
Ivana: Moj dečko Petar. Vjenčanje je u lipnju.
Daša: Divno! Gdje ćete se vjenčati?
Ivana: U crkvi u Zadru. Naravno, i ti si pozvana!', 'Ivana: Дашо, у мене велика новина. Я заручена!
Daša: Вітаю! І хто ж цей щасливчик?
Ivana: Мій хлопець Петар. Весілля в червні.
Daša: Чудово! Де ви будете вінчатися?
Ivana: У церкві в Задарі. Звісно, ти теж запрошена!', 'Діалог «Весілля»: «Divno! Gdje ćete se vjenčati?» — «U crkvi u Zadru. Naravno, i ti si pozvana!», тобто «У церкві в Задарі. Звісно, ти теж запрошена!».', (select id from public.lessons where id = 'f9ca38e4-3a61-56a6-b5f5-060933516c9a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('9f76bebd-836f-5d9b-8c10-cc4aeaaae7af', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Це мій найкращий друг». Що ви скажете?', null, '["Ovo je moj najbolji prijatelj.", "Ona ima plave oči.", "Udana sam."]'::jsonb, 0, null, null, null, null, '«Це мій найкращий друг.» — «Ovo je moj najbolji prijatelj.».', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v1'),
  ('dc45848c-c2bf-56ed-b6f9-cacbae0f91d6', v_aid, 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «кумедний, смішний»', null, '[]'::jsonb, null, 'smiješan', null, null, null, '«кумедний, смішний» — smiješan.', (select id from public.lessons where id = '60130364-d731-5f5a-8b12-ac4d8d6d92e9'), 'PUBLISHED', 'claude_assessment_v1'),
  ('472b600a-6dda-5ead-9f7c-604f9a6250fd', v_aid, 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Мій брат наймолодший.»', null, '["Moj", "je", "najmlađi.", "brat"]'::jsonb, null, 'Moj brat je najmlađi.', null, null, null, '«Мій брат наймолодший.» — «Moj brat je najmlađi.».', (select id from public.lessons where id = '4e003796-1ce0-5a02-8a2d-59a0de38f3dd'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b915df8b-e91b-594b-a969-42fcae7ec83e', v_aid, 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Хто це?»', null, '[]'::jsonb, null, 'Tko je to?', null, null, null, '«Хто це?» — «Tko je to?».', (select id from public.lessons where id = '4e003796-1ce0-5a02-8a2d-59a0de38f3dd'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під уроки за темою (curriculum_a0_v4) — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('6b408b81-12dc-54a9-861d-88a0911831f5', '2b6897ed-c57a-5b5f-a4dc-25addbc6fc89', '2d366294-67b3-5f74-9ad6-756d66e58ab8', '4bafdcce-57be-572e-ac08-b1ca147e0b45', '581abacb-7ddf-5a73-9775-e0c441e6c772', 'a8009b41-001a-521b-9af6-cb565be65445', '9f76bebd-836f-5d9b-8c10-cc4aeaaae7af', 'dc45848c-c2bf-56ed-b6f9-cacbae0f91d6', '472b600a-6dda-5ead-9f7c-604f9a6250fd', 'b915df8b-e91b-594b-a969-42fcae7ec83e') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a0-m05')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'
                     and i.id not in ('6b408b81-12dc-54a9-861d-88a0911831f5', '2b6897ed-c57a-5b5f-a4dc-25addbc6fc89', '2d366294-67b3-5f74-9ad6-756d66e58ab8', '4bafdcce-57be-572e-ac08-b1ca147e0b45', '581abacb-7ddf-5a73-9775-e0c441e6c772', 'a8009b41-001a-521b-9af6-cb565be65445', '9f76bebd-836f-5d9b-8c10-cc4aeaaae7af', 'dc45848c-c2bf-56ed-b6f9-cacbae0f91d6', '472b600a-6dda-5ead-9f7c-604f9a6250fd', 'b915df8b-e91b-594b-a969-42fcae7ec83e')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірки модулів a0-m05 оновлено — % нових завдань', v_new;
end $$;

commit;
