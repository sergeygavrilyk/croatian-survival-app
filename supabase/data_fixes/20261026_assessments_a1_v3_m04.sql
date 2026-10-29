-- =====================================================================
-- Перевірка модуля A1.4 під програму A1 v3 · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_assessment_a1_v3.py 4 (не редагуйте вручну).
--
-- Тести: a1-m04 — по 10 завдань із нових діалогів і вправ модуля.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A1). Середину й фінал рівня A1 не змінено (їх — після всього A1).
--   * Потрібні: 20261026_curriculum_a1_v3_structure.sql і 20261026_curriculum_a1_v3_m04.sql.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A1.4 · Модуль A1.4 — Транспорт
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a1-m04';
  if v_aid is null then  -- новий модуль програми v3: тесту ще немає
    insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index, pass_ratio,
                                    area_min_ratio, estimated_minutes, description_ua)
    values ('4b86bcaf-9004-5047-9490-2e949beb6c34', 'a1-m04', 'module', 'Перевірка модуля A1.4', 1, 'PUBLISHED', 'claude_assessment_v1', 'A1',
            'e092e4e7-b706-5e70-84b6-eaa665020394', 4, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.')
    returning id into v_aid;
  end if;
  if exists (select 1 from public.assessment_items where id = 'f913c8de-abde-56cc-a435-6755ccdd25ca') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from 'e092e4e7-b706-5e70-84b6-eaa665020394'::uuid then
    raise exception 'Тест a1-m04 прив’язаний не до модуля A1.4 — спершу 20261026_curriculum_a1_v3_structure.sql';
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
  ('f913c8de-abde-56cc-a435-6755ccdd25ca', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Є, але він дорожчий — двадцять п’ять євро.", "Зазвичай завтра. Ми надішлемо її на вашу адресу.", "Так, квиток в один бік і бронювання місця."]'::jsonb, 2, null, 'Da, jednosmjernu kartu i rezervaciju sjedala.', null, null, 'Прозвучало: «Da, jednosmjernu kartu i rezervaciju sjedala.» — «Так, квиток в один бік і бронювання місця.».', (select id from public.lessons where id = 'cae7a47d-7fb4-5b03-a8cc-5a0df2ccd92f'), 'PUBLISHED', 'claude_assessment_v1'),
  ('7314f699-ff8e-5555-8aa4-409eb1e07fb0', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А якщо я запізнюся?", "Бажаєте місце біля вікна?", "Пляж далеко звідси?"]'::jsonb, 1, null, 'Želite li sjedalo do prozora?', null, null, 'Прозвучало: «Želite li sjedalo do prozora?» — «Бажаєте місце біля вікна?».', (select id from public.lessons where id = '69ec0776-4f69-5f86-afac-6652234a7da5'), 'PUBLISHED', 'claude_assessment_v1'),
  ('ff8d5bd3-706d-58a9-9642-78454691ff2c', v_aid, 3, 'A1', 'reading', 'understand', 'multiple_choice', 'Що треба зробити з квитком у трамваї?', 'Kako kupiti kartu na automatu', '["Віддати водієві", "Прокомпостувати", "Нічого"]'::jsonb, 1, null, null, '1. Odaberite jezik.
2. Odaberite kartu: jednosmjernu ili povratnu.
3. Upišite broj putnika.
4. Platite karticom ili kovanicama.
5. Uzmite kartu i ostatak novca.
Karta vrijedi 90 minuta. Poništite je u tramvaju ili autobusu.', '1. Виберіть мову.
2. Виберіть квиток: в один бік чи туди й назад.
3. Введіть кількість пасажирів.
4. Заплатіть карткою або монетами.
5. Заберіть квиток і решту.
Квиток дійсний 90 хвилин. Прокомпостуйте його в трамваї чи автобусі.', 'Текст «Як купити квиток в автоматі». Правильна відповідь: «Прокомпостувати».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('f3d2acc7-a179-5333-93cd-38dffc3f2d10', v_aid, 4, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Kada će auto biti gotov?', '["Subotom se izležavam, a nedjeljom idem na izlet.", "Na košulji nedostaje jedan gumb na ovratniku.", "Sutra popodne, ako stigne rezervni dio."]'::jsonb, 2, null, 'Kada će auto biti gotov?', null, null, 'Діалог «Дивний звук»: «Kada će auto biti gotov?» (Коли машина буде готова?) — «Sutra popodne, ako stigne rezervni dio.» (Завтра по обіді, якщо надійде запчастина.).', (select id from public.lessons where id = 'cd5db261-a421-511d-8100-f86bf2335bbe'), 'PUBLISHED', 'claude_assessment_v1'),
  ('768d8203-fda8-591e-8c56-6b11e74ae823', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Kada se čuje, kad krenete ili u vožnji?', '["Nažalost nemam, imam sastanak cijeli dan.", "Napravi mi kajganu i jedan tost, molim te.", "Kad mijenjam brzinu. I svijetli lampica akumulatora."]'::jsonb, 2, null, 'Kada se čuje, kad krenete ili u vožnji?', null, null, 'Діалог «Дивний звук»: «Kada se čuje, kad krenete ili u vožnji?» (Коли це чути — коли рушаєте чи під час руху?) — «Kad mijenjam brzinu. I svijetli lampica akumulatora.» (Коли перемикаю передачу. І світиться індикатор акумулятора.).', (select id from public.lessons where id = 'cd5db261-a421-511d-8100-f86bf2335bbe'), 'PUBLISHED', 'claude_assessment_v1'),
  ('8c5b10af-0d83-5c95-be22-4eb0e455cd44', v_aid, 6, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Imate li i električni bicikl?', '["Є, але він дорожчий — двадцять п’ять євро.", "Працюють. Перевірте й дзвоник перед поїздкою.", "П’ятнадцять євро, із шоломом і замком."]'::jsonb, 0, null, null, 'Daša: Dobar dan, koliko košta iznajmljivanje bicikla na dan?
Radnik: Petnaest eura, s kacigom i lokotom.
Daša: Imate li i električni bicikl?
Radnik: Imamo, ali je skuplji, dvadeset pet eura.
Daša: Dobro, uzimam obični. Rade li kočnice?
Radnik: Rade. Provjerite i zvonce prije vožnje.', 'Daša: Добрий день, скільки коштує прокат велосипеда на день?
Radnik: П’ятнадцять євро, із шоломом і замком.
Daša: У вас є й електровелосипед?
Radnik: Є, але він дорожчий — двадцять п’ять євро.
Daša: Добре, беру звичайний. Гальма працюють?
Radnik: Працюють. Перевірте й дзвоник перед поїздкою.', 'Діалог «Прокат велосипедів»: «Imate li i električni bicikl?» — «Imamo, ali je skuplji, dvadeset pet eura.», тобто «Є, але він дорожчий — двадцять п’ять євро.».', (select id from public.lessons where id = '0b04119b-4d38-5d99-8237-caa95fdcfd95'), 'PUBLISHED', 'claude_assessment_v1'),
  ('9514e0d5-59cb-5348-94a0-1e89d96b0de2', v_aid, 7, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Їдь обережно!». Що ви скажете?', null, '["Jesi li već na poslu?", "Mogu li dobiti sjedalo do prolaza?", "Vozi pažljivo!"]'::jsonb, 2, null, null, null, null, '«Їдь обережно!» — «Vozi pažljivo!».', (select id from public.lessons where id = '0b04119b-4d38-5d99-8237-caa95fdcfd95'), 'PUBLISHED', 'claude_assessment_v1'),
  ('92cfb34c-1b7d-5b7f-a813-a83b3cdb5dd9', v_aid, 8, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «таксометр»', null, '[]'::jsonb, null, 'taksimetar', null, null, null, '«таксометр» — taksimetar.', (select id from public.lessons where id = '458ee6ec-31d1-5758-adef-03612626088a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('c78ca2bb-74d0-55fd-92ef-1344d18067e6', v_aid, 9, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Куди ти йдеш увечері?»', null, '["navečer?", "Kamo", "ideš"]'::jsonb, null, 'Kamo ideš navečer?', null, null, null, '«Куди ти йдеш увечері?» — «Kamo ideš navečer?».', (select id from public.lessons where id = '12012395-7359-503b-89c9-ee1807f89d6b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('6d4a5e6c-a252-50f1-8248-c0f6f6a1c80f', v_aid, 10, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Двигун дивно звучить.»', null, '[]'::jsonb, null, 'Motor ima čudan zvuk.', null, null, null, '«Двигун дивно звучить.» — «Motor ima čudan zvuk.».', (select id from public.lessons where id = 'cd5db261-a421-511d-8100-f86bf2335bbe'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під програму A1 v3 — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('f913c8de-abde-56cc-a435-6755ccdd25ca', '7314f699-ff8e-5555-8aa4-409eb1e07fb0', 'ff8d5bd3-706d-58a9-9642-78454691ff2c', 'f3d2acc7-a179-5333-93cd-38dffc3f2d10', '768d8203-fda8-591e-8c56-6b11e74ae823', '8c5b10af-0d83-5c95-be22-4eb0e455cd44', '9514e0d5-59cb-5348-94a0-1e89d96b0de2', '92cfb34c-1b7d-5b7f-a813-a83b3cdb5dd9', 'c78ca2bb-74d0-55fd-92ef-1344d18067e6', '6d4a5e6c-a252-50f1-8248-c0f6f6a1c80f') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a1-m04')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('f913c8de-abde-56cc-a435-6755ccdd25ca', '7314f699-ff8e-5555-8aa4-409eb1e07fb0', 'ff8d5bd3-706d-58a9-9642-78454691ff2c', 'f3d2acc7-a179-5333-93cd-38dffc3f2d10', '768d8203-fda8-591e-8c56-6b11e74ae823', '8c5b10af-0d83-5c95-be22-4eb0e455cd44', '9514e0d5-59cb-5348-94a0-1e89d96b0de2', '92cfb34c-1b7d-5b7f-a813-a83b3cdb5dd9', 'c78ca2bb-74d0-55fd-92ef-1344d18067e6', '6d4a5e6c-a252-50f1-8248-c0f6f6a1c80f')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів A1: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірку a1-m04 оновлено — % нових завдань', v_new;
end $$;

commit;
