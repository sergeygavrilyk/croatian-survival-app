-- =====================================================================
-- Програма A1 v3 · модуль A1.13 «Підсумок A1: моє життя в Хорватії» · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_curriculum_a1_v3.py 13 (не редагуйте вручну).
--
-- Рішення власника 2026-10-21 / 2026-10-26: до 25 слів на урок — скільки потрібно темі, 90–95 % слів — нові для рівня,
-- діалоги під тему, частіше Даша / Дар’я; бета (PUBLISHED).
--   * Уроки 106–108: 3 наявних перебудовано, 0 нових. Слів у них: 43.
--     Кожен: 10–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 15.
--   * Виправлено: otvoren — «відчинений; відкритий (про людину)»; uspjeti — «вдатися, досягти успіху; встигнути»; napredovati — «просуватися (у навчанні, по службі), прогресувати»; postati — «стати (кимось, чимось)» (стара версія — у content_versions).
--   * Стара версія кожного зміненого уроку — у content_versions; копія кроків — у backup.lesson_items_20261015;
--     старі вправи й діалоги → DEPRECATED (не видаляються). Назви всіх уроків A1 — наскрізні номери.
--   * Потрібен уже запущений 20261026_curriculum_a1_v3_structure.sql. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.modules where id = '09e7c668-b622-56b2-82e9-b1c0c0db54c6') then
    raise exception 'Спершу запустіть 20261026_curriculum_a1_v3_structure.sql (нова програма A1)';
  end if;
end $$;

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

-- 1. Нові слова й вирази A1.13 (15; наявні не змінюються)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('podrijetlo', 'podrijetlo', 'hr', 'noun', 'A1', 'походження', 'core', '{"gender": "n"}'::jsonb, '["Po podrijetlu sam Ukrajinka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odrasti', 'odrasti', 'hr', 'verb', 'A1', 'вирости, подорослішати', 'core', '{"aspect": "pfv"}'::jsonb, '["Odrasla sam u malom gradu blizu Lavova."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zanimati se', 'zanimati se', 'hr', 'verb', 'A1', 'цікавитися', 'core', '{"aspect": "ipfv"}'::jsonb, '["Zanimam se za glazbu i sport."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('osobina', 'osobina', 'hr', 'noun', 'A1', 'риса (характеру)', 'core', '{"gender": "f"}'::jsonb, '["Strpljenje je moja najbolja osobina."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('znatiželjan', 'znatizeljan', 'hr', 'adjective', 'A1', 'допитливий', 'core', '{}'::jsonb, '["Djeca su jako znatiželjna."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('komunikativan', 'komunikativan', 'hr', 'adjective', 'A1', 'комунікабельний', 'core', '{}'::jsonb, '["Tražimo komunikativnu osobu za rad s gostima."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pouzdan', 'pouzdan', 'hr', 'adjective', 'A1', 'надійний', 'core', '{}'::jsonb, '["Marko je pouzdan kolega."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('samouvjeren', 'samouvjeren', 'hr', 'adjective', 'A1', 'упевнений у собі', 'core', '{}'::jsonb, '["Na razgovoru za posao budite samouvjereni."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('samostalan', 'samostalan', 'hr', 'adjective', 'A1', 'самостійний', 'core', '{}'::jsonb, '["Volim raditi samostalno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('doseliti se', 'doseliti se', 'hr', 'verb', 'A1', 'переселитися, переїхати (на проживання)', 'core', '{"aspect": "pfv"}'::jsonb, '["Doselili smo se u Rijeku prije dvije godine."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nostalgija', 'nostalgija', 'hr', 'noun', 'A1', 'ностальгія', 'core', '{"gender": "f"}'::jsonb, '["Zimi osjećam nostalgiju za domom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('volontirati', 'volontirati', 'hr', 'verb', 'A1', 'волонтерити', 'core', '{"aspect": "ipfv"}'::jsonb, '["Subotom volontiram u skloništu za životinje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sjećati se', 'sjecati se', 'hr', 'verb', 'A1', 'пам’ятати, згадувати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Sjećam se svog prvog dana u Zagrebu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('korak po korak', 'korak po korak', 'hr', 'phrase', 'A1', 'крок за кроком', 'chunk', '{}'::jsonb, '["Korak po korak, sve će biti lakše."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('usavršiti', 'usavrsiti', 'hr', 'verb', 'A1', 'вдосконалити', 'core', '{"aspect": "pfv"}'::jsonb, '["Ove godine želim usavršiti hrvatski."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;

-- 1б. Виправлені слова (4); повторний запуск нічого не змінює
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'otvoren' and ukrainian_translation = 'відчинений / відкритий' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'відчинений; відкритий (про людину)' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'uspjeti' and ukrainian_translation = 'змогти / досягти успіху / вдатися' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'вдатися, досягти успіху; встигнути' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'napredovati' and ukrainian_translation = 'просуватися' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'просуватися (у навчанні, по службі), прогресувати' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'postati' and ukrainian_translation = 'стати (кимсь / чимось)' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'стати (кимось, чимось)' where id = r.id;
  end loop;
end $$;

-- 2. Перебудова наявних уроків модуля A1.13
-- A1.13 · урок 106: Розкажіть про себе — перебудова: 12 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'fc1baff0-0e48-5676-bd3c-47d88d31e582';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Розкажіть про себе» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'b9fa04a2-e778-57c5-95d9-106b6058ad98') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'grammar', (select coalesce(jsonb_agg(lg.grammar_topic_id), '[]'::jsonb) from public.lesson_grammar lg where lg.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a1_v3: урок перебудовано за темою — стара версія (слова, вправи, діалоги, граматика)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 106: Розкажіть про себе', title_hr = 'Lekcija 106: Recite nešto o sebi',
         objectives = '["Розповісти про себе: podrijetlo, struka, osobine", "Описати свій характер на співбесіді й у новій компанії", "Теперішній час: zanimam se, radim, volim"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Теперішній час' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Теперішній час»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'podrijetlo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odrasti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'struka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zanimati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osobina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'znatiželjan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'komunikativan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pouzdan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'samouvjeren', v_pos);
  v_pos := pg_temp.word(v_lesson, 'samostalan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'strpljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otvoren', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd1d212c3-9e4f-5131-b738-3aa1a8fd2448', 'fill_in_the_blank', 'Ja se ___ za povijest.', 'zanimam', '["zanimaš", "zanimati", "zanima", "zanimam"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f8ac40fc-5b44-5050-89a3-6adb311e8e5d', 'multiple_choice', 'Що означає «samouvjeren»?', 'упевнений у собі', '["самостійний", "упевнений у собі", "риса (характеру)", "професія; спеціальність"]'::jsonb, 'A1', 2, 'PUBLISHED', 'samouvjeren', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4d2fb98f-3cc9-5aea-9dec-f36438a8ab5a', 'multiple_choice', 'Що означає «struka»?', 'професія; спеціальність', '["самостійний", "цікавитися", "професія; спеціальність", "походження"]'::jsonb, 'A1', 3, 'PUBLISHED', 'struka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8ba9db5c-8f0e-5189-8b5b-17a915c37e4a', 'multiple_choice', 'Що означає «otvoren»?', 'відчинений; відкритий (про людину)', '["професія; спеціальність", "походження", "відчинений; відкритий (про людину)", "риса (характеру)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'otvoren', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7f4a2718-02b3-5e29-8589-d5987116d830', 'multiple_choice', 'Як хорватською «риса (характеру)»?', 'osobina', '["komunikativan", "osobina", "samouvjeren", "zanimati se"]'::jsonb, 'A1', 5, 'PUBLISHED', 'osobina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '183e686c-8dc2-539b-b7e0-23b754a56133', 'multiple_choice', 'Як хорватською «терплячий»?', 'strpljiv', '["strpljiv", "samouvjeren", "osobina", "struka"]'::jsonb, 'A1', 6, 'PUBLISHED', 'strpljiv', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd86fdc1b-eb64-56d8-9016-cd7b5ee32bd1', 'type_answer', 'Напишіть хорватською: «комунікабельний»', 'komunikativan', null, 'A1', 7, 'PUBLISHED', 'komunikativan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '179bcf04-3d88-54ca-b2dc-c3eb09c79a4d', 'type_answer', 'Напишіть хорватською: «походження»', 'podrijetlo', null, 'A1', 8, 'PUBLISHED', 'podrijetlo', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '00b605f7-0e4b-53f6-8f9c-d02374932176', 'type_answer', 'Напишіть хорватською: «надійний»', 'pouzdan', null, 'A1', 9, 'PUBLISHED', 'pouzdan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f4a18c21-d47e-5351-b032-1bc400406ed2', 'sentence_builder', 'Складіть: «Я родом з України.»', 'Podrijetlom sam iz Ukrajine.', '["Podrijetlom", "Ukrajine.", "sam", "iz"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c3e4604-c1a3-5642-9686-b01c4251adf3', 'sentence_builder', 'Складіть: «Я виросла в Києві.»', 'Odrasla sam u Kijevu.', '["Odrasla", "Kijevu.", "u", "sam"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd2839d7f-b1a1-50af-9390-7a3e2019a91d', 'listening', 'Прослухайте і складіть фразу', 'Koja je vaša struka?', '["vaša", "je", "struka?", "Koja"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '60115e89-0ab5-5dd1-aefe-69b26efa9add', 'listening', 'Прослухайте і складіть фразу', 'Zanimam se za fotografiju i povijest.', '["se", "za", "fotografiju", "i", "povijest.", "Zanimam"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1b35929e-f6be-501e-9c0e-a0042f509d6b', 'speaking', 'Розкажіть про себе.', 'Recite nešto o sebi.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1eb4ebdf-f94d-5957-babb-e74c1b24ad88', 'speaking', 'Я надійна й терпляча.', 'Pouzdana sam i strpljiva.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b9fa04a2-e778-57c5-95d9-106b6058ad98', v_lesson, 'Співбесіда', 'Razgovor za posao', 4061, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('45c85edf-cfff-5178-acde-ff678e543aa6', 'b9fa04a2-e778-57c5-95d9-106b6058ad98', 'Gospođa Horvat', 'Recite nam nešto o sebi.', 'Розкажіть нам трохи про себе.', 1);
  perform pg_temp.turn('371a55dc-ec2c-54cf-9502-ed86dadf192c', 'b9fa04a2-e778-57c5-95d9-106b6058ad98', 'Daša', 'Zovem se Daša, podrijetlom sam iz Ukrajine. Odrasla sam u Poltavi.', 'Мене звати Даша, я родом з України. Я виросла в Полтаві.', 2);
  perform pg_temp.turn('0dd46a35-e56e-56c1-8181-8a8edbe4911c', 'b9fa04a2-e778-57c5-95d9-106b6058ad98', 'Gospođa Horvat', 'Koja je vaša struka?', 'Яка ваша спеціальність?', 3);
  perform pg_temp.turn('c1eed08b-85d8-5080-9550-ba74c90292de', 'b9fa04a2-e778-57c5-95d9-106b6058ad98', 'Daša', 'Po struci sam knjigovođa, a sada radim u trgovini.', 'За фахом я бухгалтерка, а зараз працюю в магазині.', 4);
  perform pg_temp.turn('24aeda21-e34d-559d-8f9a-9bfd18d7ef51', 'b9fa04a2-e778-57c5-95d9-106b6058ad98', 'Gospođa Horvat', 'Kako biste se opisali?', 'Як би ви себе описали?', 5);
  perform pg_temp.turn('0500467a-272a-5a20-9f72-6033ab32291f', 'b9fa04a2-e778-57c5-95d9-106b6058ad98', 'Daša', 'Pouzdana sam i samostalna, a kolege kažu da sam strpljiva.', 'Я надійна й самостійна, а колеги кажуть, що я терпляча.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a15297c0-8e78-5ba8-84aa-869bc8edc1f9', v_lesson, 'Нове знайомство', 'Novo poznanstvo', 4062, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('776453a6-0923-563f-932b-61ad429c579a', 'a15297c0-8e78-5ba8-84aa-869bc8edc1f9', 'Ivana', 'Darja, čime se baviš u slobodno vrijeme?', 'Даріє, чим ти займаєшся у вільний час?', 1);
  perform pg_temp.turn('976e22f4-2764-5dad-9d6c-48dee32113da', 'a15297c0-8e78-5ba8-84aa-869bc8edc1f9', 'Darja', 'Zanimam se za fotografiju i povijest.', 'Я цікавлюся фотографією та історією.', 2);
  perform pg_temp.turn('1370e97a-34c3-57ae-a6af-352a80424ac3', 'a15297c0-8e78-5ba8-84aa-869bc8edc1f9', 'Ivana', 'Vidi se da si znatiželjna!', 'Видно, що ти допитлива!', 3);
  perform pg_temp.turn('4847d2ac-3cf8-597f-8071-a65dc5ff87b1', 'a15297c0-8e78-5ba8-84aa-869bc8edc1f9', 'Darja', 'Jesam. A ti? Koja je tvoja najbolja osobina?', 'Так. А ти? Яка твоя найкраща риса?', 4);
  perform pg_temp.turn('a6542142-3534-5860-9aec-f137d6262686', 'a15297c0-8e78-5ba8-84aa-869bc8edc1f9', 'Ivana', 'Komunikativna sam, volim upoznavati nove ljude.', 'Я комунікабельна, люблю знайомитися з новими людьми.', 5);
  perform pg_temp.turn('0386ea0a-2e3c-5abf-b3b1-48bfc4230d83', 'a15297c0-8e78-5ba8-84aa-869bc8edc1f9', 'Darja', 'To se odmah vidi. I jako si otvorena.', 'Це одразу видно. І ти дуже відкрита.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.13 · урок 107: Як усе почалося: мій перший рік — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Як усе почалося: мій перший рік» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '06214e7d-ec07-5ebb-b954-880d91fc8414') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'grammar', (select coalesce(jsonb_agg(lg.grammar_topic_id), '[]'::jsonb) from public.lesson_grammar lg where lg.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a1_v3: урок перебудовано за темою — стара версія (слова, вправи, діалоги, граматика)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 107: Як усе почалося: мій перший рік', title_hr = 'Lekcija 107: Kako je sve počelo: moja prva godina',
         objectives = '["Розповісти про перший рік у Хорватії: doseliti se, snaći se, naviknuti se", "Поділитися спогадами й враженнями", "Минулий час: doselila sam se, snašla sam se, volontirala sam"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Минулий час: radio sam, bila sam»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'doseliti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'početak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'snaći se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naviknuti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'korak po korak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mentalitet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iznenaditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nedostajati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nostalgija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sjećati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sjećanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sprijateljiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'volontirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zajednica', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d995ce3-cfe6-5e1c-aba0-64a235ba58e3', 'fill_in_the_blank', 'Prije tri godine sam se ___ u Zagreb.', 'doselila', '["doseliti", "doseljavam", "doselim", "doselila"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'de7d5012-12ee-5464-9dbf-563a22771b98', 'multiple_choice', 'Що означає «sjećati se»?', 'пам’ятати, згадувати', '["менталітет", "початок", "пам’ятати, згадувати", "спільнота"]'::jsonb, 'A1', 2, 'PUBLISHED', 'sjećati se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e91e0bac-d4a9-5740-bf13-c41b17eb9c45', 'multiple_choice', 'Що означає «početak»?', 'початок', '["зорієнтуватися, дати раду", "здивувати", "бракувати; сумувати за", "початок"]'::jsonb, 'A1', 3, 'PUBLISHED', 'početak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '97283435-360d-598c-9f3c-7455e3ec2257', 'multiple_choice', 'Що означає «doseliti se»?', 'переселитися, переїхати (на проживання)', '["спогад", "здивувати", "переселитися, переїхати (на проживання)", "крок за кроком"]'::jsonb, 'A1', 4, 'PUBLISHED', 'doseliti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fcf33ff5-b50e-5092-a8b5-9e591b83912c', 'multiple_choice', 'Як хорватською «здивувати»?', 'iznenaditi', '["iznenaditi", "snaći se", "sjećanje", "volontirati"]'::jsonb, 'A1', 5, 'PUBLISHED', 'iznenaditi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cc32682b-a96a-56dd-8f3d-fe07a64fce2d', 'multiple_choice', 'Як хорватською «менталітет»?', 'mentalitet', '["doseliti se", "sjećati se", "mentalitet", "naviknuti se"]'::jsonb, 'A1', 6, 'PUBLISHED', 'mentalitet', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a9dfceaa-46d6-5831-bb5d-279aa2ad553b', 'type_answer', 'Напишіть хорватською: «ностальгія»', 'nostalgija', null, 'A1', 7, 'PUBLISHED', 'nostalgija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bd7af48b-c140-568f-8cef-1bfde903e9f2', 'type_answer', 'Напишіть хорватською: «спільнота»', 'zajednica', null, 'A1', 8, 'PUBLISHED', 'zajednica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '869d01d7-aac6-5797-b183-b45cf695600c', 'type_answer', 'Напишіть хорватською: «звикнути»', 'naviknuti se', null, 'A1', 9, 'PUBLISHED', 'naviknuti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e9d13791-1d4d-5ba4-8538-223a324b68c9', 'sentence_builder', 'Складіть: «Я швидко звикла.»', 'Brzo sam se navikla.', '["sam", "se", "navikla.", "Brzo"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cf1d4cdc-0fa8-5030-a474-af8cc435609a', 'sentence_builder', 'Складіть: «Я сумую за мамою.»', 'Nedostaje mi mama.', '["mi", "mama.", "Nedostaje"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd09e635c-d4c6-54aa-bec4-2c9263d6359b', 'listening', 'Прослухайте і складіть фразу', 'Što ti je bilo najteže?', '["je", "Što", "ti", "bilo", "najteže?"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9ad6a40d-0579-56d6-b2ab-5ee60743429e', 'listening', 'Прослухайте і складіть фразу', 'Kako si se sprijateljila s ljudima ovdje?', '["ovdje?", "s", "ljudima", "sprijateljila", "si", "se", "Kako"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2867eae8-9c3e-5dcc-8021-d07f7970fa94', 'speaking', 'Коли ти переїхала?', 'Kada si se doselila?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3234f2d0-5bd0-58c4-b3f8-c558d588a87c', 'speaking', 'Крок за кроком.', 'Korak po korak.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('06214e7d-ec07-5ebb-b954-880d91fc8414', v_lesson, 'Перший рік', 'Prva godina', 4071, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('15b0a709-7f96-5746-bf0e-b713c0025fc4', '06214e7d-ec07-5ebb-b954-880d91fc8414', 'Marko', 'Dašo, kad si se doselila u Hrvatsku?', 'Дашо, коли ти переїхала до Хорватії?', 1);
  perform pg_temp.turn('f3f21f52-a660-5454-920a-ee00aa2c857e', '06214e7d-ec07-5ebb-b954-880d91fc8414', 'Daša', 'Prije tri godine. Početak je bio jako težak.', 'Три роки тому. Початок був дуже важкий.', 2);
  perform pg_temp.turn('0eb8af30-382c-56ff-b6e7-f62b243b225b', '06214e7d-ec07-5ebb-b954-880d91fc8414', 'Marko', 'Što ti je bilo najteže?', 'Що тобі було найважче?', 3);
  perform pg_temp.turn('160d4950-5121-5830-9485-c18c81796262', '06214e7d-ec07-5ebb-b954-880d91fc8414', 'Daša', 'Jezik i papiri. Ali korak po korak, snašla sam se.', 'Мова й документи. Але крок за кроком я дала собі раду.', 4);
  perform pg_temp.turn('5dfb4381-8422-5b41-a74a-ddc6fe9fa85d', '06214e7d-ec07-5ebb-b954-880d91fc8414', 'Marko', 'A jesi li se brzo navikla na naš mentalitet?', 'А ти швидко звикла до нашого менталітету?', 5);
  perform pg_temp.turn('b8244a01-7187-5617-94b0-4cfb2fea7ec0', '06214e7d-ec07-5ebb-b954-880d91fc8414', 'Daša', 'Jesam! Iznenadilo me koliko ljudi ovdje imaju vremena za kavu.', 'Так! Мене здивувало, скільки часу люди тут мають на каву.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('62b972c4-97e7-521d-8ebe-cab1cd4fb779', v_lesson, 'Спогади', 'Sjećanja', 4072, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('05cb487d-6899-5a62-ab9b-4dcb08e8ceef', '62b972c4-97e7-521d-8ebe-cab1cd4fb779', 'Ivana', 'Darja, nedostaje li ti Ukrajina?', 'Даріє, ти сумуєш за Україною?', 1);
  perform pg_temp.turn('68c365b6-9865-58ab-94e5-cab824e60066', '62b972c4-97e7-521d-8ebe-cab1cd4fb779', 'Darja', 'Jako. Ponekad imam nostalgiju, sjećam se mame i našeg vrta.', 'Дуже. Іноді в мене ностальгія, я згадую маму й наш сад.', 2);
  perform pg_temp.turn('728b7dbe-e041-5d06-82c1-7e4ebd69f3b0', '62b972c4-97e7-521d-8ebe-cab1cd4fb779', 'Ivana', 'Kako si se sprijateljila s ljudima ovdje?', 'Як ти тут подружилася з людьми?', 3);
  perform pg_temp.turn('1c63a4e5-45b2-51d1-89c3-c78186cbe887', '62b972c4-97e7-521d-8ebe-cab1cd4fb779', 'Darja', 'Volontirala sam u udruzi, a ondje je divna zajednica.', 'Я волонтерила в організації, а там чудова спільнота.', 4);
  perform pg_temp.turn('ff59b0bc-0898-534c-a4e2-1ab3a4bf948e', '62b972c4-97e7-521d-8ebe-cab1cd4fb779', 'Ivana', 'Koje ti je najljepše sjećanje iz prve godine?', 'Який у тебе найгарніший спогад з першого року?', 5);
  perform pg_temp.turn('3f2b8b8a-a371-52c4-a887-3c0369b35956', '62b972c4-97e7-521d-8ebe-cab1cd4fb779', 'Darja', 'Prvi Božić s novim prijateljima, bili smo kao obitelj.', 'Перше Різдво з новими друзями, ми були як сім’я.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.13 · урок 108: Нове життя: мої плани — перебудова: 17 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'dbb91fa1-4a97-5c04-99a8-8ac1d508b952';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Нове життя: мої плани» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '8a321ba0-fbba-516c-b876-01ab778fe7b9') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'grammar', (select coalesce(jsonb_agg(lg.grammar_topic_id), '[]'::jsonb) from public.lesson_grammar lg where lg.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a1_v3: урок перебудовано за темою — стара версія (слова, вправи, діалоги, граматика)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 108: Нове життя: мої плани', title_hr = 'Lekcija 108: Novi život: moji planovi',
         objectives = '["Розповісти про плани й цілі: cilj, postati, usavršiti, napredovati", "Порадити новоприбулим, обговорити переваги й недоліки", "Майбутній час: ostat ću, usavršit ću, uspjet ćeš"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Майбутній час: ići ću, bit će' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Майбутній час: ići ću, bit će»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'cilj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'budućnost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'usavršiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tečno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'napredovati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'postati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uspjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uspjeh', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ostvariti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izazov', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nadati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odlučiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ostati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'domovina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prednost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nedostatak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'savjet', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '16805efa-62dc-5c49-995a-f479b7193533', 'fill_in_the_blank', 'Sljedeće godine ___ položiti ispit.', 'ću', '["ćeš li", "ću", "bih", "sam"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7137c5b3-0d0b-585e-8e15-e785552b7581', 'multiple_choice', 'Що означає «tečno»?', 'вільно (про мову)', '["вільно (про мову)", "стати (кимось, чимось)", "вдосконалити", "успіх"]'::jsonb, 'A1', 2, 'PUBLISHED', 'tečno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'de454037-b7eb-5780-bf73-41a825af17e5', 'multiple_choice', 'Що означає «postati»?', 'стати (кимось, чимось)', '["сподіватися", "майбутнє", "успіх", "стати (кимось, чимось)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'postati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '12db305c-ba3c-5b88-9378-89b9a776426a', 'multiple_choice', 'Що означає «ostati»?', 'залишитися', '["вільно (про мову)", "порада", "батьківщина", "залишитися"]'::jsonb, 'A1', 4, 'PUBLISHED', 'ostati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d69f2e6-653e-554d-a207-cdae0fd11228', 'multiple_choice', 'Як хорватською «успіх»?', 'uspjeh', '["postati", "uspjeh", "savjet", "nedostatak"]'::jsonb, 'A1', 5, 'PUBLISHED', 'uspjeh', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '191ef04b-7c9f-5a70-9861-a1a53fd61829', 'multiple_choice', 'Як хорватською «перевага»?', 'prednost', '["postati", "ostati", "prednost", "napredovati"]'::jsonb, 'A1', 6, 'PUBLISHED', 'prednost', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '267bcc70-8252-59b3-981d-b42651551629', 'type_answer', 'Напишіть хорватською: «вирішити»', 'odlučiti', null, 'A1', 7, 'PUBLISHED', 'odlučiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '28c37d8e-71dc-59be-8a77-6669694d665e', 'type_answer', 'Напишіть хорватською: «порада»', 'savjet', null, 'A1', 8, 'PUBLISHED', 'savjet', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '101fb0e4-5fd7-5032-aca6-7065944d2f05', 'type_answer', 'Напишіть хорватською: «сподіватися»', 'nadati se', null, 'A1', 9, 'PUBLISHED', 'nadati se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '531f7693-06e1-5ddd-9747-eec8d21e55b0', 'sentence_builder', 'Складіть: «Я залишуся в Хорватії.»', 'Ostat ću u Hrvatskoj.', '["u", "Ostat", "ću", "Hrvatskoj."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '21a70462-cb4b-5927-b19a-cc4a05b25264', 'sentence_builder', 'Складіть: «Я сподіваюся на успіх.»', 'Nadam se uspjehu.', '["uspjehu.", "se", "Nadam"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f7811658-159e-53f6-abb5-bfc4ecfb5afa', 'listening', 'Прослухайте і складіть фразу', 'A posao?', '["posao?", "A"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4d0065b6-04f4-5615-90ba-8d04f14a18fe', 'listening', 'Прослухайте і складіть фразу', 'Koja je najveća prednost života ovdje?', '["prednost", "najveća", "ovdje?", "Koja", "je", "života"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '47a77aea-f6f3-5293-a073-02ae44023b5d', 'speaking', 'Які твої цілі?', 'Koji su tvoji ciljevi?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0d3dc0cc-3d3f-5f92-ae3c-2218ff0360d1', 'speaking', 'Я вдосконалю хорватську.', 'Usavršit ću hrvatski.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8a321ba0-fbba-516c-b876-01ab778fe7b9', v_lesson, 'Плани на рік', 'Planovi za godinu', 4081, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('dfa38ddd-335b-55bb-8643-e3ff5d07cfa2', '8a321ba0-fbba-516c-b876-01ab778fe7b9', 'Luka', 'Dašo, koji su tvoji ciljevi za sljedeću godinu?', 'Дашо, які в тебе цілі на наступний рік?', 1);
  perform pg_temp.turn('3ed2124a-f7be-5db2-a784-4d650ab66be9', '8a321ba0-fbba-516c-b876-01ab778fe7b9', 'Daša', 'Usavršit ću hrvatski i položiti ispit B1.', 'Я вдосконалю хорватську й складу іспит B1.', 2);
  perform pg_temp.turn('f34b8d52-d893-5863-92bb-ff21d842171a', '8a321ba0-fbba-516c-b876-01ab778fe7b9', 'Luka', 'A posao?', 'А робота?', 3);
  perform pg_temp.turn('9f7d9b5f-2606-5874-8383-851c35eee57f', '8a321ba0-fbba-516c-b876-01ab778fe7b9', 'Daša', 'Nadam se da ću napredovati i postati voditeljica smjene.', 'Сподіваюся, що просунуся й стану керівницею зміни.', 4);
  perform pg_temp.turn('18a50d5a-f098-5c5e-8210-070df3c6676c', '8a321ba0-fbba-516c-b876-01ab778fe7b9', 'Luka', 'Uspjet ćeš, ti si jako vrijedna!', 'У тебе вийде, ти дуже працьовита!', 5);
  perform pg_temp.turn('37bacb6d-dfc6-5f3e-ad6f-d8bac11fa474', '8a321ba0-fbba-516c-b876-01ab778fe7b9', 'Daša', 'Hvala, to mi je velik izazov.', 'Дякую, для мене це великий виклик.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d039705e-bb67-5364-a0d9-cd0522f1d966', v_lesson, 'Залишитися чи ні?', 'Ostati ili ne?', 4082, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('9e072cc9-ab02-5304-b310-7263f79710e5', 'd039705e-bb67-5364-a0d9-cd0522f1d966', 'Marko', 'Darja, hoćeš li ostati u Hrvatskoj?', 'Даріє, ти залишишся в Хорватії?', 1);
  perform pg_temp.turn('c0f7b9e0-7904-5bc4-b9e6-a2fd760b8523', 'd039705e-bb67-5364-a0d9-cd0522f1d966', 'Darja', 'Još nisam odlučila. Domovina mi je u srcu, ali ovdje vidim budućnost za djecu.', 'Я ще не вирішила. Батьківщина в моєму серці, але тут я бачу майбутнє для дітей.', 2);
  perform pg_temp.turn('6bf80c2e-0c5d-5626-81c0-a8dc22a56b5c', 'd039705e-bb67-5364-a0d9-cd0522f1d966', 'Marko', 'Koja je najveća prednost života ovdje?', 'Яка найбільша перевага життя тут?', 3);
  perform pg_temp.turn('fa6838ec-8ec5-5d01-931d-4351339185e8', 'd039705e-bb67-5364-a0d9-cd0522f1d966', 'Darja', 'Sigurnost i more. A nedostatak — birokracija!', 'Безпека й море. А недолік — бюрократія!', 4);
  perform pg_temp.turn('48b314a9-4183-5fef-a898-e1c9b66617c6', 'd039705e-bb67-5364-a0d9-cd0522f1d966', 'Marko', 'Imaš li neki savjet za one koji tek dolaze?', 'Маєш якусь пораду для тих, хто тільки приїжджає?', 5);
  perform pg_temp.turn('51bcaab2-832d-5963-b955-863dd298ce86', 'd039705e-bb67-5364-a0d9-cd0522f1d966', 'Darja', 'Učite jezik od prvog dana. Za godinu dana bit će vam puno lakše!', 'Вчіть мову з першого дня. За рік вам буде набагато легше!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- 3. Нові уроки модуля A1.13
-- Наскрізні номери всіх уроків A1 («Урок N: …» / «Lekcija N: …»); стара назва — у content_versions
do $$
declare r record; v_payload jsonb; v_new_ua text; v_new_hr text;
begin
  for r in select l.id, l.title_ua, l.title_hr,
                  row_number() over (order by m.order_index, u.order_index, l.order_index) as n
             from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
            where m.level_code = 'A1' and l.status = 'PUBLISHED' loop
    v_new_ua := regexp_replace(r.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':');
    v_new_hr := regexp_replace(r.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':');
    if v_new_ua is not distinct from r.title_ua and v_new_hr is not distinct from r.title_hr then continue; end if;
    select to_jsonb(l) into v_payload from public.lessons l where l.id = r.id;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'curriculum_a1_v3: новий номер уроку ' || r.n);
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;

-- 5. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_order int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('fc1baff0-0e48-5676-bd3c-47d88d31e582', '4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d', 'dbb91fa1-4a97-5c04-99a8-8ac1d508b952')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 10 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_order from (values ('fc1baff0-0e48-5676-bd3c-47d88d31e582'::uuid, 1), ('4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d'::uuid, 2), ('dbb91fa1-4a97-5c04-99a8-8ac1d508b952'::uuid, 3)) as t(id, o)
    join public.lessons l on l.id = t.id and l.order_index = t.o and l.unit_id = '90bce36b-b9de-5168-b120-49d8e33aa6cf';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A1' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('fc1baff0-0e48-5676-bd3c-47d88d31e582', '4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d', 'dbb91fa1-4a97-5c04-99a8-8ac1d508b952') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A1.13: % уроків з неправильним складом', v_bad; end if;
  if v_order <> 3 then raise exception 'Модуль A1.13: на своїх місцях % уроків з 3', v_order; end if;
  if v_titles > 0 then raise exception 'A1: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A1.13: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A1.13 — 3 уроки за темою (3 перебудовано, 0 нових)';
end $$;

commit;
