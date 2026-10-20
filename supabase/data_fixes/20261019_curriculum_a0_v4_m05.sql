-- =====================================================================
-- Уроки A0 за темою · curriculum_a0_v4 · модуль A0.5 · 2026-10-19
-- Згенеровано: python3 scripts/gen_curriculum_a0_v4.py (не редагуйте вручну).
--
-- Рішення власника 2026-10-15: слова уроку — за темою уроку, 20–25 слів і виразів, діалоги під тему; бета (PUBLISHED).
--   * Уроки 31–37: 4 наявних перебудовано, 3 нових тематичних уроків. Слів у них: 157.
--     Кожен: 20–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 52.
--   * Нові теми граматики: «Присвійні займенники».
--   * Новий порядок уроків у модулі; назви всіх уроків A0 перенумеровано підряд (разом 61).
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
values ('braća', 'braca', 'hr', 'noun', 'A0', 'брати (множина від brat)', 'core', '{"gender": "f", "singular": "brat"}'::jsonb, '["Moja braća žive u Kijevu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jedinac', 'jedinac', 'hr', 'noun', 'A0', 'єдиний син; єдина дитина в сім’ї', 'core', '{"gender": "m"}'::jsonb, '["Ja sam jedinac, nemam ni brata ni sestru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jedinica', 'jedinica', 'hr', 'noun', 'A0', 'єдина дочка; також «одиниця» (оцінка)', 'core', '{"gender": "f"}'::jsonb, '["Naša kći je jedinica."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('blizanci', 'blizanci', 'hr', 'noun', 'A0', 'близнюки', 'core', '{"gender": "m", "singular": "blizanac"}'::jsonb, '["Moji sinovi su blizanci."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('najstariji', 'najstariji', 'hr', 'adjective', 'A0', 'найстарший', 'core', '{"f": "najstarija", "n": "najstarije"}'::jsonb, '["Ja sam najstarija od troje djece."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('najmlađi', 'najmladi', 'hr', 'adjective', 'A0', 'наймолодший', 'core', '{"f": "najmlađa", "n": "najmlađe"}'::jsonb, '["Moj najmlađi brat ima deset godina."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('čije je ovo', 'cije je ovo', 'hr', 'phrase', 'A0', 'чиє це?', 'chunk', '{}'::jsonb, '["Čije je ovo dijete?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vlasnica', 'vlasnica', 'hr', 'noun', 'A0', 'власниця', 'core', '{"gender": "f", "m": "vlasnik"}'::jsonb, '["Vlasnica stana živi u Zagrebu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tuđ', 'tud', 'hr', 'adjective', 'A0', 'чужий', 'core', '{"f": "tuđa", "n": "tuđe"}'::jsonb, '["Ovo je tuđa torba, nije moja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('osobni', 'osobni', 'hr', 'adjective', 'A0', 'особистий', 'core', '{"f": "osobna", "n": "osobno"}'::jsonb, '["Ovo su moje osobne stvari."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kod mene', 'kod mene', 'hr', 'phrase', 'A0', 'у мене (вдома)', 'chunk', '{}'::jsonb, '["Večeras smo kod mene."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kod nas', 'kod nas', 'hr', 'phrase', 'A0', 'у нас (удома; у нашій країні)', 'chunk', '{}'::jsonb, '["Kod nas je uvijek puno gostiju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('razveden', 'razveden', 'hr', 'adjective', 'A0', 'розлучений', 'core', '{"f": "razvedena", "n": "razvedeno"}'::jsonb, '["Moji roditelji su razvedeni."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zaručnik', 'zarucnik', 'hr', 'noun', 'A0', 'наречений', 'core', '{"gender": "m"}'::jsonb, '["Ovo je moj zaručnik Petar."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zaručnica', 'zarucnica', 'hr', 'noun', 'A0', 'наречена', 'core', '{"gender": "f"}'::jsonb, '["Njegova zaručnica je iz Splita."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vjenčati se', 'vjencati se', 'hr', 'verb', 'A0', 'одружитися, повінчатися (про пару)', 'core', '{"aspect": "pf", "present": {"1s": "vjenčam se", "2s": "vjenčaš se", "3s": "vjenča se"}, "past": "vjenčao se"}'::jsonb, '["Vjenčali smo se prije pet godina."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('oženiti se', 'ozeniti se', 'hr', 'verb', 'A0', 'одружитися (про чоловіка)', 'core', '{"aspect": "pf", "present": {"1s": "oženim se", "2s": "oženiš se", "3s": "oženi se"}, "past": "oženio se"}'::jsonb, '["Moj brat se oženio prošle godine."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('udati se', 'udati se', 'hr', 'verb', 'A0', 'вийти заміж', 'core', '{"aspect": "pf", "present": {"1s": "udam se", "2s": "udaš se", "3s": "uda se"}, "past": "udala se"}'::jsonb, '["Sestra se udala za Hrvata."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('samac', 'samac', 'hr', 'noun', 'A0', 'неодружений чоловік; холостяк', 'core', '{"gender": "m"}'::jsonb, '["Moj kolega je samac i živi sam."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('udovica', 'udovica', 'hr', 'noun', 'A0', 'вдова', 'core', '{"gender": "f"}'::jsonb, '["Moja baka je udovica već deset godina."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stric', 'stric', 'hr', 'noun', 'A0', 'дядько (брат батька)', 'core', '{"gender": "m"}'::jsonb, '["Moj stric ima veliku kuću na selu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tetak', 'tetak', 'hr', 'noun', 'A0', 'дядько (чоловік тітки)', 'core', '{"gender": "m"}'::jsonb, '["Teta i tetak dolaze na ručak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ujna', 'ujna', 'hr', 'noun', 'A0', 'тітка (дружина брата матері)', 'core', '{"gender": "f"}'::jsonb, '["Ujna odlično kuha."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('strina', 'strina', 'hr', 'noun', 'A0', 'тітка (дружина брата батька)', 'core', '{"gender": "f"}'::jsonb, '["Strina nam je poslala paket."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nećak', 'necak', 'hr', 'noun', 'A0', 'племінник', 'core', '{"gender": "m"}'::jsonb, '["Moj nećak ide u prvi razred."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nećakinja', 'necakinja', 'hr', 'noun', 'A0', 'племінниця', 'core', '{"gender": "f"}'::jsonb, '["Nećakinja mi je nacrtala sliku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('svekrva', 'svekrva', 'hr', 'noun', 'A0', 'свекруха', 'core', '{"gender": "f"}'::jsonb, '["Svekrva nam čuva djecu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('svekar', 'svekar', 'hr', 'noun', 'A0', 'свекор', 'core', '{"gender": "m"}'::jsonb, '["Svekar voli raditi u vrtu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('punica', 'punica', 'hr', 'noun', 'A0', 'теща', 'core', '{"gender": "f"}'::jsonb, '["Punica nam dolazi za Božić."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('punac', 'punac', 'hr', 'noun', 'A0', 'тесть', 'core', '{"gender": "m"}'::jsonb, '["Moj punac je umirovljeni profesor."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('šogor', 'sogor', 'hr', 'noun', 'A0', 'шурин, дівер; чоловік сестри', 'core', '{"gender": "m"}'::jsonb, '["Šogor mi je pomogao preseliti se."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('šogorica', 'sogorica', 'hr', 'noun', 'A0', 'своячка, зовиця; дружина брата', 'core', '{"gender": "f"}'::jsonb, '["Šogorica radi u bolnici."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zet', 'zet', 'hr', 'noun', 'A0', 'зять', 'core', '{"gender": "m"}'::jsonb, '["Naš zet je jako dobar čovjek."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('snaha', 'snaha', 'hr', 'noun', 'A0', 'невістка', 'core', '{"gender": "f"}'::jsonb, '["Snaha i sin žive u Zagrebu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kum', 'kum', 'hr', 'noun', 'A0', 'хрещений батько; свідок на весіллі', 'core', '{"gender": "m"}'::jsonb, '["Marko mi je bio kum na vjenčanju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kuma', 'kuma', 'hr', 'noun', 'A0', 'хрещена мати; свідкиня на весіллі', 'core', '{"gender": "f"}'::jsonb, '["Kuma je donijela poklon za bebu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tinejdžer', 'tinejdzer', 'hr', 'noun', 'A0', 'підліток', 'core', '{"gender": "m", "f": "tinejdžerica"}'::jsonb, '["Moj sin je tinejdžer i stalno je na mobitelu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odgojiteljica', 'odgojiteljica', 'hr', 'noun', 'A0', 'вихователька (у дитсадку)', 'core', '{"gender": "f", "m": "odgojitelj"}'::jsonb, '["Odgojiteljica kaže da se Lea lijepo igra."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('najbolji prijatelj', 'najbolji prijatelj', 'hr', 'phrase', 'A0', 'найкращий друг', 'collocation', '{"f": "najbolja prijateljica"}'::jsonb, '["Luka je moj najbolji prijatelj."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('družiti se', 'druziti se', 'hr', 'verb', 'A0', 'проводити час разом; товаришувати', 'core', '{"aspect": "ipf", "present": {"1s": "družim se", "2s": "družiš se", "3s": "druži se"}, "past": "družio se"}'::jsonb, '["Volim se družiti s kolegama poslije posla."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mršav', 'mrsav', 'hr', 'adjective', 'A0', 'худий', 'core', '{"f": "mršava", "n": "mršavo"}'::jsonb, '["Moj brat je visok i mršav."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kovrčav', 'kovrcav', 'hr', 'adjective', 'A0', 'кучерявий', 'core', '{"f": "kovrčava", "n": "kovrčavo"}'::jsonb, '["Moja kći ima kovrčavu kosu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('brada', 'brada', 'hr', 'noun', 'A0', 'борода; підборіддя', 'core', '{"gender": "f"}'::jsonb, '["Moj muž ima kratku bradu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('brkovi', 'brkovi', 'hr', 'noun', 'A0', 'вуса', 'core', '{"gender": "m", "plural_only": true}'::jsonb, '["Djed ima velike sijede brkove."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mače', 'mace', 'hr', 'noun', 'A0', 'кошеня', 'core', '{"gender": "n", "plural": "mačići"}'::jsonb, '["Susjedi imaju malo crno mače."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('papiga', 'papiga', 'hr', 'noun', 'A0', 'папуга', 'core', '{"gender": "f"}'::jsonb, '["Naša papiga zna nekoliko riječi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ribica', 'ribica', 'hr', 'noun', 'A0', 'рибка', 'core', '{"gender": "f"}'::jsonb, '["Djeca imaju dvije zlatne ribice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('hrčak', 'hrcak', 'hr', 'noun', 'A0', 'хом’як', 'core', '{"gender": "m"}'::jsonb, '["Hrčak spava cijeli dan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zec', 'zec', 'hr', 'noun', 'A0', 'кролик; заєць', 'core', '{"gender": "m"}'::jsonb, '["Moja kći želi zeca za rođendan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kornjača', 'kornjaca', 'hr', 'noun', 'A0', 'черепаха', 'core', '{"gender": "f"}'::jsonb, '["Kornjača jede salatu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('maziti', 'maziti', 'hr', 'verb', 'A0', 'пестити, гладити', 'core', '{"aspect": "ipf", "present": {"1s": "mazim", "2s": "maziš", "3s": "mazi"}, "past": "mazio"}'::jsonb, '["Mačka voli kad je mazimo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ugristi', 'ugristi', 'hr', 'verb', 'A0', 'вкусити', 'core', '{"aspect": "pf", "present": {"1s": "ugrizem", "2s": "ugrizeš", "3s": "ugrize"}, "past": "ugrizao"}'::jsonb, '["Pazi, pas može ugristi!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;

-- 1а. Нові теми граматики A0 (1)
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '4fea3ec1-5230-5d19-b044-f402c1ca6f56', 'A0', 'Присвійні займенники', 'Posvojne zamjenice', 'Чий? Чия? Чиє? — moj, tvoj, njegov, njezin, naš, vaš, njihov і svoj. Займенник узгоджується з тим, що належить.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Присвійні займенники');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '957e077c-ce0f-56c8-9514-1b313e8ec0e0', '4fea3ec1-5230-5d19-b044-f402c1ca6f56', 'Мій, твій, наш, ваш', 'Як прикметник, займенник узгоджується з річчю, а не з власником: moj brat, moja sestra, moje dijete; множина — moji roditelji, moje sestre. Так само tvoj / tvoja / tvoje, naš / naša / naše, vaš / vaša / vaše. Ввічливе Vaš пишуть з великої літери: Vaša putovnica.', 'moj brat · moja sestra · moje dijete', '[{"hr": "Ovo je moja sestra.", "ua": "Це моя сестра."}, {"hr": "Gdje su tvoji roditelji?", "ua": "Де твої батьки?"}, {"hr": "Naš stan je mali.", "ua": "Наша квартира маленька."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '4fea3ec1-5230-5d19-b044-f402c1ca6f56')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '2c6a607c-e5dd-5f5b-a295-220f65a898aa', '4fea3ec1-5230-5d19-b044-f402c1ca6f56', 'Його, її, їхній', 'Українські «його», «її», «їхній» не змінюються, а хорватські змінюються за родом речі: njegov brat, njegova sestra; njezin muž, njezina kći (розмовно також njen, njena); njihov sin, njihova kći.', 'njegova sestra · njezin muž · njihov sin', '[{"hr": "Marko je ovdje, a njegova žena je na poslu.", "ua": "Марко тут, а його дружина на роботі."}, {"hr": "Ivana i njezin muž žive u Splitu.", "ua": "Івана та її чоловік живуть у Спліті."}, {"hr": "Njihova kći ide u vrtić.", "ua": "Їхня донька ходить у садочок."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '4fea3ec1-5230-5d19-b044-f402c1ca6f56')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'b6d8c184-9004-5ed6-aaac-aa66aa40a931', '4fea3ec1-5230-5d19-b044-f402c1ca6f56', 'Svoj — «свій»', 'Як і українське «свій», svoj показує, що річ належить тому, хто діє в реченні: Volim svoju obitelj. Порівняйте: Marko voli svoju ženu (свою) — Marko voli njegovu ženu (дружину іншого чоловіка).', 'Volim svoju obitelj.', '[{"hr": "Daša traži svoj ključ.", "ua": "Даша шукає свій ключ."}, {"hr": "Uzmi svoje stvari.", "ua": "Візьми свої речі."}, {"hr": "Djeca se igraju sa svojim psom.", "ua": "Діти граються зі своїм собакою."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '4fea3ec1-5230-5d19-b044-f402c1ca6f56')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '5355929d-ac16-5260-ab4b-1c02dddac8b4', '4fea3ec1-5230-5d19-b044-f402c1ca6f56', 'Чий? Чия? Чиє?', 'Питання теж узгоджується з річчю: čiji (ч. р.), čija (ж. р.), čije (с. р.). Відповідь — займенником: Čija je ovo torba? — Moja.', 'Čija je ovo torba? — Moja.', '[{"hr": "Čiji je ovo mobitel?", "ua": "Чий це мобільний?"}, {"hr": "Čija je ovo jakna?", "ua": "Чия це куртка?"}, {"hr": "Čije je ovo dijete?", "ua": "Чия це дитина?"}]'::jsonb, 4
where exists (select 1 from public.grammar_topics where id = '4fea3ec1-5230-5d19-b044-f402c1ca6f56')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '4fea3ec1-5230-5d19-b044-f402c1ca6f56', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нова тема граматики A0 для уроків за темою (curriculum_a0_v4) за запитом власника 2026-10-19. Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '4fea3ec1-5230-5d19-b044-f402c1ca6f56')
  and not exists (select 1 from public.content_reviews where entity_id = '4fea3ec1-5230-5d19-b044-f402c1ca6f56' and notes = 'Бета: нова тема граматики A0 для уроків за темою (curriculum_a0_v4) за запитом власника 2026-10-19. Потрібна перевірка носієм.');

-- 2. Перебудова наявних уроків модуля A0.5
-- A0.5 · урок 31: Моя сім’я — перебудова: 21 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '4e003796-1ce0-5a02-8a2d-59a0de38f3dd';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Моя сім’я» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '44efab41-a829-5647-b903-6673a3c46e0e') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 31: Моя сім’я', title_hr = 'Lekcija 31: Moja obitelj',
         objectives = '["Назвати членів сім’ї: majka, otac, brat, sestra, sin, kći", "Показати фото й сказати, хто це", "Розповісти про бабусю, дідуся й онуків"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'obitelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'roditelji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'majka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mama', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sestra', v_pos);
  v_pos := pg_temp.word(v_lesson, 'braća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'baka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'djed', v_pos);
  v_pos := pg_temp.word(v_lesson, 'unuk', v_pos);
  v_pos := pg_temp.word(v_lesson, 'unuka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jedinac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jedinica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blizanci', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najstariji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najmlađi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tko je to', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '35170be0-e037-5893-afaa-2f71158a8cd0', 'fill_in_the_blank', 'Ovo su moji ___.', 'roditelji', '["roditelji", "roditeljima", "roditelja", "roditelje"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '23a0f9db-b2eb-5e35-9566-f2f706d131e1', 'multiple_choice', 'Що означає «braća»?', 'брати (множина від brat)', '["сім''я, родина", "батьки", "онука", "брати (множина від brat)"]'::jsonb, 'A0', 2, 'PUBLISHED', 'braća', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eff5ce90-bf78-5f5c-95bb-2609fef0b494', 'multiple_choice', 'Що означає «unuka»?', 'онука', '["бабуся", "єдина дочка; також «одиниця» (оцінка)", "хто це", "онука"]'::jsonb, 'A0', 3, 'PUBLISHED', 'unuka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd9a066a9-8913-5bba-9789-3615ec8d62f5', 'multiple_choice', 'Що означає «majka»?', 'мати', '["брат", "мати", "єдина дочка; також «одиниця» (оцінка)", "найстарший"]'::jsonb, 'A0', 4, 'PUBLISHED', 'majka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd144541-f7b7-5011-bd71-e43a4fd439da', 'multiple_choice', 'Як хорватською «найстарший»?', 'najstariji', '["brat", "djed", "najmlađi", "najstariji"]'::jsonb, 'A0', 5, 'PUBLISHED', 'najstariji', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '35630209-14e4-5db2-a74e-a2212481c410', 'multiple_choice', 'Як хорватською «наймолодший»?', 'najmlađi', '["brat", "otac", "tko je to", "najmlađi"]'::jsonb, 'A0', 6, 'PUBLISHED', 'najmlađi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '86207bd1-4bc0-52e9-97b0-3ad9b243342e', 'type_answer', 'Напишіть хорватською: «онук»', 'unuk', null, 'A0', 7, 'PUBLISHED', 'unuk', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1dec0e1b-6b75-55c1-82d8-19a2b1262fa7', 'type_answer', 'Напишіть хорватською: «батьки»', 'roditelji', null, 'A0', 8, 'PUBLISHED', 'roditelji', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '55992a8d-7b03-5ca8-b617-b7db78c64c72', 'type_answer', 'Напишіть хорватською: «дідусь»', 'djed', null, 'A0', 9, 'PUBLISHED', 'djed', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fc268546-ddf2-58ca-a33a-c73bd6a73a5f', 'sentence_builder', 'Складіть: «Це моя сім’я.»', 'To je moja obitelj.', '["To", "obitelj.", "moja", "je"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fb7fa8a7-e0df-5d97-9f5f-bcf12710ff57', 'sentence_builder', 'Складіть: «Мій брат наймолодший.»', 'Moj brat je najmlađi.', '["je", "najmlađi.", "Moj", "brat"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '635953c5-e4dc-5872-b092-df699e9b89bb', 'listening', 'Прослухайте і складіть фразу', 'On je najmlađi u obitelji.', '["obitelji.", "najmlađi", "je", "On", "u"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dce5dab8-cee3-5ddd-b4d6-7e893c7989c8', 'listening', 'Прослухайте і складіть фразу', 'Imam sina i kćer.', '["kćer.", "sina", "i", "Imam"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd7e9e251-01a6-55c3-8a20-edc1797365a8', 'speaking', 'Хто це?', 'Tko je to?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '29dc8b0f-5e31-5eab-a0aa-d0aceb23ea73', 'speaking', 'Це мій тато.', 'Ovo je moj tata.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('44efab41-a829-5647-b903-6673a3c46e0e', v_lesson, 'Сімейне фото', 'Obiteljska fotografija', 2311, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('d0db6a88-730e-5749-9073-6a2486a2e89d', '44efab41-a829-5647-b903-6673a3c46e0e', 'Ivana', 'Dašo, tko je to na slici?', 'Дашо, хто це на фото?', 1);
  perform pg_temp.turn('de525d21-ceff-5885-ad4d-27a728925b97', '44efab41-a829-5647-b903-6673a3c46e0e', 'Daša', 'To je moja obitelj. Ovo su moji roditelji.', 'Це моя сім’я. Це мої батьки.', 2);
  perform pg_temp.turn('3884251a-c6aa-573a-bc3e-ee5138a66f20', '44efab41-a829-5647-b903-6673a3c46e0e', 'Ivana', 'A tko je ovaj dječak?', 'А хто цей хлопчик?', 3);
  perform pg_temp.turn('be041ea0-59d3-5eff-8a43-2f1a7c182da6', '44efab41-a829-5647-b903-6673a3c46e0e', 'Daša', 'To je moj brat Andrij. On je najmlađi u obitelji.', 'Це мій брат Андрій. Він наймолодший у сім’ї.', 4);
  perform pg_temp.turn('ff4375b8-8c24-5093-84ae-0935ce7f650a', '44efab41-a829-5647-b903-6673a3c46e0e', 'Ivana', 'Kako ste slični! A djevojka pored tebe?', 'Які ви схожі! А дівчина поруч із тобою?', 5);
  perform pg_temp.turn('31a72cb5-f27d-5517-87a1-4a2f5f09a9e3', '44efab41-a829-5647-b903-6673a3c46e0e', 'Daša', 'To je moja sestra Olena. Ona je najstarija.', 'Це моя сестра Олена. Вона найстарша.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('05be3692-f5f7-5837-b6f5-4e2ce6697724', v_lesson, 'Бабуся й дідусь', 'Baka i djed', 2312, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('c657e8a3-e14a-5c77-9e6b-1d5149142ec8', '05be3692-f5f7-5837-b6f5-4e2ce6697724', 'Marko', 'Dašo, imaš li baku i djeda?', 'Дашо, у тебе є бабуся й дідусь?', 1);
  perform pg_temp.turn('e4290c42-967d-5403-9f34-1cbd8bc2411c', '05be3692-f5f7-5837-b6f5-4e2ce6697724', 'Daša', 'Imam. Baka i djed žive u Poltavi.', 'Так. Бабуся й дідусь живуть у Полтаві.', 2);
  perform pg_temp.turn('c6e25ec3-abbe-591f-842a-5b6ec1091548', '05be3692-f5f7-5837-b6f5-4e2ce6697724', 'Marko', 'Imaju li puno unuka?', 'У них багато онуків?', 3);
  perform pg_temp.turn('e9fedcf4-9891-5414-8e1d-abca9995b7b2', '05be3692-f5f7-5837-b6f5-4e2ce6697724', 'Daša', 'Imaju četiri unuka i dvije unuke.', 'Четверо онуків і дві онучки.', 4);
  perform pg_temp.turn('c8200225-63fd-511b-89ca-e8f3707baa51', '05be3692-f5f7-5837-b6f5-4e2ce6697724', 'Marko', 'A ti, imaš li djecu?', 'А в тебе є діти?', 5);
  perform pg_temp.turn('1a783311-f39d-5001-b8c0-e16e64021c0c', '05be3692-f5f7-5837-b6f5-4e2ce6697724', 'Daša', 'Imam sina i kćer.', 'Маю сина й доньку.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.5 · урок 33: Шлюб і стосунки — перебудова: 23 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'f9ca38e4-3a61-56a6-b5f5-060933516c9a';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Шлюб і стосунки» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '246b980f-2b43-53f6-a151-9195acf2608b') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 33: Шлюб і стосунки', title_hr = 'Lekcija 33: Brak i veze',
         objectives = '["Сказати, одружені ви чи ні: oženjen, udana, razveden", "Розповісти про хлопця, дівчину, нареченого", "Розрізняти oženiti se (про чоловіка), udati se (про жінку), vjenčati se (про пару)"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'brak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'muž', v_pos);
  v_pos := pg_temp.word(v_lesson, 'supruga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'suprug', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oženjen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razveden', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaručen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaručnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaručnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vjenčanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vjenčati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oženiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dečko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cura', v_pos);
  v_pos := pg_temp.word(v_lesson, 'partner', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljubav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'voljeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaljubiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rastati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'samac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udovica', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f05076e-32ff-5514-9a2a-3ccbe6dd8300', 'fill_in_the_blank', 'Ivana se ___ prošle godine.', 'udala', '["oženio", "udao", "udala", "oženila"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae98cbfe-2a46-5b88-93c3-f61966bc1480', 'multiple_choice', 'Що означає «suprug»?', 'чоловік (шлюбний)', '["партнер", "весілля", "одружитися (про чоловіка)", "чоловік (шлюбний)"]'::jsonb, 'A0', 2, 'PUBLISHED', 'suprug', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '666c4f72-564d-5cd0-8aee-761118b554bc', 'multiple_choice', 'Що означає «ljubav»?', 'любов', '["шлюб", "любов", "наречена", "розлучений"]'::jsonb, 'A0', 3, 'PUBLISHED', 'ljubav', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '45eb575b-fdc0-5d04-b390-cd84b334d939', 'multiple_choice', 'Що означає «udovica»?', 'вдова', '["розлучитися; розійтися", "вдова", "любов", "чоловік (у шлюбі)"]'::jsonb, 'A0', 4, 'PUBLISHED', 'udovica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e9d4b3e4-5da6-503f-ad79-5e6e990b17be', 'multiple_choice', 'Як хорватською «любити, подобатися»?', 'voljeti', '["voljeti", "zaljubiti se", "zaručnik", "oženjen"]'::jsonb, 'A0', 5, 'PUBLISHED', 'voljeti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3018c164-e757-52dd-b8ff-bb52b1753c56', 'multiple_choice', 'Як хорватською «закохатися»?', 'zaljubiti se', '["udana", "partner", "zaljubiti se", "voljeti"]'::jsonb, 'A0', 6, 'PUBLISHED', 'zaljubiti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bb4fa337-b818-58ec-bece-3a4048a38e46', 'type_answer', 'Напишіть хорватською: «партнер»', 'partner', null, 'A0', 7, 'PUBLISHED', 'partner', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f476b18e-e6bd-5f83-9a3f-c72ceb597414', 'type_answer', 'Напишіть хорватською: «заміжня»', 'udana', null, 'A0', 8, 'PUBLISHED', 'udana', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cc33432f-89fa-5a12-8015-aa66fa145b35', 'type_answer', 'Напишіть хорватською: «шлюб»', 'brak', null, 'A0', 9, 'PUBLISHED', 'brak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '624a3dc0-6698-5db9-939e-42db2af07e44', 'sentence_builder', 'Складіть: «Ти одружений?»', 'Jesi li oženjen?', '["oženjen?", "li", "Jesi"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '348e8456-c6a6-5f77-bd55-992b820455af', 'sentence_builder', 'Складіть: «Мій чоловік працює в Німеччині.»', 'Moj muž radi u Njemačkoj.', '["Moj", "Njemačkoj.", "radi", "muž", "u"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '37196b63-de85-5bc7-8ada-cf6c663c9153', 'listening', 'Прослухайте і складіть фразу', 'Zaljubio sam se odmah!', '["se", "sam", "odmah!", "Zaljubio"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8572d4f4-0a76-530e-9947-d5a2812f92e1', 'listening', 'Прослухайте і складіть фразу', 'Vjenčanje je u lipnju.', '["u", "Vjenčanje", "lipnju.", "je"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0b922670-f628-5085-acb6-f80f1e63b160', 'speaking', 'Я заміжня.', 'Udana sam.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd82096a9-fef4-50df-9579-c3cf741b5821', 'speaking', 'Вітаю!', 'Čestitam!', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('246b980f-2b43-53f6-a151-9195acf2608b', v_lesson, 'Ти одружений?', 'Jesi li oženjen?', 2331, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('5d0bb323-b7d1-5fc1-9f4c-296e53d379c5', '246b980f-2b43-53f6-a151-9195acf2608b', 'Daša', 'Marko, jesi li oženjen?', 'Марку, ти одружений?', 1);
  perform pg_temp.turn('324f1a73-8051-5635-a23e-6f1ee0f96b6f', '246b980f-2b43-53f6-a151-9195acf2608b', 'Marko', 'Jesam, već deset godina. Moja supruga se zove Ana.', 'Так, уже десять років. Мою дружину звати Ана.', 2);
  perform pg_temp.turn('a27959d2-dfdf-5c1f-b641-c5e4716bec7d', '246b980f-2b43-53f6-a151-9195acf2608b', 'Daša', 'Gdje ste se upoznali?', 'Де ви познайомилися?', 3);
  perform pg_temp.turn('3d5b3e8e-d820-5db0-9426-be7d3edac56d', '246b980f-2b43-53f6-a151-9195acf2608b', 'Marko', 'Na fakultetu. Zaljubio sam se odmah! A ti, jesi li udana?', 'В університеті. Я закохався одразу! А ти заміжня?', 4);
  perform pg_temp.turn('c7de7488-b75f-5001-8c31-c680a4090735', '246b980f-2b43-53f6-a151-9195acf2608b', 'Daša', 'Jesam. Moj muž sada radi u Njemačkoj.', 'Так. Мій чоловік зараз працює в Німеччині.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('03f0b63b-a306-5445-8033-3fe224daac74', v_lesson, 'Весілля', 'Vjenčanje', 2332, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('b88403b8-5eb5-5162-9a49-b096611a67ec', '03f0b63b-a306-5445-8033-3fe224daac74', 'Ivana', 'Dašo, imam veliku vijest. Zaručena sam!', 'Дашо, у мене велика новина. Я заручена!', 1);
  perform pg_temp.turn('7c400b76-8728-5e7c-a3dd-83e60e7a89d5', '03f0b63b-a306-5445-8033-3fe224daac74', 'Daša', 'Čestitam! Tko je sretnik?', 'Вітаю! І хто ж цей щасливчик?', 2);
  perform pg_temp.turn('5f3303c3-1a55-5925-aa29-cb52319fe432', '03f0b63b-a306-5445-8033-3fe224daac74', 'Ivana', 'Moj dečko Petar. Vjenčanje je u lipnju.', 'Мій хлопець Петар. Весілля в червні.', 3);
  perform pg_temp.turn('2cef9089-dd1a-506f-8803-79634a052ac3', '03f0b63b-a306-5445-8033-3fe224daac74', 'Daša', 'Divno! Gdje ćete se vjenčati?', 'Чудово! Де ви будете вінчатися?', 4);
  perform pg_temp.turn('ce91fc13-e3b2-5fda-9abb-cd56ea0bfe6b', '03f0b63b-a306-5445-8033-3fe224daac74', 'Ivana', 'U crkvi u Zadru. Naravno, i ti si pozvana!', 'У церкві в Задарі. Звісно, ти теж запрошена!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.5 · урок 34: Родичі — перебудова: 23 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'cec08ff0-a97d-5847-88cc-dee22fed2f8c';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Родичі» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '40dec41a-32c8-5bfc-a3d1-48031532ba17') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 34: Родичі', title_hr = 'Lekcija 34: Rodbina',
         objectives = '["Назвати родичів: teta, ujak, stric, bratić, sestrična, nećak", "Назвати родичів чоловіка чи дружини: svekrva, punica, šogor", "Розповісти, чи є у вас родичі в Хорватії"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'rodbina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rođak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rođakinja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bratić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sestrična', v_pos);
  v_pos := pg_temp.word(v_lesson, 'teta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ujak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stric', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tetak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ujna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'strina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nećak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nećakinja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svekrva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svekar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'punica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'punac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šogor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šogorica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'snaha', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kum', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kuma', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '201a516b-868d-5088-95ab-edcbb3c76a21', 'fill_in_the_blank', 'Imam dva ___.', 'bratića', '["bratića", "bratić", "bratićem", "bratiće"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2155c944-65b0-55c7-a4be-1e75805ad963', 'multiple_choice', 'Що означає «rođakinja»?', 'родичка', '["свекруха", "родичка", "шурин, дівер; чоловік сестри", "родич"]'::jsonb, 'A0', 2, 'PUBLISHED', 'rođakinja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b6ca9d7f-deaa-5816-8be7-cb89998127ac', 'multiple_choice', 'Що означає «punac»?', 'тесть', '["зять", "дядько (брат матері)", "родич", "тесть"]'::jsonb, 'A0', 3, 'PUBLISHED', 'punac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a7de0582-5698-553f-a0ae-dea3299dd2fa', 'multiple_choice', 'Що означає «punica»?', 'теща', '["двоюрідна сестра", "теща", "хрещений батько; свідок на весіллі", "племінниця"]'::jsonb, 'A0', 4, 'PUBLISHED', 'punica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ab144d03-172c-55b7-bf50-8fb8a30bc925', 'multiple_choice', 'Як хорватською «племінниця»?', 'nećakinja', '["rođak", "nećakinja", "stric", "snaha"]'::jsonb, 'A0', 5, 'PUBLISHED', 'nećakinja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '046dab33-a577-5765-90ac-ab2d63c2c08f', 'multiple_choice', 'Як хорватською «свекор»?', 'svekar', '["šogorica", "svekrva", "šogor", "svekar"]'::jsonb, 'A0', 6, 'PUBLISHED', 'svekar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '88c4ea0a-62a4-5147-8d09-cf0bca1212af', 'type_answer', 'Напишіть хорватською: «невістка»', 'snaha', null, 'A0', 7, 'PUBLISHED', 'snaha', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ed9f067-4ced-58ba-978c-dc26f7892506', 'type_answer', 'Напишіть хорватською: «племінник»', 'nećak', null, 'A0', 8, 'PUBLISHED', 'nećak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '095eab17-9894-575b-9136-49c302d7e3bd', 'type_answer', 'Напишіть хорватською: «свекруха»', 'svekrva', null, 'A0', 9, 'PUBLISHED', 'svekrva', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f4b9d15e-80b4-545f-ba8e-3d7d3dddf4b0', 'sentence_builder', 'Складіть: «У мене є родичі в Хорватії.»', 'Imam rodbinu u Hrvatskoj.', '["rodbinu", "u", "Imam", "Hrvatskoj."]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e87223fa-85a6-5846-9c0a-0795a09de268', 'sentence_builder', 'Складіть: «Моя тітка живе в Рієці.»', 'Moja teta živi u Rijeci.', '["Moja", "teta", "Rijeci.", "živi", "u"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3e619532-1d0b-5db9-a62a-3e76a89809fc', 'listening', 'Прослухайте і складіть фразу', 'Imaju li djecu?', '["djecu?", "Imaju", "li"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ecb48b3b-0f02-5377-82f5-81aead52be7e', 'listening', 'Прослухайте і складіть фразу', 'Kako se slažete?', '["se", "Kako", "slažete?"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '914c0bd7-919d-5be4-be2d-a30d29471dab', 'speaking', 'Це мій двоюрідний брат.', 'Ovo je moj bratić.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9913a2bd-7d8e-5d08-9cb6-4d39a67d86ff', 'speaking', 'У тебе є родичі тут?', 'Imaš li rodbinu ovdje?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('40dec41a-32c8-5bfc-a3d1-48031532ba17', v_lesson, 'Родичі в Хорватії', 'Rodbina u Hrvatskoj', 2341, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('f00875cd-ffcc-58a4-be5d-b27591f1f3fc', '40dec41a-32c8-5bfc-a3d1-48031532ba17', 'Luka', 'Dašo, imaš li rodbinu u Hrvatskoj?', 'Дашо, у тебе є родичі в Хорватії?', 1);
  perform pg_temp.turn('f24fad3c-b730-50b0-b1d9-068c8803f585', '40dec41a-32c8-5bfc-a3d1-48031532ba17', 'Daša', 'Imam. Moja teta živi u Rijeci sa svojim mužem.', 'Так. Моя тітка живе в Рієці зі своїм чоловіком.', 2);
  perform pg_temp.turn('a6213a06-4cef-512c-8a21-5c92dd943245', '40dec41a-32c8-5bfc-a3d1-48031532ba17', 'Luka', 'Imaju li djecu?', 'У них є діти?', 3);
  perform pg_temp.turn('145ae8d1-4b8c-550d-8915-2d5bed0627aa', '40dec41a-32c8-5bfc-a3d1-48031532ba17', 'Daša', 'Imaju sina, mog bratića Oleha. I on radi ovdje.', 'У них є син, мій двоюрідний брат Олег. Він теж тут працює.', 4);
  perform pg_temp.turn('bb0c3102-f44d-56b2-a6c5-40feefba37bb', '40dec41a-32c8-5bfc-a3d1-48031532ba17', 'Luka', 'Super, onda nisi sama ovdje.', 'Чудово, значить, ти тут не сама.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7f47131b-df80-5ba7-bb3a-df5d15d1a4bf', v_lesson, 'Свекруха в гостях', 'Svekrva u posjetu', 2342, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('979e5b6b-b1ad-5070-b005-5f8338c69e64', '7f47131b-df80-5ba7-bb3a-df5d15d1a4bf', 'Ivana', 'Dašo, što radiš ovaj vikend?', 'Дашо, що робиш на цих вихідних?', 1);
  perform pg_temp.turn('cf9c48ca-48ea-5e19-b038-c12daedc03eb', '7f47131b-df80-5ba7-bb3a-df5d15d1a4bf', 'Daša', 'Dolazi mi svekrva iz Ukrajine, mama mog muža.', 'До мене приїжджає свекруха з України, мама мого чоловіка.', 2);
  perform pg_temp.turn('2e7f49d5-c3f9-5dd0-a2f3-f2ff1cc503b1', '7f47131b-df80-5ba7-bb3a-df5d15d1a4bf', 'Ivana', 'Kako se slažete?', 'Як ви ладнаєте?', 3);
  perform pg_temp.turn('722aa97a-ff2b-5a2b-876f-1e69ecbea173', '7f47131b-df80-5ba7-bb3a-df5d15d1a4bf', 'Daša', 'Dobro, ona je jako draga. Uvijek donese poklone unucima.', 'Добре, вона дуже мила. Завжди привозить подарунки онукам.', 4);
  perform pg_temp.turn('6eb24fba-92e2-558e-886b-ba5f4a1ee1dd', '7f47131b-df80-5ba7-bb3a-df5d15d1a4bf', 'Ivana', 'Blago tebi! Moja svekrva stalno nešto kritizira.', 'Щаслива ти! Моя свекруха постійно щось критикує.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.5 · урок 35: Діти й друзі — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '2b0e9742-99e1-57e1-a574-67ffb78d2607';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Діти й друзі» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '406b74bf-3f3b-5fa4-a3a1-80ec0b7d756b') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 35: Діти й друзі', title_hr = 'Lekcija 35: Djeca i prijatelji',
         objectives = '["Говорити про дітей: dječak, djevojčica, vrtić, škola", "Записати дитину в садочок і познайомитися з іншими батьками", "Розповісти про найкращого друга й запросити на свято"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'dijete', v_pos);
  v_pos := pg_temp.word(v_lesson, 'djeca', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dječak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'djevojčica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tinejdžer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrtić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'škola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'učiteljica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odgojiteljica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijatelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijateljica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najbolji prijatelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'družiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'igrati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'igračka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'igralište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pozvati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zabava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posjetiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dadilja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upisati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razred', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '4c3adf2e-a0c8-51eb-aafd-9ba06db0032c', 'fill_in_the_blank', 'Djeca se igraju na ___.', 'igralištu', '["igralište", "igralištem", "igralištu", "igrališta"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '40532a7a-e229-56f7-8821-b3f2c1b4686d', 'multiple_choice', 'Що означає «učiteljica»?', 'учителька', '["розвага / вечірка", "відвідати", "учителька", "няня"]'::jsonb, 'A0', 2, 'PUBLISHED', 'učiteljica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4ebe519e-2c6d-59b8-8eb5-0656e5d986a2', 'multiple_choice', 'Що означає «škola»?', 'школа', '["друг", "клас (група учнів)", "школа", "проводити час разом; товаришувати"]'::jsonb, 'A0', 3, 'PUBLISHED', 'škola', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a7770109-d42e-571e-95c8-e5d2d317f34c', 'multiple_choice', 'Що означає «igračka»?', 'іграшка', '["іграшка", "найкращий друг", "дівчинка", "хлопчик"]'::jsonb, 'A0', 4, 'PUBLISHED', 'igračka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a973724-cfe8-5c80-b2e2-a1a4f69a5f85', 'multiple_choice', 'Як хорватською «няня»?', 'dadilja', '["družiti se", "dadilja", "djeca", "škola"]'::jsonb, 'A0', 5, 'PUBLISHED', 'dadilja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '268bef73-1346-5f42-8daf-74a501d67bb1', 'multiple_choice', 'Як хорватською «хлопчик»?', 'dječak', '["družiti se", "vrtić", "djevojčica", "dječak"]'::jsonb, 'A0', 6, 'PUBLISHED', 'dječak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '62b6decb-da04-59ad-8284-ebb11738b345', 'type_answer', 'Напишіть хорватською: «клас (група учнів)»', 'razred', null, 'A0', 7, 'PUBLISHED', 'razred', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '55b5bbe9-642f-5280-a335-47ffc86d9fad', 'type_answer', 'Напишіть хорватською: «подруга»', 'prijateljica', null, 'A0', 8, 'PUBLISHED', 'prijateljica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '60927cd1-b067-54d1-a45b-e46c7d3c33fa', 'type_answer', 'Напишіть хорватською: «діти»', 'djeca', null, 'A0', 9, 'PUBLISHED', 'djeca', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dfc28a50-944f-55c5-8547-e75546b2a54e', 'sentence_builder', 'Складіть: «Діти граються в парку.»', 'Djeca se igraju u parku.', '["se", "parku.", "igraju", "Djeca", "u"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f477d5b-ebdd-5827-a0bb-7e97225390b9', 'sentence_builder', 'Складіть: «Вона моя найкраща подруга.»', 'Ona je moja najbolja prijateljica.', '["najbolja", "Ona", "je", "moja", "prijateljica."]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '87daf31e-523a-595b-b110-e55726b8411a', 'listening', 'Прослухайте і складіть фразу', 'Ide li Lea u vrtić?', '["vrtić?", "li", "Lea", "u", "Ide"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cd8126f4-677a-50a8-980e-43e7cd9bb1e2', 'listening', 'Прослухайте і складіть фразу', 'Sjedimo zajedno u razredu.', '["zajedno", "razredu.", "u", "Sjedimo"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fffd6dcc-f83a-50db-81dc-d7efca9d92be', 'speaking', 'Мій син ходить у школу.', 'Moj sin ide u školu.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '40100cf1-42b8-5a97-b073-4924752e99fa', 'speaking', 'Це мій найкращий друг.', 'Ovo je moj najbolji prijatelj.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('406b74bf-3f3b-5fa4-a3a1-80ec0b7d756b', v_lesson, 'На дитячому майданчику', 'Na igralištu', 2351, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('6a575bbc-2f7e-5e07-9ada-7e112b01a594', '406b74bf-3f3b-5fa4-a3a1-80ec0b7d756b', 'Darja', 'Bok! Je li ovo tvoja kći?', 'Привіт! Це твоя донька?', 1);
  perform pg_temp.turn('320322f6-b332-52f3-9dd6-09a6069e2188', '406b74bf-3f3b-5fa4-a3a1-80ec0b7d756b', 'Ana', 'Jest, zove se Lea. A koji je tvoj?', 'Так, її звати Леа. А котрий твій?', 2);
  perform pg_temp.turn('3646d4d6-8085-5dc9-9eaf-d17746770aa9', '406b74bf-3f3b-5fa4-a3a1-80ec0b7d756b', 'Darja', 'Onaj dječak u plavoj majici. Ide li Lea u vrtić?', 'Он той хлопчик у синій футболці. Леа ходить у садочок?', 3);
  perform pg_temp.turn('60757c47-6f42-5a90-9286-f99b73c54740', '406b74bf-3f3b-5fa4-a3a1-80ec0b7d756b', 'Ana', 'Ide, u vrtić pored škole. Odgojiteljice su jako drage.', 'Так, у садочок біля школи. Виховательки дуже милі.', 4);
  perform pg_temp.turn('579ac353-82b0-589d-9638-e5b3d1ad9f69', '406b74bf-3f3b-5fa4-a3a1-80ec0b7d756b', 'Darja', 'I mi ga moramo upisati. Djeca se lijepo igraju zajedno!', 'Нам теж треба його записати. Діти гарно граються разом!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5662ff2f-fa0f-558f-b80f-61f66a626b76', v_lesson, 'Запрошення на день народження', 'Poziv na rođendan', 2352, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('ac6a0b40-2395-51cc-a50c-dbbdd5f27765', '5662ff2f-fa0f-558f-b80f-61f66a626b76', 'Mia', 'Mama, Lucija me pozvala na rođendansku zabavu!', 'Мамо, Луція запросила мене на день народження!', 1);
  perform pg_temp.turn('f5b051b0-03aa-54e0-bc61-559152d9fb2c', '5662ff2f-fa0f-558f-b80f-61f66a626b76', 'Daša', 'Lijepo! Je li ona tvoja najbolja prijateljica?', 'Чудово! Вона твоя найкраща подруга?', 2);
  perform pg_temp.turn('bc1d5221-e94c-59e9-ae55-2c0c26be7e39', '5662ff2f-fa0f-558f-b80f-61f66a626b76', 'Mia', 'Jest! Sjedimo zajedno u razredu.', 'Так! Ми сидимо разом у класі.', 3);
  perform pg_temp.turn('d40a9031-3787-51f8-aae7-e4f6bdd26f81', '5662ff2f-fa0f-558f-b80f-61f66a626b76', 'Daša', 'Kada je zabava?', 'Коли свято?', 4);
  perform pg_temp.turn('6779d385-676d-5007-80f1-701a16087c6a', '5662ff2f-fa0f-558f-b80f-61f66a626b76', 'Mia', 'U subotu u četiri. Smijem li ići?', 'У суботу о четвертій. Можна мені піти?', 5);
  perform pg_temp.turn('1013cabb-fbd1-5e23-ba3d-43c58b487954', '5662ff2f-fa0f-558f-b80f-61f66a626b76', 'Daša', 'Naravno! Kupit ćemo joj lijepu igračku.', 'Звісно! Купимо їй гарну іграшку.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- 3. Новий порядок уроків у модулі A0.5: наявні уроки тимчасово переносяться на місця 100+
--    (unique (unit_id, order_index)), щоб звільнити місця для нових; у кроці 5 — на остаточні місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 5 and u.order_index = 1;
  update public.lessons l set order_index = t.o + 100
    from (values
    ('4e003796-1ce0-5a02-8a2d-59a0de38f3dd'::uuid, 1),
    ('f9ca38e4-3a61-56a6-b5f5-060933516c9a'::uuid, 3),
    ('cec08ff0-a97d-5847-88cc-dee22fed2f8c'::uuid, 4),
    ('2b0e9742-99e1-57e1-a574-67ffb78d2607'::uuid, 5)
    ) as t(id, o)
   where l.id = t.id and l.unit_id = v_unit and l.order_index <> t.o and l.order_index < 100;
end $$;

-- 4. Нові тематичні уроки модуля A0.5
-- A0.5 · урок 32: Чиє це? — новий урок: 21 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '18efed0f-53a5-5717-9c4e-319627da2360';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A0.5: місце 2 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Присвійні займенники' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Присвійні займенники»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 32: Чиє це?', 'Lekcija 32: Čije je ovo?', '["Сказати, чиє це: moj, tvoj, njegov, njezin, naš, vaš, njihov", "Запитати «Čiji je…? Čija je…? Čije je…?»", "Узгоджувати займенник із річчю: moj ključ, moja torba, moje dijete"]'::jsonb, 15, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'moj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tvoj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'njegov', v_pos);
  v_pos := pg_temp.word(v_lesson, 'njezin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vaš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'njihov', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svoj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čije je ovo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stvar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vlasnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vlasnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pripadati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posuditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uzeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tuđ', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zajednički', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osobni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kod mene', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kod nas', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b1a7a003-1fe5-53ad-94bc-7b8b8550648b', 'fill_in_the_blank', 'Ovo je ___ sestra.', 'moja', '["moje", "moji", "moja", "moj"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd35f3d59-d800-5ab6-9afa-af152e37e1fb', 'multiple_choice', 'Що означає «njegov»?', 'його', '["його", "свій", "позичити", "у мене (вдома)"]'::jsonb, 'A0', 2, 'PUBLISHED', 'njegov', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '367b46c6-3136-55a2-a6ef-97aa4bdc6a0b', 'multiple_choice', 'Що означає «tuđ»?', 'чужий', '["свій", "мій", "власник", "чужий"]'::jsonb, 'A0', 3, 'PUBLISHED', 'tuđ', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8312e03a-6608-5168-81d0-3034cf20c34c', 'multiple_choice', 'Що означає «vaš»?', 'ваш', '["власниця", "позичити", "ваш", "річ; предмет; справа"]'::jsonb, 'A0', 4, 'PUBLISHED', 'vaš', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b108279f-e483-5a2e-901e-bdf4f1131a1f', 'multiple_choice', 'Як хорватською «спільний»?', 'zajednički', '["dati", "njezin", "njegov", "zajednički"]'::jsonb, 'A0', 5, 'PUBLISHED', 'zajednički', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '23eb67a2-d2b9-5ee2-8622-ece848e94539', 'multiple_choice', 'Як хорватською «чиє це?»?', 'čije je ovo', '["posuditi", "čije je ovo", "njihov", "zajednički"]'::jsonb, 'A0', 6, 'PUBLISHED', 'čije je ovo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '24d7a562-c10f-5fa0-a6ac-a64205bddd3d', 'type_answer', 'Напишіть хорватською: «їхній»', 'njihov', null, 'A0', 7, 'PUBLISHED', 'njihov', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dc93aaa0-bc79-5091-850e-994e5eac3e64', 'type_answer', 'Напишіть хорватською: «позичити»', 'posuditi', null, 'A0', 8, 'PUBLISHED', 'posuditi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4ff0b3a4-2eca-5e9e-9420-d7b9dc785cfc', 'type_answer', 'Напишіть хорватською: «власник»', 'vlasnik', null, 'A0', 9, 'PUBLISHED', 'vlasnik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '79959b8e-c2fe-5ddc-a330-42ce82f5d5f9', 'sentence_builder', 'Складіть: «Чия це сумка?»', 'Čija je ovo torba?', '["torba?", "Čija", "je", "ovo"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '853e5b98-f1ac-591a-8bfe-8c25efbf5899', 'sentence_builder', 'Складіть: «Це наша квартира.»', 'Ovo je naš stan.', '["je", "naš", "stan.", "Ovo"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dafe5d4c-fe8f-52c6-b4ca-c3ece61bdfd2', 'listening', 'Прослухайте і складіть фразу', 'Uvijek zaboravlja svoje stvari!', '["Uvijek", "stvari!", "svoje", "zaboravlja"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f40f27be-06c9-545c-88ad-fdd41e5a6155', 'listening', 'Прослухайте і складіть фразу', 'Njezin stan je na našem katu.', '["stan", "našem", "katu.", "je", "na", "Njezin"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'af9f999e-0b75-5881-876f-af37207568ab', 'speaking', 'Це мій ключ.', 'To je moj ključ.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '956e7d39-0365-53ee-8a97-e02d64869548', 'speaking', 'Чия це куртка?', 'Čija je ovo jakna?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d7a6d5c6-0245-5ed0-87d0-50008817fa87', v_lesson, 'Після вечірки', 'Poslije zabave', 2321, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('95a41471-b9d6-59b1-b5b8-8236c94e5064', 'd7a6d5c6-0245-5ed0-87d0-50008817fa87', 'Daša', 'Luka, čija je ovo jakna? Je li tvoja?', 'Луко, чия це куртка? Твоя?', 1);
  perform pg_temp.turn('b221d792-9e2e-549f-9f71-76a162adc8a8', 'd7a6d5c6-0245-5ed0-87d0-50008817fa87', 'Luka', 'Nije. Ja imam crnu jaknu.', 'Ні. У мене чорна куртка.', 2);
  perform pg_temp.turn('14433079-3dc4-583a-bd1a-9ec06e392c52', 'd7a6d5c6-0245-5ed0-87d0-50008817fa87', 'Daša', 'A ovaj kišobran?', 'А ця парасолька?', 3);
  perform pg_temp.turn('d0d65eb9-1679-5cae-bdbb-7bbcc975157a', 'd7a6d5c6-0245-5ed0-87d0-50008817fa87', 'Luka', 'To je Markov. Uvijek zaboravlja svoje stvari!', 'Це Маркова. Він завжди забуває свої речі!', 4);
  perform pg_temp.turn('7af60d74-a083-5edc-ae47-9676fffe5b30', 'd7a6d5c6-0245-5ed0-87d0-50008817fa87', 'Daša', 'Onda ću mu poslati poruku.', 'Тоді надішлю йому повідомлення.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('052d4195-a185-525d-901b-cbad1054c176', v_lesson, 'Чий це ключ?', 'Čiji je ovo ključ?', 2322, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('54375012-cc7d-5dd3-8d60-63d0b2a5b8fc', '052d4195-a185-525d-901b-cbad1054c176', 'Susjed', 'Dobar dan! Je li ovo Vaš ključ? Bio je pored lifta.', 'Добрий день! Це ваш ключ? Він лежав біля ліфта.', 1);
  perform pg_temp.turn('b7a62743-c7db-5c4b-9fea-9c075a1176c3', '052d4195-a185-525d-901b-cbad1054c176', 'Daša', 'Nije moj, moj je u torbi.', 'Не мій, мій у сумці.', 2);
  perform pg_temp.turn('481ff642-b1c7-5c29-8ad6-1c5d09c7b6d4', '052d4195-a185-525d-901b-cbad1054c176', 'Susjed', 'Možda pripada gospođi Kovač?', 'Можливо, він належить пані Ковач?', 3);
  perform pg_temp.turn('281adac8-11bd-5270-9284-0dd1bf954de1', '052d4195-a185-525d-901b-cbad1054c176', 'Daša', 'Možda. Njezin stan je na našem katu.', 'Можливо. Її квартира на нашому поверсі.', 4);
  perform pg_temp.turn('a6089708-8c74-5332-b7f7-cf6a88354b65', '052d4195-a185-525d-901b-cbad1054c176', 'Susjed', 'Dobro, odnijet ću joj ga.', 'Добре, віднесу його їй.', 5);
  perform pg_temp.turn('2937d888-8103-5950-8cc1-f728bbf1e3f0', '052d4195-a185-525d-901b-cbad1054c176', 'Daša', 'Hvala, jako ste ljubazni!', 'Дякую, ви дуже люб’язні!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.5 · урок 36: Зовнішність і характер — новий урок: 24 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '60130364-d731-5f5a-8b12-ac4d8d6d92e9';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A0.5: місце 6 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Прикметники: узгодження з іменником' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Прикметники: узгодження з іменником»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 36: Зовнішність і характер', 'Lekcija 36: Izgled i karakter', '["Описати зовнішність: visok, nizak, mršav, kratka kosa, plave oči", "Описати характер: strpljiv, pametan, smiješan, lijen", "Запитати «Kako izgleda…?» і «Kakav je…?»"]'::jsonb, 15, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'izgledati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'visok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nizak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'debeo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mršav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zgodan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lijep', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kosa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smeđ', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kovrčav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brkovi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sličiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pametan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'simpatičan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'strpljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrijedan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lijen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smiješan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ozbiljan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sramežljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'drag', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f4e9383c-71b6-547d-bfd4-23dd776f7012', 'fill_in_the_blank', 'Moja sestra je ___ i ima dugu kosu.', 'visoka', '["visok", "visoki", "visoka", "visoko"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8e8cd5a2-3033-5b79-ae77-2fa0193cfb6d', 'multiple_choice', 'Що означає «simpatičan»?', 'симпатичний / приємний', '["вуса", "товстий", "кучерявий", "симпатичний / приємний"]'::jsonb, 'A0', 2, 'PUBLISHED', 'simpatičan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '966f9298-7df8-50ed-a30f-06c7b993f88d', 'multiple_choice', 'Що означає «kosa»?', 'волосся', '["борода; підборіддя", "коричневий", "волосся", "розумний"]'::jsonb, 'A0', 3, 'PUBLISHED', 'kosa', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dcda2cc6-c805-52fb-9d3c-4664fcf21470', 'multiple_choice', 'Що означає «oko»?', 'око', '["коричневий", "кучерявий", "низький", "око"]'::jsonb, 'A0', 4, 'PUBLISHED', 'oko', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'faa264e7-6230-5fac-94f0-17eeacc8441e', 'multiple_choice', 'Як хорватською «цінний, працьовитий»?', 'vrijedan', '["sličiti", "debeo", "vrijedan", "visok"]'::jsonb, 'A0', 5, 'PUBLISHED', 'vrijedan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '20fd8e58-3174-54da-9d88-fc784908433e', 'multiple_choice', 'Як хорватською «терплячий»?', 'strpljiv', '["lijen", "lijep", "sličiti", "strpljiv"]'::jsonb, 'A0', 6, 'PUBLISHED', 'strpljiv', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f33d759a-32d4-50a1-8ff2-2707a43cec0c', 'type_answer', 'Напишіть хорватською: «красивий»', 'lijep', null, 'A0', 7, 'PUBLISHED', 'lijep', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '929231a2-1b59-51a1-9683-90d3f94b8d86', 'type_answer', 'Напишіть хорватською: «високий»', 'visok', null, 'A0', 8, 'PUBLISHED', 'visok', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd901f848-8f71-5da3-a60e-bf228f64d943', 'type_answer', 'Напишіть хорватською: «кумедний, смішний»', 'smiješan', null, 'A0', 9, 'PUBLISHED', 'smiješan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '41dc944e-2208-5b80-a715-0f295fcbdb2a', 'sentence_builder', 'Складіть: «Він високий і худий.»', 'On je visok i mršav.', '["visok", "mršav.", "i", "On", "je"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'af0c360a-e8bd-54fc-a9ec-4e3904cfdb71', 'sentence_builder', 'Складіть: «Як виглядає твій брат?»', 'Kako izgleda tvoj brat?', '["tvoj", "brat?", "izgleda", "Kako"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5562ddd3-128e-53ca-af12-22ff4c27e197', 'listening', 'Прослухайте і складіть фразу', 'Ima li bradu?', '["li", "bradu?", "Ima"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dd38f693-0dec-58e4-bba3-9b6192a2d8e6', 'listening', 'Прослухайте і складіть фразу', 'Jako je strpljiva i pametna.', '["pametna.", "strpljiva", "Jako", "i", "je"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8289911-e85c-529a-b8b2-a49f0f3ef997', 'speaking', 'У неї блакитні очі.', 'Ona ima plave oči.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0842b510-b700-53da-9137-de316b374083', 'speaking', 'Ти дуже схожа на маму.', 'Jako sličiš mami.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a8f74a0d-f933-5131-bcae-2e82929b2378', v_lesson, 'Як він виглядає?', 'Kako izgleda?', 2361, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('2bdbfc3f-cdea-56c9-83a8-6233333d1143', 'a8f74a0d-f933-5131-bcae-2e82929b2378', 'Daša', 'Kako izgleda tvoj brat? Trebam ga dočekati na kolodvoru.', 'Як виглядає твій брат? Мені треба зустріти його на вокзалі.', 1);
  perform pg_temp.turn('36381af5-e22a-5fc0-a20d-014dcc7d2f7d', 'a8f74a0d-f933-5131-bcae-2e82929b2378', 'Ivana', 'Visok je i mršav, ima kratku smeđu kosu.', 'Він високий і худий, у нього коротке каштанове волосся.', 2);
  perform pg_temp.turn('250b6b07-9059-55c8-b870-317938f34cfc', 'a8f74a0d-f933-5131-bcae-2e82929b2378', 'Daša', 'Ima li bradu?', 'У нього є борода?', 3);
  perform pg_temp.turn('501ec0c8-9c7f-5eb8-9165-ff25a5350a7a', 'a8f74a0d-f933-5131-bcae-2e82929b2378', 'Ivana', 'Ima malu bradu i nosi naočale.', 'Має невелику бороду й носить окуляри.', 4);
  perform pg_temp.turn('88bf092a-e564-51b4-adc3-243e1f1ddf1e', 'a8f74a0d-f933-5131-bcae-2e82929b2378', 'Daša', 'Dobro, sigurno ću ga prepoznati.', 'Добре, я точно його впізнаю.', 5);
  perform pg_temp.turn('bf0dfef4-c292-5d3b-b6de-ef3085650227', 'a8f74a0d-f933-5131-bcae-2e82929b2378', 'Ivana', 'Hvala ti! On je jako drag, svidjet će ti se.', 'Дякую! Він дуже милий, він тобі сподобається.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e2bf1d14-b504-5135-9a5b-c270509a8e79', v_lesson, 'Яка вона?', 'Kakva je ona?', 2362, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('3563cee8-33da-5d1c-9222-b70d184adc0c', 'e2bf1d14-b504-5135-9a5b-c270509a8e79', 'Marko', 'Dašo, kakva je tvoja nova profesorica hrvatskog?', 'Дашо, яка твоя нова викладачка хорватської?', 1);
  perform pg_temp.turn('be56c6cb-212f-5026-abca-583ea9adc525', 'e2bf1d14-b504-5135-9a5b-c270509a8e79', 'Daša', 'Jako je strpljiva i pametna.', 'Вона дуже терпляча й розумна.', 2);
  perform pg_temp.turn('e3c5d354-c147-5118-84dd-c26c6ab4db46', 'e2bf1d14-b504-5135-9a5b-c270509a8e79', 'Marko', 'Je li stroga?', 'Вона сувора?', 3);
  perform pg_temp.turn('8fb5dd65-8a55-52a7-9643-dd234374de96', 'e2bf1d14-b504-5135-9a5b-c270509a8e79', 'Daša', 'Malo je ozbiljna, ali i smiješna. Svi je vole.', 'Трохи серйозна, але й кумедна. Усі її люблять.', 4);
  perform pg_temp.turn('6bf59a95-0ac4-5c38-92f2-3e54370e1eb1', 'e2bf1d14-b504-5135-9a5b-c270509a8e79', 'Marko', 'A ti? Jesi li vrijedna studentica?', 'А ти? Ти старанна студентка?', 5);
  perform pg_temp.turn('8ef060ec-b5b0-5f16-b1ad-7ace6692a778', 'e2bf1d14-b504-5135-9a5b-c270509a8e79', 'Daša', 'Ponekad sam lijena, ali učim svaki dan!', 'Іноді я лінива, але вчуся щодня!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.5 · урок 37: Домашні тварини — новий урок: 23 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '40b9da1d-1686-5b78-8317-0439067d5f8e';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A0.5: місце 7 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Дієслово «imati» (мати)' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Дієслово «imati» (мати)»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 37: Домашні тварини', 'Lekcija 37: Kućni ljubimci', '["Назвати домашніх тварин: pas, mačka, ptica, hrčak", "Розповісти про свого улюбленця: як звати, що він робить", "Пояснити ветеринарові, що сталося з твариною"]'::jsonb, 15, 'PUBLISHED', 7);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kućni ljubimac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pas', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mačka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mače', v_pos);
  v_pos := pg_temp.word(v_lesson, 'štene', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ptica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'papiga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ribica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hrčak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zec', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kornjača', v_pos);
  v_pos := pg_temp.word(v_lesson, 'veterinar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šetati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hraniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maziti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lajati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povodac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dlaka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rep', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šapa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugristi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cijepiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'alergičan', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b5a149dc-302f-567a-8128-a7a568d648ad', 'fill_in_the_blank', 'Imam jednog ___ i dvije mačke.', 'psa', '["psom", "psu", "pas", "psa"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a4bf531f-29d2-53d4-98e3-c5499e7a9a78', 'multiple_choice', 'Що означає «cijepiti»?', 'вакцинувати', '["кошеня", "повідець", "вакцинувати", "кішка"]'::jsonb, 'A0', 2, 'PUBLISHED', 'cijepiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7e2d7e11-0039-57a2-89d8-520d6c06fd27', 'multiple_choice', 'Що означає «kornjača»?', 'черепаха', '["папуга", "домашній улюбленець", "вкусити", "черепаха"]'::jsonb, 'A0', 3, 'PUBLISHED', 'kornjača', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6651f066-8701-5dac-979d-b95258d73066', 'multiple_choice', 'Що означає «papiga»?', 'папуга', '["хвіст", "папуга", "вкусити", "черепаха"]'::jsonb, 'A0', 4, 'PUBLISHED', 'papiga', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eb6541e2-2579-5a29-9ced-4eb0a31d43c9', 'multiple_choice', 'Як хорватською «лапа»?', 'šapa', '["šapa", "maziti", "papiga", "dlaka"]'::jsonb, 'A0', 5, 'PUBLISHED', 'šapa', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3cd88848-8213-5707-a518-4715499eac07', 'multiple_choice', 'Як хорватською «хвіст»?', 'rep', '["rep", "lajati", "šetati", "alergičan"]'::jsonb, 'A0', 6, 'PUBLISHED', 'rep', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '64fd0edd-0016-5470-9d65-e927c89b3619', 'type_answer', 'Напишіть хорватською: «повідець»', 'povodac', null, 'A0', 7, 'PUBLISHED', 'povodac', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0b0f20f0-7b6c-558d-93bd-b8d55ec1ecf9', 'type_answer', 'Напишіть хорватською: «рибка»', 'ribica', null, 'A0', 8, 'PUBLISHED', 'ribica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '60065eb4-284d-52fe-89a0-8a4a2f74fb8f', 'type_answer', 'Напишіть хорватською: «шерсть»', 'dlaka', null, 'A0', 9, 'PUBLISHED', 'dlaka', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eda5ddca-9d5e-55ad-8fab-029cce45c6a6', 'sentence_builder', 'Складіть: «Моя кішка спить цілий день.»', 'Moja mačka spava cijeli dan.', '["cijeli", "dan.", "Moja", "spava", "mačka"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7c1fc474-aa92-55b3-8a68-edb8826526fa', 'sentence_builder', 'Складіть: «Я щодня вигулюю собаку.»', 'Svaki dan šetam psa.', '["psa.", "šetam", "dan", "Svaki"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf5cb93b-5491-5ae6-9163-b719cfa5a68e', 'listening', 'Прослухайте і складіть фразу', 'Svako jutro ga šetam u parku.', '["u", "jutro", "ga", "Svako", "šetam", "parku."]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fcca6bae-5d7c-5a25-82ad-f868a53dc5f4', 'listening', 'Прослухайте і складіть фразу', 'Je li cijepljen?', '["li", "cijepljen?", "Je"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c87f990c-613a-538f-bc3c-848c926aee44', 'speaking', 'У вас є домашні тварини?', 'Imate li kućne ljubimce?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e6d55cfb-0508-504c-a6be-efe4e09667ee', 'speaking', 'У мене алергія на котів.', 'Imam alergiju na mačke.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9bb918ca-4a78-5645-b73c-0b587f2686a8', v_lesson, 'У тебе є тварина?', 'Imaš li ljubimca?', 2371, 'A0', 'vet', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('55d08fd7-98d8-51c6-b5f1-13d16b1c6e11', '9bb918ca-4a78-5645-b73c-0b587f2686a8', 'Luka', 'Dašo, imaš li kućnog ljubimca?', 'Дашо, у тебе є домашній улюбленець?', 1);
  perform pg_temp.turn('5f3f683e-8be2-574a-ab49-dd5310844ab9', '9bb918ca-4a78-5645-b73c-0b587f2686a8', 'Daša', 'Imam mačku, zove se Murka. A ti?', 'У мене є кішка, її звати Мурка. А в тебе?', 2);
  perform pg_temp.turn('7fe36c15-b75b-50af-892b-f5bd7a515d61', '9bb918ca-4a78-5645-b73c-0b587f2686a8', 'Luka', 'Ja imam psa. Svako jutro ga šetam u parku.', 'У мене собака. Щоранку вигулюю його в парку.', 3);
  perform pg_temp.turn('f7ba856b-a21a-5d4f-b9cc-5b5f951b00a8', '9bb918ca-4a78-5645-b73c-0b587f2686a8', 'Daša', 'Je li velik?', 'Він великий?', 4);
  perform pg_temp.turn('caeb13c4-09fe-5dec-901d-7c9f8d8aabfc', '9bb918ca-4a78-5645-b73c-0b587f2686a8', 'Luka', 'Nije, mali je, ali puno laje!', 'Ні, маленький, але багато гавкає!', 5);
  perform pg_temp.turn('2c863bc1-8900-521d-b178-09cbc6a4e28e', '9bb918ca-4a78-5645-b73c-0b587f2686a8', 'Daša', 'Moja Murka samo spava i jede.', 'Моя Мурка тільки спить і їсть.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0e3f3dab-4cd9-5f9c-a4f5-7a1525c83f38', v_lesson, 'У ветеринара', 'Kod veterinara', 2372, 'A0', 'vet', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('c45f7e5d-a5f4-57a2-98b3-4650df26cffa', '0e3f3dab-4cd9-5f9c-a4f5-7a1525c83f38', 'Veterinarka', 'Dobar dan! Što se dogodilo Vašem psu?', 'Добрий день! Що сталося з вашим собакою?', 1);
  perform pg_temp.turn('487a7eb0-3a0c-51fb-977b-e76a2db8ac3a', '0e3f3dab-4cd9-5f9c-a4f5-7a1525c83f38', 'Daša', 'To je pas moje susjede. Od jučer ne jede.', 'Це собака моєї сусідки. З учора нічого не їсть.', 2);
  perform pg_temp.turn('04edbcf2-5b45-539f-ad7b-9dc2f6dc8cb7', '0e3f3dab-4cd9-5f9c-a4f5-7a1525c83f38', 'Veterinarka', 'Je li cijepljen?', 'Він щеплений?', 3);
  perform pg_temp.turn('14fe9022-cb85-5fdb-85cc-53a0c04b4d28', '0e3f3dab-4cd9-5f9c-a4f5-7a1525c83f38', 'Daša', 'Jest, evo njegove knjižice cijepljenja.', 'Так, ось його книжечка щеплень.', 4);
  perform pg_temp.turn('52e2af10-be94-548b-a483-75a54de604b5', '0e3f3dab-4cd9-5f9c-a4f5-7a1525c83f38', 'Veterinarka', 'Dobro. Sada ću ga pregledati.', 'Добре. Зараз я його огляну.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- 5. Наявні уроки модуля A0.5 — на нові місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 5 and u.order_index = 1;
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
   where l.id in ('4e003796-1ce0-5a02-8a2d-59a0de38f3dd', '18efed0f-53a5-5717-9c4e-319627da2360', 'f9ca38e4-3a61-56a6-b5f5-060933516c9a', 'cec08ff0-a97d-5847-88cc-dee22fed2f8c', '2b0e9742-99e1-57e1-a574-67ffb78d2607', '60130364-d731-5f5a-8b12-ac4d8d6d92e9', '40b9da1d-1686-5b78-8317-0439067d5f8e')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or not exists (select 1 from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar')
             and exists (select 1 from public.lesson_grammar lg where lg.lesson_id = l.id)
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_module from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 5;
  select count(*) into v_order from (values ('4e003796-1ce0-5a02-8a2d-59a0de38f3dd'::uuid, 1), ('18efed0f-53a5-5717-9c4e-319627da2360'::uuid, 2), ('f9ca38e4-3a61-56a6-b5f5-060933516c9a'::uuid, 3), ('cec08ff0-a97d-5847-88cc-dee22fed2f8c'::uuid, 4), ('2b0e9742-99e1-57e1-a574-67ffb78d2607'::uuid, 5), ('60130364-d731-5f5a-8b12-ac4d8d6d92e9'::uuid, 6), ('40b9da1d-1686-5b78-8317-0439067d5f8e'::uuid, 7)) as t(id, o) join public.lessons l on l.id = t.id and l.order_index = t.o;
  select count(*) into v_lessons from public.lessons where level_code = 'A0' and status = 'PUBLISHED';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A0' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('4e003796-1ce0-5a02-8a2d-59a0de38f3dd', '18efed0f-53a5-5717-9c4e-319627da2360', 'f9ca38e4-3a61-56a6-b5f5-060933516c9a', 'cec08ff0-a97d-5847-88cc-dee22fed2f8c', '2b0e9742-99e1-57e1-a574-67ffb78d2607', '60130364-d731-5f5a-8b12-ac4d8d6d92e9', '40b9da1d-1686-5b78-8317-0439067d5f8e') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A0.5: % уроків з неправильним складом', v_bad; end if;
  if v_module <> 7 or v_order <> 7 then raise exception 'Модуль A0.5: уроків %, на своїх місцях % (очікувалось 7)', v_module, v_order; end if;
  if v_lessons < 61 then raise exception 'A0: уроків %, очікувалось щонайменше 61', v_lessons; end if;  -- наступні модулі додають уроки
  if v_titles > 0 then raise exception 'A0: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A0.5: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A0.5 — 7 уроків (31–37) за темою; уроків A0 — %', v_lessons;
end $$;

commit;
