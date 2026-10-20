-- =====================================================================
-- Перевірки модулів A0 під уроки за темою (curriculum_a0_v4) · 2026-10-19
-- Згенеровано: python3 -B scripts/gen_assessment_a0_v4.py (не редагуйте вручну).
--
-- Тести: a0-m03 — по 10 завдань із нових діалогів і вправ модулів A0.3.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A0). Середину й фінал рівня A0 не змінено.
--   * Потрібні: 20261015_assessments_a0_v1.sql і уроки curriculum_a0_v4 модуля A0.3 (20261019_curriculum_a0_v4_m03.sql).
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A0.3 · Модуль A0.3 — Brojevi (числа)
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a0-m03';
  if v_aid is null then raise exception 'Немає тесту a0-m03 — спершу 20261015_assessments_a0_v1.sql'; end if;
  if exists (select 1 from public.assessment_items where id = '50480c91-04b8-56f3-bf3f-82bb73819b59') then return; end if;  -- уже оновлено
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
  ('50480c91-04b8-56f3-bf3f-82bb73819b59', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Тоді купи один великий торт і кілька тістечок.", "Тоді двадцять два з кожного.", "Синові шість років, а доньці вісім місяців."]'::jsonb, 2, null, 'Sin ima šest godina, a kći osam mjeseci.', null, null, 'Прозвучало: «Sin ima šest godina, a kći osam mjeseci.» — «Синові шість років, а доньці вісім місяців.».', (select id from public.lessons where id = '4c5db9c0-aa58-55c5-b647-7f7cfc8396c2'), 'PUBLISHED', 'claude_assessment_v1'),
  ('55aa9d64-d200-59c9-9861-96f05a13c6fc', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Чотирнадцять? Без проблем.", "Чотири, п’ять, шість! Шість яблук!", "Дев’ятнадцятий приходить за двадцять хвилин."]'::jsonb, 1, null, 'Četiri, pet, šest! Šest jabuka!', null, null, 'Прозвучало: «Četiri, pet, šest! Šest jabuka!» — «Чотири, п’ять, шість! Шість яблук!».', (select id from public.lessons where id = 'c0941bd8-57b5-5e7e-981f-9be423f24208'), 'PUBLISHED', 'claude_assessment_v1'),
  ('8bf95593-30f6-555b-af0c-e3b24f52aa0b', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Де ліфт?', 'Sobe u hotelu', '["Ліворуч", "Ліфта немає", "Праворуч"]'::jsonb, 2, null, null, 'Sobe 1 – 10: prvi kat
Sobe 11 – 20: drugi kat
Recepcija: prizemlje
Lift je desno.', 'Номери 1–10: перший поверх (над входом)
Номери 11–20: другий поверх
Рецепція: партер (поверх біля входу)
Ліфт праворуч.', 'Текст «Номери в готелі». Правильна відповідь: «Праворуч».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('fae54b9a-dd9c-5d3c-b91c-b69eb80e5711', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Da. Sto minus pedeset šest je četrdeset četiri?', '["Iz Ukrajine. Rodom sam iz Odese.", "U devet sati, s perona tri.", "Točno! Bravo."]'::jsonb, 2, null, 'Da. Sto minus pedeset šest je četrdeset četiri?', null, null, 'Діалог «Домашнє завдання»: «Da. Sto minus pedeset šest je četrdeset četiri?» (Так. Сто мінус п’ятдесят шість — сорок чотири?) — «Točno! Bravo.» (Правильно! Молодець.).', (select id from public.lessons where id = 'ba35964d-f0d8-5d15-9566-ef44d37e6d12'), 'PUBLISHED', 'claude_assessment_v1'),
  ('07a81436-b53d-5ec8-ad55-774f92c434a2', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Oprostite, koliki je popust?', '["Sok od naranče, molim.", "Trideset posto na sve jakne.", "Vino, molim. Na zdravlje!"]'::jsonb, 1, null, 'Oprostite, koliki je popust?', null, null, 'Діалог «Знижка»: «Oprostite, koliki je popust?» (Вибачте, яка знижка?) — «Trideset posto na sve jakne.» (Тридцять відсотків на всі куртки.).', (select id from public.lessons where id = '22dd7878-4fa8-5e1c-909e-71c70ffd9918'), 'PUBLISHED', 'claude_assessment_v1'),
  ('60b33c24-6a31-593e-b7e6-4b8f18a7c82b', v_aid, 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Koliko je kilometara od Zagreba do Splita?', '["Шістсот, може, трохи більше.", "Це велика відстань!", "Приблизно чотириста."]'::jsonb, 2, null, null, 'Daša: Koliko je kilometara od Zagreba do Splita?
Luka: Otprilike četiristo.
Daša: A do Dubrovnika?
Luka: Šesto, možda malo više.
Daša: To je velika udaljenost!
Luka: Je, ali cesta je jako lijepa.', 'Daša: Скільки кілометрів від Загреба до Спліта?
Luka: Приблизно чотириста.
Daša: А до Дубровника?
Luka: Шістсот, може, трохи більше.
Daša: Це велика відстань!
Luka: Так, але дорога дуже гарна.', 'Діалог «Скільки кілометрів?»: «Koliko je kilometara od Zagreba do Splita?» — «Otprilike četiristo.», тобто «Приблизно чотириста.».', (select id from public.lessons where id = 'c0d7b467-acb2-581a-975b-497e63f45aa7'), 'PUBLISHED', 'claude_assessment_v1'),
  ('46e27271-48fc-5b82-bd19-53b6c5825873', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Це дуже дорого». Що ви скажете?', null, '["Pola kile.", "Devetsto.", "To je jako skupo."]'::jsonb, 2, null, null, null, null, '«Це дуже дорого.» — «To je jako skupo.».', (select id from public.lessons where id = '427e5058-7381-58a0-8f21-bd170866dbae'), 'PUBLISHED', 'claude_assessment_v1'),
  ('1fc7945c-6b44-5f19-985b-e8b5e3922ca5', v_aid, 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «майже; практично»', null, '[]'::jsonb, null, 'gotovo', null, null, null, '«майже; практично» — gotovo.', (select id from public.lessons where id = '1f41cb75-1ce5-57ba-a56f-58561ee1d983'), 'PUBLISHED', 'claude_assessment_v1'),
  ('baaba207-cdfc-5439-9126-b57e4dfeef63', v_aid, 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Скільки це коштує?»', null, '["to", "košta?", "Koliko"]'::jsonb, null, 'Koliko to košta?', null, null, null, '«Скільки це коштує?» — «Koliko to košta?».', (select id from public.lessons where id = '427e5058-7381-58a0-8f21-bd170866dbae'), 'PUBLISHED', 'claude_assessment_v1'),
  ('249e7fa5-10d8-500f-8956-684b01aa3f07', v_aid, 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Дев’яносто дев’ять.»', null, '[]'::jsonb, null, 'Devedeset devet.', null, null, null, '«Дев’яносто дев’ять.» — «Devedeset devet.».', (select id from public.lessons where id = 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під уроки за темою (curriculum_a0_v4) — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('50480c91-04b8-56f3-bf3f-82bb73819b59', '55aa9d64-d200-59c9-9861-96f05a13c6fc', '8bf95593-30f6-555b-af0c-e3b24f52aa0b', 'fae54b9a-dd9c-5d3c-b91c-b69eb80e5711', '07a81436-b53d-5ec8-ad55-774f92c434a2', '60b33c24-6a31-593e-b7e6-4b8f18a7c82b', '46e27271-48fc-5b82-bd19-53b6c5825873', '1fc7945c-6b44-5f19-985b-e8b5e3922ca5', 'baaba207-cdfc-5439-9126-b57e4dfeef63', '249e7fa5-10d8-500f-8956-684b01aa3f07') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a0-m03')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'
                     and i.id not in ('50480c91-04b8-56f3-bf3f-82bb73819b59', '55aa9d64-d200-59c9-9861-96f05a13c6fc', '8bf95593-30f6-555b-af0c-e3b24f52aa0b', 'fae54b9a-dd9c-5d3c-b91c-b69eb80e5711', '07a81436-b53d-5ec8-ad55-774f92c434a2', '60b33c24-6a31-593e-b7e6-4b8f18a7c82b', '46e27271-48fc-5b82-bd19-53b6c5825873', '1fc7945c-6b44-5f19-985b-e8b5e3922ca5', 'baaba207-cdfc-5439-9126-b57e4dfeef63', '249e7fa5-10d8-500f-8956-684b01aa3f07')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірки модулів a0-m03 оновлено — % нових завдань', v_new;
end $$;

commit;
