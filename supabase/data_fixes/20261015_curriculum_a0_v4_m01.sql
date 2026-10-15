-- =====================================================================
-- Уроки A0 за темою · curriculum_a0_v4 · модуль A0.1 «Pozdrav!» (уроки 1–4) · 2026-10-15
-- Згенеровано: python3 scripts/gen_curriculum_a0_v4.py (не редагуйте вручну).
--
-- Рішення власника 2026-10-15: слова уроку — за темою уроку, 20–25 слів і виразів, діалоги під тему; бета.
--   * Нові слова й вирази: 27. Уроків: 4, слів у них: 87.
--   * Стара версія кожного уроку — у content_versions; копія кроків — у backup.lesson_items_20261015;
--     старі вправи й діалоги → DEPRECATED (не видаляються).
--   * Безпечно запускати повторно: перебудований урок пропускається.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run.
-- =====================================================================

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
values ('zdravo', 'zdravo', 'hr', 'interjection', 'A0', 'привіт (у Хорватії частіше кажуть «bok»)', 'formulaic', '{}'::jsonb, '["Zdravo, kako si?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('puno hvala', 'puno hvala', 'hr', 'phrase', 'A0', 'дуже дякую', 'formulaic', '{}'::jsonb, '["Puno hvala na pomoći!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ne baš dobro', 'ne bas dobro', 'hr', 'phrase', 'A0', 'не дуже добре', 'chunk', '{}'::jsonb, '["Kako si? — Ne baš dobro, malo sam bolestan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tako-tako', 'tako-tako', 'hr', 'phrase', 'A0', 'так собі', 'formulaic', '{}'::jsonb, '["Kako ide posao? — Tako-tako."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('a ti', 'a ti', 'hr', 'phrase', 'A0', 'а ти? (зустрічне питання)', 'chunk', '{}'::jsonb, '["Dobro sam, hvala. A ti?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('a vi', 'a vi', 'hr', 'phrase', 'A0', 'а ви? (ввічливо)', 'chunk', '{}'::jsonb, '["Dobro, hvala. A Vi?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('i ja', 'i ja', 'hr', 'phrase', 'A0', 'і я; я теж', 'chunk', '{}'::jsonb, '["Umoran sam. — I ja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ugodan vikend', 'ugodan vikend', 'hr', 'phrase', 'A0', 'гарних вихідних', 'formulaic', '{}'::jsonb, '["Doviđenja i ugodan vikend!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vidimo se kasnije', 'vidimo se kasnije', 'hr', 'phrase', 'A0', 'побачимося пізніше', 'formulaic', '{}'::jsonb, '["Sad moram ići, vidimo se kasnije!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('do skorog viđenja', 'do skorog videnja', 'hr', 'phrase', 'A0', 'до скорої зустрічі', 'formulaic', '{}'::jsonb, '["Hvala na svemu i do skorog viđenja!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pozdrav', 'pozdrav', 'hr', 'noun', 'A0', 'привіт; вітання', 'core', '{"gender": "m", "plural": "pozdravi"}'::jsonb, '["Pozdrav, Ivane! Kako si?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('lijep pozdrav', 'lijep pozdrav', 'hr', 'phrase', 'A0', 'щирий привіт; з повагою (наприкінці листа)', 'formulaic', '{}'::jsonb, '["Vidimo se u ponedjeljak. Lijep pozdrav, Daša"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('oprosti', 'oprosti', 'hr', 'verb', 'A0', 'вибач (на «ти»)', 'formulaic', '{}'::jsonb, '["Oprosti, nisam te čuo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nisam razumio', 'nisam razumio', 'hr', 'phrase', 'A0', 'я не зрозумів (жін.: nisam razumjela)', 'chunk', '{}'::jsonb, '["Oprostite, nisam razumio. Možete li ponoviti?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nisam te čuo', 'nisam te cuo', 'hr', 'phrase', 'A0', 'я тебе не почув (жін.: nisam te čula)', 'chunk', '{}'::jsonb, '["Oprosti, nisam te čuo. Što si rekla?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sporije', 'sporije', 'hr', 'adverb', 'A0', 'повільніше', 'core', '{}'::jsonb, '["Možete li govoriti sporije?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('glasnije', 'glasnije', 'hr', 'adverb', 'A0', 'голосніше', 'core', '{}'::jsonb, '["Ne čujem Vas. Govorite glasnije, molim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('što znači', 'sto znaci', 'hr', 'phrase', 'A0', 'що означає', 'chunk', '{}'::jsonb, '["Što znači ova riječ?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('možete li napisati', 'mozete li napisati', 'hr', 'phrase', 'A0', 'можете написати?', 'chunk', '{}'::jsonb, '["Možete li napisati adresu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jasno', 'jasno', 'hr', 'adverb', 'A0', 'зрозуміло; ясно', 'function_word', '{}'::jsonb, '["Aha, sad mi je jasno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('hvala na pomoći', 'hvala na pomoci', 'hr', 'phrase', 'A0', 'дякую за допомогу', 'formulaic', '{}'::jsonb, '["Hvala na pomoći, jako ste ljubazni."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('i vama', 'i vama', 'hr', 'phrase', 'A0', 'і вам (теж)', 'formulaic', '{}'::jsonb, '["Ugodan dan! — Hvala, i Vama."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('slobodno', 'slobodno', 'hr', 'adverb', 'A0', 'прошу, можна (дозвіл); вільно', 'formulaic', '{}'::jsonb, '["Smijem li sjesti? — Slobodno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('smijem li', 'smijem li', 'hr', 'phrase', 'A0', 'чи можна мені…?', 'chunk', '{}'::jsonb, '["Smijem li otvoriti prozor?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('svakako', 'svakako', 'hr', 'adverb', 'A0', 'обов’язково; неодмінно', 'function_word', '{}'::jsonb, '["Doći ćeš na rođendan? — Svakako!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('na zdravlje', 'na zdravlje', 'hr', 'phrase', 'A0', 'будьмо! (тост); будь здоров (коли чхають)', 'formulaic', '{}'::jsonb, '["Podignimo čaše. Na zdravlje!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pristojan', 'pristojan', 'hr', 'adjective', 'A0', 'ввічливий; пристойний', 'core', '{"f": "pristojna", "n": "pristojno"}'::jsonb, '["Naš susjed je uvijek pristojan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;

-- 2. Уроки
-- A0.1 · урок 1: Привітання та подяка — 23 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'c0000000-0000-0000-0000-000000000001';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок 1 не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '91bc776d-67fe-5312-8813-461b4ca3cc8b') then return; end if;  -- уже перебудовано
  -- 1. стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a0_v4: урок перебудовано за темою — стара версія (слова, вправи, діалоги)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- 2. старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  -- 3. новий склад уроку (тема граматики та сама)
  select grammar_topic_id into v_gid from public.lesson_grammar where lesson_id = v_lesson limit 1;
  if v_gid is null then select item_id into v_gid from public.lesson_items where lesson_id = v_lesson and item_type = 'grammar' limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 1: Привітання та подяка', title_hr = 'Lekcija 1: Pozdravi i zahvale',
         objectives = '["Привітатися з другом і з незнайомою людиною", "Запитати «Як справи?» і відповісти", "Подякувати й відповісти на подяку"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'bok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zdravo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobro došli', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hvala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hvala lijepa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'puno hvala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'molim', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nema na čemu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kako si', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kako ste', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobro', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odlično', v_pos);
  v_pos := pg_temp.word(v_lesson, 'super', v_pos);
  v_pos := pg_temp.word(v_lesson, 'loše', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ne baš dobro', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tako-tako', v_pos);
  v_pos := pg_temp.word(v_lesson, 'umoran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'a ti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'a vi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'i ja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'da', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ne', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žao mi je', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a71450d-1d27-5b67-b56e-9d9e58871c4b', 'fill_in_the_blank', 'Ja ___ umorna.', 'sam', '["sam", "smo", "si", "je"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0bba0da3-a3a4-59e6-a0a9-77f3312a4486', 'multiple_choice', 'Що означає «hvala lijepa»?', 'щиро дякую', '["щиро дякую", "ні", "як ви?; як справи? (ввічливо)", "нема за що"]'::jsonb, 'A0', 2, 'PUBLISHED', 'hvala lijepa', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '56972021-2204-52d1-ab60-161139ffad87', 'multiple_choice', 'Що означає «puno hvala»?', 'дуже дякую', '["а ви? (ввічливо)", "дуже дякую", "супер", "погано"]'::jsonb, 'A0', 3, 'PUBLISHED', 'puno hvala', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9207b8bf-7f57-5bbd-9b3d-b4a2d1f049d8', 'multiple_choice', 'Що означає «nema na čemu»?', 'нема за що', '["привіт / бувай", "нема за що", "прошу / будь ласка / що (ви сказали)?", "мені шкода"]'::jsonb, 'A0', 4, 'PUBLISHED', 'nema na čemu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e5f23e3c-3e5b-567c-9c62-d891a14d83c5', 'multiple_choice', 'Як хорватською «мені шкода»?', 'žao mi je', '["dobro došli", "a vi", "žao mi je", "tako-tako"]'::jsonb, 'A0', 5, 'PUBLISHED', 'žao mi je', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c84dd9ed-84e2-52a4-8404-907243fcb574', 'multiple_choice', 'Як хорватською «втомлений»?', 'umoran', '["odlično", "dobro došli", "zdravo", "umoran"]'::jsonb, 'A0', 6, 'PUBLISHED', 'umoran', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7b30b496-4ab1-5f79-80c6-1b87dd88a617', 'type_answer', 'Напишіть хорватською: «погано»', 'loše', null, 'A0', 7, 'PUBLISHED', 'loše', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3f62b7df-fddd-55b2-adde-e4425a7b7e40', 'type_answer', 'Напишіть хорватською: «супер»', 'super', null, 'A0', 8, 'PUBLISHED', 'super', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd0f89af9-eb4d-5efc-a128-d33832315ee7', 'type_answer', 'Напишіть хорватською: «ласкаво просимо»', 'dobro došli', null, 'A0', 9, 'PUBLISHED', 'dobro došli', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ef7b6ee0-ae43-5d81-b478-237cea3f2223', 'sentence_builder', 'Складіть: «Добре, дякую. А ти?»', 'Dobro, hvala. A ti?', '["hvala.", "A", "Dobro,", "ti?"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f0a38ca1-665b-55cf-979b-871261ad8e16', 'sentence_builder', 'Складіть: «Я теж трохи втомлений.»', 'I ja sam malo umoran.', '["ja", "malo", "umoran.", "I", "sam"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '99f0a8c3-84b2-51ca-bab5-daeb0ae550d9', 'listening', 'Прослухайте і складіть фразу', 'Žao mi je. I ja sam malo umoran.', '["mi", "umoran.", "je.", "I", "sam", "Žao", "malo", "ja"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '777ed956-59d3-551e-b4c3-287e929522e6', 'listening', 'Прослухайте і складіть фразу', 'Odlično, hvala. A Vi?', '["Odlično,", "hvala.", "Vi?", "A"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '763ffd8f-e67f-5336-83e2-0fc2b8b2fc2a', 'speaking', 'Як справи? (до друга)', 'Kako si?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6c356de4-3044-5c0b-a39d-c0d283f2203a', 'speaking', 'Дуже дякую!', 'Puno hvala!', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('91bc776d-67fe-5312-8813-461b4ca3cc8b', v_lesson, 'Зустріч на вулиці', 'Susret na ulici', 2011, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('fdd65063-7819-511c-a88d-b85264fc99d1', '91bc776d-67fe-5312-8813-461b4ca3cc8b', 'Daša', 'Bok, Marko! Kako si?', 'Привіт, Марку! Як справи?', 1);
  perform pg_temp.turn('d6e72123-958d-53f8-9ef4-d922543c2037', '91bc776d-67fe-5312-8813-461b4ca3cc8b', 'Marko', 'Bok, Dašo! Super, hvala. A ti?', 'Привіт, Дашо! Чудово, дякую. А ти?', 2);
  perform pg_temp.turn('0ecf40bf-d3ce-5aa3-9438-8803c5dc5387', '91bc776d-67fe-5312-8813-461b4ca3cc8b', 'Daša', 'Ne baš dobro. Umorna sam.', 'Не дуже добре. Я втомлена.', 3);
  perform pg_temp.turn('29f6b491-d3ac-5efc-b7cb-9669f8e482bd', '91bc776d-67fe-5312-8813-461b4ca3cc8b', 'Marko', 'Žao mi je. I ja sam malo umoran.', 'Мені шкода. Я теж трохи втомлений.', 4);
  perform pg_temp.turn('a72d6078-7fef-578b-a67e-ea3417f1ce82', '91bc776d-67fe-5312-8813-461b4ca3cc8b', 'Daša', 'Hvala ti. Bok!', 'Дякую тобі. Бувай!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3a52a25b-0773-5acf-9a77-01011274a353', v_lesson, 'У гостях у сусідки', 'Kod susjede', 2012, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('d244eded-0c5a-5a73-ad01-392be839519f', '3a52a25b-0773-5acf-9a77-01011274a353', 'Gospođa Horvat', 'Dobro došli! Izvolite.', 'Ласкаво просимо! Заходьте.', 1);
  perform pg_temp.turn('038f7607-08a2-5bb8-9990-1a40363610a5', '3a52a25b-0773-5acf-9a77-01011274a353', 'Petro', 'Hvala lijepa! Kako ste?', 'Щиро дякую! Як ви?', 2);
  perform pg_temp.turn('a29550b8-f237-5572-9cf6-4b526ded8612', '3a52a25b-0773-5acf-9a77-01011274a353', 'Gospođa Horvat', 'Odlično, hvala. A Vi?', 'Відмінно, дякую. А ви?', 3);
  perform pg_temp.turn('119eff4c-d32b-5161-a449-5ebfd05de3a9', '3a52a25b-0773-5acf-9a77-01011274a353', 'Petro', 'Tako-tako. Imam puno posla.', 'Так собі. У мене багато роботи.', 4);
  perform pg_temp.turn('c7c531ce-c8ea-5957-80cd-19a296ff286a', '3a52a25b-0773-5acf-9a77-01011274a353', 'Gospođa Horvat', 'Onda sjednite i odmorite se.', 'Тоді сідайте й відпочиньте.', 5);
  perform pg_temp.turn('ab66a3eb-52af-5bc2-999b-bcdd64d905db', '3a52a25b-0773-5acf-9a77-01011274a353', 'Petro', 'Puno hvala!', 'Дуже дякую!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.1 · урок 2: Добрий день і до побачення — 21 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'd8cffb46-8a62-538a-b864-e227a6d8b863';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок 2 не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '07f79b2d-3ef5-5fb5-8d54-9e1fcd418b58') then return; end if;  -- уже перебудовано
  -- 1. стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a0_v4: урок перебудовано за темою — стара версія (слова, вправи, діалоги)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- 2. старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  -- 3. новий склад уроку (тема граматики та сама)
  select grammar_topic_id into v_gid from public.lesson_grammar where lesson_id = v_lesson limit 1;
  if v_gid is null then select item_id into v_gid from public.lesson_items where lesson_id = v_lesson and item_type = 'grammar' limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 2: Добрий день і до побачення', title_hr = 'Lekcija 2: Dobar dan i doviđenja',
         objectives = '["Вітатися зранку, вдень і ввечері", "Прощатися й бажати гарного дня, вечора чи вихідних", "Казати «до завтра» і «побачимося пізніше»"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'dobro jutro', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobar dan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobra večer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'laku noć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'doviđenja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugodan dan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugodna večer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugodan vikend', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vidimo se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'do sutra', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vidimo se kasnije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'do skorog viđenja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čujemo se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sretan put', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pozdrav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lijep pozdrav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pozdraviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jutro', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'večer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'noć', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a26e0e49-1d3d-5ec8-9a71-deba7189f976', 'fill_in_the_blank', 'Hvala, i ___, gospodine Kovač!', 'Vama', '["Vama", "Vas", "ti", "tebi"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f2ba39ac-0897-5e23-9bce-6ce3a14ae4e3', 'multiple_choice', 'Що означає «dan»?', 'день', '["привіт; вітання", "день", "доброго ранку", "привітати"]'::jsonb, 'A0', 2, 'PUBLISHED', 'dan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9e5b5625-5af9-592a-abd4-c3cf61916fc8', 'multiple_choice', 'Що означає «ugodna večer»?', 'гарного вечора', '["до завтра", "доброго ранку", "до скорої зустрічі", "гарного вечора"]'::jsonb, 'A0', 3, 'PUBLISHED', 'ugodna večer', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7038d062-1610-57fa-9f5e-2794bec70a45', 'multiple_choice', 'Що означає «doviđenja»?', 'до побачення', '["привітати", "гарних вихідних", "щасливої дороги", "до побачення"]'::jsonb, 'A0', 4, 'PUBLISHED', 'doviđenja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3bbe7edb-b710-5496-8628-e5c675448247', 'multiple_choice', 'Як хорватською «ранок»?', 'jutro', '["vidimo se", "pozdrav", "doviđenja", "jutro"]'::jsonb, 'A0', 5, 'PUBLISHED', 'jutro', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bb58b04f-b4d2-5fce-a5c7-560da26cb204', 'multiple_choice', 'Як хорватською «гарних вихідних»?', 'ugodan vikend', '["pozdrav", "do skorog viđenja", "ugodan vikend", "večer"]'::jsonb, 'A0', 6, 'PUBLISHED', 'ugodan vikend', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '56117486-b65c-5ac5-97d8-ec6d2d5f7ff4', 'type_answer', 'Напишіть хорватською: «зідзвонимось»', 'čujemo se', null, 'A0', 7, 'PUBLISHED', 'čujemo se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd112150c-374c-595c-9a57-f9e078aa409b', 'type_answer', 'Напишіть хорватською: «щасливої дороги»', 'sretan put', null, 'A0', 8, 'PUBLISHED', 'sretan put', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd86ae220-46b9-5261-a416-95efe77198b6', 'type_answer', 'Напишіть хорватською: «надобраніч»', 'laku noć', null, 'A0', 9, 'PUBLISHED', 'laku noć', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '84c29b4d-26a9-57f9-8d58-9615edc1d718', 'sentence_builder', 'Складіть: «Гарного дня!»', 'Ugodan dan!', '["dan!", "Ugodan"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cc39a356-976d-5c92-8e54-6f07b158929c', 'sentence_builder', 'Складіть: «Побачимося пізніше!»', 'Vidimo se kasnije!', '["se", "Vidimo", "kasnije!"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '67dac1e1-8fb2-5808-a522-d082edef14c0', 'listening', 'Прослухайте і складіть фразу', 'Hvala, i Vama. Doviđenja!', '["Doviđenja!", "Vama.", "Hvala,", "i"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3b71f76f-ec32-5b45-82bd-ce1abaa48872', 'listening', 'Прослухайте і складіть фразу', 'Hoću. Laku noć!', '["noć!", "Hoću.", "Laku"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f37694a-5de2-5c6a-b543-616e2bbaf8e5', 'speaking', 'Доброго ранку!', 'Dobro jutro!', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '51f8e317-2f54-520f-bd22-ef2ad7d49270', 'speaking', 'Гарних вихідних!', 'Ugodan vikend!', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('07f79b2d-3ef5-5fb5-8d54-9e1fcd418b58', v_lesson, 'Ранок у під’їзді', 'Jutro u zgradi', 2021, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('ae7c403f-7235-572b-b067-cc25290f5123', '07f79b2d-3ef5-5fb5-8d54-9e1fcd418b58', 'Gospodin Kovač', 'Dobro jutro, Dašo!', 'Доброго ранку, Дашо!', 1);
  perform pg_temp.turn('2bf3cee5-2a91-532b-b110-5728416288a7', '07f79b2d-3ef5-5fb5-8d54-9e1fcd418b58', 'Daša', 'Dobro jutro, gospodine Kovač! Kako ste?', 'Доброго ранку, пане Ковач! Як ви?', 2);
  perform pg_temp.turn('12946429-b1b0-541f-863f-cdf12d1ccd18', '07f79b2d-3ef5-5fb5-8d54-9e1fcd418b58', 'Gospodin Kovač', 'Dobro, hvala. Idem na posao.', 'Добре, дякую. Іду на роботу.', 3);
  perform pg_temp.turn('bb2ea83b-c8dd-5a28-ba47-94e4be6f008c', '07f79b2d-3ef5-5fb5-8d54-9e1fcd418b58', 'Daša', 'I ja. Ugodan dan!', 'Я теж. Гарного дня!', 4);
  perform pg_temp.turn('337435aa-455b-5669-82dd-68c6eace8048', '07f79b2d-3ef5-5fb5-8d54-9e1fcd418b58', 'Gospodin Kovač', 'Hvala, i Vama. Doviđenja!', 'Дякую, і вам. До побачення!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('da8989e4-61d2-563d-b15e-5ad93bd4d986', v_lesson, 'Увечері після курсу', 'Navečer poslije tečaja', 2022, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('b1b90b56-9b1b-50eb-af45-4b85785cfabf', 'da8989e4-61d2-563d-b15e-5ad93bd4d986', 'Maja', 'Ja idem kući. Vidimo se sutra?', 'Я йду додому. Побачимося завтра?', 1);
  perform pg_temp.turn('f1c53d88-4393-5746-828a-d7cd9f985097', 'da8989e4-61d2-563d-b15e-5ad93bd4d986', 'Ivan', 'Sutra ne mogu. Čujemo se!', 'Завтра не можу. Зідзвонимося!', 2);
  perform pg_temp.turn('fcec9615-1e08-50bf-9a20-9bac06231200', 'da8989e4-61d2-563d-b15e-5ad93bd4d986', 'Maja', 'Dobro. Ugodna večer i ugodan vikend!', 'Добре. Гарного вечора й гарних вихідних!', 3);
  perform pg_temp.turn('2be1977f-8e2e-5436-a228-bc0d72694816', 'da8989e4-61d2-563d-b15e-5ad93bd4d986', 'Ivan', 'Hvala, i tebi. Pozdravi mamu!', 'Дякую, і тобі. Передавай привіт мамі!', 4);
  perform pg_temp.turn('832f0601-ab91-5851-98d4-386058d872ce', 'da8989e4-61d2-563d-b15e-5ad93bd4d986', 'Maja', 'Hoću. Laku noć!', 'Обов’язково. На добраніч!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.1 · урок 3: Вибачте, я не розумію — 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'a17f2f16-1be9-50f2-8e16-2bebfcced33b';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок 3 не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'd29ae6e0-caf4-5877-955b-d174a7ef73ae') then return; end if;  -- уже перебудовано
  -- 1. стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a0_v4: урок перебудовано за темою — стара версія (слова, вправи, діалоги)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- 2. старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  -- 3. новий склад уроку (тема граматики та сама)
  select grammar_topic_id into v_gid from public.lesson_grammar where lesson_id = v_lesson limit 1;
  if v_gid is null then select item_id into v_gid from public.lesson_items where lesson_id = v_lesson and item_type = 'grammar' limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 3: Вибачте, я не розумію', title_hr = 'Lekcija 3: Oprostite, ne razumijem',
         objectives = '["Сказати, що ви не зрозуміли чи не почули", "Попросити повторити, говорити повільніше чи голосніше", "Запитати, що означає слово і як щось сказати"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'oprostite', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oprosti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ne razumijem', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razumjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nisam razumio', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nisam te čuo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'možete li ponoviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polako', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sporije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glasnije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'malo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'govoriti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'govorite li engleski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'engleski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'što znači', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kako se kaže', v_pos);
  v_pos := pg_temp.word(v_lesson, 'riječ', v_pos);
  v_pos := pg_temp.word(v_lesson, 'možete li napisati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ne znam', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naravno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pitanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jasno', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a05d998-0233-51f5-b84a-bdb032d2e13b', 'fill_in_the_blank', 'Oprostite, ___ razumijem.', 'ne', '["nije", "ni", "nisam", "ne"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '37d7063f-30a0-5d17-aeb1-93fdcded5e84', 'multiple_choice', 'Що означає «možete li ponoviti»?', 'можете повторити', '["що означає", "розуміти", "можете повторити", "повільніше"]'::jsonb, 'A0', 2, 'PUBLISHED', 'možete li ponoviti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b5a73c8-9deb-5170-a62d-662a9220f199', 'multiple_choice', 'Що означає «jasno»?', 'зрозуміло; ясно', '["я тебе не почув (жін.: nisam te čula)", "зрозуміло; ясно", "розуміти", "звісно / звичайно"]'::jsonb, 'A0', 3, 'PUBLISHED', 'jasno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a24d9030-e511-5375-969b-582b4b705540', 'multiple_choice', 'Що означає «nisam razumio»?', 'я не зрозумів (жін.: nisam razumjela)', '["мало / трохи", "говорити", "я не зрозумів (жін.: nisam razumjela)", "повільно"]'::jsonb, 'A0', 4, 'PUBLISHED', 'nisam razumio', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd75e6514-3490-56f5-ba99-afb38654acc7', 'multiple_choice', 'Як хорватською «розуміти»?', 'razumjeti', '["oprostite", "što znači", "razumjeti", "jasno"]'::jsonb, 'A0', 5, 'PUBLISHED', 'razumjeti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cba8386a-8b1e-5ca5-899b-df20faa33697', 'multiple_choice', 'Як хорватською «мало / трохи»?', 'malo', '["jasno", "kako se kaže", "malo", "možete li ponoviti"]'::jsonb, 'A0', 6, 'PUBLISHED', 'malo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0f066f67-66ec-52fb-8923-47a50c2c517b', 'type_answer', 'Напишіть хорватською: «запитання»', 'pitanje', null, 'A0', 7, 'PUBLISHED', 'pitanje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '609cb0a4-75dd-52a3-8fb5-16a3d3ce8638', 'type_answer', 'Напишіть хорватською: «повільніше»', 'sporije', null, 'A0', 8, 'PUBLISHED', 'sporije', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ed0e43e9-5a04-5b1b-b1aa-ae066383c66e', 'type_answer', 'Напишіть хорватською: «голосніше»', 'glasnije', null, 'A0', 9, 'PUBLISHED', 'glasnije', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '02d5649a-e4cf-50d0-ba8b-0e9707371edb', 'sentence_builder', 'Складіть: «Що означає це слово?»', 'Što znači ova riječ?', '["znači", "ova", "Što", "riječ?"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aee39010-8a2e-5737-9162-8c0112e51b2f', 'sentence_builder', 'Складіть: «Можете написати?»', 'Možete li napisati?', '["napisati?", "Možete", "li"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b13773db-25b7-5342-a7cc-7c571470d58f', 'listening', 'Прослухайте і складіть фразу', 'Oprostite, nisam razumio. Možete li ponoviti?', '["Možete", "ponoviti?", "razumio.", "li", "Oprostite,", "nisam"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0c538d1f-95b4-5358-9404-3c334e09f9a8', 'listening', 'Прослухайте і складіть фразу', 'Aha, jasno!', '["jasno!", "Aha,"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'da0ece41-afe4-520e-82fa-68b94677b957', 'speaking', 'Я не розумію.', 'Ne razumijem.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa917be6-21b4-58ac-aedf-a0487ed19e9b', 'speaking', 'Говоріть повільніше, будь ласка.', 'Govorite sporije, molim.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d29ae6e0-caf4-5877-955b-d174a7ef73ae', v_lesson, 'Турист у Загребі', 'Turist u Zagrebu', 2031, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('a97fbe3d-9421-5ca0-b8be-7425585b2718', 'd29ae6e0-caf4-5877-955b-d174a7ef73ae', 'Turist', 'Oprostite, govorite li engleski?', 'Вибачте, ви розмовляєте англійською?', 1);
  perform pg_temp.turn('cb1f77d0-e0d5-52f0-ba7d-20da52cf8001', 'd29ae6e0-caf4-5877-955b-d174a7ef73ae', 'Prolaznik', 'Malo. Izvolite?', 'Трохи. Слухаю вас?', 2);
  perform pg_temp.turn('4a5fee35-1217-578b-b05c-8ac0d9ea777b', 'd29ae6e0-caf4-5877-955b-d174a7ef73ae', 'Turist', 'Ne razumijem dobro hrvatski. Možete li govoriti polako?', 'Я погано розумію хорватську. Можете говорити повільно?', 3);
  perform pg_temp.turn('e532581c-abbb-5ace-aa08-b04f26fca6c5', 'd29ae6e0-caf4-5877-955b-d174a7ef73ae', 'Prolaznik', 'Naravno. Tramvaj broj šest ide u centar.', 'Звісно. Трамвай номер шість їде в центр.', 4);
  perform pg_temp.turn('bf919ec5-1182-5b68-b955-075d7c202eef', 'd29ae6e0-caf4-5877-955b-d174a7ef73ae', 'Turist', 'Oprostite, nisam razumio. Možete li ponoviti?', 'Вибачте, я не зрозумів. Можете повторити?', 5);
  perform pg_temp.turn('49ac812b-9fa4-5ed2-9bcc-b62314fd9f28', 'd29ae6e0-caf4-5877-955b-d174a7ef73ae', 'Prolaznik', 'Tramvaj broj šest. Šest!', 'Трамвай номер шість. Шість!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b4583f3b-0f13-511e-a86d-8428f631c2a8', v_lesson, 'На курсі хорватської', 'Na tečaju hrvatskog', 2032, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('a7f45cca-1635-549c-9fee-2a9b8da9e2b4', 'b4583f3b-0f13-511e-a86d-8428f631c2a8', 'Daša', 'Oprostite, što znači »sutra«?', 'Вибачте, що означає «sutra»?', 1);
  perform pg_temp.turn('629d6e00-f4d5-590a-9f29-759d5685de9f', 'b4583f3b-0f13-511e-a86d-8428f631c2a8', 'Profesorica', 'Danas je ponedjeljak, a sutra je utorak.', 'Сьогодні понеділок, а завтра вівторок.', 2);
  perform pg_temp.turn('30dbf91c-2680-5d3c-bd7f-518e751764f9', 'b4583f3b-0f13-511e-a86d-8428f631c2a8', 'Daša', 'Aha, jasno! A kako se kaže »thank you«?', 'А, зрозуміло! А як сказати «thank you»?', 3);
  perform pg_temp.turn('19174428-5e15-5a50-bb9a-a4ffe1a632e8', 'b4583f3b-0f13-511e-a86d-8428f631c2a8', 'Profesorica', 'Kaže se: hvala.', 'Кажуть: «hvala».', 4);
  perform pg_temp.turn('e4430435-7d29-5057-9716-ac6f0228fd50', 'b4583f3b-0f13-511e-a86d-8428f631c2a8', 'Daša', 'Oprostite, nisam Vas čula. Možete li ponoviti glasnije?', 'Вибачте, я вас не почула. Можете повторити голосніше?', 5);
  perform pg_temp.turn('5d7f8402-2de7-5ad2-818b-49acb350b60d', 'b4583f3b-0f13-511e-a86d-8428f631c2a8', 'Profesorica', 'Naravno. Hvala!', 'Звісно. «Hvala»!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.1 · урок 4: Ввічливі слова — 21 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'e704760a-f743-5762-9c1a-027b10ca030a';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок 4 не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '18d57240-d7f5-50f0-a9c1-6c570cfc4190') then return; end if;  -- уже перебудовано
  -- 1. стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a0_v4: урок перебудовано за темою — стара версія (слова, вправи, діалоги)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- 2. старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  -- 3. новий склад уроку (тема граматики та сама)
  select grammar_topic_id into v_gid from public.lesson_grammar where lesson_id = v_lesson limit 1;
  if v_gid is null then select item_id into v_gid from public.lesson_items where lesson_id = v_lesson and item_type = 'grammar' limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 4: Ввічливі слова', title_hr = 'Lekcija 4: Pristojne riječi',
         objectives = '["Перепросити й відповісти на вибачення", "Попросити дозволу й дозволити", "Привітати з днем народження й побажати успіху"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'izvolite', v_pos);
  v_pos := pg_temp.word(v_lesson, 'molim vas', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispričavam se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nema problema', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u redu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'može', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slobodno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smijem li', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svakako', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sretno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čestitam', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sretan rođendan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'i tebi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'i vama', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hvala na pomoći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kasniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na zdravlje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobar tek', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nažalost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pristojan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljubazan', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '8db6b806-3ac0-5171-988a-27ab7d509c2f', 'fill_in_the_blank', 'Ispričavam ___, kasnim.', 'se', '["me", "te", "si", "se"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b3490992-c9f0-55dc-a9d5-630f5b901ecc', 'multiple_choice', 'Що означає «može»?', 'можна / згода', '["смачного!", "можна / згода", "обов’язково; неодмінно", "і тобі (теж)"]'::jsonb, 'A0', 2, 'PUBLISHED', 'može', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '36b806f0-5e73-5be6-9224-e5410195c5b0', 'multiple_choice', 'Що означає «hvala na pomoći»?', 'дякую за допомогу', '["успіхів; щасти", "дякую за допомогу", "немає проблем", "будь ласка (до вас)"]'::jsonb, 'A0', 3, 'PUBLISHED', 'hvala na pomoći', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '70414170-18ec-5ff1-a06c-230395d59bbe', 'multiple_choice', 'Що означає «ljubazan»?', 'ввічливий; добрий', '["можна / згода", "успіхів; щасти", "і вам (теж)", "ввічливий; добрий"]'::jsonb, 'A0', 4, 'PUBLISHED', 'ljubazan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7908928e-b70b-5154-a6b7-09fe89712ceb', 'multiple_choice', 'Як хорватською «будьмо! (тост); будь здоров (коли чхають)»?', 'na zdravlje', '["nema problema", "hvala na pomoći", "na zdravlje", "kasniti"]'::jsonb, 'A0', 5, 'PUBLISHED', 'na zdravlje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c80cd73b-50f4-5d14-b9a4-421e40a9e96d', 'multiple_choice', 'Як хорватською «на жаль»?', 'nažalost', '["ispričavam se", "nažalost", "sretan rođendan", "pristojan"]'::jsonb, 'A0', 6, 'PUBLISHED', 'nažalost', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f3bbd036-9b82-50cd-9960-1ea51e16bd4d', 'type_answer', 'Напишіть хорватською: «успіхів; щасти»', 'sretno', null, 'A0', 7, 'PUBLISHED', 'sretno', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a91b8797-586f-5130-b38d-82ae80084059', 'type_answer', 'Напишіть хорватською: «запізнюватися»', 'kasniti', null, 'A0', 8, 'PUBLISHED', 'kasniti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7c055c05-50e6-53d1-a8af-771e06cfbae4', 'type_answer', 'Напишіть хорватською: «смачного!»', 'dobar tek', null, 'A0', 9, 'PUBLISHED', 'dobar tek', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a4ff963b-3c35-5b31-903b-c896ebbdef7a', 'sentence_builder', 'Складіть: «Перепрошую, я запізнююся.»', 'Ispričavam se, kasnim.', '["Ispričavam", "kasnim.", "se,"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3b35372e-2131-5433-bd27-ea0bb2f9ebed', 'sentence_builder', 'Складіть: «З днем народження!»', 'Sretan rođendan!', '["rođendan!", "Sretan"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '05f99530-5a61-53ee-8b81-89aad8d65121', 'listening', 'Прослухайте і складіть фразу', 'Nema problema. Izvolite, sjednite.', '["sjednite.", "problema.", "Nema", "Izvolite,"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7bf3fee2-fcc3-57ed-a361-a6aec6eeb557', 'listening', 'Прослухайте і складіть фразу', 'Vino, molim. Na zdravlje!', '["molim.", "Vino,", "zdravlje!", "Na"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9eca1e71-d983-5b0c-a3dc-887215bdeff5', 'speaking', 'Можна? (просимо дозволу)', 'Smijem li?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b228b8cf-3458-56d8-a302-3d1db4082020', 'speaking', 'Дякую за допомогу!', 'Hvala na pomoći!', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('18d57240-d7f5-50f0-a9c1-6c570cfc4190', v_lesson, 'Перепрошую!', 'Ispričavam se!', 2041, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('c011b674-b735-5956-8813-300723cdd137', '18d57240-d7f5-50f0-a9c1-6c570cfc4190', 'Daša', 'Ispričavam se, kasnim pet minuta.', 'Перепрошую, я запізнююся на п’ять хвилин.', 1);
  perform pg_temp.turn('b398bb0b-4a82-5399-8eaa-e0c61dfda60c', '18d57240-d7f5-50f0-a9c1-6c570cfc4190', 'Gospođa Horvat', 'Nema problema. Izvolite, sjednite.', 'Нічого страшного. Прошу, сідайте.', 2);
  perform pg_temp.turn('02d606d2-d56f-54c1-8077-355d03a47b4c', '18d57240-d7f5-50f0-a9c1-6c570cfc4190', 'Daša', 'Hvala. Smijem li otvoriti prozor?', 'Дякую. Можна відчинити вікно?', 3);
  perform pg_temp.turn('b3623791-7c7c-5745-bdd4-c1c9ffcd036f', '18d57240-d7f5-50f0-a9c1-6c570cfc4190', 'Gospođa Horvat', 'Slobodno.', 'Прошу, відчиняйте.', 4);
  perform pg_temp.turn('f4bb6292-c3a0-5b8b-9015-bb74863ff312', '18d57240-d7f5-50f0-a9c1-6c570cfc4190', 'Daša', 'Hvala, jako ste ljubazni.', 'Дякую, ви дуже люб’язні.', 5);
  perform pg_temp.turn('037d8118-baee-586e-99ad-5ce1a8640a5a', '18d57240-d7f5-50f0-a9c1-6c570cfc4190', 'Gospođa Horvat', 'Molim, nema na čemu.', 'Прошу, нема за що.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6ed24db8-2aaf-51bd-91f2-6bc8767e1a3a', v_lesson, 'День народження', 'Rođendan', 2042, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('64dea03c-8b68-5731-af61-95fc19afb495', '6ed24db8-2aaf-51bd-91f2-6bc8767e1a3a', 'Marko', 'Sretan rođendan, Dašo! Čestitam!', 'З днем народження, Дашо! Вітаю!', 1);
  perform pg_temp.turn('c5f61f67-5971-534b-864e-54a4bedb16cf', '6ed24db8-2aaf-51bd-91f2-6bc8767e1a3a', 'Daša', 'Hvala, Marko! Izvoli, sok ili vino?', 'Дякую, Марку! Прошу, сік чи вино?', 2);
  perform pg_temp.turn('2d4d95bc-dd70-589e-ad38-0e94ff403051', '6ed24db8-2aaf-51bd-91f2-6bc8767e1a3a', 'Marko', 'Vino, molim. Na zdravlje!', 'Вино, будь ласка. Будьмо!', 3);
  perform pg_temp.turn('982346e6-e9d9-5ad7-b5a3-0bebef89a164', '6ed24db8-2aaf-51bd-91f2-6bc8767e1a3a', 'Daša', 'Na zdravlje! I sretno na novom poslu!', 'Будьмо! І успіхів на новій роботі!', 4);
  perform pg_temp.turn('cdd2c75f-1483-5119-8776-adabd6221ac1', '6ed24db8-2aaf-51bd-91f2-6bc8767e1a3a', 'Marko', 'Hvala, i tebi!', 'Дякую, і тобі!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('c0000000-0000-0000-0000-000000000001', 'd8cffb46-8a62-538a-b864-e227a6d8b863', 'a17f2f16-1be9-50f2-8e16-2bebfcced33b', 'e704760a-f743-5762-9c1a-027b10ca030a')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15);
  if v_bad > 0 then raise exception 'Перебудова не вдалася: % уроків з неправильним складом', v_bad; end if;
  raise notice 'Готово: уроки A0.1 перебудовано (20–25 слів, 2 діалоги, 15 вправ)';
end $$;
