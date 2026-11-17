-- =====================================================================
-- Перевірки рівня A0 після нового модуля A0.6 «Kućni ljubimci» · 2026-11-17
-- Згенеровано: python3 -B scripts/gen_a0_pets_module.py assessments (не редагуйте вручну).
--
-- Запускати після 20261117_a0_pets_module.sql (назва файлу стоїть після нього — «Apply SQL» запускає за назвою). Схема 2026-11-07: модуль — 2 завдання на урок (12–20).
--   * Тести модулів a0-m06…a0-m10 → a0-m07…a0-m11 (назва «Перевірка модуля A0.N» і місце — теж); спроби користувачів
--     прив’язані до id тесту й не змінюються. Копія рядків тестів — backup.assessments_a0_20261117.
--   * Новий тест a0-m06 «Перевірка модуля A0.6» — 14 завдань (7 уроків).
--   * Тест a0-m05 — наново: 12 завдань (у модулі A0.5 тепер 6 уроків; 5 старих завдань були з уроку 37).
--   * Завдання — з діалогів, вправ і текстів уроків модуля; нових хорватських речень немає. Старі завдання a0-m05 —
--     у content_versions і DEPRECATED. Середина (a0-mid) і фінал (a0-final) не змінюються.
--   * Повторний запуск нічого не змінює.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: 20261117_a0_pets_tests_m05_m06.sql — …».
-- =====================================================================

begin;

create schema if not exists backup;
create table if not exists backup.assessments_a0_20261117 (like public.assessments including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'assessments_a0_20261117_pkey') then
    alter table backup.assessments_a0_20261117 add constraint assessments_a0_20261117_pkey primary key (id);
  end if;
end $$;
revoke all on backup.assessments_a0_20261117 from anon, authenticated;

-- 1. Тести модулів a0-m06…a0-m10 → a0-m07…a0-m11 і новий тест a0-m06
do $$
declare r record;
begin
  if exists (select 1 from public.assessments where id = 'da4de236-de05-5019-9ba1-62ac07f0add3') then return; end if;  -- уже зроблено
  if not exists (select 1 from public.modules where id = 'fd6730dd-07aa-590d-b7db-c639e3ed3919' and order_index = 6) then
    raise exception 'Спершу пакет 20261117_a0_pets_module.sql (модуль A0.6)';
  end if;
  insert into backup.assessments_a0_20261117 select * from public.assessments where cefr = 'A0' on conflict (id) do nothing;
  -- з кінця, щоб не зайняти slug наступного тесту (slug унікальний)
  for r in select a.id, m.order_index as mo from public.assessments a join public.modules m on m.id = a.module_id
            where a.cefr = 'A0' and a.kind = 'module' and a.slug ~ '^a0-m(0[6-9]|10)$' order by a.slug desc loop
    update public.assessments
       set slug = 'a0-m' || lpad(r.mo::text, 2, '0'), title_ua = 'Перевірка модуля A0.' || r.mo, order_index = r.mo
     where id = r.id;
  end loop;
  insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index,
                                  pass_ratio, area_min_ratio, estimated_minutes, description_ua)
  select 'da4de236-de05-5019-9ba1-62ac07f0add3', 'a0-m06', 'module', 'Перевірка модуля A0.6', 1, 'PUBLISHED', a.source, 'A0', 'fd6730dd-07aa-590d-b7db-c639e3ed3919', 6,
         a.pass_ratio, a.area_min_ratio, a.estimated_minutes, a.description_ua
    from public.assessments a where a.slug = 'a0-m05';
  if exists (select 1 from public.assessments a join public.modules m on m.id = a.module_id
              where a.cefr = 'A0' and a.kind = 'module' and a.slug <> 'a0-m' || lpad(m.order_index::text, 2, '0')) then
    raise exception 'Адреса тесту не збігається з номером модуля';
  end if;
end $$;

-- Перевірка модуля A0.5 · 12 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-m05' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-m05 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = 'fed5be44-6163-5c93-8f8d-43977133ca13') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '03537c9e-b657-5004-a254-389abb5c8dfc'::uuid then
    raise exception 'Тест a0-m05 прив’язаний не до модуля A0.5 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  if jsonb_array_length(v_payload -> 'items') > 0 then
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
            v_payload, 'a0_pets: перевірку модуля оновлено після нового модуля A0.6 — старі завдання');
  end if;
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 12 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~6 хв.', estimated_minutes = 6 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('fed5be44-6163-5c93-8f8d-43977133ca13', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Чудово, значить, ти тут не сама.", "Мамо, Луція запросила мене на день народження!", "Добре, віднесу його їй."]'::jsonb, 1, null, '{}'::text[], 'Mama, Lucija me pozvala na rođendansku zabavu!', null, null, 'Прозвучало: «Mama, Lucija me pozvala na rođendansku zabavu!» — «Мамо, Луція запросила мене на день народження!».', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v5'),
  ('119dd95f-102d-522a-8c9c-a394cbbe8170', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А хто цей хлопчик?", "У них є діти?", "Вона сувора?"]'::jsonb, 2, null, '{}'::text[], 'Je li stroga?', null, null, 'Прозвучало: «Je li stroga?» — «Вона сувора?».', (select id from public.lessons where id = '60130364-d731-5f5a-8b12-ac4d8d6d92e9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('37579d51-7ca2-5cd4-a3b2-8bdb33e86bc1', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Для кого цей майданчик?', 'Dječje igralište', '["Для всіх", "Для собак", "Для дітей до 12 років"]'::jsonb, 2, null, '{}'::text[], null, 'DJEČJE IGRALIŠTE
Za djecu do 12 godina.
Roditelji, pazite na djecu!
Psi ne smiju ući.', 'ДИТЯЧИЙ МАЙДАНЧИК
Для дітей до 12 років.
Батьки, наглядайте за дітьми!
Собакам заходити не можна.', 'Текст «Дитячий майданчик». Правильна відповідь: «Для дітей до 12 років».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('02c90c57-3f87-56fd-b0ad-6848489b5c8a', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Čestitam! Tko je sretnik?', '["Nas je dvanaest.", "Moj dečko Petar. Vjenčanje je u lipnju.", "Točno! Bravo."]'::jsonb, 1, null, '{}'::text[], 'Čestitam! Tko je sretnik?', null, null, 'Діалог «Весілля»: «Čestitam! Tko je sretnik?» (Вітаю! І хто ж цей щасливчик?) — «Moj dečko Petar. Vjenčanje je u lipnju.» (Мій хлопець Петар. Весілля в червні.).', (select id from public.lessons where id = 'f9ca38e4-3a61-56a6-b5f5-060933516c9a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('933de3d7-5feb-521f-8ac7-aab453d3728f', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Lijepo! Je li ona tvoja najbolja prijateljica?', '["Na trećem katu, stan broj 8.", "Jest! Sjedimo zajedno u razredu.", "Na trgu u centru. Bit će koncert i vatromet."]'::jsonb, 1, null, '{}'::text[], 'Lijepo! Je li ona tvoja najbolja prijateljica?', null, null, 'Діалог «Запрошення на день народження»: «Lijepo! Je li ona tvoja najbolja prijateljica?» (Чудово! Вона твоя найкраща подруга?) — «Jest! Sjedimo zajedno u razredu.» (Так! Ми сидимо разом у класі.).', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f581fa7b-80a8-5d91-beca-a8cd684fa473', v_aid, 6, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'U subotu u četiri. Smijem li ići?', '["Na zapadu s Poljskom, Slovačkom i Mađarskom.", "Naravno! Kupit ćemo joj lijepu igračku.", "Loše. Boli me glava i hladno mi je."]'::jsonb, 1, null, '{}'::text[], 'U subotu u četiri. Smijem li ići?', null, null, 'Діалог «Запрошення на день народження»: «U subotu u četiri. Smijem li ići?» (У суботу о четвертій. Можна мені піти?) — «Naravno! Kupit ćemo joj lijepu igračku.» (Звісно! Купимо їй гарну іграшку.).', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f00ee99b-a0d6-5546-b693-d575e1f3bb92', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Luka, čija je ovo jakna? Je li tvoja?', '["Це Маркова. Він завжди забуває свої речі!", "Тоді надішлю йому повідомлення.", "Ні. У мене чорна куртка."]'::jsonb, 2, null, '{}'::text[], null, 'Daša: Luka, čija je ovo jakna? Je li tvoja?
Luka: Nije. Ja imam crnu jaknu.
Daša: A ovaj kišobran?
Luka: To je Markov. Uvijek zaboravlja svoje stvari!
Daša: Onda ću mu poslati poruku.', 'Daša: Луко, чия це куртка? Твоя?
Luka: Ні. У мене чорна куртка.
Daša: А ця парасолька?
Luka: Це Маркова. Він завжди забуває свої речі!
Daša: Тоді надішлю йому повідомлення.', 'Діалог «Після вечірки»: «Luka, čija je ovo jakna? Je li tvoja?» — «Nije. Ja imam crnu jaknu.», тобто «Ні. У мене чорна куртка.».', (select id from public.lessons where id = '18efed0f-53a5-5717-9c4e-319627da2360'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5660c624-8d29-5b8a-bdcc-40a0a7c0f1ae', v_aid, 8, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dašo, imaš li baku i djeda?', '["Четверо онуків і дві онучки.", "Маю сина й доньку.", "Так. Бабуся й дідусь живуть у Полтаві."]'::jsonb, 2, null, '{}'::text[], null, 'Marko: Dašo, imaš li baku i djeda?
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
  ('e714d85b-15cb-5f33-8ac6-a3d3bc196001', v_aid, 9, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я заміжня». Що ви скажете?', null, '["Udana sam.", "Tko je to?", "Čestitam!"]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Я заміжня.» — «Udana sam.».', (select id from public.lessons where id = 'f9ca38e4-3a61-56a6-b5f5-060933516c9a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('24371df3-ea62-5f5a-a90e-02bd4deb8a4b', v_aid, 10, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «високий»', null, '[]'::jsonb, null, 'visok', '{}'::text[], null, null, null, '«високий» — visok.', (select id from public.lessons where id = '60130364-d731-5f5a-8b12-ac4d8d6d92e9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('676ec48a-e5b0-51dd-992c-edff4dbc235e', v_aid, 11, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Мій брат наймолодший.»', null, '["najmlađi.", "brat", "je", "Moj"]'::jsonb, null, 'Moj brat je najmlađi.', '{}'::text[], null, null, null, '«Мій брат наймолодший.» — «Moj brat je najmlađi.».', (select id from public.lessons where id = '4e003796-1ce0-5a02-8a2d-59a0de38f3dd'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4bb83b0d-74a1-5603-870c-796676fbdfea', v_aid, 12, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Чия це куртка?»', null, '[]'::jsonb, null, 'Čija je ovo jakna?', '{}'::text[], null, null, null, '«Чия це куртка?» — «Čija je ovo jakna?».', (select id from public.lessons where id = '18efed0f-53a5-5717-9c4e-319627da2360'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 (модуль — 2 завдання на урок): тест модуля A0.5 після нового модуля A0.6 «Kućni ljubimci» (рішення власника 2026-11-17). Завдання — з діалогів, вправ і текстів уроків модуля. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A0.6 · 14 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-m06' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-m06 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '09c6022d-d1e3-5e53-8d53-5fcffe7878f0') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from 'fd6730dd-07aa-590d-b7db-c639e3ed3919'::uuid then
    raise exception 'Тест a0-m06 прив’язаний не до модуля A0.6 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  if jsonb_array_length(v_payload -> 'items') > 0 then
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
            v_payload, 'a0_pets: перевірку модуля оновлено після нового модуля A0.6 — старі завдання');
  end if;
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 14 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~7 хв.', estimated_minutes = 7 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('09c6022d-d1e3-5e53-8d53-5fcffe7878f0', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Десять хвилин пішки. Там собаці можна без повідця.", "Ага, кіготь у нього задовгий. Я його підріжу.", "Он вона! Нявкає під машиною!"]'::jsonb, 0, null, '{}'::text[], 'Deset minuta pješice. Tamo pas smije bez povodca.', null, null, 'Прозвучало: «Deset minuta pješice. Tamo pas smije bez povodca.» — «Десять хвилин пішки. Там собаці можна без повідця.».', (select id from public.lessons where id = 'd3008969-de66-509c-a2d4-88987322edb5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('fad333aa-7bf2-5bc6-9de3-86eb9b009c07', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Шкода. А на терасі?", "Можна, але кого? Собаку чи кішку?", "Добрий день! Що з ним?"]'::jsonb, 0, null, '{}'::text[], 'Šteta. A na terasi?', null, null, 'Прозвучало: «Šteta. A na terasi?» — «Шкода. А на терасі?».', (select id from public.lessons where id = '64ad8ee5-741e-54e5-b31d-88f1130e3f3e'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9a953aa0-8c57-5a75-8a56-bc9f009a9af4', v_aid, 3, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А хто це так рано кричить?", "Добре. Де найближчий пляж для собак?", "Добрий день. Ви подорожуєте з твариною?"]'::jsonb, 1, null, '{}'::text[], 'Može. Gdje je najbliža plaža za pse?', null, null, 'Прозвучало: «Može. Gdje je najbliža plaža za pse?» — «Добре. Де найближчий пляж для собак?».', (select id from public.lessons where id = 'd3008969-de66-509c-a2d4-88987322edb5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('393c2a1a-1f73-55d2-9a3d-059c3f2ddd0f', v_aid, 4, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Ні, маленький, але багато гавкає!", "Добре. Спокійно, Медо!", "Дивись, Дашо, коні на лузі!"]'::jsonb, 1, null, '{}'::text[], 'Dobro. Mirno, Medo!', null, null, 'Прозвучало: «Dobro. Mirno, Medo!» — «Добре. Спокійно, Медо!».', (select id from public.lessons where id = 'fa7fd153-275f-5214-b759-2db31e50a4b4'), 'PUBLISHED', 'claude_assessment_v5'),
  ('cb88baf4-a2b4-55d1-b1bd-ca55a46a3000', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Imam mačku, zove se Murka. A ti?', '["Desetak, možda dvadesetak.", "Ja imam psa. Svako jutro ga šetam u parku.", "Dobar dan. Zovem se Darja Kovalenko."]'::jsonb, 1, null, '{}'::text[], 'Imam mačku, zove se Murka. A ti?', null, null, 'Діалог «У тебе є тварина?»: «Imam mačku, zove se Murka. A ti?» (У мене є кішка, її звати Мурка. А в тебе?) — «Ja imam psa. Svako jutro ga šetam u parku.» (У мене собака. Щоранку вигулюю його в парку.).', (select id from public.lessons where id = '40b9da1d-1686-5b78-8317-0439067d5f8e'), 'PUBLISHED', 'claude_assessment_v5'),
  ('34041b9f-e971-5217-803f-ef1f8f6a642d', v_aid, 6, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Zar na balkonu nema zaštitne mreže?', '["Ima, ali u mreži je mala rupa.", "U Ukrajini sam bila inženjerka.", "Nula devet osam, pedeset tri, sedamdeset dva, devedeset jedan."]'::jsonb, 0, null, '{}'::text[], 'Zar na balkonu nema zaštitne mreže?', null, null, 'Діалог «Кішка втекла»: «Zar na balkonu nema zaštitne mreže?» (Хіба на балконі немає захисної сітки?) — «Ima, ali u mreži je mala rupa.» (Є, але в сітці маленька дірка.).', (select id from public.lessons where id = '5c421c03-f070-538e-b152-8c50b31f4daf'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1190166b-5ecd-5e9f-a309-0406b33ecfd2', v_aid, 7, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dobar dan! Želite li jahati?', '["Sedam, ne osam.", "Želimo, ali nikad nismo jahale.", "Večeras ne mogu, radim do ponoći."]'::jsonb, 1, null, '{}'::text[], 'Dobar dan! Želite li jahati?', null, null, 'Діалог «Їзда верхи»: «Dobar dan! Želite li jahati?» (Добрий день! Хочете поїздити верхи?) — «Želimo, ali nikad nismo jahale.» (Хочемо, але ми ніколи не їздили верхи.).', (select id from public.lessons where id = '5ffbe419-6abc-574e-907e-2dc427276abd'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9e443e8a-aacd-500c-a9aa-de3907d79d2d', v_aid, 8, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Super! Bruno, idi se igrati! Koje je pasmine vaš pas?', '["Ні, не кусається. Бачите, махає хвостом! Не бійтеся.", "Можна, це парк для собак. Тут його можна відпустити.", "Не породистий, це метис. Його звати Медо."]'::jsonb, 2, null, '{}'::text[], null, 'Luka: Dobar dan! Smije li moj pas ovdje bez povodca?
Daša: Smije, ovo je park za pse. Ovdje ga možete pustiti.
Luka: Super! Bruno, idi se igrati! Koje je pasmine vaš pas?
Daša: Nije čiste pasmine, mješanac je. Zove se Medo.
Luka: Medo njuši Bruna. Grize li?
Daša: Ne, ne grize. Vidite, maše repom! Ne bojte se.', 'Luka: Добрий день! Моєму собаці тут можна без повідця?
Daša: Можна, це парк для собак. Тут його можна відпустити.
Luka: Чудово! Бруно, йди погратися! Якої породи ваш собака?
Daša: Не породистий, це метис. Його звати Медо.
Luka: Медо обнюхує Бруно. Він кусається?
Daša: Ні, не кусається. Бачите, махає хвостом! Не бійтеся.', 'Діалог «У парку для собак»: «Super! Bruno, idi se igrati! Koje je pasmine vaš pas?» — «Nije čiste pasmine, mješanac je. Zove se Medo.», тобто «Не породистий, це метис. Його звати Медо.».', (select id from public.lessons where id = '64ad8ee5-741e-54e5-b31d-88f1130e3f3e'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4c393b83-8df2-5269-ad6b-f146d1e60c9f', v_aid, 9, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Može, ali koga? Psa ili mačku?', '["Тоді кошеня? Або хом’ячка, він маленький.", "Не знаю, у Марка алергія на шерсть.", "Собаку треба вигулювати щодня, а ми працюємо цілий день."]'::jsonb, 2, null, '{}'::text[], null, 'Darja: Dašo, djeca žele kućnog ljubimca. Što misliš?
Daša: Može, ali koga? Psa ili mačku?
Darja: Psa treba šetati svaki dan, a mi radimo cijeli dan.
Daša: Onda mače? Ili hrčka, on je mali.
Darja: Ne znam, Marko je alergičan na dlaku.
Daša: Onda kornjača ili ribica! One nemaju dlaku.', 'Darja: Дашо, діти хочуть домашнього улюбленця. Що думаєш?
Daša: Можна, але кого? Собаку чи кішку?
Darja: Собаку треба вигулювати щодня, а ми працюємо цілий день.
Daša: Тоді кошеня? Або хом’ячка, він маленький.
Darja: Не знаю, у Марка алергія на шерсть.
Daša: Тоді черепаха або рибка! У них немає шерсті.', 'Діалог «Кого візьмемо?»: «Može, ali koga? Psa ili mačku?» — «Psa treba šetati svaki dan, a mi radimo cijeli dan.», тобто «Собаку треба вигулювати щодня, а ми працюємо цілий день.».', (select id from public.lessons where id = '40b9da1d-1686-5b78-8317-0439067d5f8e'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c88b3127-9af0-5eb7-a01b-03f6ca14ec23', v_aid, 10, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Можна поїздити верхи?». Що ви скажете?', null, '["Ne bojte se, on ne grize.", "Mogu li jahati?", "Evo putovnice mog psa."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Можна поїздити верхи?» — «Mogu li jahati?».', (select id from public.lessons where id = '5ffbe419-6abc-574e-907e-2dc427276abd'), 'PUBLISHED', 'claude_assessment_v5'),
  ('917f4a79-d580-551d-8b49-ae130648b2ec', v_aid, 11, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «У вас є засіб проти кліщів?». Що ви скажете?', null, '["Imate li sredstvo protiv krpelja?", "Želimo udomiti psa.", "Jeste li vidjeli moju mačku?"]'::jsonb, 0, null, '{}'::text[], null, null, null, '«У вас є засіб проти кліщів?» — «Imate li sredstvo protiv krpelja?».', (select id from public.lessons where id = 'fa7fd153-275f-5214-b759-2db31e50a4b4'), 'PUBLISHED', 'claude_assessment_v5'),
  ('26c0fcf0-4e22-5a38-ba6b-3c0252bbcdae', v_aid, 12, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «повідець»', null, '[]'::jsonb, null, 'povodac', '{}'::text[], null, null, null, '«повідець» — povodac.', (select id from public.lessons where id = '40b9da1d-1686-5b78-8317-0439067d5f8e'), 'PUBLISHED', 'claude_assessment_v5'),
  ('63321bbd-6b2a-5588-9cda-8d5eff82048b', v_aid, 13, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я щодня вигулюю собаку.»', null, '["psa.", "dan", "šetam", "Svaki"]'::jsonb, null, 'Svaki dan šetam psa.', '{}'::text[], null, null, null, '«Я щодня вигулюю собаку.» — «Svaki dan šetam psa.».', (select id from public.lessons where id = '40b9da1d-1686-5b78-8317-0439067d5f8e'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a0e2e8d5-ee82-5b1d-99cb-9af4d56e5200', v_aid, 14, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Ви не бачили цього собаки?»', null, '[]'::jsonb, null, 'Jeste li vidjeli ovog psa?', '{}'::text[], null, null, null, '«Ви не бачили цього собаки?» — «Jeste li vidjeli ovog psa?».', (select id from public.lessons where id = '0a9c3362-e49a-5e17-bb46-9f3a345b67e4'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 (модуль — 2 завдання на урок): тест модуля A0.6 після нового модуля A0.6 «Kućni ljubimci» (рішення власника 2026-11-17). Завдання — з діалогів, вправ і текстів уроків модуля. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('fed5be44-6163-5c93-8f8d-43977133ca13', '119dd95f-102d-522a-8c9c-a394cbbe8170', '37579d51-7ca2-5cd4-a3b2-8bdb33e86bc1', '02c90c57-3f87-56fd-b0ad-6848489b5c8a', '933de3d7-5feb-521f-8ac7-aab453d3728f', 'f581fa7b-80a8-5d91-beca-a8cd684fa473', 'f00ee99b-a0d6-5546-b693-d575e1f3bb92', '5660c624-8d29-5b8a-bdcc-40a0a7c0f1ae', 'e714d85b-15cb-5f33-8ac6-a3d3bc196001', '24371df3-ea62-5f5a-a90e-02bd4deb8a4b', '676ec48a-e5b0-51dd-992c-edff4dbc235e', '4bb83b0d-74a1-5603-870c-796676fbdfea', '09c6022d-d1e3-5e53-8d53-5fcffe7878f0', 'fad333aa-7bf2-5bc6-9de3-86eb9b009c07', '9a953aa0-8c57-5a75-8a56-bc9f009a9af4', '393c2a1a-1f73-55d2-9a3d-059c3f2ddd0f', 'cb88baf4-a2b4-55d1-b1bd-ca55a46a3000', '34041b9f-e971-5217-803f-ef1f8f6a642d', '1190166b-5ecd-5e9f-a309-0406b33ecfd2', '9e443e8a-aacd-500c-a9aa-de3907d79d2d', '4c393b83-8df2-5269-ad6b-f146d1e60c9f', 'c88b3127-9af0-5eb7-a01b-03f6ca14ec23', '917f4a79-d580-551d-8b49-ae130648b2ec', '26c0fcf0-4e22-5a38-ba6b-3c0252bbcdae', '63321bbd-6b2a-5588-9cda-8d5eff82048b', 'a0e2e8d5-ee82-5b1d-99cb-9af4d56e5200') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a join public.modules m on m.id = a.module_id
   where a.cefr = 'A0' and a.kind = 'module' and a.status = 'PUBLISHED'
     and (a.slug <> 'a0-m' || lpad(m.order_index::text, 2, '0') or a.title_ua <> 'Перевірка модуля A0.' || m.order_index
          or (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED')
             <> greatest(12, least(20, 2 * (select count(*) from public.lessons l join public.units u on u.id = l.unit_id
                                              where u.module_id = m.id and l.status = 'PUBLISHED'))));
  if v_new <> 26 or v_bad > 0 or (select count(*) from public.assessments where cefr = 'A0' and kind = 'module') <> 11 then
    raise exception 'Перевірки A0: нових завдань % (очікувалось 26), тестів з помилкою %', v_new, v_bad;
  end if;
  raise notice 'Готово: 20261117_a0_pets_tests_m05_m06.sql — 11 тестів модулів A0, % нових завдань (a0-m05, a0-m06)', v_new;
end $$;

commit;
