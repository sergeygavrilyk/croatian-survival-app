-- =====================================================================
-- Перевірки модулів A0 під уроки за темою (curriculum_a0_v4) · 2026-10-19
-- Згенеровано: python3 -B scripts/gen_assessment_a0_v4.py (не редагуйте вручну).
--
-- Тести: a0-m07 — по 10 завдань із нових діалогів і вправ модулів A0.7.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A0). Середину й фінал рівня A0 не змінено.
--   * Потрібні: 20261015_assessments_a0_v1.sql і уроки curriculum_a0_v4 модуля A0.7 (20261019_curriculum_a0_v4_m07.sql).
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A0.7 · Модуль A0.7 — Hrana (їжа)
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a0-m07';
  if v_aid is null then raise exception 'Немає тесту a0-m07 — спершу 20261015_assessments_a0_v1.sql'; end if;
  if exists (select 1 from public.assessment_items where id = 'e582a14f-c1f9-5724-96d4-74eab982f066') then return; end if;  -- уже оновлено
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
  ('e582a14f-c1f9-5724-96d4-74eab982f066', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Є паста з овочами.", "Перепрошую, рахунок, будь ласка!", "Усе було чудово, дякую. Решта — вам."]'::jsonb, 0, null, 'Imamo tjesteninu s povrćem.', null, null, 'Прозвучало: «Imamo tjesteninu s povrćem.» — «Є паста з овочами.».', (select id from public.lessons where id = 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('5282eca6-a25c-54d4-bf65-e7c80417a1a6', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Хочете збиті вершки?", "Що ви нам порадите?", "Кальмари свіжі?"]'::jsonb, 2, null, 'Jesu li lignje svježe?', null, null, 'Прозвучало: «Jesu li lignje svježe?» — «Кальмари свіжі?».', (select id from public.lessons where id = 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('5bb4ebf9-7ed8-5a7a-ab9c-94f4ec772a05', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Скільки коштує чай?', 'Cjenik kafića', '["2,50 €", "1,50 €", "1,80 €"]'::jsonb, 1, null, null, 'CJENIK
Kava 1,80 €
Kava s mlijekom 2,20 €
Čaj 1,50 €
Sok 2,50 €
Voda 1,20 €', 'ЦІНИ
Кава 1,80 €
Кава з молоком 2,20 €
Чай 1,50 €
Сік 2,50 €
Вода 1,20 €', 'Текст «Ціни в кафе». Правильна відповідь: «1,50 €».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('a2544ea8-7042-509f-8416-49410386a398', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Ja ne pijem alkohol. Što imate bezalkoholno?', '["Ta majica košta dvadeset eura.", "Imamo sokove, limunadu i mineralnu vodu.", "Otprilike šest sati."]'::jsonb, 1, null, 'Ja ne pijem alkohol. Što imate bezalkoholno?', null, null, 'Діалог «Що будете пити?»: «Ja ne pijem alkohol. Što imate bezalkoholno?» (Я не п’ю алкоголю. Що у вас є безалкогольне?) — «Imamo sokove, limunadu i mineralnu vodu.» (Маємо соки, лимонад і мінеральну воду.).', (select id from public.lessons where id = '77d640c4-4190-544a-8094-4e699f9a0a10'), 'PUBLISHED', 'claude_assessment_v1'),
  ('27154aca-61a5-5288-8f7c-b6cd66f68ee3', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Plaćate li zajedno ili odvojeno?', '["Zajedno. Danas ja častim!", "Jako je strpljiva i pametna.", "Ilica 25, u Zagrebu."]'::jsonb, 0, null, 'Plaćate li zajedno ili odvojeno?', null, null, 'Діалог «Рахунок»: «Plaćate li zajedno ili odvojeno?» (Платите разом чи окремо?) — «Zajedno. Danas ja častim!» (Разом. Сьогодні я пригощаю!).', (select id from public.lessons where id = '8b30911e-4e57-5648-9ff6-bd11c1b0e27e'), 'PUBLISHED', 'claude_assessment_v1'),
  ('81f6d685-9166-5701-8dce-1ccb2a2b7d70', v_aid, 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dobra večer, što ćete piti?', '["Тоді лимонад, і побільше льоду.", "Мені велике розливне пиво.", "Маємо соки, лимонад і мінеральну воду."]'::jsonb, 1, null, null, 'Konobar: Dobra večer, što ćete piti?
Luka: Za mene veliko točeno pivo.
Daša: Ja ne pijem alkohol. Što imate bezalkoholno?
Konobar: Imamo sokove, limunadu i mineralnu vodu.
Daša: Onda limunadu, s puno leda.
Konobar: Želite li i slamku?', 'Konobar: Добрий вечір, що будете пити?
Luka: Мені велике розливне пиво.
Daša: Я не п’ю алкоголю. Що у вас є безалкогольне?
Konobar: Маємо соки, лимонад і мінеральну воду.
Daša: Тоді лимонад, і побільше льоду.
Konobar: Вам ще й соломинку?', 'Діалог «Що будете пити?»: «Dobra večer, što ćete piti?» — «Za mene veliko točeno pivo.», тобто «Мені велике розливне пиво.».', (select id from public.lessons where id = '77d640c4-4190-544a-8094-4e699f9a0a10'), 'PUBLISHED', 'claude_assessment_v1'),
  ('6a7ce99c-b168-522e-8a36-19f5163a934b', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Що ви нам порадите?». Що ви скажете?', null, '["Čašu vode, molim.", "Što nam preporučujete?", "Što želite?"]'::jsonb, 1, null, null, null, null, '«Що ви нам порадите?» — «Što nam preporučujete?».', (select id from public.lessons where id = '8b30911e-4e57-5648-9ff6-bd11c1b0e27e'), 'PUBLISHED', 'claude_assessment_v1'),
  ('21ca1dc8-c589-5ed8-97da-ef3a61bc0708', v_aid, 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «ресторан»', null, '[]'::jsonb, null, 'restoran', null, null, null, '«ресторан» — restoran.', (select id from public.lessons where id = '8b30911e-4e57-5648-9ff6-bd11c1b0e27e'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e9e6545f-6630-59cd-8758-aade7fe568a5', v_aid, 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Пляшку мінеральної води, будь ласка.»', null, '["mineralne", "vode,", "molim.", "Bocu"]'::jsonb, null, 'Bocu mineralne vode, molim.', null, null, null, '«Пляшку мінеральної води, будь ласка.» — «Bocu mineralne vode, molim.».', (select id from public.lessons where id = '77d640c4-4190-544a-8094-4e699f9a0a10'), 'PUBLISHED', 'claude_assessment_v1'),
  ('f6200940-b9da-5872-9cb7-4dfcab0f12fe', v_aid, 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Це гостре?»', null, '[]'::jsonb, null, 'Je li ovo ljuto?', null, null, null, '«Це гостре?» — «Je li ovo ljuto?».', (select id from public.lessons where id = 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під уроки за темою (curriculum_a0_v4) — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('e582a14f-c1f9-5724-96d4-74eab982f066', '5282eca6-a25c-54d4-bf65-e7c80417a1a6', '5bb4ebf9-7ed8-5a7a-ab9c-94f4ec772a05', 'a2544ea8-7042-509f-8416-49410386a398', '27154aca-61a5-5288-8f7c-b6cd66f68ee3', '81f6d685-9166-5701-8dce-1ccb2a2b7d70', '6a7ce99c-b168-522e-8a36-19f5163a934b', '21ca1dc8-c589-5ed8-97da-ef3a61bc0708', 'e9e6545f-6630-59cd-8758-aade7fe568a5', 'f6200940-b9da-5872-9cb7-4dfcab0f12fe') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a0-m07')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'
                     and i.id not in ('e582a14f-c1f9-5724-96d4-74eab982f066', '5282eca6-a25c-54d4-bf65-e7c80417a1a6', '5bb4ebf9-7ed8-5a7a-ab9c-94f4ec772a05', 'a2544ea8-7042-509f-8416-49410386a398', '27154aca-61a5-5288-8f7c-b6cd66f68ee3', '81f6d685-9166-5701-8dce-1ccb2a2b7d70', '6a7ce99c-b168-522e-8a36-19f5163a934b', '21ca1dc8-c589-5ed8-97da-ef3a61bc0708', 'e9e6545f-6630-59cd-8758-aade7fe568a5', 'f6200940-b9da-5872-9cb7-4dfcab0f12fe')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірки модулів a0-m07 оновлено — % нових завдань', v_new;
end $$;

commit;
