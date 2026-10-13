-- =====================================================================
-- Програма A1 · curriculum_a1_v1 · частина 2 з 2 · 2026-10-13
-- Згенеровано: python3 scripts/gen_curriculum_a1.py (не редагуйте вручну).
-- Запуск: Supabase → SQL Editor → вставити ВЕСЬ файл → Run. Спершу частина 1, потім частина 2.
--
--   * Модулі A1.6–A1.10: 25 уроків (№ 25–49), 50 діалогів (230 реплік), 300 вправ.
--   * Публікація 10 модулів і 13 тем граматики A1 (статус PUBLISHED: бета, як A0; носій ще не перевіряв).
--   * Самоперевірка всієї програми: 49 уроків.
--   * Потрібна частина 1 (20261013_curriculum_a1_v1_part1.sql).
--   * Наявні дані не видаляються. Повторний запуск безпечний.
-- =====================================================================

begin;

do $$
begin
  if not exists (select 1 from public.lessons where id = 'b69a8cca-4918-562f-8ae5-22f8d7ba2f76') then
    raise exception 'Спершу запустіть частину 1 (20261013_curriculum_a1_v1_part1.sql)';
  end if;
end $$;

-- Допоміжні функції (тимчасові: зникають після запуску)
create or replace function pg_temp.word(p_lesson uuid, p_lemma text, p_pos int) returns int language plpgsql as $f$
declare v_id uuid;
begin
  select id into v_id from public.lexemes where lower(lemma) = lower(p_lemma) and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', p_lemma; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (p_lesson, 'lexeme', v_id, p_pos + 1, 'vocabulary');
  return p_pos + 1;
end $f$;

create or replace function pg_temp.ex(p_lesson uuid, p_pos int, p_id uuid, p_type text, p_question text, p_answer text, p_options jsonb,
                                      p_level text, p_order int, p_status text, p_lemma text, p_skill text) returns int language plpgsql as $f$
declare v_id uuid;
begin
  if p_lemma is not null then
    select id into v_id from public.lexemes where lower(lemma) = lower(p_lemma) and status = 'PUBLISHED' order by created_at limit 1;
  end if;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values (p_id, p_type, p_question, p_answer, p_options, p_level, p_order, p_status, v_id) on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (p_lesson, 'exercise', p_id, p_pos + 1, p_skill);
  return p_pos + 1;
end $f$;

create or replace function pg_temp.turn(p_id uuid, p_conv uuid, p_speaker text, p_hr text, p_ua text, p_order int) returns void language sql as $f$
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values (p_id, p_conv, p_speaker, p_hr, p_ua, p_order) on conflict (id) do nothing;
$f$;

-- 5. Уроки A1, частина 2
-- A1.6 · урок 25: Мій робочий день
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'd813e9c0-2331-59d8-90f1-cea7e9a61c7d';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.6: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.6.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 25: Мій робочий день', 'Lekcija 25: Moj radni dan', '["Дізнатися робочий час і перерви", "Розповісти, що ви робите на роботі", "Поговорити з колегою"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'posao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ured', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolega', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolegica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šef', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sastanak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radno vrijeme', v_pos);
  v_pos := pg_temp.word(v_lesson, 'počinjati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'završavati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plaća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tvrtka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'klijent', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '376da6c2-bd0f-51f1-86c9-bbd5e98ec38c', 'fill_in_the_blank', 'Mi ___ u četiri.', 'završavamo', '["završavamo", "završavam", "završavaju", "završava"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2d4a76ae-caba-5132-a758-4fc6986eac57', 'multiple_choice', 'Що означає «ured»?', 'офіс / кабінет', '["заробітна плата", "закінчувати", "офіс / кабінет", "робочий час"]'::jsonb, 'A1', 2, 'PUBLISHED', 'ured', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0bf2334b-e3ba-5b0b-943f-2af2a2e9c920', 'multiple_choice', 'Що означає «klijent»?', 'клієнт', '["колега (жінка)", "клієнт", "робочий час", "офіс / кабінет"]'::jsonb, 'A1', 3, 'PUBLISHED', 'klijent', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b2f8c55b-73bb-5513-a2e0-3f097cb30ba2', 'multiple_choice', 'Як хорватською «починати»?', 'počinjati', '["šef", "ured", "plaća", "počinjati"]'::jsonb, 'A1', 4, 'PUBLISHED', 'počinjati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'df9ede8c-7a79-5f68-9391-cd3ddf6bd676', 'type_answer', 'Напишіть хорватською: «закінчувати»', 'završavati', null, 'A1', 5, 'PUBLISHED', 'završavati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0ecc5eb9-68c5-57c8-9aa2-8ed25a6535da', 'type_answer', 'Напишіть хорватською: «начальник / шеф»', 'šef', null, 'A1', 6, 'PUBLISHED', 'šef', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c630afa6-f631-578e-b53f-c92d52bb81c9', 'sentence_builder', 'Складіть: «Коли починається робочий день?»', 'Kada počinje radno vrijeme?', '["počinje", "radno", "Kada", "vrijeme?"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0281f85a-3edc-5098-be7f-508fc231210a', 'sentence_builder', 'Складіть: «Я працюю з клієнтами.»', 'Radim s klijentima.', '["s", "Radim", "klijentima."]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fdf7e45c-d4f6-5a71-8b16-b3197d88a41b', 'listening', 'Прослухайте і складіть фразу', 'U osam. Završavamo u četiri.', '["četiri.", "Završavamo", "osam.", "u", "U"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3c0171dd-93be-54ab-8dbf-87638491ec17', 'listening', 'Прослухайте і складіть фразу', 'Imamo danas sastanak u deset.', '["deset.", "u", "Imamo", "sastanak", "danas"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c9e3a51e-6ffe-5b1a-b517-3975926a468b', 'speaking', 'Я працюю в офісі.', 'Radim u uredu.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '141e3b85-7224-5665-8472-1b03ee1b37ce', 'speaking', 'Нарада о десятій.', 'Sastanak je u deset.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2b7fa201-2f79-57f7-8d13-862e4afa2659', v_lesson, 'Перший день', 'Prvi dan', 1251, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('0c7cac22-26d4-546c-8936-040577cd86d0', '2b7fa201-2f79-57f7-8d13-862e4afa2659', 'Šefica', 'Dobrodošli! Ovo je Vaš stol.', 'Ласкаво просимо! Це ваш стіл.', 1);
  perform pg_temp.turn('ef553f96-756a-58d2-8b83-8cf38f32934c', '2b7fa201-2f79-57f7-8d13-862e4afa2659', 'Oleg', 'Hvala. Kada počinje radno vrijeme?', 'Дякую. Коли починається робочий день?', 2);
  perform pg_temp.turn('c5ec4e9c-2da5-579a-bcd3-49a25c6fb691', '2b7fa201-2f79-57f7-8d13-862e4afa2659', 'Šefica', 'U osam. Završavamo u četiri.', 'О восьмій. Закінчуємо о четвертій.', 3);
  perform pg_temp.turn('8309795c-9217-5558-b5ee-cc79a2745863', '2b7fa201-2f79-57f7-8d13-862e4afa2659', 'Oleg', 'A pauza za ručak?', 'А обідня перерва?', 4);
  perform pg_temp.turn('58bd5e4a-8594-54ca-a9bc-849451230880', '2b7fa201-2f79-57f7-8d13-862e4afa2659', 'Šefica', 'U podne, pola sata.', 'Опівдні, пів години.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9a28aaba-c0d9-5446-af55-b43ba17dadb2', v_lesson, 'Кава з колегою', 'Kava s kolegicom', 1252, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('8927c548-5859-5e60-a60f-0fdcc4d17e01', '9a28aaba-c0d9-5446-af55-b43ba17dadb2', 'Kolegica', 'Gdje radiš, u kojem odjelu?', 'Де ти працюєш, у якому відділі?', 1);
  perform pg_temp.turn('b7007915-77f2-5be8-a190-e0123f812f06', '9a28aaba-c0d9-5446-af55-b43ba17dadb2', 'Oleg', 'U prodaji. Radim s klijentima.', 'У відділі продажів. Працюю з клієнтами.', 2);
  perform pg_temp.turn('5e4fcbe0-aa7b-5294-8cca-9afe8ae0ff5b', '9a28aaba-c0d9-5446-af55-b43ba17dadb2', 'Kolegica', 'Sviđa li ti se?', 'Тобі подобається?', 3);
  perform pg_temp.turn('916a5da6-7084-5a4f-a923-da2d88f44a5b', '9a28aaba-c0d9-5446-af55-b43ba17dadb2', 'Oleg', 'Da, kolege su jako dragi.', 'Так, колеги дуже приємні.', 4);
  perform pg_temp.turn('128bddde-57c5-5ce2-9a07-577c8545fc04', '9a28aaba-c0d9-5446-af55-b43ba17dadb2', 'Kolegica', 'Imamo danas sastanak u deset.', 'Сьогодні в нас нарада о десятій.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 26: Правила на роботі
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '99088d92-0f0c-52c2-b51f-548d903fc9ef';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.6: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.6.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 26: Правила на роботі', 'Lekcija 26: Pravila na poslu', '["Запитати, що можна, а що ні", "Повідомити, що ви захворіли", "Вживати smijem, moram, mogu"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'smjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'morati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pušiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bolovanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potvrda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'liječnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slobodan dan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godišnji odmor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pitati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kasniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šef', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2a95e246-90ea-55c7-bad1-f091edaa8c01', 'fill_in_the_blank', 'Vi ovdje ne ___ pušiti.', 'smijete', '["smijete", "smijem", "smiju", "smije"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a7be2822-f35d-5f4d-9786-4c1b58c590a0', 'multiple_choice', 'Що означає «pitati»?', 'питати', '["вихідний день", "питати", "начальник / шеф", "довідка / підтвердження"]'::jsonb, 'A1', 2, 'PUBLISHED', 'pitati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c356ad55-2057-5213-90ac-0541f15859f2', 'multiple_choice', 'Що означає «pušiti»?', 'курити', '["курити", "мусити / бути зобов''язаним", "вихідний день", "сміти, мати дозвіл"]'::jsonb, 'A1', 3, 'PUBLISHED', 'pušiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '66276c5f-dd5c-5c3d-86e0-03a47508884f', 'multiple_choice', 'Як хорватською «мусити / бути зобов''язаним»?', 'morati', '["šef", "godišnji odmor", "potvrda", "morati"]'::jsonb, 'A1', 4, 'PUBLISHED', 'morati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '59fea773-0bef-5291-9768-5e29f8997046', 'type_answer', 'Напишіть хорватською: «начальник / шеф»', 'šef', null, 'A1', 5, 'PUBLISHED', 'šef', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd7ac6d65-acb0-575b-967d-1dee47d502bd', 'type_answer', 'Напишіть хорватською: «лікарняний»', 'bolovanje', null, 'A1', 6, 'PUBLISHED', 'bolovanje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a00038d0-ab2f-5214-a942-bd5bbc7bf5de', 'sentence_builder', 'Складіть: «Тут можна курити?»', 'Smijem li ovdje pušiti?', '["li", "ovdje", "Smijem", "pušiti?"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '46044d85-b534-570e-99f2-e242282c130f', 'sentence_builder', 'Складіть: «Мені треба принести довідку?»', 'Trebam li donijeti potvrdu?', '["donijeti", "Trebam", "potvrdu?", "li"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd0da34f3-6ff5-5316-97d6-3dbd704bb2e6', 'listening', 'Прослухайте і складіть фразу', 'Ne smiješ. Moraš izaći van.', '["izaći", "Moraš", "van.", "smiješ.", "Ne"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '317d7242-e8a1-547f-a674-4559d6b34372', 'listening', 'Прослухайте і складіть фразу', 'Žao mi je. Morate ići liječniku.', '["mi", "Žao", "ići", "Morate", "je.", "liječniku."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '09255bad-dbd4-5d34-b393-ed496c1e1e30', 'speaking', 'Мені треба йти до лікаря.', 'Moram ići liječniku.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1013b77d-2cde-5442-ae6e-5bd1116d362f', 'speaking', 'Можна працювати з дому?', 'Smijem li raditi od kuće?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2ac7ca24-cf19-5fc8-8b74-0aec42f4e427', v_lesson, 'Що можна, а що ні', 'Što smijem, a što ne', 1261, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('7733eecd-1d88-5844-9242-e8a927b5129b', '2ac7ca24-cf19-5fc8-8b74-0aec42f4e427', 'Oleg', 'Smijem li ovdje pušiti?', 'Тут можна курити?', 1);
  perform pg_temp.turn('5e086a43-d714-527b-bae2-b58ab3b3c17f', '2ac7ca24-cf19-5fc8-8b74-0aec42f4e427', 'Kolega', 'Ne smiješ. Moraš izaći van.', 'Не можна. Треба вийти надвір.', 2);
  perform pg_temp.turn('99297345-0060-54bb-b285-da19af4e03c3', '2ac7ca24-cf19-5fc8-8b74-0aec42f4e427', 'Oleg', 'A smijem li raditi od kuće?', 'А можна працювати з дому?', 3);
  perform pg_temp.turn('1355be24-cca3-58f4-a542-a76ec9798dc1', '2ac7ca24-cf19-5fc8-8b74-0aec42f4e427', 'Kolega', 'Petkom smiješ, ali moraš pitati šefa.', 'По п’ятницях можна, але треба спитати шефа.', 4);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e17a0f51-adeb-53d9-801e-6da66b9cb36e', v_lesson, 'Лікарняний', 'Bolovanje', 1262, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('f587ccce-8fdf-5360-96e9-5a380d31d39d', 'e17a0f51-adeb-53d9-801e-6da66b9cb36e', 'Oksana', 'Dobro jutro. Bolesna sam i danas ne mogu doći.', 'Доброго ранку. Я захворіла й сьогодні не можу прийти.', 1);
  perform pg_temp.turn('64af9052-7aba-5d09-85b3-f7dd231d807a', 'e17a0f51-adeb-53d9-801e-6da66b9cb36e', 'Šef', 'Žao mi je. Morate ići liječniku.', 'Мені шкода. Вам треба піти до лікаря.', 2);
  perform pg_temp.turn('f4303b48-64d1-5253-b2ac-b609800124a6', 'e17a0f51-adeb-53d9-801e-6da66b9cb36e', 'Oksana', 'Znam. Trebam li donijeti potvrdu?', 'Знаю. Мені треба принести довідку?', 3);
  perform pg_temp.turn('b1d19147-7de6-5901-b517-73eaf3665504', 'e17a0f51-adeb-53d9-801e-6da66b9cb36e', 'Šef', 'Da, za bolovanje. Ozdravite brzo!', 'Так, для лікарняного. Одужуйте швидше!', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 27: Співбесіда
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '92858dbe-ede1-5bc5-b80a-c796c5598019';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.6: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.6.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 27: Співбесіда', 'Lekcija 27: Razgovor za posao', '["Розповісти про свій досвід", "Запитати про зарплату й договір", "Відповідати на питання kakav, koliko, kada"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'razgovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iskustvo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zanimanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plaća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaposliti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jezik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'znati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'govoriti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'početi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vozačka dozvola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vozač', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c948e1d1-4d3f-587a-bd50-30a748d3fe95', 'fill_in_the_blank', '___ dugo živite ovdje?', 'Koliko', '["Koliko", "Gdje", "Kada", "Tko"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '788bd2d8-e0cd-5b5c-aef0-2f1207b190db', 'multiple_choice', 'Що означає «vozačka dozvola»?', 'водійське посвідчення', '["водійське посвідчення", "почати", "досвід", "розмова / бесіда"]'::jsonb, 'A1', 2, 'PUBLISHED', 'vozačka dozvola', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e8e3ec0d-c739-5eec-af6b-579fad2ebd38', 'multiple_choice', 'Що означає «plaća»?', 'заробітна плата', '["говорити", "знати", "досвід", "заробітна плата"]'::jsonb, 'A1', 3, 'PUBLISHED', 'plaća', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '049e768d-2dd6-5998-9240-a88bd0fc640f', 'multiple_choice', 'Як хорватською «розмова / бесіда»?', 'razgovor', '["govoriti", "ugovor", "razgovor", "vozač"]'::jsonb, 'A1', 4, 'PUBLISHED', 'razgovor', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'df67affc-9566-567a-9ad3-20a19a745ded', 'type_answer', 'Напишіть хорватською: «водій»', 'vozač', null, 'A1', 5, 'PUBLISHED', 'vozač', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'da33aaba-6d62-5aab-86d7-377a37055e02', 'type_answer', 'Напишіть хорватською: «говорити»', 'govoriti', null, 'A1', 6, 'PUBLISHED', 'govoriti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c7d9a4b8-3bf1-52a7-a143-e6ef562d0234', 'sentence_builder', 'Складіть: «Я живу тут два роки.»', 'Živim ovdje dvije godine.', '["ovdje", "dvije", "Živim", "godine."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cbd34969-1eb6-5c26-80f6-a218c847a6b5', 'sentence_builder', 'Складіть: «Коли я можу почати?»', 'Kada mogu početi?', '["Kada", "početi?", "mogu"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4ce7e331-4f8c-5e56-b769-1412144e84a7', 'listening', 'Прослухайте і складіть фразу', 'Kakvo iskustvo imate?', '["imate?", "iskustvo", "Kakvo"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '740ada9b-dd32-5a71-9d4a-15889adfb066', 'listening', 'Прослухайте і складіть фразу', 'Kolika je plaća?', '["je", "Kolika", "plaća?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fc8cb2be-9b18-57f1-979b-e5ce5c1b9e57', 'speaking', 'Який у вас досвід?', 'Kakvo iskustvo imate?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7fad616e-f591-58f8-b20e-8d366f075df0', 'speaking', 'Я говорю українською й англійською.', 'Govorim ukrajinski i engleski.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2ce70360-9c38-58f4-b7b0-f810fa7949af', v_lesson, 'Досвід', 'Iskustvo', 1271, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('5ac6a959-2efd-516c-bbbe-3879f02fc2d8', '2ce70360-9c38-58f4-b7b0-f810fa7949af', 'Direktor', 'Odakle ste i koliko dugo živite u Hrvatskoj?', 'Звідки ви і як довго живете в Хорватії?', 1);
  perform pg_temp.turn('5fb860ac-0f11-5db9-a51c-3a031c42726b', '2ce70360-9c38-58f4-b7b0-f810fa7949af', 'Taras', 'Iz Ukrajine. Živim ovdje dvije godine.', 'З України. Живу тут два роки.', 2);
  perform pg_temp.turn('1777aff4-8846-52e4-94a3-de3d2d315286', '2ce70360-9c38-58f4-b7b0-f810fa7949af', 'Direktor', 'Kakvo iskustvo imate?', 'Який у вас досвід?', 3);
  perform pg_temp.turn('0b618667-1501-51e4-a39e-3abf413de548', '2ce70360-9c38-58f4-b7b0-f810fa7949af', 'Taras', 'Radim kao vozač već pet godina.', 'Я працюю водієм уже п’ять років.', 4);
  perform pg_temp.turn('10f40966-5c02-5025-9868-8930748d635e', '2ce70360-9c38-58f4-b7b0-f810fa7949af', 'Direktor', 'Imate li vozačku dozvolu za kamion?', 'У вас є посвідчення на вантажівку?', 5);
  perform pg_temp.turn('ebbb1851-8eba-5d33-8126-21bb037f814c', '2ce70360-9c38-58f4-b7b0-f810fa7949af', 'Taras', 'Imam, kategoriju C.', 'Так, категорії C.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('721e1ea0-da62-526e-bb59-49509e2564f0', v_lesson, 'Умови', 'Uvjeti', 1272, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('c0a0be9e-c729-506a-a264-b843a0ce0685', '721e1ea0-da62-526e-bb59-49509e2564f0', 'Taras', 'Kada mogu početi?', 'Коли я можу почати?', 1);
  perform pg_temp.turn('81764251-5bd7-5ef3-84d6-101f259b7c74', '721e1ea0-da62-526e-bb59-49509e2564f0', 'Direktor', 'Od prvog. Ugovor je na godinu dana.', 'З першого числа. Договір на рік.', 2);
  perform pg_temp.turn('ca1383dc-d373-5e27-9fa3-ef939f545eda', '721e1ea0-da62-526e-bb59-49509e2564f0', 'Taras', 'Kolika je plaća?', 'Яка зарплата?', 3);
  perform pg_temp.turn('43adaabc-2976-58f8-880a-fe879c5ceb7f', '721e1ea0-da62-526e-bb59-49509e2564f0', 'Direktor', 'Tisuću dvjesto eura neto.', 'Тисяча двісті євро чистими.', 4);
  perform pg_temp.turn('efa19384-5189-5bf6-9a08-7c9cd22dc09d', '721e1ea0-da62-526e-bb59-49509e2564f0', 'Taras', 'To mi odgovara. Hvala!', 'Мене це влаштовує. Дякую!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 28: Договір і зарплата
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '4d6f3498-2cc5-54a0-b4e4-c66add71ef12';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.6: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.6.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 28: Договір і зарплата', 'Lekcija 28: Ugovor i plaća', '["Зрозуміти умови договору", "Запитати про зарплату й зміни", "Вживати trebam, moram, mogu"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'probni rad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'puno radno vrijeme', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smjena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radna dozvola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'privremena zaštita', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bruto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'porez', v_pos);
  v_pos := pg_temp.word(v_lesson, 'isplata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prekovremeni sati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'platna lista', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posebno', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'acc696ac-9bd6-501a-978c-8875209c4c38', 'fill_in_the_blank', 'Trebate li radnu dozvolu? — Ne, ne ___.', 'trebam', '["treba", "trebaš", "trebaju", "trebam"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '92584266-9889-5028-aa5e-52b0ed17256c', 'multiple_choice', 'Що означає «prekovremeni sati»?', 'понаднормові години', '["понаднормові години", "окремо; особливо", "повний робочий день", "тимчасовий захист"]'::jsonb, 'A1', 2, 'PUBLISHED', 'prekovremeni sati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4eba8cd3-b2a6-551a-b81f-aeed7b2b2be9', 'multiple_choice', 'Що означає «probni rad»?', 'випробувальний термін', '["виплата / зняття", "випробувальний термін", "зміна (на роботі)", "повний робочий день"]'::jsonb, 'A1', 3, 'PUBLISHED', 'probni rad', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4ee23ec0-9cbd-5e76-b0bc-d72cfeb849c4', 'multiple_choice', 'Як хорватською «розрахунковий листок»?', 'platna lista', '["privremena zaštita", "platna lista", "radna dozvola", "posebno"]'::jsonb, 'A1', 4, 'PUBLISHED', 'platna lista', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '86acebb5-2784-5b7e-8ff3-3904ea86695d', 'type_answer', 'Напишіть хорватською: «податок»', 'porez', null, 'A1', 5, 'PUBLISHED', 'porez', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2adf115f-3e97-50ac-abd0-6787cf81a312', 'type_answer', 'Напишіть хорватською: «зміна (на роботі)»', 'smjena', null, 'A1', 6, 'PUBLISHED', 'smjena', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '31366ef3-906a-5695-93ac-53d23ecbcd81', 'sentence_builder', 'Складіть: «Це повний робочий день?»', 'Je li puno radno vrijeme?', '["Je", "vrijeme?", "radno", "puno", "li"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9b575fa2-b08b-51c3-80b3-a0209b648b2b', 'sentence_builder', 'Складіть: «Зарплата брутто чи нетто?»', 'Je li plaća bruto ili neto?', '["li", "bruto", "Je", "ili", "neto?", "plaća"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0727828f-549b-58b0-bc42-6eb903a99b02', 'listening', 'Прослухайте і складіть фразу', 'Da, osam sati dnevno. Radimo u dvije smjene.', '["dvije", "smjene.", "sati", "Radimo", "u", "dnevno.", "osam", "Da,"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd8c5e036-13ff-594f-93d7-98b689d73ea2', 'listening', 'Прослухайте і складіть фразу', 'A prekovremeni sati?', '["A", "sati?", "prekovremeni"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f285757-1361-5f73-8568-dac27b4f5ed7', 'speaking', 'Мені потрібен дозвіл на роботу?', 'Trebam li radnu dozvolu?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c319f5a3-6544-51fa-9e82-8fdfc9adac8c', 'speaking', 'Коли виплата?', 'Kada je isplata?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('982110e5-9fda-5d21-9c81-54b064cf657e', v_lesson, 'Договір', 'Ugovor o radu', 1281, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('f290648f-db0f-5951-abb1-1882c5cc77d9', '982110e5-9fda-5d21-9c81-54b064cf657e', 'Šefica', 'Ovo je Vaš ugovor. Prvo je probni rad, tri mjeseca.', 'Це ваш договір. Спочатку випробувальний термін, три місяці.', 1);
  perform pg_temp.turn('ac645499-b639-5a9f-94fe-418a1e5bfd36', '982110e5-9fda-5d21-9c81-54b064cf657e', 'Oleg', 'Je li puno radno vrijeme?', 'Це повний робочий день?', 2);
  perform pg_temp.turn('ef322b2a-b3d9-5135-80c3-0187f6030401', '982110e5-9fda-5d21-9c81-54b064cf657e', 'Šefica', 'Da, osam sati dnevno. Radimo u dvije smjene.', 'Так, вісім годин на день. Працюємо у дві зміни.', 3);
  perform pg_temp.turn('51eda58c-5ca3-51e4-a41b-6ec013b7a408', '982110e5-9fda-5d21-9c81-54b064cf657e', 'Oleg', 'Trebam li radnu dozvolu?', 'Мені потрібен дозвіл на роботу?', 4);
  perform pg_temp.turn('9919c1ed-7642-5bbb-9afd-51c6c0a5555d', '982110e5-9fda-5d21-9c81-54b064cf657e', 'Šefica', 'Ne trebate, imate privremenu zaštitu.', 'Не потрібен, у вас тимчасовий захист.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('88ae3d58-6389-5fdd-a95e-fe4efdde5c51', v_lesson, 'Зарплата', 'Plaća', 1282, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('32afd68b-26d5-5e03-b8b7-2062dc14c022', '88ae3d58-6389-5fdd-a95e-fe4efdde5c51', 'Oleg', 'Je li plaća bruto ili neto?', 'Зарплата брутто чи нетто?', 1);
  perform pg_temp.turn('8aa50f94-97d6-526c-8c56-f22015c4cb87', '88ae3d58-6389-5fdd-a95e-fe4efdde5c51', 'Računovotkinja', 'Neto, poslije poreza. Isplata je do desetog u mjesecu.', 'Нетто, після податків. Виплата — до десятого числа.', 2);
  perform pg_temp.turn('6b54580b-6264-577d-b6c8-8f0b1cbff206', '88ae3d58-6389-5fdd-a95e-fe4efdde5c51', 'Oleg', 'A prekovremeni sati?', 'А понаднормові години?', 3);
  perform pg_temp.turn('dadcb5f4-fb30-567e-a69f-3d25c8bc0318', '88ae3d58-6389-5fdd-a95e-fe4efdde5c51', 'Računovotkinja', 'Plaćaju se posebno. Sve piše na platnoj listi.', 'Оплачуються окремо. Усе написано в розрахунковому листку.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 29: Дзвінок на роботу
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'e806dd39-4d38-5781-ad2d-949961dd95f9';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.6: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.6.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 29: Дзвінок на роботу', 'Lekcija 29: Telefonski poziv', '["Попросити до телефону потрібну людину", "Попередити колегу, що не прийдете", "Вживати mogu, hoću, ne mogu"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'nazvati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zauzet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kasnije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poruka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ostaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tajnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'javiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'videopoziv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'link', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mail', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bolestan', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a39a01dc-d767-59d3-b582-7a2495c9b79b', 'fill_in_the_blank', 'Oni ___ razgovarati s Vama.', 'hoće', '["hoću", "hoćemo", "hoće", "hoćeš"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ef5ff88d-493e-5d52-8865-16aff18a5707', 'multiple_choice', 'Що означає «javiti se»?', 'обізватися; відповісти (на дзвінок); зголоситися', '["електронний лист; імейл", "подзвонити / назвати", "обізватися; відповісти (на дзвінок); зголоситися", "відеодзвінок"]'::jsonb, 'A1', 2, 'PUBLISHED', 'javiti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bb6e6548-088c-59c6-906f-863c28a2df2d', 'multiple_choice', 'Що означає «videopoziv»?', 'відеодзвінок', '["повідомлення", "залишити", "відеодзвінок", "пізніше"]'::jsonb, 'A1', 3, 'PUBLISHED', 'videopoziv', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a5f94b16-bde3-5c7b-a1a5-2c8bc28ca42c', 'multiple_choice', 'Як хорватською «хворий»?', 'bolestan', '["link", "videopoziv", "bolestan", "javiti se"]'::jsonb, 'A1', 4, 'PUBLISHED', 'bolestan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7253a1a2-2572-5ae9-b615-8e69d91fa53f', 'type_answer', 'Напишіть хорватською: «залишити»', 'ostaviti', null, 'A1', 5, 'PUBLISHED', 'ostaviti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8dbf3c6f-22a0-54e2-b5ff-f44d4d8456c1', 'type_answer', 'Напишіть хорватською: «повідомлення»', 'poruka', null, 'A1', 6, 'PUBLISHED', 'poruka', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bcdba6ef-02f0-5984-b99d-90fc63f0e78a', 'sentence_builder', 'Складіть: «Можете подзвонити пізніше?»', 'Možete li nazvati kasnije?', '["kasnije?", "nazvati", "Možete", "li"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4c6c158e-1495-56ea-a513-971c51184b68', 'sentence_builder', 'Складіть: «Я не можу прийти на нараду.»', 'Ne mogu doći na sastanak.', '["mogu", "doći", "Ne", "sastanak.", "na"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6306e5a6-9263-56e8-a172-e63c689ca021', 'listening', 'Прослухайте і складіть фразу', 'Nažalost, sada je zauzet.', '["zauzet.", "Nažalost,", "je", "sada"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c02b773-7d8e-5207-b273-f32dc1c81dcc', 'listening', 'Прослухайте і складіть фразу', 'Mogu, pošalji mi link.', '["pošalji", "link.", "Mogu,", "mi"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5775ef09-8773-5ded-9d2e-bb6f2b968470', 'speaking', 'Можу я поговорити з паном Бабичем?', 'Mogu li razgovarati s gospodinom Babićem?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8f480e6a-00a9-5315-bdb0-76011dec2d41', 'speaking', 'Подзвоніть мені, будь ласка.', 'Nazovite me, molim.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('92864bdd-493f-5304-9b90-c78683c3bd65', v_lesson, 'Дзвінок в офіс', 'Poziv u ured', 1291, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('2b9fad62-02c2-500f-941b-49e1cc1eb082', '92864bdd-493f-5304-9b90-c78683c3bd65', 'Tajnica', 'Tvrtka Adria, dobar dan.', 'Компанія «Адрія», добрий день.', 1);
  perform pg_temp.turn('6780343a-1f8c-5d56-a84c-83768045ed65', '92864bdd-493f-5304-9b90-c78683c3bd65', 'Oleg', 'Dobar dan, ovdje Oleg Kovalenko. Mogu li razgovarati s gospodinom Babićem?', 'Добрий день, це Олег Коваленко. Можу я поговорити з паном Бабичем?', 2);
  perform pg_temp.turn('b713c223-59be-5dac-bb22-a5718c737a0a', '92864bdd-493f-5304-9b90-c78683c3bd65', 'Tajnica', 'Nažalost, sada je zauzet. Možete li nazvati kasnije?', 'На жаль, зараз він зайнятий. Можете подзвонити пізніше?', 3);
  perform pg_temp.turn('d405dcc9-889b-5ee2-bdcc-104c44b7392e', '92864bdd-493f-5304-9b90-c78683c3bd65', 'Oleg', 'Mogu. Ili mu ostavite poruku da me nazove.', 'Можу. Або передайте йому, щоб він мені передзвонив.', 4);
  perform pg_temp.turn('c4816709-85b3-51b8-b7d3-d4276c66014d', '92864bdd-493f-5304-9b90-c78683c3bd65', 'Tajnica', 'Naravno. Koji je Vaš broj?', 'Звісно. Який ваш номер?', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('058d9554-1cca-5329-baba-46b470cad59c', v_lesson, 'Повідомлення колезі', 'Poruka kolegi', 1292, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('1eed44e6-7c3c-5eb8-a2a9-2182c68c5e25', '058d9554-1cca-5329-baba-46b470cad59c', 'Iryna', 'Bok Marko, ne mogu doći na sastanak. Bolesna sam.', 'Привіт, Марку, я не можу прийти на нараду. Я захворіла.', 1);
  perform pg_temp.turn('5afd2919-d517-5894-918a-5f6e0de864f9', '058d9554-1cca-5329-baba-46b470cad59c', 'Marko', 'Nema problema. Možeš li se uključiti na videopoziv?', 'Без проблем. Можеш підключитися відеодзвінком?', 2);
  perform pg_temp.turn('2cec44f7-ab7b-557e-87fb-85b0f3da81b1', '058d9554-1cca-5329-baba-46b470cad59c', 'Iryna', 'Mogu, pošalji mi link.', 'Можу, надішли мені посилання.', 3);
  perform pg_temp.turn('52d945db-8c3c-555c-ad46-f173cbf816e6', '058d9554-1cca-5329-baba-46b470cad59c', 'Marko', 'Šaljem ti mail. Javi se ako nešto trebaš.', 'Надсилаю тобі мейл. Озвися, якщо щось треба.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 30: Запис до лікаря
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '08e31e8b-f8f7-5a80-89ed-093bc68dae03';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.7: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.7.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 30: Запис до лікаря', 'Lekcija 30: Naručivanje kod liječnika', '["Записатися до лікаря телефоном", "Пояснити, що болить", "Вживати boli me, bole me"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'dom zdravlja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pregled', v_pos);
  v_pos := pg_temp.word(v_lesson, 'termin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zdravstveno osiguranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'boljeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grlo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'leđa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'temperatura', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kašalj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'liječnica', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '7bdce927-ed8e-5de6-95d8-afafb4b1ce16', 'fill_in_the_blank', 'Boli ___ glava.', 'me', '["ja", "meni", "moja", "me"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7f96c842-4814-55eb-a367-86352f3b19cc', 'multiple_choice', 'Що означає «pregled»?', 'медичний огляд / обстеження', '["медичне страхування", "температура (жар)", "медичний огляд / обстеження", "біль"]'::jsonb, 'A1', 2, 'PUBLISHED', 'pregled', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4fad1b78-9915-5bc8-8614-333bfd9ade5f', 'multiple_choice', 'Що означає «glava»?', 'голова', '["медичне страхування", "голова", "горло", "біль"]'::jsonb, 'A1', 3, 'PUBLISHED', 'glava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bb8a2807-ed77-5938-83a3-d8e604d01651', 'multiple_choice', 'Як хорватською «болити»?', 'boljeti', '["leđa", "boljeti", "zdravstveno osiguranje", "termin"]'::jsonb, 'A1', 4, 'PUBLISHED', 'boljeti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3ec442cd-e8e7-589e-9d5f-05df37c9c79b', 'type_answer', 'Напишіть хорватською: «спина»', 'leđa', null, 'A1', 5, 'PUBLISHED', 'leđa', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2fa5b21f-18ed-5181-ad37-8a2a63571c71', 'type_answer', 'Напишіть хорватською: «кашель»', 'kašalj', null, 'A1', 6, 'PUBLISHED', 'kašalj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '52a6b3e6-34ca-5a52-8bc1-a9e879089d5e', 'sentence_builder', 'Складіть: «Мені потрібен запис до лікаря.»', 'Trebam termin kod liječnika.', '["Trebam", "liječnika.", "kod", "termin"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '46613f26-9f49-5c7a-b838-081f95985805', 'sentence_builder', 'Складіть: «У мене болить горло.»', 'Boli me grlo.', '["Boli", "grlo.", "me"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '95b1f432-d12d-5cae-afad-397f64b66b72', 'listening', 'Прослухайте і складіть фразу', 'Imate li zdravstveno osiguranje?', '["Imate", "zdravstveno", "osiguranje?", "li"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e914f118-aaca-5626-bf54-a77d9e16c051', 'listening', 'Прослухайте і складіть фразу', 'Malo, trideset sedam i pet.', '["Malo,", "pet.", "sedam", "i", "trideset"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6c012a8a-54cc-5221-a3e5-5bc5290c7d38', 'speaking', 'У мене болить спина.', 'Bole me leđa.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9194e3f8-b260-579b-bc76-8aaae80979c1', 'speaking', 'У мене кашель.', 'Imam kašalj.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b94f5c8b-ab08-54c3-9968-ee219046202d', v_lesson, 'Телефоном', 'Telefonom', 1301, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('66f51ca0-cf56-59a0-b89e-3f7a6038a859', 'b94f5c8b-ab08-54c3-9968-ee219046202d', 'Sestra', 'Dom zdravlja, izvolite.', 'Поліклініка, слухаю.', 1);
  perform pg_temp.turn('a9d46994-f9fc-553a-9866-b415621b9e63', 'b94f5c8b-ab08-54c3-9968-ee219046202d', 'Olena', 'Dobar dan, trebam termin kod doktorice Babić.', 'Добрий день, мені потрібен запис до лікарки Бабич.', 2);
  perform pg_temp.turn('60c61907-d43e-54fd-8137-30d4243ea2d7', 'b94f5c8b-ab08-54c3-9968-ee219046202d', 'Sestra', 'Imate li zdravstveno osiguranje?', 'У вас є медичне страхування?', 3);
  perform pg_temp.turn('5235220c-5c67-5c03-ab00-b1d317eb854e', 'b94f5c8b-ab08-54c3-9968-ee219046202d', 'Olena', 'Imam.', 'Так.', 4);
  perform pg_temp.turn('2dc2b9a2-92b0-5659-a996-f62d24bbbd62', 'b94f5c8b-ab08-54c3-9968-ee219046202d', 'Sestra', 'Može sutra u devet i petnaest.', 'Можна завтра о дев’ятій п’ятнадцять.', 5);
  perform pg_temp.turn('a482d338-39c3-5951-aa77-4e9efd4450df', 'b94f5c8b-ab08-54c3-9968-ee219046202d', 'Olena', 'Odlično, hvala.', 'Чудово, дякую.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('85984398-4598-5d46-a4ce-1b81b0d7d502', v_lesson, 'У кабінеті', 'U ordinaciji', 1302, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('428f122a-a95b-50d1-a5d6-d7f088579e23', '85984398-4598-5d46-a4ce-1b81b0d7d502', 'Doktorica', 'Što Vas boli?', 'Що у вас болить?', 1);
  perform pg_temp.turn('6b51a72f-adcf-5212-a249-a71a51b2f02c', '85984398-4598-5d46-a4ce-1b81b0d7d502', 'Olena', 'Boli me grlo i imam kašalj.', 'У мене болить горло і кашель.', 2);
  perform pg_temp.turn('6c761c03-9c3d-52ce-bba7-a907f167069d', '85984398-4598-5d46-a4ce-1b81b0d7d502', 'Doktorica', 'Imate li temperaturu?', 'У вас є температура?', 3);
  perform pg_temp.turn('58e8b581-8cac-50bd-95e3-6b954f49e641', '85984398-4598-5d46-a4ce-1b81b0d7d502', 'Olena', 'Malo, trideset sedam i pet.', 'Трохи, тридцять сім і п’ять.', 4);
  perform pg_temp.turn('d68d89b0-b4ee-579f-8819-bd3060523028', '85984398-4598-5d46-a4ce-1b81b0d7d502', 'Doktorica', 'Otvorite usta, molim. Da vidim.', 'Відкрийте рот, будь ласка. Подивимося.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 31: В аптеці
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '123e68fa-291f-5ad6-8403-51db7020d641';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.7: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.7.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 31: В аптеці', 'Lekcija 31: U ljekarni', '["Купити ліки від застуди", "Зрозуміти, як приймати ліки", "Розуміти поради: uzmite, pijte"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'ljekarna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljekarnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lijek', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tableta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sirup protiv kašlja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'recept', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lijek protiv bolova', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prehlada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uzimati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dnevno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'voda', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd08e89db-d7b1-518e-acb9-b4b0720bc4f7', 'fill_in_the_blank', '___ jednu tabletu dnevno.', 'Uzmite', '["Uzeti", "Uzmem", "Uzme", "Uzmite"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a2a7722-367b-5670-a9cd-de420e2c933a', 'multiple_choice', 'Що означає «sirup protiv kašlja»?', 'сироп від кашлю', '["сироп від кашлю", "аптека", "ліки / медикамент", "застуда"]'::jsonb, 'A1', 2, 'PUBLISHED', 'sirup protiv kašlja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c1f67a24-f169-55db-b8d7-f482aaa28de1', 'multiple_choice', 'Що означає «lijek protiv bolova»?', 'знеболювальне', '["знеболювальне", "щодня; на день", "аптека", "вода"]'::jsonb, 'A1', 3, 'PUBLISHED', 'lijek protiv bolova', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a29bb569-743f-5894-89d2-e2b3d57aa777', 'multiple_choice', 'Як хорватською «рецепт»?', 'recept', '["ljekarnik", "ljekarna", "recept", "tableta"]'::jsonb, 'A1', 4, 'PUBLISHED', 'recept', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'deb408de-142a-564e-8b1c-164ce0b90c08', 'type_answer', 'Напишіть хорватською: «таблетка»', 'tableta', null, 'A1', 5, 'PUBLISHED', 'tableta', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4047ce55-80e7-5dd9-9d4d-bfba6afce5eb', 'type_answer', 'Напишіть хорватською: «застуда»', 'prehlada', null, 'A1', 6, 'PUBLISHED', 'prehlada', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '13b92aed-7e0f-515b-b1a3-dbee0922c936', 'sentence_builder', 'Складіть: «У вас є щось від застуди?»', 'Imate li nešto za prehladu?', '["Imate", "nešto", "prehladu?", "li", "za"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e38ee11c-162e-54e0-a6b2-b86296ff4989', 'sentence_builder', 'Складіть: «До чи після їжі?»', 'Prije ili poslije jela?', '["Prije", "poslije", "ili", "jela?"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ba5b6513-c968-53ab-a2af-c24d41ff8f62', 'listening', 'Прослухайте і складіть фразу', 'Ne, ne trebate.', '["trebate.", "Ne,", "ne"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '62f93f91-2c2c-531a-94ea-273616ae620f', 'listening', 'Прослухайте і складіть фразу', 'Poslije jela. I pijte puno vode.', '["Poslije", "jela.", "puno", "pijte", "vode.", "I"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '13936d8f-5100-5b91-8b52-587df2eddfbd', 'speaking', 'Мені потрібні ліки від болю.', 'Trebam lijek protiv bolova.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a76dbc7-d75c-532f-a62c-67b228a138c5', 'speaking', 'Пийте багато води.', 'Pijte puno vode.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1d36e4c1-d72d-5d78-b5f7-bd00d5ce36c2', v_lesson, 'Ліки від застуди', 'Lijek za prehladu', 1311, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('04c1efcc-926c-584f-93bc-eae32e57c6fd', '1d36e4c1-d72d-5d78-b5f7-bd00d5ce36c2', 'Ljekarnica', 'Izvolite?', 'Слухаю вас?', 1);
  perform pg_temp.turn('dd0588b1-5ec5-50c0-823f-556120f2808d', '1d36e4c1-d72d-5d78-b5f7-bd00d5ce36c2', 'Andrij', 'Imate li nešto za prehladu?', 'У вас є щось від застуди?', 2);
  perform pg_temp.turn('bc0a0fb0-ce61-51ff-a680-4fe6eac1f7ec', '1d36e4c1-d72d-5d78-b5f7-bd00d5ce36c2', 'Ljekarnica', 'Imamo ove tablete i sirup protiv kašlja.', 'Є ці таблетки й сироп від кашлю.', 3);
  perform pg_temp.turn('f1ff55bf-8f95-5693-8929-94252f1b408e', '1d36e4c1-d72d-5d78-b5f7-bd00d5ce36c2', 'Andrij', 'Trebam li recept?', 'Мені потрібен рецепт?', 4);
  perform pg_temp.turn('1ab8dfae-0b4f-562c-ab7b-4bd02bd3d914', '1d36e4c1-d72d-5d78-b5f7-bd00d5ce36c2', 'Ljekarnica', 'Ne, ne trebate.', 'Ні, не потрібен.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1e40287e-e618-5a21-8ed8-5c2bb3c0c147', v_lesson, 'Як приймати', 'Kako uzimati', 1312, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('0dbe87c7-54f4-5719-9459-8f213decbc44', '1e40287e-e618-5a21-8ed8-5c2bb3c0c147', 'Andrij', 'Kako trebam uzimati tablete?', 'Як мені приймати таблетки?', 1);
  perform pg_temp.turn('60a7409a-ca51-5d69-bddc-a0ad6d29f233', '1e40287e-e618-5a21-8ed8-5c2bb3c0c147', 'Ljekarnica', 'Uzmite jednu tabletu tri puta dnevno.', 'Приймайте одну таблетку тричі на день.', 2);
  perform pg_temp.turn('02aca639-dccf-5276-866f-feb5e1c6492e', '1e40287e-e618-5a21-8ed8-5c2bb3c0c147', 'Andrij', 'Prije ili poslije jela?', 'До чи після їжі?', 3);
  perform pg_temp.turn('0f3d3325-a22c-5bc4-97fe-a50440f3eec6', '1e40287e-e618-5a21-8ed8-5c2bb3c0c147', 'Ljekarnica', 'Poslije jela. I pijte puno vode.', 'Після їжі. І пийте багато води.', 4);
  perform pg_temp.turn('a7343c49-e185-5cbb-95dd-8930c395b9c5', '1e40287e-e618-5a21-8ed8-5c2bb3c0c147', 'Andrij', 'Hvala, doviđenja!', 'Дякую, до побачення!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 32: Як ви почуваєтеся?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '878c0712-e4e5-5a7d-aab5-510c781da0c7';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.7: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b89a9004-2c03-567a-b23e-31db18f92dea';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.7.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 32: Як ви почуваєтеся?', 'Lekcija 32: Kako se osjećate?', '["Сказати, як ви почуваєтеся", "Порадити другові відпочити", "Вживати nisam, nemam, ne"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'osjećati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zdrav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'umoran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spavati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odmarati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zdravlje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svježi zrak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šetati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vitamin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobro', v_pos);
  v_pos := pg_temp.word(v_lesson, 'loše', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a300fb09-d01f-55a8-b5c7-5ab0879950dc', 'fill_in_the_blank', 'Ja danas ___ dobro.', 'nisam', '["ne", "nemam", "nisam", "nema"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '207895a6-7422-5463-91c7-3b4d6b53418f', 'multiple_choice', 'Що означає «spavati»?', 'спати', '["спати", "втомлений", "добре", "вітамін"]'::jsonb, 'A1', 2, 'PUBLISHED', 'spavati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd44b4556-80cd-56fd-9edb-b76763368a9a', 'multiple_choice', 'Що означає «zdrav»?', 'здоровий', '["здоровий", "почуватися", "відпочивати", "втомлений"]'::jsonb, 'A1', 3, 'PUBLISHED', 'zdrav', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '85378c5a-eed9-5da6-a1ec-8706be4a6893', 'multiple_choice', 'Як хорватською «добре»?', 'dobro', '["svježi zrak", "loše", "zdrav", "dobro"]'::jsonb, 'A1', 4, 'PUBLISHED', 'dobro', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9b27bbe2-49f2-594a-ac24-0777fde7883f', 'type_answer', 'Напишіть хорватською: «вітамін»', 'vitamin', null, 'A1', 5, 'PUBLISHED', 'vitamin', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '03f70d67-c630-5b42-ab7c-422969d11bf5', 'type_answer', 'Напишіть хорватською: «почуватися»', 'osjećati se', null, 'A1', 6, 'PUBLISHED', 'osjećati se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c8c509f-3cd7-5c1f-8134-f4ff53e9b45f', 'sentence_builder', 'Складіть: «Як ти сьогодні почуваєшся?»', 'Kako se osjećaš danas?', '["se", "osjećaš", "danas?", "Kako"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e1a68bef-e6ef-55c1-af52-b55026b83de8', 'sentence_builder', 'Складіть: «Я вже не хворий.»', 'Više nisam bolestan.', '["bolestan.", "Više", "nisam"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7520860c-3406-5044-89ce-e74eb45996fc', 'listening', 'Прослухайте і складіть фразу', 'Nemam, samo sam jako umoran.', '["jako", "samo", "Nemam,", "umoran.", "sam"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e1dc9767-6aa5-5cc8-8eab-e6c1fa084243', 'listening', 'Прослухайте і складіть фразу', 'Super! Idemo u šetnju?', '["Super!", "u", "Idemo", "šetnju?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '90800cdb-8f12-5d1a-b3ec-98d6100f5143', 'speaking', 'Мені недобре.', 'Nije mi dobro.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '71b96112-5873-59c3-aea8-f103f76f12cf', 'speaking', 'Я погано сплю.', 'Ne spavam dobro.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('40d80acd-3716-5fc1-83c0-6da6f5aecc85', v_lesson, 'Другові недобре', 'Prijatelju nije dobro', 1321, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('16c0b552-a975-5929-88ec-7b91d48fd85e', '40d80acd-3716-5fc1-83c0-6da6f5aecc85', 'Lana', 'Kako se osjećaš danas?', 'Як ти сьогодні почуваєшся?', 1);
  perform pg_temp.turn('44c52e5f-9fde-541b-8716-e1ef5518b6ad', '40d80acd-3716-5fc1-83c0-6da6f5aecc85', 'Taras', 'Nisam dobro. Ne spavam dobro i nemam apetita.', 'Мені недобре. Погано сплю, і немає апетиту.', 2);
  perform pg_temp.turn('d51cd91c-0ef4-5103-806d-b5cb9498e138', '40d80acd-3716-5fc1-83c0-6da6f5aecc85', 'Lana', 'Imaš li temperaturu?', 'У тебе є температура?', 3);
  perform pg_temp.turn('a32aa0fd-b6a8-52da-8ab7-70c2ad910bfd', '40d80acd-3716-5fc1-83c0-6da6f5aecc85', 'Taras', 'Nemam, samo sam jako umoran.', 'Немає, просто дуже втомлений.', 4);
  perform pg_temp.turn('8d67ced2-f529-5ee9-ac8d-5a53cfa52abf', '40d80acd-3716-5fc1-83c0-6da6f5aecc85', 'Lana', 'Odmaraj se i pij čaj!', 'Відпочивай і пий чай!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cb93fa2d-981e-5d48-b7df-f9140d4b4490', v_lesson, 'Через тиждень', 'Tjedan dana kasnije', 1322, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('b78c8c53-7588-51c3-b3e1-d928202c1edf', 'cb93fa2d-981e-5d48-b7df-f9140d4b4490', 'Lana', 'Kako si sada?', 'Як ти зараз?', 1);
  perform pg_temp.turn('f64253f8-1822-588c-bea1-f3f9b1b40330', 'cb93fa2d-981e-5d48-b7df-f9140d4b4490', 'Taras', 'Puno bolje! Više nisam bolestan.', 'Набагато краще! Я вже не хворий.', 2);
  perform pg_temp.turn('73332bc3-bc67-56d8-8f30-9271b13f2278', 'cb93fa2d-981e-5d48-b7df-f9140d4b4490', 'Lana', 'Super! Idemo u šetnju?', 'Супер! Підемо на прогулянку?', 3);
  perform pg_temp.turn('f8769f9a-28b2-5213-a57d-d270fc399986', 'cb93fa2d-981e-5d48-b7df-f9140d4b4490', 'Taras', 'Može. Treba mi svježeg zraka.', 'Давай. Мені потрібне свіже повітря.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 33: Що болить?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '431b51ad-baa3-5387-94ac-a7273fdb9263';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.7: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.7.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 33: Що болить?', 'Lekcija 33: Što boli?', '["Назвати частини тіла", "Пояснити лікарю, що болить", "Вживати boli me / bole me"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'tijelo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ruka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uho', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zub', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trbuh', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prst', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srce', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koljeno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rame', v_pos);
  v_pos := pg_temp.word(v_lesson, 'usta', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '15e1d406-76ac-5d03-8fb3-4db9031950fa', 'fill_in_the_blank', 'Bole me ___.', 'oči', '["oči", "oko", "okom", "oka"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4f768547-cf16-53a8-9796-e1161d0d461c', 'multiple_choice', 'Що означає «usta»?', 'рот', '["вухо", "рот", "око", "палець"]'::jsonb, 'A1', 2, 'PUBLISHED', 'usta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b0a0cd92-4db4-502c-ae59-600d2ae14a94', 'multiple_choice', 'Що означає «prst»?', 'палець', '["коліно", "око", "палець", "плече"]'::jsonb, 'A1', 3, 'PUBLISHED', 'prst', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a696b49-ee50-50f3-9632-a423088cbbd5', 'multiple_choice', 'Як хорватською «вухо»?', 'uho', '["rame", "oko", "uho", "vrat"]'::jsonb, 'A1', 4, 'PUBLISHED', 'uho', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '303a0a94-cd20-5a3b-9abc-9fb4681f537c', 'type_answer', 'Напишіть хорватською: «серце»', 'srce', null, 'A1', 5, 'PUBLISHED', 'srce', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c7991d5d-167d-5a82-874f-922d1560087a', 'type_answer', 'Напишіть хорватською: «тіло»', 'tijelo', null, 'A1', 6, 'PUBLISHED', 'tijelo', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd6580900-5de7-515c-a90c-fddd5d8f036f', 'sentence_builder', 'Складіть: «У мене болить коліно.»', 'Boli me koljeno.', '["koljeno.", "Boli", "me"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5131007d-0c8b-5ad0-946f-9595a9c3e2ed', 'sentence_builder', 'Складіть: «У нього болить живіт.»', 'Boli ga trbuh.', '["ga", "trbuh.", "Boli"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2fe30e5d-50bf-52e7-a5a1-9650f772aaa2', 'listening', 'Прослухайте і складіть фразу', 'Možete li pomaknuti ruku?', '["pomaknuti", "li", "Možete", "ruku?"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '446c4f2d-be62-53da-8f03-2d711b788323', 'listening', 'Прослухайте і складіть фразу', 'Otvori usta i pokaži jezik.', '["Otvori", "pokaži", "jezik.", "i", "usta"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a7b48a2a-5e67-5e09-b379-8cb01e66b30d', 'speaking', 'У мене болить рука.', 'Boli me ruka.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a7997a7d-0dfc-584b-ae60-36f7cc854090', 'speaking', 'У мене болять очі.', 'Bole me oči.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('efff311e-2e91-5683-ac5e-0e5f0adc32e3', v_lesson, 'Після футболу', 'Poslije nogometa', 1331, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('36be24eb-c16d-51fb-af16-349fae747a93', 'efff311e-2e91-5683-ac5e-0e5f0adc32e3', 'Liječnik', 'Što Vas boli?', 'Що у вас болить?', 1);
  perform pg_temp.turn('930de80e-b07f-51ae-b45a-45fe782e35e2', 'efff311e-2e91-5683-ac5e-0e5f0adc32e3', 'Taras', 'Boli me koljeno, a i rame.', 'У мене болить коліно, а ще плече.', 2);
  perform pg_temp.turn('2e7b53c6-1f2f-5fd9-ab35-c3f33b6a9313', 'efff311e-2e91-5683-ac5e-0e5f0adc32e3', 'Liječnik', 'Od kada?', 'Відколи?', 3);
  perform pg_temp.turn('a66e50f0-0e9f-502e-bbbf-6c2bd3912215', 'efff311e-2e91-5683-ac5e-0e5f0adc32e3', 'Taras', 'Od subote, od nogometa.', 'Із суботи, після футболу.', 4);
  perform pg_temp.turn('518a7f4b-b9ba-5f35-9f7b-a02244b229cb', 'efff311e-2e91-5683-ac5e-0e5f0adc32e3', 'Liječnik', 'Možete li pomaknuti ruku?', 'Можете поворушити рукою?', 5);
  perform pg_temp.turn('f4b99d9f-0923-571c-8e8a-eb09a94a68e3', 'efff311e-2e91-5683-ac5e-0e5f0adc32e3', 'Taras', 'Mogu, ali boli.', 'Можу, але болить.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('77d8eae7-65a5-5813-ab44-1672ac72c575', v_lesson, 'Дитина хворіє', 'Dijete je bolesno', 1332, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('9e47fcbc-2bee-5c34-bbb6-1d2873085a5a', '77d8eae7-65a5-5813-ab44-1672ac72c575', 'Mama', 'Doktorice, sinu je loše. Boli ga trbuh i uho.', 'Лікарко, синові погано. У нього болить живіт і вухо.', 1);
  perform pg_temp.turn('c0b7d524-0c15-5463-86cb-cf27832f5934', '77d8eae7-65a5-5813-ab44-1672ac72c575', 'Doktorica', 'Ima li temperaturu?', 'У нього є температура?', 2);
  perform pg_temp.turn('ee30739c-afba-53b4-8faf-49a26e00771b', '77d8eae7-65a5-5813-ab44-1672ac72c575', 'Mama', 'Ima, trideset osam.', 'Є, тридцять вісім.', 3);
  perform pg_temp.turn('803ec261-62cb-54e7-bf94-792cb1ea62cb', '77d8eae7-65a5-5813-ab44-1672ac72c575', 'Doktorica', 'Otvori usta i pokaži jezik.', 'Відкрий рот і покажи язик.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 34: У стоматолога
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '247c3445-6ba3-50f0-a441-9073d6734451';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.7: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.7.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 34: У стоматолога', 'Lekcija 34: Kod zubara', '["Записатися до стоматолога терміново", "Пояснити, який зуб болить", "Зрозуміти, що зробить лікар"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zubar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zubobolja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hitan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plomba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'injekcija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izvaditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osjetljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hladno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gore', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dolje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osiguranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'popravljati', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d65f9e1-bd2e-5599-a83b-b3ff2b57abbb', 'fill_in_the_blank', '___ zub Vas boli?', 'Koji', '["Koja", "Koju", "Koje", "Koji"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c242c57a-5ddb-5fd3-b107-a42f02892e2d', 'multiple_choice', 'Що означає «dolje»?', 'внизу', '["внизу", "терміновий", "зубний біль", "пломба (зубна)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'dolje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a1a09105-7a2b-5f32-8c5c-a19546b40329', 'multiple_choice', 'Що означає «popravljati»?', 'ремонтувати (процес)', '["укол", "ремонтувати (процес)", "вгорі", "пломба (зубна)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'popravljati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ca61ced3-5963-58d5-bbb0-4dc92dbdd3a0', 'multiple_choice', 'Як хорватською «терміновий»?', 'hitan', '["hitan", "osiguranje", "zubobolja", "zubar"]'::jsonb, 'A1', 4, 'PUBLISHED', 'hitan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c662d3aa-9961-549d-94b1-8cd8b62f83f2', 'type_answer', 'Напишіть хорватською: «стоматолог»', 'zubar', null, 'A1', 5, 'PUBLISHED', 'zubar', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd1a151e2-553d-5cd0-b383-5477a0244911', 'type_answer', 'Напишіть хорватською: «вгорі»', 'gore', null, 'A1', 6, 'PUBLISHED', 'gore', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ebd6d402-0b31-56db-9d72-f09d59023614', 'sentence_builder', 'Складіть: «Мені потрібен терміновий запис.»', 'Trebam hitan termin.', '["Trebam", "termin.", "hitan"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0302df37-c7a8-5112-97ce-69710c5f90a3', 'sentence_builder', 'Складіть: «Він чутливий до холодного.»', 'Osjetljiv je na hladno.', '["je", "Osjetljiv", "na", "hladno."]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '48d95580-c963-56f5-ad81-770a1901cc9d', 'listening', 'Прослухайте і складіть фразу', 'Možete li doći danas u tri?', '["li", "danas", "tri?", "Možete", "u", "doći"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2b09aa69-e3d3-54ca-a0b0-07c248bf4f65', 'listening', 'Прослухайте і складіть фразу', 'Trebate plombu. Želite li injekciju?', '["plombu.", "Želite", "li", "injekciju?", "Trebate"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cb1069d3-ee18-56b3-ae00-035a38726ac6', 'speaking', 'Мені потрібен стоматолог.', 'Trebam zubara.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d338096-0569-55b5-a504-94f56acc6c23', 'speaking', 'Скільки коштує огляд?', 'Koliko košta pregled?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4c59828f-76ec-5364-bac4-339e13a88d8c', v_lesson, 'Терміновий запис', 'Hitan termin', 1341, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('59af35d8-25dd-5f92-bacc-9e1198fbf04f', '4c59828f-76ec-5364-bac4-339e13a88d8c', 'Iryna', 'Dobar dan, imam jaku zubobolju. Trebam hitan termin.', 'Добрий день, у мене сильно болить зуб. Мені потрібен терміновий запис.', 1);
  perform pg_temp.turn('c4447e1a-68e3-5ad5-92f4-c2fb5d864baf', '4c59828f-76ec-5364-bac4-339e13a88d8c', 'Sestra', 'Možete li doći danas u tri?', 'Можете прийти сьогодні о третій?', 2);
  perform pg_temp.turn('09ebbe53-306d-5557-ad90-3895c9a997ea', '4c59828f-76ec-5364-bac4-339e13a88d8c', 'Iryna', 'Mogu. Koliko košta pregled?', 'Можу. Скільки коштує огляд?', 3);
  perform pg_temp.turn('7c51d00f-4cd0-5ff7-a7e2-51caf944440e', '4c59828f-76ec-5364-bac4-339e13a88d8c', 'Sestra', 'S osiguranjem ne plaćate ništa.', 'Зі страховкою ви нічого не платите.', 4);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8d399aa0-15f7-57cc-bd88-c1f6d2bfa03a', v_lesson, 'У кріслі', 'U stolici', 1342, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('9de4d08e-e79a-5718-8f4b-99b47e888ae5', '8d399aa0-15f7-57cc-bd88-c1f6d2bfa03a', 'Zubar', 'Koji zub Vas boli?', 'Який зуб у вас болить?', 1);
  perform pg_temp.turn('20d09588-925c-5f31-b161-a1d8cfe1856b', '8d399aa0-15f7-57cc-bd88-c1f6d2bfa03a', 'Iryna', 'Ovaj gore, lijevo. Osjetljiv je na hladno.', 'Ось цей угорі ліворуч. Він чутливий до холодного.', 2);
  perform pg_temp.turn('1011f5a8-8507-50bf-9766-07b458c11d25', '8d399aa0-15f7-57cc-bd88-c1f6d2bfa03a', 'Zubar', 'Trebate plombu. Želite li injekciju?', 'Вам потрібна пломба. Хочете укол?', 3);
  perform pg_temp.turn('794169d7-50e2-590d-b7e3-99b4fba53fc9', '8d399aa0-15f7-57cc-bd88-c1f6d2bfa03a', 'Iryna', 'Da, molim! Morate li ga izvaditi?', 'Так, будь ласка! Його треба видаляти?', 4);
  perform pg_temp.turn('afcd993e-5e1d-5d18-8ae9-845864fb4994', '8d399aa0-15f7-57cc-bd88-c1f6d2bfa03a', 'Zubar', 'Ne, samo ga popravljamo.', 'Ні, тільки лікуємо.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 35: Запрошення
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '3ed8282d-b9fa-5151-b184-73fd352f8ba7';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.8: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.8.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 35: Запрошення', 'Lekcija 35: Poziv', '["Запросити друга", "Погодитися або відмовитися", "Вживати hoćeš li, mogu, ne mogu"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'pozvati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poziv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zabava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rođendan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'doći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'htjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'moći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vidimo se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kino', v_pos);
  v_pos := pg_temp.word(v_lesson, 'večeras', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rado', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a271dbd0-520f-507b-972b-fc6b129a662c', 'fill_in_the_blank', 'Nažalost, ja ne ___ doći.', 'mogu', '["možeš", "mogu", "može", "moći"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '815ca078-f42a-5eb4-8389-5ea5c748f5a8', 'multiple_choice', 'Що означає «slaviti»?', 'святкувати', '["святкувати", "запросити", "сьогодні ввечері", "день народження"]'::jsonb, 'A1', 2, 'PUBLISHED', 'slaviti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '31374717-29b1-5f39-ac4c-c642c068831b', 'multiple_choice', 'Що означає «poziv»?', 'дзвінок / запрошення', '["побачимося", "день народження", "могти", "дзвінок / запрошення"]'::jsonb, 'A1', 3, 'PUBLISHED', 'poziv', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f6b3c127-e913-52c8-bf7e-193bb1e89e7b', 'multiple_choice', 'Як хорватською «побачимося»?', 'vidimo se', '["slaviti", "htjeti", "poziv", "vidimo se"]'::jsonb, 'A1', 4, 'PUBLISHED', 'vidimo se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f8176496-7b92-517f-952b-3310747826e5', 'type_answer', 'Напишіть хорватською: «могти»', 'moći', null, 'A1', 5, 'PUBLISHED', 'moći', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '14dd814d-c27c-5870-8654-383e33e15763', 'type_answer', 'Напишіть хорватською: «сьогодні ввечері»', 'večeras', null, 'A1', 6, 'PUBLISHED', 'večeras', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '262636df-e854-5748-a8e2-ee63395ed471', 'sentence_builder', 'Складіть: «У суботу я святкую день народження.»', 'U subotu slavim rođendan.', '["U", "slavim", "rođendan.", "subotu"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '760bdb89-1797-5aed-8c02-b91f9136ca94', 'sentence_builder', 'Складіть: «На жаль, не можу.»', 'Nažalost, ne mogu.', '["Nažalost,", "mogu.", "ne"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '911cb1c6-d66e-51be-bd1d-1aa172180f9f', 'listening', 'Прослухайте і складіть фразу', 'U osam, kod mene.', '["kod", "osam,", "mene.", "U"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '98dad53b-1f9d-5fab-b836-570783fe43da', 'listening', 'Прослухайте і складіть фразу', 'Sutra mogu. Vidimo se u sedam!', '["Vidimo", "Sutra", "se", "mogu.", "sedam!", "u"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8970522d-f5f0-5211-8e50-af14bac63e9d', 'speaking', 'Хочеш піти в кіно?', 'Hoćeš li ići u kino?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ed8ac0cd-9419-5859-b2e2-8ef7f6fafe1b', 'speaking', 'Із задоволенням!', 'S veseljem!', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('67c17c91-b780-51a6-bfb7-342077a804b0', v_lesson, 'День народження', 'Rođendan', 1351, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('da70dc7e-bfed-5618-b86b-2d2d2ed0b1af', '67c17c91-b780-51a6-bfb7-342077a804b0', 'Marko', 'U subotu slavim rođendan. Hoćeš li doći?', 'У суботу я святкую день народження. Прийдеш?', 1);
  perform pg_temp.turn('27ccd9b4-9b25-50dc-a817-693383f4ca97', '67c17c91-b780-51a6-bfb7-342077a804b0', 'Iryna', 'Hoću, rado! U koliko sati?', 'Так, із радістю! О котрій?', 2);
  perform pg_temp.turn('31541477-422c-5c35-9645-a50a4fed182f', '67c17c91-b780-51a6-bfb7-342077a804b0', 'Marko', 'U osam, kod mene.', 'О восьмій, у мене.', 3);
  perform pg_temp.turn('7c3d8edc-2cc8-5207-84e1-9e7a0ab6e9e3', '67c17c91-b780-51a6-bfb7-342077a804b0', 'Iryna', 'Trebam li nešto donijeti?', 'Мені щось принести?', 4);
  perform pg_temp.turn('9a71c62b-e304-54d3-9126-8a6815dc9882', '67c17c91-b780-51a6-bfb7-342077a804b0', 'Marko', 'Ne trebaš, samo dobro raspoloženje!', 'Не треба, тільки гарний настрій!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('591c3e6f-a91b-530d-a75a-077509f11a51', v_lesson, 'Не можу', 'Ne mogu', 1352, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('e6f8f637-448f-570f-b59c-46b52dab4e89', '591c3e6f-a91b-530d-a75a-077509f11a51', 'Ana', 'Idemo u kino večeras?', 'Підемо сьогодні ввечері в кіно?', 1);
  perform pg_temp.turn('432c8501-a359-54e5-bfd3-9054e5966b42', '591c3e6f-a91b-530d-a75a-077509f11a51', 'Taras', 'Nažalost, ne mogu. Moram raditi.', 'На жаль, не можу. Мушу працювати.', 2);
  perform pg_temp.turn('1de3119f-c4b3-5b43-977c-e3c9a40b8bf2', '591c3e6f-a91b-530d-a75a-077509f11a51', 'Ana', 'A sutra?', 'А завтра?', 3);
  perform pg_temp.turn('9b7f6302-8a73-54d8-98a8-7960ba557d43', '591c3e6f-a91b-530d-a75a-077509f11a51', 'Taras', 'Sutra mogu. Vidimo se u sedam!', 'Завтра можу. Побачимося о сьомій!', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 36: Хобі
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '1c16ceee-5f42-536a-98b4-7dcabaa3be6d';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.8: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '318b394b-c622-5dd6-8494-4c1472b6df62';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.8.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 36: Хобі', 'Lekcija 36: Hobiji', '["Розповісти про свої хобі", "Запитати, що любить робити співрозмовник", "Вживати volim + інфінітив"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'hobi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'voljeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plivati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plesati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pjevati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crtati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fotografirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'igrati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nogomet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bazen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slobodno vrijeme', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sport', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a0ebefc5-7f08-59c6-89a2-5e9ade0d0bf3', 'fill_in_the_blank', 'Ja ___ plivati.', 'volim', '["vole", "voliš", "voli", "volim"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a1608e64-acf4-55a1-b055-dd170d21bef0', 'multiple_choice', 'Що означає «fotografirati»?', 'фотографувати', '["плавати", "танцювати", "фотографувати", "вільний час"]'::jsonb, 'A1', 2, 'PUBLISHED', 'fotografirati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c2ec3d11-c2e1-5103-8faf-8a0634d1d692', 'multiple_choice', 'Що означає «igrati»?', 'грати', '["хобі / улюблена справа", "грати", "співати", "футбол"]'::jsonb, 'A1', 3, 'PUBLISHED', 'igrati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd7526c73-8164-573e-91bf-d4a2072ab797', 'multiple_choice', 'Як хорватською «плавати»?', 'plivati', '["fotografirati", "slobodno vrijeme", "plivati", "igrati"]'::jsonb, 'A1', 4, 'PUBLISHED', 'plivati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f136044c-5640-5313-98a0-b954763f2f92', 'type_answer', 'Напишіть хорватською: «співати»', 'pjevati', null, 'A1', 5, 'PUBLISHED', 'pjevati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '777632cd-9931-55f4-bafd-2b1605cd6b03', 'type_answer', 'Напишіть хорватською: «спорт»', 'sport', null, 'A1', 6, 'PUBLISHED', 'sport', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'daeb6338-8e44-5994-9c0a-9d99b27909b2', 'sentence_builder', 'Складіть: «Я люблю плавати й фотографувати.»', 'Volim plivati i fotografirati.', '["Volim", "plivati", "fotografirati.", "i"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be619a29-c303-57d5-8a6c-4a88a74c5b42', 'sentence_builder', 'Складіть: «Ти граєш у футбол?»', 'Igraš li nogomet?', '["li", "nogomet?", "Igraš"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a6933b0d-b9be-5a27-a14a-1b43334254b9', 'listening', 'Прослухайте і складіть фразу', 'Ja više volim plesati.', '["više", "volim", "plesati.", "Ja"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '630789ee-d9ef-5621-b33b-b3b67ce3c2f8', 'listening', 'Прослухайте і складіть фразу', 'Igram, svake nedjelje s kolegama.', '["kolegama.", "nedjelje", "svake", "Igram,", "s"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aabab1a4-1d41-5c2f-b418-32aea4be6b4d', 'speaking', 'Я люблю співати.', 'Volim pjevati.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b2b0d44f-edee-55bb-8163-b60978932cd4', 'speaking', 'Що ти любиш робити?', 'Što voliš raditi?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7381d5b8-4e9c-5e8c-a5f4-ea90f3569d97', v_lesson, 'Що ти любиш робити?', 'Što voliš raditi?', 1361, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('45bbeb84-0b58-53a7-b2ba-a5b3011eb477', '7381d5b8-4e9c-5e8c-a5f4-ea90f3569d97', 'Petra', 'Što voliš raditi u slobodno vrijeme?', 'Що ти любиш робити у вільний час?', 1);
  perform pg_temp.turn('d88f86d5-1a39-5847-aa0a-c73033fa6462', '7381d5b8-4e9c-5e8c-a5f4-ea90f3569d97', 'Andrij', 'Volim plivati i fotografirati.', 'Я люблю плавати й фотографувати.', 2);
  perform pg_temp.turn('323ad068-7ad3-5eb2-9daf-12ee53227819', '7381d5b8-4e9c-5e8c-a5f4-ea90f3569d97', 'Petra', 'Gdje plivaš?', 'Де ти плаваєш?', 3);
  perform pg_temp.turn('f8827e57-897b-57c8-b5dc-f6ff04efc209', '7381d5b8-4e9c-5e8c-a5f4-ea90f3569d97', 'Andrij', 'Ljeti na moru, a zimi na bazenu.', 'Влітку в морі, а взимку в басейні.', 4);
  perform pg_temp.turn('e2ca7c4d-453a-56f6-99d7-19706b23e490', '7381d5b8-4e9c-5e8c-a5f4-ea90f3569d97', 'Petra', 'Ja više volim plesati.', 'А я більше люблю танцювати.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3c3ae8fb-c1e7-5136-842c-2b8dfe862b23', v_lesson, 'Футбол', 'Nogomet', 1362, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('2ed0c178-e4b8-5277-b05a-72b97257c8c9', '3c3ae8fb-c1e7-5136-842c-2b8dfe862b23', 'Luka', 'Igraš li nogomet?', 'Ти граєш у футбол?', 1);
  perform pg_temp.turn('55e71f6d-b08e-5f2d-8cc5-cca4c84709bf', '3c3ae8fb-c1e7-5136-842c-2b8dfe862b23', 'Taras', 'Igram, svake nedjelje s kolegama.', 'Граю, щонеділі з колегами.', 2);
  perform pg_temp.turn('7a7aa967-c5a0-5469-9200-a06b529c6af6', '3c3ae8fb-c1e7-5136-842c-2b8dfe862b23', 'Luka', 'Mogu li i ja igrati s vama?', 'Можна й мені грати з вами?', 3);
  perform pg_temp.turn('a3a45419-9bd3-591b-a809-89c6a1cf8809', '3c3ae8fb-c1e7-5136-842c-2b8dfe862b23', 'Taras', 'Naravno! Dođi u nedjelju u deset.', 'Звісно! Приходь у неділю о десятій.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 37: Що ти думаєш?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'ec1b7982-c092-5504-a233-4162f92f512a';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.8: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '765ac66f-d54b-505b-9b11-c48e5ad26018';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.8.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 37: Що ти думаєш?', 'Lekcija 37: Što misliš?', '["Сказати, що вам подобається, а що ні", "Пояснити чому: jer, zato što", "Порадити книжку чи фільм"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'misliti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mišljenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zanimljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dosadan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'film', v_pos);
  v_pos := pg_temp.word(v_lesson, 'knjiga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zato što', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ali', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ili', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sviđati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preporučiti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b39572a1-ece4-550c-8bf6-002750f1923a', 'fill_in_the_blank', 'Volim ovaj film ___ je zanimljiv.', 'jer', '["a", "ali", "jer", "ili"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b87360cd-d5c5-5995-a68d-5ff6d7864e1d', 'multiple_choice', 'Що означає «mišljenje»?', 'думка', '["але", "подобатися", "думка", "цікавий"]'::jsonb, 'A1', 2, 'PUBLISHED', 'mišljenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '765970f6-399e-5ecc-9067-a5fa1f89a661', 'multiple_choice', 'Що означає «zato što»?', 'тому що', '["подобатися", "фільм", "тому що", "нудний"]'::jsonb, 'A1', 3, 'PUBLISHED', 'zato što', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e83c4ab8-d07d-5871-b533-cfcb3dbe49de', 'multiple_choice', 'Як хорватською «рекомендувати»?', 'preporučiti', '["mišljenje", "dosadan", "preporučiti", "misliti"]'::jsonb, 'A1', 4, 'PUBLISHED', 'preporučiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ec9b7d0a-60a7-53b1-9821-1d10ddae646c', 'type_answer', 'Напишіть хорватською: «або»', 'ili', null, 'A1', 5, 'PUBLISHED', 'ili', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e7c99f6b-0539-5ca9-9626-acd173fd254c', 'type_answer', 'Напишіть хорватською: «нудний»', 'dosadan', null, 'A1', 6, 'PUBLISHED', 'dosadan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2edfea9e-3775-5da3-9784-74bdc1b01f27', 'sentence_builder', 'Складіть: «Цікавий, але задовгий.»', 'Zanimljiv je, ali predug.', '["Zanimljiv", "predug.", "je,", "ali"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5ca839e7-1bf1-55af-9f78-78a20d6aedca', 'sentence_builder', 'Складіть: «Спробуй комікси, бо вони легкі.»', 'Probaj stripove jer su laki.', '["su", "jer", "Probaj", "laki.", "stripove"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2332c850-7a87-57e6-96a5-388af42d8ecf', 'listening', 'Прослухайте і складіть фразу', 'Meni je dosadan.', '["je", "dosadan.", "Meni"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9c39d8e5-e68f-5c1b-979f-8fa25b195bb3', 'listening', 'Прослухайте і складіть фразу', 'Mislim da jest.', '["da", "jest.", "Mislim"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '108b29a9-b49a-50f5-b6f1-6766f1295c99', 'speaking', 'Я думаю, що це цікаво.', 'Mislim da je to zanimljivo.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5648bc2d-fae4-5598-8e0e-6f64a5d065e5', 'speaking', 'Мені подобається, бо це легко.', 'Sviđa mi se jer je lako.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('85f95ab6-8f99-5214-b1cc-99a4d2539237', v_lesson, 'Після кіно', 'Poslije kina', 1371, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('c24637da-cbe5-589f-9cad-716b48c13381', '85f95ab6-8f99-5214-b1cc-99a4d2539237', 'Ana', 'Kako ti se sviđa film?', 'Як тобі фільм?', 1);
  perform pg_temp.turn('aff89dc3-3fb1-5e99-ac54-8a26b5d7747b', '85f95ab6-8f99-5214-b1cc-99a4d2539237', 'Oleg', 'Zanimljiv je, ali predug.', 'Цікавий, але задовгий.', 2);
  perform pg_temp.turn('b1c4b164-390d-50bb-bc67-74242dc65053', '85f95ab6-8f99-5214-b1cc-99a4d2539237', 'Ana', 'Meni je dosadan.', 'А мені нудний.', 3);
  perform pg_temp.turn('bca8d6d6-7335-5723-9550-168bfa2ad29f', '85f95ab6-8f99-5214-b1cc-99a4d2539237', 'Oleg', 'Zašto?', 'Чому?', 4);
  perform pg_temp.turn('df54d199-0228-55cb-8fb7-27aae03680d6', '85f95ab6-8f99-5214-b1cc-99a4d2539237', 'Ana', 'Zato što znam kraj od početka!', 'Бо я знаю кінець від самого початку!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e0a9f7ce-277a-506b-930f-9ae425f73016', v_lesson, 'Порада', 'Preporuka', 1372, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('7cb92bfc-aa09-5538-99a7-716c31bdc1c4', 'e0a9f7ce-277a-506b-930f-9ae425f73016', 'Iryna', 'Što da čitam na hrvatskom?', 'Що мені почитати хорватською?', 1);
  perform pg_temp.turn('1878f16f-36b4-5655-825f-59a8f21c1c59', 'e0a9f7ce-277a-506b-930f-9ae425f73016', 'Marko', 'Probaj stripove jer su laki.', 'Спробуй комікси, бо вони легкі.', 2);
  perform pg_temp.turn('a2a4c758-d9e5-519b-92f0-7a2ef69f41fd', 'e0a9f7ce-277a-506b-930f-9ae425f73016', 'Iryna', 'Misliš li da je to dobro za učenje?', 'Думаєш, це добре для навчання?', 3);
  perform pg_temp.turn('8697096d-efca-5ea3-b9f4-df6cd9118926', 'e0a9f7ce-277a-506b-930f-9ae425f73016', 'Marko', 'Mislim da jest. Ili gledaj filmove s titlovima.', 'Думаю, що так. Або дивись фільми із субтитрами.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 38: Почуття
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'fac55dd6-0020-5997-8461-45ee2f94d3c5';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.8: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '765ac66f-d54b-505b-9b11-c48e5ad26018';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.8.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 38: Почуття', 'Lekcija 38: Osjećaji', '["Сказати, як ви почуваєтеся", "Підтримати друга", "Пояснити причину: jer, zato što"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'osjećaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tužan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'usamljen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nedostajati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nervozan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zabrinut', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brinuti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljut', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zadovoljan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iznenađen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izgledati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sasvim', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fda2a9c0-42d4-5883-aace-5fe14ecaf1a2', 'fill_in_the_blank', 'Sretna sam ___ si ovdje.', 'jer', '["ali", "jer", "ili", "a"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dbc0576c-2451-515b-beee-7e24cb2b64d2', 'multiple_choice', 'Що означає «nervozan»?', 'знервований; схвильований', '["турбуватися", "почуття", "знепокоєний / стурбований", "знервований; схвильований"]'::jsonb, 'A1', 2, 'PUBLISHED', 'nervozan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '867e5d6f-44ff-56f8-a151-39f10aed436d', 'multiple_choice', 'Що означає «ljut»?', 'злий / сердитий', '["злий / сердитий", "знервований; схвильований", "здивований", "самотній"]'::jsonb, 'A1', 3, 'PUBLISHED', 'ljut', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '89ea482b-e4c8-5c2d-a5a9-663ae5fd5350', 'multiple_choice', 'Як хорватською «самотній»?', 'usamljen', '["usamljen", "iznenađen", "izgledati", "ljut"]'::jsonb, 'A1', 4, 'PUBLISHED', 'usamljen', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '94724e0e-1aa0-5441-b20c-6e62a007af37', 'type_answer', 'Напишіть хорватською: «почуття»', 'osjećaj', null, 'A1', 5, 'PUBLISHED', 'osjećaj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e76c7732-7d3d-5c51-8745-a42523dd76a4', 'type_answer', 'Напишіть хорватською: «турбуватися»', 'brinuti se', null, 'A1', 6, 'PUBLISHED', 'brinuti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d975b58-3248-5cb5-a0bd-71218cf5c7a9', 'sentence_builder', 'Складіть: «Я сумую за родиною.»', 'Nedostaje mi obitelj.', '["Nedostaje", "obitelj.", "mi"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0b21e4be-bbe8-50fd-b9bf-b630b493a26e', 'sentence_builder', 'Складіть: «Я дуже нервую.»', 'Jako sam nervozan.', '["sam", "Jako", "nervozan."]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f2b6e37f-fca8-5f22-a913-837e86931227', 'listening', 'Прослухайте і складіть фразу', 'Razumijem. Hoćeš li doći k meni na kavu?', '["meni", "na", "Hoćeš", "Razumijem.", "k", "kavu?", "li", "doći"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '40f2713e-d3a2-54a7-a84b-6ee1a73c4b1a', 'listening', 'Прослухайте і складіть фразу', 'Zašto? Ti si odličan!', '["odličan!", "Ti", "Zašto?", "si"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '69f81e45-af65-513c-ac54-ea32737feaff', 'speaking', 'Я сьогодні щасливий.', 'Danas sam sretan.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '92eaaabd-e635-56f6-8b0e-829c790a8883', 'speaking', 'Не хвилюйся!', 'Ne brini!', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6f18ed19-9bfe-540a-aa29-5a9f55a88925', v_lesson, 'Що з тобою?', 'Što ti je?', 1381, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('db25e7a7-14c5-528a-8802-45812afefc30', '6f18ed19-9bfe-540a-aa29-5a9f55a88925', 'Ana', 'Što ti je? Izgledaš tužno.', 'Що з тобою? Ти сумно виглядаєш.', 1);
  perform pg_temp.turn('aee7deb7-d265-54d5-91f3-e46e758ba97f', '6f18ed19-9bfe-540a-aa29-5a9f55a88925', 'Oksana', 'Nedostaje mi obitelj. Ponekad sam usamljena.', 'Я сумую за родиною. Іноді мені самотньо.', 2);
  perform pg_temp.turn('f13530c3-5480-505d-9e58-ca5d0c28422e', '6f18ed19-9bfe-540a-aa29-5a9f55a88925', 'Ana', 'Razumijem. Hoćeš li doći k meni na kavu?', 'Розумію. Хочеш прийти до мене на каву?', 3);
  perform pg_temp.turn('64ac74dc-f985-5939-923c-0993ce129b0b', '6f18ed19-9bfe-540a-aa29-5a9f55a88925', 'Oksana', 'Hoću, hvala. Sretna sam jer te imam.', 'Так, дякую. Я щаслива, що ти в мене є.', 4);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('20ab6801-b0bb-5638-bbd7-39ee863ba76f', v_lesson, 'Перед співбесідою', 'Prije razgovora za posao', 1382, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('79c3ae7e-4335-5dcb-8739-41de67c5fcaa', '20ab6801-b0bb-5638-bbd7-39ee863ba76f', 'Taras', 'Jako sam nervozan.', 'Я дуже нервую.', 1);
  perform pg_temp.turn('74969ab1-7644-51d9-b320-39b9a9350562', '20ab6801-b0bb-5638-bbd7-39ee863ba76f', 'Marko', 'Zašto? Ti si odličan!', 'Чому? Ти чудовий!', 2);
  perform pg_temp.turn('e725327c-9cd9-58c4-85c5-b4e4d5bbf8c2', '20ab6801-b0bb-5638-bbd7-39ee863ba76f', 'Taras', 'Zabrinut sam jer ne govorim dobro hrvatski.', 'Я хвилююся, бо погано говорю хорватською.', 3);
  perform pg_temp.turn('85d6ffa1-fe97-5012-b9bc-f6513b8cc0d2', '20ab6801-b0bb-5638-bbd7-39ee863ba76f', 'Marko', 'Govoriš sasvim dobro. Ne brini!', 'Ти говориш цілком добре. Не хвилюйся!', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 39: Домовляємося про зустріч
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'dde31f54-28b8-505b-aba6-3e578601fccb';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.8: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.8.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 39: Домовляємося про зустріч', 'Lekcija 39: Dogovor', '["Запросити на прогулянку", "Домовитися, де й коли зустрітися", "Запитати, що взяти з собою"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'izlet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'planina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrh', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nalaziti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispred', v_pos);
  v_pos := pg_temp.word(v_lesson, 'točno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponijeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sendvič', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udoban', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dogovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iza', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'af38f920-2c4e-5cc2-bfcd-728d59926763', 'fill_in_the_blank', '___ se nalazimo? — Ispred kolodvora.', 'Gdje', '["Gdje", "Tko", "Kako", "Kada"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '123e13f1-1da9-5200-a950-625c9d8f1f1a', 'multiple_choice', 'Що означає «izlet»?', 'поїздка; екскурсія', '["домовленість", "вершина", "поїздка; екскурсія", "перед"]'::jsonb, 'A1', 2, 'PUBLISHED', 'izlet', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5fcdca3d-3dfe-59e4-b514-f6d13382a67a', 'multiple_choice', 'Що означає «točno»?', 'точно, правильно', '["за / позаду", "точно, правильно", "сендвіч", "зручний"]'::jsonb, 'A1', 3, 'PUBLISHED', 'točno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3be65fdd-3dbb-5b5a-af15-0e7dbb5f56ad', 'multiple_choice', 'Як хорватською «зручний»?', 'udoban', '["ponijeti", "nalaziti se", "sendvič", "udoban"]'::jsonb, 'A1', 4, 'PUBLISHED', 'udoban', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a5aa85e7-3c9a-5072-9167-9cc8f049fb80', 'type_answer', 'Напишіть хорватською: «вершина»', 'vrh', null, 'A1', 5, 'PUBLISHED', 'vrh', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a699b27-4dc2-5a80-94f2-7710282cf3da', 'type_answer', 'Напишіть хорватською: «сендвіч»', 'sendvič', null, 'A1', 6, 'PUBLISHED', 'sendvič', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c505fa1b-716f-5a6e-b7fd-3af8840c1f83', 'sentence_builder', 'Складіть: «Ти вільна в неділю?»', 'Jesi li slobodna u nedjelju?', '["u", "Jesi", "li", "slobodna", "nedjelju?"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1ed393dd-5d8b-5bd6-8930-e27373d2e337', 'sentence_builder', 'Складіть: «Що мені взяти з собою?»', 'Što trebam ponijeti?', '["trebam", "Što", "ponijeti?"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd8f7e876-bcb9-5248-846d-49ecaf5be672', 'listening', 'Прослухайте і складіть фразу', 'Ispred kolodvora, u devet točno.', '["devet", "Ispred", "kolodvora,", "u", "točno."]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '63085953-e8af-555f-ba33-99efc5b3e50c', 'listening', 'Прослухайте і складіть фразу', 'Oko dva sata hoda.', '["hoda.", "Oko", "sata", "dva"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '73a44a8f-4eb3-53e4-8d11-9b187a23aa28', 'speaking', 'Де зустрічаємося?', 'Gdje se nalazimo?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4aa9faf9-40cc-5612-a0d7-79a405f3ae8c', 'speaking', 'О котрій?', 'U koliko sati?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8779ae61-6f07-55c5-a0ec-39963b35cfb2', v_lesson, 'Плани на неділю', 'Planovi za nedjelju', 1391, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('0f0e7364-ea22-55f2-b6fb-8ea72eb386b8', '8779ae61-6f07-55c5-a0ec-39963b35cfb2', 'Luka', 'Bok! Jesi li slobodna u nedjelju?', 'Привіт! Ти вільна в неділю?', 1);
  perform pg_temp.turn('fe549e36-9e18-5743-a5ba-4aa2c8c27023', '8779ae61-6f07-55c5-a0ec-39963b35cfb2', 'Iryna', 'Jesam. Zašto?', 'Так. А що?', 2);
  perform pg_temp.turn('ec039af6-816d-51e4-81bf-8f6e5fcbba2c', '8779ae61-6f07-55c5-a0ec-39963b35cfb2', 'Luka', 'Idemo na izlet na Sljeme. Hoćeš s nama?', 'Ми йдемо в похід на Слеме. Хочеш з нами?', 3);
  perform pg_temp.turn('fd800710-66f7-5855-8ada-7c1a23d6a5da', '8779ae61-6f07-55c5-a0ec-39963b35cfb2', 'Iryna', 'Hoću! Gdje se nalazimo?', 'Хочу! Де зустрічаємося?', 4);
  perform pg_temp.turn('47b80126-c894-53e8-a5db-d627dbc45447', '8779ae61-6f07-55c5-a0ec-39963b35cfb2', 'Luka', 'Ispred kolodvora, u devet točno.', 'Перед вокзалом, рівно о дев’ятій.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0d0e10a6-6b58-5a8b-bef8-eef55c884fed', v_lesson, 'Що взяти?', 'Što ponijeti?', 1392, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('bbfd6fd7-5c1f-599d-983c-2edf3ea7d605', '0d0e10a6-6b58-5a8b-bef8-eef55c884fed', 'Iryna', 'Što trebam ponijeti?', 'Що мені взяти з собою?', 1);
  perform pg_temp.turn('efa4cf51-0807-5dc5-b987-c21e64b9b123', '0d0e10a6-6b58-5a8b-bef8-eef55c884fed', 'Luka', 'Vodu, sendvič i udobne cipele.', 'Воду, сендвіч і зручне взуття.', 2);
  perform pg_temp.turn('1bd1feb4-ec67-5668-a4cb-7c141ca5ef38', '0d0e10a6-6b58-5a8b-bef8-eef55c884fed', 'Iryna', 'Je li daleko do vrha planine?', 'Далеко до вершини гори?', 3);
  perform pg_temp.turn('5a57ae8f-403e-5bd1-88fb-3b7b68625520', '0d0e10a6-6b58-5a8b-bef8-eef55c884fed', 'Luka', 'Oko dva sata hoda.', 'Близько двох годин пішки.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 40: Погода
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '0cb42e87-0ece-5e12-a07c-05cb5c370157';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.9: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.9.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 40: Погода', 'Lekcija 40: Vrijeme', '["Запитати про прогноз погоди", "Порівняти погоду: toplije, hladnije", "Сказати, яку пору року ви любите"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'vremenska prognoza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sunce', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kiša', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vjetar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'snijeg', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oblak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hladan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'topao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kišobran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'magla', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godišnja doba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jesen', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ea0980dc-a70b-54b6-922e-9ec5dbcf6a19', 'fill_in_the_blank', 'Danas je ___ nego jučer.', 'toplije', '["toplo", "toplije", "najtoplije", "topao"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd5abc7bb-fef0-5d54-a581-21681995943a', 'multiple_choice', 'Що означає «hladan»?', 'холодний', '["вітер", "хмара", "холодний", "осінь"]'::jsonb, 'A1', 2, 'PUBLISHED', 'hladan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c5b6e22a-d3e5-51da-a024-853b40d7f13e', 'multiple_choice', 'Що означає «topao»?', 'теплий', '["теплий", "дощ", "сніг", "прогноз погоди"]'::jsonb, 'A1', 3, 'PUBLISHED', 'topao', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '56b4a540-8896-523a-9a11-6607ae921fba', 'multiple_choice', 'Як хорватською «дощ»?', 'kiša', '["kiša", "godišnja doba", "kišobran", "oblak"]'::jsonb, 'A1', 4, 'PUBLISHED', 'kiša', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a73dd8cc-0a96-5759-9589-d4a80cf6fa15', 'type_answer', 'Напишіть хорватською: «пори року»', 'godišnja doba', null, 'A1', 5, 'PUBLISHED', 'godišnja doba', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ce25f8cd-9176-5a53-ac0f-15e49cbbc99a', 'type_answer', 'Напишіть хорватською: «хмара»', 'oblak', null, 'A1', 6, 'PUBLISHED', 'oblak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '00d69c74-4a9a-59e5-a770-55a5b32c6cae', 'sentence_builder', 'Складіть: «Який прогноз на завтра?»', 'Kakva je prognoza za sutra?', '["je", "Kakva", "za", "sutra?", "prognoza"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7d461881-d606-513c-92c8-61b8369ff11a', 'sentence_builder', 'Складіть: «У Загребі зима холодніша, ніж у Спліті.»', 'U Zagrebu je zima hladnija nego u Splitu.', '["u", "U", "je", "Zagrebu", "hladnija", "zima", "Splitu.", "nego"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '78c58eaa-e5e7-5a55-97bb-516f0d4ae01b', 'listening', 'Прослухайте і складіть фразу', 'Opet kiša? Danas je ljepše.', '["Opet", "kiša?", "je", "Danas", "ljepše."]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd1ca9c3e-46c7-5e45-a572-1c5b38d861cd', 'listening', 'Прослухайте і складіть фразу', 'Ja volim jesen jer je najmirnija.', '["volim", "Ja", "jesen", "jer", "najmirnija.", "je"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a1881d74-7c8c-5a54-8dd6-ba0bd03e0a8b', 'speaking', 'Сьогодні холодніше, ніж учора.', 'Danas je hladnije nego jučer.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0df474e8-70eb-5fdc-9585-da0c3e32a867', 'speaking', 'Візьми парасолю!', 'Ponesi kišobran!', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3c61e8f6-867f-5f60-8ea6-bcb94946b0a9', v_lesson, 'Прогноз', 'Prognoza', 1401, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('7f113cdd-d635-5ac8-a493-04819f95a7bc', '3c61e8f6-867f-5f60-8ea6-bcb94946b0a9', 'Ivan', 'Kakva je prognoza za sutra?', 'Який прогноз на завтра?', 1);
  perform pg_temp.turn('adb30abb-ab78-5a12-af75-4fecfb134ba0', '3c61e8f6-867f-5f60-8ea6-bcb94946b0a9', 'Olena', 'Kiša i vjetar.', 'Дощ і вітер.', 2);
  perform pg_temp.turn('2b0379f0-677a-52f3-b9a5-c8b75f7f3bc7', '3c61e8f6-867f-5f60-8ea6-bcb94946b0a9', 'Ivan', 'Opet kiša? Danas je ljepše.', 'Знову дощ? Сьогодні гарніше.', 3);
  perform pg_temp.turn('810ce523-601b-560c-b891-6be5a1467e5c', '3c61e8f6-867f-5f60-8ea6-bcb94946b0a9', 'Olena', 'Ponesi sutra kišobran!', 'Візьми завтра парасолю!', 4);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c0d17e56-5dcc-58bd-842e-dfcc55ddc1b7', v_lesson, 'Найкраща пора року', 'Najljepše godišnje doba', 1402, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('3a5ebb83-650d-5ff7-9cdb-f7d1ba638fdd', 'c0d17e56-5dcc-58bd-842e-dfcc55ddc1b7', 'Maja', 'Koje godišnje doba voliš najviše?', 'Яку пору року ти любиш найбільше?', 1);
  perform pg_temp.turn('0bfa8981-df5e-519e-b1c1-48387388feac', 'c0d17e56-5dcc-58bd-842e-dfcc55ddc1b7', 'Taras', 'Proljeće. Toplije je nego zimi, a nije prevruće.', 'Весну. Тепліше, ніж узимку, і не надто спекотно.', 2);
  perform pg_temp.turn('8a7136d3-61f1-5722-a68d-41838938a08d', 'c0d17e56-5dcc-58bd-842e-dfcc55ddc1b7', 'Maja', 'Ja volim jesen jer je najmirnija.', 'А я люблю осінь, бо вона найспокійніша.', 3);
  perform pg_temp.turn('5a62de2d-720e-5cc2-ac8a-c0c74423053f', 'c0d17e56-5dcc-58bd-842e-dfcc55ddc1b7', 'Taras', 'U Zagrebu je zima hladnija nego u Splitu.', 'У Загребі зима холодніша, ніж у Спліті.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 41: На острів
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '71ab330d-abbe-57a7-870e-77e59daf3627';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.9: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.9.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 41: На острів', 'Lekcija 41: Na otok', '["Купити квиток на пором", "Сказати, де ви зупинилися", "Вживати na otoku, na plaži, u Bolu"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'otok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trajekt', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trajektna luka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plaža', v_pos);
  v_pos := pg_temp.word(v_lesson, 'more', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljeto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'apartman', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sunce', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odmor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'putovanje', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf396dea-6aec-5d5f-b665-4e1df023d88f', 'fill_in_the_blank', 'Ljeti živimo na ___.', 'otoku', '["otoku", "otoka", "otok", "otokom"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f254317-c74e-53e4-ae44-76e3c8753a10', 'multiple_choice', 'Що означає «obala»?', 'берег / узбережжя', '["подорож", "берег / узбережжя", "апартаменти / квартира", "поромний порт"]'::jsonb, 'A1', 2, 'PUBLISHED', 'obala', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8af672f1-806f-58ad-9925-e9c2e1dce5e8', 'multiple_choice', 'Що означає «trajekt»?', 'пором', '["апартаменти / квартира", "літо", "поромний порт", "пором"]'::jsonb, 'A1', 3, 'PUBLISHED', 'trajekt', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cb5403d8-a4b0-5755-b8d8-71bae2ec734d', 'multiple_choice', 'Як хорватською «поромний порт»?', 'trajektna luka', '["apartman", "odmor", "ljeto", "trajektna luka"]'::jsonb, 'A1', 4, 'PUBLISHED', 'trajektna luka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e95f79b2-4b0a-5cc5-85bf-69d73287cbd3', 'type_answer', 'Напишіть хорватською: «купатися»', 'kupati se', null, 'A1', 5, 'PUBLISHED', 'kupati se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '02fd3d4f-743c-542e-acf8-53e3d7a68f2f', 'type_answer', 'Напишіть хорватською: «сонце»', 'sunce', null, 'A1', 6, 'PUBLISHED', 'sunce', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '40847451-e1d5-5645-85b7-9a6690630538', 'sentence_builder', 'Складіть: «Пором відправляється о десятій.»', 'Trajekt polazi u deset sati.', '["polazi", "u", "sati.", "Trajekt", "deset"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b9e16224-249d-5a8c-b28b-04b72f58cdc6', 'sentence_builder', 'Складіть: «На якому ви пляжі?»', 'Na kojoj plaži ste?', '["kojoj", "Na", "ste?", "plaži"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '849808ae-f506-5e9b-9185-75e16481db80', 'listening', 'Прослухайте і складіть фразу', 'Pedeset minuta. Čekajte u drugom redu.', '["drugom", "Pedeset", "minuta.", "u", "Čekajte", "redu."]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7a484c44-5add-50e8-807d-f32e5023ceaa', 'listening', 'Прослухайте і складіть фразу', 'U malom apartmanu u Bolu.', '["malom", "Bolu.", "U", "apartmanu", "u"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8485c65c-ef36-54e1-8b0c-4276bb287430', 'speaking', 'Ми на пляжі.', 'Na plaži smo.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '04ea1a44-b623-505a-883a-2687162de52c', 'speaking', 'Ми відпочиваємо на острові.', 'Odmaramo se na otoku.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ed410612-b8b1-555a-9c0a-444f5d66a57c', v_lesson, 'Квиток на пором', 'Karta za trajekt', 1411, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('4d285160-d21b-51d3-b1f4-e2b20f5a49b5', 'ed410612-b8b1-555a-9c0a-444f5d66a57c', 'Oksana', 'Dvije karte za Brač i jedan auto, molim.', 'Два квитки на Брач і одне авто, будь ласка.', 1);
  perform pg_temp.turn('78423447-6747-58f6-b70d-bcae7ff3c67c', 'ed410612-b8b1-555a-9c0a-444f5d66a57c', 'Blagajnik', 'Trajekt polazi u deset sati.', 'Пором відправляється о десятій.', 2);
  perform pg_temp.turn('cbbd5971-a00e-5142-a042-0f1130f33dec', 'ed410612-b8b1-555a-9c0a-444f5d66a57c', 'Oksana', 'Koliko dugo traje vožnja?', 'Скільки триває поїздка?', 3);
  perform pg_temp.turn('43aadb09-b4f4-5d8d-a6bb-7c9f8dbb3fd0', 'ed410612-b8b1-555a-9c0a-444f5d66a57c', 'Blagajnik', 'Pedeset minuta. Čekajte u drugom redu.', 'П’ятдесят хвилин. Чекайте в другому ряду.', 4);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6faa3705-d7a9-5745-b594-6384e846a8ff', v_lesson, 'На пляжі', 'Na plaži', 1412, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('a6153179-74b8-533a-9b1d-01d624a1c52f', '6faa3705-d7a9-5745-b594-6384e846a8ff', 'Andrij', 'Gdje spavate na otoku?', 'Де ви ночуєте на острові?', 1);
  perform pg_temp.turn('15ddbd23-1438-59a7-81dc-f07c92044f05', '6faa3705-d7a9-5745-b594-6384e846a8ff', 'Petra', 'U malom apartmanu u Bolu.', 'У маленьких апартаментах у Болі.', 2);
  perform pg_temp.turn('02dab047-7aef-52e8-84d9-f21863927e13', '6faa3705-d7a9-5745-b594-6384e846a8ff', 'Andrij', 'I mi smo u Bolu! Na kojoj plaži ste?', 'Ми теж у Болі! На якому ви пляжі?', 3);
  perform pg_temp.turn('e741d6bf-1ca0-5e3b-8f65-2e18f9a348f2', '6faa3705-d7a9-5745-b594-6384e846a8ff', 'Petra', 'Na Zlatnom ratu. More je predivno, kupamo se svaki dan!', 'На Златному Раті. Море чудове, ми купаємося щодня!', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 42: Свята
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'f67bd38c-a41c-51df-b9c0-081737600fce';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.9: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.9.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 42: Свята', 'Lekcija 42: Blagdani', '["Розповісти, як ваша родина святкує", "Привітати зі святом", "Вживати naš, vaš, njihov"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'Božić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blagdan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obitelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tradicija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poklon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sretan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zajedno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vaš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'njihov', v_pos);
  v_pos := pg_temp.word(v_lesson, 'djeca', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '37935ea0-49cc-5dc7-9620-4e10e2188396', 'fill_in_the_blank', 'Ovo je ___ obitelj.', 'naša', '["naše", "naša", "našu", "naš"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a02e132a-0b41-51d1-b667-f2c6cf50e4c7', 'multiple_choice', 'Що означає «naš»?', 'наш', '["сім''я, родина", "традиція", "наш", "їхній"]'::jsonb, 'A1', 2, 'PUBLISHED', 'naš', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '367926cd-1212-5cb3-aad0-4c99a6e6c42f', 'multiple_choice', 'Що означає «njihov»?', 'їхній', '["Різдво", "свято", "подарунок", "їхній"]'::jsonb, 'A1', 3, 'PUBLISHED', 'njihov', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ec4685e8-b351-5c62-bfbc-b1a948114101', 'multiple_choice', 'Як хорватською «ваш»?', 'vaš', '["njihov", "tradicija", "zajedno", "vaš"]'::jsonb, 'A1', 4, 'PUBLISHED', 'vaš', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '940b4003-e758-58f5-8e99-180f6c62b864', 'type_answer', 'Напишіть хорватською: «традиція»', 'tradicija', null, 'A1', 5, 'PUBLISHED', 'tradicija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2dfcb53d-e4a3-50c2-b7d8-8482c8b83a40', 'type_answer', 'Напишіть хорватською: «щасливий»', 'sretan', null, 'A1', 6, 'PUBLISHED', 'sretan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '646f3e54-a96b-5068-b818-5693f7eb9540', 'sentence_builder', 'Складіть: «Наша родина святкує двадцять п’ятого грудня.»', 'Naša obitelj slavi dvadeset petog prosinca.', '["Naša", "dvadeset", "slavi", "prosinca.", "petog", "obitelj"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0d0845f9-40ec-503f-b218-dc11be00bfdb', 'sentence_builder', 'Складіть: «Наші діти люблять шоколад.»', 'Naša djeca vole čokoladu.', '["vole", "čokoladu.", "Naša", "djeca"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6945d233-bba6-59f4-99c6-4061b4c0e4f4', 'listening', 'Прослухайте і складіть фразу', 'I mi! Što je vaše tradicionalno jelo?', '["jelo?", "je", "vaše", "I", "Što", "mi!", "tradicionalno"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a87f5941-32e8-56fd-b41c-150296f77cd3', 'listening', 'Прослухайте і складіть фразу', 'Sretan Božić vama i vašoj obitelji!', '["vama", "i", "Božić", "obitelji!", "vašoj", "Sretan"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd22f4736-04d1-5fc4-9390-423d29ed6b13', 'speaking', 'Щасливого Різдва!', 'Sretan Božić!', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7b4c9a79-eb69-599a-b617-ba9ebf8230bc', 'speaking', 'Це наша традиція.', 'To je naša tradicija.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ae41c9a6-560e-5a09-bdc0-7cd74e0cafb1', v_lesson, 'Різдво', 'Božić', 1421, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('c1bee22e-6f0f-50f6-a13a-da81fb8ea44d', 'ae41c9a6-560e-5a09-bdc0-7cd74e0cafb1', 'Ana', 'Koji je najveći blagdan u vašoj obitelji?', 'Яке найбільше свято у вашій родині?', 1);
  perform pg_temp.turn('c50734dd-89d8-5a3c-b20c-1194f8eeff9d', 'ae41c9a6-560e-5a09-bdc0-7cd74e0cafb1', 'Iryna', 'Božić. Naša obitelj slavi dvadeset petog prosinca.', 'Різдво. Наша родина святкує двадцять п’ятого грудня.', 2);
  perform pg_temp.turn('361d75d0-2a5e-5f61-bb3b-0b2d8d530d3b', 'ae41c9a6-560e-5a09-bdc0-7cd74e0cafb1', 'Ana', 'I mi! Što je vaše tradicionalno jelo?', 'І ми! Яка ваша традиційна страва?', 3);
  perform pg_temp.turn('128ba101-0bb7-5951-a699-70cdbc624fba', 'ae41c9a6-560e-5a09-bdc0-7cd74e0cafb1', 'Iryna', 'Kutja. A vaše?', 'Кутя. А ваша?', 4);
  perform pg_temp.turn('be79c5a3-d5c3-5666-ac3b-d51ae11a9319', 'ae41c9a6-560e-5a09-bdc0-7cd74e0cafb1', 'Ana', 'Bakalar i sarma. Moja baka kuha najbolju sarmu!', 'Тріска й сарма. Моя бабуся готує найкращу сарму!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4fe44aa5-3595-5214-827a-3e5de2c99c68', v_lesson, 'Подарунок', 'Poklon', 1422, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('ed20fcea-3d9d-5513-abe1-066f2789a4aa', '4fe44aa5-3595-5214-827a-3e5de2c99c68', 'Marko', 'Ovo je za tebe i tvoju djecu.', 'Це для тебе і твоїх дітей.', 1);
  perform pg_temp.turn('c84443f8-8f2b-5bc1-898f-c482afd1cd95', '4fe44aa5-3595-5214-827a-3e5de2c99c68', 'Taras', 'Hvala puno! Naša djeca vole čokoladu.', 'Дуже дякую! Наші діти люблять шоколад.', 2);
  perform pg_temp.turn('80527b56-7927-54f7-b6bc-bf51bfde5461', '4fe44aa5-3595-5214-827a-3e5de2c99c68', 'Marko', 'Sretan Božić vama i vašoj obitelji!', 'Щасливого Різдва вам і вашій родині!', 3);
  perform pg_temp.turn('3984f29b-8a9c-5502-8624-bc0dc044dc71', '4fe44aa5-3595-5214-827a-3e5de2c99c68', 'Taras', 'Hvala, i tebi i tvojima!', 'Дякую, і тобі, і твоїм рідним!', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 43: Краї Хорватії
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '8633c234-d638-57f1-ad92-1c78be43fb07';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.9: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.9.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 43: Краї Хорватії', 'Lekcija 43: Hrvatski krajevi', '["Сказати, де розташоване місто: на півночі, на півдні", "Розповісти про різні краї Хорватії", "Порівняти міста: veći, ljepši"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kraj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sjever', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jug', v_pos);
  v_pos := pg_temp.word(v_lesson, 'istok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zapad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rijeka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ravnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glavni grad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poznat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maslinovo ulje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'način', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvučati', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '32212ec4-0ddf-5b24-8b3f-0a78954e203d', 'fill_in_the_blank', 'Split je ___ od Osijeka.', 'veći', '["veliki", "najveći", "velik", "veći"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f1c36ca-cd59-54ed-b82e-59ec8cfb37ae', 'multiple_choice', 'Що означає «rijeka»?', 'річка', '["річка", "південь", "рівнина", "схід"]'::jsonb, 'A1', 2, 'PUBLISHED', 'rijeka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '905deb83-bb67-52d5-822b-53a04ac50651', 'multiple_choice', 'Що означає «glavni grad»?', 'столиця', '["південь", "спосіб", "схід", "столиця"]'::jsonb, 'A1', 3, 'PUBLISHED', 'glavni grad', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '59654261-e3a6-5abf-9621-c3d3a3402c5f', 'multiple_choice', 'Як хорватською «північ»?', 'sjever', '["način", "maslinovo ulje", "sjever", "rijeka"]'::jsonb, 'A1', 4, 'PUBLISHED', 'sjever', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dcbaaea8-cd30-5d25-a58a-36d8d272f394', 'type_answer', 'Напишіть хорватською: «схід»', 'istok', null, 'A1', 5, 'PUBLISHED', 'istok', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '639acd09-a4a8-5b77-b60b-9ce0a94e78fa', 'type_answer', 'Напишіть хорватською: «південь»', 'jug', null, 'A1', 6, 'PUBLISHED', 'jug', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '13172209-e42e-5099-8581-7ca62274e65d', 'sentence_builder', 'Складіть: «Спліт на півдні Хорватії.»', 'Split je na jugu Hrvatske.', '["na", "Split", "jugu", "je", "Hrvatske."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '25c5f800-d3d0-5687-9fbf-c91be2867afc', 'sentence_builder', 'Складіть: «Кожен гарний по-своєму.»', 'Svaki je lijep na svoj način.', '["na", "svoj", "način.", "je", "lijep", "Svaki"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7bd2f4a5-dc3b-517e-a5a4-271665efe786', 'listening', 'Прослухайте і складіть фразу', 'A Ana je iz Slavonije?', '["je", "Slavonije?", "iz", "A", "Ana"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e22f666f-676c-5512-b172-d1d4b6eabdef', 'listening', 'Прослухайте і складіть фразу', 'Oko tri sata autom. Na zapadu je.', '["zapadu", "autom.", "tri", "sata", "Na", "Oko", "je."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '118a083c-b240-5732-b607-8b21db278879', 'speaking', 'Загреб — столиця Хорватії.', 'Zagreb je glavni grad Hrvatske.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ff414850-bbbb-5eb4-82d2-c2bb75fa0885', 'speaking', 'Я живу на півночі.', 'Živim na sjeveru.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('924ca9af-4b03-5128-9db0-76fb98f9b934', v_lesson, 'Звідки ти?', 'Odakle si?', 1431, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('289cc6b4-969c-5a06-8079-a63e56d66f2a', '924ca9af-4b03-5128-9db0-76fb98f9b934', 'Iryna', 'Marko, ti si iz Dalmacije?', 'Марку, ти з Далмації?', 1);
  perform pg_temp.turn('97e3dbff-d799-50d2-a879-92a8529ed75f', '924ca9af-4b03-5128-9db0-76fb98f9b934', 'Marko', 'Da, iz Splita. To je na jugu, na moru.', 'Так, зі Спліта. Це на півдні, біля моря.', 2);
  perform pg_temp.turn('e30c76af-441b-5e7d-8d0d-d2c7115a9409', '924ca9af-4b03-5128-9db0-76fb98f9b934', 'Iryna', 'A Ana je iz Slavonije?', 'А Ана зі Славонії?', 3);
  perform pg_temp.turn('4e3b0012-06ce-5c4d-9d5c-27793c9658a8', '924ca9af-4b03-5128-9db0-76fb98f9b934', 'Marko', 'Da, iz Osijeka, na istoku. Tamo su ravnice i rijeke.', 'Так, з Осієка, на сході. Там рівнини й річки.', 4);
  perform pg_temp.turn('5cd3ad24-5472-5e54-b41a-385678dba706', '924ca9af-4b03-5128-9db0-76fb98f9b934', 'Iryna', 'Koji je kraj najljepši?', 'Який край найкрасивіший?', 5);
  perform pg_temp.turn('41601682-1ee0-54ae-9fb4-830512220b06', '924ca9af-4b03-5128-9db0-76fb98f9b934', 'Marko', 'Svaki je lijep na svoj način!', 'Кожен гарний по-своєму!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d9dd0b07-8133-56ae-8d2d-04401378d1d4', v_lesson, 'Поїздка в Істрію', 'Izlet u Istru', 1432, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('2b6cb4cf-e8f5-52e7-966c-64ee27fec5d6', 'd9dd0b07-8133-56ae-8d2d-04401378d1d4', 'Taras', 'Je li Istra daleko od Zagreba?', 'Істрія далеко від Загреба?', 1);
  perform pg_temp.turn('202e0575-67de-51d2-81fe-7da5d68737c4', 'd9dd0b07-8133-56ae-8d2d-04401378d1d4', 'Lana', 'Oko tri sata autom. Na zapadu je.', 'Близько трьох годин машиною. Вона на заході.', 2);
  perform pg_temp.turn('c0e6eb16-1d26-5ea1-ae27-4a011ef7579c', 'd9dd0b07-8133-56ae-8d2d-04401378d1d4', 'Taras', 'Po čemu je Istra poznata?', 'Чим відома Істрія?', 3);
  perform pg_temp.turn('c8eb8496-2b22-5091-8b4b-cd5a92aac078', 'd9dd0b07-8133-56ae-8d2d-04401378d1d4', 'Lana', 'Po tartufima, maslinovom ulju i starim gradovima.', 'Трюфелями, оливковою олією і старими містечками.', 4);
  perform pg_temp.turn('08ef8cbd-946b-50d6-b224-f62a23d8805f', 'd9dd0b07-8133-56ae-8d2d-04401378d1d4', 'Taras', 'Zvuči odlično!', 'Звучить чудово!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 44: Хорватські звичаї
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '2fabcd03-324d-5355-b96e-022723fbeda7';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.9: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.9.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 44: Хорватські звичаї', 'Lekcija 44: Hrvatski običaji', '["Зрозуміти, чому кава в Хорватії — це зустріч", "Поводитися в гостях за столом", "Сказати тост: Živjeli!"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'običaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'druženje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'terasa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sjediti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pričati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dugo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobro došli', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sjesti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'živjeli', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tradicionalan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'piće', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '9e5827c5-d200-58d8-8782-9da0d8c66f03', 'fill_in_the_blank', 'Hrvati ___ kavu na terasi.', 'piju', '["piju", "piješ", "pijem", "pije"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7b1e4f10-b1be-5971-9c2a-7f183d79d906', 'multiple_choice', 'Що означає «živjeli»?', 'будьмо! (тост)', '["напій", "будьмо! (тост)", "сидіти", "звичай"]'::jsonb, 'A1', 2, 'PUBLISHED', 'živjeli', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f67c144f-8fca-5fdb-af70-08f8cde18cd0', 'multiple_choice', 'Що означає «gost»?', 'гість / відвідувач', '["будьмо! (тост)", "довго", "гість / відвідувач", "розповідати; розмовляти"]'::jsonb, 'A1', 3, 'PUBLISHED', 'gost', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '728bd2be-762a-567f-b0f3-15c2f95c9057', 'multiple_choice', 'Як хорватською «ласкаво просимо»?', 'dobro došli', '["dobro došli", "pričati", "živjeli", "običaj"]'::jsonb, 'A1', 4, 'PUBLISHED', 'dobro došli', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '68a56491-751f-59aa-81dc-696585299d00', 'type_answer', 'Напишіть хорватською: «традиційний»', 'tradicionalan', null, 'A1', 5, 'PUBLISHED', 'tradicionalan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9aa4957c-ae35-5d9c-b105-c2189bb3ac09', 'type_answer', 'Напишіть хорватською: «тераса»', 'terasa', null, 'A1', 6, 'PUBLISHED', 'terasa', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '84f0dbb3-b7bd-5e1b-a0b4-78ddc75ade3f', 'sentence_builder', 'Складіть: «Кава — це не просто напій.»', 'Kava nije samo piće.', '["nije", "piće.", "samo", "Kava"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '474532a4-a9c4-5ce2-bf35-e06927f0eb3d', 'sentence_builder', 'Складіть: «Сідайте, обід готовий.»', 'Sjednite, ručak je spreman.', '["Sjednite,", "je", "spreman.", "ručak"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3e86de47-4052-56bf-8354-0cfe858a82c6', 'listening', 'Прослухайте і складіть фразу', 'Naravno! Sjedimo na terasi i pričamo.', '["pričamo.", "na", "terasi", "Sjedimo", "i", "Naravno!"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eda04e04-b8ca-50a3-a11b-f97985dbb64e', 'listening', 'Прослухайте і складіть фразу', 'Hvala, dušo! Živjeli!', '["Živjeli!", "dušo!", "Hvala,"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eec9c478-f2f5-5583-bb1f-0bb9bf644abd', 'speaking', 'Будьмо!', 'Živjeli!', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c1537581-c108-5564-996d-35e5b1652189', 'speaking', 'Ласкаво просимо!', 'Dobro došli!', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('91b5a690-9711-5104-8831-55789fcb6081', v_lesson, 'Кава — це зустріч', 'Kava je druženje', 1441, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('6cdbfb3a-e428-51c8-8770-be70b412af2f', '91b5a690-9711-5104-8831-55789fcb6081', 'Iryna', 'Zašto Hrvati piju kavu tako dugo?', 'Чому хорвати так довго п’ють каву?', 1);
  perform pg_temp.turn('ade344f6-0096-5450-b587-5a84f9e0703e', '91b5a690-9711-5104-8831-55789fcb6081', 'Ivan', 'Kava nije samo piće. To je druženje!', 'Кава — це не просто напій. Це спілкування!', 2);
  perform pg_temp.turn('8628c2d4-1830-5a08-8d19-358b2bf5adb8', '91b5a690-9711-5104-8831-55789fcb6081', 'Iryna', 'Sat vremena za jednu kavu?', 'Година на одну каву?', 3);
  perform pg_temp.turn('1e2627de-bac7-51f4-9206-c6a069e71eae', '91b5a690-9711-5104-8831-55789fcb6081', 'Ivan', 'Naravno! Sjedimo na terasi i pričamo.', 'Звісно! Сидимо на терасі й розмовляємо.', 4);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c5bfaa23-7a1d-5def-b9a8-08ee4715a852', v_lesson, 'Недільний обід', 'Nedjeljni ručak', 1442, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('4ab7b73a-0228-51ea-99c8-5baee2b82c89', 'c5bfaa23-7a1d-5def-b9a8-08ee4715a852', 'Baka', 'Dobro došli! Sjednite, ručak je spreman.', 'Ласкаво просимо! Сідайте, обід готовий.', 1);
  perform pg_temp.turn('0d3fb02d-338d-51c5-b2d7-1deaff18f3ae', 'c5bfaa23-7a1d-5def-b9a8-08ee4715a852', 'Taras', 'Hvala! Ovo vino je za Vas.', 'Дякую! Це вино для вас.', 2);
  perform pg_temp.turn('3b8eecfc-9949-5a02-b0d1-14d319be5e3f', 'c5bfaa23-7a1d-5def-b9a8-08ee4715a852', 'Baka', 'Hvala, dušo! Živjeli!', 'Дякую, любий! Будьмо!', 3);
  perform pg_temp.turn('7a5aabc2-6cbc-535b-b74f-f60e9fcf5b0c', 'c5bfaa23-7a1d-5def-b9a8-08ee4715a852', 'Taras', 'Živjeli! U Ukrajini kažemo «Budmo!».', 'Будьмо! В Україні кажемо «Будьмо!».', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 45: Розкажіть про себе
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'fc1baff0-0e48-5676-bd3c-47d88d31e582';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.10: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.10.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 45: Розкажіть про себе', 'Lekcija 45: Recite nešto o sebi', '["Розповісти про себе, роботу й родину", "Пояснити, чому ви вчите хорватську", "Поставити питання новому знайомому"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'živjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'raditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'učiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jezik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obitelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'djeca', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hobi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razgovarati', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd53e4466-3081-5dc3-bab0-fe12b20f3169', 'fill_in_the_blank', '___ učite hrvatski? — Zato što radim ovdje.', 'Zašto', '["Zašto", "Gdje", "Kada", "Kako"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fde24d06-ec02-5d6d-81e2-6a9a92756310', 'multiple_choice', 'Що означає «grad»?', 'місто', '["робота / справа", "місто", "квартира", "розмовляти"]'::jsonb, 'A1', 2, 'PUBLISHED', 'grad', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f67f1ab8-6d1a-5813-a514-cab32f1acbe3', 'multiple_choice', 'Що означає «godina»?', 'рік', '["квартира", "рік", "сім''я, родина", "мова"]'::jsonb, 'A1', 3, 'PUBLISHED', 'godina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '674366c2-066a-5a17-86fe-16b000006958', 'multiple_choice', 'Як хорватською «жити»?', 'živjeti', '["raditi", "godina", "živjeti", "učiti"]'::jsonb, 'A1', 4, 'PUBLISHED', 'živjeti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'de91415c-99cc-5667-8d9a-e3adc0902e59', 'type_answer', 'Напишіть хорватською: «вчити (ся)»', 'učiti', null, 'A1', 5, 'PUBLISHED', 'učiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f5383fc-a7be-5942-8012-449016094516', 'type_answer', 'Напишіть хорватською: «діти»', 'djeca', null, 'A1', 6, 'PUBLISHED', 'djeca', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c95c7996-3162-5549-82bd-7e6e61bc5cfc', 'sentence_builder', 'Складіть: «Розкажіть щось про себе.»', 'Recite nešto o sebi.', '["o", "Recite", "nešto", "sebi."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fbc551e5-559f-5df0-8353-dafb2bf14f12', 'sentence_builder', 'Складіть: «Що ти робиш на вихідних?»', 'Što radiš vikendom?', '["vikendom?", "Što", "radiš"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a190b0e8-10f5-5e6f-9054-0e23366dc867', 'listening', 'Прослухайте і складіть фразу', 'Čime se bavite?', '["se", "bavite?", "Čime"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8171f65a-6948-5c21-9e4f-bbbed1f57167', 'listening', 'Прослухайте і складіть фразу', 'Tri godine. Volim Rijeku, ali mi nedostaje dom.', '["Volim", "dom.", "Tri", "nedostaje", "godine.", "mi", "Rijeku,", "ali"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2a8e4d22-f2d0-5a75-b5a5-12d33ecfe666', 'speaking', 'Я вчу хорватську, бо працюю тут.', 'Učim hrvatski jer radim ovdje.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0bc35778-f844-512b-a4d4-5007ce863460', 'speaking', 'Чим ви займаєтеся?', 'Čime se bavite?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2bffcc25-5ca2-5e5f-912f-5e35138384aa', v_lesson, 'На курсі', 'Na tečaju', 1451, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('ac392a0f-1690-536f-8f95-65e966b320da', '2bffcc25-5ca2-5e5f-912f-5e35138384aa', 'Profesorica', 'Recite nešto o sebi.', 'Розкажіть щось про себе.', 1);
  perform pg_temp.turn('ac1e91d7-5d1c-5336-ad8f-5a38e2d19478', '2bffcc25-5ca2-5e5f-912f-5e35138384aa', 'Oleg', 'Zovem se Oleg. Imam četrdeset godina i živim u Rijeci.', 'Мене звати Олег. Мені сорок років, і я живу в Рієці.', 2);
  perform pg_temp.turn('2b257e7c-f0b6-5919-a0e5-4507fdb12124', '2bffcc25-5ca2-5e5f-912f-5e35138384aa', 'Profesorica', 'Čime se bavite?', 'Чим ви займаєтеся?', 3);
  perform pg_temp.turn('c934cfba-4bbb-5c7a-a4f4-508a5aa08f10', '2bffcc25-5ca2-5e5f-912f-5e35138384aa', 'Oleg', 'Radim u luci. Imam ženu i dvoje djece.', 'Працюю в порту. У мене дружина і двоє дітей.', 4);
  perform pg_temp.turn('d9b3244c-a666-55e8-8e09-3db03522a291', '2bffcc25-5ca2-5e5f-912f-5e35138384aa', 'Profesorica', 'Zašto učite hrvatski?', 'Чому ви вчите хорватську?', 5);
  perform pg_temp.turn('a33110dc-17a7-5958-adde-546e2bc63daf', '2bffcc25-5ca2-5e5f-912f-5e35138384aa', 'Oleg', 'Zato što želim razgovarati s kolegama.', 'Тому що хочу розмовляти з колегами.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ff9314b3-e6ae-54d1-96f2-2b73af4e3846', v_lesson, 'Нова знайома', 'Nova poznanica', 1452, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('614888df-74b0-5073-9f81-98e3b60670de', 'ff9314b3-e6ae-54d1-96f2-2b73af4e3846', 'Iva', 'Koliko dugo si u Hrvatskoj?', 'Як довго ти в Хорватії?', 1);
  perform pg_temp.turn('8ee8d1e8-b026-5d0f-84f1-67b539ba0a38', 'ff9314b3-e6ae-54d1-96f2-2b73af4e3846', 'Oksana', 'Tri godine. Volim Rijeku, ali mi nedostaje dom.', 'Три роки. Люблю Рієку, але сумую за домом.', 2);
  perform pg_temp.turn('cfc82ad4-7d42-5b46-809d-db19e00bd383', 'ff9314b3-e6ae-54d1-96f2-2b73af4e3846', 'Iva', 'Razumijem. Što radiš vikendom?', 'Розумію. Що ти робиш на вихідних?', 3);
  perform pg_temp.turn('6a0396b6-926a-538e-aebe-b674fb9ca315', 'ff9314b3-e6ae-54d1-96f2-2b73af4e3846', 'Oksana', 'Šetam uz more i učim kuhati hrvatska jela.', 'Гуляю вздовж моря і вчуся готувати хорватські страви.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 46: Пошта і банкомат
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '1c468857-b9aa-5143-aa84-6ea02aa2443c';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.10: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.10.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 46: Пошта і банкомат', 'Lekcija 46: Pošta i bankomat', '["Надіслати посилку", "Знайти банкомат", "Вживати kod banke, preko puta pošte, do centra"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'pošta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'banka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bankomat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'paket', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pismo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poslati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bankovni račun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'novac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šalter', v_pos);
  v_pos := pg_temp.word(v_lesson, 'red', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obrazac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blizu', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8183c3e-9555-5331-9a81-b8605a3b9dff', 'fill_in_the_blank', 'Bankomat je preko puta ___.', 'pošte', '["poštu", "pošti", "pošta", "pošte"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2e0af783-4b8a-5a29-99b0-b8cd69666f54', 'multiple_choice', 'Що означає «poslati»?', 'надіслати / відправити', '["пошта", "надіслати / відправити", "банк", "черга"]'::jsonb, 'A1', 2, 'PUBLISHED', 'poslati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '69b249de-a6dc-5f68-9640-1263908b6207', 'multiple_choice', 'Що означає «blizu»?', 'поруч / близько', '["банкомат", "поруч / близько", "бланк / анкета", "гроші"]'::jsonb, 'A1', 3, 'PUBLISHED', 'blizu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f91b7bc8-fb3c-58c1-afcb-c027283ea35e', 'multiple_choice', 'Як хорватською «бланк / анкета»?', 'obrazac', '["pismo", "obrazac", "red", "poslati"]'::jsonb, 'A1', 4, 'PUBLISHED', 'obrazac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '629fa843-1cc4-5d48-a279-6786df97beae', 'type_answer', 'Напишіть хорватською: «черга»', 'red', null, 'A1', 5, 'PUBLISHED', 'red', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'da6f4775-eb5c-5e9a-ad96-b1b1789be935', 'type_answer', 'Напишіть хорватською: «пошта»', 'pošta', null, 'A1', 6, 'PUBLISHED', 'pošta', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'decc5a5d-aa2b-5c22-8438-7888f6a47896', 'sentence_builder', 'Складіть: «Я хочу надіслати цю посилку в Україну.»', 'Želim poslati ovaj paket u Ukrajinu.', '["ovaj", "paket", "Želim", "u", "poslati", "Ukrajinu."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3f86575a-e3c5-5d59-9f78-310daf7b3d93', 'sentence_builder', 'Складіть: «Тут поблизу є якийсь банкомат?»', 'Ima li ovdje blizu neki bankomat?', '["bankomat?", "ovdje", "li", "Ima", "blizu", "neki"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a60395d5-4cf6-59e2-8eec-66f05b57e2ad', 'listening', 'Прослухайте і складіть фразу', 'Oko deset dana.', '["Oko", "dana.", "deset"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'af281d9c-cfa5-565b-bf3d-ac4085e63d9f', 'listening', 'Прослухайте і складіть фразу', 'Nije, dvije minute pješice.', '["Nije,", "dvije", "pješice.", "minute"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd7c1990-b037-50e5-92af-b3287e87901e', 'speaking', 'Де найближча пошта?', 'Gdje je najbliža pošta?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '35d6f393-fab6-53d5-be99-841b599fc9e9', 'speaking', 'Я хочу відкрити рахунок.', 'Želim otvoriti račun.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('315b0e9a-e716-5d36-b70e-18cc134885bd', v_lesson, 'На пошті', 'Na pošti', 1461, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('9ed287ac-2ca7-5f40-941a-780ff7416b4f', '315b0e9a-e716-5d36-b70e-18cc134885bd', 'Službenica', 'Sljedeći, molim.', 'Наступний, будь ласка.', 1);
  perform pg_temp.turn('9b076c9d-a92b-5a47-8b18-5f353d01d7d6', '315b0e9a-e716-5d36-b70e-18cc134885bd', 'Taras', 'Želim poslati ovaj paket u Ukrajinu.', 'Я хочу надіслати цю посилку в Україну.', 2);
  perform pg_temp.turn('6c2c57fd-ac91-50c9-9cce-b77578193010', '315b0e9a-e716-5d36-b70e-18cc134885bd', 'Službenica', 'Ispunite ovaj obrazac, molim.', 'Заповніть цей бланк, будь ласка.', 3);
  perform pg_temp.turn('13c446a8-c23c-5961-bf29-6530a0e96366', '315b0e9a-e716-5d36-b70e-18cc134885bd', 'Taras', 'Koliko dugo putuje?', 'Скільки часу вона йде?', 4);
  perform pg_temp.turn('ba712d0e-96a1-578d-b18d-6d6d5ad4d082', '315b0e9a-e716-5d36-b70e-18cc134885bd', 'Službenica', 'Oko deset dana.', 'Близько десяти днів.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('54c57bec-9cf4-58a3-857a-f3125c5b348f', v_lesson, 'Де банкомат?', 'Gdje je bankomat?', 1462, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('1c2e2eef-7b2b-5d2b-8286-2f3b8209facc', '54c57bec-9cf4-58a3-857a-f3125c5b348f', 'Olena', 'Oprostite, ima li ovdje blizu neki bankomat?', 'Вибачте, тут поблизу є якийсь банкомат?', 1);
  perform pg_temp.turn('5afcf091-1668-550b-8f60-7e815c1d3146', '54c57bec-9cf4-58a3-857a-f3125c5b348f', 'Prolaznik', 'Ima, kod banke, preko puta pošte.', 'Є, біля банку, навпроти пошти.', 2);
  perform pg_temp.turn('f8882c82-4b5c-56c5-8834-74c7c9ccda06', '54c57bec-9cf4-58a3-857a-f3125c5b348f', 'Olena', 'Je li daleko od tržnice?', 'Це далеко від ринку?', 3);
  perform pg_temp.turn('1e7c6392-d25b-5d63-b868-64708579afec', '54c57bec-9cf4-58a3-857a-f3125c5b348f', 'Prolaznik', 'Nije, dvije minute pješice.', 'Ні, дві хвилини пішки.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 47: Моє життя в Хорватії
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.10: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.10.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 47: Моє життя в Хорватії', 'Lekcija 47: Moj život u Hrvatskoj', '["Розповісти про свої плани на літо", "Сказати, що у вас уже є в Хорватії", "Підсумувати, що ви вмієте хорватською"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'život', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijatelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'more', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dolaziti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'doći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ići', v_pos);
  v_pos := pg_temp.word(v_lesson, 'htjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posjetiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sretan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zajedno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pokazati', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '7b7200e0-3c6e-54a1-9ad2-d27d6326ad79', 'fill_in_the_blank', 'Moja mama ___ k meni.', 'dolazi', '["dolaze", "dolazi", "dolaziš", "dolazim"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '546ae909-fcaf-5388-a72b-a59e78fa16cf', 'multiple_choice', 'Що означає «život»?', 'життя', '["життя", "хотіти", "щасливий", "приходити"]'::jsonb, 'A1', 2, 'PUBLISHED', 'život', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf3d40a1-612b-55e2-868e-760eaa41c090', 'multiple_choice', 'Що означає «sretan»?', 'щасливий', '["життя", "щасливий", "друг", "море"]'::jsonb, 'A1', 3, 'PUBLISHED', 'sretan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '12939ac8-3e5e-52f3-9b5e-68785f19ac24', 'multiple_choice', 'Як хорватською «разом»?', 'zajedno', '["pokazati", "ići", "život", "zajedno"]'::jsonb, 'A1', 4, 'PUBLISHED', 'zajedno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '141d81b5-f1bf-5396-9f79-a74417e36c8a', 'type_answer', 'Напишіть хорватською: «місто»', 'grad', null, 'A1', 5, 'PUBLISHED', 'grad', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '083ab7d7-f632-565d-a4fe-a966b6836fec', 'type_answer', 'Напишіть хорватською: «прийти»', 'doći', null, 'A1', 6, 'PUBLISHED', 'doći', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '70e643d1-90a4-59f1-bcea-e93dca02fb23', 'sentence_builder', 'Складіть: «Моя мама приїжджає до мене.»', 'Moja mama dolazi k meni.', '["k", "Moja", "meni.", "mama", "dolazi"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '63e5500d-1f7f-5987-b331-e8c07fbd1bf3', 'sentence_builder', 'Складіть: «Щодня розумію більше.»', 'Svaki dan razumijem više.', '["više.", "Svaki", "dan", "razumijem"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '78d34f96-ace8-59d4-a9f8-6b005fcc955c', 'listening', 'Прослухайте і складіть фразу', 'Super! Što želite vidjeti?', '["želite", "vidjeti?", "Što", "Super!"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '322355da-de1a-5fa9-834f-921e8d546626', 'listening', 'Прослухайте і складіть фразу', 'Jesam. Imam posao, stan i prijatelje.', '["stan", "Jesam.", "i", "posao,", "prijatelje.", "Imam"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '398b2d78-b9a4-5a01-b9d3-c280a78cc94b', 'speaking', 'Мені тут добре.', 'Dobro mi je ovdje.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '76e410e0-8454-5b7c-878a-5fe8c94f99d0', 'speaking', 'Тепер я можу розмовляти хорватською.', 'Sada mogu razgovarati na hrvatskom.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1827ec73-ba93-5991-b4ad-597db8705634', v_lesson, 'Плани на літо', 'Planovi za ljeto', 1471, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('d7549f9f-baf5-56f1-9679-694cbab4cb8c', '1827ec73-ba93-5991-b4ad-597db8705634', 'Ivan', 'Ideš li ljeti u Ukrajinu?', 'Ти їдеш улітку в Україну?', 1);
  perform pg_temp.turn('0e9fdc4a-dea3-5133-927c-3cfe386f2f7f', '1827ec73-ba93-5991-b4ad-597db8705634', 'Iryna', 'Ne idem. Moja mama dolazi k meni.', 'Ні. Моя мама приїжджає до мене.', 2);
  perform pg_temp.turn('66f18a6d-1644-59f6-895a-8d1ed8b597de', '1827ec73-ba93-5991-b4ad-597db8705634', 'Ivan', 'Super! Što želite vidjeti?', 'Чудово! Що ви хочете побачити?', 3);
  perform pg_temp.turn('427589e7-148a-531f-8633-1978a3e963aa', '1827ec73-ba93-5991-b4ad-597db8705634', 'Iryna', 'Želim joj pokazati Plitvice i more.', 'Хочу показати їй Плітвіце й море.', 4);
  perform pg_temp.turn('2a2fb11b-a27a-5784-b2ae-a0066e4eed09', '1827ec73-ba93-5991-b4ad-597db8705634', 'Ivan', 'Ako hoćete, mogu vas voziti.', 'Якщо хочете, можу вас повозити.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('abc34f51-8f2f-5121-a748-8ff6a048e6f3', v_lesson, 'Рік у Хорватії', 'Godina u Hrvatskoj', 1472, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('73b49471-5d2a-5067-a80b-46278896b2be', 'abc34f51-8f2f-5121-a748-8ff6a048e6f3', 'Ana', 'Jesi li sretna ovdje?', 'Ти щаслива тут?', 1);
  perform pg_temp.turn('35de419d-10da-53b8-9270-b40847e7d3e0', 'abc34f51-8f2f-5121-a748-8ff6a048e6f3', 'Iryna', 'Jesam. Imam posao, stan i prijatelje.', 'Так. У мене є робота, квартира й друзі.', 2);
  perform pg_temp.turn('f80a399a-7451-59c7-ae1e-1c240fca4452', 'abc34f51-8f2f-5121-a748-8ff6a048e6f3', 'Ana', 'A jezik?', 'А мова?', 3);
  perform pg_temp.turn('5d6286f7-03c3-53bf-a46c-eaf9e24a5de9', 'abc34f51-8f2f-5121-a748-8ff6a048e6f3', 'Iryna', 'Svaki dan razumijem više. Sada mogu razgovarati s tobom!', 'Щодня розумію більше. Тепер можу розмовляти з тобою!', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 48: Дитячий садок і школа
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '42c31cfb-8680-5450-8453-245f3abd475a';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.10: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.10.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 48: Дитячий садок і школа', 'Lekcija 48: Vrtić i škola', '["Записати дитину в садок", "Знати, які документи потрібні", "Поговорити з учителькою"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'vrtić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upisati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rodni list', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cijepljenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjesto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ravnateljica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'učenica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zadaća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slabo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'produženi boravak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'roditeljski sastanak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'učiteljica', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '755482e7-c777-53ca-b131-e6eb384275ea', 'fill_in_the_blank', 'Ima li ___ u vrtiću?', 'mjesta', '["mjestom", "mjesta", "mjesto", "mjestu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '888ca97e-55eb-557c-85f5-da4fcb143b05', 'multiple_choice', 'Що означає «učiteljica»?', 'учителька', '["слабо; погано", "дитячий садок", "учителька", "домашнє завдання"]'::jsonb, 'A1', 2, 'PUBLISHED', 'učiteljica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b82923bb-5ae1-5494-8a3a-bdefbba49ae8', 'multiple_choice', 'Що означає «zadaća»?', 'домашнє завдання', '["директорка (школи, садка)", "дитячий садок", "місце", "домашнє завдання"]'::jsonb, 'A1', 3, 'PUBLISHED', 'zadaća', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '25e2ff9c-39f9-52e9-a4ca-98f161069470', 'multiple_choice', 'Як хорватською «щеплення»?', 'cijepljenje', '["rodni list", "učiteljica", "vrtić", "cijepljenje"]'::jsonb, 'A1', 4, 'PUBLISHED', 'cijepljenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '76e12f6e-a4d7-5eb3-b088-4a9e2727764b', 'type_answer', 'Напишіть хорватською: «директорка (школи, садка)»', 'ravnateljica', null, 'A1', 5, 'PUBLISHED', 'ravnateljica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1aa39a5b-be32-543b-8844-00178bb54a39', 'type_answer', 'Напишіть хорватською: «учениця»', 'učenica', null, 'A1', 6, 'PUBLISHED', 'učenica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '77d040a9-1573-5d27-8f75-0c90c529d6a4', 'sentence_builder', 'Складіть: «Я хочу записати сина в садок.»', 'Želim upisati sina u vrtić.', '["Želim", "upisati", "u", "sina", "vrtić."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '205f968c-8afc-57de-b3c8-0c392824d6b0', 'sentence_builder', 'Складіть: «Коли батьківські збори?»', 'Kada je roditeljski sastanak?', '["je", "sastanak?", "roditeljski", "Kada"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f2fea7fa-b879-50be-89ec-6728c1fa42f0', 'listening', 'Прослухайте і складіть фразу', 'Četiri. Koji su dokumenti potrebni?', '["su", "Koji", "dokumenti", "Četiri.", "potrebni?"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '22ca1450-f441-5899-899b-01e09139336a', 'listening', 'Прослухайте і складіть фразу', 'Hm. Ona još slabo čita hrvatski.', '["Ona", "slabo", "Hm.", "još", "čita", "hrvatski."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4db5bd53-0ffc-536c-89e6-58eedf33428f', 'speaking', 'Мій син ходить у садок.', 'Moj sin ide u vrtić.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '61d4613f-6d63-5c44-b855-11ff82898d87', 'speaking', 'Що задали додому?', 'Što je za zadaću?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1eabbc55-0245-5d95-92be-00b4dd1f4b22', v_lesson, 'Запис у садок', 'Upis u vrtić', 1481, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('afc650f6-74c6-578d-a889-1bbc28de23e0', '1eabbc55-0245-5d95-92be-00b4dd1f4b22', 'Mama', 'Dobar dan, želim upisati sina u vrtić.', 'Добрий день, я хочу записати сина в садок.', 1);
  perform pg_temp.turn('22da15b1-6fd1-55dd-be15-5dcb430497b4', '1eabbc55-0245-5d95-92be-00b4dd1f4b22', 'Ravnateljica', 'Koliko ima godina?', 'Скільки йому років?', 2);
  perform pg_temp.turn('b16aec0c-9907-5f91-a915-7e920611a784', '1eabbc55-0245-5d95-92be-00b4dd1f4b22', 'Mama', 'Četiri. Koji su dokumenti potrebni?', 'Чотири. Які документи потрібні?', 3);
  perform pg_temp.turn('2ca15bf5-da56-5962-a075-3ebbbb3790e9', '1eabbc55-0245-5d95-92be-00b4dd1f4b22', 'Ravnateljica', 'Rodni list, potvrda o cijepljenju i Vaš OIB.', 'Свідоцтво про народження, довідка про щеплення і ваш OIB.', 4);
  perform pg_temp.turn('61356c00-84d3-5cf4-9706-8088d6fcf175', '1eabbc55-0245-5d95-92be-00b4dd1f4b22', 'Mama', 'Ima li mjesta od rujna?', 'Чи є місце з вересня?', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('81710b48-fe17-57cd-ae5f-db7f9ae87afe', v_lesson, 'Розмова з учителькою', 'Razgovor s učiteljicom', 1482, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('f468a8dc-aa5b-5f2f-8ab5-81416c9cf488', '81710b48-fe17-57cd-ae5f-db7f9ae87afe', 'Učiteljica', 'Vaša kći je dobra učenica, ali ne piše zadaću.', 'Ваша донька хороша учениця, але не робить домашнього завдання.', 1);
  perform pg_temp.turn('9fd8605c-e01b-5b95-bb9b-896ae6e0fd7b', '81710b48-fe17-57cd-ae5f-db7f9ae87afe', 'Tata', 'Hm. Ona još slabo čita hrvatski.', 'Хм. Вона ще погано читає хорватською.', 2);
  perform pg_temp.turn('2f965722-658b-5ba9-b63a-fbd922259d99', '81710b48-fe17-57cd-ae5f-db7f9ae87afe', 'Učiteljica', 'Razumijem. Može ostati u produženom boravku i učiti s nama.', 'Розумію. Вона може лишатися на продовженому дні й вчитися з нами.', 3);
  perform pg_temp.turn('f99c6e8f-8ab9-530e-98ab-4e30d4d20c79', '81710b48-fe17-57cd-ae5f-db7f9ae87afe', 'Tata', 'Odlično, hvala. Kada je roditeljski sastanak?', 'Чудово, дякую. Коли батьківські збори?', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 49: У банку
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'fee5b77b-dc3b-5fd5-818a-c5496e95c23b';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.10: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.10.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 49: У банку', 'Lekcija 49: U banci', '["Відкрити рахунок у банку", "Дізнатися про щомісячну плату", "Розблокувати картку"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'otvoriti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tekući račun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'IBAN', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naknada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dokaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blokiran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odblokirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'PIN', v_pos);
  v_pos := pg_temp.word(v_lesson, 'aplikacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podići', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kriv', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b1ed5867-bab9-5fb4-a4fb-3408cccc5cd4', 'fill_in_the_blank', 'Želim otvoriti ___ račun.', 'tekući', '["tekuća", "tekućem", "tekuće", "tekući"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '36454c24-b2a7-5371-8590-95bd98d2b768', 'multiple_choice', 'Що означає «kriv»?', 'неправильний / винний', '["неправильний / винний", "підняти; зняти гроші", "поточний рахунок у банку", "відчинити / відкрити"]'::jsonb, 'A1', 2, 'PUBLISHED', 'kriv', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b9ab92eb-436c-582c-95ad-182309e8fad7', 'multiple_choice', 'Що означає «PIN»?', 'PIN-код', '["PIN-код", "підняти; зняти гроші", "додаток (app)", "заблокований"]'::jsonb, 'A1', 3, 'PUBLISHED', 'PIN', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8cd80526-90e4-5711-bc7c-f68861342041', 'multiple_choice', 'Як хорватською «розблокувати»?', 'odblokirati', '["blokiran", "tekući račun", "odblokirati", "dobiti"]'::jsonb, 'A1', 4, 'PUBLISHED', 'odblokirati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0288b8a2-0b2f-5c22-b491-f1e0d79b4eb7', 'type_answer', 'Напишіть хорватською: «додаток (app)»', 'aplikacija', null, 'A1', 5, 'PUBLISHED', 'aplikacija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0017a12a-0f12-5c27-b40b-275118d7fa10', 'type_answer', 'Напишіть хорватською: «заблокований»', 'blokiran', null, 'A1', 6, 'PUBLISHED', 'blokiran', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'df5279dc-2bdf-52ea-9510-6d1a4a04f2ea', 'sentence_builder', 'Складіть: «Я хочу відкрити поточний рахунок.»', 'Želim otvoriti tekući račun.', '["tekući", "otvoriti", "račun.", "Želim"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '85ef62aa-d8df-5035-a6d7-7ac8b088d6a2', 'sentence_builder', 'Складіть: «Моя картка не працює.»', 'Moja kartica ne radi.', '["kartica", "radi.", "ne", "Moja"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '05003b98-5322-5f67-991d-be0442cc3919', 'listening', 'Прослухайте і складіть фразу', 'Kolika je mjesečna naknada?', '["Kolika", "naknada?", "mjesečna", "je"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fbb65d34-5895-54c9-8471-8820a7abc742', 'listening', 'Прослухайте і складіть фразу', 'Možete li je odblokirati?', '["li", "je", "Možete", "odblokirati?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f196812a-ede5-5dcc-88ac-a11687f2c170', 'speaking', 'Мені потрібно зняти гроші.', 'Trebam podići novac.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a8c3c2b4-3b60-5fd2-b4f5-2415a5fcddca', 'speaking', 'Який ваш IBAN?', 'Koji je Vaš IBAN?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('38f0ec41-eee4-5deb-8b81-53deefbb3803', v_lesson, 'Відкрити рахунок', 'Otvaranje računa', 1491, 'A1', 'bank', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('2afc28a7-6f4c-5033-b9c2-2fb3a292d0d9', '38f0ec41-eee4-5deb-8b81-53deefbb3803', 'Službenica', 'Izvolite, kako Vam mogu pomoći?', 'Прошу, чим можу допомогти?', 1);
  perform pg_temp.turn('44f63f1c-9066-5120-8d1a-82c12162bad3', '38f0ec41-eee4-5deb-8b81-53deefbb3803', 'Andrij', 'Želim otvoriti tekući račun.', 'Я хочу відкрити поточний рахунок.', 2);
  perform pg_temp.turn('fb8cba19-c6fb-5b63-b2b6-5a41233eac3d', '38f0ec41-eee4-5deb-8b81-53deefbb3803', 'Službenica', 'Trebam Vašu putovnicu, OIB i dokaz o adresi.', 'Мені потрібні ваш паспорт, OIB і підтвердження адреси.', 3);
  perform pg_temp.turn('a7cea101-5c19-5152-a783-005b4cb5d1d0', '38f0ec41-eee4-5deb-8b81-53deefbb3803', 'Andrij', 'Kolika je mjesečna naknada?', 'Яка щомісячна плата?', 4);
  perform pg_temp.turn('3a8a920c-e645-5f73-9c30-a10d97e14c5c', '38f0ec41-eee4-5deb-8b81-53deefbb3803', 'Službenica', 'Dva eura. Karticu dobivate za deset dana.', 'Два євро. Картку отримаєте за десять днів.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('58dc6c16-4c46-5746-a966-3381c61ec43d', v_lesson, 'Картку заблоковано', 'Kartica je blokirana', 1492, 'A1', 'bank', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('89fc72bb-ec2a-5ebe-9481-1e14456b4ad2', '58dc6c16-4c46-5746-a966-3381c61ec43d', 'Oksana', 'Moja kartica ne radi. Bankomat ne daje novac.', 'Моя картка не працює. Банкомат не видає гроші.', 1);
  perform pg_temp.turn('27a8b4f0-f572-5a2a-b66e-db9d151a7490', '58dc6c16-4c46-5746-a966-3381c61ec43d', 'Službenik', 'Kartica je blokirana zbog krivog PIN-a.', 'Картку заблоковано через неправильний PIN.', 2);
  perform pg_temp.turn('f89a8e3e-e523-5695-8cc4-af866e4d2f73', '58dc6c16-4c46-5746-a966-3381c61ec43d', 'Oksana', 'Možete li je odblokirati?', 'Можете її розблокувати?', 3);
  perform pg_temp.turn('37968c0a-832b-562d-848e-0fec3021917b', '58dc6c16-4c46-5746-a966-3381c61ec43d', 'Službenik', 'Mogu. Novi PIN dobivate u aplikaciji.', 'Можу. Новий PIN отримаєте в застосунку.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- Модулі A1: опис і публікація (модулі вже є в каркасі як DRAFT; юніти — у частині 1)
update public.modules set description = 'Розпорядок дня, вихідні й звички. Теперішній час дієслів.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 1 and status <> 'DEPRECATED';
update public.modules set description = 'Ресторан, кухня і ринок. Знахідний і родовий відмінки, наказовий спосіб.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 2 and status <> 'DEPRECATED';
update public.modules set description = 'Одяг, супермаркет, повернення товару. Ступені порівняння, модальні дієслова, заперечення.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 3 and status <> 'DEPRECATED';
update public.modules set description = 'Трамвай, поїзд і літак. Місцевий відмінок, питання, присвійні займенники.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 4 and status <> 'DEPRECATED';
update public.modules set description = 'Оренда, поломки, сусіди. Сполучники, місцевий відмінок, наказовий спосіб.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 5 and status <> 'DEPRECATED';
update public.modules set description = 'Робочий день, правила, співбесіда. Теперішній час, модальні дієслова, питання.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 6 and status <> 'DEPRECATED';
update public.modules set description = 'Лікар, аптека, самопочуття. Знахідний відмінок, наказовий спосіб, заперечення.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 7 and status <> 'DEPRECATED';
update public.modules set description = 'Запрошення, хобі, думки. Модальні дієслова, теперішній час, сполучники.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 8 and status <> 'DEPRECATED';
update public.modules set description = 'Погода, острови, свята. Ступені порівняння, місцевий відмінок, присвійні займенники.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 9 and status <> 'DEPRECATED';
update public.modules set description = 'Повторення: теми A1 у нових життєвих ситуаціях.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 10 and status <> 'DEPRECATED';

-- Граматика A1: опис і публікація тем (теми вже є в каркасі як DRAFT; правила — у частині 1)
update public.grammar_topics set description = 'Як змінюються дієслова в теперішньому часі: три типи закінчень.', status = 'PUBLISHED'
where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '387f7bea-839e-56ae-bbfd-213aacbe7c26', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '387f7bea-839e-56ae-bbfd-213aacbe7c26' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Інфінітив, дієслово + інфінітив, питання й заперечення з дієсловами.', status = 'PUBLISHED'
where id = '318b394b-c622-5dd6-8494-4c1472b6df62' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '318b394b-c622-5dd6-8494-4c1472b6df62', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '318b394b-c622-5dd6-8494-4c1472b6df62' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Найчастіші дієслова, які змінюються не за правилом: ići, htjeti, moći, jesti, piti.', status = 'PUBLISHED'
where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '6ba7fa0f-46cc-5679-85bb-23c1329bfa18', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Кого? Що? — знахідний відмінок після дієслів: želim kavu, vidim brata, boli me glava.', status = 'PUBLISHED'
where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '0db658cb-b2ed-5719-bced-f95a93cf15ce', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '0db658cb-b2ed-5719-bced-f95a93cf15ce' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Де? Про що? — місцевий відмінок після u, na, o.', status = 'PUBLISHED'
where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', 'f891e65a-d7be-5542-ae6e-dbee5bfe415c', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Чого? Скільки? Звідки? — родовий відмінок після кількості, nema і прийменників.', status = 'PUBLISHED'
where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', 'd27ae527-a8d6-512f-acd2-a6cfec39c01f', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Наш, ваш, його, її, їхній — і питання «чий?».', status = 'PUBLISHED'
where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '94ab9b5e-95b0-5edb-8322-52293bdb5d05', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Можу, мушу, треба, можна: moći, morati, trebati, smjeti.', status = 'PUBLISHED'
where id = '61247c65-c284-51c5-a9ed-1626afbd77ac' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '61247c65-c284-51c5-a9ed-1626afbd77ac', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '61247c65-c284-51c5-a9ed-1626afbd77ac' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Прохання й поради: dodaj, uzmite, nemojte.', status = 'PUBLISHED'
where id = '45c5cb39-daf7-5dab-8413-9a5302b33553' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '45c5cb39-daf7-5dab-8413-9a5302b33553', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '45c5cb39-daf7-5dab-8413-9a5302b33553' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Більший, дешевший, найкращий: вищий і найвищий ступінь прикметників.', status = 'PUBLISHED'
where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', 'b58103b4-a259-5384-aa65-ffc0e2a195c8', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Питання з li і питальні слова: kada, koliko, zašto, koji, kakav.', status = 'PUBLISHED'
where id = '1435d343-6721-5eb7-8dc2-af7f9a027716' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '1435d343-6721-5eb7-8dc2-af7f9a027716', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '1435d343-6721-5eb7-8dc2-af7f9a027716' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Ne, nisam, nemam, ništa, nitko, nikad — і подвійне заперечення, як в українській.', status = 'PUBLISHED'
where id = 'b89a9004-2c03-567a-b23e-31db18f92dea' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', 'b89a9004-2c03-567a-b23e-31db18f92dea', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = 'b89a9004-2c03-567a-b23e-31db18f92dea' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Як поєднати думки: i, a, ali, ili, jer, zato što.', status = 'PUBLISHED'
where id = '765ac66f-d54b-505b-9b11-c48e5ad26018' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '765ac66f-d54b-505b-9b11-c48e5ad26018', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '765ac66f-d54b-505b-9b11-c48e5ad26018' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');

-- 6. Самоперевірка: якщо щось не так — уся частина 2 відкочується
do $$
declare
  v_modules int; v_lessons int; v_short int; v_scenes int; v_grammar int; v_rules int;
begin
  select count(*) into v_modules from public.modules where level_code = 'A1' and status = 'PUBLISHED';
  select count(*) into v_lessons from public.lessons where level_code = 'A1' and status = 'PUBLISHED';
  select count(*) into v_short from public.lessons l where l.level_code = 'A1'
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') < 12;
  select count(*) into v_scenes from public.lessons l where l.level_code = 'A1'
     and (select count(*) from public.conversations c where c.lesson_id = l.id) < 2;
  select count(*) into v_grammar from public.grammar_topics where cefr = 'A1' and status = 'PUBLISHED';
  select count(*) into v_rules from public.grammar_topics g where g.cefr = 'A1'
     and not exists (select 1 from public.grammar_rules r where r.topic_id = g.id);
  if v_modules < 10 then raise exception 'A1: модулів %, очікувалось 10', v_modules; end if;
  if v_lessons < 49 then raise exception 'A1: уроків %, очікувалось 49', v_lessons; end if;
  if v_short > 0 then raise exception 'A1: % уроків мають менше 12 вправ', v_short; end if;
  if v_scenes > 0 then raise exception 'A1: % уроків без двох діалогів', v_scenes; end if;
  if v_grammar < 13 or v_rules > 0 then raise exception 'A1: граматика — тем %, без правил %', v_grammar, v_rules; end if;
  raise notice 'Готово: A1 — % модулів, % уроків, % граматичних тем', v_modules, v_lessons, v_grammar;
end $$;

commit;

-- Перевірка (окремим запитом після запуску):
-- select m.order_index as модуль, m.title_ua, count(l.id) as уроків
-- from public.modules m join public.units u on u.module_id = m.id
-- left join public.lessons l on l.unit_id = u.id
-- where m.level_code = 'A1' group by m.order_index, m.title_ua order by 1;
