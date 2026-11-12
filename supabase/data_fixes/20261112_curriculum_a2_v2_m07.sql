-- =====================================================================
-- Програма A2 v2 · модуль A2.7 «Здоров’я: система й самопочуття» · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2.py 7 (не редагуйте вручну).
--
-- Рішення власника 2026-11-12: 20–25 нових слів на урок, 90–95 % слів — нові для рівня, діалоги під тему,
-- частіше Даша / Дар’я; «Прослухайте діалог чи оголошення» в кожному уроці; бета (PUBLISHED).
--   * Уроки 43–47 (5): слів у них 105. Кожен: 20–25 слів, 2 діалоги, 15 вправ
--     (одна — «Прослухайте діалог чи оголошення»), «Напишіть повідомлення» і «Перекажіть другу» (ua → hr, необов’язкові), 20 хв.
--   * Слова: 105 (нові — PUBLISHED; ті, що вже є в словнику, не змінюються).
--   * Модуль і юніт A2.7 → PUBLISHED. Потрібен уже запущений 20261112_curriculum_a2_v2_00_structure.sql.
--   * Нічого не видаляє. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.units where id = 'bdffb239-0f67-5481-ab8a-af81744b9fa3') then
    raise exception 'Спершу запустіть 20261112_curriculum_a2_v2_00_structure.sql (структура A2 v2)';
  end if;
  if not exists (select 1 from pg_constraint where conname = 'exercises_type_check' and conrelid = 'public.exercises'::regclass
                  and pg_get_constraintdef(oid) like '%listening_dialogue%') then
    raise exception 'Спершу потрібна міграція M23 (listening_dialogue)';
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

create or replace function pg_temp.ex_task(p_lesson uuid, p_pos int, p_id uuid, p_type text, p_question text, p_answer text,
                                           p_level text, p_status text, p_task jsonb, p_required boolean, p_skill text) returns int language plpgsql as $f$
begin
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, task)
  values (p_id, p_type, p_question, p_answer, null, p_level, 0, p_status, p_task) on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, required, target_skill)
  values (p_lesson, 'exercise', p_id, p_pos + 1, p_required, p_skill);
  return p_pos + 1;
end $f$;

-- 1. Слова уроків A2.7 (105): нові — PUBLISHED (бета); наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A2', t.ua, t.vtype, t.forms, t.examples, 'PUBLISHED', 'claude_curriculum_a2_v2'
  from jsonb_to_recordset('[{"lemma": "liječnik opće prakse", "normalized": "lijecnik opce prakse", "pos": "phrase", "ua": "лікар загальної практики", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Liječnik opće prakse radi u domu zdravlja."]}, {"lemma": "izabrani liječnik", "normalized": "izabrani lijecnik", "pos": "phrase", "ua": "обраний (сімейний) лікар", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Prvo se javite izabranom liječniku."]}, {"lemma": "e-uputnica", "normalized": "e-uputnica", "pos": "noun", "ua": "електронне направлення", "vtype": "core", "forms": {"gender": "f"}, "examples": ["E-uputnica je odmah u sustavu."]}, {"lemma": "specijalistički pregled", "normalized": "specijalisticki pregled", "pos": "phrase", "ua": "огляд у фахівця", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Na specijalistički pregled čekam tri mjeseca."]}, {"lemma": "kardiolog", "normalized": "kardiolog", "pos": "noun", "ua": "кардіолог", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Kardiolog mi je snimio EKG."]}, {"lemma": "dermatolog", "normalized": "dermatolog", "pos": "noun", "ua": "дерматолог", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Zbog madeža idem dermatologu."]}, {"lemma": "ortoped", "normalized": "ortoped", "pos": "noun", "ua": "ортопед", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ortoped kaže da imam ravna stopala."]}, {"lemma": "neurolog", "normalized": "neurolog", "pos": "noun", "ua": "невролог", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Zbog glavobolje me šalju neurologu."]}, {"lemma": "oftalmolog", "normalized": "oftalmolog", "pos": "noun", "ua": "офтальмолог", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Oftalmolog mi je propisao naočale."]}, {"lemma": "vađenje krvi", "normalized": "vadenje krvi", "pos": "phrase", "ua": "забір крові", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Vađenje krvi je ujutro natašte."]}, {"lemma": "natašte", "normalized": "nataste", "pos": "adverb", "ua": "натщесерце", "vtype": "core", "forms": {}, "examples": ["Na pregled dođite natašte."]}, {"lemma": "nalaz", "normalized": "nalaz", "pos": "noun", "ua": "результат аналізу", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Nalaz krvi je dobar."]}, {"lemma": "e-recept", "normalized": "e-recept", "pos": "noun", "ua": "електронний рецепт", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Liječnik mi je poslao e-recept u ljekarnu."]}, {"lemma": "privatna poliklinika", "normalized": "privatna poliklinika", "pos": "phrase", "ua": "приватна поліклініка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U privatnoj poliklinici nema čekanja, ali je skupo."]}, {"lemma": "termin za pregled", "normalized": "termin za pregled", "pos": "phrase", "ua": "час огляду", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Dobila sam termin za pregled u srijedu."]}, {"lemma": "karton", "normalized": "karton", "pos": "noun", "ua": "медична картка", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Sve je zapisano u Vašem kartonu."]}, {"lemma": "dijagnoza", "normalized": "dijagnoza", "pos": "noun", "ua": "діагноз", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Još ne znam dijagnozu."]}, {"lemma": "krvna slika", "normalized": "krvna slika", "pos": "phrase", "ua": "загальний аналіз крові", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Krvna slika je uredna."]}, {"lemma": "trnci", "normalized": "trnci", "pos": "noun", "ua": "поколювання, мурашки", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Osjećam trnce u ruci."]}, {"lemma": "kontrolni pregled", "normalized": "kontrolni pregled", "pos": "phrase", "ua": "контрольний огляд", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Kontrolni pregled je za mjesec dana."]}, {"lemma": "ginekolog", "normalized": "ginekolog", "pos": "noun", "ua": "гінеколог", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Naručila sam se kod ginekologa."]}, {"lemma": "snimiti EKG", "normalized": "snimiti ekg", "pos": "phrase", "ua": "зробити ЕКГ", "vtype": "chunk", "forms": {}, "examples": ["Prije operacije treba snimiti EKG."]}, {"lemma": "bolovanje radi njege djeteta", "normalized": "bolovanje radi njege djeteta", "pos": "phrase", "ua": "лікарняний по догляду за дитиною", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Uzela sam bolovanje radi njege djeteta."]}, {"lemma": "njega djeteta", "normalized": "njega djeteta", "pos": "phrase", "ua": "догляд за дитиною", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Njega djeteta traje dok dijete ne ozdravi."]}, {"lemma": "potvrda o privremenoj nesposobnosti", "normalized": "potvrda o privremenoj nesposobnosti", "pos": "phrase", "ua": "довідка про тимчасову непрацездатність", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Poslodavcu šaljem potvrdu o privremenoj nesposobnosti."]}, {"lemma": "nesposoban za rad", "normalized": "nesposoban za rad", "pos": "phrase", "ua": "непрацездатний", "vtype": "chunk", "forms": {}, "examples": ["Liječnik kaže da sam nesposobna za rad pet dana."]}, {"lemma": "muka mi je", "normalized": "muka mi je", "pos": "phrase", "ua": "мене нудить", "vtype": "chunk", "forms": {}, "examples": ["Muka mi je od jutra."]}, {"lemma": "vrti mi se", "normalized": "vrti mi se", "pos": "phrase", "ua": "у мене паморочиться голова", "vtype": "chunk", "forms": {}, "examples": ["Kad ustanem, vrti mi se."]}, {"lemma": "slabo mi je", "normalized": "slabo mi je", "pos": "phrase", "ua": "мені погано (слабість)", "vtype": "chunk", "forms": {}, "examples": ["Slabo mi je, moram sjesti."]}, {"lemma": "povraćati", "normalized": "povracati", "pos": "verb", "ua": "блювати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Dijete je povraćalo cijelu noć."]}, {"lemma": "proljev", "normalized": "proljev", "pos": "noun", "ua": "діарея", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ima proljev i temperaturu."]}, {"lemma": "crijevna viroza", "normalized": "crijevna viroza", "pos": "phrase", "ua": "кишкова інфекція (вірусна)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U vrtiću je crijevna viroza."]}, {"lemma": "zarazan", "normalized": "zarazan", "pos": "adjective", "ua": "заразний", "vtype": "core", "forms": {}, "examples": ["Dok je zarazan, ne smije u vrtić."]}, {"lemma": "snižavati temperaturu", "normalized": "snizavati temperaturu", "pos": "phrase", "ua": "збивати температуру", "vtype": "chunk", "forms": {}, "examples": ["Temperaturu snižavamo sirupom."]}, {"lemma": "pedijatrica", "normalized": "pedijatrica", "pos": "noun", "ua": "дитяча лікарка, педіатриня", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Pedijatrica radi samo ujutro."]}, {"lemma": "ispričnica za vrtić", "normalized": "ispricnica za vrtic", "pos": "phrase", "ua": "довідка для садочка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za vrtić trebamo ispričnicu od pedijatrice."]}, {"lemma": "ležati", "normalized": "lezati", "pos": "verb", "ua": "лежати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Mora ležati tri dana."]}, {"lemma": "piti puno tekućine", "normalized": "piti puno tekucine", "pos": "phrase", "ua": "пити багато рідини", "vtype": "chunk", "forms": {}, "examples": ["Neka pije puno tekućine."]}, {"lemma": "produžiti bolovanje", "normalized": "produziti bolovanje", "pos": "phrase", "ua": "продовжити лікарняний", "vtype": "chunk", "forms": {}, "examples": ["Liječnik mi je produžio bolovanje."]}, {"lemma": "vratiti se u vrtić", "normalized": "vratiti se u vrtic", "pos": "phrase", "ua": "повернутися в садочок", "vtype": "chunk", "forms": {}, "examples": ["U ponedjeljak se vraća u vrtić."]}, {"lemma": "javiti poslodavcu", "normalized": "javiti poslodavcu", "pos": "phrase", "ua": "повідомити роботодавця", "vtype": "chunk", "forms": {}, "examples": ["Javila sam poslodavcu da sam na bolovanju."]}, {"lemma": "bolje mu je", "normalized": "bolje mu je", "pos": "phrase", "ua": "йому краще", "vtype": "chunk", "forms": {}, "examples": ["Danas mu je već bolje."]}, {"lemma": "dehidracija", "normalized": "dehidracija", "pos": "noun", "ua": "зневоднення", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Kod proljeva pazite na dehidraciju."]}, {"lemma": "kronična bolest", "normalized": "kronicna bolest", "pos": "phrase", "ua": "хронічна хвороба", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Dijabetes je kronična bolest."]}, {"lemma": "šećerna bolest", "normalized": "secerna bolest", "pos": "phrase", "ua": "цукровий діабет", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Baka ima šećernu bolest."]}, {"lemma": "povišen tlak", "normalized": "povisen tlak", "pos": "phrase", "ua": "підвищений тиск", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Imam povišen tlak već godinama."]}, {"lemma": "mjeriti tlak", "normalized": "mjeriti tlak", "pos": "phrase", "ua": "міряти тиск", "vtype": "chunk", "forms": {}, "examples": ["Tlak mjerim svako jutro."]}, {"lemma": "šećer u krvi", "normalized": "secer u krvi", "pos": "phrase", "ua": "цукор у крові", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Šećer u krvi mi je danas viši."]}, {"lemma": "inzulin", "normalized": "inzulin", "pos": "noun", "ua": "інсулін", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Inzulin uzima prije jela."]}, {"lemma": "trajna terapija", "normalized": "trajna terapija", "pos": "phrase", "ua": "постійна терапія", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na trajnoj sam terapiji za tlak."]}, {"lemma": "ponovljivi recept", "normalized": "ponovljivi recept", "pos": "phrase", "ua": "рецепт на повторні видачі", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Liječnica mi je dala ponovljivi recept."]}, {"lemma": "kutija lijekova", "normalized": "kutija lijekova", "pos": "phrase", "ua": "упаковка ліків", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Jedna kutija lijekova traje mjesec dana."]}, {"lemma": "tableta", "normalized": "tableta", "pos": "noun", "ua": "таблетка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Pijem jednu tabletu ujutro."]}, {"lemma": "nakon jela", "normalized": "nakon jela", "pos": "phrase", "ua": "після їжі", "vtype": "chunk", "forms": {}, "examples": ["Lijek uzimajte nakon jela."]}, {"lemma": "prije spavanja", "normalized": "prije spavanja", "pos": "phrase", "ua": "перед сном", "vtype": "chunk", "forms": {}, "examples": ["Drugu tabletu popijte prije spavanja."]}, {"lemma": "preskočiti", "normalized": "preskociti", "pos": "verb", "ua": "пропустити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "preskakati"}, "examples": ["Ne smijete preskočiti dozu."]}, {"lemma": "viši", "normalized": "visi", "pos": "adjective", "ua": "вищий", "vtype": "core", "forms": {}, "examples": ["Ujutro je tlak viši nego navečer."]}, {"lemma": "niži", "normalized": "nizi", "pos": "adjective", "ua": "нижчий", "vtype": "core", "forms": {}, "examples": ["Nakon šetnje mi je šećer niži."]}, {"lemma": "jači", "normalized": "jaci", "pos": "adjective", "ua": "сильніший", "vtype": "core", "forms": {}, "examples": ["Trebam jači lijek protiv bolova."]}, {"lemma": "slabiji", "normalized": "slabiji", "pos": "adjective", "ua": "слабший", "vtype": "core", "forms": {}, "examples": ["Ovaj lijek je slabiji od prošlog."]}, {"lemma": "zdrava prehrana", "normalized": "zdrava prehrana", "pos": "phrase", "ua": "здорове харчування", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Zdrava prehrana pomaže kod tlaka."]}, {"lemma": "manje soli", "normalized": "manje soli", "pos": "phrase", "ua": "менше солі", "vtype": "chunk", "forms": {}, "examples": ["Liječnik kaže da jedem manje soli."]}, {"lemma": "redoviti pregledi", "normalized": "redoviti pregledi", "pos": "phrase", "ua": "регулярні огляди", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Redoviti pregledi su važni."]}, {"lemma": "dnevnik tlaka", "normalized": "dnevnik tlaka", "pos": "phrase", "ua": "щоденник тиску", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Vodim dnevnik tlaka za liječnicu."]}, {"lemma": "ne da mi se", "normalized": "ne da mi se", "pos": "phrase", "ua": "мені не хочеться, лінь", "vtype": "chunk", "forms": {}, "examples": ["Ne da mi se danas ništa."]}, {"lemma": "spava mi se", "normalized": "spava mi se", "pos": "phrase", "ua": "мені хочеться спати", "vtype": "chunk", "forms": {}, "examples": ["Spava mi se već u osam."]}, {"lemma": "teško mi je", "normalized": "tesko mi je", "pos": "phrase", "ua": "мені важко", "vtype": "chunk", "forms": {}, "examples": ["Teško mi je usredotočiti se."]}, {"lemma": "pod stresom", "normalized": "pod stresom", "pos": "phrase", "ua": "у стресі", "vtype": "chunk", "forms": {}, "examples": ["Na poslu sam stalno pod stresom."]}, {"lemma": "izgaranje na poslu", "normalized": "izgaranje na poslu", "pos": "phrase", "ua": "професійне вигорання", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Izgaranje na poslu je sve češće."]}, {"lemma": "premoren", "normalized": "premoren", "pos": "adjective", "ua": "перевтомлений", "vtype": "core", "forms": {}, "examples": ["Premorena sam nakon smjene."]}, {"lemma": "napet", "normalized": "napet", "pos": "adjective", "ua": "напружений", "vtype": "core", "forms": {}, "examples": ["Cijeli tjedan sam napeta."]}, {"lemma": "razdražljiv", "normalized": "razdrazljiv", "pos": "adjective", "ua": "дратівливий", "vtype": "core", "forms": {}, "examples": ["Kad ne spavam, razdražljiva sam."]}, {"lemma": "usredotočiti se", "normalized": "usredotociti se", "pos": "verb", "ua": "зосередитися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "usredotočivati se"}, "examples": ["Ne mogu se usredotočiti na posao."]}, {"lemma": "loše spavati", "normalized": "lose spavati", "pos": "phrase", "ua": "погано спати", "vtype": "chunk", "forms": {}, "examples": ["Mjesecima loše spavam."]}, {"lemma": "buditi se noću", "normalized": "buditi se nocu", "pos": "phrase", "ua": "прокидатися вночі", "vtype": "chunk", "forms": {}, "examples": ["Budim se noću i ne mogu zaspati."]}, {"lemma": "zaspati", "normalized": "zaspati", "pos": "verb", "ua": "заснути", "vtype": "core", "forms": {"aspect": "pfv", "pair": "zaspivati"}, "examples": ["Zaspala sam tek u dva."]}, {"lemma": "ravnoteža posla i života", "normalized": "ravnoteza posla i zivota", "pos": "phrase", "ua": "баланс роботи й життя", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Važna mi je ravnoteža posla i života."]}, {"lemma": "isključiti mobitel", "normalized": "iskljuciti mobitel", "pos": "phrase", "ua": "вимкнути мобільний", "vtype": "chunk", "forms": {}, "examples": ["Navečer isključim mobitel."]}, {"lemma": "boravak u prirodi", "normalized": "boravak u prirodi", "pos": "phrase", "ua": "перебування на природі", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Boravak u prirodi me smiruje."]}, {"lemma": "smirivati", "normalized": "smirivati", "pos": "verb", "ua": "заспокоювати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Glazba me smiruje."]}, {"lemma": "opuštanje", "normalized": "opustanje", "pos": "noun", "ua": "розслаблення", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Za opuštanje idem plivati."]}, {"lemma": "savjetovalište", "normalized": "savjetovaliste", "pos": "noun", "ua": "консультаційний центр", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Savjetovalište nudi besplatne razgovore."]}, {"lemma": "psihoterapeut", "normalized": "psihoterapeut", "pos": "noun", "ua": "психотерапевт", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Razgovaram s psihoterapeutom jednom tjedno."]}, {"lemma": "zatražiti pomoć", "normalized": "zatraziti pomoc", "pos": "phrase", "ua": "попросити допомоги", "vtype": "chunk", "forms": {}, "examples": ["Nije sramota zatražiti pomoć."]}, {"lemma": "napuniti baterije", "normalized": "napuniti baterije", "pos": "phrase", "ua": "відновити сили («зарядити батарейки»)", "vtype": "chunk", "forms": {}, "examples": ["Vikendom punim baterije na moru."]}, {"lemma": "razboljeti se", "normalized": "razboljeti se", "pos": "verb", "ua": "захворіти", "vtype": "core", "forms": {"aspect": "pfv", "pair": "razbolijevati se"}, "examples": ["Razboljela sam se odmah nakon putovanja."]}, {"lemma": "prehladiti se", "normalized": "prehladiti se", "pos": "verb", "ua": "застудитися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "prehlađivati se"}, "examples": ["Prehladio sam se na kiši."]}, {"lemma": "liječiti se", "normalized": "lijeciti se", "pos": "verb", "ua": "лікуватися", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "izliječiti se"}, "examples": ["Liječila sam se dva tjedna."]}, {"lemma": "izliječiti se", "normalized": "izlijeciti se", "pos": "verb", "ua": "вилікуватися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "liječiti se"}, "examples": ["Napokon sam se izliječila."]}, {"lemma": "oporaviti se", "normalized": "oporaviti se", "pos": "verb", "ua": "одужати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "oporavljati se"}, "examples": ["Oporavio se brže nego što smo mislili."]}, {"lemma": "upala pluća", "normalized": "upala pluca", "pos": "phrase", "ua": "запалення легень", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Prošle zime sam imala upalu pluća."]}, {"lemma": "ležati u bolnici", "normalized": "lezati u bolnici", "pos": "phrase", "ua": "лежати в лікарні", "vtype": "chunk", "forms": {}, "examples": ["Tjedan dana sam ležao u bolnici."]}, {"lemma": "primiti u bolnicu", "normalized": "primiti u bolnicu", "pos": "phrase", "ua": "покласти в лікарню", "vtype": "chunk", "forms": {}, "examples": ["Primili su me u bolnicu zbog visoke temperature."]}, {"lemma": "otpustiti iz bolnice", "normalized": "otpustiti iz bolnice", "pos": "phrase", "ua": "виписати з лікарні", "vtype": "chunk", "forms": {}, "examples": ["Otpustili su me iz bolnice u petak."]}, {"lemma": "otpusno pismo", "normalized": "otpusno pismo", "pos": "phrase", "ua": "виписка з лікарні", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Otpusno pismo odnesite obiteljskom liječniku."]}, {"lemma": "operirati", "normalized": "operirati", "pos": "verb", "ua": "оперувати", "vtype": "core", "forms": {"aspect": "biasp"}, "examples": ["Operirali su mu koljeno."]}, {"lemma": "slomiti", "normalized": "slomiti", "pos": "verb", "ua": "зламати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "lomiti"}, "examples": ["Na skijanju sam slomila ruku."]}, {"lemma": "uganuti", "normalized": "uganuti", "pos": "verb", "ua": "підвернути, розтягнути (суглоб)", "vtype": "core", "forms": {"aspect": "pfv"}, "examples": ["Uganula sam gležanj na stepenicama."]}, {"lemma": "gležanj", "normalized": "glezanj", "pos": "noun", "ua": "щиколотка", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Gležanj mi je natekao."]}, {"lemma": "nateći", "normalized": "nateci", "pos": "verb", "ua": "набрякнути", "vtype": "core", "forms": {"aspect": "pfv", "pair": "naticati"}, "examples": ["Ruka je natekla nakon pada."]}, {"lemma": "fizikalna terapija", "normalized": "fizikalna terapija", "pos": "phrase", "ua": "фізіотерапія", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Poslije gipsa sam išla na fizikalnu terapiju."]}, {"lemma": "posljedice", "normalized": "posljedice", "pos": "noun", "ua": "наслідки", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Srećom, nema posljedica."]}, {"lemma": "prvih dana", "normalized": "prvih dana", "pos": "phrase", "ua": "у перші дні", "vtype": "chunk", "forms": {}, "examples": ["Prvih dana nisam mogla hodati."]}, {"lemma": "postupno", "normalized": "postupno", "pos": "adverb", "ua": "поступово", "vtype": "core", "forms": {}, "examples": ["Postupno mi je bilo sve bolje."]}, {"lemma": "opet sam na nogama", "normalized": "opet sam na nogama", "pos": "phrase", "ua": "я знову на ногах", "vtype": "chunk", "forms": {}, "examples": ["Nakon tri tjedna opet sam na nogama."]}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 2. Уроки модуля A2.7
-- A2.7 · урок 43: Сімейний лікар і направлення — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'bdffb239-0f67-5481-ab8a-af81744b9fa3';
  v_lesson constant uuid := '468ce636-fdba-5b52-9695-dc9daa6a032b';
  v_gid constant uuid := '879e6305-0f75-5e88-abff-e27819f2d92d';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики GLAS'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A2.7: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 43: Сімейний лікар і направлення', 'Lekcija 43: Obiteljski liječnik i uputnica', '["Записатися до сімейного лікаря й отримати направлення до фахівця", "Звукові зміни: liječnik — liječnici, ruka — u ruci"]'::jsonb, 20, 'PUBLISHED', 1);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'liječnik opće prakse', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izabrani liječnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'e-uputnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'specijalistički pregled', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kardiolog', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dermatolog', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ortoped', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neurolog', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oftalmolog', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vađenje krvi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'natašte', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nalaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'e-recept', v_pos);
  v_pos := pg_temp.word(v_lesson, 'privatna poliklinika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'termin za pregled', v_pos);
  v_pos := pg_temp.word(v_lesson, 'karton', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dijagnoza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krvna slika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trnci', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kontrolni pregled', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ginekolog', v_pos);
  v_pos := pg_temp.word(v_lesson, 'snimiti EKG', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a0d684e6-1251-53a3-8b51-459cd32ab9b7', 'fill_in_the_blank', 'Osjećam bol u ___ već tjedan dana.', 'ruci', '["ruku", "ruka", "ruci", "rukom"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3f88964f-d220-51b9-b243-f101a8caae38', 'multiple_choice', 'Що означає «krvna slika»?', 'загальний аналіз крові', '["ортопед", "натщесерце", "лікар загальної практики", "загальний аналіз крові"]'::jsonb, 'A2', 2, 'PUBLISHED', 'krvna slika', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e25db8cf-7db6-5a80-b0c7-8df0c86e5e82', 'multiple_choice', 'Що означає «nalaz»?', 'результат аналізу', '["обраний (сімейний) лікар", "результат аналізу", "зробити ЕКГ", "медична картка"]'::jsonb, 'A2', 3, 'PUBLISHED', 'nalaz', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '06ea74f5-d1ed-5714-ba0f-6cb1e8d54b90', 'multiple_choice', 'Що означає «snimiti EKG»?', 'зробити ЕКГ', '["зробити ЕКГ", "діагноз", "медична картка", "офтальмолог"]'::jsonb, 'A2', 4, 'PUBLISHED', 'snimiti EKG', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3daab072-2c97-51f3-a59e-4ddc6849dc38', 'multiple_choice', 'Як хорватською «поколювання, мурашки»?', 'trnci', '["specijalistički pregled", "oftalmolog", "trnci", "e-uputnica"]'::jsonb, 'A2', 5, 'PUBLISHED', 'trnci', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9c9e9f24-610e-5e7e-8c4b-7809e8fbf902', 'multiple_choice', 'Як хорватською «ортопед»?', 'ortoped', '["dijagnoza", "trnci", "vađenje krvi", "ortoped"]'::jsonb, 'A2', 6, 'PUBLISHED', 'ortoped', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '292a7df7-c70d-51cb-816a-aa691584ee3d', 'type_answer', 'Напишіть хорватською: «невролог»', 'neurolog', null, 'A2', 7, 'PUBLISHED', 'neurolog', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e1f4076d-018e-554c-813a-189c964199c6', 'type_answer', 'Напишіть хорватською: «електронне направлення»', 'e-uputnica', null, 'A2', 8, 'PUBLISHED', 'e-uputnica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5100e9bf-2595-5629-866b-b0cfb058f9e8', 'type_answer', 'Напишіть хорватською: «офтальмолог»', 'oftalmolog', null, 'A2', 9, 'PUBLISHED', 'oftalmolog', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2ed65507-396c-51e5-bd36-c2e173f5a284', 'sentence_builder', 'Складіть: «Приходьте на огляд натщесерце.»', 'Na pregled dođite natašte.', '["Na", "pregled", "natašte.", "dođite"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d7e1e73-e6e6-517c-a971-44f708c480cc', 'sentence_builder', 'Складіть: «Лікарі працюють у дві зміни.»', 'Liječnici rade u dvije smjene.', '["Liječnici", "rade", "smjene.", "u", "dvije"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2bddffef-1760-5e9a-be58-5f06f422dd0a', 'listening', 'Прослухайте і складіть фразу', 'Jesu, liječnici će Vam ih objasniti.', '["liječnici", "Jesu,", "će", "Vam", "objasniti.", "ih"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '01d17835-c953-5234-99d8-0d7e5f70a689', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'кардіологія; у четвер о 10:00; направлення й старі результати', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Вам телефонували з лікарні.", "script": [{"hr": "Dobar dan, zovemo iz bolnice Sveti Duh, odjel kardiologije.", "ua": "Добрий день, телефонуємо з лікарні Святого Духа, кардіологічне відділення."}, {"hr": "Vaš termin za pregled je pomaknut na četvrtak, devetnaestog, u deset sati.", "ua": "Ваш огляд перенесено на четвер, дев’ятнадцяте, на десяту."}, {"hr": "Ponesite uputnicu i stare nalaze.", "ua": "Візьміть направлення й старі результати."}], "questions": [{"q_ua": "Яке відділення телефонувало?", "options": ["кардіологія", "неврологія", "дерматологія"], "correct": 0, "answer_turn": 0}, {"q_ua": "Коли новий огляд?", "options": ["у середу о 9:00", "у четвер о 10:00", "у п’ятницю о 10:00"], "correct": 1, "answer_turn": 1}, {"q_ua": "Що треба взяти?", "options": ["рецепт", "страховий поліс", "направлення й старі результати"], "correct": 2, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '01d17835-c953-5234-99d8-0d7e5f70a689', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9c4e54bc-fddb-5734-b026-867854d43315', 'speaking', 'Мені потрібне направлення до кардіолога.', 'Trebam uputnicu za kardiologa.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c38d51c-b401-55c3-ad81-8675f1af0135', 'speaking', 'Скільки чекати на огляд?', 'Koliko se čeka na pregled?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '6d2fafad-15a5-5406-93cf-d697bce6491d', 'write_message', 'Напишіть сімейному лікарю: у вас тиждень болить спина, і ви просите направлення до ортопеда.', 'Poštovana doktorice, već tjedan dana me bole leđa. Molim Vas uputnicu za ortopeda.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть сімейному лікарю: у вас тиждень болить спина, і ви просите направлення до ортопеда.", "points": [{"ua": "болить спина", "keys": [["leđ"]]}, {"ua": "тиждень", "keys": [["tjed"]]}, {"ua": "направлення до ортопеда", "keys": [["uputnic"], ["ortoped"]]}], "hints": ["već tjedan dana me bole leđa", "molim Vas uputnicu", "za ortopeda"], "models": ["Poštovana doktorice, već tjedan dana me bole leđa. Molim Vas uputnicu za ortopeda."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '6d2fafad-15a5-5406-93cf-d697bce6491d', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '998bf6ce-b2fa-58b6-95b1-a450c1521b35', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Došla je na vađenje krvi i natašte je.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи медсестрі, що я прийшла на забір крові і я натщесерце.", "direction": "ua_hr", "points": [{"ua": "забір крові", "keys": [["vađenj"], ["krv"]]}, {"ua": "натщесерце", "keys": [["natašte"]]}], "hints": [], "models": ["Došla je na vađenje krvi i natašte je."], "source_ua": "Скажи медсестрі, що я прийшла на забір крові і я натщесерце."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '998bf6ce-b2fa-58b6-95b1-a450c1521b35', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('22d1131d-7c5c-5be6-83a2-2d44309e55ca', v_lesson, 'Направлення', 'Uputnica', 5431, 'A2', 'health', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('a0531775-deb5-51ef-ab58-f3d7ad5264f9', '22d1131d-7c5c-5be6-83a2-2d44309e55ca', 'Darja', 'Dobar dan, doktorice. Već tjedan dana osjećam trnce u ruci.', 'Добрий день, пані лікарко. Уже тиждень я відчуваю поколювання в руці.', 1);
  perform pg_temp.turn('de9ff194-8bcf-550e-b848-66dd848146dc', '22d1131d-7c5c-5be6-83a2-2d44309e55ca', 'Liječnica', 'Dat ću Vam e-uputnicu za neurologa.', 'Я дам вам електронне направлення до невролога.', 2);
  perform pg_temp.turn('454ec820-94ce-577c-8772-f8b5e72f9341', '22d1131d-7c5c-5be6-83a2-2d44309e55ca', 'Darja', 'Koliko se čeka na specijalistički pregled?', 'Скільки чекати на огляд у фахівця?', 3);
  perform pg_temp.turn('b56f6777-8b5b-5fd5-8b1e-7c2ca8f29c9c', '22d1131d-7c5c-5be6-83a2-2d44309e55ca', 'Liječnica', 'Oko dva mjeseca. Ako ne želite čekati, postoji privatna poliklinika.', 'Близько двох місяців. Якщо не хочете чекати, є приватна поліклініка.', 4);
  perform pg_temp.turn('7d3786e0-ad5f-52b9-b111-385bf00fc9c0', '22d1131d-7c5c-5be6-83a2-2d44309e55ca', 'Darja', 'Trebam li prije toga napraviti nalaze krvi?', 'Мені треба перед тим здати аналізи крові?', 5);
  perform pg_temp.turn('22d5fcde-95af-56fb-a759-59cdb200ee5a', '22d1131d-7c5c-5be6-83a2-2d44309e55ca', 'Liječnica', 'Da. Vađenje krvi je ujutro, dođite natašte.', 'Так. Забір крові — уранці, приходьте натщесерце.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a6c3344f-70d1-5470-893a-19bf6215b1a4', v_lesson, 'У медсестри', 'Kod medicinske sestre', 5432, 'A2', 'health', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('6775d6c6-a7bd-5d04-89c5-8462275315ab', 'a6c3344f-70d1-5470-893a-19bf6215b1a4', 'Ivan', 'Dobar dan, imam termin za pregled u devet.', 'Добрий день, у мене огляд о дев’ятій.', 1);
  perform pg_temp.turn('da3193ef-afdf-5e5c-8a2f-9a615a066e7b', 'a6c3344f-70d1-5470-893a-19bf6215b1a4', 'Sestra', 'Vaše ime? Da, tu ste u kartonu. Sjednite, izmjerit ću Vam tlak.', 'Ваше ім’я? Так, ось ви в картці. Сідайте, я виміряю вам тиск.', 2);
  perform pg_temp.turn('6bf66572-ea55-5cbf-921f-4132dbd462a2', 'a6c3344f-70d1-5470-893a-19bf6215b1a4', 'Ivan', 'Jesu li stigli moji nalazi?', 'Мої результати вже прийшли?', 3);
  perform pg_temp.turn('d83aca7d-0138-5074-b9e7-96a9dc83adad', 'a6c3344f-70d1-5470-893a-19bf6215b1a4', 'Sestra', 'Jesu, liječnici će Vam ih objasniti.', 'Так, лікарі вам їх пояснять.', 4);
  perform pg_temp.turn('a65b5dc2-b4d7-594a-b82a-ea206cf7c587', 'a6c3344f-70d1-5470-893a-19bf6215b1a4', 'Ivan', 'Hvala. I još imam modricu na nozi.', 'Дякую. І ще в мене синець на нозі.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.7 · урок 44: Лікарняний для себе й для дитини — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'bdffb239-0f67-5481-ab8a-af81744b9fa3';
  v_lesson constant uuid := '8f08356b-8efa-5ebc-906e-f409fbaadaf3';
  v_gid constant uuid := '9c01b59a-6b4f-52a9-abfd-d78278072098';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики BEZL'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A2.7: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 44: Лікарняний для себе й для дитини', 'Lekcija 44: Bolovanje za sebe i za dijete', '["Оформити лікарняний для себе й по догляду за дитиною", "Описати стан безособово: Muka mi je, Djetetu je loše"]'::jsonb, 20, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'bolovanje radi njege djeteta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'njega djeteta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potvrda o privremenoj nesposobnosti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nesposoban za rad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'muka mi je', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrti mi se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slabo mi je', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povraćati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'proljev', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crijevna viroza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zarazan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'snižavati temperaturu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pedijatrica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispričnica za vrtić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ležati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'piti puno tekućine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'produžiti bolovanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vratiti se u vrtić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'javiti poslodavcu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bolje mu je', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dehidracija', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '7aef80f2-21e5-5891-a604-b1af3c210195', 'fill_in_the_blank', 'Jutros ___ je bilo jako loše.', 'mi', '["me", "mi", "moj", "ja"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f3675612-8c79-5fcc-a808-141a0f16ca6d', 'multiple_choice', 'Що означає «vratiti se u vrtić»?', 'повернутися в садочок', '["довідка про тимчасову непрацездатність", "повернутися в садочок", "повідомити роботодавця", "заразний"]'::jsonb, 'A2', 2, 'PUBLISHED', 'vratiti se u vrtić', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '19f27471-14cf-5dec-a6d3-716e8e715d3a', 'multiple_choice', 'Що означає «slabo mi je»?', 'мені погано (слабість)', '["лежати", "повідомити роботодавця", "мені погано (слабість)", "довідка про тимчасову непрацездатність"]'::jsonb, 'A2', 3, 'PUBLISHED', 'slabo mi je', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '04002ffc-ce54-580f-b869-04e1d6ef5ea7', 'multiple_choice', 'Що означає «ispričnica za vrtić»?', 'довідка для садочка', '["мені погано (слабість)", "зневоднення", "довідка для садочка", "кишкова інфекція (вірусна)"]'::jsonb, 'A2', 4, 'PUBLISHED', 'ispričnica za vrtić', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0f68557e-c40a-5543-9835-713a4bd94ef2', 'multiple_choice', 'Що означає «potvrda o privremenoj nesposobnosti»?', 'довідка про тимчасову непрацездатність', '["пити багато рідини", "довідка про тимчасову непрацездатність", "діарея", "мене нудить"]'::jsonb, 'A2', 5, 'PUBLISHED', 'potvrda o privremenoj nesposobnosti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f1004126-af99-509a-9cd7-55759a6f506e', 'multiple_choice', 'Як хорватською «заразний»?', 'zarazan', '["javiti poslodavcu", "vratiti se u vrtić", "zarazan", "povraćati"]'::jsonb, 'A2', 6, 'PUBLISHED', 'zarazan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '57ca405f-77bf-5a2c-ae93-09e3d1ccf483', 'multiple_choice', 'Як хорватською «діарея»?', 'proljev', '["vratiti se u vrtić", "bolovanje radi njege djeteta", "proljev", "javiti poslodavcu"]'::jsonb, 'A2', 7, 'PUBLISHED', 'proljev', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e66efeb9-c461-5be9-a5f6-4c78b5c94dc0', 'type_answer', 'Напишіть хорватською: «блювати»', 'povraćati', null, 'A2', 8, 'PUBLISHED', 'povraćati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e4144b5-c219-591d-9f4c-2748324aa5e3', 'type_answer', 'Напишіть хорватською: «зневоднення»', 'dehidracija', null, 'A2', 9, 'PUBLISHED', 'dehidracija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a443c307-e1be-5211-b363-d19287bd15c5', 'sentence_builder', 'Складіть: «Мене нудить зранку.»', 'Muka mi je od jutra.', '["mi", "Muka", "je", "jutra.", "od"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3b876edc-0a7d-5d5e-b2d5-6a42644ba47f', 'sentence_builder', 'Складіть: «Сьогодні йому вже краще.»', 'Danas mu je već bolje.', '["mu", "bolje.", "već", "Danas", "je"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '70448b20-13c1-57d7-b817-7797f0b14ffa', 'listening', 'Прослухайте і складіть фразу', 'Jutros, kad sam ustala. Slabo mi je bilo i na poslu.', '["ustala.", "bilo", "mi", "i", "Slabo", "na", "sam", "Jutros,", "kad", "poslu.", "je"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '39d189f6-b65b-562f-a392-b29255b46542', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'їй погано, температура; якнайшвидше її забрати; довідка від педіатра', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Виховательниця з садочка залишила вам повідомлення.", "script": [{"hr": "Dobar dan, zovem iz vrtića Maslačak.", "ua": "Добрий день, телефоную із садочка «Кульбабка»."}, {"hr": "Vašoj kćeri je danas bilo slabo i ima temperaturu.", "ua": "Вашій доньці сьогодні стало погано, і в неї температура."}, {"hr": "Molimo Vas da dođete po nju što prije.", "ua": "Просимо вас якнайшвидше її забрати."}, {"hr": "Prije povratka u vrtić treba ispričnica od pedijatra.", "ua": "Перед поверненням у садочок потрібна довідка від педіатра."}], "questions": [{"q_ua": "Що з донькою?", "options": ["їй погано, температура", "вона впала", "у неї алергія"], "correct": 0, "answer_turn": 1}, {"q_ua": "Про що просять?", "options": ["привести її завтра", "якнайшвидше її забрати", "передзвонити педіатру"], "correct": 1, "answer_turn": 2}, {"q_ua": "Що потрібно перед поверненням?", "options": ["аналізи", "нова медкартка", "довідка від педіатра"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '39d189f6-b65b-562f-a392-b29255b46542', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6ef1ad4a-8b42-5170-8b9e-ef05fd9306e6', 'speaking', 'У мене паморочиться голова.', 'Vrti mi se.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c4e01199-5df5-5c56-b071-5f5c306d8558', 'speaking', 'Мені потрібен лікарняний по догляду за дитиною.', 'Trebam bolovanje radi njege djeteta.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '12553d7a-04ea-51e8-a5d4-8ef2c60dad52', 'write_message', 'Напишіть керівнику: ваша дитина хвора, ви берете лікарняний по догляду за дитиною до п’ятниці.', 'Poštovani, moje dijete je bolesno pa sam na bolovanju radi njege djeteta do petka.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть керівнику: ваша дитина хвора, ви берете лікарняний по догляду за дитиною до п’ятниці.", "points": [{"ua": "дитина хвора", "keys": [["bolesn"]]}, {"ua": "лікарняний по догляду", "keys": [["njeg"], ["bolovanj"]]}, {"ua": "до п’ятниці", "keys": [["petk"]]}], "hints": ["moje dijete je bolesno", "bolovanje radi njege djeteta", "do petka"], "models": ["Poštovani, moje dijete je bolesno pa sam na bolovanju radi njege djeteta do petka."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '12553d7a-04ea-51e8-a5d4-8ef2c60dad52', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '39786143-e03e-5ebe-9c59-6e0dad9e1784', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Njezinoj kćeri je muka i vrti joj se od jučer.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи лікарці, що мою доньку нудить і в неї паморочиться голова з учорашнього дня.", "direction": "ua_hr", "points": [{"ua": "нудить", "keys": [["muka"]]}, {"ua": "паморочиться", "keys": [["vrti"]]}, {"ua": "з учора", "keys": [["jučer"]]}], "hints": [], "models": ["Njezinoj kćeri je muka i vrti joj se od jučer."], "source_ua": "Скажи лікарці, що мою доньку нудить і в неї паморочиться голова з учорашнього дня."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '39786143-e03e-5ebe-9c59-6e0dad9e1784', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c590ba13-4ead-5ddf-a528-f7ed37bbf8be', v_lesson, 'Дитина хвора', 'Dijete je bolesno', 5441, 'A2', 'health', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('42d81fa7-875a-5521-a1f1-d0cf5882b1fc', 'c590ba13-4ead-5ddf-a528-f7ed37bbf8be', 'Darja', 'Dobar dan, Filip je povraćao cijelu noć i ima proljev.', 'Добрий день, Філіпа всю ніч нудило, і в нього діарея.', 1);
  perform pg_temp.turn('65abf870-70e5-5d96-8658-95b6622f4979', 'c590ba13-4ead-5ddf-a528-f7ed37bbf8be', 'Pedijatrica', 'U vrtiću je crijevna viroza. Ima li temperaturu?', 'У садочку кишкова інфекція. У нього є температура?', 2);
  perform pg_temp.turn('1b8a4643-e5ac-591c-bdad-babfd22a388b', 'c590ba13-4ead-5ddf-a528-f7ed37bbf8be', 'Darja', 'Ima, toplomjer je pokazao trideset osam i pol.', 'Є, градусник показав тридцять вісім з половиною.', 3);
  perform pg_temp.turn('e3acaf29-3bd5-5f56-8799-f83037c993b3', 'c590ba13-4ead-5ddf-a528-f7ed37bbf8be', 'Pedijatrica', 'Neka leži i pije puno tekućine. Dok je zarazan, ne smije u vrtić.', 'Хай лежить і п’є багато рідини. Поки заразний, у садочок не можна.', 4);
  perform pg_temp.turn('c9fd6d4b-55ba-57fd-ad2b-b35161159aac', 'c590ba13-4ead-5ddf-a528-f7ed37bbf8be', 'Darja', 'Trebam bolovanje radi njege djeteta. Radim u trgovini.', 'Мені потрібен лікарняний по догляду за дитиною. Я працюю в магазині.', 5);
  perform pg_temp.turn('62ab83b3-71ce-536f-bc6b-3b596961b9f9', 'c590ba13-4ead-5ddf-a528-f7ed37bbf8be', 'Pedijatrica', 'Javite se svojoj liječnici, ona Vam otvara bolovanje. Ja ću napisati ispričnicu za vrtić.', 'Зверніться до своєї лікарки, вона відкриває вам лікарняний. Я напишу довідку для садочка.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('384be560-56c7-51e2-9893-766f94eb16b4', v_lesson, 'Мені погано', 'Loše mi je', 5442, 'A2', 'health', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('b746ad51-47db-5198-a8ea-f6bbe3d73ebb', '384be560-56c7-51e2-9893-766f94eb16b4', 'Daša', 'Doktore, muka mi je od jutra i vrti mi se.', 'Лікарю, мене нудить зранку, і паморочиться голова.', 1);
  perform pg_temp.turn('88a8c10a-90ea-5531-afc5-b63697d095ca', '384be560-56c7-51e2-9893-766f94eb16b4', 'Liječnik', 'Kada Vam je bilo najgore?', 'Коли вам було найгірше?', 2);
  perform pg_temp.turn('75285603-118e-5d4e-bf1f-68f98bd70c55', '384be560-56c7-51e2-9893-766f94eb16b4', 'Daša', 'Jutros, kad sam ustala. Slabo mi je bilo i na poslu.', 'Сьогодні вранці, коли встала. Мені було погано й на роботі.', 3);
  perform pg_temp.turn('335cff50-afdc-53c1-b600-d34c1c08e4e6', '384be560-56c7-51e2-9893-766f94eb16b4', 'Liječnik', 'Otvorit ću Vam bolovanje na tri dana. Nesposobni ste za rad.', 'Я відкрию вам лікарняний на три дні. Ви непрацездатні.', 4);
  perform pg_temp.turn('a9c7056d-a58d-5f47-b444-0fd2c8975d88', '384be560-56c7-51e2-9893-766f94eb16b4', 'Daša', 'Hvala. Moram javiti poslodavcu.', 'Дякую. Мені треба повідомити роботодавця.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.7 · урок 45: Хронічна хвороба й ліки щодня — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'bdffb239-0f67-5481-ab8a-af81744b9fa3';
  v_lesson constant uuid := 'd295953d-21df-54ec-9b99-7aa7b872acca';
  v_gid constant uuid := '879e6305-0f75-5e88-abff-e27819f2d92d';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики GLAS'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A2.7: місце 3 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 45: Хронічна хвороба й ліки щодня', 'Lekcija 45: Kronična bolest i svakodnevni lijekovi', '["Розповісти про хронічну хворобу й режим ліків", "Звукові зміни в прикметниках: viši tlak, jači lijek, niži šećer"]'::jsonb, 20, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kronična bolest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šećerna bolest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povišen tlak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjeriti tlak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šećer u krvi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'inzulin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trajna terapija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponovljivi recept', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kutija lijekova', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tableta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nakon jela', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prije spavanja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preskočiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'viši', v_pos);
  v_pos := pg_temp.word(v_lesson, 'niži', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jači', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slabiji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zdrava prehrana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'manje soli', v_pos);
  v_pos := pg_temp.word(v_lesson, 'redoviti pregledi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dnevnik tlaka', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f112168-07c4-5355-83de-4547bf398eb9', 'fill_in_the_blank', 'Ujutro mi je tlak ___ nego navečer.', 'viši', '["visokiji", "viši", "visoko", "visok"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '981b4543-0e4c-5e1a-9409-2b4d1e09ec69', 'multiple_choice', 'Що означає «trajna terapija»?', 'постійна терапія', '["щоденник тиску", "цукровий діабет", "постійна терапія", "упаковка ліків"]'::jsonb, 'A2', 2, 'PUBLISHED', 'trajna terapija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e811b7d4-fba3-5e74-9bcf-1ae253ae8fc1', 'multiple_choice', 'Що означає «kronična bolest»?', 'хронічна хвороба', '["вищий", "хронічна хвороба", "регулярні огляди", "упаковка ліків"]'::jsonb, 'A2', 3, 'PUBLISHED', 'kronična bolest', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '62d42a3c-7f90-5fe0-a04e-b18a51aff2fc', 'multiple_choice', 'Що означає «šećer u krvi»?', 'цукор у крові', '["після їжі", "цукор у крові", "інсулін", "підвищений тиск"]'::jsonb, 'A2', 4, 'PUBLISHED', 'šećer u krvi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a94f70b2-bf85-5b02-a0e6-64764bae879d', 'multiple_choice', 'Як хорватською «нижчий»?', 'niži', '["manje soli", "niži", "jači", "slabiji"]'::jsonb, 'A2', 5, 'PUBLISHED', 'niži', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f1f00b57-39c4-51b6-88ad-10207d0e8c28', 'multiple_choice', 'Як хорватською «вищий»?', 'viši', '["dnevnik tlaka", "viši", "šećer u krvi", "tableta"]'::jsonb, 'A2', 6, 'PUBLISHED', 'viši', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '15bcdba6-9261-5f37-90d5-7abfd74606c0', 'type_answer', 'Напишіть хорватською: «інсулін»', 'inzulin', null, 'A2', 7, 'PUBLISHED', 'inzulin', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'caaf86f1-e37b-56e9-ae6b-97de8161c226', 'type_answer', 'Напишіть хорватською: «менше солі»', 'manje soli', null, 'A2', 8, 'PUBLISHED', 'manje soli', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd8b7c0bb-6d5b-587a-85e7-8212c497757e', 'type_answer', 'Напишіть хорватською: «цукровий діабет»', 'šećerna bolest', null, 'A2', 9, 'PUBLISHED', 'šećerna bolest', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1bd6b8dc-b39d-5edf-ab84-38c3811048aa', 'sentence_builder', 'Складіть: «Я міряю тиск щоранку.»', 'Tlak mjerim svako jutro.', '["jutro.", "Tlak", "svako", "mjerim"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3bdea191-02f1-525b-a69e-678e0aee8127', 'sentence_builder', 'Складіть: «Не можна пропускати дозу.»', 'Ne smijete preskočiti dozu.', '["preskočiti", "Ne", "dozu.", "smijete"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd41ff37e-f836-5948-acb1-feb66ccb1628', 'listening', 'Прослухайте і складіть фразу', 'Ima. Uzima inzulin prije jela i mjeri šećer u krvi.', '["inzulin", "prije", "u", "šećer", "jela", "krvi.", "i", "Ima.", "Uzima", "mjeri"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '4caf90ad-7dfa-5823-9fa1-474901a6d94b', 'listening_dialogue', 'Прослухайте розмову', 'від тиску; уранці після їжі; просто продовжити наступного дня', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Дар’я розмовляє з фармацевткою в аптеці.", "script": [{"speaker": "Ljekarnica", "hr": "Ovo je Vaš lijek za tlak, s ponovljivog recepta.", "ua": "Ось ваші ліки від тиску, за рецептом на повторні видачі."}, {"speaker": "Darja", "hr": "Kako se uzima?", "ua": "Як їх приймати?"}, {"speaker": "Ljekarnica", "hr": "Jedna tableta ujutro nakon jela. Kutija je za mjesec dana.", "ua": "Одна таблетка вранці після їжі. Упаковки вистачить на місяць."}, {"speaker": "Darja", "hr": "A ako zaboravim?", "ua": "А якщо я забуду?"}, {"speaker": "Ljekarnica", "hr": "Ne pijte dvije odjednom, samo nastavite sljedeći dan.", "ua": "Не пийте дві одразу, просто продовжуйте наступного дня."}], "questions": [{"q_ua": "Від чого ліки?", "options": ["від тиску", "від болю", "від алергії"], "correct": 0, "answer_turn": 0}, {"q_ua": "Коли приймати?", "options": ["перед сном", "уранці після їжі", "двічі на день"], "correct": 1, "answer_turn": 2}, {"q_ua": "Що робити, якщо забула?", "options": ["випити дві таблетки", "подзвонити лікарю", "просто продовжити наступного дня"], "correct": 2, "answer_turn": 4}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '4caf90ad-7dfa-5823-9fa1-474901a6d94b', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f5edf209-9156-50d6-ac23-bcb8275229d0', 'speaking', 'У мене підвищений тиск.', 'Imam povišen tlak.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7268e62d-13d1-5c0e-87db-feaf4476db23', 'speaking', 'Мені потрібен сильніший засіб від болю.', 'Trebam jači lijek protiv bolova.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '4a68a100-fe42-5898-9d5d-7d5dee8a54a5', 'write_message', 'Напишіть лікарці: у вас закінчуються ліки від тиску, і ви просите новий рецепт; тиск уранці вищий.', 'Poštovana doktorice, nestaje mi lijek za tlak. Molim Vas novi recept. Ujutro mi je tlak viši.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть лікарці: у вас закінчуються ліки від тиску, і ви просите новий рецепт; тиск уранці вищий.", "points": [{"ua": "закінчуються ліки", "keys": [["nestaj"], ["nemam"], ["potroš"]]}, {"ua": "від тиску", "keys": [["tlak"]]}, {"ua": "новий рецепт", "keys": [["recept"]]}], "hints": ["nestaje mi lijek za tlak", "molim Vas novi recept", "ujutro mi je tlak viši"], "models": ["Poštovana doktorice, nestaje mi lijek za tlak. Molim Vas novi recept. Ujutro mi je tlak viši."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '4a68a100-fe42-5898-9d5d-7d5dee8a54a5', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '60bd05ff-7132-5bd2-8dc4-d7173c0f3734', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Njezina baka ima šećernu bolest i treba novi aparat za mjerenje šećera.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи фармацевтці, що в бабусі діабет і їй потрібен новий глюкометр.", "direction": "ua_hr", "points": [{"ua": "діабет", "keys": [["šećer"], ["dijabetes"]]}, {"ua": "глюкометр", "keys": [["aparat"], ["mjerač"], ["glukometar"]]}], "hints": [], "models": ["Njezina baka ima šećernu bolest i treba novi aparat za mjerenje šećera."], "source_ua": "Скажи фармацевтці, що в бабусі діабет і їй потрібен новий глюкометр."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '60bd05ff-7132-5bd2-8dc4-d7173c0f3734', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('dadc460c-d03f-5fe3-83d1-6841c31c55f4', v_lesson, 'Мій тиск', 'Moj tlak', 5451, 'A2', 'health', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('51fd9444-3b5e-5bc1-94ff-928f66eb1cb4', 'dadc460c-d03f-5fe3-83d1-6841c31c55f4', 'Liječnica', 'Kako je tlak ovaj mjesec?', 'Який тиск цього місяця?', 1);
  perform pg_temp.turn('2b10f308-90b3-5325-8ce9-c475dcc9a295', 'dadc460c-d03f-5fe3-83d1-6841c31c55f4', 'Ivan', 'Ujutro je viši, navečer je niži. Vodim dnevnik tlaka.', 'Уранці вищий, увечері нижчий. Я веду щоденник тиску.', 2);
  perform pg_temp.turn('c793be45-feef-5b72-88b8-e163ac4c92ab', 'dadc460c-d03f-5fe3-83d1-6841c31c55f4', 'Liječnica', 'Odlično. Uzimate li tablete redovito?', 'Чудово. Ви регулярно приймаєте таблетки?', 3);
  perform pg_temp.turn('c3633d6f-6068-551e-8c50-6cb4cca7735d', 'dadc460c-d03f-5fe3-83d1-6841c31c55f4', 'Ivan', 'Jednom sam preskočio dozu, zaboravio sam.', 'Одного разу пропустив дозу, забув.', 4);
  perform pg_temp.turn('da87698e-7634-5251-b37f-46a430c59127', 'dadc460c-d03f-5fe3-83d1-6841c31c55f4', 'Liječnica', 'To ne smijete. Dat ću Vam ponovljivi recept, i jedite manje soli.', 'Так не можна. Я дам вам рецепт на повторні видачі, і їжте менше солі.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3879ffa7-9607-53f0-a98a-36d77f8820be', v_lesson, 'Бабуся й діабет', 'Baka i šećer', 5452, 'A2', 'health', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('9c457a12-aaf4-5d03-abb8-974b8cc4038c', '3879ffa7-9607-53f0-a98a-36d77f8820be', 'Daša', 'Darja, tvoja baka ima šećernu bolest?', 'Дар’є, у твоєї бабусі цукровий діабет?', 1);
  perform pg_temp.turn('6161e8df-9381-51de-bd6e-c5d4210a7da5', '3879ffa7-9607-53f0-a98a-36d77f8820be', 'Darja', 'Ima. Uzima inzulin prije jela i mjeri šećer u krvi.', 'Так. Вона коле інсулін перед їжею й міряє цукор у крові.', 2);
  perform pg_temp.turn('98b13329-a8a7-5314-97d8-2179419567ac', '3879ffa7-9607-53f0-a98a-36d77f8820be', 'Daša', 'Je li joj teško?', 'Їй важко?', 3);
  perform pg_temp.turn('e8ea04b4-8bf7-5e4b-b459-8aa0d2c1f8a1', '3879ffa7-9607-53f0-a98a-36d77f8820be', 'Darja', 'Navikla se. Najvažnija je zdrava prehrana i redoviti pregledi.', 'Звикла. Найважливіше — здорове харчування й регулярні огляди.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.7 · урок 46: Стрес, втома й відпочинок — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'bdffb239-0f67-5481-ab8a-af81744b9fa3';
  v_lesson constant uuid := '4b8782ab-0559-531b-a393-38aaf599a97c';
  v_gid constant uuid := '9c01b59a-6b4f-52a9-abfd-d78278072098';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики BEZL'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A2.7: місце 4 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 46: Стрес, втома й відпочинок', 'Lekcija 46: Stres, umor i odmor', '["Розповісти про стрес і втому, порадити, як відпочити", "Безособові речення: Ne da mi se, Spava mi se, Teško mi je"]'::jsonb, 20, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'ne da mi se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spava mi se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'teško mi je', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pod stresom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izgaranje na poslu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'premoren', v_pos);
  v_pos := pg_temp.word(v_lesson, 'napet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razdražljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'usredotočiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'loše spavati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'buditi se noću', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaspati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ravnoteža posla i života', v_pos);
  v_pos := pg_temp.word(v_lesson, 'isključiti mobitel', v_pos);
  v_pos := pg_temp.word(v_lesson, 'boravak u prirodi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smirivati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opuštanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'savjetovalište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'psihoterapeut', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zatražiti pomoć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'napuniti baterije', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f354344d-9ac9-5e59-a7ad-27dd15514286', 'fill_in_the_blank', 'Ne da ___ se danas kuhati.', 'mi', '["mi", "ja", "moj", "me"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b709ac8a-ba91-558a-997a-47b384382dec', 'multiple_choice', 'Що означає «ne da mi se»?', 'мені не хочеться, лінь', '["мені не хочеться, лінь", "психотерапевт", "розслаблення", "дратівливий"]'::jsonb, 'A2', 2, 'PUBLISHED', 'ne da mi se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '443b2b92-1850-55a2-8477-ebea7c4d55f1', 'multiple_choice', 'Що означає «buditi se noću»?', 'прокидатися вночі', '["мені хочеться спати", "прокидатися вночі", "дратівливий", "заспокоювати"]'::jsonb, 'A2', 3, 'PUBLISHED', 'buditi se noću', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '67f9be6e-f0cf-5aa9-9c23-16f8a3c71731', 'multiple_choice', 'Що означає «izgaranje na poslu»?', 'професійне вигорання', '["мені не хочеться, лінь", "професійне вигорання", "мені важко", "зосередитися"]'::jsonb, 'A2', 4, 'PUBLISHED', 'izgaranje na poslu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '55064eb7-71a9-5fa8-9551-be4c8d9edf7f', 'multiple_choice', 'Як хорватською «напружений»?', 'napet', '["razdražljiv", "napet", "teško mi je", "zaspati"]'::jsonb, 'A2', 5, 'PUBLISHED', 'napet', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7b930a03-0e01-5863-9cd5-11091b734cec', 'multiple_choice', 'Як хорватською «відновити сили («зарядити батарейки»)»?', 'napuniti baterije', '["savjetovalište", "opuštanje", "ravnoteža posla i života", "napuniti baterije"]'::jsonb, 'A2', 6, 'PUBLISHED', 'napuniti baterije', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '836e81c1-27e4-5ad5-8667-a551a2e2dfe3', 'type_answer', 'Напишіть хорватською: «заспокоювати»', 'smirivati', null, 'A2', 7, 'PUBLISHED', 'smirivati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be20e4fc-0a2c-5ca3-97b3-0af669665739', 'type_answer', 'Напишіть хорватською: «у стресі»', 'pod stresom', null, 'A2', 8, 'PUBLISHED', 'pod stresom', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b80a4714-1d6c-5de3-9a98-1476b32f0f8e', 'type_answer', 'Напишіть хорватською: «заснути»', 'zaspati', null, 'A2', 9, 'PUBLISHED', 'zaspati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be5c5075-0192-5bd0-b52c-9838d6b9da18', 'sentence_builder', 'Складіть: «Мені хочеться спати вже о восьмій.»', 'Spava mi se već u osam.', '["Spava", "osam.", "se", "mi", "već", "u"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '92e0d874-8f1a-5400-9ef5-44010be010ca', 'sentence_builder', 'Складіть: «Музика мене заспокоює.»', 'Glazba me smiruje.', '["me", "smiruje.", "Glazba"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '41d3bea2-1da5-566c-9a65-6ac6bde1e2b9', 'listening', 'Прослухайте і складіть фразу', 'Boravak u prirodi. Vikendom idem na Sljeme i isključim mobitel.', '["Sljeme", "isključim", "i", "u", "prirodi.", "mobitel.", "Boravak", "Vikendom", "idem", "na"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'da27e21a-ad95-546e-b1ca-164818bb0d21', 'listening_dialogue', 'Прослухайте новину', 'кожен третій; пів години прогулянки щодня; щовівторка', 'A2', 'PUBLISHED', '{"kind": "news", "situation_ua": "Ви слухаєте коротку радіопередачу про здоров’я.", "script": [{"hr": "Prema novom istraživanju, svaki treći radnik u Hrvatskoj je stalno pod stresom.", "ua": "За новим дослідженням, кожен третій працівник у Хорватії постійно в стресі."}, {"hr": "Stručnjaci savjetuju pola sata šetnje dnevno i manje vremena na mobitelu.", "ua": "Фахівці радять пів години прогулянки щодня й менше часу в мобільному."}, {"hr": "Gradsko savjetovalište nudi besplatne razgovore svakog utorka.", "ua": "Міський консультаційний центр пропонує безкоштовні розмови щовівторка."}], "questions": [{"q_ua": "Скільки працівників постійно в стресі?", "options": ["кожен третій", "кожен другий", "кожен десятий"], "correct": 0, "answer_turn": 0}, {"q_ua": "Що радять фахівці?", "options": ["більше спати вдень", "пів години прогулянки щодня", "пити каву"], "correct": 1, "answer_turn": 1}, {"q_ua": "Коли безкоштовні розмови?", "options": ["щоп’ятниці", "щодня", "щовівторка"], "correct": 2, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'da27e21a-ad95-546e-b1ca-164818bb0d21', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e5274a69-8be2-549f-9c94-ca5f6010fbfa', 'speaking', 'Мені важко зосередитися.', 'Teško mi je usredotočiti se.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a30f9ad-f1c3-519b-94d4-ae4d6af97bff', 'speaking', 'Я постійно в стресі.', 'Stalno sam pod stresom.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '8df126ad-8c84-51a4-9851-5cd7bd44c67d', 'write_message', 'Напишіть подрузі: ви втомлені й у стресі, вам не хочеться нікуди йти, але пропонуєте прогулятися в парку в неділю.', 'Umorna sam i pod stresom, ne da mi se nikamo. Ali idemo u nedjelju u šetnju u park?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі: ви втомлені й у стресі, вам не хочеться нікуди йти, але пропонуєте прогулятися в парку в неділю.", "points": [{"ua": "втомлені / у стресі", "keys": [["umorn"], ["stres"], ["premoren"]]}, {"ua": "не хочеться", "keys": [["ne da mi se"]]}, {"ua": "прогулянка в неділю", "keys": [["nedjelj"]]}], "hints": ["umorna sam", "pod stresom", "ne da mi se nikamo", "šetnja u parku u nedjelju"], "models": ["Umorna sam i pod stresom, ne da mi se nikamo. Ali idemo u nedjelju u šetnju u park?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '8df126ad-8c84-51a4-9851-5cd7bd44c67d', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'ae8cdcbf-d492-5082-ab34-96b3d2cd9823', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Mjesec dana loše spava i budi se noću.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи лікарю, що я погано сплю вже місяць і прокидаюся вночі.", "direction": "ua_hr", "points": [{"ua": "погано спить", "keys": [["spava"]]}, {"ua": "місяць", "keys": [["mjesec"]]}, {"ua": "прокидається вночі", "keys": [["budi"]]}], "hints": [], "models": ["Mjesec dana loše spava i budi se noću."], "source_ua": "Скажи лікарю, що я погано сплю вже місяць і прокидаюся вночі."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'ae8cdcbf-d492-5082-ab34-96b3d2cd9823', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d27e73c4-b6ff-58c2-9fd7-fcfb10544a37', v_lesson, 'Я втомилася', 'Umorna sam', 5461, 'A2', 'health', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('2409f7a9-5809-5bb3-934d-b163ea30dabc', 'd27e73c4-b6ff-58c2-9fd7-fcfb10544a37', 'Daša', 'Darja, izgledaš premoreno. Što je bilo?', 'Дар’є, ти виглядаєш перевтомленою. Що сталося?', 1);
  perform pg_temp.turn('71a4c080-365b-529f-b268-e590a6ea3f47', 'd27e73c4-b6ff-58c2-9fd7-fcfb10544a37', 'Darja', 'Stalno sam pod stresom na poslu. Ne mogu se usredotočiti.', 'Я постійно в стресі на роботі. Не можу зосередитися.', 2);
  perform pg_temp.turn('a82caa2f-917e-5507-ba8a-65cbc2eb7c1c', 'd27e73c4-b6ff-58c2-9fd7-fcfb10544a37', 'Daša', 'Spavaš li dobro?', 'Ти добре спиш?', 3);
  perform pg_temp.turn('7174feca-2d51-577b-afec-e70e2426931d', 'd27e73c4-b6ff-58c2-9fd7-fcfb10544a37', 'Darja', 'Ne. Budim se noću, a ujutro mi se ne da ustati.', 'Ні. Прокидаюся вночі, а вранці мені не хочеться вставати.', 4);
  perform pg_temp.turn('25128cd9-95db-5b27-95e4-0ca83b56a7c6', 'd27e73c4-b6ff-58c2-9fd7-fcfb10544a37', 'Daša', 'To zvuči kao izgaranje na poslu. Trebaš napuniti baterije.', 'Це схоже на професійне вигорання. Тобі треба відновити сили.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('fae2eba7-76f3-5103-bdf5-955258af3416', v_lesson, 'Як відпочити?', 'Kako se odmoriti?', 5462, 'A2', 'health', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('762b4e48-1664-5db7-bb5e-016bed4be7ea', 'fae2eba7-76f3-5103-bdf5-955258af3416', 'Ivan', 'Što ti pomaže za opuštanje?', 'Що допомагає тобі розслабитися?', 1);
  perform pg_temp.turn('d993cff2-d23e-51cb-8b4e-9a73590e54b9', 'fae2eba7-76f3-5103-bdf5-955258af3416', 'Marko', 'Boravak u prirodi. Vikendom idem na Sljeme i isključim mobitel.', 'Перебування на природі. На вихідних я їду на Слєме й вимикаю мобільний.', 2);
  perform pg_temp.turn('13839fe2-89f0-5c56-b7e2-6a51a45f6fea', 'fae2eba7-76f3-5103-bdf5-955258af3416', 'Ivan', 'Meni je teško isključiti se od posla.', 'Мені важко відключитися від роботи.', 3);
  perform pg_temp.turn('7a93a971-5723-518c-9793-a2bcaba8ae0b', 'fae2eba7-76f3-5103-bdf5-955258af3416', 'Marko', 'Probaj. A ako ne ide, zatraži pomoć. Savjetovalište nudi besplatne razgovore.', 'Спробуй. А якщо не виходить, попроси допомоги. Консультаційний центр пропонує безкоштовні розмови.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.7 · урок 47: Розповідаю, як хворів — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'bdffb239-0f67-5481-ab8a-af81744b9fa3';
  v_lesson constant uuid := '266c7f3d-8fb2-5fce-8127-3b52f464ecbe';
  v_gid constant uuid := '0b2de584-05a6-5570-a129-366fcb94766d';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики VID'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A2.7: місце 5 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 47: Розповідаю, як хворів', 'Lekcija 47: Pričam kako sam bio bolestan', '["Розповісти про хворобу в минулому: як почалося, що робили, як одужали", "Вид у perfekt: liječio sam se — izliječio sam se"]'::jsonb, 20, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'razboljeti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prehladiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'liječiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izliječiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oporaviti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upala pluća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ležati u bolnici', v_pos);
  v_pos := pg_temp.word(v_lesson, 'primiti u bolnicu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otpustiti iz bolnice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otpusno pismo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'operirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slomiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uganuti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gležanj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nateći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fizikalna terapija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posljedice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prvih dana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'postupno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opet sam na nogama', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '0ae47f04-3757-51a2-af2a-5dc0f826a1c2', 'fill_in_the_blank', 'Nakon dva tjedna liječenja konačno sam se ___.', 'izliječila', '["liječim", "izliječila", "liječila", "liječiti"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eb5c0360-6fef-577d-ac94-ca0ef0984cd1', 'multiple_choice', 'Що означає «otpustiti iz bolnice»?', 'виписати з лікарні', '["покласти в лікарню", "наслідки", "виписати з лікарні", "вилікуватися"]'::jsonb, 'A2', 2, 'PUBLISHED', 'otpustiti iz bolnice', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9a64f084-33f2-5b32-80d0-eb4d14dcfcca', 'multiple_choice', 'Що означає «prvih dana»?', 'у перші дні', '["зламати", "захворіти", "лікуватися", "у перші дні"]'::jsonb, 'A2', 3, 'PUBLISHED', 'prvih dana', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '85e7cef8-dbed-58c4-8431-7ddfd201e229', 'multiple_choice', 'Що означає «gležanj»?', 'щиколотка', '["щиколотка", "виписка з лікарні", "фізіотерапія", "поступово"]'::jsonb, 'A2', 4, 'PUBLISHED', 'gležanj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3b531cec-a8f7-5450-b968-b59d788b4435', 'multiple_choice', 'Як хорватською «запалення легень»?', 'upala pluća', '["ležati u bolnici", "nateći", "operirati", "upala pluća"]'::jsonb, 'A2', 5, 'PUBLISHED', 'upala pluća', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ba64edd-841c-55e2-a986-58f127d1cc46', 'multiple_choice', 'Як хорватською «оперувати»?', 'operirati', '["gležanj", "operirati", "izliječiti se", "prehladiti se"]'::jsonb, 'A2', 6, 'PUBLISHED', 'operirati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f8ba7325-0596-5f29-a8bb-dcd45aaa7c35', 'type_answer', 'Напишіть хорватською: «лікуватися»', 'liječiti se', null, 'A2', 7, 'PUBLISHED', 'liječiti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c99ddc61-6480-5317-b8fb-8f1640a5609f', 'type_answer', 'Напишіть хорватською: «набрякнути»', 'nateći', null, 'A2', 8, 'PUBLISHED', 'nateći', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a0d2d8cf-b9e6-56e5-86ae-f3438777a292', 'type_answer', 'Напишіть хорватською: «поступово»', 'postupno', null, 'A2', 9, 'PUBLISHED', 'postupno', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7e2b9006-a4e1-55bd-b79b-b578fbd0e4cc', 'sentence_builder', 'Складіть: «Я підвернула щиколотку на сходах.»', 'Uganula sam gležanj na stepenicama.', '["na", "Uganula", "sam", "gležanj", "stepenicama."]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0b14911a-408d-5f74-88cc-8a5b58e8d769', 'sentence_builder', 'Складіть: «Поступово мені ставало краще.»', 'Postupno mi je bilo sve bolje.', '["je", "bilo", "bolje.", "Postupno", "mi", "sve"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c2f95842-b92e-52e5-8e94-4636e71d2fb6', 'listening', 'Прослухайте і складіть фразу', 'Tjedan dana. Primili su me zbog visoke temperature.', '["dana.", "me", "visoke", "Primili", "zbog", "su", "temperature.", "Tjedan"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '37509845-8ced-5dbe-a8e1-27aa81522be1', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'грипом; два тижні; з понеділка', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Даша розповідає в голосовому повідомленні, як хворіла.", "script": [{"hr": "Bok, ovdje Daša. Oprosti što se nisam javljala.", "ua": "Привіт, це Даша. Вибач, що не озивалася."}, {"hr": "Dva tjedna sam bila bolesna, imala sam gripu i visoku temperaturu.", "ua": "Два тижні я хворіла, у мене був грип і висока температура."}, {"hr": "Sad mi je bolje, od ponedjeljka se vraćam na posao.", "ua": "Тепер мені краще, з понеділка повертаюся на роботу."}], "questions": [{"q_ua": "Чим хворіла Даша?", "options": ["грипом", "запаленням легень", "кишковою інфекцією"], "correct": 0, "answer_turn": 1}, {"q_ua": "Скільки вона хворіла?", "options": ["тиждень", "два тижні", "місяць"], "correct": 1, "answer_turn": 1}, {"q_ua": "Коли вона повертається на роботу?", "options": ["завтра", "у середу", "з понеділка"], "correct": 2, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '37509845-8ced-5dbe-a8e1-27aa81522be1', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6196069e-ebad-5db2-976a-9dfd7c35f42e', 'speaking', 'Я застудився на дощі.', 'Prehladio sam se na kiši.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '82be61f7-3434-5d8c-9060-3a417b6465ef', 'speaking', 'Через три тижні я знову на ногах.', 'Nakon tri tjedna opet sam na nogama.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'c6026cf8-854e-5ab4-a909-3984d9eafd11', 'write_message', 'Напишіть колегам: ви тиждень хворіли на грип, тепер вам краще, і з понеділка ви повертаєтеся на роботу.', 'Tjedan dana sam bila bolesna, imala sam gripu. Sad mi je bolje i od ponedjeljka se vraćam na posao.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть колегам: ви тиждень хворіли на грип, тепер вам краще, і з понеділка ви повертаєтеся на роботу.", "points": [{"ua": "хворіли тиждень", "keys": [["bolesn"], ["tjed"]]}, {"ua": "тепер краще", "keys": [["bolje"]]}, {"ua": "з понеділка на роботу", "keys": [["ponedjelj"]]}], "hints": ["tjedan dana sam bila bolesna", "imala sam gripu", "sad mi je bolje", "od ponedjeljka se vraćam"], "models": ["Tjedan dana sam bila bolesna, imala sam gripu. Sad mi je bolje i od ponedjeljka se vraćam na posao."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'c6026cf8-854e-5ab4-a909-3984d9eafd11', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '2fbd946f-17e7-58c3-a5f5-471c1f249776', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Otpustili su ga iz bolnice u petak. Ovo je otpusno pismo.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи сімейному лікареві, що мене виписали з лікарні в п’ятницю, і ось виписка.", "direction": "ua_hr", "points": [{"ua": "виписали в п’ятницю", "keys": [["otpust"], ["petak"]]}, {"ua": "виписка", "keys": [["otpusn"]]}], "hints": [], "models": ["Otpustili su ga iz bolnice u petak. Ovo je otpusno pismo."], "source_ua": "Скажи сімейному лікареві, що мене виписали з лікарні в п’ятницю, і ось виписка."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '2fbd946f-17e7-58c3-a5f5-471c1f249776', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2fea2eb6-3842-5a91-b86b-523c943b9d1a', v_lesson, 'Запалення легень', 'Upala pluća', 5471, 'A2', 'health', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('bcf3991b-3d5f-588b-a58e-0d44a860ad32', '2fea2eb6-3842-5a91-b86b-523c943b9d1a', 'Daša', 'Ivane, dugo te nije bilo. Jesi li bio bolestan?', 'Іване, тебе довго не було. Ти хворів?', 1);
  perform pg_temp.turn('f4403368-5de1-5aa9-bf5b-c1c91636613e', '2fea2eb6-3842-5a91-b86b-523c943b9d1a', 'Ivan', 'Jesam. Prehladio sam se, a onda sam dobio upalu pluća.', 'Так. Я застудився, а потім отримав запалення легень.', 2);
  perform pg_temp.turn('25d9232b-dab5-505a-8932-cc40a894bd7b', '2fea2eb6-3842-5a91-b86b-523c943b9d1a', 'Daša', 'Joj! Jesi li ležao u bolnici?', 'Ой! Ти лежав у лікарні?', 3);
  perform pg_temp.turn('5c440eff-8a97-5a93-ba10-d87df699ba79', '2fea2eb6-3842-5a91-b86b-523c943b9d1a', 'Ivan', 'Tjedan dana. Primili su me zbog visoke temperature.', 'Тиждень. Мене поклали через високу температуру.', 4);
  perform pg_temp.turn('624a4f50-d38c-5f8f-b09a-ef0973e565c6', '2fea2eb6-3842-5a91-b86b-523c943b9d1a', 'Daša', 'A sad?', 'А тепер?', 5);
  perform pg_temp.turn('daeabd5b-d66b-52ee-9dc2-9deacf0126fe', '2fea2eb6-3842-5a91-b86b-523c943b9d1a', 'Ivan', 'Otpustili su me u petak. Postupno se oporavljam, opet sam na nogama.', 'Мене виписали в п’ятницю. Поступово одужую, знову на ногах.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5d4247f6-51ce-5852-8f1d-dfa666eba5e4', v_lesson, 'Зламана рука', 'Slomljena ruka', 5472, 'A2', 'health', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('f7d4894f-5ab1-58b8-92ca-7699cfefa3cc', '5d4247f6-51ce-5852-8f1d-dfa666eba5e4', 'Marko', 'Što ti je s rukom?', 'Що в тебе з рукою?', 1);
  perform pg_temp.turn('1fa8eba2-ef73-528e-b1fe-668adb3b2887', '5d4247f6-51ce-5852-8f1d-dfa666eba5e4', 'Darja', 'Slomila sam je na skijanju prošli mjesec.', 'Я зламала її на лижах минулого місяця.', 2);
  perform pg_temp.turn('0cedc944-2cf4-5caa-b445-cac12878ce84', '5d4247f6-51ce-5852-8f1d-dfa666eba5e4', 'Marko', 'Je li jako boljelo?', 'Дуже боліло?', 3);
  perform pg_temp.turn('801e0ba6-1b7f-56e4-bc25-f48931079b10', '5d4247f6-51ce-5852-8f1d-dfa666eba5e4', 'Darja', 'Prvih dana jest, ruka je natekla. Sad idem na fizikalnu terapiju.', 'Перші дні так, рука набрякла. Тепер ходжу на фізіотерапію.', 4);
  perform pg_temp.turn('807cf22b-970b-5663-ad95-231baf7dea3d', '5d4247f6-51ce-5852-8f1d-dfa666eba5e4', 'Marko', 'Hoće li biti posljedica?', 'Чи будуть наслідки?', 5);
  perform pg_temp.turn('28572f9b-4fc3-5675-9485-660a9abb9e5b', '5d4247f6-51ce-5852-8f1d-dfa666eba5e4', 'Darja', 'Liječnik kaže da neće. Srećom!', 'Лікар каже, що ні. На щастя!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- 3. Модуль і юніт — опубліковані
update public.modules set status = 'PUBLISHED', title_ua = 'Модуль A2.7 — Здоров’я: система й самопочуття', title_hr = 'Modul A2.7 — Zdravlje: sustav i dobrobit' where id = 'd66361ac-89bc-5021-99ad-c3f61c71145c';
update public.units set status = 'PUBLISHED' where id = 'bdffb239-0f67-5481-ab8a-af81744b9fa3';

-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('468ce636-fdba-5b52-9695-dc9daa6a032b', '8f08356b-8efa-5ebc-906e-f409fbaadaf3', 'd295953d-21df-54ec-9b99-7aa7b872acca', '4b8782ab-0559-531b-a393-38aaf599a97c', '266c7f3d-8fb2-5fce-8127-3b52f464ecbe')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and li.required) <> 15
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and not li.required
                 and e.exercise_type in ('write_message', 'mediation')) <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and e.exercise_type = 'listening_dialogue' and e.status = 'PUBLISHED') <> 1
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 20 or l.unit_id <> 'bdffb239-0f67-5481-ab8a-af81744b9fa3');
  select count(*) into v_titles from (values ('468ce636-fdba-5b52-9695-dc9daa6a032b'::uuid, 'Урок 43:%', 1), ('8f08356b-8efa-5ebc-906e-f409fbaadaf3'::uuid, 'Урок 44:%', 2), ('d295953d-21df-54ec-9b99-7aa7b872acca'::uuid, 'Урок 45:%', 3), ('4b8782ab-0559-531b-a393-38aaf599a97c'::uuid, 'Урок 46:%', 4), ('266c7f3d-8fb2-5fce-8127-3b52f464ecbe'::uuid, 'Урок 47:%', 5)) as t(id, pat, o)
    left join public.lessons l on l.id = t.id and l.title_ua like t.pat and l.order_index = t.o
   where l.id is null;
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
      where l.level_code = 'A2' and l.status = 'PUBLISHED' and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A2.7: % уроків з неправильним складом', v_bad; end if;
  if v_titles > 0 then raise exception 'Модуль A2.7: % уроків не на своєму місці чи з неправильним номером', v_titles; end if;
  if v_words > 0 then raise exception 'A2: % слів повторюються в кількох уроках', v_words; end if;
  if (select status from public.modules where id = 'd66361ac-89bc-5021-99ad-c3f61c71145c') <> 'PUBLISHED' then raise exception 'Модуль A2.7 не опубліковано'; end if;
  raise notice 'Готово: модуль A2.7 — 5 уроків, слів 105';
end $$;

commit;
