-- =====================================================================
-- Уроки A0 за темою · curriculum_a0_v4 · модуль A0.3 · 2026-10-19
-- Згенеровано: python3 scripts/gen_curriculum_a0_v4.py (не редагуйте вручну).
--
-- Рішення власника 2026-10-15: слова уроку — за темою уроку, 20–25 слів і виразів, діалоги під тему; бета (PUBLISHED).
--   * Уроки 14–23: 5 наявних перебудовано, 5 нових тематичних уроків. Слів у них: 156.
--     Кожен: 12–20 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 53.
--   * Нові теми граматики: «Великі числа: сотні, тисячі, мільйони», «Порядкові числівники».
--   * Новий порядок уроків у модулі; назви всіх уроків A0 перенумеровано підряд (разом 56).
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
values ('dvije', 'dvije', 'hr', 'number', 'A0', 'дві (з іменниками жін. роду)', 'core', '{}'::jsonb, '["Imam dvije sestre."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('koliko vas je', 'koliko vas je', 'hr', 'phrase', 'A0', 'скільки вас?', 'chunk', '{}'::jsonb, '["Koliko vas je? — Nas je pet."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pozivni broj', 'pozivni broj', 'hr', 'phrase', 'A0', 'телефонний код', 'collocation', '{}'::jsonb, '["Pozivni broj za Hrvatsku je plus tristo osamdeset pet."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('krivi broj', 'krivi broj', 'hr', 'phrase', 'A0', 'не той номер (помилково набраний)', 'collocation', '{}'::jsonb, '["Oprostite, nazvali ste krivi broj."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stotina', 'stotina', 'hr', 'noun', 'A0', 'сотня', 'core', '{"gender": "f", "plural": "stotine"}'::jsonb, '["Stotine turista dolaze svaki dan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('četiristo', 'cetiristo', 'hr', 'number', 'A0', 'чотириста', 'core', '{}'::jsonb, '["Do Splita ima otprilike četiristo kilometara."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('šesto', 'sesto', 'hr', 'number', 'A0', 'шістсот', 'core', '{}'::jsonb, '["Ovaj laptop košta šesto eura."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sedamsto', 'sedamsto', 'hr', 'number', 'A0', 'сімсот', 'core', '{}'::jsonb, '["Najam stana je sedamsto eura mjesečno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('osamsto', 'osamsto', 'hr', 'number', 'A0', 'вісімсот', 'core', '{}'::jsonb, '["Paket je težak osamsto grama."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('devetsto', 'devetsto', 'hr', 'number', 'A0', 'дев’ятсот', 'core', '{}'::jsonb, '["Ova knjiga ima devetsto stranica."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kilometar', 'kilometar', 'hr', 'noun', 'A0', 'кілометр', 'core', '{"gender": "m", "plural": "kilometri"}'::jsonb, '["Do mora ima sto kilometara."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('metar', 'metar', 'hr', 'noun', 'A0', 'метр', 'core', '{"gender": "m", "plural": "metri"}'::jsonb, '["Stanica je dvjesto metara odavde."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gram', 'gram', 'hr', 'noun', 'A0', 'грам', 'core', '{"gender": "m", "plural": "grami"}'::jsonb, '["Molim dvjesto grama sira."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('iznos', 'iznos', 'hr', 'noun', 'A0', 'сума (грошей)', 'core', '{"gender": "m"}'::jsonb, '["Koji iznos trebam platiti?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('udaljenost', 'udaljenost', 'hr', 'noun', 'A0', 'відстань', 'core', '{"gender": "f"}'::jsonb, '["Udaljenost od Zagreba do Rijeke je oko sto šezdeset kilometara."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('milijarda', 'milijarda', 'hr', 'noun', 'A0', 'мільярд', 'core', '{"gender": "f", "plural": "milijarde"}'::jsonb, '["Na svijetu živi više od osam milijardi ljudi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stanovništvo', 'stanovnistvo', 'hr', 'noun', 'A0', 'населення', 'core', '{"gender": "n"}'::jsonb, '["Popis stanovništva radi se svakih deset godina."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('godišnje', 'godisnje', 'hr', 'adverb', 'A0', 'щороку; на рік', 'core', '{}'::jsonb, '["Plaća je dvadeset tisuća eura godišnje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dvadeseti', 'dvadeseti', 'hr', 'adjective', 'A0', 'двадцятий', 'core', '{"f": "dvadeseta", "n": "dvadeseto"}'::jsonb, '["Živim na dvadesetom katu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stoti', 'stoti', 'hr', 'adjective', 'A0', 'сотий', 'core', '{"f": "stota", "n": "stoto"}'::jsonb, '["Vi ste naš stoti kupac danas!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zadnji', 'zadnji', 'hr', 'adjective', 'A0', 'останній', 'core', '{"f": "zadnja", "n": "zadnje"}'::jsonb, '["Tko je zadnji u redu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('redni broj', 'redni broj', 'hr', 'phrase', 'A0', 'порядковий номер; порядкове число', 'collocation', '{}'::jsonb, '["Na listiću piše Vaš redni broj."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('na redu', 'na redu', 'hr', 'phrase', 'A0', 'на черзі (чия черга)', 'chunk', '{}'::jsonb, '["Tko je sljedeći na redu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prvo', 'prvo', 'hr', 'adverb', 'A0', 'спочатку; по-перше', 'function_word', '{}'::jsonb, '["Prvo platite, onda uzmite kartu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('plus', 'plus', 'hr', 'other', 'A0', 'плюс', 'function_word', '{}'::jsonb, '["Dva plus dva je četiri."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('minus', 'minus', 'hr', 'other', 'A0', 'мінус', 'function_word', '{}'::jsonb, '["Deset minus tri je sedam."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('puta', 'puta', 'hr', 'other', 'A0', 'помножити на; разів', 'function_word', '{}'::jsonb, '["Tri puta tri je devet."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('podijeljeno s', 'podijeljeno s', 'hr', 'phrase', 'A0', 'поділити на (у прикладі)', 'chunk', '{}'::jsonb, '["Osam podijeljeno s dva je četiri."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jednako', 'jednako', 'hr', 'adverb', 'A0', 'дорівнює; однаково', 'core', '{}'::jsonb, '["Pet plus pet jednako je deset."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('koliko je', 'koliko je', 'hr', 'phrase', 'A0', 'скільки буде (у прикладі); скільки це', 'chunk', '{}'::jsonb, '["Koliko je devet puta devet?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zbrojiti', 'zbrojiti', 'hr', 'verb', 'A0', 'додати (числа)', 'core', '{"aspect": "pf"}'::jsonb, '["Zbroji sve račune."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('oduzeti', 'oduzeti', 'hr', 'verb', 'A0', 'відняти', 'core', '{"aspect": "pf"}'::jsonb, '["Od deset oduzmi tri."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pomnožiti', 'pomnoziti', 'hr', 'verb', 'A0', 'помножити', 'core', '{"aspect": "pf"}'::jsonb, '["Pomnoži cijenu s tri."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('paran broj', 'paran broj', 'hr', 'phrase', 'A0', 'парне число', 'collocation', '{}'::jsonb, '["Dva, četiri i šest su parni brojevi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('neparan broj', 'neparan broj', 'hr', 'phrase', 'A0', 'непарне число', 'collocation', '{}'::jsonb, '["Sedam je neparan broj."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kalkulator', 'kalkulator', 'hr', 'noun', 'A0', 'калькулятор', 'core', '{"gender": "m"}'::jsonb, '["Imaš li kalkulator na mobitelu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('desetak', 'desetak', 'hr', 'number', 'A0', 'близько десяти', 'core', '{}'::jsonb, '["Na tečaju je desetak ljudi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dvadesetak', 'dvadesetak', 'hr', 'number', 'A0', 'близько двадцяти', 'core', '{}'::jsonb, '["Čekali smo dvadesetak minuta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stotinjak', 'stotinjak', 'hr', 'number', 'A0', 'близько сотні', 'core', '{}'::jsonb, '["Na koncertu je bilo stotinjak ljudi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nekoliko', 'nekoliko', 'hr', 'pronoun', 'A0', 'кілька', 'function_word', '{}'::jsonb, '["Imam nekoliko pitanja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('par', 'par', 'hr', 'noun', 'A0', 'пара; кілька', 'core', '{"gender": "m"}'::jsonb, '["Vidimo se za par dana."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('trećina', 'trecina', 'hr', 'noun', 'A0', 'третина', 'core', '{"gender": "f"}'::jsonb, '["Trećina plaće ide na stan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('četvrtina', 'cetvrtina', 'hr', 'noun', 'A0', 'чверть; четверта частина', 'core', '{"gender": "f"}'::jsonb, '["Četvrtina torte je za tebe."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('posto', 'posto', 'hr', 'other', 'A0', 'відсоток; відсотків', 'core', '{}'::jsonb, '["Danas je popust dvadeset posto."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('najviše', 'najvise', 'hr', 'adverb', 'A0', 'найбільше; щонайбільше', 'core', '{}'::jsonb, '["Čekat ćemo najviše deset minuta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('koliko imaš godina', 'koliko imas godina', 'hr', 'phrase', 'A0', 'скільки тобі років', 'chunk', '{}'::jsonb, '["Koliko imaš godina? — Dvadeset pet."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stariji', 'stariji', 'hr', 'adjective', 'A0', 'старший', 'core', '{"f": "starija", "n": "starije"}'::jsonb, '["Moj brat je stariji od mene."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mlađi', 'mladi', 'hr', 'adjective', 'A0', 'молодший', 'core', '{"f": "mlađa", "n": "mlađe"}'::jsonb, '["Sestra je dvije godine mlađa."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('godište', 'godiste', 'hr', 'noun', 'A0', 'рік народження', 'core', '{"gender": "n"}'::jsonb, '["Koje si godište? — Devedeset peto."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('punoljetan', 'punoljetan', 'hr', 'adjective', 'A0', 'повнолітній', 'core', '{"f": "punoljetna", "n": "punoljetno"}'::jsonb, '["S osamnaest godina si punoljetan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('maloljetan', 'maloljetan', 'hr', 'adjective', 'A0', 'неповнолітній', 'core', '{"f": "maloljetna", "n": "maloljetno"}'::jsonb, '["Moja kći je još maloljetna."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odrastao', 'odrastao', 'hr', 'adjective', 'A0', 'дорослий', 'core', '{"f": "odrasla", "n": "odraslo"}'::jsonb, '["Karta za odraslu osobu košta pet eura."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ostatak', 'ostatak', 'hr', 'noun', 'A0', 'решта (гроші); залишок', 'core', '{"gender": "m"}'::jsonb, '["Evo Vam ostatak, dva eura."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;

-- 1а. Нові теми граматики A0 (2)
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '79f431d7-62d7-59ca-b963-62893eb2209e', 'A0', 'Великі числа: сотні, тисячі, мільйони', 'Veliki brojevi: stotine, tisuće, milijuni', 'Сотні, тисячі, мільйони й мільярди; як читати довге число; рахуємо вголос; приблизно, частини й відсотки.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Великі числа: сотні, тисячі, мільйони');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'ba2394b6-e377-5e21-b051-65ed1adb8a78', '79f431d7-62d7-59ca-b963-62893eb2209e', 'Сотні', 'Сотні пишуться одним словом: dvjesto, tristo, četiristo, petsto, šesto, sedamsto, osamsto, devetsto. Складене число — по порядку: сотні, десятки, одиниці.', 'tristo četrdeset pet = 345', '[{"hr": "dvjesto eura", "ua": "двісті євро"}, {"hr": "tristo četrdeset pet", "ua": "триста сорок п’ять"}, {"hr": "devetsto devedeset devet", "ua": "дев’ятсот дев’яносто дев’ять"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '79f431d7-62d7-59ca-b963-62893eb2209e')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '0c682821-4e55-570d-8817-847da808afd8', '79f431d7-62d7-59ca-b963-62893eb2209e', 'Тисячі, мільйони, мільярди', 'Tisuća і milijarda — жіночого роду, milijun — чоловічого. Після 2, 3, 4: dvije tisuće, tri milijuna, četiri milijarde; після 5 і більше: pet tisuća, pet milijuna, pet milijardi. «1000 євро» — tisuću eura.', 'dvije tisuće · pet tisuća · dva milijuna', '[{"hr": "tisuću eura", "ua": "тисяча євро"}, {"hr": "dvije tisuće stanovnika", "ua": "дві тисячі жителів"}, {"hr": "pet milijuna ljudi", "ua": "п’ять мільйонів людей"}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '79f431d7-62d7-59ca-b963-62893eb2209e')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '79f692db-206b-5b3c-9c7d-df4d26334a3e', '79f431d7-62d7-59ca-b963-62893eb2209e', 'Як читати довге число', 'Читаємо зліва направо: тисячі, сотні, десятки, одиниці. Рік народження (godište) кажуть порядковим числом: devedeset drugo — 1992-го.', '2026 = dvije tisuće dvadeset šest', '[{"hr": "dvije tisuće dvadeset šest", "ua": "дві тисячі двадцять шість"}, {"hr": "tisuću devetsto osamdeset", "ua": "тисяча дев’ятсот вісімдесят"}, {"hr": "dvjesto pedeset tisuća eura", "ua": "двісті п’ятдесят тисяч євро"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '79f431d7-62d7-59ca-b963-62893eb2209e')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '07adba91-9e3b-5efc-b797-4d9415492d85', '79f431d7-62d7-59ca-b963-62893eb2209e', 'Рахуємо вголос', 'Plus, minus, puta (помножити на), podijeljeno s (поділити на); «дорівнює» — je або jednako je.', 'Dva plus tri je pet.', '[{"hr": "Dva plus tri je pet.", "ua": "Два плюс три — п’ять."}, {"hr": "Tri puta četiri je dvanaest.", "ua": "Три помножити на чотири — дванадцять."}, {"hr": "Osam podijeljeno s dva jednako je četiri.", "ua": "Вісім поділити на два дорівнює чотири."}]'::jsonb, 4
where exists (select 1 from public.grammar_topics where id = '79f431d7-62d7-59ca-b963-62893eb2209e')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'a9bde1a9-ffb5-5de8-bcdf-62b3de65d35b', '79f431d7-62d7-59ca-b963-62893eb2209e', 'Приблизно, частини, відсотки', 'Приблизно: desetak (≈ 10), dvadesetak (≈ 20), stotinjak (≈ 100) + родовий множини. Частини: pola (половина), trećina, četvrtina. Відсотки: число + posto.', 'desetak ljudi · pola cijene · trideset posto', '[{"hr": "desetak ljudi", "ua": "близько десяти людей"}, {"hr": "pola kile", "ua": "пів кілограма"}, {"hr": "trideset posto popusta", "ua": "тридцять відсотків знижки"}]'::jsonb, 5
where exists (select 1 from public.grammar_topics where id = '79f431d7-62d7-59ca-b963-62893eb2209e')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '79f431d7-62d7-59ca-b963-62893eb2209e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нова тема граматики A0 для уроків за темою (curriculum_a0_v4) за запитом власника 2026-10-19. Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '79f431d7-62d7-59ca-b963-62893eb2209e')
  and not exists (select 1 from public.content_reviews where entity_id = '79f431d7-62d7-59ca-b963-62893eb2209e' and notes = 'Бета: нова тема граматики A0 для уроків за темою (curriculum_a0_v4) за запитом власника 2026-10-19. Потрібна перевірка носієм.');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '6b94be82-6b25-5565-86d8-d4c0e429c627', 'A0', 'Порядкові числівники', 'Redni brojevi', 'Перший, другий, третій…: узгодження з іменником і запис цифрою з крапкою.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Порядкові числівники');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '1fa7bed6-ee4f-54df-83db-6ade4b1c24f6', '6b94be82-6b25-5565-86d8-d4c0e429c627', 'Перший … десятий', 'prvi, drugi, treći, četvrti, peti, šesti, sedmi, osmi, deveti, deseti; далі — dvadeseti, stoti. У складених змінюється лише останнє слово: dvadeset prvi.', 'prvi · drugi · treći · dvadeset prvi', '[{"hr": "prvi dan", "ua": "перший день"}, {"hr": "deseti put", "ua": "десятий раз"}, {"hr": "dvadeset prvi", "ua": "двадцять перший"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '6b94be82-6b25-5565-86d8-d4c0e429c627')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '5ff86011-9303-591a-ae6a-d2717e8e6a53', '6b94be82-6b25-5565-86d8-d4c0e429c627', 'Як прикметник', 'Порядкове число узгоджується з іменником, як прикметник: prvi kat, prva ulica, prvo mjesto. На якому поверсі? — na prvom, drugom, trećem katu.', 'prvi kat · prva ulica · na trećem katu', '[{"hr": "Živim na trećem katu.", "ua": "Я живу на третьому поверсі."}, {"hr": "Treća vrata lijevo.", "ua": "Треті двері ліворуч."}, {"hr": "Ovo mi je prvi put.", "ua": "Я тут уперше."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '6b94be82-6b25-5565-86d8-d4c0e429c627')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'a5882358-61ac-5a60-afe5-2becf3379d4c', '6b94be82-6b25-5565-86d8-d4c0e429c627', 'Цифра з крапкою', 'Порядкове число цифрою пишуть із крапкою: 3. kat = treći kat, 5. razred = peti razred.', '3. kat = treći kat', '[{"hr": "2. kat", "ua": "другий поверх"}, {"hr": "5. razred", "ua": "п’ятий клас"}, {"hr": "21. stoljeće", "ua": "двадцять перше століття"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '6b94be82-6b25-5565-86d8-d4c0e429c627')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '6b94be82-6b25-5565-86d8-d4c0e429c627', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нова тема граматики A0 для уроків за темою (curriculum_a0_v4) за запитом власника 2026-10-19. Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '6b94be82-6b25-5565-86d8-d4c0e429c627')
  and not exists (select 1 from public.content_reviews where entity_id = '6b94be82-6b25-5565-86d8-d4c0e429c627' and notes = 'Бета: нова тема граматики A0 для уроків за темою (curriculum_a0_v4) за запитом власника 2026-10-19. Потрібна перевірка носієм.');

-- 2. Перебудова наявних уроків модуля A0.3
-- A0.3 · урок 14: Числа від 0 до 10 — перебудова: 16 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'c0941bd8-57b5-5e7e-981f-9be423f24208';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Числа від 0 до 10» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'cff67650-034f-57a8-912a-869f461a2905') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 14: Числа від 0 до 10', title_hr = 'Lekcija 14: Brojevi od nula do deset',
         objectives = '["Рахувати від 0 до 10", "Казати «два» і «дві»: dva brata, dvije sestre", "Назвати номер квартири чи будинку"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'nula', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jedan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dvije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tri', v_pos);
  v_pos := pg_temp.word(v_lesson, 'četiri', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sedam', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osam', v_pos);
  v_pos := pg_temp.word(v_lesson, 'devet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'deset', v_pos);
  v_pos := pg_temp.word(v_lesson, 'broj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brojka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brojati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koliko', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eb19c8aa-2d6c-5f6a-9754-8e49da7b2180', 'fill_in_the_blank', 'Imam ___ sestre.', 'dvije', '["dvjema", "dvije", "dvoje", "dva"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0e6f345d-4724-5cee-92cd-b4de3bb6bfca', 'multiple_choice', 'Що означає «broj»?', 'номер / число', '["шість", "п''ять", "номер / число", "сім"]'::jsonb, 'A0', 2, 'PUBLISHED', 'broj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '850f7c9b-e396-51b8-bac1-38f6793fb3b5', 'multiple_choice', 'Що означає «sedam»?', 'сім', '["п''ять", "сім", "вісім", "чотири"]'::jsonb, 'A0', 3, 'PUBLISHED', 'sedam', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f4eb9a0a-0990-5db4-8297-2881372f4df8', 'multiple_choice', 'Що означає «dvije»?', 'дві (з іменниками жін. роду)', '["дев''ять", "два", "сім", "дві (з іменниками жін. роду)"]'::jsonb, 'A0', 4, 'PUBLISHED', 'dvije', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9a81a11a-a931-54e3-baa1-d23d6c86692d', 'multiple_choice', 'Як хорватською «два»?', 'dva', '["dva", "sedam", "osam", "jedan"]'::jsonb, 'A0', 5, 'PUBLISHED', 'dva', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '67bfe444-2d28-5e4c-9bf2-18c97a1afe54', 'multiple_choice', 'Як хорватською «нуль»?', 'nula', '["koliko", "nula", "brojati", "šest"]'::jsonb, 'A0', 6, 'PUBLISHED', 'nula', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '75764df2-ba11-53ce-b6e6-be36af390754', 'type_answer', 'Напишіть хорватською: «три»', 'tri', null, 'A0', 7, 'PUBLISHED', 'tri', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a32aa45f-d483-5a33-b7b9-394f01f899b9', 'type_answer', 'Напишіть хорватською: «вісім»', 'osam', null, 'A0', 8, 'PUBLISHED', 'osam', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a31050fd-4f33-5faa-9bc9-61ee910ae3b1', 'type_answer', 'Напишіть хорватською: «шість»', 'šest', null, 'A0', 9, 'PUBLISHED', 'šest', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c5255d97-8956-58a9-b14c-35c41fc2503a', 'sentence_builder', 'Складіть: «Мій номер — нуль дев’ять один.»', 'Moj broj je nula devet jedan.', '["Moj", "jedan.", "devet", "broj", "nula", "je"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c346be00-fdc9-56ca-81b0-2594e6c53c47', 'sentence_builder', 'Складіть: «Скільки тут яблук?»', 'Koliko ima jabuka?', '["ima", "Koliko", "jabuka?"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c87e8a66-afa6-552b-997b-2ea3bfe67817', 'listening', 'Прослухайте і складіть фразу', 'A koliko ima krušaka?', '["ima", "A", "krušaka?", "koliko"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c18e8cd3-e7e5-5d91-af45-5d9325a4c1c5', 'listening', 'Прослухайте і складіть фразу', 'Dobro, dolazim za pet minuta.', '["pet", "Dobro,", "minuta.", "dolazim", "za"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7684aeba-5415-57e7-8071-44af462827bd', 'speaking', 'Сім, не вісім.', 'Sedam, ne osam.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4d3c8f24-8274-5896-9eda-d09149947fa7', 'speaking', 'Нуль, один, два, три.', 'Nula, jedan, dva, tri.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cff67650-034f-57a8-912a-869f461a2905', v_lesson, 'Скільки яблук?', 'Koliko jabuka?', 2141, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('418d9271-5c0e-59a6-bd8f-02d593438e9c', 'cff67650-034f-57a8-912a-869f461a2905', 'Mia', 'Dašo, koliko ima jabuka?', 'Дашо, скільки тут яблук?', 1);
  perform pg_temp.turn('a7752ac9-c84d-51c5-9ad6-618ff3a7da94', 'cff67650-034f-57a8-912a-869f461a2905', 'Daša', 'Brojimo zajedno: jedan, dva, tri…', 'Рахуймо разом: один, два, три…', 2);
  perform pg_temp.turn('17eaf9c0-caab-55f5-8a96-0da3ab404c3a', 'cff67650-034f-57a8-912a-869f461a2905', 'Mia', 'Četiri, pet, šest! Šest jabuka!', 'Чотири, п’ять, шість! Шість яблук!', 3);
  perform pg_temp.turn('2ce94b74-4c87-57b0-af7f-82c6af07e424', 'cff67650-034f-57a8-912a-869f461a2905', 'Daša', 'Bravo! A koliko ima krušaka?', 'Молодець! А скільки груш?', 4);
  perform pg_temp.turn('77ca1594-ffbf-5146-af06-6c720f8a6b3a', 'cff67650-034f-57a8-912a-869f461a2905', 'Mia', 'Samo dvije.', 'Лише дві.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8261022f-55e9-569b-9ec1-0d7f02891ed6', v_lesson, 'Номер квартири', 'Broj stana', 2142, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('0a58c0ab-cf70-5bf9-95ba-29d97d2e1e21', '8261022f-55e9-569b-9ec1-0d7f02891ed6', 'Dostavljač', 'Dobar dan, dostava! Koji je broj Vašeg stana?', 'Добрий день, доставка! Який номер вашої квартири?', 1);
  perform pg_temp.turn('8806c70f-b057-5f44-b8e9-93386fe66539', '8261022f-55e9-569b-9ec1-0d7f02891ed6', 'Daša', 'Broj sedam.', 'Номер сім.', 2);
  perform pg_temp.turn('bd6a3f6a-c9ca-5f30-9748-0c473ad9da4c', '8261022f-55e9-569b-9ec1-0d7f02891ed6', 'Dostavljač', 'Sedam ili osam?', 'Сім чи вісім?', 3);
  perform pg_temp.turn('bdff7598-0593-51fc-9ebc-998a44473711', '8261022f-55e9-569b-9ec1-0d7f02891ed6', 'Daša', 'Sedam, ne osam.', 'Сім, не вісім.', 4);
  perform pg_temp.turn('764152f5-795e-543a-8341-a43b17a1d7d4', '8261022f-55e9-569b-9ec1-0d7f02891ed6', 'Dostavljač', 'Dobro, dolazim za pet minuta.', 'Добре, буду за п’ять хвилин.', 5);
  perform pg_temp.turn('75cd84c6-3ac9-577b-a78e-da3e5022c9b3', '8261022f-55e9-569b-9ec1-0d7f02891ed6', 'Daša', 'Hvala, čekam!', 'Дякую, чекаю!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.3 · урок 15: Числа від 11 до 20 — перебудова: 15 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'e30c65f2-1a30-5b51-85e7-6a460cd1799f';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Числа від 11 до 20» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '4e43c139-a163-5503-a419-dce26e17863c') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 15: Числа від 11 до 20', title_hr = 'Lekcija 15: Brojevi od jedanaest do dvadeset',
         objectives = '["Рахувати від 11 до 20", "Сказати, скільки вас людей: Nas je dvanaest", "Зрозуміти номер автобуса й час у хвилинах"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'jedanaest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dvanaest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trinaest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'četrnaest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'petnaest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šesnaest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sedamnaest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osamnaest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'devetnaest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dvadeset', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osoba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koliko vas je', v_pos);
  v_pos := pg_temp.word(v_lesson, 'samo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'još', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ukupno', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2569b921-ad6f-5430-97af-e18b31245136', 'fill_in_the_blank', 'Nas ___ dvanaest.', 'je', '["smo", "su", "ste", "je"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'af1be9a3-7e44-5e38-b03a-7317f9893a2d', 'multiple_choice', 'Що означає «devetnaest»?', 'дев''ятнадцять', '["тільки / лише", "скільки вас?", "дев''ятнадцять", "чотирнадцять"]'::jsonb, 'A0', 2, 'PUBLISHED', 'devetnaest', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f1c91c54-f1db-5705-b446-4136a478c1cf', 'multiple_choice', 'Що означає «još»?', 'ще', '["сімнадцять", "ще", "п''ятнадцять", "разом; загалом"]'::jsonb, 'A0', 3, 'PUBLISHED', 'još', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '02ea160a-a0e5-5640-bdf0-aa819e05d581', 'multiple_choice', 'Що означає «osoba»?', 'особа', '["тринадцять", "п''ятнадцять", "дванадцять", "особа"]'::jsonb, 'A0', 4, 'PUBLISHED', 'osoba', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fab1b8be-1d4b-58c9-bfe8-b54e7bc122b2', 'multiple_choice', 'Як хорватською «чотирнадцять»?', 'četrnaest', '["četrnaest", "koliko vas je", "petnaest", "dvadeset"]'::jsonb, 'A0', 5, 'PUBLISHED', 'četrnaest', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8604f4ea-ac1c-5a14-814c-52c36367c423', 'multiple_choice', 'Як хорватською «одинадцять»?', 'jedanaest', '["ukupno", "jedanaest", "dvanaest", "šesnaest"]'::jsonb, 'A0', 6, 'PUBLISHED', 'jedanaest', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ca46a5e-d106-53fe-9981-d758429da47b', 'type_answer', 'Напишіть хорватською: «дванадцять»', 'dvanaest', null, 'A0', 7, 'PUBLISHED', 'dvanaest', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '266d5edd-bc9d-5788-b9b4-00d42e7d7bae', 'type_answer', 'Напишіть хорватською: «сімнадцять»', 'sedamnaest', null, 'A0', 8, 'PUBLISHED', 'sedamnaest', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7366e162-884b-545e-8a3a-04bb66a795bb', 'type_answer', 'Напишіть хорватською: «тринадцять»', 'trinaest', null, 'A0', 9, 'PUBLISHED', 'trinaest', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a2de2012-edaa-5b9e-861a-ad6843598ca4', 'sentence_builder', 'Складіть: «Скільки вас?»', 'Koliko vas je?', '["je?", "Koliko", "vas"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bb57cea4-da41-53b8-b5ac-680b55da0eed', 'sentence_builder', 'Складіть: «Ще дві особи.»', 'Još dvije osobe.', '["dvije", "Još", "osobe."]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '40eb53f2-a186-57f2-9557-6b2a59b645a0', 'listening', 'Прослухайте і складіть фразу', 'Nas je dvanaest.', '["je", "Nas", "dvanaest."]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c2a7bc0f-0e5a-5f64-8c0c-b8be6a6ad13e', 'listening', 'Прослухайте і складіть фразу', 'Za točno petnaest minuta.', '["Za", "minuta.", "točno", "petnaest"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '44f63fc8-8643-59fa-93ce-5bbe21f7b468', 'speaking', 'Нас чотирнадцять.', 'Nas je četrnaest.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '07ecebe9-df86-50d2-a6fc-71a3f42e53de', 'speaking', 'Автобус номер сімнадцять.', 'Autobus broj sedamnaest.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4e43c139-a163-5503-a419-dce26e17863c', v_lesson, 'Стіл на скількох?', 'Stol za koliko osoba?', 2151, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('43cff97d-5282-584a-8bbc-c22259e989c5', '4e43c139-a163-5503-a419-dce26e17863c', 'Konobar', 'Dobra večer! Koliko vas je?', 'Добрий вечір! Скільки вас?', 1);
  perform pg_temp.turn('4d64ab3d-01c0-50e4-9990-c999b5ffc1df', '4e43c139-a163-5503-a419-dce26e17863c', 'Daša', 'Nas je dvanaest.', 'Нас дванадцять.', 2);
  perform pg_temp.turn('7fa765cd-f231-550c-966b-8857ec356d70', '4e43c139-a163-5503-a419-dce26e17863c', 'Konobar', 'Za dvanaest osoba imamo jedan veliki stol.', 'Для дванадцяти осіб у нас є один великий стіл.', 3);
  perform pg_temp.turn('fd08f760-aae9-53e6-a006-81293946963a', '4e43c139-a163-5503-a419-dce26e17863c', 'Daša', 'Super. Dolaze još dvije osobe, ukupno četrnaest.', 'Чудово. Прийдуть ще дві особи, разом чотирнадцять.', 4);
  perform pg_temp.turn('f35ef360-a561-584f-98b3-c361929a97f8', '4e43c139-a163-5503-a419-dce26e17863c', 'Konobar', 'Četrnaest? Nema problema.', 'Чотирнадцять? Без проблем.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3c21a0b0-6e22-5af5-84de-cfa0d47bfdb9', v_lesson, 'Який автобус?', 'Koji autobus?', 2152, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('2e62585e-5bb2-5a9c-b0b0-0aad1bdcbe11', '3c21a0b0-6e22-5af5-84de-cfa0d47bfdb9', 'Daša', 'Oprostite, koji autobus ide na kolodvor?', 'Вибачте, який автобус їде на вокзал?', 1);
  perform pg_temp.turn('003e4c44-de17-5c9f-85b2-566fb7fa95ef', '3c21a0b0-6e22-5af5-84de-cfa0d47bfdb9', 'Gospođa Šimić', 'Sedamnaest ili devetnaest.', 'Сімнадцятий або дев’ятнадцятий.', 2);
  perform pg_temp.turn('c1211ec0-14c0-5b5a-9704-dc9a934dcb11', '3c21a0b0-6e22-5af5-84de-cfa0d47bfdb9', 'Daša', 'Kada dolazi sedamnaest?', 'Коли приходить сімнадцятий?', 3);
  perform pg_temp.turn('c553f634-218a-57bb-b4f1-ed2e0ecb5040', '3c21a0b0-6e22-5af5-84de-cfa0d47bfdb9', 'Gospođa Šimić', 'Za točno petnaest minuta.', 'Рівно за п’ятнадцять хвилин.', 4);
  perform pg_temp.turn('c9bbcf97-b7c3-5889-b0e7-483e9c28415d', '3c21a0b0-6e22-5af5-84de-cfa0d47bfdb9', 'Daša', 'A devetnaest?', 'А дев’ятнадцятий?', 5);
  perform pg_temp.turn('ad3b0504-0665-5d25-b1d4-1ff5cd4d8ad2', '3c21a0b0-6e22-5af5-84de-cfa0d47bfdb9', 'Gospođa Šimić', 'Devetnaest dolazi za dvadeset minuta.', 'Дев’ятнадцятий приходить за двадцять хвилин.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.3 · урок 16: Десятки й номер телефону — перебудова: 16 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Десятки й номер телефону» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '32606bff-06b3-555d-8b0c-e9a07608997c') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 16: Десятки й номер телефону', title_hr = 'Lekcija 16: Desetice i broj telefona',
         objectives = '["Рахувати десятками до 100", "Складати числа: trideset pet, devedeset devet", "Продиктувати й записати номер телефону"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'trideset', v_pos);
  v_pos := pg_temp.word(v_lesson, 'četrdeset', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pedeset', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šezdeset', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sedamdeset', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osamdeset', v_pos);
  v_pos := pg_temp.word(v_lesson, 'devedeset', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'broj telefona', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pozivni broj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krivi broj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mobitel', v_pos);
  v_pos := pg_temp.word(v_lesson, 'telefon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nazvati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zapisati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponoviti', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '5810643e-1986-5a27-9502-3ff93fa3998c', 'fill_in_the_blank', 'Trideset i trideset je ___.', 'šezdeset', '["šest", "šezdeset", "šesnaest", "šesti"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '24e95d15-50a2-590d-be5e-7799a56dec84', 'multiple_choice', 'Що означає «devedeset»?', 'дев''яносто', '["записати", "сто", "дев''яносто", "номер телефону"]'::jsonb, 'A0', 2, 'PUBLISHED', 'devedeset', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '46cef8b2-68a2-5b77-9c5b-2b7d5efcee1c', 'multiple_choice', 'Що означає «krivi broj»?', 'не той номер (помилково набраний)', '["тридцять", "телефон", "шістдесят", "не той номер (помилково набраний)"]'::jsonb, 'A0', 3, 'PUBLISHED', 'krivi broj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fbb5ef5b-d81a-5ff3-b9c5-8d0499d7505a', 'multiple_choice', 'Що означає «ponoviti»?', 'повторити', '["повторити", "тридцять", "номер телефону", "подзвонити / назвати"]'::jsonb, 'A0', 4, 'PUBLISHED', 'ponoviti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fcde8270-4d6b-5cff-853f-b13a59157c4f', 'multiple_choice', 'Як хорватською «тридцять»?', 'trideset', '["zapisati", "pedeset", "sedamdeset", "trideset"]'::jsonb, 'A0', 5, 'PUBLISHED', 'trideset', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5808882e-21f0-57d6-a64e-f7eac043893c', 'multiple_choice', 'Як хорватською «телефонний код»?', 'pozivni broj', '["zapisati", "telefon", "sto", "pozivni broj"]'::jsonb, 'A0', 6, 'PUBLISHED', 'pozivni broj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '332d25d6-4d1e-5d7f-b767-19e886add3a3', 'type_answer', 'Напишіть хорватською: «сімдесят»', 'sedamdeset', null, 'A0', 7, 'PUBLISHED', 'sedamdeset', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a633265c-5bd7-55ca-9d2f-b0916f6bcdb3', 'type_answer', 'Напишіть хорватською: «сорок»', 'četrdeset', null, 'A0', 8, 'PUBLISHED', 'četrdeset', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7d4398f9-1787-5d1a-be4d-dc8fb4edf960', 'type_answer', 'Напишіть хорватською: «подзвонити / назвати»', 'nazvati', null, 'A0', 9, 'PUBLISHED', 'nazvati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '083cd5f6-880e-5d03-8dc2-9303b20f2cb6', 'sentence_builder', 'Складіть: «Ви набрали не той номер.»', 'Nazvali ste krivi broj.', '["ste", "krivi", "Nazvali", "broj."]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3b65835f-94f4-5bd4-93a6-8959c2be989b', 'sentence_builder', 'Складіть: «Який ваш номер телефону?»', 'Koji je Vaš broj telefona?', '["je", "Koji", "Vaš", "telefona?", "broj"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0e78364e-f3e9-5ce4-a428-29dccdf097ab', 'listening', 'Прослухайте і складіть фразу', 'Sedamdeset dva, devedeset jedan.', '["Sedamdeset", "jedan.", "dva,", "devedeset"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '80ad09c1-9b08-58b3-9ada-0702648f8a17', 'listening', 'Прослухайте і складіть фразу', 'Ne, nazvali ste krivi broj.', '["nazvali", "broj.", "krivi", "ste", "Ne,"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '21844823-183a-51ef-b1f6-9f10f19f8200', 'speaking', 'Дев’яносто дев’ять.', 'Devedeset devet.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '359f6f59-6e97-569d-b292-c8dd3768e722', 'speaking', 'Можете повторити номер?', 'Možete li ponoviti broj?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('32606bff-06b3-555d-8b0c-e9a07608997c', v_lesson, 'Продиктуйте номер', 'Koji je Vaš broj?', 2161, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('f66aef07-95ca-587b-a77f-54fb1c150078', '32606bff-06b3-555d-8b0c-e9a07608997c', 'Službenica', 'Koji je Vaš broj mobitela?', 'Який у вас номер мобільного?', 1);
  perform pg_temp.turn('4e011d9d-e286-5cf9-a6c1-4eaff60f4ebc', '32606bff-06b3-555d-8b0c-e9a07608997c', 'Daša', 'Nula devet osam, pedeset tri, sedamdeset dva, devedeset jedan.', 'Нуль дев’ять вісім, п’ятдесят три, сімдесят два, дев’яносто один.', 2);
  perform pg_temp.turn('5d0405b9-526d-5474-82b1-433afabc59f4', '32606bff-06b3-555d-8b0c-e9a07608997c', 'Službenica', 'Oprostite, možete li ponoviti zadnje brojeve?', 'Вибачте, можете повторити останні цифри?', 3);
  perform pg_temp.turn('dfd32f11-e45b-5fe1-ab73-8809950d2136', '32606bff-06b3-555d-8b0c-e9a07608997c', 'Daša', 'Sedamdeset dva, devedeset jedan.', 'Сімдесят два, дев’яносто один.', 4);
  perform pg_temp.turn('6d5ad8ba-ea69-5a0e-a14a-3249c122ca30', '32606bff-06b3-555d-8b0c-e9a07608997c', 'Službenica', 'Zapisala sam. Hvala!', 'Я записала. Дякую!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('bc40ee3c-94af-5f01-855e-0f54b5c805c0', v_lesson, 'Не той номер', 'Krivi broj', 2162, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('e88ca13d-6cd9-5412-9a60-76245145a189', 'bc40ee3c-94af-5f01-855e-0f54b5c805c0', 'Daša', 'Halo?', 'Алло?', 1);
  perform pg_temp.turn('5946f37e-02b9-59b1-84b2-6eada6c73259', 'bc40ee3c-94af-5f01-855e-0f54b5c805c0', 'Gospođa Kos', 'Dobar dan, je li to frizerski salon?', 'Добрий день, це перукарня?', 2);
  perform pg_temp.turn('a3f0a3b1-c566-5bea-b6d7-4c3a89b60d34', 'bc40ee3c-94af-5f01-855e-0f54b5c805c0', 'Daša', 'Ne, nazvali ste krivi broj.', 'Ні, ви набрали не той номер.', 3);
  perform pg_temp.turn('f170858c-317d-549c-8df4-1a948cfd7690', 'bc40ee3c-94af-5f01-855e-0f54b5c805c0', 'Gospođa Kos', 'Oprostite! Je li ovo pedeset šest, osamdeset dva?', 'Вибачте! Це п’ятдесят шість, вісімдесят два?', 4);
  perform pg_temp.turn('bf2df9ed-b012-5164-92d3-bb7addbe652f', 'bc40ee3c-94af-5f01-855e-0f54b5c805c0', 'Daša', 'Nije, ovo je pedeset šest, osamdeset tri.', 'Ні, це п’ятдесят шість, вісімдесят три.', 5);
  perform pg_temp.turn('47dda8ae-edef-5d03-a3fc-f151caa9bf0c', 'bc40ee3c-94af-5f01-855e-0f54b5c805c0', 'Gospođa Kos', 'Ah, krivo sam zapisala. Hvala!', 'А, я неправильно записала. Дякую!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.3 · урок 22: Скільки вам років? — перебудова: 16 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '4c5db9c0-aa58-55c5-b647-7f7cfc8396c2';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Скільки вам років?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '2c6bdf66-d1c0-5db4-bb83-1fb938e373bb') then return; end if;  -- уже перебудовано
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
  if v_gid is null then select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Числа 0–100' and status = 'PUBLISHED' order by created_at limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 22: Скільки вам років?', title_hr = 'Lekcija 22: Koliko imate godina?',
         objectives = '["Сказати свій вік: imam trideset godina", "Запитати про вік на «ти» і на «ви»", "Порівняти: stariji, mlađi"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'koliko godina imate', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koliko imaš godina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'imati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjesec', v_pos);
  v_pos := pg_temp.word(v_lesson, 'star', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mlad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stariji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mlađi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'punoljetan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maloljetan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odrastao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'beba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rođendan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slaviti', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae6643fd-f3e1-5f04-9b06-f9bdb5e733f6', 'fill_in_the_blank', 'Moj sin ___ šest godina.', 'ima', '["su", "ima", "imaju", "je"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bd0e4fc1-407b-5cf4-a052-96a1e8ee14e2', 'multiple_choice', 'Що означає «mjesec»?', 'місяць', '["скільки тобі років", "місяць", "немовля", "рік народження"]'::jsonb, 'A0', 2, 'PUBLISHED', 'mjesec', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ac21a11-6503-57f4-bfd6-32cd7c2a5b78', 'multiple_choice', 'Що означає «mlađi»?', 'молодший', '["святкувати", "молодший", "рік народження", "скільки тобі років"]'::jsonb, 'A0', 3, 'PUBLISHED', 'mlađi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3ad566bf-0c94-5ca2-ad18-8f3456a38f49', 'multiple_choice', 'Що означає «slaviti»?', 'святкувати', '["рік", "святкувати", "скільки тобі років", "старший"]'::jsonb, 'A0', 4, 'PUBLISHED', 'slaviti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d4ac0fe-037e-5a7e-b557-0b0e45981fc2', 'multiple_choice', 'Як хорватською «немовля»?', 'beba', '["stariji", "mlad", "koliko imaš godina", "beba"]'::jsonb, 'A0', 5, 'PUBLISHED', 'beba', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6f5e96a1-d1c5-53b0-b2fb-a708ee3cf6ad', 'multiple_choice', 'Як хорватською «дорослий»?', 'odrastao', '["maloljetan", "mlađi", "odrastao", "mlad"]'::jsonb, 'A0', 6, 'PUBLISHED', 'odrastao', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3864997d-e2f8-52f4-ac44-77f5612aa905', 'type_answer', 'Напишіть хорватською: «старий»', 'star', null, 'A0', 7, 'PUBLISHED', 'star', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd3917100-7ad2-5d51-a2da-172863602d0d', 'type_answer', 'Напишіть хорватською: «старший»', 'stariji', null, 'A0', 8, 'PUBLISHED', 'stariji', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c048312-bb88-530d-9084-14217ac2a04e', 'type_answer', 'Напишіть хорватською: «неповнолітній»', 'maloljetan', null, 'A0', 9, 'PUBLISHED', 'maloljetan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be04b00f-4ddc-5e40-ad37-3c26d40804e0', 'sentence_builder', 'Складіть: «Мені тридцять чотири роки.»', 'Imam trideset četiri godine.', '["Imam", "godine.", "četiri", "trideset"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '420ce3a7-9956-5f23-ae28-fa58e7d72166', 'sentence_builder', 'Складіть: «Він старший за мене.»', 'On je stariji od mene.', '["stariji", "mene.", "je", "od", "On"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '88e8fedb-c90b-56ca-b8ce-8489874a0f7d', 'listening', 'Прослухайте і складіть фразу', 'Sin ima šest godina, a kći osam mjeseci.', '["kći", "osam", "a", "ima", "mjeseci.", "godina,", "Sin", "šest"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e06602a7-5270-5914-8dcc-1b7c597626d9', 'listening', 'Прослухайте і складіть фразу', 'On je stariji, ima četrdeset dva.', '["četrdeset", "On", "dva.", "je", "ima", "stariji,"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '772e0542-c933-5198-811f-eaf17f9f88d4', 'speaking', 'Скільки тобі років?', 'Koliko imaš godina?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e9fc8a8-b9d3-5ed2-b222-5e7771119bd0', 'speaking', 'Мені двадцять п’ять років.', 'Imam dvadeset pet godina.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2c6bdf66-d1c0-5db4-bb83-1fb938e373bb', v_lesson, 'У поліклініці', 'U ambulanti', 2221, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('8aef20cf-6b4a-5f80-8f09-5b565459ee6d', '2c6bdf66-d1c0-5db4-bb83-1fb938e373bb', 'Medicinska sestra', 'Koliko godina imate?', 'Скільки вам років?', 1);
  perform pg_temp.turn('2afd8213-4905-5de1-803e-094a20a6855a', '2c6bdf66-d1c0-5db4-bb83-1fb938e373bb', 'Darja', 'Trideset četiri.', 'Тридцять чотири.', 2);
  perform pg_temp.turn('c829376c-5587-5c79-aefd-f4249fc725a7', '2c6bdf66-d1c0-5db4-bb83-1fb938e373bb', 'Medicinska sestra', 'Koje ste godište?', 'Якого ви року народження?', 3);
  perform pg_temp.turn('a6ba0e0d-9016-5cc7-ba2a-2c3cb00d36d9', '2c6bdf66-d1c0-5db4-bb83-1fb938e373bb', 'Darja', 'Devedeset drugo.', 'Дев’яносто другого.', 4);
  perform pg_temp.turn('4987af70-3d24-535b-8d1b-2bf90735232f', '2c6bdf66-d1c0-5db4-bb83-1fb938e373bb', 'Medicinska sestra', 'A djeca?', 'А діти?', 5);
  perform pg_temp.turn('203ac932-9015-54c5-8d99-f7d7252278a6', '2c6bdf66-d1c0-5db4-bb83-1fb938e373bb', 'Darja', 'Sin ima šest godina, a kći osam mjeseci.', 'Синові шість років, а доньці вісім місяців.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('20ea4bbd-4c1f-5b01-9553-f74d29772fae', v_lesson, 'Скільки тобі років?', 'Koliko imaš godina?', 2222, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('5b0d7574-0df9-5b58-9478-19d077393a93', '20ea4bbd-4c1f-5b01-9553-f74d29772fae', 'Luka', 'Dašo, sretan rođendan! Koliko imaš godina?', 'Дашо, з днем народження! Скільки тобі років?', 1);
  perform pg_temp.turn('b687c754-325c-557b-9cbf-907cb5381c7b', '20ea4bbd-4c1f-5b01-9553-f74d29772fae', 'Daša', 'Danas imam trideset četiri.', 'Сьогодні мені тридцять чотири.', 2);
  perform pg_temp.turn('5a2aee89-fe83-5a4e-a985-b638814d9461', '20ea4bbd-4c1f-5b01-9553-f74d29772fae', 'Luka', 'Mlađa si od mene. Ja imam trideset osam.', 'Ти молодша за мене. Мені тридцять вісім.', 3);
  perform pg_temp.turn('ca75aadb-4684-552b-ac4e-1406f0c0e9ea', '20ea4bbd-4c1f-5b01-9553-f74d29772fae', 'Daša', 'A tvoj brat?', 'А твоєму братові?', 4);
  perform pg_temp.turn('ed472d10-a290-59d4-99aa-6de9efb76797', '20ea4bbd-4c1f-5b01-9553-f74d29772fae', 'Luka', 'On je stariji, ima četrdeset dva.', 'Він старший, йому сорок два.', 5);
  perform pg_temp.turn('da62959c-b36c-557c-8737-9e210d997d44', '20ea4bbd-4c1f-5b01-9553-f74d29772fae', 'Daša', 'Idemo slaviti!', 'Ходімо святкувати!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.3 · урок 23: Скільки це коштує? — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '427e5058-7381-58a0-8f21-bd170866dbae';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Скільки це коштує?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '1247f1c7-9aa1-51cf-b143-8077a1b6ef68') then return; end if;  -- уже перебудовано
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
  if v_gid is null then select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Числа 0–100' and status = 'PUBLISHED' order by created_at limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 23: Скільки це коштує?', title_hr = 'Lekcija 23: Koliko to košta?',
         objectives = '["Запитати ціну й зрозуміти відповідь у євро і центах", "Платити купюрою чи монетами, отримати решту", "Сказати «дорого», «дешево», «безкоштовно»"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'koliko to košta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koštati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cijena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'euro', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cent', v_pos);
  v_pos := pg_temp.word(v_lesson, 'novčanica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kovanica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sitniš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skupo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jeftino', v_pos);
  v_pos := pg_temp.word(v_lesson, 'besplatno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'platiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vratiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ostatak', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dc1da393-fae5-54af-b5f3-32c26e4d9212', 'fill_in_the_blank', 'Ova kava košta tri ___.', 'eura', '["eure", "euro", "eurima", "eura"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '42d8759d-a702-5d6e-9bd4-7aa4dcae6355', 'multiple_choice', 'Що означає «koliko to košta»?', 'скільки це коштує', '["дрібні гроші", "скільки це коштує", "євро", "заплатити"]'::jsonb, 'A0', 2, 'PUBLISHED', 'koliko to košta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a8a8d06e-7729-5c9f-8ab5-435f98cf2757', 'multiple_choice', 'Що означає «novčanica»?', 'банкнота', '["коштувати", "дрібні гроші", "банкнота", "цент"]'::jsonb, 'A0', 3, 'PUBLISHED', 'novčanica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa4ecda5-4880-565f-930e-b9092583cd5e', 'multiple_choice', 'Що означає «sitniš»?', 'дрібні гроші', '["дрібні гроші", "дешево", "коштувати", "заплатити"]'::jsonb, 'A0', 4, 'PUBLISHED', 'sitniš', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '91fabaee-f94d-5e8d-8e74-d9c7846276a2', 'multiple_choice', 'Як хорватською «ціна»?', 'cijena', '["ostatak", "skupo", "cijena", "vratiti"]'::jsonb, 'A0', 5, 'PUBLISHED', 'cijena', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '941f980b-50b8-578b-8e2f-657384a14aaf', 'multiple_choice', 'Як хорватською «цент»?', 'cent', '["sitniš", "koštati", "vratiti", "cent"]'::jsonb, 'A0', 6, 'PUBLISHED', 'cent', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd892686b-ac63-5ef9-957a-e6561753021e', 'type_answer', 'Напишіть хорватською: «дешево»', 'jeftino', null, 'A0', 7, 'PUBLISHED', 'jeftino', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b2e599b7-d3e3-5a8a-812c-7fd1ae911777', 'type_answer', 'Напишіть хорватською: «євро»', 'euro', null, 'A0', 8, 'PUBLISHED', 'euro', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4b673262-bbce-5302-86cf-10b03adfca33', 'type_answer', 'Напишіть хорватською: «безкоштовно»', 'besplatno', null, 'A0', 9, 'PUBLISHED', 'besplatno', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c5e7554-55fc-5e4f-9ce9-27ad51a0b6ca', 'sentence_builder', 'Складіть: «Скільки це коштує?»', 'Koliko to košta?', '["košta?", "to", "Koliko"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '55bdf393-31f9-5eea-b139-7e13a5de5ddc', 'sentence_builder', 'Складіть: «Вибачте, у мене немає дрібних.»', 'Oprostite, nemam sitniša.', '["sitniša.", "nemam", "Oprostite,"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '777f8223-85e1-58e3-8727-005e9d2cff26', 'listening', 'Прослухайте і складіть фразу', 'Nemam sitniša. Imate li kovanice?', '["kovanice?", "sitniša.", "Nemam", "Imate", "li"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'edbfb090-7c0c-5daf-8119-013344b16fa6', 'listening', 'Прослухайте і складіть фразу', 'Evo četiri eura ostatka. Hvala!', '["Evo", "Hvala!", "ostatka.", "četiri", "eura"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '81e7f2bd-e2cb-5eb9-8fc5-81e265a7a38f', 'speaking', 'Це дуже дорого.', 'To je jako skupo.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ddaab4fc-10dd-5fff-a699-0ae2078be649', 'speaking', 'Сьогодні плачу я.', 'Danas ja plaćam.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1247f1c7-9aa1-51cf-b143-8077a1b6ef68', v_lesson, 'У кіоску', 'Na kiosku', 2231, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('ea0c8068-3dc8-5fe1-9bbe-ba82ce9e9950', '1247f1c7-9aa1-51cf-b143-8077a1b6ef68', 'Daša', 'Dobar dan. Koliko to košta?', 'Добрий день. Скільки це коштує?', 1);
  perform pg_temp.turn('6ccbae8e-aeb1-5186-ae08-f48b6189bfd1', '1247f1c7-9aa1-51cf-b143-8077a1b6ef68', 'Prodavač', 'Dva eura i pedeset centi.', 'Два євро п’ятдесят центів.', 2);
  perform pg_temp.turn('542f1d2a-6f08-531a-a44f-51b6d571af81', '1247f1c7-9aa1-51cf-b143-8077a1b6ef68', 'Daša', 'Imam samo novčanicu od pedeset eura.', 'У мене лише купюра в п’ятдесят євро.', 3);
  perform pg_temp.turn('00ffa6cc-b183-5c54-abd3-fd25468d236c', '1247f1c7-9aa1-51cf-b143-8077a1b6ef68', 'Prodavač', 'Nemam sitniša. Imate li kovanice?', 'У мене немає дрібних. У вас є монети?', 4);
  perform pg_temp.turn('059e10c1-1cc6-55c5-a4b2-7e04951dfd24', '1247f1c7-9aa1-51cf-b143-8077a1b6ef68', 'Daša', 'Evo, točno dva eura i pedeset centi.', 'Ось, рівно два євро п’ятдесят центів.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ff1933d2-a7ca-58ff-84e1-1027c5831834', v_lesson, 'Дорого чи дешево?', 'Skupo ili jeftino?', 2232, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('657b3b9b-db7c-5295-8e42-4313150ad80c', 'ff1933d2-a7ca-58ff-84e1-1027c5831834', 'Marko', 'Kava ovdje košta tri eura. Skupo je!', 'Кава тут коштує три євро. Дорого!', 1);
  perform pg_temp.turn('f54f055a-eece-5989-a54d-01c2162c7e26', 'ff1933d2-a7ca-58ff-84e1-1027c5831834', 'Daša', 'Da, u mom kvartu je jeftinije. Danas ja plaćam.', 'Так, у моєму районі дешевше. Сьогодні плачу я.', 2);
  perform pg_temp.turn('547ffe92-8c35-5bda-b4cb-64c2cf36c9b2', 'ff1933d2-a7ca-58ff-84e1-1027c5831834', 'Konobar', 'Dvije kave, šest eura, molim.', 'Дві кави, шість євро, будь ласка.', 3);
  perform pg_temp.turn('46bf6489-426a-5bc5-8830-97020e65f77a', 'ff1933d2-a7ca-58ff-84e1-1027c5831834', 'Daša', 'Izvolite deset eura.', 'Прошу, десять євро.', 4);
  perform pg_temp.turn('b6a34c56-74c4-523b-8e12-d4244eb028fb', 'ff1933d2-a7ca-58ff-84e1-1027c5831834', 'Konobar', 'Evo četiri eura ostatka. Hvala!', 'Ось чотири євро решти. Дякую!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- 3. Новий порядок уроків у модулі A0.3: наявні уроки тимчасово переносяться на місця 100+
--    (unique (unit_id, order_index)), щоб звільнити місця для нових; у кроці 5 — на остаточні місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 3 and u.order_index = 1;
  update public.lessons l set order_index = t.o + 100
    from (values
    ('c0941bd8-57b5-5e7e-981f-9be423f24208'::uuid, 1),
    ('e30c65f2-1a30-5b51-85e7-6a460cd1799f'::uuid, 2),
    ('ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'::uuid, 3),
    ('4c5db9c0-aa58-55c5-b647-7f7cfc8396c2'::uuid, 9),
    ('427e5058-7381-58a0-8f21-bd170866dbae'::uuid, 10)
    ) as t(id, o)
   where l.id = t.id and l.unit_id = v_unit and l.order_index <> t.o and l.order_index < 100;
end $$;

-- 4. Нові тематичні уроки модуля A0.3
-- A0.3 · урок 17: Сотні: від 100 до 1000 — новий урок: 16 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'c0d7b467-acb2-581a-975b-497e63f45aa7';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A0.3: місце 4 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Великі числа: сотні, тисячі, мільйони' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Великі числа: сотні, тисячі, мільйони»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 17: Сотні: від 100 до 1000', 'Lekcija 17: Stotine: od sto do tisuću', '["Рахувати сотнями до 1000", "Назвати суму, відстань і вагу: petsto eura, četiristo kilometara", "Розрізняти на слух sedamsto і sedamdeset"]'::jsonb, 15, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'stotina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dvjesto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tristo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'četiristo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'petsto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šesto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sedamsto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osamsto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'devetsto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tisuća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kilometar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'metar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gram', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stranica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iznos', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udaljenost', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fac5d263-e052-571a-9968-1ab1e8e4c8fc', 'fill_in_the_blank', 'Dvjesto i tristo je ___.', 'petsto', '["pet", "pedeset", "petnaest", "petsto"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7e082347-55b7-5363-8a31-c1f160ad1cda', 'multiple_choice', 'Що означає «stotina»?', 'сотня', '["відстань", "сотня", "грам", "сума (грошей)"]'::jsonb, 'A0', 2, 'PUBLISHED', 'stotina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '78cad230-528d-5f38-8e37-9582027fd4ff', 'multiple_choice', 'Що означає «osamsto»?', 'вісімсот', '["тисяча", "сума (грошей)", "вісімсот", "шістсот"]'::jsonb, 'A0', 3, 'PUBLISHED', 'osamsto', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '71369804-8ca8-5066-89e2-00665c6dc76d', 'multiple_choice', 'Що означає «devetsto»?', 'дев’ятсот', '["дев’ятсот", "метр", "кілометр", "відстань"]'::jsonb, 'A0', 4, 'PUBLISHED', 'devetsto', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd3bed7d-f694-5f76-8f08-8bb66c4abdb8', 'multiple_choice', 'Як хорватською «кілометр»?', 'kilometar', '["tisuća", "kilometar", "tristo", "dvjesto"]'::jsonb, 'A0', 5, 'PUBLISHED', 'kilometar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7a88114a-afe3-50cc-ac79-92152beb0c95', 'multiple_choice', 'Як хорватською «тисяча»?', 'tisuća', '["tisuća", "kilometar", "osamsto", "petsto"]'::jsonb, 'A0', 6, 'PUBLISHED', 'tisuća', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '93504ec8-162a-5fe5-a254-be2b7289154a', 'type_answer', 'Напишіть хорватською: «метр»', 'metar', null, 'A0', 7, 'PUBLISHED', 'metar', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '24b177aa-88c0-5ae8-b986-783c3d730c19', 'type_answer', 'Напишіть хорватською: «чотириста»', 'četiristo', null, 'A0', 8, 'PUBLISHED', 'četiristo', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f049ce7f-d020-5723-8df3-671ae40942b0', 'type_answer', 'Напишіть хорватською: «триста»', 'tristo', null, 'A0', 9, 'PUBLISHED', 'tristo', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3b6c4820-cc1d-51e9-931f-2023d01a5f82', 'sentence_builder', 'Складіть: «Сімсот євро, будь ласка.»', 'Sedamsto eura, molim.', '["Sedamsto", "molim.", "eura,"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1e6b281a-e357-50e7-8c73-7590877be82f', 'sentence_builder', 'Складіть: «Приблизно чотириста кілометрів.»', 'Otprilike četiristo kilometara.', '["kilometara.", "četiristo", "Otprilike"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '07ca7a08-7344-540d-b7c2-b3bc2e19e79f', 'listening', 'Прослухайте і складіть фразу', 'Šesto, možda malo više.', '["više.", "malo", "možda", "Šesto,"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f6d37ce7-0c67-5992-96ba-43c5d6ee687e', 'listening', 'Прослухайте і складіть фразу', 'Sedamsto ili sedamdeset?', '["sedamdeset?", "ili", "Sedamsto"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8a506fb-65c6-58fc-baa2-c2ed4f9bc90c', 'speaking', 'Дев’ятсот.', 'Devetsto.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c86ab028-349a-5dc0-a571-3c8da88785d8', 'speaking', 'Тисяча євро.', 'Tisuću eura.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c25ba230-44c3-5132-9893-da1e3a22023e', v_lesson, 'Скільки кілометрів?', 'Koliko kilometara?', 2171, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('5b19e447-bdf9-5f56-9ab3-6b1d73276183', 'c25ba230-44c3-5132-9893-da1e3a22023e', 'Daša', 'Koliko je kilometara od Zagreba do Splita?', 'Скільки кілометрів від Загреба до Спліта?', 1);
  perform pg_temp.turn('9a97a8c8-d8a9-579e-bb19-2bfab62a66a1', 'c25ba230-44c3-5132-9893-da1e3a22023e', 'Luka', 'Otprilike četiristo.', 'Приблизно чотириста.', 2);
  perform pg_temp.turn('707d90b5-b804-5e4d-ae13-eeb47e316b5c', 'c25ba230-44c3-5132-9893-da1e3a22023e', 'Daša', 'A do Dubrovnika?', 'А до Дубровника?', 3);
  perform pg_temp.turn('e21a640f-1e09-5926-9563-360c43598923', 'c25ba230-44c3-5132-9893-da1e3a22023e', 'Luka', 'Šesto, možda malo više.', 'Шістсот, може, трохи більше.', 4);
  perform pg_temp.turn('c9beb77c-4781-5d0e-84c6-be9840dc443b', 'c25ba230-44c3-5132-9893-da1e3a22023e', 'Daša', 'To je velika udaljenost!', 'Це велика відстань!', 5);
  perform pg_temp.turn('15c5e959-3ebb-5809-979b-1b157a631747', 'c25ba230-44c3-5132-9893-da1e3a22023e', 'Luka', 'Je, ali cesta je jako lijepa.', 'Так, але дорога дуже гарна.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('caeb2a71-455f-5d92-ac6e-72686dc8522f', v_lesson, 'Яка сума?', 'Koji iznos?', 2172, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('f81796cf-db7f-5d08-8f60-a35b1e762671', 'caeb2a71-455f-5d92-ac6e-72686dc8522f', 'Službenica', 'Koji iznos želite podići?', 'Яку суму ви хочете зняти?', 1);
  perform pg_temp.turn('c512bb98-8606-5192-889f-7fd168a25f6f', 'caeb2a71-455f-5d92-ac6e-72686dc8522f', 'Darja', 'Sedamsto eura, molim.', 'Сімсот євро, будь ласка.', 2);
  perform pg_temp.turn('886da88f-f28a-59e6-a6d5-87d4a052b0fe', 'caeb2a71-455f-5d92-ac6e-72686dc8522f', 'Službenica', 'Sedamsto ili sedamdeset?', 'Сімсот чи сімдесят?', 3);
  perform pg_temp.turn('ba385be7-9bb8-502b-8474-4f2b22284453', 'caeb2a71-455f-5d92-ac6e-72686dc8522f', 'Darja', 'Sedamsto. Za najam stana.', 'Сімсот. За оренду квартири.', 4);
  perform pg_temp.turn('693f2aac-0e25-5705-b0ff-ef118f5220df', 'caeb2a71-455f-5d92-ac6e-72686dc8522f', 'Službenica', 'Izvolite: sedam novčanica od sto eura.', 'Прошу: сім купюр по сто євро.', 5);
  perform pg_temp.turn('baf7bd4d-b8a5-5e33-827c-0a080dfc02ec', 'caeb2a71-455f-5d92-ac6e-72686dc8522f', 'Darja', 'Hvala, točno je.', 'Дякую, усе правильно.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.3 · урок 18: Тисячі, мільйони, мільярди — новий урок: 12 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '1f41cb75-1ce5-57ba-a56f-58561ee1d983';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A0.3: місце 5 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Великі числа: сотні, тисячі, мільйони' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Великі числа: сотні, тисячі, мільйони»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 18: Тисячі, мільйони, мільярди', 'Lekcija 18: Tisuće, milijuni, milijarde', '["Назвати тисячі: dvije tisuće, pet tisuća", "Сказати «мільйон» і «мільярд» з іменником", "Говорити про населення, зарплату й ціни квартир"]'::jsonb, 15, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'milijun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'milijarda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stanovnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stanovništvo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gotovo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plaća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjesečno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godišnje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'novac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kredit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'štedjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bogat', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f622d94c-5e6d-565d-b3ef-0a26134b0387', 'fill_in_the_blank', 'Hrvatska ima gotovo četiri ___ stanovnika.', 'milijuna', '["milijuna", "milijun", "milijunom", "milijuni"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ec2c119-ea22-5ef8-8b68-ce42ab3022b8', 'multiple_choice', 'Що означає «plaća»?', 'заробітна плата', '["населення", "мільйон", "заробітна плата", "багатий"]'::jsonb, 'A0', 2, 'PUBLISHED', 'plaća', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1e510134-d900-5be1-89a8-8e64ef8e9818', 'multiple_choice', 'Що означає «stanovnik»?', 'мешканець', '["щомісяця; на місяць", "багатий", "заощаджувати", "мешканець"]'::jsonb, 'A0', 3, 'PUBLISHED', 'stanovnik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4c5c81ec-4458-5651-b3ec-3a4cc428d948', 'multiple_choice', 'Що означає «bogat»?', 'багатий', '["заощаджувати", "гроші", "багатий", "населення"]'::jsonb, 'A0', 4, 'PUBLISHED', 'bogat', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0a64a63d-533f-5650-865f-bc63cb2a16b5', 'multiple_choice', 'Як хорватською «мільйон»?', 'milijun', '["godišnje", "štedjeti", "bogat", "milijun"]'::jsonb, 'A0', 5, 'PUBLISHED', 'milijun', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '20a77381-92d1-5e14-9b71-c792e76d9e30', 'multiple_choice', 'Як хорватською «населення»?', 'stanovništvo', '["stanovnik", "kredit", "gotovo", "stanovništvo"]'::jsonb, 'A0', 6, 'PUBLISHED', 'stanovništvo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b63b9639-b814-5e9a-a327-15bccb0c0d73', 'type_answer', 'Напишіть хорватською: «мільярд»', 'milijarda', null, 'A0', 7, 'PUBLISHED', 'milijarda', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f6d2b9e9-ec62-5069-801e-d4acf9d5637a', 'type_answer', 'Напишіть хорватською: «кредит»', 'kredit', null, 'A0', 8, 'PUBLISHED', 'kredit', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '54d10af1-bfba-524d-b64d-bd5cfac34604', 'type_answer', 'Напишіть хорватською: «майже; практично»', 'gotovo', null, 'A0', 9, 'PUBLISHED', 'gotovo', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3635ad9e-01e6-5e51-86fb-5469aefc98e6', 'sentence_builder', 'Складіть: «Тисяча двісті євро на місяць.»', 'Tisuću dvjesto eura mjesečno.', '["mjesečno.", "dvjesto", "eura", "Tisuću"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd029b6df-9f67-5010-801c-5f1d0e2f7189', 'sentence_builder', 'Складіть: «Тут живе мільйон людей.»', 'Ovdje živi milijun ljudi.', '["milijun", "živi", "Ovdje", "ljudi."]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '15665cc8-0fb3-57e4-9527-523553357402', 'listening', 'Прослухайте і складіть фразу', 'Malo manje od četiri milijuna.', '["od", "četiri", "manje", "Malo", "milijuna."]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '35d0eebf-c2f5-5d53-b416-f207061d3239', 'listening', 'Прослухайте і складіть фразу', 'Zato ljudi uzimaju kredit.', '["uzimaju", "kredit.", "ljudi", "Zato"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cdc443e8-bfd6-525d-b001-66de2cbec149', 'speaking', 'Дві тисячі.', 'Dvije tisuće.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ed95648f-c6c9-5f9d-a176-034a1e9f481e', 'speaking', 'Мільярд євро.', 'Milijarda eura.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('11970410-78dc-594e-9e9b-8a0e57a9568d', v_lesson, 'Скільки жителів?', 'Koliko stanovnika?', 2181, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('1806d3b6-66ae-5bc1-b0b7-46390be8b515', '11970410-78dc-594e-9e9b-8a0e57a9568d', 'Daša', 'Koliko stanovnika ima Hrvatska?', 'Скільки жителів у Хорватії?', 1);
  perform pg_temp.turn('59df2500-9072-5501-821b-971f49b8d9a5', '11970410-78dc-594e-9e9b-8a0e57a9568d', 'Ivana', 'Malo manje od četiri milijuna.', 'Трохи менше ніж чотири мільйони.', 2);
  perform pg_temp.turn('00e47d8d-a0d4-51dc-8d43-02f0d7f12846', '11970410-78dc-594e-9e9b-8a0e57a9568d', 'Daša', 'A Zagreb?', 'А в Загребі?', 3);
  perform pg_temp.turn('b2fbafad-b3eb-53cf-85db-08f2126d404a', '11970410-78dc-594e-9e9b-8a0e57a9568d', 'Ivana', 'Gotovo osamsto tisuća.', 'Майже вісімсот тисяч.', 4);
  perform pg_temp.turn('bfc8c744-8dbb-53ac-89c8-622f0a97086c', '11970410-78dc-594e-9e9b-8a0e57a9568d', 'Daša', 'Kijev ima gotovo tri milijuna stanovnika.', 'У Києві майже три мільйони жителів.', 5);
  perform pg_temp.turn('3fcd1ff2-fe64-5752-b3db-eb0b6c3c92c0', '11970410-78dc-594e-9e9b-8a0e57a9568d', 'Ivana', 'To je gotovo kao cijela Hrvatska!', 'Це майже як уся Хорватія!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e21dcaf6-55a7-5ccc-90d2-435e018b6879', v_lesson, 'Ціни на квартири', 'Cijene stanova', 2182, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('368f5514-65c6-5cc2-ba09-ae17bf0aaa16', 'e21dcaf6-55a7-5ccc-90d2-435e018b6879', 'Marko', 'Koliko košta stan u centru Zagreba?', 'Скільки коштує квартира в центрі Загреба?', 1);
  perform pg_temp.turn('121b8dcb-235d-5fd9-a672-97da58946b53', 'e21dcaf6-55a7-5ccc-90d2-435e018b6879', 'Darja', 'Ovaj ima pedeset kvadrata i košta dvjesto pedeset tisuća eura.', 'Ця має п’ятдесят квадратних метрів і коштує двісті п’ятдесят тисяч євро.', 2);
  perform pg_temp.turn('e5ab5394-9b5b-53a3-a541-372d3fc87499', 'e21dcaf6-55a7-5ccc-90d2-435e018b6879', 'Marko', 'Dvjesto pedeset tisuća! S mojom plaćom moram štedjeti dvadeset godina.', 'Двісті п’ятдесят тисяч! З моєю зарплатою мені треба заощаджувати двадцять років.', 3);
  perform pg_temp.turn('222136ae-6292-5a57-9a79-75e586bbd7a2', 'e21dcaf6-55a7-5ccc-90d2-435e018b6879', 'Darja', 'Zato ljudi uzimaju kredit.', 'Тому люди беруть кредит.', 4);
  perform pg_temp.turn('e56f7af8-e5e4-54fd-a38b-241e45890742', 'e21dcaf6-55a7-5ccc-90d2-435e018b6879', 'Marko', 'Da, kredit na trideset godina.', 'Так, кредит на тридцять років.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.3 · урок 19: Перший, другий, третій — новий урок: 18 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '40f7c64a-ad42-5fe2-a230-7b1e98607112';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A0.3: місце 6 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Порядкові числівники' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Порядкові числівники»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 19: Перший, другий, третій', 'Lekcija 19: Prvi, drugi, treći', '["Казати порядкові числа: prvi … deseti, dvadeseti, stoti", "Узгоджувати їх: prvi kat, treća vrata", "Запитати, хто останній у черзі"]'::jsonb, 15, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'prvi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'drugi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'treći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'četvrti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'peti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šesti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sedmi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osmi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'deveti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'deseti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dvadeseti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stoti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zadnji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'redni broj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'red', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na redu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prvo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'onda', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b0ae5aba-130f-5abb-a566-32b02b67687a', 'fill_in_the_blank', 'Živim na ___ katu.', 'trećem', '["treća", "treći", "trećem", "tri"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e9b3e6a-45a9-5aa6-af6c-b9a80cd1c028', 'multiple_choice', 'Що означає «deveti»?', 'дев''ятий', '["двадцятий", "четвертий", "дев''ятий", "сотий"]'::jsonb, 'A0', 2, 'PUBLISHED', 'deveti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '43cf7380-2da7-5e75-8039-1f7f48f01c06', 'multiple_choice', 'Що означає «prvo»?', 'спочатку; по-перше', '["десятий", "останній", "перший", "спочатку; по-перше"]'::jsonb, 'A0', 3, 'PUBLISHED', 'prvo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3c1bba67-0e06-546b-9823-1c9e358cf876', 'multiple_choice', 'Що означає «šesti»?', 'шостий', '["шостий", "п''ятий", "десятий", "третій"]'::jsonb, 'A0', 4, 'PUBLISHED', 'šesti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd17a39ca-ab31-5a03-a7e9-fc2581654df2', 'multiple_choice', 'Як хорватською «сотий»?', 'stoti', '["stoti", "onda", "redni broj", "peti"]'::jsonb, 'A0', 5, 'PUBLISHED', 'stoti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0230c869-1c04-5b49-84f5-5db5bcc8a74f', 'multiple_choice', 'Як хорватською «третій»?', 'treći', '["prvo", "na redu", "treći", "dvadeseti"]'::jsonb, 'A0', 6, 'PUBLISHED', 'treći', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '359ea710-0e9f-56d7-baeb-cab31ef57cb9', 'type_answer', 'Напишіть хорватською: «останній»', 'zadnji', null, 'A0', 7, 'PUBLISHED', 'zadnji', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e83cb52-ef5c-523c-85c7-44e0c6ad6fd7', 'type_answer', 'Напишіть хорватською: «десятий»', 'deseti', null, 'A0', 8, 'PUBLISHED', 'deseti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bfcf36b0-b266-58ce-b99d-8bbbcb63de64', 'type_answer', 'Напишіть хорватською: «восьмий»', 'osmi', null, 'A0', 9, 'PUBLISHED', 'osmi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd363c3c7-e3d3-5218-94ef-3aa538db9769', 'sentence_builder', 'Складіть: «Хто останній у черзі?»', 'Tko je zadnji u redu?', '["zadnji", "je", "redu?", "u", "Tko"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd8800168-d32e-5ad5-b67a-d4537432e0af', 'sentence_builder', 'Складіть: «Я тут уперше.»', 'Ovo mi je prvi put ovdje.', '["ovdje.", "Ovo", "mi", "put", "prvi", "je"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3449e171-aea2-5931-8d04-2a5090f4211b', 'listening', 'Прослухайте і складіть фразу', 'Ja sam zadnji. Vi ste iza mene.', '["ste", "Vi", "sam", "mene.", "iza", "Ja", "zadnji."]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5067387f-c68e-59ff-a7a1-13afb9bc4257', 'listening', 'Прослухайте і складіть фразу', 'Na drugom katu, treća vrata lijevo.', '["lijevo.", "drugom", "Na", "treća", "katu,", "vrata"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aecb637c-2104-54dc-8cad-f4492e71a15d', 'speaking', 'Перший поверх.', 'Prvi kat.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e385b3bc-e440-578e-8452-f1c376499106', 'speaking', 'Я десятий у черзі.', 'Ja sam deseti u redu.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('962fcf3b-c3c2-5553-883d-e5e9e0325521', v_lesson, 'У черзі', 'U redu', 2191, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('4402e74f-9753-5424-bfa2-f2b066ce6176', '962fcf3b-c3c2-5553-883d-e5e9e0325521', 'Daša', 'Oprostite, tko je zadnji u redu?', 'Вибачте, хто останній у черзі?', 1);
  perform pg_temp.turn('0cc3a004-9b1f-5e2c-95ce-95ebddfa1f44', '962fcf3b-c3c2-5553-883d-e5e9e0325521', 'Gospodin Marić', 'Ja sam zadnji. Vi ste iza mene.', 'Я останній. Ви за мною.', 2);
  perform pg_temp.turn('1d0f3e59-1db8-5c47-9be8-bf13a298565d', '962fcf3b-c3c2-5553-883d-e5e9e0325521', 'Daša', 'Hvala. Koji je broj sada na redu?', 'Дякую. Який номер зараз на черзі?', 3);
  perform pg_temp.turn('d64ba390-9e15-5fc1-8338-7cbfb3cc40ee', '962fcf3b-c3c2-5553-883d-e5e9e0325521', 'Gospodin Marić', 'Broj dvadeset jedan, a ja imam trideset šest.', 'Номер двадцять один, а в мене тридцять шість.', 4);
  perform pg_temp.turn('03bcdf92-2f12-59a1-898a-b4bdb429539c', '962fcf3b-c3c2-5553-883d-e5e9e0325521', 'Daša', 'Znači, Vi ste šesnaesti, a ja sedamnaesta.', 'Отже, ви шістнадцятий, а я сімнадцята.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ded4458f-16e3-54cc-a9ab-f6e1e8824ece', v_lesson, 'На якому поверсі?', 'Na kojem katu?', 2192, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('e6988bff-440f-5d6d-a4e6-a29ba6691864', 'ded4458f-16e3-54cc-a9ab-f6e1e8824ece', 'Darja', 'Oprostite, gdje je ured broj dvjesto tri?', 'Вибачте, де кабінет номер двісті три?', 1);
  perform pg_temp.turn('9e7386b9-15a0-5f96-9cea-9e32c7b61d01', 'ded4458f-16e3-54cc-a9ab-f6e1e8824ece', 'Recepcionarka', 'Na drugom katu, treća vrata lijevo.', 'На другому поверсі, треті двері ліворуч.', 2);
  perform pg_temp.turn('4fbf2285-0e12-56d8-9ba7-e34041bd273d', 'ded4458f-16e3-54cc-a9ab-f6e1e8824ece', 'Darja', 'A gdje je lift?', 'А де ліфт?', 3);
  perform pg_temp.turn('f24224d0-5aa6-5e6e-bcae-389ae9ed1f3b', 'ded4458f-16e3-54cc-a9ab-f6e1e8824ece', 'Recepcionarka', 'Prvo ravno, onda prvi hodnik desno.', 'Спочатку прямо, потім перший коридор праворуч.', 4);
  perform pg_temp.turn('fee01ac4-a848-5251-9f35-1f53bc2ff48b', 'ded4458f-16e3-54cc-a9ab-f6e1e8824ece', 'Darja', 'Hvala! Ovo mi je prvi put ovdje.', 'Дякую! Я тут уперше.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.3 · урок 20: Рахуємо: плюс, мінус, помножити — новий урок: 18 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'ba35964d-f0d8-5d15-9566-ef44d37e6d12';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A0.3: місце 7 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Великі числа: сотні, тисячі, мільйони' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Великі числа: сотні, тисячі, мільйони»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 20: Рахуємо: плюс, мінус, помножити', 'Lekcija 20: Računamo: plus, minus, puta', '["Рахувати вголос: plus, minus, puta, podijeljeno s", "Перевіряти результат: točno, netočno", "Поділити рахунок у кафе на кількох"]'::jsonb, 15, 'PUBLISHED', 7);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'plus', v_pos);
  v_pos := pg_temp.word(v_lesson, 'minus', v_pos);
  v_pos := pg_temp.word(v_lesson, 'puta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podijeljeno s', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jednako', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koliko je', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zbrojiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oduzeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pomnožiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'računati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rezultat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zadatak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'točno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'netočno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'paran broj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neparan broj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kalkulator', v_pos);
  v_pos := pg_temp.word(v_lesson, 'matematika', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '9ad17482-d164-5c56-9c0f-47a47c4d2ef3', 'fill_in_the_blank', 'Tri ___ četiri je dvanaest.', 'puta', '["manje", "puta", "minus", "plus"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5a192e64-d755-5b28-a67a-6022b082f777', 'multiple_choice', 'Що означає «kalkulator»?', 'калькулятор', '["плюс", "завдання", "калькулятор", "математика"]'::jsonb, 'A0', 2, 'PUBLISHED', 'kalkulator', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1074c3ae-6b96-5e4b-b98a-3f916481de59', 'multiple_choice', 'Що означає «paran broj»?', 'парне число', '["калькулятор", "парне число", "помножити", "точно, правильно"]'::jsonb, 'A0', 3, 'PUBLISHED', 'paran broj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a9e7dd9-e61d-55b2-bfd0-ac60db784acc', 'multiple_choice', 'Що означає «plus»?', 'плюс', '["плюс", "неправильно", "помножити на; разів", "калькулятор"]'::jsonb, 'A0', 4, 'PUBLISHED', 'plus', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '96334856-2b6b-5267-9ab8-565244b78c82', 'multiple_choice', 'Як хорватською «обчислювати»?', 'računati', '["računati", "zadatak", "puta", "zbrojiti"]'::jsonb, 'A0', 5, 'PUBLISHED', 'računati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '907a4f67-9942-5296-be53-a82a0aa0312d', 'multiple_choice', 'Як хорватською «результат»?', 'rezultat', '["rezultat", "oduzeti", "zbrojiti", "netočno"]'::jsonb, 'A0', 6, 'PUBLISHED', 'rezultat', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '59d3e7bc-5613-5617-970a-11237b74cef5', 'type_answer', 'Напишіть хорватською: «математика»', 'matematika', null, 'A0', 7, 'PUBLISHED', 'matematika', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9bcb8a01-9910-5e28-a0c9-e7ec775ba0b3', 'type_answer', 'Напишіть хорватською: «додати (числа)»', 'zbrojiti', null, 'A0', 8, 'PUBLISHED', 'zbrojiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '013c8ec1-3a5a-52f6-8ef8-3fdeae32b55d', 'type_answer', 'Напишіть хорватською: «завдання»', 'zadatak', null, 'A0', 9, 'PUBLISHED', 'zadatak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '08e73e62-83f7-52ff-98de-4025ba625487', 'sentence_builder', 'Складіть: «П’ять плюс три — вісім.»', 'Pet plus tri je osam.', '["tri", "osam.", "Pet", "plus", "je"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8e6acb31-98f6-52b3-896c-6714e191a8d1', 'sentence_builder', 'Складіть: «Скільки буде сім помножити на вісім?»', 'Koliko je sedam puta osam?', '["Koliko", "puta", "sedam", "je", "osam?"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5dba11b5-93c9-523d-9893-3900d60d30da', 'listening', 'Прослухайте і складіть фразу', 'Dvadeset pet. Provjeri na kalkulatoru!', '["pet.", "Dvadeset", "kalkulatoru!", "na", "Provjeri"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ff706dd0-35ad-5f5b-bdbd-200e76d781bd', 'listening', 'Прослухайте і складіть фразу', 'Onda dvadeset dva po osobi.', '["dva", "dvadeset", "Onda", "po", "osobi."]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cd07d616-d757-5edb-8744-d838c711b3e6', 'speaking', 'Десять мінус три — сім.', 'Deset minus tri je sedam.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0b542c99-1666-55bd-bcfd-1067f1ff8494', 'speaking', 'Скільки це разом?', 'Koliko je to ukupno?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('bb42bcb5-dc5f-500c-aff8-70d59f42635b', v_lesson, 'Домашнє завдання', 'Domaća zadaća', 2201, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('786185d9-253f-5280-b3a0-d585a2a000b7', 'bb42bcb5-dc5f-500c-aff8-70d59f42635b', 'Mia', 'Dašo, koliko je sedam puta osam?', 'Дашо, скільки буде сім помножити на вісім?', 1);
  perform pg_temp.turn('26d0c29d-1915-56f1-8e12-36bfcb3d1365', 'bb42bcb5-dc5f-500c-aff8-70d59f42635b', 'Daša', 'Pedeset šest. Imaš zadatak iz matematike?', 'П’ятдесят шість. У тебе завдання з математики?', 2);
  perform pg_temp.turn('7eb361ec-0ba8-5dbd-ad37-842062a5f82f', 'bb42bcb5-dc5f-500c-aff8-70d59f42635b', 'Mia', 'Da. Sto minus pedeset šest je četrdeset četiri?', 'Так. Сто мінус п’ятдесят шість — сорок чотири?', 3);
  perform pg_temp.turn('4f559bf1-00e4-583b-b3eb-81e931d35e00', 'bb42bcb5-dc5f-500c-aff8-70d59f42635b', 'Daša', 'Točno! Bravo.', 'Правильно! Молодець.', 4);
  perform pg_temp.turn('280c973c-0b23-51d3-a412-c7daabdc4769', 'bb42bcb5-dc5f-500c-aff8-70d59f42635b', 'Mia', 'A sto podijeljeno s četiri?', 'А сто поділити на чотири?', 5);
  perform pg_temp.turn('0cf12d86-04f3-56e4-8323-4b05c096032d', 'bb42bcb5-dc5f-500c-aff8-70d59f42635b', 'Daša', 'Dvadeset pet. Provjeri na kalkulatoru!', 'Двадцять п’ять. Перевір на калькуляторі!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('131d849b-7781-5535-b622-e22a9f514a35', v_lesson, 'Рахунок на трьох', 'Račun za troje', 2202, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('7efb6dc2-33d1-5ec0-8d1e-2f327ae558f4', '131d849b-7781-5535-b622-e22a9f514a35', 'Luka', 'Račun je šezdeset eura. Nas je troje.', 'Рахунок — шістдесят євро. Нас троє.', 1);
  perform pg_temp.turn('d490ff17-9fa4-5321-a6a9-058b455e6a57', '131d849b-7781-5535-b622-e22a9f514a35', 'Daša', 'Šezdeset podijeljeno s tri je dvadeset.', 'Шістдесят поділити на три — двадцять.', 2);
  perform pg_temp.turn('7b3888ad-3f72-5308-87b5-451862955f46', '131d849b-7781-5535-b622-e22a9f514a35', 'Luka', 'Plus napojnica: šest eura.', 'Плюс чайові: шість євро.', 3);
  perform pg_temp.turn('752efd04-4f96-5ecf-b2af-5bf22a6ee6ae', '131d849b-7781-5535-b622-e22a9f514a35', 'Daša', 'Onda dvadeset dva po osobi.', 'Тоді двадцять два з кожного.', 4);
  perform pg_temp.turn('71ac1f9d-8d74-568e-abb0-54a972b89d5e', '131d849b-7781-5535-b622-e22a9f514a35', 'Luka', 'Točno. Ti si brža od kalkulatora!', 'Точно. Ти швидша за калькулятор!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.3 · урок 21: Приблизно, половина, відсотки — новий урок: 15 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '22dd7878-4fa8-5e1c-909e-71c70ffd9918';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 8) then
    raise exception 'A0.3: місце 8 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Великі числа: сотні, тисячі, мільйони' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Великі числа: сотні, тисячі, мільйони»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 21: Приблизно, половина, відсотки', 'Lekcija 21: Otprilike, pola, posto', '["Казати приблизно: desetak, dvadesetak, stotinjak", "Називати частини: pola, trećina, četvrtina", "Розуміти знижки й відсотки: trideset posto"]'::jsonb, 15, 'PUBLISHED', 8);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'otprilike', v_pos);
  v_pos := pg_temp.word(v_lesson, 'desetak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dvadesetak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stotinjak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nekoliko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'par', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trećina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'četvrtina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'manje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'barem', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najviše', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dovoljno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cijeli', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c51a9131-b65b-5313-9801-c5ca3d73c826', 'fill_in_the_blank', 'Pedeset ___ je pola.', 'posto', '["pola", "para", "puta", "posto"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e97f1595-ae92-558a-be82-4bea8cb72d7e', 'multiple_choice', 'Що означає «dovoljno»?', 'достатньо', '["пара; кілька", "менше", "достатньо", "близько двадцяти"]'::jsonb, 'A0', 2, 'PUBLISHED', 'dovoljno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '39e26095-8a7a-5b23-ab6c-856c43a4764d', 'multiple_choice', 'Що означає «posto»?', 'відсоток; відсотків', '["третина", "близько двадцяти", "відсоток; відсотків", "цілий"]'::jsonb, 'A0', 3, 'PUBLISHED', 'posto', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd9b5e116-ab3d-5e74-b38a-0d39e264089a', 'multiple_choice', 'Що означає «četvrtina»?', 'чверть; четверта частина', '["близько сотні", "чверть; четверта частина", "найбільше; щонайбільше", "достатньо"]'::jsonb, 'A0', 4, 'PUBLISHED', 'četvrtina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f98f0923-fa8b-5bde-846d-5850ffddcfae', 'multiple_choice', 'Як хорватською «принаймні»?', 'barem', '["četvrtina", "cijeli", "nekoliko", "barem"]'::jsonb, 'A0', 5, 'PUBLISHED', 'barem', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '097c8085-0a22-52a5-9812-16149b273f7b', 'multiple_choice', 'Як хорватською «третина»?', 'trećina', '["cijeli", "dovoljno", "otprilike", "trećina"]'::jsonb, 'A0', 6, 'PUBLISHED', 'trećina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '643874bd-a416-526b-bad9-1944c6361683', 'type_answer', 'Напишіть хорватською: «менше»', 'manje', null, 'A0', 7, 'PUBLISHED', 'manje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f56a6dde-36ce-5511-a10b-0f6dc53e98fd', 'type_answer', 'Напишіть хорватською: «половина»', 'pola', null, 'A0', 8, 'PUBLISHED', 'pola', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '158b5f0e-97e9-564f-bd7e-a4597480c3bf', 'type_answer', 'Напишіть хорватською: «цілий»', 'cijeli', null, 'A0', 9, 'PUBLISHED', 'cijeli', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5cd4974c-e9b5-5011-a993-39fc14ff096d', 'sentence_builder', 'Складіть: «Прийде близько двадцяти людей.»', 'Dolazi dvadesetak ljudi.', '["ljudi.", "dvadesetak", "Dolazi"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '21e167bf-9f70-5565-b28f-fa23c2e0c4ec', 'sentence_builder', 'Складіть: «Тридцять відсотків знижки.»', 'Trideset posto popusta.', '["popusta.", "Trideset", "posto"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '59510424-5172-51b9-a95a-24c1199da084', 'listening', 'Прослухайте і складіть фразу', 'Desetak, možda dvadesetak.', '["možda", "Desetak,", "dvadesetak."]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4eec6df4-7a8a-52a0-94fc-1361c7477f17', 'listening', 'Прослухайте і складіть фразу', 'Trideset posto na sve jakne.', '["na", "Trideset", "posto", "jakne.", "sve"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c2c05118-5b12-5cce-8cc2-e293b216f52f', 'speaking', 'Пів кілограма.', 'Pola kile.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7277ff3b-5ef8-54cd-9ffa-4d2dce4ab662', 'speaking', 'Принаймні п’ять.', 'Barem pet.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c45e5480-fd28-5f25-adb4-b5aa7c26584c', v_lesson, 'Скільки людей прийде?', 'Koliko ljudi dolazi?', 2211, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('96c1bc99-4c9b-5e40-87eb-3882f9d07965', 'c45e5480-fd28-5f25-adb4-b5aa7c26584c', 'Ana', 'Koliko ljudi dolazi na tvoj rođendan?', 'Скільки людей прийде на твій день народження?', 1);
  perform pg_temp.turn('f51aff03-5875-5508-bee4-dbc047c0c20a', 'c45e5480-fd28-5f25-adb4-b5aa7c26584c', 'Daša', 'Desetak, možda dvadesetak.', 'Близько десяти, може, близько двадцяти.', 2);
  perform pg_temp.turn('7cceb86c-76bf-58c5-8688-64cad8bf75df', 'c45e5480-fd28-5f25-adb4-b5aa7c26584c', 'Ana', 'Trebaš barem tri torte!', 'Тобі треба принаймні три торти!', 3);
  perform pg_temp.turn('d4bc9440-e1ef-54d7-b1af-c47514484678', 'c45e5480-fd28-5f25-adb4-b5aa7c26584c', 'Daša', 'Ne, dvije su dovoljne. Pola ljudi ne jede slatko.', 'Ні, двох досить. Половина людей не їсть солодкого.', 4);
  perform pg_temp.turn('47061ff9-65f7-55f1-8282-3e936090e041', 'c45e5480-fd28-5f25-adb4-b5aa7c26584c', 'Ana', 'Onda kupi jednu veliku tortu i par kolača.', 'Тоді купи один великий торт і кілька тістечок.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('058ac807-133a-5486-9fb2-5de4d98c0b70', v_lesson, 'Знижка', 'Popust', 2212, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('b9be749e-229a-5f90-b3b4-229c45c49a93', '058ac807-133a-5486-9fb2-5de4d98c0b70', 'Daša', 'Oprostite, koliki je popust?', 'Вибачте, яка знижка?', 1);
  perform pg_temp.turn('971673b6-6dce-503b-95a1-2f29cec84f9b', '058ac807-133a-5486-9fb2-5de4d98c0b70', 'Prodavačica', 'Trideset posto na sve jakne.', 'Тридцять відсотків на всі куртки.', 2);
  perform pg_temp.turn('968e29eb-9953-5299-8bd6-6915502c94e2', '058ac807-133a-5486-9fb2-5de4d98c0b70', 'Daša', 'Jakna košta sto eura. Znači, sada je sedamdeset?', 'Куртка коштує сто євро. Тобто зараз сімдесят?', 3);
  perform pg_temp.turn('b3741ddb-fb45-5505-96fe-ca90750eb7d3', '058ac807-133a-5486-9fb2-5de4d98c0b70', 'Prodavačica', 'Točno. A druga jakna je pola cijene.', 'Точно. А друга куртка — за пів ціни.', 4);
  perform pg_temp.turn('83c6eaaa-795a-5431-82cf-d41e3ac128df', '058ac807-133a-5486-9fb2-5de4d98c0b70', 'Daša', 'Super, uzimam dvije!', 'Супер, беру дві!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- 5. Наявні уроки модуля A0.3 — на нові місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 3 and u.order_index = 1;
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
   where l.id in ('c0941bd8-57b5-5e7e-981f-9be423f24208', 'e30c65f2-1a30-5b51-85e7-6a460cd1799f', 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a', 'c0d7b467-acb2-581a-975b-497e63f45aa7', '1f41cb75-1ce5-57ba-a56f-58561ee1d983', '40f7c64a-ad42-5fe2-a230-7b1e98607112', 'ba35964d-f0d8-5d15-9566-ef44d37e6d12', '22dd7878-4fa8-5e1c-909e-71c70ffd9918', '4c5db9c0-aa58-55c5-b647-7f7cfc8396c2', '427e5058-7381-58a0-8f21-bd170866dbae')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 12 and 20
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or not exists (select 1 from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar')
             and exists (select 1 from public.lesson_grammar lg where lg.lesson_id = l.id)
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_module from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 3;
  select count(*) into v_order from (values ('c0941bd8-57b5-5e7e-981f-9be423f24208'::uuid, 1), ('e30c65f2-1a30-5b51-85e7-6a460cd1799f'::uuid, 2), ('ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'::uuid, 3), ('c0d7b467-acb2-581a-975b-497e63f45aa7'::uuid, 4), ('1f41cb75-1ce5-57ba-a56f-58561ee1d983'::uuid, 5), ('40f7c64a-ad42-5fe2-a230-7b1e98607112'::uuid, 6), ('ba35964d-f0d8-5d15-9566-ef44d37e6d12'::uuid, 7), ('22dd7878-4fa8-5e1c-909e-71c70ffd9918'::uuid, 8), ('4c5db9c0-aa58-55c5-b647-7f7cfc8396c2'::uuid, 9), ('427e5058-7381-58a0-8f21-bd170866dbae'::uuid, 10)) as t(id, o) join public.lessons l on l.id = t.id and l.order_index = t.o;
  select count(*) into v_lessons from public.lessons where level_code = 'A0' and status = 'PUBLISHED';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A0' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('c0941bd8-57b5-5e7e-981f-9be423f24208', 'e30c65f2-1a30-5b51-85e7-6a460cd1799f', 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a', 'c0d7b467-acb2-581a-975b-497e63f45aa7', '1f41cb75-1ce5-57ba-a56f-58561ee1d983', '40f7c64a-ad42-5fe2-a230-7b1e98607112', 'ba35964d-f0d8-5d15-9566-ef44d37e6d12', '22dd7878-4fa8-5e1c-909e-71c70ffd9918', '4c5db9c0-aa58-55c5-b647-7f7cfc8396c2', '427e5058-7381-58a0-8f21-bd170866dbae') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A0.3: % уроків з неправильним складом', v_bad; end if;
  if v_module <> 10 or v_order <> 10 then raise exception 'Модуль A0.3: уроків %, на своїх місцях % (очікувалось 10)', v_module, v_order; end if;
  if v_lessons < 56 then raise exception 'A0: уроків %, очікувалось щонайменше 56', v_lessons; end if;  -- наступні модулі додають уроки
  if v_titles > 0 then raise exception 'A0: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A0.3: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A0.3 — 10 уроків (14–23) за темою; уроків A0 — %', v_lessons;
end $$;

commit;
