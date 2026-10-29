-- =====================================================================
-- Програма A1 v3 · модуль A1.4 «Транспорт» · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_curriculum_a1_v3.py 4 (не редагуйте вручну).
--
-- Рішення власника 2026-10-21 / 2026-10-26: до 25 слів на урок — скільки потрібно темі, 90–95 % слів — нові для рівня,
-- діалоги під тему, частіше Даша / Дар’я; бета (PUBLISHED).
--   * Уроки 30–39: 9 наявних перебудовано, 1 нових. Слів у них: 156.
--     Кожен: 10–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 60.
--   * Нові теми граматики: «Kamo? і Gdje?: u grad — u gradu», «Орудний відмінок: autobusom, s prijateljem».
--   * Виправлено: kuda — «куди, якою дорогою»; pumpa — «заправка (АЗС); насос»; zastoj — «затримка, зупинка; перешкода (блокер у роботі)» (стара версія — у content_versions).
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

-- 1. Нові слова й вирази A1.4 (60; наявні не змінюються)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ovamo', 'ovamo', 'hr', 'adverb', 'A1', 'сюди', 'core', '{}'::jsonb, '["Dođi ovamo i sjedni pored mene."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('van', 'van', 'hr', 'adverb', 'A1', 'назовні, надвір (куди?)', 'core', '{}'::jsonb, '["Djeco, idemo van, sunčano je!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('svratiti', 'svratiti', 'hr', 'verb', 'A1', 'заскочити, зайти ненадовго', 'core', '{"aspect": "pfv", "present": {"1s": "svratim", "2s": "svratiš", "3s": "svrati"}}'::jsonb, '["Na putu kući mogu svratiti u ljekarnu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odvesti', 'odvesti', 'hr', 'verb', 'A1', 'відвезти; відвести', 'core', '{"aspect": "pfv", "present": {"1s": "odvezem", "2s": "odvezeš", "3s": "odveze"}}'::jsonb, '["Mogu te odvesti na kolodvor."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ulaziti', 'ulaziti', 'hr', 'verb', 'A1', 'входити, заходити', 'core', '{"aspect": "ipfv", "present": {"1s": "ulazim", "2s": "ulaziš", "3s": "ulazi"}}'::jsonb, '["U autobus se ulazi na prednja vrata."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('izlaziti', 'izlaziti', 'hr', 'verb', 'A1', 'виходити', 'core', '{"aspect": "ipfv", "present": {"1s": "izlazim", "2s": "izlaziš", "3s": "izlazi"}}'::jsonb, '["Izlazim na sljedećoj stanici."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('poništiti', 'ponistiti', 'hr', 'verb', 'A1', 'прокомпостувати (квиток); скасувати', 'core', '{"aspect": "pfv", "present": {"1s": "poništim", "2s": "poništiš", "3s": "poništi"}}'::jsonb, '["Kartu treba poništiti odmah u tramvaju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nadoplatiti', 'nadoplatiti', 'hr', 'verb', 'A1', 'поповнити (картку, рахунок)', 'core', '{"aspect": "pfv", "present": {"1s": "nadoplatim", "2s": "nadoplatiš", "3s": "nadoplati"}}'::jsonb, '["Pokaznu kartu možeš nadoplatiti na kiosku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('okretište', 'okretiste', 'hr', 'noun', 'A1', 'кінцева зупинка', 'core', '{"gender": "n"}'::jsonb, '["Ovaj tramvaj vozi samo do okretišta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('noćna linija', 'nocna linija', 'hr', 'phrase', 'A1', 'нічний маршрут', 'collocation', '{"gender": "f"}'::jsonb, '["Poslije ponoći voze samo noćne linije."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ustupiti mjesto', 'ustupiti mjesto', 'hr', 'phrase', 'A1', 'поступитися місцем', 'collocation', '{"aspect": "pfv", "present": {"1s": "ustupim mjesto", "2s": "ustupiš mjesto", "3s": "ustupi mjesto"}}'::jsonb, '["U tramvaju uvijek ustupim mjesto starijima."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gurati se', 'gurati se', 'hr', 'verb', 'A1', 'штовхатися', 'core', '{"aspect": "ipfv", "present": {"1s": "guram se", "2s": "guraš se", "3s": "gura se"}}'::jsonb, '["Ne gurajte se, ima mjesta za sve."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stizati', 'stizati', 'hr', 'verb', 'A1', 'прибувати, приходити', 'core', '{"aspect": "ipfv", "present": {"1s": "stižem", "2s": "stižeš", "3s": "stiže"}}'::jsonb, '["Vlak iz Rijeke stiže u pet sati."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kolosijek', 'kolosijek', 'hr', 'noun', 'A1', 'колія', 'core', '{"gender": "m"}'::jsonb, '["Vlak za Split polazi s drugog kolosijeka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vagon', 'vagon', 'hr', 'noun', 'A1', 'вагон', 'core', '{"gender": "m"}'::jsonb, '["Naš vagon je na kraju vlaka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kupe', 'kupe', 'hr', 'noun', 'A1', 'купе', 'core', '{"gender": "m"}'::jsonb, '["U kupeu ima šest sjedala."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('brzi vlak', 'brzi vlak', 'hr', 'phrase', 'A1', 'швидкий поїзд', 'collocation', '{"gender": "m"}'::jsonb, '["Brzi vlak ne staje u malim mjestima."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prvi razred', 'prvi razred', 'hr', 'phrase', 'A1', 'перший клас (у поїзді)', 'collocation', '{"gender": "m"}'::jsonb, '["Karta za prvi razred je skuplja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('drugi razred', 'drugi razred', 'hr', 'phrase', 'A1', 'другий клас (у поїзді)', 'collocation', '{"gender": "m"}'::jsonb, '["Jednu kartu za drugi razred, molim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rezervacija sjedala', 'rezervacija sjedala', 'hr', 'phrase', 'A1', 'бронювання місця', 'collocation', '{"gender": "f"}'::jsonb, '["Za ovaj vlak treba rezervacija sjedala."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('otkazan', 'otkazan', 'hr', 'adjective', 'A1', 'скасований', 'core', '{"f": "otkazana", "n": "otkazano"}'::jsonb, '["Večernji vlak je danas otkazan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('željeznica', 'zeljeznica', 'hr', 'noun', 'A1', 'залізниця', 'core', '{"gender": "f"}'::jsonb, '["Željeznica od Zagreba do Rijeke ide kroz Gorski kotar."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stanka', 'stanka', 'hr', 'noun', 'A1', 'зупинка в дорозі, перерва', 'core', '{"gender": "f"}'::jsonb, '["Autobus ima stanku od petnaest minuta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mučnina', 'mucnina', 'hr', 'noun', 'A1', 'нудота', 'core', '{"gender": "f"}'::jsonb, '["U autobusu imam mučninu ako čitam."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prijava za let', 'prijava za let', 'hr', 'phrase', 'A1', 'реєстрація на рейс', 'collocation', '{"gender": "f"}'::jsonb, '["Prijava za let počinje dva sata prije polaska."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('traka za prtljagu', 'traka za prtljagu', 'hr', 'phrase', 'A1', 'багажна стрічка', 'collocation', '{"gender": "f"}'::jsonb, '["Kofere čekamo kod trake za prtljagu broj tri."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('izgubljena prtljaga', 'izgubljena prtljaga', 'hr', 'phrase', 'A1', 'загублений багаж', 'collocation', '{"gender": "f"}'::jsonb, '["Šalter za izgubljenu prtljagu je pored izlaza."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('polijetanje', 'polijetanje', 'hr', 'noun', 'A1', 'зліт (літака)', 'core', '{"gender": "n"}'::jsonb, '["Za vrijeme polijetanja vežite pojas."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('slijetanje', 'slijetanje', 'hr', 'noun', 'A1', 'приземлення (літака)', 'core', '{"gender": "n"}'::jsonb, '["Slijetanje u Split je u deset sati."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('naručiti taksi', 'naruciti taksi', 'hr', 'phrase', 'A1', 'викликати таксі', 'collocation', '{"aspect": "pfv", "present": {"1s": "naručim taksi", "2s": "naručiš taksi", "3s": "naruči taksi"}}'::jsonb, '["Možete li mi naručiti taksi do zračne luke?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('taksimetar', 'taksimetar', 'hr', 'noun', 'A1', 'таксометр', 'core', '{"gender": "m"}'::jsonb, '["Vozač uključuje taksimetar na početku vožnje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('cijena vožnje', 'cijena voznje', 'hr', 'phrase', 'A1', 'вартість поїздки', 'collocation', '{"gender": "f"}'::jsonb, '["Cijena vožnje do centra je oko petnaest eura."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stražnje sjedalo', 'straznje sjedalo', 'hr', 'phrase', 'A1', 'заднє сидіння', 'collocation', '{"gender": "n"}'::jsonb, '["Djeca sjede na stražnjem sjedalu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prednje sjedalo', 'prednje sjedalo', 'hr', 'phrase', 'A1', 'переднє сидіння', 'collocation', '{"gender": "n"}'::jsonb, '["Mogu li sjesti na prednje sjedalo?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('najkraći put', 'najkraci put', 'hr', 'phrase', 'A1', 'найкоротший шлях', 'collocation', '{"gender": "m"}'::jsonb, '["Vozite najkraćim putem, molim vas."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zaobići', 'zaobici', 'hr', 'verb', 'A1', 'об’їхати, обійти', 'core', '{"aspect": "pfv", "present": {"1s": "zaobiđem", "2s": "zaobiđeš", "3s": "zaobiđe"}}'::jsonb, '["Gužvu možemo zaobići obilaznicom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pričekati', 'pricekati', 'hr', 'verb', 'A1', 'почекати', 'core', '{"aspect": "pfv", "present": {"1s": "pričekam", "2s": "pričekaš", "3s": "pričeka"}}'::jsonb, '["Pričekajte me ispred hotela."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pedala', 'pedala', 'hr', 'noun', 'A1', 'педаль', 'core', '{"gender": "f"}'::jsonb, '["Lijeva pedala je labava."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zvonce', 'zvonce', 'hr', 'noun', 'A1', 'дзвоник', 'core', '{"gender": "n"}'::jsonb, '["Na biciklu mora biti zvonce."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('probušen', 'probusen', 'hr', 'adjective', 'A1', 'проколотий', 'core', '{"f": "probušena", "n": "probušeno"}'::jsonb, '["Guma na biciklu je probušena."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('napumpati', 'napumpati', 'hr', 'verb', 'A1', 'накачати', 'core', '{"aspect": "pfv", "present": {"1s": "napumpam", "2s": "napumpaš", "3s": "napumpa"}}'::jsonb, '["Prije vožnje treba napumpati gume."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('biciklist', 'biciklist', 'hr', 'noun', 'A1', 'велосипедист', 'core', '{"gender": "m"}'::jsonb, '["Biciklisti voze po biciklističkoj stazi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('parkiralište za bicikle', 'parkiraliste za bicikle', 'hr', 'phrase', 'A1', 'велопарковка', 'collocation', '{"gender": "n"}'::jsonb, '["Parkiralište za bicikle je ispred škole."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('iznajmljivanje', 'iznajmljivanje', 'hr', 'noun', 'A1', 'прокат, оренда', 'core', '{"gender": "n"}'::jsonb, '["Iznajmljivanje bicikla je deset eura na dan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('natočiti', 'natociti', 'hr', 'verb', 'A1', 'заправити (бак); налити', 'core', '{"aspect": "pfv", "present": {"1s": "natočim", "2s": "natočiš", "3s": "natoči"}}'::jsonb, '["Moram natočiti gorivo prije puta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bezolovni benzin', 'bezolovni benzin', 'hr', 'phrase', 'A1', 'неетилований бензин', 'collocation', '{"gender": "m"}'::jsonb, '["Moj auto vozi na bezolovni benzin."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tlak u gumama', 'tlak u gumama', 'hr', 'phrase', 'A1', 'тиск у шинах', 'collocation', '{"gender": "m"}'::jsonb, '["Na pumpi provjeravam tlak u gumama."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('parkirna karta', 'parkirna karta', 'hr', 'phrase', 'A1', 'паркувальний талон', 'collocation', '{"gender": "f"}'::jsonb, '["Parkirnu kartu stavite iza stakla."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('naplata parkiranja', 'naplata parkiranja', 'hr', 'phrase', 'A1', 'оплата паркування', 'collocation', '{"gender": "f"}'::jsonb, '["Naplata parkiranja je od sedam do devetnaest sati."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kazna za parkiranje', 'kazna za parkiranje', 'hr', 'phrase', 'A1', 'штраф за паркування', 'collocation', '{"gender": "f"}'::jsonb, '["Na staklu je kazna za parkiranje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pauk', 'pauk', 'hr', 'noun', 'A1', 'евакуатор (розм.); павук', 'core', '{"gender": "m"}'::jsonb, '["Pauk odvozi aute s nogostupa."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odvući', 'odvuci', 'hr', 'verb', 'A1', 'відбуксирувати, евакуювати (авто)', 'core', '{"aspect": "pfv", "present": {"1s": "odvučem", "2s": "odvučeš", "3s": "odvuče"}}'::jsonb, '["Ako parkiraš ovdje, mogu ti odvući auto."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('traka', 'traka', 'hr', 'noun', 'A1', 'смуга (руху); стрічка', 'core', '{"gender": "f"}'::jsonb, '["Na autocesti vozimo u desnoj traci."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zaustavna traka', 'zaustavna traka', 'hr', 'phrase', 'A1', 'аварійна смуга (узбіччя на трасі)', 'collocation', '{"gender": "f"}'::jsonb, '["Kad se auto pokvari, stani u zaustavnu traku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('skretanje', 'skretanje', 'hr', 'noun', 'A1', 'поворот; з’їзд', 'core', '{"gender": "n"}'::jsonb, '["Nakon mosta je skretanje za centar."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('brisač', 'brisac', 'hr', 'noun', 'A1', 'склоочисник, «двірник»', 'core', '{"gender": "m"}'::jsonb, '["Brisači ne čiste dobro, trebam nove."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zimske gume', 'zimske gume', 'hr', 'phrase', 'A1', 'зимові шини', 'collocation', '{"gender": "f_pl"}'::jsonb, '["U studenom stavljam zimske gume."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ispuh', 'ispuh', 'hr', 'noun', 'A1', 'вихлопна труба, вихлоп', 'core', '{"gender": "m"}'::jsonb, '["Ispuh je glasan, treba ga pogledati."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('lampica', 'lampica', 'hr', 'noun', 'A1', 'індикатор (на приладовій панелі)', 'core', '{"gender": "f"}'::jsonb, '["Svijetli lampica za ulje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rezervni dio', 'rezervni dio', 'hr', 'phrase', 'A1', 'запчастина', 'collocation', '{"gender": "m"}'::jsonb, '["Rezervni dio stiže za dva dana."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;

-- 1б. Виправлені слова (3); повторний запуск нічого не змінює
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'kuda' and ukrainian_translation = 'куди' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'куди, якою дорогою' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'pumpa' and ukrainian_translation = 'заправка' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'заправка (АЗС); насос' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'zastoj' and ukrainian_translation = 'блокер (перешкода)' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'затримка, зупинка; перешкода (блокер у роботі)' where id = r.id;
  end loop;
end $$;

-- 1а. Граматика A1.4: нові теми (2) і нові правила до наявних тем (0)
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'ab238fe7-7be6-5aff-91d5-771529dbe406', 'A1', 'Kamo? і Gdje?: u grad — u gradu', 'Kamo? i Gdje?: u grad — u gradu', 'Куди? — u / na + знахідний (idem u grad), де? — u / na + місцевий (u gradu sam), звідки? — iz / s + родовий (iz grada). У хорватській після u / na важливо, рух це чи місце.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Kamo? і Gdje?: u grad — u gradu');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '50f35eca-d82b-565c-8b09-2ee481228782', 'ab238fe7-7be6-5aff-91d5-771529dbe406', 'Kamo? — u / na + знахідний', 'Коли є рух кудись (ići, putovati, voziti se, doći), після u / na — знахідний відмінок: idem u grad, putujem u Zadar, idem na posao, idemo na more. Жіночий рід: -u — u školu, na tržnicu; чоловічий неживий і середній — без змін: u grad, na kolodvor, na more. Українською — «в місто», «на роботу».', 'Kamo? → u grad · na posao · u školu · na more', '[{"hr": "Idem u grad.", "ua": "Я йду в місто."}, {"hr": "Sutra putujem na more.", "ua": "Завтра я їду на море."}, {"hr": "Djeca idu u školu.", "ua": "Діти йдуть до школи."}, {"hr": "Kamo ideš poslije posla?", "ua": "Куди ти йдеш після роботи?"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = 'ab238fe7-7be6-5aff-91d5-771529dbe406')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'd14cf2ce-253a-5d3c-8369-ad1ecbb6cf08', 'ab238fe7-7be6-5aff-91d5-771529dbe406', 'Gdje? — u / na + місцевий', 'Коли людина чи річ уже на місці (biti, živjeti, raditi, čekati), після u / na — місцевий відмінок: u gradu sam, živim u Zadru, na poslu sam, čekam na kolodvoru. Головна помилка: «Idem u gradu» — так не кажуть; правильно Idem u grad, але Ja sam u gradu.', 'Gdje? → u gradu · na poslu · u školi · na moru', '[{"hr": "Ja sam u gradu.", "ua": "Я в місті."}, {"hr": "Luka je još na poslu.", "ua": "Лука ще на роботі."}, {"hr": "Čekam te na kolodvoru.", "ua": "Я чекаю тебе на вокзалі."}, {"hr": "Ljeti smo na moru.", "ua": "Влітку ми на морі."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = 'ab238fe7-7be6-5aff-91d5-771529dbe406')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'f711e487-ef7f-5f0d-980e-43959a05b5ce', 'ab238fe7-7be6-5aff-91d5-771529dbe406', 'Odakle? — iz / s + родовий', 'Звідки? — iz + родовий, якщо «куди» було з u: u grad → iz grada, u školu → iz škole; s (sa) + родовий, якщо «куди» було з na: na posao → s posla, na more → s mora. Отже, пара u — iz, пара na — s.', 'u grad → iz grada · na posao → s posla', '[{"hr": "Vraćam se iz grada.", "ua": "Я повертаюся з міста."}, {"hr": "Dolazim s posla u šest.", "ua": "Я приходжу з роботи о шостій."}, {"hr": "Ovaj vlak stiže iz Rijeke.", "ua": "Цей потяг прибуває з Рієки."}, {"hr": "Djeca idu kući iz škole.", "ua": "Діти йдуть додому зі школи."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = 'ab238fe7-7be6-5aff-91d5-771529dbe406')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'd48e6e7f-12f8-5e08-9a0c-493296fa4fc6', 'ab238fe7-7be6-5aff-91d5-771529dbe406', 'Kamo і kuda; ovdje і ovamo', 'Kamo? — куди (мета руху). Kuda? — якою дорогою, куди саме (у розмові часто й «куди»): Kuda ide ovaj autobus? Так само розрізняють місце й напрям: ovdje — тут, ovamo — сюди; tamo — там і туди; vani — надворі, van — надвір: Dođi ovamo! Idemo van.', 'Gdje? ovdje · vani — Kamo? ovamo · van', '[{"hr": "Dođi ovamo, molim te.", "ua": "Ходи сюди, будь ласка."}, {"hr": "Djeca su vani.", "ua": "Діти надворі."}, {"hr": "Idemo van, lijepo je.", "ua": "Ходімо надвір, гарно."}, {"hr": "Kuda ide ovaj autobus?", "ua": "Куди їде цей автобус?"}]'::jsonb, 4
where exists (select 1 from public.grammar_topics where id = 'ab238fe7-7be6-5aff-91d5-771529dbe406')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', 'ab238fe7-7be6-5aff-91d5-771529dbe406', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = 'ab238fe7-7be6-5aff-91d5-771529dbe406')
  and not exists (select 1 from public.content_reviews where entity_id = 'ab238fe7-7be6-5aff-91d5-771529dbe406' and notes = 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'b6e5c6e1-e16b-5894-819e-e50fe0fc887b', 'A1', 'Орудний відмінок: autobusom, s prijateljem', 'Instrumental: autobusom, s prijateljem', 'Орудний (s kim? s čim? čime?): транспорт без прийменника (autobusom, vlakom), з ким — s / sa + орудний, займенники sa mnom, s tobom; де? — pred, pod, nad, između + орудний.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Орудний відмінок: autobusom, s prijateljem');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '46058c6e-5c5c-50f5-b91e-d336c5505500', 'b6e5c6e1-e16b-5894-819e-e50fe0fc887b', 'Чим? — транспорт: autobusom, vlakom', 'Як в українській «їхати автобусом»: idem autobusom, putujem vlakom, vozim se tramvajem, dolazim biciklom. Закінчення: чоловічий і середній рід — -om (autobus → autobusom, auto → autom), після м’якого приголосного — -em (tramvaj → tramvajem); жіночий рід — -om (žičara → žičarom). Пішки — pješice або pješke.', 'autobus → autobusom · vlak → vlakom · tramvaj → tramvajem', '[{"hr": "Na posao idem tramvajem.", "ua": "На роботу я їжджу трамваєм."}, {"hr": "U Split putujemo vlakom.", "ua": "До Спліта ми їдемо потягом."}, {"hr": "Dolazim biciklom.", "ua": "Я приїжджаю велосипедом."}, {"hr": "Do centra idem pješice.", "ua": "До центру я йду пішки."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = 'b6e5c6e1-e16b-5894-819e-e50fe0fc887b')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '572e1283-9156-53e7-ac4b-e0805ed40616', 'b6e5c6e1-e16b-5894-819e-e50fe0fc887b', 'S kim? — s / sa + орудний', 'З ким або з чим — s + орудний: s prijateljem, s mamom, s djecom, kava s mlijekom. Перед s, z, š, ž і mn — sa: sa sestrom, sa ženom, sa mnom. Без чого — bez + родовий: kava bez šećera.', 's prijateljem · s mamom · sa sestrom', '[{"hr": "Putujem s prijateljem.", "ua": "Я подорожую з другом."}, {"hr": "Idem u kino sa sestrom.", "ua": "Я йду в кіно із сестрою."}, {"hr": "Dijete je s bakom.", "ua": "Дитина з бабусею."}, {"hr": "Uzmi kofer s kotačima.", "ua": "Візьми валізу на коліщатах."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = 'b6e5c6e1-e16b-5894-819e-e50fe0fc887b')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '9447f610-8198-5d13-bf6a-31c313f0d171', 'b6e5c6e1-e16b-5894-819e-e50fe0fc887b', 'Sa mnom, s tobom, s njim, s njom', 'Займенники в орудному: ja → sa mnom, ti → s tobom, on → s njim, ona → s njom, mi → s nama, vi → s vama, oni → s njima. Ideš li sa mnom? — Ідеш зі мною?', 'sa mnom · s tobom · s njim · s njom · s nama · s vama · s njima', '[{"hr": "Ideš li sa mnom?", "ua": "Ідеш зі мною?"}, {"hr": "Mogu li s vama do centra?", "ua": "Можна з вами до центру?"}, {"hr": "Razgovaram s njim svaki dan.", "ua": "Я розмовляю з ним щодня."}, {"hr": "Dođi s nama na more!", "ua": "Їдь з нами на море!"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = 'b6e5c6e1-e16b-5894-819e-e50fe0fc887b')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '7a09dd9c-8a2f-5492-81ef-f337157d8c4e', 'b6e5c6e1-e16b-5894-819e-e50fe0fc887b', 'Pred, pod, nad, između + орудний', 'Де? — pred (перед), pod (під), nad (над), između (між) + орудний: pred kolodvorom, pod mostom, između banke i pošte. Порівняйте: ispred, iza, iznad, ispod + родовий (ispred kolodvora) — значення схоже.', 'pred kolodvorom · pod mostom · između banke i pošte', '[{"hr": "Čekam te pred kolodvorom.", "ua": "Чекаю тебе перед вокзалом."}, {"hr": "Stanica je između banke i pošte.", "ua": "Зупинка між банком і поштою."}, {"hr": "Bicikl je pod stubištem.", "ua": "Велосипед під сходами."}, {"hr": "Nad gradom je dvorac.", "ua": "Над містом — замок."}]'::jsonb, 4
where exists (select 1 from public.grammar_topics where id = 'b6e5c6e1-e16b-5894-819e-e50fe0fc887b')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', 'b6e5c6e1-e16b-5894-819e-e50fe0fc887b', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = 'b6e5c6e1-e16b-5894-819e-e50fe0fc887b')
  and not exists (select 1 from public.content_reviews where entity_id = 'b6e5c6e1-e16b-5894-819e-e50fe0fc887b' and notes = 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.');

-- 2. Перебудова наявних уроків модуля A1.4
-- A1.4 · урок 31: У трамваї й автобусі: проїзний — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '0ef458c5-53cf-530a-99cf-4ccd6e0132e5';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «У трамваї й автобусі: проїзний» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'e6d3bf69-6dc0-5d74-9bcb-450ec2218355') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 31: У трамваї й автобусі: проїзний', title_hr = 'Lekcija 31: U tramvaju i autobusu: pokazna karta',
         objectives = '["Купити й прокомпостувати квиток, поповнити проїзний", "Поговорити з контролером", "Орудний для транспорту: tramvajem, autobusom"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Орудний відмінок: autobusom, s prijateljem' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Орудний відмінок: autobusom, s prijateljem»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'poništač karata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poništiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kontrolor karata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jednokratna karta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dnevna karta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjesečna pokazna karta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'važeći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nadoplatiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'aplikacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'presjedati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'okretište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'noćna linija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ustupiti mjesto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gurati se', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2659b1c2-1bac-5d25-b5ae-e3614e69b13e', 'fill_in_the_blank', 'Na posao idem ___.', 'tramvajem', '["tramvaju", "tramvajem", "tramvaja", "tramvaj"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7d8a11a0-dc97-5e3c-b5a4-7328d9bd3b02', 'multiple_choice', 'Що означає «nadoplatiti»?', 'поповнити (картку, рахунок)', '["робити пересадку", "чинний; дійсний", "поповнити (картку, рахунок)", "денний квиток"]'::jsonb, 'A1', 2, 'PUBLISHED', 'nadoplatiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bc034255-a871-5192-8b15-f419da9420d9', 'multiple_choice', 'Що означає «jednokratna karta»?', 'одноразовий квиток', '["контролер", "одноразовий квиток", "чинний; дійсний", "додаток (app)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'jednokratna karta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8894d233-24eb-5a88-85a6-a201fde6a08c', 'multiple_choice', 'Що означає «dnevna karta»?', 'денний квиток', '["штовхатися", "чинний; дійсний", "нічний маршрут", "денний квиток"]'::jsonb, 'A1', 4, 'PUBLISHED', 'dnevna karta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '485f4295-965d-53b8-901f-e13df6a68223', 'multiple_choice', 'Що означає «poništiti»?', 'прокомпостувати (квиток); скасувати', '["компостер для квитків", "кінцева зупинка", "нічний маршрут", "прокомпостувати (квиток); скасувати"]'::jsonb, 'A1', 5, 'PUBLISHED', 'poništiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '72d84c1d-46f4-5b06-9bb2-ec42394032f1', 'multiple_choice', 'Як хорватською «додаток (app)»?', 'aplikacija', '["mjesečna pokazna karta", "nadoplatiti", "aplikacija", "poništač karata"]'::jsonb, 'A1', 6, 'PUBLISHED', 'aplikacija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fea722e5-e234-5101-89b7-44261b3b70e9', 'multiple_choice', 'Як хорватською «поступитися місцем»?', 'ustupiti mjesto', '["noćna linija", "mjesečna pokazna karta", "nadoplatiti", "ustupiti mjesto"]'::jsonb, 'A1', 7, 'PUBLISHED', 'ustupiti mjesto', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9441ef25-df4d-5874-b337-fdbf997af6d7', 'type_answer', 'Напишіть хорватською: «чинний; дійсний»', 'važeći', null, 'A1', 8, 'PUBLISHED', 'važeći', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e0491a4c-96e4-5544-a5f5-bee628905d9e', 'type_answer', 'Напишіть хорватською: «штовхатися»', 'gurati se', null, 'A1', 9, 'PUBLISHED', 'gurati se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0f5cd814-9fb2-5971-8044-1366e4798270', 'sentence_builder', 'Складіть: «На роботу я їжджу автобусом.»', 'Na posao idem autobusom.', '["posao", "idem", "autobusom.", "Na"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '74e43458-da10-53a3-bbce-9a31df8ab4a8', 'sentence_builder', 'Складіть: «Де можна прокомпостувати квиток?»', 'Gdje mogu poništiti kartu?', '["mogu", "poništiti", "kartu?", "Gdje"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '254be377-1984-5169-8efe-273aa39ddaa5', 'listening', 'Прослухайте і складіть фразу', 'Poništač je kod vrata, žuti aparat.', '["vrata,", "žuti", "aparat.", "kod", "Poništač", "je"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7e941f8b-5e92-5f47-973c-21f184b1db9f', 'listening', 'Прослухайте і складіть фразу', 'Možete kupiti jednokratnu kartu u aplikaciji.', '["Možete", "aplikaciji.", "jednokratnu", "kupiti", "kartu", "u"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a28abe6-2391-5c8a-b193-e635b020a759', 'speaking', 'Поступіться місцем бабусі.', 'Ustupite mjesto baki.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9c0f7ffb-898e-5791-a405-680ec8fc5752', 'speaking', 'Мені треба поповнити проїзний.', 'Moram nadoplatiti pokaznu kartu.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e6d3bf69-6dc0-5d74-9bcb-450ec2218355', v_lesson, 'У трамваї', 'U tramvaju', 3311, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('b6cee351-8121-56f8-9622-3f622c6dc0b2', 'e6d3bf69-6dc0-5d74-9bcb-450ec2218355', 'Daša', 'Oprostite, gdje mogu poništiti kartu?', 'Перепрошую, де можна прокомпостувати квиток?', 1);
  perform pg_temp.turn('75cfd71b-c5c8-5d15-8910-a8ccc3087fee', 'e6d3bf69-6dc0-5d74-9bcb-450ec2218355', 'Putnica', 'Poništač je kod vrata, žuti aparat.', 'Компостер біля дверей, жовтий апарат.', 2);
  perform pg_temp.turn('5d7b97f0-2763-5dfe-a1c6-8c6bcff75e3b', 'e6d3bf69-6dc0-5d74-9bcb-450ec2218355', 'Daša', 'Hvala. Trebam li presjedati do kolodvora?', 'Дякую. Мені треба робити пересадку до вокзалу?', 3);
  perform pg_temp.turn('819c22b2-a406-55ff-8752-f287aafb9097', 'e6d3bf69-6dc0-5d74-9bcb-450ec2218355', 'Putnica', 'Ne, ovim tramvajem stižete ravno do kolodvora.', 'Ні, цим трамваєм ви доїдете просто до вокзалу.', 4);
  perform pg_temp.turn('7613b3f4-82d8-51d9-8454-f688cbcb56df', 'e6d3bf69-6dc0-5d74-9bcb-450ec2218355', 'Daša', 'Je li dnevna karta važeća i u autobusu?', 'Денний квиток дійсний і в автобусі?', 5);
  perform pg_temp.turn('9a59195f-7e74-507d-b916-47df85aacd79', 'e6d3bf69-6dc0-5d74-9bcb-450ec2218355', 'Putnica', 'Jest, do ponoći, i tramvajem i autobusom.', 'Так, до опівночі — і трамваєм, і автобусом.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('93635f8c-a524-50b0-a879-beb7c6ba7587', v_lesson, 'Контроль квитків', 'Kontrola karata', 3312, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('7b2e643c-ef60-5bb9-9f75-2d46a98ad9ab', '93635f8c-a524-50b0-a879-beb7c6ba7587', 'Kontrolor', 'Dobar dan, kontrola karata. Vašu kartu, molim.', 'Добрий день, контроль квитків. Ваш квиток, будь ласка.', 1);
  perform pg_temp.turn('ea62d1d0-8add-58ab-a76f-df9d05078261', '93635f8c-a524-50b0-a879-beb7c6ba7587', 'Darja', 'Izvolite, imam mjesečnu pokaznu kartu.', 'Прошу, у мене місячний проїзний.', 2);
  perform pg_temp.turn('fa6110a9-2508-5e37-b4d7-44d307cb1ce9', '93635f8c-a524-50b0-a879-beb7c6ba7587', 'Kontrolor', 'Karta nije važeća, mjesec je završio.', 'Квиток недійсний, місяць закінчився.', 3);
  perform pg_temp.turn('1d757015-274a-5078-8b1a-e737e139f206', '93635f8c-a524-50b0-a879-beb7c6ba7587', 'Darja', 'Joj, moram je danas nadoplatiti!', 'Ой, мені треба сьогодні його поповнити!', 4);
  perform pg_temp.turn('0262a7d0-53d0-5215-90fc-ca777c1bcecc', '93635f8c-a524-50b0-a879-beb7c6ba7587', 'Kontrolor', 'Možete kupiti jednokratnu kartu u aplikaciji.', 'Можете купити одноразовий квиток у застосунку.', 5);
  perform pg_temp.turn('511809cb-2ecc-5b67-9b78-37eed2692f35', '93635f8c-a524-50b0-a879-beb7c6ba7587', 'Darja', 'Evo, kupujem je odmah. Hvala vam!', 'Ось, купую одразу. Дякую вам!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 32: Розклад поїздів — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'cae7a47d-7fb4-5b03-a8cc-5a0df2ccd92f';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Розклад поїздів» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'c923d02c-7789-56ef-b0b3-02ea03777749') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 32: Розклад поїздів', title_hr = 'Lekcija 32: Vozni red vlakova',
         objectives = '["Запитати про потяг: коли відправляється, коли прибуває, з якої колії", "Купити квиток у перший чи другий клас", "Питання: Kada…? S kojeg…? Je li…?"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Побудова питань' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Побудова питань»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'polaziti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stizati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odlazak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolosijek', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vagon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brzi vlak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prvi razred', v_pos);
  v_pos := pg_temp.word(v_lesson, 'drugi razred', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rezervacija sjedala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jednosmjerna karta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kondukter', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otkazan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'željeznica', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '6ecd1d28-db49-51cc-a3b1-6a532b4d7476', 'fill_in_the_blank', 'S ___ kolosijeka polazi vlak?', 'kojeg', '["koja", "koji", "kojeg", "kojem"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '791f62cf-8aeb-5157-806e-fc224f63cb91', 'multiple_choice', 'Що означає «rezervacija sjedala»?', 'бронювання місця', '["скасований", "другий клас (у поїзді)", "купе", "бронювання місця"]'::jsonb, 'A1', 2, 'PUBLISHED', 'rezervacija sjedala', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '520d05bf-ccd7-5886-9971-374a8a47f4d1', 'multiple_choice', 'Що означає «prvi razred»?', 'перший клас (у поїзді)', '["скасований", "колія", "кондуктор", "перший клас (у поїзді)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'prvi razred', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '448e6783-ea56-562c-afad-751567ac6001', 'multiple_choice', 'Що означає «jednosmjerna karta»?', 'квиток в один бік', '["бронювання місця", "квиток в один бік", "другий клас (у поїзді)", "відправлятися"]'::jsonb, 'A1', 4, 'PUBLISHED', 'jednosmjerna karta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '20cee968-1dd1-593f-acb5-618775fbb174', 'multiple_choice', 'Як хорватською «відправлятися»?', 'polaziti', '["stizati", "željeznica", "kupe", "polaziti"]'::jsonb, 'A1', 5, 'PUBLISHED', 'polaziti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '79331d3b-9962-5b6e-9ff6-9b3fe81fd4a4', 'multiple_choice', 'Як хорватською «кондуктор»?', 'kondukter', '["stizati", "kondukter", "otkazan", "željeznica"]'::jsonb, 'A1', 6, 'PUBLISHED', 'kondukter', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '21e8465d-a7b5-5019-ac82-f7617e38778b', 'type_answer', 'Напишіть хорватською: «купе»', 'kupe', null, 'A1', 7, 'PUBLISHED', 'kupe', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ab39f6f5-f0d6-5405-b931-2846949f561a', 'type_answer', 'Напишіть хорватською: «відбуття»', 'odlazak', null, 'A1', 8, 'PUBLISHED', 'odlazak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2577cb83-9e85-5bca-8376-8c836e9c46dd', 'type_answer', 'Напишіть хорватською: «залізниця»', 'željeznica', null, 'A1', 9, 'PUBLISHED', 'željeznica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '224f1a69-3219-5b23-9333-2f1006e4177f', 'sentence_builder', 'Складіть: «Коли прибуває потяг?»', 'Kada stiže vlak?', '["Kada", "vlak?", "stiže"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '36d5cca8-474e-5e1b-a2d7-46b4a20b35b6', 'sentence_builder', 'Складіть: «Квиток у другий клас, будь ласка.»', 'Kartu za drugi razred, molim.', '["razred,", "molim.", "Kartu", "za", "drugi"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '71e95695-775e-562b-bf6b-76a985e9425a', 'listening', 'Прослухайте і складіть фразу', 'Brzi vlak polazi u osam i petnaest.', '["u", "Brzi", "vlak", "osam", "polazi", "petnaest.", "i"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '55b51db5-d343-563d-8891-0f9cdddd0ef8', 'listening', 'Прослухайте і складіть фразу', 'Kako onda mogu stići u Osijek?', '["mogu", "u", "onda", "Kako", "Osijek?", "stići"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '61ae2d53-3f31-56db-94da-ae41af9f7cee', 'speaking', 'Коли відправляється потяг до Спліта?', 'Kada polazi vlak za Split?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5a86a3b2-c11b-55ba-adc6-a6e0a063282f', 'speaking', 'Потяг скасовано?', 'Je li vlak otkazan?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c923d02c-7789-56ef-b0b3-02ea03777749', v_lesson, 'На касі вокзалу', 'Na blagajni kolodvora', 3321, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('4bca3c85-489e-5906-b935-d0ec37bb2be9', 'c923d02c-7789-56ef-b0b3-02ea03777749', 'Daša', 'Dobar dan, kada polazi vlak za Split?', 'Добрий день, коли відправляється потяг до Спліта?', 1);
  perform pg_temp.turn('2dd79820-ee64-5825-b2b6-4021a958a782', 'c923d02c-7789-56ef-b0b3-02ea03777749', 'Blagajnica', 'Brzi vlak polazi u osam i petnaest.', 'Швидкий потяг відправляється о восьмій п’ятнадцять.', 2);
  perform pg_temp.turn('8df5e9cb-54fb-5adf-8a22-180f3b6aa1b6', 'c923d02c-7789-56ef-b0b3-02ea03777749', 'Daša', 'Kada stiže u Split?', 'Коли він прибуває до Спліта?', 3);
  perform pg_temp.turn('18167978-2413-51b9-9ec1-7b6b75bea15c', 'c923d02c-7789-56ef-b0b3-02ea03777749', 'Blagajnica', 'U četiri popodne. Želite li drugi razred?', 'О четвертій дня. Бажаєте другий клас?', 4);
  perform pg_temp.turn('0f557174-5912-5461-bc35-27c4a55c98db', 'c923d02c-7789-56ef-b0b3-02ea03777749', 'Daša', 'Da, jednosmjernu kartu i rezervaciju sjedala.', 'Так, квиток в один бік і бронювання місця.', 5);
  perform pg_temp.turn('a91bf946-27b7-5504-87e0-20849e1684e6', 'c923d02c-7789-56ef-b0b3-02ea03777749', 'Blagajnica', 'Izvolite. Vaš vagon je broj tri.', 'Прошу. Ваш вагон — номер три.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('95e6c4cf-b004-50ec-9331-f30f02591f09', v_lesson, 'На пероні', 'Na peronu', 3322, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('3de81294-4729-5d7f-85ce-d64ef9d179a1', '95e6c4cf-b004-50ec-9331-f30f02591f09', 'Marko', 'Oprostite, s kojeg kolosijeka polazi vlak za Rijeku?', 'Перепрошую, з якої колії відправляється потяг до Рієки?', 1);
  perform pg_temp.turn('6a9f58d3-caf5-54b6-8813-8a0d79569240', '95e6c4cf-b004-50ec-9331-f30f02591f09', 'Kondukter', 'S drugog, ali danas kasni dvadeset minuta.', 'З другої, але сьогодні він запізнюється на двадцять хвилин.', 2);
  perform pg_temp.turn('30280bca-627e-5975-b347-bbea1b0bdd1c', '95e6c4cf-b004-50ec-9331-f30f02591f09', 'Marko', 'A vlak za Osijek?', 'А потяг до Осієка?', 3);
  perform pg_temp.turn('5ae2adfa-f4bb-5477-92b3-5c5a8619229e', '95e6c4cf-b004-50ec-9331-f30f02591f09', 'Kondukter', 'Nažalost, otkazan je zbog radova na pruzi.', 'На жаль, його скасовано через ремонт колії.', 4);
  perform pg_temp.turn('210b099e-c30c-5bb4-8106-890720e3cdb0', '95e6c4cf-b004-50ec-9331-f30f02591f09', 'Marko', 'Kako onda mogu stići u Osijek?', 'Як тоді мені дістатися до Осієка?', 5);
  perform pg_temp.turn('fba3a5d1-502f-5fec-b793-5b029bae08d2', '95e6c4cf-b004-50ec-9331-f30f02591f09', 'Kondukter', 'Željeznica ima zamjenski autobus ispred kolodvora.', 'Залізниця пускає замінний автобус перед вокзалом.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 33: Міжміський автобус — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'c1b32b15-8f3c-5f75-bba9-e831d544ec7b';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Міжміський автобус» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '118b5678-d51b-5e7d-af85-74a60044efef') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 33: Міжміський автобус', title_hr = 'Lekcija 33: Međugradski autobus',
         objectives = '["Купити квиток на міжміський автобус і вибрати місце", "Запитати про тривалість, пересадку й зупинки", "Куди? u Zadar — де? u Zadru"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Kamo? і Gdje?: u grad — u gradu' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Kamo? і Gdje?: u grad — u gradu»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'međugradski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'relacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izravan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'presjedanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'noćni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trajati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stanka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sjedalo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sjedalo do prolaza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prtljažni prostor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naplatiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vezati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odredište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mučnina', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '0a460944-6f51-52c0-b902-0a20d776c6f2', 'fill_in_the_blank', 'Sutra putujem ___ more.', 'na', '["po", "na", "iz", "u"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '86a82976-9220-5604-a80d-d0592753db10', 'multiple_choice', 'Що означає «odredište»?', 'місце призначення', '["місце призначення", "тривати", "зав’язувати; пристібати", "багажне відділення"]'::jsonb, 'A1', 2, 'PUBLISHED', 'odredište', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '57e98c73-cf69-527f-ac8f-c66a1b733509', 'multiple_choice', 'Що означає «sjedalo do prolaza»?', 'місце біля проходу', '["прямий (без пересадок)", "місце біля проходу", "тривати", "зупинка в дорозі, перерва"]'::jsonb, 'A1', 3, 'PUBLISHED', 'sjedalo do prolaza', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7e8c95ec-3339-5f54-90b8-50d80d2c19d0', 'multiple_choice', 'Що означає «prtljažni prostor»?', 'багажне відділення', '["багажне відділення", "стягнути оплату", "зупинка в дорозі, перерва", "маршрут; напрямок (рейсу)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'prtljažni prostor', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '96f14cdb-bddd-58ea-897f-b0aadc905c3d', 'multiple_choice', 'Як хорватською «пересадка (на транспорті)»?', 'presjedanje', '["prtljažni prostor", "presjedanje", "noćni", "odredište"]'::jsonb, 'A1', 5, 'PUBLISHED', 'presjedanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8e63a9d5-7fe4-5ebd-9b3c-5585a7356333', 'multiple_choice', 'Як хорватською «тривати»?', 'trajati', '["trajati", "sjedalo", "međugradski", "stanka"]'::jsonb, 'A1', 6, 'PUBLISHED', 'trajati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a512e4eb-19b8-59e0-a1dd-49a1f6c1deb4', 'type_answer', 'Напишіть хорватською: «зав’язувати; пристібати»', 'vezati', null, 'A1', 7, 'PUBLISHED', 'vezati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7bd27b3c-de29-5940-a3a5-837ed8144d2f', 'type_answer', 'Напишіть хорватською: «нудота»', 'mučnina', null, 'A1', 8, 'PUBLISHED', 'mučnina', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ed52de18-4558-5cb4-9a3c-4d32f0722a86', 'type_answer', 'Напишіть хорватською: «міжміський»', 'međugradski', null, 'A1', 9, 'PUBLISHED', 'međugradski', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cb98b18e-cf55-5f74-a00a-d077b6ace510', 'sentence_builder', 'Складіть: «Скільки триває поїздка?»', 'Koliko traje vožnja?', '["traje", "vožnja?", "Koliko"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f0bca473-367c-5a81-bde9-388ab5fbae18', 'sentence_builder', 'Складіть: «Чи є прямий автобус до Задара?»', 'Ima li izravan autobus za Zadar?', '["izravan", "autobus", "Zadar?", "Ima", "za", "li"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '21a25a00-6ca3-5f69-9e8d-e1013c805819', 'listening', 'Прослухайте і складіть фразу', 'Koliko traje vožnja?', '["vožnja?", "Koliko", "traje"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3cfef420-0789-5b1d-adcc-f0f864d9a8f9', 'listening', 'Прослухайте і складіть фразу', 'Naravno, prvo sjedalo je slobodno.', '["sjedalo", "je", "slobodno.", "prvo", "Naravno,"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5d565146-ee7c-5be9-be26-fe6b1032e695', 'speaking', 'Я їду в Задар.', 'Putujem u Zadar.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c22d529b-e8e3-56c8-b7dc-dc32bff171f7', 'speaking', 'Можна місце біля проходу?', 'Mogu li dobiti sjedalo do prolaza?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('118b5678-d51b-5e7d-af85-74a60044efef', v_lesson, 'Квиток до Задара', 'Karta za Zadar', 3331, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('07ca2e49-79c1-59dd-ba51-5632b0b4dc25', '118b5678-d51b-5e7d-af85-74a60044efef', 'Daša', 'Dobar dan, ima li izravan autobus za Zadar?', 'Добрий день, є прямий автобус до Задара?', 1);
  perform pg_temp.turn('f7de94e5-6af5-5a8a-a50a-2f945d37db82', '118b5678-d51b-5e7d-af85-74a60044efef', 'Blagajnik', 'Ima, u deset sati, bez presjedanja.', 'Є, о десятій, без пересадки.', 2);
  perform pg_temp.turn('db8f2a4f-0cd0-531b-b227-54e1a65d6078', '118b5678-d51b-5e7d-af85-74a60044efef', 'Daša', 'Koliko traje vožnja?', 'Скільки триває поїздка?', 3);
  perform pg_temp.turn('b81133f9-27d6-5bf1-9d86-da61138a5873', '118b5678-d51b-5e7d-af85-74a60044efef', 'Blagajnik', 'Oko tri i pol sata, sa stankom od petnaest minuta.', 'Близько трьох з половиною годин, із зупинкою на п’ятнадцять хвилин.', 4);
  perform pg_temp.turn('621c0e6a-fa93-5794-8558-653cdf8234e3', '118b5678-d51b-5e7d-af85-74a60044efef', 'Daša', 'Mogu li dobiti sjedalo do prolaza?', 'Можна місце біля проходу?', 5);
  perform pg_temp.turn('eee3f997-4240-5662-aa82-af3a9ba95ba4', '118b5678-d51b-5e7d-af85-74a60044efef', 'Blagajnik', 'Možete. Za prtljažni prostor naplaćujemo dva eura.', 'Можна. За багажне відділення беремо два євро.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1b3e505f-0309-50d0-99ee-6f21432a0574', v_lesson, 'В автобусі', 'U autobusu', 3332, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('6b2aecda-3f1f-51b4-842b-fd83e89eac45', '1b3e505f-0309-50d0-99ee-6f21432a0574', 'Vozač', 'Dobar dan. Molim vas, vežite pojaseve.', 'Добрий день. Будь ласка, пристебніться.', 1);
  perform pg_temp.turn('2cdeffc5-0eb5-5f1c-b3ea-a1f58527710a', '1b3e505f-0309-50d0-99ee-6f21432a0574', 'Darja', 'Oprostite, staje li autobus usput?', 'Перепрошую, автобус зупиняється дорогою?', 2);
  perform pg_temp.turn('f0db5d1c-2b2c-50d3-bf42-f49ea0d499eb', '1b3e505f-0309-50d0-99ee-6f21432a0574', 'Vozač', 'Samo jednom, na odmorištu.', 'Лише раз, на зоні відпочинку.', 3);
  perform pg_temp.turn('168b0b7c-0317-567a-b8fd-fc34ef41a0f0', '1b3e505f-0309-50d0-99ee-6f21432a0574', 'Darja', 'Moje dijete ima mučninu. Možemo li sjesti naprijed?', 'Мою дитину нудить. Можемо сісти спереду?', 4);
  perform pg_temp.turn('825c0efd-39ea-5c27-b793-fca02d70c9d0', '1b3e505f-0309-50d0-99ee-6f21432a0574', 'Vozač', 'Naravno, prvo sjedalo je slobodno.', 'Звісно, перше сидіння вільне.', 5);
  perform pg_temp.turn('f77948cc-f6ec-590d-a3c4-992913efc20f', '1b3e505f-0309-50d0-99ee-6f21432a0574', 'Darja', 'Hvala. Stižemo li u Zadar u podne?', 'Дякую. Ми будемо в Задарі опівдні?', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 34: В аеропорту — перебудова: 19 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '69ec0776-4f69-5f86-afac-6652234a7da5';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «В аеропорту» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '4fd79a5b-8c49-5a91-aac3-f3f162cc2142') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 34: В аеропорту', title_hr = 'Lekcija 34: U zračnoj luci',
         objectives = '["Зареєструватися на рейс і здати багаж", "Знайти вихід на посадку й багажну стрічку", "Присвійні: moj kofer, vaša propusnica, naš let"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Присвійні займенники' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Присвійні займенники»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zrakoplovna kompanija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijava za let', v_pos);
  v_pos := pg_temp.word(v_lesson, 'let', v_pos);
  v_pos := pg_temp.word(v_lesson, 'direktni let', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otkazivanje leta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'terminal', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kofer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prtljaga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ručna prtljaga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'traka za prtljagu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izgubljena prtljaga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kontrola sigurnosti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'carina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izlaz za ukrcaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ukrcajna propusnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sjedalo do prozora', v_pos);
  v_pos := pg_temp.word(v_lesson, 'avion', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polijetanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slijetanje', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '4398d54c-4ac4-5da5-a1c5-3c2cc88340c7', 'fill_in_the_blank', 'Ovo je ___ ukrcajna propusnica.', 'vaša', '["vaše", "vašu", "vaša", "vaš"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '18d9c499-6b73-5d87-95a7-5ba944993f7c', 'multiple_choice', 'Що означає «traka za prtljagu»?', 'багажна стрічка', '["контроль безпеки", "багажна стрічка", "авіакомпанія", "посадковий талон"]'::jsonb, 'A1', 2, 'PUBLISHED', 'traka za prtljagu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ca26e349-4e73-5cbe-916a-49c67e50d843', 'multiple_choice', 'Що означає «otkazivanje leta»?', 'скасування рейсу', '["загублений багаж", "реєстрація на рейс", "скасування рейсу", "літак"]'::jsonb, 'A1', 3, 'PUBLISHED', 'otkazivanje leta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'acb2a0b4-44e0-5d44-8be8-0cec00f4c8a7', 'multiple_choice', 'Що означає «slijetanje»?', 'приземлення (літака)', '["термінал", "вихід на посадку", "приземлення (літака)", "митниця; мито"]'::jsonb, 'A1', 4, 'PUBLISHED', 'slijetanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd036dfb8-f777-5f9e-ae41-8ada1ab8c530', 'multiple_choice', 'Що означає «prijava za let»?', 'реєстрація на рейс', '["літак", "реєстрація на рейс", "авіакомпанія", "валіза"]'::jsonb, 'A1', 5, 'PUBLISHED', 'prijava za let', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b6aa5ee4-77da-5d6d-8a4b-c1721f0c27f2', 'multiple_choice', 'Як хорватською «літак»?', 'avion', '["kofer", "prtljaga", "traka za prtljagu", "avion"]'::jsonb, 'A1', 6, 'PUBLISHED', 'avion', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2043fc0c-3a45-57d3-9a9d-f2bdea9e0571', 'multiple_choice', 'Як хорватською «термінал»?', 'terminal', '["carina", "ručna prtljaga", "terminal", "ukrcajna propusnica"]'::jsonb, 'A1', 7, 'PUBLISHED', 'terminal', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '122e3486-4060-5985-80cc-78a89bee6583', 'type_answer', 'Напишіть хорватською: «ручна поклажа»', 'ručna prtljaga', null, 'A1', 8, 'PUBLISHED', 'ručna prtljaga', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b661d0df-b579-55b6-88c4-e509f2be6eb5', 'type_answer', 'Напишіть хорватською: «валіза»', 'kofer', null, 'A1', 9, 'PUBLISHED', 'kofer', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2fc8b6c5-06a4-5016-82b4-e1ae3fecacb7', 'sentence_builder', 'Складіть: «Це моя валіза.»', 'Ovo je moj kofer.', '["Ovo", "kofer.", "je", "moj"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'af224909-4c86-5dfe-b18b-eed490a86546', 'sentence_builder', 'Складіть: «Наш рейс скасовано.»', 'Naš let je otkazan.', '["je", "otkazan.", "let", "Naš"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '36f9db63-b645-5d20-a6b7-0dc1e8df02a0', 'listening', 'Прослухайте і складіть фразу', 'Želite li sjedalo do prozora?', '["prozora?", "Želite", "sjedalo", "do", "li"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f8d5688-a93f-51ca-a182-3d6f163c7174', 'listening', 'Прослухайте і складіть фразу', 'Koji je broj vašeg leta?', '["broj", "vašeg", "Koji", "je", "leta?"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '28be3f65-0f07-568d-88b5-bdc44ae04584', 'speaking', 'Де багажна стрічка?', 'Gdje je traka za prtljagu?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7e9380b1-0971-5f00-b63b-39f16e154af4', 'speaking', 'Я не можу знайти свій багаж.', 'Ne mogu naći svoju prtljagu.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4fd79a5b-8c49-5a91-aac3-f3f162cc2142', v_lesson, 'Реєстрація на рейс', 'Prijava za let', 3341, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('f3b408b6-a5cb-5762-bfe9-5760258fe6c6', '4fd79a5b-8c49-5a91-aac3-f3f162cc2142', 'Službenica', 'Dobar dan. Vašu putovnicu, molim.', 'Добрий день. Ваш паспорт, будь ласка.', 1);
  perform pg_temp.turn('d74ff43e-a78e-555e-afae-7c75d17e7d42', '4fd79a5b-8c49-5a91-aac3-f3f162cc2142', 'Daša', 'Izvolite. Ovo je moj kofer, a ova torba je ručna prtljaga.', 'Прошу. Це моя валіза, а ця сумка — ручна поклажа.', 2);
  perform pg_temp.turn('e619df13-65cc-5a67-8707-ac4d3e21d944', '4fd79a5b-8c49-5a91-aac3-f3f162cc2142', 'Službenica', 'Želite li sjedalo do prozora?', 'Бажаєте місце біля вікна?', 3);
  perform pg_temp.turn('1b40273e-9161-5ef8-a420-1571ac6657d3', '4fd79a5b-8c49-5a91-aac3-f3f162cc2142', 'Daša', 'Da, molim. S kojeg izlaza polazi let?', 'Так, будь ласка. З якого виходу відправляється рейс?', 4);
  perform pg_temp.turn('2e0a9fc5-dcd9-589b-b7cb-333f59599588', '4fd79a5b-8c49-5a91-aac3-f3f162cc2142', 'Službenica', 'Izlaz sedam. Evo vaše ukrcajne propusnice.', 'Вихід сім. Ось ваш посадковий талон.', 5);
  perform pg_temp.turn('441ccf4e-d9c5-5d67-a677-32078cf465f9', '4fd79a5b-8c49-5a91-aac3-f3f162cc2142', 'Daša', 'Hvala. Gdje je kontrola sigurnosti?', 'Дякую. Де контроль безпеки?', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d21a7de4-70f9-5b01-84ed-bda22ba4638b', v_lesson, 'Де мій багаж?', 'Gdje je moja prtljaga?', 3342, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('1f6e4aec-bb4d-5c4c-8ac9-4cedff9a181f', 'd21a7de4-70f9-5b01-84ed-bda22ba4638b', 'Marko', 'Oprostite, moj kofer nije na traci za prtljagu.', 'Перепрошую, моєї валізи немає на багажній стрічці.', 1);
  perform pg_temp.turn('23054897-2ebf-5400-8db3-9e159509f94c', 'd21a7de4-70f9-5b01-84ed-bda22ba4638b', 'Službenik', 'Koji je broj vašeg leta?', 'Який номер вашого рейсу?', 2);
  perform pg_temp.turn('190606d7-6178-54aa-bcb4-37c64e200e07', 'd21a7de4-70f9-5b01-84ed-bda22ba4638b', 'Marko', 'Let iz Beča, slijetanje u deset sati.', 'Рейс із Відня, приземлення о десятій.', 3);
  perform pg_temp.turn('d8dc9752-f061-5303-8e77-d3e86f2e86d5', 'd21a7de4-70f9-5b01-84ed-bda22ba4638b', 'Službenik', 'Ispunite obrazac za izgubljenu prtljagu.', 'Заповніть бланк про загублений багаж.', 4);
  perform pg_temp.turn('4f620f8c-4af9-5012-9af8-c5b45af8ef93', 'd21a7de4-70f9-5b01-84ed-bda22ba4638b', 'Marko', 'Kada mogu dobiti svoj kofer?', 'Коли я зможу отримати свою валізу?', 5);
  perform pg_temp.turn('633ff5ca-1d63-5e2c-904e-124d9ff7fe33', 'd21a7de4-70f9-5b01-84ed-bda22ba4638b', 'Službenik', 'Obično sutra. Šaljemo ga na vašu adresu.', 'Зазвичай завтра. Ми надішлемо її на вашу адресу.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 35: Таксі: адреса й багаж — перебудова: 13 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '458ee6ec-31d1-5758-adef-03612626088a';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Таксі: адреса й багаж» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '667d8b9d-8db3-5c5a-aa2d-887cef115bf3') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 35: Таксі: адреса й багаж', title_hr = 'Lekcija 35: Taksi: adresa i prtljaga',
         objectives = '["Викликати таксі й назвати адресу", "Попросити водія: зупиніться, почекайте, увімкніть кондиціонер", "Наказовий: stanite, pričekajte, vozite"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Наказовий спосіб' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Наказовий спосіб»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'naručiti taksi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'taksimetar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cijena vožnje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kućni broj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prtljažnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stražnje sjedalo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prednje sjedalo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najkraći put', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaobići', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pričekati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plaćati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'klima', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b1701062-b611-5bcc-bde7-d8891b9201d0', 'fill_in_the_blank', '___ ovdje, molim vas.', 'Stanite', '["Stane", "Stanem", "Stanite", "Stati"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fcecb9a1-9f6f-5bbe-a982-0dba741f8e4a', 'multiple_choice', 'Що означає «naručiti taksi»?', 'викликати таксі', '["найкоротший шлях", "почекати", "номер будинку", "викликати таксі"]'::jsonb, 'A1', 2, 'PUBLISHED', 'naručiti taksi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '92e68761-5a53-58a3-9e5a-5be4406c4f73', 'multiple_choice', 'Що означає «stražnje sjedalo»?', 'заднє сидіння', '["кондиціонер", "заднє сидіння", "об’їхати, обійти", "почекати"]'::jsonb, 'A1', 3, 'PUBLISHED', 'stražnje sjedalo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d1dfca5-9749-533e-ab4a-cd494ebefb19', 'multiple_choice', 'Що означає «stati»?', 'зупинитися', '["багажник", "викликати таксі", "зупинитися", "переднє сидіння"]'::jsonb, 'A1', 4, 'PUBLISHED', 'stati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd66f1c79-5fb5-5741-9724-89e6a9254508', 'multiple_choice', 'Що означає «zaobići»?', 'об’їхати, обійти', '["почекати", "зупинитися", "кондиціонер", "об’їхати, обійти"]'::jsonb, 'A1', 5, 'PUBLISHED', 'zaobići', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '05a8ad33-e122-56c5-ba9c-9ab53c3ce917', 'multiple_choice', 'Як хорватською «вартість поїздки»?', 'cijena vožnje', '["cijena vožnje", "zaobići", "stražnje sjedalo", "naručiti taksi"]'::jsonb, 'A1', 6, 'PUBLISHED', 'cijena vožnje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b9f13841-6018-5656-b0a8-3fb073a52fb9', 'multiple_choice', 'Як хорватською «багажник»?', 'prtljažnik', '["najkraći put", "zaobići", "prtljažnik", "taksimetar"]'::jsonb, 'A1', 7, 'PUBLISHED', 'prtljažnik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e4f7c97b-ccf5-5f34-af03-fc789d90f566', 'type_answer', 'Напишіть хорватською: «таксометр»', 'taksimetar', null, 'A1', 8, 'PUBLISHED', 'taksimetar', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c565bfde-cfd2-5333-b39e-201fd807b2b3', 'type_answer', 'Напишіть хорватською: «почекати»', 'pričekati', null, 'A1', 9, 'PUBLISHED', 'pričekati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7e78c678-7f05-522f-af64-b4aa94ab9886', 'sentence_builder', 'Складіть: «Почекайте мене тут.»', 'Pričekajte me ovdje.', '["Pričekajte", "ovdje.", "me"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0e6de6a1-c37b-5baa-97cd-f83423348028', 'sentence_builder', 'Складіть: «Відкрийте багажник, будь ласка.»', 'Otvorite prtljažnik, molim.', '["prtljažnik,", "molim.", "Otvorite"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3c84d41e-2bc1-5374-aacc-dc9b5840b42a', 'listening', 'Прослухайте і складіть фразу', 'Koji je kućni broj?', '["je", "broj?", "kućni", "Koji"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '41a26331-4d3d-5134-8c37-64a3327ffc2e', 'listening', 'Прослухайте і складіть фразу', 'Može. Možete li upaliti klimu?', '["Možete", "upaliti", "Može.", "li", "klimu?"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c24e0fbe-bea7-5e28-9411-71e8592d1d0e', 'speaking', 'Я хочу викликати таксі.', 'Želim naručiti taksi.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a2834a5e-38c6-516f-a530-8060628054e8', 'speaking', 'Зупиніться тут, будь ласка.', 'Stanite ovdje, molim.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('667d8b9d-8db3-5c5a-aa2d-887cef115bf3', v_lesson, 'Викликаю таксі', 'Naručujem taksi', 3351, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('fa9726cb-579b-5d98-82c3-310bb8bbcd14', '667d8b9d-8db3-5c5a-aa2d-887cef115bf3', 'Daša', 'Dobar dan, želim naručiti taksi za Ulicu grada Vukovara.', 'Добрий день, хочу викликати таксі на вулицю Граду Вуковара.', 1);
  perform pg_temp.turn('31c41e36-6dd6-588b-a291-a4aafdb5851e', '667d8b9d-8db3-5c5a-aa2d-887cef115bf3', 'Dispečerka', 'Koji je kućni broj?', 'Який номер будинку?', 2);
  perform pg_temp.turn('fb1b4274-d895-53ac-82db-c92f69da31d0', '667d8b9d-8db3-5c5a-aa2d-887cef115bf3', 'Daša', 'Dvadeset dva. Imam veliki kofer.', 'Двадцять два. У мене велика валіза.', 3);
  perform pg_temp.turn('5500de6d-6d1f-50a7-97d2-cd0f8a01e9bc', '667d8b9d-8db3-5c5a-aa2d-887cef115bf3', 'Dispečerka', 'Nema problema, stane u prtljažnik.', 'Без проблем, вона поміститься в багажник.', 4);
  perform pg_temp.turn('7559d02a-f264-5b01-a621-459c405a8b45', '667d8b9d-8db3-5c5a-aa2d-887cef115bf3', 'Daša', 'Kolika je cijena vožnje do zračne luke?', 'Скільки коштує поїздка до аеропорту?', 5);
  perform pg_temp.turn('cfee1c67-e0c3-55d2-a6ba-93f3e86edfcb', '667d8b9d-8db3-5c5a-aa2d-887cef115bf3', 'Dispečerka', 'Oko trideset eura, prema taksimetru.', 'Близько тридцяти євро, за таксометром.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6a218fb4-4e02-5825-8744-f5d9813cffa4', v_lesson, 'У таксі', 'U taksiju', 3352, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('7bc54431-b4ce-5ed5-ba1f-f7a48f37d03b', '6a218fb4-4e02-5825-8744-f5d9813cffa4', 'Taksist', 'Dobar dan, izvolite. Vežite pojas, molim.', 'Добрий день, прошу. Пристебніться, будь ласка.', 1);
  perform pg_temp.turn('c8ac56ca-1bb9-55b7-a940-f5fe03507b9c', '6a218fb4-4e02-5825-8744-f5d9813cffa4', 'Marko', 'Vozite najkraćim putem, molim vas, žurim se.', 'Їдьте найкоротшим шляхом, будь ласка, я поспішаю.', 2);
  perform pg_temp.turn('fb8b359e-f206-5312-b451-d318fc1ab1b4', '6a218fb4-4e02-5825-8744-f5d9813cffa4', 'Taksist', 'Na glavnoj cesti je gužva, idemo preko obilaznice.', 'На головній дорозі затор, поїдемо об’їзною.', 3);
  perform pg_temp.turn('b8317d1e-9630-53fd-9e05-9173e31f70b8', '6a218fb4-4e02-5825-8744-f5d9813cffa4', 'Marko', 'Može. Možete li upaliti klimu?', 'Добре. Можете увімкнути кондиціонер?', 4);
  perform pg_temp.turn('582b75f5-4089-5a26-90a6-d032f2076b6f', '6a218fb4-4e02-5825-8744-f5d9813cffa4', 'Taksist', 'Naravno. Gdje da stanem?', 'Звісно. Де мені зупинитися?', 5);
  perform pg_temp.turn('ad75abcd-4874-5536-b959-8290b8e0f8cc', '6a218fb4-4e02-5825-8744-f5d9813cffa4', 'Marko', 'Stanite ispred hotela i pričekajte me pet minuta.', 'Зупиніться перед готелем і почекайте мене п’ять хвилин.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 36: Велосипед і самокат — перебудова: 15 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '0b04119b-4d38-5d99-8237-caa95fdcfd95';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Велосипед і самокат» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '279abd52-3497-5397-972f-8ddbe7169a39') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 36: Велосипед і самокат', title_hr = 'Lekcija 36: Bicikl i romobil',
         objectives = '["Узяти велосипед напрокат і перевірити гальма", "Пояснити поломку: проколоте колесо, ланцюг", "Орудний: biciklom, s kacigom, s prijateljem"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Орудний відмінок: autobusom, s prijateljem' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Орудний відмінок: autobusom, s prijateljem»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'iznajmljivanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kaciga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lokot', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kotač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lanac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pedala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvonce', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kočnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kočiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'probušen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'napumpati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'biciklist', v_pos);
  v_pos := pg_temp.word(v_lesson, 'parkiralište za bicikle', v_pos);
  v_pos := pg_temp.word(v_lesson, 'električni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pažljivo', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '3eabcde0-13fe-5e4f-bec3-d777843dbafb', 'fill_in_the_blank', 'Vozim se ___ po gradu.', 'biciklom', '["biciklom", "bicikla", "bicikl", "biciklu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'de1329a5-fe63-52ba-a21a-1d7863a24cfb', 'multiple_choice', 'Що означає «pažljivo»?', 'обережно; уважно', '["педаль", "обережно; уважно", "гальмувати", "велосипедист"]'::jsonb, 'A1', 2, 'PUBLISHED', 'pažljivo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'de974a65-18a5-532a-befe-92c7c5d78b71', 'multiple_choice', 'Що означає «iznajmljivanje»?', 'прокат, оренда', '["гальмувати", "шолом", "прокат, оренда", "педаль"]'::jsonb, 'A1', 3, 'PUBLISHED', 'iznajmljivanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7dd86942-772a-5f5d-9392-93658b15599b', 'multiple_choice', 'Що означає «kočnica»?', 'гальмо', '["шолом", "гальмо", "накачати", "велопарковка"]'::jsonb, 'A1', 4, 'PUBLISHED', 'kočnica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '74aa4491-28bf-5057-bd92-9dafa55044ab', 'multiple_choice', 'Як хорватською «гальмувати»?', 'kočiti', '["pedala", "kočiti", "biciklist", "probušen"]'::jsonb, 'A1', 5, 'PUBLISHED', 'kočiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f1572458-ea76-5075-af08-c741f0359211', 'multiple_choice', 'Як хорватською «шолом»?', 'kaciga', '["biciklist", "iznajmljivanje", "kaciga", "parkiralište za bicikle"]'::jsonb, 'A1', 6, 'PUBLISHED', 'kaciga', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c9584c97-702e-5346-930d-6deb770190b8', 'type_answer', 'Напишіть хорватською: «велосипедист»', 'biciklist', null, 'A1', 7, 'PUBLISHED', 'biciklist', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2918a904-c236-5418-9521-dc63e6dc199c', 'type_answer', 'Напишіть хорватською: «накачати»', 'napumpati', null, 'A1', 8, 'PUBLISHED', 'napumpati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8fdec21b-be10-50d7-9025-a16013b1dd86', 'type_answer', 'Напишіть хорватською: «педаль»', 'pedala', null, 'A1', 9, 'PUBLISHED', 'pedala', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3ad7e25c-9777-5802-8ff7-8e9939441d1f', 'sentence_builder', 'Складіть: «Я катаюся з другом.»', 'Vozim se s prijateljem.', '["se", "prijateljem.", "Vozim", "s"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd57b06e-e645-5dde-9336-6fee82916870', 'sentence_builder', 'Складіть: «Колесо проколоте.»', 'Kotač je probušen.', '["Kotač", "probušen.", "je"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '55ce5039-231c-547c-94e6-16e7beee1a6c', 'listening', 'Прослухайте і складіть фразу', 'Petnaest eura, s kacigom i lokotom.', '["i", "kacigom", "Petnaest", "eura,", "lokotom.", "s"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '97076c84-542e-595a-adc9-9c908661c95f', 'listening', 'Прослухайте і складіть фразу', 'Mogu li voziti po pločniku?', '["pločniku?", "po", "voziti", "li", "Mogu"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '761fad25-20c0-5d49-ad81-81d101ef8bf5', 'speaking', 'Візьми шолом і замок.', 'Uzmi kacigu i lokot.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d2099b8-efe5-5607-b558-6ca0837fe787', 'speaking', 'Їдь обережно!', 'Vozi pažljivo!', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('279abd52-3497-5397-972f-8ddbe7169a39', v_lesson, 'Прокат велосипедів', 'Iznajmljivanje bicikala', 3361, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('2b941614-b3e9-59a2-b2a1-fedcb0bdde8f', '279abd52-3497-5397-972f-8ddbe7169a39', 'Daša', 'Dobar dan, koliko košta iznajmljivanje bicikla na dan?', 'Добрий день, скільки коштує прокат велосипеда на день?', 1);
  perform pg_temp.turn('21cb4b55-ec25-55f4-ab63-a9b24e3d8e3e', '279abd52-3497-5397-972f-8ddbe7169a39', 'Radnik', 'Petnaest eura, s kacigom i lokotom.', 'П’ятнадцять євро, із шоломом і замком.', 2);
  perform pg_temp.turn('27d459bc-2df3-59d9-bc94-e3d6971cdee6', '279abd52-3497-5397-972f-8ddbe7169a39', 'Daša', 'Imate li i električni bicikl?', 'У вас є й електровелосипед?', 3);
  perform pg_temp.turn('4d7a3a2d-00bb-594f-951e-df41e5ff128d', '279abd52-3497-5397-972f-8ddbe7169a39', 'Radnik', 'Imamo, ali je skuplji, dvadeset pet eura.', 'Є, але він дорожчий — двадцять п’ять євро.', 4);
  perform pg_temp.turn('44780bac-2471-536a-9052-faf53312cac9', '279abd52-3497-5397-972f-8ddbe7169a39', 'Daša', 'Dobro, uzimam obični. Rade li kočnice?', 'Добре, беру звичайний. Гальма працюють?', 5);
  perform pg_temp.turn('7b19c9d6-51fd-540a-939f-f45c527b9038', '279abd52-3497-5397-972f-8ddbe7169a39', 'Radnik', 'Rade. Provjerite i zvonce prije vožnje.', 'Працюють. Перевірте й дзвоник перед поїздкою.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('339d190d-237c-59c5-a5a7-29d4ddb36abf', v_lesson, 'Проколоте колесо', 'Probušena guma', 3362, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('4697b5c9-e282-544d-9313-4b2e8a2c58ec', '339d190d-237c-59c5-a5a7-29d4ddb36abf', 'Filip', 'Tata, stražnji kotač je probušen!', 'Тату, заднє колесо проколоте!', 1);
  perform pg_temp.turn('4130507d-c03c-5216-af83-8690dd5296c9', '339d190d-237c-59c5-a5a7-29d4ddb36abf', 'Marko', 'Pokaži. Trebamo ga napumpati, imam pumpu.', 'Покажи. Треба його накачати, у мене є насос.', 2);
  perform pg_temp.turn('caf00309-22a3-53ea-9161-acbe7d446ff7', '339d190d-237c-59c5-a5a7-29d4ddb36abf', 'Filip', 'I lanac mi stalno spada.', 'І ланцюг у мене весь час злітає.', 3);
  perform pg_temp.turn('d816f672-38cc-56b3-a32b-8f70f15a2103', '339d190d-237c-59c5-a5a7-29d4ddb36abf', 'Marko', 'To popravljamo kod kuće. Sad vozi polako.', 'Це полагодимо вдома. Зараз їдь повільно.', 4);
  perform pg_temp.turn('211bc369-a5fb-5931-9060-8752479456c3', '339d190d-237c-59c5-a5a7-29d4ddb36abf', 'Filip', 'Mogu li voziti po pločniku?', 'Можна їхати по тротуару?', 5);
  perform pg_temp.turn('f41dbcee-e990-5d51-aec0-fba49b9398ff', '339d190d-237c-59c5-a5a7-29d4ddb36abf', 'Marko', 'Ne, ovdje je biciklistička staza. Pazi na pješake!', 'Ні, тут велодоріжка. Зважай на пішоходів!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 37: Заправка й паркування — перебудова: 18 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'd6ca64d8-4c71-5936-a930-51e400f5681d';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Заправка й паркування» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '71a147e3-3030-53f8-b537-03e7ef441e5a') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 37: Заправка й паркування', title_hr = 'Lekcija 37: Pumpa i parkiranje',
         objectives = '["Заправити авто й перевірити тиск у шинах", "Запитати, де й скільки можна паркуватися", "Модальні дієслова: smijem li…? moram…? mogu li…?"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Модальні дієслова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Модальні дієслова»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'pumpa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'natočiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gorivo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bezolovni benzin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dizel', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rezervoar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'guma', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tlak u gumama', v_pos);
  v_pos := pg_temp.word(v_lesson, 'provjeriti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'parkirno mjesto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'garažno mjesto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zona', v_pos);
  v_pos := pg_temp.word(v_lesson, 'automat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'parkirna karta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naplata parkiranja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kazna za parkiranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pauk', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odvući', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '943fbd1f-77f5-5bd4-baf3-5cbdde0e06ff', 'fill_in_the_blank', 'Moram ___ gorivo.', 'natočiti', '["natočiti", "natoči", "natočen", "natočim"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c4836d86-b16c-5e76-8faf-afce6e5866f4', 'multiple_choice', 'Що означає «bezolovni benzin»?', 'неетилований бензин', '["оплата паркування", "паливо", "неетилований бензин", "заправити (бак); налити"]'::jsonb, 'A1', 2, 'PUBLISHED', 'bezolovni benzin', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c7b77064-8aee-59fd-b39f-503b0f4a0c8a', 'multiple_choice', 'Що означає «natočiti»?', 'заправити (бак); налити', '["оплата паркування", "автомат (паркомат, автомат з продажу)", "заправити (бак); налити", "відбуксирувати, евакуювати (авто)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'natočiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '953c7377-2a5a-503a-acfc-91b58658f100', 'multiple_choice', 'Що означає «tlak u gumama»?', 'тиск у шинах', '["тиск у шинах", "бак (паливний)", "перевірити", "паркувальний талон"]'::jsonb, 'A1', 4, 'PUBLISHED', 'tlak u gumama', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1fafce9b-fad7-5496-8de2-358ffb4360ad', 'multiple_choice', 'Як хорватською «автомат (паркомат, автомат з продажу)»?', 'automat', '["gorivo", "automat", "provjeriti", "parkirno mjesto"]'::jsonb, 'A1', 5, 'PUBLISHED', 'automat', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '389e3d8a-864a-59b4-b0d1-0f91fe1ebb64', 'multiple_choice', 'Як хорватською «паливо»?', 'gorivo', '["dizel", "gorivo", "pumpa", "zona"]'::jsonb, 'A1', 6, 'PUBLISHED', 'gorivo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ffe34e9c-b412-51de-9ff8-a30acfd37292', 'type_answer', 'Напишіть хорватською: «заправка (АЗС); насос»', 'pumpa', null, 'A1', 7, 'PUBLISHED', 'pumpa', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a13e5dcf-6840-5855-93b3-2d555d027cdd', 'type_answer', 'Напишіть хорватською: «шина»', 'guma', null, 'A1', 8, 'PUBLISHED', 'guma', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd7a57962-54b7-5125-9912-310aa88b3cbe', 'type_answer', 'Напишіть хорватською: «дизель»', 'dizel', null, 'A1', 9, 'PUBLISHED', 'dizel', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '05cdbe01-8275-5ac3-82c6-468812eb1c03', 'sentence_builder', 'Складіть: «Чи можна тут паркуватися?»', 'Smijem li parkirati ovdje?', '["parkirati", "ovdje?", "li", "Smijem"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9aff333d-f49e-54b8-b5b6-8e086006f626', 'sentence_builder', 'Складіть: «Мені треба заправити бак.»', 'Moram natočiti gorivo.', '["natočiti", "Moram", "gorivo."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cdd03aae-528a-5e8f-b94e-62ebef6cfbbb', 'listening', 'Прослухайте і складіть фразу', 'Bezolovni benzin ili dizel?', '["benzin", "dizel?", "Bezolovni", "ili"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '079282be-780e-592e-aab8-4db81e995b4f', 'listening', 'Прослухайте і складіть фразу', 'A ako zakasnim?', '["A", "zakasnim?", "ako"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '28414bed-16b7-5443-b3d1-24e052dbfa72', 'speaking', 'Повний бак, будь ласка.', 'Pun rezervoar, molim.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '03cdb5cf-0223-524f-8982-97e1d882a160', 'speaking', 'Де паркомат?', 'Gdje je automat za parkiranje?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('71a147e3-3030-53f8-b537-03e7ef441e5a', v_lesson, 'На заправці', 'Na pumpi', 3371, 'A1', 'car_service', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('39fcc4a7-8a13-591a-b65e-995aec896eb8', '71a147e3-3030-53f8-b537-03e7ef441e5a', 'Daša', 'Dobar dan, natočite mi pun rezervoar, molim.', 'Добрий день, заправте мені повний бак, будь ласка.', 1);
  perform pg_temp.turn('424efeab-2a36-5933-a65d-cce34a1ccf65', '71a147e3-3030-53f8-b537-03e7ef441e5a', 'Radnik', 'Bezolovni benzin ili dizel?', 'Бензин чи дизель?', 2);
  perform pg_temp.turn('d78ba9f4-512a-55eb-ae67-9cb03cd21517', '71a147e3-3030-53f8-b537-03e7ef441e5a', 'Daša', 'Bezolovni. Možete li provjeriti i tlak u gumama?', 'Бензин. Можете перевірити ще й тиск у шинах?', 3);
  perform pg_temp.turn('376a3518-3c0e-58e7-a3a2-6e1560b7e980', '71a147e3-3030-53f8-b537-03e7ef441e5a', 'Radnik', 'Mogu. Prednja lijeva guma je malo mekana.', 'Можу. Передня ліва шина трохи спущена.', 4);
  perform pg_temp.turn('80b2a979-15a7-54c8-b61d-2ebe1b6e25a9', '71a147e3-3030-53f8-b537-03e7ef441e5a', 'Daša', 'Gdje mogu platiti gorivo?', 'Де можна заплатити за пальне?', 5);
  perform pg_temp.turn('d9060fd7-e525-56c4-9100-59b83161e540', '71a147e3-3030-53f8-b537-03e7ef441e5a', 'Radnik', 'Unutra na blagajni, karticom ili gotovinom.', 'Усередині на касі, карткою чи готівкою.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('84799d5d-a812-5dbb-9974-b907885a5e73', v_lesson, 'Паркування в центрі', 'Parkiranje u centru', 3372, 'A1', 'car_service', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('9b822edf-453b-5b7e-955a-f8b3fc87ca58', '84799d5d-a812-5dbb-9974-b907885a5e73', 'Luka', 'Oprostite, smijem li parkirati ovdje?', 'Перепрошую, тут можна паркуватися?', 1);
  perform pg_temp.turn('6c6934fe-5c8c-5e14-a751-a75ac83558f1', '84799d5d-a812-5dbb-9974-b907885a5e73', 'Redar', 'Smijete, ali ovo je prva zona, najviše dva sata.', 'Можна, але це перша зона, щонайбільше дві години.', 2);
  perform pg_temp.turn('dd8ab942-7552-5eb0-abff-21f26f1a8e36', '84799d5d-a812-5dbb-9974-b907885a5e73', 'Luka', 'Kako se plaća parkiranje?', 'Як оплачується паркування?', 3);
  perform pg_temp.turn('b8724623-97b2-5e97-8344-fa3e9766ebc7', '84799d5d-a812-5dbb-9974-b907885a5e73', 'Redar', 'Na automatu ili SMS-om. Parkirnu kartu stavite iza stakla.', 'У паркоматі або через SMS. Талон покладіть за скло.', 4);
  perform pg_temp.turn('46520cda-9a7c-51c1-9906-3233aa818195', '84799d5d-a812-5dbb-9974-b907885a5e73', 'Luka', 'A ako zakasnim?', 'А якщо я запізнюся?', 5);
  perform pg_temp.turn('55144b7a-75e0-5601-974a-ddd259feada1', '84799d5d-a812-5dbb-9974-b907885a5e73', 'Redar', 'Onda dobijete kaznu za parkiranje.', 'Тоді отримаєте штраф за паркування.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 38: На автомагістралі — перебудова: 17 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '06f927cf-f38c-51b5-a1f9-696698ad23fb';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «На автомагістралі» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '5aa129ff-30ce-54f6-9521-6436b5d3cde6') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 38: На автомагістралі', title_hr = 'Lekcija 38: Na autocesti',
         objectives = '["Розуміти дорожні знаки й повідомлення про затори", "Запитати дорогу: з’їзд, кільце, поворот", "Родовий: do izlaza, od Zagreba do Splita"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Родовий відмінок: основи' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Родовий відмінок: основи»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'naplatna kućica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izlaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skretanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kružni tok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obilaznica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'traka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaustavna traka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ograničenje brzine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brzina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prometni znak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pretjecati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radovi na cesti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolona', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zastoj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prometna nesreća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sudar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odmorište', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'effac390-d3b6-540b-8565-1f750898ba11', 'fill_in_the_blank', 'Koliko je još do ___?', 'izlaza', '["izlazu", "izlaz", "izlaza", "izlazom"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9f90f41d-469d-5c9e-9adc-1ad2949b74af', 'multiple_choice', 'Що означає «skretanje»?', 'поворот; з’їзд', '["поворот; з’їзд", "смуга (руху); стрічка", "обмеження швидкості", "дорожні роботи"]'::jsonb, 'A1', 2, 'PUBLISHED', 'skretanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd89ac7af-f656-5145-9884-15beac5baf7e', 'multiple_choice', 'Що означає «traka»?', 'смуга (руху); стрічка', '["поворот; з’їзд", "смуга (руху); стрічка", "швидкість", "затримка, зупинка; перешкода (блокер у роботі)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'traka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5eaa8217-6f3e-5f01-b8fc-cc09b7ee505c', 'multiple_choice', 'Що означає «sudar»?', 'зіткнення (ДТП)', '["обганяти", "зона відпочинку (на трасі)", "швидкість", "зіткнення (ДТП)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'sudar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3dbe4f3d-105a-5f5c-9d92-ace906f62c8d', 'multiple_choice', 'Що означає «kolona»?', 'колона (машин); затор', '["колона (машин); затор", "дорожні роботи", "ДТП; аварія", "поворот; з’їзд"]'::jsonb, 'A1', 5, 'PUBLISHED', 'kolona', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0bf5c6de-9f64-5f48-9766-160245d34bf3', 'multiple_choice', 'Як хорватською «швидкість»?', 'brzina', '["ograničenje brzine", "brzina", "obilaznica", "pretjecati"]'::jsonb, 'A1', 6, 'PUBLISHED', 'brzina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd224086f-6fbb-5792-9fbc-eedf4039acc1', 'multiple_choice', 'Як хорватською «дорожній знак»?', 'prometni znak', '["prometni znak", "obilaznica", "ograničenje brzine", "brzina"]'::jsonb, 'A1', 7, 'PUBLISHED', 'prometni znak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6f0dfdbf-6ab3-5775-bc54-d194f13a19e4', 'type_answer', 'Напишіть хорватською: «обганяти»', 'pretjecati', null, 'A1', 8, 'PUBLISHED', 'pretjecati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a6a44757-7d39-5476-9a85-d922504122f0', 'type_answer', 'Напишіть хорватською: «кільцева розв''язка»', 'kružni tok', null, 'A1', 9, 'PUBLISHED', 'kružni tok', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '166b89b5-1ffd-580f-b2ee-49723ec2d2ac', 'sentence_builder', 'Складіть: «Не обганяй тут.»', 'Nemoj pretjecati ovdje.', '["Nemoj", "ovdje.", "pretjecati"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1b3df1fc-b54b-54c4-9049-93602266e5c0', 'sentence_builder', 'Складіть: «Від Загреба до Спліта.»', 'Od Zagreba do Splita.', '["Zagreba", "do", "Od", "Splita."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '92ce226b-e8a9-5680-ba2c-ca685dfab16c', 'listening', 'Прослухайте і складіть фразу', 'Vidim znak, ograničenje je osamdeset.', '["ograničenje", "osamdeset.", "znak,", "je", "Vidim"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7bbab582-94b7-5251-8ce0-b3dbf19c86a3', 'listening', 'Прослухайте і складіть фразу', 'Je li to daleko od centra?', '["Je", "li", "to", "centra?", "od", "daleko"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be8a6046-226a-5d45-aebd-247047811556', 'speaking', 'Де найближча зона відпочинку?', 'Gdje je najbliže odmorište?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f4d5160f-c3a3-5156-9ffc-3f72c2bebb5b', 'speaking', 'На дорозі затор.', 'Na cesti je kolona.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5aa129ff-30ce-54f6-9521-6436b5d3cde6', v_lesson, 'Магістраллю на море', 'Autocestom na more', 3381, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('28f1449c-8719-5353-992d-4799058fff5f', '5aa129ff-30ce-54f6-9521-6436b5d3cde6', 'Luka', 'Dašo, koliko je još do izlaza za Zadar?', 'Дашо, скільки ще до з’їзду на Задар?', 1);
  perform pg_temp.turn('fd10c3b9-f918-519a-9ef4-14df55fce4b4', '5aa129ff-30ce-54f6-9521-6436b5d3cde6', 'Daša', 'Oko pedeset kilometara. Pazi, ovdje su radovi na cesti.', 'Близько п’ятдесяти кілометрів. Обережно, тут дорожні роботи.', 2);
  perform pg_temp.turn('51ac4c00-2883-594d-b632-0004f1224b29', '5aa129ff-30ce-54f6-9521-6436b5d3cde6', 'Luka', 'Vidim znak, ograničenje je osamdeset.', 'Бачу знак, обмеження — вісімдесят.', 3);
  perform pg_temp.turn('d81c5e3c-4db4-5145-90e8-4a2b69aba240', '5aa129ff-30ce-54f6-9521-6436b5d3cde6', 'Daša', 'Na radiju kažu da je sudar u lijevoj traci.', 'По радіо кажуть, що в лівій смузі зіткнення.', 4);
  perform pg_temp.turn('7cfe2240-9ef9-504b-8322-3b2b4f353a0f', '5aa129ff-30ce-54f6-9521-6436b5d3cde6', 'Luka', 'Onda stajemo na prvom odmorištu.', 'Тоді зупинимося на першій зоні відпочинку.', 5);
  perform pg_temp.turn('371b9df2-764a-5775-8cbe-fa89461b06a3', '5aa129ff-30ce-54f6-9521-6436b5d3cde6', 'Daša', 'Dobro, ionako trebam kavu.', 'Добре, мені однаково треба кави.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e2beb7b5-b6a8-50af-a461-df5c336637d5', v_lesson, 'Як доїхати до готелю?', 'Kako doći do hotela?', 3382, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('bfe6565a-a711-5367-80de-f14d85bcda14', 'e2beb7b5-b6a8-50af-a461-df5c336637d5', 'Marko', 'Oprostite, kako doći do hotela Park?', 'Перепрошую, як доїхати до готелю «Парк»?', 1);
  perform pg_temp.turn('85e33e74-a90d-5eb8-9639-4d9673a42fa4', 'e2beb7b5-b6a8-50af-a461-df5c336637d5', 'Prolaznik', 'Nakon naplatne kućice idite obilaznicom.', 'Після пункту оплати їдьте об’їзною.', 2);
  perform pg_temp.turn('afd3df8d-6b9d-5342-9fec-2360bddbb6cc', 'e2beb7b5-b6a8-50af-a461-df5c336637d5', 'Marko', 'A onda?', 'А потім?', 3);
  perform pg_temp.turn('cbb694b2-2589-510f-beac-9b8a39c07e6d', 'e2beb7b5-b6a8-50af-a461-df5c336637d5', 'Prolaznik', 'Na kružnom toku drugi izlaz, pa prvo skretanje desno.', 'На кільці другий з’їзд, потім перший поворот праворуч.', 4);
  perform pg_temp.turn('93ea0891-5b3e-5eb5-89ac-fba0d37307dd', 'e2beb7b5-b6a8-50af-a461-df5c336637d5', 'Marko', 'Je li to daleko od centra?', 'Це далеко від центру?', 5);
  perform pg_temp.turn('b8f266c2-0cbc-5c7f-b3a9-79c8db119ecb', 'e2beb7b5-b6a8-50af-a461-df5c336637d5', 'Prolaznik', 'Nije, pet minuta od centra.', 'Ні, п’ять хвилин від центру.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 39: В автосервісі — перебудова: 19 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'cd5db261-a421-511d-8100-f86bf2335bbe';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «В автосервісі» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'b2a5051e-ec52-56b4-9bcb-a6a48dd65472') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 39: В автосервісі', title_hr = 'Lekcija 39: U autoservisu',
         objectives = '["Описати несправність авто: дивний звук, індикатор", "Домовитися про ремонт і техогляд", "Знахідний: trebam novi akumulator, promijenite žarulju"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Знахідний відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Знахідний відмінок»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'servis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mehaničar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'motor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'akumulator', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kvačilo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjenjač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'filter', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žarulja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brisač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zimske gume', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispuh', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lampica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rezervni dio', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mijenjati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'popravak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tehnički pregled', v_pos);
  v_pos := pg_temp.word(v_lesson, 'registracija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvuk', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gotov', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '40e1f701-3a5a-5f35-b402-ae752b092f01', 'fill_in_the_blank', 'Trebam promijeniti ___.', 'žarulju', '["žarulju", "žarulji", "žarulja", "žaruljom"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2625ea1d-f385-5fad-ae74-ffe7ff3519ff', 'multiple_choice', 'Що означає «registracija»?', 'реєстрація (авто)', '["лампочка", "сервіс; майстерня", "запчастина", "реєстрація (авто)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'registracija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '511aaa93-68df-50d7-8d19-fa3f7931bed0', 'multiple_choice', 'Що означає «popravak»?', 'ремонт', '["техогляд", "акумулятор", "фільтр", "ремонт"]'::jsonb, 'A1', 3, 'PUBLISHED', 'popravak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'da8b1e4c-0eda-54ca-a0ae-1f32c2681487', 'multiple_choice', 'Що означає «lampica»?', 'індикатор (на приладовій панелі)', '["реєстрація (авто)", "індикатор (на приладовій панелі)", "механік", "зчеплення"]'::jsonb, 'A1', 4, 'PUBLISHED', 'lampica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd6de5e1a-76e4-5dcc-8f08-bed0f1d69ef0', 'multiple_choice', 'Як хорватською «міняти; змінювати»?', 'mijenjati', '["mjenjač", "mijenjati", "ispuh", "lampica"]'::jsonb, 'A1', 5, 'PUBLISHED', 'mijenjati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '134d2722-554b-55b4-ae01-a79343a29154', 'multiple_choice', 'Як хорватською «фільтр»?', 'filter', '["popravak", "motor", "mijenjati", "filter"]'::jsonb, 'A1', 6, 'PUBLISHED', 'filter', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '141e5ab3-4a11-54e5-84f0-02d4cea67041', 'type_answer', 'Напишіть хорватською: «акумулятор»', 'akumulator', null, 'A1', 7, 'PUBLISHED', 'akumulator', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e92f9252-e3e6-5099-a84c-85e0aaf902c9', 'type_answer', 'Напишіть хорватською: «лампочка»', 'žarulja', null, 'A1', 8, 'PUBLISHED', 'žarulja', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '16ba2bf8-a88f-5fbe-88b6-c3f54cc37b98', 'type_answer', 'Напишіть хорватською: «зчеплення»', 'kvačilo', null, 'A1', 9, 'PUBLISHED', 'kvačilo', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7943f04a-aa94-57f7-b144-ca98042f0374', 'sentence_builder', 'Складіть: «Мені потрібен новий акумулятор.»', 'Trebam novi akumulator.', '["Trebam", "akumulator.", "novi"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2ec2dbc0-56a2-54e7-9eae-d1fa74180972', 'sentence_builder', 'Складіть: «Поставте зимові шини.»', 'Stavite zimske gume.', '["gume.", "zimske", "Stavite"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '97af8f76-432c-5703-9ed2-3f3d98ce8fcb', 'listening', 'Прослухайте і складіть фразу', 'Možda je kvačilo. Moram pogledati auto.', '["je", "Moram", "auto.", "Možda", "kvačilo.", "pogledati"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bcdf7f62-0532-5c3d-94a7-35a1691e83da', 'listening', 'Прослухайте і складіть фразу', 'A ispuh? Malo je glasan.', '["je", "A", "glasan.", "ispuh?", "Malo"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '46674a13-2fc6-575d-835b-7b1deee3b5ce', 'speaking', 'Двигун дивно звучить.', 'Motor ima čudan zvuk.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a1856eb-3093-5cf9-817f-3377904248b5', 'speaking', 'Коли машина буде готова?', 'Kada će auto biti gotov?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b2a5051e-ec52-56b4-9bcb-a6a48dd65472', v_lesson, 'Дивний звук', 'Čudan zvuk', 3391, 'A1', 'car_service', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('fab1f111-0251-5c4c-87d1-e06b9217224a', 'b2a5051e-ec52-56b4-9bcb-a6a48dd65472', 'Daša', 'Dobar dan, motor ima neki čudan zvuk.', 'Добрий день, двигун якось дивно звучить.', 1);
  perform pg_temp.turn('18b57190-57bb-54d1-8567-feb4b50b71e7', 'b2a5051e-ec52-56b4-9bcb-a6a48dd65472', 'Mehaničar', 'Kada se čuje, kad krenete ili u vožnji?', 'Коли це чути — коли рушаєте чи під час руху?', 2);
  perform pg_temp.turn('06c735ae-dffd-5ef5-b3f0-704f61d04a14', 'b2a5051e-ec52-56b4-9bcb-a6a48dd65472', 'Daša', 'Kad mijenjam brzinu. I svijetli lampica akumulatora.', 'Коли перемикаю передачу. І світиться індикатор акумулятора.', 3);
  perform pg_temp.turn('af443089-b2f5-5757-9ae4-a9fb1585b119', 'b2a5051e-ec52-56b4-9bcb-a6a48dd65472', 'Mehaničar', 'Možda je kvačilo. Moram pogledati auto.', 'Можливо, зчеплення. Мені треба подивитися машину.', 4);
  perform pg_temp.turn('2b7e90fc-76ee-52f9-a35f-953ac1d436dd', 'b2a5051e-ec52-56b4-9bcb-a6a48dd65472', 'Daša', 'Kada će auto biti gotov?', 'Коли машина буде готова?', 5);
  perform pg_temp.turn('8ccb71fe-6ebe-501f-bf0d-5338438f2d7a', 'b2a5051e-ec52-56b4-9bcb-a6a48dd65472', 'Mehaničar', 'Sutra popodne, ako stigne rezervni dio.', 'Завтра по обіді, якщо надійде запчастина.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('fba9c521-7f35-5a74-a031-1ba5e076b0a7', v_lesson, 'Перед техоглядом', 'Prije tehničkog pregleda', 3392, 'A1', 'car_service', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('39946647-18cc-5fbc-aedb-38b407bf5890', 'fba9c521-7f35-5a74-a031-1ba5e076b0a7', 'Marko', 'Za tjedan dana imam tehnički pregled i registraciju.', 'За тиждень у мене техогляд і реєстрація.', 1);
  perform pg_temp.turn('b0e3fa51-b986-5585-b324-cd672cbea756', 'fba9c521-7f35-5a74-a031-1ba5e076b0a7', 'Mehaničar', 'Onda treba promijeniti žarulju i brisače.', 'Тоді треба замінити лампочку й двірники.', 2);
  perform pg_temp.turn('4cc7ebd2-c17a-54a1-9348-ce5cbc9837cc', 'fba9c521-7f35-5a74-a031-1ba5e076b0a7', 'Marko', 'A ispuh? Malo je glasan.', 'А вихлоп? Він трохи гучний.', 3);
  perform pg_temp.turn('021b92d1-6cd1-5a0b-a978-fa6a603d2cdc', 'fba9c521-7f35-5a74-a031-1ba5e076b0a7', 'Mehaničar', 'Ispuh je u redu, ali filter treba mijenjati.', 'З вихлопом усе гаразд, а от фільтр треба міняти.', 4);
  perform pg_temp.turn('df760c49-a396-57b8-a47a-60f0b342de34', 'fba9c521-7f35-5a74-a031-1ba5e076b0a7', 'Marko', 'I stavite mi zimske gume, molim.', 'І поставте мені зимові шини, будь ласка.', 5);
  perform pg_temp.turn('ab4587c3-e14b-56f7-9f5a-7dde9c69fea6', 'fba9c521-7f35-5a74-a031-1ba5e076b0a7', 'Mehaničar', 'Može. Sve je gotovo do petka.', 'Добре. До п’ятниці все буде готово.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- 3. Нові уроки модуля A1.4
-- A1.4 · урок 30: Куди йдемо? Kamo чи gdje? — новий урок: 13 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := '72a3eec1-fb04-5e99-a0ea-da4f6bc07ed5';
  v_lesson constant uuid := '12012395-7359-503b-89c9-ee1807f89d6b';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.4: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 30: Куди йдемо? Kamo чи gdje?', 'Lekcija 30: Kamo idemo? Kamo ili gdje?', '["Розрізняти «куди?» і «де?»: idem u grad — u gradu sam", "Запитати й пояснити, куди йти: naprijed, natrag, prema", "Kamo + знахідний, gdje + місцевий, odakle + родовий"]'::jsonb, 15, 'PUBLISHED', 1);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Kamo? і Gdje?: u grad — u gradu' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Kamo? і Gdje?: u grad — u gradu»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kamo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kuda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovamo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'van', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naprijed', v_pos);
  v_pos := pg_temp.word(v_lesson, 'natrag', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prema', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otići', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svratiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odvesti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odnijeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ulaziti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izlaziti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '50cb0018-31f5-5a71-8762-d6f3d7bf7b4b', 'fill_in_the_blank', 'Idem ___ grad.', 'u', '["kod", "na", "iz", "u"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '97a1ae42-44ea-5888-8b5e-bc72c4ee7d27', 'multiple_choice', 'Що означає «otići»?', 'піти, поїхати', '["віднести", "піти, поїхати", "входити, заходити", "вперед"]'::jsonb, 'A1', 2, 'PUBLISHED', 'otići', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ba6bf950-c80d-527b-b76d-fcd7dc00ec64', 'multiple_choice', 'Що означає «natrag»?', 'назад', '["назад", "піти, поїхати", "куди, якою дорогою", "відвезти; відвести"]'::jsonb, 'A1', 3, 'PUBLISHED', 'natrag', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '73e086cd-be0a-58a5-bc06-e56c606f243b', 'multiple_choice', 'Що означає «kuda»?', 'куди, якою дорогою', '["відвезти; відвести", "у напрямку до", "вперед", "куди, якою дорогою"]'::jsonb, 'A1', 4, 'PUBLISHED', 'kuda', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '113f413d-9af7-58df-a6d0-8359fb4da299', 'multiple_choice', 'Як хорватською «сюди»?', 'ovamo', '["svratiti", "ovamo", "van", "natrag"]'::jsonb, 'A1', 5, 'PUBLISHED', 'ovamo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '84a00638-cedc-5be3-b197-6261b62804fb', 'multiple_choice', 'Як хорватською «віднести»?', 'odnijeti', '["izlaziti", "van", "odnijeti", "natrag"]'::jsonb, 'A1', 6, 'PUBLISHED', 'odnijeti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f8365485-e64d-5079-999c-36c646034da0', 'type_answer', 'Напишіть хорватською: «входити, заходити»', 'ulaziti', null, 'A1', 7, 'PUBLISHED', 'ulaziti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '15248525-588a-5254-a3ca-7204d5979847', 'type_answer', 'Напишіть хорватською: «відвезти; відвести»', 'odvesti', null, 'A1', 8, 'PUBLISHED', 'odvesti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ac144be0-f796-5b81-be86-d53b45e5516c', 'type_answer', 'Напишіть хорватською: «заскочити, зайти ненадовго»', 'svratiti', null, 'A1', 9, 'PUBLISHED', 'svratiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6cebcf4b-f393-569c-85e8-097d1dc51d48', 'sentence_builder', 'Складіть: «Куди ти йдеш увечері?»', 'Kamo ideš navečer?', '["navečer?", "ideš", "Kamo"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5484cc92-8a7d-5ac4-a577-81b438790e60', 'sentence_builder', 'Складіть: «Я йду на роботу.»', 'Idem na posao.', '["posao.", "Idem", "na"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '57f6d817-0d20-5532-be8a-5cf9384d69d4', 'listening', 'Прослухайте і складіть фразу', 'Idem u grad, na tržnicu. A ti?', '["na", "grad,", "ti?", "Idem", "u", "tržnicu.", "A"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '03b5cea3-3ace-5452-9e54-6cc0e5588a81', 'listening', 'Прослухайте і складіть фразу', 'Idite naprijed, pa prema crkvi.', '["pa", "crkvi.", "Idite", "naprijed,", "prema"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1324f9c3-6265-5bdb-aa4d-635d5323215c', 'speaking', 'Я йду в місто.', 'Idem u grad.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fb2a2b3e-876c-5a32-9789-8cb0867b8858', 'speaking', 'Ти вже на роботі?', 'Jesi li već na poslu?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('aaec3075-ac4a-50df-9112-4853bf029ff6', v_lesson, 'Куди ти йдеш?', 'Kamo ideš?', 3301, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('952a133b-5ab0-5897-b72d-370e6136d976', 'aaec3075-ac4a-50df-9112-4853bf029ff6', 'Luka', 'Dašo, kamo ideš tako rano?', 'Дашо, куди ти так рано?', 1);
  perform pg_temp.turn('bf39da8f-58ea-53ef-bf29-3369ba2cf57a', 'aaec3075-ac4a-50df-9112-4853bf029ff6', 'Daša', 'Idem u grad, na tržnicu. A ti?', 'Іду в місто, на ринок. А ти?', 2);
  perform pg_temp.turn('6ea7ea30-ace6-5124-b12c-b65a2a34a4c7', 'aaec3075-ac4a-50df-9112-4853bf029ff6', 'Luka', 'Ja sam danas na poslu do pet.', 'А я сьогодні на роботі до п’ятої.', 3);
  perform pg_temp.turn('c0723554-7faf-5bd3-8743-a1083533e1d3', 'aaec3075-ac4a-50df-9112-4853bf029ff6', 'Daša', 'Gdje je tvoj ured, u centru?', 'Де твій офіс, у центрі?', 4);
  perform pg_temp.turn('4a49ac43-d300-5705-af98-d0146e9d3fd3', 'aaec3075-ac4a-50df-9112-4853bf029ff6', 'Luka', 'Da, u centru. Mogu te odvesti autom.', 'Так, у центрі. Можу підвезти тебе машиною.', 5);
  perform pg_temp.turn('2e28d624-c6ab-59b2-a688-3874b584f0e8', 'aaec3075-ac4a-50df-9112-4853bf029ff6', 'Daša', 'Super! Usput mogu svratiti u pekaru.', 'Чудово! Дорогою можу заскочити в пекарню.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0278f7e6-0214-5eb1-b851-7a0586303975', v_lesson, 'Як пройти на пляж?', 'Kuda do plaže?', 3302, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('c2a2cc46-0ed0-51de-a17f-22e7f2520030', '0278f7e6-0214-5eb1-b851-7a0586303975', 'Darja', 'Oprostite, kuda se ide na plažu?', 'Перепрошую, як пройти на пляж?', 1);
  perform pg_temp.turn('6f6c4d0c-a967-5d41-8bcf-f68ed9b49aac', '0278f7e6-0214-5eb1-b851-7a0586303975', 'Prolaznik', 'Idite naprijed, pa prema crkvi.', 'Ідіть прямо, а потім у бік церкви.', 2);
  perform pg_temp.turn('041b1e46-ede4-55d7-bc9c-cd1bb287b76f', '0278f7e6-0214-5eb1-b851-7a0586303975', 'Darja', 'Je li plaža daleko odavde?', 'Пляж далеко звідси?', 3);
  perform pg_temp.turn('7ba89e9e-bcc6-5bb8-9721-1e23be363c6a', '0278f7e6-0214-5eb1-b851-7a0586303975', 'Prolaznik', 'Nije, deset minuta pješice.', 'Ні, десять хвилин пішки.', 4);
  perform pg_temp.turn('3260ce46-2701-521d-b6e5-3b26a94e1a35', '0278f7e6-0214-5eb1-b851-7a0586303975', 'Darja', 'A natrag? Isto ovim putem?', 'А назад? Так само цією дорогою?', 5);
  perform pg_temp.turn('9d4da064-0f2f-5c65-b994-519f0f95e6a4', '0278f7e6-0214-5eb1-b851-7a0586303975', 'Prolaznik', 'Da, ili autobusom broj dva, vozi ovamo do trga.', 'Так, або автобусом номер два, він їде сюди до площі.', 6);
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
   where l.id in ('12012395-7359-503b-89c9-ee1807f89d6b', '0ef458c5-53cf-530a-99cf-4ccd6e0132e5', 'cae7a47d-7fb4-5b03-a8cc-5a0df2ccd92f', 'c1b32b15-8f3c-5f75-bba9-e831d544ec7b', '69ec0776-4f69-5f86-afac-6652234a7da5', '458ee6ec-31d1-5758-adef-03612626088a', '0b04119b-4d38-5d99-8237-caa95fdcfd95', 'd6ca64d8-4c71-5936-a930-51e400f5681d', '06f927cf-f38c-51b5-a1f9-696698ad23fb', 'cd5db261-a421-511d-8100-f86bf2335bbe')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 10 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_order from (values ('12012395-7359-503b-89c9-ee1807f89d6b'::uuid, 1), ('0ef458c5-53cf-530a-99cf-4ccd6e0132e5'::uuid, 2), ('cae7a47d-7fb4-5b03-a8cc-5a0df2ccd92f'::uuid, 3), ('c1b32b15-8f3c-5f75-bba9-e831d544ec7b'::uuid, 4), ('69ec0776-4f69-5f86-afac-6652234a7da5'::uuid, 5), ('458ee6ec-31d1-5758-adef-03612626088a'::uuid, 6), ('0b04119b-4d38-5d99-8237-caa95fdcfd95'::uuid, 7), ('d6ca64d8-4c71-5936-a930-51e400f5681d'::uuid, 8), ('06f927cf-f38c-51b5-a1f9-696698ad23fb'::uuid, 9), ('cd5db261-a421-511d-8100-f86bf2335bbe'::uuid, 10)) as t(id, o)
    join public.lessons l on l.id = t.id and l.order_index = t.o and l.unit_id = '72a3eec1-fb04-5e99-a0ea-da4f6bc07ed5';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A1' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('12012395-7359-503b-89c9-ee1807f89d6b', '0ef458c5-53cf-530a-99cf-4ccd6e0132e5', 'cae7a47d-7fb4-5b03-a8cc-5a0df2ccd92f', 'c1b32b15-8f3c-5f75-bba9-e831d544ec7b', '69ec0776-4f69-5f86-afac-6652234a7da5', '458ee6ec-31d1-5758-adef-03612626088a', '0b04119b-4d38-5d99-8237-caa95fdcfd95', 'd6ca64d8-4c71-5936-a930-51e400f5681d', '06f927cf-f38c-51b5-a1f9-696698ad23fb', 'cd5db261-a421-511d-8100-f86bf2335bbe') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A1.4: % уроків з неправильним складом', v_bad; end if;
  if v_order <> 10 then raise exception 'Модуль A1.4: на своїх місцях % уроків з 10', v_order; end if;
  if v_titles > 0 then raise exception 'A1: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A1.4: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A1.4 — 10 уроків за темою (9 перебудовано, 1 нових)';
end $$;

commit;
