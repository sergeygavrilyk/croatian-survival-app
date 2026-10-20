-- =====================================================================
-- Уроки A0 за темою · curriculum_a0_v4 · модуль A0.6 · 2026-10-19
-- Згенеровано: python3 scripts/gen_curriculum_a0_v4.py (не редагуйте вручну).
--
-- Рішення власника 2026-10-15: слова уроку — за темою уроку, 20–25 слів і виразів, діалоги під тему; бета (PUBLISHED).
--   * Уроки 38–43: 4 наявних перебудовано, 2 нових тематичних уроків. Слів у них: 134.
--     Кожен: 20–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 17.
--   * Новий порядок уроків у модулі; назви всіх уроків A0 перенумеровано підряд (разом 63).
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
values ('unajmiti', 'unajmiti', 'hr', 'verb', 'A0', 'винайняти, орендувати (житло)', 'core', '{"aspect": "pf", "present": {"1s": "unajmim", "2s": "unajmiš", "3s": "unajmi"}, "past": "unajmio"}'::jsonb, '["Unajmili smo stan blizu centra."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kvadrat', 'kvadrat', 'hr', 'noun', 'A0', 'квадратний метр (розмовно); квадрат', 'core', '{"gender": "m"}'::jsonb, '["Stan ima pedeset kvadrata."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dvosoban stan', 'dvosoban stan', 'hr', 'phrase', 'A0', 'двокімнатна квартира', 'collocation', '{"gender": "m"}'::jsonb, '["Tražimo dvosoban stan s balkonom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('garsonijera', 'garsonijera', 'hr', 'noun', 'A0', 'квартира-студія; однокімнатна квартира', 'core', '{"gender": "f"}'::jsonb, '["Garsonijera je mala, ali jeftina."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kaucija', 'kaucija', 'hr', 'noun', 'A0', 'застава, депозит (за житло)', 'core', '{"gender": "f"}'::jsonb, '["Kaucija je jedna najamnina."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('noćni ormarić', 'nocni ormaric', 'hr', 'phrase', 'A0', 'тумбочка (біля ліжка)', 'collocation', '{"gender": "m"}'::jsonb, '["Naočale su na noćnom ormariću."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('radni stol', 'radni stol', 'hr', 'phrase', 'A0', 'письмовий (робочий) стіл', 'collocation', '{"gender": "m"}'::jsonb, '["Radni stol je pored prozora."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uz', 'uz', 'hr', 'preposition', 'A0', 'біля, при; уздовж (uz zid — під стіною)', 'function_word', '{"case": "acc"}'::jsonb, '["Krevet stoji uz zid."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('u kutu', 'u kutu', 'hr', 'phrase', 'A0', 'у кутку', 'chunk', '{}'::jsonb, '["U kutu sobe je velika biljka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('na vrhu', 'na vrhu', 'hr', 'phrase', 'A0', 'на верху, нагорі', 'chunk', '{}'::jsonb, '["Kutija je na vrhu ormara."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('na dnu', 'na dnu', 'hr', 'phrase', 'A0', 'на дні; у самому низу', 'chunk', '{}'::jsonb, '["Ključevi su na dnu torbe."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('na sredini', 'na sredini', 'hr', 'phrase', 'A0', 'посередині', 'chunk', '{}'::jsonb, '["Na sredini sobe je stol."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('daljinski upravljač', 'daljinski upravljac', 'hr', 'phrase', 'A0', 'пульт (від телевізора)', 'collocation', '{"gender": "m"}'::jsonb, '["Daljinski upravljač je na kauču."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('glačalo', 'glacalo', 'hr', 'noun', 'A0', 'праска', 'core', '{"gender": "n"}'::jsonb, '["Glačalo je u ormaru u hodniku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bojler', 'bojler', 'hr', 'noun', 'A0', 'бойлер (водонагрівач)', 'core', '{"gender": "m"}'::jsonb, '["Bojler je pokvaren pa se tuširamo hladnom vodom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('topla voda', 'topla voda', 'hr', 'phrase', 'A0', 'гаряча вода', 'collocation', '{"gender": "f"}'::jsonb, '["Imate li toplu vodu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('glasan', 'glasan', 'hr', 'adjective', 'A0', 'гучний', 'core', '{"f": "glasna", "n": "glasno"}'::jsonb, '["Susjedi imaju glasnog psa."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;

-- 2. Перебудова наявних уроків модуля A0.6
-- A0.6 · урок 38: Моя квартира — перебудова: 24 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '78f28f85-dd8b-5e81-8a52-1b2dbce4eb34';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Моя квартира» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '56d16204-72dd-54f5-99b1-7935290828a6') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 38: Моя квартира', title_hr = 'Lekcija 38: Moj stan',
         objectives = '["Назвати кімнати й частини квартири", "Зрозуміти оголошення про оренду: dvosoban, namješten, najamnina, kaucija", "Запитати власника про квартиру й домовитися про огляд"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'stan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'soba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dnevni boravak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kuhinja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupaonica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spavaća soba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hodnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zahod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'balkon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'terasa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podrum', v_pos);
  v_pos := pg_temp.word(v_lesson, 'garaža', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dvosoban stan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'garsonijera', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kvadrat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'namješten', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najam', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najamnina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stanodavac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kaucija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'unajmiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iznajmiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'useliti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oglas', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '692be9a5-f2d2-510f-abc2-04034f4a4470', 'fill_in_the_blank', 'Kupaonica je pored ___ sobe.', 'spavaće', '["spavaće", "spavaću", "spavaća", "spavaćoj"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6e402789-bf84-5a41-b111-8adf17ab4170', 'multiple_choice', 'Що означає «dnevni boravak»?', 'вітальня', '["підвал", "вітальня", "оренда", "власник житла / орендодавець"]'::jsonb, 'A0', 2, 'PUBLISHED', 'dnevni boravak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8be8aa8-ee67-505a-ae16-b81f355fe494', 'multiple_choice', 'Що означає «stanodavac»?', 'власник житла / орендодавець', '["тераса", "власник житла / орендодавець", "спальня", "застава, депозит (за житло)"]'::jsonb, 'A0', 3, 'PUBLISHED', 'stanodavac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b616b476-98f8-5896-bd95-66e4c19a4d23', 'multiple_choice', 'Що означає «kaucija»?', 'застава, депозит (за житло)', '["застава, депозит (за житло)", "квадратний метр (розмовно); квадрат", "тераса", "ванна кімната"]'::jsonb, 'A0', 4, 'PUBLISHED', 'kaucija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7de98497-2242-581d-84d2-556b321a28fa', 'multiple_choice', 'Як хорватською «мебльований»?', 'namješten', '["unajmiti", "kuhinja", "garaža", "namješten"]'::jsonb, 'A0', 5, 'PUBLISHED', 'namješten', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fb833a5a-16a4-5bd9-94c9-763d862f1dcf', 'multiple_choice', 'Як хорватською «оголошення»?', 'oglas', '["oglas", "balkon", "stan", "kuhinja"]'::jsonb, 'A0', 6, 'PUBLISHED', 'oglas', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e248fb8-2209-52f3-8b0e-242e6f4be548', 'type_answer', 'Напишіть хорватською: «балкон»', 'balkon', null, 'A0', 7, 'PUBLISHED', 'balkon', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd86a8459-8bc6-59a6-ad0e-16c19af26d08', 'type_answer', 'Напишіть хорватською: «спальня»', 'spavaća soba', null, 'A0', 8, 'PUBLISHED', 'spavaća soba', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f828593b-f6ef-5cb5-8bf2-fe63f1075075', 'type_answer', 'Напишіть хорватською: «коридор»', 'hodnik', null, 'A0', 9, 'PUBLISHED', 'hodnik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '66f49a36-64a8-50ff-9395-84fe16cf365c', 'sentence_builder', 'Складіть: «Квартира ще вільна?»', 'Je li stan još slobodan?', '["stan", "li", "Je", "još", "slobodan?"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3289e7fd-8cf7-5eab-bf39-433a37e7d2d7', 'sentence_builder', 'Складіть: «Де ванна кімната?»', 'Gdje je kupaonica?', '["je", "kupaonica?", "Gdje"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b8790325-ada8-5c75-93db-99b8eabf8778', 'listening', 'Прослухайте і складіть фразу', 'Je li namješten?', '["li", "namješten?", "Je"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '30a3d455-387d-5de5-9057-99c3a515a825', 'listening', 'Прослухайте і складіть фразу', 'Ima li stan podrum ili garažu?', '["li", "Ima", "ili", "garažu?", "podrum", "stan"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f1ad662a-ace6-5634-979e-1a46390cb6cd', 'speaking', 'Я шукаю квартиру.', 'Tražim stan.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f39512c7-8883-50be-8f8d-e76a439a372f', 'speaking', 'Скільки коштує оренда?', 'Koliko je najamnina?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('56d16204-72dd-54f5-99b1-7935290828a6', v_lesson, 'Оголошення', 'Oglas za stan', 2381, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('ff7a175d-1af4-53fe-9460-640398928454', '56d16204-72dd-54f5-99b1-7935290828a6', 'Daša', 'Dobar dan, zovem zbog oglasa. Je li stan još slobodan?', 'Добрий день, я телефоную щодо оголошення. Квартира ще вільна?', 1);
  perform pg_temp.turn('2d73f17c-6684-5fb0-8ad4-e84395c4980e', '56d16204-72dd-54f5-99b1-7935290828a6', 'Stanodavac', 'Jest. To je dvosoban stan, šezdeset kvadrata, s balkonom.', 'Так. Це двокімнатна квартира, шістдесят квадратних метрів, з балконом.', 2);
  perform pg_temp.turn('d5bef826-cf97-5145-8866-df108b1ce460', '56d16204-72dd-54f5-99b1-7935290828a6', 'Daša', 'Je li namješten?', 'Вона мебльована?', 3);
  perform pg_temp.turn('03af109b-3fa9-55d3-8c9a-57c5ee2996ea', '56d16204-72dd-54f5-99b1-7935290828a6', 'Stanodavac', 'Jest, potpuno. Najamnina je petsto eura, a režije posebno.', 'Так, повністю. Оренда — п’ятсот євро, а комунальні окремо.', 4);
  perform pg_temp.turn('c37776c9-70d4-59f3-8f97-e8423a77770b', '56d16204-72dd-54f5-99b1-7935290828a6', 'Daša', 'Tražite li kauciju?', 'Ви берете заставу?', 5);
  perform pg_temp.turn('77117d02-b4f8-5d7f-acdc-60f594c46023', '56d16204-72dd-54f5-99b1-7935290828a6', 'Stanodavac', 'Da, jednu najamninu. Možete ga pogledati sutra.', 'Так, у розмірі місячної оплати. Можете подивитися її завтра.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cbc1c114-4892-513d-bb6b-8b7618609a68', v_lesson, 'Огляд квартири', 'Razgledavanje stana', 2382, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('d960b680-380e-5ee7-9b32-378da3bbe3a5', 'cbc1c114-4892-513d-bb6b-8b7618609a68', 'Stanodavac', 'Izvolite. Ovo je dnevni boravak, a tamo je kuhinja.', 'Прошу. Це вітальня, а там кухня.', 1);
  perform pg_temp.turn('f58567a1-db8e-5069-9352-2f3d8200e235', 'cbc1c114-4892-513d-bb6b-8b7618609a68', 'Daša', 'Lijepo! Gdje je kupaonica?', 'Гарно! А де ванна кімната?', 2);
  perform pg_temp.turn('23e7262d-edb3-5832-8847-ebbd1ab49a93', 'cbc1c114-4892-513d-bb6b-8b7618609a68', 'Stanodavac', 'Na kraju hodnika, pored spavaće sobe. Zahod je odvojen.', 'У кінці коридору, біля спальні. Туалет окремо.', 3);
  perform pg_temp.turn('4ef6854f-95ac-535b-a685-538899557e52', 'cbc1c114-4892-513d-bb6b-8b7618609a68', 'Daša', 'Ima li stan podrum ili garažu?', 'У квартири є підвал чи гараж?', 4);
  perform pg_temp.turn('3aa661f2-9a17-5a9c-ba75-feeda41bf3b9', 'cbc1c114-4892-513d-bb6b-8b7618609a68', 'Stanodavac', 'Ima podrum. Kada se želite useliti?', 'Є підвал. Коли ви хочете заїхати?', 5);
  perform pg_temp.turn('8233502a-453b-51f6-8a15-eff4407075a8', 'cbc1c114-4892-513d-bb6b-8b7618609a68', 'Daša', 'Početkom sljedećeg mjeseca, ako može.', 'На початку наступного місяця, якщо можна.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.6 · урок 39: Що є в кімнаті? — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '1436c20e-0aea-550a-b66d-fb3149a1c2e2';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Що є в кімнаті?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'fc2bde4c-bcff-5203-9946-11ca1b83184b') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 39: Що є в кімнаті?', title_hr = 'Lekcija 39: Što ima u sobi?',
         objectives = '["Назвати меблі: krevet, ormar, stol, kauč, polica", "Назвати речі для спальні: jastuk, pokrivač, plahta", "Купити меблі в магазині"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'namještaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krevet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stolica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ormar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kauč', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fotelja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ladica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'noćni ormarić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radni stol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tepih', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zavjesa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lampa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ogledalo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jastuk', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pokrivač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plahta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'madrac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vješalica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kutija', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dd4dec9f-0c83-5a9b-b10d-953c117804b4', 'fill_in_the_blank', 'Knjige su na ___.', 'polici', '["polici", "policu", "polica", "policom"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd61d1e7e-aa70-5d57-836e-ffa13561a85f', 'multiple_choice', 'Що означає «pokrivač»?', 'ковдра', '["шухляда", "ковдра", "письмовий (робочий) стіл", "лампа"]'::jsonb, 'A0', 2, 'PUBLISHED', 'pokrivač', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8db7a58-bf92-56ef-aa63-c843cecc6df6', 'multiple_choice', 'Що означає «radni stol»?', 'письмовий (робочий) стіл', '["тумбочка (біля ліжка)", "ковдра", "письмовий (робочий) стіл", "завіса, штора"]'::jsonb, 'A0', 3, 'PUBLISHED', 'radni stol', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '86d2e168-b465-5a42-87ef-b0d91fbab098', 'multiple_choice', 'Що означає «lampa»?', 'лампа', '["тумбочка (біля ліжка)", "ліжко", "матрац", "лампа"]'::jsonb, 'A0', 4, 'PUBLISHED', 'lampa', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2451c86d-f4c8-544d-8cb6-8b9dca2ead3b', 'multiple_choice', 'Як хорватською «вішалка»?', 'vješalica', '["stol", "zavjesa", "vješalica", "kauč"]'::jsonb, 'A0', 5, 'PUBLISHED', 'vješalica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1a9fa693-4f89-5b11-8a75-c73322a56bb6', 'multiple_choice', 'Як хорватською «шафа»?', 'ormar', '["stol", "madrac", "lampa", "ormar"]'::jsonb, 'A0', 6, 'PUBLISHED', 'ormar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '974e491f-8a13-5127-a244-b6c1085ea73f', 'type_answer', 'Напишіть хорватською: «коробка»', 'kutija', null, 'A0', 7, 'PUBLISHED', 'kutija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '26ba5554-344e-56f0-bf3e-914e39243980', 'type_answer', 'Напишіть хорватською: «килим»', 'tepih', null, 'A0', 8, 'PUBLISHED', 'tepih', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2db60ebf-737b-568f-969d-615aa7f9a062', 'type_answer', 'Напишіть хорватською: «простирадло»', 'plahta', null, 'A0', 9, 'PUBLISHED', 'plahta', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '64a7484a-d870-5259-a0ad-9105da0a0c6d', 'sentence_builder', 'Складіть: «У кімнаті є ліжко й шафа.»', 'U sobi su krevet i ormar.', '["krevet", "ormar.", "sobi", "su", "i", "U"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '18d0f658-2f70-55bb-9f2f-0a903ba7a835', 'sentence_builder', 'Складіть: «Я шукаю новий диван.»', 'Tražim novi kauč.', '["novi", "Tražim", "kauč."]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '63aef7df-2b03-5774-8ccc-6921eb0e1915', 'listening', 'Прослухайте і складіть фразу', 'Na polici iznad stola.', '["iznad", "polici", "stola.", "Na"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '278e7b6e-0d51-5c4a-92dd-0d7f31f05132', 'listening', 'Прослухайте і складіть фразу', 'Tražim kauč za dnevni boravak.', '["Tražim", "dnevni", "kauč", "boravak.", "za"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7b773a7d-e2b3-5ddc-a310-73a07507dcfc', 'speaking', 'Це зручне крісло.', 'Ovo je udobna fotelja.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c2f7320-95ca-5fc0-9e2b-69b5cc104297', 'speaking', 'Де шафа?', 'Gdje je ormar?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('fc2bde4c-bcff-5203-9946-11ca1b83184b', v_lesson, 'Нова кімната', 'Nova soba', 2391, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('07c9ca66-26be-5c99-b71f-7eff3fd1cfbb', 'fc2bde4c-bcff-5203-9946-11ca1b83184b', 'Ivana', 'Dašo, kakva ti je nova soba?', 'Дашо, яка в тебе нова кімната?', 1);
  perform pg_temp.turn('b7e6ee7d-df12-5217-9c61-7b0eec387139', 'fc2bde4c-bcff-5203-9946-11ca1b83184b', 'Daša', 'Mala je, ali lijepa. Ima krevet, ormar i radni stol.', 'Маленька, але гарна. Є ліжко, шафа й письмовий стіл.', 2);
  perform pg_temp.turn('9ade8a89-4a3f-5d4a-9f0f-5acbf7189f46', 'fc2bde4c-bcff-5203-9946-11ca1b83184b', 'Ivana', 'A gdje držiš knjige?', 'А де ти тримаєш книжки?', 3);
  perform pg_temp.turn('8bfdefcc-5a72-5005-9e95-bb4f3bf36f50', 'fc2bde4c-bcff-5203-9946-11ca1b83184b', 'Daša', 'Na polici iznad stola.', 'На полиці над столом.', 4);
  perform pg_temp.turn('d7bec48a-20aa-58a7-9df8-265fd1abab06', 'fc2bde4c-bcff-5203-9946-11ca1b83184b', 'Ivana', 'Treba ti još jedna lampa i tepih.', 'Тобі ще потрібні лампа й килим.', 5);
  perform pg_temp.turn('e5268b15-681b-5da6-81ad-fe26f4c29bc7', 'fc2bde4c-bcff-5203-9946-11ca1b83184b', 'Daša', 'Imaš pravo. U subotu idem u trgovinu namještajem.', 'Маєш рацію. У суботу піду в меблевий магазин.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('fa783e5d-d420-54d4-bf99-22ad90e4a9c6', v_lesson, 'У меблевому магазині', 'U trgovini namještajem', 2392, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('3a4ca86d-2353-5df4-8ba5-8758eeef3bfe', 'fa783e5d-d420-54d4-bf99-22ad90e4a9c6', 'Prodavač', 'Dobar dan, mogu li vam pomoći?', 'Добрий день, чим можу допомогти?', 1);
  perform pg_temp.turn('1e1d078e-5790-513d-a5a2-d1525a2af695', 'fa783e5d-d420-54d4-bf99-22ad90e4a9c6', 'Daša', 'Tražim kauč za dnevni boravak.', 'Я шукаю диван для вітальні.', 2);
  perform pg_temp.turn('57adc12d-1ad3-5a67-8b59-b4fa2ef263ab', 'fa783e5d-d420-54d4-bf99-22ad90e4a9c6', 'Prodavač', 'Ovaj je udoban i nije skup.', 'Цей зручний і недорогий.', 3);
  perform pg_temp.turn('7141f6ea-5609-5e2a-93b5-028912bbb41c', 'fa783e5d-d420-54d4-bf99-22ad90e4a9c6', 'Daša', 'Lijep je. Imate li i jastuke iste boje?', 'Гарний. А подушки такого ж кольору у вас є?', 4);
  perform pg_temp.turn('e6666be1-8536-5e88-9724-35fcda5a497e', 'fa783e5d-d420-54d4-bf99-22ad90e4a9c6', 'Prodavač', 'Imamo, tamo pored ogledala.', 'Є, он там біля дзеркала.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.6 · урок 41: Де мої ключі? — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '0ecb6f19-2630-533d-9f1b-85102442af08';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Де мої ключі?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'f906094e-4257-5c49-b6db-9201e5672019') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 41: Де мої ключі?', title_hr = 'Lekcija 41: Gdje su moji ključevi?',
         objectives = '["Назвати речі, які ми щодня шукаємо: ključ, novčanik, naočale, punjač", "Попросити зачинити, замкнути, вимкнути", "Сказати, що ви щось загубили чи знайшли"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'ključ', v_pos);
  v_pos := pg_temp.word(v_lesson, 'novčanik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'torba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ruksak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naočale', v_pos);
  v_pos := pg_temp.word(v_lesson, 'punjač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'daljinski upravljač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prozor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svjetlo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upaliti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugasiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otvoriti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zatvoriti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaključati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otključati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izgubiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tražiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'staviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ostaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaboraviti', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f556a6ed-370f-5b47-950d-90842a146cde', 'fill_in_the_blank', 'Ne mogu naći svoje ___.', 'ključeve', '["ključevima", "ključeve", "ključ", "ključevi"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4caea851-bdfc-5c68-b936-9811f852bd2b', 'multiple_choice', 'Що означає «ostaviti»?', 'залишити', '["шукати", "покласти; поставити", "залишити", "окуляри"]'::jsonb, 'A0', 2, 'PUBLISHED', 'ostaviti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e30918ad-e192-5ac6-81db-ed04cc0b9834', 'multiple_choice', 'Що означає «ruksak»?', 'рюкзак', '["забути", "рюкзак", "окуляри", "вікно"]'::jsonb, 'A0', 3, 'PUBLISHED', 'ruksak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '63ab0bdc-087f-59a8-acca-fec1d1e68a88', 'multiple_choice', 'Що означає «zaključati»?', 'замкнути', '["пульт (від телевізора)", "замкнути", "гаманець", "сумка"]'::jsonb, 'A0', 4, 'PUBLISHED', 'zaključati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c5465f3e-62ec-5dca-bb1b-f7bb26327f53', 'multiple_choice', 'Як хорватською «загубити; втратити; програти»?', 'izgubiti', '["otključati", "ruksak", "otvoriti", "izgubiti"]'::jsonb, 'A0', 5, 'PUBLISHED', 'izgubiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6d8650c5-1d35-52d5-8c10-785227c2294f', 'multiple_choice', 'Як хорватською «покласти; поставити»?', 'staviti', '["naočale", "prozor", "staviti", "otključati"]'::jsonb, 'A0', 6, 'PUBLISHED', 'staviti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd056649d-0a48-536c-b802-feea4ed3f7e3', 'type_answer', 'Напишіть хорватською: «гаманець»', 'novčanik', null, 'A0', 7, 'PUBLISHED', 'novčanik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ef11cf3f-9ea1-5639-8304-15ebc26da476', 'type_answer', 'Напишіть хорватською: «ключ»', 'ključ', null, 'A0', 8, 'PUBLISHED', 'ključ', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3bd7cd23-0262-5b84-9b49-2c06a74061a0', 'type_answer', 'Напишіть хорватською: «сумка»', 'torba', null, 'A0', 9, 'PUBLISHED', 'torba', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0a3696ae-8892-5254-8c79-3b90cc66ddb3', 'sentence_builder', 'Складіть: «Я не можу знайти свій гаманець.»', 'Ne mogu naći svoj novčanik.', '["svoj", "mogu", "naći", "novčanik.", "Ne"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2a6ea77c-7131-5ad8-b0dc-e54104efdbb8', 'sentence_builder', 'Складіть: «Вимкни світло, будь ласка.»', 'Ugasi svjetlo, molim te.', '["molim", "svjetlo,", "Ugasi", "te."]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '49e3ff38-49a9-5ec3-b3f8-fffebc3a9722', 'listening', 'Прослухайте і складіть фразу', 'Jesi li pogledala u torbi?', '["torbi?", "pogledala", "li", "Jesi", "u"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '956f331c-f30c-5735-94b9-df2360125d70', 'listening', 'Прослухайте і складіть фразу', 'I ugasio sam svjetlo.', '["I", "svjetlo.", "ugasio", "sam"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3c1e0ad9-1415-5e4a-a4d0-d5d0c24f33c1', 'speaking', 'Де мої окуляри?', 'Gdje su moje naočale?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '207be29c-25ca-5455-a077-5e1a13b42f52', 'speaking', 'Зачини вікно, будь ласка.', 'Zatvori prozor, molim te.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f906094e-4257-5c49-b6db-9201e5672019', v_lesson, 'Де ключі?', 'Gdje su ključevi?', 2411, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('4a46bcf6-3cff-5d49-9529-221aa795d377', 'f906094e-4257-5c49-b6db-9201e5672019', 'Daša', 'Mia, jesi li vidjela moje ključeve? Ne mogu ih naći!', 'Міє, ти бачила мої ключі? Не можу їх знайти!', 1);
  perform pg_temp.turn('2b45ff08-d2df-5c13-838b-79da30cc7ba3', 'f906094e-4257-5c49-b6db-9201e5672019', 'Mia', 'Jesi li pogledala u torbi?', 'Ти дивилася в сумці?', 2);
  perform pg_temp.turn('daa239dc-abbd-547e-b11f-e9dbb218aca6', 'f906094e-4257-5c49-b6db-9201e5672019', 'Daša', 'Jesam. Nisu ni u torbi ni u novčaniku.', 'Так. Їх немає ні в сумці, ні в гаманці.', 3);
  perform pg_temp.turn('8b70aa93-576b-5f5b-85ec-dfccd799c3ee', 'f906094e-4257-5c49-b6db-9201e5672019', 'Mia', 'Evo ih! Bili su na stolu, ispod novina.', 'Ось вони! Вони були на столі, під газетою.', 4);
  perform pg_temp.turn('fb6ed2c0-6572-511a-b251-5361780b9277', 'f906094e-4257-5c49-b6db-9201e5672019', 'Daša', 'Hvala! Uvijek ih negdje ostavim.', 'Дякую! Я завжди їх десь залишаю.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('17bc6f1a-3b49-5025-97e7-e2d653cb5123', v_lesson, 'Перед виходом', 'Prije izlaska', 2412, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('5fcca76e-ddb1-579d-9ef9-6a9625a0e621', '17bc6f1a-3b49-5025-97e7-e2d653cb5123', 'Daša', 'Danilo, jesi li zatvorio prozor u kuhinji?', 'Даниле, ти зачинив вікно на кухні?', 1);
  perform pg_temp.turn('ec02ebda-f9b6-5d93-81c9-47f8d1bf1f26', '17bc6f1a-3b49-5025-97e7-e2d653cb5123', 'Danilo', 'Jesam. I ugasio sam svjetlo.', 'Так. І вимкнув світло.', 2);
  perform pg_temp.turn('5234ca87-446e-582f-8808-28f649c8f9b1', '17bc6f1a-3b49-5025-97e7-e2d653cb5123', 'Daša', 'Dobro. Ne zaboravi zaključati vrata!', 'Добре. Не забудь замкнути двері!', 3);
  perform pg_temp.turn('26b0fe30-f50f-5a6c-b0f6-ea0e895c0830', '17bc6f1a-3b49-5025-97e7-e2d653cb5123', 'Danilo', 'Neću. Mama, gdje je moj punjač?', 'Не забуду. Мамо, де мій зарядний?', 4);
  perform pg_temp.turn('6a4fec1f-5907-5495-82db-1ed638306545', '17bc6f1a-3b49-5025-97e7-e2d653cb5123', 'Daša', 'U tvom ruksaku. Idemo, kasnimo!', 'У твоєму рюкзаку. Ходімо, ми запізнюємося!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.6 · урок 42: Техніка й комунальні послуги — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Техніка й комунальні послуги» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'ddcdbb1a-b269-543e-8b51-9851ffc1271a') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 42: Техніка й комунальні послуги', title_hr = 'Lekcija 42: Kućanski aparati i režije',
         objectives = '["Назвати побутову техніку: hladnjak, štednjak, perilica, usisavač", "Повідомити власника про поломку й попросити майстра", "Говорити про комунальні: struja, plin, grijanje, račun za struju"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'hladnjak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'štednjak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pećnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mikrovalna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'perilica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'perilica posuđa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'usisavač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glačalo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'televizor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'klima', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grijanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bojler', v_pos);
  v_pos := pg_temp.word(v_lesson, 'struja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'topla voda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'režije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'račun za struju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kvar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pokvaren', v_pos);
  v_pos := pg_temp.word(v_lesson, 'popraviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'majstor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'utičnica', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa1333de-0d73-5dc6-a5ab-48b111db9306', 'fill_in_the_blank', 'Mlijeko je u ___.', 'hladnjaku', '["hladnjak", "hladnjaku", "hladnjaka", "hladnjakom"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0d1e7f4a-d06c-5077-94ec-cba9b324d258', 'multiple_choice', 'Що означає «račun za struju»?', 'рахунок за електрику', '["рахунок за електрику", "духовка", "телевізор", "розетка"]'::jsonb, 'A0', 2, 'PUBLISHED', 'račun za struju', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5c477dd4-a60f-5395-b3f7-ce8bedf4b484', 'multiple_choice', 'Що означає «štednjak»?', 'плита (для готування)', '["майстер", "відремонтувати / полагодити", "пилосос", "плита (для готування)"]'::jsonb, 'A0', 3, 'PUBLISHED', 'štednjak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e42f4f66-4689-5ba4-9767-8876d978ee7e', 'multiple_choice', 'Що означає «majstor»?', 'майстер', '["плита (для готування)", "несправність / поломка", "майстер", "розетка"]'::jsonb, 'A0', 4, 'PUBLISHED', 'majstor', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '578dc1b8-7ccb-5eb2-86a2-c4e7ea2678a0', 'multiple_choice', 'Як хорватською «зіпсований»?', 'pokvaren', '["pokvaren", "kvar", "grijanje", "perilica"]'::jsonb, 'A0', 5, 'PUBLISHED', 'pokvaren', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'afdef45b-9990-51fe-bf99-4126cef56529', 'multiple_choice', 'Як хорватською «телевізор»?', 'televizor', '["mikrovalna", "štednjak", "televizor", "pećnica"]'::jsonb, 'A0', 6, 'PUBLISHED', 'televizor', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9ae32ac9-db79-53df-a0c2-b14b971f933f', 'type_answer', 'Напишіть хорватською: «відремонтувати / полагодити»', 'popraviti', null, 'A0', 7, 'PUBLISHED', 'popraviti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '445f60be-cfc7-5fea-a4d1-ff60b7b717de', 'type_answer', 'Напишіть хорватською: «розетка»', 'utičnica', null, 'A0', 8, 'PUBLISHED', 'utičnica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '90144b8d-9fdf-50b2-81b3-5ba5f8b8df1c', 'type_answer', 'Напишіть хорватською: «мікрохвильовка»', 'mikrovalna', null, 'A0', 9, 'PUBLISHED', 'mikrovalna', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cdff946c-b2bb-5be4-b87e-c20f44198222', 'sentence_builder', 'Складіть: «Пральна машина не працює.»', 'Perilica ne radi.', '["radi.", "ne", "Perilica"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6faed243-7cd6-5ed4-a9ab-98300a066de6', 'sentence_builder', 'Складіть: «Коли прийде майстер?»', 'Kada dolazi majstor?', '["dolazi", "majstor?", "Kada"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd8e7c0f8-5f2d-535a-b1e9-3af0f323b774', 'listening', 'Прослухайте і складіть фразу', 'Poslat ću majstora sutra ujutro.', '["ću", "Poslat", "sutra", "ujutro.", "majstora"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '80c5c192-d1fd-5607-8d89-24276eb598ea', 'listening', 'Прослухайте і складіть фразу', 'Ljeti stalno radi klima.', '["radi", "klima.", "Ljeti", "stalno"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '77389d2f-c16b-534c-bb19-b24f62fc57e0', 'speaking', 'Немає гарячої води.', 'Nema tople vode.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '85a161f1-84b2-5072-836b-8ea71e6a8c12', 'speaking', 'Холодильник зламався.', 'Hladnjak je pokvaren.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ddcdbb1a-b269-543e-8b51-9851ffc1271a', v_lesson, 'Не працює пральна машина', 'Perilica ne radi', 2421, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('795a1840-0c1b-53ba-ad58-d1987dfc046f', 'ddcdbb1a-b269-543e-8b51-9851ffc1271a', 'Daša', 'Dobar dan, gospodine Horvat. Perilica ne radi već dva dana.', 'Добрий день, пане Горвате. Пральна машина вже два дні не працює.', 1);
  perform pg_temp.turn('302f67c6-2bc7-51d8-805a-5804dc23c2c8', 'ddcdbb1a-b269-543e-8b51-9851ffc1271a', 'Stanodavac', 'Joj, žao mi je. Što se točno dogodilo?', 'Ой, мені шкода. Що саме сталося?', 2);
  perform pg_temp.turn('bc52ce13-55bb-513e-bc28-0bbfbc396aa6', 'ddcdbb1a-b269-543e-8b51-9851ffc1271a', 'Daša', 'Ne pali se. Mislim da je pokvarena.', 'Не вмикається. Думаю, вона зламалася.', 3);
  perform pg_temp.turn('6e82e724-a1ba-56a1-b3c6-1a810aef2a2a', 'ddcdbb1a-b269-543e-8b51-9851ffc1271a', 'Stanodavac', 'Poslat ću majstora sutra ujutro.', 'Я пришлю майстра завтра вранці.', 4);
  perform pg_temp.turn('5aaebee8-a6cb-5408-a31d-3f1cce7280e9', 'ddcdbb1a-b269-543e-8b51-9851ffc1271a', 'Daša', 'Hvala! I bojler je jako star, često nemamo tople vode.', 'Дякую! І бойлер дуже старий, часто немає гарячої води.', 5);
  perform pg_temp.turn('ffd8430b-5e26-5978-acfc-5e0f7de79eba', 'ddcdbb1a-b269-543e-8b51-9851ffc1271a', 'Stanodavac', 'Dobro, neka majstor pogleda i njega.', 'Добре, хай майстер огляне і його.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a5149426-2c27-53ea-a9f7-484c1e7921d5', v_lesson, 'Комунальні рахунки', 'Režije', 2422, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('2333a3b5-847a-5df5-880c-afa6b82a532d', 'a5149426-2c27-53ea-a9f7-484c1e7921d5', 'Ivana', 'Dašo, koliko plaćaš režije?', 'Дашо, скільки ти платиш за комунальні?', 1);
  perform pg_temp.turn('5323baf4-be2e-5cbe-aebd-9062543b77fd', 'a5149426-2c27-53ea-a9f7-484c1e7921d5', 'Daša', 'Zimi oko sto pedeset eura, zbog grijanja.', 'Узимку близько ста п’ятдесяти євро, через опалення.', 2);
  perform pg_temp.turn('64dc44f9-870d-50a1-b459-aa963eaf57db', 'a5149426-2c27-53ea-a9f7-484c1e7921d5', 'Ivana', 'Kod nas je najskuplji račun za struju.', 'У нас найдорожчий рахунок за електрику.', 3);
  perform pg_temp.turn('76e39b26-1e95-5fff-a08d-712e4f0e9229', 'a5149426-2c27-53ea-a9f7-484c1e7921d5', 'Daša', 'I kod nas. Ljeti stalno radi klima.', 'І в нас. Улітку постійно працює кондиціонер.', 4);
  perform pg_temp.turn('e68c9c12-4cf5-5e1f-9d9d-3dbb4ac43d29', 'a5149426-2c27-53ea-a9f7-484c1e7921d5', 'Ivana', 'Mi smo kupili novu perilicu posuđa. Troši malo struje.', 'Ми купили нову посудомийну машину. Вона споживає мало електрики.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- 3. Новий порядок уроків у модулі A0.6: наявні уроки тимчасово переносяться на місця 100+
--    (unique (unit_id, order_index)), щоб звільнити місця для нових; у кроці 5 — на остаточні місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 6 and u.order_index = 1;
  update public.lessons l set order_index = t.o + 100
    from (values
    ('78f28f85-dd8b-5e81-8a52-1b2dbce4eb34'::uuid, 1),
    ('1436c20e-0aea-550a-b66d-fb3149a1c2e2'::uuid, 2),
    ('0ecb6f19-2630-533d-9f1b-85102442af08'::uuid, 4),
    ('e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9'::uuid, 5)
    ) as t(id, o)
   where l.id = t.id and l.unit_id = v_unit and l.order_index <> t.o and l.order_index < 100;
end $$;

-- 4. Нові тематичні уроки модуля A0.6
-- A0.6 · урок 40: Де це? Прийменники місця — новий урок: 22 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '32f5d97b-d6c0-57af-9e48-86f9ee9a932d';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A0.6: місце 3 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Де? Прийменники місця' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Де? Прийменники місця»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 40: Де це? Прийменники місця', 'Lekcija 40: Gdje je to?', '["Сказати, де щось лежить: ispod, iznad, pored, iza, između", "Сказати «нагорі», «унизу», «у кутку», «посередині»", "Пояснити вантажникам, куди ставити меблі, і знайти кабінет у будівлі"]'::jsonb, 15, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'ispod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iznad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pored', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pokraj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispred', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'između', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'unutra', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vani', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gore', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dolje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lijevo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'desno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u kutu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na vrhu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na dnu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na sredini', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zid', v_pos);
  v_pos := pg_temp.word(v_lesson, 'strop', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nalaziti se', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '5c48fa03-b543-5229-aa16-b1334353927a', 'fill_in_the_blank', 'Mačka spava ispod ___.', 'stola', '["stolom", "stolu", "stol", "stola"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9c64c6d9-b721-5741-82e2-57641611d32e', 'multiple_choice', 'Що означає «na dnu»?', 'на дні; у самому низу', '["на дні; у самому низу", "стіна", "вгорі", "всередині / всередину"]'::jsonb, 'A0', 2, 'PUBLISHED', 'na dnu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f02c1145-bdcf-5ef6-8065-fed2bed8b3d0', 'multiple_choice', 'Що означає «unutra»?', 'всередині / всередину', '["направо / праворуч", "на дні; у самому низу", "біля, при; уздовж (uz zid — під стіною)", "всередині / всередину"]'::jsonb, 'A0', 3, 'PUBLISHED', 'unutra', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '909bdd11-c25d-5580-8dc1-c76230605c85', 'multiple_choice', 'Що означає «pokraj»?', 'поруч із', '["внизу", "перед", "поруч із", "стіна"]'::jsonb, 'A0', 4, 'PUBLISHED', 'pokraj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'da523059-2c59-5118-ac4b-0e2af91665a1', 'multiple_choice', 'Як хорватською «надворі»?', 'vani', '["desno", "vani", "iza", "dolje"]'::jsonb, 'A0', 5, 'PUBLISHED', 'vani', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '15a386e8-91a7-5aca-a2f4-35eaa9c4defa', 'multiple_choice', 'Як хорватською «над»?', 'iznad', '["zid", "vani", "lijevo", "iznad"]'::jsonb, 'A0', 6, 'PUBLISHED', 'iznad', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '67af5c39-ed72-59ec-b1a4-e9e60a4e3026', 'type_answer', 'Напишіть хорватською: «стіна»', 'zid', null, 'A0', 7, 'PUBLISHED', 'zid', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '568b4c1a-1e63-5525-ab3f-f326bd2b4f8f', 'type_answer', 'Напишіть хорватською: «у кутку»', 'u kutu', null, 'A0', 8, 'PUBLISHED', 'u kutu', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b408e697-6dc1-553d-8703-18b95ea59e8d', 'type_answer', 'Напишіть хорватською: «підлога»', 'pod', null, 'A0', 9, 'PUBLISHED', 'pod', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ef36752c-a20f-5c2e-8395-b65e04f1c033', 'sentence_builder', 'Складіть: «Ключі на столі.»', 'Ključevi su na stolu.', '["su", "na", "stolu.", "Ključevi"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '03d26ca8-13d5-5e89-b5b7-0bb3e9999cb6', 'sentence_builder', 'Складіть: «Шафа між вікном і дверима.»', 'Ormar je između prozora i vrata.', '["vrata.", "je", "prozora", "između", "Ormar", "i"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7bccff58-2ba9-588f-a7d9-779e1c3e2101', 'listening', 'Прослухайте і складіть фразу', 'Kutije ostavljamo ovdje u kutu?', '["Kutije", "ostavljamo", "ovdje", "kutu?", "u"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '99d568a1-2e4e-5781-81b8-5e4a830f5b75', 'listening', 'Прослухайте і складіть фразу', 'Na prvom katu, lijevo od lifta.', '["lifta.", "lijevo", "Na", "od", "katu,", "prvom"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1e6fb096-c94f-5f9c-9db4-e236c9ce2eb7', 'speaking', 'Де знаходиться ліфт?', 'Gdje se nalazi lift?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8465904a-228d-508f-bacc-d9742b529453', 'speaking', 'Праворуч від дверей.', 'Desno od vrata.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c42067f5-1802-51ac-b9cc-600eeb62c87a', v_lesson, 'Переїзд', 'Selidba', 2401, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('e6565229-b736-57f4-b6e4-de4dbff09647', 'c42067f5-1802-51ac-b9cc-600eeb62c87a', 'Radnik', 'Gospođo, kamo stavljamo ormar?', 'Пані, куди ставимо шафу?', 1);
  perform pg_temp.turn('c70ea7b9-ca5e-57ca-a693-ed52137c517d', 'c42067f5-1802-51ac-b9cc-600eeb62c87a', 'Daša', 'U spavaću sobu, uz zid, između prozora i vrata.', 'У спальню, під стіну, між вікном і дверима.', 2);
  perform pg_temp.turn('5c798d8c-0767-5ec9-a91e-5a3e15bce10b', 'c42067f5-1802-51ac-b9cc-600eeb62c87a', 'Radnik', 'A kauč?', 'А диван?', 3);
  perform pg_temp.turn('fe4e3e72-564a-540e-a1d3-f0fb0bb27a97', 'c42067f5-1802-51ac-b9cc-600eeb62c87a', 'Daša', 'U dnevni boravak, ispod slike.', 'У вітальню, під картину.', 4);
  perform pg_temp.turn('d9eab7f4-f207-5700-bd32-c4f52da077a4', 'c42067f5-1802-51ac-b9cc-600eeb62c87a', 'Radnik', 'Kutije ostavljamo ovdje u kutu?', 'Коробки залишаємо тут, у кутку?', 5);
  perform pg_temp.turn('92f5b930-bf90-5e20-8b98-8a23de2ad88b', 'c42067f5-1802-51ac-b9cc-600eeb62c87a', 'Daša', 'Da, hvala. Knjige idu gore, na policu.', 'Так, дякую. Книжки — нагору, на полицю.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5867b9ef-4b8d-530d-a88b-00edf836bd56', v_lesson, 'У будівлі', 'U zgradi', 2402, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('9db41506-f653-5a48-823f-3dc707c5c1c0', '5867b9ef-4b8d-530d-a88b-00edf836bd56', 'Daša', 'Oprostite, gdje se nalazi ured broj pet?', 'Вибачте, де знаходиться кабінет номер п’ять?', 1);
  perform pg_temp.turn('b8b0dd43-fd22-5aea-881d-9e3a4d97a18d', '5867b9ef-4b8d-530d-a88b-00edf836bd56', 'Portir', 'Na prvom katu, lijevo od lifta.', 'На першому поверсі над партером, ліворуч від ліфта.', 2);
  perform pg_temp.turn('9df87ae4-9cea-51c3-b6c0-1ba62288f109', '5867b9ef-4b8d-530d-a88b-00edf836bd56', 'Daša', 'A gdje je zahod?', 'А де туалет?', 3);
  perform pg_temp.turn('073b7d8a-5379-5de5-b6c5-77818e0f48c8', '5867b9ef-4b8d-530d-a88b-00edf836bd56', 'Portir', 'Dolje, pored ulaza, iza stepenica.', 'Унизу, біля входу, за сходами.', 4);
  perform pg_temp.turn('cda33ae6-0869-5952-b0db-e3e5793bdda2', '5867b9ef-4b8d-530d-a88b-00edf836bd56', 'Daša', 'Hvala! Gdje mogu ostaviti bicikl?', 'Дякую! А де можна залишити велосипед?', 5);
  perform pg_temp.turn('676e817e-23a9-574c-8a4e-af132005bcf6', '5867b9ef-4b8d-530d-a88b-00edf836bd56', 'Portir', 'Vani, ispred zgrade.', 'Надворі, перед будинком.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.6 · урок 43: Велике й маленьке — новий урок: 22 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'f51692d8-cb95-5f2e-8263-f3728f5e10c0';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A0.6: місце 6 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Прикметники: узгодження з іменником' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Прикметники: узгодження з іменником»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 43: Велике й маленьке', 'Lekcija 43: Veliko i malo', '["Описати речі й житло протилежностями: velik — mali, čist — prljav, svijetao — taman", "Узгоджувати прикметник з іменником: velik stan, velika soba, veliko dvorište", "Вибрати річ у магазині: težak — lagan, tvrd — mekan"]'::jsonb, 15, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'velik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mali', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nov', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dug', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kratak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'širok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uzak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'težak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lagan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čist', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prljav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svijetao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'taman', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udoban', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mekan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tvrd', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prazan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tih', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glasan', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '34af4302-290b-5968-bd6c-c3d1da045457', 'fill_in_the_blank', 'Ova soba je jako ___.', 'mala', '["mali", "male", "mala", "malo"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '06aa180f-4284-542d-83c6-4d395abea61c', 'multiple_choice', 'Що означає «brz»?', 'швидкий', '["швидкий", "порожній", "м''який", "малий"]'::jsonb, 'A0', 2, 'PUBLISHED', 'brz', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fe47ac98-df8c-5e65-8cd9-563d3cb4b328', 'multiple_choice', 'Що означає «nov»?', 'новий', '["широкий", "новий", "м''який", "світлий"]'::jsonb, 'A0', 3, 'PUBLISHED', 'nov', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e9d2678b-9169-5e54-8601-98b4c45601df', 'multiple_choice', 'Що означає «lagan»?', 'легкий', '["повний", "тихий", "гучний", "легкий"]'::jsonb, 'A0', 4, 'PUBLISHED', 'lagan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3396dae8-3758-52a6-abf9-1bc61dd9a625', 'multiple_choice', 'Як хорватською «короткий»?', 'kratak', '["kratak", "težak", "lagan", "nov"]'::jsonb, 'A0', 5, 'PUBLISHED', 'kratak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6762dc7e-e38e-5fd5-90aa-d56497ce6136', 'multiple_choice', 'Як хорватською «довгий»?', 'dug', '["čist", "udoban", "tvrd", "dug"]'::jsonb, 'A0', 6, 'PUBLISHED', 'dug', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5470cbc7-db23-51f1-b4c2-fab7e517a85a', 'type_answer', 'Напишіть хорватською: «широкий»', 'širok', null, 'A0', 7, 'PUBLISHED', 'širok', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f1cee295-e08b-515a-96ff-db82da016097', 'type_answer', 'Напишіть хорватською: «зручний»', 'udoban', null, 'A0', 8, 'PUBLISHED', 'udoban', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f5228a8b-ecb1-5ac2-928b-24db64e76398', 'type_answer', 'Напишіть хорватською: «темний»', 'taman', null, 'A0', 9, 'PUBLISHED', 'taman', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '674c075b-0ba3-5f49-ab8a-6a5dbbddc448', 'sentence_builder', 'Складіть: «Квартира велика й світла.»', 'Stan je velik i svijetao.', '["velik", "svijetao.", "i", "je", "Stan"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '83ea9d86-1880-5bea-983c-8b1f9d31308e', 'sentence_builder', 'Складіть: «Ця валіза дуже легка.»', 'Ovaj kofer je jako lagan.', '["lagan.", "je", "jako", "Ovaj", "kofer"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5aca006f-997d-549b-a044-4ff6f5602c02', 'listening', 'Прослухайте і складіть фразу', 'Velik je i svijetao.', '["Velik", "svijetao.", "je", "i"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cb71c387-61e8-5570-b902-4ffbfc0b03f0', 'listening', 'Прослухайте і складіть фразу', 'Je li tvrd ili mekan?', '["mekan?", "Je", "li", "tvrd", "ili"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '90e419bf-2373-5aa3-a7ba-172fb0d7d432', 'speaking', 'Кімната маленька, але чиста.', 'Soba je mala, ali čista.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c719c380-bdf5-55f4-b069-61399baa508f', 'speaking', 'Ця сумка дуже важка.', 'Ova torba je jako teška.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9358c6b6-1f56-544c-b8df-f713c5c7f7fd', v_lesson, 'Стара й нова квартира', 'Stari i novi stan', 2431, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('5e1c0c65-f57f-50c7-a8b6-7f4e9e55b7da', '9358c6b6-1f56-544c-b8df-f713c5c7f7fd', 'Luka', 'Dašo, kakav je tvoj novi stan?', 'Дашо, яка твоя нова квартира?', 1);
  perform pg_temp.turn('171941dd-1731-5b84-adb1-5d06c732f75e', '9358c6b6-1f56-544c-b8df-f713c5c7f7fd', 'Daša', 'Puno je bolji od starog! Velik je i svijetao.', 'Набагато краща за стару! Велика й світла.', 2);
  perform pg_temp.turn('c02076d8-282c-5c8e-9788-86b934f3095d', '9358c6b6-1f56-544c-b8df-f713c5c7f7fd', 'Luka', 'A stari je bio mali i taman, zar ne?', 'А стара була маленька й темна, так?', 3);
  perform pg_temp.turn('c0567620-1bec-542b-9525-789cdb76487a', '9358c6b6-1f56-544c-b8df-f713c5c7f7fd', 'Daša', 'Da, i ulica je bila glasna. Sada je sve tiho.', 'Так, і вулиця була гучна. Тепер усе тихо.', 4);
  perform pg_temp.turn('dea436ea-11e7-5822-8ca4-fc3c1ca81aba', '9358c6b6-1f56-544c-b8df-f713c5c7f7fd', 'Luka', 'A kuhinja?', 'А кухня?', 5);
  perform pg_temp.turn('b2c357ad-9f28-5a40-9050-6810779d6e70', '9358c6b6-1f56-544c-b8df-f713c5c7f7fd', 'Daša', 'Kuhinja je uska, ali je čista i nova.', 'Кухня вузька, але чиста й нова.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('67da9fa3-f85d-573d-911a-a54b3df7bdc3', v_lesson, 'Нова валіза', 'Novi kofer', 2432, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('5e9ee252-f091-50f8-8f8d-20b7c2210bcf', '67da9fa3-f85d-573d-911a-a54b3df7bdc3', 'Daša', 'Oprostite, imate li manji kofer? Ovaj je pretežak.', 'Вибачте, у вас є менша валіза? Ця заважка.', 1);
  perform pg_temp.turn('77d2400d-b885-5aa7-aae7-8e2ee6d7df55', '67da9fa3-f85d-573d-911a-a54b3df7bdc3', 'Prodavačica', 'Ovaj plavi je lagan i jako čvrst.', 'Ця синя легка й дуже міцна.', 2);
  perform pg_temp.turn('4ed795db-f9cf-5a7f-854d-dfe67d5d68a6', '67da9fa3-f85d-573d-911a-a54b3df7bdc3', 'Daša', 'Je li tvrd ili mekan?', 'Вона тверда чи м’яка?', 3);
  perform pg_temp.turn('99b98028-332b-566e-b87d-6f7bc5ca7b91', '67da9fa3-f85d-573d-911a-a54b3df7bdc3', 'Prodavačica', 'Tvrd je, ali je unutra prostran.', 'Тверда, але всередині простора.', 4);
  perform pg_temp.turn('06dc3207-aa4b-5e73-b0ac-62876aef9aa4', '67da9fa3-f85d-573d-911a-a54b3df7bdc3', 'Daša', 'Super, uzet ću ga.', 'Чудово, візьму її.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- 5. Наявні уроки модуля A0.6 — на нові місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 6 and u.order_index = 1;
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
   where l.id in ('78f28f85-dd8b-5e81-8a52-1b2dbce4eb34', '1436c20e-0aea-550a-b66d-fb3149a1c2e2', '32f5d97b-d6c0-57af-9e48-86f9ee9a932d', '0ecb6f19-2630-533d-9f1b-85102442af08', 'e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9', 'f51692d8-cb95-5f2e-8263-f3728f5e10c0')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or not exists (select 1 from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar')
             and exists (select 1 from public.lesson_grammar lg where lg.lesson_id = l.id)
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_module from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 6;
  select count(*) into v_order from (values ('78f28f85-dd8b-5e81-8a52-1b2dbce4eb34'::uuid, 1), ('1436c20e-0aea-550a-b66d-fb3149a1c2e2'::uuid, 2), ('32f5d97b-d6c0-57af-9e48-86f9ee9a932d'::uuid, 3), ('0ecb6f19-2630-533d-9f1b-85102442af08'::uuid, 4), ('e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9'::uuid, 5), ('f51692d8-cb95-5f2e-8263-f3728f5e10c0'::uuid, 6)) as t(id, o) join public.lessons l on l.id = t.id and l.order_index = t.o;
  select count(*) into v_lessons from public.lessons where level_code = 'A0' and status = 'PUBLISHED';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A0' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('78f28f85-dd8b-5e81-8a52-1b2dbce4eb34', '1436c20e-0aea-550a-b66d-fb3149a1c2e2', '32f5d97b-d6c0-57af-9e48-86f9ee9a932d', '0ecb6f19-2630-533d-9f1b-85102442af08', 'e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9', 'f51692d8-cb95-5f2e-8263-f3728f5e10c0') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A0.6: % уроків з неправильним складом', v_bad; end if;
  if v_module <> 6 or v_order <> 6 then raise exception 'Модуль A0.6: уроків %, на своїх місцях % (очікувалось 6)', v_module, v_order; end if;
  if v_lessons < 63 then raise exception 'A0: уроків %, очікувалось щонайменше 63', v_lessons; end if;  -- наступні модулі додають уроки
  if v_titles > 0 then raise exception 'A0: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A0.6: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A0.6 — 6 уроків (38–43) за темою; уроків A0 — %', v_lessons;
end $$;

commit;
