-- =====================================================================
-- Перевірки модулів A0 під уроки за темою (curriculum_a0_v4) · 2026-10-19
-- Згенеровано: python3 -B scripts/gen_assessment_a0_v4.py (не редагуйте вручну).
--
-- Тести: a0-m01, a0-m02 — по 10 завдань із нових діалогів і вправ модулів A0.1, A0.2.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A0). Середину й фінал рівня A0 не змінено.
--   * Потрібні: 20261015_assessments_a0_v1.sql і уроки curriculum_a0_v4 (A0.1 — m01, A0.2 — m02).
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A0.1 · Модуль A0.1 — Pozdrav!
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a0-m01';
  if v_aid is null then raise exception 'Немає тесту a0-m01 — спершу 20261015_assessments_a0_v1.sql'; end if;
  if exists (select 1 from public.assessment_items where id = '97c80cdc-4661-5bbe-8106-658cb1300895') then return; end if;  -- уже оновлено
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
  ('97c80cdc-4661-5bbe-8106-658cb1300895', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Дякую, ви дуже люб’язні.", "Трамвай номер шість. Шість!", "Кажуть: «hvala»."]'::jsonb, 1, null, 'Tramvaj broj šest. Šest!', null, null, 'Прозвучало: «Tramvaj broj šest. Šest!» — «Трамвай номер шість. Шість!».', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('562c650a-a7fb-5603-aced-823a529bae8f', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Дякую, ви дуже люб’язні.", "Тоді сідайте й відпочиньте.", "Дякую, і тобі. Передавай привіт мамі!"]'::jsonb, 2, null, 'Hvala, i tebi. Pozdravi mamu!', null, null, 'Прозвучало: «Hvala, i tebi. Pozdravi mamu!» — «Дякую, і тобі. Передавай привіт мамі!».', (select id from public.lessons where id = 'd8cffb46-8a62-538a-b864-e227a6d8b863'), 'PUBLISHED', 'claude_assessment_v1'),
  ('6a00f02b-8b5b-5e6c-a7a8-25b13f3b240a', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Що вам кажуть, коли ви заходите?', 'Na vratima trgovine', '["Laku noć!", "Dobar dan! Izvolite.", "Oprostite!"]'::jsonb, 1, null, null, 'DOBRO DOŠLI!
OTVORENO
Dobar dan! Izvolite.
Hvala i doviđenja!', 'ЛАСКАВО ПРОСИМО!
ВІДЧИНЕНО
Добрий день! Прошу, заходьте.
Дякуємо і до побачення!', 'Текст «На дверях магазину». Правильна відповідь: «Dobar dan! Izvolite.».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('5dc4bf14-7e94-5513-992c-a9881899afb2', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Ja idem kući. Vidimo se sutra?', '["Broj sedam.", "Sutra ne mogu. Čujemo se!", "Za dvije noći."]'::jsonb, 1, null, 'Ja idem kući. Vidimo se sutra?', null, null, 'Діалог «Увечері після курсу»: «Ja idem kući. Vidimo se sutra?» (Я йду додому. Побачимося завтра?) — «Sutra ne mogu. Čujemo se!» (Завтра не можу. Зідзвонимося!).', (select id from public.lessons where id = 'd8cffb46-8a62-538a-b864-e227a6d8b863'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b0747384-7ffa-5a2d-969d-8d3955a83d63', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Odlično, hvala. A Vi?', '["Ukrajinski, engleski i malo poljski. Hrvatski još učim.", "Mama je u Ukrajini, a brat u Njemačkoj.", "Tako-tako. Imam puno posla."]'::jsonb, 2, null, 'Odlično, hvala. A Vi?', null, null, 'Діалог «У гостях у сусідки»: «Odlično, hvala. A Vi?» (Відмінно, дякую. А ви?) — «Tako-tako. Imam puno posla.» (Так собі. У мене багато роботи.).', (select id from public.lessons where id = 'c0000000-0000-0000-0000-000000000001'), 'PUBLISHED', 'claude_assessment_v1'),
  ('512fc60d-7ddc-5fb6-8270-6207c5b9a9b2', v_aid, 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Hvala, Marko! Izvoli, sok ili vino?', '["Дякую, і тобі!", "Будьмо! І успіхів на новій роботі!", "Вино, будь ласка. Будьмо!"]'::jsonb, 2, null, null, 'Marko: Sretan rođendan, Dašo! Čestitam!
Daša: Hvala, Marko! Izvoli, sok ili vino?
Marko: Vino, molim. Na zdravlje!
Daša: Na zdravlje! I sretno na novom poslu!
Marko: Hvala, i tebi!', 'Marko: З днем народження, Дашо! Вітаю!
Daša: Дякую, Марку! Прошу, сік чи вино?
Marko: Вино, будь ласка. Будьмо!
Daša: Будьмо! І успіхів на новій роботі!
Marko: Дякую, і тобі!', 'Діалог «День народження»: «Hvala, Marko! Izvoli, sok ili vino?» — «Vino, molim. Na zdravlje!», тобто «Вино, будь ласка. Будьмо!».', (select id from public.lessons where id = 'e704760a-f743-5762-9c1a-027b10ca030a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('1374f199-2a93-5bbe-99f3-d6a9e09423cc', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Гарних вихідних!». Що ви скажете?', null, '["Dobro jutro!", "Hvala na pomoći!", "Ugodan vikend!"]'::jsonb, 2, null, null, null, null, '«Гарних вихідних!» — «Ugodan vikend!».', (select id from public.lessons where id = 'd8cffb46-8a62-538a-b864-e227a6d8b863'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b93451ec-af1c-5ff8-a67b-18cd767cf779', v_aid, 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «смачного!»', null, '[]'::jsonb, null, 'dobar tek', null, null, null, '«смачного!» — dobar tek.', (select id from public.lessons where id = 'e704760a-f743-5762-9c1a-027b10ca030a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('8fd07580-e7db-58ce-a431-9e583ad590f5', v_aid, 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Перепрошую, я запізнююся.»', null, '["Ispričavam", "kasnim.", "se,"]'::jsonb, null, 'Ispričavam se, kasnim.', null, null, null, '«Перепрошую, я запізнююся.» — «Ispričavam se, kasnim.».', (select id from public.lessons where id = 'e704760a-f743-5762-9c1a-027b10ca030a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('0e8b68d8-690c-5cad-b150-ed7124decdd7', v_aid, 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Я не розумію.»', null, '[]'::jsonb, null, 'Ne razumijem.', null, null, null, '«Я не розумію.» — «Ne razumijem.».', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під уроки за темою (curriculum_a0_v4) — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A0.2 · Модуль A0.2 — Ja sam…
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a0-m02';
  if v_aid is null then raise exception 'Немає тесту a0-m02 — спершу 20261015_assessments_a0_v1.sql'; end if;
  if exists (select 1 from public.assessment_items where id = '8e7f1b27-594b-57a6-b935-21b6559dea54') then return; end if;  -- уже оновлено
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
  ('8e7f1b27-594b-57a6-b935-21b6559dea54', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Львів — столиця України?", "У вас є температура?", "Велика! З якими країнами межує?"]'::jsonb, 2, null, 'Velika je! S kojim zemljama graniči?', null, null, 'Прозвучало: «Velika je! S kojim zemljama graniči?» — «Велика! З якими країнами межує?».', (select id from public.lessons where id = '479784bc-54ab-522d-9c77-55887ae68e33'), 'PUBLISHED', 'claude_assessment_v1'),
  ('a40d492f-4247-5685-b312-a15bbcd6a336', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Хорватія — у Європі, на Адріатичному морі.", "Зараз працюю офіціанткою в кав’ярні.", "Так! Але зараз я живу в Загребі."]'::jsonb, 0, null, 'Hrvatska je u Europi, na Jadranskom moru.', null, null, 'Прозвучало: «Hrvatska je u Europi, na Jadranskom moru.» — «Хорватія — у Європі, на Адріатичному морі.».', (select id from public.lessons where id = '479784bc-54ab-522d-9c77-55887ae68e33'), 'PUBLISHED', 'claude_assessment_v1'),
  ('cc8ec24f-e293-5c85-8432-2d80141d005c', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Який номер кабінету?', 'Natpis na vratima ordinacije', '["30", "13", "3"]'::jsonb, 2, null, null, 'Dr. Ivo Kovač
liječnik obiteljske medicine
Soba 3
Molimo, pokucajte!', 'Д-р Іво Ковач
лікар сімейної медицини
Кабінет 3
Просимо, постукайте!', 'Текст «Табличка на дверях кабінету». Правильна відповідь: «3».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('c91e946b-ed1a-5fee-8221-4e00a45ecae5', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Kada si došla u Hrvatsku?', '["Čaj, molim. Šalicu toplog čaja.", "Prije dvije godine.", "Jaja i kruh."]'::jsonb, 1, null, 'Kada si došla u Hrvatsku?', null, null, 'Діалог «Звідки ти?»: «Kada si došla u Hrvatsku?» (Коли ти приїхала до Хорватії?) — «Prije dvije godine.» (Два роки тому.).', (select id from public.lessons where id = '04167753-db83-5163-a91c-9f71dac18ab5'), 'PUBLISHED', 'claude_assessment_v1'),
  ('2c55c6c0-05c2-5192-96f0-bb99d979b4c8', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Učimo li samo na hrvatskom?', '["Da, ali polako. Ne brinite!", "Čaj, molim. Šalicu toplog čaja.", "Deset i dvanaest."]'::jsonb, 0, null, 'Učimo li samo na hrvatskom?', null, null, 'Діалог «Курс для іноземців»: «Učimo li samo na hrvatskom?» (Ми вчимося лише хорватською?) — «Da, ali polako. Ne brinite!» (Так, але повільно. Не хвилюйтеся!).', (select id from public.lessons where id = 'a9944193-2dfb-5944-b94c-41c41fdb7ca1'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b18131bc-f448-5cbc-b1dd-9170e9a10245', v_aid, 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Jesam. Koje jezike govoriš?', '["Супер! Ти можеш навчити мене італійської!", "Українською, англійською і трохи польською. Хорватську ще вчу.", "А я вільно говорю італійською. Моя мама — італійка."]'::jsonb, 1, null, null, 'Petra: Jesi li ti Ukrajinka?
Daša: Jesam. A ti si Hrvatica?
Petra: Jesam. Koje jezike govoriš?
Daša: Ukrajinski, engleski i malo poljski. Hrvatski još učim.
Petra: Ja tečno govorim talijanski. Majka mi je Talijanka.
Daša: Super! Možeš me naučiti talijanski!', 'Petra: Ти українка?
Daša: Так. А ти хорватка?
Petra: Так. Якими мовами ти розмовляєш?
Daša: Українською, англійською і трохи польською. Хорватську ще вчу.
Petra: А я вільно говорю італійською. Моя мама — італійка.
Daša: Супер! Ти можеш навчити мене італійської!', 'Діалог «Ти українка?»: «Jesam. Koje jezike govoriš?» — «Ukrajinski, engleski i malo poljski. Hrvatski još učim.», тобто «Українською, англійською і трохи польською. Хорватську ще вчу.».', (select id from public.lessons where id = 'a9944193-2dfb-5944-b94c-41c41fdb7ca1'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d8ba6c42-c4a5-5c87-b8e8-8be099abb8c3', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я програміст». Що ви скажете?', null, '["Ona je moja kolegica.", "Kako se osjećaš?", "Ja sam programer."]'::jsonb, 2, null, null, null, null, '«Я програміст.» — «Ja sam programer.».', (select id from public.lessons where id = '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('f5da5962-d333-5009-bf87-bf49ebdd3ad6', v_aid, 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «Сербія»', null, '[]'::jsonb, null, 'Srbija', null, null, null, '«Сербія» — Srbija.', (select id from public.lessons where id = '479784bc-54ab-522d-9c77-55887ae68e33'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e70e8eb6-7084-595a-9e65-1910cf1f448f', v_aid, 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Він мій сусід.»', null, '["On", "moj", "susjed.", "je"]'::jsonb, null, 'On je moj susjed.', null, null, null, '«Він мій сусід.» — «On je moj susjed.».', (select id from public.lessons where id = '8abb83d8-ec02-5921-ac9b-814489816fcd'), 'PUBLISHED', 'claude_assessment_v1'),
  ('edeb8cb3-313a-5a95-b41c-dbbc98aa372f', v_aid, 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Що це?»', null, '[]'::jsonb, null, 'Što je to?', null, null, null, '«Що це?» — «Što je to?».', (select id from public.lessons where id = '8f6439a9-c6ac-5271-99c8-1f0adc5d7599'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під уроки за темою (curriculum_a0_v4) — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('97c80cdc-4661-5bbe-8106-658cb1300895', '562c650a-a7fb-5603-aced-823a529bae8f', '6a00f02b-8b5b-5e6c-a7a8-25b13f3b240a', '5dc4bf14-7e94-5513-992c-a9881899afb2', 'b0747384-7ffa-5a2d-969d-8d3955a83d63', '512fc60d-7ddc-5fb6-8270-6207c5b9a9b2', '1374f199-2a93-5bbe-99f3-d6a9e09423cc', 'b93451ec-af1c-5ff8-a67b-18cd767cf779', '8fd07580-e7db-58ce-a431-9e583ad590f5', '0e8b68d8-690c-5cad-b150-ed7124decdd7', '8e7f1b27-594b-57a6-b935-21b6559dea54', 'a40d492f-4247-5685-b312-a15bbcd6a336', 'cc8ec24f-e293-5c85-8432-2d80141d005c', 'c91e946b-ed1a-5fee-8221-4e00a45ecae5', '2c55c6c0-05c2-5192-96f0-bb99d979b4c8', 'b18131bc-f448-5cbc-b1dd-9170e9a10245', 'd8ba6c42-c4a5-5c87-b8e8-8be099abb8c3', 'f5da5962-d333-5009-bf87-bf49ebdd3ad6', 'e70e8eb6-7084-595a-9e65-1910cf1f448f', 'edeb8cb3-313a-5a95-b41c-dbbc98aa372f') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a0-m01', 'a0-m02')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'
                     and i.id not in ('97c80cdc-4661-5bbe-8106-658cb1300895', '562c650a-a7fb-5603-aced-823a529bae8f', '6a00f02b-8b5b-5e6c-a7a8-25b13f3b240a', '5dc4bf14-7e94-5513-992c-a9881899afb2', 'b0747384-7ffa-5a2d-969d-8d3955a83d63', '512fc60d-7ddc-5fb6-8270-6207c5b9a9b2', '1374f199-2a93-5bbe-99f3-d6a9e09423cc', 'b93451ec-af1c-5ff8-a67b-18cd767cf779', '8fd07580-e7db-58ce-a431-9e583ad590f5', '0e8b68d8-690c-5cad-b150-ed7124decdd7', '8e7f1b27-594b-57a6-b935-21b6559dea54', 'a40d492f-4247-5685-b312-a15bbcd6a336', 'cc8ec24f-e293-5c85-8432-2d80141d005c', 'c91e946b-ed1a-5fee-8221-4e00a45ecae5', '2c55c6c0-05c2-5192-96f0-bb99d979b4c8', 'b18131bc-f448-5cbc-b1dd-9170e9a10245', 'd8ba6c42-c4a5-5c87-b8e8-8be099abb8c3', 'f5da5962-d333-5009-bf87-bf49ebdd3ad6', 'e70e8eb6-7084-595a-9e65-1910cf1f448f', 'edeb8cb3-313a-5a95-b41c-dbbc98aa372f')));
  if v_new <> 20 or v_bad > 0 then raise exception 'Перевірки модулів: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірки модулів a0-m01, a0-m02 оновлено — % нових завдань', v_new;
end $$;

commit;
