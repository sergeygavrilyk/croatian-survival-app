-- =====================================================================
-- Перевірка модуля A1.10 під програму A1 v3 · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_assessment_a1_v3.py 10 (не редагуйте вручну).
--
-- Тести: a1-m10 — по 10 завдань із нових діалогів і вправ модуля.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A1). Середину й фінал рівня A1 не змінено (їх — після всього A1).
--   * Потрібні: 20261026_curriculum_a1_v3_structure.sql і 20261026_curriculum_a1_v3_m10.sql.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A1.10 · Модуль A1.10 — Подорожуємо Хорватією
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a1-m10';
  if v_aid is null then  -- новий модуль програми v3: тесту ще немає
    insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index, pass_ratio,
                                    area_min_ratio, estimated_minutes, description_ua)
    values ('8bec7c1a-a67d-598b-940a-f8711352ec1e', 'a1-m10', 'module', 'Перевірка модуля A1.10', 1, 'PUBLISHED', 'claude_assessment_v1', 'A1',
            '4a99a045-1da4-5ac1-be05-74811dd7d630', 10, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.')
    returning id into v_aid;
  end if;
  if exists (select 1 from public.assessment_items where id = '9f7a2331-5751-5668-81f0-80f8977d1f00') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '4a99a045-1da4-5ac1-be05-74811dd7d630'::uuid then
    raise exception 'Тест a1-m10 прив’язаний не до модуля A1.10 — спершу 20261026_curriculum_a1_v3_structure.sql';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'curriculum_a1_v3: перевірку модуля оновлено під нові уроки — старі завдання');
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + 100
   where assessment_id = v_aid and status = 'PUBLISHED' and order_index <= 100;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('9f7a2331-5751-5668-81f0-80f8977d1f00', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Ми їдемо машиною, тож беремо пором.", "Я складу план подорожі сьогодні ввечері.", "Живуть, і вовки, і рисі, але вони дуже полохливі."]'::jsonb, 1, null, 'Napravit ću plan puta večeras.', null, null, 'Прозвучало: «Napravit ću plan puta večeras.» — «Я складу план подорожі сьогодні ввечері.».', (select id from public.lessons where id = '373074e1-3c4b-5d0f-a4f3-3ed06e0904f2'), 'PUBLISHED', 'claude_assessment_v1'),
  ('afb9863f-e46b-59f3-8334-8e7d41c7254b', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Білка! А вночі почуємо сову.", "Є невеликі хвилі, але пором ходить.", "Дивись, дельфіни біля човна!"]'::jsonb, 2, null, 'Gledaj, dupini pored broda!', null, null, 'Прозвучало: «Gledaj, dupini pored broda!» — «Дивись, дельфіни біля човна!».', (select id from public.lessons where id = '88e6f563-29dd-5e5d-865b-67fa47474b07'), 'PUBLISHED', 'claude_assessment_v1'),
  ('a8aa4f00-49c4-58d6-a4e3-d7cf953858d0', v_aid, 3, 'A1', 'reading', 'understand', 'multiple_choice', 'Яка погода завтра на морі?', 'Vremenska prognoza', '["Дощ", "Сонячно й тепло", "Сніг"]'::jsonb, 1, null, null, 'Sutra je na moru sunčano i toplo, do 28 stupnjeva. U Zagrebu i na sjeveru je oblačno, a poslijepodne pada kiša. Temperatura je od 15 do 20 stupnjeva. U planinama puše jak vjetar. Na Jadranu puše jugo, zato trajekti mogu kasniti.', 'Завтра на морі сонячно й тепло, до 28 градусів. У Загребі й на півночі хмарно, а після обіду йде дощ. Температура від 15 до 20 градусів. У горах дме сильний вітер. На Адріатиці дме юго, тому пороми можуть запізнюватися.', 'Текст «Прогноз погоди». Правильна відповідь: «Сонячно й тепло».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('f37b1508-581c-5e93-9aa8-d50de521e4d9', v_aid, 4, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Idemo li sutra na Plitvice ili na Krku?', '["Obično zobene pahuljice s voćem i malo meda.", "Na Plitvice. Ondje su najljepša jezera i slapovi.", "Rijetko. Pročitajte upute u kutiji."]'::jsonb, 1, null, 'Idemo li sutra na Plitvice ili na Krku?', null, null, 'Діалог «Плітвіце»: «Idemo li sutra na Plitvice ili na Krku?» (Поїдемо завтра на Плітвіце чи на Крку?) — «Na Plitvice. Ondje su najljepša jezera i slapovi.» (На Плітвіце. Там найгарніші озера й водоспади.).', (select id from public.lessons where id = '84a20a00-701a-5ce5-a3c8-fca72986f912'), 'PUBLISHED', 'claude_assessment_v1'),
  ('3f29234c-ea21-583d-a31c-8e7a4ad79a0c', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koji je kraj najljepši?', '["Jučer sam se jako loše osjećala. Imala sam vrtoglavicu.", "Za mene primorski, Dalmacija je jedna od najljepših regija.", "Riba na žaru. Potvrdit ću vam rezervaciju porukom."]'::jsonb, 1, null, 'Koji je kraj najljepši?', null, null, 'Діалог «Як вони говорять?»: «Koji je kraj najljepši?» (Який край найгарніший?) — «Za mene primorski, Dalmacija je jedna od najljepših regija.» (Для мене приморський, Далмація — один із найгарніших регіонів.).', (select id from public.lessons where id = '8633c234-d638-57f1-ad92-1c78be43fb07'), 'PUBLISHED', 'claude_assessment_v1'),
  ('57a0eb8f-4f45-55a3-8dde-2a30fc08541b', v_aid, 6, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Ima li izvora pitke vode?', '["Є, але візьми й свою воду.", "Я люблю природу, поїдьмо у вересні!", "Глибокі печери, каньйон і ліси."]'::jsonb, 0, null, null, 'Marko: Darja, jesi li bila u parku prirode Velebit?
Darja: Nisam. Što ima ondje?
Marko: Duboke špilje, kanjon i šume.
Darja: Ima li izvora pitke vode?
Marko: Ima, ali ponesi i svoju vodu.
Darja: Volim prirodu, idemo u rujnu!', 'Marko: Даріє, ти була в природному парку Велебіт?
Darja: Ні. Що там є?
Marko: Глибокі печери, каньйон і ліси.
Darja: Там є джерела питної води?
Marko: Є, але візьми й свою воду.
Darja: Я люблю природу, поїдьмо у вересні!', 'Діалог «Печера й каньйон»: «Ima li izvora pitke vode?» — «Ima, ali ponesi i svoju vodu.», тобто «Є, але візьми й свою воду.».', (select id from public.lessons where id = '84a20a00-701a-5ce5-a3c8-fca72986f912'), 'PUBLISHED', 'claude_assessment_v1'),
  ('05ca05dc-3c88-54f5-9fe2-6a68f415991e', v_aid, 7, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Яка буде погода завтра?». Що ви скажете?', null, '["Kartu za trajekt, molim.", "Kakvo će biti vrijeme sutra?", "Vidjeli smo jelena."]'::jsonb, 1, null, null, null, null, '«Яка буде погода завтра?» — «Kakvo će biti vrijeme sutra?».', (select id from public.lessons where id = '0cb42e87-0ece-5e12-a07c-05cb5c370157'), 'PUBLISHED', 'claude_assessment_v1'),
  ('3e91b114-d0eb-5488-80e8-d631d5edb808', v_aid, 8, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «злива»', null, '[]'::jsonb, null, 'pljusak', null, null, null, '«злива» — pljusak.', (select id from public.lessons where id = '0cb42e87-0ece-5e12-a07c-05cb5c370157'), 'PUBLISHED', 'claude_assessment_v1'),
  ('94e80092-8213-5222-a81c-26180a412063', v_aid, 9, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Це один із найгарніших островів.»', null, '["jedan", "otoka.", "je", "To", "najljepših", "od"]'::jsonb, null, 'To je jedan od najljepših otoka.', null, null, null, '«Це один із найгарніших островів.» — «To je jedan od najljepših otoka.».', (select id from public.lessons where id = '8633c234-d638-57f1-ad92-1c78be43fb07'), 'PUBLISHED', 'claude_assessment_v1'),
  ('30246425-6ea5-5ae8-8d0c-8317957aefdb', v_aid, 10, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Дивись, дельфіни!»', null, '[]'::jsonb, null, 'Gledaj, dupini!', null, null, null, '«Дивись, дельфіни!» — «Gledaj, dupini!».', (select id from public.lessons where id = '88e6f563-29dd-5e5d-865b-67fa47474b07'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під програму A1 v3 — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('9f7a2331-5751-5668-81f0-80f8977d1f00', 'afb9863f-e46b-59f3-8334-8e7d41c7254b', 'a8aa4f00-49c4-58d6-a4e3-d7cf953858d0', 'f37b1508-581c-5e93-9aa8-d50de521e4d9', '3f29234c-ea21-583d-a31c-8e7a4ad79a0c', '57a0eb8f-4f45-55a3-8dde-2a30fc08541b', '05ca05dc-3c88-54f5-9fe2-6a68f415991e', '3e91b114-d0eb-5488-80e8-d631d5edb808', '94e80092-8213-5222-a81c-26180a412063', '30246425-6ea5-5ae8-8d0c-8317957aefdb') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a1-m10')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('9f7a2331-5751-5668-81f0-80f8977d1f00', 'afb9863f-e46b-59f3-8334-8e7d41c7254b', 'a8aa4f00-49c4-58d6-a4e3-d7cf953858d0', 'f37b1508-581c-5e93-9aa8-d50de521e4d9', '3f29234c-ea21-583d-a31c-8e7a4ad79a0c', '57a0eb8f-4f45-55a3-8dde-2a30fc08541b', '05ca05dc-3c88-54f5-9fe2-6a68f415991e', '3e91b114-d0eb-5488-80e8-d631d5edb808', '94e80092-8213-5222-a81c-26180a412063', '30246425-6ea5-5ae8-8d0c-8317957aefdb')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів A1: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірку a1-m10 оновлено — % нових завдань', v_new;
end $$;

commit;
