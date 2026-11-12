-- =====================================================================
-- Програма A2 v2 · модуль A2.2 «Навчання: курси, університет, школа» · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2.py 2 (не редагуйте вручну).
--
-- Рішення власника 2026-11-12: 20–25 нових слів на урок, 90–95 % слів — нові для рівня, діалоги під тему,
-- частіше Даша / Дар’я; «Прослухайте діалог чи оголошення» в кожному уроці; бета (PUBLISHED).
--   * Уроки 9–16 (8): слів у них 170. Кожен: 20–25 слів, 2 діалоги, 15 вправ
--     (одна — «Прослухайте діалог чи оголошення»), «Напишіть повідомлення» і «Перекажіть другу» (ua → hr, необов’язкові), 20 хв.
--   * Слова: 170 (нові — PUBLISHED; ті, що вже є в словнику, не змінюються).
--   * Модуль і юніт A2.2 → PUBLISHED. Потрібен уже запущений 20261112_curriculum_a2_v2_00_structure.sql.
--   * Нічого не видаляє. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.units where id = '6b2a808e-df6e-5da3-bf7a-597668e47495') then
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

-- 1. Слова уроків A2.2 (170): нові — PUBLISHED (бета); наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A2', t.ua, t.vtype, t.forms, t.examples, 'PUBLISHED', 'claude_curriculum_a2_v2'
  from jsonb_to_recordset('[{"lemma": "tečaj za odrasle", "normalized": "tecaj za odrasle", "pos": "phrase", "ua": "курс для дорослих", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ovaj tečaj za odrasle traje cijelu školsku godinu."]}, {"lemma": "početni tečaj", "normalized": "pocetni tecaj", "pos": "phrase", "ua": "курс для початківців", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Početni tečaj je za one koji ne znaju ništa."]}, {"lemma": "napredni tečaj", "normalized": "napredni tecaj", "pos": "phrase", "ua": "курс для просунутих", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Nakon dvije godine upisala sam napredni tečaj."]}, {"lemma": "test razine", "normalized": "test razine", "pos": "phrase", "ua": "тест на рівень", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Prije upisa pišete test razine."]}, {"lemma": "polaznica", "normalized": "polaznica", "pos": "noun", "ua": "слухачка курсу", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Na tečaju su polaznice iz cijelog svijeta."]}, {"lemma": "predavačica", "normalized": "predavacica", "pos": "noun", "ua": "викладачка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Naša predavačica je jako strpljiva."]}, {"lemma": "školarina", "normalized": "skolarina", "pos": "noun", "ua": "плата за навчання", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Školarina za semestar iznosi četiristo eura."]}, {"lemma": "plaćanje u ratama", "normalized": "placanje u ratama", "pos": "phrase", "ua": "оплата частинами", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Moguće je plaćanje u ratama."]}, {"lemma": "večernji tečaj", "normalized": "vecernji tecaj", "pos": "phrase", "ua": "вечірній курс", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Radim do pet, pa idem na večernji tečaj."]}, {"lemma": "potvrda o pohađanju", "normalized": "potvrda o pohadanju", "pos": "phrase", "ua": "довідка про відвідування", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za posao trebam potvrdu o pohađanju tečaja."]}, {"lemma": "pohađati", "normalized": "pohadati", "pos": "verb", "ua": "відвідувати (заняття, курс)", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Pohađam tečaj dvaput tjedno."]}, {"lemma": "upisivati", "normalized": "upisivati", "pos": "verb", "ua": "записувати(ся), набирати (на курс)", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "upisati"}, "examples": ["Škola upisuje nove polaznike u rujnu."]}, {"lemma": "upisati se", "normalized": "upisati se", "pos": "verb", "ua": "записатися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "upisivati se"}, "examples": ["Upisala sam se na tečaj hrvatskog."]}, {"lemma": "izgovor", "normalized": "izgovor", "pos": "noun", "ua": "вимова", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Moj izgovor je još loš."]}, {"lemma": "vježbati", "normalized": "vjezbati", "pos": "verb", "ua": "вправлятися, тренувати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Svaki dan vježbam izgovor s aplikacijom."]}, {"lemma": "gramatika", "normalized": "gramatika", "pos": "noun", "ua": "граматика", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Hrvatska gramatika ima sedam padeža."]}, {"lemma": "vokabular", "normalized": "vokabular", "pos": "noun", "ua": "словниковий запас", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Moj vokabular raste iz tjedna u tjedan."]}, {"lemma": "domaća zadaća", "normalized": "domaca zadaca", "pos": "phrase", "ua": "домашнє завдання", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za domaću zadaću trebamo napisati pismo."]}, {"lemma": "napredovati", "normalized": "napredovati", "pos": "verb", "ua": "робити успіхи, прогресувати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Brzo napreduješ, bravo!"]}, {"lemma": "mala grupa", "normalized": "mala grupa", "pos": "phrase", "ua": "мала група", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U maloj grupi svi puno govore."]}, {"lemma": "individualna nastava", "normalized": "individualna nastava", "pos": "phrase", "ua": "індивідуальні заняття", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Individualna nastava je skuplja, ali brža."]}, {"lemma": "ispit iz hrvatskog", "normalized": "ispit iz hrvatskog", "pos": "phrase", "ua": "іспит з хорватської", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Za državljanstvo treba položiti ispit iz hrvatskog."]}, {"lemma": "prijemni ispit", "normalized": "prijemni ispit", "pos": "phrase", "ua": "вступний іспит", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Na neke fakultete se piše prijemni ispit."]}, {"lemma": "državna matura", "normalized": "drzavna matura", "pos": "phrase", "ua": "державна матура (випускні іспити)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Bez državne mature ne možeš upisati fakultet."]}, {"lemma": "natječaj za upis", "normalized": "natjecaj za upis", "pos": "phrase", "ua": "конкурс на вступ", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Natječaj za upis objavljuje se u proljeće."]}, {"lemma": "rok za prijavu", "normalized": "rok za prijavu", "pos": "phrase", "ua": "строк подання заявки", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Rok za prijavu je do kraja lipnja."]}, {"lemma": "bodovi", "normalized": "bodovi", "pos": "noun", "ua": "бали", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Za medicinu treba puno bodova."]}, {"lemma": "rang-lista", "normalized": "rang-lista", "pos": "noun", "ua": "рейтинговий список", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Na rang-listi sam na dvadesetom mjestu."]}, {"lemma": "studijski program", "normalized": "studijski program", "pos": "phrase", "ua": "освітня програма", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Odabrala sam studijski program iz ekonomije."]}, {"lemma": "preddiplomski studij", "normalized": "preddiplomski studij", "pos": "phrase", "ua": "бакалаврат", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Preddiplomski studij traje tri godine."]}, {"lemma": "diplomski studij", "normalized": "diplomski studij", "pos": "phrase", "ua": "магістратура", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Nakon toga upisujem diplomski studij."]}, {"lemma": "redoviti student", "normalized": "redoviti student", "pos": "phrase", "ua": "студент денної форми", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Redoviti studenti ne plaćaju školarinu prvu godinu."]}, {"lemma": "izvanredni student", "normalized": "izvanredni student", "pos": "phrase", "ua": "студент заочної форми", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Kao izvanredni student mogu raditi."]}, {"lemma": "akademska godina", "normalized": "akademska godina", "pos": "phrase", "ua": "навчальний рік (в університеті)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Akademska godina počinje u listopadu."]}, {"lemma": "semestar", "normalized": "semestar", "pos": "noun", "ua": "семестр", "vtype": "core", "forms": {"gender": "m"}, "examples": ["U prvom semestru imam šest kolegija."]}, {"lemma": "studentski dom", "normalized": "studentski dom", "pos": "phrase", "ua": "гуртожиток", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Prijavila sam se za studentski dom."]}, {"lemma": "studentska iskaznica", "normalized": "studentska iskaznica", "pos": "phrase", "ua": "студентський квиток", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Sa studentskom iskaznicom imaš popust u menzi."]}, {"lemma": "menza", "normalized": "menza", "pos": "noun", "ua": "студентська їдальня", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ručam u menzi jer je jeftino."]}, {"lemma": "studentska služba", "normalized": "studentska sluzba", "pos": "phrase", "ua": "деканат (студентський відділ)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Dokumente predaješ u studentskoj službi."]}, {"lemma": "primati prijave", "normalized": "primati prijave", "pos": "phrase", "ua": "приймати заявки", "vtype": "chunk", "forms": {}, "examples": ["Fakultet prima prijave do petnaestog srpnja."]}, {"lemma": "objaviti", "normalized": "objaviti", "pos": "verb", "ua": "оголосити, опублікувати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "objavljivati"}, "examples": ["Rezultati će biti objavljeni na stranici fakulteta."]}, {"lemma": "kvota za strance", "normalized": "kvota za strance", "pos": "phrase", "ua": "квота для іноземців", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Postoji posebna kvota za strance."]}, {"lemma": "poznavanje jezika", "normalized": "poznavanje jezika", "pos": "phrase", "ua": "знання мови", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Traži se poznavanje hrvatskog jezika na razini B2."]}, {"lemma": "priznavanje diplome", "normalized": "priznavanje diplome", "pos": "phrase", "ua": "визнання диплома", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Postupak priznavanja diplome traje do šezdeset dana."]}, {"lemma": "inozemna kvalifikacija", "normalized": "inozemna kvalifikacija", "pos": "phrase", "ua": "іноземна кваліфікація", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za inozemnu kvalifikaciju predaje se poseban zahtjev."]}, {"lemma": "akademsko priznavanje", "normalized": "akademsko priznavanje", "pos": "phrase", "ua": "академічне визнання", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Akademsko priznavanje treba za nastavak studija."]}, {"lemma": "stručno priznavanje", "normalized": "strucno priznavanje", "pos": "phrase", "ua": "професійне визнання", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Za rad kao liječnica treba stručno priznavanje."]}, {"lemma": "regulirana profesija", "normalized": "regulirana profesija", "pos": "phrase", "ua": "регульована професія", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Medicinska sestra je regulirana profesija."]}, {"lemma": "prijepis ocjena", "normalized": "prijepis ocjena", "pos": "phrase", "ua": "виписка оцінок (додаток)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Uz diplomu se prilaže prijepis ocjena."]}, {"lemma": "dodatak diplomi", "normalized": "dodatak diplomi", "pos": "phrase", "ua": "додаток до диплома", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Dodatak diplomi treba prevesti na hrvatski."]}, {"lemma": "ovjerena preslika", "normalized": "ovjerena preslika", "pos": "phrase", "ua": "засвідчена копія", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Predajte ovjerenu presliku diplome."]}, {"lemma": "apostille", "normalized": "apostille", "pos": "noun", "ua": "апостиль", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Na diplomi mora biti apostille."]}, {"lemma": "priložiti", "normalized": "priloziti", "pos": "verb", "ua": "додати (документ)", "vtype": "core", "forms": {"aspect": "pfv", "pair": "prilagati"}, "examples": ["Zahtjevu treba priložiti preslike dokumenata."]}, {"lemma": "obrazac zahtjeva", "normalized": "obrazac zahtjeva", "pos": "phrase", "ua": "бланк заяви", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Obrazac zahtjeva se ispunjava online."]}, {"lemma": "upravna pristojba", "normalized": "upravna pristojba", "pos": "phrase", "ua": "адміністративний збір", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Upravna pristojba plaća se prije predaje."]}, {"lemma": "trajanje postupka", "normalized": "trajanje postupka", "pos": "phrase", "ua": "тривалість процедури", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Trajanje postupka ovisi o vrsti priznavanja."]}, {"lemma": "ishod", "normalized": "ishod", "pos": "noun", "ua": "результат (рішення)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ishod postupka dobit ćete poštom."]}, {"lemma": "nedostajati", "normalized": "nedostajati", "pos": "verb", "ua": "бракувати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Nedostaje Vam prijepis ocjena."]}, {"lemma": "dopuniti", "normalized": "dopuniti", "pos": "verb", "ua": "доповнити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "dopunjavati"}, "examples": ["Zahtjev morate dopuniti u roku od osam dana."]}, {"lemma": "usporediv", "normalized": "usporediv", "pos": "adjective", "ua": "порівнянний", "vtype": "core", "forms": {}, "examples": ["Vaš studij je usporediv s hrvatskim."]}, {"lemma": "razlikovni ispit", "normalized": "razlikovni ispit", "pos": "phrase", "ua": "різницевий іспит (додатковий)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Možda ćete morati položiti razlikovni ispit."]}, {"lemma": "ured za priznavanje", "normalized": "ured za priznavanje", "pos": "phrase", "ua": "відділ визнання (кваліфікацій)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ured za priznavanje radi od devet do dvanaest."]}, {"lemma": "rješenje o priznavanju", "normalized": "rjesenje o priznavanju", "pos": "phrase", "ua": "рішення про визнання", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Rješenje o priznavanju stiglo je poštom."]}, {"lemma": "podnijeti zahtjev", "normalized": "podnijeti zahtjev", "pos": "phrase", "ua": "подати заяву", "vtype": "chunk", "forms": {}, "examples": ["Zahtjev možete podnijeti i elektronički."]}, {"lemma": "kolegij", "normalized": "kolegij", "pos": "noun", "ua": "навчальна дисципліна, курс", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ovaj kolegij je obvezan za sve studente."]}, {"lemma": "vježbe", "normalized": "vjezbe", "pos": "noun", "ua": "практичні заняття", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Vježbe su utorkom ujutro."]}, {"lemma": "seminar", "normalized": "seminar", "pos": "noun", "ua": "семінар", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Na seminaru svatko mora nešto prezentirati."]}, {"lemma": "seminarski rad", "normalized": "seminarski rad", "pos": "phrase", "ua": "курсова (реферат)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Seminarski rad predajem do petka."]}, {"lemma": "kolokvij", "normalized": "kolokvij", "pos": "noun", "ua": "проміжна контрольна, колоквіум", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ako položiš kolokvij, ne pišeš ispit."]}, {"lemma": "ispitni rok", "normalized": "ispitni rok", "pos": "phrase", "ua": "екзаменаційна сесія, дата іспиту", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Sljedeći ispitni rok je u rujnu."]}, {"lemma": "polagati", "normalized": "polagati", "pos": "verb", "ua": "складати (іспит)", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "položiti"}, "examples": ["Sutra polažem matematiku."]}, {"lemma": "položiti", "normalized": "poloziti", "pos": "verb", "ua": "скласти (іспит успішно)", "vtype": "core", "forms": {"aspect": "pfv", "pair": "polagati"}, "examples": ["Položila sam sve ispite!"]}, {"lemma": "usmeni ispit", "normalized": "usmeni ispit", "pos": "phrase", "ua": "усний іспит", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Usmeni ispit je u ponedjeljak."]}, {"lemma": "pismeni ispit", "normalized": "pismeni ispit", "pos": "phrase", "ua": "письмовий іспит", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Na pismenom ispitu imamo dva sata."]}, {"lemma": "asistent", "normalized": "asistent", "pos": "noun", "ua": "асистент (викладач)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Asistent vodi vježbe."]}, {"lemma": "konzultacije", "normalized": "konzultacije", "pos": "noun", "ua": "консультації", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Profesorica ima konzultacije srijedom."]}, {"lemma": "bilješke", "normalized": "biljeske", "pos": "noun", "ua": "нотатки, конспект", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Možeš li mi posuditi svoje bilješke?"]}, {"lemma": "skripta", "normalized": "skripta", "pos": "noun", "ua": "конспект лекцій (посібник)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Skripta se kupuje u skriptarnici."]}, {"lemma": "literatura", "normalized": "literatura", "pos": "noun", "ua": "література (для курсу)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Popis literature je na stranici kolegija."]}, {"lemma": "prolazna ocjena", "normalized": "prolazna ocjena", "pos": "phrase", "ua": "прохідна оцінка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Dovoljan je prolazna ocjena."]}, {"lemma": "prepisivati", "normalized": "prepisivati", "pos": "verb", "ua": "списувати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Na ispitu je zabranjeno prepisivati."]}, {"lemma": "naučiti napamet", "normalized": "nauciti napamet", "pos": "phrase", "ua": "вивчити напам’ять", "vtype": "chunk", "forms": {}, "examples": ["Formule moraš naučiti napamet."]}, {"lemma": "ponavljati gradivo", "normalized": "ponavljati gradivo", "pos": "phrase", "ua": "повторювати матеріал", "vtype": "chunk", "forms": {}, "examples": ["Cijeli tjedan ponavljam gradivo."]}, {"lemma": "prisutnost", "normalized": "prisutnost", "pos": "noun", "ua": "присутність, відвідування", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Prisutnost na vježbama je obvezna."]}, {"lemma": "ponoviti godinu", "normalized": "ponoviti godinu", "pos": "phrase", "ua": "залишитися на другий рік", "vtype": "chunk", "forms": {}, "examples": ["Ako ne položi tri ispita, mora ponoviti godinu."]}, {"lemma": "ispitno pitanje", "normalized": "ispitno pitanje", "pos": "phrase", "ua": "екзаменаційне питання", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Dobila sam lako ispitno pitanje."]}, {"lemma": "prekvalifikacija", "normalized": "prekvalifikacija", "pos": "noun", "ua": "перекваліфікація", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Razmišljam o prekvalifikaciji za programerku."]}, {"lemma": "obrazovanje odraslih", "normalized": "obrazovanje odraslih", "pos": "phrase", "ua": "освіта дорослих", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Obrazovanje odraslih organiziraju razna učilišta."]}, {"lemma": "pučko otvoreno učilište", "normalized": "pucko otvoreno uciliste", "pos": "phrase", "ua": "народний відкритий навчальний заклад (освіта дорослих)", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Upisala sam tečaj na pučkom otvorenom učilištu."]}, {"lemma": "vaučer za obrazovanje", "normalized": "vaucer za obrazovanje", "pos": "phrase", "ua": "ваучер на навчання", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Vaučer za obrazovanje pokriva cijenu tečaja."]}, {"lemma": "usavršavanje", "normalized": "usavrsavanje", "pos": "noun", "ua": "підвищення кваліфікації", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Poslodavac plaća usavršavanje zaposlenika."]}, {"lemma": "osposobljavanje", "normalized": "osposobljavanje", "pos": "noun", "ua": "професійне навчання (короткий курс)", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Osposobljavanje za viličarista traje mjesec dana."]}, {"lemma": "stručni ispit", "normalized": "strucni ispit", "pos": "phrase", "ua": "кваліфікаційний іспит", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Na kraju se polaže stručni ispit."]}, {"lemma": "praktična nastava", "normalized": "prakticna nastava", "pos": "phrase", "ua": "практичне навчання", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Pola programa je praktična nastava."]}, {"lemma": "digitalne vještine", "normalized": "digitalne vjestine", "pos": "phrase", "ua": "цифрові навички", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Tečaj digitalnih vještina je besplatan."]}, {"lemma": "tržište rada", "normalized": "trziste rada", "pos": "phrase", "ua": "ринок праці", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Na tržištu rada traže se električari."]}, {"lemma": "tražen", "normalized": "trazen", "pos": "adjective", "ua": "затребуваний", "vtype": "core", "forms": {}, "examples": ["Njegovatelji su vrlo traženi."]}, {"lemma": "deficitarno zanimanje", "normalized": "deficitarno zanimanje", "pos": "phrase", "ua": "дефіцитна професія", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Zavarivač je deficitarno zanimanje."]}, {"lemma": "viličarist", "normalized": "vilicarist", "pos": "noun", "ua": "водій навантажувача", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Kao viličarist možeš raditi u skladištu."]}, {"lemma": "zavarivač", "normalized": "zavarivac", "pos": "noun", "ua": "зварювальник", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Zavarivači dobro zarađuju u brodogradilištu."]}, {"lemma": "knjigovođa", "normalized": "knjigovoda", "pos": "noun", "ua": "бухгалтер (рахівник)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Tečaj za knjigovođu traje šest mjeseci."]}, {"lemma": "programiranje", "normalized": "programiranje", "pos": "noun", "ua": "програмування", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Programiranje možeš učiti i online."]}, {"lemma": "uvjerenje", "normalized": "uvjerenje", "pos": "noun", "ua": "свідоцтво, посвідчення", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Na kraju dobivaš uvjerenje o osposobljenosti."]}, {"lemma": "besplatan", "normalized": "besplatan", "pos": "adjective", "ua": "безкоштовний", "vtype": "core", "forms": {}, "examples": ["Za nezaposlene je tečaj besplatan."]}, {"lemma": "savjetnik za zapošljavanje", "normalized": "savjetnik za zaposljavanje", "pos": "phrase", "ua": "консультант з працевлаштування", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Savjetnik za zapošljavanje mi je preporučio tečaj."]}, {"lemma": "prijaviti se na Zavod", "normalized": "prijaviti se na zavod", "pos": "phrase", "ua": "стати на облік у службі зайнятості", "vtype": "chunk", "forms": {}, "examples": ["Prvo se moraš prijaviti na Zavod."]}, {"lemma": "promijeniti struku", "normalized": "promijeniti struku", "pos": "phrase", "ua": "змінити фах", "vtype": "chunk", "forms": {}, "examples": ["Htjela bih promijeniti struku."]}, {"lemma": "razredna nastava", "normalized": "razredna nastava", "pos": "phrase", "ua": "початкова школа (1–4 класи, один учитель)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U razrednoj nastavi djecu uči jedna učiteljica."]}, {"lemma": "predmetna nastava", "normalized": "predmetna nastava", "pos": "phrase", "ua": "середні класи (5–8, предметники)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Od petog razreda je predmetna nastava."]}, {"lemma": "obvezno obrazovanje", "normalized": "obvezno obrazovanje", "pos": "phrase", "ua": "обов’язкова освіта", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Obvezno obrazovanje u Hrvatskoj traje osam godina."]}, {"lemma": "školska godina", "normalized": "skolska godina", "pos": "phrase", "ua": "навчальний рік (у школі)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Školska godina počinje početkom rujna."]}, {"lemma": "polugodište", "normalized": "polugodiste", "pos": "noun", "ua": "півріччя", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Prvo polugodište završava pred Božić."]}, {"lemma": "zaključna ocjena", "normalized": "zakljucna ocjena", "pos": "phrase", "ua": "підсумкова оцінка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Zaključna ocjena iz matematike je četiri."]}, {"lemma": "nedovoljan", "normalized": "nedovoljan", "pos": "adjective", "ua": "незадовільно (оцінка 1)", "vtype": "core", "forms": {}, "examples": ["Jedinica je nedovoljan."]}, {"lemma": "dovoljan", "normalized": "dovoljan", "pos": "adjective", "ua": "достатньо (оцінка 2)", "vtype": "core", "forms": {}, "examples": ["Dvojka je dovoljan."]}, {"lemma": "odličan", "normalized": "odlican", "pos": "adjective", "ua": "відмінно (оцінка 5)", "vtype": "core", "forms": {}, "examples": ["Petica je odličan."]}, {"lemma": "izborni predmet", "normalized": "izborni predmet", "pos": "phrase", "ua": "предмет за вибором", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Informatika je izborni predmet u nižim razredima."]}, {"lemma": "vjeronauk", "normalized": "vjeronauk", "pos": "noun", "ua": "релігієзнавство (урок)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Vjeronauk nije obvezan."]}, {"lemma": "strani jezik", "normalized": "strani jezik", "pos": "phrase", "ua": "іноземна мова", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Prvi strani jezik je engleski."]}, {"lemma": "e-Dnevnik", "normalized": "e-dnevnik", "pos": "noun", "ua": "електронний щоденник (журнал)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ocjene se upisuju u e-Dnevnik."]}, {"lemma": "školski pedagog", "normalized": "skolski pedagog", "pos": "phrase", "ua": "шкільний педагог", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Školski pedagog pomaže djeci koja su nova u školi."]}, {"lemma": "ravnatelj", "normalized": "ravnatelj", "pos": "noun", "ua": "директор школи", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ravnatelj je potpisao potvrdu."]}, {"lemma": "prijelaz u drugu školu", "normalized": "prijelaz u drugu skolu", "pos": "phrase", "ua": "перехід до іншої школи", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Za prijelaz u drugu školu treba ispisnica."]}, {"lemma": "ispisnica", "normalized": "ispisnica", "pos": "noun", "ua": "документ про вибуття зі школи", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ispisnicu dobivate u tajništvu."]}, {"lemma": "upisno područje", "normalized": "upisno podrucje", "pos": "phrase", "ua": "шкільний округ (за адресою)", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Dijete ide u školu prema upisnom području."]}, {"lemma": "dopunska nastava", "normalized": "dopunska nastava", "pos": "phrase", "ua": "додаткові заняття (для відстаючих)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na dopunskoj nastavi učimo hrvatski."]}, {"lemma": "dodatna nastava", "normalized": "dodatna nastava", "pos": "phrase", "ua": "поглиблені заняття (для сильних)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na dodatnoj nastavi rješavamo teže zadatke."]}, {"lemma": "školski praznici", "normalized": "skolski praznici", "pos": "phrase", "ua": "шкільні канікули", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Zimski školski praznici traju dva tjedna."]}, {"lemma": "informacije", "normalized": "informacije", "pos": "noun", "ua": "зустріч з учителем (день консультацій)", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Informacije su svakog drugog utorka."]}, {"lemma": "razrednik", "normalized": "razrednik", "pos": "noun", "ua": "класний керівник", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Razrednik me pozvao na razgovor."]}, {"lemma": "napredak", "normalized": "napredak", "pos": "noun", "ua": "прогрес, успіхи", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Zadovoljna sam napretkom vašeg sina."]}, {"lemma": "poteškoće", "normalized": "poteskoce", "pos": "noun", "ua": "труднощі", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Ima poteškoća s čitanjem."]}, {"lemma": "vladanje", "normalized": "vladanje", "pos": "noun", "ua": "поведінка (оцінка)", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Vladanje mu je uzorno."]}, {"lemma": "ometati", "normalized": "ometati", "pos": "verb", "ua": "заважати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Na satu ometa druge učenike."]}, {"lemma": "surađivati", "normalized": "suradivati", "pos": "verb", "ua": "співпрацювати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Hvala što surađujete sa školom."]}, {"lemma": "izostanak", "normalized": "izostanak", "pos": "noun", "ua": "пропуск (заняття)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ima tri izostanka ovaj mjesec."]}, {"lemma": "opravdati", "normalized": "opravdati", "pos": "verb", "ua": "виправдати (пропуск)", "vtype": "core", "forms": {"aspect": "pfv", "pair": "opravdavati"}, "examples": ["Izostanak morate opravdati u roku od tri dana."]}, {"lemma": "ispričnica", "normalized": "ispricnica", "pos": "noun", "ua": "записка про відсутність (від батьків)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Napisala sam ispričnicu za jedan dan."]}, {"lemma": "liječnička ispričnica", "normalized": "lijecnicka ispricnica", "pos": "phrase", "ua": "довідка від лікаря", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za tri dana bolesti treba liječnička ispričnica."]}, {"lemma": "neopravdan", "normalized": "neopravdan", "pos": "adjective", "ua": "невиправданий", "vtype": "core", "forms": {}, "examples": ["Neopravdani izostanci utječu na vladanje."]}, {"lemma": "pohvaliti", "normalized": "pohvaliti", "pos": "verb", "ua": "похвалити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "hvaliti"}, "examples": ["Učiteljica je pohvalila njegov sastavak."]}, {"lemma": "sastavak", "normalized": "sastavak", "pos": "noun", "ua": "твір (шкільний)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Za zadaću pišu sastavak o ljetu."]}, {"lemma": "lektira", "normalized": "lektira", "pos": "noun", "ua": "обов’язкова книжка для читання", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ovaj mjesec čitaju lektiru o Hlapiću."]}, {"lemma": "izlet razreda", "normalized": "izlet razreda", "pos": "phrase", "ua": "класна екскурсія", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Izlet razreda je u svibnju."]}, {"lemma": "suglasnost roditelja", "normalized": "suglasnost roditelja", "pos": "phrase", "ua": "згода батьків", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za izlet treba suglasnost roditelja."]}, {"lemma": "potpisati", "normalized": "potpisati", "pos": "verb", "ua": "підписати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "potpisivati"}, "examples": ["Molim Vas, potpišite suglasnost."]}, {"lemma": "prilagoditi se", "normalized": "prilagoditi se", "pos": "verb", "ua": "адаптуватися, пристосуватися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "prilagođavati se"}, "examples": ["Djeca se brzo prilagode novoj školi."]}, {"lemma": "sramežljiv", "normalized": "sramezljiv", "pos": "adjective", "ua": "сором’язливий", "vtype": "core", "forms": {}, "examples": ["Na početku je bio sramežljiv."]}, {"lemma": "druželjubiv", "normalized": "druzeljubiv", "pos": "adjective", "ua": "товариський", "vtype": "core", "forms": {}, "examples": ["Sad je druželjubiv i ima prijatelje."]}, {"lemma": "cjelodnevni boravak", "normalized": "cjelodnevni boravak", "pos": "phrase", "ua": "група продовженого дня (на цілий день)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Cjelodnevni boravak traje do pet sati."]}, {"lemma": "izvannastavne aktivnosti", "normalized": "izvannastavne aktivnosti", "pos": "phrase", "ua": "позакласні заняття (у школі)", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Škola nudi puno izvannastavnih aktivnosti."]}, {"lemma": "izvanškolske aktivnosti", "normalized": "izvanskolske aktivnosti", "pos": "phrase", "ua": "позашкільні гуртки", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Izvanškolske aktivnosti plaćaju roditelji."]}, {"lemma": "zbor", "normalized": "zbor", "pos": "noun", "ua": "хор", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Kći pjeva u školskom zboru."]}, {"lemma": "dramska skupina", "normalized": "dramska skupina", "pos": "phrase", "ua": "драматичний гурток", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U dramskoj skupini pripremaju predstavu."]}, {"lemma": "sportski klub", "normalized": "sportski klub", "pos": "phrase", "ua": "спортивний клуб", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Sin trenira u sportskom klubu."]}, {"lemma": "glazbena škola", "normalized": "glazbena skola", "pos": "phrase", "ua": "музична школа", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Upisala je glazbenu školu, svira klavir."]}, {"lemma": "rukomet", "normalized": "rukomet", "pos": "noun", "ua": "гандбол", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Rukomet je u Hrvatskoj jako popularan."]}, {"lemma": "vaterpolo", "normalized": "vaterpolo", "pos": "noun", "ua": "водне поло", "vtype": "core", "forms": {"gender": "m"}, "examples": ["U Splitu svi dječaci igraju vaterpolo."]}, {"lemma": "članarina", "normalized": "clanarina", "pos": "noun", "ua": "членський внесок", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Članarina za klub je trideset eura mjesečno."]}, {"lemma": "instrukcije", "normalized": "instrukcije", "pos": "noun", "ua": "репетиторство", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Iz matematike ide na instrukcije."]}, {"lemma": "pomoć u učenju", "normalized": "pomoc u ucenju", "pos": "phrase", "ua": "допомога в навчанні", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Volonteri nude besplatnu pomoć u učenju."]}, {"lemma": "riješiti zadatak", "normalized": "rijesiti zadatak", "pos": "phrase", "ua": "розв’язати задачу", "vtype": "chunk", "forms": {}, "examples": ["Možeš li mi pomoći riješiti zadatak?"]}, {"lemma": "provjeriti zadaću", "normalized": "provjeriti zadacu", "pos": "phrase", "ua": "перевірити домашнє завдання", "vtype": "chunk", "forms": {}, "examples": ["Svaku večer mu provjerim zadaću."]}, {"lemma": "školska knjižnica", "normalized": "skolska knjiznica", "pos": "phrase", "ua": "шкільна бібліотека", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Lektiru posuđujemo u školskoj knjižnici."]}, {"lemma": "marenda", "normalized": "marenda", "pos": "noun", "ua": "перекус у школі (Далмація)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Za marendu je danas pizza."]}, {"lemma": "školska kuhinja", "normalized": "skolska kuhinja", "pos": "phrase", "ua": "шкільна їдальня (обіди)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Ručak u školskoj kuhinji je besplatan."]}, {"lemma": "raspored aktivnosti", "normalized": "raspored aktivnosti", "pos": "phrase", "ua": "розклад гуртків", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Raspored aktivnosti je na vratima učionice."]}, {"lemma": "upisnica", "normalized": "upisnica", "pos": "noun", "ua": "бланк запису", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ispunite upisnicu za zbor."]}, {"lemma": "slobodno vrijeme djeteta", "normalized": "slobodno vrijeme djeteta", "pos": "phrase", "ua": "вільний час дитини", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Slobodno vrijeme djeteta nije samo mobitel."]}, {"lemma": "školski projekt", "normalized": "skolski projekt", "pos": "phrase", "ua": "шкільний проєкт", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Za školski projekt trebaju veliki plakat."]}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 2. Уроки модуля A2.2
-- A2.2 · урок 9: Курси хорватської для дорослих — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6b2a808e-df6e-5da3-bf7a-597668e47495';
  v_lesson constant uuid := '8190831a-549a-544a-962b-4f716a895a32';
  v_gid constant uuid := '0b2de584-05a6-5570-a129-366fcb94766d';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики VID'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A2.2: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 9: Курси хорватської для дорослих', 'Lekcija 9: Tečaj hrvatskog za odrasle', '["Записатися на курс мови: рівень, тест, розклад, оплата частинами", "Розрізняти вид: upisivati — upisati, polagati — položiti"]'::jsonb, 20, 'PUBLISHED', 1);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'tečaj za odrasle', v_pos);
  v_pos := pg_temp.word(v_lesson, 'početni tečaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'napredni tečaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'test razine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polaznica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predavačica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'školarina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plaćanje u ratama', v_pos);
  v_pos := pg_temp.word(v_lesson, 'večernji tečaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potvrda o pohađanju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pohađati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upisivati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upisati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izgovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vježbati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gramatika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vokabular', v_pos);
  v_pos := pg_temp.word(v_lesson, 'domaća zadaća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'napredovati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mala grupa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'individualna nastava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispit iz hrvatskog', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '05c4ce9e-0414-5c04-8d93-45b119affa25', 'fill_in_the_blank', 'Prošle godine sam se ___ na tečaj hrvatskog.', 'upisala', '["upisivati", "upisujem", "upisala", "upisivala"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c3aec36-59c4-59f5-a625-68cfa78bf51f', 'multiple_choice', 'Що означає «napredovati»?', 'робити успіхи, прогресувати', '["вечірній курс", "записувати(ся), набирати (на курс)", "робити успіхи, прогресувати", "записатися"]'::jsonb, 'A2', 2, 'PUBLISHED', 'napredovati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4d736369-6ec9-5ac5-8461-e1c51b36f561', 'multiple_choice', 'Що означає «plaćanje u ratama»?', 'оплата частинами', '["тест на рівень", "граматика", "мала група", "оплата частинами"]'::jsonb, 'A2', 3, 'PUBLISHED', 'plaćanje u ratama', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f7fd2919-f9c8-5cc1-820d-3f207a829bb0', 'multiple_choice', 'Що означає «školarina»?', 'плата за навчання', '["домашнє завдання", "мала група", "індивідуальні заняття", "плата за навчання"]'::jsonb, 'A2', 4, 'PUBLISHED', 'školarina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1abc433f-aa10-5b83-8d77-e536f2da0c47', 'multiple_choice', 'Як хорватською «тест на рівень»?', 'test razine', '["upisati se", "test razine", "ispit iz hrvatskog", "polaznica"]'::jsonb, 'A2', 5, 'PUBLISHED', 'test razine', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c176dd59-83df-5740-84d1-d39ca51088c9', 'multiple_choice', 'Як хорватською «вимова»?', 'izgovor', '["test razine", "potvrda o pohađanju", "izgovor", "napredni tečaj"]'::jsonb, 'A2', 6, 'PUBLISHED', 'izgovor', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3dc6db27-4f03-5401-b274-f04e735b560f', 'type_answer', 'Напишіть хорватською: «відвідувати (заняття, курс)»', 'pohađati', null, 'A2', 7, 'PUBLISHED', 'pohađati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a3f05a34-83dd-5fb0-b831-d5a386307ae8', 'type_answer', 'Напишіть хорватською: «вправлятися, тренувати»', 'vježbati', null, 'A2', 8, 'PUBLISHED', 'vježbati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '86e1721e-36a8-51e4-9b83-508882417621', 'type_answer', 'Напишіть хорватською: «словниковий запас»', 'vokabular', null, 'A2', 9, 'PUBLISHED', 'vokabular', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '67acc490-a281-5e82-b2c7-35227aeec47e', 'sentence_builder', 'Складіть: «Я відвідую курс двічі на тиждень.»', 'Pohađam tečaj dvaput tjedno.', '["dvaput", "tečaj", "Pohađam", "tjedno."]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b74518a3-66a7-5715-86bf-85edc001ec95', 'sentence_builder', 'Складіть: «Можна платити частинами?»', 'Je li moguće plaćanje u ratama?', '["li", "plaćanje", "ratama?", "u", "moguće", "Je"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7b984002-c2a7-51b4-a1cd-f51e5b47ff7a', 'listening', 'Прослухайте і складіть фразу', 'Kolika je školarina? Je li moguće plaćanje u ratama?', '["je", "ratama?", "Kolika", "li", "u", "Je", "školarina?", "moguće", "plaćanje"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'af36c356-7b25-5474-be5c-4a507a3e97a5', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'A2; у вівторок і четвер; внести першу частину оплати', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Мовна школа залишила вам повідомлення.", "script": [{"hr": "Dobar dan, ovdje škola stranih jezika Lingua.", "ua": "Добрий день, це школа іноземних мов «Лінгва»."}, {"hr": "Vaš test razine je gotov, upisani ste u grupu A2.", "ua": "Ваш тест на рівень перевірено, вас записано до групи A2."}, {"hr": "Nastava je utorkom i četvrtkom od osamnaest sati.", "ua": "Заняття у вівторок і четвер з вісімнадцятої."}, {"hr": "Prvu ratu školarine platite do kraja tjedna.", "ua": "Першу частину оплати внесіть до кінця тижня."}], "questions": [{"q_ua": "До якої групи вас записали?", "options": ["A1", "A2", "B1"], "correct": 1, "answer_turn": 1}, {"q_ua": "Коли заняття?", "options": ["у понеділок і середу", "у вівторок і четвер", "у суботу"], "correct": 1, "answer_turn": 2}, {"q_ua": "Що треба зробити до кінця тижня?", "options": ["написати тест", "принести документи", "внести першу частину оплати"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'af36c356-7b25-5474-be5c-4a507a3e97a5', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9e6901c7-8781-564e-85fc-accde77fa4fe', 'speaking', 'Мене цікавить вечірній курс.', 'Zanima me večernji tečaj.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f9612765-1979-5882-a727-ec3f9fedb389', 'speaking', 'Мені потрібна довідка про відвідування.', 'Trebam potvrdu o pohađanju.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'c1f4bffd-fc99-5ee1-8cdd-1760c1698be3', 'write_message', 'Напишіть у мовну школу: хочете записатися на вечірній курс хорватської й питаєте, чи можна платити частинами.', 'Poštovani, htjela bih se upisati na večernji tečaj hrvatskog. Je li moguće plaćanje u ratama?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у мовну школу: хочете записатися на вечірній курс хорватської й питаєте, чи можна платити частинами.", "points": [{"ua": "записатися на курс", "keys": [["upis"], ["prijav"]]}, {"ua": "вечірній", "keys": [["večernj"]]}, {"ua": "платити частинами", "keys": [["rat"]]}], "hints": ["htjela bih se upisati", "večernji tečaj", "plaćanje u ratama"], "models": ["Poštovani, htjela bih se upisati na večernji tečaj hrvatskog. Je li moguće plaćanje u ratama?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'c1f4bffd-fc99-5ee1-8cdd-1760c1698be3', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'b2734bec-479e-5d43-b288-7b1ed27b1c0d', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Imate li tečaj u maloj grupi? Kada je test razine?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай у секретарки, чи є курс у малій групі і коли тест на рівень.", "direction": "ua_hr", "points": [{"ua": "мала група", "keys": [["mal", "grup"]]}, {"ua": "тест на рівень", "keys": [["test"]]}, {"ua": "коли", "keys": [["kad"]]}], "hints": [], "models": ["Imate li tečaj u maloj grupi? Kada je test razine?"], "source_ua": "Спитай у секретарки, чи є курс у малій групі і коли тест на рівень."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'b2734bec-479e-5d43-b288-7b1ed27b1c0d', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d198b0f9-0676-53cf-87d3-3c1468482649', v_lesson, 'Запис на курс', 'Upis na tečaj', 5091, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('a99bf38d-afe2-5b08-ba67-13802e8f140a', 'd198b0f9-0676-53cf-87d3-3c1468482649', 'Darja', 'Dobar dan, zanima me tečaj hrvatskog za odrasle.', 'Добрий день, мене цікавить курс хорватської для дорослих.', 1);
  perform pg_temp.turn('2f489f05-a14d-50bc-a4da-1165aa12bb19', 'd198b0f9-0676-53cf-87d3-3c1468482649', 'Tajnica', 'Prvo trebate napisati test razine. Znate li već nešto?', 'Спершу вам треба написати тест на рівень. Ви вже щось знаєте?', 2);
  perform pg_temp.turn('dc3e64b9-8918-58eb-a78e-632617e8c911', 'd198b0f9-0676-53cf-87d3-3c1468482649', 'Darja', 'Učim sama godinu dana, ali moj izgovor je loš.', 'Я вчуся сама рік, але вимова в мене погана.', 3);
  perform pg_temp.turn('aa7fbd8d-9cb1-57ea-ab8f-02f21bddff3d', 'd198b0f9-0676-53cf-87d3-3c1468482649', 'Tajnica', 'Onda možda nije početni tečaj. Imamo večernji tečaj u maloj grupi.', 'Тоді, можливо, це не курс для початківців. Маємо вечірній курс у малій групі.', 4);
  perform pg_temp.turn('cfe6f725-18b7-5496-bc68-eb9ebe68c738', 'd198b0f9-0676-53cf-87d3-3c1468482649', 'Darja', 'Kolika je školarina? Je li moguće plaćanje u ratama?', 'Скільки коштує навчання? Можна платити частинами?', 5);
  perform pg_temp.turn('65b65610-91df-5045-b224-89396dd81871', 'd198b0f9-0676-53cf-87d3-3c1468482649', 'Tajnica', 'Petsto eura, u tri rate. Upisujemo do petnaestog rujna.', 'П’ятсот євро, трьома частинами. Записуємо до п’ятнадцятого вересня.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('478c52ca-ccf4-5b83-8f0e-2d35adfccfb9', v_lesson, 'Після заняття', 'Nakon nastave', 5092, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('619f5925-f747-5928-82b2-672655f6dee1', '478c52ca-ccf4-5b83-8f0e-2d35adfccfb9', 'Daša', 'Kako ti ide na tečaju?', 'Як тобі на курсі?', 1);
  perform pg_temp.turn('91ca3796-9174-58e9-a51d-442f783e7714', '478c52ca-ccf4-5b83-8f0e-2d35adfccfb9', 'Darja', 'Dobro! Predavačica kaže da brzo napredujem.', 'Добре! Викладачка каже, що я швидко роблю успіхи.', 2);
  perform pg_temp.turn('6395d9e8-8b4a-55c2-9cbb-f3da4b313bf3', '478c52ca-ccf4-5b83-8f0e-2d35adfccfb9', 'Daša', 'A gramatika? Meni su padeži bili najteži.', 'А граматика? Мені відмінки були найважчі.', 3);
  perform pg_temp.turn('af1b651c-6b62-55e2-abfe-9ceea730193c', '478c52ca-ccf4-5b83-8f0e-2d35adfccfb9', 'Darja', 'I meni. Zato svaki dan pišem domaću zadaću i vježbam.', 'І мені. Тому щодня пишу домашнє завдання й вправляюся.', 4);
  perform pg_temp.turn('71904212-5eea-5717-9653-9ec67881cd3f', '478c52ca-ccf4-5b83-8f0e-2d35adfccfb9', 'Daša', 'Bravo. Kad budeš spremna, upiši se na ispit iz hrvatskog.', 'Молодець. Коли будеш готова, запишися на іспит з хорватської.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.2 · урок 10: Вступ до університету — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6b2a808e-df6e-5da3-bf7a-597668e47495';
  v_lesson constant uuid := 'aad2c656-7750-545f-88be-b36c1cdb3b79';
  v_gid constant uuid := 'a6dba6b3-0b0a-588c-acd4-7eedced88519';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики PAS'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A2.2: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 10: Вступ до університету', 'Lekcija 10: Upis na fakultet', '["Розпитати про вступ: конкурс, бали, строки, документи", "Зрозуміти правила з пасивом: Prijave se primaju…"]'::jsonb, 20, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'prijemni ispit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'državna matura', v_pos);
  v_pos := pg_temp.word(v_lesson, 'natječaj za upis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rok za prijavu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bodovi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rang-lista', v_pos);
  v_pos := pg_temp.word(v_lesson, 'studijski program', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preddiplomski studij', v_pos);
  v_pos := pg_temp.word(v_lesson, 'diplomski studij', v_pos);
  v_pos := pg_temp.word(v_lesson, 'redoviti student', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izvanredni student', v_pos);
  v_pos := pg_temp.word(v_lesson, 'akademska godina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'semestar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'studentski dom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'studentska iskaznica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'menza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'studentska služba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'primati prijave', v_pos);
  v_pos := pg_temp.word(v_lesson, 'objaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kvota za strance', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poznavanje jezika', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '7f57ffa0-1618-5959-bfeb-4c73e094eef3', 'fill_in_the_blank', 'Prijave ___ primaju do kraja lipnja.', 'se', '["su", "je", "se", "ih"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '46729f93-5541-5d43-a7fd-8000e9b0b039', 'multiple_choice', 'Що означає «akademska godina»?', 'навчальний рік (в університеті)', '["студент денної форми", "навчальний рік (в університеті)", "гуртожиток", "студентська їдальня"]'::jsonb, 'A2', 2, 'PUBLISHED', 'akademska godina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '39f1f1a2-d38c-5717-a373-5dfa6928c506', 'multiple_choice', 'Що означає «menza»?', 'студентська їдальня', '["семестр", "приймати заявки", "гуртожиток", "студентська їдальня"]'::jsonb, 'A2', 3, 'PUBLISHED', 'menza', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '53ceee13-9a2e-5280-9a79-6f6d864a1cb4', 'multiple_choice', 'Що означає «redoviti student»?', 'студент денної форми', '["освітня програма", "бали", "квота для іноземців", "студент денної форми"]'::jsonb, 'A2', 4, 'PUBLISHED', 'redoviti student', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa001720-2e31-58e5-b1a1-f5b0557b3283', 'multiple_choice', 'Як хорватською «бакалаврат»?', 'preddiplomski studij', '["preddiplomski studij", "natječaj za upis", "rang-lista", "studentski dom"]'::jsonb, 'A2', 5, 'PUBLISHED', 'preddiplomski studij', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c670675a-3c4f-5aed-9027-de3c56e8c05d', 'multiple_choice', 'Як хорватською «квота для іноземців»?', 'kvota za strance', '["studentski dom", "redoviti student", "kvota za strance", "državna matura"]'::jsonb, 'A2', 6, 'PUBLISHED', 'kvota za strance', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd0d57274-81e1-5af7-97bb-b609b1dfc7c1', 'type_answer', 'Напишіть хорватською: «державна матура (випускні іспити)»', 'državna matura', null, 'A2', 7, 'PUBLISHED', 'državna matura', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '58db0084-2cee-550d-8c06-18555674f546', 'type_answer', 'Напишіть хорватською: «бали»', 'bodovi', null, 'A2', 8, 'PUBLISHED', 'bodovi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'adc71adc-2d0a-5fe1-846b-767aabafee2f', 'type_answer', 'Напишіть хорватською: «семестр»', 'semestar', null, 'A2', 9, 'PUBLISHED', 'semestar', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '93290360-919e-586f-9099-028fbd581296', 'sentence_builder', 'Складіть: «Конкурс оголошують у травні.»', 'Natječaj se objavljuje u svibnju.', '["objavljuje", "se", "u", "svibnju.", "Natječaj"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1083ce18-f82f-5078-b6a6-6e6ce9e90dbd', 'sentence_builder', 'Складіть: «Навчальний рік починається в жовтні.»', 'Akademska godina počinje u listopadu.', '["počinje", "u", "Akademska", "listopadu.", "godina"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '44f5463d-ae69-59ac-a6b6-862df11c5d8a', 'listening', 'Прослухайте і складіть фразу', 'Postoji. Traži se i poznavanje hrvatskog na razini B2.', '["na", "i", "hrvatskog", "poznavanje", "Traži", "Postoji.", "razini", "se", "B2."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '2e3f663b-b8f7-54bd-94f8-5ccc8aec29c4', 'listening_dialogue', 'Прослухайте оголошення', 'до 20 липня; документ про знання хорватської; у вересні', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Ви на сайті університету, вмикаєте відео з оголошенням.", "script": [{"hr": "Prijave za upis primaju se od prvog do dvadesetog srpnja.", "ua": "Заявки на вступ приймають з першого до двадцятого липня."}, {"hr": "Rang-lista bit će objavljena dvadeset petog srpnja.", "ua": "Рейтинговий список оприлюднять двадцять п’ятого липня."}, {"hr": "Strani studenti trebaju potvrdu o poznavanju hrvatskog jezika.", "ua": "Іноземним студентам потрібен документ про знання хорватської мови."}, {"hr": "Upis u studentski dom je u rujnu.", "ua": "Заселення в гуртожиток — у вересні."}], "questions": [{"q_ua": "До котрого числа приймають заявки?", "options": ["до 20 липня", "до 25 липня", "до 1 вересня"], "correct": 0, "answer_turn": 0}, {"q_ua": "Що потрібно іноземним студентам?", "options": ["вступний іспит", "документ про знання хорватської", "медична довідка"], "correct": 1, "answer_turn": 2}, {"q_ua": "Коли заселення в гуртожиток?", "options": ["у липні", "у жовтні", "у вересні"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '2e3f663b-b8f7-54bd-94f8-5ccc8aec29c4', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '896f0d69-b85c-5c4d-a203-9068dfc75a8a', 'speaking', 'Мене цікавить вступ на магістратуру.', 'Zanima me upis na diplomski studij.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bb41cef2-3b3c-59b2-b499-23005939c400', 'speaking', 'До коли приймають заявки?', 'Do kada se primaju prijave?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '6ba4b21b-70a5-5a70-bdc5-fd8dde5f73ae', 'write_message', 'Напишіть у студентський відділ: ви закінчили школу в Україні й питаєте, чи є квота для іноземців і який рівень хорватської потрібен.', 'Poštovani, završila sam školu u Ukrajini. Postoji li kvota za strance i koja razina hrvatskog se traži?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у студентський відділ: ви закінчили школу в Україні й питаєте, чи є квота для іноземців і який рівень хорватської потрібен.", "points": [{"ua": "закінчили школу в Україні", "keys": [["Ukrajin"]]}, {"ua": "квота для іноземців", "keys": [["kvot"]]}, {"ua": "рівень хорватської", "keys": [["razin"]]}], "hints": ["završila sam školu u Ukrajini", "kvota za strance", "koja razina hrvatskog"], "models": ["Poštovani, završila sam školu u Ukrajini. Postoji li kvota za strance i koja razina hrvatskog se traži?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '6ba4b21b-70a5-5a70-bdc5-fd8dde5f73ae', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'c90569df-2a46-57f8-bf14-7af10a320d49', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Može li se studirati kao izvanredni student i istovremeno raditi?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай, чи можна вчитися заочно й одночасно працювати.", "direction": "ua_hr", "points": [{"ua": "заочно", "keys": [["izvanredn"]]}, {"ua": "працювати", "keys": [["radi"]]}], "hints": [], "models": ["Može li se studirati kao izvanredni student i istovremeno raditi?"], "source_ua": "Спитай, чи можна вчитися заочно й одночасно працювати."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'c90569df-2a46-57f8-bf14-7af10a320d49', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a1bc9ed4-1239-5a84-b465-affe11d1a5f4', v_lesson, 'У студентському відділі', 'U studentskoj službi', 5101, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('37acebbc-5bfe-544e-a33e-3efccd0a4bf0', 'a1bc9ed4-1239-5a84-b465-affe11d1a5f4', 'Daša', 'Dobar dan, zanima me upis na preddiplomski studij ekonomije.', 'Добрий день, мене цікавить вступ на бакалаврат з економіки.', 1);
  perform pg_temp.turn('5d68d5c1-9dfb-58e8-8ae6-7ea512a77e58', 'a1bc9ed4-1239-5a84-b465-affe11d1a5f4', 'Referentica', 'Natječaj za upis objavljuje se u svibnju. Prijave se primaju do kraja lipnja.', 'Конкурс на вступ оголошують у травні. Заявки приймають до кінця червня.', 2);
  perform pg_temp.turn('7603a3c3-f00f-583b-a126-b42ae0313e58', 'a1bc9ed4-1239-5a84-b465-affe11d1a5f4', 'Daša', 'Piše li se prijemni ispit?', 'Чи пишуть вступний іспит?', 3);
  perform pg_temp.turn('00525b2a-0ba5-53aa-b48f-29f3efd49fd4', 'a1bc9ed4-1239-5a84-b465-affe11d1a5f4', 'Referentica', 'Ne, upisuje se prema bodovima iz državne mature i srednje škole.', 'Ні, вступають за балами матури й середньої школи.', 4);
  perform pg_temp.turn('9ec002cc-0ac8-5a3c-add0-ed0535a7fa30', 'a1bc9ed4-1239-5a84-b465-affe11d1a5f4', 'Daša', 'Ja sam završila školu u Ukrajini. Postoji li kvota za strance?', 'Я закінчила школу в Україні. Чи є квота для іноземців?', 5);
  perform pg_temp.turn('4e1ef0f0-2e14-531d-8b67-4c091a2b5ad5', 'a1bc9ed4-1239-5a84-b465-affe11d1a5f4', 'Referentica', 'Postoji. Traži se i poznavanje hrvatskog na razini B2.', 'Є. Також потрібне знання хорватської на рівні B2.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('dc69dcd8-ddd4-5c6c-b7c8-2d9b9d770f84', v_lesson, 'Результати', 'Rezultati', 5102, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('d9ef835b-a090-5af9-900f-ade1562af6bb', 'dc69dcd8-ddd4-5c6c-b7c8-2d9b9d770f84', 'Luka', 'Dašo, jesu li objavili rang-listu?', 'Дашо, оприлюднили рейтинговий список?', 1);
  perform pg_temp.turn('147d97c3-f3a2-5de2-9a70-869f8915e2f9', 'dc69dcd8-ddd4-5c6c-b7c8-2d9b9d770f84', 'Daša', 'Jesu! Ja sam na petnaestom mjestu, a upisuje se pedeset studenata.', 'Так! Я на п’ятнадцятому місці, а набирають п’ятдесят студентів.', 2);
  perform pg_temp.turn('ba4c06d6-a92f-580d-9ddf-cdc760d92a42', 'dc69dcd8-ddd4-5c6c-b7c8-2d9b9d770f84', 'Luka', 'Čestitam! Hoćeš li biti redoviti ili izvanredni student?', 'Вітаю! Ти будеш на денній чи на заочній?', 3);
  perform pg_temp.turn('c8d0fe6d-436a-56a2-aac4-4d4b5e704922', 'dc69dcd8-ddd4-5c6c-b7c8-2d9b9d770f84', 'Daša', 'Redoviti. Prijavit ću se i za studentski dom.', 'На денній. Я подамся ще й на гуртожиток.', 4);
  perform pg_temp.turn('a6b29741-23dc-5fa1-bd56-439068b616c2', 'dc69dcd8-ddd4-5c6c-b7c8-2d9b9d770f84', 'Luka', 'Super. Sa studentskom iskaznicom jedeš jeftino u menzi.', 'Супер. Зі студентським дешево їсиш у їдальні.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.2 · урок 11: Визнання диплома — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6b2a808e-df6e-5da3-bf7a-597668e47495';
  v_lesson constant uuid := 'dd6c5f39-f66e-5acb-8255-932f822ddcc5';
  v_gid constant uuid := 'a6dba6b3-0b0a-588c-acd4-7eedced88519';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики PAS'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A2.2: місце 3 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 11: Визнання диплома', 'Lekcija 11: Priznavanje diplome', '["Розпитати, як визнати український диплом: документи, переклад, строк", "Зрозуміти інструкцію: Zahtjev se predaje…, Prilaže se…"]'::jsonb, 20, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'priznavanje diplome', v_pos);
  v_pos := pg_temp.word(v_lesson, 'inozemna kvalifikacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'akademsko priznavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stručno priznavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'regulirana profesija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijepis ocjena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dodatak diplomi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovjerena preslika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'apostille', v_pos);
  v_pos := pg_temp.word(v_lesson, 'priložiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obrazac zahtjeva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upravna pristojba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trajanje postupka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ishod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nedostajati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dopuniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'usporediv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razlikovni ispit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ured za priznavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rješenje o priznavanju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podnijeti zahtjev', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cb7a0d31-06ab-5b81-8ccf-ce0995a4b844', 'fill_in_the_blank', 'Upravna pristojba ___ plaća prije predaje zahtjeva.', 'se', '["su", "je", "se", "si"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c9f872ea-7789-51d0-9977-1a081b31d814', 'multiple_choice', 'Що означає «razlikovni ispit»?', 'різницевий іспит (додатковий)', '["виписка оцінок (додаток)", "визнання диплома", "різницевий іспит (додатковий)", "бракувати"]'::jsonb, 'A2', 2, 'PUBLISHED', 'razlikovni ispit', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8207021d-0290-586e-99e1-3236f6004da5', 'multiple_choice', 'Що означає «trajanje postupka»?', 'тривалість процедури', '["виписка оцінок (додаток)", "тривалість процедури", "доповнити", "бракувати"]'::jsonb, 'A2', 3, 'PUBLISHED', 'trajanje postupka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c2a45004-5504-5362-a2ae-62859107d65d', 'multiple_choice', 'Що означає «dodatak diplomi»?', 'додаток до диплома', '["подати заяву", "додати (документ)", "додаток до диплома", "професійне визнання"]'::jsonb, 'A2', 4, 'PUBLISHED', 'dodatak diplomi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0e77b327-b717-5d07-baa5-bc0db2e23384', 'multiple_choice', 'Як хорватською «виписка оцінок (додаток)»?', 'prijepis ocjena', '["usporediv", "prijepis ocjena", "podnijeti zahtjev", "rješenje o priznavanju"]'::jsonb, 'A2', 5, 'PUBLISHED', 'prijepis ocjena', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'af09b222-54c6-5475-918f-03b56edbb5d6', 'multiple_choice', 'Як хорватською «адміністративний збір»?', 'upravna pristojba', '["nedostajati", "priznavanje diplome", "upravna pristojba", "prijepis ocjena"]'::jsonb, 'A2', 6, 'PUBLISHED', 'upravna pristojba', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f9eda0b-3fde-5d7f-a2df-059a8ad5f8a9', 'type_answer', 'Напишіть хорватською: «порівнянний»', 'usporediv', null, 'A2', 7, 'PUBLISHED', 'usporediv', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '88c9d90b-9a9c-57d3-a837-74beaf6f9085', 'type_answer', 'Напишіть хорватською: «апостиль»', 'apostille', null, 'A2', 8, 'PUBLISHED', 'apostille', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ce4f23d4-de08-55db-9bb5-5a274b532470', 'type_answer', 'Напишіть хорватською: «доповнити»', 'dopuniti', null, 'A2', 9, 'PUBLISHED', 'dopuniti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ea7274e5-aed4-5527-bf96-001a4cd66d57', 'sentence_builder', 'Складіть: «Бракує виписки оцінок.»', 'Nedostaje prijepis ocjena.', '["ocjena.", "prijepis", "Nedostaje"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8095d296-0bb7-584f-84ed-167ab0a4984a', 'sentence_builder', 'Складіть: «Заяву схвалено.»', 'Zahtjev je odobren.', '["odobren.", "Zahtjev", "je"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1ff61e2a-ec87-5254-9701-fe38e00c6962', 'listening', 'Прослухайте і складіть фразу', 'Zahtjev nije odbijen, ali nedostaje dodatak diplomi.', '["dodatak", "ali", "diplomi.", "odbijen,", "nedostaje", "Zahtjev", "nije"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '07754446-38cb-5034-9bb4-6de2bc2d6592', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'перекладу додатка до диплома; e-mailом або особисто; 10 днів', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Вам телефонували з відділу визнання кваліфікацій.", "script": [{"hr": "Dobar dan, zovem iz ureda za priznavanje inozemnih kvalifikacija.", "ua": "Добрий день, телефоную з відділу визнання іноземних кваліфікацій."}, {"hr": "U Vašem zahtjevu nedostaje prijevod dodatka diplomi.", "ua": "У вашій заяві бракує перекладу додатка до диплома."}, {"hr": "Možete ga poslati e-mailom ili donijeti osobno.", "ua": "Можете надіслати його електронною поштою або принести особисто."}, {"hr": "Rok je deset dana, inače se zahtjev odbija.", "ua": "Строк — десять днів, інакше заяву відхиляють."}], "questions": [{"q_ua": "Чого бракує в заяві?", "options": ["перекладу додатка до диплома", "апостиля", "фото"], "correct": 0, "answer_turn": 1}, {"q_ua": "Як можна передати документ?", "options": ["лише поштою", "e-mailом або особисто", "через школу"], "correct": 1, "answer_turn": 2}, {"q_ua": "Який строк?", "options": ["8 днів", "30 днів", "10 днів"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '07754446-38cb-5034-9bb4-6de2bc2d6592', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e69626df-9518-5f85-95bd-f71cbf84df25', 'speaking', 'Як визнається диплом?', 'Kako se priznaje diploma?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dcfe4d15-e94a-546a-84b4-8a18f07f38c2', 'speaking', 'Що треба додати до заяви?', 'Što treba priložiti zahtjevu?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'c74ad249-d732-55c4-b7b8-68526d16310f', 'write_message', 'Напишіть у відділ визнання: ви надсилаєте переклад додатка до диплома, якого бракувало, і питаєте, скільки ще триватиме процедура.', 'Poštovani, u privitku šaljem prijevod dodatka diplomi koji je nedostajao. Koliko će još trajati postupak?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у відділ визнання: ви надсилаєте переклад додатка до диплома, якого бракувало, і питаєте, скільки ще триватиме процедура.", "points": [{"ua": "надсилаєте переклад", "keys": [["šalj", "prijevod"], ["prilaž", "prijevod"]]}, {"ua": "додаток до диплома", "keys": [["dodat"]]}, {"ua": "скільки триватиме", "keys": [["traj"]]}], "hints": ["u privitku šaljem", "prijevod dodatka diplomi", "koliko će još trajati postupak?"], "models": ["Poštovani, u privitku šaljem prijevod dodatka diplomi koji je nedostajao. Koliko će još trajati postupak?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'c74ad249-d732-55c4-b7b8-68526d16310f', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '146c51be-b748-5f0e-bb1b-0f4ade15435e', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Treba li apostille na diplomi? Može li se zahtjev predati online?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай, чи потрібен апостиль на дипломі і чи можна подати заяву онлайн.", "direction": "ua_hr", "points": [{"ua": "апостиль", "keys": [["apostille"]]}, {"ua": "онлайн", "keys": [["online"], ["internet"]]}], "hints": [], "models": ["Treba li apostille na diplomi? Može li se zahtjev predati online?"], "source_ua": "Спитай, чи потрібен апостиль на дипломі і чи можна подати заяву онлайн."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '146c51be-b748-5f0e-bb1b-0f4ade15435e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('522c77f2-e09e-5aa9-80b2-aff2e310ce28', v_lesson, 'Які документи?', 'Koji dokumenti?', 5111, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('7fb4bba9-8b78-54bc-8fb7-b9e4b2c47fc1', '522c77f2-e09e-5aa9-80b2-aff2e310ce28', 'Darja', 'Dobar dan, završila sam medicinsku školu u Ukrajini. Kako se priznaje diploma?', 'Добрий день, я закінчила медичне училище в Україні. Як визнається диплом?', 1);
  perform pg_temp.turn('4d8ab032-6a96-5cf6-a4aa-90975884fc6f', '522c77f2-e09e-5aa9-80b2-aff2e310ce28', 'Službenica', 'Medicinska sestra je regulirana profesija, pa treba stručno priznavanje.', 'Медсестра — регульована професія, тому потрібне професійне визнання.', 2);
  perform pg_temp.turn('a76a271c-cba9-5d76-b5a5-bfdcf4a74fa0', '522c77f2-e09e-5aa9-80b2-aff2e310ce28', 'Darja', 'Što se prilaže uz zahtjev?', 'Що додається до заяви?', 3);
  perform pg_temp.turn('73202db7-bff8-5d74-a9e1-17786d78666a', '522c77f2-e09e-5aa9-80b2-aff2e310ce28', 'Službenica', 'Ovjerena preslika diplome s apostilleom i prijepis ocjena, s prijevodom.', 'Засвідчена копія диплома з апостилем і виписка оцінок, з перекладом.', 4);
  perform pg_temp.turn('8063f47a-dc50-5823-8c9b-20aed5abbef4', '522c77f2-e09e-5aa9-80b2-aff2e310ce28', 'Darja', 'Koliko traje postupak?', 'Скільки триває процедура?', 5);
  perform pg_temp.turn('ab052568-aa7b-53dc-bcc1-f21705670488', '522c77f2-e09e-5aa9-80b2-aff2e310ce28', 'Službenica', 'Do šezdeset dana. Upravna pristojba se plaća prije predaje.', 'До шістдесяти днів. Адміністративний збір сплачують перед поданням.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e00fb5bb-a209-56a8-8cac-3464e460f129', v_lesson, 'Лист з відділу', 'Pismo iz ureda', 5112, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('a927632e-9e53-523e-a5c8-4c8ddf489dc4', 'e00fb5bb-a209-56a8-8cac-3464e460f129', 'Ivan', 'Darja, što piše u pismu?', 'Дар’є, що пише в листі?', 1);
  perform pg_temp.turn('597d6869-72df-5aad-8a44-dcf456a2a2ab', 'e00fb5bb-a209-56a8-8cac-3464e460f129', 'Darja', 'Zahtjev nije odbijen, ali nedostaje dodatak diplomi.', 'Заяву не відхилили, але бракує додатка до диплома.', 2);
  perform pg_temp.turn('382ad0d7-992e-5c78-838e-a23e58ac2ea4', 'e00fb5bb-a209-56a8-8cac-3464e460f129', 'Ivan', 'Do kada ga moraš poslati?', 'До коли ти маєш його надіслати?', 3);
  perform pg_temp.turn('352f494b-f2a0-58f2-9e99-d1bda9eb32d6', 'e00fb5bb-a209-56a8-8cac-3464e460f129', 'Darja', 'Zahtjev moram dopuniti u roku od osam dana.', 'Я маю доповнити заяву протягом восьми днів.', 4);
  perform pg_temp.turn('223b04c9-68d3-5f50-8bad-4f8b9eb5412f', 'e00fb5bb-a209-56a8-8cac-3464e460f129', 'Ivan', 'A ako studij nije usporediv?', 'А якщо навчання не порівнянне?', 5);
  perform pg_temp.turn('b7e34e47-0c75-5c0b-891f-785e7f8dfde1', 'e00fb5bb-a209-56a8-8cac-3464e460f129', 'Darja', 'Onda ću morati položiti razlikovni ispit.', 'Тоді доведеться скласти різницевий іспит.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.2 · урок 12: На парах і на іспиті — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6b2a808e-df6e-5da3-bf7a-597668e47495';
  v_lesson constant uuid := '4be96321-cd99-57ff-a9bc-17cfaf4f4c29';
  v_gid constant uuid := '0b2de584-05a6-5570-a129-366fcb94766d';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики VID'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A2.2: місце 4 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 12: На парах і на іспиті', 'Lekcija 12: Na nastavi i na ispitu', '["Розповісти про пари, семінари й іспити", "Розрізняти: polagati — položiti, pisati — napisati, učiti — naučiti"]'::jsonb, 20, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kolegij', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vježbe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'seminar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'seminarski rad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolokvij', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispitni rok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polagati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'položiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'usmeni ispit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pismeni ispit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'asistent', v_pos);
  v_pos := pg_temp.word(v_lesson, 'konzultacije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bilješke', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skripta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'literatura', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prolazna ocjena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prepisivati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naučiti napamet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponavljati gradivo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prisutnost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponoviti godinu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispitno pitanje', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd482e6ec-2509-53e1-8439-86d7c539d45b', 'fill_in_the_blank', 'Jučer sam ___ zadnji ispit i sad sam slobodna!', 'položila', '["polagati", "položila", "polagala", "polažem"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f4cbb917-b2b7-514b-afc7-0cf202f940a3', 'multiple_choice', 'Що означає «skripta»?', 'конспект лекцій (посібник)', '["усний іспит", "залишитися на другий рік", "конспект лекцій (посібник)", "курсова (реферат)"]'::jsonb, 'A2', 2, 'PUBLISHED', 'skripta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '593f6039-c002-5a2c-bf27-a52226e01eb5', 'multiple_choice', 'Що означає «vježbe»?', 'практичні заняття', '["практичні заняття", "курсова (реферат)", "семінар", "нотатки, конспект"]'::jsonb, 'A2', 3, 'PUBLISHED', 'vježbe', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5650138d-471b-5950-814b-685002109bc5', 'multiple_choice', 'Що означає «kolegij»?', 'навчальна дисципліна, курс', '["залишитися на другий рік", "асистент (викладач)", "навчальна дисципліна, курс", "усний іспит"]'::jsonb, 'A2', 4, 'PUBLISHED', 'kolegij', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e3a7e729-6966-5e5e-8214-b58c1600415a', 'multiple_choice', 'Як хорватською «асистент (викладач)»?', 'asistent', '["prolazna ocjena", "ispitni rok", "asistent", "prisutnost"]'::jsonb, 'A2', 5, 'PUBLISHED', 'asistent', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b4cd7380-51c3-54c4-b428-bf0e23882f64', 'multiple_choice', 'Як хорватською «семінар»?', 'seminar', '["skripta", "kolokvij", "seminar", "ispitno pitanje"]'::jsonb, 'A2', 6, 'PUBLISHED', 'seminar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd2af2840-065b-5ea7-8735-8ff5dfdde202', 'type_answer', 'Напишіть хорватською: «курсова (реферат)»', 'seminarski rad', null, 'A2', 7, 'PUBLISHED', 'seminarski rad', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6c267867-3af3-51a3-a626-6cdf6ba63fa7', 'type_answer', 'Напишіть хорватською: «література (для курсу)»', 'literatura', null, 'A2', 8, 'PUBLISHED', 'literatura', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '594cf85d-a3ba-5ff8-93b3-1309e3ecc413', 'type_answer', 'Напишіть хорватською: «складати (іспит)»', 'polagati', null, 'A2', 9, 'PUBLISHED', 'polagati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4d8d6056-b45c-5dd8-b494-f7a8c2b998b1', 'sentence_builder', 'Складіть: «Можеш позичити мені свій конспект?»', 'Možeš li mi posuditi svoje bilješke?', '["posuditi", "bilješke?", "li", "Možeš", "svoje", "mi"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e796aaa2-c421-500d-93fc-02392ba57202', 'sentence_builder', 'Складіть: «Наступна сесія у вересні.»', 'Sljedeći ispitni rok je u rujnu.', '["u", "rok", "ispitni", "je", "Sljedeći", "rujnu."]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0c77412f-45a6-56f4-b18f-e2c6e8fa3593', 'listening', 'Прослухайте і складіть фразу', 'Hoću, hvala! Bez njih ne bih znala ponoviti gradivo.', '["Hoću,", "gradivo.", "ne", "bih", "znala", "hvala!", "ponoviti", "Bez", "njih"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '9892fc3c-9600-534b-8e1d-bb0662baa629', 'listening_dialogue', 'Прослухайте оголошення', 'наступного четверга; не треба писати письмовий іспит; калькулятор', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Асистент говорить студентам наприкінці пари. Послухайте.", "script": [{"hr": "Kolokvij iz statistike pišemo idući četvrtak u devet sati.", "ua": "Колоквіум зі статистики пишемо наступного четверга о дев’ятій."}, {"hr": "Tko položi kolokvij, ne mora pisati pismeni ispit.", "ua": "Хто складе колоквіум, тому не треба писати письмовий іспит."}, {"hr": "Ponesite kalkulator, a mobiteli moraju biti isključeni.", "ua": "Візьміть калькулятор, а мобільні мають бути вимкнені."}], "questions": [{"q_ua": "Коли колоквіум?", "options": ["наступного четверга", "у понеділок", "завтра"], "correct": 0, "answer_turn": 0}, {"q_ua": "Що буде, якщо скласти колоквіум?", "options": ["не треба писати письмовий іспит", "не треба ходити на пари", "отримаєш «відмінно»"], "correct": 0, "answer_turn": 1}, {"q_ua": "Що треба взяти?", "options": ["конспект", "калькулятор", "студентський квиток"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '9892fc3c-9600-534b-8e1d-bb0662baa629', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f2d6138a-7c50-554c-9ea5-571a75a08034', 'speaking', 'Я склала всі іспити!', 'Položila sam sve ispite!', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '065638dd-9411-5583-8efe-d483eae614d8', 'speaking', 'Коли в професорки консультації?', 'Kada profesorica ima konzultacije?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '4f26e190-9747-5500-aec5-17af90aa37b1', 'write_message', 'Напишіть одногрупнику: ви не були на парі в понеділок і просите позичити конспект; спитайте, коли колоквіум.', 'Bok, nisam bila na nastavi u ponedjeljak. Možeš li mi posuditi bilješke? Kada je kolokvij?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть одногрупнику: ви не були на парі в понеділок і просите позичити конспект; спитайте, коли колоквіум.", "points": [{"ua": "не були на парі", "keys": [["nisam bil"], ["nisam bio"], ["nije me bilo"]]}, {"ua": "позичити конспект", "keys": [["bilješk"]]}, {"ua": "коли колоквіум", "keys": [["kolokvij"]]}], "hints": ["nisam bila na nastavi", "posudi mi bilješke", "kada je kolokvij?"], "models": ["Bok, nisam bila na nastavi u ponedjeljak. Možeš li mi posuditi bilješke? Kada je kolokvij?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '4f26e190-9747-5500-aec5-17af90aa37b1', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '0b0c1df2-47db-50fb-aed9-1d606d75de07', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Je li prisutnost na seminaru obvezna? Gdje je popis literature?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай асистента, чи обов’язкова присутність на семінарі і де знайти список літератури.", "direction": "ua_hr", "points": [{"ua": "присутність обов’язкова", "keys": [["prisutnost"], ["obvez"]]}, {"ua": "семінар", "keys": [["seminar"]]}, {"ua": "список літератури", "keys": [["literatur"]]}], "hints": [], "models": ["Je li prisutnost na seminaru obvezna? Gdje je popis literature?"], "source_ua": "Спитай асистента, чи обов’язкова присутність на семінарі і де знайти список літератури."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '0b0c1df2-47db-50fb-aed9-1d606d75de07', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('420004fb-40ca-5b0b-8ea6-a602d5b3ff5a', v_lesson, 'Перед іспитом', 'Prije ispita', 5121, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('65126c59-28c8-5a7b-8a7e-51c98fe23178', '420004fb-40ca-5b0b-8ea6-a602d5b3ff5a', 'Luka', 'Dašo, kad polažeš statistiku?', 'Дашо, коли ти складаєш статистику?', 1);
  perform pg_temp.turn('c7fbe470-38b6-594c-94e3-9a22a3ed194f', '420004fb-40ca-5b0b-8ea6-a602d5b3ff5a', 'Daša', 'U ponedjeljak. Pismeni ispit, pa usmeni.', 'У понеділок. Письмовий іспит, а потім усний.', 2);
  perform pg_temp.turn('95378c8f-98d2-5f2f-9a6c-9f8a072f9366', '420004fb-40ca-5b0b-8ea6-a602d5b3ff5a', 'Luka', 'Jesi li naučila sve formule?', 'Ти вивчила всі формули?', 3);
  perform pg_temp.turn('0f98a1ba-fa05-5a46-84a3-89b35490e27d', '420004fb-40ca-5b0b-8ea6-a602d5b3ff5a', 'Daša', 'Učim ih cijeli tjedan, ali još nisam naučila sve.', 'Учу їх цілий тиждень, але ще не вивчила всі.', 4);
  perform pg_temp.turn('a4845b85-bfeb-5591-8098-ce4adc978017', '420004fb-40ca-5b0b-8ea6-a602d5b3ff5a', 'Luka', 'Imam dobre bilješke s vježbi. Hoćeš li ih?', 'У мене гарний конспект із практичних. Хочеш?', 5);
  perform pg_temp.turn('4b6fb6c1-5890-59fa-8fe6-71227ea23669', '420004fb-40ca-5b0b-8ea6-a602d5b3ff5a', 'Daša', 'Hoću, hvala! Bez njih ne bih znala ponoviti gradivo.', 'Хочу, дякую! Без нього я б не знала, як повторити матеріал.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d8bce6ec-0316-5fe5-a79c-7a3f296ddf01', v_lesson, 'Після іспиту', 'Nakon ispita', 5122, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('f276a261-4b20-5fef-b117-9ee9dab13e9c', 'd8bce6ec-0316-5fe5-a79c-7a3f296ddf01', 'Darja', 'Kako je bilo na ispitu?', 'Як було на іспиті?', 1);
  perform pg_temp.turn('08c3cd1e-a8cd-59dd-be70-3f256a7aa875', 'd8bce6ec-0316-5fe5-a79c-7a3f296ddf01', 'Daša', 'Položila sam! Dobila sam vrlo dobar.', 'Я склала! Отримала «дуже добре».', 2);
  perform pg_temp.turn('f073e3f5-3d75-5f4e-a2e6-c111a5f3bed4', 'd8bce6ec-0316-5fe5-a79c-7a3f296ddf01', 'Darja', 'Čestitam! A Luka?', 'Вітаю! А Лука?', 3);
  perform pg_temp.turn('abacba4f-ffa0-523e-98ce-91436ee13d2e', 'd8bce6ec-0316-5fe5-a79c-7a3f296ddf01', 'Daša', 'On je pao na usmenom. Ide opet u sljedećem ispitnom roku.', 'Він провалив усний. Піде знову на наступну сесію.', 4);
  perform pg_temp.turn('ae4b437b-b81d-58a8-a3a3-d3000b365453', 'd8bce6ec-0316-5fe5-a79c-7a3f296ddf01', 'Darja', 'Neka ide na konzultacije prije toga.', 'Хай піде на консультацію перед тим.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.2 · урок 13: Перекваліфікація й курси для дорослих — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6b2a808e-df6e-5da3-bf7a-597668e47495';
  v_lesson constant uuid := '24894494-1af7-5153-a7b0-7f0ef3c0bdce';
  v_gid constant uuid := '0c68352a-803a-5410-a59b-91f2c1ddc49f';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KOND'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A2.2: місце 5 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 13: Перекваліфікація й курси для дорослих', 'Lekcija 13: Prekvalifikacija i obrazovanje odraslih', '["Розпитати про програми перекваліфікації й ваучери", "Пояснити мету: Upisala bih tečaj da bih…"]'::jsonb, 20, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'prekvalifikacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obrazovanje odraslih', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pučko otvoreno učilište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vaučer za obrazovanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'usavršavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osposobljavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stručni ispit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'praktična nastava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'digitalne vještine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tržište rada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tražen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'deficitarno zanimanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'viličarist', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zavarivač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'knjigovođa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'programiranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uvjerenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'besplatan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'savjetnik za zapošljavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijaviti se na Zavod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'promijeniti struku', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa1e5962-cbb9-52a5-a61a-e25b1054f574', 'fill_in_the_blank', 'Učim programiranje da ___ našla bolji posao.', 'bih', '["bih", "bismo", "bi", "biste"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '865ed517-2257-59e3-bbe5-2cee799951f3', 'multiple_choice', 'Що означає «obrazovanje odraslih»?', 'освіта дорослих', '["освіта дорослих", "перекваліфікація", "народний відкритий навчальний заклад (освіта дорослих)", "дефіцитна професія"]'::jsonb, 'A2', 2, 'PUBLISHED', 'obrazovanje odraslih', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3251d28d-3d26-5796-aac0-2dac6ce6112a', 'multiple_choice', 'Що означає «praktična nastava»?', 'практичне навчання', '["кваліфікаційний іспит", "практичне навчання", "консультант з працевлаштування", "стати на облік у службі зайнятості"]'::jsonb, 'A2', 3, 'PUBLISHED', 'praktična nastava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bb1aa21a-fd1a-5b49-af64-87cc77678d96', 'multiple_choice', 'Що означає «viličarist»?', 'водій навантажувача', '["перекваліфікація", "водій навантажувача", "бухгалтер (рахівник)", "затребуваний"]'::jsonb, 'A2', 4, 'PUBLISHED', 'viličarist', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '12ae8b08-75a8-5bfb-b2db-55cead771a8d', 'multiple_choice', 'Як хорватською «програмування»?', 'programiranje', '["besplatan", "stručni ispit", "digitalne vještine", "programiranje"]'::jsonb, 'A2', 5, 'PUBLISHED', 'programiranje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '18cf603d-e0f0-5f95-80b6-18054460d0eb', 'multiple_choice', 'Як хорватською «ринок праці»?', 'tržište rada', '["tržište rada", "zavarivač", "praktična nastava", "programiranje"]'::jsonb, 'A2', 6, 'PUBLISHED', 'tržište rada', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '870661b7-84df-5f03-9be5-443464e15cb7', 'type_answer', 'Напишіть хорватською: «зварювальник»', 'zavarivač', null, 'A2', 7, 'PUBLISHED', 'zavarivač', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cb97bd5c-e014-5919-93f8-3ae25165ff0d', 'type_answer', 'Напишіть хорватською: «бухгалтер (рахівник)»', 'knjigovođa', null, 'A2', 8, 'PUBLISHED', 'knjigovođa', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6d51aa66-e703-5c5c-9799-6fe2b740fb42', 'type_answer', 'Напишіть хорватською: «затребуваний»', 'tražen', null, 'A2', 9, 'PUBLISHED', 'tražen', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '401503e0-dcac-548c-887d-c8731c7b1d97', 'sentence_builder', 'Складіть: «Я хотіла б змінити фах.»', 'Htjela bih promijeniti struku.', '["struku.", "bih", "promijeniti", "Htjela"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'efa39596-d860-5d1a-9ac4-b8300f7ab551', 'sentence_builder', 'Складіть: «Для безробітних курс безкоштовний.»', 'Za nezaposlene je tečaj besplatan.', '["nezaposlene", "Za", "besplatan.", "tečaj", "je"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ed3f21e2-5c3b-55b8-ace5-102afd8acf4b', 'listening', 'Прослухайте і складіть фразу', 'Koliko traje?', '["traje?", "Koliko"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '03ff634b-af39-592d-b7ee-e3265ead9a5b', 'listening_dialogue', 'Прослухайте оголошення', 'безробітні з ваучером; зварювальник; до кінця місяця', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Ви слухаєте рекламу на місцевому радіо.", "script": [{"hr": "Pučko otvoreno učilište upisuje polaznike za nove programe.", "ua": "Народний відкритий навчальний заклад набирає слухачів на нові програми."}, {"hr": "Nudimo osposobljavanje za viličariste, njegovatelje i knjigovođe.", "ua": "Пропонуємо навчання на водіїв навантажувачів, доглядальників і бухгалтерів."}, {"hr": "Za nezaposlene s vaučerom programi su besplatni.", "ua": "Для безробітних з ваучером програми безкоштовні."}, {"hr": "Upisi traju do kraja mjeseca.", "ua": "Набір триває до кінця місяця."}], "questions": [{"q_ua": "Хто може вчитися безкоштовно?", "options": ["усі охочі", "безробітні з ваучером", "студенти"], "correct": 1, "answer_turn": 2}, {"q_ua": "Якої програми НЕМАЄ в оголошенні?", "options": ["водій навантажувача", "зварювальник", "бухгалтер"], "correct": 1, "answer_turn": 1}, {"q_ua": "До коли набір?", "options": ["до кінця місяця", "до кінця року", "до понеділка"], "correct": 0, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '03ff634b-af39-592d-b7ee-e3265ead9a5b', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f2c915aa-d41c-5ff1-9721-7284d84759e0', 'speaking', 'Я б записалася на курс, щоб знайти роботу.', 'Upisala bih tečaj da bih našla posao.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c3c37823-54b3-536e-a8bb-ffa7cf974317', 'speaking', 'Чи можу я отримати ваучер на навчання?', 'Mogu li dobiti vaučer za obrazovanje?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '736391ed-22dc-585a-a31b-0d494a206b2d', 'write_message', 'Напишіть консультанту служби зайнятості: хочете перекваліфікуватися на бухгалтера й питаєте про ваучер на навчання.', 'Poštovani, htjela bih se prekvalificirati za knjigovođu. Mogu li dobiti vaučer za obrazovanje?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть консультанту служби зайнятості: хочете перекваліфікуватися на бухгалтера й питаєте про ваучер на навчання.", "points": [{"ua": "перекваліфікуватися", "keys": [["prekvalifi"], ["promijeni", "struk"]]}, {"ua": "на бухгалтера", "keys": [["knjigovođ"], ["knjigovodstv"]]}, {"ua": "ваучер", "keys": [["vaučer"]]}], "hints": ["htjela bih se prekvalificirati", "za knjigovođu", "vaučer za obrazovanje"], "models": ["Poštovani, htjela bih se prekvalificirati za knjigovođu. Mogu li dobiti vaučer za obrazovanje?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '736391ed-22dc-585a-a31b-0d494a206b2d', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'f54146f9-fff5-5572-8f02-dda804e2d2cb', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Moj prijatelj je bio vozač u Ukrajini i htio bi se osposobiti za viličarista.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи консультанту, що я був водієм в Україні і хотів би отримати посвідчення водія навантажувача.", "direction": "ua_hr", "points": [{"ua": "був водієм", "keys": [["vozač"]]}, {"ua": "в Україні", "keys": [["Ukrajin"]]}, {"ua": "навантажувач", "keys": [["viličar"]]}], "hints": [], "models": ["Moj prijatelj je bio vozač u Ukrajini i htio bi se osposobiti za viličarista."], "source_ua": "Скажи консультанту, що я був водієм в Україні і хотів би отримати посвідчення водія навантажувача."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'f54146f9-fff5-5572-8f02-dda804e2d2cb', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('79440b3e-fb1f-5693-a774-b7feff13d03d', v_lesson, 'У консультанта', 'Kod savjetnika', 5131, 'A2', 'work', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('3012e167-ceba-5a74-83a0-61c302f2841d', '79440b3e-fb1f-5693-a774-b7feff13d03d', 'Darja', 'Dobar dan. U Ukrajini sam bila učiteljica, ali htjela bih promijeniti struku.', 'Добрий день. В Україні я була вчителькою, але хотіла б змінити фах.', 1);
  perform pg_temp.turn('bca6bad3-cb98-5b06-a50c-be388622401d', '79440b3e-fb1f-5693-a774-b7feff13d03d', 'Savjetnik', 'Što biste voljeli raditi?', 'Чим би ви хотіли займатися?', 2);
  perform pg_temp.turn('65dcf101-6c77-5622-893a-9923a940c0e8', '79440b3e-fb1f-5693-a774-b7feff13d03d', 'Darja', 'Možda knjigovodstvo. Upisala bih tečaj da bih brže našla posao.', 'Можливо, бухгалтерією. Я б записалася на курс, щоб швидше знайти роботу.', 3);
  perform pg_temp.turn('c53feaab-48dc-50dd-afb7-6cb46ebf1f10', '79440b3e-fb1f-5693-a774-b7feff13d03d', 'Savjetnik', 'Knjigovođe su traženi. Možete dobiti vaučer za obrazovanje.', 'Бухгалтери затребувані. Ви можете отримати ваучер на навчання.', 4);
  perform pg_temp.turn('d0611753-1c28-52bd-9ca2-1ca520ba5cd9', '79440b3e-fb1f-5693-a774-b7feff13d03d', 'Darja', 'Je li tečaj onda besplatan?', 'Тоді курс безкоштовний?', 5);
  perform pg_temp.turn('68676bb3-c221-5a33-8977-1335d3816e78', '79440b3e-fb1f-5693-a774-b7feff13d03d', 'Savjetnik', 'Jest. Na kraju polažete stručni ispit i dobivate uvjerenje.', 'Так. Наприкінці складаєте кваліфікаційний іспит і отримуєте свідоцтво.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a370c59a-771e-5703-a2f1-b65200d3955f', v_lesson, 'Нова професія', 'Novo zanimanje', 5132, 'A2', 'work', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('ab8103ec-0aea-5dd7-8416-ec2e6f88d449', 'a370c59a-771e-5703-a2f1-b65200d3955f', 'Ivan', 'Čuo sam da si upisao osposobljavanje.', 'Я чув, що ти записався на професійне навчання.', 1);
  perform pg_temp.turn('b30e3811-13f4-5f85-a0d3-88f787713e2b', 'a370c59a-771e-5703-a2f1-b65200d3955f', 'Marko', 'Jesam, za zavarivača. To je deficitarno zanimanje.', 'Так, на зварювальника. Це дефіцитна професія.', 2);
  perform pg_temp.turn('a2d1b84d-d183-50f2-a045-337b9ff99b2b', 'a370c59a-771e-5703-a2f1-b65200d3955f', 'Ivan', 'Koliko traje?', 'Скільки триває?', 3);
  perform pg_temp.turn('e7178f54-fc1b-5ab0-80a7-9ce63501c97e', 'a370c59a-771e-5703-a2f1-b65200d3955f', 'Marko', 'Četiri mjeseca. Pola je praktična nastava u radionici.', 'Чотири місяці. Половина — практичне навчання в майстерні.', 4);
  perform pg_temp.turn('4dba7457-7683-544d-b1b3-c4732e61b2da', 'a370c59a-771e-5703-a2f1-b65200d3955f', 'Ivan', 'I ja bih nešto upisao da bih bolje zarađivao.', 'І я б щось записав, щоб краще заробляти.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.2 · урок 14: Хорватська школа: як вона влаштована — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6b2a808e-df6e-5da3-bf7a-597668e47495';
  v_lesson constant uuid := '2a1b2b63-def1-5fb9-91e6-d09e1fd5b95c';
  v_gid constant uuid := 'a6dba6b3-0b0a-588c-acd4-7eedced88519';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики PAS'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A2.2: місце 6 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 14: Хорватська школа: як вона влаштована', 'Lekcija 14: Hrvatska škola: kako je organizirana', '["Зрозуміти, як влаштована школа: ступені, оцінки, півріччя, предмети", "Описати правила з пасивом: Ocjene se upisuju u e-Dnevnik"]'::jsonb, 20, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'razredna nastava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predmetna nastava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obvezno obrazovanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'školska godina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polugodište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaključna ocjena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nedovoljan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dovoljan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odličan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izborni predmet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vjeronauk', v_pos);
  v_pos := pg_temp.word(v_lesson, 'strani jezik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'e-Dnevnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'školski pedagog', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ravnatelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijelaz u drugu školu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispisnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upisno područje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dopunska nastava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dodatna nastava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'školski praznici', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '1feacf9c-07db-5374-9dd4-ec9b073afe6f', 'fill_in_the_blank', 'Ocjene ___ upisuju u e-Dnevnik.', 'se', '["su", "ih", "se", "je"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '89d495c6-3af4-55df-a519-80b11c1b07e5', 'multiple_choice', 'Що означає «prijelaz u drugu školu»?', 'перехід до іншої школи', '["перехід до іншої школи", "релігієзнавство (урок)", "незадовільно (оцінка 1)", "предмет за вибором"]'::jsonb, 'A2', 2, 'PUBLISHED', 'prijelaz u drugu školu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7afe36da-9ab5-55c8-a696-deab41ca9323', 'multiple_choice', 'Що означає «školski pedagog»?', 'шкільний педагог', '["півріччя", "перехід до іншої школи", "шкільний педагог", "релігієзнавство (урок)"]'::jsonb, 'A2', 3, 'PUBLISHED', 'školski pedagog', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '26a76d0c-31c7-567d-98b4-5a24ab670c4a', 'multiple_choice', 'Що означає «dodatna nastava»?', 'поглиблені заняття (для сильних)', '["достатньо (оцінка 2)", "поглиблені заняття (для сильних)", "перехід до іншої школи", "середні класи (5–8, предметники)"]'::jsonb, 'A2', 4, 'PUBLISHED', 'dodatna nastava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c76604fa-061b-5141-8f27-b28ed7c9d073', 'multiple_choice', 'Як хорватською «достатньо (оцінка 2)»?', 'dovoljan', '["vjeronauk", "dodatna nastava", "ispisnica", "dovoljan"]'::jsonb, 'A2', 5, 'PUBLISHED', 'dovoljan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f5667e53-d8e5-50df-8406-dbe7de9c1bdc', 'multiple_choice', 'Як хорватською «середні класи (5–8, предметники)»?', 'predmetna nastava', '["obvezno obrazovanje", "zaključna ocjena", "predmetna nastava", "dodatna nastava"]'::jsonb, 'A2', 6, 'PUBLISHED', 'predmetna nastava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cb3009b3-a93c-54f5-8998-7ed505b9f643', 'type_answer', 'Напишіть хорватською: «півріччя»', 'polugodište', null, 'A2', 7, 'PUBLISHED', 'polugodište', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '145da43f-f7bd-5411-8727-fb72f26b0842', 'type_answer', 'Напишіть хорватською: «незадовільно (оцінка 1)»', 'nedovoljan', null, 'A2', 8, 'PUBLISHED', 'nedovoljan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b923adbb-4562-5168-9e3b-3588e58631d2', 'type_answer', 'Напишіть хорватською: «електронний щоденник (журнал)»', 'e-Dnevnik', null, 'A2', 9, 'PUBLISHED', 'e-Dnevnik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3e2822c7-4c3d-58e3-8be3-b382a8defcb5', 'sentence_builder', 'Складіть: «З п’ятого класу предметне навчання.»', 'Od petog razreda je predmetna nastava.', '["petog", "nastava.", "je", "razreda", "predmetna", "Od"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8904280-ce58-5cb9-947d-0b352cc1d00f', 'sentence_builder', 'Складіть: «Релігієзнавство — предмет за вибором.»', 'Vjeronauk je izborni predmet.', '["predmet.", "Vjeronauk", "izborni", "je"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '98ae849c-731d-5d08-a2b5-4503dec1f50c', 'listening', 'Прослухайте і складіть фразу', 'Nije, to je izborni predmet. Može izabrati i etiku.', '["i", "izabrati", "etiku.", "Nije,", "to", "predmet.", "je", "Može", "izborni"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'b788c200-3022-5646-a91d-b2e20f8b8bbb', 'listening_dialogue', 'Прослухайте оголошення', '8 вересня; двічі на тиждень; класний керівник', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Ви на зборах для батьків нових учнів. Говорить директорка.", "script": [{"hr": "Školska godina počinje osmog rujna u osam sati.", "ua": "Навчальний рік починається восьмого вересня о восьмій."}, {"hr": "Učenici razredne nastave imaju nastavu ujutro.", "ua": "Учні початкових класів навчаються зранку."}, {"hr": "Djeca koja ne govore hrvatski mogu ići na dopunsku nastavu dvaput tjedno.", "ua": "Діти, які не говорять хорватською, можуть ходити на додаткові заняття двічі на тиждень."}, {"hr": "Lozinke za e-Dnevnik dobit ćete od razrednika.", "ua": "Паролі до електронного щоденника ви отримаєте від класного керівника."}], "questions": [{"q_ua": "Коли починається навчальний рік?", "options": ["1 вересня", "8 вересня", "15 вересня"], "correct": 1, "answer_turn": 0}, {"q_ua": "Як часто додаткові заняття з хорватської?", "options": ["двічі на тиждень", "щодня", "раз на місяць"], "correct": 0, "answer_turn": 2}, {"q_ua": "Хто дасть паролі до щоденника?", "options": ["директорка", "секретарка", "класний керівник"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'b788c200-3022-5646-a91d-b2e20f8b8bbb', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '542cf63f-237b-5497-baa6-bcb97bc93790', 'speaking', 'Як працює школа в Хорватії?', 'Kako funkcionira škola u Hrvatskoj?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5f9ef292-d7cf-5e21-ad8d-31d667b3c04e', 'speaking', 'Коли закінчується перше півріччя?', 'Kada završava prvo polugodište?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'ee497503-ade2-5233-b468-2e93f1913594', 'write_message', 'Напишіть класному керівнику: ваш син новий у школі й погано знає хорватську; спитайте про додаткові заняття.', 'Poštovana, moj sin je nov u školi i još slabo govori hrvatski. Može li ići na dopunsku nastavu?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть класному керівнику: ваш син новий у школі й погано знає хорватську; спитайте про додаткові заняття.", "points": [{"ua": "син новий у школі", "keys": [["nov"]]}, {"ua": "погано знає хорватську", "keys": [["hrvatsk"]]}, {"ua": "додаткові заняття", "keys": [["dopunsk"]]}], "hints": ["moj sin je nov u školi", "još slabo govori hrvatski", "dopunska nastava"], "models": ["Poštovana, moj sin je nov u školi i još slabo govori hrvatski. Može li ići na dopunsku nastavu?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'ee497503-ade2-5233-b468-2e93f1913594', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '3c53bd90-30fa-55de-a3f5-12f6800c7777', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Koji dokumenti trebaju za prijelaz djeteta u drugu školu?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай, які документи потрібні для переходу дитини в іншу школу.", "direction": "ua_hr", "points": [{"ua": "документи", "keys": [["dokument"], ["ispisnic"]]}, {"ua": "перехід в іншу школу", "keys": [["prijelaz"], ["drug", "škol"]]}], "hints": [], "models": ["Koji dokumenti trebaju za prijelaz djeteta u drugu školu?"], "source_ua": "Спитай, які документи потрібні для переходу дитини в іншу школу."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '3c53bd90-30fa-55de-a3f5-12f6800c7777', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6a40f674-1773-5e6b-8a4c-c37259f199bb', v_lesson, 'Як тут усе влаштовано?', 'Kako je tu sve organizirano?', 5141, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('389bc78d-918f-58f9-8fb6-3223568b6100', '6a40f674-1773-5e6b-8a4c-c37259f199bb', 'Darja', 'Ivana, kako funkcionira škola u Hrvatskoj? Sin ide u peti razred.', 'Івано, як працює школа в Хорватії? Син іде в п’ятий клас.', 1);
  perform pg_temp.turn('77abbf10-8a47-5ec2-bfbe-4ba20b7abcae', '6a40f674-1773-5e6b-8a4c-c37259f199bb', 'Ivana', 'Od petog razreda je predmetna nastava, svaki predmet ima svog nastavnika.', 'З п’ятого класу предметне навчання, у кожного предмета свій учитель.', 2);
  perform pg_temp.turn('9f93a660-5998-5e52-a829-bef89417061a', '6a40f674-1773-5e6b-8a4c-c37259f199bb', 'Darja', 'A ocjene? Kod nas je bilo do dvanaest.', 'А оцінки? У нас було до дванадцяти.', 3);
  perform pg_temp.turn('029dc517-e969-5457-89a3-88a0ad006003', '6a40f674-1773-5e6b-8a4c-c37259f199bb', 'Ivana', 'Ovdje od jedan do pet. Jedinica je nedovoljan, a petica odličan.', 'Тут від одного до п’яти. Одиниця — незадовільно, а п’ятірка — відмінно.', 4);
  perform pg_temp.turn('adc2d589-2d9e-5597-be06-68cdda12ec68', '6a40f674-1773-5e6b-8a4c-c37259f199bb', 'Darja', 'Gdje vidim ocjene?', 'Де я бачу оцінки?', 5);
  perform pg_temp.turn('95d8fc9c-c3f5-53a7-8ff1-777f94d28303', '6a40f674-1773-5e6b-8a4c-c37259f199bb', 'Ivana', 'Ocjene se upisuju u e-Dnevnik, imat ćeš svoju lozinku.', 'Оцінки вносять в електронний щоденник, у тебе буде свій пароль.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d50413e8-0f04-5bd4-8af4-565b6b3e6db0', v_lesson, 'Розмова з педагогом', 'Razgovor s pedagogom', 5142, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('2c588e51-c36f-52d4-9a08-85da151e652f', 'd50413e8-0f04-5bd4-8af4-565b6b3e6db0', 'Pedagoginja', 'Dobro došli. Filip može ići na dopunsku nastavu iz hrvatskog.', 'Ласкаво просимо. Філіп може ходити на додаткові заняття з хорватської.', 1);
  perform pg_temp.turn('298d1e43-0f14-5739-90b3-cb278eb3c1c8', 'd50413e8-0f04-5bd4-8af4-565b6b3e6db0', 'Darja', 'Odlično. Je li vjeronauk obvezan?', 'Чудово. Релігієзнавство обов’язкове?', 2);
  perform pg_temp.turn('461b048a-231e-5cd7-8bc8-28c66853390a', 'd50413e8-0f04-5bd4-8af4-565b6b3e6db0', 'Pedagoginja', 'Nije, to je izborni predmet. Može izabrati i etiku.', 'Ні, це предмет за вибором. Він може вибрати й етику.', 3);
  perform pg_temp.turn('c954b7fc-849b-5bc5-a463-ea888d19c776', 'd50413e8-0f04-5bd4-8af4-565b6b3e6db0', 'Darja', 'Kada završava prvo polugodište?', 'Коли закінчується перше півріччя?', 4);
  perform pg_temp.turn('78f464d7-ac58-5113-a758-42de4c915faa', 'd50413e8-0f04-5bd4-8af4-565b6b3e6db0', 'Pedagoginja', 'Pred Božić. Onda su zimski školski praznici.', 'Перед Різдвом. Потім зимові канікули.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.2 · урок 15: Розмова з учителем і батьківські збори — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6b2a808e-df6e-5da3-bf7a-597668e47495';
  v_lesson constant uuid := 'e32cdbd5-0e59-53c7-8773-bf31e69068a2';
  v_gid constant uuid := '0b2de584-05a6-5570-a129-366fcb94766d';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики VID'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A2.2: місце 7 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 15: Розмова з учителем і батьківські збори', 'Lekcija 15: Razgovor s učiteljicom i roditeljski sastanak', '["Поговорити з учителем про успіхи й проблеми дитини", "Пояснити відсутність і домовитися: Opravdat ću izostanak"]'::jsonb, 20, 'PUBLISHED', 7);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'informacije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razrednik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'napredak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poteškoće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vladanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ometati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'surađivati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izostanak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opravdati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispričnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'liječnička ispričnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neopravdan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pohvaliti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sastavak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lektira', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izlet razreda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'suglasnost roditelja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potpisati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prilagoditi se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sramežljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'druželjubiv', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '9951689c-af01-5a15-af28-4a7853eaa9eb', 'fill_in_the_blank', 'Sutra ću ___ izostanak, imam ispričnicu.', 'opravdati', '["opravdavati", "opravdati", "opravdala", "opravdam"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '25be2ca5-9728-5f87-b20a-c9af7cb6bfa6', 'multiple_choice', 'Що означає «izlet razreda»?', 'класна екскурсія', '["труднощі", "обов’язкова книжка для читання", "класна екскурсія", "сором’язливий"]'::jsonb, 'A2', 2, 'PUBLISHED', 'izlet razreda', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e9b3bd6e-906f-5c2a-a14f-3881e25538ee', 'multiple_choice', 'Що означає «suglasnost roditelja»?', 'згода батьків', '["обов’язкова книжка для читання", "класна екскурсія", "класний керівник", "згода батьків"]'::jsonb, 'A2', 3, 'PUBLISHED', 'suglasnost roditelja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4d6a9dd8-571d-517c-b85d-be2bea84a032', 'multiple_choice', 'Що означає «liječnička ispričnica»?', 'довідка від лікаря', '["довідка від лікаря", "співпрацювати", "труднощі", "згода батьків"]'::jsonb, 'A2', 4, 'PUBLISHED', 'liječnička ispričnica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a9471df7-8af7-5080-9dd2-5244baaa0286', 'multiple_choice', 'Як хорватською «поведінка (оцінка)»?', 'vladanje', '["sastavak", "vladanje", "druželjubiv", "informacije"]'::jsonb, 'A2', 5, 'PUBLISHED', 'vladanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '89bde032-93a5-5a00-b563-c663d94df7b8', 'multiple_choice', 'Як хорватською «заважати»?', 'ometati', '["neopravdan", "prilagoditi se", "opravdati", "ometati"]'::jsonb, 'A2', 6, 'PUBLISHED', 'ometati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bed9c186-de61-5624-899a-d8c52ff1afbe', 'type_answer', 'Напишіть хорватською: «сором’язливий»', 'sramežljiv', null, 'A2', 7, 'PUBLISHED', 'sramežljiv', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '60afcd21-ee8d-5eb3-ae37-cdc90caf058e', 'type_answer', 'Напишіть хорватською: «товариський»', 'druželjubiv', null, 'A2', 8, 'PUBLISHED', 'druželjubiv', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '307fa538-748f-5a22-9729-b1d9c5931cc5', 'type_answer', 'Напишіть хорватською: «підписати»', 'potpisati', null, 'A2', 9, 'PUBLISHED', 'potpisati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a6fafb18-7fbc-5cb9-9db3-ee13a76f115d', 'sentence_builder', 'Складіть: «Я задоволена його успіхами.»', 'Zadovoljna sam njegovim napretkom.', '["napretkom.", "njegovim", "Zadovoljna", "sam"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b3c9d48d-49d5-594a-8f55-8df283cbacf6', 'sentence_builder', 'Складіть: «Підпишіть згоду на екскурсію.»', 'Potpišite suglasnost za izlet.', '["za", "suglasnost", "izlet.", "Potpišite"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3884d8de-3d76-5c0c-8cd7-6ae6dac86804', 'listening', 'Прослухайте і складіть фразу', 'Petnaestog svibnja, idemo u Krapinu.', '["svibnja,", "u", "Petnaestog", "Krapinu.", "idemo"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'd1244397-5731-561b-b3b1-6aeea46c4398', 'listening_dialogue', 'Прослухайте розмову', 'у нього температура; довідку від лікаря; надіслати домашнє завдання', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Дар’я розмовляє з класним керівником по телефону.", "script": [{"speaker": "Razrednik", "hr": "Gospođo, Filip danas nije bio u školi.", "ua": "Пані, Філіпа сьогодні не було в школі."}, {"speaker": "Darja", "hr": "Znam, ima temperaturu. Ostat će kod kuće do petka.", "ua": "Знаю, у нього температура. Він залишиться вдома до п’ятниці."}, {"speaker": "Razrednik", "hr": "U redu. Kad se vrati, neka donese liječničku ispričnicu.", "ua": "Гаразд. Коли повернеться, хай принесе довідку від лікаря."}, {"speaker": "Darja", "hr": "Hoće. Možete li mi poslati zadaću e-mailom?", "ua": "Принесе. Можете надіслати мені домашнє завдання e-mailом?"}], "questions": [{"q_ua": "Чому Філіпа не було в школі?", "options": ["у нього температура", "вони їздили в Україну", "проспав"], "correct": 0, "answer_turn": 1}, {"q_ua": "Що треба принести після хвороби?", "options": ["записку від мами", "довідку від лікаря", "щоденник"], "correct": 1, "answer_turn": 2}, {"q_ua": "Про що просить Дар’я?", "options": ["про додаткові заняття", "про зустріч", "надіслати домашнє завдання"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'd1244397-5731-561b-b3b1-6aeea46c4398', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3baa39e4-5466-5f04-becc-a41ac226d310', 'speaking', 'Як у нього справи в школі?', 'Kako mu ide u školi?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '175869b7-4f4d-55ab-91a7-ef63b58aac06', 'speaking', 'Він хворів, у мене є довідка від лікаря.', 'Bio je bolestan, imam liječničku ispričnicu.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'c66094d1-f476-5cad-8b4d-04fc067e52e7', 'write_message', 'Напишіть класному керівнику записку: ваша донька вчора не була в школі, бо мала температуру; просите виправдати пропуск.', 'Poštovani, moja kći jučer nije bila u školi jer je imala temperaturu. Molim Vas da opravdate izostanak.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть класному керівнику записку: ваша донька вчора не була в школі, бо мала температуру; просите виправдати пропуск.", "points": [{"ua": "донька не була в школі", "keys": [["nije bil"], ["nije bila"]]}, {"ua": "мала температуру", "keys": [["temperatur"], ["bolesn"]]}, {"ua": "виправдати пропуск", "keys": [["opravda"]]}], "hints": ["moja kći jučer nije bila u školi", "imala je temperaturu", "molim da opravdate izostanak"], "models": ["Poštovani, moja kći jučer nije bila u školi jer je imala temperaturu. Molim Vas da opravdate izostanak."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'c66094d1-f476-5cad-8b4d-04fc067e52e7', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '26102497-87b7-5bad-83fc-a765587ff085', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Ima li njezina kći poteškoća s hrvatskim? Što možemo raditi kod kuće?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай учительку, чи моя донька має труднощі з хорватською і що нам робити вдома.", "direction": "ua_hr", "points": [{"ua": "труднощі", "keys": [["poteškoć"], ["problem"]]}, {"ua": "з хорватською", "keys": [["hrvatsk"]]}, {"ua": "що робити вдома", "keys": [["kod kuć"]]}], "hints": [], "models": ["Ima li njezina kći poteškoća s hrvatskim? Što možemo raditi kod kuće?"], "source_ua": "Спитай учительку, чи моя донька має труднощі з хорватською і що нам робити вдома."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '26102497-87b7-5bad-83fc-a765587ff085', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('06850f31-dc68-5110-ac28-0f86e98b1791', v_lesson, 'На консультації', 'Na informacijama', 5151, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('e0f86243-695a-57c5-938d-38e8718c3fa3', '06850f31-dc68-5110-ac28-0f86e98b1791', 'Darja', 'Dobar dan, ja sam Filipova mama. Kako mu ide?', 'Добрий день, я мама Філіпа. Як у нього справи?', 1);
  perform pg_temp.turn('23f2f409-8594-5f69-8a66-73bc44c31e1c', '06850f31-dc68-5110-ac28-0f86e98b1791', 'Učiteljica', 'Zadovoljna sam napretkom. Na početku je bio sramežljiv, a sad je druželjubiv.', 'Я задоволена його успіхами. Спочатку він був сором’язливий, а тепер товариський.', 2);
  perform pg_temp.turn('8ec3cd24-3c71-5061-80be-12271e227049', '06850f31-dc68-5110-ac28-0f86e98b1791', 'Darja', 'Drago mi je. Ima li poteškoća?', 'Мені приємно. Чи має він труднощі?', 3);
  perform pg_temp.turn('e5b2ba3d-3607-584d-83ad-551ca9dfdc39', '06850f31-dc68-5110-ac28-0f86e98b1791', 'Učiteljica', 'Malo s čitanjem. Neka svaki dan čita lektiru po deset minuta.', 'Трохи з читанням. Хай щодня читає книжку по десять хвилин.', 4);
  perform pg_temp.turn('d46a9169-0486-50b5-9c17-b077eabdea49', '06850f31-dc68-5110-ac28-0f86e98b1791', 'Darja', 'Hoćemo. Hvala što ste ga pohvalili za sastavak, bio je jako sretan.', 'Будемо. Дякую, що похвалили його за твір, він був дуже щасливий.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f17c113b-71a5-50a2-9b00-03d781e34eb2', v_lesson, 'Пропуски', 'Izostanci', 5152, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('87af931e-62a3-5d88-997f-04d5cff1e978', 'f17c113b-71a5-50a2-9b00-03d781e34eb2', 'Razrednik', 'Gospođo, Filip ima dva neopravdana izostanka.', 'Пані, у Філіпа два невиправдані пропуски.', 1);
  perform pg_temp.turn('c902d4d9-aae0-5365-9463-e10b4a59b646', 'f17c113b-71a5-50a2-9b00-03d781e34eb2', 'Darja', 'Bio je bolestan. Opravdat ću ih, imam liječničku ispričnicu.', 'Він хворів. Я їх виправдаю, у мене є довідка від лікаря.', 2);
  perform pg_temp.turn('0790d13a-b1f2-53da-aaae-48f6e42ba110', 'f17c113b-71a5-50a2-9b00-03d781e34eb2', 'Razrednik', 'Dobro, donesite je sutra. I potpišite suglasnost za izlet razreda.', 'Добре, принесіть її завтра. І підпишіть згоду на класну екскурсію.', 3);
  perform pg_temp.turn('e4e0e6a6-3d29-56dd-acfe-9e208cb42d57', 'f17c113b-71a5-50a2-9b00-03d781e34eb2', 'Darja', 'Kada je izlet?', 'Коли екскурсія?', 4);
  perform pg_temp.turn('8a8cf146-d498-5298-a8d2-c5be001e49f4', 'f17c113b-71a5-50a2-9b00-03d781e34eb2', 'Razrednik', 'Petnaestog svibnja, idemo u Krapinu.', 'П’ятнадцятого травня, їдемо в Крапину.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.2 · урок 16: Домашнє завдання, продовжений день і гуртки — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6b2a808e-df6e-5da3-bf7a-597668e47495';
  v_lesson constant uuid := 'f0e24e2b-9e73-5a70-8f2f-ec825b0308e2';
  v_gid constant uuid := '0c68352a-803a-5410-a59b-91f2c1ddc49f';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KOND'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 8) then
    raise exception 'A2.2: місце 8 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 16: Домашнє завдання, продовжений день і гуртки', 'Lekcija 16: Zadaća, cjelodnevni boravak i aktivnosti', '["Обрати гурток і продовжений день для дитини", "Пояснити мету й бажання: Volio bih da…, Upisali bismo ga da bi…"]'::jsonb, 20, 'PUBLISHED', 8);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'cjelodnevni boravak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izvannastavne aktivnosti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izvanškolske aktivnosti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zbor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dramska skupina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sportski klub', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glazbena škola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rukomet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vaterpolo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'članarina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'instrukcije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pomoć u učenju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'riješiti zadatak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'provjeriti zadaću', v_pos);
  v_pos := pg_temp.word(v_lesson, 'školska knjižnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'marenda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'školska kuhinja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'raspored aktivnosti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upisnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slobodno vrijeme djeteta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'školski projekt', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c88e76be-2024-5540-9745-338a5eb9a0de', 'fill_in_the_blank', 'Upisali bismo ga u zbor da ___ više pjevao.', 'bi', '["bi", "bismo", "biste", "bih"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '202747df-9e55-52de-b351-e921212275f9', 'multiple_choice', 'Що означає «izvannastavne aktivnosti»?', 'позакласні заняття (у школі)', '["шкільний проєкт", "позакласні заняття (у школі)", "позашкільні гуртки", "вільний час дитини"]'::jsonb, 'A2', 2, 'PUBLISHED', 'izvannastavne aktivnosti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a11b56f8-2d12-5419-9c23-3a6be435179a', 'multiple_choice', 'Що означає «provjeriti zadaću»?', 'перевірити домашнє завдання', '["шкільна їдальня (обіди)", "перевірити домашнє завдання", "бланк запису", "репетиторство"]'::jsonb, 'A2', 3, 'PUBLISHED', 'provjeriti zadaću', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4f43933d-41bd-530d-a7d4-d0323b5e270b', 'multiple_choice', 'Що означає «cjelodnevni boravak»?', 'група продовженого дня (на цілий день)', '["шкільна бібліотека", "вільний час дитини", "група продовженого дня (на цілий день)", "репетиторство"]'::jsonb, 'A2', 4, 'PUBLISHED', 'cjelodnevni boravak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3d8c6413-ccb0-58e0-a5bf-2c03840cf70f', 'multiple_choice', 'Як хорватською «водне поло»?', 'vaterpolo', '["vaterpolo", "sportski klub", "upisnica", "članarina"]'::jsonb, 'A2', 5, 'PUBLISHED', 'vaterpolo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3af4db66-4165-5270-bcbf-87ab953f6c39', 'multiple_choice', 'Як хорватською «хор»?', 'zbor', '["pomoć u učenju", "zbor", "glazbena škola", "marenda"]'::jsonb, 'A2', 6, 'PUBLISHED', 'zbor', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bd3c2881-3bf4-543b-9b3a-2acfdc2de3ba', 'type_answer', 'Напишіть хорватською: «спортивний клуб»', 'sportski klub', null, 'A2', 7, 'PUBLISHED', 'sportski klub', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0b6b3393-42a0-5e88-a0a8-e5326868a993', 'type_answer', 'Напишіть хорватською: «членський внесок»', 'članarina', null, 'A2', 8, 'PUBLISHED', 'članarina', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bb9f61af-7d16-5f54-8dd8-51df98f7e9d7', 'type_answer', 'Напишіть хорватською: «репетиторство»', 'instrukcije', null, 'A2', 9, 'PUBLISHED', 'instrukcije', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e3624811-4c35-5abf-b529-ab0cc2f83017', 'sentence_builder', 'Складіть: «Він ходить до репетитора з математики.»', 'Iz matematike ide na instrukcije.', '["na", "ide", "Iz", "matematike", "instrukcije."]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8c2f4ef3-a866-5bb2-937d-32b55b95aa16', 'sentence_builder', 'Складіть: «Заповніть бланк запису до хору.»', 'Ispunite upisnicu za zbor.', '["upisnicu", "zbor.", "za", "Ispunite"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa9b2557-c05a-5569-8479-12ff1803720b', 'listening', 'Прослухайте і складіть фразу', 'Na vratima učionice. Samo ispuniš upisnicu.', '["Samo", "upisnicu.", "ispuniš", "vratima", "Na", "učionice."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '7ac097fb-0513-5c8b-b862-d8179bb5f758', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'у середу о 17:00; кросівки й воду; безкоштовно', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Тренер спортивного клубу залишив вам повідомлення.", "script": [{"hr": "Dobar dan, ovdje trener iz rukometnog kluba Zamet.", "ua": "Добрий день, це тренер з гандбольного клубу «Замет»."}, {"hr": "Vaš sin može doći na probni trening u srijedu u pet.", "ua": "Ваш син може прийти на пробне тренування в середу о п’ятій."}, {"hr": "Neka ponese tenisice i bocu vode.", "ua": "Хай візьме кросівки й пляшку води."}, {"hr": "Prvi mjesec je besplatan, a onda je članarina dvadeset eura.", "ua": "Перший місяць безкоштовний, а потім внесок двадцять євро."}], "questions": [{"q_ua": "Коли пробне тренування?", "options": ["у середу о 17:00", "у понеділок о 15:00", "у суботу"], "correct": 0, "answer_turn": 1}, {"q_ua": "Що треба взяти?", "options": ["м’яч", "кросівки й воду", "форму клубу"], "correct": 1, "answer_turn": 2}, {"q_ua": "Скільки коштує перший місяць?", "options": ["20 євро", "10 євро", "безкоштовно"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '7ac097fb-0513-5c8b-b862-d8179bb5f758', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '683561c5-949f-52d9-8fa5-00615a1123b0', 'speaking', 'Чи може він залишатися в школі після уроків?', 'Može li ostati u školi poslije nastave?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4abdd2e8-bea0-5cd6-ad42-5c9a95af321e', 'speaking', 'Скільки коштує членський внесок?', 'Koliko iznosi članarina?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '3439c74c-3e22-523b-9ad9-d1318484a3d6', 'write_message', 'Напишіть тренеру: ваш син (10 років) хотів би грати в гандбол; спитайте про розклад тренувань і внесок.', 'Poštovani, moj sin ima deset godina i volio bi igrati rukomet. Kakav je raspored treninga i kolika je članarina?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть тренеру: ваш син (10 років) хотів би грати в гандбол; спитайте про розклад тренувань і внесок.", "points": [{"ua": "син 10 років", "keys": [["10"], ["deset"]]}, {"ua": "хотів би грати в гандбол", "keys": [["rukomet"]]}, {"ua": "розклад", "keys": [["raspored"], ["kad"]]}, {"ua": "внесок", "keys": [["članarin"]]}], "hints": ["moj sin ima deset godina", "volio bi igrati rukomet", "raspored treninga", "članarina"], "models": ["Poštovani, moj sin ima deset godina i volio bi igrati rukomet. Kakav je raspored treninga i kolika je članarina?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '3439c74c-3e22-523b-9ad9-d1318484a3d6', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'eb4ffa89-62f4-52d8-8496-538aaaf55a11', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Moja prijateljica radi do pet i htjela bi upisati kćer u cjelodnevni boravak.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи секретарці, що я працюю до п’ятої й хотіла б записати дочку на продовжений день.", "direction": "ua_hr", "points": [{"ua": "працюю до п’ятої", "keys": [["pet"]]}, {"ua": "продовжений день", "keys": [["boravak"]]}, {"ua": "дочка", "keys": [["kćer"], ["kći"]]}], "hints": [], "models": ["Moja prijateljica radi do pet i htjela bi upisati kćer u cjelodnevni boravak."], "source_ua": "Скажи секретарці, що я працюю до п’ятої й хотіла б записати дочку на продовжений день."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'eb4ffa89-62f4-52d8-8496-538aaaf55a11', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b2f1d008-6695-5461-bba0-4495732d5145', v_lesson, 'Продовжений день', 'Cjelodnevni boravak', 5161, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('ca45e1f8-ac18-521a-9c3a-e40721deaf3f', 'b2f1d008-6695-5461-bba0-4495732d5145', 'Darja', 'Radim do četiri. Može li Filip ostati u školi poslije nastave?', 'Я працюю до четвертої. Чи може Філіп залишатися в школі після уроків?', 1);
  perform pg_temp.turn('aded8e53-3b2c-59ce-a9a2-8e5a7d0cc5ce', 'b2f1d008-6695-5461-bba0-4495732d5145', 'Tajnica', 'Može, imamo cjelodnevni boravak do pet sati.', 'Може, у нас група продовженого дня до п’ятої.', 2);
  perform pg_temp.turn('4181d001-cae9-5ff0-8c15-37645641e6ab', 'b2f1d008-6695-5461-bba0-4495732d5145', 'Darja', 'Pišu li tamo zadaću?', 'Вони там роблять домашнє завдання?', 3);
  perform pg_temp.turn('82c85101-30c4-580e-94ae-2bf79385beb0', 'b2f1d008-6695-5461-bba0-4495732d5145', 'Tajnica', 'Pišu, učiteljica im provjeri zadaću. Ručak je u školskoj kuhinji.', 'Роблять, учителька перевіряє їм домашнє. Обід у шкільній їдальні.', 4);
  perform pg_temp.turn('736e6bbc-394b-55b0-85ca-4b755baa1e8f', 'b2f1d008-6695-5461-bba0-4495732d5145', 'Darja', 'Super. Upisali bismo ga da bi bolje naučio hrvatski.', 'Супер. Ми б записали його, щоб він краще вивчив хорватську.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('32fbae58-4fa2-52ed-ab9c-e3045f0b36fe', v_lesson, 'Який гурток?', 'Koja aktivnost?', 5162, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('996e103e-06b2-5ded-a56d-76adc5f3c529', '32fbae58-4fa2-52ed-ab9c-e3045f0b36fe', 'Daša', 'Darja, hoće li Filip ići na neku aktivnost?', 'Дар’є, Філіп ходитиме на якийсь гурток?', 1);
  perform pg_temp.turn('420d8fa7-75e6-52e4-a5c7-206470b1e69e', '32fbae58-4fa2-52ed-ab9c-e3045f0b36fe', 'Darja', 'Volio bi igrati vaterpolo, ali članarina je skupa.', 'Він хотів би грати у водне поло, але внесок дорогий.', 2);
  perform pg_temp.turn('11e79f07-80e6-5f57-8bac-5ff76508d4f1', '32fbae58-4fa2-52ed-ab9c-e3045f0b36fe', 'Daša', 'U školi ima besplatnih izvannastavnih aktivnosti. Moj sin je u dramskoj skupini.', 'У школі є безкоштовні позакласні заняття. Мій син у драматичному гуртку.', 3);
  perform pg_temp.turn('cda12036-f9f8-5a43-964b-c1034e11cf09', '32fbae58-4fa2-52ed-ab9c-e3045f0b36fe', 'Darja', 'Gdje je raspored aktivnosti?', 'Де розклад гуртків?', 4);
  perform pg_temp.turn('60e4fcac-23ab-5acf-b60b-6def9d46d49d', '32fbae58-4fa2-52ed-ab9c-e3045f0b36fe', 'Daša', 'Na vratima učionice. Samo ispuniš upisnicu.', 'На дверях класу. Просто заповнюєш бланк запису.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- 3. Модуль і юніт — опубліковані
update public.modules set status = 'PUBLISHED', title_ua = 'Модуль A2.2 — Навчання: курси, університет, школа', title_hr = 'Modul A2.2 — Obrazovanje: tečajevi, fakultet, škola' where id = '0b2b8e34-d7e7-5200-a5ee-584af028ed75';
update public.units set status = 'PUBLISHED' where id = '6b2a808e-df6e-5da3-bf7a-597668e47495';

-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('8190831a-549a-544a-962b-4f716a895a32', 'aad2c656-7750-545f-88be-b36c1cdb3b79', 'dd6c5f39-f66e-5acb-8255-932f822ddcc5', '4be96321-cd99-57ff-a9bc-17cfaf4f4c29', '24894494-1af7-5153-a7b0-7f0ef3c0bdce', '2a1b2b63-def1-5fb9-91e6-d09e1fd5b95c', 'e32cdbd5-0e59-53c7-8773-bf31e69068a2', 'f0e24e2b-9e73-5a70-8f2f-ec825b0308e2')
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
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 20 or l.unit_id <> '6b2a808e-df6e-5da3-bf7a-597668e47495');
  select count(*) into v_titles from (values ('8190831a-549a-544a-962b-4f716a895a32'::uuid, 'Урок 9:%', 1), ('aad2c656-7750-545f-88be-b36c1cdb3b79'::uuid, 'Урок 10:%', 2), ('dd6c5f39-f66e-5acb-8255-932f822ddcc5'::uuid, 'Урок 11:%', 3), ('4be96321-cd99-57ff-a9bc-17cfaf4f4c29'::uuid, 'Урок 12:%', 4), ('24894494-1af7-5153-a7b0-7f0ef3c0bdce'::uuid, 'Урок 13:%', 5), ('2a1b2b63-def1-5fb9-91e6-d09e1fd5b95c'::uuid, 'Урок 14:%', 6), ('e32cdbd5-0e59-53c7-8773-bf31e69068a2'::uuid, 'Урок 15:%', 7), ('f0e24e2b-9e73-5a70-8f2f-ec825b0308e2'::uuid, 'Урок 16:%', 8)) as t(id, pat, o)
    left join public.lessons l on l.id = t.id and l.title_ua like t.pat and l.order_index = t.o
   where l.id is null;
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
      where l.level_code = 'A2' and l.status = 'PUBLISHED' and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A2.2: % уроків з неправильним складом', v_bad; end if;
  if v_titles > 0 then raise exception 'Модуль A2.2: % уроків не на своєму місці чи з неправильним номером', v_titles; end if;
  if v_words > 0 then raise exception 'A2: % слів повторюються в кількох уроках', v_words; end if;
  if (select status from public.modules where id = '0b2b8e34-d7e7-5200-a5ee-584af028ed75') <> 'PUBLISHED' then raise exception 'Модуль A2.2 не опубліковано'; end if;
  raise notice 'Готово: модуль A2.2 — 8 уроків, слів 170';
end $$;

commit;
