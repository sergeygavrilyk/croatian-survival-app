-- =====================================================================
-- Програма A1 · curriculum_a1_v1 · частина 1 з 2 · 2026-10-13
-- Згенеровано: python3 scripts/gen_curriculum_a1.py (не редагуйте вручну).
-- Запуск: Supabase → SQL Editor → вставити ВЕСЬ файл → Run. Спершу частина 1, потім частина 2.
--
--   * Нові слова: 104. Виправлення словника: 11 переклади + 3 написання леми (старі — у content_versions).
--   * 13 граматичних тем A1 → 39 правил з прикладами (теми публікуються в частині 2).
--   * Юніти 10 модулів A1.
--   * Модулі A1.1–A1.5: 24 уроків (№ 1–24), 48 діалогів (244 реплік), 288 вправ.
--   * Після цієї частини A1 ще НЕ видно користувачам — модулі публікує частина 2.
--   * Потрібна міграція M13 (типи вправ type_answer і speaking).
--   * Наявні дані не видаляються. Повторний запуск безпечний.
-- =====================================================================

begin;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'exercises_type_check'
                 and pg_get_constraintdef(oid) like '%speaking%') then
    raise exception 'Спершу запустіть міграцію M13 (20261013140000_m13_exercise_types.sql)';
  end if;
  if (select count(*) from public.modules where level_code = 'A1') < 10 then
    raise exception 'Немає 10 модулів A1 (каркас) — спершу curriculum_a0_v1';
  end if;
end $$;

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

-- 1. Нові слова A1 (яких ще немає у словнику)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kilogram', 'kilogram', 'hr', 'noun', 'A1', 'кілограм', 'core', '{"gender": "m"}'::jsonb, '["Kilogram jabuka košta dva eura."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pušiti', 'pusiti', 'hr', 'verb', 'A1', 'курити', 'core', '{"aspect": "ipfv"}'::jsonb, '["Ovdje se ne smije pušiti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uzimati', 'uzimati', 'hr', 'verb', 'A1', 'брати; приймати (ліки)', 'core', '{"aspect": "ipfv"}'::jsonb, '["Lijek uzimajte poslije jela."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dnevno', 'dnevno', 'hr', 'adverb', 'A1', 'щодня; на день', 'core', '{}'::jsonb, '["Pijte dvije litre vode dnevno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('večeras', 'veceras', 'hr', 'adverb', 'A1', 'сьогодні ввечері', 'core', '{}'::jsonb, '["Večeras idemo u kino."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rado', 'rado', 'hr', 'adverb', 'A1', 'охоче; із задоволенням', 'core', '{}'::jsonb, '["Rado čitam knjige na hrvatskom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nogomet', 'nogomet', 'hr', 'noun', 'A1', 'футбол', 'core', '{"gender": "m"}'::jsonb, '["Nedjeljom igramo nogomet u parku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kupati se', 'kupati se', 'hr', 'verb', 'A1', 'купатися', 'core', '{"aspect": "ipfv"}'::jsonb, '["Ljeti se kupamo u moru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Božić', 'bozic', 'hr', 'noun', 'A1', 'Різдво', 'core', '{"gender": "m"}'::jsonb, '["Za Božić je cijela obitelj zajedno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('blagdan', 'blagdan', 'hr', 'noun', 'A1', 'свято', 'core', '{"gender": "m"}'::jsonb, '["Uskrs je veliki blagdan u Hrvatskoj."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kućanski poslovi', 'kucanski poslovi', 'hr', 'phrase', 'A1', 'домашні справи', 'collocation', '{}'::jsonb, '["Kućanske poslove dijelimo napola."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('suđe', 'sude', 'hr', 'noun', 'A1', 'посуд', 'core', '{"gender": "n"}'::jsonb, '["Tko danas pere suđe?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rublje', 'rublje', 'hr', 'noun', 'A1', 'білизна (для прання)', 'core', '{"gender": "n"}'::jsonb, '["Rublje se suši na balkonu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prašina', 'prasina', 'hr', 'noun', 'A1', 'пил', 'core', '{"gender": "f"}'::jsonb, '["Na polici ima puno prašine."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('cimerica', 'cimerica', 'hr', 'noun', 'A1', 'сусідка по квартирі', 'core', '{"gender": "f"}'::jsonb, '["Moja cimerica je iz Zadra."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('umiti se', 'umiti se', 'hr', 'verb', 'A1', 'умитися', 'core', '{"aspect": "pfv"}'::jsonb, '["Umij se hladnom vodom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('obući se', 'obuci se', 'hr', 'verb', 'A1', 'одягнутися', 'core', '{"aspect": "pfv"}'::jsonb, '["Obuci se toplo, vani je hladno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('češljati se', 'cesljati se', 'hr', 'verb', 'A1', 'причісуватися', 'core', '{"aspect": "ipfv"}'::jsonb, '["Ona se češlja pred ogledalom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('četkica za zube', 'cetkica za zube', 'hr', 'phrase', 'A1', 'зубна щітка', 'collocation', '{}'::jsonb, '["Trebam novu četkicu za zube."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('žuriti se', 'zuriti se', 'hr', 'verb', 'A1', 'поспішати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Ne žuri se, imamo vremena."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('burek', 'burek', 'hr', 'noun', 'A1', 'бурек (листковий пиріг)', 'core', '{"gender": "m"}'::jsonb, '["Za doručak jedem burek sa sirom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pecivo', 'pecivo', 'hr', 'noun', 'A1', 'булочка; випічка', 'core', '{"gender": "n"}'::jsonb, '["Pecivo je još toplo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jogurt', 'jogurt', 'hr', 'noun', 'A1', 'йогурт', 'core', '{"gender": "m"}'::jsonb, '["Djeca vole jogurt s voćem."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('domaći', 'domaci', 'hr', 'adjective', 'A1', 'домашній', 'core', '{}'::jsonb, '["Ovo je domaći kruh."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vegetarijanac', 'vegetarijanac', 'hr', 'noun', 'A1', 'вегетаріанець', 'core', '{"gender": "m"}'::jsonb, '["Moj brat je vegetarijanac."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('orah', 'orah', 'hr', 'noun', 'A1', 'горіх', 'core', '{"gender": "m"}'::jsonb, '["U ovom kolaču ima oraha."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('slan', 'slan', 'hr', 'adjective', 'A1', 'солоний', 'core', '{}'::jsonb, '["Sir je malo previše slan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kiseo', 'kiseo', 'hr', 'adjective', 'A1', 'кислий', 'core', '{}'::jsonb, '["Ova jabuka je kisela."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('previše', 'previse', 'hr', 'adverb', 'A1', 'надто; забагато', 'core', '{}'::jsonb, '["Ne jedi previše slatkiša."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('drogerija', 'drogerija', 'hr', 'noun', 'A1', 'магазин побутової хімії й косметики', 'core', '{"gender": "f"}'::jsonb, '["Šampon kupujem u drogeriji."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pasta za zube', 'pasta za zube', 'hr', 'phrase', 'A1', 'зубна паста', 'collocation', '{}'::jsonb, '["Nestalo nam je paste za zube."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pelene', 'pelene', 'hr', 'noun', 'A1', 'підгузки', 'core', '{"gender": "f"}'::jsonb, '["Pelene su na akciji."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('deterdžent', 'deterdzent', 'hr', 'noun', 'A1', 'засіб для прання; мийний засіб', 'core', '{"gender": "m"}'::jsonb, '["Kupi deterdžent za rublje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('SIM kartica', 'sim kartica', 'hr', 'phrase', 'A1', 'SIM-картка', 'collocation', '{}'::jsonb, '["Novu SIM karticu možete kupiti na kiosku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bon', 'bon', 'hr', 'noun', 'A1', 'передплата (поповнення рахунку)', 'core', '{"gender": "m"}'::jsonb, '["Imam bon, a ne ugovor."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tarifa', 'tarifa', 'hr', 'noun', 'A1', 'тариф', 'core', '{"gender": "f"}'::jsonb, '["Ova tarifa ima neograničen internet."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mjesečno', 'mjesecno', 'hr', 'adverb', 'A1', 'щомісяця; на місяць', 'core', '{}'::jsonb, '["Najam je petsto eura mjesečno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zvati', 'zvati', 'hr', 'verb', 'A1', 'дзвонити; кликати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Mama me zove svaki dan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('puniti', 'puniti', 'hr', 'verb', 'A1', 'заряджати; наповнювати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Mobitel punim preko noći."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('broj mobitela', 'broj mobitela', 'hr', 'phrase', 'A1', 'номер мобільного телефону', 'collocation', '{}'::jsonb, '["Koji je tvoj broj mobitela?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('taksist', 'taksist', 'hr', 'noun', 'A1', 'таксист', 'core', '{"gender": "m"}'::jsonb, '["Taksist zna kraći put."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gužva', 'guzva', 'hr', 'noun', 'A1', 'затор; тиснява', 'core', '{"gender": "f"}'::jsonb, '["Ujutro je u gradu velika gužva."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('na vrijeme', 'na vrijeme', 'hr', 'adverb', 'A1', 'вчасно', 'chunk', '{}'::jsonb, '["Vlak stiže na vrijeme."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('benzinska postaja', 'benzinska postaja', 'hr', 'phrase', 'A1', 'автозаправна станція', 'collocation', '{}'::jsonb, '["Benzinska postaja radi cijelu noć."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rezervoar', 'rezervoar', 'hr', 'noun', 'A1', 'бак (паливний)', 'core', '{"gender": "m"}'::jsonb, '["Rezervoar je skoro prazan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('provjeriti', 'provjeriti', 'hr', 'verb', 'A1', 'перевірити', 'core', '{"aspect": "pfv"}'::jsonb, '["Možete li provjeriti ulje?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('automat', 'automat', 'hr', 'noun', 'A1', 'автомат (паркомат, автомат з продажу)', 'core', '{"gender": "m"}'::jsonb, '["Kartu možete kupiti na automatu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('račun za struju', 'racun za struju', 'hr', 'phrase', 'A1', 'рахунок за електрику', 'collocation', '{}'::jsonb, '["Račun za struju dolazi svaki mjesec."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uplatnica', 'uplatnica', 'hr', 'noun', 'A1', 'платіжна квитанція', 'core', '{"gender": "f"}'::jsonb, '["Uplatnicu možete platiti na pošti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ruter', 'ruter', 'hr', 'noun', 'A1', 'роутер', 'core', '{"gender": "m"}'::jsonb, '["Ugasi ruter i upali ga ponovno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uključen', 'ukljucen', 'hr', 'adjective', 'A1', 'увімкнений; включений', 'core', '{}'::jsonb, '["Je li grijanje uključeno u cijenu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tehničar', 'tehnicar', 'hr', 'noun', 'A1', 'технік', 'core', '{"gender": "m"}'::jsonb, '["Tehničar dolazi u utorak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('probni rad', 'probni rad', 'hr', 'phrase', 'A1', 'випробувальний термін', 'collocation', '{}'::jsonb, '["Probni rad traje tri mjeseca."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('puno radno vrijeme', 'puno radno vrijeme', 'hr', 'phrase', 'A1', 'повний робочий день', 'collocation', '{}'::jsonb, '["Tražim posao na puno radno vrijeme."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('smjena', 'smjena', 'hr', 'noun', 'A1', 'зміна (на роботі)', 'core', '{"gender": "f"}'::jsonb, '["Ovaj tjedan radim u drugoj smjeni."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('radna dozvola', 'radna dozvola', 'hr', 'phrase', 'A1', 'дозвіл на роботу', 'collocation', '{}'::jsonb, '["Za ovaj posao trebate radnu dozvolu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('privremena zaštita', 'privremena zastita', 'hr', 'phrase', 'A1', 'тимчасовий захист', 'collocation', '{}'::jsonb, '["Imam status privremene zaštite."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bruto', 'bruto', 'hr', 'adjective', 'A1', 'брутто (до податків)', 'core', '{}'::jsonb, '["Plaća je tisuću petsto eura bruto."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('neto', 'neto', 'hr', 'adjective', 'A1', 'нетто (після податків)', 'core', '{}'::jsonb, '["Neto plaća je manja od bruto plaće."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prekovremeni sati', 'prekovremeni sati', 'hr', 'phrase', 'A1', 'понаднормові години', 'collocation', '{}'::jsonb, '["Ovaj mjesec imam deset prekovremenih sati."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('platna lista', 'platna lista', 'hr', 'phrase', 'A1', 'розрахунковий листок', 'collocation', '{}'::jsonb, '["Platnu listu dobivate svaki mjesec."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('posebno', 'posebno', 'hr', 'adverb', 'A1', 'окремо; особливо', 'core', '{}'::jsonb, '["Piće se plaća posebno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('javiti se', 'javiti se', 'hr', 'verb', 'A1', 'обізватися; відповісти (на дзвінок); зголоситися', 'core', '{"aspect": "pfv"}'::jsonb, '["Javi se kad stigneš."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('videopoziv', 'videopoziv', 'hr', 'noun', 'A1', 'відеодзвінок', 'core', '{"gender": "m"}'::jsonb, '["Svake večeri imam videopoziv s mamom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('link', 'link', 'hr', 'noun', 'A1', 'посилання', 'core', '{"gender": "m"}'::jsonb, '["Pošalji mi link, molim te."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mail', 'mail', 'hr', 'noun', 'A1', 'електронний лист; імейл', 'core', '{"gender": "m"}'::jsonb, '["Odgovaram na mail poslije sastanka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rame', 'rame', 'hr', 'noun', 'A1', 'плече', 'core', '{"gender": "n"}'::jsonb, '["Torbu nosim na ramenu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vrat', 'vrat', 'hr', 'noun', 'A1', 'шия', 'core', '{"gender": "m"}'::jsonb, '["Od računala me boli vrat."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zubobolja', 'zubobolja', 'hr', 'noun', 'A1', 'зубний біль', 'core', '{"gender": "f"}'::jsonb, '["Zubobolja ne prolazi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('plomba', 'plomba', 'hr', 'noun', 'A1', 'пломба (зубна)', 'core', '{"gender": "f"}'::jsonb, '["Trebam novu plombu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('izvaditi', 'izvaditi', 'hr', 'verb', 'A1', 'видалити (зуб); вийняти', 'core', '{"aspect": "pfv"}'::jsonb, '["Zubar mora izvaditi zub."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('osjetljiv', 'osjetljiv', 'hr', 'adjective', 'A1', 'чутливий', 'core', '{}'::jsonb, '["Imam osjetljivu kožu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('usamljen', 'usamljen', 'hr', 'adjective', 'A1', 'самотній', 'core', '{}'::jsonb, '["U novom gradu sam ponekad usamljen."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nervozan', 'nervozan', 'hr', 'adjective', 'A1', 'знервований; схвильований', 'core', '{}'::jsonb, '["Prije ispita sam uvijek nervozan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zadovoljan', 'zadovoljan', 'hr', 'adjective', 'A1', 'задоволений', 'core', '{}'::jsonb, '["Šef je zadovoljan mojim radom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sasvim', 'sasvim', 'hr', 'adverb', 'A1', 'цілком; зовсім', 'core', '{}'::jsonb, '["To je sasvim normalno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vrh', 'vrh', 'hr', 'noun', 'A1', 'вершина', 'core', '{"gender": "m"}'::jsonb, '["S vrha se vidi cijeli grad."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nalaziti se', 'nalaziti se', 'hr', 'verb', 'A1', 'знаходитися; зустрічатися', 'core', '{"aspect": "ipfv"}'::jsonb, '["Nalazimo se ispred kina u osam."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sendvič', 'sendvic', 'hr', 'noun', 'A1', 'сендвіч', 'core', '{"gender": "m"}'::jsonb, '["Za put nosim sendvič i vodu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('udoban', 'udoban', 'hr', 'adjective', 'A1', 'зручний', 'core', '{}'::jsonb, '["Ovaj kauč je jako udoban."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('hod', 'hod', 'hr', 'noun', 'A1', 'ходьба', 'core', '{"gender": "m"}'::jsonb, '["Do plaže je pet minuta hoda."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sjever', 'sjever', 'hr', 'noun', 'A1', 'північ', 'core', '{"gender": "m"}'::jsonb, '["Zagreb je na sjeveru Hrvatske."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jug', 'jug', 'hr', 'noun', 'A1', 'південь', 'core', '{"gender": "m"}'::jsonb, '["Dubrovnik je na jugu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('istok', 'istok', 'hr', 'noun', 'A1', 'схід', 'core', '{"gender": "m"}'::jsonb, '["Sunce izlazi na istoku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zapad', 'zapad', 'hr', 'noun', 'A1', 'захід', 'core', '{"gender": "m"}'::jsonb, '["Istra je na zapadu Hrvatske."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ravnica', 'ravnica', 'hr', 'noun', 'A1', 'рівнина', 'core', '{"gender": "f"}'::jsonb, '["Slavonija je velika ravnica."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('glavni grad', 'glavni grad', 'hr', 'phrase', 'A1', 'столиця', 'collocation', '{}'::jsonb, '["Kijev je glavni grad Ukrajine."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zvučati', 'zvucati', 'hr', 'verb', 'A1', 'звучати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Tvoj plan zvuči dobro."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dugo', 'dugo', 'hr', 'adverb', 'A1', 'довго', 'core', '{}'::jsonb, '["Dugo čekamo autobus."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pričati', 'pricati', 'hr', 'verb', 'A1', 'розповідати; розмовляти', 'core', '{"aspect": "ipfv"}'::jsonb, '["Baka voli pričati o mladosti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vrtić', 'vrtic', 'hr', 'noun', 'A1', 'дитячий садок', 'core', '{"gender": "m"}'::jsonb, '["Kći ide u vrtić od osam do četiri."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('upisati', 'upisati', 'hr', 'verb', 'A1', 'записати (в садок, школу); вписати', 'core', '{"aspect": "pfv"}'::jsonb, '["Sina želimo upisati u školu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('cijepljenje', 'cijepljenje', 'hr', 'noun', 'A1', 'щеплення', 'core', '{"gender": "n"}'::jsonb, '["Cijepljenje je besplatno za djecu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ravnateljica', 'ravnateljica', 'hr', 'noun', 'A1', 'директорка (школи, садка)', 'core', '{"gender": "f"}'::jsonb, '["Ravnateljica nas čeka u uredu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('učenica', 'ucenica', 'hr', 'noun', 'A1', 'учениця', 'core', '{"gender": "f"}'::jsonb, '["Ona je učenica trećeg razreda."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('učiteljica', 'uciteljica', 'hr', 'noun', 'A1', 'учителька', 'core', '{"gender": "f"}'::jsonb, '["Učiteljica je jako strpljiva."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('slabo', 'slabo', 'hr', 'adverb', 'A1', 'слабо; погано', 'core', '{}'::jsonb, '["Još slabo govorim hrvatski."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('produženi boravak', 'produzeni boravak', 'hr', 'phrase', 'A1', 'група продовженого дня (у школі)', 'collocation', '{}'::jsonb, '["Poslije nastave djeca idu u produženi boravak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('roditeljski sastanak', 'roditeljski sastanak', 'hr', 'phrase', 'A1', 'батьківські збори', 'collocation', '{}'::jsonb, '["Roditeljski sastanak je u četvrtak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('naknada', 'naknada', 'hr', 'noun', 'A1', 'плата; комісія; компенсація', 'core', '{"gender": "f"}'::jsonb, '["Banka uzima malu naknadu za podizanje novca."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('IBAN', 'iban', 'hr', 'noun', 'A1', 'IBAN (номер банківського рахунку)', 'core', '{"gender": "m"}'::jsonb, '["Pošaljite mi svoj IBAN."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('PIN', 'pin', 'hr', 'noun', 'A1', 'PIN-код', 'core', '{"gender": "m"}'::jsonb, '["Nikome ne govorite svoj PIN."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('blokiran', 'blokiran', 'hr', 'adjective', 'A1', 'заблокований', 'core', '{}'::jsonb, '["Račun je privremeno blokiran."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odblokirati', 'odblokirati', 'hr', 'verb', 'A1', 'розблокувати', 'core', '{"aspect": "pfv"}'::jsonb, '["Karticu možete odblokirati u aplikaciji."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;

-- 2. Виправлення словника (стара версія — у content_versions)
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('luk') and ukrainian_translation = 'цибуля / часник';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «цибуля / часник» → «цибуля»');
  update public.lexemes set ukrainian_translation = 'цибуля' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «цибуля / часник» → «цибуля»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('slobodno vrijeme') and ukrainian_translation = 'віільний час';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «віільний час» → «вільний час»');
  update public.lexemes set ukrainian_translation = 'вільний час' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «віільний час» → «вільний час»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('uho') and ukrainian_translation = 'вхо';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «вхо» → «вухо»');
  update public.lexemes set ukrainian_translation = 'вухо' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «вхо» → «вухо»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('polica') and ukrainian_translation = 'страховий поліс';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «страховий поліс» → «полиця; страховий поліс»');
  update public.lexemes set ukrainian_translation = 'полиця; страховий поліс' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «страховий поліс» → «полиця; страховий поліс»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('spremati') and ukrainian_translation = 'зберігати';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «зберігати» → «прибирати; готувати; зберігати»');
  update public.lexemes set ukrainian_translation = 'прибирати; готувати; зберігати' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «зберігати» → «прибирати; готувати; зберігати»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('kraj') and ukrainian_translation = 'кінець';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «кінець» → «кінець; край, місцевість»');
  update public.lexemes set ukrainian_translation = 'кінець; край, місцевість' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «кінець» → «кінець; край, місцевість»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('hladno') and ukrainian_translation = 'холодне';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «холодне» → «холодно; холодне»');
  update public.lexemes set ukrainian_translation = 'холодно; холодне' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «холодне» → «холодно; холодне»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('dokaz') and ukrainian_translation = 'доказ';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «доказ» → «доказ; підтвердження»');
  update public.lexemes set ukrainian_translation = 'доказ; підтвердження' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «доказ» → «доказ; підтвердження»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('mobilno bankarstvo') and ukrainian_translation = 'Мобільний банкінг';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «Мобільний банкінг» → «мобільний банкінг»');
  update public.lexemes set ukrainian_translation = 'мобільний банкінг' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «Мобільний банкінг» → «мобільний банкінг»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('prtljažnik') and ukrainian_translation = 'Багажник';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «Багажник» → «багажник»');
  update public.lexemes set ukrainian_translation = 'багажник' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «Багажник» → «багажник»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('živjeli') and ukrainian_translation = 'Будьмо! (Тост)';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «Будьмо! (Тост)» → «будьмо! (тост)»');
  update public.lexemes set ukrainian_translation = 'будьмо! (тост)' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «Будьмо! (Тост)» → «будьмо! (тост)»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lemma = 'Vozačka dozvola';
  if v_id is null then return; end if;  -- уже виправлено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: лема «Vozačka dozvola» → «vozačka dozvola»');
  update public.lexemes set lemma = 'vozačka dozvola' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: лема «Vozačka dozvola» → «vozačka dozvola»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lemma = 'Mobilno bankarstvo';
  if v_id is null then return; end if;  -- уже виправлено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: лема «Mobilno bankarstvo» → «mobilno bankarstvo»');
  update public.lexemes set lemma = 'mobilno bankarstvo' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: лема «Mobilno bankarstvo» → «mobilno bankarstvo»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lemma = 'Prtljažnik';
  if v_id is null then return; end if;  -- уже виправлено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: лема «Prtljažnik» → «prtljažnik»');
  update public.lexemes set lemma = 'prtljažnik' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: лема «Prtljažnik» → «prtljažnik»');
end $$;

-- 3. Граматика A1: правила з прикладами (теми публікуються в частині 2)
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '40151a44-ae08-5a62-906c-f1687e499720', '387f7bea-839e-56ae-bbfd-213aacbe7c26', 'Дієслова на -am: čitati', 'Більшість дієслів на -ati мають закінчення -am, -aš, -a, -amo, -ate, -aju.', 'čitam, čitaš, čita, čitamo, čitate, čitaju', '[{"hr": "Čitam knjigu.", "ua": "Я читаю книжку."}, {"hr": "Gdje radiš?", "ua": "Де ти працюєш?"}, {"hr": "Oni gledaju film.", "ua": "Вони дивляться фільм."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '07ac2a81-2cc1-5d4f-bb3d-7847ab7a8ffd', '387f7bea-839e-56ae-bbfd-213aacbe7c26', 'Дієслова на -im: govoriti', 'Дієслова на -iti і частина на -jeti мають закінчення -im, -iš, -i, -imo, -ite, -e.', 'govorim, govoriš, govori, govorimo, govorite, govore', '[{"hr": "Govorim malo hrvatski.", "ua": "Я трохи говорю хорватською."}, {"hr": "Kada ručaš?", "ua": "Коли ти обідаєш?"}, {"hr": "Oni žive u Splitu.", "ua": "Вони живуть у Спліті."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'ecc08256-b531-5fc1-83ea-92473592fbaa', '387f7bea-839e-56ae-bbfd-213aacbe7c26', 'Дієслова на -em: pisati, piti, doručkovati', 'Решта дієслів мають -em, -eš, -e, -emo, -ete, -u. Основа часто змінюється: pisati → pišem, piti → pijem, doručkovati → doručkujem.', 'pišem, pišeš, piše, pišemo, pišete, pišu', '[{"hr": "Pijem kavu bez šećera.", "ua": "Я п’ю каву без цукру."}, {"hr": "Doručkujem u sedam.", "ua": "Я снідаю о сьомій."}, {"hr": "Što pišeš?", "ua": "Що ти пишеш?"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '54f5c417-a734-51fb-a128-1cc620ed6c30', '318b394b-c622-5dd6-8494-4c1472b6df62', 'Інфінітив: -ti або -ći', 'У словнику дієслова стоять в інфінітиві: raditi, gledati, ići, moći. Від нього утворюємо теперішній час.', 'gledati → gledam · raditi → radim', '[{"hr": "Volim gledati filmove.", "ua": "Я люблю дивитися фільми."}, {"hr": "Želim raditi ovdje.", "ua": "Я хочу працювати тут."}, {"hr": "Moram ići.", "ua": "Мені треба йти."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '318b394b-c622-5dd6-8494-4c1472b6df62')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'e2b038a6-5c04-5753-ae96-79a675c75f57', '318b394b-c622-5dd6-8494-4c1472b6df62', 'Дієслово + інфінітив', 'Після voljeti, željeti, htjeti, moći, morati друге дієслово стоїть в інфінітиві — як в українській.', 'Volim + plivati', '[{"hr": "Volim plivati.", "ua": "Я люблю плавати."}, {"hr": "Želimo kuhati zajedno.", "ua": "Ми хочемо готувати разом."}, {"hr": "Učim govoriti hrvatski.", "ua": "Я вчуся говорити хорватською."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '318b394b-c622-5dd6-8494-4c1472b6df62')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '052e29e6-98b5-5fc8-bd83-5a3703f2dde1', '318b394b-c622-5dd6-8494-4c1472b6df62', 'Питання і заперечення', 'Питання: дієслово + li (Čitaš li?). Заперечення: ne перед дієсловом (Ne čitam).', 'Gledaš li? · Ne gledam.', '[{"hr": "Gledaš li seriju?", "ua": "Ти дивишся серіал?"}, {"hr": "Ne gledam, čitam.", "ua": "Не дивлюся, читаю."}, {"hr": "Kuhate li doma?", "ua": "Ви готуєте вдома?"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '318b394b-c622-5dd6-8494-4c1472b6df62')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '18d86872-bbd7-58b8-a968-97cbd9fe8eed', '6ba7fa0f-46cc-5679-85bb-23c1329bfa18', 'Ići — іти, їхати', 'Ići означає і «йти», і «їхати». Теперішній час: idem, ideš, ide, idemo, idete, idu.', 'idem, ideš, ide, idemo, idete, idu', '[{"hr": "Idem na posao.", "ua": "Я йду на роботу."}, {"hr": "Idemo autobusom.", "ua": "Ми їдемо автобусом."}, {"hr": "Kamo ideš?", "ua": "Куди ти йдеш?"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '6dfda313-836e-5098-a7b3-80c045d487d8', '6ba7fa0f-46cc-5679-85bb-23c1329bfa18', 'Htjeti і moći', 'Htjeti (хотіти): hoću, hoćeš, hoće, hoćemo, hoćete, hoće. Moći (могти): mogu, možeš, može, možemo, možete, mogu. Після них — інфінітив або li-питання: Hoćeš li…? Mogu li…?', 'hoću · mogu', '[{"hr": "Hoćeš li kavu?", "ua": "Хочеш кави?"}, {"hr": "Danas ne mogu.", "ua": "Сьогодні я не можу."}, {"hr": "Možete li ponoviti?", "ua": "Можете повторити?"}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '7e64b6d4-0e82-5c5e-a1cf-ff8f0ac03012', '6ba7fa0f-46cc-5679-85bb-23c1329bfa18', 'Jesti і piti', 'Jesti (їсти): jedem, jedeš, jede, jedemo, jedete, jedu. Piti (пити): pijem, piješ, pije, pijemo, pijete, piju. Основа змінюється — форми треба запам’ятати.', 'jedem · pijem', '[{"hr": "Što jedeš?", "ua": "Що ти їси?"}, {"hr": "Pijemo vodu.", "ua": "Ми п’ємо воду."}, {"hr": "Djeca jedu voće.", "ua": "Діти їдять фрукти."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '3691ec21-3052-5fab-91d7-bc13629aa97a', '0db658cb-b2ed-5719-bced-f95a93cf15ce', 'Жіночий рід: -a → -u', 'Іменники жіночого роду на -a мають -u — як в українській: «кава — каву».', 'kava → kavu · juha → juhu', '[{"hr": "Želim kavu.", "ua": "Я хочу каву."}, {"hr": "Jedem juhu.", "ua": "Я їм суп."}, {"hr": "Imam sestru.", "ua": "У мене є сестра."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '3d5ae2cf-932d-55a0-adda-09523c6b6993', '0db658cb-b2ed-5719-bced-f95a93cf15ce', 'Чоловічий рід: неживе не змінюється, живе → -a', 'Неживі іменники чоловічого роду не змінюються: Trebam ključ. Живі отримують -a: Čekam prijatelja. Середній рід не змінюється.', 'ključ → ključ · prijatelj → prijatelja', '[{"hr": "Trebam ključ.", "ua": "Мені потрібен ключ."}, {"hr": "Čekam prijatelja.", "ua": "Я чекаю друга."}, {"hr": "Naručujem vino.", "ua": "Я замовляю вино."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'f2fb8e78-785a-5cf3-855e-156ebfffa954', '0db658cb-b2ed-5719-bced-f95a93cf15ce', 'Займенники: me, te, ga, je', 'Короткі форми: me (мене), te (тебе), ga (його), je (її), nas, vas, ih. «Boli me glava» — дослівно «болить мене голова».', 'Boli me glava. · Vidim te.', '[{"hr": "Boli me grlo.", "ua": "У мене болить горло."}, {"hr": "Volim te.", "ua": "Я тебе люблю."}, {"hr": "Zovem ga sutra.", "ua": "Я подзвоню йому завтра."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '92f89436-6b06-551f-b319-34715c0c9d5b', 'f891e65a-d7be-5542-ae6e-dbee5bfe415c', 'Де? — u / na + місцевий', 'Чоловічий і середній рід: -u (u gradu, na moru). Жіночий рід на -a: -i (u kući, na plaži).', 'grad → u gradu · plaža → na plaži', '[{"hr": "Živim u Zagrebu.", "ua": "Я живу в Загребі."}, {"hr": "Ona je na poslu.", "ua": "Вона на роботі."}, {"hr": "Čekam na stanici.", "ua": "Я чекаю на зупинці."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'd233f971-d086-5069-9713-49dab2159f35', 'f891e65a-d7be-5542-ae6e-dbee5bfe415c', 'U чи na?', 'U — всередині (u stanu, u trgovini). Na — на поверхні, на відкритому місці й у сталих виразах (na moru, na poslu, na tržnici, na otoku).', 'u trgovini · na tržnici', '[{"hr": "Kupujem u trgovini.", "ua": "Я купую в магазині."}, {"hr": "Voće je na tržnici.", "ua": "Фрукти — на ринку."}, {"hr": "Ljeti smo na otoku.", "ua": "Влітку ми на острові."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '678aa2e5-cc44-5e58-bb6e-148782e8076e', 'f891e65a-d7be-5542-ae6e-dbee5bfe415c', 'O + місцевий: про кого, про що', 'Після o (про) теж місцевий відмінок: pričamo o poslu.', 'o poslu · o Hrvatskoj', '[{"hr": "Pričamo o filmu.", "ua": "Ми говоримо про фільм."}, {"hr": "Čitam o Hrvatskoj.", "ua": "Я читаю про Хорватію."}, {"hr": "Knjiga je o moru.", "ua": "Книжка про море."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '6677f562-23a4-558a-9ccf-cf154ed81bab', 'd27ae527-a8d6-512f-acd2-a6cfec39c01f', 'Кількість + родовий', 'Після слів кількості (kilogram, boca, malo, puno) — родовий: жіночий рід -a → -e, чоловічий і середній отримують -a.', 'voda → boca vode · sir → malo sira', '[{"hr": "Bocu vode, molim.", "ua": "Пляшку води, будь ласка."}, {"hr": "Kilogram grožđa.", "ua": "Кілограм винограду."}, {"hr": "Malo šećera?", "ua": "Трохи цукру?"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '59347e30-33da-5e33-8bb0-e9cabb0a801b', 'd27ae527-a8d6-512f-acd2-a6cfec39c01f', 'Nema + родовий', 'Nema — «немає»: nema mlijeka. Nemam — «у мене немає»: nemam vremena.', 'nema + mlijeka', '[{"hr": "Nema tople vode.", "ua": "Немає гарячої води."}, {"hr": "Nemam vremena.", "ua": "У мене немає часу."}, {"hr": "Danas nema kruha.", "ua": "Сьогодні немає хліба."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '2cdc36c9-1c4e-579f-b815-132a0d48feca', 'd27ae527-a8d6-512f-acd2-a6cfec39c01f', 'Iz, od, do, kod, preko puta + родовий', 'Після цих прийменників — родовий: iz Ukrajine, do centra, kod liječnika, preko puta pošte.', 'iz Ukrajine · do centra · kod banke', '[{"hr": "Ja sam iz Ukrajine.", "ua": "Я з України."}, {"hr": "Idem do centra.", "ua": "Я їду до центру."}, {"hr": "Bankomat je kod banke.", "ua": "Банкомат біля банку."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'a59cc0ae-f9c0-5703-bfd6-98c7c7dc81b6', '94ab9b5e-95b0-5edb-8322-52293bdb5d05', 'Naš, vaš', 'Naš — наш, vaš — ваш. Закінчення — як у прикметника: naš stan, naša kuća, naše dijete. «Vaš» у ввічливому звертанні пишемо з великої: Vaš.', 'naš · naša · naše', '[{"hr": "Ovo je naš stan.", "ua": "Це наша квартира."}, {"hr": "Je li ovo Vaša torba?", "ua": "Це ваша сумка?"}, {"hr": "Naše dijete ide u vrtić.", "ua": "Наша дитина ходить у садок."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '8d340287-844c-512a-bc71-5526a79f7972', '94ab9b5e-95b0-5edb-8322-52293bdb5d05', 'Njegov, njezin, njihov', 'Njegov — його, njezin — її, njihov — їхній. Закінчення залежить від того, що належить: njezin brat, njezina sestra.', 'njegov · njezina · njihovo', '[{"hr": "To je njegov auto.", "ua": "Це його машина."}, {"hr": "Njezina mama je liječnica.", "ua": "Її мама — лікарка."}, {"hr": "Njihova djeca su u školi.", "ua": "Їхні діти в школі."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'a4f85731-c2b1-5b6a-80b6-e882bf118063', '94ab9b5e-95b0-5edb-8322-52293bdb5d05', 'Čiji? — чий?', 'Питання: čiji (чий), čija (чия), čije (чиє).', 'Čiji je ovo kofer?', '[{"hr": "Čiji je ovo ključ?", "ua": "Чий це ключ?"}, {"hr": "Čija je ovo jakna?", "ua": "Чия це куртка?"}, {"hr": "Moja!", "ua": "Моя!"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'e91eedbd-788e-538a-af75-508e4aa4c06d', '61247c65-c284-51c5-a9ed-1626afbd77ac', 'Moći — могти', 'Mogu, možeš, može… «Mogu li…?» — ввічливе прохання: «Можна…?»', 'Mogu li platiti karticom?', '[{"hr": "Mogu li probati?", "ua": "Можна поміряти?"}, {"hr": "Ne mogu doći.", "ua": "Я не можу прийти."}, {"hr": "Možete li mi pomoći?", "ua": "Можете мені допомогти?"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'd11240eb-be89-5de7-a23f-e95094302ddc', '61247c65-c284-51c5-a9ed-1626afbd77ac', 'Morati і trebati', 'Moram — я мушу, мені треба. Trebam + іменник — мені потрібне щось: trebam liječnika.', 'Moram ići. · Trebam vrećicu.', '[{"hr": "Moram raditi.", "ua": "Я мушу працювати."}, {"hr": "Trebam pomoć.", "ua": "Мені потрібна допомога."}, {"hr": "Moraš li danas raditi?", "ua": "Тобі сьогодні треба працювати?"}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'a703e2b8-1680-5ce4-bc63-263dc7968b76', '61247c65-c284-51c5-a9ed-1626afbd77ac', 'Smjeti — можна (дозвіл)', 'Smijem, smiješ, smije… «Smijem li?» — «чи можна мені?». «Ne smijete» — «вам не можна».', 'Smijem li ući? · Ne smijete pušiti.', '[{"hr": "Smijem li ući?", "ua": "Можна увійти?"}, {"hr": "Ovdje ne smijete parkirati.", "ua": "Тут не можна паркуватися."}, {"hr": "Djeca ne smiju plivati sama.", "ua": "Дітям не можна плавати самим."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '92d8b179-0b0d-5147-9851-b314799a2a39', '45c5cb39-daf7-5dab-8413-9a5302b33553', 'Ти: -i / -j', 'Прохання до однієї людини на «ти»: čekati → čekaj, dodati → dodaj, uzeti → uzmi, doći → dođi.', 'Dodaj sol! · Dođi!', '[{"hr": "Čekaj me!", "ua": "Зачекай мене!"}, {"hr": "Dodaj malo soli.", "ua": "Додай трохи солі."}, {"hr": "Dođi u nedjelju!", "ua": "Приходь у неділю!"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'a39d68a6-c8bf-5e01-ad04-4c1dc4b69a4d', '45c5cb39-daf7-5dab-8413-9a5302b33553', 'Ви: -ite / -jte', 'До кількох людей або ввічливо: čekajte, uzmite, izvolite, ispunite.', 'Uzmite · Pijte · Izvolite', '[{"hr": "Uzmite jednu tabletu.", "ua": "Прийміть одну таблетку."}, {"hr": "Pijte puno vode.", "ua": "Пийте багато води."}, {"hr": "Pričekajte malo, molim.", "ua": "Зачекайте трохи, будь ласка."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'b3c4bdb0-89b8-5862-9e75-df0ee53d16eb', '45c5cb39-daf7-5dab-8413-9a5302b33553', 'Не роби: nemoj / nemojte + інфінітив', 'Заборона або порада «не роби»: nemoj (ти), nemojte (ви) + інфінітив.', 'Nemoj kasniti! · Nemojte pušiti.', '[{"hr": "Nemoj zaboraviti ključ!", "ua": "Не забудь ключ!"}, {"hr": "Nemojte parkirati ovdje.", "ua": "Не паркуйтеся тут."}, {"hr": "Nemoj se brinuti.", "ua": "Не хвилюйся."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '1f00b1c7-432b-59a3-a501-3b0f09c4fec1', 'b58103b4-a259-5384-aa65-ffc0e2a195c8', 'Вищий ступінь: -iji, -ji', 'Jeftin → jeftiniji, topao → topliji, skup → skuplji. Неправильні: velik → veći, mali → manji, dobar → bolji, loš → gori.', 'jeftin → jeftiniji · dobar → bolji', '[{"hr": "Ova jakna je jeftinija.", "ua": "Ця куртка дешевша."}, {"hr": "Ovaj stan je veći.", "ua": "Ця квартира більша."}, {"hr": "Kava je ovdje bolja.", "ua": "Кава тут краща."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '2ce7b65f-71a8-506c-9f1f-0d419cfad61b', 'b58103b4-a259-5384-aa65-ffc0e2a195c8', 'Ніж: nego', 'Порівняння: X je … nego Y.', 'Danas je toplije nego jučer.', '[{"hr": "Split je topliji nego Zagreb.", "ua": "Спліт тепліший, ніж Загреб."}, {"hr": "Vlak je sporiji nego autobus.", "ua": "Поїзд повільніший, ніж автобус."}, {"hr": "Danas je hladnije nego jučer.", "ua": "Сьогодні холодніше, ніж учора."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '02d95098-1270-5676-9014-268a1731d748', 'b58103b4-a259-5384-aa65-ffc0e2a195c8', 'Найвищий ступінь: naj-', 'Naj- + вищий ступінь: najbolji, najjeftiniji, najveći.', 'najbolji · najljepši', '[{"hr": "Ovo je najbolja pekara.", "ua": "Це найкраща пекарня."}, {"hr": "Ljeto je najtoplije.", "ua": "Літо найтепліше."}, {"hr": "Koja je najjeftinija?", "ua": "Яка найдешевша?"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '2b222d54-3708-5ce5-9e35-fab772d62efc', '1435d343-6721-5eb7-8dc2-af7f9a027716', 'Питання з li', 'Питання «так / ні»: дієслово + li: Imate li…? Možete li…? З «je»: Je li…?', 'Imate li vremena? · Je li daleko?', '[{"hr": "Imate li sobu?", "ua": "У вас є кімната?"}, {"hr": "Je li ovo Vaš kofer?", "ua": "Це ваша валіза?"}, {"hr": "Govorite li engleski?", "ua": "Ви говорите англійською?"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'a24dbd9c-93ee-58fc-adb3-440ec7a9b904', '1435d343-6721-5eb7-8dc2-af7f9a027716', 'Питальні слова', 'Kada? — коли? Koliko? — скільки? Zašto? — чому? Kako? — як? Odakle? — звідки? Kamo? — куди?', 'Kada polazi vlak?', '[{"hr": "Koliko traje vožnja?", "ua": "Скільки триває поїздка?"}, {"hr": "Zašto učiš hrvatski?", "ua": "Чому ти вчиш хорватську?"}, {"hr": "Odakle ste?", "ua": "Звідки ви?"}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'f775c72c-254d-5d58-9db1-b79d7cea6196', '1435d343-6721-5eb7-8dc2-af7f9a027716', 'Koji і kakav — який?', 'Koji — який саме, з кількох: koji autobus? Kakav — який на вигляд, за якістю: kakvo je vrijeme?', 'Koji autobus? · Kakvo vrijeme?', '[{"hr": "Koji vlak ide u Split?", "ua": "Який поїзд їде до Спліта?"}, {"hr": "Kakvo je vrijeme danas?", "ua": "Яка сьогодні погода?"}, {"hr": "Kakav je stan?", "ua": "Яка квартира?"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '3f86e34f-45ba-5f5e-94ac-285743798fda', 'b89a9004-2c03-567a-b23e-31db18f92dea', 'Ne + дієслово', 'Ne ставимо перед дієсловом: ne razumijem, ne radi.', 'ne + radi', '[{"hr": "Mobitel ne radi.", "ua": "Телефон не працює."}, {"hr": "Ne pijem kavu.", "ua": "Я не п’ю каву."}, {"hr": "Ne znam.", "ua": "Я не знаю."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = 'b89a9004-2c03-567a-b23e-31db18f92dea')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '343f5db5-566c-5ade-a8f5-549243c8a5b8', 'b89a9004-2c03-567a-b23e-31db18f92dea', 'Nisam, nemam, neću, nema', 'Деякі дієслова зливаються з ne: nisam (я не…), nemam (не маю), neću (не хочу), nema (немає).', 'nisam · nemam · neću', '[{"hr": "Nisam umoran.", "ua": "Я не втомлений."}, {"hr": "Nemam vremena.", "ua": "У мене немає часу."}, {"hr": "Neću kavu, hvala.", "ua": "Я не хочу кави, дякую."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = 'b89a9004-2c03-567a-b23e-31db18f92dea')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '046da53a-fb5c-5816-81b8-e1ae9ba551f3', 'b89a9004-2c03-567a-b23e-31db18f92dea', 'Подвійне заперечення', 'Як в українській: ništa, nitko, nikad, nigdje + ne: Nitko ne zna. Nikad ne kasnim.', 'Ništa ne vidim.', '[{"hr": "Nitko ne zna.", "ua": "Ніхто не знає."}, {"hr": "Nikad ne kasnim.", "ua": "Я ніколи не запізнююся."}, {"hr": "Ništa mi se ne sviđa.", "ua": "Мені нічого не подобається."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = 'b89a9004-2c03-567a-b23e-31db18f92dea')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'd9fde9a0-a876-5b33-817b-c6d9ab56e820', '765ac66f-d54b-505b-9b11-c48e5ad26018', 'I, a, ali', 'I — і; a — а (протиставлення: «я — так, а ти…»); ali — але.', 'Ja pijem čaj, a ti kavu.', '[{"hr": "Stan je mali, ali lijep.", "ua": "Квартира мала, але гарна."}, {"hr": "Ja radim, a on spava.", "ua": "Я працюю, а він спить."}, {"hr": "Imam brata i sestru.", "ua": "У мене є брат і сестра."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '765ac66f-d54b-505b-9b11-c48e5ad26018')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '3ae30ad9-f446-576b-95a5-4f7e1461b204', '765ac66f-d54b-505b-9b11-c48e5ad26018', 'Ili — або, чи', 'Ili — вибір: kava ili čaj?', 'X ili Y?', '[{"hr": "Kava ili čaj?", "ua": "Кава чи чай?"}, {"hr": "Platite karticom ili gotovinom.", "ua": "Заплатіть карткою або готівкою."}, {"hr": "Danas ili sutra?", "ua": "Сьогодні чи завтра?"}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '765ac66f-d54b-505b-9b11-c48e5ad26018')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '1862eaaa-050d-5596-a6b0-c6b3dc64d2f6', '765ac66f-d54b-505b-9b11-c48e5ad26018', 'Jer, zato što — бо, тому що', 'Причина: jer і zato što. Питання — zašto?', 'Zašto? — Zato što…', '[{"hr": "Učim hrvatski jer živim ovdje.", "ua": "Я вчу хорватську, бо живу тут."}, {"hr": "Ne idem, zato što sam umorna.", "ua": "Я не йду, тому що втомилася."}, {"hr": "Sviđa mi se jer je tiho.", "ua": "Мені подобається, бо тут тихо."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '765ac66f-d54b-505b-9b11-c48e5ad26018')
on conflict (id) do nothing;

-- 4. Юніти модулів A1 (модулі публікуються в частині 2)
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '893000a6-3e62-528c-8ecf-e644f677823c', m.id, 'Мій день', 'Moj dan', '["Розповісти про свій день", "Сказати, що ви робите у вихідні", "Сказати, як часто ви щось робите"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 1
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '54c21ee3-db66-5d1e-9eca-7223a2e6f6e4', m.id, 'Їжа і ресторани', 'Hrana i restorani', '["Замовити страву в ресторані", "Приготувати просту страву за рецептом", "Купити продукти на ринку"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 2
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '480b3ca1-58c7-5b6f-8a52-eff47d53b3e4', m.id, 'Покупки', 'Kupovina', '["Порівняти речі за ціною і розміром", "Сказати, що вам треба купити", "Повернути або обміняти товар"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 3
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '72a3eec1-fb04-5e99-a0ea-da4f6bc07ed5', m.id, 'Транспорт', 'Prijevoz', '["Купити квиток і зробити пересадку", "Дізнатися розклад поїздів", "Пройти реєстрацію в аеропорту"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 4
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select 'c80b7070-95f0-54de-b4dd-90d024f5b830', m.id, 'Житло', 'Stanovanje', '["Знайти квартиру й запитати про умови", "Пояснити, що в квартирі не працює", "Познайомитися із сусідом"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 5
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '874caaa6-f5e5-5c4f-acf4-cfdb0e510116', m.id, 'Робота', 'Posao', '["Розповісти про свою роботу", "Зрозуміти правила на роботі", "Пройти просту співбесіду"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 6
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '2eec2289-6a8a-5fb2-9988-e52433d5a242', m.id, 'Здоров’я', 'Zdravlje', '["Записатися до лікаря", "Купити ліки й зрозуміти, як їх приймати", "Розповісти про своє самопочуття"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 7
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '0df70119-403a-517e-af33-8073d14fca03', m.id, 'Друзі й вільний час', 'Društveni život', '["Запросити когось і відповісти на запрошення", "Розповісти про свої хобі", "Висловити думку і пояснити чому"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 8
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '704b6312-30cc-5a3c-94ff-c2a2dfd1b17c', m.id, 'Хорватія', 'Hrvatska', '["Поговорити про погоду", "Поїхати на острів поромом", "Розповісти про свята своєї родини"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 9
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '90bce36b-b9de-5168-b120-49d8e33aa6cf', m.id, 'Підсумок A1', 'Ponavljanje A1', '["Розповісти про себе", "Впоратися на пошті й у банку", "Поговорити про своє життя в Хорватії"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 10
on conflict do nothing;

-- 5. Уроки A1, частина 1
-- A1.1 · урок 1: Мій звичайний день
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '4bf48151-be83-5108-bc92-645c0603a1a3';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.1: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.1.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 1: Мій звичайний день', 'Lekcija 1: Moj običan dan', '["Розповісти, коли ви встаєте й лягаєте спати", "Назвати щоденні справи", "Змінювати дієслова в теперішньому часі"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'buditi se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ustajati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tuširati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'doručkovati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'raditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ručati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'večerati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spavati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obično', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svaki dan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rano', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kasno', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '51cddd7d-7232-5856-9611-9a0af94bcba9', 'fill_in_the_blank', 'Ja se ___ u šest.', 'budim', '["budim", "budiš", "budimo", "budi"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8f588e91-b18f-517e-aaf1-870199b5865f', 'multiple_choice', 'Що означає «rano»?', 'рано', '["пізно", "рано", "обідати", "вечеряти"]'::jsonb, 'A1', 2, 'PUBLISHED', 'rano', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd0147081-5d55-5e3e-98ce-894a3b0a8db4', 'multiple_choice', 'Що означає «ustajati»?', 'вставати (прокидатися і підніматися)', '["приймати душ", "вставати (прокидатися і підніматися)", "працювати, робити", "рано"]'::jsonb, 'A1', 3, 'PUBLISHED', 'ustajati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '05749173-d0b3-5c26-93ef-bce6861ab292', 'multiple_choice', 'Як хорватською «зазвичай»?', 'obično', '["kasno", "buditi se", "tuširati se", "obično"]'::jsonb, 'A1', 4, 'PUBLISHED', 'obično', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1373f322-9db9-55f0-9f6f-2f8a04a35e3f', 'type_answer', 'Напишіть хорватською: «вечеряти»', 'večerati', null, 'A1', 5, 'PUBLISHED', 'večerati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e9d5fd7c-f239-5d34-93ca-765e79316767', 'type_answer', 'Напишіть хорватською: «снідати»', 'doručkovati', null, 'A1', 6, 'PUBLISHED', 'doručkovati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fb2c9477-fd59-51ae-a1bf-a3df6b0ec13b', 'sentence_builder', 'Складіть: «Спочатку приймаю душ, потім снідаю.»', 'Prvo se tuširam, onda doručkujem.', '["doručkujem.", "se", "onda", "Prvo", "tuširam,"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b8cd99ee-448d-5291-8343-227f48099b9c', 'sentence_builder', 'Складіть: «Обідаю на роботі.»', 'Ručam na poslu.', '["poslu.", "na", "Ručam"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e54b0f29-90c0-550e-9b8f-827962a4b07d', 'listening', 'Прослухайте і складіть фразу', 'Budim se u šest i pol.', '["pol.", "i", "u", "šest", "se", "Budim"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '089e554a-43a2-516d-b867-9807f51ef14b', 'listening', 'Прослухайте і складіть фразу', 'Ne, večeramo u sedam.', '["večeramo", "Ne,", "sedam.", "u"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '18513d05-5595-5813-bac7-bf72760e5353', 'speaking', 'Я прокидаюся о сьомій.', 'Budim se u sedam.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '737c71b1-4f4a-5fb0-b294-292f11094ea6', 'speaking', 'Зазвичай я обідаю о дванадцятій.', 'Obično ručam u dvanaest.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b257ea30-5241-541b-8ca8-5e0711eaf75b', v_lesson, 'Ранок Тараса', 'Tarasovo jutro', 1011, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('7465c771-034a-57c8-8c23-592d6135b3c4', 'b257ea30-5241-541b-8ca8-5e0711eaf75b', 'Ana', 'Kada se obično budiš?', 'Коли ти зазвичай прокидаєшся?', 1);
  perform pg_temp.turn('ab56ed36-adc8-5645-a650-0b119ffdb071', 'b257ea30-5241-541b-8ca8-5e0711eaf75b', 'Taras', 'Budim se u šest i pol.', 'Я прокидаюся о пів на сьому.', 2);
  perform pg_temp.turn('f60c1f45-103b-52b5-8aba-1ea1bf979530', 'b257ea30-5241-541b-8ca8-5e0711eaf75b', 'Ana', 'Tako rano! Zašto?', 'Так рано! Чому?', 3);
  perform pg_temp.turn('57e55006-7cca-55d7-9956-906974e9a0d7', 'b257ea30-5241-541b-8ca8-5e0711eaf75b', 'Taras', 'Radim od osam. Prvo se tuširam, onda doručkujem.', 'Я працюю з восьмої. Спочатку приймаю душ, потім снідаю.', 4);
  perform pg_temp.turn('57d5cd65-4009-5213-a94c-50b2e9462f6a', 'b257ea30-5241-541b-8ca8-5e0711eaf75b', 'Ana', 'A kada ideš spavati?', 'А коли ти лягаєш спати?', 5);
  perform pg_temp.turn('ab4c1707-24c1-515f-a2a4-aec80efca643', 'b257ea30-5241-541b-8ca8-5e0711eaf75b', 'Taras', 'Obično u jedanaest.', 'Зазвичай об одинадцятій.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9045e6af-47b3-515c-87ad-ea5864d940de', v_lesson, 'Робочий день Олени', 'Olenin radni dan', 1012, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('50ab2c0d-da30-585c-bbc0-9167748c2c09', '9045e6af-47b3-515c-87ad-ea5864d940de', 'Marija', 'Gdje ručaš?', 'Де ти обідаєш?', 1);
  perform pg_temp.turn('f7b9a119-fdb4-52a0-86c8-d8316f4b8395', '9045e6af-47b3-515c-87ad-ea5864d940de', 'Olena', 'Ručam na poslu, u dvanaest.', 'Обідаю на роботі, о дванадцятій.', 2);
  perform pg_temp.turn('364674ed-85f3-5dbe-8c8d-3dbac4b0dea2', '9045e6af-47b3-515c-87ad-ea5864d940de', 'Marija', 'Kada završavaš?', 'Коли ти закінчуєш?', 3);
  perform pg_temp.turn('6aead209-20ef-534a-9261-c59aa5ba1bf5', '9045e6af-47b3-515c-87ad-ea5864d940de', 'Olena', 'U četiri. Onda kuham večeru.', 'О четвертій. Потім готую вечерю.', 4);
  perform pg_temp.turn('2a1c9519-a195-5fca-b096-4948697755bb', '9045e6af-47b3-515c-87ad-ea5864d940de', 'Marija', 'Večeraš li kasno?', 'Ти пізно вечеряєш?', 5);
  perform pg_temp.turn('0032f60f-3104-5b00-9233-80b084deb7a7', '9045e6af-47b3-515c-87ad-ea5864d940de', 'Olena', 'Ne, večeramo u sedam.', 'Ні, ми вечеряємо о сьомій.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 2: Вихідні
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '458b73de-d6b3-5bd3-98ad-c243a2fff03f';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.1: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '318b394b-c622-5dd6-8494-4c1472b6df62';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.1.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 2: Вихідні', 'Lekcija 2: Vikend', '["Розповісти, що ви робите у вихідні", "Запитати про плани друга", "Сказати, що ви любите робити"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'vikend', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gledati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čitati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šetati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kuhati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slušati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glazba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'film', v_pos);
  v_pos := pg_temp.word(v_lesson, 'knjiga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odmarati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'park', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijatelj', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bef58b13-44f9-595c-9652-e9de604fdec9', 'fill_in_the_blank', 'Mi ___ film.', 'gledamo', '["gledaju", "gledamo", "gledaš", "gledam"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9778c444-680c-52d3-b840-00a36ed19167', 'multiple_choice', 'Що означає «šetati»?', 'прогулюватися / гуляти', '["книга", "відпочивати", "прогулюватися / гуляти", "фільм"]'::jsonb, 'A1', 2, 'PUBLISHED', 'šetati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be626c63-382a-53db-85b7-e6091a4a7aaf', 'multiple_choice', 'Що означає «prijatelj»?', 'друг', '["слухати", "дивитися", "читати", "друг"]'::jsonb, 'A1', 3, 'PUBLISHED', 'prijatelj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ac7fca54-6e3e-5506-958e-aa9b16c9a21f', 'multiple_choice', 'Як хорватською «музика»?', 'glazba', '["čitati", "glazba", "knjiga", "film"]'::jsonb, 'A1', 4, 'PUBLISHED', 'glazba', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '80a29f6a-7651-5dca-a932-5355285f0abe', 'type_answer', 'Напишіть хорватською: «фільм»', 'film', null, 'A1', 5, 'PUBLISHED', 'film', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4c263e95-960f-53f1-91a2-f6877ef66d9c', 'type_answer', 'Напишіть хорватською: «слухати»', 'slušati', null, 'A1', 6, 'PUBLISHED', 'slušati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f185e99-9083-5401-a3bc-9b1745d8f5e9', 'sentence_builder', 'Складіть: «Зранку гуляю в парку.»', 'Ujutro šetam u parku.', '["šetam", "u", "parku.", "Ujutro"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '92c20a0d-4d1e-5380-9171-5f54a2ce4a4a', 'sentence_builder', 'Складіть: «Готую і слухаю музику.»', 'Kuham i slušam glazbu.', '["i", "Kuham", "glazbu.", "slušam"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ff46d092-8009-551a-81c3-635b4e9ff655', 'listening', 'Прослухайте і складіть фразу', 'Što radiš u subotu?', '["radiš", "subotu?", "u", "Što"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '95baebc5-46b3-53a6-83d1-402c0773e91f', 'listening', 'Прослухайте і складіть фразу', 'Koju glazbu slušaš?', '["Koju", "slušaš?", "glazbu"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'df8001d8-0985-50ef-8968-0ee6f76e4465', 'speaking', 'Що ти робиш у суботу?', 'Što radiš u subotu?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4e2ce2f5-1d45-5e9e-8136-eb683287c2da', 'speaking', 'Я читаю книжку.', 'Čitam knjigu.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7c220f4a-7621-5bb8-8846-e09bc7d4b653', v_lesson, 'Плани на суботу', 'Planovi za subotu', 1021, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('ebba57ee-f502-55f0-b2ca-b8a0a3b58a17', '7c220f4a-7621-5bb8-8846-e09bc7d4b653', 'Ivan', 'Što radiš u subotu?', 'Що ти робиш у суботу?', 1);
  perform pg_temp.turn('aa51d8f4-f589-5036-97bc-61f2d29864b0', '7c220f4a-7621-5bb8-8846-e09bc7d4b653', 'Iryna', 'Ujutro šetam u parku, a popodne čitam.', 'Зранку гуляю в парку, а після обіду читаю.', 2);
  perform pg_temp.turn('498a1418-232f-53d0-b82d-e496a8dad5e7', '7c220f4a-7621-5bb8-8846-e09bc7d4b653', 'Ivan', 'Što čitaš?', 'Що ти читаєш?', 3);
  perform pg_temp.turn('0c5f8db7-7147-5b32-9a81-473c2ea1e3bd', '7c220f4a-7621-5bb8-8846-e09bc7d4b653', 'Iryna', 'Knjigu na hrvatskom. Polako, ali čitam!', 'Книжку хорватською. Повільно, але читаю!', 4);
  perform pg_temp.turn('770df97f-4d6b-56b8-b40b-7a5264782bc7', '7c220f4a-7621-5bb8-8846-e09bc7d4b653', 'Ivan', 'Bravo! Ja gledam film s prijateljima.', 'Браво! А я дивлюся фільм із друзями.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('14f7df31-c5a5-5701-a656-b7060da94b74', v_lesson, 'Спокійні вихідні', 'Miran vikend', 1022, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('0580d871-233c-564d-9026-cb66a66ded0c', '14f7df31-c5a5-5701-a656-b7060da94b74', 'Petra', 'Kako provodiš vikend?', 'Як ти проводиш вихідні?', 1);
  perform pg_temp.turn('f1f530d4-82ec-5372-b97c-acb70a4e7781', '14f7df31-c5a5-5701-a656-b7060da94b74', 'Andrij', 'Odmaram se. Kuham i slušam glazbu.', 'Відпочиваю. Готую і слухаю музику.', 2);
  perform pg_temp.turn('059e4bf1-8ac7-5cf7-8238-7576359ae1c3', '14f7df31-c5a5-5701-a656-b7060da94b74', 'Petra', 'Koju glazbu slušaš?', 'Яку музику ти слухаєш?', 3);
  perform pg_temp.turn('ae60691d-c415-5e40-9f55-4ee3bab9d16e', '14f7df31-c5a5-5701-a656-b7060da94b74', 'Andrij', 'Hrvatsku i ukrajinsku.', 'Хорватську й українську.', 4);
  perform pg_temp.turn('2fbe8eb3-d1d7-5ce1-8d0a-b2c5647acfa5', '14f7df31-c5a5-5701-a656-b7060da94b74', 'Petra', 'I ja volim hrvatsku glazbu!', 'Я теж люблю хорватську музику!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 3: Як часто?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '959e879f-a28d-5bed-9c09-16cff91ef456';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.1: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.1.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 3: Як часто?', 'Lekcija 3: Koliko često?', '["Сказати, як часто ви щось робите", "Розповісти про спорт і їжу", "Вживати дієслова ići, jesti, piti, moći, htjeti"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'uvijek', v_pos);
  v_pos := pg_temp.word(v_lesson, 'često', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponekad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rijetko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nikad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ići', v_pos);
  v_pos := pg_temp.word(v_lesson, 'piti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jesti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'htjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'moći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trčati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sport', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '700e5d09-f7aa-5284-9d43-ff53b84a6bac', 'fill_in_the_blank', 'Ja ___ u grad.', 'idem', '["idu", "ideš", "idem", "ide"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cf2068ba-cbfe-539f-b3c7-4b7a18ea0422', 'multiple_choice', 'Що означає «sport»?', 'спорт', '["спорт", "пити", "іноді / часом", "могти"]'::jsonb, 'A1', 2, 'PUBLISHED', 'sport', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8f44eed3-ee1d-59fb-b047-c4359f16f964', 'multiple_choice', 'Що означає «moći»?', 'могти', '["ніколи", "могти", "завжди", "спорт"]'::jsonb, 'A1', 3, 'PUBLISHED', 'moći', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0e259b82-ef3a-58d3-b7df-7c277ffc7886', 'multiple_choice', 'Як хорватською «їсти»?', 'jesti', '["često", "ponekad", "jesti", "rijetko"]'::jsonb, 'A1', 4, 'PUBLISHED', 'jesti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9c8459b6-940b-56c5-a7ef-c584902c824e', 'type_answer', 'Напишіть хорватською: «ніколи»', 'nikad', null, 'A1', 5, 'PUBLISHED', 'nikad', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e5726227-8ccd-518a-a3c9-fdc3ca58aaaa', 'type_answer', 'Напишіть хорватською: «бігати»', 'trčati', null, 'A1', 6, 'PUBLISHED', 'trčati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e3f1f1e6-4f55-592f-af2d-3b0ce4db6259', 'sentence_builder', 'Складіть: «Ходжу двічі на тиждень.»', 'Idem dva puta tjedno.', '["dva", "tjedno.", "puta", "Idem"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9810be7e-a70f-5624-aa23-ce6f72ef990b', 'sentence_builder', 'Складіть: «Зазвичай я п’ю чай.»', 'Obično pijem čaj.', '["pijem", "čaj.", "Obično"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f4ac5e9e-4406-57c1-ab2d-80ee7471b60e', 'listening', 'Прослухайте і складіть фразу', 'Ja trčim svaki dan, ujutro.', '["Ja", "dan,", "trčim", "svaki", "ujutro."]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'df5d2152-80ad-5a68-aae6-ad0e54f4ec68', 'listening', 'Прослухайте і складіть фразу', 'Uvijek jedem kruh i jaja.', '["kruh", "i", "jaja.", "Uvijek", "jedem"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '48af1a74-d053-5fca-a8d3-3a8b01df3a0e', 'speaking', 'Я часто ходжу в парк.', 'Često idem u park.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c23bc9a5-d812-517c-ab47-fc4bcdde3796', 'speaking', 'Я ніколи не п’ю каву.', 'Nikad ne pijem kavu.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b719021b-6485-5ac7-b85d-366c14029fcd', v_lesson, 'Спорт', 'Sport', 1031, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('7d52d23f-5f11-58c5-8ca0-65e4e6b33a71', 'b719021b-6485-5ac7-b85d-366c14029fcd', 'Luka', 'Ideš li često na trening?', 'Ти часто ходиш на тренування?', 1);
  perform pg_temp.turn('3569afc3-6d0f-5f43-ba64-19d1eae8f9cc', 'b719021b-6485-5ac7-b85d-366c14029fcd', 'Oksana', 'Idem dva puta tjedno. A ti?', 'Ходжу двічі на тиждень. А ти?', 2);
  perform pg_temp.turn('2ba71fe7-dcdd-55e2-8b0b-01791225f172', 'b719021b-6485-5ac7-b85d-366c14029fcd', 'Luka', 'Ja trčim svaki dan, ujutro.', 'Я бігаю щодня, зранку.', 3);
  perform pg_temp.turn('686afda5-e743-587e-bc4b-212c56c7c98c', 'b719021b-6485-5ac7-b85d-366c14029fcd', 'Oksana', 'Svaki dan? Ja to ne mogu!', 'Щодня? Я так не можу!', 4);
  perform pg_temp.turn('57263962-a5be-54a7-aded-027c23923644', 'b719021b-6485-5ac7-b85d-366c14029fcd', 'Luka', 'Možeš! Hoćeš li trčati sa mnom?', 'Можеш! Хочеш бігати зі мною?', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('884a5a61-45b8-5b11-93a4-dff5ab4bb0be', v_lesson, 'Кава чи чай?', 'Kava ili čaj?', 1032, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('45d2e7a5-4d67-5c33-86af-3b6e90f7e8c0', '884a5a61-45b8-5b11-93a4-dff5ab4bb0be', 'Marta', 'Piješ li kavu?', 'Ти п’єш каву?', 1);
  perform pg_temp.turn('89a4d0bf-ae4b-5142-8768-4535d17e6adb', '884a5a61-45b8-5b11-93a4-dff5ab4bb0be', 'Taras', 'Rijetko. Obično pijem čaj.', 'Рідко. Зазвичай я п’ю чай.', 2);
  perform pg_temp.turn('059e220d-6df9-5013-8157-04f9186443e7', '884a5a61-45b8-5b11-93a4-dff5ab4bb0be', 'Marta', 'A što jedeš za doručak?', 'А що ти їси на сніданок?', 3);
  perform pg_temp.turn('5b1b9f08-de02-50d9-9ea8-d8ae1d93dc02', '884a5a61-45b8-5b11-93a4-dff5ab4bb0be', 'Taras', 'Uvijek jedem kruh i jaja.', 'Я завжди їм хліб і яйця.', 4);
  perform pg_temp.turn('ec110dec-02cc-595e-a4f8-132c3c5fe364', '884a5a61-45b8-5b11-93a4-dff5ab4bb0be', 'Marta', 'Ja nikad ne jedem ujutro.', 'А я ніколи не їм зранку.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 4: Домашні справи
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '9c38f909-9275-5194-9a6e-f799c6e416ce';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.1: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.1.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 4: Домашні справи', 'Lekcija 4: Kućanski poslovi', '["Розподілити домашні справи", "Назвати, хто що робить удома", "Вживати prati, čistiti, usisavati в теперішньому часі"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kućanski poslovi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čistiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'usisavati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'peglati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spremati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'suđe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rublje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iznositi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cimerica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pomagati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prašina', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '3218e589-0ba3-5603-a17a-ae9ec3d699a0', 'fill_in_the_blank', 'Tata ___ suđe.', 'pere', '["perem", "pere", "peru", "pereš"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2b0649ae-3e7a-5a8a-861f-39e9e02018c3', 'multiple_choice', 'Що означає «kućanski poslovi»?', 'домашні справи', '["пилососити", "домашні справи", "прибирати; готувати; зберігати", "виносити"]'::jsonb, 'A1', 2, 'PUBLISHED', 'kućanski poslovi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '69585e77-3d3f-5a05-905a-ee5e798ae255', 'multiple_choice', 'Що означає «usisavati»?', 'пилососити', '["пилососити", "прасувати", "прибирати; готувати; зберігати", "білизна (для прання)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'usisavati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4b79d1e0-dfeb-5feb-8ac2-21f75e8672db', 'multiple_choice', 'Як хорватською «допомагати»?', 'pomagati', '["pomagati", "prati", "peglati", "prašina"]'::jsonb, 'A1', 4, 'PUBLISHED', 'pomagati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '48ff61fb-e8b1-520a-ab59-f74ea629f284', 'type_answer', 'Напишіть хорватською: «мити / прати»', 'prati', null, 'A1', 5, 'PUBLISHED', 'prati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '78cbd093-4a32-546a-9b17-3c0281127797', 'type_answer', 'Напишіть хорватською: «посуд»', 'suđe', null, 'A1', 6, 'PUBLISHED', 'suđe', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a00f34d-e4d6-569d-b3b3-e1723a31bd09', 'sentence_builder', 'Складіть: «Ти пилососиш кімнати.»', 'Ti usisavaš sobe.', '["usisavaš", "Ti", "sobe."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9202fa2c-2e09-5d3a-acbc-d03d31b24652', 'sentence_builder', 'Складіть: «Я перу білизну й прасую.»', 'Ja perem rublje i peglam.', '["peglam.", "rublje", "perem", "Ja", "i"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fed6efb0-033f-589a-b1e6-3711de3a3ca8', 'listening', 'Прослухайте і складіть фразу', 'Danas je subota. Čistimo stan!', '["Danas", "stan!", "Čistimo", "subota.", "je"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c266c2ff-e584-528f-a8aa-6c809eb7f7f7', 'listening', 'Прослухайте і складіть фразу', 'I iznosiš smeće?', '["I", "smeće?", "iznosiš"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '65b1adc4-abc6-52d1-bc97-56460656ddae', 'speaking', 'Я мию посуд.', 'Perem suđe.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0f52a311-8606-5249-92c6-32b6c104b42e', 'speaking', 'Хто прибирає кухню?', 'Tko sprema kuhinju?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cbbe13fb-d190-5755-b414-a88db7351083', v_lesson, 'Субота вдома', 'Subota kod kuće', 1041, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('3af6c813-f667-56bf-b7f1-05e48a7093a2', 'cbbe13fb-d190-5755-b414-a88db7351083', 'Mama', 'Danas je subota. Čistimo stan!', 'Сьогодні субота. Прибираємо квартиру!', 1);
  perform pg_temp.turn('ed571ed5-722a-5df8-bd41-c4805a032c65', 'cbbe13fb-d190-5755-b414-a88db7351083', 'Sin', 'Opet? Što ja radim?', 'Знову? А що роблю я?', 2);
  perform pg_temp.turn('13f40c6b-ba14-5705-b0ec-7c537da01308', 'cbbe13fb-d190-5755-b414-a88db7351083', 'Mama', 'Ti usisavaš sobe, a tata pere suđe.', 'Ти пилососиш кімнати, а тато миє посуд.', 3);
  perform pg_temp.turn('8a844170-b88b-5220-ac6f-9d006a95015a', 'cbbe13fb-d190-5755-b414-a88db7351083', 'Sin', 'A ti?', 'А ти?', 4);
  perform pg_temp.turn('c7f245a8-69be-5bf3-b687-406759ea6f46', 'cbbe13fb-d190-5755-b414-a88db7351083', 'Mama', 'Ja perem rublje i peglam.', 'Я перу білизну й прасую.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('915d9951-0f5e-518d-86b1-0eeb5f45495f', v_lesson, 'Сусідка по квартирі', 'Cimerica', 1042, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('a8a93dd7-2c68-54af-bcd7-a8700554cbdf', '915d9951-0f5e-518d-86b1-0eeb5f45495f', 'Olena', 'Tko danas sprema kuhinju?', 'Хто сьогодні прибирає кухню?', 1);
  perform pg_temp.turn('165bed66-00a0-5f71-9a2a-70aa14f72506', '915d9951-0f5e-518d-86b1-0eeb5f45495f', 'Lana', 'Ja spremam kuhinju ponedjeljkom i srijedom.', 'Я прибираю кухню по понеділках і середах.', 2);
  perform pg_temp.turn('a3a5fab1-4943-5cab-af11-fa65a5e9dde0', '915d9951-0f5e-518d-86b1-0eeb5f45495f', 'Olena', 'Dobro, onda ja čistim kupaonicu i brišem prašinu.', 'Добре, тоді я мию ванну й витираю пил.', 3);
  perform pg_temp.turn('31d3dda6-81b8-505d-95ac-784b17287fb3', '915d9951-0f5e-518d-86b1-0eeb5f45495f', 'Lana', 'I iznosiš smeće?', 'І виносиш сміття?', 4);
  perform pg_temp.turn('78dae8d1-e317-5b7c-96df-0975531b1d14', '915d9951-0f5e-518d-86b1-0eeb5f45495f', 'Olena', 'Može. Hvala ti što pomažeš!', 'Добре. Дякую, що допомагаєш!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 5: Збираємося зранку
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '54f17cf7-3c17-5978-b400-b6b6888c9f84';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.1: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.1.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 5: Збираємося зранку', 'Lekcija 5: Jutarnje spremanje', '["Попросити дитину вмитися й одягнутися", "Назвати речі у ванній", "Вживати наказовий спосіб: umij se, obuci se"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'umiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oprati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zub', v_pos);
  v_pos := pg_temp.word(v_lesson, 'četkica za zube', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sapun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ručnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obući se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'češljati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žuriti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brzo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spreman', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vani', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2da1eb38-2c23-56ac-9790-d808905e0308', 'fill_in_the_blank', '___ zube, molim te!', 'Operi', '["Pere", "Oprati", "Operi", "Perem"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6f411e7d-3c03-5e3b-861e-e4483218ac17', 'multiple_choice', 'Що означає «obući se»?', 'одягнутися', '["поспішати", "рушник", "надворі", "одягнутися"]'::jsonb, 'A1', 2, 'PUBLISHED', 'obući se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd8b21aa9-69f6-55aa-996d-915d5d7b8ecb', 'multiple_choice', 'Що означає «spreman»?', 'готовий', '["зубна щітка", "мило", "умитися", "готовий"]'::jsonb, 'A1', 3, 'PUBLISHED', 'spreman', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1b0b8ec7-cea9-5e69-8e09-1561a165e64f', 'multiple_choice', 'Як хорватською «причісуватися»?', 'češljati se', '["češljati se", "ručnik", "sapun", "oprati"]'::jsonb, 'A1', 4, 'PUBLISHED', 'češljati se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '519193c5-5b31-58ba-b85f-2daf829341a5', 'type_answer', 'Напишіть хорватською: «рушник»', 'ručnik', null, 'A1', 5, 'PUBLISHED', 'ručnik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '69625641-dc23-5c47-84fb-397261614f21', 'type_answer', 'Напишіть хорватською: «надворі»', 'vani', null, 'A1', 6, 'PUBLISHED', 'vani', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f9c97067-b05a-5c4d-8e28-2e4d0195ac1a', 'sentence_builder', 'Складіть: «Де моя зубна щітка?»', 'Gdje je moja četkica za zube?', '["je", "za", "Gdje", "zube?", "moja", "četkica"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '058d9056-7afe-574f-baf1-c163ebc86926', 'sentence_builder', 'Складіть: «Вдягни сині штани.»', 'Obuci plave hlače.', '["plave", "hlače.", "Obuci"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1a74ecbe-d9ff-56a9-8eb1-a55133aea3af', 'listening', 'Прослухайте і складіть фразу', 'U kupaonici, pored sapuna. Brzo!', '["kupaonici,", "pored", "U", "sapuna.", "Brzo!"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be27d30c-9ea4-5004-962f-42cfef211d22', 'listening', 'Прослухайте і складіть фразу', 'Spreman sam!', '["sam!", "Spreman"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5872b4e7-14e7-5b3b-aa24-087fa630d800', 'speaking', 'Мені треба поспішати.', 'Moram se žuriti.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '409860e0-d2ce-5d50-989b-11762a16820f', 'speaking', 'Де рушник?', 'Gdje je ručnik?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('41d1fcde-eee7-5dcb-b733-c0c42fa651f9', v_lesson, 'Вставай!', 'Ustani!', 1051, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('3f8952a4-89ce-505d-86e0-9376f2e137cd', '41d1fcde-eee7-5dcb-b733-c0c42fa651f9', 'Mama', 'Dino, ustani! Kasnimo!', 'Діно, вставай! Ми запізнюємося!', 1);
  perform pg_temp.turn('a76f3a7a-dafa-5e4e-8cf7-2a36b4fd840f', '41d1fcde-eee7-5dcb-b733-c0c42fa651f9', 'Dino', 'Još pet minuta, molim te.', 'Ще п’ять хвилин, будь ласка.', 2);
  perform pg_temp.turn('bb021269-08dc-56da-8741-fcb87cae8772', '41d1fcde-eee7-5dcb-b733-c0c42fa651f9', 'Mama', 'Ne! Umij se i operi zube.', 'Ні! Умийся й почисть зуби.', 3);
  perform pg_temp.turn('33611345-69e9-53e5-b271-070058636184', '41d1fcde-eee7-5dcb-b733-c0c42fa651f9', 'Dino', 'Gdje je moja četkica za zube?', 'Де моя зубна щітка?', 4);
  perform pg_temp.turn('a0dc461b-068b-5b8f-b7dd-84f37c396175', '41d1fcde-eee7-5dcb-b733-c0c42fa651f9', 'Mama', 'U kupaonici, pored sapuna. Brzo!', 'У ванній, біля мила. Швидко!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c57e5b9d-bdd9-59c3-aad1-b597214a0681', v_lesson, 'Що вдягнути?', 'Što obući?', 1052, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('385ae438-83b5-5ec8-bef6-0fc0a5f8f219', 'c57e5b9d-bdd9-59c3-aad1-b597214a0681', 'Dino', 'Mama, što da obučem?', 'Мамо, що мені вдягнути?', 1);
  perform pg_temp.turn('7cbe840e-eaab-5132-8d55-39e4685ef8e7', 'c57e5b9d-bdd9-59c3-aad1-b597214a0681', 'Mama', 'Obuci plave hlače i bijelu majicu.', 'Вдягни сині штани й білу футболку.', 2);
  perform pg_temp.turn('a5ffd6c8-ae25-57cf-95cb-ede4e5402162', 'c57e5b9d-bdd9-59c3-aad1-b597214a0681', 'Dino', 'A jaknu?', 'А куртку?', 3);
  perform pg_temp.turn('86a4cb96-ab36-5cf5-a5cb-96f60cc86b2f', 'c57e5b9d-bdd9-59c3-aad1-b597214a0681', 'Mama', 'Da, vani je hladno. Počešljaj se i idemo!', 'Так, надворі холодно. Причешися — і ходімо!', 4);
  perform pg_temp.turn('cf62bd78-66f7-5150-81cf-075cd0d6f910', 'c57e5b9d-bdd9-59c3-aad1-b597214a0681', 'Dino', 'Spreman sam!', 'Я готовий!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 6: Столик на двох
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '5e4a1c56-3931-58bb-81af-cb598966da77';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.2: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.2.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 6: Столик на двох', 'Lekcija 6: Stol za dvoje', '["Забронювати столик", "Замовити закуску, основну страву і напій", "Вживати знахідний відмінок: juhu, ribu, salatu"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'restoran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rezervirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jelovnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predjelo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glavno jelo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'desert', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naručiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'juha', v_pos);
  v_pos := pg_temp.word(v_lesson, 'riba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'salata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vino', v_pos);
  v_pos := pg_temp.word(v_lesson, 'račun', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '3ca18091-c017-55ac-ac74-db6cc55f1a7d', 'fill_in_the_blank', 'Želim ___, molim.', 'juhu', '["juhom", "juhu", "juhe", "juha"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c0491339-dce7-5cd4-94b4-d1e64c9bded0', 'multiple_choice', 'Що означає «vino»?', 'вино', '["головна страва", "закуска", "вино", "меню"]'::jsonb, 'A1', 2, 'PUBLISHED', 'vino', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c5b63813-b43e-5c2d-ad0b-a62279a130f2', 'multiple_choice', 'Що означає «desert»?', 'десерт', '["суп / юшка", "головна страва", "замовити", "десерт"]'::jsonb, 'A1', 3, 'PUBLISHED', 'desert', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e0487cef-20ad-5062-a923-bed0076168d9', 'multiple_choice', 'Як хорватською «ресторан»?', 'restoran', '["riba", "salata", "predjelo", "restoran"]'::jsonb, 'A1', 4, 'PUBLISHED', 'restoran', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd7a69b44-7029-52c8-9da8-95e91b6658a2', 'type_answer', 'Напишіть хорватською: «забронювати»', 'rezervirati', null, 'A1', 5, 'PUBLISHED', 'rezervirati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1118d499-a5e5-5363-b8fc-554f6a542589', 'type_answer', 'Напишіть хорватською: «замовити»', 'naručiti', null, 'A1', 6, 'PUBLISHED', 'naručiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '46412f32-28a5-5361-9ec9-cb2d6ad7c4c6', 'sentence_builder', 'Складіть: «Я хочу забронювати столик на двох.»', 'Želim rezervirati stol za dvoje.', '["rezervirati", "stol", "Želim", "za", "dvoje."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0d0f8b02-1bfb-5013-a826-ed3d523aa322', 'sentence_builder', 'Складіть: «Тільки рахунок, будь ласка.»', 'Samo račun, molim.', '["molim.", "račun,", "Samo"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '97dd09d5-a3b7-5b96-83fe-7b7a0cb6c483', 'listening', 'Прослухайте і складіть фразу', 'Za petak u osam.', '["petak", "osam.", "u", "Za"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9f2a0afc-fca6-56ce-a35b-d1c1b72b390a', 'listening', 'Прослухайте і складіть фразу', 'Želite li desert?', '["li", "desert?", "Želite"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'abfad817-51d9-57ab-b87f-fea531cda18c', 'speaking', 'Я хочу рибу і салат.', 'Želim ribu i salatu.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '34e56167-26f8-518a-bccc-4bd1f7f853ec', 'speaking', 'Можна меню?', 'Mogu li dobiti jelovnik?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8b18710c-9d6f-5b9d-bed3-755a930d4963', v_lesson, 'Бронювання', 'Rezervacija', 1061, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('94830879-e88b-5d8a-af9f-8ae00981bc15', '8b18710c-9d6f-5b9d-bed3-755a930d4963', 'Konobar', 'Restoran Lavanda, izvolite.', 'Ресторан «Лаванда», слухаю.', 1);
  perform pg_temp.turn('93a5ffe1-8fcf-58ef-8b7d-4a0fc8022aef', '8b18710c-9d6f-5b9d-bed3-755a930d4963', 'Andrij', 'Dobar dan. Želim rezervirati stol za dvoje.', 'Добрий день. Я хочу забронювати столик на двох.', 2);
  perform pg_temp.turn('58288cf0-c3f6-54d1-8aa5-98f0f3b2293b', '8b18710c-9d6f-5b9d-bed3-755a930d4963', 'Konobar', 'Za kada?', 'На коли?', 3);
  perform pg_temp.turn('e8991c69-a1e1-57b0-80e3-2c0f9b603c8a', '8b18710c-9d6f-5b9d-bed3-755a930d4963', 'Andrij', 'Za petak u osam.', 'На п’ятницю на восьму.', 4);
  perform pg_temp.turn('4c42a128-8317-52b5-86de-9e44b9204da5', '8b18710c-9d6f-5b9d-bed3-755a930d4963', 'Konobar', 'U redu. Na koje ime?', 'Добре. На яке ім’я?', 5);
  perform pg_temp.turn('cb2cc3c4-ba32-5b25-aa41-e490bce0d992', '8b18710c-9d6f-5b9d-bed3-755a930d4963', 'Andrij', 'Na ime Kovalenko.', 'На ім’я Коваленко.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('301ad81c-8cb3-5aaa-b933-fc0b5875b593', v_lesson, 'Замовлення', 'Narudžba', 1062, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('64f46d36-13e2-509e-b9a5-e9f989ac3246', '301ad81c-8cb3-5aaa-b933-fc0b5875b593', 'Konobarica', 'Što želite naručiti?', 'Що бажаєте замовити?', 1);
  perform pg_temp.turn('58c76d25-2d8d-5fa5-a34c-5202a7704725', '301ad81c-8cb3-5aaa-b933-fc0b5875b593', 'Iryna', 'Za predjelo juhu, a za glavno jelo ribu.', 'На закуску суп, а на основну страву рибу.', 2);
  perform pg_temp.turn('d2e4a418-a299-557e-917b-aff33a7b958f', '301ad81c-8cb3-5aaa-b933-fc0b5875b593', 'Konobarica', 'A za piće?', 'А що питимете?', 3);
  perform pg_temp.turn('4d7d57fd-bcf8-5b4c-918d-83088c07f496', '301ad81c-8cb3-5aaa-b933-fc0b5875b593', 'Iryna', 'Čašu bijelog vina, molim.', 'Келих білого вина, будь ласка.', 4);
  perform pg_temp.turn('b812f7b6-4438-53c7-8371-e4dbd4f83d1f', '301ad81c-8cb3-5aaa-b933-fc0b5875b593', 'Konobarica', 'Želite li desert?', 'Бажаєте десерт?', 5);
  perform pg_temp.turn('764a2c1e-0a9b-5ba6-b3cc-19f89c20722d', '301ad81c-8cb3-5aaa-b933-fc0b5875b593', 'Iryna', 'Ne, hvala. Samo račun, molim.', 'Ні, дякую. Тільки рахунок, будь ласка.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 7: Готуємо вдома
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '3e652232-866b-5edf-ac05-d61ee7a325fe';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.2: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.2.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 7: Готуємо вдома', 'Lekcija 7: Kuhamo kod kuće', '["Зрозуміти простий рецепт", "Попросити щось подати чи принести", "Вживати наказовий спосіб: dodaj, donesi"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kuhati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ulje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'papar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'luk', v_pos);
  v_pos := pg_temp.word(v_lesson, 'češnjak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rajčica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tjestenina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tanjur', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vilica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žlica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nož', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '1ca90b02-c1e8-54df-8f97-0a068c941509', 'fill_in_the_blank', '___ sol, molim te!', 'Dodaj', '["Dodati", "Dodaj", "Dodam", "Doda"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd40d32d-161b-5f5b-b2c3-f3bb2789f070', 'multiple_choice', 'Що означає «ulje»?', 'олія', '["сіль", "олія", "часник", "ніж"]'::jsonb, 'A1', 2, 'PUBLISHED', 'ulje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '250cc7cb-ec9c-5cb0-88ec-09531b618f4a', 'multiple_choice', 'Що означає «kuhati»?', 'варити / готувати їжу', '["перець", "цибуля", "ложка", "варити / готувати їжу"]'::jsonb, 'A1', 3, 'PUBLISHED', 'kuhati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8f523e27-c2f6-51e6-ab05-ec2318ad5332', 'multiple_choice', 'Як хорватською «цибуля»?', 'luk', '["sol", "tanjur", "luk", "rajčica"]'::jsonb, 'A1', 4, 'PUBLISHED', 'luk', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd894989a-83bf-5eba-9a6a-eb8c3ecfdc24', 'type_answer', 'Напишіть хорватською: «помідор»', 'rajčica', null, 'A1', 5, 'PUBLISHED', 'rajčica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '230e3f8f-21ba-57d5-8504-244b18ea356e', 'type_answer', 'Напишіть хорватською: «тарілка»', 'tanjur', null, 'A1', 6, 'PUBLISHED', 'tanjur', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b8b5e742-391f-5d81-9cc8-2d9fc0a111cd', 'sentence_builder', 'Складіть: «Наріж цибулю й часник.»', 'Nareži luk i češnjak.', '["Nareži", "i", "češnjak.", "luk"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '960f75df-6c41-550b-97dd-051894c25426', 'sentence_builder', 'Складіть: «Будь ласка, принеси тарілки.»', 'Molim te, donesi tanjure.', '["donesi", "Molim", "tanjure.", "te,"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8beb42ce-f2e2-5d7f-8d74-cf159ba5b1a8', 'listening', 'Прослухайте і складіть фразу', 'Prvo zakuhaj vodu.', '["zakuhaj", "Prvo", "vodu."]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ee0a6cba-ef57-5219-85cb-946501c76ada', 'listening', 'Прослухайте і складіть фразу', 'Pazi, vruće je!', '["Pazi,", "je!", "vruće"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0c1756f3-fcf0-5a62-8b89-7d204fc738d9', 'speaking', 'Додай сіль, будь ласка.', 'Dodaj sol, molim te.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fc92968e-e9f3-5a30-a89f-5b2339dd1d01', 'speaking', 'Можна скуштувати?', 'Mogu li probati?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('91c0b399-3bf9-53ec-a78f-3758d61bd81a', v_lesson, 'Рецепт пасти', 'Recept za tjesteninu', 1071, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('3f42db1f-6b5b-5ccb-b443-a034ba77a521', '91c0b399-3bf9-53ec-a78f-3758d61bd81a', 'Baka', 'Prvo zakuhaj vodu.', 'Спочатку закип’яти воду.', 1);
  perform pg_temp.turn('9208a6e0-d282-57c7-86f8-641d27fe75f2', '91c0b399-3bf9-53ec-a78f-3758d61bd81a', 'Dino', 'A onda?', 'А потім?', 2);
  perform pg_temp.turn('748887e3-d893-558d-965b-386f1244f2a2', '91c0b399-3bf9-53ec-a78f-3758d61bd81a', 'Baka', 'Nareži luk i češnjak.', 'Наріж цибулю й часник.', 3);
  perform pg_temp.turn('917b571b-39a9-50fb-8d72-80b79c97fb50', '91c0b399-3bf9-53ec-a78f-3758d61bd81a', 'Dino', 'Koliko ulja?', 'Скільки олії?', 4);
  perform pg_temp.turn('e77445d9-43c0-58c2-92b7-14b8bf3bc3c8', '91c0b399-3bf9-53ec-a78f-3758d61bd81a', 'Baka', 'Malo. Dodaj rajčice, sol i papar.', 'Трохи. Додай помідори, сіль і перець.', 5);
  perform pg_temp.turn('459f63df-919c-5aa2-8a2d-22c772cee035', '91c0b399-3bf9-53ec-a78f-3758d61bd81a', 'Dino', 'Mmm, miriše odlično!', 'Ммм, чудово пахне!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a05d1db3-4804-5ea4-86a9-83e3af2c9e4a', v_lesson, 'Накриваємо на стіл', 'Postavljamo stol', 1072, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('3b9b774a-9c68-5f60-8e16-68a45ba18085', 'a05d1db3-4804-5ea4-86a9-83e3af2c9e4a', 'Mama', 'Molim te, donesi tanjure.', 'Будь ласка, принеси тарілки.', 1);
  perform pg_temp.turn('093e44e1-33f6-50ee-8de1-32bb96172c9f', 'a05d1db3-4804-5ea4-86a9-83e3af2c9e4a', 'Sofija', 'Koliko tanjura?', 'Скільки тарілок?', 2);
  perform pg_temp.turn('7abc6787-3b66-5ac8-933b-6463ab3c0a6f', 'a05d1db3-4804-5ea4-86a9-83e3af2c9e4a', 'Mama', 'Četiri. I vilice, noževe i žlice.', 'Чотири. І виделки, ножі й ложки.', 3);
  perform pg_temp.turn('9098fa79-c4b9-562c-896c-7f0154385b42', 'a05d1db3-4804-5ea4-86a9-83e3af2c9e4a', 'Sofija', 'Evo. Mogu li probati?', 'Ось. Можна скуштувати?', 4);
  perform pg_temp.turn('deb1799e-3369-5c5e-a41b-53d241e1247a', 'a05d1db3-4804-5ea4-86a9-83e3af2c9e4a', 'Mama', 'Možeš. Pazi, vruće je!', 'Можна. Обережно, гаряче!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 8: На ринку
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '46a89cf5-41e0-50a2-99b1-f4e66a5ff146';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.2: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.2.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 8: На ринку', 'Lekcija 8: Na tržnici', '["Купити фрукти й овочі на вагу", "Запитати, чи є товар", "Вживати родовий відмінок: kilogram grožđa, boca mlijeka"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'tržnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kilogram', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svježe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'voće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povrće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grožđe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kruška', v_pos);
  v_pos := pg_temp.word(v_lesson, 'breskva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'komad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'boca', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mlijeko', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '7721f275-35e8-54bb-a67b-7839cc6342ef', 'fill_in_the_blank', 'Kilogram ___, molim.', 'grožđa', '["grožđu", "grožđe", "grožđem", "grožđa"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4948b85e-c772-5ad7-8a6a-10c1ef996103', 'multiple_choice', 'Що означає «voće»?', 'фрукти', '["груша", "фрукти", "виноград", "кілограм"]'::jsonb, 'A1', 2, 'PUBLISHED', 'voće', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '41835e1a-f223-5f98-899a-3079bedbdd12', 'multiple_choice', 'Що означає «komad»?', 'шматок, штука', '["кілограм", "груша", "шматок, штука", "овочі"]'::jsonb, 'A1', 3, 'PUBLISHED', 'komad', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b61adec-1b1c-50ca-85ca-d64b8236c97e', 'multiple_choice', 'Як хорватською «сир»?', 'sir', '["sir", "grožđe", "komad", "kilogram"]'::jsonb, 'A1', 4, 'PUBLISHED', 'sir', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7020f443-edfe-5813-bf91-4f3aad04c082', 'type_answer', 'Напишіть хорватською: «ринок / базар»', 'tržnica', null, 'A1', 5, 'PUBLISHED', 'tržnica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '11167aba-4fcc-5191-8866-281fd6a4cbea', 'type_answer', 'Напишіть хорватською: «овочі»', 'povrće', null, 'A1', 6, 'PUBLISHED', 'povrće', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '054d8612-46d2-5f81-aa98-accae1f74029', 'sentence_builder', 'Складіть: «Кілограм винограду, будь ласка.»', 'Kilogram grožđa, molim.', '["molim.", "grožđa,", "Kilogram"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4c2d2fe5-b088-5966-9277-14cd9a582935', 'sentence_builder', 'Складіть: «Один шматок і пляшку молока.»', 'Jedan komad i bocu mlijeka.', '["Jedan", "komad", "mlijeka.", "i", "bocu"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '07f862bd-cf89-5881-8f34-155786616904', 'listening', 'Прослухайте і складіть фразу', 'Izvolite, sve je svježe!', '["svježe!", "sve", "je", "Izvolite,"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8733fae-52de-5622-ba64-11a297ea6e57', 'listening', 'Прослухайте і складіть фразу', 'Mlijeka danas nemam, nažalost.', '["nažalost.", "danas", "Mlijeka", "nemam,"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8ecd3597-e3cf-5c2b-82d6-07984179643d', 'speaking', 'Пляшку води, будь ласка.', 'Bocu vode, molim.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '83cfa532-bdb3-5afa-b8ca-1c5ef57c6783', 'speaking', 'Скільки коштує кілограм?', 'Koliko košta kilogram?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('278e7d05-5ad8-5266-80ae-ded17ba4bcba', v_lesson, 'Фрукти', 'Voće', 1081, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('4bdf0b6c-d785-5744-a8d0-8cccb49d13bf', '278e7d05-5ad8-5266-80ae-ded17ba4bcba', 'Prodavačica', 'Izvolite, sve je svježe!', 'Прошу, усе свіже!', 1);
  perform pg_temp.turn('58cb2e08-817c-5d4d-8276-8821a750d1dc', '278e7d05-5ad8-5266-80ae-ded17ba4bcba', 'Olena', 'Kilogram grožđa i pola kilograma krušaka, molim.', 'Кілограм винограду й півкілограма груш, будь ласка.', 2);
  perform pg_temp.turn('3defb6a2-4fad-5e34-aee3-89858fdaf169', '278e7d05-5ad8-5266-80ae-ded17ba4bcba', 'Prodavačica', 'Još nešto? Breskve su danas jako slatke.', 'Ще щось? Персики сьогодні дуже солодкі.', 3);
  perform pg_temp.turn('ed79eaeb-8370-57cc-a99b-a00862582f0a', '278e7d05-5ad8-5266-80ae-ded17ba4bcba', 'Olena', 'Dobro, i tri breskve.', 'Добре, і три персики.', 4);
  perform pg_temp.turn('1fc592b7-7b33-5bad-9577-754dd57cbf1e', '278e7d05-5ad8-5266-80ae-ded17ba4bcba', 'Prodavačica', 'To je sedam eura.', 'Це сім євро.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f41e10b5-4923-5cb9-b388-c5ea3e85e4d8', v_lesson, 'Сир і молоко', 'Sir i mlijeko', 1082, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('55416bb8-8786-5e7a-895d-12b03f438939', 'f41e10b5-4923-5cb9-b388-c5ea3e85e4d8', 'Kupac', 'Imate li domaćeg sira?', 'У вас є домашній сир?', 1);
  perform pg_temp.turn('8376aef3-2d00-568c-8ff4-d89b8dcda1d8', 'f41e10b5-4923-5cb9-b388-c5ea3e85e4d8', 'Prodavač', 'Imam. Koliko želite?', 'Є. Скільки бажаєте?', 2);
  perform pg_temp.turn('593c1cdc-5a6c-59da-a5af-7717e954bac5', 'f41e10b5-4923-5cb9-b388-c5ea3e85e4d8', 'Kupac', 'Jedan komad. I bocu mlijeka.', 'Один шматок. І пляшку молока.', 3);
  perform pg_temp.turn('76779b5a-026d-522d-b7fd-7c504a1eb023', 'f41e10b5-4923-5cb9-b388-c5ea3e85e4d8', 'Prodavač', 'Mlijeka danas nemam, nažalost.', 'Молока сьогодні, на жаль, немає.', 4);
  perform pg_temp.turn('56c4289f-5bf6-51a0-af94-04394b98b7bc', 'f41e10b5-4923-5cb9-b388-c5ea3e85e4d8', 'Kupac', 'Nema problema. Hvala!', 'Нічого страшного. Дякую!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 9: У кафе й пекарні
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '1e8c2d0e-28f6-5873-aa9f-5d0ad2567fb8';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.2: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.2.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 9: У кафе й пекарні', 'Lekcija 9: U kafiću i pekari', '["Замовити каву, чай і щось солодке", "Купити випічку з собою", "Вживати знахідний відмінок: kavu, jednu kavu"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kafić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šećer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sladoled', v_pos);
  v_pos := pg_temp.word(v_lesson, 'burek', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pecivo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jogurt', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kava za van', v_pos);
  v_pos := pg_temp.word(v_lesson, 'domaći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'konobar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slatko', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '91426657-ee30-55ea-bb5c-8294399728b5', 'fill_in_the_blank', 'Molim jednu ___.', 'kavu', '["kava", "kave", "kavu", "kavom"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c2b34dae-fbd0-5a64-b637-841af985bfaa', 'multiple_choice', 'Що означає «šećer»?', 'цукор', '["кафе / кав''ярня", "домашній", "цукор", "тістечко / пиріг"]'::jsonb, 'A1', 2, 'PUBLISHED', 'šećer', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '649bec92-f455-5128-8389-dea1b7c05c9f', 'multiple_choice', 'Що означає «burek»?', 'бурек (листковий пиріг)', '["офіціант", "йогурт", "кафе / кав''ярня", "бурек (листковий пиріг)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'burek', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1715166b-8c8d-5fe9-a6a7-05068109edea', 'multiple_choice', 'Як хорватською «офіціант»?', 'konobar', '["kava za van", "slatko", "burek", "konobar"]'::jsonb, 'A1', 4, 'PUBLISHED', 'konobar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '062380db-9279-5d43-bd16-7529aae08abc', 'type_answer', 'Напишіть хорватською: «кафе / кав''ярня»', 'kafić', null, 'A1', 5, 'PUBLISHED', 'kafić', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ef540a9a-f8fd-5314-b368-b9bcd8e7f66d', 'type_answer', 'Напишіть хорватською: «йогурт»', 'jogurt', null, 'A1', 6, 'PUBLISHED', 'jogurt', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6753eded-a784-541d-adef-14f78c3ed80c', 'sentence_builder', 'Складіть: «Один бурек із сиром, будь ласка.»', 'Jedan burek sa sirom, molim.', '["molim.", "sa", "sirom,", "burek", "Jedan"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a697b4aa-ebfd-5eb0-8389-e9c77622dd51', 'sentence_builder', 'Складіть: «Цукор на столі.»', 'Šećer je na stolu.', '["je", "stolu.", "na", "Šećer"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7495ac8f-86dd-564f-b69c-aa2ced2d8998', 'listening', 'Прослухайте і складіть фразу', 'Želite li nešto slatko?', '["Želite", "slatko?", "li", "nešto"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c4a4234-0eb3-5286-bbd5-fcdf0d6bfefb', 'listening', 'Прослухайте і складіть фразу', 'Još nešto? Jogurt?', '["nešto?", "Jogurt?", "Još"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '54c1c306-a8b3-500f-9239-3416b676b079', 'speaking', 'Каву з собою, будь ласка.', 'Kavu za van, molim.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cf4237e7-f1ae-57da-a798-3e2573f1f9a3', 'speaking', 'Чай без цукру, будь ласка.', 'Čaj bez šećera, molim.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3a8a259b-c688-54a9-b3f3-2538a7806e6a', v_lesson, 'У кафе', 'U kafiću', 1091, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('f36d094f-dbbc-5c08-bddf-486204e4e31f', '3a8a259b-c688-54a9-b3f3-2538a7806e6a', 'Konobar', 'Dobar dan! Što želite?', 'Добрий день! Що бажаєте?', 1);
  perform pg_temp.turn('cf8e775d-8bfa-55d8-9a3a-c5bba26c116c', '3a8a259b-c688-54a9-b3f3-2538a7806e6a', 'Iryna', 'Jednu kavu s mlijekom i čaj od mente, molim.', 'Одну каву з молоком і м’ятний чай, будь ласка.', 2);
  perform pg_temp.turn('a18ce650-a0b4-5c8d-8817-03a45dfb87ae', '3a8a259b-c688-54a9-b3f3-2538a7806e6a', 'Konobar', 'Želite li nešto slatko? Imamo domaće kolače.', 'Бажаєте щось солодке? У нас домашні тістечка.', 3);
  perform pg_temp.turn('fdd60345-6574-572d-88fa-a08376ff0505', '3a8a259b-c688-54a9-b3f3-2538a7806e6a', 'Iryna', 'Može jedan kolač od čokolade.', 'Можна одне шоколадне тістечко.', 4);
  perform pg_temp.turn('22274622-9e53-53c4-a264-333291df48c6', '3a8a259b-c688-54a9-b3f3-2538a7806e6a', 'Konobar', 'Šećer je na stolu.', 'Цукор на столі.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('954a8b27-5c1e-5e97-a4b9-acff635802cf', v_lesson, 'У пекарні', 'U pekari', 1092, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('c1caefa1-43e1-59ec-9ebc-756a14de29f7', '954a8b27-5c1e-5e97-a4b9-acff635802cf', 'Prodavačica', 'Izvolite?', 'Слухаю вас?', 1);
  perform pg_temp.turn('2c07e20a-a229-51f1-a678-c5d9689200c8', '954a8b27-5c1e-5e97-a4b9-acff635802cf', 'Taras', 'Jedan burek sa sirom i dva peciva, molim.', 'Один бурек із сиром і дві булочки, будь ласка.', 2);
  perform pg_temp.turn('a7958e47-af57-561f-8d15-a6c8cb5a4cc4', '954a8b27-5c1e-5e97-a4b9-acff635802cf', 'Prodavačica', 'Još nešto? Jogurt?', 'Ще щось? Йогурт?', 3);
  perform pg_temp.turn('6280bf4d-1f21-5a9a-894a-5b03092dae52', '954a8b27-5c1e-5e97-a4b9-acff635802cf', 'Taras', 'Da, jedan jogurt. I kavu za van.', 'Так, один йогурт. І каву з собою.', 4);
  perform pg_temp.turn('abc417dd-6f4e-53a0-bb7b-1627191a6ab0', '954a8b27-5c1e-5e97-a4b9-acff635802cf', 'Prodavačica', 'Ukupno pet eura.', 'Разом п’ять євро.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 10: Алергія і смаки
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '6af82dd3-beb1-54cf-9c1b-44ec3cb12a35';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.2: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b89a9004-2c03-567a-b23e-31db18f92dea';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.2.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 10: Алергія і смаки', 'Lekcija 10: Alergija i okusi', '["Сказати, чого ви не їсте", "Повідомити про алергію", "Поскаржитися на страву: надто солоне, гостре"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'alergija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'alergičan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vegetarijanac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'orah', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljut', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kiseo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ukusan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'okus', v_pos);
  v_pos := pg_temp.word(v_lesson, 'previše', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jelo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'donijeti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '6614669c-6ce7-5429-a297-29e36b639717', 'fill_in_the_blank', 'Juha ___ slana.', 'nije', '["ne", "nije", "nema", "nisam"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '62c7a451-c566-5e35-aa75-26c7bc210028', 'multiple_choice', 'Що означає «previše»?', 'надто; забагато', '["алергія", "вегетаріанець", "принести", "надто; забагато"]'::jsonb, 'A1', 2, 'PUBLISHED', 'previše', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2737bc90-56d3-5e74-8549-99a07ab740c1', 'multiple_choice', 'Що означає «orah»?', 'горіх', '["вегетаріанець", "горіх", "алергічний", "смак"]'::jsonb, 'A1', 3, 'PUBLISHED', 'orah', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9bcb35fe-7f7d-5922-859c-f1e815b8ebc8', 'multiple_choice', 'Як хорватською «кислий»?', 'kiseo', '["okus", "jelo", "orah", "kiseo"]'::jsonb, 'A1', 4, 'PUBLISHED', 'kiseo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4e0a3bc0-afe3-5111-b8b6-9e4a492f93b2', 'type_answer', 'Напишіть хорватською: «злий / сердитий»', 'ljut', null, 'A1', 5, 'PUBLISHED', 'ljut', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dabc613c-50da-529d-bce9-33c04263ee31', 'type_answer', 'Напишіть хорватською: «смачний»', 'ukusan', null, 'A1', 6, 'PUBLISHED', 'ukusan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f37f6c6d-d54c-5449-9f6e-44f98ae810f5', 'sentence_builder', 'Складіть: «Я не їм м’яса.»', 'Ja ne jedem meso.', '["meso.", "ne", "Ja", "jedem"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a060c13d-da36-536d-9f59-81ddfea1d3e7', 'sentence_builder', 'Складіть: «Суп надто солоний.»', 'Juha je previše slana.', '["Juha", "slana.", "je", "previše"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '31214492-2a6f-5fea-a901-6f2662ac7209', 'listening', 'Прослухайте і складіть фразу', 'Onda rižoto s povrćem?', '["povrćem?", "rižoto", "Onda", "s"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '037086b4-4106-5697-997a-5e433145d5d3', 'listening', 'Прослухайте і складіть фразу', 'I ovo jelo je jako ljuto.', '["ovo", "jelo", "jako", "I", "ljuto.", "je"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bffdaf1d-3f9f-51d5-a398-80796c4b709b', 'speaking', 'У мене алергія на горіхи.', 'Alergičan sam na orahe.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b9b5606-224c-54c9-bad1-4b6eec7e00d1', 'speaking', 'Це дуже смачно!', 'Ovo je jako ukusno!', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('05dc3e18-d557-56ba-9550-a5317ddf2ddc', v_lesson, 'Я вегетаріанка', 'Ja sam vegetarijanka', 1101, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('bd1937b2-3382-5a49-9caa-08e0984b6cd3', '05dc3e18-d557-56ba-9550-a5317ddf2ddc', 'Konobarica', 'Preporučujem gulaš, jako je ukusan.', 'Раджу гуляш, він дуже смачний.', 1);
  perform pg_temp.turn('2ce3b0cb-b20d-5fc8-922c-19f639cb4d24', '05dc3e18-d557-56ba-9550-a5317ddf2ddc', 'Oksana', 'Hvala, ali ja ne jedem meso. Vegetarijanka sam.', 'Дякую, але я не їм м’яса. Я вегетаріанка.', 2);
  perform pg_temp.turn('96e9fb12-c11e-50b5-9449-2e94c244b597', '05dc3e18-d557-56ba-9550-a5317ddf2ddc', 'Konobarica', 'Onda rižoto s povrćem?', 'Тоді різото з овочами?', 3);
  perform pg_temp.turn('6ed27adc-bdb6-5065-8711-b6d6b4699ef5', '05dc3e18-d557-56ba-9550-a5317ddf2ddc', 'Oksana', 'Može. Ima li u njemu oraha? Alergična sam na orahe.', 'Можна. У ньому є горіхи? У мене алергія на горіхи.', 4);
  perform pg_temp.turn('ef699c5a-8bfa-5105-95a2-62c102b0c39f', '05dc3e18-d557-56ba-9550-a5317ddf2ddc', 'Konobarica', 'Nema, ne brinite.', 'Немає, не хвилюйтеся.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('15a9e1f7-ccaa-5505-b937-5387bb713b9f', v_lesson, 'Надто солоно', 'Previše slano', 1102, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('4d613401-ad6d-5a01-a877-db32af888d74', '15a9e1f7-ccaa-5505-b937-5387bb713b9f', 'Andrij', 'Oprostite, juha je previše slana.', 'Перепрошую, суп надто солоний.', 1);
  perform pg_temp.turn('be0bceb9-c03c-5ace-b8f4-3937e7f7386f', '15a9e1f7-ccaa-5505-b937-5387bb713b9f', 'Konobar', 'Žao mi je! Odmah donosim novu.', 'Мені шкода! Зараз принесу новий.', 2);
  perform pg_temp.turn('0db37a17-9d9b-51b8-b290-c9bf7267fec2', '15a9e1f7-ccaa-5505-b937-5387bb713b9f', 'Andrij', 'I ovo jelo je jako ljuto.', 'І ця страва дуже гостра.', 3);
  perform pg_temp.turn('0381c29a-e075-5369-88af-a357cc736a29', '15a9e1f7-ccaa-5505-b937-5387bb713b9f', 'Konobar', 'Nema problema, mogu ga zamijeniti.', 'Без проблем, можу її замінити.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 11: Яка краща?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '7042ff57-9a20-514a-ab80-71b6f63579f7';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.3: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.3.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 11: Яка краща?', 'Lekcija 11: Koja je bolja?', '["Порівняти дві речі", "Попросити інший розмір", "Вживати вищий ступінь: jeftiniji, veći, bolji"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'jakna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'haljina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'košulja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'traperice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'boja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'veličina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skup', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jeftin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'veliki', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mali', v_pos);
  v_pos := pg_temp.word(v_lesson, 'probati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kabina', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd7da6d66-2a78-5c5d-8b5a-ebda1b218b6a', 'fill_in_the_blank', 'Crna jakna je ___ od plave.', 'toplija', '["topliji", "najtoplija", "toplija", "topla"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a2ae94e-e787-530f-92d8-05f45e406102', 'multiple_choice', 'Що означає «jeftin»?', 'дешевий', '["дешевий", "примірочна / кабінка", "сорочка", "сукня"]'::jsonb, 'A1', 2, 'PUBLISHED', 'jeftin', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5a5f71cc-e61c-542f-83ab-2c21e91a0bac', 'multiple_choice', 'Що означає «jakna»?', 'куртка', '["дешевий", "куртка", "джинси", "примірочна / кабінка"]'::jsonb, 'A1', 3, 'PUBLISHED', 'jakna', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '050e157b-7d64-59d2-afbf-7b337e768cd4', 'multiple_choice', 'Як хорватською «сорочка»?', 'košulja', '["mali", "košulja", "jakna", "haljina"]'::jsonb, 'A1', 4, 'PUBLISHED', 'košulja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ff3b1625-83ad-50d6-b286-76369a8f1308', 'type_answer', 'Напишіть хорватською: «малий»', 'mali', null, 'A1', 5, 'PUBLISHED', 'mali', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '52766e7c-5ecc-5e7a-9328-3d3e3637d000', 'type_answer', 'Напишіть хорватською: «джинси»', 'traperice', null, 'A1', 6, 'PUBLISHED', 'traperice', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5813af54-0628-5a1d-98da-222034a59635', 'sentence_builder', 'Складіть: «Яка куртка краща?»', 'Koja jakna je bolja?', '["bolja?", "Koja", "je", "jakna"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '156231a9-a655-5efd-8d96-fc6bf47fef83', 'sentence_builder', 'Складіть: «У вас є дешевші?»', 'Imate li jeftinije?', '["jeftinije?", "li", "Imate"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2d99654b-5556-5919-9f19-6c053427f726', 'listening', 'Прослухайте і складіть фразу', 'Crna je i skuplja.', '["je", "skuplja.", "i", "Crna"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd329163c-352e-5844-98e1-008bc699ac6a', 'listening', 'Прослухайте і складіть фразу', 'Ove traperice su mi male.', '["male.", "Ove", "traperice", "mi", "su"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fc0e22d1-34f7-5f09-8aa1-2eddaf21949d', 'speaking', 'Ця сукня дешевша.', 'Ova haljina je jeftinija.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '34a3c536-ebe6-5697-927d-f5ee371f5850', 'speaking', 'Можна поміряти?', 'Mogu li probati?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ee6d92cf-eb53-5fb9-8d3b-db7de3ef7033', v_lesson, 'Куртка', 'Jakna', 1111, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('05d0ca8c-cda6-5da0-b37b-42c32664f910', 'ee6d92cf-eb53-5fb9-8d3b-db7de3ef7033', 'Iryna', 'Koja jakna je bolja, plava ili crna?', 'Яка куртка краща, синя чи чорна?', 1);
  perform pg_temp.turn('a2cbe74e-d8f7-5b1a-965d-f622cfcc3bf9', 'ee6d92cf-eb53-5fb9-8d3b-db7de3ef7033', 'Lana', 'Plava je ljepša, ali crna je toplija.', 'Синя гарніша, але чорна тепліша.', 2);
  perform pg_temp.turn('91110a9d-aa7d-5327-a533-9ef35139b435', 'ee6d92cf-eb53-5fb9-8d3b-db7de3ef7033', 'Iryna', 'Crna je i skuplja.', 'Чорна ще й дорожча.', 3);
  perform pg_temp.turn('49635b78-d03a-508f-9e4f-bb66765e0922', 'ee6d92cf-eb53-5fb9-8d3b-db7de3ef7033', 'Lana', 'Da, ali je bolja za zimu.', 'Так, але вона краща для зими.', 4);
  perform pg_temp.turn('b57e9a9f-b304-5b8f-9a4f-ab0395efe4fa', 'ee6d92cf-eb53-5fb9-8d3b-db7de3ef7033', 'Iryna', 'Dobro, uzimam crnu.', 'Добре, беру чорну.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cfe29472-4cd7-577e-85c2-7f69646a9bb8', v_lesson, 'У примірочній', 'U kabini', 1112, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('6ff598f3-7f12-5761-8acf-c86b3831402f', 'cfe29472-4cd7-577e-85c2-7f69646a9bb8', 'Andrij', 'Ove traperice su mi male.', 'Ці джинси мені малі.', 1);
  perform pg_temp.turn('393ba053-09d9-5a39-ad21-901c5278bce0', 'cfe29472-4cd7-577e-85c2-7f69646a9bb8', 'Prodavačica', 'Probajte veće. Ovo je veličina trideset dva.', 'Поміряйте більші. Це розмір тридцять два.', 2);
  perform pg_temp.turn('b29598ce-d19b-5db8-9ef3-533c121b1bbe', 'cfe29472-4cd7-577e-85c2-7f69646a9bb8', 'Andrij', 'Imate li jeftinije?', 'У вас є дешевші?', 3);
  perform pg_temp.turn('8e5ab9ab-bb0b-5f5f-a9dc-ffd329f5ddad', 'cfe29472-4cd7-577e-85c2-7f69646a9bb8', 'Prodavačica', 'Imamo. Ove su na popustu.', 'Є. Ці зі знижкою.', 4);
  perform pg_temp.turn('e888a4bf-7d9a-54c1-b166-9bbe94f1b394', 'cfe29472-4cd7-577e-85c2-7f69646a9bb8', 'Andrij', 'Super, njih probam.', 'Чудово, їх і поміряю.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 12: У супермаркеті
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '0c19643d-57ff-5030-820f-ba330833ea88';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.3: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.3.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 12: У супермаркеті', 'Lekcija 12: U supermarketu', '["Сказати, що вам треба купити", "Запитати, чи можна заплатити карткою", "Вживати moram, mogu, trebam"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'trebati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'morati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'željeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'platiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uzeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'košarica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'supermarket', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blagajna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrećica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kartica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'red', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '11cc5462-4ac8-5495-9e7b-53101a92c22d', 'fill_in_the_blank', 'Ja ___ kupiti kruh.', 'moram', '["mora", "moraš", "moram", "moraju"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9dc82923-928c-5950-8e98-76a08e43c30a', 'multiple_choice', 'Що означає «platiti»?', 'заплатити', '["черга", "мусити / бути зобов''язаним", "потребувати", "заплатити"]'::jsonb, 'A1', 2, 'PUBLISHED', 'platiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9ae68757-dcae-5721-8a7a-44a182ec873d', 'multiple_choice', 'Що означає «kupiti»?', 'купити', '["взяти", "купити", "пакет", "заплатити"]'::jsonb, 'A1', 3, 'PUBLISHED', 'kupiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '97375a5f-b6e8-5905-a096-5e852c99b474', 'multiple_choice', 'Як хорватською «мусити / бути зобов''язаним»?', 'morati', '["vrećica", "željeti", "morati", "kartica"]'::jsonb, 'A1', 4, 'PUBLISHED', 'morati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0f3de0af-a885-580d-b299-2c122917a419', 'type_answer', 'Напишіть хорватською: «кошик (для покупок)»', 'košarica', null, 'A1', 5, 'PUBLISHED', 'košarica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cf85dccb-b3e8-5dcf-b624-7490ff5d9c06', 'type_answer', 'Напишіть хорватською: «черга»', 'red', null, 'A1', 6, 'PUBLISHED', 'red', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2b4eebaf-5004-5f1e-b5b0-3a7f855d9179', 'sentence_builder', 'Складіть: «Мені треба купити молоко й хліб.»', 'Moram kupiti mlijeko i kruh.', '["mlijeko", "kupiti", "Moram", "i", "kruh."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6d121f68-7551-544e-8a3f-5aa2c865b972', 'sentence_builder', 'Складіть: «Можна заплатити карткою?»', 'Mogu li platiti karticom?', '["karticom?", "li", "Mogu", "platiti"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '559c5614-7829-5c9d-9fc4-3ec0fc179956', 'listening', 'Прослухайте і складіть фразу', 'Možeš li uzeti košaricu?', '["Možeš", "košaricu?", "li", "uzeti"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '71263c9f-3300-5219-80f5-f65fd8e42764', 'listening', 'Прослухайте і складіть фразу', 'Trebate li vrećicu?', '["vrećicu?", "li", "Trebate"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6bb15115-e3c4-53f4-9cf7-a844af59b17f', 'speaking', 'Мені потрібен пакет.', 'Trebam vrećicu.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f951bd16-c2d9-5de9-9f0b-7e06f3d0e30b', 'speaking', 'Мені треба платити готівкою?', 'Moram li platiti gotovinom?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('52acf9ac-7b1e-554a-824a-ae291cbfa5a4', v_lesson, 'Список покупок', 'Popis za kupovinu', 1121, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('28cb8de7-1644-5cb6-ab8c-59e6ef66d933', '52acf9ac-7b1e-554a-824a-ae291cbfa5a4', 'Taras', 'Moram kupiti mlijeko i kruh.', 'Мені треба купити молоко й хліб.', 1);
  perform pg_temp.turn('fda1c4aa-5f7e-57eb-a2bb-ab75425bd74b', '52acf9ac-7b1e-554a-824a-ae291cbfa5a4', 'Olena', 'Trebamo i jaja.', 'Нам ще потрібні яйця.', 2);
  perform pg_temp.turn('08e2e6b9-8c05-59e4-8314-c0419fbde071', '52acf9ac-7b1e-554a-824a-ae291cbfa5a4', 'Taras', 'Možeš li uzeti košaricu?', 'Можеш узяти кошик?', 3);
  perform pg_temp.turn('64f52482-a496-5ca0-92a8-df27f79137f9', '52acf9ac-7b1e-554a-824a-ae291cbfa5a4', 'Olena', 'Mogu. Gdje je mlijeko?', 'Можу. Де молоко?', 4);
  perform pg_temp.turn('d6eec0bb-ccab-56d7-9172-69e2ec648f95', '52acf9ac-7b1e-554a-824a-ae291cbfa5a4', 'Taras', 'Tamo, lijevo.', 'Там, ліворуч.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('29cd6000-dd31-53ed-8774-be5866cf437f', v_lesson, 'На касі', 'Na blagajni', 1122, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('787bfe7d-65d6-5270-a210-305c4d4168a1', '29cd6000-dd31-53ed-8774-be5866cf437f', 'Blagajnica', 'Trebate li vrećicu?', 'Вам потрібен пакет?', 1);
  perform pg_temp.turn('a697a31c-a572-5ced-92e6-5fd2b15dadfe', '29cd6000-dd31-53ed-8774-be5866cf437f', 'Olena', 'Da, jednu. Mogu li platiti karticom?', 'Так, один. Можна заплатити карткою?', 2);
  perform pg_temp.turn('d4db8950-402f-595f-82e6-7c73de772ac5', '29cd6000-dd31-53ed-8774-be5866cf437f', 'Blagajnica', 'Naravno. Unesite PIN.', 'Звісно. Введіть PIN.', 3);
  perform pg_temp.turn('7457d564-0ba9-55bf-b655-c3c7f55e7cc9', '29cd6000-dd31-53ed-8774-be5866cf437f', 'Olena', 'Evo. Hvala!', 'Ось. Дякую!', 4);
  perform pg_temp.turn('54ca78ab-b83b-5849-97b0-0697e2d3a89d', '29cd6000-dd31-53ed-8774-be5866cf437f', 'Blagajnica', 'Hvala Vama! Ugodan dan!', 'Дякую вам! Гарного дня!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 13: Повернення товару
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '6a7b0f42-510b-521e-9cc0-f77b2659d838';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.3: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b89a9004-2c03-567a-b23e-31db18f92dea';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.3.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 13: Повернення товару', 'Lekcija 13: Povrat robe', '["Сказати, що річ не працює", "Попросити обміняти товар або повернути гроші", "Вживати заперечення: ne radi, nema, ništa"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'vratiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zamijeniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pokvareno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'račun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'novac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ništa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nitko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nikad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prodavač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kvar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sviđati se', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fc472d19-2b83-577d-93dc-081571e7dce8', 'fill_in_the_blank', 'Punjač ___ radi.', 'ne', '["nije", "nema", "ni", "ne"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9daa9ee6-2fcd-5df4-9662-befbcd3ea838', 'multiple_choice', 'Що означає «vratiti»?', 'повернути', '["ніколи", "повернути", "продавець", "рахунок / чек"]'::jsonb, 'A1', 2, 'PUBLISHED', 'vratiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '421295e1-46e1-568a-850a-f8ec9b2cf5ce', 'multiple_choice', 'Що означає «račun»?', 'рахунок / чек', '["повернути", "ніхто", "продавець", "рахунок / чек"]'::jsonb, 'A1', 3, 'PUBLISHED', 'račun', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8bd3ff32-d27a-5505-a913-fa6e780f37ec', 'multiple_choice', 'Як хорватською «продавець»?', 'prodavač', '["prodavač", "ništa", "sviđati se", "nikad"]'::jsonb, 'A1', 4, 'PUBLISHED', 'prodavač', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '52ef7b54-1004-5de2-85f1-9fe79e2aad29', 'type_answer', 'Напишіть хорватською: «несправність / поломка»', 'kvar', null, 'A1', 5, 'PUBLISHED', 'kvar', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e0d393c6-aba6-556d-822c-ed949533ad33', 'type_answer', 'Напишіть хорватською: «замінити»', 'zamijeniti', null, 'A1', 6, 'PUBLISHED', 'zamijeniti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cea4de34-47ac-5145-b04a-f92d5da2fb11', 'sentence_builder', 'Складіть: «Цей зарядний пристрій не працює.»', 'Ovaj punjač ne radi.', '["punjač", "Ovaj", "ne", "radi."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '19111b42-b8ed-55ff-9f29-c97a57019b77', 'sentence_builder', 'Складіть: «Мені нічого не подобається.»', 'Ništa mi se ne sviđa.', '["se", "sviđa.", "mi", "Ništa", "ne"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '43288778-9f5d-57e2-ac0d-a61ef179a2a8', 'listening', 'Прослухайте і складіть фразу', 'Imate li račun?', '["račun?", "li", "Imate"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '839ef982-ad14-5f41-842e-112e1343afdd', 'listening', 'Прослухайте і складіть фразу', 'Nema moje veličine.', '["moje", "veličine.", "Nema"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '330a903a-955e-58c0-8486-88375079324e', 'speaking', 'Це не працює.', 'Ovo ne radi.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '13e05920-4c40-5fa4-ab58-e66677308367', 'speaking', 'Я нічого не купую.', 'Ništa ne kupujem.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('728fcebb-e240-5ac4-9139-cfda3cc7984a', v_lesson, 'Зарядка не працює', 'Punjač ne radi', 1131, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('da0f1307-5629-557a-8861-be5f3003372d', '728fcebb-e240-5ac4-9139-cfda3cc7984a', 'Prodavač', 'Izvolite, kako mogu pomoći?', 'Прошу, чим можу допомогти?', 1);
  perform pg_temp.turn('4b25622b-5f5e-579f-8738-af43acf18874', '728fcebb-e240-5ac4-9139-cfda3cc7984a', 'Andrij', 'Ovaj punjač ne radi.', 'Цей зарядний пристрій не працює.', 2);
  perform pg_temp.turn('4d7578ec-e5dc-510d-a614-2dd037b552c0', '728fcebb-e240-5ac4-9139-cfda3cc7984a', 'Prodavač', 'Imate li račun?', 'У вас є чек?', 3);
  perform pg_temp.turn('d4d78d56-00b0-5d23-9454-b0834d08553d', '728fcebb-e240-5ac4-9139-cfda3cc7984a', 'Andrij', 'Imam, evo ga.', 'Є, ось він.', 4);
  perform pg_temp.turn('35a14328-9d2d-51dd-86f3-47c4600ec016', '728fcebb-e240-5ac4-9139-cfda3cc7984a', 'Prodavač', 'Možemo ga zamijeniti ili vratiti novac.', 'Можемо його обміняти або повернути гроші.', 5);
  perform pg_temp.turn('cabe93d0-3ae4-52c3-8239-01752556eb8e', '728fcebb-e240-5ac4-9139-cfda3cc7984a', 'Andrij', 'Molim Vas, vratite novac.', 'Поверніть, будь ласка, гроші.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6dccf29e-3564-5366-b7d0-b39698bc65fa', v_lesson, 'Нічого не подобається', 'Ništa mi se ne sviđa', 1132, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('602c8e93-b567-5de9-9e2f-6a7efa4a55ef', '6dccf29e-3564-5366-b7d0-b39698bc65fa', 'Lana', 'Kupuješ li nešto?', 'Ти щось купуєш?', 1);
  perform pg_temp.turn('7fe9091c-6e76-5d82-afaa-4584cdbf38a9', '6dccf29e-3564-5366-b7d0-b39698bc65fa', 'Oksana', 'Ne, ništa mi se ne sviđa.', 'Ні, мені нічого не подобається.', 2);
  perform pg_temp.turn('06849bce-862a-5d1f-bdc3-bcda0155de17', '6dccf29e-3564-5366-b7d0-b39698bc65fa', 'Lana', 'A ova haljina?', 'А ця сукня?', 3);
  perform pg_temp.turn('d9963baf-bc68-5525-8564-5866c738ccfa', '6dccf29e-3564-5366-b7d0-b39698bc65fa', 'Oksana', 'Nema moje veličine.', 'Немає мого розміру.', 4);
  perform pg_temp.turn('7eb6d373-c61e-5970-aa02-f2b1070aadcf', '6dccf29e-3564-5366-b7d0-b39698bc65fa', 'Lana', 'Ni ja nikad ne nalazim ništa ovdje!', 'Я теж ніколи нічого тут не знаходжу!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 14: У дрогерії
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '9ba8e62a-83fd-5b08-9e01-760bc0f7219f';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.3: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.3.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 14: У дрогерії', 'Lekcija 14: U drogeriji', '["Купити засоби гігієни й побутову хімію", "Знайти товар у магазині", "Вживати родовий відмінок: nema šampona"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'drogerija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šampon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pasta za zube', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pelene', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krema', v_pos);
  v_pos := pg_temp.word(v_lesson, 'deterdžent', v_pos);
  v_pos := pg_temp.word(v_lesson, 'toaletni papir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'akcija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kosa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'suh', v_pos);
  v_pos := pg_temp.word(v_lesson, 'beba', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '85d93558-60d2-5db9-8829-53cd4446b36f', 'fill_in_the_blank', 'Danas nema ___.', 'šampona', '["šamponom", "šampona", "šampon", "šamponu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '34af2be4-0ae2-5b14-af04-004c5920e09e', 'multiple_choice', 'Що означає «krema»?', 'крем', '["зубна паста", "шампунь", "крем", "акція; спеціальна пропозиція"]'::jsonb, 'A1', 2, 'PUBLISHED', 'krema', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e43b6ac5-e8b8-51d4-b82f-99490a4049f4', 'multiple_choice', 'Що означає «pelene»?', 'підгузки', '["волосся", "шампунь", "полиця; страховий поліс", "підгузки"]'::jsonb, 'A1', 3, 'PUBLISHED', 'pelene', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '11b4c1c6-ea65-565f-9523-024c7f60ed8d', 'multiple_choice', 'Як хорватською «магазин побутової хімії й косметики»?', 'drogerija', '["drogerija", "deterdžent", "krema", "polica"]'::jsonb, 'A1', 4, 'PUBLISHED', 'drogerija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f2baafab-686b-50eb-86a9-31abb5cb62c6', 'type_answer', 'Напишіть хорватською: «шампунь»', 'šampon', null, 'A1', 5, 'PUBLISHED', 'šampon', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6190f7a8-7009-502e-a565-76f6db482903', 'type_answer', 'Напишіть хорватською: «сухий»', 'suh', null, 'A1', 6, 'PUBLISHED', 'suh', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1e7f24ba-dd84-55f3-9380-b4ccfd591769', 'sentence_builder', 'Складіть: «Вибачте, де підгузки?»', 'Oprostite, gdje su pelene?', '["Oprostite,", "pelene?", "gdje", "su"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '56cc82b5-4409-5c90-8869-183eccc4567c', 'sentence_builder', 'Складіть: «Мені потрібна зубна паста.»', 'Trebam pastu za zube.', '["za", "zube.", "pastu", "Trebam"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3722f574-39e1-52af-86ac-1b762a862126', 'listening', 'Прослухайте і складіть фразу', 'Imate li veći paket?', '["li", "veći", "Imate", "paket?"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e8be9c48-72bb-5029-967e-53a6c83a0052', 'listening', 'Прослухайте і складіть фразу', 'Ima li deterdženta za rublje?', '["Ima", "li", "rublje?", "za", "deterdženta"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '08165527-06b4-5e02-bbeb-6bbbaf7d150c', 'speaking', 'Де туалетний папір?', 'Gdje je toaletni papir?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e94db4a-9961-58d2-a1cd-0ca719a2dc69', 'speaking', 'Це по акції?', 'Je li ovo na akciji?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ded88657-9ec2-5846-a64b-92e777bed924', v_lesson, 'Для малюка', 'Za bebu', 1141, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('2a68f733-f854-516a-824c-9203c6f00c40', 'ded88657-9ec2-5846-a64b-92e777bed924', 'Olena', 'Oprostite, gdje su pelene?', 'Вибачте, де підгузки?', 1);
  perform pg_temp.turn('225f080c-7293-5a3e-9fd0-f4a7aca19627', 'ded88657-9ec2-5846-a64b-92e777bed924', 'Prodavačica', 'Na kraju, desno, pored kreme za bebe.', 'У кінці, праворуч, біля дитячого крему.', 2);
  perform pg_temp.turn('ebc4aede-9692-5428-93ab-e813d72a2a90', 'ded88657-9ec2-5846-a64b-92e777bed924', 'Olena', 'Imate li veći paket?', 'У вас є більша упаковка?', 3);
  perform pg_temp.turn('bec9fdee-f4dc-5d8d-adb3-eb83421a7152', 'ded88657-9ec2-5846-a64b-92e777bed924', 'Prodavačica', 'Imamo, i danas je na akciji.', 'Є, і сьогодні вона по акції.', 4);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a5602db1-b844-5266-9759-95d92b05ebf1', v_lesson, 'Немає шампуню', 'Nema šampona', 1142, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('fbd78819-34a0-5f37-a925-ffd173cefacb', 'a5602db1-b844-5266-9759-95d92b05ebf1', 'Taras', 'Trebam šampon i pastu za zube.', 'Мені потрібні шампунь і зубна паста.', 1);
  perform pg_temp.turn('b31ae2b0-f3a3-596a-b01d-33eb4284cb12', 'a5602db1-b844-5266-9759-95d92b05ebf1', 'Prodavač', 'Pasta za zube je ovdje. Šampona za suhu kosu danas nema.', 'Зубна паста тут. Шампуню для сухого волосся сьогодні немає.', 2);
  perform pg_temp.turn('4cc10ac1-f40d-5907-9663-59defbea47d3', 'a5602db1-b844-5266-9759-95d92b05ebf1', 'Taras', 'Ima li deterdženta za rublje?', 'А засіб для прання є?', 3);
  perform pg_temp.turn('ae6e4785-3fa2-59e5-a45c-5e1eca6db7a4', 'a5602db1-b844-5266-9759-95d92b05ebf1', 'Prodavač', 'Ima, na zadnjoj polici. I toaletni papir je tamo.', 'Є, на останній полиці. Туалетний папір теж там.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 15: Мобільний зв’язок
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '35203547-5f9a-5857-95a0-3a0d596f715d';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.3: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.3.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 15: Мобільний зв’язок', 'Lekcija 15: Mobilna mreža', '["Купити SIM-картку й обрати тариф", "Запитати про інтернет і дзвінки в Україну", "Віддати телефон у ремонт"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'SIM kartica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tarifa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'internet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjesečno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'punjač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'puniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'broj mobitela', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poruka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ostaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'aplikacija', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fc1a004b-bfd2-526a-b762-f9b53f796682', 'fill_in_the_blank', '___ košta internet?', 'Koliko', '["Kada", "Koliko", "Gdje", "Koji"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd1a58bf9-6547-59dd-89c0-8e63b05760f8', 'multiple_choice', 'Що означає «poruka»?', 'повідомлення', '["передплата (поповнення рахунку)", "SIM-картка", "повідомлення", "дзвонити; кликати"]'::jsonb, 'A1', 2, 'PUBLISHED', 'poruka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3f920b13-9699-5e7d-8b3e-5b1a3cde902e', 'multiple_choice', 'Що означає «zvati»?', 'дзвонити; кликати', '["дзвонити; кликати", "номер мобільного телефону", "повідомлення", "SIM-картка"]'::jsonb, 'A1', 3, 'PUBLISHED', 'zvati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1dfc85ca-c600-539c-81dd-2f41838f8f5e', 'multiple_choice', 'Як хорватською «інтернет»?', 'internet', '["internet", "ostaviti", "bon", "aplikacija"]'::jsonb, 'A1', 4, 'PUBLISHED', 'internet', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8ba8af2-b2cb-5f2b-8f0f-8046c2bb8c4f', 'type_answer', 'Напишіть хорватською: «додаток (app)»', 'aplikacija', null, 'A1', 5, 'PUBLISHED', 'aplikacija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1a6f719c-6eb7-5abf-91ea-2ae254de8c02', 'type_answer', 'Напишіть хорватською: «зарядний пристрій»', 'punjač', null, 'A1', 6, 'PUBLISHED', 'punjač', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e23b7220-8f81-568f-96e3-bfa2ae0ac922', 'sentence_builder', 'Складіть: «Мені потрібна SIM-картка.»', 'Trebam SIM karticu.', '["karticu.", "SIM", "Trebam"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '11f2e5ac-19e4-5d5f-919b-bcd5c734fe9a', 'sentence_builder', 'Складіть: «Мій телефон не заряджається.»', 'Moj mobitel se ne puni.', '["se", "mobitel", "Moj", "ne", "puni."]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '88ac26d6-3bbc-5055-a6ad-72301f141e43', 'listening', 'Прослухайте і складіть фразу', 'Mogu li zvati u Ukrajinu?', '["u", "zvati", "Ukrajinu?", "li", "Mogu"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ecfa0654-9418-5153-b2af-7749264a7e68', 'listening', 'Прослухайте і складіть фразу', 'Koji punjač imate?', '["punjač", "imate?", "Koji"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a5204f17-1f59-5a12-a5e0-89f92fff1dfe', 'speaking', 'Скільки коштує інтернет?', 'Koliko košta internet?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '259e7d53-7c56-548b-b8e2-cf096e10c62b', 'speaking', 'Мені потрібен зарядний пристрій.', 'Trebam punjač.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('20cfacc9-ff3c-525d-b4a5-b75f2ea18dbe', v_lesson, 'Нова SIM-картка', 'Nova SIM kartica', 1151, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('c362aabb-37e5-5894-9f0a-5beeeb730f92', '20cfacc9-ff3c-525d-b4a5-b75f2ea18dbe', 'Andrij', 'Dobar dan, trebam SIM karticu.', 'Добрий день, мені потрібна SIM-картка.', 1);
  perform pg_temp.turn('8c5739a7-d00e-5736-a5f2-ec08c924c1aa', '20cfacc9-ff3c-525d-b4a5-b75f2ea18dbe', 'Prodavačica', 'Želite li bon ili tarifu s ugovorom?', 'Бажаєте передплачену картку чи тариф із договором?', 2);
  perform pg_temp.turn('e2ff6045-2cb9-566a-b6f3-8a4bc44bec46', '20cfacc9-ff3c-525d-b4a5-b75f2ea18dbe', 'Andrij', 'Bon. Koliko košta internet?', 'Передплачену. Скільки коштує інтернет?', 3);
  perform pg_temp.turn('8623871b-4a39-5371-ac7a-85e0fe7b4001', '20cfacc9-ff3c-525d-b4a5-b75f2ea18dbe', 'Prodavačica', 'Deset eura mjesečno za dvadeset giga.', 'Десять євро на місяць за двадцять гігабайтів.', 4);
  perform pg_temp.turn('ea1d9468-7c2a-5e59-9d84-6dce35dc5863', '20cfacc9-ff3c-525d-b4a5-b75f2ea18dbe', 'Andrij', 'Mogu li zvati u Ukrajinu?', 'Чи можу я дзвонити в Україну?', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8e713d59-523e-5fe4-a126-d33e6c027b1e', v_lesson, 'Телефон не заряджається', 'Mobitel se ne puni', 1152, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('4c9e145a-cbd5-5d97-b8ab-f19504af15b9', '8e713d59-523e-5fe4-a126-d33e6c027b1e', 'Iryna', 'Moj mobitel se ne puni.', 'Мій телефон не заряджається.', 1);
  perform pg_temp.turn('50edb3bf-e13e-5aef-9dec-a8b4bfeb1b15', '8e713d59-523e-5fe4-a126-d33e6c027b1e', 'Prodavač', 'Koji punjač imate?', 'Який у вас зарядний пристрій?', 2);
  perform pg_temp.turn('0a47ecd8-d731-52de-a27c-6656cce574ea', '8e713d59-523e-5fe4-a126-d33e6c027b1e', 'Iryna', 'Ovaj. Kada mogu doći po mobitel?', 'Ось цей. Коли я можу прийти по телефон?', 3);
  perform pg_temp.turn('060905eb-8ae5-5393-bde4-fd5ae92339f1', '8e713d59-523e-5fe4-a126-d33e6c027b1e', 'Prodavač', 'Sutra poslijepodne. Ostavite broj mobitela, molim.', 'Завтра після обіду. Залиште, будь ласка, номер телефону.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 16: У трамваї
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '0ef458c5-53cf-530a-99cf-4ccd6e0132e5';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.4: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.4.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 16: У трамваї', 'Lekcija 16: U tramvaju', '["Купити квиток на трамвай чи автобус", "Запитати, де пересісти", "Вживати місцевий відмінок: u tramvaju, na stanici"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'tramvaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'autobus', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stanica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'karta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poništač karata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kontrolor karata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'javni prijevoz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'linija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'presjedati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vozač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sljedeći', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '69ba93db-7996-5afb-a43c-b9ea4d271329', 'fill_in_the_blank', 'Čekam na ___.', 'stanici', '["stanice", "stanici", "stanica", "stanicu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ee72dcec-b1c4-58bf-9167-1ae3f9471803', 'multiple_choice', 'Що означає «presjedati»?', 'робити пересадку', '["трамвай", "контролер", "робити пересадку", "зупинка / станція"]'::jsonb, 'A1', 2, 'PUBLISHED', 'presjedati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '00d82720-cced-5889-b290-39dac33c58fe', 'multiple_choice', 'Що означає «vozač»?', 'водій', '["водій", "зупинка / станція", "квиток / карта", "робити пересадку"]'::jsonb, 'A1', 3, 'PUBLISHED', 'vozač', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f980d9db-6603-5e6a-a4cb-ddfdd6105694', 'multiple_choice', 'Як хорватською «громадський транспорт»?', 'javni prijevoz', '["poništač karata", "kontrolor karata", "javni prijevoz", "sljedeći"]'::jsonb, 'A1', 4, 'PUBLISHED', 'javni prijevoz', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c6ec6379-67c3-5aa5-b865-72039199fc5e', 'type_answer', 'Напишіть хорватською: «автобус»', 'autobus', null, 'A1', 5, 'PUBLISHED', 'autobus', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4fb4725a-4fac-5074-9bf8-a020e7dedb69', 'type_answer', 'Напишіть хорватською: «наступний»', 'sljedeći', null, 'A1', 6, 'PUBLISHED', 'sljedeći', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '000a06ef-dc7b-5845-977a-0649e4a603c0', 'sentence_builder', 'Складіть: «Де я можу купити квиток?»', 'Gdje mogu kupiti kartu?', '["kupiti", "Gdje", "mogu", "kartu?"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '37e47a3d-5cdb-556f-b102-84de69da4d2a', 'sentence_builder', 'Складіть: «На якій зупинці?»', 'Na kojoj stanici?', '["stanici?", "kojoj", "Na"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '375dfa40-3c8a-52dc-b044-3a25e9380548', 'listening', 'Прослухайте і складіть фразу', 'Na kiosku ili u tramvaju, kod vozača.', '["Na", "ili", "u", "tramvaju,", "kiosku", "kod", "vozača."]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e9725e94-2bdc-5592-8b2c-adf262960153', 'listening', 'Прослухайте і складіть фразу', 'Na sljedećoj. Onda uzmite šesticu.', '["Na", "sljedećoj.", "Onda", "šesticu.", "uzmite"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '151724db-a8ac-5772-985b-276e172a7fd9', 'speaking', 'Я в трамваї.', 'U tramvaju sam.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '19c797b3-ece1-5658-9349-c3492180b6bd', 'speaking', 'Я чекаю на зупинці.', 'Čekam na stanici.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e1f64e62-cc75-5697-ae23-9d7524e2a387', v_lesson, 'Де купити квиток?', 'Gdje kupiti kartu?', 1161, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('c5e872f0-ded7-553f-a37e-fb86e95dc64d', 'e1f64e62-cc75-5697-ae23-9d7524e2a387', 'Olena', 'Oprostite, gdje mogu kupiti kartu?', 'Вибачте, де я можу купити квиток?', 1);
  perform pg_temp.turn('6524ce01-7b4e-5030-bdb6-49f631a3be2f', 'e1f64e62-cc75-5697-ae23-9d7524e2a387', 'Gospođa', 'Na kiosku ili u tramvaju, kod vozača.', 'У кіоску або в трамваї, у водія.', 2);
  perform pg_temp.turn('ef7cc83d-e104-59fc-beb2-538f9a3cb65c', 'e1f64e62-cc75-5697-ae23-9d7524e2a387', 'Olena', 'Koliko košta?', 'Скільки коштує?', 3);
  perform pg_temp.turn('2edd7129-bf33-5186-ae61-55542f7c3e7f', 'e1f64e62-cc75-5697-ae23-9d7524e2a387', 'Gospođa', 'Kod vozača dva eura. Ne zaboravite je poništiti!', 'У водія два євро. Не забудьте її прокомпостувати!', 4);
  perform pg_temp.turn('1bd599b8-38a7-5b61-b351-192813743c40', 'e1f64e62-cc75-5697-ae23-9d7524e2a387', 'Olena', 'Hvala na pomoći!', 'Дякую за допомогу!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('12c3f895-5d6d-5c1c-923f-980ab2090ced', v_lesson, 'Пересадка', 'Presjedanje', 1162, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('987f86a3-b05f-5a3d-912c-9bb8e98aee1a', '12c3f895-5d6d-5c1c-923f-980ab2090ced', 'Taras', 'Ide li ovaj tramvaj do kolodvora?', 'Цей трамвай їде до вокзалу?', 1);
  perform pg_temp.turn('f1d32935-2907-5afd-b2e2-4c255a84f299', '12c3f895-5d6d-5c1c-923f-980ab2090ced', 'Mladić', 'Ne ide. Morate presjesti na Trgu bana Jelačića.', 'Не їде. Вам треба пересісти на площі бана Єлачича.', 2);
  perform pg_temp.turn('e42b7c04-9d1c-59f9-95fa-86f066909b9b', '12c3f895-5d6d-5c1c-923f-980ab2090ced', 'Taras', 'Na kojoj stanici?', 'На якій зупинці?', 3);
  perform pg_temp.turn('076b0518-d492-52f6-9656-b777ff328c79', '12c3f895-5d6d-5c1c-923f-980ab2090ced', 'Mladić', 'Na sljedećoj. Onda uzmite šesticu.', 'На наступній. Потім сідайте на шістку.', 4);
  perform pg_temp.turn('a9e60db1-4fb2-5747-b3c6-3dd146e1a4fe', '12c3f895-5d6d-5c1c-923f-980ab2090ced', 'Taras', 'Hvala!', 'Дякую!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 17: Розклад поїздів
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'cae7a47d-7fb4-5b03-a8cc-5a0df2ccd92f';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.4: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.4.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 17: Розклад поїздів', 'Lekcija 17: Vozni red', '["Дізнатися, коли відправляється поїзд", "Купити квиток туди й назад", "Ставити питання: kada, koliko, zašto"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'vlak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolodvor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'peron', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vozni red', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polaziti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dolazak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kasniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kašnjenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povratna karta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jednosmjerna karta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koliko', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e633ff89-e16e-5e55-9869-d256fac7cbf1', 'fill_in_the_blank', '___ polazi vlak? — U tri.', 'Kada', '["Koliko", "Kada", "Tko", "Gdje"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5d5cd976-f9fe-5715-86a7-f6d4a8e6c904', 'multiple_choice', 'Що означає «vlak»?', 'поїзд', '["скільки", "запізнення", "поїзд", "квиток туди і назад"]'::jsonb, 'A1', 2, 'PUBLISHED', 'vlak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0dd8a571-ac58-5030-828f-6b3330c04d34', 'multiple_choice', 'Що означає «kada»?', 'коли', '["поїзд", "запізнення", "коли", "вокзал"]'::jsonb, 'A1', 3, 'PUBLISHED', 'kada', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7987f3db-834a-5fe2-be1d-ec6ffd09741e', 'multiple_choice', 'Як хорватською «перон»?', 'peron', '["dolazak", "kada", "peron", "vozni red"]'::jsonb, 'A1', 4, 'PUBLISHED', 'peron', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c298432b-ed46-5ad6-86c0-dca08b11670c', 'type_answer', 'Напишіть хорватською: «відправлятися»', 'polaziti', null, 'A1', 5, 'PUBLISHED', 'polaziti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '81d032cc-e7c0-5aee-8009-70c188f680ae', 'type_answer', 'Напишіть хорватською: «вокзал»', 'kolodvor', null, 'A1', 6, 'PUBLISHED', 'kolodvor', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c95a7553-4284-56f2-9148-06aa3aaefdf9', 'sentence_builder', 'Складіть: «Коли відправляється поїзд до Рієки?»', 'Kada polazi vlak za Rijeku?', '["vlak", "za", "Rijeku?", "Kada", "polazi"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '54632ac3-1d83-56c7-a2e6-7ab0720f198f', 'sentence_builder', 'Складіть: «Де можна випити кави?»', 'Gdje mogu popiti kavu?', '["popiti", "Gdje", "kavu?", "mogu"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '88b27787-b24a-51ae-b92e-ff5982396c6b', 'listening', 'Прослухайте і складіть фразу', 'Oko četiri sata.', '["četiri", "Oko", "sata."]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '09f6f165-80c2-552f-9eae-8b33208e44a3', 'listening', 'Прослухайте і складіть фразу', 'Kasni dvadeset minuta.', '["Kasni", "minuta.", "dvadeset"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5a19592c-b7fd-5a74-816e-080b7dfabc7e', 'speaking', 'Скільки триває поїздка?', 'Koliko traje vožnja?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be41c2c9-feec-597c-8a24-c29bc9542e50', 'speaking', 'З якої платформи?', 'S kojeg perona?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('35d68ca5-c995-5530-b5d8-468ffc0db2d3', v_lesson, 'На вокзалі', 'Na kolodvoru', 1171, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('bf0e5efa-9b3f-52fb-8f0e-7037eac396cb', '35d68ca5-c995-5530-b5d8-468ffc0db2d3', 'Andrij', 'Kada polazi vlak za Rijeku?', 'Коли відправляється поїзд до Рієки?', 1);
  perform pg_temp.turn('1ef0aceb-a8c6-51bc-895d-55a66e0cdc7f', '35d68ca5-c995-5530-b5d8-468ffc0db2d3', 'Službenica', 'U četrnaest i dvadeset, s trećeg perona.', 'О чотирнадцятій двадцять, з третьої платформи.', 2);
  perform pg_temp.turn('aab973ae-c5b8-5756-ab4c-fbcab1aac2c1', '35d68ca5-c995-5530-b5d8-468ffc0db2d3', 'Andrij', 'Koliko traje vožnja?', 'Скільки триває поїздка?', 3);
  perform pg_temp.turn('86bdb99d-f484-53ec-9d5e-00de9ed6ccc7', '35d68ca5-c995-5530-b5d8-468ffc0db2d3', 'Službenica', 'Oko četiri sata.', 'Близько чотирьох годин.', 4);
  perform pg_temp.turn('da9e4cc7-04e2-5759-979a-5ded4adcd097', '35d68ca5-c995-5530-b5d8-468ffc0db2d3', 'Andrij', 'Jednu povratnu kartu, molim.', 'Один квиток туди й назад, будь ласка.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e2ae8424-68e4-5b92-80e2-9d83f79c79cd', v_lesson, 'Поїзд запізнюється', 'Vlak kasni', 1172, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('b8387074-15c6-57ca-abd6-efdedfe1fe9f', 'e2ae8424-68e4-5b92-80e2-9d83f79c79cd', 'Putnica', 'Zašto vlak još nije ovdje?', 'Чому поїзда досі немає?', 1);
  perform pg_temp.turn('f05b07b1-d107-5c8b-aad2-73468263300d', 'e2ae8424-68e4-5b92-80e2-9d83f79c79cd', 'Kondukter', 'Kasni dvadeset minuta.', 'Він запізнюється на двадцять хвилин.', 2);
  perform pg_temp.turn('52f0fa12-1424-5c69-a47d-091d95e1a488', 'e2ae8424-68e4-5b92-80e2-9d83f79c79cd', 'Putnica', 'Kada stiže?', 'Коли він прибуває?', 3);
  perform pg_temp.turn('f5685fe3-468c-51ad-8ad8-446f6089fb9f', 'e2ae8424-68e4-5b92-80e2-9d83f79c79cd', 'Kondukter', 'U pola tri.', 'О пів на третю.', 4);
  perform pg_temp.turn('4e43596c-95cf-5127-b2c9-67e5ecf8d179', 'e2ae8424-68e4-5b92-80e2-9d83f79c79cd', 'Putnica', 'Gdje mogu popiti kavu?', 'Де можна випити кави?', 5);
  perform pg_temp.turn('4fef423a-b5ce-5be0-a1a9-046414792ac7', 'e2ae8424-68e4-5b92-80e2-9d83f79c79cd', 'Kondukter', 'U kafiću pored izlaza.', 'У кафе біля виходу.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 18: В аеропорту
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '69ec0776-4f69-5f86-afac-6652234a7da5';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.4: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.4.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 18: В аеропорту', 'Lekcija 18: U zračnoj luci', '["Пройти реєстрацію на рейс", "Запитати, чия це річ", "Вживати moj, Vaš, njegov, čiji"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zračna luka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'let', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kofer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prtljaga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ručna prtljaga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'putovnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izlaz za ukrcaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ukrcajna propusnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sjedalo do prozora', v_pos);
  v_pos := pg_temp.word(v_lesson, 'avion', v_pos);
  v_pos := pg_temp.word(v_lesson, 'torba', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '8ff86f1e-01fa-5aea-87d9-69672362f30e', 'fill_in_the_blank', 'Je li ovo ___ kofer? — Da, moj.', 'Vaš', '["Vaš", "Vaše", "Vaša", "Vašu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7de2c257-a4d4-50da-8bd1-42a4a2eb652a', 'multiple_choice', 'Що означає «avion»?', 'літак', '["аеропорт", "вихід на посадку", "валіза", "літак"]'::jsonb, 'A1', 2, 'PUBLISHED', 'avion', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '138d064e-416c-5f7a-80aa-49c7e7d0a097', 'multiple_choice', 'Що означає «torba»?', 'сумка', '["ручна поклажа", "аеропорт", "посадковий талон", "сумка"]'::jsonb, 'A1', 3, 'PUBLISHED', 'torba', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e4ee0d25-3fbb-55d2-8aea-65f809453b29', 'multiple_choice', 'Як хорватською «закордонний паспорт»?', 'putovnica', '["prtljaga", "putovnica", "izlaz za ukrcaj", "sjedalo do prozora"]'::jsonb, 'A1', 4, 'PUBLISHED', 'putovnica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9e6ced9b-dc78-5672-bf0e-51436855ffa5', 'type_answer', 'Напишіть хорватською: «ручна поклажа»', 'ručna prtljaga', null, 'A1', 5, 'PUBLISHED', 'ručna prtljaga', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '540a992d-5728-5701-88a1-50bff8b2a7ea', 'type_answer', 'Напишіть хорватською: «рейс / політ»', 'let', null, 'A1', 6, 'PUBLISHED', 'let', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '385c54b0-52ac-529c-8be3-14d9c1e9897e', 'sentence_builder', 'Складіть: «Це ваша валіза?»', 'Je li ovo Vaš kofer?', '["Vaš", "kofer?", "li", "Je", "ovo"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c4735af-43f1-5811-b955-8a64b8ccc061', 'sentence_builder', 'Складіть: «Не моя. Моя чорна.»', 'Nije moja. Moja je crna.', '["crna.", "Nije", "moja.", "Moja", "je"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'feb1daac-2437-52fc-aa2d-bff5ab64d935', 'listening', 'Прослухайте і складіть фразу', 'Želite li sjedalo do prozora?', '["Želite", "li", "do", "prozora?", "sjedalo"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0a25d610-28a9-5755-87c8-19a6c3d8d7d2', 'listening', 'Прослухайте і складіть фразу', 'Možda je njegova?', '["je", "Možda", "njegova?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '95ecdbca-1cc4-5e6a-b182-223d21d75fcc', 'speaking', 'Це мій паспорт.', 'Ovo je moja putovnica.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '02d5b4b4-5747-55db-8338-b23de5096484', 'speaking', 'Де вихід на посадку?', 'Gdje je izlaz za ukrcaj?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5bafa277-ad88-5368-a150-bb114f14b3e9', v_lesson, 'Реєстрація', 'Prijava za let', 1181, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('3f189dff-a3bd-5896-ada0-789dd0220c38', '5bafa277-ad88-5368-a150-bb114f14b3e9', 'Službenik', 'Vašu putovnicu, molim.', 'Ваш паспорт, будь ласка.', 1);
  perform pg_temp.turn('1860b992-8333-54ae-be66-0849d0badcbf', '5bafa277-ad88-5368-a150-bb114f14b3e9', 'Iryna', 'Izvolite.', 'Прошу.', 2);
  perform pg_temp.turn('b2d6c9b0-ca3a-5cb2-a6d6-bfaed220d0d6', '5bafa277-ad88-5368-a150-bb114f14b3e9', 'Službenik', 'Je li ovo Vaš kofer?', 'Це ваша валіза?', 3);
  perform pg_temp.turn('3efc85f5-069f-5133-a1a0-cecbde81677e', '5bafa277-ad88-5368-a150-bb114f14b3e9', 'Iryna', 'Da, moj. A ova torba je ručna prtljaga.', 'Так, моя. А ця сумка — ручна поклажа.', 4);
  perform pg_temp.turn('1295a4b9-01a3-50bd-a3de-8f5c3a33a9bb', '5bafa277-ad88-5368-a150-bb114f14b3e9', 'Službenik', 'Želite li sjedalo do prozora?', 'Бажаєте місце біля вікна?', 5);
  perform pg_temp.turn('dfd7e085-0c8e-50e1-b4cd-c96e0d25e553', '5bafa277-ad88-5368-a150-bb114f14b3e9', 'Iryna', 'Da, molim.', 'Так, будь ласка.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('339d93c7-d0b9-5780-a4d6-7045aee416bc', v_lesson, 'Чия це сумка?', 'Čija je ovo torba?', 1182, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('931b93f8-c8bf-5099-9925-1a82755aacdc', '339d93c7-d0b9-5780-a4d6-7045aee416bc', 'Djevojka', 'Oprostite, je li ovo Vaša torba?', 'Вибачте, це ваша сумка?', 1);
  perform pg_temp.turn('3f05be51-01a2-5f1e-9cb5-21b5b03aa071', '339d93c7-d0b9-5780-a4d6-7045aee416bc', 'Taras', 'Nije moja. Moja je crna.', 'Не моя. Моя чорна.', 2);
  perform pg_temp.turn('d33ffd11-a950-5c7d-bcab-65881449f049', '339d93c7-d0b9-5780-a4d6-7045aee416bc', 'Djevojka', 'Možda je njegova?', 'Може, це його?', 3);
  perform pg_temp.turn('5ea549ab-31f4-527a-9f97-cac653f16987', '339d93c7-d0b9-5780-a4d6-7045aee416bc', 'Muškarac', 'Da, moja je! Hvala Vam.', 'Так, моя! Дякую вам.', 4);
  perform pg_temp.turn('15f1157e-54a5-510f-b18a-8795d07fb8fb', '339d93c7-d0b9-5780-a4d6-7045aee416bc', 'Djevojka', 'Nema na čemu.', 'Нема за що.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 19: Таксі
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '458ee6ec-31d1-5758-adef-03612626088a';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.4: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.4.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 19: Таксі', 'Lekcija 19: Taksi', '["Викликати таксі", "Попросити водія зупинитися", "Запитати, скільки платити"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'taksi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'taksist', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odmah', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stići', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prtljažnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'staviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gužva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na vrijeme', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plaćati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'voziti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '9f402257-8f8c-574b-8ec3-afb95069c93d', 'fill_in_the_blank', '___ ovdje, molim!', 'Stanite', '["Stane", "Stanem", "Stanite", "Stati"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eaaa7606-fa52-5fda-a9d5-ecd992f0551a', 'multiple_choice', 'Що означає «stići»?', 'прибути / доїхати', '["прибути / доїхати", "таксі", "таксист", "водити (авто) / везти"]'::jsonb, 'A1', 2, 'PUBLISHED', 'stići', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c6bfcedc-fd38-5169-be50-a4ecc463d93f', 'multiple_choice', 'Що означає «taksi»?', 'таксі', '["платити", "водити (авто) / везти", "прибути / доїхати", "таксі"]'::jsonb, 'A1', 3, 'PUBLISHED', 'taksi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1daa66e9-311c-54f8-8a3f-653b69c20d67', 'multiple_choice', 'Як хорватською «вчасно»?', 'na vrijeme', '["plaćati", "stići", "gužva", "na vrijeme"]'::jsonb, 'A1', 4, 'PUBLISHED', 'na vrijeme', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8705161b-e383-5e35-8daa-f9be4182632d', 'type_answer', 'Напишіть хорватською: «зупинитися»', 'stati', null, 'A1', 5, 'PUBLISHED', 'stati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2a276ba4-2755-5ee0-b080-00584cd86f5c', 'type_answer', 'Напишіть хорватською: «платити»', 'plaćati', null, 'A1', 6, 'PUBLISHED', 'plaćati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3cad4b82-fd01-51ae-87d5-ff4fdf9c0d5e', 'sentence_builder', 'Складіть: «Мені потрібне таксі до вокзалу.»', 'Trebam taksi do kolodvora.', '["Trebam", "kolodvora.", "do", "taksi"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '258f1a32-1a02-5187-9c6a-ce3d51bd9b79', 'sentence_builder', 'Складіть: «Зупиніться тут, будь ласка.»', 'Stanite ovdje, molim.', '["Stanite", "molim.", "ovdje,"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c6828b9-97a3-5a05-8a7b-b5704231f191', 'listening', 'Прослухайте і складіть фразу', 'Odmah, molim. Idem na kolodvor.', '["molim.", "kolodvor.", "na", "Idem", "Odmah,"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6da4f022-fb78-5955-beef-f891aec21793', 'listening', 'Прослухайте і складіть фразу', 'Ima gužve, ali stižemo na vrijeme.', '["na", "vrijeme.", "gužve,", "ali", "Ima", "stižemo"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c46a0f83-6257-5d7a-8f9c-eeace227eba4', 'speaking', 'Покладіть валізу в багажник.', 'Stavite kofer u prtljažnik.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b7ea4cc1-4a9c-5750-89e2-64080bce62e7', 'speaking', 'Скільки з мене?', 'Koliko plaćam?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b3441025-0dcd-5dd6-a31b-6ceb2f3fb110', v_lesson, 'Виклик таксі', 'Naručivanje taksija', 1191, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('eb15cdf9-4435-5b9d-b8e8-f615436060ce', 'b3441025-0dcd-5dd6-a31b-6ceb2f3fb110', 'Oksana', 'Dobar dan, trebam taksi na adresu Ilica deset.', 'Добрий день, мені потрібне таксі на адресу Іліца, 10.', 1);
  perform pg_temp.turn('86c100cd-d921-52d3-9846-bc40ded8e86b', 'b3441025-0dcd-5dd6-a31b-6ceb2f3fb110', 'Dispečerica', 'Kada?', 'Коли?', 2);
  perform pg_temp.turn('929ef4b3-1def-5b0f-942e-52017d5e0f41', 'b3441025-0dcd-5dd6-a31b-6ceb2f3fb110', 'Oksana', 'Odmah, molim. Idem na kolodvor.', 'Негайно, будь ласка. Я їду на вокзал.', 3);
  perform pg_temp.turn('cbcdd603-3bfe-547e-b733-0f502d2ce5ed', 'b3441025-0dcd-5dd6-a31b-6ceb2f3fb110', 'Dispečerica', 'Taksi stiže za pet minuta. Bijela Škoda.', 'Таксі приїде за п’ять хвилин. Біла «Шкода».', 4);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('40840853-432e-5f67-9a65-c970305bd771', v_lesson, 'У таксі', 'U taksiju', 1192, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('c6410e83-1406-52ff-a0ff-81b8fc6cceca', '40840853-432e-5f67-9a65-c970305bd771', 'Taksist', 'Stavite kofer u prtljažnik.', 'Покладіть валізу в багажник.', 1);
  perform pg_temp.turn('762f72ef-6a1e-5d51-a0e6-eb02c3f16804', '40840853-432e-5f67-9a65-c970305bd771', 'Oksana', 'Hvala. Možete li voziti malo brže? Žurim se.', 'Дякую. Можете їхати трохи швидше? Я поспішаю.', 2);
  perform pg_temp.turn('5ab2b8e6-0eab-5ecb-b5d0-8e30ae5eb0f6', '40840853-432e-5f67-9a65-c970305bd771', 'Taksist', 'Ima gužve, ali stižemo na vrijeme.', 'Є затор, але ми встигаємо вчасно.', 3);
  perform pg_temp.turn('cb277687-7dcc-5717-b471-203ceb35663d', '40840853-432e-5f67-9a65-c970305bd771', 'Oksana', 'Stanite ovdje, molim. Koliko plaćam?', 'Зупиніться тут, будь ласка. Скільки з мене?', 4);
  perform pg_temp.turn('3cd93f08-5406-5209-92a3-6c0c5f7b4f28', '40840853-432e-5f67-9a65-c970305bd771', 'Taksist', 'Dvanaest eura.', 'Дванадцять євро.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 20: Заправка й паркування
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'd6ca64d8-4c71-5936-a930-51e400f5681d';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.4: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.4.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 20: Заправка й паркування', 'Lekcija 20: Benzinska i parkiranje', '["Заправити машину", "Запитати, чи можна тут паркуватися", "Вживати smijem li, moram"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'auto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'benzinska postaja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'benzin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dizel', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rezervoar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'guma', v_pos);
  v_pos := pg_temp.word(v_lesson, 'provjeriti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'parkirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zona', v_pos);
  v_pos := pg_temp.word(v_lesson, 'automat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kazna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pun', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '619e50e5-b4a2-5480-844e-201ae7798a01', 'fill_in_the_blank', 'Mi ___ platiti parking.', 'moramo', '["moraju", "moram", "moramo", "moraš"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '55c87292-dfcb-5563-920b-ae3b64dce1b6', 'multiple_choice', 'Що означає «rezervoar»?', 'бак (паливний)', '["автомат (паркомат, автомат з продажу)", "бак (паливний)", "перевірити", "штраф / покарання"]'::jsonb, 'A1', 2, 'PUBLISHED', 'rezervoar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd2fb5076-ed0d-579f-9611-b16fdf9f5bcb', 'multiple_choice', 'Що означає «automat»?', 'автомат (паркомат, автомат з продажу)', '["штраф / покарання", "зона", "паркуватися", "автомат (паркомат, автомат з продажу)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'automat', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '260037eb-4f7d-59ca-b322-c86cb53372f2', 'multiple_choice', 'Як хорватською «паркуватися»?', 'parkirati', '["benzinska postaja", "parkirati", "dizel", "auto"]'::jsonb, 'A1', 4, 'PUBLISHED', 'parkirati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2dcc5d2b-a55f-5ac6-affd-4fc8448d7b41', 'type_answer', 'Напишіть хорватською: «штраф / покарання»', 'kazna', null, 'A1', 5, 'PUBLISHED', 'kazna', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a3556eff-72de-5b68-b2fb-759fdb091720', 'type_answer', 'Напишіть хорватською: «зона»', 'zona', null, 'A1', 6, 'PUBLISHED', 'zona', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '68c5837f-100c-5aea-a19b-714042803ced', 'sentence_builder', 'Складіть: «Дизель, повний бак, будь ласка.»', 'Dizel, pun rezervoar, molim.', '["pun", "molim.", "Dizel,", "rezervoar,"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3bade5dc-91e8-515d-8d29-f972a5fdeefb', 'sentence_builder', 'Складіть: «Мені можна тут паркуватися?»', 'Smijem li ovdje parkirati?', '["li", "ovdje", "Smijem", "parkirati?"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '07f9a9c4-2643-51c5-b64d-1b62ab1b2f18', 'listening', 'Прослухайте і складіть фразу', 'Plaćate unutra, na blagajni.', '["unutra,", "Plaćate", "blagajni.", "na"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a157a95e-2f37-5649-98aa-29ae2d29f29e', 'listening', 'Прослухайте і складіть фразу', 'Gdje je automat?', '["automat?", "Gdje", "je"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '717bf3b0-897c-5a94-9e57-9f8270cf2260', 'speaking', 'Де заправка?', 'Gdje je benzinska postaja?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3e904d4a-579f-545e-b4e5-fb35ade4c254', 'speaking', 'Тут треба платити?', 'Moram li ovdje platiti?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('563e541a-ac09-5faf-bc22-75c0b21594c5', v_lesson, 'На заправці', 'Na benzinskoj', 1201, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('dcb5c234-1331-5b88-9383-218628abe1d1', '563e541a-ac09-5faf-bc22-75c0b21594c5', 'Radnik', 'Dobar dan! Benzin ili dizel?', 'Добрий день! Бензин чи дизель?', 1);
  perform pg_temp.turn('0947b7c7-8481-59be-ac65-59b696336d4e', '563e541a-ac09-5faf-bc22-75c0b21594c5', 'Taras', 'Dizel, pun rezervoar, molim.', 'Дизель, повний бак, будь ласка.', 2);
  perform pg_temp.turn('36ce15cd-3874-5305-8f9c-f86c1abb46fb', '563e541a-ac09-5faf-bc22-75c0b21594c5', 'Radnik', 'Plaćate unutra, na blagajni.', 'Платите всередині, на касі.', 3);
  perform pg_temp.turn('617213f4-0e2a-5252-bc74-5f65794beb6a', '563e541a-ac09-5faf-bc22-75c0b21594c5', 'Taras', 'Mogu li ovdje provjeriti gume?', 'Чи можу я тут перевірити шини?', 4);
  perform pg_temp.turn('ceb395d8-098b-503b-8bf9-7e71e19d4de9', '563e541a-ac09-5faf-bc22-75c0b21594c5', 'Radnik', 'Možete, zrak je iza postaje.', 'Можете, повітря — за заправкою.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8fff3581-695c-50fd-8ec0-fdde50e3b3df', v_lesson, 'Де можна паркуватися?', 'Gdje smijem parkirati?', 1202, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('572df6b3-43cb-5924-ab76-9f15d3841e5b', '8fff3581-695c-50fd-8ec0-fdde50e3b3df', 'Iryna', 'Oprostite, smijem li ovdje parkirati?', 'Вибачте, мені можна тут паркуватися?', 1);
  perform pg_temp.turn('1707de0f-36d6-53e8-8a50-2fbf4c82c5e8', '8fff3581-695c-50fd-8ec0-fdde50e3b3df', 'Prolaznik', 'Smijete, ali morate platiti. Ovo je druga zona.', 'Можна, але треба заплатити. Це друга зона.', 2);
  perform pg_temp.turn('20ee163e-bed2-52df-a3fb-481c57b272f7', '8fff3581-695c-50fd-8ec0-fdde50e3b3df', 'Iryna', 'Gdje je automat?', 'Де паркомат?', 3);
  perform pg_temp.turn('86fd9344-9f0a-5a70-a2bf-5865de5d1d72', '8fff3581-695c-50fd-8ec0-fdde50e3b3df', 'Prolaznik', 'Tamo. Ili platite SMS-om.', 'Он там. Або заплатіть через SMS.', 4);
  perform pg_temp.turn('9aa1bcd0-e152-52ee-8dc8-0f22ae051eb3', '8fff3581-695c-50fd-8ec0-fdde50e3b3df', 'Iryna', 'Hvala! Ne želim kaznu.', 'Дякую! Не хочу штрафу.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 21: Шукаю квартиру
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '278947e3-ae50-5818-abd7-7f07b8ab5c44';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.5: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '765ac66f-d54b-505b-9b11-c48e5ad26018';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.5.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 21: Шукаю квартиру', 'Lekcija 21: Tražim stan', '["Зателефонувати щодо оголошення", "Запитати про оренду, заставу й комунальні", "Поєднувати думки: i, ali, jer"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'stan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najam', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najamnina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'režije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'namješten', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polog', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dizalo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'garaža', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stanodavac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'useliti se', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '09fad40f-2d4e-5317-8001-0f68cf481e69', 'fill_in_the_blank', 'Stan je lijep, ___ je skup.', 'ali', '["ali", "ili", "jer", "i"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '576ca0d4-188a-5566-8b90-49987a29be7b', 'multiple_choice', 'Що означає «stanodavac»?', 'власник житла / орендодавець', '["власник житла / орендодавець", "комунальні послуги / рахунки", "договір / контракт", "в''їхати (в житло)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'stanodavac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2941c116-ca5f-5514-9c9f-f0bf17c1f384', 'multiple_choice', 'Що означає «režije»?', 'комунальні послуги / рахунки', '["поверх", "комунальні послуги / рахунки", "орендна плата / квартплата", "оренда"]'::jsonb, 'A1', 3, 'PUBLISHED', 'režije', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5c3b1dc8-da30-5772-b437-c41cefc88564', 'multiple_choice', 'Як хорватською «гараж»?', 'garaža', '["useliti se", "garaža", "režije", "namješten"]'::jsonb, 'A1', 4, 'PUBLISHED', 'garaža', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9c085aa2-e725-5454-aa8f-ccc5958d13ba', 'type_answer', 'Напишіть хорватською: «поверх»', 'kat', null, 'A1', 5, 'PUBLISHED', 'kat', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c52e4b12-45dc-5ec0-a96d-1b385fb86b7c', 'type_answer', 'Напишіть хорватською: «застава / депозит»', 'polog', null, 'A1', 6, 'PUBLISHED', 'polog', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9fb2edbd-b484-57d8-aa98-788f8680f427', 'sentence_builder', 'Складіть: «Квартира ще вільна.»', 'Stan je još slobodan.', '["je", "još", "slobodan.", "Stan"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9c9ca28b-98c1-5395-9fef-6919e7ee78b8', 'sentence_builder', 'Складіть: «Мені подобається, бо вона світла.»', 'Sviđa mi se jer je svijetao.', '["mi", "je", "jer", "Sviđa", "svijetao.", "se"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bd25dad4-e17b-50d0-9f7b-f88bdca55700', 'listening', 'Прослухайте і складіть фразу', 'Je li namješten?', '["namješten?", "Je", "li"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aeffce8b-a604-5401-8f60-16921bd82762', 'listening', 'Прослухайте і складіть фразу', 'Polog je jedna najamnina.', '["najamnina.", "Polog", "je", "jedna"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '623107eb-d795-513a-ac9d-b517a602520d', 'speaking', 'Скільки коштує оренда?', 'Koliko je najamnina?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '77789058-042a-5e38-a769-ab6c94332edc', 'speaking', 'Квартира гарна, але дорога.', 'Stan je lijep, ali skup.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b168f346-76bc-5225-8397-42b6b17bac28', v_lesson, 'Дзвінок щодо оголошення', 'Poziv zbog oglasa', 1211, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('44d7eeb1-9b3d-5080-9eca-54ab6574a0e1', 'b168f346-76bc-5225-8397-42b6b17bac28', 'Oksana', 'Dobar dan, zovem zbog oglasa za stan.', 'Добрий день, я телефоную щодо оголошення про квартиру.', 1);
  perform pg_temp.turn('c68ca67f-08c3-596a-a2fc-38533d8cf70e', 'b168f346-76bc-5225-8397-42b6b17bac28', 'Stanodavac', 'Da, stan je još slobodan.', 'Так, квартира ще вільна.', 2);
  perform pg_temp.turn('217151df-b434-5852-936f-0c635806cf67', 'b168f346-76bc-5225-8397-42b6b17bac28', 'Oksana', 'Je li namješten?', 'Вона мебльована?', 3);
  perform pg_temp.turn('88fbe72a-0e74-54d4-b631-72f432fa910d', 'b168f346-76bc-5225-8397-42b6b17bac28', 'Stanodavac', 'Jest, ali nema perilice.', 'Так, але немає пральної машини.', 4);
  perform pg_temp.turn('26f9e522-0498-5366-8ad8-76d31e9d304b', 'b168f346-76bc-5225-8397-42b6b17bac28', 'Oksana', 'Koliko je najamnina?', 'Скільки коштує оренда?', 5);
  perform pg_temp.turn('a7ec4721-b85c-53fa-b6ab-21d41587ef01', 'b168f346-76bc-5225-8397-42b6b17bac28', 'Stanodavac', 'Petsto pedeset eura i režije.', 'П’ятсот п’ятдесят євро плюс комунальні.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b5990243-0ca2-513d-82bc-5693910cde2a', v_lesson, 'Огляд квартири', 'Razgled stana', 1212, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('0b3d6462-cfac-58e2-80fe-8600fbfc7ba2', 'b5990243-0ca2-513d-82bc-5693910cde2a', 'Stanodavac', 'Stan je na trećem katu, a dizalo radi.', 'Квартира на третьому поверсі, і ліфт працює.', 1);
  perform pg_temp.turn('116505f8-f8e9-5e45-8b02-d2588c06d49c', 'b5990243-0ca2-513d-82bc-5693910cde2a', 'Oksana', 'Sviđa mi se jer je svijetao.', 'Мені подобається, бо вона світла.', 2);
  perform pg_temp.turn('b995e8b8-b7f3-5e9d-8649-b99f7a99e482', 'b5990243-0ca2-513d-82bc-5693910cde2a', 'Stanodavac', 'Polog je jedna najamnina.', 'Застава — одна місячна оплата.', 3);
  perform pg_temp.turn('eae6b635-506e-592b-9892-0cdb8455e66b', 'b5990243-0ca2-513d-82bc-5693910cde2a', 'Oksana', 'Mogu li se useliti prvog?', 'Чи можу я в’їхати першого числа?', 4);
  perform pg_temp.turn('c9c63d86-ddbb-5729-a2c3-ee0396d123df', 'b5990243-0ca2-513d-82bc-5693910cde2a', 'Stanodavac', 'Možete. Ugovor potpisujemo sutra.', 'Можете. Договір підписуємо завтра.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 22: Щось не працює
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '8fc3399d-0405-5517-9358-d3ad6308d860';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.5: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.5.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 22: Щось не працює', 'Lekcija 22: Nešto ne radi', '["Пояснити орендодавцю, що зламалося", "Домовитися про прихід майстра", "Сказати, де проблема: u kupaonici, u kuhinji"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kvar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'popraviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'majstor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grijanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'struja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'perilica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tuš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hladnjak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupaonica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kuhinja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'utičnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'voda', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c68404e1-46eb-54d4-8d23-78d7d47bff64', 'fill_in_the_blank', 'Problem je u ___.', 'kuhinji', '["kuhinje", "kuhinju", "kuhinji", "kuhinja"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eae06fb7-dc5c-5fc1-86ce-ee4a6d964036', 'multiple_choice', 'Що означає «perilica»?', 'пральна машина', '["кухня", "майстер", "ванна кімната", "пральна машина"]'::jsonb, 'A1', 2, 'PUBLISHED', 'perilica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd112938f-fa9d-5411-9129-fc21954d2a29', 'multiple_choice', 'Що означає «voda»?', 'вода', '["холодильник", "опалення", "вода", "пральна машина"]'::jsonb, 'A1', 3, 'PUBLISHED', 'voda', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e4c525b3-385a-5411-8fc1-045f7691e932', 'multiple_choice', 'Як хорватською «опалення»?', 'grijanje', '["hladnjak", "utičnica", "kvar", "grijanje"]'::jsonb, 'A1', 4, 'PUBLISHED', 'grijanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9eee176d-16dc-5d4c-91f1-30416660553c', 'type_answer', 'Напишіть хорватською: «кухня»', 'kuhinja', null, 'A1', 5, 'PUBLISHED', 'kuhinja', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '511d0913-e787-5a27-b98d-881d5218f305', 'type_answer', 'Напишіть хорватською: «холодильник»', 'hladnjak', null, 'A1', 6, 'PUBLISHED', 'hladnjak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '60896779-d711-5d00-898f-cf49991e5ea3', 'sentence_builder', 'Складіть: «У ванній щось не працює.»', 'U kupaonici nešto ne radi.', '["ne", "nešto", "radi.", "U", "kupaonici"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '65b9c819-b8fc-5537-b432-61bc812817a6', 'sentence_builder', 'Складіть: «Холодильник не охолоджує.»', 'Hladnjak ne hladi.', '["ne", "hladi.", "Hladnjak"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b593363c-3481-5546-8556-86108348bfc9', 'listening', 'Прослухайте і складіть фразу', 'Tuš. Nema tople vode.', '["tople", "Tuš.", "vode.", "Nema"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '42f3a007-3a50-5d5f-86f4-2d838422cd9f', 'listening', 'Прослухайте і складіть фразу', 'A struja? Je li utičnica u redu?', '["Je", "li", "redu?", "A", "utičnica", "struja?", "u"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aaa3b616-3655-59f9-8f0f-fbe3359f0832', 'speaking', 'Холодильник не працює.', 'Hladnjak ne radi.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a8d97ec9-aede-57c0-85e0-b866482e136b', 'speaking', 'Я вдома після п’ятої.', 'Doma sam poslije pet.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('44dab520-fbf0-5338-b23c-bb81cb058602', v_lesson, 'Дзвінок орендодавцю', 'Poziv stanodavcu', 1221, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('b19e06c6-af7f-52df-bcec-3d871891df91', '44dab520-fbf0-5338-b23c-bb81cb058602', 'Andrij', 'Dobar dan, gospodine Horvat. U kupaonici nešto ne radi.', 'Добрий день, пане Горват. У ванній щось не працює.', 1);
  perform pg_temp.turn('e1d5d19b-9136-5946-9d47-1f64876922ea', '44dab520-fbf0-5338-b23c-bb81cb058602', 'Stanodavac', 'Što točno?', 'Що саме?', 2);
  perform pg_temp.turn('821d9f16-0af6-5b0a-8c9f-475913c3b3eb', '44dab520-fbf0-5338-b23c-bb81cb058602', 'Andrij', 'Tuš. Nema tople vode.', 'Душ. Немає гарячої води.', 3);
  perform pg_temp.turn('d0445922-72f5-5350-b788-c339b894bb4f', '44dab520-fbf0-5338-b23c-bb81cb058602', 'Stanodavac', 'Sutra šaljem majstora.', 'Завтра надішлю майстра.', 4);
  perform pg_temp.turn('c30d6bf5-6b0b-53f5-a05b-46ba20435ca2', '44dab520-fbf0-5338-b23c-bb81cb058602', 'Andrij', 'Hvala. Ja sam doma poslije pet.', 'Дякую. Я вдома після п’ятої.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('98101c6a-101b-5e5a-bd6f-35abb0296ce0', v_lesson, 'Майстер', 'Majstor', 1222, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('e0d45f68-5d3f-5800-a776-da3c571b9e9d', '98101c6a-101b-5e5a-bd6f-35abb0296ce0', 'Majstor', 'Gdje je problem?', 'Де проблема?', 1);
  perform pg_temp.turn('3c37393e-4cc7-5ba4-8b30-47496d53084f', '98101c6a-101b-5e5a-bd6f-35abb0296ce0', 'Andrij', 'U kuhinji. Hladnjak ne hladi.', 'На кухні. Холодильник не охолоджує.', 2);
  perform pg_temp.turn('59e6aa25-b799-548c-9f5c-bcbe7e299407', '98101c6a-101b-5e5a-bd6f-35abb0296ce0', 'Majstor', 'A struja? Je li utičnica u redu?', 'А електрика? Розетка в порядку?', 3);
  perform pg_temp.turn('0d52456f-1fc0-5824-b891-9017c97dd999', '98101c6a-101b-5e5a-bd6f-35abb0296ce0', 'Andrij', 'Mislim da jest.', 'Думаю, що так.', 4);
  perform pg_temp.turn('26b4dccc-af71-55e2-995e-cf2b2463e7aa', '98101c6a-101b-5e5a-bd6f-35abb0296ce0', 'Majstor', 'Dobro, sad gledam.', 'Добре, зараз подивлюся.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 23: Новий сусід
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'a42b9121-2ec0-5064-909b-f59f315b3c4a';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.5: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.5.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 23: Новий сусід', 'Lekcija 23: Novi susjed', '["Познайомитися із сусідом", "Запитати про правила будинку", "Ввічливо попросити: stišajte, nemojte"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'susjed', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smeće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kanta za smeće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'buka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tiho', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glasno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stepenice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvono', v_pos);
  v_pos := pg_temp.word(v_lesson, 'parkiralište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upoznati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pozdraviti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '6994db6c-1567-51bf-8e95-1e117c2f3fe3', 'fill_in_the_blank', 'Molim Vas, ___ glazbu.', 'stišajte', '["stišati", "stišaju", "stišam", "stišajte"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd9a2325d-82c4-58e7-8bfe-b73f9fdd2716', 'multiple_choice', 'Що означає «smeće»?', 'сміття', '["сусід", "голосно", "шум", "сміття"]'::jsonb, 'A1', 2, 'PUBLISHED', 'smeće', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '429d246d-7882-5fa5-965c-adc3c1d60534', 'multiple_choice', 'Що означає «parkiralište»?', 'автостоянка / парковка', '["шум", "познайомитися / пізнати", "автостоянка / парковка", "тихо"]'::jsonb, 'A1', 3, 'PUBLISHED', 'parkiralište', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '009a1a53-87c8-5f38-9bee-4c9ebe65e048', 'multiple_choice', 'Як хорватською «шум»?', 'buka', '["vrata", "glasno", "smeće", "buka"]'::jsonb, 'A1', 4, 'PUBLISHED', 'buka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '66970083-6969-55e7-a251-f7c564162793', 'type_answer', 'Напишіть хорватською: «познайомитися / пізнати»', 'upoznati', null, 'A1', 5, 'PUBLISHED', 'upoznati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '90ea7387-0cdf-5ab7-866b-d3763494c27b', 'type_answer', 'Напишіть хорватською: «двері»', 'vrata', null, 'A1', 6, 'PUBLISHED', 'vrata', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4e89e9ef-9d47-5486-ab99-534cf0ff297e', 'sentence_builder', 'Складіть: «Я живу на другому поверсі.»', 'Živim na drugom katu.', '["drugom", "Živim", "katu.", "na"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '92244612-6441-5e98-96e8-60d43f71edad', 'sentence_builder', 'Складіть: «Розумію, зараз вимкну.»', 'Razumijem, odmah gasim.', '["Razumijem,", "gasim.", "odmah"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '791d1f1e-db5d-5bff-8903-432f586cfe7a', 'listening', 'Прослухайте і складіть фразу', 'Dolje, pored parkirališta.', '["parkirališta.", "pored", "Dolje,"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '54c226d7-12bc-5d2b-a764-d4d329e707ef', 'listening', 'Прослухайте і складіть фразу', 'Jest. Djeca već spavaju.', '["spavaju.", "Djeca", "Jest.", "već"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa9e666d-673b-517a-ab28-8a1fa5ff3b08', 'speaking', 'Я ваш новий сусід.', 'Ja sam Vaš novi susjed.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dfd4ef87-1511-591f-af51-4164a8079625', 'speaking', 'Не паркуйтеся тут, будь ласка.', 'Molim Vas, nemojte parkirati ovdje.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1f226b65-81ec-57ff-94a0-9dd29e532379', v_lesson, 'Знайомство на сходах', 'Na stepenicama', 1231, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('a33403bb-a21c-55ca-8aa3-804a590612fd', '1f226b65-81ec-57ff-94a0-9dd29e532379', 'Susjeda', 'Dobar dan! Vi ste novi susjed?', 'Добрий день! Ви новий сусід?', 1);
  perform pg_temp.turn('3236fcfc-2ef6-5ffd-9ef7-053c01d7d544', '1f226b65-81ec-57ff-94a0-9dd29e532379', 'Taras', 'Da, ja sam Taras. Živim na drugom katu.', 'Так, я Тарас. Живу на другому поверсі.', 2);
  perform pg_temp.turn('f741e895-1b8b-5bd7-abe9-05452767f4e8', '1f226b65-81ec-57ff-94a0-9dd29e532379', 'Susjeda', 'Ja sam Ana, iz stana pet. Drago mi je!', 'Я Ана, з п’ятої квартири. Приємно познайомитися!', 3);
  perform pg_temp.turn('9f58f104-d35e-5311-b9a7-dfce2276cddf', '1f226b65-81ec-57ff-94a0-9dd29e532379', 'Taras', 'I meni. Gdje bacamo smeće?', 'Мені теж. Куди ми викидаємо сміття?', 4);
  perform pg_temp.turn('afca38f3-bacd-5e2d-a68f-b9736cc32554', '1f226b65-81ec-57ff-94a0-9dd29e532379', 'Susjeda', 'Dolje, pored parkirališta. Plava kanta je za papir.', 'Унизу, біля парковки. Синій бак — для паперу.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('14cae966-24cb-55f9-99e5-08012cc7ca02', v_lesson, 'Тихіше, будь ласка', 'Malo tiše, molim', 1232, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('e450580c-7bb1-5adc-8982-ea058a87d6ba', '14cae966-24cb-55f9-99e5-08012cc7ca02', 'Susjed', 'Oprostite, molim Vas, stišajte glazbu.', 'Перепрошую, будь ласка, зробіть музику тихіше.', 1);
  perform pg_temp.turn('2a5ec911-2597-5e15-97f5-8c3a571dfdc7', '14cae966-24cb-55f9-99e5-08012cc7ca02', 'Iryna', 'Oprostite! Je li preglasna?', 'Вибачте! Занадто гучно?', 2);
  perform pg_temp.turn('c245addb-397a-5b95-8a9a-a30b6a41fad4', '14cae966-24cb-55f9-99e5-08012cc7ca02', 'Susjed', 'Jest. Djeca već spavaju.', 'Так. Діти вже сплять.', 3);
  perform pg_temp.turn('df06f9a4-80d6-5789-b459-7ee6ac960bcb', '14cae966-24cb-55f9-99e5-08012cc7ca02', 'Iryna', 'Razumijem, odmah gasim.', 'Розумію, зараз вимкну.', 4);
  perform pg_temp.turn('44cb9f6d-1238-5f4e-860b-c080b395e1f1', '14cae966-24cb-55f9-99e5-08012cc7ca02', 'Susjed', 'Hvala i laku noć!', 'Дякую і на добраніч!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 24: Рахунки й інтернет
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'b69a8cca-4918-562f-8ae5-22f8d7ba2f76';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.5: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.5.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 24: Рахунки й інтернет', 'Lekcija 24: Računi i internet', '["Дізнатися, хто платить комунальні", "Оплатити квитанцію", "Повідомити, що не працює інтернет"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'račun za struju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uplatnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mobilno bankarstvo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'internet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ruter', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uključen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lozinka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tehničar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'korisnik', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'abbcf325-4ccc-5f57-90e5-fe6a1e7877fc', 'fill_in_the_blank', '___ internet ne radi.', 'Naš', '["Našu", "Naše", "Naša", "Naš"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a6b35c31-ce4a-5c52-b722-5d1231ae388a', 'multiple_choice', 'Що означає «korisnik»?', 'користувач', '["рахунок за електрику", "користувач", "пароль", "увімкнений; включений"]'::jsonb, 'A1', 2, 'PUBLISHED', 'korisnik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eb8ddbeb-8e43-5fe0-8857-f54bcc541fa6', 'multiple_choice', 'Що означає «rok»?', 'дедлайн / термін', '["платіжна квитанція", "дедлайн / термін", "мобільний банкінг", "роутер"]'::jsonb, 'A1', 3, 'PUBLISHED', 'rok', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '40f6eaff-8bd1-574d-966a-35778028507f', 'multiple_choice', 'Як хорватською «увімкнений; включений»?', 'uključen', '["mobilno bankarstvo", "uključen", "uplatnica", "tehničar"]'::jsonb, 'A1', 4, 'PUBLISHED', 'uključen', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7864ba4c-309f-5b8d-bade-645f05e2d461', 'type_answer', 'Напишіть хорватською: «газ»', 'plin', null, 'A1', 5, 'PUBLISHED', 'plin', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9192df41-9524-59de-aef9-184d3963371c', 'type_answer', 'Напишіть хорватською: «пароль»', 'lozinka', null, 'A1', 6, 'PUBLISHED', 'lozinka', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa95942f-353b-5376-9556-d3b539b94dd0', 'sentence_builder', 'Складіть: «Хто оплачує рахунок?»', 'Tko plaća račun?', '["plaća", "Tko", "račun?"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '671d5912-e90c-5b27-b860-8462b933098b', 'sentence_builder', 'Складіть: «Наш інтернет не працює.»', 'Naš internet ne radi.', '["Naš", "ne", "radi.", "internet"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e18600c-40d5-5ebe-b7de-750734aac4d0', 'listening', 'Прослухайте і складіть фразу', 'Koji je rok?', '["rok?", "Koji", "je"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a8a3a50-b691-5f2e-8e83-9c2765fc24d6', 'listening', 'Прослухайте і складіть фразу', 'Je li ruter uključen?', '["ruter", "li", "uključen?", "Je"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '85b09878-f3b1-52be-b7f3-3a0e3a90b2ac', 'speaking', 'Як я можу заплатити?', 'Kako mogu platiti?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ac797985-e910-5ef5-a87b-289a4a5e7055', 'speaking', 'Роутер не працює.', 'Ruter ne radi.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d7d11f11-7094-5b3a-840a-2bb3b3a2efbb', v_lesson, 'Рахунок за електрику', 'Račun za struju', 1241, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('16590664-dc33-5268-8823-d39c844a84a1', 'd7d11f11-7094-5b3a-840a-2bb3b3a2efbb', 'Oksana', 'Gospodine Horvat, imam račun za struju. Tko ga plaća?', 'Пане Горват, у мене рахунок за електрику. Хто його оплачує?', 1);
  perform pg_temp.turn('47f10afc-214a-5b39-9e19-0dfc48a5bc85', 'd7d11f11-7094-5b3a-840a-2bb3b3a2efbb', 'Stanodavac', 'Vi plaćate struju i plin, a ja vodu.', 'Ви платите за електрику й газ, а я — за воду.', 2);
  perform pg_temp.turn('ebabde22-e5db-5892-b02a-35c65d839680', 'd7d11f11-7094-5b3a-840a-2bb3b3a2efbb', 'Oksana', 'Kako mogu platiti uplatnicu?', 'Як я можу оплатити квитанцію?', 3);
  perform pg_temp.turn('969b74e8-325b-5ca0-8e78-642e8d52cb26', 'd7d11f11-7094-5b3a-840a-2bb3b3a2efbb', 'Stanodavac', 'U banci, na pošti ili mobilnim bankarstvom.', 'У банку, на пошті або через мобільний банкінг.', 4);
  perform pg_temp.turn('2fc3ef96-c073-5d8f-bc5b-8250648ab310', 'd7d11f11-7094-5b3a-840a-2bb3b3a2efbb', 'Oksana', 'Koji je rok?', 'Який термін?', 5);
  perform pg_temp.turn('63805cf2-2efb-5604-9dc6-555561ceb481', 'd7d11f11-7094-5b3a-840a-2bb3b3a2efbb', 'Stanodavac', 'Do petnaestog u mjesecu.', 'До п’ятнадцятого числа.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('770a1204-d504-51d5-b6f7-ff6d234aee5b', v_lesson, 'Інтернет не працює', 'Internet ne radi', 1242, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  perform pg_temp.turn('5757e7af-9031-51eb-8796-8624abd326c6', '770a1204-d504-51d5-b6f7-ff6d234aee5b', 'Taras', 'Dobar dan, naš internet ne radi od jutra.', 'Добрий день, наш інтернет не працює з ранку.', 1);
  perform pg_temp.turn('4f618ef0-50c6-570f-82b8-83a7664f1b2b', '770a1204-d504-51d5-b6f7-ff6d234aee5b', 'Operaterka', 'Je li ruter uključen?', 'Роутер увімкнений?', 2);
  perform pg_temp.turn('ebc17163-086a-5735-bf10-28bfe262af74', '770a1204-d504-51d5-b6f7-ff6d234aee5b', 'Taras', 'Jest, ali lampica je crvena. I lozinka ne radi.', 'Так, але лампочка червона. І пароль не підходить.', 3);
  perform pg_temp.turn('b8725c06-1006-51e4-be8a-cbde0eb78ad3', '770a1204-d504-51d5-b6f7-ff6d234aee5b', 'Operaterka', 'Sutra šaljemo tehničara. Vaš broj korisnika, molim?', 'Завтра надішлемо техніка. Ваш номер абонента, будь ласка?', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- Самоперевірка частини 1: якщо щось не так — усе відкочується
do $$
declare v_lessons int;
begin
  select count(*) into v_lessons from public.lessons l join public.units u on u.id = l.unit_id
    join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index between 1 and 5;
  if v_lessons < 24 then raise exception 'A1.1–A1.5: уроків %, очікувалось 24', v_lessons; end if;
  raise notice 'Частина 1 готова: уроків у A1.1–A1.5 — %. Тепер запустіть частину 2.', v_lessons;
end $$;

commit;
