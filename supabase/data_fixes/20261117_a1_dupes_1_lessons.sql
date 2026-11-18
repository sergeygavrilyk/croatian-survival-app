-- =====================================================================
-- Дублі A1 · 2026-11-17 (план «Дублі й сенс уроків A0–A2», PR 3)
-- Згенеровано: python3 -B scripts/gen_a1_dupes.py (не редагуйте вручну).
--
-- Рішення власника 2026-11-17: урок 105 «Надзвичайні ситуації» → модуль A1.8 «Здоров’я» (стане 76);
-- Д2 (урок 101), Д3 (54), Д13 (93), Д12 (70); A1.11 «Хорватська культура» — 3 нові уроки; 9 назв діалогів. Уроків A1 108 → 111.
--   * Нові слова: 60 (з мітками); наявні без уроку — 18 і з A2-9 — 3 (рівень → A1);
--     прибрані, які тепер учать лише в A2 (6), — рівень A2; svjedodžba → A2-11, porez і platna lista → A2-34.
--   * Слово в уроці — заміна на тому самому місці; вправи на прибрані слова й діалоги — нові на тому самому місці.
--   * Нічого не видаляється: старі діалоги й вправи → DEPRECATED; копія складу уроків — backup.lesson_items_a1dupes_20261117;
--     старі версії уроків, діалогів і слів — у content_versions. Прогрес користувачів не змінюється.
--   * Далі за назвою: 20261117_a1_dupes_2_tests.sql (перевірки модулів A1.6, A1.8, A1.11, A1.12 і фінал A1).
--   * Повторний запуск нічого не змінює. Бета: PUBLISHED.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: 20261117_a1_dupes_1_lessons.sql — …».
-- =====================================================================

begin;

-- 0. Копія складу уроків до змін (схема backup без доступу для anon / authenticated)
create schema if not exists backup;
create table if not exists backup.lesson_items_a1dupes_20261117 (like public.lesson_items including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'lesson_items_a1dupes_20261117_pkey') then
    alter table backup.lesson_items_a1dupes_20261117 add constraint lesson_items_a1dupes_20261117_pkey primary key (id);
  end if;
end $$;
revoke all on backup.lesson_items_a1dupes_20261117 from anon, authenticated;

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

-- слово уроку: заміна на тому самому місці (рядок lesson_items той самий — змінюється лише слово)
create or replace function pg_temp.swap_word(p_lesson uuid, p_old text, p_new text) returns void language plpgsql as $f$
declare v_new uuid; v_n int;
begin
  select id into v_new from public.lexemes where lower(lemma) = lower(p_new) and status = 'PUBLISHED' order by created_at limit 1;
  if v_new is null then raise exception 'Немає опублікованого слова «%»', p_new; end if;
  update public.lesson_items set item_id = v_new
   where lesson_id = p_lesson and item_type = 'lexeme' and item_id in (select id from public.lexemes where lower(lemma) = lower(p_old));
  get diagnostics v_n = row_count;
  if v_n <> 1 then raise exception 'Слово «%» в уроці: % рядків замість 1 — звірте базу', p_old, v_n; end if;
end $f$;

-- вправа: нова на місці старої (той самий тип і місце); стара — DEPRECATED, якщо більше ніде не використовується
create or replace function pg_temp.swap_ex(p_lesson uuid, p_old uuid, p_new uuid, p_type text, p_question text, p_answer text,
                                           p_options jsonb, p_lemma text) returns void language plpgsql as $f$
declare v_lex uuid; v_n int;
begin
  if p_lemma is not null then
    select id into v_lex from public.lexemes where lower(lemma) = lower(p_lemma) and status = 'PUBLISHED' order by created_at limit 1;
    if v_lex is null then raise exception 'Немає опублікованого слова «%»', p_lemma; end if;
  end if;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  select p_new, p_type, p_question, p_answer, p_options, e.level, e.order_index, 'PUBLISHED', v_lex
    from public.exercises e where e.id = p_old and e.exercise_type = p_type
  on conflict (id) do nothing;
  update public.lesson_items set item_id = p_new where lesson_id = p_lesson and item_type = 'exercise' and item_id = p_old;
  get diagnostics v_n = row_count;
  if v_n <> 1 or not exists (select 1 from public.exercises where id = p_new) then
    raise exception 'Вправу % в уроці не замінено — звірте базу', p_old;
  end if;
  update public.exercises e set status = 'DEPRECATED' where e.id = p_old and e.status = 'PUBLISHED'
     and not exists (select 1 from public.lesson_items x where x.item_type = 'exercise' and x.item_id = e.id);
end $f$;

-- копія складу уроку до змін і стара версія уроку (разом з опублікованими діалогами) — у content_versions
create or replace function pg_temp.snapshot_lesson(p_lesson uuid, p_reason text) returns void language plpgsql as $f$
begin
  insert into backup.lesson_items_a1dupes_20261117 select li.* from public.lesson_items li where li.lesson_id = p_lesson on conflict (id) do nothing;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'lesson', l.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = l.id), 0) + 1,
         jsonb_build_object('lesson', to_jsonb(l),
           'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = l.id),
           'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c
                              where c.lesson_id = l.id and c.status = 'PUBLISHED')), p_reason
    from public.lessons l where l.id = p_lesson;
end $f$;

-- 1. Нові слова (60): PUBLISHED (бета), з мітками; наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples,
                            ukrainian_interference, register, regionality, usage_tags, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A1', t.ua, t.vtype, t.forms, t.examples, t.interference,
       t.register, t.regionality, array(select jsonb_array_elements_text(t.usage_tags)), 'PUBLISHED', 'claude_curriculum_a1_dupes'
  from jsonb_to_recordset('[{"lemma": "potpisati ugovor", "normalized": "potpisati ugovor", "pos": "phrase", "ua": "підписати договір", "vtype": "chunk", "forms": {}, "examples": ["Sutra idem potpisati ugovor u novoj firmi."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "raditi vikendom", "normalized": "raditi vikendom", "pos": "phrase", "ua": "працювати у вихідні", "vtype": "chunk", "forms": {}, "examples": ["U trgovini često moram raditi vikendom."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "opis posla", "normalized": "opis posla", "pos": "phrase", "ua": "опис посадових обов’язків", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["U oglasu piše kratak opis posla."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "uvjeti rada", "normalized": "uvjeti rada", "pos": "phrase", "ua": "умови праці", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Uvjeti rada u ovoj tvrtki su jako dobri."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "prije jela", "normalized": "prije jela", "pos": "phrase", "ua": "перед їжею", "vtype": "chunk", "forms": {}, "examples": ["Sirup uzimajte tri puta dnevno prije jela."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "dvaput dnevno", "normalized": "dvaput dnevno", "pos": "phrase", "ua": "двічі на день", "vtype": "chunk", "forms": {}, "examples": ["Kapi stavljajte dvaput dnevno, ujutro i navečer."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "gotički", "normalized": "goticki", "pos": "adjective", "ua": "готичний", "vtype": "core", "forms": {}, "examples": ["Gotičke crkve imaju visoke tornjeve i velike prozore."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "renesansni", "normalized": "renesansni", "pos": "adjective", "ua": "ренесансний", "vtype": "core", "forms": {}, "examples": ["U starom gradu ima mnogo renesansnih palača."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "simbol", "normalized": "simbol", "pos": "noun", "ua": "символ", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Licitarsko srce je simbol Zagreba."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "šahovnica", "normalized": "sahovnica", "pos": "noun", "ua": "шахівниця (червоно-білий хорватський герб)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Na dresu reprezentacije je crveno-bijela šahovnica."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "grb", "normalized": "grb", "pos": "noun", "ua": "герб", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Na hrvatskom grbu je dvadeset pet polja."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "crveno-bijeli", "normalized": "crveno-bijeli", "pos": "adjective", "ua": "червоно-білий", "vtype": "core", "forms": {}, "examples": ["Navijači su nosili crveno-bijele majice."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "vezati kravatu", "normalized": "vezati kravatu", "pos": "phrase", "ua": "зав’язувати краватку", "vtype": "chunk", "forms": {}, "examples": ["Tata me naučio vezati kravatu."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "Dan kravate", "normalized": "dan kravate", "pos": "phrase", "ua": "День краватки (18 жовтня)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Osamnaestog listopada slavimo Dan kravate."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "marama", "normalized": "marama", "pos": "noun", "ua": "хустка (на шию, на голову)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Oko vrata je nosila svilenu maramu."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "izumiti", "normalized": "izumiti", "pos": "verb", "ua": "винайти", "vtype": "core", "forms": {"aspect": "pfv", "pair": "izumljivati"}, "examples": ["Moj sin želi izumiti robota koji pere suđe."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "patent", "normalized": "patent", "pos": "noun", "ua": "патент", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Izumitelj je prijavio patent za novi stroj."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "tehnička olovka", "normalized": "tehnicka olovka", "pos": "phrase", "ua": "механічний олівець", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za crtanje koristim tehničku olovku."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "nalivpero", "normalized": "nalivpero", "pos": "noun", "ua": "авторучка (перова)", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Ugovor je potpisao starim nalivperom."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "padobran", "normalized": "padobran", "pos": "noun", "ua": "парашут", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Skočio je iz aviona s padobranom."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "dalmatinac", "normalized": "dalmatinac", "pos": "noun", "ua": "далматинець (порода собак)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Naš susjed ima dalmatinca s crnim točkama."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": "з малої — порода собак; Dalmatinac з великої — житель Далмації"}, {"lemma": "svjetski poznat", "normalized": "svjetski poznat", "pos": "phrase", "ua": "всесвітньо відомий", "vtype": "chunk", "forms": {}, "examples": ["Dubrovnik je svjetski poznat grad."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "karneval", "normalized": "karneval", "pos": "noun", "ua": "карнавал", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Riječki karneval je najveći u Hrvatskoj."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "maškare", "normalized": "maskare", "pos": "noun", "ua": "маскарад; ряджені (на карнавалі)", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Djeca jedva čekaju maškare u vrtiću."], "register": "standard", "regionality": "general", "usage_tags": ["italianism"], "interference": null}, {"lemma": "poklade", "normalized": "poklade", "pos": "noun", "ua": "карнавальні дні перед Великим постом (масниця)", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Za vrijeme poklada ljudi se maskiraju i zabavljaju."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "Pepelnica", "normalized": "pepelnica", "pos": "noun", "ua": "Попільна середа (початок Великого посту)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Na Pepelnicu završavaju poklade."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "kostim", "normalized": "kostim", "pos": "noun", "ua": "костюм (карнавальний, сценічний)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Mama mi je sašila kostim za maškare."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": "діловий костюм — odijelo; kostim — карнавальний, сценічний; kupaći kostim — купальник"}, {"lemma": "maskirati se", "normalized": "maskirati se", "pos": "verb", "ua": "перевдягатися (на карнавал), маскуватися", "vtype": "core", "forms": {"aspect": "biasp"}, "examples": ["Na maškare se svi u uredu maskiramo."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "prerušiti se", "normalized": "prerusiti se", "pos": "verb", "ua": "перевдягнутися (в когось)", "vtype": "core", "forms": {"aspect": "pfv", "pair": "prerušavati se"}, "examples": ["Brat se prerušio u policajca."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "gusar", "normalized": "gusar", "pos": "noun", "ua": "пірат", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Sin želi kostim gusara s crnim šeširom."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "povorka", "normalized": "povorka", "pos": "noun", "ua": "хода, процесія", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Karnevalska povorka prolazi glavnom ulicom."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "zvončari", "normalized": "zvoncari", "pos": "noun", "ua": "дзвонарі (ряджені з дзвонами з околиць Рієки)", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Zvončari zimi obilaze sela oko Rijeke."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "ovčja koža", "normalized": "ovcja koza", "pos": "phrase", "ua": "овеча шкура", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Zvončari nose ovčje kože i velika zvona."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "rog", "normalized": "rog", "pos": "noun", "ua": "ріг", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Maska ima dva velika roga."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "tjerati", "normalized": "tjerati", "pos": "verb", "ua": "проганяти, гнати", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "otjerati"}, "examples": ["Kažu da buka zvona tjera zle duhove."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "spaliti", "normalized": "spaliti", "pos": "verb", "ua": "спалити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "spaljivati"}, "examples": ["Na kraju karnevala ljudi spale veliku lutku."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "maskenbal", "normalized": "maskenbal", "pos": "noun", "ua": "бал-маскарад", "vtype": "core", "forms": {"gender": "m"}, "examples": ["U subotu idemo na maskenbal u hotelu."], "register": "standard", "regionality": "general", "usage_tags": ["germanism"], "interference": null}, {"lemma": "konfeti", "normalized": "konfeti", "pos": "noun", "ua": "конфеті", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Djeca bacaju konfete po ulici."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "bubanj", "normalized": "bubanj", "pos": "noun", "ua": "барабан", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Dječak glasno udara u bubanj."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "nastupati", "normalized": "nastupati", "pos": "verb", "ua": "виступати (на сцені)", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "nastupiti"}, "examples": ["Na festivalu nastupaju bendovi iz cijele Europe."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "šaliti se", "normalized": "saliti se", "pos": "verb", "ua": "жартувати", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "našaliti se"}, "examples": ["Ne ljuti se, samo se šalim!"], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "legenda", "normalized": "legenda", "pos": "noun", "ua": "легенда", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Prema legendi, u ovoj špilji živio je zmaj."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "pripovijedati", "normalized": "pripovijedati", "pos": "verb", "ua": "розповідати (історію, казку)", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "ispripovijedati"}, "examples": ["Baka nam je pripovijedala stare priče."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "bilo jednom", "normalized": "bilo jednom", "pos": "phrase", "ua": "колись давно; жили-були (початок казки)", "vtype": "formulaic", "forms": {}, "examples": ["Bilo jednom jedno malo selo pokraj velike šume."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "za laku noć", "normalized": "za laku noc", "pos": "phrase", "ua": "на ніч (казка, поцілунок)", "vtype": "formulaic", "forms": {}, "examples": ["Svaku večer čitam kćeri priču za laku noć."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "kraljević", "normalized": "kraljevic", "pos": "noun", "ua": "королевич, принц", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Kraljević je jahao na bijelom konju."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "kraljevna", "normalized": "kraljevna", "pos": "noun", "ua": "королівна, принцеса", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Kraljevna je živjela u visokom tornju."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "vila", "normalized": "vila", "pos": "noun", "ua": "фея; вілла", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Dobra vila pomogla je siromašnoj djevojci."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": "два значення: «фея» (у казці) і «вілла» (будинок)"}, {"lemma": "zmaj", "normalized": "zmaj", "pos": "noun", "ua": "дракон; повітряний змій", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Zmaj je čuvao zlato u planini."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": "ще й «повітряний змій» (puštati zmaja)"}, {"lemma": "vještica", "normalized": "vjestica", "pos": "noun", "ua": "відьма", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Zla vještica živjela je duboko u šumi."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "div", "normalized": "div", "pos": "noun", "ua": "велетень", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Regoč je div iz priče Ivane Brlić-Mažuranić."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": "не «диво»: div — велетень (čudo — диво)"}, {"lemma": "patuljak", "normalized": "patuljak", "pos": "noun", "ua": "гном, карлик", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Snjeguljica je živjela sa sedam patuljaka."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "čarobni", "normalized": "carobni", "pos": "adjective", "ua": "чарівний, магічний", "vtype": "core", "forms": {}, "examples": ["Starac mu je dao čarobni prsten."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "čarolija", "normalized": "carolija", "pos": "noun", "ua": "чари, заклинання", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Vještica je tiho izgovorila čaroliju."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "začarati", "normalized": "zacarati", "pos": "verb", "ua": "зачарувати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "začaravati"}, "examples": ["Zla vila začarala je cijeli dvorac."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "pretvoriti se", "normalized": "pretvoriti se", "pos": "verb", "ua": "перетворитися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "pretvarati se"}, "examples": ["Žaba se pretvorila u lijepog kraljevića."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": "видова пара pretvarati se має ще значення «прикидатися»"}, {"lemma": "zao", "normalized": "zao", "pos": "adjective", "ua": "злий", "vtype": "core", "forms": {}, "examples": ["U priči je bio jedan zao čarobnjak."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "dobrota", "normalized": "dobrota", "pos": "noun", "ua": "доброта", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Kraljevnu su svi voljeli zbog njezine dobrote."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}, {"lemma": "pouka", "normalized": "pouka", "pos": "noun", "ua": "мораль, повчання (казки)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Pouka ove priče je da treba govoriti istinu."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": "не «наука»: pouka — мораль, повчання казки"}, {"lemma": "sretan kraj", "normalized": "sretan kraj", "pos": "phrase", "ua": "щасливий кінець", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Volim filmove sa sretnim krajem."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb, interference text,
         register text, regionality text, usage_tags jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 1а. Слова без уроку (18) і з A2-9 (3), які тепер учать в уроках A1: рівень — A1; стара версія — у content_versions
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) in ('kravata', 'vojnik', 'izum', 'izumitelj', 'znanstvenik', 'otkriće', 'slavan', 'ponos', 'ples', 'šala', 'smijeh', 'priča', 'junak', 'hrabar', 'zlo', 'rječnik', 'vježba', 'ugovor o radu', 'upisati se', 'test razine', 'početni tečaj') and status = 'PUBLISHED' and cefr is distinct from 'A1' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'a1_dupes: рівень слова A1 — його вперше вчать в уроці A1 — стара версія');
    update public.lexemes set cefr = 'A1', version = version + 1 where id = r.id;
  end loop;
end $$;

-- 1б. Прибрані з уроків A1 слова, які вчать в A2 (6): рівень — A2; стара версія — у content_versions
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) in ('polagati', 'položiti', 'uvjerenje', 'svjedodžba', 'porez', 'platna lista') and status = 'PUBLISHED' and cefr is distinct from 'A2' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'a1_dupes: рівень слова A2 — в уроках A1 його більше немає, його вчать в A2 — стара версія');
    update public.lexemes set cefr = 'A2', version = version + 1 where id = r.id;
  end loop;
end $$;

-- 2. Нові уроки модуля A1.11 (місця 6–8): «Символи й винаходи», «Фестивалі й карнавали», «Казки й легенди»
do $$
declare
  v_unit constant uuid := '1fb51162-343f-5587-89cf-d2594a3091db';
  v_lesson uuid;
  v_gid uuid;
  v_cid uuid;
  v_pos int;
begin
  if exists (select 1 from public.lessons where id = '5ae02c5f-7ba1-5b59-be71-f744d6e9b169') then return; end if;  -- уже створено
  if (select count(*) from public.lessons where unit_id = v_unit and status = 'PUBLISHED') <> 5 then
    raise exception 'Модуль A1.11: очікувалось 5 уроків — звірте базу';
  end if;
  -- урок 99 «Символи й винаходи»: 22 слів, 2 діалоги, 15 вправ
  v_lesson := '5ae02c5f-7ba1-5b59-be71-f744d6e9b169';
  v_pos := 0;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Побудова питань' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Побудова питань»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 99: Символи й винаходи', 'Lekcija 99: Simboli i izumi', '["Назвати символи Хорватії: šahovnica, grb, kravata, dalmatinac", "Розповісти про хорватські винаходи: tehnička olovka, nalivpero, padobran", "Поставити питання: Tko je izumio…? Odakle je…? Zašto se tako zove?"]'::jsonb, 15, 'PUBLISHED', 6);
  v_pos := pg_temp.word(v_lesson, 'simbol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šahovnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grb', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crveno-bijeli', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kravata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vezati kravatu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Dan kravate', v_pos);
  v_pos := pg_temp.word(v_lesson, 'marama', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vojnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izum', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izumitelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izumiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'patent', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tehnička olovka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nalivpero', v_pos);
  v_pos := pg_temp.word(v_lesson, 'padobran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'znanstvenik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otkriće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dalmatinac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slavan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svjetski poznat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponos', v_pos);
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  v_pos := pg_temp.ex(v_lesson, v_pos, '3ab32807-1171-52f7-a627-2efc0a0409c4', 'fill_in_the_blank', '___ je kravata? — Iz Hrvatske.', 'Odakle', '["Kada", "Koliko", "Odakle", "Tko"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '147dcc2d-e528-535d-9866-4230cb8ae23b', 'multiple_choice', 'Що означає «crveno-bijeli»?', 'червоно-білий', '["далматинець (порода собак)", "герб", "парашут", "червоно-білий"]'::jsonb, 'A1', 2, 'PUBLISHED', 'crveno-bijeli', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7cf8a372-a50e-561c-8c8c-f719196abd9b', 'multiple_choice', 'Що означає «grb»?', 'герб', '["славетний", "червоно-білий", "патент", "герб"]'::jsonb, 'A1', 3, 'PUBLISHED', 'grb', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0a48776b-42ce-59a5-804b-9125c2a686cb', 'multiple_choice', 'Що означає «tehnička olovka»?', 'механічний олівець', '["шахівниця (червоно-білий хорватський герб)", "механічний олівець", "науковець", "всесвітньо відомий"]'::jsonb, 'A1', 4, 'PUBLISHED', 'tehnička olovka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c557ff7-552f-5649-a6ab-c5ff2d787536', 'multiple_choice', 'Як хорватською «авторучка (перова)»?', 'nalivpero', '["patent", "simbol", "dalmatinac", "nalivpero"]'::jsonb, 'A1', 5, 'PUBLISHED', 'nalivpero', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd851cf20-ce9a-5c50-85d3-48191045449c', 'multiple_choice', 'Як хорватською «відкриття»?', 'otkriće', '["kravata", "izumitelj", "otkriće", "ponos"]'::jsonb, 'A1', 6, 'PUBLISHED', 'otkriće', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '79480da0-bb50-5871-bc87-96bed082a598', 'type_answer', 'Напишіть хорватською: «славетний»', 'slavan', null, 'A1', 7, 'PUBLISHED', 'slavan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0c7d4f4c-3f03-58e6-a0ba-1582008d23ae', 'type_answer', 'Напишіть хорватською: «науковець»', 'znanstvenik', null, 'A1', 8, 'PUBLISHED', 'znanstvenik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b2ca41c0-d75b-501d-8207-51bfc8b44d2d', 'type_answer', 'Напишіть хорватською: «гордість»', 'ponos', null, 'A1', 9, 'PUBLISHED', 'ponos', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0af02891-d4b2-5baa-baeb-6d39fecb4ec2', 'sentence_builder', 'Складіть: «Краватка — хорватський винахід.»', 'Kravata je hrvatski izum.', '["hrvatski", "izum.", "Kravata", "je"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2299fd9e-cd3e-56a6-af38-2d4e80bfe3c1', 'sentence_builder', 'Складіть: «Хто винайшов парашут?»', 'Tko je izumio padobran?', '["je", "padobran?", "Tko", "izumio"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5fe864d4-c78c-5c98-8009-5295fb7edbeb', 'listening', 'Прослухайте і складіть фразу', 'Zato se kravata tako zove?', '["kravata", "zove?", "se", "Zato", "tako"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cfdbd37c-c0bf-518d-ab29-a0a604ae2dc0', 'listening', 'Прослухайте і складіть фразу', 'Tko je izumio tehničku olovku?', '["tehničku", "izumio", "Tko", "olovku?", "je"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '802d831e-1ab5-5471-8955-6c5cbd307585', 'speaking', 'Я не вмію зав’язувати краватку.', 'Ne znam vezati kravatu.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '033ab934-5911-56a4-a9a7-3d3597d7db40', 'speaking', 'Звідки цей символ?', 'Odakle je ovaj simbol?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  v_cid := 'f6a90db7-a852-5e8a-96ea-9c357a173e5a';
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values (v_cid, v_lesson, 'Звідки краватка?', 'Odakle je kravata?', 3991, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('908fbbf9-871b-5d7b-bb2b-11f590f00184', v_cid, 'Marko', 'Dašo, znaš li da je kravata hrvatski izum?', 'Дашо, знаєш, що краватка — хорватський винахід?', 1);
  perform pg_temp.turn('620ab65b-91b7-597b-b094-ce196830ddee', v_cid, 'Daša', 'Stvarno? Mislila sam da je iz Francuske.', 'Справді? Я думала, що вона з Франції.', 2);
  perform pg_temp.turn('c984d8f3-26be-5fdb-804c-46e24c8a5670', v_cid, 'Marko', 'Hrvatski vojnici nosili su marame oko vrata, a Francuzi su ih tako nazvali.', 'Хорватські солдати носили хустки на шиї, а французи так їх і назвали.', 3);
  perform pg_temp.turn('3511ee21-ceb1-510d-b601-97753c485bad', v_cid, 'Daša', 'Zato se kravata tako zove?', 'Тому краватка так називається?', 4);
  perform pg_temp.turn('012d0428-ff3a-5cfc-99cf-17b87595eafc', v_cid, 'Marko', 'Da, po Hrvatima. Osamnaestog listopada je Dan kravate.', 'Так, на честь хорватів. Вісімнадцятого жовтня — День краватки.', 5);
  perform pg_temp.turn('a9949700-7357-533a-9fc6-2d131d6af37a', v_cid, 'Daša', 'Onda ću tati kupiti kravatu. Ali ne znam je vezati!', 'Тоді куплю татові краватку. Але я не вмію її зав’язувати!', 6);
  v_cid := '65445845-9126-5581-a3ca-62508c44cd0b';
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values (v_cid, v_lesson, 'Хорватські винаходи', 'Hrvatski izumi', 3992, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('f2302fce-2a27-522a-a2ec-d49437d908cb', v_cid, 'Ana', 'Dobro došli! Ovdje su izumi poznatih hrvatskih znanstvenika i izumitelja.', 'Ласкаво просимо! Тут винаходи відомих хорватських учених і винахідників.', 1);
  perform pg_temp.turn('27fa6304-3b74-50a6-b773-95562a462942', v_cid, 'Darja', 'Tko je izumio tehničku olovku?', 'Хто винайшов механічний олівець?', 2);
  perform pg_temp.turn('6d605a26-b7a2-5627-99e4-da30ae0f4840', v_cid, 'Ana', 'Slavoljub Penkala. Imao je i patent za nalivpero.', 'Славолюб Пенкала. У нього був і патент на авторучку.', 3);
  perform pg_temp.turn('ef1128f3-3145-5d81-bd41-4d83148d49de', v_cid, 'Darja', 'A ovaj crtež? Izgleda kao padobran.', 'А цей малюнок? Схожий на парашут.', 4);
  perform pg_temp.turn('87395799-8eca-53d0-a62a-f0427d482297', v_cid, 'Ana', 'Jest. Faust Vrančić nacrtao ga je prije više od četiristo godina.', 'Так. Фауст Вранчич намалював його понад чотириста років тому.', 5);
  perform pg_temp.turn('eff22b95-daf7-5463-a1f3-59abfb443cdb', v_cid, 'Darja', 'Nevjerojatno! Na takva otkrića možete biti ponosni.', 'Неймовірно! Такими відкриттями можна пишатися.', 6);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок модуля A1.11 «Хорватська культура» (рішення власника 2026-11-17: «Символи й винаходи», «Фестивалі й карнавали», «Казки й легенди» — «окей») за схемою уроків за темою (20–25 слів, 2 діалоги, 15 вправ). Потрібна перевірка носієм.');
  -- урок 100 «Фестивалі й карнавали»: 22 слів, 2 діалоги, 15 вправ
  v_lesson := 'b026f1b1-879d-59b5-8506-ee99e128c9c1';
  v_pos := 0;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Орудний відмінок: autobusom, s prijateljem' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Орудний відмінок: autobusom, s prijateljem»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 100: Фестивалі й карнавали', 'Lekcija 100: Festivali i karnevali', '["Розповісти про карнавал: maškare, kostim, povorka, zvončari", "Домовитися піти на карнавал чи фестиваль: «Idemo li na karneval?»", "Орудний відмінок: s kolegama, s maskama, sa zvonima"]'::jsonb, 15, 'PUBLISHED', 7);
  v_pos := pg_temp.word(v_lesson, 'karneval', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maškare', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poklade', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Pepelnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kostim', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maskirati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prerušiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gusar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povorka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvončari', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovčja koža', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rog', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tjerati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spaliti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maskenbal', v_pos);
  v_pos := pg_temp.word(v_lesson, 'konfeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bubanj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ples', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nastupati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šaliti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smijeh', v_pos);
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ca64a6f-0d76-548b-88e3-99d5617837ce', 'fill_in_the_blank', 'Na karneval idem ___.', 's prijateljima', '["prijateljima", "s prijateljima", "prijatelji", "s prijatelje"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e4f221a4-8af4-5ad9-b505-5566241d63ee', 'multiple_choice', 'Що означає «prerušiti se»?', 'перевдягнутися (в когось)', '["проганяти, гнати", "перевдягнутися (в когось)", "карнавальні дні перед Великим постом (масниця)", "карнавал"]'::jsonb, 'A1', 2, 'PUBLISHED', 'prerušiti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cc5e78e8-cdf4-5e52-b3ac-3caa54eb24a3', 'multiple_choice', 'Що означає «zvončari»?', 'дзвонарі (ряджені з дзвонами з околиць Рієки)', '["виступати (на сцені)", "дзвонарі (ряджені з дзвонами з околиць Рієки)", "карнавал", "спалити"]'::jsonb, 'A1', 3, 'PUBLISHED', 'zvončari', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '332706d1-dbbd-5199-a53f-719673559123', 'multiple_choice', 'Що означає «šaliti se»?', 'жартувати', '["маскарад; ряджені (на карнавалі)", "ріг", "перевдягатися (на карнавал), маскуватися", "жартувати"]'::jsonb, 'A1', 4, 'PUBLISHED', 'šaliti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c9cc2607-e2ed-5df0-8eb2-d42b24aa12cc', 'multiple_choice', 'Як хорватською «танець»?', 'ples', '["ovčja koža", "šaliti se", "maskenbal", "ples"]'::jsonb, 'A1', 5, 'PUBLISHED', 'ples', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1495615f-87ea-543a-9bf6-6926329a2ff6', 'multiple_choice', 'Як хорватською «виступати (на сцені)»?', 'nastupati', '["nastupati", "Pepelnica", "maskenbal", "šaliti se"]'::jsonb, 'A1', 6, 'PUBLISHED', 'nastupati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a515510-469d-54a2-acb6-415dfe2fec7f', 'type_answer', 'Напишіть хорватською: «овеча шкура»', 'ovčja koža', null, 'A1', 7, 'PUBLISHED', 'ovčja koža', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6257c2a0-d383-5ac4-a73e-4b0ef490c5fa', 'type_answer', 'Напишіть хорватською: «проганяти, гнати»', 'tjerati', null, 'A1', 8, 'PUBLISHED', 'tjerati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '48574aa3-ecb7-5433-bf6d-baf79b8ff42e', 'type_answer', 'Напишіть хорватською: «хода, процесія»', 'povorka', null, 'A1', 9, 'PUBLISHED', 'povorka', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0bac8f7b-1990-5c62-a9d0-4e51efb9b280', 'sentence_builder', 'Складіть: «Я перевдягнуся на пірата.»', 'Maskirat ću se u gusara.', '["se", "ću", "Maskirat", "u", "gusara."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bb10c388-6a01-5e33-a840-f7be6c0bc429', 'sentence_builder', 'Складіть: «Хода йде головною вулицею.»', 'Povorka ide glavnom ulicom.', '["ide", "Povorka", "ulicom.", "glavnom"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0a73be74-c626-5d2e-8b28-9faff8d2de5c', 'listening', 'Прослухайте і складіть фразу', 'A ja ću biti mačka, s ušima i repom.', '["biti", "repom.", "ću", "ušima", "ja", "mačka,", "s", "i", "A"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5f60b564-d677-52f3-9dfc-79a2ec8b1d5c', 'listening', 'Прослухайте і складіть фразу', 'Tko su zvončari?', '["zvončari?", "Tko", "su"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f9c357e5-0a4f-5ee0-a1c1-2543e00499cb', 'speaking', 'Я йду на карнавал з колегами.', 'Idem na karneval s kolegama.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3d877ced-e39d-564f-be19-2b86ebf4c10c', 'speaking', 'Я просто жартую!', 'Samo se šalim!', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  v_cid := 'feec38b9-1ed2-5130-bc3b-516f5c77a218';
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values (v_cid, v_lesson, 'Підемо на карнавал?', 'Idemo na karneval?', 4001, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('e32bfe2a-06df-5eb7-bcb9-43dcb453973a', v_cid, 'Daša', 'Darja, idemo li u nedjelju na Riječki karneval?', 'Дар’є, підемо в неділю на Рієцький карнавал?', 1);
  perform pg_temp.turn('07185f3f-cc53-5b58-81ce-ad5f04095a3c', v_cid, 'Darja', 'Može! Idem s kolegama s posla. Imaš li kostim?', 'Можна! Я йду з колегами з роботи. У тебе є костюм?', 2);
  perform pg_temp.turn('96a72ad0-816b-53be-93df-abc7478f5341', v_cid, 'Daša', 'Imam. Maskirat ću se u gusaricu s crnim šeširom.', 'Є. Я перевдягнуся на піратку в чорному капелюсі.', 3);
  perform pg_temp.turn('9d5afaf2-83fd-58b2-be31-b286354a47a6', v_cid, 'Darja', 'A ja ću biti mačka, s ušima i repom.', 'А я буду кішкою, з вушками й хвостом.', 4);
  perform pg_temp.turn('50690357-97a4-5e1a-a0b3-b53f2c556549', v_cid, 'Daša', 'Super! Povorka kreće u podne, s bubnjevima i konfetima.', 'Чудово! Хода рушає опівдні, з барабанами й конфеті.', 5);
  perform pg_temp.turn('efdc38d7-3b35-5de3-8835-dcf2b891ce13', v_cid, 'Darja', 'Onda se nađemo u jedanaest ispred kazališta.', 'Тоді зустрінемося об одинадцятій перед театром.', 6);
  v_cid := '537363b7-bb03-5d7a-8682-4e088d853308';
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values (v_cid, v_lesson, 'Дзвонарі', 'Zvončari', 4002, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('6068e4ff-31ed-5b55-a2a4-a0552fa6b7d0', v_cid, 'Marko', 'Dašo, čuješ li ova zvona? Dolaze zvončari!', 'Дашо, чуєш ці дзвони? Ідуть дзвонарі!', 1);
  perform pg_temp.turn('a0645114-31c8-5ef8-b012-8146646e22bc', v_cid, 'Daša', 'Tko su zvončari?', 'Хто такі дзвонарі?', 2);
  perform pg_temp.turn('093dbc99-0d6a-515d-968b-42de0c986ef9', v_cid, 'Marko', 'Muškarci s velikim zvonima i maskama s rogovima. Nose ovčje kože.', 'Чоловіки з великими дзвонами й масками з рогами. Вони вдягнені в овечі шкури.', 3);
  perform pg_temp.turn('b7b449ea-aff9-53c9-9b50-ac394a5d4ca7', v_cid, 'Daša', 'Zašto toliko zvone?', 'Чому вони так дзвонять?', 4);
  perform pg_temp.turn('592e1efc-6567-513e-8589-8a8a557f6929', v_cid, 'Marko', 'To je stari običaj. Tjeraju zimu i zle duhove.', 'Це давній звичай. Вони проганяють зиму й злих духів.', 5);
  perform pg_temp.turn('f05c55aa-3252-583b-ba19-ae4ebe776c13', v_cid, 'Daša', 'Malo su strašni, ali i smiješni!', 'Трохи страшні, але й кумедні!', 6);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок модуля A1.11 «Хорватська культура» (рішення власника 2026-11-17: «Символи й винаходи», «Фестивалі й карнавали», «Казки й легенди» — «окей») за схемою уроків за темою (20–25 слів, 2 діалоги, 15 вправ). Потрібна перевірка носієм.');
  -- урок 101 «Казки й легенди»: 23 слів, 2 діалоги, 15 вправ
  v_lesson := '8bb4331d-c7c0-5039-acf9-756684424039';
  v_pos := 0;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Минулий час: radio sam, bila sam»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 101: Казки й легенди', 'Lekcija 101: Bajke i legende', '["Назвати героїв казок: vila, zmaj, div, vještica, kraljević, kraljevna", "Розповісти коротку казку в минулому часі: «Bilo jednom…», «spasio je…»", "Знати «Priče iz davnine» Івани Брлич-Мажуранич (1916)"]'::jsonb, 15, 'PUBLISHED', 8);
  v_pos := pg_temp.word(v_lesson, 'priča', v_pos);
  v_pos := pg_temp.word(v_lesson, 'legenda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pripovijedati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bilo jednom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'za laku noć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'junak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hrabar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kraljević', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kraljevna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vila', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zmaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vještica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'div', v_pos);
  v_pos := pg_temp.word(v_lesson, 'patuljak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čarobni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čarolija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'začarati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pretvoriti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zlo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobrota', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pouka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sretan kraj', v_pos);
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a66df4a5-45f1-5653-9804-e9fc3189d750', 'fill_in_the_blank', 'Zmaj je ___ kraljevnu.', 'oteo', '["oteli", "otela", "oteo", "oteti"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cb7c31ae-87d7-525f-ac5c-0ea2d087b47d', 'multiple_choice', 'Що означає «bilo jednom»?', 'колись давно; жили-були (початок казки)', '["зачарувати", "колись давно; жили-були (початок казки)", "зло", "доброта"]'::jsonb, 'A1', 2, 'PUBLISHED', 'bilo jednom', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fde4eb86-174a-55c5-9972-e6c5c92f49e6', 'multiple_choice', 'Що означає «pouka»?', 'мораль, повчання (казки)', '["зло", "мораль, повчання (казки)", "розповідь, історія", "відьма"]'::jsonb, 'A1', 3, 'PUBLISHED', 'pouka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3c5a853f-eb59-5fc4-89b5-2e288e5dde83', 'multiple_choice', 'Що означає «dobrota»?', 'доброта', '["доброта", "розповідати (історію, казку)", "відьма", "щасливий кінець"]'::jsonb, 'A1', 4, 'PUBLISHED', 'dobrota', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ad6b6855-e689-5955-b7ca-41ccdee7d2e7', 'multiple_choice', 'Як хорватською «відьма»?', 'vještica', '["legenda", "vještica", "pripovijedati", "čarobni"]'::jsonb, 'A1', 5, 'PUBLISHED', 'vještica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d41a596-12a3-5ffc-9254-452244d53a83', 'multiple_choice', 'Як хорватською «легенда»?', 'legenda', '["legenda", "priča", "div", "zlo"]'::jsonb, 'A1', 6, 'PUBLISHED', 'legenda', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cfe9276d-0a9e-5734-8e76-2ba2606a7aae', 'type_answer', 'Напишіть хорватською: «велетень»', 'div', null, 'A1', 7, 'PUBLISHED', 'div', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '13fe3967-8814-5a37-bbf7-d7b35a59acb9', 'type_answer', 'Напишіть хорватською: «королевич, принц»', 'kraljević', null, 'A1', 8, 'PUBLISHED', 'kraljević', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a106f125-4fac-5c15-9954-684fd8f370c5', 'type_answer', 'Напишіть хорватською: «дракон; повітряний змій»', 'zmaj', null, 'A1', 9, 'PUBLISHED', 'zmaj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3240e0e3-8fbe-5fbd-b13d-158c7e0b738c', 'sentence_builder', 'Складіть: «Фея перетворилася на пташку.»', 'Vila se pretvorila u pticu.', '["pretvorila", "Vila", "se", "u", "pticu."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b0975b3c-db25-5e07-8bac-8095dbf872d0', 'sentence_builder', 'Складіть: «Королевич урятував королівну.»', 'Kraljević je spasio kraljevnu.', '["spasio", "je", "kraljevnu.", "Kraljević"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cc173655-688f-5399-acb3-de9c4fc2a128', 'listening', 'Прослухайте і складіть фразу', 'Je li ju hrabri kraljević spasio?', '["kraljević", "hrabri", "li", "Je", "ju", "spasio?"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a6fb17af-8c1c-5b40-8368-3c48cebd8b8b', 'listening', 'Прослухайте і складіть фразу', 'O čemu su te priče?', '["su", "te", "O", "priče?", "čemu"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dae4ca1e-037d-54cb-9dff-275a01e0fd80', 'speaking', 'Прочитай мені казку на ніч!', 'Pročitaj mi priču za laku noć!', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c69d362-e667-5295-ba82-bae8a5748541', 'speaking', 'Яка мораль цієї казки?', 'Koja je pouka ove priče?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  v_cid := '0e859832-f199-5755-af6a-9289dff7392a';
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values (v_cid, v_lesson, 'Казка на ніч', 'Priča za laku noć', 4011, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('f90d65a5-eb2a-517b-bca8-4fb4a6a0fb10', v_cid, 'Mia', 'Mama, pročitaj mi priču za laku noć!', 'Мамо, прочитай мені казку на ніч!', 1);
  perform pg_temp.turn('9b5efec8-1b28-5619-b906-2abcb9274a86', v_cid, 'Daša', 'Može. Koju želiš, o zmaju ili o dobroj vili?', 'Добре. Яку хочеш: про дракона чи про добру фею?', 2);
  perform pg_temp.turn('331439a1-f72f-568e-9256-568d12224aff', v_cid, 'Mia', 'O zmaju! I neka ima sretan kraj.', 'Про дракона! І щоб був щасливий кінець.', 3);
  perform pg_temp.turn('e4529d44-ff28-5d39-a6c6-d095c25a8e74', v_cid, 'Daša', 'Bilo jednom jedno kraljevstvo. Zli zmaj oteo je kraljevnu.', 'Колись давно було одне королівство. Злий дракон викрав королівну.', 4);
  perform pg_temp.turn('942949ec-989d-5290-a603-7dbca2f4e537', v_cid, 'Mia', 'Je li ju hrabri kraljević spasio?', 'А сміливий королевич її врятував?', 5);
  perform pg_temp.turn('5046eee4-1911-5f7d-b69e-d8b43b5e921e', v_cid, 'Daša', 'Jest, i svi su živjeli sretno. A sada zatvori oči!', 'Так, і всі жили щасливо. А тепер заплющ очі!', 6);
  v_cid := '80398a9e-a330-55ac-8413-433d23afd733';
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values (v_cid, v_lesson, 'Казки з давнини', 'Priče iz davnine', 4012, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('4fd7f960-873e-56bd-886c-ae673c151da1', v_cid, 'Darja', 'Ivana, koju hrvatsku knjigu bajki da kupim kćeri?', 'Івано, яку хорватську книжку казок купити доньці?', 1);
  perform pg_temp.turn('b225776e-d57b-59ff-a22d-8e3411f5acc2', v_cid, 'Ivana', '„Priče iz davnine“ Ivane Brlić-Mažuranić. Djeca ih vole već više od sto godina.', '«Казки з давнини» Івани Брлич-Мажуранич. Діти люблять їх уже понад сто років.', 2);
  perform pg_temp.turn('6e5aeba8-4b0a-520d-a4a6-8eb0c31bdac3', v_cid, 'Darja', 'O čemu su te priče?', 'Про що ці казки?', 3);
  perform pg_temp.turn('b38d78fb-b1a8-5950-bc05-16538b654273', v_cid, 'Ivana', 'O hrabrim junacima, vilama i divovima iz starih slavenskih legendi.', 'Про сміливих героїв, фей і велетнів зі старих слов’янських легенд.', 4);
  perform pg_temp.turn('51572e2a-1615-5be3-877b-5098ac7e57da', v_cid, 'Darja', 'Imaju li te priče neku pouku?', 'У цих казок є якась мораль?', 5);
  perform pg_temp.turn('1da55fb4-6eb2-5965-81a9-76157e8219c3', v_cid, 'Ivana', 'Imaju. Dobrota i hrabrost uvijek pobjeđuju zlo.', 'Так. Доброта й сміливість завжди перемагають зло.', 6);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок модуля A1.11 «Хорватська культура» (рішення власника 2026-11-17: «Символи й винаходи», «Фестивалі й карнавали», «Казки й легенди» — «окей») за схемою уроків за темою (20–25 слів, 2 діалоги, 15 вправ). Потрібна перевірка носієм.');
end $$;

-- 3. Урок 54 (стане 54): урок «Договір і зарплата» без бруто, нето й податків — їх пояснює A2-34 (Д3)
do $$
declare
  v_lesson constant uuid := '4d6f3498-2cc5-54a0-b4e4-c66add71ef12';
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = 'potpisati ugovor') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a1_dupes: урок «Договір і зарплата» без бруто, нето й податків — їх пояснює A2-34 (Д3) — стара версія');
  perform pg_temp.swap_word(v_lesson, 'bruto', 'potpisati ugovor');
  perform pg_temp.swap_word(v_lesson, 'neto', 'raditi vikendom');
  perform pg_temp.swap_word(v_lesson, 'porez', 'ugovor o radu');
  perform pg_temp.swap_word(v_lesson, 'doprinosi', 'opis posla');
  perform pg_temp.swap_word(v_lesson, 'platna lista', 'uvjeti rada');
  perform pg_temp.swap_ex(v_lesson, '03f30aba-a181-5afd-a691-834659ab5123', 'ed91c5ef-187b-5cea-b5a3-c4fd1929845a', 'multiple_choice', 'Як хорватською «працювати у вихідні»?', 'raditi vikendom', '["probni rad", "regres", "raditi vikendom", "otkazni rok"]'::jsonb, 'raditi vikendom');
  perform pg_temp.swap_ex(v_lesson, '6a5e24b6-e6b1-5f56-b973-54699d56f903', 'd604e73f-1461-587d-afb3-b491bb8d928c', 'type_answer', 'Напишіть хорватською: «опис посадових обов’язків»', 'opis posla', null, 'opis posla');
  perform pg_temp.swap_ex(v_lesson, '031e103b-24b1-52de-85a8-729f112a4e5a', '2d7d5cab-ceaa-5c20-b6bd-4de549cf67b1', 'type_answer', 'Напишіть хорватською: «умови праці»', 'uvjeti rada', null, 'uvjeti rada');
  perform pg_temp.swap_ex(v_lesson, '9ce82225-ddf8-578a-aa46-6ac6b993611a', '51f6fe6d-2326-57ee-9f12-bb2f29efee99', 'listening', 'Прослухайте і складіть фразу', 'Moram li raditi vikendom?', '["li", "vikendom?", "Moram", "raditi"]'::jsonb, null);
  perform pg_temp.swap_ex(v_lesson, '55d9f7d9-f12c-52ce-aa6b-4ad3d0b650c2', '3c37107a-9fe6-56cc-9578-b13cedb5daff', 'speaking', 'Де мені підписати договір?', 'Gdje da potpišem ugovor?', null, null);
  perform pg_temp.swap_ex(v_lesson, 'be459db2-e3f5-5143-a8c1-79a984bd6c25', 'c21a7c55-66af-5185-bfd4-c0599f927aa4', 'multiple_choice', 'Що означає «smjena»?', 'зміна (на роботі)', '["відпускні (виплата до відпустки)", "випробувальний термін", "строк попередження про звільнення", "зміна (на роботі)"]'::jsonb, 'smjena');
  perform pg_temp.swap_ex(v_lesson, 'e7919ed9-9b77-5384-953e-0f47767dffea', '600aabd5-2b4b-5abf-98c5-010d5a2d90ec', 'multiple_choice', 'Що означає «ugovor na određeno»?', 'строковий договір', '["строковий договір", "різдвяна премія", "понаднормові години", "випробувальний термін"]'::jsonb, 'ugovor na određeno');
  -- діалог «Prva plaća» → «Pitanja o ugovoru» (старий — DEPRECATED, не видаляється)
  update public.conversations set status = 'DEPRECATED' where id = 'd683d4c9-6d44-5479-966f-dfd350782ec6' and status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Prva plaća» — звірте базу'; end if;
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  -- source — як в інших діалогів уроку (програма curriculum_a1_v3); звідки діалог — у content_reviews
  values ('b06a6197-10d2-5b32-bda7-78cdc101a053', v_lesson, 'Запитання про договір', 'Pitanja o ugovoru', 3542, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3');
  perform pg_temp.turn('fd2c2e67-f6d9-5554-9c97-065600a9097f', 'b06a6197-10d2-5b32-bda7-78cdc101a053', 'Daša', 'Prije nego što potpišem ugovor, imam nekoliko pitanja.', 'Перш ніж я підпишу договір, у мене є кілька запитань.', 1);
  perform pg_temp.turn('cee9ebd5-9a4c-5ffe-b59f-3d388874c33b', 'b06a6197-10d2-5b32-bda7-78cdc101a053', 'Gospodin Babić', 'Naravno, slobodno pitajte.', 'Звісно, питайте.', 2);
  perform pg_temp.turn('18cd6cc3-46ba-5af7-add6-ee497c3a606e', 'b06a6197-10d2-5b32-bda7-78cdc101a053', 'Daša', 'Moram li raditi vikendom?', 'Чи мушу я працювати у вихідні?', 3);
  perform pg_temp.turn('b4549ded-b00c-52ee-9fa2-e823cd2697a7', 'b06a6197-10d2-5b32-bda7-78cdc101a053', 'Gospodin Babić', 'Samo jednu subotu u mjesecu, a prekovremeni sati plaćaju se posebno.', 'Лише одну суботу на місяць, а понаднормові години оплачуються окремо.', 4);
  perform pg_temp.turn('9160a8f0-e89d-5eb3-a5d0-a24eb743c40b', 'b06a6197-10d2-5b32-bda7-78cdc101a053', 'Daša', 'Gdje mogu vidjeti opis posla i uvjete rada?', 'Де я можу подивитися опис обов’язків і умови праці?', 5);
  perform pg_temp.turn('4b99c3be-338f-5d79-8a4d-769898b2ecad', 'b06a6197-10d2-5b32-bda7-78cdc101a053', 'Gospodin Babić', 'U ugovoru o radu, na drugoj stranici. Kad pročitate, potpišite ovdje.', 'У трудовому договорі, на другій сторінці. Коли прочитаєте, підпишіть ось тут.', 6);
  update public.lessons set objectives = '["Розпитати про договір: na određeno, na neodređeno, probni rad, otkazni rok", "Поставити питання перед підписанням: «Moram li raditi vikendom?», «Gdje je opis posla?»", "Модальні дієслова: moram, ne moraš, smijem li…"]'::jsonb where id = v_lesson;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a1_dupes 20261117: план «Дублі й сенс уроків» (PR 3, рішення власника 2026-11-17) — урок «Договір і зарплата» без бруто, нето й податків — їх пояснює A2-34 (Д3). Бета, потрібна перевірка носієм.');
end $$;

-- 3. Урок 70 (стане 70): урок «В аптеці: як приймати ліки» без tableta, lijek protiv bolova — їх учать в A0 «В аптеці» (Д12)
do $$
declare
  v_lesson constant uuid := '123e68fa-291f-5ad6-8403-51db7020d641';
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = 'prije jela') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a1_dupes: урок «В аптеці: як приймати ліки» без tableta, lijek protiv bolova — їх учать в A0 «В аптеці» (Д12) — стара версія');
  perform pg_temp.swap_word(v_lesson, 'lijek protiv bolova', 'prije jela');
  perform pg_temp.swap_word(v_lesson, 'tableta', 'dvaput dnevno');
  perform pg_temp.swap_ex(v_lesson, '70bf200c-8a2f-52e5-9999-27f7a87d8b12', '09a24fea-bac9-5b93-9a9c-56188a577076', 'multiple_choice', 'Що означає «prije jela»?', 'перед їжею', '["побічна дія", "краплі", "мазь", "перед їжею"]'::jsonb, 'prije jela');
  perform pg_temp.swap_ex(v_lesson, 'b5c3941b-83e4-5ace-b143-2d86eb71ca54', '0712250e-c401-5a7c-b359-0c9380cbee2f', 'multiple_choice', 'Як хорватською «двічі на день»?', 'dvaput dnevno', '["natašte", "doza", "kapsula", "dvaput dnevno"]'::jsonb, 'dvaput dnevno');
  perform pg_temp.swap_ex(v_lesson, '6e094afa-fc78-5fad-974d-c04642330ef4', '27eeffd0-9c08-5036-8871-418e5ccb30ce', 'multiple_choice', 'Що означає «uzimati»?', 'брати; приймати (ліки)', '["спрей для носа", "проковтнути", "натщесерце", "брати; приймати (ліки)"]'::jsonb, 'uzimati');
  perform pg_temp.swap_ex(v_lesson, 'a273ece0-7e79-5419-98a1-a4737ef7f2e9', 'bc0694ae-d816-52bc-a37a-fc8617344f7a', 'multiple_choice', 'Що означає «bez recepta»?', 'без рецепта', '["капсула", "без рецепта", "розчинити", "доза"]'::jsonb, 'bez recepta');
  perform pg_temp.swap_ex(v_lesson, '8bf54a92-0831-5b09-b6f3-3598bd9ddbed', '595b1436-2ca1-5579-a50f-ff46310ba06a', 'multiple_choice', 'Як хорватською «розчинити»?', 'otopiti', '["mast", "kapi", "uzimati", "otopiti"]'::jsonb, 'otopiti');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a1_dupes 20261117: план «Дублі й сенс уроків» (PR 3, рішення власника 2026-11-17) — урок «В аптеці: як приймати ліки» без tableta, lijek protiv bolova — їх учать в A0 «В аптеці» (Д12). Бета, потрібна перевірка носієм.');
end $$;

-- 3. Урок 93 (стане 94): урок «Дубровник і Спліт» без katedrala, zidine — вони в A0 «Старе місто» (Д13)
do $$
declare
  v_lesson constant uuid := 'd9ef1de4-f4db-590e-bafd-474f84c8e03f';
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = 'gotički') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a1_dupes: урок «Дубровник і Спліт» без katedrala, zidine — вони в A0 «Старе місто» (Д13) — стара версія');
  perform pg_temp.swap_word(v_lesson, 'zidine', 'gotički');
  perform pg_temp.swap_word(v_lesson, 'katedrala', 'renesansni');
  perform pg_temp.swap_ex(v_lesson, '19fe1e06-3fe4-5c78-af85-28da7b3fbedf', '5a16a0a4-71c3-5a33-ac04-13c62a98676e', 'multiple_choice', 'Що означає «gotički»?', 'готичний', '["бароковий", "руїни", "готичний", "вуличка"]'::jsonb, 'gotički');
  perform pg_temp.swap_ex(v_lesson, '1ff1bf03-e926-5ffa-9eb7-ee9cf9600333', 'fb9e225f-cfb1-5064-9815-ff5d3fea69c3', 'speaking', 'Ця церква готична.', 'Ova crkva je gotička.', null, null);
  update public.lessons set objectives = '["Розповісти про Дубровник і Спліт: tvrđava, toranj, gradska vrata, palača", "Назвати стилі: srednjovjekovni, gotički, renesansni, barokni", "Минулий час: šetala sam, izgradili su"]'::jsonb where id = v_lesson;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a1_dupes 20261117: план «Дублі й сенс уроків» (PR 3, рішення власника 2026-11-17) — урок «Дубровник і Спліт» без katedrala, zidine — вони в A0 «Старе місто» (Д13). Бета, потрібна перевірка носієм.');
end $$;

-- 3. Урок 101 (стане 105): урок «Навчання й мовні курси» — запис на курс і перше заняття; іспит і визнання — в A2-11…A2-13 (Д2)
do $$
declare
  v_lesson constant uuid := '11b565a4-1e2a-50d2-8d9d-c05e84371402';
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = 'upisati se') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a1_dupes: урок «Навчання й мовні курси» — запис на курс і перше заняття; іспит і визнання — в A2-11…A2-13 (Д2) — стара версія');
  perform pg_temp.swap_word(v_lesson, 'polagati', 'upisati se');
  perform pg_temp.swap_word(v_lesson, 'položiti', 'test razine');
  perform pg_temp.swap_word(v_lesson, 'uvjerenje', 'početni tečaj');
  perform pg_temp.swap_word(v_lesson, 'svjedodžba', 'rječnik');
  perform pg_temp.swap_word(v_lesson, 'priznavanje', 'vježba');
  perform pg_temp.swap_ex(v_lesson, 'b56f41cb-9d38-5d65-832d-58e00cd62cfd', 'a2978753-b575-5f79-92e9-030f590ba109', 'multiple_choice', 'Що означає «test razine»?', 'тест на рівень', '["клас, аудиторія", "стипендія", "лекція", "тест на рівень"]'::jsonb, 'test razine');
  perform pg_temp.swap_ex(v_lesson, 'd41871f8-28e1-587e-9398-afcf9a805011', 'ad25dee7-b00d-598a-b1a3-070593982ea9', 'type_answer', 'Напишіть хорватською: «словник»', 'rječnik', null, 'rječnik');
  perform pg_temp.swap_ex(v_lesson, '04a6c5a1-49d3-527c-afff-9dcf94500785', 'e0f09715-6d9a-5f12-aeed-fe569a295cfd', 'sentence_builder', 'Складіть: «Я записалася на курс для початківців.»', 'Upisala sam se na početni tečaj.', '["sam", "Upisala", "početni", "tečaj.", "se", "na"]'::jsonb, null);
  perform pg_temp.swap_ex(v_lesson, 'ed8c7539-cab8-57ba-9e5c-caaea95043d6', 'ad91b362-9e94-5c40-b8a2-aba5c76c582c', 'listening', 'Прослухайте і складіть фразу', 'Onda prvo napišite kratki test.', '["napišite", "test.", "prvo", "kratki", "Onda"]'::jsonb, null);
  perform pg_temp.swap_ex(v_lesson, '7d637eca-9d12-551e-8088-adbab2e44661', 'c681752e-f404-5125-bbfc-bd5c78bc1c75', 'listening', 'Прослухайте і складіть фразу', 'Smijem li koristiti rječnik na mobitelu?', '["koristiti", "mobitelu?", "na", "rječnik", "Smijem", "li"]'::jsonb, null);
  perform pg_temp.swap_ex(v_lesson, '096b06c4-1890-57a1-bd2d-3052fbe2da1b', '07b2de09-86be-5f38-ae8a-25ed0252e849', 'multiple_choice', 'Що означає «napredni»?', 'просунутий (рівень)', '["навчальний матеріал", "початківець", "слухач (курсу)", "просунутий (рівень)"]'::jsonb, 'napredni');
  perform pg_temp.swap_ex(v_lesson, '05a853de-b4ea-5611-b260-15215ee1bba1', '56c7713a-8bd8-57df-84ec-76daa0ca00f7', 'multiple_choice', 'Що означає «nastava»?', 'заняття; навчання (уроки)', '["клас, аудиторія", "стипендія", "рівень", "заняття; навчання (уроки)"]'::jsonb, 'nastava');
  perform pg_temp.swap_ex(v_lesson, '3b2d7214-b68b-5627-a055-2fb6bb2a3843', '921e02a0-f80b-5e4d-b5fe-1b3565f1eef5', 'multiple_choice', 'Як хорватською «лекція»?', 'predavanje', '["učionica", "gradivo", "nastava", "predavanje"]'::jsonb, 'predavanje');
  perform pg_temp.swap_ex(v_lesson, '4ebbb7ff-5b43-50aa-ba56-a5af65b8b6c5', 'ad47c7a4-cfe6-5826-a340-4f51a758d629', 'multiple_choice', 'Як хорватською «початківець»?', 'početnik', '["gradivo", "stipendija", "polaznik", "početnik"]'::jsonb, 'početnik');
  -- діалог «Poslije ispita» → «Prvi sat» (старий — DEPRECATED, не видаляється)
  update public.conversations set status = 'DEPRECATED' where id = '8334cf71-db86-5617-87b7-e8a7d9921162' and status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Poslije ispita» — звірте базу'; end if;
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  -- source — як в інших діалогів уроку (програма curriculum_a1_v3); звідки діалог — у content_reviews
  values ('0829890c-d828-5e11-b673-5c601d15ce82', v_lesson, 'Перше заняття', 'Prvi sat', 4012, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3');
  perform pg_temp.turn('aaabb2f0-7d5d-5d2a-939c-4e5646ff3adf', '0829890c-d828-5e11-b673-5c601d15ce82', 'Profesorica', 'Dobro došli na početni tečaj! Ja sam vaša profesorica Ana.', 'Ласкаво просимо на курс для початківців! Я ваша викладачка Ана.', 1);
  perform pg_temp.turn('91f2782a-a07a-55b4-8f51-f4c6396dca89', '0829890c-d828-5e11-b673-5c601d15ce82', 'Daša', 'Dobar dan! Upisala sam se jučer, ali još nemam udžbenik.', 'Добрий день! Я записалася вчора, але ще не маю підручника.', 2);
  perform pg_temp.turn('bcbd2509-8645-5d0a-94a5-75d8ac94b21e', '0829890c-d828-5e11-b673-5c601d15ce82', 'Profesorica', 'Nema problema, danas radimo vježbe na listićima.', 'Нічого страшного, сьогодні робимо вправи на аркушах.', 3);
  perform pg_temp.turn('3a6d0dfa-71df-5444-b754-e018770a73d8', '0829890c-d828-5e11-b673-5c601d15ce82', 'Daša', 'Smijem li koristiti rječnik na mobitelu?', 'Можна користуватися словником у телефоні?', 4);
  perform pg_temp.turn('c51996de-4456-5511-8202-4c640cfca869', '0829890c-d828-5e11-b673-5c601d15ce82', 'Profesorica', 'Smijete, ali prvo pokušajte bez njega. Sljedeći sat je u četvrtak.', 'Можна, але спершу спробуйте без нього. Наступне заняття — у четвер.', 5);
  perform pg_temp.turn('de9f999b-feff-534c-8aa0-69b8f3032579', '0829890c-d828-5e11-b673-5c601d15ce82', 'Daša', 'Dobro, hvala! Vidimo se u četvrtak.', 'Добре, дякую! Побачимося в четвер.', 6);
  update public.lessons set objectives = '["Записатися на мовний курс: razina, test razine, početni tečaj, intenzivni tečaj", "Перше заняття: učionica, vježba, rječnik, gradivo", "Родовий відмінок: tečaj hrvatskog, od rujna do prosinca"]'::jsonb where id = v_lesson;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a1_dupes 20261117: план «Дублі й сенс уроків» (PR 3, рішення власника 2026-11-17) — урок «Навчання й мовні курси» — запис на курс і перше заняття; іспит і визнання — в A2-11…A2-13 (Д2). Бета, потрібна перевірка носієм.');
end $$;

-- 4. Слова не зникають з курсу: svjedodžba → A2-11, porez і platna lista → A2-34 (у кінець уроку, без нових вправ)
do $$
declare v_lesson constant uuid := 'dd6c5f39-f66e-5acb-8255-932f822ddcc5'; w text;
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id
              where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = 'svjedodžba') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a1_dupes: A2 урок 11 «Визнання диплома» + svjedodžba з уроку A1 (план «Дублі», PR 3) — слова не зникають з курсу — стара версія');
  foreach w in array array['svjedodžba'] loop
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill)
    select v_lesson, 'lexeme', (select id from public.lexemes where lower(lemma) = w and status = 'PUBLISHED' order by created_at limit 1),
           (select max(order_index) + 1 from public.lesson_items where lesson_id = v_lesson), 'vocabulary';
  end loop;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a1_dupes 20261117: план «Дублі й сенс уроків» (PR 3, рішення власника 2026-11-17) — A2 урок 11 «Визнання диплома» + svjedodžba з уроку A1 (план «Дублі», PR 3) — слова не зникають з курсу. Бета, потрібна перевірка носієм.');
end $$;

do $$
declare v_lesson constant uuid := 'b9bcea21-08a3-56cf-be72-edf6b6c7b03f'; w text;
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id
              where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = 'porez') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a1_dupes: A2 урок 34 «Зарплата: бруто, нето, податки» + porez, platna lista з уроку A1 (план «Дублі», PR 3) — слова не зникають з курсу — стара версія');
  foreach w in array array['porez', 'platna lista'] loop
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill)
    select v_lesson, 'lexeme', (select id from public.lexemes where lower(lemma) = w and status = 'PUBLISHED' order by created_at limit 1),
           (select max(order_index) + 1 from public.lesson_items where lesson_id = v_lesson), 'vocabulary';
  end loop;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a1_dupes 20261117: план «Дублі й сенс уроків» (PR 3, рішення власника 2026-11-17) — A2 урок 34 «Зарплата: бруто, нето, податки» + porez, platna lista з уроку A1 (план «Дублі», PR 3) — слова не зникають з курсу. Бета, потрібна перевірка носієм.');
end $$;

-- 5. Урок 105 «Надзвичайні ситуації» → модуль A1.8 «Здоров’я», місце 11 (стане уроком 76); стара версія — content_versions
do $$
declare v_lesson constant uuid := '692e9310-7a5b-5adf-9f0a-a66b72fc5459';
begin
  if (select unit_id from public.lessons where id = v_lesson) = '2eec2289-6a8a-5fb2-9988-e52433d5a242'::uuid then return; end if;  -- уже зроблено
  if (select unit_id from public.lessons where id = v_lesson) is distinct from 'e0fc94e0-c41d-5f59-adf7-db0c97c4575c'::uuid
     or (select count(*) from public.lessons where unit_id = '2eec2289-6a8a-5fb2-9988-e52433d5a242' and status = 'PUBLISHED') <> 10 then
    raise exception 'Урок 105 не в модулі A1.12 або в A1.8 не 10 уроків — звірте базу';
  end if;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'lesson', l.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = l.id), 0) + 1,
         to_jsonb(l), 'a1_dupes: урок «Надзвичайні ситуації» → модуль A1.8 «Здоров’я», після «Здоровий спосіб життя» (рішення власника 2026-11-17) — стара версія'
    from public.lessons l where l.id = v_lesson;
  update public.lessons set unit_id = '2eec2289-6a8a-5fb2-9988-e52433d5a242', order_index = 11 where id = v_lesson;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a1_dupes 20261117: план «Дублі й сенс уроків» (PR 3, рішення власника 2026-11-17) — урок «Надзвичайні ситуації» → модуль A1.8 «Здоров’я», після «Здоровий спосіб життя» (рішення власника 2026-11-17). Бета, потрібна перевірка носієм.');
end $$;

-- 6. Нові назви 9 діалогів з однаковими назвами (у пізнішому уроці; зміст інший); стара — у content_versions
do $$
begin
  if (select title_hr from public.conversations where id = '1515f889-130f-5476-8851-938106d3700a') = 'Tobogan i ljuljačka' then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a1_dupes: нова назва діалогу уроку A1 5 (така сама — в іншому уроці) — стара версія'
    from public.conversations c where c.id = '1515f889-130f-5476-8851-938106d3700a' and c.title_hr = 'Na igralištu' and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Na igralištu» уроку A1 5 — звірте базу'; end if;
  update public.conversations set title_ua = 'Гірка й гойдалка', title_hr = 'Tobogan i ljuljačka' where id = '1515f889-130f-5476-8851-938106d3700a';
end $$;
do $$
begin
  if (select title_hr from public.conversations where id = '6a218fb4-4e02-5825-8744-f5d9813cffa4') = 'Najkraćim putem' then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a1_dupes: нова назва діалогу уроку A1 35 (така сама — в іншому уроці) — стара версія'
    from public.conversations c where c.id = '6a218fb4-4e02-5825-8744-f5d9813cffa4' and c.title_hr = 'U taksiju' and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «U taksiju» уроку A1 35 — звірте базу'; end if;
  update public.conversations set title_ua = 'Найкоротшим шляхом', title_hr = 'Najkraćim putem' where id = '6a218fb4-4e02-5825-8744-f5d9813cffa4';
end $$;
do $$
begin
  if (select title_hr from public.conversations where id = '1344654b-470d-5676-b47e-b0001240b17d') = 'Stan s potkrovljem' then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a1_dupes: нова назва діалогу уроку A1 40 (така сама — в іншому уроці) — стара версія'
    from public.conversations c where c.id = '1344654b-470d-5676-b47e-b0001240b17d' and c.title_hr = 'Razgledavanje stana' and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Razgledavanje stana» уроку A1 40 — звірте базу'; end if;
  update public.conversations set title_ua = 'Квартира з мансардою', title_hr = 'Stan s potkrovljem' where id = '1344654b-470d-5676-b47e-b0001240b17d';
end $$;
do $$
begin
  if (select title_hr from public.conversations where id = '514923a7-f17e-52bd-bf86-ddfff3e51b51') = 'Garnitura na akciji' then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a1_dupes: нова назва діалогу уроку A1 42 (така сама — в іншому уроці) — стара версія'
    from public.conversations c where c.id = '514923a7-f17e-52bd-bf86-ddfff3e51b51' and c.title_hr = 'U trgovini namještajem' and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «U trgovini namještajem» уроку A1 42 — звірте базу'; end if;
  update public.conversations set title_ua = 'Кутовий диван зі знижкою', title_hr = 'Garnitura na akciji' where id = '514923a7-f17e-52bd-bf86-ddfff3e51b51';
end $$;
do $$
begin
  if (select title_hr from public.conversations where id = '14858aec-7921-527f-b3c3-e839da3fb494') = 'Tko gdje radi?' then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a1_dupes: нова назва діалогу уроку A1 50 (така сама — в іншому уроці) — стара версія'
    from public.conversations c where c.id = '14858aec-7921-527f-b3c3-e839da3fb494' and c.title_hr = 'Tko što radi?' and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Tko što radi?» уроку A1 50 — звірте базу'; end if;
  update public.conversations set title_ua = 'Хто де працює?', title_hr = 'Tko gdje radi?' where id = '14858aec-7921-527f-b3c3-e839da3fb494';
end $$;
do $$
begin
  if (select title_hr from public.conversations where id = '0a6b020d-ea8a-52dd-9cba-22cda92936e5') = 'Gdje ste radili prije?' then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a1_dupes: нова назва діалогу уроку A1 53 (така сама — в іншому уроці) — стара версія'
    from public.conversations c where c.id = '0a6b020d-ea8a-52dd-9cba-22cda92936e5' and c.title_hr = 'Razgovor za posao' and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Razgovor za posao» уроку A1 53 — звірте базу'; end if;
  update public.conversations set title_ua = 'Де ви працювали раніше?', title_hr = 'Gdje ste radili prije?' where id = '0a6b020d-ea8a-52dd-9cba-22cda92936e5';
end $$;
do $$
begin
  if (select title_hr from public.conversations where id = 'fe918e0d-21ff-5dc9-b37a-fbf2af2bfccd') = 'Mišići i zglobovi' then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a1_dupes: нова назва діалогу уроку A1 67 (така сама — в іншому уроці) — стара версія'
    from public.conversations c where c.id = 'fe918e0d-21ff-5dc9-b37a-fbf2af2bfccd' and c.title_hr = 'Poslije treninga' and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Poslije treninga» уроку A1 67 — звірте базу'; end if;
  update public.conversations set title_ua = 'М’язи й суглоби', title_hr = 'Mišići i zglobovi' where id = 'fe918e0d-21ff-5dc9-b37a-fbf2af2bfccd';
end $$;
do $$
begin
  if (select title_hr from public.conversations where id = 'b2e86525-a790-5cf3-87ce-734d9e063a43') = 'Dođi na moj rođendan!' then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a1_dupes: нова назва діалогу уроку A1 78 (така сама — в іншому уроці) — стара версія'
    from public.conversations c where c.id = 'b2e86525-a790-5cf3-87ce-734d9e063a43' and c.title_hr = 'Poziv na rođendan' and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Poziv na rođendan» уроку A1 78 — звірте базу'; end if;
  update public.conversations set title_ua = 'Приходь на мій день народження!', title_hr = 'Dođi na moj rođendan!' where id = 'b2e86525-a790-5cf3-87ce-734d9e063a43';
end $$;
do $$
begin
  if (select title_hr from public.conversations where id = 'b9fa04a2-e778-57c5-95d9-106b6058ad98') = 'Recite nam nešto o sebi' then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a1_dupes: нова назва діалогу уроку A1 106 (така сама — в іншому уроці) — стара версія'
    from public.conversations c where c.id = 'b9fa04a2-e778-57c5-95d9-106b6058ad98' and c.title_hr = 'Razgovor za posao' and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Razgovor za posao» уроку A1 106 — звірте базу'; end if;
  update public.conversations set title_ua = 'Розкажіть про себе', title_hr = 'Recite nam nešto o sebi' where id = 'b9fa04a2-e778-57c5-95d9-106b6058ad98';
end $$;

-- 7. Наскрізні номери всіх уроків A1 («Урок N: …» / «Lekcija N: …»); стара назва — у content_versions;
--    порядок діалогів уроків v3 (3000 + N·10 + k) — за новим номером
do $$
declare r record; v_payload jsonb; v_new_ua text; v_new_hr text;
begin
  for r in select l.id, l.title_ua, l.title_hr,
                  row_number() over (order by m.order_index, u.order_index, l.order_index) as n
             from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
            where m.level_code = 'A1' and l.status = 'PUBLISHED' loop
    update public.conversations set order_index = 3000 + r.n * 10 + order_index % 10
     where lesson_id = r.id and order_index between 3000 and 4999 and order_index / 10 <> 300 + r.n;
    v_new_ua := regexp_replace(r.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':');
    v_new_hr := regexp_replace(r.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':');
    if v_new_ua is not distinct from r.title_ua and v_new_hr is not distinct from r.title_hr then continue; end if;
    select to_jsonb(l) into v_payload from public.lessons l where l.id = r.id;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'a1_dupes: новий номер уроку ' || r.n || ' (урок 105 → A1.8, 3 нові уроки A1.11)');
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_lex int;
begin
  -- уроки A1: 111, номери 1…111 без пропусків; A1.8 — 11 уроків (105 → 76), A1.11 — 8, A1.12 — 7
  if (select count(*) from public.lessons where level_code = 'A1' and status = 'PUBLISHED') <> 111
     or exists (select 1 from (select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) n
                                 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                                where m.level_code = 'A1' and l.status = 'PUBLISHED') t
                 where t.title_ua !~ ('^Урок ' || t.n || ':') or t.title_hr !~ ('^Lekcija ' || t.n || ':')) then
    raise exception 'Уроки A1: очікувалось 111 з номерами 1…111';
  end if;
  if (select count(*) from public.lessons where unit_id = '2eec2289-6a8a-5fb2-9988-e52433d5a242' and status = 'PUBLISHED') <> 11
     or (select count(*) from public.lessons where unit_id = '1fb51162-343f-5587-89cf-d2594a3091db' and status = 'PUBLISHED') <> 8
     or (select count(*) from public.lessons where unit_id = 'e0fc94e0-c41d-5f59-adf7-db0c97c4575c' and status = 'PUBLISHED') <> 7
     or (select title_ua from public.lessons where id = '692e9310-7a5b-5adf-9f0a-a66b72fc5459') <> 'Урок 76: Надзвичайні ситуації'
     or (select count(*) from (values ('5ae02c5f-7ba1-5b59-be71-f744d6e9b169'::uuid, 'Урок 99: Символи й винаходи'), ('b026f1b1-879d-59b5-8506-ee99e128c9c1'::uuid, 'Урок 100: Фестивалі й карнавали'), ('8bb4331d-c7c0-5039-acf9-756684424039'::uuid, 'Урок 101: Казки й легенди')) t(id, title) join public.lessons l on l.id = t.id and l.title_ua = t.title) <> 3 then
    raise exception 'Модулі A1.8 / A1.11 / A1.12: очікувалось 11 / 8 / 7 уроків і нові номери';
  end if;
  -- діалоги уроків A1 v3: порядок 3000 + N·10 + k
  if exists (select 1 from public.conversations c join public.lessons l on l.id = c.lesson_id
              where l.level_code = 'A1' and l.status = 'PUBLISHED' and c.status = 'PUBLISHED'
                and c.order_index / 10 <> 300 + substring(l.title_ua from '^Урок ([0-9]+):')::int) then
    raise exception 'Порядок діалогів A1 не за номером уроку';
  end if;
  -- змінені й нові уроки: 2 опубліковані діалоги, 15 обов’язкових вправ (усі опубліковані)
  select count(*) into v_bad from public.lessons l
   where l.id in ('4d6f3498-2cc5-54a0-b4e4-c66add71ef12', '123e68fa-291f-5ad6-8403-51db7020d641', 'd9ef1de4-f4db-590e-bafd-474f84c8e03f', '11b565a4-1e2a-50d2-8d9d-c05e84371402', '5ae02c5f-7ba1-5b59-be71-f744d6e9b169', 'b026f1b1-879d-59b5-8506-ee99e128c9c1', '8bb4331d-c7c0-5039-acf9-756684424039')
     and ((select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and li.required) <> 15
          or exists (select 1 from public.lesson_items li join public.exercises e on e.id = li.item_id
                      where li.lesson_id = l.id and li.item_type = 'exercise' and e.status <> 'PUBLISHED'));
  if v_bad > 0 then raise exception 'Уроки пакета: % з неправильним складом', v_bad; end if;
  select count(*) into v_bad from public.lessons l where l.id in ('5ae02c5f-7ba1-5b59-be71-f744d6e9b169', 'b026f1b1-879d-59b5-8506-ee99e128c9c1', '8bb4331d-c7c0-5039-acf9-756684424039')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or exists (select 1 from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED'
                      and (select count(*) from public.conversation_turns t where t.conversation_id = c.id) <> 6));
  if v_bad > 0 then raise exception 'Нові уроки A1.11: % без 20–25 слів чи 6 реплік', v_bad; end if;
  -- прибраних слів більше немає в уроках A1; svjedodžba — в A2-11, porez і platna lista — в A2-34
  if exists (select 1 from public.lesson_items li join public.lessons l on l.id = li.lesson_id and l.level_code = 'A1' and l.status = 'PUBLISHED'
              join public.lexemes x on x.id = li.item_id where li.item_type = 'lexeme' and lower(x.lemma) in ('bruto', 'doprinosi', 'katedrala', 'lijek protiv bolova', 'neto', 'platna lista', 'polagati', 'položiti', 'porez', 'priznavanje', 'svjedodžba', 'tableta', 'uvjerenje', 'zidine')) then
    raise exception 'Прибрані слова ще в уроках A1';
  end if;
  if (select count(*) from public.lesson_items li join public.lexemes x on x.id = li.item_id
       where li.item_type = 'lexeme' and ((li.lesson_id = 'dd6c5f39-f66e-5acb-8255-932f822ddcc5' and lower(x.lemma) = 'svjedodžba')
          or (li.lesson_id = 'b9bcea21-08a3-56cf-be72-edf6b6c7b03f' and lower(x.lemma) in ('porez', 'platna lista')))) <> 3 then
    raise exception 'A2-11 / A2-34: немає слів з уроків A1';
  end if;
  -- нові слова: опубліковані, з мітками; рівні слів
  select count(*) into v_lex from public.lexemes where lower(lemma) in ('potpisati ugovor', 'raditi vikendom', 'opis posla', 'uvjeti rada', 'prije jela', 'dvaput dnevno', 'gotički', 'renesansni', 'simbol', 'šahovnica', 'grb', 'crveno-bijeli', 'vezati kravatu', 'dan kravate', 'marama', 'izumiti', 'patent', 'tehnička olovka', 'nalivpero', 'padobran', 'dalmatinac', 'svjetski poznat', 'karneval', 'maškare', 'poklade', 'pepelnica', 'kostim', 'maskirati se', 'prerušiti se', 'gusar', 'povorka', 'zvončari', 'ovčja koža', 'rog', 'tjerati', 'spaliti', 'maskenbal', 'konfeti', 'bubanj', 'nastupati', 'šaliti se', 'legenda', 'pripovijedati', 'bilo jednom', 'za laku noć', 'kraljević', 'kraljevna', 'vila', 'zmaj', 'vještica', 'div', 'patuljak', 'čarobni', 'čarolija', 'začarati', 'pretvoriti se', 'zao', 'dobrota', 'pouka', 'sretan kraj') and status = 'PUBLISHED'
     and register is not null and regionality is not null and usage_tags is not null;
  if v_lex <> 60 then raise exception 'Нових слів: % (очікувалось 60)', v_lex; end if;
  if exists (select 1 from public.lexemes where lower(lemma) in ('kravata', 'vojnik', 'izum', 'izumitelj', 'znanstvenik', 'otkriće', 'slavan', 'ponos', 'ples', 'šala', 'smijeh', 'priča', 'junak', 'hrabar', 'zlo', 'rječnik', 'vježba', 'ugovor o radu', 'upisati se', 'test razine', 'početni tečaj') and status = 'PUBLISHED' and cefr <> 'A1')
     or exists (select 1 from public.lexemes where lower(lemma) in ('polagati', 'položiti', 'uvjerenje', 'svjedodžba', 'porez', 'platna lista') and status = 'PUBLISHED' and cefr <> 'A2') then
    raise exception 'Рівні слів: наявні слова нових уроків — не A1 або прибрані — не A2';
  end if;
  -- діалоги — нові назви, без повторів назв в A1
  if (select count(*) from (values ('1515f889-130f-5476-8851-938106d3700a'::uuid, 'Tobogan i ljuljačka'), ('6a218fb4-4e02-5825-8744-f5d9813cffa4'::uuid, 'Najkraćim putem'), ('1344654b-470d-5676-b47e-b0001240b17d'::uuid, 'Stan s potkrovljem'), ('514923a7-f17e-52bd-bf86-ddfff3e51b51'::uuid, 'Garnitura na akciji'), ('14858aec-7921-527f-b3c3-e839da3fb494'::uuid, 'Tko gdje radi?'), ('0a6b020d-ea8a-52dd-9cba-22cda92936e5'::uuid, 'Gdje ste radili prije?'), ('fe918e0d-21ff-5dc9-b37a-fbf2af2bfccd'::uuid, 'Mišići i zglobovi'), ('b2e86525-a790-5cf3-87ce-734d9e063a43'::uuid, 'Dođi na moj rođendan!'), ('b9fa04a2-e778-57c5-95d9-106b6058ad98'::uuid, 'Recite nam nešto o sebi')) t(id, title) join public.conversations c on c.id = t.id and c.title_hr = t.title) <> 9 then
    raise exception 'Діалоги не перейменовано';
  end if;
  if exists (select 1 from public.conversations c join public.lessons l on l.id = c.lesson_id and l.level_code = 'A1' and l.status = 'PUBLISHED'
              where c.status = 'PUBLISHED' group by lower(c.title_hr) having count(*) > 1) then
    raise exception 'Однакові назви діалогів в A1';
  end if;
  raise notice 'Готово: 20261117_a1_dupes_1_lessons.sql — 3 нові уроки A1.11, урок 105 → A1.8 (76), уроки 54, 70, 93, 101 без дублів, 60 нових слів, 9 назв діалогів, уроків A1 — 111';
end $$;

commit;
