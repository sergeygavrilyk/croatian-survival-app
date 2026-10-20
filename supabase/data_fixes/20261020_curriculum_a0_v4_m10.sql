-- =====================================================================
-- Уроки A0 за темою · curriculum_a0_v4 · модуль A0.10 · 2026-10-20
-- Згенеровано: python3 scripts/gen_curriculum_a0_v4.py (не редагуйте вручну).
--
-- Рішення власника 2026-10-15: слова уроку — за темою уроку, 20–25 слів і виразів, діалоги під тему; бета (PUBLISHED).
--   * Уроки 60–66: 5 наявних перебудовано, 2 нових тематичних уроків. Слів у них: 150.
--     Кожен: 20–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 32.
--   * Нові теми граматики: «Що болить? Boli me…, bole me…».
--   * Виправлено переклад: nesreća — «нещастя; аварія, нещасний випадок», prijava — «реєстрація; заява (в поліцію, установу)» (стара версія — у content_versions).
--   * Новий порядок уроків у модулі; назви всіх уроків A0 перенумеровано підряд (разом 66).
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
values ('jednokrevetna soba', 'jednokrevetna soba', 'hr', 'phrase', 'A0', 'одномісний номер', 'collocation', '{"gender": "f"}'::jsonb, '["Trebam jednokrevetnu sobu za tri noći."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dvokrevetna soba', 'dvokrevetna soba', 'hr', 'phrase', 'A0', 'двомісний номер', 'collocation', '{"gender": "f"}'::jsonb, '["Imate li slobodnu dvokrevetnu sobu za vikend?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sef', 'sef', 'hr', 'noun', 'A0', 'сейф', 'core', '{"gender": "m"}'::jsonb, '["Putovnicu možete ostaviti u sefu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odsjesti', 'odsjesti', 'hr', 'verb', 'A0', 'зупинитися (в готелі, у когось)', 'core', '{"aspect": "pf", "present": {"1s": "odsjednem", "2s": "odsjedneš", "3s": "odsjedne"}, "past": "odsjeo"}'::jsonb, '["Odsjeli smo u malom hotelu blizu plaže."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prenoćiti', 'prenociti', 'hr', 'verb', 'A0', 'переночувати', 'core', '{"aspect": "pf", "present": {"1s": "prenoćim", "2s": "prenoćiš", "3s": "prenoći"}, "past": "prenoćio"}'::jsonb, '["Možemo li prenoćiti kod vas samo jednu noć?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('lakat', 'lakat', 'hr', 'noun', 'A0', 'лікоть', 'core', '{"gender": "m", "plural": "laktovi"}'::jsonb, '["Udario sam se u lakat."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prsa', 'prsa', 'hr', 'noun', 'A0', 'груди', 'core', '{"gender": "n_pl"}'::jsonb, '["Bole me prsa kad duboko dišem."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stopalo', 'stopalo', 'hr', 'noun', 'A0', 'стопа', 'core', '{"gender": "n", "plural": "stopala"}'::jsonb, '["Nakon duge šetnje bole me stopala."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('protiv bolova', 'protiv bolova', 'hr', 'phrase', 'A0', 'від болю (знеболювальне)', 'chunk', '{}'::jsonb, '["Imate li nešto protiv bolova?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ozlijeđen', 'ozlijeden', 'hr', 'adjective', 'A0', 'поранений, травмований', 'core', '{"f": "ozlijeđena", "n": "ozlijeđeno"}'::jsonb, '["Je li netko ozlijeđen?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('onesvijestiti se', 'onesvijestiti se', 'hr', 'verb', 'A0', 'знепритомніти', 'core', '{"aspect": "pf", "present": {"3s": "onesvijesti se"}, "past": "onesvijestio se"}'::jsonb, '["Jedna se gospođa onesvijestila u tramvaju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ukrasti', 'ukrasti', 'hr', 'verb', 'A0', 'украсти', 'core', '{"aspect": "pf", "present": {"1s": "ukradem", "2s": "ukradeš", "3s": "ukrade"}, "past": "ukrao"}'::jsonb, '["Netko mi je ukrao mobitel."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('džeparoš', 'dzeparos', 'hr', 'noun', 'A0', 'кишеньковий злодій', 'core', '{"gender": "m"}'::jsonb, '["Pazite na torbu, u tramvaju ima džeparoša."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('blokirati', 'blokirati', 'hr', 'verb', 'A0', 'заблокувати', 'core', '{"aspect": "biasp", "present": {"1s": "blokiram", "3s": "blokira"}}'::jsonb, '["Odmah sam blokirala karticu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zapisnik', 'zapisnik', 'hr', 'noun', 'A0', 'протокол', 'core', '{"gender": "m"}'::jsonb, '["Policajac piše zapisnik o krađi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('provala', 'provala', 'hr', 'noun', 'A0', 'квартирна крадіжка, злам', 'core', '{"gender": "f"}'::jsonb, '["Susjedi su prijavili provalu u stan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sumnjiv', 'sumnjiv', 'hr', 'adjective', 'A0', 'підозрілий', 'core', '{"f": "sumnjiva", "n": "sumnjivo"}'::jsonb, '["Ispred zgrade stoji neki sumnjiv auto."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odjednom', 'odjednom', 'hr', 'adverb', 'A0', 'раптом', 'core', '{}'::jsonb, '["Odjednom je netko povukao moju torbu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('osobni podaci', 'osobni podaci', 'hr', 'phrase', 'A0', 'особисті дані', 'collocation', '{"gender": "m_pl"}'::jsonb, '["Upišite svoje osobne podatke u obrazac."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mjesto rođenja', 'mjesto rodenja', 'hr', 'phrase', 'A0', 'місце народження', 'collocation', '{"gender": "n"}'::jsonb, '["Moje mjesto rođenja je Lavov."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('spol', 'spol', 'hr', 'noun', 'A0', 'стать', 'core', '{"gender": "m"}'::jsonb, '["U obrascu označite spol."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('muški', 'muski', 'hr', 'adjective', 'A0', 'чоловічий', 'core', '{"f": "muška", "n": "muško"}'::jsonb, '["Muški zahod je lijevo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ženski', 'zenski', 'hr', 'adjective', 'A0', 'жіночий', 'core', '{"f": "ženska", "n": "žensko"}'::jsonb, '["Ženska odjeća je na prvom katu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bračno stanje', 'bracno stanje', 'hr', 'phrase', 'A0', 'сімейний стан', 'collocation', '{"gender": "n"}'::jsonb, '["U obrascu pitaju i za bračno stanje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('e-pošta', 'e-posta', 'hr', 'noun', 'A0', 'електронна пошта', 'core', '{"gender": "f"}'::jsonb, '["Potvrdu ćemo vam poslati e-poštom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tiskanim slovima', 'tiskanim slovima', 'hr', 'phrase', 'A0', 'друкованими літерами', 'chunk', '{}'::jsonb, '["Ime i prezime napišite tiskanim slovima."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rubrika', 'rubrika', 'hr', 'noun', 'A0', 'графа, поле (у бланку)', 'core', '{"gender": "f"}'::jsonb, '["Ovu rubriku ne trebate ispuniti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ovjeriti', 'ovjeriti', 'hr', 'verb', 'A0', 'засвідчити (печаткою, у нотаріуса)', 'core', '{"aspect": "pf", "present": {"1s": "ovjerim", "3s": "ovjeri"}, "past": "ovjerio"}'::jsonb, '["Kopiju diplome morate ovjeriti kod javnog bilježnika."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('obvezno', 'obvezno', 'hr', 'adverb', 'A0', 'обов’язково', 'core', '{}'::jsonb, '["Polja sa zvjezdicom obvezno ispunite."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('privremeni boravak', 'privremeni boravak', 'hr', 'phrase', 'A0', 'тимчасове проживання (дозвіл)', 'collocation', '{"gender": "m"}'::jsonb, '["Predala sam zahtjev za privremeni boravak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uplatiti', 'uplatiti', 'hr', 'verb', 'A0', 'сплатити (у банку, переказом)', 'core', '{"aspect": "pf", "present": {"1s": "uplatim", "3s": "uplati"}, "past": "uplatio"}'::jsonb, '["Pristojbu možete uplatiti u banci ili na pošti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('osobno', 'osobno', 'hr', 'adverb', 'A0', 'особисто', 'core', '{}'::jsonb, '["Zahtjev morate predati osobno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;

-- 1а. Нові теми граматики A0 (1)
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'b587f1b6-5840-5471-a70e-fcdd69330d0f', 'A0', 'Що болить? Boli me…, bole me…', 'Što te boli? Boli me…, bole me…', 'Як сказати, що болить: boli me + те, що болить (називний відмінок); boli / bole; питання Što vas boli?', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Що болить? Boli me…, bole me…');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'c550c68d-502f-5ded-bcbf-7b0e298c58c5', 'b587f1b6-5840-5471-a70e-fcdd69330d0f', 'Мене болить: boli me', 'Те, що болить, — підмет (називний відмінок), а людина — у знахідному: boli me glava — дослівно «болить мене голова». Займенники: me, te, ga, je, nas, vas, ih. Ім’я теж у знахідному: Dašu boli koljeno.', 'Boli me glava. · Boli ga zub. · Dašu boli koljeno.', '[{"hr": "Boli me grlo.", "ua": "У мене болить горло."}, {"hr": "Dašu boli koljeno.", "ua": "У Даші болить коліно."}, {"hr": "Boli li te trbuh?", "ua": "У тебе болить живіт?"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = 'b587f1b6-5840-5471-a70e-fcdd69330d0f')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '10e74809-c39c-5050-9db6-fdd05204d03a', 'b587f1b6-5840-5471-a70e-fcdd69330d0f', 'Болить чи болять: boli / bole', 'Дієслово узгоджується з тим, що болить: однина — boli, множина — bole. Leđa (спина) і prsa (груди) — лише множина, тому bole me leđa, bole me prsa.', 'Boli me noga. → Bole me noge.', '[{"hr": "Bole me leđa.", "ua": "У мене болить спина."}, {"hr": "Bole me zubi.", "ua": "У мене болять зуби."}, {"hr": "Nakon šetnje bole me stopala.", "ua": "Після прогулянки в мене болять стопи."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = 'b587f1b6-5840-5471-a70e-fcdd69330d0f')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '8af4a061-9579-5a1a-b79c-cbfb2d92543a', 'b587f1b6-5840-5471-a70e-fcdd69330d0f', 'Що болить? Питання й заперечення', 'Питаємо Što vas boli? або Gdje vas boli? (до знайомих — te). Заперечення — ne перед дієсловом: Ne boli me. Više me ne boli — уже не болить.', 'Što vas boli? · Gdje te boli? · Ne boli me.', '[{"hr": "Što vas boli?", "ua": "Що у вас болить?"}, {"hr": "Gdje te boli?", "ua": "Де в тебе болить?"}, {"hr": "Više me ne boli.", "ua": "Мені вже не болить."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = 'b587f1b6-5840-5471-a70e-fcdd69330d0f')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', 'b587f1b6-5840-5471-a70e-fcdd69330d0f', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нова тема граматики A0 для уроків за темою (curriculum_a0_v4) за запитом власника 2026-10-19. Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = 'b587f1b6-5840-5471-a70e-fcdd69330d0f')
  and not exists (select 1 from public.content_reviews where entity_id = 'b587f1b6-5840-5471-a70e-fcdd69330d0f' and notes = 'Бета: нова тема граматики A0 для уроків за темою (curriculum_a0_v4) за запитом власника 2026-10-19. Потрібна перевірка носієм.');

-- 1б. Виправлені переклади наявних слів (2); повторний запуск нічого не змінює
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'nesreća' and ukrainian_translation = 'нещастя' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a0_v4: виправлено переклад слова (додано значення за темою уроку) — стара версія');
    update public.lexemes set ukrainian_translation = 'нещастя; аварія, нещасний випадок' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'prijava' and ukrainian_translation = 'реєстрація / заява / донос' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a0_v4: виправлено переклад слова (додано значення за темою уроку) — стара версія');
    update public.lexemes set ukrainian_translation = 'реєстрація; заява (в поліцію, установу)' where id = r.id;
  end loop;
end $$;

-- 2. Перебудова наявних уроків модуля A0.10
-- A0.10 · урок 60: У готелі — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'edbae9ca-c4f4-575d-b876-d50b0a1fd9b5';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «У готелі» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '471adf39-c211-5977-9ac4-a1d6a48416ba') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 60: У готелі', title_hr = 'Lekcija 60: U hotelu',
         objectives = '["Забронювати й попросити номер: jednokrevetna soba, dvokrevetna soba", "Поселитися й виселитися: prijava, odjava, putovnica", "Запитати про сніданок, пароль від Wi-Fi і сейф"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'hotel', v_pos);
  v_pos := pg_temp.word(v_lesson, 'recepcija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smještaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'apartman', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hostel', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rezervacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jednokrevetna soba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dvokrevetna soba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'noćenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odjava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'putovnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uključen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ručnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sapun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lozinka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sef', v_pos);
  v_pos := pg_temp.word(v_lesson, 'domaćin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odsjesti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prenoćiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'buka', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '5d61bfe5-204e-5fde-b725-ec6cef16574c', 'fill_in_the_blank', 'Imate li slobodnu ___ sobu?', 'dvokrevetnu', '["dvokrevetne", "dvokrevetnu", "dvokrevetnom", "dvokrevetna"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aeab385f-9369-52fc-b91b-261205dd1e9b', 'multiple_choice', 'Що означає «recepcija»?', 'рецепція', '["рецепція", "пароль", "хостел", "шум"]'::jsonb, 'A0', 2, 'PUBLISHED', 'recepcija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '28d81be8-5231-57ce-bfee-911e747cbb7b', 'multiple_choice', 'Що означає «rezervacija»?', 'бронювання / резерв', '["одномісний номер", "житло / розміщення", "бронювання / резерв", "зупинитися (в готелі, у когось)"]'::jsonb, 'A0', 3, 'PUBLISHED', 'rezervacija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ef2b9a3-e541-58fe-91e3-56f73d733dd1', 'multiple_choice', 'Що означає «odjava»?', 'виселення (check-out)', '["зупинитися (в готелі, у когось)", "виселення (check-out)", "бронювання / резерв", "шум"]'::jsonb, 'A0', 4, 'PUBLISHED', 'odjava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a47cfc2c-f9b3-5640-be60-9f447dbf31c7', 'multiple_choice', 'Як хорватською «сейф»?', 'sef', '["domaćin", "sef", "hotel", "dvokrevetna soba"]'::jsonb, 'A0', 5, 'PUBLISHED', 'sef', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '05c5ddee-6695-5795-bc0f-42c796b1d908', 'multiple_choice', 'Як хорватською «гість / відвідувач»?', 'gost', '["hostel", "smještaj", "gost", "dvokrevetna soba"]'::jsonb, 'A0', 6, 'PUBLISHED', 'gost', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '10e832dc-b1f1-5825-b6a1-b3e99a3aa64e', 'type_answer', 'Напишіть хорватською: «хостел»', 'hostel', null, 'A0', 7, 'PUBLISHED', 'hostel', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c81eb45c-9780-5368-9d46-e264e4177845', 'type_answer', 'Напишіть хорватською: «ночівля»', 'noćenje', null, 'A0', 8, 'PUBLISHED', 'noćenje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '887394b7-fc12-551e-99e3-fec914071217', 'type_answer', 'Напишіть хорватською: «закордонний паспорт»', 'putovnica', null, 'A0', 9, 'PUBLISHED', 'putovnica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '02924c8c-6f14-52d3-bfeb-6b4d195fd84b', 'sentence_builder', 'Складіть: «Я хочу забронювати двомісний номер.»', 'Želim rezervirati dvokrevetnu sobu.', '["dvokrevetnu", "rezervirati", "Želim", "sobu."]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9018f7b1-cf30-5870-a9dd-0eedd6559145', 'sentence_builder', 'Складіть: «Ми зупинилися в приватних апартаментах.»', 'Odsjeli smo u privatnom apartmanu.', '["smo", "u", "apartmanu.", "Odsjeli", "privatnom"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bace6be4-0d20-53b7-9ee0-b3317ac73299', 'listening', 'Прослухайте і складіть фразу', 'Je li doručak uključen u cijenu?', '["u", "cijenu?", "li", "Je", "doručak", "uključen"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '897a953c-6c39-5c5c-8308-719c66a61e5c', 'listening', 'Прослухайте і складіть фразу', 'Koja je lozinka za Wi-Fi?', '["Wi-Fi?", "Koja", "lozinka", "je", "za"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eaadd30e-6453-58d2-91eb-5bb9d05ede95', 'speaking', 'У мене бронювання.', 'Imam rezervaciju.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eea1c47c-bf14-57ff-831e-a0af77c5cf3c', 'speaking', 'Можна залишити речі на рецепції?', 'Mogu li ostaviti stvari na recepciji?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('471adf39-c211-5977-9ac4-a1d6a48416ba', v_lesson, 'На рецепції', 'Na recepciji', 2601, 'A0', 'travel', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('1d477b53-bb33-5831-84a6-1c4b86f714af', '471adf39-c211-5977-9ac4-a1d6a48416ba', 'Daša', 'Dobar dan, imam rezervaciju na ime Daša Kovalenko.', 'Добрий день, у мене бронювання на ім’я Даша Коваленко.', 1);
  perform pg_temp.turn('a01a23ed-c437-57fa-899d-12d5c0db960e', '471adf39-c211-5977-9ac4-a1d6a48416ba', 'Ivana', 'Dobro došli! Jednokrevetna soba za tri noćenja, je li tako?', 'Ласкаво просимо! Одномісний номер на три ночі, так?', 2);
  perform pg_temp.turn('82ec2f6b-7113-5874-ae0f-34f13e181184', '471adf39-c211-5977-9ac4-a1d6a48416ba', 'Daša', 'Da. Je li doručak uključen u cijenu?', 'Так. Сніданок входить у вартість?', 3);
  perform pg_temp.turn('17a08c84-ba19-5566-8a74-3ec6d6487f6f', '471adf39-c211-5977-9ac4-a1d6a48416ba', 'Ivana', 'Jest, od sedam do deset. Trebam vašu putovnicu za prijavu.', 'Так, із сьомої до десятої. Мені потрібен ваш паспорт для реєстрації.', 4);
  perform pg_temp.turn('66991d62-396a-533b-9c06-50088a2a38dd', '471adf39-c211-5977-9ac4-a1d6a48416ba', 'Daša', 'Izvolite. Do kada je odjava?', 'Прошу. До котрої треба виселитися?', 5);
  perform pg_temp.turn('a6219648-d5d3-5556-bcce-b47e7bc2c29f', '471adf39-c211-5977-9ac4-a1d6a48416ba', 'Ivana', 'Do jedanaest sati. Ovo je vaš ključ, soba dvjesto pet.', 'До одинадцятої. Ось ваш ключ, номер двісті п’ять.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('da028a94-ff9d-5425-ae8e-cbe269d0a5f8', v_lesson, 'Проблема в номері', 'Problem u sobi', 2602, 'A0', 'travel', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('f06d3736-3436-51b2-8118-33cbc89692ca', 'da028a94-ff9d-5425-ae8e-cbe269d0a5f8', 'Darja', 'Oprostite, u sobi nema ručnika ni sapuna.', 'Перепрошую, у номері немає ні рушника, ні мила.', 1);
  perform pg_temp.turn('f73f5f0f-b083-5fca-bd2a-b42f81f139f0', 'da028a94-ff9d-5425-ae8e-cbe269d0a5f8', 'Marko', 'Ispričavam se! Odmah ću vam ih donijeti.', 'Перепрошую! Зараз вам їх принесу.', 2);
  perform pg_temp.turn('f67e0ab4-1624-595e-bb9f-e1a398d7de2a', 'da028a94-ff9d-5425-ae8e-cbe269d0a5f8', 'Darja', 'Hvala. Koja je lozinka za Wi-Fi?', 'Дякую. Який пароль від Wi-Fi?', 3);
  perform pg_temp.turn('96c1c39d-5b5b-50e3-929c-1589d5fbf7cd', 'da028a94-ff9d-5425-ae8e-cbe269d0a5f8', 'Marko', 'Piše na kartici pored kreveta.', 'Він написаний на картці біля ліжка.', 4);
  perform pg_temp.turn('8ff6277c-dc6e-5dea-9591-a8ffcd9c3dd4', 'da028a94-ff9d-5425-ae8e-cbe269d0a5f8', 'Darja', 'I još nešto: sef ne radi, a s ulice se čuje velika buka.', 'І ще одне: сейф не працює, а з вулиці дуже шумно.', 5);
  perform pg_temp.turn('55d3bfdd-b8ed-5a10-b6e7-fb52ec5f8568', 'da028a94-ff9d-5425-ae8e-cbe269d0a5f8', 'Marko', 'Možemo vam dati drugu sobu, s pogledom na dvorište.', 'Можемо дати вам інший номер, з видом на двір.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.10 · урок 62: У лікаря й в аптеці — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'fbc71f82-e715-5bab-a990-b8542fb0fe01';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «У лікаря й в аптеці» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '97d743bb-68c8-52f6-977f-92001bd6037c') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 62: У лікаря й в аптеці', title_hr = 'Lekcija 62: Kod liječnika i u ljekarni',
         objectives = '["Записатися до лікаря й розповісти про симптоми: imam temperaturu, kašalj", "Зрозуміти лікаря: recept, uputnica, bolovanje", "Купити ліки в аптеці й запитати, як їх приймати"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'liječnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljekarna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljekarnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dom zdravlja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ambulanta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pregled', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uputnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zdravstveno osiguranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naručiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'recept', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lijek', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tableta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sirup', v_pos);
  v_pos := pg_temp.word(v_lesson, 'protiv bolova', v_pos);
  v_pos := pg_temp.word(v_lesson, 'temperatura', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prehlada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gripa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kašalj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'alergija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tlak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dnevno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bolovanje', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '639796cb-ca34-5486-9c16-4fa9a3bdc85b', 'fill_in_the_blank', 'Imam ___ i kašalj.', 'temperaturu', '["temperature", "temperaturom", "temperaturu", "temperatura"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f68a9298-6710-5236-8b44-c752a862f24e', 'multiple_choice', 'Що означає «recept»?', 'рецепт', '["провізор / фармацевт", "рецепт", "грип", "медичний огляд / обстеження"]'::jsonb, 'A0', 2, 'PUBLISHED', 'recept', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '306a86f6-5c4f-5577-abc8-956bea6a27ff', 'multiple_choice', 'Що означає «pregled»?', 'медичний огляд / обстеження', '["поліклініка", "тиск", "ліки / медикамент", "медичний огляд / обстеження"]'::jsonb, 'A0', 3, 'PUBLISHED', 'pregled', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9e2baa42-6c5a-58e2-9917-08686ca1d242', 'multiple_choice', 'Що означає «ambulanta»?', 'амбулаторія', '["лікар", "амбулаторія", "ліки / медикамент", "поліклініка"]'::jsonb, 'A0', 4, 'PUBLISHED', 'ambulanta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '298d28f3-ac07-558e-8416-7909f75f540c', 'multiple_choice', 'Як хорватською «поліклініка»?', 'dom zdravlja', '["bolovanje", "sirup", "dom zdravlja", "gripa"]'::jsonb, 'A0', 5, 'PUBLISHED', 'dom zdravlja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2073170a-ade8-5736-9461-d429a946c28e', 'multiple_choice', 'Як хорватською «таблетка»?', 'tableta', '["tableta", "alergija", "zdravstveno osiguranje", "prehlada"]'::jsonb, 'A0', 6, 'PUBLISHED', 'tableta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e015965e-a124-593d-b847-e24610f7040b', 'type_answer', 'Напишіть хорватською: «температура (жар)»', 'temperatura', null, 'A0', 7, 'PUBLISHED', 'temperatura', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0d8b677f-3a7a-5bbd-a48a-e098fa6a0715', 'type_answer', 'Напишіть хорватською: «сироп»', 'sirup', null, 'A0', 8, 'PUBLISHED', 'sirup', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1ae1d0d1-98ca-5f1a-beba-4ef8ac80e68c', 'type_answer', 'Напишіть хорватською: «застуда»', 'prehlada', null, 'A0', 9, 'PUBLISHED', 'prehlada', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4638c0e3-df93-518b-82b8-59891c6f8147', 'sentence_builder', 'Складіть: «Я хочу записатися до лікаря.»', 'Želim se naručiti kod liječnika.', '["naručiti", "liječnika.", "Želim", "se", "kod"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3f1f4617-44bd-5d88-b3bc-1d80ab4c6729', 'sentence_builder', 'Складіть: «У мене алергія на пеніцилін.»', 'Imam alergiju na penicilin.', '["Imam", "penicilin.", "na", "alergiju"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'da7a4719-4d08-5983-9b5b-31301e4ff4a2', 'listening', 'Прослухайте і складіть фразу', 'Imam temperaturu i jak kašalj već tri dana.', '["tri", "kašalj", "dana.", "Imam", "već", "temperaturu", "i", "jak"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6082b60d-3933-5cc2-9fa8-7dec0b7ef675', 'listening', 'Прослухайте і складіть фразу', 'Imate li i nešto protiv bolova?', '["protiv", "i", "nešto", "li", "bolova?", "Imate"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5f01a6d9-9e91-5eb6-909e-6c0669c7a8c8', 'speaking', 'Де найближча аптека?', 'Gdje je najbliža ljekarna?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e37d3a2c-d94b-5c02-b67b-c977c2f9d526', 'speaking', 'У мене застуда.', 'Imam prehladu.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('97d743bb-68c8-52f6-977f-92001bd6037c', v_lesson, 'У сімейного лікаря', 'Kod obiteljskog liječnika', 2621, 'A0', 'health', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('ef43a4f2-6515-503d-913b-3cf5fff99a5b', '97d743bb-68c8-52f6-977f-92001bd6037c', 'Liječnica', 'Dobar dan, izvolite sjesti. Što vas muči?', 'Добрий день, сідайте. Що вас турбує?', 1);
  perform pg_temp.turn('1d72c3fa-c427-53cf-8f30-9bb0d46d1879', '97d743bb-68c8-52f6-977f-92001bd6037c', 'Daša', 'Imam temperaturu i jak kašalj već tri dana.', 'У мене температура й сильний кашель уже три дні.', 2);
  perform pg_temp.turn('7420046f-a640-5b03-ac72-438db98c9b7a', '97d743bb-68c8-52f6-977f-92001bd6037c', 'Liječnica', 'Da vidimo. Tlak vam je normalan. Mislim da je gripa.', 'Подивимося. Тиск у вас нормальний. Думаю, це грип.', 3);
  perform pg_temp.turn('74225a38-cb46-5497-aaa1-2f710a54b51e', '97d743bb-68c8-52f6-977f-92001bd6037c', 'Daša', 'Trebam li ostati kod kuće?', 'Мені треба залишитися вдома?', 4);
  perform pg_temp.turn('20090529-611e-5b0d-88bf-63792eb9d726', '97d743bb-68c8-52f6-977f-92001bd6037c', 'Liječnica', 'Da, otvorit ću vam bolovanje. Evo recepta za sirup.', 'Так, я відкрию вам лікарняний. Ось рецепт на сироп.', 5);
  perform pg_temp.turn('28bafb7b-03d7-5a64-bac6-739ff9efb91c', '97d743bb-68c8-52f6-977f-92001bd6037c', 'Daša', 'Hvala, doktorice.', 'Дякую, лікарко.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1e4899ae-60f8-5de7-91fb-9517b913cbda', v_lesson, 'В аптеці', 'U ljekarni', 2622, 'A0', 'health', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('8c8e20b1-eec9-5c25-903e-8e26b891d4cf', '1e4899ae-60f8-5de7-91fb-9517b913cbda', 'Darja', 'Dobar dan, imam recept za ovaj sirup.', 'Добрий день, у мене рецепт на цей сироп.', 1);
  perform pg_temp.turn('f1fe2ded-fb3d-5c78-bec7-8adc335fca5a', '1e4899ae-60f8-5de7-91fb-9517b913cbda', 'Ljekarnik', 'Izvolite. Uzimajte ga tri puta dnevno nakon jela.', 'Прошу. Приймайте його тричі на день після їжі.', 2);
  perform pg_temp.turn('441a45ee-2262-52ed-8604-ce8bb0a26170', '1e4899ae-60f8-5de7-91fb-9517b913cbda', 'Darja', 'Imate li i nešto protiv bolova?', 'А у вас є щось від болю?', 3);
  perform pg_temp.turn('e7bdcc91-a07d-58e6-9381-df2834293028', '1e4899ae-60f8-5de7-91fb-9517b913cbda', 'Ljekarnik', 'Imamo ove tablete. Imate li alergiju na neki lijek?', 'Є ось ці таблетки. У вас є алергія на якісь ліки?', 4);
  perform pg_temp.turn('c71d54db-38a7-5d8b-bf58-040d0f6ae090', '1e4899ae-60f8-5de7-91fb-9517b913cbda', 'Darja', 'Nemam. Koliko košta sve zajedno?', 'Ні. Скільки коштує все разом?', 5);
  perform pg_temp.turn('17ebe064-6259-52f2-ae7c-5a224453007e', '1e4899ae-60f8-5de7-91fb-9517b913cbda', 'Ljekarnik', 'Ukupno devet eura.', 'Разом дев’ять євро.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.10 · урок 64: У поліції — перебудова: 20 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'd2689a70-cb73-515f-9d81-6bb0f0fc1cff';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «У поліції» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '60fdd839-3b23-5f0f-ab7f-ab6515dc7376') then return; end if;  -- уже перебудовано
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
  if v_gid is null then select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Заперечення і питання з «biti»' and status = 'PUBLISHED' order by created_at limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 64: У поліції', title_hr = 'Lekcija 64: U policiji',
         objectives = '["Заявити про крадіжку: «Želim prijaviti krađu»", "Розповісти, що сталося і що зникло: kožni novčanik, osobna iskaznica", "Відповісти на питання поліцейського й підписати протокол"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'policija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'policajac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'policijska postaja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krađa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ukrasti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lopov', v_pos);
  v_pos := pg_temp.word(v_lesson, 'džeparoš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osobna iskaznica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blokirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svjedok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zapisnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opisati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nestati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'provala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sumnjiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odjednom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kožni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'torbica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kamera', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '8734919c-6353-53cf-8a85-85ebfc5f5f9e', 'fill_in_the_blank', 'Ja ___ vidjela lopova.', 'nisam', '["nisi", "nismo", "nije", "nisam"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8c083304-bacb-5889-8f53-d336fa16329b', 'multiple_choice', 'Що означає «džeparoš»?', 'кишеньковий злодій', '["кишеньковий злодій", "раптом", "протокол", "квартирна крадіжка, злам"]'::jsonb, 'A0', 2, 'PUBLISHED', 'džeparoš', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e53e3453-e409-5bf8-90ef-c33a6d149a04', 'multiple_choice', 'Що означає «blokirati»?', 'заблокувати', '["украсти", "заблокувати", "раптом", "зареєструвати; повідомити"]'::jsonb, 'A0', 3, 'PUBLISHED', 'blokirati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b319eb5c-4a44-57c7-b16c-eeb45e838fbf', 'multiple_choice', 'Що означає «policija»?', 'поліція', '["поліцейський", "протокол", "крадіжка", "поліція"]'::jsonb, 'A0', 4, 'PUBLISHED', 'policija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9be00f71-8ea9-5a21-9f6a-1088c692b4f2', 'multiple_choice', 'Як хорватською «раптом»?', 'odjednom', '["kamera", "zapisnik", "odjednom", "torbica"]'::jsonb, 'A0', 5, 'PUBLISHED', 'odjednom', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '62e15b88-d10d-5c73-bb44-7a1117138f29', 'multiple_choice', 'Як хорватською «протокол»?', 'zapisnik', '["prijaviti", "zapisnik", "kamera", "policijska postaja"]'::jsonb, 'A0', 6, 'PUBLISHED', 'zapisnik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '64d4d3c1-740f-51fe-80aa-a758ffbc55ec', 'type_answer', 'Напишіть хорватською: «шкіряний»', 'kožni', null, 'A0', 7, 'PUBLISHED', 'kožni', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9cff3076-fe67-5638-b14c-b5e93e753f6d', 'type_answer', 'Напишіть хорватською: «камера»', 'kamera', null, 'A0', 8, 'PUBLISHED', 'kamera', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '603f4ef8-9580-5f1e-ad1b-ffd56b41ba2e', 'type_answer', 'Напишіть хорватською: «зареєструвати; повідомити»', 'prijaviti', null, 'A0', 9, 'PUBLISHED', 'prijaviti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '14666f9e-e619-5f38-a1bb-d5158250e8e0', 'sentence_builder', 'Складіть: «Хтось украв мою сумочку.»', 'Netko mi je ukrao torbicu.', '["ukrao", "mi", "Netko", "je", "torbicu."]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4b40952d-8cae-51f1-ae84-721eab040afc', 'sentence_builder', 'Складіть: «Де поліцейський відділок?»', 'Gdje je policijska postaja?', '["policijska", "Gdje", "postaja?", "je"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7efb4335-cef4-5379-9cd3-7152fbfe127b', 'listening', 'Прослухайте і складіть фразу', 'Što vam je ukradeno?', '["ukradeno?", "je", "Što", "vam"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd0a56df8-a436-5cd9-a12f-81d0e2b5c80b', 'listening', 'Прослухайте і складіть фразу', 'Je li bio netko sumnjiv u blizini?', '["sumnjiv", "blizini?", "Je", "u", "netko", "bio", "li"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '42cd4579-1997-524d-b94a-9b0f1477c379', 'speaking', 'У мене вкрали гаманець.', 'Ukrali su mi novčanik.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bce8fe08-aded-5084-8f56-0693264432c0', 'speaking', 'Я хочу заблокувати картку.', 'Želim blokirati karticu.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('60fdd839-3b23-5f0f-ab7f-ab6515dc7376', v_lesson, 'Крадіжка в трамваї', 'Krađa u tramvaju', 2641, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('2ea13742-4864-532a-99e9-529915356c03', '60fdd839-3b23-5f0f-ab7f-ab6515dc7376', 'Daša', 'Dobar dan, želim prijaviti krađu.', 'Добрий день, я хочу заявити про крадіжку.', 1);
  perform pg_temp.turn('b37bc35f-f191-5be8-a33c-1d4d29f2b22d', '60fdd839-3b23-5f0f-ab7f-ab6515dc7376', 'Policajac', 'Što vam je ukradeno?', 'Що у вас украли?', 2);
  perform pg_temp.turn('9768a0c2-e208-54ba-9895-3a8ecc1c57da', '60fdd839-3b23-5f0f-ab7f-ab6515dc7376', 'Daša', 'Kožni novčanik s osobnom iskaznicom i karticom.', 'Шкіряний гаманець із посвідченням особи й карткою.', 3);
  perform pg_temp.turn('f430e829-5d88-5655-8abd-188c4220beb3', '60fdd839-3b23-5f0f-ab7f-ab6515dc7376', 'Policajac', 'Gdje se to dogodilo?', 'Де це сталося?', 4);
  perform pg_temp.turn('937b1296-839d-54ab-b50f-63d1868fd6b6', '60fdd839-3b23-5f0f-ab7f-ab6515dc7376', 'Daša', 'U tramvaju. Bila je gužva i odjednom je novčanik nestao.', 'У трамваї. Була тіснява, і раптом гаманець зник.', 5);
  perform pg_temp.turn('dac76323-ae43-598e-97b5-0d01bc204f87', '60fdd839-3b23-5f0f-ab7f-ab6515dc7376', 'Policajac', 'Vjerojatno džeparoš. Jeste li blokirali karticu?', 'Мабуть, кишеньковий злодій. Ви заблокували картку?', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3d2c3d4f-cf05-5f7b-9f02-e67adbe73e42', v_lesson, 'Свідок', 'Svjedok', 2642, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('ed260d67-6c08-543b-98c1-94b8d50322bb', '3d2c3d4f-cf05-5f7b-9f02-e67adbe73e42', 'Policajka', 'Jeste li vidjeli lopova?', 'Ви бачили злодія?', 1);
  perform pg_temp.turn('56a7325d-28b9-5394-9ecf-a3f392406734', '3d2c3d4f-cf05-5f7b-9f02-e67adbe73e42', 'Darja', 'Nisam ga dobro vidjela. Bio je visok, s crnom kapom.', 'Я його погано бачила. Він був високий, у чорній шапці.', 2);
  perform pg_temp.turn('82bb112b-76f8-589d-9f0b-e7f31e6e0c6b', '3d2c3d4f-cf05-5f7b-9f02-e67adbe73e42', 'Policajka', 'Je li bio netko sumnjiv u blizini?', 'Чи був хтось підозрілий поблизу?', 3);
  perform pg_temp.turn('7d98523c-bfe5-5dd1-bf3c-474a1ece842b', '3d2c3d4f-cf05-5f7b-9f02-e67adbe73e42', 'Darja', 'Jedan muškarac je stajao uz mene cijelo vrijeme.', 'Один чоловік увесь час стояв біля мене.', 4);
  perform pg_temp.turn('fb5eaca9-8b52-5807-8830-3bd4fde3e8b7', '3d2c3d4f-cf05-5f7b-9f02-e67adbe73e42', 'Policajka', 'Dobro. U tramvaju ima kamera. Evo zapisnika, potpišite ovdje.', 'Добре. У трамваї є камери. Ось протокол, підпишіть тут.', 5);
  perform pg_temp.turn('e6e821d4-05e5-56fb-8f78-2ccfbef0d605', '3d2c3d4f-cf05-5f7b-9f02-e67adbe73e42', 'Darja', 'Hvala. Nadam se da ćete ga naći.', 'Дякую. Сподіваюся, ви його знайдете.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.10 · урок 65: Заповнюємо анкету — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'b095637e-0644-507e-8f3d-d323483dd3e4';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Заповнюємо анкету» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '24993bef-7740-5f52-8b8f-a7d3d827b4c6') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 65: Заповнюємо анкету', title_hr = 'Lekcija 65: Ispunjavamo obrazac',
         objectives = '["Розуміти графи анкети: spol, mjesto rođenja, bračno stanje, OIB", "Заповнити бланк друкованими літерами й підписатися", "Запитати, чи потрібна копія і де її засвідчити"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'obrazac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispuniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potpisati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potpis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dokument', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osobni podaci', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjesto rođenja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'muški', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ženski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bračno stanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'e-pošta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'OIB', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kopija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fotografija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tiskanim slovima', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rubrika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovjeriti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pečat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispraviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pogreška', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obvezno', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '81874281-b4b9-54c5-be7f-c0aee9e88abd', 'fill_in_the_blank', 'Ime i prezime napišite ___ slovima.', 'tiskanim', '["tiskanih", "tiskani", "tiskana", "tiskanim"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'de5a73ef-522c-5382-b95f-d4c047d57815', 'multiple_choice', 'Що означає «e-pošta»?', 'електронна пошта', '["помилка", "електронна пошта", "особисті дані", "фотографія"]'::jsonb, 'A0', 2, 'PUBLISHED', 'e-pošta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f9a29974-9db1-53d8-9ba4-0cc1aa7c0168', 'multiple_choice', 'Що означає «tiskanim slovima»?', 'друкованими літерами', '["графа, поле (у бланку)", "друкованими літерами", "особисті дані", "виправити"]'::jsonb, 'A0', 3, 'PUBLISHED', 'tiskanim slovima', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b4e9af42-f364-56e1-98cf-c82cb97d8ff9', 'multiple_choice', 'Що означає «bračno stanje»?', 'сімейний стан', '["виправити", "підпис", "стать", "сімейний стан"]'::jsonb, 'A0', 4, 'PUBLISHED', 'bračno stanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '90ecb16f-2e72-5f5c-8e87-fe1e6a19f8dd', 'multiple_choice', 'Як хорватською «підписати»?', 'potpisati', '["potpisati", "bračno stanje", "osobni podaci", "mjesto rođenja"]'::jsonb, 'A0', 5, 'PUBLISHED', 'potpisati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '01a3fa3a-ea58-5370-87d5-950a2240a632', 'multiple_choice', 'Як хорватською «особисті дані»?', 'osobni podaci', '["ženski", "osobni podaci", "OIB", "ispraviti"]'::jsonb, 'A0', 6, 'PUBLISHED', 'osobni podaci', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e42b33ce-c540-5932-86d6-ffdf6bb857d3', 'type_answer', 'Напишіть хорватською: «заповнити»', 'ispuniti', null, 'A0', 7, 'PUBLISHED', 'ispuniti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ea34b8b-5cdc-593c-b38d-dc5005329ac5', 'type_answer', 'Напишіть хорватською: «чоловічий»', 'muški', null, 'A0', 8, 'PUBLISHED', 'muški', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aa405754-ee98-505c-950d-41fc5afb60f0', 'type_answer', 'Напишіть хорватською: «засвідчити (печаткою, у нотаріуса)»', 'ovjeriti', null, 'A0', 9, 'PUBLISHED', 'ovjeriti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f016a961-3a8e-5d53-8f43-40d4030fe9e0', 'sentence_builder', 'Складіть: «Підпишіться тут, будь ласка.»', 'Potpišite se ovdje, molim.', '["Potpišite", "ovdje,", "molim.", "se"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '273dcedf-cb5c-583c-bb13-893ea6c2fa36', 'sentence_builder', 'Складіть: «Я заповнила бланк.»', 'Ispunila sam obrazac.', '["sam", "obrazac.", "Ispunila"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd3e2c1a-1edb-5b8e-8ff2-8ab240d622b3', 'listening', 'Прослухайте і складіть фразу', 'Prvo upišite osobne podatke, tiskanim slovima.', '["upišite", "osobne", "tiskanim", "slovima.", "podatke,", "Prvo"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6c069cd7-4ef0-577c-9ac7-122c5bfedd9c', 'listening', 'Прослухайте і складіть фразу', 'Gdje mogu ovjeriti kopiju?', '["Gdje", "kopiju?", "ovjeriti", "mogu"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '03affe73-e67f-5fdd-9cb0-090975f02e4d', 'speaking', 'Можете мені допомогти з бланком?', 'Možete li mi pomoći s obrascem?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd6bed24a-39c5-5748-807a-a12bcda03a33', 'speaking', 'Де мені підписатися?', 'Gdje se trebam potpisati?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('24993bef-7740-5f52-8b8f-a7d3d827b4c6', v_lesson, 'Допомога з бланком', 'Pomoć s obrascem', 2651, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('877572b0-6525-5c28-8aa7-991baa5c9da5', '24993bef-7740-5f52-8b8f-a7d3d827b4c6', 'Daša', 'Oprostite, kako se ispunjava ovaj obrazac?', 'Перепрошую, як заповнювати цей бланк?', 1);
  perform pg_temp.turn('0e501a40-77bc-5236-932a-eea904657568', '24993bef-7740-5f52-8b8f-a7d3d827b4c6', 'Službenica', 'Prvo upišite osobne podatke, tiskanim slovima.', 'Спочатку впишіть особисті дані друкованими літерами.', 2);
  perform pg_temp.turn('8098f38f-1c03-551d-b641-a6063cd1d375', '24993bef-7740-5f52-8b8f-a7d3d827b4c6', 'Daša', 'Što pišem u rubriku „spol“?', 'Що писати в графу «стать»?', 3);
  perform pg_temp.turn('8cea054d-d5c7-51be-b450-c6af4e126847', '24993bef-7740-5f52-8b8f-a7d3d827b4c6', 'Službenica', 'Ženski. A ovdje mjesto rođenja i bračno stanje.', 'Жіноча. А тут — місце народження й сімейний стан.', 4);
  perform pg_temp.turn('bf4d3083-560e-55b4-8d99-6480a717edb2', '24993bef-7740-5f52-8b8f-a7d3d827b4c6', 'Daša', 'Moram li upisati i OIB?', 'Мені треба вписати й OIB?', 5);
  perform pg_temp.turn('607891d8-1a6c-5448-8b1e-870367ba40c5', '24993bef-7740-5f52-8b8f-a7d3d827b4c6', 'Službenica', 'Da, to je obvezno. Na kraju se potpišite.', 'Так, це обов’язково. Наприкінці підпишіться.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('be321cc8-3b8f-5ef1-bf04-2da879d40dff', v_lesson, 'Копія чи оригінал?', 'Kopija ili original?', 2652, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('2b4d2b8e-2036-57ca-9114-c8ca9645998a', 'be321cc8-3b8f-5ef1-bf04-2da879d40dff', 'Darja', 'Trebate li original ili kopiju diplome?', 'Вам потрібен оригінал чи копія диплома?', 1);
  perform pg_temp.turn('bab675c1-69b9-5d7a-b03b-7baf3d4fee09', 'be321cc8-3b8f-5ef1-bf04-2da879d40dff', 'Službenik', 'Kopiju, ali mora biti ovjerena.', 'Копія, але засвідчена.', 2);
  perform pg_temp.turn('b96118ca-984b-56b0-9609-920b7567afc4', 'be321cc8-3b8f-5ef1-bf04-2da879d40dff', 'Darja', 'Gdje mogu ovjeriti kopiju?', 'Де можна засвідчити копію?', 3);
  perform pg_temp.turn('7c6603c3-0e99-5ce0-afe9-95b4804f387c', 'be321cc8-3b8f-5ef1-bf04-2da879d40dff', 'Službenik', 'Kod javnog bilježnika. Treba vam pečat i potpis.', 'У нотаріуса. Потрібні печатка й підпис.', 4);
  perform pg_temp.turn('a4532053-0160-566b-b345-19353dfc38d1', 'be321cc8-3b8f-5ef1-bf04-2da879d40dff', 'Darja', 'U obrascu imam jednu pogrešku. Mogu li je ispraviti?', 'У бланку в мене одна помилка. Можна її виправити?', 5);
  perform pg_temp.turn('5baacb80-c1b1-53cb-a2ef-62255f5efc6a', 'be321cc8-3b8f-5ef1-bf04-2da879d40dff', 'Službenik', 'Možete, ali bolje ispunite novi.', 'Можна, але краще заповніть новий.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.10 · урок 66: Документи в MUP — перебудова: 20 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '19df3241-90f3-5450-94ac-642d79fb2869';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Документи в MUP» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '1b05a4d8-e796-56a4-993b-d078f4000e1b') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 66: Документи в MUP', title_hr = 'Lekcija 66: Dokumenti u MUP-u',
         objectives = '["Взяти номерок і дочекатися свого віконця", "Подати заяву на тимчасове проживання: zahtjev, pristojba, uplatnica", "Зрозуміти, яких документів бракує і коли забрати рішення"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'MUP', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šalter', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čekaonica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čekati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'službenik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'boravak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'privremeni boravak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radna dozvola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zahtjev', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pristojba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uplatnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uplatiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nedostajati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'donijeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rješenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preuzeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osobno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potvrda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odobriti', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '251165e6-ddb6-5acf-a208-84859f33e008', 'fill_in_the_blank', '___ mogu uplatiti pristojbu?', 'Gdje', '["Koji", "Tko", "Čiji", "Gdje"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f75a638c-5450-5146-80c7-b3f39f614811', 'multiple_choice', 'Що означає «osobno»?', 'особисто', '["сплатити (у банку, переказом)", "службовець / чиновник", "принести", "особисто"]'::jsonb, 'A0', 2, 'PUBLISHED', 'osobno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2b387b78-5a76-5dcb-a07b-7d24fdb0d028', 'multiple_choice', 'Що означає «boravak»?', 'перебування; проживання', '["перебування; проживання", "віконце (в установі)", "зал очікування", "бракувати; сумувати за"]'::jsonb, 'A0', 3, 'PUBLISHED', 'boravak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d3d572b-f8d1-5b0e-a37d-07e51c6e6af8', 'multiple_choice', 'Що означає «uplatnica»?', 'платіжна квитанція', '["здати, передати", "зал очікування", "платіжна квитанція", "МВС / Міністерство внутрішніх справ"]'::jsonb, 'A0', 4, 'PUBLISHED', 'uplatnica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3c533e63-319c-5531-9b11-75f009a6a6b5', 'multiple_choice', 'Як хорватською «офіційне рішення»?', 'rješenje', '["rješenje", "preuzeti", "uplatiti", "čekaonica"]'::jsonb, 'A0', 5, 'PUBLISHED', 'rješenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0264665d-b5f5-5bf8-8627-be5df117d88c', 'multiple_choice', 'Як хорватською «схвалити»?', 'odobriti', '["privremeni boravak", "uplatnica", "odobriti", "osobno"]'::jsonb, 'A0', 6, 'PUBLISHED', 'odobriti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b84e090f-8947-58fb-b167-dd13771df18d', 'type_answer', 'Напишіть хорватською: «чекати»', 'čekati', null, 'A0', 7, 'PUBLISHED', 'čekati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ee763593-ac0e-53ce-a455-a2e8d29a2967', 'type_answer', 'Напишіть хорватською: «сплатити (у банку, переказом)»', 'uplatiti', null, 'A0', 8, 'PUBLISHED', 'uplatiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f66577cb-debd-5a27-b789-55a1e355f834', 'type_answer', 'Напишіть хорватською: «службовець / чиновник»', 'službenik', null, 'A0', 9, 'PUBLISHED', 'službenik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8a2e8751-76a1-52b9-adb3-c1907da8a637', 'sentence_builder', 'Складіть: «Я хочу подати заяву.»', 'Želim predati zahtjev.', '["predati", "zahtjev.", "Želim"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7226b691-34c8-5b4a-b3c5-d711cc56a0e8', 'sentence_builder', 'Складіть: «Яких документів бракує?»', 'Koji dokumenti nedostaju?', '["dokumenti", "nedostaju?", "Koji"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b7474fd4-080c-5050-bf12-9a2773b1255b', 'listening', 'Прослухайте і складіть фразу', 'Nedostaje vam potvrda o smještaju.', '["Nedostaje", "vam", "o", "potvrda", "smještaju."]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae2663b2-5b1c-59cf-8932-b40f9bfcd752', 'listening', 'Прослухайте і складіть фразу', 'Moram li doći osobno?', '["doći", "Moram", "osobno?", "li"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '16185a7a-ea50-51cb-98d3-cdce2f0443ca', 'speaking', 'Де можна сплатити збір?', 'Gdje mogu uplatiti pristojbu?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '186e6e86-9700-5a56-b853-935cc34b3ab0', 'speaking', 'Коли я можу забрати рішення?', 'Kada mogu preuzeti rješenje?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1b05a4d8-e796-56a4-993b-d078f4000e1b', v_lesson, 'Біля віконця', 'Na šalteru', 2661, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('136e41f6-3b16-5ce4-ba2d-9b4e03252be5', '1b05a4d8-e796-56a4-993b-d078f4000e1b', 'Službenik', 'Sljedeći! Izvolite, što trebate?', 'Наступний! Прошу, що вам потрібно?', 1);
  perform pg_temp.turn('ab0fa4b9-4e20-50a3-9545-f9d217e43239', '1b05a4d8-e796-56a4-993b-d078f4000e1b', 'Daša', 'Želim predati zahtjev za privremeni boravak.', 'Я хочу подати заяву на тимчасове проживання.', 2);
  perform pg_temp.turn('ee5e6e23-939d-517b-a2af-696e2474480a', '1b05a4d8-e796-56a4-993b-d078f4000e1b', 'Službenik', 'Imate li sve dokumente i uplatnicu za pristojbu?', 'У вас є всі документи й квитанція про сплату збору?', 3);
  perform pg_temp.turn('3fa07647-6073-5b0c-893b-9062317ad403', '1b05a4d8-e796-56a4-993b-d078f4000e1b', 'Daša', 'Evo putovnice, ugovora o radu i uplatnice.', 'Ось паспорт, трудовий договір і квитанція.', 4);
  perform pg_temp.turn('882109fe-c620-5d27-8aec-8751f6dada00', '1b05a4d8-e796-56a4-993b-d078f4000e1b', 'Službenik', 'Nedostaje vam potvrda o smještaju.', 'Вам бракує довідки про житло.', 5);
  perform pg_temp.turn('e737cbed-847d-578c-9fe8-72d01bc11777', '1b05a4d8-e796-56a4-993b-d078f4000e1b', 'Daša', 'Mogu li je donijeti sutra?', 'Можна принести її завтра?', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1359d7f5-1ceb-5ad4-933e-4a35292b1fad', v_lesson, 'Коли буде рішення?', 'Kada će biti rješenje?', 2662, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('ee4e075e-9421-502f-bc09-19a395acffbf', '1359d7f5-1ceb-5ad4-933e-4a35292b1fad', 'Darja', 'Dobar dan, kada će biti gotovo rješenje za moj boravak?', 'Добрий день, коли буде готове рішення щодо мого проживання?', 1);
  perform pg_temp.turn('f6925682-7877-590e-bafb-3f2a22aa4ee3', '1359d7f5-1ceb-5ad4-933e-4a35292b1fad', 'Službenica', 'Zahtjev je odobren. Rješenje možete preuzeti na šalteru tri.', 'Заяву схвалено. Рішення можна забрати у віконці номер три.', 2);
  perform pg_temp.turn('c99f69a6-6f7c-5e84-b705-949a307f6b0b', '1359d7f5-1ceb-5ad4-933e-4a35292b1fad', 'Darja', 'Moram li doći osobno?', 'Мені треба прийти особисто?', 3);
  perform pg_temp.turn('4f1254a2-f5f2-5650-b9cf-29fe226626b9', '1359d7f5-1ceb-5ad4-933e-4a35292b1fad', 'Službenica', 'Da, s putovnicom. Uzmite broj i čekajte u čekaonici.', 'Так, із паспортом. Візьміть номерок і чекайте в залі очікування.', 4);
  perform pg_temp.turn('4c78c2c5-4d84-5226-8058-98baeeecd12d', '1359d7f5-1ceb-5ad4-933e-4a35292b1fad', 'Darja', 'Koliko se obično čeka?', 'Скільки зазвичай доводиться чекати?', 5);
  perform pg_temp.turn('d10bbcae-00f6-5640-8906-d15796029e18', '1359d7f5-1ceb-5ad4-933e-4a35292b1fad', 'Službenica', 'Oko pola sata. Budite strpljivi.', 'Близько пів години. Будьте терплячі.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- 3. Новий порядок уроків у модулі A0.10: наявні уроки тимчасово переносяться на місця 100+
--    (unique (unit_id, order_index)), щоб звільнити місця для нових; у кроці 5 — на остаточні місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 10 and u.order_index = 1;
  update public.lessons l set order_index = t.o + 100
    from (values
    ('edbae9ca-c4f4-575d-b876-d50b0a1fd9b5'::uuid, 1),
    ('fbc71f82-e715-5bab-a990-b8542fb0fe01'::uuid, 3),
    ('d2689a70-cb73-515f-9d81-6bb0f0fc1cff'::uuid, 5),
    ('b095637e-0644-507e-8f3d-d323483dd3e4'::uuid, 6),
    ('19df3241-90f3-5450-94ac-642d79fb2869'::uuid, 7)
    ) as t(id, o)
   where l.id = t.id and l.unit_id = v_unit and l.order_index <> t.o and l.order_index < 100;
end $$;

-- 4. Нові тематичні уроки модуля A0.10
-- A0.10 · урок 61: Частини тіла — новий урок: 22 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '599fba4f-4cee-5a88-9f9b-5ce32a445554';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A0.10: місце 2 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Що болить? Boli me…, bole me…' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Що болить? Boli me…, bole me…»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 61: Частини тіла', 'Lekcija 61: Dijelovi tijela', '["Назвати частини тіла: glava, ruka, noga, leđa, trbuh", "Сказати, що болить: «Boli me grlo», «Bole me leđa»", "Запитати інших: «Što te boli?», «Gdje vas boli?»"]'::jsonb, 15, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'tijelo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uho', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nos', v_pos);
  v_pos := pg_temp.word(v_lesson, 'usta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zub', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grlo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rame', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ruka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lakat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prst', v_pos);
  v_pos := pg_temp.word(v_lesson, 'leđa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prsa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trbuh', v_pos);
  v_pos := pg_temp.word(v_lesson, 'noga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koljeno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stopalo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koža', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srce', v_pos);
  v_pos := pg_temp.word(v_lesson, 'boljeti', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '1ddb7f3f-a305-5166-8387-653167e8e9db', 'fill_in_the_blank', 'Bole me ___.', 'leđa', '["glava", "srce", "leđa", "grlo"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '87978c2a-9d2d-5843-a0f9-a6a7f9d85c38', 'multiple_choice', 'Що означає «zub»?', 'зуб', '["зуб", "тіло", "болити", "стопа"]'::jsonb, 'A0', 2, 'PUBLISHED', 'zub', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f8943eee-2aad-5ef2-98cb-b15d42fbbb7a', 'multiple_choice', 'Що означає «grlo»?', 'горло', '["шкіра", "нога", "тіло", "горло"]'::jsonb, 'A0', 3, 'PUBLISHED', 'grlo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b79e392f-fa64-5e1e-bef7-669104869438', 'multiple_choice', 'Що означає «glava»?', 'голова', '["голова", "плече", "палець", "рот"]'::jsonb, 'A0', 4, 'PUBLISHED', 'glava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9c9bfa05-9d78-52d6-a3df-946f0f34e70f', 'multiple_choice', 'Як хорватською «тіло»?', 'tijelo', '["uho", "tijelo", "zub", "koljeno"]'::jsonb, 'A0', 5, 'PUBLISHED', 'tijelo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b5db76ee-7cfa-574e-9d0e-e28c2762556f', 'multiple_choice', 'Як хорватською «шкіра»?', 'koža', '["lakat", "koža", "boljeti", "koljeno"]'::jsonb, 'A0', 6, 'PUBLISHED', 'koža', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4c4df433-4d9e-55ca-86db-aa0fbf4d1fbd', 'type_answer', 'Напишіть хорватською: «палець»', 'prst', null, 'A0', 7, 'PUBLISHED', 'prst', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf2f66b4-5976-5e82-88c1-7067a788b03b', 'type_answer', 'Напишіть хорватською: «коліно»', 'koljeno', null, 'A0', 8, 'PUBLISHED', 'koljeno', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd7c143c0-6e47-590a-92e1-5fe5dd3ecf7d', 'type_answer', 'Напишіть хорватською: «груди»', 'prsa', null, 'A0', 9, 'PUBLISHED', 'prsa', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d8e924c-732f-5900-a727-e3c63d2eb232', 'sentence_builder', 'Складіть: «У мене болить зуб.»', 'Boli me zub.', '["me", "Boli", "zub."]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '64fb4491-ed2c-56ee-833f-b60478dedf42', 'sentence_builder', 'Складіть: «Де у вас болить?»', 'Gdje vas boli?', '["vas", "boli?", "Gdje"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '190f7744-659d-55f0-b322-3cc5c0b68163', 'listening', 'Прослухайте і складіть фразу', 'Boli me glava, a i grlo.', '["i", "grlo.", "glava,", "Boli", "me", "a"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c83ec357-480e-5497-b697-0e8a24edc44b', 'listening', 'Прослухайте і складіть фразу', 'Boli li te ovdje?', '["li", "te", "ovdje?", "Boli"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf82c996-c0e2-589d-bef4-e2ce2dde72cc', 'speaking', 'У мене болить живіт.', 'Boli me trbuh.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '31ea02b2-3bfc-581a-b799-d30cb413ade6', 'speaking', 'У мене болять ноги.', 'Bole me noge.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a81c5fdb-ce9b-53b9-94be-d9b65afc2f79', v_lesson, 'Що в тебе болить?', 'Što te boli?', 2611, 'A0', 'health', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('2f459e39-b618-5159-b82d-943214368c34', 'a81c5fdb-ce9b-53b9-94be-d9b65afc2f79', 'Ana', 'Dašo, što ti je? Izgledaš umorno.', 'Дашо, що з тобою? Ти виглядаєш утомленою.', 1);
  perform pg_temp.turn('7115b4f1-650a-5a36-8cc0-bfcdc10817b2', 'a81c5fdb-ce9b-53b9-94be-d9b65afc2f79', 'Daša', 'Boli me glava, a i grlo.', 'У мене болить голова, а ще горло.', 2);
  perform pg_temp.turn('f278b857-5a30-5c98-bc6f-9329576144ba', 'a81c5fdb-ce9b-53b9-94be-d9b65afc2f79', 'Ana', 'Imaš li temperaturu?', 'У тебе є температура?', 3);
  perform pg_temp.turn('d43dd31c-0ad9-54f4-8f06-026151a6e000', 'a81c5fdb-ce9b-53b9-94be-d9b65afc2f79', 'Daša', 'Mislim da nemam, ali bole me i leđa.', 'Здається, ні, але в мене ще й спина болить.', 4);
  perform pg_temp.turn('81e87b5c-bd9c-5a95-b6d8-6a1335d32678', 'a81c5fdb-ce9b-53b9-94be-d9b65afc2f79', 'Ana', 'Onda odmah u krevet! Popij čaj s medom.', 'Тоді негайно в ліжко! Випий чаю з медом.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('adca51aa-b1b3-5796-a1c3-fa89dd631b92', v_lesson, 'Після тренування', 'Poslije treninga', 2612, 'A0', 'health', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('062c7991-3451-5287-98f8-29e711f10f43', 'adca51aa-b1b3-5796-a1c3-fa89dd631b92', 'Darja', 'Joj, bole me noge i ramena.', 'Ой, у мене болять ноги й плечі.', 1);
  perform pg_temp.turn('c1099e1c-e8f9-5878-8371-6383620d3e70', 'adca51aa-b1b3-5796-a1c3-fa89dd631b92', 'Tomislav', 'Prvi put si bila u teretani. To je normalno.', 'Ти вперше була в спортзалі. Це нормально.', 2);
  perform pg_temp.turn('0cc2b611-56db-5d26-8a5c-a580156a6fd2', 'adca51aa-b1b3-5796-a1c3-fa89dd631b92', 'Darja', 'I lakat me boli kad podignem ruku.', 'І лікоть болить, коли піднімаю руку.', 3);
  perform pg_temp.turn('bc738a6a-e991-5c8a-abf1-d902631f6c22', 'adca51aa-b1b3-5796-a1c3-fa89dd631b92', 'Tomislav', 'Pokaži mi. Boli li te ovdje?', 'Покажи. Тут болить?', 4);
  perform pg_temp.turn('a5d6c349-d06f-53cb-aa55-887bb86ae982', 'adca51aa-b1b3-5796-a1c3-fa89dd631b92', 'Darja', 'Malo. Ali najviše me bole stopala.', 'Трохи. Але найбільше болять стопи.', 5);
  perform pg_temp.turn('5e739a9c-8d00-5a32-8e2d-eb23a78a4e8a', 'adca51aa-b1b3-5796-a1c3-fa89dd631b92', 'Tomislav', 'Sutra odmaraj, a za tjedan dana idemo opet!', 'Завтра відпочивай, а за тиждень підемо знову!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.10 · урок 63: Допоможіть! — новий урок: 22 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '48f26e9d-96c5-5189-8ec6-db1f9d58e200';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A0.10: місце 4 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Ввічливість: ti і Vi' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Ввічливість: ti і Vi»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 63: Допоможіть!', 'Lekcija 63: Upomoć!', '["Покликати на допомогу: «Upomoć!», «Trebam pomoć!»", "Викликати швидку, поліцію чи пожежників (112) і сказати, що сталося", "Сказати, що ви заблукали, і попросити допомоги"]'::jsonb, 15, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'upomoć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pomoć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pomoći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'možete li mi pomoći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trebam pomoć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hitna pomoć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zovite hitnu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zovite policiju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vatrogasac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'požar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gorjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nesreća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ozlijeđen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'onesvijestiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'disati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opasno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pazi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brzo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hitno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izgubio sam se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smiriti se', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '0be0d537-d172-519b-ba99-fb4a77efad67', 'fill_in_the_blank', 'Gospođo, ___ mi, molim vas!', 'pomozite', '["pomogne", "pomozite", "pomozi", "pomoći"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f25b21ae-d53e-584f-9788-c250e3703573', 'multiple_choice', 'Що означає «brzo»?', 'швидко', '["знепритомніти", "пожежа", "швидко", "терміново"]'::jsonb, 'A0', 2, 'PUBLISHED', 'brzo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '739ffd3f-5032-5132-b3a3-360ef4a8416d', 'multiple_choice', 'Що означає «hitna pomoć»?', 'швидка допомога', '["допомогти", "швидка допомога", "горіти", "швидко"]'::jsonb, 'A0', 3, 'PUBLISHED', 'hitna pomoć', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd1ee34e-8623-58c5-9593-a037cfac3691', 'multiple_choice', 'Що означає «pomoći»?', 'допомогти', '["допомогти", "мені потрібна допомога", "терміново", "нещастя; аварія, нещасний випадок"]'::jsonb, 'A0', 4, 'PUBLISHED', 'pomoći', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0f2e391b-7709-5611-9337-681c2ad28482', 'multiple_choice', 'Як хорватською «знепритомніти»?', 'onesvijestiti se', '["onesvijestiti se", "pomoć", "opasno", "zovite hitnu"]'::jsonb, 'A0', 5, 'PUBLISHED', 'onesvijestiti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f06aa3cd-a662-5862-a947-15e1fbb6335e', 'multiple_choice', 'Як хорватською «горіти»?', 'gorjeti', '["zovite hitnu", "krv", "gorjeti", "disati"]'::jsonb, 'A0', 6, 'PUBLISHED', 'gorjeti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '068107d6-5631-54e8-a904-bbc1dd67f523', 'type_answer', 'Напишіть хорватською: «небезпечно»', 'opasno', null, 'A0', 7, 'PUBLISHED', 'opasno', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '17eeafea-585e-5126-b1fb-c004a5bd98e2', 'type_answer', 'Напишіть хорватською: «дихати»', 'disati', null, 'A0', 8, 'PUBLISHED', 'disati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '432ac272-3ac9-53d4-9339-940fae5cf96e', 'type_answer', 'Напишіть хорватською: «пожежник»', 'vatrogasac', null, 'A0', 9, 'PUBLISHED', 'vatrogasac', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ebc6c758-b901-51c5-84bd-15be9189f920', 'sentence_builder', 'Складіть: «Швидко викличте пожежників!»', 'Brzo zovite vatrogasce!', '["vatrogasce!", "zovite", "Brzo"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '917ca22f-ae84-503b-abef-553b0aa2d242', 'sentence_builder', 'Складіть: «Тут горить будинок!»', 'Ovdje gori kuća!', '["gori", "Ovdje", "kuća!"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '57564e79-4865-5b1a-9230-8cfecaaa15fb', 'listening', 'Прослухайте і складіть фразу', 'Jedan čovjek je ozlijeđen.', '["Jedan", "je", "ozlijeđen.", "čovjek"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '240ef7ee-6b89-5a74-80f1-4861e72f1a88', 'listening', 'Прослухайте і складіть фразу', 'Izgubio sam se.', '["Izgubio", "se.", "sam"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9cbf3984-5b99-5bdb-9ba8-551629285b85', 'speaking', 'Допоможіть! Мені потрібна допомога!', 'Upomoć! Trebam pomoć!', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9416309a-72c1-5368-97f4-fee6dec81029', 'speaking', 'Викличте швидку, людина знепритомніла!', 'Zovite hitnu, čovjek se onesvijestio!', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('60f7d6dc-15e6-5491-8099-cac6121b48a0', v_lesson, 'Дзвінок на 112', 'Poziv na 112', 2631, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('decef046-de80-5bfc-887e-05e85955c18e', '60f7d6dc-15e6-5491-8099-cac6121b48a0', 'Operaterka', 'Centar 112, izvolite. Što se dogodilo?', 'Центр 112, слухаю. Що сталося?', 1);
  perform pg_temp.turn('48f5fc49-037e-5fe4-a965-cc42e6daa0f2', '60f7d6dc-15e6-5491-8099-cac6121b48a0', 'Daša', 'Dogodila se prometna nesreća! Jedan čovjek je ozlijeđen.', 'Сталася ДТП! Один чоловік поранений.', 2);
  perform pg_temp.turn('983fd753-4d40-5806-b3a9-ae8bd242e850', '60f7d6dc-15e6-5491-8099-cac6121b48a0', 'Operaterka', 'Gdje ste točno? Diše li?', 'Де ви точно? Він дихає?', 3);
  perform pg_temp.turn('65ef4d0f-b3db-5fba-a463-69a045d70007', '60f7d6dc-15e6-5491-8099-cac6121b48a0', 'Daša', 'U Ilici, kod broja deset. Diše, ali ima puno krvi.', 'На вулиці Іліца, біля будинку десять. Дихає, але багато крові.', 4);
  perform pg_temp.turn('39ddc346-7879-506c-8d9d-61a7c35b3438', '60f7d6dc-15e6-5491-8099-cac6121b48a0', 'Operaterka', 'Hitna pomoć stiže za pet minuta. Smirite se i ostanite s njim.', 'Швидка буде за п’ять хвилин. Заспокойтеся й залишайтеся з ним.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('47639b47-c8fc-5acf-8123-788c4dbecbcb', v_lesson, 'Я заблукав', 'Izgubio sam se', 2632, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('ad5252aa-dd87-5da8-99c2-14c478ea1ab9', '47639b47-c8fc-5acf-8123-788c4dbecbcb', 'Andrij', 'Oprostite, možete li mi pomoći? Izgubio sam se.', 'Перепрошую, можете мені допомогти? Я заблукав.', 1);
  perform pg_temp.turn('6cad8949-cbfd-5290-9182-1b1504f1ca8b', '47639b47-c8fc-5acf-8123-788c4dbecbcb', 'Gospođa', 'Naravno. Kamo trebate ići?', 'Звісно. Куди вам треба?', 2);
  perform pg_temp.turn('66817b47-674e-57ee-bb13-49cc5069de6b', '47639b47-c8fc-5acf-8123-788c4dbecbcb', 'Andrij', 'Do hotela Park, ali mobitel mi se ugasio.', 'До готелю «Парк», але в мене вимкнувся телефон.', 3);
  perform pg_temp.turn('85d92401-7a1e-5e17-b223-d214d19664db', '47639b47-c8fc-5acf-8123-788c4dbecbcb', 'Gospođa', 'Pazite, ovdje je opasno prelaziti cestu. Idemo do semafora.', 'Обережно, тут небезпечно переходити дорогу. Ходімо до світлофора.', 4);
  perform pg_temp.turn('5fab81c7-6469-578d-836e-b2c16b6e8f5f', '47639b47-c8fc-5acf-8123-788c4dbecbcb', 'Andrij', 'Hvala vam puno, jako ste ljubazni.', 'Дуже дякую, ви дуже люб’язні.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- 5. Наявні уроки модуля A0.10 — на нові місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 10 and u.order_index = 1;
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
   where l.id in ('edbae9ca-c4f4-575d-b876-d50b0a1fd9b5', '599fba4f-4cee-5a88-9f9b-5ce32a445554', 'fbc71f82-e715-5bab-a990-b8542fb0fe01', '48f26e9d-96c5-5189-8ec6-db1f9d58e200', 'd2689a70-cb73-515f-9d81-6bb0f0fc1cff', 'b095637e-0644-507e-8f3d-d323483dd3e4', '19df3241-90f3-5450-94ac-642d79fb2869')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or not exists (select 1 from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar')
             and exists (select 1 from public.lesson_grammar lg where lg.lesson_id = l.id)
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_module from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 10;
  select count(*) into v_order from (values ('edbae9ca-c4f4-575d-b876-d50b0a1fd9b5'::uuid, 1), ('599fba4f-4cee-5a88-9f9b-5ce32a445554'::uuid, 2), ('fbc71f82-e715-5bab-a990-b8542fb0fe01'::uuid, 3), ('48f26e9d-96c5-5189-8ec6-db1f9d58e200'::uuid, 4), ('d2689a70-cb73-515f-9d81-6bb0f0fc1cff'::uuid, 5), ('b095637e-0644-507e-8f3d-d323483dd3e4'::uuid, 6), ('19df3241-90f3-5450-94ac-642d79fb2869'::uuid, 7)) as t(id, o) join public.lessons l on l.id = t.id and l.order_index = t.o;
  select count(*) into v_lessons from public.lessons where level_code = 'A0' and status = 'PUBLISHED';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A0' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('edbae9ca-c4f4-575d-b876-d50b0a1fd9b5', '599fba4f-4cee-5a88-9f9b-5ce32a445554', 'fbc71f82-e715-5bab-a990-b8542fb0fe01', '48f26e9d-96c5-5189-8ec6-db1f9d58e200', 'd2689a70-cb73-515f-9d81-6bb0f0fc1cff', 'b095637e-0644-507e-8f3d-d323483dd3e4', '19df3241-90f3-5450-94ac-642d79fb2869') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A0.10: % уроків з неправильним складом', v_bad; end if;
  if v_module <> 7 or v_order <> 7 then raise exception 'Модуль A0.10: уроків %, на своїх місцях % (очікувалось 7)', v_module, v_order; end if;
  if v_lessons < 66 then raise exception 'A0: уроків %, очікувалось щонайменше 66', v_lessons; end if;  -- наступні модулі додають уроки
  if v_titles > 0 then raise exception 'A0: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A0.10: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A0.10 — 7 уроків (60–66) за темою; уроків A0 — %', v_lessons;
end $$;

commit;
