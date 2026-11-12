-- =====================================================================
-- Програма A2 v2 · модуль A2.9 «Неприємності в місті й довкілля» · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2.py 9 (не редагуйте вручну).
--
-- Рішення власника 2026-11-12: 20–25 нових слів на урок, 90–95 % слів — нові для рівня, діалоги під тему,
-- частіше Даша / Дар’я; «Прослухайте діалог чи оголошення» в кожному уроці; бета (PUBLISHED).
--   * Уроки 54–59 (6): слів у них 126. Кожен: 20–25 слів, 2 діалоги, 15 вправ
--     (одна — «Прослухайте діалог чи оголошення»), «Напишіть повідомлення» і «Перекажіть другу» (ua → hr, необов’язкові), 20 хв.
--   * Слова: 126 (нові — PUBLISHED; ті, що вже є в словнику, не змінюються).
--   * Модуль і юніт A2.9 → PUBLISHED. Потрібен уже запущений 20261112_curriculum_a2_v2_00_structure.sql.
--   * Нічого не видаляє. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.units where id = '688768a3-a672-54c7-a3df-60d408b8c210') then
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

-- 1. Слова уроків A2.9 (126): нові — PUBLISHED (бета); наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A2', t.ua, t.vtype, t.forms, t.examples, 'PUBLISHED', 'claude_curriculum_a2_v2'
  from jsonb_to_recordset('[{"lemma": "ured za izgubljene stvari", "normalized": "ured za izgubljene stvari", "pos": "phrase", "ua": "бюро знахідок", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ured za izgubljene stvari je u zgradi ZET-a."]}, {"lemma": "izgubljene stvari", "normalized": "izgubljene stvari", "pos": "phrase", "ua": "загублені речі", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Izgubljene stvari čuvaju se tri mjeseca."]}, {"lemma": "prijaviti gubitak", "normalized": "prijaviti gubitak", "pos": "phrase", "ua": "заявити про втрату", "vtype": "chunk", "forms": {}, "examples": ["Gubitak putovnice treba prijaviti policiji."]}, {"lemma": "pronaći", "normalized": "pronaci", "pos": "verb", "ua": "знайти", "vtype": "core", "forms": {"aspect": "pfv", "pair": "pronalaziti"}, "examples": ["Netko je pronašao moj novčanik!"]}, {"lemma": "pronalazač", "normalized": "pronalazac", "pos": "noun", "ua": "той, хто знайшов", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Pronalazač je dobio nagradu."]}, {"lemma": "vratiti vlasniku", "normalized": "vratiti vlasniku", "pos": "phrase", "ua": "повернути власникові", "vtype": "chunk", "forms": {}, "examples": ["Novčanik su vratili vlasniku."]}, {"lemma": "ostaviti negdje", "normalized": "ostaviti negdje", "pos": "phrase", "ua": "залишити десь", "vtype": "chunk", "forms": {}, "examples": ["Mora da sam ga ostavila negdje u tramvaju."]}, {"lemma": "blokirati karticu", "normalized": "blokirati karticu", "pos": "phrase", "ua": "заблокувати картку", "vtype": "chunk", "forms": {}, "examples": ["Odmah sam blokirala karticu."]}, {"lemma": "kartica je ukradena", "normalized": "kartica je ukradena", "pos": "phrase", "ua": "картку вкрали", "vtype": "chunk", "forms": {}, "examples": ["Mislim da mi je kartica ukradena."]}, {"lemma": "prijava krađe", "normalized": "prijava krade", "pos": "phrase", "ua": "заява про крадіжку", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za osiguranje trebam prijavu krađe."]}, {"lemma": "smeđ", "normalized": "smed", "pos": "adjective", "ua": "коричневий", "vtype": "core", "forms": {}, "examples": ["Novčanik je smeđ i kožni."]}, {"lemma": "kišobran", "normalized": "kisobran", "pos": "noun", "ua": "парасолька", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Kišobrani se najčešće zaboravljaju."]}, {"lemma": "u tramvajima", "normalized": "u tramvajima", "pos": "phrase", "ua": "у трамваях", "vtype": "chunk", "forms": {}, "examples": ["U tramvajima ljudi često zaborave kišobrane."]}, {"lemma": "s dokumentima", "normalized": "s dokumentima", "pos": "phrase", "ua": "з документами", "vtype": "chunk", "forms": {}, "examples": ["Izgubila sam torbu s dokumentima."]}, {"lemma": "po džepovima", "normalized": "po dzepovima", "pos": "phrase", "ua": "по кишенях", "vtype": "chunk", "forms": {}, "examples": ["Tražila sam ključeve po svim džepovima."]}, {"lemma": "obrazac za prijavu", "normalized": "obrazac za prijavu", "pos": "phrase", "ua": "бланк заяви", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ispunite obrazac za prijavu gubitka."]}, {"lemma": "javiti se ako se nađe", "normalized": "javiti se ako se nade", "pos": "phrase", "ua": "повідомити, якщо знайдеться", "vtype": "chunk", "forms": {}, "examples": ["Javit ćemo Vam se ako se nađe."]}, {"lemma": "osobne stvari", "normalized": "osobne stvari", "pos": "phrase", "ua": "особисті речі", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Osobne stvari čuvajte uz sebe."]}, {"lemma": "gubitak", "normalized": "gubitak", "pos": "noun", "ua": "втрата", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Gubitak dokumenata je velika gnjavaža."]}, {"lemma": "nestati bez traga", "normalized": "nestati bez traga", "pos": "phrase", "ua": "зникнути без сліду", "vtype": "chunk", "forms": {}, "examples": ["Novčanik je nestao bez traga."]}, {"lemma": "privjesak za ključeve", "normalized": "privjesak za kljuceve", "pos": "phrase", "ua": "брелок для ключів", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ključevi su na crvenom privjesku za ključeve."]}, {"lemma": "odvajanje otpada", "normalized": "odvajanje otpada", "pos": "phrase", "ua": "сортування сміття", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Odvajanje otpada je obvezno u cijelom gradu."]}, {"lemma": "odvajati", "normalized": "odvajati", "pos": "verb", "ua": "сортувати, відокремлювати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Odvajamo papir, plastiku i staklo."]}, {"lemma": "reciklirati", "normalized": "reciklirati", "pos": "verb", "ua": "переробляти", "vtype": "core", "forms": {"aspect": "biasp"}, "examples": ["Staklo se može reciklirati bez kraja."]}, {"lemma": "ambalaža", "normalized": "ambalaza", "pos": "noun", "ua": "упаковка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Plastična ambalaža ide u žutu vreću."]}, {"lemma": "plastika", "normalized": "plastika", "pos": "noun", "ua": "пластик", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Plastiku treba oprati prije bacanja."]}, {"lemma": "staklo", "normalized": "staklo", "pos": "noun", "ua": "скло", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Staklo se baca u zeleni spremnik."]}, {"lemma": "metal", "normalized": "metal", "pos": "noun", "ua": "метал", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Limenke su metal, idu zajedno s plastikom."]}, {"lemma": "biootpad", "normalized": "biootpad", "pos": "noun", "ua": "біовідходи", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ostatke hrane bacamo u biootpad."]}, {"lemma": "miješani komunalni otpad", "normalized": "mijesani komunalni otpad", "pos": "phrase", "ua": "змішані побутові відходи", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Pelene idu u miješani komunalni otpad."]}, {"lemma": "spremnik", "normalized": "spremnik", "pos": "noun", "ua": "контейнер", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Plavi spremnik je za papir."]}, {"lemma": "zeleni otok", "normalized": "zeleni otok", "pos": "phrase", "ua": "майданчик з контейнерами для сортування", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Zeleni otok je na uglu ulice."]}, {"lemma": "žuta vreća", "normalized": "zuta vreca", "pos": "phrase", "ua": "жовтий мішок (для пластику)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Žute vreće dobivate u komunalnom poduzeću."]}, {"lemma": "limenka", "normalized": "limenka", "pos": "noun", "ua": "бляшанка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Limenke od piva idu u žutu vreću."]}, {"lemma": "boca", "normalized": "boca", "pos": "noun", "ua": "пляшка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Plastične boce možete vratiti u trgovinu."]}, {"lemma": "povratna naknada", "normalized": "povratna naknada", "pos": "phrase", "ua": "повернення застави за тару", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za svaku bocu dobijete povratnu naknadu."]}, {"lemma": "zgnječiti", "normalized": "zgnjeciti", "pos": "verb", "ua": "зім’яти, сплющити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "gnječiti"}, "examples": ["Zgnječite boce da zauzmu manje mjesta."]}, {"lemma": "ostaci hrane", "normalized": "ostaci hrane", "pos": "phrase", "ua": "залишки їжі", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Ostaci hrane ne idu u plastiku."]}, {"lemma": "raspored odvoza", "normalized": "raspored odvoza", "pos": "phrase", "ua": "графік вивезення сміття", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Raspored odvoza je na stranici grada."]}, {"lemma": "kazna za neodvajanje", "normalized": "kazna za neodvajanje", "pos": "phrase", "ua": "штраф за несортування", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Postoji i kazna za neodvajanje otpada."]}, {"lemma": "u spremnicima", "normalized": "u spremnicima", "pos": "phrase", "ua": "у контейнерах", "vtype": "chunk", "forms": {}, "examples": ["U spremnicima za papir često ima plastike."]}, {"lemma": "okolišno", "normalized": "okolisno", "pos": "adverb", "ua": "екологічно", "vtype": "core", "forms": {}, "examples": ["Živimo okolišno odgovorno."]}, {"lemma": "tetrapak", "normalized": "tetrapak", "pos": "noun", "ua": "тетрапак (упаковка з-під молока, соку)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Tetrapak od mlijeka ide u žutu vreću."]}, {"lemma": "glomazni otpad", "normalized": "glomazni otpad", "pos": "phrase", "ua": "великогабаритні відходи", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Glomazni otpad se odvozi jednom godišnje besplatno."]}, {"lemma": "naručiti odvoz", "normalized": "naruciti odvoz", "pos": "phrase", "ua": "замовити вивезення", "vtype": "chunk", "forms": {}, "examples": ["Naručila sam odvoz starog kauča."]}, {"lemma": "reciklažno dvorište", "normalized": "reciklazno dvoriste", "pos": "phrase", "ua": "пункт приймання вторсировини", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Staru perilicu sam odvezla u reciklažno dvorište."]}, {"lemma": "stari namještaj", "normalized": "stari namjestaj", "pos": "phrase", "ua": "старі меблі", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Stari namještaj ostavite ispred zgrade navečer."]}, {"lemma": "elektronički otpad", "normalized": "elektronicki otpad", "pos": "phrase", "ua": "електронні відходи", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Elektronički otpad ne ide u običnu kantu."]}, {"lemma": "istrošene baterije", "normalized": "istrosene baterije", "pos": "phrase", "ua": "використані батарейки", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Istrošene baterije vratite u trgovinu."]}, {"lemma": "opasni otpad", "normalized": "opasni otpad", "pos": "phrase", "ua": "небезпечні відходи", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Boje i lakovi su opasni otpad."]}, {"lemma": "komunalno poduzeće", "normalized": "komunalno poduzece", "pos": "phrase", "ua": "комунальне підприємство", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Nazvala sam komunalno poduzeće."]}, {"lemma": "rupa na cesti", "normalized": "rupa na cesti", "pos": "phrase", "ua": "яма на дорозі", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U našoj ulici je velika rupa na cesti."]}, {"lemma": "pokvarena rasvjeta", "normalized": "pokvarena rasvjeta", "pos": "phrase", "ua": "несправне освітлення", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Javna rasvjeta je pokvarena već tjedan dana."]}, {"lemma": "javna rasvjeta", "normalized": "javna rasvjeta", "pos": "phrase", "ua": "вуличне освітлення", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Javna rasvjeta se pali u sumrak."]}, {"lemma": "divlje odlagalište", "normalized": "divlje odlagaliste", "pos": "phrase", "ua": "стихійне звалище", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Iza šume je divlje odlagalište."]}, {"lemma": "prijaviti problem", "normalized": "prijaviti problem", "pos": "phrase", "ua": "повідомити про проблему", "vtype": "chunk", "forms": {}, "examples": ["Problem možete prijaviti u aplikaciji grada."]}, {"lemma": "aplikacija grada", "normalized": "aplikacija grada", "pos": "phrase", "ua": "міський застосунок", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Preko aplikacije grada prijavila sam rupu."]}, {"lemma": "besplatno jednom godišnje", "normalized": "besplatno jednom godisnje", "pos": "phrase", "ua": "раз на рік безкоштовно", "vtype": "chunk", "forms": {}, "examples": ["Odvoz je besplatno jednom godišnje."]}, {"lemma": "kauč", "normalized": "kauc", "pos": "noun", "ua": "диван", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Stari kauč je pun prašine."]}, {"lemma": "raskrčiti", "normalized": "raskrciti", "pos": "verb", "ua": "розчистити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "krčiti"}, "examples": ["Treba raskrčiti podrum."]}, {"lemma": "nagomilati se", "normalized": "nagomilati se", "pos": "verb", "ua": "накопичитися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "gomilati se"}, "examples": ["Na balkonu se nagomilalo puno stvari."]}, {"lemma": "ispred zgrade", "normalized": "ispred zgrade", "pos": "phrase", "ua": "перед будинком", "vtype": "chunk", "forms": {}, "examples": ["Kauč smo ostavili ispred zgrade."]}, {"lemma": "u ulicama", "normalized": "u ulicama", "pos": "phrase", "ua": "на вулицях", "vtype": "chunk", "forms": {}, "examples": ["U ulicama starog grada nema kontejnera."]}, {"lemma": "okoliš", "normalized": "okolis", "pos": "noun", "ua": "довкілля", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Moramo čuvati okoliš."]}, {"lemma": "zaštita okoliša", "normalized": "zastita okolisa", "pos": "phrase", "ua": "охорона довкілля", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Zaštita okoliša tema je u školi."]}, {"lemma": "onečišćenje", "normalized": "oneciscenje", "pos": "noun", "ua": "забруднення", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Onečišćenje mora je veliki problem."]}, {"lemma": "klimatske promjene", "normalized": "klimatske promjene", "pos": "phrase", "ua": "зміна клімату", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Klimatske promjene osjećamo svako ljeto."]}, {"lemma": "kvaliteta zraka", "normalized": "kvaliteta zraka", "pos": "phrase", "ua": "якість повітря", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Zimi je kvaliteta zraka u gradu lošija."]}, {"lemma": "štedjeti vodu", "normalized": "stedjeti vodu", "pos": "phrase", "ua": "заощаджувати воду", "vtype": "chunk", "forms": {}, "examples": ["Ljeti na otocima treba štedjeti vodu."]}, {"lemma": "štedjeti struju", "normalized": "stedjeti struju", "pos": "phrase", "ua": "заощаджувати електроенергію", "vtype": "chunk", "forms": {}, "examples": ["Štedimo struju i gasimo svjetla."]}, {"lemma": "platnena vrećica", "normalized": "platnena vrecica", "pos": "phrase", "ua": "полотняна сумка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U trgovinu nosim platnenu vrećicu."]}, {"lemma": "jednokratan", "normalized": "jednokratan", "pos": "adjective", "ua": "одноразовий", "vtype": "core", "forms": {}, "examples": ["Jednokratna plastika je zabranjena na plažama."]}, {"lemma": "višekratan", "normalized": "visekratan", "pos": "adjective", "ua": "багаторазовий", "vtype": "core", "forms": {}, "examples": ["Kupila sam višekratnu bocu za vodu."]}, {"lemma": "solarni paneli", "normalized": "solarni paneli", "pos": "phrase", "ua": "сонячні панелі", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Na krovu imamo solarne panele."]}, {"lemma": "obnovljivi izvori energije", "normalized": "obnovljivi izvori energije", "pos": "phrase", "ua": "відновлювані джерела енергії", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Hrvatska ulaže u obnovljive izvore energije."]}, {"lemma": "šuma", "normalized": "suma", "pos": "noun", "ua": "ліс", "vtype": "core", "forms": {"gender": "f"}, "examples": ["U šumama oko grada ima puno smeća."]}, {"lemma": "čišćenje plaže", "normalized": "ciscenje plaze", "pos": "phrase", "ua": "прибирання пляжу", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["U subotu je akcija čišćenja plaže."]}, {"lemma": "ekološka akcija", "normalized": "ekoloska akcija", "pos": "phrase", "ua": "екологічна акція", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na ekološkoj akciji smo skupili sto vreća smeća."]}, {"lemma": "ugrožen", "normalized": "ugrozen", "pos": "adjective", "ua": "під загрозою, зникаючий", "vtype": "core", "forms": {}, "examples": ["Morska kornjača je ugrožena vrsta."]}, {"lemma": "vrsta", "normalized": "vrsta", "pos": "noun", "ua": "вид (тварин, рослин)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["U parku živi više od sto vrsta ptica."]}, {"lemma": "bacati smeće", "normalized": "bacati smece", "pos": "phrase", "ua": "смітити", "vtype": "chunk", "forms": {}, "examples": ["Zabranjeno je bacati smeće u prirodu."]}, {"lemma": "ekološki osviješten", "normalized": "ekoloski osvijesten", "pos": "phrase", "ua": "екологічно свідомий", "vtype": "chunk", "forms": {}, "examples": ["Mladi su danas ekološki osviješteniji."]}, {"lemma": "s volonterima", "normalized": "s volonterima", "pos": "phrase", "ua": "з волонтерами", "vtype": "chunk", "forms": {}, "examples": ["Plažu smo očistili s volonterima."]}, {"lemma": "u rijekama", "normalized": "u rijekama", "pos": "phrase", "ua": "у річках", "vtype": "chunk", "forms": {}, "examples": ["U rijekama je sve manje ribe."]}, {"lemma": "meteoalarm", "normalized": "meteoalarm", "pos": "noun", "ua": "метеопопередження", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Za Dalmaciju je izdan meteoalarm."]}, {"lemma": "crveno upozorenje", "normalized": "crveno upozorenje", "pos": "phrase", "ua": "червоний рівень небезпеки", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Na snazi je crveno upozorenje zbog vrućine."]}, {"lemma": "narančasto upozorenje", "normalized": "narancasto upozorenje", "pos": "phrase", "ua": "помаранчевий рівень небезпеки", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Narančasto upozorenje vrijedi do večeri."]}, {"lemma": "olujni vjetar", "normalized": "olujni vjetar", "pos": "phrase", "ua": "штормовий вітер", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Olujni vjetar je srušio drveće."]}, {"lemma": "tuča", "normalized": "tuca", "pos": "noun", "ua": "град (опади)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Tuča je oštetila automobile."]}, {"lemma": "bujica", "normalized": "bujica", "pos": "noun", "ua": "бурхливий потік (після зливи)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Bujica je odnijela most."]}, {"lemma": "šumski požar", "normalized": "sumski pozar", "pos": "phrase", "ua": "лісова пожежа", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Šumski požar je blizu sela."]}, {"lemma": "vatrogasci", "normalized": "vatrogasci", "pos": "noun", "ua": "пожежники", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Vatrogasci su cijelu noć gasili požar."]}, {"lemma": "kanader", "normalized": "kanader", "pos": "noun", "ua": "канадер (протипожежний літак)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Kanaderi gase požar iz zraka."]}, {"lemma": "zabrana loženja vatre", "normalized": "zabrana lozenja vatre", "pos": "phrase", "ua": "заборона розпалювати вогонь", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Ljeti vrijedi zabrana loženja vatre."]}, {"lemma": "ugroženo područje", "normalized": "ugrozeno podrucje", "pos": "phrase", "ua": "зона небезпеки", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Napustite ugroženo područje."]}, {"lemma": "skloniti se", "normalized": "skloniti se", "pos": "verb", "ua": "сховатися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "sklanjati se"}, "examples": ["Sklonite se u zatvoreni prostor."]}, {"lemma": "izbjegavati", "normalized": "izbjegavati", "pos": "verb", "ua": "уникати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Izbjegavajte sunce od jedanaest do sedamnaest."]}, {"lemma": "pitka voda", "normalized": "pitka voda", "pos": "phrase", "ua": "питна вода", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Uvijek imajte uz sebe pitku vodu."]}, {"lemma": "starije osobe", "normalized": "starije osobe", "pos": "phrase", "ua": "літні люди", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Starije osobe ne bi trebale izlaziti po vrućini."]}, {"lemma": "nestanak struje", "normalized": "nestanak struje", "pos": "phrase", "ua": "відключення світла", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Zbog oluje je nestanak struje."]}, {"lemma": "srušeno stablo", "normalized": "sruseno stablo", "pos": "phrase", "ua": "повалене дерево", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Srušeno stablo blokira cestu."]}, {"lemma": "evakuirati", "normalized": "evakuirati", "pos": "verb", "ua": "евакуювати", "vtype": "core", "forms": {"aspect": "biasp"}, "examples": ["Evakuirali su turiste iz kampa."]}, {"lemma": "na cestama", "normalized": "na cestama", "pos": "phrase", "ua": "на дорогах", "vtype": "chunk", "forms": {}, "examples": ["Na cestama je puno vode."]}, {"lemma": "u kućama", "normalized": "u kucama", "pos": "phrase", "ua": "у будинках", "vtype": "chunk", "forms": {}, "examples": ["Ljudi su ostali u kućama."]}, {"lemma": "hitne službe", "normalized": "hitne sluzbe", "pos": "phrase", "ua": "екстрені служби", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["U hitnom slučaju nazovite hitne službe na 112."]}, {"lemma": "biljka", "normalized": "biljka", "pos": "noun", "ua": "рослина", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Na balkonu imam desetak biljaka."]}, {"lemma": "cvijeće", "normalized": "cvijece", "pos": "noun", "ua": "квіти", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Mama obožava cvijeće."]}, {"lemma": "lonac za cvijeće", "normalized": "lonac za cvijece", "pos": "phrase", "ua": "вазон", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Kupila sam novi lonac za cvijeće."]}, {"lemma": "saditi", "normalized": "saditi", "pos": "verb", "ua": "садити", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "posaditi"}, "examples": ["U travnju sadimo rajčice."]}, {"lemma": "posaditi", "normalized": "posaditi", "pos": "verb", "ua": "посадити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "saditi"}, "examples": ["Posadili smo masline u dvorištu."]}, {"lemma": "sjeme", "normalized": "sjeme", "pos": "noun", "ua": "насіння", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Sjeme sam kupila na tržnici."]}, {"lemma": "začinsko bilje", "normalized": "zacinsko bilje", "pos": "phrase", "ua": "пряні трави", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Na prozoru uzgajam začinsko bilje."]}, {"lemma": "bosiljak", "normalized": "bosiljak", "pos": "noun", "ua": "базилік", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Bosiljak voli sunce."]}, {"lemma": "ružmarin", "normalized": "ruzmarin", "pos": "noun", "ua": "розмарин", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ružmarin raste uz svaku kuću na moru."]}, {"lemma": "lavanda", "normalized": "lavanda", "pos": "noun", "ua": "лаванда", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Na Hvaru su polja lavande."]}, {"lemma": "maslina", "normalized": "maslina", "pos": "noun", "ua": "оливкове дерево; оливка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ova maslina je stara sto godina."]}, {"lemma": "uzgajati", "normalized": "uzgajati", "pos": "verb", "ua": "вирощувати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Uzgajamo povrće za sebe."]}, {"lemma": "kompost", "normalized": "kompost", "pos": "noun", "ua": "компост", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Od ostataka hrane radimo kompost."]}, {"lemma": "zemlja za cvijeće", "normalized": "zemlja za cvijece", "pos": "phrase", "ua": "ґрунт для квітів", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Treba nam vreća zemlje za cvijeće."]}, {"lemma": "orezati", "normalized": "orezati", "pos": "verb", "ua": "обрізати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "orezivati"}, "examples": ["Ruže treba orezati u proljeće."]}, {"lemma": "korov", "normalized": "korov", "pos": "noun", "ua": "бур’ян", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Vikendom čupamo korov."]}, {"lemma": "cvjetati", "normalized": "cvjetati", "pos": "verb", "ua": "цвісти", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Lavanda cvjeta u lipnju."]}, {"lemma": "uvenuti", "normalized": "uvenuti", "pos": "verb", "ua": "зів’янути", "vtype": "core", "forms": {"aspect": "pfv", "pair": "venuti"}, "examples": ["Dok smo bili na moru, biljke su uvenule."]}, {"lemma": "zalijevanje", "normalized": "zalijevanje", "pos": "noun", "ua": "полив", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Ljeti je zalijevanje navečer najbolje."]}, {"lemma": "vrtlarski centar", "normalized": "vrtlarski centar", "pos": "phrase", "ua": "садовий центр", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["U vrtlarskom centru imaju sve za balkon."]}, {"lemma": "s biljkama", "normalized": "s biljkama", "pos": "phrase", "ua": "з рослинами", "vtype": "chunk", "forms": {}, "examples": ["Balkon s biljkama je kao mali vrt."]}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 2. Уроки модуля A2.9
-- A2.9 · урок 54: Загубив гаманець: бюро знахідок — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '688768a3-a672-54c7-a3df-60d408b8c210';
  v_lesson constant uuid := '6c0efc81-fd32-55c6-8e57-b1885e387093';
  v_gid constant uuid := '6de8bf6e-97a1-5cb3-8e31-538b07c36309';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики PL'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A2.9: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 54: Загубив гаманець: бюро знахідок', 'Lekcija 54: Izgubio sam novčanik: ured za izgubljene stvari', '["Заявити про загублену річ і описати її", "Множина D / L / I: u tramvajima, s dokumentima, po džepovima"]'::jsonb, 20, 'PUBLISHED', 1);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'ured za izgubljene stvari', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izgubljene stvari', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijaviti gubitak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pronaći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pronalazač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vratiti vlasniku', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ostaviti negdje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blokirati karticu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kartica je ukradena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijava krađe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smeđ', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kišobran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u tramvajima', v_pos);
  v_pos := pg_temp.word(v_lesson, 's dokumentima', v_pos);
  v_pos := pg_temp.word(v_lesson, 'po džepovima', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obrazac za prijavu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'javiti se ako se nađe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osobne stvari', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gubitak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nestati bez traga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'privjesak za ključeve', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '079c2a51-9481-5e94-9357-0ec7d70b00f8', 'fill_in_the_blank', 'U ___ ljudi često zaborave kišobrane.', 'tramvajima', '["tramvaja", "tramvaje", "tramvaji", "tramvajima"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '69cbf5a8-b49c-5900-a4dc-8f247b685141', 'multiple_choice', 'Що означає «blokirati karticu»?', 'заблокувати картку', '["заблокувати картку", "знайти", "загублені речі", "залишити десь"]'::jsonb, 'A2', 2, 'PUBLISHED', 'blokirati karticu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '426c2dd4-c588-59ef-8301-a353ba25eeab', 'multiple_choice', 'Що означає «osobne stvari»?', 'особисті речі', '["особисті речі", "бюро знахідок", "той, хто знайшов", "втрата"]'::jsonb, 'A2', 3, 'PUBLISHED', 'osobne stvari', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd27f85f5-34c9-53e9-992a-96d900bdc588', 'multiple_choice', 'Що означає «prijava krađe»?', 'заява про крадіжку', '["з документами", "у трамваях", "той, хто знайшов", "заява про крадіжку"]'::jsonb, 'A2', 4, 'PUBLISHED', 'prijava krađe', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e35998e4-bcc6-5c2d-850c-449b6e5555f5', 'multiple_choice', 'Як хорватською «по кишенях»?', 'po džepovima', '["obrazac za prijavu", "javiti se ako se nađe", "po džepovima", "gubitak"]'::jsonb, 'A2', 5, 'PUBLISHED', 'po džepovima', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a969cf01-232d-53b3-b5b8-ebe6b0fe396c', 'multiple_choice', 'Як хорватською «знайти»?', 'pronaći', '["javiti se ako se nađe", "smeđ", "prijava krađe", "pronaći"]'::jsonb, 'A2', 6, 'PUBLISHED', 'pronaći', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fda855d5-d34c-5e2f-ae5c-ae4a611708cc', 'type_answer', 'Напишіть хорватською: «коричневий»', 'smeđ', null, 'A2', 7, 'PUBLISHED', 'smeđ', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eee608bf-6f72-5252-acb8-39bf35bf777b', 'type_answer', 'Напишіть хорватською: «з документами»', 's dokumentima', null, 'A2', 8, 'PUBLISHED', 's dokumentima', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8fea4123-8cf3-5b27-b670-730f40ad8919', 'type_answer', 'Напишіть хорватською: «у трамваях»', 'u tramvajima', null, 'A2', 9, 'PUBLISHED', 'u tramvajima', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f09b42f1-3305-5889-9dfe-2e8656a90d1a', 'sentence_builder', 'Складіть: «Я одразу заблокувала картку.»', 'Odmah sam blokirala karticu.', '["sam", "blokirala", "karticu.", "Odmah"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '35b9f172-7027-5f2a-a57e-155c0432b063', 'sentence_builder', 'Складіть: «Я загубила сумку з документами.»', 'Izgubila sam torbu s dokumentima.', '["sam", "s", "Izgubila", "torbu", "dokumentima."]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7f4f0636-ea89-58bb-97ad-2a3074775396', 'listening', 'Прослухайте і складіть фразу', 'I ona je u novčaniku. Moram prijaviti gubitak policiji.', '["u", "policiji.", "novčaniku.", "ona", "I", "Moram", "gubitak", "prijaviti", "je"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'c183a154-ada3-500f-a66f-69143a3f55f9', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'коричневий рюкзак; посвідчення особи; 15', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Вам телефонували з бюро знахідок.", "script": [{"hr": "Dobar dan, zovem iz ureda za izgubljene stvari.", "ua": "Добрий день, телефоную з бюро знахідок."}, {"hr": "Pronađen je smeđi ruksak s Vašim imenom.", "ua": "Знайдено коричневий рюкзак з вашим ім’ям."}, {"hr": "Možete ga preuzeti do petka, uz osobnu iskaznicu.", "ua": "Можете забрати його до п’ятниці з посвідченням особи."}, {"hr": "Radimo od osam do petnaest sati.", "ua": "Ми працюємо з восьмої до п’ятнадцятої."}], "questions": [{"q_ua": "Що знайшли?", "options": ["коричневий рюкзак", "гаманець", "парасольку"], "correct": 0, "answer_turn": 1}, {"q_ua": "Що треба взяти?", "options": ["квитанцію", "посвідчення особи", "гроші"], "correct": 1, "answer_turn": 2}, {"q_ua": "До котрої працює бюро?", "answer_text": "15", "accept": ["15:00", "15.00", "п’ятнадцятої"], "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'c183a154-ada3-500f-a66f-69143a3f55f9', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '66bf0ee2-d62b-5f9d-919c-2117dda6838f', 'speaking', 'Я загубив гаманець.', 'Izgubio sam novčanik.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aae677ef-81e1-5f8f-95df-4dec96c02a32', 'speaking', 'Він коричневий і шкіряний.', 'Smeđ je i kožni.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '61705647-d49d-5e4d-8161-be7f93538af2', 'write_message', 'Напишіть у бюро знахідок: ви вчора загубили чорну парасольку й зарядку в автобусі № 12.', 'Poštovani, jučer sam u autobusu broj 12 izgubila crni kišobran i punjač. Jesu li možda pronađeni?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у бюро знахідок: ви вчора загубили чорну парасольку й зарядку в автобусі № 12.", "points": [{"ua": "загубили", "keys": [["izgubi"], ["ostavi"]]}, {"ua": "парасолька", "keys": [["kišobran"]]}, {"ua": "зарядка", "keys": [["punjač"]]}, {"ua": "автобус 12", "keys": [["12"]]}], "hints": ["jučer sam izgubila", "crni kišobran", "punjač", "u autobusu broj 12"], "models": ["Poštovani, jučer sam u autobusu broj 12 izgubila crni kišobran i punjač. Jesu li možda pronađeni?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '61705647-d49d-5e4d-8161-be7f93538af2', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'c3c3fcf7-9c76-5332-85f6-893ef054713a', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'U njegovom ruksaku su bili laptop i putovnica.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи в бюро знахідок, що в моєму рюкзаку були ноутбук і паспорт.", "direction": "ua_hr", "points": [{"ua": "рюкзак", "keys": [["ruksak"]]}, {"ua": "ноутбук", "keys": [["laptop"], ["prijenosn"]]}, {"ua": "паспорт", "keys": [["putovnic"]]}], "hints": [], "models": ["U njegovom ruksaku su bili laptop i putovnica."], "source_ua": "Скажи в бюро знахідок, що в моєму рюкзаку були ноутбук і паспорт."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'c3c3fcf7-9c76-5332-85f6-893ef054713a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f6a748bd-ccdd-5754-88bd-4645f5563f01', v_lesson, 'У бюро знахідок', 'U uredu za izgubljene stvari', 5541, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('24a31206-da55-5430-a34b-a0d9bace83e5', 'f6a748bd-ccdd-5754-88bd-4645f5563f01', 'Ivan', 'Dobar dan, jučer sam izgubio novčanik. Mislim da sam ga ostavio u tramvaju.', 'Добрий день, учора я загубив гаманець. Думаю, що залишив його в трамваї.', 1);
  perform pg_temp.turn('1a1bb5e4-1d46-5e31-827c-f7a4a838bc32', 'f6a748bd-ccdd-5754-88bd-4645f5563f01', 'Službenica', 'Možete li ga opisati?', 'Можете його описати?', 2);
  perform pg_temp.turn('0dd22c60-5e24-511a-b087-1d22f4f41926', 'f6a748bd-ccdd-5754-88bd-4645f5563f01', 'Ivan', 'Smeđ je, kožni, s dokumentima i karticama.', 'Він коричневий, шкіряний, з документами й картками.', 3);
  perform pg_temp.turn('dfbeee90-b618-59c3-9a13-077dd2fdb7e4', 'f6a748bd-ccdd-5754-88bd-4645f5563f01', 'Službenica', 'Pogledat ću. U tramvajima svaki dan pronađemo puno novčanika.', 'Я подивлюся. У трамваях щодня ми знаходимо багато гаманців.', 4);
  perform pg_temp.turn('fb8441ee-a6ad-5359-90bb-aa362af8d7b8', 'f6a748bd-ccdd-5754-88bd-4645f5563f01', 'Ivan', 'Jeste li ga pronašli?', 'Ви його знайшли?', 5);
  perform pg_temp.turn('6126cde1-d7e2-5651-bd69-51713f64664f', 'f6a748bd-ccdd-5754-88bd-4645f5563f01', 'Službenica', 'Još nije stigao. Ispunite obrazac, javit ćemo Vam se ako se nađe.', 'Ще не надійшов. Заповніть бланк, ми повідомимо вас, якщо знайдеться.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('bb42ca2a-7080-58a0-b36b-e6b6e4f99955', v_lesson, 'Картки', 'Kartice', 5542, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('a28645b6-eb22-5678-b3bb-0c6b549badc6', 'bb42ca2a-7080-58a0-b36b-e6b6e4f99955', 'Daša', 'Jesi li blokirao kartice?', 'Ти заблокував картки?', 1);
  perform pg_temp.turn('f0a666f3-37fc-5a41-b259-6ce3f19fbc60', 'bb42ca2a-7080-58a0-b36b-e6b6e4f99955', 'Ivan', 'Jesam, odmah. Srećom, novac je bio u drugom džepu.', 'Так, одразу. На щастя, гроші були в іншій кишені.', 2);
  perform pg_temp.turn('6d8b8ea3-9543-56c1-85cb-c6006a423dad', 'bb42ca2a-7080-58a0-b36b-e6b6e4f99955', 'Daša', 'A osobna iskaznica?', 'А посвідчення особи?', 3);
  perform pg_temp.turn('7c71eb8f-2370-528c-9d51-8f080c1f4b42', 'bb42ca2a-7080-58a0-b36b-e6b6e4f99955', 'Ivan', 'I ona je u novčaniku. Moram prijaviti gubitak policiji.', 'Воно теж у гаманці. Мушу заявити про втрату в поліцію.', 4);
  perform pg_temp.turn('f14ce230-c916-5e7d-814b-87ebc38c5465', 'bb42ca2a-7080-58a0-b36b-e6b6e4f99955', 'Daša', 'Pričekaj dan-dva. Možda ga netko vrati vlasniku.', 'Почекай день-два. Може, хтось поверне його власникові.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.9 · урок 55: Сортування сміття — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '688768a3-a672-54c7-a3df-60d408b8c210';
  v_lesson constant uuid := '8d6a1367-0183-5c35-b6df-ddfbe23a4152';
  v_gid constant uuid := '6de8bf6e-97a1-5cb3-8e31-538b07c36309';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики PL'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A2.9: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 55: Сортування сміття', 'Lekcija 55: Odvajanje otpada', '["Правильно сортувати сміття: папір, пластик, скло, біовідходи", "Множина: u spremnicima, s vrećicama, na zelenim otocima"]'::jsonb, 20, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'odvajanje otpada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odvajati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'reciklirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ambalaža', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plastika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'staklo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'metal', v_pos);
  v_pos := pg_temp.word(v_lesson, 'biootpad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'miješani komunalni otpad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spremnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zeleni otok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žuta vreća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'limenka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'boca', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povratna naknada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zgnječiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ostaci hrane', v_pos);
  v_pos := pg_temp.word(v_lesson, 'raspored odvoza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kazna za neodvajanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u spremnicima', v_pos);
  v_pos := pg_temp.word(v_lesson, 'okolišno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tetrapak', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b71aabc-1300-5bc6-b1d3-d59e063c51ac', 'fill_in_the_blank', 'U ___ za papir često ima plastike.', 'spremnicima', '["spremnici", "spremnicima", "spremnike", "spremnika"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'df933644-aec9-552e-a796-0a8d1924bdcb', 'multiple_choice', 'Що означає «odvajanje otpada»?', 'сортування сміття', '["тетрапак (упаковка з-під молока, соку)", "сортування сміття", "метал", "сортувати, відокремлювати"]'::jsonb, 'A2', 2, 'PUBLISHED', 'odvajanje otpada', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ebdbd814-7cd9-5b69-b442-304038e119e5', 'multiple_choice', 'Що означає «kazna za neodvajanje»?', 'штраф за несортування', '["штраф за несортування", "майданчик з контейнерами для сортування", "сортувати, відокремлювати", "упаковка"]'::jsonb, 'A2', 3, 'PUBLISHED', 'kazna za neodvajanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ce96f812-11a3-5936-9ef6-e9fb2d5cf57f', 'multiple_choice', 'Що означає «ostaci hrane»?', 'залишки їжі', '["біовідходи", "повернення застави за тару", "бляшанка", "залишки їжі"]'::jsonb, 'A2', 4, 'PUBLISHED', 'ostaci hrane', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3b9a2d7e-9f67-5d59-aefc-2c38597e16de', 'multiple_choice', 'Як хорватською «пляшка»?', 'boca', '["boca", "tetrapak", "staklo", "odvajanje otpada"]'::jsonb, 'A2', 5, 'PUBLISHED', 'boca', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aceb9709-5c78-5f2f-bfc1-d5eb62e63f1d', 'multiple_choice', 'Як хорватською «у контейнерах»?', 'u spremnicima', '["reciklirati", "odvajanje otpada", "žuta vreća", "u spremnicima"]'::jsonb, 'A2', 6, 'PUBLISHED', 'u spremnicima', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c9759c6b-8662-5c5e-b526-c29a47d12526', 'type_answer', 'Напишіть хорватською: «скло»', 'staklo', null, 'A2', 7, 'PUBLISHED', 'staklo', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd5947ecd-edce-52f2-b5b7-811b4dbce32f', 'type_answer', 'Напишіть хорватською: «біовідходи»', 'biootpad', null, 'A2', 8, 'PUBLISHED', 'biootpad', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '08cf448a-4127-58d0-8174-a56c33f4925a', 'type_answer', 'Напишіть хорватською: «контейнер»', 'spremnik', null, 'A2', 9, 'PUBLISHED', 'spremnik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2520fee4-701b-58a0-a129-8082e1ad85b1', 'sentence_builder', 'Складіть: «Скло викидають у зелений контейнер.»', 'Staklo se baca u zeleni spremnik.', '["spremnik.", "Staklo", "u", "se", "zeleni", "baca"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9e122630-46ad-59ab-a038-8d4fbfef76c2', 'sentence_builder', 'Складіть: «Зімніть пляшки перед тим, як викинути.»', 'Zgnječite boce prije bacanja.', '["boce", "prije", "bacanja.", "Zgnječite"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cde9c2a1-7ff4-5551-b63f-273ea9377a1c', 'listening', 'Прослухайте і складіть фразу', 'One idu u miješani komunalni otpad.', '["komunalni", "u", "otpad.", "miješani", "One", "idu"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'b73112e8-bfcf-56e9-a2fa-8be423899316', 'listening_dialogue', 'Прослухайте оголошення', 'у вівторок; у четвер; 2', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Оголошення комунального підприємства в під’їзді.", "script": [{"hr": "Poštovani stanari, od prvog ožujka mijenja se raspored odvoza.", "ua": "Шановні мешканці, з першого березня змінюється графік вивезення сміття."}, {"hr": "Plastika se odvozi utorkom, a papir četvrtkom.", "ua": "Пластик вивозять у вівторок, а папір — у четвер."}, {"hr": "Biootpad se odvozi dvaput tjedno, ponedjeljkom i petkom.", "ua": "Біовідходи вивозять двічі на тиждень, у понеділок і п’ятницю."}], "questions": [{"q_ua": "Коли вивозять пластик?", "options": ["у вівторок", "у четвер", "у понеділок"], "correct": 0, "answer_turn": 1}, {"q_ua": "Коли вивозять папір?", "options": ["у п’ятницю", "у середу", "у четвер"], "correct": 2, "answer_turn": 1}, {"q_ua": "Скільки разів на тиждень вивозять біовідходи?", "answer_text": "2", "accept": ["двічі", "два", "два рази"], "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'b73112e8-bfcf-56e9-a2fa-8be423899316', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '41a38071-12a0-5b39-a752-9f45ad0c45e6', 'speaking', 'Куди йде ця пляшка?', 'Kamo ide ova boca?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '736d51c4-3f8e-57b1-9585-ec26c8b13fe8', 'speaking', 'Ми сортуємо папір, пластик і скло.', 'Odvajamo papir, plastiku i staklo.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '476449c5-80a0-5c6f-9a95-b81f78a02352', 'write_message', 'Напишіть новим сусідам у групу будинку: як сортувати — папір у синій контейнер, пластик у жовтий мішок, скло — на розі вулиці.', 'Papir ide u plavi spremnik, plastika u žutu vreću, a staklo u zeleni spremnik na uglu ulice.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть новим сусідам у групу будинку: як сортувати — папір у синій контейнер, пластик у жовтий мішок, скло — на розі вулиці.", "points": [{"ua": "папір", "keys": [["papir"]]}, {"ua": "пластик", "keys": [["plastik"]]}, {"ua": "скло", "keys": [["staklo"]]}], "hints": ["papir ide u plavi spremnik", "plastika u žutu vreću", "staklo na zeleni otok na uglu"], "models": ["Papir ide u plavi spremnik, plastika u žutu vreću, a staklo u zeleni spremnik na uglu ulice."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '476449c5-80a0-5c6f-9a95-b81f78a02352', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '82e0e78c-66b1-5e00-beac-cc93905dbd1e', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Gdje se mogu dobiti žute vreće za plastiku?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай сусідку, де взяти жовті мішки для пластику.", "direction": "ua_hr", "points": [{"ua": "жовті мішки", "keys": [["žut"]]}, {"ua": "пластик", "keys": [["plastik"]]}, {"ua": "де взяти", "keys": [["gdje"]]}], "hints": [], "models": ["Gdje se mogu dobiti žute vreće za plastiku?"], "source_ua": "Спитай сусідку, де взяти жовті мішки для пластику."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '82e0e78c-66b1-5e00-beac-cc93905dbd1e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e7b92c81-680c-5550-be10-5c24ce922940', v_lesson, 'Що куди?', 'Što ide gdje?', 5551, 'A2', 'housing', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('694d0e27-0e86-52b5-b34a-8a8b64b6df60', 'e7b92c81-680c-5550-be10-5c24ce922940', 'Darja', 'Susjedo, kamo ide ova plastična boca?', 'Сусідко, куди йде ця пластикова пляшка?', 1);
  perform pg_temp.turn('213ce0c8-569e-53a8-9360-4756974f26a3', 'e7b92c81-680c-5550-be10-5c24ce922940', 'Susjeda', 'Najbolje je vratiti je u trgovinu, dobijete povratnu naknadu.', 'Найкраще повернути її в магазин, отримаєте заставу назад.', 2);
  perform pg_temp.turn('9e0f66ba-e978-5dfe-8d3d-3189449e772e', 'e7b92c81-680c-5550-be10-5c24ce922940', 'Darja', 'A ostala plastika i limenke?', 'А решта пластику й бляшанки?', 3);
  perform pg_temp.turn('21571b8e-9400-57c7-8c9c-27c548cf46b5', 'e7b92c81-680c-5550-be10-5c24ce922940', 'Susjeda', 'U žutu vreću. Plavi spremnik je za papir i karton.', 'У жовтий мішок. Синій контейнер — для паперу й картону.', 4);
  perform pg_temp.turn('041ed79f-52ff-557a-aa72-7a72f5d00390', 'e7b92c81-680c-5550-be10-5c24ce922940', 'Darja', 'A staklo?', 'А скло?', 5);
  perform pg_temp.turn('13914f5b-686c-5f4b-8ac4-9ae391658b77', 'e7b92c81-680c-5550-be10-5c24ce922940', 'Susjeda', 'U zeleni spremnik na zelenom otoku, na uglu ulice.', 'У зелений контейнер на майданчику для сортування, на розі вулиці.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d54af43b-a034-5ea0-8cfc-c16695c1c8f3', v_lesson, 'Біовідходи', 'Biootpad', 5552, 'A2', 'housing', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('76a4dbd9-ee76-5454-937b-fb37625c7d05', 'd54af43b-a034-5ea0-8cfc-c16695c1c8f3', 'Ivan', 'Dašo, gdje bacamo ostatke hrane?', 'Дашо, куди викидаємо залишки їжі?', 1);
  perform pg_temp.turn('96b8518b-a913-5f16-81e8-ed8bacef0331', 'd54af43b-a034-5ea0-8cfc-c16695c1c8f3', 'Daša', 'U smeđu kantu za biootpad. Ali ne u plastičnoj vrećici!', 'У коричневий бак для біовідходів. Але не в пластиковому пакеті!', 2);
  perform pg_temp.turn('830c03f6-b5dd-538e-b3c1-c44aa9d95035', 'd54af43b-a034-5ea0-8cfc-c16695c1c8f3', 'Ivan', 'A pelene?', 'А підгузки?', 3);
  perform pg_temp.turn('3bacba14-bbbb-5d12-b5ed-e5afcbbe9911', 'd54af43b-a034-5ea0-8cfc-c16695c1c8f3', 'Daša', 'One idu u miješani komunalni otpad.', 'Вони йдуть у змішані побутові відходи.', 4);
  perform pg_temp.turn('72a6c9d5-9672-5986-ab9f-873f97be62fc', 'd54af43b-a034-5ea0-8cfc-c16695c1c8f3', 'Ivan', 'Komplicirano je, ali vrijedi.', 'Складно, але воно того варте.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.9 · урок 56: Великі речі й комунальна служба — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '688768a3-a672-54c7-a3df-60d408b8c210';
  v_lesson constant uuid := '5ef67da9-21aa-58fa-91c2-d8144333a756';
  v_gid constant uuid := '6de8bf6e-97a1-5cb3-8e31-538b07c36309';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики PL'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A2.9: місце 3 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 56: Великі речі й комунальна служба', 'Lekcija 56: Glomazni otpad i komunalne službe', '["Замовити вивезення великих речей і поскаржитися комунальній службі", "Множина: s ormarima, o rupama na cestama, u ulicama"]'::jsonb, 20, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'glomazni otpad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naručiti odvoz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'reciklažno dvorište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stari namještaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'elektronički otpad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'istrošene baterije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opasni otpad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'komunalno poduzeće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rupa na cesti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pokvarena rasvjeta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'javna rasvjeta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'divlje odlagalište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijaviti problem', v_pos);
  v_pos := pg_temp.word(v_lesson, 'aplikacija grada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'besplatno jednom godišnje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kauč', v_pos);
  v_pos := pg_temp.word(v_lesson, 'raskrčiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nagomilati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispred zgrade', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u ulicama', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '887f7787-044e-578e-8bff-f95e0d03b13e', 'fill_in_the_blank', 'Riješite se starog kauča zajedno s ___.', 'ormarima', '["ormari", "ormara", "ormarima", "ormare"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '78e10002-d6ec-5d8e-aebe-f1a34a2d5eca', 'multiple_choice', 'Що означає «naručiti odvoz»?', 'замовити вивезення', '["використані батарейки", "пункт приймання вторсировини", "замовити вивезення", "стихійне звалище"]'::jsonb, 'A2', 2, 'PUBLISHED', 'naručiti odvoz', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd10f32c-6b03-5f90-b714-6847593347a5', 'multiple_choice', 'Що означає «javna rasvjeta»?', 'вуличне освітлення', '["вуличне освітлення", "накопичитися", "електронні відходи", "стихійне звалище"]'::jsonb, 'A2', 3, 'PUBLISHED', 'javna rasvjeta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e1951ae3-4a59-5258-83ab-75bc2716fd05', 'multiple_choice', 'Що означає «divlje odlagalište»?', 'стихійне звалище', '["електронні відходи", "повідомити про проблему", "яма на дорозі", "стихійне звалище"]'::jsonb, 'A2', 4, 'PUBLISHED', 'divlje odlagalište', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6415a579-befa-5fda-bfb4-f26d22cd7cbf', 'multiple_choice', 'Як хорватською «розчистити»?', 'raskrčiti', '["komunalno poduzeće", "aplikacija grada", "besplatno jednom godišnje", "raskrčiti"]'::jsonb, 'A2', 5, 'PUBLISHED', 'raskrčiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'edec0433-8e03-502a-b412-4d5210546c80', 'multiple_choice', 'Як хорватською «старі меблі»?', 'stari namještaj', '["javna rasvjeta", "ispred zgrade", "opasni otpad", "stari namještaj"]'::jsonb, 'A2', 6, 'PUBLISHED', 'stari namještaj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e9e87a6d-c27f-521f-8703-02806d1a1b4d', 'type_answer', 'Напишіть хорватською: «на вулицях»', 'u ulicama', null, 'A2', 7, 'PUBLISHED', 'u ulicama', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6ad95b7a-29b9-51aa-acdd-e6b053fcaf17', 'type_answer', 'Напишіть хорватською: «перед будинком»', 'ispred zgrade', null, 'A2', 8, 'PUBLISHED', 'ispred zgrade', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e49af300-5279-5435-a401-e7314a48262c', 'type_answer', 'Напишіть хорватською: «диван»', 'kauč', null, 'A2', 9, 'PUBLISHED', 'kauč', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ec1dcbf9-db7f-52b2-bfbf-19f5a1d6c875', 'sentence_builder', 'Складіть: «Залиште старі меблі перед будинком.»', 'Ostavite stari namještaj ispred zgrade.', '["namještaj", "ispred", "stari", "zgrade.", "Ostavite"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e1bdaae7-3503-5283-bbbf-5ada40d86a8e', 'sentence_builder', 'Складіть: «Використані батарейки поверніть у магазин.»', 'Istrošene baterije vratite u trgovinu.', '["u", "trgovinu.", "Istrošene", "baterije", "vratite"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5b63c207-4881-5142-a1fa-e4531a6feb71', 'listening', 'Прослухайте і складіть фразу', 'Već sam prijavio prošli mjesec.', '["prošli", "mjesec.", "sam", "prijavio", "Već"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '0b530083-20b4-5bd2-8949-ec2d95f0eaee', 'listening_dialogue', 'Прослухайте оголошення', 'у середу, 12 квітня; 18; електроніку й фарби', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Повідомлення в міському застосунку. Послухайте.", "script": [{"hr": "Odvoz glomaznog otpada u Vašoj četvrti je u srijedu, dvanaestog travnja.", "ua": "Вивезення великогабаритних відходів у вашому районі — у середу, дванадцятого квітня."}, {"hr": "Stvari ostavite ispred zgrade dan prije, poslije osamnaest sati.", "ua": "Речі залиште перед будинком за день до того, після вісімнадцятої."}, {"hr": "Elektronički otpad i boje ne odvozimo.", "ua": "Електронні відходи й фарби ми не вивозимо."}], "questions": [{"q_ua": "Коли вивезення?", "options": ["у середу, 12 квітня", "у вівторок, 11 квітня", "у четвер, 12 квітня"], "correct": 0, "answer_turn": 0}, {"q_ua": "Після котрої години можна виставляти речі (за день до того)?", "answer_text": "18", "accept": ["18:00", "18.00", "вісімнадцятої"], "answer_turn": 1}, {"q_ua": "Що НЕ вивозять?", "options": ["старі меблі", "електроніку й фарби", "диван"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '0b530083-20b4-5bd2-8949-ec2d95f0eaee', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0ad23792-826e-5396-8c3b-ec1200a28894', 'speaking', 'Я хотіла б замовити вивезення.', 'Htjela bih naručiti odvoz.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e678244f-0365-55f4-a565-c00e8ef3624e', 'speaking', 'Вуличне освітлення не працює.', 'Javna rasvjeta ne radi.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '7903e859-f185-5baa-a208-958c413f98ee', 'write_message', 'Повідомте в міському застосунку: на вулиці біля школи велика яма, а вуличне освітлення не працює тиждень.', 'Kod škole je velika rupa na cesti, a javna rasvjeta ne radi tjedan dana.', 'A2', 'PUBLISHED', '{"situation_ua": "Повідомте в міському застосунку: на вулиці біля школи велика яма, а вуличне освітлення не працює тиждень.", "points": [{"ua": "яма на дорозі", "keys": [["rup"]]}, {"ua": "біля школи", "keys": [["škol"]]}, {"ua": "освітлення не працює", "keys": [["rasvjet"]]}], "hints": ["velika rupa na cesti", "kod škole", "javna rasvjeta ne radi tjedan dana"], "models": ["Kod škole je velika rupa na cesti, a javna rasvjeta ne radi tjedan dana."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '7903e859-f185-5baa-a208-958c413f98ee', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '9210a5ff-f74f-5d0e-8ede-57203ae80d46', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Kamo se može odvesti stara perilica i boje?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай, куди здати стару пральну машину й фарби.", "direction": "ua_hr", "points": [{"ua": "пральна машина", "keys": [["perilic"]]}, {"ua": "фарби", "keys": [["boj"]]}, {"ua": "куди", "keys": [["kamo"], ["gdje"]]}], "hints": [], "models": ["Kamo se može odvesti stara perilica i boje?"], "source_ua": "Спитай, куди здати стару пральну машину й фарби."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '9210a5ff-f74f-5d0e-8ede-57203ae80d46', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6cd42871-ed94-5db6-bc46-03f7a94e6121', v_lesson, 'Старий диван', 'Stari kauč', 5561, 'A2', 'housing', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('58fab317-99a7-5fb5-9c31-5d292449f0bc', '6cd42871-ed94-5db6-bc46-03f7a94e6121', 'Darja', 'Dobar dan, htjela bih naručiti odvoz glomaznog otpada.', 'Добрий день, я хотіла б замовити вивезення великогабаритних відходів.', 1);
  perform pg_temp.turn('fd086bb5-ea2c-531b-a0b5-8abb9e2cc0d0', '6cd42871-ed94-5db6-bc46-03f7a94e6121', 'Službenik', 'Što trebate odvesti?', 'Що вам треба вивезти?', 2);
  perform pg_temp.turn('c60e8587-7365-5393-928c-eac5dcbd98bd', '6cd42871-ed94-5db6-bc46-03f7a94e6121', 'Darja', 'Stari kauč, dva ormara i staru perilicu.', 'Старий диван, дві шафи й стару пральну машину.', 3);
  perform pg_temp.turn('bd5604f4-f854-50ef-a86c-00c8083ebc32', '6cd42871-ed94-5db6-bc46-03f7a94e6121', 'Službenik', 'Perilica je elektronički otpad, nju odvezite u reciklažno dvorište. Ostalo ostavite ispred zgrade u utorak navečer.', 'Пральна машина — електронні відходи, її відвезіть на пункт приймання. Решту залиште перед будинком у вівторок увечері.', 4);
  perform pg_temp.turn('3dc7dd8f-1265-59f8-a891-9bfca7993bf1', '6cd42871-ed94-5db6-bc46-03f7a94e6121', 'Darja', 'Je li odvoz besplatan?', 'Вивезення безкоштовне?', 5);
  perform pg_temp.turn('3982e704-3983-5fb0-911a-e18253f12b01', '6cd42871-ed94-5db6-bc46-03f7a94e6121', 'Službenik', 'Jest, jednom godišnje.', 'Так, раз на рік.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0879c3f8-8bae-5071-b58e-6ff0ebdba40e', v_lesson, 'Яма й світло', 'Rupa i rasvjeta', 5562, 'A2', 'housing', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('fd131c57-eb50-5466-a38a-75ee99dbb34f', '0879c3f8-8bae-5071-b58e-6ff0ebdba40e', 'Ivan', 'Dašo, javna rasvjeta u našoj ulici opet ne radi.', 'Дашо, вуличне освітлення на нашій вулиці знову не працює.', 1);
  perform pg_temp.turn('2750d059-22ae-5f37-9618-72e1a73003ca', '0879c3f8-8bae-5071-b58e-6ff0ebdba40e', 'Daša', 'Prijavi problem u aplikaciji grada. I rupu na cesti kod škole.', 'Повідом про проблему в міському застосунку. І про яму на дорозі біля школи.', 2);
  perform pg_temp.turn('bc12dc12-82d1-5e4a-b201-ad52846aee06', '0879c3f8-8bae-5071-b58e-6ff0ebdba40e', 'Ivan', 'Već sam prijavio prošli mjesec.', 'Я вже повідомляв минулого місяця.', 3);
  perform pg_temp.turn('f70e8ce7-1d61-5681-86bb-809beceefbd9', '0879c3f8-8bae-5071-b58e-6ff0ebdba40e', 'Daša', 'Onda nazovi komunalno poduzeće. Djeca idu tuda u mraku.', 'Тоді подзвони в комунальне підприємство. Діти ходять там у темряві.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.9 · урок 57: Природа й охорона довкілля — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '688768a3-a672-54c7-a3df-60d408b8c210';
  v_lesson constant uuid := '03c6044d-1ebf-5dee-becb-e4748f65511c';
  v_gid constant uuid := '6de8bf6e-97a1-5cb3-8e31-538b07c36309';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики PL'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A2.9: місце 4 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 57: Природа й охорона довкілля', 'Lekcija 57: Priroda i zaštita okoliša', '["Поговорити про екологію: що ми робимо для довкілля", "Множина: o šumama, u rijekama, s volonterima"]'::jsonb, 20, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'okoliš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaštita okoliša', v_pos);
  v_pos := pg_temp.word(v_lesson, 'onečišćenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'klimatske promjene', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kvaliteta zraka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'štedjeti vodu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'štedjeti struju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'platnena vrećica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jednokratan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'višekratan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'solarni paneli', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obnovljivi izvori energije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šuma', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čišćenje plaže', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ekološka akcija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugrožen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrsta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bacati smeće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ekološki osviješten', v_pos);
  v_pos := pg_temp.word(v_lesson, 's volonterima', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u rijekama', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '330817b5-4781-5991-9ac9-a2ab21fb9b97', 'fill_in_the_blank', 'Plažu smo očistili s ___.', 'volonterima', '["volonteri", "volontere", "volontera", "volonterima"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0738a39f-594f-5835-8666-f12142b0f123', 'multiple_choice', 'Що означає «klimatske promjene»?', 'зміна клімату', '["під загрозою, зникаючий", "вид (тварин, рослин)", "заощаджувати електроенергію", "зміна клімату"]'::jsonb, 'A2', 2, 'PUBLISHED', 'klimatske promjene', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9ff3397a-4f28-5d0f-a079-4da9464764b3', 'multiple_choice', 'Що означає «ekološki osviješten»?', 'екологічно свідомий', '["відновлювані джерела енергії", "з волонтерами", "екологічно свідомий", "довкілля"]'::jsonb, 'A2', 3, 'PUBLISHED', 'ekološki osviješten', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '67a54174-a4ff-5526-a988-a09533f3e8e6', 'multiple_choice', 'Що означає «štedjeti vodu»?', 'заощаджувати воду', '["смітити", "прибирання пляжу", "екологічно свідомий", "заощаджувати воду"]'::jsonb, 'A2', 4, 'PUBLISHED', 'štedjeti vodu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1a66e9ce-53d2-5b9f-905c-55f6864eb61a', 'multiple_choice', 'Як хорватською «з волонтерами»?', 's volonterima', '["onečišćenje", "ekološki osviješten", "s volonterima", "obnovljivi izvori energije"]'::jsonb, 'A2', 5, 'PUBLISHED', 's volonterima', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '834d7482-65cd-5ac3-97eb-85e10c733f8d', 'multiple_choice', 'Як хорватською «багаторазовий»?', 'višekratan', '["višekratan", "ekološka akcija", "ekološki osviješten", "vrsta"]'::jsonb, 'A2', 6, 'PUBLISHED', 'višekratan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '27d3d304-a841-5369-a5e0-fe6deb623216', 'type_answer', 'Напишіть хорватською: «забруднення»', 'onečišćenje', null, 'A2', 7, 'PUBLISHED', 'onečišćenje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b2590f4e-81b8-5843-a4fb-2847f9624dec', 'type_answer', 'Напишіть хорватською: «сонячні панелі»', 'solarni paneli', null, 'A2', 8, 'PUBLISHED', 'solarni paneli', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fbdff4fb-088c-51c0-ab59-de9899ff03eb', 'type_answer', 'Напишіть хорватською: «одноразовий»', 'jednokratan', null, 'A2', 9, 'PUBLISHED', 'jednokratan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '924960ba-bf7b-5d32-ac38-178d26614ffd', 'sentence_builder', 'Складіть: «Треба берегти довкілля.»', 'Moramo čuvati okoliš.', '["okoliš.", "Moramo", "čuvati"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4eec5f87-ab4e-59d0-8c2d-a0f6e40b7b71', 'sentence_builder', 'Складіть: «Я ношу багаторазову пляшку для води.»', 'Nosim višekratnu bocu za vodu.', '["Nosim", "za", "višekratnu", "bocu", "vodu."]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e8c561f1-c3df-5428-a5d6-303aeaa11e83', 'listening', 'Прослухайте і складіть фразу', 'Najviše je jednokratne plastike.', '["jednokratne", "Najviše", "plastike.", "je"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'f8818fdd-0598-53a3-8ac1-97230544fa80', 'listening_dialogue', 'Прослухайте новину', '3000; пластикових пляшок; у вересні', 'A2', 'PUBLISHED', '{"kind": "news", "situation_ua": "Ви слухаєте коротку новину про екологію.", "script": [{"hr": "Na akciji čišćenja Jadrana sudjelovalo je više od tri tisuće volontera.", "ua": "В акції з прибирання Адріатики взяли участь понад три тисячі волонтерів."}, {"hr": "Skupili su dvadeset tona otpada, najviše plastičnih boca.", "ua": "Вони зібрали двадцять тонн відходів, найбільше пластикових пляшок."}, {"hr": "Sljedeća akcija bit će u rujnu na Krki.", "ua": "Наступна акція буде у вересні на Крці."}], "questions": [{"q_ua": "Скільки волонтерів було (понад…)?", "answer_text": "3000", "accept": ["3 000", "3.000", "понад 3000", "три тисячі"], "answer_turn": 0}, {"q_ua": "Чого зібрали найбільше?", "options": ["скла", "пластикових пляшок", "металу"], "correct": 1, "answer_turn": 1}, {"q_ua": "Коли наступна акція?", "options": ["у червні", "у жовтні", "у вересні"], "correct": 2, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'f8818fdd-0598-53a3-8ac1-97230544fa80', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c7bced96-936c-503b-8c9f-a5bdadfa9c53', 'speaking', 'У суботу акція з прибирання пляжу.', 'U subotu je akcija čišćenja plaže.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a2e9eed8-9ef7-5182-8f63-0951cc2f230a', 'speaking', 'Ми заощаджуємо воду й світло.', 'Štedimo vodu i struju.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'dca5c0a9-59b3-578d-b6d8-50228a770857', 'write_message', 'Напишіть подрузі: запрошуєте її на екологічну акцію в суботу — прибирати ліс біля міста; хай візьме рукавички.', 'Dašo, u subotu je ekološka akcija, čistimo šumu kod grada. Dođi i ponesi rukavice!', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі: запрошуєте її на екологічну акцію в суботу — прибирати ліс біля міста; хай візьме рукавички.", "points": [{"ua": "екологічна акція", "keys": [["akcij"]]}, {"ua": "у суботу", "keys": [["subot"]]}, {"ua": "прибирати ліс", "keys": [["šum"]]}, {"ua": "рукавички", "keys": [["rukavic"]]}], "hints": ["ekološka akcija", "u subotu", "čistimo šumu kod grada", "ponesi rukavice"], "models": ["Dašo, u subotu je ekološka akcija, čistimo šumu kod grada. Dođi i ponesi rukavice!"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'dca5c0a9-59b3-578d-b6d8-50228a770857', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'facd87f1-7831-50cf-9294-495696f15236', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Želi volontirati i dovest će dva prijatelja.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи організаторам, що я хочу волонтерити й приведу двох друзів.", "direction": "ua_hr", "points": [{"ua": "волонтерити", "keys": [["volont"]]}, {"ua": "двох друзів", "keys": [["dva prijatelj"], ["dvoje"]]}], "hints": [], "models": ["Želi volontirati i dovest će dva prijatelja."], "source_ua": "Скажи організаторам, що я хочу волонтерити й приведу двох друзів."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'facd87f1-7831-50cf-9294-495696f15236', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('15d33bb9-bb1a-5f68-96db-e8ee347c0be2', v_lesson, 'Акція на пляжі', 'Akcija na plaži', 5571, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('2b6a9647-cddb-5f95-948d-ba8ed0c7335a', '15d33bb9-bb1a-5f68-96db-e8ee347c0be2', 'Daša', 'Darja, u subotu je akcija čišćenja plaže. Ideš?', 'Дар’є, у суботу акція з прибирання пляжу. Підеш?', 1);
  perform pg_temp.turn('614c3079-3241-5c50-9a96-a9a256ac5f08', '15d33bb9-bb1a-5f68-96db-e8ee347c0be2', 'Darja', 'Idem! Prošli put smo s volonterima skupili sto vreća smeća.', 'Піду! Минулого разу ми з волонтерами зібрали сто мішків сміття.', 2);
  perform pg_temp.turn('e1d039b2-ad97-5d21-848b-5c14c020eb4b', '15d33bb9-bb1a-5f68-96db-e8ee347c0be2', 'Daša', 'Najviše je jednokratne plastike.', 'Найбільше одноразового пластику.', 3);
  perform pg_temp.turn('5d0055c3-505b-5380-b2a7-dfb8edc56dde', '15d33bb9-bb1a-5f68-96db-e8ee347c0be2', 'Darja', 'Zato ja nosim višekratnu bocu i platnenu vrećicu.', 'Тому я ношу багаторазову пляшку й полотняну сумку.', 4);
  perform pg_temp.turn('50bb6758-bfda-5d48-9925-7889262e4379', '15d33bb9-bb1a-5f68-96db-e8ee347c0be2', 'Daša', 'Bravo. Malo po malo štitimo okoliš.', 'Молодець. Потроху захищаємо довкілля.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('951e274c-c212-5417-a726-2c5ade6acaa4', v_lesson, 'Зміна клімату', 'Klimatske promjene', 5572, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('5f5da26a-e641-5649-815f-214276865f47', '951e274c-c212-5417-a726-2c5ade6acaa4', 'Ivan', 'Ljeta su sve toplija. Klimatske promjene se stvarno osjećaju.', 'Літо дедалі спекотніше. Зміна клімату справді відчувається.', 1);
  perform pg_temp.turn('96f03d62-9baf-53c3-ac72-8d57a2d59e5b', '951e274c-c212-5417-a726-2c5ade6acaa4', 'Marko', 'Istina. I kvaliteta zraka u gradu je loša zimi.', 'Правда. І якість повітря в місті погана взимку.', 2);
  perform pg_temp.turn('5023533a-5cdc-5782-9205-19114cfecf5e', '951e274c-c212-5417-a726-2c5ade6acaa4', 'Ivan', 'Mi smo stavili solarne panele na krov.', 'Ми поставили сонячні панелі на дах.', 3);
  perform pg_temp.turn('ff4aff18-73d7-5d99-b80f-bd6c6c7f93f5', '951e274c-c212-5417-a726-2c5ade6acaa4', 'Marko', 'Pametno. Mi štedimo struju i vodu, više ne možemo.', 'Розумно. Ми заощаджуємо світло й воду, більше не можемо.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.9 · урок 58: Спека, буря, пожежа: попередження — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '688768a3-a672-54c7-a3df-60d408b8c210';
  v_lesson constant uuid := '88f2e9d5-51e4-5ff4-b18b-b221ac12117d';
  v_gid constant uuid := '6de8bf6e-97a1-5cb3-8e31-538b07c36309';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики PL'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A2.9: місце 5 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 58: Спека, буря, пожежа: попередження', 'Lekcija 58: Vrućina, oluja i požar: upozorenja', '["Зрозуміти попередження про негоду й що робити", "Множина: u kućama, na cestama, s djecom i starijima"]'::jsonb, 20, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'meteoalarm', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crveno upozorenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'narančasto upozorenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'olujni vjetar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tuča', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bujica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šumski požar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vatrogasci', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kanader', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zabrana loženja vatre', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugroženo područje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skloniti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izbjegavati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pitka voda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'starije osobe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nestanak struje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srušeno stablo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'evakuirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na cestama', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u kućama', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hitne službe', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '4034ca1a-8869-5b7f-93e1-72604d933637', 'fill_in_the_blank', 'Zbog oluje je puno vode na ___.', 'cestama', '["cesta", "cestama", "ceste", "cesti"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '88add990-99aa-5d0a-b489-a211de4e2622', 'multiple_choice', 'Що означає «olujni vjetar»?', 'штормовий вітер', '["уникати", "лісова пожежа", "метеопопередження", "штормовий вітер"]'::jsonb, 'A2', 2, 'PUBLISHED', 'olujni vjetar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6d00bd4b-bda1-599c-91a0-9fb5e43c28c6', 'multiple_choice', 'Що означає «starije osobe»?', 'літні люди', '["літні люди", "штормовий вітер", "канадер (протипожежний літак)", "лісова пожежа"]'::jsonb, 'A2', 3, 'PUBLISHED', 'starije osobe', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b26eee31-292a-57f9-b8fd-6edc2a762fff', 'multiple_choice', 'Що означає «kanader»?', 'канадер (протипожежний літак)', '["повалене дерево", "канадер (протипожежний літак)", "евакуювати", "літні люди"]'::jsonb, 'A2', 4, 'PUBLISHED', 'kanader', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0354d5bd-0b10-5bc0-a2c6-c3125b6c8390', 'multiple_choice', 'Як хорватською «відключення світла»?', 'nestanak struje', '["bujica", "nestanak struje", "na cestama", "narančasto upozorenje"]'::jsonb, 'A2', 5, 'PUBLISHED', 'nestanak struje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2a8090f4-61e7-5980-bde7-e009775a7588', 'multiple_choice', 'Як хорватською «сховатися»?', 'skloniti se', '["olujni vjetar", "ugroženo područje", "izbjegavati", "skloniti se"]'::jsonb, 'A2', 6, 'PUBLISHED', 'skloniti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '30793111-012a-5088-a371-1583a19e0903', 'type_answer', 'Напишіть хорватською: «метеопопередження»', 'meteoalarm', null, 'A2', 7, 'PUBLISHED', 'meteoalarm', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c0cd3376-2fc1-56a8-befa-1c5de71a9f93', 'type_answer', 'Напишіть хорватською: «град (опади)»', 'tuča', null, 'A2', 8, 'PUBLISHED', 'tuča', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ec9f30e4-a036-5016-acbf-0c97d7035720', 'type_answer', 'Напишіть хорватською: «на дорогах»', 'na cestama', null, 'A2', 9, 'PUBLISHED', 'na cestama', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '682717b7-1665-5778-b2eb-3fefb7b39e2d', 'sentence_builder', 'Складіть: «Сховайтеся в закритому приміщенні.»', 'Sklonite se u zatvoreni prostor.', '["Sklonite", "u", "se", "prostor.", "zatvoreni"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a66e368-3d3a-50a6-ac16-f1d0195c788f', 'sentence_builder', 'Складіть: «Повалене дерево блокує дорогу.»', 'Srušeno stablo blokira cestu.', '["cestu.", "stablo", "Srušeno", "blokira"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b7667632-d3e7-5c5e-ba3a-37532f9944bd', 'listening', 'Прослухайте і складіть фразу', 'Neka ostane u kući i pije puno pitke vode.', '["ostane", "i", "pitke", "kući", "Neka", "pije", "vode.", "puno", "u"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '927e6f40-3915-5391-bbe0-9b4bb66c2a83', 'listening_dialogue', 'Прослухайте прогноз', 'помаранчевий; 80; не паркуватися під деревами', 'A2', 'PUBLISHED', '{"kind": "forecast", "situation_ua": "Ви слухаєте попередження по радіо.", "script": [{"hr": "Izdano je narančasto upozorenje za Liku i Gorski kotar.", "ua": "Видано помаранчеве попередження для Ліки й Горського Котару."}, {"hr": "Očekuju se jaka kiša, tuča i olujni vjetar do osamdeset kilometara na sat.", "ua": "Очікуються сильний дощ, град і штормовий вітер до вісімдесяти кілометрів на годину."}, {"hr": "Vozače molimo da izbjegavaju put i ne parkiraju ispod stabala.", "ua": "Водіїв просимо уникати поїздок і не паркуватися під деревами."}], "questions": [{"q_ua": "Який рівень попередження?", "options": ["помаранчевий", "червоний", "жовтий"], "correct": 0, "answer_turn": 0}, {"q_ua": "Яка швидкість вітру (км/год)?", "answer_text": "80", "accept": ["вісімдесят", "80 км/год"], "answer_turn": 1}, {"q_ua": "Про що просять водіїв?", "options": ["їхати швидше", "не паркуватися під деревами", "заправитися"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '927e6f40-3915-5391-bbe0-9b4bb66c2a83', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a97687bf-5f41-5ca9-bfeb-b4a8ad04a846', 'speaking', 'Для Спліта червоне попередження.', 'Za Split je crveno upozorenje.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '87488bcf-d99d-5e1c-8cdc-3523a326fc95', 'speaking', 'У разі небезпеки телефонуйте 112.', 'U hitnom slučaju nazovite 112.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '776fb263-3e6b-5acb-8cf9-5294cbc68f35', 'write_message', 'Напишіть родині в групу: через бурю немає світла, ви вдома, усі в порядку.', 'Zbog oluje nemamo struje, ali kod kuće smo i svi smo dobro.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть родині в групу: через бурю немає світла, ви вдома, усі в порядку.", "points": [{"ua": "буря", "keys": [["oluj"], ["nevrijem"]]}, {"ua": "немає світла", "keys": [["strij"], ["struj"]]}, {"ua": "усі в порядку", "keys": [["u redu"], ["dobro"]]}], "hints": ["zbog oluje", "nemamo struje", "kod kuće smo", "svi smo dobro"], "models": ["Zbog oluje nemamo struje, ali kod kuće smo i svi smo dobro."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '776fb263-3e6b-5acb-8cf9-5294cbc68f35', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '9eb8184d-e59c-5bba-8a9d-05f50a77c4d7', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Moramo li se evakuirati? Kamo trebamo ići?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай пожежника, чи треба нам евакуюватися і куди йти.", "direction": "ua_hr", "points": [{"ua": "евакуюватися", "keys": [["evakuir"]]}, {"ua": "куди", "keys": [["kamo"], ["gdje"]]}], "hints": [], "models": ["Moramo li se evakuirati? Kamo trebamo ići?"], "source_ua": "Спитай пожежника, чи треба нам евакуюватися і куди йти."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '9eb8184d-e59c-5bba-8a9d-05f50a77c4d7', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('af8da87c-08a5-530c-af4c-eb66f15410da', v_lesson, 'Червоне попередження', 'Crveno upozorenje', 5581, 'A2', 'basics', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('98f50467-bb07-57b0-bba7-f7394a1a62ef', 'af8da87c-08a5-530c-af4c-eb66f15410da', 'Darja', 'Jesi li čula? Za Split je crveno upozorenje zbog vrućine.', 'Ти чула? Для Спліта червоне попередження через спеку.', 1);
  perform pg_temp.turn('064ea927-bda7-55eb-a02b-13b957309190', 'af8da87c-08a5-530c-af4c-eb66f15410da', 'Daša', 'Jesam. Treba izbjegavati sunce od jedanaest do sedamnaest.', 'Так. Треба уникати сонця з одинадцятої до сімнадцятої.', 2);
  perform pg_temp.turn('b6761609-0ee1-5731-aea2-b1cd09046988', 'af8da87c-08a5-530c-af4c-eb66f15410da', 'Darja', 'Moja mama je kod nas. Starije osobe ne bi trebale izlaziti.', 'Моя мама в нас. Літнім людям не варто виходити.', 3);
  perform pg_temp.turn('89484b81-d3e1-5941-be1d-a7ba76859115', 'af8da87c-08a5-530c-af4c-eb66f15410da', 'Daša', 'Neka ostane u kući i pije puno pitke vode.', 'Хай лишається вдома й п’є багато питної води.', 4);
  perform pg_temp.turn('7bd263be-1fe9-594a-9b2d-66ee2120998d', 'af8da87c-08a5-530c-af4c-eb66f15410da', 'Darja', 'A djeca žele na plažu...', 'А діти хочуть на пляж...', 5);
  perform pg_temp.turn('6c9dceb3-7c53-5a0c-9214-45ba89bc71fd', 'af8da87c-08a5-530c-af4c-eb66f15410da', 'Daša', 'Idite rano ujutro ili navečer.', 'Ідіть рано вранці або ввечері.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b0c9465c-98fe-557b-9158-64006bbc4d81', v_lesson, 'Пожежа поблизу', 'Požar blizu', 5582, 'A2', 'basics', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('30c65c04-c288-5c7a-9540-8060bddffe92', 'b0c9465c-98fe-557b-9158-64006bbc4d81', 'Ivan', 'Vidiš li dim? Šumski požar je iznad sela.', 'Бачиш дим? Лісова пожежа над селом.', 1);
  perform pg_temp.turn('96b844bc-52f0-5358-bb48-0afecff66036', 'b0c9465c-98fe-557b-9158-64006bbc4d81', 'Marko', 'Kanaderi su već tu. Vatrogasci gase od jutra.', 'Канадери вже тут. Пожежники гасять з ранку.', 2);
  perform pg_temp.turn('5875552d-da77-570b-8096-d6bab4a57951', 'b0c9465c-98fe-557b-9158-64006bbc4d81', 'Ivan', 'Hoće li evakuirati kamp?', 'Чи евакуюють кемпінг?', 3);
  perform pg_temp.turn('7b2c6c18-6b69-526b-8ece-4f372613893b', 'b0c9465c-98fe-557b-9158-64006bbc4d81', 'Marko', 'Ako vjetar okrene, hoće. Spremimo dokumente za svaki slučaj.', 'Якщо вітер зміниться, евакуюють. Приготуймо документи про всяк випадок.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.9 · урок 59: Сад, балкон і рослини — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '688768a3-a672-54c7-a3df-60d408b8c210';
  v_lesson constant uuid := '47da19c6-e1f7-589a-87a2-e78e419c206a';
  v_gid constant uuid := '6de8bf6e-97a1-5cb3-8e31-538b07c36309';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики PL'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A2.9: місце 6 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 59: Сад, балкон і рослини', 'Lekcija 59: Vrt, balkon i biljke', '["Поговорити про рослини на балконі й у саду", "Множина: s biljkama, u teglama, o cvjetovima"]'::jsonb, 20, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'biljka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cvijeće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lonac za cvijeće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'saditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posaditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sjeme', v_pos);
  v_pos := pg_temp.word(v_lesson, 'začinsko bilje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bosiljak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ružmarin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lavanda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maslina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uzgajati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kompost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zemlja za cvijeće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'orezati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'korov', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cvjetati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uvenuti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zalijevanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrtlarski centar', v_pos);
  v_pos := pg_temp.word(v_lesson, 's biljkama', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8a27e2a-8a91-533b-8b2a-65ab322a17c4', 'fill_in_the_blank', 'Balkon s ___ je kao mali vrt.', 'biljkama', '["biljke", "biljkama", "biljku", "biljaka"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a8f2cea-2910-5355-adde-f7d7acf16f07', 'multiple_choice', 'Що означає «maslina»?', 'оливкове дерево; оливка', '["розмарин", "оливкове дерево; оливка", "садовий центр", "базилік"]'::jsonb, 'A2', 2, 'PUBLISHED', 'maslina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b8e33034-29db-5750-b56b-d91af9a082f9', 'multiple_choice', 'Що означає «uvenuti»?', 'зів’янути', '["лаванда", "компост", "зів’янути", "садити"]'::jsonb, 'A2', 3, 'PUBLISHED', 'uvenuti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ba533bd1-f1a9-508c-baef-6cd377b289f4', 'multiple_choice', 'Що означає «uzgajati»?', 'вирощувати', '["вирощувати", "лаванда", "садити", "посадити"]'::jsonb, 'A2', 4, 'PUBLISHED', 'uzgajati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a7054f0-e4d9-5bf3-8923-9d471af3af82', 'multiple_choice', 'Як хорватською «лаванда»?', 'lavanda', '["uvenuti", "uzgajati", "lavanda", "cvjetati"]'::jsonb, 'A2', 5, 'PUBLISHED', 'lavanda', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '89299d56-f099-5b0d-b640-6b9684442073', 'multiple_choice', 'Як хорватською «рослина»?', 'biljka', '["ružmarin", "biljka", "sjeme", "korov"]'::jsonb, 'A2', 6, 'PUBLISHED', 'biljka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f95c29fc-c4fb-531d-89cf-e922226f0eb6', 'type_answer', 'Напишіть хорватською: «розмарин»', 'ružmarin', null, 'A2', 7, 'PUBLISHED', 'ružmarin', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bb8e2176-fb41-5427-8738-be7c494f771b', 'type_answer', 'Напишіть хорватською: «компост»', 'kompost', null, 'A2', 8, 'PUBLISHED', 'kompost', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '678c89c7-8741-551d-93f7-30c1eaa1180a', 'type_answer', 'Напишіть хорватською: «посадити»', 'posaditi', null, 'A2', 9, 'PUBLISHED', 'posaditi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7d2ed160-e36d-5a23-a7e8-8515f9a4494b', 'sentence_builder', 'Складіть: «Лаванда цвіте в червні.»', 'Lavanda cvjeta u lipnju.', '["cvjeta", "Lavanda", "u", "lipnju."]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '490c24c2-86fe-59b1-a796-c525d24689df', 'sentence_builder', 'Складіть: «Ми вирощуємо овочі для себе.»', 'Uzgajamo povrće za sebe.', '["sebe.", "za", "Uzgajamo", "povrće"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8a7ef36e-667b-59ab-8636-edd183927835', 'listening', 'Прослухайте і складіть фразу', 'Za masline. Želim ih posaditi na terasi.', '["terasi.", "Želim", "na", "masline.", "Za", "posaditi", "ih"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'f19ecd33-f845-5e16-ae87-906eafc1e01c', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'щовечора; базилік; вони вже червоні', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Сусідка залишила вам повідомлення, поки ви у відпустці.", "script": [{"hr": "Bok Darja, ovdje Vesna, susjeda.", "ua": "Привіт, Дар’є, це Весна, сусідка."}, {"hr": "Zalijevam ti biljke svaku večer, sve je u redu.", "ua": "Я поливаю твої рослини щовечора, усе гаразд."}, {"hr": "Samo je bosiljak malo uvenuo od vrućine, stavila sam ga u hlad.", "ua": "Лише базилік трохи зів’яв від спеки, я поставила його в тінь."}, {"hr": "Rajčice su već crvene, uberi ih kad se vratiš!", "ua": "Помідори вже червоні, збери їх, коли повернешся!"}], "questions": [{"q_ua": "Як часто сусідка поливає рослини?", "options": ["щовечора", "раз на тиждень", "щоранку"], "correct": 0, "answer_turn": 1}, {"q_ua": "Яка рослина зів’яла?", "answer_text": "базилік", "accept": ["bosiljak", "базилика"], "answer_turn": 2}, {"q_ua": "Що з помідорами?", "options": ["їх з’їли птахи", "вони вже червоні", "вони ще зелені"], "correct": 1, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'f19ecd33-f845-5e16-ae87-906eafc1e01c', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd290151d-7982-5aec-9a82-64a6121eb41a', 'speaking', 'Я вирощую пряні трави.', 'Uzgajam začinsko bilje.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f338cb8f-fb82-54e0-8b0b-b022e3662d49', 'speaking', 'Поки нас не було, рослини зів’яли.', 'Dok nas nije bilo, biljke su uvenule.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '6b48c1bc-3ed2-5c80-bb16-dbb10697f6f4', 'write_message', 'Напишіть сусідці: ви їдете на тиждень і просите поливати рослини на балконі ввечері; ключ залишите під килимком.', 'Vesna, idem na tjedan dana. Molim te da navečer zalijevaš biljke na balkonu. Ključ je ispod otirača.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть сусідці: ви їдете на тиждень і просите поливати рослини на балконі ввечері; ключ залишите під килимком.", "points": [{"ua": "їдете на тиждень", "keys": [["tjed"]]}, {"ua": "поливати рослини", "keys": [["zalij"], ["biljk"]]}, {"ua": "ввечері", "keys": [["navečer"]]}, {"ua": "ключ", "keys": [["ključ"]]}], "hints": ["idem na tjedan dana", "molim te da zalijevaš biljke", "navečer", "ključ je ispod otirača"], "models": ["Vesna, idem na tjedan dana. Molim te da navečer zalijevaš biljke na balkonu. Ključ je ispod otirača."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '6b48c1bc-3ed2-5c80-bb16-dbb10697f6f4', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '8530e10a-dcc3-5e24-97c1-a4eee3c12d81', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Koliko često treba zalijevati lavandu i voli li sunce?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай продавчиню, як часто поливати лаванду і чи любить вона сонце.", "direction": "ua_hr", "points": [{"ua": "як часто поливати", "keys": [["zalij"]]}, {"ua": "лаванда", "keys": [["lavand"]]}, {"ua": "сонце", "keys": [["sunc"]]}], "hints": [], "models": ["Koliko često treba zalijevati lavandu i voli li sunce?"], "source_ua": "Спитай продавчиню, як часто поливати лаванду і чи любить вона сонце."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '8530e10a-dcc3-5e24-97c1-a4eee3c12d81', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8e04841b-1a40-5864-bb8f-18802fd993af', v_lesson, 'Балкон Дар’ї', 'Darjin balkon', 5591, 'A2', 'housing', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('ef323a45-7089-5f87-b4b7-a247ffc5fe79', '8e04841b-1a40-5864-bb8f-18802fd993af', 'Daša', 'Kakav lijep balkon! Toliko biljaka!', 'Який гарний балкон! Стільки рослин!', 1);
  perform pg_temp.turn('276938a7-516a-51ad-a389-bbe1d3838207', '8e04841b-1a40-5864-bb8f-18802fd993af', 'Darja', 'Hvala. Uzgajam začinsko bilje: bosiljak, ružmarin i lavandu.', 'Дякую. Я вирощую пряні трави: базилік, розмарин і лаванду.', 2);
  perform pg_temp.turn('9d6bb8d7-5607-5dd0-89a0-b85c30c39939', '8e04841b-1a40-5864-bb8f-18802fd993af', 'Daša', 'A rajčice?', 'А помідори?', 3);
  perform pg_temp.turn('eb7289ea-8e3b-538e-8e6a-9cfa930c7ffb', '8e04841b-1a40-5864-bb8f-18802fd993af', 'Darja', 'Posadila sam ih u travnju, iz sjemena. Sad već cvjetaju.', 'Я посадила їх у квітні, з насіння. Тепер уже цвітуть.', 4);
  perform pg_temp.turn('675e868d-aa17-5643-86f4-369153f3d61f', '8e04841b-1a40-5864-bb8f-18802fd993af', 'Daša', 'Ja sam lani bila na moru i sve su mi biljke uvenule.', 'А я торік була на морі, і всі мої рослини зів’яли.', 5);
  perform pg_temp.turn('be08ab65-89fb-52d3-80db-f0b1073e1992', '8e04841b-1a40-5864-bb8f-18802fd993af', 'Darja', 'Zamoli susjedu za zalijevanje dok te nema.', 'Попроси сусідку поливати, поки тебе немає.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c40ff1f9-49f9-5531-aa24-6bad1a4f95a3', v_lesson, 'У садовому центрі', 'U vrtlarskom centru', 5592, 'A2', 'housing', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('c61ad028-431e-503b-a2c6-7bca7c48d873', 'c40ff1f9-49f9-5531-aa24-6bad1a4f95a3', 'Ivan', 'Dobar dan, trebam zemlju za cvijeće i dva lonca.', 'Добрий день, мені потрібен ґрунт для квітів і два вазони.', 1);
  perform pg_temp.turn('b92f0ae8-f9d3-526e-8e4c-7f7d6f583329', 'c40ff1f9-49f9-5531-aa24-6bad1a4f95a3', 'Prodavačica', 'Za koje biljke?', 'Для яких рослин?', 2);
  perform pg_temp.turn('4e44c507-0c9c-5efe-8c36-8cd61cccf628', 'c40ff1f9-49f9-5531-aa24-6bad1a4f95a3', 'Ivan', 'Za masline. Želim ih posaditi na terasi.', 'Для оливкових дерев. Хочу посадити їх на терасі.', 3);
  perform pg_temp.turn('d9d50f1a-01af-5e8e-b0a8-eb3708ea8466', 'c40ff1f9-49f9-5531-aa24-6bad1a4f95a3', 'Prodavačica', 'Masline vole sunce i malo vode. Orežite ih u proljeće.', 'Оливки люблять сонце й мало води. Обрізайте їх навесні.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- 3. Модуль і юніт — опубліковані
update public.modules set status = 'PUBLISHED', title_ua = 'Модуль A2.9 — Неприємності в місті й довкілля', title_hr = 'Modul A2.9 — Nevolje u gradu i okoliš' where id = 'a198575a-bafc-51b5-b325-95aa7d6c9d8a';
update public.units set status = 'PUBLISHED' where id = '688768a3-a672-54c7-a3df-60d408b8c210';

-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('6c0efc81-fd32-55c6-8e57-b1885e387093', '8d6a1367-0183-5c35-b6df-ddfbe23a4152', '5ef67da9-21aa-58fa-91c2-d8144333a756', '03c6044d-1ebf-5dee-becb-e4748f65511c', '88f2e9d5-51e4-5ff4-b18b-b221ac12117d', '47da19c6-e1f7-589a-87a2-e78e419c206a')
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
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 20 or l.unit_id <> '688768a3-a672-54c7-a3df-60d408b8c210');
  select count(*) into v_titles from (values ('6c0efc81-fd32-55c6-8e57-b1885e387093'::uuid, 'Урок 54:%', 1), ('8d6a1367-0183-5c35-b6df-ddfbe23a4152'::uuid, 'Урок 55:%', 2), ('5ef67da9-21aa-58fa-91c2-d8144333a756'::uuid, 'Урок 56:%', 3), ('03c6044d-1ebf-5dee-becb-e4748f65511c'::uuid, 'Урок 57:%', 4), ('88f2e9d5-51e4-5ff4-b18b-b221ac12117d'::uuid, 'Урок 58:%', 5), ('47da19c6-e1f7-589a-87a2-e78e419c206a'::uuid, 'Урок 59:%', 6)) as t(id, pat, o)
    left join public.lessons l on l.id = t.id and l.title_ua like t.pat and l.order_index = t.o
   where l.id is null;
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
      where l.level_code = 'A2' and l.status = 'PUBLISHED' and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A2.9: % уроків з неправильним складом', v_bad; end if;
  if v_titles > 0 then raise exception 'Модуль A2.9: % уроків не на своєму місці чи з неправильним номером', v_titles; end if;
  if v_words > 0 then raise exception 'A2: % слів повторюються в кількох уроках', v_words; end if;
  if (select status from public.modules where id = 'a198575a-bafc-51b5-b325-95aa7d6c9d8a') <> 'PUBLISHED' then raise exception 'Модуль A2.9 не опубліковано'; end if;
  raise notice 'Готово: модуль A2.9 — 6 уроків, слів 126';
end $$;

commit;
