-- =====================================================================
-- Перевірка модуля A1.6 під програму A1 v3 · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_assessment_a1_v3.py 6 (не редагуйте вручну).
--
-- Тести: a1-m06 — по 10 завдань із нових діалогів і вправ модуля.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A1). Середину й фінал рівня A1 не змінено (їх — після всього A1).
--   * Потрібні: 20261026_curriculum_a1_v3_structure.sql і 20261026_curriculum_a1_v3_m06.sql.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A1.6 · Модуль A1.6 — Робота
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a1-m06';
  if v_aid is null then  -- новий модуль програми v3: тесту ще немає
    insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index, pass_ratio,
                                    area_min_ratio, estimated_minutes, description_ua)
    values ('e61233d3-d4d5-5719-967a-d1822cca15c3', 'a1-m06', 'module', 'Перевірка модуля A1.6', 1, 'PUBLISHED', 'claude_assessment_v1', 'A1',
            '03c65998-2648-5d02-9254-f67ce765fe27', 6, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.')
    returning id into v_aid;
  end if;
  if exists (select 1 from public.assessment_items where id = 'e9d2c513-65cb-5716-82bf-73e6276f1cb7') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '03c65998-2648-5d02-9254-f67ce765fe27'::uuid then
    raise exception 'Тест a1-m06 прив’язаний не до модуля A1.6 — спершу 20261026_curriculum_a1_v3_structure.sql';
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
  ('e9d2c513-65cb-5716-82bf-73e6276f1cb7', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А де я бачу понаднормові години?", "Шефе, можна мені взяти два дні відпустки?", "Добрий день, це Лука. Пані Бабич на місці?"]'::jsonb, 0, null, 'A gdje vidim prekovremene sate?', null, null, 'Прозвучало: «A gdje vidim prekovremene sate?» — «А де я бачу понаднормові години?».', (select id from public.lessons where id = '4d6f3498-2cc5-54a0-b4e4-c66add71ef12'), 'PUBLISHED', 'claude_assessment_v1'),
  ('babbb7ea-6012-5152-8b8d-e8d2d135878a', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Де нарада?", "Коли виплата?", "Керівниця сувора?"]'::jsonb, 0, null, 'Gdje je sastanak?', null, null, 'Прозвучало: «Gdje je sastanak?» — «Де нарада?».', (select id from public.lessons where id = 'ee016ba8-5160-581d-b440-1bcb7647173d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('ead8a8f8-40f4-5785-95f6-7bed19e15621', v_aid, 3, 'A1', 'reading', 'understand', 'multiple_choice', 'Коли перший робочий день?', 'Mail od poslodavca', '["У понеділок", "У п’ятницю", "Завтра"]'::jsonb, 0, null, null, 'Poštovani gospodine Melnyk,
dobro došli u našu tvrtku! Vaš prvi radni dan je u ponedjeljak. Dođite u osam sati na ulaz B. Na recepciji Vas čeka voditeljica smjene, gospođa Babić. Ponesite osobnu iskaznicu, OIB i broj računa u banci. Radnu odjeću dobivate prvi dan.
Lijep pozdrav,
Ana Perić, ured za ljudske resurse', 'Шановний пане Мельник,
ласкаво просимо до нашої компанії! Ваш перший робочий день — у понеділок. Приходьте о восьмій годині до входу B. На рецепції на вас чекатиме керівниця зміни, пані Бабич. Візьміть із собою посвідчення особи, OIB і номер банківського рахунку. Робочий одяг отримаєте першого дня.
З повагою,
Ана Перич, відділ кадрів', 'Текст «Лист від роботодавця». Правильна відповідь: «У понеділок».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('667918a8-befe-5340-90be-fbde437112aa', v_aid, 4, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Kada možete početi?', '["Volim sportsku odjeću. Visoke pete mi se ne sviđaju.", "Možemo. Montiranje je besplatno.", "Od prvog sljedećeg mjeseca."]'::jsonb, 2, null, 'Kada možete početi?', null, null, 'Діалог «Навички й досвід»: «Kada možete početi?» (Коли можете почати?) — «Od prvog sljedećeg mjeseca.» (З першого числа наступного місяця.).', (select id from public.lessons where id = '92858dbe-ede1-5bc5-b80a-c796c5598019'), 'PUBLISHED', 'claude_assessment_v1'),
  ('9f24cd69-7ee1-5fbb-9960-bd5b05de288d', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Nije, danas je odsutna. Želite li ostaviti poruku?', '["Recite joj da sam bolestan i da danas ne dolazim.", "Obično zobene pahuljice s voćem i malo meda.", "Šest eura, a juha je besplatna."]'::jsonb, 0, null, 'Nije, danas je odsutna. Želite li ostaviti poruku?', null, null, 'Діалог «Повідомлення секретарці»: «Nije, danas je odsutna. Želite li ostaviti poruku?» (Ні, сьогодні її немає. Бажаєте залишити повідомлення?) — «Recite joj da sam bolestan i da danas ne dolazim.» (Скажіть їй, що я хворий і сьогодні не прийду.).', (select id from public.lessons where id = 'e806dd39-4d38-5781-ad2d-949961dd95f9'), 'PUBLISHED', 'claude_assessment_v1'),
  ('0aa6dd70-6f4b-51c2-b6dc-aba212e95b7a', v_aid, 6, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Gdje je sastanak?', '["У тебе є степлер? Мені треба скріпити презентацію.", "У переговорній на другому поверсі.", "Хочеш кави? Кавовий автомат знову працює."]'::jsonb, 1, null, null, 'Luka: Gdje je sastanak?
Darja: U sali za sastanke na drugom katu.
Luka: Imaš li klamericu? Moram spojiti prezentaciju.
Darja: Uzmi je iz moje ladice. I donesi registrator s računima.
Luka: Hoćeš li kavu? Aparat za kavu opet radi.
Darja: Hoću, i ponesi bilježnicu za bilješke.', 'Luka: Де нарада?
Darja: У переговорній на другому поверсі.
Luka: У тебе є степлер? Мені треба скріпити презентацію.
Darja: Візьми з моєї шухляди. І принеси реєстратор із рахунками.
Luka: Хочеш кави? Кавовий автомат знову працює.
Darja: Хочу, і візьми зошит для нотаток.', 'Діалог «Перед нарадою»: «Gdje je sastanak?» — «U sali za sastanke na drugom katu.», тобто «У переговорній на другому поверсі.».', (select id from public.lessons where id = 'ee016ba8-5160-581d-b440-1bcb7647173d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('bd56175e-3553-5e9d-b8b6-6ae6cd34db6b', v_aid, 7, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Коли ти починаєш працювати?». Що ви скажете?', null, '["Ovdje se ne smije pušiti.", "Kada počinješ raditi?", "Što radiš po zanimanju?"]'::jsonb, 1, null, null, null, null, '«Коли ти починаєш працювати?» — «Kada počinješ raditi?».', (select id from public.lessons where id = 'd813e9c0-2331-59d8-90f1-cea7e9a61c7d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('7b1190f0-5a88-54a5-b28b-62411401f7b7', v_aid, 8, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «адміністратор (на рецепції)»', null, '[]'::jsonb, null, 'recepcioner', null, null, null, '«адміністратор (на рецепції)» — recepcioner.', (select id from public.lessons where id = 'b369f01f-4a84-57b4-98cb-150d236f4d7f'), 'PUBLISHED', 'claude_assessment_v1'),
  ('7f407b61-2347-5c1c-8e82-6417abf1b6c0', v_aid, 9, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Де ви працювали раніше?»', null, '["prije?", "radili", "ste", "Gdje"]'::jsonb, null, 'Gdje ste radili prije?', null, null, null, '«Де ви працювали раніше?» — «Gdje ste radili prije?».', (select id from public.lessons where id = '92858dbe-ede1-5bc5-b80a-c796c5598019'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e64e5611-da1e-5cf4-a643-d48b3ee099f2', v_aid, 10, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Яка зарплата нетто?»', null, '[]'::jsonb, null, 'Kolika je neto plaća?', null, null, null, '«Яка зарплата нетто?» — «Kolika je neto plaća?».', (select id from public.lessons where id = '4d6f3498-2cc5-54a0-b4e4-c66add71ef12'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під програму A1 v3 — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('e9d2c513-65cb-5716-82bf-73e6276f1cb7', 'babbb7ea-6012-5152-8b8d-e8d2d135878a', 'ead8a8f8-40f4-5785-95f6-7bed19e15621', '667918a8-befe-5340-90be-fbde437112aa', '9f24cd69-7ee1-5fbb-9960-bd5b05de288d', '0aa6dd70-6f4b-51c2-b6dc-aba212e95b7a', 'bd56175e-3553-5e9d-b8b6-6ae6cd34db6b', '7b1190f0-5a88-54a5-b28b-62411401f7b7', '7f407b61-2347-5c1c-8e82-6417abf1b6c0', 'e64e5611-da1e-5cf4-a643-d48b3ee099f2') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a1-m06')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('e9d2c513-65cb-5716-82bf-73e6276f1cb7', 'babbb7ea-6012-5152-8b8d-e8d2d135878a', 'ead8a8f8-40f4-5785-95f6-7bed19e15621', '667918a8-befe-5340-90be-fbde437112aa', '9f24cd69-7ee1-5fbb-9960-bd5b05de288d', '0aa6dd70-6f4b-51c2-b6dc-aba212e95b7a', 'bd56175e-3553-5e9d-b8b6-6ae6cd34db6b', '7b1190f0-5a88-54a5-b28b-62411401f7b7', '7f407b61-2347-5c1c-8e82-6417abf1b6c0', 'e64e5611-da1e-5cf4-a643-d48b3ee099f2')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів A1: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірку a1-m06 оновлено — % нових завдань', v_new;
end $$;

commit;
