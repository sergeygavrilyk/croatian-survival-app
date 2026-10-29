-- =====================================================================
-- Програма A1 v3 · структура: 13 модулів, теперішні 89 уроків — на нові місця · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_curriculum_a1_v3.py structure (не редагуйте вручну).
--
-- Програма погоджена власником 2026-10-26 (content/reviews/2026-10-21_curriculum_a1_v3_program.md).
--   * Модулі A1.1–A1.6 — ті самі (нові назви й описи); «Здоров’я» → A1.8, «Соціальне життя» → A1.9 «Люди й вільний час»,
--     «Хорватія» → A1.10 «Подорожуємо Хорватією», «Підсумок» → A1.13; нові модулі A1.7 «Комп’ютер, телефон та інтернет»,
--     A1.11 «Хорватська культура», A1.12 «Діти, навчання й документи». id модуля лишається з темою; перевірки модулів
--     (a1-m07 → a1-m08, a1-m08 → a1-m09, a1-m09 → a1-m10, a1-m10 → a1-m13) і тексти для читання — теж за своїм модулем.
--   * Уроки переносяться на свої місця в програмі (уроки 23, 26, 71 → A1.7; 25 → A1.5; 74, 76, 77, 79, 80 → A1.11;
--     82, 84–88 → A1.12); місця 19 нових уроків лишаються вільними до SQL їхнього модуля. Назви уроків поки старі,
--     номери «Урок N» — підряд.
--   * Нічого не видаляє; стара версія уроків — у content_versions, модулів і юнітів — у backup.modules_a1_20261026 /
--     backup.units_a1_20261026. Повторний запуск нічого не змінює.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- Далі: 20261026_curriculum_a1_v3_m01.sql (модуль A1.1).
-- =====================================================================

begin;

create schema if not exists backup;
create table if not exists backup.modules_a1_20261026 (like public.modules including defaults);
create table if not exists backup.units_a1_20261026 (like public.units including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'modules_a1_20261026_pkey') then
    alter table backup.modules_a1_20261026 add constraint modules_a1_20261026_pkey primary key (id);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'units_a1_20261026_pkey') then
    alter table backup.units_a1_20261026 add constraint units_a1_20261026_pkey primary key (id);
  end if;
end $$;
revoke all on backup.modules_a1_20261026, backup.units_a1_20261026 from anon, authenticated;

do $$
begin
  if exists (select 1 from public.modules where id = '09e7c668-b622-56b2-82e9-b1c0c0db54c6') then
    raise notice 'Структуру A1 v3 уже застосовано — пропускаю';
    return;
  end if;
  if (select count(*) from public.lessons where level_code = 'A1' and status = 'PUBLISHED') <> 89 then
    raise exception 'Очікувалось 89 уроків A1 (теперішня програма) — спершу звірте базу';
  end if;
  -- 1. стара версія: модулі й юніти A1 — копія в backup (content_versions їх не приймає), уроки — у content_versions
  insert into backup.modules_a1_20261026 select x.* from public.modules x where x.level_code = 'A1' on conflict (id) do nothing;
  insert into backup.units_a1_20261026 select x.* from public.units x join public.modules m on m.id = x.module_id
   where m.level_code = 'A1' on conflict (id) do nothing;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'lesson', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = x.id), 0) + 1,
         to_jsonb(x), 'curriculum_a1_v3: нова програма A1 (13 модулів) — стара версія' from public.lessons x where x.level_code = 'A1';
  -- 2. модулі: тимчасово +100 (unique (level_code, order_index)), потім — нові місця, назви, описи
  update public.modules set order_index = order_index + 100 where level_code = 'A1' and order_index < 100;
  update public.modules set order_index = 1, title_ua = 'Модуль A1.1 — Мій день', title_hr = 'Modul A1.1 — Moj dan', description = 'Розпорядок дня, домашні справи, вихідні й сон. Теперішній час, дієслова із se.', status = 'PUBLISHED'
   where id = '329c44d2-afb3-5e9e-a04e-0ab31405ad9f';
  update public.units set title_ua = 'Мій день', title_hr = 'Moj dan', objectives = '["Розповісти про свій день від ранку до вечора", "Сказати, як часто ви щось робите", "Домовитися про справи й плани на тиждень"]'::jsonb where id = '893000a6-3e62-528c-8ecf-e644f677823c';
  update public.modules set order_index = 2, title_ua = 'Модуль A1.2 — Їжа й кухня', title_hr = 'Modul A1.2 — Hrana i kuhinja', description = 'Сніданок, покупки продуктів, посуд і рецепти. Знахідний відмінок, числа з іменниками.', status = 'PUBLISHED'
   where id = '8d02296d-bc46-5537-9a9b-c678fe5ff1c9';
  update public.units set title_ua = 'Їжа й кухня', title_hr = 'Hrana i kuhinja', objectives = '["Купити продукти в потрібній кількості", "Приготувати страву за рецептом", "Накрити на стіл і замовити столик"]'::jsonb where id = '54c21ee3-db66-5d1e-9eca-7223a2e6f6e4';
  update public.modules set order_index = 3, title_ua = 'Модуль A1.3 — Покупки', title_hr = 'Modul A1.3 — Kupovina', description = 'Одяг, косметика, прикраси, повернення товару. Короткі форми mi / ti, порівняння.', status = 'PUBLISHED'
   where id = '88e77a6f-1140-5f26-b724-0ae15477637a';
  update public.units set title_ua = 'Покупки', title_hr = 'Kupovina', objectives = '["Сказати, що вам подобається", "Приміряти й обрати одяг", "Повернути або обміняти товар"]'::jsonb where id = '480b3ca1-58c7-5b6f-8a52-eff47d53b3e4';
  update public.modules set order_index = 4, title_ua = 'Модуль A1.4 — Транспорт', title_hr = 'Modul A1.4 — Promet i prijevoz', description = 'Міський і міжміський транспорт, авто й велосипед. Kamo? і Gdje?, орудний відмінок.', status = 'PUBLISHED'
   where id = 'e092e4e7-b706-5e70-84b6-eaa665020394';
  update public.units set title_ua = 'Транспорт', title_hr = 'Promet i prijevoz', objectives = '["Сказати, куди і чим ви їдете", "Купити квиток і дізнатися розклад", "Заправити авто й домовитися в сервісі"]'::jsonb where id = '72a3eec1-fb04-5e99-a0ea-da4f6bc07ed5';
  update public.modules set order_index = 5, title_ua = 'Модуль A1.5 — Житло', title_hr = 'Modul A1.5 — Stanovanje', description = 'Оренда, район, переїзд, поломки й сусіди. Місцевий і родовий відмінки з прикметниками.', status = 'PUBLISHED'
   where id = '82ce9ca7-ea90-5413-94a6-d69b1a1cd72b';
  update public.units set title_ua = 'Житло', title_hr = 'Stanovanje', objectives = '["Знайти квартиру й описати свій район", "Пояснити, що не працює", "Познайомитися із сусідами й правилами будинку"]'::jsonb where id = 'c80b7070-95f0-54de-b4dd-90d024f5b830';
  update public.modules set order_index = 6, title_ua = 'Модуль A1.6 — Робота', title_hr = 'Modul A1.6 — Posao', description = 'Професії, пошук роботи, співбесіда, перший день. Модальні дієслова, минулий час (основи).', status = 'PUBLISHED'
   where id = '03c65998-2648-5d02-9254-f67ce765fe27';
  update public.units set title_ua = 'Робота', title_hr = 'Posao', objectives = '["Розповісти про свою роботу", "Пройти просту співбесіду", "Розповісти, як минув робочий день"]'::jsonb where id = '874caaa6-f5e5-5c4f-acf4-cfdb0e510116';
  insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
  values ('09e7c668-b622-56b2-82e9-b1c0c0db54c6', 'A1', 'Модуль A1.7 — Комп’ютер, телефон та інтернет', 'Modul A1.7 — Računalo, mobitel i internet', 'Комп’ютер, телефон, пошта, акаунти й онлайн-послуги. Минулий час: питання й заперечення.', 7, 'PUBLISHED');
  insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
  values ('f5b3441e-2c2a-52bf-825e-a316aae00588', '09e7c668-b622-56b2-82e9-b1c0c0db54c6', 'Комп’ютер, телефон та інтернет', 'Računalo, mobitel i internet', '["Назвати техніку й пояснити, що не працює", "Написати лист чи повідомлення", "Користуватися онлайн-послугами"]'::jsonb, 1, 'PUBLISHED');
  update public.modules set order_index = 8, title_ua = 'Модуль A1.8 — Здоров’я', title_hr = 'Modul A1.8 — Zdravlje', description = 'Лікар, органи, симптоми, аптека й здоровий спосіб життя. Наказовий спосіб, давальний у скаргах.', status = 'PUBLISHED'
   where id = 'e4b28ab0-2aa7-5d37-885b-6908dc14e17b';
  update public.units set title_ua = 'Здоров’я', title_hr = 'Zdravlje', objectives = '["Записатися до лікаря й описати симптоми", "Зрозуміти, як приймати ліки", "Розповісти, що з вами сталося"]'::jsonb where id = '2eec2289-6a8a-5fb2-9988-e52433d5a242';
  update public.modules set order_index = 9, title_ua = 'Модуль A1.9 — Люди й вільний час', title_hr = 'Modul A1.9 — Ljudi i slobodno vrijeme', description = 'Звертання, почуття, запрошення, хобі й стосунки. Кличний відмінок, сполучники, неозначені займенники.', status = 'PUBLISHED'
   where id = '4fae6fe1-6bf2-5eef-9023-f7425b151c9e';
  update public.units set title_ua = 'Люди й вільний час', title_hr = 'Ljudi i slobodno vrijeme', objectives = '["Звернутися до людини й запросити її", "Розповісти про хобі й почуття", "Висловити думку"]'::jsonb where id = '0df70119-403a-517e-af33-8073d14fca03';
  update public.modules set order_index = 10, title_ua = 'Модуль A1.10 — Подорожуємо Хорватією', title_hr = 'Modul A1.10 — Putujemo Hrvatskom', description = 'Погода, відпустка, краї Хорватії, Далмація, острови й природа. Майбутній час (основи).', status = 'PUBLISHED'
   where id = '4a99a045-1da4-5ac1-be05-74811dd7d630';
  update public.units set title_ua = 'Подорожуємо Хорватією', title_hr = 'Putujemo Hrvatskom', objectives = '["Розповісти про плани на відпустку", "Поговорити про погоду й прогноз", "Розповісти про краї й природу Хорватії"]'::jsonb where id = '704b6312-30cc-5a3c-94ff-c2a2dfd1b17c';
  insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
  values ('7ed566a6-0272-5422-96e4-1ee69a1c41f1', 'A1', 'Модуль A1.11 — Хорватська культура', 'Modul A1.11 — Hrvatska kultura', 'Старе місто, кухня, звичаї й свята Хорватії. Нагадування минулого й майбутнього часу.', 11, 'PUBLISHED');
  insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
  values ('1fb51162-343f-5587-89cf-d2594a3091db', '7ed566a6-0272-5422-96e4-1ee69a1c41f1', 'Хорватська культура', 'Hrvatska kultura', '["Розповісти про пам’ятки старого міста", "Розповісти про хорватську кухню й звичаї", "Привітати зі святом"]'::jsonb, 1, 'PUBLISHED');
  insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
  values ('5a6eadc1-9da1-52c0-a50d-943a3fbffe70', 'A1', 'Модуль A1.12 — Діти, навчання й документи', 'Modul A1.12 — Djeca, škola i dokumenti', 'Садок, школа, курси, пошта, банк і документи. Родовий відмінок часу, svoj.', 12, 'PUBLISHED');
  insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
  values ('e0fc94e0-c41d-5f59-adf7-db0c97c4575c', '5a6eadc1-9da1-52c0-a50d-943a3fbffe70', 'Діти, навчання й документи', 'Djeca, škola i dokumenti', '["Записати дитину в садок чи школу", "Впоратися на пошті й у банку", "Продовжити перебування в Хорватії"]'::jsonb, 1, 'PUBLISHED');
  update public.modules set order_index = 13, title_ua = 'Модуль A1.13 — Підсумок A1: моє життя в Хорватії', title_hr = 'Modul A1.13 — Moj život u Hrvatskoj', description = 'Підсумок A1: розповідь про себе, своє минуле й плани.', status = 'PUBLISHED'
   where id = '34064af4-9715-5f07-b87c-a5e28eb8127b';
  update public.units set title_ua = 'Підсумок A1: моє життя в Хорватії', title_hr = 'Moj život u Hrvatskoj', objectives = '["Розповісти про себе", "Розповісти, як усе почалося в Хорватії", "Розповісти про свої плани"]'::jsonb where id = '90bce36b-b9de-5168-b120-49d8e33aa6cf';
  -- 2а. перевірки модулів і тексти для читання йдуть за своїм модулем (новий номер); стара версія — у content_versions
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = x.id), 0) + 1,
         to_jsonb(x), 'curriculum_a1_v3: нова програма A1 (13 модулів) — стара версія' from public.assessments x where x.slug = 'a1-m10' and x.module_id = '34064af4-9715-5f07-b87c-a5e28eb8127b';
  update public.assessments set slug = 'a1-m13', title_ua = 'Перевірка модуля A1.13', order_index = 13
   where slug = 'a1-m10' and module_id = '34064af4-9715-5f07-b87c-a5e28eb8127b';
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'reading_text', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'reading_text' and entity_id = x.id), 0) + 1,
         to_jsonb(x), 'curriculum_a1_v3: нова програма A1 (13 модулів) — стара версія' from public.reading_texts x where x.cefr = 'A1' and x.module_order = 10;
  update public.reading_texts set module_order = 13 where cefr = 'A1' and module_order = 10;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = x.id), 0) + 1,
         to_jsonb(x), 'curriculum_a1_v3: нова програма A1 (13 модулів) — стара версія' from public.assessments x where x.slug = 'a1-m09' and x.module_id = '4a99a045-1da4-5ac1-be05-74811dd7d630';
  update public.assessments set slug = 'a1-m10', title_ua = 'Перевірка модуля A1.10', order_index = 10
   where slug = 'a1-m09' and module_id = '4a99a045-1da4-5ac1-be05-74811dd7d630';
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'reading_text', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'reading_text' and entity_id = x.id), 0) + 1,
         to_jsonb(x), 'curriculum_a1_v3: нова програма A1 (13 модулів) — стара версія' from public.reading_texts x where x.cefr = 'A1' and x.module_order = 9;
  update public.reading_texts set module_order = 10 where cefr = 'A1' and module_order = 9;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = x.id), 0) + 1,
         to_jsonb(x), 'curriculum_a1_v3: нова програма A1 (13 модулів) — стара версія' from public.assessments x where x.slug = 'a1-m08' and x.module_id = '4fae6fe1-6bf2-5eef-9023-f7425b151c9e';
  update public.assessments set slug = 'a1-m09', title_ua = 'Перевірка модуля A1.9', order_index = 9
   where slug = 'a1-m08' and module_id = '4fae6fe1-6bf2-5eef-9023-f7425b151c9e';
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'reading_text', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'reading_text' and entity_id = x.id), 0) + 1,
         to_jsonb(x), 'curriculum_a1_v3: нова програма A1 (13 модулів) — стара версія' from public.reading_texts x where x.cefr = 'A1' and x.module_order = 8;
  update public.reading_texts set module_order = 9 where cefr = 'A1' and module_order = 8;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = x.id), 0) + 1,
         to_jsonb(x), 'curriculum_a1_v3: нова програма A1 (13 модулів) — стара версія' from public.assessments x where x.slug = 'a1-m07' and x.module_id = 'e4b28ab0-2aa7-5d37-885b-6908dc14e17b';
  update public.assessments set slug = 'a1-m08', title_ua = 'Перевірка модуля A1.8', order_index = 8
   where slug = 'a1-m07' and module_id = 'e4b28ab0-2aa7-5d37-885b-6908dc14e17b';
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'reading_text', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'reading_text' and entity_id = x.id), 0) + 1,
         to_jsonb(x), 'curriculum_a1_v3: нова програма A1 (13 модулів) — стара версія' from public.reading_texts x where x.cefr = 'A1' and x.module_order = 7;
  update public.reading_texts set module_order = 8 where cefr = 'A1' and module_order = 7;
  -- 3. уроки: тимчасово +1000 (unique (unit_id, order_index)), потім — юніт і місце за програмою
  update public.lessons set order_index = order_index + 1000 where level_code = 'A1' and order_index < 1000;
  update public.lessons l set unit_id = t.unit_id, order_index = t.o
    from (values
      ('4bf48151-be83-5108-bc92-645c0603a1a3'::uuid, '893000a6-3e62-528c-8ecf-e644f677823c'::uuid, 1),
      ('458b73de-d6b3-5bd3-98ad-c243a2fff03f'::uuid, '893000a6-3e62-528c-8ecf-e644f677823c'::uuid, 7),
      ('959e879f-a28d-5bed-9c09-16cff91ef456'::uuid, '893000a6-3e62-528c-8ecf-e644f677823c'::uuid, 3),
      ('9c38f909-9275-5194-9a6e-f799c6e416ce'::uuid, '893000a6-3e62-528c-8ecf-e644f677823c'::uuid, 4),
      ('54f17cf7-3c17-5978-b400-b6b6888c9f84'::uuid, '893000a6-3e62-528c-8ecf-e644f677823c'::uuid, 2),
      ('63a4a6d8-1cae-5e0e-90ff-98efcfe8b4c7'::uuid, '893000a6-3e62-528c-8ecf-e644f677823c'::uuid, 8),
      ('d43d6c65-1ce3-5c72-9ecd-cce2ed200fc2'::uuid, '893000a6-3e62-528c-8ecf-e644f677823c'::uuid, 5),
      ('1968c7d5-4e3a-5b1e-92f6-88df711e9c54'::uuid, '893000a6-3e62-528c-8ecf-e644f677823c'::uuid, 6),
      ('3365f423-e694-5b55-baa1-3205fba11aff'::uuid, '893000a6-3e62-528c-8ecf-e644f677823c'::uuid, 9),
      ('5e4a1c56-3931-58bb-81af-cb598966da77'::uuid, '54c21ee3-db66-5d1e-9eca-7223a2e6f6e4'::uuid, 9),
      ('3e652232-866b-5edf-ac05-d61ee7a325fe'::uuid, '54c21ee3-db66-5d1e-9eca-7223a2e6f6e4'::uuid, 7),
      ('46a89cf5-41e0-50a2-99b1-f4e66a5ff146'::uuid, '54c21ee3-db66-5d1e-9eca-7223a2e6f6e4'::uuid, 3),
      ('1e8c2d0e-28f6-5873-aa9f-5d0ad2567fb8'::uuid, '54c21ee3-db66-5d1e-9eca-7223a2e6f6e4'::uuid, 5),
      ('6af82dd3-beb1-54cf-9c1b-44ec3cb12a35'::uuid, '54c21ee3-db66-5d1e-9eca-7223a2e6f6e4'::uuid, 10),
      ('bb7bc159-cb40-5a8a-91b7-c6da05c6342a'::uuid, '54c21ee3-db66-5d1e-9eca-7223a2e6f6e4'::uuid, 1),
      ('17fcd38a-e295-5849-9ba3-1ef240c6be78'::uuid, '54c21ee3-db66-5d1e-9eca-7223a2e6f6e4'::uuid, 8),
      ('ae33e31a-f937-5305-908e-3d957df15f6a'::uuid, '54c21ee3-db66-5d1e-9eca-7223a2e6f6e4'::uuid, 4),
      ('2c192d05-f259-53b6-a6ec-55ebfb25ec01'::uuid, '54c21ee3-db66-5d1e-9eca-7223a2e6f6e4'::uuid, 11),
      ('7042ff57-9a20-514a-ab80-71b6f63579f7'::uuid, '480b3ca1-58c7-5b6f-8a52-eff47d53b3e4'::uuid, 6),
      ('0c19643d-57ff-5030-820f-ba330833ea88'::uuid, '54c21ee3-db66-5d1e-9eca-7223a2e6f6e4'::uuid, 2),
      ('6a7b0f42-510b-521e-9cc0-f77b2659d838'::uuid, '480b3ca1-58c7-5b6f-8a52-eff47d53b3e4'::uuid, 7),
      ('9ba8e62a-83fd-5b08-9e01-760bc0f7219f'::uuid, '480b3ca1-58c7-5b6f-8a52-eff47d53b3e4'::uuid, 4),
      ('35203547-5f9a-5857-95a0-3a0d596f715d'::uuid, 'f5b3441e-2c2a-52bf-825e-a316aae00588'::uuid, 3),
      ('c8297811-44ed-55a2-8cb5-d1bd9b8a6a73'::uuid, '480b3ca1-58c7-5b6f-8a52-eff47d53b3e4'::uuid, 2),
      ('de93d3ab-6769-5daf-9560-8858285a8136'::uuid, 'c80b7070-95f0-54de-b4dd-90d024f5b830'::uuid, 3),
      ('31bbedca-4b51-5478-8513-df5cb996ffd9'::uuid, 'f5b3441e-2c2a-52bf-825e-a316aae00588'::uuid, 2),
      ('91d4c9b3-c9a8-5e94-8691-6683835c375b'::uuid, '480b3ca1-58c7-5b6f-8a52-eff47d53b3e4'::uuid, 8),
      ('0ef458c5-53cf-530a-99cf-4ccd6e0132e5'::uuid, '72a3eec1-fb04-5e99-a0ea-da4f6bc07ed5'::uuid, 2),
      ('cae7a47d-7fb4-5b03-a8cc-5a0df2ccd92f'::uuid, '72a3eec1-fb04-5e99-a0ea-da4f6bc07ed5'::uuid, 3),
      ('69ec0776-4f69-5f86-afac-6652234a7da5'::uuid, '72a3eec1-fb04-5e99-a0ea-da4f6bc07ed5'::uuid, 5),
      ('458ee6ec-31d1-5758-adef-03612626088a'::uuid, '72a3eec1-fb04-5e99-a0ea-da4f6bc07ed5'::uuid, 6),
      ('d6ca64d8-4c71-5936-a930-51e400f5681d'::uuid, '72a3eec1-fb04-5e99-a0ea-da4f6bc07ed5'::uuid, 8),
      ('0b04119b-4d38-5d99-8237-caa95fdcfd95'::uuid, '72a3eec1-fb04-5e99-a0ea-da4f6bc07ed5'::uuid, 7),
      ('06f927cf-f38c-51b5-a1f9-696698ad23fb'::uuid, '72a3eec1-fb04-5e99-a0ea-da4f6bc07ed5'::uuid, 9),
      ('cd5db261-a421-511d-8100-f86bf2335bbe'::uuid, '72a3eec1-fb04-5e99-a0ea-da4f6bc07ed5'::uuid, 10),
      ('c1b32b15-8f3c-5f75-bba9-e831d544ec7b'::uuid, '72a3eec1-fb04-5e99-a0ea-da4f6bc07ed5'::uuid, 4),
      ('278947e3-ae50-5818-abd7-7f07b8ab5c44'::uuid, 'c80b7070-95f0-54de-b4dd-90d024f5b830'::uuid, 1),
      ('8fc3399d-0405-5517-9358-d3ad6308d860'::uuid, 'c80b7070-95f0-54de-b4dd-90d024f5b830'::uuid, 6),
      ('a42b9121-2ec0-5064-909b-f59f315b3c4a'::uuid, 'c80b7070-95f0-54de-b4dd-90d024f5b830'::uuid, 9),
      ('b69a8cca-4918-562f-8ae5-22f8d7ba2f76'::uuid, 'c80b7070-95f0-54de-b4dd-90d024f5b830'::uuid, 5),
      ('23f3aad6-4447-5b75-9dd1-891773457f7e'::uuid, 'c80b7070-95f0-54de-b4dd-90d024f5b830'::uuid, 4),
      ('f296bc84-8059-5981-a5b9-9d4531627e18'::uuid, 'c80b7070-95f0-54de-b4dd-90d024f5b830'::uuid, 10),
      ('62b118f9-a5e0-587b-82f8-39de181ddeba'::uuid, 'c80b7070-95f0-54de-b4dd-90d024f5b830'::uuid, 8),
      ('dd2c0f3c-19f2-5c73-b448-a0631cd97e69'::uuid, 'c80b7070-95f0-54de-b4dd-90d024f5b830'::uuid, 7),
      ('d813e9c0-2331-59d8-90f1-cea7e9a61c7d'::uuid, '874caaa6-f5e5-5c4f-acf4-cfdb0e510116'::uuid, 2),
      ('99088d92-0f0c-52c2-b51f-548d903fc9ef'::uuid, '874caaa6-f5e5-5c4f-acf4-cfdb0e510116'::uuid, 7),
      ('92858dbe-ede1-5bc5-b80a-c796c5598019'::uuid, '874caaa6-f5e5-5c4f-acf4-cfdb0e510116'::uuid, 4),
      ('4d6f3498-2cc5-54a0-b4e4-c66add71ef12'::uuid, '874caaa6-f5e5-5c4f-acf4-cfdb0e510116'::uuid, 5),
      ('e806dd39-4d38-5781-ad2d-949961dd95f9'::uuid, '874caaa6-f5e5-5c4f-acf4-cfdb0e510116'::uuid, 8),
      ('b369f01f-4a84-57b4-98cb-150d236f4d7f'::uuid, '874caaa6-f5e5-5c4f-acf4-cfdb0e510116'::uuid, 1),
      ('c9b87882-5e31-5485-aea7-0169216466a8'::uuid, '874caaa6-f5e5-5c4f-acf4-cfdb0e510116'::uuid, 3),
      ('2c56a486-dbbb-5102-b7cb-754c59cf94c3'::uuid, '874caaa6-f5e5-5c4f-acf4-cfdb0e510116'::uuid, 6),
      ('ee016ba8-5160-581d-b440-1bcb7647173d'::uuid, '874caaa6-f5e5-5c4f-acf4-cfdb0e510116'::uuid, 9),
      ('08e31e8b-f8f7-5a80-89ed-093bc68dae03'::uuid, '2eec2289-6a8a-5fb2-9988-e52433d5a242'::uuid, 1),
      ('123e68fa-291f-5ad6-8403-51db7020d641'::uuid, '2eec2289-6a8a-5fb2-9988-e52433d5a242'::uuid, 5),
      ('878c0712-e4e5-5a7d-aab5-510c781da0c7'::uuid, '2eec2289-6a8a-5fb2-9988-e52433d5a242'::uuid, 3),
      ('431b51ad-baa3-5387-94ac-a7273fdb9263'::uuid, '2eec2289-6a8a-5fb2-9988-e52433d5a242'::uuid, 4),
      ('247c3445-6ba3-50f0-a441-9073d6734451'::uuid, '2eec2289-6a8a-5fb2-9988-e52433d5a242'::uuid, 6),
      ('d5dee6c5-f510-57b9-a1ed-4b0a60e8e09a'::uuid, '2eec2289-6a8a-5fb2-9988-e52433d5a242'::uuid, 8),
      ('293af384-4ee2-5746-80a8-e8ffdc7009bc'::uuid, '2eec2289-6a8a-5fb2-9988-e52433d5a242'::uuid, 7),
      ('4bcf3852-7d28-5ceb-80ca-1870222d6834'::uuid, '2eec2289-6a8a-5fb2-9988-e52433d5a242'::uuid, 10),
      ('0df023bb-17fb-5006-91bf-3b911dd30295'::uuid, '2eec2289-6a8a-5fb2-9988-e52433d5a242'::uuid, 9),
      ('3ed8282d-b9fa-5151-b184-73fd352f8ba7'::uuid, '0df70119-403a-517e-af33-8073d14fca03'::uuid, 3),
      ('1c16ceee-5f42-536a-98b4-7dcabaa3be6d'::uuid, '0df70119-403a-517e-af33-8073d14fca03'::uuid, 5),
      ('ec1b7982-c092-5504-a233-4162f92f512a'::uuid, '0df70119-403a-517e-af33-8073d14fca03'::uuid, 9),
      ('fac55dd6-0020-5997-8461-45ee2f94d3c5'::uuid, '0df70119-403a-517e-af33-8073d14fca03'::uuid, 2),
      ('dde31f54-28b8-505b-aba6-3e578601fccb'::uuid, '0df70119-403a-517e-af33-8073d14fca03'::uuid, 4),
      ('0d0547ed-c0ef-53bd-bfe4-c482c84c40f4'::uuid, '0df70119-403a-517e-af33-8073d14fca03'::uuid, 10),
      ('e61e3942-cd86-5f75-9eb5-d878242125bf'::uuid, '0df70119-403a-517e-af33-8073d14fca03'::uuid, 6),
      ('631c7f59-de43-5081-adb7-77bdf23ce805'::uuid, '0df70119-403a-517e-af33-8073d14fca03'::uuid, 7),
      ('4edd1556-f088-5d14-8f59-529b35747609'::uuid, 'f5b3441e-2c2a-52bf-825e-a316aae00588'::uuid, 7),
      ('0cb42e87-0ece-5e12-a07c-05cb5c370157'::uuid, '704b6312-30cc-5a3c-94ff-c2a2dfd1b17c'::uuid, 1),
      ('71ab330d-abbe-57a7-870e-77e59daf3627'::uuid, '704b6312-30cc-5a3c-94ff-c2a2dfd1b17c'::uuid, 5),
      ('f67bd38c-a41c-51df-b9c0-081737600fce'::uuid, '1fb51162-343f-5587-89cf-d2594a3091db'::uuid, 4),
      ('8633c234-d638-57f1-ad92-1c78be43fb07'::uuid, '704b6312-30cc-5a3c-94ff-c2a2dfd1b17c'::uuid, 3),
      ('2fabcd03-324d-5355-b96e-022723fbeda7'::uuid, '1fb51162-343f-5587-89cf-d2594a3091db'::uuid, 3),
      ('f1b2093d-9699-59af-92b9-ed7bdf7fad49'::uuid, '1fb51162-343f-5587-89cf-d2594a3091db'::uuid, 2),
      ('84a20a00-701a-5ce5-a3c8-fca72986f912'::uuid, '704b6312-30cc-5a3c-94ff-c2a2dfd1b17c'::uuid, 6),
      ('d9ef1de4-f4db-590e-bafd-474f84c8e03f'::uuid, '1fb51162-343f-5587-89cf-d2594a3091db'::uuid, 1),
      ('33c041a0-e71a-55c1-94c8-64941876c6d2'::uuid, '1fb51162-343f-5587-89cf-d2594a3091db'::uuid, 5),
      ('fc1baff0-0e48-5676-bd3c-47d88d31e582'::uuid, '90bce36b-b9de-5168-b120-49d8e33aa6cf'::uuid, 1),
      ('1c468857-b9aa-5143-aa84-6ea02aa2443c'::uuid, 'e0fc94e0-c41d-5f59-adf7-db0c97c4575c'::uuid, 5),
      ('4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d'::uuid, '90bce36b-b9de-5168-b120-49d8e33aa6cf'::uuid, 2),
      ('42c31cfb-8680-5450-8453-245f3abd475a'::uuid, 'e0fc94e0-c41d-5f59-adf7-db0c97c4575c'::uuid, 1),
      ('fee5b77b-dc3b-5fd5-818a-c5496e95c23b'::uuid, 'e0fc94e0-c41d-5f59-adf7-db0c97c4575c'::uuid, 6),
      ('fe2839bc-fd72-5e8b-bc0e-937d48a90aa8'::uuid, 'e0fc94e0-c41d-5f59-adf7-db0c97c4575c'::uuid, 7),
      ('11b565a4-1e2a-50d2-8d9d-c05e84371402'::uuid, 'e0fc94e0-c41d-5f59-adf7-db0c97c4575c'::uuid, 4),
      ('692e9310-7a5b-5adf-9f0a-a66b72fc5459'::uuid, 'e0fc94e0-c41d-5f59-adf7-db0c97c4575c'::uuid, 8),
      ('dbb91fa1-4a97-5c04-99a8-8ac1d508b952'::uuid, '90bce36b-b9de-5168-b120-49d8e33aa6cf'::uuid, 3)
    ) as t(id, unit_id, o)
   where l.id = t.id;
end $$;

-- Наскрізні номери всіх уроків A1 («Урок N: …» / «Lekcija N: …»); стара назва — у content_versions
do $$
declare r record; v_payload jsonb; v_new_ua text; v_new_hr text;
begin
  for r in select l.id, l.title_ua, l.title_hr,
                  row_number() over (order by m.order_index, u.order_index, l.order_index) as n
             from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
            where m.level_code = 'A1' and l.status = 'PUBLISHED' loop
    v_new_ua := regexp_replace(r.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':');
    v_new_hr := regexp_replace(r.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':');
    if v_new_ua is not distinct from r.title_ua and v_new_hr is not distinct from r.title_hr then continue; end if;
    select to_jsonb(l) into v_payload from public.lessons l where l.id = r.id;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'curriculum_a1_v3: новий номер уроку ' || r.n);
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_modules int; v_placed int; v_titles int; v_lessons int;
begin
  select count(*) into v_modules from public.modules where level_code = 'A1' and order_index between 1 and 13 and status = 'PUBLISHED';
  select count(*) into v_placed from (values ('4bf48151-be83-5108-bc92-645c0603a1a3'::uuid, 1, 1), ('458b73de-d6b3-5bd3-98ad-c243a2fff03f'::uuid, 1, 7), ('959e879f-a28d-5bed-9c09-16cff91ef456'::uuid, 1, 3), ('9c38f909-9275-5194-9a6e-f799c6e416ce'::uuid, 1, 4), ('54f17cf7-3c17-5978-b400-b6b6888c9f84'::uuid, 1, 2), ('63a4a6d8-1cae-5e0e-90ff-98efcfe8b4c7'::uuid, 1, 8), ('d43d6c65-1ce3-5c72-9ecd-cce2ed200fc2'::uuid, 1, 5), ('1968c7d5-4e3a-5b1e-92f6-88df711e9c54'::uuid, 1, 6), ('3365f423-e694-5b55-baa1-3205fba11aff'::uuid, 1, 9), ('5e4a1c56-3931-58bb-81af-cb598966da77'::uuid, 2, 9), ('3e652232-866b-5edf-ac05-d61ee7a325fe'::uuid, 2, 7), ('46a89cf5-41e0-50a2-99b1-f4e66a5ff146'::uuid, 2, 3), ('1e8c2d0e-28f6-5873-aa9f-5d0ad2567fb8'::uuid, 2, 5), ('6af82dd3-beb1-54cf-9c1b-44ec3cb12a35'::uuid, 2, 10), ('bb7bc159-cb40-5a8a-91b7-c6da05c6342a'::uuid, 2, 1), ('17fcd38a-e295-5849-9ba3-1ef240c6be78'::uuid, 2, 8), ('ae33e31a-f937-5305-908e-3d957df15f6a'::uuid, 2, 4), ('2c192d05-f259-53b6-a6ec-55ebfb25ec01'::uuid, 2, 11), ('7042ff57-9a20-514a-ab80-71b6f63579f7'::uuid, 3, 6), ('0c19643d-57ff-5030-820f-ba330833ea88'::uuid, 2, 2), ('6a7b0f42-510b-521e-9cc0-f77b2659d838'::uuid, 3, 7), ('9ba8e62a-83fd-5b08-9e01-760bc0f7219f'::uuid, 3, 4), ('35203547-5f9a-5857-95a0-3a0d596f715d'::uuid, 7, 3), ('c8297811-44ed-55a2-8cb5-d1bd9b8a6a73'::uuid, 3, 2), ('de93d3ab-6769-5daf-9560-8858285a8136'::uuid, 5, 3), ('31bbedca-4b51-5478-8513-df5cb996ffd9'::uuid, 7, 2), ('91d4c9b3-c9a8-5e94-8691-6683835c375b'::uuid, 3, 8), ('0ef458c5-53cf-530a-99cf-4ccd6e0132e5'::uuid, 4, 2), ('cae7a47d-7fb4-5b03-a8cc-5a0df2ccd92f'::uuid, 4, 3), ('69ec0776-4f69-5f86-afac-6652234a7da5'::uuid, 4, 5), ('458ee6ec-31d1-5758-adef-03612626088a'::uuid, 4, 6), ('d6ca64d8-4c71-5936-a930-51e400f5681d'::uuid, 4, 8), ('0b04119b-4d38-5d99-8237-caa95fdcfd95'::uuid, 4, 7), ('06f927cf-f38c-51b5-a1f9-696698ad23fb'::uuid, 4, 9), ('cd5db261-a421-511d-8100-f86bf2335bbe'::uuid, 4, 10), ('c1b32b15-8f3c-5f75-bba9-e831d544ec7b'::uuid, 4, 4), ('278947e3-ae50-5818-abd7-7f07b8ab5c44'::uuid, 5, 1), ('8fc3399d-0405-5517-9358-d3ad6308d860'::uuid, 5, 6), ('a42b9121-2ec0-5064-909b-f59f315b3c4a'::uuid, 5, 9), ('b69a8cca-4918-562f-8ae5-22f8d7ba2f76'::uuid, 5, 5), ('23f3aad6-4447-5b75-9dd1-891773457f7e'::uuid, 5, 4), ('f296bc84-8059-5981-a5b9-9d4531627e18'::uuid, 5, 10), ('62b118f9-a5e0-587b-82f8-39de181ddeba'::uuid, 5, 8), ('dd2c0f3c-19f2-5c73-b448-a0631cd97e69'::uuid, 5, 7), ('d813e9c0-2331-59d8-90f1-cea7e9a61c7d'::uuid, 6, 2), ('99088d92-0f0c-52c2-b51f-548d903fc9ef'::uuid, 6, 7), ('92858dbe-ede1-5bc5-b80a-c796c5598019'::uuid, 6, 4), ('4d6f3498-2cc5-54a0-b4e4-c66add71ef12'::uuid, 6, 5), ('e806dd39-4d38-5781-ad2d-949961dd95f9'::uuid, 6, 8), ('b369f01f-4a84-57b4-98cb-150d236f4d7f'::uuid, 6, 1), ('c9b87882-5e31-5485-aea7-0169216466a8'::uuid, 6, 3), ('2c56a486-dbbb-5102-b7cb-754c59cf94c3'::uuid, 6, 6), ('ee016ba8-5160-581d-b440-1bcb7647173d'::uuid, 6, 9), ('08e31e8b-f8f7-5a80-89ed-093bc68dae03'::uuid, 8, 1), ('123e68fa-291f-5ad6-8403-51db7020d641'::uuid, 8, 5), ('878c0712-e4e5-5a7d-aab5-510c781da0c7'::uuid, 8, 3), ('431b51ad-baa3-5387-94ac-a7273fdb9263'::uuid, 8, 4), ('247c3445-6ba3-50f0-a441-9073d6734451'::uuid, 8, 6), ('d5dee6c5-f510-57b9-a1ed-4b0a60e8e09a'::uuid, 8, 8), ('293af384-4ee2-5746-80a8-e8ffdc7009bc'::uuid, 8, 7), ('4bcf3852-7d28-5ceb-80ca-1870222d6834'::uuid, 8, 10), ('0df023bb-17fb-5006-91bf-3b911dd30295'::uuid, 8, 9), ('3ed8282d-b9fa-5151-b184-73fd352f8ba7'::uuid, 9, 3), ('1c16ceee-5f42-536a-98b4-7dcabaa3be6d'::uuid, 9, 5), ('ec1b7982-c092-5504-a233-4162f92f512a'::uuid, 9, 9), ('fac55dd6-0020-5997-8461-45ee2f94d3c5'::uuid, 9, 2), ('dde31f54-28b8-505b-aba6-3e578601fccb'::uuid, 9, 4), ('0d0547ed-c0ef-53bd-bfe4-c482c84c40f4'::uuid, 9, 10), ('e61e3942-cd86-5f75-9eb5-d878242125bf'::uuid, 9, 6), ('631c7f59-de43-5081-adb7-77bdf23ce805'::uuid, 9, 7), ('4edd1556-f088-5d14-8f59-529b35747609'::uuid, 7, 7), ('0cb42e87-0ece-5e12-a07c-05cb5c370157'::uuid, 10, 1), ('71ab330d-abbe-57a7-870e-77e59daf3627'::uuid, 10, 5), ('f67bd38c-a41c-51df-b9c0-081737600fce'::uuid, 11, 4), ('8633c234-d638-57f1-ad92-1c78be43fb07'::uuid, 10, 3), ('2fabcd03-324d-5355-b96e-022723fbeda7'::uuid, 11, 3), ('f1b2093d-9699-59af-92b9-ed7bdf7fad49'::uuid, 11, 2), ('84a20a00-701a-5ce5-a3c8-fca72986f912'::uuid, 10, 6), ('d9ef1de4-f4db-590e-bafd-474f84c8e03f'::uuid, 11, 1), ('33c041a0-e71a-55c1-94c8-64941876c6d2'::uuid, 11, 5), ('fc1baff0-0e48-5676-bd3c-47d88d31e582'::uuid, 13, 1), ('1c468857-b9aa-5143-aa84-6ea02aa2443c'::uuid, 12, 5), ('4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d'::uuid, 13, 2), ('42c31cfb-8680-5450-8453-245f3abd475a'::uuid, 12, 1), ('fee5b77b-dc3b-5fd5-818a-c5496e95c23b'::uuid, 12, 6), ('fe2839bc-fd72-5e8b-bc0e-937d48a90aa8'::uuid, 12, 7), ('11b565a4-1e2a-50d2-8d9d-c05e84371402'::uuid, 12, 4), ('692e9310-7a5b-5adf-9f0a-a66b72fc5459'::uuid, 12, 8), ('dbb91fa1-4a97-5c04-99a8-8ac1d508b952'::uuid, 13, 3)) as t(id, m, o)
    join public.lessons l on l.id = t.id and l.order_index = t.o
    join public.units u on u.id = l.unit_id join public.modules md on md.id = u.module_id and md.order_index = t.m;
  select count(*) into v_lessons from public.lessons where level_code = 'A1' and status = 'PUBLISHED';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A1' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  if v_modules <> 13 then raise exception 'A1: модулів %, очікувалось 13', v_modules; end if;
  if v_placed <> 89 then raise exception 'A1: на своїх місцях % уроків з 89', v_placed; end if;
  if v_titles > 0 then raise exception 'A1: % уроків з неправильним номером у назві', v_titles; end if;
  raise notice 'Готово: програма A1 v3 — 13 модулів, уроків %', v_lessons;
end $$;

commit;
