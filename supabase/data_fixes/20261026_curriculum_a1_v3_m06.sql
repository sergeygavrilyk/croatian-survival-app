-- =====================================================================
-- Програма A1 v3 · модуль A1.6 «Робота» · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_curriculum_a1_v3.py 6 (не редагуйте вручну).
--
-- Рішення власника 2026-10-21 / 2026-10-26: до 25 слів на урок — скільки потрібно темі, 90–95 % слів — нові для рівня,
-- діалоги під тему, частіше Даша / Дар’я; бета (PUBLISHED).
--   * Уроки 50–58: 9 наявних перебудовано, 0 нових. Слів у них: 124.
--     Кожен: 10–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 43.
--   * Нові теми граматики: «Минулий час: radio sam, bila sam».
--   * Нові правила до тем: «Модальні дієслова» (+1).
--   * Виправлено: dnevni sastanak — «щоденна нарада; дейлі (стендап)»; natječaj — «конкурс (на посаду), вакансія» (стара версія — у content_versions).
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

-- 1. Нові слова й вирази A1.6 (43; наявні не змінюються)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tvornica', 'tvornica', 'hr', 'noun', 'A1', 'фабрика, завод', 'core', '{"gender": "f"}'::jsonb, '["Moj brat radi u tvornici namještaja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dostavljač', 'dostavljac', 'hr', 'noun', 'A1', 'кур’єр доставки, доставник', 'core', '{"gender": "m"}'::jsonb, '["Dostavljač donosi pizzu za pola sata."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('čuvar', 'cuvar', 'hr', 'noun', 'A1', 'охоронець; сторож', 'core', '{"gender": "m"}'::jsonb, '["Čuvar radi noću u trgovačkom centru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nadređeni', 'nadredeni', 'hr', 'noun', 'A1', 'керівник, безпосередній начальник', 'core', '{"gender": "m"}'::jsonb, '["Moj nadređeni odobrava godišnji odmor."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prekovremeno', 'prekovremeno', 'hr', 'adverb', 'A1', 'понаднормово', 'core', '{}'::jsonb, '["Ovaj tjedan radim prekovremeno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rad od kuće', 'rad od kuce', 'hr', 'phrase', 'A1', 'робота з дому', 'collocation', '{"gender": "m"}'::jsonb, '["Petkom imamo rad od kuće."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('oglas za posao', 'oglas za posao', 'hr', 'phrase', 'A1', 'оголошення про роботу, вакансія', 'collocation', '{"gender": "m"}'::jsonb, '["Svaki dan čitam oglase za posao."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('motivacijsko pismo', 'motivacijsko pismo', 'hr', 'phrase', 'A1', 'мотиваційний лист', 'collocation', '{"gender": "n"}'::jsonb, '["Uz životopis pošaljite i motivacijsko pismo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('honorarni posao', 'honorarni posao', 'hr', 'phrase', 'A1', 'підробіток, робота за договором', 'collocation', '{"gender": "m"}'::jsonb, '["Vikendom imam honorarni posao u kafiću."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nepuno radno vrijeme', 'nepuno radno vrijeme', 'hr', 'phrase', 'A1', 'неповний робочий день', 'collocation', '{"gender": "n"}'::jsonb, '["Tražim posao na nepuno radno vrijeme."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('razgovor za posao', 'razgovor za posao', 'hr', 'phrase', 'A1', 'співбесіда', 'collocation', '{"gender": "m"}'::jsonb, '["Sutra imam razgovor za posao."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prethodni', 'prethodni', 'hr', 'adjective', 'A1', 'попередній', 'core', '{"f": "prethodna", "n": "prethodno"}'::jsonb, '["Na prethodnom poslu radila sam pet godina."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bivši', 'bivsi', 'hr', 'adjective', 'A1', 'колишній', 'core', '{"f": "bivša", "n": "bivše"}'::jsonb, '["Moj bivši šef piše mi preporuku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('timski rad', 'timski rad', 'hr', 'phrase', 'A1', 'командна робота', 'collocation', '{"gender": "m"}'::jsonb, '["Timski rad mi je jako važan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ugovor na određeno', 'ugovor na odredeno', 'hr', 'phrase', 'A1', 'строковий договір', 'collocation', '{"gender": "m"}'::jsonb, '["Prvo dobiješ ugovor na određeno, na šest mjeseci."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ugovor na neodređeno', 'ugovor na neodredeno', 'hr', 'phrase', 'A1', 'безстроковий договір', 'collocation', '{"gender": "m"}'::jsonb, '["Nakon godinu dana dobila sam ugovor na neodređeno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('doprinosi', 'doprinosi', 'hr', 'noun', 'A1', 'соціальні внески', 'core', '{"gender": "m_pl"}'::jsonb, '["Od bruto plaće plaćaju se porez i doprinosi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('minimalna plaća', 'minimalna placa', 'hr', 'phrase', 'A1', 'мінімальна зарплата', 'collocation', '{"gender": "f"}'::jsonb, '["Minimalna plaća raste svake godine."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('regres', 'regres', 'hr', 'noun', 'A1', 'відпускні (виплата до відпустки)', 'core', '{"gender": "m"}'::jsonb, '["Regres dobivamo u lipnju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('božićnica', 'bozicnica', 'hr', 'noun', 'A1', 'різдвяна премія', 'core', '{"gender": "f"}'::jsonb, '["U prosincu dobivamo božićnicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('otkazni rok', 'otkazni rok', 'hr', 'phrase', 'A1', 'строк попередження про звільнення', 'collocation', '{"gender": "m"}'::jsonb, '["Otkazni rok je mjesec dana."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mentor', 'mentor', 'hr', 'noun', 'A1', 'наставник, ментор', 'core', '{"gender": "m"}'::jsonb, '["Prvi mjesec radim s mentorom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('obuka', 'obuka', 'hr', 'noun', 'A1', 'навчання (на роботі), інструктаж', 'core', '{"gender": "f"}'::jsonb, '["Obuka za nove radnike traje tri dana."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pravilnik', 'pravilnik', 'hr', 'noun', 'A1', 'внутрішні правила, положення', 'core', '{"gender": "m"}'::jsonb, '["Pročitajte pravilnik o radu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zabrana pušenja', 'zabrana pusenja', 'hr', 'phrase', 'A1', 'заборона куріння', 'collocation', '{"gender": "f"}'::jsonb, '["U cijeloj zgradi vrijedi zabrana pušenja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zaštita na radu', 'zastita na radu', 'hr', 'phrase', 'A1', 'охорона праці', 'collocation', '{"gender": "f"}'::jsonb, '["Prvi dan imamo tečaj zaštite na radu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uniforma', 'uniforma', 'hr', 'noun', 'A1', 'уніформа', 'core', '{"gender": "f"}'::jsonb, '["Konobari nose crnu uniformu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dopust', 'dopust', 'hr', 'noun', 'A1', 'відпустка (додаткова, за обставинами)', 'core', '{"gender": "m"}'::jsonb, '["Za vjenčanje imaš pravo na dva dana dopusta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('plaćeni dopust', 'placeni dopust', 'hr', 'phrase', 'A1', 'оплачувана відпустка (короткострокова)', 'collocation', '{"gender": "m"}'::jsonb, '["Za selidbu dobiješ jedan dan plaćenog dopusta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odsutnost', 'odsutnost', 'hr', 'noun', 'A1', 'відсутність', 'core', '{"gender": "f"}'::jsonb, '["Svaku odsutnost treba javiti šefu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('najaviti', 'najaviti', 'hr', 'verb', 'A1', 'попередити заздалегідь, оголосити', 'core', '{"aspect": "pfv", "present": {"1s": "najavim", "2s": "najaviš", "3s": "najavi"}}'::jsonb, '["Godišnji odmor treba najaviti mjesec dana prije."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ostaviti poruku', 'ostaviti poruku', 'hr', 'phrase', 'A1', 'залишити повідомлення', 'collocation', '{"aspect": "pfv", "present": {"1s": "ostavim poruku", "2s": "ostaviš poruku", "3s": "ostavi poruku"}}'::jsonb, '["Šef nije tu, možete mu ostaviti poruku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('doznaka', 'doznaka', 'hr', 'noun', 'A1', 'лікарняний лист (від лікаря)', 'core', '{"gender": "f"}'::jsonb, '["Doznaku za bolovanje daje obiteljski liječnik."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prehlađen', 'prehladen', 'hr', 'adjective', 'A1', 'застуджений', 'core', '{"f": "prehlađena", "n": "prehlađeno"}'::jsonb, '["Prehlađena sam i boli me grlo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zaraziti se', 'zaraziti se', 'hr', 'verb', 'A1', 'заразитися', 'core', '{"aspect": "pfv", "present": {"1s": "zarazim se", "2s": "zaraziš se", "3s": "zarazi se"}}'::jsonb, '["Ne želim da se kolege zaraze."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nadoknaditi', 'nadoknaditi', 'hr', 'verb', 'A1', 'надолужити, компенсувати', 'core', '{"aspect": "pfv", "present": {"1s": "nadoknadim", "2s": "nadoknadiš", "3s": "nadoknadi"}}'::jsonb, '["Sate mogu nadoknaditi u subotu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odsutan', 'odsutan', 'hr', 'adjective', 'A1', 'відсутній', 'core', '{"f": "odsutna", "n": "odsutno"}'::jsonb, '["Danas je pola tima odsutno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('fotokopirni aparat', 'fotokopirni aparat', 'hr', 'phrase', 'A1', 'копіювальний апарат, ксерокс', 'collocation', '{"gender": "m"}'::jsonb, '["Fotokopirni aparat je na kraju hodnika."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('spajalica', 'spajalica', 'hr', 'noun', 'A1', 'скріпка', 'core', '{"gender": "f"}'::jsonb, '["Spoji papire spajalicom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('klamerica', 'klamerica', 'hr', 'noun', 'A1', 'степлер', 'core', '{"gender": "f"}'::jsonb, '["Možeš li mi posuditi klamericu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('registrator', 'registrator', 'hr', 'noun', 'A1', 'реєстратор (папка для документів)', 'core', '{"gender": "m"}'::jsonb, '["Račune čuvamo u plavom registratoru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sala za sastanke', 'sala za sastanke', 'hr', 'phrase', 'A1', 'переговорна кімната', 'collocation', '{"gender": "f"}'::jsonb, '["Sastanak je u sali za sastanke na drugom katu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('aparat za kavu', 'aparat za kavu', 'hr', 'phrase', 'A1', 'кавовий автомат, кавоварка', 'collocation', '{"gender": "m"}'::jsonb, '["Aparat za kavu opet ne radi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;

-- 1б. Виправлені слова (2); повторний запуск нічого не змінює
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'dnevni sastanak' and ukrainian_translation = 'дейлі (стендап)' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'щоденна нарада; дейлі (стендап)' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'natječaj' and ukrainian_translation = 'конкурс / вакансія' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'конкурс (на посаду), вакансія' where id = r.id;
  end loop;
end $$;

-- 1а. Граматика A1.6: нові теми (1) і нові правила до наявних тем (1)
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '556c6f4d-dfe5-5150-99c6-01413a1d29dc', 'A1', 'Минулий час: radio sam, bila sam', 'Perfekt: radio sam, bila sam', 'Минулий час (perfekt) = коротка форма biti (sam, si, je, smo, ste, su) + дієприкметник на -o / -la / -lo / -li / -le. Рід, порядок слів, заперечення й питання; часті неправильні форми.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '5607ea09-9f10-5aaa-a751-c451fbdae7f4', '556c6f4d-dfe5-5150-99c6-01413a1d29dc', 'Biti + -o / -la: radio sam, radila sam', 'Минулий час = sam, si, je, smo, ste, su + дієприкметник: від інфінітива відкидаємо -ti і додаємо -o (він), -la (вона): raditi → radio / radila, čitati → čitao / čitala, živjeti → živio / živjela. «Я працював» — radio sam, «я працювала» — radila sam.', 'raditi → radio sam / radila sam · biti → bio sam / bila sam', '[{"hr": "Radila sam u hotelu.", "ua": "Я працювала в готелі."}, {"hr": "Jučer sam bio na poslu do sedam.", "ua": "Учора я був на роботі до сьомої."}, {"hr": "Gdje si živio prije?", "ua": "Де ти жив раніше?"}, {"hr": "Bili smo na razgovoru za posao.", "ua": "Ми були на співбесіді."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '556c6f4d-dfe5-5150-99c6-01413a1d29dc')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'e212a770-8832-5c87-87d4-d1af897b15d0', '556c6f4d-dfe5-5150-99c6-01413a1d29dc', 'Рід і число: radio, radila, radili', 'Дієприкметник узгоджується з підметом: on je radio, ona je radila, dijete je spavalo; у множині — -li (чоловічий і змішаний), -le (лише жінки): oni su radili, one su radile. Ввічливе Vi: Jeste li radili? — для однієї особи теж -li.', 'on radio · ona radila · ono radilo · oni radili · one radile', '[{"hr": "Marko je radio na gradilištu.", "ua": "Марко працював на будові."}, {"hr": "Ana je radila kao njegovateljica.", "ua": "Ана працювала доглядальницею."}, {"hr": "Djeca su spavala.", "ua": "Діти спали."}, {"hr": "Gdje ste radili prije?", "ua": "Де ви працювали раніше?"}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '556c6f4d-dfe5-5150-99c6-01413a1d29dc')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'a1b370c5-f1df-5c97-b3ac-b2af9d4ab1e3', '556c6f4d-dfe5-5150-99c6-01413a1d29dc', 'Порядок слів, заперечення й питання', 'Sam, si, je… — коротке слово на другому місці: Jučer sam radio. Radio sam jučer. Без займенника — дієприкметник першим: Radio sam. Заперечення — повні форми nisam, nisi, nije…: Nisam radio. Питання: Jesi li radio? Jeste li bili…? Відповідь: Jesam. / Nisam.', 'Radio sam. · Nisam radio. · Jesi li radio? — Jesam.', '[{"hr": "Nisam radila prošli tjedan.", "ua": "Я не працювала минулого тижня."}, {"hr": "Jeste li već radili u Hrvatskoj?", "ua": "Ви вже працювали в Хорватії?"}, {"hr": "Jesam, dvije godine.", "ua": "Так, два роки."}, {"hr": "Danas nije došao na posao.", "ua": "Сьогодні він не прийшов на роботу."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '556c6f4d-dfe5-5150-99c6-01413a1d29dc')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'b5db2cbd-eadd-5014-b27c-6c096b846867', '556c6f4d-dfe5-5150-99c6-01413a1d29dc', 'Часті неправильні: išao, došao, mogao, htio', 'Кілька частих дієслів мають особливу форму: ići → išao / išla, doći → došao / došla, otići → otišao / otišla, moći → mogao / mogla, htjeti → htio / htjela, reći → rekao / rekla, jesti → jeo / jela, pomoći → pomogao / pomogla.', 'ići → išao / išla · moći → mogao / mogla · reći → rekao / rekla', '[{"hr": "Išla sam na posao autobusom.", "ua": "Я їхала на роботу автобусом."}, {"hr": "Nisam mogao doći.", "ua": "Я не зміг прийти."}, {"hr": "Šef je rekao da počinjem u ponedjeljak.", "ua": "Начальник сказав, що я починаю в понеділок."}, {"hr": "Kada si došla u Zagreb?", "ua": "Коли ти приїхала до Загреба?"}]'::jsonb, 4
where exists (select 1 from public.grammar_topics where id = '556c6f4d-dfe5-5150-99c6-01413a1d29dc')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '556c6f4d-dfe5-5150-99c6-01413a1d29dc', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '556c6f4d-dfe5-5150-99c6-01413a1d29dc')
  and not exists (select 1 from public.content_reviews where entity_id = '556c6f4d-dfe5-5150-99c6-01413a1d29dc' and notes = 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.');
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Модальні дієслова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Модальні дієслова»'; end if;
  if exists (select 1 from public.grammar_rules where id = 'b61b483e-955c-54a3-a78e-4b8aed6432cc') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('b61b483e-955c-54a3-a78e-4b8aed6432cc', v_topic, 'Ne moraš і ne smiješ', 'Ne moraš — «не мусиш, не обов’язково»: Ne moraš doći u subotu. Ne smiješ — «не можна, заборонено»: Ovdje ne smiješ pušiti. Ne trebaš — «не треба»: Ne trebaš nositi kravatu. Не плутайте: «не мусиш» дає вибір, «не смієш» — ні.', 'ne moraš = не обов’язково · ne smiješ = не можна', '[{"hr": "Ne moraš raditi prekovremeno.", "ua": "Тобі не обов’язково працювати понаднормово."}, {"hr": "Na gradilištu ne smiješ raditi bez kacige.", "ua": "На будові не можна працювати без шолома."}, {"hr": "Ne trebate donijeti ništa.", "ua": "Нічого не треба приносити."}, {"hr": "Smijem li uzeti slobodan dan?", "ua": "Можна мені взяти вихідний?"}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', 'b61b483e-955c-54a3-a78e-4b8aed6432cc', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;

-- 2. Перебудова наявних уроків модуля A1.6
-- A1.6 · урок 50: Професії: хто де працює — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'b369f01f-4a84-57b4-98cb-150d236f4d7f';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Професії: хто де працює» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '14858aec-7921-527f-b3c3-e839da3fb494') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 50: Професії: хто де працює', title_hr = 'Lekcija 50: Zanimanja: tko gdje radi',
         objectives = '["Назвати професії: zidar, njegovateljica, dostavljač, računovođa", "Сказати, де працює людина: u tvornici, na gradilištu", "Місцевий: u skladištu, na recepciji, u bolnici"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Місцевий відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Місцевий відмінок»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zidar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gradilište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skladištar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skladište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tvornica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'njegovateljica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'medicinska sestra', v_pos);
  v_pos := pg_temp.word(v_lesson, 'liječnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'frizerka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'recepcioner', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sobarica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dostavljač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'računovođa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čuvar', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c1e8f4c-912b-5d59-8e54-ee93f4b90b27', 'fill_in_the_blank', 'Moja sestra radi u ___.', 'bolnici', '["bolnici", "bolnicu", "bolnica", "bolnice"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ba97e9ac-a674-5878-a078-df7a5178fcc2', 'multiple_choice', 'Що означає «liječnica»?', 'лікарка', '["перукарка", "охоронець; сторож", "лікарка", "кур’єр доставки, доставник"]'::jsonb, 'A1', 2, 'PUBLISHED', 'liječnica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '64d1419a-7aba-5e56-b320-c5f773bb02fd', 'multiple_choice', 'Що означає «dostavljač»?', 'кур’єр доставки, доставник', '["бухгалтер", "кур’єр доставки, доставник", "лікарка", "адміністратор (на рецепції)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'dostavljač', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'edca327f-55df-5c03-bab5-abb4a69159ff', 'multiple_choice', 'Що означає «sobarica»?', 'покоївка', '["перукарка", "кур’єр доставки, доставник", "покоївка", "фабрика, завод"]'::jsonb, 'A1', 4, 'PUBLISHED', 'sobarica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6601dd24-5724-5442-a09f-392ddce5b0d8', 'multiple_choice', 'Як хорватською «охоронець; сторож»?', 'čuvar', '["računovođa", "recepcioner", "zidar", "čuvar"]'::jsonb, 'A1', 5, 'PUBLISHED', 'čuvar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bc2c0ed8-c740-55e5-a63e-957f5f7fdb0c', 'multiple_choice', 'Як хорватською «доглядальниця»?', 'njegovateljica', '["medicinska sestra", "recepcioner", "njegovateljica", "frizerka"]'::jsonb, 'A1', 6, 'PUBLISHED', 'njegovateljica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '85a735b1-3c13-5213-826e-ea71f8ed270c', 'type_answer', 'Напишіть хорватською: «перукарка»', 'frizerka', null, 'A1', 7, 'PUBLISHED', 'frizerka', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '49a02d90-b6f1-5959-9f09-631a99d7a449', 'type_answer', 'Напишіть хорватською: «фабрика, завод»', 'tvornica', null, 'A1', 8, 'PUBLISHED', 'tvornica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '59d789bd-010d-56a4-b625-5c1bfc2803ad', 'type_answer', 'Напишіть хорватською: «адміністратор (на рецепції)»', 'recepcioner', null, 'A1', 9, 'PUBLISHED', 'recepcioner', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ad6d54c5-2fc1-5975-b350-3c4e2eaab0a1', 'sentence_builder', 'Складіть: «Він працює на будові.»', 'On radi na gradilištu.', '["radi", "On", "na", "gradilištu."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ed4c5d43-c461-5977-8c40-e676a6ccd2a8', 'sentence_builder', 'Складіть: «Я працюю на рецепції.»', 'Radim na recepciji.', '["Radim", "recepciji.", "na"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e827b0b2-9a41-5080-9fbb-d626156ae1ea', 'listening', 'Прослухайте і складіть фразу', 'On je zidar, radi na gradilištu u Novom Zagrebu.', '["Novom", "je", "u", "Zagrebu.", "na", "On", "gradilištu", "radi", "zidar,"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3919c412-f713-5355-bab0-fe815af17b8a', 'listening', 'Прослухайте і складіть фразу', 'Je li teško?', '["teško?", "Je", "li"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6843f07e-3426-5b44-9723-0ca7abf3b782', 'speaking', 'Ким ти працюєш?', 'Što radiš po zanimanju?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9719e8d2-60f8-55c9-b6dc-12ce95ec641d', 'speaking', 'Я працюю на фабриці.', 'Radim u tvornici.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('14858aec-7921-527f-b3c3-e839da3fb494', v_lesson, 'Хто ким працює?', 'Tko što radi?', 3501, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('9241af11-30c6-5db4-9469-e7ac461ecdf9', '14858aec-7921-527f-b3c3-e839da3fb494', 'Ivana', 'Dašo, gdje radi tvoj brat?', 'Дашо, де працює твій брат?', 1);
  perform pg_temp.turn('5cebf48f-2cec-5e9e-9a3b-d9c4b4d38277', '14858aec-7921-527f-b3c3-e839da3fb494', 'Daša', 'On je zidar, radi na gradilištu u Novom Zagrebu.', 'Він муляр, працює на будові в Новому Загребі.', 2);
  perform pg_temp.turn('c058020c-a3b6-5c6a-ad30-08db3257b9bf', '14858aec-7921-527f-b3c3-e839da3fb494', 'Ivana', 'A tvoja sestra?', 'А твоя сестра?', 3);
  perform pg_temp.turn('f33b3fdd-f7e0-5c71-b97c-f23afdff384e', '14858aec-7921-527f-b3c3-e839da3fb494', 'Daša', 'Ona je njegovateljica u domu za starije.', 'Вона доглядальниця в будинку для літніх людей.', 4);
  perform pg_temp.turn('f033ed06-a130-5d0c-aab2-d5b16651beb9', '14858aec-7921-527f-b3c3-e839da3fb494', 'Ivana', 'Moj muž je skladištar u tvornici.', 'Мій чоловік комірник на фабриці.', 5);
  perform pg_temp.turn('5a201e7b-b519-556b-a98c-adbf16bc1504', '14858aec-7921-527f-b3c3-e839da3fb494', 'Daša', 'Radi li u smjenama?', 'Він працює позмінно?', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9df47bb1-92db-529f-8828-9eb1c6cc591e', v_lesson, 'У готелі', 'U hotelu', 3502, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('08d9c1fd-a754-53e6-82e6-4ad0805b6b12', '9df47bb1-92db-529f-8828-9eb1c6cc591e', 'Marko', 'Darja, što radiš u hotelu?', 'Даріє, що ти робиш у готелі?', 1);
  perform pg_temp.turn('bdeb3fdd-236f-5cdd-b5b4-3238eee52d2f', '9df47bb1-92db-529f-8828-9eb1c6cc591e', 'Darja', 'Radim na recepciji, a moja prijateljica je sobarica.', 'Я працюю на рецепції, а моя подруга — покоївка.', 2);
  perform pg_temp.turn('2e63a5ac-f1b8-57ab-a191-d44e94ab9ec8', '9df47bb1-92db-529f-8828-9eb1c6cc591e', 'Marko', 'Je li teško?', 'Важко?', 3);
  perform pg_temp.turn('c515e330-f040-5009-b15c-cc898746f6bd', '9df47bb1-92db-529f-8828-9eb1c6cc591e', 'Darja', 'Ljeti je puno gostiju, ali kolege su super.', 'Влітку багато гостей, але колеги чудові.', 4);
  perform pg_temp.turn('7ffd946d-f65c-5a23-8218-59d4a4369f71', '9df47bb1-92db-529f-8828-9eb1c6cc591e', 'Marko', 'Ja tražim posao kao dostavljač ili čuvar.', 'А я шукаю роботу доставником або охоронцем.', 5);
  perform pg_temp.turn('e97cd762-7d73-544a-b439-f4bec6439ff1', '9df47bb1-92db-529f-8828-9eb1c6cc591e', 'Darja', 'Pitaj na recepciji, trebaju noćnog čuvara.', 'Спитай на рецепції, їм потрібен нічний охоронець.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 51: Мій робочий день — перебудова: 13 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'd813e9c0-2331-59d8-90f1-cea7e9a61c7d';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Мій робочий день» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'd1db246a-2c6b-524d-a8ee-50ebc7b62a83') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 51: Мій робочий день', title_hr = 'Lekcija 51: Moj radni dan',
         objectives = '["Розповісти про свій робочий день: sastanak, izvještaj, klijenti", "Сказати, коли починаєте й закінчуєте", "Теперішній час: počinjem, završavam, šaljem"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Теперішній час' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Теперішній час»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'šef', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nadređeni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolega', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dnevni sastanak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izvještaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obaveza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zadatak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'počinjati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'završavati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'klijent', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mail', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prekovremeno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rad od kuće', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '151cfdcc-882c-53d9-ab7c-277767c3f8ae', 'fill_in_the_blank', 'Radni dan ___ u osam sati.', 'počinje', '["počinje", "počinješ", "počinjem", "počinjati"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e1050a8-ec49-5669-936a-057a5849ead5', 'multiple_choice', 'Що означає «nadređeni»?', 'керівник, безпосередній начальник', '["керівник, безпосередній начальник", "клієнт", "завдання", "щоденна нарада; дейлі (стендап)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'nadređeni', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6786be20-45c3-5111-9db8-2f3943be0440', 'multiple_choice', 'Що означає «šef»?', 'начальник / шеф', '["закінчувати", "починати", "завдання", "начальник / шеф"]'::jsonb, 'A1', 3, 'PUBLISHED', 'šef', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '57ed3d70-b8e7-5dd4-9329-f721656e68ec', 'multiple_choice', 'Що означає «mail»?', 'електронний лист; імейл', '["клієнт", "щоденна нарада; дейлі (стендап)", "електронний лист; імейл", "звіт"]'::jsonb, 'A1', 4, 'PUBLISHED', 'mail', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '78a3e5c1-cf18-54ee-8983-cca2c638c394', 'multiple_choice', 'Як хорватською «понаднормово»?', 'prekovremeno', '["obaveza", "prekovremeno", "izvještaj", "završavati"]'::jsonb, 'A1', 5, 'PUBLISHED', 'prekovremeno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '528a08c7-d509-51f7-b681-f976971c3611', 'multiple_choice', 'Як хорватською «завдання»?', 'zadatak', '["završavati", "dnevni sastanak", "zadatak", "nadređeni"]'::jsonb, 'A1', 6, 'PUBLISHED', 'zadatak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a376e907-74a2-5134-a28a-775943a82018', 'type_answer', 'Напишіть хорватською: «закінчувати»', 'završavati', null, 'A1', 7, 'PUBLISHED', 'završavati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '81f1c613-ce8b-5150-86b7-e7d9c87ffaf3', 'type_answer', 'Напишіть хорватською: «звіт»', 'izvještaj', null, 'A1', 8, 'PUBLISHED', 'izvještaj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f1f92f6c-046e-5bf6-a7a9-d52a7c53a744', 'type_answer', 'Напишіть хорватською: «клієнт»', 'klijent', null, 'A1', 9, 'PUBLISHED', 'klijent', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5eb4c4ac-4951-5198-b2fc-471385c9fd8a', 'sentence_builder', 'Складіть: «Я закінчую о четвертій.»', 'Završavam u četiri.', '["Završavam", "četiri.", "u"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f33fc73-5047-573e-a829-7f33cf9ff92f', 'sentence_builder', 'Складіть: «Сьогодні в мене нарада.»', 'Danas imam sastanak.', '["imam", "Danas", "sastanak."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1513ecb0-59e5-5043-9345-be4c7b7d4ebc', 'listening', 'Прослухайте і складіть фразу', 'Imaš li puno obaveza?', '["puno", "obaveza?", "Imaš", "li"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd03031ee-75a9-5b4d-a4f3-d8b07f40f4aa', 'listening', 'Прослухайте і складіть фразу', 'Preko videopoziva i maila.', '["i", "videopoziva", "Preko", "maila."]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '408da13e-bee7-5ae9-9230-72057804841a', 'speaking', 'Коли ти починаєш працювати?', 'Kada počinješ raditi?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e6f2df08-13bc-55e0-b21e-066301488707', 'speaking', 'Я працюю з дому.', 'Radim od kuće.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d1db246a-2c6b-524d-a8ee-50ebc7b62a83', v_lesson, 'Як минає день?', 'Kako izgleda tvoj dan?', 3511, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('12b422dd-18fb-5b67-9c5b-2b206cf6b92b', 'd1db246a-2c6b-524d-a8ee-50ebc7b62a83', 'Luka', 'Dašo, kada počinješ raditi?', 'Дашо, коли ти починаєш працювати?', 1);
  perform pg_temp.turn('6173f3af-863a-5b0b-b750-8cf44a19aed0', 'd1db246a-2c6b-524d-a8ee-50ebc7b62a83', 'Daša', 'U osam. Prvo čitam mailove, a u devet je dnevni sastanak.', 'О восьмій. Спершу читаю листи, а о дев’ятій — щоденна нарада.', 2);
  perform pg_temp.turn('5b7daac9-376b-5cec-a9b5-ddad4f094d1e', 'd1db246a-2c6b-524d-a8ee-50ebc7b62a83', 'Luka', 'Imaš li puno obaveza?', 'У тебе багато обов’язків?', 3);
  perform pg_temp.turn('e3b9f781-b544-5599-814f-1e42841ed118', 'd1db246a-2c6b-524d-a8ee-50ebc7b62a83', 'Daša', 'Imam. Petkom pišem izvještaj za nadređenu.', 'Багато. По п’ятницях пишу звіт для керівниці.', 4);
  perform pg_temp.turn('6251f2e4-95cf-5868-b0ff-596822d70fba', 'd1db246a-2c6b-524d-a8ee-50ebc7b62a83', 'Luka', 'A kada završavaš?', 'А коли закінчуєш?', 5);
  perform pg_temp.turn('b6317d64-0e9e-5ceb-ab96-06009bee740b', 'd1db246a-2c6b-524d-a8ee-50ebc7b62a83', 'Daša', 'U četiri, ali ovaj tjedan radim prekovremeno.', 'О четвертій, але цього тижня працюю понаднормово.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e7632b25-6550-5484-8452-b5e456d54e9f', v_lesson, 'Робота з дому', 'Rad od kuće', 3512, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('0f467efd-b02e-54db-85ce-f4af9b6a8885', 'e7632b25-6550-5484-8452-b5e456d54e9f', 'Marko', 'Darja, radiš li od kuće?', 'Даріє, ти працюєш з дому?', 1);
  perform pg_temp.turn('ba916b82-6009-54f9-8f14-fe36b67c9538', 'e7632b25-6550-5484-8452-b5e456d54e9f', 'Darja', 'Dva dana tjedno. Šef kaže da je to u redu.', 'Два дні на тиждень. Начальник каже, що це нормально.', 2);
  perform pg_temp.turn('0259da53-2162-5c51-ad75-72dd59ccdc71', 'e7632b25-6550-5484-8452-b5e456d54e9f', 'Marko', 'Kako razgovaraš s klijentima?', 'Як ти спілкуєшся з клієнтами?', 3);
  perform pg_temp.turn('d2ef177e-64ff-5e8b-a75b-1a58931a2e1b', 'e7632b25-6550-5484-8452-b5e456d54e9f', 'Darja', 'Preko videopoziva i maila.', 'Через відеодзвінки й імейл.', 4);
  perform pg_temp.turn('cf5c4c29-9989-5ca1-8c6a-bc1949eb79d4', 'e7632b25-6550-5484-8452-b5e456d54e9f', 'Marko', 'A kolege?', 'А колеги?', 5);
  perform pg_temp.turn('02758b77-4c60-5bd3-bd2e-ea398c3d119f', 'e7632b25-6550-5484-8452-b5e456d54e9f', 'Darja', 'Vidimo se u uredu utorkom i četvrtkom.', 'Бачимося в офісі по вівторках і четвергах.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 52: Шукаю роботу — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'c9b87882-5e31-5485-aea7-0169216466a8';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Шукаю роботу» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '130aea37-83b0-5214-924b-f9314775de2c') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 52: Шукаю роботу', title_hr = 'Lekcija 52: Tražim posao',
         objectives = '["Знайти вакансію й зрозуміти умови: satnica, stalan posao, nepuno radno vrijeme", "Запитати роботодавця про умови", "Питання: Koliki je…? Trebam li…? Kako se…?"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Побудова питань' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Побудова питань»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'oglas za posao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'natječaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'životopis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'motivacijsko pismo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijaviti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poslodavac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radno mjesto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uvjet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'satnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stalan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plaćen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'honorarni posao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nepuno radno vrijeme', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zavod za zapošljavanje', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '1281030c-4dc3-53ea-bccc-4700af555a71', 'fill_in_the_blank', 'Kolika je ___?', 'satnica', '["satnicom", "satnici", "satnicu", "satnica"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '20ba5677-9476-55b8-88c7-51a75ef55e13', 'multiple_choice', 'Що означає «zavod za zapošljavanje»?', 'центр зайнятості', '["постійний", "центр зайнятості", "погодинна оплата", "мотиваційний лист"]'::jsonb, 'A1', 2, 'PUBLISHED', 'zavod za zapošljavanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7c050f31-97c0-5077-ac5c-316e09cc5da8', 'multiple_choice', 'Що означає «oglas za posao»?', 'оголошення про роботу, вакансія', '["робоче місце", "оголошення про роботу, вакансія", "зареєструватися; подати заявку", "центр зайнятості"]'::jsonb, 'A1', 3, 'PUBLISHED', 'oglas za posao', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '478fe433-4ce2-5d08-82db-babf1167a665', 'multiple_choice', 'Що означає «nepuno radno vrijeme»?', 'неповний робочий день', '["постійний", "підробіток, робота за договором", "центр зайнятості", "неповний робочий день"]'::jsonb, 'A1', 4, 'PUBLISHED', 'nepuno radno vrijeme', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '83dab523-168c-53ff-a275-37ccc56150c5', 'multiple_choice', 'Як хорватською «резюме»?', 'životopis', '["satnica", "motivacijsko pismo", "životopis", "natječaj"]'::jsonb, 'A1', 5, 'PUBLISHED', 'životopis', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '864718ac-56eb-5061-80c1-56c5a07794d7', 'multiple_choice', 'Як хорватською «оплачуваний; оплачений»?', 'plaćen', '["stalan", "plaćen", "satnica", "životopis"]'::jsonb, 'A1', 6, 'PUBLISHED', 'plaćen', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7fd2e9d7-422d-5212-b33b-d15c23455abe', 'type_answer', 'Напишіть хорватською: «постійний»', 'stalan', null, 'A1', 7, 'PUBLISHED', 'stalan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d243542-c31d-5c50-9586-a8b47b134ca1', 'type_answer', 'Напишіть хорватською: «роботодавець»', 'poslodavac', null, 'A1', 8, 'PUBLISHED', 'poslodavac', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '973988c6-69e5-5ddb-a287-9edbac144c70', 'type_answer', 'Напишіть хорватською: «умова»', 'uvjet', null, 'A1', 9, 'PUBLISHED', 'uvjet', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'edf2383b-833e-54a3-b226-719640bd6a2b', 'sentence_builder', 'Складіть: «Як я можу подати заявку?»', 'Kako se mogu prijaviti?', '["se", "prijaviti?", "mogu", "Kako"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2d949f97-5a02-5f3e-bc91-60ce6c5c3b68', 'sentence_builder', 'Складіть: «Я шукаю постійну роботу.»', 'Tražim stalan posao.', '["posao.", "Tražim", "stalan"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'caf5f787-5d8e-5a12-89c3-cf8e8318f277', 'listening', 'Прослухайте і складіть фразу', 'Kolika je satnica?', '["satnica?", "Kolika", "je"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd0f0e227-c080-5edd-abab-82e6545497bf', 'listening', 'Прослухайте і складіть фразу', 'Zavod vam može platiti tečaj.', '["Zavod", "vam", "platiti", "može", "tečaj."]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4bcd779d-c93e-501a-b251-d931e2b731da', 'speaking', 'Надішліть резюме, будь ласка.', 'Pošaljite životopis, molim.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '36f794ac-aa34-5f5c-921e-446a89f95c69', 'speaking', 'Це робота на неповний день?', 'Je li posao na nepuno radno vrijeme?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('130aea37-83b0-5214-924b-f9314775de2c', v_lesson, 'Вакансія в пекарні', 'Oglas u pekari', 3521, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('1a8dab36-54f9-529f-8bc7-62d29ae832c5', '130aea37-83b0-5214-924b-f9314775de2c', 'Daša', 'Vidjela sam oglas za posao. Tražite li još prodavačicu?', 'Я бачила оголошення про роботу. Ви ще шукаєте продавчиню?', 1);
  perform pg_temp.turn('252a8fb4-e994-528c-9996-f97a1b2da495', '130aea37-83b0-5214-924b-f9314775de2c', 'Poslodavac', 'Tražimo. Radno mjesto je na nepuno radno vrijeme.', 'Шукаємо. Це робота на неповний день.', 2);
  perform pg_temp.turn('31c90b88-b01b-5a2e-bcd8-cf20280b63f8', '130aea37-83b0-5214-924b-f9314775de2c', 'Daša', 'Kolika je satnica?', 'Яка погодинна оплата?', 3);
  perform pg_temp.turn('f5221bdc-be27-5418-969a-009c6776e05a', '130aea37-83b0-5214-924b-f9314775de2c', 'Poslodavac', 'Šest eura neto, plaćen prijevoz.', 'Шість євро нетто, проїзд оплачується.', 4);
  perform pg_temp.turn('5fa29a44-ac59-5430-9889-08d721e5f1c8', '130aea37-83b0-5214-924b-f9314775de2c', 'Daša', 'Kako se mogu prijaviti?', 'Як я можу подати заявку?', 5);
  perform pg_temp.turn('39c2c018-26ac-56bf-a8a2-0a0a80eaba7d', '130aea37-83b0-5214-924b-f9314775de2c', 'Poslodavac', 'Pošaljite životopis i kratko motivacijsko pismo.', 'Надішліть резюме й короткий мотиваційний лист.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('580ae0a1-64e1-5267-89da-d4b23eda9a58', v_lesson, 'У центрі зайнятості', 'Na zavodu za zapošljavanje', 3522, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('50536384-9847-5d67-a326-7c4c7a6a9e0c', '580ae0a1-64e1-5267-89da-d4b23eda9a58', 'Marko', 'Dobar dan, tražim stalan posao.', 'Добрий день, я шукаю постійну роботу.', 1);
  perform pg_temp.turn('ba658c9c-e6de-5c15-8376-c77a697b6d10', '580ae0a1-64e1-5267-89da-d4b23eda9a58', 'Savjetnica', 'Imamo natječaj za skladištara. Ima li uvjeta koje ne ispunjavate?', 'Є вакансія комірника. Є умови, яким ви не відповідаєте?', 2);
  perform pg_temp.turn('e228fb26-d213-54ba-b8d0-5409770e26b4', '580ae0a1-64e1-5267-89da-d4b23eda9a58', 'Marko', 'Nemam vozačku za viličar.', 'У мене немає посвідчення на навантажувач.', 3);
  perform pg_temp.turn('93787ad5-443c-5ce4-9fca-3848ac14f426', '580ae0a1-64e1-5267-89da-d4b23eda9a58', 'Savjetnica', 'Zavod vam može platiti tečaj.', 'Центр може оплатити вам курси.', 4);
  perform pg_temp.turn('09cca426-8b03-5324-ae9a-7ef625374631', '580ae0a1-64e1-5267-89da-d4b23eda9a58', 'Marko', 'Super. A do tada? Trebam li honorarni posao?', 'Чудово. А до того? Мені шукати підробіток?', 5);
  perform pg_temp.turn('7dd42fcd-9aba-552f-ba72-c78cddb61223', '580ae0a1-64e1-5267-89da-d4b23eda9a58', 'Savjetnica', 'Možete, samo nam javite.', 'Можете, тільки повідомте нам.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 53: Співбесіда: де ви працювали? — перебудова: 15 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '92858dbe-ede1-5bc5-b80a-c796c5598019';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Співбесіда: де ви працювали?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '0a6b020d-ea8a-52dd-9cba-22cda92936e5') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 53: Співбесіда: де ви працювали?', title_hr = 'Lekcija 53: Razgovor za posao: gdje ste radili?',
         objectives = '["Розповісти про досвід роботи в минулому часі: radila sam, bio sam", "Відповісти про освіту й навички", "Минулий час: radio sam, završila sam, otišao sam"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Минулий час: radio sam, bila sam»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'razgovor za posao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razgovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prethodni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bivši', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iskustvo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaposliti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'početi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'završiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'diploma', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fakultet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vještina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'timski rad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odgovornost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otkaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dati otkaz', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f920f6c2-2620-577a-be2c-0fa1fa368070', 'fill_in_the_blank', 'Prije sam ___ u hotelu.', 'radila', '["radit ću", "radila", "raditi", "radim"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7b71c822-9c8e-5579-aace-f65e4331b3ce', 'multiple_choice', 'Що означає «razgovor za posao»?', 'співбесіда', '["факультет / університет", "відповідальність", "розмова / бесіда", "співбесіда"]'::jsonb, 'A1', 2, 'PUBLISHED', 'razgovor za posao', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ed4a7145-babd-51a5-935c-fea9711a35c5', 'multiple_choice', 'Що означає «timski rad»?', 'командна робота', '["факультет / університет", "командна робота", "звільнення", "влаштуватися на роботу"]'::jsonb, 'A1', 3, 'PUBLISHED', 'timski rad', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '57c08e57-db78-5c5a-8634-3ed4383f2290', 'multiple_choice', 'Що означає «zaposliti se»?', 'влаштуватися на роботу', '["влаштуватися на роботу", "факультет / університет", "розмова / бесіда", "закінчити"]'::jsonb, 'A1', 4, 'PUBLISHED', 'zaposliti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f6f2153-c00a-5dd0-a178-66ee63d1b823', 'multiple_choice', 'Як хорватською «відповідальність»?', 'odgovornost', '["fakultet", "razgovor za posao", "vještina", "odgovornost"]'::jsonb, 'A1', 5, 'PUBLISHED', 'odgovornost', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd77779b4-eb5a-590e-a126-b2394662a62e', 'multiple_choice', 'Як хорватською «досвід»?', 'iskustvo', '["vještina", "završiti", "početi", "iskustvo"]'::jsonb, 'A1', 6, 'PUBLISHED', 'iskustvo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a493b564-b7a9-5ce1-924c-cc5363edbdb8', 'type_answer', 'Напишіть хорватською: «диплом»', 'diploma', null, 'A1', 7, 'PUBLISHED', 'diploma', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8b316de8-1e93-5b3b-8eb3-333938f7fcae', 'type_answer', 'Напишіть хорватською: «почати»', 'početi', null, 'A1', 8, 'PUBLISHED', 'početi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9415bdcf-60ac-5f5c-b0bc-be1239078caf', 'type_answer', 'Напишіть хорватською: «попередній»', 'prethodni', null, 'A1', 9, 'PUBLISHED', 'prethodni', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a10989e6-7383-5cba-8af0-b8030f8de518', 'sentence_builder', 'Складіть: «Де ви працювали раніше?»', 'Gdje ste radili prije?', '["ste", "prije?", "Gdje", "radili"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '567ed1ac-02c1-52fb-b0d6-5e1f1fed21d3', 'sentence_builder', 'Складіть: «Я закінчила університет.»', 'Završila sam fakultet.', '["sam", "Završila", "fakultet."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ee9e7a5b-074a-531e-b4ae-08b9a82665c9', 'listening', 'Прослухайте і складіть фразу', 'Gdje ste radili prije?', '["Gdje", "ste", "prije?", "radili"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fb18af5f-89e7-5bef-a210-1e3d7e02b96f', 'listening', 'Прослухайте і складіть фразу', 'Organizacija. Volim odgovornost.', '["Volim", "Organizacija.", "odgovornost."]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '53d9026c-470c-53de-8ad5-9f580d3d891a', 'speaking', 'Я працював водієм.', 'Radio sam kao vozač.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '398ea751-3cdc-552f-bc60-9e5536d11898', 'speaking', 'Коли можете почати?', 'Kada možete početi?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0a6b020d-ea8a-52dd-9cba-22cda92936e5', v_lesson, 'Співбесіда', 'Razgovor za posao', 3531, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('45f05ccd-e9f9-51a6-9bbb-10c790f8f7e9', '0a6b020d-ea8a-52dd-9cba-22cda92936e5', 'Poslodavka', 'Gdje ste radili prije?', 'Де ви працювали раніше?', 1);
  perform pg_temp.turn('4ee82181-f431-5266-912a-c9fa9471dd80', '0a6b020d-ea8a-52dd-9cba-22cda92936e5', 'Daša', 'U Kijevu sam radila kao računovođa šest godina.', 'У Києві я шість років працювала бухгалтеркою.', 2);
  perform pg_temp.turn('b2e304bd-47a9-5987-8450-18c91f249dc7', '0a6b020d-ea8a-52dd-9cba-22cda92936e5', 'Poslodavka', 'Zašto ste otišli s prethodnog posla?', 'Чому ви пішли з попередньої роботи?', 3);
  perform pg_temp.turn('f69e4ab5-5511-5a84-931b-7752cf4a1368', '0a6b020d-ea8a-52dd-9cba-22cda92936e5', 'Daša', 'Došla sam u Hrvatsku, pa sam dala otkaz.', 'Я приїхала до Хорватії, тож звільнилася.', 4);
  perform pg_temp.turn('ccd81d26-2f2b-5e16-8016-e468b23cf939', '0a6b020d-ea8a-52dd-9cba-22cda92936e5', 'Poslodavka', 'Jeste li završili fakultet?', 'Ви закінчили університет?', 5);
  perform pg_temp.turn('0073abe1-eefd-5e49-ae2b-ce3af2edc87b', '0a6b020d-ea8a-52dd-9cba-22cda92936e5', 'Daša', 'Jesam, ekonomiju. Diplomu imam i na hrvatskom.', 'Так, економічний. Диплом маю й хорватською.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c37fa586-6741-5933-aced-262fac1cc5c1', v_lesson, 'Навички й досвід', 'Vještine i iskustvo', 3532, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('cdc75f78-00be-5741-b276-477b7a25655a', 'c37fa586-6741-5933-aced-262fac1cc5c1', 'Šef', 'Imate li iskustva s timskim radom?', 'У вас є досвід командної роботи?', 1);
  perform pg_temp.turn('d73d74ff-8076-5ef6-a450-0925c226b834', 'c37fa586-6741-5933-aced-262fac1cc5c1', 'Luka', 'Imam. Na bivšem poslu vodio sam tim od pet ljudi.', 'Є. На колишній роботі я керував командою з п’яти людей.', 2);
  perform pg_temp.turn('5cf2e63e-190c-5ce6-989c-0170bbc15a72', 'c37fa586-6741-5933-aced-262fac1cc5c1', 'Šef', 'Koja je vaša najjača vještina?', 'Яка ваша найсильніша навичка?', 3);
  perform pg_temp.turn('7317f684-d044-501d-a147-8c8ee19649b0', 'c37fa586-6741-5933-aced-262fac1cc5c1', 'Luka', 'Organizacija. Volim odgovornost.', 'Організація. Я люблю відповідальність.', 4);
  perform pg_temp.turn('9cae515d-3207-5467-9589-19b703fc47a2', 'c37fa586-6741-5933-aced-262fac1cc5c1', 'Šef', 'Kada možete početi?', 'Коли можете почати?', 5);
  perform pg_temp.turn('492bfc95-684d-5b73-ba8e-5af9580ed32e', 'c37fa586-6741-5933-aced-262fac1cc5c1', 'Luka', 'Od prvog sljedećeg mjeseca.', 'З першого числа наступного місяця.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 54: Договір і зарплата — перебудова: 16 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '4d6f3498-2cc5-54a0-b4e4-c66add71ef12';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Договір і зарплата» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '5c284535-b25e-5276-be73-f63463cf2c46') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 54: Договір і зарплата', title_hr = 'Lekcija 54: Ugovor i plaća',
         objectives = '["Розібратися в договорі: na određeno, probni rad, otkazni rok", "Зрозуміти зарплату: bruto, neto, porez, regres", "Ne moraš і ne smiješ: що обов’язково, а що заборонено"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Модальні дієслова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Модальні дієслова»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'ugovor na određeno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugovor na neodređeno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'probni rad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'puno radno vrijeme', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smjena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bruto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'porez', v_pos);
  v_pos := pg_temp.word(v_lesson, 'doprinosi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'isplata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'platna lista', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prekovremeni sati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'minimalna plaća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'regres', v_pos);
  v_pos := pg_temp.word(v_lesson, 'božićnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otkazni rok', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f9261f71-41d4-5410-8a10-7e49d7ae24ed', 'fill_in_the_blank', 'Ne ___ raditi u subotu, to nije obavezno.', 'moraš', '["smiješ", "moraš", "možeš li", "moram li"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be459db2-e3f5-5143-a8c1-79a984bd6c25', 'multiple_choice', 'Що означає «smjena»?', 'зміна (на роботі)', '["брутто (до податків)", "випробувальний термін", "строк попередження про звільнення", "зміна (на роботі)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'smjena', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '90276eb9-0935-5b9a-9345-578fdd3eaef8', 'multiple_choice', 'Що означає «regres»?', 'відпускні (виплата до відпустки)', '["повний робочий день", "строк попередження про звільнення", "безстроковий договір", "відпускні (виплата до відпустки)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'regres', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '983d8e2e-49ef-51c9-9ea7-6c82bf7139a1', 'multiple_choice', 'Що означає «minimalna plaća»?', 'мінімальна зарплата', '["строк попередження про звільнення", "мінімальна зарплата", "виплата / зняття", "різдвяна премія"]'::jsonb, 'A1', 4, 'PUBLISHED', 'minimalna plaća', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e7919ed9-9b77-5384-953e-0f47767dffea', 'multiple_choice', 'Що означає «ugovor na određeno»?', 'строковий договір', '["строковий договір", "розрахунковий листок", "понаднормові години", "випробувальний термін"]'::jsonb, 'A1', 5, 'PUBLISHED', 'ugovor na određeno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0c0dc2ec-dba4-59aa-a707-d3ba47bb66f4', 'multiple_choice', 'Як хорватською «понаднормові години»?', 'prekovremeni sati', '["božićnica", "otkazni rok", "probni rad", "prekovremeni sati"]'::jsonb, 'A1', 6, 'PUBLISHED', 'prekovremeni sati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '03f30aba-a181-5afd-a691-834659ab5123', 'multiple_choice', 'Як хорватською «соціальні внески»?', 'doprinosi', '["doprinosi", "božićnica", "prekovremeni sati", "porez"]'::jsonb, 'A1', 7, 'PUBLISHED', 'doprinosi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a5e24b6-e6b1-5f56-b973-54699d56f903', 'type_answer', 'Напишіть хорватською: «розрахунковий листок»', 'platna lista', null, 'A1', 8, 'PUBLISHED', 'platna lista', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '031e103b-24b1-52de-85a8-729f112a4e5a', 'type_answer', 'Напишіть хорватською: «податок»', 'porez', null, 'A1', 9, 'PUBLISHED', 'porez', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2dd9366f-cb92-57b0-a1f3-0838deddfcdf', 'sentence_builder', 'Складіть: «Коли виплата зарплати?»', 'Kada je isplata plaće?', '["isplata", "je", "plaće?", "Kada"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cd6861be-7281-54b9-91a6-fa0104ef9c75', 'sentence_builder', 'Складіть: «Тобі не обов’язково працювати в суботу.»', 'Ne moraš raditi u subotu.', '["u", "raditi", "Ne", "moraš", "subotu."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7612a60c-cc55-5839-a924-885eac9f4ee6', 'listening', 'Прослухайте і складіть фразу', 'Koliki je otkazni rok?', '["Koliki", "otkazni", "rok?", "je"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9ce82225-ddf8-578a-aa46-6ac6b993611a', 'listening', 'Прослухайте і складіть фразу', 'Kada je isplata?', '["je", "isplata?", "Kada"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ee672bde-4206-5738-a7af-ba5da2a0889a', 'speaking', 'Договір строковий?', 'Je li ugovor na određeno?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '55d9f7d9-f12c-52ce-aa6b-4ad3d0b650c2', 'speaking', 'Яка зарплата нетто?', 'Kolika je neto plaća?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5c284535-b25e-5276-be73-f63463cf2c46', v_lesson, 'Підписуємо договір', 'Potpisujemo ugovor', 3541, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('c64060fb-b39d-546a-931b-84f5e66b1fff', '5c284535-b25e-5276-be73-f63463cf2c46', 'Daša', 'Je li ugovor na određeno ili na neodređeno?', 'Договір строковий чи безстроковий?', 1);
  perform pg_temp.turn('749cb9d2-4579-5be2-9ffe-ac0c271a2566', '5c284535-b25e-5276-be73-f63463cf2c46', 'Referentica', 'Prvo na određeno, s probnim radom od tri mjeseca.', 'Спершу строковий, з випробувальним терміном три місяці.', 2);
  perform pg_temp.turn('4e33e42e-8297-5321-ba0f-930d54b5fc09', '5c284535-b25e-5276-be73-f63463cf2c46', 'Daša', 'Koliki je otkazni rok?', 'Який строк попередження про звільнення?', 3);
  perform pg_temp.turn('500afb54-da29-5d9e-8665-eff4764d1fe1', '5c284535-b25e-5276-be73-f63463cf2c46', 'Referentica', 'Za vrijeme probnog rada samo tjedan dana.', 'Під час випробувального терміну — лише тиждень.', 4);
  perform pg_temp.turn('3545bc59-1af0-58c3-991c-c693d55e020d', '5c284535-b25e-5276-be73-f63463cf2c46', 'Daša', 'Moram li raditi u smjenama?', 'Мені доведеться працювати позмінно?', 5);
  perform pg_temp.turn('e17d4af1-2c9b-58d4-9df9-02677d90d230', '5c284535-b25e-5276-be73-f63463cf2c46', 'Referentica', 'Ne morate, puno radno vrijeme je od osam do četiri.', 'Ні, повний робочий день — з восьмої до четвертої.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d683d4c9-6d44-5479-966f-dfd350782ec6', v_lesson, 'Перша зарплата', 'Prva plaća', 3542, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('f80ba95d-c1ca-5693-92b0-e15051f40e4b', 'd683d4c9-6d44-5479-966f-dfd350782ec6', 'Luka', 'Zašto je neto plaća toliko manja od bruto?', 'Чому зарплата нетто настільки менша за брутто?', 1);
  perform pg_temp.turn('c9cf08ae-d7a7-566c-bee1-0a6681676017', 'd683d4c9-6d44-5479-966f-dfd350782ec6', 'Kolegica', 'Od bruto plaće se plaćaju porez i doprinosi.', 'Із брутто сплачуються податок і внески.', 2);
  perform pg_temp.turn('4b1090e0-2565-56d4-98d4-9614305d8f83', 'd683d4c9-6d44-5479-966f-dfd350782ec6', 'Luka', 'A gdje vidim prekovremene sate?', 'А де я бачу понаднормові години?', 3);
  perform pg_temp.turn('2b728cee-9455-5da1-8d5e-bc478df6b617', 'd683d4c9-6d44-5479-966f-dfd350782ec6', 'Kolegica', 'Na platnoj listi, ispod osnovne plaće.', 'У розрахунковому листку, під основною зарплатою.', 4);
  perform pg_temp.turn('556c8e69-d122-56d7-90c4-0ad7b2ba6a6d', 'd683d4c9-6d44-5479-966f-dfd350782ec6', 'Luka', 'Kada je isplata?', 'Коли виплата?', 5);
  perform pg_temp.turn('62816cd3-217f-5a3e-912a-5c9007402012', 'd683d4c9-6d44-5479-966f-dfd350782ec6', 'Kolegica', 'Do desetog. U lipnju dobiješ i regres, a u prosincu božićnicu.', 'До десятого. У червні отримаєш ще відпускні, а в грудні — різдвяну премію.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 55: Перший робочий день: як було? — перебудова: 13 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '2c56a486-dbbb-5102-b7cb-754c59cf94c3';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Перший робочий день: як було?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '07afbd39-eb2d-57d3-9792-b223dd7e6d32') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 55: Перший робочий день: як було?', title_hr = 'Lekcija 55: Prvi radni dan: kako je bilo?',
         objectives = '["Розповісти, як минув перший день: što ste naučili, tko vam je pomogao", "Назвати робочий одяг і захисне спорядження", "Минулий час: dobio sam, upoznala sam, pokazao je"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Минулий час: radio sam, bila sam»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'radna odjeća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaštitna oprema', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svlačionica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ormarić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sigurnost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'voditelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mentor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obuka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tim', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naučiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'objasniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odgovoran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'točan', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '724abffb-f56d-58fa-b358-f52edbf21b41', 'fill_in_the_blank', 'Prvi dan sam ___ cijeli tim.', 'upoznala', '["upoznajem", "upoznat ću", "upoznala", "upoznati"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8929d5fc-1d21-551c-a152-a6448f3fcaa1', 'multiple_choice', 'Що означає «obuka»?', 'навчання (на роботі), інструктаж', '["робочий одяг", "вивчити", "навчання (на роботі), інструктаж", "команда"]'::jsonb, 'A1', 2, 'PUBLISHED', 'obuka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f719bbe-7004-5f33-8b63-b3db82a21f11', 'multiple_choice', 'Що означає «zaštitna oprema»?', 'захисне спорядження', '["пояснити", "захисне спорядження", "команда", "керівник, ведучий"]'::jsonb, 'A1', 3, 'PUBLISHED', 'zaštitna oprema', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '88021b56-96a5-571c-a372-5088b9fce68c', 'multiple_choice', 'Що означає «svlačionica»?', 'роздягальня', '["захисне спорядження", "роздягальня", "команда", "шафка"]'::jsonb, 'A1', 4, 'PUBLISHED', 'svlačionica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fe517a5a-d8ce-5ad6-a109-d2f0bc49bf4f', 'multiple_choice', 'Як хорватською «пояснити»?', 'objasniti', '["tim", "objasniti", "sigurnost", "obuka"]'::jsonb, 'A1', 5, 'PUBLISHED', 'objasniti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '59e1c48c-52c2-5a0c-90f2-1a1456bfe5b7', 'multiple_choice', 'Як хорватською «безпека»?', 'sigurnost', '["sigurnost", "tim", "voditelj", "točan"]'::jsonb, 'A1', 6, 'PUBLISHED', 'sigurnost', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd9ee8118-98fe-551f-8b64-1813ed6da37b', 'type_answer', 'Напишіть хорватською: «точний; пунктуальний»', 'točan', null, 'A1', 7, 'PUBLISHED', 'točan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1faec4f9-4606-546b-b437-38c6b8b4de90', 'type_answer', 'Напишіть хорватською: «наставник, ментор»', 'mentor', null, 'A1', 8, 'PUBLISHED', 'mentor', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1bf95757-935c-5f2f-8733-53cc9a1646b2', 'type_answer', 'Напишіть хорватською: «шафка»', 'ormarić', null, 'A1', 9, 'PUBLISHED', 'ormarić', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '654b1b28-1674-5712-92ce-0e1b5ab12efa', 'sentence_builder', 'Складіть: «Наставник мені все пояснив.»', 'Mentor mi je sve objasnio.', '["sve", "je", "mi", "objasnio.", "Mentor"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e3d89224-1c62-5eb4-8cf6-1bf04f27c56a', 'sentence_builder', 'Складіть: «Я отримала робочий одяг.»', 'Dobila sam radnu odjeću.', '["radnu", "odjeću.", "sam", "Dobila"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4816d396-6b6c-5580-b6ce-de7fd8a42f7b', 'listening', 'Прослухайте і складіть фразу', 'Super! Upoznala sam cijeli tim.', '["Upoznala", "Super!", "cijeli", "tim.", "sam"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '22290e15-a5c3-5fd4-995d-72680df821bd', 'listening', 'Прослухайте і складіть фразу', 'U svlačionici, svatko ima svoj ormarić.', '["svatko", "ormarić.", "svoj", "U", "ima", "svlačionici,"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '37f7fd54-78a7-5920-b70b-06064c73160d', 'speaking', 'Як минув перший день?', 'Kako je bio prvi dan?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f53383a9-6d0d-58f8-b0cd-6f0369dfc849', 'speaking', 'Я багато чого навчився.', 'Puno sam naučio.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('07afbd39-eb2d-57d3-9792-b223dd7e6d32', v_lesson, 'Як було?', 'Kako je bilo?', 3551, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('e1f79856-c4a2-5cc9-b9af-94b8973660c7', '07afbd39-eb2d-57d3-9792-b223dd7e6d32', 'Luka', 'Dašo, kako je bio prvi dan?', 'Дашо, як минув перший день?', 1);
  perform pg_temp.turn('b5d8bc0b-811b-5edd-878f-5d066f66105e', '07afbd39-eb2d-57d3-9792-b223dd7e6d32', 'Daša', 'Super! Upoznala sam cijeli tim.', 'Чудово! Я познайомилася з усією командою.', 2);
  perform pg_temp.turn('349a00f2-62ae-56a3-bdfa-4793a9811b4f', '07afbd39-eb2d-57d3-9792-b223dd7e6d32', 'Luka', 'Što si radila?', 'Що ти робила?', 3);
  perform pg_temp.turn('c7cd225c-3434-5116-8968-194ac2fe83fd', '07afbd39-eb2d-57d3-9792-b223dd7e6d32', 'Daša', 'Ujutro sam imala obuku, a mentorica mi je objasnila program.', 'Зранку був інструктаж, а наставниця пояснила мені програму.', 4);
  perform pg_temp.turn('d3ffb878-6833-52ac-9826-e199114e4254', '07afbd39-eb2d-57d3-9792-b223dd7e6d32', 'Luka', 'Je li voditeljica stroga?', 'Керівниця сувора?', 5);
  perform pg_temp.turn('5ad7a567-88fa-5e58-beae-7e918254374c', '07afbd39-eb2d-57d3-9792-b223dd7e6d32', 'Daša', 'Nije, ali traži da budemo točni.', 'Ні, але вимагає пунктуальності.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0bc8def4-91ba-53bf-b06a-56763107573a', v_lesson, 'На складі', 'U skladištu', 3552, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('142b0fce-21dd-5b2c-bd1e-0029d20deaaa', '0bc8def4-91ba-53bf-b06a-56763107573a', 'Marko', 'Prvi dan sam dobio radnu odjeću i zaštitnu opremu.', 'Першого дня я отримав робочий одяг і захисне спорядження.', 1);
  perform pg_temp.turn('2c9c4152-4aae-5b0a-8b0a-4cd38a5c7064', '0bc8def4-91ba-53bf-b06a-56763107573a', 'Darja', 'Gdje si se presvukao?', 'Де ти перевдягнувся?', 2);
  perform pg_temp.turn('151f2273-3d2b-5bd3-8293-957c146923be', '0bc8def4-91ba-53bf-b06a-56763107573a', 'Marko', 'U svlačionici, svatko ima svoj ormarić.', 'У роздягальні, у кожного своя шафка.', 3);
  perform pg_temp.turn('7f2d421e-9dab-5165-bd70-a77b9c863d6c', '0bc8def4-91ba-53bf-b06a-56763107573a', 'Darja', 'Je li bilo teško?', 'Було важко?', 4);
  perform pg_temp.turn('d5fb9917-4721-5198-ad07-9f721943b77f', '0bc8def4-91ba-53bf-b06a-56763107573a', 'Marko', 'Malo. Mentor je rekao da je sigurnost najvažnija.', 'Трохи. Наставник сказав, що безпека — найважливіше.', 5);
  perform pg_temp.turn('a20ee5da-d7c6-5ed3-8b65-4ccd781015b3', '0bc8def4-91ba-53bf-b06a-56763107573a', 'Darja', 'Čini se da si odgovoran radnik!', 'Схоже, ти відповідальний працівник!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 56: Правила на роботі — перебудова: 12 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '99088d92-0f0c-52c2-b51f-548d903fc9ef';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Правила на роботі» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '01a4736e-1953-57ca-b43d-ae4d46c394c5') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 56: Правила на роботі', title_hr = 'Lekcija 56: Pravila na poslu',
         objectives = '["Зрозуміти правила: zabrana pušenja, zaštita na radu, uniforma", "Попросити дозвіл і відпустку", "Модальні: smjeti, morati; ne moraš — ne smiješ"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Модальні дієслова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Модальні дієслова»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'smjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'morati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pravilnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zabrana pušenja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pušiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaštita na radu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uniforma', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dopust', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plaćeni dopust', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odobrenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odsutnost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najaviti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ca001508-399c-5fac-9129-bc578c19beae', 'fill_in_the_blank', 'Ovdje ne ___ pušiti, to je zabranjeno.', 'smiješ', '["trebaš li", "moram li", "moraš", "smiješ"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e8b8b6f0-d600-5011-88bf-2d10e19a11b2', 'multiple_choice', 'Що означає «odobrenje»?', 'схвалення, дозвіл', '["попередити заздалегідь, оголосити", "схвалення, дозвіл", "курити", "уніформа"]'::jsonb, 'A1', 2, 'PUBLISHED', 'odobrenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6539b475-19cd-5e90-bdcf-8733df1170b1', 'multiple_choice', 'Що означає «dopust»?', 'відпустка (додаткова, за обставинами)', '["уніформа", "мусити / бути зобов''язаним", "попередити заздалегідь, оголосити", "відпустка (додаткова, за обставинами)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'dopust', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '567f2735-e759-5936-b2f2-b07858569de8', 'multiple_choice', 'Що означає «morati»?', 'мусити / бути зобов''язаним', '["оплачувана відпустка (короткострокова)", "сміти, мати дозвіл", "мусити / бути зобов''язаним", "заборона куріння"]'::jsonb, 'A1', 4, 'PUBLISHED', 'morati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b4acf86b-d4de-59e4-af3d-62a58ee9c9b3', 'multiple_choice', 'Що означає «smjeti»?', 'сміти, мати дозвіл', '["відпустка (додаткова, за обставинами)", "уніформа", "курити", "сміти, мати дозвіл"]'::jsonb, 'A1', 5, 'PUBLISHED', 'smjeti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '77d9d2cf-165d-53dc-b64a-46759261465b', 'multiple_choice', 'Як хорватською «охорона праці»?', 'zaštita na radu', '["najaviti", "odobrenje", "zaštita na radu", "odsutnost"]'::jsonb, 'A1', 6, 'PUBLISHED', 'zaštita na radu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e09ff145-6d70-57c9-8334-dcb2326f733e', 'multiple_choice', 'Як хорватською «уніформа»?', 'uniforma', '["uniforma", "zaštita na radu", "pravilnik", "odobrenje"]'::jsonb, 'A1', 7, 'PUBLISHED', 'uniforma', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a0f7eef-b889-5643-ae15-27cb56e293bf', 'type_answer', 'Напишіть хорватською: «курити»', 'pušiti', null, 'A1', 8, 'PUBLISHED', 'pušiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '202e2b4d-852c-5834-a9fa-97bcc7106d00', 'type_answer', 'Напишіть хорватською: «відсутність»', 'odsutnost', null, 'A1', 9, 'PUBLISHED', 'odsutnost', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0334a74f-0330-5db0-9b9e-8badb35a2d45', 'sentence_builder', 'Складіть: «Можна мені взяти вихідний?»', 'Smijem li uzeti slobodan dan?', '["slobodan", "Smijem", "dan?", "uzeti", "li"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c06f66dd-5892-59de-98ad-0e8856d15d95', 'sentence_builder', 'Складіть: «Уніформу треба носити завжди.»', 'Uniformu moraš uvijek nositi.', '["Uniformu", "uvijek", "moraš", "nositi."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a85c648-a689-5d86-bf22-99ecd0526912', 'listening', 'Прослухайте і складіть фразу', 'Smijem li pušiti u pauzi?', '["pušiti", "pauzi?", "u", "Smijem", "li"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9526ed8d-ca96-52f3-9057-c6e89499d966', 'listening', 'Прослухайте і складіть фразу', 'Barem tjedan dana prije.', '["prije.", "dana", "Barem", "tjedan"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e881f3c0-7bb9-58ae-8bba-e58bfe70a014', 'speaking', 'Можна мені взяти вихідний?', 'Smijem li uzeti slobodan dan?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '58a742ea-3296-5611-bc1a-705efd3a3c04', 'speaking', 'Тут не можна курити.', 'Ovdje se ne smije pušiti.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('01a4736e-1953-57ca-b43d-ae4d46c394c5', v_lesson, 'Правила в ресторані', 'Pravila u restoranu', 3561, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('8542209a-b57a-5a47-a557-7f0299f4b3ae', '01a4736e-1953-57ca-b43d-ae4d46c394c5', 'Šefica', 'Darja, uniformu moraš nositi cijelo vrijeme.', 'Даріє, уніформу треба носити весь час.', 1);
  perform pg_temp.turn('ef9ff02c-139a-54af-9737-b2af15352b2b', '01a4736e-1953-57ca-b43d-ae4d46c394c5', 'Darja', 'Smijem li pušiti u pauzi?', 'Можна курити на перерві?', 2);
  perform pg_temp.turn('f737af18-42c6-599d-8992-7edf3fdaf2e1', '01a4736e-1953-57ca-b43d-ae4d46c394c5', 'Šefica', 'Samo vani. U zgradi vrijedi zabrana pušenja.', 'Лише надворі. У будівлі діє заборона куріння.', 3);
  perform pg_temp.turn('e71da4cf-ce40-5f0b-b5d3-f89f5ede9715', '01a4736e-1953-57ca-b43d-ae4d46c394c5', 'Darja', 'Gdje mogu pročitati pravilnik?', 'Де можна прочитати правила?', 4);
  perform pg_temp.turn('2f7bb7eb-51a8-57b1-a6ea-69e4a50b7bfe', '01a4736e-1953-57ca-b43d-ae4d46c394c5', 'Šefica', 'Na oglasnoj ploči, pored kuhinje.', 'На дошці оголошень, біля кухні.', 5);
  perform pg_temp.turn('eb0f6f01-6c6d-5657-8534-ca970541354f', '01a4736e-1953-57ca-b43d-ae4d46c394c5', 'Darja', 'A tečaj zaštite na radu?', 'А курс з охорони праці?', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('374e3098-d438-5db4-8034-e355e82838ec', v_lesson, 'Прошу вихідний', 'Molim slobodan dan', 3562, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('555b3ba7-dd1f-5f2f-86e6-49eb5bd0e854', '374e3098-d438-5db4-8034-e355e82838ec', 'Luka', 'Šefe, smijem li uzeti dva dana dopusta?', 'Шефе, можна мені взяти два дні відпустки?', 1);
  perform pg_temp.turn('a241bde9-ab59-5bc0-ad0c-7cc0d7928094', '374e3098-d438-5db4-8034-e355e82838ec', 'Šef', 'Zašto?', 'Чому?', 2);
  perform pg_temp.turn('ef32006c-c908-5f99-b49c-38c8ba5dfcb5', '374e3098-d438-5db4-8034-e355e82838ec', 'Luka', 'Selim se. Je li to plaćeni dopust?', 'Я переїжджаю. Це оплачувана відпустка?', 3);
  perform pg_temp.turn('ed52b1e9-dbe0-5bb4-b65d-7b40d48a95ef', '374e3098-d438-5db4-8034-e355e82838ec', 'Šef', 'Jedan dan je plaćen. Trebaš moje odobrenje.', 'Один день оплачується. Потрібен мій дозвіл.', 4);
  perform pg_temp.turn('0cf82a04-5d02-56c1-92e9-d61251ee8449', '374e3098-d438-5db4-8034-e355e82838ec', 'Luka', 'Hvala. Kada moram najaviti odsutnost?', 'Дякую. Коли мені треба попередити про відсутність?', 5);
  perform pg_temp.turn('67f4e5ac-5f67-50ed-b32d-c07b8a69949e', '374e3098-d438-5db4-8034-e355e82838ec', 'Šef', 'Barem tjedan dana prije.', 'Щонайменше за тиждень.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 57: Дзвінок на роботу: я захворів — перебудова: 12 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'e806dd39-4d38-5781-ad2d-949961dd95f9';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Дзвінок на роботу: я захворів» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'e7e40df6-3384-54c0-ae40-1943f29df9a4') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 57: Дзвінок на роботу: я захворів', title_hr = 'Lekcija 57: Zovem posao: razbolio sam se',
         objectives = '["Повідомити на роботу, що захворіли: prehlađen sam, išao sam doktoru", "Залишити повідомлення секретарці", "Минулий час: razbolio sam se, bila sam kod liječnika"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Минулий час: radio sam, bila sam»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'javiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poruka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ostaviti poruku', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tajnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'videopoziv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'link', v_pos);
  v_pos := pg_temp.word(v_lesson, 'doznaka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prehlađen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaraziti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nadoknaditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odsutan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ozdraviti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '5f22abef-34db-51bd-af04-6d2d05a5f6f1', 'fill_in_the_blank', 'Jučer sam ___ kod liječnika.', 'bila', '["bila", "budem", "sam", "biti"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4fd12cd2-f757-544f-aca3-72dfb28d8b50', 'multiple_choice', 'Що означає «poruka»?', 'повідомлення', '["одужати", "лікарняний лист (від лікаря)", "секретарка", "повідомлення"]'::jsonb, 'A1', 2, 'PUBLISHED', 'poruka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a294fb2-6ee7-5fff-817a-63816655b71e', 'multiple_choice', 'Що означає «javiti se»?', 'обізватися; відповісти (на дзвінок); зголоситися', '["застуджений", "лікарняний лист (від лікаря)", "обізватися; відповісти (на дзвінок); зголоситися", "залишити повідомлення"]'::jsonb, 'A1', 3, 'PUBLISHED', 'javiti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '016eb553-3317-50ec-a3df-669cbec61205', 'multiple_choice', 'Що означає «link»?', 'посилання', '["залишити повідомлення", "посилання", "відеодзвінок", "заразитися"]'::jsonb, 'A1', 4, 'PUBLISHED', 'link', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dea42cf8-91ad-592f-846e-8ff4a3e5b3f5', 'multiple_choice', 'Як хорватською «заразитися»?', 'zaraziti se', '["tajnica", "link", "odsutan", "zaraziti se"]'::jsonb, 'A1', 5, 'PUBLISHED', 'zaraziti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '48042575-e943-507d-ba7d-8d84d4288643', 'multiple_choice', 'Як хорватською «відеодзвінок»?', 'videopoziv', '["nadoknaditi", "odsutan", "videopoziv", "prehlađen"]'::jsonb, 'A1', 6, 'PUBLISHED', 'videopoziv', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bad95506-f919-5e5c-9413-96b228ba4581', 'type_answer', 'Напишіть хорватською: «секретарка»', 'tajnica', null, 'A1', 7, 'PUBLISHED', 'tajnica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '724dad3c-5709-582f-a368-1f9cd5a6f0b2', 'type_answer', 'Напишіть хорватською: «одужати»', 'ozdraviti', null, 'A1', 8, 'PUBLISHED', 'ozdraviti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0af21def-abc2-5289-a257-b8a5efb66e84', 'type_answer', 'Напишіть хорватською: «відсутній»', 'odsutan', null, 'A1', 9, 'PUBLISHED', 'odsutan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '13e4a935-f4ae-5735-b34b-05a5c49db272', 'sentence_builder', 'Складіть: «Я захворіла.»', 'Razboljela sam se.', '["sam", "Razboljela", "se."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8769aab8-faa8-5f60-bd82-8a373206346e', 'sentence_builder', 'Складіть: «Я була в лікаря.»', 'Bila sam kod liječnika.', '["sam", "Bila", "kod", "liječnika."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '08585a28-ac04-53af-bdb1-baa9b5d77f8a', 'listening', 'Прослухайте і складіть фразу', 'Joj, što ti je?', '["što", "Joj,", "ti", "je?"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd9b95c7f-cf3e-500f-9d4f-07f3f60a84f1', 'listening', 'Прослухайте і складіть фразу', 'Nije, danas je odsutna. Želite li ostaviti poruku?', '["poruku?", "odsutna.", "ostaviti", "danas", "Želite", "li", "je", "Nije,"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e7d3d3d7-5f6b-581a-be1d-06862fa0a6be', 'speaking', 'Я застуджений, сьогодні не прийду.', 'Prehlađen sam, danas ne dolazim.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c2831014-5142-52e1-8b64-8b72c1934d2e', 'speaking', 'Можна залишити повідомлення?', 'Mogu li ostaviti poruku?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e7e40df6-3384-54c0-ae40-1943f29df9a4', v_lesson, 'Дзвінок начальнику', 'Poziv šefu', 3571, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('1f914792-ee5a-58bc-8183-64ebc27ac8ff', 'e7e40df6-3384-54c0-ae40-1943f29df9a4', 'Daša', 'Dobro jutro, šefe. Nažalost, razboljela sam se.', 'Доброго ранку, шефе. На жаль, я захворіла.', 1);
  perform pg_temp.turn('d1690fa3-aee4-55cf-acf9-9a7562802dff', 'e7e40df6-3384-54c0-ae40-1943f29df9a4', 'Šef', 'Joj, što ti je?', 'Ой, що з тобою?', 2);
  perform pg_temp.turn('5c981c7e-dbbc-531c-9fa1-8cf74d760eb1', 'e7e40df6-3384-54c0-ae40-1943f29df9a4', 'Daša', 'Prehlađena sam i imam temperaturu. Bila sam kod liječnika.', 'Я застуджена, і в мене температура. Я була в лікаря.', 3);
  perform pg_temp.turn('6037b617-3a85-5ed6-accb-a787ce476670', 'e7e40df6-3384-54c0-ae40-1943f29df9a4', 'Šef', 'Jesi li dobila doznaku za bolovanje?', 'Ти отримала лікарняний лист?', 4);
  perform pg_temp.turn('c1feb024-6afe-5bcb-9296-979ae8aa9e75', 'e7e40df6-3384-54c0-ae40-1943f29df9a4', 'Daša', 'Jesam, za tri dana. Ne želim da se kolege zaraze.', 'Так, на три дні. Не хочу, щоб колеги заразилися.', 5);
  perform pg_temp.turn('4789e882-6ab3-5455-beea-0ead74d825c8', 'e7e40df6-3384-54c0-ae40-1943f29df9a4', 'Šef', 'U redu, samo ozdravi. Posao možeš nadoknaditi poslije.', 'Добре, головне одужуй. Роботу надолужиш потім.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a3a8c926-8310-55d1-8186-05257528c85b', v_lesson, 'Повідомлення секретарці', 'Poruka za tajnicu', 3572, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('27441f48-53a2-5dcb-9025-96728840f1c9', 'a3a8c926-8310-55d1-8186-05257528c85b', 'Tajnica', 'Tvrtka Adria, izvolite.', 'Компанія «Адрія», слухаю.', 1);
  perform pg_temp.turn('ccd6f447-aa64-5703-a917-3d495cfe0efc', 'a3a8c926-8310-55d1-8186-05257528c85b', 'Luka', 'Dobar dan, Luka ovdje. Je li gospođa Babić tu?', 'Добрий день, це Лука. Пані Бабич на місці?', 2);
  perform pg_temp.turn('7f6dccb8-0adb-563f-8836-771f74559ceb', 'a3a8c926-8310-55d1-8186-05257528c85b', 'Tajnica', 'Nije, danas je odsutna. Želite li ostaviti poruku?', 'Ні, сьогодні її немає. Бажаєте залишити повідомлення?', 3);
  perform pg_temp.turn('6787723c-473f-549b-b82c-4e1dfc830ac8', 'a3a8c926-8310-55d1-8186-05257528c85b', 'Luka', 'Recite joj da sam bolestan i da danas ne dolazim.', 'Скажіть їй, що я хворий і сьогодні не прийду.', 4);
  perform pg_temp.turn('2422bc4a-0c3d-5c85-9338-54490256a72e', 'a3a8c926-8310-55d1-8186-05257528c85b', 'Tajnica', 'Hoćete li se javiti na sastanak preko videopoziva?', 'Ви підключитеся до наради через відеодзвінок?', 5);
  perform pg_temp.turn('0d0d8467-0b8f-5d09-8df8-665525a83d26', 'a3a8c926-8310-55d1-8186-05257528c85b', 'Luka', 'Hoću, pošaljite mi link mailom.', 'Так, надішліть мені посилання імейлом.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 58: В офісі — перебудова: 15 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'ee016ba8-5160-581d-b440-1bcb7647173d';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «В офісі» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'e9e27135-4de3-5f71-aa0c-c507d7d6c371') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 58: В офісі', title_hr = 'Lekcija 58: U uredu',
         objectives = '["Назвати офісні речі: pisač, spajalica, klamerica, registrator", "Попросити колегу роздрукувати чи скопіювати", "Наказовий: ispiši, skeniraj, donesi"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Наказовий спосіб' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Наказовий спосіб»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'pisač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispisati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skenirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kopirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fotokopirni aparat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'papir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spajalica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'klamerica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'registrator', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mapa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tablica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bilježnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prezentacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sala za sastanke', v_pos);
  v_pos := pg_temp.word(v_lesson, 'aparat za kavu', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '5b78f9ed-5f6e-5735-aa72-353311692801', 'fill_in_the_blank', '___ mi ugovor, molim te.', 'Skeniraj', '["Skeniraj", "Skeniram", "Skenirati", "Skenira"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd7f951c5-2e15-5e4d-98c5-a3464d2555a2', 'multiple_choice', 'Що означає «aparat za kavu»?', 'кавовий автомат, кавоварка', '["копіювальний апарат, ксерокс", "принтер", "кавовий автомат, кавоварка", "презентація"]'::jsonb, 'A1', 2, 'PUBLISHED', 'aparat za kavu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b7352404-ae39-574e-b5b3-14c1bfbf3035', 'multiple_choice', 'Що означає «mapa»?', 'папка', '["зошит", "папка", "папір", "презентація"]'::jsonb, 'A1', 3, 'PUBLISHED', 'mapa', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e7332e63-52c2-58c7-9681-7deac515043b', 'multiple_choice', 'Що означає «sala za sastanke»?', 'переговорна кімната', '["переговорна кімната", "сканувати", "копіювати", "папка"]'::jsonb, 'A1', 4, 'PUBLISHED', 'sala za sastanke', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c53eee87-7f1b-57be-bd61-0f16b5f2bab7', 'multiple_choice', 'Як хорватською «сканувати»?', 'skenirati', '["bilježnica", "kopirati", "papir", "skenirati"]'::jsonb, 'A1', 5, 'PUBLISHED', 'skenirati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '37f8de54-08fb-5a3d-92d6-777a4d9718ca', 'multiple_choice', 'Як хорватською «скріпка»?', 'spajalica', '["tablica", "aparat za kavu", "spajalica", "bilježnica"]'::jsonb, 'A1', 6, 'PUBLISHED', 'spajalica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '23371d42-e6e2-557d-83ea-a9cd19d0043d', 'type_answer', 'Напишіть хорватською: «степлер»', 'klamerica', null, 'A1', 7, 'PUBLISHED', 'klamerica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ff58ef4e-1f1b-544b-b75f-33c6d30bab17', 'type_answer', 'Напишіть хорватською: «принтер»', 'pisač', null, 'A1', 8, 'PUBLISHED', 'pisač', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f108c906-f266-5b3e-b05c-1b761e83f3ce', 'type_answer', 'Напишіть хорватською: «роздрукувати»', 'ispisati', null, 'A1', 9, 'PUBLISHED', 'ispisati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cefd36a5-60f3-5a74-b6fe-f949631040b2', 'sentence_builder', 'Складіть: «Роздрукуй мені таблицю.»', 'Ispiši mi tablicu.', '["mi", "Ispiši", "tablicu."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0f64c329-ac3d-502f-83b8-c7353b897158', 'sentence_builder', 'Складіть: «У принтері немає паперу.»', 'Pisač nema papira.', '["nema", "Pisač", "papira."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '166d4f2b-2f7c-5dcd-8b17-b67f8d7a2963', 'listening', 'Прослухайте і складіть фразу', 'Pisač opet nema papira.', '["nema", "Pisač", "opet", "papira."]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dcd5acea-a293-5895-baf9-9462850c5715', 'listening', 'Прослухайте і складіть фразу', 'Gdje je sastanak?', '["sastanak?", "je", "Gdje"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7414dada-739d-535f-8e16-2e2a17b75342', 'speaking', 'Відскануйте договір, будь ласка.', 'Skenirajte ugovor, molim.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3fd83cbf-0588-55f1-a605-35887cf74c6a', 'speaking', 'Де переговорна?', 'Gdje je sala za sastanke?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e9e27135-4de3-5f71-aa0c-c507d7d6c371', v_lesson, 'Допоможи з документами', 'Pomoć s papirima', 3581, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('2400b5ad-cdab-5461-a9fd-7ef0681c81fa', 'e9e27135-4de3-5f71-aa0c-c507d7d6c371', 'Šefica', 'Dašo, ispiši mi tablicu za sastanak, molim te.', 'Дашо, роздрукуй мені таблицю для наради, будь ласка.', 1);
  perform pg_temp.turn('9fffa8a4-4472-5f15-b6fe-64daa35fcd22', 'e9e27135-4de3-5f71-aa0c-c507d7d6c371', 'Daša', 'Pisač opet nema papira.', 'У принтері знову немає паперу.', 2);
  perform pg_temp.turn('2abc6493-3774-58ce-b140-913770f77b72', 'e9e27135-4de3-5f71-aa0c-c507d7d6c371', 'Šefica', 'Papir je u ormaru. Skeniraj i ugovor.', 'Папір у шафі. І відскануй договір.', 3);
  perform pg_temp.turn('4cac0469-be6d-51a3-87bb-919aaa39776f', 'e9e27135-4de3-5f71-aa0c-c507d7d6c371', 'Daša', 'Može. Trebate li i kopiju?', 'Добре. Вам потрібна ще й копія?', 4);
  perform pg_temp.turn('1f2c60cf-f0f9-5e42-a581-e34e7ddb2960', 'e9e27135-4de3-5f71-aa0c-c507d7d6c371', 'Šefica', 'Da, dvije. Fotokopirni aparat je na kraju hodnika.', 'Так, дві. Ксерокс у кінці коридору.', 5);
  perform pg_temp.turn('31222ff9-745d-5fde-bf38-36110281d9a4', 'e9e27135-4de3-5f71-aa0c-c507d7d6c371', 'Daša', 'Spojit ću ih spajalicom i staviti u plavu mapu.', 'Скріплю їх скріпкою й покладу в синю папку.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ead0b059-1c9d-556b-9fb7-464055ebb7e4', v_lesson, 'Перед нарадою', 'Prije sastanka', 3582, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('477263cb-f21f-5dd2-87cf-753657283953', 'ead0b059-1c9d-556b-9fb7-464055ebb7e4', 'Luka', 'Gdje je sastanak?', 'Де нарада?', 1);
  perform pg_temp.turn('ac72d0a2-bbb8-5cb2-986a-51b1e567b371', 'ead0b059-1c9d-556b-9fb7-464055ebb7e4', 'Darja', 'U sali za sastanke na drugom katu.', 'У переговорній на другому поверсі.', 2);
  perform pg_temp.turn('e7ae44ba-3694-56a0-a9ce-b00f72accf5e', 'ead0b059-1c9d-556b-9fb7-464055ebb7e4', 'Luka', 'Imaš li klamericu? Moram spojiti prezentaciju.', 'У тебе є степлер? Мені треба скріпити презентацію.', 3);
  perform pg_temp.turn('35a4b384-4a93-51f3-a084-05873d04010a', 'ead0b059-1c9d-556b-9fb7-464055ebb7e4', 'Darja', 'Uzmi je iz moje ladice. I donesi registrator s računima.', 'Візьми з моєї шухляди. І принеси реєстратор із рахунками.', 4);
  perform pg_temp.turn('28a1e2ad-c32c-5d0e-982b-2fc25694d328', 'ead0b059-1c9d-556b-9fb7-464055ebb7e4', 'Luka', 'Hoćeš li kavu? Aparat za kavu opet radi.', 'Хочеш кави? Кавовий автомат знову працює.', 5);
  perform pg_temp.turn('8988dbdd-79d1-52fb-b52c-0ef069c2e5f7', 'ead0b059-1c9d-556b-9fb7-464055ebb7e4', 'Darja', 'Hoću, i ponesi bilježnicu za bilješke.', 'Хочу, і візьми зошит для нотаток.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- 3. Нові уроки модуля A1.6
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
   where l.id in ('b369f01f-4a84-57b4-98cb-150d236f4d7f', 'd813e9c0-2331-59d8-90f1-cea7e9a61c7d', 'c9b87882-5e31-5485-aea7-0169216466a8', '92858dbe-ede1-5bc5-b80a-c796c5598019', '4d6f3498-2cc5-54a0-b4e4-c66add71ef12', '2c56a486-dbbb-5102-b7cb-754c59cf94c3', '99088d92-0f0c-52c2-b51f-548d903fc9ef', 'e806dd39-4d38-5781-ad2d-949961dd95f9', 'ee016ba8-5160-581d-b440-1bcb7647173d')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 10 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_order from (values ('b369f01f-4a84-57b4-98cb-150d236f4d7f'::uuid, 1), ('d813e9c0-2331-59d8-90f1-cea7e9a61c7d'::uuid, 2), ('c9b87882-5e31-5485-aea7-0169216466a8'::uuid, 3), ('92858dbe-ede1-5bc5-b80a-c796c5598019'::uuid, 4), ('4d6f3498-2cc5-54a0-b4e4-c66add71ef12'::uuid, 5), ('2c56a486-dbbb-5102-b7cb-754c59cf94c3'::uuid, 6), ('99088d92-0f0c-52c2-b51f-548d903fc9ef'::uuid, 7), ('e806dd39-4d38-5781-ad2d-949961dd95f9'::uuid, 8), ('ee016ba8-5160-581d-b440-1bcb7647173d'::uuid, 9)) as t(id, o)
    join public.lessons l on l.id = t.id and l.order_index = t.o and l.unit_id = '874caaa6-f5e5-5c4f-acf4-cfdb0e510116';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A1' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('b369f01f-4a84-57b4-98cb-150d236f4d7f', 'd813e9c0-2331-59d8-90f1-cea7e9a61c7d', 'c9b87882-5e31-5485-aea7-0169216466a8', '92858dbe-ede1-5bc5-b80a-c796c5598019', '4d6f3498-2cc5-54a0-b4e4-c66add71ef12', '2c56a486-dbbb-5102-b7cb-754c59cf94c3', '99088d92-0f0c-52c2-b51f-548d903fc9ef', 'e806dd39-4d38-5781-ad2d-949961dd95f9', 'ee016ba8-5160-581d-b440-1bcb7647173d') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A1.6: % уроків з неправильним складом', v_bad; end if;
  if v_order <> 9 then raise exception 'Модуль A1.6: на своїх місцях % уроків з 9', v_order; end if;
  if v_titles > 0 then raise exception 'A1: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A1.6: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A1.6 — 9 уроків за темою (9 перебудовано, 0 нових)';
end $$;

commit;
