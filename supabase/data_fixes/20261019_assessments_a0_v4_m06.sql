-- =====================================================================
-- Перевірки модулів A0 під уроки за темою (curriculum_a0_v4) · 2026-10-19
-- Згенеровано: python3 -B scripts/gen_assessment_a0_v4.py (не редагуйте вручну).
--
-- Тести: a0-m06 — по 10 завдань із нових діалогів і вправ модулів A0.6.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A0). Середину й фінал рівня A0 не змінено.
--   * Потрібні: 20261015_assessments_a0_v1.sql і уроки curriculum_a0_v4 модуля A0.6 (20261019_curriculum_a0_v4_m06.sql).
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A0.6 · Модуль A0.6 — Moj dom (мій дім)
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a0-m06';
  if v_aid is null then raise exception 'Немає тесту a0-m06 — спершу 20261015_assessments_a0_v1.sql'; end if;
  if exists (select 1 from public.assessment_items where id = '95fc7040-4c6e-5747-9dc0-e9be78a47d22') then return; end if;  -- уже оновлено
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
  ('95fc7040-4c6e-5747-9dc0-e9be78a47d22', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А де ти тримаєш книжки?", "Ви берете заставу?", "Не забуду. Мамо, де мій зарядний?"]'::jsonb, 2, null, 'Neću. Mama, gdje je moj punjač?', null, null, 'Прозвучало: «Neću. Mama, gdje je moj punjač?» — «Не забуду. Мамо, де мій зарядний?».', (select id from public.lessons where id = '0ecb6f19-2630-533d-9f1b-85102442af08'), 'PUBLISHED', 'claude_assessment_v1'),
  ('ba999057-45d0-5694-8e70-7958f2cbad2a', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А стара була маленька й темна, так?", "Добрий день, чим можу допомогти?", "Дашо, яка твоя нова квартира?"]'::jsonb, 0, null, 'A stari je bio mali i taman, zar ne?', null, null, 'Прозвучало: «A stari je bio mali i taman, zar ne?» — «А стара була маленька й темна, так?».', (select id from public.lessons where id = 'f51692d8-cb95-5f2e-8263-f3728f5e10c0'), 'PUBLISHED', 'claude_assessment_v1'),
  ('4ef83566-d8f1-5768-ae11-8bf63cc10230', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Де пароль від Wi-Fi?', 'Poruka u apartmanu', '["На холодильнику", "Біля дверей", "На столі"]'::jsonb, 0, null, null, 'Dobro došli!
Ključ je na stolu.
Lozinka za Wi-Fi je na hladnjaku.
Kupaonica je lijevo, kuhinja je desno.
Ugodan boravak!', 'Ласкаво просимо!
Ключ — на столі.
Пароль від Wi-Fi — на холодильнику.
Ванна кімната ліворуч, кухня праворуч.
Приємного перебування!', 'Текст «Записка в апартаментах». Правильна відповідь: «На холодильнику».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('1fa3088f-1635-549b-9c67-bc4d351344a1', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Joj, žao mi je. Što se točno dogodilo?', '["Nas je dvanaest.", "Jedno pivo, molim. Veliko.", "Ne pali se. Mislim da je pokvarena."]'::jsonb, 2, null, 'Joj, žao mi je. Što se točno dogodilo?', null, null, 'Діалог «Не працює пральна машина»: «Joj, žao mi je. Što se točno dogodilo?» (Ой, мені шкода. Що саме сталося?) — «Ne pali se. Mislim da je pokvarena.» (Не вмикається. Думаю, вона зламалася.).', (select id from public.lessons where id = 'e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9'), 'PUBLISHED', 'claude_assessment_v1'),
  ('138e6e86-69e7-5c74-b9fe-5b58493beb84', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Je li namješten?', '["Preko puta, u knjižari.", "Izgubio sam se. Tražim hotel Central.", "Jest, potpuno. Najamnina je petsto eura, a režije posebno."]'::jsonb, 2, null, 'Je li namješten?', null, null, 'Діалог «Оголошення»: «Je li namješten?» (Вона мебльована?) — «Jest, potpuno. Najamnina je petsto eura, a režije posebno.» (Так, повністю. Оренда — п’ятсот євро, а комунальні окремо.).', (select id from public.lessons where id = '78f28f85-dd8b-5e81-8a52-1b2dbce4eb34'), 'PUBLISHED', 'claude_assessment_v1'),
  ('10744ff8-fdb2-57ba-a3fd-bdf9fda9779c', v_aid, 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Danilo, jesi li zatvorio prozor u kuhinji?', '["Добре. Не забудь замкнути двері!", "Так. І вимкнув світло.", "У твоєму рюкзаку. Ходімо, ми запізнюємося!"]'::jsonb, 1, null, null, 'Daša: Danilo, jesi li zatvorio prozor u kuhinji?
Danilo: Jesam. I ugasio sam svjetlo.
Daša: Dobro. Ne zaboravi zaključati vrata!
Danilo: Neću. Mama, gdje je moj punjač?
Daša: U tvom ruksaku. Idemo, kasnimo!', 'Daša: Даниле, ти зачинив вікно на кухні?
Danilo: Так. І вимкнув світло.
Daša: Добре. Не забудь замкнути двері!
Danilo: Не забуду. Мамо, де мій зарядний?
Daša: У твоєму рюкзаку. Ходімо, ми запізнюємося!', 'Діалог «Перед виходом»: «Danilo, jesi li zatvorio prozor u kuhinji?» — «Jesam. I ugasio sam svjetlo.», тобто «Так. І вимкнув світло.».', (select id from public.lessons where id = '0ecb6f19-2630-533d-9f1b-85102442af08'), 'PUBLISHED', 'claude_assessment_v1'),
  ('6557c46b-e17c-52b3-828e-9a8f4ca15a67', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Кімната маленька, але чиста». Що ви скажете?', null, '["Desno od vrata.", "Soba je mala, ali čista.", "Tražim stan."]'::jsonb, 1, null, null, null, null, '«Кімната маленька, але чиста.» — «Soba je mala, ali čista.».', (select id from public.lessons where id = 'f51692d8-cb95-5f2e-8263-f3728f5e10c0'), 'PUBLISHED', 'claude_assessment_v1'),
  ('6641750b-a632-5867-a1bd-9b8ef06797e6', v_aid, 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «широкий»', null, '[]'::jsonb, null, 'širok', null, null, null, '«широкий» — širok.', (select id from public.lessons where id = 'f51692d8-cb95-5f2e-8263-f3728f5e10c0'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e2485def-8ab8-5aa4-91cc-dc96e64d1016', v_aid, 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Квартира ще вільна?»', null, '["slobodan?", "stan", "još", "li", "Je"]'::jsonb, null, 'Je li stan još slobodan?', null, null, null, '«Квартира ще вільна?» — «Je li stan još slobodan?».', (select id from public.lessons where id = '78f28f85-dd8b-5e81-8a52-1b2dbce4eb34'), 'PUBLISHED', 'claude_assessment_v1'),
  ('88eb4d85-6ae0-5807-9bd2-fc012bdfe8e9', v_aid, 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Це зручне крісло.»', null, '[]'::jsonb, null, 'Ovo je udobna fotelja.', null, null, null, '«Це зручне крісло.» — «Ovo je udobna fotelja.».', (select id from public.lessons where id = '1436c20e-0aea-550a-b66d-fb3149a1c2e2'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під уроки за темою (curriculum_a0_v4) — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('95fc7040-4c6e-5747-9dc0-e9be78a47d22', 'ba999057-45d0-5694-8e70-7958f2cbad2a', '4ef83566-d8f1-5768-ae11-8bf63cc10230', '1fa3088f-1635-549b-9c67-bc4d351344a1', '138e6e86-69e7-5c74-b9fe-5b58493beb84', '10744ff8-fdb2-57ba-a3fd-bdf9fda9779c', '6557c46b-e17c-52b3-828e-9a8f4ca15a67', '6641750b-a632-5867-a1bd-9b8ef06797e6', 'e2485def-8ab8-5aa4-91cc-dc96e64d1016', '88eb4d85-6ae0-5807-9bd2-fc012bdfe8e9') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a0-m06')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'
                     and i.id not in ('95fc7040-4c6e-5747-9dc0-e9be78a47d22', 'ba999057-45d0-5694-8e70-7958f2cbad2a', '4ef83566-d8f1-5768-ae11-8bf63cc10230', '1fa3088f-1635-549b-9c67-bc4d351344a1', '138e6e86-69e7-5c74-b9fe-5b58493beb84', '10744ff8-fdb2-57ba-a3fd-bdf9fda9779c', '6557c46b-e17c-52b3-828e-9a8f4ca15a67', '6641750b-a632-5867-a1bd-9b8ef06797e6', 'e2485def-8ab8-5aa4-91cc-dc96e64d1016', '88eb4d85-6ae0-5807-9bd2-fc012bdfe8e9')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірки модулів a0-m06 оновлено — % нових завдань', v_new;
end $$;

commit;
