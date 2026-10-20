-- =====================================================================
-- Перевірки модулів A0 під уроки за темою (curriculum_a0_v4) · 2026-10-19
-- Згенеровано: python3 -B scripts/gen_assessment_a0_v4.py (не редагуйте вручну).
--
-- Тести: a0-m08 — по 10 завдань із нових діалогів і вправ модулів A0.8.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A0). Середину й фінал рівня A0 не змінено.
--   * Потрібні: 20261015_assessments_a0_v1.sql і уроки curriculum_a0_v4 модуля A0.8 (20261019_curriculum_a0_v4_m08.sql).
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A0.8 · Модуль A0.8 — Kupovina (покупки)
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a0-m08';
  if v_aid is null then raise exception 'Немає тесту a0-m08 — спершу 20261015_assessments_a0_v1.sql'; end if;
  if exists (select 1 from public.assessment_items where id = '2ef2e3b2-d6ce-5362-b38f-2eefc8d47c36') then return; end if;  -- уже оновлено
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'curriculum_a0_v4: перевірку модуля оновлено під нові уроки — старі завдання');
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + 100
   where assessment_id = v_aid and status = 'PUBLISHED' and order_index <= 100;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('2ef2e3b2-d6ce-5362-b38f-2eefc8d47c36', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Дякую! А ти завжди носиш бежеве й сіре.", "Ту, домашню. І пів кіло фаршу.", "Ось: дві бляшанки квасолі, банка меду й пачка кави."]'::jsonb, 1, null, 'Onu domaću. I pola kile mljevenog mesa.', null, null, 'Прозвучало: «Onu domaću. I pola kile mljevenog mesa.» — «Ту, домашню. І пів кіло фаршу.».', (select id from public.lessons where id = '0e925295-2766-5931-b031-2412682bc6f8'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d172c750-4dfc-55fc-add1-2ebe698f0bba', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Скільки коштує ця стара лампа?", "Є, ось він. Можна її обміняти?", "Це забагато. Можна дешевше?"]'::jsonb, 2, null, 'To je previše. Može li jeftinije?', null, null, 'Прозвучало: «To je previše. Može li jeftinije?» — «Це забагато. Можна дешевше?».', (select id from public.lessons where id = '6836e57c-030c-59f8-9818-b44c08b126a6'), 'PUBLISHED', 'claude_assessment_v1'),
  ('a55d3548-0972-52d4-8c47-b1cb434ba38b', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Скільки коштує пакет?', 'Na blagajni u supermarketu', '["Безкоштовно", "1 €", "0,10 €"]'::jsonb, 2, null, null, 'BLAGAJNA 3
Samo kartice
AKCIJA: –20 %
Vrećica 0,10 €
Hvala na kupnji!', 'КАСА 3
Тільки картки
АКЦІЯ: –20 %
Пакет 0,10 €
Дякуємо за покупку!', 'Текст «На касі в супермаркеті». Правильна відповідь: «0,10 €».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('5ad0dd0a-0e01-58d0-a743-a00698f780b6', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koja ti se jakna više sviđa, ova ili ona?', '["Jesu, jutros su ulovljene.", "Broj šest.", "Ona crna. Ova je premalena za tebe."]'::jsonb, 2, null, 'Koja ti se jakna više sviđa, ova ili ona?', null, null, 'Діалог «Ця чи та?»: «Koja ti se jakna više sviđa, ova ili ona?» (Яка куртка тобі більше подобається, ця чи он та?) — «Ona crna. Ova je premalena za tebe.» (Он та чорна. Ця тобі замала.).', (select id from public.lessons where id = 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0'), 'PUBLISHED', 'claude_assessment_v1'),
  ('fc9a04f9-eb81-5473-9578-9a91c1bdb68f', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Može za devedeset?', '["U park! A onda u knjižnicu.", "On je Hrvat, a ona je Slovenka.", "Može za devedeset pet. Isplati vam se!"]'::jsonb, 2, null, 'Može za devedeset?', null, null, 'Діалог «Вживаний велосипед»: «Može za devedeset?» (А за дев’яносто можна?) — «Može za devedeset pet. Isplati vam se!» (Можна за дев’яносто п’ять. Вам це вигідно!).', (select id from public.lessons where id = '6836e57c-030c-59f8-9818-b44c08b126a6'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b0eec371-d78a-5cb7-8b1a-db70b9237dbd', v_aid, 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Stvarno su slatke. Koliko košta kila?', '["Так, зі Славонії. Скуштуйте одне.", "Прошу, пані! Яблука сьогодні дуже добрі.", "Два євро. Є ще свіжа полуниця."]'::jsonb, 2, null, null, 'Prodavačica: Izvolite, gospođo! Jabuke su danas jako dobre.
Daša: Jesu li domaće?
Prodavačica: Jesu, iz Slavonije. Probajte jednu.
Daša: Stvarno su slatke. Koliko košta kila?
Prodavačica: Dva eura. Imam i svježe jagode.
Daša: Dajte mi kilu jabuka, molim.', 'Prodavačica: Прошу, пані! Яблука сьогодні дуже добрі.
Daša: Вони домашні?
Prodavačica: Так, зі Славонії. Скуштуйте одне.
Daša: Справді солодкі. Скільки коштує кілограм?
Prodavačica: Два євро. Є ще свіжа полуниця.
Daša: Дайте мені кілограм яблук, будь ласка.', 'Діалог «Біля прилавка з фруктами»: «Stvarno su slatke. Koliko košta kila?» — «Dva eura. Imam i svježe jagode.», тобто «Два євро. Є ще свіжа полуниця.».', (select id from public.lessons where id = 'e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0'), 'PUBLISHED', 'claude_assessment_v1'),
  ('28fa7b59-1740-5a3f-b4e4-89000b986e67', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Ця сорочка мені пасує». Що ви скажете?', null, '["Ova košulja mi pristaje.", "Kilu rajčica, molim.", "Kakve je boje?"]'::jsonb, 0, null, null, null, null, '«Ця сорочка мені пасує.» — «Ova košulja mi pristaje.».', (select id from public.lessons where id = 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0'), 'PUBLISHED', 'claude_assessment_v1'),
  ('fde499ef-59a1-51aa-8760-8f3eb1a40fd9', v_aid, 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «купити»', null, '[]'::jsonb, null, 'kupiti', null, null, null, '«купити» — kupiti.', (select id from public.lessons where id = '28913ad6-490f-5d89-bad7-9b303c673fcd'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d16baa0b-c0c2-52be-8a50-c4a5a6aa8458', v_aid, 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Якого кольору твоя куртка?»', null, '["tvoja", "Kakve", "jakna?", "je", "boje"]'::jsonb, null, 'Kakve je boje tvoja jakna?', null, null, null, '«Якого кольору твоя куртка?» — «Kakve je boje tvoja jakna?».', (select id from public.lessons where id = '288e7610-99c8-5696-989a-86f60ce38b0a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b74d03cd-2325-5e07-ac1f-ff626132b072', v_aid, 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Сто грамів сиру, будь ласка.»', null, '[]'::jsonb, null, 'Deset deka sira, molim.', null, null, null, '«Сто грамів сиру, будь ласка.» — «Deset deka sira, molim.».', (select id from public.lessons where id = '0e925295-2766-5931-b031-2412682bc6f8'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під уроки за темою (curriculum_a0_v4) — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('2ef2e3b2-d6ce-5362-b38f-2eefc8d47c36', 'd172c750-4dfc-55fc-add1-2ebe698f0bba', 'a55d3548-0972-52d4-8c47-b1cb434ba38b', '5ad0dd0a-0e01-58d0-a743-a00698f780b6', 'fc9a04f9-eb81-5473-9578-9a91c1bdb68f', 'b0eec371-d78a-5cb7-8b1a-db70b9237dbd', '28fa7b59-1740-5a3f-b4e4-89000b986e67', 'fde499ef-59a1-51aa-8760-8f3eb1a40fd9', 'd16baa0b-c0c2-52be-8a50-c4a5a6aa8458', 'b74d03cd-2325-5e07-ac1f-ff626132b072') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a0-m08')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'
                     and i.id not in ('2ef2e3b2-d6ce-5362-b38f-2eefc8d47c36', 'd172c750-4dfc-55fc-add1-2ebe698f0bba', 'a55d3548-0972-52d4-8c47-b1cb434ba38b', '5ad0dd0a-0e01-58d0-a743-a00698f780b6', 'fc9a04f9-eb81-5473-9578-9a91c1bdb68f', 'b0eec371-d78a-5cb7-8b1a-db70b9237dbd', '28fa7b59-1740-5a3f-b4e4-89000b986e67', 'fde499ef-59a1-51aa-8760-8f3eb1a40fd9', 'd16baa0b-c0c2-52be-8a50-c4a5a6aa8458', 'b74d03cd-2325-5e07-ac1f-ff626132b072')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірки модулів a0-m08 оновлено — % нових завдань', v_new;
end $$;

commit;
