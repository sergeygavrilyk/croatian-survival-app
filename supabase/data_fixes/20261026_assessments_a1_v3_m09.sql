-- =====================================================================
-- Перевірка модуля A1.9 під програму A1 v3 · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_assessment_a1_v3.py 9 (не редагуйте вручну).
--
-- Тести: a1-m09 — по 10 завдань із нових діалогів і вправ модуля.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A1). Середину й фінал рівня A1 не змінено (їх — після всього A1).
--   * Потрібні: 20261026_curriculum_a1_v3_structure.sql і 20261026_curriculum_a1_v3_m09.sql.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A1.9 · Модуль A1.9 — Люди й вільний час
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a1-m09';
  if v_aid is null then  -- новий модуль програми v3: тесту ще немає
    insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index, pass_ratio,
                                    area_min_ratio, estimated_minutes, description_ua)
    values ('7f5e9d2e-12ec-5905-af8e-6efc6ff09841', 'a1-m09', 'module', 'Перевірка модуля A1.9', 1, 'PUBLISHED', 'claude_assessment_v1', 'A1',
            '4fae6fe1-6bf2-5eef-9023-f7425b151c9e', 9, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.')
    returning id into v_aid;
  end if;
  if exists (select 1 from public.assessment_items where id = '3a58b567-5bd3-52de-9f92-c110339b8c69') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '4fae6fe1-6bf2-5eef-9023-f7425b151c9e'::uuid then
    raise exception 'Тест a1-m09 прив’язаний не до модуля A1.9 — спершу 20261026_curriculum_a1_v3_structure.sql';
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
  ('3a58b567-5bd3-52de-9f92-c110339b8c69', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Рекс. А тебе як звати, юначе?", "Стежка важка?", "Як романтично! Скільки ви разом?"]'::jsonb, 2, null, 'Kako romantično! Koliko ste dugo u vezi?', null, null, 'Прозвучало: «Kako romantično! Koliko ste dugo u vezi?» — «Як романтично! Скільки ви разом?».', (select id from public.lessons where id = '0d0547ed-c0ef-53bd-bfe4-c482c84c40f4'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b0aff28c-f894-5ac5-ada4-07a4f4506ec3', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Балет. Квитки ще продаються.", "Актори добрі, погоджуюся, але сюжет повільний.", "Можеш поїхати будь-коли, пором ходить щодня."]'::jsonb, 2, null, 'Možeš ići bilo kad, trajekt vozi svaki dan.', null, null, 'Прозвучало: «Možeš ići bilo kad, trajekt vozi svaki dan.» — «Можеш поїхати будь-коли, пором ходить щодня.».', (select id from public.lessons where id = '3f440ad8-f057-5898-b773-6aa8816fa8a3'), 'PUBLISHED', 'claude_assessment_v1'),
  ('16abfcb1-dc9d-51be-b8b6-32a993d804f6', v_aid, 3, 'A1', 'reading', 'understand', 'multiple_choice', 'Що радять узяти?', 'Koncert u parku', '["Ковдру", "Квиток", "Парасольку"]'::jsonb, 0, null, null, 'KONCERT U PARKU ZRINJEVAC
Subota, 20 sati
Svira lokalni bend.
Ulaz je besplatan!
Ako pada kiša, koncert je u kazalištu.
Ponesite deku i dobru volju.', 'КОНЦЕРТ У ПАРКУ ЗРИНЄВАЦ
Субота, 20 година
Грає місцевий гурт.
Вхід вільний!
Якщо йде дощ, концерт відбудеться в театрі.
Візьміть ковдру й гарний настрій.', 'Текст «Концерт у парку». Правильна відповідь: «Ковдру».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('13efad74-7ac6-5f2d-8236-e4270451addf', v_aid, 4, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Filip želi trenirati. Koji sport preporučuješ?', '["Ponekad, jer sam stalno iscrpljena.", "Barem tjedan dana prije.", "Rukomet ili košarka, ovdje su jako popularni."]'::jsonb, 2, null, 'Filip želi trenirati. Koji sport preporučuješ?', null, null, 'Діалог «Який спорт обрати?»: «Filip želi trenirati. Koji sport preporučuješ?» (Філіп хоче займатися спортом. Який вид порадиш?) — «Rukomet ili košarka, ovdje su jako popularni.» (Гандбол або баскетбол, тут вони дуже популярні.).', (select id from public.lessons where id = 'e61e3942-cd86-5f75-9eb5-d878242125bf'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d068171b-b03e-50df-9c14-4e5ad7910a54', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje je planinarski dom?', '["Sutra poslije podne, vidjet ćete ih u e-Građanima.", "Organizacija. Volim odgovornost.", "Malo niže. Tamo se okupljamo s ostalima."]'::jsonb, 2, null, 'Gdje je planinarski dom?', null, null, 'Діалог «На вершині»: «Gdje je planinarski dom?» (Де гірський притулок?) — «Malo niže. Tamo se okupljamo s ostalima.» (Трохи нижче. Там ми збираємося з іншими.).', (select id from public.lessons where id = 'dde31f54-28b8-505b-aba6-3e578601fccb'), 'PUBLISHED', 'claude_assessment_v1'),
  ('267306fb-f708-5728-92db-ecdca9b7ab95', v_aid, 6, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Koliko puta tjedno imaju trening?', '["Моя донька займається волейболом. Тренер чудовий.", "Тричі, а на вихідних грають матчі за шкільну команду.", "Гандбол або баскетбол, тут вони дуже популярні."]'::jsonb, 1, null, null, 'Daša: Filip želi trenirati. Koji sport preporučuješ?
Ana: Rukomet ili košarka, ovdje su jako popularni.
Daša: On voli loptu, ali i plivati.
Ana: Moja kći trenira odbojku. Trener je odličan.
Daša: Koliko puta tjedno imaju trening?
Ana: Triput, a vikendom igraju utakmice za momčad škole.', 'Daša: Філіп хоче займатися спортом. Який вид порадиш?
Ana: Гандбол або баскетбол, тут вони дуже популярні.
Daša: Він любить м’яч, але й плавати.
Ana: Моя донька займається волейболом. Тренер чудовий.
Daša: Скільки разів на тиждень у них тренування?
Ana: Тричі, а на вихідних грають матчі за шкільну команду.', 'Діалог «Який спорт обрати?»: «Koliko puta tjedno imaju trening?» — «Triput, a vikendom igraju utakmice za momčad škole.», тобто «Тричі, а на вихідних грають матчі за шкільну команду.».', (select id from public.lessons where id = 'e61e3942-cd86-5f75-9eb5-d878242125bf'), 'PUBLISHED', 'claude_assessment_v1'),
  ('7fafabff-eeb0-55c9-808c-09c08a1a53df', v_aid, 7, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Можемо на «ти»?». Що ви скажете?', null, '["Koliko ste dugo u vezi?", "Možemo li se tikati?", "Nađimo se kod ulaza."]'::jsonb, 1, null, null, null, null, '«Можемо на «ти»?» — «Možemo li se tikati?».', (select id from public.lessons where id = '6df343ef-4a40-5dfb-9100-7ab47fb1667d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('5ca349a1-e502-559e-8906-59037199c69a', v_aid, 8, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «розлючений»', null, '[]'::jsonb, null, 'bijesan', null, null, null, '«розлючений» — bijesan.', (select id from public.lessons where id = 'fac55dd6-0020-5997-8461-45ee2f94d3c5'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e5d4a2a5-8257-5cce-be34-e254d8789a1b', v_aid, 9, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Хто переміг?»', null, '["Tko", "pobijedio?", "je"]'::jsonb, null, 'Tko je pobijedio?', null, null, null, '«Хто переміг?» — «Tko je pobijedio?».', (select id from public.lessons where id = 'e61e3942-cd86-5f75-9eb5-d878242125bf'), 'PUBLISHED', 'claude_assessment_v1'),
  ('2d87097a-bf00-5d39-895a-b282c46dd9f4', v_aid, 10, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Я закохана.»', null, '[]'::jsonb, null, 'Zaljubljena sam.', null, null, null, '«Я закохана.» — «Zaljubljena sam.».', (select id from public.lessons where id = '0d0547ed-c0ef-53bd-bfe4-c482c84c40f4'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під програму A1 v3 — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('3a58b567-5bd3-52de-9f92-c110339b8c69', 'b0aff28c-f894-5ac5-ada4-07a4f4506ec3', '16abfcb1-dc9d-51be-b8b6-32a993d804f6', '13efad74-7ac6-5f2d-8236-e4270451addf', 'd068171b-b03e-50df-9c14-4e5ad7910a54', '267306fb-f708-5728-92db-ecdca9b7ab95', '7fafabff-eeb0-55c9-808c-09c08a1a53df', '5ca349a1-e502-559e-8906-59037199c69a', 'e5d4a2a5-8257-5cce-be34-e254d8789a1b', '2d87097a-bf00-5d39-895a-b282c46dd9f4') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a1-m09')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('3a58b567-5bd3-52de-9f92-c110339b8c69', 'b0aff28c-f894-5ac5-ada4-07a4f4506ec3', '16abfcb1-dc9d-51be-b8b6-32a993d804f6', '13efad74-7ac6-5f2d-8236-e4270451addf', 'd068171b-b03e-50df-9c14-4e5ad7910a54', '267306fb-f708-5728-92db-ecdca9b7ab95', '7fafabff-eeb0-55c9-808c-09c08a1a53df', '5ca349a1-e502-559e-8906-59037199c69a', 'e5d4a2a5-8257-5cce-be34-e254d8789a1b', '2d87097a-bf00-5d39-895a-b282c46dd9f4')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів A1: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірку a1-m09 оновлено — % нових завдань', v_new;
end $$;

commit;
