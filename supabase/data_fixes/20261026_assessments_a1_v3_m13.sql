-- =====================================================================
-- Перевірка модуля A1.13 під програму A1 v3 · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_assessment_a1_v3.py 13 (не редагуйте вручну).
--
-- Тести: a1-m13 — по 10 завдань із нових діалогів і вправ модуля.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A1). Середину й фінал рівня A1 не змінено (їх — після всього A1).
--   * Потрібні: 20261026_curriculum_a1_v3_structure.sql і 20261026_curriculum_a1_v3_m13.sql.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A1.13 · Модуль A1.13 — Підсумок A1: моє життя в Хорватії
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a1-m13';
  if v_aid is null then  -- новий модуль програми v3: тесту ще немає
    insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index, pass_ratio,
                                    area_min_ratio, estimated_minutes, description_ua)
    values ('11954243-ebda-5eb9-a06f-58a57ad34b6d', 'a1-m13', 'module', 'Перевірка модуля A1.13', 1, 'PUBLISHED', 'claude_assessment_v1', 'A1',
            '34064af4-9715-5f07-b87c-a5e28eb8127b', 13, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.')
    returning id into v_aid;
  end if;
  if exists (select 1 from public.assessment_items where id = '84554e22-a00e-560e-9d9a-73d27fa758d7') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '34064af4-9715-5f07-b87c-a5e28eb8127b'::uuid then
    raise exception 'Тест a1-m13 прив’язаний не до модуля A1.13 — спершу 20261026_curriculum_a1_v3_structure.sql';
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
  ('84554e22-a00e-560e-9d9a-73d27fa758d7', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Сподіваюся, що просунуся й стану керівницею зміни.", "У тебе вийде, ти дуже працьовита!", "Я волонтерила в організації, а там чудова спільнота."]'::jsonb, 0, null, 'Nadam se da ću napredovati i postati voditeljica smjene.', null, null, 'Прозвучало: «Nadam se da ću napredovati i postati voditeljica smjene.» — «Сподіваюся, що просунуся й стану керівницею зміни.».', (select id from public.lessons where id = 'dbb91fa1-4a97-5c04-99a8-8ac1d508b952'), 'PUBLISHED', 'claude_assessment_v1'),
  ('2b521184-d5b7-5603-b898-e683d0876c2f', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Що тобі було найважче?", "Так. А ти? Яка твоя найкраща риса?", "А ти швидко звикла до нашого менталітету?"]'::jsonb, 0, null, 'Što ti je bilo najteže?', null, null, 'Прозвучало: «Što ti je bilo najteže?» — «Що тобі було найважче?».', (select id from public.lessons where id = '4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('726b0905-3d20-5eec-9664-a81ecd8a116e', v_aid, 3, 'A1', 'reading', 'understand', 'multiple_choice', 'Хто перекладає документи?', 'Obavijest MUP-a', '["Присяжний перекладач", "Будь-хто", "Сам заявник"]'::jsonb, 0, null, null, 'OBAVIJEST ZA STRANCE
Zahtjev za privremeni boravak predajete u policijskoj upravi prema mjestu stanovanja.
Trebate: važeću putovnicu, fotografiju, dokaz o smještaju i zdravstveno osiguranje.
Dokumente na stranom jeziku prevodi sudski tumač.
Na šalter dolazite s brojem iz automata. Radno vrijeme: 8 – 15 sati.', 'ОГОЛОШЕННЯ ДЛЯ ІНОЗЕМЦІВ
Заяву на тимчасове перебування подаєте в поліцейському управлінні за місцем проживання.
Потрібно: чинний паспорт, фотографія, підтвердження житла й медичне страхування.
Документи іноземною мовою перекладає присяжний перекладач.
До віконця підходите з номером з автомата. Години роботи: 8 – 15 година.', 'Текст «Документи в MUP». Правильна відповідь: «Присяжний перекладач».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('00803770-adbf-57cb-8c43-d6d5df569252', v_aid, 4, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Što ti je bilo najteže?', '["U Kijevu sam radila kao računovođa šest godina.", "Jezik i papiri. Ali korak po korak, snašla sam se.", "Tri eura. Uz račun dobivate debitnu karticu i mobilno bankarstvo."]'::jsonb, 1, null, 'Što ti je bilo najteže?', null, null, 'Діалог «Перший рік»: «Što ti je bilo najteže?» (Що тобі було найважче?) — «Jezik i papiri. Ali korak po korak, snašla sam se.» (Мова й документи. Але крок за кроком я дала собі раду.).', (select id from public.lessons where id = '4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('ce059b3f-e4b1-5e63-bf85-eac67355c818', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Darja, čime se baviš u slobodno vrijeme?', '["Petnaest eura, s kacigom i lokotom.", "Rade. Provjerite i zvonce prije vožnje.", "Zanimam se za fotografiju i povijest."]'::jsonb, 2, null, 'Darja, čime se baviš u slobodno vrijeme?', null, null, 'Діалог «Нове знайомство»: «Darja, čime se baviš u slobodno vrijeme?» (Даріє, чим ти займаєшся у вільний час?) — «Zanimam se za fotografiju i povijest.» (Я цікавлюся фотографією та історією.).', (select id from public.lessons where id = 'fc1baff0-0e48-5676-bd3c-47d88d31e582'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e3f181ef-42c9-5997-a9a2-16b705f64a55', v_aid, 6, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Darja, nedostaje li ti Ukrajina?', '["Перше Різдво з новими друзями, ми були як сім’я.", "Дуже. Іноді в мене ностальгія, я згадую маму й наш сад.", "Я волонтерила в організації, а там чудова спільнота."]'::jsonb, 1, null, null, 'Ivana: Darja, nedostaje li ti Ukrajina?
Darja: Jako. Ponekad imam nostalgiju, sjećam se mame i našeg vrta.
Ivana: Kako si se sprijateljila s ljudima ovdje?
Darja: Volontirala sam u udruzi, a ondje je divna zajednica.
Ivana: Koje ti je najljepše sjećanje iz prve godine?
Darja: Prvi Božić s novim prijateljima, bili smo kao obitelj.', 'Ivana: Даріє, ти сумуєш за Україною?
Darja: Дуже. Іноді в мене ностальгія, я згадую маму й наш сад.
Ivana: Як ти тут подружилася з людьми?
Darja: Я волонтерила в організації, а там чудова спільнота.
Ivana: Який у тебе найгарніший спогад з першого року?
Darja: Перше Різдво з новими друзями, ми були як сім’я.', 'Діалог «Спогади»: «Darja, nedostaje li ti Ukrajina?» — «Jako. Ponekad imam nostalgiju, sjećam se mame i našeg vrta.», тобто «Дуже. Іноді в мене ностальгія, я згадую маму й наш сад.».', (select id from public.lessons where id = '4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('233bf702-f66b-58de-a853-3a93aa8ff1a9', v_aid, 7, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я надійна й терпляча». Що ви скажете?', null, '["Pouzdana sam i strpljiva.", "Korak po korak.", "Usavršit ću hrvatski."]'::jsonb, 0, null, null, null, null, '«Я надійна й терпляча.» — «Pouzdana sam i strpljiva.».', (select id from public.lessons where id = 'fc1baff0-0e48-5676-bd3c-47d88d31e582'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d3edc884-35ea-5f2a-ac14-23316f7dad01', v_aid, 8, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «звикнути»', null, '[]'::jsonb, null, 'naviknuti se', null, null, null, '«звикнути» — naviknuti se.', (select id from public.lessons where id = '4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b29f4abf-9929-521f-8c50-b0f78bf73da5', v_aid, 9, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я родом з України.»', null, '["sam", "Podrijetlom", "iz", "Ukrajine."]'::jsonb, null, 'Podrijetlom sam iz Ukrajine.', null, null, null, '«Я родом з України.» — «Podrijetlom sam iz Ukrajine.».', (select id from public.lessons where id = 'fc1baff0-0e48-5676-bd3c-47d88d31e582'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e764c1f3-fb3f-5855-888f-3ad713bb0015', v_aid, 10, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Які твої цілі?»', null, '[]'::jsonb, null, 'Koji su tvoji ciljevi?', null, null, null, '«Які твої цілі?» — «Koji su tvoji ciljevi?».', (select id from public.lessons where id = 'dbb91fa1-4a97-5c04-99a8-8ac1d508b952'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під програму A1 v3 — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('84554e22-a00e-560e-9d9a-73d27fa758d7', '2b521184-d5b7-5603-b898-e683d0876c2f', '726b0905-3d20-5eec-9664-a81ecd8a116e', '00803770-adbf-57cb-8c43-d6d5df569252', 'ce059b3f-e4b1-5e63-bf85-eac67355c818', 'e3f181ef-42c9-5997-a9a2-16b705f64a55', '233bf702-f66b-58de-a853-3a93aa8ff1a9', 'd3edc884-35ea-5f2a-ac14-23316f7dad01', 'b29f4abf-9929-521f-8c50-b0f78bf73da5', 'e764c1f3-fb3f-5855-888f-3ad713bb0015') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a1-m13')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('84554e22-a00e-560e-9d9a-73d27fa758d7', '2b521184-d5b7-5603-b898-e683d0876c2f', '726b0905-3d20-5eec-9664-a81ecd8a116e', '00803770-adbf-57cb-8c43-d6d5df569252', 'ce059b3f-e4b1-5e63-bf85-eac67355c818', 'e3f181ef-42c9-5997-a9a2-16b705f64a55', '233bf702-f66b-58de-a853-3a93aa8ff1a9', 'd3edc884-35ea-5f2a-ac14-23316f7dad01', 'b29f4abf-9929-521f-8c50-b0f78bf73da5', 'e764c1f3-fb3f-5855-888f-3ad713bb0015')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів A1: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірку a1-m13 оновлено — % нових завдань', v_new;
end $$;

commit;
