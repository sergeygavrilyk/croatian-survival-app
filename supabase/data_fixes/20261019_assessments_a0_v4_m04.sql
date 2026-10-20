-- =====================================================================
-- Перевірки модулів A0 під уроки за темою (curriculum_a0_v4) · 2026-10-19
-- Згенеровано: python3 -B scripts/gen_assessment_a0_v4.py (не редагуйте вручну).
--
-- Тести: a0-m04 — по 10 завдань із нових діалогів і вправ модулів A0.4.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A0). Середину й фінал рівня A0 не змінено.
--   * Потрібні: 20261015_assessments_a0_v1.sql і уроки curriculum_a0_v4 модуля A0.4 (20261019_curriculum_a0_v4_m04.sql).
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A0.4 · Модуль A0.4 — Vrijeme (час)
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a0-m04';
  if v_aid is null then raise exception 'Немає тесту a0-m04 — спершу 20261015_assessments_a0_v1.sql'; end if;
  if exists (select 1 from public.assessment_items where id = 'b18fb9eb-099f-5057-a9e5-04851f601825') then return; end if;  -- уже оновлено
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
  ('b18fb9eb-099f-5057-a9e5-04851f601825', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Чудово, побачимося в понеділок!", "Так! Бажаю тобі щасливого Нового року!", "Ой, завтра в мене річниця весілля!"]'::jsonb, 0, null, 'Odlično, vidimo se u ponedjeljak!', null, null, 'Прозвучало: «Odlično, vidimo se u ponedjeljak!» — «Чудово, побачимося в понеділок!».', (select id from public.lessons where id = '8e372ece-ae10-50ae-9cf3-07b52ef2f72d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('47e3574f-49c5-521a-9a10-baf717b9d1c8', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Дякую, запишу це в календар.", "Доброго ранку, Дашо! Ти виглядаєш утомленою.", "Я люблю весну, особливо квітень і травень."]'::jsonb, 2, null, 'Volim proljeće, posebno travanj i svibanj.', null, null, 'Прозвучало: «Volim proljeće, posebno travanj i svibanj.» — «Я люблю весну, особливо квітень і травень.».', (select id from public.lessons where id = '036fc4fb-1bf2-5100-9fd0-6f6a612554a1'), 'PUBLISHED', 'claude_assessment_v1'),
  ('5a26529c-d31b-55af-ae8a-9bffe0e7afa1', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Як часто він їздить на вихідних?', 'Vozni red autobusa', '["Не їздить", "Кожні 30 хвилин", "Щогодини"]'::jsonb, 2, null, null, 'AUTOBUS 6
Smjer: Kolodvor
Polasci: 7:15 • 7:45 • 8:15
Vikendom: svaki sat', 'АВТОБУС 6
Напрямок: вокзал
Відправлення: 7:15 • 7:45 • 8:15
На вихідних: щогодини', 'Текст «Розклад автобуса». Правильна відповідь: «Щогодини».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('5819da16-cb46-50f7-a459-22700ccde4be', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, gdje dočekuješ Novu godinu?', '["Iz Ukrajine, iz Harkiva.", "Na trgu u centru. Bit će koncert i vatromet.", "Ja pijem limunadu s ledom."]'::jsonb, 1, null, 'Dašo, gdje dočekuješ Novu godinu?', null, null, 'Діалог «Новий рік»: «Dašo, gdje dočekuješ Novu godinu?» (Дашо, де ти зустрічаєш Новий рік?) — «Na trgu u centru. Bit će koncert i vatromet.» (На площі в центрі. Буде концерт і феєрверк.).', (select id from public.lessons where id = 'd7cf3059-0d92-5215-8ef4-ad699e317b10'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b9881635-25af-5eb6-ab61-b4366fad7eec', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Luka, koji je danas datum?', '["Iz Ukrajine. Rodom sam iz Odese.", "Sedamdeset dva, devedeset jedan.", "Danas je dvadeseti listopada."]'::jsonb, 2, null, 'Luka, koji je danas datum?', null, null, 'Діалог «Яке сьогодні число?»: «Luka, koji je danas datum?» (Луко, яке сьогодні число?) — «Danas je dvadeseti listopada.» (Сьогодні двадцяте жовтня.).', (select id from public.lessons where id = 'b36b4550-ff36-50cb-89fb-8246b351c8d6'), 'PUBLISHED', 'claude_assessment_v1'),
  ('1b513701-0563-596a-9a15-a2ba93e4f2ee', v_aid, 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Oprostite, u koliko sati ide vlak za Rijeku?', '["Відправлення о десятій п’ятнадцять.", "Ні, потяг іде вчасно. Прибуття до Рієки о пів на другу.", "Рівно десята. У вас ще чверть години."]'::jsonb, 0, null, null, 'Daša: Oprostite, u koliko sati ide vlak za Rijeku?
Službenica: Polazak je u deset i petnaest.
Daša: A koliko je sati sada?
Službenica: Točno deset. Imate još četvrt sata.
Daša: Ima li kašnjenja?
Službenica: Nema, vlak ide na vrijeme. Dolazak u Rijeku je u jedan i pol.', 'Daša: Вибачте, о котрій їде потяг до Рієки?
Službenica: Відправлення о десятій п’ятнадцять.
Daša: А котра зараз година?
Službenica: Рівно десята. У вас ще чверть години.
Daša: Є затримка?
Službenica: Ні, потяг іде вчасно. Прибуття до Рієки о пів на другу.', 'Діалог «На вокзалі»: «Oprostite, u koliko sati ide vlak za Rijeku?» — «Polazak je u deset i petnaest.», тобто «Відправлення о десятій п’ятнадцять.».', (select id from public.lessons where id = '39b1e31f-b573-5000-9713-1660688c3cc9'), 'PUBLISHED', 'claude_assessment_v1'),
  ('616b6746-de00-5750-8b90-ad99cfb4e950', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «З Великоднем!». Що ви скажете?', null, '["U prosincu je hladno.", "Sretni blagdani!", "Sretan Uskrs!"]'::jsonb, 2, null, null, null, null, '«З Великоднем!» — «Sretan Uskrs!».', (select id from public.lessons where id = 'd7cf3059-0d92-5215-8ef4-ad699e317b10'), 'PUBLISHED', 'claude_assessment_v1'),
  ('622dd0d0-f761-53c9-aaae-0f3fb276bd65', v_aid, 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «минулий»', null, '[]'::jsonb, null, 'prošli', null, null, null, '«минулий» — prošli.', (select id from public.lessons where id = '8e372ece-ae10-50ae-9cf3-07b52ef2f72d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('f845369a-8bbd-5c48-916f-74d089ab2933', v_aid, 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Щасливого Різдва, Дашо!»', null, '["Dašo!", "Božić,", "Sretan"]'::jsonb, null, 'Sretan Božić, Dašo!', null, null, null, '«Щасливого Різдва, Дашо!» — «Sretan Božić, Dašo!».', (select id from public.lessons where id = 'd7cf3059-0d92-5215-8ef4-ad699e317b10'), 'PUBLISHED', 'claude_assessment_v1'),
  ('fff04876-6193-5468-a731-579221f0d130', v_aid, 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Я поспішаю.»', null, '[]'::jsonb, null, 'Žurim se.', null, null, null, '«Я поспішаю.» — «Žurim se.».', (select id from public.lessons where id = '39b1e31f-b573-5000-9713-1660688c3cc9'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під уроки за темою (curriculum_a0_v4) — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('b18fb9eb-099f-5057-a9e5-04851f601825', '47e3574f-49c5-521a-9a10-baf717b9d1c8', '5a26529c-d31b-55af-ae8a-9bffe0e7afa1', '5819da16-cb46-50f7-a459-22700ccde4be', 'b9881635-25af-5eb6-ab61-b4366fad7eec', '1b513701-0563-596a-9a15-a2ba93e4f2ee', '616b6746-de00-5750-8b90-ad99cfb4e950', '622dd0d0-f761-53c9-aaae-0f3fb276bd65', 'f845369a-8bbd-5c48-916f-74d089ab2933', 'fff04876-6193-5468-a731-579221f0d130') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a0-m04')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'
                     and i.id not in ('b18fb9eb-099f-5057-a9e5-04851f601825', '47e3574f-49c5-521a-9a10-baf717b9d1c8', '5a26529c-d31b-55af-ae8a-9bffe0e7afa1', '5819da16-cb46-50f7-a459-22700ccde4be', 'b9881635-25af-5eb6-ab61-b4366fad7eec', '1b513701-0563-596a-9a15-a2ba93e4f2ee', '616b6746-de00-5750-8b90-ad99cfb4e950', '622dd0d0-f761-53c9-aaae-0f3fb276bd65', 'f845369a-8bbd-5c48-916f-74d089ab2933', 'fff04876-6193-5468-a731-579221f0d130')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірки модулів a0-m04 оновлено — % нових завдань', v_new;
end $$;

commit;
