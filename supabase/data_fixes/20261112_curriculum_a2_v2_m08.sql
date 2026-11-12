-- =====================================================================
-- Програма A2 v2 · модуль A2.8 «Авто в Хорватії» · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2.py 8 (не редагуйте вручну).
--
-- Рішення власника 2026-11-12: 20–25 нових слів на урок, 90–95 % слів — нові для рівня, діалоги під тему,
-- частіше Даша / Дар’я; «Прослухайте діалог чи оголошення» в кожному уроці; бета (PUBLISHED).
--   * Уроки 48–53 (6): слів у них 129. Кожен: 20–25 слів, 2 діалоги, 15 вправ
--     (одна — «Прослухайте діалог чи оголошення»), «Напишіть повідомлення» і «Перекажіть другу» (ua → hr, необов’язкові), 20 хв.
--   * Слова: 129 (нові — PUBLISHED; ті, що вже є в словнику, не змінюються).
--   * Модуль і юніт A2.8 → PUBLISHED. Потрібен уже запущений 20261112_curriculum_a2_v2_00_structure.sql.
--   * Нічого не видаляє. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.units where id = 'fb308628-6f9f-58c7-86bf-91bc5e469555') then
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

-- 1. Слова уроків A2.8 (129): нові — PUBLISHED (бета); наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A2', t.ua, t.vtype, t.forms, t.examples, 'PUBLISHED', 'claude_curriculum_a2_v2'
  from jsonb_to_recordset('[{"lemma": "zamjena vozačke dozvole", "normalized": "zamjena vozacke dozvole", "pos": "phrase", "ua": "обмін посвідчення водія", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Zamjena vozačke dozvole radi se u policijskoj upravi."]}, {"lemma": "strana vozačka dozvola", "normalized": "strana vozacka dozvola", "pos": "phrase", "ua": "іноземне посвідчення водія", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Sa stranom vozačkom dozvolom možete voziti godinu dana."]}, {"lemma": "policijska uprava", "normalized": "policijska uprava", "pos": "phrase", "ua": "поліцейське управління", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Zahtjev se predaje u policijskoj upravi."]}, {"lemma": "liječničko uvjerenje", "normalized": "lijecnicko uvjerenje", "pos": "phrase", "ua": "медична довідка", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Za vozačku treba liječničko uvjerenje."]}, {"lemma": "medicina rada", "normalized": "medicina rada", "pos": "phrase", "ua": "медицина праці (огляд водіїв)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Liječnički pregled za vozače radi se u medicini rada."]}, {"lemma": "vozački ispit", "normalized": "vozacki ispit", "pos": "phrase", "ua": "іспит на водійські права", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ne morate polagati vozački ispit."]}, {"lemma": "autoškola", "normalized": "autoskola", "pos": "noun", "ua": "автошкола", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Brat se upisao u autoškolu."]}, {"lemma": "kategorija", "normalized": "kategorija", "pos": "noun", "ua": "категорія", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Imam vozačku za kategoriju B."]}, {"lemma": "važiti", "normalized": "vaziti", "pos": "verb", "ua": "бути чинним", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Moja dozvola važi do dvije tisuće tridesete."]}, {"lemma": "istek valjanosti", "normalized": "istek valjanosti", "pos": "phrase", "ua": "закінчення строку дії", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Pazite na istek valjanosti dozvole."]}, {"lemma": "fotografija za dokumente", "normalized": "fotografija za dokumente", "pos": "phrase", "ua": "фото на документи", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Fotografija za dokumente se radi na licu mjesta."]}, {"lemma": "proći", "normalized": "proci", "pos": "verb", "ua": "пройти, проїхати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "prolaziti"}, "examples": ["Prošla sam liječnički pregled bez problema."]}, {"lemma": "doći na red", "normalized": "doci na red", "pos": "phrase", "ua": "дійти черги", "vtype": "chunk", "forms": {}, "examples": ["Čekala sam sat vremena dok nisam došla na red."]}, {"lemma": "otići po", "normalized": "otici po", "pos": "phrase", "ua": "піти по (щось)", "vtype": "chunk", "forms": {}, "examples": ["Sutra idem po novu dozvolu."]}, {"lemma": "podići dokument", "normalized": "podici dokument", "pos": "phrase", "ua": "забрати документ", "vtype": "chunk", "forms": {}, "examples": ["Novu dozvolu možete podići za tri tjedna."]}, {"lemma": "privremena potvrda", "normalized": "privremena potvrda", "pos": "phrase", "ua": "тимчасова довідка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Do tada vozite s privremenom potvrdom."]}, {"lemma": "vozački staž", "normalized": "vozacki staz", "pos": "phrase", "ua": "водійський стаж", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Imam deset godina vozačkog staža."]}, {"lemma": "vozač početnik", "normalized": "vozac pocetnik", "pos": "phrase", "ua": "водій-початківець", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Vozač početnik ne smije piti ni malo alkohola."]}, {"lemma": "prijevod dozvole", "normalized": "prijevod dozvole", "pos": "phrase", "ua": "переклад посвідчення", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Treba li ovjereni prijevod dozvole?"]}, {"lemma": "naplaćuje se", "normalized": "naplacuje se", "pos": "phrase", "ua": "стягується (плата)", "vtype": "chunk", "forms": {}, "examples": ["Za novu dozvolu naplaćuje se pristojba."]}, {"lemma": "izaći iz zgrade", "normalized": "izaci iz zgrade", "pos": "phrase", "ua": "вийти з будівлі", "vtype": "chunk", "forms": {}, "examples": ["Izašla sam iz zgrade s privremenom potvrdom."]}, {"lemma": "ući u sustav", "normalized": "uci u sustav", "pos": "phrase", "ua": "увійти в систему", "vtype": "chunk", "forms": {}, "examples": ["Vaši podaci moraju ući u sustav."]}, {"lemma": "registracija vozila", "normalized": "registracija vozila", "pos": "phrase", "ua": "реєстрація транспортного засобу", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Registracija vozila traje godinu dana."]}, {"lemma": "registrirati auto", "normalized": "registrirati auto", "pos": "phrase", "ua": "зареєструвати авто", "vtype": "chunk", "forms": {}, "examples": ["Auto moram registrirati do kraja mjeseca."]}, {"lemma": "stanica za tehnički pregled", "normalized": "stanica za tehnicki pregled", "pos": "phrase", "ua": "станція техогляду", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Stanica za tehnički pregled je kod zaobilaznice."]}, {"lemma": "prometna dozvola", "normalized": "prometna dozvola", "pos": "phrase", "ua": "свідоцтво про реєстрацію (техпаспорт)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Prometna dozvola mora biti u autu."]}, {"lemma": "registarske pločice", "normalized": "registarske plocice", "pos": "phrase", "ua": "номерні знаки", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Dobili smo nove registarske pločice."]}, {"lemma": "naljepnica", "normalized": "naljepnica", "pos": "noun", "ua": "наліпка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Naljepnica za registraciju ide na staklo."]}, {"lemma": "ispravnost vozila", "normalized": "ispravnost vozila", "pos": "phrase", "ua": "справність авто", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na pregledu se provjerava ispravnost vozila."]}, {"lemma": "kočnice", "normalized": "kocnice", "pos": "noun", "ua": "гальма", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Kočnice su istrošene."]}, {"lemma": "ispušni plinovi", "normalized": "ispusni plinovi", "pos": "phrase", "ua": "вихлопні гази", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Auto nije prošao zbog ispušnih plinova."]}, {"lemma": "istrošen", "normalized": "istrosen", "pos": "adjective", "ua": "зношений", "vtype": "core", "forms": {}, "examples": ["Gume su istrošene, treba ih zamijeniti."]}, {"lemma": "nije prošao", "normalized": "nije prosao", "pos": "phrase", "ua": "не пройшов (огляд)", "vtype": "chunk", "forms": {}, "examples": ["Auto nije prošao tehnički pregled."]}, {"lemma": "ponovni pregled", "normalized": "ponovni pregled", "pos": "phrase", "ua": "повторний огляд", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ponovni pregled je besplatan u roku od petnaest dana."]}, {"lemma": "obvezno osiguranje od automobilske odgovornosti", "normalized": "obvezno osiguranje od automobilske odgovornosti", "pos": "phrase", "ua": "обов’язкове страхування цивільної відповідальності (авто)", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Uz registraciju plaćate obvezno osiguranje od automobilske odgovornosti."]}, {"lemma": "vlasnik vozila", "normalized": "vlasnik vozila", "pos": "phrase", "ua": "власник авто", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Vlasnik vozila mora potpisati zahtjev."]}, {"lemma": "ući na liniju", "normalized": "uci na liniju", "pos": "phrase", "ua": "заїхати на лінію (огляду)", "vtype": "chunk", "forms": {}, "examples": ["Uđite na liniju broj dva."]}, {"lemma": "izaći iz vozila", "normalized": "izaci iz vozila", "pos": "phrase", "ua": "вийти з авто", "vtype": "chunk", "forms": {}, "examples": ["Molim Vas, izađite iz vozila."]}, {"lemma": "prijeći na", "normalized": "prijeci na", "pos": "phrase", "ua": "перейти на (до)", "vtype": "chunk", "forms": {}, "examples": ["Prijeđite na blagajnu za plaćanje."]}, {"lemma": "ugasiti motor", "normalized": "ugasiti motor", "pos": "phrase", "ua": "заглушити двигун", "vtype": "chunk", "forms": {}, "examples": ["Ugasite motor i otvorite haubu."]}, {"lemma": "hauba", "normalized": "hauba", "pos": "noun", "ua": "капот", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Otvorite haubu, molim."]}, {"lemma": "prtljažnik", "normalized": "prtljaznik", "pos": "noun", "ua": "багажник", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Prva pomoć je u prtljažniku."]}, {"lemma": "kutija prve pomoći", "normalized": "kutija prve pomoci", "pos": "phrase", "ua": "аптечка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Kutija prve pomoći je obvezna."]}, {"lemma": "europsko izvješće", "normalized": "europsko izvjesce", "pos": "phrase", "ua": "європротокол", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Ispunili smo europsko izvješće na licu mjesta."]}, {"lemma": "sudariti se", "normalized": "sudariti se", "pos": "verb", "ua": "зіткнутися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "sudarati se"}, "examples": ["Sudarili smo se na raskrižju."]}, {"lemma": "naletjeti", "normalized": "naletjeti", "pos": "verb", "ua": "наїхати, налетіти", "vtype": "core", "forms": {"aspect": "pfv", "pair": "nalijetati"}, "examples": ["Naletio je na mene straga."]}, {"lemma": "udariti straga", "normalized": "udariti straga", "pos": "phrase", "ua": "вдарити ззаду", "vtype": "chunk", "forms": {}, "examples": ["Auto me udario straga na semaforu."]}, {"lemma": "oduzeti prednost", "normalized": "oduzeti prednost", "pos": "phrase", "ua": "не надати переваги (порушити пріоритет)", "vtype": "chunk", "forms": {}, "examples": ["Oduzeo mi je prednost na raskrižju."]}, {"lemma": "prometna traka", "normalized": "prometna traka", "pos": "phrase", "ua": "смуга руху", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Prešao je u moju prometnu traku."]}, {"lemma": "skrenuti", "normalized": "skrenuti", "pos": "verb", "ua": "повернути", "vtype": "core", "forms": {"aspect": "pfv", "pair": "skretati"}, "examples": ["Skrenuo je lijevo bez žmigavca."]}, {"lemma": "žmigavac", "normalized": "zmigavac", "pos": "noun", "ua": "покажчик повороту", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Nije uključio žmigavac."]}, {"lemma": "zavoj", "normalized": "zavoj", "pos": "noun", "ua": "поворот (дороги)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Izletio je iz zavoja."]}, {"lemma": "ogrebotina na branik", "normalized": "ogrebotina na branik", "pos": "phrase", "ua": "подряпина на бампері", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na branik je samo ogrebotina."]}, {"lemma": "branik", "normalized": "branik", "pos": "noun", "ua": "бампер", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Stražnji branik je udubljen."]}, {"lemma": "udubljen", "normalized": "udubljen", "pos": "adjective", "ua": "вм’ятий", "vtype": "core", "forms": {}, "examples": ["Vrata su udubljena."]}, {"lemma": "materijalna šteta", "normalized": "materijalna steta", "pos": "phrase", "ua": "матеріальна шкода", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Ima samo materijalne štete, nitko nije ozlijeđen."]}, {"lemma": "reflektirajući prsluk", "normalized": "reflektirajuci prsluk", "pos": "phrase", "ua": "світловідбивний жилет", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Obucite reflektirajući prsluk prije izlaska."]}, {"lemma": "sigurnosni trokut", "normalized": "sigurnosni trokut", "pos": "phrase", "ua": "знак аварійної зупинки", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Postavite sigurnosni trokut iza auta."]}, {"lemma": "pozvati policiju", "normalized": "pozvati policiju", "pos": "phrase", "ua": "викликати поліцію", "vtype": "chunk", "forms": {}, "examples": ["Ako se ne slažete, pozovite policiju."]}, {"lemma": "vučna služba", "normalized": "vucna sluzba", "pos": "phrase", "ua": "евакуатор (служба)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Vučna služba je odvezla auto u servis."]}, {"lemma": "na licu mjesta", "normalized": "na licu mjesta", "pos": "phrase", "ua": "на місці (події)", "vtype": "chunk", "forms": {}, "examples": ["Policija je izašla na lice mjesta."]}, {"lemma": "krivac", "normalized": "krivac", "pos": "noun", "ua": "винуватець", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Krivac je drugi vozač."]}, {"lemma": "izjava svjedoka", "normalized": "izjava svjedoka", "pos": "phrase", "ua": "показання свідка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Trebamo izjavu svjedoka."]}, {"lemma": "fotografirati štetu", "normalized": "fotografirati stetu", "pos": "phrase", "ua": "сфотографувати пошкодження", "vtype": "chunk", "forms": {}, "examples": ["Fotografirajte štetu i oba auta."]}, {"lemma": "pregaziti", "normalized": "pregaziti", "pos": "verb", "ua": "переїхати (когось), наїхати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "pregaziti"}, "examples": ["Umalo je pregazio pješaka."]}, {"lemma": "radar", "normalized": "radar", "pos": "noun", "ua": "радар", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Na izlazu iz grada je radar."]}, {"lemma": "prekršaj", "normalized": "prekrsaj", "pos": "noun", "ua": "правопорушення", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Prolazak kroz crveno je težak prekršaj."]}, {"lemma": "prekoračiti brzinu", "normalized": "prekoraciti brzinu", "pos": "phrase", "ua": "перевищити швидкість", "vtype": "chunk", "forms": {}, "examples": ["Prekoračio sam brzinu za dvadeset kilometara."]}, {"lemma": "prometna kazna", "normalized": "prometna kazna", "pos": "phrase", "ua": "штраф за порушення ПДР", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Prometna kazna stigla je poštom."]}, {"lemma": "platiti na licu mjesta", "normalized": "platiti na licu mjesta", "pos": "phrase", "ua": "заплатити на місці", "vtype": "chunk", "forms": {}, "examples": ["Kaznu možete platiti na licu mjesta upola manje."]}, {"lemma": "upola manje", "normalized": "upola manje", "pos": "phrase", "ua": "удвічі менше", "vtype": "chunk", "forms": {}, "examples": ["Ako platite odmah, plaćate upola manje."]}, {"lemma": "kazneni bodovi", "normalized": "kazneni bodovi", "pos": "phrase", "ua": "штрафні бали", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Dobio je dva kaznena boda."]}, {"lemma": "proći kroz crveno", "normalized": "proci kroz crveno", "pos": "phrase", "ua": "проїхати на червоне", "vtype": "chunk", "forms": {}, "examples": ["Prošao je kroz crveno i udario pješaka."]}, {"lemma": "parkirna zona", "normalized": "parkirna zona", "pos": "phrase", "ua": "паркувальна зона", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U prvoj parkirnoj zoni možete stajati sat vremena."]}, {"lemma": "parkirni automat", "normalized": "parkirni automat", "pos": "phrase", "ua": "паркомат", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Parkirni automat ne prima kartice."]}, {"lemma": "platiti parking SMS-om", "normalized": "platiti parking sms-om", "pos": "phrase", "ua": "оплатити паркування SMS-кою", "vtype": "chunk", "forms": {}, "examples": ["Parking možete platiti SMS-om."]}, {"lemma": "parkirna karta", "normalized": "parkirna karta", "pos": "phrase", "ua": "паркувальний квиток", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Parkirnu kartu stavite iza stakla."]}, {"lemma": "nepropisno parkiran", "normalized": "nepropisno parkiran", "pos": "phrase", "ua": "неправильно припаркований", "vtype": "chunk", "forms": {}, "examples": ["Auto je bio nepropisno parkiran."]}, {"lemma": "mjesto za invalide", "normalized": "mjesto za invalide", "pos": "phrase", "ua": "місце для людей з інвалідністю", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Ne smijete parkirati na mjestu za invalide."]}, {"lemma": "odvesti auto", "normalized": "odvesti auto", "pos": "phrase", "ua": "відвезти (евакуювати) авто", "vtype": "chunk", "forms": {}, "examples": ["Pauk je odvezao auto jer je stajao na pločniku."]}, {"lemma": "pločnik", "normalized": "plocnik", "pos": "noun", "ua": "тротуар", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ne parkirajte na pločniku."]}, {"lemma": "prometni redar", "normalized": "prometni redar", "pos": "phrase", "ua": "інспектор з паркування", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Prometni redar je stavio kaznu na staklo."]}, {"lemma": "žuta crta", "normalized": "zuta crta", "pos": "phrase", "ua": "жовта лінія", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na žutoj crti je zabranjeno parkiranje."]}, {"lemma": "zona smirenog prometa", "normalized": "zona smirenog prometa", "pos": "phrase", "ua": "зона заспокоєного руху", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U zoni smirenog prometa vozi se trideset."]}, {"lemma": "ući u zonu", "normalized": "uci u zonu", "pos": "phrase", "ua": "заїхати в зону", "vtype": "chunk", "forms": {}, "examples": ["Ušli ste u pješačku zonu bez dozvole."]}, {"lemma": "žaliti se na kaznu", "normalized": "zaliti se na kaznu", "pos": "phrase", "ua": "оскаржити штраф", "vtype": "chunk", "forms": {}, "examples": ["Na kaznu se možete žaliti u roku od osam dana."]}, {"lemma": "naplata cestarine", "normalized": "naplata cestarine", "pos": "phrase", "ua": "оплата за проїзд (платна дорога)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Naplata cestarine je na izlazu s autoceste."]}, {"lemma": "elektronička naplata", "normalized": "elektronicka naplata", "pos": "phrase", "ua": "електронна оплата проїзду", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za elektroničku naplatu trebate uređaj ENC."]}, {"lemma": "brza cesta", "normalized": "brza cesta", "pos": "phrase", "ua": "швидкісна дорога", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Do Zadra možete i brzom cestom."]}, {"lemma": "tunel", "normalized": "tunel", "pos": "noun", "ua": "тунель", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Kroz tunel Sveti Rok vozi se polako."]}, {"lemma": "vijadukt", "normalized": "vijadukt", "pos": "noun", "ua": "віадук", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Na vijaduktu puše jak vjetar."]}, {"lemma": "zimska oprema", "normalized": "zimska oprema", "pos": "phrase", "ua": "зимове спорядження", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Zimska oprema obvezna je od studenog do travnja."]}, {"lemma": "lanci za snijeg", "normalized": "lanci za snijeg", "pos": "phrase", "ua": "ланцюги на колеса", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["U Lici ponekad trebaju lanci za snijeg."]}, {"lemma": "poledica", "normalized": "poledica", "pos": "noun", "ua": "ожеледиця", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Na cesti je poledica, vozite oprezno."]}, {"lemma": "stanje na cestama", "normalized": "stanje na cestama", "pos": "phrase", "ua": "стан доріг", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Prije puta provjerite stanje na cestama."]}, {"lemma": "zatvoren za promet", "normalized": "zatvoren za promet", "pos": "phrase", "ua": "закритий для руху", "vtype": "chunk", "forms": {}, "examples": ["Zbog bure je most zatvoren za promet."]}, {"lemma": "zaobići", "normalized": "zaobici", "pos": "verb", "ua": "об’їхати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "zaobilaziti"}, "examples": ["Možemo zaobići gužvu starom cestom."]}, {"lemma": "sići s autoceste", "normalized": "sici s autoceste", "pos": "phrase", "ua": "з’їхати з автостради", "vtype": "chunk", "forms": {}, "examples": ["Siđite s autoceste kod Karlovca."]}, {"lemma": "izlaz", "normalized": "izlaz", "pos": "noun", "ua": "з’їзд, виїзд", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Na sljedećem izlazu skrenite desno."]}, {"lemma": "vozilo s prikolicom", "normalized": "vozilo s prikolicom", "pos": "phrase", "ua": "авто з причепом", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Vozila s prikolicom plaćaju višu cestarinu."]}, {"lemma": "vinjeta", "normalized": "vinjeta", "pos": "noun", "ua": "віньєтка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Za Sloveniju trebaš vinjetu."]}, {"lemma": "granični prijelaz", "normalized": "granicni prijelaz", "pos": "phrase", "ua": "пункт пропуску на кордоні", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Na graničnom prijelazu se čeka sat vremena."]}, {"lemma": "napuniti spremnik", "normalized": "napuniti spremnik", "pos": "phrase", "ua": "заправити повний бак", "vtype": "chunk", "forms": {}, "examples": ["Napunimo spremnik prije Like."]}, {"lemma": "voziti oprezno", "normalized": "voziti oprezno", "pos": "phrase", "ua": "їхати обережно", "vtype": "chunk", "forms": {}, "examples": ["Kad pada snijeg, vozite oprezno."]}, {"lemma": "prometne informacije", "normalized": "prometne informacije", "pos": "phrase", "ua": "дорожня інформація", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Na radiju slušamo prometne informacije."]}, {"lemma": "kolona vozila", "normalized": "kolona vozila", "pos": "phrase", "ua": "колона автомобілів", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Kolona vozila je duga deset kilometara."]}, {"lemma": "zaobilaznica", "normalized": "zaobilaznica", "pos": "noun", "ua": "об’їзна дорога", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Zaobilaznica oko Zadra je nova."]}, {"lemma": "rabljeni auto", "normalized": "rabljeni auto", "pos": "phrase", "ua": "вживане авто", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Tražimo rabljeni auto do pet tisuća eura."]}, {"lemma": "oglas za auto", "normalized": "oglas za auto", "pos": "phrase", "ua": "оголошення про продаж авто", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Našla sam oglas za auto na internetu."]}, {"lemma": "prijeđeni kilometri", "normalized": "prijedeni kilometri", "pos": "phrase", "ua": "пробіг (пройдені кілометри)", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Ima sto pedeset tisuća prijeđenih kilometara."]}, {"lemma": "servisna knjižica", "normalized": "servisna knjizica", "pos": "phrase", "ua": "сервісна книжка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Imate li servisnu knjižicu?"]}, {"lemma": "prvi vlasnik", "normalized": "prvi vlasnik", "pos": "phrase", "ua": "перший власник", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Prodaje ga prvi vlasnik."]}, {"lemma": "probna vožnja", "normalized": "probna voznja", "pos": "phrase", "ua": "тест-драйв", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Mogu li ići na probnu vožnju?"]}, {"lemma": "provozati se", "normalized": "provozati se", "pos": "verb", "ua": "проїхатися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "provoziti se"}, "examples": ["Provozajmo se do kraja ulice."]}, {"lemma": "kupoprodajni ugovor za vozilo", "normalized": "kupoprodajni ugovor za vozilo", "pos": "phrase", "ua": "договір купівлі-продажу авто", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Potpisali smo kupoprodajni ugovor za vozilo."]}, {"lemma": "prijenos vlasništva", "normalized": "prijenos vlasnistva", "pos": "phrase", "ua": "переоформлення власності", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Prijenos vlasništva radi se na tehničkom pregledu."]}, {"lemma": "porez na promet vozila", "normalized": "porez na promet vozila", "pos": "phrase", "ua": "податок на купівлю вживаного авто", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Kupac plaća porez na promet vozila."]}, {"lemma": "fiksna cijena", "normalized": "fiksna cijena", "pos": "phrase", "ua": "фіксована ціна", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Cijena nije fiksna, možemo razgovarati."]}, {"lemma": "spustiti cijenu", "normalized": "spustiti cijenu", "pos": "phrase", "ua": "знизити ціну", "vtype": "chunk", "forms": {}, "examples": ["Možete li spustiti cijenu za tristo eura?"]}, {"lemma": "benzinac", "normalized": "benzinac", "pos": "noun", "ua": "бензинове авто", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Benzinac je bolji za grad."]}, {"lemma": "hrđa", "normalized": "hrda", "pos": "noun", "ua": "іржа", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ispod vrata ima malo hrđe."]}, {"lemma": "udaren", "normalized": "udaren", "pos": "adjective", "ua": "битий (після аварії)", "vtype": "core", "forms": {}, "examples": ["Je li auto ikad bio udaren?"]}, {"lemma": "sajam automobila", "normalized": "sajam automobila", "pos": "phrase", "ua": "авторинок", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["U nedjelju idemo na sajam automobila."]}, {"lemma": "dovesti na pregled", "normalized": "dovesti na pregled", "pos": "phrase", "ua": "пригнати на огляд", "vtype": "chunk", "forms": {}, "examples": ["Dovest ću auto na pregled kod mehaničara."]}, {"lemma": "mehaničar", "normalized": "mehanicar", "pos": "noun", "ua": "механік", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Moj mehaničar će pogledati motor."]}, {"lemma": "godina proizvodnje", "normalized": "godina proizvodnje", "pos": "phrase", "ua": "рік виробництва", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Godina proizvodnje je dvije tisuće šesnaesta."]}, {"lemma": "pogađati se", "normalized": "pogadati se", "pos": "verb", "ua": "торгуватися", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Na sajmu se svi pogađaju oko cijene."]}, {"lemma": "potrošnja goriva", "normalized": "potrosnja goriva", "pos": "phrase", "ua": "витрата пального", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Potrošnja goriva je šest litara na sto."]}, {"lemma": "registriran do", "normalized": "registriran do", "pos": "phrase", "ua": "зареєстрований до", "vtype": "chunk", "forms": {}, "examples": ["Auto je registriran do svibnja."]}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 2. Уроки модуля A2.8
-- A2.8 · урок 48: Обмін посвідчення водія — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'fb308628-6f9f-58c7-86bf-91bc5e469555';
  v_lesson constant uuid := 'd4af6240-036d-5046-9c4a-430b34a04c79';
  v_gid constant uuid := '3a13fbe7-c0e4-55f8-b938-5579165e11bf';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KRET'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A2.8: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 48: Обмін посвідчення водія', 'Lekcija 48: Zamjena vozačke dozvole', '["Дізнатися, як обміняти українське посвідчення водія в Хорватії", "Дієслова руху: doći na šalter, otići po potvrdu, proći pregled"]'::jsonb, 20, 'PUBLISHED', 1);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zamjena vozačke dozvole', v_pos);
  v_pos := pg_temp.word(v_lesson, 'strana vozačka dozvola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'policijska uprava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'liječničko uvjerenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'medicina rada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vozački ispit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'autoškola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kategorija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'važiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'istek valjanosti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fotografija za dokumente', v_pos);
  v_pos := pg_temp.word(v_lesson, 'proći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'doći na red', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otići po', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podići dokument', v_pos);
  v_pos := pg_temp.word(v_lesson, 'privremena potvrda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vozački staž', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vozač početnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijevod dozvole', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naplaćuje se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izaći iz zgrade', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ući u sustav', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a1ca7997-64da-500f-93a5-cf84d20f414c', 'fill_in_the_blank', 'Sutra ću ___ po novu vozačku dozvolu.', 'otići', '["izaći", "ući", "prijeći", "otići"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae907299-a704-53c6-8a12-17dbca5b20b7', 'multiple_choice', 'Що означає «liječničko uvjerenje»?', 'медична довідка', '["водійський стаж", "медична довідка", "вийти з будівлі", "медицина праці (огляд водіїв)"]'::jsonb, 'A2', 2, 'PUBLISHED', 'liječničko uvjerenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '66506085-34b0-5a79-8637-17c98dc1d6e9', 'multiple_choice', 'Що означає «medicina rada»?', 'медицина праці (огляд водіїв)', '["фото на документи", "медицина праці (огляд водіїв)", "стягується (плата)", "пройти, проїхати"]'::jsonb, 'A2', 3, 'PUBLISHED', 'medicina rada', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '64ce9136-efd0-57d5-83ae-232fbb5802e4', 'multiple_choice', 'Що означає «otići po»?', 'піти по (щось)', '["автошкола", "водійський стаж", "піти по (щось)", "водій-початківець"]'::jsonb, 'A2', 4, 'PUBLISHED', 'otići po', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '84c068e6-5d70-57ac-9f49-6fbaa26f87cc', 'multiple_choice', 'Що означає «fotografija za dokumente»?', 'фото на документи', '["медицина праці (огляд водіїв)", "дійти черги", "поліцейське управління", "фото на документи"]'::jsonb, 'A2', 5, 'PUBLISHED', 'fotografija za dokumente', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bc9e0b22-4d69-59a1-8daa-4f18223108ac', 'multiple_choice', 'Як хорватською «дійти черги»?', 'doći na red', '["autoškola", "medicina rada", "doći na red", "policijska uprava"]'::jsonb, 'A2', 6, 'PUBLISHED', 'doći na red', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8a299179-fe9e-5cbc-8230-19371a9a32f7', 'multiple_choice', 'Як хорватською «категорія»?', 'kategorija', '["istek valjanosti", "kategorija", "policijska uprava", "liječničko uvjerenje"]'::jsonb, 'A2', 7, 'PUBLISHED', 'kategorija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '563aac0c-6e82-5525-94c7-4ae56ee70148', 'type_answer', 'Напишіть хорватською: «стягується (плата)»', 'naplaćuje se', null, 'A2', 8, 'PUBLISHED', 'naplaćuje se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '93091b09-e43b-5498-8797-73e2ec149215', 'type_answer', 'Напишіть хорватською: «автошкола»', 'autoškola', null, 'A2', 9, 'PUBLISHED', 'autoškola', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8c97164c-b480-5919-8dce-9315f2d9f3b3', 'sentence_builder', 'Складіть: «Моє посвідчення чинне до 2030 року.»', 'Moja dozvola važi do 2030. godine.', '["Moja", "2030.", "do", "godine.", "važi", "dozvola"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5367b3f7-26d4-54e2-a51f-02572dd23872', 'sentence_builder', 'Складіть: «Я пройшла медогляд без проблем.»', 'Prošla sam liječnički pregled bez problema.', '["pregled", "bez", "liječnički", "sam", "problema.", "Prošla"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '49e5c7ad-fe0b-5f56-a8f7-5d39c41a2e8d', 'listening', 'Прослухайте і складіть фразу', 'Ponesi i prijevod dozvole, za svaki slučaj.', '["svaki", "slučaj.", "prijevod", "Ponesi", "dozvole,", "za", "i"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '66735004-9dcd-5b09-950d-4ff4215be5cd', 'listening_dialogue', 'Прослухайте оголошення', '18; медичну довідку й паспорт', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Ви чуєте автовідповідач поліцейського управління.", "script": [{"hr": "Dobili ste Policijsku upravu zagrebačku, odjel za vozačke dozvole.", "ua": "Ви зателефонували до Загребського поліцейського управління, відділ посвідчень водія."}, {"hr": "Šalteri rade od osam do šesnaest sati, a srijedom do osamnaest.", "ua": "Віконця працюють з восьмої до шістнадцятої, а в середу — до вісімнадцятої."}, {"hr": "Za zamjenu strane dozvole ponesite liječničko uvjerenje i putovnicu.", "ua": "Для обміну іноземного посвідчення візьміть медичну довідку й паспорт."}], "questions": [{"q_ua": "До котрої працюють віконця в середу?", "answer_text": "18", "accept": ["18:00", "18.00", "до 18", "вісімнадцятої"], "answer_turn": 1}, {"q_ua": "Що треба взяти для обміну?", "options": ["медичну довідку й паспорт", "фото й переклад", "лише старе посвідчення"], "correct": 0, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '66735004-9dcd-5b09-950d-4ff4215be5cd', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8020f274-c3d1-563c-a5d3-4eda27cf4904', 'speaking', 'Як обміняти іноземне посвідчення?', 'Kako se mijenja strana vozačka dozvola?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '00b66be1-fc76-5494-91e2-57391ab8956e', 'speaking', 'Коли я можу забрати документ?', 'Kada mogu podići dokument?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'e769a1ea-c176-5c4e-bd4c-753e2344b11d', 'write_message', 'Напишіть у поліцейське управління: у вас українське посвідчення водія, ви питаєте, які документи потрібні для обміну.', 'Poštovani, imam ukrajinsku vozačku dozvolu. Koji dokumenti su potrebni za zamjenu?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у поліцейське управління: у вас українське посвідчення водія, ви питаєте, які документи потрібні для обміну.", "points": [{"ua": "українське посвідчення", "keys": [["ukrajinsk"]]}, {"ua": "обмін", "keys": [["zamjen"]]}, {"ua": "які документи", "keys": [["dokument"]]}], "hints": ["imam ukrajinsku vozačku dozvolu", "zamjena", "koji dokumenti su potrebni?"], "models": ["Poštovani, imam ukrajinsku vozačku dozvolu. Koji dokumenti su potrebni za zamjenu?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'e769a1ea-c176-5c4e-bd4c-753e2344b11d', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'f071aa19-1904-5315-a484-0d451c53a65a', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Treba li ovjereni prijevod dozvole i koliko košta zamjena?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай службовця, чи потрібен засвідчений переклад посвідчення і скільки коштує обмін.", "direction": "ua_hr", "points": [{"ua": "засвідчений переклад", "keys": [["prijevod"]]}, {"ua": "скільки коштує", "keys": [["košt"], ["pristojb"]]}], "hints": [], "models": ["Treba li ovjereni prijevod dozvole i koliko košta zamjena?"], "source_ua": "Спитай службовця, чи потрібен засвідчений переклад посвідчення і скільки коштує обмін."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'f071aa19-1904-5315-a484-0d451c53a65a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('82cdf22b-ae0c-5783-898e-bed827a54a1e', v_lesson, 'У поліцейському управлінні', 'U policijskoj upravi', 5481, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('b61ff0cb-83bd-56f1-9c4c-21498a56cec5', '82cdf22b-ae0c-5783-898e-bed827a54a1e', 'Darja', 'Dobar dan, imam ukrajinsku vozačku dozvolu. Kako se radi zamjena?', 'Добрий день, у мене українське посвідчення водія. Як відбувається обмін?', 1);
  perform pg_temp.turn('6ef16807-4203-58d8-b250-e3fda5ff0ab6', '82cdf22b-ae0c-5783-898e-bed827a54a1e', 'Službenik', 'Trebate liječničko uvjerenje iz medicine rada, putovnicu i staru dozvolu.', 'Вам потрібна медична довідка з медицини праці, паспорт і старе посвідчення.', 2);
  perform pg_temp.turn('8f25109b-7b8d-5d69-8df9-3957242d0064', '82cdf22b-ae0c-5783-898e-bed827a54a1e', 'Darja', 'Moram li polagati vozački ispit?', 'Чи мушу я складати іспит?', 3);
  perform pg_temp.turn('e9f73870-55dd-5885-922c-71dbc9bd2ad8', '82cdf22b-ae0c-5783-898e-bed827a54a1e', 'Službenik', 'Ne morate. Fotografija za dokumente se radi ovdje.', 'Не мусите. Фото на документи роблять тут.', 4);
  perform pg_temp.turn('0fe4b8fd-d64c-584f-bfb8-d4d5f7815729', '82cdf22b-ae0c-5783-898e-bed827a54a1e', 'Darja', 'Kada mogu podići novu dozvolu?', 'Коли я можу забрати нове посвідчення?', 5);
  perform pg_temp.turn('55c68a98-3719-52d1-b471-d304a7c36f54', '82cdf22b-ae0c-5783-898e-bed827a54a1e', 'Službenik', 'Za tri tjedna. Do tada vozite s privremenom potvrdom.', 'Через три тижні. До того їздите з тимчасовою довідкою.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9d135708-89e8-5dac-90b8-09c185bc9bfb', v_lesson, 'Після медогляду', 'Nakon pregleda', 5482, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('7b0ff080-ca06-5cec-aaeb-80b74b5c71ce', '9d135708-89e8-5dac-90b8-09c185bc9bfb', 'Ivan', 'Jesi li prošla liječnički pregled?', 'Ти пройшла медогляд?', 1);
  perform pg_temp.turn('cd1d8a7a-b133-518d-823b-9e349501062c', '9d135708-89e8-5dac-90b8-09c185bc9bfb', 'Darja', 'Jesam, ali čekala sam sat vremena dok nisam došla na red.', 'Так, але я чекала годину, поки дійшла моя черга.', 2);
  perform pg_temp.turn('061a115f-5615-5a32-adb1-eeb781ac8c8b', '9d135708-89e8-5dac-90b8-09c185bc9bfb', 'Ivan', 'A sad?', 'А тепер?', 3);
  perform pg_temp.turn('b4960267-f579-5daa-b4b6-9a41aa2b7e56', '9d135708-89e8-5dac-90b8-09c185bc9bfb', 'Darja', 'Sutra idem u policijsku upravu predati zahtjev.', 'Завтра йду в поліцейське управління подати заяву.', 4);
  perform pg_temp.turn('91392b31-43a2-5fa1-9af5-f0250fe49d4c', '9d135708-89e8-5dac-90b8-09c185bc9bfb', 'Ivan', 'Ponesi i prijevod dozvole, za svaki slučaj.', 'Візьми й переклад посвідчення, про всяк випадок.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.8 · урок 49: Реєстрація й технічний огляд — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'fb308628-6f9f-58c7-86bf-91bc5e469555';
  v_lesson constant uuid := 'c689f4db-1707-535b-a2cd-0f244b663854';
  v_gid constant uuid := '3a13fbe7-c0e4-55f8-b938-5579165e11bf';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KRET'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A2.8: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 49: Реєстрація й технічний огляд', 'Lekcija 49: Registracija i tehnički pregled', '["Зареєструвати авто й пройти техогляд", "Префікси руху: uđite na liniju, izađite iz vozila, prođite do blagajne"]'::jsonb, 20, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'registracija vozila', v_pos);
  v_pos := pg_temp.word(v_lesson, 'registrirati auto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stanica za tehnički pregled', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prometna dozvola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'registarske pločice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naljepnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispravnost vozila', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kočnice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispušni plinovi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'istrošen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nije prošao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponovni pregled', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obvezno osiguranje od automobilske odgovornosti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vlasnik vozila', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ući na liniju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izaći iz vozila', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijeći na', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugasiti motor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hauba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prtljažnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kutija prve pomoći', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e2eade8d-b3fe-5cd9-8f9a-2543b43a619d', 'fill_in_the_blank', 'Molim Vas, ___ iz vozila.', 'izađite', '["dođite", "uđite", "izađite", "prijeđite"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d4d664a-7f41-5335-86bb-d08db3e885ce', 'multiple_choice', 'Що означає «ispravnost vozila»?', 'справність авто', '["капот", "свідоцтво про реєстрацію (техпаспорт)", "справність авто", "обов’язкове страхування цивільної відповідальності (авто)"]'::jsonb, 'A2', 2, 'PUBLISHED', 'ispravnost vozila', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'caa5a1f6-5f8b-5d5b-ba02-fca3c5e9558f', 'multiple_choice', 'Що означає «stanica za tehnički pregled»?', 'станція техогляду', '["зношений", "станція техогляду", "вихлопні гази", "перейти на (до)"]'::jsonb, 'A2', 3, 'PUBLISHED', 'stanica za tehnički pregled', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b69a2e23-09f6-5e5f-946d-37047d1f8a29', 'multiple_choice', 'Що означає «ući na liniju»?', 'заїхати на лінію (огляду)', '["заїхати на лінію (огляду)", "свідоцтво про реєстрацію (техпаспорт)", "повторний огляд", "гальма"]'::jsonb, 'A2', 4, 'PUBLISHED', 'ući na liniju', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c45b7121-3f56-5107-8ee4-18c53cabb895', 'multiple_choice', 'Як хорватською «гальма»?', 'kočnice', '["istrošen", "stanica za tehnički pregled", "kočnice", "registrirati auto"]'::jsonb, 'A2', 5, 'PUBLISHED', 'kočnice', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd2b0d6a1-9966-56fd-865e-7ee8599ea84b', 'multiple_choice', 'Як хорватською «багажник»?', 'prtljažnik', '["registracija vozila", "naljepnica", "prtljažnik", "registarske pločice"]'::jsonb, 'A2', 6, 'PUBLISHED', 'prtljažnik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '211d24cf-ced4-5a3b-8558-9fb4075de7ce', 'type_answer', 'Напишіть хорватською: «наліпка»', 'naljepnica', null, 'A2', 7, 'PUBLISHED', 'naljepnica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8ff323a0-6eb6-5640-babc-851ca5bdbf6f', 'type_answer', 'Напишіть хорватською: «не пройшов (огляд)»', 'nije prošao', null, 'A2', 8, 'PUBLISHED', 'nije prošao', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1df25944-1414-5918-b4a4-284549ca9895', 'type_answer', 'Напишіть хорватською: «зношений»', 'istrošen', null, 'A2', 9, 'PUBLISHED', 'istrošen', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9f1ded78-00ee-5414-97c1-295c919dc7d9', 'sentence_builder', 'Складіть: «Гальма зношені.»', 'Kočnice su istrošene.', '["istrošene.", "Kočnice", "su"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f9e8f839-eb82-5ae4-8011-7bf40be2a6b6', 'sentence_builder', 'Складіть: «Свідоцтво про реєстрацію має бути в авто.»', 'Prometna dozvola mora biti u autu.', '["u", "Prometna", "mora", "autu.", "dozvola", "biti"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c183433-9ce8-5f5b-88a3-22c1a957f057', 'listening', 'Прослухайте і складіть фразу', 'Da, kad auto prođe pregled.', '["prođe", "Da,", "auto", "kad", "pregled."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '17d9f309-8938-5f47-874f-bbca80815c58', 'listening_dialogue', 'Прослухайте розмову', '10.30; свідоцтво про реєстрацію й посвідчення особи; 300 євро', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Дар’я телефонує на станцію техогляду. Послухайте.", "script": [{"speaker": "Darja", "hr": "Dobar dan, trebam termin za tehnički pregled.", "ua": "Добрий день, мені потрібен час на техогляд."}, {"speaker": "Službenica", "hr": "Imamo slobodno u četvrtak u deset i trideset.", "ua": "Є вільне місце в четвер о десятій тридцять."}, {"speaker": "Darja", "hr": "Odgovara mi. Što trebam ponijeti?", "ua": "Мені підходить. Що треба взяти?"}, {"speaker": "Službenica", "hr": "Prometnu dozvolu i osobnu iskaznicu. Registracija s osiguranjem je oko tristo eura.", "ua": "Свідоцтво про реєстрацію й посвідчення особи. Реєстрація зі страховкою — близько трьохсот євро."}], "questions": [{"q_ua": "О котрій огляд у четвер?", "answer_text": "10.30", "accept": ["10:30", "10,30", "пів на одинадцяту"], "answer_turn": 1}, {"q_ua": "Що треба взяти?", "options": ["свідоцтво про реєстрацію й посвідчення особи", "лише паспорт", "страховий поліс"], "correct": 0, "answer_turn": 3}, {"q_ua": "Скільки приблизно коштує реєстрація зі страховкою?", "options": ["30 євро", "300 євро", "3000 євро"], "correct": 1, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '17d9f309-8938-5f47-874f-bbca80815c58', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9ff68a58-3d06-5cd8-8938-b45d924978e0', 'speaking', 'Моє авто не пройшло техогляд.', 'Moj auto nije prošao tehnički pregled.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '96668aee-6bea-5690-9188-864ddb44c424', 'speaking', 'Де я плачу за реєстрацію?', 'Gdje plaćam registraciju?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'e75f0ad5-96d9-54cf-993a-692856b06383', 'write_message', 'Напишіть на станцію техогляду: хочете записатися на техогляд і реєстрацію в п’ятницю, спитайте ціну.', 'Dobar dan, htjela bih termin za tehnički pregled i registraciju u petak. Kolika je cijena?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть на станцію техогляду: хочете записатися на техогляд і реєстрацію в п’ятницю, спитайте ціну.", "points": [{"ua": "техогляд", "keys": [["pregled"]]}, {"ua": "реєстрація", "keys": [["registracij"]]}, {"ua": "у п’ятницю", "keys": [["petak"]]}, {"ua": "ціна", "keys": [["cijen"], ["košt"]]}], "hints": ["htjela bih termin", "za tehnički pregled i registraciju", "u petak", "kolika je cijena?"], "models": ["Dobar dan, htjela bih termin za tehnički pregled i registraciju u petak. Kolika je cijena?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'e75f0ad5-96d9-54cf-993a-692856b06383', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '54f347ce-be03-5557-bedd-da34472a11b5', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Zašto auto nije prošao? Je li ponovni pregled besplatan?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай контролера, чому авто не пройшло і чи повторний огляд безкоштовний.", "direction": "ua_hr", "points": [{"ua": "чому не пройшло", "keys": [["nije prošao"], ["zašto"]]}, {"ua": "повторний огляд", "keys": [["ponovn"]]}, {"ua": "безкоштовний", "keys": [["besplat"]]}], "hints": [], "models": ["Zašto auto nije prošao? Je li ponovni pregled besplatan?"], "source_ua": "Спитай контролера, чому авто не пройшло і чи повторний огляд безкоштовний."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '54f347ce-be03-5557-bedd-da34472a11b5', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('485c3a6a-afd3-5691-87ee-1587930010ec', v_lesson, 'На станції техогляду', 'Na tehničkom pregledu', 5491, 'A2', 'car_service', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('342199d5-549e-537e-a2ae-f5807648121b', '485c3a6a-afd3-5691-87ee-1587930010ec', 'Kontrolor', 'Dobar dan. Uđite na liniju broj dva i ugasite motor.', 'Добрий день. Заїжджайте на лінію номер два й заглушіть двигун.', 1);
  perform pg_temp.turn('9910121b-4602-54f1-9ce1-e20e7fdb1951', '485c3a6a-afd3-5691-87ee-1587930010ec', 'Ivan', 'Trebate li prometnu dozvolu?', 'Вам потрібне свідоцтво про реєстрацію?', 2);
  perform pg_temp.turn('9761be35-98d7-57c1-87d9-c14bece3ace6', '485c3a6a-afd3-5691-87ee-1587930010ec', 'Kontrolor', 'Da. I izađite iz vozila, molim. Otvorite haubu.', 'Так. І вийдіть з авто, будь ласка. Відкрийте капот.', 3);
  perform pg_temp.turn('54472b70-e731-5440-af18-4f52300ebfe9', '485c3a6a-afd3-5691-87ee-1587930010ec', 'Ivan', 'Je li sve u redu?', 'Усе в порядку?', 4);
  perform pg_temp.turn('89bdca29-7419-5347-b345-9cd584a3d3e1', '485c3a6a-afd3-5691-87ee-1587930010ec', 'Kontrolor', 'Nažalost, auto nije prošao. Kočnice su istrošene.', 'На жаль, авто не пройшло. Гальма зношені.', 5);
  perform pg_temp.turn('92aa3f18-9ef4-57d2-bd18-cb6cfe66e03b', '485c3a6a-afd3-5691-87ee-1587930010ec', 'Ivan', 'Što sad?', 'І що тепер?', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('13ec081f-06a4-52a5-99df-6bfb4321c852', v_lesson, 'Повторний огляд', 'Ponovni pregled', 5492, 'A2', 'car_service', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('03cfdcd4-530d-5d73-b349-296961a8fa07', '13ec081f-06a4-52a5-99df-6bfb4321c852', 'Kontrolor', 'Popravite kočnice. Ponovni pregled je besplatan u roku od petnaest dana.', 'Відремонтуйте гальма. Повторний огляд безкоштовний протягом п’ятнадцяти днів.', 1);
  perform pg_temp.turn('169b5fee-7b4f-5b6f-a0ec-f2d14e81527c', '13ec081f-06a4-52a5-99df-6bfb4321c852', 'Ivan', 'Dobro. A gdje plaćam registraciju?', 'Добре. А де я плачу за реєстрацію?', 2);
  perform pg_temp.turn('52215d44-2c2e-516f-8036-e22eca547d17', '13ec081f-06a4-52a5-99df-6bfb4321c852', 'Kontrolor', 'Prijeđite na blagajnu. Tamo plaćate i obvezno osiguranje.', 'Перейдіть до каси. Там ви сплачуєте й обов’язкову страховку.', 3);
  perform pg_temp.turn('6728f90a-ad1e-57f9-8b41-8861ae67d2d0', '13ec081f-06a4-52a5-99df-6bfb4321c852', 'Ivan', 'Dobit ću i novu naljepnicu?', 'Я отримаю й нову наліпку?', 4);
  perform pg_temp.turn('47cbf213-d233-5adb-9680-3cb8744fce72', '13ec081f-06a4-52a5-99df-6bfb4321c852', 'Kontrolor', 'Da, kad auto prođe pregled.', 'Так, коли авто пройде огляд.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.8 · урок 50: ДТП: що сталося? — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'fb308628-6f9f-58c7-86bf-91bc5e469555';
  v_lesson constant uuid := '306ddbde-6662-5d7e-8c58-eb2c2a17a504';
  v_gid constant uuid := '3a13fbe7-c0e4-55f8-b938-5579165e11bf';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KRET'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A2.8: місце 3 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 50: ДТП: що сталося?', 'Lekcija 50: Prometna nesreća: što se dogodilo?', '["Пояснити, як сталася ДТП, і заповнити європротокол", "Дієслова руху: izašao je iz zavoja, prešao je u moju traku, naletio je"]'::jsonb, 20, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'europsko izvješće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sudariti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naletjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udariti straga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oduzeti prednost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prometna traka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skrenuti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žmigavac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zavoj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ogrebotina na branik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'branik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udubljen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'materijalna šteta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'reflektirajući prsluk', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sigurnosni trokut', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pozvati policiju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vučna služba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na licu mjesta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krivac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izjava svjedoka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fotografirati štetu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pregaziti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be436914-ba28-5a79-a8d4-0b7c91365f4c', 'fill_in_the_blank', 'Auto je ___ iz zavoja i udario u ogradu.', 'izletio', '["uletio", "doletio", "izletio", "preletio"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'de2baae9-a516-5bdb-93de-fb579ab4d7f8', 'multiple_choice', 'Що означає «prometna traka»?', 'смуга руху', '["смуга руху", "на місці (події)", "подряпина на бампері", "європротокол"]'::jsonb, 'A2', 2, 'PUBLISHED', 'prometna traka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8296c2b8-dd35-5d4a-8bc3-a3a8bbecbaf3', 'multiple_choice', 'Що означає «naletjeti»?', 'наїхати, налетіти', '["не надати переваги (порушити пріоритет)", "поворот (дороги)", "наїхати, налетіти", "зіткнутися"]'::jsonb, 'A2', 3, 'PUBLISHED', 'naletjeti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '15afad9c-5bcb-5761-85ee-32781b1baa0a', 'multiple_choice', 'Що означає «europsko izvješće»?', 'європротокол', '["покажчик повороту", "винуватець", "європротокол", "повернути"]'::jsonb, 'A2', 4, 'PUBLISHED', 'europsko izvješće', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '208872fa-5a93-5cfa-a3c7-a8b773398ec6', 'multiple_choice', 'Як хорватською «покажчик повороту»?', 'žmigavac', '["prometna traka", "žmigavac", "udariti straga", "pozvati policiju"]'::jsonb, 'A2', 5, 'PUBLISHED', 'žmigavac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '71f29958-5f98-5783-bfde-d853f51aef81', 'multiple_choice', 'Як хорватською «знак аварійної зупинки»?', 'sigurnosni trokut', '["žmigavac", "reflektirajući prsluk", "oduzeti prednost", "sigurnosni trokut"]'::jsonb, 'A2', 6, 'PUBLISHED', 'sigurnosni trokut', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d04e609-cabe-529b-bda9-50131527d72f', 'type_answer', 'Напишіть хорватською: «евакуатор (служба)»', 'vučna služba', null, 'A2', 7, 'PUBLISHED', 'vučna služba', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2113f65d-b969-5e60-9cd3-14a1de10c9fa', 'type_answer', 'Напишіть хорватською: «вм’ятий»', 'udubljen', null, 'A2', 8, 'PUBLISHED', 'udubljen', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f5b6a9f6-bb8f-5492-84e4-0a364f35ce6b', 'type_answer', 'Напишіть хорватською: «зіткнутися»', 'sudariti se', null, 'A2', 9, 'PUBLISHED', 'sudariti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '22bace12-c189-5c66-b06b-ff57215110c0', 'sentence_builder', 'Складіть: «Ніхто не постраждав.»', 'Nitko nije ozlijeđen.', '["nije", "ozlijeđen.", "Nitko"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3fdb6fd8-ac3e-5af8-a1f5-a30e2dceace3', 'sentence_builder', 'Складіть: «Він повернув ліворуч без покажчика.»', 'Skrenuo je lijevo bez žmigavca.', '["lijevo", "je", "bez", "Skrenuo", "žmigavca."]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '805da260-2649-5dad-8627-f4a8df023e51', 'listening', 'Прослухайте і складіть фразу', 'Jest. Branik je udubljen, zvat ću vučnu službu.', '["udubljen,", "službu.", "vučnu", "Branik", "je", "ću", "zvat", "Jest."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'cd83a8f8-b3d8-5165-a427-28cd4b3405c6', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'на світлофорі; бампер; о 19:00', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Даша залишила вам голосове повідомлення після ДТП.", "script": [{"hr": "Bok, nemoj se brinuti, dobro sam.", "ua": "Привіт, не хвилюйся, я в порядку."}, {"hr": "Jedan auto me udario straga na semaforu kod Savske.", "ua": "Одне авто вдарило мене ззаду на світлофорі біля Савської."}, {"hr": "Ispunili smo europsko izvješće, šteta je samo na braniku.", "ua": "Ми заповнили європротокол, пошкоджено лише бампер."}, {"hr": "Doći ću kući oko sedam.", "ua": "Я буду вдома близько сьомої."}], "questions": [{"q_ua": "Де сталася ДТП?", "options": ["на світлофорі", "на парковці", "на автостраді"], "correct": 0, "answer_turn": 1}, {"q_ua": "Що пошкоджено?", "answer_text": "бампер", "accept": ["branik", "бампера"], "answer_turn": 2}, {"q_ua": "Коли Даша буде вдома?", "options": ["о 17:00", "о 19:00", "о 21:00"], "correct": 1, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'cd83a8f8-b3d8-5165-a427-28cd4b3405c6', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '98d67ba7-4fcc-507d-90f4-9a08e9ead0b0', 'speaking', 'Він вдарив мене ззаду.', 'Udario me straga.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae04cc44-af96-5065-9097-f361667de172', 'speaking', 'Заповнімо європротокол.', 'Ispunimo europsko izvješće.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'be352619-b309-56c7-b960-66bcd1987525', 'write_message', 'Напишіть у страхову: учора на перехресті інший водій не надав вам переваги; пошкоджено двері; у вкладенні європротокол.', 'Poštovani, jučer mi je na raskrižju drugi vozač oduzeo prednost. Oštećena su vrata. U privitku je europsko izvješće.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у страхову: учора на перехресті інший водій не надав вам переваги; пошкоджено двері; у вкладенні європротокол.", "points": [{"ua": "на перехресті", "keys": [["raskrižj"]]}, {"ua": "не надав переваги", "keys": [["prednost"]]}, {"ua": "двері", "keys": [["vrata"]]}, {"ua": "європротокол", "keys": [["izvješć"]]}], "hints": ["jučer na raskrižju", "oduzeo mi je prednost", "oštećena su vrata", "u privitku europsko izvješće"], "models": ["Poštovani, jučer mi je na raskrižju drugi vozač oduzeo prednost. Oštećena su vrata. U privitku je europsko izvješće."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'be352619-b309-56c7-b960-66bcd1987525', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '6b1704b0-6c03-5ac7-b753-3977081952d2', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Drugi vozač ga je udario straga. Ova gospođa je svjedokinja.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи поліцейському, що інший водій вдарив мене ззаду, а ця пані — свідок.", "direction": "ua_hr", "points": [{"ua": "вдарив ззаду", "keys": [["straga"]]}, {"ua": "свідок", "keys": [["svjedok"], ["svjedokinj"]]}], "hints": [], "models": ["Drugi vozač ga je udario straga. Ova gospođa je svjedokinja."], "source_ua": "Скажи поліцейському, що інший водій вдарив мене ззаду, а ця пані — свідок."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '6b1704b0-6c03-5ac7-b753-3977081952d2', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('bb0af795-2fb6-5d37-9760-a0745296e920', v_lesson, 'На перехресті', 'Na raskrižju', 5501, 'A2', 'car_service', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('d556ba9e-0e0c-5148-adf0-469cd2b9f668', 'bb0af795-2fb6-5d37-9760-a0745296e920', 'Darja', 'Jeste li dobro? Nitko nije ozlijeđen?', 'Ви в порядку? Ніхто не постраждав?', 1);
  perform pg_temp.turn('755ad725-f3ae-5ba6-afb7-bb6b763072a2', 'bb0af795-2fb6-5d37-9760-a0745296e920', 'Vozač', 'Dobro sam. Oprostite, nisam Vas vidio.', 'Я в порядку. Вибачте, я вас не бачив.', 2);
  perform pg_temp.turn('12952140-1a17-5fe0-8ad6-6c2a80f7bf40', 'bb0af795-2fb6-5d37-9760-a0745296e920', 'Darja', 'Oduzeli ste mi prednost i udarili me u vrata.', 'Ви не надали мені переваги й вдарили мене в двері.', 3);
  perform pg_temp.turn('0babdefc-a662-59d9-9b15-75b85a076e3e', 'bb0af795-2fb6-5d37-9760-a0745296e920', 'Vozač', 'Imate pravo. Ispunimo europsko izvješće.', 'Ваша правда. Заповнімо європротокол.', 4);
  perform pg_temp.turn('6787a0f7-fc0e-5919-a9e0-21f00e5ecdf8', 'bb0af795-2fb6-5d37-9760-a0745296e920', 'Darja', 'Dobro. Prvo ću postaviti sigurnosni trokut i fotografirati štetu.', 'Добре. Спочатку поставлю знак аварійної зупинки й сфотографую пошкодження.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('68c2fa6e-cad6-5385-89d6-b135c5d9ae4d', v_lesson, 'Розмова з поліцією', 'Razgovor s policijom', 5502, 'A2', 'car_service', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('9699b0e2-cb97-544b-aa82-9dfbea0710a4', '68c2fa6e-cad6-5385-89d6-b135c5d9ae4d', 'Policajac', 'Što se dogodilo?', 'Що сталося?', 1);
  perform pg_temp.turn('d4056d00-9fb6-55b5-a7c3-08131a78671e', '68c2fa6e-cad6-5385-89d6-b135c5d9ae4d', 'Ivan', 'Vozio sam ravno, a on je skrenuo lijevo bez žmigavca i prešao u moju traku.', 'Я їхав прямо, а він повернув ліворуч без покажчика й виїхав на мою смугу.', 2);
  perform pg_temp.turn('8cebfd2e-a5a8-59e6-9cbf-c7eaa783a6fb', '68c2fa6e-cad6-5385-89d6-b135c5d9ae4d', 'Policajac', 'Ima li svjedoka?', 'Є свідки?', 3);
  perform pg_temp.turn('25e2de2b-1b8f-55f2-90bd-da57b81c9528', '68c2fa6e-cad6-5385-89d6-b135c5d9ae4d', 'Ivan', 'Ima, ova gospođa je sve vidjela.', 'Є, ця пані все бачила.', 4);
  perform pg_temp.turn('5a56a451-cd97-57b3-8ff2-88fbbd79f57c', '68c2fa6e-cad6-5385-89d6-b135c5d9ae4d', 'Policajac', 'Dobro. Je li šteta samo materijalna?', 'Добре. Шкода лише матеріальна?', 5);
  perform pg_temp.turn('d09efaf1-55c2-5507-a300-ca1d72059ce5', '68c2fa6e-cad6-5385-89d6-b135c5d9ae4d', 'Ivan', 'Jest. Branik je udubljen, zvat ću vučnu službu.', 'Так. Бампер вм’ятий, я викличу евакуатор.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.8 · урок 51: Штраф, радар і паркувальні зони — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'fb308628-6f9f-58c7-86bf-91bc5e469555';
  v_lesson constant uuid := 'dfa42285-bd22-5df8-bf4a-670f56911803';
  v_gid constant uuid := '3a13fbe7-c0e4-55f8-b938-5579165e11bf';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KRET'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A2.8: місце 4 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 51: Штраф, радар і паркувальні зони', 'Lekcija 51: Kazna, radar i parkirne zone', '["Зрозуміти штраф і правила паркування в місті", "Дієслова руху: prošao je kroz crveno, odvezli su auto, ušli ste u zonu"]'::jsonb, 20, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'radar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prekršaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prekoračiti brzinu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prometna kazna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'platiti na licu mjesta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upola manje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kazneni bodovi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'proći kroz crveno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'parkirna zona', v_pos);
  v_pos := pg_temp.word(v_lesson, 'parkirni automat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'platiti parking SMS-om', v_pos);
  v_pos := pg_temp.word(v_lesson, 'parkirna karta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nepropisno parkiran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjesto za invalide', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odvesti auto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pločnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prometni redar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žuta crta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zona smirenog prometa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ući u zonu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žaliti se na kaznu', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a028633-ca9c-5e9f-a5a7-324a1cc305d3', 'fill_in_the_blank', 'Pauk je ___ auto jer je stajao na pločniku.', 'odvezao', '["uvezao", "dovezao", "odvezao", "izvezao"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8165af58-0482-5ce7-87c0-c4dc426b5b27', 'multiple_choice', 'Що означає «upola manje»?', 'удвічі менше', '["правопорушення", "паркувальна зона", "удвічі менше", "проїхати на червоне"]'::jsonb, 'A2', 2, 'PUBLISHED', 'upola manje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7f935df5-168a-547e-bc0f-fd5b2e2fa910', 'multiple_choice', 'Що означає «parkirni automat»?', 'паркомат', '["паркомат", "жовта лінія", "паркувальний квиток", "неправильно припаркований"]'::jsonb, 'A2', 3, 'PUBLISHED', 'parkirni automat', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'baacbd7b-2a3c-53fc-86dd-158d3dc23115', 'multiple_choice', 'Що означає «parkirna zona»?', 'паркувальна зона', '["неправильно припаркований", "проїхати на червоне", "заплатити на місці", "паркувальна зона"]'::jsonb, 'A2', 4, 'PUBLISHED', 'parkirna zona', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c3bc3d4a-5c67-5b29-bfb4-32c53f1208b5', 'multiple_choice', 'Що означає «mjesto za invalide»?', 'місце для людей з інвалідністю', '["місце для людей з інвалідністю", "відвезти (евакуювати) авто", "перевищити швидкість", "правопорушення"]'::jsonb, 'A2', 5, 'PUBLISHED', 'mjesto za invalide', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ddff5e3d-3977-56f3-955e-f8afd850b93c', 'multiple_choice', 'Як хорватською «тротуар»?', 'pločnik', '["mjesto za invalide", "ući u zonu", "pločnik", "radar"]'::jsonb, 'A2', 6, 'PUBLISHED', 'pločnik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '70db1f4a-5272-53a4-a771-3acf746d589c', 'multiple_choice', 'Як хорватською «неправильно припаркований»?', 'nepropisno parkiran', '["kazneni bodovi", "nepropisno parkiran", "upola manje", "prekoračiti brzinu"]'::jsonb, 'A2', 7, 'PUBLISHED', 'nepropisno parkiran', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '494d544b-d4f2-5b4a-86ab-f9acc95bb860', 'type_answer', 'Напишіть хорватською: «радар»', 'radar', null, 'A2', 8, 'PUBLISHED', 'radar', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '474e5f31-7c29-510d-b811-c1752e25d4bd', 'type_answer', 'Напишіть хорватською: «правопорушення»', 'prekršaj', null, 'A2', 9, 'PUBLISHED', 'prekršaj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '326bceca-fc5c-5797-a69f-7e2261edfed0', 'sentence_builder', 'Складіть: «Не паркуйтеся на тротуарі.»', 'Ne parkirajte na pločniku.', '["pločniku.", "parkirajte", "Ne", "na"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '23c087a7-d42c-5e55-b342-69785957fa4b', 'sentence_builder', 'Складіть: «Паркування можна оплатити SMS-кою.»', 'Parking možete platiti SMS-om.', '["možete", "SMS-om.", "Parking", "platiti"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '60007ebc-ff2e-5a68-a56c-3fe9fc93369f', 'listening', 'Прослухайте і складіть фразу', 'Možda djelomično, na pločniku.', '["djelomično,", "pločniku.", "Možda", "na"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'a9d5453a-fa77-577c-85e8-bee5fa780c0d', 'listening_dialogue', 'Прослухайте оголошення', 'годину; у неділю й у свята; 708', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Ви читаєте вголос інформацію з паркомату. Послухайте.", "script": [{"hr": "Prva zona: najduže jedan sat, od sedam do dvadeset jedan sat.", "ua": "Перша зона: максимум одна година, з сьомої до двадцять першої."}, {"hr": "Nedjeljom i praznikom parkiranje je besplatno.", "ua": "У неділю й у свята паркування безкоштовне."}, {"hr": "SMS pošaljite na broj 708 s registracijom vozila.", "ua": "SMS надішліть на номер 708 з номером авто."}], "questions": [{"q_ua": "Скільки максимум можна стояти в першій зоні?", "options": ["годину", "дві години", "без обмежень"], "correct": 0, "answer_turn": 0}, {"q_ua": "Коли паркування безкоштовне?", "options": ["у суботу", "у неділю й у свята", "уночі з 19:00"], "correct": 1, "answer_turn": 1}, {"q_ua": "На який номер надсилати SMS?", "answer_text": "708", "accept": ["сімсот вісім"], "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'a9d5453a-fa77-577c-85e8-bee5fa780c0d', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '536fe74a-90b2-5f07-b648-d4361108a3ab', 'speaking', 'Я не бачив знака.', 'Nisam vidio znak.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e8cd1ee9-2d77-5f8d-b4ae-2b2294bd9974', 'speaking', 'Можу я заплатити на місці?', 'Mogu li platiti na licu mjesta?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '2b596f02-c1d5-520f-a973-875cf5f29e41', 'write_message', 'Напишіть у міську службу: ви отримали штраф за паркування, але заплатили квиток; хочете оскаржити штраф.', 'Poštovani, dobila sam kaznu za parkiranje, ali sam platila parkirnu kartu. Želim se žaliti na kaznu.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у міську службу: ви отримали штраф за паркування, але заплатили квиток; хочете оскаржити штраф.", "points": [{"ua": "отримали штраф", "keys": [["kazn"]]}, {"ua": "заплатили квиток", "keys": [["platil"], ["karta"], ["kart"]]}, {"ua": "оскаржити", "keys": [["žal"]]}], "hints": ["dobila sam kaznu za parkiranje", "platila sam parkirnu kartu", "želim se žaliti"], "models": ["Poštovani, dobila sam kaznu za parkiranje, ali sam platila parkirnu kartu. Želim se žaliti na kaznu."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '2b596f02-c1d5-520f-a973-875cf5f29e41', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'ad581a18-af7c-55e0-a17b-da7ee893aa3d', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Gdje može preuzeti auto i koliko to košta?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай інспектора, де можна забрати евакуйоване авто і скільки це коштує.", "direction": "ua_hr", "points": [{"ua": "де забрати", "keys": [["gdje"], ["preuzet"]]}, {"ua": "авто", "keys": [["auto"]]}, {"ua": "скільки коштує", "keys": [["košt"]]}], "hints": [], "models": ["Gdje može preuzeti auto i koliko to košta?"], "source_ua": "Спитай інспектора, де можна забрати евакуйоване авто і скільки це коштує."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'ad581a18-af7c-55e0-a17b-da7ee893aa3d', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9d3f077b-d4ca-58e1-9407-20efb4480b94', v_lesson, 'Поліцейська зупинка', 'Policijska kontrola', 5511, 'A2', 'car_service', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('8519072d-7b9d-560b-87ca-ebe7c2d17eaa', '9d3f077b-d4ca-58e1-9407-20efb4480b94', 'Policajac', 'Dobar dan. Prekoračili ste brzinu. Vozili ste sedamdeset, a ograničenje je pedeset.', 'Добрий день. Ви перевищили швидкість. Ви їхали сімдесят, а обмеження п’ятдесят.', 1);
  perform pg_temp.turn('1d38e30d-50a8-5dc9-8e77-881aa45f0fd8', '9d3f077b-d4ca-58e1-9407-20efb4480b94', 'Ivan', 'Oprostite, nisam vidio znak.', 'Перепрошую, я не бачив знака.', 2);
  perform pg_temp.turn('525f0f10-20b7-5e84-a262-068c4d054d6a', '9d3f077b-d4ca-58e1-9407-20efb4480b94', 'Policajac', 'Radar Vas je snimio. To je prekršaj.', 'Радар вас зафіксував. Це правопорушення.', 3);
  perform pg_temp.turn('777282eb-fad2-578d-af64-e352d18789f3', '9d3f077b-d4ca-58e1-9407-20efb4480b94', 'Ivan', 'Mogu li platiti na licu mjesta?', 'Можу я заплатити на місці?', 4);
  perform pg_temp.turn('a6cc0b24-6236-5bc9-b5f9-3d8273518fe8', '9d3f077b-d4ca-58e1-9407-20efb4480b94', 'Policajac', 'Možete, onda plaćate upola manje.', 'Можете, тоді платите вдвічі менше.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('946b5567-f486-5d56-b97a-5f1aad43a7b9', v_lesson, 'Де моє авто?', 'Gdje mi je auto?', 5512, 'A2', 'car_service', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('1483c717-f1a0-5d13-9549-fae6fa49b53d', '946b5567-f486-5d56-b97a-5f1aad43a7b9', 'Daša', 'Ivane, nema auta! Ostavila sam ga ovdje kod pločnika.', 'Іване, авто немає! Я залишила його тут біля тротуару.', 1);
  perform pg_temp.turn('1ba4fd52-e4ee-5e7a-8b8b-0988c52b40fd', '946b5567-f486-5d56-b97a-5f1aad43a7b9', 'Ivan', 'Je li bio na žutoj crti?', 'Воно стояло на жовтій лінії?', 2);
  perform pg_temp.turn('0f890b18-da32-5f29-8b29-fd602c6659fc', '946b5567-f486-5d56-b97a-5f1aad43a7b9', 'Daša', 'Možda djelomično, na pločniku.', 'Можливо, частково, на тротуарі.', 3);
  perform pg_temp.turn('878dec9f-8495-53b7-86b8-cf45fd257d42', '946b5567-f486-5d56-b97a-5f1aad43a7b9', 'Ivan', 'Onda ga je pauk odvezao. Nepropisno parkiran auto se odvozi.', 'Тоді його евакуювали. Неправильно припарковане авто евакуюють.', 4);
  perform pg_temp.turn('03d8c89d-573a-55be-98d1-a15dffba82f4', '946b5567-f486-5d56-b97a-5f1aad43a7b9', 'Daša', 'Super. Gdje ga mogu preuzeti?', 'Чудово. Де я можу його забрати?', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.8 · урок 52: Платні дороги, зимові шини й подорож авто — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'fb308628-6f9f-58c7-86bf-91bc5e469555';
  v_lesson constant uuid := '161ebc1e-5359-551e-82a5-ddd878ceb97a';
  v_gid constant uuid := '3a13fbe7-c0e4-55f8-b938-5579165e11bf';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KRET'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A2.8: місце 5 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 52: Платні дороги, зимові шини й подорож авто', 'Lekcija 52: Ceste, zimske gume i put autom', '["Підготуватися до поїздки: платна дорога, зимове спорядження, стан доріг", "Дієслова руху: zaobići gužvu, sići s autoceste, proći kroz tunel"]'::jsonb, 20, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'naplata cestarine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'elektronička naplata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brza cesta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tunel', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vijadukt', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zimska oprema', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lanci za snijeg', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poledica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stanje na cestama', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zatvoren za promet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaobići', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sići s autoceste', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izlaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vozilo s prikolicom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vinjeta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'granični prijelaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'napuniti spremnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'voziti oprezno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prometne informacije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolona vozila', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaobilaznica', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '220e06b8-e2d5-5212-bb9c-b9678273b4da', 'fill_in_the_blank', 'Zbog radova moramo ___ centar grada.', 'zaobići', '["izaći", "ući", "doći", "zaobići"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'abc29c72-ae26-5a7e-8306-b307497ec8d9', 'multiple_choice', 'Що означає «voziti oprezno»?', 'їхати обережно', '["тунель", "ожеледиця", "їхати обережно", "віадук"]'::jsonb, 'A2', 2, 'PUBLISHED', 'voziti oprezno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '28bf5c2b-d787-5376-ac77-c503d824a476', 'multiple_choice', 'Що означає «granični prijelaz»?', 'пункт пропуску на кордоні', '["авто з причепом", "віадук", "з’їхати з автостради", "пункт пропуску на кордоні"]'::jsonb, 'A2', 3, 'PUBLISHED', 'granični prijelaz', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '550fe18a-2d75-52dc-91f6-c0ad89b5d884', 'multiple_choice', 'Що означає «naplata cestarine»?', 'оплата за проїзд (платна дорога)', '["ланцюги на колеса", "тунель", "оплата за проїзд (платна дорога)", "зимове спорядження"]'::jsonb, 'A2', 4, 'PUBLISHED', 'naplata cestarine', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b0b4b05f-107f-54b6-9898-434e22da06fc', 'multiple_choice', 'Як хорватською «дорожня інформація»?', 'prometne informacije', '["lanci za snijeg", "elektronička naplata", "zimska oprema", "prometne informacije"]'::jsonb, 'A2', 5, 'PUBLISHED', 'prometne informacije', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '98cb21f8-3dc5-5c1b-8fb2-01507fe371a9', 'multiple_choice', 'Як хорватською «віньєтка»?', 'vinjeta', '["vinjeta", "lanci za snijeg", "izlaz", "prometne informacije"]'::jsonb, 'A2', 6, 'PUBLISHED', 'vinjeta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae29afec-843e-53d3-a001-ce50590dd59c', 'type_answer', 'Напишіть хорватською: «колона автомобілів»', 'kolona vozila', null, 'A2', 7, 'PUBLISHED', 'kolona vozila', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7479b17d-1ccf-5f69-b5c8-fdacab638b12', 'type_answer', 'Напишіть хорватською: «тунель»', 'tunel', null, 'A2', 8, 'PUBLISHED', 'tunel', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a1e05742-2e83-5098-b627-d1a9d2e25950', 'type_answer', 'Напишіть хорватською: «віадук»', 'vijadukt', null, 'A2', 9, 'PUBLISHED', 'vijadukt', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fe4dd54b-8762-5868-b5e2-48d47d67141b', 'sentence_builder', 'Складіть: «На дорозі ожеледиця, їдьте обережно.»', 'Na cesti je poledica, vozite oprezno.', '["cesti", "je", "poledica,", "oprezno.", "vozite", "Na"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0d5a3781-2c98-5f3d-bc5a-0b75d86bae0c', 'sentence_builder', 'Складіть: «На наступному з’їзді поверніть праворуч.»', 'Na sljedećem izlazu skrenite desno.', '["Na", "skrenite", "izlazu", "desno.", "sljedećem"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5b97c3f7-f632-5c23-a0da-ca40d645eb07', 'listening', 'Прослухайте і складіть фразу', 'Starom cestom do Karlovca, pa opet na autocestu.', '["opet", "pa", "Starom", "do", "autocestu.", "Karlovca,", "cestom", "na"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '67324d2e-cad0-570d-ae7f-7cb6e763c324', 'listening_dialogue', 'Прослухайте новину', 'для авто з причепами; 80; 40 хвилин', 'A2', 'PUBLISHED', '{"kind": "news", "situation_ua": "Ви їдете авто й слухаєте дорожні новини по радіо.", "script": [{"hr": "Zbog jake bure autocesta između Svetog Roka i Maslenice zatvorena je za vozila s prikolicom.", "ua": "Через сильну буру автострада між Светим Роком і Масленицею закрита для авто з причепами."}, {"hr": "Za ostala vozila brzina je ograničena na osamdeset kilometara na sat.", "ua": "Для інших авто швидкість обмежена до вісімдесяти кілометрів на годину."}, {"hr": "Na graničnom prijelazu Bregana čeka se četrdeset minuta.", "ua": "На пункті пропуску Брегана чекають сорок хвилин."}], "questions": [{"q_ua": "Для кого закрита автострада?", "options": ["для авто з причепами", "для всіх авто", "для мотоциклів"], "correct": 0, "answer_turn": 0}, {"q_ua": "Яке обмеження швидкості для інших авто (км/год)?", "answer_text": "80", "accept": ["вісімдесят", "80 км/год"], "answer_turn": 1}, {"q_ua": "Скільки чекають на кордоні в Брегані?", "options": ["20 хвилин", "40 хвилин", "годину"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '67324d2e-cad0-570d-ae7f-7cb6e763c324', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5a3baefa-8bf6-5f91-ae39-43421d7f84ec', 'speaking', 'Як оплачують проїзд по автостраді?', 'Kako se plaća cestarina?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '55c4fc0e-5786-50e1-a2ca-ad93d72c4105', 'speaking', 'Можемо об’їхати затор?', 'Možemo li zaobići zastoj?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'cf5ddffd-06fd-5f4b-a300-dbd852c69464', 'write_message', 'Напишіть друзям: ви в заторі біля Лучко, об’їжджаєте старою дорогою й запізнитеся на годину.', 'U zastoju smo kod Lučkog. Zaobilazimo starom cestom i kasnit ćemo sat vremena.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть друзям: ви в заторі біля Лучко, об’їжджаєте старою дорогою й запізнитеся на годину.", "points": [{"ua": "у заторі", "keys": [["zastoj"], ["gužv"]]}, {"ua": "об’їжджаєте", "keys": [["zaobi"], ["starom cestom"]]}, {"ua": "запізнитеся на годину", "keys": [["kasn"], ["sat"]]}], "hints": ["u zastoju smo kod Lučkog", "zaobilazimo starom cestom", "kasnit ćemo sat vremena"], "models": ["U zastoju smo kod Lučkog. Zaobilazimo starom cestom i kasnit ćemo sat vremena."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'cf5ddffd-06fd-5f4b-a300-dbd852c69464', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'a999ece3-866f-5a9d-a75b-b290becb8a2e', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Je li cesta kroz Liku otvorena? Trebaju li lanci za snijeg?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай на заправці, чи відкрита дорога через Ліку і чи потрібні ланцюги.", "direction": "ua_hr", "points": [{"ua": "дорога відкрита", "keys": [["otvoren"], ["zatvoren"]]}, {"ua": "через Ліку", "keys": [["lik"]]}, {"ua": "ланцюги", "keys": [["lanc"]]}], "hints": [], "models": ["Je li cesta kroz Liku otvorena? Trebaju li lanci za snijeg?"], "source_ua": "Спитай на заправці, чи відкрита дорога через Ліку і чи потрібні ланцюги."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'a999ece3-866f-5a9d-a75b-b290becb8a2e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7042acda-e967-50c9-82e9-ccdb1ec97fe8', v_lesson, 'Перед поїздкою до Спліта', 'Prije puta za Split', 5521, 'A2', 'transport', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('3734b7ac-7e32-59ae-9de9-11d2549c1553', '7042acda-e967-50c9-82e9-ccdb1ec97fe8', 'Darja', 'Ivane, trebamo li zimske gume za put u Split?', 'Іване, нам потрібні зимові шини для поїздки до Спліта?', 1);
  perform pg_temp.turn('90ed1d90-4eb8-541a-a163-f4e8ca376073', '7042acda-e967-50c9-82e9-ccdb1ec97fe8', 'Ivan', 'Trebamo, zimska oprema je obvezna od studenog. Kroz Liku može biti poledice.', 'Потрібні, зимове спорядження обов’язкове з листопада. Через Ліку може бути ожеледиця.', 2);
  perform pg_temp.turn('2907c654-ceac-5c25-ad9d-338383d9d781', '7042acda-e967-50c9-82e9-ccdb1ec97fe8', 'Darja', 'Kako se plaća cestarina?', 'Як оплачують проїзд?', 3);
  perform pg_temp.turn('b4c72dc9-3ef5-5d4e-bc2b-ffbca31dce38', '7042acda-e967-50c9-82e9-ccdb1ec97fe8', 'Ivan', 'Na izlazu s autoceste, karticom. Ili elektronička naplata, ako imaš uređaj.', 'На виїзді з автостради, карткою. Або електронна оплата, якщо маєш пристрій.', 4);
  perform pg_temp.turn('e51e11b2-c9aa-5b95-8830-2774e623e576', '7042acda-e967-50c9-82e9-ccdb1ec97fe8', 'Darja', 'Provjerit ću stanje na cestama prije polaska.', 'Перевірю стан доріг перед виїздом.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('07f82551-a4d0-5b6e-b271-443e4999b945', v_lesson, 'Затор', 'Zastoj', 5522, 'A2', 'transport', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('11b05e08-0b4f-5b07-a6d8-f5b56230cb09', '07f82551-a4d0-5b6e-b271-443e4999b945', 'Radio', 'Prometne informacije: kod Lučkog je zastoj od pet kilometara.', 'Дорожня інформація: біля Лучко затор п’ять кілометрів.', 1);
  perform pg_temp.turn('1468a9a4-94fb-551f-ba4d-0575a177c0f4', '07f82551-a4d0-5b6e-b271-443e4999b945', 'Daša', 'Joj, zastoj! Možemo li ga zaobići?', 'Ой, затор! Можемо його об’їхати?', 2);
  perform pg_temp.turn('12c257bf-ffab-5285-973e-cb0a70718365', '07f82551-a4d0-5b6e-b271-443e4999b945', 'Ivan', 'Možemo. Siđimo s autoceste na sljedećem izlazu.', 'Можемо. З’їдьмо з автостради на наступному з’їзді.', 3);
  perform pg_temp.turn('2dcfa309-5505-5ea9-853e-dd4196e3ee2b', '07f82551-a4d0-5b6e-b271-443e4999b945', 'Daša', 'A onda?', 'А потім?', 4);
  perform pg_temp.turn('05288790-9eaf-54c0-bcf7-7389c8c34d63', '07f82551-a4d0-5b6e-b271-443e4999b945', 'Ivan', 'Starom cestom do Karlovca, pa opet na autocestu.', 'Старою дорогою до Карловаца, а тоді знову на автостраду.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.8 · урок 53: Купуємо вживане авто — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'fb308628-6f9f-58c7-86bf-91bc5e469555';
  v_lesson constant uuid := '6a010148-5c1c-5e64-ab4a-c030b3adb969';
  v_gid constant uuid := '3a13fbe7-c0e4-55f8-b938-5579165e11bf';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KRET'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A2.8: місце 6 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 53: Купуємо вживане авто', 'Lekcija 53: Kupujemo rabljeni auto', '["Розпитати продавця про вживане авто й домовитися про ціну", "Дієслова руху: provozati se, dovesti auto na pregled, prepisati auto"]'::jsonb, 20, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'rabljeni auto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oglas za auto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijeđeni kilometri', v_pos);
  v_pos := pg_temp.word(v_lesson, 'servisna knjižica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prvi vlasnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'probna vožnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'provozati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupoprodajni ugovor za vozilo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijenos vlasništva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'porez na promet vozila', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fiksna cijena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spustiti cijenu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'benzinac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hrđa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udaren', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sajam automobila', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dovesti na pregled', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mehaničar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godina proizvodnje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pogađati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potrošnja goriva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'registriran do', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '5fb62889-e84b-55c9-8b77-238f08d81a09', 'fill_in_the_blank', 'Dovest ću auto na pregled, pa ćemo se ___.', 'provozati', '["izvozati", "provoziti", "dovozati", "provozati"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c6507e9d-e668-5daa-a264-adfc6df10da1', 'multiple_choice', 'Що означає «kupoprodajni ugovor za vozilo»?', 'договір купівлі-продажу авто', '["механік", "рік виробництва", "договір купівлі-продажу авто", "переоформлення власності"]'::jsonb, 'A2', 2, 'PUBLISHED', 'kupoprodajni ugovor za vozilo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '621e0aaf-250a-5cd1-b805-1d55fa0afd71', 'multiple_choice', 'Що означає «dovesti na pregled»?', 'пригнати на огляд', '["переоформлення власності", "фіксована ціна", "проїхатися", "пригнати на огляд"]'::jsonb, 'A2', 3, 'PUBLISHED', 'dovesti na pregled', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e900d767-5480-5c9e-82ec-cb37269c026c', 'multiple_choice', 'Що означає «godina proizvodnje»?', 'рік виробництва', '["проїхатися", "іржа", "договір купівлі-продажу авто", "рік виробництва"]'::jsonb, 'A2', 4, 'PUBLISHED', 'godina proizvodnje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd954e1e2-32a0-5f2a-a258-c3f1f4906a23', 'multiple_choice', 'Як хорватською «битий (після аварії)»?', 'udaren', '["registriran do", "prijeđeni kilometri", "udaren", "hrđa"]'::jsonb, 'A2', 5, 'PUBLISHED', 'udaren', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd0bb385f-ca7b-54c6-b711-968c1b8d7cc1', 'multiple_choice', 'Як хорватською «проїхатися»?', 'provozati se', '["prvi vlasnik", "porez na promet vozila", "registriran do", "provozati se"]'::jsonb, 'A2', 6, 'PUBLISHED', 'provozati se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aaff0fca-3786-5989-a24f-fc537494fea8', 'type_answer', 'Напишіть хорватською: «зареєстрований до»', 'registriran do', null, 'A2', 7, 'PUBLISHED', 'registriran do', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '70091648-ea60-54ec-899b-8f866345d24b', 'type_answer', 'Напишіть хорватською: «механік»', 'mehaničar', null, 'A2', 8, 'PUBLISHED', 'mehaničar', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '31cfd216-3890-5f61-85c6-3f2d578130e4', 'type_answer', 'Напишіть хорватською: «іржа»', 'hrđa', null, 'A2', 9, 'PUBLISHED', 'hrđa', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '17ba50c6-f2c9-5fa6-b51d-34b4673692c0', 'sentence_builder', 'Складіть: «Чи можу я поїхати на тест-драйв?»', 'Mogu li ići na probnu vožnju?', '["ići", "li", "probnu", "Mogu", "na", "vožnju?"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '773507ff-6448-5430-bffa-a6b495e591ec', 'sentence_builder', 'Складіть: «Під дверима трохи іржі.»', 'Ispod vrata ima malo hrđe.', '["hrđe.", "vrata", "ima", "malo", "Ispod"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd1ef305d-46ce-59b2-b097-e3997227c01b', 'listening', 'Прослухайте і складіть фразу', 'Prvi sam vlasnik i imam sve račune iz servisa.', '["imam", "Prvi", "i", "sam", "vlasnik", "račune", "iz", "sve", "servisa."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '7ee68688-aa80-555f-8540-c6b473f3c8d3', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'у суботу о 9:00; 6000; так, можна поговорити', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Продавець авто залишив вам повідомлення.", "script": [{"hr": "Dobar dan, ovdje Josip, zbog auta iz oglasa.", "ua": "Добрий день, це Йосип, щодо авто з оголошення."}, {"hr": "Može probna vožnja u subotu u devet ujutro.", "ua": "Можна тест-драйв у суботу о дев’ятій ранку."}, {"hr": "Cijena je šest tisuća eura, ali možemo razgovarati.", "ua": "Ціна шість тисяч євро, але можемо поговорити."}, {"hr": "Adresa je Ilica sto dvadeset.", "ua": "Адреса — Іліца, сто двадцять."}], "questions": [{"q_ua": "Коли тест-драйв?", "options": ["у суботу о 9:00", "у неділю о 10:00", "у п’ятницю ввечері"], "correct": 0, "answer_turn": 1}, {"q_ua": "Яка ціна (євро)?", "answer_text": "6000", "accept": ["6.000", "шість тисяч", "6 000"], "answer_turn": 2}, {"q_ua": "Чи можна торгуватися?", "options": ["ні, ціна фіксована", "так, можна поговорити", "лише при оплаті готівкою"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '7ee68688-aa80-555f-8540-c6b473f3c8d3', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fffd2522-77ee-5496-b681-ad4e452b3ee8', 'speaking', 'Ви перший власник?', 'Jeste li prvi vlasnik?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9553d8cf-bb53-53d2-bc83-0b3afc1d9d6b', 'speaking', 'Чи можете знизити ціну?', 'Možete li spustiti cijenu?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'c3062419-63c0-5553-97c5-9c3a812d25a7', 'write_message', 'Напишіть продавцеві: вас цікавить авто з оголошення; спитайте пробіг, чи є сервісна книжка і чи можна тест-драйв у суботу.', 'Dobar dan, zanima me auto iz oglasa. Koliko ima kilometara, imate li servisnu knjižicu i može li probna vožnja u subotu?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть продавцеві: вас цікавить авто з оголошення; спитайте пробіг, чи є сервісна книжка і чи можна тест-драйв у суботу.", "points": [{"ua": "цікавить авто", "keys": [["zanima"], ["oglas"]]}, {"ua": "пробіг", "keys": [["kilomet"]]}, {"ua": "сервісна книжка", "keys": [["servisn"]]}, {"ua": "тест-драйв у суботу", "keys": [["probn"], ["subot"]]}], "hints": ["zanima me auto iz oglasa", "koliko ima kilometara?", "servisna knjižica", "probna vožnja u subotu"], "models": ["Dobar dan, zanima me auto iz oglasa. Koliko ima kilometara, imate li servisnu knjižicu i može li probna vožnja u subotu?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'c3062419-63c0-5553-97c5-9c3a812d25a7', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '4655b8d8-71b8-5af1-baf4-11d9ff9e1141', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Auto nam se sviđa, ali dat ćemo petsto eura manje zbog hrđe.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи продавцеві, що авто нам подобається, але ми дамо на п’ятсот євро менше через іржу.", "direction": "ua_hr", "points": [{"ua": "подобається", "keys": [["sviđa"]]}, {"ua": "п’ятсот менше", "keys": [["petsto"]]}, {"ua": "через іржу", "keys": [["hrđ"]]}], "hints": [], "models": ["Auto nam se sviđa, ali dat ćemo petsto eura manje zbog hrđe."], "source_ua": "Скажи продавцеві, що авто нам подобається, але ми дамо на п’ятсот євро менше через іржу."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '4655b8d8-71b8-5af1-baf4-11d9ff9e1141', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3014b5a8-7cf0-5b0a-818f-4a1124f462cf', v_lesson, 'Дзвінок за оголошенням', 'Poziv na oglas', 5531, 'A2', 'car_service', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('4634e673-7434-5552-8796-8db310864870', '3014b5a8-7cf0-5b0a-818f-4a1124f462cf', 'Darja', 'Dobar dan, zovem zbog oglasa za auto. Je li još na prodaju?', 'Добрий день, дзвоню щодо оголошення про авто. Воно ще продається?', 1);
  perform pg_temp.turn('54547a78-63db-5e48-bacc-499d0451a245', '3014b5a8-7cf0-5b0a-818f-4a1124f462cf', 'Prodavač', 'Jest. Godište je dvije tisuće šesnaest, sto dvadeset tisuća kilometara.', 'Так. Рік випуску дві тисячі шістнадцятий, сто двадцять тисяч кілометрів.', 2);
  perform pg_temp.turn('194b0992-50e2-5cbb-bb3e-424c7788a3b5', '3014b5a8-7cf0-5b0a-818f-4a1124f462cf', 'Darja', 'Jeste li prvi vlasnik? Imate li servisnu knjižicu?', 'Ви перший власник? У вас є сервісна книжка?', 3);
  perform pg_temp.turn('d6035e6d-85b7-53bd-b074-11639f3c9d38', '3014b5a8-7cf0-5b0a-818f-4a1124f462cf', 'Prodavač', 'Prvi sam vlasnik i imam sve račune iz servisa.', 'Я перший власник, і в мене всі рахунки із сервісу.', 4);
  perform pg_temp.turn('bbfbf2b7-5a9b-5eea-bd4e-9d7f729a0eca', '3014b5a8-7cf0-5b0a-818f-4a1124f462cf', 'Darja', 'Je li auto ikad bio udaren?', 'Авто колись було бите?', 5);
  perform pg_temp.turn('f864c7c7-3e8f-5fef-ad03-a6d07f31c9e3', '3014b5a8-7cf0-5b0a-818f-4a1124f462cf', 'Prodavač', 'Nije. Dođite pa se provozajte.', 'Ні. Приїжджайте й проїдьтеся.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2e21e846-d671-5672-905c-395d9b734559', v_lesson, 'Торгуємося', 'Cjenkamo se', 5532, 'A2', 'car_service', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('64ec4858-7f3d-53e8-8573-2bd15f9b7639', '2e21e846-d671-5672-905c-395d9b734559', 'Ivan', 'Probna vožnja je bila dobra, ali ispod vrata ima hrđe.', 'Тест-драйв був добрий, але під дверима є іржа.', 1);
  perform pg_temp.turn('d4410558-e5ad-57ee-a571-acb2b02e02b4', '2e21e846-d671-5672-905c-395d9b734559', 'Prodavač', 'Malo, to nije ništa strašno.', 'Трохи, нічого страшного.', 2);
  perform pg_temp.turn('51d54f35-2f26-5d34-b11e-e18cda9c7a3d', '2e21e846-d671-5672-905c-395d9b734559', 'Ivan', 'Je li cijena fiksna? Biste li spustili cijenu za petsto eura?', 'Ціна фіксована? Чи не знизили б ви ціну на п’ятсот євро?', 3);
  perform pg_temp.turn('74db17ee-9a96-5c92-9f3f-594001542467', '2e21e846-d671-5672-905c-395d9b734559', 'Prodavač', 'Mogu za tristo. Ali prvo ga dovedite na pregled kod svog mehaničara.', 'Можу на триста. Але спершу пригоніть його на огляд до свого механіка.', 4);
  perform pg_temp.turn('ad39c176-7377-5711-9241-04709717e8de', '2e21e846-d671-5672-905c-395d9b734559', 'Ivan', 'Dogovoreno. Prijenos vlasništva radimo u petak.', 'Домовилися. Переоформлення робимо в п’ятницю.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- 3. Модуль і юніт — опубліковані
update public.modules set status = 'PUBLISHED', title_ua = 'Модуль A2.8 — Авто в Хорватії', title_hr = 'Modul A2.8 — Automobil u Hrvatskoj' where id = 'f72289b9-a174-5dd1-8cf6-553684bd120d';
update public.units set status = 'PUBLISHED' where id = 'fb308628-6f9f-58c7-86bf-91bc5e469555';

-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('d4af6240-036d-5046-9c4a-430b34a04c79', 'c689f4db-1707-535b-a2cd-0f244b663854', '306ddbde-6662-5d7e-8c58-eb2c2a17a504', 'dfa42285-bd22-5df8-bf4a-670f56911803', '161ebc1e-5359-551e-82a5-ddd878ceb97a', '6a010148-5c1c-5e64-ab4a-c030b3adb969')
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
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 20 or l.unit_id <> 'fb308628-6f9f-58c7-86bf-91bc5e469555');
  select count(*) into v_titles from (values ('d4af6240-036d-5046-9c4a-430b34a04c79'::uuid, 'Урок 48:%', 1), ('c689f4db-1707-535b-a2cd-0f244b663854'::uuid, 'Урок 49:%', 2), ('306ddbde-6662-5d7e-8c58-eb2c2a17a504'::uuid, 'Урок 50:%', 3), ('dfa42285-bd22-5df8-bf4a-670f56911803'::uuid, 'Урок 51:%', 4), ('161ebc1e-5359-551e-82a5-ddd878ceb97a'::uuid, 'Урок 52:%', 5), ('6a010148-5c1c-5e64-ab4a-c030b3adb969'::uuid, 'Урок 53:%', 6)) as t(id, pat, o)
    left join public.lessons l on l.id = t.id and l.title_ua like t.pat and l.order_index = t.o
   where l.id is null;
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
      where l.level_code = 'A2' and l.status = 'PUBLISHED' and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A2.8: % уроків з неправильним складом', v_bad; end if;
  if v_titles > 0 then raise exception 'Модуль A2.8: % уроків не на своєму місці чи з неправильним номером', v_titles; end if;
  if v_words > 0 then raise exception 'A2: % слів повторюються в кількох уроках', v_words; end if;
  if (select status from public.modules where id = 'f72289b9-a174-5dd1-8cf6-553684bd120d') <> 'PUBLISHED' then raise exception 'Модуль A2.8 не опубліковано'; end if;
  raise notice 'Готово: модуль A2.8 — 6 уроків, слів 129';
end $$;

commit;
