-- =====================================================================
-- Програма A1 v3 · модуль A1.1 «Мій день» · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_curriculum_a1_v3.py 1 (не редагуйте вручну).
--
-- Рішення власника 2026-10-21 / 2026-10-26: до 25 слів на урок — скільки потрібно темі, 90–95 % слів — нові для рівня,
-- діалоги під тему, частіше Даша / Дар’я; бета (PUBLISHED).
--   * Уроки 1–10: 9 наявних перебудовано, 1 нових. Слів у них: 169.
--     Кожен: 10–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 73.
--   * Нові теми граматики: «Зворотні дієслова: se».
--   * Нові правила до тем: «Теперішній час» (+2), «Заперечення» (+1).
--   * Виправлено: Uglavnom → uglavnom; čuvati — «берегти; доглядати, наглядати (за дитиною)»; ponovno — «знову, ще раз» (стара версія — у content_versions).
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

-- 1. Нові слова й вирази A1.1 (73; наявні не змінюються)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('spremati se', 'spremati se', 'hr', 'verb', 'A1', 'збиратися, готуватися (кудись)', 'core', '{"aspect": "ipfv", "present": {"1s": "spremam se", "2s": "spremaš se", "3s": "sprema se"}}'::jsonb, '["Ujutro se spremam pola sata."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('svakog jutra', 'svakog jutra', 'hr', 'phrase', 'A1', 'щоранку', 'chunk', '{}'::jsonb, '["Svakog jutra pijem kavu na balkonu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('svake večeri', 'svake veceri', 'hr', 'phrase', 'A1', 'щовечора', 'chunk', '{}'::jsonb, '["Svake večeri čitam djeci priču."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vraćati se', 'vracati se', 'hr', 'verb', 'A1', 'повертатися', 'core', '{"aspect": "ipfv", "present": {"1s": "vraćam se", "2s": "vraćaš se", "3s": "vraća se"}}'::jsonb, '["S posla se vraćam oko šest."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zatim', 'zatim', 'hr', 'adverb', 'A1', 'потім, після цього', 'function_word', '{}'::jsonb, '["Prvo se tuširam, zatim doručkujem."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nakon toga', 'nakon toga', 'hr', 'phrase', 'A1', 'після цього', 'chunk', '{}'::jsonb, '["Radim do četiri, a nakon toga idem u trgovinu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('na kraju', 'na kraju', 'hr', 'phrase', 'A1', 'наприкінці; зрештою', 'chunk', '{}'::jsonb, '["Na kraju dana sam jako umorna."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rutina', 'rutina', 'hr', 'noun', 'A1', 'розпорядок; звичний ритуал', 'core', '{"gender": "f"}'::jsonb, '["Moja jutarnja rutina traje sat vremena."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prati zube', 'prati zube', 'hr', 'phrase', 'A1', 'чистити зуби', 'collocation', '{"aspect": "ipfv", "present": {"1s": "perem zube", "2s": "pereš zube", "3s": "pere zube"}}'::jsonb, '["Djeca peru zube dvaput dnevno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('brijati se', 'brijati se', 'hr', 'verb', 'A1', 'голитися', 'core', '{"aspect": "ipfv", "present": {"1s": "brijem se", "2s": "briješ se", "3s": "brije se"}}'::jsonb, '["Marko se brije svako jutro."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('šminkati se', 'sminkati se', 'hr', 'verb', 'A1', 'фарбуватися, робити макіяж', 'core', '{"aspect": "ipfv", "present": {"1s": "šminkam se", "2s": "šminkaš se", "3s": "šminka se"}}'::jsonb, '["Daša se šminka pred ogledalom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('fen', 'fen', 'hr', 'noun', 'A1', 'фен', 'core', '{"gender": "m"}'::jsonb, '["Fen je u ladici u kupaonici."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sušiti kosu', 'susiti kosu', 'hr', 'phrase', 'A1', 'сушити волосся', 'collocation', '{"aspect": "ipfv", "present": {"1s": "sušim kosu", "2s": "sušiš kosu", "3s": "suši kosu"}}'::jsonb, '["Ujutro nemam vremena sušiti kosu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('obuti se', 'obuti se', 'hr', 'verb', 'A1', 'взутися', 'core', '{"aspect": "pfv", "present": {"1s": "obujem se", "2s": "obuješ se", "3s": "obuje se"}, "imperative": "obuj se"}'::jsonb, '["Obuj se, idemo van!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('presvući se', 'presvuci se', 'hr', 'verb', 'A1', 'перевдягнутися', 'core', '{"aspect": "pfv", "present": {"1s": "presvučem se", "2s": "presvučeš se", "3s": "presvuče se"}}'::jsonb, '["Moram se presvući prije posla."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('požuriti se', 'pozuriti se', 'hr', 'verb', 'A1', 'поквапитися', 'core', '{"aspect": "pfv", "present": {"1s": "požurim se", "2s": "požuriš se", "3s": "požuri se"}, "imperative": "požuri se"}'::jsonb, '["Požuri se, autobus dolazi za pet minuta!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('povremeno', 'povremeno', 'hr', 'adverb', 'A1', 'час від часу', 'core', '{}'::jsonb, '["Povremeno radim od kuće."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stalno', 'stalno', 'hr', 'adverb', 'A1', 'постійно, весь час', 'core', '{}'::jsonb, '["Susjedov pas stalno laje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gotovo nikad', 'gotovo nikad', 'hr', 'phrase', 'A1', 'майже ніколи', 'chunk', '{}'::jsonb, '["Gotovo nikad ne jedem meso."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('svaki put', 'svaki put', 'hr', 'phrase', 'A1', 'щоразу', 'chunk', '{}'::jsonb, '["Svaki put kad dođem, ona skuha kavu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jednom', 'jednom', 'hr', 'adverb', 'A1', 'один раз; колись', 'core', '{}'::jsonb, '["Jednom tjedno idem na bazen."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('triput', 'triput', 'hr', 'adverb', 'A1', 'тричі', 'core', '{}'::jsonb, '["Lijek uzimam triput dnevno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('svakodnevno', 'svakodnevno', 'hr', 'adverb', 'A1', 'щодня, повсякденно', 'core', '{}'::jsonb, '["Svakodnevno vježbam hrvatski."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('svaki drugi dan', 'svaki drugi dan', 'hr', 'phrase', 'A1', 'через день', 'chunk', '{}'::jsonb, '["Trčim svaki drugi dan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vikendom', 'vikendom', 'hr', 'adverb', 'A1', 'на вихідних, щовихідних', 'core', '{}'::jsonb, '["Vikendom spavamo do devet."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('radnim danom', 'radnim danom', 'hr', 'phrase', 'A1', 'у будні', 'chunk', '{}'::jsonb, '["Radnim danom ustajem u šest."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('cijelo vrijeme', 'cijelo vrijeme', 'hr', 'phrase', 'A1', 'весь час', 'chunk', '{}'::jsonb, '["Cijelo vrijeme pada kiša."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pospremiti', 'pospremiti', 'hr', 'verb', 'A1', 'прибрати (кімнату, речі)', 'core', '{"aspect": "pfv", "present": {"1s": "pospremim", "2s": "pospremiš", "3s": "pospremi"}}'::jsonb, '["Moram pospremiti sobu prije nego što dođu gosti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('perilica rublja', 'perilica rublja', 'hr', 'phrase', 'A1', 'пральна машина', 'collocation', '{"gender": "f"}'::jsonb, '["Perilica rublja je u kupaonici."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('brisati prašinu', 'brisati prasinu', 'hr', 'phrase', 'A1', 'витирати пил', 'collocation', '{"aspect": "ipfv", "present": {"1s": "brišem prašinu", "2s": "brišeš prašinu", "3s": "briše prašinu"}}'::jsonb, '["Subotom brišem prašinu i usisavam."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mesti', 'mesti', 'hr', 'verb', 'A1', 'підмітати', 'core', '{"aspect": "ipfv", "present": {"1s": "metem", "2s": "meteš", "3s": "mete"}}'::jsonb, '["Tko danas mete kuhinju?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bočica', 'bocica', 'hr', 'noun', 'A1', 'пляшечка (для малюка)', 'core', '{"gender": "f"}'::jsonb, '["Beba pije mlijeko iz bočice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('duda', 'duda', 'hr', 'noun', 'A1', 'соска (пустушка)', 'core', '{"gender": "f"}'::jsonb, '["Gdje je duda? Beba plače."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('slikovnica', 'slikovnica', 'hr', 'noun', 'A1', 'дитяча книжка з малюнками', 'core', '{"gender": "f"}'::jsonb, '["Navečer joj čitam slikovnicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kocke', 'kocke', 'hr', 'noun', 'A1', 'кубики (іграшка)', 'core', '{"gender": "f_pl"}'::jsonb, '["Mali se igra kockama na podu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('grliti', 'grliti', 'hr', 'verb', 'A1', 'обіймати', 'core', '{"aspect": "ipfv", "present": {"1s": "grlim", "2s": "grliš", "3s": "grli"}}'::jsonb, '["Djeca vole grliti baku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('šetati psa', 'setati psa', 'hr', 'phrase', 'A1', 'вигулювати собаку', 'collocation', '{"aspect": "ipfv", "present": {"1s": "šetam psa", "2s": "šetaš psa", "3s": "šeta psa"}}'::jsonb, '["Ujutro šetam psa u parku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('izvesti psa', 'izvesti psa', 'hr', 'phrase', 'A1', 'вивести собаку (на прогулянку)', 'collocation', '{"aspect": "pfv", "present": {"1s": "izvedem psa", "2s": "izvedeš psa", "3s": "izvede psa"}}'::jsonb, '["Možeš li večeras izvesti psa?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mjaukati', 'mjaukati', 'hr', 'verb', 'A1', 'нявкати', 'core', '{"aspect": "ipfv", "present": {"1s": "mjaučem", "2s": "mjaučeš", "3s": "mjauče"}}'::jsonb, '["Mačka mjauče jer je gladna."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('grebati', 'grebati', 'hr', 'verb', 'A1', 'дряпати', 'core', '{"aspect": "ipfv", "present": {"1s": "grebem", "2s": "grebeš", "3s": "grebe"}}'::jsonb, '["Mačić grebe kauč."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('buha', 'buha', 'hr', 'noun', 'A1', 'блоха', 'core', '{"gender": "f", "plural": "buhe"}'::jsonb, '["Pas ima buhe, moramo ga odvesti veterinaru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('četkati', 'cetkati', 'hr', 'verb', 'A1', 'вичісувати (щіткою)', 'core', '{"aspect": "ipfv", "present": {"1s": "četkam", "2s": "četkaš", "3s": "četka"}}'::jsonb, '["Psa četkam svaki dan jer mu ispada dlaka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kavez', 'kavez', 'hr', 'noun', 'A1', 'клітка', 'core', '{"gender": "m"}'::jsonb, '["Papiga živi u velikom kavezu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('akvarij', 'akvarij', 'hr', 'noun', 'A1', 'акваріум', 'core', '{"gender": "m"}'::jsonb, '["U akvariju imamo pet riba."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pijesak za mačke', 'pijesak za macke', 'hr', 'phrase', 'A1', 'наповнювач для котячого туалету', 'collocation', '{"gender": "m"}'::jsonb, '["Pijesak za mačke treba mijenjati svaki dan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dresirati', 'dresirati', 'hr', 'verb', 'A1', 'дресирувати', 'core', '{"aspect": "ipfv", "present": {"1s": "dresiram", "2s": "dresiraš", "3s": "dresira"}}'::jsonb, '["Psa dresiramo kod trenera."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('šetnja', 'setnja', 'hr', 'noun', 'A1', 'прогулянка', 'core', '{"gender": "f"}'::jsonb, '["Nedjeljom idemo u šetnju uz more."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prošetati', 'prosetati', 'hr', 'verb', 'A1', 'прогулятися', 'core', '{"aspect": "pfv", "present": {"1s": "prošetam", "2s": "prošetaš", "3s": "prošeta"}}'::jsonb, '["Hoćemo li prošetati do parka?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('roštilj', 'rostilj', 'hr', 'noun', 'A1', 'гриль; барбекю', 'core', '{"gender": "m"}'::jsonb, '["U subotu radimo roštilj u vrtu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('piknik', 'piknik', 'hr', 'noun', 'A1', 'пікнік', 'core', '{"gender": "m"}'::jsonb, '["Ako bude sunčano, idemo na piknik."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sajam', 'sajam', 'hr', 'noun', 'A1', 'ярмарок', 'core', '{"gender": "m", "genitive": "sajma"}'::jsonb, '["Na sajmu se prodaju domaći sir i med."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('izležavati se', 'izlezavati se', 'hr', 'verb', 'A1', 'ніжитися, вилежуватися', 'core', '{"aspect": "ipfv", "present": {"1s": "izležavam se", "2s": "izležavaš se", "3s": "izležava se"}}'::jsonb, '["Nedjeljom se izležavam do podneva."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zabavno', 'zabavno', 'hr', 'adverb', 'A1', 'весело, цікаво', 'core', '{}'::jsonb, '["Na izletu je bilo jako zabavno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dosadno', 'dosadno', 'hr', 'adverb', 'A1', 'нудно', 'core', '{}'::jsonb, '["Kad pada kiša, djeci je dosadno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vikendica', 'vikendica', 'hr', 'noun', 'A1', 'дача, заміський будинок', 'core', '{"gender": "f"}'::jsonb, '["Vikendicu imamo na selu blizu Karlovca."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('noćna mora', 'nocna mora', 'hr', 'phrase', 'A1', 'нічний кошмар', 'collocation', '{"gender": "f"}'::jsonb, '["Dijete se budi zbog noćne more."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zaspati', 'zaspati', 'hr', 'verb', 'A1', 'заснути', 'core', '{"aspect": "pfv", "present": {"1s": "zaspim", "2s": "zaspiš", "3s": "zaspi"}}'::jsonb, '["Ne mogu zaspati kad je vruće."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('lijegati', 'lijegati', 'hr', 'verb', 'A1', 'лягати (спати)', 'core', '{"aspect": "ipfv", "present": {"1s": "liježem", "2s": "liježeš", "3s": "liježe"}}'::jsonb, '["Radnim danom liježem oko jedanaest."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('naspavati se', 'naspavati se', 'hr', 'verb', 'A1', 'виспатися', 'core', '{"aspect": "pfv", "present": {"1s": "naspavam se", "2s": "naspavaš se", "3s": "naspava se"}}'::jsonb, '["Vikendom se konačno naspavam."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('iscrpljen', 'iscrpljen', 'hr', 'adjective', 'A1', 'виснажений', 'core', '{"f": "iscrpljena", "n": "iscrpljeno"}'::jsonb, '["Nakon noćne smjene sam potpuno iscrpljena."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sljedeći tjedan', 'sljedeci tjedan', 'hr', 'phrase', 'A1', 'наступного тижня; наступний тиждень', 'chunk', '{}'::jsonb, '["Sljedeći tjedan imam puno obveza."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prošli tjedan', 'prosli tjedan', 'hr', 'phrase', 'A1', 'минулого тижня; минулий тиждень', 'chunk', '{}'::jsonb, '["Prošli tjedan sam bila bolesna."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('krajem tjedna', 'krajem tjedna', 'hr', 'phrase', 'A1', 'наприкінці тижня', 'chunk', '{}'::jsonb, '["Krajem tjedna idemo na more."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('početkom tjedna', 'pocetkom tjedna', 'hr', 'phrase', 'A1', 'на початку тижня', 'chunk', '{}'::jsonb, '["Početkom tjedna uvijek imam sastanak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('imati vremena', 'imati vremena', 'hr', 'phrase', 'A1', 'мати час', 'chunk', '{}'::jsonb, '["Imaš li vremena u četvrtak?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('upravo', 'upravo', 'hr', 'adverb', 'A1', 'саме зараз; щойно; якраз', 'function_word', '{}'::jsonb, '["Upravo izlazim iz kuće."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('skoro', 'skoro', 'hr', 'adverb', 'A1', 'майже; скоро', 'function_word', '{}'::jsonb, '["Skoro je osam, moramo krenuti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ipak', 'ipak', 'hr', 'adverb', 'A1', 'все-таки, все одно', 'function_word', '{}'::jsonb, '["Umorna sam, ali ipak idem na trening."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stvarno', 'stvarno', 'hr', 'adverb', 'A1', 'справді, дійсно', 'function_word', '{}'::jsonb, '["Stvarno ne znam gdje su ključevi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uopće', 'uopce', 'hr', 'adverb', 'A1', 'зовсім, взагалі', 'function_word', '{}'::jsonb, '["Uopće nisam gladna."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('inače', 'inace', 'hr', 'adverb', 'A1', 'інакше; в інших випадках', 'function_word', '{}'::jsonb, '["Pospremi sobu, inače nema crtića!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('više ne', 'vise ne', 'hr', 'phrase', 'A1', 'більше не; уже ні', 'function_word', '{}'::jsonb, '["Više ne radim u hotelu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('još ne', 'jos ne', 'hr', 'phrase', 'A1', 'ще не; ще ні', 'function_word', '{}'::jsonb, '["Još ne znam dobro hrvatski."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;

-- 1б. Виправлені слова (3); повторний запуск нічого не змінює
do $$
declare r record;
begin
  for r in select * from public.lexemes where lemma = 'Uglavnom' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set lemma = 'uglavnom' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'čuvati' and ukrainian_translation = 'берегти' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'берегти; доглядати, наглядати (за дитиною)' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'ponovno' and ukrainian_translation = 'знову' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'знову, ще раз' where id = r.id;
  end loop;
end $$;

-- 1а. Граматика A1.1: нові теми (1) і нові правила до наявних тем (3)
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '93dcc4e8-1cb6-5b8b-8350-57538e39f738', 'A1', 'Зворотні дієслова: se', 'Povratni glagoli: se', 'Дієслова із se для щоденної рутини (budim se, tuširam se): що означає se, де воно стоїть у реченні, заперечення й питання, відмінності від українського «-ся».', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Зворотні дієслова: se');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '55e3914c-0556-51ff-afdb-616390029316', '93dcc4e8-1cb6-5b8b-8350-57538e39f738', 'Se — це «-ся»', 'Багато дієслів щоденної рутини мають коротке слово se: buditi se (прокидатися), tuširati se (приймати душ), češljati se (причісуватися). Se не змінюється: ja se budim, ti se budiš, oni se bude. Без se значення інше: buditi — будити когось.', 'buditi → buditi se: Budim djecu. — Budim se.', '[{"hr": "Budim se u šest.", "ua": "Я прокидаюся о шостій."}, {"hr": "Daša se tušira navečer.", "ua": "Даша приймає душ увечері."}, {"hr": "Djeca se bude rano.", "ua": "Діти прокидаються рано."}, {"hr": "Budim djecu u sedam.", "ua": "Я буджу дітей о сьомій."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '93dcc4e8-1cb6-5b8b-8350-57538e39f738')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '78a7f69b-1d12-53fc-bc0e-16f21e5c2b03', '93dcc4e8-1cb6-5b8b-8350-57538e39f738', 'Де стоїть se', 'Se — коротке ненаголошене слово, тому воно стоїть на другому місці в реченні: після першого слова або першої групи слів (Ujutro se tuširam. Svake večeri se vraćam kasno). Якщо речення починається з дієслова, se стоїть одразу після нього: Tuširam se.', 'Ujutro se tuširam. · Tuširam se ujutro.', '[{"hr": "Ujutro se brzo spremam.", "ua": "Уранці я швидко збираюся."}, {"hr": "Kada se vraćaš s posla?", "ua": "Коли ти повертаєшся з роботи?"}, {"hr": "Tuširam se svako jutro.", "ua": "Я приймаю душ щоранку."}, {"hr": "Marko se brije svaki dan.", "ua": "Марко голиться щодня."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '93dcc4e8-1cb6-5b8b-8350-57538e39f738')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'e080cba5-fa8a-5c98-88b9-af4121492fac', '93dcc4e8-1cb6-5b8b-8350-57538e39f738', 'Заперечення й питання із se', 'У запереченні ne і дієслово — одне ціле, тому se йде після них: Ne brijem se svaki dan. Якщо перед ne є інше слово, se стає на друге місце: Zašto se ne češljaš? У питанні з li порядок такий: дієслово + li + se — Tuširaš li se ujutro?', 'Ne brijem se. · Zašto se ne češljaš? · Tuširaš li se ujutro?', '[{"hr": "Ne brijem se svaki dan.", "ua": "Я не голюся щодня."}, {"hr": "Zašto se ne češljaš?", "ua": "Чому ти не причісуєшся?"}, {"hr": "Tuširaš li se ujutro ili navečer?", "ua": "Ти приймаєш душ уранці чи ввечері?"}, {"hr": "Djeca se ne žele umiti.", "ua": "Діти не хочуть умиватися."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '93dcc4e8-1cb6-5b8b-8350-57538e39f738')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '7ca39d1b-f5b2-59dd-9593-1c2fabfadaac', '93dcc4e8-1cb6-5b8b-8350-57538e39f738', 'Не завжди як в українській', 'Se не завжди збігається з українським «-ся». Із se в хорватській, але без «-ся» в українській: odmarati se — відпочивати, zvati se (Zovem se Daša — мене звати Даша). І навпаки, без se: početi / počinjati — починатися (Film počinje u osam), učiti — вчитися (Učim u večernjoj školi).', 'odmarati se — відпочивати · počinjati — починатися', '[{"hr": "Vikendom se odmaram.", "ua": "На вихідних я відпочиваю."}, {"hr": "Kako se zoveš?", "ua": "Як тебе звати?"}, {"hr": "Film počinje u osam.", "ua": "Фільм починається о восьмій."}, {"hr": "Učim u večernjoj školi.", "ua": "Я вчуся у вечірній школі."}]'::jsonb, 4
where exists (select 1 from public.grammar_topics where id = '93dcc4e8-1cb6-5b8b-8350-57538e39f738')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '93dcc4e8-1cb6-5b8b-8350-57538e39f738', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '93dcc4e8-1cb6-5b8b-8350-57538e39f738')
  and not exists (select 1 from public.content_reviews where entity_id = '93dcc4e8-1cb6-5b8b-8350-57538e39f738' and notes = 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.');
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Теперішній час' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Теперішній час»'; end if;
  if exists (select 1 from public.grammar_rules where id = '3ad8d305-a222-53d3-b760-f149ff984f48') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('3ad8d305-a222-53d3-b760-f149ff984f48', v_topic, 'Дієслова на -ovati, -nuti і -ći', 'Дієслова на -ovati / -ivati мають у теперішньому часі -uj-: kupovati → kupujem, putovati → putujem. Дієслова на -nuti мають -n-: krenuti → krenem. Дієслова на -ći треба запам’ятати: ići → idem, doći → dođem, moći → mogu, reći → kažem.', 'kupovati → kupujem · krenuti → krenem · ići → idem', '[{"hr": "Kupujem kruh svako jutro.", "ua": "Я щоранку купую хліб."}, {"hr": "Ljeti putujemo na more.", "ua": "Улітку ми їздимо на море."}, {"hr": "Vlak krene u sedam.", "ua": "Потяг вирушає о сьомій."}, {"hr": "Idem na posao pješice.", "ua": "Я йду на роботу пішки."}, {"hr": "Danas ne mogu, mogu sutra.", "ua": "Сьогодні не можу, можу завтра."}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', '3ad8d305-a222-53d3-b760-f149ff984f48', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Теперішній час' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Теперішній час»'; end if;
  if exists (select 1 from public.grammar_rules where id = 'feb76c9b-c152-599a-8b57-1a3a13f72a6d') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('feb76c9b-c152-599a-8b57-1a3a13f72a6d', v_topic, 'Як часто: прислівники частоти', 'Прислівники частоти (često, rijetko, povremeno, stalno) зазвичай стоять перед дієсловом або на початку речення: Često kuham. Vikendom spavam duže. З nikad і gotovo nikad дієслово завжди із ne: Nikad ne kasnim. Питаємо Koliko često…?', 'Često kuham. · Nikad ne kasnim. · Koliko često…?', '[{"hr": "Često kuham kod kuće.", "ua": "Я часто готую вдома."}, {"hr": "Rijetko gledam televiziju.", "ua": "Я рідко дивлюся телевізор."}, {"hr": "Nikad ne pijem kavu navečer.", "ua": "Я ніколи не п’ю кави ввечері."}, {"hr": "Koliko često ideš na bazen?", "ua": "Як часто ти ходиш у басейн?"}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', 'feb76c9b-c152-599a-8b57-1a3a13f72a6d', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Заперечення' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Заперечення»'; end if;
  if exists (select 1 from public.grammar_rules where id = '01f41832-32be-5196-803d-e7cfbc1e840a') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('01f41832-32be-5196-803d-e7cfbc1e840a', v_topic, 'Ще не, більше не, зовсім не', 'Još ne — ще ні, ще не сталося: Još ne znam. Više ne — більше не, раніше було, а тепер ні: Više ne pušim. Uopće ne / uopće nije — зовсім не, взагалі не: Uopće nije hladno. Коротка відповідь: — Jesi li gotova? — Još ne.', 'još ne · više ne · uopće ne', '[{"hr": "Još ne znam dobro hrvatski.", "ua": "Я ще погано знаю хорватську."}, {"hr": "Više ne radim u hotelu.", "ua": "Я більше не працюю в готелі."}, {"hr": "Uopće nije hladno.", "ua": "Зовсім не холодно."}, {"hr": "— Jesi li gotova? — Još ne.", "ua": "— Ти готова? — Ще ні."}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', '01f41832-32be-5196-803d-e7cfbc1e840a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;

-- 2. Перебудова наявних уроків модуля A1.1
-- A1.1 · урок 1: Мій звичайний день — перебудова: 18 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '4bf48151-be83-5108-bc92-645c0603a1a3';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Мій звичайний день» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '558752be-10bb-5edb-b019-def6ffa98ac6') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 1: Мій звичайний день', title_hr = 'Lekcija 1: Moj običan dan',
         objectives = '["Розповісти, як минає ваш звичайний день: budim se, tuširam se, krećem na posao", "Розставити події по порядку: zatim, nakon toga, na kraju", "Ставити дієслова із se на правильне місце в реченні"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Зворотні дієслова: se' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Зворотні дієслова: se»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'buditi se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'probuditi se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ustajati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ustati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tuširati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spremati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obično', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svakog jutra', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svake večeri', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krenuti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odlaziti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dolaziti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vraćati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vratiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zatim', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nakon toga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na kraju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rutina', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b6a07e43-0779-5039-a8ae-a3a0c36bae51', 'fill_in_the_blank', 'Ujutro ___ budim u šest.', 'se', '["se", "me", "si", "je"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3012bcab-85cb-5c49-8208-2dcb087d815a', 'multiple_choice', 'Що означає «na kraju»?', 'наприкінці; зрештою', '["наприкінці; зрештою", "приймати душ", "повернутися", "вставати (прокидатися і підніматися)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'na kraju', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b18df2d4-09b5-5ff4-a825-15216263c910', 'multiple_choice', 'Що означає «buditi se»?', 'прокидатися', '["повернутися", "приймати душ", "прокидатися", "повертатися"]'::jsonb, 'A1', 3, 'PUBLISHED', 'buditi se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1b53e3f8-7ae7-57ac-b25d-8b459ea2e389', 'multiple_choice', 'Що означає «ustajati»?', 'вставати (прокидатися і підніматися)', '["йти; від''їжджати", "вставати (прокидатися і підніматися)", "повернутися", "розпорядок; звичний ритуал"]'::jsonb, 'A1', 4, 'PUBLISHED', 'ustajati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '13bdaf11-2757-5f91-92f4-b7bc675fdb70', 'multiple_choice', 'Як хорватською «йти; від''їжджати»?', 'odlaziti', '["dolaziti", "rutina", "odlaziti", "ustajati"]'::jsonb, 'A1', 5, 'PUBLISHED', 'odlaziti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '64600754-1cd5-577e-b962-6be82389b61b', 'multiple_choice', 'Як хорватською «щоранку»?', 'svakog jutra', '["buditi se", "obično", "dolaziti", "svakog jutra"]'::jsonb, 'A1', 6, 'PUBLISHED', 'svakog jutra', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '126c8cff-c242-58ba-b3d3-077008c90201', 'type_answer', 'Напишіть хорватською: «зазвичай»', 'obično', null, 'A1', 7, 'PUBLISHED', 'obično', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b8c02269-707d-5edc-804b-5e325d168cfa', 'type_answer', 'Напишіть хорватською: «приходити»', 'dolaziti', null, 'A1', 8, 'PUBLISHED', 'dolaziti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '481122b0-6133-5b41-a413-c1f76c62c3c6', 'type_answer', 'Напишіть хорватською: «повертатися»', 'vraćati se', null, 'A1', 9, 'PUBLISHED', 'vraćati se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f4dd5022-9c07-5499-a604-58f7464d098d', 'sentence_builder', 'Складіть: «Я прокидаюся о шостій.»', 'Budim se u šest.', '["se", "u", "Budim", "šest."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '93449430-4ade-53c2-a154-bb11d801bcd6', 'sentence_builder', 'Складіть: «Потім я збираюся на роботу.»', 'Zatim se spremam za posao.', '["za", "posao.", "Zatim", "se", "spremam"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '608f0fc0-3c54-5310-bcbc-35d5fc3aadd6', 'listening', 'Прослухайте і складіть фразу', 'Dašo, u koliko sati se obično budiš?', '["budiš?", "sati", "Dašo,", "obično", "koliko", "u", "se"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '23c62b22-6121-5473-b17e-ad4fa1935183', 'listening', 'Прослухайте і складіть фразу', 'Svake večeri se vraćam oko šest.', '["Svake", "oko", "šest.", "vraćam", "se", "večeri"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9775d48b-2418-55fb-8dd6-fca9dc26fe6b', 'speaking', 'Я зазвичай прокидаюся о сьомій.', 'Obično se budim u sedam.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f8b187f-bc22-5606-bd6c-1d1da9239676', 'speaking', 'Коли ти повертаєшся з роботи?', 'Kada se vraćaš s posla?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('558752be-10bb-5edb-b019-def6ffa98ac6', v_lesson, 'Ранок Даші', 'Dašino jutro', 3011, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('68901ccc-ed75-562f-9587-e14d6ffad6af', '558752be-10bb-5edb-b019-def6ffa98ac6', 'Ivana', 'Dašo, u koliko sati se obično budiš?', 'Дашо, о котрій ти зазвичай прокидаєшся?', 1);
  perform pg_temp.turn('58c1ce27-5e56-5c55-92d9-c5d81db11a35', '558752be-10bb-5edb-b019-def6ffa98ac6', 'Daša', 'Budim se u šest, ali ustajem tek u šest i petnaest.', 'Я прокидаюся о шостій, але встаю лише о шостій п’ятнадцять.', 2);
  perform pg_temp.turn('c13fd79f-9f07-560b-b2b0-570aaa40237f', '558752be-10bb-5edb-b019-def6ffa98ac6', 'Ivana', 'A što radiš zatim?', 'А що робиш потім?', 3);
  perform pg_temp.turn('ae7e39ed-0e65-54e6-b61e-475a2ed027a5', '558752be-10bb-5edb-b019-def6ffa98ac6', 'Daša', 'Prvo se tuširam, zatim pijem kavu i spremam se za posao.', 'Спочатку приймаю душ, потім п’ю каву й збираюся на роботу.', 4);
  perform pg_temp.turn('d67d4608-5236-5dd6-94e6-bd4102845f99', '558752be-10bb-5edb-b019-def6ffa98ac6', 'Ivana', 'U koliko sati izlaziš iz kuće?', 'О котрій ти виходиш з дому?', 5);
  perform pg_temp.turn('a89e4261-fc09-5348-82f8-9d07a698aee6', '558752be-10bb-5edb-b019-def6ffa98ac6', 'Daša', 'Obično krećem u sedam, a na posao dolazim u pola osam.', 'Зазвичай вирушаю о сьомій, а на роботу приходжу о пів на восьму.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ca39253f-5bf3-5ade-adb6-6bc63fd59115', v_lesson, 'Увечері', 'Navečer', 3012, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('ed111a3a-d22d-55ee-8652-8f5a4568916d', 'ca39253f-5bf3-5ade-adb6-6bc63fd59115', 'Marko', 'Kada se vraćaš s posla?', 'Коли ти повертаєшся з роботи?', 1);
  perform pg_temp.turn('5459e684-a1d5-5f51-bd97-6fd1a02319ff', 'ca39253f-5bf3-5ade-adb6-6bc63fd59115', 'Darja', 'Svake večeri se vraćam oko šest.', 'Щовечора повертаюся близько шостої.', 2);
  perform pg_temp.turn('56bee85a-40bd-5076-9f12-a4eba868b2fd', 'ca39253f-5bf3-5ade-adb6-6bc63fd59115', 'Marko', 'A što radiš nakon toga?', 'А що робиш після цього?', 3);
  perform pg_temp.turn('c282e6d4-a12b-5da9-a183-ff6fc252e501', 'ca39253f-5bf3-5ade-adb6-6bc63fd59115', 'Darja', 'Kuham večeru, a zatim se igram s djecom.', 'Готую вечерю, а потім граюся з дітьми.', 4);
  perform pg_temp.turn('dc059944-206f-5c3e-9f26-207541ae61df', 'ca39253f-5bf3-5ade-adb6-6bc63fd59115', 'Marko', 'Imaš li neku večernju rutinu?', 'У тебе є якийсь вечірній ритуал?', 5);
  perform pg_temp.turn('f8b79b74-c2e6-5130-886c-f3714c1f8ed2', 'ca39253f-5bf3-5ade-adb6-6bc63fd59115', 'Darja', 'Imam. Na kraju dana čitam pola sata i rano liježem.', 'Так. Наприкінці дня читаю пів години й рано лягаю.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 2: Збираємося зранку — перебудова: 16 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '54f17cf7-3c17-5978-b400-b6b6888c9f84';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Збираємося зранку» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '3e312d07-721c-5bfa-b430-981f962c861a') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 2: Збираємося зранку', title_hr = 'Lekcija 2: Jutarnje spremanje',
         objectives = '["Розповісти, як ви збираєтеся зранку: umivam se, perem zube, češljam se", "Поквапити когось і нагадати взяти потрібне: Požuri se! Ponesi kapu!", "Відмінювати дієслова із se в усіх особах"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Зворотні дієслова: se' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Зворотні дієслова: se»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'umiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prati zube', v_pos);
  v_pos := pg_temp.word(v_lesson, 'četkica za zube', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pasta za zube', v_pos);
  v_pos := pg_temp.word(v_lesson, 'češljati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'češalj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brijati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šminkati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sušiti kosu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obući se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obuti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'presvući se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spreman', v_pos);
  v_pos := pg_temp.word(v_lesson, 'požuriti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponijeti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a07ba31-f970-50cb-9008-3ccf0bb47d09', 'fill_in_the_blank', 'Djeca se ___ u kupaonici.', 'umivaju', '["umivaju", "umiva", "umivaš", "umivam"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6f4c797c-a031-513d-90e0-168a7235d5fc', 'multiple_choice', 'Що означає «sušiti kosu»?', 'сушити волосся', '["зубна паста", "сушити волосся", "умитися", "фен"]'::jsonb, 'A1', 2, 'PUBLISHED', 'sušiti kosu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c7c2bf0f-083b-5d6d-b903-baca8ffca36c', 'multiple_choice', 'Що означає «četkica za zube»?', 'зубна щітка', '["взутися", "одягнутися", "гребінець", "зубна щітка"]'::jsonb, 'A1', 3, 'PUBLISHED', 'četkica za zube', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '74834023-311d-57ec-b0a5-8c315fd4acbb', 'multiple_choice', 'Що означає «pasta za zube»?', 'зубна паста', '["фен", "зубна паста", "готовий", "голитися"]'::jsonb, 'A1', 4, 'PUBLISHED', 'pasta za zube', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '50f2881a-0ecf-5ed7-b206-e1eda2f81e69', 'multiple_choice', 'Як хорватською «гребінець»?', 'češalj', '["pasta za zube", "češalj", "umiti se", "sušiti kosu"]'::jsonb, 'A1', 5, 'PUBLISHED', 'češalj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd2dcee47-125b-58df-96a3-3273585dd9a3', 'multiple_choice', 'Як хорватською «перевдягнутися»?', 'presvući se', '["spreman", "šminkati se", "ponijeti", "presvući se"]'::jsonb, 'A1', 6, 'PUBLISHED', 'presvući se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd5430efe-0a2c-5905-840f-8950a148c002', 'type_answer', 'Напишіть хорватською: «готовий»', 'spreman', null, 'A1', 7, 'PUBLISHED', 'spreman', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7597ff52-6bf3-5a01-900b-1b7b826f8522', 'type_answer', 'Напишіть хорватською: «умитися»', 'umiti se', null, 'A1', 8, 'PUBLISHED', 'umiti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd42928a5-294c-5c87-b931-387bbb254929', 'type_answer', 'Напишіть хорватською: «взутися»', 'obuti se', null, 'A1', 9, 'PUBLISHED', 'obuti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5b162f07-5b23-5995-9f1a-a1f2ea60b9f9', 'sentence_builder', 'Складіть: «Я чищу зуби двічі на день.»', 'Perem zube dvaput dnevno.', '["dnevno.", "dvaput", "Perem", "zube"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c744d46d-5d80-53fe-9840-4ca1ddf999a0', 'sentence_builder', 'Складіть: «Поквапся, ми запізнюємося!»', 'Požuri se, kasnimo!', '["kasnimo!", "se,", "Požuri"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3d26538a-6441-56e9-9786-259cfc3daf0f', 'listening', 'Прослухайте і складіть фразу', 'Požuri se, molim te. Kasnim na posao.', '["na", "Požuri", "posao.", "te.", "molim", "se,", "Kasnim"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dc7febc5-c982-5b8f-9846-1f4139961f60', 'listening', 'Прослухайте і складіть фразу', 'Mogu li ponijeti loptu u vrtić?', '["u", "li", "loptu", "vrtić?", "ponijeti", "Mogu"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b3499001-e13a-5ef2-85cc-7e57a7182e30', 'speaking', 'Мені треба вмитися.', 'Moram se umiti.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '23b2cf4f-9b19-59a9-860a-0dadf8978de1', 'speaking', 'Візьми парасольку!', 'Ponesi kišobran!', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3e312d07-721c-5bfa-b430-981f962c861a', v_lesson, 'Хто у ванній?', 'Tko je u kupaonici?', 3021, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('9dc66194-05f2-58a7-9dd7-cbe4f5529825', '3e312d07-721c-5bfa-b430-981f962c861a', 'Daša', 'Luka, jesi li još u kupaonici? Moram se umiti!', 'Луко, ти ще у ванній? Мені треба вмитися!', 1);
  perform pg_temp.turn('da8ef489-3a93-5e99-b139-4a140d1b208e', '3e312d07-721c-5bfa-b430-981f962c861a', 'Luka', 'Još se brijem, gotov sam za dvije minute.', 'Я ще голюся, буду готовий за дві хвилини.', 2);
  perform pg_temp.turn('702cdfa7-b51d-5104-a95e-e996cf57f17f', '3e312d07-721c-5bfa-b430-981f962c861a', 'Daša', 'Požuri se, molim te. Kasnim na posao.', 'Поквапся, будь ласка. Я запізнююся на роботу.', 3);
  perform pg_temp.turn('cc544415-6b10-5cd7-80ea-284700176d37', '3e312d07-721c-5bfa-b430-981f962c861a', 'Luka', 'Evo, izlazim. Tvoja četkica za zube je pored ogledala.', 'Ось, виходжу. Твоя зубна щітка біля дзеркала.', 4);
  perform pg_temp.turn('50e81a3c-0a66-5ea6-9115-c9e41594d17f', '3e312d07-721c-5bfa-b430-981f962c861a', 'Daša', 'Hvala. A gdje je pasta za zube?', 'Дякую. А де зубна паста?', 5);
  perform pg_temp.turn('041d2d27-5994-501d-8c05-78cead19852d', '3e312d07-721c-5bfa-b430-981f962c861a', 'Luka', 'U ormariću. I fen je tamo, ako ćeš sušiti kosu.', 'У шафці. І фен там, якщо будеш сушити волосся.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('27e24d42-90fc-5dac-ba5e-e5123448335c', v_lesson, 'Збираємо дитину', 'Spremamo dijete', 3022, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('65f4fdcd-d2af-51f6-a285-77d5b6318e87', '27e24d42-90fc-5dac-ba5e-e5123448335c', 'Darja', 'Filipe, jesi li spreman? Za deset minuta krećemo.', 'Філіпе, ти готовий? Через десять хвилин вирушаємо.', 1);
  perform pg_temp.turn('71f05973-89c7-53c7-82a8-19a9cbf33891', '27e24d42-90fc-5dac-ba5e-e5123448335c', 'Filip', 'Još se oblačim, mama.', 'Я ще одягаюся, мамо.', 2);
  perform pg_temp.turn('d36240f8-c345-575a-96e0-4f2ae2a81c5c', '27e24d42-90fc-5dac-ba5e-e5123448335c', 'Darja', 'Počešljaj se i obuj se, čekam te na vratima.', 'Причешися і взуйся, я чекаю тебе біля дверей.', 3);
  perform pg_temp.turn('6f3a7371-c350-5319-b01e-5ef846bbd1a2', '27e24d42-90fc-5dac-ba5e-e5123448335c', 'Filip', 'Mogu li ponijeti loptu u vrtić?', 'Можна мені взяти м’яч у садок?', 4);
  perform pg_temp.turn('d3643675-e9cb-5a0a-afce-98e6da7c5c10', '27e24d42-90fc-5dac-ba5e-e5123448335c', 'Darja', 'Možeš. I ponesi kapu, vani je hladno!', 'Можна. І візьми шапку, надворі холодно!', 5);
  perform pg_temp.turn('1655b590-478c-53ee-90bd-8c579e900c2e', '27e24d42-90fc-5dac-ba5e-e5123448335c', 'Filip', 'Dobro! Mama, ti se danas ne šminkaš?', 'Добре! Мамо, ти сьогодні не фарбуєшся?', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 3: Як часто? — перебудова: 18 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '959e879f-a28d-5bed-9c09-16cff91ef456';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Як часто?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '91b3f44a-e58a-5c73-9db0-05ad85bb3ddb') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 3: Як часто?', title_hr = 'Lekcija 3: Koliko često?',
         objectives = '["Сказати, як часто ви щось робите: često, rijetko, povremeno, nikad", "Відповісти на питання «Koliko često…?»: jednom tjedno, svaki drugi dan", "Пам’ятати: з nikad дієслово із ne — Nikad ne kasnim."]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Теперішній час' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Теперішній час»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'često', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rijetko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nikad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'katkad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povremeno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stalno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'redovito', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uglavnom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gotovo nikad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svaki put', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jednom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dvaput', v_pos);
  v_pos := pg_temp.word(v_lesson, 'triput', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svakodnevno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svaki drugi dan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vikendom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radnim danom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cijelo vrijeme', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '7b9f61a3-9591-5f0c-a825-e368e8a39b55', 'fill_in_the_blank', 'Nikad ___ kasnim na posao.', 'ne', '["nije", "ni", "nisam", "ne"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b3289f6b-2a13-5231-9365-2573e34fad86', 'multiple_choice', 'Що означає «gotovo nikad»?', 'майже ніколи', '["тричі", "регулярно", "майже ніколи", "інколи"]'::jsonb, 'A1', 2, 'PUBLISHED', 'gotovo nikad', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e7b2496a-2e13-53a1-8139-e5a320b75e35', 'multiple_choice', 'Що означає «cijelo vrijeme»?', 'весь час', '["рідко", "регулярно", "двічі", "весь час"]'::jsonb, 'A1', 3, 'PUBLISHED', 'cijelo vrijeme', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '882c680f-769d-5bef-9886-f76ddf32e912', 'multiple_choice', 'Що означає «povremeno»?', 'час від часу', '["тричі", "переважно / головним чином", "регулярно", "час від часу"]'::jsonb, 'A1', 4, 'PUBLISHED', 'povremeno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e70ccf5b-d788-5d90-9fe5-82a4c267ed48', 'multiple_choice', 'Як хорватською «часто»?', 'često', '["nikad", "radnim danom", "svakodnevno", "često"]'::jsonb, 'A1', 5, 'PUBLISHED', 'često', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cdb65c32-cfa6-5883-9f62-f45deeebb178', 'multiple_choice', 'Як хорватською «інколи»?', 'katkad', '["redovito", "dvaput", "katkad", "stalno"]'::jsonb, 'A1', 6, 'PUBLISHED', 'katkad', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '33af730b-d17d-5cd5-8f47-69a719ea955c', 'type_answer', 'Напишіть хорватською: «тричі»', 'triput', null, 'A1', 7, 'PUBLISHED', 'triput', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e505aeb-bdaf-536b-b4d5-fea437d68d23', 'type_answer', 'Напишіть хорватською: «щоразу»', 'svaki put', null, 'A1', 8, 'PUBLISHED', 'svaki put', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'efc633d7-9c47-5ad0-b952-6a50051e7003', 'type_answer', 'Напишіть хорватською: «рідко»', 'rijetko', null, 'A1', 9, 'PUBLISHED', 'rijetko', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3d25de0d-a4cb-5693-afbf-0173c4ed2ba6', 'sentence_builder', 'Складіть: «Я ходжу в басейн раз на тиждень.»', 'Jednom tjedno idem na bazen.', '["bazen.", "na", "Jednom", "idem", "tjedno"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2053bfcc-bb3e-57c8-bc8b-f12171c06712', 'sentence_builder', 'Складіть: «Я майже ніколи не їм м’яса.»', 'Gotovo nikad ne jedem meso.', '["Gotovo", "ne", "meso.", "nikad", "jedem"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0ada19ca-a33d-5954-a1a8-f6fb78e7c81f', 'listening', 'Прослухайте і складіть фразу', 'Svaki drugi dan, a vikendom trčim uz more.', '["a", "trčim", "more.", "dan,", "drugi", "vikendom", "uz", "Svaki"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f198b571-c765-5b3e-a21a-f1a678596f87', 'listening', 'Прослухайте і складіть фразу', 'Radnim danom nije problem, ali vikendom spavam duže.', '["ali", "Radnim", "danom", "nije", "spavam", "duže.", "vikendom", "problem,"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b48770a6-58f6-55df-81d9-e0337e9f33cb', 'speaking', 'Як часто ти готуєш?', 'Koliko često kuhaš?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '29dd645b-d60d-5223-8341-b0de2f3f7151', 'speaking', 'Я рідко дивлюся телевізор.', 'Rijetko gledam televiziju.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('91b3f44a-e58a-5c73-9db0-05ad85bb3ddb', v_lesson, 'Спорт і звички', 'Sport i navike', 3031, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('57053ab7-a3c4-5b6e-8163-f49fe279dce5', '91b3f44a-e58a-5c73-9db0-05ad85bb3ddb', 'Tomislav', 'Dašo, koliko često ideš na trening?', 'Дашо, як часто ти ходиш на тренування?', 1);
  perform pg_temp.turn('81e744e3-2ec7-5650-9e48-b0b20427355b', '91b3f44a-e58a-5c73-9db0-05ad85bb3ddb', 'Daša', 'Svaki drugi dan, a vikendom trčim uz more.', 'Через день, а на вихідних бігаю вздовж моря.', 2);
  perform pg_temp.turn('92d35a93-3bf1-53c6-85b5-6587d5dda55a', '91b3f44a-e58a-5c73-9db0-05ad85bb3ddb', 'Tomislav', 'Bravo! Ja nažalost rijetko imam vremena.', 'Молодець! А в мене, на жаль, рідко буває час.', 3);
  perform pg_temp.turn('5b14db9d-7ab8-5566-b5f7-932bb92b726e', '91b3f44a-e58a-5c73-9db0-05ad85bb3ddb', 'Daša', 'A plivaš li redovito?', 'А ти регулярно плаваєш?', 4);
  perform pg_temp.turn('ff3f7bc1-507a-5f04-bc7e-022d1dd7c460', '91b3f44a-e58a-5c73-9db0-05ad85bb3ddb', 'Tomislav', 'Povremeno, jednom ili dvaput mjesečno.', 'Час від часу, раз чи двічі на місяць.', 5);
  perform pg_temp.turn('7e59910e-66b1-559e-aa12-2d562baad5d9', '91b3f44a-e58a-5c73-9db0-05ad85bb3ddb', 'Daša', 'Ja gotovo nikad ne plivam, more mi je prehladno.', 'А я майже ніколи не плаваю, море для мене надто холодне.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('69c6c48e-bc5b-5330-9247-9609ccbff1c5', v_lesson, 'Гучний сусід', 'Glasni susjed', 3032, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('db0045ee-ac35-5669-8c57-7d692d97f897', '69c6c48e-bc5b-5330-9247-9609ccbff1c5', 'Darja', 'Gospođo Horvat, vaš pas stalno laje.', 'Пані Горват, ваш пес постійно гавкає.', 1);
  perform pg_temp.turn('b22e06b7-41bc-5a3a-b00d-41ef83f80e8a', '69c6c48e-bc5b-5330-9247-9609ccbff1c5', 'Gospođa Horvat', 'Stvarno? Svaki put kad netko prođe, on laje.', 'Справді? Щоразу, коли хтось проходить, він гавкає.', 2);
  perform pg_temp.turn('12395cf8-7e92-545d-bf97-1529827fc955', '69c6c48e-bc5b-5330-9247-9609ccbff1c5', 'Darja', 'Radnim danom nije problem, ali vikendom spavam duže.', 'У будні це не проблема, але на вихідних я сплю довше.', 3);
  perform pg_temp.turn('5a7db53a-7f91-5487-bca7-37ee56b539fb', '69c6c48e-bc5b-5330-9247-9609ccbff1c5', 'Gospođa Horvat', 'Razumijem. Uglavnom je u vrtu, a navečer je unutra.', 'Розумію. Здебільшого він у саду, а ввечері — в хаті.', 4);
  perform pg_temp.turn('82e67d60-4315-544c-a505-ad68e1ed752f', '69c6c48e-bc5b-5330-9247-9609ccbff1c5', 'Darja', 'Jutros laje cijelo vrijeme.', 'Сьогодні зранку він гавкає весь час.', 5);
  perform pg_temp.turn('a742590a-1263-5424-b10e-ebd0f8adf4b5', '69c6c48e-bc5b-5330-9247-9609ccbff1c5', 'Gospođa Horvat', 'Ispričavam se. Danas ga triput vodim u šetnju.', 'Перепрошую. Сьогодні я виведу його на прогулянку тричі.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 4: Домашні справи — перебудова: 21 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '9c38f909-9275-5194-9a6e-f799c6e416ce';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Домашні справи» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'a98cf68e-f316-54ae-87be-157a7a9d2c48') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 4: Домашні справи', title_hr = 'Lekcija 4: Kućanski poslovi',
         objectives = '["Назвати домашні справи: usisavati, prati suđe, peglati, iznositi smeće", "Домовитися, хто що робить удома", "Дієслова на -ati / -iti в теперішньому часі: usisavam, čistim, perem"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Теперішній час' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Теперішній час»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kućanski poslovi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čistiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'usisavati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'peglati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pospremiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'suđe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rublje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'perilica rublja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sušilo za rublje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'objesiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smeće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iznositi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kanta za smeće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prašina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brisati prašinu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krpa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'metla', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mesti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cimerica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pomagati', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '46ef9f03-2233-51aa-b884-09ceaf0aeec4', 'fill_in_the_blank', 'Ja svake subote ___ kuću.', 'čistim', '["čiste", "čisti", "čistiš", "čistim"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f3873080-9f8f-59c9-a3c2-d8c792bff129', 'multiple_choice', 'Що означає «kućanski poslovi»?', 'домашні справи', '["домашні справи", "прасувати", "підмітати", "пральна машина"]'::jsonb, 'A1', 2, 'PUBLISHED', 'kućanski poslovi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e6c3e418-159d-5e31-b34b-415ccc9cbe37', 'multiple_choice', 'Що означає «smeće»?', 'сміття', '["сусідка по квартирі", "сміття", "витирати пил", "мітла"]'::jsonb, 'A1', 3, 'PUBLISHED', 'smeće', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '363a51ad-37b8-5692-8ad3-4a59de4a60e8', 'multiple_choice', 'Що означає «cimerica»?', 'сусідка по квартирі', '["сусідка по квартирі", "виносити", "сміття", "посуд"]'::jsonb, 'A1', 4, 'PUBLISHED', 'cimerica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0da0f164-0a57-5d8f-ba68-c5847420cdbf', 'multiple_choice', 'Як хорватською «повісити»?', 'objesiti', '["metla", "pospremiti", "brisati prašinu", "objesiti"]'::jsonb, 'A1', 5, 'PUBLISHED', 'objesiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2834d374-1862-5e94-98bb-7f0df240aa2b', 'multiple_choice', 'Як хорватською «посуд»?', 'suđe', '["prati", "suđe", "rublje", "objesiti"]'::jsonb, 'A1', 6, 'PUBLISHED', 'suđe', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b044f9ff-8d08-52ac-9299-04aa68995845', 'type_answer', 'Напишіть хорватською: «допомагати»', 'pomagati', null, 'A1', 7, 'PUBLISHED', 'pomagati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8dc03214-3449-5419-9a6e-b9728c443b2c', 'type_answer', 'Напишіть хорватською: «мити / прати»', 'prati', null, 'A1', 8, 'PUBLISHED', 'prati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ee86744b-84eb-5b20-9329-2ccddd7af90d', 'type_answer', 'Напишіть хорватською: «ганчірка»', 'krpa', null, 'A1', 9, 'PUBLISHED', 'krpa', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '346de500-b21a-5725-a108-18267c626794', 'sentence_builder', 'Складіть: «Хто сьогодні виносить сміття?»', 'Tko danas iznosi smeće?', '["smeće?", "danas", "Tko", "iznosi"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '48ded7e6-2d0c-57f0-85ae-52fc4b2fca58', 'sentence_builder', 'Складіть: «Я мию посуд після вечері.»', 'Perem suđe nakon večere.', '["Perem", "večere.", "nakon", "suđe"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ef94ada2-ccfc-56f5-923d-9afdab337d4b', 'listening', 'Прослухайте і складіть фразу', 'Onda ja perem suđe i čistim kupaonicu.', '["čistim", "Onda", "kupaonicu.", "perem", "i", "suđe", "ja"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '70379ca9-8c49-568d-8a14-306358124a1f', 'listening', 'Прослухайте і складіть фразу', 'Mogu. Gdje je sušilo za rublje?', '["Mogu.", "sušilo", "za", "Gdje", "rublje?", "je"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fc87e5cd-6273-5676-90f3-28a9847de41b', 'speaking', 'Я пилососю у вітальні.', 'Usisavam u dnevnom boravku.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7fb88675-a8ba-5d9e-a3e5-5074d11b7663', 'speaking', 'Можеш повісити білизну?', 'Možeš li objesiti rublje?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a98cf68e-f316-54ae-87be-157a7a9d2c48', v_lesson, 'Хто що робить?', 'Tko što radi?', 3041, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('5462b42b-e7ca-593a-9081-2285f9c3154e', 'a98cf68e-f316-54ae-87be-157a7a9d2c48', 'Mia', 'Dašo, subota je. Podijelimo kućanske poslove?', 'Дашо, сьогодні субота. Розподілимо домашні справи?', 1);
  perform pg_temp.turn('919c68cd-6d47-52a9-8189-71fecd6bbb76', 'a98cf68e-f316-54ae-87be-157a7a9d2c48', 'Daša', 'Može. Ja usisavam i brišem prašinu.', 'Давай. Я пилососю й витираю пил.', 2);
  perform pg_temp.turn('83cef385-6580-5f44-8e8d-cbed9f92b97a', 'a98cf68e-f316-54ae-87be-157a7a9d2c48', 'Mia', 'Onda ja perem suđe i čistim kupaonicu.', 'Тоді я мию посуд і прибираю у ванній.', 3);
  perform pg_temp.turn('ce80c304-e3a5-56f5-bc6d-e2b4055c6400', 'a98cf68e-f316-54ae-87be-157a7a9d2c48', 'Daša', 'A tko iznosi smeće? Kanta za smeće je puna.', 'А хто виносить сміття? Відро для сміття повне.', 4);
  perform pg_temp.turn('626ace22-0e64-569e-9479-3a8c01c200a1', 'a98cf68e-f316-54ae-87be-157a7a9d2c48', 'Mia', 'Danas ti, a sutra ja.', 'Сьогодні ти, а завтра я.', 5);
  perform pg_temp.turn('2a8c08a4-7b36-5add-b74e-50594851a7da', 'a98cf68e-f316-54ae-87be-157a7a9d2c48', 'Daša', 'Dogovoreno! Ti si najbolja cimerica.', 'Домовились! Ти найкраща сусідка по квартирі.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ab30598d-0990-559f-8f18-bd7f127ce73c', v_lesson, 'Прання', 'Pranje rublja', 3042, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('6ba3ff14-021f-5bf7-88d6-9f5600a26a7c', 'ab30598d-0990-559f-8f18-bd7f127ce73c', 'Darja', 'Luka, perilica rublja je gotova. Možeš li objesiti rublje?', 'Луко, пральна машина закінчила. Можеш повісити білизну?', 1);
  perform pg_temp.turn('08af86b5-be2b-540b-ab2f-b0b5822c119c', 'ab30598d-0990-559f-8f18-bd7f127ce73c', 'Luka', 'Mogu. Gdje je sušilo za rublje?', 'Можу. Де сушарка для білизни?', 2);
  perform pg_temp.turn('6455f2be-2580-53fa-b2a3-5892ea3c93f6', 'ab30598d-0990-559f-8f18-bd7f127ce73c', 'Darja', 'Na balkonu. Ja ću peglati košulje.', 'На балконі. А я попрасую сорочки.', 3);
  perform pg_temp.turn('1a4a65a6-5bb1-5b9b-a694-b4a03cc45645', 'ab30598d-0990-559f-8f18-bd7f127ce73c', 'Luka', 'Treba li pospremiti i dječju sobu?', 'Треба ще прибрати в дитячій кімнаті?', 4);
  perform pg_temp.turn('66b45e4d-e5ec-53db-8bc7-5f2a01016754', 'ab30598d-0990-559f-8f18-bd7f127ce73c', 'Darja', 'Treba. Uzmi metlu i krpu, hvala što mi pomažeš!', 'Треба. Візьми мітлу й ганчірку, дякую, що допомагаєш!', 5);
  perform pg_temp.turn('4acd2773-459a-5bb4-84e0-0b6d4fc99df7', 'ab30598d-0990-559f-8f18-bd7f127ce73c', 'Luka', 'Nema problema, zajedno je brže.', 'Без проблем, разом швидше.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 5: З дитиною вдома — перебудова: 19 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «З дитиною вдома» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '82ce4115-3612-54a6-a08b-dab0138a8992') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 5: З дитиною вдома', title_hr = 'Lekcija 5: S djetetom kod kuće',
         objectives = '["Говорити про догляд за малюком: kupati, presvući, pelene, bočica", "Попросити допомоги: Čuvaj malu! Daj joj dudu!", "Наказовий спосіб для ti й vi в побуті"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Наказовий спосіб' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Наказовий спосіб»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kupati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'presvući', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pelene', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bočica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'duda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dječja kolica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uspavati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plakati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smijati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bajka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slikovnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crtić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kocke', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljuljačka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tobogan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pijesak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čuvati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nositi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grliti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dcc64ea2-f0e9-5752-a9eb-45e9252e0c18', 'fill_in_the_blank', 'Molim te, ___ malu, ja se brzo tuširam.', 'čuvaj', '["čuvam", "čuva", "čuvaju", "čuvaj"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd4490f71-0928-56d1-9928-0eb6f22a91e8', 'multiple_choice', 'Що означає «slikovnica»?', 'дитяча книжка з малюнками', '["дитяча книжка з малюнками", "сміятися", "мультфільм", "казка"]'::jsonb, 'A1', 2, 'PUBLISHED', 'slikovnica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '63b91e92-95c1-5f42-83af-628dd818d9a2', 'multiple_choice', 'Що означає «tobogan»?', 'гірка (дитяча)', '["гірка (дитяча)", "купати", "кубики (іграшка)", "обіймати"]'::jsonb, 'A1', 3, 'PUBLISHED', 'tobogan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bce9a3c9-1c51-5cb4-b21a-1cf8d6afd621', 'multiple_choice', 'Що означає «bajka»?', 'казка', '["дитячий візочок", "казка", "носити / одягати", "дитяча книжка з малюнками"]'::jsonb, 'A1', 4, 'PUBLISHED', 'bajka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c9e8691-7515-50df-b4fc-2e38c8478e9e', 'multiple_choice', 'Як хорватською «носити / одягати»?', 'nositi', '["smijati se", "grliti", "nositi", "plakati"]'::jsonb, 'A1', 5, 'PUBLISHED', 'nositi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d5daffe-3020-54c1-84fa-24022a8e56c9', 'multiple_choice', 'Як хорватською «підгузки»?', 'pelene', '["pijesak", "ljuljačka", "pelene", "plakati"]'::jsonb, 'A1', 6, 'PUBLISHED', 'pelene', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7671e58f-d81f-52a1-a058-9226baa3f82d', 'type_answer', 'Напишіть хорватською: «обіймати»', 'grliti', null, 'A1', 7, 'PUBLISHED', 'grliti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '600ad851-1d8b-51f9-84bb-ce6919198f8f', 'type_answer', 'Напишіть хорватською: «мультфільм»', 'crtić', null, 'A1', 8, 'PUBLISHED', 'crtić', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'daf90982-23e1-549c-aa99-f921ae9faa9a', 'type_answer', 'Напишіть хорватською: «пісок»', 'pijesak', null, 'A1', 9, 'PUBLISHED', 'pijesak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a3390b15-56cb-5d6a-9faa-19dca40da8b5', 'sentence_builder', 'Складіть: «Не плач, мама тут.»', 'Nemoj plakati, mama je tu.', '["plakati,", "tu.", "mama", "Nemoj", "je"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3127586d-e230-5056-8c02-8bd29336e0a5', 'sentence_builder', 'Складіть: «Дай їй соску, будь ласка.»', 'Daj joj dudu, molim te.', '["joj", "dudu,", "molim", "Daj", "te."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6e1312b0-45ef-5ab0-bb4d-59cc509504e1', 'listening', 'Прослухайте і складіть фразу', 'U pet joj daj bočicu s mlijekom.', '["mlijekom.", "U", "joj", "daj", "pet", "bočicu", "s"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b6cbcfd6-b785-5e0a-871b-3d58dc1725b1', 'listening', 'Прослухайте і складіть фразу', 'Zaljuljaj me na ljuljački, molim te!', '["me", "te!", "na", "molim", "ljuljački,", "Zaljuljaj"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c56bd79a-5806-5835-9995-6fd281707d6d', 'speaking', 'Перевдягни малюка, будь ласка.', 'Presvuci bebu, molim te.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1349ee87-f10c-574b-9dd0-8164744d0e85', 'speaking', 'Почитай мені казку!', 'Pročitaj mi bajku!', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('82ce4115-3612-54a6-a08b-dab0138a8992', v_lesson, 'Сусідка допомагає', 'Susjeda pomaže', 3051, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('1130ec14-d3c9-588e-a080-4451a3cb5e29', '82ce4115-3612-54a6-a08b-dab0138a8992', 'Daša', 'Ana, možeš li čuvati malu dva sata?', 'Ано, можеш посидіти з малою дві години?', 1);
  perform pg_temp.turn('bcd3650f-2bd4-5812-a930-15bd73cedec1', '82ce4115-3612-54a6-a08b-dab0138a8992', 'Ana', 'Naravno. Kada joj dajem mlijeko?', 'Звісно. Коли їй дати молоко?', 2);
  perform pg_temp.turn('6ec44a54-bac5-5689-bcb6-5f888dfeea0b', '82ce4115-3612-54a6-a08b-dab0138a8992', 'Daša', 'U pet joj daj bočicu s mlijekom.', 'О п’ятій дай їй пляшечку з молоком.', 3);
  perform pg_temp.turn('8cd26fc1-646f-5af0-bf09-23abe9c842ce', '82ce4115-3612-54a6-a08b-dab0138a8992', 'Ana', 'A ako plače?', 'А якщо плаче?', 4);
  perform pg_temp.turn('5b2ace0a-eb40-5041-8388-a3d6d972b3f5', '82ce4115-3612-54a6-a08b-dab0138a8992', 'Daša', 'Daj joj dudu i nosi je malo po sobi.', 'Дай їй соску й трохи поноси по кімнаті.', 5);
  perform pg_temp.turn('807dcde7-7650-5ee2-954a-f7bd8e4693d4', '82ce4115-3612-54a6-a08b-dab0138a8992', 'Ana', 'Dobro. Gdje su pelene, ako je trebam presvući?', 'Добре. Де підгузки, якщо треба буде її перевдягнути?', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1515f889-130f-5476-8851-938106d3700a', v_lesson, 'На майданчику', 'Na igralištu', 3052, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('a41cd628-5fe6-5bc2-8207-46f006f5f73a', '1515f889-130f-5476-8851-938106d3700a', 'Filip', 'Mama, idemo na tobogan!', 'Мамо, ходімо на гірку!', 1);
  perform pg_temp.turn('d4693928-fa43-59a4-b897-69463a50c7b5', '1515f889-130f-5476-8851-938106d3700a', 'Darja', 'Idemo, ali pazi na mlađu djecu.', 'Ходімо, але зважай на менших дітей.', 2);
  perform pg_temp.turn('753cb8b8-6ca1-500e-963b-fcebeb86ff6a', '1515f889-130f-5476-8851-938106d3700a', 'Filip', 'Zaljuljaj me na ljuljački, molim te!', 'Погойдай мене на гойдалці, будь ласка!', 3);
  perform pg_temp.turn('540a518b-db90-59d9-97fb-f77ddf014717', '1515f889-130f-5476-8851-938106d3700a', 'Darja', 'Može. Nemoj se igrati u pijesku, nove su ti hlače.', 'Добре. Не грайся в піску, в тебе нові штани.', 4);
  perform pg_temp.turn('df9f41d9-a9d4-51b9-852e-ee081d7f4813', '1515f889-130f-5476-8851-938106d3700a', 'Filip', 'Hoćeš li mi navečer pročitati bajku?', 'А ввечері прочитаєш мені казку?', 5);
  perform pg_temp.turn('2aeb2c65-4f3f-5741-88bb-e0cd0bd0a323', '1515f889-130f-5476-8851-938106d3700a', 'Darja', 'Hoću, ali prvo se kupaš i gledaš jedan crtić.', 'Так, але спершу ти купаєшся й дивишся один мультик.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 6: Догляд за улюбленцем — перебудова: 15 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '1968c7d5-4e3a-5b1e-92f6-88df711e9c54';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Догляд за улюбленцем» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '91600261-5b62-5a00-bae9-b8ee0d475bea') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 6: Догляд за улюбленцем', title_hr = 'Lekcija 6: Briga o ljubimcu',
         objectives = '["Розповісти, як доглядати за твариною: šetati psa, četkati, hrana za pse", "Попросити сусіда доглянути улюбленця", "Знахідний відмінок живого: imam psa, hranim mačića"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Знахідний відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Знахідний відмінок»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'šetati psa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izvesti psa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hrana za pse', v_pos);
  v_pos := pg_temp.word(v_lesson, 'granule', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zdjelica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mačić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjaukati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grebati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'buha', v_pos);
  v_pos := pg_temp.word(v_lesson, 'četkati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kavez', v_pos);
  v_pos := pg_temp.word(v_lesson, 'akvarij', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pijesak za mačke', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dresirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poslušan', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ce472855-7f0c-5642-8500-150f697c08a6', 'fill_in_the_blank', 'Imamo malog ___.', 'mačića', '["mačićem", "mačić", "mačiću", "mačića"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '410158be-47fe-562c-87c0-cea765f2d459', 'multiple_choice', 'Що означає «granule»?', 'сухий корм (гранули)', '["мисочка", "дресирувати", "сухий корм (гранули)", "вивести собаку (на прогулянку)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'granule', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6e896b41-c16a-5d66-9fda-46adc6b5e9dd', 'multiple_choice', 'Що означає «šetati psa»?', 'вигулювати собаку', '["корм для собак", "мисочка", "вигулювати собаку", "дряпати"]'::jsonb, 'A1', 3, 'PUBLISHED', 'šetati psa', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d253222-49e7-51e7-b172-91a648852173', 'multiple_choice', 'Що означає «buha»?', 'блоха', '["блоха", "наповнювач для котячого туалету", "дряпати", "вичісувати (щіткою)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'buha', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e49a25fd-ef86-521e-9a83-d02eee020dcb', 'multiple_choice', 'Як хорватською «слухняний»?', 'poslušan', '["akvarij", "četkati", "poslušan", "mačić"]'::jsonb, 'A1', 5, 'PUBLISHED', 'poslušan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '60f5e69c-8a04-5b31-8a6a-85e2ed3df336', 'multiple_choice', 'Як хорватською «вичісувати (щіткою)»?', 'četkati', '["grebati", "hrana za pse", "mjaukati", "četkati"]'::jsonb, 'A1', 6, 'PUBLISHED', 'četkati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e020a661-3030-5f4b-b9fd-d2e5e5f0a276', 'type_answer', 'Напишіть хорватською: «дряпати»', 'grebati', null, 'A1', 7, 'PUBLISHED', 'grebati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2e87fe0b-94fc-514b-a00c-56909e0882e4', 'type_answer', 'Напишіть хорватською: «акваріум»', 'akvarij', null, 'A1', 8, 'PUBLISHED', 'akvarij', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6bfc2643-02db-5277-83f0-3695d2f0af41', 'type_answer', 'Напишіть хорватською: «клітка»', 'kavez', null, 'A1', 9, 'PUBLISHED', 'kavez', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e6cde7fe-6b2d-5d8c-b64f-99c036da755e', 'sentence_builder', 'Складіть: «Я вигулюю пса в парку.»', 'Šetam psa u parku.', '["psa", "parku.", "Šetam", "u"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f3e39a0e-751e-58a1-bb62-77f087005667', 'sentence_builder', 'Складіть: «Папуга живе в клітці.»', 'Papiga živi u kavezu.', '["Papiga", "živi", "kavezu.", "u"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '899fbff3-2add-5733-9474-73937fa95ab7', 'listening', 'Прослухайте і складіть фразу', 'Šetaj psa dvaput dnevno, ujutro i navečer.', '["dnevno,", "psa", "navečer.", "Šetaj", "i", "dvaput", "ujutro"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '142a09cf-26e4-55e1-89c9-61749a97145c', 'listening', 'Прослухайте і складіть фразу', 'Mislim da ima buhe.', '["buhe.", "Mislim", "ima", "da"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3dee14b4-5381-50e6-b050-4bec20fbf078', 'speaking', 'Можеш вивести пса?', 'Možeš li izvesti psa?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3879eb7a-5ea2-5ff8-b441-7e2024b77ee6', 'speaking', 'Наш пес дуже слухняний.', 'Naš pas je jako poslušan.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('91600261-5b62-5a00-bae9-b8ee0d475bea', v_lesson, 'Поки нас немає', 'Dok nas nema', 3061, 'A1', 'vet', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('49e3ddc4-7aa3-55d1-bc25-a4d8124393ef', '91600261-5b62-5a00-bae9-b8ee0d475bea', 'Daša', 'Marko, idemo na put. Možeš li pripaziti na našeg psa?', 'Марко, ми їдемо. Можеш наглянути за нашим псом?', 1);
  perform pg_temp.turn('15977b45-d014-5b69-bc60-065a5f29ba61', '91600261-5b62-5a00-bae9-b8ee0d475bea', 'Marko', 'Mogu. Koliko često ga trebam izvesti?', 'Можу. Як часто його треба виводити?', 2);
  perform pg_temp.turn('5e3552cf-b34d-5ca2-95af-1115ce6a5500', '91600261-5b62-5a00-bae9-b8ee0d475bea', 'Daša', 'Šetaj psa dvaput dnevno, ujutro i navečer.', 'Вигулюй пса двічі на день, уранці й увечері.', 3);
  perform pg_temp.turn('bfa1e4a2-60ed-568f-9400-e7afc2086e5b', '91600261-5b62-5a00-bae9-b8ee0d475bea', 'Marko', 'A hrana za pse?', 'А корм для собак?', 4);
  perform pg_temp.turn('ebe1cf13-e997-50d8-8813-5b910c290ff0', '91600261-5b62-5a00-bae9-b8ee0d475bea', 'Daša', 'Granule su u ormaru. Zdjelicu napuni jednom dnevno.', 'Гранули в шафі. Мисочку наповнюй раз на день.', 5);
  perform pg_temp.turn('3b9bd5c5-3042-555e-bd88-de27501961e6', '91600261-5b62-5a00-bae9-b8ee0d475bea', 'Marko', 'Nema problema. On je jako poslušan.', 'Без проблем. Він дуже слухняний.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('58a4c38a-58eb-500f-871a-17f95405ee17', v_lesson, 'Нове кошеня', 'Novi mačić', 3062, 'A1', 'vet', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('110fa975-7cb5-57a4-8df1-5ea89f505720', '58a4c38a-58eb-500f-871a-17f95405ee17', 'Darja', 'Dobar dan, imamo novog mačića. Sve grebe i stalno mjauče.', 'Добрий день, у нас нове кошеня. Усе дряпає й постійно нявкає.', 1);
  perform pg_temp.turn('2ce74466-66cb-5bad-875d-a4884848ba79', '58a4c38a-58eb-500f-871a-17f95405ee17', 'Veterinarka', 'To je normalno, još je mali. Kupite mu grebalicu.', 'Це нормально, воно ще мале. Купіть йому дряпку.', 2);
  perform pg_temp.turn('a061d733-2a3e-5a02-aae1-0a5ebc3ad5c6', '58a4c38a-58eb-500f-871a-17f95405ee17', 'Darja', 'Mislim da ima buhe.', 'Мені здається, у нього блохи.', 3);
  perform pg_temp.turn('5f52b767-e1f9-5d70-83aa-d7b8874db076', '58a4c38a-58eb-500f-871a-17f95405ee17', 'Veterinarka', 'Da vidim. Da, ima. Dat ću vam kapi.', 'Дайте подивлюся. Так, є. Я дам вам краплі.', 4);
  perform pg_temp.turn('db8eece4-6f1d-52ed-adb5-d955c1cc9a45', '58a4c38a-58eb-500f-871a-17f95405ee17', 'Darja', 'Koliko često trebam mijenjati pijesak za mačke?', 'Як часто треба міняти наповнювач для котячого туалету?', 5);
  perform pg_temp.turn('fc79ad1e-6c7c-5caa-9333-a7c160aff765', '58a4c38a-58eb-500f-871a-17f95405ee17', 'Veterinarka', 'Svaki dan, a mačića redovito četkajte.', 'Щодня, а кошеня регулярно вичісуйте.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 7: Вихідні — перебудова: 17 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '458b73de-d6b3-5bd3-98ad-c243a2fff03f';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Вихідні» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'c00a6c86-7a0c-5fdc-b66b-d61915199e32') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 7: Вихідні', title_hr = 'Lekcija 7: Vikend',
         objectives = '["Розповісти, як ви проводите вихідні: izlet, roštilj, šetnja", "Запропонувати план на вихідні й погодитися", "Дієслово + інфінітив: volim planinariti, želim se opustiti"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Правильні дієслова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Правильні дієслова»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'izlet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šetnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prošetati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'roštilj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'piknik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izložba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sajam', v_pos);
  v_pos := pg_temp.word(v_lesson, 'druženje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izležavati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'planinariti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'provesti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opustiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zabavno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dosadno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'selo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vikendica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrt', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '24cdfdad-0fa5-5f29-8228-04740cf7ca9a', 'fill_in_the_blank', 'Volim ___ u prirodi.', 'planinariti', '["planinariti", "planinari", "planinariš", "planinarim"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '80a02536-20eb-58a2-9799-6d287d147bda', 'multiple_choice', 'Що означає «druženje»?', 'спілкування / зустріч (з друзями)', '["провести", "ніжитися, вилежуватися", "спілкування / зустріч (з друзями)", "нудно"]'::jsonb, 'A1', 2, 'PUBLISHED', 'druženje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '39ffc610-b7df-55c0-b713-27018a883cf4', 'multiple_choice', 'Що означає «dosadno»?', 'нудно', '["гриль; барбекю", "село", "весело, цікаво", "нудно"]'::jsonb, 'A1', 3, 'PUBLISHED', 'dosadno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3ce18e97-8eca-568b-a838-8fd50c204ecc', 'multiple_choice', 'Що означає «izlet»?', 'поїздка; екскурсія', '["спілкування / зустріч (з друзями)", "поїздка; екскурсія", "пікнік", "прогулятися"]'::jsonb, 'A1', 4, 'PUBLISHED', 'izlet', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '44dff0d9-58d2-5b1a-9dfe-0ee4dc70aa0e', 'multiple_choice', 'Як хорватською «ярмарок»?', 'sajam', '["sajam", "prošetati", "vrt", "piknik"]'::jsonb, 'A1', 5, 'PUBLISHED', 'sajam', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a4805431-aa41-5e72-937f-48f8b2942849', 'multiple_choice', 'Як хорватською «пікнік»?', 'piknik', '["piknik", "planinariti", "vikendica", "opustiti se"]'::jsonb, 'A1', 6, 'PUBLISHED', 'piknik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '160f904d-ec3b-5993-b99a-a27eab034274', 'type_answer', 'Напишіть хорватською: «весело, цікаво»', 'zabavno', null, 'A1', 7, 'PUBLISHED', 'zabavno', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '51b309bf-f8d3-5d8f-9691-434ecce8a76a', 'type_answer', 'Напишіть хорватською: «розслабитися»', 'opustiti se', null, 'A1', 8, 'PUBLISHED', 'opustiti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7774706e-949f-50a1-9de4-22da77b5326f', 'type_answer', 'Напишіть хорватською: «гриль; барбекю»', 'roštilj', null, 'A1', 9, 'PUBLISHED', 'roštilj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '109582cf-eef3-540f-a262-ad8a854800d6', 'sentence_builder', 'Складіть: «У неділю ми йдемо на пікнік.»', 'U nedjelju idemo na piknik.', '["piknik.", "U", "nedjelju", "idemo", "na"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4191eada-2847-5035-b311-c48aa13fbd21', 'sentence_builder', 'Складіть: «Я хочу відпочити.»', 'Želim se opustiti.', '["se", "opustiti.", "Želim"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b3add2d2-e99c-5870-bd07-77c544e1d1d4', 'listening', 'Прослухайте і складіть фразу', 'Subotom se izležavam, a nedjeljom idem na izlet.', '["Subotom", "a", "na", "idem", "se", "izležavam,", "nedjeljom", "izlet."]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '05abaa04-5c97-5b33-a62e-996a1b9df29f', 'listening', 'Прослухайте і складіть фразу', 'Šteta. Djeci je kod kuće dosadno.', '["kuće", "je", "Šteta.", "kod", "Djeci", "dosadno."]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd22853ae-5079-5def-829c-114c896a2c18', 'speaking', 'Як ти проводиш вихідні?', 'Kako provodiš vikend?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '74ca96a5-83ec-510e-9185-53ccafc66306', 'speaking', 'Ходімо прогуляємося!', 'Idemo prošetati!', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c00a6c86-7a0c-5fdc-b66b-d61915199e32', v_lesson, 'Плани на суботу', 'Planovi za subotu', 3071, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('88e3d5c8-de9b-5ba4-a3ba-f0a0fca31e83', 'c00a6c86-7a0c-5fdc-b66b-d61915199e32', 'Ivana', 'Dašo, kako voliš provesti vikend?', 'Дашо, як ти любиш проводити вихідні?', 1);
  perform pg_temp.turn('7b5c30c1-8a35-5b98-af26-351fc7d01250', 'c00a6c86-7a0c-5fdc-b66b-d61915199e32', 'Daša', 'Subotom se izležavam, a nedjeljom idem na izlet.', 'У суботу ніжуся в ліжку, а в неділю їду на екскурсію.', 2);
  perform pg_temp.turn('16a789a7-fbc5-5289-ad60-4bc1af67654a', 'c00a6c86-7a0c-5fdc-b66b-d61915199e32', 'Ivana', 'Mi ovaj vikend idemo u vikendicu na selu. Hoćeš s nama?', 'Ми ці вихідні їдемо на дачу в село. Поїдеш з нами?', 3);
  perform pg_temp.turn('603c650c-4a31-5cfe-a16d-9f0774e132bd', 'c00a6c86-7a0c-5fdc-b66b-d61915199e32', 'Daša', 'Rado! Što ćemo tamo raditi?', 'Залюбки! Що ми там робитимемо?', 4);
  perform pg_temp.turn('aa4799cd-0078-5a66-9137-2a4a2aae121e', 'c00a6c86-7a0c-5fdc-b66b-d61915199e32', 'Ivana', 'Radimo roštilj u vrtu, a u nedjelju idemo planinariti.', 'Смажимо барбекю в саду, а в неділю йдемо в гори.', 5);
  perform pg_temp.turn('1a3650ce-4dc1-5048-8672-8de76934776b', 'c00a6c86-7a0c-5fdc-b66b-d61915199e32', 'Daša', 'Super, tamo se stvarno mogu opustiti.', 'Чудово, там я справді можу відпочити.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f4b338cf-e3a2-5a4b-b877-43a3b6caa199', v_lesson, 'Дощова неділя', 'Kišna nedjelja', 3072, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('8cc90156-6b0f-5781-a4e8-89adc6c41a9a', 'f4b338cf-e3a2-5a4b-b877-43a3b6caa199', 'Marko', 'Pada kiša, od piknika nema ništa.', 'Іде дощ, з пікніком нічого не вийде.', 1);
  perform pg_temp.turn('bba83abe-0edd-5267-a5a3-6cc475694846', 'f4b338cf-e3a2-5a4b-b877-43a3b6caa199', 'Darja', 'Šteta. Djeci je kod kuće dosadno.', 'Шкода. Дітям удома нудно.', 2);
  perform pg_temp.turn('6fec2be4-2952-52fc-87e9-cbe49bfd8bd2', 'f4b338cf-e3a2-5a4b-b877-43a3b6caa199', 'Marko', 'Možemo ići na izložbu dinosaura u muzeju.', 'Можемо піти на виставку динозаврів у музеї.', 3);
  perform pg_temp.turn('24a765b0-0e3a-51af-a8eb-e92ae5a145e0', 'f4b338cf-e3a2-5a4b-b877-43a3b6caa199', 'Darja', 'Dobra ideja, to je djeci zabavno.', 'Гарна ідея, дітям це цікаво.', 4);
  perform pg_temp.turn('a44b30b1-ea16-59c9-a290-58c751a9196a', 'f4b338cf-e3a2-5a4b-b877-43a3b6caa199', 'Marko', 'A navečer, ako stane kiša, možemo prošetati.', 'А ввечері, якщо дощ ущухне, можемо прогулятися.', 5);
  perform pg_temp.turn('5afeac6f-82a0-5f55-bd1f-e01bc8720600', 'f4b338cf-e3a2-5a4b-b877-43a3b6caa199', 'Darja', 'Može, kratka šetnja i rano u krevet.', 'Давай, коротка прогулянка — і рано спати.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 8: Сон і відпочинок — перебудова: 16 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '63a4a6d8-1cae-5e0e-90ff-98efcfe8b4c7';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Сон і відпочинок» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'e784baf7-d320-514c-a35a-e1c3ce955298') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 8: Сон і відпочинок', title_hr = 'Lekcija 8: San i odmor',
         objectives = '["Розповісти, як ви спите: liježem, zaspim, budim se", "Поскаржитися на безсоння чи втому: imam nesanicu, iscrpljena sam", "Неправильні дієслова: leći — legnem, zaspati — zaspim"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Часті неправильні дієслова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Часті неправильні дієслова»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'san', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sanjati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'noćna mora', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaspati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'leći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lijegati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naspavati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'drijemati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nesanica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hrkati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zijevati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pidžama', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odmoran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iscrpljen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tišina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvoniti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '56ae53be-e3d4-5f51-ad62-107171864a7c', 'fill_in_the_blank', 'Kad je vruće, ne mogu ___.', 'zaspati', '["zaspim", "zaspala", "zaspati", "zaspi"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '099ab5de-ab72-5d3f-9fab-92f1d0814f9e', 'multiple_choice', 'Що означає «zvoniti»?', 'дзвонити (про дзвінок, будильник, телефон)', '["нічний кошмар", "тиша", "дрімати", "дзвонити (про дзвінок, будильник, телефон)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'zvoniti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '26f91c8f-9529-51d0-a23c-e3fa62881d17', 'multiple_choice', 'Що означає «lijegati»?', 'лягати (спати)', '["хропіти", "лягати (спати)", "лягти", "мріяти, бачити сни"]'::jsonb, 'A1', 3, 'PUBLISHED', 'lijegati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd07bc4d5-6113-565e-819c-a8c93b1fa3a6', 'multiple_choice', 'Що означає «zaspati»?', 'заснути', '["піжама", "заснути", "безсоння", "дрімати"]'::jsonb, 'A1', 4, 'PUBLISHED', 'zaspati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4ea4bbfb-f383-5f45-886a-141ed7b152cc', 'multiple_choice', 'Як хорватською «виспатися»?', 'naspavati se', '["zaspati", "lijegati", "zijevati", "naspavati se"]'::jsonb, 'A1', 5, 'PUBLISHED', 'naspavati se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5b3e7009-7092-5b87-b6ec-a7648ab84eef', 'multiple_choice', 'Як хорватською «дрімати»?', 'drijemati', '["leći", "noćna mora", "drijemati", "san"]'::jsonb, 'A1', 6, 'PUBLISHED', 'drijemati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '21f2284f-522f-5e80-a98c-19e1e4a710ca', 'type_answer', 'Напишіть хорватською: «хропіти»', 'hrkati', null, 'A1', 7, 'PUBLISHED', 'hrkati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3f11bb7d-5385-525b-96b1-4d172cd9ec06', 'type_answer', 'Напишіть хорватською: «безсоння»', 'nesanica', null, 'A1', 8, 'PUBLISHED', 'nesanica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '94b9ba16-490e-5825-89a3-05432d4ef701', 'type_answer', 'Напишіть хорватською: «відпочилий»', 'odmoran', null, 'A1', 9, 'PUBLISHED', 'odmoran', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '29e1e25b-c2bf-5189-a935-bd99ca6b490e', 'sentence_builder', 'Складіть: «Я лягаю об одинадцятій.»', 'Liježem u jedanaest.', '["u", "Liježem", "jedanaest."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d686b92-9776-5716-8bff-60a4b7996aee', 'sentence_builder', 'Складіть: «На вихідних я висипаюся.»', 'Vikendom se naspavam.', '["se", "naspavam.", "Vikendom"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c3ccf8c9-aa71-5a83-adbf-ac10c58594a1', 'listening', 'Прослухайте і складіть фразу', 'Drijemate li poslijepodne?', '["li", "Drijemate", "poslijepodne?"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8b8602d5-bb74-5812-9036-e0a2f143e8f3', 'listening', 'Прослухайте і складіть фразу', 'Ja trebam tišinu da zaspim.', '["trebam", "tišinu", "da", "Ja", "zaspim."]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '37292b50-100a-5082-bc16-d2d5b7a10c5d', 'speaking', 'Я не можу заснути.', 'Ne mogu zaspati.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9029c9c3-bf7c-510a-beae-4c253b5ecf33', 'speaking', 'Будильник дзвонить о шостій.', 'Budilica zvoni u šest.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e784baf7-d320-514c-a35a-e1c3ce955298', v_lesson, 'Безсоння', 'Nesanica', 3081, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('84482de9-a8b1-54ee-b035-0d7acbbcd5f8', 'e784baf7-d320-514c-a35a-e1c3ce955298', 'Liječnica', 'Što vas muči?', 'Що вас турбує?', 1);
  perform pg_temp.turn('4cd2b664-23f9-5916-8ff1-64824800d7ff', 'e784baf7-d320-514c-a35a-e1c3ce955298', 'Daša', 'Već tjedan dana imam nesanicu. Liježem u jedanaest, ali ne mogu zaspati.', 'Уже тиждень маю безсоння. Лягаю об одинадцятій, але не можу заснути.', 2);
  perform pg_temp.turn('61d37f34-a748-53df-a93d-0f27eb074263', 'e784baf7-d320-514c-a35a-e1c3ce955298', 'Liječnica', 'Drijemate li poslijepodne?', 'Ви дрімаєте вдень?', 3);
  perform pg_temp.turn('d9fa656c-429c-5757-bf14-aaa33ba0c9bc', 'e784baf7-d320-514c-a35a-e1c3ce955298', 'Daša', 'Ponekad, jer sam stalno iscrpljena.', 'Іноді, бо я постійно виснажена.', 4);
  perform pg_temp.turn('5b7715be-bd47-5a85-b479-f8deab678ebd', 'e784baf7-d320-514c-a35a-e1c3ce955298', 'Liječnica', 'Nemojte drijemati i navečer ne pijte kavu.', 'Не дрімайте і ввечері не пийте кави.', 5);
  perform pg_temp.turn('24a94660-2a0e-5512-821b-f490d2bbe5f2', 'e784baf7-d320-514c-a35a-e1c3ce955298', 'Daša', 'Dobro. Nadam se da ću se uskoro naspavati.', 'Добре. Сподіваюся, що скоро висплюся.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('96b05f21-39af-5993-bd49-4e5355ca1fbc', v_lesson, 'Хто хропе?', 'Tko hrče?', 3082, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('291ddfab-1a5a-5997-9dab-bb7b384a5128', '96b05f21-39af-5993-bd49-4e5355ca1fbc', 'Darja', 'Luka, ti stalno hrčeš!', 'Луко, ти постійно хропеш!', 1);
  perform pg_temp.turn('9d9dbc80-71b0-5270-9228-07604ad63ab3', '96b05f21-39af-5993-bd49-4e5355ca1fbc', 'Luka', 'Stvarno? Zato sam ujutro tako umoran.', 'Справді? То от чому я вранці такий втомлений.', 2);
  perform pg_temp.turn('a2d2fb9d-7908-5cf4-a4e9-546d5b5b99ea', '96b05f21-39af-5993-bd49-4e5355ca1fbc', 'Darja', 'Ja trebam tišinu da zaspim.', 'Мені потрібна тиша, щоб заснути.', 3);
  perform pg_temp.turn('6c40eabc-060a-59dc-9be9-81533375e29a', '96b05f21-39af-5993-bd49-4e5355ca1fbc', 'Luka', 'Imaš li noćne more?', 'У тебе бувають нічні кошмари?', 4);
  perform pg_temp.turn('0bcb40c0-6558-58e0-84f1-2d43bfee241b', '96b05f21-39af-5993-bd49-4e5355ca1fbc', 'Darja', 'Ne, ali često sanjam posao.', 'Ні, але мені часто сниться робота.', 5);
  perform pg_temp.turn('273608ff-6e97-5d70-ba87-4780359813de', '96b05f21-39af-5993-bd49-4e5355ca1fbc', 'Luka', 'Onda večeras rano legni, a ja spavam u dnevnom boravku.', 'Тоді сьогодні лягай рано, а я посплю у вітальні.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 9: Мій тиждень — перебудова: 15 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '3365f423-e694-5b55-baa1-3205fba11aff';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Мій тиждень» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '6eb75c54-e93d-5902-ac85-7dc8cb297210') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 9: Мій тиждень', title_hr = 'Lekcija 9: Moj tjedan',
         objectives = '["Розповісти про розклад тижня: početkom tjedna, krajem tjedna, sljedeći tjedan", "Домовитися, перенести або скасувати зустріч", "Модальні дієслова: moram, mogu, trebam + інфінітив"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Модальні дієслова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Модальні дієслова»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'raspored', v_pos);
  v_pos := pg_temp.word(v_lesson, 'planirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podsjetnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sjetiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dogovoriti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dogovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sastanak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otkazati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odgoditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pomaknuti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sljedeći tjedan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prošli tjedan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krajem tjedna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'početkom tjedna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'imati vremena', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd67310e4-b086-5a50-8e54-a7c1771e01c8', 'fill_in_the_blank', 'Ja sutra ne ___ doći.', 'mogu', '["moći", "može", "možeš", "mogu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '06fd09fa-0a64-537b-a7b1-5d1e3511e902', 'multiple_choice', 'Що означає «krajem tjedna»?', 'наприкінці тижня', '["зустріч / нарада", "наприкінці тижня", "нагадування", "скасувати"]'::jsonb, 'A1', 2, 'PUBLISHED', 'krajem tjedna', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4ccd7b4f-c692-5b4e-b9b9-c0471c8a044e', 'multiple_choice', 'Що означає «imati vremena»?', 'мати час', '["розклад", "нагадування", "мати час", "відкласти"]'::jsonb, 'A1', 3, 'PUBLISHED', 'imati vremena', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '05a275f3-0987-5567-9e85-a7a12af99ba9', 'multiple_choice', 'Що означає «sastanak»?', 'зустріч / нарада', '["планувати", "наступного тижня; наступний тиждень", "домовитися", "зустріч / нарада"]'::jsonb, 'A1', 4, 'PUBLISHED', 'sastanak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e5d9bb8c-e24a-553d-b85c-ae938d76f44c', 'multiple_choice', 'Як хорватською «перенести; зрушити»?', 'pomaknuti', '["podsjetnik", "pomaknuti", "sjetiti se", "početkom tjedna"]'::jsonb, 'A1', 5, 'PUBLISHED', 'pomaknuti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8bc8bbe8-73cd-5576-9728-8bf2bdfec539', 'multiple_choice', 'Як хорватською «відкласти»?', 'odgoditi', '["podsjetnik", "krajem tjedna", "otkazati", "odgoditi"]'::jsonb, 'A1', 6, 'PUBLISHED', 'odgoditi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ac40594e-ab45-54df-82fd-0efa3478f20a', 'type_answer', 'Напишіть хорватською: «домовленість»', 'dogovor', null, 'A1', 7, 'PUBLISHED', 'dogovor', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a82371ab-1e45-5cce-a06f-1a85803bd374', 'type_answer', 'Напишіть хорватською: «згадати»', 'sjetiti se', null, 'A1', 8, 'PUBLISHED', 'sjetiti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2dfea694-ef53-58b7-9b82-60d19119686d', 'type_answer', 'Напишіть хорватською: «нагадування»', 'podsjetnik', null, 'A1', 9, 'PUBLISHED', 'podsjetnik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '75ddf8ba-ed21-51ed-b641-9813853e499b', 'sentence_builder', 'Складіть: «Нам треба перенести зустріч.»', 'Moramo odgoditi sastanak.', '["sastanak.", "Moramo", "odgoditi"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d05d818-f79d-5d99-ac4e-339238b51407', 'sentence_builder', 'Складіть: «Наступного тижня я працюю з дому.»', 'Sljedeći tjedan radim od kuće.', '["radim", "Sljedeći", "kuće.", "od", "tjedan"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f55b2bb6-7842-596c-b003-d6329698a565', 'listening', 'Прослухайте і складіть фразу', 'Možemo li pomaknuti kavu na petak?', '["Možemo", "na", "li", "pomaknuti", "petak?", "kavu"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a24740d-d1b7-592a-997e-cbec835f9841', 'listening', 'Прослухайте і складіть фразу', 'Što planiraš za sljedeći tjedan?', '["Što", "tjedan?", "planiraš", "za", "sljedeći"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7e3fc9a2-e29a-5852-b7c1-9d33c53962fd', 'speaking', 'Можемо домовитися на понеділок?', 'Možemo li se dogovoriti za ponedjeljak?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '659cef32-2a48-56c9-a8c7-6bf2958c7be2', 'speaking', 'Мені треба скасувати запис.', 'Moram otkazati termin.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6eb75c54-e93d-5902-ac85-7dc8cb297210', v_lesson, 'Перенесемо?', 'Možemo li pomaknuti?', 3091, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('88605e52-9b4c-5125-9d16-8502be36e74b', '6eb75c54-e93d-5902-ac85-7dc8cb297210', 'Daša', 'Ivana, imaš li vremena u četvrtak?', 'Івано, у тебе є час у четвер?', 1);
  perform pg_temp.turn('97e86563-2230-59d0-8c61-b326b3a02509', '6eb75c54-e93d-5902-ac85-7dc8cb297210', 'Ivana', 'Nažalost nemam, imam sastanak cijeli dan.', 'На жаль, ні, у мене нарада цілий день.', 2);
  perform pg_temp.turn('6ce5efd7-2675-5425-805a-8b83573a9e14', '6eb75c54-e93d-5902-ac85-7dc8cb297210', 'Daša', 'Možemo li pomaknuti kavu na petak?', 'Можемо перенести каву на п’ятницю?', 3);
  perform pg_temp.turn('06cf2bf3-7801-595a-9973-9e6827727a00', '6eb75c54-e93d-5902-ac85-7dc8cb297210', 'Ivana', 'Može, krajem tjedna sam slobodnija.', 'Можна, наприкінці тижня я вільніша.', 4);
  perform pg_temp.turn('36f07bee-2fb6-5715-a3c8-d9f8e2cfaed6', '6eb75c54-e93d-5902-ac85-7dc8cb297210', 'Daša', 'Dogovoreno, u petak u pet.', 'Домовились, у п’ятницю о п’ятій.', 5);
  perform pg_temp.turn('59781be9-9d37-5806-ab04-b446472a3492', '6eb75c54-e93d-5902-ac85-7dc8cb297210', 'Ivana', 'Stavit ću podsjetnik u mobitel.', 'Поставлю нагадування в телефоні.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('75e183d0-ed4e-522a-b3ff-5a1d2f47dd8a', v_lesson, 'Розклад на тиждень', 'Raspored za tjedan', 3092, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('6eaae8d4-7016-5208-9905-89cf43e56585', '75e183d0-ed4e-522a-b3ff-5a1d2f47dd8a', 'Luka', 'Što planiraš za sljedeći tjedan?', 'Що ти плануєш на наступний тиждень?', 1);
  perform pg_temp.turn('517189df-f498-5dc5-b1b6-5423457e796b', '75e183d0-ed4e-522a-b3ff-5a1d2f47dd8a', 'Darja', 'Početkom tjedna imam liječnika, a u srijedu tečaj.', 'На початку тижня в мене лікар, а в середу курси.', 2);
  perform pg_temp.turn('fefef09c-f3f6-5045-bf7e-997723182fd0', '75e183d0-ed4e-522a-b3ff-5a1d2f47dd8a', 'Luka', 'Ne zaboravi, u subotu je Markov rođendan.', 'Не забудь, у суботу день народження Марка.', 3);
  perform pg_temp.turn('42d5a1ad-a3b0-5968-b399-39e4f02db1f5', '75e183d0-ed4e-522a-b3ff-5a1d2f47dd8a', 'Darja', 'Hvala što me podsjećaš! Moram kupiti poklon.', 'Дякую, що нагадуєш! Мені треба купити подарунок.', 4);
  perform pg_temp.turn('54986f7e-582e-5a6f-97e6-a2e6f86b3225', '75e183d0-ed4e-522a-b3ff-5a1d2f47dd8a', 'Luka', 'A sastanak s majstorom? Trebamo li ga otkazati?', 'А зустріч з майстром? Нам треба її скасувати?', 5);
  perform pg_temp.turn('b20236ea-5e71-54b2-b916-2038c475402e', '75e183d0-ed4e-522a-b3ff-5a1d2f47dd8a', 'Darja', 'Ne, samo ga moramo odgoditi za utorak.', 'Ні, нам треба лише перенести її на вівторок.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- 3. Нові уроки модуля A1.1
-- A1.1 · урок 10: Корисні слова: навіть, саме, знову, ще не — новий урок: 14 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := '893000a6-3e62-528c-8ecf-e644f677823c';
  v_lesson constant uuid := 'ad0bc1f4-2808-5b24-969d-9da64d4a7a4d';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 10) then
    raise exception 'A1.1: місце 10 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 10: Корисні слова: навіть, саме, знову, ще не', 'Lekcija 10: Korisne riječi: čak, baš, opet, još ne', '["Вживати маленькі слова, що оживляють мову: čak, baš, ipak, zapravo", "Сказати «ще не» і «більше не»: Još ne. Više ne radim.", "Підсилити заперечення: Uopće nisam gladna."]'::jsonb, 15, 'PUBLISHED', 10);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Заперечення' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Заперечення»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'čak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'baš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponovno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upravo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skoro', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ipak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stvarno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zapravo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uopće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'valjda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'inače', v_pos);
  v_pos := pg_temp.word(v_lesson, 'više ne', v_pos);
  v_pos := pg_temp.word(v_lesson, 'još ne', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '09c81b3c-0a48-5e17-936b-81347b941dd8', 'fill_in_the_blank', 'Radiš li još u hotelu? — Ne, ___ ne radim.', 'više', '["više", "još", "čak", "baš"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf11aed8-7bc1-555e-b198-97787553ae9d', 'multiple_choice', 'Що означає «ponovno»?', 'знову, ще раз', '["насправді", "знову, ще раз", "більше не; уже ні", "все-таки, все одно"]'::jsonb, 'A1', 2, 'PUBLISHED', 'ponovno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fafcdb48-ee1a-5a33-a859-ba49f473a698', 'multiple_choice', 'Що означає «upravo»?', 'саме зараз; щойно; якраз', '["знову, ще раз", "все-таки, все одно", "саме зараз; щойно; якраз", "справді, дійсно"]'::jsonb, 'A1', 3, 'PUBLISHED', 'upravo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '193ad7d7-d122-58ff-8bcf-36d4b291bd15', 'multiple_choice', 'Що означає «još ne»?', 'ще не; ще ні', '["справді, дійсно", "знову", "мабуть", "ще не; ще ні"]'::jsonb, 'A1', 4, 'PUBLISHED', 'još ne', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd6986624-2d86-576e-a3bc-5b7307a151a9', 'multiple_choice', 'Як хорватською «інакше; в інших випадках»?', 'inače', '["ponovno", "inače", "uopće", "upravo"]'::jsonb, 'A1', 5, 'PUBLISHED', 'inače', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '53a45506-40b9-54d7-90c4-1e8f403fc0a4', 'multiple_choice', 'Як хорватською «насправді»?', 'zapravo', '["inače", "zapravo", "opet", "valjda"]'::jsonb, 'A1', 6, 'PUBLISHED', 'zapravo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6c1dce94-97e0-59a0-beb3-881bc34291f3', 'type_answer', 'Напишіть хорватською: «навіть»', 'čak', null, 'A1', 7, 'PUBLISHED', 'čak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e9f78b68-b371-5a8d-8918-156aa59fe342', 'type_answer', 'Напишіть хорватською: «зовсім, взагалі»', 'uopće', null, 'A1', 8, 'PUBLISHED', 'uopće', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd7912399-2d63-5f72-96be-98b87012a734', 'type_answer', 'Напишіть хорватською: «справді, дійсно»', 'stvarno', null, 'A1', 9, 'PUBLISHED', 'stvarno', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '60442a32-6731-570a-80a5-45356a3bb48f', 'sentence_builder', 'Складіть: «Я більше не працюю в готелі.»', 'Više ne radim u hotelu.', '["hotelu.", "ne", "Više", "radim", "u"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ef479fcf-3743-5be6-9ee7-8979502b1138', 'sentence_builder', 'Складіть: «Він навіть не знає мого імені.»', 'On čak ne zna moje ime.', '["zna", "ime.", "moje", "čak", "ne", "On"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd7e5f695-4984-588d-9f20-1f109fbe68b6', 'listening', 'Прослухайте і складіть фразу', 'Još ne, upravo se oblačim.', '["se", "Još", "upravo", "oblačim.", "ne,"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '981230cd-1be8-5962-8de4-3fb266749dce', 'listening', 'Прослухайте і складіть фразу', 'Više ne, sada radim u školi.', '["radim", "u", "ne,", "Više", "sada", "školi."]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '002abf1f-087c-5c77-b41d-c3d9259bd2a9', 'speaking', 'Я саме виходжу з дому.', 'Upravo izlazim iz kuće.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '26eb17eb-a27e-5b65-b25d-c05dae17d5c0', 'speaking', 'Насправді я не голодна.', 'Zapravo nisam gladna.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ab4f510e-b2cb-5d16-af55-7a3a579670e2', v_lesson, 'Ти вже готова?', 'Jesi li spremna?', 3101, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('f6471f08-3e4b-5938-b4a3-064b67834502', 'ab4f510e-b2cb-5d16-af55-7a3a579670e2', 'Luka', 'Dašo, jesi li spremna?', 'Дашо, ти готова?', 1);
  perform pg_temp.turn('7915e0cd-1ac9-5c4b-94cc-03af5ee1c6ee', 'ab4f510e-b2cb-5d16-af55-7a3a579670e2', 'Daša', 'Još ne, upravo se oblačim.', 'Ще ні, саме одягаюся.', 2);
  perform pg_temp.turn('2545ef7c-07f9-586d-a38e-13bd60cdf071', 'ab4f510e-b2cb-5d16-af55-7a3a579670e2', 'Luka', 'Skoro je osam, opet ćemo zakasniti!', 'Уже майже восьма, ми знову запізнимося!', 3);
  perform pg_temp.turn('f64403f1-8ca2-5508-8fca-8e0f3a2907e6', 'ab4f510e-b2cb-5d16-af55-7a3a579670e2', 'Daša', 'Zapravo ne kasnimo, film počinje tek u pola devet.', 'Насправді ми не запізнюємося, фільм починається лише о пів на дев’яту.', 4);
  perform pg_temp.turn('be2dca72-66cc-5252-834f-7fc1cdf548c5', 'ab4f510e-b2cb-5d16-af55-7a3a579670e2', 'Luka', 'Stvarno? Onda imam vremena čak i za kavu.', 'Справді? Тоді я навіть встигну випити кави.', 5);
  perform pg_temp.turn('f6ee7a43-e54d-53a3-b95e-19b3ff898391', 'ab4f510e-b2cb-5d16-af55-7a3a579670e2', 'Daša', 'Baš tako. Ja navečer kavu uopće ne pijem.', 'Саме так. А я ввечері каву взагалі не п’ю.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('687fba20-ad05-5a05-a2b5-3dcb7a5115d0', v_lesson, 'Стара знайома', 'Stara poznanica', 3102, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('1e77ad45-1586-5443-a6d6-488335f8835f', '687fba20-ad05-5a05-a2b5-3dcb7a5115d0', 'Petra', 'Darja! Radiš li još u hotelu?', 'Дар’є! Ти ще працюєш у готелі?', 1);
  perform pg_temp.turn('bf03e333-0aa2-542e-b4a6-385c1958ed85', '687fba20-ad05-5a05-a2b5-3dcb7a5115d0', 'Darja', 'Više ne, sada radim u školi.', 'Уже ні, тепер працюю в школі.', 2);
  perform pg_temp.turn('698825f2-02ed-5907-af7b-c759a6f83f83', '687fba20-ad05-5a05-a2b5-3dcb7a5115d0', 'Petra', 'Super! Valjda ti je tamo lakše?', 'Чудово! Мабуть, тобі там легше?', 3);
  perform pg_temp.turn('3f35e515-8d92-56f6-a548-d7ab3a739aae', '687fba20-ad05-5a05-a2b5-3dcb7a5115d0', 'Darja', 'Lakše je, ali ipak puno radim.', 'Легше, але я все одно багато працюю.', 4);
  perform pg_temp.turn('fe610c85-1b7b-56a1-bef6-2bf1c8570844', '687fba20-ad05-5a05-a2b5-3dcb7a5115d0', 'Petra', 'Ja inače radim od kuće, a danas sam baš u gradu.', 'Я зазвичай працюю з дому, а сьогодні якраз у місті.', 5);
  perform pg_temp.turn('3a8fc91e-2a0f-5ff2-8a09-ad33f118631c', '687fba20-ad05-5a05-a2b5-3dcb7a5115d0', 'Darja', 'Onda idemo opet na kavu, može?', 'Тоді ходімо знову на каву, гаразд?', 6);
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
   where l.id in ('4bf48151-be83-5108-bc92-645c0603a1a3', '54f17cf7-3c17-5978-b400-b6b6888c9f84', '959e879f-a28d-5bed-9c09-16cff91ef456', '9c38f909-9275-5194-9a6e-f799c6e416ce', 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2', '1968c7d5-4e3a-5b1e-92f6-88df711e9c54', '458b73de-d6b3-5bd3-98ad-c243a2fff03f', '63a4a6d8-1cae-5e0e-90ff-98efcfe8b4c7', '3365f423-e694-5b55-baa1-3205fba11aff', 'ad0bc1f4-2808-5b24-969d-9da64d4a7a4d')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 10 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_order from (values ('4bf48151-be83-5108-bc92-645c0603a1a3'::uuid, 1), ('54f17cf7-3c17-5978-b400-b6b6888c9f84'::uuid, 2), ('959e879f-a28d-5bed-9c09-16cff91ef456'::uuid, 3), ('9c38f909-9275-5194-9a6e-f799c6e416ce'::uuid, 4), ('d43d6c65-1ce3-5c72-9ecd-cce2ed200fc2'::uuid, 5), ('1968c7d5-4e3a-5b1e-92f6-88df711e9c54'::uuid, 6), ('458b73de-d6b3-5bd3-98ad-c243a2fff03f'::uuid, 7), ('63a4a6d8-1cae-5e0e-90ff-98efcfe8b4c7'::uuid, 8), ('3365f423-e694-5b55-baa1-3205fba11aff'::uuid, 9), ('ad0bc1f4-2808-5b24-969d-9da64d4a7a4d'::uuid, 10)) as t(id, o)
    join public.lessons l on l.id = t.id and l.order_index = t.o and l.unit_id = '893000a6-3e62-528c-8ecf-e644f677823c';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A1' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('4bf48151-be83-5108-bc92-645c0603a1a3', '54f17cf7-3c17-5978-b400-b6b6888c9f84', '959e879f-a28d-5bed-9c09-16cff91ef456', '9c38f909-9275-5194-9a6e-f799c6e416ce', 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2', '1968c7d5-4e3a-5b1e-92f6-88df711e9c54', '458b73de-d6b3-5bd3-98ad-c243a2fff03f', '63a4a6d8-1cae-5e0e-90ff-98efcfe8b4c7', '3365f423-e694-5b55-baa1-3205fba11aff', 'ad0bc1f4-2808-5b24-969d-9da64d4a7a4d') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A1.1: % уроків з неправильним складом', v_bad; end if;
  if v_order <> 10 then raise exception 'Модуль A1.1: на своїх місцях % уроків з 10', v_order; end if;
  if v_titles > 0 then raise exception 'A1: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A1.1: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A1.1 — 10 уроків за темою (9 перебудовано, 1 нових)';
end $$;

commit;
