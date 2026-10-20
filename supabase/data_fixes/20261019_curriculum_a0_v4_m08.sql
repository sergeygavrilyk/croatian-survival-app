-- =====================================================================
-- Уроки A0 за темою · curriculum_a0_v4 · модуль A0.8 · 2026-10-19
-- Згенеровано: python3 scripts/gen_curriculum_a0_v4.py (не редагуйте вручну).
--
-- Рішення власника 2026-10-15: слова уроку — за темою уроку, 20–25 слів і виразів, діалоги під тему; бета (PUBLISHED).
--   * Уроки 49–54: 5 наявних перебудовано, 1 нових тематичних уроків. Слів у них: 131.
--     Кожен: 20–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 36.
--   * Нові теми граматики: «Дешевше чи дорожче? Порівняння».
--   * Новий порядок уроків у модулі; назви всіх уроків A0 перенумеровано підряд (разом 64).
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
values ('šljiva', 'sljiva', 'hr', 'noun', 'A0', 'слива', 'core', '{"gender": "f"}'::jsonb, '["Ove šljive su jako slatke."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('krastavac', 'krastavac', 'hr', 'noun', 'A0', 'огірок', 'core', '{"gender": "m"}'::jsonb, '["Za salatu trebam krastavac i rajčicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pola kile', 'pola kile', 'hr', 'phrase', 'A0', 'пів кілограма', 'chunk', '{}'::jsonb, '["Dajte mi pola kile sira."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('limenka', 'limenka', 'hr', 'noun', 'A0', 'бляшанка, (металева) банка', 'core', '{"gender": "f"}'::jsonb, '["Kupi dvije limenke graha."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('staklenka', 'staklenka', 'hr', 'noun', 'A0', 'скляна банка', 'core', '{"gender": "f"}'::jsonb, '["U staklenci je domaći med."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('narezati', 'narezati', 'hr', 'verb', 'A0', 'нарізати', 'core', '{"aspect": "pf", "present": {"1s": "narežem", "2s": "narežeš", "3s": "nareže"}, "past": "narezao"}'::jsonb, '["Možete li mi narezati šunku?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('još nešto', 'jos nesto', 'hr', 'phrase', 'A0', 'ще щось?', 'formulaic', '{}'::jsonb, '["Još nešto? — Ne, hvala, to je sve."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('to je sve', 'to je sve', 'hr', 'phrase', 'A0', 'це все', 'formulaic', '{}'::jsonb, '["To je sve, hvala."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('samoposlužna blagajna', 'samoposluzna blagajna', 'hr', 'phrase', 'A0', 'каса самообслуговування', 'collocation', '{"gender": "f"}'::jsonb, '["Platila sam na samoposlužnoj blagajni."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kupovina', 'kupovina', 'hr', 'noun', 'A0', 'покупки, шопінг; купівля', 'core', '{"gender": "f"}'::jsonb, '["Subotom idemo u kupovinu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('beskontaktno', 'beskontaktno', 'hr', 'adverb', 'A0', 'безконтактно (про оплату карткою)', 'core', '{}'::jsonb, '["Možete platiti beskontaktno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('podići novac', 'podici novac', 'hr', 'phrase', 'A0', 'зняти гроші (з рахунку, у банкоматі)', 'collocation', '{}'::jsonb, '["Moram podići novac na bankomatu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('trebate li vrećicu', 'trebate li vrecicu', 'hr', 'phrase', 'A0', 'вам потрібен пакет?', 'formulaic', '{}'::jsonb, '["Trebate li vrećicu? — Ne, hvala, imam torbu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pristajati', 'pristajati', 'hr', 'verb', 'A0', 'пасувати, личити; підходити за розміром', 'core', '{"aspect": "ipf", "present": {"1s": "pristajem", "2s": "pristaješ", "3s": "pristaje"}, "past": "pristajao"}'::jsonb, '["Ova haljina ti jako pristaje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prevelik', 'prevelik', 'hr', 'adjective', 'A0', 'завеликий', 'core', '{"f": "prevelika", "n": "preveliko"}'::jsonb, '["Ove cipele su mi prevelike."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('premalen', 'premalen', 'hr', 'adjective', 'A0', 'замалий', 'core', '{"f": "premalena", "n": "premaleno"}'::jsonb, '["Jakna mi je premalena."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kakve je boje', 'kakve je boje', 'hr', 'phrase', 'A0', 'якого (воно) кольору?', 'formulaic', '{}'::jsonb, '["Kakve je boje tvoj auto?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tamnoplav', 'tamnoplav', 'hr', 'adjective', 'A0', 'темно-синій', 'core', '{"f": "tamnoplava", "n": "tamnoplavo"}'::jsonb, '["Nosi tamnoplavo odijelo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('svijetloplav', 'svijetloplav', 'hr', 'adjective', 'A0', 'блакитний, світло-синій', 'core', '{"f": "svijetloplava", "n": "svijetloplavo"}'::jsonb, '["Kupila sam svijetloplavu košulju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bež', 'bez', 'hr', 'adjective', 'A0', 'бежевий', 'core', '{"indeclinable": true}'::jsonb, '["Tražim bež kaput."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zlatan', 'zlatan', 'hr', 'adjective', 'A0', 'золотий; золотистий', 'core', '{"f": "zlatna", "n": "zlatno"}'::jsonb, '["Na ruci nosi zlatni sat."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('srebrn', 'srebrn', 'hr', 'adjective', 'A0', 'срібний; сріблястий', 'core', '{"f": "srebrna", "n": "srebrno"}'::jsonb, '["Imam srebrni mobitel."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('na pruge', 'na pruge', 'hr', 'phrase', 'A0', 'у смужку', 'chunk', '{}'::jsonb, '["Sviđa mi se ova majica na pruge."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('na točkice', 'na tockice', 'hr', 'phrase', 'A0', 'у горошок', 'chunk', '{}'::jsonb, '["Kupila je haljinu na točkice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jeftiniji', 'jeftiniji', 'hr', 'adjective', 'A0', 'дешевший', 'core', '{"f": "jeftinija", "n": "jeftinije", "positive": "jeftin"}'::jsonb, '["Ovaj mobitel je jeftiniji od onoga."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('skuplji', 'skuplji', 'hr', 'adjective', 'A0', 'дорожчий', 'core', '{"f": "skuplja", "n": "skuplje", "positive": "skup"}'::jsonb, '["Kava je ovdje skuplja nego u gradu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jeftinije', 'jeftinije', 'hr', 'adverb', 'A0', 'дешевше', 'core', '{}'::jsonb, '["Na tržnici je jeftinije."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('skuplje', 'skuplje', 'hr', 'adverb', 'A0', 'дорожче', 'core', '{}'::jsonb, '["Ljeti je na moru sve skuplje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zadnja cijena', 'zadnja cijena', 'hr', 'phrase', 'A0', 'остання (кінцева) ціна', 'collocation', '{"gender": "f"}'::jsonb, '["Dvadeset eura, to je zadnja cijena."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('spustiti cijenu', 'spustiti cijenu', 'hr', 'phrase', 'A0', 'знизити ціну, скинути ціну', 'collocation', '{}'::jsonb, '["Možete li spustiti cijenu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ponuditi', 'ponuditi', 'hr', 'verb', 'A0', 'запропонувати', 'core', '{"aspect": "pf", "present": {"1s": "ponudim", "2s": "ponudiš", "3s": "ponudi"}, "past": "ponudio"}'::jsonb, '["Ponudila sam mu pedeset eura."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dogovoreno', 'dogovoreno', 'hr', 'phrase', 'A0', 'домовилися!; гаразд', 'formulaic', '{}'::jsonb, '["Sutra u pet? — Dogovoreno!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('cjenkati se', 'cjenkati se', 'hr', 'verb', 'A0', 'торгуватися (про ціну)', 'core', '{"aspect": "ipf", "present": {"1s": "cjenkam se", "2s": "cjenkaš se", "3s": "cjenka se"}, "past": "cjenkao se"}'::jsonb, '["Na buvljaku se možete cjenkati."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rabljen', 'rabljen', 'hr', 'adjective', 'A0', 'вживаний, б/в', 'core', '{"f": "rabljena", "n": "rabljeno"}'::jsonb, '["Kupili smo rabljeni auto."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('buvljak', 'buvljak', 'hr', 'noun', 'A0', 'блошиний ринок, барахолка', 'core', '{"gender": "m"}'::jsonb, '["Nedjeljom idemo na buvljak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('isplatiti se', 'isplatiti se', 'hr', 'verb', 'A0', 'бути вигідним, окупатися', 'core', '{"aspect": "pf", "present": {"3s": "isplati se"}, "past": "isplatilo se"}'::jsonb, '["Ova ponuda se stvarno isplati."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;

-- 1а. Нові теми граматики A0 (1)
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'd7393ee2-ff00-575d-9c1c-04cabaeeca3c', 'A0', 'Дешевше чи дорожче? Порівняння', 'Komparativ: jeftiniji, skuplji', 'Як порівняти ціни й речі: jeftiniji / skuplji, jeftinije / skuplje, nego і od, найвищий ступінь з naj-.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Дешевше чи дорожче? Порівняння');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '24aa41f7-618f-5d90-af23-823273bee990', 'd7393ee2-ff00-575d-9c1c-04cabaeeca3c', 'Дешевший, дорожчий: -iji і -ji', 'Вищий ступінь прикметника найчастіше має закінчення -iji: jeftin → jeftiniji, nov → noviji, star → stariji. Деякі прикметники мають -ji і змінюють приголосний: skup → skuplji, drag → draži, tih → tiši. Неправильні: dobar → bolji, loš → gori, velik → veći, mali → manji. Як і звичайний прикметник, він узгоджується з іменником: jeftiniji kaput, jeftinija jakna, jeftinije odijelo.', 'jeftin → jeftiniji · skup → skuplji · dobar → bolji', '[{"hr": "Ova jakna je skuplja.", "ua": "Ця куртка дорожча."}, {"hr": "Trebam veću veličinu.", "ua": "Мені потрібен більший розмір."}, {"hr": "Ovaj model je bolji.", "ua": "Ця модель краща."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = 'd7393ee2-ff00-575d-9c1c-04cabaeeca3c')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '0541d6a3-7499-5a1c-bbe2-e255ea2c2b7d', 'd7393ee2-ff00-575d-9c1c-04cabaeeca3c', 'Дешевше, дорожче, більше', 'Коли порівнюємо не річ, а ціну чи дію загалом, уживаємо форму на -e (як прислівник): jeftinije, skuplje, bolje, više, manje. Može li jeftinije? — Можна дешевше?', 'Može li jeftinije?', '[{"hr": "Može li malo jeftinije?", "ua": "Можна трохи дешевше?"}, {"hr": "Na tržnici je jeftinije.", "ua": "На ринку дешевше."}, {"hr": "Ne mogu platiti više.", "ua": "Я не можу заплатити більше."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = 'd7393ee2-ff00-575d-9c1c-04cabaeeca3c')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'e7db03d3-bb52-5e73-8fd4-843d135837ec', 'd7393ee2-ff00-575d-9c1c-04cabaeeca3c', 'Ніж: nego або od', 'Українське «ніж» / «за» — це nego (слово після нього не змінюється) або od + родовий відмінок. Обидва варіанти правильні: jeftiniji nego novi = jeftiniji od novog.', 'jeftiniji nego novi · jeftiniji od novog', '[{"hr": "Rabljeni bicikl je jeftiniji od novog.", "ua": "Вживаний велосипед дешевший за новий."}, {"hr": "Na buvljaku je jeftinije nego u trgovini.", "ua": "На блошиному ринку дешевше, ніж у магазині."}, {"hr": "Jakna je skuplja od majice.", "ua": "Куртка дорожча за футболку."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = 'd7393ee2-ff00-575d-9c1c-04cabaeeca3c')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '37f85a19-fd5c-5ac3-bde3-4b946c1fda73', 'd7393ee2-ff00-575d-9c1c-04cabaeeca3c', 'Найдешевший: naj-', 'Найвищий ступінь — naj- + вищий ступінь: najjeftiniji, najskuplji, najbolji, najveći.', 'najjeftiniji · najskuplji · najbolji', '[{"hr": "Koji je najjeftiniji?", "ua": "Який найдешевший?"}, {"hr": "Ovo je najbolja cijena.", "ua": "Це найкраща ціна."}, {"hr": "Uzimam najmanju veličinu.", "ua": "Беру найменший розмір."}]'::jsonb, 4
where exists (select 1 from public.grammar_topics where id = 'd7393ee2-ff00-575d-9c1c-04cabaeeca3c')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', 'd7393ee2-ff00-575d-9c1c-04cabaeeca3c', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нова тема граматики A0 для уроків за темою (curriculum_a0_v4) за запитом власника 2026-10-19. Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = 'd7393ee2-ff00-575d-9c1c-04cabaeeca3c')
  and not exists (select 1 from public.content_reviews where entity_id = 'd7393ee2-ff00-575d-9c1c-04cabaeeca3c' and notes = 'Бета: нова тема граматики A0 для уроків за темою (curriculum_a0_v4) за запитом власника 2026-10-19. Потрібна перевірка носієм.');

-- 2. Перебудова наявних уроків модуля A0.8
-- A0.8 · урок 49: На ринку — перебудова: 24 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «На ринку» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '36c7cb7f-a7ea-5840-930c-bc27a15a5420') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 49: На ринку', title_hr = 'Lekcija 49: Na tržnici',
         objectives = '["Назвати фрукти й овочі", "Купити на ринку: «Koliko košta kila?», «Dajte mi…»", "Запитати, чи товар свіжий, стиглий і домашній"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'tržnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'voće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povrće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jabuka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kruška', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šljiva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'breskva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'banana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naranča', v_pos);
  v_pos := pg_temp.word(v_lesson, 'limun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jagoda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grožđe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lubenica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rajčica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krastavac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krumpir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'luk', v_pos);
  v_pos := pg_temp.word(v_lesson, 'češnjak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'paprika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mrkva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupus', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zreo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svjež', v_pos);
  v_pos := pg_temp.word(v_lesson, 'domaći', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '8e14902f-ebe5-5904-84c5-e2329f45236c', 'fill_in_the_blank', 'Breskve su jako ___.', 'slatke', '["sladak", "slatka", "slatko", "slatke"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e9395514-c51c-500e-b7ec-36191104104b', 'multiple_choice', 'Що означає «naranča»?', 'апельсин', '["домашній", "апельсин", "перець (овоч)", "картопля"]'::jsonb, 'A0', 2, 'PUBLISHED', 'naranča', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b28cff0-a383-5959-b8e6-6f7810f787c8', 'multiple_choice', 'Що означає «mrkva»?', 'морква', '["перець (овоч)", "виноград", "морква", "картопля"]'::jsonb, 'A0', 3, 'PUBLISHED', 'mrkva', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9cd7fad9-3009-5a34-9548-d19bfecb988f', 'multiple_choice', 'Що означає «kupus»?', 'капуста', '["помідор", "банан", "овочі", "капуста"]'::jsonb, 'A0', 4, 'PUBLISHED', 'kupus', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd96b71e7-6989-562f-8d16-963f58c5da5e', 'multiple_choice', 'Як хорватською «овочі»?', 'povrće', '["jagoda", "šljiva", "domaći", "povrće"]'::jsonb, 'A0', 5, 'PUBLISHED', 'povrće', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0b8a6746-4533-51c8-a8d8-64bcaea789bf', 'multiple_choice', 'Як хорватською «часник»?', 'češnjak', '["češnjak", "krumpir", "šljiva", "tržnica"]'::jsonb, 'A0', 6, 'PUBLISHED', 'češnjak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c6ce7fe9-2d45-5885-b1ee-02f9cc6f7f30', 'type_answer', 'Напишіть хорватською: «кавун»', 'lubenica', null, 'A0', 7, 'PUBLISHED', 'lubenica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '01186a1d-af05-5a31-96e1-bd37a1058f82', 'type_answer', 'Напишіть хорватською: «перець (овоч)»', 'paprika', null, 'A0', 8, 'PUBLISHED', 'paprika', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3ba6a490-c4e9-5165-b549-4f549104f268', 'type_answer', 'Напишіть хорватською: «огірок»', 'krastavac', null, 'A0', 9, 'PUBLISHED', 'krastavac', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e81036f6-7192-5530-b340-065060f98cb3', 'sentence_builder', 'Складіть: «Скільки коштує кілограм?»', 'Koliko košta kila?', '["kila?", "Koliko", "košta"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7a065525-ffe2-5a60-83ea-4c12f8348cca', 'sentence_builder', 'Складіть: «Мені потрібні овочі на суп.»', 'Trebam povrće za juhu.', '["Trebam", "juhu.", "za", "povrće"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c6fb0a4a-acc8-5807-be41-10097d0137a8', 'listening', 'Прослухайте і складіть фразу', 'Jesu li domaće?', '["li", "Jesu", "domaće?"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '28547f36-53e0-584a-ba03-170ab238c46a', 'listening', 'Прослухайте і складіть фразу', 'Imam mrkvu, krumpir, luk i kupus.', '["i", "kupus.", "mrkvu,", "luk", "krumpir,", "Imam"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dc954c67-6b26-576e-87c2-f1a41d1dffce', 'speaking', 'Це свіже?', 'Je li ovo svježe?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3185760b-b021-54b3-b692-42625066d2b0', 'speaking', 'Кілограм помідорів, будь ласка.', 'Kilu rajčica, molim.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('36c7cb7f-a7ea-5840-930c-bc27a15a5420', v_lesson, 'Біля прилавка з фруктами', 'Na štandu s voćem', 2491, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('ee2c3268-2cba-528a-b85e-82f49af9de9e', '36c7cb7f-a7ea-5840-930c-bc27a15a5420', 'Prodavačica', 'Izvolite, gospođo! Jabuke su danas jako dobre.', 'Прошу, пані! Яблука сьогодні дуже добрі.', 1);
  perform pg_temp.turn('afd232a8-399c-5d85-95a3-976c08d98419', '36c7cb7f-a7ea-5840-930c-bc27a15a5420', 'Daša', 'Jesu li domaće?', 'Вони домашні?', 2);
  perform pg_temp.turn('7c7158cb-88cc-5f7a-af47-3c8c82e17523', '36c7cb7f-a7ea-5840-930c-bc27a15a5420', 'Prodavačica', 'Jesu, iz Slavonije. Probajte jednu.', 'Так, зі Славонії. Скуштуйте одне.', 3);
  perform pg_temp.turn('3d7f7989-1850-523a-80af-b8df228d7404', '36c7cb7f-a7ea-5840-930c-bc27a15a5420', 'Daša', 'Stvarno su slatke. Koliko košta kila?', 'Справді солодкі. Скільки коштує кілограм?', 4);
  perform pg_temp.turn('86e6dd2c-1060-53b1-8fa8-254ec0b264b6', '36c7cb7f-a7ea-5840-930c-bc27a15a5420', 'Prodavačica', 'Dva eura. Imam i svježe jagode.', 'Два євро. Є ще свіжа полуниця.', 5);
  perform pg_temp.turn('a9a83211-7634-5722-90ac-944ba0360a37', '36c7cb7f-a7ea-5840-930c-bc27a15a5420', 'Daša', 'Dajte mi kilu jabuka, molim.', 'Дайте мені кілограм яблук, будь ласка.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b8593734-3524-5ede-a730-fdb4f298e40d', v_lesson, 'Овочі на суп', 'Povrće za juhu', 2492, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('f3f3b5d4-e194-5cb7-a570-0b7f8ff41a5a', 'b8593734-3524-5ede-a730-fdb4f298e40d', 'Darja', 'Dobar dan, trebam povrće za juhu.', 'Добрий день, мені потрібні овочі на суп.', 1);
  perform pg_temp.turn('54d5c6a2-fbc5-54f8-b78d-664928992d20', 'b8593734-3524-5ede-a730-fdb4f298e40d', 'Prodavač', 'Imam mrkvu, krumpir, luk i kupus.', 'Є морква, картопля, цибуля й капуста.', 2);
  perform pg_temp.turn('715222a9-e8a2-5a34-8b2e-fb7e4c1da50a', 'b8593734-3524-5ede-a730-fdb4f298e40d', 'Darja', 'Dajte mi dvije mrkve, jedan luk i kilu krumpira.', 'Дайте мені дві морквини, одну цибулину й кілограм картоплі.', 3);
  perform pg_temp.turn('16cb5d6b-bda2-50d5-9ac1-d850af3a0a8c', 'b8593734-3524-5ede-a730-fdb4f298e40d', 'Prodavač', 'Još nešto? Rajčice su danas jako zrele.', 'Ще щось? Помідори сьогодні дуже стиглі.', 4);
  perform pg_temp.turn('74bd8ff5-1c2d-50b4-bfdc-1a4e4100a410', 'b8593734-3524-5ede-a730-fdb4f298e40d', 'Darja', 'Može pola kile rajčica i malo češnjaka.', 'Можна пів кіло помідорів і трохи часнику.', 5);
  perform pg_temp.turn('c8742573-08a1-597e-9a5a-96cb7036d345', 'b8593734-3524-5ede-a730-fdb4f298e40d', 'Prodavač', 'Izvolite. Ukupno pet eura.', 'Прошу. Разом п’ять євро.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.8 · урок 50: Скільки вам? — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '0e925295-2766-5931-b031-2412682bc6f8';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Скільки вам?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '04b5f1e7-2937-5a33-83f3-d94a027376e4') then return; end if;  -- уже перебудовано
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
  if v_gid is null then select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Цей, той, он той: ovaj, taj, onaj' and status = 'PUBLISHED' order by created_at limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 50: Скільки вам?', title_hr = 'Lekcija 50: Koliko trebate?',
         objectives = '["Назвати магазини: pekara, mesnica, supermarket", "Попросити потрібну кількість: deset deka, pola kile, komad, litra", "Купити в м’ясній лавці й сказати «Це все»"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'trgovina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'supermarket', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pekara', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mesnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kilogram', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kila', v_pos);
  v_pos := pg_temp.word(v_lesson, 'deka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pola kile', v_pos);
  v_pos := pg_temp.word(v_lesson, 'litra', v_pos);
  v_pos := pg_temp.word(v_lesson, 'komad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pakiranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'limenka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'staklenka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šunka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'salama', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kobasica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mljeveno meso', v_pos);
  v_pos := pg_temp.word(v_lesson, 'narezati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'još nešto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'to je sve', v_pos);
  v_pos := pg_temp.word(v_lesson, 'popis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dosta', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '084541d9-2162-564a-bf15-b619ca72d071', 'fill_in_the_blank', 'Želite li ovaj sir ili ___ tamo?', 'onaj', '["ono", "ona", "onaj", "oni"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2873d687-f4dc-5e43-9cb5-e5eee0382fa5', 'multiple_choice', 'Що означає «staklenka»?', 'скляна банка', '["десять грамів (у кількостях: deset deka = 100 г)", "пів кілограма", "пекарня", "скляна банка"]'::jsonb, 'A0', 2, 'PUBLISHED', 'staklenka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8e0aca67-ecba-565c-96fc-e031db94c444', 'multiple_choice', 'Що означає «limenka»?', 'бляшанка, (металева) банка', '["список", "м''ясна лавка", "бляшанка, (металева) банка", "шинка"]'::jsonb, 'A0', 3, 'PUBLISHED', 'limenka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9f2e1fea-9199-5948-8779-997dfecebde6', 'multiple_choice', 'Що означає «pekara»?', 'пекарня', '["шматок, штука", "бляшанка, (металева) банка", "салямі", "пекарня"]'::jsonb, 'A0', 4, 'PUBLISHED', 'pekara', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f389bdc5-c20c-5ed3-8060-1e8ddc1f5f37', 'multiple_choice', 'Як хорватською «магазин / крамниця»?', 'trgovina', '["komad", "trgovina", "supermarket", "mljeveno meso"]'::jsonb, 'A0', 5, 'PUBLISHED', 'trgovina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '52f3660a-137f-596c-b5a3-7a8df6be542f', 'multiple_choice', 'Як хорватською «це все»?', 'to je sve', '["trgovina", "još nešto", "limenka", "to je sve"]'::jsonb, 'A0', 6, 'PUBLISHED', 'to je sve', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cb9ab81f-b7c7-5428-ae35-3f5a5203a746', 'type_answer', 'Напишіть хорватською: «сосиска; ковбаска»', 'kobasica', null, 'A0', 7, 'PUBLISHED', 'kobasica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c0aefa3-7aba-5c1c-8943-40e4329350af', 'type_answer', 'Напишіть хорватською: «шинка»', 'šunka', null, 'A0', 8, 'PUBLISHED', 'šunka', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6dd79b2b-3d3a-5e45-9331-e3eff9594778', 'type_answer', 'Напишіть хорватською: «нарізати»', 'narezati', null, 'A0', 9, 'PUBLISHED', 'narezati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '504d310d-9373-5877-96a3-201bf09c31bc', 'sentence_builder', 'Складіть: «Це все, дякую.»', 'To je sve, hvala.', '["To", "je", "hvala.", "sve,"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cd7458d9-e747-5835-9ae1-74bb99d899d2', 'sentence_builder', 'Складіть: «Пів кіло фаршу, будь ласка.»', 'Pola kile mljevenog mesa, molim.', '["Pola", "kile", "molim.", "mljevenog", "mesa,"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '818a22ff-9d88-533e-839e-7ee2332dfe37', 'listening', 'Прослухайте і складіть фразу', 'Naravno. Ovu ili onu?', '["onu?", "ili", "Naravno.", "Ovu"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c62ea417-7459-5e93-ba83-bb24d12fad91', 'listening', 'Прослухайте і складіть фразу', 'Napiši mi popis, molim te.', '["popis,", "te.", "Napiši", "mi", "molim"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c915dc45-6a50-55b2-9b34-7ef55e418823', 'speaking', 'Сто грамів сиру, будь ласка.', 'Deset deka sira, molim.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5f4ffa0d-fc06-5a99-ac07-02581401cbca', 'speaking', 'Ще щось?', 'Još nešto?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('04b5f1e7-2937-5a33-83f3-d94a027376e4', v_lesson, 'У м’ясній лавці', 'U mesnici', 2501, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('db72c289-e531-530c-af36-b7ccb53c5112', '04b5f1e7-2937-5a33-83f3-d94a027376e4', 'Mesar', 'Dobar dan, izvolite.', 'Добрий день, прошу.', 1);
  perform pg_temp.turn('da5e2074-3299-5242-a7f4-2ffbc9df772d', '04b5f1e7-2937-5a33-83f3-d94a027376e4', 'Daša', 'Dvadeset deka šunke, molim. Možete li je narezati?', 'Двісті грамів шинки, будь ласка. Можете її нарізати?', 2);
  perform pg_temp.turn('65beae8b-f5dc-5ca3-8f03-071786235831', '04b5f1e7-2937-5a33-83f3-d94a027376e4', 'Mesar', 'Naravno. Ovu ili onu?', 'Звісно. Цю чи ту?', 3);
  perform pg_temp.turn('8431a85d-524c-51b3-91d3-1f024ca53c6b', '04b5f1e7-2937-5a33-83f3-d94a027376e4', 'Daša', 'Onu domaću. I pola kile mljevenog mesa.', 'Ту, домашню. І пів кіло фаршу.', 4);
  perform pg_temp.turn('38fb6d25-3f71-52a5-b493-f6b56e15f486', '04b5f1e7-2937-5a33-83f3-d94a027376e4', 'Mesar', 'Još nešto?', 'Ще щось?', 5);
  perform pg_temp.turn('8969c830-5450-5b31-85e0-590c9b1d7ca4', '04b5f1e7-2937-5a33-83f3-d94a027376e4', 'Daša', 'To je sve, hvala.', 'Це все, дякую.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('feb180a1-5373-5654-9d24-16c18bb1b57f', v_lesson, 'Список покупок', 'Popis za kupovinu', 2502, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('d70bdfd9-08ea-5d8b-9cff-00fd579f549a', 'feb180a1-5373-5654-9d24-16c18bb1b57f', 'Luka', 'Dašo, idem u supermarket. Trebaš li nešto?', 'Дашо, я йду в супермаркет. Тобі щось треба?', 1);
  perform pg_temp.turn('9197483a-0ba8-5a13-8fd4-a7bf4e6f39d2', 'feb180a1-5373-5654-9d24-16c18bb1b57f', 'Daša', 'Da, litru mlijeka i kruh iz pekare.', 'Так, літр молока й хліб із пекарні.', 2);
  perform pg_temp.turn('f1074262-4b0b-57b6-9709-e6598e87eaac', 'feb180a1-5373-5654-9d24-16c18bb1b57f', 'Luka', 'Napiši mi popis, molim te.', 'Напиши мені список, будь ласка.', 3);
  perform pg_temp.turn('574d0c36-bdf2-5780-b14d-880b69d5825e', 'feb180a1-5373-5654-9d24-16c18bb1b57f', 'Daša', 'Evo: dvije limenke graha, staklenka meda i pakiranje kave.', 'Ось: дві бляшанки квасолі, банка меду й пачка кави.', 4);
  perform pg_temp.turn('09325a15-9d56-50aa-b607-85fedf1d2861', 'feb180a1-5373-5654-9d24-16c18bb1b57f', 'Luka', 'Je li jedno pakiranje kave dosta?', 'Однієї пачки кави вистачить?', 5);
  perform pg_temp.turn('0fc6b485-b95d-5d78-9bac-daaa05767bc5', 'feb180a1-5373-5654-9d24-16c18bb1b57f', 'Daša', 'Dosta je. Hvala ti!', 'Вистачить. Дякую тобі!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.8 · урок 51: На касі — перебудова: 20 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '28913ad6-490f-5d89-bad7-9b303c673fcd';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «На касі» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '2aa25194-8450-5899-a02c-089796158da4') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 51: На касі', title_hr = 'Lekcija 51: Na blagajni',
         objectives = '["Заплатити на касі карткою чи готівкою", "Відповісти касирці: пакет, PIN, безконтактно", "Обміняти чи повернути товар з чеком"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'blagajna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blagajnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'samoposlužna blagajna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupovina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'račun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kartica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gotovina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'karticom ili gotovinom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'beskontaktno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bankomat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podići novac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrećica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trebate li vrećicu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zamijeniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povrat novca', v_pos);
  v_pos := pg_temp.word(v_lesson, 'reklamacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jamstvo', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd3d8f7a5-2482-52c1-bcdc-23d64470e0b8', 'fill_in_the_blank', 'Platit ću ___.', 'karticom', '["kartica", "kartici", "karticom", "kartice"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae862b74-2487-5778-a6c3-fec4b4422c50', 'multiple_choice', 'Що означає «kupac»?', 'покупець', '["готівка", "карткою чи готівкою", "скарга (на товар); рекламація", "покупець"]'::jsonb, 'A0', 2, 'PUBLISHED', 'kupac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '96e6f47b-515e-54ed-afd6-9df2f2009e3f', 'multiple_choice', 'Що означає «gotovina»?', 'готівка', '["покупки, шопінг; купівля", "замінити", "готівка", "гарантія"]'::jsonb, 'A0', 3, 'PUBLISHED', 'gotovina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a269d8db-ddeb-5a2d-9d23-62e7d048cebd', 'multiple_choice', 'Що означає «kartica»?', 'банківська картка', '["банківська картка", "рахунок / чек", "покупець", "вам потрібен пакет?"]'::jsonb, 'A0', 4, 'PUBLISHED', 'kartica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '782f4e9b-f236-5bee-a3d7-f9da8ae25ab1', 'multiple_choice', 'Як хорватською «касирка»?', 'blagajnica', '["kupovina", "bankomat", "zamijeniti", "blagajnica"]'::jsonb, 'A0', 5, 'PUBLISHED', 'blagajnica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'db4b64bf-73b2-5919-960e-6dceb3264f95', 'multiple_choice', 'Як хорватською «гарантія»?', 'jamstvo', '["jamstvo", "reklamacija", "beskontaktno", "kupac"]'::jsonb, 'A0', 6, 'PUBLISHED', 'jamstvo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '63a99d1d-89e1-5380-898b-2a1063b7a599', 'type_answer', 'Напишіть хорватською: «купити»', 'kupiti', null, 'A0', 7, 'PUBLISHED', 'kupiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8f7f6f51-fa22-5590-9ad9-e3529492f6e4', 'type_answer', 'Напишіть хорватською: «замінити»', 'zamijeniti', null, 'A0', 8, 'PUBLISHED', 'zamijeniti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9f78df04-7db3-5309-b9f0-a2ec1cfb3954', 'type_answer', 'Напишіть хорватською: «банкомат»', 'bankomat', null, 'A0', 9, 'PUBLISHED', 'bankomat', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6e96b2e1-e410-51ce-96b7-2cecdd71a361', 'sentence_builder', 'Складіть: «Карткою чи готівкою?»', 'Karticom ili gotovinom?', '["ili", "gotovinom?", "Karticom"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '69998f82-75a2-5db0-9f29-f44c004df879', 'sentence_builder', 'Складіть: «Можна безконтактно?»', 'Može li beskontaktno?', '["Može", "beskontaktno?", "li"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd706f1df-1b79-534c-8600-81d3e3d940be', 'listening', 'Прослухайте і складіть фразу', 'Trebate li vrećicu?', '["Trebate", "vrećicu?", "li"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '56704fd5-58a6-569a-aafd-718882525031', 'listening', 'Прослухайте і складіть фразу', 'Mogu li je zamijeniti?', '["li", "je", "Mogu", "zamijeniti?"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a22047a6-99e8-5435-b745-be1cc72561c9', 'speaking', 'Де найближчий банкомат?', 'Gdje je najbliži bankomat?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'da9b7ccb-e214-5fbd-893a-62c2054c1e63', 'speaking', 'Мені треба зняти гроші.', 'Moram podići novac.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2aa25194-8450-5899-a02c-089796158da4', v_lesson, 'Карткою чи готівкою?', 'Karticom ili gotovinom?', 2511, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('8d4139c2-f091-5673-99bf-901652d471f9', '2aa25194-8450-5899-a02c-089796158da4', 'Blagajnica', 'Dobar dan. Trebate li vrećicu?', 'Добрий день. Вам потрібен пакет?', 1);
  perform pg_temp.turn('07656358-3bc5-5303-a56a-3c19c0048235', '2aa25194-8450-5899-a02c-089796158da4', 'Daša', 'Da, jednu, molim.', 'Так, один, будь ласка.', 2);
  perform pg_temp.turn('c4e1daa9-8ab7-575e-bde4-1adeb4e119fb', '2aa25194-8450-5899-a02c-089796158da4', 'Blagajnica', 'Ukupno dvadeset tri eura. Karticom ili gotovinom?', 'Разом двадцять три євро. Карткою чи готівкою?', 3);
  perform pg_temp.turn('fb58a92c-4ee0-5b15-afe1-3c5172178e74', '2aa25194-8450-5899-a02c-089796158da4', 'Daša', 'Karticom. Može li beskontaktno?', 'Карткою. Можна безконтактно?', 4);
  perform pg_temp.turn('df4bfa44-8e0b-5547-8e1a-5f258b9f5afc', '2aa25194-8450-5899-a02c-089796158da4', 'Blagajnica', 'Može. Prislonite karticu ovdje.', 'Можна. Прикладіть картку сюди.', 5);
  perform pg_temp.turn('61cc4d6a-ee18-5824-8dd5-51b0c9419d36', '2aa25194-8450-5899-a02c-089796158da4', 'Daša', 'Gotovo. Hvala, doviđenja!', 'Готово. Дякую, до побачення!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cde40e42-79aa-569f-ad78-f7ac42014330', v_lesson, 'Обмін куртки', 'Zamjena jakne', 2512, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('dcdd675d-12b5-52f0-bc3d-fc3fc3bc3667', 'cde40e42-79aa-569f-ad78-f7ac42014330', 'Darja', 'Dobar dan, jučer sam kupila ovu jaknu, ali je prevelika.', 'Добрий день, учора я купила цю куртку, але вона завелика.', 1);
  perform pg_temp.turn('b09b3695-ad89-5d3b-b0df-975f33ae8144', 'cde40e42-79aa-569f-ad78-f7ac42014330', 'Prodavačica', 'Imate li račun?', 'У вас є чек?', 2);
  perform pg_temp.turn('5bf3805d-b875-5874-8fcd-39339ee894c8', 'cde40e42-79aa-569f-ad78-f7ac42014330', 'Darja', 'Imam, evo ga. Mogu li je zamijeniti?', 'Є, ось він. Можна її обміняти?', 3);
  perform pg_temp.turn('e01a02c2-ecda-54c0-b0ab-91563d74d772', 'cde40e42-79aa-569f-ad78-f7ac42014330', 'Prodavačica', 'Možete je zamijeniti ili dobiti povrat novca.', 'Можете її обміняти або отримати гроші назад.', 4);
  perform pg_temp.turn('94afe0b3-0f3c-5261-915d-5712937bbf8d', 'cde40e42-79aa-569f-ad78-f7ac42014330', 'Darja', 'Radije bih je zamijenila za manju veličinu.', 'Я б краще обміняла її на менший розмір.', 5);
  perform pg_temp.turn('12c09e0f-1d8f-5d73-8dc0-f72c96431160', 'cde40e42-79aa-569f-ad78-f7ac42014330', 'Prodavačica', 'Nema problema. Izvolite, probajte ovu.', 'Без проблем. Прошу, приміряйте цю.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.8 · урок 52: Скільки коштує ця футболка? — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Скільки коштує ця футболка?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '0119ff02-cf85-577b-8109-b72609a0212e') then return; end if;  -- уже перебудовано
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
  if v_gid is null then select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Цей, той, он той: ovaj, taj, onaj' and status = 'PUBLISHED' order by created_at limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 52: Скільки коштує ця футболка?', title_hr = 'Lekcija 52: Koliko košta ova majica?',
         objectives = '["Назвати одяг і взуття", "Попросити свій розмір і приміряти", "Сказати, що річ завелика, замала чи пасує"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'odjeća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'majica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'košulja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hlače', v_pos);
  v_pos := pg_temp.word(v_lesson, 'traperice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'haljina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'suknja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jakna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kaput', v_pos);
  v_pos := pg_temp.word(v_lesson, 'džemper', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cipele', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tenisice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čarape', v_pos);
  v_pos := pg_temp.word(v_lesson, 'veličina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'taj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'onaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'probati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kabina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pristajati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prevelik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'premalen', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a086f9e-07e0-557b-a272-c4c06f6e132c', 'fill_in_the_blank', 'Koliko košta ___ majica?', 'ova', '["ove", "ovaj", "ova", "ovo"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f16c9643-41c6-556d-9ee9-2f6f0927ecac', 'multiple_choice', 'Що означає «džemper»?', 'светр', '["одяг", "светр", "той", "завеликий"]'::jsonb, 'A0', 2, 'PUBLISHED', 'džemper', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a306075-59a9-5810-801e-7911c46b62ef', 'multiple_choice', 'Що означає «taj»?', 'цей', '["приміряти / спробувати", "цей", "пасувати, личити; підходити за розміром", "светр"]'::jsonb, 'A0', 3, 'PUBLISHED', 'taj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '991570fc-67e1-599f-8ddb-da6672d50ac4', 'multiple_choice', 'Що означає «pristajati»?', 'пасувати, личити; підходити за розміром', '["сорочка", "пасувати, личити; підходити за розміром", "сукня", "спідниця"]'::jsonb, 'A0', 4, 'PUBLISHED', 'pristajati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '24e63997-9d20-5ef1-9094-d42ba81b8c3c', 'multiple_choice', 'Як хорватською «сорочка»?', 'košulja', '["košulja", "cipele", "pristajati", "probati"]'::jsonb, 'A0', 5, 'PUBLISHED', 'košulja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd57a621a-decf-53b1-a96a-8ef8ed96f337', 'multiple_choice', 'Як хорватською «сукня»?', 'haljina', '["haljina", "jakna", "košulja", "cipele"]'::jsonb, 'A0', 6, 'PUBLISHED', 'haljina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '69d8b564-c28e-521a-b341-d7b985c1c919', 'type_answer', 'Напишіть хорватською: «футболка»', 'majica', null, 'A0', 7, 'PUBLISHED', 'majica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6f82fbbd-d07c-5dab-971b-618f4afa0b8f', 'type_answer', 'Напишіть хорватською: «шкарпетки»', 'čarape', null, 'A0', 8, 'PUBLISHED', 'čarape', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd9006815-afa9-552c-8017-1dc952d131e3', 'type_answer', 'Напишіть хорватською: «куртка»', 'jakna', null, 'A0', 9, 'PUBLISHED', 'jakna', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1b1fe6a6-bae8-5763-8d88-e54afb83d628', 'sentence_builder', 'Складіть: «Можна приміряти цю сукню?»', 'Mogu li probati ovu haljinu?', '["probati", "li", "Mogu", "ovu", "haljinu?"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e98d25d4-2ce8-54ff-98e6-ba410e0c1d68', 'sentence_builder', 'Складіть: «Ці штани мені завеликі.»', 'Ove hlače su mi prevelike.', '["hlače", "Ove", "mi", "su", "prevelike."]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'abf12f34-afac-5e4c-9260-41e5a188acbd', 'listening', 'Прослухайте і складіть фразу', 'Koju veličinu nosite?', '["veličinu", "nosite?", "Koju"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0be9426c-c9ab-5095-b400-180edf5719d5', 'listening', 'Прослухайте і складіть фразу', 'Ona crna. Ova je premalena za tebe.', '["crna.", "Ova", "Ona", "za", "tebe.", "je", "premalena"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '616c94dd-8fc7-5ed2-8d6d-2ad7a2a8e8ea', 'speaking', 'Де примірочна?', 'Gdje je kabina?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5b80e4bc-1303-59c1-b7b9-ee4e422aa340', 'speaking', 'Ця сорочка мені пасує.', 'Ova košulja mi pristaje.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0119ff02-cf85-577b-8109-b72609a0212e', v_lesson, 'У магазині одягу', 'U trgovini odjećom', 2521, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('ce8d65c6-2861-56e4-91f9-0fa73bfbb17a', '0119ff02-cf85-577b-8109-b72609a0212e', 'Daša', 'Oprostite, imate li ove traperice u manjoj veličini?', 'Перепрошую, у вас є ці джинси меншого розміру?', 1);
  perform pg_temp.turn('c326e6fe-4d17-5299-88af-14ccdd0d2e1d', '0119ff02-cf85-577b-8109-b72609a0212e', 'Prodavačica', 'Koju veličinu nosite?', 'Який розмір ви носите?', 2);
  perform pg_temp.turn('d0b40e83-2f65-50c2-a80b-7fb2c3a7750f', '0119ff02-cf85-577b-8109-b72609a0212e', 'Daša', 'Trideset osam. Ove su mi prevelike.', 'Тридцять восьмий. Ці мені завеликі.', 3);
  perform pg_temp.turn('60b82759-2b37-579c-9a62-b3d49437272b', '0119ff02-cf85-577b-8109-b72609a0212e', 'Prodavačica', 'Izvolite. Kabina je tamo lijevo.', 'Прошу. Примірочна там, ліворуч.', 4);
  perform pg_temp.turn('32d07eec-987f-56eb-8aa6-4d7eaf8981dc', '0119ff02-cf85-577b-8109-b72609a0212e', 'Daša', 'Ove mi savršeno pristaju! Koliko koštaju?', 'Ці мені ідеально пасують! Скільки вони коштують?', 5);
  perform pg_temp.turn('e767645d-5996-5ac5-bd87-5fc53c56e197', '0119ff02-cf85-577b-8109-b72609a0212e', 'Prodavačica', 'Četrdeset eura.', 'Сорок євро.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('82d331e4-b359-5a10-9282-ef1ea18903dc', v_lesson, 'Ця чи та?', 'Ova ili ona?', 2522, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('138b93b5-3d73-56b5-ad82-124dd6a60130', '82d331e4-b359-5a10-9282-ef1ea18903dc', 'Darja', 'Koja ti se jakna više sviđa, ova ili ona?', 'Яка куртка тобі більше подобається, ця чи он та?', 1);
  perform pg_temp.turn('d7a9dd7c-b3cc-554e-87cf-dee0a33be272', '82d331e4-b359-5a10-9282-ef1ea18903dc', 'Daša', 'Ona crna. Ova je premalena za tebe.', 'Он та чорна. Ця тобі замала.', 2);
  perform pg_temp.turn('1702b011-cc4a-555a-b6ae-999f873b71dc', '82d331e4-b359-5a10-9282-ef1ea18903dc', 'Darja', 'Probat ću onu. A ti, trebaš li nešto?', 'Приміряю ту. А тобі щось треба?', 3);
  perform pg_temp.turn('7a6709da-854e-510d-b3fe-a0403c875347', '82d331e4-b359-5a10-9282-ef1ea18903dc', 'Daša', 'Trebam čarape i topli džemper.', 'Мені потрібні шкарпетки й теплий светр.', 4);
  perform pg_temp.turn('3d9790ef-fe9d-534e-808c-c7dbcacb4026', '82d331e4-b359-5a10-9282-ef1ea18903dc', 'Darja', 'Džemperi su tamo, pored kaputa.', 'Светри там, біля пальт.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.8 · урок 53: Кольори — перебудова: 21 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '288e7610-99c8-5696-989a-86f60ce38b0a';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Кольори» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '6d262a67-f8ac-58ff-8c8f-afcc42d0d9dd') then return; end if;  -- уже перебудовано
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
  if v_gid is null then select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Прикметники: узгодження з іменником' and status = 'PUBLISHED' order by created_at limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 53: Кольори', title_hr = 'Lekcija 53: Boje',
         objectives = '["Назвати кольори й відтінки: tamnoplav, svijetloplav, bež, zlatan, srebrn", "Запитати «Kakve je boje?» і описати річ", "Сказати про візерунок: na pruge, na točkice, jednobojan"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'boja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kakve je boje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bijel', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crn', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crven', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zelen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žut', v_pos);
  v_pos := pg_temp.word(v_lesson, 'siv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ružičast', v_pos);
  v_pos := pg_temp.word(v_lesson, 'narančast', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljubičast', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tamnoplav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svijetloplav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bež', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zlatan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srebrn', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šaren', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na pruge', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na točkice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jednobojan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'omiljen', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bff94b34-86b9-5fa3-b546-9f372271cb1e', 'fill_in_the_blank', 'Imate li ovu majicu u ___ boji?', 'crvenoj', '["crven", "crvena", "crvenu", "crvenoj"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5abb3158-be9e-5899-a344-3bd11002160d', 'multiple_choice', 'Що означає «šaren»?', 'строкатий', '["зелений", "строкатий", "чорний", "фіолетовий"]'::jsonb, 'A0', 2, 'PUBLISHED', 'šaren', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f401c4d7-4474-5964-969e-a31e06bb0397', 'multiple_choice', 'Що означає «zlatan»?', 'золотий; золотистий', '["улюблений", "у горошок", "помаранчевий", "золотий; золотистий"]'::jsonb, 'A0', 3, 'PUBLISHED', 'zlatan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2981594c-1003-5871-942f-7013e1efc100', 'multiple_choice', 'Що означає «narančast»?', 'помаранчевий', '["рожевий", "помаранчевий", "блакитний, світло-синій", "якого (воно) кольору?"]'::jsonb, 'A0', 4, 'PUBLISHED', 'narančast', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5763fad3-806f-55b3-a74d-bae6c18abd42', 'multiple_choice', 'Як хорватською «однотонний»?', 'jednobojan', '["jednobojan", "ljubičast", "na točkice", "boja"]'::jsonb, 'A0', 5, 'PUBLISHED', 'jednobojan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '059c3c28-03ab-5fdb-934f-41d0439ef0e9', 'multiple_choice', 'Як хорватською «зелений»?', 'zelen', '["zelen", "srebrn", "na pruge", "omiljen"]'::jsonb, 'A0', 6, 'PUBLISHED', 'zelen', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '120737e8-f326-5aef-b6e4-bb578322a6b9', 'type_answer', 'Напишіть хорватською: «у горошок»', 'na točkice', null, 'A0', 7, 'PUBLISHED', 'na točkice', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a645c394-387f-53eb-89f0-5c6eeb1dd2df', 'type_answer', 'Напишіть хорватською: «улюблений»', 'omiljen', null, 'A0', 8, 'PUBLISHED', 'omiljen', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '57877364-1013-5fff-9091-941514ac8629', 'type_answer', 'Напишіть хорватською: «бежевий»', 'bež', null, 'A0', 9, 'PUBLISHED', 'bež', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '860319a5-b2bf-51c6-988f-786d0944c49c', 'sentence_builder', 'Складіть: «Мій улюблений колір — зелений.»', 'Moja omiljena boja je zelena.', '["omiljena", "boja", "je", "zelena.", "Moja"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '13b268d7-5d5b-5cd3-85f5-574420626bcd', 'sentence_builder', 'Складіть: «Якого кольору твоя куртка?»', 'Kakve je boje tvoja jakna?', '["je", "jakna?", "Kakve", "tvoja", "boje"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0a2b8945-315e-5c67-b672-60c89a5a039d', 'listening', 'Прослухайте і складіть фразу', 'Imamo bijelu i ovu na pruge.', '["na", "ovu", "i", "bijelu", "Imamo", "pruge."]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dc6f51e9-d739-5760-9f7b-f2dcb61b8f69', 'listening', 'Прослухайте і складіть фразу', 'Zelena. A tvoja?', '["tvoja?", "A", "Zelena."]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '60449d25-17f6-5ccd-b1c1-fdc589de40c8', 'speaking', 'Якого це кольору?', 'Kakve je boje?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6cb11885-a38d-532e-a22f-c7aa0e92f658', 'speaking', 'Я люблю чорний колір.', 'Volim crnu boju.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6d262a67-f8ac-58ff-8c8f-afcc42d0d9dd', v_lesson, 'Сорочка для роботи', 'Košulja za posao', 2531, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('dfdd7cc1-7c0b-53c3-a64b-d0276970a415', '6d262a67-f8ac-58ff-8c8f-afcc42d0d9dd', 'Prodavač', 'Tražite li nešto određeno?', 'Шукаєте щось конкретне?', 1);
  perform pg_temp.turn('d6effc8d-83be-596f-9d8d-01c456db916f', '6d262a67-f8ac-58ff-8c8f-afcc42d0d9dd', 'Daša', 'Tražim košulju za posao, bijelu ili svijetloplavu.', 'Шукаю сорочку для роботи, білу чи блакитну.', 2);
  perform pg_temp.turn('609279d9-4f45-5d19-92be-cc8dd8f465ec', '6d262a67-f8ac-58ff-8c8f-afcc42d0d9dd', 'Prodavač', 'Imamo bijelu i ovu na pruge.', 'Є біла й оця в смужку.', 3);
  perform pg_temp.turn('481802a2-c0e4-50a3-9a35-837c3b68e7db', '6d262a67-f8ac-58ff-8c8f-afcc42d0d9dd', 'Daša', 'Lijepa je, ali tražim jednobojnu. Imate li tamnoplavu?', 'Гарна, але я шукаю однотонну. Темно-синя є?', 4);
  perform pg_temp.turn('76408304-be2f-5939-93ad-e56d77d28463', '6d262a67-f8ac-58ff-8c8f-afcc42d0d9dd', 'Prodavač', 'Nažalost, samo crnu i sivu.', 'На жаль, лише чорна й сіра.', 5);
  perform pg_temp.turn('e2322317-fbaa-57a4-9a50-693c96a36dff', '6d262a67-f8ac-58ff-8c8f-afcc42d0d9dd', 'Daša', 'Onda uzimam bijelu.', 'Тоді беру білу.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a9be54ea-5c2a-5b30-9495-37b8304542df', v_lesson, 'Улюблений колір', 'Omiljena boja', 2532, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('301dd942-b408-5c5c-8c20-adb486de153e', 'a9be54ea-5c2a-5b30-9495-37b8304542df', 'Mia', 'Dašo, koja ti je omiljena boja?', 'Дашо, який твій улюблений колір?', 1);
  perform pg_temp.turn('9fccefbe-224a-5b65-a9c3-37f3eb779be1', 'a9be54ea-5c2a-5b30-9495-37b8304542df', 'Daša', 'Zelena. A tvoja?', 'Зелений. А твій?', 2);
  perform pg_temp.turn('e15de571-879d-5b6b-815d-45ade294462d', 'a9be54ea-5c2a-5b30-9495-37b8304542df', 'Mia', 'Ljubičasta. Volim šarenu odjeću.', 'Фіолетовий. Я люблю строкатий одяг.', 3);
  perform pg_temp.turn('0c359b55-0495-5dd7-987e-39371dfbf895', 'a9be54ea-5c2a-5b30-9495-37b8304542df', 'Daša', 'Vidim! Haljina na točkice ti jako pristaje.', 'Бачу! Сукня в горошок тобі дуже пасує.', 4);
  perform pg_temp.turn('d12f9b4f-7916-598a-bc84-485b3b76a86c', 'a9be54ea-5c2a-5b30-9495-37b8304542df', 'Mia', 'Hvala! A ti uvijek nosiš bež i sivo.', 'Дякую! А ти завжди носиш бежеве й сіре.', 5);
  perform pg_temp.turn('24c93ead-9503-5055-a4e1-5c23ca647d8a', 'a9be54ea-5c2a-5b30-9495-37b8304542df', 'Daša', 'Istina, ali ova zlatna narukvica je nova!', 'Правда, але цей золотий браслет — новий!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- 3. Новий порядок уроків у модулі A0.8: наявні уроки тимчасово переносяться на місця 100+
--    (unique (unit_id, order_index)), щоб звільнити місця для нових; у кроці 5 — на остаточні місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 8 and u.order_index = 1;
  update public.lessons l set order_index = t.o + 100
    from (values
    ('e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0'::uuid, 1),
    ('0e925295-2766-5931-b031-2412682bc6f8'::uuid, 2),
    ('28913ad6-490f-5d89-bad7-9b303c673fcd'::uuid, 3),
    ('b01e2f67-3e7a-5ab6-99bb-fae374f431e0'::uuid, 4),
    ('288e7610-99c8-5696-989a-86f60ce38b0a'::uuid, 5)
    ) as t(id, o)
   where l.id = t.id and l.unit_id = v_unit and l.order_index <> t.o and l.order_index < 100;
end $$;

-- 4. Нові тематичні уроки модуля A0.8
-- A0.8 · урок 54: Можна дешевше? — новий урок: 22 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '6836e57c-030c-59f8-9818-b44c08b126a6';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A0.8: місце 6 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Дешевше чи дорожче? Порівняння' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Дешевше чи дорожче? Порівняння»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 54: Можна дешевше?', 'Lekcija 54: Može li jeftinije?', '["Запитати про знижку й поторгуватися: «Može li jeftinije?»", "Порівняти ціни: jeftiniji, skuplji, jeftinije nego…", "Домовитися про ціну, купуючи вживану річ"]'::jsonb, 15, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'popust', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sniženje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'akcija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rasprodaja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jeftiniji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skuplji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jeftinije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skuplje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'više', v_pos);
  v_pos := pg_temp.word(v_lesson, 'previše', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zadnja cijena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spustiti cijenu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponuda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponuditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dogovoreno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cjenkati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rabljen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'buvljak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prodati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prodavati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrijediti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'isplatiti se', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b316db49-bee7-50a3-99b6-b5c24b71f0a5', 'fill_in_the_blank', 'Ova lampa je ___ od one.', 'jeftinija', '["jeftin", "jeftiniji", "jeftinije", "jeftinija"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7f565838-e212-5048-a374-56c8cad735ac', 'multiple_choice', 'Що означає «prodavati»?', 'продавати', '["більше", "дорожче", "блошиний ринок, барахолка", "продавати"]'::jsonb, 'A0', 2, 'PUBLISHED', 'prodavati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '68065a14-dea0-5263-8315-ebf58d5fe2fc', 'multiple_choice', 'Що означає «spustiti cijenu»?', 'знизити ціну, скинути ціну', '["розпродаж", "знизити ціну, скинути ціну", "пропозиція", "знижка"]'::jsonb, 'A0', 3, 'PUBLISHED', 'spustiti cijenu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '22113dc5-bb91-5efd-b390-c2aea44059ae', 'multiple_choice', 'Що означає «sniženje»?', 'розпродаж / зниження цін', '["остання (кінцева) ціна", "дорожчий", "вживаний, б/в", "розпродаж / зниження цін"]'::jsonb, 'A0', 4, 'PUBLISHED', 'sniženje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cef57a3b-cf2e-574b-a0d5-a8ad5072ec4f', 'multiple_choice', 'Як хорватською «дешевше»?', 'jeftinije', '["jeftinije", "skuplji", "zadnja cijena", "cjenkati se"]'::jsonb, 'A0', 5, 'PUBLISHED', 'jeftinije', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b01aa528-deb1-5679-81a8-d7489b6bddbc', 'multiple_choice', 'Як хорватською «дорожчий»?', 'skuplji', '["rasprodaja", "zadnja cijena", "skuplji", "isplatiti se"]'::jsonb, 'A0', 6, 'PUBLISHED', 'skuplji', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '404365c8-201a-5e71-a663-db949fa7c9da', 'type_answer', 'Напишіть хорватською: «знижка»', 'popust', null, 'A0', 7, 'PUBLISHED', 'popust', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '021817a2-edea-51a7-a911-bb6ef910efd8', 'type_answer', 'Напишіть хорватською: «надто; забагато»', 'previše', null, 'A0', 8, 'PUBLISHED', 'previše', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '83b3b534-4a6b-50fe-bd1b-64d295221596', 'type_answer', 'Напишіть хорватською: «запропонувати»', 'ponuditi', null, 'A0', 9, 'PUBLISHED', 'ponuditi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '44241704-859a-5bfe-9c8d-d2fcde05a45c', 'sentence_builder', 'Складіть: «Можна дешевше?»', 'Može li jeftinije?', '["li", "jeftinije?", "Može"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '188fcec1-29f0-57b1-87c0-a293a2690dbb', 'sentence_builder', 'Складіть: «Це остання ціна.»', 'To je zadnja cijena.', '["To", "cijena.", "zadnja", "je"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'deb93b1d-12d6-51db-965d-1c4c5a5ebdcd', 'listening', 'Прослухайте і складіть фразу', 'Za vas dvadeset pet.', '["Za", "pet.", "vas", "dvadeset"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '860939ce-8492-587f-9dd1-993d3dd4d4e4', 'listening', 'Прослухайте і складіть фразу', 'Može za devedeset?', '["devedeset?", "za", "Može"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '02e3f69f-6b57-5fca-adf6-81aafbafadcb', 'speaking', 'Є знижка?', 'Ima li popusta?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '91658e89-e4c0-5260-bdd0-4a02d0859dbf', 'speaking', 'Домовилися!', 'Dogovoreno!', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ee5c7b10-1f31-539e-a06e-5c711fadadb0', v_lesson, 'На блошиному ринку', 'Na buvljaku', 2541, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('0c99e3d3-8123-5dcd-92a2-79677cd7851a', 'ee5c7b10-1f31-539e-a06e-5c711fadadb0', 'Daša', 'Koliko košta ova stara lampa?', 'Скільки коштує ця стара лампа?', 1);
  perform pg_temp.turn('05678fb7-52df-5c31-bc03-6d7466dec939', 'ee5c7b10-1f31-539e-a06e-5c711fadadb0', 'Prodavač', 'Trideset eura.', 'Тридцять євро.', 2);
  perform pg_temp.turn('5a8a8658-e577-5fe9-880f-37ccc52c6914', 'ee5c7b10-1f31-539e-a06e-5c711fadadb0', 'Daša', 'To je previše. Može li jeftinije?', 'Це забагато. Можна дешевше?', 3);
  perform pg_temp.turn('e7b761fc-4179-5b77-aabd-c553e177b3e2', 'ee5c7b10-1f31-539e-a06e-5c711fadadb0', 'Prodavač', 'Za vas dvadeset pet. To je zadnja cijena.', 'Для вас двадцять п’ять. Це остання ціна.', 4);
  perform pg_temp.turn('6bf88c95-bf45-53ad-b67e-49ef4a730174', 'ee5c7b10-1f31-539e-a06e-5c711fadadb0', 'Daša', 'Dajem vam dvadeset, u gotovini.', 'Даю вам двадцять, готівкою.', 5);
  perform pg_temp.turn('1eefab99-de7e-56fe-89e6-eb8aeab235a5', 'ee5c7b10-1f31-539e-a06e-5c711fadadb0', 'Prodavač', 'Dobro, dogovoreno!', 'Гаразд, домовилися!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1f6daeb7-b59f-5246-bc3c-79a8dd39ff41', v_lesson, 'Вживаний велосипед', 'Rabljeni bicikl', 2542, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('eef0729b-a45c-51c5-a114-2ff48f999d7b', '1f6daeb7-b59f-5246-bc3c-79a8dd39ff41', 'Darja', 'Dobar dan, zovem zbog oglasa. Je li bicikl još na prodaju?', 'Добрий день, я телефоную щодо оголошення. Велосипед ще продається?', 1);
  perform pg_temp.turn('641c9df2-9e8c-558f-b0a4-04684652b421', '1f6daeb7-b59f-5246-bc3c-79a8dd39ff41', 'Prodavač', 'Jest. Rabljen je, ali u odličnom stanju. Cijena je sto dvadeset eura.', 'Так. Він вживаний, але у відмінному стані. Ціна — сто двадцять євро.', 2);
  perform pg_temp.turn('673e8860-b146-5b3a-876e-96cb98945cf6', '1f6daeb7-b59f-5246-bc3c-79a8dd39ff41', 'Darja', 'Novi je u trgovini sto pedeset. Vaš nije puno jeftiniji.', 'Новий у магазині коштує сто п’ятдесят. Ваш ненабагато дешевший.', 3);
  perform pg_temp.turn('25bdc792-72ed-50f9-9954-a57b32c9557a', '1f6daeb7-b59f-5246-bc3c-79a8dd39ff41', 'Prodavač', 'Moj je bolji model, ali mogu spustiti cijenu na sto.', 'Мій — краща модель, але можу знизити ціну до ста.', 4);
  perform pg_temp.turn('fdaa8953-ea46-5e3d-854c-4a6c6e527f9b', '1f6daeb7-b59f-5246-bc3c-79a8dd39ff41', 'Darja', 'Može za devedeset?', 'А за дев’яносто можна?', 5);
  perform pg_temp.turn('8902d715-5078-506b-83f1-097c52b8135b', '1f6daeb7-b59f-5246-bc3c-79a8dd39ff41', 'Prodavač', 'Može za devedeset pet. Isplati vam se!', 'Можна за дев’яносто п’ять. Вам це вигідно!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- 5. Наявні уроки модуля A0.8 — на нові місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 8 and u.order_index = 1;
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
   where l.id in ('e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0', '0e925295-2766-5931-b031-2412682bc6f8', '28913ad6-490f-5d89-bad7-9b303c673fcd', 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0', '288e7610-99c8-5696-989a-86f60ce38b0a', '6836e57c-030c-59f8-9818-b44c08b126a6')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or not exists (select 1 from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar')
             and exists (select 1 from public.lesson_grammar lg where lg.lesson_id = l.id)
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_module from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 8;
  select count(*) into v_order from (values ('e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0'::uuid, 1), ('0e925295-2766-5931-b031-2412682bc6f8'::uuid, 2), ('28913ad6-490f-5d89-bad7-9b303c673fcd'::uuid, 3), ('b01e2f67-3e7a-5ab6-99bb-fae374f431e0'::uuid, 4), ('288e7610-99c8-5696-989a-86f60ce38b0a'::uuid, 5), ('6836e57c-030c-59f8-9818-b44c08b126a6'::uuid, 6)) as t(id, o) join public.lessons l on l.id = t.id and l.order_index = t.o;
  select count(*) into v_lessons from public.lessons where level_code = 'A0' and status = 'PUBLISHED';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A0' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0', '0e925295-2766-5931-b031-2412682bc6f8', '28913ad6-490f-5d89-bad7-9b303c673fcd', 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0', '288e7610-99c8-5696-989a-86f60ce38b0a', '6836e57c-030c-59f8-9818-b44c08b126a6') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A0.8: % уроків з неправильним складом', v_bad; end if;
  if v_module <> 6 or v_order <> 6 then raise exception 'Модуль A0.8: уроків %, на своїх місцях % (очікувалось 6)', v_module, v_order; end if;
  if v_lessons < 64 then raise exception 'A0: уроків %, очікувалось щонайменше 64', v_lessons; end if;  -- наступні модулі додають уроки
  if v_titles > 0 then raise exception 'A0: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A0.8: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A0.8 — 6 уроків (49–54) за темою; уроків A0 — %', v_lessons;
end $$;

commit;
