-- =====================================================================
-- Перевірка модуля A1.8 під програму A1 v3 · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_assessment_a1_v3.py 8 (не редагуйте вручну).
--
-- Тести: a1-m08 — по 10 завдань із нових діалогів і вправ модуля.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A1). Середину й фінал рівня A1 не змінено (їх — після всього A1).
--   * Потрібні: 20261026_curriculum_a1_v3_structure.sql і 20261026_curriculum_a1_v3_m08.sql.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A1.8 · Модуль A1.8 — Здоров’я
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a1-m08';
  if v_aid is null then  -- новий модуль програми v3: тесту ще немає
    insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index, pass_ratio,
                                    area_min_ratio, estimated_minutes, description_ua)
    values ('3a977488-3eb3-5208-8925-8fc1cc825196', 'a1-m08', 'module', 'Перевірка модуля A1.8', 1, 'PUBLISHED', 'claude_assessment_v1', 'A1',
            'e4b28ab0-2aa7-5d37-885b-6908dc14e17b', 8, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.')
    returning id into v_aid;
  end if;
  if exists (select 1 from public.assessment_items where id = '5760741b-4c07-51fe-b746-93f220894b63') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from 'e4b28ab0-2aa7-5d37-885b-6908dc14e17b'::uuid then
    raise exception 'Тест a1-m08 прив’язаний не до модуля A1.8 — спершу 20261026_curriculum_a1_v3_structure.sql';
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
  ('5760741b-4c07-51fe-b746-93f220894b63', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Даріє, ти цілий день чхаєш.", "Термометр показав тридцять вісім з половиною.", "Лікарка спершу огляне немовля."]'::jsonb, 2, null, 'Doktorica će prvo pregledati dojenče.', null, null, 'Прозвучало: «Doktorica će prvo pregledati dojenče.» — «Лікарка спершу огляне немовля.».', (select id from public.lessons where id = '0df023bb-17fb-5006-91bf-3b911dd30295'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e7b09216-5a76-50fe-8530-457f4e8a8823', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Якщо це невідкладно, приходьте сьогодні до обіду.", "Це може бути печінка або жовчний міхур.", "Покажи. Рана сильно кровоточить."]'::jsonb, 0, null, 'Ako je hitan slučaj, dođite danas do podne.', null, null, 'Прозвучало: «Ako je hitan slučaj, dođite danas do podne.» — «Якщо це невідкладно, приходьте сьогодні до обіду.».', (select id from public.lessons where id = '08e31e8b-f8f7-5a80-89ed-093bc68dae03'), 'PUBLISHED', 'claude_assessment_v1'),
  ('1cc9bde9-1ab2-55be-a0b7-fbd4d98fc72e', v_aid, 3, 'A1', 'reading', 'understand', 'multiple_choice', 'Коли приймати ліки?', 'Uputa o lijeku', '["Натщесерце", "Після їжі", "Перед сном"]'::jsonb, 1, null, null, 'SIRUP PROTIV KAŠLJA
Odrasli: jedna žlica tri puta dnevno.
Djeca od 6 do 12 godina: pola žlice tri puta dnevno.
Djeca mlađa od 6 godina: pitajte liječnika.
Lijek uzimajte poslije jela. Ne pijte alkohol.
Ako kašalj traje dulje od tjedan dana, javite se liječniku.', 'СИРОП ВІД КАШЛЮ
Дорослі: одна ложка тричі на день.
Діти від 6 до 12 років: пів ложки тричі на день.
Діти до 6 років: запитайте лікаря.
Ліки приймайте після їжі. Не пийте алкоголь.
Якщо кашель триває довше за тиждень, зверніться до лікаря.', 'Текст «Як приймати ліки». Правильна відповідь: «Після їжі».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('47b0e3b4-c9de-592a-9544-627b3d71f68e', v_aid, 4, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Je li u vrtiću opasno zbog vodenih kozica?', '["Prvo na određeno, s probnim radom od tri mjeseca.", "Recite joj da sam bolestan i da danas ne dolazim.", "Za to postoji cjepivo, pitajte doktoricu."]'::jsonb, 2, null, 'Je li u vrtiću opasno zbog vodenih kozica?', null, null, 'Діалог «Щеплення»: «Je li u vrtiću opasno zbog vodenih kozica?» (У садочку небезпечно через вітрянку?) — «Za to postoji cjepivo, pitajte doktoricu.» (Від неї є вакцина, запитайте лікарку.).', (select id from public.lessons where id = '0df023bb-17fb-5006-91bf-3b911dd30295'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e1d9ce4c-7358-5768-b65c-2fca8ed18108', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Jeste li pali u nesvijest?', '["Prvo oguli jabuke i nasjeckaj ih.", "Nisam, ali sam morala leći.", "Klikni mišem na postavke, pa na «Ažuriranje»."]'::jsonb, 1, null, 'Jeste li pali u nesvijest?', null, null, 'Діалог «Що сталося?»: «Jeste li pali u nesvijest?» (Ви знепритомніли?) — «Nisam, ali sam morala leći.» (Ні, але мені довелося лягти.).', (select id from public.lessons where id = '878c0712-e4e5-5a7d-aab5-510c781da0c7'), 'PUBLISHED', 'claude_assessment_v1'),
  ('698f2f5c-29ec-5ff3-beb0-a9d3010a6a08', v_aid, 6, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Može li se to izliječiti?', '["Краще. У неї був грип, але вірус минув.", "Це хронічне, тож вона ходить на терапію двічі на тиждень.", "Не повністю, але відновлення добре, якщо регулярно займатися."]'::jsonb, 2, null, null, 'Marko: Kako je tvoja mama?
Darja: Bolje. Imala je gripu, ali virus je prošao.
Marko: A ono s leđima?
Darja: To je kronično, pa ide na terapiju dvaput tjedno.
Marko: Može li se to izliječiti?
Darja: Ne potpuno, ali oporavak je dobar ako redovito vježba.', 'Marko: Як твоя мама?
Darja: Краще. У неї був грип, але вірус минув.
Marko: А та проблема зі спиною?
Darja: Це хронічне, тож вона ходить на терапію двічі на тиждень.
Marko: Це можна вилікувати?
Darja: Не повністю, але відновлення добре, якщо регулярно займатися.', 'Діалог «Довге лікування»: «Može li se to izliječiti?» — «Ne potpuno, ali oporavak je dobar ako redovito vježba.», тобто «Не повністю, але відновлення добре, якщо регулярно займатися.».', (select id from public.lessons where id = '431b51ad-baa3-5387-94ac-a7273fdb9263'), 'PUBLISHED', 'claude_assessment_v1'),
  ('3b746ef7-ea26-5d3c-a6cb-58d817451b2d', v_aid, 7, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Це невідкладний випадок». Що ви скажете?', null, '["Posjekao sam se.", "Ovo je hitan slučaj.", "Vježbajte svaki dan."]'::jsonb, 1, null, null, null, null, '«Це невідкладний випадок.» — «Ovo je hitan slučaj.».', (select id from public.lessons where id = '08e31e8b-f8f7-5a80-89ed-093bc68dae03'), 'PUBLISHED', 'claude_assessment_v1'),
  ('346846f0-b6c4-53a2-8c96-84362e37d697', v_aid, 8, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «доза»', null, '[]'::jsonb, null, 'doza', null, null, null, '«доза» — doza.', (select id from public.lessons where id = '123e68fa-291f-5ad6-8403-51db7020d641'), 'PUBLISHED', 'claude_assessment_v1'),
  ('54c02f6d-107d-5643-be2c-9bc1a7776af5', v_aid, 9, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Який діагноз?»', null, '["je", "Kakva", "dijagnoza?"]'::jsonb, null, 'Kakva je dijagnoza?', null, null, null, '«Який діагноз?» — «Kakva je dijagnoza?».', (select id from public.lessons where id = '431b51ad-baa3-5387-94ac-a7273fdb9263'), 'PUBLISHED', 'claude_assessment_v1'),
  ('88a1e040-db48-575c-865a-59a9f332fd3f', v_aid, 10, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Я порізався.»', null, '[]'::jsonb, null, 'Posjekao sam se.', null, null, null, '«Я порізався.» — «Posjekao sam se.».', (select id from public.lessons where id = 'd5dee6c5-f510-57b9-a1ed-4b0a60e8e09a'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під програму A1 v3 — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('5760741b-4c07-51fe-b746-93f220894b63', 'e7b09216-5a76-50fe-8530-457f4e8a8823', '1cc9bde9-1ab2-55be-a0b7-fbd4d98fc72e', '47b0e3b4-c9de-592a-9544-627b3d71f68e', 'e1d9ce4c-7358-5768-b65c-2fca8ed18108', '698f2f5c-29ec-5ff3-beb0-a9d3010a6a08', '3b746ef7-ea26-5d3c-a6cb-58d817451b2d', '346846f0-b6c4-53a2-8c96-84362e37d697', '54c02f6d-107d-5643-be2c-9bc1a7776af5', '88a1e040-db48-575c-865a-59a9f332fd3f') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a1-m08')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('5760741b-4c07-51fe-b746-93f220894b63', 'e7b09216-5a76-50fe-8530-457f4e8a8823', '1cc9bde9-1ab2-55be-a0b7-fbd4d98fc72e', '47b0e3b4-c9de-592a-9544-627b3d71f68e', 'e1d9ce4c-7358-5768-b65c-2fca8ed18108', '698f2f5c-29ec-5ff3-beb0-a9d3010a6a08', '3b746ef7-ea26-5d3c-a6cb-58d817451b2d', '346846f0-b6c4-53a2-8c96-84362e37d697', '54c02f6d-107d-5643-be2c-9bc1a7776af5', '88a1e040-db48-575c-865a-59a9f332fd3f')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів A1: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірку a1-m08 оновлено — % нових завдань', v_new;
end $$;

commit;
