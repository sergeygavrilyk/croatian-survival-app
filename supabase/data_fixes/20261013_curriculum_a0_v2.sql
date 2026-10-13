-- =====================================================================
-- Розширення уроків A0 · curriculum_a0_v2 · 2026-10-13
-- Згенеровано: python3 scripts/gen_curriculum_a0_v2.py (не редагуйте вручну).
--
--   * Кожен з 30 уроків A0: +слова (разом 10–12), друга сцена діалогу, 9 нових вправ
--     (склади речення, аудіювання, 2 × скажіть уголос, 5 вправ на слова) → ~12 хв.
--   * Нові слова: 13. Виправлення перекладів: 4 (старі — у content_versions).
--   * Статус PUBLISHED: бета за рішенням власника (як і A0 v1).
--   * Наявні вправи, слова й діалоги НЕ видаляються. Повторний запуск безпечний.
--   * Потрібна міграція M13 (20261013140000_m13_exercise_types.sql).
--   * Нові типи вправ (type_answer, speaking, multiple_choice) показує лише новий екран уроку
--     (components/lesson/LessonPlayer.tsx). Старий LessonView на сайті їх не вміє — після запуску
--     перевірте на localhost і оновіть сайт (push).
-- =====================================================================

begin;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'exercises_type_check'
                 and pg_get_constraintdef(oid) like '%speaking%') then
    raise exception 'Спершу запустіть міграцію M13 (20261013140000_m13_exercise_types.sql)';
  end if;
  if (select count(*) from public.lessons where level_code = 'A0' and status = 'PUBLISHED') < 30 then
    raise exception 'Немає 30 уроків A0 — спершу curriculum_a0_v1';
  end if;
end $$;

-- 1. Нові слова A0 (яких ще немає у словнику)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kako si', 'kako si', 'hr', 'phrase', 'A0', 'як ти?; як справи? (до друга)', 'formulaic', '{}'::jsonb, '["Bok, Marko! Kako si?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kako ste', 'kako ste', 'hr', 'phrase', 'A0', 'як ви?; як справи? (ввічливо)', 'formulaic', '{}'::jsonb, '["Dobar dan, gospođo! Kako ste?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('hvala lijepa', 'hvala lijepa', 'hr', 'phrase', 'A0', 'щиро дякую', 'formulaic', '{}'::jsonb, '["Hvala lijepa na pomoći!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jagoda', 'jagoda', 'hr', 'noun', 'A0', 'полуниця', 'core', '{"gender": "f"}'::jsonb, '["Ove jagode su jako slatke."]'::jsonb, 'PUBLISHED', 'claude_curriculum_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tjestenina', 'tjestenina', 'hr', 'noun', 'A0', 'макарони; паста', 'core', '{"gender": "f"}'::jsonb, '["Za ručak imamo tjesteninu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('preko puta', 'preko puta', 'hr', 'adverb', 'A0', 'навпроти', 'chunk', '{}'::jsonb, '["Stanica je preko puta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nažalost', 'nazalost', 'hr', 'adverb', 'A0', 'на жаль', 'function_word', '{}'::jsonb, '["Nažalost, nemam vremena."]'::jsonb, 'PUBLISHED', 'claude_curriculum_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('u redu', 'u redu', 'hr', 'phrase', 'A0', 'гаразд; добре', 'formulaic', '{}'::jsonb, '["U redu, vidimo se sutra."]'::jsonb, 'PUBLISHED', 'claude_curriculum_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ukupno', 'ukupno', 'hr', 'adverb', 'A0', 'разом; загалом', 'core', '{}'::jsonb, '["Ukupno je dvadeset eura."]'::jsonb, 'PUBLISHED', 'claude_curriculum_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('napojnica', 'napojnica', 'hr', 'noun', 'A0', 'чайові', 'core', '{"gender": "f"}'::jsonb, '["Konobaru smo ostavili napojnicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('datum rođenja', 'datum rodenja', 'hr', 'phrase', 'A0', 'дата народження', 'collocation', '{}'::jsonb, '["Upišite datum rođenja ovdje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('termin', 'termin', 'hr', 'noun', 'A0', '(вільний) час; запис (до лікаря, перукаря)', 'core', '{"gender": "m"}'::jsonb, '["Imate li slobodan termin u petak?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sladak', 'sladak', 'hr', 'adjective', 'A0', 'солодкий', 'core', '{}'::jsonb, '["Ove jagode su slatke."]'::jsonb, 'PUBLISHED', 'claude_curriculum_v2')
on conflict do nothing;

-- 2. Виправлення перекладів (старий варіант зберігається в content_versions)
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('skupo') and ukrainian_translation = 'дороге';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a0_v2: переклад «дороге» → «дорого»');
  update public.lexemes set ukrainian_translation = 'дорого' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a0_v2: переклад «дороге» → «дорого»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('jeftino') and ukrainian_translation = 'дешеве';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a0_v2: переклад «дешеве» → «дешево»');
  update public.lexemes set ukrainian_translation = 'дешево' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a0_v2: переклад «дешеве» → «дешево»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('vruće') and ukrainian_translation = 'гаряче';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a0_v2: переклад «гаряче» → «гаряче; спекотно»');
  update public.lexemes set ukrainian_translation = 'гаряче; спекотно' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a0_v2: переклад «гаряче» → «гаряче; спекотно»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('piće') and ukrainian_translation = 'напої';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a0_v2: переклад «напої» → «напій»');
  update public.lexemes set ukrainian_translation = 'напій' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a0_v2: переклад «напої» → «напій»');
end $$;

-- 3. Уроки
-- Урок 1: +9 слів, сцена «У сусідки», 9 нових вправ
do $$
declare
  v_lesson constant uuid := 'c0000000-0000-0000-0000-000000000001';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 1 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '8f6abb8b-aecc-5c01-bf6d-6a848c73c9c9') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('kako si') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kako si'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('kako ste') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kako ste'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('dobro') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dobro'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('loše') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'loše'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('umoran') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'umoran'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('žao mi je') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'žao mi je'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('hvala lijepa') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hvala lijepa'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('da') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'da'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('ne') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ne'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('loše') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('40003602-d70c-59f4-a996-2be52a4cd9fe', 'multiple_choice', 'Що означає «loše»?', 'погано', '["добре", "погано", "привіт / бувай", "втомлений"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '40003602-d70c-59f4-a996-2be52a4cd9fe', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kako si') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a3cc2097-eb72-577a-ab82-f9e92150b5da', 'multiple_choice', 'Що означає «kako si»?', 'як ти?; як справи? (до друга)', '["як ти?; як справи? (до друга)", "ні", "втомлений", "мені шкода"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a3cc2097-eb72-577a-ab82-f9e92150b5da', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ne') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('bd42653b-b91e-5dc8-a055-4f5ec7ea348a', 'multiple_choice', 'Як хорватською «ні»?', 'ne', '["hvala lijepa", "ne", "bok", "umoran"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'bd42653b-b91e-5dc8-a055-4f5ec7ea348a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('umoran') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('76fe54c8-e603-51eb-a7f8-341f4b5eed61', 'type_answer', 'Напишіть хорватською: «втомлений»', 'umoran', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '76fe54c8-e603-51eb-a7f8-341f4b5eed61', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('dobro') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c3ef449f-8beb-5662-bc77-429309ba407f', 'type_answer', 'Напишіть хорватською: «добре»', 'dobro', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c3ef449f-8beb-5662-bc77-429309ba407f', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('90c8c769-a007-5e83-9e47-03f7b292d622', 'sentence_builder', 'Складіть: «Добре, дякую. А ви?»', 'Dobro, hvala. A Vi?', '["hvala.", "Vi?", "A", "Dobro,"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '90c8c769-a007-5e83-9e47-03f7b292d622', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f0629441-0e44-58cf-80a5-3012b81d77fb', 'sentence_builder', 'Складіть: «Привіт! Як справи?»', 'Bok! Kako si?', '["Kako", "si?", "Bok!"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f0629441-0e44-58cf-80a5-3012b81d77fb', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('50dad67d-82b1-5df8-8822-2fcd9c429a24', 'listening', 'Прослухайте і складіть фразу', 'Ne baš dobro. Umorna sam.', '["baš", "dobro.", "Umorna", "Ne", "sam."]'::jsonb, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '50dad67d-82b1-5df8-8822-2fcd9c429a24', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('967e384e-dcb1-5de1-966a-e2432a5500fd', 'listening', 'Прослухайте і складіть фразу', 'Dobro sam, hvala.', '["sam,", "hvala.", "Dobro"]'::jsonb, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '967e384e-dcb1-5de1-966a-e2432a5500fd', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('281616bb-6c31-5fe0-9cb2-109b50b738e8', 'speaking', 'Привіт! Як справи?', 'Bok! Kako si?', null, 'A0', 20, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '281616bb-6c31-5fe0-9cb2-109b50b738e8', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9de67cd8-5477-5e99-a536-f5e8ab268c3c', 'speaking', 'Мені шкода.', 'Žao mi je.', null, 'A0', 21, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9de67cd8-5477-5e99-a536-f5e8ab268c3c', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8f6abb8b-aecc-5c01-bf6d-6a848c73c9c9', v_lesson, 'У сусідки', 'Kod susjede', 101, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ec70d053-b9af-5a4c-9372-badfa140dcec', '8f6abb8b-aecc-5c01-bf6d-6a848c73c9c9', 'Ivana', 'Dobar dan, gospodine Petrenko! Kako ste?', 'Добрий день, пане Петренко! Як ви?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5000910e-f366-51dd-8060-058fc80c1af3', '8f6abb8b-aecc-5c01-bf6d-6a848c73c9c9', 'Petrenko', 'Dobro, hvala. A Vi?', 'Добре, дякую. А ви?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f4488b74-3699-5624-8692-ef7f5dac26f9', '8f6abb8b-aecc-5c01-bf6d-6a848c73c9c9', 'Ivana', 'Ne baš dobro. Umorna sam.', 'Не дуже добре. Я втомлена.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('11aa3781-d579-5783-8b8b-5bf2eea3431e', '8f6abb8b-aecc-5c01-bf6d-6a848c73c9c9', 'Petrenko', 'Žao mi je.', 'Мені шкода.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8eefb633-6178-58e7-afe0-15f607ea270e', '8f6abb8b-aecc-5c01-bf6d-6a848c73c9c9', 'Ivana', 'Hvala. Doviđenja!', 'Дякую. До побачення!', 5) on conflict (id) do nothing;
  -- перший діалог уроку 1 створено до v1: доповнюємо рівень і ситуацію
  update public.conversations set level = coalesce(level, 'A0'), situation = coalesce(situation, 'basics')
   where lesson_id = v_lesson and id <> '8f6abb8b-aecc-5c01-bf6d-6a848c73c9c9' and (level is null or situation is null);
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '8f6abb8b-aecc-5c01-bf6d-6a848c73c9c9', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 2: +5 слів, сцена «Увечері в готелі», 9 нових вправ
do $$
declare
  v_lesson constant uuid := 'd8cffb46-8a62-538a-b864-e227a6d8b863';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 2 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '5b27b971-929e-52a5-90db-118b9073177e') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('kava') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kava'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('hvala lijepa') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hvala lijepa'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('ključ') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ključ'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('soba') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'soba'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('rezervacija') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rezervacija'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('soba') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c1ea9449-84f4-5584-a381-c728b773f6c7', 'multiple_choice', 'Що означає «soba»?', 'кімната', '["надобраніч", "кімната", "бронювання / резерв", "ключ"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c1ea9449-84f4-5584-a381-c728b773f6c7', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rezervacija') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('30accfd2-e2f6-5c6f-a162-4368e29adb19', 'multiple_choice', 'Що означає «rezervacija»?', 'бронювання / резерв', '["доброго ранку", "добрий день", "надобраніч", "бронювання / резерв"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '30accfd2-e2f6-5c6f-a162-4368e29adb19', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ključ') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c185c8d7-0ad7-5b19-b6a6-df0c6087d8dc', 'multiple_choice', 'Як хорватською «ключ»?', 'ključ', '["kava", "ugodan dan", "ključ", "dobar dan"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c185c8d7-0ad7-5b19-b6a6-df0c6087d8dc', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kava') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('300672d6-22af-596a-bcf8-30e41bdae5b7', 'type_answer', 'Напишіть хорватською: «кава»', 'kava', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '300672d6-22af-596a-bcf8-30e41bdae5b7', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('hvala lijepa') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fc6eec2b-9576-5895-bfaf-19f3b7dbf999', 'type_answer', 'Напишіть хорватською: «щиро дякую»', 'hvala lijepa', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fc6eec2b-9576-5895-bfaf-19f3b7dbf999', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('35ac3deb-4a28-5c87-a12f-0f2020834e3b', 'sentence_builder', 'Складіть: «Добрий вечір. У мене бронювання.»', 'Dobra večer. Imam rezervaciju.', '["večer.", "Dobra", "rezervaciju.", "Imam"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '35ac3deb-4a28-5c87-a12f-0f2020834e3b', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('83f68ca6-52c4-5499-9777-0941d72980e0', 'listening', 'Прослухайте і складіть фразу', 'Hvala lijepa. Laku noć!', '["lijepa.", "Laku", "noć!", "Hvala"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '83f68ca6-52c4-5499-9777-0941d72980e0', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('17789f7e-6b77-5611-ad90-e80506ade22c', 'speaking', 'Одну каву, будь ласка.', 'Jednu kavu, molim.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '17789f7e-6b77-5611-ad90-e80506ade22c', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ce1a256e-c3e2-5c21-a4b3-8caea4f643fc', 'speaking', 'У мене бронювання.', 'Imam rezervaciju.', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ce1a256e-c3e2-5c21-a4b3-8caea4f643fc', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5b27b971-929e-52a5-90db-118b9073177e', v_lesson, 'Увечері в готелі', 'Navečer u hotelu', 102, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('680c2ab9-cd59-57a6-b288-4c33746c4518', '5b27b971-929e-52a5-90db-118b9073177e', 'Recepcionarka', 'Dobra večer! Izvolite?', 'Добрий вечір! Слухаю вас?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e670122a-5f96-5b1b-b280-bb135b9b1149', '5b27b971-929e-52a5-90db-118b9073177e', 'Olena', 'Dobra večer. Imam rezervaciju.', 'Добрий вечір. У мене бронювання.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('603bb37b-12d3-53c5-ae05-a39bde35e509', '5b27b971-929e-52a5-90db-118b9073177e', 'Recepcionarka', 'Da, izvolite ključ. Soba broj dvanaest.', 'Так, ось ключ. Кімната номер дванадцять.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d399417f-60ef-55a8-85fc-4ceeba8e5acc', '5b27b971-929e-52a5-90db-118b9073177e', 'Olena', 'Hvala lijepa. Laku noć!', 'Щиро дякую. На добраніч!', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('136bfbfe-af66-5339-a76a-42bb9d851028', '5b27b971-929e-52a5-90db-118b9073177e', 'Recepcionarka', 'Laku noć i ugodan boravak!', 'На добраніч і приємного перебування!', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '5b27b971-929e-52a5-90db-118b9073177e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 3: +5 слів, сцена «У магазині», 9 нових вправ
do $$
declare
  v_lesson constant uuid := 'a17f2f16-1be9-50f2-8e16-2bebfcced33b';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 3 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '99c04cad-8afe-53f9-9479-98463f6a9d9c') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('polako') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'polako'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('malo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'malo'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('govoriti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'govoriti'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('engleski') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'engleski'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('vrećica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vrećica'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('malo') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('cc819cc0-9d4c-5e2e-ac4d-cf8bf312434e', 'multiple_choice', 'Що означає «malo»?', 'мало / трохи', '["прошу / будь ласка / що (ви сказали)?", "мало / трохи", "можете повторити", "пакет"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'cc819cc0-9d4c-5e2e-ac4d-cf8bf312434e', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('govoriti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e29b8da8-139c-509b-a891-afe3883e9eaa', 'multiple_choice', 'Що означає «govoriti»?', 'говорити', '["звісно / звичайно", "вибачте / перепрошую", "говорити", "англійська (мова)"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e29b8da8-139c-509b-a891-afe3883e9eaa', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('engleski') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4fcfd325-772f-5eb3-a886-3e141e906c88', 'multiple_choice', 'Як хорватською «англійська (мова)»?', 'engleski', '["možete li ponoviti", "ne razumijem", "engleski", "malo"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4fcfd325-772f-5eb3-a886-3e141e906c88', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('polako') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2c5f0243-625d-5c8e-be51-0ff257a30685', 'type_answer', 'Напишіть хорватською: «повільно»', 'polako', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2c5f0243-625d-5c8e-be51-0ff257a30685', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('vrećica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('40511016-0eb5-56df-b5f1-a3d48dcc671b', 'type_answer', 'Напишіть хорватською: «пакет»', 'vrećica', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '40511016-0eb5-56df-b5f1-a3d48dcc671b', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('69e0e51f-4de6-5f2a-949d-25491b8a1fa6', 'sentence_builder', 'Складіть: «Вибачте, не розумію.»', 'Oprostite, ne razumijem.', '["ne", "razumijem.", "Oprostite,"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '69e0e51f-4de6-5f2a-949d-25491b8a1fa6', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d8622518-d5cb-5d8d-9a33-40eee995d0ef', 'listening', 'Прослухайте і складіть фразу', 'Trebate li vrećicu?', '["li", "Trebate", "vrećicu?"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd8622518-d5cb-5d8d-9a33-40eee995d0ef', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b26fc19f-73bd-5e5f-899a-367f3cf6be14', 'speaking', 'Можете говорити повільно?', 'Možete li govoriti polako?', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b26fc19f-73bd-5e5f-899a-367f3cf6be14', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d95a6ff6-10f7-5158-8044-1514e554dd62', 'speaking', 'Можете повторити?', 'Možete li ponoviti?', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd95a6ff6-10f7-5158-8044-1514e554dd62', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('99c04cad-8afe-53f9-9479-98463f6a9d9c', v_lesson, 'У магазині', 'U trgovini', 103, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('bd531439-da20-5274-8585-ab7a23a60d11', '99c04cad-8afe-53f9-9479-98463f6a9d9c', 'Prodavačica', 'Trebate li vrećicu?', 'Вам потрібен пакет?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5ec856a0-6b24-5d9f-adc8-9e3809aba8f6', '99c04cad-8afe-53f9-9479-98463f6a9d9c', 'Olena', 'Oprostite, ne razumijem. Možete li ponoviti?', 'Вибачте, не розумію. Можете повторити?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('fe788c75-3316-582f-9dc4-ebdee96bda20', '99c04cad-8afe-53f9-9479-98463f6a9d9c', 'Prodavačica', 'Vrećicu? Trebate li vrećicu?', 'Пакет? Вам потрібен пакет?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d4766573-dcb0-5a88-bc24-f1840f279059', '99c04cad-8afe-53f9-9479-98463f6a9d9c', 'Olena', 'Ah, da. Jednu, molim.', 'А, так. Один, будь ласка.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3078ca0e-1385-54a1-827c-8a92ec38955d', '99c04cad-8afe-53f9-9479-98463f6a9d9c', 'Prodavačica', 'Izvolite.', 'Прошу.', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4e0146ba-1be2-5980-9a90-53160795a7bf', '99c04cad-8afe-53f9-9479-98463f6a9d9c', 'Olena', 'Hvala!', 'Дякую!', 6) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '99c04cad-8afe-53f9-9479-98463f6a9d9c', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 4: +6 слів, сцена «На прийомі в лікаря», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '2b6ed342-cc80-5bd9-baf0-b66109624d62';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 4 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = 'fa4cde9c-d493-590b-8635-ce87ac34736b') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('gospodin') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'gospodin'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('gospođa') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'gospođa'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('bok') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'bok'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('ja') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ja'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('ti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ti'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('vi') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vi'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('vi') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('656cd6da-fd4a-523c-a642-0ba33f6bb3c4', 'multiple_choice', 'Що означає «vi»?', 'ви', '["як тебе звати", "прізвище", "привіт / бувай", "ви"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '656cd6da-fd4a-523c-a642-0ba33f6bb3c4', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('gospodin') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('79a8da72-df2a-57fa-9ee4-017153c0d1c0', 'multiple_choice', 'Що означає «gospodin»?', 'пан', '["ти", "пан", "ім''я", "як вас звати"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '79a8da72-df2a-57fa-9ee4-017153c0d1c0', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1d9757f0-2a2e-5a73-8d2f-9422ca6b66e8', 'multiple_choice', 'Як хорватською «ти»?', 'ti', '["ti", "zovem se", "gospođa", "drago mi je"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1d9757f0-2a2e-5a73-8d2f-9422ca6b66e8', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('gospođa') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b7ba0512-08e7-50f1-9877-abd82f2d3f45', 'type_answer', 'Напишіть хорватською: «пані»', 'gospođa', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b7ba0512-08e7-50f1-9877-abd82f2d3f45', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('ja') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d6c91a40-ba86-56cf-b856-d5bfb0a15ebe', 'type_answer', 'Напишіть хорватською: «я»', 'ja', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd6c91a40-ba86-56cf-b856-d5bfb0a15ebe', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c033840c-0a62-5da5-9eba-05581e5fc5ac', 'sentence_builder', 'Складіть: «Добрий день. Як вас звати?»', 'Dobar dan. Kako se zovete?', '["Dobar", "dan.", "se", "zovete?", "Kako"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c033840c-0a62-5da5-9eba-05581e5fc5ac', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6a7a5e57-eeff-5577-b7b3-1427090363fa', 'listening', 'Прослухайте і складіть фразу', 'A Vaše prezime?', '["Vaše", "A", "prezime?"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6a7a5e57-eeff-5577-b7b3-1427090363fa', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1b409039-53ba-5856-9fb4-33916e6c68b4', 'speaking', 'Мене звати Олег.', 'Zovem se Oleg.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1b409039-53ba-5856-9fb4-33916e6c68b4', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7b602afc-ef0f-5e76-8472-d716d59bc910', 'speaking', 'Приємно познайомитися.', 'Drago mi je.', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7b602afc-ef0f-5e76-8472-d716d59bc910', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('fa4cde9c-d493-590b-8635-ce87ac34736b', v_lesson, 'На прийомі в лікаря', 'Kod liječnika', 104, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ef55e488-fef0-51b8-9a0f-2ee0f151ebd7', 'fa4cde9c-d493-590b-8635-ce87ac34736b', 'Medicinska sestra', 'Dobar dan. Kako se zovete?', 'Добрий день. Як вас звати?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a49ddb3f-0a67-5cbf-87ac-652e4a506b3a', 'fa4cde9c-d493-590b-8635-ce87ac34736b', 'Oleg', 'Zovem se Oleg.', 'Мене звати Олег.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8ff5300a-bb56-5d23-a537-f8f80780fa73', 'fa4cde9c-d493-590b-8635-ce87ac34736b', 'Medicinska sestra', 'A Vaše prezime?', 'А ваше прізвище?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ad155ba9-320a-5408-b1e5-5a5ff1d4a27e', 'fa4cde9c-d493-590b-8635-ce87ac34736b', 'Oleg', 'Petrenko.', 'Петренко.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('94c7b379-4cbf-5b01-9022-26bf39b5f451', 'fa4cde9c-d493-590b-8635-ce87ac34736b', 'Medicinska sestra', 'Hvala, gospodine Petrenko. Izvolite sjesti.', 'Дякую, пане Петренко. Сідайте, будь ласка.', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', 'fa4cde9c-d493-590b-8635-ce87ac34736b', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 5: +5 слів, сцена «На каві з колегою», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '04167753-db83-5163-a91c-9f71dac18ab5';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 5 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '2da992d1-490f-533b-9ebd-fe8a717e9fe0') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('Hrvatska') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'Hrvatska'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('more') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'more'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('lijep') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'lijep'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('ali') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ali'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('daleko') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'daleko'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('Hrvatska') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('70841443-ae20-5b38-9b41-1c5b8f4b604a', 'multiple_choice', 'Що означає «Hrvatska»?', 'Хорватія', '["українець", "звідки ви", "море", "Хорватія"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '70841443-ae20-5b38-9b41-1c5b8f4b604a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ali') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c15ff805-a1ea-5cd8-9a92-9980755fdd26', 'multiple_choice', 'Що означає «ali»?', 'але', '["море", "звідки ви", "хорват", "але"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c15ff805-a1ea-5cd8-9a92-9980755fdd26', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('daleko') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9d3bf64b-d81b-5696-a982-20816e0da7be', 'multiple_choice', 'Як хорватською «далеко»?', 'daleko', '["lijep", "Hrvatska", "daleko", "ukrajinac"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9d3bf64b-d81b-5696-a982-20816e0da7be', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('lijep') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2725ceea-3911-53e8-9763-5fe173df5ef3', 'type_answer', 'Напишіть хорватською: «красивий»', 'lijep', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2725ceea-3911-53e8-9763-5fe173df5ef3', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('more') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b7270233-bef7-57a0-a89f-43906ee5e926', 'type_answer', 'Напишіть хорватською: «море»', 'more', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b7270233-bef7-57a0-a89f-43906ee5e926', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('655e0147-605c-5f13-97e3-eff9e9ccdeaa', 'sentence_builder', 'Складіть: «Загреб — гарне місто.»', 'Zagreb je lijep grad.', '["Zagreb", "grad.", "je", "lijep"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '655e0147-605c-5f13-97e3-eff9e9ccdeaa', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('bc58e110-b365-5279-b14c-86ae659fd301', 'listening', 'Прослухайте і складіть фразу', 'Da, ali more je daleko!', '["daleko!", "Da,", "more", "ali", "je"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'bc58e110-b365-5279-b14c-86ae659fd301', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2fe03648-90ed-55d4-8cd8-0ae56986cbb9', 'speaking', 'Я з України.', 'Ja sam iz Ukrajine.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2fe03648-90ed-55d4-8cd8-0ae56986cbb9', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('64572555-c4fa-560d-b6cd-23ae31288560', 'speaking', 'Я живу в Загребі.', 'Živim u Zagrebu.', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '64572555-c4fa-560d-b6cd-23ae31288560', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2da992d1-490f-533b-9ebd-fe8a717e9fe0', v_lesson, 'На каві з колегою', 'S kolegom na kavi', 105, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('34e30e4a-db92-58e5-8cd5-3d9d8fc1882e', '2da992d1-490f-533b-9ebd-fe8a717e9fe0', 'Marko', 'Odakle si?', 'Звідки ти?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b9f087d0-0500-579f-b194-3f5e05c48c29', '2da992d1-490f-533b-9ebd-fe8a717e9fe0', 'Iryna', 'Iz Ukrajine, iz Lavova. A ti?', 'З України, зі Львова. А ти?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('12424ac2-5ccb-5103-a0d0-026eaaf5412a', '2da992d1-490f-533b-9ebd-fe8a717e9fe0', 'Marko', 'Ja sam iz Splita, ali živim u Zagrebu.', 'Я зі Спліта, але живу в Загребі.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('74f8ba62-3438-58a5-87cd-71129c0a0cb6', '2da992d1-490f-533b-9ebd-fe8a717e9fe0', 'Iryna', 'Zagreb je lijep grad.', 'Загреб — гарне місто.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('12ea30f8-f34a-553a-97d5-10425f450586', '2da992d1-490f-533b-9ebd-fe8a717e9fe0', 'Marko', 'Da, ali more je daleko!', 'Так, але море далеко!', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '2da992d1-490f-533b-9ebd-fe8a717e9fe0', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 6: +5 слів, сцена «Співбесіда», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 6 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = 'edaf21dc-88bc-56a7-86a0-199568eeb017') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('medicinska sestra') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'medicinska sestra'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('iskustvo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'iskustvo'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('učiti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'učiti'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('hrvatski') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hrvatski'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('odlično') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'odlično'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('medicinska sestra') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0adeb541-355d-5a9c-b07d-57d0907512ca', 'multiple_choice', 'Що означає «medicinska sestra»?', 'медична сестра', '["робота / справа", "програміст", "досвід", "медична сестра"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0adeb541-355d-5a9c-b07d-57d0907512ca', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('odlično') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('22d79fcf-b540-50e8-b9ed-31a9db07cb6e', 'multiple_choice', 'Що означає «odlično»?', 'відмінно', '["школа", "досвід", "відмінно", "медична сестра"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '22d79fcf-b540-50e8-b9ed-31a9db07cb6e', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('hrvatski') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('15b99b8c-be04-523f-98b5-4bf41022d86a', 'multiple_choice', 'Як хорватською «хорватська (мова)»?', 'hrvatski', '["raditi", "profesor", "zanimanje", "hrvatski"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '15b99b8c-be04-523f-98b5-4bf41022d86a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('iskustvo') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e8e6bfd9-611d-5789-a490-f4017fa4e0c1', 'type_answer', 'Напишіть хорватською: «досвід»', 'iskustvo', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e8e6bfd9-611d-5789-a490-f4017fa4e0c1', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('učiti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b14246e3-24fe-5bac-842a-80ba0cfcd6bd', 'type_answer', 'Напишіть хорватською: «вчити (ся)»', 'učiti', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b14246e3-24fe-5bac-842a-80ba0cfcd6bd', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d87b2dc7-2969-5edb-8f0d-70353d223109', 'sentence_builder', 'Складіть: «Я медсестра.»', 'Ja sam medicinska sestra.', '["sam", "medicinska", "Ja", "sestra."]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd87b2dc7-2969-5edb-8f0d-70353d223109', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('672c0272-0dca-50ae-95a7-52b8d08ccad0', 'listening', 'Прослухайте і складіть фразу', 'Malo. Učim hrvatski.', '["hrvatski.", "Učim", "Malo."]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '672c0272-0dca-50ae-95a7-52b8d08ccad0', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2d90a6b8-dac1-542d-a6b6-737d3bf68d31', 'speaking', 'Я програміст.', 'Ja sam programer.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2d90a6b8-dac1-542d-a6b6-737d3bf68d31', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9a415f6e-9925-5814-bbc0-f81e0c7357ce', 'speaking', 'Я вчу хорватську.', 'Učim hrvatski.', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9a415f6e-9925-5814-bbc0-f81e0c7357ce', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('edaf21dc-88bc-56a7-86a0-199568eeb017', v_lesson, 'Співбесіда', 'Razgovor za posao', 106, 'A0', 'work', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6dc38601-2e6a-5470-91cc-105638dfbcc7', 'edaf21dc-88bc-56a7-86a0-199568eeb017', 'Direktorica', 'Dobar dan. Što ste po zanimanju?', 'Добрий день. Хто ви за фахом?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3f2e4046-6b12-518f-9ea3-058d7daac1b4', 'edaf21dc-88bc-56a7-86a0-199568eeb017', 'Oksana', 'Ja sam medicinska sestra.', 'Я медсестра.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4a87929d-8e11-5646-905a-8c13fe751997', 'edaf21dc-88bc-56a7-86a0-199568eeb017', 'Direktorica', 'Imate li iskustva?', 'У вас є досвід?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('aae62270-9a73-502f-a9f0-314e6c04521e', 'edaf21dc-88bc-56a7-86a0-199568eeb017', 'Oksana', 'Da, pet godina.', 'Так, п’ять років.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2a2285c1-90ad-5345-bfe8-b7c4dea2f766', 'edaf21dc-88bc-56a7-86a0-199568eeb017', 'Direktorica', 'Odlično. Govorite li hrvatski?', 'Чудово. Ви говорите хорватською?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a5f74af6-3f86-5f0e-a752-33ee943f9bc9', 'edaf21dc-88bc-56a7-86a0-199568eeb017', 'Oksana', 'Malo. Učim hrvatski.', 'Трохи. Я вчу хорватську.', 6) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', 'edaf21dc-88bc-56a7-86a0-199568eeb017', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 7: +0 слів, сцена «Доставка», 9 нових вправ
do $$
declare
  v_lesson constant uuid := 'c0941bd8-57b5-5e7e-981f-9be423f24208';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 7 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '526aa893-1577-58df-8664-9abee2809547') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('dva') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8f760ea0-4eb7-551e-a850-ffc73c21e869', 'multiple_choice', 'Що означає «dva»?', 'два', '["вісім", "два", "один", "шість"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8f760ea0-4eb7-551e-a850-ffc73c21e869', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('broj') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('88e6c101-d072-5d27-b128-c3bbb20529d5', 'multiple_choice', 'Що означає «broj»?', 'номер / число', '["сім", "номер / число", "дев''ять", "чотири"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '88e6c101-d072-5d27-b128-c3bbb20529d5', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tri') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('129f5779-57ff-541c-8a74-4dee6edff9eb', 'multiple_choice', 'Як хорватською «три»?', 'tri', '["dva", "deset", "tri", "nula"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '129f5779-57ff-541c-8a74-4dee6edff9eb', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('nula') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1e6a6229-262c-5e68-9371-f8af1eebaf93', 'type_answer', 'Напишіть хорватською: «нуль»', 'nula', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1e6a6229-262c-5e68-9371-f8af1eebaf93', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('pet') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('59af3fa8-631d-5bb2-a474-c78c87da5e42', 'type_answer', 'Напишіть хорватською: «п''ять»', 'pet', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '59af3fa8-631d-5bb2-a474-c78c87da5e42', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('44056e28-8148-5273-9183-d7eed6743024', 'sentence_builder', 'Складіть: «Квартира номер три.»', 'Stan broj tri.', '["Stan", "tri.", "broj"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '44056e28-8148-5273-9183-d7eed6743024', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('054fbc27-f064-5f7e-b7a2-8c9edb632450', 'listening', 'Прослухайте і складіть фразу', 'Stižem za pet minuta.', '["Stižem", "pet", "za", "minuta."]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '054fbc27-f064-5f7e-b7a2-8c9edb632450', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('71944ea8-1bca-57a8-9880-6d893bce3b44', 'speaking', 'Повтори, будь ласка.', 'Ponovi, molim te.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '71944ea8-1bca-57a8-9880-6d893bce3b44', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a93ffad4-b69d-5d1c-833c-53ccd660061d', 'speaking', 'Номер сім.', 'Broj sedam.', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a93ffad4-b69d-5d1c-833c-53ccd660061d', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('526aa893-1577-58df-8664-9abee2809547', v_lesson, 'Доставка', 'Dostava', 107, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('61bc4b54-afc4-5d5b-8b85-9d64619cb2fd', '526aa893-1577-58df-8664-9abee2809547', 'Dostavljač', 'Dobar dan! Koji je Vaš kućni broj?', 'Добрий день! Який номер вашого будинку?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8e83a0af-3895-5774-b4f3-2723a1d21928', '526aa893-1577-58df-8664-9abee2809547', 'Ana', 'Broj sedam.', 'Номер сім.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('eb5d0ab6-3e40-57d3-a9ba-bda5f003b7dd', '526aa893-1577-58df-8664-9abee2809547', 'Dostavljač', 'A stan?', 'А квартира?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('702bf40a-c4af-522d-893e-f837697aa615', '526aa893-1577-58df-8664-9abee2809547', 'Ana', 'Stan broj tri, na drugom katu.', 'Квартира номер три, на другому поверсі.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f0c0241d-e2fc-5a77-a664-f352dad923ec', '526aa893-1577-58df-8664-9abee2809547', 'Dostavljač', 'Hvala! Stižem za pet minuta.', 'Дякую! Буду за п’ять хвилин.', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '526aa893-1577-58df-8664-9abee2809547', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 8: +5 слів, сцена «У парку», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '4c5db9c0-aa58-55c5-b647-7f7cfc8396c2';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 8 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '38ec612a-d1ac-5d95-8261-ca97eebbc9b6') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('pas') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pas'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('star') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'star'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('dvadeset') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dvadeset'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('četrdeset') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'četrdeset'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('pedeset') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pedeset'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('star') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1a74c3f2-a2cf-52df-977f-68a759a3f890', 'multiple_choice', 'Що означає «star»?', 'старий', '["тридцять", "собака", "старий", "скільки вам років"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1a74c3f2-a2cf-52df-977f-68a759a3f890', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pedeset') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f8c96c0c-795d-5d6e-bef7-9f4d480c04b1', 'multiple_choice', 'Що означає «pedeset»?', 'п''ятдесят', '["двадцять", "п''ятдесят", "мати", "тридцять"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f8c96c0c-795d-5d6e-bef7-9f4d480c04b1', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pas') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('46f3e81f-6afe-5bb6-b029-478c376fafcd', 'multiple_choice', 'Як хорватською «собака»?', 'pas', '["trideset", "koliko godina imate", "dvadeset", "pas"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '46f3e81f-6afe-5bb6-b029-478c376fafcd', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dvadeset') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1d8efa71-792c-5e87-bfe3-622ca8e8becd', 'type_answer', 'Напишіть хорватською: «двадцять»', 'dvadeset', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1d8efa71-792c-5e87-bfe3-622ca8e8becd', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('četrdeset') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4a3bd1f6-b3b9-5000-a4ed-3704bc93df74', 'type_answer', 'Напишіть хорватською: «сорок»', 'četrdeset', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4a3bd1f6-b3b9-5000-a4ed-3704bc93df74', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d49693c6-0be3-5d2f-af21-a7f8bf7b6a78', 'sentence_builder', 'Складіть: «Скільки тобі років?»', 'Koliko imaš godina?', '["Koliko", "godina?", "imaš"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd49693c6-0be3-5d2f-af21-a7f8bf7b6a78', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f0550262-f062-5086-be6b-2bb5cac0c556', 'listening', 'Прослухайте і складіть фразу', 'Ovo je moj pas.', '["pas.", "je", "Ovo", "moj"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f0550262-f062-5086-be6b-2bb5cac0c556', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0b026d51-88ef-55d5-96b8-553dcc143540', 'speaking', 'Мені тридцять п’ять років.', 'Imam trideset pet godina.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0b026d51-88ef-55d5-96b8-553dcc143540', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f2afd69d-ea45-5ba4-be95-5b5604e5e4a2', 'speaking', 'Скільки тобі років?', 'Koliko imaš godina?', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f2afd69d-ea45-5ba4-be95-5b5604e5e4a2', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('38ec612a-d1ac-5d95-8261-ca97eebbc9b6', v_lesson, 'У парку', 'U parku', 108, 'A0', 'health', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('baeac247-491e-5eb2-a1b1-d7890a7937f3', '38ec612a-d1ac-5d95-8261-ca97eebbc9b6', 'Luka', 'Koliko imaš godina?', 'Скільки тобі років?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4df35f7f-c0a3-56d8-8cbe-7898c86684fe', '38ec612a-d1ac-5d95-8261-ca97eebbc9b6', 'Sofija', 'Imam šest godina. A ti?', 'Мені шість років. А тобі?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3277b0e0-5012-527a-a109-9425ea7898ec', '38ec612a-d1ac-5d95-8261-ca97eebbc9b6', 'Luka', 'Ja imam sedam. Ovo je moj pas.', 'Мені сім. Це мій пес.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0fa1e9c3-b514-5c6e-933d-935d856d69c7', '38ec612a-d1ac-5d95-8261-ca97eebbc9b6', 'Sofija', 'Koliko godina ima pas?', 'Скільки років собаці?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d4fdaf45-cb91-5ef7-8792-4ed21fd4fa88', '38ec612a-d1ac-5d95-8261-ca97eebbc9b6', 'Luka', 'Dvije.', 'Два.', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '38ec612a-d1ac-5d95-8261-ca97eebbc9b6', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 9: +4 слів, сцена «У пекарні», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '427e5058-7381-58a0-8f21-bd170866dbae';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 9 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '2787ce09-9207-5532-ac24-fe6aad91b65a') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('kruh') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kruh'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('pekara') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pekara'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('skupo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'skupo'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('jeftino') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jeftino'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('pekara') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9c1f57d2-a7ce-5616-a5a1-c2b30d162fc9', 'multiple_choice', 'Що означає «pekara»?', 'пекарня', '["дорого", "пекарня", "сік", "хліб"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9c1f57d2-a7ce-5616-a5a1-c2b30d162fc9', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jeftino') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('acd9644a-1f79-5b0b-af9c-17d0e2f8b0ca', 'multiple_choice', 'Що означає «jeftino»?', 'дешево', '["ціна", "кава", "коштувати", "дешево"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'acd9644a-1f79-5b0b-af9c-17d0e2f8b0ca', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('skupo') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6360fa27-d90c-5eeb-b2a2-e93c40c282c9', 'multiple_choice', 'Як хорватською «дорого»?', 'skupo', '["cijena", "sok", "euro", "skupo"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6360fa27-d90c-5eeb-b2a2-e93c40c282c9', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kruh') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0cabde4d-0a55-59cf-b2bb-2df143cd4759', 'type_answer', 'Напишіть хорватською: «хліб»', 'kruh', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0cabde4d-0a55-59cf-b2bb-2df143cd4759', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('cent') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2563fcf8-d224-58cb-ade2-35eaa307240f', 'type_answer', 'Напишіть хорватською: «цент»', 'cent', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2563fcf8-d224-58cb-ade2-35eaa307240f', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ec38dfd4-84d4-521e-a73b-7983c58f4267', 'sentence_builder', 'Складіть: «Ні, дякую. Скільки з мене?»', 'Ne, hvala. Koliko je to?', '["Ne,", "hvala.", "to?", "je", "Koliko"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ec38dfd4-84d4-521e-a73b-7983c58f4267', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('effb3882-41df-5099-9ca8-42d51384268b', 'listening', 'Прослухайте і складіть фразу', 'Četiri eura i dvadeset centi.', '["Četiri", "dvadeset", "eura", "i", "centi."]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'effb3882-41df-5099-9ca8-42d51384268b', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('66f331bc-7189-5c25-a8d8-1b345830e20e', 'speaking', 'Скільки це коштує?', 'Koliko to košta?', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '66f331bc-7189-5c25-a8d8-1b345830e20e', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1b8fe705-1c05-5c64-87e4-89722724e50c', 'speaking', 'Один хліб, будь ласка.', 'Jedan kruh, molim.', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1b8fe705-1c05-5c64-87e4-89722724e50c', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2787ce09-9207-5532-ac24-fe6aad91b65a', v_lesson, 'У пекарні', 'U pekari', 109, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('12892461-c409-515c-a6a2-150a3f5b4175', '2787ce09-9207-5532-ac24-fe6aad91b65a', 'Prodavačica', 'Dobro jutro! Izvolite?', 'Доброго ранку! Що бажаєте?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b91824dc-bb96-5c82-aa2d-e5b48f1a3d1d', '2787ce09-9207-5532-ac24-fe6aad91b65a', 'Kupac', 'Jedan kruh i dva kroasana, molim.', 'Одну хлібину й два круасани, будь ласка.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b27acc70-ea37-535c-b4ab-fd55a2a1fbdd', '2787ce09-9207-5532-ac24-fe6aad91b65a', 'Prodavačica', 'Još nešto?', 'Ще щось?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6174bd9c-248a-5013-a8fa-f36211ed1547', '2787ce09-9207-5532-ac24-fe6aad91b65a', 'Kupac', 'Ne, hvala. Koliko je to?', 'Ні, дякую. Скільки з мене?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cfa7334e-be7a-5baa-ac7f-1732c2c4646f', '2787ce09-9207-5532-ac24-fe6aad91b65a', 'Prodavačica', 'Četiri eura i dvadeset centi.', 'Чотири євро двадцять центів.', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '2787ce09-9207-5532-ac24-fe6aad91b65a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 10: +2 слів, сцена «Запис до перукаря», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '8e372ece-ae10-50ae-9cf3-07b52ef2f72d';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 10 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = 'baa5ea0d-ef2f-590b-baaf-cfe84e8e729e') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('termin') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'termin'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('u redu') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'u redu'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('u redu') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a3136632-b46a-5bcb-9987-cf1c7db627bc', 'multiple_choice', 'Що означає «u redu»?', 'гаразд; добре', '["гаразд; добре", "середа", "понеділок", "четвер"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a3136632-b46a-5bcb-9987-cf1c7db627bc', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('termin') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4600c132-9009-546c-9198-ed40ab47bc62', 'multiple_choice', 'Що означає «termin»?', '(вільний) час; запис (до лікаря, перукаря)', '["вівторок", "четвер", "завтра", "(вільний) час; запис (до лікаря, перукаря)"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4600c132-9009-546c-9198-ed40ab47bc62', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('koji je danas dan') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f9ba2b9d-04af-565b-82f5-916eb035f575', 'multiple_choice', 'Як хорватською «який сьогодні день»?', 'koji je danas dan', '["sutra", "termin", "koji je danas dan", "srijeda"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f9ba2b9d-04af-565b-82f5-916eb035f575', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('nedjelja') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9b86bb62-b0d2-5198-866c-ba08ba9c4993', 'type_answer', 'Напишіть хорватською: «неділя»', 'nedjelja', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9b86bb62-b0d2-5198-866c-ba08ba9c4993', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('petak') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a93c29fc-d3b4-5e3e-a4ff-6c53bf7df3b6', 'type_answer', 'Напишіть хорватською: «п''ятниця»', 'petak', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a93c29fc-d3b4-5e3e-a4ff-6c53bf7df3b6', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9db5df01-9a5f-53e5-afaa-7d1f6a90d674', 'sentence_builder', 'Складіть: «Добре, побачимося в п’ятницю.»', 'U redu, vidimo se u petak.', '["u", "redu,", "se", "petak.", "U", "vidimo"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9db5df01-9a5f-53e5-afaa-7d1f6a90d674', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fd8ff439-be71-566f-96bb-a24ec5e8338d', 'listening', 'Прослухайте і складіть фразу', 'Petak je dobro.', '["Petak", "dobro.", "je"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fd8ff439-be71-566f-96bb-a24ec5e8338d', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('06009a1a-aee0-5dae-985f-d08f7f3ee7cd', 'speaking', 'Сьогодні середа.', 'Danas je srijeda.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '06009a1a-aee0-5dae-985f-d08f7f3ee7cd', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fc3ed1c5-86ad-5d2d-b5a2-e35eafa4d78f', 'speaking', 'Побачимося в п’ятницю!', 'Vidimo se u petak!', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fc3ed1c5-86ad-5d2d-b5a2-e35eafa4d78f', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('baa5ea0d-ef2f-590b-baaf-cfe84e8e729e', v_lesson, 'Запис до перукаря', 'Kod frizera', 110, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1737b62c-95cd-5de7-aa57-a96de8980609', 'baa5ea0d-ef2f-590b-baaf-cfe84e8e729e', 'Frizerka', 'Frizerski salon, izvolite.', 'Перукарня, слухаю.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5a4bd8d1-33db-5ab2-ae39-d27c5ac59047', 'baa5ea0d-ef2f-590b-baaf-cfe84e8e729e', 'Marta', 'Dobar dan. Imate li slobodan termin u četvrtak?', 'Добрий день. У вас є вільний час у четвер?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('76bf6ce6-684b-560e-8b10-edf6abe950af', 'baa5ea0d-ef2f-590b-baaf-cfe84e8e729e', 'Frizerka', 'U četvrtak ne, ali u petak da.', 'У четвер ні, а в п’ятницю так.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cae11439-20e8-5fc4-9221-154fab21dce4', 'baa5ea0d-ef2f-590b-baaf-cfe84e8e729e', 'Marta', 'Petak je dobro. Hvala!', 'П’ятниця підходить. Дякую!', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('90dbc192-f333-54fa-a079-940d1fddcf67', 'baa5ea0d-ef2f-590b-baaf-cfe84e8e729e', 'Frizerka', 'U redu, vidimo se u petak.', 'Добре, побачимося в п’ятницю.', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', 'baa5ea0d-ef2f-590b-baaf-cfe84e8e729e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 11: +4 слів, сцена «Вранці вдома», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '39b1e31f-b573-5000-9713-1660688c3cc9';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 11 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '4add83ed-b73e-52ac-8b96-69369318cc16') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('jutro') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jutro'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('vrijeme') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vrijeme'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('škola') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'škola'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('noć') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'noć'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('noć') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9a4d7f72-f132-5cbc-89c4-7f8a3050583b', 'multiple_choice', 'Що означає «noć»?', 'ніч', '["автобус", "рано", "школа", "ніч"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9a4d7f72-f132-5cbc-89c4-7f8a3050583b', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vrijeme') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('75e966ec-12e4-5220-8593-15fbab9a5283', 'multiple_choice', 'Що означає «vrijeme»?', 'погода / час', '["котра година", "ніч", "погода / час", "автобус"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '75e966ec-12e4-5220-8593-15fbab9a5283', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jutro') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('40c15e2a-6e2a-595c-8ca7-f23302149056', 'multiple_choice', 'Як хорватською «ранок»?', 'jutro', '["jutro", "sat", "noć", "kasno"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '40c15e2a-6e2a-595c-8ca7-f23302149056', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('škola') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('db942126-ed92-5277-9a13-882760c3ee8b', 'type_answer', 'Напишіть хорватською: «школа»', 'škola', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'db942126-ed92-5277-9a13-882760c3ee8b', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('autobus') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('802a2fd7-eebd-5994-b103-758eaa3558bd', 'type_answer', 'Напишіть хорватською: «автобус»', 'autobus', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '802a2fd7-eebd-5994-b103-758eaa3558bd', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('131a669d-2dcf-5484-bf13-3378f44b267a', 'sentence_builder', 'Складіть: «Школа починається о восьмій.»', 'Škola počinje u osam.', '["Škola", "osam.", "u", "počinje"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '131a669d-2dcf-5484-bf13-3378f44b267a', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('dabf3ab2-a695-5065-85a5-087992eb410b', 'listening', 'Прослухайте і складіть фразу', 'Ustani, kasno je!', '["je!", "Ustani,", "kasno"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'dabf3ab2-a695-5065-85a5-087992eb410b', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8f9676bd-02b7-5edd-afba-c56d26734332', 'speaking', 'Котра година?', 'Koliko je sati?', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8f9676bd-02b7-5edd-afba-c56d26734332', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9cbda869-b4a4-52b6-b12e-110ab9bd96eb', 'speaking', 'Об одинадцятій.', 'U jedanaest sati.', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9cbda869-b4a4-52b6-b12e-110ab9bd96eb', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4add83ed-b73e-52ac-8b96-69369318cc16', v_lesson, 'Вранці вдома', 'Ujutro kod kuće', 111, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e327b4f0-8371-5ca4-9e2e-8b3a75fd353a', '4add83ed-b73e-52ac-8b96-69369318cc16', 'Mama', 'Ustani, kasno je!', 'Вставай, уже пізно!', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c9ea97e4-4fc7-5dca-9b45-4ce7426da123', '4add83ed-b73e-52ac-8b96-69369318cc16', 'Dino', 'Koliko je sati?', 'Котра година?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8a107608-81d0-5e1c-a459-6769bc3eb846', '4add83ed-b73e-52ac-8b96-69369318cc16', 'Mama', 'Sedam i pol.', 'Пів на восьму.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('063fde02-acfa-588f-867e-13ae3306eab6', '4add83ed-b73e-52ac-8b96-69369318cc16', 'Dino', 'Škola počinje u osam. Imam vremena!', 'Школа починається о восьмій. У мене є час!', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a50e50dd-2012-5ff2-8a85-ac2c6c7128ba', '4add83ed-b73e-52ac-8b96-69369318cc16', 'Mama', 'Nemaš! Autobus ide u sedam i četrdeset.', 'Немає! Автобус їде о сьомій сорок.', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '4add83ed-b73e-52ac-8b96-69369318cc16', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 12: +4 слів, сцена «Плани на відпустку», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '036fc4fb-1bf2-5100-9fd0-6f6a612554a1';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 12 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '5e084920-548d-51ba-aef8-73a8933e80bb') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('kolovoz') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kolovoz'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('rujan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rujan'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('vruće') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vruće'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('godišnji odmor') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'godišnji odmor'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('godišnji odmor') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('94149370-dd58-5c64-af92-473926b47519', 'multiple_choice', 'Що означає «godišnji odmor»?', 'щорічна відпустка', '["осінь", "любити, подобатися", "день народження", "щорічна відпустка"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '94149370-dd58-5c64-af92-473926b47519', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vruće') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5e8e4a71-3df6-5ba7-94b5-f57b9ac46fb9', 'multiple_choice', 'Що означає «vruće»?', 'гаряче; спекотно', '["вересень", "гаряче; спекотно", "любити, подобатися", "липень"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5e8e4a71-3df6-5ba7-94b5-f57b9ac46fb9', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kolovoz') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f287c3e7-8b26-5b9b-9a73-95f51282a206', 'multiple_choice', 'Як хорватською «серпень»?', 'kolovoz', '["proljeće", "kolovoz", "jesen", "voljeti"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f287c3e7-8b26-5b9b-9a73-95f51282a206', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rujan') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1f7edc18-060e-5ccd-b252-bc39482cbeef', 'type_answer', 'Напишіть хорватською: «вересень»', 'rujan', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1f7edc18-060e-5ccd-b252-bc39482cbeef', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('ljeto') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('455d879a-ddc2-5c39-ad23-1b061d640cc6', 'type_answer', 'Напишіть хорватською: «літо»', 'ljeto', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '455d879a-ddc2-5c39-ad23-1b061d640cc6', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e2964f8e-4f42-533f-bcb5-d370b0a965e1', 'sentence_builder', 'Складіть: «У серпні. Їду на море.»', 'U kolovozu. Idem na more.', '["U", "more.", "Idem", "kolovozu.", "na"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e2964f8e-4f42-533f-bcb5-d370b0a965e1', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6417af8c-eabe-587a-85ca-7dd0c089bf82', 'listening', 'Прослухайте і складіть фразу', 'Tada nije tako vruće.', '["vruće.", "tako", "nije", "Tada"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6417af8c-eabe-587a-85ca-7dd0c089bf82', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('95bddd0b-dfd0-52a1-a5db-15dce495e5ea', 'speaking', 'Я люблю літо.', 'Volim ljeto.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '95bddd0b-dfd0-52a1-a5db-15dce495e5ea', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a12d02af-b982-5870-8456-7ac008fa2d3a', 'speaking', 'Мій день народження в липні.', 'Rođendan mi je u srpnju.', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a12d02af-b982-5870-8456-7ac008fa2d3a', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5e084920-548d-51ba-aef8-73a8933e80bb', v_lesson, 'Плани на відпустку', 'Planovi za godišnji', 112, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('40a52f6b-b59a-54d2-9c00-234c76583ac1', '5e084920-548d-51ba-aef8-73a8933e80bb', 'Ana', 'Kada ideš na godišnji odmor?', 'Коли ти йдеш у відпустку?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8a8b1e82-882d-51ab-991a-e6d065568379', '5e084920-548d-51ba-aef8-73a8933e80bb', 'Ivan', 'U kolovozu. Idem na more.', 'У серпні. Їду на море.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('dddc39f4-a305-5a5d-a18b-fd21f6a4b2e9', '5e084920-548d-51ba-aef8-73a8933e80bb', 'Ana', 'Ja idem u rujnu. Tada nije tako vruće.', 'Я йду у вересні. Тоді не так спекотно.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8fc7360f-315a-5d97-999c-481f246e1748', '5e084920-548d-51ba-aef8-73a8933e80bb', 'Ivan', 'Imaš pravo.', 'Ти маєш рацію.', 4) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '5e084920-548d-51ba-aef8-73a8933e80bb', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 13: +5 слів, сцена «Фото на телефоні», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '4e003796-1ce0-5a02-8a2d-59a0de38f3dd';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 13 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '20b9e485-2571-528f-97ec-a2056f2f1214') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('mama') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'mama'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('tata') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tata'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('baka') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'baka'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('djed') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'djed'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('selo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'selo'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('tata') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fcfff384-0bf2-5409-a933-79d6fc3fb337', 'multiple_choice', 'Що означає «tata»?', 'тато', '["бабуся", "тато", "мати", "дідусь"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fcfff384-0bf2-5409-a933-79d6fc3fb337', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('djed') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c0593632-970f-5706-ab58-fae206610880', 'multiple_choice', 'Що означає «djed»?', 'дідусь', '["батьки", "дідусь", "батько", "брат"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c0593632-970f-5706-ab58-fae206610880', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('baka') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8451ed7c-d797-5533-9583-7665de4812f0', 'multiple_choice', 'Як хорватською «бабуся»?', 'baka', '["mama", "roditelji", "baka", "djed"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8451ed7c-d797-5533-9583-7665de4812f0', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('mama') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0e4d56db-d12f-522a-a22c-d7ea081d8cfd', 'type_answer', 'Напишіть хорватською: «мама»', 'mama', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0e4d56db-d12f-522a-a22c-d7ea081d8cfd', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('selo') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e34c58e2-05c4-54a7-8055-cc1031aed854', 'type_answer', 'Напишіть хорватською: «село»', 'selo', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e34c58e2-05c4-54a7-8055-cc1031aed854', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6d73ebbb-2fa3-5dae-afc9-cfb7af169c22', 'sentence_builder', 'Складіть: «Бабуся й дідусь живуть у селі.»', 'Baka i djed žive na selu.', '["selu.", "i", "Baka", "na", "žive", "djed"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6d73ebbb-2fa3-5dae-afc9-cfb7af169c22', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('18a78fb8-651e-5183-81a6-e718443e6b88', 'listening', 'Прослухайте і складіть фразу', 'Je li ovo tvoja mama?', '["tvoja", "ovo", "Je", "li", "mama?"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '18a78fb8-651e-5183-81a6-e718443e6b88', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fdd430d0-735f-5b5f-9b1b-04d810db2014', 'speaking', 'Це моя родина.', 'Ovo je moja obitelj.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fdd430d0-735f-5b5f-9b1b-04d810db2014', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ff505938-b7a0-5f50-a1c9-f2e48f759b7d', 'speaking', 'Хто це?', 'Tko je to?', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ff505938-b7a0-5f50-a1c9-f2e48f759b7d', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('20b9e485-2571-528f-97ec-a2056f2f1214', v_lesson, 'Фото на телефоні', 'Slika na mobitelu', 113, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3f2caef6-016d-5b3f-a0bb-9cb8951eff1e', '20b9e485-2571-528f-97ec-a2056f2f1214', 'Maja', 'Je li ovo tvoja mama?', 'Це твоя мама?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c3417b23-43f7-50c5-88ec-d8884598ddc3', '20b9e485-2571-528f-97ec-a2056f2f1214', 'Oleg', 'Da, to je moja mama, a ovo je moj tata.', 'Так, це моя мама, а це мій тато.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6e67e465-9b6d-5ba7-b68e-bb24b6703cc5', '20b9e485-2571-528f-97ec-a2056f2f1214', 'Maja', 'Gdje žive?', 'Де вони живуть?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e481362f-e2af-537c-ac6e-e29bece08209', '20b9e485-2571-528f-97ec-a2056f2f1214', 'Oleg', 'U Kijevu. Baka i djed žive na selu.', 'У Києві. Бабуся й дідусь живуть у селі.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5c3ef0cb-60ee-56fa-bb6f-9670dd997330', '20b9e485-2571-528f-97ec-a2056f2f1214', 'Maja', 'Lijepa obitelj!', 'Гарна родина!', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '20b9e485-2571-528f-97ec-a2056f2f1214', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 14: +4 слів, сцена «На дні народження», 9 нових вправ
do $$
declare
  v_lesson constant uuid := 'f9ca38e4-3a61-56a6-b5f5-060933516c9a';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 14 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '6974e7bb-3930-5cc1-b03d-d42dbc9dc3ab') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('djeca') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'djeca'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('sin') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sin'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('drago mi je') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'drago mi je'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('koliko') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'koliko'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('koliko') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3919d28e-98ab-5167-9c9a-34502974cabe', 'multiple_choice', 'Що означає «koliko»?', 'скільки', '["син", "жінка, дружина", "брат", "скільки"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3919d28e-98ab-5167-9c9a-34502974cabe', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('djeca') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('492a52fc-8675-5c82-8167-c245b6f3bd6e', 'multiple_choice', 'Що означає «djeca»?', 'діти', '["брат", "діти", "син", "дуже приємно"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '492a52fc-8675-5c82-8167-c245b6f3bd6e', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('drago mi je') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('09e79e5f-6afe-5327-9c50-567e67f6a219', 'multiple_choice', 'Як хорватською «дуже приємно»?', 'drago mi je', '["koliko", "sestra", "brat", "drago mi je"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '09e79e5f-6afe-5327-9c50-567e67f6a219', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sin') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9cb2e95a-0600-5544-b67c-96f507b331da', 'type_answer', 'Напишіть хорватською: «син»', 'sin', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9cb2e95a-0600-5544-b67c-96f507b331da', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('sestra') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('74e7f62c-1bde-5cb6-b1b1-2093a90bff3c', 'type_answer', 'Напишіть хорватською: «сестра»', 'sestra', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '74e7f62c-1bde-5cb6-b1b1-2093a90bff3c', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6a1657f3-8f1c-54ed-bff9-0a7d76a62cc0', 'sentence_builder', 'Складіть: «У нас один син.»', 'Imamo jednog sina.', '["jednog", "sina.", "Imamo"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6a1657f3-8f1c-54ed-bff9-0a7d76a62cc0', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f03dbec0-c05b-50f2-8180-eeb7860a0c85', 'listening', 'Прослухайте і складіть фразу', 'Ovo je moja žena Olga.', '["je", "Olga.", "žena", "Ovo", "moja"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f03dbec0-c05b-50f2-8180-eeb7860a0c85', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6589ad25-9ef4-5861-993f-270043312ae1', 'speaking', 'У мене одна сестра.', 'Imam jednu sestru.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6589ad25-9ef4-5861-993f-270043312ae1', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c5b0c06c-b440-5663-abf6-f39165754cbf', 'speaking', 'У вас є діти?', 'Imate li djecu?', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c5b0c06c-b440-5663-abf6-f39165754cbf', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6974e7bb-3930-5cc1-b03d-d42dbc9dc3ab', v_lesson, 'На дні народження', 'Na rođendanu', 114, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('eb6d4911-b205-5a6e-a1ca-9e07e69947c1', '6974e7bb-3930-5cc1-b03d-d42dbc9dc3ab', 'Petra', 'Tko je ovo?', 'Хто це?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a82dde68-c3fa-5f86-a1f4-c52bbc7dfdc4', '6974e7bb-3930-5cc1-b03d-d42dbc9dc3ab', 'Andrij', 'Ovo je moja žena Olga.', 'Це моя дружина Ольга.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7947b5c9-31bb-5968-a97a-44716026fda6', '6974e7bb-3930-5cc1-b03d-d42dbc9dc3ab', 'Petra', 'Drago mi je! Imate li djecu?', 'Приємно познайомитися! У вас є діти?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0020a989-a16c-56e5-8376-f9b68a7a6d81', '6974e7bb-3930-5cc1-b03d-d42dbc9dc3ab', 'Olga', 'Imamo jednog sina. Zove se Maksim.', 'У нас один син. Його звати Максим.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d7c18899-1c48-5b91-9a03-e1e41bdf3290', '6974e7bb-3930-5cc1-b03d-d42dbc9dc3ab', 'Petra', 'Koliko ima godina?', 'Скільки йому років?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('52c03d77-9d63-5492-aaf0-9d44e8812349', '6974e7bb-3930-5cc1-b03d-d42dbc9dc3ab', 'Olga', 'Četiri.', 'Чотири.', 6) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '6974e7bb-3930-5cc1-b03d-d42dbc9dc3ab', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 15: +4 слів, сцена «Після школи», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '2b0e9742-99e1-57e1-a574-67ffb78d2607';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 15 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '943cfda6-4a02-5814-b219-357f7b5f5f3e') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('prijateljica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prijateljica'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('učitelj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'učitelj'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('igrati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'igrati'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('škola') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'škola'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('učitelj') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ebaa623b-04c0-5363-95cb-0605c02834bb', 'multiple_choice', 'Що означає «učitelj»?', 'вчитель', '["вчитель", "дитина", "дівчинка", "хлопчик"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ebaa623b-04c0-5363-95cb-0605c02834bb', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('igrati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f14b1db4-c81e-5a2b-b3bb-51ef322bfdd3', 'multiple_choice', 'Що означає «igrati»?', 'грати', '["друг", "дитина", "грати", "син"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f14b1db4-c81e-5a2b-b3bb-51ef322bfdd3', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prijateljica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0f2c37a9-8203-5552-8f8e-aa2505209336', 'multiple_choice', 'Як хорватською «подруга»?', 'prijateljica', '["igrati", "prijatelj", "dječak", "prijateljica"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0f2c37a9-8203-5552-8f8e-aa2505209336', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('škola') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4d37eae0-323e-5ab2-ade7-eb6084403683', 'type_answer', 'Напишіть хорватською: «школа»', 'škola', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4d37eae0-323e-5ab2-ade7-eb6084403683', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('prijatelj') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d7cce401-15ed-5fb1-9bfb-c6972cc932d5', 'type_answer', 'Напишіть хорватською: «друг»', 'prijatelj', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd7cce401-15ed-5fb1-9bfb-c6972cc932d5', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a44b4524-bfc0-5262-a98c-fbcfc0534174', 'sentence_builder', 'Складіть: «У мене новий друг.»', 'Imam novog prijatelja.', '["novog", "prijatelja.", "Imam"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a44b4524-bfc0-5262-a98c-fbcfc0534174', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b8a002b2-da69-56b5-852d-ff9c643db6fb', 'listening', 'Прослухайте і складіть фразу', 'Kako je bilo u školi?', '["je", "u", "Kako", "školi?", "bilo"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b8a002b2-da69-56b5-852d-ff9c643db6fb', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d0b97b7d-ff0b-5a97-a955-0ea263f9dd98', 'speaking', 'У мене син і донька.', 'Imam sina i kćer.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd0b97b7d-ff0b-5a97-a955-0ea263f9dd98', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ef5a57be-d6e1-5268-94f5-e3de99be5448', 'speaking', 'Як його звати?', 'Kako se zove?', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ef5a57be-d6e1-5268-94f5-e3de99be5448', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('943cfda6-4a02-5814-b219-357f7b5f5f3e', v_lesson, 'Після школи', 'Poslije škole', 115, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ba18c605-400b-59b2-a4d4-048fee5d0fb2', '943cfda6-4a02-5814-b219-357f7b5f5f3e', 'Teta', 'Kako je bilo u školi?', 'Як було в школі?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4ec3f009-fede-5f06-bad8-a15b4bddf50b', '943cfda6-4a02-5814-b219-357f7b5f5f3e', 'Tin', 'Dobro! Imam novog prijatelja.', 'Добре! У мене новий друг.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('78a23d7a-5709-5339-b202-5fc6c87347c0', '943cfda6-4a02-5814-b219-357f7b5f5f3e', 'Teta', 'Kako se zove?', 'Як його звати?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('bd59f5e3-d932-58d7-8b63-fe616fd20e92', '943cfda6-4a02-5814-b219-357f7b5f5f3e', 'Tin', 'Zove se Bohdan. On je iz Ukrajine.', 'Його звати Богдан. Він з України.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f81ee9bc-95c9-5663-ade0-9442f022cd59', '943cfda6-4a02-5814-b219-357f7b5f5f3e', 'Teta', 'Super! Pozovi ga k nama.', 'Супер! Запроси його до нас.', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '943cfda6-4a02-5814-b219-357f7b5f5f3e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 16: +4 слів, сцена «Оренда квартири», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '78f28f85-dd8b-5e81-8a52-1b2dbce4eb34';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 16 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '3037a3b8-2532-546b-8bb2-3fdc6848a437') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('najam') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'najam'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('režije') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'režije'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('balkon') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'balkon'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('prozor') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prozor'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('balkon') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('650c8fca-5d94-55d1-84ed-73169d6b911c', 'multiple_choice', 'Що означає «balkon»?', 'балкон', '["ванна кімната", "наліво / ліворуч", "балкон", "направо / праворуч"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '650c8fca-5d94-55d1-84ed-73169d6b911c', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('režije') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5da1cd90-5ac7-56fc-986f-c9b82c816aad', 'multiple_choice', 'Що означає «režije»?', 'комунальні послуги / рахунки', '["балкон", "комунальні послуги / рахунки", "наліво / ліворуч", "ванна кімната"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5da1cd90-5ac7-56fc-986f-c9b82c816aad', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prozor') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4c51b443-3543-5ecc-b748-208bd50a5744', 'multiple_choice', 'Як хорватською «вікно»?', 'prozor', '["režije", "balkon", "prozor", "soba"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4c51b443-3543-5ecc-b748-208bd50a5744', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('najam') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3bbf50dd-6700-5382-89e5-77333ce6b6e3', 'type_answer', 'Напишіть хорватською: «оренда»', 'najam', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3bbf50dd-6700-5382-89e5-77333ce6b6e3', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('dnevni boravak') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('28defa7b-7cf0-547b-b30a-f36858f0b23e', 'type_answer', 'Напишіть хорватською: «вітальня»', 'dnevni boravak', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '28defa7b-7cf0-547b-b30a-f36858f0b23e', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('296429f9-ae37-5ade-bfca-02eb7edb3ea3', 'sentence_builder', 'Складіть: «Скільки коштує оренда?»', 'Koliko je najam?', '["Koliko", "najam?", "je"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '296429f9-ae37-5ade-bfca-02eb7edb3ea3', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8813af39-784b-537d-9d65-bd958601363e', 'listening', 'Прослухайте і складіть фразу', 'Petsto eura mjesečno.', '["mjesečno.", "Petsto", "eura"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8813af39-784b-537d-9d65-bd958601363e', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d5524993-1aaf-5b06-b90e-7f47d5fd77a5', 'speaking', 'Де кухня?', 'Gdje je kuhinja?', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd5524993-1aaf-5b06-b90e-7f47d5fd77a5', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('aa6180fe-6b3c-5559-bd9d-3d9c825162f9', 'speaking', 'Можу прийти завтра?', 'Mogu li doći sutra?', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'aa6180fe-6b3c-5559-bd9d-3d9c825162f9', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3037a3b8-2532-546b-8bb2-3fdc6848a437', v_lesson, 'Оренда квартири', 'Najam stana', 116, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('bfece99a-0201-51d1-82bd-6e73d94f2287', '3037a3b8-2532-546b-8bb2-3fdc6848a437', 'Oleg', 'Koliko je najam?', 'Скільки коштує оренда?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6c439018-ffbe-569a-bca1-bb535e53d3bd', '3037a3b8-2532-546b-8bb2-3fdc6848a437', 'Agentica', 'Petsto eura mjesečno.', 'П’ятсот євро на місяць.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('fc60559f-0da2-546e-8e51-73e351d6ff31', '3037a3b8-2532-546b-8bb2-3fdc6848a437', 'Oleg', 'Je li uključena struja?', 'Електрика входить у ціну?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('31797722-68f7-5d42-a9cf-59af57b3e83a', '3037a3b8-2532-546b-8bb2-3fdc6848a437', 'Agentica', 'Ne, režije se plaćaju posebno.', 'Ні, комунальні оплачуються окремо.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2942de7a-0a1e-5cc2-be3c-43168af25ebc', '3037a3b8-2532-546b-8bb2-3fdc6848a437', 'Oleg', 'U redu. Mogu li doći sutra?', 'Добре. Можу прийти завтра?', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '3037a3b8-2532-546b-8bb2-3fdc6848a437', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 17: +4 слів, сцена «Де телефон?», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '0ecb6f19-2630-533d-9f1b-85102442af08';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 17 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = 'f1d1c15f-2029-5c18-b1d6-3e92387e8ab5') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('mobitel') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'mobitel'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('naočale') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'naočale'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('vrata') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vrata'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('prozor') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prozor'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('mobitel') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fd819b17-506f-5eb2-91b3-3b102752b0da', 'multiple_choice', 'Що означає «mobitel»?', 'мобільний телефон', '["над", "двері", "мобільний телефон", "вікно"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fd819b17-506f-5eb2-91b3-3b102752b0da', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prozor') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4a64f4b4-b8b0-5314-9f60-c9670d7aa4a2', 'multiple_choice', 'Що означає «prozor»?', 'вікно', '["вікно", "мобільний телефон", "над", "сумка"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4a64f4b4-b8b0-5314-9f60-c9670d7aa4a2', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('naočale') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e8a80dd8-ac74-541c-9978-126e4056ea34', 'multiple_choice', 'Як хорватською «окуляри»?', 'naočale', '["iznad", "prozor", "naočale", "torba"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e8a80dd8-ac74-541c-9978-126e4056ea34', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vrata') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5d098478-f94d-547b-9c6f-3ce7d0a996dd', 'type_answer', 'Напишіть хорватською: «двері»', 'vrata', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5d098478-f94d-547b-9c6f-3ce7d0a996dd', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('pored') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7f4db1c6-5317-5fe2-bc91-c68e2ed71f41', 'type_answer', 'Напишіть хорватською: «поруч»', 'pored', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7f4db1c6-5317-5fe2-bc91-c68e2ed71f41', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('63b9f752-7cc0-5a49-bb31-8c84fcc575c5', 'sentence_builder', 'Складіть: «Ти бачиш мій телефон?»', 'Vidiš li moj mobitel?', '["mobitel?", "li", "Vidiš", "moj"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '63b9f752-7cc0-5a49-bb31-8c84fcc575c5', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7f15350d-fe20-5c5a-be18-9f4065a9b8cd', 'listening', 'Прослухайте і складіть фразу', 'Evo ga, pored televizora!', '["ga,", "televizora!", "pored", "Evo"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7f15350d-fe20-5c5a-be18-9f4065a9b8cd', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('52711f88-41a7-5f29-b1e7-eee1a171220d', 'speaking', 'Де мої ключі?', 'Gdje su moji ključevi?', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '52711f88-41a7-5f29-b1e7-eee1a171220d', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('71227840-db40-5f65-9a6e-88d802b68811', 'speaking', 'Ось вони!', 'Evo ih!', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '71227840-db40-5f65-9a6e-88d802b68811', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f1d1c15f-2029-5c18-b1d6-3e92387e8ab5', v_lesson, 'Де телефон?', 'Gdje je mobitel?', 117, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0c4af951-7ffe-5072-bb8f-fcdcc34038b8', 'f1d1c15f-2029-5c18-b1d6-3e92387e8ab5', 'Ivan', 'Vidiš li moj mobitel?', 'Ти бачиш мій телефон?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0b01c29a-6bce-5c51-8c0a-20daaaea4637', 'f1d1c15f-2029-5c18-b1d6-3e92387e8ab5', 'Ana', 'Je li na krevetu?', 'Він на ліжку?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('82d78011-c775-5f70-94bb-397936180ad9', 'f1d1c15f-2029-5c18-b1d6-3e92387e8ab5', 'Ivan', 'Nije.', 'Ні.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1db1686f-200c-55b8-b551-14948444efee', 'f1d1c15f-2029-5c18-b1d6-3e92387e8ab5', 'Ana', 'Evo ga, pored televizora!', 'Ось він, біля телевізора!', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3f423aaa-419d-5024-ace3-4d1b11b59952', 'f1d1c15f-2029-5c18-b1d6-3e92387e8ab5', 'Ivan', 'Hvala!', 'Дякую!', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', 'f1d1c15f-2029-5c18-b1d6-3e92387e8ab5', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 18: +4 слів, сцена «У меблевому магазині», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '1436c20e-0aea-550a-b66d-fb3149a1c2e2';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 18 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '0b21286e-baeb-504a-a12e-e8b4b6db5147') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('lampa') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'lampa'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('tepih') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tepih'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('namještaj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'namještaj'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('tražiti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tražiti'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('namještaj') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ca2de886-1880-5f6f-9090-e8d36d9691bc', 'multiple_choice', 'Що означає «namještaj»?', 'меблі', '["стіл", "меблі", "шафа", "телевізор"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ca2de886-1880-5f6f-9090-e8d36d9691bc', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tražiti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c37fc68e-33d5-54d1-8168-4e6eb6301f56', 'multiple_choice', 'Що означає «tražiti»?', 'шукати', '["шукати", "картина / фотографія", "телевізор", "стіл"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c37fc68e-33d5-54d1-8168-4e6eb6301f56', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('lampa') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('66b33962-bb75-551f-8b92-1a5af6277e33', 'multiple_choice', 'Як хорватською «лампа»?', 'lampa', '["stolica", "lampa", "ormar", "kauč"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '66b33962-bb75-551f-8b92-1a5af6277e33', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tepih') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('46ccd00e-2e6e-5839-a1bf-3e241d709a40', 'type_answer', 'Напишіть хорватською: «килим»', 'tepih', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '46ccd00e-2e6e-5839-a1bf-3e241d709a40', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('televizor') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4ab80bda-51ab-52e2-91da-8924cd797d4b', 'type_answer', 'Напишіть хорватською: «телевізор»', 'televizor', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4ab80bda-51ab-52e2-91da-8924cd797d4b', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c0810220-55f8-5c56-b0ed-9423391c0bb4', 'sentence_builder', 'Складіть: «Шукаю стіл і чотири стільці.»', 'Tražim stol i četiri stolice.', '["i", "stolice.", "stol", "Tražim", "četiri"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c0810220-55f8-5c56-b0ed-9423391c0bb4', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6fee4554-fb7d-5cc9-b36c-a57d147436ab', 'listening', 'Прослухайте і складіть фразу', 'Ovaj stol je od drva.', '["od", "Ovaj", "je", "stol", "drva."]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6fee4554-fb7d-5cc9-b36c-a57d147436ab', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('44ea8ee9-2f1e-56c5-9382-f65b96d87738', 'speaking', 'Що є у твоїй кімнаті?', 'Što ima u tvojoj sobi?', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '44ea8ee9-2f1e-56c5-9382-f65b96d87738', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f678d0b2-1e54-50ee-bd0a-f713b55b58cc', 'speaking', 'Скільки коштує?', 'Koliko košta?', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f678d0b2-1e54-50ee-bd0a-f713b55b58cc', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0b21286e-baeb-504a-a12e-e8b4b6db5147', v_lesson, 'У меблевому магазині', 'U trgovini namještajem', 118, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7388af62-e4e5-5e5f-807b-533a6f5b934e', '0b21286e-baeb-504a-a12e-e8b4b6db5147', 'Prodavač', 'Trebate li pomoć?', 'Вам допомогти?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('32c4b20e-6a52-5d92-b739-be0efc291485', '0b21286e-baeb-504a-a12e-e8b4b6db5147', 'Kupac', 'Da. Tražim stol i četiri stolice.', 'Так. Шукаю стіл і чотири стільці.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6f65c33d-24e7-5d3c-abaf-441e60168696', '0b21286e-baeb-504a-a12e-e8b4b6db5147', 'Prodavač', 'Ovaj stol je od drva.', 'Цей стіл дерев’яний.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ddb77d83-5e4a-5623-b103-19a97ef44f3a', '0b21286e-baeb-504a-a12e-e8b4b6db5147', 'Kupac', 'Lijep je. Koliko košta?', 'Гарний. Скільки коштує?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a4cda851-65b7-579d-9545-398dda55bde1', '0b21286e-baeb-504a-a12e-e8b4b6db5147', 'Prodavač', 'Tristo eura.', 'Триста євро.', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '0b21286e-baeb-504a-a12e-e8b4b6db5147', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 19: +5 слів, сцена «Сніданок», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '7bbaf7ff-10bb-512a-91c5-798b59ec92a5';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 19 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = 'f0778a60-fa27-584b-895f-f4d6e9dfb05e') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('doručak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'doručak'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('jaje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jaje'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('piće') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'piće'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('naranča') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'naranča'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('ručak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ručak'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('jaje') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3d09de20-3c86-5bad-91bc-d4000919b9bd', 'multiple_choice', 'Що означає «jaje»?', 'яйце', '["яйце", "сніданок", "спраглий", "обід"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3d09de20-3c86-5bad-91bc-d4000919b9bd', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('piće') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('57c0d150-4cd4-56aa-81a2-36ae74009238', 'multiple_choice', 'Що означає «piće»?', 'напій', '["обід", "напій", "яблуко", "апельсин"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '57c0d150-4cd4-56aa-81a2-36ae74009238', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ručak') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7917957f-52fd-56f7-ac5c-c960780a7f07', 'multiple_choice', 'Як хорватською «обід»?', 'ručak', '["jaje", "ručak", "sir", "piće"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7917957f-52fd-56f7-ac5c-c960780a7f07', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('naranča') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('57b1585c-e2bf-54ae-829c-e69c54bcb811', 'type_answer', 'Напишіть хорватською: «апельсин»', 'naranča', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '57b1585c-e2bf-54ae-829c-e69c54bcb811', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('doručak') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('11670845-fc98-526e-a4b1-78aeb7b399b1', 'type_answer', 'Напишіть хорватською: «сніданок»', 'doručak', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '11670845-fc98-526e-a4b1-78aeb7b399b1', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('61f4d780-d60e-5324-ae1e-39341475dd31', 'sentence_builder', 'Складіть: «Що хочеш на сніданок?»', 'Što želiš za doručak?', '["želiš", "doručak?", "za", "Što"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '61f4d780-d60e-5324-ae1e-39341475dd31', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('15b5f768-2c62-5552-8deb-a796292e71c9', 'listening', 'Прослухайте і складіть фразу', 'Sok od naranče, molim.', '["od", "molim.", "Sok", "naranče,"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '15b5f768-2c62-5552-8deb-a796292e71c9', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c95c4e39-ec3a-50ee-878f-73afeeec0171', 'speaking', 'Я дуже голодний.', 'Jako sam gladan.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c95c4e39-ec3a-50ee-878f-73afeeec0171', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8f005661-c93e-500f-8ce3-3c2868d8e9e2', 'speaking', 'Яйця і хліб.', 'Jaja i kruh.', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8f005661-c93e-500f-8ce3-3c2868d8e9e2', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f0778a60-fa27-584b-895f-f4d6e9dfb05e', v_lesson, 'Сніданок', 'Doručak', 119, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1fe270f8-b37d-52b7-964d-89b74de702da', 'f0778a60-fa27-584b-895f-f4d6e9dfb05e', 'Mama', 'Što želiš za doručak?', 'Що хочеш на сніданок?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5f6c6345-1bf6-5f0b-9321-768129bf5de0', 'f0778a60-fa27-584b-895f-f4d6e9dfb05e', 'Dino', 'Jaja i kruh.', 'Яйця і хліб.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a90bf4d6-86f0-5907-99ae-57f3945fc285', 'f0778a60-fa27-584b-895f-f4d6e9dfb05e', 'Mama', 'A za piće? Mlijeko ili sok?', 'А пити? Молоко чи сік?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9a3636ac-6d38-599b-97a7-93f518ea7db4', 'f0778a60-fa27-584b-895f-f4d6e9dfb05e', 'Dino', 'Sok od naranče, molim.', 'Апельсиновий сік, будь ласка.', 4) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', 'f0778a60-fa27-584b-895f-f4d6e9dfb05e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 20: +6 слів, сцена «Замовлення їжі», 9 нових вправ
do $$
declare
  v_lesson constant uuid := 'c9e045fb-91ff-52a2-9916-1b698d30eb19';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 20 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '9a6afa32-d212-576b-baa3-1b92fa6906b2') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('juha') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'juha'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('tjestenina') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tjestenina'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('salata') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'salata'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('meso') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'meso'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('riba') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'riba'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('jesti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jesti'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('meso') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d0cdfabe-db43-5a01-a736-986c1f570878', 'multiple_choice', 'Що означає «meso»?', 'м''ясо', '["макарони; паста", "меню", "м''ясо", "з молоком"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd0cdfabe-db43-5a01-a736-986c1f570878', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('riba') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e7161673-2672-5835-afa9-4385a3a64fd8', 'multiple_choice', 'Що означає «riba»?', 'риба', '["з молоком", "кава", "меню", "риба"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e7161673-2672-5835-afa9-4385a3a64fd8', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('juha') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('21e13e12-283b-5a80-8422-280d961a92ec', 'multiple_choice', 'Як хорватською «суп / юшка»?', 'juha', '["juha", "mlijeko", "jesti", "kava"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '21e13e12-283b-5a80-8422-280d961a92ec', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tjestenina') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3cc66ff4-6b8e-5329-a7cf-a08f889af927', 'type_answer', 'Напишіть хорватською: «макарони; паста»', 'tjestenina', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3cc66ff4-6b8e-5329-a7cf-a08f889af927', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('jesti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e5800225-d6b9-50f2-a057-8c4276c286cc', 'type_answer', 'Напишіть хорватською: «їсти»', 'jesti', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e5800225-d6b9-50f2-a057-8c4276c286cc', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ee1fe648-b609-581d-a7c4-0522644f6dec', 'sentence_builder', 'Складіть: «Тоді суп, будь ласка.»', 'Onda juhu, molim.', '["molim.", "juhu,", "Onda"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ee1fe648-b609-581d-a7c4-0522644f6dec', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f402759b-748f-5f86-83a2-cd6c1053ce9c', 'listening', 'Прослухайте і складіть фразу', 'Što preporučujete?', '["preporučujete?", "Što"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f402759b-748f-5f86-83a2-cd6c1053ce9c', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('bebf1d73-553d-5c5d-bcb9-5f6ebb7ada8b', 'speaking', 'Каву з молоком, будь ласка.', 'Kavu s mlijekom, molim.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'bebf1d73-553d-5c5d-bcb9-5f6ebb7ada8b', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fe1ee8d2-3563-58ab-90fd-9b07dc22a158', 'speaking', 'Що порадите?', 'Što preporučujete?', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fe1ee8d2-3563-58ab-90fd-9b07dc22a158', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9a6afa32-d212-576b-baa3-1b92fa6906b2', v_lesson, 'Замовлення їжі', 'Narudžba', 120, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1474b7db-9fbd-5c02-a22f-6f19a1e5ee3e', '9a6afa32-d212-576b-baa3-1b92fa6906b2', 'Konobar', 'Želite li nešto jesti?', 'Бажаєте щось поїсти?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('70a1ccce-5fd0-5eab-8ce8-d3459040eb9c', '9a6afa32-d212-576b-baa3-1b92fa6906b2', 'Gost', 'Što preporučujete?', 'Що порадите?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9bc7ea58-767b-5b92-9e71-92e139bd601c', '9a6afa32-d212-576b-baa3-1b92fa6906b2', 'Konobar', 'Danas imamo dobru juhu i tjesteninu.', 'Сьогодні в нас смачний суп і паста.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0dd12453-b915-588d-8419-b135f32761e2', '9a6afa32-d212-576b-baa3-1b92fa6906b2', 'Gost', 'Onda juhu, molim.', 'Тоді суп, будь ласка.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c544039a-dd37-52e8-86a3-d522cdbb3eda', '9a6afa32-d212-576b-baa3-1b92fa6906b2', 'Konobar', 'Odmah stiže.', 'Зараз принесу.', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '9a6afa32-d212-576b-baa3-1b92fa6906b2', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 21: +6 слів, сцена «Розрахунок», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '8b30911e-4e57-5648-9ff6-bd11c1b0e27e';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 21 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '27b7139c-4483-5c85-bf47-6db13fd3838c') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('ukupno') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ukupno'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('napojnica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'napojnica'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('gotovina') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'gotovina'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('kartica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kartica'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('hvala lijepa') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hvala lijepa'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('doviđenja') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'doviđenja'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('ukupno') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('36deeb85-582b-5ce0-b75a-9e6c0744a8e1', 'multiple_choice', 'Що означає «ukupno»?', 'разом; загалом', '["до побачення", "разом; загалом", "щиро дякую", "рахунок, будь ласка"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '36deeb85-582b-5ce0-b75a-9e6c0744a8e1', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('gotovina') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('682e53b8-def1-5190-9b42-3c86f25b7b7a', 'multiple_choice', 'Що означає «gotovina»?', 'готівка', '["готівка", "щиро дякую", "рахунок, будь ласка", "до побачення"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '682e53b8-def1-5190-9b42-3c86f25b7b7a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kartica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('87703b6b-1872-5463-82d8-2d99e20835e1', 'multiple_choice', 'Як хорватською «банківська картка»?', 'kartica', '["kartica", "mogu li platiti karticom", "ukupno", "gotovina"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '87703b6b-1872-5463-82d8-2d99e20835e1', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('doviđenja') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2c88e992-5cb2-560a-9a70-f98228ae7fd0', 'type_answer', 'Напишіть хорватською: «до побачення»', 'doviđenja', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2c88e992-5cb2-560a-9a70-f98228ae7fd0', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('hvala lijepa') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('31e61dcf-7edf-564c-b89a-0dd3a8818d8c', 'type_answer', 'Напишіть хорватською: «щиро дякую»', 'hvala lijepa', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '31e61dcf-7edf-564c-b89a-0dd3a8818d8c', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7d41cf41-fe0f-5a74-b90a-8c21aa78ea06', 'sentence_builder', 'Складіть: «Разом двадцять два євро.»', 'Ukupno dvadeset dva eura.', '["dvadeset", "dva", "eura.", "Ukupno"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7d41cf41-fe0f-5a74-b90a-8c21aa78ea06', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('baee2dcb-dfac-5c25-bbbe-169af40ade25', 'listening', 'Прослухайте і складіть фразу', 'Izvolite dvadeset pet.', '["dvadeset", "pet.", "Izvolite"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'baee2dcb-dfac-5c25-bbbe-169af40ade25', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('780e0691-518c-5401-8b5e-c0b219edb5f8', 'speaking', 'Рахунок, будь ласка.', 'Molim vas, račun.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '780e0691-518c-5401-8b5e-c0b219edb5f8', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('20dd10f6-66f5-555f-af32-cff64098bb6f', 'speaking', 'Можна заплатити карткою?', 'Mogu li platiti karticom?', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '20dd10f6-66f5-555f-af32-cff64098bb6f', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('27b7139c-4483-5c85-bf47-6db13fd3838c', v_lesson, 'Розрахунок', 'Plaćanje', 121, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('eb9417ab-bd03-5389-9532-0bdc76655c28', '27b7139c-4483-5c85-bf47-6db13fd3838c', 'Konobarica', 'Ukupno dvadeset dva eura.', 'Разом двадцять два євро.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2d4c7c98-f1b6-55a1-9cd4-29dab5ef87ef', '27b7139c-4483-5c85-bf47-6db13fd3838c', 'Gost', 'Izvolite dvadeset pet. U redu je.', 'Ось двадцять п’ять. Решти не треба.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d28067ee-59d4-58c5-b15a-e81c692b7cbc', '27b7139c-4483-5c85-bf47-6db13fd3838c', 'Konobarica', 'Hvala lijepa! Doviđenja!', 'Щиро дякую! До побачення!', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ea72de07-57cd-5c0f-8a66-1e4240f80774', '27b7139c-4483-5c85-bf47-6db13fd3838c', 'Gost', 'Doviđenja!', 'До побачення!', 4) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '27b7139c-4483-5c85-bf47-6db13fd3838c', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 22: +4 слів, сцена «Полуниці», 9 нових вправ
do $$
declare
  v_lesson constant uuid := 'e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 22 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '36a42094-f88b-5272-ba57-77d200a09ffc') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('jagoda') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jagoda'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('banana') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'banana'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('krumpir') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'krumpir'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('sladak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sladak'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('jagoda') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('88862b0c-ba21-5e8b-b0be-44c5e1285dbd', 'multiple_choice', 'Що означає «jagoda»?', 'полуниця', '["полуниця", "солодкий", "банан", "овочі"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '88862b0c-ba21-5e8b-b0be-44c5e1285dbd', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sladak') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('36672f5e-b323-570c-88dc-330ce6dc760a', 'multiple_choice', 'Що означає «sladak»?', 'солодкий', '["полуниця", "фрукти", "яблуко", "солодкий"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '36672f5e-b323-570c-88dc-330ce6dc760a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('banana') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d6be2ad5-8162-5b25-a03e-6fa778f299e8', 'multiple_choice', 'Як хорватською «банан»?', 'banana', '["krumpir", "banana", "voće", "koliko to košta"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd6be2ad5-8162-5b25-a03e-6fa778f299e8', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('krumpir') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c12f4a10-7d52-511a-8b53-fd00b6b1ee33', 'type_answer', 'Напишіть хорватською: «картопля»', 'krumpir', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c12f4a10-7d52-511a-8b53-fd00b6b1ee33', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('rajčica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('88438021-91fc-5703-bd6e-deed52444133', 'type_answer', 'Напишіть хорватською: «помідор»', 'rajčica', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '88438021-91fc-5703-bd6e-deed52444133', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4e0df609-be28-525b-937e-73edaddab076', 'sentence_builder', 'Складіть: «Полуниці солодкі?»', 'Jesu li jagode slatke?', '["slatke?", "li", "Jesu", "jagode"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4e0df609-be28-525b-937e-73edaddab076', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('266e7cc6-0f63-5906-a59e-f4d28eb788c9', 'listening', 'Прослухайте і складіть фразу', 'Ne, to je sve.', '["to", "je", "Ne,", "sve."]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '266e7cc6-0f63-5906-a59e-f4d28eb788c9', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8298d376-ffb7-5154-8fb7-e5c131cd6519', 'speaking', 'Кілограм яблук, будь ласка.', 'Kilu jabuka, molim.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8298d376-ffb7-5154-8fb7-e5c131cd6519', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a786256a-8484-5058-8ba3-70acd9044127', 'speaking', 'Ні, це все.', 'Ne, to je sve.', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a786256a-8484-5058-8ba3-70acd9044127', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('36a42094-f88b-5272-ba57-77d200a09ffc', v_lesson, 'Полуниці', 'Jagode', 122, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4a140a08-85a7-5e72-8b6b-eb9655cc480d', '36a42094-f88b-5272-ba57-77d200a09ffc', 'Kupac', 'Jesu li jagode slatke?', 'Полуниці солодкі?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9882a7e8-8830-5dab-9563-ea0206fa5c55', '36a42094-f88b-5272-ba57-77d200a09ffc', 'Prodavač', 'Jako slatke! Probajte.', 'Дуже солодкі! Спробуйте.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0cb3be4a-cdda-5722-a8e9-8df7dbc0f930', '36a42094-f88b-5272-ba57-77d200a09ffc', 'Kupac', 'Odlične su. Kilu jagoda, molim.', 'Чудові. Кілограм полуниць, будь ласка.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7ff69527-b555-57d4-bca4-2c3039ca8348', '36a42094-f88b-5272-ba57-77d200a09ffc', 'Prodavač', 'Pet eura. Još nešto?', 'П’ять євро. Ще щось?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ea9a072d-e226-5a6f-a6db-e4dd85ff240f', '36a42094-f88b-5272-ba57-77d200a09ffc', 'Kupac', 'Ne, to je sve.', 'Ні, це все.', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '36a42094-f88b-5272-ba57-77d200a09ffc', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 23: +5 слів, сцена «Примірочна», 9 нових вправ
do $$
declare
  v_lesson constant uuid := 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 23 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '97b80d44-e53a-50e8-bb7e-bb72aa36fd28') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('hlače') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hlače'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('cipele') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'cipele'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('veličina') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'veličina'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('mali') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'mali'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('crven') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'crven'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('hlače') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('59c7ddf7-8761-5c4d-9d8d-e51258611b7a', 'multiple_choice', 'Що означає «hlače»?', 'штани', '["штани", "цей", "той", "малий"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '59c7ddf7-8761-5c4d-9d8d-e51258611b7a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('cipele') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b6e3a460-d3a8-58e6-97de-339248f1ae60', 'multiple_choice', 'Що означає «cipele»?', 'взуття / туфлі', '["цей", "синій / блакитний", "взуття / туфлі", "червоний"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b6e3a460-d3a8-58e6-97de-339248f1ae60', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('mali') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3b3e391b-e140-5b20-b60b-ba476ddaac27', 'multiple_choice', 'Як хорватською «малий»?', 'mali', '["onaj", "hlače", "mali", "taj"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3b3e391b-e140-5b20-b60b-ba476ddaac27', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('veličina') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2f5ade1f-9cc3-5509-b4fb-bb171ae173f5', 'type_answer', 'Напишіть хорватською: «розмір (одягу/взуття)»', 'veličina', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2f5ade1f-9cc3-5509-b4fb-bb171ae173f5', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('crven') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a90be732-f602-5139-8e0d-7fc748af0434', 'type_answer', 'Напишіть хорватською: «червоний»', 'crven', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a90be732-f602-5139-8e0d-7fc748af0434', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('43c7abc5-2270-5ffa-88d7-dde604ffd523', 'sentence_builder', 'Складіть: «Можна приміряти цю футболку?»', 'Mogu li probati ovu majicu?', '["ovu", "Mogu", "li", "probati", "majicu?"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '43c7abc5-2270-5ffa-88d7-dde604ffd523', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f82f209d-d8bb-5425-b333-2893413f7ac1', 'listening', 'Прослухайте і складіть фразу', 'Ova je mala. Imate li veću?', '["Ova", "mala.", "Imate", "li", "veću?", "je"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f82f209d-d8bb-5425-b333-2893413f7ac1', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('79d2eb31-dfa5-5650-88d8-6952daf95f7b', 'speaking', 'Скільки коштує ця футболка?', 'Koliko košta ova majica?', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '79d2eb31-dfa5-5650-88d8-6952daf95f7b', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('25006227-554f-5dad-89f4-c708f6511405', 'speaking', 'Візьму синю.', 'Uzet ću plavu.', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '25006227-554f-5dad-89f4-c708f6511405', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('97b80d44-e53a-50e8-bb7e-bb72aa36fd28', v_lesson, 'Примірочна', 'U kabini', 123, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('170facc3-b0e1-56b4-bb3a-a16c35c7dbfe', '97b80d44-e53a-50e8-bb7e-bb72aa36fd28', 'Kupac', 'Mogu li probati ovu majicu?', 'Можна приміряти цю футболку?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c6b7a154-704a-51e9-9d6f-c31ede4d9eb0', '97b80d44-e53a-50e8-bb7e-bb72aa36fd28', 'Prodavačica', 'Naravno, kabina je lijevo.', 'Звісно, примірочна ліворуч.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a3b43953-fa34-5701-92cd-474fc95213a6', '97b80d44-e53a-50e8-bb7e-bb72aa36fd28', 'Kupac', 'Ova je mala. Imate li veću?', 'Ця мала. Є більша?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('27b3c15c-2a83-5fda-b94e-7b81c33cc83c', '97b80d44-e53a-50e8-bb7e-bb72aa36fd28', 'Prodavačica', 'Imamo. Izvolite, veličina L.', 'Є. Прошу, розмір L.', 4) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '97b80d44-e53a-50e8-bb7e-bb72aa36fd28', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 24: +4 слів, сцена «Картку не приймає», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '28913ad6-490f-5d89-bad7-9b303c673fcd';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 24 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '50c872c1-f34a-53ff-95d0-20865730d7a7') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('kartica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kartica'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('gotovina') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'gotovina'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('nažalost') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'nažalost'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('račun') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'račun'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('kartica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('393ea793-e9ae-5860-8f59-0974406e250c', 'multiple_choice', 'Що означає «kartica»?', 'банківська картка', '["пакет", "на жаль", "банківська картка", "євро"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '393ea793-e9ae-5860-8f59-0974406e250c', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('nažalost') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8e8f9f10-add8-5cd3-8c22-a70452f7249d', 'multiple_choice', 'Що означає «nažalost»?', 'на жаль', '["пакет", "на жаль", "карткою чи готівкою", "до побачення"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8e8f9f10-add8-5cd3-8c22-a70452f7249d', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('gotovina') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('bb52047c-7df6-5381-a693-cd90ebfc2cab', 'multiple_choice', 'Як хорватською «готівка»?', 'gotovina', '["doviđenja", "kartica", "vrećica", "gotovina"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'bb52047c-7df6-5381-a693-cd90ebfc2cab', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('račun') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('91e6c266-a825-5440-9018-2968f4837ebb', 'type_answer', 'Напишіть хорватською: «рахунок / чек»', 'račun', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '91e6c266-a825-5440-9018-2968f4837ebb', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('cent') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0b4c701f-273f-5b2d-a8a2-f604456a6272', 'type_answer', 'Напишіть хорватською: «цент»', 'cent', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0b4c701f-273f-5b2d-a8a2-f604456a6272', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('301d06ca-e0f4-5160-be84-c6759902071b', 'sentence_builder', 'Складіть: «На жаль, картка не проходить.»', 'Nažalost, kartica ne prolazi.', '["prolazi.", "Nažalost,", "ne", "kartica"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '301d06ca-e0f4-5160-be84-c6759902071b', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2c6a3720-6eba-5a70-9b4b-331605a41c46', 'listening', 'Прослухайте і складіть фразу', 'Onda gotovinom.', '["gotovinom.", "Onda"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2c6a3720-6eba-5a70-9b4b-331605a41c46', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7fe42816-fd6e-5017-957a-99a925ce79e1', 'speaking', 'Готівкою чи карткою?', 'Gotovinom ili karticom?', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7fe42816-fd6e-5017-957a-99a925ce79e1', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7b1bfa6e-2a08-5b7f-b6fa-990b3f31381f', 'speaking', 'Тоді готівкою.', 'Onda gotovinom.', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7b1bfa6e-2a08-5b7f-b6fa-990b3f31381f', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('50c872c1-f34a-53ff-95d0-20865730d7a7', v_lesson, 'Картку не приймає', 'Kartica ne prolazi', 124, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('df12cc96-8013-515d-bac1-fe6b8b6ece7d', '50c872c1-f34a-53ff-95d0-20865730d7a7', 'Blagajnik', 'Dvadeset eura, molim.', 'Двадцять євро, будь ласка.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2c715ae4-66a6-544e-8102-51f41e53fe2c', '50c872c1-f34a-53ff-95d0-20865730d7a7', 'Kupac', 'Izvolite karticu.', 'Ось картка.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('51c1bcff-6abd-5d38-b9f4-cd6ea4a69742', '50c872c1-f34a-53ff-95d0-20865730d7a7', 'Blagajnik', 'Nažalost, kartica ne prolazi.', 'На жаль, картка не проходить.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('445af461-b622-5454-8ddd-51d4d60c3e74', '50c872c1-f34a-53ff-95d0-20865730d7a7', 'Kupac', 'Onda gotovinom.', 'Тоді готівкою.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('45591c1b-1724-5466-a2e3-67dbe3d72e31', '50c872c1-f34a-53ff-95d0-20865730d7a7', 'Blagajnik', 'Hvala. Izvolite račun.', 'Дякую. Ось чек.', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '50c872c1-f34a-53ff-95d0-20865730d7a7', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 25: +5 слів, сцена «На зупинці», 9 нових вправ
do $$
declare
  v_lesson constant uuid := 'e0b9d742-0418-597b-9482-b6e2d82469da';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 25 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '4408713e-8b5a-5f18-b024-718d11d8338d') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('stanica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'stanica'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('centar') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'centar'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('preko puta') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'preko puta'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('tamo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tamo'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('ovdje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ovdje'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('centar') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7aa10894-1386-54de-b882-f21284b3bd17', 'multiple_choice', 'Що означає «centar»?', 'центр', '["прямо", "вокзал", "центр", "пішки"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7aa10894-1386-54de-b882-f21284b3bd17', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('preko puta') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ed1800be-9db5-58ba-94f2-4cb5de313826', 'multiple_choice', 'Що означає «preko puta»?', 'навпроти', '["навпроти", "прямо", "вокзал", "направо / праворуч"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ed1800be-9db5-58ba-94f2-4cb5de313826', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tamo') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('385c3de5-e24d-5d3b-bd19-a54506ee2e48', 'multiple_choice', 'Як хорватською «там»?', 'tamo', '["tamo", "lijevo", "desno", "ovdje"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '385c3de5-e24d-5d3b-bd19-a54506ee2e48', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ovdje') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('11dda374-eb31-5da5-b419-f4910eff3cf3', 'type_answer', 'Напишіть хорватською: «тут»', 'ovdje', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '11dda374-eb31-5da5-b419-f4910eff3cf3', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('stanica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0ef4cef2-8da8-5d9e-91ec-b37efde684b0', 'type_answer', 'Напишіть хорватською: «зупинка / станція»', 'stanica', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0ef4cef2-8da8-5d9e-91ec-b37efde684b0', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c6c1e5a6-ff6b-574b-a230-471d49f68c4f', 'sentence_builder', 'Складіть: «Який автобус їде до центру?»', 'Koji autobus ide do centra?', '["centra?", "do", "ide", "autobus", "Koji"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c6c1e5a6-ff6b-574b-a230-471d49f68c4f', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a9a55245-8731-5799-9910-485b4da45047', 'listening', 'Прослухайте і складіть фразу', 'Tamo, preko puta.', '["preko", "Tamo,", "puta."]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a9a55245-8731-5799-9910-485b4da45047', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2f9a5ad7-3768-5117-b0a8-4887acfc3bf8', 'speaking', 'Це далеко?', 'Je li daleko?', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2f9a5ad7-3768-5117-b0a8-4887acfc3bf8', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9d5b2ff4-884f-538c-8cdc-f95ea726c4af', 'speaking', 'Де зупинка?', 'Gdje je stanica?', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9d5b2ff4-884f-538c-8cdc-f95ea726c4af', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4408713e-8b5a-5f18-b024-718d11d8338d', v_lesson, 'На зупинці', 'Na stanici', 125, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('309420f0-b00b-5314-81a1-3321bc4bacc2', '4408713e-8b5a-5f18-b024-718d11d8338d', 'Turist', 'Oprostite, koji autobus ide do centra?', 'Вибачте, який автобус їде до центру?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('be5f7941-f776-5f8a-8d3a-86e164b32301', '4408713e-8b5a-5f18-b024-718d11d8338d', 'Gospođa', 'Broj šest.', 'Номер шість.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('432abb0c-829c-5812-8f10-bd83734a58a0', '4408713e-8b5a-5f18-b024-718d11d8338d', 'Turist', 'Gdje je stanica?', 'Де зупинка?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('726a0912-9a38-5dbf-bd13-941bf3f9449c', '4408713e-8b5a-5f18-b024-718d11d8338d', 'Gospođa', 'Tamo, preko puta.', 'Там, навпроти.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('767dd94e-7159-56c7-bb44-9bbe262995ab', '4408713e-8b5a-5f18-b024-718d11d8338d', 'Turist', 'Hvala Vam!', 'Дякую вам!', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '4408713e-8b5a-5f18-b024-718d11d8338d', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 26: +5 слів, сцена «У музеї», 9 нових вправ
do $$
declare
  v_lesson constant uuid := '1e0384e5-6097-56ed-ab56-cf530f02ab73';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 26 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = 'c24f0807-bbf7-5ed0-9833-313c60b06d96') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('ulaznica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ulaznica'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('student') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'student'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('trg') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'trg'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('ulica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ulica'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('otvoren') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'otvoren'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('ulica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a73c4416-e872-5568-b7a6-3507eaabecc7', 'multiple_choice', 'Що означає «ulica»?', 'вулиця', '["великий", "площа", "студент", "вулиця"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a73c4416-e872-5568-b7a6-3507eaabecc7', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('student') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5a4fa97f-af68-51bd-9810-57f1f142504e', 'multiple_choice', 'Що означає «student»?', 'студент', '["вхідний квиток", "місто", "площа", "студент"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5a4fa97f-af68-51bd-9810-57f1f142504e', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('trg') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7822e927-08f7-5c51-8957-f4956cbec72c', 'multiple_choice', 'Як хорватською «площа»?', 'trg', '["trg", "student", "nov", "ulica"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7822e927-08f7-5c51-8957-f4956cbec72c', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ulaznica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d8d47fd6-d234-58d6-8d8d-e7ca850ef203', 'type_answer', 'Напишіть хорватською: «вхідний квиток»', 'ulaznica', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd8d47fd6-d234-58d6-8d8d-e7ca850ef203', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('otvoren') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a82ccc8b-b21a-5c59-998c-307cd30b524d', 'type_answer', 'Напишіть хорватською: «відчинений / відкритий»', 'otvoren', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a82ccc8b-b21a-5c59-998c-307cd30b524d', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b95af33e-4771-52e7-8c8f-fcadd1e1a157', 'sentence_builder', 'Складіть: «Два квитки, будь ласка.»', 'Dvije ulaznice, molim.', '["molim.", "Dvije", "ulaznice,"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b95af33e-4771-52e7-8c8f-fcadd1e1a157', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0595d631-ccf5-5ab4-bdf9-a1dee7d8d6fe', 'listening', 'Прослухайте і складіть фразу', 'Muzej radi do šest.', '["radi", "do", "Muzej", "šest."]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0595d631-ccf5-5ab4-bdf9-a1dee7d8d6fe', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e007fa2c-948c-5984-bf56-81f3c5bd9457', 'speaking', 'Ходімо в музей!', 'Idemo u muzej!', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e007fa2c-948c-5984-bf56-81f3c5bd9457', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2946e99d-27ad-51c3-b9a5-3e1490f3b3d7', 'speaking', 'Два квитки, будь ласка.', 'Dvije ulaznice, molim.', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2946e99d-27ad-51c3-b9a5-3e1490f3b3d7', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c24f0807-bbf7-5ed0-9833-313c60b06d96', v_lesson, 'У музеї', 'U muzeju', 126, 'A0', 'travel', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('de43be23-a2fa-5cf9-9a51-b047eaaea6f3', 'c24f0807-bbf7-5ed0-9833-313c60b06d96', 'Ana', 'Dvije ulaznice, molim.', 'Два квитки, будь ласка.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('04e949d8-d9da-5c94-a048-f3a035bf1d27', 'c24f0807-bbf7-5ed0-9833-313c60b06d96', 'Blagajnica', 'Šesnaest eura. Studenti imaju popust.', 'Шістнадцять євро. Студенти мають знижку.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7fe59326-ab11-5cec-9009-ec10afb62520', 'c24f0807-bbf7-5ed0-9833-313c60b06d96', 'Ana', 'Nismo studenti.', 'Ми не студенти.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4c2a3382-dc81-521e-b4f1-42a5566c03c6', 'c24f0807-bbf7-5ed0-9833-313c60b06d96', 'Blagajnica', 'U redu. Muzej radi do šest.', 'Добре. Музей працює до шостої.', 4) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', 'c24f0807-bbf7-5ed0-9833-313c60b06d96', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 27: +5 слів, сцена «У поїзді», 9 нових вправ
do $$
declare
  v_lesson constant uuid := 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 27 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '6328dd45-53a0-58f1-acc8-7c590e088328') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('vlak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vlak'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('putovati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'putovati'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('kolodvor') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kolodvor'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('dolazak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dolazak'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('sat') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sat'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('dolazak') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d2b86f1d-5485-53da-b03e-4d324f972765', 'multiple_choice', 'Що означає «dolazak»?', 'прибуття', '["перон", "вокзал", "прибуття", "поїзд"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd2b86f1d-5485-53da-b03e-4d324f972765', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('putovati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('74913e2e-7b61-5fa7-9237-faf3656e4100', 'multiple_choice', 'Що означає «putovati»?', 'подорожувати', '["подорожувати", "годинник / година", "поїзд", "квиток / карта"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '74913e2e-7b61-5fa7-9237-faf3656e4100', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vlak') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('bdb1f594-d9fe-50da-94ab-48b626a1d3d3', 'multiple_choice', 'Як хорватською «поїзд»?', 'vlak', '["autobus", "kolodvor", "vlak", "karta"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'bdb1f594-d9fe-50da-94ab-48b626a1d3d3', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kolodvor') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('91a4e6be-9004-5672-ad01-3b8e8081c8af', 'type_answer', 'Напишіть хорватською: «вокзал»', 'kolodvor', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '91a4e6be-9004-5672-ad01-3b8e8081c8af', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('sat') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('32903b38-701e-559f-9bb9-0d5287424e72', 'type_answer', 'Напишіть хорватською: «годинник / година»', 'sat', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '32903b38-701e-559f-9bb9-0d5287424e72', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('30b3a685-6576-580e-9414-0af4b16f2c77', 'sentence_builder', 'Складіть: «Скільки триває поїздка?»', 'Koliko traje vožnja?', '["Koliko", "vožnja?", "traje"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '30b3a685-6576-580e-9414-0af4b16f2c77', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('21eb9c50-83eb-5182-ac55-acc2102d6d81', 'listening', 'Прослухайте і складіть фразу', 'Oko dva sata.', '["dva", "sata.", "Oko"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '21eb9c50-83eb-5182-ac55-acc2102d6d81', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1bf50ec4-0829-50db-873c-cc3479da5790', 'speaking', 'Один квиток до Спліта, будь ласка.', 'Jednu kartu za Split, molim.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1bf50ec4-0829-50db-873c-cc3479da5790', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5f5b7bb4-f6b4-5521-9297-a1bb1cba5907', 'speaking', 'Коли їде автобус?', 'Kada ide autobus?', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5f5b7bb4-f6b4-5521-9297-a1bb1cba5907', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6328dd45-53a0-58f1-acc8-7c590e088328', v_lesson, 'У поїзді', 'U vlaku', 127, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('eb9daab3-4ae0-58e4-86ae-542932ad9ed8', '6328dd45-53a0-58f1-acc8-7c590e088328', 'Kondukter', 'Karte, molim.', 'Квитки, будь ласка.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('eb3c43d3-61a9-5cc4-a05c-eb1da5142575', '6328dd45-53a0-58f1-acc8-7c590e088328', 'Putnica', 'Izvolite.', 'Прошу.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('21fe92cf-27c2-5075-bfed-fa14b698de5f', '6328dd45-53a0-58f1-acc8-7c590e088328', 'Kondukter', 'Hvala. Presjedate u Zagrebu.', 'Дякую. У вас пересадка в Загребі.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0a875036-9825-5717-80f9-027e77076c3e', '6328dd45-53a0-58f1-acc8-7c590e088328', 'Putnica', 'Koliko traje vožnja?', 'Скільки триває поїздка?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('33e8322c-832c-54e3-98b3-9cd9a170a26f', '6328dd45-53a0-58f1-acc8-7c590e088328', 'Kondukter', 'Oko dva sata.', 'Близько двох годин.', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '6328dd45-53a0-58f1-acc8-7c590e088328', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 28: +5 слів, сцена «На рецепції», 9 нових вправ
do $$
declare
  v_lesson constant uuid := 'edbae9ca-c4f4-575d-b876-d50b0a1fd9b5';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 28 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = 'd9cb81e7-d226-50f4-84cf-4f4e2a4f7151') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('noć') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'noć'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('slobodan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'slobodan'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('soba') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'soba'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('recepcija') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'recepcija'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('putovnica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'putovnica'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('noć') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('48f63d8b-a7d8-528d-a66d-5da06cd82f49', 'multiple_choice', 'Що означає «noć»?', 'ніч', '["ніч", "готель", "вільний", "закордонний паспорт"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '48f63d8b-a7d8-528d-a66d-5da06cd82f49', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('slobodan') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('af5b82e0-7dcd-5ae0-9192-9640c7e4fca7', 'multiple_choice', 'Що означає «slobodan»?', 'вільний', '["чи можете ви мені допомогти", "рецепція", "вільний", "ніч"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'af5b82e0-7dcd-5ae0-9192-9640c7e4fca7', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('recepcija') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7834113d-3e5f-56c5-9589-5f20624e2c08', 'multiple_choice', 'Як хорватською «рецепція»?', 'recepcija', '["recepcija", "soba", "hotel", "pomoći"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7834113d-3e5f-56c5-9589-5f20624e2c08', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('putovnica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d16410fb-53e2-56a0-9394-083f6610942b', 'type_answer', 'Напишіть хорватською: «закордонний паспорт»', 'putovnica', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd16410fb-53e2-56a0-9394-083f6610942b', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('soba') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f0dc4710-17c8-5c0e-9544-a908cf9d9d8d', 'type_answer', 'Напишіть хорватською: «кімната»', 'soba', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f0dc4710-17c8-5c0e-9544-a908cf9d9d8d', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9472361a-65ea-5c2f-bc6b-830468357583', 'sentence_builder', 'Складіть: «У вас є вільний номер?»', 'Imate li slobodnu sobu?', '["sobu?", "Imate", "li", "slobodnu"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9472361a-65ea-5c2f-bc6b-830468357583', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8d06664d-0640-52e7-ab8e-9ca53c017f91', 'listening', 'Прослухайте і складіть фразу', 'Za dvije noći.', '["noći.", "Za", "dvije"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8d06664d-0640-52e7-ab8e-9ca53c017f91', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4aeccb1e-8226-50ea-96d9-08927cba831a', 'speaking', 'Можете мені допомогти?', 'Možete li mi pomoći?', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4aeccb1e-8226-50ea-96d9-08927cba831a', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d88a6de3-e0f5-5968-88df-088f3e27d95f', 'speaking', 'Я заблукав.', 'Izgubio sam se.', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd88a6de3-e0f5-5968-88df-088f3e27d95f', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d9cb81e7-d226-50f4-84cf-4f4e2a4f7151', v_lesson, 'На рецепції', 'Na recepciji', 128, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3068755d-2f35-5bfe-89fc-466345a1e556', 'd9cb81e7-d226-50f4-84cf-4f4e2a4f7151', 'Oleg', 'Dobra večer. Imate li slobodnu sobu?', 'Добрий вечір. У вас є вільний номер?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('99ea2d50-0fb8-5f98-bdbb-84f68c62d945', 'd9cb81e7-d226-50f4-84cf-4f4e2a4f7151', 'Recepcionar', 'Imamo. Za koliko noći?', 'Є. На скільки ночей?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6404f4d4-8bc2-5120-8d81-0176dfa2f053', 'd9cb81e7-d226-50f4-84cf-4f4e2a4f7151', 'Oleg', 'Za dvije noći.', 'На дві ночі.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('674ee76b-8721-5f4f-967c-9c5e99d1db1f', 'd9cb81e7-d226-50f4-84cf-4f4e2a4f7151', 'Recepcionar', 'Može. Trebam Vašu putovnicu.', 'Можна. Мені потрібен ваш паспорт.', 4) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', 'd9cb81e7-d226-50f4-84cf-4f4e2a4f7151', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 29: +5 слів, сцена «У лікаря», 9 нових вправ
do $$
declare
  v_lesson constant uuid := 'fbc71f82-e715-5bab-a990-b8542fb0fe01';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 29 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '32ea8229-b49c-5226-8bf5-814fbe1f04a7') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('glava') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'glava'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('temperatura') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'temperatura'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('recept') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'recept'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('ljekarna') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ljekarna'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('liječnik') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'liječnik'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('glava') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('45fc66c3-2f62-5395-994b-cfde32683936', 'multiple_choice', 'Що означає «glava»?', 'голова', '["лікар", "температура (жар)", "голова", "викликайте поліцію"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '45fc66c3-2f62-5395-994b-cfde32683936', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('temperatura') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1032fd95-217a-558c-91e8-f7c94f595271', 'multiple_choice', 'Що означає «temperatura»?', 'температура (жар)', '["температура (жар)", "лікар", "викликайте поліцію", "мені потрібна допомога"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1032fd95-217a-558c-91e8-f7c94f595271', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('recept') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('50b7b0f4-8f5d-5863-aaf6-d85b408462e5', 'multiple_choice', 'Як хорватською «рецепт»?', 'recept', '["upomoć", "glava", "trebam doktora", "recept"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '50b7b0f4-8f5d-5863-aaf6-d85b408462e5', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ljekarna') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fcb8517f-cc82-5ee6-b1e8-ff79eada7426', 'type_answer', 'Напишіть хорватською: «аптека»', 'ljekarna', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fcb8517f-cc82-5ee6-b1e8-ff79eada7426', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('liječnik') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d90fdb86-45cc-5067-8acb-f949064d0802', 'type_answer', 'Напишіть хорватською: «лікар»', 'liječnik', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd90fdb86-45cc-5067-8acb-f949064d0802', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e7c54f93-1237-5442-ab9c-0d61f07546ab', 'sentence_builder', 'Складіть: «У мене болить голова.»', 'Boli me glava.', '["me", "Boli", "glava."]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e7c54f93-1237-5442-ab9c-0d61f07546ab', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b9dc449a-7b4a-5132-9110-37a0b42e16a3', 'listening', 'Прослухайте і складіть фразу', 'Imate li temperaturu?', '["li", "Imate", "temperaturu?"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b9dc449a-7b4a-5132-9110-37a0b42e16a3', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f02cf0ea-9f31-5290-85ff-b53f7288d8e0', 'speaking', 'Мені потрібна допомога.', 'Trebam pomoć.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f02cf0ea-9f31-5290-85ff-b53f7288d8e0', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('62e4b4f7-7f45-528b-8d82-bb41a990a127', 'speaking', 'У мене болить голова.', 'Boli me glava.', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '62e4b4f7-7f45-528b-8d82-bb41a990a127', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('32ea8229-b49c-5226-8bf5-814fbe1f04a7', v_lesson, 'У лікаря', 'Kod liječnice', 129, 'A0', 'health', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a85028c7-2a41-5a1d-82f3-a5f64ea1d124', '32ea8229-b49c-5226-8bf5-814fbe1f04a7', 'Liječnica', 'Što Vas boli?', 'Що у вас болить?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f1516e6e-c716-5526-b665-28d4c4dffbb1', '32ea8229-b49c-5226-8bf5-814fbe1f04a7', 'Pacijent', 'Boli me glava.', 'У мене болить голова.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('503273d2-2ac4-5b50-8c0e-760013e746cd', '32ea8229-b49c-5226-8bf5-814fbe1f04a7', 'Liječnica', 'Imate li temperaturu?', 'У вас є температура?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cd7ea2eb-f7b8-5f49-810a-a35d0b906c9d', '32ea8229-b49c-5226-8bf5-814fbe1f04a7', 'Pacijent', 'Da, malo.', 'Так, трохи.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('526fe055-9d30-5c0f-807f-750512a88aa2', '32ea8229-b49c-5226-8bf5-814fbe1f04a7', 'Liječnica', 'Izvolite recept. Pijte puno vode.', 'Ось рецепт. Пийте багато води.', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '32ea8229-b49c-5226-8bf5-814fbe1f04a7', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- Урок 30: +5 слів, сцена «В установі», 9 нових вправ
do $$
declare
  v_lesson constant uuid := 'b095637e-0644-507e-8f3d-d323483dd3e4';
  v_id uuid;
  v_pos int;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then
    raise notice 'Урок 30 не знайдено — пропускаю'; return;
  end if;
  if exists (select 1 from public.conversations where id = '8c85931f-d9ce-5e58-8636-6e5736f7d65a') then return; end if;  -- уже розширено
  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;

  -- нові слова
  select id into v_id from public.lexemes where lower(lemma) = lower('obrazac') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'obrazac'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('zahtjev') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zahtjev'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('datum rođenja') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'datum rođenja'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('potpis') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'potpis'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  select id into v_id from public.lexemes where lower(lemma) = lower('jezik') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jezik'; end if;
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  end if;
  -- вправи
  select id into v_id from public.lexemes where lower(lemma) = lower('zahtjev') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('eb148c8e-2b17-5201-b37a-738749781315', 'multiple_choice', 'Що означає «zahtjev»?', 'запит / заявка', '["адреса", "закордонний паспорт", "підпис", "запит / заявка"]'::jsonb, 'A0', 11, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'eb148c8e-2b17-5201-b37a-738749781315', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jezik') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e17ec58d-ee1f-52ca-8f8f-f8c58572dd8d', 'multiple_choice', 'Що означає «jezik»?', 'мова', '["закордонний паспорт", "прізвище", "підписати", "мова"]'::jsonb, 'A0', 12, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e17ec58d-ee1f-52ca-8f8f-f8c58572dd8d', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('potpis') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('de45a777-b9d6-54b1-9451-9a2a87418bca', 'multiple_choice', 'Як хорватською «підпис»?', 'potpis', '["potpis", "zahtjev", "potpisati", "jezik"]'::jsonb, 'A0', 13, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'de45a777-b9d6-54b1-9451-9a2a87418bca', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('datum rođenja') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f8c75a00-0d75-52b3-9334-f39616fb3d5d', 'type_answer', 'Напишіть хорватською: «дата народження»', 'datum rođenja', null, 'A0', 14, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f8c75a00-0d75-52b3-9334-f39616fb3d5d', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('obrazac') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('522f7afe-0454-55d6-b8cf-525bc693818f', 'type_answer', 'Напишіть хорватською: «бланк / анкета»', 'obrazac', null, 'A0', 15, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '522f7afe-0454-55d6-b8cf-525bc693818f', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5e7396c6-a05a-5f6c-b2ba-852284e468aa', 'sentence_builder', 'Складіть: «Де можна подати заяву?»', 'Gdje mogu predati zahtjev?', '["predati", "Gdje", "zahtjev?", "mogu"]'::jsonb, 'A0', 16, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5e7396c6-a05a-5f6c-b2ba-852284e468aa', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3ce56ee3-ff03-55fb-af01-6f0c30f6a863', 'listening', 'Прослухайте і складіть фразу', 'Ispunite ovaj obrazac.', '["obrazac.", "Ispunite", "ovaj"]'::jsonb, 'A0', 17, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3ce56ee3-ff03-55fb-af01-6f0c30f6a863', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('25d5cba1-378c-510c-a271-33eb6d5a7e9b', 'speaking', 'Підпишіть тут, будь ласка.', 'Potpišite ovdje, molim.', null, 'A0', 18, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '25d5cba1-378c-510c-a271-33eb6d5a7e9b', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7e1f8204-0b28-5cd5-b601-f031059dc5ed', 'speaking', 'Якою мовою?', 'Na kojem jeziku?', null, 'A0', 19, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7e1f8204-0b28-5cd5-b601-f031059dc5ed', v_pos, 'speaking');
  -- друга сцена діалогу
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8c85931f-d9ce-5e58-8636-6e5736f7d65a', v_lesson, 'В установі', 'U uredu', 130, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_v2');
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('20d1f5b5-a381-5733-92ec-2fb3fde096e6', '8c85931f-d9ce-5e58-8636-6e5736f7d65a', 'Službenik', 'Sljedeći, molim!', 'Наступний, будь ласка!', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a2aaa388-7740-5759-b26b-c35dd4a350a3', '8c85931f-d9ce-5e58-8636-6e5736f7d65a', 'Oleg', 'Dobar dan. Gdje mogu predati zahtjev?', 'Добрий день. Де можна подати заяву?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('15c5dfb2-217b-519f-8556-d01fdb590311', '8c85931f-d9ce-5e58-8636-6e5736f7d65a', 'Službenik', 'Ovdje. Ispunite ovaj obrazac.', 'Тут. Заповніть цю форму.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('aa833841-d039-556b-a855-893cceb0cffd', '8c85931f-d9ce-5e58-8636-6e5736f7d65a', 'Oleg', 'Na kojem jeziku?', 'Якою мовою?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('02a288a7-6e3e-55fc-8f63-22dd1b264df6', '8c85931f-d9ce-5e58-8636-6e5736f7d65a', 'Službenik', 'Na hrvatskom. Datum rođenja pišite ovdje.', 'Хорватською. Дату народження пишіть тут.', 5) on conflict (id) do nothing;
  update public.lessons set estimated_minutes = 12 where id = v_lesson;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'),
         ('conversation', '8c85931f-d9ce-5e58-8636-6e5736f7d65a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.');
end $$;

-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare
  v_short int; v_one_scene int; v_few_words int;
begin
  select count(*) into v_short from public.lessons l
   where l.level_code = 'A0' and l.status = 'PUBLISHED'
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') < 12;
  select count(*) into v_one_scene from public.lessons l
   where l.level_code = 'A0' and l.status = 'PUBLISHED'
     and (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') < 2;
  select count(*) into v_few_words from public.lessons l
   where l.level_code = 'A0' and l.status = 'PUBLISHED'
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'lexeme') < 8;
  if v_short > 0 then raise exception 'A0: % уроків мають менше 12 вправ', v_short; end if;
  if v_one_scene > 0 then raise exception 'A0: % уроків без другої сцени', v_one_scene; end if;
  if v_few_words > 0 then raise exception 'A0: % уроків мають менше 8 слів', v_few_words; end if;
  raise notice 'Готово: усі 30 уроків A0 розширено';
end $$;

commit;

-- Перевірка (окремим запитом після запуску):
-- select l.title_ua, l.estimated_minutes as хв,
--   (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'lexeme') as слів,
--   (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') as вправ,
--   (select count(*) from public.conversations c where c.lesson_id = l.id) as діалогів
-- from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
-- where l.level_code = 'A0' order by m.order_index, l.order_index;
