-- =====================================================================
-- Тести рівня A0 (§60): 10 тестів модуля + середина рівня + фінальний · assessment_v1 · 2026-10-15
-- Згенеровано: python3 scripts/gen_assessment.py A0  (джерело — опубліковані уроки й тексти A0)
-- Потребує M17 (20261015160000_m17_level_assessments.sql). Безпечно запускати повторно:
-- наявні тести й завдання не перезаписуються. Статус: PUBLISHED (бета за рішенням власника 2026-10-15).
-- Що змінить: додасть 12 тестів і 150 завдань, запис у журнал перевірки.
-- =====================================================================

-- Перевірка модуля A0.1 · Модуль A0.1 — Pozdrav!
insert into public.assessments (id, slug, kind, title_ua, cefr, module_id, order_index, pass_ratio, area_min_ratio, estimated_minutes, description_ua, status, source)
values ('139f75e8-5e54-56f3-93fb-e4737af4ad6a', 'a0-m01', 'module', 'Перевірка модуля A0.1', 'A0', (select id from public.modules where level_code = 'A0' and order_index = 1), 1, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.', 'PUBLISHED', 'claude_assessment_v1')
on conflict (slug) do nothing;
insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options, correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('40573101-26c5-57c4-91c5-3ce311b1a8c5', '139f75e8-5e54-56f3-93fb-e4737af4ad6a', 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Дякую вам. Вітаю з новою роботою!", "Нічого страшного. Сідайте.", "До завтра! Гарного вечора!"]'::jsonb, 2, null, 'Do sutra! Ugodna večer!', null, null, 'Прозвучало: «Do sutra! Ugodna večer!» — «До завтра! Гарного вечора!».', (select id from public.lessons where id = 'e704760a-f743-5762-9c1a-027b10ca030a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('5c1828dc-64f7-560d-b175-84f01cdea240', '139f75e8-5e54-56f3-93fb-e4737af4ad6a', 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["На добраніч і приємного перебування!", "Прошу. Гарного дня!", "Дякую! Успіхів і вам!"]'::jsonb, 2, null, 'Hvala! Sretno i Vama!', null, null, 'Прозвучало: «Hvala! Sretno i Vama!» — «Дякую! Успіхів і вам!».', (select id from public.lessons where id = 'e704760a-f743-5762-9c1a-027b10ca030a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('a54cce46-8ddf-5d3e-9537-a8f10effa35c', '139f75e8-5e54-56f3-93fb-e4737af4ad6a', 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Що означає «Oprostite»?', 'Natpis na vratima kafića', '["Дякую", "Вибачте", "Привіт"]'::jsonb, 1, null, null, 'ZATVORENO
Oprostite, danas ne radimo.
Vidimo se sutra!
Hvala!', 'ЗАЧИНЕНО
Вибачте, сьогодні ми не працюємо.
Побачимося завтра!
Дякуємо!', 'Текст «Табличка на дверях кафе». Правильна відповідь: «Вибачте».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('1bfd540b-e327-5fe4-839d-d9f334f13acf', '139f75e8-5e54-56f3-93fb-e4737af4ad6a', 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Vrećicu? Trebate li vrećicu?', '["Početkom rujna, a završava u lipnju.", "Ovo je moja žena Olga.", "Ah, da. Jednu, molim."]'::jsonb, 2, null, 'Vrećicu? Trebate li vrećicu?', null, null, 'Діалог «У магазині»: «Vrećicu? Trebate li vrećicu?» (Пакет? Вам потрібен пакет?) — «Ah, da. Jednu, molim.» (А, так. Один, будь ласка.).', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d4b2c390-40a2-5df0-b593-156edea5d234', '139f75e8-5e54-56f3-93fb-e4737af4ad6a', 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dobro, hvala. A Vi?', '["Dvadeset dva, treći kat.", "Ne baš dobro. Umorna sam.", "Ja imam sedam. Ovo je moj pas."]'::jsonb, 1, null, 'Dobro, hvala. A Vi?', null, null, 'Діалог «У сусідки»: «Dobro, hvala. A Vi?» (Добре, дякую. А ви?) — «Ne baš dobro. Umorna sam.» (Не дуже добре. Я втомлена.).', (select id from public.lessons where id = 'c0000000-0000-0000-0000-000000000001'), 'PUBLISHED', 'claude_assessment_v1'),
  ('a9f18153-0560-54d5-b7b3-481b7f38d169', '139f75e8-5e54-56f3-93fb-e4737af4ad6a', 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Ne razumijem dobro hrvatski. Možete li govoriti polako?', '["Звісно. Ласкаво просимо до Загреба!", "Нема за що.", "Щиро дякую!"]'::jsonb, 0, null, null, 'Turist: Oprostite, govorite li engleski?
Prolaznik: Malo. Izvolite?
Turist: Ne razumijem dobro hrvatski. Možete li govoriti polako?
Prolaznik: Naravno. Dobro došli u Zagreb!
Turist: Hvala lijepa!
Prolaznik: Nema na čemu.', 'Turist: Вибачте, ви розмовляєте англійською?
Prolaznik: Трохи. Слухаю вас?
Turist: Я погано розумію хорватську. Можете говорити повільно?
Prolaznik: Звісно. Ласкаво просимо до Загреба!
Turist: Щиро дякую!
Prolaznik: Нема за що.', 'Діалог «Турист у Загребі»: «Ne razumijem dobro hrvatski. Možete li govoriti polako?» — «Naravno. Dobro došli u Zagreb!», тобто «Звісно. Ласкаво просимо до Загреба!».', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('20948e10-eed0-5774-b8a4-780007161886', '139f75e8-5e54-56f3-93fb-e4737af4ad6a', 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «У мене бронювання». Що ви скажете?', null, '["Jednu kavu, molim.", "Pozdravi obitelj!", "Imam rezervaciju."]'::jsonb, 2, null, null, null, null, '«У мене бронювання.» — «Imam rezervaciju.».', (select id from public.lessons where id = 'd8cffb46-8a62-538a-b864-e227a6d8b863'), 'PUBLISHED', 'claude_assessment_v1'),
  ('2f637833-6660-592a-b721-5612fdea97f8', '139f75e8-5e54-56f3-93fb-e4737af4ad6a', 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «пакет»', null, '[]'::jsonb, null, 'vrećica', null, null, null, '«пакет» — vrećica.', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('5bf32dee-30cd-5231-8151-4c78b1ed48db', '139f75e8-5e54-56f3-93fb-e4737af4ad6a', 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Побачимося завтра!»', null, '["Vidimo", "sutra!", "se"]'::jsonb, null, 'Vidimo se sutra!', null, null, null, '«Побачимося завтра!» — «Vidimo se sutra!».', (select id from public.lessons where id = 'e704760a-f743-5762-9c1a-027b10ca030a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('97f8c7e5-a58b-5137-a026-dd2e4bf4ee02', '139f75e8-5e54-56f3-93fb-e4737af4ad6a', 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Можете говорити повільно?»', null, '[]'::jsonb, null, 'Možete li govoriti polako?', null, null, null, '«Можете говорити повільно?» — «Možete li govoriti polako?».', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v1')
on conflict (id) do nothing;

-- Перевірка модуля A0.2 · Модуль A0.2 — Ja sam…
insert into public.assessments (id, slug, kind, title_ua, cefr, module_id, order_index, pass_ratio, area_min_ratio, estimated_minutes, description_ua, status, source)
values ('4a402350-5a98-5305-b5ea-e7ab92a3df66', 'a0-m02', 'module', 'Перевірка модуля A0.2', 'A0', (select id from public.modules where level_code = 'A0' and order_index = 2), 2, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.', 'PUBLISHED', 'claude_assessment_v1')
on conflict (slug) do nothing;
insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options, correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('9fc9553d-8b8b-5294-9441-f7e2c8263864', '4a402350-5a98-5305-b5ea-e7ab92a3df66', 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["У вас є досвід?", "Який номер будинку?", "Добрий день. Хто ви за фахом?"]'::jsonb, 0, null, 'Imate li iskustva?', null, null, 'Прозвучало: «Imate li iskustva?» — «У вас є досвід?».', (select id from public.lessons where id = '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('a4dd8b2a-2456-5e9c-970e-f5221e039234', '4a402350-5a98-5305-b5ea-e7ab92a3df66', 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А поштовий індекс?", "Так, я українка. А ти хорватка?", "Чудово. Ви говорите хорватською?"]'::jsonb, 0, null, 'A poštanski broj?', null, null, 'Прозвучало: «A poštanski broj?» — «А поштовий індекс?».', (select id from public.lessons where id = 'adf335ee-0cba-5c9a-b86a-8baac868edbc'), 'PUBLISHED', 'claude_assessment_v1'),
  ('5cf0bdba-e378-589e-b12b-c8e99d2ac8c4', '4a402350-5a98-5305-b5ea-e7ab92a3df66', 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Який номер кабінету?', 'Natpis na vratima ordinacije', '["30", "13", "3"]'::jsonb, 2, null, null, 'Dr. Ivo Kovač
liječnik obiteljske medicine
Soba 3
Molimo, pokucajte!', 'Д-р Іво Ковач
лікар сімейної медицини
Кабінет 3
Просимо, постукайте!', 'Текст «Табличка на дверях кабінету». Правильна відповідь: «3».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('a954e5f7-31c3-555d-819f-411701312740', '4a402350-5a98-5305-b5ea-e7ab92a3df66', 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Imate li iskustva?', '["Piletina s rižom i salatom.", "Da, pet godina.", "Čaj, molim. Šalicu toplog čaja."]'::jsonb, 1, null, 'Imate li iskustva?', null, null, 'Діалог «Співбесіда»: «Imate li iskustva?» (У вас є досвід?) — «Da, pet godina.» (Так, п’ять років.).', (select id from public.lessons where id = '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('8a86f9a9-5ef2-5ac9-b90f-530bf6983c3e', '4a402350-5a98-5305-b5ea-e7ab92a3df66', 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Jesam. Govoriš li hrvatski?', '["Malo. Govorim ukrajinski i engleski.", "Ta majica košta dvadeset eura.", "Zove se Bohdan. On je iz Ukrajine."]'::jsonb, 0, null, 'Jesam. Govoriš li hrvatski?', null, null, 'Діалог «Ти українка?»: «Jesam. Govoriš li hrvatski?» (Так. Ти говориш хорватською?) — «Malo. Govorim ukrajinski i engleski.» (Трохи. Я говорю українською й англійською.).', (select id from public.lessons where id = 'a9944193-2dfb-5944-b94c-41c41fdb7ca1'), 'PUBLISHED', 'claude_assessment_v1'),
  ('2c7fbf99-8320-5f91-ad40-9a858ffd3029', '4a402350-5a98-5305-b5ea-e7ab92a3df66', 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Ja sam programer. A ti?', '["Супер! А я працюю з дому.", "Я вчителька. Працюю в школі.", "Чим ти займаєшся?"]'::jsonb, 1, null, null, 'Petra: Što radiš?
Andrij: Ja sam programer. A ti?
Petra: Ja sam profesorica. Radim u školi.
Andrij: Super! Ja radim od kuće.', 'Petra: Чим ти займаєшся?
Andrij: Я програміст. А ти?
Petra: Я вчителька. Працюю в школі.
Andrij: Супер! А я працюю з дому.', 'Діалог «Розмова з сусідкою»: «Ja sam programer. A ti?» — «Ja sam profesorica. Radim u školi.», тобто «Я вчителька. Працюю в школі.».', (select id from public.lessons where id = '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('0a1c5a31-0df6-576d-96d5-3b794bffdd4a', '4a402350-5a98-5305-b5ea-e7ab92a3df66', 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я живу на другому поверсі». Що ви скажете?', null, '["Drago mi je.", "Ja sam Ukrajinac.", "Živim na drugom katu."]'::jsonb, 2, null, null, null, null, '«Я живу на другому поверсі.» — «Živim na drugom katu.».', (select id from public.lessons where id = 'adf335ee-0cba-5c9a-b86a-8baac868edbc'), 'PUBLISHED', 'claude_assessment_v1'),
  ('00eeb0a1-fd68-5a26-9219-8a36cebf58b3', '4a402350-5a98-5305-b5ea-e7ab92a3df66', 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «вчити (ся)»', null, '[]'::jsonb, null, 'učiti', null, null, null, '«вчити (ся)» — učiti.', (select id from public.lessons where id = '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('1fe336b9-cf36-51f8-8636-5c0f6817ae72', '4a402350-5a98-5305-b5ea-e7ab92a3df66', 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Добрий день. Як вас звати?»', null, '["Dobar", "se", "zovete?", "Kako", "dan."]'::jsonb, null, 'Dobar dan. Kako se zovete?', null, null, null, '«Добрий день. Як вас звати?» — «Dobar dan. Kako se zovete?».', (select id from public.lessons where id = '2b6ed342-cc80-5bd9-baf0-b66109624d62'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b522f22d-a45c-5af1-8912-23e37f0c9339', '4a402350-5a98-5305-b5ea-e7ab92a3df66', 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Я з України.»', null, '[]'::jsonb, null, 'Ja sam iz Ukrajine.', null, null, null, '«Я з України.» — «Ja sam iz Ukrajine.».', (select id from public.lessons where id = '04167753-db83-5163-a91c-9f71dac18ab5'), 'PUBLISHED', 'claude_assessment_v1')
on conflict (id) do nothing;

-- Перевірка модуля A0.3 · Модуль A0.3 — Brojevi (числа)
insert into public.assessments (id, slug, kind, title_ua, cefr, module_id, order_index, pass_ratio, area_min_ratio, estimated_minutes, description_ua, status, source)
values ('6368838d-f507-5791-b06b-af29eb19ca3b', 'a0-m03', 'module', 'Перевірка модуля A0.3', 'A0', (select id from public.modules where level_code = 'A0' and order_index = 3), 3, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.', 'PUBLISHED', 'claude_assessment_v1')
on conflict (slug) do nothing;
insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options, correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('1e976a7a-c619-53ff-866f-ac35036acf0d', '6368838d-f507-5791-b06b-af29eb19ca3b', 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А он та синя?", "Скільки вам років?", "Який ваш номер телефону?"]'::jsonb, 0, null, 'A ona plava?', null, null, 'Прозвучало: «A ona plava?» — «А он та синя?».', (select id from public.lessons where id = 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('6443b1bc-1e09-5786-86c5-1e19447485a4', '6368838d-f507-5791-b06b-af29eb19ca3b', 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["У нас є стіл на чотирнадцять, на терасі.", "Нуль, дев’ять, один, два, три, чотири, п’ять.", "Квартира номер три, на другому поверсі."]'::jsonb, 1, null, 'Nula, devet, jedan, dva, tri, četiri, pet.', null, null, 'Прозвучало: «Nula, devet, jedan, dva, tri, četiri, pet.» — «Нуль, дев’ять, один, два, три, чотири, п’ять.».', (select id from public.lessons where id = 'c0941bd8-57b5-5e7e-981f-9be423f24208'), 'PUBLISHED', 'claude_assessment_v1'),
  ('790e1d2a-5fbb-5372-8202-82a6bdb0ad80', '6368838d-f507-5791-b06b-af29eb19ca3b', 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Де ліфт?', 'Sobe u hotelu', '["Ліворуч", "Ліфта немає", "Праворуч"]'::jsonb, 2, null, null, 'Sobe 1 – 10: prvi kat
Sobe 11 – 20: drugi kat
Recepcija: prizemlje
Lift je desno.', 'Номери 1–10: перший поверх (над входом)
Номери 11–20: другий поверх
Рецепція: партер (поверх біля входу)
Ліфт праворуч.', 'Текст «Номери в готелі». Правильна відповідь: «Праворуч».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('262ec635-afe0-5b57-bd95-f6069c49a9e5', '6368838d-f507-5791-b06b-af29eb19ca3b', 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koji je Vaš broj telefona?', '["Malo. Učim hrvatski.", "Ja pijem limunadu s ledom.", "Nula devedeset jedan, šezdeset sedam, osamdeset dva, sedamdeset tri."]'::jsonb, 2, null, 'Koji je Vaš broj telefona?', null, null, 'Діалог «Номер телефону»: «Koji je Vaš broj telefona?» (Який ваш номер телефону?) — «Nula devedeset jedan, šezdeset sedam, osamdeset dva, sedamdeset tri.» (Нуль дев’яносто один, шістдесят сім, вісімдесят два, сімдесят три.).', (select id from public.lessons where id = 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('5d6f632c-548d-5c5f-9df8-25c5107ffc40', '6368838d-f507-5791-b06b-af29eb19ca3b', 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koliko košta ova jakna?', '["Izgubio sam se. Tražim hotel Central.", "Devedeset eura.", "Ja sam profesorica. Radim u školi."]'::jsonb, 1, null, 'Koliko košta ova jakna?', null, null, 'Діалог «Скільки коштує?»: «Koliko košta ova jakna?» (Скільки коштує ця куртка?) — «Devedeset eura.» (Дев’яносто євро.).', (select id from public.lessons where id = 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('82132e78-3a6e-56f1-a096-c6e3ee8ecf82', '6368838d-f507-5791-b06b-af29eb19ca3b', 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Koji autobus ide u centar?', '["Скільки хвилин до центру?", "Приблизно п’ятнадцять хвилин.", "Сімнадцятий або дев’ятнадцятий."]'::jsonb, 2, null, null, 'Turistkinja: Koji autobus ide u centar?
Gospodin: Sedamnaest ili devetnaest.
Turistkinja: Koliko minuta do centra?
Gospodin: Otprilike petnaest minuta.', 'Turistkinja: Який автобус їде в центр?
Gospodin: Сімнадцятий або дев’ятнадцятий.
Turistkinja: Скільки хвилин до центру?
Gospodin: Приблизно п’ятнадцять хвилин.', 'Діалог «Який автобус?»: «Koji autobus ide u centar?» — «Sedamnaest ili devetnaest.», тобто «Сімнадцятий або дев’ятнадцятий.».', (select id from public.lessons where id = 'e30c65f2-1a30-5b51-85e7-6a460cd1799f'), 'PUBLISHED', 'claude_assessment_v1'),
  ('818af186-df35-5b72-8360-9a1113837f80', '6368838d-f507-5791-b06b-af29eb19ca3b', 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Скажіть, будь ласка, ваш номер телефону». Що ви скажете?', null, '["Autobus broj jedanaest.", "Koliko imaš godina?", "Recite mi, molim, Vaš broj telefona."]'::jsonb, 2, null, null, null, null, '«Скажіть, будь ласка, ваш номер телефону.» — «Recite mi, molim, Vaš broj telefona.».', (select id from public.lessons where id = 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('fdfda79b-423d-5445-8401-a5ca4b831044', '6368838d-f507-5791-b06b-af29eb19ca3b', 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «одинадцять»', null, '[]'::jsonb, null, 'jedanaest', null, null, null, '«одинадцять» — jedanaest.', (select id from public.lessons where id = 'e30c65f2-1a30-5b51-85e7-6a460cd1799f'), 'PUBLISHED', 'claude_assessment_v1'),
  ('3a834055-31ff-560e-bae4-4aa9e63cd64f', '6368838d-f507-5791-b06b-af29eb19ca3b', 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Ось сто євро.»', null, '["sto", "eura.", "Evo"]'::jsonb, null, 'Evo sto eura.', null, null, null, '«Ось сто євро.» — «Evo sto eura.».', (select id from public.lessons where id = 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('988c8187-3749-5b96-96d2-d8f9d2dbcd51', '6368838d-f507-5791-b06b-af29eb19ca3b', 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Мені тридцять п’ять років.»', null, '[]'::jsonb, null, 'Imam trideset pet godina.', null, null, null, '«Мені тридцять п’ять років.» — «Imam trideset pet godina.».', (select id from public.lessons where id = '4c5db9c0-aa58-55c5-b647-7f7cfc8396c2'), 'PUBLISHED', 'claude_assessment_v1')
on conflict (id) do nothing;

-- Перевірка модуля A0.4 · Модуль A0.4 — Vrijeme (час)
insert into public.assessments (id, slug, kind, title_ua, cefr, module_id, order_index, pass_ratio, area_min_ratio, estimated_minutes, description_ua, status, source)
values ('658e6b3e-b9d7-565a-bbac-11efa09b325e', 'a0-m04', 'module', 'Перевірка модуля A0.4', 'A0', (select id from public.modules where level_code = 'A0' and order_index = 4), 4, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.', 'PUBLISHED', 'claude_assessment_v1')
on conflict (slug) do nothing;
insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options, correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('e6b6570b-be69-5aef-b7b5-6971b4bb1106', '658e6b3e-b9d7-565a-bbac-11efa09b325e', 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["У четвер ні, а в п’ятницю так.", "Немає! Автобус їде о сьомій сорок.", "У серпні. Їду на море."]'::jsonb, 0, null, 'U četvrtak ne, ali u petak da.', null, null, 'Прозвучало: «U četvrtak ne, ali u petak da.» — «У четвер ні, а в п’ятницю так.».', (select id from public.lessons where id = '8e372ece-ae10-50ae-9cf3-07b52ef2f72d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('bfa10c1c-5947-5b5b-8ab7-7f3e15c07d8f', '658e6b3e-b9d7-565a-bbac-11efa09b325e', 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["На початку вересня, а закінчується в червні.", "Насичений! Учора робота, сьогодні курс, а завтра — море!", "З кінця грудня до середини січня."]'::jsonb, 2, null, 'Od kraja prosinca do sredine siječnja.', null, null, 'Прозвучало: «Od kraja prosinca do sredine siječnja.» — «З кінця грудня до середини січня.».', (select id from public.lessons where id = 'b36b4550-ff36-50cb-89fb-8246b351c8d6'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d9d88db5-cad8-5921-9e1f-38af5311b8f2', '658e6b3e-b9d7-565a-bbac-11efa09b325e', 3, 'A0', 'reading', 'understand', 'multiple_choice', 'До котрої пошта працює в суботу?', 'Radno vrijeme pošte', '["До 13", "До 19", "До 8"]'::jsonb, 0, null, null, 'POŠTA
Radno vrijeme:
ponedjeljak – petak: 7 – 19 h
subota: 8 – 13 h
nedjelja: zatvoreno', 'ПОШТА
Години роботи:
понеділок – п’ятниця: 7–19
субота: 8–13
неділя: зачинено', 'Текст «Години роботи пошти». Правильна відповідь: «До 13».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('edd890fb-f1a4-57da-87df-d0fff91eb181', '658e6b3e-b9d7-565a-bbac-11efa09b325e', 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'U srpnju. A ti?', '["Tramvajem, autom je gužva. Stanica je na raskrižju.", "U siječnju. Volim zimu!", "Izgubio sam se. Tražim hotel Central."]'::jsonb, 1, null, 'U srpnju. A ti?', null, null, 'Діалог «День народження»: «U srpnju. A ti?» (У липні. А в тебе?) — «U siječnju. Volim zimu!» (У січні. Я люблю зиму!).', (select id from public.lessons where id = '036fc4fb-1bf2-5100-9fd0-6f6a612554a1'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e0b9cd7a-5062-5afe-96c3-58820c990b8e', '658e6b3e-b9d7-565a-bbac-11efa09b325e', 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Kada ideš na godišnji odmor?', '["Ja sam medicinska sestra.", "Krevet, stol, stolica i ormar.", "U kolovozu. Idem na more."]'::jsonb, 2, null, 'Kada ideš na godišnji odmor?', null, null, 'Діалог «Плани на відпустку»: «Kada ideš na godišnji odmor?» (Коли ти йдеш у відпустку?) — «U kolovozu. Idem na more.» (У серпні. Їду на море.).', (select id from public.lessons where id = '036fc4fb-1bf2-5100-9fd0-6f6a612554a1'), 'PUBLISHED', 'claude_assessment_v1'),
  ('4b61de91-e1db-5b25-97c3-88cdf2b291e4', '658e6b3e-b9d7-565a-bbac-11efa09b325e', 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Koliko je sati?', '["Вставай, уже пізно!", "Немає! Автобус їде о сьомій сорок.", "Пів на восьму."]'::jsonb, 2, null, null, 'Mama: Ustani, kasno je!
Dino: Koliko je sati?
Mama: Sedam i pol.
Dino: Škola počinje u osam. Imam vremena!
Mama: Nemaš! Autobus ide u sedam i četrdeset.', 'Mama: Вставай, уже пізно!
Dino: Котра година?
Mama: Пів на восьму.
Dino: Школа починається о восьмій. У мене є час!
Mama: Немає! Автобус їде о сьомій сорок.', 'Діалог «Вранці вдома»: «Koliko je sati?» — «Sedam i pol.», тобто «Пів на восьму.».', (select id from public.lessons where id = '39b1e31f-b573-5000-9713-1660688c3cc9'), 'PUBLISHED', 'claude_assessment_v1'),
  ('62327d88-7214-5666-aa72-c000d3cdac39', '658e6b3e-b9d7-565a-bbac-11efa09b325e', 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Сьогодні перше квітня». Що ви скажете?', null, '["Jučer, danas, sutra.", "Danas je prvi travnja.", "Koliko je sati?"]'::jsonb, 1, null, null, null, null, '«Сьогодні перше квітня.» — «Danas je prvi travnja.».', (select id from public.lessons where id = 'b36b4550-ff36-50cb-89fb-8246b351c8d6'), 'PUBLISHED', 'claude_assessment_v1'),
  ('9bc52b4b-c35e-5618-b6d1-e110bc53ecf7', '658e6b3e-b9d7-565a-bbac-11efa09b325e', 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «вчора»', null, '[]'::jsonb, null, 'jučer', null, null, null, '«вчора» — jučer.', (select id from public.lessons where id = '238d9508-3c2e-5ee6-910f-0ae8863c2dc7'), 'PUBLISHED', 'claude_assessment_v1'),
  ('54d6e46c-1503-5996-8f43-7c3da16e08d9', '658e6b3e-b9d7-565a-bbac-11efa09b325e', 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Післязавтра можна.»', null, '["može.", "Prekosutra"]'::jsonb, null, 'Prekosutra može.', null, null, null, '«Післязавтра можна.» — «Prekosutra može.».', (select id from public.lessons where id = '238d9508-3c2e-5ee6-910f-0ae8863c2dc7'), 'PUBLISHED', 'claude_assessment_v1'),
  ('4e788fba-a369-5522-bfd9-8da1c514bbc9', '658e6b3e-b9d7-565a-bbac-11efa09b325e', 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Учора, сьогодні, завтра.»', null, '[]'::jsonb, null, 'Jučer, danas, sutra.', null, null, null, '«Учора, сьогодні, завтра.» — «Jučer, danas, sutra.».', (select id from public.lessons where id = '238d9508-3c2e-5ee6-910f-0ae8863c2dc7'), 'PUBLISHED', 'claude_assessment_v1')
on conflict (id) do nothing;

-- Перевірка модуля A0.5 · Модуль A0.5 — Obitelj (сім’я)
insert into public.assessments (id, slug, kind, title_ua, cefr, module_id, order_index, pass_ratio, area_min_ratio, estimated_minutes, description_ua, status, source)
values ('792592a4-b105-53d8-a093-32f4e9ebac4a', 'a0-m05', 'module', 'Перевірка модуля A0.5', 'A0', (select id from public.modules where level_code = 'A0' and order_index = 5), 5, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.', 'PUBLISHED', 'claude_assessment_v1')
on conflict (slug) do nothing;
insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options, correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('eea9079d-c125-58a3-b3bc-ce6e215f11a6', '792592a4-b105-53d8-a093-32f4e9ebac4a', 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Скільки їм років?", "Як було в школі?", "Приємно познайомитися! У вас є діти?"]'::jsonb, 0, null, 'Koliko su stari?', null, null, 'Прозвучало: «Koliko su stari?» — «Скільки їм років?».', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v1'),
  ('1d333ea6-6954-5e33-a22d-e7ad117f75d6', '792592a4-b105-53d8-a093-32f4e9ebac4a', 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Супер! Запроси його до нас.", "Десять і дванадцять.", "У Києві. Бабуся й дідусь живуть у селі."]'::jsonb, 0, null, 'Super! Pozovi ga k nama.', null, null, 'Прозвучало: «Super! Pozovi ga k nama.» — «Супер! Запроси його до нас.».', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v1'),
  ('60756507-c893-572a-9a6d-17fe7b273b25', '792592a4-b105-53d8-a093-32f4e9ebac4a', 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Хто пише листівку?', 'Čestitka za rođendan', '["Мама", "Ана і Марко", "Тільки Ана"]'::jsonb, 1, null, null, 'Draga mama,
sretan rođendan!
Volimo te puno.
Tvoji Ana i Marko', 'Люба мамо,
з днем народження!
Ми тебе дуже любимо.
Твої Ана і Марко', 'Текст «Листівка на день народження». Правильна відповідь: «Ана і Марко».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('69deb8e7-193a-5654-a9c6-45704c5b1c12', '792592a4-b105-53d8-a093-32f4e9ebac4a', 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Imaš li brata ili sestru?', '["Ukrajinski, poljski i malo njemački.", "Danas je srijeda.", "Imam jednu sestru. Ona živi u Kijevu."]'::jsonb, 2, null, 'Imaš li brata ili sestru?', null, null, 'Діалог «Про родину»: «Imaš li brata ili sestru?» (У тебе є брат чи сестра?) — «Imam jednu sestru. Ona živi u Kijevu.» (У мене одна сестра. Вона живе в Києві.).', (select id from public.lessons where id = 'f9ca38e4-3a61-56a6-b5f5-060933516c9a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('a01ea0fc-e3cf-5499-9f07-96bc44da5650', '792592a4-b105-53d8-a093-32f4e9ebac4a', 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Imaš li djecu?', '["Ja sam profesorica. Radim u školi.", "Da, imam sina i kćer.", "Devedeset eura."]'::jsonb, 1, null, 'Imaš li djecu?', null, null, 'Діалог «У парку»: «Imaš li djecu?» (У тебе є діти?) — «Da, imam sina i kćer.» (Так, у мене син і донька.).', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v1'),
  ('255a94ef-e748-5253-8eb3-63d265688dcf', '792592a4-b105-53d8-a093-32f4e9ebac4a', 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Tko je ovo?', '["Це моя дружина Ольга.", "У нас один син. Його звати Максим.", "Приємно познайомитися! У вас є діти?"]'::jsonb, 0, null, null, 'Petra: Tko je ovo?
Andrij: Ovo je moja žena Olga.
Petra: Drago mi je! Imate li djecu?
Olga: Imamo jednog sina. Zove se Maksim.
Petra: Koliko ima godina?
Olga: Četiri.', 'Petra: Хто це?
Andrij: Це моя дружина Ольга.
Petra: Приємно познайомитися! У вас є діти?
Olga: У нас один син. Його звати Максим.
Petra: Скільки йому років?
Olga: Чотири.', 'Діалог «На дні народження»: «Tko je ovo?» — «Ovo je moja žena Olga.», тобто «Це моя дружина Ольга.».', (select id from public.lessons where id = 'f9ca38e4-3a61-56a6-b5f5-060933516c9a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('c3149ce9-164f-5b15-a07a-f71e1ebf849f', '792592a4-b105-53d8-a093-32f4e9ebac4a', 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «У мене син і донька». Що ви скажете?', null, '["Imate li djecu?", "Imam sina i kćer.", "Kako se zove?"]'::jsonb, 1, null, null, null, null, '«У мене син і донька.» — «Imam sina i kćer.».', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v1'),
  ('4db3431d-d930-55d5-9e15-7d92fef7b425', '792592a4-b105-53d8-a093-32f4e9ebac4a', 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «син»', null, '[]'::jsonb, null, 'sin', null, null, null, '«син» — sin.', (select id from public.lessons where id = 'f9ca38e4-3a61-56a6-b5f5-060933516c9a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('ffee87b9-dcc6-5e1b-82a2-574a4084dd40', '792592a4-b105-53d8-a093-32f4e9ebac4a', 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «У нас один син.»', null, '["Imamo", "sina.", "jednog"]'::jsonb, null, 'Imamo jednog sina.', null, null, null, '«У нас один син.» — «Imamo jednog sina.».', (select id from public.lessons where id = 'f9ca38e4-3a61-56a6-b5f5-060933516c9a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('90d604c9-2fb0-5449-82de-c5affcc9333f', '792592a4-b105-53d8-a093-32f4e9ebac4a', 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Це моя родина.»', null, '[]'::jsonb, null, 'Ovo je moja obitelj.', null, null, null, '«Це моя родина.» — «Ovo je moja obitelj.».', (select id from public.lessons where id = '4e003796-1ce0-5a02-8a2d-59a0de38f3dd'), 'PUBLISHED', 'claude_assessment_v1')
on conflict (id) do nothing;

-- Перевірка середини рівня A0
insert into public.assessments (id, slug, kind, title_ua, cefr, module_id, order_index, pass_ratio, area_min_ratio, estimated_minutes, description_ua, status, source)
values ('259321ff-474d-50cd-bab0-55e51dbb9ae7', 'a0-mid', 'mid', 'Перевірка середини рівня A0', 'A0', null, 50, 0.70, 0.50, 10, 'Середина рівня (модулі 1–5): 20 завдань на 4 навички. ~10 хв.', 'PUBLISHED', 'claude_assessment_v1')
on conflict (slug) do nothing;
insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options, correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('1bf9514e-3690-5c65-ada9-509ead5172a5', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["П’ятниця підходить. Дякую!", "Пів на восьму.", "Добре, побачимося в п’ятницю."]'::jsonb, 0, null, 'Petak je dobro. Hvala!', null, null, 'Прозвучало: «Petak je dobro. Hvala!» — «П’ятниця підходить. Дякую!».', (select id from public.lessons where id = '8e372ece-ae10-50ae-9cf3-07b52ef2f72d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('f4f62531-3348-58b4-bd77-b6e9b55474e2', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Нічого страшного. Сідайте.", "Одну каву, будь ласка.", "Дякую, і тобі. Передавай привіт родині!"]'::jsonb, 0, null, 'Nema problema. Sjednite.', null, null, 'Прозвучало: «Nema problema. Sjednite.» — «Нічого страшного. Сідайте.».', (select id from public.lessons where id = 'e704760a-f743-5762-9c1a-027b10ca030a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('fe47612a-0848-5c97-b884-eb0d77aae88d', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 3, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Добрий вечір! Скільки вас?", "Скільки хвилин до центру?", "Який ваш номер телефону?"]'::jsonb, 2, null, 'Koji je Vaš broj telefona?', null, null, 'Прозвучало: «Koji je Vaš broj telefona?» — «Який ваш номер телефону?».', (select id from public.lessons where id = 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('55b28fe9-d52e-5333-b0a5-46edada0d2a6', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 4, 'A0', 'reading', 'understand', 'multiple_choice', 'О котрій пошта відчиняється в понеділок?', 'Radno vrijeme pošte', '["О 7", "О 13", "О 8"]'::jsonb, 0, null, null, 'POŠTA
Radno vrijeme:
ponedjeljak – petak: 7 – 19 h
subota: 8 – 13 h
nedjelja: zatvoreno', 'ПОШТА
Години роботи:
понеділок – п’ятниця: 7–19
субота: 8–13
неділя: зачинено', 'Текст «Години роботи пошти». Правильна відповідь: «О 7».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('96658a3e-15dc-59d3-92dd-0f77ebbdca64', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 5, 'A0', 'reading', 'understand', 'multiple_choice', 'Яке свято?', 'Čestitka za rođendan', '["Великдень", "День народження", "Новий рік"]'::jsonb, 1, null, null, 'Draga mama,
sretan rođendan!
Volimo te puno.
Tvoji Ana i Marko', 'Люба мамо,
з днем народження!
Ми тебе дуже любимо.
Твої Ана і Марко', 'Текст «Листівка на день народження». Правильна відповідь: «День народження».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('e8fa4cdf-f711-5729-9587-dd6385bea4b6', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 6, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koliko imaju godina?', '["Bok, Ivane! Zovem se Maja.", "Deset i dvanaest.", "U siječnju. Volim zimu!"]'::jsonb, 1, null, 'Koliko imaju godina?', null, null, 'Діалог «Про родину»: «Koliko imaju godina?» (Скільки їм років?) — «Deset i dvanaest.» (Десять і дванадцять.).', (select id from public.lessons where id = 'f9ca38e4-3a61-56a6-b5f5-060933516c9a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('99606576-f9c0-58d2-865c-eb9b852905d7', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 7, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koliko minuta do centra?', '["Piletina s rižom i salatom.", "Otprilike petnaest minuta.", "Tramvajem, autom je gužva. Stanica je na raskrižju."]'::jsonb, 1, null, 'Koliko minuta do centra?', null, null, 'Діалог «Який автобус?»: «Koliko minuta do centra?» (Скільки хвилин до центру?) — «Otprilike petnaest minuta.» (Приблизно п’ятнадцять хвилин.).', (select id from public.lessons where id = 'e30c65f2-1a30-5b51-85e7-6a460cd1799f'), 'PUBLISHED', 'claude_assessment_v1'),
  ('4415e4e1-b2bc-5bd5-911f-5fb565c7e057', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 8, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Oprostite, koliko je sati?', '["Deset sati.", "U park! A onda u knjižnicu.", "Čaj, molim. Šalicu toplog čaja."]'::jsonb, 0, null, 'Oprostite, koliko je sati?', null, null, 'Діалог «На зупинці»: «Oprostite, koliko je sati?» (Вибачте, котра година?) — «Deset sati.» (Десята.).', (select id from public.lessons where id = '39b1e31f-b573-5000-9713-1660688c3cc9'), 'PUBLISHED', 'claude_assessment_v1'),
  ('352e4f3c-f523-561b-9308-422b51e638bd', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 9, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Ne razumijem dobro hrvatski. Možete li govoriti polako?', '["Naravno. Dobro došli u Zagreb!", "Ja sam iz Splita, ali živim u Zagrebu.", "Na stolu."]'::jsonb, 0, null, 'Ne razumijem dobro hrvatski. Možete li govoriti polako?', null, null, 'Діалог «Турист у Загребі»: «Ne razumijem dobro hrvatski. Možete li govoriti polako?» (Я погано розумію хорватську. Можете говорити повільно?) — «Naravno. Dobro došli u Zagreb!» (Звісно. Ласкаво просимо до Загреба!).', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('07c30c17-7948-55a8-a66f-108c1fa931d4', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 10, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koji je kućni broj?', '["Dvadeset dva, treći kat.", "Ja sam oženjen i imam unuka!", "Jako slatke! Probajte."]'::jsonb, 0, null, 'Koji je kućni broj?', null, null, 'Діалог «Яка ваша адреса?»: «Koji je kućni broj?» (Який номер будинку?) — «Dvadeset dva, treći kat.» (Двадцять два, третій поверх.).', (select id from public.lessons where id = 'adf335ee-0cba-5c9a-b86a-8baac868edbc'), 'PUBLISHED', 'claude_assessment_v1'),
  ('06a490b2-1ef3-5b1c-a753-808ccfc37b49', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 11, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Koji je danas dan?', '["А завтра?", "Завтра четвер. У п’ятницю їдемо на море!", "Сьогодні середа."]'::jsonb, 2, null, null, 'Marko: Koji je danas dan?
Ana: Danas je srijeda.
Marko: A sutra?
Ana: Sutra je četvrtak. U petak idemo na more!', 'Marko: Який сьогодні день?
Ana: Сьогодні середа.
Marko: А завтра?
Ana: Завтра четвер. У п’ятницю їдемо на море!', 'Діалог «Плани на тиждень»: «Koji je danas dan?» — «Danas je srijeda.», тобто «Сьогодні середа.».', (select id from public.lessons where id = '8e372ece-ae10-50ae-9cf3-07b52ef2f72d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('3621dc81-9396-5ca5-a671-61af2e20bcac', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 12, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dobro, hvala. A Vi?', '["Не дуже добре. Я втомлена.", "Мені шкода.", "Дякую. До побачення!"]'::jsonb, 0, null, null, 'Ivana: Dobar dan, gospodine Petrenko! Kako ste?
Petrenko: Dobro, hvala. A Vi?
Ivana: Ne baš dobro. Umorna sam.
Petrenko: Žao mi je.
Ivana: Hvala. Doviđenja!', 'Ivana: Добрий день, пане Петренко! Як ви?
Petrenko: Добре, дякую. А ви?
Ivana: Не дуже добре. Я втомлена.
Petrenko: Мені шкода.
Ivana: Дякую. До побачення!', 'Діалог «У сусідки»: «Dobro, hvala. A Vi?» — «Ne baš dobro. Umorna sam.», тобто «Не дуже добре. Я втомлена.».', (select id from public.lessons where id = 'c0000000-0000-0000-0000-000000000001'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e6c12e14-c689-5ee2-a76f-22c1cd245543', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 13, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Imaš li djecu?', '["Скільки їм років?", "Так, у мене син і донька.", "Синові п’ять, а доньці вісім років."]'::jsonb, 1, null, null, 'Ivan: Imaš li djecu?
Petra: Da, imam sina i kćer.
Ivan: Koliko su stari?
Petra: Sin ima pet, a kći osam godina.', 'Ivan: У тебе є діти?
Petra: Так, у мене син і донька.
Ivan: Скільки їм років?
Petra: Синові п’ять, а доньці вісім років.', 'Діалог «У парку»: «Imaš li djecu?» — «Da, imam sina i kćer.», тобто «Так, у мене син і донька.».', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v1'),
  ('4bcfab0f-1c18-58a6-9826-27fa854e1d8e', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 14, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я програміст». Що ви скажете?', null, '["Ja sam programer.", "Zovem se Oleg.", "Živim na drugom katu."]'::jsonb, 0, null, null, null, null, '«Я програміст.» — «Ja sam programer.».', (select id from public.lessons where id = '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('c396903a-d81f-5716-abcc-5f41196f83c9', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 15, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Можете повторити?». Що ви скажете?', null, '["Žao mi je.", "Možete li ponoviti?", "Možete li govoriti polako?"]'::jsonb, 1, null, null, null, null, '«Можете повторити?» — «Možete li ponoviti?».', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('cd849bb4-dc2d-5e21-8566-0de6eac245ed', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 16, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «тиждень»', null, '[]'::jsonb, null, 'tjedan', null, null, null, '«тиждень» — tjedan.', (select id from public.lessons where id = '238d9508-3c2e-5ee6-910f-0ae8863c2dc7'), 'PUBLISHED', 'claude_assessment_v1'),
  ('35a2c0b5-b96f-50d1-b353-65549558c6a0', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 17, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «нуль»', null, '[]'::jsonb, null, 'nula', null, null, null, '«нуль» — nula.', (select id from public.lessons where id = 'c0941bd8-57b5-5e7e-981f-9be423f24208'), 'PUBLISHED', 'claude_assessment_v1'),
  ('f8e2bc2c-36a7-53d5-9c58-bef328acc926', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 18, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Коли в тебе день народження?»', null, '["ti", "Kada", "je", "rođendan?"]'::jsonb, null, 'Kada ti je rođendan?', null, null, null, '«Коли в тебе день народження?» — «Kada ti je rođendan?».', (select id from public.lessons where id = 'b36b4550-ff36-50cb-89fb-8246b351c8d6'), 'PUBLISHED', 'claude_assessment_v1'),
  ('9f5692ed-8b28-5bf6-8c07-f9d3a3a1aac2', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 19, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Скільки тобі років?»', null, '["imaš", "godina?", "Koliko"]'::jsonb, null, 'Koliko imaš godina?', null, null, null, '«Скільки тобі років?» — «Koliko imaš godina?».', (select id from public.lessons where id = '4c5db9c0-aa58-55c5-b647-7f7cfc8396c2'), 'PUBLISHED', 'claude_assessment_v1'),
  ('f7182690-d53c-597a-8a39-579b0f3b6f71', '259321ff-474d-50cd-bab0-55e51dbb9ae7', 20, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Привіт! Як справи?»', null, '[]'::jsonb, null, 'Bok! Kako si?', null, null, null, '«Привіт! Як справи?» — «Bok! Kako si?».', (select id from public.lessons where id = 'c0000000-0000-0000-0000-000000000001'), 'PUBLISHED', 'claude_assessment_v1')
on conflict (id) do nothing;

-- Перевірка модуля A0.6 · Модуль A0.6 — Moj dom (мій дім)
insert into public.assessments (id, slug, kind, title_ua, cefr, module_id, order_index, pass_ratio, area_min_ratio, estimated_minutes, description_ua, status, source)
values ('42a4bbc9-186a-586d-ab42-fa6916e79e67', 'a0-m06', 'module', 'Перевірка модуля A0.6', 'A0', (select id from public.modules where level_code = 'A0' and order_index = 6), 6, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.', 'PUBLISHED', 'claude_assessment_v1')
on conflict (slug) do nothing;
insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options, correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('20e799db-7686-5825-bcbd-8fd33df4c154', '42a4bbc9-186a-586d-ab42-fa6916e79e67', 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Може, вони в сумці або під ліжком.", "У нашого будинку є сад і подвір’я.", "Ліжко, стіл, стілець і шафа."]'::jsonb, 1, null, 'Naša kuća ima vrt i dvorište.', null, null, 'Прозвучало: «Naša kuća ima vrt i dvorište.» — «У нашого будинку є сад і подвір’я.».', (select id from public.lessons where id = 'e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9'), 'PUBLISHED', 'claude_assessment_v1'),
  ('1a6f9f00-b1d3-5b2b-8565-192f9c04027d', '42a4bbc9-186a-586d-ab42-fa6916e79e67', 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Кухня ліворуч, а ванна праворуч.", "П’ятсот євро на місяць.", "Це вітальня."]'::jsonb, 2, null, 'Ovo je dnevni boravak.', null, null, 'Прозвучало: «Ovo je dnevni boravak.» — «Це вітальня.».', (select id from public.lessons where id = '78f28f85-dd8b-5e81-8a52-1b2dbce4eb34'), 'PUBLISHED', 'claude_assessment_v1'),
  ('3964ec76-462f-5030-a7f4-0b9db72c9d5a', '42a4bbc9-186a-586d-ab42-fa6916e79e67', 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Де пароль від Wi-Fi?', 'Poruka u apartmanu', '["На холодильнику", "Біля дверей", "На столі"]'::jsonb, 0, null, null, 'Dobro došli!
Ključ je na stolu.
Lozinka za Wi-Fi je na hladnjaku.
Kupaonica je lijevo, kuhinja je desno.
Ugodan boravak!', 'Ласкаво просимо!
Ключ — на столі.
Пароль від Wi-Fi — на холодильнику.
Ванна кімната ліворуч, кухня праворуч.
Приємного перебування!', 'Текст «Записка в апартаментах». Правильна відповідь: «На холодильнику».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('f78e1d81-b680-5211-9fa3-301b7ae22b78', '42a4bbc9-186a-586d-ab42-fa6916e79e67', 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje je moja soba?', '["Dva eura.", "Dobro! Imam novog prijatelja.", "Gore, na katu, pored velikog ogledala."]'::jsonb, 2, null, 'Gdje je moja soba?', null, null, 'Діалог «Будинок із садом»: «Gdje je moja soba?» (Де моя кімната?) — «Gore, na katu, pored velikog ogledala.» (Нагорі, на поверсі, біля великого дзеркала.).', (select id from public.lessons where id = 'e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9'), 'PUBLISHED', 'claude_assessment_v1'),
  ('5a677b51-99f3-559c-99b8-4073a2d434e2', '42a4bbc9-186a-586d-ab42-fa6916e79e67', 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koliko soba ima stan?', '["Idite ravno do semafora, pa skrenite desno.", "Zelenu ili žutu.", "Dvije sobe."]'::jsonb, 2, null, 'Koliko soba ima stan?', null, null, 'Діалог «Огляд квартири»: «Koliko soba ima stan?» (Скільки кімнат у квартирі?) — «Dvije sobe.» (Дві кімнати.).', (select id from public.lessons where id = '78f28f85-dd8b-5e81-8a52-1b2dbce4eb34'), 'PUBLISHED', 'claude_assessment_v1'),
  ('5465221c-60be-5640-ae4f-7f6395bcab2e', '42a4bbc9-186a-586d-ab42-fa6916e79e67', 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Trebate li pomoć?', '["Цей стіл дерев’яний.", "Так. Шукаю стіл і чотири стільці.", "Триста євро."]'::jsonb, 1, null, null, 'Prodavač: Trebate li pomoć?
Kupac: Da. Tražim stol i četiri stolice.
Prodavač: Ovaj stol je od drva.
Kupac: Lijep je. Koliko košta?
Prodavač: Tristo eura.', 'Prodavač: Вам допомогти?
Kupac: Так. Шукаю стіл і чотири стільці.
Prodavač: Цей стіл дерев’яний.
Kupac: Гарний. Скільки коштує?
Prodavač: Триста євро.', 'Діалог «У меблевому магазині»: «Trebate li pomoć?» — «Da. Tražim stol i četiri stolice.», тобто «Так. Шукаю стіл і чотири стільці.».', (select id from public.lessons where id = '1436c20e-0aea-550a-b66d-fb3149a1c2e2'), 'PUBLISHED', 'claude_assessment_v1'),
  ('078b3b7f-b8c3-52b3-8243-f09279cb265d', '42a4bbc9-186a-586d-ab42-fa6916e79e67', 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Де кухня?». Що ви скажете?', null, '["Evo ih!", "Gdje je kuhinja?", "Nemam pećnice."]'::jsonb, 1, null, null, null, null, '«Де кухня?» — «Gdje je kuhinja?».', (select id from public.lessons where id = '78f28f85-dd8b-5e81-8a52-1b2dbce4eb34'), 'PUBLISHED', 'claude_assessment_v1'),
  ('66179c69-20ca-5c56-8329-b60fdc9b00eb', '42a4bbc9-186a-586d-ab42-fa6916e79e67', 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «килим»', null, '[]'::jsonb, null, 'tepih', null, null, null, '«килим» — tepih.', (select id from public.lessons where id = '1436c20e-0aea-550a-b66d-fb3149a1c2e2'), 'PUBLISHED', 'claude_assessment_v1'),
  ('7a83208a-2ce0-5228-a17c-bb738a7e12e3', '42a4bbc9-186a-586d-ab42-fa6916e79e67', 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «А де туалет?»', null, '["gdje", "je", "zahod?", "A"]'::jsonb, null, 'A gdje je zahod?', null, null, null, '«А де туалет?» — «A gdje je zahod?».', (select id from public.lessons where id = 'e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9'), 'PUBLISHED', 'claude_assessment_v1'),
  ('2eb98557-8b2a-517c-b9f1-be61cd60f4c8', '42a4bbc9-186a-586d-ab42-fa6916e79e67', 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Де мої ключі?»', null, '[]'::jsonb, null, 'Gdje su moji ključevi?', null, null, null, '«Де мої ключі?» — «Gdje su moji ključevi?».', (select id from public.lessons where id = '0ecb6f19-2630-533d-9f1b-85102442af08'), 'PUBLISHED', 'claude_assessment_v1')
on conflict (id) do nothing;

-- Перевірка модуля A0.7 · Модуль A0.7 — Hrana (їжа)
insert into public.assessments (id, slug, kind, title_ua, cefr, module_id, order_index, pass_ratio, area_min_ratio, estimated_minutes, description_ua, status, source)
values ('042c7f06-a438-5205-835e-79778512b418', 'a0-m07', 'module', 'Перевірка модуля A0.7', 'A0', (select id from public.modules where level_code = 'A0' and order_index = 7), 7, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.', 'PUBLISHED', 'claude_assessment_v1')
on conflict (slug) do nothing;
insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options, correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('af54a43a-9711-5a67-9239-7a429fc3083f', '042c7f06-a438-5205-835e-79778512b418', 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Щиро дякую! До побачення!", "Сьогодні в нас смачний суп і паста.", "Дякую! М’ясо дуже смачне."]'::jsonb, 0, null, 'Hvala lijepa! Doviđenja!', null, null, 'Прозвучало: «Hvala lijepa! Doviđenja!» — «Щиро дякую! До побачення!».', (select id from public.lessons where id = '8b30911e-4e57-5648-9ff6-bd11c1b0e27e'), 'PUBLISHED', 'claude_assessment_v1'),
  ('db53227f-06d0-58c7-a3bf-1c5f25fd7d57', '042c7f06-a438-5205-835e-79778512b418', 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Можна заплатити карткою?", "Знову курятина? А картопля фрі є?", "Мамо, що на вечерю?"]'::jsonb, 1, null, 'Opet piletina? Ima li pomfrita?', null, null, 'Прозвучало: «Opet piletina? Ima li pomfrita?» — «Знову курятина? А картопля фрі є?».', (select id from public.lessons where id = 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('9ff5b842-9811-5544-a2e6-d8d47853d20f', '042c7f06-a438-5205-835e-79778512b418', 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Скільки коштує чай?', 'Cjenik kafića', '["2,50 €", "1,50 €", "1,80 €"]'::jsonb, 1, null, null, 'CJENIK
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
  ('da908dd0-91ae-5ba4-852f-2bfb6306b81c', '042c7f06-a438-5205-835e-79778512b418', 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Mama, što je za večeru?', '["Ja sam oženjen i imam unuka!", "Piletina s rižom i salatom.", "Ja sam medicinska sestra."]'::jsonb, 1, null, 'Mama, što je za večeru?', null, null, 'Діалог «Що на вечерю?»: «Mama, što je za večeru?» (Мамо, що на вечерю?) — «Piletina s rižom i salatom.» (Курятина з рисом і салатом.).', (select id from public.lessons where id = 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('bb121dea-ac98-525b-bfbb-33c1eef4bca5', '042c7f06-a438-5205-835e-79778512b418', 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Želiš li čaj ili kavu?', '["U kolovozu. Idem na more.", "Izgubio sam se. Tražim hotel Central.", "Čaj, molim. Šalicu toplog čaja."]'::jsonb, 2, null, 'Želiš li čaj ili kavu?', null, null, 'Діалог «Чай чи кава?»: «Želiš li čaj ili kavu?» (Хочеш чаю чи кави?) — «Čaj, molim. Šalicu toplog čaja.» (Чай, будь ласка. Чашку гарячого чаю.).', (select id from public.lessons where id = '77d640c4-4190-544a-8094-4e699f9a0a10'), 'PUBLISHED', 'claude_assessment_v1'),
  ('9b721c72-8968-580f-a0eb-891da9e4d7e0', '042c7f06-a438-5205-835e-79778512b418', 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Ne, bez šećera. A ti?', '["З цукром?", "Чай, будь ласка. Чашку гарячого чаю.", "Я п’ю лимонад з льодом."]'::jsonb, 2, null, null, 'Ana: Želiš li čaj ili kavu?
Iryna: Čaj, molim. Šalicu toplog čaja.
Ana: Sa šećerom?
Iryna: Ne, bez šećera. A ti?
Ana: Ja pijem limunadu s ledom.', 'Ana: Хочеш чаю чи кави?
Iryna: Чай, будь ласка. Чашку гарячого чаю.
Ana: З цукром?
Iryna: Ні, без цукру. А ти?
Ana: Я п’ю лимонад з льодом.', 'Діалог «Чай чи кава?»: «Ne, bez šećera. A ti?» — «Ja pijem limunadu s ledom.», тобто «Я п’ю лимонад з льодом.».', (select id from public.lessons where id = '77d640c4-4190-544a-8094-4e699f9a0a10'), 'PUBLISHED', 'claude_assessment_v1'),
  ('bb42ae63-5fce-5a5d-ba22-0072ff7ff10a', '042c7f06-a438-5205-835e-79778512b418', 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Можна заплатити карткою?». Що ви скажете?', null, '["Čašu vode, molim.", "Mogu li platiti karticom?", "Kavu s mlijekom, molim."]'::jsonb, 1, null, null, null, null, '«Можна заплатити карткою?» — «Mogu li platiti karticom?».', (select id from public.lessons where id = '8b30911e-4e57-5648-9ff6-bd11c1b0e27e'), 'PUBLISHED', 'claude_assessment_v1'),
  ('347f4ec7-cd9f-515a-a75f-51adb3dfb0be', '042c7f06-a438-5205-835e-79778512b418', 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «макарони; паста»', null, '[]'::jsonb, null, 'tjestenina', null, null, null, '«макарони; паста» — tjestenina.', (select id from public.lessons where id = 'c9e045fb-91ff-52a2-9916-1b698d30eb19'), 'PUBLISHED', 'claude_assessment_v1'),
  ('0afaf007-2845-536b-a8dc-c8bebe98de00', '042c7f06-a438-5205-835e-79778512b418', 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Ні, без цукру.»', null, '["bez", "šećera.", "Ne,"]'::jsonb, null, 'Ne, bez šećera.', null, null, null, '«Ні, без цукру.» — «Ne, bez šećera.».', (select id from public.lessons where id = '77d640c4-4190-544a-8094-4e699f9a0a10'), 'PUBLISHED', 'claude_assessment_v1'),
  ('20b23194-c073-5195-8314-093b859b71d2', '042c7f06-a438-5205-835e-79778512b418', 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Це дуже смачно!»', null, '[]'::jsonb, null, 'Ovo je jako ukusno!', null, null, null, '«Це дуже смачно!» — «Ovo je jako ukusno!».', (select id from public.lessons where id = 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d'), 'PUBLISHED', 'claude_assessment_v1')
on conflict (id) do nothing;

-- Перевірка модуля A0.8 · Модуль A0.8 — Kupovina (покупки)
insert into public.assessments (id, slug, kind, title_ua, cefr, module_id, order_index, pass_ratio, area_min_ratio, estimated_minutes, description_ua, status, source)
values ('79a86c1a-a125-519e-bc8b-9d80439c95da', 'a0-m08', 'module', 'Перевірка модуля A0.8', 'A0', (select id from public.modules where level_code = 'A0' and order_index = 8), 8, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.', 'PUBLISHED', 'claude_assessment_v1')
on conflict (slug) do nothing;
insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options, correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('53123a8c-56f1-5bba-9e12-36e54cc1a43f', '79a86c1a-a125-519e-bc8b-9d80439c95da', 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Ні, досить, дякую.", "Ні, це все.", "Вона зі знижкою, десять євро."]'::jsonb, 1, null, 'Ne, to je sve.', null, null, 'Прозвучало: «Ne, to je sve.» — «Ні, це все.».', (select id from public.lessons where id = 'e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0'), 'PUBLISHED', 'claude_assessment_v1'),
  ('6dfdfd61-05b1-56d5-ba48-2a47b350a934', '79a86c1a-a125-519e-bc8b-9d80439c95da', 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Чорної немає. Є сіра й коричнева.", "Одну хлібину. І багато фруктів для дітей!", "Звісно, примірочна ліворуч."]'::jsonb, 0, null, 'Nemamo crnu. Imamo sivu i smeđu.', null, null, 'Прозвучало: «Nemamo crnu. Imamo sivu i smeđu.» — «Чорної немає. Є сіра й коричнева.».', (select id from public.lessons where id = '288e7610-99c8-5696-989a-86f60ce38b0a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('37d18a01-cf49-52f6-a96c-bb114040a18a', '79a86c1a-a125-519e-bc8b-9d80439c95da', 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Скільки коштує пакет?', 'Na blagajni u supermarketu', '["Безкоштовно", "1 €", "0,10 €"]'::jsonb, 2, null, null, 'BLAGAJNA 3
Samo kartice
AKCIJA: –20 %
Vrećica 0,10 €
Hvala na kupnji!', 'КАСА 3
Тільки картки
АКЦІЯ: –20 %
Пакет 0,10 €
Дякуємо за покупку!', 'Текст «На касі в супермаркеті». Правильна відповідь: «0,10 €».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('f7ccbe52-16bd-53ec-8c8d-729cedc56e12', '79a86c1a-a125-519e-bc8b-9d80439c95da', 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Može malo više?', '["U park! A onda u knjižnicu.", "Idite ravno do semafora, pa skrenite desno.", "Može. I pola kile šunke."]'::jsonb, 2, null, 'Može malo više?', null, null, 'Діалог «За прилавком»: «Može malo više?» (Можна трохи більше?) — «Može. I pola kile šunke.» (Можна. І півкіло шинки.).', (select id from public.lessons where id = '0e925295-2766-5931-b031-2412682bc6f8'), 'PUBLISHED', 'claude_assessment_v1'),
  ('1083591a-6c48-59f9-b447-ce91d6beeccd', '79a86c1a-a125-519e-bc8b-9d80439c95da', 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koju boju želite?', '["Moj prijatelj je pao. Boli ga noga.", "Dvadeset dva, treći kat.", "Zelenu ili žutu."]'::jsonb, 2, null, 'Koju boju želite?', null, null, 'Діалог «Яку сукню?»: «Koju boju želite?» (Який колір бажаєте?) — «Zelenu ili žutu.» (Зелену або жовту.).', (select id from public.lessons where id = '288e7610-99c8-5696-989a-86f60ce38b0a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('a1502327-21a6-5fbe-8b42-32c72b051932', '79a86c1a-a125-519e-bc8b-9d80439c95da', 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Koliko košta ova majica?', '["Візьму синю.", "Вона зі знижкою, десять євро.", "Ця футболка коштує двадцять євро."]'::jsonb, 2, null, null, 'Kupac: Koliko košta ova majica?
Prodavač: Ta majica košta dvadeset eura.
Kupac: A ona plava?
Prodavač: Ona je na popustu, deset eura.
Kupac: Uzet ću plavu.', 'Kupac: Скільки коштує ця футболка?
Prodavač: Ця футболка коштує двадцять євро.
Kupac: А он та синя?
Prodavač: Вона зі знижкою, десять євро.
Kupac: Візьму синю.', 'Діалог «У магазині одягу»: «Koliko košta ova majica?» — «Ta majica košta dvadeset eura.», тобто «Ця футболка коштує двадцять євро.».', (select id from public.lessons where id = 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0'), 'PUBLISHED', 'claude_assessment_v1'),
  ('eb998827-401b-5d99-8f6f-4f0de41e0771', '79a86c1a-a125-519e-bc8b-9d80439c95da', 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Трохи більше, будь ласка». Що ви скажете?', null, '["Malo više, molim.", "Ne, to je sve.", "Moja omiljena boja je plava."]'::jsonb, 0, null, null, null, null, '«Трохи більше, будь ласка.» — «Malo više, molim.».', (select id from public.lessons where id = '0e925295-2766-5931-b031-2412682bc6f8'), 'PUBLISHED', 'claude_assessment_v1'),
  ('c6cca64d-a802-5cfe-b756-f1efd7eb2f62', '79a86c1a-a125-519e-bc8b-9d80439c95da', 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «червоний»', null, '[]'::jsonb, null, 'crven', null, null, null, '«червоний» — crven.', (select id from public.lessons where id = 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b9c7a44a-deda-5bb0-b21e-f3eff1644b90', '79a86c1a-a125-519e-bc8b-9d80439c95da', 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «На жаль, картка не проходить.»', null, '["prolazi.", "Nažalost,", "ne", "kartica"]'::jsonb, null, 'Nažalost, kartica ne prolazi.', null, null, null, '«На жаль, картка не проходить.» — «Nažalost, kartica ne prolazi.».', (select id from public.lessons where id = '28913ad6-490f-5d89-bad7-9b303c673fcd'), 'PUBLISHED', 'claude_assessment_v1'),
  ('4cf21d4b-abb3-5ba8-a707-cc313fecc077', '79a86c1a-a125-519e-bc8b-9d80439c95da', 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Скільки коштує ця футболка?»', null, '[]'::jsonb, null, 'Koliko košta ova majica?', null, null, null, '«Скільки коштує ця футболка?» — «Koliko košta ova majica?».', (select id from public.lessons where id = 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0'), 'PUBLISHED', 'claude_assessment_v1')
on conflict (id) do nothing;

-- Перевірка модуля A0.9 · Модуль A0.9 — Grad (місто)
insert into public.assessments (id, slug, kind, title_ua, cefr, module_id, order_index, pass_ratio, area_min_ratio, estimated_minutes, description_ua, status, source)
values ('440f11e8-d7bb-520f-a00e-5f709d93b280', 'a0-m09', 'module', 'Перевірка модуля A0.9', 'A0', (select id from public.modules where level_code = 'A0' and order_index = 9), 9, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.', 'PUBLISHED', 'claude_assessment_v1')
on conflict (slug) do nothing;
insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options, correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('d1993ad6-480e-5737-9546-403418582f46', '440f11e8-d7bb-520f-a00e-5f709d93b280', 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Ні. Перейдіть міст — і ви там.", "Так, біля пошти, а пошта навпроти банку.", "Супер. Ходімо в музей!"]'::jsonb, 1, null, 'Jest, pored pošte, a pošta je preko puta banke.', null, null, 'Прозвучало: «Jest, pored pošte, a pošta je preko puta banke.» — «Так, біля пошти, а пошта навпроти банку.».', (select id from public.lessons where id = '0addd5be-230b-582f-baed-a5d18eb1d619'), 'PUBLISHED', 'claude_assessment_v1'),
  ('87376adb-1eea-5083-b53a-56caba25552c', '440f11e8-d7bb-520f-a00e-5f709d93b280', 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["В один бік чи туди й назад?", "Вибачте, який автобус їде до центру?", "Де пішохідний перехід?"]'::jsonb, 1, null, 'Oprostite, koji autobus ide do centra?', null, null, 'Прозвучало: «Oprostite, koji autobus ide do centra?» — «Вибачте, який автобус їде до центру?».', (select id from public.lessons where id = 'e0b9d742-0418-597b-9482-b6e2d82469da'), 'PUBLISHED', 'claude_assessment_v1'),
  ('ff158381-5a00-5a56-85f2-64987e33fa3b', '440f11e8-d7bb-520f-a00e-5f709d93b280', 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Куди йти до лікарні?', 'Putokaz u gradu', '["Прямо", "Ліворуч", "Праворуч"]'::jsonb, 0, null, null, 'Centar 1 km →
Kolodvor 500 m ←
Bolnica 2 km ↑
Muzej ←
Ljekarna 100 m →', 'Центр 1 км →
Вокзал 500 м ←
Лікарня 2 км ↑
Музей ←
Аптека 100 м →', 'Текст «Дороговказ у місті». Правильна відповідь: «Прямо».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('a4d57103-2f77-56b6-ad92-2881c0283c63', '440f11e8-d7bb-520f-a00e-5f709d93b280', 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'U jednom smjeru. Kada ide autobus?', '["Izgubio sam se. Tražim hotel Central.", "U devet sati, s perona tri.", "Ukrajinski, poljski i malo njemački."]'::jsonb, 1, null, 'U jednom smjeru. Kada ide autobus?', null, null, 'Діалог «На автовокзалі»: «U jednom smjeru. Kada ide autobus?» (В один бік. Коли їде автобус?) — «U devet sati, s perona tri.» (О дев’ятій, з платформи три.).', (select id from public.lessons where id = 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('977902ef-aa9a-5855-8b38-56405cf81d34', '440f11e8-d7bb-520f-a00e-5f709d93b280', 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Idemo u park ili u kino?', '["Ovo je moja žena Olga.", "Tek tjedan dana.", "U park! A onda u knjižnicu."]'::jsonb, 2, null, 'Idemo u park ili u kino?', null, null, 'Діалог «Вихідні з дітьми»: «Idemo u park ili u kino?» (Підемо в парк чи в кіно?) — «U park! A onda u knjižnicu.» (У парк! А потім у бібліотеку.).', (select id from public.lessons where id = '0addd5be-230b-582f-baed-a5d18eb1d619'), 'PUBLISHED', 'claude_assessment_v1'),
  ('41664d36-149c-5e5a-8f21-0b450420c622', '440f11e8-d7bb-520f-a00e-5f709d93b280', 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Jako je lijep! Je li ova crkva stara?', '["Це старе місто.", "Супер. Ходімо в музей!", "Так, дуже стара. А он там — новий музей."]'::jsonb, 2, null, null, 'Ana: Ovo je stari grad.
Oleg: Jako je lijep! Je li ova crkva stara?
Ana: Da, jako stara. A ono je novi muzej.
Oleg: Super. Idemo u muzej!', 'Ana: Це старе місто.
Oleg: Дуже гарне! Ця церква стара?
Ana: Так, дуже стара. А он там — новий музей.
Oleg: Супер. Ходімо в музей!', 'Діалог «Прогулянка»: «Jako je lijep! Je li ova crkva stara?» — «Da, jako stara. A ono je novi muzej.», тобто «Так, дуже стара. А он там — новий музей.».', (select id from public.lessons where id = '1e0384e5-6097-56ed-ab56-cf530f02ab73'), 'PUBLISHED', 'claude_assessment_v1'),
  ('fc4859a3-aef3-5e2e-aaf7-4321c8716390', '440f11e8-d7bb-520f-a00e-5f709d93b280', 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Тут поруч є банк?». Що ви скажете?', null, '["Je li blizu neka banka?", "Kada ide autobus?", "Dvije ulaznice, molim."]'::jsonb, 0, null, null, null, null, '«Тут поруч є банк?» — «Je li blizu neka banka?».', (select id from public.lessons where id = '0addd5be-230b-582f-baed-a5d18eb1d619'), 'PUBLISHED', 'claude_assessment_v1'),
  ('bd5f3be5-489e-52cd-84b2-477c031975c8', '440f11e8-d7bb-520f-a00e-5f709d93b280', 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «годинник / година»', null, '[]'::jsonb, null, 'sat', null, null, null, '«годинник / година» — sat.', (select id from public.lessons where id = 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('35a83c94-eab3-5599-8781-103f9599c2d6', '440f11e8-d7bb-520f-a00e-5f709d93b280', 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Скільки триває поїздка?»', null, '["traje", "vožnja?", "Koliko"]'::jsonb, null, 'Koliko traje vožnja?', null, null, null, '«Скільки триває поїздка?» — «Koliko traje vožnja?».', (select id from public.lessons where id = 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('2f2b203a-8c38-53cb-b214-3cab47d93dde', '440f11e8-d7bb-520f-a00e-5f709d93b280', 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Ідіть прямо.»', null, '[]'::jsonb, null, 'Idite ravno.', null, null, null, '«Ідіть прямо.» — «Idite ravno.».', (select id from public.lessons where id = '55af257e-e4d1-51ed-9637-388a7e0b4baf'), 'PUBLISHED', 'claude_assessment_v1')
on conflict (id) do nothing;

-- Перевірка модуля A0.10 · Модуль A0.10 — Survival Croatian (виживання)
insert into public.assessments (id, slug, kind, title_ua, cefr, module_id, order_index, pass_ratio, area_min_ratio, estimated_minutes, description_ua, status, source)
values ('dac4709f-fcbc-5090-89e4-090a3872ff9e', 'a0-m10', 'module', 'Перевірка модуля A0.10', 'A0', (select id from public.modules where level_code = 'A0' and order_index = 10), 10, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.', 'PUBLISHED', 'claude_assessment_v1')
on conflict (slug) do nothing;
insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options, correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('fda4cd88-0fc9-55e4-bee9-e9d6c4383a03', 'dac4709f-fcbc-5090-89e4-090a3872ff9e', 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Добрий день. Ваше ім’я та прізвище?", "Є. На скільки ночей?", "У вас є паспорт?"]'::jsonb, 2, null, 'Imate li putovnicu?', null, null, 'Прозвучало: «Imate li putovnicu?» — «У вас є паспорт?».', (select id from public.lessons where id = 'b095637e-0644-507e-8f3d-d323483dd3e4'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e89fc2c4-026f-5d29-b174-469a2810fa69', 'dac4709f-fcbc-5090-89e4-090a3872ff9e', 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Є. На скільки ночей?", "Його немає в сумці?", "Прошу, чим можу допомогти?"]'::jsonb, 2, null, 'Izvolite, kako Vam mogu pomoći?', null, null, 'Прозвучало: «Izvolite, kako Vam mogu pomoći?» — «Прошу, чим можу допомогти?».', (select id from public.lessons where id = 'd2689a70-cb73-515f-9d81-6bb0f0fc1cff'), 'PUBLISHED', 'claude_assessment_v1'),
  ('32f444d6-d8dd-5287-921c-2a226b518f21', 'dac4709f-fcbc-5090-89e4-090a3872ff9e', 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Що означає «ZABRANJENO PUŠENJE»?', 'Zabrane i upozorenja', '["Місце для паління", "Палити заборонено", "Можна палити"]'::jsonb, 1, null, null, 'ZABRANJENO PUŠENJE
PAZI, PAS!
GURAJ
VUCI
NE NAGINJI SE KROZ PROZOR', 'ПАЛИТИ ЗАБОРОНЕНО
ОБЕРЕЖНО, СОБАКА!
ВІД СЕБЕ (штовхайте)
НА СЕБЕ (тягніть)
НЕ ВИХИЛЯЙТЕСЯ З ВІКНА', 'Текст «Заборони й попередження». Правильна відповідь: «Палити заборонено».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('c8222ed2-ab45-54cc-a7d6-90b7104b4248', 'dac4709f-fcbc-5090-89e4-090a3872ff9e', 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koliko dugo čekamo?', '["Oko sat vremena. Ja čekam od osam.", "Piletina s rižom i salatom.", "U stanu, u velikoj zgradi."]'::jsonb, 0, null, 'Koliko dugo čekamo?', null, null, 'Діалог «У черзі»: «Koliko dugo čekamo?» (Скільки ми чекаємо?) — «Oko sat vremena. Ja čekam od osam.» (Близько години. Я чекаю з восьмої.).', (select id from public.lessons where id = '19df3241-90f3-5450-94ac-642d79fb2869'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b089c956-3289-5abf-8a22-f2d20022c9fd', 'dac4709f-fcbc-5090-89e4-090a3872ff9e', 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Što se dogodilo?', '["Moj prijatelj je pao. Boli ga noga.", "U siječnju. Volim zimu!", "U kolovozu. Idem na more."]'::jsonb, 0, null, 'Što se dogodilo?', null, null, 'Діалог «На вулиці»: «Što se dogodilo?» (Що сталося?) — «Moj prijatelj je pao. Boli ga noga.» (Мій друг упав. У нього болить нога.).', (select id from public.lessons where id = 'fbc71f82-e715-5bab-a990-b8542fb0fe01'), 'PUBLISHED', 'claude_assessment_v1'),
  ('209cbe73-a3eb-5a03-84bf-1daa258016f4', 'dac4709f-fcbc-5090-89e4-090a3872ff9e', 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Imate li temperaturu?', '["У мене болить голова.", "Так, трохи.", "Ось рецепт. Пийте багато води."]'::jsonb, 1, null, null, 'Liječnica: Što Vas boli?
Pacijent: Boli me glava.
Liječnica: Imate li temperaturu?
Pacijent: Da, malo.
Liječnica: Izvolite recept. Pijte puno vode.', 'Liječnica: Що у вас болить?
Pacijent: У мене болить голова.
Liječnica: У вас є температура?
Pacijent: Так, трохи.
Liječnica: Ось рецепт. Пийте багато води.', 'Діалог «У лікаря»: «Imate li temperaturu?» — «Da, malo.», тобто «Так, трохи.».', (select id from public.lessons where id = 'fbc71f82-e715-5bab-a990-b8542fb0fe01'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b6806d8b-9180-5e45-b3a6-104bbd1008b1', 'dac4709f-fcbc-5090-89e4-090a3872ff9e', 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Можете мені допомогти?». Що ви скажете?', null, '["Možete li mi pomoći?", "Na kojem jeziku?", "Izgubio sam se."]'::jsonb, 0, null, null, null, null, '«Можете мені допомогти?» — «Možete li mi pomoći?».', (select id from public.lessons where id = 'edbae9ca-c4f4-575d-b876-d50b0a1fd9b5'), 'PUBLISHED', 'claude_assessment_v1'),
  ('5d47cec4-88c1-5e1f-ac5f-c7a15c2f8e34', 'dac4709f-fcbc-5090-89e4-090a3872ff9e', 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «шкіряний»', null, '[]'::jsonb, null, 'kožni', null, null, null, '«шкіряний» — kožni.', (select id from public.lessons where id = 'd2689a70-cb73-515f-9d81-6bb0f0fc1cff'), 'PUBLISHED', 'claude_assessment_v1'),
  ('808444e7-c34d-5fcc-a798-6862e77d20da', 'dac4709f-fcbc-5090-89e4-090a3872ff9e', 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Хочу про це заявити.»', null, '["to", "Želim", "prijaviti."]'::jsonb, null, 'Želim to prijaviti.', null, null, null, '«Хочу про це заявити.» — «Želim to prijaviti.».', (select id from public.lessons where id = 'd2689a70-cb73-515f-9d81-6bb0f0fc1cff'), 'PUBLISHED', 'claude_assessment_v1'),
  ('12903aa8-c206-5d71-89d8-a578c5840015', 'dac4709f-fcbc-5090-89e4-090a3872ff9e', 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Де черга?»', null, '[]'::jsonb, null, 'Gdje je red?', null, null, null, '«Де черга?» — «Gdje je red?».', (select id from public.lessons where id = '19df3241-90f3-5450-94ac-642d79fb2869'), 'PUBLISHED', 'claude_assessment_v1')
on conflict (id) do nothing;

-- Фінальна перевірка рівня A0
insert into public.assessments (id, slug, kind, title_ua, cefr, module_id, order_index, pass_ratio, area_min_ratio, estimated_minutes, description_ua, status, source)
values ('52bf1b71-7936-547c-9994-675c81e394e5', 'a0-final', 'final', 'Фінальна перевірка рівня A0', 'A0', null, 100, 0.70, 0.50, 15, 'Кінець рівня (усі 10 модулів): 30 завдань на 4 навички. ~15 хв.', 'PUBLISHED', 'claude_assessment_v1')
on conflict (slug) do nothing;
insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options, correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('16b26160-8f3c-568d-90fd-f07183a6911e', '52bf1b71-7936-547c-9994-675c81e394e5', 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Можна трохи більше?", "А он та синя?", "Скільки коштує ця футболка?"]'::jsonb, 0, null, 'Može malo više?', null, null, 'Прозвучало: «Može malo više?» — «Можна трохи більше?».', (select id from public.lessons where id = '0e925295-2766-5931-b031-2412682bc6f8'), 'PUBLISHED', 'claude_assessment_v1'),
  ('6846a658-a3ca-5026-8409-889e1d9e7f0a', '52bf1b71-7936-547c-9994-675c81e394e5', 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Який номер будинку?", "Добрий день. Як вас звати?", "Чудово! А італійську ви розумієте?"]'::jsonb, 0, null, 'Koji je kućni broj?', null, null, 'Прозвучало: «Koji je kućni broj?» — «Який номер будинку?».', (select id from public.lessons where id = 'adf335ee-0cba-5c9a-b86a-8baac868edbc'), 'PUBLISHED', 'claude_assessment_v1'),
  ('3add48a6-2734-53cb-a1e8-5de529b11d92', '52bf1b71-7936-547c-9994-675c81e394e5', 3, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Ось двадцять п’ять. Решти не треба.", "Немає. Зате є тістечка на десерт!", "Сьогодні в нас смачний суп і паста."]'::jsonb, 2, null, 'Danas imamo dobru juhu i tjesteninu.', null, null, 'Прозвучало: «Danas imamo dobru juhu i tjesteninu.» — «Сьогодні в нас смачний суп і паста.».', (select id from public.lessons where id = 'c9e045fb-91ff-52a2-9916-1b698d30eb19'), 'PUBLISHED', 'claude_assessment_v1'),
  ('294442d1-99df-593d-87a9-ffcd4ba77604', '52bf1b71-7936-547c-9994-675c81e394e5', 4, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Який сьогодні день?", "Коли їде автобус до Спліта?", "Коли в Хорватії починається школа?"]'::jsonb, 1, null, 'Kada ide autobus za Split?', null, null, 'Прозвучало: «Kada ide autobus za Split?» — «Коли їде автобус до Спліта?».', (select id from public.lessons where id = '39b1e31f-b573-5000-9713-1660688c3cc9'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e21b22a1-16ff-5aa0-9d62-c0a9e6763f61', '52bf1b71-7936-547c-9994-675c81e394e5', 5, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Можна. Мені потрібен ваш паспорт.", "Мені потрібна ще копія паспорта.", "Добре. Заповніть цей бланк."]'::jsonb, 1, null, 'Trebam i kopiju putovnice.', null, null, 'Прозвучало: «Trebam i kopiju putovnice.» — «Мені потрібна ще копія паспорта.».', (select id from public.lessons where id = '19df3241-90f3-5450-94ac-642d79fb2869'), 'PUBLISHED', 'claude_assessment_v1'),
  ('33825800-1bdd-5216-b53e-8d7b018010cb', '52bf1b71-7936-547c-9994-675c81e394e5', 6, 'A0', 'reading', 'understand', 'multiple_choice', 'Коли кафе знову працюватиме?', 'Natpis na vratima kafića', '["Завтра", "У понеділок", "Через тиждень"]'::jsonb, 0, null, null, 'ZATVORENO
Oprostite, danas ne radimo.
Vidimo se sutra!
Hvala!', 'ЗАЧИНЕНО
Вибачте, сьогодні ми не працюємо.
Побачимося завтра!
Дякуємо!', 'Текст «Табличка на дверях кафе». Правильна відповідь: «Завтра».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('77fa6f28-a8a9-5e0b-b2ba-6f19e815cd08', '52bf1b71-7936-547c-9994-675c81e394e5', 7, 'A0', 'reading', 'understand', 'multiple_choice', 'Де фрукти й овочі?', 'Odjeli u trgovini', '["Ліворуч", "Прямо", "Праворуч"]'::jsonb, 0, null, null, 'Voće i povrće ←
Mlijeko i sir →
Pića →
Kruh ↑
WC i izlaz ↓', 'Фрукти й овочі ←
Молоко й сир →
Напої →
Хліб ↑
Туалет і вихід ↓', 'Текст «Відділи магазину». Правильна відповідь: «Ліворуч».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('5a6f0898-c7b0-52da-9284-15ac5dd6a956', '52bf1b71-7936-547c-9994-675c81e394e5', 8, 'A0', 'reading', 'understand', 'multiple_choice', 'Де ключ?', 'Poruka u apartmanu', '["На столі", "У ванній", "На холодильнику"]'::jsonb, 0, null, null, 'Dobro došli!
Ključ je na stolu.
Lozinka za Wi-Fi je na hladnjaku.
Kupaonica je lijevo, kuhinja je desno.
Ugodan boravak!', 'Ласкаво просимо!
Ключ — на столі.
Пароль від Wi-Fi — на холодильнику.
Ванна кімната ліворуч, кухня праворуч.
Приємного перебування!', 'Текст «Записка в апартаментах». Правильна відповідь: «На столі».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('fd04371e-2eca-503d-b045-ec025f8696ff', '52bf1b71-7936-547c-9994-675c81e394e5', 9, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Oprostite, koliko košta ova kava?', '["Dobro! Imam novog prijatelja.", "Jako slatke! Probajte.", "Dva eura."]'::jsonb, 2, null, 'Oprostite, koliko košta ova kava?', null, null, 'Діалог «У кіоску»: «Oprostite, koliko košta ova kava?» (Перепрошую, скільки коштує ця кава?) — «Dva eura.» (Два євро.).', (select id from public.lessons where id = '427e5058-7381-58a0-8f21-bd170866dbae'), 'PUBLISHED', 'claude_assessment_v1'),
  ('14e7aaa7-63c2-5cd7-98aa-d0d4289b964c', '52bf1b71-7936-547c-9994-675c81e394e5', 10, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Imaš li rodbinu u Hrvatskoj?', '["Petsto eura mjesečno.", "Devedeset eura.", "Imam. Moja teta i ujak žive u Rijeci."]'::jsonb, 2, null, 'Imaš li rodbinu u Hrvatskoj?', null, null, 'Діалог «Родичі в Хорватії»: «Imaš li rodbinu u Hrvatskoj?» (У тебе є родичі в Хорватії?) — «Imam. Moja teta i ujak žive u Rijeci.» (Так. Моя тітка й дядько живуть у Рієці.).', (select id from public.lessons where id = 'cec08ff0-a97d-5847-88cc-dee22fed2f8c'), 'PUBLISHED', 'claude_assessment_v1'),
  ('bc94b540-9f58-52d5-95c6-00754d0c4c85', '52bf1b71-7936-547c-9994-675c81e394e5', 11, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Imate li temperaturu?', '["Nula, devet, jedan, dva, tri, četiri, pet.", "Sin ima pet, a kći osam godina.", "Da, malo."]'::jsonb, 2, null, 'Imate li temperaturu?', null, null, 'Діалог «У лікаря»: «Imate li temperaturu?» (У вас є температура?) — «Da, malo.» (Так, трохи.).', (select id from public.lessons where id = 'fbc71f82-e715-5bab-a990-b8542fb0fe01'), 'PUBLISHED', 'claude_assessment_v1'),
  ('76c25c88-68e9-54e6-bbf1-1b81162de642', '52bf1b71-7936-547c-9994-675c81e394e5', 12, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Je li daleko?', '["Čaj, molim. Šalicu toplog čaja.", "Ne, blizu je. Pet minuta pješice.", "Ja sam profesorica. Radim u školi."]'::jsonb, 1, null, 'Je li daleko?', null, null, 'Діалог «На вулиці»: «Je li daleko?» (Це далеко?) — «Ne, blizu je. Pet minuta pješice.» (Ні, близько. П’ять хвилин пішки.).', (select id from public.lessons where id = 'e0b9d742-0418-597b-9482-b6e2d82469da'), 'PUBLISHED', 'claude_assessment_v1'),
  ('dd30e6d1-8630-58ae-beff-b12f83766eff', '52bf1b71-7936-547c-9994-675c81e394e5', 13, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Što ima u tvojoj sobi?', '["Krevet, stol, stolica i ormar.", "Početkom rujna, a završava u lipnju.", "Oko dva sata."]'::jsonb, 0, null, 'Što ima u tvojoj sobi?', null, null, 'Діалог «Нова кімната»: «Što ima u tvojoj sobi?» (Що є у твоїй кімнаті?) — «Krevet, stol, stolica i ormar.» (Ліжко, стіл, стілець і шафа.).', (select id from public.lessons where id = '1436c20e-0aea-550a-b66d-fb3149a1c2e2'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d5c26274-acef-52ef-8687-c3e77dffab00', '52bf1b71-7936-547c-9994-675c81e394e5', 14, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dobar dan! Koji je Vaš kućni broj?', '["Malo. Govorim ukrajinski i engleski.", "Tramvajem, autom je gužva. Stanica je na raskrižju.", "Broj sedam."]'::jsonb, 2, null, 'Dobar dan! Koji je Vaš kućni broj?', null, null, 'Діалог «Доставка»: «Dobar dan! Koji je Vaš kućni broj?» (Добрий день! Який номер вашого будинку?) — «Broj sedam.» (Номер сім.).', (select id from public.lessons where id = 'c0941bd8-57b5-5e7e-981f-9be423f24208'), 'PUBLISHED', 'claude_assessment_v1'),
  ('3e5e04cd-71de-5354-b968-67841afcb4a7', '52bf1b71-7936-547c-9994-675c81e394e5', 15, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Je li ovo tvoja mama?', '["Nula, devet, jedan, dva, tri, četiri, pet.", "Dvije sobe.", "Da, to je moja mama, a ovo je moj tata."]'::jsonb, 2, null, 'Je li ovo tvoja mama?', null, null, 'Діалог «Фото на телефоні»: «Je li ovo tvoja mama?» (Це твоя мама?) — «Da, to je moja mama, a ovo je moj tata.» (Так, це моя мама, а це мій тато.).', (select id from public.lessons where id = '4e003796-1ce0-5a02-8a2d-59a0de38f3dd'), 'PUBLISHED', 'claude_assessment_v1'),
  ('5199f1e3-66e9-5cdf-b0bb-bcbd9b517229', '52bf1b71-7936-547c-9994-675c81e394e5', 16, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Imate li ovu jaknu u crnoj boji?', '["Сіра підійде. А білі футболки?", "Білі он там, біля помаранчевих.", "Чорної немає. Є сіра й коричнева."]'::jsonb, 2, null, null, 'Andrij: Imate li ovu jaknu u crnoj boji?
Prodavač: Nemamo crnu. Imamo sivu i smeđu.
Andrij: Siva je dobra. A bijele majice?
Prodavač: Bijele su tamo, pored narančastih.', 'Andrij: У вас є ця куртка чорного кольору?
Prodavač: Чорної немає. Є сіра й коричнева.
Andrij: Сіра підійде. А білі футболки?
Prodavač: Білі он там, біля помаранчевих.', 'Діалог «Шукаю куртку»: «Imate li ovu jaknu u crnoj boji?» — «Nemamo crnu. Imamo sivu i smeđu.», тобто «Чорної немає. Є сіра й коричнева.».', (select id from public.lessons where id = '288e7610-99c8-5696-989a-86f60ce38b0a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('951441fb-9feb-528f-a2a3-61ef9b4b007a', '52bf1b71-7936-547c-9994-675c81e394e5', 17, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Idemo pješice ili tramvajem?', '["Трамваєм, машиною — затор. Зупинка на перехресті.", "Он там, біля світлофора. Обережно, велосипеди!", "Де пішохідний перехід?"]'::jsonb, 0, null, null, 'Oksana: Idemo pješice ili tramvajem?
Ivan: Tramvajem, autom je gužva. Stanica je na raskrižju.
Oksana: Gdje je pješački prijelaz?
Ivan: Tamo, kod semafora. Pazi na bicikle!', 'Oksana: Ідемо пішки чи трамваєм?
Ivan: Трамваєм, машиною — затор. Зупинка на перехресті.
Oksana: Де пішохідний перехід?
Ivan: Он там, біля світлофора. Обережно, велосипеди!', 'Діалог «Пішки чи трамваєм?»: «Idemo pješice ili tramvajem?» — «Tramvajem, autom je gužva. Stanica je na raskrižju.», тобто «Трамваєм, машиною — затор. Зупинка на перехресті.».', (select id from public.lessons where id = '55af257e-e4d1-51ed-9637-388a7e0b4baf'), 'PUBLISHED', 'claude_assessment_v1'),
  ('aa0b58cc-d1bb-5922-828d-699a5548fe88', '52bf1b71-7936-547c-9994-675c81e394e5', 18, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Imaš li vremena sutra poslijepodne?', '["Післязавтра субота. До обіду чи після обіду?", "Завтра ні, працюю до вечора. Післязавтра можна.", "До обіду, о десятій."]'::jsonb, 1, null, null, 'Ana: Imaš li vremena sutra poslijepodne?
Taras: Sutra ne, radim do večeri. Prekosutra može.
Ana: Prekosutra je subota. Prijepodne ili poslijepodne?
Taras: Prijepodne, u deset.', 'Ana: Маєш час завтра після обіду?
Taras: Завтра ні, працюю до вечора. Післязавтра можна.
Ana: Післязавтра субота. До обіду чи після обіду?
Taras: До обіду, о десятій.', 'Діалог «Коли зустрінемося?»: «Imaš li vremena sutra poslijepodne?» — «Sutra ne, radim do večeri. Prekosutra može.», тобто «Завтра ні, працюю до вечора. Післязавтра можна.».', (select id from public.lessons where id = '238d9508-3c2e-5ee6-910f-0ae8863c2dc7'), 'PUBLISHED', 'claude_assessment_v1'),
  ('1ee4c66f-c18e-5b26-88e4-01436f53d435', '52bf1b71-7936-547c-9994-675c81e394e5', 19, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Drago mi je! Imate li djecu?', '["Це моя дружина Ольга.", "У нас один син. Його звати Максим.", "Хто це?"]'::jsonb, 1, null, null, 'Petra: Tko je ovo?
Andrij: Ovo je moja žena Olga.
Petra: Drago mi je! Imate li djecu?
Olga: Imamo jednog sina. Zove se Maksim.
Petra: Koliko ima godina?
Olga: Četiri.', 'Petra: Хто це?
Andrij: Це моя дружина Ольга.
Petra: Приємно познайомитися! У вас є діти?
Olga: У нас один син. Його звати Максим.
Petra: Скільки йому років?
Olga: Чотири.', 'Діалог «На дні народження»: «Drago mi je! Imate li djecu?» — «Imamo jednog sina. Zove se Maksim.», тобто «У нас один син. Його звати Максим.».', (select id from public.lessons where id = 'f9ca38e4-3a61-56a6-b5f5-060933516c9a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('50c419e9-a58d-5b7d-a15c-5d94cdb9876b', '52bf1b71-7936-547c-9994-675c81e394e5', 20, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «У мене одна сестра». Що ви скажете?', null, '["Imam dečka.", "Imam jednu sestru.", "Tko je to?"]'::jsonb, 1, null, null, null, null, '«У мене одна сестра.» — «Imam jednu sestru.».', (select id from public.lessons where id = 'f9ca38e4-3a61-56a6-b5f5-060933516c9a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('6e1af552-e48f-5232-be1b-086bd360b205', '52bf1b71-7936-547c-9994-675c81e394e5', 21, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Сто євро». Що ви скажете?', null, '["Sto eura.", "Koliko to košta?", "Imam osamnaest godina."]'::jsonb, 0, null, null, null, null, '«Сто євро.» — «Sto eura.».', (select id from public.lessons where id = 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('f5a6bcb0-2d90-55a2-8a33-34cdb4b116d1', '52bf1b71-7936-547c-9994-675c81e394e5', 22, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Одну каву, будь ласка». Що ви скажете?', null, '["Možete li govoriti polako?", "Jednu kavu, molim.", "Bok! Kako si?"]'::jsonb, 1, null, null, null, null, '«Одну каву, будь ласка.» — «Jednu kavu, molim.».', (select id from public.lessons where id = 'd8cffb46-8a62-538a-b864-e227a6d8b863'), 'PUBLISHED', 'claude_assessment_v1'),
  ('cb5ce8d5-f03e-5230-92ef-70898bea554e', '52bf1b71-7936-547c-9994-675c81e394e5', 23, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «одружений (про чоловіка)»', null, '[]'::jsonb, null, 'oženjen', null, null, null, '«одружений (про чоловіка)» — oženjen.', (select id from public.lessons where id = 'cec08ff0-a97d-5847-88cc-dee22fed2f8c'), 'PUBLISHED', 'claude_assessment_v1'),
  ('914cd88e-f64a-5e4c-b8d1-1f2cb74bee93', '52bf1b71-7936-547c-9994-675c81e394e5', 24, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «автомобіль»', null, '[]'::jsonb, null, 'auto', null, null, null, '«автомобіль» — auto.', (select id from public.lessons where id = '55af257e-e4d1-51ed-9637-388a7e0b4baf'), 'PUBLISHED', 'claude_assessment_v1'),
  ('468e8002-26fb-5d4f-8818-16d9a96869f3', '52bf1b71-7936-547c-9994-675c81e394e5', 25, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «щиро дякую»', null, '[]'::jsonb, null, 'hvala lijepa', null, null, null, '«щиро дякую» — hvala lijepa.', (select id from public.lessons where id = '8b30911e-4e57-5648-9ff6-bd11c1b0e27e'), 'PUBLISHED', 'claude_assessment_v1'),
  ('9e1cc503-42eb-5a87-8c9b-d1c274c50220', '52bf1b71-7936-547c-9994-675c81e394e5', 26, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я живу в Загребі.»', null, '["Zagrebu.", "Živim", "u"]'::jsonb, null, 'Živim u Zagrebu.', null, null, null, '«Я живу в Загребі.» — «Živim u Zagrebu.».', (select id from public.lessons where id = 'adf335ee-0cba-5c9a-b86a-8baac868edbc'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d68f794a-d46c-58a0-a4fe-dd6d910b9be3', '52bf1b71-7936-547c-9994-675c81e394e5', 27, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Візьміть номерок в автоматі.»', null, '["Uzmite", "na", "broj", "automatu."]'::jsonb, null, 'Uzmite broj na automatu.', null, null, null, '«Візьміть номерок в автоматі.» — «Uzmite broj na automatu.».', (select id from public.lessons where id = '19df3241-90f3-5450-94ac-642d79fb2869'), 'PUBLISHED', 'claude_assessment_v1'),
  ('0550a88f-90c1-592b-9530-49298ba066e7', '52bf1b71-7936-547c-9994-675c81e394e5', 28, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Що хочеш на сніданок?»', null, '["želiš", "Što", "doručak?", "za"]'::jsonb, null, 'Što želiš za doručak?', null, null, null, '«Що хочеш на сніданок?» — «Što želiš za doručak?».', (select id from public.lessons where id = '7bbaf7ff-10bb-512a-91c5-798b59ec92a5'), 'PUBLISHED', 'claude_assessment_v1'),
  ('50d2add7-2352-529e-bd2c-5e6c6eb9bb91', '52bf1b71-7936-547c-9994-675c81e394e5', 29, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Котра година?»', null, '[]'::jsonb, null, 'Koliko je sati?', null, null, null, '«Котра година?» — «Koliko je sati?».', (select id from public.lessons where id = '39b1e31f-b573-5000-9713-1660688c3cc9'), 'PUBLISHED', 'claude_assessment_v1'),
  ('1de7804a-3ae9-569b-8c90-dbdec5a883a0', '52bf1b71-7936-547c-9994-675c81e394e5', 30, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «У вас є діти?»', null, '[]'::jsonb, null, 'Imate li djecu?', null, null, null, '«У вас є діти?» — «Imate li djecu?».', (select id from public.lessons where id = 'f9ca38e4-3a61-56a6-b5f5-060933516c9a'), 'PUBLISHED', 'claude_assessment_v1')
on conflict (id) do nothing;

-- Журнал перевірки (один запис на тест)
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'assessment', a.id, null, a.status, 'auto_passed', 'script', '[]'::jsonb, 'Бета: тести рівня (§60) за рішенням власника 2026-10-15 (assessment_v1), як уроки A0/A1. Потрібна перевірка носієм.'
from public.assessments a
where a.source = 'claude_assessment_v1' and a.slug in ('a0-m01', 'a0-m02', 'a0-m03', 'a0-m04', 'a0-m05', 'a0-mid', 'a0-m06', 'a0-m07', 'a0-m08', 'a0-m09', 'a0-m10', 'a0-final')
  and not exists (select 1 from public.content_reviews c where c.entity_id = a.id and c.notes = 'Бета: тести рівня (§60) за рішенням власника 2026-10-15 (assessment_v1), як уроки A0/A1. Потрібна перевірка носієм.');

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_tests int; v_items int; v_bad int;
begin
  select count(*) into v_tests from public.assessments where source = 'claude_assessment_v1' and slug in ('a0-m01', 'a0-m02', 'a0-m03', 'a0-m04', 'a0-m05', 'a0-mid', 'a0-m06', 'a0-m07', 'a0-m08', 'a0-m09', 'a0-m10', 'a0-final') and cefr = 'A0';
  select count(*) into v_items from public.assessment_items i join public.assessments a on a.id = i.assessment_id
   where a.source = 'claude_assessment_v1' and a.slug in ('a0-m01', 'a0-m02', 'a0-m03', 'a0-m04', 'a0-m05', 'a0-mid', 'a0-m06', 'a0-m07', 'a0-m08', 'a0-m09', 'a0-m10', 'a0-final');
  select count(*) into v_bad from public.assessments a
   where a.source = 'claude_assessment_v1' and a.slug in ('a0-m01', 'a0-m02', 'a0-m03', 'a0-m04', 'a0-m05', 'a0-mid', 'a0-m06', 'a0-m07', 'a0-m08', 'a0-m09', 'a0-m10', 'a0-final') and (a.kind = 'module' and a.module_id is null);
  if v_tests <> 12 then raise exception 'Тестів %, очікувалось 12', v_tests; end if;
  if v_items <> 150 then raise exception 'Завдань %, очікувалось 150', v_items; end if;
  if v_bad > 0 then raise exception '% тестів модуля без модуля', v_bad; end if;
  raise notice 'Готово: тести рівня A0 — %, завдань — %', v_tests, v_items;
end $$;
