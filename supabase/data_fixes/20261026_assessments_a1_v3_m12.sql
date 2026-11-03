-- =====================================================================
-- Перевірка модуля A1.12 під програму A1 v3 · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_assessment_a1_v3.py 12 (не редагуйте вручну).
--
-- Тести: a1-m12 — по 10 завдань із нових діалогів і вправ модуля.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A1). Середину й фінал рівня A1 не змінено (їх — після всього A1).
--   * Потрібні: 20261026_curriculum_a1_v3_structure.sql і 20261026_curriculum_a1_v3_m12.sql.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A1.12 · Модуль A1.12 — Діти, навчання й документи
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a1-m12';
  if v_aid is null then  -- новий модуль програми v3: тесту ще немає
    insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index, pass_ratio,
                                    area_min_ratio, estimated_minutes, description_ua)
    values ('f1393650-ef0c-5252-a7dd-c1f10fb4864b', 'a1-m12', 'module', 'Перевірка модуля A1.12', 1, 'PUBLISHED', 'claude_assessment_v1', 'A1',
            '5a6eadc1-9da1-52c0-a50d-943a3fbffe70', 12, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.')
    returning id into v_aid;
  end if;
  if exists (select 1 from public.assessment_items where id = 'd95b4a9e-15f2-59b0-a183-0886922b8976') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '5a6eadc1-9da1-52c0-a50d-943a3fbffe70'::uuid then
    raise exception 'Тест a1-m12 прив’язаний не до модуля A1.12 — спершу 20261026_curriculum_a1_v3_structure.sql';
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
  ('d95b4a9e-15f2-59b0-a183-0886922b8976', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Улітку є й безкоштовні лекції в університеті.", "Добрий день, я телефоную щодо оголошення про трикімнатну квартиру.", "Не панікуємо. Ховаємося під стіл і чекаємо, поки скінчиться."]'::jsonb, 2, null, 'Ne paničarimo. Idemo pod stol i čekamo da prestane.', null, null, 'Прозвучало: «Ne paničarimo. Idemo pod stol i čekamo da prestane.» — «Не панікуємо. Ховаємося під стіл і чекаємо, поки скінчиться.».', (select id from public.lessons where id = '692e9310-7a5b-5adf-9f0a-a66b72fc5459'), 'PUBLISHED', 'claude_assessment_v1'),
  ('5d77e3f9-c46c-56ea-83e9-c92c63c8512e', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Сплатіть його до подання. Рішення отримаєте поштою.", "Прошу. Бачу, у вас регулярні надходження.", "Добрий день, мені потрібні робочі зошити для другого класу."]'::jsonb, 1, null, 'Izvolite. Vidim da imate redovite uplate.', null, null, 'Прозвучало: «Izvolite. Vidim da imate redovite uplate.» — «Прошу. Бачу, у вас регулярні надходження.».', (select id from public.lessons where id = 'fee5b77b-dc3b-5fd5-818a-c5496e95c23b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d9ba1a4c-1b8b-5bc3-9df9-01ecc08e319c', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Засвідчити можна в нотаріуса, це поруч.", "Скріплю їх скріпкою й покладу в синю папку.", "Я склала! Перед іспитом я вчилася щодня."]'::jsonb, 2, null, 'Položila sam! Prije ispita sam učila svaki dan.', null, null, 'Прозвучало: «Položila sam! Prije ispita sam učila svaki dan.» — «Я склала! Перед іспитом я вчилася щодня.».', (select id from public.lessons where id = '11b565a4-1e2a-50d2-8d9d-c05e84371402'), 'PUBLISHED', 'claude_assessment_v1'),
  ('45e7c25f-5234-56dd-854c-4a330f6a42e1', v_aid, 4, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'U redu. Moram li donijeti rezervnu odjeću?', '["Vjerojatno nećemo. Ali jutros sam vidio srnu i jelena.", "Sutra popodne, ako stigne rezervni dio.", "Morate, i papuče. Djeca se često zaprljaju."]'::jsonb, 2, null, 'U redu. Moram li donijeti rezervnu odjeću?', null, null, 'Діалог «Перший тиждень»: «U redu. Moram li donijeti rezervnu odjeću?» (Гаразд. Чи треба принести запасний одяг?) — «Morate, i papuče. Djeca se često zaprljaju.» (Так, і тапочки. Діти часто забруднюються.).', (select id from public.lessons where id = '42c31cfb-8680-5450-8453-245f3abd475a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('55516546-f524-5fea-9a38-52580fce6f38', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dobivam li uvjerenje na kraju?', '["Da, nakon tečaja svi polaznici polažu ispit.", "Skoro. Grah mora još malo prokuhati.", "Šetali smo šetnicom do rimskog foruma."]'::jsonb, 0, null, 'Dobivam li uvjerenje na kraju?', null, null, 'Діалог «Мовна школа»: «Dobivam li uvjerenje na kraju?» (Я отримаю свідоцтво в кінці?) — «Da, nakon tečaja svi polaznici polažu ispit.» (Так, після курсу всі слухачі складають іспит.).', (select id from public.lessons where id = '11b565a4-1e2a-50d2-8d9d-c05e84371402'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b70f1bcd-21e5-5a45-bf23-dd257c6dd6de', v_aid, 6, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Bravo! Što ćeš sada?', '["Запишуся на курс просунутого рівня, а ще мені потрібне визнання атестата.", "Чудово, так я повторю матеріал.", "Так, після курсу всі слухачі складають іспит."]'::jsonb, 0, null, null, 'Marko: Darja, kako je bilo na ispitu?
Darja: Položila sam! Prije ispita sam učila svaki dan.
Marko: Bravo! Što ćeš sada?
Darja: Upisat ću napredni tečaj, a trebam i priznavanje svjedodžbe.
Marko: Tijekom ljeta ima i besplatnih predavanja na fakultetu.
Darja: Super, tako ću ponoviti gradivo.', 'Marko: Даріє, як було на іспиті?
Darja: Я склала! Перед іспитом я вчилася щодня.
Marko: Браво! Що тепер робитимеш?
Darja: Запишуся на курс просунутого рівня, а ще мені потрібне визнання атестата.
Marko: Улітку є й безкоштовні лекції в університеті.
Darja: Чудово, так я повторю матеріал.', 'Діалог «Після іспиту»: «Bravo! Što ćeš sada?» — «Upisat ću napredni tečaj, a trebam i priznavanje svjedodžbe.», тобто «Запишуся на курс просунутого рівня, а ще мені потрібне визнання атестата.».', (select id from public.lessons where id = '11b565a4-1e2a-50d2-8d9d-c05e84371402'), 'PUBLISHED', 'claude_assessment_v1'),
  ('dd325827-eeff-5fb3-bbdb-e9b1a853f076', v_aid, 7, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Чи є вільні місця?». Що ви скажете?', null, '["Pokupit ću ga u četiri.", "Koja je vaša razina?", "Ima li slobodnih mjesta?"]'::jsonb, 2, null, null, null, null, '«Чи є вільні місця?» — «Ima li slobodnih mjesta?».', (select id from public.lessons where id = '42c31cfb-8680-5450-8453-245f3abd475a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('f85855e3-c706-580d-973e-cc491b0ea446', v_aid, 8, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «офіційне рішення»', null, '[]'::jsonb, null, 'rješenje', null, null, null, '«офіційне рішення» — rješenje.', (select id from public.lessons where id = 'fe2839bc-fd72-5e8b-bc0e-937d48a90aa8'), 'PUBLISHED', 'claude_assessment_v1'),
  ('500415f9-4dc7-55b7-a9ab-441b55991f8e', v_aid, 9, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я склала іспит.»', null, '["ispit.", "Položila", "sam"]'::jsonb, null, 'Položila sam ispit.', null, null, null, '«Я склала іспит.» — «Položila sam ispit.».', (select id from public.lessons where id = '11b565a4-1e2a-50d2-8d9d-c05e84371402'), 'PUBLISHED', 'claude_assessment_v1'),
  ('62beb7df-7fae-59d2-9a94-66e81959dd13', v_aid, 10, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Я хочу забрати посилку.»', null, '[]'::jsonb, null, 'Želim preuzeti paket.', null, null, null, '«Я хочу забрати посилку.» — «Želim preuzeti paket.».', (select id from public.lessons where id = '1c468857-b9aa-5143-aa84-6ea02aa2443c'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під програму A1 v3 — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('d95b4a9e-15f2-59b0-a183-0886922b8976', '5d77e3f9-c46c-56ea-83e9-c92c63c8512e', 'd9ba1a4c-1b8b-5bc3-9df9-01ecc08e319c', '45e7c25f-5234-56dd-854c-4a330f6a42e1', '55516546-f524-5fea-9a38-52580fce6f38', 'b70f1bcd-21e5-5a45-bf23-dd257c6dd6de', 'dd325827-eeff-5fb3-bbdb-e9b1a853f076', 'f85855e3-c706-580d-973e-cc491b0ea446', '500415f9-4dc7-55b7-a9ab-441b55991f8e', '62beb7df-7fae-59d2-9a94-66e81959dd13') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a1-m12')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('d95b4a9e-15f2-59b0-a183-0886922b8976', '5d77e3f9-c46c-56ea-83e9-c92c63c8512e', 'd9ba1a4c-1b8b-5bc3-9df9-01ecc08e319c', '45e7c25f-5234-56dd-854c-4a330f6a42e1', '55516546-f524-5fea-9a38-52580fce6f38', 'b70f1bcd-21e5-5a45-bf23-dd257c6dd6de', 'dd325827-eeff-5fb3-bbdb-e9b1a853f076', 'f85855e3-c706-580d-973e-cc491b0ea446', '500415f9-4dc7-55b7-a9ab-441b55991f8e', '62beb7df-7fae-59d2-9a94-66e81959dd13')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів A1: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірку a1-m12 оновлено — % нових завдань', v_new;
end $$;

commit;
