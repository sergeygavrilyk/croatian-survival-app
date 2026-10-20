-- =====================================================================
-- Уроки A0 за темою · curriculum_a0_v4 · модуль A0.7 · 2026-10-19
-- Згенеровано: python3 scripts/gen_curriculum_a0_v4.py (не редагуйте вручну).
--
-- Рішення власника 2026-10-15: слова уроку — за темою уроку, 20–25 слів і виразів, діалоги під тему; бета (PUBLISHED).
--   * Уроки 44–48: 5 наявних перебудовано, 0 нових тематичних уроків. Слів у них: 113.
--     Кожен: 20–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 28.
--   * Виправлено переклад: ljut — «злий, сердитий; гострий (про їжу)» (стара версія — у content_versions).
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
values ('sit', 'sit', 'hr', 'adjective', 'A0', 'ситий', 'core', '{"f": "sita", "n": "sito"}'::jsonb, '["Hvala, ne mogu više, sit sam."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('obrok', 'obrok', 'hr', 'noun', 'A0', 'прийом їжі; порція їжі', 'core', '{"gender": "m"}'::jsonb, '["Doručak je najvažniji obrok u danu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('džem', 'dzem', 'hr', 'noun', 'A0', 'джем, варення', 'core', '{"gender": "m"}'::jsonb, '["Volim kruh s maslacem i džemom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bijela kava', 'bijela kava', 'hr', 'phrase', 'A0', 'кава з молоком', 'collocation', '{"gender": "f"}'::jsonb, '["Jednu bijelu kavu, molim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('torta', 'torta', 'hr', 'noun', 'A0', 'торт', 'core', '{"gender": "f"}'::jsonb, '["Za rođendan smo kupili čokoladnu tortu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kroasan', 'kroasan', 'hr', 'noun', 'A0', 'круасан', 'core', '{"gender": "m"}'::jsonb, '["Uz kavu uvijek uzmem kroasan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kuglica', 'kuglica', 'hr', 'noun', 'A0', 'кулька (морозива)', 'core', '{"gender": "f"}'::jsonb, '["Jedna kuglica sladoleda košta dva eura."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('šlag', 'slag', 'hr', 'noun', 'A0', 'збиті вершки', 'core', '{"gender": "m"}'::jsonb, '["Želite li šlag na kavu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('što želite', 'sto zelite', 'hr', 'phrase', 'A0', 'що бажаєте? (у кафе, магазині)', 'formulaic', '{}'::jsonb, '["Dobar dan, što želite?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('za van', 'za van', 'hr', 'phrase', 'A0', 'з собою, навинос', 'chunk', '{}'::jsonb, '["Jednu kavu za van, molim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('još jedan', 'jos jedan', 'hr', 'phrase', 'A0', 'ще один', 'chunk', '{"f": "još jedna", "n": "još jedno"}'::jsonb, '["Još jedan sok, molim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stol za dvoje', 'stol za dvoje', 'hr', 'phrase', 'A0', 'столик на двох', 'collocation', '{"gender": "m"}'::jsonb, '["Imate li slobodan stol za dvoje?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zajedno ili odvojeno', 'zajedno ili odvojeno', 'hr', 'phrase', 'A0', 'разом чи окремо? (про рахунок)', 'formulaic', '{}'::jsonb, '["Plaćate li zajedno ili odvojeno?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('častiti', 'castiti', 'hr', 'verb', 'A0', 'пригощати; платити за когось', 'core', '{"aspect": "ipf", "present": {"1s": "častim", "2s": "častiš", "3s": "časti"}, "past": "častio"}'::jsonb, '["Danas ja častim!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('izvrstan', 'izvrstan', 'hr', 'adjective', 'A0', 'чудовий, відмінний', 'core', '{"f": "izvrsna", "n": "izvrsno"}'::jsonb, '["Riba je bila izvrsna."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gazirani sok', 'gazirani sok', 'hr', 'phrase', 'A0', 'газований напій', 'collocation', '{"gender": "m"}'::jsonb, '["Djeca vole gazirane sokove."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('crno vino', 'crno vino', 'hr', 'phrase', 'A0', 'червоне вино', 'collocation', '{"gender": "n"}'::jsonb, '["Uz meso pijem crno vino."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bijelo vino', 'bijelo vino', 'hr', 'phrase', 'A0', 'біле вино', 'collocation', '{"gender": "n"}'::jsonb, '["Uz ribu pijemo bijelo vino."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gemišt', 'gemist', 'hr', 'noun', 'A0', 'гемішт (біле вино з газованою мінеральною водою)', 'core', '{"gender": "m"}'::jsonb, '["Ljeti volim popiti hladan gemišt."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bevanda', 'bevanda', 'hr', 'noun', 'A0', 'беванда (вино зі звичайною водою; Далмація)', 'core', '{"gender": "f"}'::jsonb, '["U Dalmaciji uz ručak često piju bevandu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bezalkoholno piće', 'bezalkoholno pice', 'hr', 'phrase', 'A0', 'безалкогольний напій', 'collocation', '{"gender": "n"}'::jsonb, '["Vozim, pa pijem samo bezalkoholna pića."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('slamka', 'slamka', 'hr', 'noun', 'A0', 'соломинка (для напоїв)', 'core', '{"gender": "f"}'::jsonb, '["Djeca piju sok na slamku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('lignje', 'lignje', 'hr', 'noun', 'A0', 'кальмари', 'core', '{"gender": "f", "number": "pl"}'::jsonb, '["Lignje na žaru su specijalitet ove konobe."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('škampi', 'skampi', 'hr', 'noun', 'A0', 'скампі (лангустини), креветки', 'core', '{"gender": "m", "number": "pl"}'::jsonb, '["Škampi su skupi, ali jako ukusni."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('na žaru', 'na zaru', 'hr', 'phrase', 'A0', 'на грилі', 'chunk', '{}'::jsonb, '["Uzet ću ribu na žaru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pržen', 'przen', 'hr', 'adjective', 'A0', 'смажений (на пательні, у фритюрі)', 'core', '{"f": "pržena", "n": "prženo"}'::jsonb, '["Ne jedem prženu hranu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gorak', 'gorak', 'hr', 'adjective', 'A0', 'гіркий', 'core', '{"f": "gorka", "n": "gorko"}'::jsonb, '["Kava bez šećera je gorka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pikantan', 'pikantan', 'hr', 'adjective', 'A0', 'гострий, пікантний (про їжу)', 'core', '{"f": "pikantna", "n": "pikantno"}'::jsonb, '["Ova kobasica je jako pikantna."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;

-- 1б. Виправлені переклади наявних слів (1); повторний запуск нічого не змінює
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'ljut' and ukrainian_translation = 'злий / сердитий' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a0_v4: виправлено переклад слова (додано значення за темою уроку) — стара версія');
    update public.lexemes set ukrainian_translation = 'злий, сердитий; гострий (про їжу)' where id = r.id;
  end loop;
end $$;

-- 2. Перебудова наявних уроків модуля A0.7
-- A0.7 · урок 44: Я голодний — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '7bbaf7ff-10bb-512a-91c5-798b59ec92a5';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Я голодний» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'ae1db7ac-208f-5f01-86fe-d085ecff39ef') then return; end if;  -- уже перебудовано
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
  if v_gid is null then select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Дієслово «imati» (мати)' and status = 'PUBLISHED' order by created_at limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 44: Я голодний', title_hr = 'Lekcija 44: Gladan sam',
         objectives = '["Сказати, що ви голодні, хочете пити чи вже наїлися", "Назвати прийоми їжі: doručak, ručak, večera, užina", "Розповісти, що ви їсте на сніданок"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'gladan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žedan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hrana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obrok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jesti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'doručak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ručak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'večera', v_pos);
  v_pos := pg_temp.word(v_lesson, 'užina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'doručkovati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ručati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'večerati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kruh', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pecivo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maslac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'džem', v_pos);
  v_pos := pg_temp.word(v_lesson, 'med', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jaje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jogurt', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sendvič', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b369f603-8bad-5fd3-814d-4edb644b6714', 'fill_in_the_blank', 'Ja ___ kruh, maslac i džem.', 'imam', '["ima", "imaš", "imam", "imamo"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '922d217d-b26b-5c4b-be6e-9c9f0e4fe0e7', 'multiple_choice', 'Що означає «ručati»?', 'обідати', '["перекус", "сендвіч", "обідати", "їсти"]'::jsonb, 'A0', 2, 'PUBLISHED', 'ručati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a99e4792-67cc-5662-9492-6fb7b317bb6f', 'multiple_choice', 'Що означає «žedan»?', 'спраглий', '["прийом їжі; порція їжі", "спраглий", "вечеряти", "їжа"]'::jsonb, 'A0', 3, 'PUBLISHED', 'žedan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '12d04ac1-a199-5d3e-8f51-68f2f9e636a1', 'multiple_choice', 'Що означає «hrana»?', 'їжа', '["їсти", "снідати", "їжа", "вершкове масло"]'::jsonb, 'A0', 4, 'PUBLISHED', 'hrana', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd3170983-1bf0-5e3e-89aa-e4b31ff3e6e3', 'multiple_choice', 'Як хорватською «їсти»?', 'jesti', '["jogurt", "ručati", "hrana", "jesti"]'::jsonb, 'A0', 5, 'PUBLISHED', 'jesti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b91bd38-c3c1-5cda-9b19-a41fd7eabd89', 'multiple_choice', 'Як хорватською «снідати»?', 'doručkovati', '["gladan", "ručak", "pecivo", "doručkovati"]'::jsonb, 'A0', 6, 'PUBLISHED', 'doručkovati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '45a9be3e-db33-5544-b99d-9f135334f273', 'type_answer', 'Напишіть хорватською: «голодний»', 'gladan', null, 'A0', 7, 'PUBLISHED', 'gladan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '089be1e2-89b6-5a6d-81d9-89313471d36b', 'type_answer', 'Напишіть хорватською: «сендвіч»', 'sendvič', null, 'A0', 8, 'PUBLISHED', 'sendvič', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd85de176-2985-5320-93b2-a74971a35d0a', 'type_answer', 'Напишіть хорватською: «вечеря»', 'večera', null, 'A0', 9, 'PUBLISHED', 'večera', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '821a31e1-3e21-519a-90d3-15ae847a0620', 'sentence_builder', 'Складіть: «Що є на сніданок?»', 'Što ima za doručak?', '["ima", "Što", "doručak?", "za"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '86b7f16f-630b-5692-b5d2-b8658f5080e8', 'sentence_builder', 'Складіть: «Я їм тричі на день.»', 'Jedem tri puta dnevno.', '["Jedem", "puta", "tri", "dnevno."]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b4fcd657-9609-5475-9ce8-f2486b67812d', 'listening', 'Прослухайте і складіть фразу', 'Imam kruh, maslac, med i džem.', '["džem.", "maslac,", "med", "i", "kruh,", "Imam"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b4d2cf5-9c29-51a0-b953-e671ecc70857', 'listening', 'Прослухайте і складіть фразу', 'Ali poslije ručka bit ću sita!', '["sita!", "ručka", "poslije", "bit", "Ali", "ću"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '016a4252-bae6-5a80-b3b7-bd2f77b8eef2', 'speaking', 'Я голодний.', 'Gladan sam.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dac88362-7fcc-5960-91ce-e46cb8d75640', 'speaking', 'Що на вечерю?', 'Što je za večeru?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ae1db7ac-208f-5f01-86fe-d085ecff39ef', v_lesson, 'Що на сніданок?', 'Što ima za doručak?', 2441, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('429c122e-3812-5c5e-8d4d-f57852bc71d3', 'ae1db7ac-208f-5f01-86fe-d085ecff39ef', 'Daša', 'Ivana, gladna sam. Imaš li nešto za doručak?', 'Івано, я голодна. У тебе є щось на сніданок?', 1);
  perform pg_temp.turn('bb6e92e0-a910-59b1-9957-b3913aebb555', 'ae1db7ac-208f-5f01-86fe-d085ecff39ef', 'Ivana', 'Imam kruh, maslac, med i džem. U hladnjaku su jaja i jogurt.', 'Є хліб, масло, мед і джем. У холодильнику — яйця й йогурт.', 2);
  perform pg_temp.turn('517918e6-cc50-5b0d-98d2-f35936f93996', 'ae1db7ac-208f-5f01-86fe-d085ecff39ef', 'Daša', 'Super! Ja ću kruh s maslacem i medom.', 'Супер! Я буду хліб з маслом і медом.', 3);
  perform pg_temp.turn('01000120-43fb-5812-94ad-791841443007', 'ae1db7ac-208f-5f01-86fe-d085ecff39ef', 'Ivana', 'Hoćeš li i jaje?', 'А яйце хочеш?', 4);
  perform pg_temp.turn('c82bb537-2abb-5f1d-ab12-80234e8da7d4', 'ae1db7ac-208f-5f01-86fe-d085ecff39ef', 'Daša', 'Ne, hvala, to mi je dosta. Ali žedna sam.', 'Ні, дякую, мені цього досить. Але я хочу пити.', 5);
  perform pg_temp.turn('1ab98857-7d9b-570c-b76c-66f0f455334a', 'ae1db7ac-208f-5f01-86fe-d085ecff39ef', 'Ivana', 'Evo ti čaša vode.', 'Ось тобі склянка води.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2b46afcb-381a-51a7-9d33-64bc59185a38', v_lesson, 'Обідня перерва', 'Pauza za ručak', 2442, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('952a7f26-5172-5bf1-a6d6-ce3de4d3aa44', '2b46afcb-381a-51a7-9d33-64bc59185a38', 'Marko', 'Dašo, ideš li na ručak?', 'Дашо, ти йдеш на обід?', 1);
  perform pg_temp.turn('d2fe236a-1176-5cc9-95e4-676f08afb0f4', '2b46afcb-381a-51a7-9d33-64bc59185a38', 'Daša', 'Nisam gladna. U deset sam pojela sendvič.', 'Я не голодна. О десятій я з’їла сендвіч.', 2);
  perform pg_temp.turn('ba0bd2c0-d1e6-5a1d-a661-b904ede1d342', '2b46afcb-381a-51a7-9d33-64bc59185a38', 'Marko', 'To je bila samo užina! Kada onda ručaš?', 'Це був лише перекус! А коли ж ти обідаєш?', 3);
  perform pg_temp.turn('08fba59f-437f-5739-991d-8e1a3582ca76', '2b46afcb-381a-51a7-9d33-64bc59185a38', 'Daša', 'Obično ne ručam. Navečer večeram s obitelji.', 'Зазвичай я не обідаю. Увечері вечеряю з сім’єю.', 4);
  perform pg_temp.turn('f663f204-fdab-54c6-8909-25dc77fe220e', '2b46afcb-381a-51a7-9d33-64bc59185a38', 'Marko', 'Tri obroka dnevno su važna. Hajde sa mnom!', 'Їсти тричі на день — важливо. Ходімо зі мною!', 5);
  perform pg_temp.turn('64dbbf76-517c-5fb5-820a-fea220090d19', '2b46afcb-381a-51a7-9d33-64bc59185a38', 'Daša', 'Dobro, idem. Ali poslije ručka bit ću sita!', 'Гаразд, іду. Але після обіду я буду сита!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.7 · урок 45: У кафе — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'c9e045fb-91ff-52a2-9916-1b698d30eb19';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «У кафе» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'dd6ec998-34e9-560d-aa4a-99493e762ca2') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 45: У кафе', title_hr = 'Lekcija 45: U kafiću',
         objectives = '["Замовити каву, чай чи сік у кафе", "Сказати, як ви п’єте каву: s mlijekom, bez šećera", "Купити тістечко чи морозиво з собою (za van)"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kafić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slastičarnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bijela kava', v_pos);
  v_pos := pg_temp.word(v_lesson, 's mlijekom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mlijeko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šećer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bez šećera', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kakao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'torta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kroasan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sladoled', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kuglica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šlag', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šalica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naručiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'što želite', v_pos);
  v_pos := pg_temp.word(v_lesson, 'za van', v_pos);
  v_pos := pg_temp.word(v_lesson, 'još jedan', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f47138cf-20bf-55b2-b75f-642b105c34cf', 'fill_in_the_blank', 'Kavu s ___, molim.', 'mlijekom', '["mlijeko", "mlijekom", "mlijeku", "mlijeka"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fbc115d2-196e-598a-a3fe-365d38a93b02', 'multiple_choice', 'Що означає «kuglica»?', 'кулька (морозива)', '["сік", "збиті вершки", "кулька (морозива)", "кафе / кав''ярня"]'::jsonb, 'A0', 2, 'PUBLISHED', 'kuglica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f1f278c2-9d2d-58c7-95a5-e4719aace8ae', 'multiple_choice', 'Що означає «kroasan»?', 'круасан', '["з молоком", "круасан", "сік", "ще один"]'::jsonb, 'A0', 3, 'PUBLISHED', 'kroasan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b182ba88-3c4f-58d8-a2e7-3f4641e9280d', 'multiple_choice', 'Що означає «što želite»?', 'що бажаєте? (у кафе, магазині)', '["кава", "з молоком", "чай", "що бажаєте? (у кафе, магазині)"]'::jsonb, 'A0', 4, 'PUBLISHED', 'što želite', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b44aee91-b384-57d8-a696-340432140bc7', 'multiple_choice', 'Як хорватською «кондитерська»?', 'slastičarnica', '["torta", "kava", "šećer", "slastičarnica"]'::jsonb, 'A0', 5, 'PUBLISHED', 'slastičarnica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '27228df6-4c48-5a0b-abfc-cc47e3a6dd6a', 'multiple_choice', 'Як хорватською «молоко»?', 'mlijeko', '["mlijeko", "kakao", "s mlijekom", "kroasan"]'::jsonb, 'A0', 6, 'PUBLISHED', 'mlijeko', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a874725e-b002-5110-800c-738d1678fe38', 'type_answer', 'Напишіть хорватською: «торт»', 'torta', null, 'A0', 7, 'PUBLISHED', 'torta', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c6cfc598-e910-5792-b7ce-c6d41380be04', 'type_answer', 'Напишіть хорватською: «сік»', 'sok', null, 'A0', 8, 'PUBLISHED', 'sok', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be748985-517c-590a-828d-d7abdd1a4d35', 'type_answer', 'Напишіть хорватською: «з собою, навинос»', 'za van', null, 'A0', 9, 'PUBLISHED', 'za van', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c53cef0c-7cce-51ea-b14f-b500953be636', 'sentence_builder', 'Складіть: «Мені каву з молоком.»', 'Za mene kavu s mlijekom.', '["s", "mlijekom.", "Za", "kavu", "mene"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '85b55cc9-9db4-5b7f-b03f-8c850ad298e0', 'sentence_builder', 'Складіть: «Чай без цукру, будь ласка.»', 'Čaj bez šećera, molim.', '["bez", "molim.", "Čaj", "šećera,"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd3c5dcf1-f99a-54c7-b22f-a323687149e8', 'listening', 'Прослухайте і складіть фразу', 'Za mene bijelu kavu i kroasan, molim.', '["bijelu", "kroasan,", "molim.", "Za", "i", "mene", "kavu"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '02b9c0a6-38e5-547b-8574-6fe780b5f1b2', 'listening', 'Прослухайте і складіть фразу', 'Sladoled ovdje, a tortu za van.', '["Sladoled", "van.", "za", "ovdje,", "tortu", "a"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6ee797a8-684c-54a2-832a-cc3b8732127b', 'speaking', 'Що бажаєте?', 'Što želite?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a8fa8cf-a263-519d-a637-ec6f9923a1be', 'speaking', 'Каву з собою, будь ласка.', 'Kavu za van, molim.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('dd6ec998-34e9-560d-aa4a-99493e762ca2', v_lesson, 'Кава на терасі', 'Kava na terasi', 2451, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('ab27e215-6b20-5a5f-aa45-d194da409c6c', 'dd6ec998-34e9-560d-aa4a-99493e762ca2', 'Konobarica', 'Dobar dan! Što želite?', 'Добрий день! Що бажаєте?', 1);
  perform pg_temp.turn('544b57f6-ca34-52b0-b90e-6ab285010c48', 'dd6ec998-34e9-560d-aa4a-99493e762ca2', 'Daša', 'Za mene bijelu kavu i kroasan, molim.', 'Мені каву з молоком і круасан, будь ласка.', 2);
  perform pg_temp.turn('2bf77f34-574c-54e0-a0ae-043f416a2317', 'dd6ec998-34e9-560d-aa4a-99493e762ca2', 'Darja', 'A ja ću čaj s limunom, bez šećera.', 'А я буду чай з лимоном, без цукру.', 3);
  perform pg_temp.turn('447b09f2-b63c-526b-aabc-aee4a5ae65bc', 'dd6ec998-34e9-560d-aa4a-99493e762ca2', 'Konobarica', 'Izvolite: kava, čaj i kroasan.', 'Прошу: кава, чай і круасан.', 4);
  perform pg_temp.turn('0c577cef-87e0-5f5c-bbb7-8ddc792be00b', 'dd6ec998-34e9-560d-aa4a-99493e762ca2', 'Daša', 'Kroasan je odličan! Još jedan, molim vas.', 'Круасан чудовий! Ще один, будь ласка.', 5);
  perform pg_temp.turn('d29896a9-ac53-5307-bf32-7c3a8fc8ae84', 'dd6ec998-34e9-560d-aa4a-99493e762ca2', 'Konobarica', 'Odmah stiže.', 'Зараз принесу.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4f5eeb9e-d392-5f3a-a881-669f251ef987', v_lesson, 'У кондитерській', 'U slastičarnici', 2452, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('dc540549-e26c-5cca-af24-ec90fcd0555c', '4f5eeb9e-d392-5f3a-a881-669f251ef987', 'Prodavačica', 'Izvolite, što ćete?', 'Прошу, що будете?', 1);
  perform pg_temp.turn('60d0a981-99b8-5ad5-aa0d-1c2b08da863f', '4f5eeb9e-d392-5f3a-a881-669f251ef987', 'Daša', 'Dvije kuglice sladoleda, molim: čokoladu i vaniliju.', 'Дві кульки морозива, будь ласка: шоколадне й ванільне.', 2);
  perform pg_temp.turn('ea0bdfaf-6e7d-54de-9ebd-edd84b0d58d4', '4f5eeb9e-d392-5f3a-a881-669f251ef987', 'Prodavačica', 'Hoćete li šlag?', 'Хочете збиті вершки?', 3);
  perform pg_temp.turn('b519c8bd-216c-5ab3-91f5-ee700fbd0493', '4f5eeb9e-d392-5f3a-a881-669f251ef987', 'Daša', 'Može. I jedan komad torte, molim.', 'Можна. І шматок торта, будь ласка.', 4);
  perform pg_temp.turn('5fb76552-2891-5204-b1ba-b61a5ddd40a1', '4f5eeb9e-d392-5f3a-a881-669f251ef987', 'Prodavačica', 'Za van ili ćete jesti ovdje?', 'З собою чи будете їсти тут?', 5);
  perform pg_temp.turn('f2210431-5578-5914-a923-d5b293b9b1dc', '4f5eeb9e-d392-5f3a-a881-669f251ef987', 'Daša', 'Sladoled ovdje, a tortu za van.', 'Морозиво тут, а торт з собою.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.7 · урок 46: У ресторані — перебудова: 23 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '8b30911e-4e57-5648-9ff6-bd11c1b0e27e';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «У ресторані» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '9565c3f9-eec8-540d-bb1f-b66e917d5f6f') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 46: У ресторані', title_hr = 'Lekcija 46: U restoranu',
         objectives = '["Попросити столик і замовити страву", "Розібратися в меню: predjelo, glavno jelo, prilog, desert", "Попросити рахунок, залишити чайові й сказати «я пригощаю»"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'restoran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'konoba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rezervirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stol za dvoje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jelovnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preporučiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predjelo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glavno jelo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prilog', v_pos);
  v_pos := pg_temp.word(v_lesson, 'desert', v_pos);
  v_pos := pg_temp.word(v_lesson, 'juha', v_pos);
  v_pos := pg_temp.word(v_lesson, 'salata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jelo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'porcija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tanjur', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vilica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nož', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žlica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'molim račun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zajedno ili odvojeno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'napojnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'častiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izvrstan', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '23b1f267-43db-5dc8-856c-cd9f9489fd00', 'fill_in_the_blank', 'Za ___ jelo uzimam ribu.', 'glavno', '["glavni", "glavno", "glavnu", "glavna"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c82a476c-2801-5981-b5a2-aac8594d3967', 'multiple_choice', 'Що означає «tanjur»?', 'тарілка', '["чудовий, відмінний", "тарілка", "меню", "головна страва"]'::jsonb, 'A0', 2, 'PUBLISHED', 'tanjur', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '37ee4fd4-d2eb-556a-9aa7-1aba5eb1dac3', 'multiple_choice', 'Що означає «preporučiti»?', 'рекомендувати', '["страва", "тарілка", "рекомендувати", "столик на двох"]'::jsonb, 'A0', 3, 'PUBLISHED', 'preporučiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1fa197ed-aa22-5c19-8306-0914b7ff1434', 'multiple_choice', 'Що означає «prilog»?', 'гарнір', '["пригощати; платити за когось", "ложка", "гарнір", "закуска"]'::jsonb, 'A0', 4, 'PUBLISHED', 'prilog', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '824bb36b-ea85-58a8-9e5c-cb85d50ee7c6', 'multiple_choice', 'Як хорватською «чайові»?', 'napojnica', '["konoba", "glavno jelo", "napojnica", "žlica"]'::jsonb, 'A0', 5, 'PUBLISHED', 'napojnica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f8b8957a-4c8a-5279-87fe-ac9c4d34574c', 'multiple_choice', 'Як хорватською «ложка»?', 'žlica', '["konoba", "žlica", "molim račun", "rezervirati"]'::jsonb, 'A0', 6, 'PUBLISHED', 'žlica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5a706ff4-6032-56d2-8cd9-2dfe3d7a9c15', 'type_answer', 'Напишіть хорватською: «виделка»', 'vilica', null, 'A0', 7, 'PUBLISHED', 'vilica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4f77222a-9ce8-52fa-86b3-f1424df9cf81', 'type_answer', 'Напишіть хорватською: «закуска»', 'predjelo', null, 'A0', 8, 'PUBLISHED', 'predjelo', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '79298703-c86e-5514-b73d-79ba3fd4968a', 'type_answer', 'Напишіть хорватською: «ресторан»', 'restoran', null, 'A0', 9, 'PUBLISHED', 'restoran', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ccba3d91-207c-5b52-bf73-bdbc58401523', 'sentence_builder', 'Складіть: «У вас є столик на двох?»', 'Imate li stol za dvoje?', '["stol", "Imate", "za", "dvoje?", "li"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b74c5742-b92c-55ce-8501-7ef218f45271', 'sentence_builder', 'Складіть: «Сьогодні я пригощаю.»', 'Danas ja častim.', '["ja", "častim.", "Danas"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c79e8eff-9b8e-5384-9359-a0141acd5b21', 'listening', 'Прослухайте і складіть фразу', 'Nema problema, sjednite ovdje.', '["problema,", "sjednite", "ovdje.", "Nema"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '059d8e7e-f600-54f4-8beb-3f07cd6062a0', 'listening', 'Прослухайте і складіть фразу', 'Plaćate li zajedno ili odvojeno?', '["ili", "zajedno", "odvojeno?", "li", "Plaćate"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '73f3a6e6-c84c-5c14-900f-57b34931d6fb', 'speaking', 'Рахунок, будь ласка.', 'Molim račun.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0922b252-8513-5840-939d-0ef8e9249632', 'speaking', 'Що ви нам порадите?', 'Što nam preporučujete?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9565c3f9-eec8-540d-bb1f-b66e917d5f6f', v_lesson, 'Столик на двох', 'Stol za dvoje', 2461, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('c2ab8d47-cdac-5851-afe5-efe184d3a82d', '9565c3f9-eec8-540d-bb1f-b66e917d5f6f', 'Daša', 'Dobra večer! Imate li slobodan stol za dvoje?', 'Добрий вечір! У вас є вільний столик на двох?', 1);
  perform pg_temp.turn('570243af-b48b-5d6e-a119-63aa47899a95', '9565c3f9-eec8-540d-bb1f-b66e917d5f6f', 'Konobar', 'Imate li rezervaciju?', 'Ви бронювали?', 2);
  perform pg_temp.turn('5107d7ca-512e-5765-86a4-64c0be696d45', '9565c3f9-eec8-540d-bb1f-b66e917d5f6f', 'Daša', 'Nemamo, nažalost.', 'На жаль, ні.', 3);
  perform pg_temp.turn('8afe6e71-7c14-5066-9172-7853585af907', '9565c3f9-eec8-540d-bb1f-b66e917d5f6f', 'Konobar', 'Nema problema, sjednite ovdje. Izvolite jelovnik.', 'Нічого страшного, сідайте тут. Ось меню.', 4);
  perform pg_temp.turn('879cb9bc-4445-5eed-ae3a-e41944e8fc50', '9565c3f9-eec8-540d-bb1f-b66e917d5f6f', 'Darja', 'Što nam preporučujete?', 'Що ви нам порадите?', 5);
  perform pg_temp.turn('392f5bf5-568a-5016-be06-1d205635442f', '9565c3f9-eec8-540d-bb1f-b66e917d5f6f', 'Konobar', 'Za predjelo juhu, a za glavno jelo svježu ribu s krumpirom.', 'На закуску — суп, а на основну страву — свіжу рибу з картоплею.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('fee5247b-fe64-5eea-a310-0a825ba78bcd', v_lesson, 'Рахунок', 'Račun', 2462, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('88ccf7c3-2f5f-52b3-9478-399a22528da9', 'fee5247b-fe64-5eea-a310-0a825ba78bcd', 'Daša', 'Oprostite, molim račun!', 'Перепрошую, рахунок, будь ласка!', 1);
  perform pg_temp.turn('7a8a1935-1908-50ef-be71-ae01a241d74c', 'fee5247b-fe64-5eea-a310-0a825ba78bcd', 'Konobar', 'Plaćate li zajedno ili odvojeno?', 'Платите разом чи окремо?', 2);
  perform pg_temp.turn('34b03861-57e9-59ea-8cb8-096f02053ccd', 'fee5247b-fe64-5eea-a310-0a825ba78bcd', 'Darja', 'Zajedno. Danas ja častim!', 'Разом. Сьогодні я пригощаю!', 3);
  perform pg_temp.turn('0fccf6c6-5c39-5eaa-925e-11a24a8ca483', 'fee5247b-fe64-5eea-a310-0a825ba78bcd', 'Konobar', 'Ukupno šezdeset eura. Je li sve bilo u redu?', 'Разом шістдесят євро. Усе було добре?', 4);
  perform pg_temp.turn('9812812f-b736-5bf4-9871-1616435d9c75', 'fee5247b-fe64-5eea-a310-0a825ba78bcd', 'Darja', 'Sve je bilo izvrsno, hvala. Ostatak je za vas.', 'Усе було чудово, дякую. Решта — вам.', 5);
  perform pg_temp.turn('35a0692a-26e7-5249-b01f-1566e074669c', 'fee5247b-fe64-5eea-a310-0a825ba78bcd', 'Konobar', 'Hvala lijepa na napojnici! Laku noć.', 'Щиро дякую за чайові! На добраніч.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.7 · урок 47: Напої — перебудова: 23 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '77d640c4-4190-544a-8094-4e699f9a0a10';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Напої» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '08bef677-9684-5327-9527-d1e41a5ee0e4') then return; end if;  -- уже перебудовано
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
  if v_gid is null then select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Питальні слова' and status = 'PUBLISHED' order by created_at limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 47: Напої', title_hr = 'Lekcija 47: Pića',
         objectives = '["Замовити воду, сік, пиво чи вино", "Розрізнити crno vino і bijelo vino, gemišt і bevanda", "Запитати про безалкогольні напої й виголосити тост"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'piće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'piti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'voda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mineralna voda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'voda bez plina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gazirani sok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'limunada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pivo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'točeno pivo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vino', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crno vino', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bijelo vino', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gemišt', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bevanda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rakija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'alkohol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bezalkoholno piće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čaša', v_pos);
  v_pos := pg_temp.word(v_lesson, 'boca', v_pos);
  v_pos := pg_temp.word(v_lesson, 'led', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slamka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hladan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'živjeli', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bc2b4580-fc9c-5315-992c-a27ac49286df', 'fill_in_the_blank', '___ ćete piti? — Pivo, molim.', 'Što', '["Što", "Gdje", "Kada", "Tko"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2e8773cb-ff65-5c74-b293-a40bb7a4656f', 'multiple_choice', 'Що означає «bezalkoholno piće»?', 'безалкогольний напій', '["вода без газу", "соломинка (для напоїв)", "вино", "безалкогольний напій"]'::jsonb, 'A0', 2, 'PUBLISHED', 'bezalkoholno piće', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '85af3c4b-be0b-5a0b-a23b-985e4e4716fb', 'multiple_choice', 'Що означає «piti»?', 'пити', '["гемішт (біле вино з газованою мінеральною водою)", "алкоголь", "пити", "мінеральна вода"]'::jsonb, 'A0', 3, 'PUBLISHED', 'piti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '51d6d42c-6f1f-5fe2-b801-fc24dfc5d82d', 'multiple_choice', 'Що означає «crno vino»?', 'червоне вино', '["холодний", "червоне вино", "пиво", "напій"]'::jsonb, 'A0', 4, 'PUBLISHED', 'crno vino', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2e04defb-1795-5824-81e3-dbc10b697a23', 'multiple_choice', 'Як хорватською «склянка / келих»?', 'čaša', '["boca", "voda", "bezalkoholno piće", "čaša"]'::jsonb, 'A0', 5, 'PUBLISHED', 'čaša', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '03a8188b-68a6-5d57-bf4f-cdd1205b2b97', 'multiple_choice', 'Як хорватською «лимонад»?', 'limunada', '["čaša", "boca", "gazirani sok", "limunada"]'::jsonb, 'A0', 6, 'PUBLISHED', 'limunada', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a3de879e-de3b-5331-a779-ace511b3ce7c', 'type_answer', 'Напишіть хорватською: «алкоголь»', 'alkohol', null, 'A0', 7, 'PUBLISHED', 'alkohol', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '57464cf6-70a7-545c-8b6a-7849961bc6d0', 'type_answer', 'Напишіть хорватською: «пляшка»', 'boca', null, 'A0', 8, 'PUBLISHED', 'boca', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2bd57fbc-c22f-5830-b5f5-8d2ebf43527c', 'type_answer', 'Напишіть хорватською: «лід»', 'led', null, 'A0', 9, 'PUBLISHED', 'led', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aa34d503-b297-5b92-adc1-d19536159f6c', 'sentence_builder', 'Складіть: «Я не п’ю алкоголю.»', 'Ne pijem alkohol.', '["Ne", "alkohol.", "pijem"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf72070b-8475-5396-816d-a5e498f536da', 'sentence_builder', 'Складіть: «Пляшку мінеральної води, будь ласка.»', 'Bocu mineralne vode, molim.', '["Bocu", "vode,", "mineralne", "molim."]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3fa13ca6-4b4c-5ae6-a672-64ea1dd5fc78', 'listening', 'Прослухайте і складіть фразу', 'Ja ne pijem alkohol.', '["alkohol.", "Ja", "ne", "pijem"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b03c20ce-8523-5dc4-81ad-8933f71e4d45', 'listening', 'Прослухайте і складіть фразу', 'Crno vino s običnom vodom je bevanda.', '["vodom", "bevanda.", "s", "Crno", "je", "običnom", "vino"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6f98eaf2-ae5b-5fd8-871e-9b753689842c', 'speaking', 'Склянку води, будь ласка.', 'Čašu vode, molim.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '89e49096-b139-55fb-94f8-83e057343a56', 'speaking', 'Будьмо!', 'Živjeli!', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('08bef677-9684-5327-9527-d1e41a5ee0e4', v_lesson, 'Що будете пити?', 'Što ćete piti?', 2471, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('31cb12f8-ac38-5e9c-9393-fef3030eb85d', '08bef677-9684-5327-9527-d1e41a5ee0e4', 'Konobar', 'Dobra večer, što ćete piti?', 'Добрий вечір, що будете пити?', 1);
  perform pg_temp.turn('83488998-78b4-5f2f-b24e-a1ee675ee30f', '08bef677-9684-5327-9527-d1e41a5ee0e4', 'Luka', 'Za mene veliko točeno pivo.', 'Мені велике розливне пиво.', 2);
  perform pg_temp.turn('1ca2d969-c885-5ef0-9ce7-e9523ff17043', '08bef677-9684-5327-9527-d1e41a5ee0e4', 'Daša', 'Ja ne pijem alkohol. Što imate bezalkoholno?', 'Я не п’ю алкоголю. Що у вас є безалкогольне?', 3);
  perform pg_temp.turn('e695edab-c015-56d0-8580-ddf0d2f18707', '08bef677-9684-5327-9527-d1e41a5ee0e4', 'Konobar', 'Imamo sokove, limunadu i mineralnu vodu.', 'Маємо соки, лимонад і мінеральну воду.', 4);
  perform pg_temp.turn('0a0a76b9-83b4-58a9-9371-aa15ab4f250c', '08bef677-9684-5327-9527-d1e41a5ee0e4', 'Daša', 'Onda limunadu, s puno leda.', 'Тоді лимонад, і побільше льоду.', 5);
  perform pg_temp.turn('a66d1815-f86a-5155-b593-91230fbb62ed', '08bef677-9684-5327-9527-d1e41a5ee0e4', 'Konobar', 'Želite li i slamku?', 'Вам ще й соломинку?', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6e9733cc-d1a8-5d32-8ea2-7b6f583f1401', v_lesson, 'Вино до вечері', 'Vino uz večeru', 2472, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('96fccef9-9fc3-5714-8ded-f72b9bd983f7', '6e9733cc-d1a8-5d32-8ea2-7b6f583f1401', 'Ivana', 'Dašo, piješ li crno ili bijelo vino?', 'Дашо, ти п’єш червоне чи біле вино?', 1);
  perform pg_temp.turn('7f0067c3-8581-5ba2-bfc6-59beb0fcdb81', '6e9733cc-d1a8-5d32-8ea2-7b6f583f1401', 'Daša', 'Bijelo, ali s mineralnom vodom. Kako se to zove?', 'Біле, але з мінеральною водою. Як це називається?', 2);
  perform pg_temp.turn('276764cf-24a9-5f75-980a-75678c587883', '6e9733cc-d1a8-5d32-8ea2-7b6f583f1401', 'Ivana', 'To je gemišt. Crno vino s običnom vodom je bevanda.', 'Це гемішт. А червоне вино зі звичайною водою — беванда.', 3);
  perform pg_temp.turn('8f50a1dc-2183-584a-98d8-1e1e5e2b4389', '6e9733cc-d1a8-5d32-8ea2-7b6f583f1401', 'Daša', 'Zanimljivo! Onda jedan gemišt, molim.', 'Цікаво! Тоді один гемішт, будь ласка.', 4);
  perform pg_temp.turn('cdc17694-09a0-5d45-b5ab-c0d3a05c0840', '6e9733cc-d1a8-5d32-8ea2-7b6f583f1401', 'Ivana', 'Evo. Živjeli!', 'Ось. Будьмо!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.7 · урок 48: Що на вечерю? — перебудова: 23 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Що на вечерю?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '48d653b4-c3bd-50c3-9201-8e98133e2004') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 48: Що на вечерю?', title_hr = 'Lekcija 48: Što je za večeru?',
         objectives = '["Назвати м’ясо, рибу й морепродукти: piletina, govedina, lignje, škampi", "Сказати, як приготовано: na žaru, pečen, pržen, kuhan", "Описати смак: slan, sladak, kiseo, gorak, ljut / pikantan (гострий)"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'meso', v_pos);
  v_pos := pg_temp.word(v_lesson, 'piletina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svinjetina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'govedina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'riba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lignje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'škampi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tjestenina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'riža', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pomfrit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'umak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na žaru', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pečen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pržen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kuhan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'okus', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ukusan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sladak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kiseo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gorak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pikantan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vegetarijanac', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e3d0997c-5227-5ceb-b195-117c16a3c1cd', 'fill_in_the_blank', 'Piletina je jako ___.', 'ukusna', '["ukusno", "ukusna", "ukusan", "ukusni"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '78c8eb95-8a6f-5bd8-90bd-9f53aa5586c4', 'multiple_choice', 'Що означає «svinjetina»?', 'свинина', '["на грилі", "свинина", "гострий, пікантний (про їжу)", "кальмари"]'::jsonb, 'A0', 2, 'PUBLISHED', 'svinjetina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a1fe145f-d3a3-5336-b150-529401a7cb75', 'multiple_choice', 'Що означає «pikantan»?', 'гострий, пікантний (про їжу)', '["на грилі", "кислий", "гострий, пікантний (про їжу)", "макарони; паста"]'::jsonb, 'A0', 3, 'PUBLISHED', 'pikantan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a7bafe6c-109f-59dd-972f-e704413cfead', 'multiple_choice', 'Що означає «slan»?', 'солоний', '["солоний", "вегетаріанець", "варений", "гострий, пікантний (про їжу)"]'::jsonb, 'A0', 4, 'PUBLISHED', 'slan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '764e5425-c63a-5b62-a502-64d877ed187e', 'multiple_choice', 'Як хорватською «яловичина»?', 'govedina', '["riža", "govedina", "lignje", "riba"]'::jsonb, 'A0', 5, 'PUBLISHED', 'govedina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b4cccaf9-35d0-5f88-96ff-01c0772dc74e', 'multiple_choice', 'Як хорватською «варений»?', 'kuhan', '["piletina", "kuhan", "pečen", "na žaru"]'::jsonb, 'A0', 6, 'PUBLISHED', 'kuhan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '310d8b02-4e58-5f32-8683-1bad30ea66b6', 'type_answer', 'Напишіть хорватською: «рис»', 'riža', null, 'A0', 7, 'PUBLISHED', 'riža', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ab71b9d6-1421-5861-b79e-e729e709c2a8', 'type_answer', 'Напишіть хорватською: «курятина»', 'piletina', null, 'A0', 8, 'PUBLISHED', 'piletina', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c91aed4a-906a-5584-95dd-60c864213b91', 'type_answer', 'Напишіть хорватською: «смачний»', 'ukusan', null, 'A0', 9, 'PUBLISHED', 'ukusan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '134e46df-e5e5-58cc-8850-07a29982b70f', 'sentence_builder', 'Складіть: «Я не їм м’яса.»', 'Ne jedem meso.', '["jedem", "Ne", "meso."]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '65f47791-ca16-518d-a12f-5e6f57715237', 'sentence_builder', 'Складіть: «Соус дуже гострий.»', 'Umak je jako ljut.', '["ljut.", "jako", "Umak", "je"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0c144444-39a2-5c7b-b972-067713e1a490', 'listening', 'Прослухайте і складіть фразу', 'Jesu li lignje svježe?', '["svježe?", "li", "lignje", "Jesu"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e791f309-7885-5435-a45a-4a4d21eaf9d0', 'listening', 'Прослухайте і складіть фразу', 'Ukusna je, ali malo preslana.', '["je,", "Ukusna", "malo", "ali", "preslana."]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '27ae3c1e-1d3e-5011-8d9b-4fa721eaadaa', 'speaking', 'Рибу на грилі, будь ласка.', 'Ribu na žaru, molim.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '27f422da-d902-5002-8aa2-941f04720240', 'speaking', 'Це гостре?', 'Je li ovo ljuto?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('48d653b4-c3bd-50c3-9201-8e98133e2004', v_lesson, 'Вечеря в коноби', 'Večera u konobi', 2481, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('16ef3306-81a2-5697-ac5f-6fb7d872d21c', '48d653b4-c3bd-50c3-9201-8e98133e2004', 'Konobar', 'Večeras preporučujem lignje na žaru ili pečenu piletinu.', 'Сьогодні ввечері раджу кальмари на грилі або запечену курятину.', 1);
  perform pg_temp.turn('e30d225b-9b57-51db-a73e-0f5fae27abe7', '48d653b4-c3bd-50c3-9201-8e98133e2004', 'Daša', 'Jesu li lignje svježe?', 'Кальмари свіжі?', 2);
  perform pg_temp.turn('18e748a3-b210-58c1-8072-a548bda31398', '48d653b4-c3bd-50c3-9201-8e98133e2004', 'Konobar', 'Jesu, jutros su ulovljene.', 'Так, їх виловили сьогодні вранці.', 3);
  perform pg_temp.turn('a9e857e5-6892-56d9-a5fe-f23040d3c7ac', '48d653b4-c3bd-50c3-9201-8e98133e2004', 'Darja', 'Ja ne jedem ni meso ni ribu. Imate li nešto za vegetarijance?', 'Я не їм ні м’яса, ні риби. У вас є щось для вегетаріанців?', 4);
  perform pg_temp.turn('9fd72cd5-8896-5e55-88a8-52310d1c6988', '48d653b4-c3bd-50c3-9201-8e98133e2004', 'Konobar', 'Imamo tjesteninu s povrćem.', 'Є паста з овочами.', 5);
  perform pg_temp.turn('62476d39-137e-5c09-b7b1-baa7a1a69fc9', '48d653b4-c3bd-50c3-9201-8e98133e2004', 'Darja', 'Odlično, onda tjesteninu.', 'Чудово, тоді пасту.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('076a5e68-d5d8-5802-a684-2785b3dee568', v_lesson, 'Як на смак?', 'Kakav je okus?', 2482, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('7524e86f-efce-552a-bf05-78f88fe2cb5f', '076a5e68-d5d8-5802-a684-2785b3dee568', 'Luka', 'Kakva je govedina?', 'Як тобі яловичина?', 1);
  perform pg_temp.turn('06c3c44e-e963-5d94-b66e-e3947ef3cf2a', '076a5e68-d5d8-5802-a684-2785b3dee568', 'Daša', 'Ukusna je, ali malo preslana.', 'Смачна, але трохи пересолена.', 2);
  perform pg_temp.turn('43dcafbe-5d06-52a3-98ec-681f6e7d1adb', '076a5e68-d5d8-5802-a684-2785b3dee568', 'Luka', 'Probaj ovaj umak. Pazi, ljut je!', 'Скуштуй цей соус. Обережно, він гострий!', 3);
  perform pg_temp.turn('08e238bb-59a0-5361-97a3-2e0e906bc163', '076a5e68-d5d8-5802-a684-2785b3dee568', 'Daša', 'Joj, stvarno je pikantan! Daj mi vode.', 'Ой, справді гострий! Дай мені води.', 4);
  perform pg_temp.turn('79b9ff3e-8375-59a3-a799-9ad2c21733a9', '076a5e68-d5d8-5802-a684-2785b3dee568', 'Luka', 'Hoćeš li desert? Kolač nije previše sladak.', 'Хочеш десерт? Тістечко не надто солодке.', 5);
  perform pg_temp.turn('d570364f-ee1b-59ba-b1bf-01eb97ffa377', '076a5e68-d5d8-5802-a684-2785b3dee568', 'Daša', 'Može! Nakon ovoga trebam nešto slatko.', 'Давай! Після такого мені треба чогось солодкого.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- 3. Новий порядок уроків у модулі A0.7: наявні уроки тимчасово переносяться на місця 100+
--    (unique (unit_id, order_index)), щоб звільнити місця для нових; у кроці 5 — на остаточні місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 7 and u.order_index = 1;
  update public.lessons l set order_index = t.o + 100
    from (values
    ('7bbaf7ff-10bb-512a-91c5-798b59ec92a5'::uuid, 1),
    ('c9e045fb-91ff-52a2-9916-1b698d30eb19'::uuid, 2),
    ('8b30911e-4e57-5648-9ff6-bd11c1b0e27e'::uuid, 3),
    ('77d640c4-4190-544a-8094-4e699f9a0a10'::uuid, 4),
    ('e6925fe5-e7fb-5594-9d3f-87fab1b5598d'::uuid, 5)
    ) as t(id, o)
   where l.id = t.id and l.unit_id = v_unit and l.order_index <> t.o and l.order_index < 100;
end $$;

-- 4. Нові тематичні уроки модуля A0.7
-- 5. Наявні уроки модуля A0.7 — на нові місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 7 and u.order_index = 1;
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
   where l.id in ('7bbaf7ff-10bb-512a-91c5-798b59ec92a5', 'c9e045fb-91ff-52a2-9916-1b698d30eb19', '8b30911e-4e57-5648-9ff6-bd11c1b0e27e', '77d640c4-4190-544a-8094-4e699f9a0a10', 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or not exists (select 1 from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar')
             and exists (select 1 from public.lesson_grammar lg where lg.lesson_id = l.id)
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_module from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 7;
  select count(*) into v_order from (values ('7bbaf7ff-10bb-512a-91c5-798b59ec92a5'::uuid, 1), ('c9e045fb-91ff-52a2-9916-1b698d30eb19'::uuid, 2), ('8b30911e-4e57-5648-9ff6-bd11c1b0e27e'::uuid, 3), ('77d640c4-4190-544a-8094-4e699f9a0a10'::uuid, 4), ('e6925fe5-e7fb-5594-9d3f-87fab1b5598d'::uuid, 5)) as t(id, o) join public.lessons l on l.id = t.id and l.order_index = t.o;
  select count(*) into v_lessons from public.lessons where level_code = 'A0' and status = 'PUBLISHED';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A0' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('7bbaf7ff-10bb-512a-91c5-798b59ec92a5', 'c9e045fb-91ff-52a2-9916-1b698d30eb19', '8b30911e-4e57-5648-9ff6-bd11c1b0e27e', '77d640c4-4190-544a-8094-4e699f9a0a10', 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A0.7: % уроків з неправильним складом', v_bad; end if;
  if v_module <> 5 or v_order <> 5 then raise exception 'Модуль A0.7: уроків %, на своїх місцях % (очікувалось 5)', v_module, v_order; end if;
  if v_lessons < 63 then raise exception 'A0: уроків %, очікувалось щонайменше 63', v_lessons; end if;  -- наступні модулі додають уроки
  if v_titles > 0 then raise exception 'A0: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A0.7: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A0.7 — 5 уроків (44–48) за темою; уроків A0 — %', v_lessons;
end $$;

commit;
