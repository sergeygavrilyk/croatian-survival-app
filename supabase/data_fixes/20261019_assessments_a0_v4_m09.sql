-- =====================================================================
-- Перевірки модулів A0 під уроки за темою (curriculum_a0_v4) · 2026-10-19
-- Згенеровано: python3 -B scripts/gen_assessment_a0_v4.py (не редагуйте вручну).
--
-- Тести: a0-m09 — по 10 завдань із нових діалогів і вправ модулів A0.9.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A0). Середину й фінал рівня A0 не змінено.
--   * Потрібні: 20261015_assessments_a0_v1.sql і уроки curriculum_a0_v4 модуля A0.9 (20261019_curriculum_a0_v4_m09.sql).
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A0.9 · Модуль A0.9 — Grad (місто)
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a0-m09';
  if v_aid is null then raise exception 'Немає тесту a0-m09 — спершу 20261015_assessments_a0_v1.sql'; end if;
  if exists (select 1 from public.assessment_items where id = 'a8c39ae2-f94e-562c-9d66-313067b6e959') then return; end if;  -- уже оновлено
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
  ('a8c39ae2-f94e-562c-9d66-313067b6e959', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А якщо прийде контролер?", "Добрий день, коли починається екскурсія старим містом?", "Томиславе, який трамвай їде до вокзалу?"]'::jsonb, 1, null, 'Dobar dan, kada počinje obilazak starog grada?', null, null, 'Прозвучало: «Dobar dan, kada počinje obilazak starog grada?» — «Добрий день, коли починається екскурсія старим містом?».', (select id from public.lessons where id = '1e0384e5-6097-56ed-ab56-cf530f02ab73'), 'PUBLISHED', 'claude_assessment_v1'),
  ('14def3ff-53a9-563f-a250-f8274fc6aaf8', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Дар’є, ти тут водиш машину?", "Супер. А де найближчий обмін валют?", "На головний вокзал, будь ласка. Скільки коштуватиме поїздка?"]'::jsonb, 2, null, 'Na glavni kolodvor, molim. Koliko će koštati vožnja?', null, null, 'Прозвучало: «Na glavni kolodvor, molim. Koliko će koštati vožnja?» — «На головний вокзал, будь ласка. Скільки коштуватиме поїздка?».', (select id from public.lessons where id = 'e0b9d742-0418-597b-9482-b6e2d82469da'), 'PUBLISHED', 'claude_assessment_v1'),
  ('2203c12f-2fe2-5149-af84-f923734db501', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Куди йти до лікарні?', 'Putokaz u gradu', '["Прямо", "Ліворуч", "Праворуч"]'::jsonb, 0, null, null, 'Centar 1 km →
Kolodvor 500 m ←
Bolnica 2 km ↑
Muzej ←
Ljekarna 100 m →', 'Центр 1 км →
Вокзал 500 м ←
Лікарня 2 км ↑
Музей ←
Аптека 100 м →', 'Текст «Дороговказ у місті». Правильна відповідь: «Прямо».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('6147d5f2-016d-54dc-90e6-d1f454bce102', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Smijem li fotografirati u katedrali?', '["Ona crna. Ova je premalena za tebe.", "Možete, ali bez bljeskalice.", "Za točno petnaest minuta."]'::jsonb, 1, null, 'Smijem li fotografirati u katedrali?', null, null, 'Діалог «Екскурсія старим містом»: «Smijem li fotografirati u katedrali?» (Можна фотографувати в соборі?) — «Možete, ali bez bljeskalice.» (Можна, але без спалаху.).', (select id from public.lessons where id = '1e0384e5-6097-56ed-ab56-cf530f02ab73'), 'PUBLISHED', 'claude_assessment_v1'),
  ('4682b13f-467a-5fc3-959a-a0b272d3ae2f', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje mogu kupiti kartu?', '["U crkvi u Zadru. Naravno, i ti si pozvana!", "Volim proljeće, posebno travanj i svibanj.", "Na kiosku ili kod vozača. Uđi na prednja vrata."]'::jsonb, 2, null, 'Gdje mogu kupiti kartu?', null, null, 'Діалог «Яким трамваєм?»: «Gdje mogu kupiti kartu?» (Де можна купити квиток?) — «Na kiosku ili kod vozača. Uđi na prednja vrata.» (У кіоску або у водія. Заходь через передні двері.).', (select id from public.lessons where id = 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('56ab6ff6-e199-5ffc-b579-9fb77a41efdd', v_aid, 6, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Što ćemo vidjeti?', '["О десятій, біля фонтана на головній площі.", "Можна, але без спалаху.", "Собор, старий палац і міські мури."]'::jsonb, 2, null, null, 'Daša: Dobar dan, kada počinje obilazak starog grada?
Vodič: U deset sati, kod fontane na glavnom trgu.
Daša: Što ćemo vidjeti?
Vodič: Katedralu, staru palaču i gradske zidine.
Daša: Smijem li fotografirati u katedrali?
Vodič: Možete, ali bez bljeskalice.', 'Daša: Добрий день, коли починається екскурсія старим містом?
Vodič: О десятій, біля фонтана на головній площі.
Daša: Що ми побачимо?
Vodič: Собор, старий палац і міські мури.
Daša: Можна фотографувати в соборі?
Vodič: Можна, але без спалаху.', 'Діалог «Екскурсія старим містом»: «Što ćemo vidjeti?» — «Katedralu, staru palaču i gradske zidine.», тобто «Собор, старий палац і міські мури.».', (select id from public.lessons where id = '1e0384e5-6097-56ed-ab56-cf530f02ab73'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b35d80c1-dfea-5e78-90b5-b825a80d8f54', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Який автобус їде в центр?». Що ви скажете?', null, '["Koji autobus ide u centar?", "U koliko sati počinje obilazak?", "Koliko je daleko do centra?"]'::jsonb, 0, null, null, null, null, '«Який автобус їде в центр?» — «Koji autobus ide u centar?».', (select id from public.lessons where id = 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('c9f98852-4c3a-5b05-851a-e538cec984e0', v_aid, 8, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «затор; тиснява»', null, '[]'::jsonb, null, 'gužva', null, null, null, '«затор; тиснява» — gužva.', (select id from public.lessons where id = 'e0b9d742-0418-597b-9482-b6e2d82469da'), 'PUBLISHED', 'claude_assessment_v1'),
  ('8a6f40ef-770a-5e01-a805-4cf045ad3838', v_aid, 9, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я хочу оглянути старе місто.»', null, '["razgledati", "grad.", "stari", "Želim"]'::jsonb, null, 'Želim razgledati stari grad.', null, null, null, '«Я хочу оглянути старе місто.» — «Želim razgledati stari grad.».', (select id from public.lessons where id = '1e0384e5-6097-56ed-ab56-cf530f02ab73'), 'PUBLISHED', 'claude_assessment_v1'),
  ('ccd51e82-e124-52d0-a823-635177a62000', v_aid, 10, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Де найближча заправка?»', null, '[]'::jsonb, null, 'Gdje je najbliža benzinska postaja?', null, null, null, '«Де найближча заправка?» — «Gdje je najbliža benzinska postaja?».', (select id from public.lessons where id = 'e0b9d742-0418-597b-9482-b6e2d82469da'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під уроки за темою (curriculum_a0_v4) — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('a8c39ae2-f94e-562c-9d66-313067b6e959', '14def3ff-53a9-563f-a250-f8274fc6aaf8', '2203c12f-2fe2-5149-af84-f923734db501', '6147d5f2-016d-54dc-90e6-d1f454bce102', '4682b13f-467a-5fc3-959a-a0b272d3ae2f', '56ab6ff6-e199-5ffc-b579-9fb77a41efdd', 'b35d80c1-dfea-5e78-90b5-b825a80d8f54', 'c9f98852-4c3a-5b05-851a-e538cec984e0', '8a6f40ef-770a-5e01-a805-4cf045ad3838', 'ccd51e82-e124-52d0-a823-635177a62000') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a0-m09')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'
                     and i.id not in ('a8c39ae2-f94e-562c-9d66-313067b6e959', '14def3ff-53a9-563f-a250-f8274fc6aaf8', '2203c12f-2fe2-5149-af84-f923734db501', '6147d5f2-016d-54dc-90e6-d1f454bce102', '4682b13f-467a-5fc3-959a-a0b272d3ae2f', '56ab6ff6-e199-5ffc-b579-9fb77a41efdd', 'b35d80c1-dfea-5e78-90b5-b825a80d8f54', 'c9f98852-4c3a-5b05-851a-e538cec984e0', '8a6f40ef-770a-5e01-a805-4cf045ad3838', 'ccd51e82-e124-52d0-a823-635177a62000')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірки модулів a0-m09 оновлено — % нових завдань', v_new;
end $$;

commit;
