-- =====================================================================
-- Доповнення A1 · curriculum_a1_v2 · частина 3 з 4 · 2026-10-13
-- Згенеровано: python3 scripts/gen_curriculum_a1_v2.py (не редагуйте вручну).
-- Запуск: Supabase → SQL Editor → вставити ВЕСЬ файл → Run. Частини запускайте по черзі (1 → 4).
--
--   * 10 нових уроків (модулі A1.6–A1.8), у плані програми № 50–69:
--       A1.6 «Професії»
--       A1.6 «Шукаю роботу»
--       A1.6 «Перший робочий день»
--       A1.6 «В офісі»
--       A1.7 «Травма»
--       A1.7 «Аналізи й обстеження»
--       A1.7 «Здоровий спосіб життя»
--       A1.7 «У педіатра»
--       A1.8 «Кохання й стосунки»
--       A1.8 «Спорт і матчі»
--   * У кожному 14 нових слів, 2 діалоги (103 реплік разом), граматика, 12 вправ, ~12 хв.
--   * Нові слова у словнику: 67. Виправлення словника: 6 (стара версія — у content_versions).
--   * Назви всіх уроків A1 перенумеровано підряд («Урок N»); старі назви — у content_versions.
--   * Статус PUBLISHED: бета, як решта A1 (носій ще не перевіряв). Наявні дані не видаляються.
--   * Потрібна програма A1 v1 (20261013_curriculum_a1_v1_part1.sql і _part2.sql). Повторний запуск безпечний.
-- =====================================================================

begin;

do $$
begin
  if not exists (select 1 from public.lessons where id = 'fee5b77b-dc3b-5fd5-818a-c5496e95c23b' and status = 'PUBLISHED') then
    raise exception 'Спершу запустіть програму A1 v1 (20261013_curriculum_a1_v1_part1.sql і _part2.sql)';
  end if;
  if not exists (select 1 from pg_constraint where conname = 'exercises_type_check'
                 and pg_get_constraintdef(oid) like '%speaking%') then
    raise exception 'Спершу запустіть міграцію M13 (20261013140000_m13_exercise_types.sql)';
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

-- 1. Нові слова (67), яких ще немає у словнику
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('čistačica', 'cistacica', 'hr', 'noun', 'A1', 'прибиральниця', 'core', '{"gender": "f"}'::jsonb, '["Čistačica dolazi u ured navečer."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('električar', 'elektricar', 'hr', 'noun', 'A1', 'електрик', 'core', '{"gender": "m"}'::jsonb, '["Električar popravlja utičnicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vodoinstalater', 'vodoinstalater', 'hr', 'noun', 'A1', 'сантехнік', 'core', '{"gender": "m"}'::jsonb, '["Zovem vodoinstalatera, curi voda."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zidar', 'zidar', 'hr', 'noun', 'A1', 'муляр; будівельник', 'core', '{"gender": "m"}'::jsonb, '["Zidar radi na gradilištu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('njegovateljica', 'njegovateljica', 'hr', 'noun', 'A1', 'доглядальниця', 'core', '{"gender": "f"}'::jsonb, '["Njegovateljica brine o starijoj gospođi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('frizerka', 'frizerka', 'hr', 'noun', 'A1', 'перукарка', 'core', '{"gender": "f"}'::jsonb, '["Moja frizerka radi i subotom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('blagajnica', 'blagajnica', 'hr', 'noun', 'A1', 'касирка', 'core', '{"gender": "f"}'::jsonb, '["Blagajnica pita: karticom ili gotovinom?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('skladištar', 'skladistar', 'hr', 'noun', 'A1', 'комірник; працівник складу', 'core', '{"gender": "m"}'::jsonb, '["Skladištar slaže pakete na police."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('recepcioner', 'recepcioner', 'hr', 'noun', 'A1', 'адміністратор (на рецепції)', 'core', '{"gender": "m"}'::jsonb, '["Recepcioner govori engleski i njemački."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sobarica', 'sobarica', 'hr', 'noun', 'A1', 'покоївка', 'core', '{"gender": "f"}'::jsonb, '["Sobarica čisti sobe u hotelu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gradilište', 'gradiliste', 'hr', 'noun', 'A1', 'будівельний майданчик', 'core', '{"gender": "n"}'::jsonb, '["Na gradilištu se nosi kaciga."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('oglas', 'oglas', 'hr', 'noun', 'A1', 'оголошення', 'core', '{"gender": "m"}'::jsonb, '["Vidim oglas za posao u hotelu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('satnica', 'satnica', 'hr', 'noun', 'A1', 'погодинна оплата', 'core', '{"gender": "f"}'::jsonb, '["Satnica je osam eura."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sezonski', 'sezonski', 'hr', 'adjective', 'A1', 'сезонний', 'core', '{}'::jsonb, '["Ljeti ima puno sezonskih poslova."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stalan', 'stalan', 'hr', 'adjective', 'A1', 'постійний', 'core', '{}'::jsonb, '["Tražim stalan posao."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('plaćen', 'placen', 'hr', 'adjective', 'A1', 'оплачуваний; оплачений', 'core', '{}'::jsonb, '["Prekovremeni rad je dobro plaćen."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('radna odjeća', 'radna odjeca', 'hr', 'phrase', 'A1', 'робочий одяг', 'collocation', '{"gender": "f"}'::jsonb, '["Radnu odjeću dobivate prvi dan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('svlačionica', 'svlacionica', 'hr', 'noun', 'A1', 'роздягальня', 'core', '{"gender": "f"}'::jsonb, '["Svlačionica je pored ulaza."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ormarić', 'ormaric', 'hr', 'noun', 'A1', 'шафка', 'core', '{"gender": "m"}'::jsonb, '["Torbu ostavi u ormariću."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zaštitna oprema', 'zastitna oprema', 'hr', 'phrase', 'A1', 'захисне спорядження', 'collocation', '{"gender": "f"}'::jsonb, '["Bez zaštitne opreme ne smiješ na gradilište."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pisač', 'pisac', 'hr', 'noun', 'A1', 'принтер', 'core', '{"gender": "m"}'::jsonb, '["Pisač opet ne radi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ispisati', 'ispisati', 'hr', 'verb', 'A1', 'роздрукувати', 'core', '{"aspect": "pfv"}'::jsonb, '["Ispiši mi ovaj dokument."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('skenirati', 'skenirati', 'hr', 'verb', 'A1', 'сканувати', 'core', '{"aspect": "ipfv/pfv"}'::jsonb, '["Možeš li skenirati moju putovnicu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('privitak', 'privitak', 'hr', 'noun', 'A1', 'вкладення (в листі)', 'core', '{"gender": "m"}'::jsonb, '["Ugovor je u privitku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kopirati', 'kopirati', 'hr', 'verb', 'A1', 'копіювати', 'core', '{"aspect": "ipfv/pfv"}'::jsonb, '["Kopiraj datoteku na stolno računalo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('proslijediti', 'proslijediti', 'hr', 'verb', 'A1', 'переслати', 'core', '{"aspect": "pfv"}'::jsonb, '["Proslijedi mi taj mail."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tablica', 'tablica', 'hr', 'noun', 'A1', 'таблиця', 'core', '{"gender": "f"}'::jsonb, '["Podaci su u tablici."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ozlijediti se', 'ozlijediti se', 'hr', 'verb', 'A1', 'травмуватися; поранитися', 'core', '{"aspect": "pfv"}'::jsonb, '["Pazi, možeš se ozlijediti!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('modrica', 'modrica', 'hr', 'noun', 'A1', 'синець', 'core', '{"gender": "f"}'::jsonb, '["Imam modricu na koljenu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('otečen', 'otecen', 'hr', 'adjective', 'A1', 'набряклий; опухлий', 'core', '{}'::jsonb, '["Gležanj je jako otečen."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uganuti', 'uganuti', 'hr', 'verb', 'A1', 'підвернути; вивихнути', 'core', '{"aspect": "pfv"}'::jsonb, '["Na stepenicama je lako uganuti nogu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('hitni prijem', 'hitni prijem', 'hr', 'phrase', 'A1', 'приймальне відділення (невідкладна допомога)', 'collocation', '{"gender": "m"}'::jsonb, '["Idemo na hitni prijem u bolnicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pretraga', 'pretraga', 'hr', 'noun', 'A1', 'обстеження; аналіз', 'core', '{"gender": "f"}'::jsonb, '["Trebate pretragu krvi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('natašte', 'nataste', 'hr', 'adverb', 'A1', 'натщесерце', 'core', '{}'::jsonb, '["Krv vadimo natašte."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kontrola', 'kontrola', 'hr', 'noun', 'A1', 'контрольний огляд; контроль', 'core', '{"gender": "f"}'::jsonb, '["Dođite na kontrolu za mjesec dana."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rendgen', 'rendgen', 'hr', 'noun', 'A1', 'рентген', 'core', '{"gender": "m"}'::jsonb, '["Trebate rendgen pluća."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('čekaonica', 'cekaonica', 'hr', 'noun', 'A1', 'зал очікування', 'core', '{"gender": "f"}'::jsonb, '["Sjednite u čekaonicu, molim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ultrazvuk', 'ultrazvuk', 'hr', 'noun', 'A1', 'ультразвук (УЗД)', 'core', '{"gender": "m"}'::jsonb, '["U utorak imam ultrazvuk srca."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('naručiti se', 'naruciti se', 'hr', 'verb', 'A1', 'записатися (на прийом)', 'core', '{"aspect": "pfv"}'::jsonb, '["Moram se naručiti kod liječnika."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('teretana', 'teretana', 'hr', 'noun', 'A1', 'тренажерний зал', 'core', '{"gender": "f"}'::jsonb, '["Idem u teretanu tri puta tjedno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mršaviti', 'mrsaviti', 'hr', 'verb', 'A1', 'худнути', 'core', '{"aspect": "ipfv"}'::jsonb, '["Zimi teško mršavim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('debljati se', 'debljati se', 'hr', 'verb', 'A1', 'гладшати; набирати вагу', 'core', '{"aspect": "ipfv"}'::jsonb, '["Zimi se debljam."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dijeta', 'dijeta', 'hr', 'noun', 'A1', 'дієта', 'core', '{"gender": "f"}'::jsonb, '["Moja sestra je na dijeti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('alkohol', 'alkohol', 'hr', 'noun', 'A1', 'алкоголь', 'core', '{"gender": "m"}'::jsonb, '["Ne pijem alkohol."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pušenje', 'pusenje', 'hr', 'noun', 'A1', 'куріння', 'core', '{"gender": "n"}'::jsonb, '["Pušenje je loše za zdravlje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('redovito', 'redovito', 'hr', 'adverb', 'A1', 'регулярно', 'core', '{}'::jsonb, '["Redovito pijem vodu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kretanje', 'kretanje', 'hr', 'noun', 'A1', 'рух', 'core', '{"gender": "n"}'::jsonb, '["Kretanje je važno za zdravlje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('navika', 'navika', 'hr', 'noun', 'A1', 'звичка', 'core', '{"gender": "f"}'::jsonb, '["Šetnja poslije večere je moja navika."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pedijatar', 'pedijatar', 'hr', 'noun', 'A1', 'педіатр', 'core', '{"gender": "m"}'::jsonb, '["Pedijatar radi od osam do dva."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('osip', 'osip', 'hr', 'noun', 'A1', 'висип', 'core', '{"gender": "m"}'::jsonb, '["Dijete ima osip po tijelu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('povraćati', 'povracati', 'hr', 'verb', 'A1', 'блювати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Mali povraća od jutros."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('proljev', 'proljev', 'hr', 'noun', 'A1', 'пронос; діарея', 'core', '{"gender": "m"}'::jsonb, '["Kod proljeva pijte puno vode."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('curiti', 'curiti', 'hr', 'verb', 'A1', 'текти; протікати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Curi mi nos."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('upala', 'upala', 'hr', 'noun', 'A1', 'запалення', 'core', '{"gender": "f"}'::jsonb, '["Dijete ima upalu uha."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kapi', 'kapi', 'hr', 'noun', 'A1', 'краплі', 'core', '{"gender": "f", "number": "pl"}'::jsonb, '["Kapi za nos dajte tri puta dnevno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dojenče', 'dojence', 'hr', 'noun', 'A1', 'немовля', 'core', '{"gender": "n"}'::jsonb, '["Dojenče puno spava."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zaručen', 'zarucen', 'hr', 'adjective', 'A1', 'заручений', 'core', '{}'::jsonb, '["Moj brat je zaručen."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rastati se', 'rastati se', 'hr', 'verb', 'A1', 'розлучитися; розійтися', 'core', '{"aspect": "pfv"}'::jsonb, '["Ne želim se rastati od tebe."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zgodan', 'zgodan', 'hr', 'adjective', 'A1', 'гарний (на вигляд); привабливий', 'core', '{}'::jsonb, '["Njezin dečko je jako zgodan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('romantičan', 'romantican', 'hr', 'adjective', 'A1', 'романтичний', 'core', '{}'::jsonb, '["Večera uz more je romantična."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('godišnjica', 'godisnjica', 'hr', 'noun', 'A1', 'річниця', 'core', '{"gender": "f"}'::jsonb, '["Sutra nam je godišnjica braka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('navijati', 'navijati', 'hr', 'verb', 'A1', 'вболівати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Za koga navijaš?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gol', 'gol', 'hr', 'noun', 'A1', 'гол', 'core', '{"gender": "m"}'::jsonb, '["Kakav lijep gol!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('košarka', 'kosarka', 'hr', 'noun', 'A1', 'баскетбол', 'core', '{"gender": "f"}'::jsonb, '["Moj sin igra košarku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tenis', 'tenis', 'hr', 'noun', 'A1', 'теніс', 'core', '{"gender": "m"}'::jsonb, '["Subotom igram tenis."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odbojka', 'odbojka', 'hr', 'noun', 'A1', 'волейбол', 'core', '{"gender": "f"}'::jsonb, '["Ljeti igramo odbojku na plaži."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rukomet', 'rukomet', 'hr', 'noun', 'A1', 'гандбол', 'core', '{"gender": "m"}'::jsonb, '["Hrvatska je jaka u rukometu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;

-- 2. Виправлення словника для слів цих уроків (стара версія — у content_versions)
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('obiteljski liječnik') and ukrainian_translation = 'Сімейний лікар';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «Сімейний лікар» → «сімейний лікар»');
  update public.lexemes set ukrainian_translation = 'сімейний лікар' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «Сімейний лікар» → «сімейний лікар»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('spoj') and ukrainian_translation = 'з''єднання';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «з''єднання» → «побачення; з''єднання»');
  update public.lexemes set ukrainian_translation = 'побачення; з''єднання' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «з''єднання» → «побачення; з''єднання»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('prijaviti se') and ukrainian_translation = 'зареєструватися';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «зареєструватися» → «зареєструватися; подати заявку»');
  update public.lexemes set ukrainian_translation = 'зареєструватися; подати заявку' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «зареєструватися» → «зареєструватися; подати заявку»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('točan') and ukrainian_translation = 'правильний / точний';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «правильний / точний» → «точний; пунктуальний»');
  update public.lexemes set ukrainian_translation = 'точний; пунктуальний' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «правильний / точний» → «точний; пунктуальний»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('izgubiti') and ukrainian_translation = 'загубити / втратити';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «загубити / втратити» → «загубити; втратити; програти»');
  update public.lexemes set ukrainian_translation = 'загубити; втратити; програти' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «загубити / втратити» → «загубити; втратити; програти»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lemma = 'Obiteljski liječnik';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: лема «Obiteljski liječnik» → «obiteljski liječnik»');
  update public.lexemes set lemma = 'obiteljski liječnik' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: лема «Obiteljski liječnik» → «obiteljski liječnik»');
end $$;

-- 3. Уроки
-- A1.6 · урок 50: Професії
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'b369f01f-4a84-57b4-98cb-150d236f4d7f';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A1.6: місце уроку 6 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.6.6'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 50: Професії', 'Lekcija 50: Zanimanja', '["Назвати свою професію", "Розповісти, хто ким працює в родині", "Зрозуміти оголошення про вакансії"]'::jsonb, 12, 'PUBLISHED', 6);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kuhar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čistačica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'električar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vodoinstalater', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zidar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'njegovateljica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'frizerka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blagajnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skladištar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'recepcioner', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sobarica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gradilište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skladište', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '225d6f96-4dae-5269-9ee6-ede4d8d4e212', 'fill_in_the_blank', 'Moj muž ___ kao kuhar.', 'radi', '["radiš", "radi", "radim", "rade"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a33cacf6-d5f0-5011-a96b-b25825b926a9', 'multiple_choice', 'Що означає «zidar»?', 'муляр; будівельник', '["муляр; будівельник", "склад", "електрик", "будівельний майданчик"]'::jsonb, 'A1', 2, 'PUBLISHED', 'zidar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c73bd53d-4c09-5284-9861-0d483cd827fd', 'multiple_choice', 'Що означає «sobarica»?', 'покоївка', '["будівельний майданчик", "покоївка", "перукарка", "робітник"]'::jsonb, 'A1', 3, 'PUBLISHED', 'sobarica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8353aab3-3c2e-56de-a816-37aa3ced7cdf', 'multiple_choice', 'Як хорватською «комірник; працівник складу»?', 'skladištar', '["frizerka", "vodoinstalater", "blagajnica", "skladištar"]'::jsonb, 'A1', 4, 'PUBLISHED', 'skladištar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '65883e20-ef05-5822-a799-07e640afa449', 'type_answer', 'Напишіть хорватською: «прибиральниця»', 'čistačica', null, 'A1', 5, 'PUBLISHED', 'čistačica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b166eba3-2acd-5ee3-bad2-7bb3823c056a', 'type_answer', 'Напишіть хорватською: «кухар»', 'kuhar', null, 'A1', 6, 'PUBLISHED', 'kuhar', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8a0e4a4f-3219-5535-bc11-67b3a7f29824', 'sentence_builder', 'Складіть: «Я працюю покоївкою в готелі.»', 'Radim kao sobarica u hotelu.', '["Radim", "sobarica", "u", "hotelu.", "kao"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '14f290b9-8975-5e3e-b089-e8417b3296b8', 'sentence_builder', 'Складіть: «Вона доглядає літню пані.»', 'Ona brine o starijoj gospođi.', '["o", "Ona", "starijoj", "gospođi.", "brine"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2e2e3226-7be9-5141-b8a9-f14d97824c36', 'listening', 'Прослухайте і складіть фразу', 'Što radiš u Hrvatskoj?', '["Hrvatskoj?", "u", "Što", "radiš"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7a39f4e5-4b59-5725-a1e7-e1878ff2f425', 'listening', 'Прослухайте і складіть фразу', 'Je li skladište daleko?', '["li", "skladište", "daleko?", "Je"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2291a791-a43e-56d4-989f-4eecfbb09970', 'speaking', 'Моя подруга — перукарка.', 'Moja prijateljica je frizerka.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a2e78032-e0b4-5f22-af5d-772f988133ec', 'speaking', 'На будівництві працює багато робітників.', 'Na gradilištu radi puno radnika.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('693ce72c-5f06-5a26-95bd-51593a77a50d', v_lesson, 'Ким ти працюєш?', 'Što radiš?', 1501, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('4b0056c7-a969-5e02-a0ea-6cfc438c8500', '693ce72c-5f06-5a26-95bd-51593a77a50d', 'Marko', 'Što radiš u Hrvatskoj?', 'Ким ти працюєш у Хорватії?', 1);
  perform pg_temp.turn('03997097-6cb2-5a6c-a2d2-92559fb8ebf0', '693ce72c-5f06-5a26-95bd-51593a77a50d', 'Oksana', 'Radim kao sobarica u hotelu. Moj muž je kuhar.', 'Я працюю покоївкою в готелі. Мій чоловік — кухар.', 2);
  perform pg_temp.turn('9ba3a841-b509-5905-b953-0794713b6b70', '693ce72c-5f06-5a26-95bd-51593a77a50d', 'Marko', 'A tvoja sestra?', 'А твоя сестра?', 3);
  perform pg_temp.turn('72885258-101b-5f93-af84-6ac4af7a7e26', '693ce72c-5f06-5a26-95bd-51593a77a50d', 'Oksana', 'Ona je njegovateljica. Brine o starijoj gospođi.', 'Вона доглядальниця. Доглядає літню пані.', 4);
  perform pg_temp.turn('43351da1-0d0b-5ca7-9102-9839cdbff770', '693ce72c-5f06-5a26-95bd-51593a77a50d', 'Marko', 'Ja sam električar. Radim na gradilištu.', 'Я електрик. Працюю на будівництві.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('31cf09c4-cba4-571a-a2d4-724180350e8b', v_lesson, 'Вакансії', 'Slobodna radna mjesta', 1502, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('77009228-e88f-52f4-933a-8170196c1950', '31cf09c4-cba4-571a-a2d4-724180350e8b', 'Ana', 'Trgovina traži blagajnicu i skladištara.', 'Магазин шукає касирку й комірника.', 1);
  perform pg_temp.turn('65e5f866-2a1f-527c-b91b-f69c68b710e3', '31cf09c4-cba4-571a-a2d4-724180350e8b', 'Taras', 'Je li skladište daleko?', 'Склад далеко?', 2);
  perform pg_temp.turn('9b323519-9aed-5da1-8935-c18e167645fe', '31cf09c4-cba4-571a-a2d4-724180350e8b', 'Ana', 'Ne, blizu. A hotel traži recepcionera i čistačicu.', 'Ні, близько. А готель шукає адміністратора й прибиральницю.', 3);
  perform pg_temp.turn('6a8dcb21-1ddf-5d4d-b79c-4f7e37d9cddf', '31cf09c4-cba4-571a-a2d4-724180350e8b', 'Taras', 'Znam engleski, mogu raditi na recepciji.', 'Я знаю англійську, можу працювати на рецепції.', 4);
  perform pg_temp.turn('51861a2a-6a8c-53f4-bd48-7b73d9a555c3', '31cf09c4-cba4-571a-a2d4-724180350e8b', 'Ana', 'Super! A tvoj brat je zidar, zar ne?', 'Чудово! А твій брат муляр, так?', 5);
  perform pg_temp.turn('ec075a95-892f-5b62-8857-284bd93d026a', '31cf09c4-cba4-571a-a2d4-724180350e8b', 'Taras', 'Da, ali sada radi kao vodoinstalater.', 'Так, але зараз працює сантехніком.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 51: Шукаю роботу
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'c9b87882-5e31-5485-aea7-0169216466a8';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A1.6: місце уроку 7 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.6.7'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 51: Шукаю роботу', 'Lekcija 51: Tražim posao', '["Подзвонити за оголошенням про роботу", "Запитати про умови: оплата, житло, сезон", "Зареєструватися в центрі зайнятості"]'::jsonb, 12, 'PUBLISHED', 7);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'oglas', v_pos);
  v_pos := pg_temp.word(v_lesson, 'životopis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poslodavac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uvjet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'satnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smještaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sezonski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radno mjesto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zavod za zapošljavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nezaposlen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijaviti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preporuka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stalan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plaćen', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f7791426-a950-5cca-8306-16e74bdea9e9', 'fill_in_the_blank', '___ su uvjeti rada?', 'Kakvi', '["Kakvo", "Kakvi", "Kakav", "Kakva"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5c0d8e5e-61ff-5c1d-a8c3-654261421a85', 'multiple_choice', 'Що означає «preporuka»?', 'рекомендація', '["постійний", "зареєструватися; подати заявку", "рекомендація", "умова"]'::jsonb, 'A1', 2, 'PUBLISHED', 'preporuka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6597b3af-f39a-589c-85de-6f32fc286bb2', 'multiple_choice', 'Що означає «nezaposlen»?', 'безробітний', '["оплачуваний; оплачений", "погодинна оплата", "роботодавець", "безробітний"]'::jsonb, 'A1', 3, 'PUBLISHED', 'nezaposlen', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ced56c8e-96a2-58e7-aad4-daf8236900c1', 'multiple_choice', 'Як хорватською «постійний»?', 'stalan', '["prijaviti se", "životopis", "sezonski", "stalan"]'::jsonb, 'A1', 4, 'PUBLISHED', 'stalan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b063ee9b-46f4-5986-8ea7-51d6c80ed652', 'type_answer', 'Напишіть хорватською: «умова»', 'uvjet', null, 'A1', 5, 'PUBLISHED', 'uvjet', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f503fb91-edbd-5138-b96e-84b1f7612df8', 'type_answer', 'Напишіть хорватською: «зареєструватися; подати заявку»', 'prijaviti se', null, 'A1', 6, 'PUBLISHED', 'prijaviti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '36db2098-91ad-5478-82e9-4ab0b3a2d3b7', 'sentence_builder', 'Складіть: «Надішліть мені резюме.»', 'Pošaljite mi životopis.', '["mi", "Pošaljite", "životopis."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '85fb3600-9b6b-59d2-a5fc-9385948e5847', 'sentence_builder', 'Складіть: «Я шукаю постійну роботу.»', 'Tražim stalan posao.', '["posao.", "stalan", "Tražim"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7899911f-83d3-5680-8a98-5d5d71551277', 'listening', 'Прослухайте і складіть фразу', 'Je li posao sezonski ili stalan?', '["ili", "stalan?", "li", "Je", "posao", "sezonski"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '27e139d4-5358-53f9-8d33-8a1a568e088e', 'listening', 'Прослухайте і складіть фразу', 'Jeste li nezaposleni?', '["nezaposleni?", "li", "Jeste"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ee63d34b-8ec1-5515-a52d-f6a73db40a38', 'speaking', 'Яка погодинна оплата?', 'Kolika je satnica?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa589094-922a-582b-b0e8-f1d32a0f7270', 'speaking', 'Хто роботодавець?', 'Tko je poslodavac?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4c722e98-8682-5118-b1b8-993559e35a98', v_lesson, 'Оголошення', 'Oglas za posao', 1511, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('f20d483d-4ddc-5283-b4a3-5dbd759714e4', '4c722e98-8682-5118-b1b8-993559e35a98', 'Andrij', 'Dobar dan, zovem zbog oglasa. Je li radno mjesto još slobodno?', 'Добрий день, дзвоню щодо оголошення. Посада ще вільна?', 1);
  perform pg_temp.turn('75a74bbb-5c66-5e8d-887d-702e30b90a8a', '4c722e98-8682-5118-b1b8-993559e35a98', 'Poslodavac', 'Jest. Tražimo konobara za sezonu. Imate li iskustva?', 'Так. Шукаємо офіціанта на сезон. У вас є досвід?', 2);
  perform pg_temp.turn('2fff6033-eeb8-5292-a41d-c2e7281683a1', '4c722e98-8682-5118-b1b8-993559e35a98', 'Andrij', 'Imam dvije godine iskustva. Kakvi su uvjeti?', 'Маю два роки досвіду. Які умови?', 3);
  perform pg_temp.turn('9d17d511-5652-5680-a325-2ff8b70bf6e9', '4c722e98-8682-5118-b1b8-993559e35a98', 'Poslodavac', 'Satnica je osam eura. Smještaj i hrana su besplatni.', 'Погодинна оплата — вісім євро. Житло й харчування безкоштовні.', 4);
  perform pg_temp.turn('8708c8ea-c60b-565e-9b0a-69a9ee6e4964', '4c722e98-8682-5118-b1b8-993559e35a98', 'Andrij', 'Je li posao sezonski ili stalan?', 'Робота сезонна чи постійна?', 5);
  perform pg_temp.turn('3e0bc4e9-acae-5984-949c-a7b046c1b24c', '4c722e98-8682-5118-b1b8-993559e35a98', 'Poslodavac', 'Sezonski, do listopada. Pošaljite mi životopis.', 'Сезонна, до жовтня. Надішліть мені резюме.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7740d1a2-ac84-5e78-8b59-48388b18fd48', v_lesson, 'У центрі зайнятості', 'Na Zavodu za zapošljavanje', 1512, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('c07f5390-9319-51ff-b531-a4f872350ad8', '7740d1a2-ac84-5e78-8b59-48388b18fd48', 'Službenica', 'Jeste li nezaposleni?', 'Ви безробітні?', 1);
  perform pg_temp.turn('09ec40bc-48c5-56b2-b349-d758b3420343', '7740d1a2-ac84-5e78-8b59-48388b18fd48', 'Olena', 'Da. Kako se mogu prijaviti na Zavod za zapošljavanje?', 'Так. Як мені зареєструватися в центрі зайнятості?', 2);
  perform pg_temp.turn('cecee3bb-c78d-5a9b-8dec-40dd465e3242', '7740d1a2-ac84-5e78-8b59-48388b18fd48', 'Službenica', 'Trebate osobni dokument i OIB.', 'Вам потрібні документ, що посвідчує особу, і OIB.', 3);
  perform pg_temp.turn('c0b67da5-0d02-5673-8df1-c525daf93869', '7740d1a2-ac84-5e78-8b59-48388b18fd48', 'Olena', 'Imate li preporuku za neki tečaj?', 'Можете порадити якісь курси?', 4);
  perform pg_temp.turn('fcf81b58-6797-538f-8531-06cda430e491', '7740d1a2-ac84-5e78-8b59-48388b18fd48', 'Službenica', 'Imamo tečaj hrvatskog za strance. Za Vas je plaćen.', 'У нас є курс хорватської для іноземців. Для вас він оплачений.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 52: Перший робочий день
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '2c56a486-dbbb-5102-b7cb-754c59cf94c3';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 8) then
    raise exception 'A1.6: місце уроку 8 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.6.8'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 52: Перший робочий день', 'Lekcija 52: Prvi radni dan', '["Познайомитися з командою і керівником", "Зрозуміти правила безпеки", "Запитати, що можна й що треба робити"]'::jsonb, 12, 'PUBLISHED', 8);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'radna odjeća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svlačionica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ormarić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pauza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaštitna oprema', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sigurnost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upute', v_pos);
  v_pos := pg_temp.word(v_lesson, 'voditelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zadatak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naučiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'objasniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tim', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odgovoran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'točan', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '74e2b831-4a8b-5250-aefa-0a5df56c9555', 'fill_in_the_blank', 'Ti bez zaštitne opreme ne ___ ući.', 'smiješ', '["smije", "smijemo", "smiješ", "smijem"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f085be4-679b-57be-be52-094636911a0f', 'multiple_choice', 'Що означає «sigurnost»?', 'безпека', '["команда", "безпека", "перерва", "завдання"]'::jsonb, 'A1', 2, 'PUBLISHED', 'sigurnost', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ea581ec2-66f1-5769-9905-6eb17d7709c7', 'multiple_choice', 'Що означає «radna odjeća»?', 'робочий одяг', '["шафка", "керівник, ведучий", "відповідальний", "робочий одяг"]'::jsonb, 'A1', 3, 'PUBLISHED', 'radna odjeća', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0c6c1a1a-d73e-5c18-85d6-ecd594705ebd', 'multiple_choice', 'Як хорватською «інструкції»?', 'upute', '["radna odjeća", "voditelj", "upute", "ormarić"]'::jsonb, 'A1', 4, 'PUBLISHED', 'upute', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1bbd4224-0936-5f88-a95c-e172dcc73fc7', 'type_answer', 'Напишіть хорватською: «точний; пунктуальний»', 'točan', null, 'A1', 5, 'PUBLISHED', 'točan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '43afb2d7-9b6e-5c33-9945-b176e7d82356', 'type_answer', 'Напишіть хорватською: «відповідальний»', 'odgovoran', null, 'A1', 6, 'PUBLISHED', 'odgovoran', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a0587655-65ac-5e08-8641-9b8f4e46cb46', 'sentence_builder', 'Складіть: «Сумку залиш у шафці.»', 'Torbu ostavi u ormariću.', '["ormariću.", "u", "Torbu", "ostavi"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1044969d-3afe-525e-ac5a-006f4e736fdc', 'sentence_builder', 'Складіть: «Що мені треба вивчити?»', 'Što moram naučiti?', '["moram", "Što", "naučiti?"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6549404a-d183-5f6e-aaf4-84aa344dc487', 'listening', 'Прослухайте і складіть фразу', 'Kada je pauza?', '["pauza?", "Kada", "je"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '549766e1-5f4e-5002-87ab-a84a9f516471', 'listening', 'Прослухайте і складіть фразу', 'Možete li mi objasniti upute?', '["Možete", "objasniti", "li", "mi", "upute?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '580074bb-ad4c-52d8-87d9-e7638808bf32', 'speaking', 'Де роздягальня?', 'Gdje je svlačionica?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dc5916e3-d8de-58f3-b995-9ba264cb403d', 'speaking', 'Я відповідаю за безпеку.', 'Ja sam odgovoran za sigurnost.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e63cb032-2718-51ee-9bb7-7f25813ec95d', v_lesson, 'Ласкаво просимо в команду', 'Dobro došla u tim', 1521, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('b26b8147-e197-56b0-b65b-59c4b5bf9636', 'e63cb032-2718-51ee-9bb7-7f25813ec95d', 'Maja', 'Dobro došla u naš tim! Ja sam Maja, voditeljica smjene.', 'Ласкаво просимо в нашу команду! Я Мая, керівниця зміни.', 1);
  perform pg_temp.turn('a1585817-464d-5e8c-b385-d5d16b0a15c0', 'e63cb032-2718-51ee-9bb7-7f25813ec95d', 'Oksana', 'Drago mi je. Što moram danas naučiti?', 'Приємно познайомитися. Що мені сьогодні треба вивчити?', 2);
  perform pg_temp.turn('32030c16-1062-5844-9a13-72484252e1fd', 'e63cb032-2718-51ee-9bb7-7f25813ec95d', 'Maja', 'Prvo svlačionica. Tamo su tvoj ormarić i radna odjeća.', 'Спочатку роздягальня. Там твоя шафка й робочий одяг.', 3);
  perform pg_temp.turn('c75d0b23-1e6c-5a52-bedb-4590b9d867a8', 'e63cb032-2718-51ee-9bb7-7f25813ec95d', 'Oksana', 'Kada je pauza?', 'Коли перерва?', 4);
  perform pg_temp.turn('b2920cf6-2e35-5b3d-b456-3127890a3146', 'e63cb032-2718-51ee-9bb7-7f25813ec95d', 'Maja', 'U deset i u dva, po petnaest minuta. Moraš biti točna.', 'О десятій і о другій, по п’ятнадцять хвилин. Треба бути пунктуальною.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f465df03-c023-54eb-b461-d2c84e30b038', v_lesson, 'Безпека на складі', 'Sigurnost u skladištu', 1522, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('631c46f7-8290-53c6-b3eb-bb8d0670ed14', 'f465df03-c023-54eb-b461-d2c84e30b038', 'Voditelj', 'Ovdje je sigurnost najvažnija. Bez zaštitne opreme ne smiješ ući.', 'Тут безпека найважливіша. Без захисного спорядження заходити не можна.', 1);
  perform pg_temp.turn('f5158980-bd4f-5743-aaf7-6cf458d877b5', 'f465df03-c023-54eb-b461-d2c84e30b038', 'Andrij', 'Razumijem. Možete li mi objasniti upute?', 'Розумію. Можете пояснити мені інструкції?', 2);
  perform pg_temp.turn('53485bd9-ad54-5e39-8834-7b87618d6a5c', 'f465df03-c023-54eb-b461-d2c84e30b038', 'Voditelj', 'Naravno. Tvoj zadatak je slagati pakete na police.', 'Звісно. Твоє завдання — складати пакунки на полиці.', 3);
  perform pg_temp.turn('c8178975-6b0f-542e-8520-eaa9421bea71', 'f465df03-c023-54eb-b461-d2c84e30b038', 'Andrij', 'Koga trebam zvati ako imam problem?', 'Кому мені дзвонити, якщо є проблема?', 4);
  perform pg_temp.turn('b0209ca7-a758-54ba-a81e-a706fea5a718', 'f465df03-c023-54eb-b461-d2c84e30b038', 'Voditelj', 'Mene. Ja sam odgovoran za cijeli tim.', 'Мені. Я відповідаю за всю команду.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 53: В офісі
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'ee016ba8-5160-581d-b440-1bcb7647173d';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 9) then
    raise exception 'A1.6: місце уроку 9 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '318b394b-c622-5dd6-8494-4c1472b6df62';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.6.9'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 53: В офісі', 'Lekcija 53: U uredu', '["Роздрукувати, відсканувати й зберегти документ", "Відповісти на робочий лист і переслати його", "Назвати офісні речі"]'::jsonb, 12, 'PUBLISHED', 9);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'pisač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispisati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skenirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'datoteka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'privitak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mapa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'računalo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kopirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spremiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obrisati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odgovoriti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'proslijediti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'papir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tablica', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2cf5f7ac-70aa-5fe6-942e-201dc20d5384', 'fill_in_the_blank', 'Ja ___ dokumente u mapu.', 'spremam', '["spremaju", "spremam", "sprema", "spremaš"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0bc75b7e-df7b-5f50-9b8c-7f684de10a69', 'multiple_choice', 'Що означає «ispisati»?', 'роздрукувати', '["папір", "роздрукувати", "видалити", "принтер"]'::jsonb, 'A1', 2, 'PUBLISHED', 'ispisati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '54e3bfa0-dc7d-5ef3-8407-b02aadab4037', 'multiple_choice', 'Що означає «odgovoriti»?', 'відповісти', '["принтер", "відповісти", "копіювати", "переслати"]'::jsonb, 'A1', 3, 'PUBLISHED', 'odgovoriti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '482ca0b6-9af2-56d2-a9be-a7c36177b295', 'multiple_choice', 'Як хорватською «копіювати»?', 'kopirati', '["kopirati", "skenirati", "papir", "proslijediti"]'::jsonb, 'A1', 4, 'PUBLISHED', 'kopirati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '05fed2e4-759b-5a95-b332-c791b8c311eb', 'type_answer', 'Напишіть хорватською: «таблиця»', 'tablica', null, 'A1', 5, 'PUBLISHED', 'tablica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3c45d85d-1c90-5461-9c56-87b2a39fe4c3', 'type_answer', 'Напишіть хорватською: «переслати»', 'proslijediti', null, 'A1', 6, 'PUBLISHED', 'proslijediti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4075902c-02cc-582f-8500-8ebbdc0229b3', 'sentence_builder', 'Складіть: «Договір у вкладенні.»', 'Ugovor je u privitku.', '["je", "Ugovor", "u", "privitku."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0f4e2df8-76b7-5b1c-b004-c707a9cb6dbc', 'sentence_builder', 'Складіть: «Роздрукуй мені цей документ.»', 'Ispiši mi ovaj dokument.', '["ovaj", "mi", "dokument.", "Ispiši"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '00c8a326-ebbc-52c4-9bf9-62023a9e3b65', 'listening', 'Прослухайте і складіть фразу', 'Nema papira.', '["papira.", "Nema"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '917d917d-e483-57bf-a73c-054da7299c01', 'listening', 'Прослухайте і складіть фразу', 'Naravno. Što mu šaljem?', '["šaljem?", "Što", "mu", "Naravno."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '13108522-fd7d-5381-91b8-3d518b94b935', 'speaking', 'Перешли мені цей лист.', 'Proslijedi mi taj mail.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '36f7521d-6a0e-5146-8bb9-b5f8180d7ae9', 'speaking', 'Дані в таблиці.', 'Podaci su u tablici.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7c464ed6-905f-542f-8cc8-495d70768310', v_lesson, 'Принтер не друкує', 'Pisač ne radi', 1531, 'A1', 'it_work', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('41143c64-e068-54b2-bdf2-c91d221528dc', '7c464ed6-905f-542f-8cc8-495d70768310', 'Ivana', 'Pisač opet ne radi! Trebam ispisati ugovor.', 'Принтер знову не працює! Мені треба роздрукувати договір.', 1);
  perform pg_temp.turn('769c7653-8a22-5bf9-87c1-9bb12af129ea', '7c464ed6-905f-542f-8cc8-495d70768310', 'Taras', 'Nema papira. Evo, stavljam papir.', 'Немає паперу. Ось, кладу папір.', 2);
  perform pg_temp.turn('9de8d6c8-2081-5c97-85f0-e6818096053d', '7c464ed6-905f-542f-8cc8-495d70768310', 'Ivana', 'Hvala! Možeš li mi skenirati i ovu putovnicu?', 'Дякую! Можеш мені ще відсканувати цей паспорт?', 3);
  perform pg_temp.turn('8bad97b9-423f-5ce2-9584-8fe87884b0cb', '7c464ed6-905f-542f-8cc8-495d70768310', 'Taras', 'Mogu. Datoteku spremam u mapu Klijenti.', 'Можу. Файл зберігаю в папку «Клієнти».', 4);
  perform pg_temp.turn('7a5e33f4-2f2c-55c8-88bf-7b424e520b19', '7c464ed6-905f-542f-8cc8-495d70768310', 'Ivana', 'Super. Kopiraj je i na moje računalo.', 'Чудово. Скопіюй його й на мій комп’ютер.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('dfa88584-54f5-501d-8f3e-eaafcb1c1393', v_lesson, 'Пошта на роботі', 'Mail na poslu', 1532, 'A1', 'it_work', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('97509487-0f4c-5481-888c-ad1b13c16259', 'dfa88584-54f5-501d-8f3e-eaafcb1c1393', 'Šef', 'Molim Vas, odgovorite danas klijentu iz Splita.', 'Будь ласка, дайте сьогодні відповідь клієнту зі Спліта.', 1);
  perform pg_temp.turn('86461412-867b-532d-a996-7983c1211d9b', 'dfa88584-54f5-501d-8f3e-eaafcb1c1393', 'Oksana', 'Naravno. Što mu šaljem?', 'Звісно. Що йому надіслати?', 2);
  perform pg_temp.turn('24b3f37d-dd6b-5f2c-a043-62200a1fa74b', 'dfa88584-54f5-501d-8f3e-eaafcb1c1393', 'Šef', 'Tablicu s cijenama. Ona je u privitku mog maila.', 'Таблицю з цінами. Вона у вкладенні мого листа.', 3);
  perform pg_temp.turn('c9fe347f-8c7c-56a9-9509-13911ab6ee92', 'dfa88584-54f5-501d-8f3e-eaafcb1c1393', 'Oksana', 'Dobro, prosljeđujem mu Vaš mail.', 'Добре, пересилаю йому ваш лист.', 4);
  perform pg_temp.turn('7c2761df-7627-5fa9-a004-7c889ba051d1', 'dfa88584-54f5-501d-8f3e-eaafcb1c1393', 'Šef', 'I obrišite stare datoteke iz zajedničke mape.', 'І видаліть старі файли зі спільної папки.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 59: Травма
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'd5dee6c5-f510-57b9-a1ed-4b0a60e8e09a';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A1.7: місце уроку 6 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.7.6'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 59: Травма', 'Lekcija 59: Ozljeda', '["Допомогти при порізі", "Пояснити лікареві травму", "Зрозуміти: рентген, гіпс, бинт"]'::jsonb, 12, 'PUBLISHED', 6);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'ozljeda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ozlijediti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pasti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slomiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zavoj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'flaster', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gips', v_pos);
  v_pos := pg_temp.word(v_lesson, 'modrica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otečen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krvariti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uganuti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hitni prijem', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ad486f01-ec69-543e-a8d5-ffc5b3506572', 'fill_in_the_blank', 'Dijete često ___ na igralištu.', 'padne', '["pasti", "padne", "padnem", "padnu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c12533a-a1c6-5e02-afbe-337e7515b691', 'multiple_choice', 'Що означає «rana»?', 'рана', '["набряклий; опухлий", "кров", "підвернути; вивихнути", "рана"]'::jsonb, 'A1', 2, 'PUBLISHED', 'rana', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eab05df9-696d-5c38-9484-07e4729c6846', 'multiple_choice', 'Що означає «flaster»?', 'пластир', '["приймальне відділення (невідкладна допомога)", "підвернути; вивихнути", "травмуватися; поранитися", "пластир"]'::jsonb, 'A1', 3, 'PUBLISHED', 'flaster', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'de3a862d-c556-5827-8765-0498c562fe9f', 'multiple_choice', 'Як хорватською «кров»?', 'krv', '["modrica", "krv", "flaster", "slomiti"]'::jsonb, 'A1', 4, 'PUBLISHED', 'krv', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7bd0980c-0d1e-5eaa-a7a5-be48396dc72d', 'type_answer', 'Напишіть хорватською: «травма»', 'ozljeda', null, 'A1', 5, 'PUBLISHED', 'ozljeda', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aef25c53-d493-5cb8-9299-91dee1553d9c', 'type_answer', 'Напишіть хорватською: «травмуватися; поранитися»', 'ozlijediti se', null, 'A1', 6, 'PUBLISHED', 'ozlijediti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b6052dd9-8877-59ca-ae44-15fa53abf0e4', 'sentence_builder', 'Складіть: «Рана кровить.»', 'Rana krvari.', '["krvari.", "Rana"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c393656f-39f3-5831-bb28-3e434d1b98c8', 'sentence_builder', 'Складіть: «У мене синець на коліні.»', 'Imam modricu na koljenu.', '["na", "koljenu.", "modricu", "Imam"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dee0e57d-cdb2-59dc-b96f-a712111203e2', 'listening', 'Прослухайте і складіть фразу', 'Rana nije duboka, ali krv ne staje.', '["Rana", "staje.", "duboka,", "ali", "nije", "ne", "krv"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c7f63d79-65f7-5bc5-962c-ffe4128d6510', 'listening', 'Прослухайте і складіть фразу', 'Možete li hodati?', '["Možete", "hodati?", "li"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e4ed440d-578d-51f4-8143-e63923e18c7a', 'speaking', 'Обережно, можеш травмуватися!', 'Pazi, možeš se ozlijediti!', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '30af679d-8afc-543b-bef5-7a40b60398f8', 'speaking', 'Де приймальне відділення?', 'Gdje je hitni prijem?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6e6748ab-f1a3-5662-9f27-e7f9c301e872', v_lesson, 'Поріз на роботі', 'Ozljeda na poslu', 1591, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('92205425-f564-5517-a24a-53bbe08a82fe', '6e6748ab-f1a3-5662-9f27-e7f9c301e872', 'Kolega', 'Što ti je? Ruka ti krvari!', 'Що з тобою? У тебе кровить рука!', 1);
  perform pg_temp.turn('a9c2d1a3-bed9-570a-ad61-8fcf9a6854a8', '6e6748ab-f1a3-5662-9f27-e7f9c301e872', 'Andrij', 'Nož. Rana nije duboka, ali krv ne staje.', 'Ніж. Рана неглибока, але кров не зупиняється.', 2);
  perform pg_temp.turn('5865ca47-e3d2-510a-a9ed-13bdfddd11b8', '6e6748ab-f1a3-5662-9f27-e7f9c301e872', 'Kolega', 'Evo flaster. Ne, trebaš zavoj!', 'Ось пластир. Ні, тобі потрібен бинт!', 3);
  perform pg_temp.turn('21b04486-94d5-552e-9236-c52eecda453f', '6e6748ab-f1a3-5662-9f27-e7f9c301e872', 'Andrij', 'Hvala. Daj mi i malo vode.', 'Дякую. Дай мені ще трохи води.', 4);
  perform pg_temp.turn('6e2309ce-c221-5ed2-aac1-257c310ac342', '6e6748ab-f1a3-5662-9f27-e7f9c301e872', 'Kolega', 'Sjedni. Zovem šefa, to je ozljeda na radu.', 'Сідай. Кличу шефа, це травма на роботі.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f7997f9b-470e-55d3-a671-713a93efeef4', v_lesson, 'У приймальному відділенні', 'Na hitnom prijemu', 1592, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('3fcadaa2-6e4d-593b-b139-a454f50f5b60', 'f7997f9b-470e-55d3-a671-713a93efeef4', 'Liječnica', 'Što Vas boli?', 'Що у вас болить?', 1);
  perform pg_temp.turn('117af02f-599d-5ac4-9e29-e3b67e7a0916', 'f7997f9b-470e-55d3-a671-713a93efeef4', 'Olena', 'Gležanj. Jako je otečen i plav.', 'Щиколотка. Дуже набрякла й синя.', 2);
  perform pg_temp.turn('d78168de-b65c-53c3-8baa-4e7b642bf29c', 'f7997f9b-470e-55d3-a671-713a93efeef4', 'Liječnica', 'Imate veliku modricu. Možete li hodati?', 'У вас великий синець. Можете ходити?', 3);
  perform pg_temp.turn('661fa994-a75e-59e8-b257-9f0e3a1c74c3', 'f7997f9b-470e-55d3-a671-713a93efeef4', 'Olena', 'Jedva. Je li slomljen?', 'Ледве. Вона зламана?', 4);
  perform pg_temp.turn('5e9355df-76e1-503b-93c6-ca9808983541', 'f7997f9b-470e-55d3-a671-713a93efeef4', 'Liječnica', 'Ne znam još. Idemo na rendgen. Ako je slomljen, dobivate gips.', 'Ще не знаю. Ідемо на рентген. Якщо зламана, отримаєте гіпс.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 60: Аналізи й обстеження
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '293af384-4ee2-5746-80a8-e8ffdc7009bc';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A1.7: місце уроку 7 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.7.7'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 60: Аналізи й обстеження', 'Lekcija 60: Pretrage i nalazi', '["Отримати направлення до спеціаліста", "Здати аналіз крові в лабораторії", "Записатися на контрольний огляд"]'::jsonb, 12, 'PUBLISHED', 7);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'uputnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'specijalist', v_pos);
  v_pos := pg_temp.word(v_lesson, 'laboratorij', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nalaz krvi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pretraga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tlak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'natašte', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kontrola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rendgen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čekaonica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obiteljski liječnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ultrazvuk', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naručiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjeriti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '877a68fc-9466-5f32-8910-f57cfd4bf035', 'fill_in_the_blank', 'Trebam uputnicu od obiteljskog ___.', 'liječnika', '["liječnik", "liječniku", "liječnikom", "liječnika"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '502b0f81-c2c3-5ffb-9247-0c2c9af6d457', 'multiple_choice', 'Що означає «pretraga»?', 'обстеження; аналіз', '["записатися (на прийом)", "обстеження; аналіз", "лабораторія", "тиск"]'::jsonb, 'A1', 2, 'PUBLISHED', 'pretraga', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd1788a86-cb76-58b2-abd0-9266ad3b23b7', 'multiple_choice', 'Що означає «ultrazvuk»?', 'ультразвук (УЗД)', '["записатися (на прийом)", "вимірювати", "ультразвук (УЗД)", "зал очікування"]'::jsonb, 'A1', 3, 'PUBLISHED', 'ultrazvuk', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b22e68a-f640-5213-bd60-b67e6469f3fb', 'multiple_choice', 'Як хорватською «записатися (на прийом)»?', 'naručiti se', '["čekaonica", "tlak", "naručiti se", "mjeriti"]'::jsonb, 'A1', 4, 'PUBLISHED', 'naručiti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1ace9392-877e-570d-89e0-43240e715222', 'type_answer', 'Напишіть хорватською: «рентген»', 'rendgen', null, 'A1', 5, 'PUBLISHED', 'rendgen', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e8fb54d8-2da8-5638-929d-02039fbdb539', 'type_answer', 'Напишіть хорватською: «натщесерце»', 'natašte', null, 'A1', 6, 'PUBLISHED', 'natašte', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b9c8fc46-d75f-5fe4-9fcc-35fe40e3cca6', 'sentence_builder', 'Складіть: «Кров здаємо натщесерце.»', 'Krv vadimo natašte.', '["Krv", "natašte.", "vadimo"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a0bc4e2d-9bbe-52b7-aa22-d406a552c688', 'sentence_builder', 'Складіть: «Мені треба записатися до спеціаліста.»', 'Moram se naručiti kod specijalista.', '["naručiti", "specijalista.", "kod", "se", "Moram"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '91b7c6ff-d1b7-5e97-8e70-02c18441605f', 'listening', 'Прослухайте і складіть фразу', 'Trebam li uputnicu?', '["Trebam", "uputnicu?", "li"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '18bd0a8f-2e39-5983-bf08-eea4f2da8d3d', 'listening', 'Прослухайте і складіть фразу', 'Jeste li natašte?', '["li", "Jeste", "natašte?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b5be283a-47e8-5e5f-b3e7-c8ce3e864f78', 'speaking', 'Мені потрібен рентген легенів.', 'Trebam rendgen pluća.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ed9124fb-cc35-5324-b744-0522d862f782', 'speaking', 'Де зал очікування?', 'Gdje je čekaonica?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('dd882d9a-25b2-5e39-80ed-8e7a9f3027e7', v_lesson, 'У сімейного лікаря', 'Kod obiteljskog liječnika', 1601, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('6cec109d-538e-5113-b337-0ce17449d5cb', 'dd882d9a-25b2-5e39-80ed-8e7a9f3027e7', 'Liječnik', 'Sada Vam mjerim tlak.', 'Зараз виміряю вам тиск.', 1);
  perform pg_temp.turn('543727db-7ed4-51bb-bd3e-7428aac9fa7f', 'dd882d9a-25b2-5e39-80ed-8e7a9f3027e7', 'Taras', 'Je li visok?', 'Він високий?', 2);
  perform pg_temp.turn('c44bd94d-a34e-5d6d-b149-ddf772fd5681', 'dd882d9a-25b2-5e39-80ed-8e7a9f3027e7', 'Liječnik', 'Malo. Trebate pretragu krvi i ultrazvuk srca.', 'Трохи. Вам треба здати аналіз крові й зробити УЗД серця.', 3);
  perform pg_temp.turn('51f57f0a-ff20-5a7d-a896-e5f1b9ad157f', 'dd882d9a-25b2-5e39-80ed-8e7a9f3027e7', 'Taras', 'Trebam li uputnicu?', 'Мені потрібне направлення?', 4);
  perform pg_temp.turn('2deff695-3edd-5603-9a2b-2bb35a897666', 'dd882d9a-25b2-5e39-80ed-8e7a9f3027e7', 'Liječnik', 'Da, evo uputnice za laboratorij i za specijalista.', 'Так, ось направлення до лабораторії і до спеціаліста.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('19d76f3b-8d0a-5628-b06f-0d9dc4fc88af', v_lesson, 'У лабораторії', 'U laboratoriju', 1602, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('6f7392ff-412d-546b-8827-5be2fe93fb03', '19d76f3b-8d0a-5628-b06f-0d9dc4fc88af', 'Sestra', 'Dobro jutro. Jeste li natašte?', 'Доброго ранку. Ви натщесерце?', 1);
  perform pg_temp.turn('d8867679-3f3e-5103-b811-11eac9833aed', '19d76f3b-8d0a-5628-b06f-0d9dc4fc88af', 'Olena', 'Jesam, ništa ne jedem od jučer.', 'Так, нічого не їм з учорашнього дня.', 2);
  perform pg_temp.turn('1f131456-a35a-54e4-a053-e6749153c1ac', '19d76f3b-8d0a-5628-b06f-0d9dc4fc88af', 'Sestra', 'Dobro. Sjednite u čekaonicu, zovem Vas.', 'Добре. Сядьте в залі очікування, я вас покличу.', 3);
  perform pg_temp.turn('95b5d934-f99a-5528-a3d1-83af08feefe2', '19d76f3b-8d0a-5628-b06f-0d9dc4fc88af', 'Olena', 'Kada dobivam nalaz krvi?', 'Коли я отримаю результат аналізу крові?', 4);
  perform pg_temp.turn('bda0c1c4-471b-566d-9e88-e0f7094d8fb3', '19d76f3b-8d0a-5628-b06f-0d9dc4fc88af', 'Sestra', 'Sutra. S nalazom se naručite kod liječnika na kontrolu.', 'Завтра. З результатом запишіться до лікаря на контрольний огляд.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 61: Здоровий спосіб життя
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '4bcf3852-7d28-5ceb-80ca-1870222d6834';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 8) then
    raise exception 'A1.7: місце уроку 8 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.7.8'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 61: Здоровий спосіб життя', 'Lekcija 61: Zdrav život', '["Поговорити про спорт і здоров’я", "Порівняти: краще, здоровіше, легше", "Назвати шкідливі й корисні звички"]'::jsonb, 12, 'PUBLISHED', 8);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zdrav život', v_pos);
  v_pos := pg_temp.word(v_lesson, 'teretana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vježbati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'težina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mršaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'debljati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dijeta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'alkohol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pušenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'redovito', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kretanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pravilna prehrana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stres', v_pos);
  v_pos := pg_temp.word(v_lesson, 'navika', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '08d8e2fe-4db3-5b76-939f-f75492e26146', 'fill_in_the_blank', 'Plivanje je ___ od trčanja za koljena.', 'bolje', '["dobar", "bolje", "najbolje", "dobro"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2e791686-db31-5132-a988-eddf6c9a9223', 'multiple_choice', 'Що означає «težina»?', 'вага, складність', '["правильне харчування", "гладшати; набирати вагу", "вага, складність", "регулярно"]'::jsonb, 'A1', 2, 'PUBLISHED', 'težina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '54528659-4171-5e92-9af8-6ce53586b49f', 'multiple_choice', 'Що означає «redovito»?', 'регулярно', '["регулярно", "дієта", "тренуватися; виконувати вправи", "алкоголь"]'::jsonb, 'A1', 3, 'PUBLISHED', 'redovito', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fcfad869-e271-520e-8107-0294aa72c6a4', 'multiple_choice', 'Як хорватською «куріння»?', 'pušenje', '["pravilna prehrana", "pušenje", "težina", "redovito"]'::jsonb, 'A1', 4, 'PUBLISHED', 'pušenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2d38846f-1a23-52e7-85ad-dd33306fc4d1', 'type_answer', 'Напишіть хорватською: «худнути»', 'mršaviti', null, 'A1', 5, 'PUBLISHED', 'mršaviti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e895b508-f7b4-59ad-b581-d18215ad3f37', 'type_answer', 'Напишіть хорватською: «алкоголь»', 'alkohol', null, 'A1', 6, 'PUBLISHED', 'alkohol', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0ca04e6e-13e6-5b29-80f0-cc1cc6128667', 'sentence_builder', 'Складіть: «Я тренуюся тричі на тиждень.»', 'Vježbam tri puta tjedno.', '["tjedno.", "tri", "Vježbam", "puta"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6cfc9df5-36d6-548e-bf99-284610afd1f0', 'sentence_builder', 'Складіть: «Здоровий спосіб життя — це звичка.»', 'Zdrav život je navika.', '["navika.", "je", "život", "Zdrav"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bbbd2c6d-1416-5b5a-b345-bb368add9583', 'listening', 'Прослухайте і складіть фразу', 'Koliko često vježbate?', '["često", "Koliko", "vježbate?"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '47e5642e-ea0b-533e-af78-822f62608eb2', 'listening', 'Прослухайте і складіть фразу', 'Da, ali manje nego prije.', '["ali", "nego", "Da,", "manje", "prije."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e6e56859-cb87-5eec-8c03-c44218afbed3', 'speaking', 'Я хочу схуднути, але не люблю дієт.', 'Želim mršaviti, ali ne volim dijete.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f39077df-8424-5001-9e4c-548d8ba19c3b', 'speaking', 'Як часто ти ходиш у спортзал?', 'Koliko često ideš u teretanu?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7a86a2d0-416c-56f5-b6fa-19cd22bd78f7', v_lesson, 'У спортзалі', 'U teretani', 1611, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('002363ab-a089-5f3b-9df9-c604e276d9b3', '7a86a2d0-416c-56f5-b6fa-19cd22bd78f7', 'Trener', 'Koliko često vježbate?', 'Як часто ви тренуєтеся?', 1);
  perform pg_temp.turn('ebc718c6-8e4e-5512-8523-9ddf5d079a7a', '7a86a2d0-416c-56f5-b6fa-19cd22bd78f7', 'Taras', 'Rijetko. Zimi se debljam.', 'Рідко. Взимку я гладшаю.', 2);
  perform pg_temp.turn('168eef4c-5881-5ed8-8dc8-954ed5a92da3', '7a86a2d0-416c-56f5-b6fa-19cd22bd78f7', 'Trener', 'Dolazite redovito, tri puta tjedno. To je bolje od dijete.', 'Приходьте регулярно, тричі на тиждень. Це краще за дієту.', 3);
  perform pg_temp.turn('fa58d79f-9fab-5419-9581-14dde818193e', '7a86a2d0-416c-56f5-b6fa-19cd22bd78f7', 'Taras', 'A trčanje ili plivanje, što je zdravije?', 'А біг чи плавання — що здоровіше?', 4);
  perform pg_temp.turn('13f2aa8d-78df-5c4d-a0fb-8dd417eca98b', '7a86a2d0-416c-56f5-b6fa-19cd22bd78f7', 'Trener', 'Plivanje je lakše za koljena, a s trčanjem brže mršavite.', 'Плавання легше для колін, а з бігом ви швидше худнете.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d42ce42c-7932-5bbb-8379-aa7c13160396', v_lesson, 'Здорові звички', 'Zdrave navike', 1612, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('c46c0303-6575-565f-979d-5f22d2676980', 'd42ce42c-7932-5bbb-8379-aa7c13160396', 'Liječnica', 'Pušite li?', 'Ви курите?', 1);
  perform pg_temp.turn('4657a632-f8df-5472-af11-ec91ced064eb', 'd42ce42c-7932-5bbb-8379-aa7c13160396', 'Andrij', 'Da, ali manje nego prije.', 'Так, але менше, ніж раніше.', 2);
  perform pg_temp.turn('63b41cab-8b5a-55d4-b2f0-5d551d70cdb6', 'd42ce42c-7932-5bbb-8379-aa7c13160396', 'Liječnica', 'Pušenje i alkohol su najgore navike. Imate li puno stresa?', 'Куріння й алкоголь — найгірші звички. У вас багато стресу?', 3);
  perform pg_temp.turn('66f8d0b0-87c3-53b3-a17e-90dacf2b6ecf', 'd42ce42c-7932-5bbb-8379-aa7c13160396', 'Andrij', 'Imam. I težina mi raste.', 'Так. І вага в мене росте.', 4);
  perform pg_temp.turn('87cae204-152c-5b55-a926-3096e51f3405', 'd42ce42c-7932-5bbb-8379-aa7c13160396', 'Liječnica', 'Važni su pravilna prehrana i kretanje. Hodajte više!', 'Важливі правильне харчування й рух. Ходіть більше!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 62: У педіатра
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '0df023bb-17fb-5006-91bf-3b911dd30295';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 9) then
    raise exception 'A1.7: місце уроку 9 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.7.9'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 62: У педіатра', 'Lekcija 62: Kod pedijatra', '["Описати симптоми дитини педіатрові", "Зрозуміти, як давати ліки", "Назвати дитячі хвороби: висип, пронос, запалення"]'::jsonb, 12, 'PUBLISHED', 9);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'pedijatar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osip', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povraćati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'proljev', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kihati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'curiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nos', v_pos);
  v_pos := pg_temp.word(v_lesson, 'toplomjer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kapi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pregledati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dojenče', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kašljati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mast', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cef6a0aa-4bb3-57d7-9f5c-d9d2e0233f53', 'fill_in_the_blank', '___ joj kapi tri puta dnevno.', 'Dajte', '["Dajem", "Daju", "Dati", "Dajte"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c2de8a5f-3930-55bd-b2a6-f23135811927', 'multiple_choice', 'Що означає «curiti»?', 'текти; протікати', '["текти; протікати", "краплі", "немовля", "ніс"]'::jsonb, 'A1', 2, 'PUBLISHED', 'curiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '521336f2-5002-509b-bc09-e784548191c6', 'multiple_choice', 'Що означає «kihati»?', 'чхати', '["термометр", "пронос; діарея", "чхати", "краплі"]'::jsonb, 'A1', 3, 'PUBLISHED', 'kihati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b8a38a96-f395-53e4-8f0b-0081ee9b8034', 'multiple_choice', 'Як хорватською «педіатр»?', 'pedijatar', '["osip", "pedijatar", "proljev", "kašljati"]'::jsonb, 'A1', 4, 'PUBLISHED', 'pedijatar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9338d735-27e9-521f-8aa5-d1daf67ce657', 'type_answer', 'Напишіть хорватською: «висип»', 'osip', null, 'A1', 5, 'PUBLISHED', 'osip', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '96cee825-5ae8-5775-8c0a-50b9dc1fd8c6', 'type_answer', 'Напишіть хорватською: «запалення»', 'upala', null, 'A1', 6, 'PUBLISHED', 'upala', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f73a4a92-4987-5796-9547-2f4842bf72f0', 'sentence_builder', 'Складіть: «У дитини запалення вуха.»', 'Dijete ima upalu uha.', '["Dijete", "uha.", "ima", "upalu"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '07441fb4-68b5-5d1d-ae36-3c21c1d8cb19', 'sentence_builder', 'Складіть: «У мене тече з носа.»', 'Curi mi nos.', '["mi", "Curi", "nos."]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '138c4dab-b8dc-5505-a7c3-30a56aeb2a29', 'listening', 'Прослухайте і складіть фразу', 'Što da radim?', '["da", "Što", "radim?"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '93f111de-05da-5f31-b7b1-15a00b2639e9', 'listening', 'Прослухайте і складіть фразу', 'Ima li proljev?', '["li", "Ima", "proljev?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '364319f5-0bc5-59d1-920c-c1b8ed7b8e02', 'speaking', 'Мені треба записатися до педіатра.', 'Trebam se naručiti kod pedijatra.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b50815b9-389d-5288-8802-ba82dcf3648a', 'speaking', 'Дитина кашляє вночі.', 'Dijete kašlje noću.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7d6cf353-7b9b-5ab4-9d18-b6199bd75e19', v_lesson, 'Дитина хворіє', 'Dijete je bolesno', 1621, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('d74e4509-f340-532d-81cf-8581b44ec500', '7d6cf353-7b9b-5ab4-9d18-b6199bd75e19', 'Olena', 'Doktorice, mala ima temperaturu i kašlje.', 'Лікарко, мала має температуру й кашляє.', 1);
  perform pg_temp.turn('dc89cf68-2604-548d-9b28-4784129d9f30', '7d6cf353-7b9b-5ab4-9d18-b6199bd75e19', 'Pedijatrica', 'Kolika je temperatura na toplomjeru?', 'Яка температура на термометрі?', 2);
  perform pg_temp.turn('7e0c213a-371e-526d-8c6e-793625122120', '7d6cf353-7b9b-5ab4-9d18-b6199bd75e19', 'Olena', 'Trideset osam. I stalno kiše, curi joj nos.', 'Тридцять вісім. І постійно чхає, у неї тече з носа.', 3);
  perform pg_temp.turn('f8c7da4f-f370-53fe-99cb-8fb958d305ed', '7d6cf353-7b9b-5ab4-9d18-b6199bd75e19', 'Pedijatrica', 'Da je pregledam. Aha, ima upalu uha.', 'Дайте я її огляну. Ага, у неї запалення вуха.', 4);
  perform pg_temp.turn('34fabc7a-81df-56eb-9f4f-8ef3ee1b50c1', '7d6cf353-7b9b-5ab4-9d18-b6199bd75e19', 'Olena', 'Što da radim?', 'Що мені робити?', 5);
  perform pg_temp.turn('464cc062-174d-5216-80b2-ca46f04b49a4', '7d6cf353-7b9b-5ab4-9d18-b6199bd75e19', 'Pedijatrica', 'Dajte joj kapi za uho i sirup. Neka pije puno vode.', 'Давайте їй краплі у вухо і сироп. Нехай п’є багато води.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a8885abb-bdd6-5b7f-8109-104b069b94d5', v_lesson, 'Висип у немовляти', 'Osip kod dojenčeta', 1622, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('2a98f303-8334-51a8-afd4-4852a0d13414', 'a8885abb-bdd6-5b7f-8109-104b069b94d5', 'Taras', 'Naše dojenče ima osip po tijelu.', 'У нашого немовляти висип по тілу.', 1);
  perform pg_temp.turn('279862f5-833d-5f1c-847d-1373807ae828', 'a8885abb-bdd6-5b7f-8109-104b069b94d5', 'Pedijatar', 'Povraća li? Ima li proljev?', 'Він блює? Має пронос?', 2);
  perform pg_temp.turn('2fa178f7-bf1f-51d8-afba-04b6371241e8', 'a8885abb-bdd6-5b7f-8109-104b069b94d5', 'Taras', 'Ne, samo je nemiran i plače.', 'Ні, тільки неспокійний і плаче.', 3);
  perform pg_temp.turn('8185bf8a-5ac2-5c53-820b-12bb9f1f6797', 'a8885abb-bdd6-5b7f-8109-104b069b94d5', 'Pedijatar', 'To je alergija. Stavljajte ovu mast na osip dvaput dnevno.', 'Це алергія. Наносьте цю мазь на висип двічі на день.', 4);
  perform pg_temp.turn('f17b7976-4593-5b05-a358-29a1309132e5', 'a8885abb-bdd6-5b7f-8109-104b069b94d5', 'Taras', 'Hvala, doktore.', 'Дякую, лікарю.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 68: Кохання й стосунки
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '0d0547ed-c0ef-53bd-bfe4-c482c84c40f4';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A1.8: місце уроку 6 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.8.6'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 68: Кохання й стосунки', 'Lekcija 68: Ljubav i veze', '["Поговорити про побачення і стосунки", "Привітати з річницею чи заручинами", "Сказати, чиє: мій, твій, наш"]'::jsonb, 12, 'PUBLISHED', 6);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zaljubiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spoj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljubav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poljubac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zagrljaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vjenčanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaručen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rastati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'partner', v_pos);
  v_pos := pg_temp.word(v_lesson, 'djevojka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zgodan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'romantičan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prsten', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godišnjica', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '4aa28801-011a-5b3e-b8fb-11cc4b04132a', 'fill_in_the_blank', 'Kako je ___ partner?', 'tvoj', '["tvoju", "tvoj", "tvoja", "tvoje"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '470bbabb-db73-5681-a68a-a0355f880cbe', 'multiple_choice', 'Що означає «vjenčanje»?', 'весілля', '["каблучка", "дівчина", "весілля", "річниця"]'::jsonb, 'A1', 2, 'PUBLISHED', 'vjenčanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cea25ef0-cab1-5f3a-85fb-c187b845dd97', 'multiple_choice', 'Що означає «rastati se»?', 'розлучитися; розійтися', '["весілля", "партнер", "гарний (на вигляд); привабливий", "розлучитися; розійтися"]'::jsonb, 'A1', 3, 'PUBLISHED', 'rastati se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '42d9d75d-5379-549f-b82a-0deab95599b2', 'multiple_choice', 'Як хорватською «поцілунок»?', 'poljubac', '["poljubac", "spoj", "prsten", "vjenčanje"]'::jsonb, 'A1', 4, 'PUBLISHED', 'poljubac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '195c9ec9-fe31-59f9-8180-b23322e14a04', 'type_answer', 'Напишіть хорватською: «каблучка»', 'prsten', null, 'A1', 5, 'PUBLISHED', 'prsten', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b840e0e5-c300-5ec8-a31c-85acab1731ae', 'type_answer', 'Напишіть хорватською: «обійми»', 'zagrljaj', null, 'A1', 6, 'PUBLISHED', 'zagrljaj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5f8fd1bb-7ae6-5ad3-98eb-0eca28e32236', 'sentence_builder', 'Складіть: «Це моя дівчина Ана.»', 'Ovo je moja djevojka Ana.', '["moja", "Ovo", "je", "djevojka", "Ana."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd5007eda-78f8-5b67-8939-23f520ab44d9', 'sentence_builder', 'Складіть: «Наше весілля в червні.»', 'Naše vjenčanje je u lipnju.', '["vjenčanje", "je", "lipnju.", "Naše", "u"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f202fc16-36df-5ce0-85a0-4d32f904a501', 'listening', 'Прослухайте і складіть фразу', 'Je li zgodan?', '["li", "Je", "zgodan?"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5c729e83-ef07-50c8-9363-28b730d60dfc', 'listening', 'Прослухайте і складіть фразу', 'Zaručeni smo!', '["smo!", "Zaručeni"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '653c7147-5ea7-57fa-8710-8b5a89828cba', 'speaking', 'Обійми й поцілунок!', 'Zagrljaj i poljubac!', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '31ed7907-ccd5-5d0e-944f-7c04f3509dad', 'speaking', 'Я не хочу з тобою розлучатися.', 'Ne želim se rastati od tebe.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d0418db4-f97c-5684-90c8-5478c14b79d8', v_lesson, 'Побачення', 'Spoj', 1681, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('68240d3d-976b-5230-9d69-0f068087330e', 'd0418db4-f97c-5684-90c8-5478c14b79d8', 'Ana', 'Imaš li večeras spoj?', 'У тебе сьогодні ввечері побачення?', 1);
  perform pg_temp.turn('59c41919-c90c-5592-b325-33e0138a1401', 'd0418db4-f97c-5684-90c8-5478c14b79d8', 'Ivana', 'Imam! S Markom iz teretane.', 'Так! З Марком із спортзалу.', 2);
  perform pg_temp.turn('b19f3f0a-b22f-5273-83cd-ebb66903547f', 'd0418db4-f97c-5684-90c8-5478c14b79d8', 'Ana', 'Je li zgodan?', 'Він гарний?', 3);
  perform pg_temp.turn('e901f5b1-a363-5a2a-bf0b-7d6dd4a1fda9', 'd0418db4-f97c-5684-90c8-5478c14b79d8', 'Ivana', 'Jako. I romantičan je, vodi me na večeru uz more.', 'Дуже. І романтичний, веде мене на вечерю біля моря.', 4);
  perform pg_temp.turn('ac618649-b703-5679-be62-2328f26a73c0', 'd0418db4-f97c-5684-90c8-5478c14b79d8', 'Ana', 'Mislim da se zaljubljuješ!', 'Думаю, ти закохуєшся!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e77d91be-a380-50e9-94cb-b0d4430e2e97', v_lesson, 'Річниця', 'Godišnjica', 1682, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('05c77bc5-6c6f-587d-bf6c-a8692d34625a', 'e77d91be-a380-50e9-94cb-b0d4430e2e97', 'Olena', 'Sutra nam je godišnjica braka. Deset godina!', 'Завтра в нас річниця шлюбу. Десять років!', 1);
  perform pg_temp.turn('f03c1068-0c91-5541-b1ae-e80312913a5d', 'e77d91be-a380-50e9-94cb-b0d4430e2e97', 'Marija', 'Čestitam! Što ti tvoj muž kupuje?', 'Вітаю! Що тобі купує твій чоловік?', 2);
  perform pg_temp.turn('74c47862-8f18-50a4-b0a1-dcbe828917f0', 'e77d91be-a380-50e9-94cb-b0d4430e2e97', 'Olena', 'Ne znam. Možda prsten. A kako je tvoj partner?', 'Не знаю. Може, каблучку. А як твій партнер?', 3);
  perform pg_temp.turn('2a8074c1-131a-52f3-9773-c865743de7b1', 'e77d91be-a380-50e9-94cb-b0d4430e2e97', 'Marija', 'Dobro. Zaručeni smo! Vjenčanje je u lipnju.', 'Добре. Ми заручені! Весілля в червні.', 4);
  perform pg_temp.turn('5c9672e2-ae58-5e40-b361-e6fd621295c4', 'e77d91be-a380-50e9-94cb-b0d4430e2e97', 'Olena', 'Divno! Ljubav je najvažnija.', 'Чудово! Кохання найважливіше.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 69: Спорт і матчі
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'e61e3942-cd86-5f75-9eb5-d878242125bf';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A1.8: місце уроку 7 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.8.7'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 69: Спорт і матчі', 'Lekcija 69: Sport i utakmice', '["Поговорити про футбол і спорт", "Записатися на тренування", "Назвати види спорту"]'::jsonb, 12, 'PUBLISHED', 7);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'trener', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trening', v_pos);
  v_pos := pg_temp.word(v_lesson, 'utakmica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'momčad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'navijati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pobijediti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izgubiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'košarka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tenis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odbojka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rukomet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'igrač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lopta', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f9bff30b-4dc8-5bbc-8d8e-aa8685c00538', 'fill_in_the_blank', 'Za koga ___ ti?', 'navijaš', '["navijaju", "navija", "navijam", "navijaš"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a921491b-e822-5a37-87ab-8104fa15f099', 'multiple_choice', 'Що означає «gol»?', 'гол', '["команда (спортивна)", "м''яч", "гол", "перемогти"]'::jsonb, 'A1', 2, 'PUBLISHED', 'gol', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5353d4a8-3fc4-5b7d-bc58-54be772551cd', 'multiple_choice', 'Що означає «izgubiti»?', 'загубити; втратити; програти', '["волейбол", "гандбол", "баскетбол", "загубити; втратити; програти"]'::jsonb, 'A1', 3, 'PUBLISHED', 'izgubiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '24b78fff-7ba6-54c5-ad1b-73162d7039fc', 'multiple_choice', 'Як хорватською «волейбол»?', 'odbojka', '["odbojka", "izgubiti", "trening", "pobijediti"]'::jsonb, 'A1', 4, 'PUBLISHED', 'odbojka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8e368f16-2313-5a6b-a006-2893ff99c792', 'type_answer', 'Напишіть хорватською: «гандбол»', 'rukomet', null, 'A1', 5, 'PUBLISHED', 'rukomet', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7a104bae-ea1c-57da-8444-c660f77c5a60', 'type_answer', 'Напишіть хорватською: «гравець»', 'igrač', null, 'A1', 6, 'PUBLISHED', 'igrač', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6acb416f-4d33-52e0-8858-bc00295c59e4', 'sentence_builder', 'Складіть: «Хорватія сильна в гандболі.»', 'Hrvatska je jaka u rukometu.', '["Hrvatska", "rukometu.", "jaka", "u", "je"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ef782773-0589-52e1-9a45-c0efd3f7b2e9', 'sentence_builder', 'Складіть: «Мій брат грає в теніс.»', 'Moj brat igra tenis.', '["Moj", "igra", "tenis.", "brat"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7f084565-a2bd-594b-b71a-56e46a46dd86', 'listening', 'Прослухайте і складіть фразу', 'Za Hajduk, naravno!', '["Za", "naravno!", "Hajduk,"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8f58dabd-4f09-5f1d-95f5-226de1bf8381', 'listening', 'Прослухайте і складіть фразу', 'Trebam li svoju loptu?', '["svoju", "loptu?", "li", "Trebam"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8c9ef66d-25f5-597a-a331-0c245afbd3c5', 'speaking', 'Ми не хочемо програти.', 'Ne želimo izgubiti.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ffd106b7-7aab-5eed-8a86-efe69154a625', 'speaking', 'Який гарний гол!', 'Kakav lijep gol!', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1afbd1c9-836a-5b71-8a70-444b5524c58c', v_lesson, 'За кого вболіваєш?', 'Za koga navijaš?', 1691, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('3cb29c80-1e4f-5f50-b2cf-4f737f2af463', '1afbd1c9-836a-5b71-8a70-444b5524c58c', 'Marko', 'Večeras je utakmica. Za koga navijaš?', 'Сьогодні ввечері матч. За кого ти вболіваєш?', 1);
  perform pg_temp.turn('3cd1635e-2566-5354-af34-9b92b5b8d225', '1afbd1c9-836a-5b71-8a70-444b5524c58c', 'Taras', 'Za Hajduk, naravno! A ti?', 'За «Хайдук», звісно! А ти?', 2);
  perform pg_temp.turn('c54657c7-28d2-595d-8ef1-b21d04c6d16b', '1afbd1c9-836a-5b71-8a70-444b5524c58c', 'Marko', 'Ja za Dinamo. Mislim da Dinamo danas pobjeđuje.', 'Я за «Динамо». Думаю, «Динамо» сьогодні переможе.', 3);
  perform pg_temp.turn('996e9073-0e92-5e3c-af8c-dc9fe86a2ebd', '1afbd1c9-836a-5b71-8a70-444b5524c58c', 'Taras', 'Nema šanse! Hajduk ima bolju momčad.', 'Без шансів! У «Хайдука» краща команда.', 4);
  perform pg_temp.turn('39e74f07-c4ce-5486-9d50-0f3be7315d7d', '1afbd1c9-836a-5b71-8a70-444b5524c58c', 'Marko', 'Dobro, gledamo zajedno u kafiću?', 'Добре, дивимося разом у кафе?', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3303dd86-ad51-5ffc-872a-eb5b3f578cb4', v_lesson, 'Тренування', 'Trening', 1692, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('3e21f118-8784-56a4-9aa0-ab4b0f760a16', '3303dd86-ad51-5ffc-872a-eb5b3f578cb4', 'Trener', 'Dobro došao! Igraš li rukomet?', 'Ласкаво просимо! Ти граєш у гандбол?', 1);
  perform pg_temp.turn('bc8e68b9-b62e-5b2c-ba7a-f74fe9ca1653', '3303dd86-ad51-5ffc-872a-eb5b3f578cb4', 'Danilo', 'Ne, igram košarku i odbojku.', 'Ні, я граю в баскетбол і волейбол.', 2);
  perform pg_temp.turn('facf8f1f-4d17-5eeb-91f8-71ad625c6ba4', '3303dd86-ad51-5ffc-872a-eb5b3f578cb4', 'Trener', 'Nema veze. Trening je utorkom i četvrtkom.', 'Нічого страшного. Тренування по вівторках і четвергах.', 3);
  perform pg_temp.turn('a6033e2d-df32-5712-b17f-477a05ecd70f', '3303dd86-ad51-5ffc-872a-eb5b3f578cb4', 'Danilo', 'Trebam li svoju loptu?', 'Мені потрібен свій м’яч?', 4);
  perform pg_temp.turn('2613a86e-7930-54db-80cd-106f857515b7', '3303dd86-ad51-5ffc-872a-eb5b3f578cb4', 'Trener', 'Ne. Svaki igrač dobiva dres i loptu.', 'Ні. Кожен гравець отримує форму і м’яч.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- 4. Наскрізні номери всіх уроків A1 («Урок N: …» / «Lekcija N: …») за модулем і місцем; стара назва — у content_versions
do $$
declare r record; v_payload jsonb; v_ua text; v_hr text;
begin
  for r in
    select l.id, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where m.level_code = 'A1' and l.status <> 'DEPRECATED'
  loop
    select to_jsonb(l), regexp_replace(l.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':'),
           regexp_replace(l.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':')
      into v_payload, v_ua, v_hr
      from public.lessons l where l.id = r.id;
    if v_ua is not distinct from (v_payload->>'title_ua') and v_hr is not distinct from (v_payload->>'title_hr') then continue; end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'curriculum_a1_v2: новий номер уроку ' || r.n);
    update public.lessons set title_ua = v_ua, title_hr = v_hr where id = r.id;
  end loop;
end $$;

-- 5. Самоперевірка частини 3: якщо щось не так — уся частина відкочується
do $$
declare v_new int; v_short int; v_scenes int; v_words int; v_total int; v_bad_titles int;
begin
  select count(*) into v_new from public.lessons where id in ('b369f01f-4a84-57b4-98cb-150d236f4d7f', 'c9b87882-5e31-5485-aea7-0169216466a8', '2c56a486-dbbb-5102-b7cb-754c59cf94c3', 'ee016ba8-5160-581d-b440-1bcb7647173d', 'd5dee6c5-f510-57b9-a1ed-4b0a60e8e09a', '293af384-4ee2-5746-80a8-e8ffdc7009bc', '4bcf3852-7d28-5ceb-80ca-1870222d6834', '0df023bb-17fb-5006-91bf-3b911dd30295', '0d0547ed-c0ef-53bd-bfe4-c482c84c40f4', 'e61e3942-cd86-5f75-9eb5-d878242125bf') and status = 'PUBLISHED';
  select count(*) into v_short from public.lessons l where l.id in ('b369f01f-4a84-57b4-98cb-150d236f4d7f', 'c9b87882-5e31-5485-aea7-0169216466a8', '2c56a486-dbbb-5102-b7cb-754c59cf94c3', 'ee016ba8-5160-581d-b440-1bcb7647173d', 'd5dee6c5-f510-57b9-a1ed-4b0a60e8e09a', '293af384-4ee2-5746-80a8-e8ffdc7009bc', '4bcf3852-7d28-5ceb-80ca-1870222d6834', '0df023bb-17fb-5006-91bf-3b911dd30295', '0d0547ed-c0ef-53bd-bfe4-c482c84c40f4', 'e61e3942-cd86-5f75-9eb5-d878242125bf')
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') < 12;
  select count(*) into v_scenes from public.lessons l where l.id in ('b369f01f-4a84-57b4-98cb-150d236f4d7f', 'c9b87882-5e31-5485-aea7-0169216466a8', '2c56a486-dbbb-5102-b7cb-754c59cf94c3', 'ee016ba8-5160-581d-b440-1bcb7647173d', 'd5dee6c5-f510-57b9-a1ed-4b0a60e8e09a', '293af384-4ee2-5746-80a8-e8ffdc7009bc', '4bcf3852-7d28-5ceb-80ca-1870222d6834', '0df023bb-17fb-5006-91bf-3b911dd30295', '0d0547ed-c0ef-53bd-bfe4-c482c84c40f4', 'e61e3942-cd86-5f75-9eb5-d878242125bf')
     and (select count(*) from public.conversations c where c.lesson_id = l.id) < 2;
  select count(*) into v_words from public.lessons l where l.id in ('b369f01f-4a84-57b4-98cb-150d236f4d7f', 'c9b87882-5e31-5485-aea7-0169216466a8', '2c56a486-dbbb-5102-b7cb-754c59cf94c3', 'ee016ba8-5160-581d-b440-1bcb7647173d', 'd5dee6c5-f510-57b9-a1ed-4b0a60e8e09a', '293af384-4ee2-5746-80a8-e8ffdc7009bc', '4bcf3852-7d28-5ceb-80ca-1870222d6834', '0df023bb-17fb-5006-91bf-3b911dd30295', '0d0547ed-c0ef-53bd-bfe4-c482c84c40f4', 'e61e3942-cd86-5f75-9eb5-d878242125bf')
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'lexeme') < 12;
  select count(*) into v_total from public.lessons where level_code = 'A1' and status = 'PUBLISHED';
  select count(*) into v_bad_titles from (
    select l.title_ua, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where m.level_code = 'A1' and l.status <> 'DEPRECATED') t
   where t.title_ua not like 'Урок ' || t.n || ':%';
  if v_new <> 10 then raise exception 'Частина 3: створено % уроків з 10', v_new; end if;
  if v_short > 0 then raise exception 'Частина 3: % уроків мають менше 12 вправ', v_short; end if;
  if v_scenes > 0 then raise exception 'Частина 3: % уроків без двох діалогів', v_scenes; end if;
  if v_words > 0 then raise exception 'Частина 3: % уроків мають менше 12 слів', v_words; end if;
  if v_bad_titles > 0 then raise exception 'Частина 3: % назв уроків A1 не за порядком', v_bad_titles; end if;
  raise notice 'Готово: частина 3 — 10 нових уроків; усього уроків A1 — %', v_total;
end $$;

commit;
