-- =====================================================================
-- Перевірка модуля A1.1 під програму A1 v3 · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_assessment_a1_v3.py 1 (не редагуйте вручну).
--
-- Тести: a1-m01 — по 10 завдань із нових діалогів і вправ модуля.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A1). Середину й фінал рівня A1 не змінено (їх — після всього A1).
--   * Потрібні: 20261026_curriculum_a1_v3_structure.sql і 20261026_curriculum_a1_v3_m01.sql.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A1.1 · Модуль A1.1 — Мій день
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a1-m01';
  if v_aid is null then  -- новий модуль програми v3: тесту ще немає
    insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index, pass_ratio,
                                    area_min_ratio, estimated_minutes, description_ua)
    values ('3a4fa5be-b4a3-5d37-8052-e2a02deccf14', 'a1-m01', 'module', 'Перевірка модуля A1.1', 1, 'PUBLISHED', 'claude_assessment_v1', 'A1',
            '329c44d2-afb3-5e9e-a04e-0ab31405ad9f', 1, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.')
    returning id into v_aid;
  end if;
  if exists (select 1 from public.assessment_items where id = 'e444c764-4c41-5a0a-9b36-7cbbb20a1719') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '329c44d2-afb3-5e9e-a04e-0ab31405ad9f'::uuid then
    raise exception 'Тест a1-m01 прив’язаний не до модуля A1.1 — спершу 20261026_curriculum_a1_v3_structure.sql';
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
  ('e444c764-4c41-5a0a-9b36-7cbbb20a1719', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Коли ти повертаєшся з роботи?", "Можу. Де сушарка для білизни?", "А що робиш потім?"]'::jsonb, 1, null, 'Mogu. Gdje je sušilo za rublje?', null, null, 'Прозвучало: «Mogu. Gdje je sušilo za rublje?» — «Можу. Де сушарка для білизни?».', (select id from public.lessons where id = '9c38f909-9275-5194-9a6e-f799c6e416ce'), 'PUBLISHED', 'claude_assessment_v1'),
  ('88cd26a5-8407-5e5a-847a-f527f60ca694', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А ввечері прочитаєш мені казку?", "Що вас турбує?", "Дашо, ти готова?"]'::jsonb, 0, null, 'Hoćeš li mi navečer pročitati bajku?', null, null, 'Прозвучало: «Hoćeš li mi navečer pročitati bajku?» — «А ввечері прочитаєш мені казку?».', (select id from public.lessons where id = 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2'), 'PUBLISHED', 'claude_assessment_v1'),
  ('86df4d0e-5a77-56f9-bad7-857dab66db9e', v_aid, 3, 'A1', 'reading', 'understand', 'multiple_choice', 'Де вони можуть зустрітися?', 'Poruka od prijateljice', '["На ринку", "Перед пекарнею", "У кафе"]'::jsonb, 1, null, null, 'Bok, Olena! Jesi li slobodna u subotu ujutro? Idem na tržnicu po voće i povrće, a onda na kavu. Hoćeš li sa mnom? Možemo se naći u devet ispred pekare. Javi mi! Ana', 'Привіт, Олено! Ти вільна в суботу вранці? Я йду на ринок по фрукти й овочі, а потім на каву. Підеш зі мною? Можемо зустрітися о дев’ятій перед пекарнею. Дай знати! Ана', 'Текст «Повідомлення від подруги». Правильна відповідь: «Перед пекарнею».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('ec9573d8-0019-5c9d-b54e-00b691065deb', v_aid, 4, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Darja! Radiš li još u hotelu?', '["U kuhinji imamo mikrovalnu.", "Jesu, iz mog vrta. I patlidžani su domaći.", "Više ne, sada radim u školi."]'::jsonb, 2, null, 'Darja! Radiš li još u hotelu?', null, null, 'Діалог «Стара знайома»: «Darja! Radiš li još u hotelu?» (Дар’є! Ти ще працюєш у готелі?) — «Više ne, sada radim u školi.» (Уже ні, тепер працюю в школі.).', (select id from public.lessons where id = 'ad0bc1f4-2808-5b24-969d-9da64d4a7a4d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('ade7469a-a0de-5482-a9e4-bb2ff8dfdc54', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Možemo li pomaknuti kavu na petak?', '["Napravi mi kajganu i jedan tost, molim te.", "Jedem, ali moj brat je vegan.", "Može, krajem tjedna sam slobodnija."]'::jsonb, 2, null, 'Možemo li pomaknuti kavu na petak?', null, null, 'Діалог «Перенесемо?»: «Možemo li pomaknuti kavu na petak?» (Можемо перенести каву на п’ятницю?) — «Može, krajem tjedna sam slobodnija.» (Можна, наприкінці тижня я вільніша.).', (select id from public.lessons where id = '3365f423-e694-5b55-baa1-3205fba11aff'), 'PUBLISHED', 'claude_assessment_v1'),
  ('5066b1a2-54ae-5656-95ab-7e4167c435c7', v_aid, 6, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dašo, koliko često ideš na trening?', '["Через день, а на вихідних бігаю вздовж моря.", "Час від часу, раз чи двічі на місяць.", "А я майже ніколи не плаваю, море для мене надто холодне."]'::jsonb, 0, null, null, 'Tomislav: Dašo, koliko često ideš na trening?
Daša: Svaki drugi dan, a vikendom trčim uz more.
Tomislav: Bravo! Ja nažalost rijetko imam vremena.
Daša: A plivaš li redovito?
Tomislav: Povremeno, jednom ili dvaput mjesečno.
Daša: Ja gotovo nikad ne plivam, more mi je prehladno.', 'Tomislav: Дашо, як часто ти ходиш на тренування?
Daša: Через день, а на вихідних бігаю вздовж моря.
Tomislav: Молодець! А в мене, на жаль, рідко буває час.
Daša: А ти регулярно плаваєш?
Tomislav: Час від часу, раз чи двічі на місяць.
Daša: А я майже ніколи не плаваю, море для мене надто холодне.', 'Діалог «Спорт і звички»: «Dašo, koliko često ideš na trening?» — «Svaki drugi dan, a vikendom trčim uz more.», тобто «Через день, а на вихідних бігаю вздовж моря.».', (select id from public.lessons where id = '959e879f-a28d-5bed-9c09-16cff91ef456'), 'PUBLISHED', 'claude_assessment_v1'),
  ('fd8a47bf-b6d6-57b2-8fc8-1ea984815a04', v_aid, 7, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Насправді я не голодна». Що ви скажете?', null, '["Zapravo nisam gladna.", "Možemo li se dogovoriti za ponedjeljak?", "Moram otkazati termin."]'::jsonb, 0, null, null, null, null, '«Насправді я не голодна.» — «Zapravo nisam gladna.».', (select id from public.lessons where id = 'ad0bc1f4-2808-5b24-969d-9da64d4a7a4d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('43c4cd4f-dca4-5ce4-a4f8-cca6296fbfda', v_aid, 8, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «навіть»', null, '[]'::jsonb, null, 'čak', null, null, null, '«навіть» — čak.', (select id from public.lessons where id = 'ad0bc1f4-2808-5b24-969d-9da64d4a7a4d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b3f2183d-ac04-540a-8ea2-60cd3ae2ebd8', v_aid, 9, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я більше не працюю в готелі.»', null, '["hotelu.", "u", "radim", "Više", "ne"]'::jsonb, null, 'Više ne radim u hotelu.', null, null, null, '«Я більше не працюю в готелі.» — «Više ne radim u hotelu.».', (select id from public.lessons where id = 'ad0bc1f4-2808-5b24-969d-9da64d4a7a4d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('6b4391c2-8161-5a70-989e-c9f917cf4680', v_aid, 10, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Я пилососю у вітальні.»', null, '[]'::jsonb, null, 'Usisavam u dnevnom boravku.', null, null, null, '«Я пилососю у вітальні.» — «Usisavam u dnevnom boravku.».', (select id from public.lessons where id = '9c38f909-9275-5194-9a6e-f799c6e416ce'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під програму A1 v3 — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('e444c764-4c41-5a0a-9b36-7cbbb20a1719', '88cd26a5-8407-5e5a-847a-f527f60ca694', '86df4d0e-5a77-56f9-bad7-857dab66db9e', 'ec9573d8-0019-5c9d-b54e-00b691065deb', 'ade7469a-a0de-5482-a9e4-bb2ff8dfdc54', '5066b1a2-54ae-5656-95ab-7e4167c435c7', 'fd8a47bf-b6d6-57b2-8fc8-1ea984815a04', '43c4cd4f-dca4-5ce4-a4f8-cca6296fbfda', 'b3f2183d-ac04-540a-8ea2-60cd3ae2ebd8', '6b4391c2-8161-5a70-989e-c9f917cf4680') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a1-m01')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('e444c764-4c41-5a0a-9b36-7cbbb20a1719', '88cd26a5-8407-5e5a-847a-f527f60ca694', '86df4d0e-5a77-56f9-bad7-857dab66db9e', 'ec9573d8-0019-5c9d-b54e-00b691065deb', 'ade7469a-a0de-5482-a9e4-bb2ff8dfdc54', '5066b1a2-54ae-5656-95ab-7e4167c435c7', 'fd8a47bf-b6d6-57b2-8fc8-1ea984815a04', '43c4cd4f-dca4-5ce4-a4f8-cca6296fbfda', 'b3f2183d-ac04-540a-8ea2-60cd3ae2ebd8', '6b4391c2-8161-5a70-989e-c9f917cf4680')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів A1: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірку a1-m01 оновлено — % нових завдань', v_new;
end $$;

commit;
