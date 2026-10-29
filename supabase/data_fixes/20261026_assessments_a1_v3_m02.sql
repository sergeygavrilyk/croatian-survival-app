-- =====================================================================
-- Перевірка модуля A1.2 під програму A1 v3 · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_assessment_a1_v3.py 2 (не редагуйте вручну).
--
-- Тести: a1-m02 — по 10 завдань із нових діалогів і вправ модуля.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A1). Середину й фінал рівня A1 не змінено (їх — після всього A1).
--   * Потрібні: 20261026_curriculum_a1_v3_structure.sql і 20261026_curriculum_a1_v3_m02.sql.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A1.2 · Модуль A1.2 — Їжа й кухня
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a1-m02';
  if v_aid is null then  -- новий модуль програми v3: тесту ще немає
    insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index, pass_ratio,
                                    area_min_ratio, estimated_minutes, description_ua)
    values ('4c8f3bfe-758b-54c5-9300-7bd34c4fd019', 'a1-m02', 'module', 'Перевірка модуля A1.2', 1, 'PUBLISHED', 'claude_assessment_v1', 'A1',
            '8d02296d-bc46-5537-9a9b-c678fe5ff1c9', 2, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.')
    returning id into v_aid;
  end if;
  if exists (select 1 from public.assessment_items where id = '240e9644-88d0-5da2-848a-4a2a4460bf0f') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '8d02296d-bc46-5537-9a9b-c678fe5ff1c9'::uuid then
    raise exception 'Тест a1-m02 прив’язаний не до модуля A1.2 — спершу 20261026_curriculum_a1_v3_structure.sql';
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
  ('240e9644-88d0-5da2-848a-4a2a4460bf0f', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Один бурек із сиром і два рогалики, будь ласка.", "Зазвичай вівсянку з фруктами й трохи меду.", "Тоді три кабачки й два баклажани."]'::jsonb, 1, null, 'Obično zobene pahuljice s voćem i malo meda.', null, null, 'Прозвучало: «Obično zobene pahuljice s voćem i malo meda.» — «Зазвичай вівсянку з фруктами й трохи меду.».', (select id from public.lessons where id = 'bb7bc159-cb40-5a8a-91b7-c6da05c6342a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('3764ebfb-df9e-5ae1-9323-f6006edcb4db', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Доброго ранку! Що сьогодні сезонне?", "Смажу його на оливковій олії?", "Столик на чотирьох о восьмій. Можна біля вікна?"]'::jsonb, 1, null, 'Pržim ga na maslinovom ulju?', null, null, 'Прозвучало: «Pržim ga na maslinovom ulju?» — «Смажу його на оливковій олії?».', (select id from public.lessons where id = '3e652232-866b-5edf-ac05-d61ee7a325fe'), 'PUBLISHED', 'claude_assessment_v1'),
  ('a1bbe46b-961f-5f14-a8d7-1d8d38cdc119', v_aid, 3, 'A1', 'reading', 'understand', 'multiple_choice', 'Скільки коштує денне меню?', 'Dnevni meni', '["16 €", "9 €", "11 €"]'::jsonb, 1, null, null, 'DNEVNI MENI – 9 €
Juha od rajčice
Pečena piletina, krumpir i salata
ili
Varivo od graha s kobasicom
Kolač dana
Kruh i voda su besplatni. Kavu plaćate posebno.
Radimo od 11 do 16 sati.', 'ДЕННЕ МЕНЮ – 9 €
Томатний суп
Запечена курка, картопля й салат
або
Рагу з квасолі з ковбаскою
Тістечко дня
Хліб і вода безкоштовні. За каву платите окремо.
Працюємо з 11 до 16 години.', 'Текст «Денне меню». Правильна відповідь: «9 €».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('7a8fc03b-80e7-51c7-9f07-37c36d04576f', v_aid, 4, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Mama, je li juha gotova?', '["Skoro. Grah mora još malo prokuhati.", "Svaki drugi dan, a vikendom trčim uz more.", "Ponekad, jer sam stalno iscrpljena."]'::jsonb, 0, null, 'Mama, je li juha gotova?', null, null, 'Діалог «Обережно, гаряче!»: «Mama, je li juha gotova?» (Мамо, суп готовий?) — «Skoro. Grah mora još malo prokuhati.» (Майже. Квасоля має ще трохи прокипіти.).', (select id from public.lessons where id = '17fcd38a-e295-5849-9ba3-1ef240c6be78'), 'PUBLISHED', 'claude_assessment_v1'),
  ('95c4f649-4976-5def-ac0c-16fe13a13234', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje je pribor za jelo?', '["U ladici. Stavi i salvete pored tanjura.", "Svaki drugi dan, a vikendom trčim uz more.", "Subotom se izležavam, a nedjeljom idem na izlet."]'::jsonb, 0, null, 'Gdje je pribor za jelo?', null, null, 'Діалог «Накриваємо на стіл»: «Gdje je pribor za jelo?» (Де столові прибори?) — «U ladici. Stavi i salvete pored tanjura.» (У шухляді. Поклади ще серветки біля тарілок.).', (select id from public.lessons where id = '213ab10f-63a4-5e1c-8b2e-156c433de874'), 'PUBLISHED', 'claude_assessment_v1'),
  ('93b782b8-6203-5036-a981-5211ded49792', v_aid, 6, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Izvolite, gospođo, što vam treba?', '["Пів кіло курячих грудок і чотири свинячі відбивні.", "Дякую, це чудово для недільного супу.", "Можу. Кістки для супу даю вам безкоштовно."]'::jsonb, 0, null, null, 'Mesar: Izvolite, gospođo, što vam treba?
Daša: Pola kile pilećih prsa i četiri svinjska kotleta.
Mesar: Imam i lijepu janjetinu i puretinu.
Daša: Ne danas. Možete li mi narezati dva odreska?
Mesar: Mogu. Kosti za juhu vam dajem besplatno.
Daša: Hvala, to je super za nedjeljnu juhu.', 'Mesar: Прошу, пані, що вам потрібно?
Daša: Пів кіло курячих грудок і чотири свинячі відбивні.
Mesar: Є ще гарна ягнятина й індичатина.
Daša: Не сьогодні. Можете нарізати мені два стейки?
Mesar: Можу. Кістки для супу даю вам безкоштовно.
Daša: Дякую, це чудово для недільного супу.', 'Діалог «У м’ясника»: «Izvolite, gospođo, što vam treba?» — «Pola kile pilećih prsa i četiri svinjska kotleta.», тобто «Пів кіло курячих грудок і чотири свинячі відбивні.».', (select id from public.lessons where id = 'ae33e31a-f937-5305-908e-3d957df15f6a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('0fd92cef-7905-521f-bfcd-6d8f2a652b39', v_aid, 7, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Що сьогодні сезонне?». Що ви скажете?', null, '["Daj mi žličicu.", "Što je danas sezonsko?", "Imate li plodove mora?"]'::jsonb, 1, null, null, null, null, '«Що сьогодні сезонне?» — «Što je danas sezonsko?».', (select id from public.lessons where id = '46a89cf5-41e0-50a2-99b1-f4e66a5ff146'), 'PUBLISHED', 'claude_assessment_v1'),
  ('32c4e9b5-eaef-5c0b-a664-d8a0f7fcd139', v_aid, 8, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «спеція, приправа»', null, '[]'::jsonb, null, 'začin', null, null, null, '«спеція, приправа» — začin.', (select id from public.lessons where id = '3e652232-866b-5edf-ac05-d61ee7a325fe'), 'PUBLISHED', 'claude_assessment_v1'),
  ('4310aedd-b389-5f44-a8c7-b8e104cc7236', v_aid, 9, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Пів кіло сардин, будь ласка.»', null, '["Pola", "srdela,", "kile", "molim."]'::jsonb, null, 'Pola kile srdela, molim.', null, null, null, '«Пів кіло сардин, будь ласка.» — «Pola kile srdela, molim.».', (select id from public.lessons where id = 'ae33e31a-f937-5305-908e-3d957df15f6a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('6483df63-2020-577e-8983-8b2c27740071', v_aid, 10, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Дай мені чайну ложечку.»', null, '[]'::jsonb, null, 'Daj mi žličicu.', null, null, null, '«Дай мені чайну ложечку.» — «Daj mi žličicu.».', (select id from public.lessons where id = '213ab10f-63a4-5e1c-8b2e-156c433de874'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під програму A1 v3 — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('240e9644-88d0-5da2-848a-4a2a4460bf0f', '3764ebfb-df9e-5ae1-9323-f6006edcb4db', 'a1bbe46b-961f-5f14-a8d7-1d8d38cdc119', '7a8fc03b-80e7-51c7-9f07-37c36d04576f', '95c4f649-4976-5def-ac0c-16fe13a13234', '93b782b8-6203-5036-a981-5211ded49792', '0fd92cef-7905-521f-bfcd-6d8f2a652b39', '32c4e9b5-eaef-5c0b-a664-d8a0f7fcd139', '4310aedd-b389-5f44-a8c7-b8e104cc7236', '6483df63-2020-577e-8983-8b2c27740071') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a1-m02')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('240e9644-88d0-5da2-848a-4a2a4460bf0f', '3764ebfb-df9e-5ae1-9323-f6006edcb4db', 'a1bbe46b-961f-5f14-a8d7-1d8d38cdc119', '7a8fc03b-80e7-51c7-9f07-37c36d04576f', '95c4f649-4976-5def-ac0c-16fe13a13234', '93b782b8-6203-5036-a981-5211ded49792', '0fd92cef-7905-521f-bfcd-6d8f2a652b39', '32c4e9b5-eaef-5c0b-a664-d8a0f7fcd139', '4310aedd-b389-5f44-a8c7-b8e104cc7236', '6483df63-2020-577e-8983-8b2c27740071')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів A1: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірку a1-m02 оновлено — % нових завдань', v_new;
end $$;

commit;
