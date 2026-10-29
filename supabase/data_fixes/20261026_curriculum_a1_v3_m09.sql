-- =====================================================================
-- Програма A1 v3 · модуль A1.9 «Люди й вільний час» · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_curriculum_a1_v3.py 9 (не редагуйте вручну).
--
-- Рішення власника 2026-10-21 / 2026-10-26: до 25 слів на урок — скільки потрібно темі, 90–95 % слів — нові для рівня,
-- діалоги під тему, частіше Даша / Дар’я; бета (PUBLISHED).
--   * Уроки 76–85: 8 наявних перебудовано, 2 нових. Слів у них: 134.
--     Кожен: 10–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 43.
--   * Нові теми граматики: «Кличний відмінок: Dašo! Ivane! Gospodine!», «Неозначені займенники: netko, nešto, negdje».
--   * Нові правила до тем: «Сполучники» (+1).
--   * Виправлено: veza — «зв’язок; стосунки (бути у стосунках — biti u vezi)»; prekinuti — «перервати, зупинити; розійтися (prekinuti s nekim)»; slikati — «малювати (фарбами); фотографувати»; ponosan — «гордий; який пишається» (стара версія — у content_versions).
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

-- 1. Нові слова й вирази A1.9 (43; наявні не змінюються)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('oslovljavati', 'oslovljavati', 'hr', 'verb', 'A1', 'називати (при звертанні: на ім’я, «пане»)', 'core', '{"aspect": "ipfv", "present": {"1s": "oslovljavam", "2s": "oslovljavaš", "3s": "oslovljava"}}'::jsonb, '["Kolege se oslovljavaju imenom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('obraćati se', 'obracati se', 'hr', 'verb', 'A1', 'звертатися (до когось)', 'core', '{"aspect": "ipfv", "present": {"1s": "obraćam se", "2s": "obraćaš se", "3s": "obraća se"}}'::jsonb, '["Profesoru se obraćamo s «Vi»."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('persirati', 'persirati', 'hr', 'verb', 'A1', 'звертатися на «Ви»', 'core', '{"aspect": "ipfv", "present": {"1s": "persiram", "2s": "persiraš", "3s": "persira"}}'::jsonb, '["Starijim ljudima persiramo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tikati', 'tikati', 'hr', 'verb', 'A1', 'звертатися на «ти»', 'core', '{"aspect": "ipfv", "present": {"1s": "tikam", "2s": "tikaš", "3s": "tika"}}'::jsonb, '["Možemo se tikati, ja sam Marko."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('poštovani', 'postovani', 'hr', 'adjective', 'A1', 'шановний (у листі, зверненні)', 'core', '{"f": "poštovana", "n": "poštovano"}'::jsonb, '["Poštovani gospodine Kovaču, …"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dame i gospodo', 'dame i gospodo', 'hr', 'phrase', 'A1', 'пані та панове', 'chunk', '{}'::jsonb, '["Dame i gospodo, dobro došli!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('titula', 'titula', 'hr', 'noun', 'A1', 'звання, титул (dr., prof.)', 'core', '{"gender": "f"}'::jsonb, '["Liječnika oslovljavamo titulom: doktore."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('čika', 'cika', 'hr', 'noun', 'A1', 'дядько (до старшого чоловіка, дитяче)', 'core', '{"gender": "m"}'::jsonb, '["Čika Ivo, možete li nam dodati loptu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dobro raspoložen', 'dobro raspolozen', 'hr', 'phrase', 'A1', 'у гарному настрої', 'collocation', '{}'::jsonb, '["Danas si baš dobro raspoložena!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('loše volje', 'lose volje', 'hr', 'phrase', 'A1', 'не в гуморі, у поганому настрої', 'chunk', '{}'::jsonb, '["Šef je danas loše volje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('razočaran', 'razocaran', 'hr', 'adjective', 'A1', 'розчарований', 'core', '{"f": "razočarana", "n": "razočarano"}'::jsonb, '["Razočaran sam rezultatom ispita."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uzbuđen', 'uzbuden', 'hr', 'adjective', 'A1', 'схвильований (радісно)', 'core', '{"f": "uzbuđena", "n": "uzbuđeno"}'::jsonb, '["Djeca su uzbuđena zbog izleta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ljubomoran', 'ljubomoran', 'hr', 'adjective', 'A1', 'ревнивий; заздрісний', 'core', '{"f": "ljubomorna", "n": "ljubomorno"}'::jsonb, '["Nemoj biti ljubomoran."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bijesan', 'bijesan', 'hr', 'adjective', 'A1', 'розлючений', 'core', '{"f": "bijesna", "n": "bijesno"}'::jsonb, '["Bio je bijesan jer je izgubio novčanik."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uplašen', 'uplasen', 'hr', 'adjective', 'A1', 'наляканий', 'core', '{"f": "uplašena", "n": "uplašeno"}'::jsonb, '["Pas je uplašen od vatrometa."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('domjenak', 'domjenak', 'hr', 'noun', 'A1', 'невелика вечірка, прийом (на роботі)', 'core', '{"gender": "m"}'::jsonb, '["U petak imamo božićni domjenak u uredu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('svečan', 'svecan', 'hr', 'adjective', 'A1', 'святковий, урочистий', 'core', '{"f": "svečana", "n": "svečano"}'::jsonb, '["Za vjenčanje treba svečana odjeća."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pratnja', 'pratnja', 'hr', 'noun', 'A1', 'супровід; партнер (на захід)', 'core', '{"gender": "f"}'::jsonb, '["Možeš doći s pratnjom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('planinarski dom', 'planinarski dom', 'hr', 'phrase', 'A1', 'гірський притулок', 'collocation', '{"gender": "m"}'::jsonb, '["Ručamo u planinarskom domu na vrhu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('izletnik', 'izletnik', 'hr', 'noun', 'A1', 'турист (на прогулянці, у поході)', 'core', '{"gender": "m"}'::jsonb, '["Vikendom je na Sljemenu puno izletnika."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mjesto sastanka', 'mjesto sastanka', 'hr', 'phrase', 'A1', 'місце зустрічі', 'collocation', '{"gender": "n"}'::jsonb, '["Mjesto sastanka je kod glavnog ulaza."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('okupiti se', 'okupiti se', 'hr', 'verb', 'A1', 'зібратися (разом)', 'core', '{"aspect": "pfv", "present": {"1s": "okupim se", "2s": "okupiš se", "3s": "okupi se"}}'::jsonb, '["Okupimo se u osam ispred škole."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('šah', 'sah', 'hr', 'noun', 'A1', 'шахи', 'core', '{"gender": "m"}'::jsonb, '["Djed i ja igramo šah nedjeljom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('društvene igre', 'drustvene igre', 'hr', 'phrase', 'A1', 'настільні ігри', 'collocation', '{"gender": "f_pl"}'::jsonb, '["Kad pada kiša, igramo društvene igre."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pecati', 'pecati', 'hr', 'verb', 'A1', 'рибалити, ловити рибу (вудкою)', 'core', '{"aspect": "ipfv", "present": {"1s": "pecam", "2s": "pecaš", "3s": "peca"}}'::jsonb, '["Tata ljeti peca na moru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vrtlarenje', 'vrtlarenje', 'hr', 'noun', 'A1', 'садівництво, робота в саду', 'core', '{"gender": "n"}'::jsonb, '["Moj hobi je vrtlarenje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('skupljati', 'skupljati', 'hr', 'verb', 'A1', 'збирати, колекціонувати', 'core', '{"aspect": "ipfv", "present": {"1s": "skupljam", "2s": "skupljaš", "3s": "skuplja"}}'::jsonb, '["Moj sin skuplja sličice nogometaša."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('neriješeno', 'nerijeseno', 'hr', 'adverb', 'A1', 'нічия (у грі)', 'core', '{}'::jsonb, '["Utakmica je završila neriješeno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('premijera', 'premijera', 'hr', 'noun', 'A1', 'прем’єра', 'core', '{"gender": "f"}'::jsonb, '["Premijera predstave je u subotu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('opera', 'opera', 'hr', 'noun', 'A1', 'опера', 'core', '{"gender": "f"}'::jsonb, '["U HNK-u gledamo operu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('balet', 'balet', 'hr', 'noun', 'A1', 'балет', 'core', '{"gender": "m"}'::jsonb, '["Kći ide na balet dvaput tjedno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pljeskati', 'pljeskati', 'hr', 'verb', 'A1', 'аплодувати, плескати', 'core', '{"aspect": "ipfv", "present": {"1s": "pljeskam", "2s": "pljeskaš", "3s": "pljeska"}}'::jsonb, '["Publika dugo plješće glumcima."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('negdje', 'negdje', 'hr', 'adverb', 'A1', 'десь', 'function_word', '{}'::jsonb, '["Negdje sam ostavila ključeve."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ikad', 'ikad', 'hr', 'adverb', 'A1', 'коли-небудь', 'function_word', '{}'::jsonb, '["Jesi li ikad bio u Dubrovniku?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nekad', 'nekad', 'hr', 'adverb', 'A1', 'колись; іноді', 'function_word', '{}'::jsonb, '["Nekad sam živjela u Kijevu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nekako', 'nekako', 'hr', 'adverb', 'A1', 'якось', 'function_word', '{}'::jsonb, '["Nekako mi nije dobro danas."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('svatko', 'svatko', 'hr', 'pronoun', 'A1', 'кожен, будь-хто', 'function_word', '{}'::jsonb, '["Svatko može naučiti hrvatski."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('po mom mišljenju', 'po mom misljenju', 'hr', 'phrase', 'A1', 'на мою думку', 'chunk', '{}'::jsonb, '["Po mom mišljenju, film je predug."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('u pravu', 'u pravu', 'hr', 'phrase', 'A1', 'правий (бути правим)', 'chunk', '{}'::jsonb, '["Mislim da si u pravu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('griješiti', 'grijesiti', 'hr', 'verb', 'A1', 'помилятися', 'core', '{"aspect": "ipfv", "present": {"1s": "griješim", "2s": "griješiš", "3s": "griješi"}}'::jsonb, '["Možda griješim, ali mislim da kasnimo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('simpatija', 'simpatija', 'hr', 'noun', 'A1', 'симпатія (людина, яка подобається)', 'core', '{"gender": "f"}'::jsonb, '["Moja simpatija je u drugom razredu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zaljubljen', 'zaljubljen', 'hr', 'adjective', 'A1', 'закоханий', 'core', '{"f": "zaljubljena", "n": "zaljubljeno"}'::jsonb, '["Vidi se da su zaljubljeni."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zaručiti se', 'zaruciti se', 'hr', 'verb', 'A1', 'заручитися', 'core', '{"aspect": "pfv", "present": {"1s": "zaručim se", "2s": "zaručiš se", "3s": "zaruči se"}}'::jsonb, '["Zaručili su se na Božić."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;

-- 1б. Виправлені слова (4); повторний запуск нічого не змінює
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'veza' and ukrainian_translation = 'зв''язок' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'зв’язок; стосунки (бути у стосунках — biti u vezi)' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'prekinuti' and ukrainian_translation = 'перервати, зупинити' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'перервати, зупинити; розійтися (prekinuti s nekim)' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'slikati' and ukrainian_translation = 'фотографувати / малювати' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'малювати (фарбами); фотографувати' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'ponosan' and ukrainian_translation = 'гордий' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'гордий; який пишається' where id = r.id;
  end loop;
end $$;

-- 1а. Граматика A1.9: нові теми (2) і нові правила до наявних тем (1)
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '681237a6-5916-5c6a-837b-2c5ca67708f9', 'A1', 'Кличний відмінок: Dašo! Ivane! Gospodine!', 'Vokativ: Dašo! Ivane! Gospodine!', 'Звертання до людини — кличний відмінок, як в українській: Ivane, gospodine, Dašo, gospođo. Чоловічий рід: -e / -u; жіночий: -o або без змін; ввічливі звертання й множина.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Кличний відмінок: Dašo! Ivane! Gospodine!');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '0f3119f9-8a56-50ad-935b-326e14b006a4', '681237a6-5916-5c6a-837b-2c5ca67708f9', 'Чоловічий рід: Ivane, gospodine, prijatelju', 'Імена й іменники на приголосний отримують -e: Ivan → Ivane, Filip → Filipe, gospodin → gospodine, doktor → doktore, šef → šefe. Після м’якого приголосного (j, lj, nj, č, ć, š, ž) — -u: prijatelj → prijatelju, mladić → mladiću. Імена на -o, -a не змінюються: Marko!, Luka!, Ivo!', 'Ivan → Ivane · gospodin → gospodine · prijatelj → prijatelju · Marko → Marko', '[{"hr": "Ivane, dođi ovamo!", "ua": "Іване, ходи сюди!"}, {"hr": "Dobar dan, gospodine!", "ua": "Добрий день, пане!"}, {"hr": "Hvala ti, prijatelju!", "ua": "Дякую тобі, друже!"}, {"hr": "Marko, gdje si?", "ua": "Марку, де ти?"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '681237a6-5916-5c6a-837b-2c5ca67708f9')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'ffdb88c4-936e-5688-ad0c-1269e7f954fe', '681237a6-5916-5c6a-837b-2c5ca67708f9', 'Жіночий рід: Dašo, mamo, gospođo', 'Іменники на -a часто мають -o: mama → mamo, sestra → sestro, gospođa → gospođo, Daša → Dašo, teta → teto. Багато жіночих імен у розмові не змінюються: Ana!, Ivana!, Marija!, Petra! Імена на -ica — -ice: Marica → Marice.', 'Daša → Dašo · gospođa → gospođo · sestra → sestro · Ana → Ana', '[{"hr": "Dašo, kamo ideš?", "ua": "Дашо, куди ти йдеш?"}, {"hr": "Mamo, gladan sam!", "ua": "Мамо, я голодний!"}, {"hr": "Hvala, gospođo!", "ua": "Дякую, пані!"}, {"hr": "Ana, čekaj me!", "ua": "Ано, зачекай мене!"}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '681237a6-5916-5c6a-837b-2c5ca67708f9')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '6b5e2bf7-b6d7-519a-a976-4adc52046f9e', '681237a6-5916-5c6a-837b-2c5ca67708f9', 'Ввічливо: gospodine Kovaču, gospođo Babić', 'Чоловіче ім’я чи прізвище після gospodine теж у кличному: gospodine Kovaču, gospodine Horvate. Жіноче прізвище не змінюється: gospođo Babić, gospođo Horvat. Посади: doktore, profesorice, šefice. У листі — Poštovani gospodine…, Poštovana gospođo….', 'gospodine Kovaču · gospođo Babić · doktorice · profesore', '[{"hr": "Izvolite, gospodine Kovaču.", "ua": "Прошу, пане Ковач."}, {"hr": "Doktorice, imam pitanje.", "ua": "Пані лікарко, у мене питання."}, {"hr": "Poštovana gospođo Babić, …", "ua": "Шановна пані Бабич, …"}, {"hr": "Profesore, možete li ponoviti?", "ua": "Пане професоре, можете повторити?"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '681237a6-5916-5c6a-837b-2c5ca67708f9')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '8ac48bf2-34a2-5df0-a037-e9d29caf12a4', '681237a6-5916-5c6a-837b-2c5ca67708f9', 'Множина: Djeco! Dragi prijatelji!', 'У множині кличний збігається з називним: Djeco!, Prijatelji!, Kolege!, Dame i gospodo! Прикметник теж: Dragi prijatelji! Drage kolegice i kolege!', 'djeca → djeco! · dragi prijatelji! · dame i gospodo!', '[{"hr": "Djeco, ručak je gotov!", "ua": "Діти, обід готовий!"}, {"hr": "Dragi prijatelji, hvala vam!", "ua": "Дорогі друзі, дякую вам!"}, {"hr": "Dame i gospodo, dobro došli!", "ua": "Пані та панове, ласкаво просимо!"}, {"hr": "Drage kolege, sastanak počinje.", "ua": "Шановні колеги, нарада починається."}]'::jsonb, 4
where exists (select 1 from public.grammar_topics where id = '681237a6-5916-5c6a-837b-2c5ca67708f9')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '681237a6-5916-5c6a-837b-2c5ca67708f9', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '681237a6-5916-5c6a-837b-2c5ca67708f9')
  and not exists (select 1 from public.content_reviews where entity_id = '681237a6-5916-5c6a-837b-2c5ca67708f9' and notes = 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '94ba8f80-31ef-5516-813b-b9f0bab86d1b', 'A1', 'Неозначені займенники: netko, nešto, negdje', 'Neodređene zamjenice: netko, nešto, negdje', 'Ne- = «-сь» (netko, nešto, negdje, nekad, nekako); ni- = «ні-» з запереченням (nitko ne, ništa ne, nigdje ne); i- / bilo- = «-небудь, будь-» (ikad, bilo tko); sve-: svatko, sve, svugdje.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Неозначені займенники: netko, nešto, negdje');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '2f44a086-54cf-5160-86aa-86dcb5e90b85', '94ba8f80-31ef-5516-813b-b9f0bab86d1b', 'Ne- = «-сь»: netko, nešto, negdje', 'Ne- + питальне слово: tko → netko (хтось), što → nešto (щось), gdje → negdje (десь), kada → nekad (колись, іноді), kako → nekako (якось), koji → neki (якийсь). Netko kuca. Negdje sam vidjela ključ.', 'tko → netko · što → nešto · gdje → negdje · kako → nekako', '[{"hr": "Netko te traži.", "ua": "Тебе хтось шукає."}, {"hr": "Želiš li nešto popiti?", "ua": "Хочеш щось випити?"}, {"hr": "Negdje sam vidjela tvoj ključ.", "ua": "Я десь бачила твій ключ."}, {"hr": "Nekad idemo u kino.", "ua": "Іноді ми ходимо в кіно."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '94ba8f80-31ef-5516-813b-b9f0bab86d1b')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '44a12304-262f-55ae-8d23-7cb39468d3bc', '94ba8f80-31ef-5516-813b-b9f0bab86d1b', 'Ni- = «ні-»: nitko ne, ništa ne, nigdje ne', 'Ni- + питальне слово, і дієслово теж із запереченням, як в українській: Nitko ne zna. Ništa ne razumijem. Nigdje ga nema. Nikad nisam bio u Splitu. З прийменником він стає посередині: ni od koga, ni s kim, ni o čemu.', 'nitko ne… · ništa ne… · nigdje ne… · nikad ne…', '[{"hr": "Nitko nije došao.", "ua": "Ніхто не прийшов."}, {"hr": "Ništa ne vidim.", "ua": "Я нічого не бачу."}, {"hr": "Nigdje nema parkinga.", "ua": "Ніде немає парковки."}, {"hr": "Ni s kim ne razgovara.", "ua": "Він ні з ким не розмовляє."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '94ba8f80-31ef-5516-813b-b9f0bab86d1b')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '24acc6d7-08a3-5666-9e09-ca2debadc28c', '94ba8f80-31ef-5516-813b-b9f0bab86d1b', 'I- і bilo-: ikad, bilo tko, bilo što', 'I- — «коли-небудь» у питанні: Jesi li ikad bio na Hvaru? Bilo- — «будь-»: bilo tko (будь-хто), bilo što (будь-що), bilo gdje (будь-де), bilo kad (будь-коли). Pitaj bilo koga.', 'ikad? · bilo tko · bilo što · bilo gdje', '[{"hr": "Jesi li ikad jeo peku?", "ua": "Ти коли-небудь їв пеку?"}, {"hr": "Možeš doći bilo kad.", "ua": "Можеш прийти будь-коли."}, {"hr": "Pitaj bilo koga na ulici.", "ua": "Спитай будь-кого на вулиці."}, {"hr": "Daj mi bilo što za pisanje.", "ua": "Дай мені будь-що, щоб писати."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '94ba8f80-31ef-5516-813b-b9f0bab86d1b')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '53e087b8-31a7-5d41-97cb-6e032efd4004', '94ba8f80-31ef-5516-813b-b9f0bab86d1b', 'Sve-: svatko, sve, svugdje', 'Svatko — кожен (svatko zna), svi — усі, sve — усе, svugdje — всюди, uvijek — завжди. Svatko je dobrodošao. Svugdje je gužva.', 'svatko · svi · sve · svugdje · uvijek', '[{"hr": "Svatko može doći.", "ua": "Кожен може прийти."}, {"hr": "Svi su tu?", "ua": "Усі тут?"}, {"hr": "Svugdje je gužva.", "ua": "Скрізь тіснява."}, {"hr": "Sve je u redu.", "ua": "Усе гаразд."}]'::jsonb, 4
where exists (select 1 from public.grammar_topics where id = '94ba8f80-31ef-5516-813b-b9f0bab86d1b')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '94ba8f80-31ef-5516-813b-b9f0bab86d1b', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '94ba8f80-31ef-5516-813b-b9f0bab86d1b')
  and not exists (select 1 from public.content_reviews where entity_id = '94ba8f80-31ef-5516-813b-b9f0bab86d1b' and notes = 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.');
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Сполучники' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Сполучники»'; end if;
  if exists (select 1 from public.grammar_rules where id = 'a369278e-7ecf-5e7b-8260-cb0c82970c2c') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('a369278e-7ecf-5e7b-8260-cb0c82970c2c', v_topic, 'Da, kad, ako: Mislim da…, Kad dođeš…, Ako želiš…', 'Da — «що» після думати, знати, казати: Mislim da je film dobar. Znam da kasniš. Kad — «коли»: Kad dođeš, nazovi me. Ako — «якщо»: Ako želiš, idemo zajedno. Після da, kad, ako — звичайний порядок слів, короткі слова одразу після сполучника: Mislim da te razumijem.', 'Mislim da… · Kad… · Ako…', '[{"hr": "Mislim da je to dobra ideja.", "ua": "Думаю, що це гарна ідея."}, {"hr": "Kad stigneš, javi se.", "ua": "Коли приїдеш, озвися."}, {"hr": "Ako pada kiša, ostajemo kod kuće.", "ua": "Якщо буде дощ, лишимося вдома."}, {"hr": "Rekla je da kasni.", "ua": "Вона сказала, що запізнюється."}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', 'a369278e-7ecf-5e7b-8260-cb0c82970c2c', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;

-- 2. Перебудова наявних уроків модуля A1.9
-- A1.9 · урок 77: Почуття і настрій — перебудова: 13 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'fac55dd6-0020-5997-8461-45ee2f94d3c5';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Почуття і настрій» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '90ea1e84-1bed-5d1c-a6cd-cec2cb4906e0') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 77: Почуття і настрій', title_hr = 'Lekcija 77: Osjećaji i raspoloženje',
         objectives = '["Сказати, як ви почуваєтеся: razočaran, uzbuđen, bijesan", "Поцікавитися настроєм іншого", "Давальний: drago mi je, žao mi je, dosadno mi je"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Короткі форми давального: sviđa mi se' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Короткі форми давального: sviđa mi se»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'osjećaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobro raspoložen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'loše volje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zadovoljan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opušten', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razočaran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uzbuđen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljubomoran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bijesan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uplašen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brinuti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sram', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponosan', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b25dceb-f32f-54d9-ba1b-aada75918a71', 'fill_in_the_blank', 'Žao ___ je, nisam mogla doći.', 'mi', '["me", "mi", "moj", "ja"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '44f62a36-9c4d-5b94-95ae-98d52ea55a79', 'multiple_choice', 'Що означає «loše volje»?', 'не в гуморі, у поганому настрої', '["почуття", "не в гуморі, у поганому настрої", "розлючений", "схвильований (радісно)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'loše volje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ebe6a674-5e9f-5dab-acd3-b4ebf570e881', 'multiple_choice', 'Що означає «uzbuđen»?', 'схвильований (радісно)', '["почуття", "схвильований (радісно)", "розслаблений", "не в гуморі, у поганому настрої"]'::jsonb, 'A1', 3, 'PUBLISHED', 'uzbuđen', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '704fab4c-3d25-534c-b6dc-8c61f330002f', 'multiple_choice', 'Що означає «ponosan»?', 'гордий; який пишається', '["гордий; який пишається", "сором", "у гарному настрої", "схвильований (радісно)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'ponosan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '682795ce-e8f8-5cab-b3e4-a1747817af57', 'multiple_choice', 'Як хорватською «задоволений»?', 'zadovoljan', '["sram", "zadovoljan", "ljubomoran", "razočaran"]'::jsonb, 'A1', 5, 'PUBLISHED', 'zadovoljan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd539289d-9664-5eef-b231-5ad3e8f20adc', 'multiple_choice', 'Як хорватською «ревнивий; заздрісний»?', 'ljubomoran', '["zadovoljan", "sram", "brinuti se", "ljubomoran"]'::jsonb, 'A1', 6, 'PUBLISHED', 'ljubomoran', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b14e2298-dce3-56c4-80b3-ba5b261594dd', 'type_answer', 'Напишіть хорватською: «розслаблений»', 'opušten', null, 'A1', 7, 'PUBLISHED', 'opušten', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c98511c-b3b3-5c74-b37a-bca7c45e71fb', 'type_answer', 'Напишіть хорватською: «розлючений»', 'bijesan', null, 'A1', 8, 'PUBLISHED', 'bijesan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2b26b677-c266-5b81-935e-d1ef39ad643b', 'type_answer', 'Напишіть хорватською: «розчарований»', 'razočaran', null, 'A1', 9, 'PUBLISHED', 'razočaran', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '26acda20-693b-58ee-bd60-775f62ea4c43', 'sentence_builder', 'Складіть: «Мені дуже шкода.»', 'Jako mi je žao.', '["žao.", "je", "mi", "Jako"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '999b6884-9373-51cb-ab84-ae2cf185df81', 'sentence_builder', 'Складіть: «Я розчарований.»', 'Razočaran sam.', '["sam.", "Razočaran"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '408fab47-0bb1-5fdb-be01-cf42c34fb702', 'listening', 'Прослухайте і складіть фразу', 'Znam, ali brinem se zbog novca.', '["novca.", "Znam,", "zbog", "ali", "brinem", "se"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd4895871-5527-5ca0-98fb-a419d8e5553d', 'listening', 'Прослухайте і складіть фразу', 'A sad je uzbuđen?', '["sad", "uzbuđen?", "A", "je"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd8421f30-87ce-51b1-9181-225e92173941', 'speaking', 'Що з тобою?', 'Što ti je?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fbe127bf-7007-5255-83e0-dad1d766325d', 'speaking', 'Я пишаюся тобою.', 'Ponosna sam na tebe.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('90ea1e84-1bed-5d1c-a6cd-cec2cb4906e0', v_lesson, 'Що з тобою?', 'Što ti je?', 3771, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('6c0e1ebc-6d26-57c2-98ff-4ffdadcfb755', '90ea1e84-1bed-5d1c-a6cd-cec2cb4906e0', 'Luka', 'Dašo, što ti je? Loše si volje.', 'Дашо, що з тобою? Ти не в гуморі.', 1);
  perform pg_temp.turn('26bae025-a687-5225-95dc-86f5ddf07e87', '90ea1e84-1bed-5d1c-a6cd-cec2cb4906e0', 'Daša', 'Razočarana sam. Nisam dobila posao.', 'Я розчарована. Мене не взяли на роботу.', 2);
  perform pg_temp.turn('e560e991-debc-53d8-a467-fa472985480d', '90ea1e84-1bed-5d1c-a6cd-cec2cb4906e0', 'Luka', 'Žao mi je. Ali drugi put će biti bolje.', 'Мені шкода. Але наступного разу буде краще.', 3);
  perform pg_temp.turn('30ed0f98-b3f2-557c-951a-8a925b7a8c3c', '90ea1e84-1bed-5d1c-a6cd-cec2cb4906e0', 'Daša', 'Znam, ali brinem se zbog novca.', 'Знаю, але я хвилююся через гроші.', 4);
  perform pg_temp.turn('ed2e52e9-61b2-53e4-b4bc-9f18243592af', '90ea1e84-1bed-5d1c-a6cd-cec2cb4906e0', 'Luka', 'Ne brini, imamo dovoljno do kraja mjeseca.', 'Не хвилюйся, нам вистачить до кінця місяця.', 5);
  perform pg_temp.turn('778edf80-25df-5a58-b4ab-71ce699a6189', '90ea1e84-1bed-5d1c-a6cd-cec2cb4906e0', 'Daša', 'Hvala ti. S tobom sam uvijek opuštenija.', 'Дякую. З тобою я завжди спокійніша.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0a838bee-eaee-5a71-b08a-70e4e0f4cab2', v_lesson, 'Великий день', 'Veliki dan', 3772, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('f3174497-b2e7-53e1-bfb4-d6e76051bb6b', '0a838bee-eaee-5a71-b08a-70e4e0f4cab2', 'Marko', 'Darja, danas si baš dobro raspoložena!', 'Даріє, ти сьогодні в чудовому настрої!', 1);
  perform pg_temp.turn('76bd747b-121d-5186-ac43-fc1555041993', '0a838bee-eaee-5a71-b08a-70e4e0f4cab2', 'Darja', 'Jesam! Filip je dobio nagradu u školi.', 'Так! Філіп отримав нагороду в школі.', 2);
  perform pg_temp.turn('b9e75820-96b2-5310-82e5-b01ddee442f0', '0a838bee-eaee-5a71-b08a-70e4e0f4cab2', 'Marko', 'Bravo! Sigurno si ponosna.', 'Браво! Ти, мабуть, пишаєшся.', 3);
  perform pg_temp.turn('0a8e0257-5eb8-5b1f-9626-44ef23b19ddd', '0a838bee-eaee-5a71-b08a-70e4e0f4cab2', 'Darja', 'Jako. On je bio uplašen prije natjecanja.', 'Дуже. Він був наляканий перед змаганням.', 4);
  perform pg_temp.turn('72da06e9-1550-50e3-8dda-51497efe2bde', '0a838bee-eaee-5a71-b08a-70e4e0f4cab2', 'Marko', 'A sad je uzbuđen?', 'А тепер схвильований?', 5);
  perform pg_temp.turn('9cafee46-d0d4-5553-aa06-da437c4aac46', '0a838bee-eaee-5a71-b08a-70e4e0f4cab2', 'Darja', 'Da, a sestra je malo ljubomorna.', 'Так, а сестра трохи ревнує.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 78: Запрошення — перебудова: 12 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '3ed8282d-b9fa-5151-b184-73fd352f8ba7';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Запрошення» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'b2e86525-a790-5cf3-87ce-734d9e063a43') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 78: Запрошення', title_hr = 'Lekcija 78: Poziv',
         objectives = '["Запросити на свято чи вечірку", "Прийняти або ввічливо відмовитися", "Модальні: možeš li doći, moram raditi, hoćeš li"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Модальні дієслова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Модальні дієслова»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'pozivnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pozvati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'proslaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'domjenak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svečan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pratnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prihvatiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odbiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rado', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nemam vremena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'htjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'moći', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cf35dac4-bf53-53a5-b54e-5f20df95f579', 'fill_in_the_blank', 'Možeš li ___ u subotu?', 'doći', '["dođeš", "dolaziš", "doći", "došao"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f31817af-a6d1-59d0-bf51-04de78bdb825', 'multiple_choice', 'Що означає «rado»?', 'охоче; із задоволенням', '["у мене немає часу", "запрошення", "охоче; із задоволенням", "могти"]'::jsonb, 'A1', 2, 'PUBLISHED', 'rado', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa7582f2-7f6c-5ea5-86ff-314450b9d85e', 'multiple_choice', 'Що означає «nemam vremena»?', 'у мене немає часу', '["запрошення", "у мене немає часу", "хотіти", "супровід; партнер (на захід)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'nemam vremena', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '55cf445d-7bc7-5925-82e7-b47393d05118', 'multiple_choice', 'Що означає «pratnja»?', 'супровід; партнер (на захід)', '["хотіти", "відмовити", "супровід; партнер (на захід)", "прийняти"]'::jsonb, 'A1', 4, 'PUBLISHED', 'pratnja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e3a1cb33-fc94-5040-9555-5395c0d1e56e', 'multiple_choice', 'Як хорватською «святковий, урочистий»?', 'svečan', '["rado", "svečan", "pratnja", "prihvatiti"]'::jsonb, 'A1', 5, 'PUBLISHED', 'svečan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f360ca25-9d42-566c-bc79-79f0e8663cd4', 'multiple_choice', 'Як хорватською «прийняти»?', 'prihvatiti', '["prihvatiti", "domjenak", "svečan", "pratnja"]'::jsonb, 'A1', 6, 'PUBLISHED', 'prihvatiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bc795b0b-20c1-5355-b231-bbd3afbf8547', 'type_answer', 'Напишіть хорватською: «могти»', 'moći', null, 'A1', 7, 'PUBLISHED', 'moći', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0601890b-406b-57e4-9b12-a2f5644d840e', 'type_answer', 'Напишіть хорватською: «запросити»', 'pozvati', null, 'A1', 8, 'PUBLISHED', 'pozvati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3ac4dbd9-7d69-5f78-8c09-4fea04fcda1b', 'type_answer', 'Напишіть хорватською: «відсвяткувати»', 'proslaviti', null, 'A1', 9, 'PUBLISHED', 'proslaviti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ad46c421-073a-5bc1-bbab-0b2786e04d3c', 'sentence_builder', 'Складіть: «Можеш прийти в суботу?»', 'Možeš li doći u subotu?', '["u", "subotu?", "doći", "li", "Možeš"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '80a14ad4-dddf-5ee1-bf22-c3197f32e4af', 'sentence_builder', 'Складіть: «Дякую за запрошення!»', 'Hvala na pozivu!', '["na", "pozivu!", "Hvala"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cbda549f-2aa7-5e67-afe4-4ef8dc608218', 'listening', 'Прослухайте і складіть фразу', 'Rado! U koliko sati?', '["U", "sati?", "Rado!", "koliko"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a6b7c16d-4547-5a8f-81c0-eb16470631ef', 'listening', 'Прослухайте і складіть фразу', 'Jesam. Treba li svečana odjeća?', '["li", "svečana", "Jesam.", "odjeća?", "Treba"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '36939193-04b1-53ba-926c-fc922b38d59f', 'speaking', 'На жаль, я не можу прийти.', 'Nažalost, ne mogu doći.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e9d2f488-c981-5102-b6c8-8f263a30deb4', 'speaking', 'Що принести?', 'Što da donesem?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b2e86525-a790-5cf3-87ce-734d9e063a43', v_lesson, 'Запрошення на день народження', 'Poziv na rođendan', 3781, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('2afdb70a-dc41-51ba-93cf-eb2bf974d5cd', 'b2e86525-a790-5cf3-87ce-734d9e063a43', 'Ivana', 'Dašo, u subotu slavim rođendan. Možeš li doći?', 'Дашо, у суботу святкую день народження. Можеш прийти?', 1);
  perform pg_temp.turn('58ab7347-6b93-5eb9-98a7-b88dace5c29e', 'b2e86525-a790-5cf3-87ce-734d9e063a43', 'Daša', 'Rado! U koliko sati?', 'Із задоволенням! О котрій?', 2);
  perform pg_temp.turn('c07b8a49-6ac0-581f-b8e9-18ee01bf9f33', 'b2e86525-a790-5cf3-87ce-734d9e063a43', 'Ivana', 'U osam, kod mene. Možeš doći s pratnjom.', 'О восьмій, у мене. Можеш прийти з парою.', 3);
  perform pg_temp.turn('846e37f2-f206-5e01-a47d-b76cfd48cee8', 'b2e86525-a790-5cf3-87ce-734d9e063a43', 'Daša', 'Super, doći ću s Lukom. Što da donesem?', 'Чудово, я прийду з Лукою. Що принести?', 4);
  perform pg_temp.turn('e7662bf2-0ef7-5fdb-be3c-a2265c76a191', 'b2e86525-a790-5cf3-87ce-734d9e063a43', 'Ivana', 'Ništa, samo dobro raspoloženje!', 'Нічого, тільки гарний настрій!', 5);
  perform pg_temp.turn('b1fdf272-a14c-5ae0-9a93-28acfe2297af', 'b2e86525-a790-5cf3-87ce-734d9e063a43', 'Daša', 'Hvala na pozivu!', 'Дякую за запрошення!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('990d6166-7e14-5c74-805d-43ec941f305a', v_lesson, 'Корпоратив', 'Domjenak na poslu', 3782, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('84b55351-33ed-5638-8e41-c83d7f0f5f26', '990d6166-7e14-5c74-805d-43ec941f305a', 'Kolegica', 'Marko, jesi li dobio pozivnicu za domjenak?', 'Марку, ти отримав запрошення на корпоратив?', 1);
  perform pg_temp.turn('c6528bbf-dfe5-5ac6-834c-b526840ff4ac', '990d6166-7e14-5c74-805d-43ec941f305a', 'Marko', 'Jesam. Treba li svečana odjeća?', 'Так. Потрібен святковий одяг?', 2);
  perform pg_temp.turn('3e323c86-714d-51c9-8dac-dbada7aebd04', '990d6166-7e14-5c74-805d-43ec941f305a', 'Kolegica', 'Ne mora, ali bez traperica.', 'Не обов’язково, але без джинсів.', 3);
  perform pg_temp.turn('2a828f83-abf8-51a3-a2e0-ac4a1292fcb9', '990d6166-7e14-5c74-805d-43ec941f305a', 'Marko', 'Nažalost, ne mogu doći, nemam vremena.', 'На жаль, я не можу прийти, у мене немає часу.', 4);
  perform pg_temp.turn('80b9ab00-bca0-5825-ad1f-4c94b9f12375', '990d6166-7e14-5c74-805d-43ec941f305a', 'Kolegica', 'Šteta! Šef želi proslaviti dobru godinu.', 'Шкода! Начальник хоче відсвяткувати вдалий рік.', 5);
  perform pg_temp.turn('a5146dd9-5cc1-505b-828c-80ad3761b68c', '990d6166-7e14-5c74-805d-43ec941f305a', 'Marko', 'Onda ne mogu odbiti. Doći ću na sat vremena.', 'Тоді не можу відмовитися. Прийду на годину.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 79: Домовляємося про зустріч — перебудова: 11 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'dde31f54-28b8-505b-aba6-3e578601fccb';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Домовляємося про зустріч» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '950ec5b5-fa2b-52b7-83e4-81e336e05837') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 79: Домовляємося про зустріч', title_hr = 'Lekcija 79: Dogovaramo se',
         objectives = '["Домовитися про похід: де й о котрій зустрічаємося", "Запитати про маршрут і притулок", "Питання: Gdje se nalazimo? U koliko sati? Kako…?"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Побудова питань' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Побудова питань»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'planina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrh', v_pos);
  v_pos := pg_temp.word(v_lesson, 'staza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vidikovac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'planinarski dom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izletnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjesto sastanka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naći se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'okupiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'javiti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2e0a563a-cc2a-5c8f-b475-029e1c0a857f', 'fill_in_the_blank', '___ se nalazimo?', 'Gdje', '["Kamo", "Što", "Tko", "Gdje"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '83d511d2-520f-50a4-858c-45ed7388a9ac', 'multiple_choice', 'Що означає «okupiti se»?', 'зібратися (разом)', '["зустрітися", "повідомити", "оглядовий майданчик", "зібратися (разом)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'okupiti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2cedafdf-f084-5aca-bb7e-455c3f80b151', 'multiple_choice', 'Що означає «izletnik»?', 'турист (на прогулянці, у поході)', '["місце зустрічі", "гірський притулок", "вершина", "турист (на прогулянці, у поході)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'izletnik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '212c21ff-44a9-5bf8-9ad3-fab1b7868ae0', 'multiple_choice', 'Що означає «vidikovac»?', 'оглядовий майданчик', '["гора / гірський масив", "оглядовий майданчик", "турист (на прогулянці, у поході)", "зустрітися"]'::jsonb, 'A1', 4, 'PUBLISHED', 'vidikovac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '788ec1da-793a-5509-9688-6c54d543a1c9', 'multiple_choice', 'Що означає «javiti»?', 'повідомити', '["повідомити", "місце зустрічі", "ходьба", "гірський притулок"]'::jsonb, 'A1', 5, 'PUBLISHED', 'javiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6127c889-7b0e-5943-ae66-334048659c18', 'multiple_choice', 'Як хорватською «вершина»?', 'vrh', '["vrh", "hod", "izletnik", "staza"]'::jsonb, 'A1', 6, 'PUBLISHED', 'vrh', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e21c06c-911f-5107-b117-4746537a04a4', 'multiple_choice', 'Як хорватською «зустрітися»?', 'naći se', '["vidikovac", "javiti", "naći se", "hod"]'::jsonb, 'A1', 7, 'PUBLISHED', 'naći se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8574e311-5f3f-576d-aae5-d780781aefde', 'type_answer', 'Напишіть хорватською: «стежка; доріжка»', 'staza', null, 'A1', 8, 'PUBLISHED', 'staza', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b6810b41-09fd-5de5-b39c-f4d35515f0d9', 'type_answer', 'Напишіть хорватською: «ходьба»', 'hod', null, 'A1', 9, 'PUBLISHED', 'hod', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '261e967e-e041-5eec-97ca-798aaa2ea14b', 'sentence_builder', 'Складіть: «Де зустрічаємося?»', 'Gdje se nalazimo sutra?', '["se", "nalazimo", "Gdje", "sutra?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a8c565f8-ce7c-57cb-a863-6c6a0ff0789f', 'sentence_builder', 'Складіть: «Стежка важка?»', 'Je li staza teška?', '["Je", "staza", "li", "teška?"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '98b703e7-6bd5-503c-b24d-d69011276a9a', 'listening', 'Прослухайте і складіть фразу', 'Može! Gdje se nalazimo?', '["Gdje", "se", "Može!", "nalazimo?"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8876a06e-d73c-51e6-bc9c-5b8588f49c9d', 'listening', 'Прослухайте і складіть фразу', 'Danas je ovdje puno izletnika.', '["Danas", "je", "izletnika.", "puno", "ovdje"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eba1a401-1cd1-52ef-a847-644d646e7a37', 'speaking', 'О котрій зустрічаємося?', 'U koliko sati se nalazimo?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '41083acd-ab1e-5147-bb8c-6559e79d22fa', 'speaking', 'Зустріньмося біля входу.', 'Nađimo se kod ulaza.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('950ec5b5-fa2b-52b7-83e4-81e336e05837', v_lesson, 'Похід на Слеме', 'Izlet na Sljeme', 3791, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('2fcc3a83-6e97-521e-ba3f-234d82ecfa09', '950ec5b5-fa2b-52b7-83e4-81e336e05837', 'Marko', 'Dašo, idemo li u nedjelju na Sljeme?', 'Дашо, підемо в неділю на Слеме?', 1);
  perform pg_temp.turn('81431d1a-a552-5bfc-a913-adc21e9e47b4', '950ec5b5-fa2b-52b7-83e4-81e336e05837', 'Daša', 'Može! Gdje se nalazimo?', 'Давай! Де зустрічаємося?', 2);
  perform pg_temp.turn('36ea66b6-6b10-5d6a-b389-cb9cd7595ddf', '950ec5b5-fa2b-52b7-83e4-81e336e05837', 'Marko', 'Mjesto sastanka je na tramvajskoj stanici Mihaljevac.', 'Місце зустрічі — на трамвайній зупинці Михалевац.', 3);
  perform pg_temp.turn('2a550c01-04fc-5584-a344-465f88c0467b', '950ec5b5-fa2b-52b7-83e4-81e336e05837', 'Daša', 'U koliko sati?', 'О котрій?', 4);
  perform pg_temp.turn('46152a49-6d99-5041-8fff-54b696733bde', '950ec5b5-fa2b-52b7-83e4-81e336e05837', 'Marko', 'U osam. Do vrha je dva sata hoda.', 'О восьмій. До вершини дві години ходьби.', 5);
  perform pg_temp.turn('34a322d6-0a1e-5727-bfa3-e434051c07d1', '950ec5b5-fa2b-52b7-83e4-81e336e05837', 'Daša', 'Je li staza teška?', 'Стежка важка?', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('39c4d534-05a1-5d0f-8412-3292fc97bc92', v_lesson, 'На вершині', 'Na vrhu', 3792, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('5020237b-654d-530a-91b5-982c09629a20', '39c4d534-05a1-5d0f-8412-3292fc97bc92', 'Darja', 'Kako je lijep pogled s vidikovca!', 'Який гарний вигляд з оглядового майданчика!', 1);
  perform pg_temp.turn('64569995-fed7-5369-960d-303f3bf45a04', '39c4d534-05a1-5d0f-8412-3292fc97bc92', 'Luka', 'Danas je ovdje puno izletnika.', 'Сьогодні тут багато туристів.', 2);
  perform pg_temp.turn('cde45fb5-4747-588f-b886-2f064557842e', '39c4d534-05a1-5d0f-8412-3292fc97bc92', 'Darja', 'Gdje je planinarski dom?', 'Де гірський притулок?', 3);
  perform pg_temp.turn('b66b1d64-64dd-5be6-b02a-fbe9edadbd1b', '39c4d534-05a1-5d0f-8412-3292fc97bc92', 'Luka', 'Malo niže. Tamo se okupljamo s ostalima.', 'Трохи нижче. Там ми збираємося з іншими.', 4);
  perform pg_temp.turn('948a6038-7c04-5a88-b99a-097fc5c4db71', '39c4d534-05a1-5d0f-8412-3292fc97bc92', 'Darja', 'Kad stignu, javi mi.', 'Коли вони прийдуть, скажи мені.', 5);
  perform pg_temp.turn('d44f8755-bf5f-569f-8120-9753363e1705', '39c4d534-05a1-5d0f-8412-3292fc97bc92', 'Luka', 'Hoću. Nađimo se kod ulaza za pola sata.', 'Добре. Зустріньмося біля входу за пів години.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 80: Хобі — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '1c16ceee-5f42-536a-98b4-7dcabaa3be6d';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Хобі» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '8ca78224-e694-5167-8008-510e2966bb97') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 80: Хобі', title_hr = 'Lekcija 80: Hobiji',
         objectives = '["Розповісти про своє хобі: šah, vrtlarenje, pecati", "Запитати про чуже хобі й вільний час", "Теперішній час: igram, pletem, skupljam"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Теперішній час' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Теперішній час»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'hobi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slobodno vrijeme', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slikati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crtati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plesti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šivati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pjevati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plesati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šah', v_pos);
  v_pos := pg_temp.word(v_lesson, 'društvene igre', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pecati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrtlarenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skupljati', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '17a5827d-31aa-5efb-83cf-3fd54bf89e8e', 'fill_in_the_blank', 'Moja baka ___ džemper za mene.', 'plete', '["pleteš", "plete", "plesti", "pletem"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8817073-b92d-5672-b11a-edcf62719f76', 'multiple_choice', 'Що означає «svirati»?', 'грати (на інструменті)', '["рибалити, ловити рибу (вудкою)", "садівництво, робота в саду", "грати (на інструменті)", "малювати (фарбами); фотографувати"]'::jsonb, 'A1', 2, 'PUBLISHED', 'svirati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '93241859-4b0b-57e5-a042-3b61f4bf604d', 'multiple_choice', 'Що означає «vrtlarenje»?', 'садівництво, робота в саду', '["малювати (фарбами); фотографувати", "співати", "садівництво, робота в саду", "шити"]'::jsonb, 'A1', 3, 'PUBLISHED', 'vrtlarenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6cd5b057-fbfc-5573-ad51-277da6e8d1de', 'multiple_choice', 'Що означає «hobi»?', 'хобі / улюблена справа', '["хобі / улюблена справа", "шахи", "малювати (фарбами); фотографувати", "танцювати"]'::jsonb, 'A1', 4, 'PUBLISHED', 'hobi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e92669b8-007e-58ef-822b-f133be71290a', 'multiple_choice', 'Як хорватською «в''язати»?', 'plesti', '["pecati", "plesti", "hobi", "crtati"]'::jsonb, 'A1', 5, 'PUBLISHED', 'plesti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ad69baa4-fb73-54ef-8a87-40757f8c4a84', 'multiple_choice', 'Як хорватською «шахи»?', 'šah', '["šah", "plesti", "slobodno vrijeme", "plesati"]'::jsonb, 'A1', 6, 'PUBLISHED', 'šah', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0ce89c87-864d-5feb-b635-8cfde4e99e0d', 'type_answer', 'Напишіть хорватською: «настільні ігри»', 'društvene igre', null, 'A1', 7, 'PUBLISHED', 'društvene igre', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4d0f09e2-a38a-5c40-b8a4-97b73f1e89be', 'type_answer', 'Напишіть хорватською: «танцювати»', 'plesati', null, 'A1', 8, 'PUBLISHED', 'plesati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8f662537-bfdf-5343-8fd5-d6b2793dad2b', 'type_answer', 'Напишіть хорватською: «співати»', 'pjevati', null, 'A1', 9, 'PUBLISHED', 'pjevati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5bd87ad7-2dd7-50de-8869-8186933a8887', 'sentence_builder', 'Складіть: «Я граю на гітарі.»', 'Sviram gitaru.', '["gitaru.", "Sviram"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '47cbd78b-1ce3-5b40-8e5c-ce9bccead07c', 'sentence_builder', 'Складіть: «Яке в тебе хобі?»', 'Koji je tvoj hobi?', '["je", "Koji", "hobi?", "tvoj"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '66b91cd5-9abe-5ef6-b6dc-74e37ce285e7', 'listening', 'Прослухайте і складіть фразу', 'Pletem i šivam. A zimi slikam.', '["šivam.", "slikam.", "zimi", "A", "Pletem", "i"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e0628d00-01c5-52b2-8c37-9c5a6f22e12a', 'listening', 'Прослухайте і складіть фразу', 'Mama više voli plesati!', '["plesati!", "Mama", "više", "voli"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '78126999-8f9f-5f33-aaab-42fe7292115d', 'speaking', 'Я граю в шахи з дідусем.', 'Igram šah s djedom.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2fb678a1-476b-5d27-9663-e14f2eddeaf2', 'speaking', 'Що ти робиш у вільний час?', 'Što radiš u slobodno vrijeme?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8ca78224-e694-5167-8008-510e2966bb97', v_lesson, 'Що ти робиш у вільний час?', 'Što radiš u slobodno vrijeme?', 3801, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('f158d802-2748-5482-877a-0036594318f0', '8ca78224-e694-5167-8008-510e2966bb97', 'Ivana', 'Dašo, imaš li neki hobi?', 'Дашо, у тебе є якесь хобі?', 1);
  perform pg_temp.turn('ddac8044-8cac-5854-9c26-1c46287bb642', '8ca78224-e694-5167-8008-510e2966bb97', 'Daša', 'Pletem i šivam. A zimi slikam.', 'В’яжу й шию. А взимку малюю.', 2);
  perform pg_temp.turn('d9747296-ca50-5cb6-8b80-b7ef32d60b98', '8ca78224-e694-5167-8008-510e2966bb97', 'Ivana', 'Super! Ja pjevam u zboru i sviram gitaru.', 'Чудово! Я співаю в хорі й граю на гітарі.', 3);
  perform pg_temp.turn('1a365872-5c11-5202-9646-f3ac8f3a764b', '8ca78224-e694-5167-8008-510e2966bb97', 'Daša', 'A tvoj muž?', 'А твій чоловік?', 4);
  perform pg_temp.turn('f429b7c8-d4e6-54c8-8768-f63ae322ca5f', '8ca78224-e694-5167-8008-510e2966bb97', 'Ivana', 'On peca vikendom, a ljeti uživa u vrtlarenju.', 'Він рибалить на вихідних, а влітку з задоволенням порається в саду.', 5);
  perform pg_temp.turn('a1370881-cee7-5afb-bb8d-54eb1861daf9', '8ca78224-e694-5167-8008-510e2966bb97', 'Daša', 'Kod nas Luka skuplja stare razglednice.', 'А в нас Лука збирає старі листівки.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4a1a3749-8411-5686-9680-fc5a3ce5d503', v_lesson, 'Ігровий вечір', 'Večer igara', 3802, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('31d2967f-951b-5215-84ad-75045bf2ad9f', '4a1a3749-8411-5686-9680-fc5a3ce5d503', 'Filip', 'Tata, igramo li večeras šah?', 'Тату, зіграємо сьогодні в шахи?', 1);
  perform pg_temp.turn('82a7d7a4-709e-53e3-9fe4-0d6dc58c9bd9', '4a1a3749-8411-5686-9680-fc5a3ce5d503', 'Luka', 'Može, a poslije društvene igre s mamom.', 'Давай, а потім настільні ігри з мамою.', 2);
  perform pg_temp.turn('ebdc5b65-606c-53a4-9c05-8324ed024d0b', '4a1a3749-8411-5686-9680-fc5a3ce5d503', 'Filip', 'Mama više voli plesati!', 'Мама більше любить танцювати!', 3);
  perform pg_temp.turn('e448c1da-6f2f-54e2-a73b-e63437ca2f9a', '4a1a3749-8411-5686-9680-fc5a3ce5d503', 'Luka', 'Istina, ona pleše svake srijede.', 'Правда, вона танцює щосереди.', 4);
  perform pg_temp.turn('f8381ca9-f5bc-56c4-b399-f192e8d97723', '4a1a3749-8411-5686-9680-fc5a3ce5d503', 'Filip', 'A ja crtam stripove.', 'А я малюю комікси.', 5);
  perform pg_temp.turn('4beb6d81-9aff-5314-9812-d321267618ab', '4a1a3749-8411-5686-9680-fc5a3ce5d503', 'Luka', 'Pokaži mi novi crtež poslije šaha.', 'Покажи мені новий малюнок після шахів.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 81: Спорт і матчі — перебудова: 19 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'e61e3942-cd86-5f75-9eb5-d878242125bf';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Спорт і матчі» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '7a3b9a5b-dd34-583a-b35c-3eb77208c0e6') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 81: Спорт і матчі', title_hr = 'Lekcija 81: Sport i utakmice',
         objectives = '["Поговорити про види спорту й тренування", "Розповісти про матч: tko je pobijedio, neriješeno", "Минулий час: pobijedili smo, igrao je"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Минулий час: radio sam, bila sam»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'sport', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nogomet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'košarka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rukomet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odbojka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tenis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plivati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trening', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trener', v_pos);
  v_pos := pg_temp.word(v_lesson, 'utakmica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'momčad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'igrač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'igrati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lopta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'navijati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'navijač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pobijediti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neriješeno', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '7a09fbf6-6b23-5247-9a4d-ed0b6a5ffecd', 'fill_in_the_blank', 'Jučer smo ___ dva nula!', 'pobijedili', '["pobijediti", "pobijedili", "pobjeda", "pobijedimo"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f480be5c-0ca3-5f27-93c7-7d6e3d6ff828', 'multiple_choice', 'Що означає «rukomet»?', 'гандбол', '["команда (спортивна)", "гол", "гандбол", "спорт"]'::jsonb, 'A1', 2, 'PUBLISHED', 'rukomet', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9fc1b254-2df7-5935-8a14-84446d2c172c', 'multiple_choice', 'Що означає «lopta»?', 'м''яч', '["м''яч", "матч / гра", "команда (спортивна)", "тренер"]'::jsonb, 'A1', 3, 'PUBLISHED', 'lopta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3f0f6322-a2f5-5e81-aa87-e68d15c6048d', 'multiple_choice', 'Що означає «pobijediti»?', 'перемогти', '["перемогти", "волейбол", "тренер", "баскетбол"]'::jsonb, 'A1', 4, 'PUBLISHED', 'pobijediti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3469e7a0-3d02-5a2d-a9c1-1719c3787f67', 'multiple_choice', 'Як хорватською «гравець»?', 'igrač', '["gol", "igrač", "rukomet", "trening"]'::jsonb, 'A1', 5, 'PUBLISHED', 'igrač', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8df0da23-2d2b-5d6f-bf2b-f42b14d18a68', 'multiple_choice', 'Як хорватською «волейбол»?', 'odbojka', '["igrati", "odbojka", "košarka", "igrač"]'::jsonb, 'A1', 6, 'PUBLISHED', 'odbojka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c448bd4f-b02e-5036-b924-fd7b053bdc6b', 'type_answer', 'Напишіть хорватською: «гол»', 'gol', null, 'A1', 7, 'PUBLISHED', 'gol', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fce56f90-0f64-5765-9ffd-9d8daae91fff', 'type_answer', 'Напишіть хорватською: «тренер»', 'trener', null, 'A1', 8, 'PUBLISHED', 'trener', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8ea1291f-b785-5550-a58a-de164db3aa98', 'type_answer', 'Напишіть хорватською: «вболівальник»', 'navijač', null, 'A1', 9, 'PUBLISHED', 'navijač', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9f6f9ce7-2884-59ce-bb13-38316d080336', 'sentence_builder', 'Складіть: «Хто переміг?»', 'Tko je pobijedio?', '["je", "Tko", "pobijedio?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3f11290e-6677-5e50-8792-f71020b64e28', 'sentence_builder', 'Складіть: «Я вболіваю за Хорватію.»', 'Navijam za Hrvatsku.', '["Hrvatsku.", "za", "Navijam"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cc4133da-ee1f-524b-9a79-93616e216706', 'listening', 'Прослухайте і складіть фразу', 'Tko je zabio drugi gol?', '["zabio", "gol?", "drugi", "je", "Tko"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bda77e56-eafa-5206-b558-0df69f1026b8', 'listening', 'Прослухайте і складіть фразу', 'On voli loptu, ali i plivati.', '["plivati.", "voli", "On", "i", "loptu,", "ali"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8c5326b6-d1c4-5d6c-8793-241ab50cacc2', 'speaking', 'Матч закінчився нічиєю.', 'Utakmica je završila neriješeno.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '14acd781-ec8d-5bb4-a33f-b752520eaf73', 'speaking', 'Я граю в теніс.', 'Igram tenis.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7a3b9a5b-dd34-583a-b35c-3eb77208c0e6', v_lesson, 'Ти дивився матч?', 'Jesi li gledao utakmicu?', 3811, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('8f2df2bb-136b-54ba-897c-5d90be61378b', '7a3b9a5b-dd34-583a-b35c-3eb77208c0e6', 'Luka', 'Marko, jesi li sinoć gledao utakmicu?', 'Марку, ти вчора дивився матч?', 1);
  perform pg_temp.turn('5377021e-6068-5a3e-b84d-e592dfd9778c', '7a3b9a5b-dd34-583a-b35c-3eb77208c0e6', 'Marko', 'Jesam! Hrvatska je pobijedila dva jedan.', 'Так! Хорватія перемогла два — один.', 2);
  perform pg_temp.turn('c8e065d1-a405-5528-8d77-681d0fba8553', '7a3b9a5b-dd34-583a-b35c-3eb77208c0e6', 'Luka', 'Tko je zabio drugi gol?', 'Хто забив другий гол?', 3);
  perform pg_temp.turn('f3ac79d7-5503-50a1-8d8e-5738677f2d4f', '7a3b9a5b-dd34-583a-b35c-3eb77208c0e6', 'Marko', 'Mladi igrač iz Dinama, u zadnjoj minuti.', 'Молодий гравець «Динамо», на останній хвилині.', 4);
  perform pg_temp.turn('d89345dd-76ec-5abb-aa0d-8d36b18f4ad4', '7a3b9a5b-dd34-583a-b35c-3eb77208c0e6', 'Luka', 'Super! Prošli put je bilo neriješeno.', 'Чудово! Минулого разу була нічия.', 5);
  perform pg_temp.turn('db091676-a3aa-5807-b020-6d7f463cabde', '7a3b9a5b-dd34-583a-b35c-3eb77208c0e6', 'Marko', 'Navijači su slavili cijelu noć.', 'Уболівальники святкували всю ніч.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5de77632-4e64-5d52-ae4e-76787e1b6d50', v_lesson, 'Який спорт обрати?', 'Koji sport?', 3812, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('0cb841c5-c9e8-5291-95a1-6e0cee61b001', '5de77632-4e64-5d52-ae4e-76787e1b6d50', 'Daša', 'Filip želi trenirati. Koji sport preporučuješ?', 'Філіп хоче займатися спортом. Який вид порадиш?', 1);
  perform pg_temp.turn('de3e41a9-5492-5551-9f4b-91bfa7a33e8f', '5de77632-4e64-5d52-ae4e-76787e1b6d50', 'Ana', 'Rukomet ili košarka, ovdje su jako popularni.', 'Гандбол або баскетбол, тут вони дуже популярні.', 2);
  perform pg_temp.turn('6e64479c-a39d-5fa7-b27e-d9971d526732', '5de77632-4e64-5d52-ae4e-76787e1b6d50', 'Daša', 'On voli loptu, ali i plivati.', 'Він любить м’яч, але й плавати.', 3);
  perform pg_temp.turn('8ae4e7bf-1841-56c2-9c38-ac0bef2f2566', '5de77632-4e64-5d52-ae4e-76787e1b6d50', 'Ana', 'Moja kći trenira odbojku. Trener je odličan.', 'Моя донька займається волейболом. Тренер чудовий.', 4);
  perform pg_temp.turn('2ee47f24-f3f6-590c-9957-7dd0f1d09e91', '5de77632-4e64-5d52-ae4e-76787e1b6d50', 'Daša', 'Koliko puta tjedno imaju trening?', 'Скільки разів на тиждень у них тренування?', 5);
  perform pg_temp.turn('cc20b77a-0b8e-5c45-b30a-6eaa27106728', '5de77632-4e64-5d52-ae4e-76787e1b6d50', 'Ana', 'Triput, a vikendom igraju utakmice za momčad škole.', 'Тричі, а на вихідних грають матчі за шкільну команду.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 82: Театр, кіно й концерти — перебудова: 15 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '631c7f59-de43-5081-adb7-77bdf23ce805';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Театр, кіно й концерти» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'ea606448-9c44-5783-bee8-c9e75875dee5') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 82: Театр, кіно й концерти', title_hr = 'Lekcija 82: Kazalište, kino i koncerti',
         objectives = '["Обрати виставу, концерт чи фестиваль", "Купити квитки й поділитися враженнями", "Місцевий: u kazalištu, na koncertu, na premijeri"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Місцевий відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Місцевий відмінок»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'koncert', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predstava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'premijera', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opera', v_pos);
  v_pos := pg_temp.word(v_lesson, 'balet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pjevač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glumac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bend', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nastup', v_pos);
  v_pos := pg_temp.word(v_lesson, 'publika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pozornica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pljeskati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'festival', v_pos);
  v_pos := pg_temp.word(v_lesson, 'umjetnost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ulaznica', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c10dea38-5421-52ab-ba7f-cead1d444a0c', 'fill_in_the_blank', 'Bili smo na ___ u subotu.', 'koncertu', '["koncert", "koncerta", "koncertu", "koncertom"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7130c675-535d-5272-b0d1-6a2e20ea49a9', 'multiple_choice', 'Що означає «bend»?', 'гурт (музичний)', '["прем’єра", "мистецтво", "вхідний квиток", "гурт (музичний)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'bend', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b02109da-7d0e-525d-a7de-3c91f0db81ed', 'multiple_choice', 'Що означає «koncert»?', 'концерт', '["фестиваль", "концерт", "актор", "прем’єра"]'::jsonb, 'A1', 3, 'PUBLISHED', 'koncert', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd0de1810-68d6-597f-b535-b2c3a04bac27', 'multiple_choice', 'Що означає «balet»?', 'балет', '["фестиваль", "балет", "опера", "мистецтво"]'::jsonb, 'A1', 4, 'PUBLISHED', 'balet', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eaaab486-7b0e-5b0f-bae5-c81ec206aa60', 'multiple_choice', 'Як хорватською «виступ»?', 'nastup', '["nastup", "pozornica", "pjevač", "premijera"]'::jsonb, 'A1', 5, 'PUBLISHED', 'nastup', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '30551cb5-c6f6-5380-87f2-25c6027d04db', 'multiple_choice', 'Як хорватською «співак»?', 'pjevač', '["pjevač", "umjetnost", "bend", "ulaznica"]'::jsonb, 'A1', 6, 'PUBLISHED', 'pjevač', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8c1aedd2-a55f-57f4-9a6f-3fb8adb710ad', 'type_answer', 'Напишіть хорватською: «фестиваль»', 'festival', null, 'A1', 7, 'PUBLISHED', 'festival', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f6d29109-1057-50b9-860a-cfce5729c55c', 'type_answer', 'Напишіть хорватською: «вистава»', 'predstava', null, 'A1', 8, 'PUBLISHED', 'predstava', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be733b71-4a67-536f-94dd-3eb4a760f9b1', 'type_answer', 'Напишіть хорватською: «публіка»', 'publika', null, 'A1', 9, 'PUBLISHED', 'publika', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6ef6781a-358e-5a5e-8522-016f7432bc83', 'sentence_builder', 'Складіть: «Ми були в театрі.»', 'Bili smo u kazalištu.', '["kazalištu.", "u", "Bili", "smo"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '941992db-3fad-5660-9429-c21fd5112630', 'sentence_builder', 'Складіть: «Квитки ще продаються?»', 'Ima li još ulaznica?', '["još", "ulaznica?", "Ima", "li"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2660c995-bd72-54d1-930a-6e91b643e077', 'listening', 'Прослухайте і складіть фразу', 'Je li opera ili balet?', '["balet?", "li", "ili", "Je", "opera"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fc8ff6a8-2854-5124-9e6d-e9546d9a723b', 'listening', 'Прослухайте і складіть фразу', 'Publika je pljeskala deset minuta.', '["Publika", "je", "pljeskala", "minuta.", "deset"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aefb41df-b28a-5ded-a9e1-82d0dfdda1a3', 'speaking', 'Підемо на концерт?', 'Idemo li na koncert?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5acbad4e-0ab3-5652-9633-91400b0c4108', 'speaking', 'Як тобі вистава?', 'Kako ti se svidjela predstava?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ea606448-9c44-5783-bee8-c9e75875dee5', v_lesson, 'Куди підемо?', 'Kamo ćemo izaći?', 3821, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('4bbbe757-acb5-5566-8d2e-4ec24c1c3997', 'ea606448-9c44-5783-bee8-c9e75875dee5', 'Daša', 'Luka, u HNK-u je u petak premijera nove predstave.', 'Луко, у Національному театрі в п’ятницю прем’єра нової вистави.', 1);
  perform pg_temp.turn('c0d2fa47-c973-5673-b865-74aa20236ae5', 'ea606448-9c44-5783-bee8-c9e75875dee5', 'Luka', 'Je li opera ili balet?', 'Це опера чи балет?', 2);
  perform pg_temp.turn('b0105c93-d415-5e74-9293-9440888e4932', 'ea606448-9c44-5783-bee8-c9e75875dee5', 'Daša', 'Balet. Ulaznice su još u prodaji.', 'Балет. Квитки ще продаються.', 3);
  perform pg_temp.turn('64284999-2923-5031-9405-f2b050668b90', 'ea606448-9c44-5783-bee8-c9e75875dee5', 'Luka', 'Može. A u subotu je koncert mog omiljenog benda.', 'Давай. А в суботу концерт мого улюбленого гурту.', 4);
  perform pg_temp.turn('39dad2a3-5de6-53ab-846a-1bf142c215b0', 'ea606448-9c44-5783-bee8-c9e75875dee5', 'Daša', 'Na Šalati? Tamo je ljeti festival.', 'На Шалаті? Там улітку фестиваль.', 5);
  perform pg_temp.turn('ee0af88a-c27b-59a8-830d-e065d11f4088', 'ea606448-9c44-5783-bee8-c9e75875dee5', 'Luka', 'Da, otvoreni koncert. Pjevač je odličan uživo.', 'Так, концерт просто неба. Співак чудовий наживо.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6e731ac0-f9b5-5b4b-af1c-5b9bafb92542', v_lesson, 'Після вистави', 'Poslije predstave', 3822, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('cd60d595-1432-50df-9421-48f3c6eb32ed', '6e731ac0-f9b5-5b4b-af1c-5b9bafb92542', 'Darja', 'Kako ti se svidjela predstava?', 'Як тобі вистава?', 1);
  perform pg_temp.turn('3a8b0888-b82c-56cb-9fa5-98df6f982476', '6e731ac0-f9b5-5b4b-af1c-5b9bafb92542', 'Marko', 'Odlično! Glavni glumac je bio fantastičan.', 'Чудово! Головний актор був неймовірний.', 2);
  perform pg_temp.turn('b21fa84b-ad1a-55c8-8fd7-31ead76262d1', '6e731ac0-f9b5-5b4b-af1c-5b9bafb92542', 'Darja', 'Publika je pljeskala deset minuta.', 'Глядачі аплодували десять хвилин.', 3);
  perform pg_temp.turn('e3f7c9c9-cc1a-5f02-8e3c-436576d22147', '6e731ac0-f9b5-5b4b-af1c-5b9bafb92542', 'Marko', 'I pozornica je bila prekrasna.', 'І сцена була чудова.', 4);
  perform pg_temp.turn('64eac06f-231f-5daf-aa26-695a5aa79f2d', '6e731ac0-f9b5-5b4b-af1c-5b9bafb92542', 'Darja', 'Ovo je prava umjetnost.', 'Оце справжнє мистецтво.', 5);
  perform pg_temp.turn('42859252-30d3-500b-ade4-a3f32f65b74d', '6e731ac0-f9b5-5b4b-af1c-5b9bafb92542', 'Marko', 'Sljedeći nastup gledamo opet zajedno!', 'Наступний виступ знову дивимося разом!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 84: Що ти думаєш? Mislim da… — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'ec1b7982-c092-5504-a233-4162f92f512a';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Що ти думаєш? Mislim da…» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'e04b2d77-c82f-5d66-a375-ec36d3f622ab') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 84: Що ти думаєш? Mislim da…', title_hr = 'Lekcija 84: Što misliš? Mislim da…',
         objectives = '["Висловити думку: Mislim da…, po mom mišljenju", "Погодитися чи не погодитися", "Сполучники: da, kad, ako, jer"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Сполучники' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Сполучники»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'misliti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mišljenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'po mom mišljenju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smatrati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'složiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u pravu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'griješiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vjerovati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sumnjati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'istina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zanimljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dosadan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'film', v_pos);
  v_pos := pg_temp.word(v_lesson, 'knjiga', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '860c7665-cc64-5358-8549-a041d42f87f2', 'fill_in_the_blank', 'Mislim ___ je film dobar.', 'da', '["jer", "da", "ako", "kad"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '205341c6-457b-52ac-a8bb-829765f0fba8', 'multiple_choice', 'Що означає «misliti»?', 'думати / вважати', '["правий (бути правим)", "думати / вважати", "цікавий", "правда"]'::jsonb, 'A1', 2, 'PUBLISHED', 'misliti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '49a0ebba-999b-517c-a6cc-a081a67b8046', 'multiple_choice', 'Що означає «smatrati»?', 'вважати', '["правий (бути правим)", "вірити", "погодитися", "вважати"]'::jsonb, 'A1', 3, 'PUBLISHED', 'smatrati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b07f2ee0-7c6d-55c0-9d21-31c029d87e08', 'multiple_choice', 'Що означає «istina»?', 'правда', '["думка", "помилятися", "сумніватися", "правда"]'::jsonb, 'A1', 4, 'PUBLISHED', 'istina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2dfff591-2236-5602-b60e-c73fe9e73d32', 'multiple_choice', 'Як хорватською «на мою думку»?', 'po mom mišljenju', '["knjiga", "mišljenje", "po mom mišljenju", "griješiti"]'::jsonb, 'A1', 5, 'PUBLISHED', 'po mom mišljenju', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e65a279d-6680-547f-ae09-ba500bb00cfd', 'multiple_choice', 'Як хорватською «думка»?', 'mišljenje', '["film", "po mom mišljenju", "mišljenje", "istina"]'::jsonb, 'A1', 6, 'PUBLISHED', 'mišljenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9cae71a3-5291-52bd-9339-a8a4df172167', 'type_answer', 'Напишіть хорватською: «цікавий»', 'zanimljiv', null, 'A1', 7, 'PUBLISHED', 'zanimljiv', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '32bbb201-44b7-5be0-926e-fb85f4758d5b', 'type_answer', 'Напишіть хорватською: «книга»', 'knjiga', null, 'A1', 8, 'PUBLISHED', 'knjiga', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '485bc968-851b-5ecc-9993-ba059beb2eb7', 'type_answer', 'Напишіть хорватською: «сумніватися»', 'sumnjati', null, 'A1', 9, 'PUBLISHED', 'sumnjati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5afac50d-948b-5990-8e6e-ef35389fd701', 'sentence_builder', 'Складіть: «Думаю, що ти правий.»', 'Mislim da si u pravu.', '["u", "pravu.", "si", "Mislim", "da"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0d99d52e-055d-589e-920d-6c5ff10066b4', 'sentence_builder', 'Складіть: «Я не погоджуюся.»', 'Ne slažem se s tobom.', '["s", "se", "Ne", "tobom.", "slažem"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c3bdecc6-b2a7-593f-b6a0-24a2f7ca23da', 'listening', 'Прослухайте і складіть фразу', 'Možda si u pravu.', '["u", "si", "pravu.", "Možda"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '680fb3c9-448a-5021-bbb9-261bce925545', 'listening', 'Прослухайте і складіть фразу', 'Sumnjam da zovu mamu. Igraju igrice!', '["mamu.", "igrice!", "Igraju", "da", "zovu", "Sumnjam"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c69b0f3b-28bb-520e-89d7-8b4b7e002f06', 'speaking', 'На мою думку, це гарна ідея.', 'Po mom mišljenju, to je dobra ideja.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bd580360-0c38-5948-9673-a18b7dd6801c', 'speaking', 'Що ти думаєш?', 'Što misliš?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e04b2d77-c82f-5d66-a375-ec36d3f622ab', v_lesson, 'Про фільм', 'O filmu', 3841, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('60444479-9e4c-5a4f-abf4-b81b67439c95', 'e04b2d77-c82f-5d66-a375-ec36d3f622ab', 'Ivana', 'Kako ti se čini film?', 'Як тобі фільм?', 1);
  perform pg_temp.turn('0e5bf43f-bd73-5ace-971d-39ceffc3bea2', 'e04b2d77-c82f-5d66-a375-ec36d3f622ab', 'Daša', 'Po mom mišljenju, malo je dosadan.', 'На мою думку, трохи нудний.', 2);
  perform pg_temp.turn('5394bc71-3765-59b6-a2bf-a8e3973e2375', 'e04b2d77-c82f-5d66-a375-ec36d3f622ab', 'Ivana', 'Stvarno? Mislim da je jako zanimljiv.', 'Справді? Я думаю, що він дуже цікавий.', 3);
  perform pg_temp.turn('0add1f77-9b95-5893-8bf0-7c9d37cfb931', 'e04b2d77-c82f-5d66-a375-ec36d3f622ab', 'Daša', 'Glumci su dobri, slažem se, ali priča je spora.', 'Актори добрі, погоджуюся, але сюжет повільний.', 4);
  perform pg_temp.turn('8de1d3cc-7541-500f-b72d-05f892d14350', 'e04b2d77-c82f-5d66-a375-ec36d3f622ab', 'Ivana', 'Možda si u pravu.', 'Може, ти й права.', 5);
  perform pg_temp.turn('06a5da48-e3fc-5049-848a-d25250f196be', 'e04b2d77-c82f-5d66-a375-ec36d3f622ab', 'Daša', 'Ali kraj je bio odličan, to je istina.', 'Але кінець був чудовий, це правда.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5b839be9-dc9c-5008-b340-d95c52249b63', v_lesson, 'Суперечка', 'Rasprava', 3842, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('0b995eaf-aa01-54b7-9a31-e1e10a74a953', '5b839be9-dc9c-5008-b340-d95c52249b63', 'Marko', 'Smatram da djeca ne trebaju mobitel do dvanaeste.', 'Я вважаю, що дітям не потрібен телефон до дванадцяти.', 1);
  perform pg_temp.turn('aa3f3e35-40b7-50a5-9cfb-689587f022bf', '5b839be9-dc9c-5008-b340-d95c52249b63', 'Darja', 'Ne slažem se. Ako ga nemaju, ne mogu nas nazvati.', 'Не погоджуюся. Якщо його немає, вони не можуть нам подзвонити.', 2);
  perform pg_temp.turn('1e3f2410-10d9-5745-b2f3-d17dcae47ecd', '5b839be9-dc9c-5008-b340-d95c52249b63', 'Marko', 'Sumnjam da zovu mamu. Igraju igrice!', 'Сумніваюся, що вони дзвонять мамі. Вони грають в ігри!', 3);
  perform pg_temp.turn('c9b9d298-5c4c-56d8-b36e-314dd7e3a6d9', '5b839be9-dc9c-5008-b340-d95c52249b63', 'Darja', 'Možda griješim, ali vjerujem svom sinu.', 'Можливо, я помиляюся, але я довіряю своєму синові.', 4);
  perform pg_temp.turn('87f61043-1ca1-5eb1-a256-bc12ff5abebb', '5b839be9-dc9c-5008-b340-d95c52249b63', 'Marko', 'Kakvo je tvoje mišljenje o školskim pravilima?', 'Яка твоя думка про шкільні правила?', 5);
  perform pg_temp.turn('e2193caa-aac8-5b7e-a0eb-54997a563300', '5b839be9-dc9c-5008-b340-d95c52249b63', 'Darja', 'Mislim da su dobra, jer su mobiteli zabranjeni na satu.', 'Думаю, що вони добрі, бо на уроках телефони заборонені.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 85: Кохання й стосунки — перебудова: 11 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '0d0547ed-c0ef-53bd-bfe4-c482c84c40f4';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Кохання й стосунки» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '0fd3b312-3c03-5628-a62d-263a46566cc0') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 85: Кохання й стосунки', title_hr = 'Lekcija 85: Ljubav i veze',
         objectives = '["Розповісти про стосунки: veza, zaručili su se, prekinuli su", "Поговорити про побачення", "Присвійні: njegova cura, njezin dečko, svoj"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Присвійні займенники' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Присвійні займенники»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'veza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'simpatija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaljubljen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spoj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poljubac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zagrljaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'romantičan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prekinuti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaručiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dečko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cura', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '4e5f1799-e62d-51a7-ae7f-74fea3182350', 'fill_in_the_blank', 'Ana i ___ dečko su se zaručili.', 'njezin', '["njegov", "moja", "njezin", "njihov"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a24bc55f-f3fb-5574-a73d-a39f3000f554', 'multiple_choice', 'Що означає «cura»?', 'дівчина (романтично)', '["поцілунок", "дівчина (романтично)", "обійми", "заручитися"]'::jsonb, 'A1', 2, 'PUBLISHED', 'cura', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a0e544e-9822-5ea9-9132-a94b0944d3a7', 'multiple_choice', 'Що означає «simpatija»?', 'симпатія (людина, яка подобається)', '["перервати, зупинити; розійтися (prekinuti s nekim)", "симпатія (людина, яка подобається)", "зв’язок; стосунки (бути у стосунках — biti u vezi)", "дівчина (романтично)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'simpatija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9cfee79f-6fb0-55a3-9099-e420e7e015c1', 'multiple_choice', 'Що означає «dečko»?', 'хлопець (романтично)', '["побачення; з''єднання", "обійми", "хлопець (романтично)", "заручитися"]'::jsonb, 'A1', 4, 'PUBLISHED', 'dečko', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ff914be2-a882-5255-9f74-473fa32899ed', 'multiple_choice', 'Як хорватською «обійми»?', 'zagrljaj', '["dečko", "zagrljaj", "spoj", "poljubac"]'::jsonb, 'A1', 5, 'PUBLISHED', 'zagrljaj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4eac8075-ba50-590c-a833-2e898dc694c3', 'multiple_choice', 'Як хорватською «заручитися»?', 'zaručiti se', '["poljubac", "zagrljaj", "veza", "zaručiti se"]'::jsonb, 'A1', 6, 'PUBLISHED', 'zaručiti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ad58f8f3-99e3-5ae4-9002-512cea9a5750', 'type_answer', 'Напишіть хорватською: «закоханий»', 'zaljubljen', null, 'A1', 7, 'PUBLISHED', 'zaljubljen', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'af10ac2a-a812-562e-b5e4-8a87be0cc195', 'type_answer', 'Напишіть хорватською: «поцілунок»', 'poljubac', null, 'A1', 8, 'PUBLISHED', 'poljubac', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '018c0e32-4c23-5406-8803-ed91eeb9883f', 'type_answer', 'Напишіть хорватською: «романтичний»', 'romantičan', null, 'A1', 9, 'PUBLISHED', 'romantičan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd575763b-8918-5d8f-9564-412c47c58418', 'sentence_builder', 'Складіть: «Вони заручилися.»', 'Oni su se zaručili.', '["zaručili.", "su", "se", "Oni"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '562c320d-7c1a-5a5a-ba75-62c6ddcaf9e8', 'sentence_builder', 'Складіть: «Він розійшовся з дівчиною.»', 'Prekinuo je s curom.', '["je", "Prekinuo", "s", "curom."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9b8424fc-99da-59cf-a274-1b39d972192d', 'listening', 'Прослухайте і складіть фразу', 'Čestitam! Kako je to bilo?', '["Čestitam!", "Kako", "bilo?", "je", "to"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '51456481-79f6-5aa4-8349-3337308ce36f', 'listening', 'Прослухайте і складіть фразу', 'Da, prekinuo je s curom.', '["Da,", "s", "curom.", "prekinuo", "je"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'de9d1b08-ba78-5b82-b577-4036ac9351f9', 'speaking', 'Скільки ви разом?', 'Koliko ste dugo u vezi?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '574c638e-2888-5f6f-badc-f351ce3bdbe4', 'speaking', 'Я закохана.', 'Zaljubljena sam.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0fd3b312-3c03-5628-a62d-263a46566cc0', v_lesson, 'Новини від подруги', 'Novosti od prijateljice', 3851, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('76b6d4af-6ef1-5ce1-a7d1-21c55346d46e', '0fd3b312-3c03-5628-a62d-263a46566cc0', 'Ivana', 'Dašo, imam veliku vijest. Zaručila sam se!', 'Дашо, у мене велика новина. Я заручилася!', 1);
  perform pg_temp.turn('f2cbed77-eb4d-519c-8725-70b424146c88', '0fd3b312-3c03-5628-a62d-263a46566cc0', 'Daša', 'Čestitam! Kako je to bilo?', 'Вітаю! Як це було?', 2);
  perform pg_temp.turn('cb3d1594-c611-5851-bda4-2f98aebf23c2', '0fd3b312-3c03-5628-a62d-263a46566cc0', 'Ivana', 'Moj dečko me pitao na plaži, za zalazak sunca.', 'Мій хлопець запитав мене на пляжі, на заході сонця.', 3);
  perform pg_temp.turn('75a7e677-3588-5719-a5e4-a26246445caf', '0fd3b312-3c03-5628-a62d-263a46566cc0', 'Daša', 'Kako romantično! Koliko ste dugo u vezi?', 'Як романтично! Скільки ви разом?', 4);
  perform pg_temp.turn('06df33cc-af49-519b-9421-a7d3c3da3230', '0fd3b312-3c03-5628-a62d-263a46566cc0', 'Ivana', 'Tri godine. A prvi spoj nam je bio u kinu.', 'Три роки. А наше перше побачення було в кіно.', 5);
  perform pg_temp.turn('9b6d31a4-6532-5f7b-b68c-7910ae6ccb33', '0fd3b312-3c03-5628-a62d-263a46566cc0', 'Daša', 'Još se sjećam koliko si bila zaljubljena!', 'Я досі пам’ятаю, як ти була закохана!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('739ff7dc-d6a0-50e0-9fda-4b72ac4ab332', v_lesson, 'Підлітки', 'Tinejdžeri', 3852, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('42a0dd6d-a08f-556e-90b2-e1442a1f2fa4', '739ff7dc-d6a0-50e0-9fda-4b72ac4ab332', 'Darja', 'Marko, tvoj sin je neki dan bio tužan.', 'Марку, твій син днями був сумний.', 1);
  perform pg_temp.turn('b8f07cd7-6e5c-5253-a0b4-a7891e3fc6de', '739ff7dc-d6a0-50e0-9fda-4b72ac4ab332', 'Marko', 'Da, prekinuo je s curom.', 'Так, він розійшовся з дівчиною.', 2);
  perform pg_temp.turn('9da45a53-230e-531e-a8e7-6f115e886d1c', '739ff7dc-d6a0-50e0-9fda-4b72ac4ab332', 'Darja', 'Joj. A ima li novu simpatiju?', 'Ой. А в нього є нова симпатія?', 3);
  perform pg_temp.turn('996ecd37-55f5-5994-aa06-2933e9f9564e', '739ff7dc-d6a0-50e0-9fda-4b72ac4ab332', 'Marko', 'Mislim da ima, stalno piše poruke.', 'Думаю, є, постійно пише повідомлення.', 4);
  perform pg_temp.turn('e7a40d19-5370-5c72-accf-9170bb33ab13', '739ff7dc-d6a0-50e0-9fda-4b72ac4ab332', 'Darja', 'Mladost! Prvi poljubac, prvi zagrljaj…', 'Молодість! Перший поцілунок, перші обійми…', 5);
  perform pg_temp.turn('cc61a0d7-701b-5334-9389-15c5bb1b47f8', '739ff7dc-d6a0-50e0-9fda-4b72ac4ab332', 'Marko', 'Samo neka uči za ispite!', 'Аби тільки вчився до іспитів!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- 3. Нові уроки модуля A1.9
-- A1.9 · урок 76: Як звернутися? Dašo! Gospodine! — новий урок: 12 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := '0df70119-403a-517e-af33-8073d14fca03';
  v_lesson constant uuid := '6df343ef-4a40-5dfb-9100-7ab47fb1667d';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.9: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 76: Як звернутися? Dašo! Gospodine!', 'Lekcija 76: Kako se obratiti? Dašo! Gospodine!', '["Звернутися до людини: Dašo! Ivane! gospodine Kovaču!", "Вибрати «ти» чи «Ви»: tikati, persirati", "Кличний відмінок однини й множини"]'::jsonb, 15, 'PUBLISHED', 1);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Кличний відмінок: Dašo! Ivane! Gospodine!' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Кличний відмінок: Dašo! Ivane! Gospodine!»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'oslovljavati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obraćati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'persirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tikati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poštovani', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dame i gospodo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'titula', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poznanik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nepoznat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'doktor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gospođica', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bab2a743-ff47-5bdb-b46a-9157e4941ccb', 'fill_in_the_blank', 'Dobar dan, ___ Kovaču!', 'gospodine', '["gospodinu", "gospodina", "gospodin", "gospodine"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '342817e0-e856-5288-934d-2840eb49d5df', 'multiple_choice', 'Що означає «dame i gospodo»?', 'пані та панове', '["звертатися на «ти»", "невідомий", "знайомий", "пані та панове"]'::jsonb, 'A1', 2, 'PUBLISHED', 'dame i gospodo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'acbbcce6-e576-5574-b96e-394bde75f1ac', 'multiple_choice', 'Що означає «gospođica»?', 'панна (ввічливо до молодої жінки)', '["пані та панове", "лікар", "звертатися на «Ви»", "панна (ввічливо до молодої жінки)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'gospođica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b081c4e9-11e7-5a8b-b210-f32903bed450', 'multiple_choice', 'Що означає «obraćati se»?', 'звертатися (до когось)', '["називати (при звертанні: на ім’я, «пане»)", "панна (ввічливо до молодої жінки)", "звертатися (до когось)", "шановний (у листі, зверненні)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'obraćati se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '993e876d-8ff8-56d7-bfc2-56b15f8818e8', 'multiple_choice', 'Що означає «oslovljavati»?', 'називати (при звертанні: на ім’я, «пане»)', '["лікар", "звертатися (до когось)", "називати (при звертанні: на ім’я, «пане»)", "шановний (у листі, зверненні)"]'::jsonb, 'A1', 5, 'PUBLISHED', 'oslovljavati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f7f6ca0-1464-5bab-8e44-77004c95b006', 'multiple_choice', 'Що означає «doktor»?', 'лікар', '["звертатися (до когось)", "звання, титул (dr., prof.)", "пані та панове", "лікар"]'::jsonb, 'A1', 6, 'PUBLISHED', 'doktor', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ed7879e8-a737-5ecd-b34c-08aca6a85499', 'multiple_choice', 'Як хорватською «знайомий»?', 'poznanik', '["nepoznat", "gospođica", "poznanik", "čika"]'::jsonb, 'A1', 7, 'PUBLISHED', 'poznanik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e933a697-8533-5ba2-ab4c-78cff34ef50e', 'multiple_choice', 'Як хорватською «звання, титул (dr., prof.)»?', 'titula', '["persirati", "doktor", "poznanik", "titula"]'::jsonb, 'A1', 8, 'PUBLISHED', 'titula', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6f63d848-b9ec-5595-a1bd-2ee5995ea061', 'type_answer', 'Напишіть хорватською: «невідомий»', 'nepoznat', null, 'A1', 9, 'PUBLISHED', 'nepoznat', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7b526605-cad4-5260-83a6-1c532780cf9f', 'sentence_builder', 'Складіть: «Іване, ходи сюди!»', 'Ivane, dođi ovamo!', '["ovamo!", "dođi", "Ivane,"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '29e2b1db-212e-5077-93e4-04733599dc00', 'sentence_builder', 'Складіть: «Дякую, пані!»', 'Hvala vam, gospođo!', '["Hvala", "gospođo!", "vam,"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bce46406-a2e2-5460-b4d5-0d67198e32d2', 'listening', 'Прослухайте і складіть фразу', 'Hvala, Ivo. U Ukrajini starijima uvijek persiramo.', '["starijima", "uvijek", "Ukrajini", "U", "persiramo.", "Ivo.", "Hvala,"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d8f4ec4-f7b9-5760-9ad1-07cc25f44161', 'listening', 'Прослухайте і складіть фразу', 'Dobar dan! Kako se zove vaš pas?', '["se", "vaš", "Kako", "pas?", "Dobar", "dan!", "zove"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c95c9111-e6f7-5ee2-8813-e5ef10b5fe8d', 'speaking', 'Дашо, куди ти йдеш?', 'Dašo, kamo ideš?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6c8ef15b-b36d-5281-a1a6-3032f4c83a35', 'speaking', 'Можемо на «ти»?', 'Možemo li se tikati?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cedff046-ffbd-570e-9eff-24dbe83c9d78', v_lesson, 'Ти чи Ви?', 'Ti ili Vi?', 3761, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('cb681599-799c-5637-846a-22730767b33f', 'cedff046-ffbd-570e-9eff-24dbe83c9d78', 'Daša', 'Gospodine Kovaču, smijem li vas nešto pitati?', 'Пане Ковач, можна вас щось запитати?', 1);
  perform pg_temp.turn('8adb5ce2-ba61-5094-bb96-edb54d20f7b0', 'cedff046-ffbd-570e-9eff-24dbe83c9d78', 'Kovač', 'Naravno, Dašo. I možemo se tikati, ja sam Ivo.', 'Звісно, Дашо. І можемо на «ти», я Іво.', 2);
  perform pg_temp.turn('d5b94eb5-348d-5340-83c4-7695edacf433', 'cedff046-ffbd-570e-9eff-24dbe83c9d78', 'Daša', 'Hvala, Ivo. U Ukrajini starijima uvijek persiramo.', 'Дякую, Іво. В Україні до старших завжди звертаємося на «Ви».', 3);
  perform pg_temp.turn('b34604ba-2021-5af0-95b9-1547c80c4529', 'cedff046-ffbd-570e-9eff-24dbe83c9d78', 'Kovač', 'I kod nas, ali na poslu se kolege oslovljavaju imenom.', 'І в нас, але на роботі колеги звертаються на ім’я.', 4);
  perform pg_temp.turn('d39b56fd-3357-509b-98b0-aa6084deb5b7', 'cedff046-ffbd-570e-9eff-24dbe83c9d78', 'Daša', 'A kako se obraćam liječniku?', 'А як мені звертатися до лікаря?', 5);
  perform pg_temp.turn('047dd6dd-d91f-5b17-b23b-144f9684ebf2', 'cedff046-ffbd-570e-9eff-24dbe83c9d78', 'Kovač', 'Doktore ili doktorice, i uvijek s «Vi».', '«Пане лікарю» чи «пані лікарко», і завжди на «Ви».', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('74a6dd30-bd1f-5a88-9f8f-5aa26b30b744', v_lesson, 'У парку', 'U parku', 3762, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('b869c4e5-245f-5f42-ae6e-1ae107d1b06b', '74a6dd30-bd1f-5a88-9f8f-5aa26b30b744', 'Filip', 'Mama, onaj čika ima psa kao mi!', 'Мамо, он той дядько має такого пса, як у нас!', 1);
  perform pg_temp.turn('9bff6130-f58b-5bad-a693-caf83fef38fc', '74a6dd30-bd1f-5a88-9f8f-5aa26b30b744', 'Darja', 'Filipe, ne viči. Reci «dobar dan».', 'Філіпе, не кричи. Скажи «добрий день».', 2);
  perform pg_temp.turn('a6d1b7ce-4eee-5105-a3a8-7b3121eb1dc9', '74a6dd30-bd1f-5a88-9f8f-5aa26b30b744', 'Filip', 'Dobar dan! Kako se zove vaš pas?', 'Добрий день! Як звати вашого пса?', 3);
  perform pg_temp.turn('cc1186ff-2c27-5ea4-9e76-7911d0016386', '74a6dd30-bd1f-5a88-9f8f-5aa26b30b744', 'Gospodin', 'Rex. A kako se ti zoveš, mladiću?', 'Рекс. А тебе як звати, юначе?', 4);
  perform pg_temp.turn('73f32381-05a2-54c8-8a4e-8aba38f5bafa', '74a6dd30-bd1f-5a88-9f8f-5aa26b30b744', 'Filip', 'Filip. A ovo je moja teta Ana.', 'Філіп. А це моя тітка Ана.', 5);
  perform pg_temp.turn('d750dc31-9897-5379-bc7e-ad91a9897055', '74a6dd30-bd1f-5a88-9f8f-5aa26b30b744', 'Gospodin', 'Drago mi je, gospođice Ana!', 'Приємно познайомитися, панночко Ано!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A1 v3 (слова за темою, 2 діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 83: Хтось, щось, десь — новий урок: 13 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := '0df70119-403a-517e-af33-8073d14fca03';
  v_lesson constant uuid := '3f440ad8-f057-5898-b773-6aa8816fa8a3';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 8) then
    raise exception 'A1.9: місце 8 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 83: Хтось, щось, десь', 'Lekcija 83: Netko, nešto, negdje', '["Говорити про невідомих людей, речі й місця: netko, nešto, negdje", "Заперечувати: nitko, ništa, nigdje", "Неозначені займенники: ne-, ni-, i-, bilo-, sve-"]'::jsonb, 15, 'PUBLISHED', 8);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Неозначені займенники: netko, nešto, negdje' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Неозначені займенники: netko, nešto, negdje»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'netko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nitko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nešto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ništa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'negdje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nigdje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ikad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nekad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nekako', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svatko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bilo tko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bilo što', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svugdje', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '6d27ae7c-2a59-57c2-949a-b2a8b4b3a110', 'fill_in_the_blank', 'U sobi nema ___, svi su otišli.', 'nikoga', '["ništa", "netko", "nikoga", "nitko"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ddbc18a8-6a6c-5123-8d1d-8c6f0b1c8125', 'multiple_choice', 'Що означає «nešto»?', 'щось', '["будь-що", "нічого", "щось", "ніде"]'::jsonb, 'A1', 2, 'PUBLISHED', 'nešto', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a0c7678-ea58-5614-9767-e8e9d4035363', 'multiple_choice', 'Що означає «bilo tko»?', 'будь-хто', '["коли-небудь", "щось", "будь-хто", "хтось"]'::jsonb, 'A1', 3, 'PUBLISHED', 'bilo tko', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d8adf1d-e067-5a9a-b5a2-b2a95ce170ed', 'multiple_choice', 'Що означає «bilo što»?', 'будь-що', '["колись; іноді", "коли-небудь", "нічого", "будь-що"]'::jsonb, 'A1', 4, 'PUBLISHED', 'bilo što', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ee13144e-a0d2-5556-bc72-c5696809d235', 'multiple_choice', 'Як хорватською «десь»?', 'negdje', '["nešto", "nekako", "negdje", "nigdje"]'::jsonb, 'A1', 5, 'PUBLISHED', 'negdje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b0c1f0cd-df9d-5ac8-83b8-df9f140e2188', 'multiple_choice', 'Як хорватською «ніде»?', 'nigdje', '["nešto", "ikad", "nigdje", "bilo što"]'::jsonb, 'A1', 6, 'PUBLISHED', 'nigdje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f077fd81-dfc8-55f8-a1bf-e303cd94108c', 'type_answer', 'Напишіть хорватською: «нічого»', 'ništa', null, 'A1', 7, 'PUBLISHED', 'ništa', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eb888cda-fd67-59e7-9a66-e0641ef0d584', 'type_answer', 'Напишіть хорватською: «якось»', 'nekako', null, 'A1', 8, 'PUBLISHED', 'nekako', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7f9f4a0d-3a54-5fa4-a416-2f857dba00c0', 'type_answer', 'Напишіть хорватською: «всюди»', 'svugdje', null, 'A1', 9, 'PUBLISHED', 'svugdje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '32a9f5a8-8e3f-59a8-ab23-8416017e91f0', 'sentence_builder', 'Складіть: «Хтось тебе шукає.»', 'Netko te traži.', '["Netko", "traži.", "te"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c6d7b3e5-8246-503c-950a-3ef95075cbde', 'sentence_builder', 'Складіть: «Я нічого не бачу.»', 'Ništa ne vidim.', '["vidim.", "ne", "Ništa"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a3334d51-15a4-56bd-b3f7-95997f0e68c7', 'listening', 'Прослухайте і складіть фразу', 'Tko? Je li ostavio poruku?', '["li", "Tko?", "poruku?", "ostavio", "Je"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '135ca561-e2bd-56f3-aaef-a486fe4abfe8', 'listening', 'Прослухайте і складіть фразу', 'Svatko mora jednom vidjeti Hvar!', '["Hvar!", "vidjeti", "jednom", "mora", "Svatko"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '95f52d63-9869-5c58-b1f1-081f0ba8b435', 'speaking', 'Ти коли-небудь був у Спліті?', 'Jesi li ikad bio u Splitu?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'abf032c0-c5c2-5d24-8a24-dc1c73727238', 'speaking', 'Ніхто не прийшов.', 'Nitko nije došao.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d8d80090-83d5-5ec9-acde-c6432d70e7ac', v_lesson, 'Хтось дзвонив', 'Netko je zvao', 3831, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('aac44b38-2a2c-5f6f-ba4f-1b61f6dec2c5', 'd8d80090-83d5-5ec9-acde-c6432d70e7ac', 'Luka', 'Dašo, netko je zvao dok si bila vani.', 'Дашо, хтось дзвонив, поки тебе не було.', 1);
  perform pg_temp.turn('93718c26-651a-505d-8202-2d758a08d459', 'd8d80090-83d5-5ec9-acde-c6432d70e7ac', 'Daša', 'Tko? Je li ostavio poruku?', 'Хто? Залишив повідомлення?', 2);
  perform pg_temp.turn('193bd7e1-2bed-57b9-9295-e1016ee847c7', 'd8d80090-83d5-5ec9-acde-c6432d70e7ac', 'Luka', 'Nije rekao ništa, samo da će opet nazvati.', 'Нічого не сказав, тільки що передзвонить.', 3);
  perform pg_temp.turn('f0d81b6f-eb97-5f1b-af1b-ec197ade6452', 'd8d80090-83d5-5ec9-acde-c6432d70e7ac', 'Daša', 'Čudno. Jesi li vidio moje naočale? Nigdje ih nema.', 'Дивно. Ти бачив мої окуляри? Їх ніде немає.', 4);
  perform pg_temp.turn('a81ba703-b382-5c49-9e8e-3c6241881131', 'd8d80090-83d5-5ec9-acde-c6432d70e7ac', 'Luka', 'Negdje sam ih vidio, možda u kuhinji.', 'Я їх десь бачив, може, на кухні.', 5);
  perform pg_temp.turn('fd69a0da-f012-5d06-8451-a751e91743c1', 'd8d80090-83d5-5ec9-acde-c6432d70e7ac', 'Daša', 'Svugdje sam gledala!', 'Я всюди дивилася!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('29c5f326-f7aa-5256-ad92-86c52f9b58a6', v_lesson, 'Ти коли-небудь…?', 'Jesi li ikad…?', 3832, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('53d7e65e-a299-5d4a-93b8-46db1ed3e29d', '29c5f326-f7aa-5256-ad92-86c52f9b58a6', 'Marko', 'Darja, jesi li ikad bila na Hvaru?', 'Даріє, ти коли-небудь була на Хварі?', 1);
  perform pg_temp.turn('196a98d1-8d23-52fa-9f01-b754a40749b0', '29c5f326-f7aa-5256-ad92-86c52f9b58a6', 'Darja', 'Nisam, nikad nisam bila na otocima.', 'Ні, я ніколи не була на островах.', 2);
  perform pg_temp.turn('3d9de96b-afc3-5063-aa04-f968f9c830b4', '29c5f326-f7aa-5256-ad92-86c52f9b58a6', 'Marko', 'Svatko mora jednom vidjeti Hvar!', 'Кожен має хоч раз побачити Хвар!', 3);
  perform pg_temp.turn('c30aae69-7086-56d4-8ee3-e05d49dbb550', '29c5f326-f7aa-5256-ad92-86c52f9b58a6', 'Darja', 'Nekad ću otići, kad budem imala vremena.', 'Колись поїду, коли матиму час.', 4);
  perform pg_temp.turn('7742bfb8-8906-5845-b1ab-377948d9db23', '29c5f326-f7aa-5256-ad92-86c52f9b58a6', 'Marko', 'Možeš ići bilo kad, trajekt vozi svaki dan.', 'Можеш поїхати будь-коли, пором ходить щодня.', 5);
  perform pg_temp.turn('d68d7679-a717-5f43-9ac7-01cc1aee79d7', '29c5f326-f7aa-5256-ad92-86c52f9b58a6', 'Darja', 'Nekako ću se organizirati.', 'Якось організуюся.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A1 v3 (слова за темою, 2 діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

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
   where l.id in ('6df343ef-4a40-5dfb-9100-7ab47fb1667d', 'fac55dd6-0020-5997-8461-45ee2f94d3c5', '3ed8282d-b9fa-5151-b184-73fd352f8ba7', 'dde31f54-28b8-505b-aba6-3e578601fccb', '1c16ceee-5f42-536a-98b4-7dcabaa3be6d', 'e61e3942-cd86-5f75-9eb5-d878242125bf', '631c7f59-de43-5081-adb7-77bdf23ce805', '3f440ad8-f057-5898-b773-6aa8816fa8a3', 'ec1b7982-c092-5504-a233-4162f92f512a', '0d0547ed-c0ef-53bd-bfe4-c482c84c40f4')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 10 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_order from (values ('6df343ef-4a40-5dfb-9100-7ab47fb1667d'::uuid, 1), ('fac55dd6-0020-5997-8461-45ee2f94d3c5'::uuid, 2), ('3ed8282d-b9fa-5151-b184-73fd352f8ba7'::uuid, 3), ('dde31f54-28b8-505b-aba6-3e578601fccb'::uuid, 4), ('1c16ceee-5f42-536a-98b4-7dcabaa3be6d'::uuid, 5), ('e61e3942-cd86-5f75-9eb5-d878242125bf'::uuid, 6), ('631c7f59-de43-5081-adb7-77bdf23ce805'::uuid, 7), ('3f440ad8-f057-5898-b773-6aa8816fa8a3'::uuid, 8), ('ec1b7982-c092-5504-a233-4162f92f512a'::uuid, 9), ('0d0547ed-c0ef-53bd-bfe4-c482c84c40f4'::uuid, 10)) as t(id, o)
    join public.lessons l on l.id = t.id and l.order_index = t.o and l.unit_id = '0df70119-403a-517e-af33-8073d14fca03';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A1' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('6df343ef-4a40-5dfb-9100-7ab47fb1667d', 'fac55dd6-0020-5997-8461-45ee2f94d3c5', '3ed8282d-b9fa-5151-b184-73fd352f8ba7', 'dde31f54-28b8-505b-aba6-3e578601fccb', '1c16ceee-5f42-536a-98b4-7dcabaa3be6d', 'e61e3942-cd86-5f75-9eb5-d878242125bf', '631c7f59-de43-5081-adb7-77bdf23ce805', '3f440ad8-f057-5898-b773-6aa8816fa8a3', 'ec1b7982-c092-5504-a233-4162f92f512a', '0d0547ed-c0ef-53bd-bfe4-c482c84c40f4') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A1.9: % уроків з неправильним складом', v_bad; end if;
  if v_order <> 10 then raise exception 'Модуль A1.9: на своїх місцях % уроків з 10', v_order; end if;
  if v_titles > 0 then raise exception 'A1: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A1.9: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A1.9 — 10 уроків за темою (8 перебудовано, 2 нових)';
end $$;

commit;
