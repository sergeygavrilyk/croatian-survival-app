-- =====================================================================
-- Перевірка модуля A1.11 під програму A1 v3 · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_assessment_a1_v3.py 11 (не редагуйте вручну).
--
-- Тести: a1-m11 — по 10 завдань із нових діалогів і вправ модуля.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A1). Середину й фінал рівня A1 не змінено (їх — після всього A1).
--   * Потрібні: 20261026_curriculum_a1_v3_structure.sql і 20261026_curriculum_a1_v3_m11.sql.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A1.11 · Модуль A1.11 — Хорватська культура
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a1-m11';
  if v_aid is null then  -- новий модуль програми v3: тесту ще немає
    insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index, pass_ratio,
                                    area_min_ratio, estimated_minutes, description_ua)
    values ('45b41043-5b90-58b1-ad34-a4105afce8ee', 'a1-m11', 'module', 'Перевірка модуля A1.11', 1, 'PUBLISHED', 'claude_assessment_v1', 'A1',
            '7ed566a6-0272-5422-96e4-1ee69a1c41f1', 11, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.')
    returning id into v_aid;
  end if;
  if exists (select 1 from public.assessment_items where id = '59c456b2-276d-5db9-9b68-b16f9b84c0a0') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '7ed566a6-0272-5422-96e4-1ee69a1c41f1'::uuid then
    raise exception 'Тест a1-m11 прив’язаний не до модуля A1.11 — спершу 20261026_curriculum_a1_v3_structure.sql';
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
  ('59c456b2-276d-5db9-9b68-b16f9b84c0a0', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Бакалар, а опівночі підемо на різдвяну месу.", "Звісно, це найкращий гарнір!", "Дякую! У нас звичай роззуватися."]'::jsonb, 1, null, 'Naravno, to je najbolji prilog!', null, null, 'Прозвучало: «Naravno, to je najbolji prilog!» — «Звісно, це найкращий гарнір!».', (select id from public.lessons where id = 'f1b2093d-9699-59af-92b9-ed7bdf7fad49'), 'PUBLISHED', 'claude_assessment_v1'),
  ('6a8daca1-e45b-5727-acf0-ebe0ea7bcd1d', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Їх будували століттями, ще в середньовіччі.", "Сьогодні я пригощаю, так годиться — у мене іменини!", "На площі, буде концерт і феєрверк опівночі."]'::jsonb, 1, null, 'Danas ja častim, red je, imam imendan!', null, null, 'Прозвучало: «Danas ja častim, red je, imam imendan!» — «Сьогодні я пригощаю, так годиться — у мене іменини!».', (select id from public.lessons where id = '2fabcd03-324d-5355-b96e-022723fbeda7'), 'PUBLISHED', 'claude_assessment_v1'),
  ('efa518f8-8633-5ee0-bfbb-ef755b061980', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Пека звучить чудово. Скільки чекати?", "Добре. А хто платить за каву?", "А що це за велика фортеця?"]'::jsonb, 0, null, 'Peka zvuči odlično. Koliko se čeka?', null, null, 'Прозвучало: «Peka zvuči odlično. Koliko se čeka?» — «Пека звучить чудово. Скільки чекати?».', (select id from public.lessons where id = 'f1b2093d-9699-59af-92b9-ed7bdf7fad49'), 'PUBLISHED', 'claude_assessment_v1'),
  ('a5c996e2-fdf3-56ad-b2ba-2f212409362e', v_aid, 4, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Ivana, kako se ovdje slavi Uskrs?', '["Za to postoji cjepivo, pitajte doktoricu.", "Prije Uskrsa je korizma, a tjedan prije je Cvjetnica.", "Prvo oguli jabuke i nasjeckaj ih."]'::jsonb, 1, null, 'Ivana, kako se ovdje slavi Uskrs?', null, null, 'Діалог «Великдень»: «Ivana, kako se ovdje slavi Uskrs?» (Іванно, як тут святкують Великдень?) — «Prije Uskrsa je korizma, a tjedan prije je Cvjetnica.» (Перед Великоднем — Великий піст, а за тиждень до нього — Квітна неділя.).', (select id from public.lessons where id = 'f67bd38c-a41c-51df-b9c0-081737600fce'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d65ff2f4-0685-5217-be1c-25ccc15d4a5b', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Jesi li vidjela kip Grgura Ninskog?', '["Barem tjedan dana prije.", "Više ne, sada radim u školi.", "Jesam, i protrljala sam mu nožni palac za sreću."]'::jsonb, 2, null, 'Jesi li vidjela kip Grgura Ninskog?', null, null, 'Діалог «Прогулянка Сплітом»: «Jesi li vidjela kip Grgura Ninskog?» (Ти бачила статую Григорія Нинського?) — «Jesam, i protrljala sam mu nožni palac za sreću.» (Так, і потерла йому великий палець ноги на щастя.).', (select id from public.lessons where id = 'd9ef1de4-f4db-590e-bafd-474f84c8e03f'), 'PUBLISHED', 'claude_assessment_v1'),
  ('531b44bc-6f6f-5c14-825e-6c2dc7bfb9d3', v_aid, 6, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Kako se ovdje ljudi pozdravljaju?', '["Дякую! У нас звичай роззуватися.", "І в нас так, але господиня завжди дасть тобі тапочки.", "Чоловіки тиснуть руки, а друзі цілуються двічі в щоку."]'::jsonb, 2, null, null, 'Ivana: Dašo, uđi! Ne moraš se izuti.
Daša: Hvala! Kod nas je običaj da se izujemo.
Ivana: I kod nas, ali domaćica ti uvijek da papuče.
Daša: Kako se ovdje ljudi pozdravljaju?
Ivana: Muškarci se rukuju, a prijatelji se ljube dvaput u obraz.
Daša: Dobro je znati!', 'Ivana: Дашо, заходь! Не треба роззуватися.
Daša: Дякую! У нас звичай роззуватися.
Ivana: І в нас так, але господиня завжди дасть тобі тапочки.
Daša: Як тут люди вітаються?
Ivana: Чоловіки тиснуть руки, а друзі цілуються двічі в щоку.
Daša: Добре знати!', 'Діалог «У гостях»: «Kako se ovdje ljudi pozdravljaju?» — «Muškarci se rukuju, a prijatelji se ljube dvaput u obraz.», тобто «Чоловіки тиснуть руки, а друзі цілуються двічі в щоку.».', (select id from public.lessons where id = '2fabcd03-324d-5355-b96e-022723fbeda7'), 'PUBLISHED', 'claude_assessment_v1'),
  ('5ef2d721-684b-5097-84b3-ebd15d6a2fc8', v_aid, 7, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Ми підемо на різдвяну месу». Що ви скажете?', null, '["Ići ćemo na polnoćku.", "Živjeli!", "Sretna Nova godina!"]'::jsonb, 0, null, null, null, null, '«Ми підемо на різдвяну месу.» — «Ići ćemo na polnoćku.».', (select id from public.lessons where id = 'f67bd38c-a41c-51df-b9c0-081737600fce'), 'PUBLISHED', 'claude_assessment_v1'),
  ('fec9f8bd-1b12-5cf6-a176-bafbf0746249', v_aid, 8, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «руїни»', null, '[]'::jsonb, null, 'ruševine', null, null, null, '«руїни» — ruševine.', (select id from public.lessons where id = 'd9ef1de4-f4db-590e-bafd-474f84c8e03f'), 'PUBLISHED', 'claude_assessment_v1'),
  ('ff428718-eca0-51f2-be2a-bad1463ba063', v_aid, 9, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Це неробочий день.»', null, '["neradni", "To", "je", "dan."]'::jsonb, null, 'To je neradni dan.', null, null, null, '«Це неробочий день.» — «To je neradni dan.».', (select id from public.lessons where id = '33c041a0-e71a-55c1-94c8-64941876c6d2'), 'PUBLISHED', 'claude_assessment_v1'),
  ('a53f40ea-969c-5153-b458-feaf295eab34', v_aid, 10, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «З іменинами!»', null, '[]'::jsonb, null, 'Sretan imendan!', null, null, null, '«З іменинами!» — «Sretan imendan!».', (select id from public.lessons where id = '2fabcd03-324d-5355-b96e-022723fbeda7'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під програму A1 v3 — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('59c456b2-276d-5db9-9b68-b16f9b84c0a0', '6a8daca1-e45b-5727-acf0-ebe0ea7bcd1d', 'efa518f8-8633-5ee0-bfbb-ef755b061980', 'a5c996e2-fdf3-56ad-b2ba-2f212409362e', 'd65ff2f4-0685-5217-be1c-25ccc15d4a5b', '531b44bc-6f6f-5c14-825e-6c2dc7bfb9d3', '5ef2d721-684b-5097-84b3-ebd15d6a2fc8', 'fec9f8bd-1b12-5cf6-a176-bafbf0746249', 'ff428718-eca0-51f2-be2a-bad1463ba063', 'a53f40ea-969c-5153-b458-feaf295eab34') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a1-m11')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('59c456b2-276d-5db9-9b68-b16f9b84c0a0', '6a8daca1-e45b-5727-acf0-ebe0ea7bcd1d', 'efa518f8-8633-5ee0-bfbb-ef755b061980', 'a5c996e2-fdf3-56ad-b2ba-2f212409362e', 'd65ff2f4-0685-5217-be1c-25ccc15d4a5b', '531b44bc-6f6f-5c14-825e-6c2dc7bfb9d3', '5ef2d721-684b-5097-84b3-ebd15d6a2fc8', 'fec9f8bd-1b12-5cf6-a176-bafbf0746249', 'ff428718-eca0-51f2-be2a-bad1463ba063', 'a53f40ea-969c-5153-b458-feaf295eab34')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів A1: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірку a1-m11 оновлено — % нових завдань', v_new;
end $$;

commit;
