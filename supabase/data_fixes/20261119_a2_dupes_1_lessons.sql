-- =====================================================================
-- Дублі A2 · 2026-11-19 (план «Дублі й сенс уроків A0–A2», PR 4)
-- Згенеровано: python3 -B scripts/gen_a2_dupes.py (не редагуйте вручну).
--
-- Рішення власника 2026-11-17: Д1 (урок 27), Д2 (9), Д5 (38), Д6 (29), Д7 (70), Д8 (33 і 44) + назва уроку 33;
-- новий урок A2.11 «Далмація: Задар і околиці» (стане 70); 6 назв діалогів. Уроків A2 86 → 87.
--   * Нові слова: 43 (з мітками); наявні без уроку — 4 (рівень → A2).
--   * Слово в уроці — заміна на тому самому місці; вправи на прибрані слова й діалоги — нові на тому самому місці.
--   * otvoriti / zatvoriti bolovanje, javiti se bolestan — з уроку 33 в урок 44 (слово не зникає з курсу).
--   * Нічого не видаляється: старі діалоги й вправи → DEPRECATED; копія складу уроків — backup.lesson_items_a2dupes_20261119;
--     старі версії уроків, діалогів і слів — у content_versions. Прогрес користувачів не змінюється.
--   * Далі за назвою: 20261119_a2_dupes_2_tests_*.sql (перевірки рівнів A1 і A2 наново).
--   * Повторний запуск нічого не змінює. Бета: PUBLISHED.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: 20261119_a2_dupes_1_lessons.sql — …».
-- =====================================================================

begin;

-- 0. Копія складу уроків до змін (схема backup без доступу для anon / authenticated)
create schema if not exists backup;
create table if not exists backup.lesson_items_a2dupes_20261119 (like public.lesson_items including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'lesson_items_a2dupes_20261119_pkey') then
    alter table backup.lesson_items_a2dupes_20261119 add constraint lesson_items_a2dupes_20261119_pkey primary key (id);
  end if;
end $$;
revoke all on backup.lesson_items_a2dupes_20261119 from anon, authenticated;

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

create or replace function pg_temp.ex_task(p_lesson uuid, p_pos int, p_id uuid, p_type text, p_question text, p_answer text,
                                           p_level text, p_status text, p_task jsonb, p_required boolean, p_skill text) returns int language plpgsql as $f$
begin
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, task)
  values (p_id, p_type, p_question, p_answer, null, p_level, 0, p_status, p_task) on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, required, target_skill)
  values (p_lesson, 'exercise', p_id, p_pos + 1, p_required, p_skill);
  return p_pos + 1;
end $f$;

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
                                           p_options jsonb, p_lemma text, p_task jsonb) returns void language plpgsql as $f$
declare v_lex uuid; v_n int;
begin
  if p_lemma is not null then
    select id into v_lex from public.lexemes where lower(lemma) = lower(p_lemma) and status = 'PUBLISHED' order by created_at limit 1;
    if v_lex is null then raise exception 'Немає опублікованого слова «%»', p_lemma; end if;
  end if;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id, task)
  select p_new, p_type, p_question, p_answer, p_options, e.level, e.order_index, 'PUBLISHED', v_lex, p_task
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
  insert into backup.lesson_items_a2dupes_20261119 select li.* from public.lesson_items li where li.lesson_id = p_lesson on conflict (id) do nothing;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'lesson', l.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = l.id), 0) + 1,
         jsonb_build_object('lesson', to_jsonb(l),
           'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = l.id),
           'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c
                              where c.lesson_id = l.id and c.status = 'PUBLISHED')), p_reason
    from public.lessons l where l.id = p_lesson;
end $f$;

-- 1. Нові слова (43): PUBLISHED (бета), з мітками (đir — розмовне, Далмація, італізм); наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples,
                            ukrainian_interference, register, regionality, usage_tags, standard_lexeme_id, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A2', t.ua, t.vtype, t.forms, t.examples, t.interference,
       t.register, t.regionality, array(select jsonb_array_elements_text(t.usage_tags)),
       (select s.id from public.lexemes s where lower(s.lemma) = lower(t.standard) and s.status = 'PUBLISHED' order by s.created_at limit 1),
       'PUBLISHED', 'claude_a2_dupes'
  from jsonb_to_recordset('[{"lemma": "uvjerljiv", "normalized": "uvjerljiv", "pos": "adjective", "ua": "переконливий", "vtype": "core", "forms": {}, "examples": ["Tvoj argument nije baš uvjerljiv."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "popustiti", "normalized": "popustiti", "pos": "verb", "ua": "поступитися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "popuštati"}, "examples": ["Na kraju je šef popustio i pristao na kompromis."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "inzistirati", "normalized": "inzistirati", "pos": "verb", "ua": "наполягати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Zašto stalno inzistiraš na svome?"], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "opravdan", "normalized": "opravdan", "pos": "adjective", "ua": "обґрунтований, виправданий", "vtype": "core", "forms": {}, "examples": ["Mislim da je tvoj zahtjev potpuno opravdan."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "razina znanja", "normalized": "razina znanja", "pos": "phrase", "ua": "рівень знань", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na kraju tečaja provjeravamo razinu znanja."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "konverzacija", "normalized": "konverzacija", "pos": "noun", "ua": "розмовна практика", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Utorkom imamo sat konverzacije."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "zaostajati", "normalized": "zaostajati", "pos": "verb", "ua": "відставати", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "zaostati"}, "examples": ["Ne želim zaostajati za grupom."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "samostalno učiti", "normalized": "samostalno uciti", "pos": "phrase", "ua": "вчитися самостійно", "vtype": "chunk", "forms": {}, "examples": ["Kod kuće samostalno učim nove riječi."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "procuriti", "normalized": "procuriti", "pos": "verb", "ua": "протекти", "vtype": "core", "forms": {"aspect": "pfv"}, "examples": ["Voda je procurila kroz strop u kupaonici."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "fasada", "normalized": "fasada", "pos": "noun", "ua": "фасад", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Fasada zgrade je stara i treba je obnoviti."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "popravak krova", "normalized": "popravak krova", "pos": "phrase", "ua": "ремонт даху", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Na sastanku stanara dogovorili smo popravak krova."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "nadoknada štete", "normalized": "nadoknada stete", "pos": "phrase", "ua": "відшкодування збитків", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Susjed je platio nadoknadu štete za poplavljenu kupaonicu."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "zamjena smjene", "normalized": "zamjena smjene", "pos": "phrase", "ua": "обмін змінами", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Kolega me pitao za zamjenu smjene u subotu."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "kolektivni godišnji odmor", "normalized": "kolektivni godisnji odmor", "pos": "phrase", "ua": "колективна відпустка (уся фірма)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["U kolovozu je u tvrtki kolektivni godišnji odmor."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "prenijeti dane", "normalized": "prenijeti dane", "pos": "phrase", "ua": "перенести дні (відпустки)", "vtype": "chunk", "forms": {}, "examples": ["Neiskorištene dane mogu prenijeti u iduću godinu."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "pravo na godišnji", "normalized": "pravo na godisnji", "pos": "phrase", "ua": "право на відпустку", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Svaki radnik ima pravo na godišnji od najmanje četiri tjedna."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "rok završetka", "normalized": "rok zavrsetka", "pos": "phrase", "ua": "термін завершення (робіт)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Koji je rok završetka radova u kupaonici?"], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "kašnjenje radova", "normalized": "kasnjenje radova", "pos": "phrase", "ua": "затримка робіт", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Zbog kiše je došlo do kašnjenja radova."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "plaćanje gotovinom", "normalized": "placanje gotovinom", "pos": "phrase", "ua": "оплата готівкою", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Je li moguće plaćanje gotovinom ili samo karticom?"], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "gostoprimstvo", "normalized": "gostoprimstvo", "pos": "noun", "ua": "гостинність", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Hvala vam na gostoprimstvu!"], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "nutkati", "normalized": "nutkati", "pos": "verb", "ua": "припрошувати (їсти, пити)", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Domaćica nas je cijelu večer nutkala kolačima."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "zadarski", "normalized": "zadarski", "pos": "adjective", "ua": "задарський", "vtype": "core", "forms": {}, "examples": ["Zadarska riva je najljepša pri zalasku sunca."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "solana", "normalized": "solana", "pos": "noun", "ua": "солеварня", "vtype": "core", "forms": {"gender": "f"}, "examples": ["U Ninu je stara solana u kojoj se sol i danas skuplja ručno."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "ljekovito blato", "normalized": "ljekovito blato", "pos": "phrase", "ua": "лікувальна грязь", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Ljudi dolaze u Nin zbog ljekovitog blata."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "crkvica", "normalized": "crkvica", "pos": "noun", "ua": "церковця, маленька церква", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Na brdu iznad sela je mala kamena crkvica."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "kraljevski grad", "normalized": "kraljevski grad", "pos": "phrase", "ua": "королівське місто", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Nin je stari hrvatski kraljevski grad."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "starohrvatski", "normalized": "starohrvatski", "pos": "adjective", "ua": "давньохорватський", "vtype": "core", "forms": {}, "examples": ["U muzeju su izloženi starohrvatski nakit i oružje."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "arheološko nalazište", "normalized": "arheolosko nalaziste", "pos": "phrase", "ua": "археологічна пам’ятка (місце розкопок)", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Pokraj crkve je veliko arheološko nalazište."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "penjač", "normalized": "penjac", "pos": "noun", "ua": "скелелаз", "vtype": "core", "forms": {"gender": "m"}, "examples": ["U proljeće u Paklenicu dolaze penjači iz cijele Europe."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "penjalište", "normalized": "penjaliste", "pos": "noun", "ua": "місце для скелелазіння", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Penjalište je samo deset minuta od parkirališta."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "stijena", "normalized": "stijena", "pos": "noun", "ua": "скеля", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Penjač se polako penje uz stijenu."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "uže", "normalized": "uze", "pos": "noun", "ua": "мотузка (страхувальна)", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Bez užeta i kacige ne smiješ se penjati."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": "не «вуж» і не «вже»: uže — мотузка", "standard": null}, {"lemma": "slobodno penjanje", "normalized": "slobodno penjanje", "pos": "phrase", "ua": "скелелазіння", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Slobodno penjanje je popularno u Paklenici."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "marina", "normalized": "marina", "pos": "noun", "ua": "марина (пристань для яхт)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Biograd ima veliku marinu punu jedrilica."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": "не жіноче ім’я: marina — пристань для яхт", "standard": null}, {"lemma": "izletnički brod", "normalized": "izletnicki brod", "pos": "phrase", "ua": "прогулянковий корабель", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Izletnički brod polazi u devet ujutro."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "cjelodnevni izlet", "normalized": "cjelodnevni izlet", "pos": "phrase", "ua": "одноденна екскурсія", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Cjelodnevni izlet na Kornate traje do šest navečer."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "ribarska brodica", "normalized": "ribarska brodica", "pos": "phrase", "ua": "рибальський човен", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U luci su ribarske brodice i jahte."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "ulov", "normalized": "ulov", "pos": "noun", "ua": "улов", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ribari prodaju jutarnji ulov na ribarnici."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "turistička sezona", "normalized": "turisticka sezona", "pos": "phrase", "ua": "туристичний сезон", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za vrijeme turističke sezone Zadar je pun ljudi."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "izvan sezone", "normalized": "izvan sezone", "pos": "phrase", "ua": "поза сезоном", "vtype": "chunk", "forms": {}, "examples": ["Izvan sezone su cijene smještaja niže."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "tempo života", "normalized": "tempo zivota", "pos": "phrase", "ua": "темп життя", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["U Zadru je tempo života sporiji nego u Zagrebu."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "sezonski posao", "normalized": "sezonski posao", "pos": "phrase", "ua": "сезонна робота", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Mnogi studenti ljeti rade sezonski posao na moru."], "register": "standard", "regionality": "general", "usage_tags": [], "interference": null, "standard": null}, {"lemma": "đir", "normalized": "dir", "pos": "noun", "ua": "прогулянка (щоб розвіятися)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Navečer idemo na đir po rivi."], "register": "colloquial", "regionality": "Dalmatia", "usage_tags": ["italianism"], "interference": "розмовне далматинське слово (з італ. giro); нейтрально — šetnja; ići na đir — піти прогулятися", "standard": null}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb, interference text,
         register text, regionality text, usage_tags jsonb, standard text)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 1а. Наявні слова без уроку (4), які тепер учать в уроках A2: рівень — A2; стара версія — у content_versions
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) in ('dokaz', 'ispravljati', 'sudjelovati', 'morska sol') and status = 'PUBLISHED' and cefr is distinct from 'A2' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'a2_dupes: рівень слова A2 — його вперше вчать в уроці A2 — стара версія');
    update public.lexemes set cefr = 'A2', version = version + 1 where id = r.id;
  end loop;
end $$;

-- 2. Урок 33 (стане 33): лікарняний — в уроці «Лікарняний для себе й для дитини», урок 33 — «Відпустка й вихідні дні»; симптоми — в A1-74 (Д8)
do $$
declare
  v_lesson constant uuid := '0e0d07a2-2a6c-5090-ab84-3089f20a48b8';
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = 'zamjena smjene') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a2_dupes: лікарняний — в уроці «Лікарняний для себе й для дитини», урок 33 — «Відпустка й вихідні дні»; симптоми — в A1-74 (Д8) — стара версія');
  perform pg_temp.swap_word(v_lesson, 'otvoriti bolovanje', 'zamjena smjene');
  perform pg_temp.swap_word(v_lesson, 'zatvoriti bolovanje', 'kolektivni godišnji odmor');
  perform pg_temp.swap_word(v_lesson, 'biti na bolovanju', 'prenijeti dane');
  perform pg_temp.swap_word(v_lesson, 'javiti se bolestan', 'pravo na godišnji');
  perform pg_temp.swap_ex(v_lesson, '3933abb2-38b2-53ce-ba8b-a332fc8ce8f5', '5e9999cd-848c-5aa3-a889-fb00e714b652', 'multiple_choice', 'Що означає «zahtjev za godišnji»?', 'заява на відпустку', '["заява на відпустку", "право на відпустку", "передача справ", "відпустка по догляду за дитиною"]'::jsonb, 'zahtjev za godišnji', null);
  perform pg_temp.swap_ex(v_lesson, '4fe32f23-4220-52b8-9da8-8b62616c915d', '178270c6-58c9-519a-9da4-71184a0f3547', 'multiple_choice', 'Що означає «rodiljni dopust»?', 'декретна відпустка (у пологах)', '["обмін змінами", "дні відпустки", "погодити заяву", "декретна відпустка (у пологах)"]'::jsonb, 'rodiljni dopust', null);
  perform pg_temp.swap_ex(v_lesson, '89355606-2d62-5afa-b223-5df7cf556ae4', '016585ee-decc-5dc1-8f0a-14e9f0b527f0', 'multiple_choice', 'Як хорватською «обмін змінами»?', 'zamjena smjene', '["vratiti se na posao", "primopredaja", "neplaćeni dopust", "zamjena smjene"]'::jsonb, 'zamjena smjene', null);
  perform pg_temp.swap_ex(v_lesson, 'cb1c5220-ae32-5b8e-8edf-3a683e0ff57f', 'c6c3b0c7-63c6-5491-87aa-467dcce134e7', 'sentence_builder', 'Складіть: «У серпні в нас колективна відпустка.»', 'U kolovozu imamo kolektivni godišnji odmor.', '["godišnji", "kolovozu", "imamo", "kolektivni", "odmor.", "U"]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, 'fa827041-d737-510c-866f-4f4db2d931e0', 'bfa5f369-4c89-557e-9c97-bf0c42352273', 'listening', 'Прослухайте і складіть фразу', 'Prva dva tjedna u kolovozu. Tvrtka je tada zatvorena.', '["u", "je", "zatvorena.", "kolovozu.", "Tvrtka", "Prva", "dva", "tada", "tjedna"]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, '44cce3d0-24f1-5c18-83ee-3e5d84d51e85', 'ad447225-cfb7-5892-9d47-15139d1ddc97', 'speaking', 'Я хочу перенести дні на наступний рік.', 'Želim prenijeti dane u iduću godinu.', null, null, null);
  perform pg_temp.swap_ex(v_lesson, '032b0d9b-5a28-54d5-81fb-2f2a1e307310', '03333f71-e37f-5388-8b1b-59d1829c75a5', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Moja kolegica želi prenijeti preostale dane godišnjeg u iduću godinu.', null, null, '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи шефу, що я хочу перенести решту днів відпустки на наступний рік.", "direction": "ua_hr", "points": [{"ua": "перенести", "keys": [["prenije"], ["prenes"]]}, {"ua": "решту днів", "keys": [["preostal"], ["dan"]]}, {"ua": "наступний рік", "keys": [["iduć"], ["sljedeć"]]}], "hints": [], "models": ["Moja kolegica želi prenijeti preostale dane godišnjeg u iduću godinu."], "source_ua": "Скажи шефу, що я хочу перенести решту днів відпустки на наступний рік."}'::jsonb);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '03333f71-e37f-5388-8b1b-59d1829c75a5', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a2_dupes 20261119: нова вправа «mediation» в уроці A2 замість старої (план «Дублі», PR 4). Бета, потрібна перевірка носієм.');
  -- діалог «Bolesna sam» → «Godišnji u kolovozu» (старий — DEPRECATED, не видаляється)
  update public.conversations set status = 'DEPRECATED' where id = 'b5b1477b-4b6a-54e0-84a7-be89bf1dd927' and status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Bolesna sam» — звірте базу'; end if;
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  -- source — цього пакета (діалоги програми A2 v2 рахує тест a2_v2_dialogues); звідки діалог — у content_reviews
  values ('63409fed-be8f-5f65-b117-0826cec5b436', v_lesson, 'Відпустка в серпні', 'Godišnji u kolovozu', 5332, 'A2', 'work', 'PUBLISHED', 'claude_a2_dupes');
  perform pg_temp.turn('d07e2844-a4a7-5e48-92bc-b4ce5031b611', '63409fed-be8f-5f65-b117-0826cec5b436', 'Daša', 'Ivane, znaš li kad je ove godine kolektivni godišnji odmor?', 'Іване, знаєш, коли цього року колективна відпустка?', 1);
  perform pg_temp.turn('18c03add-1bbe-5c27-befc-cca506895006', '63409fed-be8f-5f65-b117-0826cec5b436', 'Ivan', 'Prva dva tjedna u kolovozu. Tvrtka je tada zatvorena.', 'Перші два тижні серпня. Фірма тоді зачинена.', 2);
  perform pg_temp.turn('fadda0d9-1225-5619-99ce-ce27b812b97a', '63409fed-be8f-5f65-b117-0826cec5b436', 'Daša', 'Super. A imam još pet dana od prošle godine.', 'Супер. А в мене ще п’ять днів з минулого року.', 3);
  perform pg_temp.turn('aae0c831-4eb0-50f8-ac99-6d9625bfcdd1', '63409fed-be8f-5f65-b117-0826cec5b436', 'Ivan', 'Prenesene dane moraš iskoristiti do kraja lipnja.', 'Перенесені дні треба використати до кінця червня.', 4);
  perform pg_temp.turn('f2df46a8-ba63-5eba-8d9e-a9f2d5a95805', '63409fed-be8f-5f65-b117-0826cec5b436', 'Daša', 'Onda ću uzeti produženi vikend u svibnju. A tko radi umjesto mene u subotu?', 'Тоді візьму довгі вихідні в травні. А хто працює замість мене в суботу?', 5);
  perform pg_temp.turn('051880fa-3dbb-5435-bf5c-67a63d7e37b5', '63409fed-be8f-5f65-b117-0826cec5b436', 'Ivan', 'Mogu ja. Dogovorit ćemo zamjenu smjene.', 'Можу я. Домовимося про обмін змінами.', 6);
  update public.lessons set objectives = '["Попросити відпустку й домовитися про заміну чи обмін змінами", "Колективна відпустка, перенесені дні, право на відпустку", "Ввічливо: Bih li mogla uzeti…? Htjela bih iskoristiti…"]'::jsonb where id = v_lesson;
  update public.lessons set title_ua = regexp_replace(title_ua, ':.*$', '') || ': Відпустка й вихідні дні', title_hr = regexp_replace(title_hr, ':.*$', '') || ': Godišnji odmor i slobodni dani' where id = v_lesson;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a2_dupes 20261119: план «Дублі й сенс уроків» (PR 4, рішення власника 2026-11-17) — лікарняний — в уроці «Лікарняний для себе й для дитини», урок 33 — «Відпустка й вихідні дні»; симптоми — в A1-74 (Д8). Бета, потрібна перевірка носієм.');
end $$;

-- 2. Урок 44 (стане 44): лікарняний — в уроці «Лікарняний для себе й для дитини», урок 33 — «Відпустка й вихідні дні»; симптоми — в A1-74 (Д8)
do $$
declare
  v_lesson constant uuid := '8f08356b-8efa-5ebc-906e-f409fbaadaf3';
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = 'otvoriti bolovanje') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a2_dupes: лікарняний — в уроці «Лікарняний для себе й для дитини», урок 33 — «Відпустка й вихідні дні»; симптоми — в A1-74 (Д8) — стара версія');
  perform pg_temp.swap_word(v_lesson, 'povraćati', 'otvoriti bolovanje');
  perform pg_temp.swap_word(v_lesson, 'proljev', 'zatvoriti bolovanje');
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill)
  select v_lesson, 'lexeme', (select id from public.lexemes where lower(lemma) = 'javiti se bolestan' and status = 'PUBLISHED' order by created_at limit 1),
         (select max(order_index) + 1 from public.lesson_items where lesson_id = v_lesson), 'vocabulary';
  perform pg_temp.swap_ex(v_lesson, '0f68557e-c40a-5543-9835-713a4bd94ef2', '0b91b118-9724-5e9c-a873-ad1fbce341ab', 'multiple_choice', 'Що означає «potvrda o privremenoj nesposobnosti»?', 'довідка про тимчасову непрацездатність', '["довідка про тимчасову непрацездатність", "мене нудить", "пити багато рідини", "закрити лікарняний"]'::jsonb, 'potvrda o privremenoj nesposobnosti', null);
  perform pg_temp.swap_ex(v_lesson, 'f1004126-af99-509a-9cd7-55759a6f506e', 'f1d95ad3-76cf-5981-85c7-3c1af1480a35', 'multiple_choice', 'Як хорватською «заразний»?', 'zarazan', '["javiti poslodavcu", "vratiti se u vrtić", "otvoriti bolovanje", "zarazan"]'::jsonb, 'zarazan', null);
  perform pg_temp.swap_ex(v_lesson, '57ca405f-77bf-5a2c-ae93-09e3d1ccf483', '106ef7b8-2f7e-5b12-9331-d3f2f2a86fcf', 'multiple_choice', 'Як хорватською «закрити лікарняний»?', 'zatvoriti bolovanje', '["zatvoriti bolovanje", "ležati", "njega djeteta", "dehidracija"]'::jsonb, 'zatvoriti bolovanje', null);
  perform pg_temp.swap_ex(v_lesson, 'e66efeb9-c461-5be9-a5f6-4c78b5c94dc0', '225286b1-b837-55c9-899e-a3eb2aa0d366', 'type_answer', 'Напишіть хорватською: «дитяча лікарка, педіатриня»', 'pedijatrica', null, 'pedijatrica', null);
  -- діалог «Dijete je bolesno» → «Ispričnica za vrtić» (старий — DEPRECATED, не видаляється)
  update public.conversations set status = 'DEPRECATED' where id = 'c590ba13-4ead-5ddf-a528-f7ed37bbf8be' and status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Dijete je bolesno» — звірте базу'; end if;
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  -- source — цього пакета (діалоги програми A2 v2 рахує тест a2_v2_dialogues); звідки діалог — у content_reviews
  values ('dd11587e-50d1-5248-ae83-814f102c46a9', v_lesson, 'Довідка для садочка', 'Ispričnica za vrtić', 5441, 'A2', 'health', 'PUBLISHED', 'claude_a2_dupes');
  perform pg_temp.turn('ad63b809-8137-514d-9e04-4f5b860eab0d', 'dd11587e-50d1-5248-ae83-814f102c46a9', 'Darja', 'Dobar dan, Filip je bio bolestan tjedan dana. Danas mu je bolje.', 'Добрий день, Філіп хворів тиждень. Сьогодні йому краще.', 1);
  perform pg_temp.turn('7437f778-6266-52a2-acaa-026320ad945c', 'dd11587e-50d1-5248-ae83-814f102c46a9', 'Pedijatrica', 'Drago mi je. Ima li još temperaturu?', 'Я рада. У нього ще є температура?', 2);
  perform pg_temp.turn('927e0bcd-8604-5363-9bad-43aaf21592b6', 'dd11587e-50d1-5248-ae83-814f102c46a9', 'Darja', 'Nema već dva dana. Može li se vratiti u vrtić?', 'Уже два дні немає. Він може повернутися в садочок?', 3);
  perform pg_temp.turn('85bf3733-d604-5b69-92a2-586e5559fefd', 'dd11587e-50d1-5248-ae83-814f102c46a9', 'Pedijatrica', 'Može od ponedjeljka. Evo ispričnice za vrtić.', 'Може з понеділка. Ось довідка для садочка.', 4);
  perform pg_temp.turn('742abf65-c2ab-5560-8c49-1b4253b0b46e', 'dd11587e-50d1-5248-ae83-814f102c46a9', 'Darja', 'Hvala. Moram li i ja nešto napraviti zbog posla?', 'Дякую. Мені теж треба щось зробити через роботу?', 5);
  perform pg_temp.turn('b3d60888-5c51-5a4a-9537-090d9fb17263', 'dd11587e-50d1-5248-ae83-814f102c46a9', 'Pedijatrica', 'Da, Vaša liječnica Vam mora zatvoriti bolovanje radi njege djeteta.', 'Так, ваша лікарка має закрити вам лікарняний по догляду за дитиною.', 6);
  update public.lessons set objectives = '["Оформити лікарняний для себе й по догляду за дитиною: otvoriti, zatvoriti, produžiti bolovanje", "Описати стан безособово: Muka mi je, Djetetu je loše"]'::jsonb where id = v_lesson;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a2_dupes 20261119: план «Дублі й сенс уроків» (PR 4, рішення власника 2026-11-17) — лікарняний — в уроці «Лікарняний для себе й для дитини», урок 33 — «Відпустка й вихідні дні»; симптоми — в A1-74 (Д8). Бета, потрібна перевірка носієм.');
end $$;

-- 2. Урок 9 (стане 9): урок «Курси хорватської для дорослих» — уже на курсі: прогрес, розмовна практика, довідка; запис на курс — в A1-105 (Д2)
do $$
declare
  v_lesson constant uuid := '8190831a-549a-544a-962b-4f716a895a32';
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = 'razina znanja') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a2_dupes: урок «Курси хорватської для дорослих» — уже на курсі: прогрес, розмовна практика, довідка; запис на курс — в A1-105 (Д2) — стара версія');
  perform pg_temp.swap_word(v_lesson, 'početni tečaj', 'razina znanja');
  perform pg_temp.swap_word(v_lesson, 'napredni tečaj', 'konverzacija');
  perform pg_temp.swap_word(v_lesson, 'test razine', 'zaostajati');
  perform pg_temp.swap_word(v_lesson, 'polaznica', 'sudjelovati');
  perform pg_temp.swap_word(v_lesson, 'upisivati', 'ispravljati');
  perform pg_temp.swap_word(v_lesson, 'upisati se', 'samostalno učiti');
  perform pg_temp.swap_ex(v_lesson, '05c4ce9e-0414-5c04-8d93-45b119affa25', 'c7f64ebb-1100-5941-9dad-26f3bb2a14a7', 'fill_in_the_blank', 'Cijelu večer sam ___ pogreške u zadaći.', 'ispravljala', '["ispravila", "ispravljati", "ispravljala", "ispraviti"]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, '2c3aec36-59c4-59f5-a625-68cfa78bf51f', 'cc01ace2-a1b6-5b34-b6ce-8a9cf9b9b92c', 'multiple_choice', 'Що означає «napredovati»?', 'робити успіхи, прогресувати', '["вчитися самостійно", "плата за навчання", "рівень знань", "робити успіхи, прогресувати"]'::jsonb, 'napredovati', null);
  perform pg_temp.swap_ex(v_lesson, '4d736369-6ec9-5ac5-8461-e1c51b36f561', 'bbd63297-c0e0-5d2e-9075-0f6985f49c68', 'multiple_choice', 'Що означає «plaćanje u ratama»?', 'оплата частинами', '["розмовна практика", "відставати", "оплата частинами", "вимова"]'::jsonb, 'plaćanje u ratama', null);
  perform pg_temp.swap_ex(v_lesson, '1abc433f-aa10-5b83-8d77-e536f2da0c47', '54c3aef5-28be-565a-ae98-3e285f2681de', 'multiple_choice', 'Як хорватською «розмовна практика»?', 'konverzacija', '["izgovor", "konverzacija", "školarina", "mala grupa"]'::jsonb, 'konverzacija', null);
  perform pg_temp.swap_ex(v_lesson, 'c176dd59-83df-5740-84d1-d39ca51088c9', 'a9462d8a-b500-5cba-872d-a9fe3f2372ee', 'multiple_choice', 'Як хорватською «вимова»?', 'izgovor', '["izgovor", "večernji tečaj", "sudjelovati", "razina znanja"]'::jsonb, 'izgovor', null);
  perform pg_temp.swap_ex(v_lesson, '7b984002-c2a7-51b4-a1cd-f51e5b47ff7a', 'e40b3cf6-4315-5213-96c4-9873e0793174', 'listening', 'Прослухайте і складіть фразу', 'Hoćete li me ispravljati kad pogriješim?', '["kad", "me", "ispravljati", "Hoćete", "li", "pogriješim?"]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, 'af36c356-7b25-5474-be5c-4a507a3e97a5', '7a66a4a9-c421-5590-8ed9-c2efd941a4b4', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'довідка про відвідування; з понеділка до п’ятниці, з 10 до 16; посвідчення особи', null, null, '{"kind": "voicemail", "situation_ua": "Мовна школа залишила вам повідомлення.", "script": [{"hr": "Dobar dan, ovdje škola stranih jezika Lingua.", "ua": "Добрий день, це школа іноземних мов «Лінгва»."}, {"hr": "Vaša potvrda o pohađanju je gotova, možete je podići u tajništvu.", "ua": "Ваша довідка про відвідування готова, можете забрати її в секретаріаті."}, {"hr": "Tajništvo radi od ponedjeljka do petka, od deset do šesnaest sati.", "ua": "Секретаріат працює з понеділка до п’ятниці, з десятої до шістнадцятої."}, {"hr": "Za potvrdu ponesite osobnu iskaznicu.", "ua": "По довідку візьміть із собою посвідчення особи."}], "questions": [{"q_ua": "Що готово?", "options": ["сертифікат про рівень", "довідка про відвідування", "розклад занять"], "correct": 1, "answer_turn": 1}, {"q_ua": "Коли працює секретаріат?", "options": ["лише в суботу", "щодня з 8 до 20", "з понеділка до п’ятниці, з 10 до 16"], "correct": 2, "answer_turn": 2}, {"q_ua": "Що треба взяти із собою?", "options": ["посвідчення особи", "фотографію", "квитанцію про оплату"], "correct": 0, "answer_turn": 3}], "max_plays": 3}'::jsonb);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '7a66a4a9-c421-5590-8ed9-c2efd941a4b4', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a2_dupes 20261119: нова вправа «listening_dialogue» в уроці A2 замість старої (план «Дублі», PR 4). Бета, потрібна перевірка носієм.');
  perform pg_temp.swap_ex(v_lesson, '9e6901c7-8781-564e-85fc-accde77fa4fe', '619f3ad8-8e4c-5c2e-8be6-2d951bebce18', 'speaking', 'Я відстаю на розмовній практиці.', 'Zaostajem na konverzaciji.', null, null, null);
  perform pg_temp.swap_ex(v_lesson, 'c1f4bffd-fc99-5ee1-8cdd-1760c1698be3', 'b9f28cfc-57bd-5088-82cb-8fe42654e429', 'write_message', 'Напишіть викладачці: у четвер ви не прийдете на заняття через роботу й питаєте, що повторити самостійно.', 'Poštovana profesorice, u četvrtak neću moći doći na sat zbog posla. Što trebam samostalno ponoviti?', null, null, '{"situation_ua": "Напишіть викладачці: у четвер ви не прийдете на заняття через роботу й питаєте, що повторити самостійно.", "points": [{"ua": "не прийдете на заняття", "keys": [["neću"], ["ne mogu"], ["propust"]]}, {"ua": "у четвер", "keys": [["četvrt"]]}, {"ua": "що повторити самостійно", "keys": [["ponovi"], ["samostal"]]}], "hints": ["u četvrtak neću moći doći", "zbog posla", "što trebam ponoviti?"], "models": ["Poštovana profesorice, u četvrtak neću moći doći na sat zbog posla. Što trebam samostalno ponoviti?"]}'::jsonb);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'b9f28cfc-57bd-5088-82cb-8fe42654e429', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a2_dupes 20261119: нова вправа «write_message» в уроці A2 замість старої (план «Дублі», PR 4). Бета, потрібна перевірка носієм.');
  perform pg_temp.swap_ex(v_lesson, 'b2734bec-479e-5d43-b288-7b1ed27b1c0d', '571f5551-cb79-50fa-b3ec-5e50cfaf325b', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Imate li sate konverzacije u maloj grupi?', null, null, '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай у школі, чи є заняття з розмовної практики в малій групі.", "direction": "ua_hr", "points": [{"ua": "розмовна практика", "keys": [["konverzacij"]]}, {"ua": "мала група", "keys": [["mal", "grup"]]}], "hints": [], "models": ["Imate li sate konverzacije u maloj grupi?"], "source_ua": "Спитай у школі, чи є заняття з розмовної практики в малій групі."}'::jsonb);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '571f5551-cb79-50fa-b3ec-5e50cfaf325b', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a2_dupes 20261119: нова вправа «mediation» в уроці A2 замість старої (план «Дублі», PR 4). Бета, потрібна перевірка носієм.');
  -- діалог «Upis na tečaj» → «Kako napredujem?» (старий — DEPRECATED, не видаляється)
  update public.conversations set status = 'DEPRECATED' where id = 'd198b0f9-0676-53cf-87d3-3c1468482649' and status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Upis na tečaj» — звірте базу'; end if;
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  -- source — цього пакета (діалоги програми A2 v2 рахує тест a2_v2_dialogues); звідки діалог — у content_reviews
  values ('9f4f9ff7-6d4c-5988-ae7a-b3e32cf1bb4d', v_lesson, 'Як я просуваюся?', 'Kako napredujem?', 5091, 'A2', 'small_talk', 'PUBLISHED', 'claude_a2_dupes');
  perform pg_temp.turn('339f6e19-1a74-52cb-ab28-5b26bd0a1ece', '9f4f9ff7-6d4c-5988-ae7a-b3e32cf1bb4d', 'Daša', 'Profesorice, imate li minutu? Zanima me kako napredujem.', 'Пані викладачко, у вас є хвилинка? Мені цікаво, як я просуваюся.', 1);
  perform pg_temp.turn('3e649408-da13-5719-81d0-8a8dbf0d3fdb', '9f4f9ff7-6d4c-5988-ae7a-b3e32cf1bb4d', 'Predavačica', 'Napredujete dobro. Vaša razina znanja je sada bolja nego u rujnu.', 'Ви робите добрі успіхи. Ваш рівень знань тепер кращий, ніж у вересні.', 2);
  perform pg_temp.turn('6933ecee-7ca6-51d9-8308-f01e75014d08', '9f4f9ff7-6d4c-5988-ae7a-b3e32cf1bb4d', 'Daša', 'Ali na konverzaciji još malo zaostajem za grupom.', 'Але на розмовній практиці я ще трохи відстаю від групи.', 3);
  perform pg_temp.turn('937f9fe7-b661-5b1b-8970-45745a3e506c', '9f4f9ff7-6d4c-5988-ae7a-b3e32cf1bb4d', 'Predavačica', 'Zato više sudjelujte na satu. Nemojte se bojati pogrešaka.', 'Тому більше беріть участь на занятті. Не бійтеся помилок.', 4);
  perform pg_temp.turn('9e1971b5-7c3d-5e89-9eec-9ef526c16d40', '9f4f9ff7-6d4c-5988-ae7a-b3e32cf1bb4d', 'Daša', 'Hoćete li me ispravljati kad pogriješim?', 'Ви виправлятимете мене, коли я помилятимуся?', 5);
  perform pg_temp.turn('cb93e57c-fe01-5a28-88de-282a421ed2e9', '9f4f9ff7-6d4c-5988-ae7a-b3e32cf1bb4d', 'Predavačica', 'Naravno. A kod kuće samostalno učite riječi i čitajte naglas.', 'Звісно. А вдома самостійно вчіть слова й читайте вголос.', 6);
  update public.lessons set objectives = '["Розповісти, як іде навчання на курсі: прогрес, розмовна практика, довідка про відвідування", "Розрізняти вид: ispravljati — ispraviti, vježbati — izvježbati"]'::jsonb where id = v_lesson;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a2_dupes 20261119: план «Дублі й сенс уроків» (PR 4, рішення власника 2026-11-17) — урок «Курси хорватської для дорослих» — уже на курсі: прогрес, розмовна практика, довідка; запис на курс — в A1-105 (Д2). Бета, потрібна перевірка носієм.');
end $$;

-- 2. Урок 27 (стане 27): урок «Аргументи й компроміс» без «згоден / не згоден / ти правий» — їх учать в A1 «Що ти думаєш?» (Д1)
do $$
declare
  v_lesson constant uuid := 'f029711f-710e-5327-be4d-2310435e6eac';
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = 'uvjerljiv') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a2_dupes: урок «Аргументи й компроміс» без «згоден / не згоден / ти правий» — їх учать в A1 «Що ти думаєш?» (Д1) — стара версія');
  perform pg_temp.swap_word(v_lesson, 'slagati se', 'uvjerljiv');
  perform pg_temp.swap_word(v_lesson, 'ne slažem se', 'popustiti');
  perform pg_temp.swap_word(v_lesson, 'u pravu si', 'inzistirati');
  perform pg_temp.swap_word(v_lesson, 'nisi u pravu', 'opravdan');
  perform pg_temp.swap_word(v_lesson, 'po meni', 'dokaz');
  perform pg_temp.swap_ex(v_lesson, '838044ce-76ea-500c-80ea-b6a1d40d5d93', '0c71d3bf-d58c-53d3-ba28-759602c6e120', 'multiple_choice', 'Що означає «opravdan»?', 'обґрунтований, виправданий', '["контраргумент", "обґрунтований, виправданий", "перевага", "певною мірою"]'::jsonb, 'opravdan', null);
  perform pg_temp.swap_ex(v_lesson, 'e6391f10-1d7c-592a-8ea6-7f5894a2a9e0', 'ebc5f067-6edc-580c-9ed0-cd6189c25c26', 'multiple_choice', 'Що означає «rasprava»?', 'обговорення, дискусія', '["доказ; підтвердження", "переконливий", "обговорення, дискусія", "пропозиція"]'::jsonb, 'rasprava', null);
  perform pg_temp.swap_ex(v_lesson, 'ad082e2c-6a48-5164-b80e-d20aa4b4ab4e', 'aa063f91-386c-5c89-999c-a68c56acee70', 'multiple_choice', 'Що означає «popustiti»?', 'поступитися', '["аргумент", "компроміс", "поступитися", "з одного боку"]'::jsonb, 'popustiti', null);
  perform pg_temp.swap_ex(v_lesson, '03825d02-031e-5f68-9f83-7da0109b1762', '51389b36-e46c-5c5b-a989-af100e33fa91', 'multiple_choice', 'Як хорватською «переконливий»?', 'uvjerljiv', '["stav", "uvjerljiv", "nikako", "prijedlog"]'::jsonb, 'uvjerljiv', null);
  perform pg_temp.swap_ex(v_lesson, '99f0be0d-b009-5161-95bc-d932cad23526', 'df30f9dc-63cf-567a-b511-de6e5dfd9f10', 'type_answer', 'Напишіть хорватською: «наполягати»', 'inzistirati', null, 'inzistirati', null);
  perform pg_temp.swap_ex(v_lesson, '4336f5da-3c6d-5132-95ff-4cc9e48031ef', '0b6f248e-e784-503c-828f-ccbb718c01bc', 'sentence_builder', 'Складіть: «Твій аргумент не дуже переконливий.»', 'Tvoj argument nije baš uvjerljiv.', '["Tvoj", "baš", "uvjerljiv.", "nije", "argument"]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, '98627a8b-045d-59fd-a5ef-34d9dcf35e77', 'efc9193b-455e-5296-9e0f-098d3fbdf93d', 'speaking', 'Твоя вимога цілком обґрунтована.', 'Tvoj zahtjev je potpuno opravdan.', null, null, null);
  update public.lessons set objectives = '["Аргументувати думку й шукати компроміс: argument, dokaz, uvjerljiv, popustiti, inzistirati", "Вживати орудний: slažem se s tobom / s kolegama, ne slažem se s njima"]'::jsonb where id = v_lesson;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a2_dupes 20261119: план «Дублі й сенс уроків» (PR 4, рішення власника 2026-11-17) — урок «Аргументи й компроміс» без «згоден / не згоден / ти правий» — їх учать в A1 «Що ти думаєш?» (Д1). Бета, потрібна перевірка носієм.');
end $$;

-- 2. Урок 29 (стане 29): урок «Сусіди: збори й шкода» без шуму — він в A1-48 «Новий сусід» (Д6)
do $$
declare
  v_lesson constant uuid := '5252662a-abfc-517a-9bde-8683121a53c5';
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = 'procuriti') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a2_dupes: урок «Сусіди: збори й шкода» без шуму — він в A1-48 «Новий сусід» (Д6) — стара версія');
  perform pg_temp.swap_word(v_lesson, 'glasna glazba', 'procuriti');
  perform pg_temp.swap_word(v_lesson, 'lupati', 'fasada');
  perform pg_temp.swap_word(v_lesson, 'smetati', 'popravak krova');
  perform pg_temp.swap_word(v_lesson, 'utišati', 'nadoknada štete');
  perform pg_temp.swap_ex(v_lesson, '5e508569-9d16-5835-88ea-90e78a51be08', '0ec609bb-30ee-51d3-805f-c1b9961799cd', 'fill_in_the_blank', 'Dogovorila sam se ___ susjedima oko popravka krova.', 'sa', '["od", "kod", "sa", "s"]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, '63dbfe40-befb-511e-b48a-96255b1753fe', 'e8b88bca-bfc6-559f-a90c-0bcca0b9d702', 'multiple_choice', 'Що означає «oglasna ploča»?', 'дошка оголошень', '["дошка оголошень", "під’їзд", "фасад", "затопити"]'::jsonb, 'oglasna ploča', null);
  perform pg_temp.swap_ex(v_lesson, '71048f18-8cd0-50f4-bbc0-9309aa43fa6a', 'd2362f59-a44c-5c56-a155-14c431f472c3', 'type_answer', 'Напишіть хорватською: «фасад»', 'fasada', null, 'fasada', null);
  perform pg_temp.swap_ex(v_lesson, '01f7d1e3-7332-5a2d-9ad1-4428cc5b1c9d', 'a0ceb3ee-e21c-59cc-80a7-72dcadde5b70', 'sentence_builder', 'Складіть: «На зборах ми домовилися про ремонт даху.»', 'Na sastanku smo dogovorili popravak krova.', '["smo", "Na", "sastanku", "dogovorili", "popravak", "krova."]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, 'f8c7f1ee-aa3d-5958-88fa-23cbc615abba', '7a62364b-cafb-5ed0-9b33-50c335091f5d', 'listening', 'Прослухайте і складіть фразу', 'Jutros mi je pukla cijev ispod umivaonika.', '["je", "mi", "ispod", "cijev", "pukla", "umivaonika.", "Jutros"]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, '4c5cf1ca-356b-5737-a98f-30bab1e339af', '3ef10e8d-54a2-5e36-a560-8a90ca5d8b13', 'speaking', 'У нас зі стелі тече вода.', 'Kod nas curi voda sa stropa.', null, null, null);
  perform pg_temp.swap_ex(v_lesson, '1bdceef1-45a5-5bd8-9291-d5aa2eda8a0a', '032544b6-6ae5-5422-ad85-02969f62ee4d', 'write_message', 'Напишіть оголошення на дошку: у п’ятницю о 19:00 збори мешканців, тема — ремонт даху й фасаду.', 'Poštovani stanari, sastanak stanara je u petak u 19 sati. Tema je popravak krova i fasade.', null, null, '{"situation_ua": "Напишіть оголошення на дошку: у п’ятницю о 19:00 збори мешканців, тема — ремонт даху й фасаду.", "points": [{"ua": "у п’ятницю", "keys": [["petak"]]}, {"ua": "збори мешканців", "keys": [["sastan"]]}, {"ua": "о 19:00", "keys": [["19"], ["devetnaest"], ["sedam"]]}, {"ua": "дах і фасад", "keys": [["krov"], ["fasad"]]}], "hints": ["poštovani stanari", "sastanak stanara je u petak", "popravak krova i fasade"], "models": ["Poštovani stanari, sastanak stanara je u petak u 19 sati. Tema je popravak krova i fasade."]}'::jsonb);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '032544b6-6ae5-5422-ad85-02969f62ee4d', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a2_dupes 20261119: нова вправа «write_message» в уроці A2 замість старої (план «Дублі», PR 4). Бета, потрібна перевірка носієм.');
  -- діалог «Buka navečer» → «Poplavio nas je susjed» (старий — DEPRECATED, не видаляється)
  update public.conversations set status = 'DEPRECATED' where id = '318010bf-019c-5e76-86ff-4cb83577f32c' and status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Buka navečer» — звірте базу'; end if;
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  -- source — цього пакета (діалоги програми A2 v2 рахує тест a2_v2_dialogues); звідки діалог — у content_reviews
  values ('edbc9ea0-d01d-5d58-94c5-454bc111cda7', v_lesson, 'Сусід нас затопив', 'Poplavio nas je susjed', 5291, 'A2', 'housing', 'PUBLISHED', 'claude_a2_dupes');
  perform pg_temp.turn('478c58af-1f36-561f-82a6-d337e2962f74', 'edbc9ea0-d01d-5d58-94c5-454bc111cda7', 'Darja', 'Dobar dan, ja sam Darja iz stana ispod Vas. Imamo problem.', 'Добрий день, я Дар’я з квартири під вами. У нас проблема.', 1);
  perform pg_temp.turn('487b660b-d94a-51f4-a897-8152e909547e', 'edbc9ea0-d01d-5d58-94c5-454bc111cda7', 'Susjed', 'Dobar dan. Što se dogodilo?', 'Добрий день. Що сталося?', 2);
  perform pg_temp.turn('2ad36ec6-38e5-5762-8caf-7b9f16cc8a5e', 'edbc9ea0-d01d-5d58-94c5-454bc111cda7', 'Darja', 'Voda je procurila kroz strop u našoj kupaonici.', 'Вода протекла крізь стелю в нашій ванній.', 3);
  perform pg_temp.turn('9c4b3cec-b195-5103-b529-05a74dcb6051', 'edbc9ea0-d01d-5d58-94c5-454bc111cda7', 'Susjed', 'Joj, oprostite! Jutros mi je pukla cijev ispod umivaonika.', 'Ой, перепрошую! Сьогодні вранці в мене лопнула труба під умивальником.', 4);
  perform pg_temp.turn('79f87406-f81a-5db7-98f1-9ef1538f9a2b', 'edbc9ea0-d01d-5d58-94c5-454bc111cda7', 'Darja', 'Imate li osiguranje stana? Trebat će nam nadoknada štete.', 'У вас є страховка квартири? Нам знадобиться відшкодування збитків.', 5);
  perform pg_temp.turn('bb674e81-503e-5e38-88a6-c2f103a379aa', 'edbc9ea0-d01d-5d58-94c5-454bc111cda7', 'Susjed', 'Imam. Zvat ću osiguravajuće društvo i platit ću štetu.', 'Є. Зателефоную в страхову компанію й оплачу збитки.', 6);
  update public.lessons set objectives = '["Поговорити із сусідом про шкоду: протекла вода, страховка, відшкодування", "Збори мешканців: дах, фасад, спільне приміщення, паркування", "Вживати орудний: razgovarati sa susjedima, pred zgradom, među stanarima"]'::jsonb where id = v_lesson;
  update public.lessons set title_ua = regexp_replace(title_ua, ':.*$', '') || ': Сусіди: збори й шкода', title_hr = regexp_replace(title_hr, ':.*$', '') || ': Susjedi: sastanak stanara i šteta' where id = v_lesson;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a2_dupes 20261119: план «Дублі й сенс уроків» (PR 4, рішення власника 2026-11-17) — урок «Сусіди: збори й шкода» без шуму — він в A1-48 «Новий сусід» (Д6). Бета, потрібна перевірка носієм.');
end $$;

-- 2. Урок 38 (стане 38): урок «Майстер удома: кошторис і гарантія» без «тече кран» і «немає світла» — вони в A1-45 (Д5)
do $$
declare
  v_lesson constant uuid := 'bf43b6bd-d547-596b-8981-55a4043cf238';
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = 'rok završetka') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a2_dupes: урок «Майстер удома: кошторис і гарантія» без «тече кран» і «немає світла» — вони в A1-45 (Д5) — стара версія');
  perform pg_temp.swap_word(v_lesson, 'kapati', 'rok završetka');
  perform pg_temp.swap_word(v_lesson, 'iskočio je osigurač', 'kašnjenje radova');
  perform pg_temp.swap_word(v_lesson, 'začepiti se', 'plaćanje gotovinom');
  perform pg_temp.swap_ex(v_lesson, '9d4860f1-6fdd-5448-b272-eb745116fcb0', 'fa825e6d-ae9a-5026-9e59-7a3ac6aabdd0', 'fill_in_the_blank', 'Majstor je došao bez ___.', 'dijelova', '["dijelova", "dijelove", "dijelovi", "dijelovima"]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, '077804c2-c057-50d8-b879-7ee5cadbaa4a', '61b226d9-74c8-5e66-8cf4-eb867f4e162c', 'multiple_choice', 'Що означає «brava»?', 'замок (дверний)', '["затримка робіт", "матеріал", "маляр (стін)", "замок (дверний)"]'::jsonb, 'brava', null);
  perform pg_temp.swap_ex(v_lesson, '8cd3c477-7b16-56de-b9ec-e16ca6288439', '1651a226-7789-517f-a3ab-da929da6501b', 'multiple_choice', 'Як хорватською «маляр (стін)»?', 'soboslikar', '["stolar", "soboslikar", "rok završetka", "procjena"]'::jsonb, 'soboslikar', null);
  perform pg_temp.swap_ex(v_lesson, '4cfaf13f-1e59-50c7-a05c-8022193578bd', 'f34af0f9-4ff4-5bb5-b188-1b6875003d9a', 'sentence_builder', 'Складіть: «Який термін завершення робіт?»', 'Koji je rok završetka radova?', '["završetka", "radova?", "je", "Koji", "rok"]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, '6e3a138a-a4f4-5eee-9601-1e0dc9f1332d', '516a8859-8008-5323-88db-75843b4faebf', 'listening', 'Прослухайте і складіть фразу', 'Je li moguće plaćanje gotovinom?', '["li", "gotovinom?", "Je", "plaćanje", "moguće"]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, '4b53554b-8c82-5e77-9aa5-fcfb5ed1dd9c', '618836a0-70a0-5944-bd09-c8996b89d5fc', 'speaking', 'Чи буде затримка робіт?', 'Hoće li biti kašnjenja radova?', null, null, null);
  perform pg_temp.swap_ex(v_lesson, '43598d39-1b4a-5fa6-8878-b55306c76d80', '4896a102-0324-5b7b-ad1f-55820616b84c', 'write_message', 'Напишіть майстрові: попросіть кошторис на плитку у ванній і спитайте про термін завершення робіт.', 'Dobar dan, molim Vas predračun za pločice u kupaonici. Koji je rok završetka radova?', null, null, '{"situation_ua": "Напишіть майстрові: попросіть кошторис на плитку у ванній і спитайте про термін завершення робіт.", "points": [{"ua": "кошторис", "keys": [["predračun"], ["procjen"]]}, {"ua": "плитка у ванній", "keys": [["pločic"]]}, {"ua": "термін завершення", "keys": [["rok"], ["završ"], ["kada"]]}], "hints": ["molim Vas predračun", "pločice u kupaonici", "rok završetka radova"], "models": ["Dobar dan, molim Vas predračun za pločice u kupaonici. Koji je rok završetka radova?"]}'::jsonb);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '4896a102-0324-5b7b-ad1f-55820616b84c', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a2_dupes 20261119: нова вправа «write_message» в уроці A2 замість старої (план «Дублі», PR 4). Бета, потрібна перевірка носієм.');
  -- діалог «Kapa slavina» → «Mijenjamo bravu» (старий — DEPRECATED, не видаляється)
  update public.conversations set status = 'DEPRECATED' where id = '3b36368a-5bfe-5451-a5a1-b345a714350f' and status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Kapa slavina» — звірте базу'; end if;
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  -- source — цього пакета (діалоги програми A2 v2 рахує тест a2_v2_dialogues); звідки діалог — у content_reviews
  values ('bfe93637-a37f-55d1-84c5-32a776dad2d2', v_lesson, 'Міняємо замок', 'Mijenjamo bravu', 5381, 'A2', 'housing', 'PUBLISHED', 'claude_a2_dupes');
  perform pg_temp.turn('2e1ee3cc-9bc2-5700-8b3a-55a9d5523dd3', 'bfe93637-a37f-55d1-84c5-32a776dad2d2', 'Darja', 'Dobar dan, zovem zbog brave na ulaznim vratima. Ključ se teško okreće.', 'Добрий день, телефоную щодо замка на вхідних дверях. Ключ важко повертається.', 1);
  perform pg_temp.turn('a8a7ccb2-ff4e-582a-a409-3a0e7c3b8b4c', 'bfe93637-a37f-55d1-84c5-32a776dad2d2', 'Bravar', 'Najbolje je zamijeniti bravu. Mogu doći sutra ujutro.', 'Найкраще замінити замок. Можу приїхати завтра вранці.', 2);
  perform pg_temp.turn('2efa3c49-3f3c-53a3-b17e-b29aa30de678', 'bfe93637-a37f-55d1-84c5-32a776dad2d2', 'Darja', 'Koliko košta izlazak na teren?', 'Скільки коштує виїзд майстра?', 3);
  perform pg_temp.turn('367c303e-683d-5286-9eda-1be669e24672', 'bfe93637-a37f-55d1-84c5-32a776dad2d2', 'Bravar', 'Trideset eura, a nova brava s ugradnjom oko sto.', 'Тридцять євро, а новий замок зі встановленням — близько ста.', 4);
  perform pg_temp.turn('d6977f60-ba2f-5b5b-82cb-a96ce52962b0', 'bfe93637-a37f-55d1-84c5-32a776dad2d2', 'Darja', 'Je li moguće plaćanje gotovinom?', 'Можна оплатити готівкою?', 5);
  perform pg_temp.turn('991a9506-9652-53fa-947e-fc10f95dd185', 'bfe93637-a37f-55d1-84c5-32a776dad2d2', 'Bravar', 'Može gotovinom ili karticom. Dobit ćete račun i jamstvo na radove.', 'Можна готівкою або карткою. Отримаєте рахунок і гарантію на роботи.', 6);
  -- діалог «Bez struje» → «Predračun za pločice» (старий — DEPRECATED, не видаляється)
  update public.conversations set status = 'DEPRECATED' where id = '83c1bbe5-d130-5039-bf75-94e1be89f88a' and status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Bez struje» — звірте базу'; end if;
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  -- source — цього пакета (діалоги програми A2 v2 рахує тест a2_v2_dialogues); звідки діалог — у content_reviews
  values ('67cf9e08-9e7e-58a4-a3ac-dc1eb2d297ed', v_lesson, 'Кошторис на плитку', 'Predračun za pločice', 5382, 'A2', 'housing', 'PUBLISHED', 'claude_a2_dupes');
  perform pg_temp.turn('cd7966fd-daf9-5c0d-a7af-f364cc6c9cb1', '67cf9e08-9e7e-58a4-a3ac-dc1eb2d297ed', 'Ivan', 'Dobar dan, dobili smo Vaš predračun za pločice u kupaonici.', 'Добрий день, ми отримали ваш кошторис на плитку у ванній.', 1);
  perform pg_temp.turn('62dd7b0d-8850-5b88-9f48-ee701627d1e3', '67cf9e08-9e7e-58a4-a3ac-dc1eb2d297ed', 'Keramičar', 'Odlično. Imate li pitanja?', 'Чудово. Маєте запитання?', 2);
  perform pg_temp.turn('2a2874f7-7c46-55c9-92ac-cb195a7432f0', '67cf9e08-9e7e-58a4-a3ac-dc1eb2d297ed', 'Ivan', 'Koji je rok završetka radova?', 'Який термін завершення робіт?', 3);
  perform pg_temp.turn('36f4132a-23cc-513e-91b0-a30f1aeeb94d', '67cf9e08-9e7e-58a4-a3ac-dc1eb2d297ed', 'Keramičar', 'Deset radnih dana, ako materijal stigne na vrijeme.', 'Десять робочих днів, якщо матеріал прибуде вчасно.', 4);
  perform pg_temp.turn('a85829d4-193c-5a10-869b-3623fd53c6b5', '67cf9e08-9e7e-58a4-a3ac-dc1eb2d297ed', 'Ivan', 'A ako dođe do kašnjenja radova?', 'А якщо буде затримка робіт?', 5);
  perform pg_temp.turn('9889e536-1693-56d0-a7bd-a2e2b2bf29db', '67cf9e08-9e7e-58a4-a3ac-dc1eb2d297ed', 'Keramičar', 'Javit ću Vam odmah. Za svaki tjedan kašnjenja dajem popust.', 'Я одразу вам повідомлю. За кожен тиждень затримки даю знижку.', 6);
  update public.lessons set objectives = '["Домовитися з майстром про кошторис, термін, оплату й гарантію", "Родовий: bez dijelova, zbog kašnjenja, umjesto stare brave"]'::jsonb where id = v_lesson;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a2_dupes 20261119: план «Дублі й сенс уроків» (PR 4, рішення власника 2026-11-17) — урок «Майстер удома: кошторис і гарантія» без «тече кран» і «немає світла» — вони в A1-45 (Д5). Бета, потрібна перевірка носієм.');
end $$;

-- 2. Урок 70 (стане 71): урок «Звичаї й етикет» без «ти чи Ви» — він в A1-77 (Д7)
do $$
declare
  v_lesson constant uuid := '7d3c3501-a381-5b3c-a0a2-b269f3dff137';
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = 'gostoprimstvo') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a2_dupes: урок «Звичаї й етикет» без «ти чи Ви» — він в A1-77 (Д7) — стара версія');
  perform pg_temp.swap_word(v_lesson, 'persirati', 'gostoprimstvo');
  perform pg_temp.swap_word(v_lesson, 'tikati', 'nutkati');
  perform pg_temp.swap_ex(v_lesson, '6fd9f1b0-355e-527e-8e71-7c20171f3e72', 'f057e0f3-c67c-5788-8dd6-034239980580', 'sentence_builder', 'Складіть: «Дякую за гостинність!»', 'Hvala na gostoprimstvu!', '["Hvala", "gostoprimstvu!", "na"]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, '70c2ff70-2b33-569b-a0aa-662dd4fbe4db', 'fb14b07d-f9d6-5a5f-b13d-0ae50086820e', 'listening_dialogue', 'Прослухайте розмову', 'коли господиня скаже «Смачного!»; похвалити їжу; припрошуватиме', null, null, '{"kind": "dialogue", "situation_ua": "Дар’я питає Івану, як поводитися на святковому обіді.", "script": [{"speaker": "Darja", "hr": "Kada se počinje jesti, odmah ili kad svi sjednu?", "ua": "Коли починають їсти — одразу чи коли всі сядуть?"}, {"speaker": "Ivana", "hr": "Kad domaćica kaže „Dobar tek!“. Prije toga se čeka.", "ua": "Коли господиня скаже «Смачного!». До того чекають."}, {"speaker": "Darja", "hr": "A smijem li odbiti drugi tanjur?", "ua": "А можна відмовитися від добавки?"}, {"speaker": "Ivana", "hr": "Smiješ, ali pohvali hranu. Domaćica će te ionako nutkati.", "ua": "Можна, але похвали їжу. Господиня все одно тебе припрошуватиме."}], "questions": [{"q_ua": "Коли починають їсти?", "options": ["коли господиня скаже «Смачного!»", "одразу, як принесуть їжу", "після тосту"], "correct": 0, "answer_turn": 1}, {"q_ua": "Що треба зробити, якщо відмовляєшся від добавки?", "answer_text": "похвалити їжу", "accept": ["похвалити", "похвалити страву", "похвалити господиню"], "answer_turn": 3}, {"q_ua": "Що все одно робитиме господиня?", "options": ["принесе десерт", "припрошуватиме", "образиться"], "correct": 1, "answer_turn": 3}], "max_plays": 3}'::jsonb);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'fb14b07d-f9d6-5a5f-b13d-0ae50086820e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a2_dupes 20261119: нова вправа «listening_dialogue» в уроці A2 замість старої (план «Дублі», PR 4). Бета, потрібна перевірка носієм.');
  -- діалог «Ti ili Vi?» → «Ručak kod Ivaninih roditelja» (старий — DEPRECATED, не видаляється)
  update public.conversations set status = 'DEPRECATED' where id = '4b330410-5e4a-5b9e-9470-0f20bcc5f475' and status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Ti ili Vi?» — звірте базу'; end if;
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  -- source — цього пакета (діалоги програми A2 v2 рахує тест a2_v2_dialogues); звідки діалог — у content_reviews
  values ('4d8d461e-3901-592b-a23f-17ad529f3f33', v_lesson, 'Обід у батьків Івани', 'Ručak kod Ivaninih roditelja', 5702, 'A2', 'small_talk', 'PUBLISHED', 'claude_a2_dupes');
  perform pg_temp.turn('648c39ae-89cc-5d99-bf08-be8401787acb', '4d8d461e-3901-592b-a23f-17ad529f3f33', 'Gospođa Horvat', 'Izvolite, sjednite. Danas imamo juhu, pečenu piletinu i kolač.', 'Прошу, сідайте. Сьогодні маємо суп, печене курча й пиріг.', 1);
  perform pg_temp.turn('19c993af-ee09-531f-a375-36e74e5efa7b', '4d8d461e-3901-592b-a23f-17ad529f3f33', 'Darja', 'Hvala, sve izgleda prekrasno. Hvala na gostoprimstvu!', 'Дякую, усе виглядає чудово. Дякую за гостинність!', 2);
  perform pg_temp.turn('905edc99-21e9-5b7d-9c14-703d9ae21c3e', '4d8d461e-3901-592b-a23f-17ad529f3f33', 'Gospođa Horvat', 'Uzmite još malo piletine, nemojte se sramiti.', 'Візьміть ще трохи курятини, не соромтеся.', 3);
  perform pg_temp.turn('db4216c0-4307-5bf4-b4c8-a827f601b902', '4d8d461e-3901-592b-a23f-17ad529f3f33', 'Darja', 'Hvala, stvarno sam sita. Bilo je jako ukusno.', 'Дякую, я справді сита. Було дуже смачно.', 4);
  perform pg_temp.turn('f781482e-0e32-5df4-8fcc-06963933603f', '4d8d461e-3901-592b-a23f-17ad529f3f33', 'Ivana', 'Mama, nemoj je toliko nutkati!', 'Мамо, не припрошуй її так!', 5);
  perform pg_temp.turn('d7c7b6a1-f4de-5870-afa8-73087507ce8d', '4d8d461e-3901-592b-a23f-17ad529f3f33', 'Gospođa Horvat', 'Dobro, dobro. Ali kolač morate probati, to je običaj u ovoj kući.', 'Добре, добре. Але пиріг мусите скуштувати, такий звичай у цьому домі.', 6);
  update public.lessons set objectives = '["Знати, як поводитися в гостях і за столом: gostoprimstvo, nutkati, poklon za domaćina", "Присвійні: domaćičin kolač, Ivanov rođendan, tuđa kuća"]'::jsonb where id = v_lesson;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a2_dupes 20261119: план «Дублі й сенс уроків» (PR 4, рішення власника 2026-11-17) — урок «Звичаї й етикет» без «ти чи Ви» — він в A1-77 (Д7). Бета, потрібна перевірка носієм.');
end $$;

-- 3. Новий урок A2.11, місце 5 (стане уроком 70): «Далмація: Задар і околиці» — 23 слів, 2 діалоги, 15 вправ + письмо й переказ;
--    «Звичаї й етикет: як поводитися» і «Клапа, тамбурица й спадщина ЮНЕСКО» — місця 6 і 7
do $$
declare
  v_unit constant uuid := '3fbc4d9b-4366-5f0f-b785-eb3f750240be';
  v_lesson constant uuid := '185cee8e-46a7-58b2-bc82-166ba74dc272';
  v_gid constant uuid := '6da44157-69d7-5261-8289-fe910fd60f59';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if (select count(*) from public.lessons where unit_id = v_unit and status = 'PUBLISHED') <> 6
     or (select order_index from public.lessons where id = '7d3c3501-a381-5b3c-a0a2-b269f3dff137') <> 5 or (select order_index from public.lessons where id = 'c71597ab-1dac-5b9d-a304-b389f93a420a') <> 6 then
    raise exception 'Модуль A2.11: очікувалось 6 уроків, «Звичаї й етикет» — 5, «Клапа…» — 6 — звірте базу';
  end if;
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики POSV'; end if;
  -- місця 5 → 6 і 6 → 7 (спершу останній); стара версія — у content_versions
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'lesson', l.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = l.id), 0) + 1,
         to_jsonb(l), 'a2_dupes: нове місце в модулі A2.11 (перед уроком — новий «Далмація: Задар і околиці») — стара версія'
    from public.lessons l where l.id = 'c71597ab-1dac-5b9d-a304-b389f93a420a';
  update public.lessons set order_index = 7 where id = 'c71597ab-1dac-5b9d-a304-b389f93a420a';
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'lesson', l.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = l.id), 0) + 1,
         to_jsonb(l), 'a2_dupes: нове місце в модулі A2.11 (перед уроком — новий «Далмація: Задар і околиці») — стара версія'
    from public.lessons l where l.id = '7d3c3501-a381-5b3c-a0a2-b269f3dff137';
  update public.lessons set order_index = 6 where id = '7d3c3501-a381-5b3c-a0a2-b269f3dff137';
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 70: Далмація: Задар і околиці', 'Lekcija 70: Dalmacija: Zadar i okolica', '["Розповісти про Задар і околиці: Нін, Паклениця, Біоград, острови", "Прикметники від назв місць: zadarski, ninski, biogradski", "Впізнати далматинське розмовне слово: ići na đir"]'::jsonb, 20, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zadarski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'solana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'morska sol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljekovito blato', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crkvica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kraljevski grad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'starohrvatski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'arheološko nalazište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'penjač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'penjalište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stijena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uže', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slobodno penjanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'marina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izletnički brod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cjelodnevni izlet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ribarska brodica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ulov', v_pos);
  v_pos := pg_temp.word(v_lesson, 'turistička sezona', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izvan sezone', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tempo života', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sezonski posao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'đir', v_pos);
  -- «đir» — лише впізнавати (розмовне далматинське слово): без «напишіть» і «скажіть»
  update public.lesson_items set target_skill = 'recognition' where lesson_id = v_lesson and item_type = 'lexeme'
     and item_id = (select id from public.lexemes where lower(lemma) = 'đir' and status = 'PUBLISHED' order by created_at limit 1);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '98dcf937-db0d-5269-b3eb-306204361d13', 'fill_in_the_blank', 'U ___ solani sol se i danas skuplja ručno.', 'ninskoj', '["Nina", "Ninu", "ninski", "ninskoj"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '44d36195-ff9d-5814-9f2e-6de1d1cb3148', 'multiple_choice', 'Що означає «slobodno penjanje»?', 'скелелазіння', '["скелелазіння", "королівське місто", "марина (пристань для яхт)", "лікувальна грязь"]'::jsonb, 'A2', 2, 'PUBLISHED', 'slobodno penjanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa697873-81f9-5441-b312-7eda79693cc2', 'multiple_choice', 'Що означає «ljekovito blato»?', 'лікувальна грязь', '["археологічна пам’ятка (місце розкопок)", "лікувальна грязь", "церковця, маленька церква", "скелелазіння"]'::jsonb, 'A2', 3, 'PUBLISHED', 'ljekovito blato', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1bec5516-ac47-5f8d-9bda-3f2b4aa4b590', 'multiple_choice', 'Що означає «arheološko nalazište»?', 'археологічна пам’ятка (місце розкопок)', '["рибальський човен", "улов", "археологічна пам’ятка (місце розкопок)", "королівське місто"]'::jsonb, 'A2', 4, 'PUBLISHED', 'arheološko nalazište', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7d23facf-2943-561d-91e1-62d113e3c27f', 'multiple_choice', 'Як хорватською «темп життя»?', 'tempo života', '["kraljevski grad", "tempo života", "turistička sezona", "morska sol"]'::jsonb, 'A2', 5, 'PUBLISHED', 'tempo života', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '08232038-4f32-59b7-bc5c-e34313c1cb5c', 'multiple_choice', 'Як хорватською «скелелаз»?', 'penjač', '["penjač", "penjalište", "sezonski posao", "uže"]'::jsonb, 'A2', 6, 'PUBLISHED', 'penjač', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'da6b777d-21e4-5a2d-b555-7ceef8757e78', 'type_answer', 'Напишіть хорватською: «скеля»', 'stijena', null, 'A2', 7, 'PUBLISHED', 'stijena', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '18e93106-e99b-5661-8ad1-cac4a7dc7171', 'type_answer', 'Напишіть хорватською: «церковця, маленька церква»', 'crkvica', null, 'A2', 8, 'PUBLISHED', 'crkvica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3537d12a-dcec-587c-86b5-d97ed5242eb0', 'type_answer', 'Напишіть хорватською: «морська сіль»', 'morska sol', null, 'A2', 9, 'PUBLISHED', 'morska sol', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '30c9ba78-7748-5089-a5f8-1fe3ef70651b', 'sentence_builder', 'Складіть: «У Задарі темп життя повільніший.»', 'U Zadru je tempo života sporiji.', '["tempo", "U", "je", "sporiji.", "Zadru", "života"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1bfb201d-95be-5517-bd49-ae1e7be10209', 'sentence_builder', 'Складіть: «Прогулянковий корабель відпливає о дев’ятій.»', 'Izletnički brod polazi u devet.', '["polazi", "devet.", "Izletnički", "u", "brod"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '54f1bbe4-da56-5a5e-99fc-f38beaccbb30', 'listening', 'Прослухайте і складіть фразу', 'Idi u Nin. To je stari kraljevski grad, pola sata od Zadra.', '["kraljevski", "grad,", "je", "od", "stari", "sata", "To", "Nin.", "Idi", "u", "pola", "Zadra."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'f77ed7a2-4a7f-571c-be27-a862bd70c891', 'listening_dialogue', 'Прослухайте оголошення', '1; на кораблі; о 18:00', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Оголошення на прогулянковому кораблі в Задарі.", "script": [{"hr": "Dobro došli na cjelodnevni izlet na Kornate!", "ua": "Ласкаво просимо на одноденну екскурсію на Корнати!"}, {"hr": "Prvo stajemo u uvali Lojena, gdje se možete kupati sat vremena.", "ua": "Спершу зупиняємося в бухті Лоєна, де можна купатися годину."}, {"hr": "Ručak je na brodu oko jedan sat.", "ua": "Обід на кораблі близько першої."}, {"hr": "U Zadar se vraćamo u šest sati navečer.", "ua": "До Задара повертаємося о шостій вечора."}], "questions": [{"q_ua": "Скільки годин можна купатися в бухті?", "answer_text": "1", "accept": ["одну", "годину", "1 годину", "одна"], "answer_turn": 1}, {"q_ua": "Де обід?", "options": ["у ресторані на острові", "на кораблі", "у Задарі"], "correct": 1, "answer_turn": 2}, {"q_ua": "Коли повернуться до Задара?", "options": ["о 16:00", "о 20:00", "о 18:00"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'f77ed7a2-4a7f-571c-be27-a862bd70c891', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5c40301b-de05-5cc2-a917-724554189db3', 'speaking', 'Де тут можна займатися скелелазінням?', 'Gdje se ovdje može slobodno penjati?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5045f85b-d435-5f59-81a6-10c3a97c2715', 'speaking', 'Поза сезоном ціни нижчі.', 'Izvan sezone su cijene niže.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'd42ac261-924d-547d-bfc6-74dc217fcd01', 'write_message', 'Напишіть подрузі: ви в Ніні, купили морську сіль у солеварні, а завтра йдете на скелелазіння в Пакленицю.', 'Pozdrav iz Nina! U solani sam kupila morsku sol, a sutra idem na slobodno penjanje u Paklenicu.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі: ви в Ніні, купили морську сіль у солеварні, а завтра йдете на скелелазіння в Пакленицю.", "points": [{"ua": "Нін", "keys": [["nin"]]}, {"ua": "морська сіль", "keys": [["sol"]]}, {"ua": "скелелазіння в Паклениці", "keys": [["penja"], ["paklenic"]]}], "hints": ["pozdrav iz Nina", "kupila sam morsku sol", "sutra idem na slobodno penjanje"], "models": ["Pozdrav iz Nina! U solani sam kupila morsku sol, a sutra idem na slobodno penjanje u Paklenicu."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'd42ac261-924d-547d-bfc6-74dc217fcd01', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'fe352f7c-a9f6-5cbd-9c89-cc2a8ab1be4e', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Kada polazi izletnički brod na Kornate i koliko košta karta?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай у порту, о котрій відпливає прогулянковий корабель на Корнати і скільки коштує квиток.", "direction": "ua_hr", "points": [{"ua": "прогулянковий корабель", "keys": [["brod"]]}, {"ua": "о котрій", "keys": [["kad"], ["sat"]]}, {"ua": "скільки коштує", "keys": [["košt"], ["cijen"]]}], "hints": [], "models": ["Kada polazi izletnički brod na Kornate i koliko košta karta?"], "source_ua": "Спитай у порту, о котрій відпливає прогулянковий корабель на Корнати і скільки коштує квиток."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'fe352f7c-a9f6-5cbd-9c89-cc2a8ab1be4e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d835583e-0d77-5737-8847-199690d2c23b', v_lesson, 'Вихідні в Ніні', 'Vikend u Ninu', 5701, 'A2', 'travel', 'PUBLISHED', 'claude_a2_dupes') on conflict (id) do nothing;
  perform pg_temp.turn('cb1a8bdf-ba3c-5209-a48d-c801f0158c96', 'd835583e-0d77-5737-8847-199690d2c23b', 'Darja', 'Dašo, što da vidim blizu Zadra ako imam samo jedan dan?', 'Дашо, що мені подивитися біля Задара, якщо в мене лише один день?', 1);
  perform pg_temp.turn('95614558-1e7e-5e9d-8baa-e21581061b23', 'd835583e-0d77-5737-8847-199690d2c23b', 'Daša', 'Idi u Nin. To je stari kraljevski grad, pola sata od Zadra.', 'Їдь у Нін. Це давнє королівське місто, пів години від Задара.', 2);
  perform pg_temp.turn('a536b04c-a116-5271-a440-40012c053137', 'd835583e-0d77-5737-8847-199690d2c23b', 'Darja', 'Što ima tamo?', 'Що там є?', 3);
  perform pg_temp.turn('251245ce-0d0f-50df-bcf9-03a77266faee', 'd835583e-0d77-5737-8847-199690d2c23b', 'Daša', 'Malu starohrvatsku crkvicu, solanu i plažu s ljekovitim blatom.', 'Маленьку давньохорватську церковцю, солеварню й пляж із лікувальною грязю.', 4);
  perform pg_temp.turn('3c201f55-4e80-5399-81da-22bc5db5f8d6', 'd835583e-0d77-5737-8847-199690d2c23b', 'Darja', 'Može li se kupiti sol iz solane?', 'А можна купити сіль із солеварні?', 5);
  perform pg_temp.turn('d551fd0b-6ba1-5379-b1ca-72c09742ac0e', 'd835583e-0d77-5737-8847-199690d2c23b', 'Daša', 'Može, ninska morska sol je odličan suvenir.', 'Можна, нінська морська сіль — чудовий сувенір.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1e18012a-e274-5508-aec4-24dddceae79f', v_lesson, 'Жити в Задарі', 'Živjeti u Zadru', 5702, 'A2', 'small_talk', 'PUBLISHED', 'claude_a2_dupes') on conflict (id) do nothing;
  perform pg_temp.turn('28acdb36-676e-5bc9-b72f-f628645fcd80', '1e18012a-e274-5508-aec4-24dddceae79f', 'Marko', 'Darja, kako ti je život u Zadru?', 'Дар’є, як тобі живеться в Задарі?', 1);
  perform pg_temp.turn('ec4c6cca-e2dd-5ce3-b284-c3c6e8320c97', '1e18012a-e274-5508-aec4-24dddceae79f', 'Darja', 'Lijepo. Tempo života je sporiji nego u Zagrebu.', 'Гарно. Темп життя повільніший, ніж у Загребі.', 2);
  perform pg_temp.turn('315181af-e33b-5259-bf8d-2c97399609ae', '1e18012a-e274-5508-aec4-24dddceae79f', 'Marko', 'A ljeti, za vrijeme turističke sezone?', 'А влітку, під час туристичного сезону?', 3);
  perform pg_temp.turn('e6500d71-aad1-59f0-81e1-445c6a7db9ab', '1e18012a-e274-5508-aec4-24dddceae79f', 'Darja', 'Tada je gužva, a ja radim sezonski posao na izletničkom brodu.', 'Тоді тиснява, а я працюю на сезонній роботі на прогулянковому кораблі.', 4);
  perform pg_temp.turn('a130c38a-65b3-51cf-a24e-17c30e778dcb', '1e18012a-e274-5508-aec4-24dddceae79f', 'Marko', 'Što radiš izvan sezone?', 'Що робиш поза сезоном?', 5);
  perform pg_temp.turn('e5dd0cea-2972-59c5-b30b-3f8afc0ff699', '1e18012a-e274-5508-aec4-24dddceae79f', 'Darja', 'Vikendom idem u Paklenicu na slobodno penjanje, a navečer na đir po rivi.', 'На вихідних їжджу в Пакленицю на скелелазіння, а ввечері — прогулятися набережною.', 6);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок модуля A2.11 «Далмація: Задар і околиці» (рішення власника 2026-11-17: «без слів і діалогів A1-89»; далматинська говірка — лише впізнавання) за схемою уроків A2 (20–25 слів, 2 діалоги, 15 вправ, письмо й переказ). Потрібна перевірка носієм.');
end $$;

-- 4. Нові назви 6 діалогів з однаковими назвами (у пізнішому уроці; зміст інший); стара — у content_versions
do $$
begin
  if (select title_hr from public.conversations where id = '2c8cd7ee-e3d3-58d3-8ffe-420bf19fdb8e') = 'Prijava u hotel' then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a2_dupes: нова назва діалогу уроку A2 3 (така сама — в іншому уроці) — стара версія'
    from public.conversations c where c.id = '2c8cd7ee-e3d3-58d3-8ffe-420bf19fdb8e' and c.title_hr = 'Na recepciji' and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Na recepciji» уроку A2 3 — звірте базу'; end if;
  update public.conversations set title_ua = 'Реєстрація в готелі', title_hr = 'Prijava u hotel' where id = '2c8cd7ee-e3d3-58d3-8ffe-420bf19fdb8e';
end $$;
do $$
begin
  if (select title_hr from public.conversations where id = '9140c599-ceba-5bbb-8214-54c16f55a70c') = 'Pogreška u računu' then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a2_dupes: нова назва діалогу уроку A2 4 (така сама — в іншому уроці) — стара версія'
    from public.conversations c where c.id = '9140c599-ceba-5bbb-8214-54c16f55a70c' and c.title_hr = 'Račun' and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Račun» уроку A2 4 — звірте базу'; end if;
  update public.conversations set title_ua = 'Помилка в рахунку', title_hr = 'Pogreška u računu' where id = '9140c599-ceba-5bbb-8214-54c16f55a70c';
end $$;
do $$
begin
  if (select title_hr from public.conversations where id = 'dc69dcd8-ddd4-5c6c-b7c8-2d9b9d770f84') = 'Rang-lista' then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a2_dupes: нова назва діалогу уроку A2 10 (така сама — в іншому уроці) — стара версія'
    from public.conversations c where c.id = 'dc69dcd8-ddd4-5c6c-b7c8-2d9b9d770f84' and c.title_hr = 'Rezultati' and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Rezultati» уроку A2 10 — звірте базу'; end if;
  update public.conversations set title_ua = 'Рейтинговий список', title_hr = 'Rang-lista' where id = 'dc69dcd8-ddd4-5c6c-b7c8-2d9b9d770f84';
end $$;
do $$
begin
  if (select title_hr from public.conversations where id = '14d9a946-c3e1-58cf-bff8-0c2cca867149') = 'Dobio sam otkaz' then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a2_dupes: нова назва діалогу уроку A2 35 (така сама — в іншому уроці) — стара версія'
    from public.conversations c where c.id = '14d9a946-c3e1-58cf-bff8-0c2cca867149' and c.title_hr = 'Loša vijest' and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Loša vijest» уроку A2 35 — звірте базу'; end if;
  update public.conversations set title_ua = 'Мене звільнили', title_hr = 'Dobio sam otkaz' where id = '14d9a946-c3e1-58cf-bff8-0c2cca867149';
end $$;
do $$
begin
  if (select title_hr from public.conversations where id = '82cdf22b-ae0c-5783-898e-bed827a54a1e') = 'Zamjena vozačke dozvole' then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a2_dupes: нова назва діалогу уроку A2 48 (така сама — в іншому уроці) — стара версія'
    from public.conversations c where c.id = '82cdf22b-ae0c-5783-898e-bed827a54a1e' and c.title_hr = 'U policijskoj upravi' and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «U policijskoj upravi» уроку A2 48 — звірте базу'; end if;
  update public.conversations set title_ua = 'Обмін водійського посвідчення', title_hr = 'Zamjena vozačke dozvole' where id = '82cdf22b-ae0c-5783-898e-bed827a54a1e';
end $$;
do $$
begin
  if (select title_hr from public.conversations where id = 'b4dd1542-9a39-5b6b-b285-9b12c3a68061') = 'Rad od kuće: za i protiv' then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a2_dupes: нова назва діалогу уроку A2 65 (така сама — в іншому уроці) — стара версія'
    from public.conversations c where c.id = 'b4dd1542-9a39-5b6b-b285-9b12c3a68061' and c.title_hr = 'Rad od kuće' and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Rad od kuće» уроку A2 65 — звірте базу'; end if;
  update public.conversations set title_ua = 'Робота з дому: за і проти', title_hr = 'Rad od kuće: za i protiv' where id = 'b4dd1542-9a39-5b6b-b285-9b12c3a68061';
end $$;

-- 5. Наскрізні номери всіх уроків A2 («Урок N: …» / «Lekcija N: …»); стара назва — у content_versions;
--    порядок діалогів уроків A2 (5000 + N·10 + k) — за новим номером
do $$
declare r record; v_payload jsonb; v_new_ua text; v_new_hr text;
begin
  for r in select l.id, l.title_ua, l.title_hr,
                  row_number() over (order by m.order_index, u.order_index, l.order_index) as n
             from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
            where m.level_code = 'A2' and l.status = 'PUBLISHED' loop
    update public.conversations set order_index = 5000 + r.n * 10 + order_index % 10
     where lesson_id = r.id and order_index between 5000 and 5999 and order_index / 10 <> 500 + r.n;
    v_new_ua := regexp_replace(r.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':');
    v_new_hr := regexp_replace(r.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':');
    if v_new_ua is not distinct from r.title_ua and v_new_hr is not distinct from r.title_hr then continue; end if;
    select to_jsonb(l) into v_payload from public.lessons l where l.id = r.id;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'a2_dupes: новий номер уроку ' || r.n || ' (новий урок A2.11 «Далмація: Задар і околиці»)');
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_lex int;
begin
  -- уроки A2: 87, номери 1…87 без пропусків; A2.11 — 7 уроків, новий — 70
  if (select count(*) from public.lessons where level_code = 'A2' and status = 'PUBLISHED') <> 87
     or exists (select 1 from (select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) n
                                 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                                where m.level_code = 'A2' and l.status = 'PUBLISHED') t
                 where t.title_ua !~ ('^Урок ' || t.n || ':') or t.title_hr !~ ('^Lekcija ' || t.n || ':')) then
    raise exception 'Уроки A2: очікувалось 87 з номерами 1…87';
  end if;
  if (select count(*) from public.lessons where unit_id = '3fbc4d9b-4366-5f0f-b785-eb3f750240be' and status = 'PUBLISHED') <> 7
     or (select title_ua from public.lessons where id = '185cee8e-46a7-58b2-bc82-166ba74dc272') <> 'Урок 70: Далмація: Задар і околиці'
     or (select count(*) from (values ('5252662a-abfc-517a-9bde-8683121a53c5'::uuid, 'Урок 29: Сусіди: збори й шкода'), ('0e0d07a2-2a6c-5090-ab84-3089f20a48b8'::uuid, 'Урок 33: Відпустка й вихідні дні')) t(id, title) join public.lessons l on l.id = t.id and l.title_ua = t.title) <> 2 then
    raise exception 'Модуль A2.11 — 7 уроків, новий урок 70; нові назви уроків 29 і 33';
  end if;
  -- діалоги уроків A2: порядок 5000 + N·10 + k
  if exists (select 1 from public.conversations c join public.lessons l on l.id = c.lesson_id
              where l.level_code = 'A2' and l.status = 'PUBLISHED' and c.status = 'PUBLISHED'
                and c.order_index / 10 <> 500 + substring(l.title_ua from '^Урок ([0-9]+):')::int) then
    raise exception 'Порядок діалогів A2 не за номером уроку';
  end if;
  -- змінені й новий уроки: 20–25 слів, 2 опубліковані діалоги (6–8 реплік), 15 обов’язкових вправ, письмо й переказ, «на слух»
  select count(*) into v_bad from public.lessons l
   where l.id in ('8190831a-549a-544a-962b-4f716a895a32', 'f029711f-710e-5327-be4d-2310435e6eac', '5252662a-abfc-517a-9bde-8683121a53c5', '0e0d07a2-2a6c-5090-ab84-3089f20a48b8', '8f08356b-8efa-5ebc-906e-f409fbaadaf3', 'bf43b6bd-d547-596b-8981-55a4043cf238', '7d3c3501-a381-5b3c-a0a2-b269f3dff137', '185cee8e-46a7-58b2-bc82-166ba74dc272')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or exists (select 1 from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED'
                      and (select count(*) from public.conversation_turns t where t.conversation_id = c.id) not between 6 and 8)
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and li.required) <> 15
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and not li.required
                 and e.exercise_type in ('write_message', 'mediation')) <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and e.exercise_type = 'listening_dialogue' and e.status = 'PUBLISHED') <> 1
          or exists (select 1 from public.lesson_items li join public.exercises e on e.id = li.item_id
                      where li.lesson_id = l.id and li.item_type = 'exercise' and e.status <> 'PUBLISHED'));
  if v_bad > 0 then raise exception 'Уроки пакета: % з неправильним складом', v_bad; end if;
  -- слова уроків A2 не повторюються між уроками; прибраних слів немає в уроках A2; лікарняний — в уроці 44, не в 33
  if exists (select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id and l.level_code = 'A2' and l.status = 'PUBLISHED'
              where li.item_type = 'lexeme' group by li.item_id having count(*) > 1) then
    raise exception 'A2: слова повторюються в кількох уроках';
  end if;
  if exists (select 1 from public.lesson_items li join public.lessons l on l.id = li.lesson_id and l.level_code = 'A2' and l.status = 'PUBLISHED'
              join public.lexemes x on x.id = li.item_id where li.item_type = 'lexeme' and lower(x.lemma) in ('biti na bolovanju', 'glasna glazba', 'iskočio je osigurač', 'kapati', 'lupati', 'napredni tečaj', 'ne slažem se', 'nisi u pravu', 'persirati', 'po meni', 'polaznica', 'povraćati', 'početni tečaj', 'proljev', 'slagati se', 'smetati', 'test razine', 'tikati', 'u pravu si', 'upisati se', 'upisivati', 'utišati', 'začepiti se')) then
    raise exception 'Прибрані слова ще в уроках A2';
  end if;
  if (select count(*) from public.lesson_items li join public.lexemes x on x.id = li.item_id
       where li.item_type = 'lexeme' and li.lesson_id = '8f08356b-8efa-5ebc-906e-f409fbaadaf3' and lower(x.lemma) in ('otvoriti bolovanje', 'zatvoriti bolovanje', 'javiti se bolestan')) <> 3 then
    raise exception 'Урок 44: немає слів лікарняного з уроку 33';
  end if;
  -- «лише впізнавати»: đir
  if (select count(*) from public.lesson_items li join public.lexemes x on x.id = li.item_id
       where li.lesson_id = '185cee8e-46a7-58b2-bc82-166ba74dc272' and li.item_type = 'lexeme' and li.target_skill = 'recognition') <> 1 then
    raise exception 'Новий урок: слово «лише впізнавати» без target_skill = recognition';
  end if;
  -- нові слова: опубліковані, з мітками; наявні — рівень A2
  select count(*) into v_lex from public.lexemes where lower(lemma) in ('uvjerljiv', 'popustiti', 'inzistirati', 'opravdan', 'razina znanja', 'konverzacija', 'zaostajati', 'samostalno učiti', 'procuriti', 'fasada', 'popravak krova', 'nadoknada štete', 'zamjena smjene', 'kolektivni godišnji odmor', 'prenijeti dane', 'pravo na godišnji', 'rok završetka', 'kašnjenje radova', 'plaćanje gotovinom', 'gostoprimstvo', 'nutkati', 'zadarski', 'solana', 'ljekovito blato', 'crkvica', 'kraljevski grad', 'starohrvatski', 'arheološko nalazište', 'penjač', 'penjalište', 'stijena', 'uže', 'slobodno penjanje', 'marina', 'izletnički brod', 'cjelodnevni izlet', 'ribarska brodica', 'ulov', 'turistička sezona', 'izvan sezone', 'tempo života', 'sezonski posao', 'đir') and status = 'PUBLISHED'
     and register is not null and regionality is not null and usage_tags is not null;
  if v_lex <> 43 then raise exception 'Нових слів: % (очікувалось 43)', v_lex; end if;
  if exists (select 1 from public.lexemes where lower(lemma) in ('dokaz', 'ispravljati', 'sudjelovati', 'morska sol') and status = 'PUBLISHED' and cefr <> 'A2')
     or not exists (select 1 from public.lexemes where lower(lemma) = 'đir' and register = 'colloquial' and regionality = 'Dalmatia') then
    raise exception 'Рівень наявних слів (A2) чи мітки đir';
  end if;
  -- діалоги: нові назви; однакових назв в A0–A2 більше немає
  if (select count(*) from (values ('2c8cd7ee-e3d3-58d3-8ffe-420bf19fdb8e'::uuid, 'Prijava u hotel'), ('9140c599-ceba-5bbb-8214-54c16f55a70c'::uuid, 'Pogreška u računu'), ('dc69dcd8-ddd4-5c6c-b7c8-2d9b9d770f84'::uuid, 'Rang-lista'), ('14d9a946-c3e1-58cf-bff8-0c2cca867149'::uuid, 'Dobio sam otkaz'), ('82cdf22b-ae0c-5783-898e-bed827a54a1e'::uuid, 'Zamjena vozačke dozvole'), ('b4dd1542-9a39-5b6b-b285-9b12c3a68061'::uuid, 'Rad od kuće: za i protiv')) t(id, title) join public.conversations c on c.id = t.id and c.title_hr = t.title) <> 6 then
    raise exception 'Діалоги не перейменовано';
  end if;
  if exists (select 1 from public.conversations c join public.lessons l on l.id = c.lesson_id and l.level_code in ('A0', 'A1', 'A2') and l.status = 'PUBLISHED'
              where c.status = 'PUBLISHED' group by lower(c.title_hr) having count(*) > 1) then
    raise exception 'Однакові назви діалогів в A0–A2';
  end if;
  raise notice 'Готово: 20261119_a2_dupes_1_lessons.sql — уроки 9, 27, 29, 33, 38, 44, 70 без дублів, новий урок 70 «Далмація: Задар і околиці», 43 нових слів, 6 назв діалогів, уроків A2 — 87';
end $$;

commit;
