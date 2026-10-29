-- =====================================================================
-- Програма A1 v3 · модуль A1.5 «Житло» · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_curriculum_a1_v3.py 5 (не редагуйте вручну).
--
-- Рішення власника 2026-10-21 / 2026-10-26: до 25 слів на урок — скільки потрібно темі, 90–95 % слів — нові для рівня,
-- діалоги під тему, частіше Даша / Дар’я; бета (PUBLISHED).
--   * Уроки 40–49: 9 наявних перебудовано, 1 нових. Слів у них: 143.
--     Кожен: 10–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 58.
--   * Нові правила до тем: «Місцевий відмінок» (+1), «Родовий відмінок: основи» (+1).
--   * Виправлено: blizina — «близькість (u blizini — поруч)»; peć — «піч» (стара версія — у content_versions).
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

-- 1. Нові слова й вирази A1.5 (58; наявні не змінюються)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('agencija za nekretnine', 'agencija za nekretnine', 'hr', 'phrase', 'A1', 'агентство нерухомості', 'collocation', '{"gender": "f"}'::jsonb, '["Stan tražimo preko agencije za nekretnine."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nekretnina', 'nekretnina', 'hr', 'noun', 'A1', 'нерухомість (об’єкт)', 'core', '{"gender": "f"}'::jsonb, '["Cijene nekretnina u Zagrebu rastu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('trosoban stan', 'trosoban stan', 'hr', 'phrase', 'A1', 'трикімнатна квартира', 'collocation', '{"gender": "m"}'::jsonb, '["Za obitelj nam treba trosoban stan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('potkrovlje', 'potkrovlje', 'hr', 'noun', 'A1', 'мансарда', 'core', '{"gender": "n"}'::jsonb, '["Stan je u potkrovlju, ali ima dizalo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('novogradnja', 'novogradnja', 'hr', 'noun', 'A1', 'новобудова', 'core', '{"gender": "f"}'::jsonb, '["Ovaj stan je u novogradnji, zgrada ima samo dvije godine."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('useljiv', 'useljiv', 'hr', 'adjective', 'A1', 'готовий до заселення', 'core', '{"f": "useljiva", "n": "useljivo"}'::jsonb, '["Stan je odmah useljiv."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('blagovaonica', 'blagovaonica', 'hr', 'noun', 'A1', 'їдальня (кімната)', 'core', '{"gender": "f"}'::jsonb, '["Kuhinja je spojena s blagovaonicom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prometan', 'prometan', 'hr', 'adjective', 'A1', 'жвавий, з інтенсивним рухом', 'core', '{"f": "prometna", "n": "prometno"}'::jsonb, '["Živimo u prometnoj ulici, pa je bučno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kiosk', 'kiosk', 'hr', 'noun', 'A1', 'кіоск', 'core', '{"gender": "m"}'::jsonb, '["Novine kupujem na kiosku pored stanice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('groblje', 'groblje', 'hr', 'noun', 'A1', 'кладовище', 'core', '{"gender": "n"}'::jsonb, '["Mirogoj je poznato zagrebačko groblje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sportski centar', 'sportski centar', 'hr', 'phrase', 'A1', 'спортивний центр', 'collocation', '{"gender": "m"}'::jsonb, '["Djeca treniraju u sportskom centru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zelenilo', 'zelenilo', 'hr', 'noun', 'A1', 'зелень, зелені насадження', 'core', '{"gender": "n"}'::jsonb, '["U našem kvartu ima puno zelenila."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jastučnica', 'jastucnica', 'hr', 'noun', 'A1', 'наволочка', 'core', '{"gender": "f"}'::jsonb, '["Promijeni jastučnice i plahte."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ugaona garnitura', 'ugaona garnitura', 'hr', 'phrase', 'A1', 'кутовий диван', 'collocation', '{"gender": "f"}'::jsonb, '["U dnevnom boravku imamo veliku ugaonu garnituru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('blagovaonski stol', 'blagovaonski stol', 'hr', 'phrase', 'A1', 'обідній стіл', 'collocation', '{"gender": "m"}'::jsonb, '["Za blagovaonskim stolom ima mjesta za šestero."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('polica za knjige', 'polica za knjige', 'hr', 'phrase', 'A1', 'книжкова полиця', 'collocation', '{"gender": "f"}'::jsonb, '["Polica za knjige je pored prozora."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('raspakirati', 'raspakirati', 'hr', 'verb', 'A1', 'розпакувати', 'core', '{"aspect": "pfv", "present": {"1s": "raspakiram", "2s": "raspakiraš", "3s": "raspakira"}}'::jsonb, '["Sutra raspakiramo kutije s knjigama."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kartonska kutija', 'kartonska kutija', 'hr', 'phrase', 'A1', 'картонна коробка', 'collocation', '{"gender": "f"}'::jsonb, '["Za selidbu trebamo dvadeset kartonskih kutija."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ljepljiva traka', 'ljepljiva traka', 'hr', 'phrase', 'A1', 'скотч, клейка стрічка', 'collocation', '{"gender": "f"}'::jsonb, '["Zatvori kutiju ljepljivom trakom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prenijeti', 'prenijeti', 'hr', 'verb', 'A1', 'перенести', 'core', '{"aspect": "pfv", "present": {"1s": "prenesem", "2s": "preneseš", "3s": "prenese"}}'::jsonb, '["Možeš li mi pomoći prenijeti ormar?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('selidbena tvrtka', 'selidbena tvrtka', 'hr', 'phrase', 'A1', 'компанія з перевезень (переїздів)', 'collocation', '{"gender": "f"}'::jsonb, '["Selidbena tvrtka dolazi u subotu ujutro."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('račun za vodu', 'racun za vodu', 'hr', 'phrase', 'A1', 'рахунок за воду', 'collocation', '{"gender": "m"}'::jsonb, '["Račun za vodu stiže svaka tri mjeseca."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odvoz smeća', 'odvoz smeca', 'hr', 'phrase', 'A1', 'вивіз сміття', 'collocation', '{"gender": "m"}'::jsonb, '["Odvoz smeća je utorkom i petkom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('očitanje', 'ocitanje', 'hr', 'noun', 'A1', 'показання (лічильника)', 'core', '{"gender": "n"}'::jsonb, '["Očitanje brojila je jednom godišnje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('trajni nalog', 'trajni nalog', 'hr', 'phrase', 'A1', 'автоплатіж, постійне доручення (у банку)', 'collocation', '{"gender": "m"}'::jsonb, '["Račune plaćam trajnim nalogom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rok plaćanja', 'rok placanja', 'hr', 'phrase', 'A1', 'термін оплати', 'collocation', '{"gender": "m"}'::jsonb, '["Rok plaćanja je petnaesti u mjesecu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('opomena', 'opomena', 'hr', 'noun', 'A1', 'нагадування про борг; попередження', 'core', '{"gender": "f"}'::jsonb, '["Ako ne platiš na vrijeme, dobiješ opomenu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pretplata', 'pretplata', 'hr', 'noun', 'A1', 'передплата, абонемент', 'core', '{"gender": "f"}'::jsonb, '["Pretplata za internet je dvadeset eura mjesečno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('začepljen', 'zacepljen', 'hr', 'adjective', 'A1', 'засмічений, забитий', 'core', '{"f": "začepljena", "n": "začepljeno"}'::jsonb, '["Odvod u kadi je začepljen."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odvod', 'odvod', 'hr', 'noun', 'A1', 'злив, стік', 'core', '{"gender": "m"}'::jsonb, '["Voda ne ide u odvod."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pregorjeti', 'pregorjeti', 'hr', 'verb', 'A1', 'перегоріти', 'core', '{"aspect": "pfv", "present": {"1s": "pregorim", "2s": "pregoriš", "3s": "pregori"}}'::jsonb, '["Ako žarulja pregori, zamijeni je novom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kratki spoj', 'kratki spoj', 'hr', 'phrase', 'A1', 'коротке замикання', 'collocation', '{"gender": "m"}'::jsonb, '["Zbog kratkog spoja nema struje u kuhinji."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('domar', 'domar', 'hr', 'noun', 'A1', 'двірник-завгосп (у будинку, школі)', 'core', '{"gender": "m"}'::jsonb, '["Domar popravlja svjetlo na stubištu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zabiti', 'zabiti', 'hr', 'verb', 'A1', 'забити (цвях)', 'core', '{"aspect": "pfv", "present": {"1s": "zabijem", "2s": "zabiješ", "3s": "zabije"}}'::jsonb, '["Zabij čavao malo više."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bušiti', 'busiti', 'hr', 'verb', 'A1', 'свердлити', 'core', '{"aspect": "ipfv", "present": {"1s": "bušim", "2s": "bušiš", "3s": "buši"}}'::jsonb, '["Nedjeljom se ne smije bušiti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kliješta', 'klijesta', 'hr', 'noun', 'A1', 'плоскогубці, кліщі', 'core', '{"gender": "n_pl"}'::jsonb, '["Dodaj mi kliješta iz kutije s alatom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zategnuti', 'zategnuti', 'hr', 'verb', 'A1', 'затягнути, підкрутити', 'core', '{"aspect": "pfv", "present": {"1s": "zategnem", "2s": "zategneš", "3s": "zategne"}}'::jsonb, '["Treba zategnuti vijak na slavini."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ljestve', 'ljestve', 'hr', 'noun', 'A1', 'драбина', 'core', '{"gender": "f_pl"}'::jsonb, '["Za stropnu lampu trebam ljestve."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kist', 'kist', 'hr', 'noun', 'A1', 'пензель', 'core', '{"gender": "m"}'::jsonb, '["Kutove ličim malim kistom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('valjak', 'valjak', 'hr', 'noun', 'A1', 'валик (для фарби)', 'core', '{"gender": "m"}'::jsonb, '["Zid je brže ličiti valjkom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ljepilo', 'ljepilo', 'hr', 'noun', 'A1', 'клей', 'core', '{"gender": "n"}'::jsonb, '["Pločicu možeš zalijepiti ljepilom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('centralno grijanje', 'centralno grijanje', 'hr', 'phrase', 'A1', 'центральне опалення', 'collocation', '{"gender": "n"}'::jsonb, '["Zgrada ima centralno grijanje od listopada."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('grijalica', 'grijalica', 'hr', 'noun', 'A1', 'обігрівач', 'core', '{"gender": "f"}'::jsonb, '["U kupaonici imamo malu grijalicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ventilator', 'ventilator', 'hr', 'noun', 'A1', 'вентилятор', 'core', '{"gender": "m"}'::jsonb, '["Ljeti spavam s ventilatorom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('propuh', 'propuh', 'hr', 'noun', 'A1', 'протяг', 'core', '{"gender": "m"}'::jsonb, '["Zatvori prozor, imamo propuh!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odvlaživač', 'odvlazivac', 'hr', 'noun', 'A1', 'осушувач повітря', 'core', '{"gender": "m"}'::jsonb, '["Zbog vlage smo kupili odvlaživač."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vrućina', 'vrucina', 'hr', 'noun', 'A1', 'спека', 'core', '{"gender": "f"}'::jsonb, '["Ljeti je u Splitu velika vrućina."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('izolacija', 'izolacija', 'hr', 'noun', 'A1', 'утеплення, ізоляція', 'core', '{"gender": "f"}'::jsonb, '["Stara zgrada nema dobru izolaciju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('susjedstvo', 'susjedstvo', 'hr', 'noun', 'A1', 'сусідство; сусіди', 'core', '{"gender": "n"}'::jsonb, '["U našem susjedstvu živi puno mladih obitelji."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stubište', 'stubiste', 'hr', 'noun', 'A1', 'сходова клітка', 'core', '{"gender": "n"}'::jsonb, '["Na stubištu ne radi svjetlo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pokucati', 'pokucati', 'hr', 'verb', 'A1', 'постукати', 'core', '{"aspect": "pfv", "present": {"1s": "pokucam", "2s": "pokucaš", "3s": "pokuca"}}'::jsonb, '["Pokucaj prije nego uđeš."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('smetati', 'smetati', 'hr', 'verb', 'A1', 'заважати', 'core', '{"aspect": "ipfv", "present": {"1s": "smetam", "2s": "smetaš", "3s": "smeta"}}'::jsonb, '["Smeta li vam glazba?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uznemiravati', 'uznemiravati', 'hr', 'verb', 'A1', 'турбувати, непокоїти', 'core', '{"aspect": "ipfv", "present": {"1s": "uznemiravam", "2s": "uznemiravaš", "3s": "uznemirava"}}'::jsonb, '["Oprostite što vas uznemiravam."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dobrodošlica', 'dobrodoslica', 'hr', 'noun', 'A1', 'привітання з приїздом, гостинний прийом', 'core', '{"gender": "f"}'::jsonb, '["Susjedi nam donose kolač za dobrodošlicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zalijevati', 'zalijevati', 'hr', 'verb', 'A1', 'поливати', 'core', '{"aspect": "ipfv", "present": {"1s": "zalijevam", "2s": "zalijevaš", "3s": "zalijeva"}}'::jsonb, '["Dok smo na moru, susjeda zalijeva cvijeće."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stambena zgrada', 'stambena zgrada', 'hr', 'phrase', 'A1', 'житловий будинок', 'collocation', '{"gender": "f"}'::jsonb, '["Živimo u stambenoj zgradi s deset katova."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zajednički prostori', 'zajednicki prostori', 'hr', 'phrase', 'A1', 'місця загального користування', 'collocation', '{"gender": "m_pl"}'::jsonb, '["Zajedničke prostore čistimo svaki tjedan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('noćni mir', 'nocni mir', 'hr', 'phrase', 'A1', 'нічна тиша', 'collocation', '{"gender": "m"}'::jsonb, '["Noćni mir je od dvadeset dva do šest sati."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;

-- 1б. Виправлені слова (2); повторний запуск нічого не змінює
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'blizina' and ukrainian_translation = 'близькість; околиці' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'близькість (u blizini — поруч)' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'peć' and ukrainian_translation = 'піч; обігрівач' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'піч' where id = r.id;
  end loop;
end $$;

-- 1а. Граматика A1.5: нові теми (0) і нові правила до наявних тем (2)
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Місцевий відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Місцевий відмінок»'; end if;
  if exists (select 1 from public.grammar_rules where id = 'b718f1ab-da0b-583a-b5e2-65cfaf32ffed') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('b718f1ab-da0b-583a-b5e2-65cfaf32ffed', v_topic, 'Прикметник у місцевому: u novom stanu, na prvom katu', 'Прикметник у місцевому змінюється разом з іменником. Чоловічий і середній рід: -om (-em після м’якого): u novom stanu, na prvom katu, u malom selu, u velikom dvorištu. Жіночий рід: -oj: u novoj zgradi, u maloj sobi, na trećoj stanici. Множина: -im: u novim zgradama.', 'nov stan → u novom stanu · nova zgrada → u novoj zgradi', '[{"hr": "Živimo u novom stanu.", "ua": "Ми живемо в новій квартирі."}, {"hr": "Stan je na prvom katu.", "ua": "Квартира на першому поверсі."}, {"hr": "Radim u maloj firmi.", "ua": "Я працюю в невеликій фірмі."}, {"hr": "Ključevi su u gornjoj ladici.", "ua": "Ключі у верхній шухляді."}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', 'b718f1ab-da0b-583a-b5e2-65cfaf32ffed', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Родовий відмінок: основи' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Родовий відмінок: основи»'; end if;
  if exists (select 1 from public.grammar_rules where id = '1e487be8-d45a-574a-bfe3-7fd95c80f63b') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('1e487be8-d45a-574a-bfe3-7fd95c80f63b', v_topic, 'Blizu, pokraj, preko puta, nasuprot, oko + родовий', 'Після прийменників місця — родовий: blizu škole, pokraj parka, preko puta pošte, nasuprot crkve, oko zgrade, iza kuće. Прикметник у родовому: чоловічий і середній — -og (-eg): blizu velikog parka; жіночий — -e: preko puta nove škole.', 'blizu + škola → blizu škole · preko puta + veliki park → preko puta velikog parka', '[{"hr": "Živimo blizu škole.", "ua": "Ми живемо біля школи."}, {"hr": "Kiosk je preko puta pošte.", "ua": "Кіоск навпроти пошти."}, {"hr": "Parkiram pokraj velikog dućana.", "ua": "Я паркуюся біля великого магазину."}, {"hr": "Oko zgrade je puno zelenila.", "ua": "Навколо будинку багато зелені."}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', '1e487be8-d45a-574a-bfe3-7fd95c80f63b', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;

-- 2. Перебудова наявних уроків модуля A1.5
-- A1.5 · урок 40: Шукаю квартиру: оголошення — перебудова: 12 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '278947e3-ae50-5818-abd7-7f07b8ab5c44';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Шукаю квартиру: оголошення» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '6cf09c8e-56e8-5cd2-9f53-999dd52ce9b3') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 40: Шукаю квартиру: оголошення', title_hr = 'Lekcija 40: Tražim stan: oglas',
         objectives = '["Зрозуміти оголошення про квартиру: trosoban, potkrovlje, useljiv", "Запитати агента про поверх, ліфт, заставу", "Місцевий із прикметником: u novom stanu, na prvom katu"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Місцевий відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Місцевий відмінок»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'agencija za nekretnine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nekretnina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trosoban stan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potkrovlje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'novogradnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'useljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blagovaonica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dvorište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dizalo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polog', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'balkon', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '1062b607-58ef-587a-ae3e-574897108b45', 'fill_in_the_blank', 'Stan je na prvom ___.', 'katu', '["katu", "kata", "kat", "katom"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae1181f0-8535-5dd3-a1db-1cd0d327736e', 'multiple_choice', 'Що означає «trosoban stan»?', 'трикімнатна квартира', '["балкон", "договір / контракт", "новобудова", "трикімнатна квартира"]'::jsonb, 'A1', 2, 'PUBLISHED', 'trosoban stan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ad5a094d-b9c6-5c0a-aff4-939906114841', 'multiple_choice', 'Що означає «agencija za nekretnine»?', 'агентство нерухомості', '["подвір''я", "агентство нерухомості", "їдальня (кімната)", "мансарда"]'::jsonb, 'A1', 3, 'PUBLISHED', 'agencija za nekretnine', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7b1838b8-92e9-56c8-a0b8-f2054dcece27', 'multiple_choice', 'Що означає «useljiv»?', 'готовий до заселення', '["застава / депозит", "мансарда", "їдальня (кімната)", "готовий до заселення"]'::jsonb, 'A1', 4, 'PUBLISHED', 'useljiv', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9fd7f9ce-bd17-5a18-8d6c-476214199369', 'multiple_choice', 'Як хорватською «балкон»?', 'balkon', '["trosoban stan", "balkon", "agencija za nekretnine", "nekretnina"]'::jsonb, 'A1', 5, 'PUBLISHED', 'balkon', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b681992d-cd28-551d-8d6f-33411283133c', 'multiple_choice', 'Як хорватською «подвір''я»?', 'dvorište', '["dizalo", "polog", "agencija za nekretnine", "dvorište"]'::jsonb, 'A1', 6, 'PUBLISHED', 'dvorište', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '62434241-cbd2-5eef-8ce7-bf3e7c63d05e', 'type_answer', 'Напишіть хорватською: «мансарда»', 'potkrovlje', null, 'A1', 7, 'PUBLISHED', 'potkrovlje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '11fa9457-6f08-5185-b8ec-8b1d44166eb9', 'type_answer', 'Напишіть хорватською: «договір / контракт»', 'ugovor', null, 'A1', 8, 'PUBLISHED', 'ugovor', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '713389a6-6a9c-5149-85d2-feb736a0a90e', 'type_answer', 'Напишіть хорватською: «новобудова»', 'novogradnja', null, 'A1', 9, 'PUBLISHED', 'novogradnja', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '67f38878-b02f-5161-a306-8e2930e6afc8', 'sentence_builder', 'Складіть: «Ми живемо в новій квартирі.»', 'Živimo u novom stanu.', '["u", "novom", "stanu.", "Živimo"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e400b31e-356e-5220-a0fb-63f3965a9565', 'sentence_builder', 'Складіть: «Квартира одразу готова до заселення.»', 'Stan je odmah useljiv.', '["Stan", "odmah", "je", "useljiv."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'edf501ab-55b2-5c62-b84d-a5c2c20e5000', 'listening', 'Прослухайте і складіть фразу', 'Ima li zgrada dizalo?', '["dizalo?", "zgrada", "li", "Ima"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '251fa453-6502-5c91-817c-77672686c784', 'listening', 'Прослухайте і складіть фразу', 'Lijepo. A spavaće sobe?', '["sobe?", "spavaće", "A", "Lijepo."]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3197ac7d-2c01-56ec-8345-e178fa83d03c', 'speaking', 'Я шукаю трикімнатну квартиру.', 'Tražim trosoban stan.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '358db347-07e2-5a7b-b9be-eade683da420', 'speaking', 'Яка застава?', 'Koliki je polog?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6cf09c8e-56e8-5cd2-9f53-999dd52ce9b3', v_lesson, 'Дзвінок в агентство', 'Poziv agenciji', 3401, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('43dfa4b1-17d9-5ad6-84ab-4b8f6146fdcd', '6cf09c8e-56e8-5cd2-9f53-999dd52ce9b3', 'Daša', 'Dobar dan, zovem zbog oglasa za trosoban stan.', 'Добрий день, я телефоную щодо оголошення про трикімнатну квартиру.', 1);
  perform pg_temp.turn('f932389d-a8f9-5d41-9e3f-1b61128cc6ac', '6cf09c8e-56e8-5cd2-9f53-999dd52ce9b3', 'Agent', 'Da, stan je u novogradnji, na četvrtom katu.', 'Так, квартира в новобудові, на четвертому поверсі.', 2);
  perform pg_temp.turn('e3efa76e-147e-5cde-8547-55eb2ad5216d', '6cf09c8e-56e8-5cd2-9f53-999dd52ce9b3', 'Daša', 'Ima li zgrada dizalo?', 'У будинку є ліфт?', 3);
  perform pg_temp.turn('a4134ee8-78de-5693-bb54-5d40e5e18aac', '6cf09c8e-56e8-5cd2-9f53-999dd52ce9b3', 'Agent', 'Ima. Stan je odmah useljiv i ima veliki balkon.', 'Є. Квартира одразу готова до заселення й має великий балкон.', 4);
  perform pg_temp.turn('14e3b8b9-d531-539e-80f0-0cdb95bdc1fe', '6cf09c8e-56e8-5cd2-9f53-999dd52ce9b3', 'Daša', 'Koliki je polog?', 'Яка застава?', 5);
  perform pg_temp.turn('c8099b9e-4fd3-5914-ab50-c89bf011f758', '6cf09c8e-56e8-5cd2-9f53-999dd52ce9b3', 'Agent', 'Dvije najamnine. Ugovor je na godinu dana.', 'Дві місячні оплати. Договір — на рік.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1344654b-470d-5676-b47e-b0001240b17d', v_lesson, 'Огляд квартири', 'Razgledavanje stana', 3402, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('c4585a55-7abd-5297-94f5-dd82c7b5ffc7', '1344654b-470d-5676-b47e-b0001240b17d', 'Agentica', 'Ovo je dnevni boravak, a ovdje je blagovaonica.', 'Це вітальня, а тут їдальня.', 1);
  perform pg_temp.turn('db132f55-6c11-5908-9f90-24e2c0468302', '1344654b-470d-5676-b47e-b0001240b17d', 'Luka', 'Lijepo. A spavaće sobe?', 'Гарно. А спальні?', 2);
  perform pg_temp.turn('ded07ce0-f909-59d2-ab88-f72151c0b1cc', '1344654b-470d-5676-b47e-b0001240b17d', 'Agentica', 'Gore u potkrovlju, dvije sobe i kupaonica.', 'Нагорі в мансарді — дві кімнати й ванна.', 3);
  perform pg_temp.turn('c23ecf14-d912-521a-988b-b52fca407b67', '1344654b-470d-5676-b47e-b0001240b17d', 'Luka', 'Ima li zgrada dvorište za djecu?', 'А в будинку є подвір’я для дітей?', 4);
  perform pg_temp.turn('42afb368-f40a-59bb-9f73-d25204755378', '1344654b-470d-5676-b47e-b0001240b17d', 'Agentica', 'Ima, iza zgrade, s malim igralištem.', 'Є, за будинком, з невеликим майданчиком.', 5);
  perform pg_temp.turn('ea605a66-11f1-5943-86bd-ffa87c5e6470', '1344654b-470d-5676-b47e-b0001240b17d', 'Luka', 'Super. Javimo vam se do petka.', 'Чудово. Ми вам відповімо до п’ятниці.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 42: Меблі для квартири — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'de93d3ab-6769-5daf-9560-8858285a8136';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Меблі для квартири» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '514923a7-f17e-52bd-bf86-ddfff3e51b51') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 42: Меблі для квартири', title_hr = 'Lekcija 42: Namještaj za stan',
         objectives = '["Назвати меблі й речі для дому: komoda, naslonjač, polica za knjige", "Домовитися про доставку й збирання меблів", "Місцевий: u dnevnom boravku, na gornjoj polici"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Місцевий відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Місцевий відмінок»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'posteljina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jastučnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pokrivač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'komoda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stolić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naslonjač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugaona garnitura', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blagovaonski stol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polica za knjige', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zidni sat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sklopiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'montirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vijak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dostaviti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e2b182b3-fe60-5bbc-a9e6-b328d4ad6013', 'fill_in_the_blank', 'Sat je na ___ zidu.', 'velikom', '["veliki", "velikog", "velikom", "velika"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5c6aea95-910e-5cec-b002-e5a6b1cf578c', 'multiple_choice', 'Що означає «zidni sat»?', 'настінний годинник', '["наволочка", "комод", "настінний годинник", "постільна білизна"]'::jsonb, 'A1', 2, 'PUBLISHED', 'zidni sat', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0260c93a-1751-5da5-bb3e-5cf8eede612b', 'multiple_choice', 'Що означає «stolić»?', 'столик', '["столик", "гвинт; шуруп", "ковдра", "комод"]'::jsonb, 'A1', 3, 'PUBLISHED', 'stolić', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f08d3a59-2a00-5945-b088-db6183ee830d', 'multiple_choice', 'Що означає «posteljina»?', 'постільна білизна', '["постільна білизна", "наволочка", "кутовий диван", "доставити"]'::jsonb, 'A1', 4, 'PUBLISHED', 'posteljina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd3c3708c-25b7-5c86-a719-d31a77aa7ee8', 'multiple_choice', 'Як хорватською «ковдра»?', 'pokrivač', '["sklopiti", "montirati", "naslonjač", "pokrivač"]'::jsonb, 'A1', 5, 'PUBLISHED', 'pokrivač', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '57f51bee-751f-5f65-a8cd-accac73e8705', 'multiple_choice', 'Як хорватською «гвинт; шуруп»?', 'vijak', '["dostaviti", "vijak", "polica za knjige", "komoda"]'::jsonb, 'A1', 6, 'PUBLISHED', 'vijak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f0a1d6d-d572-5739-a6c6-050d6b23bae9', 'type_answer', 'Напишіть хорватською: «доставити»', 'dostaviti', null, 'A1', 7, 'PUBLISHED', 'dostaviti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dd991520-f408-5214-a7bd-25751d80aeb9', 'type_answer', 'Напишіть хорватською: «наволочка»', 'jastučnica', null, 'A1', 8, 'PUBLISHED', 'jastučnica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd485d229-820d-5d92-81ea-f96eac9fb816', 'type_answer', 'Напишіть хорватською: «комод»', 'komoda', null, 'A1', 9, 'PUBLISHED', 'komoda', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e5e0ff3e-e978-5005-a545-cdc722e65f0a', 'sentence_builder', 'Складіть: «Ключі в маленькій шухляді.»', 'Ključevi su u maloj ladici.', '["su", "ladici.", "u", "maloj", "Ključevi"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd4112fa1-bf0d-5830-83a2-93ec145424f6', 'sentence_builder', 'Складіть: «Можете доставити диван?»', 'Možete li dostaviti garnituru?', '["li", "garnituru?", "Možete", "dostaviti"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0b11536b-7130-564a-b9c5-2acd58d4b8ee', 'listening', 'Прослухайте і складіть фразу', 'Možemo. Montiranje je besplatno.', '["besplatno.", "Možemo.", "Montiranje", "je"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d662a7e-bb3b-5aef-b310-6a42bfef7e61', 'listening', 'Прослухайте і складіть фразу', 'Gdje ide zidni sat?', '["sat?", "ide", "zidni", "Gdje"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd456cecb-5c64-5042-81d9-efab827d9045', 'speaking', 'Нам потрібен обідній стіл.', 'Treba nam blagovaonski stol.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '390a2d3d-7e3b-56e7-ad6a-8c410ee08306', 'speaking', 'Де інструкція?', 'Gdje su upute?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('514923a7-f17e-52bd-bf86-ddfff3e51b51', v_lesson, 'У меблевому магазині', 'U trgovini namještajem', 3421, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('be41018a-0b19-5735-bc25-1641676db929', '514923a7-f17e-52bd-bf86-ddfff3e51b51', 'Daša', 'Tražimo ugaonu garnituru za dnevni boravak.', 'Ми шукаємо кутовий диван для вітальні.', 1);
  perform pg_temp.turn('6cfcad32-b75b-586d-9885-7006a47493f9', '514923a7-f17e-52bd-bf86-ddfff3e51b51', 'Prodavač', 'Ova je na akciji, a ima i naslonjač u istoj boji.', 'Цей на акції, і до нього є крісло того ж кольору.', 2);
  perform pg_temp.turn('9051ee89-3b0e-5106-a7e5-8a308ebec367', '514923a7-f17e-52bd-bf86-ddfff3e51b51', 'Daša', 'Možete li je dostaviti u subotu?', 'Можете доставити його в суботу?', 3);
  perform pg_temp.turn('181ea672-cbdb-541f-91a4-4e9e0b1f7f59', '514923a7-f17e-52bd-bf86-ddfff3e51b51', 'Prodavač', 'Možemo. Montiranje je besplatno.', 'Можемо. Монтаж безкоштовний.', 4);
  perform pg_temp.turn('d2d03049-d268-5e0c-a6b3-bf78546cb705', '514923a7-f17e-52bd-bf86-ddfff3e51b51', 'Daša', 'Odlično. Treba nam i blagovaonski stol za šest osoba.', 'Чудово. Нам ще потрібен обідній стіл на шістьох.', 5);
  perform pg_temp.turn('c190f142-aabc-51b9-8c48-0c2af0a83e63', '514923a7-f17e-52bd-bf86-ddfff3e51b51', 'Prodavač', 'Stolovi su na drugom katu, pored polica za knjige.', 'Столи на другому поверсі, біля книжкових полиць.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('521e87de-053e-5f5f-baa2-2d0177991275', v_lesson, 'Збираємо комод', 'Sklapamo komodu', 3422, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('be0b328d-253a-54b2-bca1-5ee8ca3091ed', '521e87de-053e-5f5f-baa2-2d0177991275', 'Luka', 'Dašo, gdje su upute za komodu?', 'Дашо, де інструкція до комода?', 1);
  perform pg_temp.turn('38a247e4-df0d-590f-9ee4-d0f8c015af15', '521e87de-053e-5f5f-baa2-2d0177991275', 'Daša', 'U kutiji, na dnu. I vijci su u maloj vrećici.', 'У коробці, на дні. І гвинти в маленькому пакетику.', 2);
  perform pg_temp.turn('4f107cfb-28b2-5280-b182-4d6347bde08f', '521e87de-053e-5f5f-baa2-2d0177991275', 'Luka', 'Sklopim je za sat vremena.', 'Я зберу його за годину.', 3);
  perform pg_temp.turn('67db7703-4851-5b00-9074-f1d780d39a9c', '521e87de-053e-5f5f-baa2-2d0177991275', 'Daša', 'Dobro, a ja stavljam novu posteljinu i jastučnice.', 'Добре, а я застеляю нову білизну й наволочки.', 4);
  perform pg_temp.turn('af9f6a09-ab4f-5d80-99d8-496347ad2470', '521e87de-053e-5f5f-baa2-2d0177991275', 'Luka', 'Gdje ide zidni sat?', 'А куди повісимо настінний годинник?', 5);
  perform pg_temp.turn('e1939649-e4ef-50de-9332-4edb7a79ac49', '521e87de-053e-5f5f-baa2-2d0177991275', 'Daša', 'Iznad stolića u dnevnom boravku.', 'Над столиком у вітальні.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 43: Переїзд — перебудова: 13 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '23f3aad6-4447-5b75-9dd1-891773457f7e';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Переїзд» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'b0285e9d-25ca-50f7-9c32-9ce8ae90fca2') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 43: Переїзд', title_hr = 'Lekcija 43: Selidba',
         objectives = '["Підготуватися до переїзду: kartonske kutije, ljepljiva traka", "Попросити допомогти перенести речі", "Модальні дієслова: Možeš li mi pomoći?"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Модальні дієслова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Модальні дієслова»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'selidba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'seliti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iseliti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'selidbena tvrtka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kombi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijevoz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pakirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'raspakirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kartonska kutija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljepljiva traka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lomljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prenijeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podići', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a337b6d1-7182-5949-93cb-e1c63eb6d81a', 'fill_in_the_blank', 'Moramo se ___ do kraja mjeseca.', 'iseliti', '["iseliti", "iselimo", "iseli", "iselili"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '92be4135-a703-557b-99a6-2464bccf3b28', 'multiple_choice', 'Що означає «iseliti se»?', 'виїхати (з житла)', '["картонна коробка", "переїзд", "виїхати (з житла)", "компанія з перевезень (переїздів)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'iseliti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0ddf776a-0cb0-5649-8d4c-0178d76e0289', 'multiple_choice', 'Що означає «prenijeti»?', 'перенести', '["перенести", "мікроавтобус; бус", "виїхати (з житла)", "розпакувати"]'::jsonb, 'A1', 3, 'PUBLISHED', 'prenijeti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '28d9974d-387e-5486-95e7-0248badb1cc5', 'multiple_choice', 'Що означає «ljepljiva traka»?', 'скотч, клейка стрічка', '["транспорт; перевезення", "крихкий", "підняти; зняти гроші", "скотч, клейка стрічка"]'::jsonb, 'A1', 4, 'PUBLISHED', 'ljepljiva traka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '19051b8a-11bd-5f7f-8ede-4958bc9f4100', 'multiple_choice', 'Як хорватською «мікроавтобус; бус»?', 'kombi', '["podići", "raspakirati", "selidbena tvrtka", "kombi"]'::jsonb, 'A1', 5, 'PUBLISHED', 'kombi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a2384e09-888f-5c3f-ad98-7ac8a30031ee', 'multiple_choice', 'Як хорватською «крихкий»?', 'lomljiv', '["raspakirati", "lomljiv", "selidba", "selidbena tvrtka"]'::jsonb, 'A1', 6, 'PUBLISHED', 'lomljiv', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '796875c6-7c6b-5020-901a-ab166ccb39f3', 'type_answer', 'Напишіть хорватською: «розпакувати»', 'raspakirati', null, 'A1', 7, 'PUBLISHED', 'raspakirati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6f3ecdb1-9728-5a74-b681-00eb6b635cd7', 'type_answer', 'Напишіть хорватською: «переїзд»', 'selidba', null, 'A1', 8, 'PUBLISHED', 'selidba', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6f1e7ae5-d6b6-5115-8a64-5ac9fbaa7b30', 'type_answer', 'Напишіть хорватською: «переїжджати»', 'seliti se', null, 'A1', 9, 'PUBLISHED', 'seliti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '28bee63d-e25b-5be4-96a3-5df6da5316a5', 'sentence_builder', 'Складіть: «Можеш мені допомогти?»', 'Možeš li mi pomoći?', '["li", "Možeš", "mi", "pomoći?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a46017f-d1e2-5cdd-a27a-31aac132450f', 'sentence_builder', 'Складіть: «Нам потрібні картонні коробки.»', 'Trebamo kartonske kutije.', '["Trebamo", "kutije.", "kartonske"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'df46a7ad-ff3e-59d6-9b75-8f1ec6b0f209', 'listening', 'Прослухайте і складіть фразу', 'Imamo li dovoljno kartonskih kutija?', '["kutija?", "Imamo", "li", "dovoljno", "kartonskih"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c68c14d0-8753-5363-8183-c1bbb26a60a0', 'listening', 'Прослухайте і складіть фразу', 'Mogu. Imaš li kombi?', '["Mogu.", "kombi?", "Imaš", "li"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b5adf1a6-a915-5d05-9670-2637d0daf8db', 'speaking', 'Я переїжджаю в суботу.', 'Selim se u subotu.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '964be661-b5eb-5148-8fae-dcbf477092ab', 'speaking', 'Це крихке, обережно!', 'Ovo je lomljivo, pažljivo!', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b0285e9d-25ca-50f7-9c32-9ce8ae90fca2', v_lesson, 'Готуємося до переїзду', 'Pripremamo selidbu', 3431, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('cd2967aa-47a8-5d2c-8328-34d571cfe831', 'b0285e9d-25ca-50f7-9c32-9ce8ae90fca2', 'Luka', 'Kada se moramo iseliti iz starog stana?', 'Коли нам треба виїхати зі старої квартири?', 1);
  perform pg_temp.turn('5bb35abe-eb54-512d-8ae8-0ed9c73f95df', 'b0285e9d-25ca-50f7-9c32-9ce8ae90fca2', 'Daša', 'Do kraja mjeseca. Selidbena tvrtka dolazi u subotu.', 'До кінця місяця. Компанія з перевезень приїде в суботу.', 2);
  perform pg_temp.turn('2aa5f947-24a1-5723-967d-bcc3882fa640', 'b0285e9d-25ca-50f7-9c32-9ce8ae90fca2', 'Luka', 'Imamo li dovoljno kartonskih kutija?', 'У нас вистачає картонних коробок?', 3);
  perform pg_temp.turn('89997cc1-ec7e-5475-9f7b-f0a2abd430bc', 'b0285e9d-25ca-50f7-9c32-9ce8ae90fca2', 'Daša', 'Nemamo, a trebamo i ljepljivu traku.', 'Ні, і ще потрібен скотч.', 4);
  perform pg_temp.turn('0f91f032-ba08-55c0-bef1-fb28dadcc475', 'b0285e9d-25ca-50f7-9c32-9ce8ae90fca2', 'Luka', 'Čaše moramo pakirati posebno, lomljive su.', 'Склянки треба пакувати окремо, вони крихкі.', 5);
  perform pg_temp.turn('76fa50b2-ab1e-55a4-8041-47e15c3557c6', 'b0285e9d-25ca-50f7-9c32-9ce8ae90fca2', 'Daša', 'Da, i na kutiju napiši: «Pažljivo, lomljivo!»', 'Так, і напиши на коробці: «Обережно, крихке!»', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0e54e5a2-4f9e-548f-8ede-5a1467b2e169', v_lesson, 'Допоможеш?', 'Možeš li pomoći?', 3432, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('3d8459f9-caca-594e-a995-df09b030fdaa', '0e54e5a2-4f9e-548f-8ede-5a1467b2e169', 'Darja', 'Marko, možeš li mi pomoći u subotu? Selim se.', 'Марку, можеш мені допомогти в суботу? Я переїжджаю.', 1);
  perform pg_temp.turn('32711e21-ace9-5292-bf24-fae6cfb77a87', '0e54e5a2-4f9e-548f-8ede-5a1467b2e169', 'Marko', 'Mogu. Imaš li kombi?', 'Можу. У тебе є бус?', 2);
  perform pg_temp.turn('906af478-6244-57cd-9570-67b65a314281', '0e54e5a2-4f9e-548f-8ede-5a1467b2e169', 'Darja', 'Imam, ali ne mogu sama prenijeti ormar.', 'Є, але я не можу сама перенести шафу.', 3);
  perform pg_temp.turn('9408aec0-ffa5-539a-bf8d-fc0ba9897656', '0e54e5a2-4f9e-548f-8ede-5a1467b2e169', 'Marko', 'Nema problema, nas dvoje ga možemo podići.', 'Без проблем, удвох ми її піднімемо.', 4);
  perform pg_temp.turn('5e3e155c-5680-5fa6-b02e-b428a14fc728', '0e54e5a2-4f9e-548f-8ede-5a1467b2e169', 'Darja', 'Hvala ti! Poslije moramo sve raspakirati.', 'Дякую! Потім треба все розпакувати.', 5);
  perform pg_temp.turn('a8169fee-aacb-52cd-98bd-996b7e0fe321', '0e54e5a2-4f9e-548f-8ede-5a1467b2e169', 'Marko', 'Može, ali prvo pizza!', 'Добре, але спочатку піца!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 44: Рахунки й комунальні послуги — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'b69a8cca-4918-562f-8ae5-22f8d7ba2f76';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Рахунки й комунальні послуги» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '79e82cc7-d134-50cf-a088-3d5650f009af') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 44: Рахунки й комунальні послуги', title_hr = 'Lekcija 44: Računi i režije',
         objectives = '["Розібратися з рахунками: вода, вивіз сміття, інтернет", "Сказати про термін оплати й автоплатіж", "Родовий: rok plaćanja, do kraja mjeseca, račun za vodu"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Родовий відмінок: основи' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Родовий відмінок: основи»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'račun za vodu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odvoz smeća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brojilo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'očitanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potrošnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trajni nalog', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rok plaćanja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opomena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pretplata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mobilno bankarstvo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'internet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ruter', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tehničar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'korisnik', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e38979b3-5490-5527-8f10-bcd52a57aa9e', 'fill_in_the_blank', 'Račun moram platiti do kraja ___.', 'mjeseca', '["mjesec", "mjesecom", "mjeseca", "mjesecu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9145c5a4-519e-5402-ac21-6d0b450382f0', 'multiple_choice', 'Що означає «odvoz smeća»?', 'вивіз сміття', '["лічильник", "рахунок за воду", "вивіз сміття", "автоплатіж, постійне доручення (у банку)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'odvoz smeća', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '39d0be3b-08ae-524c-95fa-2acfad9d5d9d', 'multiple_choice', 'Що означає «trajni nalog»?', 'автоплатіж, постійне доручення (у банку)', '["нагадування про борг; попередження", "користувач", "автоплатіж, постійне доручення (у банку)", "мобільний банкінг"]'::jsonb, 'A1', 3, 'PUBLISHED', 'trajni nalog', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5586dfab-0c91-58cc-a415-211b87c5ca00', 'multiple_choice', 'Що означає «internet»?', 'інтернет', '["нагадування про борг; попередження", "передплата, абонемент", "інтернет", "вивіз сміття"]'::jsonb, 'A1', 4, 'PUBLISHED', 'internet', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0541430a-cf6c-5ff4-bcbd-cedfd84a63a1', 'multiple_choice', 'Як хорватською «користувач»?', 'korisnik', '["tehničar", "korisnik", "potrošnja", "ruter"]'::jsonb, 'A1', 5, 'PUBLISHED', 'korisnik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5cc0fbe6-7e62-5b58-8711-6bf0b79a2804', 'multiple_choice', 'Як хорватською «технік»?', 'tehničar', '["očitanje", "tehničar", "brojilo", "račun za vodu"]'::jsonb, 'A1', 6, 'PUBLISHED', 'tehničar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9c4b771b-9f5f-5e5f-a9ac-ee8d6973bfc7', 'type_answer', 'Напишіть хорватською: «споживання; витрати»', 'potrošnja', null, 'A1', 7, 'PUBLISHED', 'potrošnja', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b95818b0-b76f-54a4-89fa-0cf165c27994', 'type_answer', 'Напишіть хорватською: «показання (лічильника)»', 'očitanje', null, 'A1', 8, 'PUBLISHED', 'očitanje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c7b18b75-0984-5246-9790-12277c4037af', 'type_answer', 'Напишіть хорватською: «роутер»', 'ruter', null, 'A1', 9, 'PUBLISHED', 'ruter', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '410eeabc-450c-5fca-a364-39cb9ccb5747', 'sentence_builder', 'Складіть: «Коли термін оплати?»', 'Kada je rok plaćanja?', '["Kada", "je", "plaćanja?", "rok"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '450df974-814f-53b2-bf90-c20cf80ebac8', 'sentence_builder', 'Складіть: «Ось рахунок за воду.»', 'Evo računa za vodu.', '["Evo", "za", "vodu.", "računa"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a644104d-0bdc-561a-8bbf-7afa85f0bc0d', 'listening', 'Прослухайте і складіть фразу', 'Kada je rok plaćanja?', '["je", "plaćanja?", "rok", "Kada"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b2fa47c2-94cf-5c54-b4e3-f3153931d1b0', 'listening', 'Прослухайте і складіть фразу', 'To radim svaki dan, ali i dalje nema signala.', '["svaki", "dan,", "To", "dalje", "ali", "nema", "radim", "signala.", "i"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c3c148c2-97e0-5485-92a8-05eeb50e4000', 'speaking', 'Інтернет не працює.', 'Internet ne radi.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eea78385-7dbb-5ec5-b6f1-3870ab590356', 'speaking', 'Я плачу автоплатежем.', 'Plaćam trajnim nalogom.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('79e82cc7-d134-50cf-a088-3d5650f009af', v_lesson, 'Рахунки за місяць', 'Računi za ovaj mjesec', 3441, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('4456cebb-0909-59c2-8319-acc5d0325d23', '79e82cc7-d134-50cf-a088-3d5650f009af', 'Luka', 'Dašo, evo računa za vodu.', 'Дашо, ось рахунок за воду.', 1);
  perform pg_temp.turn('8564e743-70ae-5978-9f6f-f8988a45b0df', '79e82cc7-d134-50cf-a088-3d5650f009af', 'Daša', 'Koliko je? Potrošnja nam je velika ovo ljeto.', 'Скільки? Цього літа в нас велике споживання.', 2);
  perform pg_temp.turn('9b1f4162-9942-5c55-81c8-467286fe2ab7', '79e82cc7-d134-50cf-a088-3d5650f009af', 'Luka', 'Trideset eura. A odvoz smeća je posebno.', 'Тридцять євро. А вивіз сміття — окремо.', 3);
  perform pg_temp.turn('fbb1af6b-8fcf-519e-9017-709b0fcaeb54', '79e82cc7-d134-50cf-a088-3d5650f009af', 'Daša', 'Kada je rok plaćanja?', 'Коли термін оплати?', 4);
  perform pg_temp.turn('8b500167-250c-5892-a09c-b71d92b65c2f', '79e82cc7-d134-50cf-a088-3d5650f009af', 'Luka', 'Do petnaestog. Platim ga odmah mobilnim bankarstvom.', 'До п’ятнадцятого. Зараз заплачу через мобільний банкінг.', 5);
  perform pg_temp.turn('c7db7b3d-44c1-5c81-9b93-b99f4d95d662', '79e82cc7-d134-50cf-a088-3d5650f009af', 'Daša', 'Bolje napravi trajni nalog, pa nema opomena.', 'Краще зроби автоплатіж, тоді не буде нагадувань.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('38404d39-06a7-55bd-a34b-df401191a6d6', v_lesson, 'Інтернет не працює', 'Internet ne radi', 3442, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('bd98309a-a990-5871-aa3b-479e82a1863b', '38404d39-06a7-55bd-a34b-df401191a6d6', 'Darja', 'Dobar dan, ja sam korisnik broj četiri sto dvadeset. Internet ne radi.', 'Добрий день, я абонент номер чотириста двадцять. Інтернет не працює.', 1);
  perform pg_temp.turn('adc58168-fc6d-59d2-86ea-21c4272d767d', '38404d39-06a7-55bd-a34b-df401191a6d6', 'Operater', 'Isključite ruter na minutu pa ga ponovno uključite.', 'Вимкніть роутер на хвилину, а потім знову увімкніть.', 2);
  perform pg_temp.turn('6e09e719-0f03-5567-ad3c-fd9d751461c5', '38404d39-06a7-55bd-a34b-df401191a6d6', 'Darja', 'To radim svaki dan, ali i dalje nema signala.', 'Я роблю це щодня, але сигналу досі немає.', 3);
  perform pg_temp.turn('f14856e1-80cd-58d2-a4f6-8a15c205bc08', '38404d39-06a7-55bd-a34b-df401191a6d6', 'Operater', 'Šaljemo tehničara sutra prije podne.', 'Ми надішлемо техніка завтра до обіду.', 4);
  perform pg_temp.turn('0e47fae7-0287-5a08-8a82-f1404fc2e630', '38404d39-06a7-55bd-a34b-df401191a6d6', 'Darja', 'Moram li platiti dolazak?', 'Мені треба платити за виклик?', 5);
  perform pg_temp.turn('9af441c7-0ea0-57b9-9415-715b441edc5e', '38404d39-06a7-55bd-a34b-df401191a6d6', 'Operater', 'Ne, sve je uključeno u pretplatu.', 'Ні, усе входить в абонплату.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 45: Щось не працює — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '8fc3399d-0405-5517-9358-d3ad6308d860';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Щось не працює» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '3f393547-28bc-5c06-88bd-c5d1b44c1ffe') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 45: Щось не працює', title_hr = 'Lekcija 45: Nešto ne radi',
         objectives = '["Описати поломку: kapa slavina, začepljen odvod, nema struje", "Викликати сантехніка чи електрика", "Місцевий: u kupaonici, u kuhinji, na stubištu"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Місцевий відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Місцевий відмінок»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'tuš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slavina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kapati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'curiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'začepljen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odvod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vodokotlić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'umivaonik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osigurač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pregorjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kratki spoj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vodoinstalater', v_pos);
  v_pos := pg_temp.word(v_lesson, 'električar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'domar', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ffe51b54-089b-5913-8b37-93c14253cf17', 'fill_in_the_blank', 'Slavina u ___ curi.', 'kuhinji', '["kuhinja", "kuhinje", "kuhinji", "kuhinju"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a8f399f-905d-5a9a-8f57-2a8f3a1ec8ba', 'multiple_choice', 'Що означає «domar»?', 'двірник-завгосп (у будинку, школі)', '["двірник-завгосп (у будинку, школі)", "коротке замикання", "запобіжник (електричний)", "сантехнік"]'::jsonb, 'A1', 2, 'PUBLISHED', 'domar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c1d3a97b-8786-568d-b4c2-5990b55189bf', 'multiple_choice', 'Що означає «osigurač»?', 'запобіжник (електричний)', '["злив, стік", "текти; протікати", "запобіжник (електричний)", "засмічений, забитий"]'::jsonb, 'A1', 3, 'PUBLISHED', 'osigurač', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a43f1d5d-8e0d-5cb0-9be8-1041feedc518', 'multiple_choice', 'Що означає «kratki spoj»?', 'коротке замикання', '["капати", "сантехнік", "коротке замикання", "електрик"]'::jsonb, 'A1', 4, 'PUBLISHED', 'kratki spoj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd470327-861b-5b58-8849-b7697781594a', 'multiple_choice', 'Як хорватською «засмічений, забитий»?', 'začepljen', '["domar", "curiti", "vodokotlić", "začepljen"]'::jsonb, 'A1', 5, 'PUBLISHED', 'začepljen', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '14c3624b-9780-57dd-b155-e10d9640b47a', 'multiple_choice', 'Як хорватською «умивальник»?', 'umivaonik', '["domar", "umivaonik", "curiti", "kapati"]'::jsonb, 'A1', 6, 'PUBLISHED', 'umivaonik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ba58ee5f-4fc3-59eb-80ca-5bf32e52cbe8', 'type_answer', 'Напишіть хорватською: «сантехнік»', 'vodoinstalater', null, 'A1', 7, 'PUBLISHED', 'vodoinstalater', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4c5ca5d7-b16b-5a2b-a552-ef1afe247c7d', 'type_answer', 'Напишіть хорватською: «зливний бачок»', 'vodokotlić', null, 'A1', 8, 'PUBLISHED', 'vodokotlić', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '463e115c-5257-5991-ba70-b2e5809744a0', 'type_answer', 'Напишіть хорватською: «електрик»', 'električar', null, 'A1', 9, 'PUBLISHED', 'električar', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eabbe12a-bb3b-5a7d-ae67-0156a5e7cbd3', 'sentence_builder', 'Складіть: «Злив у ванній забився.»', 'Odvod u kupaonici je začepljen.', '["kupaonici", "je", "u", "začepljen.", "Odvod"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8be49324-3f9b-51eb-aa9c-bc90627e3e75', 'sentence_builder', 'Складіть: «Мені потрібен сантехнік.»', 'Trebam vodoinstalatera.', '["vodoinstalatera.", "Trebam"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '44c1eaaf-62d8-5bb0-884f-9d9b2593059b', 'listening', 'Прослухайте і складіть фразу', 'Samo kapa ili jako curi?', '["Samo", "kapa", "curi?", "ili", "jako"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '547442ad-ab27-5198-b820-faf13e72a758', 'listening', 'Прослухайте і складіть фразу', 'Provjeri osigurač u hodniku.', '["Provjeri", "hodniku.", "u", "osigurač"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e90ef33b-e921-5d46-8eb4-e655d6c3141f', 'speaking', 'Кран тече.', 'Slavina curi.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5084e6dc-0102-5bd6-9d12-f64a1738b36b', 'speaking', 'У ванній немає світла.', 'U kupaonici nema struje.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3f393547-28bc-5c06-88bd-c5d1b44c1ffe', v_lesson, 'Протікає кран', 'Slavina curi', 3451, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('368bdb15-22b1-593f-9477-08181dd247fc', '3f393547-28bc-5c06-88bd-c5d1b44c1ffe', 'Daša', 'Dobar dan, zovem iz stana broj pet. Slavina u kuhinji curi.', 'Добрий день, телефоную з квартири номер п’ять. На кухні тече кран.', 1);
  perform pg_temp.turn('1340ce60-2d9e-57c1-b836-f938263a295f', '3f393547-28bc-5c06-88bd-c5d1b44c1ffe', 'Stanodavac', 'Samo kapa ili jako curi?', 'Лише капає чи сильно тече?', 2);
  perform pg_temp.turn('7d8f0953-e2b3-596d-9df1-c5a851da57bb', '3f393547-28bc-5c06-88bd-c5d1b44c1ffe', 'Daša', 'Jako curi, a i odvod u kupaonici je začepljen.', 'Сильно тече, а ще злив у ванній забився.', 3);
  perform pg_temp.turn('eaeb5405-47b5-5c5c-a1df-4f09893dd28a', '3f393547-28bc-5c06-88bd-c5d1b44c1ffe', 'Stanodavac', 'Šaljem vodoinstalatera danas poslije podne.', 'Надішлю сантехніка сьогодні по обіді.', 4);
  perform pg_temp.turn('a163c05f-3e27-50f3-bdba-faebe6d807fe', '3f393547-28bc-5c06-88bd-c5d1b44c1ffe', 'Daša', 'Hvala. I vodokotlić stalno radi.', 'Дякую. І зливний бачок весь час шумить.', 5);
  perform pg_temp.turn('abb94d00-982b-5035-ae60-38596951a9d6', '3f393547-28bc-5c06-88bd-c5d1b44c1ffe', 'Stanodavac', 'Dobro, neka pogleda sve odjednom.', 'Добре, хай подивиться все одразу.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4df4e174-4614-5d19-976c-ae15eb22c9ca', v_lesson, 'Немає світла', 'Nema struje', 3452, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('89850783-84ab-5386-8788-1fd95a85acb7', '4df4e174-4614-5d19-976c-ae15eb22c9ca', 'Luka', 'Opet nema struje u kupaonici!', 'Знову немає світла у ванній!', 1);
  perform pg_temp.turn('a975d825-bfe2-5302-8c8d-ddbf497c9b90', '4df4e174-4614-5d19-976c-ae15eb22c9ca', 'Darja', 'Provjeri osigurač u hodniku.', 'Перевір запобіжник у коридорі.', 2);
  perform pg_temp.turn('3b25b541-36fb-53cc-8cc8-168dd484dbf1', '4df4e174-4614-5d19-976c-ae15eb22c9ca', 'Luka', 'Osigurač je u redu. Možda je kratki spoj.', 'Запобіжник у порядку. Може, коротке замикання.', 3);
  perform pg_temp.turn('1ebd6dd0-6a1c-5e2c-9d04-c9686f89365a', '4df4e174-4614-5d19-976c-ae15eb22c9ca', 'Darja', 'Onda zovi električara, ne diraj ništa.', 'Тоді клич електрика, нічого не чіпай.', 4);
  perform pg_temp.turn('a6b03b44-7203-5bd9-8a4f-ae77d6e544fc', '4df4e174-4614-5d19-976c-ae15eb22c9ca', 'Luka', 'A svjetlo na stubištu?', 'А світло на сходах?', 5);
  perform pg_temp.turn('78b3f0b3-fb6a-5b23-9705-8b506a6e54aa', '4df4e174-4614-5d19-976c-ae15eb22c9ca', 'Darja', 'To popravlja domar, treba promijeniti žarulju.', 'Це ремонтує завгосп, треба замінити лампочку.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 46: Дрібний ремонт — перебудова: 16 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'dd2c0f3c-19f2-5c73-b448-a0631cd97e69';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Дрібний ремонт» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'b3dec00a-5a9a-5c81-8e1d-491239595a85') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 46: Дрібний ремонт', title_hr = 'Lekcija 46: Mali popravci',
         objectives = '["Назвати інструменти: čekić, kliješta, odvijač, ljestve", "Попросити подати інструмент і допомогти", "Наказовий: dodaj mi, drži, zabij, zategni"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Наказовий спосіб' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Наказовий спосіб»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'alat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čekić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čavao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zabiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bušilica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bušiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odvijač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kliješta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zategnuti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljestve', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kist', v_pos);
  v_pos := pg_temp.word(v_lesson, 'valjak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ličiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pločica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brtva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljepilo', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '488e50d4-72b5-541a-bb66-5345190d234f', 'fill_in_the_blank', '___ mi čekić, molim te.', 'Dodaj', '["Dodaje", "Dodam", "Dodati", "Dodaj"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '49b3d745-b37b-5697-87ea-1f42dba82460', 'multiple_choice', 'Що означає «zabiti»?', 'забити (цвях)', '["дриль", "плоскогубці, кліщі", "затягнути, підкрутити", "забити (цвях)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'zabiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a04d3709-5060-52e3-8ecb-907ac6fc6dc6', 'multiple_choice', 'Що означає «kist»?', 'пензель', '["викрутка", "пензель", "валик (для фарби)", "дриль"]'::jsonb, 'A1', 3, 'PUBLISHED', 'kist', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '80f06f5c-a4d8-5ba9-920e-3764477ffd63', 'multiple_choice', 'Що означає «ličiti»?', 'фарбувати (стіни)', '["валик (для фарби)", "затягнути, підкрутити", "фарбувати (стіни)", "пензель"]'::jsonb, 'A1', 4, 'PUBLISHED', 'ličiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b465be15-e026-5b13-b8e3-ff2697489ad8', 'multiple_choice', 'Як хорватською «драбина»?', 'ljestve', '["ličiti", "kist", "ljestve", "brtva"]'::jsonb, 'A1', 5, 'PUBLISHED', 'ljestve', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '501e567d-c1d7-566e-ae40-6c2637a98ba1', 'multiple_choice', 'Як хорватською «прокладка (у крані)»?', 'brtva', '["alat", "brtva", "zabiti", "ljepilo"]'::jsonb, 'A1', 6, 'PUBLISHED', 'brtva', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '63ea5a67-0f51-5d8c-abda-cff7a0fa184e', 'type_answer', 'Напишіть хорватською: «затягнути, підкрутити»', 'zategnuti', null, 'A1', 7, 'PUBLISHED', 'zategnuti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e6c18e9-9402-51e7-ade6-9c010fe7ac7c', 'type_answer', 'Напишіть хорватською: «свердлити»', 'bušiti', null, 'A1', 8, 'PUBLISHED', 'bušiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '674634d0-09c4-5a55-8ec9-95b39ab10f69', 'type_answer', 'Напишіть хорватською: «молоток»', 'čekić', null, 'A1', 9, 'PUBLISHED', 'čekić', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '189c9c9c-d346-5d64-8bc2-9e2aae878cea', 'sentence_builder', 'Складіть: «Потримай драбину, будь ласка.»', 'Drži ljestve, molim te.', '["molim", "te.", "ljestve,", "Drži"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ed171d37-d6d9-560c-ae40-2f6983998780', 'sentence_builder', 'Складіть: «Подай мені викрутку.»', 'Dodaj mi odvijač.', '["mi", "odvijač.", "Dodaj"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6c0ed718-d955-53d8-82f3-54bbcd0448b2', 'listening', 'Прослухайте і складіть фразу', 'Gdje želiš policu, iznad kreveta?', '["iznad", "Gdje", "želiš", "kreveta?", "policu,"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '491ef80f-8433-5ef9-a281-36bf280036ab', 'listening', 'Прослухайте і складіть фразу', 'Imam, u kutiji s alatom.', '["Imam,", "alatom.", "kutiji", "u", "s"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '22feeb80-67b4-56ef-9b92-f222ee4f97a1', 'speaking', 'Принеси дриль.', 'Donesi bušilicu.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ddea879f-c563-5895-a406-fed5f7e432f5', 'speaking', 'Підтягни гвинт.', 'Zategni vijak.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b3dec00a-5a9a-5c81-8e1d-491239595a85', v_lesson, 'Вішаємо полицю', 'Vješamo policu', 3461, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('0cef9b1f-eb90-58d2-aba2-011469f0bc0c', 'b3dec00a-5a9a-5c81-8e1d-491239595a85', 'Daša', 'Luka, donesi bušilicu i ljestve.', 'Луко, принеси дриль і драбину.', 1);
  perform pg_temp.turn('1818174a-cb26-5fa0-a3c7-39222f210e7e', 'b3dec00a-5a9a-5c81-8e1d-491239595a85', 'Luka', 'Gdje želiš policu, iznad kreveta?', 'Де ти хочеш полицю — над ліжком?', 2);
  perform pg_temp.turn('0daf5ad1-752d-5ee3-a643-453979c421fa', 'b3dec00a-5a9a-5c81-8e1d-491239595a85', 'Daša', 'Da. Drži ljestve, molim te, a ja bušim.', 'Так. Потримай драбину, будь ласка, а я свердлитиму.', 3);
  perform pg_temp.turn('ba307d25-b2d2-50f2-bb6a-78fa807cd9b0', 'b3dec00a-5a9a-5c81-8e1d-491239595a85', 'Luka', 'Pazi, ne buši preblizu prozora.', 'Обережно, не свердли надто близько до вікна.', 4);
  perform pg_temp.turn('a9abdbf3-2550-57a4-a352-d0fa480817ba', 'b3dec00a-5a9a-5c81-8e1d-491239595a85', 'Daša', 'Dobro. Sad mi dodaj odvijač i vijke.', 'Добре. Тепер подай мені викрутку й гвинти.', 5);
  perform pg_temp.turn('12c524b8-ece6-5b22-baea-645d74e394fd', 'b3dec00a-5a9a-5c81-8e1d-491239595a85', 'Luka', 'Izvoli. Za slike je dosta čekić i čavao.', 'Тримай. Для картин вистачить молотка й цвяха.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('bf512b5e-9308-5b93-bf3b-11227315efbc', v_lesson, 'Фарбуємо кімнату', 'Ličimo sobu', 3462, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('37d0c288-ce70-5bc8-a772-a952e9711f3c', 'bf512b5e-9308-5b93-bf3b-11227315efbc', 'Marko', 'Darja, imaš li valjak i kist?', 'Даріє, у тебе є валик і пензель?', 1);
  perform pg_temp.turn('d7ddb721-fde5-5ff6-bb59-4002a8c4b8b5', 'bf512b5e-9308-5b93-bf3b-11227315efbc', 'Darja', 'Imam, u kutiji s alatom.', 'Є, у коробці з інструментами.', 2);
  perform pg_temp.turn('5ab47569-1542-5b04-9893-42f6cd76e6a3', 'bf512b5e-9308-5b93-bf3b-11227315efbc', 'Marko', 'Ličimo prvo strop, pa zidove.', 'Спочатку фарбуємо стелю, потім стіни.', 3);
  perform pg_temp.turn('2ce48206-ea0d-5101-a8f6-7a9405029ddd', 'bf512b5e-9308-5b93-bf3b-11227315efbc', 'Darja', 'Može. A što je s pločicom u kupaonici?', 'Добре. А що з плиткою у ванній?', 4);
  perform pg_temp.turn('c5bf92ea-924f-52ea-baa9-0b26b404ea70', 'bf512b5e-9308-5b93-bf3b-11227315efbc', 'Marko', 'Zalijepi je ljepilom za pločice.', 'Приклей її клеєм для плитки.', 5);
  perform pg_temp.turn('edc5d6e1-b2f0-5d94-8280-468d4beb6418', 'bf512b5e-9308-5b93-bf3b-11227315efbc', 'Darja', 'I slavina kapa, zategni je kliještima.', 'І кран капає, підтягни його плоскогубцями.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 47: Опалення, холод і спека — перебудова: 16 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '62b118f9-a5e0-587b-82f8-39de181ddeba';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Опалення, холод і спека» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'c3f74cfe-5882-5cc3-bb08-b2e420c19614') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 47: Опалення, холод і спека', title_hr = 'Lekcija 47: Grijanje, hladnoća i vrućina',
         objectives = '["Поговорити про опалення й вологу: radijator, termostat, plijesan", "Порадити, як провітрити й зберегти тепло", "Дієслово + інфінітив: moram prozračiti, trebaš upaliti"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Правильні дієслова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Правильні дієслова»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'centralno grijanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radijator', v_pos);
  v_pos := pg_temp.word(v_lesson, 'termostat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grijalica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'peć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'drva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ventilator', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prozračiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'propuh', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vlaga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plijesan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odvlaživač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izolacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hladnoća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrućina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smrznuti se', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2bbcdb00-397b-52f0-b140-062a667dd728', 'fill_in_the_blank', 'Trebaš ___ sobu svaki dan.', 'prozračiti', '["prozračiti", "prozračim", "prozrači", "prozračen"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'da732bc0-56e7-5d5c-8fce-9a14c364b02d', 'multiple_choice', 'Що означає «centralno grijanje»?', 'центральне опалення', '["пліснява", "утеплення, ізоляція", "центральне опалення", "осушувач повітря"]'::jsonb, 'A1', 2, 'PUBLISHED', 'centralno grijanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8cb48edc-72fd-54d1-85e0-e292b6d911b0', 'multiple_choice', 'Що означає «vlaga»?', 'вологість; сирість', '["обігрівач", "утеплення, ізоляція", "вологість; сирість", "пліснява"]'::jsonb, 'A1', 3, 'PUBLISHED', 'vlaga', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c3ec845f-d69d-597c-965d-07f7176b7d1c', 'multiple_choice', 'Що означає «smrznuti se»?', 'замерзнути', '["обігрівач", "дрова", "піч", "замерзнути"]'::jsonb, 'A1', 4, 'PUBLISHED', 'smrznuti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a3ac03b3-2fc6-5084-89ce-6d98cef1746d', 'multiple_choice', 'Як хорватською «утеплення, ізоляція»?', 'izolacija', '["propuh", "prozračiti", "plijesan", "izolacija"]'::jsonb, 'A1', 5, 'PUBLISHED', 'izolacija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e1a07d71-ba01-585d-b5ef-0989d7fc8073', 'multiple_choice', 'Як хорватською «дрова»?', 'drva', '["izolacija", "radijator", "ventilator", "drva"]'::jsonb, 'A1', 6, 'PUBLISHED', 'drva', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a7f43859-c6b4-5faf-bdf6-89b34e6926a5', 'type_answer', 'Напишіть хорватською: «піч»', 'peć', null, 'A1', 7, 'PUBLISHED', 'peć', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '45a796aa-b14d-5069-bfc5-a4efa2036874', 'type_answer', 'Напишіть хорватською: «провітрити»', 'prozračiti', null, 'A1', 8, 'PUBLISHED', 'prozračiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '23a0730f-69f5-509c-8273-b0bc7dadc4fd', 'type_answer', 'Напишіть хорватською: «протяг»', 'propuh', null, 'A1', 9, 'PUBLISHED', 'propuh', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9563daf5-77f6-5f58-92fe-557c58f3d715', 'sentence_builder', 'Складіть: «Батарея холодна.»', 'Radijator je hladan.', '["Radijator", "hladan.", "je"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a8f8ca63-2991-5b37-a677-aa199f0de3c4', 'sentence_builder', 'Складіть: «Треба провітрити ванну.»', 'Treba prozračiti kupaonicu.', '["kupaonicu.", "Treba", "prozračiti"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dc1c1a5f-f3b8-55e6-86a7-36c7dbb69bff', 'listening', 'Прослухайте і складіть фразу', 'Onda upali grijalicu u spavaćoj sobi.', '["upali", "Onda", "u", "sobi.", "grijalicu", "spavaćoj"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ec4b6cdf-0020-5e60-b86b-ab9310eae5cd', 'listening', 'Прослухайте і складіть фразу', 'Ali onda imamo propuh i hladnoću.', '["imamo", "hladnoću.", "i", "propuh", "Ali", "onda"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '01fb8471-911c-5af5-bd85-279e98590ee8', 'speaking', 'У квартирі холодно.', 'U stanu je hladno.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c2ded10c-31f7-5b05-8410-756c6b33ac37', 'speaking', 'Увімкни вентилятор.', 'Upali ventilator.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c3f74cfe-5882-5cc3-bb08-b2e420c19614', v_lesson, 'Холодно в квартирі', 'Hladno je u stanu', 3471, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('6fdb7a2d-83fe-52b2-a046-191840619710', 'c3f74cfe-5882-5cc3-bb08-b2e420c19614', 'Luka', 'Dašo, smrzavam se, radijator je hladan!', 'Дашо, я мерзну, батарея холодна!', 1);
  perform pg_temp.turn('bbd7f03c-536d-552c-8cb2-18ca84befcc4', 'c3f74cfe-5882-5cc3-bb08-b2e420c19614', 'Daša', 'Centralno grijanje počinje tek petnaestog listopada.', 'Центральне опалення вмикають лише п’ятнадцятого жовтня.', 2);
  perform pg_temp.turn('cef78e9d-3394-560d-9e7a-51d8c87b38e4', 'c3f74cfe-5882-5cc3-bb08-b2e420c19614', 'Luka', 'Onda upali grijalicu u spavaćoj sobi.', 'Тоді увімкни обігрівач у спальні.', 3);
  perform pg_temp.turn('c18a8c8f-8106-5d13-8e38-873c6a68b30e', 'c3f74cfe-5882-5cc3-bb08-b2e420c19614', 'Daša', 'Može. I stavi termostat na dvadeset dva.', 'Добре. І постав термостат на двадцять два.', 4);
  perform pg_temp.turn('eb42ffde-4a50-553e-a359-a7dc5879f331', 'c3f74cfe-5882-5cc3-bb08-b2e420c19614', 'Luka', 'Kod bake na selu imaju peć na drva.', 'У бабусі в селі піч на дровах.', 5);
  perform pg_temp.turn('17823496-f2ce-51de-b72f-dfde1941a98e', 'c3f74cfe-5882-5cc3-bb08-b2e420c19614', 'Daša', 'Tamo nikad nije hladno, ni zimi.', 'Там ніколи не холодно, навіть узимку.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5e8ade10-3637-548d-8a2f-65c82115282b', v_lesson, 'Волога й пліснява', 'Vlaga i plijesan', 3472, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('a2f0a80b-3565-5b9d-976c-accaefd6aec5', '5e8ade10-3637-548d-8a2f-65c82115282b', 'Darja', 'Na zidu u kupaonici je plijesan.', 'На стіні у ванній пліснява.', 1);
  perform pg_temp.turn('ef94eee6-6ca0-587e-9ec7-f773a7a50059', '5e8ade10-3637-548d-8a2f-65c82115282b', 'Ana', 'To je od vlage. Trebaš prozračiti svaki dan.', 'Це від вологи. Треба щодня провітрювати.', 2);
  perform pg_temp.turn('5df84254-0028-55b1-bf51-d394a7f52e00', '5e8ade10-3637-548d-8a2f-65c82115282b', 'Darja', 'Ali onda imamo propuh i hladnoću.', 'Але тоді в нас протяг і холод.', 3);
  perform pg_temp.turn('10b8e4df-aacb-5555-96db-81a68d6f63a2', '5e8ade10-3637-548d-8a2f-65c82115282b', 'Ana', 'Deset minuta je dosta. Kupi i odvlaživač.', 'Десяти хвилин досить. Купи ще осушувач.', 4);
  perform pg_temp.turn('83343109-b2bd-5051-af4a-eea0104a72a9', '5e8ade10-3637-548d-8a2f-65c82115282b', 'Darja', 'Zgrada je stara, nema dobru izolaciju.', 'Будинок старий, без гарного утеплення.', 5);
  perform pg_temp.turn('dc49282d-45e8-54f2-b3ac-c236edbe27c1', '5e8ade10-3637-548d-8a2f-65c82115282b', 'Ana', 'Zato je ljeti vrućina, pa trebaš ventilator.', 'Тому влітку спека, і потрібен вентилятор.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 48: Новий сусід — перебудова: 13 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'a42b9121-2ec0-5064-909b-f59f315b3c4a';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Новий сусід» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '18935501-825a-5701-8da0-81b63b422f21') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 48: Новий сусід', title_hr = 'Lekcija 48: Novi susjed',
         objectives = '["Познайомитися із сусідами й запропонувати допомогу", "Ввічливо поскаржитися на шум", "Сполучники: jer, ali, pa, ako"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Сполучники' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Сполучники»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'susjedstvo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stanar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stubište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stepenice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pokucati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smetati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uznemiravati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispričati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tiho', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glasno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobrodošlica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zalijevati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posuditi', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2510b402-325c-5413-be95-69b60e653f4e', 'fill_in_the_blank', 'Molim vas, tiše, ___ dijete spava.', 'jer', '["ali", "jer", "ili", "a"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c017e7c-fcc5-5f12-8ef9-b7d943bc169b', 'multiple_choice', 'Що означає «stubište»?', 'сходова клітка', '["сусідство; сусіди", "заважати", "мешканець / орендар", "сходова клітка"]'::jsonb, 'A1', 2, 'PUBLISHED', 'stubište', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5bce1769-7c17-561c-9a58-1b2a5ad37159', 'multiple_choice', 'Що означає «stepenice»?', 'сходи', '["сусідство; сусіди", "постукати", "турбувати, непокоїти", "сходи"]'::jsonb, 'A1', 3, 'PUBLISHED', 'stepenice', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8c00db63-f38a-5f1e-b166-6ec157a9f3a6', 'multiple_choice', 'Що означає «glasno»?', 'голосно', '["голосно", "постукати", "поливати", "сходова клітка"]'::jsonb, 'A1', 4, 'PUBLISHED', 'glasno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0e429592-f564-5f60-9263-e898422279e4', 'multiple_choice', 'Як хорватською «поливати»?', 'zalijevati', '["stubište", "zalijevati", "glasno", "stanar"]'::jsonb, 'A1', 5, 'PUBLISHED', 'zalijevati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '285091d5-7649-58e9-8614-fd11363e868c', 'multiple_choice', 'Як хорватською «сусідство; сусіди»?', 'susjedstvo', '["susjedstvo", "pokucati", "glasno", "uznemiravati"]'::jsonb, 'A1', 6, 'PUBLISHED', 'susjedstvo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '74ae018f-cfd1-5030-be08-bc5d349f9c19', 'type_answer', 'Напишіть хорватською: «турбувати, непокоїти»', 'uznemiravati', null, 'A1', 7, 'PUBLISHED', 'uznemiravati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd48603ac-486e-52f7-8dd8-93c47480f8f8', 'type_answer', 'Напишіть хорватською: «вибачитися»', 'ispričati se', null, 'A1', 8, 'PUBLISHED', 'ispričati se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '59f6793e-ed14-5153-84f7-156a7d9c0f87', 'type_answer', 'Напишіть хорватською: «позичити»', 'posuditi', null, 'A1', 9, 'PUBLISHED', 'posuditi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd0403747-79b3-5e0c-be7b-209062d36e73', 'sentence_builder', 'Складіть: «Вибачте, що турбую.»', 'Oprostite što vas uznemiravam.', '["vas", "što", "uznemiravam.", "Oprostite"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'befd6de0-d9e9-5240-b199-bcbb32758541', 'sentence_builder', 'Складіть: «Музика нам заважає.»', 'Glazba nam smeta.', '["smeta.", "Glazba", "nam"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a13eb2da-e23a-582a-8ea6-a2adb06fd1db', 'listening', 'Прослухайте і складіть фразу', 'Da, ja sam Daša. Drago mi je!', '["je!", "Daša.", "mi", "sam", "Da,", "ja", "Drago"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bd8c4a3e-6acb-58c7-ab2c-46da52fd247e', 'listening', 'Прослухайте і складіть фразу', 'Malo, jer dijete spava.', '["Malo,", "jer", "spava.", "dijete"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4106f711-59c3-5c00-a153-ba9dd60d3c49', 'speaking', 'Ласкаво просимо до сусідства!', 'Dobrodošli u susjedstvo!', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '56f865be-a0ce-542b-ac3d-cdb2fb6b9ace', 'speaking', 'Можете поливати квіти?', 'Možete li zalijevati cvijeće?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('18935501-825a-5701-8da0-81b63b422f21', v_lesson, 'Знайомство на сходах', 'Upoznavanje na stubištu', 3481, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('a9ceff8c-d18b-5e1b-a5a1-91dc421665a5', '18935501-825a-5701-8da0-81b63b422f21', 'Susjeda', 'Dobar dan! Vi ste novi stanari na trećem katu?', 'Добрий день! Ви нові мешканці на третьому поверсі?', 1);
  perform pg_temp.turn('e6313a71-3bdf-5bd8-8a31-8e4f12a929d3', '18935501-825a-5701-8da0-81b63b422f21', 'Daša', 'Da, ja sam Daša. Drago mi je!', 'Так, я Даша. Приємно познайомитися!', 2);
  perform pg_temp.turn('122937c5-60a0-5a87-99f1-afca68e55820', '18935501-825a-5701-8da0-81b63b422f21', 'Susjeda', 'Ja sam Mirjana. Dobrodošli u susjedstvo!', 'Я Мір’яна. Ласкаво просимо до сусідства!', 3);
  perform pg_temp.turn('46eed033-6590-528c-9587-137f3aaf6eb1', '18935501-825a-5701-8da0-81b63b422f21', 'Daša', 'Hvala! Ako vam nešto treba, slobodno pokucajte.', 'Дякую! Якщо вам щось треба, стукайте без вагань.', 4);
  perform pg_temp.turn('5770f5d2-06e0-530e-a986-cd512129da65', '18935501-825a-5701-8da0-81b63b422f21', 'Susjeda', 'I vi meni. Kad idete na more, mogu zalijevati cvijeće.', 'І ви до мене. Коли поїдете на море, можу поливати квіти.', 5);
  perform pg_temp.turn('830840bc-37ca-5bb3-8cfc-8fe11955933c', '18935501-825a-5701-8da0-81b63b422f21', 'Daša', 'To je jako lijepo od vas.', 'Це дуже мило з вашого боку.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d58dc263-fc9f-59e0-8cfe-b53aed6d1a49', v_lesson, 'Голосна музика', 'Glasna glazba', 3482, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('1164250e-c437-57b2-9f62-d6272723706c', 'd58dc263-fc9f-59e0-8cfe-b53aed6d1a49', 'Luka', 'Oprostite što vas uznemiravam, ali glazba je preglasna.', 'Перепрошую, що турбую, але музика надто гучна.', 1);
  perform pg_temp.turn('fc9882d7-7e05-5a4a-aead-af2ac25b2400', 'd58dc263-fc9f-59e0-8cfe-b53aed6d1a49', 'Susjed', 'Joj, ispričavam se! Smeta li vam jako?', 'Ой, вибачте! Вам дуже заважає?', 2);
  perform pg_temp.turn('a8137d7e-9bf5-59d2-93df-5b7cfb3bff8e', 'd58dc263-fc9f-59e0-8cfe-b53aed6d1a49', 'Luka', 'Malo, jer dijete spava.', 'Трохи, бо дитина спить.', 3);
  perform pg_temp.turn('ea7202e9-5e1e-53f8-b321-778ff5f2b62a', 'd58dc263-fc9f-59e0-8cfe-b53aed6d1a49', 'Susjed', 'Razumijem. Odmah stišavam.', 'Розумію. Уже роблю тихіше.', 4);
  perform pg_temp.turn('b91f3921-7949-5224-ad93-fb405d4722f6', 'd58dc263-fc9f-59e0-8cfe-b53aed6d1a49', 'Luka', 'Hvala vam. A trebate li možda pomoć sa stepenicama?', 'Дякую вам. А вам, може, допомогти зі сходами?', 5);
  perform pg_temp.turn('746893d5-39c8-59b6-9a10-d43149ad4f27', 'd58dc263-fc9f-59e0-8cfe-b53aed6d1a49', 'Susjed', 'Može, ako mi posudite kolica za prtljagu.', 'Так, якщо позичите мені візок для багажу.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 49: Правила будинку — перебудова: 16 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'f296bc84-8059-5981-a5b9-9d4531627e18';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Правила будинку» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'e2b5f802-fa02-5268-8101-750a87180a4a') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 49: Правила будинку', title_hr = 'Lekcija 49: Kućni red',
         objectives = '["Зрозуміти правила будинку: noćni mir, zajednički prostori, otpad", "Запитати управителя про внесок і сміття", "Заперечення: ne smije se, nije dopušteno, nikad"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Заперечення' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Заперечення»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kućni red', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stambena zgrada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upravitelj zgrade', v_pos);
  v_pos := pg_temp.word(v_lesson, 'suvlasnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pričuva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zajednički prostori', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tavan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'noćni mir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zabranjeno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dopušteno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pravilo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poštovati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otpad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'reciklaža', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kontejner', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sušiti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b6ea8d37-8200-5bea-8d7d-5d9800e72f11', 'fill_in_the_blank', 'Ovdje se ne ___ pušiti.', 'smije', '["smijem", "smiješ", "smjeti", "smije"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fc662495-e447-5180-bc8e-6fd43ae719e4', 'multiple_choice', 'Що означає «noćni mir»?', 'нічна тиша', '["управитель будинку", "нічна тиша", "горище", "правило"]'::jsonb, 'A1', 2, 'PUBLISHED', 'noćni mir', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '03af41ae-232a-5487-a3aa-3f420cebbde8', 'multiple_choice', 'Що означає «kontejner»?', 'контейнер', '["управитель будинку", "нічна тиша", "контейнер", "відходи"]'::jsonb, 'A1', 3, 'PUBLISHED', 'kontejner', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7bed230d-3e79-53f4-85ba-ed9871318071', 'multiple_choice', 'Що означає «stambena zgrada»?', 'житловий будинок', '["горище", "контейнер", "співвласник", "житловий будинок"]'::jsonb, 'A1', 4, 'PUBLISHED', 'stambena zgrada', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e2afe66a-7490-529f-a0ba-d76b42a5cef4', 'multiple_choice', 'Як хорватською «переробка»?', 'reciklaža', '["noćni mir", "sušiti", "stambena zgrada", "reciklaža"]'::jsonb, 'A1', 5, 'PUBLISHED', 'reciklaža', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd0cc4bdf-064b-5410-8626-9eb469974b91', 'multiple_choice', 'Як хорватською «правило»?', 'pravilo', '["zabranjeno", "pravilo", "otpad", "upravitelj zgrade"]'::jsonb, 'A1', 6, 'PUBLISHED', 'pravilo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '37a50925-54ec-5965-94f5-fc9fb0e076cd', 'type_answer', 'Напишіть хорватською: «горище»', 'tavan', null, 'A1', 7, 'PUBLISHED', 'tavan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c6fc46d9-43ce-5e2f-b83e-1a0d0716c79e', 'type_answer', 'Напишіть хорватською: «відходи»', 'otpad', null, 'A1', 8, 'PUBLISHED', 'otpad', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '93090998-9a0f-5c5f-a4ae-de7c5b7a9025', 'type_answer', 'Напишіть хорватською: «дозволено»', 'dopušteno', null, 'A1', 9, 'PUBLISHED', 'dopušteno', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bcbf3c53-8b72-5e19-8ee4-908733524570', 'sentence_builder', 'Складіть: «Тут не можна паркуватися.»', 'Ovdje se ne smije parkirati.', '["se", "smije", "parkirati.", "Ovdje", "ne"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '83dd96bd-2540-5a03-bf3e-d88c9f715d9d', 'sentence_builder', 'Складіть: «Нічна тиша з десятої.»', 'Noćni mir je od deset.', '["Noćni", "mir", "od", "deset.", "je"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd3a0b335-cb17-53c6-b00b-7bc8755c7348', 'listening', 'Прослухайте і складіть фразу', 'Smijete, tavan je zajednički prostor.', '["je", "tavan", "Smijete,", "zajednički", "prostor."]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '58b2ef61-a99c-585b-9306-7addb90f1319', 'listening', 'Прослухайте і складіть фразу', 'Gdje bacamo otpad?', '["bacamo", "Gdje", "otpad?"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9dc4fb74-156e-5665-b99d-48b4bbc84798', 'speaking', 'Де правила будинку?', 'Gdje je kućni red?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '78a80a64-64f5-5afa-a775-21c7818e073a', 'speaking', 'Це заборонено.', 'To je zabranjeno.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e2b5f802-fa02-5268-8101-750a87180a4a', v_lesson, 'Розмова з управителем', 'Razgovor s upraviteljem', 3491, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('72661cb0-447e-58bf-8d0e-fc65fa101604', 'e2b5f802-fa02-5268-8101-750a87180a4a', 'Daša', 'Dobar dan, gdje mogu pročitati kućni red?', 'Добрий день, де можна прочитати правила будинку?', 1);
  perform pg_temp.turn('f765b30d-9713-5ea4-81fc-e94cdf893036', 'e2b5f802-fa02-5268-8101-750a87180a4a', 'Upravitelj', 'Na ploči u ulazu. Noćni mir je od deset do šest.', 'На дошці в під’їзді. Нічна тиша — з десятої до шостої.', 2);
  perform pg_temp.turn('de122a91-eb0f-5b5f-a1f1-8d86bc403d3a', 'e2b5f802-fa02-5268-8101-750a87180a4a', 'Daša', 'Smijemo li sušiti rublje na tavanu?', 'Можна сушити білизну на горищі?', 3);
  perform pg_temp.turn('f82d8edb-d45b-501c-857a-40cd7f2c52c8', 'e2b5f802-fa02-5268-8101-750a87180a4a', 'Upravitelj', 'Smijete, tavan je zajednički prostor.', 'Можна, горище — місце загального користування.', 4);
  perform pg_temp.turn('1fe70d11-f8bb-54eb-aa4a-a56c263bfbfa', 'e2b5f802-fa02-5268-8101-750a87180a4a', 'Daša', 'A tko plaća pričuvu, stanar ili vlasnik?', 'А хто платить внесок на утримання — орендар чи власник?', 5);
  perform pg_temp.turn('c47832cb-ec90-5093-b133-b031ee58e7bb', 'e2b5f802-fa02-5268-8101-750a87180a4a', 'Upravitelj', 'Pričuvu plaćaju suvlasnici zgrade.', 'Внесок платять співвласники будинку.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8b74e4a5-c9e0-5634-8c2a-d59b5b845365', v_lesson, 'Сміття й переробка', 'Otpad i reciklaža', 3492, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('c53ad4e0-fbfd-527e-b0e9-818f97b54d4e', '8b74e4a5-c9e0-5634-8c2a-d59b5b845365', 'Luka', 'Gdje bacamo otpad?', 'Куди викидаємо сміття?', 1);
  perform pg_temp.turn('eec9c86b-3fa4-5f82-9371-0ed2693ab18b', '8b74e4a5-c9e0-5634-8c2a-d59b5b845365', 'Susjeda', 'Kontejneri su iza zgrade. Papir i plastiku odvajamo.', 'Контейнери за будинком. Папір і пластик сортуємо.', 2);
  perform pg_temp.turn('0e9d9806-cb06-519e-9914-d700c9b4e7e5', '8b74e4a5-c9e0-5634-8c2a-d59b5b845365', 'Luka', 'Je li dopušteno ostaviti stari namještaj pored kontejnera?', 'Можна залишити старі меблі біля контейнера?', 3);
  perform pg_temp.turn('633ab50e-8c0e-56ed-b993-8b5c06dea7ed', '8b74e4a5-c9e0-5634-8c2a-d59b5b845365', 'Susjeda', 'Nije, to je zabranjeno. Zovite odvoz glomaznog otpada.', 'Ні, це заборонено. Викличте вивіз великогабаритного сміття.', 4);
  perform pg_temp.turn('82dd8649-9627-5273-bb29-f89eb7c74ab3', '8b74e4a5-c9e0-5634-8c2a-d59b5b845365', 'Luka', 'Razumijem. Ovdje svi poštuju pravila?', 'Зрозуміло. Тут усі дотримуються правил?', 5);
  perform pg_temp.turn('0a367ea8-978b-55ea-b94b-7e91ae13eddb', '8b74e4a5-c9e0-5634-8c2a-d59b5b845365', 'Susjeda', 'Uglavnom da, ova stambena zgrada je mirna.', 'Здебільшого так, цей житловий будинок спокійний.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- 3. Нові уроки модуля A1.5
-- A1.5 · урок 41: Мій район: що поруч? — новий урок: 15 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := 'c80b7070-95f0-54de-b4dd-90d024f5b830';
  v_lesson constant uuid := '3ea9520d-2baa-56b2-aa85-402e3e3ecb9b';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.5: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 41: Мій район: що поруч?', 'Lekcija 41: Moj kvart: što je blizu?', '["Розповісти, що є поруч із домом: kiosk, sportski centar, stara jezgra", "Сказати, який район: miran, prometan, siguran", "Прийменники + родовий: blizu, preko puta, nasuprot, oko"]'::jsonb, 15, 'PUBLISHED', 2);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Родовий відмінок: основи' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Родовий відмінок: основи»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'okolica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blizina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nasuprot', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prometan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'siguran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dućan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kiosk', v_pos);
  v_pos := pg_temp.word(v_lesson, 'groblje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spomenik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fontana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'klupa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pješačka zona', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stara jezgra', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sportski centar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zelenilo', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '98f5a8e9-cde6-5726-af17-5398fe626dd0', 'fill_in_the_blank', 'Kiosk je preko puta ___.', 'pošte', '["poštu", "pošti", "pošte", "pošta"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6d8399db-09c6-58b1-b745-e7ba5d9cb61f', 'multiple_choice', 'Що означає «klupa»?', 'лава; лавка', '["жвавий, з інтенсивним рухом", "лава; лавка", "пішохідна зона", "пам''ятник"]'::jsonb, 'A1', 2, 'PUBLISHED', 'klupa', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6301a1f5-2a7a-5d37-b6e0-e93adbbeec9c', 'multiple_choice', 'Що означає «spomenik»?', 'пам''ятник', '["пішохідна зона", "пам''ятник", "кладовище", "близькість (u blizini — поруч)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'spomenik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d16ca2c-fbed-54ba-875b-48b89adabccd', 'multiple_choice', 'Що означає «nasuprot»?', 'навпроти', '["спортивний центр", "навпроти", "пішохідна зона", "близькість (u blizini — поруч)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'nasuprot', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '17f26d92-62bf-5176-8925-a27cbff43835', 'multiple_choice', 'Як хорватською «жвавий, з інтенсивним рухом»?', 'prometan', '["klupa", "blizina", "kiosk", "prometan"]'::jsonb, 'A1', 5, 'PUBLISHED', 'prometan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6eb112b4-e140-51bb-839c-0500abb3dbfc', 'multiple_choice', 'Як хорватською «околиці»?', 'okolica', '["pješačka zona", "zelenilo", "stara jezgra", "okolica"]'::jsonb, 'A1', 6, 'PUBLISHED', 'okolica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '54e54846-4b88-5021-ad2e-2e9af877b360', 'type_answer', 'Напишіть хорватською: «кіоск»', 'kiosk', null, 'A1', 7, 'PUBLISHED', 'kiosk', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ec150c2e-14b1-5733-9fab-badf23b9cc5b', 'type_answer', 'Напишіть хорватською: «безпечний / впевнений»', 'siguran', null, 'A1', 8, 'PUBLISHED', 'siguran', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e37df111-7156-5f3d-947f-dc17a55d8029', 'type_answer', 'Напишіть хорватською: «фонтан»', 'fontana', null, 'A1', 9, 'PUBLISHED', 'fontana', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '300fb20d-60a0-5e57-b898-dbc1d468d591', 'sentence_builder', 'Складіть: «Ми живемо біля школи.»', 'Živimo blizu škole.', '["Živimo", "škole.", "blizu"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0768057f-be44-515c-a56e-29b04e2bb239', 'sentence_builder', 'Складіть: «Навпроти будинку спортивний центр.»', 'Nasuprot zgrade je sportski centar.', '["centar.", "je", "zgrade", "Nasuprot", "sportski"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '23a46e1a-04db-52fa-92bf-1d356f6c0799', 'listening', 'Прослухайте і складіть фразу', 'Odličan! U blizini su dućan, kiosk i pekara.', '["kiosk", "U", "blizini", "Odličan!", "dućan,", "su", "pekara.", "i"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '658a0f88-eb09-528f-b0e5-86aa82a6e3e4', 'listening', 'Прослухайте і складіть фразу', 'Gdje je ovdje pješačka zona?', '["Gdje", "je", "pješačka", "zona?", "ovdje"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a77d58ce-7d29-5a23-bfba-768ba58202f0', 'speaking', 'Що поруч із твоїм будинком?', 'Što je blizu tvoje zgrade?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '34944ba4-48e1-59b3-92d1-028bb549cbe1', 'speaking', 'Наш район тихий і безпечний.', 'Naš kvart je miran i siguran.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b882109b-45de-587b-ac0d-b6be852c3ef9', v_lesson, 'Що в тебе поруч?', 'Što imaš u blizini?', 3411, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('38722a8e-108b-52a8-8702-b9f5cfba79da', 'b882109b-45de-587b-ac0d-b6be852c3ef9', 'Ivana', 'Dašo, kako ti je novi kvart?', 'Дашо, як тобі новий район?', 1);
  perform pg_temp.turn('edecdc13-1b87-516a-86be-c4d113f77fcd', 'b882109b-45de-587b-ac0d-b6be852c3ef9', 'Daša', 'Odličan! U blizini su dućan, kiosk i pekara.', 'Чудовий! Поруч магазин, кіоск і пекарня.', 2);
  perform pg_temp.turn('e7e780b2-9246-529e-9ce7-1e4aea11075e', 'b882109b-45de-587b-ac0d-b6be852c3ef9', 'Ivana', 'A za djecu?', 'А для дітей?', 3);
  perform pg_temp.turn('8e864fca-027a-58ac-bbd9-e7b99d6eefd2', 'b882109b-45de-587b-ac0d-b6be852c3ef9', 'Daša', 'Nasuprot zgrade je sportski centar s bazenom.', 'Навпроти будинку спортивний центр із басейном.', 4);
  perform pg_temp.turn('0726b9d6-8b4c-5905-a574-0beab69e4aad', 'b882109b-45de-587b-ac0d-b6be852c3ef9', 'Ivana', 'Je li ulica prometna?', 'Вулиця жвава?', 5);
  perform pg_temp.turn('c3cbb797-b491-59af-9428-566ee167fcc3', 'b882109b-45de-587b-ac0d-b6be852c3ef9', 'Daša', 'Nije, mirna je i sigurna, i ima puno zelenila.', 'Ні, тиха й безпечна, і багато зелені.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('fe812880-914e-53c0-981d-13f20e560655', v_lesson, 'Прогулянка старим містом', 'Šetnja starom jezgrom', 3412, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('3d00a504-031d-53ba-858d-e48a7ffce1ab', 'fe812880-914e-53c0-981d-13f20e560655', 'Darja', 'Gdje je ovdje pješačka zona?', 'Де тут пішохідна зона?', 1);
  perform pg_temp.turn('96993a40-38ea-5a19-9cce-fbd1768e995e', 'fe812880-914e-53c0-981d-13f20e560655', 'Marko', 'Odmah iza spomenika počinje stara jezgra.', 'Одразу за пам’ятником починається старе місто.', 2);
  perform pg_temp.turn('bf5cb363-2656-5c6b-89b5-989fc0a43149', 'fe812880-914e-53c0-981d-13f20e560655', 'Darja', 'Možemo li sjesti na klupu kod fontane?', 'Можемо сісти на лавку біля фонтана?', 3);
  perform pg_temp.turn('fcd3c8cf-2da4-592e-b1fa-e7de1ed14540', 'fe812880-914e-53c0-981d-13f20e560655', 'Marko', 'Može. Okolica fontane je najljepši dio grada.', 'Можна. Довкола фонтана — найгарніша частина міста.', 4);
  perform pg_temp.turn('0a79e20d-b037-54b7-b8b5-036174556c2c', 'fe812880-914e-53c0-981d-13f20e560655', 'Darja', 'A što je ono na brdu?', 'А що ото на пагорбі?', 5);
  perform pg_temp.turn('e2d393f5-9586-53dc-9559-e58636983dc9', 'fe812880-914e-53c0-981d-13f20e560655', 'Marko', 'To je staro groblje, ondje je mirno i lijepo.', 'Це старе кладовище, там тихо й гарно.', 6);
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
   where l.id in ('278947e3-ae50-5818-abd7-7f07b8ab5c44', '3ea9520d-2baa-56b2-aa85-402e3e3ecb9b', 'de93d3ab-6769-5daf-9560-8858285a8136', '23f3aad6-4447-5b75-9dd1-891773457f7e', 'b69a8cca-4918-562f-8ae5-22f8d7ba2f76', '8fc3399d-0405-5517-9358-d3ad6308d860', 'dd2c0f3c-19f2-5c73-b448-a0631cd97e69', '62b118f9-a5e0-587b-82f8-39de181ddeba', 'a42b9121-2ec0-5064-909b-f59f315b3c4a', 'f296bc84-8059-5981-a5b9-9d4531627e18')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 10 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_order from (values ('278947e3-ae50-5818-abd7-7f07b8ab5c44'::uuid, 1), ('3ea9520d-2baa-56b2-aa85-402e3e3ecb9b'::uuid, 2), ('de93d3ab-6769-5daf-9560-8858285a8136'::uuid, 3), ('23f3aad6-4447-5b75-9dd1-891773457f7e'::uuid, 4), ('b69a8cca-4918-562f-8ae5-22f8d7ba2f76'::uuid, 5), ('8fc3399d-0405-5517-9358-d3ad6308d860'::uuid, 6), ('dd2c0f3c-19f2-5c73-b448-a0631cd97e69'::uuid, 7), ('62b118f9-a5e0-587b-82f8-39de181ddeba'::uuid, 8), ('a42b9121-2ec0-5064-909b-f59f315b3c4a'::uuid, 9), ('f296bc84-8059-5981-a5b9-9d4531627e18'::uuid, 10)) as t(id, o)
    join public.lessons l on l.id = t.id and l.order_index = t.o and l.unit_id = 'c80b7070-95f0-54de-b4dd-90d024f5b830';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A1' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('278947e3-ae50-5818-abd7-7f07b8ab5c44', '3ea9520d-2baa-56b2-aa85-402e3e3ecb9b', 'de93d3ab-6769-5daf-9560-8858285a8136', '23f3aad6-4447-5b75-9dd1-891773457f7e', 'b69a8cca-4918-562f-8ae5-22f8d7ba2f76', '8fc3399d-0405-5517-9358-d3ad6308d860', 'dd2c0f3c-19f2-5c73-b448-a0631cd97e69', '62b118f9-a5e0-587b-82f8-39de181ddeba', 'a42b9121-2ec0-5064-909b-f59f315b3c4a', 'f296bc84-8059-5981-a5b9-9d4531627e18') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A1.5: % уроків з неправильним складом', v_bad; end if;
  if v_order <> 10 then raise exception 'Модуль A1.5: на своїх місцях % уроків з 10', v_order; end if;
  if v_titles > 0 then raise exception 'A1: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A1.5: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A1.5 — 10 уроків за темою (9 перебудовано, 1 нових)';
end $$;

commit;
