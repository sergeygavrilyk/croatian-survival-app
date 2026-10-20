-- =====================================================================
-- Уроки A0 за темою · curriculum_a0_v4 · модуль A0.2 · 2026-10-19
-- Згенеровано: python3 scripts/gen_curriculum_a0_v4.py (не редагуйте вручну).
--
-- Рішення власника 2026-10-15: слова уроку — за темою уроку, 20–25 слів і виразів, діалоги під тему; бета (PUBLISHED).
--   * Уроки 5–13: 5 наявних перебудовано, 4 нових тематичних уроків. Слів у них: 195.
--     Кожен: 20–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 58.
--   * Новий порядок уроків у модулі; назви всіх уроків A0 перенумеровано підряд (разом 51).
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
values ('nadimak', 'nadimak', 'hr', 'noun', 'A0', 'прізвисько; коротке ім’я', 'core', '{"gender": "m", "plural": "nadimci"}'::jsonb, '["Ime mi je Aleksandar, a nadimak Saša."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gospođica', 'gospodica', 'hr', 'noun', 'A0', 'панна (ввічливо до молодої жінки)', 'core', '{"gender": "f"}'::jsonb, '["Gospođice, izvolite, ovo je Vaša karta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('posjetnica', 'posjetnica', 'hr', 'noun', 'A0', 'візитівка', 'core', '{"gender": "f"}'::jsonb, '["Evo moje posjetnice, tu je moj broj telefona."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('upoznavanje', 'upoznavanje', 'hr', 'noun', 'A0', 'знайомство', 'core', '{"gender": "n"}'::jsonb, '["Upoznavanje s novim kolegama nije uvijek lako."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kako ste rekli', 'kako ste rekli', 'hr', 'phrase', 'A0', 'як ви сказали?', 'chunk', '{}'::jsonb, '["Oprostite, kako ste rekli? Ne čujem dobro."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('i meni', 'i meni', 'hr', 'phrase', 'A0', 'і мені (теж); навзаєм', 'formulaic', '{}'::jsonb, '["Drago mi je! — I meni."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ovo je', 'ovo je', 'hr', 'phrase', 'A0', 'це… (коли когось представляєте)', 'chunk', '{}'::jsonb, '["Ovo je moja prijateljica Daša."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('susjeda', 'susjeda', 'hr', 'noun', 'A0', 'сусідка', 'core', '{"gender": "f", "plural": "susjede"}'::jsonb, '["Moja susjeda ima malog psa."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('svi', 'svi', 'hr', 'pronoun', 'A0', 'усі; всі', 'function_word', '{"f": "sve", "n": "sva"}'::jsonb, '["Svi su već ovdje, idemo!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kakav', 'kakav', 'hr', 'pronoun', 'A0', 'який? (якої якості)', 'function_word', '{"f": "kakva", "n": "kakvo"}'::jsonb, '["Kakav je tvoj novi stan?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('je li', 'je li', 'hr', 'phrase', 'A0', 'чи…? (на початку питання)', 'function_word', '{}'::jsonb, '["Je li ovo autobus za centar?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('od kada', 'od kada', 'hr', 'phrase', 'A0', 'відколи; з якого часу', 'chunk', '{}'::jsonb, '["Od kada učiš hrvatski?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('do kada', 'do kada', 'hr', 'phrase', 'A0', 'доки; до якого часу', 'chunk', '{}'::jsonb, '["Do kada radi pošta?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('koliko dugo', 'koliko dugo', 'hr', 'phrase', 'A0', 'як довго', 'chunk', '{}'::jsonb, '["Koliko dugo živiš u Zagrebu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('što je to', 'sto je to', 'hr', 'phrase', 'A0', 'що це?', 'chunk', '{}'::jsonb, '["Što je to na stolu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odakle si', 'odakle si', 'hr', 'phrase', 'A0', 'звідки ти', 'chunk', '{}'::jsonb, '["Odakle si? — Iz Ukrajine."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rodom', 'rodom', 'hr', 'adverb', 'A0', 'родом (звідкись)', 'core', '{}'::jsonb, '["Rodom sam iz Odese, ali živim u Splitu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rođen', 'roden', 'hr', 'adjective', 'A0', 'народжений (жін.: rođena)', 'core', '{"f": "rođena", "n": "rođeno"}'::jsonb, '["Rođen sam u Kijevu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rodni grad', 'rodni grad', 'hr', 'phrase', 'A0', 'рідне місто', 'collocation', '{}'::jsonb, '["Moj rodni grad je mali, ali jako lijep."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('preseliti se', 'preseliti se', 'hr', 'verb', 'A0', 'переїхати (на нове місце)', 'core', '{"aspect": "pf", "present": {"1s": "preselim se", "2s": "preseliš se", "3s": "preseli se"}, "past": "preselio se"}'::jsonb, '["Prošle godine smo se preselili u Rijeku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kontinent', 'kontinent', 'hr', 'noun', 'A0', 'континент', 'core', '{"gender": "m"}'::jsonb, '["Afrika je veliki kontinent."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Europa', 'europa', 'hr', 'noun', 'A0', 'Європа', 'core', '{"gender": "f", "loc": "u Europi"}'::jsonb, '["Hrvatska je u Europi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Azija', 'azija', 'hr', 'noun', 'A0', 'Азія', 'core', '{"gender": "f", "loc": "u Aziji"}'::jsonb, '["Kina i Japan su u Aziji."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Afrika', 'afrika', 'hr', 'noun', 'A0', 'Африка', 'core', '{"gender": "f", "loc": "u Africi"}'::jsonb, '["Egipat je u Africi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Amerika', 'amerika', 'hr', 'noun', 'A0', 'Америка', 'core', '{"gender": "f", "loc": "u Americi"}'::jsonb, '["Moj ujak živi u Americi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Australija', 'australija', 'hr', 'noun', 'A0', 'Австралія', 'core', '{"gender": "f", "loc": "u Australiji"}'::jsonb, '["Australija je daleko od Hrvatske."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Poljska', 'poljska', 'hr', 'noun', 'A0', 'Польща', 'core', '{"gender": "f", "loc": "u Poljskoj"}'::jsonb, '["Moja sestra radi u Poljskoj."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Italija', 'italija', 'hr', 'noun', 'A0', 'Італія', 'core', '{"gender": "f", "loc": "u Italiji"}'::jsonb, '["Ljeti putujemo u Italiju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Austrija', 'austrija', 'hr', 'noun', 'A0', 'Австрія', 'core', '{"gender": "f", "loc": "u Austriji"}'::jsonb, '["Beč je glavni grad Austrije."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Slovenija', 'slovenija', 'hr', 'noun', 'A0', 'Словенія', 'core', '{"gender": "f", "loc": "u Sloveniji"}'::jsonb, '["Slovenija graniči s Hrvatskom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Mađarska', 'madarska', 'hr', 'noun', 'A0', 'Угорщина', 'core', '{"gender": "f", "loc": "u Mađarskoj"}'::jsonb, '["Budimpešta je glavni grad Mađarske."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Srbija', 'srbija', 'hr', 'noun', 'A0', 'Сербія', 'core', '{"gender": "f", "loc": "u Srbiji"}'::jsonb, '["Beograd je glavni grad Srbije."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Bosna i Hercegovina', 'bosna i hercegovina', 'hr', 'noun', 'A0', 'Боснія і Герцеговина', 'core', '{"gender": "f", "loc": "u Bosni i Hercegovini"}'::jsonb, '["Sarajevo je glavni grad Bosne i Hercegovine."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Francuska', 'francuska', 'hr', 'noun', 'A0', 'Франція', 'core', '{"gender": "f", "loc": "u Francuskoj"}'::jsonb, '["Pariz je u Francuskoj."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Španjolska', 'spanjolska', 'hr', 'noun', 'A0', 'Іспанія', 'core', '{"gender": "f", "loc": "u Španjolskoj"}'::jsonb, '["U Španjolskoj govore španjolski."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('narodnost', 'narodnost', 'hr', 'noun', 'A0', 'національність', 'core', '{"gender": "f"}'::jsonb, '["Koje ste narodnosti? — Ukrajinka sam."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('strankinja', 'strankinja', 'hr', 'noun', 'A0', 'іноземка', 'core', '{"gender": "f"}'::jsonb, '["Ona je strankinja, ali odlično govori hrvatski."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('materinski jezik', 'materinski jezik', 'hr', 'phrase', 'A0', 'рідна мова', 'collocation', '{}'::jsonb, '["Moj materinski jezik je ukrajinski."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tečno', 'tecno', 'hr', 'adverb', 'A0', 'вільно (про мову)', 'core', '{}'::jsonb, '["Moj sin već tečno govori hrvatski."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('na hrvatskom', 'na hrvatskom', 'hr', 'phrase', 'A0', 'хорватською (мовою)', 'chunk', '{}'::jsonb, '["Kako se to kaže na hrvatskom?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gdje živite', 'gdje zivite', 'hr', 'phrase', 'A0', 'де ви живете', 'chunk', '{}'::jsonb, '["Gdje živite? — U Zagrebu, u Dubravi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prizemlje', 'prizemlje', 'hr', 'noun', 'A0', 'партер; нижній поверх (в Україні — перший)', 'core', '{"gender": "n", "loc": "u prizemlju"}'::jsonb, '["Pošta je u prizemlju zgrade."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('predgrađe', 'predgrade', 'hr', 'noun', 'A0', 'передмістя', 'core', '{"gender": "n", "loc": "u predgrađu"}'::jsonb, '["Živimo u predgrađu, a radimo u centru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stanovati', 'stanovati', 'hr', 'verb', 'A0', 'проживати; мешкати', 'core', '{"aspect": "ipf", "present": {"1s": "stanujem", "2s": "stanuješ", "3s": "stanuje"}}'::jsonb, '["Stanujem u Ulici kralja Zvonimira."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('podstanar', 'podstanar', 'hr', 'noun', 'A0', 'орендар житла', 'core', '{"gender": "m", "f_form": "podstanarka", "plural": "podstanari"}'::jsonb, '["Mi smo podstanari, stan nije naš."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('čime se bavite', 'cime se bavite', 'hr', 'phrase', 'A0', 'чим ви займаєтеся?', 'chunk', '{}'::jsonb, '["Čime se bavite? — Ja sam učiteljica."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prodavačica', 'prodavacica', 'hr', 'noun', 'A0', 'продавчиня', 'core', '{"gender": "f"}'::jsonb, '["Prodavačica je bila jako ljubazna."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('frizer', 'frizer', 'hr', 'noun', 'A0', 'перукар', 'core', '{"gender": "m", "f_form": "frizerka"}'::jsonb, '["Sutra idem frizeru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kako se osjećaš', 'kako se osjecas', 'hr', 'phrase', 'A0', 'як ти почуваєшся?', 'chunk', '{}'::jsonb, '["Kako se osjećaš danas? — Puno bolje, hvala."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('veseo', 'veseo', 'hr', 'adjective', 'A0', 'веселий', 'core', '{"f": "vesela", "n": "veselo"}'::jsonb, '["Naša susjeda je uvijek vesela."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pospan', 'pospan', 'hr', 'adjective', 'A0', 'сонний', 'core', '{"f": "pospana", "n": "pospano"}'::jsonb, '["Ujutro sam uvijek pospan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dosadno mi je', 'dosadno mi je', 'hr', 'phrase', 'A0', 'мені нудно', 'chunk', '{}'::jsonb, '["Kiša pada cijeli dan i dosadno mi je."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('hladno mi je', 'hladno mi je', 'hr', 'phrase', 'A0', 'мені холодно', 'chunk', '{}'::jsonb, '["Zatvori prozor, molim te, hladno mi je."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('loše mi je', 'lose mi je', 'hr', 'phrase', 'A0', 'мені погано', 'chunk', '{}'::jsonb, '["Loše mi je, moram sjesti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('strah me je', 'strah me je', 'hr', 'phrase', 'A0', 'мені страшно; я боюся', 'chunk', '{}'::jsonb, '["Strah me je velikih pasa."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nedostaje mi', 'nedostaje mi', 'hr', 'phrase', 'A0', 'я сумую за…; мені бракує', 'chunk', '{}'::jsonb, '["Nedostaje mi moja obitelj."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bolje', 'bolje', 'hr', 'adverb', 'A0', 'краще', 'core', '{}'::jsonb, '["Danas mi je bolje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('boli me glava', 'boli me glava', 'hr', 'phrase', 'A0', 'у мене болить голова', 'chunk', '{}'::jsonb, '["Boli me glava, imate li tabletu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;

-- 2. Перебудова наявних уроків модуля A0.2
-- A0.2 · урок 5: Як тебе звати? — перебудова: 21 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '2b6ed342-cc80-5bd9-baf0-b66109624d62';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Як тебе звати?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'd8282809-1eab-5202-8606-5a2a50e701f9') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 5: Як тебе звати?', title_hr = 'Lekcija 5: Kako se zoveš?',
         objectives = '["Назвати своє ім’я і прізвище", "Запитати ім’я на «ти» і на «ви»", "Пояснити, як пишеться ваше прізвище"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zovem se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kako se zoveš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kako se zovete', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ime', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prezime', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nadimak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'drago mi je', v_pos);
  v_pos := pg_temp.word(v_lesson, 'i meni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'također', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upoznati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upoznavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predstaviti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovo je', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gospodin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gospođa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gospođica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kako se piše', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slovo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kako ste rekli', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posjetnica', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '90b9bbb3-5fa3-5e3b-b2d1-0ea12f1039fd', 'fill_in_the_blank', 'Ja se ___ Darja.', 'zovem', '["zovete", "zove", "zovem", "zoveš"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e5831f2c-86c7-5318-b67d-fb6066e6b888', 'multiple_choice', 'Що означає «gospodin»?', 'пан', '["як ви сказали?", "пан", "і мені (теж); навзаєм", "також"]'::jsonb, 'A0', 2, 'PUBLISHED', 'gospodin', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b06bda62-b6c4-57d0-968f-35282aae1573', 'multiple_choice', 'Що означає «drago mi je»?', 'дуже приємно', '["дуже приємно", "познайомитися / пізнати", "прізвисько; коротке ім’я", "панна (ввічливо до молодої жінки)"]'::jsonb, 'A0', 3, 'PUBLISHED', 'drago mi je', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f00fdb0e-1b78-5483-924f-d878421258b3', 'multiple_choice', 'Що означає «ime»?', 'ім''я', '["як ви сказали?", "також", "і мені (теж); навзаєм", "ім''я"]'::jsonb, 'A0', 4, 'PUBLISHED', 'ime', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '46819359-e4a3-55ec-ba8e-3fa48f9caacc', 'multiple_choice', 'Як хорватською «пані»?', 'gospođa', '["također", "prezime", "kako se zoveš", "gospođa"]'::jsonb, 'A0', 5, 'PUBLISHED', 'gospođa', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bbe842a3-3919-5463-aadc-0a9b67e6fdc8', 'multiple_choice', 'Як хорватською «також»?', 'također', '["posjetnica", "zovem se", "također", "ime"]'::jsonb, 'A0', 6, 'PUBLISHED', 'također', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b7e222a9-54df-518b-b2d1-3474736318ff', 'type_answer', 'Напишіть хорватською: «візитівка»', 'posjetnica', null, 'A0', 7, 'PUBLISHED', 'posjetnica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2fe586c5-5a38-5250-8512-b08ca1d73360', 'type_answer', 'Напишіть хорватською: «знайомство»', 'upoznavanje', null, 'A0', 8, 'PUBLISHED', 'upoznavanje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8a27de24-8703-572f-a07d-aee132049067', 'type_answer', 'Напишіть хорватською: «представитися»', 'predstaviti se', null, 'A0', 9, 'PUBLISHED', 'predstaviti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '951c001a-0fd8-5043-bab7-9a72cae68114', 'sentence_builder', 'Складіть: «Моє повне ім’я — Дар’я.»', 'Moje puno ime je Darja.', '["Moje", "ime", "je", "Darja.", "puno"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eb2b3f94-c050-5697-bfd6-0a339ae1544e', 'sentence_builder', 'Складіть: «Як пишеться ваше прізвище?»', 'Kako se piše Vaše prezime?', '["prezime?", "Vaše", "piše", "Kako", "se"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f64f4b70-c600-5cbd-97e3-2c227f601d6f', 'listening', 'Прослухайте і складіть фразу', 'Ne, to je nadimak.', '["je", "Ne,", "to", "nadimak."]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '75bb960b-2f6e-506e-951b-ed0e718835c3', 'listening', 'Прослухайте і складіть фразу', 'Oprostite, kako ste rekli?', '["rekli?", "Oprostite,", "kako", "ste"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c2b74019-63c2-5173-909c-7e86c3bcfd59', 'speaking', 'Як тебе звати?', 'Kako se zoveš?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f5702243-6524-5ea7-9244-009ed4b25dea', 'speaking', 'Дуже приємно!', 'Drago mi je!', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d8282809-1eab-5202-8606-5a2a50e701f9', v_lesson, 'Знайомство на курсі', 'Upoznavanje na tečaju', 2051, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('bc3f65de-7d46-5d49-a925-221da77313ef', 'd8282809-1eab-5202-8606-5a2a50e701f9', 'Daša', 'Bok! Ja sam Daša. A kako se ti zoveš?', 'Привіт! Я Даша. А тебе як звати?', 1);
  perform pg_temp.turn('e215dbb6-3912-5cc1-ab8a-8a7ea8360aab', 'd8282809-1eab-5202-8606-5a2a50e701f9', 'Luka', 'Zovem se Luka. Drago mi je, Dašo.', 'Мене звати Лука. Приємно познайомитися, Дашо.', 2);
  perform pg_temp.turn('c37cd4e2-4620-5b64-bb15-19b3a38d9572', 'd8282809-1eab-5202-8606-5a2a50e701f9', 'Daša', 'I meni.', 'Мені теж.', 3);
  perform pg_temp.turn('7531428a-ba2c-5bc0-8dab-208178e75e79', 'd8282809-1eab-5202-8606-5a2a50e701f9', 'Luka', 'Je li Daša tvoje puno ime?', '«Даша» — це твоє повне ім’я?', 4);
  perform pg_temp.turn('17ca7a89-b8f9-59a9-9366-73ee5f083dac', 'd8282809-1eab-5202-8606-5a2a50e701f9', 'Daša', 'Ne, to je nadimak. Moje puno ime je Darja.', 'Ні, це коротке ім’я. Моє повне ім’я — Дар’я.', 5);
  perform pg_temp.turn('d79ff226-c16a-53e8-87ed-aa4f4d158443', 'd8282809-1eab-5202-8606-5a2a50e701f9', 'Luka', 'Darja? Lijepo ime!', 'Дар’я? Гарне ім’я!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0f598eed-50bd-539c-8fdd-a5634c0c4626', v_lesson, 'У банку', 'U banci', 2052, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('239d1763-0acd-5a6b-b531-3847f0fc5706', '0f598eed-50bd-539c-8fdd-a5634c0c4626', 'Gospodin Babić', 'Dobar dan, izvolite. Kako se zovete?', 'Добрий день, слухаю вас. Як вас звати?', 1);
  perform pg_temp.turn('102f6871-34f8-5bde-b6f5-573be3425fb9', '0f598eed-50bd-539c-8fdd-a5634c0c4626', 'Darja', 'Dobar dan. Zovem se Darja Kovalenko.', 'Добрий день. Мене звати Дар’я Коваленко.', 2);
  perform pg_temp.turn('65d633aa-9998-5b51-810e-79ae2502aba4', '0f598eed-50bd-539c-8fdd-a5634c0c4626', 'Gospodin Babić', 'Oprostite, kako ste rekli? Kako se piše Vaše prezime?', 'Вибачте, як ви сказали? Як пишеться ваше прізвище?', 3);
  perform pg_temp.turn('29936468-13b1-5664-a3b4-30ef8d20291b', '0f598eed-50bd-539c-8fdd-a5634c0c4626', 'Darja', 'Kovalenko. Prvo slovo je K. Izvolite moju posjetnicu.', 'Коваленко. Перша літера — К. Ось моя візитівка.', 4);
  perform pg_temp.turn('638df2fc-c948-518d-9c61-b8c9ed3d017e', '0f598eed-50bd-539c-8fdd-a5634c0c4626', 'Gospodin Babić', 'Hvala, gospođo Kovalenko. Drago mi je.', 'Дякую, пані Коваленко. Дуже приємно.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.2 · урок 8: Звідки ви? — перебудова: 21 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '04167753-db83-5163-a91c-9f71dac18ab5';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Звідки ви?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '070431f4-9139-5438-8acc-63fefe0653f0') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 8: Звідки ви?', title_hr = 'Lekcija 8: Odakle ste?',
         objectives = '["Сказати, з якої ви країни й міста", "Розповісти, коли ви переїхали до Хорватії", "Запитати співрозмовника, звідки він"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'odakle ste', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odakle si', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rodom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'doći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Ukrajina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Hrvatska', v_pos);
  v_pos := pg_temp.word(v_lesson, 'domovina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rodni grad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glavni grad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjesto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rođen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preseliti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'živjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'već', v_pos);
  v_pos := pg_temp.word(v_lesson, 'privremena zaštita', v_pos);
  v_pos := pg_temp.word(v_lesson, 'daleko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'more', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '34f009c5-3b3b-521f-a173-c33a450df396', 'fill_in_the_blank', 'Lviv ___ glavni grad Ukrajine.', 'nije', '["niste", "nije", "nisam", "nisu"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f080955e-8274-53a2-b9a3-fa7fc0cee308', 'multiple_choice', 'Що означає «Hrvatska»?', 'Хорватія', '["Хорватія", "вже", "звідки ви", "родом (звідкись)"]'::jsonb, 'A0', 2, 'PUBLISHED', 'Hrvatska', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '50e49b93-f31c-584a-9063-78a565360c76', 'multiple_choice', 'Що означає «odakle si»?', 'звідки ти', '["перед, раніше", "жити", "звідки ти", "тимчасовий захист"]'::jsonb, 'A0', 3, 'PUBLISHED', 'odakle si', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '49e5e7c2-f71a-595e-bd0a-53f526e3fa9f', 'multiple_choice', 'Що означає «već»?', 'вже', '["Хорватія", "вже", "родом (звідкись)", "прийти"]'::jsonb, 'A0', 4, 'PUBLISHED', 'već', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e69c746c-bbc6-5be3-8d88-50a5aa9a2f38', 'multiple_choice', 'Як хорватською «з (відкілясь)»?', 'iz', '["daleko", "iz", "mjesto", "doći"]'::jsonb, 'A0', 5, 'PUBLISHED', 'iz', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1ab9806a-9a73-5724-9adb-9252f913ffd3', 'multiple_choice', 'Як хорватською «прийти»?', 'doći', '["domovina", "mjesto", "iz", "doći"]'::jsonb, 'A0', 6, 'PUBLISHED', 'doći', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b7f0611b-c71c-5d2a-ac16-502fa93d10fc', 'type_answer', 'Напишіть хорватською: «столиця»', 'glavni grad', null, 'A0', 7, 'PUBLISHED', 'glavni grad', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '07196337-5e1d-5789-9796-17860a61bb31', 'type_answer', 'Напишіть хорватською: «далеко»', 'daleko', null, 'A0', 8, 'PUBLISHED', 'daleko', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '496cfd7a-25d8-56aa-93d3-cfe42c130f5b', 'type_answer', 'Напишіть хорватською: «жити»', 'živjeti', null, 'A0', 9, 'PUBLISHED', 'živjeti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'da66b159-1efc-5376-95f1-2c6cfdb41ca1', 'sentence_builder', 'Складіть: «Я родом з Одеси.»', 'Rodom sam iz Odese.', '["iz", "Rodom", "sam", "Odese."]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8e6ecbd-f17c-540d-abb8-ef62148c984b', 'sentence_builder', 'Складіть: «Я народилася в Києві.»', 'Rođena sam u Kijevu.', '["Kijevu.", "Rođena", "u", "sam"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '23c1c1fc-9e5e-5f41-9156-a9088f6547a5', 'listening', 'Прослухайте і складіть фразу', 'Ali sada živim u Zagrebu.', '["sada", "Ali", "Zagrebu.", "u", "živim"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f1c4bea-5668-565f-9682-29d152ee3136', 'listening', 'Прослухайте і складіть фразу', 'Nije. Glavni grad je Kijev.', '["je", "Kijev.", "Glavni", "grad", "Nije."]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1be39cf0-f22b-516c-9ccf-79551530b209', 'speaking', 'Я з України.', 'Ja sam iz Ukrajine.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6ad4da88-78fc-593d-80b7-e717e8096b55', 'speaking', 'Звідки ти?', 'Odakle si?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('070431f4-9139-5438-8acc-63fefe0653f0', v_lesson, 'Звідки ти?', 'Odakle si?', 2081, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('878fa3ed-7e83-5da5-8a92-9e5186b251dc', '070431f4-9139-5438-8acc-63fefe0653f0', 'Marko', 'Dašo, odakle si?', 'Дашо, звідки ти?', 1);
  perform pg_temp.turn('7a1c348d-9bac-591b-9e19-149fc2fe8a02', '070431f4-9139-5438-8acc-63fefe0653f0', 'Daša', 'Iz Ukrajine. Rodom sam iz Odese.', 'З України. Я родом з Одеси.', 2);
  perform pg_temp.turn('146d31f9-823d-5e49-902e-687a3597711a', '070431f4-9139-5438-8acc-63fefe0653f0', 'Marko', 'Odesa je na moru, kao Split!', 'Одеса біля моря, як Спліт!', 3);
  perform pg_temp.turn('64a47b32-059d-5c96-a1aa-8754ad63fbe9', '070431f4-9139-5438-8acc-63fefe0653f0', 'Daša', 'Da! Ali sada živim u Zagrebu.', 'Так! Але зараз я живу в Загребі.', 4);
  perform pg_temp.turn('b42d5068-63c4-5594-bf4e-94affc417b91', '070431f4-9139-5438-8acc-63fefe0653f0', 'Marko', 'Kada si došla u Hrvatsku?', 'Коли ти приїхала до Хорватії?', 5);
  perform pg_temp.turn('981ed60e-eae1-5603-9f92-e0d57eadf637', '070431f4-9139-5438-8acc-63fefe0653f0', 'Daša', 'Prije dvije godine.', 'Два роки тому.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('be5b55b2-e5e8-5b2f-832b-14cde7651924', v_lesson, 'Розмова з сусідом', 'Razgovor sa susjedom', 2082, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('8e8583b9-83f1-542f-a390-5631695f5ee1', 'be5b55b2-e5e8-5b2f-832b-14cde7651924', 'Gospodin Novak', 'Odakle ste, gospođo?', 'Звідки ви, пані?', 1);
  perform pg_temp.turn('a9f3c1fc-477a-5516-a65f-876c08675c67', 'be5b55b2-e5e8-5b2f-832b-14cde7651924', 'Darja', 'Iz Ukrajine. Moj rodni grad je Lviv.', 'З України. Моє рідне місто — Львів.', 2);
  perform pg_temp.turn('c205536f-0bdf-55ee-b023-965f994517dd', 'be5b55b2-e5e8-5b2f-832b-14cde7651924', 'Gospodin Novak', 'Je li Lviv glavni grad Ukrajine?', 'Львів — столиця України?', 3);
  perform pg_temp.turn('e9df12f6-2ce5-5e0e-87c0-8868324b7298', 'be5b55b2-e5e8-5b2f-832b-14cde7651924', 'Darja', 'Nije. Glavni grad je Kijev. Lviv je na zapadu.', 'Ні. Столиця — Київ. Львів — на заході.', 4);
  perform pg_temp.turn('8f3d31db-b158-5005-996f-7e419ac7dc3d', 'be5b55b2-e5e8-5b2f-832b-14cde7651924', 'Gospodin Novak', 'Jeste li se preselili ovamo s obitelji?', 'Ви переїхали сюди з родиною?', 5);
  perform pg_temp.turn('dbd77d02-02f3-5d6b-a8d4-777a481661d8', 'be5b55b2-e5e8-5b2f-832b-14cde7651924', 'Darja', 'Jesam. Ovdje smo pod privremenom zaštitom.', 'Так. Ми тут під тимчасовим захистом.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.2 · урок 10: Мови й національності — перебудова: 21 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'a9944193-2dfb-5944-b94c-41c41fdb7ca1';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Мови й національності» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'd322f236-815f-5156-9c13-71f77763c2d4') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 10: Мови й національності', title_hr = 'Lekcija 10: Jezici i narodnosti',
         objectives = '["Сказати, хто ви за національністю", "Назвати мови, якими говорите, і як добре", "Запитати співрозмовника про мови"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'jezik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'narodnost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'državljanstvo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Ukrajinac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Ukrajinka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Hrvat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Hrvatica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stranac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'strankinja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ukrajinski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hrvatski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'njemački', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poljski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'talijanski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'materinski jezik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na hrvatskom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tečno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'učiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'znati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tečaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'profesorica', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c97f3f8-e2e0-5c9b-b538-6b0fddfd3a4c', 'fill_in_the_blank', 'Ja sam Ukrajinka, a moj muž je ___.', 'Ukrajinac', '["Ukrajinka", "Ukrajinku", "Ukrajinac", "Ukrajinci"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '30006580-0238-5db1-922d-66497cd255c4', 'multiple_choice', 'Що означає «Hrvat»?', 'хорват', '["хорват", "польська (мова); польський", "національність", "українка"]'::jsonb, 'A0', 2, 'PUBLISHED', 'Hrvat', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd5315e35-17a1-5f10-a8e0-e2def8dca50c', 'multiple_choice', 'Що означає «materinski jezik»?', 'рідна мова', '["національність", "рідна мова", "хорватська (мова)", "мова"]'::jsonb, 'A0', 3, 'PUBLISHED', 'materinski jezik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8f1289a1-9d27-559e-aea3-1aa6ed7456e0', 'multiple_choice', 'Що означає «jezik»?', 'мова', '["українська (мова); український", "мова", "знати", "німецька (мова); німецький"]'::jsonb, 'A0', 4, 'PUBLISHED', 'jezik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a81e1774-1981-51b7-8ace-90245a611ec4', 'multiple_choice', 'Як хорватською «українка»?', 'Ukrajinka', '["materinski jezik", "stranac", "Ukrajinka", "ukrajinski"]'::jsonb, 'A0', 5, 'PUBLISHED', 'Ukrajinka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7a6132c8-199c-5b1c-bb16-f46737490cdb', 'multiple_choice', 'Як хорватською «іноземець»?', 'stranac', '["talijanski", "stranac", "materinski jezik", "profesorica"]'::jsonb, 'A0', 6, 'PUBLISHED', 'stranac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '21ca5920-d061-527a-bcca-7ba45ade37c9', 'type_answer', 'Напишіть хорватською: «хорватка»', 'Hrvatica', null, 'A0', 7, 'PUBLISHED', 'Hrvatica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '41014bdb-7925-5994-8a3e-538352131232', 'type_answer', 'Напишіть хорватською: «українська (мова); український»', 'ukrajinski', null, 'A0', 8, 'PUBLISHED', 'ukrajinski', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d09a707-079a-5f55-927f-411d48b92705', 'type_answer', 'Напишіть хорватською: «національність»', 'narodnost', null, 'A0', 9, 'PUBLISHED', 'narodnost', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a5f84268-0083-589d-9603-14e2e806ab55', 'sentence_builder', 'Складіть: «Моя рідна мова — українська.»', 'Moj materinski jezik je ukrajinski.', '["Moj", "ukrajinski.", "jezik", "je", "materinski"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '846cfe53-ecd7-5965-9ea0-f2c5b54efe26', 'sentence_builder', 'Складіть: «Я ще вчу хорватську.»', 'Još učim hrvatski.', '["hrvatski.", "Još", "učim"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2e59ed22-bb35-5661-8baa-750ebe52ba8f', 'listening', 'Прослухайте і складіть фразу', 'Ukrajinski, engleski i malo poljski.', '["Ukrajinski,", "malo", "poljski.", "i", "engleski"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '09427dff-6a77-5e69-87e8-e9e507dea9ce', 'listening', 'Прослухайте і складіть фразу', 'Učimo li samo na hrvatskom?', '["samo", "hrvatskom?", "na", "li", "Učimo"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '47931fe1-4af4-59e2-8cc6-fe61c058ecb8', 'speaking', 'Я українка.', 'Ja sam Ukrajinka.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '426897d7-8571-58e5-86ae-809c49b0c9cd', 'speaking', 'Я трохи розмовляю хорватською.', 'Govorim malo hrvatski.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d322f236-815f-5156-9c13-71f77763c2d4', v_lesson, 'Ти українка?', 'Jesi li Ukrajinka?', 2101, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('cc8c4505-bd29-55c1-aa83-baa05ff1a0bd', 'd322f236-815f-5156-9c13-71f77763c2d4', 'Petra', 'Jesi li ti Ukrajinka?', 'Ти українка?', 1);
  perform pg_temp.turn('f0bf3fb0-f47f-551e-8dc4-3ab132c4372f', 'd322f236-815f-5156-9c13-71f77763c2d4', 'Daša', 'Jesam. A ti si Hrvatica?', 'Так. А ти хорватка?', 2);
  perform pg_temp.turn('cecbe310-bd99-5ae9-97d2-04bcbd67eeb3', 'd322f236-815f-5156-9c13-71f77763c2d4', 'Petra', 'Jesam. Koje jezike govoriš?', 'Так. Якими мовами ти розмовляєш?', 3);
  perform pg_temp.turn('f560de96-6f19-5e22-8de6-616f48927b50', 'd322f236-815f-5156-9c13-71f77763c2d4', 'Daša', 'Ukrajinski, engleski i malo poljski. Hrvatski još učim.', 'Українською, англійською і трохи польською. Хорватську ще вчу.', 4);
  perform pg_temp.turn('943b9cce-de99-56d2-8185-8542b8f5440e', 'd322f236-815f-5156-9c13-71f77763c2d4', 'Petra', 'Ja tečno govorim talijanski. Majka mi je Talijanka.', 'А я вільно говорю італійською. Моя мама — італійка.', 5);
  perform pg_temp.turn('ca1c3dd1-592c-5766-9095-9a2be4fd167c', 'd322f236-815f-5156-9c13-71f77763c2d4', 'Daša', 'Super! Možeš me naučiti talijanski!', 'Супер! Ти можеш навчити мене італійської!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4e0f5ab7-5489-531b-806c-9f998cabb262', v_lesson, 'Курс для іноземців', 'Tečaj za strance', 2102, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('05bd12c7-f2e7-5de5-837e-48c74b9dfcc1', '4e0f5ab7-5489-531b-806c-9f998cabb262', 'Darja', 'Dobar dan! Je li ovo tečaj hrvatskog za strance?', 'Добрий день! Це курс хорватської для іноземців?', 1);
  perform pg_temp.turn('706fe606-1240-5ec2-a900-c4103bd5f91d', '4e0f5ab7-5489-531b-806c-9f998cabb262', 'Profesorica', 'Jest. Kako se zovete i koje ste narodnosti?', 'Так. Як вас звати і якої ви національності?', 2);
  perform pg_temp.turn('ad231ce3-623d-53d8-858c-762aba3a1aa7', '4e0f5ab7-5489-531b-806c-9f998cabb262', 'Darja', 'Darja, Ukrajinka sam. Materinski jezik mi je ukrajinski.', 'Дар’я, я українка. Моя рідна мова — українська.', 3);
  perform pg_temp.turn('b796e121-0952-5e4c-ae47-88c675b1b89c', '4e0f5ab7-5489-531b-806c-9f998cabb262', 'Profesorica', 'Odlično. Ovdje su stranci iz cijelog svijeta.', 'Чудово. Тут іноземці з усього світу.', 4);
  perform pg_temp.turn('6f703d92-d7ef-5621-8e8b-9d70ff9556da', '4e0f5ab7-5489-531b-806c-9f998cabb262', 'Darja', 'Učimo li samo na hrvatskom?', 'Ми вчимося лише хорватською?', 5);
  perform pg_temp.turn('8fb027f7-1f76-5a1a-9e42-f308ffe8c082', '4e0f5ab7-5489-531b-806c-9f998cabb262', 'Profesorica', 'Da, ali polako. Ne brinite!', 'Так, але повільно. Не хвилюйтеся!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.2 · урок 11: Де ви живете? — перебудова: 21 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'adf335ee-0cba-5c9a-b86a-8baac868edbc';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Де ви живете?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '199792cf-60b2-55ef-a47b-982b336e5505') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 11: Де ви живете?', title_hr = 'Lekcija 11: Gdje živite?',
         objectives = '["Назвати свою адресу й поштовий індекс", "Сказати, на якому поверсі ви живете", "Розповісти про свій будинок і район"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'gdje živite', v_pos);
  v_pos := pg_temp.word(v_lesson, 'adresa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ulica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kućni broj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poštanski broj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prizemlje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zgrada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kuća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kvart', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predgrađe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'miran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bučan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ulaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvono', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lift', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poštanski sandučić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stanovati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prebivalište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'boravište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podstanar', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd2a26945-c76e-58c7-93f0-5ca7e735e429', 'fill_in_the_blank', 'Živim ___ trećem katu.', 'na', '["u", "na", "iz", "od"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b05c3610-982a-5bad-9e06-c8a9e315de82', 'multiple_choice', 'Що означає «kvart»?', 'район (міста)', '["галасливий", "район (міста)", "передмістя", "будівля"]'::jsonb, 'A0', 2, 'PUBLISHED', 'kvart', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd2ded3fe-5dc4-5cab-bd84-c4c61ade3eb0', 'multiple_choice', 'Що означає «poštanski broj»?', 'поштовий індекс', '["номер будинку", "дзвінок", "поштовий індекс", "вулиця"]'::jsonb, 'A0', 3, 'PUBLISHED', 'poštanski broj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd7f5c0c-9563-56c3-9198-6b133a57224e', 'multiple_choice', 'Що означає «podstanar»?', 'орендар житла', '["орендар житла", "номер будинку", "галасливий", "місце тимчасового проживання"]'::jsonb, 'A0', 4, 'PUBLISHED', 'podstanar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3e87fe6e-84d5-5eb0-933e-282f455a262f', 'multiple_choice', 'Як хорватською «ліфт»?', 'lift', '["boravište", "lift", "kvart", "miran"]'::jsonb, 'A0', 5, 'PUBLISHED', 'lift', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bdfbc0a4-c1f5-5c03-81ed-5c837fcad36c', 'multiple_choice', 'Як хорватською «будинок; дім»?', 'kuća', '["bučan", "kuća", "prebivalište", "adresa"]'::jsonb, 'A0', 6, 'PUBLISHED', 'kuća', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '14f97c30-3730-5e6e-8989-a5443e44bdd2', 'type_answer', 'Напишіть хорватською: «вулиця»', 'ulica', null, 'A0', 7, 'PUBLISHED', 'ulica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '67c0c6cf-2f3c-58c6-89d0-1ec2180a7147', 'type_answer', 'Напишіть хорватською: «галасливий»', 'bučan', null, 'A0', 8, 'PUBLISHED', 'bučan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f86a60e2-fe84-5530-a205-af6a5ca09b20', 'type_answer', 'Напишіть хорватською: «передмістя»', 'predgrađe', null, 'A0', 9, 'PUBLISHED', 'predgrađe', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5f9ef2b3-8899-5192-81da-7eb4b96a62f4', 'sentence_builder', 'Складіть: «Де ви зараз живете?»', 'Gdje sada živite?', '["živite?", "sada", "Gdje"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '840adf2e-22b4-5c88-9f5b-2b31dd49cf0d', 'sentence_builder', 'Складіть: «Я живу в спокійному районі.»', 'Živim u mirnom kvartu.', '["mirnom", "u", "kvartu.", "Živim"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '34155d32-409d-508b-affc-aa863504925a', 'listening', 'Прослухайте і складіть фразу', 'Na trećem katu, stan broj 8.', '["Na", "8.", "broj", "katu,", "trećem", "stan"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a8c8493-cda7-5eba-aeeb-37807f824960', 'listening', 'Прослухайте і складіть фразу', 'Nema, ali ja stanujem u prizemlju.', '["ja", "stanujem", "Nema,", "ali", "prizemlju.", "u"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c7bd8c2c-92a2-5d67-bff7-e7ba4014193d', 'speaking', 'Я живу на вулиці Іліца.', 'Živim u Ilici.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3513b0ff-d5c2-59b2-8705-9d7b5314ad18', 'speaking', 'Я живу на другому поверсі.', 'Živim na drugom katu.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('199792cf-60b2-55ef-a47b-982b336e5505', v_lesson, 'Яка ваша адреса?', 'Koja je Vaša adresa?', 2111, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('60086782-fb77-5225-9af2-4270dfac7bc5', '199792cf-60b2-55ef-a47b-982b336e5505', 'Gospođa Jurić', 'Gdje živite? Koja je Vaša adresa?', 'Де ви живете? Яка ваша адреса?', 1);
  perform pg_temp.turn('3e8c679b-1f51-5fef-901d-93e0ee70e1f7', '199792cf-60b2-55ef-a47b-982b336e5505', 'Darja', 'Ilica 25, u Zagrebu.', 'Іліца, 25, у Загребі.', 2);
  perform pg_temp.turn('c48eeb9a-399c-5bd3-a179-ab31fb35671f', '199792cf-60b2-55ef-a47b-982b336e5505', 'Gospođa Jurić', 'Na kojem katu?', 'На якому поверсі?', 3);
  perform pg_temp.turn('28a8f546-1592-51d3-84f7-5627c1c129e4', '199792cf-60b2-55ef-a47b-982b336e5505', 'Darja', 'Na trećem katu, stan broj 8.', 'На третьому поверсі, квартира номер 8.', 4);
  perform pg_temp.turn('2e0d473e-53d4-5e77-b7ee-6321991987a3', '199792cf-60b2-55ef-a47b-982b336e5505', 'Gospođa Jurić', 'A poštanski broj?', 'А поштовий індекс?', 5);
  perform pg_temp.turn('5f72c5da-f18c-5ea0-b9ed-e59fc9301233', '199792cf-60b2-55ef-a47b-982b336e5505', 'Darja', 'Deset tisuća.', 'Десять тисяч (10 000).', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7be3e56a-f064-5ef4-aa30-27bc437b71ea', v_lesson, 'Новий район', 'Novi kvart', 2112, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('ab290958-beb8-5979-a563-b24e36e26c46', '7be3e56a-f064-5ef4-aa30-27bc437b71ea', 'Marko', 'Dašo, kako ti je novi kvart?', 'Дашо, як тобі новий район?', 1);
  perform pg_temp.turn('6e8499e2-764b-522f-9431-6ca7099f7ce5', '7be3e56a-f064-5ef4-aa30-27bc437b71ea', 'Daša', 'Miran je. Živim u predgrađu, u maloj zgradi.', 'Спокійний. Я живу в передмісті, у невеликому будинку.', 2);
  perform pg_temp.turn('6cfb4a54-db0a-5ddb-a030-fd8bbdefa938', '7be3e56a-f064-5ef4-aa30-27bc437b71ea', 'Marko', 'Ima li zgrada lift?', 'У будинку є ліфт?', 3);
  perform pg_temp.turn('51968035-6c9e-5091-95c0-8ec6ceb112d7', '7be3e56a-f064-5ef4-aa30-27bc437b71ea', 'Daša', 'Nema, ali ja stanujem u prizemlju.', 'Немає, але я живу на першому поверсі.', 4);
  perform pg_temp.turn('206093a0-b7b4-5b59-96c5-36093c2e1a33', '7be3e56a-f064-5ef4-aa30-27bc437b71ea', 'Marko', 'Super. Ja živim u centru i tamo je jako bučno.', 'Чудово. А я живу в центрі, і там дуже галасливо.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.2 · урок 12: Ким ви працюєте? — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Ким ви працюєте?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'c72be6e0-216d-5d3f-8188-6b5f7202ae62') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 12: Ким ви працюєте?', title_hr = 'Lekcija 12: Čime se bavite?',
         objectives = '["Назвати свою професію", "Запитати, ким працює співрозмовник", "Сказати, що ви шукаєте роботу"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'čime se bavite', v_pos);
  v_pos := pg_temp.word(v_lesson, 'raditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zanimanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iskustvo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'programer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'profesor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'medicinska sestra', v_pos);
  v_pos := pg_temp.word(v_lesson, 'konobar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'konobarica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kuhar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vozač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prodavač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prodavačica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čistačica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'inženjer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'frizer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tvrtka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ured', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nezaposlen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'umirovljenik', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '620ea6ee-9805-5b97-a978-5011947f3128', 'fill_in_the_blank', 'Radim ___ konobarica.', 'kao', '["kao", "kako", "koji", "kad"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '350dfaba-7aa9-59f4-b691-95ff8cb474f3', 'multiple_choice', 'Що означає «iskustvo»?', 'досвід', '["продавець", "безробітний", "досвід", "інженер"]'::jsonb, 'A0', 2, 'PUBLISHED', 'iskustvo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aae3e503-f726-539a-9be1-c4ee73c99b35', 'multiple_choice', 'Що означає «vozač»?', 'водій', '["перукар", "водій", "безробітний", "офіс / кабінет"]'::jsonb, 'A0', 3, 'PUBLISHED', 'vozač', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5dcde1ee-b73d-5bd9-8e51-706f7bb63200', 'multiple_choice', 'Що означає «medicinska sestra»?', 'медична сестра', '["професія / заняття", "безробітний", "досвід", "медична сестра"]'::jsonb, 'A0', 4, 'PUBLISHED', 'medicinska sestra', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '16138d9f-ba6c-512a-ab17-ad17d107e12c', 'multiple_choice', 'Як хорватською «офіс / кабінет»?', 'ured', '["ured", "kuhar", "frizer", "programer"]'::jsonb, 'A0', 5, 'PUBLISHED', 'ured', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4ae861f3-9ee0-5bb8-a57e-9ed756f2bc85', 'multiple_choice', 'Як хорватською «безробітний»?', 'nezaposlen', '["čime se bavite", "inženjer", "nezaposlen", "posao"]'::jsonb, 'A0', 6, 'PUBLISHED', 'nezaposlen', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ddcdcdce-f950-57fc-bb44-87c7250688d8', 'type_answer', 'Напишіть хорватською: «працювати, робити»', 'raditi', null, 'A0', 7, 'PUBLISHED', 'raditi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a1eee5a-5dea-5f7a-bc43-83f03fd51079', 'type_answer', 'Напишіть хорватською: «інженер»', 'inženjer', null, 'A0', 8, 'PUBLISHED', 'inženjer', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fb1d2cac-4d96-5766-96ad-60730084e5dd', 'type_answer', 'Напишіть хорватською: «продавчиня»', 'prodavačica', null, 'A0', 9, 'PUBLISHED', 'prodavačica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '47c48452-c69e-51c7-97fa-0497b38df050', 'sentence_builder', 'Складіть: «Чим ви займаєтеся?»', 'Čime se bavite?', '["se", "Čime", "bavite?"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '61803a0e-4463-5220-a83e-a0df8679ba8d', 'sentence_builder', 'Складіть: «Мій чоловік — водій.»', 'Moj muž je vozač.', '["Moj", "vozač.", "je", "muž"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2cd90e74-9b75-5942-be84-e691cab5a05b', 'listening', 'Прослухайте і складіть фразу', 'Sada radim kao konobarica u kafiću.', '["konobarica", "radim", "u", "kafiću.", "kao", "Sada"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8978c014-c832-5bb3-9f8a-7a73b7de67c9', 'listening', 'Прослухайте і складіть фразу', 'Da, tražim posao.', '["Da,", "posao.", "tražim"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae8f5e16-a4f2-514d-9824-d2a7a9f5041f', 'speaking', 'Я програміст.', 'Ja sam programer.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9f83711a-7052-5a2b-8096-1fda1c530420', 'speaking', 'Я працюю в офісі.', 'Radim u uredu.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c72be6e0-216d-5d3f-8188-6b5f7202ae62', v_lesson, 'Чим ви займаєтеся?', 'Čime se bavite?', 2121, 'A0', 'work', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('781a24f0-e06d-5624-8685-83ec2e9d4da8', 'c72be6e0-216d-5d3f-8188-6b5f7202ae62', 'Gospođa Horvat', 'Čime se bavite?', 'Чим ви займаєтеся?', 1);
  perform pg_temp.turn('3b95fe88-6a64-5236-9b97-fb66c69bc6aa', 'c72be6e0-216d-5d3f-8188-6b5f7202ae62', 'Darja', 'U Ukrajini sam bila inženjerka.', 'В Україні я була інженеркою.', 2);
  perform pg_temp.turn('3fcf80da-96f7-51bc-8a98-26cf5c8558c2', 'c72be6e0-216d-5d3f-8188-6b5f7202ae62', 'Gospođa Horvat', 'A sada?', 'А зараз?', 3);
  perform pg_temp.turn('b5be6bf9-c8b0-5112-943d-1480ef7d5f53', 'c72be6e0-216d-5d3f-8188-6b5f7202ae62', 'Darja', 'Sada radim kao konobarica u kafiću.', 'Зараз працюю офіціанткою в кав’ярні.', 4);
  perform pg_temp.turn('c3d9fe47-4fec-52db-8a7a-7c42ae9b25fb', 'c72be6e0-216d-5d3f-8188-6b5f7202ae62', 'Gospođa Horvat', 'Moj sin je kuhar. Možda trebaju ljude u njegovom restoranu.', 'Мій син — кухар. Можливо, у його ресторані потрібні люди.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7af159fb-d27f-5597-91a2-0ccf3c84702e', v_lesson, 'Співбесіда', 'Razgovor za posao', 2122, 'A0', 'work', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('dc768077-88c4-569b-bcb0-e9a93a544aed', '7af159fb-d27f-5597-91a2-0ccf3c84702e', 'Gospodin Kovačević', 'Dobar dan. Imate li iskustva kao prodavačica?', 'Добрий день. У вас є досвід роботи продавчинею?', 1);
  perform pg_temp.turn('8971ac44-3d66-5df1-82a9-a66634f98648', '7af159fb-d27f-5597-91a2-0ccf3c84702e', 'Daša', 'Imam. Dvije godine sam radila u trgovini u Kijevu.', 'Так. Два роки я працювала в магазині в Києві.', 2);
  perform pg_temp.turn('a3e429e5-0ce9-54b6-b59d-9409d395936c', '7af159fb-d27f-5597-91a2-0ccf3c84702e', 'Gospodin Kovačević', 'Dobro. Sada ste nezaposleni?', 'Добре. Зараз ви не працюєте?', 3);
  perform pg_temp.turn('3b3a7eae-af70-5fb0-bd39-7278b09866b7', '7af159fb-d27f-5597-91a2-0ccf3c84702e', 'Daša', 'Da, tražim posao.', 'Так, шукаю роботу.', 4);
  perform pg_temp.turn('434621d5-0bf4-5e66-8f16-d2fd1b98fadb', '7af159fb-d27f-5597-91a2-0ccf3c84702e', 'Gospodin Kovačević', 'Naša tvrtka traži prodavačicu. Možete li početi u ponedjeljak?', 'Наша фірма шукає продавчиню. Можете почати в понеділок?', 5);
  perform pg_temp.turn('86e8a470-61c7-5654-9a2d-956d0d62c3b4', '7af159fb-d27f-5597-91a2-0ccf3c84702e', 'Daša', 'Mogu, naravno!', 'Можу, звісно!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- 3. Новий порядок уроків у модулі A0.2: наявні уроки тимчасово переносяться на місця 100+
--    (unique (unit_id, order_index)), щоб звільнити місця для нових; у кроці 5 — на остаточні місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 2 and u.order_index = 1;
  update public.lessons l set order_index = t.o + 100
    from (values
    ('2b6ed342-cc80-5bd9-baf0-b66109624d62'::uuid, 1),
    ('04167753-db83-5163-a91c-9f71dac18ab5'::uuid, 4),
    ('a9944193-2dfb-5944-b94c-41c41fdb7ca1'::uuid, 6),
    ('adf335ee-0cba-5c9a-b86a-8baac868edbc'::uuid, 7),
    ('2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'::uuid, 8)
    ) as t(id, o)
   where l.id = t.id and l.unit_id = v_unit and l.order_index <> t.o and l.order_index < 100;
end $$;

-- 4. Нові тематичні уроки модуля A0.2
-- A0.2 · урок 6: Я, ти, він: особові займенники — новий урок: 22 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '8abb83d8-ec02-5921-ac9b-814489816fcd';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A0.2: місце 2 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Особові займенники та дієслово BITI' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Особові займенники та дієслово BITI»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 6: Я, ти, він: особові займенники', 'Lekcija 6: Ja, ti, on: osobne zamjenice', '["Казати «я», «ти», «він», «вона», «ми», «ви», «вони»", "Пояснити, хто є хто: «Він мій сусід», «Ми колеги»", "Вживати форми «biti»: sam, si, je, smo, ste, su"]'::jsonb, 15, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'ja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'on', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ona', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ono', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'one', v_pos);
  v_pos := pg_temp.word(v_lesson, 'biti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čovjek', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljudi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'muškarac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'djevojka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mladić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'susjed', v_pos);
  v_pos := pg_temp.word(v_lesson, 'susjeda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolega', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolegica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zajedno', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '858a1f1d-8ad7-57fa-ad34-c2c02e64aeb7', 'fill_in_the_blank', 'Mi ___ kolege.', 'smo', '["ste", "su", "smo", "sam"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f7b1913-4fc7-52ec-a8a8-aa52aaf4dd61', 'multiple_choice', 'Що означає «ono»?', 'воно', '["бути", "воно", "ми", "колега (чоловік)"]'::jsonb, 'A0', 2, 'PUBLISHED', 'ono', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '304d2f1b-e7bd-566e-86c9-a6411c50a955', 'multiple_choice', 'Що означає «mladić»?', 'юнак', '["разом", "вона", "юнак", "вони"]'::jsonb, 'A0', 3, 'PUBLISHED', 'mladić', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ec383216-8634-5d1e-a520-1be8351e4016', 'multiple_choice', 'Що означає «ljudi»?', 'люди', '["люди", "жінка, дружина", "бути", "юнак"]'::jsonb, 'A0', 4, 'PUBLISHED', 'ljudi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '19fa299d-4085-5a5e-94fb-606045c73a9a', 'multiple_choice', 'Як хорватською «ми»?', 'mi', '["ti", "biti", "djevojka", "mi"]'::jsonb, 'A0', 5, 'PUBLISHED', 'mi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f8602c8-3e2a-5991-bc55-8e8da447603f', 'multiple_choice', 'Як хорватською «сусідка»?', 'susjeda', '["mi", "susjeda", "ljudi", "susjed"]'::jsonb, 'A0', 6, 'PUBLISHED', 'susjeda', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '78f1e6fd-239d-5e4b-b796-305d904d9312', 'type_answer', 'Напишіть хорватською: «ви»', 'vi', null, 'A0', 7, 'PUBLISHED', 'vi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd02aa021-18c6-52c8-a1e1-918468ce9b7c', 'type_answer', 'Напишіть хорватською: «сусід»', 'susjed', null, 'A0', 8, 'PUBLISHED', 'susjed', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cb57e419-19d5-54bc-9e4d-897535f7bd15', 'type_answer', 'Напишіть хорватською: «вона»', 'ona', null, 'A0', 9, 'PUBLISHED', 'ona', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '47f0b0a6-d353-52ca-9c87-06c8b901b237', 'sentence_builder', 'Складіть: «Він мій сусід.»', 'On je moj susjed.', '["je", "moj", "On", "susjed."]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '840184ed-2acb-5130-978b-3df99975dfcf', 'sentence_builder', 'Складіть: «Ми всі тут разом.»', 'Mi smo svi ovdje zajedno.', '["ovdje", "svi", "smo", "Mi", "zajedno."]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d1f4ec3-0b88-503d-a1f9-cf4e9dfa80ec', 'listening', 'Прослухайте і складіть фразу', 'Tko je onaj mladić?', '["mladić?", "Tko", "je", "onaj"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0bc1c685-bedc-5583-b41c-858082e847b4', 'listening', 'Прослухайте і складіть фразу', 'Da, mi smo oboje iz Ukrajine.', '["iz", "Da,", "oboje", "Ukrajine.", "smo", "mi"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '61940487-7927-5892-9f7c-edef6f65229a', 'speaking', 'Вона моя колега.', 'Ona je moja kolegica.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eb241403-1ac9-5d24-9aac-edd718968d28', 'speaking', 'Ми колеги.', 'Mi smo kolege.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('105d5432-6d4d-5952-b0e8-c0874f6e73a3', v_lesson, 'Хто це?', 'Tko je to?', 2061, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('d30e1203-6603-5d68-ae60-9a5fa9ee2037', '105d5432-6d4d-5952-b0e8-c0874f6e73a3', 'Daša', 'Tko je onaj mladić?', 'Хто той хлопець?', 1);
  perform pg_temp.turn('64a8491b-09bd-5dd5-bb59-d5d97cffb6c0', '105d5432-6d4d-5952-b0e8-c0874f6e73a3', 'Ana', 'On je moj susjed Marko. A ona je njegova žena.', 'Він мій сусід Марко. А вона — його дружина.', 2);
  perform pg_temp.turn('611b179c-2f99-5cc8-bc52-a444a0e0822d', '105d5432-6d4d-5952-b0e8-c0874f6e73a3', 'Daša', 'Jesu li oni Hrvati?', 'Вони хорвати?', 3);
  perform pg_temp.turn('c6c4b7a0-6273-52ca-92f4-e7fa3f9f730d', '105d5432-6d4d-5952-b0e8-c0874f6e73a3', 'Ana', 'On je Hrvat, a ona je Slovenka.', 'Він хорват, а вона словенка.', 4);
  perform pg_temp.turn('9bef6db9-0ae9-5722-b194-5ae8d768336b', '105d5432-6d4d-5952-b0e8-c0874f6e73a3', 'Daša', 'A ti i ja smo susjede!', 'А ми з тобою — сусідки!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7aa8fb5a-7905-5514-ab25-b8be49bfc851', v_lesson, 'На роботі', 'Na poslu', 2062, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('738a1f18-98d9-5fd5-a6b6-c3dc803d456c', '7aa8fb5a-7905-5514-ab25-b8be49bfc851', 'Gospođa Perić', 'Dobro jutro! Jeste li Vi nova kolegica?', 'Доброго ранку! Ви нова колега?', 1);
  perform pg_temp.turn('9c6c700b-9c47-5dc0-9c29-1e64db5b7c45', '7aa8fb5a-7905-5514-ab25-b8be49bfc851', 'Darja', 'Jesam. Ja sam Darja, a ovo je Oleh.', 'Так. Я Дар’я, а це Олег.', 2);
  perform pg_temp.turn('89933e95-b51c-5945-acca-75db94bf69fe', '7aa8fb5a-7905-5514-ab25-b8be49bfc851', 'Gospođa Perić', 'Drago mi je. Vi ste iz Ukrajine?', 'Дуже приємно. Ви з України?', 3);
  perform pg_temp.turn('6bd5c4d4-14c9-5687-bdf5-e6c3cbf39801', '7aa8fb5a-7905-5514-ab25-b8be49bfc851', 'Oleh', 'Da, mi smo oboje iz Ukrajine.', 'Так, ми обоє з України.', 4);
  perform pg_temp.turn('cff2333a-c372-5141-9b7b-b67914465ac3', '7aa8fb5a-7905-5514-ab25-b8be49bfc851', 'Gospođa Perić', 'Odlično. Ovdje su svi jako ljubazni.', 'Чудово. Тут усі дуже привітні.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.2 · урок 7: Питальні слова — новий урок: 21 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '8f6439a9-c6ac-5271-99c8-1f0adc5d7599';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A0.2: місце 3 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Питальні слова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Питальні слова»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 7: Питальні слова', 'Lekcija 7: Upitne riječi', '["Ставити прості питання: хто? що? де? коли? як?", "Розрізняти «де?», «куди?» і «звідки?»", "Питати «чому?» і відповідати «тому що…»"]'::jsonb, 15, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'tko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'što', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gdje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kamo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odakle', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kako', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zašto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čiji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kakav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'je li', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zato što', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zato', v_pos);
  v_pos := pg_temp.word(v_lesson, 'od kada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'do kada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koliko dugo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'što je to', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pitati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odgovoriti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odgovor', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ff5193ce-a45c-5480-a64b-81b4b1eba8b7', 'fill_in_the_blank', '___ si? — Iz Ukrajine.', 'Odakle', '["Gdje", "Kamo", "Odakle", "Kada"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd53caf9-ceca-5d74-9fba-f50fc7a562d8', 'multiple_choice', 'Що означає «koliko dugo»?', 'як довго', '["який? (якої якості)", "що", "як довго", "доки; до якого часу"]'::jsonb, 'A0', 2, 'PUBLISHED', 'koliko dugo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9195ddc8-987d-5d7c-b902-7df47260697f', 'multiple_choice', 'Що означає «što»?', 'що', '["тому / через це", "що", "чому", "відповідь"]'::jsonb, 'A0', 3, 'PUBLISHED', 'što', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1228b2c5-291d-5d7d-a1ca-308116da7981', 'multiple_choice', 'Що означає «odgovor»?', 'відповідь', '["відповідь", "хто", "де", "тому що"]'::jsonb, 'A0', 4, 'PUBLISHED', 'odgovor', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0e2ab696-56db-5214-bc48-a92a6965183c', 'multiple_choice', 'Як хорватською «як»?', 'kako', '["kako", "koji", "kamo", "od kada"]'::jsonb, 'A0', 5, 'PUBLISHED', 'kako', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '10221bb3-5963-52a3-a488-e2ffcdc521a9', 'multiple_choice', 'Як хорватською «відповісти»?', 'odgovoriti', '["odgovor", "pitati", "je li", "odgovoriti"]'::jsonb, 'A0', 6, 'PUBLISHED', 'odgovoriti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cd716c4f-4d45-582a-990e-4fc82a2c3833', 'type_answer', 'Напишіть хорватською: «куди»', 'kamo', null, 'A0', 7, 'PUBLISHED', 'kamo', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2bc7876d-6461-59ac-8d68-ea745b4ae25d', 'type_answer', 'Напишіть хорватською: «чому»', 'zašto', null, 'A0', 8, 'PUBLISHED', 'zašto', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fb20e8f8-f150-52f7-b14a-53cc4ac85db6', 'type_answer', 'Напишіть хорватською: «чий»', 'čiji', null, 'A0', 9, 'PUBLISHED', 'čiji', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '573f9ae6-8bf5-540b-a8f4-6b643a68f7e6', 'sentence_builder', 'Складіть: «Чому ти мене питаєш?»', 'Zašto me pitaš?', '["me", "Zašto", "pitaš?"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf9f5cc3-5328-5517-a980-7195dce1ceda', 'sentence_builder', 'Складіть: «Де ти зараз живеш?»', 'Gdje sada živiš?', '["živiš?", "sada", "Gdje"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '69fe880b-23c3-5a0e-b82e-ebfcfaea6b63', 'listening', 'Прослухайте і складіть фразу', 'Od kada živiš u Zagrebu?', '["Od", "Zagrebu?", "živiš", "u", "kada"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3013b1a3-9b75-5bbf-972b-96aaae398422', 'listening', 'Прослухайте і складіть фразу', 'Koliko dugo traje vožnja?', '["traje", "dugo", "vožnja?", "Koliko"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '831c11c5-2f37-5f8d-a003-c060d0182ea7', 'speaking', 'Що це?', 'Što je to?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a14fe44-594e-595c-8ad4-c04bac2ba075', 'speaking', 'Куди ви йдете?', 'Kamo idete?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b861ebfc-0e52-50a9-b78e-bfea38b3f16f', v_lesson, 'Багато питань', 'Puno pitanja', 2071, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('d66c9511-6dd5-5cd0-9a9c-38a4c49d3da9', 'b861ebfc-0e52-50a9-b78e-bfea38b3f16f', 'Ivana', 'Odakle si, Dašo?', 'Звідки ти, Дашо?', 1);
  perform pg_temp.turn('20336ef6-5b4e-5e2b-ba66-5ac1477f4090', 'b861ebfc-0e52-50a9-b78e-bfea38b3f16f', 'Daša', 'Iz Ukrajine, iz Harkiva.', 'З України, з Харкова.', 2);
  perform pg_temp.turn('4e43dbcd-4880-58f2-85ed-15b20f913c9a', 'b861ebfc-0e52-50a9-b78e-bfea38b3f16f', 'Ivana', 'Od kada živiš u Zagrebu?', 'Відколи ти живеш у Загребі?', 3);
  perform pg_temp.turn('66fc5149-983c-5749-a4db-a6168cbb5d21', 'b861ebfc-0e52-50a9-b78e-bfea38b3f16f', 'Daša', 'Od ožujka. A zašto pitaš?', 'З березня. А чому ти питаєш?', 4);
  perform pg_temp.turn('8b15d4fe-1592-58c2-8b4e-25611cf8c281', 'b861ebfc-0e52-50a9-b78e-bfea38b3f16f', 'Ivana', 'Zato što je tvoj hrvatski jako dobar!', 'Тому що твоя хорватська дуже добра!', 5);
  perform pg_temp.turn('88bb949d-8d83-57ed-8133-55b33dc23978', 'b861ebfc-0e52-50a9-b78e-bfea38b3f16f', 'Daša', 'Hvala! Učim ga svaki dan.', 'Дякую! Я вчу її щодня.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3aae41c6-a0de-5c2d-b4d1-94419c0273a1', v_lesson, 'На вокзалі', 'Na kolodvoru', 2072, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('fd3e9146-e46d-57ba-bc16-aabf17874bd5', '3aae41c6-a0de-5c2d-b4d1-94419c0273a1', 'Daša', 'Oprostite, kada ide vlak za Split?', 'Вибачте, коли їде потяг до Спліта?', 1);
  perform pg_temp.turn('2dcf250d-ba77-5e6d-84af-40f3c96a0b47', '3aae41c6-a0de-5c2d-b4d1-94419c0273a1', 'Blagajnica', 'U devet sati.', 'О дев’ятій.', 2);
  perform pg_temp.turn('c0427dda-c587-5922-bed2-1ad0ee45e4ec', '3aae41c6-a0de-5c2d-b4d1-94419c0273a1', 'Daša', 'A s kojeg perona?', 'А з якої платформи?', 3);
  perform pg_temp.turn('1f8acccf-229f-53b6-90f9-baabeb330006', '3aae41c6-a0de-5c2d-b4d1-94419c0273a1', 'Blagajnica', 'S drugog perona.', 'З другої платформи.', 4);
  perform pg_temp.turn('0aa2ccf4-42aa-5841-8a59-9c1e7a933174', '3aae41c6-a0de-5c2d-b4d1-94419c0273a1', 'Daša', 'Koliko dugo traje vožnja?', 'Скільки триває поїздка?', 5);
  perform pg_temp.turn('b9beb392-c07f-5a9b-9461-0d66f49a6ef6', '3aae41c6-a0de-5c2d-b4d1-94419c0273a1', 'Blagajnica', 'Otprilike šest sati.', 'Приблизно шість годин.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.2 · урок 9: Країни й континенти — новий урок: 24 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '479784bc-54ab-522d-9c77-55887ae68e33';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A0.2: місце 5 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Де? Прийменники місця' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Де? Прийменники місця»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 9: Країни й континенти', 'Lekcija 9: Zemlje i kontinenti', '["Назвати континенти й сусідні з Хорватією країни", "Сказати, де країна: на півночі, на півдні, у Європі", "Розповісти, у яких країнах живуть ваші рідні"]'::jsonb, 15, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kontinent', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svijet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zemlja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'država', v_pos);
  v_pos := pg_temp.word(v_lesson, 'granica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Europa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Azija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Afrika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Amerika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Australija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Njemačka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Poljska', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Italija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Austrija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Slovenija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Mađarska', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Srbija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Bosna i Hercegovina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Francuska', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Španjolska', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sjever', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jug', v_pos);
  v_pos := pg_temp.word(v_lesson, 'istok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zapad', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bdc34aee-83ac-5cd8-80ba-50a67d553429', 'fill_in_the_blank', 'Moj brat živi u ___.', 'Njemačkoj', '["Njemačkoj", "Njemačku", "Njemačka", "Njemačke"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '23b29302-0387-5349-b777-de6336fec55d', 'multiple_choice', 'Що означає «svijet»?', 'світ', '["Італія", "світ", "Америка", "Словенія"]'::jsonb, 'A0', 2, 'PUBLISHED', 'svijet', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '04704b5e-7211-545d-9d50-5a4170778f03', 'multiple_choice', 'Що означає «Italija»?', 'Італія', '["Словенія", "Італія", "континент", "Африка"]'::jsonb, 'A0', 3, 'PUBLISHED', 'Italija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c50c229a-5b0c-57f5-8535-84c26fed0818', 'multiple_choice', 'Що означає «Španjolska»?', 'Іспанія', '["Іспанія", "північ", "світ", "південь"]'::jsonb, 'A0', 4, 'PUBLISHED', 'Španjolska', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '90d53a0c-d009-5d77-b6b4-483ae3b06259', 'multiple_choice', 'Як хорватською «Словенія»?', 'Slovenija', '["sjever", "Bosna i Hercegovina", "Njemačka", "Slovenija"]'::jsonb, 'A0', 5, 'PUBLISHED', 'Slovenija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9007a16e-dd58-5ffa-ad86-4e74f43128c1', 'multiple_choice', 'Як хорватською «південь»?', 'jug', '["Španjolska", "jug", "zemlja", "Srbija"]'::jsonb, 'A0', 6, 'PUBLISHED', 'jug', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6232b1fb-4224-5705-848c-fb7145623af5', 'type_answer', 'Напишіть хорватською: «Сербія»', 'Srbija', null, 'A0', 7, 'PUBLISHED', 'Srbija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5309783a-0182-56d9-bc8b-9b199cf1793b', 'type_answer', 'Напишіть хорватською: «кордон, межа»', 'granica', null, 'A0', 8, 'PUBLISHED', 'granica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '29ce6baa-5a38-5d0d-acef-ff3355273a60', 'type_answer', 'Напишіть хорватською: «Німеччина»', 'Njemačka', null, 'A0', 9, 'PUBLISHED', 'Njemačka', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9433c39b-d885-5824-a63a-f64abc1dadc6', 'sentence_builder', 'Складіть: «Хорватія — у Європі.»', 'Hrvatska je u Europi.', '["Hrvatska", "Europi.", "u", "je"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3b4ef696-c4f0-5f4f-820e-1ee79b238600', 'sentence_builder', 'Складіть: «Львів — на заході України.»', 'Lviv je na zapadu Ukrajine.', '["je", "Lviv", "Ukrajine.", "zapadu", "na"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '391143c7-c31c-524f-8809-a9d25cf2dfe9', 'listening', 'Прослухайте і складіть фразу', 'Evo, ovdje. Na istoku Europe.', '["ovdje.", "Europe.", "Evo,", "Na", "istoku"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3f7408a5-ca72-534c-9463-1a919b449e4a', 'listening', 'Прослухайте і складіть фразу', 'Nisam, ali ljeti idem u Španjolsku.', '["ali", "ljeti", "u", "Španjolsku.", "Nisam,", "idem"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6140b5ff-3976-54f0-a1ff-851bffb6dbac', 'speaking', 'Я з Європи.', 'Ja sam iz Europe.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5c92a151-ae0a-5377-8c86-21737f4dda6a', 'speaking', 'Італія — на півдні.', 'Italija je na jugu.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1cd439ca-8d92-5d73-b49a-f72bb6898971', v_lesson, 'Карта світу', 'Karta svijeta', 2091, 'A0', 'travel', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('8cefeda5-cf07-5ce2-8dd4-df2abd13fa74', '1cd439ca-8d92-5d73-b49a-f72bb6898971', 'Luka', 'Gdje je Ukrajina na karti?', 'Де Україна на карті?', 1);
  perform pg_temp.turn('109571e7-94cd-53ca-adac-c17de59d9574', '1cd439ca-8d92-5d73-b49a-f72bb6898971', 'Daša', 'Evo, ovdje. Na istoku Europe.', 'Ось тут. На сході Європи.', 2);
  perform pg_temp.turn('3c1e5ff6-cc71-57b4-9029-8e0b24f60ce4', '1cd439ca-8d92-5d73-b49a-f72bb6898971', 'Luka', 'Velika je! S kojim zemljama graniči?', 'Велика! З якими країнами межує?', 3);
  perform pg_temp.turn('1635b9a8-ad08-5112-be48-3abb38904ac8', '1cd439ca-8d92-5d73-b49a-f72bb6898971', 'Daša', 'Na zapadu s Poljskom, Slovačkom i Mađarskom.', 'На заході — з Польщею, Словаччиною та Угорщиною.', 4);
  perform pg_temp.turn('74dd1f48-ff70-5323-9bf4-935c526f0a65', '1cd439ca-8d92-5d73-b49a-f72bb6898971', 'Luka', 'A Hrvatska?', 'А Хорватія?', 5);
  perform pg_temp.turn('f456489f-2d99-553d-b678-21416e702431', '1cd439ca-8d92-5d73-b49a-f72bb6898971', 'Daša', 'Hrvatska je u Europi, na Jadranskom moru.', 'Хорватія — у Європі, на Адріатичному морі.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('aac495a0-b03e-53ab-8761-1edb6d8d1e4e', v_lesson, 'Де живе твоя родина?', 'Gdje živi tvoja obitelj?', 2092, 'A0', 'travel', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('81251103-a5bb-5e4b-bb32-f0557436e049', 'aac495a0-b03e-53ab-8761-1edb6d8d1e4e', 'Ana', 'Dašo, gdje živi tvoja obitelj?', 'Дашо, де живе твоя родина?', 1);
  perform pg_temp.turn('c259bf2e-0f21-5a0c-94f7-17772fc0cd7e', 'aac495a0-b03e-53ab-8761-1edb6d8d1e4e', 'Daša', 'Mama je u Ukrajini, a brat u Njemačkoj.', 'Мама — в Україні, а брат — у Німеччині.', 2);
  perform pg_temp.turn('66e03fe3-89d5-5996-aba3-5e3e66636285', 'aac495a0-b03e-53ab-8761-1edb6d8d1e4e', 'Ana', 'Moja sestra radi u Austriji, u Beču.', 'Моя сестра працює в Австрії, у Відні.', 3);
  perform pg_temp.turn('0f7df3b6-f2b6-55e0-b532-ca237562cd9b', 'aac495a0-b03e-53ab-8761-1edb6d8d1e4e', 'Daša', 'Beč je blizu! A jesi li bila u Americi?', 'Відень близько! А ти була в Америці?', 4);
  perform pg_temp.turn('01cdcbba-bbe0-5c14-bcc7-a94401b6ea84', 'aac495a0-b03e-53ab-8761-1edb6d8d1e4e', 'Ana', 'Nisam, ali ljeti idem u Španjolsku.', 'Ні, але влітку я їду до Іспанії.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.2 · урок 13: Як ви почуваєтеся? — новий урок: 22 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '3b51b1bf-47f4-5709-96d9-c518d36440e6';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 9) then
    raise exception 'A0.2: місце 9 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Прикметники: узгодження з іменником' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Прикметники: узгодження з іменником»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 13: Як ви почуваєтеся?', 'Lekcija 13: Kako se osjećate?', '["Сказати, як ви почуваєтеся: щаслива, сумний, хвора", "Запитати друга про настрій і підтримати його", "Узгоджувати прикметник: sretan — sretna"]'::jsonb, 15, 'PUBLISHED', 9);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kako se osjećaš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osjećati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'raspoloženje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sretan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tužan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'veseo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljut', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nervozan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zabrinut', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iznenađen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponosan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'usamljen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bolestan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zdrav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pospan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dosadno mi je', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hladno mi je', v_pos);
  v_pos := pg_temp.word(v_lesson, 'loše mi je', v_pos);
  v_pos := pg_temp.word(v_lesson, 'strah me je', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nedostaje mi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bolje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'boli me glava', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f5efc2d-a1bf-547f-96bc-e92d06e4e31f', 'fill_in_the_blank', 'Daša je danas jako ___.', 'sretna', '["sretno", "sretan", "sretni", "sretna"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '796afc55-1f32-574a-ad20-80cb889629e2', 'multiple_choice', 'Що означає «ljut»?', 'злий / сердитий', '["я сумую за…; мені бракує", "самотній", "злий / сердитий", "настрій"]'::jsonb, 'A0', 2, 'PUBLISHED', 'ljut', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '06a2a6aa-d949-52ad-a2c6-21cb757bdc34', 'multiple_choice', 'Що означає «dosadno mi je»?', 'мені нудно', '["здоровий", "мені нудно", "у мене болить голова", "мені холодно"]'::jsonb, 'A0', 3, 'PUBLISHED', 'dosadno mi je', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '569a3adc-821e-537f-9b97-7d2cc829baea', 'multiple_choice', 'Що означає «tužan»?', 'сумний', '["сумний", "щасливий", "сонний", "веселий"]'::jsonb, 'A0', 4, 'PUBLISHED', 'tužan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4c47052a-0c04-58f4-93a2-0c79d20d25a9', 'multiple_choice', 'Як хорватською «здивований»?', 'iznenađen', '["strah me je", "usamljen", "dosadno mi je", "iznenađen"]'::jsonb, 'A0', 5, 'PUBLISHED', 'iznenađen', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1e48f2cb-85c1-5b1f-88da-3a8c048fb01d', 'multiple_choice', 'Як хорватською «здоровий»?', 'zdrav', '["zdrav", "boli me glava", "ponosan", "zabrinut"]'::jsonb, 'A0', 6, 'PUBLISHED', 'zdrav', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3d79caac-4323-5bb6-9a7f-3cf5f2e94505', 'type_answer', 'Напишіть хорватською: «настрій»', 'raspoloženje', null, 'A0', 7, 'PUBLISHED', 'raspoloženje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6e37f906-3c01-5b93-bc41-ae05655ee29c', 'type_answer', 'Напишіть хорватською: «самотній»', 'usamljen', null, 'A0', 8, 'PUBLISHED', 'usamljen', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4cf365ce-5fe8-504a-a2c3-980708e93b29', 'type_answer', 'Напишіть хорватською: «хворий»', 'bolestan', null, 'A0', 9, 'PUBLISHED', 'bolestan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e5cef763-b367-541e-87a1-6fa6c7281990', 'sentence_builder', 'Складіть: «Я сумую за домом.»', 'Nedostaje mi dom.', '["mi", "dom.", "Nedostaje"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4f48d5d2-574d-5d6e-a3e0-d83125a7f0a3', 'sentence_builder', 'Складіть: «Мені вже краще.»', 'Već mi je bolje.', '["Već", "je", "bolje.", "mi"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b3432c9c-3475-5f6e-8546-f66de7e53862', 'listening', 'Прослухайте і складіть фразу', 'Malo sam usamljena. Nedostaje mi obitelj.', '["Nedostaje", "usamljena.", "mi", "obitelj.", "Malo", "sam"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e138ef88-8d2c-5450-a746-b0cfc791892f', 'listening', 'Прослухайте і складіть фразу', 'Loše. Boli me glava i hladno mi je.', '["Boli", "i", "glava", "Loše.", "me", "mi", "je.", "hladno"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4bb5b797-a08e-54db-b335-739819955ee2', 'speaking', 'Як ти почуваєшся?', 'Kako se osjećaš?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eddda98b-9c7a-5de8-912c-72340a4de8fd', 'speaking', 'Мені нудно.', 'Dosadno mi je.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b77808ba-3bc0-5fce-b231-50a86d4ce9c3', v_lesson, 'Поганий день', 'Loš dan', 2131, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('b596fc0b-9a17-5e64-80df-82dc53ebe8d3', 'b77808ba-3bc0-5fce-b231-50a86d4ce9c3', 'Ivana', 'Dašo, kako se osjećaš? Izgledaš tužno.', 'Дашо, як ти почуваєшся? Ти сумна.', 1);
  perform pg_temp.turn('ada31d2b-cc6f-5a37-8c90-08e575c7c060', 'b77808ba-3bc0-5fce-b231-50a86d4ce9c3', 'Daša', 'Malo sam usamljena. Nedostaje mi obitelj.', 'Мені трохи самотньо. Я сумую за родиною.', 2);
  perform pg_temp.turn('332eda8a-2f80-5192-8644-6e457e40a676', 'b77808ba-3bc0-5fce-b231-50a86d4ce9c3', 'Ivana', 'Razumijem te. Želiš li na kavu?', 'Розумію тебе. Хочеш на каву?', 3);
  perform pg_temp.turn('0fc66cd0-cde5-5fe9-8ab1-f7abd7e1c8e1', 'b77808ba-3bc0-5fce-b231-50a86d4ce9c3', 'Daša', 'Hvala, rado.', 'Дякую, із задоволенням.', 4);
  perform pg_temp.turn('2d1cc860-1204-5d28-a147-8974d3cc53d0', 'b77808ba-3bc0-5fce-b231-50a86d4ce9c3', 'Ivana', 'Idemo! Bit će ti bolje.', 'Ходімо! Тобі стане краще.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b6dd8e3b-1702-5439-bdc2-3524feecf7d1', v_lesson, 'У лікарки', 'Kod liječnice', 2132, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('3484670f-527a-5031-9aff-7b90748d4e1e', 'b6dd8e3b-1702-5439-bdc2-3524feecf7d1', 'Doktorica Marić', 'Kako se osjećate?', 'Як ви почуваєтеся?', 1);
  perform pg_temp.turn('6d4b2cd3-68e0-57c6-aa0e-5e9975a82a17', 'b6dd8e3b-1702-5439-bdc2-3524feecf7d1', 'Darja', 'Loše. Boli me glava i hladno mi je.', 'Погано. У мене болить голова, і мені холодно.', 2);
  perform pg_temp.turn('b2368348-3aef-595f-b599-381a4e4f5b15', 'b6dd8e3b-1702-5439-bdc2-3524feecf7d1', 'Doktorica Marić', 'Imate li temperaturu?', 'У вас є температура?', 3);
  perform pg_temp.turn('b43af561-fb22-503c-909e-3c3940b6e3ce', 'b6dd8e3b-1702-5439-bdc2-3524feecf7d1', 'Darja', 'Imam, malo. I jako sam pospana.', 'Так, невелика. І я дуже сонна.', 4);
  perform pg_temp.turn('0c4b42a7-dd04-52ae-9843-e7be0723c769', 'b6dd8e3b-1702-5439-bdc2-3524feecf7d1', 'Doktorica Marić', 'Bolesni ste, trebate se odmoriti.', 'Ви хворі, вам треба відпочити.', 5);
  perform pg_temp.turn('4a28579a-705e-5562-8c86-6ca1f0a02151', 'b6dd8e3b-1702-5439-bdc2-3524feecf7d1', 'Darja', 'Hvala, doktorice.', 'Дякую, лікарко.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- 5. Наявні уроки модуля A0.2 — на нові місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 2 and u.order_index = 1;
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
   where l.id in ('2b6ed342-cc80-5bd9-baf0-b66109624d62', '8abb83d8-ec02-5921-ac9b-814489816fcd', '8f6439a9-c6ac-5271-99c8-1f0adc5d7599', '04167753-db83-5163-a91c-9f71dac18ab5', '479784bc-54ab-522d-9c77-55887ae68e33', 'a9944193-2dfb-5944-b94c-41c41fdb7ca1', 'adf335ee-0cba-5c9a-b86a-8baac868edbc', '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b', '3b51b1bf-47f4-5709-96d9-c518d36440e6')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or not exists (select 1 from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar')
             and exists (select 1 from public.lesson_grammar lg where lg.lesson_id = l.id)
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_module from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 2;
  select count(*) into v_order from (values ('2b6ed342-cc80-5bd9-baf0-b66109624d62'::uuid, 1), ('8abb83d8-ec02-5921-ac9b-814489816fcd'::uuid, 2), ('8f6439a9-c6ac-5271-99c8-1f0adc5d7599'::uuid, 3), ('04167753-db83-5163-a91c-9f71dac18ab5'::uuid, 4), ('479784bc-54ab-522d-9c77-55887ae68e33'::uuid, 5), ('a9944193-2dfb-5944-b94c-41c41fdb7ca1'::uuid, 6), ('adf335ee-0cba-5c9a-b86a-8baac868edbc'::uuid, 7), ('2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'::uuid, 8), ('3b51b1bf-47f4-5709-96d9-c518d36440e6'::uuid, 9)) as t(id, o) join public.lessons l on l.id = t.id and l.order_index = t.o;
  select count(*) into v_lessons from public.lessons where level_code = 'A0' and status = 'PUBLISHED';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A0' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('2b6ed342-cc80-5bd9-baf0-b66109624d62', '8abb83d8-ec02-5921-ac9b-814489816fcd', '8f6439a9-c6ac-5271-99c8-1f0adc5d7599', '04167753-db83-5163-a91c-9f71dac18ab5', '479784bc-54ab-522d-9c77-55887ae68e33', 'a9944193-2dfb-5944-b94c-41c41fdb7ca1', 'adf335ee-0cba-5c9a-b86a-8baac868edbc', '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b', '3b51b1bf-47f4-5709-96d9-c518d36440e6') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A0.2: % уроків з неправильним складом', v_bad; end if;
  if v_module <> 9 or v_order <> 9 then raise exception 'Модуль A0.2: уроків %, на своїх місцях % (очікувалось 9)', v_module, v_order; end if;
  if v_lessons < 51 then raise exception 'A0: уроків %, очікувалось щонайменше 51', v_lessons; end if;  -- наступні модулі додають уроки
  if v_titles > 0 then raise exception 'A0: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A0.2: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A0.2 — 9 уроків (5–13) за темою; уроків A0 — %', v_lessons;
end $$;

commit;
