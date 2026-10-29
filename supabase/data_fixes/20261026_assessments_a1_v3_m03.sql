-- =====================================================================
-- Перевірка модуля A1.3 під програму A1 v3 · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_assessment_a1_v3.py 3 (не редагуйте вручну).
--
-- Тести: a1-m03 — по 10 завдань із нових діалогів і вправ модуля.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A1). Середину й фінал рівня A1 не змінено (їх — після всього A1).
--   * Потрібні: 20261026_curriculum_a1_v3_structure.sql і 20261026_curriculum_a1_v3_m03.sql.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A1.3 · Модуль A1.3 — Покупки
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a1-m03';
  if v_aid is null then  -- новий модуль програми v3: тесту ще немає
    insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index, pass_ratio,
                                    area_min_ratio, estimated_minutes, description_ua)
    values ('177bad83-b3b0-5c4b-8f22-43908d5fac1c', 'a1-m03', 'module', 'Перевірка модуля A1.3', 1, 'PUBLISHED', 'claude_assessment_v1', 'A1',
            '88e77a6f-1140-5f26-b724-0ae15477637a', 3, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.')
    returning id into v_aid;
  end if;
  if exists (select 1 from public.assessment_items where id = '33de9849-7b15-552a-b756-505ea93c301e') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '88e77a6f-1140-5f26-b724-0ae15477637a'::uuid then
    raise exception 'Тест a1-m03 прив’язаний не до модуля A1.3 — спершу 20261026_curriculum_a1_v3_structure.sql';
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
  ('33de9849-7b15-552a-b756-505ea93c301e', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Що ти береш на море?", "Гарна ідея. А татові наручний годинник?", "Перепрошую, у вас є шампунь для сухого волосся?"]'::jsonb, 2, null, 'Oprostite, imate li šampon za suhu kosu?', null, null, 'Прозвучало: «Oprostite, imate li šampon za suhu kosu?» — «Перепрошую, у вас є шампунь для сухого волосся?».', (select id from public.lessons where id = '9ba8e62a-83fd-5b08-9e01-760bc0f7219f'), 'PUBLISHED', 'claude_assessment_v1'),
  ('8f9ffa20-4e01-555d-84ec-bd9194b44090', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Івано, тобі подобається ця сукня?", "Гарна ідея. А татові наручний годинник?", "Шарф теж треба?"]'::jsonb, 2, null, 'Trebam li i šal?', null, null, 'Прозвучало: «Trebam li i šal?» — «Шарф теж треба?».', (select id from public.lessons where id = 'c8297811-44ed-55a2-8cb5-d1bd9b8a6a73'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b51a0f69-dd33-54e0-8afb-657a3429d4a1', v_aid, 3, 'A1', 'reading', 'understand', 'multiple_choice', 'Для кого куртка?', 'Koju jaknu kupiti?', '["Для Марії", "Для чоловіка", "Для сина"]'::jsonb, 2, null, null, 'Oksana: Trebam zimsku jaknu za sina. Imaš li ideju?
Marija: Probaj u centru, tamo je sada sniženje.
Oksana: Vidim dvije jakne. Plava je jeftinija, a crna je toplija.
Marija: Uzmi topliju! Zima u Zagrebu je hladna.
Oksana: Imaš pravo. Uzimam crnu i nove rukavice.', 'Оксана: Мені потрібна зимова куртка для сина. Маєш ідею?
Марія: Спробуй у центрі, там зараз розпродаж.
Оксана: Бачу дві куртки. Синя дешевша, а чорна тепліша.
Марія: Бери теплішу! Зима в Загребі холодна.
Оксана: Маєш рацію. Беру чорну і нові рукавички.', 'Текст «Яку куртку купити?». Правильна відповідь: «Для сина».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('ce7494ec-755b-5abc-8fad-bb8f2de35d0b', v_aid, 4, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Darja, što da poklonim Ani za rođendan?', '["Jutros je ulovljena, kao i brancin.", "Na ime Kovalenko. Hvala!", "Možda naušnice? Ona obožava nakit."]'::jsonb, 2, null, 'Darja, što da poklonim Ani za rođendan?', null, null, 'Діалог «Що подарувати?»: «Darja, što da poklonim Ani za rođendan?» (Даріє, що мені подарувати Ані на день народження?) — «Možda naušnice? Ona obožava nakit.» (Може, сережки? Вона обожнює прикраси.).', (select id from public.lessons where id = '86d268a5-7193-53c5-955b-cf6cc69116f1'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b33e05cc-e25f-53e4-a14a-b5082a829392', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Predivan je! Možete li ga zamotati?', '["Subotom se izležavam, a nedjeljom idem na izlet.", "Naravno, u ukrasni papir s crvenom vrpcom.", "Skoro. Grah mora još malo prokuhati."]'::jsonb, 1, null, 'Predivan je! Možete li ga zamotati?', null, null, 'Діалог «У ювелірному»: «Predivan je! Možete li ga zamotati?» (Чудовий! Можете його загорнути?) — «Naravno, u ukrasni papir s crvenom vrpcom.» (Звісно, у подарунковий папір із червоною стрічкою.).', (select id from public.lessons where id = '86d268a5-7193-53c5-955b-cf6cc69116f1'), 'PUBLISHED', 'claude_assessment_v1'),
  ('23b6bfe6-cd23-58a9-8ff9-32e18d466c81', v_aid, 6, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dašo, koje su bolje, plave ili crne?', '["Тоді беру чорні. Погана якість не окупається.", "Згодна. Краще заплатити більше, ніж купувати двічі.", "Сині дешевші, але чорні якісніші."]'::jsonb, 2, null, null, 'Luka: Dašo, koje su bolje, plave ili crne?
Daša: Plave su jeftinije, ali crne su kvalitetnije.
Luka: Ima li velike razlike u materijalu?
Daša: Ima. Crne su od kože i puno su trajnije.
Luka: Onda uzimam crne. Loša kvaliteta se ne isplati.
Daša: Slažem se. Bolje platiti više nego kupovati dvaput.', 'Luka: Дашо, які кращі — сині чи чорні?
Daša: Сині дешевші, але чорні якісніші.
Luka: А матеріал сильно відрізняється?
Daša: Так. Чорні шкіряні й набагато міцніші.
Luka: Тоді беру чорні. Погана якість не окупається.
Daša: Згодна. Краще заплатити більше, ніж купувати двічі.', 'Діалог «Які кросівки?»: «Dašo, koje su bolje, plave ili crne?» — «Plave su jeftinije, ali crne su kvalitetnije.», тобто «Сині дешевші, але чорні якісніші.».', (select id from public.lessons where id = '7042ff57-9a20-514a-ab80-71b6f63579f7'), 'PUBLISHED', 'claude_assessment_v1'),
  ('f3ef4e0a-b649-56a8-bb1c-a252b6c0bf10', v_aid, 7, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Ці дві марки схожі». Що ви скажете?', null, '["Ove dvije marke su slične.", "Uzimam kupaći kostim i kratke hlače.", "Gdje je moja zimska kapa?"]'::jsonb, 0, null, null, null, null, '«Ці дві марки схожі.» — «Ove dvije marke su slične.».', (select id from public.lessons where id = '7042ff57-9a20-514a-ab80-71b6f63579f7'), 'PUBLISHED', 'claude_assessment_v1'),
  ('3d65f79e-51c3-58c0-a338-68bbf10f3430', v_aid, 8, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «обожнювати»', null, '[]'::jsonb, null, 'obožavati', null, null, null, '«обожнювати» — obožavati.', (select id from public.lessons where id = '9a979d32-2f4b-5127-bc22-7292763c7de4'), 'PUBLISHED', 'claude_assessment_v1'),
  ('a428c344-8760-56bd-aaa3-ce30954acfe2', v_aid, 9, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «У нас немає гелю для душу.»', null, '["gela", "za", "tuširanje.", "Nemamo"]'::jsonb, null, 'Nemamo gela za tuširanje.', null, null, null, '«У нас немає гелю для душу.» — «Nemamo gela za tuširanje.».', (select id from public.lessons where id = '9ba8e62a-83fd-5b08-9e01-760bc0f7219f'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d4169add-5e95-5221-8064-fe3aa9a7c1f3', v_aid, 10, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Тобі подобається ця сукня?»', null, '[]'::jsonb, null, 'Sviđa li ti se ova haljina?', null, null, null, '«Тобі подобається ця сукня?» — «Sviđa li ti se ova haljina?».', (select id from public.lessons where id = '9a979d32-2f4b-5127-bc22-7292763c7de4'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під програму A1 v3 — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('33de9849-7b15-552a-b756-505ea93c301e', '8f9ffa20-4e01-555d-84ec-bd9194b44090', 'b51a0f69-dd33-54e0-8afb-657a3429d4a1', 'ce7494ec-755b-5abc-8fad-bb8f2de35d0b', 'b33e05cc-e25f-53e4-a14a-b5082a829392', '23b6bfe6-cd23-58a9-8ff9-32e18d466c81', 'f3ef4e0a-b649-56a8-bb1c-a252b6c0bf10', '3d65f79e-51c3-58c0-a338-68bbf10f3430', 'a428c344-8760-56bd-aaa3-ce30954acfe2', 'd4169add-5e95-5221-8064-fe3aa9a7c1f3') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a1-m03')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('33de9849-7b15-552a-b756-505ea93c301e', '8f9ffa20-4e01-555d-84ec-bd9194b44090', 'b51a0f69-dd33-54e0-8afb-657a3429d4a1', 'ce7494ec-755b-5abc-8fad-bb8f2de35d0b', 'b33e05cc-e25f-53e4-a14a-b5082a829392', '23b6bfe6-cd23-58a9-8ff9-32e18d466c81', 'f3ef4e0a-b649-56a8-bb1c-a252b6c0bf10', '3d65f79e-51c3-58c0-a338-68bbf10f3430', 'a428c344-8760-56bd-aaa3-ce30954acfe2', 'd4169add-5e95-5221-8064-fe3aa9a7c1f3')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів A1: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірку a1-m03 оновлено — % нових завдань', v_new;
end $$;

commit;
