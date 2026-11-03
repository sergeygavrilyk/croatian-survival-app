-- =====================================================================
-- Перевірка модуля A1.7 під програму A1 v3 · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_assessment_a1_v3.py 7 (не редагуйте вручну).
--
-- Тести: a1-m07 — по 10 завдань із нових діалогів і вправ модуля.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A1). Середину й фінал рівня A1 не змінено (їх — після всього A1).
--   * Потрібні: 20261026_curriculum_a1_v3_structure.sql і 20261026_curriculum_a1_v3_m07.sql.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A1.7 · Модуль A1.7 — Комп’ютер, телефон та інтернет
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a1-m07';
  if v_aid is null then  -- новий модуль програми v3: тесту ще немає
    insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index, pass_ratio,
                                    area_min_ratio, estimated_minutes, description_ua)
    values ('2a304ab5-c43c-5c29-8607-bee6d9b59bd0', 'a1-m07', 'module', 'Перевірка модуля A1.7', 1, 'PUBLISHED', 'claude_assessment_v1', 'A1',
            '09e7c668-b622-56b2-82e9-b1c0c0db54c6', 7, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.')
    returning id into v_aid;
  end if;
  if exists (select 1 from public.assessment_items where id = '04286fbb-467d-5dd1-860b-3183196a687e') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '09e7c668-b622-56b2-82e9-b1c0c0db54c6'::uuid then
    raise exception 'Тест a1-m07 прив’язаний не до модуля A1.7 — спершу 20261026_curriculum_a1_v3_structure.sql';
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
  ('04286fbb-467d-5dd1-860b-3183196a687e', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Спробуй онлайн-запис на сайті поліклініки.", "Добрий день, мені потрібна SIM-картка з хорватським номером.", "Відкрий вкладення й збережи файл."]'::jsonb, 0, null, 'Probaj e-naručivanje na web-stranici doma zdravlja.', null, null, 'Прозвучало: «Probaj e-naručivanje na web-stranici doma zdravlja.» — «Спробуй онлайн-запис на сайті поліклініки.».', (select id from public.lessons where id = '953e12fb-a6f6-5ae5-aa7a-ebfe248d24da'), 'PUBLISHED', 'claude_assessment_v1'),
  ('321dacb3-0c83-56e4-a9b9-adcd8fe15a29', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Луко, я забула пароль від банку!", "На твою робочу. Тема — «Договір».", "Я залишив тобі повідомлення на голосовій пошті."]'::jsonb, 0, null, 'Luka, zaboravila sam lozinku za banku!', null, null, 'Прозвучало: «Luka, zaboravila sam lozinku za banku!» — «Луко, я забула пароль від банку!».', (select id from public.lessons where id = 'f355be7d-c423-5651-938e-71b8ca970a62'), 'PUBLISHED', 'claude_assessment_v1'),
  ('232f77b8-7a58-5fd7-be96-cd9a3a2188db', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Клацни мишкою на налаштування, а потім на «Оновлення».", "І поставте мені зимові шини, будь ласка.", "Пише, що його треба перезавантажити."]'::jsonb, 2, null, 'Piše da ga moram ponovno pokrenuti.', null, null, 'Прозвучало: «Piše da ga moram ponovno pokrenuti.» — «Пише, що його треба перезавантажити.».', (select id from public.lessons where id = '8e08a8e3-8969-52fc-bc82-5a403dd7ad35'), 'PUBLISHED', 'claude_assessment_v1'),
  ('8818aef4-7bae-5b8e-9fb5-18f2ca1f1c37', v_aid, 4, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Zvao sam te tri puta. Jesi li vidjela propuštene pozive?', '["Nisam, na otoku nema signala.", "Ove dvije su slične, ali ova je povoljnija.", "Izlaz sedam. Evo vaše ukrcajne propusnice."]'::jsonb, 0, null, 'Zvao sam te tri puta. Jesi li vidjela propuštene pozive?', null, null, 'Діалог «Немає сигналу»: «Zvao sam te tri puta. Jesi li vidjela propuštene pozive?» (Я дзвонив тобі тричі. Ти бачила пропущені дзвінки?) — «Nisam, na otoku nema signala.» (Ні, на острові немає сигналу.).', (select id from public.lessons where id = '35203547-5f9a-5857-95a0-3a0d596f715d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d75840ee-13f4-5792-a17f-3a4e4b21ad97', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Nisam. Gdje se to radi?', '["Klikni mišem na postavke, pa na «Ažuriranje».", "Iznad stolića u dnevnom boravku.", "Jutros je ulovljena, kao i brancin."]'::jsonb, 0, null, 'Nisam. Gdje se to radi?', null, null, 'Діалог «Комп’ютер гальмує»: «Nisam. Gdje se to radi?» (Ні. Де це робиться?) — «Klikni mišem na postavke, pa na «Ažuriranje».» (Клацни мишкою на налаштування, а потім на «Оновлення».).', (select id from public.lessons where id = '8e08a8e3-8969-52fc-bc82-5a403dd7ad35'), 'PUBLISHED', 'claude_assessment_v1'),
  ('38c29f10-9024-525d-846d-2ad0834b041d', v_aid, 6, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dobro, uzimam njega. Treba li mi adapter?', '["Добрий день, я шукаю ноутбук для доньки, для навчання.", "Не потрібен, кабель у коробці.", "У другого, і батарея в нього тримає довше."]'::jsonb, 1, null, null, 'Daša: Dobar dan, tražim laptop za kćer, za školu.
Prodavač: Ovaj je lakši, a ovaj ima veću memoriju.
Daša: Koji ima bolji ekran?
Prodavač: Drugi, i baterija mu traje duže.
Daša: Dobro, uzimam njega. Treba li mi adapter?
Prodavač: Ne treba, kabel je u kutiji.', 'Daša: Добрий день, я шукаю ноутбук для доньки, для навчання.
Prodavač: Цей легший, а в цього більша пам’ять.
Daša: У якого кращий екран?
Prodavač: У другого, і батарея в нього тримає довше.
Daša: Добре, беру його. Мені потрібен перехідник?
Prodavač: Не потрібен, кабель у коробці.', 'Діалог «Ноутбук для навчання»: «Dobro, uzimam njega. Treba li mi adapter?» — «Ne treba, kabel je u kutiji.», тобто «Не потрібен, кабель у коробці.».', (select id from public.lessons where id = '31bbedca-4b51-5478-8513-df5cb996ffd9'), 'PUBLISHED', 'claude_assessment_v1'),
  ('fa315a4e-fbd0-59b3-933f-e86972fa3cba', v_aid, 7, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я надіслав тобі листа». Що ви скажете?', null, '["Zaboravila sam lozinku.", "Poslao sam ti mail.", "Koliki je polog?"]'::jsonb, 1, null, null, null, null, '«Я надіслав тобі листа.» — «Poslao sam ti mail.».', (select id from public.lessons where id = '71537166-9f48-503f-b564-3a4f99a192c5'), 'PUBLISHED', 'claude_assessment_v1'),
  ('4dfa096b-aeae-5700-afce-7710aea79527', v_aid, 8, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «необмежений, безлімітний»', null, '[]'::jsonb, null, 'neograničen', null, null, null, '«необмежений, безлімітний» — neograničen.', (select id from public.lessons where id = '35203547-5f9a-5857-95a0-3a0d596f715d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d091f168-f0c1-5f7d-a2bd-425b00a376b7', v_aid, 9, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Треба заповнити бланк.»', null, '["obrazac.", "Treba", "ispuniti"]'::jsonb, null, 'Treba ispuniti obrazac.', null, null, null, '«Треба заповнити бланк.» — «Treba ispuniti obrazac.».', (select id from public.lessons where id = '953e12fb-a6f6-5ae5-aa7a-ebfe248d24da'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b1e38cb6-c5d9-5b91-8e32-4389fc9bf09c', v_aid, 10, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Завантажте документ.»', null, '[]'::jsonb, null, 'Učitajte dokument.', null, null, null, '«Завантажте документ.» — «Učitajte dokument.».', (select id from public.lessons where id = '953e12fb-a6f6-5ae5-aa7a-ebfe248d24da'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під програму A1 v3 — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('04286fbb-467d-5dd1-860b-3183196a687e', '321dacb3-0c83-56e4-a9b9-adcd8fe15a29', '232f77b8-7a58-5fd7-be96-cd9a3a2188db', '8818aef4-7bae-5b8e-9fb5-18f2ca1f1c37', 'd75840ee-13f4-5792-a17f-3a4e4b21ad97', '38c29f10-9024-525d-846d-2ad0834b041d', 'fa315a4e-fbd0-59b3-933f-e86972fa3cba', '4dfa096b-aeae-5700-afce-7710aea79527', 'd091f168-f0c1-5f7d-a2bd-425b00a376b7', 'b1e38cb6-c5d9-5b91-8e32-4389fc9bf09c') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a1-m07')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('04286fbb-467d-5dd1-860b-3183196a687e', '321dacb3-0c83-56e4-a9b9-adcd8fe15a29', '232f77b8-7a58-5fd7-be96-cd9a3a2188db', '8818aef4-7bae-5b8e-9fb5-18f2ca1f1c37', 'd75840ee-13f4-5792-a17f-3a4e4b21ad97', '38c29f10-9024-525d-846d-2ad0834b041d', 'fa315a4e-fbd0-59b3-933f-e86972fa3cba', '4dfa096b-aeae-5700-afce-7710aea79527', 'd091f168-f0c1-5f7d-a2bd-425b00a376b7', 'b1e38cb6-c5d9-5b91-8e32-4389fc9bf09c')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів A1: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірку a1-m07 оновлено — % нових завдань', v_new;
end $$;

commit;
