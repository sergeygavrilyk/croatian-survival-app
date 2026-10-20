-- =====================================================================
-- Уроки A0 за темою · curriculum_a0_v4 · модуль A0.9 · 2026-10-19
-- Згенеровано: python3 scripts/gen_curriculum_a0_v4.py (не редагуйте вручну).
--
-- Рішення власника 2026-10-15: слова уроку — за темою уроку, 20–25 слів і виразів, діалоги під тему; бета (PUBLISHED).
--   * Уроки 55–59: 5 наявних перебудовано, 0 нових тематичних уроків. Слів у них: 113.
--     Кожен: 20–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 16.
--   * Новий порядок уроків у модулі; назви всіх уроків A0 перенумеровано підряд (разом 64).
--   * Стара версія кожного зміненого уроку — у content_versions; копія кроків — у backup.lesson_items_20261015;
--     старі вправи й діалоги → DEPRECATED (не видаляються).
--   * Усе в одній транзакції; безпечно запускати повторно (зроблене пропускається).
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

create schema if not exists backup;
create table if not exists backup.lesson_items_20261015 (like public.lesson_items including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'lesson_items_20261015_pkey') then
    alter table backup.lesson_items_20261015 add constraint lesson_items_20261015_pkey primary key (id);
  end if;
end $$;
revoke all on backup.lesson_items_20261015 from anon, authenticated;

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

-- 1. Нові слова й вирази A0 (наявні не змінюються)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zoološki vrt', 'zooloski vrt', 'hr', 'phrase', 'A0', 'зоопарк', 'collocation', '{"gender": "m"}'::jsonb, '["Djeca vole ići u zoološki vrt."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('naselje', 'naselje', 'hr', 'noun', 'A0', 'житловий район; селище', 'core', '{"gender": "n"}'::jsonb, '["Živimo u mirnom naselju blizu centra."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('u blizini', 'u blizini', 'hr', 'phrase', 'A0', 'поблизу, неподалік', 'chunk', '{}'::jsonb, '["Ima li ovdje u blizini bankomat?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('najbliži', 'najblizi', 'hr', 'adjective', 'A0', 'найближчий', 'core', '{"f": "najbliža", "n": "najbliže", "positive": "blizak"}'::jsonb, '["Gdje je najbliža pošta?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kako doći do', 'kako doci do', 'hr', 'phrase', 'A0', 'як дістатися до…; як пройти до…', 'chunk', '{}'::jsonb, '["Oprostite, kako doći do kolodvora?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('do kraja ulice', 'do kraja ulice', 'hr', 'phrase', 'A0', 'до кінця вулиці', 'chunk', '{}'::jsonb, '["Idite ravno do kraja ulice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nedaleko', 'nedaleko', 'hr', 'adverb', 'A0', 'недалеко', 'core', '{}'::jsonb, '["Muzej je nedaleko od trga."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('koliko je daleko', 'koliko je daleko', 'hr', 'phrase', 'A0', 'як далеко (до…)?', 'formulaic', '{}'::jsonb, '["Koliko je daleko do plaže?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stari grad', 'stari grad', 'hr', 'phrase', 'A0', 'старе місто (історичний центр)', 'collocation', '{"gender": "m"}'::jsonb, '["Navečer šetamo po starom gradu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('obilazak', 'obilazak', 'hr', 'noun', 'A0', 'екскурсія (з гідом); обхід', 'core', '{"gender": "m"}'::jsonb, '["Obilazak grada počinje u deset sati."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('fontana', 'fontana', 'hr', 'noun', 'A0', 'фонтан', 'core', '{"gender": "f"}'::jsonb, '["Nađimo se kod fontane na trgu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('karta grada', 'karta grada', 'hr', 'phrase', 'A0', 'карта міста', 'collocation', '{"gender": "f"}'::jsonb, '["Imate li besplatnu kartu grada?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('suvenir', 'suvenir', 'hr', 'noun', 'A0', 'сувенір', 'core', '{"gender": "m"}'::jsonb, '["Kupila sam mami suvenir iz Dubrovnika."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mjesečna karta', 'mjesecna karta', 'hr', 'phrase', 'A0', 'місячний проїзний', 'collocation', '{"gender": "f"}'::jsonb, '["Mjesečna karta vrijedi za tramvaj i autobus."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('presjesti', 'presjesti', 'hr', 'verb', 'A0', 'пересісти, зробити пересадку', 'core', '{"aspect": "pf", "present": {"1s": "presjednem", "2s": "presjedneš", "3s": "presjedne"}, "past": "presjeo"}'::jsonb, '["Na glavnom kolodvoru morate presjesti na vlak za Rijeku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kontrolor', 'kontrolor', 'hr', 'noun', 'A0', 'контролер (квитків)', 'core', '{"gender": "m", "f_form": "kontrolorka"}'::jsonb, '["Kontrolor provjerava karte u tramvaju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;

-- 2. Перебудова наявних уроків модуля A0.9
-- A0.9 · урок 55: Місця в місті — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '0addd5be-230b-582f-baed-a5d18eb1d619';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Місця в місті» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'af38c201-b364-5be5-a73f-970c386840cc') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a0_v4: урок перебудовано за темою — стара версія (слова, вправи, діалоги)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  -- новий склад уроку (тема граматики та сама)
  select grammar_topic_id into v_gid from public.lesson_grammar where lesson_id = v_lesson limit 1;
  if v_gid is null then select item_id into v_gid from public.lesson_items where lesson_id = v_lesson and item_type = 'grammar' limit 1; end if;
  if v_gid is null then select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Де? Прийменники місця' and status = 'PUBLISHED' order by created_at limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 55: Місця в місті', title_hr = 'Lekcija 55: Mjesta u gradu',
         objectives = '["Назвати місця в місті: pošta, banka, knjižnica, kazalište", "Запитати, що є поблизу: «Što ima u blizini?»", "Сказати, де що розташоване: pored banke, iza trga, između kina i supermarketa"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'centar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pošta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'banka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjenjačnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bolnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'knjižnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kino', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kazalište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'park', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trg', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trgovački centar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'teretana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bazen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plaža', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stadion', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zoološki vrt', v_pos);
  v_pos := pg_temp.word(v_lesson, 'općina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'veleposlanstvo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sveučilište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naselje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u blizini', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najbliži', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '1fe190e0-063b-547c-a5f5-8076181fbed0', 'fill_in_the_blank', 'Mjenjačnica je pored ___.', 'banke', '["banku", "banci", "banka", "banke"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3fd4cc29-fef5-54c2-8bf0-1cb5a919b771', 'multiple_choice', 'Що означає «pošta»?', 'пошта', '["посольство", "бібліотека", "торговий центр", "пошта"]'::jsonb, 'A0', 2, 'PUBLISHED', 'pošta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '80c86696-8135-53f5-944c-df738cf20c86', 'multiple_choice', 'Що означає «veleposlanstvo»?', 'посольство', '["найближчий", "посольство", "площа", "поблизу, неподалік"]'::jsonb, 'A0', 3, 'PUBLISHED', 'veleposlanstvo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e1180e26-033e-5ddd-9608-da65bb81e610', 'multiple_choice', 'Що означає «stadion»?', 'стадіон', '["стадіон", "поблизу, неподалік", "торговий центр", "житловий район; селище"]'::jsonb, 'A0', 4, 'PUBLISHED', 'stadion', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8bbe6e8e-500e-5f0b-ac23-2946819b40eb', 'multiple_choice', 'Як хорватською «муніципалітет, громада»?', 'općina', '["bazen", "centar", "općina", "banka"]'::jsonb, 'A0', 5, 'PUBLISHED', 'općina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6ebbed8a-6586-5f91-b8f4-e3a6849a738c', 'multiple_choice', 'Як хорватською «площа»?', 'trg', '["mjenjačnica", "trg", "kazalište", "plaža"]'::jsonb, 'A0', 6, 'PUBLISHED', 'trg', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '45b724d3-3965-50ec-bb1e-cd2c13d665e4', 'type_answer', 'Напишіть хорватською: «лікарня»', 'bolnica', null, 'A0', 7, 'PUBLISHED', 'bolnica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '726ffd09-1a9e-573a-b230-5bf4c565c2af', 'type_answer', 'Напишіть хорватською: «тренажерний зал»', 'teretana', null, 'A0', 8, 'PUBLISHED', 'teretana', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aafff8ea-f5ae-5d26-8a36-87c5706a8726', 'type_answer', 'Напишіть хорватською: «бібліотека»', 'knjižnica', null, 'A0', 9, 'PUBLISHED', 'knjižnica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a230add7-1895-556d-ae4a-d8f3ff469af5', 'sentence_builder', 'Складіть: «Де найближча пошта?»', 'Gdje je najbliža pošta?', '["najbliža", "je", "pošta?", "Gdje"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aa541a89-058b-5bf7-bf97-5c2fed08bdda', 'sentence_builder', 'Складіть: «Банк поруч із поштою.»', 'Banka je pored pošte.', '["Banka", "pošte.", "je", "pored"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c15afe3b-d801-5c91-ba6f-ecf67932964a', 'listening', 'Прослухайте і складіть фразу', 'Što ima u blizini?', '["u", "Što", "blizini?", "ima"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d38f90f-e6db-5a0f-ac41-89dcf80d16e8', 'listening', 'Прослухайте і складіть фразу', 'Možemo u zoološki vrt.', '["Možemo", "vrt.", "zoološki", "u"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ebae131-5ffe-5916-8239-fbe5b49e923d', 'speaking', 'Я живу поруч із парком.', 'Živim pored parka.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '25a7f8bf-6720-5c43-9c4b-cc3104187a03', 'speaking', 'Ходімо в кіно!', 'Idemo u kino!', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('af38c201-b364-5be5-a73f-970c386840cc', v_lesson, 'Що є поблизу?', 'Što ima u blizini?', 2551, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('90651b05-46b4-59c3-86a1-e64867fa5871', 'af38c201-b364-5be5-a73f-970c386840cc', 'Daša', 'Ivane, ja sam nova u ovom naselju. Što ima u blizini?', 'Іване, я нова в цьому районі. Що тут є поблизу?', 1);
  perform pg_temp.turn('70504d4c-6a86-5552-a60e-db2d7af8f54d', 'af38c201-b364-5be5-a73f-970c386840cc', 'Ivan', 'Pošta i banka su na trgu, pet minuta odavde.', 'Пошта й банк — на площі, за п’ять хвилин звідси.', 2);
  perform pg_temp.turn('ecb4a77d-003d-5b5a-b0c7-92c799b74b4d', 'af38c201-b364-5be5-a73f-970c386840cc', 'Daša', 'Super. A gdje je najbliža mjenjačnica?', 'Супер. А де найближчий обмін валют?', 3);
  perform pg_temp.turn('2825fab5-0580-51dd-9c34-eea16d282244', 'af38c201-b364-5be5-a73f-970c386840cc', 'Ivan', 'Pored banke. Iza trga je i gradska knjižnica.', 'Поруч із банком. А за площею — міська бібліотека.', 4);
  perform pg_temp.turn('1ecf88fa-806c-5d41-b982-c8912b24e4e3', 'af38c201-b364-5be5-a73f-970c386840cc', 'Daša', 'Odlično! Ima li ovdje negdje teretana?', 'Чудово! А тренажерний зал тут десь є?', 5);
  perform pg_temp.turn('f2fc7ac8-2bad-59cb-b861-0768c5d323fa', 'af38c201-b364-5be5-a73f-970c386840cc', 'Ivan', 'Ima, u trgovačkom centru, između kina i supermarketa.', 'Є, у торговому центрі, між кінотеатром і супермаркетом.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c032f2a2-f10c-581d-95a1-0ebfcd945bce', v_lesson, 'Куди підемо в неділю?', 'Kamo ćemo u nedjelju?', 2552, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('1579213f-b96b-5db3-8f0a-6970f93d911d', 'c032f2a2-f10c-581d-95a1-0ebfcd945bce', 'Marija', 'Darja, kamo ćemo u nedjelju s djecom?', 'Дар’є, куди підемо в неділю з дітьми?', 1);
  perform pg_temp.turn('e8d574b1-fd16-5bce-9680-24951be666d8', 'c032f2a2-f10c-581d-95a1-0ebfcd945bce', 'Darja', 'Možemo u zoološki vrt. Djeca ga obožavaju.', 'Можемо в зоопарк. Діти його обожнюють.', 2);
  perform pg_temp.turn('16e02531-6e01-59e5-bcb8-3ea802ac32e9', 'c032f2a2-f10c-581d-95a1-0ebfcd945bce', 'Marija', 'Može. Poslije možemo na bazen ili u park.', 'Давай. Потім можна в басейн або в парк.', 3);
  perform pg_temp.turn('b6ed7961-2dba-5583-93ea-eb4d97578f04', 'c032f2a2-f10c-581d-95a1-0ebfcd945bce', 'Darja', 'Ako bude sunčano, idemo na plažu!', 'Якщо буде сонячно, підемо на пляж!', 4);
  perform pg_temp.turn('2014baed-2ea5-5d06-9dca-fa925c9aa8e9', 'c032f2a2-f10c-581d-95a1-0ebfcd945bce', 'Marija', 'A navečer kazalište? Ima nova predstava za djecu.', 'А ввечері театр? Є нова вистава для дітей.', 5);
  perform pg_temp.turn('e26e3916-2788-5775-bcf0-c2faf4180ebf', 'c032f2a2-f10c-581d-95a1-0ebfcd945bce', 'Darja', 'Odlična ideja!', 'Чудова ідея!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.9 · урок 56: Як пройти? — перебудова: 23 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '55af257e-e4d1-51ed-9637-388a7e0b4baf';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Як пройти?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '5d966baa-25dc-5e5b-8864-3a421757ee6a') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a0_v4: урок перебудовано за темою — стара версія (слова, вправи, діалоги)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  -- новий склад уроку (тема граматики та сама)
  select grammar_topic_id into v_gid from public.lesson_grammar where lesson_id = v_lesson limit 1;
  if v_gid is null then select item_id into v_gid from public.lesson_items where lesson_id = v_lesson and item_type = 'grammar' limit 1; end if;
  if v_gid is null then select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Порядок слів' and status = 'PUBLISHED' order by created_at limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 56: Як пройти?', title_hr = 'Lekcija 56: Kako doći do…?',
         objectives = '["Запитати дорогу: «Oprostite, kako doći do…?»", "Показати дорогу: idite ravno, skrenite desno, preko puta, do kraja ulice", "Запитати, чи далеко, і зрозуміти відповідь «deset minuta pješice»"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kako doći do', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pokazati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'put', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smjer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ići', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ravno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skrenuti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preko puta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'raskrižje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'semafor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pješački prijelaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijeći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'most', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'do kraja ulice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nastaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stići', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blizu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nedaleko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pješice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koliko je daleko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovdje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tamo', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e0ccc770-40d1-5465-9d57-8808868ad658', 'fill_in_the_blank', 'Kolodvor ___ odmah preko puta mosta.', 'je', '["su", "je", "sam", "si"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c5bb7f7c-54b8-56cb-a0f6-2f16de935733', 'multiple_choice', 'Що означає «ugao»?', 'ріг (вулиці); кут', '["як дістатися до…; як пройти до…", "ріг (вулиці); кут", "прибути / доїхати", "прямо"]'::jsonb, 'A0', 2, 'PUBLISHED', 'ugao', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1b8b3aad-2858-5b3b-93e7-aa15b4f0a78f', 'multiple_choice', 'Що означає «raskrižje»?', 'перехрестя', '["напрямок", "міст", "перехрестя", "до кінця вулиці"]'::jsonb, 'A0', 3, 'PUBLISHED', 'raskrižje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5455bf05-a481-56db-b616-48239e08b69b', 'multiple_choice', 'Що означає «prijeći»?', 'перейти', '["показати", "перейти", "прямо", "ріг (вулиці); кут"]'::jsonb, 'A0', 4, 'PUBLISHED', 'prijeći', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '54766ea0-5514-56fa-8974-7cab89a970c7', 'multiple_choice', 'Як хорватською «пішохідний перехід»?', 'pješački prijelaz', '["pješački prijelaz", "smjer", "ići", "prijeći"]'::jsonb, 'A0', 5, 'PUBLISHED', 'pješački prijelaz', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4f5c625d-08b1-5727-8f66-b0e805b36226', 'multiple_choice', 'Як хорватською «прибути / доїхати»?', 'stići', '["nedaleko", "ići", "blizu", "stići"]'::jsonb, 'A0', 6, 'PUBLISHED', 'stići', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd5157ec2-2cbb-58c6-a6b1-04c873b59327', 'type_answer', 'Напишіть хорватською: «прямо»', 'ravno', null, 'A0', 7, 'PUBLISHED', 'ravno', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0cd9a3ea-429d-542d-b682-4a3c4a2a43f1', 'type_answer', 'Напишіть хорватською: «світлофор»', 'semafor', null, 'A0', 8, 'PUBLISHED', 'semafor', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ed467577-3163-5166-b580-858778ed691e', 'type_answer', 'Напишіть хорватською: «пішки»', 'pješice', null, 'A0', 9, 'PUBLISHED', 'pješice', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f8189aae-47e2-5b0b-85db-042d15042c42', 'sentence_builder', 'Складіть: «Ідіть прямо, потім поверніть праворуч.»', 'Idite ravno, pa skrenite desno.', '["ravno,", "Idite", "skrenite", "pa", "desno."]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6c93df5b-8cce-57ed-b38f-8e452839c5cb', 'sentence_builder', 'Складіть: «Пошта навпроти банку.»', 'Pošta je preko puta banke.', '["Pošta", "je", "puta", "preko", "banke."]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ad25962e-48b4-5b8e-8deb-ec3e646ba729', 'listening', 'Прослухайте і складіть фразу', 'Nije daleko, deset minuta pješice.', '["minuta", "daleko,", "deset", "Nije", "pješice."]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a58746b-5cc9-51b9-b85a-6af957c8e57b', 'listening', 'Прослухайте і складіть фразу', 'Ovdje na semaforu prijeđite cestu.', '["prijeđite", "semaforu", "Ovdje", "na", "cestu."]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4fdbef60-2651-59af-86ce-f848f641607e', 'speaking', 'Покажіть мені дорогу, будь ласка.', 'Pokažite mi put, molim vas.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ee1ebb7c-4408-53b0-8fef-be597a21e1a2', 'speaking', 'Як далеко до центру?', 'Koliko je daleko do centra?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5d966baa-25dc-5e5b-8864-3a421757ee6a', v_lesson, 'Як пройти до вокзалу?', 'Kako doći do kolodvora?', 2561, 'A0', 'travel', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('ce0a8053-adca-5453-82da-6da2dedc2940', '5d966baa-25dc-5e5b-8864-3a421757ee6a', 'Daša', 'Oprostite, kako doći do kolodvora?', 'Перепрошую, як дістатися до вокзалу?', 1);
  perform pg_temp.turn('6c45e868-c58c-5e52-a4fb-5078e8e8e70d', '5d966baa-25dc-5e5b-8864-3a421757ee6a', 'Gospođa', 'Idite ravno do kraja ulice, pa skrenite lijevo.', 'Ідіть прямо до кінця вулиці, потім поверніть ліворуч.', 2);
  perform pg_temp.turn('78426a82-c3ba-5413-84fd-97ac635779c7', '5d966baa-25dc-5e5b-8864-3a421757ee6a', 'Daša', 'Koliko je daleko?', 'Це далеко?', 3);
  perform pg_temp.turn('c87b888b-172d-5243-b195-8f322181cb7f', '5d966baa-25dc-5e5b-8864-3a421757ee6a', 'Gospođa', 'Nije daleko, deset minuta pješice.', 'Недалеко, десять хвилин пішки.', 4);
  perform pg_temp.turn('0fe49a1f-82d2-59ca-b56e-a473d4f73ee7', '5d966baa-25dc-5e5b-8864-3a421757ee6a', 'Daša', 'Je li to blizu mosta?', 'Це біля мосту?', 5);
  perform pg_temp.turn('5688197a-1b60-5e2c-9769-51ca101b8dd9', '5d966baa-25dc-5e5b-8864-3a421757ee6a', 'Gospođa', 'Da, kolodvor je tamo, odmah preko puta mosta.', 'Так, вокзал там, одразу навпроти мосту.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('71faea15-badc-5a95-9468-60667b937d96', v_lesson, 'Дар’я показує дорогу', 'Darja pokazuje put', 2562, 'A0', 'travel', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('38e0b673-9a59-5300-ba5c-663be12cfe1b', '71faea15-badc-5a95-9468-60667b937d96', 'Turistkinja', 'Oprostite, možete li mi pokazati put do muzeja?', 'Перепрошую, можете показати мені дорогу до музею?', 1);
  perform pg_temp.turn('4bd919f3-a508-5c0f-996d-e442a7bdc6b1', '71faea15-badc-5a95-9468-60667b937d96', 'Darja', 'Naravno. Ovdje na semaforu prijeđite cestu.', 'Звісно. Ось тут, на світлофорі, перейдіть дорогу.', 2);
  perform pg_temp.turn('97e6696d-0ef5-5278-9d48-a90c969a1313', '71faea15-badc-5a95-9468-60667b937d96', 'Turistkinja', 'A onda?', 'А потім?', 3);
  perform pg_temp.turn('a37cb7ee-eec9-5c27-a9e7-96bec930fd97', '71faea15-badc-5a95-9468-60667b937d96', 'Darja', 'Nastavite ravno do raskrižja i skrenite desno.', 'Ідіть далі прямо до перехрестя й поверніть праворуч.', 4);
  perform pg_temp.turn('d6bc2c5a-d766-5321-b8a1-dbb21ddcdc7c', '71faea15-badc-5a95-9468-60667b937d96', 'Turistkinja', 'Je li muzej na uglu?', 'Музей на розі?', 5);
  perform pg_temp.turn('938fd1d2-66a1-5760-b8af-92fcc380c1c5', '71faea15-badc-5a95-9468-60667b937d96', 'Darja', 'Da, odmah iza ugla. Ne možete ga promašiti.', 'Так, одразу за рогом. Не пропустите.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.9 · урок 57: Старе місто — перебудова: 24 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '1e0384e5-6097-56ed-ab56-cf530f02ab73';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Старе місто» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '2d42f83b-ee4a-501f-8fd5-ba36b7097223') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a0_v4: урок перебудовано за темою — стара версія (слова, вправи, діалоги)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  -- новий склад уроку (тема граматики та сама)
  select grammar_topic_id into v_gid from public.lesson_grammar where lesson_id = v_lesson limit 1;
  if v_gid is null then select item_id into v_gid from public.lesson_items where lesson_id = v_lesson and item_type = 'grammar' limit 1; end if;
  if v_gid is null then select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Прикметники: узгодження з іменником' and status = 'PUBLISHED' order by created_at limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 57: Старе місто', title_hr = 'Lekcija 57: Stari grad',
         objectives = '["Назвати пам’ятки: katedrala, zidine, palača, spomenik, kula", "Запитати про екскурсію, квиток і чи можна фотографувати", "Описати місто: star, poznat, prekrasan"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'stari grad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razgledati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obilazak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'znamenitost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'katedrala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crkva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'muzej', v_pos);
  v_pos := pg_temp.word(v_lesson, 'galerija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spomenik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zidine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kula', v_pos);
  v_pos := pg_temp.word(v_lesson, 'palača', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fontana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vidikovac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pogled', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ulaznica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vodič', v_pos);
  v_pos := pg_temp.word(v_lesson, 'turist', v_pos);
  v_pos := pg_temp.word(v_lesson, 'karta grada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'suvenir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fotografirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poznat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povijest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otvoren', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aa0884f6-607c-544b-bf7c-9df1316e5d2b', 'fill_in_the_blank', 'Gradske zidine su jako ___.', 'stare', '["star", "staro", "stare", "stara"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9e8750b0-f1d0-5063-b985-1e1ad0eadff2', 'multiple_choice', 'Що означає «povijest»?', 'історія', '["історія", "вид (з вікна)", "палац", "міські мури"]'::jsonb, 'A0', 2, 'PUBLISHED', 'povijest', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '96172457-f859-5d5d-88e6-97aacd317685', 'multiple_choice', 'Що означає «razgledati»?', 'оглядати (пам’ятки)', '["відчинений / відкритий", "церква", "вид (з вікна)", "оглядати (пам’ятки)"]'::jsonb, 'A0', 3, 'PUBLISHED', 'razgledati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a807fa14-3ba3-5e61-8ca6-27c750e71b37', 'multiple_choice', 'Що означає «galerija»?', 'галерея', '["старе місто (історичний центр)", "галерея", "визначна пам''ятка", "фонтан"]'::jsonb, 'A0', 4, 'PUBLISHED', 'galerija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '475785f6-913f-572e-86cd-21ccd8df31cd', 'multiple_choice', 'Як хорватською «фортечна вежа»?', 'kula', '["galerija", "suvenir", "vidikovac", "kula"]'::jsonb, 'A0', 5, 'PUBLISHED', 'kula', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b1698b0c-bbef-50bf-b9b3-dd66ca6c1c26', 'multiple_choice', 'Як хорватською «палац»?', 'palača', '["muzej", "katedrala", "palača", "znamenitost"]'::jsonb, 'A0', 6, 'PUBLISHED', 'palača', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c9a1c29b-4ca1-54b3-b488-4d4ac6859984', 'type_answer', 'Напишіть хорватською: «церква»', 'crkva', null, 'A0', 7, 'PUBLISHED', 'crkva', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'caf6ad09-ec46-5157-9957-c6157a8200a0', 'type_answer', 'Напишіть хорватською: «гід»', 'vodič', null, 'A0', 8, 'PUBLISHED', 'vodič', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '11199a7c-318a-56e4-bb2e-e30d9ce71ea3', 'type_answer', 'Напишіть хорватською: «міські мури»', 'zidine', null, 'A0', 9, 'PUBLISHED', 'zidine', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5cb386e7-ee25-5f6a-a0c9-4161384f617c', 'sentence_builder', 'Складіть: «Скільки коштує вхідний квиток?»', 'Koliko košta ulaznica?', '["košta", "Koliko", "ulaznica?"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a67db91c-d424-5521-9121-65a22a7ccd7e', 'sentence_builder', 'Складіть: «Я хочу оглянути старе місто.»', 'Želim razgledati stari grad.', '["stari", "grad.", "Želim", "razgledati"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '041e721c-2f7b-561e-ad86-10108c028e60', 'listening', 'Прослухайте і складіть фразу', 'Katedralu, staru palaču i gradske zidine.', '["zidine.", "i", "Katedralu,", "palaču", "staru", "gradske"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '14ecac4e-3eb4-57be-9566-3f09295aaddd', 'listening', 'Прослухайте і складіть фразу', 'Moram kupiti suvenir za mamu.', '["kupiti", "za", "suvenir", "mamu.", "Moram"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '51faf8f9-b72e-534e-828a-5c5c0579066a', 'speaking', 'Де можна купити карту міста?', 'Gdje mogu kupiti kartu grada?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd7e3516d-8a21-5345-b89e-82257b168447', 'speaking', 'О котрій починається екскурсія?', 'U koliko sati počinje obilazak?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2d42f83b-ee4a-501f-8fd5-ba36b7097223', v_lesson, 'Екскурсія старим містом', 'Obilazak starog grada', 2571, 'A0', 'travel', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('f57679d9-99cc-5bf1-be35-7f757dc729b2', '2d42f83b-ee4a-501f-8fd5-ba36b7097223', 'Daša', 'Dobar dan, kada počinje obilazak starog grada?', 'Добрий день, коли починається екскурсія старим містом?', 1);
  perform pg_temp.turn('29e527e9-4a50-5a63-a2b9-ec1b35c10f14', '2d42f83b-ee4a-501f-8fd5-ba36b7097223', 'Vodič', 'U deset sati, kod fontane na glavnom trgu.', 'О десятій, біля фонтана на головній площі.', 2);
  perform pg_temp.turn('3a779865-60c3-59b7-8c0c-8ce99c47cd8d', '2d42f83b-ee4a-501f-8fd5-ba36b7097223', 'Daša', 'Što ćemo vidjeti?', 'Що ми побачимо?', 3);
  perform pg_temp.turn('13da8729-9e17-5fe2-82a4-314cfd8ec207', '2d42f83b-ee4a-501f-8fd5-ba36b7097223', 'Vodič', 'Katedralu, staru palaču i gradske zidine.', 'Собор, старий палац і міські мури.', 4);
  perform pg_temp.turn('394bb073-8513-538d-a7bd-211f7acb7e7d', '2d42f83b-ee4a-501f-8fd5-ba36b7097223', 'Daša', 'Smijem li fotografirati u katedrali?', 'Можна фотографувати в соборі?', 5);
  perform pg_temp.turn('a3a74c32-a93d-535c-8194-6684d91e0239', '2d42f83b-ee4a-501f-8fd5-ba36b7097223', 'Vodič', 'Možete, ali bez bljeskalice.', 'Можна, але без спалаху.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('bc36e397-d2a1-582c-947f-21a9abfa8133', v_lesson, 'На оглядовому майданчику', 'Na vidikovcu', 2572, 'A0', 'travel', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('a9b07b6a-6738-59cb-8a0b-ca8da9dc56f1', 'bc36e397-d2a1-582c-947f-21a9abfa8133', 'Petra', 'Darja, pogledaj! S vidikovca se vidi cijeli grad.', 'Дар’є, поглянь! З оглядового майданчика видно все місто.', 1);
  perform pg_temp.turn('b5e39dbc-bb1a-56c5-9529-6a501e85336e', 'bc36e397-d2a1-582c-947f-21a9abfa8133', 'Darja', 'Prekrasan pogled! Koja je ono visoka kula?', 'Чудовий вид! Що це за висока вежа?', 2);
  perform pg_temp.turn('29788b14-7e22-5c58-8e01-1e9995b99535', 'bc36e397-d2a1-582c-947f-21a9abfa8133', 'Petra', 'To je najpoznatija kula u gradu. Ima dugu povijest.', 'Це найвідоміша вежа в місті. У неї довга історія.', 3);
  perform pg_temp.turn('ebc513f7-0b28-5411-bbc2-12702a7f2f77', 'bc36e397-d2a1-582c-947f-21a9abfa8133', 'Darja', 'Moram kupiti suvenir za mamu.', 'Мені треба купити сувенір для мами.', 4);
  perform pg_temp.turn('2bab872a-b54e-52b9-a316-18e9656443ac', 'bc36e397-d2a1-582c-947f-21a9abfa8133', 'Petra', 'Kod zidina su suveniri skupi. Idemo dolje u stari grad.', 'Біля мурів сувеніри дорогі. Ходімо вниз, у старе місто.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.9 · урок 58: Квиток на автобус — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Квиток на автобус» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'b86a934a-a762-5807-9d03-b0fb2b2545a0') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a0_v4: урок перебудовано за темою — стара версія (слова, вправи, діалоги)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  -- новий склад уроку (тема граматики та сама)
  select grammar_topic_id into v_gid from public.lesson_grammar where lesson_id = v_lesson limit 1;
  if v_gid is null then select item_id into v_gid from public.lesson_items where lesson_id = v_lesson and item_type = 'grammar' limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 58: Квиток на автобус', title_hr = 'Lekcija 58: Karta za autobus',
         objectives = '["Купити квиток: povratna karta, karta u jednom smjeru, mjesečna karta", "Запитати, який трамвай чи автобус їде і де пересадка", "Зрозуміти, з якого перону відправлення"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'javni prijevoz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'autobus', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tramvaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vlak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trajekt', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zračna luka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolodvor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'autobusni kolodvor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stanica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'peron', v_pos);
  v_pos := pg_temp.word(v_lesson, 'linija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'karta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povratna karta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'karta u jednom smjeru', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjesečna karta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'presjesti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ući', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izaći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'propustiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'putovati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'putnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kontrolor', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '9a5a5c74-38c8-5fd5-b99a-2f8fd5687cda', 'fill_in_the_blank', 'Vlak za Rijeku polazi s drugog ___.', 'perona', '["peron", "peronu", "peronom", "perona"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b20c72bd-d94b-5834-96e5-7bbe3536d319', 'multiple_choice', 'Що означає «linija»?', 'лінія / маршрут', '["лінія / маршрут", "зупинка / станція", "пропустити", "трамвай"]'::jsonb, 'A0', 2, 'PUBLISHED', 'linija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'db76fac6-428b-553c-8b29-a614a9a968ab', 'multiple_choice', 'Що означає «putnik»?', 'пасажир / мандрівник', '["подорожувати", "поїзд", "пасажир / мандрівник", "пором"]'::jsonb, 'A0', 3, 'PUBLISHED', 'putnik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7272f9e3-346b-5733-a204-4b20a4b12adb', 'multiple_choice', 'Що означає «autobusni kolodvor»?', 'автовокзал', '["автовокзал", "пропустити", "квиток в один бік", "контролер (квитків)"]'::jsonb, 'A0', 4, 'PUBLISHED', 'autobusni kolodvor', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '96499352-beb4-5479-a4d3-70e3f3d360f6', 'multiple_choice', 'Як хорватською «аеропорт»?', 'zračna luka', '["vlak", "propustiti", "karta", "zračna luka"]'::jsonb, 'A0', 5, 'PUBLISHED', 'zračna luka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6300f2dd-00f7-5c5c-a14a-606124597966', 'multiple_choice', 'Як хорватською «пересісти, зробити пересадку»?', 'presjesti', '["presjesti", "mjesečna karta", "trajekt", "autobusni kolodvor"]'::jsonb, 'A0', 6, 'PUBLISHED', 'presjesti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5bd93455-f36c-54e5-b81d-fd082814552e', 'type_answer', 'Напишіть хорватською: «автобус»', 'autobus', null, 'A0', 7, 'PUBLISHED', 'autobus', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd4160ecd-473a-5c3f-9ee7-15846aab9330', 'type_answer', 'Напишіть хорватською: «трамвай»', 'tramvaj', null, 'A0', 8, 'PUBLISHED', 'tramvaj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5d6e6bf8-b234-578c-a998-cc0e7a12b4a3', 'type_answer', 'Напишіть хорватською: «пором»', 'trajekt', null, 'A0', 9, 'PUBLISHED', 'trajekt', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6eed7313-226e-5072-8e80-f84aa0753a32', 'sentence_builder', 'Складіть: «Один квиток до Загреба, будь ласка.»', 'Jednu kartu za Zagreb, molim.', '["Zagreb,", "kartu", "za", "Jednu", "molim."]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '80f3ea90-75d4-5f1a-95fa-1c683f592b87', 'sentence_builder', 'Складіть: «Я пропустила автобус.»', 'Propustila sam autobus.', '["Propustila", "autobus.", "sam"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ef5139a6-6362-5caa-b26a-edea955aed58', 'listening', 'Прослухайте і складіть фразу', 'U jednom smjeru ili povratnu?', '["jednom", "povratnu?", "smjeru", "ili", "U"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1623e661-c631-5c9a-9cb3-231bd642ead7', 'listening', 'Прослухайте і складіть фразу', 'Gdje mogu kupiti kartu?', '["mogu", "Gdje", "kartu?", "kupiti"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1534f6de-8f86-5658-8dc5-6cfb5215757d', 'speaking', 'Де мені виходити?', 'Gdje trebam izaći?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e5a6fe7c-e6a4-5b75-ae27-6ed5c971635d', 'speaking', 'Який автобус їде в центр?', 'Koji autobus ide u centar?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b86a934a-a762-5807-9d03-b0fb2b2545a0', v_lesson, 'На автовокзалі', 'Na autobusnom kolodvoru', 2581, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('eb7c455e-221b-526b-b8e0-8273a7d507fb', 'b86a934a-a762-5807-9d03-b0fb2b2545a0', 'Daša', 'Dobar dan, jednu kartu za Split, molim.', 'Добрий день, один квиток до Спліта, будь ласка.', 1);
  perform pg_temp.turn('c9aed8c1-f7d2-577d-9719-ed8f0a49046f', 'b86a934a-a762-5807-9d03-b0fb2b2545a0', 'Blagajnik', 'U jednom smjeru ili povratnu?', 'В один бік чи туди й назад?', 2);
  perform pg_temp.turn('20c7b1d9-bc09-51f7-9dec-8aabf472f5c5', 'b86a934a-a762-5807-9d03-b0fb2b2545a0', 'Daša', 'Povratnu. Kada polazi sljedeći autobus?', 'Туди й назад. Коли відправляється наступний автобус?', 3);
  perform pg_temp.turn('a11155aa-13e2-5472-abe3-faa58d9aae89', 'b86a934a-a762-5807-9d03-b0fb2b2545a0', 'Blagajnik', 'U četrnaest i trideset, s petog perona.', 'О чотирнадцятій тридцять, з п’ятого перону.', 4);
  perform pg_temp.turn('df496bb1-44b2-5492-8bbd-bdb3bfcdba87', 'b86a934a-a762-5807-9d03-b0fb2b2545a0', 'Daša', 'Koliko traje putovanje?', 'Скільки триває поїздка?', 5);
  perform pg_temp.turn('ac683cb0-2417-5143-ba49-b507023efd1e', 'b86a934a-a762-5807-9d03-b0fb2b2545a0', 'Blagajnik', 'Oko pet sati.', 'Близько п’яти годин.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d7497f57-33d8-51d1-bb45-c01cad0a2698', v_lesson, 'Яким трамваєм?', 'Kojim tramvajem?', 2582, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('b4d8b761-6cde-5cb5-9d16-e34a9cb621fd', 'd7497f57-33d8-51d1-bb45-c01cad0a2698', 'Darja', 'Tomislave, koji tramvaj ide do kolodvora?', 'Томиславе, який трамвай їде до вокзалу?', 1);
  perform pg_temp.turn('5a38f1cc-b9de-5309-ade9-6452283a3367', 'd7497f57-33d8-51d1-bb45-c01cad0a2698', 'Tomislav', 'Šestica, ali moraš presjesti na trgu.', 'Шістка, але на площі треба пересісти.', 2);
  perform pg_temp.turn('fb1875d9-9dac-5db5-9e9a-54ec00990278', 'd7497f57-33d8-51d1-bb45-c01cad0a2698', 'Darja', 'Gdje mogu kupiti kartu?', 'Де можна купити квиток?', 3);
  perform pg_temp.turn('f5613382-2405-57df-95f5-43d7ed23c1e2', 'd7497f57-33d8-51d1-bb45-c01cad0a2698', 'Tomislav', 'Na kiosku ili kod vozača. Uđi na prednja vrata.', 'У кіоску або у водія. Заходь через передні двері.', 4);
  perform pg_temp.turn('180ebb76-2c89-52e2-a65b-0573b8ce79c2', 'd7497f57-33d8-51d1-bb45-c01cad0a2698', 'Darja', 'A ako dođe kontrolor?', 'А якщо прийде контролер?', 5);
  perform pg_temp.turn('361b7eac-9bcb-5a82-aa30-19d6c2d70645', 'd7497f57-33d8-51d1-bb45-c01cad0a2698', 'Tomislav', 'Bez karte se plaća kazna. Zato imam mjesečnu kartu.', 'Без квитка платиш штраф. Тому в мене місячний проїзний.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.9 · урок 59: Таксі, авто чи велосипед? — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'e0b9d742-0418-597b-9482-b6e2d82469da';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Таксі, авто чи велосипед?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '1e25a53b-376f-5f2b-9db0-406cce3f73b8') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a0_v4: урок перебудовано за темою — стара версія (слова, вправи, діалоги)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  -- новий склад уроку (тема граматики та сама)
  select grammar_topic_id into v_gid from public.lesson_grammar where lesson_id = v_lesson limit 1;
  if v_gid is null then select item_id into v_gid from public.lesson_items where lesson_id = v_lesson and item_type = 'grammar' limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 59: Таксі, авто чи велосипед?', title_hr = 'Lekcija 59: Taksijem, autom ili biciklom?',
         objectives = '["Поїхати таксі: сказати, куди, і запитати ціну", "Поговорити про дорогу на авто: gužva, parkiralište, cestarina", "Розповісти, як ви їздите: autom, biciklom, romobilom"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'auto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'taksi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'taksist', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bicikl', v_pos);
  v_pos := pg_temp.word(v_lesson, 'romobil', v_pos);
  v_pos := pg_temp.word(v_lesson, 'voziti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vožnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'parkirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'parkiralište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'promet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gužva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cesta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'autocesta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cestarina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'benzinska postaja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'benzin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vozačka dozvola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pojas', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pješak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pločnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'biciklistička staza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kazna', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ef334e3-bcdd-5506-8934-14e50a240daa', 'fill_in_the_blank', 'Na posao idem ___.', 'biciklom', '["biciklu", "biciklom", "bicikl", "bicikla"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4d85a740-130c-51c5-9ccd-8f45ef6a74d9', 'multiple_choice', 'Що означає «kazna»?', 'штраф / покарання', '["штраф / покарання", "пасок безпеки; пояс", "водійське посвідчення", "поїздка; їзда"]'::jsonb, 'A0', 2, 'PUBLISHED', 'kazna', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '95af07d4-e221-52f2-b4c7-fefdfa6dd091', 'multiple_choice', 'Що означає «bicikl»?', 'велосипед', '["плата за проїзд (на магістралі)", "велосипед", "штраф / покарання", "дорога (проїжджа частина)"]'::jsonb, 'A0', 3, 'PUBLISHED', 'bicikl', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5c9b491f-76ff-58d3-8de2-594b21471df6', 'multiple_choice', 'Що означає «voziti»?', 'водити (авто) / везти', '["плата за проїзд (на магістралі)", "пасок безпеки; пояс", "водити (авто) / везти", "дорога (проїжджа частина)"]'::jsonb, 'A0', 4, 'PUBLISHED', 'voziti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '49aea02c-eedd-55d7-875e-0d10c87e7807', 'multiple_choice', 'Як хорватською «рух»?', 'promet', '["promet", "taksi", "gužva", "cestarina"]'::jsonb, 'A0', 5, 'PUBLISHED', 'promet', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1820593e-f3e5-5248-8f76-7ceafece8d3f', 'multiple_choice', 'Як хорватською «автомобіль»?', 'auto', '["auto", "taksi", "benzin", "parkiralište"]'::jsonb, 'A0', 6, 'PUBLISHED', 'auto', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '285375d9-a684-532c-810e-064ce026beb7', 'type_answer', 'Напишіть хорватською: «затор; тиснява»', 'gužva', null, 'A0', 7, 'PUBLISHED', 'gužva', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d03c81a-849f-5962-a9de-7322aac7e18e', 'type_answer', 'Напишіть хорватською: «пасок безпеки; пояс»', 'pojas', null, 'A0', 8, 'PUBLISHED', 'pojas', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5ba80b82-6020-5d3f-b96e-cf5c068a529f', 'type_answer', 'Напишіть хорватською: «пішохід»', 'pješak', null, 'A0', 9, 'PUBLISHED', 'pješak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c17e188a-49ee-509f-9ad3-c7021d23c87e', 'sentence_builder', 'Складіть: «Де тут можна припаркуватися?»', 'Gdje se ovdje može parkirati?', '["parkirati?", "može", "Gdje", "se", "ovdje"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd9eab831-1659-524f-b145-025717dd06c6', 'sentence_builder', 'Складіть: «На автомагістралі платять за проїзд.»', 'Na autocesti se plaća cestarina.', '["plaća", "Na", "autocesti", "cestarina.", "se"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d776d8d-057b-5698-a0ae-dfb778612964', 'listening', 'Прослухайте і складіть фразу', 'Malo, ali znam kraći put.', '["kraći", "ali", "put.", "Malo,", "znam"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9a62cd56-07c4-55dc-9baf-361c3ce5c61a', 'listening', 'Прослухайте і складіть фразу', 'Moram zamijeniti vozačku dozvolu.', '["zamijeniti", "Moram", "dozvolu.", "vozačku"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '948dbc64-2cc6-57dd-b13c-9902ed6ef0c6', 'speaking', 'Викличте мені таксі, будь ласка.', 'Pozovite mi taksi, molim vas.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3da22cb2-8e5f-563b-81c8-d73d30ba1a3f', 'speaking', 'Де найближча заправка?', 'Gdje je najbliža benzinska postaja?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1e25a53b-376f-5f2b-9db0-406cce3f73b8', v_lesson, 'У таксі', 'U taksiju', 2591, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('db2e6ca9-0776-567f-b3cb-4ca0fd9e57da', '1e25a53b-376f-5f2b-9db0-406cce3f73b8', 'Taksist', 'Dobra večer, kamo idemo?', 'Добрий вечір, куди їдемо?', 1);
  perform pg_temp.turn('8f1f7224-e698-54c0-988a-10ad2770356b', '1e25a53b-376f-5f2b-9db0-406cce3f73b8', 'Daša', 'Na glavni kolodvor, molim. Koliko će koštati vožnja?', 'На головний вокзал, будь ласка. Скільки коштуватиме поїздка?', 2);
  perform pg_temp.turn('bba17bc1-ca18-5aaa-b5fd-c1014424a28a', '1e25a53b-376f-5f2b-9db0-406cce3f73b8', 'Taksist', 'Oko dvanaest eura. Vežite pojas, molim.', 'Близько дванадцяти євро. Пристебніться, будь ласка.', 3);
  perform pg_temp.turn('6d53984e-7453-5f86-9e5d-486056c1e33d', '1e25a53b-376f-5f2b-9db0-406cce3f73b8', 'Daša', 'Ima li gužve u ovo doba?', 'О цій порі є затори?', 4);
  perform pg_temp.turn('ba6decb9-f3a9-5b7c-9dae-51656470c412', '1e25a53b-376f-5f2b-9db0-406cce3f73b8', 'Taksist', 'Malo, ali znam kraći put.', 'Трохи, але я знаю коротший шлях.', 5);
  perform pg_temp.turn('5ae25fe2-cade-544a-8a88-946872c0e930', '1e25a53b-376f-5f2b-9db0-406cce3f73b8', 'Daša', 'Odlično, žurim se na vlak.', 'Чудово, я поспішаю на поїзд.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('37e44372-6ba4-5940-afbe-803ffa99f6de', v_lesson, 'Автом чи велосипедом?', 'Autom ili biciklom?', 2592, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('2ccfb893-16a6-50de-a2dc-c6fc210c73a5', '37e44372-6ba4-5940-afbe-803ffa99f6de', 'Ante', 'Darja, voziš li ovdje auto?', 'Дар’є, ти тут водиш машину?', 1);
  perform pg_temp.turn('c3983dc9-5787-59ee-a879-8f07ce379c4d', '37e44372-6ba4-5940-afbe-803ffa99f6de', 'Darja', 'Još ne. Moram zamijeniti vozačku dozvolu.', 'Ще ні. Мені треба обміняти водійське посвідчення.', 2);
  perform pg_temp.turn('c34b29a4-423d-5cec-8db0-479f91b6a868', '37e44372-6ba4-5940-afbe-803ffa99f6de', 'Ante', 'Ja na posao idem biciklom. Nema gužve i ne tražim parkiralište.', 'А я їжджу на роботу велосипедом. Жодних заторів, і не треба шукати парковку.', 3);
  perform pg_temp.turn('407f2a54-33a7-51ee-ac89-81990f775eaf', '37e44372-6ba4-5940-afbe-803ffa99f6de', 'Darja', 'Je li to sigurno?', 'А це безпечно?', 4);
  perform pg_temp.turn('52dca5a4-ea94-5346-971d-63f13f484ef0', '37e44372-6ba4-5940-afbe-803ffa99f6de', 'Ante', 'Jest, imamo biciklističku stazu uz cijelu cestu.', 'Так, у нас є велодоріжка вздовж усієї дороги.', 5);
  perform pg_temp.turn('0e6cc2df-04a5-5671-acde-a45123b29863', '37e44372-6ba4-5940-afbe-803ffa99f6de', 'Darja', 'Onda ću probati električni romobil!', 'Тоді спробую електросамокат!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- 3. Новий порядок уроків у модулі A0.9: наявні уроки тимчасово переносяться на місця 100+
--    (unique (unit_id, order_index)), щоб звільнити місця для нових; у кроці 5 — на остаточні місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 9 and u.order_index = 1;
  update public.lessons l set order_index = t.o + 100
    from (values
    ('0addd5be-230b-582f-baed-a5d18eb1d619'::uuid, 1),
    ('55af257e-e4d1-51ed-9637-388a7e0b4baf'::uuid, 2),
    ('1e0384e5-6097-56ed-ab56-cf530f02ab73'::uuid, 3),
    ('e5b81eb1-8ea8-5ff4-a987-e5e46421302b'::uuid, 4),
    ('e0b9d742-0418-597b-9482-b6e2d82469da'::uuid, 5)
    ) as t(id, o)
   where l.id = t.id and l.unit_id = v_unit and l.order_index <> t.o and l.order_index < 100;
end $$;

-- 4. Нові тематичні уроки модуля A0.9
-- 5. Наявні уроки модуля A0.9 — на нові місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 9 and u.order_index = 1;
  update public.lessons set order_index = order_index - 100 where unit_id = v_unit and order_index > 100;
end $$;

-- 6. Наскрізні номери всіх уроків A0 («Урок N: …» / «Lekcija N: …»); стара назва — у content_versions
do $$
declare r record; v_payload jsonb; v_new_ua text; v_new_hr text;
begin
  for r in select l.id, l.title_ua, l.title_hr,
                  row_number() over (order by m.order_index, u.order_index, l.order_index) as n
             from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
            where m.level_code = 'A0' and l.status = 'PUBLISHED' loop
    v_new_ua := regexp_replace(r.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':');
    v_new_hr := regexp_replace(r.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':');
    if v_new_ua is not distinct from r.title_ua and v_new_hr is not distinct from r.title_hr then continue; end if;
    select to_jsonb(l) into v_payload from public.lessons l where l.id = r.id;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'curriculum_a0_v4: новий номер уроку ' || r.n);
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;

-- 7. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_lessons int; v_titles int; v_order int; v_module int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('0addd5be-230b-582f-baed-a5d18eb1d619', '55af257e-e4d1-51ed-9637-388a7e0b4baf', '1e0384e5-6097-56ed-ab56-cf530f02ab73', 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b', 'e0b9d742-0418-597b-9482-b6e2d82469da')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or not exists (select 1 from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar')
             and exists (select 1 from public.lesson_grammar lg where lg.lesson_id = l.id)
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_module from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 9;
  select count(*) into v_order from (values ('0addd5be-230b-582f-baed-a5d18eb1d619'::uuid, 1), ('55af257e-e4d1-51ed-9637-388a7e0b4baf'::uuid, 2), ('1e0384e5-6097-56ed-ab56-cf530f02ab73'::uuid, 3), ('e5b81eb1-8ea8-5ff4-a987-e5e46421302b'::uuid, 4), ('e0b9d742-0418-597b-9482-b6e2d82469da'::uuid, 5)) as t(id, o) join public.lessons l on l.id = t.id and l.order_index = t.o;
  select count(*) into v_lessons from public.lessons where level_code = 'A0' and status = 'PUBLISHED';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A0' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('0addd5be-230b-582f-baed-a5d18eb1d619', '55af257e-e4d1-51ed-9637-388a7e0b4baf', '1e0384e5-6097-56ed-ab56-cf530f02ab73', 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b', 'e0b9d742-0418-597b-9482-b6e2d82469da') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A0.9: % уроків з неправильним складом', v_bad; end if;
  if v_module <> 5 or v_order <> 5 then raise exception 'Модуль A0.9: уроків %, на своїх місцях % (очікувалось 5)', v_module, v_order; end if;
  if v_lessons < 64 then raise exception 'A0: уроків %, очікувалось щонайменше 64', v_lessons; end if;  -- наступні модулі додають уроки
  if v_titles > 0 then raise exception 'A0: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A0.9: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A0.9 — 5 уроків (55–59) за темою; уроків A0 — %', v_lessons;
end $$;

commit;
