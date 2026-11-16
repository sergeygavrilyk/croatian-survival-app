-- =====================================================================
-- Перевірки рівня A0 за схемою 2026-11-07 · 2026-11-16
-- Згенеровано: python3 -B scripts/gen_assessment_a0_a1_v5.py (не редагуйте вручну).
--
-- Схема (рішення власника 2026-11-07): модуль — 2 завдання на урок (12–20), середина — 30, фінал — 48.
-- Було: модуль — 10, середина — 20, фінал — 30. У цьому файлі 218 нових завдань:
--   a0-m01 — 12, a0-m02 — 18, a0-m03 — 20, a0-m04 — 14, a0-m05 — 14, a0-m06 — 12, a0-m07 — 12, a0-m08 — 12, a0-m09 — 12, a0-m10 — 14, a0-mid — 30, a0-final — 48.
--   * Завдання — з діалогів, вправ і текстів для читання уроків A0; нових хорватських речень немає. 4 навички §60.
--   * «Складіть» — з іншими правильними порядками слів (answer_alternatives), де вони є. Потрібна міграція M27.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються). Нові — PUBLISHED (бета).
--   * Спроби й результати користувачів не змінюються. Повторний запуск нічого не змінює.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення:
--   «Готово: 20261116_assessments_a0_v5.sql — 12 тестів, 218 нових завдань».
-- =====================================================================

begin;
-- Перевірка модуля A0.1 · Модуль A0.1 — Pozdrav! · 12 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-m01' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-m01 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '9e7b55a1-27a4-53e9-b5ec-13f48547eec9') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from 'a0000000-0000-0000-0000-000000000001'::uuid then
    raise exception 'Тест a0-m01 прив’язаний не до модуля A0.1 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 12 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~6 хв.', estimated_minutes = 6 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('9e7b55a1-27a4-53e9-b5ec-13f48547eec9', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["З днем народження, Дашо! Вітаю!", "Кажуть: «hvala».", "Прошу, нема за що."]'::jsonb, 1, null, '{}'::text[], 'Kaže se: hvala.', null, null, 'Прозвучало: «Kaže se: hvala.» — «Кажуть: «hvala».».', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('bbbaad61-d9bc-5092-befc-55215ff50632', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Привіт, Дашо! Чудово, дякую. А ти?", "Вибачте, я вас не почула. Можете повторити голосніше?", "А, зрозуміло! А як сказати «thank you»?"]'::jsonb, 1, null, '{}'::text[], 'Oprostite, nisam Vas čula. Možete li ponoviti glasnije?', null, null, 'Прозвучало: «Oprostite, nisam Vas čula. Možete li ponoviti glasnije?» — «Вибачте, я вас не почула. Можете повторити голосніше?».', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('e55d2eb0-0307-5313-9e4e-56411f4a4de2', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Що означає «OTVORENO»?', 'Na vratima trgovine', '["Зачинено", "Перерва", "Відчинено"]'::jsonb, 2, null, '{}'::text[], null, 'DOBRO DOŠLI!
OTVORENO
Dobar dan! Izvolite.
Hvala i doviđenja!', 'ЛАСКАВО ПРОСИМО!
ВІДЧИНЕНО
Добрий день! Прошу, заходьте.
Дякуємо і до побачення!', 'Текст «На дверях магазину». Правильна відповідь: «Відчинено».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('8cfe0de4-8852-5ae6-8082-dcd02d728da9', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Bok, Dašo! Super, hvala. A ti?', '["Na trećem katu, stan broj 8.", "Ne baš dobro. Umorna sam.", "Loše. Boli me glava i hladno mi je."]'::jsonb, 1, null, '{}'::text[], 'Bok, Dašo! Super, hvala. A ti?', null, null, 'Діалог «Зустріч на вулиці»: «Bok, Dašo! Super, hvala. A ti?» (Привіт, Дашо! Чудово, дякую. А ти?) — «Ne baš dobro. Umorna sam.» (Не дуже добре. Я втомлена.).', (select id from public.lessons where id = 'c0000000-0000-0000-0000-000000000001'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ed28f90a-a290-5779-8055-0bdf1c6a75f8', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Ne razumijem dobro hrvatski. Možete li govoriti polako?', '["Hvala, rado.", "On je moj susjed Marko. A ona je njegova žena.", "Naravno. Tramvaj broj šest ide u centar."]'::jsonb, 2, null, '{}'::text[], 'Ne razumijem dobro hrvatski. Možete li govoriti polako?', null, null, 'Діалог «Турист у Загребі»: «Ne razumijem dobro hrvatski. Možete li govoriti polako?» (Я погано розумію хорватську. Можете говорити повільно?) — «Naravno. Tramvaj broj šest ide u centar.» (Звісно. Трамвай номер шість їде в центр.).', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ca1febac-f78a-5114-80de-ae27e61f41ce', v_aid, 6, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Oprostite, što znači »sutra«?', '["Iz Ukrajine. Moj rodni grad je Lviv.", "Miran je. Živim u predgrađu, u maloj zgradi.", "Danas je ponedjeljak, a sutra je utorak."]'::jsonb, 2, null, '{}'::text[], 'Oprostite, što znači »sutra«?', null, null, 'Діалог «На курсі хорватської»: «Oprostite, što znači »sutra«?» (Вибачте, що означає «sutra»?) — «Danas je ponedjeljak, a sutra je utorak.» (Сьогодні понеділок, а завтра вівторок.).', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('90a7fc26-c6c9-5e01-8a42-69a5032690ee', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Odlično, hvala. A Vi?', '["Так собі. У мене багато роботи.", "Ласкаво просимо! Заходьте.", "Тоді сідайте й відпочиньте."]'::jsonb, 0, null, '{}'::text[], null, 'Gospođa Horvat: Dobro došli! Izvolite.
Petro: Hvala lijepa! Kako ste?
Gospođa Horvat: Odlično, hvala. A Vi?
Petro: Tako-tako. Imam puno posla.
Gospođa Horvat: Onda sjednite i odmorite se.
Petro: Puno hvala!', 'Gospođa Horvat: Ласкаво просимо! Заходьте.
Petro: Щиро дякую! Як ви?
Gospođa Horvat: Відмінно, дякую. А ви?
Petro: Так собі. У мене багато роботи.
Gospođa Horvat: Тоді сідайте й відпочиньте.
Petro: Дуже дякую!', 'Діалог «У гостях у сусідки»: «Odlično, hvala. A Vi?» — «Tako-tako. Imam puno posla.», тобто «Так собі. У мене багато роботи.».', (select id from public.lessons where id = 'c0000000-0000-0000-0000-000000000001'), 'PUBLISHED', 'claude_assessment_v5'),
  ('216a88f8-bc5a-58b1-92c9-3444ecacd219', v_aid, 8, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Hvala, Marko! Izvoli, sok ili vino?', '["Вино, будь ласка. Будьмо!", "Дякую, і тобі!", "Будьмо! І успіхів на новій роботі!"]'::jsonb, 0, null, '{}'::text[], null, 'Marko: Sretan rođendan, Dašo! Čestitam!
Daša: Hvala, Marko! Izvoli, sok ili vino?
Marko: Vino, molim. Na zdravlje!
Daša: Na zdravlje! I sretno na novom poslu!
Marko: Hvala, i tebi!', 'Marko: З днем народження, Дашо! Вітаю!
Daša: Дякую, Марку! Прошу, сік чи вино?
Marko: Вино, будь ласка. Будьмо!
Daša: Будьмо! І успіхів на новій роботі!
Marko: Дякую, і тобі!', 'Діалог «День народження»: «Hvala, Marko! Izvoli, sok ili vino?» — «Vino, molim. Na zdravlje!», тобто «Вино, будь ласка. Будьмо!».', (select id from public.lessons where id = 'e704760a-f743-5762-9c1a-027b10ca030a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7d912fe8-5407-5e69-a76f-bc4e2152ac83', v_aid, 9, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Гарних вихідних!». Що ви скажете?', null, '["Ne razumijem.", "Ugodan vikend!", "Puno hvala!"]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Гарних вихідних!» — «Ugodan vikend!».', (select id from public.lessons where id = 'd8cffb46-8a62-538a-b864-e227a6d8b863'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d9a23dd3-d7eb-5974-94be-c44e912aef2e', v_aid, 10, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «повільніше»', null, '[]'::jsonb, null, 'sporije', '{}'::text[], null, null, null, '«повільніше» — sporije.', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('322a70bb-741e-59c9-8abc-7f0efc039923', v_aid, 11, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «З днем народження!»', null, '["rođendan!", "Sretan"]'::jsonb, null, 'Sretan rođendan!', '{}'::text[], null, null, null, '«З днем народження!» — «Sretan rođendan!».', (select id from public.lessons where id = 'e704760a-f743-5762-9c1a-027b10ca030a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('249fe305-0e10-5e34-a9c3-43133222d7b8', v_aid, 12, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Говоріть повільніше, будь ласка.»', null, '[]'::jsonb, null, 'Govorite sporije, molim.', '{}'::text[], null, null, null, '«Говоріть повільніше, будь ласка.» — «Govorite sporije, molim.».', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A0. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A0.2 · Модуль A0.2 — Ja sam… · 18 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-m02' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-m02 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '743859a4-e82b-5fa7-bb8a-11d8c079f0da') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '993b3c7b-d1ee-5a63-bbf1-75590b68c263'::uuid then
    raise exception 'Тест a0-m02 прив’язаний не до модуля A0.2 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 18 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~9 хв.', estimated_minutes = 9 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('743859a4-e82b-5fa7-bb8a-11d8c079f0da', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Скільки триває поїздка?", "Велика! З якими країнами межує?", "Чим ви займаєтеся?"]'::jsonb, 2, null, '{}'::text[], 'Čime se bavite?', null, null, 'Прозвучало: «Čime se bavite?» — «Чим ви займаєтеся?».', (select id from public.lessons where id = '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('48649401-a4e1-5dce-bfba-e53e8f8f3f48', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Іліца, 25, у Загребі.", "Він хорват, а вона словенка.", "Так, невелика. І я дуже сонна."]'::jsonb, 0, null, '{}'::text[], 'Ilica 25, u Zagrebu.', null, null, 'Прозвучало: «Ilica 25, u Zagrebu.» — «Іліца, 25, у Загребі.».', (select id from public.lessons where id = 'adf335ee-0cba-5c9a-b86a-8baac868edbc'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d5533458-a7a9-551e-9b03-c1f2d06f852f', v_aid, 3, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Відколи ти живеш у Загребі?", "Хто той хлопець?", "Львів — столиця України?"]'::jsonb, 0, null, '{}'::text[], 'Od kada živiš u Zagrebu?', null, null, 'Прозвучало: «Od kada živiš u Zagrebu?» — «Відколи ти живеш у Загребі?».', (select id from public.lessons where id = '8f6439a9-c6ac-5271-99c8-1f0adc5d7599'), 'PUBLISHED', 'claude_assessment_v5'),
  ('45b29446-8020-508a-8789-4f49b381eed0', v_aid, 4, 'A0', 'reading', 'understand', 'multiple_choice', 'Який номер кабінету?', 'Natpis na vratima ordinacije', '["3", "13", "30"]'::jsonb, 0, null, '{}'::text[], null, 'Dr. Ivo Kovač
liječnik obiteljske medicine
Soba 3
Molimo, pokucajte!', 'Д-р Іво Ковач
лікар сімейної медицини
Кабінет 3
Просимо, постукайте!', 'Текст «Табличка на дверях кабінету». Правильна відповідь: «3».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('76ab5995-20a5-5569-9c3c-294b4e182c56', v_aid, 5, 'A0', 'reading', 'understand', 'multiple_choice', 'Якими мовами вона говорить?', 'Pločica s imenom', '["Хорватською й англійською", "Українською", "Тільки хорватською"]'::jsonb, 0, null, '{}'::text[], null, 'ANA
Zovem se Ana. Ja sam konobarica.
Govorim hrvatski i engleski.
Pitajte me!', 'АНА
Мене звати Ана. Я офіціантка.
Я говорю хорватською та англійською.
Запитуйте мене!', 'Текст «Бейдж офіціантки». Правильна відповідь: «Хорватською й англійською».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('db1e05d6-f06e-5ebd-81a9-356053d095dd', v_aid, 6, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Učimo li samo na hrvatskom?', '["Da, ali polako. Ne brinite!", "Na drugom katu, treća vrata lijevo.", "Otprilike četiristo."]'::jsonb, 0, null, '{}'::text[], 'Učimo li samo na hrvatskom?', null, null, 'Діалог «Курс для іноземців»: «Učimo li samo na hrvatskom?» (Ми вчимося лише хорватською?) — «Da, ali polako. Ne brinite!» (Так, але повільно. Не хвилюйтеся!).', (select id from public.lessons where id = 'a9944193-2dfb-5944-b94c-41c41fdb7ca1'), 'PUBLISHED', 'claude_assessment_v5'),
  ('75b5338f-065a-515a-b5cd-b741bd94cf3d', v_aid, 7, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Na kojem katu?', '["Sedamnaest ili devetnaest.", "Na trećem katu, stan broj 8.", "Sutra ne mogu. Čujemo se!"]'::jsonb, 1, null, '{}'::text[], 'Na kojem katu?', null, null, 'Діалог «Яка ваша адреса?»: «Na kojem katu?» (На якому поверсі?) — «Na trećem katu, stan broj 8.» (На третьому поверсі, квартира номер 8.).', (select id from public.lessons where id = 'adf335ee-0cba-5c9a-b86a-8baac868edbc'), 'PUBLISHED', 'claude_assessment_v5'),
  ('bb59c6f8-c122-5834-9cb7-15074f50e01a', v_aid, 8, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Velika je! S kojim zemljama graniči?', '["Tramvaj broj šest. Šest!", "Broj sedam.", "Na zapadu s Poljskom, Slovačkom i Mađarskom."]'::jsonb, 2, null, '{}'::text[], 'Velika je! S kojim zemljama graniči?', null, null, 'Діалог «Карта світу»: «Velika je! S kojim zemljama graniči?» (Велика! З якими країнами межує?) — «Na zapadu s Poljskom, Slovačkom i Mađarskom.» (На заході — з Польщею, Словаччиною та Угорщиною.).', (select id from public.lessons where id = '479784bc-54ab-522d-9c77-55887ae68e33'), 'PUBLISHED', 'claude_assessment_v5'),
  ('8384090d-c536-50c2-8219-57e1670fc294', v_aid, 9, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Drago mi je. Vi ste iz Ukrajine?', '["Da, mi smo oboje iz Ukrajine.", "Trideset četiri.", "Nas je dvanaest."]'::jsonb, 0, null, '{}'::text[], 'Drago mi je. Vi ste iz Ukrajine?', null, null, 'Діалог «На роботі»: «Drago mi je. Vi ste iz Ukrajine?» (Дуже приємно. Ви з України?) — «Da, mi smo oboje iz Ukrajine.» (Так, ми обоє з України.).', (select id from public.lessons where id = '8abb83d8-ec02-5921-ac9b-814489816fcd'), 'PUBLISHED', 'claude_assessment_v5'),
  ('e3e797ed-0245-5713-9800-887f134915e1', v_aid, 10, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Jesam. Koje jezike govoriš?', '["Супер! Ти можеш навчити мене італійської!", "Українською, англійською і трохи польською. Хорватську ще вчу.", "А я вільно говорю італійською. Моя мама — італійка."]'::jsonb, 1, null, '{}'::text[], null, 'Petra: Jesi li ti Ukrajinka?
Daša: Jesam. A ti si Hrvatica?
Petra: Jesam. Koje jezike govoriš?
Daša: Ukrajinski, engleski i malo poljski. Hrvatski još učim.
Petra: Ja tečno govorim talijanski. Majka mi je Talijanka.
Daša: Super! Možeš me naučiti talijanski!', 'Petra: Ти українка?
Daša: Так. А ти хорватка?
Petra: Так. Якими мовами ти розмовляєш?
Daša: Українською, англійською і трохи польською. Хорватську ще вчу.
Petra: А я вільно говорю італійською. Моя мама — італійка.
Daša: Супер! Ти можеш навчити мене італійської!', 'Діалог «Ти українка?»: «Jesam. Koje jezike govoriš?» — «Ukrajinski, engleski i malo poljski. Hrvatski još učim.», тобто «Українською, англійською і трохи польською. Хорватську ще вчу.».', (select id from public.lessons where id = 'a9944193-2dfb-5944-b94c-41c41fdb7ca1'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1d194364-8aad-5a56-98fc-63c17986f85d', v_aid, 11, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Kada si došla u Hrvatsku?', '["Одеса біля моря, як Спліт!", "Два роки тому.", "Так! Але зараз я живу в Загребі."]'::jsonb, 1, null, '{}'::text[], null, 'Marko: Dašo, odakle si?
Daša: Iz Ukrajine. Rodom sam iz Odese.
Marko: Odesa je na moru, kao Split!
Daša: Da! Ali sada živim u Zagrebu.
Marko: Kada si došla u Hrvatsku?
Daša: Prije dvije godine.', 'Marko: Дашо, звідки ти?
Daša: З України. Я родом з Одеси.
Marko: Одеса біля моря, як Спліт!
Daša: Так! Але зараз я живу в Загребі.
Marko: Коли ти приїхала до Хорватії?
Daša: Два роки тому.', 'Діалог «Звідки ти?»: «Kada si došla u Hrvatsku?» — «Prije dvije godine.», тобто «Два роки тому.».', (select id from public.lessons where id = '04167753-db83-5163-a91c-9f71dac18ab5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('73f99b70-47ce-5760-beb3-b25bf50db71a', v_aid, 12, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Італія — на півдні». Що ви скажете?', null, '["Italija je na jugu.", "Živim u Ilici.", "Živim na drugom katu."]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Італія — на півдні.» — «Italija je na jugu.».', (select id from public.lessons where id = '479784bc-54ab-522d-9c77-55887ae68e33'), 'PUBLISHED', 'claude_assessment_v5'),
  ('8987fe44-90d0-5484-be0d-41f82d34bdce', v_aid, 13, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я програміст». Що ви скажете?', null, '["Kako se osjećaš?", "Ja sam programer.", "Odakle si?"]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Я програміст.» — «Ja sam programer.».', (select id from public.lessons where id = '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f2cd4654-881a-5aab-becf-37b44f00a9c4', v_aid, 14, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «передмістя»', null, '[]'::jsonb, null, 'predgrađe', '{}'::text[], null, null, null, '«передмістя» — predgrađe.', (select id from public.lessons where id = 'adf335ee-0cba-5c9a-b86a-8baac868edbc'), 'PUBLISHED', 'claude_assessment_v5'),
  ('148300d6-e617-5404-83e1-fe0da05e3329', v_aid, 15, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «візитівка»', null, '[]'::jsonb, null, 'posjetnica', '{}'::text[], null, null, null, '«візитівка» — posjetnica.', (select id from public.lessons where id = '2b6ed342-cc80-5bd9-baf0-b66109624d62'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d62aa616-c78a-56da-9aa9-32f681b8727f', v_aid, 16, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Він мій сусід.»', null, '["On", "susjed.", "moj", "je"]'::jsonb, null, 'On je moj susjed.', '{}'::text[], null, null, null, '«Він мій сусід.» — «On je moj susjed.».', (select id from public.lessons where id = '8abb83d8-ec02-5921-ac9b-814489816fcd'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2c3ad4de-71d4-5a44-a944-f06c8c2f7f3e', v_aid, 17, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Моя рідна мова — українська.»', null, '["jezik", "materinski", "Moj", "je", "ukrajinski."]'::jsonb, null, 'Moj materinski jezik je ukrajinski.', array['Ukrajinski je moj materinski jezik.']::text[], null, null, null, '«Моя рідна мова — українська.» — «Moj materinski jezik je ukrajinski.».', (select id from public.lessons where id = 'a9944193-2dfb-5944-b94c-41c41fdb7ca1'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9109618f-8878-56d1-abbd-7046eaf5b700', v_aid, 18, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Як тебе звати?»', null, '[]'::jsonb, null, 'Kako se zoveš?', '{}'::text[], null, null, null, '«Як тебе звати?» — «Kako se zoveš?».', (select id from public.lessons where id = '2b6ed342-cc80-5bd9-baf0-b66109624d62'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A0. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A0.3 · Модуль A0.3 — Brojevi (числа) · 20 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-m03' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-m03 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '5bf7d6f2-7d7b-5765-bc0c-4fb57d507adc') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '9367556f-1e3f-52c4-9a05-65efc8a2dc6b'::uuid then
    raise exception 'Тест a0-m03 прив’язаний не до модуля A0.3 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 20 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~10 хв.', estimated_minutes = 10 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('5bf7d6f2-7d7b-5765-bc0c-4fb57d507adc', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Дашо, скільки буде сім помножити на вісім?", "Скільки коштує квартира в центрі Загреба?", "Так. Сто мінус п’ятдесят шість — сорок чотири?"]'::jsonb, 0, null, '{}'::text[], 'Dašo, koliko je sedam puta osam?', null, null, 'Прозвучало: «Dašo, koliko je sedam puta osam?» — «Дашо, скільки буде сім помножити на вісім?».', (select id from public.lessons where id = 'ba35964d-f0d8-5d15-9566-ef44d37e6d12'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d4a7718e-202f-5589-842b-32e28634fd6b', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Який у вас номер мобільного?", "Сім чи вісім?", "А де ліфт?"]'::jsonb, 0, null, '{}'::text[], 'Koji je Vaš broj mobitela?', null, null, 'Прозвучало: «Koji je Vaš broj mobitela?» — «Який у вас номер мобільного?».', (select id from public.lessons where id = 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('832f7828-4332-5256-8501-713506c8dcb7', v_aid, 3, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Це майже як уся Хорватія!", "Ні, двох досить. Половина людей не їсть солодкого.", "Тоді купи один великий торт і кілька тістечок."]'::jsonb, 0, null, '{}'::text[], 'To je gotovo kao cijela Hrvatska!', null, null, 'Прозвучало: «To je gotovo kao cijela Hrvatska!» — «Це майже як уся Хорватія!».', (select id from public.lessons where id = '1f41cb75-1ce5-57ba-a56f-58561ee1d983'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c3be7072-a766-5cdc-832e-f3721aaf73db', v_aid, 4, 'A0', 'reading', 'understand', 'multiple_choice', 'Ваш номер — 15. Який це поверх?', 'Sobe u hotelu', '["Перший (prvi kat)", "Другий (drugi kat)", "Біля входу"]'::jsonb, 1, null, '{}'::text[], null, 'Sobe 1 – 10: prvi kat
Sobe 11 – 20: drugi kat
Recepcija: prizemlje
Lift je desno.', 'Номери 1–10: перший поверх (над входом)
Номери 11–20: другий поверх
Рецепція: партер (поверх біля входу)
Ліфт праворуч.', 'Текст «Номери в готелі». Правильна відповідь: «Другий (drugi kat)».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('97ac222f-5c64-5cd4-b81a-7c164b65643e', v_aid, 5, 'A0', 'reading', 'understand', 'multiple_choice', 'Скільки яєць можна купити за 3 €?', 'Cijene na tržnici', '["10", "3", "5"]'::jsonb, 0, null, '{}'::text[], null, 'JABUKE 1,50 € / kg
KRUŠKE 2 € / kg
JAJA – 10 komada 3 €
SIR 8 € / kg', 'ЯБЛУКА 1,50 € / кг
ГРУШІ 2 € / кг
ЯЙЦЯ – 10 штук 3 €
СИР 8 € / кг', 'Текст «Цінники на ринку». Правильна відповідь: «10».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('5c44a867-03fc-53e2-a490-bda678346c32', v_aid, 6, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dobra večer! Koliko vas je?', '["Miran je. Živim u predgrađu, u maloj zgradi.", "Ukrajinski, engleski i malo poljski. Hrvatski još učim.", "Nas je dvanaest."]'::jsonb, 2, null, '{}'::text[], 'Dobra večer! Koliko vas je?', null, null, 'Діалог «Стіл на скількох?»: «Dobra večer! Koliko vas je?» (Добрий вечір! Скільки вас?) — «Nas je dvanaest.» (Нас дванадцять.).', (select id from public.lessons where id = 'e30c65f2-1a30-5b51-85e7-6a460cd1799f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6ff72fba-4819-5d95-a8e7-2895210cbf8f', v_aid, 7, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koliko stanovnika ima Hrvatska?', '["Mama je u Ukrajini, a brat u Njemačkoj.", "Malo manje od četiri milijuna.", "Dobar dan. Zovem se Darja Kovalenko."]'::jsonb, 1, null, '{}'::text[], 'Koliko stanovnika ima Hrvatska?', null, null, 'Діалог «Скільки жителів?»: «Koliko stanovnika ima Hrvatska?» (Скільки жителів у Хорватії?) — «Malo manje od četiri milijuna.» (Трохи менше ніж чотири мільйони.).', (select id from public.lessons where id = '1f41cb75-1ce5-57ba-a56f-58561ee1d983'), 'PUBLISHED', 'claude_assessment_v5'),
  ('909188cd-6436-5b0f-961d-fb42faaa6d59', v_aid, 8, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Kada dolazi sedamnaest?', '["Hvala, rado.", "Za točno petnaest minuta.", "Tako-tako. Imam puno posla."]'::jsonb, 1, null, '{}'::text[], 'Kada dolazi sedamnaest?', null, null, 'Діалог «Який автобус?»: «Kada dolazi sedamnaest?» (Коли приходить сімнадцятий?) — «Za točno petnaest minuta.» (Рівно за п’ятнадцять хвилин.).', (select id from public.lessons where id = 'e30c65f2-1a30-5b51-85e7-6a460cd1799f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a175227d-ebb0-5852-a5fb-0130feef7ff0', v_aid, 9, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Nemam sitniša. Imate li kovanice?', '["Iz Ukrajine. Moj rodni grad je Lviv.", "Evo, točno dva eura i pedeset centi.", "Vino, molim. Na zdravlje!"]'::jsonb, 1, null, '{}'::text[], 'Nemam sitniša. Imate li kovanice?', null, null, 'Діалог «У кіоску»: «Nemam sitniša. Imate li kovanice?» (У мене немає дрібних. У вас є монети?) — «Evo, točno dva eura i pedeset centi.» (Ось, рівно два євро п’ятдесят центів.).', (select id from public.lessons where id = '427e5058-7381-58a0-8f21-bd170866dbae'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4bb40e0b-7a40-5f79-b07e-7a22952547bc', v_aid, 10, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Sedam ili osam?', '["Сім, не вісім.", "Дякую, чекаю!", "Добре, буду за п’ять хвилин."]'::jsonb, 0, null, '{}'::text[], null, 'Dostavljač: Dobar dan, dostava! Koji je broj Vašeg stana?
Daša: Broj sedam.
Dostavljač: Sedam ili osam?
Daša: Sedam, ne osam.
Dostavljač: Dobro, dolazim za pet minuta.
Daša: Hvala, čekam!', 'Dostavljač: Добрий день, доставка! Який номер вашої квартири?
Daša: Номер сім.
Dostavljač: Сім чи вісім?
Daša: Сім, не вісім.
Dostavljač: Добре, буду за п’ять хвилин.
Daša: Дякую, чекаю!', 'Діалог «Номер квартири»: «Sedam ili osam?» — «Sedam, ne osam.», тобто «Сім, не вісім.».', (select id from public.lessons where id = 'c0941bd8-57b5-5e7e-981f-9be423f24208'), 'PUBLISHED', 'claude_assessment_v5'),
  ('99d93e1c-478a-5ae9-a09f-7e8837d7656e', v_aid, 11, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Koji iznos želite podići?', '["Сімсот євро, будь ласка.", "Прошу: сім купюр по сто євро.", "Дякую, усе правильно."]'::jsonb, 0, null, '{}'::text[], null, 'Službenica: Koji iznos želite podići?
Darja: Sedamsto eura, molim.
Službenica: Sedamsto ili sedamdeset?
Darja: Sedamsto. Za najam stana.
Službenica: Izvolite: sedam novčanica od sto eura.
Darja: Hvala, točno je.', 'Službenica: Яку суму ви хочете зняти?
Darja: Сімсот євро, будь ласка.
Službenica: Сімсот чи сімдесят?
Darja: Сімсот. За оренду квартири.
Službenica: Прошу: сім купюр по сто євро.
Darja: Дякую, усе правильно.', 'Діалог «Яка сума?»: «Koji iznos želite podići?» — «Sedamsto eura, molim.», тобто «Сімсот євро, будь ласка.».', (select id from public.lessons where id = 'c0d7b467-acb2-581a-975b-497e63f45aa7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('8bfefc03-2035-52ab-9e95-c5d32553f56a', v_aid, 12, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Koliko ljudi dolazi na tvoj rođendan?', '["Синові шість років, а доньці вісім місяців.", "Ні, ви набрали не той номер.", "Близько десяти, може, близько двадцяти."]'::jsonb, 2, null, '{}'::text[], null, 'Ana: Koliko ljudi dolazi na tvoj rođendan?
Daša: Desetak, možda dvadesetak.
Ana: Trebaš barem tri torte!
Daša: Ne, dvije su dovoljne. Pola ljudi ne jede slatko.
Ana: Onda kupi jednu veliku tortu i par kolača.', 'Ana: Скільки людей прийде на твій день народження?
Daša: Близько десяти, може, близько двадцяти.
Ana: Тобі треба принаймні три торти!
Daša: Ні, двох досить. Половина людей не їсть солодкого.
Ana: Тоді купи один великий торт і кілька тістечок.', 'Діалог «Скільки людей прийде?»: «Koliko ljudi dolazi na tvoj rođendan?» — «Desetak, možda dvadesetak.», тобто «Близько десяти, може, близько двадцяти.».', (select id from public.lessons where id = '22dd7878-4fa8-5e1c-909e-71c70ffd9918'), 'PUBLISHED', 'claude_assessment_v5'),
  ('04e68591-0bfa-58ca-b82b-d5cad3a466a4', v_aid, 13, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Мільярд євро». Що ви скажете?', null, '["Milijarda eura.", "Barem pet.", "Dvije tisuće."]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Мільярд євро.» — «Milijarda eura.».', (select id from public.lessons where id = '1f41cb75-1ce5-57ba-a56f-58561ee1d983'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ce6dc354-3d34-5b23-9751-d867058d9a7a', v_aid, 14, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Автобус номер сімнадцять». Що ви скажете?', null, '["Koliko je to ukupno?", "Ne razumijem.", "Autobus broj sedamnaest."]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Автобус номер сімнадцять.» — «Autobus broj sedamnaest.».', (select id from public.lessons where id = 'e30c65f2-1a30-5b51-85e7-6a460cd1799f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('bbe8c348-58c3-550d-b068-a113eea285df', v_aid, 15, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «неповнолітній»', null, '[]'::jsonb, null, 'maloljetan', '{}'::text[], null, null, null, '«неповнолітній» — maloljetan.', (select id from public.lessons where id = '4c5db9c0-aa58-55c5-b647-7f7cfc8396c2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('0f80b69d-39c8-5baf-a5db-2a885c2ec5b1', v_aid, 16, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «сімнадцять»', null, '[]'::jsonb, null, 'sedamnaest', '{}'::text[], null, null, null, '«сімнадцять» — sedamnaest.', (select id from public.lessons where id = 'e30c65f2-1a30-5b51-85e7-6a460cd1799f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('38a95110-3792-5319-a1fa-2cb867043b70', v_aid, 17, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Хто останній у черзі?»', null, '["je", "Tko", "redu?", "u", "zadnji"]'::jsonb, null, 'Tko je zadnji u redu?', '{}'::text[], null, null, null, '«Хто останній у черзі?» — «Tko je zadnji u redu?».', (select id from public.lessons where id = '40f7c64a-ad42-5fe2-a230-7b1e98607112'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b6d086aa-b41d-52fc-a202-1c30772b029f', v_aid, 18, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «П’ять плюс три — вісім.»', null, '["tri", "osam.", "je", "plus", "Pet"]'::jsonb, null, 'Pet plus tri je osam.', '{}'::text[], null, null, null, '«П’ять плюс три — вісім.» — «Pet plus tri je osam.».', (select id from public.lessons where id = 'ba35964d-f0d8-5d15-9566-ef44d37e6d12'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a9eccd3e-70df-5121-8e98-1f3cff771afc', v_aid, 19, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Скільки тут яблук?»', null, '["Koliko", "jabuka?", "ima"]'::jsonb, null, 'Koliko ima jabuka?', array['Koliko jabuka ima?']::text[], null, null, null, '«Скільки тут яблук?» — «Koliko ima jabuka?».', (select id from public.lessons where id = 'c0941bd8-57b5-5e7e-981f-9be423f24208'), 'PUBLISHED', 'claude_assessment_v5'),
  ('8ae9c0f8-1102-5a7c-a0d6-868279f06bba', v_aid, 20, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Пів кілограма.»', null, '[]'::jsonb, null, 'Pola kile.', '{}'::text[], null, null, null, '«Пів кілограма.» — «Pola kile.».', (select id from public.lessons where id = '22dd7878-4fa8-5e1c-909e-71c70ffd9918'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A0. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A0.4 · Модуль A0.4 — Vrijeme (час) · 14 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-m04' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-m04 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = 'a26ee670-0348-5160-851a-4020cca1276d') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '7e7aa512-46f3-50d8-b95a-7ba4b9e6f148'::uuid then
    raise exception 'Тест a0-m04 прив’язаний не до модуля A0.4 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 14 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~7 хв.', estimated_minutes = 7 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('a26ee670-0348-5160-851a-4020cca1276d', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Сьогодні вранці я прокинулася о шостій.", "А в неділю прийде юго, з дощем і грозою.", "Я люблю весну, особливо квітень і травень."]'::jsonb, 2, null, '{}'::text[], 'Volim proljeće, posebno travanj i svibanj.', null, null, 'Прозвучало: «Volim proljeće, posebno travanj i svibanj.» — «Я люблю весну, особливо квітень і травень.».', (select id from public.lessons where id = '036fc4fb-1bf2-5100-9fd0-6f6a612554a1'), 'PUBLISHED', 'claude_assessment_v5'),
  ('0df3eb88-35ed-5b4b-9424-4b3c07035cc1', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Маєш рацію, сьогодні ввечері ляжу спати рано.", "Учора ввечері я прийшла додому тільки опівночі.", "Наступного понеділка о дев’ятій у мене є вільний час."]'::jsonb, 0, null, '{}'::text[], 'Imaš pravo, večeras idem rano spavati.', null, null, 'Прозвучало: «Imaš pravo, večeras idem rano spavati.» — «Маєш рацію, сьогодні ввечері ляжу спати рано.».', (select id from public.lessons where id = '238d9508-3c2e-5ee6-910f-0ae8863c2dc7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9ebd7ded-8a88-5d42-a854-4e24b73ef26e', v_aid, 3, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Дашо, яку пору року ти любиш найбільше?", "Дар’є, коли у вас відпустка?", "Добре, встаю! Чому ми завжди поспішаємо?"]'::jsonb, 0, null, '{}'::text[], 'Dašo, koje godišnje doba voliš najviše?', null, null, 'Прозвучало: «Dašo, koje godišnje doba voliš najviše?» — «Дашо, яку пору року ти любиш найбільше?».', (select id from public.lessons where id = '036fc4fb-1bf2-5100-9fd0-6f6a612554a1'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d9e71d9b-4462-57de-9cbf-f7ca34090605', v_aid, 4, 'A0', 'reading', 'understand', 'multiple_choice', 'До котрої пошта працює в суботу?', 'Radno vrijeme pošte', '["До 8", "До 13", "До 19"]'::jsonb, 1, null, '{}'::text[], null, 'POŠTA
Radno vrijeme:
ponedjeljak – petak: 7 – 19 h
subota: 8 – 13 h
nedjelja: zatvoreno', 'ПОШТА
Години роботи:
понеділок – п’ятниця: 7–19
субота: 8–13
неділя: зачинено', 'Текст «Години роботи пошти». Правильна відповідь: «До 13».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('7721eb43-233f-5418-831a-4e51d97da218', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Super! Idemo u nedjelju na izlet?', '["Otprilike četiristo.", "Darja, Ukrajinka sam. Materinski jezik mi je ukrajinski.", "Može! Ovaj tjedan imam puno obveza."]'::jsonb, 2, null, '{}'::text[], 'Super! Idemo u nedjelju na izlet?', null, null, 'Діалог «Плани на вихідні»: «Super! Idemo u nedjelju na izlet?» (Чудово! Поїдемо в неділю за місто?) — «Može! Ovaj tjedan imam puno obveza.» (Можна! Цього тижня в мене багато справ.).', (select id from public.lessons where id = '8e372ece-ae10-50ae-9cf3-07b52ef2f72d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('49435759-2fe7-513b-8372-87ce093dc386', v_aid, 6, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koji je rok?', '["Malo manje od četiri milijuna.", "Dođite najkasnije početkom veljače.", "Trideset posto na sve jakne."]'::jsonb, 1, null, '{}'::text[], 'Koji je rok?', null, null, 'Діалог «Дозвіл на проживання»: «Koji je rok?» (Який термін?) — «Dođite najkasnije početkom veljače.» (Прийдіть не пізніше початку лютого.).', (select id from public.lessons where id = 'b36b4550-ff36-50cb-89fb-8246b351c8d6'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7fb5693d-852b-5aec-b38e-e5cdde71701d', v_aid, 7, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Imaš li već poklon?', '["Nemam. Moram ga kupiti danas poslijepodne.", "On je Hrvat, a ona je Slovenka.", "Ja sam zadnji. Vi ste iza mene."]'::jsonb, 0, null, '{}'::text[], 'Imaš li već poklon?', null, null, 'Діалог «Яке сьогодні число?»: «Imaš li već poklon?» (У тебе вже є подарунок?) — «Nemam. Moram ga kupiti danas poslijepodne.» (Немає. Мушу купити його сьогодні після обіду.).', (select id from public.lessons where id = 'b36b4550-ff36-50cb-89fb-8246b351c8d6'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b91fa25d-45d1-5c0b-a0b1-22fc802bbbef', v_aid, 8, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Oprostite, u koliko sati ide vlak za Rijeku?', '["Відправлення о десятій п’ятнадцять.", "Ні, потяг іде вчасно. Прибуття до Рієки о пів на другу.", "Рівно десята. У вас ще чверть години."]'::jsonb, 0, null, '{}'::text[], null, 'Daša: Oprostite, u koliko sati ide vlak za Rijeku?
Službenica: Polazak je u deset i petnaest.
Daša: A koliko je sati sada?
Službenica: Točno deset. Imate još četvrt sata.
Daša: Ima li kašnjenja?
Službenica: Nema, vlak ide na vrijeme. Dolazak u Rijeku je u jedan i pol.', 'Daša: Вибачте, о котрій їде потяг до Рієки?
Službenica: Відправлення о десятій п’ятнадцять.
Daša: А котра зараз година?
Službenica: Рівно десята. У вас ще чверть години.
Daša: Є затримка?
Službenica: Ні, потяг іде вчасно. Прибуття до Рієки о пів на другу.', 'Діалог «На вокзалі»: «Oprostite, u koliko sati ide vlak za Rijeku?» — «Polazak je u deset i petnaest.», тобто «Відправлення о десятій п’ятнадцять.».', (select id from public.lessons where id = '39b1e31f-b573-5000-9713-1660688c3cc9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('8b0b3ba1-93a4-5b3d-9ced-1280a5791c28', v_aid, 9, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dašo, gdje dočekuješ Novu godinu?', '["Так! Бажаю тобі щасливого Нового року!", "Дякую, і тобі всього найкращого!", "На площі в центрі. Буде концерт і феєрверк."]'::jsonb, 2, null, '{}'::text[], null, 'Marko: Dašo, gdje dočekuješ Novu godinu?
Daša: Na trgu u centru. Bit će koncert i vatromet.
Marko: Super! A prvi siječnja je neradni dan, možemo se naspavati.
Daša: Da! Želim ti sretnu Novu godinu!
Marko: Hvala, sve najbolje i tebi!', 'Marko: Дашо, де ти зустрічаєш Новий рік?
Daša: На площі в центрі. Буде концерт і феєрверк.
Marko: Чудово! А перше січня — неробочий день, можна виспатися.
Daša: Так! Бажаю тобі щасливого Нового року!
Marko: Дякую, і тобі всього найкращого!', 'Діалог «Новий рік»: «Dašo, gdje dočekuješ Novu godinu?» — «Na trgu u centru. Bit će koncert i vatromet.», тобто «На площі в центрі. Буде концерт і феєрверк.».', (select id from public.lessons where id = 'd7cf3059-0d92-5215-8ef4-ad699e317b10'), 'PUBLISHED', 'claude_assessment_v5'),
  ('eb497bf0-7908-52ff-b457-a2c947fb7e5f', v_aid, 10, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Побачимося в понеділок!». Що ви скажете?', null, '["Vidimo se u ponedjeljak!", "Sretan Uskrs!", "Sljedeće godine."]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Побачимося в понеділок!» — «Vidimo se u ponedjeljak!».', (select id from public.lessons where id = '8e372ece-ae10-50ae-9cf3-07b52ef2f72d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b5ae27f4-8b83-5270-a8b0-268495762f4f', v_aid, 11, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я народилася п’ятого травня». Що ви скажете?', null, '["Sretni blagdani!", "Jučer, danas, sutra.", "Rođena sam petog svibnja."]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Я народилася п’ятого травня.» — «Rođena sam petog svibnja.».', (select id from public.lessons where id = 'b36b4550-ff36-50cb-89fb-8246b351c8d6'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c57e9f47-58c6-5cfc-8ef8-b3cd208bc352', v_aid, 12, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «наступний»', null, '[]'::jsonb, null, 'sljedeći', '{}'::text[], null, null, null, '«наступний» — sljedeći.', (select id from public.lessons where id = '8e372ece-ae10-50ae-9cf3-07b52ef2f72d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('889a2c6c-485d-5e61-87f3-aaee1dab7f82', v_aid, 13, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Яка сьогодні погода?»', null, '["je", "danas", "Kakvo", "vrijeme?"]'::jsonb, null, 'Kakvo je danas vrijeme?', array['Kakvo je vrijeme danas?']::text[], null, null, null, '«Яка сьогодні погода?» — «Kakvo je danas vrijeme?».', (select id from public.lessons where id = 'efcf49e0-c058-5986-9cf7-aee921887a81'), 'PUBLISHED', 'claude_assessment_v5'),
  ('cfa12de3-b652-5b8a-9970-e316ed73e102', v_aid, 14, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Я люблю літо.»', null, '[]'::jsonb, null, 'Volim ljeto.', '{}'::text[], null, null, null, '«Я люблю літо.» — «Volim ljeto.».', (select id from public.lessons where id = '036fc4fb-1bf2-5100-9fd0-6f6a612554a1'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A0. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A0.5 · Модуль A0.5 — Obitelj (сім’я) · 14 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-m05' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-m05 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '8b25654a-8263-5077-9bbf-0533380654ac') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '03537c9e-b657-5004-a254-389abb5c8dfc'::uuid then
    raise exception 'Тест a0-m05 прив’язаний не до модуля A0.5 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 14 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~7 хв.', estimated_minutes = 7 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('8b25654a-8263-5077-9bbf-0533380654ac', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Мамо, Луція запросила мене на день народження!", "Це моя сім’я. Це мої батьки.", "У мене собака. Щоранку вигулюю його в парку."]'::jsonb, 2, null, '{}'::text[], 'Ja imam psa. Svako jutro ga šetam u parku.', null, null, 'Прозвучало: «Ja imam psa. Svako jutro ga šetam u parku.» — «У мене собака. Щоранку вигулюю його в парку.».', (select id from public.lessons where id = '40b9da1d-1686-5b78-8317-0439067d5f8e'), 'PUBLISHED', 'claude_assessment_v5'),
  ('bb1ca926-5039-51fe-bade-e22f19f0ed84', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Іноді я лінива, але вчуся щодня!", "Звісно! Купимо їй гарну іграшку.", "Ні. У мене чорна куртка."]'::jsonb, 1, null, '{}'::text[], 'Naravno! Kupit ćemo joj lijepu igračku.', null, null, 'Прозвучало: «Naravno! Kupit ćemo joj lijepu igračku.» — «Звісно! Купимо їй гарну іграшку.».', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v5'),
  ('908d7239-4a3e-5dc4-b6f8-d0cdf8defccb', v_aid, 3, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Чудово, значить, ти тут не сама.", "Це моя сестра Олена. Вона найстарша.", "Ні, маленький, але багато гавкає!"]'::jsonb, 1, null, '{}'::text[], 'To je moja sestra Olena. Ona je najstarija.', null, null, 'Прозвучало: «To je moja sestra Olena. Ona je najstarija.» — «Це моя сестра Олена. Вона найстарша.».', (select id from public.lessons where id = '4e003796-1ce0-5a02-8a2d-59a0de38f3dd'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a1459967-460f-5349-b920-88e658e04a56', v_aid, 4, 'A0', 'reading', 'understand', 'multiple_choice', 'Що мають робити батьки?', 'Dječje igralište', '["Платити", "Чекати надворі", "Наглядати за дітьми"]'::jsonb, 2, null, '{}'::text[], null, 'DJEČJE IGRALIŠTE
Za djecu do 12 godina.
Roditelji, pazite na djecu!
Psi ne smiju ući.', 'ДИТЯЧИЙ МАЙДАНЧИК
Для дітей до 12 років.
Батьки, наглядайте за дітьми!
Собакам заходити не можна.', 'Текст «Дитячий майданчик». Правильна відповідь: «Наглядати за дітьми».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('0da0be56-6d6a-5894-bdfb-67247ae51ad8', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Čestitam! Tko je sretnik?', '["Moj dečko Petar. Vjenčanje je u lipnju.", "Tramvaj broj šest. Šest!", "Hvala, rado."]'::jsonb, 0, null, '{}'::text[], 'Čestitam! Tko je sretnik?', null, null, 'Діалог «Весілля»: «Čestitam! Tko je sretnik?» (Вітаю! І хто ж цей щасливчик?) — «Moj dečko Petar. Vjenčanje je u lipnju.» (Мій хлопець Петар. Весілля в червні.).', (select id from public.lessons where id = 'f9ca38e4-3a61-56a6-b5f5-060933516c9a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('0b1764d9-fadf-5681-ab74-6023f8c741a6', v_aid, 6, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, što radiš ovaj vikend?', '["Na trgu u centru. Bit će koncert i vatromet.", "U subotu radim, ali u nedjelju sam slobodna.", "Dolazi mi svekrva iz Ukrajine, mama mog muža."]'::jsonb, 2, null, '{}'::text[], 'Dašo, što radiš ovaj vikend?', null, null, 'Діалог «Свекруха в гостях»: «Dašo, što radiš ovaj vikend?» (Дашо, що робиш на цих вихідних?) — «Dolazi mi svekrva iz Ukrajine, mama mog muža.» (До мене приїжджає свекруха з України, мама мого чоловіка.).', (select id from public.lessons where id = 'cec08ff0-a97d-5847-88cc-dee22fed2f8c'), 'PUBLISHED', 'claude_assessment_v5'),
  ('48929c59-80cd-5652-a966-7dc96f9774c0', v_aid, 7, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Imaju li djecu?', '["Na zapadu s Poljskom, Slovačkom i Mađarskom.", "Imaju sina, mog bratića Oleha. I on radi ovdje.", "Iz Ukrajine. Rodom sam iz Odese."]'::jsonb, 1, null, '{}'::text[], 'Imaju li djecu?', null, null, 'Діалог «Родичі в Хорватії»: «Imaju li djecu?» (У них є діти?) — «Imaju sina, mog bratića Oleha. I on radi ovdje.» (У них є син, мій двоюрідний брат Олег. Він теж тут працює.).', (select id from public.lessons where id = 'cec08ff0-a97d-5847-88cc-dee22fed2f8c'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a88d7537-adca-5151-a3bf-83405d3b5141', v_aid, 8, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Je li cijepljen?', '["Це собака моєї сусідки. З учора нічого не їсть.", "Так, ось його книжечка щеплень.", "Добре. Зараз я його огляну."]'::jsonb, 1, null, '{}'::text[], null, 'Veterinarka: Dobar dan! Što se dogodilo Vašem psu?
Daša: To je pas moje susjede. Od jučer ne jede.
Veterinarka: Je li cijepljen?
Daša: Jest, evo njegove knjižice cijepljenja.
Veterinarka: Dobro. Sada ću ga pregledati.', 'Veterinarka: Добрий день! Що сталося з вашим собакою?
Daša: Це собака моєї сусідки. З учора нічого не їсть.
Veterinarka: Він щеплений?
Daša: Так, ось його книжечка щеплень.
Veterinarka: Добре. Зараз я його огляну.', 'Діалог «У ветеринара»: «Je li cijepljen?» — «Jest, evo njegove knjižice cijepljenja.», тобто «Так, ось його книжечка щеплень.».', (select id from public.lessons where id = '40b9da1d-1686-5b78-8317-0439067d5f8e'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2d388fc2-01c7-557c-9a04-5ec52a9a4801', v_aid, 9, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dašo, imaš li baku i djeda?', '["Четверо онуків і дві онучки.", "Так. Бабуся й дідусь живуть у Полтаві.", "Маю сина й доньку."]'::jsonb, 1, null, '{}'::text[], null, 'Marko: Dašo, imaš li baku i djeda?
Daša: Imam. Baka i djed žive u Poltavi.
Marko: Imaju li puno unuka?
Daša: Imaju četiri unuka i dvije unuke.
Marko: A ti, imaš li djecu?
Daša: Imam sina i kćer.', 'Marko: Дашо, у тебе є бабуся й дідусь?
Daša: Так. Бабуся й дідусь живуть у Полтаві.
Marko: У них багато онуків?
Daša: Четверо онуків і дві онучки.
Marko: А в тебе є діти?
Daša: Маю сина й доньку.', 'Діалог «Бабуся й дідусь»: «Dašo, imaš li baku i djeda?» — «Imam. Baka i djed žive u Poltavi.», тобто «Так. Бабуся й дідусь живуть у Полтаві.».', (select id from public.lessons where id = '4e003796-1ce0-5a02-8a2d-59a0de38f3dd'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4d465b82-d70b-5c2c-adc2-6096673a3565', v_aid, 10, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Чия це куртка?». Що ви скажете?', null, '["Jako sličiš mami.", "Čija je ovo jakna?", "Tko je to?"]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Чия це куртка?» — «Čija je ovo jakna?».', (select id from public.lessons where id = '18efed0f-53a5-5717-9c4e-319627da2360'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9d67ec6b-d2a9-5546-b322-0fb9ab6aa40b', v_aid, 11, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «У мене алергія на котів». Що ви скажете?', null, '["Imam alergiju na mačke.", "Ovo je moj bratić.", "Ona ima plave oči."]'::jsonb, 0, null, '{}'::text[], null, null, null, '«У мене алергія на котів.» — «Imam alergiju na mačke.».', (select id from public.lessons where id = '40b9da1d-1686-5b78-8317-0439067d5f8e'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a9395507-ab61-5582-a12f-322d4d1281cb', v_aid, 12, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «рибка»', null, '[]'::jsonb, null, 'ribica', '{}'::text[], null, null, null, '«рибка» — ribica.', (select id from public.lessons where id = '40b9da1d-1686-5b78-8317-0439067d5f8e'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a938f1c2-4af9-509c-ac0d-07183fd3e0bf', v_aid, 13, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Моя кішка спить цілий день.»', null, '["spava", "cijeli", "dan.", "mačka", "Moja"]'::jsonb, null, 'Moja mačka spava cijeli dan.', array['Moja mačka cijeli dan spava.']::text[], null, null, null, '«Моя кішка спить цілий день.» — «Moja mačka spava cijeli dan.».', (select id from public.lessons where id = '40b9da1d-1686-5b78-8317-0439067d5f8e'), 'PUBLISHED', 'claude_assessment_v5'),
  ('0f5ed4c9-392f-5f17-a1d7-c7f571135956', v_aid, 14, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Це мій найкращий друг.»', null, '[]'::jsonb, null, 'Ovo je moj najbolji prijatelj.', '{}'::text[], null, null, null, '«Це мій найкращий друг.» — «Ovo je moj najbolji prijatelj.».', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A0. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A0.6 · Модуль A0.6 — Moj dom (мій дім) · 12 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-m06' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-m06 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = 'dd5bd3fc-caeb-5c69-b2ca-5e6dd09e2966') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from 'c65b21ca-4c8b-5b74-8b12-7014e57210db'::uuid then
    raise exception 'Тест a0-m06 прив’язаний не до модуля A0.6 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 12 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~6 хв.', estimated_minutes = 6 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('dd5bd3fc-caeb-5c69-b2ca-5e6dd09e2966', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Кухня вузька, але чиста й нова.", "Так. І вимкнув світло.", "Учора ввечері я прийшла додому тільки опівночі."]'::jsonb, 0, null, '{}'::text[], 'Kuhinja je uska, ali je čista i nova.', null, null, 'Прозвучало: «Kuhinja je uska, ali je čista i nova.» — «Кухня вузька, але чиста й нова.».', (select id from public.lessons where id = 'f51692d8-cb95-5f2e-8263-f3728f5e10c0'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c316742f-263c-5d5c-b7d9-a01e696e7ef2', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["І в нас. Улітку постійно працює кондиціонер.", "Так, дякую. Книжки — нагору, на полицю.", "На полиці над столом."]'::jsonb, 2, null, '{}'::text[], 'Na polici iznad stola.', null, null, 'Прозвучало: «Na polici iznad stola.» — «На полиці над столом.».', (select id from public.lessons where id = '1436c20e-0aea-550a-b66d-fb3149a1c2e2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('01d4b36a-5863-55db-a283-26e41f6dc9a5', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Які квартири в цьому під’їзді?', 'Natpis na ulazu u zgradu', '["1–12", "13–24", "Усі"]'::jsonb, 0, null, '{}'::text[], null, 'ULAZ B
Stanovi 1 – 12
Lift ne radi. Oprostite!
Molimo, zatvorite vrata.', 'ВХІД B
Квартири 1–12
Ліфт не працює. Вибачте!
Будь ласка, зачиняйте двері.', 'Текст «Табличка біля входу в будинок». Правильна відповідь: «1–12».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('183b3b64-3006-5a51-a4d5-b39bacb4490d', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Joj, žao mi je. Što se točno dogodilo?', '["Malo manje od četiri milijuna.", "Dođite najkasnije početkom veljače.", "Ne pali se. Mislim da je pokvarena."]'::jsonb, 2, null, '{}'::text[], 'Joj, žao mi je. Što se točno dogodilo?', null, null, 'Діалог «Не працює пральна машина»: «Joj, žao mi je. Što se točno dogodilo?» (Ой, мені шкода. Що саме сталося?) — «Ne pali se. Mislim da je pokvarena.» (Не вмикається. Думаю, вона зламалася.).', (select id from public.lessons where id = 'e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('12b11ac7-b3ac-5264-8d45-6b2008f74840', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Lijep je. Imate li i jastuke iste boje?', '["Broj sedam.", "Imamo, tamo pored ogledala.", "Na zapadu s Poljskom, Slovačkom i Mađarskom."]'::jsonb, 1, null, '{}'::text[], 'Lijep je. Imate li i jastuke iste boje?', null, null, 'Діалог «У меблевому магазині»: «Lijep je. Imate li i jastuke iste boje?» (Гарний. А подушки такого ж кольору у вас є?) — «Imamo, tamo pored ogledala.» (Є, он там біля дзеркала.).', (select id from public.lessons where id = '1436c20e-0aea-550a-b66d-fb3149a1c2e2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('153f0efc-d3b3-5f6b-8858-7af676962fb1', v_aid, 6, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Ima podrum. Kada se želite useliti?', '["Početkom sljedećeg mjeseca, ako može.", "Tramvaj broj šest. Šest!", "Večeras ne mogu, radim do ponoći."]'::jsonb, 0, null, '{}'::text[], 'Ima podrum. Kada se želite useliti?', null, null, 'Діалог «Огляд квартири»: «Ima podrum. Kada se želite useliti?» (Є підвал. Коли ви хочете заїхати?) — «Početkom sljedećeg mjeseca, ako može.» (На початку наступного місяця, якщо можна.).', (select id from public.lessons where id = '78f28f85-dd8b-5e81-8a52-1b2dbce4eb34'), 'PUBLISHED', 'claude_assessment_v5'),
  ('160490d0-fc4e-5253-a413-2a315b78db91', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Neću. Mama, gdje je moj punjač?', '["Добре. Не забудь замкнути двері!", "Я шукаю диван для вітальні.", "У твоєму рюкзаку. Ходімо, ми запізнюємося!"]'::jsonb, 2, null, '{}'::text[], null, 'Daša: Danilo, jesi li zatvorio prozor u kuhinji?
Danilo: Jesam. I ugasio sam svjetlo.
Daša: Dobro. Ne zaboravi zaključati vrata!
Danilo: Neću. Mama, gdje je moj punjač?
Daša: U tvom ruksaku. Idemo, kasnimo!', 'Daša: Даниле, ти зачинив вікно на кухні?
Danilo: Так. І вимкнув світло.
Daša: Добре. Не забудь замкнути двері!
Danilo: Не забуду. Мамо, де мій зарядний?
Daša: У твоєму рюкзаку. Ходімо, ми запізнюємося!', 'Діалог «Перед виходом»: «Neću. Mama, gdje je moj punjač?» — «U tvom ruksaku. Idemo, kasnimo!», тобто «У твоєму рюкзаку. Ходімо, ми запізнюємося!».', (select id from public.lessons where id = '0ecb6f19-2630-533d-9f1b-85102442af08'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b595891c-6cff-5559-a906-86a60648cf1a', v_aid, 8, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Jesi li pogledala u torbi?', '["Дякую! Я завжди їх десь залишаю.", "Так. Їх немає ні в сумці, ні в гаманці.", "Міє, ти бачила мої ключі? Не можу їх знайти!"]'::jsonb, 1, null, '{}'::text[], null, 'Daša: Mia, jesi li vidjela moje ključeve? Ne mogu ih naći!
Mia: Jesi li pogledala u torbi?
Daša: Jesam. Nisu ni u torbi ni u novčaniku.
Mia: Evo ih! Bili su na stolu, ispod novina.
Daša: Hvala! Uvijek ih negdje ostavim.', 'Daša: Міє, ти бачила мої ключі? Не можу їх знайти!
Mia: Ти дивилася в сумці?
Daša: Так. Їх немає ні в сумці, ні в гаманці.
Mia: Ось вони! Вони були на столі, під газетою.
Daša: Дякую! Я завжди їх десь залишаю.', 'Діалог «Де ключі?»: «Jesi li pogledala u torbi?» — «Jesam. Nisu ni u torbi ni u novčaniku.», тобто «Так. Їх немає ні в сумці, ні в гаманці.».', (select id from public.lessons where id = '0ecb6f19-2630-533d-9f1b-85102442af08'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4493f8fc-64a3-5eb5-92e7-f43c8f7db524', v_aid, 9, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Кімната маленька, але чиста». Що ви скажете?', null, '["Desno od vrata.", "Soba je mala, ali čista.", "Gdje su moje naočale?"]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Кімната маленька, але чиста.» — «Soba je mala, ali čista.».', (select id from public.lessons where id = 'f51692d8-cb95-5f2e-8263-f3728f5e10c0'), 'PUBLISHED', 'claude_assessment_v5'),
  ('452cab20-c37e-56eb-be06-9e1ba4400fcf', v_aid, 10, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «коридор»', null, '[]'::jsonb, null, 'hodnik', '{}'::text[], null, null, null, '«коридор» — hodnik.', (select id from public.lessons where id = '78f28f85-dd8b-5e81-8a52-1b2dbce4eb34'), 'PUBLISHED', 'claude_assessment_v5'),
  ('aadf71ea-7e89-5b62-b4a9-689631379d4a', v_aid, 11, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Квартира велика й світла.»', null, '["Stan", "velik", "je", "i", "svijetao."]'::jsonb, null, 'Stan je velik i svijetao.', '{}'::text[], null, null, null, '«Квартира велика й світла.» — «Stan je velik i svijetao.».', (select id from public.lessons where id = 'f51692d8-cb95-5f2e-8263-f3728f5e10c0'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5eff0154-0129-5b2f-b8b3-fe2aaa09a92f', v_aid, 12, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Де знаходиться ліфт?»', null, '[]'::jsonb, null, 'Gdje se nalazi lift?', '{}'::text[], null, null, null, '«Де знаходиться ліфт?» — «Gdje se nalazi lift?».', (select id from public.lessons where id = '32f5d97b-d6c0-57af-9e48-86f9ee9a932d'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A0. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A0.7 · Модуль A0.7 — Hrana (їжа) · 12 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-m07' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-m07 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '22d9f67e-c24d-547a-ae1d-9a5cdac40ce0') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '0d928777-015b-58ca-a55f-65892de684d0'::uuid then
    raise exception 'Тест a0-m07 прив’язаний не до модуля A0.7 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 12 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~6 хв.', estimated_minutes = 6 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('22d9f67e-c24d-547a-ae1d-9a5cdac40ce0', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Івано, я голодна. У тебе є щось на сніданок?", "Це був лише перекус! А коли ж ти обідаєш?", "Дашо, ти п’єш червоне чи біле вино?"]'::jsonb, 0, null, '{}'::text[], 'Ivana, gladna sam. Imaš li nešto za doručak?', null, null, 'Прозвучало: «Ivana, gladna sam. Imaš li nešto za doručak?» — «Івано, я голодна. У тебе є щось на сніданок?».', (select id from public.lessons where id = '7bbaf7ff-10bb-512a-91c5-798b59ec92a5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('24853c60-643e-5520-91e6-483880ab5e22', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Платите разом чи окремо?", "А яйце хочеш?", "Як тобі яловичина?"]'::jsonb, 1, null, '{}'::text[], 'Hoćeš li i jaje?', null, null, 'Прозвучало: «Hoćeš li i jaje?» — «А яйце хочеш?».', (select id from public.lessons where id = '7bbaf7ff-10bb-512a-91c5-798b59ec92a5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a4167be6-c678-5480-b2e6-8a769f74d3f1', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Скільки коштує чорний хліб?', 'U pekari', '["2,50 €", "1,20 €", "1,60 €"]'::jsonb, 2, null, '{}'::text[], null, 'SVJEŽI KRUH
Bijeli kruh 1,20 €
Crni kruh 1,60 €
Burek sa sirom 2,50 €
Ne dirajte, molim!', 'СВІЖИЙ ХЛІБ
Білий хліб 1,20 €
Чорний хліб 1,60 €
Бурек із сиром 2,50 €
Не чіпайте, будь ласка!', 'Текст «У пекарні». Правильна відповідь: «1,60 €».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('655938c8-97ab-5644-b31c-a27389512cd4', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Ja ne jedem ni meso ni ribu. Imate li nešto za vegetarijance?', '["Imamo tjesteninu s povrćem.", "Iz Ukrajine. Rodom sam iz Odese.", "Devedeset drugo."]'::jsonb, 0, null, '{}'::text[], 'Ja ne jedem ni meso ni ribu. Imate li nešto za vegetarijance?', null, null, 'Діалог «Вечеря в коноби»: «Ja ne jedem ni meso ni ribu. Imate li nešto za vegetarijance?» (Я не їм ні м’яса, ні риби. У вас є щось для вегетаріанців?) — «Imamo tjesteninu s povrćem.» (Є паста з овочами.).', (select id from public.lessons where id = 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('265cf6d9-ceba-5df0-bbfd-8989dd2650d9', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Hoćete li šlag?', '["Može. I jedan komad torte, molim.", "Ponekad sam lijena, ali učim svaki dan!", "To je pas moje susjede. Od jučer ne jede."]'::jsonb, 0, null, '{}'::text[], 'Hoćete li šlag?', null, null, 'Діалог «У кондитерській»: «Hoćete li šlag?» (Хочете збиті вершки?) — «Može. I jedan komad torte, molim.» (Можна. І шматок торта, будь ласка.).', (select id from public.lessons where id = 'c9e045fb-91ff-52a2-9916-1b698d30eb19'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6e77294c-4b6f-5068-b856-68ad6052f137', v_aid, 6, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Imate li rezervaciju?', '["Kovalenko. Prvo slovo je K. Izvolite moju posjetnicu.", "Zimi oko sto pedeset eura, zbog grijanja.", "Nemamo, nažalost."]'::jsonb, 2, null, '{}'::text[], 'Imate li rezervaciju?', null, null, 'Діалог «Столик на двох»: «Imate li rezervaciju?» (Ви бронювали?) — «Nemamo, nažalost.» (На жаль, ні.).', (select id from public.lessons where id = '8b30911e-4e57-5648-9ff6-bd11c1b0e27e'), 'PUBLISHED', 'claude_assessment_v5'),
  ('38b0ff08-67d7-5fe4-a9d6-738ff54140e4', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dašo, ideš li na ručak?', '["Я не голодна. О десятій я з’їла сендвіч.", "Гаразд, іду. Але після обіду я буду сита!", "Їсти тричі на день — важливо. Ходімо зі мною!"]'::jsonb, 0, null, '{}'::text[], null, 'Marko: Dašo, ideš li na ručak?
Daša: Nisam gladna. U deset sam pojela sendvič.
Marko: To je bila samo užina! Kada onda ručaš?
Daša: Obično ne ručam. Navečer večeram s obitelji.
Marko: Tri obroka dnevno su važna. Hajde sa mnom!
Daša: Dobro, idem. Ali poslije ručka bit ću sita!', 'Marko: Дашо, ти йдеш на обід?
Daša: Я не голодна. О десятій я з’їла сендвіч.
Marko: Це був лише перекус! А коли ж ти обідаєш?
Daša: Зазвичай я не обідаю. Увечері вечеряю з сім’єю.
Marko: Їсти тричі на день — важливо. Ходімо зі мною!
Daša: Гаразд, іду. Але після обіду я буду сита!', 'Діалог «Обідня перерва»: «Dašo, ideš li na ručak?» — «Nisam gladna. U deset sam pojela sendvič.», тобто «Я не голодна. О десятій я з’їла сендвіч.».', (select id from public.lessons where id = '7bbaf7ff-10bb-512a-91c5-798b59ec92a5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('af299d1b-2d52-5a1a-b663-b8341e18fce3', v_aid, 8, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Ukupno šezdeset eura. Je li sve bilo u redu?', '["Усе було чудово, дякую. Решта — вам.", "Перепрошую, рахунок, будь ласка!", "Разом. Сьогодні я пригощаю!"]'::jsonb, 0, null, '{}'::text[], null, 'Daša: Oprostite, molim račun!
Konobar: Plaćate li zajedno ili odvojeno?
Darja: Zajedno. Danas ja častim!
Konobar: Ukupno šezdeset eura. Je li sve bilo u redu?
Darja: Sve je bilo izvrsno, hvala. Ostatak je za vas.
Konobar: Hvala lijepa na napojnici! Laku noć.', 'Daša: Перепрошую, рахунок, будь ласка!
Konobar: Платите разом чи окремо?
Darja: Разом. Сьогодні я пригощаю!
Konobar: Разом шістдесят євро. Усе було добре?
Darja: Усе було чудово, дякую. Решта — вам.
Konobar: Щиро дякую за чайові! На добраніч.', 'Діалог «Рахунок»: «Ukupno šezdeset eura. Je li sve bilo u redu?» — «Sve je bilo izvrsno, hvala. Ostatak je za vas.», тобто «Усе було чудово, дякую. Решта — вам.».', (select id from public.lessons where id = '8b30911e-4e57-5648-9ff6-bd11c1b0e27e'), 'PUBLISHED', 'claude_assessment_v5'),
  ('32755d81-76fa-501b-98d8-7d56cbcab07a', v_aid, 9, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Каву з собою, будь ласка». Що ви скажете?', null, '["Kavu za van, molim.", "Živjeli!", "Molim račun."]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Каву з собою, будь ласка.» — «Kavu za van, molim.».', (select id from public.lessons where id = 'c9e045fb-91ff-52a2-9916-1b698d30eb19'), 'PUBLISHED', 'claude_assessment_v5'),
  ('33504574-da05-5530-a4d3-6983e220293c', v_aid, 10, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «сендвіч»', null, '[]'::jsonb, null, 'sendvič', '{}'::text[], null, null, null, '«сендвіч» — sendvič.', (select id from public.lessons where id = '7bbaf7ff-10bb-512a-91c5-798b59ec92a5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ea91e254-0fe2-5d2b-9e94-5e1c1a3c4b64', v_aid, 11, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я не їм м’яса.»', null, '["jedem", "meso.", "Ne"]'::jsonb, null, 'Ne jedem meso.', array['Meso ne jedem.']::text[], null, null, null, '«Я не їм м’яса.» — «Ne jedem meso.».', (select id from public.lessons where id = 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a9af6a83-0b79-5547-bd2f-41c1de9d3cfe', v_aid, 12, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Що на вечерю?»', null, '[]'::jsonb, null, 'Što je za večeru?', '{}'::text[], null, null, null, '«Що на вечерю?» — «Što je za večeru?».', (select id from public.lessons where id = '7bbaf7ff-10bb-512a-91c5-798b59ec92a5'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A0. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A0.8 · Модуль A0.8 — Kupovina (покупки) · 12 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-m08' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-m08 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '0611c4d5-5441-5bf1-a3b5-867225df9641') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '3fbf61ad-1d1b-5447-8c67-5896b1cc1f59'::uuid then
    raise exception 'Тест a0-m08 прив’язаний не до модуля A0.8 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 12 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~6 хв.', estimated_minutes = 6 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('0611c4d5-5441-5bf1-a3b5-867225df9641', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Добрий день, прошу.", "Мені потрібні шкарпетки й теплий светр.", "Так, літр молока й хліб із пекарні."]'::jsonb, 1, null, '{}'::text[], 'Trebam čarape i topli džemper.', null, null, 'Прозвучало: «Trebam čarape i topli džemper.» — «Мені потрібні шкарпетки й теплий светр.».', (select id from public.lessons where id = 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0'), 'PUBLISHED', 'claude_assessment_v5'),
  ('da755511-fcef-5e51-8279-4d96183cc5c3', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Можна пів кіло помідорів і трохи часнику.", "Завтра не можу. Зідзвонимося!", "Я б краще обміняла її на менший розмір."]'::jsonb, 0, null, '{}'::text[], 'Može pola kile rajčica i malo češnjaka.', null, null, 'Прозвучало: «Može pola kile rajčica i malo češnjaka.» — «Можна пів кіло помідорів і трохи часнику.».', (select id from public.lessons where id = 'e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0'), 'PUBLISHED', 'claude_assessment_v5'),
  ('10b82da8-2be8-56db-aa2e-03121995b73e', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Де фрукти й овочі?', 'Odjeli u trgovini', '["Ліворуч", "Праворуч", "Прямо"]'::jsonb, 0, null, '{}'::text[], null, 'Voće i povrće ←
Mlijeko i sir →
Pića →
Kruh ↑
WC i izlaz ↓', 'Фрукти й овочі ←
Молоко й сир →
Напої →
Хліб ↑
Туалет і вихід ↓', 'Текст «Відділи магазину». Правильна відповідь: «Ліворуч».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('3d102e02-0fb3-5f2a-80ae-834b50d56156', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koju veličinu nosite?', '["Trideset osam. Ove su mi prevelike.", "Loše. Boli me glava i hladno mi je.", "U Ukrajini sam bila inženjerka."]'::jsonb, 0, null, '{}'::text[], 'Koju veličinu nosite?', null, null, 'Діалог «У магазині одягу»: «Koju veličinu nosite?» (Який розмір ви носите?) — «Trideset osam. Ove su mi prevelike.» (Тридцять восьмий. Ці мені завеликі.).', (select id from public.lessons where id = 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a311ce48-48db-5bd2-85a2-ed37001d2715', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Je li jedno pakiranje kave dosta?', '["Ovaj ima pedeset kvadrata i košta dvjesto pedeset tisuća eura.", "Dosta je. Hvala ti!", "Broj sedam."]'::jsonb, 1, null, '{}'::text[], 'Je li jedno pakiranje kave dosta?', null, null, 'Діалог «Список покупок»: «Je li jedno pakiranje kave dosta?» (Однієї пачки кави вистачить?) — «Dosta je. Hvala ti!» (Вистачить. Дякую тобі!).', (select id from public.lessons where id = '0e925295-2766-5931-b031-2412682bc6f8'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d8acb290-0ca8-5c04-a3b0-3df6bb2fec40', v_aid, 6, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koja ti se jakna više sviđa, ova ili ona?', '["Ona crna. Ova je premalena za tebe.", "Sedamdeset dva, devedeset jedan.", "Volim proljeće, posebno travanj i svibanj."]'::jsonb, 0, null, '{}'::text[], 'Koja ti se jakna više sviđa, ova ili ona?', null, null, 'Діалог «Ця чи та?»: «Koja ti se jakna više sviđa, ova ili ona?» (Яка куртка тобі більше подобається, ця чи он та?) — «Ona crna. Ova je premalena za tebe.» (Он та чорна. Ця тобі замала.).', (select id from public.lessons where id = 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0'), 'PUBLISHED', 'claude_assessment_v5'),
  ('84b3c604-19bc-5c86-af2b-8a8f8711ca68', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Lijepa je, ali tražim jednobojnu. Imate li tamnoplavu?', '["Є біла й оця в смужку.", "На жаль, лише чорна й сіра.", "Шукаю сорочку для роботи, білу чи блакитну."]'::jsonb, 1, null, '{}'::text[], null, 'Prodavač: Tražite li nešto određeno?
Daša: Tražim košulju za posao, bijelu ili svijetloplavu.
Prodavač: Imamo bijelu i ovu na pruge.
Daša: Lijepa je, ali tražim jednobojnu. Imate li tamnoplavu?
Prodavač: Nažalost, samo crnu i sivu.
Daša: Onda uzimam bijelu.', 'Prodavač: Шукаєте щось конкретне?
Daša: Шукаю сорочку для роботи, білу чи блакитну.
Prodavač: Є біла й оця в смужку.
Daša: Гарна, але я шукаю однотонну. Темно-синя є?
Prodavač: На жаль, лише чорна й сіра.
Daša: Тоді беру білу.', 'Діалог «Сорочка для роботи»: «Lijepa je, ali tražim jednobojnu. Imate li tamnoplavu?» — «Nažalost, samo crnu i sivu.», тобто «На жаль, лише чорна й сіра.».', (select id from public.lessons where id = '288e7610-99c8-5696-989a-86f60ce38b0a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('67fcc0d2-de1f-5fb4-913b-c45387ded821', v_aid, 8, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Karticom. Može li beskontaktno?', '["Можна. Прикладіть картку сюди.", "Так, один, будь ласка.", "Готово. Дякую, до побачення!"]'::jsonb, 0, null, '{}'::text[], null, 'Blagajnica: Dobar dan. Trebate li vrećicu?
Daša: Da, jednu, molim.
Blagajnica: Ukupno dvadeset tri eura. Karticom ili gotovinom?
Daša: Karticom. Može li beskontaktno?
Blagajnica: Može. Prislonite karticu ovdje.
Daša: Gotovo. Hvala, doviđenja!', 'Blagajnica: Добрий день. Вам потрібен пакет?
Daša: Так, один, будь ласка.
Blagajnica: Разом двадцять три євро. Карткою чи готівкою?
Daša: Карткою. Можна безконтактно?
Blagajnica: Можна. Прикладіть картку сюди.
Daša: Готово. Дякую, до побачення!', 'Діалог «Карткою чи готівкою?»: «Karticom. Može li beskontaktno?» — «Može. Prislonite karticu ovdje.», тобто «Можна. Прикладіть картку сюди.».', (select id from public.lessons where id = '28913ad6-490f-5d89-bad7-9b303c673fcd'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6c3ee312-9df0-50de-8881-a6e99b4922f6', v_aid, 9, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Кілограм помідорів, будь ласка». Що ви скажете?', null, '["Kilu rajčica, molim.", "Još nešto?", "Dogovoreno!"]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Кілограм помідорів, будь ласка.» — «Kilu rajčica, molim.».', (select id from public.lessons where id = 'e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f9194672-9a42-5bec-93eb-779f4ae141bd', v_aid, 10, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «надто; забагато»', null, '[]'::jsonb, null, 'previše', '{}'::text[], null, null, null, '«надто; забагато» — previše.', (select id from public.lessons where id = '6836e57c-030c-59f8-9818-b44c08b126a6'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7a5ac733-abc6-537b-b01f-1a77b7e907aa', v_aid, 11, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Можна дешевше?»', null, '["li", "Može", "jeftinije?"]'::jsonb, null, 'Može li jeftinije?', '{}'::text[], null, null, null, '«Можна дешевше?» — «Može li jeftinije?».', (select id from public.lessons where id = '6836e57c-030c-59f8-9818-b44c08b126a6'), 'PUBLISHED', 'claude_assessment_v5'),
  ('32098364-39c9-5420-95c8-c354e64b1493', v_aid, 12, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Я люблю чорний колір.»', null, '[]'::jsonb, null, 'Volim crnu boju.', '{}'::text[], null, null, null, '«Я люблю чорний колір.» — «Volim crnu boju.».', (select id from public.lessons where id = '288e7610-99c8-5696-989a-86f60ce38b0a'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A0. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A0.9 · Модуль A0.9 — Grad (місто) · 12 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-m09' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-m09 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '00a048c6-5951-5dd5-83bf-14b8234a3d2b') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '5dec9cd3-0f02-5fc1-b8ef-8bec96b7ade8'::uuid then
    raise exception 'Тест a0-m09 прив’язаний не до модуля A0.9 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 12 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~6 хв.', estimated_minutes = 6 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('00a048c6-5951-5dd5-83bf-14b8234a3d2b', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Добрий вечір, куди їдемо?", "Перепрошую, як дістатися до вокзалу?", "Скільки триває поїздка?"]'::jsonb, 2, null, '{}'::text[], 'Koliko traje putovanje?', null, null, 'Прозвучало: «Koliko traje putovanje?» — «Скільки триває поїздка?».', (select id from public.lessons where id = 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('49439dc1-545f-515c-b00f-ef8e7b15d9b2', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Поруч із банком. А за площею — міська бібліотека.", "Давай. Потім можна в басейн або в парк.", "Мені треба купити сувенір для мами."]'::jsonb, 1, null, '{}'::text[], 'Može. Poslije možemo na bazen ili u park.', null, null, 'Прозвучало: «Može. Poslije možemo na bazen ili u park.» — «Давай. Потім можна в басейн або в парк.».', (select id from public.lessons where id = '0addd5be-230b-582f-baed-a5d18eb1d619'), 'PUBLISHED', 'claude_assessment_v5'),
  ('803b68a7-5008-5d8b-9419-93517b3919ce', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Що означає «IZLAZ»?', 'Na kolodvoru', '["Вхід", "Каса", "Вихід"]'::jsonb, 2, null, '{}'::text[], null, 'ULAZ
IZLAZ
BLAGAJNA – karte
PERONI 1 – 5
ČEKAONICA
WC', 'ВХІД
ВИХІД
КАСА – квитки
ПЛАТФОРМИ 1–5
ЗАЛ ОЧІКУВАННЯ
ТУАЛЕТ', 'Текст «На вокзалі». Правильна відповідь: «Вихід».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('6d861e8f-39dc-5a64-9419-c32a161becb2', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Je li muzej na uglu?', '["Da, odmah iza ugla. Ne možete ga promašiti.", "Za mene veliko točeno pivo.", "Broj sedam."]'::jsonb, 0, null, '{}'::text[], 'Je li muzej na uglu?', null, null, 'Діалог «Дар’я показує дорогу»: «Je li muzej na uglu?» (Музей на розі?) — «Da, odmah iza ugla. Ne možete ga promašiti.» (Так, одразу за рогом. Не пропустите.).', (select id from public.lessons where id = '55af257e-e4d1-51ed-9637-388a7e0b4baf'), 'PUBLISHED', 'claude_assessment_v5'),
  ('96ef24cb-dc8c-506b-b9a8-dcdbdf307488', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Prekrasan pogled! Koja je ono visoka kula?', '["To je najpoznatija kula u gradu. Ima dugu povijest.", "U Ukrajini sam bila inženjerka.", "U kolovozu, prva dva tjedna."]'::jsonb, 0, null, '{}'::text[], 'Prekrasan pogled! Koja je ono visoka kula?', null, null, 'Діалог «На оглядовому майданчику»: «Prekrasan pogled! Koja je ono visoka kula?» (Чудовий вид! Що це за висока вежа?) — «To je najpoznatija kula u gradu. Ima dugu povijest.» (Це найвідоміша вежа в місті. У неї довга історія.).', (select id from public.lessons where id = '1e0384e5-6097-56ed-ab56-cf530f02ab73'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5dd16c8e-a1d4-5d50-9c4a-60acd7596db0', v_aid, 6, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Ima li gužve u ovo doba?', '["Večeras ne mogu, radim do ponoći.", "Na drugom katu, treća vrata lijevo.", "Malo, ali znam kraći put."]'::jsonb, 2, null, '{}'::text[], 'Ima li gužve u ovo doba?', null, null, 'Діалог «У таксі»: «Ima li gužve u ovo doba?» (О цій порі є затори?) — «Malo, ali znam kraći put.» (Трохи, але я знаю коротший шлях.).', (select id from public.lessons where id = 'e0b9d742-0418-597b-9482-b6e2d82469da'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d1a613b1-0148-597a-b7d8-b14547a9f897', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Ivane, ja sam nova u ovom naselju. Što ima u blizini?', '["О чотирнадцятій тридцять, з п’ятого перону.", "Є, у торговому центрі, між кінотеатром і супермаркетом.", "Пошта й банк — на площі, за п’ять хвилин звідси."]'::jsonb, 2, null, '{}'::text[], null, 'Daša: Ivane, ja sam nova u ovom naselju. Što ima u blizini?
Ivan: Pošta i banka su na trgu, pet minuta odavde.
Daša: Super. A gdje je najbliža mjenjačnica?
Ivan: Pored banke. Iza trga je i gradska knjižnica.
Daša: Odlično! Ima li ovdje negdje teretana?
Ivan: Ima, u trgovačkom centru, između kina i supermarketa.', 'Daša: Іване, я нова в цьому районі. Що тут є поблизу?
Ivan: Пошта й банк — на площі, за п’ять хвилин звідси.
Daša: Супер. А де найближчий обмін валют?
Ivan: Поруч із банком. А за площею — міська бібліотека.
Daša: Чудово! А тренажерний зал тут десь є?
Ivan: Є, у торговому центрі, між кінотеатром і супермаркетом.', 'Діалог «Що є поблизу?»: «Ivane, ja sam nova u ovom naselju. Što ima u blizini?» — «Pošta i banka su na trgu, pet minuta odavde.», тобто «Пошта й банк — на площі, за п’ять хвилин звідси.».', (select id from public.lessons where id = '0addd5be-230b-582f-baed-a5d18eb1d619'), 'PUBLISHED', 'claude_assessment_v5'),
  ('70578b05-8db9-5d4a-85c0-a69b8b23f765', v_aid, 8, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Smijem li fotografirati u katedrali?', '["О десятій, біля фонтана на головній площі.", "Можна, але без спалаху.", "Собор, старий палац і міські мури."]'::jsonb, 1, null, '{}'::text[], null, 'Daša: Dobar dan, kada počinje obilazak starog grada?
Vodič: U deset sati, kod fontane na glavnom trgu.
Daša: Što ćemo vidjeti?
Vodič: Katedralu, staru palaču i gradske zidine.
Daša: Smijem li fotografirati u katedrali?
Vodič: Možete, ali bez bljeskalice.', 'Daša: Добрий день, коли починається екскурсія старим містом?
Vodič: О десятій, біля фонтана на головній площі.
Daša: Що ми побачимо?
Vodič: Собор, старий палац і міські мури.
Daša: Можна фотографувати в соборі?
Vodič: Можна, але без спалаху.', 'Діалог «Екскурсія старим містом»: «Smijem li fotografirati u katedrali?» — «Možete, ali bez bljeskalice.», тобто «Можна, але без спалаху.».', (select id from public.lessons where id = '1e0384e5-6097-56ed-ab56-cf530f02ab73'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d0ba9747-02fc-561d-a363-ce42ac8555e6', v_aid, 9, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я живу поруч із парком». Що ви скажете?', null, '["Koji autobus ide u centar?", "Živim pored parka.", "Idemo u kino!"]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Я живу поруч із парком.» — «Živim pored parka.».', (select id from public.lessons where id = '0addd5be-230b-582f-baed-a5d18eb1d619'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1524ec19-63df-5c68-af19-f8f2c54f49e4', v_aid, 10, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «церква»', null, '[]'::jsonb, null, 'crkva', '{}'::text[], null, null, null, '«церква» — crkva.', (select id from public.lessons where id = '1e0384e5-6097-56ed-ab56-cf530f02ab73'), 'PUBLISHED', 'claude_assessment_v5'),
  ('252c831b-7af4-5d1c-bae3-19137070959f', v_aid, 11, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Пошта навпроти банку.»', null, '["banke.", "Pošta", "puta", "je", "preko"]'::jsonb, null, 'Pošta je preko puta banke.', array['Preko puta banke je pošta.']::text[], null, null, null, '«Пошта навпроти банку.» — «Pošta je preko puta banke.».', (select id from public.lessons where id = '55af257e-e4d1-51ed-9637-388a7e0b4baf'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4bc396f3-06f5-53c6-8b8e-2751385cba61', v_aid, 12, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Викличте мені таксі, будь ласка.»', null, '[]'::jsonb, null, 'Pozovite mi taksi, molim vas.', '{}'::text[], null, null, null, '«Викличте мені таксі, будь ласка.» — «Pozovite mi taksi, molim vas.».', (select id from public.lessons where id = 'e0b9d742-0418-597b-9482-b6e2d82469da'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A0. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A0.10 · Модуль A0.10 — Survival Croatian (виживання) · 14 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-m10' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-m10 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = 'b702196b-a0a8-5ab3-a813-f86273b92b9c') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '588b0086-831d-5577-b992-b00f68e9dd87'::uuid then
    raise exception 'Тест a0-m10 прив’язаний не до модуля A0.10 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 14 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~7 хв.', estimated_minutes = 7 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('b702196b-a0a8-5ab3-a813-f86273b92b9c', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Разом двадцять три євро. Карткою чи готівкою?", "Дашо, скільки буде сім помножити на вісім?", "У вас є всі документи й квитанція про сплату збору?"]'::jsonb, 2, null, '{}'::text[], 'Imate li sve dokumente i uplatnicu za pristojbu?', null, null, 'Прозвучало: «Imate li sve dokumente i uplatnicu za pristojbu?» — «У вас є всі документи й квитанція про сплату збору?».', (select id from public.lessons where id = '19df3241-90f3-5450-94ac-642d79fb2869'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2cc68b00-727f-51cb-bca2-a18680e32516', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["І лікоть болить, коли піднімаю руку.", "Дашо, що з тобою? Ти виглядаєш утомленою.", "Так, я відкрию вам лікарняний. Ось рецепт на сироп."]'::jsonb, 2, null, '{}'::text[], 'Da, otvorit ću vam bolovanje. Evo recepta za sirup.', null, null, 'Прозвучало: «Da, otvorit ću vam bolovanje. Evo recepta za sirup.» — «Так, я відкрию вам лікарняний. Ось рецепт на сироп.».', (select id from public.lessons where id = 'fbc71f82-e715-5bab-a990-b8542fb0fe01'), 'PUBLISHED', 'claude_assessment_v5'),
  ('be8aa5e4-26c9-5372-8f1a-a8d3068cb74c', v_aid, 3, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Покажи. Тут болить?", "Що у вас украли?", "Мені треба вписати й OIB?"]'::jsonb, 0, null, '{}'::text[], 'Pokaži mi. Boli li te ovdje?', null, null, 'Прозвучало: «Pokaži mi. Boli li te ovdje?» — «Покажи. Тут болить?».', (select id from public.lessons where id = '599fba4f-4cee-5a88-9f9b-5ce32a445554'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2f37ba60-228a-5bbb-809f-43b3982cd273', v_aid, 4, 'A0', 'reading', 'understand', 'multiple_choice', 'Який номер для всіх екстрених випадків?', 'Ljekarna i hitni brojevi', '["102", "112", "911"]'::jsonb, 1, null, '{}'::text[], null, 'LJEKARNA
Otvoreno 0 – 24 h
HITNA POMOĆ: 194
Policija: 192
Vatrogasci: 193
Svi hitni slučajevi: 112', 'АПТЕКА
Відчинено цілодобово (0–24)
ШВИДКА ДОПОМОГА: 194
Поліція: 192
Пожежники: 193
Усі екстрені випадки: 112', 'Текст «Аптека і екстрені номери». Правильна відповідь: «112».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('5e3bf88e-af90-51bd-b0c5-de0da755e8af', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Naravno. Kamo trebate ići?', '["Do hotela Park, ali mobitel mi se ugasio.", "Mala je, ali lijepa. Ima krevet, ormar i radni stol.", "Jesu, iz Slavonije. Probajte jednu."]'::jsonb, 0, null, '{}'::text[], 'Naravno. Kamo trebate ići?', null, null, 'Діалог «Я заблукав»: «Naravno. Kamo trebate ići?» (Звісно. Куди вам треба?) — «Do hotela Park, ali mobitel mi se ugasio.» (До готелю «Парк», але в мене вимкнувся телефон.).', (select id from public.lessons where id = '48f26e9d-96c5-5189-8ec6-db1f9d58e200'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9e85413a-c2d2-50b3-9061-ea279a663771', v_aid, 6, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Da. Je li doručak uključen u cijenu?', '["Tvrd je, ali je unutra prostran.", "Jest, od sedam do deset. Trebam vašu putovnicu za prijavu.", "Šestica, ali moraš presjesti na trgu."]'::jsonb, 1, null, '{}'::text[], 'Da. Je li doručak uključen u cijenu?', null, null, 'Діалог «На рецепції»: «Da. Je li doručak uključen u cijenu?» (Так. Сніданок входить у вартість?) — «Jest, od sedam do deset. Trebam vašu putovnicu za prijavu.» (Так, із сьомої до десятої. Мені потрібен ваш паспорт для реєстрації.).', (select id from public.lessons where id = 'edbae9ca-c4f4-575d-b876-d50b0a1fd9b5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('64baaa16-c432-5e60-84ef-f252751da479', v_aid, 7, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje se to dogodilo?', '["U tramvaju. Bila je gužva i odjednom je novčanik nestao.", "Moj dečko Petar. Vjenčanje je u lipnju.", "Točno! Bravo."]'::jsonb, 0, null, '{}'::text[], 'Gdje se to dogodilo?', null, null, 'Діалог «Крадіжка в трамваї»: «Gdje se to dogodilo?» (Де це сталося?) — «U tramvaju. Bila je gužva i odjednom je novčanik nestao.» (У трамваї. Була тіснява, і раптом гаманець зник.).', (select id from public.lessons where id = 'd2689a70-cb73-515f-9d81-6bb0f0fc1cff'), 'PUBLISHED', 'claude_assessment_v5'),
  ('8591b765-7724-518b-afbf-0390de61edb4', v_aid, 8, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Jeste li vidjeli lopova?', '["Я його погано бачила. Він був високий, у чорній шапці.", "Один чоловік увесь час стояв біля мене.", "Дякую. Сподіваюся, ви його знайдете."]'::jsonb, 0, null, '{}'::text[], null, 'Policajka: Jeste li vidjeli lopova?
Darja: Nisam ga dobro vidjela. Bio je visok, s crnom kapom.
Policajka: Je li bio netko sumnjiv u blizini?
Darja: Jedan muškarac je stajao uz mene cijelo vrijeme.
Policajka: Dobro. U tramvaju ima kamera. Evo zapisnika, potpišite ovdje.
Darja: Hvala. Nadam se da ćete ga naći.', 'Policajka: Ви бачили злодія?
Darja: Я його погано бачила. Він був високий, у чорній шапці.
Policajka: Чи був хтось підозрілий поблизу?
Darja: Один чоловік увесь час стояв біля мене.
Policajka: Добре. У трамваї є камери. Ось протокол, підпишіть тут.
Darja: Дякую. Сподіваюся, ви його знайдете.', 'Діалог «Свідок»: «Jeste li vidjeli lopova?» — «Nisam ga dobro vidjela. Bio je visok, s crnom kapom.», тобто «Я його погано бачила. Він був високий, у чорній шапці.».', (select id from public.lessons where id = 'd2689a70-cb73-515f-9d81-6bb0f0fc1cff'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b7dbb0e1-e9dd-5833-a542-5ea4f30c7eb5', v_aid, 9, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Hvala. Koja je lozinka za Wi-Fi?', '["Можемо дати вам інший номер, з видом на двір.", "Він написаний на картці біля ліжка.", "Перепрошую, у номері немає ні рушника, ні мила."]'::jsonb, 1, null, '{}'::text[], null, 'Darja: Oprostite, u sobi nema ručnika ni sapuna.
Marko: Ispričavam se! Odmah ću vam ih donijeti.
Darja: Hvala. Koja je lozinka za Wi-Fi?
Marko: Piše na kartici pored kreveta.
Darja: I još nešto: sef ne radi, a s ulice se čuje velika buka.
Marko: Možemo vam dati drugu sobu, s pogledom na dvorište.', 'Darja: Перепрошую, у номері немає ні рушника, ні мила.
Marko: Перепрошую! Зараз вам їх принесу.
Darja: Дякую. Який пароль від Wi-Fi?
Marko: Він написаний на картці біля ліжка.
Darja: І ще одне: сейф не працює, а з вулиці дуже шумно.
Marko: Можемо дати вам інший номер, з видом на двір.', 'Діалог «Проблема в номері»: «Hvala. Koja je lozinka za Wi-Fi?» — «Piše na kartici pored kreveta.», тобто «Він написаний на картці біля ліжка.».', (select id from public.lessons where id = 'edbae9ca-c4f4-575d-b876-d50b0a1fd9b5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('fdb94a10-cd48-581d-8f1e-bb10568ca8a3', v_aid, 10, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «У мене болить живіт». Що ви скажете?', null, '["Mogu li ostaviti stvari na recepciji?", "Ukrali su mi novčanik.", "Boli me trbuh."]'::jsonb, 2, null, '{}'::text[], null, null, null, '«У мене болить живіт.» — «Boli me trbuh.».', (select id from public.lessons where id = '599fba4f-4cee-5a88-9f9b-5ce32a445554'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6fcfd53a-512e-5916-a08d-16924c660781', v_aid, 11, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «У мене болять ноги». Що ви скажете?', null, '["Bole me noge.", "Upomoć! Trebam pomoć!", "Gdje mogu uplatiti pristojbu?"]'::jsonb, 0, null, '{}'::text[], null, null, null, '«У мене болять ноги.» — «Bole me noge.».', (select id from public.lessons where id = '599fba4f-4cee-5a88-9f9b-5ce32a445554'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b7f828f4-8a56-5eaf-a8cd-c790dfd58f30', v_aid, 12, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «заповнити»', null, '[]'::jsonb, null, 'ispuniti', '{}'::text[], null, null, null, '«заповнити» — ispuniti.', (select id from public.lessons where id = 'b095637e-0644-507e-8f3d-d323483dd3e4'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6d09cfed-65fc-50c7-8a9f-fcf07d9a7a7c', v_aid, 13, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я хочу подати заяву.»', null, '["predati", "Želim", "zahtjev."]'::jsonb, null, 'Želim predati zahtjev.', '{}'::text[], null, null, null, '«Я хочу подати заяву.» — «Želim predati zahtjev.».', (select id from public.lessons where id = '19df3241-90f3-5450-94ac-642d79fb2869'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5b4fed7c-f17b-54f5-8d8d-e447dd7186f3', v_aid, 14, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «У мене бронювання.»', null, '[]'::jsonb, null, 'Imam rezervaciju.', '{}'::text[], null, null, null, '«У мене бронювання.» — «Imam rezervaciju.».', (select id from public.lessons where id = 'edbae9ca-c4f4-575d-b876-d50b0a1fd9b5'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A0. Потрібна перевірка носієм.');
end $$;

-- Перевірка середини рівня A0 · 30 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-mid' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-mid — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '8a44179d-0268-52a2-ad80-51b76bdddd47') then return; end if;  -- уже оновлено
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Середина рівня (модулі A0.1–A0.5): 30 завдань на 4 навички. ~15 хв.', estimated_minutes = 15 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('8a44179d-0268-52a2-ad80-51b76bdddd47', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["П’ятдесят шість. У тебе завдання з математики?", "Добрий день. Скільки це коштує?", "А сто поділити на чотири?"]'::jsonb, 0, null, '{}'::text[], 'Pedeset šest. Imaš zadatak iz matematike?', null, null, 'Прозвучало: «Pedeset šest. Imaš zadatak iz matematike?» — «П’ятдесят шість. У тебе завдання з математики?».', (select id from public.lessons where id = 'ba35964d-f0d8-5d15-9566-ef44d37e6d12'), 'PUBLISHED', 'claude_assessment_v5'),
  ('76163bbb-b542-562c-b3bf-c92b286ad9fe', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Хорватія — у Європі, на Адріатичному морі.", "Ходімо! Тобі стане краще.", "Чудово. Тут усі дуже привітні."]'::jsonb, 0, null, '{}'::text[], 'Hrvatska je u Europi, na Jadranskom moru.', null, null, 'Прозвучало: «Hrvatska je u Europi, na Jadranskom moru.» — «Хорватія — у Європі, на Адріатичному морі.».', (select id from public.lessons where id = '479784bc-54ab-522d-9c77-55887ae68e33'), 'PUBLISHED', 'claude_assessment_v5'),
  ('fc43f4a4-45ed-51ba-8cf5-273cf0e88838', v_aid, 3, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Обов’язково. На добраніч!", "Перепрошую, я запізнююся на п’ять хвилин.", "Добре, дякую. Іду на роботу."]'::jsonb, 1, null, '{}'::text[], 'Ispričavam se, kasnim pet minuta.', null, null, 'Прозвучало: «Ispričavam se, kasnim pet minuta.» — «Перепрошую, я запізнююся на п’ять хвилин.».', (select id from public.lessons where id = 'e704760a-f743-5762-9c1a-027b10ca030a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('e1cb6ebd-b5c1-5b44-86a7-47999fb6334a', v_aid, 4, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Гарна традиція! Щасливого Різдва, Дашо!", "Сьогодні вранці я прокинулася о шостій.", "Сьогодні ввечері не можу, працюю до півночі."]'::jsonb, 1, null, '{}'::text[], 'Jutros sam se probudila u šest.', null, null, 'Прозвучало: «Jutros sam se probudila u šest.» — «Сьогодні вранці я прокинулася о шостій.».', (select id from public.lessons where id = '238d9508-3c2e-5ee6-910f-0ae8863c2dc7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('cfda04a4-ef3c-59f6-ab84-73e2a8f7bbc6', v_aid, 5, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Де ви познайомилися?", "Як ви ладнаєте?", "Він великий?"]'::jsonb, 1, null, '{}'::text[], 'Kako se slažete?', null, null, 'Прозвучало: «Kako se slažete?» — «Як ви ладнаєте?».', (select id from public.lessons where id = 'cec08ff0-a97d-5847-88cc-dee22fed2f8c'), 'PUBLISHED', 'claude_assessment_v5'),
  ('3c2cabbb-50a7-56a9-90ed-f3d4b22f5177', v_aid, 6, 'A0', 'reading', 'understand', 'multiple_choice', 'Чи працює кафе сьогодні?', 'Natpis na vratima kafića', '["Тільки вранці", "Ні, зачинено", "Так, до вечора"]'::jsonb, 1, null, '{}'::text[], null, 'ZATVORENO
Oprostite, danas ne radimo.
Vidimo se sutra!
Hvala!', 'ЗАЧИНЕНО
Вибачте, сьогодні ми не працюємо.
Побачимося завтра!
Дякуємо!', 'Текст «Табличка на дверях кафе». Правильна відповідь: «Ні, зачинено».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('2ebbbdbd-7efb-5ed2-aa92-83a3502c4f86', v_aid, 7, 'A0', 'reading', 'understand', 'multiple_choice', 'Як магазин прощається з покупцями?', 'Na vratima trgovine', '["Hvala i doviđenja!", "Dobro došli!", "Vidimo se sutra!"]'::jsonb, 0, null, '{}'::text[], null, 'DOBRO DOŠLI!
OTVORENO
Dobar dan! Izvolite.
Hvala i doviđenja!', 'ЛАСКАВО ПРОСИМО!
ВІДЧИНЕНО
Добрий день! Прошу, заходьте.
Дякуємо і до побачення!', 'Текст «На дверях магазину». Правильна відповідь: «Hvala i doviđenja!».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('2d7753c5-5256-559c-8d04-567cd34a2235', v_aid, 8, 'A0', 'reading', 'understand', 'multiple_choice', 'Де ліфт?', 'Sobe u hotelu', '["Ліфта немає", "Ліворуч", "Праворуч"]'::jsonb, 2, null, '{}'::text[], null, 'Sobe 1 – 10: prvi kat
Sobe 11 – 20: drugi kat
Recepcija: prizemlje
Lift je desno.', 'Номери 1–10: перший поверх (над входом)
Номери 11–20: другий поверх
Рецепція: партер (поверх біля входу)
Ліфт праворуч.', 'Текст «Номери в готелі». Правильна відповідь: «Праворуч».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('13c6ea49-6e15-5c65-bb62-35f520c56877', v_aid, 9, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koliko dugo traje vožnja?', '["Otprilike šest sati.", "Malo je ozbiljna, ali i smiješna. Svi je vole.", "Točno! Bravo."]'::jsonb, 0, null, '{}'::text[], 'Koliko dugo traje vožnja?', null, null, 'Діалог «На вокзалі»: «Koliko dugo traje vožnja?» (Скільки триває поїздка?) — «Otprilike šest sati.» (Приблизно шість годин.).', (select id from public.lessons where id = '8f6439a9-c6ac-5271-99c8-1f0adc5d7599'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2e403f2a-e2fe-518d-9f2a-a3d73be54098', v_aid, 10, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, tko je to na slici?', '["U devet sati.", "Broj dvadeset jedan, a ja imam trideset šest.", "To je moja obitelj. Ovo su moji roditelji."]'::jsonb, 2, null, '{}'::text[], 'Dašo, tko je to na slici?', null, null, 'Діалог «Сімейне фото»: «Dašo, tko je to na slici?» (Дашо, хто це на фото?) — «To je moja obitelj. Ovo su moji roditelji.» (Це моя сім’я. Це мої батьки.).', (select id from public.lessons where id = '4e003796-1ce0-5a02-8a2d-59a0de38f3dd'), 'PUBLISHED', 'claude_assessment_v5'),
  ('fd56c6cd-0f97-51a4-816c-f99cfebeb5fe', v_aid, 11, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Luka, koji je danas datum?', '["Dva eura i pedeset centi.", "Danas je dvadeseti listopada.", "Iz Ukrajine, iz Harkiva."]'::jsonb, 1, null, '{}'::text[], 'Luka, koji je danas datum?', null, null, 'Діалог «Яке сьогодні число?»: «Luka, koji je danas datum?» (Луко, яке сьогодні число?) — «Danas je dvadeseti listopada.» (Сьогодні двадцяте жовтня.).', (select id from public.lessons where id = 'b36b4550-ff36-50cb-89fb-8246b351c8d6'), 'PUBLISHED', 'claude_assessment_v5'),
  ('03806093-6f33-5b7c-998c-9a8200ab4e5c', v_aid, 12, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Jakna košta sto eura. Znači, sada je sedamdeset?', '["Točno. A druga jakna je pola cijene.", "Hvala, rado.", "U crkvi u Zadru. Naravno, i ti si pozvana!"]'::jsonb, 0, null, '{}'::text[], 'Jakna košta sto eura. Znači, sada je sedamdeset?', null, null, 'Діалог «Знижка»: «Jakna košta sto eura. Znači, sada je sedamdeset?» (Куртка коштує сто євро. Тобто зараз сімдесят?) — «Točno. A druga jakna je pola cijene.» (Точно. А друга куртка — за пів ціни.).', (select id from public.lessons where id = '22dd7878-4fa8-5e1c-909e-71c70ffd9918'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2ac108e5-5908-5028-a0f3-743300e11ce8', v_aid, 13, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Možda pripada gospođi Kovač?', '["Danas imam trideset četiri.", "Možda. Njezin stan je na našem katu.", "Vrijedi do četvrtog ožujka sljedeće godine."]'::jsonb, 1, null, '{}'::text[], 'Možda pripada gospođi Kovač?', null, null, 'Діалог «Чий це ключ?»: «Možda pripada gospođi Kovač?» (Можливо, він належить пані Ковач?) — «Možda. Njezin stan je na našem katu.» (Можливо. Її квартира на нашому поверсі.).', (select id from public.lessons where id = '18efed0f-53a5-5717-9c4e-319627da2360'), 'PUBLISHED', 'claude_assessment_v5'),
  ('dd93b6de-7ce8-5b0f-9861-158bc22c98b5', v_aid, 14, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Jesi li čula vremensku prognozu za sutra?', '["Otprilike četiristo.", "Jesam. Sutra će puhati jaka bura.", "Trideset četiri."]'::jsonb, 1, null, '{}'::text[], 'Jesi li čula vremensku prognozu za sutra?', null, null, 'Діалог «Прогноз погоди»: «Jesi li čula vremensku prognozu za sutra?» (Ти чула прогноз погоди на завтра?) — «Jesam. Sutra će puhati jaka bura.» (Так. Завтра дутиме сильна бура.).', (select id from public.lessons where id = 'efcf49e0-c058-5986-9cf7-aee921887a81'), 'PUBLISHED', 'claude_assessment_v5'),
  ('80fa7ea8-9df0-54c8-b8e6-4e7a727b9378', v_aid, 15, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dobro jutro! Jeste li Vi nova kolegica?', '["Ponekad sam lijena, ali učim svaki dan!", "Jesam. Ja sam Darja, a ovo je Oleh.", "Sunčano je i toplo, dvadeset stupnjeva."]'::jsonb, 1, null, '{}'::text[], 'Dobro jutro! Jeste li Vi nova kolegica?', null, null, 'Діалог «На роботі»: «Dobro jutro! Jeste li Vi nova kolegica?» (Доброго ранку! Ви нова колега?) — «Jesam. Ja sam Darja, a ovo je Oleh.» (Так. Я Дар’я, а це Олег.).', (select id from public.lessons where id = '8abb83d8-ec02-5921-ac9b-814489816fcd'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d026d748-6e30-5167-a7b2-a5a7e743c312', v_aid, 16, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Naša tvrtka traži prodavačicu. Možete li početi u ponedjeljak?', '["Так. Два роки я працювала в магазині в Києві.", "Так, шукаю роботу.", "Можу, звісно!"]'::jsonb, 2, null, '{}'::text[], null, 'Gospodin Kovačević: Dobar dan. Imate li iskustva kao prodavačica?
Daša: Imam. Dvije godine sam radila u trgovini u Kijevu.
Gospodin Kovačević: Dobro. Sada ste nezaposleni?
Daša: Da, tražim posao.
Gospodin Kovačević: Naša tvrtka traži prodavačicu. Možete li početi u ponedjeljak?
Daša: Mogu, naravno!', 'Gospodin Kovačević: Добрий день. У вас є досвід роботи продавчинею?
Daša: Так. Два роки я працювала в магазині в Києві.
Gospodin Kovačević: Добре. Зараз ви не працюєте?
Daša: Так, шукаю роботу.
Gospodin Kovačević: Наша фірма шукає продавчиню. Можете почати в понеділок?
Daša: Можу, звісно!', 'Діалог «Співбесіда»: «Naša tvrtka traži prodavačicu. Možete li početi u ponedjeljak?» — «Mogu, naravno!», тобто «Можу, звісно!».', (select id from public.lessons where id = '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('32321f12-b679-5296-af26-1877c2f8b967', v_aid, 17, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Koliko godina imate?', '["Дев’яносто другого.", "Синові шість років, а доньці вісім місяців.", "Тридцять чотири."]'::jsonb, 2, null, '{}'::text[], null, 'Medicinska sestra: Koliko godina imate?
Darja: Trideset četiri.
Medicinska sestra: Koje ste godište?
Darja: Devedeset drugo.
Medicinska sestra: A djeca?
Darja: Sin ima šest godina, a kći osam mjeseci.', 'Medicinska sestra: Скільки вам років?
Darja: Тридцять чотири.
Medicinska sestra: Якого ви року народження?
Darja: Дев’яносто другого.
Medicinska sestra: А діти?
Darja: Синові шість років, а доньці вісім місяців.', 'Діалог «У поліклініці»: «Koliko godina imate?» — «Trideset četiri.», тобто «Тридцять чотири.».', (select id from public.lessons where id = '4c5db9c0-aa58-55c5-b647-7f7cfc8396c2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7f99c9a3-ad9f-5902-aa56-3ef02eac79f5', v_aid, 18, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dobro, ustajem! Zašto se uvijek žurimo?', '["Бо ти завжди пізно встаєш!", "Міє, будильник дзвонить! Уже сьома година.", "Не можна, школа починається о восьмій. Ми не хочемо запізнитися."]'::jsonb, 0, null, '{}'::text[], null, 'Daša: Mia, budilica zvoni! Već je sedam sati.
Mia: Još pet minuta, mama…
Daša: Ne možemo, škola počinje u osam. Ne želimo zakasniti.
Mia: Dobro, ustajem! Zašto se uvijek žurimo?
Daša: Zato što uvijek kasno ustaješ!', 'Daša: Міє, будильник дзвонить! Уже сьома година.
Mia: Ще п’ять хвилин, мамо…
Daša: Не можна, школа починається о восьмій. Ми не хочемо запізнитися.
Mia: Добре, встаю! Чому ми завжди поспішаємо?
Daša: Бо ти завжди пізно встаєш!', 'Діалог «Ранок удома»: «Dobro, ustajem! Zašto se uvijek žurimo?» — «Zato što uvijek kasno ustaješ!», тобто «Бо ти завжди пізно встаєш!».', (select id from public.lessons where id = '39b1e31f-b573-5000-9713-1660688c3cc9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ac4af54a-da80-5688-a434-5eccb78152f5', v_aid, 19, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Ima li bradu?', '["Добре, я точно його впізнаю.", "Має невелику бороду й носить окуляри.", "Як виглядає твій брат? Мені треба зустріти його на вокзалі."]'::jsonb, 1, null, '{}'::text[], null, 'Daša: Kako izgleda tvoj brat? Trebam ga dočekati na kolodvoru.
Ivana: Visok je i mršav, ima kratku smeđu kosu.
Daša: Ima li bradu?
Ivana: Ima malu bradu i nosi naočale.
Daša: Dobro, sigurno ću ga prepoznati.
Ivana: Hvala ti! On je jako drag, svidjet će ti se.', 'Daša: Як виглядає твій брат? Мені треба зустріти його на вокзалі.
Ivana: Він високий і худий, у нього коротке каштанове волосся.
Daša: У нього є борода?
Ivana: Має невелику бороду й носить окуляри.
Daša: Добре, я точно його впізнаю.
Ivana: Дякую! Він дуже милий, він тобі сподобається.', 'Діалог «Як він виглядає?»: «Ima li bradu?» — «Ima malu bradu i nosi naočale.», тобто «Має невелику бороду й носить окуляри.».', (select id from public.lessons where id = '60130364-d731-5f5a-8b12-ac4d8d6d92e9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b539215b-0569-5dc6-9d7e-0cf7fd8d2c75', v_aid, 20, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Доброго ранку!». Що ви скажете?', null, '["Dobro jutro!", "Puno hvala!", "Smijem li?"]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Доброго ранку!» — «Dobro jutro!».', (select id from public.lessons where id = 'd8cffb46-8a62-538a-b864-e227a6d8b863'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6bbc886f-ecec-595c-8f49-9c12005e368e', v_aid, 21, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Мій син ходить у школу». Що ви скажете?', null, '["Ovo je moj tata.", "To je moj ključ.", "Moj sin ide u školu."]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Мій син ходить у школу.» — «Moj sin ide u školu.».', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6db8380d-543d-5342-b320-9c3ccb522949', v_aid, 22, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «У грудні холодно». Що ви скажете?', null, '["U prosincu je hladno.", "Volim ljeto.", "Sretan Uskrs!"]'::jsonb, 0, null, '{}'::text[], null, null, null, '«У грудні холодно.» — «U prosincu je hladno.».', (select id from public.lessons where id = '036fc4fb-1bf2-5100-9fd0-6f6a612554a1'), 'PUBLISHED', 'claude_assessment_v5'),
  ('50bfe34e-e563-55f5-9bec-731b452dad40', v_aid, 23, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «галасливий»', null, '[]'::jsonb, null, 'bučan', '{}'::text[], null, null, null, '«галасливий» — bučan.', (select id from public.lessons where id = 'adf335ee-0cba-5c9a-b86a-8baac868edbc'), 'PUBLISHED', 'claude_assessment_v5'),
  ('dff122ff-e45f-55e0-af1c-cff9bd8d158f', v_aid, 24, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «клас (група учнів)»', null, '[]'::jsonb, null, 'razred', '{}'::text[], null, null, null, '«клас (група учнів)» — razred.', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v5'),
  ('114e654a-046c-53f7-bfbb-8756e12acb1b', v_aid, 25, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «післязавтра»', null, '[]'::jsonb, null, 'prekosutra', '{}'::text[], null, null, null, '«післязавтра» — prekosutra.', (select id from public.lessons where id = '238d9508-3c2e-5ee6-910f-0ae8863c2dc7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('40dfe1db-9238-5746-a1d2-bb59987334c6', v_aid, 26, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Моє повне ім’я — Дар’я.»', null, '["ime", "Moje", "je", "Darja.", "puno"]'::jsonb, null, 'Moje puno ime je Darja.', array['Darja je moje puno ime.']::text[], null, null, null, '«Моє повне ім’я — Дар’я.» — «Moje puno ime je Darja.».', (select id from public.lessons where id = '2b6ed342-cc80-5bd9-baf0-b66109624d62'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2d1603c4-9c6b-5049-b348-34ff5c8d37af', v_aid, 27, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Побачимося пізніше!»', null, '["kasnije!", "Vidimo", "se"]'::jsonb, null, 'Vidimo se kasnije!', array['Kasnije se vidimo!']::text[], null, null, null, '«Побачимося пізніше!» — «Vidimo se kasnije!».', (select id from public.lessons where id = 'd8cffb46-8a62-538a-b864-e227a6d8b863'), 'PUBLISHED', 'claude_assessment_v5'),
  ('87b7172d-c173-550d-8595-2d280c5633f6', v_aid, 28, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Ви набрали не той номер.»', null, '["broj.", "ste", "Nazvali", "krivi"]'::jsonb, null, 'Nazvali ste krivi broj.', '{}'::text[], null, null, null, '«Ви набрали не той номер.» — «Nazvali ste krivi broj.».', (select id from public.lessons where id = 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d8f05f7f-4129-5761-bf9b-9f760890f74a', v_aid, 29, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Як справи? (до друга)»', null, '[]'::jsonb, null, 'Kako si?', '{}'::text[], null, null, null, '«Як справи? (до друга)» — «Kako si?».', (select id from public.lessons where id = 'c0000000-0000-0000-0000-000000000001'), 'PUBLISHED', 'claude_assessment_v5'),
  ('78f72379-40b5-5507-a5ae-a2439eb7264a', v_aid, 30, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Дві тисячі.»', null, '[]'::jsonb, null, 'Dvije tisuće.', '{}'::text[], null, null, null, '«Дві тисячі.» — «Dvije tisuće.».', (select id from public.lessons where id = '1f41cb75-1ce5-57ba-a56f-58561ee1d983'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A0. Потрібна перевірка носієм.');
end $$;

-- Фінальна перевірка рівня A0 · 48 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-final' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-final — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '42e434eb-21a7-5717-be2d-059842e1a6f1') then return; end if;  -- уже оновлено
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Кінець рівня (усі 10 модулів A0): 48 завдань на 4 навички. ~25 хв.', estimated_minutes = 25 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('42e434eb-21a7-5717-be2d-059842e1a6f1', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Добрий день, мені потрібні овочі на суп.", "Дайте мені дві морквини, одну цибулину й кілограм картоплі.", "Правда, але цей золотий браслет — новий!"]'::jsonb, 2, null, '{}'::text[], 'Istina, ali ova zlatna narukvica je nova!', null, null, 'Прозвучало: «Istina, ali ova zlatna narukvica je nova!» — «Правда, але цей золотий браслет — новий!».', (select id from public.lessons where id = '288e7610-99c8-5696-989a-86f60ce38b0a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5d2b0feb-e71d-50bf-affc-05188b60722a', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А, зрозуміло! А як сказати «thank you»?", "Я йду додому. Побачимося завтра?", "Вибачте, я не зрозумів. Можете повторити?"]'::jsonb, 0, null, '{}'::text[], 'Aha, jasno! A kako se kaže »thank you«?', null, null, 'Прозвучало: «Aha, jasno! A kako se kaže »thank you«?» — «А, зрозуміло! А як сказати «thank you»?».', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d4db84ac-428e-5f31-83aa-c5aa64e7de48', v_aid, 3, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Біле, але з мінеральною водою. Як це називається?", "З собою чи будете їсти тут?", "Я не п’ю алкоголю. Що у вас є безалкогольне?"]'::jsonb, 0, null, '{}'::text[], 'Bijelo, ali s mineralnom vodom. Kako se to zove?', null, null, 'Прозвучало: «Bijelo, ali s mineralnom vodom. Kako se to zove?» — «Біле, але з мінеральною водою. Як це називається?».', (select id from public.lessons where id = '77d640c4-4190-544a-8094-4e699f9a0a10'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c56454dc-628a-551f-9827-3735ccc026b1', v_aid, 4, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["У мене температура й сильний кашель уже три дні.", "Дуже дякую, ви дуже люб’язні.", "Прошу. Приймайте його тричі на день після їжі."]'::jsonb, 1, null, '{}'::text[], 'Hvala vam puno, jako ste ljubazni.', null, null, 'Прозвучало: «Hvala vam puno, jako ste ljubazni.» — «Дуже дякую, ви дуже люб’язні.».', (select id from public.lessons where id = '48f26e9d-96c5-5189-8ec6-db1f9d58e200'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d95d6c8b-5b15-5e42-8166-0327b7bc7e56', v_aid, 5, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Я шукаю диван для вітальні.", "Чудово, візьму її.", "У нас найдорожчий рахунок за електрику."]'::jsonb, 2, null, '{}'::text[], 'Kod nas je najskuplji račun za struju.', null, null, 'Прозвучало: «Kod nas je najskuplji račun za struju.» — «У нас найдорожчий рахунок за електрику.».', (select id from public.lessons where id = 'e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6479d667-81dc-5bf7-b542-a24a7d146967', v_aid, 6, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Добрий день, слухаю вас. Як вас звати?", "Вибачте, коли їде потяг до Спліта?", "З березня. А чому ти питаєш?"]'::jsonb, 2, null, '{}'::text[], 'Od ožujka. A zašto pitaš?', null, null, 'Прозвучало: «Od ožujka. A zašto pitaš?» — «З березня. А чому ти питаєш?».', (select id from public.lessons where id = '8f6439a9-c6ac-5271-99c8-1f0adc5d7599'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1faa722f-e338-5940-a973-1e30943dca6e', v_aid, 7, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Двадцять п’ять. Перевір на калькуляторі!", "Дякую! Я тут уперше.", "Дев’ятнадцятий приходить за двадцять хвилин."]'::jsonb, 1, null, '{}'::text[], 'Hvala! Ovo mi je prvi put ovdje.', null, null, 'Прозвучало: «Hvala! Ovo mi je prvi put ovdje.» — «Дякую! Я тут уперше.».', (select id from public.lessons where id = '40f7c64a-ad42-5fe2-a230-7b1e98607112'), 'PUBLISHED', 'claude_assessment_v5'),
  ('98922983-8cdb-51c9-b109-49fc0435ce5b', v_aid, 8, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Так, її звати Леа. А котрий твій?", "Які ви схожі! А дівчина поруч із тобою?", "А ти? Ти старанна студентка?"]'::jsonb, 0, null, '{}'::text[], 'Jest, zove se Lea. A koji je tvoj?', null, null, 'Прозвучало: «Jest, zove se Lea. A koji je tvoj?» — «Так, її звати Леа. А котрий твій?».', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v5'),
  ('03e2f716-0fe9-5765-8088-7146be3e03d3', v_aid, 9, 'A0', 'reading', 'understand', 'multiple_choice', 'Що означає «Oprostite»?', 'Natpis na vratima kafića', '["Дякую", "Вибачте", "Привіт"]'::jsonb, 1, null, '{}'::text[], null, 'ZATVORENO
Oprostite, danas ne radimo.
Vidimo se sutra!
Hvala!', 'ЗАЧИНЕНО
Вибачте, сьогодні ми не працюємо.
Побачимося завтра!
Дякуємо!', 'Текст «Табличка на дверях кафе». Правильна відповідь: «Вибачте».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('ea3a0aad-2beb-5f1b-a420-01e0f6361203', v_aid, 10, 'A0', 'reading', 'understand', 'multiple_choice', 'Що коштує 2,20 €?', 'Cjenik kafića', '["Сік", "Вода", "Кава з молоком"]'::jsonb, 2, null, '{}'::text[], null, 'CJENIK
Kava 1,80 €
Kava s mlijekom 2,20 €
Čaj 1,50 €
Sok 2,50 €
Voda 1,20 €', 'ЦІНИ
Кава 1,80 €
Кава з молоком 2,20 €
Чай 1,50 €
Сік 2,50 €
Вода 1,20 €', 'Текст «Ціни в кафе». Правильна відповідь: «Кава з молоком».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('ecdf953e-8b57-52f7-9011-8e2101f9af48', v_aid, 11, 'A0', 'reading', 'understand', 'multiple_choice', 'Коли кафе знову працюватиме?', 'Natpis na vratima kafića', '["У понеділок", "Завтра", "Через тиждень"]'::jsonb, 1, null, '{}'::text[], null, 'ZATVORENO
Oprostite, danas ne radimo.
Vidimo se sutra!
Hvala!', 'ЗАЧИНЕНО
Вибачте, сьогодні ми не працюємо.
Побачимося завтра!
Дякуємо!', 'Текст «Табличка на дверях кафе». Правильна відповідь: «Завтра».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('0df83fa9-363a-5566-ad60-042788a53018', v_aid, 12, 'A0', 'reading', 'understand', 'multiple_choice', 'Куди їде автобус 6?', 'Vozni red autobusa', '["До лікарні", "До вокзалу", "До аеропорту"]'::jsonb, 1, null, '{}'::text[], null, 'AUTOBUS 6
Smjer: Kolodvor
Polasci: 7:15 • 7:45 • 8:15
Vikendom: svaki sat', 'АВТОБУС 6
Напрямок: вокзал
Відправлення: 7:15 • 7:45 • 8:15
На вихідних: щогодини', 'Текст «Розклад автобуса». Правильна відповідь: «До вокзалу».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('15603578-caa7-5c20-a341-f73f231fd7d0', v_aid, 13, 'A0', 'reading', 'understand', 'multiple_choice', 'Де купити квиток?', 'Na kolodvoru', '["Čekaonica", "Blagajna", "Peroni"]'::jsonb, 1, null, '{}'::text[], null, 'ULAZ
IZLAZ
BLAGAJNA – karte
PERONI 1 – 5
ČEKAONICA
WC', 'ВХІД
ВИХІД
КАСА – квитки
ПЛАТФОРМИ 1–5
ЗАЛ ОЧІКУВАННЯ
ТУАЛЕТ', 'Текст «На вокзалі». Правильна відповідь: «Blagajna».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('fdef83cb-b4e8-525f-b47b-79a7ac76ea6e', v_aid, 14, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Može za devedeset?', '["Ženski. A ovdje mjesto rođenja i bračno stanje.", "Može za devedeset pet. Isplati vam se!", "Otprilike četiristo."]'::jsonb, 1, null, '{}'::text[], 'Može za devedeset?', null, null, 'Діалог «Вживаний велосипед»: «Može za devedeset?» (А за дев’яносто можна?) — «Može za devedeset pet. Isplati vam se!» (Можна за дев’яносто п’ять. Вам це вигідно!).', (select id from public.lessons where id = '6836e57c-030c-59f8-9818-b44c08b126a6'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f79f2db4-d5ae-529a-9530-1915be125b36', v_aid, 15, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Razumijem te. Želiš li na kavu?', '["Hvala, rado.", "Možemo u zoološki vrt. Djeca ga obožavaju.", "Kopiju, ali mora biti ovjerena."]'::jsonb, 0, null, '{}'::text[], 'Razumijem te. Želiš li na kavu?', null, null, 'Діалог «Поганий день»: «Razumijem te. Želiš li na kavu?» (Розумію тебе. Хочеш на каву?) — «Hvala, rado.» (Дякую, із задоволенням.).', (select id from public.lessons where id = '3b51b1bf-47f4-5709-96d9-c518d36440e6'), 'PUBLISHED', 'claude_assessment_v5'),
  ('16401ea2-1b4a-5add-9864-1c6db0a5a400', v_aid, 16, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dobar dan. Do kada vrijedi Vaša boravišna dozvola?', '["Vrijedi do četvrtog ožujka sljedeće godine.", "Kožni novčanik s osobnom iskaznicom i karticom.", "Vani, ispred zgrade."]'::jsonb, 0, null, '{}'::text[], 'Dobar dan. Do kada vrijedi Vaša boravišna dozvola?', null, null, 'Діалог «Дозвіл на проживання»: «Dobar dan. Do kada vrijedi Vaša boravišna dozvola?» (Добрий день. До якого числа дійсний ваш дозвіл на проживання?) — «Vrijedi do četvrtog ožujka sljedeće godine.» (Він дійсний до четвертого березня наступного року.).', (select id from public.lessons where id = 'b36b4550-ff36-50cb-89fb-8246b351c8d6'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9ae14633-2b53-55ba-bbc2-1dc1474e0079', v_aid, 17, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koliko košta ova stara lampa?', '["Točno! Bravo.", "Trideset eura.", "Jesu, jutros su ulovljene."]'::jsonb, 1, null, '{}'::text[], 'Koliko košta ova stara lampa?', null, null, 'Діалог «На блошиному ринку»: «Koliko košta ova stara lampa?» (Скільки коштує ця стара лампа?) — «Trideset eura.» (Тридцять євро.).', (select id from public.lessons where id = '6836e57c-030c-59f8-9818-b44c08b126a6'), 'PUBLISHED', 'claude_assessment_v5'),
  ('40bce75e-387e-549d-9097-0b37162701be', v_aid, 18, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, koliko ima jabuka?', '["Na prvom katu, lijevo od lifta.", "Idite ravno do kraja ulice, pa skrenite lijevo.", "Brojimo zajedno: jedan, dva, tri…"]'::jsonb, 2, null, '{}'::text[], 'Dašo, koliko ima jabuka?', null, null, 'Діалог «Скільки яблук?»: «Dašo, koliko ima jabuka?» (Дашо, скільки тут яблук?) — «Brojimo zajedno: jedan, dva, tri…» (Рахуймо разом: один, два, три…).', (select id from public.lessons where id = 'c0941bd8-57b5-5e7e-981f-9be423f24208'), 'PUBLISHED', 'claude_assessment_v5'),
  ('15a78c6f-7485-5b53-9c80-af7de79dcbc3', v_aid, 19, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Jeste li se preselili ovamo s obitelji?', '["Jesam. Ovdje smo pod privremenom zaštitom.", "Zahtjev je odobren. Rješenje možete preuzeti na šalteru tri.", "Oko pola sata. Budite strpljivi."]'::jsonb, 0, null, '{}'::text[], 'Jeste li se preselili ovamo s obitelji?', null, null, 'Діалог «Розмова з сусідом»: «Jeste li se preselili ovamo s obitelji?» (Ви переїхали сюди з родиною?) — «Jesam. Ovdje smo pod privremenom zaštitom.» (Так. Ми тут під тимчасовим захистом.).', (select id from public.lessons where id = '04167753-db83-5163-a91c-9f71dac18ab5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1d7b9bf1-1b5f-5ee2-8c11-d960c8b039f9', v_aid, 20, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, imaš li rodbinu u Hrvatskoj?', '["U četrnaest i trideset, s petog perona.", "Imam. Moja teta živi u Rijeci sa svojim mužem.", "Kod javnog bilježnika. Treba vam pečat i potpis."]'::jsonb, 1, null, '{}'::text[], 'Dašo, imaš li rodbinu u Hrvatskoj?', null, null, 'Діалог «Родичі в Хорватії»: «Dašo, imaš li rodbinu u Hrvatskoj?» (Дашо, у тебе є родичі в Хорватії?) — «Imam. Moja teta živi u Rijeci sa svojim mužem.» (Так. Моя тітка живе в Рієці зі своїм чоловіком.).', (select id from public.lessons where id = 'cec08ff0-a97d-5847-88cc-dee22fed2f8c'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f96f20a5-0d56-5574-b63d-7e5d76f2997b', v_aid, 21, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Na glavni kolodvor, molim. Koliko će koštati vožnja?', '["Prvo upišite osobne podatke, tiskanim slovima.", "Na kraju hodnika, pored spavaće sobe. Zahod je odvojen.", "Oko dvanaest eura. Vežite pojas, molim."]'::jsonb, 2, null, '{}'::text[], 'Na glavni kolodvor, molim. Koliko će koštati vožnja?', null, null, 'Діалог «У таксі»: «Na glavni kolodvor, molim. Koliko će koštati vožnja?» (На головний вокзал, будь ласка. Скільки коштуватиме поїздка?) — «Oko dvanaest eura. Vežite pojas, molim.» (Близько дванадцяти євро. Пристебніться, будь ласка.).', (select id from public.lessons where id = 'e0b9d742-0418-597b-9482-b6e2d82469da'), 'PUBLISHED', 'claude_assessment_v5'),
  ('aa92a43d-a65e-5ea1-b43b-c16a467f30f1', v_aid, 22, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Centar 112, izvolite. Što se dogodilo?', '["Još ne. Moram zamijeniti vozačku dozvolu.", "Dogodila se prometna nesreća! Jedan čovjek je ozlijeđen.", "Sladoled ovdje, a tortu za van."]'::jsonb, 1, null, '{}'::text[], 'Centar 112, izvolite. Što se dogodilo?', null, null, 'Діалог «Дзвінок на 112»: «Centar 112, izvolite. Što se dogodilo?» (Центр 112, слухаю. Що сталося?) — «Dogodila se prometna nesreća! Jedan čovjek je ozlijeđen.» (Сталася ДТП! Один чоловік поранений.).', (select id from public.lessons where id = '48f26e9d-96c5-5189-8ec6-db1f9d58e200'), 'PUBLISHED', 'claude_assessment_v5'),
  ('931142cb-78da-54ee-bf26-e3bc56fbdb64', v_aid, 23, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, kakav je tvoj novi stan?', '["Jako je strpljiva i pametna.", "Puno je bolji od starog! Velik je i svijetao.", "Na kiosku ili kod vozača. Uđi na prednja vrata."]'::jsonb, 1, null, '{}'::text[], 'Dašo, kakav je tvoj novi stan?', null, null, 'Діалог «Стара й нова квартира»: «Dašo, kakav je tvoj novi stan?» (Дашо, яка твоя нова квартира?) — «Puno je bolji od starog! Velik je i svijetao.» (Набагато краща за стару! Велика й світла.).', (select id from public.lessons where id = 'f51692d8-cb95-5f2e-8263-f3728f5e10c0'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1b0c563c-353a-5a31-a374-36ea3b316808', v_aid, 24, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Onaj dječak u plavoj majici. Ide li Lea u vrtić?', '["Ide, u vrtić pored škole. Odgojiteljice su jako drage.", "Ukupno devet eura.", "Onu domaću. I pola kile mljevenog mesa."]'::jsonb, 0, null, '{}'::text[], 'Onaj dječak u plavoj majici. Ide li Lea u vrtić?', null, null, 'Діалог «На дитячому майданчику»: «Onaj dječak u plavoj majici. Ide li Lea u vrtić?» (Он той хлопчик у синій футболці. Леа ходить у садочок?) — «Ide, u vrtić pored škole. Odgojiteljice su jako drage.» (Так, у садочок біля школи. Виховательки дуже милі.).', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v5'),
  ('87c12d8d-e50b-5cb2-9dcc-8004ec28a0f7', v_aid, 25, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Darja, voziš li ovdje auto?', '["Ще ні. Мені треба обміняти водійське посвідчення.", "Тоді спробую електросамокат!", "А я їжджу на роботу велосипедом. Жодних заторів, і не треба шукати парковку."]'::jsonb, 0, null, '{}'::text[], null, 'Ante: Darja, voziš li ovdje auto?
Darja: Još ne. Moram zamijeniti vozačku dozvolu.
Ante: Ja na posao idem biciklom. Nema gužve i ne tražim parkiralište.
Darja: Je li to sigurno?
Ante: Jest, imamo biciklističku stazu uz cijelu cestu.
Darja: Onda ću probati električni romobil!', 'Ante: Дар’є, ти тут водиш машину?
Darja: Ще ні. Мені треба обміняти водійське посвідчення.
Ante: А я їжджу на роботу велосипедом. Жодних заторів, і не треба шукати парковку.
Darja: А це безпечно?
Ante: Так, у нас є велодоріжка вздовж усієї дороги.
Darja: Тоді спробую електросамокат!', 'Діалог «Автом чи велосипедом?»: «Darja, voziš li ovdje auto?» — «Još ne. Moram zamijeniti vozačku dozvolu.», тобто «Ще ні. Мені треба обміняти водійське посвідчення.».', (select id from public.lessons where id = 'e0b9d742-0418-597b-9482-b6e2d82469da'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a9131cba-6665-5153-a60a-5b59de46bae8', v_aid, 26, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Kakva je govedina?', '["Смачна, але трохи пересолена.", "Ой, справді гострий! Дай мені води.", "Скуштуй цей соус. Обережно, він гострий!"]'::jsonb, 0, null, '{}'::text[], null, 'Luka: Kakva je govedina?
Daša: Ukusna je, ali malo preslana.
Luka: Probaj ovaj umak. Pazi, ljut je!
Daša: Joj, stvarno je pikantan! Daj mi vode.
Luka: Hoćeš li desert? Kolač nije previše sladak.
Daša: Može! Nakon ovoga trebam nešto slatko.', 'Luka: Як тобі яловичина?
Daša: Смачна, але трохи пересолена.
Luka: Скуштуй цей соус. Обережно, він гострий!
Daša: Ой, справді гострий! Дай мені води.
Luka: Хочеш десерт? Тістечко не надто солодке.
Daša: Давай! Після такого мені треба чогось солодкого.', 'Діалог «Як на смак?»: «Kakva je govedina?» — «Ukusna je, ali malo preslana.», тобто «Смачна, але трохи пересолена.».', (select id from public.lessons where id = 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('51bf94a3-c310-5830-bb6c-e521e0bd6c17', v_aid, 27, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Tražite li kauciju?', '["Так, у розмірі місячної оплати. Можете подивитися її завтра.", "Так. Це двокімнатна квартира, шістдесят квадратних метрів, з балконом.", "Так, повністю. Оренда — п’ятсот євро, а комунальні окремо."]'::jsonb, 0, null, '{}'::text[], null, 'Daša: Dobar dan, zovem zbog oglasa. Je li stan još slobodan?
Stanodavac: Jest. To je dvosoban stan, šezdeset kvadrata, s balkonom.
Daša: Je li namješten?
Stanodavac: Jest, potpuno. Najamnina je petsto eura, a režije posebno.
Daša: Tražite li kauciju?
Stanodavac: Da, jednu najamninu. Možete ga pogledati sutra.', 'Daša: Добрий день, я телефоную щодо оголошення. Квартира ще вільна?
Stanodavac: Так. Це двокімнатна квартира, шістдесят квадратних метрів, з балконом.
Daša: Вона мебльована?
Stanodavac: Так, повністю. Оренда — п’ятсот євро, а комунальні окремо.
Daša: Ви берете заставу?
Stanodavac: Так, у розмірі місячної оплати. Можете подивитися її завтра.', 'Діалог «Оголошення»: «Tražite li kauciju?» — «Da, jednu najamninu. Možete ga pogledati sutra.», тобто «Так, у розмірі місячної оплати. Можете подивитися її завтра.».', (select id from public.lessons where id = '78f28f85-dd8b-5e81-8a52-1b2dbce4eb34'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2b70b45c-7c56-54cf-9457-2452739c4049', v_aid, 28, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'U obrascu imam jednu pogrešku. Mogu li je ispraviti?', '["Копія, але засвідчена.", "У нотаріуса. Потрібні печатка й підпис.", "Можна, але краще заповніть новий."]'::jsonb, 2, null, '{}'::text[], null, 'Darja: Trebate li original ili kopiju diplome?
Službenik: Kopiju, ali mora biti ovjerena.
Darja: Gdje mogu ovjeriti kopiju?
Službenik: Kod javnog bilježnika. Treba vam pečat i potpis.
Darja: U obrascu imam jednu pogrešku. Mogu li je ispraviti?
Službenik: Možete, ali bolje ispunite novi.', 'Darja: Вам потрібен оригінал чи копія диплома?
Službenik: Копія, але засвідчена.
Darja: Де можна засвідчити копію?
Službenik: У нотаріуса. Потрібні печатка й підпис.
Darja: У бланку в мене одна помилка. Можна її виправити?
Službenik: Можна, але краще заповніть новий.', 'Діалог «Копія чи оригінал?»: «U obrascu imam jednu pogrešku. Mogu li je ispraviti?» — «Možete, ali bolje ispunite novi.», тобто «Можна, але краще заповніть новий.».', (select id from public.lessons where id = 'b095637e-0644-507e-8f3d-d323483dd3e4'), 'PUBLISHED', 'claude_assessment_v5'),
  ('078d92a2-e482-5f2b-9ef7-b43130bea9cf', v_aid, 29, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Marko, jesi li oženjen?', '["В університеті. Я закохався одразу! А ти заміжня?", "Де ви познайомилися?", "Так, уже десять років. Мою дружину звати Ана."]'::jsonb, 2, null, '{}'::text[], null, 'Daša: Marko, jesi li oženjen?
Marko: Jesam, već deset godina. Moja supruga se zove Ana.
Daša: Gdje ste se upoznali?
Marko: Na fakultetu. Zaljubio sam se odmah! A ti, jesi li udana?
Daša: Jesam. Moj muž sada radi u Njemačkoj.', 'Daša: Марку, ти одружений?
Marko: Так, уже десять років. Мою дружину звати Ана.
Daša: Де ви познайомилися?
Marko: В університеті. Я закохався одразу! А ти заміжня?
Daša: Так. Мій чоловік зараз працює в Німеччині.', 'Діалог «Ти одружений?»: «Marko, jesi li oženjen?» — «Jesam, već deset godina. Moja supruga se zove Ana.», тобто «Так, уже десять років. Мою дружину звати Ана.».', (select id from public.lessons where id = 'f9ca38e4-3a61-56a6-b5f5-060933516c9a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('af9389ff-28ce-5111-8f13-5b6c73006ae1', v_aid, 30, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Koliko je kilometara od Zagreba do Splita?', '["Шістсот, може, трохи більше.", "Так, але дорога дуже гарна.", "Приблизно чотириста."]'::jsonb, 2, null, '{}'::text[], null, 'Daša: Koliko je kilometara od Zagreba do Splita?
Luka: Otprilike četiristo.
Daša: A do Dubrovnika?
Luka: Šesto, možda malo više.
Daša: To je velika udaljenost!
Luka: Je, ali cesta je jako lijepa.', 'Daša: Скільки кілометрів від Загреба до Спліта?
Luka: Приблизно чотириста.
Daša: А до Дубровника?
Luka: Шістсот, може, трохи більше.
Daša: Це велика відстань!
Luka: Так, але дорога дуже гарна.', 'Діалог «Скільки кілометрів?»: «Koliko je kilometara od Zagreba do Splita?» — «Otprilike četiristo.», тобто «Приблизно чотириста.».', (select id from public.lessons where id = 'c0d7b467-acb2-581a-975b-497e63f45aa7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('81e5b132-fefe-5f4c-a775-5f84aa1ca52f', v_aid, 31, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Перший поверх». Що ви скажете?', null, '["Prvi kat.", "Pola kile.", "Danas ja plaćam."]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Перший поверх.» — «Prvi kat.».', (select id from public.lessons where id = '40f7c64a-ad42-5fe2-a230-7b1e98607112'), 'PUBLISHED', 'claude_assessment_v5'),
  ('15c9896c-8fe7-5596-8bb2-6eba8d67b5e5', v_aid, 32, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Ще щось?». Що ви скажете?', null, '["Ova košulja mi pristaje.", "Još nešto?", "Ima li popusta?"]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Ще щось?» — «Još nešto?».', (select id from public.lessons where id = '0e925295-2766-5931-b031-2412682bc6f8'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f668b30e-4991-5605-b25d-9c7c4f97d69e', v_aid, 33, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я працюю в офісі». Що ви скажете?', null, '["Ja sam iz Ukrajine.", "Radim u uredu.", "Govorim malo hrvatski."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Я працюю в офісі.» — «Radim u uredu.».', (select id from public.lessons where id = '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('32a85861-480f-5141-a280-7f30ee6e16b7', v_aid, 34, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Можете мені допомогти з бланком?». Що ви скажете?', null, '["Imam prehladu.", "Možete li mi pomoći s obrascem?", "Gdje je najbliža ljekarna?"]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Можете мені допомогти з бланком?» — «Možete li mi pomoći s obrascem?».', (select id from public.lessons where id = 'b095637e-0644-507e-8f3d-d323483dd3e4'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2932fd9b-9225-51ba-b3d7-e3366fd7891b', v_aid, 35, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Наступного року». Що ви скажете?', null, '["Jesi li slobodna večeras?", "Sljedeće godine.", "Hladno je."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Наступного року.» — «Sljedeće godine.».', (select id from public.lessons where id = 'b36b4550-ff36-50cb-89fb-8246b351c8d6'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a78f5e75-618c-519c-b180-86697904e2cc', v_aid, 36, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «дванадцять»', null, '[]'::jsonb, null, 'dvanaest', '{}'::text[], null, null, null, '«дванадцять» — dvanaest.', (select id from public.lessons where id = 'e30c65f2-1a30-5b51-85e7-6a460cd1799f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5ea6fe1c-93ad-5bec-9b7f-34932c3332a3', v_aid, 37, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «хвилина»', null, '[]'::jsonb, null, 'minuta', '{}'::text[], null, null, null, '«хвилина» — minuta.', (select id from public.lessons where id = '39b1e31f-b573-5000-9713-1660688c3cc9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b6b5e820-ef15-5b37-b2c5-5a4f4dfcc765', v_aid, 38, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «сосиска; ковбаска»', null, '[]'::jsonb, null, 'kobasica', '{}'::text[], null, null, null, '«сосиска; ковбаска» — kobasica.', (select id from public.lessons where id = '0e925295-2766-5931-b031-2412682bc6f8'), 'PUBLISHED', 'claude_assessment_v5'),
  ('af4cddc6-a17f-515e-b589-8399682d64b7', v_aid, 39, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «невістка»', null, '[]'::jsonb, null, 'snaha', '{}'::text[], null, null, null, '«невістка» — snaha.', (select id from public.lessons where id = 'cec08ff0-a97d-5847-88cc-dee22fed2f8c'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7d7ae030-c43a-5a68-a5be-885f1b3f83d8', v_aid, 40, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «службовець / чиновник»', null, '[]'::jsonb, null, 'službenik', '{}'::text[], null, null, null, '«службовець / чиновник» — službenik.', (select id from public.lessons where id = '19df3241-90f3-5450-94ac-642d79fb2869'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2e474952-7a4f-5c5d-a2d8-f8fe4edf246f', v_aid, 41, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Скільки коштує вхідний квиток?»', null, '["Koliko", "ulaznica?", "košta"]'::jsonb, null, 'Koliko košta ulaznica?', array['Koliko ulaznica košta?']::text[], null, null, null, '«Скільки коштує вхідний квиток?» — «Koliko košta ulaznica?».', (select id from public.lessons where id = '1e0384e5-6097-56ed-ab56-cf530f02ab73'), 'PUBLISHED', 'claude_assessment_v5'),
  ('29bea540-7596-54f0-a9f2-95ca1c843828', v_aid, 42, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «У вас є столик на двох?»', null, '["li", "dvoje?", "za", "stol", "Imate"]'::jsonb, null, 'Imate li stol za dvoje?', '{}'::text[], null, null, null, '«У вас є столик на двох?» — «Imate li stol za dvoje?».', (select id from public.lessons where id = '8b30911e-4e57-5648-9ff6-bd11c1b0e27e'), 'PUBLISHED', 'claude_assessment_v5'),
  ('71251f15-dee1-5a96-9405-47a72d69e94f', v_aid, 43, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Де ти зараз живеш?»', null, '["Gdje", "živiš?", "sada"]'::jsonb, null, 'Gdje sada živiš?', array['Gdje živiš sada?']::text[], null, null, null, '«Де ти зараз живеш?» — «Gdje sada živiš?».', (select id from public.lessons where id = '8f6439a9-c6ac-5271-99c8-1f0adc5d7599'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a574f71b-c5dc-5498-b785-552f04593b30', v_aid, 44, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Добре, дякую. А ти?»', null, '["hvala.", "A", "Dobro,", "ti?"]'::jsonb, null, 'Dobro, hvala. A ti?', array['Hvala, dobro. A ti?']::text[], null, null, null, '«Добре, дякую. А ти?» — «Dobro, hvala. A ti?».', (select id from public.lessons where id = 'c0000000-0000-0000-0000-000000000001'), 'PUBLISHED', 'claude_assessment_v5'),
  ('800e8a45-fafe-5643-9490-85f5116c2b07', v_aid, 45, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Пральна машина не працює.»', null, '["ne", "Perilica", "radi."]'::jsonb, null, 'Perilica ne radi.', '{}'::text[], null, null, null, '«Пральна машина не працює.» — «Perilica ne radi.».', (select id from public.lessons where id = 'e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9c7cf620-eb0e-530f-b485-6b55aa13d5eb', v_aid, 46, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Склянку води, будь ласка.»', null, '[]'::jsonb, null, 'Čašu vode, molim.', '{}'::text[], null, null, null, '«Склянку води, будь ласка.» — «Čašu vode, molim.».', (select id from public.lessons where id = '77d640c4-4190-544a-8094-4e699f9a0a10'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a045694e-cfab-5fc5-bdf7-06c3af9f159f', v_aid, 47, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Ця сумка дуже важка.»', null, '[]'::jsonb, null, 'Ova torba je jako teška.', '{}'::text[], null, null, null, '«Ця сумка дуже важка.» — «Ova torba je jako teška.».', (select id from public.lessons where id = 'f51692d8-cb95-5f2e-8263-f3728f5e10c0'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a51a2856-3d26-5812-b006-82c7c2911f76', v_aid, 48, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Дякую за допомогу!»', null, '[]'::jsonb, null, 'Hvala na pomoći!', '{}'::text[], null, null, null, '«Дякую за допомогу!» — «Hvala na pomoći!».', (select id from public.lessons where id = 'e704760a-f743-5762-9c1a-027b10ca030a'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A0. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('9e7b55a1-27a4-53e9-b5ec-13f48547eec9', 'bbbaad61-d9bc-5092-befc-55215ff50632', 'e55d2eb0-0307-5313-9e4e-56411f4a4de2', '8cfe0de4-8852-5ae6-8082-dcd02d728da9', 'ed28f90a-a290-5779-8055-0bdf1c6a75f8', 'ca1febac-f78a-5114-80de-ae27e61f41ce', '90a7fc26-c6c9-5e01-8a42-69a5032690ee', '216a88f8-bc5a-58b1-92c9-3444ecacd219', '7d912fe8-5407-5e69-a76f-bc4e2152ac83', 'd9a23dd3-d7eb-5974-94be-c44e912aef2e', '322a70bb-741e-59c9-8abc-7f0efc039923', '249fe305-0e10-5e34-a9c3-43133222d7b8', '743859a4-e82b-5fa7-bb8a-11d8c079f0da', '48649401-a4e1-5dce-bfba-e53e8f8f3f48', 'd5533458-a7a9-551e-9b03-c1f2d06f852f', '45b29446-8020-508a-8789-4f49b381eed0', '76ab5995-20a5-5569-9c3c-294b4e182c56', 'db1e05d6-f06e-5ebd-81a9-356053d095dd', '75b5338f-065a-515a-b5cd-b741bd94cf3d', 'bb59c6f8-c122-5834-9cb7-15074f50e01a', '8384090d-c536-50c2-8219-57e1670fc294', 'e3e797ed-0245-5713-9800-887f134915e1', '1d194364-8aad-5a56-98fc-63c17986f85d', '73f99b70-47ce-5760-beb3-b25bf50db71a', '8987fe44-90d0-5484-be0d-41f82d34bdce', 'f2cd4654-881a-5aab-becf-37b44f00a9c4', '148300d6-e617-5404-83e1-fe0da05e3329', 'd62aa616-c78a-56da-9aa9-32f681b8727f', '2c3ad4de-71d4-5a44-a944-f06c8c2f7f3e', '9109618f-8878-56d1-abbd-7046eaf5b700', '5bf7d6f2-7d7b-5765-bc0c-4fb57d507adc', 'd4a7718e-202f-5589-842b-32e28634fd6b', '832f7828-4332-5256-8501-713506c8dcb7', 'c3be7072-a766-5cdc-832e-f3721aaf73db', '97ac222f-5c64-5cd4-b81a-7c164b65643e', '5c44a867-03fc-53e2-a490-bda678346c32', '6ff72fba-4819-5d95-a8e7-2895210cbf8f', '909188cd-6436-5b0f-961d-fb42faaa6d59', 'a175227d-ebb0-5852-a5fb-0130feef7ff0', '4bb40e0b-7a40-5f79-b07e-7a22952547bc', '99d93e1c-478a-5ae9-a09f-7e8837d7656e', '8bfefc03-2035-52ab-9e95-c5d32553f56a', '04e68591-0bfa-58ca-b82b-d5cad3a466a4', 'ce6dc354-3d34-5b23-9751-d867058d9a7a', 'bbe8c348-58c3-550d-b068-a113eea285df', '0f80b69d-39c8-5baf-a5db-2a885c2ec5b1', '38a95110-3792-5319-a1fa-2cb867043b70', 'b6d086aa-b41d-52fc-a202-1c30772b029f', 'a9eccd3e-70df-5121-8e98-1f3cff771afc', '8ae9c0f8-1102-5a7c-a0d6-868279f06bba', 'a26ee670-0348-5160-851a-4020cca1276d', '0df3eb88-35ed-5b4b-9424-4b3c07035cc1', '9ebd7ded-8a88-5d42-a854-4e24b73ef26e', 'd9e71d9b-4462-57de-9cbf-f7ca34090605', '7721eb43-233f-5418-831a-4e51d97da218', '49435759-2fe7-513b-8372-87ce093dc386', '7fb5693d-852b-5aec-b38e-e5cdde71701d', 'b91fa25d-45d1-5c0b-a0b1-22fc802bbbef', '8b0b3ba1-93a4-5b3d-9ced-1280a5791c28', 'eb497bf0-7908-52ff-b457-a2c947fb7e5f', 'b5ae27f4-8b83-5270-a8b0-268495762f4f', 'c57e9f47-58c6-5cfc-8ef8-b3cd208bc352', '889a2c6c-485d-5e61-87f3-aaee1dab7f82', 'cfa12de3-b652-5b8a-9970-e316ed73e102', '8b25654a-8263-5077-9bbf-0533380654ac', 'bb1ca926-5039-51fe-bade-e22f19f0ed84', '908d7239-4a3e-5dc4-b6f8-d0cdf8defccb', 'a1459967-460f-5349-b920-88e658e04a56', '0da0be56-6d6a-5894-bdfb-67247ae51ad8', '0b1764d9-fadf-5681-ab74-6023f8c741a6', '48929c59-80cd-5652-a966-7dc96f9774c0', 'a88d7537-adca-5151-a3bf-83405d3b5141', '2d388fc2-01c7-557c-9a04-5ec52a9a4801', '4d465b82-d70b-5c2c-adc2-6096673a3565', '9d67ec6b-d2a9-5546-b322-0fb9ab6aa40b', 'a9395507-ab61-5582-a12f-322d4d1281cb', 'a938f1c2-4af9-509c-ac0d-07183fd3e0bf', '0f5ed4c9-392f-5f17-a1d7-c7f571135956', 'dd5bd3fc-caeb-5c69-b2ca-5e6dd09e2966', 'c316742f-263c-5d5c-b7d9-a01e696e7ef2', '01d4b36a-5863-55db-a283-26e41f6dc9a5', '183b3b64-3006-5a51-a4d5-b39bacb4490d', '12b11ac7-b3ac-5264-8d45-6b2008f74840', '153f0efc-d3b3-5f6b-8858-7af676962fb1', '160490d0-fc4e-5253-a413-2a315b78db91', 'b595891c-6cff-5559-a906-86a60648cf1a', '4493f8fc-64a3-5eb5-92e7-f43c8f7db524', '452cab20-c37e-56eb-be06-9e1ba4400fcf', 'aadf71ea-7e89-5b62-b4a9-689631379d4a', '5eff0154-0129-5b2f-b8b3-fe2aaa09a92f', '22d9f67e-c24d-547a-ae1d-9a5cdac40ce0', '24853c60-643e-5520-91e6-483880ab5e22', 'a4167be6-c678-5480-b2e6-8a769f74d3f1', '655938c8-97ab-5644-b31c-a27389512cd4', '265cf6d9-ceba-5df0-bbfd-8989dd2650d9', '6e77294c-4b6f-5068-b856-68ad6052f137', '38b0ff08-67d7-5fe4-a9d6-738ff54140e4', 'af299d1b-2d52-5a1a-b663-b8341e18fce3', '32755d81-76fa-501b-98d8-7d56cbcab07a', '33504574-da05-5530-a4d3-6983e220293c', 'ea91e254-0fe2-5d2b-9e94-5e1c1a3c4b64', 'a9af6a83-0b79-5547-bd2f-41c1de9d3cfe', '0611c4d5-5441-5bf1-a3b5-867225df9641', 'da755511-fcef-5e51-8279-4d96183cc5c3', '10b82da8-2be8-56db-aa2e-03121995b73e', '3d102e02-0fb3-5f2a-80ae-834b50d56156', 'a311ce48-48db-5bd2-85a2-ed37001d2715', 'd8acb290-0ca8-5c04-a3b0-3df6bb2fec40', '84b3c604-19bc-5c86-af2b-8a8f8711ca68', '67fcc0d2-de1f-5fb4-913b-c45387ded821', '6c3ee312-9df0-50de-8881-a6e99b4922f6', 'f9194672-9a42-5bec-93eb-779f4ae141bd', '7a5ac733-abc6-537b-b01f-1a77b7e907aa', '32098364-39c9-5420-95c8-c354e64b1493', '00a048c6-5951-5dd5-83bf-14b8234a3d2b', '49439dc1-545f-515c-b00f-ef8e7b15d9b2', '803b68a7-5008-5d8b-9419-93517b3919ce', '6d861e8f-39dc-5a64-9419-c32a161becb2', '96ef24cb-dc8c-506b-b9a8-dcdbdf307488', '5dd16c8e-a1d4-5d50-9c4a-60acd7596db0', 'd1a613b1-0148-597a-b7d8-b14547a9f897', '70578b05-8db9-5d4a-85c0-a69b8b23f765', 'd0ba9747-02fc-561d-a363-ce42ac8555e6', '1524ec19-63df-5c68-af19-f8f2c54f49e4', '252c831b-7af4-5d1c-bae3-19137070959f', '4bc396f3-06f5-53c6-8b8e-2751385cba61', 'b702196b-a0a8-5ab3-a813-f86273b92b9c', '2cc68b00-727f-51cb-bca2-a18680e32516', 'be8aa5e4-26c9-5372-8f1a-a8d3068cb74c', '2f37ba60-228a-5bbb-809f-43b3982cd273', '5e3bf88e-af90-51bd-b0c5-de0da755e8af', '9e85413a-c2d2-50b3-9061-ea279a663771', '64baaa16-c432-5e60-84ef-f252751da479', '8591b765-7724-518b-afbf-0390de61edb4', 'b7dbb0e1-e9dd-5833-a542-5ea4f30c7eb5', 'fdb94a10-cd48-581d-8f1e-bb10568ca8a3', '6fcfd53a-512e-5916-a08d-16924c660781', 'b7f828f4-8a56-5eaf-a8cd-c790dfd58f30', '6d09cfed-65fc-50c7-8a9f-fcf07d9a7a7c', '5b4fed7c-f17b-54f5-8d8d-e447dd7186f3', '8a44179d-0268-52a2-ad80-51b76bdddd47', '76163bbb-b542-562c-b3bf-c92b286ad9fe', 'fc43f4a4-45ed-51ba-8cf5-273cf0e88838', 'e1cb6ebd-b5c1-5b44-86a7-47999fb6334a', 'cfda04a4-ef3c-59f6-ab84-73e2a8f7bbc6', '3c2cabbb-50a7-56a9-90ed-f3d4b22f5177', '2ebbbdbd-7efb-5ed2-aa92-83a3502c4f86', '2d7753c5-5256-559c-8d04-567cd34a2235', '13c6ea49-6e15-5c65-bb62-35f520c56877', '2e403f2a-e2fe-518d-9f2a-a3d73be54098', 'fd56c6cd-0f97-51a4-816c-f99cfebeb5fe', '03806093-6f33-5b7c-998c-9a8200ab4e5c', '2ac108e5-5908-5028-a0f3-743300e11ce8', 'dd93b6de-7ce8-5b0f-9861-158bc22c98b5', '80fa7ea8-9df0-54c8-b8e6-4e7a727b9378', 'd026d748-6e30-5167-a7b2-a5a7e743c312', '32321f12-b679-5296-af26-1877c2f8b967', '7f99c9a3-ad9f-5902-aa56-3ef02eac79f5', 'ac4af54a-da80-5688-a434-5eccb78152f5', 'b539215b-0569-5dc6-9d7e-0cf7fd8d2c75', '6bbc886f-ecec-595c-8f49-9c12005e368e', '6db8380d-543d-5342-b320-9c3ccb522949', '50bfe34e-e563-55f5-9bec-731b452dad40', 'dff122ff-e45f-55e0-af1c-cff9bd8d158f', '114e654a-046c-53f7-bfbb-8756e12acb1b', '40dfe1db-9238-5746-a1d2-bb59987334c6', '2d1603c4-9c6b-5049-b348-34ff5c8d37af', '87b7172d-c173-550d-8595-2d280c5633f6', 'd8f05f7f-4129-5761-bf9b-9f760890f74a', '78f72379-40b5-5507-a5ae-a2439eb7264a', '42e434eb-21a7-5717-be2d-059842e1a6f1', '5d2b0feb-e71d-50bf-affc-05188b60722a', 'd4db84ac-428e-5f31-83aa-c5aa64e7de48', 'c56454dc-628a-551f-9827-3735ccc026b1', 'd95d6c8b-5b15-5e42-8166-0327b7bc7e56', '6479d667-81dc-5bf7-b542-a24a7d146967', '1faa722f-e338-5940-a973-1e30943dca6e', '98922983-8cdb-51c9-b109-49fc0435ce5b', '03e2f716-0fe9-5765-8088-7146be3e03d3', 'ea3a0aad-2beb-5f1b-a420-01e0f6361203', 'ecdf953e-8b57-52f7-9011-8e2101f9af48', '0df83fa9-363a-5566-ad60-042788a53018', '15603578-caa7-5c20-a341-f73f231fd7d0', 'fdef83cb-b4e8-525f-b47b-79a7ac76ea6e', 'f79f2db4-d5ae-529a-9530-1915be125b36', '16401ea2-1b4a-5add-9864-1c6db0a5a400', '9ae14633-2b53-55ba-bbc2-1dc1474e0079', '40bce75e-387e-549d-9097-0b37162701be', '15a78c6f-7485-5b53-9c80-af7de79dcbc3', '1d7b9bf1-1b5f-5ee2-8c11-d960c8b039f9', 'f96f20a5-0d56-5574-b63d-7e5d76f2997b', 'aa92a43d-a65e-5ea1-b43b-c16a467f30f1', '931142cb-78da-54ee-bf26-e3bc56fbdb64', '1b0c563c-353a-5a31-a374-36ea3b316808', '87c12d8d-e50b-5cb2-9dcc-8004ec28a0f7', 'a9131cba-6665-5153-a60a-5b59de46bae8', '51bf94a3-c310-5830-bb6c-e521e0bd6c17', '2b70b45c-7c56-54cf-9457-2452739c4049', '078d92a2-e482-5f2b-9ef7-b43130bea9cf', 'af9389ff-28ce-5111-8f13-5b6c73006ae1', '81e5b132-fefe-5f4c-a775-5f84aa1ca52f', '15c9896c-8fe7-5596-8bb2-6eba8d67b5e5', 'f668b30e-4991-5605-b25d-9c7c4f97d69e', '32a85861-480f-5141-a280-7f30ee6e16b7', '2932fd9b-9225-51ba-b3d7-e3366fd7891b', 'a78f5e75-618c-519c-b180-86697904e2cc', '5ea6fe1c-93ad-5bec-9b7f-34932c3332a3', 'b6b5e820-ef15-5b37-b2c5-5a4f4dfcc765', 'af4cddc6-a17f-515e-b589-8399682d64b7', '7d7ae030-c43a-5a68-a5be-885f1b3f83d8', '2e474952-7a4f-5c5d-a2d8-f8fe4edf246f', '29bea540-7596-54f0-a9f2-95ca1c843828', '71251f15-dee1-5a96-9405-47a72d69e94f', 'a574f71b-c5dc-5498-b785-552f04593b30', '800e8a45-fafe-5643-9490-85f5116c2b07', '9c7cf620-eb0e-530f-b485-6b55aa13d5eb', 'a045694e-cfab-5fc5-bdf7-06c3af9f159f', 'a51a2856-3d26-5812-b006-82c7c2911f76') and status = 'PUBLISHED';
  select count(*) into v_bad from (values ('a0-m01', 12), ('a0-m02', 18), ('a0-m03', 20), ('a0-m04', 14), ('a0-m05', 14), ('a0-m06', 12), ('a0-m07', 12), ('a0-m08', 12), ('a0-m09', 12), ('a0-m10', 14), ('a0-mid', 30), ('a0-final', 48)) e(slug, n) left join public.assessments a on a.slug = e.slug and a.cefr = 'A0' and a.status = 'PUBLISHED'
   where a.id is null
      or (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> e.n
      or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('9e7b55a1-27a4-53e9-b5ec-13f48547eec9', 'bbbaad61-d9bc-5092-befc-55215ff50632', 'e55d2eb0-0307-5313-9e4e-56411f4a4de2', '8cfe0de4-8852-5ae6-8082-dcd02d728da9', 'ed28f90a-a290-5779-8055-0bdf1c6a75f8', 'ca1febac-f78a-5114-80de-ae27e61f41ce', '90a7fc26-c6c9-5e01-8a42-69a5032690ee', '216a88f8-bc5a-58b1-92c9-3444ecacd219', '7d912fe8-5407-5e69-a76f-bc4e2152ac83', 'd9a23dd3-d7eb-5974-94be-c44e912aef2e', '322a70bb-741e-59c9-8abc-7f0efc039923', '249fe305-0e10-5e34-a9c3-43133222d7b8', '743859a4-e82b-5fa7-bb8a-11d8c079f0da', '48649401-a4e1-5dce-bfba-e53e8f8f3f48', 'd5533458-a7a9-551e-9b03-c1f2d06f852f', '45b29446-8020-508a-8789-4f49b381eed0', '76ab5995-20a5-5569-9c3c-294b4e182c56', 'db1e05d6-f06e-5ebd-81a9-356053d095dd', '75b5338f-065a-515a-b5cd-b741bd94cf3d', 'bb59c6f8-c122-5834-9cb7-15074f50e01a', '8384090d-c536-50c2-8219-57e1670fc294', 'e3e797ed-0245-5713-9800-887f134915e1', '1d194364-8aad-5a56-98fc-63c17986f85d', '73f99b70-47ce-5760-beb3-b25bf50db71a', '8987fe44-90d0-5484-be0d-41f82d34bdce', 'f2cd4654-881a-5aab-becf-37b44f00a9c4', '148300d6-e617-5404-83e1-fe0da05e3329', 'd62aa616-c78a-56da-9aa9-32f681b8727f', '2c3ad4de-71d4-5a44-a944-f06c8c2f7f3e', '9109618f-8878-56d1-abbd-7046eaf5b700', '5bf7d6f2-7d7b-5765-bc0c-4fb57d507adc', 'd4a7718e-202f-5589-842b-32e28634fd6b', '832f7828-4332-5256-8501-713506c8dcb7', 'c3be7072-a766-5cdc-832e-f3721aaf73db', '97ac222f-5c64-5cd4-b81a-7c164b65643e', '5c44a867-03fc-53e2-a490-bda678346c32', '6ff72fba-4819-5d95-a8e7-2895210cbf8f', '909188cd-6436-5b0f-961d-fb42faaa6d59', 'a175227d-ebb0-5852-a5fb-0130feef7ff0', '4bb40e0b-7a40-5f79-b07e-7a22952547bc', '99d93e1c-478a-5ae9-a09f-7e8837d7656e', '8bfefc03-2035-52ab-9e95-c5d32553f56a', '04e68591-0bfa-58ca-b82b-d5cad3a466a4', 'ce6dc354-3d34-5b23-9751-d867058d9a7a', 'bbe8c348-58c3-550d-b068-a113eea285df', '0f80b69d-39c8-5baf-a5db-2a885c2ec5b1', '38a95110-3792-5319-a1fa-2cb867043b70', 'b6d086aa-b41d-52fc-a202-1c30772b029f', 'a9eccd3e-70df-5121-8e98-1f3cff771afc', '8ae9c0f8-1102-5a7c-a0d6-868279f06bba', 'a26ee670-0348-5160-851a-4020cca1276d', '0df3eb88-35ed-5b4b-9424-4b3c07035cc1', '9ebd7ded-8a88-5d42-a854-4e24b73ef26e', 'd9e71d9b-4462-57de-9cbf-f7ca34090605', '7721eb43-233f-5418-831a-4e51d97da218', '49435759-2fe7-513b-8372-87ce093dc386', '7fb5693d-852b-5aec-b38e-e5cdde71701d', 'b91fa25d-45d1-5c0b-a0b1-22fc802bbbef', '8b0b3ba1-93a4-5b3d-9ced-1280a5791c28', 'eb497bf0-7908-52ff-b457-a2c947fb7e5f', 'b5ae27f4-8b83-5270-a8b0-268495762f4f', 'c57e9f47-58c6-5cfc-8ef8-b3cd208bc352', '889a2c6c-485d-5e61-87f3-aaee1dab7f82', 'cfa12de3-b652-5b8a-9970-e316ed73e102', '8b25654a-8263-5077-9bbf-0533380654ac', 'bb1ca926-5039-51fe-bade-e22f19f0ed84', '908d7239-4a3e-5dc4-b6f8-d0cdf8defccb', 'a1459967-460f-5349-b920-88e658e04a56', '0da0be56-6d6a-5894-bdfb-67247ae51ad8', '0b1764d9-fadf-5681-ab74-6023f8c741a6', '48929c59-80cd-5652-a966-7dc96f9774c0', 'a88d7537-adca-5151-a3bf-83405d3b5141', '2d388fc2-01c7-557c-9a04-5ec52a9a4801', '4d465b82-d70b-5c2c-adc2-6096673a3565', '9d67ec6b-d2a9-5546-b322-0fb9ab6aa40b', 'a9395507-ab61-5582-a12f-322d4d1281cb', 'a938f1c2-4af9-509c-ac0d-07183fd3e0bf', '0f5ed4c9-392f-5f17-a1d7-c7f571135956', 'dd5bd3fc-caeb-5c69-b2ca-5e6dd09e2966', 'c316742f-263c-5d5c-b7d9-a01e696e7ef2', '01d4b36a-5863-55db-a283-26e41f6dc9a5', '183b3b64-3006-5a51-a4d5-b39bacb4490d', '12b11ac7-b3ac-5264-8d45-6b2008f74840', '153f0efc-d3b3-5f6b-8858-7af676962fb1', '160490d0-fc4e-5253-a413-2a315b78db91', 'b595891c-6cff-5559-a906-86a60648cf1a', '4493f8fc-64a3-5eb5-92e7-f43c8f7db524', '452cab20-c37e-56eb-be06-9e1ba4400fcf', 'aadf71ea-7e89-5b62-b4a9-689631379d4a', '5eff0154-0129-5b2f-b8b3-fe2aaa09a92f', '22d9f67e-c24d-547a-ae1d-9a5cdac40ce0', '24853c60-643e-5520-91e6-483880ab5e22', 'a4167be6-c678-5480-b2e6-8a769f74d3f1', '655938c8-97ab-5644-b31c-a27389512cd4', '265cf6d9-ceba-5df0-bbfd-8989dd2650d9', '6e77294c-4b6f-5068-b856-68ad6052f137', '38b0ff08-67d7-5fe4-a9d6-738ff54140e4', 'af299d1b-2d52-5a1a-b663-b8341e18fce3', '32755d81-76fa-501b-98d8-7d56cbcab07a', '33504574-da05-5530-a4d3-6983e220293c', 'ea91e254-0fe2-5d2b-9e94-5e1c1a3c4b64', 'a9af6a83-0b79-5547-bd2f-41c1de9d3cfe', '0611c4d5-5441-5bf1-a3b5-867225df9641', 'da755511-fcef-5e51-8279-4d96183cc5c3', '10b82da8-2be8-56db-aa2e-03121995b73e', '3d102e02-0fb3-5f2a-80ae-834b50d56156', 'a311ce48-48db-5bd2-85a2-ed37001d2715', 'd8acb290-0ca8-5c04-a3b0-3df6bb2fec40', '84b3c604-19bc-5c86-af2b-8a8f8711ca68', '67fcc0d2-de1f-5fb4-913b-c45387ded821', '6c3ee312-9df0-50de-8881-a6e99b4922f6', 'f9194672-9a42-5bec-93eb-779f4ae141bd', '7a5ac733-abc6-537b-b01f-1a77b7e907aa', '32098364-39c9-5420-95c8-c354e64b1493', '00a048c6-5951-5dd5-83bf-14b8234a3d2b', '49439dc1-545f-515c-b00f-ef8e7b15d9b2', '803b68a7-5008-5d8b-9419-93517b3919ce', '6d861e8f-39dc-5a64-9419-c32a161becb2', '96ef24cb-dc8c-506b-b9a8-dcdbdf307488', '5dd16c8e-a1d4-5d50-9c4a-60acd7596db0', 'd1a613b1-0148-597a-b7d8-b14547a9f897', '70578b05-8db9-5d4a-85c0-a69b8b23f765', 'd0ba9747-02fc-561d-a363-ce42ac8555e6', '1524ec19-63df-5c68-af19-f8f2c54f49e4', '252c831b-7af4-5d1c-bae3-19137070959f', '4bc396f3-06f5-53c6-8b8e-2751385cba61', 'b702196b-a0a8-5ab3-a813-f86273b92b9c', '2cc68b00-727f-51cb-bca2-a18680e32516', 'be8aa5e4-26c9-5372-8f1a-a8d3068cb74c', '2f37ba60-228a-5bbb-809f-43b3982cd273', '5e3bf88e-af90-51bd-b0c5-de0da755e8af', '9e85413a-c2d2-50b3-9061-ea279a663771', '64baaa16-c432-5e60-84ef-f252751da479', '8591b765-7724-518b-afbf-0390de61edb4', 'b7dbb0e1-e9dd-5833-a542-5ea4f30c7eb5', 'fdb94a10-cd48-581d-8f1e-bb10568ca8a3', '6fcfd53a-512e-5916-a08d-16924c660781', 'b7f828f4-8a56-5eaf-a8cd-c790dfd58f30', '6d09cfed-65fc-50c7-8a9f-fcf07d9a7a7c', '5b4fed7c-f17b-54f5-8d8d-e447dd7186f3', '8a44179d-0268-52a2-ad80-51b76bdddd47', '76163bbb-b542-562c-b3bf-c92b286ad9fe', 'fc43f4a4-45ed-51ba-8cf5-273cf0e88838', 'e1cb6ebd-b5c1-5b44-86a7-47999fb6334a', 'cfda04a4-ef3c-59f6-ab84-73e2a8f7bbc6', '3c2cabbb-50a7-56a9-90ed-f3d4b22f5177', '2ebbbdbd-7efb-5ed2-aa92-83a3502c4f86', '2d7753c5-5256-559c-8d04-567cd34a2235', '13c6ea49-6e15-5c65-bb62-35f520c56877', '2e403f2a-e2fe-518d-9f2a-a3d73be54098', 'fd56c6cd-0f97-51a4-816c-f99cfebeb5fe', '03806093-6f33-5b7c-998c-9a8200ab4e5c', '2ac108e5-5908-5028-a0f3-743300e11ce8', 'dd93b6de-7ce8-5b0f-9861-158bc22c98b5', '80fa7ea8-9df0-54c8-b8e6-4e7a727b9378', 'd026d748-6e30-5167-a7b2-a5a7e743c312', '32321f12-b679-5296-af26-1877c2f8b967', '7f99c9a3-ad9f-5902-aa56-3ef02eac79f5', 'ac4af54a-da80-5688-a434-5eccb78152f5', 'b539215b-0569-5dc6-9d7e-0cf7fd8d2c75', '6bbc886f-ecec-595c-8f49-9c12005e368e', '6db8380d-543d-5342-b320-9c3ccb522949', '50bfe34e-e563-55f5-9bec-731b452dad40', 'dff122ff-e45f-55e0-af1c-cff9bd8d158f', '114e654a-046c-53f7-bfbb-8756e12acb1b', '40dfe1db-9238-5746-a1d2-bb59987334c6', '2d1603c4-9c6b-5049-b348-34ff5c8d37af', '87b7172d-c173-550d-8595-2d280c5633f6', 'd8f05f7f-4129-5761-bf9b-9f760890f74a', '78f72379-40b5-5507-a5ae-a2439eb7264a', '42e434eb-21a7-5717-be2d-059842e1a6f1', '5d2b0feb-e71d-50bf-affc-05188b60722a', 'd4db84ac-428e-5f31-83aa-c5aa64e7de48', 'c56454dc-628a-551f-9827-3735ccc026b1', 'd95d6c8b-5b15-5e42-8166-0327b7bc7e56', '6479d667-81dc-5bf7-b542-a24a7d146967', '1faa722f-e338-5940-a973-1e30943dca6e', '98922983-8cdb-51c9-b109-49fc0435ce5b', '03e2f716-0fe9-5765-8088-7146be3e03d3', 'ea3a0aad-2beb-5f1b-a420-01e0f6361203', 'ecdf953e-8b57-52f7-9011-8e2101f9af48', '0df83fa9-363a-5566-ad60-042788a53018', '15603578-caa7-5c20-a341-f73f231fd7d0', 'fdef83cb-b4e8-525f-b47b-79a7ac76ea6e', 'f79f2db4-d5ae-529a-9530-1915be125b36', '16401ea2-1b4a-5add-9864-1c6db0a5a400', '9ae14633-2b53-55ba-bbc2-1dc1474e0079', '40bce75e-387e-549d-9097-0b37162701be', '15a78c6f-7485-5b53-9c80-af7de79dcbc3', '1d7b9bf1-1b5f-5ee2-8c11-d960c8b039f9', 'f96f20a5-0d56-5574-b63d-7e5d76f2997b', 'aa92a43d-a65e-5ea1-b43b-c16a467f30f1', '931142cb-78da-54ee-bf26-e3bc56fbdb64', '1b0c563c-353a-5a31-a374-36ea3b316808', '87c12d8d-e50b-5cb2-9dcc-8004ec28a0f7', 'a9131cba-6665-5153-a60a-5b59de46bae8', '51bf94a3-c310-5830-bb6c-e521e0bd6c17', '2b70b45c-7c56-54cf-9457-2452739c4049', '078d92a2-e482-5f2b-9ef7-b43130bea9cf', 'af9389ff-28ce-5111-8f13-5b6c73006ae1', '81e5b132-fefe-5f4c-a775-5f84aa1ca52f', '15c9896c-8fe7-5596-8bb2-6eba8d67b5e5', 'f668b30e-4991-5605-b25d-9c7c4f97d69e', '32a85861-480f-5141-a280-7f30ee6e16b7', '2932fd9b-9225-51ba-b3d7-e3366fd7891b', 'a78f5e75-618c-519c-b180-86697904e2cc', '5ea6fe1c-93ad-5bec-9b7f-34932c3332a3', 'b6b5e820-ef15-5b37-b2c5-5a4f4dfcc765', 'af4cddc6-a17f-515e-b589-8399682d64b7', '7d7ae030-c43a-5a68-a5be-885f1b3f83d8', '2e474952-7a4f-5c5d-a2d8-f8fe4edf246f', '29bea540-7596-54f0-a9f2-95ca1c843828', '71251f15-dee1-5a96-9405-47a72d69e94f', 'a574f71b-c5dc-5498-b785-552f04593b30', '800e8a45-fafe-5643-9490-85f5116c2b07', '9c7cf620-eb0e-530f-b485-6b55aa13d5eb', 'a045694e-cfab-5fc5-bdf7-06c3af9f159f', 'a51a2856-3d26-5812-b006-82c7c2911f76'));
  if v_new <> 218 or v_bad > 0 then raise exception 'Перевірки A0: нових завдань % (очікувалось 218), тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: 20261116_assessments_a0_v5.sql — 12 тестів, % нових завдань', v_new;
end $$;

commit;
