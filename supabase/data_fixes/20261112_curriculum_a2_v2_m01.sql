-- =====================================================================
-- Програма A2 v2 · модуль A2.1 «Туризм і подорожі: Адріатика» · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2.py 1 (не редагуйте вручну).
--
-- Рішення власника 2026-11-12: 20–25 нових слів на урок, 90–95 % слів — нові для рівня, діалоги під тему,
-- частіше Даша / Дар’я; «Прослухайте діалог чи оголошення» в кожному уроці; бета (PUBLISHED).
--   * Уроки 1–8 (8): слів у них 174. Кожен: 20–25 слів, 2 діалоги, 15 вправ
--     (одна — «Прослухайте діалог чи оголошення»), «Напишіть повідомлення» і «Перекажіть другу» (ua → hr, необов’язкові), 20 хв.
--   * Слова: 174 (нові — PUBLISHED; ті, що вже є в словнику, не змінюються).
--   * Модуль і юніт A2.1 → PUBLISHED. Потрібен уже запущений 20261112_curriculum_a2_v2_00_structure.sql.
--   * Нічого не видаляє. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.units where id = '11809ea9-712b-5fb7-b4a6-8a5fb60f7d62') then
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

-- 1. Слова уроків A2.1 (174): нові — PUBLISHED (бета); наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A2', t.ua, t.vtype, t.forms, t.examples, 'PUBLISHED', 'claude_curriculum_a2_v2'
  from jsonb_to_recordset('[{"lemma": "ljetovanje", "normalized": "ljetovanje", "pos": "noun", "ua": "літній відпочинок; відпустка влітку", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Ove godine ljetovanje planiramo na Korčuli."]}, {"lemma": "ljetovati", "normalized": "ljetovati", "pos": "verb", "ua": "відпочивати влітку (на морі)", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Moji roditelji godinama ljetuju u Makarskoj."]}, {"lemma": "posezona", "normalized": "posezona", "pos": "noun", "ua": "післясезоння (вересень–жовтень)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["U posezoni su cijene niže, a plaže prazne."]}, {"lemma": "glavna sezona", "normalized": "glavna sezona", "pos": "phrase", "ua": "розпал сезону", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U glavnoj sezoni je teško naći slobodan apartman."]}, {"lemma": "primorje", "normalized": "primorje", "pos": "noun", "ua": "узбережжя, приморський край", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Hrvatsko primorje ima puno malih mjesta."]}, {"lemma": "turistička agencija", "normalized": "turisticka agencija", "pos": "phrase", "ua": "туристична агенція", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Putovanje smo kupili u turističkoj agenciji."]}, {"lemma": "paket aranžman", "normalized": "paket aranzman", "pos": "phrase", "ua": "пакетний тур", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Paket aranžman uključuje let, hotel i doručak."]}, {"lemma": "last minute ponuda", "normalized": "last minute ponuda", "pos": "phrase", "ua": "гаряча пропозиція (останньої хвилини)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Našli smo last minute ponudu za Krk."]}, {"lemma": "popust za rani booking", "normalized": "popust za rani booking", "pos": "phrase", "ua": "знижка за раннє бронювання", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ako rezervirate do ožujka, imate popust za rani booking."]}, {"lemma": "proračun", "normalized": "proracun", "pos": "noun", "ua": "бюджет", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Naš proračun za odmor je tisuću eura."]}, {"lemma": "cijena po osobi", "normalized": "cijena po osobi", "pos": "phrase", "ua": "ціна з людини", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Cijena po osobi je osamdeset eura."]}, {"lemma": "turističko mjesto", "normalized": "turisticko mjesto", "pos": "phrase", "ua": "курортне містечко", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Baška je poznato turističko mjesto na Krku."]}, {"lemma": "mirno mjesto", "normalized": "mirno mjesto", "pos": "phrase", "ua": "тихе місце", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["S djecom tražimo neko mirno mjesto."]}, {"lemma": "obiteljski odmor", "normalized": "obiteljski odmor", "pos": "phrase", "ua": "сімейний відпочинок", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Za obiteljski odmor je najbolja pješčana plaža."]}, {"lemma": "pješčana plaža", "normalized": "pjescana plaza", "pos": "phrase", "ua": "піщаний пляж", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na Rabu ima puno pješčanih plaža."]}, {"lemma": "šljunčana plaža", "normalized": "sljuncana plaza", "pos": "phrase", "ua": "гальковий пляж", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Voda je bistra jer je plaža šljunčana."]}, {"lemma": "dostupan", "normalized": "dostupan", "pos": "adjective", "ua": "доступний", "vtype": "core", "forms": {}, "examples": ["Otok je dostupan trajektom i katamaranom."]}, {"lemma": "odlučiti se", "normalized": "odluciti se", "pos": "verb", "ua": "вирішити, зважитися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "odlučivati se"}, "examples": ["Još se nismo odlučili između Istre i Dalmacije."]}, {"lemma": "više bih volio", "normalized": "vise bih volio", "pos": "phrase", "ua": "я б радше хотів", "vtype": "chunk", "forms": {}, "examples": ["Više bih volio otići na neki otok."]}, {"lemma": "vrijedi", "normalized": "vrijedi", "pos": "adverb", "ua": "варто", "vtype": "core", "forms": {}, "examples": ["Vrijedi rezervirati ranije."]}, {"lemma": "isplativ", "normalized": "isplativ", "pos": "adjective", "ua": "вигідний", "vtype": "core", "forms": {}, "examples": ["Putovanje u lipnju je isplativije."]}, {"lemma": "datum polaska", "normalized": "datum polaska", "pos": "phrase", "ua": "дата відправлення", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Još nismo odredili datum polaska."]}, {"lemma": "iznajmljivač", "normalized": "iznajmljivac", "pos": "noun", "ua": "орендодавець (житла туристам)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Iznajmljivač nas je dočekao na parkiralištu."]}, {"lemma": "studio apartman", "normalized": "studio apartman", "pos": "phrase", "ua": "студія (апартаменти)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Studio apartman ima malu kuhinju i kupaonicu."]}, {"lemma": "pomoćni ležaj", "normalized": "pomocni lezaj", "pos": "phrase", "ua": "додаткове ліжко", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Za dijete možemo dodati pomoćni ležaj."]}, {"lemma": "dječji krevetić", "normalized": "djecji krevetic", "pos": "phrase", "ua": "дитяче ліжечко", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Trebamo dječji krevetić za bebu."]}, {"lemma": "slobodan termin", "normalized": "slobodan termin", "pos": "phrase", "ua": "вільна дата", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Imate li slobodan termin od petog do dvanaestog srpnja?"]}, {"lemma": "minimalni boravak", "normalized": "minimalni boravak", "pos": "phrase", "ua": "мінімальний термін проживання", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Minimalni boravak u kolovozu je sedam noći."]}, {"lemma": "predujam", "normalized": "predujam", "pos": "noun", "ua": "передоплата, аванс", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Za potvrdu rezervacije treba uplatiti predujam."]}, {"lemma": "potvrda rezervacije", "normalized": "potvrda rezervacije", "pos": "phrase", "ua": "підтвердження бронювання", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Potvrdu rezervacije smo dobili e-mailom."]}, {"lemma": "otkazivanje", "normalized": "otkazivanje", "pos": "noun", "ua": "скасування", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Besplatno otkazivanje moguće je do trideset dana prije dolaska."]}, {"lemma": "otkazati", "normalized": "otkazati", "pos": "verb", "ua": "скасувати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "otkazivati"}, "examples": ["Moramo otkazati rezervaciju jer je sin bolestan."]}, {"lemma": "uvjeti", "normalized": "uvjeti", "pos": "noun", "ua": "умови", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Pročitajte uvjete prije rezervacije."]}, {"lemma": "boravišna pristojba", "normalized": "boravisna pristojba", "pos": "phrase", "ua": "туристичний податок", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Boravišna pristojba plaća se po osobi i noći."]}, {"lemma": "kućni ljubimac", "normalized": "kucni ljubimac", "pos": "phrase", "ua": "домашній улюбленець", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Jesu li kućni ljubimci dopušteni u apartmanu?"]}, {"lemma": "dopušten", "normalized": "dopusten", "pos": "adjective", "ua": "дозволений", "vtype": "core", "forms": {}, "examples": ["Pušenje nije dopušteno u sobama."]}, {"lemma": "vlastiti ulaz", "normalized": "vlastiti ulaz", "pos": "phrase", "ua": "окремий вхід", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Apartman ima vlastiti ulaz i malu terasu."]}, {"lemma": "zajedničko dvorište", "normalized": "zajednicko dvoriste", "pos": "phrase", "ua": "спільний двір", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Roštilj je u zajedničkom dvorištu."]}, {"lemma": "posteljina i ručnici", "normalized": "posteljina i rucnici", "pos": "phrase", "ua": "постільна білизна й рушники", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Jesu li posteljina i ručnici uključeni u cijenu?"]}, {"lemma": "raspoloživ", "normalized": "raspoloziv", "pos": "adjective", "ua": "доступний, вільний (для бронювання)", "vtype": "core", "forms": {}, "examples": ["Apartman je raspoloživ samo u lipnju."]}, {"lemma": "nadoplata", "normalized": "nadoplata", "pos": "noun", "ua": "доплата", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Za pomoćni ležaj nema nadoplate."]}, {"lemma": "dočekati", "normalized": "docekati", "pos": "verb", "ua": "зустріти (того, хто приїхав)", "vtype": "core", "forms": {"aspect": "pfv", "pair": "dočekivati"}, "examples": ["Domaćica će nas dočekati ispred kuće."]}, {"lemma": "kasni dolazak", "normalized": "kasni dolazak", "pos": "phrase", "ua": "пізній приїзд", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Kasni dolazak nije problem, ključ je u kutiji."]}, {"lemma": "povrat predujma", "normalized": "povrat predujma", "pos": "phrase", "ua": "повернення передоплати", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Povrat predujma moguć je do trideset dana prije dolaska."]}, {"lemma": "prijava gostiju", "normalized": "prijava gostiju", "pos": "phrase", "ua": "реєстрація гостей", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za prijavu gostiju trebamo vaše putovnice."]}, {"lemma": "kartica za sobu", "normalized": "kartica za sobu", "pos": "phrase", "ua": "картка-ключ від номера", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Kartica za sobu ne radi, vrata se ne otvaraju."]}, {"lemma": "lozinka za wi-fi", "normalized": "lozinka za wi-fi", "pos": "phrase", "ua": "пароль від wi-fi", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Lozinka za wi-fi je na stolu u sobi."]}, {"lemma": "doručak je uključen", "normalized": "dorucak je ukljucen", "pos": "phrase", "ua": "сніданок включено", "vtype": "chunk", "forms": {}, "examples": ["Doručak je uključen u cijenu sobe."]}, {"lemma": "ne radi", "normalized": "ne radi", "pos": "phrase", "ua": "не працює", "vtype": "chunk", "forms": {}, "examples": ["Klima u sobi ne radi."]}, {"lemma": "pokvaren", "normalized": "pokvaren", "pos": "adjective", "ua": "зламаний, несправний", "vtype": "core", "forms": {}, "examples": ["Daljinski upravljač je pokvaren."]}, {"lemma": "curiti", "normalized": "curiti", "pos": "verb", "ua": "текти, протікати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["U kupaonici curi voda ispod umivaonika."]}, {"lemma": "tuš kabina", "normalized": "tus kabina", "pos": "phrase", "ua": "душова кабіна", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Vrata tuš kabine se ne zatvaraju."]}, {"lemma": "komarac", "normalized": "komarac", "pos": "noun", "ua": "комар", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Noću nas grizu komarci."]}, {"lemma": "mrežica protiv komaraca", "normalized": "mrezica protiv komaraca", "pos": "phrase", "ua": "москітна сітка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na prozoru nema mrežice protiv komaraca."]}, {"lemma": "miris", "normalized": "miris", "pos": "noun", "ua": "запах", "vtype": "core", "forms": {"gender": "m"}, "examples": ["U sobi je neugodan miris."]}, {"lemma": "druga soba", "normalized": "druga soba", "pos": "phrase", "ua": "інший номер", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Biste li nam mogli dati drugu sobu?"]}, {"lemma": "premjestiti", "normalized": "premjestiti", "pos": "verb", "ua": "переселити, перемістити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "premještati"}, "examples": ["Premjestit ćemo vas u sobu s pogledom."]}, {"lemma": "pogledati", "normalized": "pogledati", "pos": "verb", "ua": "подивитися, оглянути", "vtype": "core", "forms": {"aspect": "pfv", "pair": "gledati"}, "examples": ["Netko će odmah pogledati klimu."]}, {"lemma": "riješiti problem", "normalized": "rijesiti problem", "pos": "phrase", "ua": "розв’язати проблему", "vtype": "chunk", "forms": {}, "examples": ["Ako ne riješite problem, želimo drugu sobu."]}, {"lemma": "ispričavamo se", "normalized": "ispricavamo se", "pos": "phrase", "ua": "просимо вибачення", "vtype": "chunk", "forms": {}, "examples": ["Ispričavamo se zbog neugodnosti."]}, {"lemma": "neugodnost", "normalized": "neugodnost", "pos": "noun", "ua": "незручність, неприємність", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Zbog neugodnosti dobivate besplatnu večeru."]}, {"lemma": "ne zatvara se", "normalized": "ne zatvara se", "pos": "phrase", "ua": "не зачиняється", "vtype": "chunk", "forms": {}, "examples": ["Prozor se ne zatvara do kraja."]}, {"lemma": "rolete", "normalized": "rolete", "pos": "noun", "ua": "ролети", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Rolete se ne mogu spustiti."]}, {"lemma": "zaglaviti se", "normalized": "zaglaviti se", "pos": "verb", "ua": "заклинити, застрягти", "vtype": "core", "forms": {"aspect": "pfv", "pair": "zaglavljivati se"}, "examples": ["Ključ se zaglavio u bravi."]}, {"lemma": "razbijen", "normalized": "razbijen", "pos": "adjective", "ua": "розбитий", "vtype": "core", "forms": {}, "examples": ["Ogledalo u kupaonici je razbijeno."]}, {"lemma": "zastor", "normalized": "zastor", "pos": "noun", "ua": "штора", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Zastor na prozoru je potrgan."]}, {"lemma": "riblji restoran", "normalized": "riblji restoran", "pos": "phrase", "ua": "рибний ресторан", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["U luci je dobar riblji restoran."]}, {"lemma": "svježa riba", "normalized": "svjeza riba", "pos": "phrase", "ua": "свіжа риба", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Je li ovo svježa riba ili smrznuta?"]}, {"lemma": "ulov dana", "normalized": "ulov dana", "pos": "phrase", "ua": "улов дня", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Danas je ulov dana orada."]}, {"lemma": "brancin", "normalized": "brancin", "pos": "noun", "ua": "сибас (риба)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Brancin na žaru je specijalitet kuće."]}, {"lemma": "dagnje", "normalized": "dagnje", "pos": "noun", "ua": "мідії", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Dagnje su iz Malostonskog zaljeva."]}, {"lemma": "hobotnica ispod peke", "normalized": "hobotnica ispod peke", "pos": "phrase", "ua": "восьминіг під пекою", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Hobotnicu ispod peke treba naručiti dan ranije."]}, {"lemma": "na buzaru", "normalized": "na buzaru", "pos": "phrase", "ua": "на бузару (у соусі з вином і часником)", "vtype": "chunk", "forms": {}, "examples": ["Kuhamo dagnje na buzaru."]}, {"lemma": "cijena po kilogramu", "normalized": "cijena po kilogramu", "pos": "phrase", "ua": "ціна за кілограм", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Riba se plaća po kilogramu, cijena po kilogramu je na jelovniku."]}, {"lemma": "preporučiti", "normalized": "preporuciti", "pos": "verb", "ua": "порадити, рекомендувати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "preporučivati"}, "examples": ["Što biste nam preporučili?"]}, {"lemma": "domaće vino", "normalized": "domace vino", "pos": "phrase", "ua": "домашнє вино", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Pola litre domaćeg vina, molim."]}, {"lemma": "pola litre", "normalized": "pola litre", "pos": "phrase", "ua": "пів літра", "vtype": "chunk", "forms": {}, "examples": ["Donesite nam pola litre vode."]}, {"lemma": "kruh i maslinovo ulje", "normalized": "kruh i maslinovo ulje", "pos": "phrase", "ua": "хліб і оливкова олія", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Kruh i maslinovo ulje dolaze prije jela."]}, {"lemma": "stol uz more", "normalized": "stol uz more", "pos": "phrase", "ua": "столик біля моря", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Imate li slobodan stol uz more?"]}, {"lemma": "pogreška u računu", "normalized": "pogreska u racunu", "pos": "phrase", "ua": "помилка в рахунку", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Mislim da je pogreška u računu."]}, {"lemma": "zasebno", "normalized": "zasebno", "pos": "adverb", "ua": "окремо", "vtype": "core", "forms": {}, "examples": ["Možemo li platiti zasebno?"]}, {"lemma": "zubatac", "normalized": "zubatac", "pos": "noun", "ua": "зубан (риба)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Zubatac je skuplji od orade."]}, {"lemma": "srdele", "normalized": "srdele", "pos": "noun", "ua": "сардини", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Pržene srdele su jeftine i ukusne."]}, {"lemma": "kamenice", "normalized": "kamenice", "pos": "noun", "ua": "устриці", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Kamenice iz Stona poznate su u cijelom svijetu."]}, {"lemma": "riblja juha", "normalized": "riblja juha", "pos": "phrase", "ua": "рибна юшка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za predjelo uzmimo riblju juhu."]}, {"lemma": "pošip", "normalized": "posip", "pos": "noun", "ua": "пошип (біле вино з Корчули)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Uz ribu preporučujem pošip s Korčule."]}, {"lemma": "polovica porcije", "normalized": "polovica porcije", "pos": "phrase", "ua": "пів порції", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Može li polovica porcije za dijete?"]}, {"lemma": "dječja porcija", "normalized": "djecja porcija", "pos": "phrase", "ua": "дитяча порція", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Imate li dječje porcije?"]}, {"lemma": "trajektna linija", "normalized": "trajektna linija", "pos": "phrase", "ua": "поромна лінія", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Trajektna linija Split – Supetar vozi cijeli dan."]}, {"lemma": "katamaran", "normalized": "katamaran", "pos": "noun", "ua": "катамаран", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Katamaran je brži, ali ne prevozi automobile."]}, {"lemma": "red vožnje", "normalized": "red voznje", "pos": "phrase", "ua": "розклад руху", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ljetni red vožnje počinje u lipnju."]}, {"lemma": "pristanište", "normalized": "pristaniste", "pos": "noun", "ua": "пристань", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Trajekt pristaje na novom pristaništu."]}, {"lemma": "karta za vozilo", "normalized": "karta za vozilo", "pos": "phrase", "ua": "квиток на авто", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Karta za vozilo je skuplja od karte za putnika."]}, {"lemma": "ukrcati se", "normalized": "ukrcati se", "pos": "verb", "ua": "сісти (на борт), завантажитися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "ukrcavati se"}, "examples": ["Vozači se ukrcavaju prvi."]}, {"lemma": "iskrcati se", "normalized": "iskrcati se", "pos": "verb", "ua": "зійти (з борту), вивантажитися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "iskrcavati se"}, "examples": ["Na Hvaru se iskrcavamo u Starom Gradu."]}, {"lemma": "čekati u koloni", "normalized": "cekati u koloni", "pos": "phrase", "ua": "чекати в черзі (автомобілів)", "vtype": "chunk", "forms": {}, "examples": ["Ljeti se satima čeka u koloni."]}, {"lemma": "prekid plovidbe", "normalized": "prekid plovidbe", "pos": "phrase", "ua": "зупинка рейсів (на морі)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Zbog bure je prekid plovidbe."]}, {"lemma": "nevrijeme", "normalized": "nevrijeme", "pos": "noun", "ua": "негода", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Zbog nevremena katamaran danas ne vozi."]}, {"lemma": "valovit", "normalized": "valovit", "pos": "adjective", "ua": "хвилястий, з хвилями", "vtype": "core", "forms": {}, "examples": ["More je danas jako valovito."]}, {"lemma": "morska bolest", "normalized": "morska bolest", "pos": "phrase", "ua": "морська хвороба", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Ako imaš morsku bolest, sjedni u sredinu broda."]}, {"lemma": "paluba", "normalized": "paluba", "pos": "noun", "ua": "палуба", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Na palubi je lijep pogled na otoke."]}, {"lemma": "pramac", "normalized": "pramac", "pos": "noun", "ua": "ніс (корабля)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Djeca stoje na pramcu i gledaju dupine."]}, {"lemma": "krma", "normalized": "krma", "pos": "noun", "ua": "корма", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Automobili izlaze na krmi."]}, {"lemma": "prevoziti", "normalized": "prevoziti", "pos": "verb", "ua": "перевозити", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Ovaj trajekt prevozi i kamione."]}, {"lemma": "Jadrolinija", "normalized": "jadrolinija", "pos": "noun", "ua": "Ядролінія (хорватська поромна компанія)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Kartu smo kupili na stranici Jadrolinije."]}, {"lemma": "kasniti", "normalized": "kasniti", "pos": "verb", "ua": "запізнюватися", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Trajekt kasni pola sata."]}, {"lemma": "pomorski", "normalized": "pomorski", "pos": "adjective", "ua": "морський", "vtype": "core", "forms": {}, "examples": ["Pomorski promet je danas otežan."]}, {"lemma": "lučka kapetanija", "normalized": "lucka kapetanija", "pos": "phrase", "ua": "капітанія порту (портова адміністрація)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Lučka kapetanija je zabranila plovidbu."]}, {"lemma": "ljuljati se", "normalized": "ljuljati se", "pos": "verb", "ua": "гойдатися", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Brod se jako ljulja na valovima."]}, {"lemma": "meduza", "normalized": "meduza", "pos": "noun", "ua": "медуза", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Danas ima puno meduza u uvali."]}, {"lemma": "ježinac", "normalized": "jezinac", "pos": "noun", "ua": "морський їжак", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Pazi, na stijenama ima ježinaca!"]}, {"lemma": "spasilac", "normalized": "spasilac", "pos": "noun", "ua": "рятувальник", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Spasilac radi do sedam navečer."]}, {"lemma": "cipelice za more", "normalized": "cipelice za more", "pos": "phrase", "ua": "взуття для моря (аквашузи)", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Uzmi cipelice za more zbog ježinaca."]}, {"lemma": "uvala", "normalized": "uvala", "pos": "noun", "ua": "бухта, затока", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Našli smo malu uvalu bez ljudi."]}, {"lemma": "stijene", "normalized": "stijene", "pos": "noun", "ua": "скелі, каміння (біля моря)", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Djeca skaču sa stijena u more."]}, {"lemma": "plićak", "normalized": "plicak", "pos": "noun", "ua": "мілина", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Mala djeca se kupaju u plićaku."]}, {"lemma": "dubina", "normalized": "dubina", "pos": "noun", "ua": "глибина", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ovdje je dubina dva metra."]}, {"lemma": "struja", "normalized": "struja", "pos": "noun", "ua": "течія", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ne plivaj daleko, ondje je jaka struja."]}, {"lemma": "plutača", "normalized": "plutaca", "pos": "noun", "ua": "буй", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ne smije se plivati iza plutača."]}, {"lemma": "sunčati se", "normalized": "suncati se", "pos": "verb", "ua": "засмагати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Volim se sunčati ujutro dok nije prevruće."]}, {"lemma": "izgorjeti na suncu", "normalized": "izgorjeti na suncu", "pos": "phrase", "ua": "обгоріти на сонці", "vtype": "chunk", "forms": {}, "examples": ["Izgorjela sam na suncu prvi dan."]}, {"lemma": "zaštitni faktor", "normalized": "zastitni faktor", "pos": "phrase", "ua": "фактор захисту (SPF)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Djeci treba krema sa zaštitnim faktorom pedeset."]}, {"lemma": "hlad", "normalized": "hlad", "pos": "noun", "ua": "тінь, прохолода", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Sjednimo u hlad ispod borova."]}, {"lemma": "ronilačka maska", "normalized": "ronilacka maska", "pos": "phrase", "ua": "маска для пірнання", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["S ronilačkom maskom vidiš ribe."]}, {"lemma": "disalica", "normalized": "disalica", "pos": "noun", "ua": "трубка (для плавання)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Kupila sam sinu masku i disalicu."]}, {"lemma": "peraje", "normalized": "peraje", "pos": "noun", "ua": "ласти", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["S perajama plivam puno brže."]}, {"lemma": "napuhati", "normalized": "napuhati", "pos": "verb", "ua": "надути", "vtype": "core", "forms": {"aspect": "pfv", "pair": "napuhavati"}, "examples": ["Tata, možeš li napuhati madrac?"]}, {"lemma": "madrac za plažu", "normalized": "madrac za plazu", "pos": "phrase", "ua": "надувний матрац", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Vjetar je odnio madrac za plažu."]}, {"lemma": "nudistička plaža", "normalized": "nudisticka plaza", "pos": "phrase", "ua": "нудистський пляж", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Iza rta je nudistička plaža."]}, {"lemma": "ubod", "normalized": "ubod", "pos": "noun", "ua": "укус, ужалення", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Na ubod meduze stavi hladnu vodu i ocat."]}, {"lemma": "temperatura mora", "normalized": "temperatura mora", "pos": "phrase", "ua": "температура моря", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Temperatura mora danas je dvadeset četiri stupnja."]}, {"lemma": "ulaznica s vremenskim terminom", "normalized": "ulaznica s vremenskim terminom", "pos": "phrase", "ua": "квиток на певний час", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Ljeti se kupuje ulaznica s vremenskim terminom."]}, {"lemma": "online kupnja", "normalized": "online kupnja", "pos": "phrase", "ua": "купівля онлайн", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Online kupnja je jeftinija nego na ulazu."]}, {"lemma": "obilazak", "normalized": "obilazak", "pos": "noun", "ua": "огляд, обхід (маршрут)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Obilazak traje oko četiri sata."]}, {"lemma": "pješačka staza", "normalized": "pjesacka staza", "pos": "phrase", "ua": "пішохідна стежка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Pješačka staza vodi uz jezera."]}, {"lemma": "drvena staza", "normalized": "drvena staza", "pos": "phrase", "ua": "дерев’яна стежка (настил)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na Plitvicama se hoda po drvenim stazama."]}, {"lemma": "vidikovac", "normalized": "vidikovac", "pos": "noun", "ua": "оглядовий майданчик", "vtype": "core", "forms": {"gender": "m"}, "examples": ["S vidikovca se vidi cijelo jezero."]}, {"lemma": "panoramski vlak", "normalized": "panoramski vlak", "pos": "phrase", "ua": "панорамний потяг (у парку)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Panoramski vlak vozi do gornjih jezera."]}, {"lemma": "brod na električni pogon", "normalized": "brod na elektricni pogon", "pos": "phrase", "ua": "електрочовен", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Preko jezera se vozimo brodom na električni pogon."]}, {"lemma": "hraniti životinje", "normalized": "hraniti zivotinje", "pos": "phrase", "ua": "годувати тварин", "vtype": "chunk", "forms": {}, "examples": ["Zabranjeno je hraniti životinje."]}, {"lemma": "vodopad", "normalized": "vodopad", "pos": "noun", "ua": "водоспад", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Veliki vodopad je visok sedamdeset osam metara."]}, {"lemma": "organizirani izlet", "normalized": "organizirani izlet", "pos": "phrase", "ua": "організована екскурсія", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Organizirani izlet uključuje prijevoz i vodiča."]}, {"lemma": "polazna točka", "normalized": "polazna tocka", "pos": "phrase", "ua": "місце відправлення, старт", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Polazna točka je ispred hotela."]}, {"lemma": "udobna obuća", "normalized": "udobna obuca", "pos": "phrase", "ua": "зручне взуття", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za obilazak trebate udobnu obuću."]}, {"lemma": "dostupno za invalidska kolica", "normalized": "dostupno za invalidska kolica", "pos": "phrase", "ua": "доступно для візків", "vtype": "chunk", "forms": {}, "examples": ["Jedna staza je dostupna za invalidska kolica."]}, {"lemma": "posjetitelj", "normalized": "posjetitelj", "pos": "noun", "ua": "відвідувач", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Park ima tisuće posjetitelja dnevno."]}, {"lemma": "radno vrijeme parka", "normalized": "radno vrijeme parka", "pos": "phrase", "ua": "години роботи парку", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Radno vrijeme parka ljeti je od sedam do osam."]}, {"lemma": "pješačenje", "normalized": "pjesacenje", "pos": "noun", "ua": "піші прогулянки, хайкінг", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Volimo pješačenje po planinama."]}, {"lemma": "najam bicikla", "normalized": "najam bicikla", "pos": "phrase", "ua": "прокат велосипеда", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Na ulazu postoji najam bicikla."]}, {"lemma": "netaknut", "normalized": "netaknut", "pos": "adjective", "ua": "незайманий", "vtype": "core", "forms": {}, "examples": ["Ovdje je priroda netaknuta."]}, {"lemma": "zaštićeno područje", "normalized": "zasticeno podrucje", "pos": "phrase", "ua": "охоронювана територія", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Cijeli kanjon je zaštićeno područje."]}, {"lemma": "pravila ponašanja", "normalized": "pravila ponasanja", "pos": "phrase", "ua": "правила поведінки", "vtype": "chunk", "forms": {"gender": "n_pl"}, "examples": ["Na ulazu su istaknuta pravila ponašanja u parku."]}, {"lemma": "rent-a-car", "normalized": "rent-a-car", "pos": "noun", "ua": "прокат авто", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Rent-a-car je odmah pored zračne luke."]}, {"lemma": "skuter", "normalized": "skuter", "pos": "noun", "ua": "скутер", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Na otoku je najlakše voziti se skuterom."]}, {"lemma": "brodica", "normalized": "brodica", "pos": "noun", "ua": "човен, моторний човник", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Unajmili smo brodicu za cijeli dan."]}, {"lemma": "gliser", "normalized": "gliser", "pos": "noun", "ua": "швидкісний моторний човен", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Za gliser treba imati dozvolu."]}, {"lemma": "dozvola za upravljanje brodicom", "normalized": "dozvola za upravljanje brodicom", "pos": "phrase", "ua": "посвідчення на керування човном", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Imate li dozvolu za upravljanje brodicom?"]}, {"lemma": "kaciga", "normalized": "kaciga", "pos": "noun", "ua": "шолом", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Bez kacige ne smijete voziti skuter."]}, {"lemma": "dnevni najam", "normalized": "dnevni najam", "pos": "phrase", "ua": "добова оренда", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Dnevni najam skutera je četrdeset eura."]}, {"lemma": "kasko osiguranje", "normalized": "kasko osiguranje", "pos": "phrase", "ua": "страхування каско", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Kasko osiguranje pokriva i štetu na autu."]}, {"lemma": "franšiza", "normalized": "fransiza", "pos": "noun", "ua": "франшиза (страхова)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Franšiza je petsto eura."]}, {"lemma": "blokirati na kartici", "normalized": "blokirati na kartici", "pos": "phrase", "ua": "заблокувати на картці (суму)", "vtype": "chunk", "forms": {}, "examples": ["Kauciju ćemo blokirati na kartici."]}, {"lemma": "pun spremnik", "normalized": "pun spremnik", "pos": "phrase", "ua": "повний бак", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Auto dobivate s punim spremnikom."]}, {"lemma": "vratiti s punim spremnikom", "normalized": "vratiti s punim spremnikom", "pos": "phrase", "ua": "повернути з повним баком", "vtype": "chunk", "forms": {}, "examples": ["Molimo Vas da auto vratite s punim spremnikom."]}, {"lemma": "ogrebotina", "normalized": "ogrebotina", "pos": "noun", "ua": "подряпина", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Na vratima je mala ogrebotina."]}, {"lemma": "oštećenje", "normalized": "ostecenje", "pos": "noun", "ua": "пошкодження", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Zapisali smo sva oštećenja prije najma."]}, {"lemma": "dodatni vozač", "normalized": "dodatni vozac", "pos": "phrase", "ua": "додатковий водій", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Dodatni vozač se plaća deset eura dnevno."]}, {"lemma": "ograničenje kilometara", "normalized": "ogranicenje kilometara", "pos": "phrase", "ua": "обмеження пробігу", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Najam je bez ograničenja kilometara."]}, {"lemma": "automatski mjenjač", "normalized": "automatski mjenjac", "pos": "phrase", "ua": "автоматична коробка передач", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Trebam auto s automatskim mjenjačem."]}, {"lemma": "vratiti vozilo", "normalized": "vratiti vozilo", "pos": "phrase", "ua": "повернути транспорт", "vtype": "chunk", "forms": {}, "examples": ["Vozilo morate vratiti do osamnaest sati."]}, {"lemma": "sidro", "normalized": "sidro", "pos": "noun", "ua": "якір", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Bacili smo sidro u maloj uvali."]}, {"lemma": "benzinska postaja na moru", "normalized": "benzinska postaja na moru", "pos": "phrase", "ua": "плавуча заправка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Gorivo za brodicu kupujemo na benzinskoj postaji na moru."]}, {"lemma": "mjesto preuzimanja", "normalized": "mjesto preuzimanja", "pos": "phrase", "ua": "місце отримання (авто)", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Mjesto preuzimanja je zračna luka Split."]}, {"lemma": "kilometraža", "normalized": "kilometraza", "pos": "noun", "ua": "пробіг", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Zapišite kilometražu kad preuzmete auto."]}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 2. Уроки модуля A2.1
-- A2.1 · урок 1: Плануємо відпустку на узбережжі — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '11809ea9-712b-5fb7-b4a6-8a5fb60f7d62';
  v_lesson constant uuid := '07da4162-a209-5893-8f3c-db3571a32f29';
  v_gid constant uuid := '0c68352a-803a-5410-a59b-91f2c1ddc49f';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KOND'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A2.1: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 1: Плануємо відпустку на узбережжі', 'Lekcija 1: Planiramo ljetovanje na obali', '["Обговорити, куди й коли поїхати на море: ljetovanje, posezona, paket aranžman", "Ввічливо висловити бажання: htio bih, više bih volio"]'::jsonb, 20, 'PUBLISHED', 1);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'ljetovanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljetovati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posezona', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glavna sezona', v_pos);
  v_pos := pg_temp.word(v_lesson, 'primorje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'turistička agencija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'paket aranžman', v_pos);
  v_pos := pg_temp.word(v_lesson, 'last minute ponuda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'popust za rani booking', v_pos);
  v_pos := pg_temp.word(v_lesson, 'proračun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cijena po osobi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'turističko mjesto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mirno mjesto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obiteljski odmor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pješčana plaža', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šljunčana plaža', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dostupan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odlučiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'više bih volio', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrijedi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'isplativ', v_pos);
  v_pos := pg_temp.word(v_lesson, 'datum polaska', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '8ecafa4e-5a1d-5db2-9c24-73d47dde4981', 'fill_in_the_blank', 'Mi ___ htjeli otići na more u rujnu.', 'bismo', '["bismo", "bi", "biste", "bih"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7a3f255e-0576-5847-a712-5199b1582804', 'multiple_choice', 'Що означає «ljetovanje»?', 'літній відпочинок; відпустка влітку', '["літній відпочинок; відпустка влітку", "гаряча пропозиція (останньої хвилини)", "дата відправлення", "доступний"]'::jsonb, 'A2', 2, 'PUBLISHED', 'ljetovanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd347e090-23f8-554d-a236-7395a5b14d3f', 'multiple_choice', 'Що означає «dostupan»?', 'доступний', '["тихе місце", "варто", "доступний", "вигідний"]'::jsonb, 'A2', 3, 'PUBLISHED', 'dostupan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c1fdaa47-2877-5dc1-9c7c-264fcbb152e5', 'multiple_choice', 'Що означає «ljetovati»?', 'відпочивати влітку (на морі)', '["розпал сезону", "ціна з людини", "відпочивати влітку (на морі)", "туристична агенція"]'::jsonb, 'A2', 4, 'PUBLISHED', 'ljetovati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2de1060e-5fbd-59f3-8176-d6a3c9e40e8d', 'multiple_choice', 'Як хорватською «туристична агенція»?', 'turistička agencija', '["datum polaska", "turistička agencija", "dostupan", "isplativ"]'::jsonb, 'A2', 5, 'PUBLISHED', 'turistička agencija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e3756682-6c1c-56f5-9fdf-58d8c910e0df', 'multiple_choice', 'Як хорватською «бюджет»?', 'proračun', '["glavna sezona", "proračun", "turističko mjesto", "primorje"]'::jsonb, 'A2', 6, 'PUBLISHED', 'proračun', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5cccbf33-f93c-5e31-94d4-db00cdf031bf', 'type_answer', 'Напишіть хорватською: «пакетний тур»', 'paket aranžman', null, 'A2', 7, 'PUBLISHED', 'paket aranžman', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e4e86601-dc06-5ace-b696-e6e60503c4fc', 'type_answer', 'Напишіть хорватською: «вирішити, зважитися»', 'odlučiti se', null, 'A2', 8, 'PUBLISHED', 'odlučiti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9e3c807e-ae2e-56d5-9c2b-1776b60116ef', 'type_answer', 'Напишіть хорватською: «розпал сезону»', 'glavna sezona', null, 'A2', 9, 'PUBLISHED', 'glavna sezona', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd68ad08-57f8-5b28-b7b2-5b4c2eefb0a5', 'sentence_builder', 'Складіть: «Я хотіла б тихе місце біля моря.»', 'Htjela bih mirno mjesto uz more.', '["more.", "uz", "mjesto", "bih", "Htjela", "mirno"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6dfb0584-2d6d-513b-963e-bd8af542261a', 'sentence_builder', 'Складіть: «У післясезоння ціни нижчі.»', 'U posezoni su cijene niže.', '["niže.", "U", "su", "posezoni", "cijene"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ac4386c2-0dc7-56af-8740-ee5f0afb6c26', 'listening', 'Прослухайте і складіть фразу', 'Kakav je Vaš proračun?', '["Vaš", "je", "Kakav", "proračun?"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '05031be6-8ab6-5587-ad6c-853249d09f5a', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'у вересні; 30 євро; бо закінчується знижка', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Подруга Даша залишила вам голосове повідомлення про відпустку.", "script": [{"hr": "Bok, ovdje Daša! Razmišljala sam o našem ljetovanju.", "ua": "Привіт, це Даша! Я думала про наш літній відпочинок."}, {"hr": "U kolovozu je preskupo, pa bih radije išla u rujnu, u posezoni.", "ua": "У серпні задорого, тож я б радше поїхала у вересні, у післясезоння."}, {"hr": "Našla sam apartman na Visu, cijena po osobi je trideset eura po noći.", "ua": "Я знайшла апартаменти на Вісі, ціна з людини — тридцять євро за ніч."}, {"hr": "Javi mi do petka, jer se popust tada završava.", "ua": "Дай мені знати до п’ятниці, бо тоді закінчується знижка."}], "questions": [{"q_ua": "Коли Даша хоче поїхати?", "options": ["у серпні", "у вересні", "у липні"], "correct": 1, "answer_turn": 1}, {"q_ua": "Скільки коштує ніч з людини?", "options": ["30 євро", "13 євро", "300 євро"], "correct": 0, "answer_turn": 2}, {"q_ua": "Чому треба відповісти до п’ятниці?", "options": ["бо апартаменти продадуть", "бо Даша їде", "бо закінчується знижка"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '05031be6-8ab6-5587-ad6c-853249d09f5a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ad162a00-3d27-5adb-9cf3-bb1b093a5558', 'speaking', 'Я хотів би пакетний тур на Крк.', 'Htio bih paket aranžman za Krk.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1b2bfcb1-0a64-5cc5-adc0-a80c7f71bc90', 'speaking', 'Чи варто бронювати раніше?', 'Vrijedi li rezervirati ranije?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'd597e604-3a9e-5755-87ac-8b3f28db3b02', 'write_message', 'Напишіть подрузі Даші: ви хотіли б поїхати на море в післясезоння, у тихе місце, і спитайте, чи вона поїде з вами.', 'Dašo, htjela bih ići na more u posezoni, u neko mirno mjesto. Ideš li s nama?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі Даші: ви хотіли б поїхати на море в післясезоння, у тихе місце, і спитайте, чи вона поїде з вами.", "points": [{"ua": "у післясезоння", "keys": [["posezon"], ["rujn"]]}, {"ua": "тихе місце", "keys": [["mirn"]]}, {"ua": "чи поїде вона з вами", "keys": [["s nama"], ["sa mnom"], ["s tobom"]]}], "hints": ["htjela bih", "u posezoni", "mirno mjesto", "ideš li s nama?"], "models": ["Dašo, htjela bih ići na more u posezoni, u neko mirno mjesto. Ideš li s nama?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'd597e604-3a9e-5755-87ac-8b3f28db3b02', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '19ed6509-6a5b-5a8d-af46-8b6cdd1da7a3', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Naš proračun je tisuću eura. Htjeli bismo pješčanu plažu za djecu.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи агентові, що в нас бюджет тисяча євро і ми хотіли б піщаний пляж для дітей.", "direction": "ua_hr", "points": [{"ua": "бюджет тисяча євро", "keys": [["tisuć"]]}, {"ua": "піщаний пляж", "keys": [["pješčan"]]}, {"ua": "для дітей", "keys": [["djec"]]}], "hints": [], "models": ["Naš proračun je tisuću eura. Htjeli bismo pješčanu plažu za djecu."], "source_ua": "Скажи агентові, що в нас бюджет тисяча євро і ми хотіли б піщаний пляж для дітей."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '19ed6509-6a5b-5a8d-af46-8b6cdd1da7a3', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('847919cd-587a-54e0-9ad8-8ae9e4d8486c', v_lesson, 'Куди цього літа?', 'Kamo ovo ljeto?', 5011, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('2732d8a9-efb4-50cf-8468-931e6c9f7baa', '847919cd-587a-54e0-9ad8-8ae9e4d8486c', 'Daša', 'Darja, gdje biste vi htjeli ljetovati ove godine?', 'Дар’є, де б ви хотіли відпочивати цього літа?', 1);
  perform pg_temp.turn('e086bc9d-3e10-5b22-a178-d98a48c3650b', '847919cd-587a-54e0-9ad8-8ae9e4d8486c', 'Darja', 'Mi bismo htjeli neko mirno mjesto, bez velike gužve.', 'Ми хотіли б якесь тихе місце, без великого натовпу.', 2);
  perform pg_temp.turn('2775c4fe-ed8c-522d-8a09-029675105002', '847919cd-587a-54e0-9ad8-8ae9e4d8486c', 'Daša', 'Onda idite u posezoni. U glavnoj sezoni je sve puno.', 'Тоді їдьте в післясезоння. У розпал сезону все заповнено.', 3);
  perform pg_temp.turn('1e0cd492-2c33-52eb-baea-f028d77bbd0a', '847919cd-587a-54e0-9ad8-8ae9e4d8486c', 'Darja', 'Djeca idu u školu, pa moramo u srpnju ili kolovozu.', 'Діти ходять до школи, тож маємо їхати в липні чи серпні.', 4);
  perform pg_temp.turn('76202607-bb1d-5701-a6c6-9958f35d310a', '847919cd-587a-54e0-9ad8-8ae9e4d8486c', 'Daša', 'Onda rezervirajte rano. Vrijedi, imate popust za rani booking.', 'Тоді бронюйте рано. Варто, у вас буде знижка за раннє бронювання.', 5);
  perform pg_temp.turn('e9c31c7a-a247-5ec8-80c3-1341b6873871', '847919cd-587a-54e0-9ad8-8ae9e4d8486c', 'Darja', 'Dobra ideja. Više bih volila šljunčanu plažu, voda je bistrija.', 'Добра ідея. Я б радше хотіла гальковий пляж, вода чистіша.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('dff6eefa-14a2-53b7-a885-1daa0a0ea1df', v_lesson, 'У туристичній агенції', 'U turističkoj agenciji', 5012, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('7482073a-a10e-5590-9b18-6fd761519d52', 'dff6eefa-14a2-53b7-a885-1daa0a0ea1df', 'Agent', 'Dobar dan! Kako Vam mogu pomoći?', 'Добрий день! Чим можу вам допомогти?', 1);
  perform pg_temp.turn('cbf7b27a-f445-5bde-b01f-32320fd0a5b4', 'dff6eefa-14a2-53b7-a885-1daa0a0ea1df', 'Marko', 'Htio bih neki paket aranžman za obiteljski odmor.', 'Я хотів би якийсь пакетний тур для сімейного відпочинку.', 2);
  perform pg_temp.turn('7a754e64-4bc2-590a-b811-17828cc2f1b1', 'dff6eefa-14a2-53b7-a885-1daa0a0ea1df', 'Agent', 'Kakav je Vaš proračun?', 'Який у вас бюджет?', 3);
  perform pg_temp.turn('f03dc52d-5f2b-580e-8e37-c1a42dc5d3a1', 'dff6eefa-14a2-53b7-a885-1daa0a0ea1df', 'Marko', 'Do osamsto eura za četvero, ako je moguće.', 'До вісімсот євро на чотирьох, якщо можливо.', 4);
  perform pg_temp.turn('ad9fb0e2-f4e9-5ae8-957d-07581e97ae9b', 'dff6eefa-14a2-53b7-a885-1daa0a0ea1df', 'Agent', 'Imamo last minute ponudu za Rab: cijena po osobi je dvjesto eura.', 'Маємо гарячу пропозицію на Раб: ціна з людини — двісті євро.', 5);
  perform pg_temp.turn('8e55d71d-85fe-5a5b-a9d2-d30047ee4919', 'dff6eefa-14a2-53b7-a885-1daa0a0ea1df', 'Marko', 'Odlično, to se isplati. Je li plaža pješčana?', 'Чудово, це вигідно. Пляж піщаний?', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.1 · урок 2: Бронюємо житло в приватних господарів — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '11809ea9-712b-5fb7-b4a6-8a5fb60f7d62';
  v_lesson constant uuid := '2aaf70f9-5a0c-53a3-a621-e42cc4548661';
  v_gid constant uuid := '0c68352a-803a-5410-a59b-91f2c1ddc49f';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KOND'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A2.1: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 2: Бронюємо житло в приватних господарів', 'Lekcija 2: Rezerviramo privatni smještaj', '["Забронювати апартаменти й уточнити умови: predujam, otkazivanje, boravišna pristojba", "Ввічливо спитати: Biste li mogli…? Bi li bilo moguće…?"]'::jsonb, 20, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'iznajmljivač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'studio apartman', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pomoćni ležaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dječji krevetić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slobodan termin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'minimalni boravak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predujam', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potvrda rezervacije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otkazivanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otkazati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uvjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'boravišna pristojba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kućni ljubimac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dopušten', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vlastiti ulaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zajedničko dvorište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posteljina i ručnici', v_pos);
  v_pos := pg_temp.word(v_lesson, 'raspoloživ', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nadoplata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dočekati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kasni dolazak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povrat predujma', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '90b2d351-b5c1-5465-8f2a-b50168b30e21', 'fill_in_the_blank', '___ li mogli poslati potvrdu rezervacije?', 'Biste', '["Biste", "Bi", "Bih", "Bismo"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b0812a9e-b484-5239-a5e6-b6c27f2d793d', 'multiple_choice', 'Що означає «zajedničko dvorište»?', 'спільний двір', '["дозволений", "домашній улюбленець", "спільний двір", "пізній приїзд"]'::jsonb, 'A2', 2, 'PUBLISHED', 'zajedničko dvorište', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '388f56cb-5f63-5527-9328-a4e67bdb8f75', 'multiple_choice', 'Що означає «dopušten»?', 'дозволений', '["повернення передоплати", "окремий вхід", "додаткове ліжко", "дозволений"]'::jsonb, 'A2', 3, 'PUBLISHED', 'dopušten', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7fe67314-a03c-50e6-98ae-27692ef6a1e9', 'multiple_choice', 'Що означає «kućni ljubimac»?', 'домашній улюбленець', '["дозволений", "домашній улюбленець", "орендодавець (житла туристам)", "повернення передоплати"]'::jsonb, 'A2', 4, 'PUBLISHED', 'kućni ljubimac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '239f7349-c5a0-5d3e-8f0e-e3e1759a7084', 'multiple_choice', 'Як хорватською «скасувати»?', 'otkazati', '["vlastiti ulaz", "otkazati", "dopušten", "pomoćni ležaj"]'::jsonb, 'A2', 5, 'PUBLISHED', 'otkazati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '508b5187-b6cc-53db-b98c-6266f4dd34e9', 'multiple_choice', 'Як хорватською «додаткове ліжко»?', 'pomoćni ležaj', '["vlastiti ulaz", "dočekati", "kasni dolazak", "pomoćni ležaj"]'::jsonb, 'A2', 6, 'PUBLISHED', 'pomoćni ležaj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '73420e0e-c1b4-5bc0-a732-1531e56ea2af', 'type_answer', 'Напишіть хорватською: «передоплата, аванс»', 'predujam', null, 'A2', 7, 'PUBLISHED', 'predujam', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b60e9fc-3171-5834-af62-48231d6e9f4b', 'type_answer', 'Напишіть хорватською: «пізній приїзд»', 'kasni dolazak', null, 'A2', 8, 'PUBLISHED', 'kasni dolazak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fe0a6ccf-2b6e-5cb9-bc22-dcfd80e5d793', 'type_answer', 'Напишіть хорватською: «доплата»', 'nadoplata', null, 'A2', 9, 'PUBLISHED', 'nadoplata', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8fe5be9-638d-5cbb-bf76-2b1a9dbb0897', 'sentence_builder', 'Складіть: «Нам треба дитяче ліжечко.»', 'Trebamo dječji krevetić.', '["Trebamo", "krevetić.", "dječji"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '67f6e347-f3bf-5afd-86f8-028f89d5c618', 'sentence_builder', 'Складіть: «Передоплату можна внести на рахунок.»', 'Predujam se može uplatiti na račun.', '["može", "na", "račun.", "se", "Predujam", "uplatiti"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '987c3722-bc5b-52c5-9710-4cb7b1b6c627', 'listening', 'Прослухайте і складіть фразу', 'Koliko iznosi predujam?', '["Koliko", "predujam?", "iznosi"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '4d75fd04-df31-561a-830d-b330523b3f6e', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'передоплату; у будинку поруч; час приїзду', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Господиня апартаментів залишила вам повідомлення.", "script": [{"hr": "Dobar dan, ovdje Ana Bašić, iznajmljivačica iz Pakoštana.", "ua": "Добрий день, це Ана Башич, господиня апартаментів з Пакоштан."}, {"hr": "Dobila sam Vaš predujam, hvala. Rezervacija je potvrđena.", "ua": "Я отримала вашу передоплату, дякую. Бронювання підтверджено."}, {"hr": "Ključeve ćete dobiti kod mene, u kući pored apartmana.", "ua": "Ключі ви отримаєте в мене, у будинку поруч з апартаментами."}, {"hr": "Molim Vas, javite mi vrijeme dolaska dan prije.", "ua": "Будь ласка, повідомте мені час приїзду за день до того."}], "questions": [{"q_ua": "Що отримала господиня?", "options": ["передоплату", "відгук", "документи"], "correct": 0, "answer_turn": 1}, {"q_ua": "Де ви отримаєте ключі?", "options": ["на рецепції", "у будинку поруч", "у поштовій скриньці"], "correct": 1, "answer_turn": 2}, {"q_ua": "Що треба повідомити за день?", "options": ["кількість гостей", "номер авто", "час приїзду"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '4d75fd04-df31-561a-830d-b330523b3f6e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c70a3ca6-1e3e-5dd3-bd06-ba0f5d82bc9b', 'speaking', 'Апартаменти вільні в липні?', 'Je li apartman raspoloživ u srpnju?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ea10cb93-4646-5e75-828f-991ca5aedaf0', 'speaking', 'Чи не могли б ви надіслати мені підтвердження?', 'Biste li mi mogli poslati potvrdu?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'e6c35369-378b-5844-ac5d-fc9d1eb6dab9', 'write_message', 'Напишіть господарю апартаментів: спитайте, чи апартаменти вільні з 10 до 17 серпня і чи дозволені собаки.', 'Poštovani, je li apartman slobodan od 10. do 17. kolovoza? Jesu li psi dopušteni?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть господарю апартаментів: спитайте, чи апартаменти вільні з 10 до 17 серпня і чи дозволені собаки.", "points": [{"ua": "чи вільні апартаменти", "keys": [["raspoloživ"], ["slobod"]]}, {"ua": "з 10 до 17 серпня", "keys": [["10", "17"], ["desetog", "sedamnaest"]]}, {"ua": "чи дозволені собаки", "keys": [["ps"], ["ljubim"]]}], "hints": ["je li apartman slobodan", "od 10. do 17. kolovoza", "kućni ljubimci", "pas"], "models": ["Poštovani, je li apartman slobodan od 10. do 17. kolovoza? Jesu li psi dopušteni?", "Dobar dan, je li apartman raspoloživ od 10. do 17. kolovoza? Imamo malog psa."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'e6c35369-378b-5844-ac5d-fc9d1eb6dab9', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '21b1b7d8-e18b-55a4-849b-9a204a2ce074', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Koliko iznosi predujam i do kada možemo besplatno otkazati?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай у господині, скільки становить передоплата й до якої дати можна безкоштовно скасувати.", "direction": "ua_hr", "points": [{"ua": "скільки передоплата", "keys": [["predujam"]]}, {"ua": "безкоштовне скасування", "keys": [["otkaz"]]}, {"ua": "до якої дати", "keys": [["do kad"], ["do kojeg"], ["datum"]]}], "hints": [], "models": ["Koliko iznosi predujam i do kada možemo besplatno otkazati?"], "source_ua": "Спитай у господині, скільки становить передоплата й до якої дати можна безкоштовно скасувати."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '21b1b7d8-e18b-55a4-849b-9a204a2ce074', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1216295a-3813-5f11-b127-a5a9f5c26efb', v_lesson, 'Дзвінок господині', 'Poziv iznajmljivačici', 5021, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('51fab827-0640-59c4-8a3d-5a84e45559dd', '1216295a-3813-5f11-b127-a5a9f5c26efb', 'Darja', 'Dobar dan, zovem zbog apartmana na oglasu. Je li raspoloživ od petog srpnja?', 'Добрий день, дзвоню щодо апартаментів з оголошення. Вони вільні з п’ятого липня?', 1);
  perform pg_temp.turn('edec1ade-d76c-522c-945a-3fdcb5be8ca6', '1216295a-3813-5f11-b127-a5a9f5c26efb', 'Gospođa Bašić', 'Jest, ali minimalni boravak je sedam noći.', 'Так, але мінімальний термін — сім ночей.', 2);
  perform pg_temp.turn('1f0b57ba-252c-582f-8caa-79dd35f4faf8', '1216295a-3813-5f11-b127-a5a9f5c26efb', 'Darja', 'To nam odgovara. Imamo bebu. Biste li mogli staviti dječji krevetić?', 'Нам це підходить. У нас немовля. Чи не могли б ви поставити дитяче ліжечко?', 3);
  perform pg_temp.turn('d5beadc3-83e6-5635-8e98-0aa3c9696de2', '1216295a-3813-5f11-b127-a5a9f5c26efb', 'Gospođa Bašić', 'Naravno, bez nadoplate. Za rezervaciju trebate uplatiti predujam.', 'Звісно, без доплати. Для бронювання вам треба внести передоплату.', 4);
  perform pg_temp.turn('6f04dbd1-060a-5a1d-83e0-e34c43a958bf', '1216295a-3813-5f11-b127-a5a9f5c26efb', 'Darja', 'Koliko iznosi predujam?', 'Скільки становить передоплата?', 5);
  perform pg_temp.turn('0ab47613-246a-55c2-94d5-7ebfbcf70290', '1216295a-3813-5f11-b127-a5a9f5c26efb', 'Gospođa Bašić', 'Trideset posto. Boravišna pristojba se plaća na dolasku.', 'Тридцять відсотків. Туристичний податок сплачують при приїзді.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2eb490f9-bf4e-52ac-b5e6-bde3ad8803fb', v_lesson, 'Умови скасування', 'Uvjeti otkazivanja', 5022, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('5be76698-ddd7-5fa5-9498-939ae9ca63c0', '2eb490f9-bf4e-52ac-b5e6-bde3ad8803fb', 'Ivan', 'Daša, jesi li pročitala uvjete otkazivanja?', 'Дашо, ти прочитала умови скасування?', 1);
  perform pg_temp.turn('a2d2600b-1cac-50f6-aa81-c59152e2f866', '2eb490f9-bf4e-52ac-b5e6-bde3ad8803fb', 'Daša', 'Jesam. Besplatno otkazivanje je do mjesec dana prije dolaska.', 'Так. Безкоштовне скасування — до місяця перед приїздом.', 2);
  perform pg_temp.turn('ee816774-87d2-51de-8754-74ca74b1679c', '2eb490f9-bf4e-52ac-b5e6-bde3ad8803fb', 'Ivan', 'A ako otkažemo kasnije?', 'А якщо скасуємо пізніше?', 3);
  perform pg_temp.turn('4841105b-ccbe-5b68-97d8-8e56765e74a8', '2eb490f9-bf4e-52ac-b5e6-bde3ad8803fb', 'Daša', 'Onda gubimo predujam. Zato bih radije čekala s uplatom.', 'Тоді втрачаємо передоплату. Тому я б радше почекала з оплатою.', 4);
  perform pg_temp.turn('36a0c2c2-d3e7-5074-b5cb-3f2848518391', '2eb490f9-bf4e-52ac-b5e6-bde3ad8803fb', 'Ivan', 'Jesu li kućni ljubimci dopušteni? Ne bih ostavio psa.', 'Домашні тварини дозволені? Я б не залишав пса.', 5);
  perform pg_temp.turn('8632bc3c-1d6c-538d-9be0-0efc20e37fe0', '2eb490f9-bf4e-52ac-b5e6-bde3ad8803fb', 'Daša', 'Jesu, a apartman ima i vlastiti ulaz.', 'Так, а в апартаментах ще й окремий вхід.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.1 · урок 3: Заселення й проблеми в номері — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '11809ea9-712b-5fb7-b4a6-8a5fb60f7d62';
  v_lesson constant uuid := '778e1a8f-01d6-5bc0-b3e3-3e3123551c8b';
  v_gid constant uuid := '59c6c708-59b5-5781-bf5d-4ecd5aa8b7dc';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики ZAV'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A2.1: місце 3 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 3: Заселення й проблеми в номері', 'Lekcija 3: Prijava i problemi u sobi', '["Заселитися й розпитати про правила: wi-fi, сніданок, паркування", "Пояснити, що не так у номері, і попросити розв’язати: Ako…, …"]'::jsonb, 20, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'prijava gostiju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kartica za sobu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lozinka za wi-fi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'doručak je uključen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ne radi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pokvaren', v_pos);
  v_pos := pg_temp.word(v_lesson, 'curiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tuš kabina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'komarac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mrežica protiv komaraca', v_pos);
  v_pos := pg_temp.word(v_lesson, 'miris', v_pos);
  v_pos := pg_temp.word(v_lesson, 'druga soba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'premjestiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pogledati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'riješiti problem', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispričavamo se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neugodnost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ne zatvara se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rolete', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaglaviti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razbijen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zastor', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '01b8eb73-4494-5f12-8139-8a29622c9dde', 'fill_in_the_blank', '___ klima ne proradi, želimo drugu sobu.', 'Ako', '["Čim", "Dok", "Nego", "Ako"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8f3d9c4a-c437-5bc6-87a3-412475447a96', 'multiple_choice', 'Що означає «kartica za sobu»?', 'картка-ключ від номера', '["переселити, перемістити", "москітна сітка", "розбитий", "картка-ключ від номера"]'::jsonb, 'A2', 2, 'PUBLISHED', 'kartica za sobu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e8cce57-675e-5db2-a658-e43a2adc39b7', 'multiple_choice', 'Що означає «doručak je uključen»?', 'сніданок включено', '["переселити, перемістити", "картка-ключ від номера", "текти, протікати", "сніданок включено"]'::jsonb, 'A2', 3, 'PUBLISHED', 'doručak je uključen', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd9d962a-3b3a-54b1-aebd-55f700e6f957', 'multiple_choice', 'Що означає «prijava gostiju»?', 'реєстрація гостей', '["реєстрація гостей", "картка-ключ від номера", "москітна сітка", "заклинити, застрягти"]'::jsonb, 'A2', 4, 'PUBLISHED', 'prijava gostiju', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '93daa0f6-6e8d-5887-82c1-4a0fdaa628f1', 'multiple_choice', 'Як хорватською «москітна сітка»?', 'mrežica protiv komaraca', '["pogledati", "ispričavamo se", "kartica za sobu", "mrežica protiv komaraca"]'::jsonb, 'A2', 5, 'PUBLISHED', 'mrežica protiv komaraca', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf14c1e2-55d9-59b7-9271-2f9c3d4267c7', 'multiple_choice', 'Як хорватською «комар»?', 'komarac', '["riješiti problem", "komarac", "druga soba", "zastor"]'::jsonb, 'A2', 6, 'PUBLISHED', 'komarac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ef9d2845-9bfc-5486-8b79-ce7c65a63f63', 'type_answer', 'Напишіть хорватською: «інший номер»', 'druga soba', null, 'A2', 7, 'PUBLISHED', 'druga soba', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b748a2db-e516-5fdb-b911-e4fad7f06481', 'type_answer', 'Напишіть хорватською: «зламаний, несправний»', 'pokvaren', null, 'A2', 8, 'PUBLISHED', 'pokvaren', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b8a5f1cb-ac4c-5632-8b49-8755edf8afad', 'type_answer', 'Напишіть хорватською: «переселити, перемістити»', 'premjestiti', null, 'A2', 9, 'PUBLISHED', 'premjestiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a3af972-6c6b-5092-8571-d35222bc1935', 'sentence_builder', 'Складіть: «У ванній тече вода.»', 'U kupaonici curi voda.', '["voda.", "curi", "U", "kupaonici"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4b9a48ea-b90a-5385-bb2b-4b6de9caee3d', 'sentence_builder', 'Складіть: «Перегоріла лампочка в коридорі.»', 'Pregorjela je žarulja u hodniku.', '["Pregorjela", "u", "je", "hodniku.", "žarulja"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ff434b03-9974-5659-b2f9-ccdbe193bf16', 'listening', 'Прослухайте і складіть фразу', 'Domar će odmah pogledati.', '["pogledati.", "Domar", "odmah", "će"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'e2656cff-db07-5135-95f7-5a4c0f389fd9', 'listening_dialogue', 'Прослухайте розмову', 'гарячої води; до обіду; москітну сітку', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Даша телефонує на рецепцію. Послухайте розмову.", "script": [{"speaker": "Daša", "hr": "Dobro jutro, ovdje soba sto dvanaest. Nemamo toplu vodu.", "ua": "Добрий ранок, це номер сто дванадцять. У нас немає гарячої води."}, {"speaker": "Recepcija", "hr": "Ispričavamo se, popravljaju bojler. Bit će gotovo do podne.", "ua": "Просимо вибачення, ремонтують бойлер. Буде готово до обіду."}, {"speaker": "Daša", "hr": "A noću nas grizu komarci. Na prozoru nema mrežice.", "ua": "А вночі нас кусають комарі. На вікні немає сітки."}, {"speaker": "Recepcija", "hr": "Domar će donijeti mrežicu poslije doručka.", "ua": "Технік принесе сітку після сніданку."}], "questions": [{"q_ua": "Чого немає в номері?", "options": ["гарячої води", "світла", "рушників"], "correct": 0, "answer_turn": 0}, {"q_ua": "Коли все відремонтують?", "options": ["увечері", "до обіду", "завтра"], "correct": 1, "answer_turn": 1}, {"q_ua": "Що принесе технік?", "options": ["вентилятор", "новий пульт", "москітну сітку"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'e2656cff-db07-5135-95f7-5a4c0f389fd9', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d9c46c5-4e51-58bf-9d28-b426d6e82392', 'speaking', 'Пульт зламаний.', 'Daljinski upravljač je pokvaren.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '888e6c94-136b-5fcd-b83e-42d1da847f6a', 'speaking', 'Чи можете ви переселити нас в інший номер?', 'Možete li nas premjestiti u drugu sobu?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'd9190431-7a3d-5207-8eda-5911b1417981', 'write_message', 'Напишіть на рецепцію: у номері 305 не працює кондиціонер і тече вода у ванній. Попросіть когось прийти.', 'Dobar dan, u sobi 305 klima ne radi i u kupaonici curi voda. Može li netko doći pogledati?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть на рецепцію: у номері 305 не працює кондиціонер і тече вода у ванній. Попросіть когось прийти.", "points": [{"ua": "номер 305", "keys": [["305"], ["tristo pet"]]}, {"ua": "кондиціонер не працює", "keys": [["klim"]]}, {"ua": "тече вода", "keys": [["curi"], ["voda"]]}, {"ua": "попросіть прийти", "keys": [["dođe"], ["doći"], ["pogleda"]]}], "hints": ["soba 305", "klima ne radi", "curi voda", "može li netko doći?"], "models": ["Dobar dan, u sobi 305 klima ne radi i u kupaonici curi voda. Može li netko doći pogledati?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'd9190431-7a3d-5207-8eda-5911b1417981', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'ce00da6f-40d4-558b-9493-7c8e49f4abf1', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'U sobi je jak miris i na zidu je vlaga. Možemo li dobiti drugu sobu?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи рецепції, що в номері сильний запах і вогкість на стіні, і попроси інший номер.", "direction": "ua_hr", "points": [{"ua": "запах", "keys": [["miris"]]}, {"ua": "вогкість на стіні", "keys": [["vlag"]]}, {"ua": "інший номер", "keys": [["drug"]]}], "hints": [], "models": ["U sobi je jak miris i na zidu je vlaga. Možemo li dobiti drugu sobu?"], "source_ua": "Скажи рецепції, що в номері сильний запах і вогкість на стіні, і попроси інший номер."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'ce00da6f-40d4-558b-9493-7c8e49f4abf1', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2c8cd7ee-e3d3-58d3-8ffe-420bf19fdb8e', v_lesson, 'На рецепції', 'Na recepciji', 5031, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('02599b4e-3779-5f98-a984-4c689761278d', '2c8cd7ee-e3d3-58d3-8ffe-420bf19fdb8e', 'Recepcionarka', 'Dobro došli! Trebam vaše putovnice za prijavu gostiju.', 'Ласкаво просимо! Мені потрібні ваші паспорти для реєстрації гостей.', 1);
  perform pg_temp.turn('6542430a-f351-5ba0-8691-6039ce9f6823', '2c8cd7ee-e3d3-58d3-8ffe-420bf19fdb8e', 'Darja', 'Izvolite. Je li doručak uključen?', 'Прошу. Сніданок включено?', 2);
  perform pg_temp.turn('a6b69941-5187-597b-9a55-36aca382cb47', '2c8cd7ee-e3d3-58d3-8ffe-420bf19fdb8e', 'Recepcionarka', 'Jest, od sedam do deset. Ovo su dvije kartice za sobu.', 'Так, із сьомої до десятої. Ось дві картки-ключі від номера.', 3);
  perform pg_temp.turn('4b150e9e-2058-506b-80c5-2849dea09879', '2c8cd7ee-e3d3-58d3-8ffe-420bf19fdb8e', 'Darja', 'A koja je lozinka za wi-fi?', 'А який пароль від wi-fi?', 4);
  perform pg_temp.turn('9c924e48-7768-5761-82b8-454473177780', '2c8cd7ee-e3d3-58d3-8ffe-420bf19fdb8e', 'Recepcionarka', 'Piše na kartici. Ako trebate nešto, nazovite recepciju.', 'Написано на картці. Якщо щось знадобиться, телефонуйте на рецепцію.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('739740ec-26e6-58d4-89ae-ab908e19f5ca', v_lesson, 'Не працює кондиціонер', 'Klima ne radi', 5032, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('94badb27-1aa8-5955-9b76-5ad9d40dd469', '739740ec-26e6-58d4-89ae-ab908e19f5ca', 'Darja', 'Dobra večer, zovem iz sobe dvjesto pet. Klima ne radi.', 'Добрий вечір, телефоную з номера двісті п’ять. Не працює кондиціонер.', 1);
  perform pg_temp.turn('149fdc38-125c-5b26-95f3-95dabd6fa35b', '739740ec-26e6-58d4-89ae-ab908e19f5ca', 'Recepcionarka', 'Ispričavamo se. Jeste li probali daljinski upravljač?', 'Просимо вибачення. Ви пробували пульт?', 2);
  perform pg_temp.turn('942254a4-f3f9-5842-8a51-48523eef9f16', '739740ec-26e6-58d4-89ae-ab908e19f5ca', 'Darja', 'Jesam, ali je pokvaren. I u kupaonici curi voda.', 'Так, але він зламаний. І у ванній тече вода.', 3);
  perform pg_temp.turn('0ab7b7d1-830d-52ce-9b53-4ffa221bbfce', '739740ec-26e6-58d4-89ae-ab908e19f5ca', 'Recepcionarka', 'Domar će odmah pogledati.', 'Технік зараз же огляне.', 4);
  perform pg_temp.turn('8e42e665-b85d-5cab-8319-e30a9079d4a3', '739740ec-26e6-58d4-89ae-ab908e19f5ca', 'Darja', 'Hvala. Ako ne riješite problem, biste li nas premjestili u drugu sobu?', 'Дякую. Якщо не розв’яжете проблему, чи не могли б ви переселити нас в інший номер?', 5);
  perform pg_temp.turn('87d2c055-dc4b-595b-9b55-9e9f1179ba07', '739740ec-26e6-58d4-89ae-ab908e19f5ca', 'Recepcionarka', 'Naravno. Ispričavamo se zbog neugodnosti.', 'Звісно. Просимо вибачення за незручності.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.1 · урок 4: Ресторан біля моря — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '11809ea9-712b-5fb7-b4a6-8a5fb60f7d62';
  v_lesson constant uuid := '098e590d-283c-56db-927d-80488d4bce45';
  v_gid constant uuid := '0c68352a-803a-5410-a59b-91f2c1ddc49f';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KOND'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A2.1: місце 4 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 4: Ресторан біля моря', 'Lekcija 4: Restoran uz more', '["Замовити рибу й морепродукти, спитати про свіжість і спосіб приготування", "Ввічливо попросити й порадитися: Što biste preporučili?"]'::jsonb, 20, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'riblji restoran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svježa riba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ulov dana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brancin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dagnje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hobotnica ispod peke', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na buzaru', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cijena po kilogramu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preporučiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'domaće vino', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pola litre', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kruh i maslinovo ulje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stol uz more', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pogreška u računu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zasebno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zubatac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srdele', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kamenice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'riblja juha', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pošip', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polovica porcije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dječja porcija', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '24925bfd-35ef-5a51-b417-9542718fdebb', 'fill_in_the_blank', 'Što ___ nam preporučili?', 'biste', '["bi", "bih", "bismo", "biste"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4309b0cf-5c95-57a2-b705-1489b51c299f', 'multiple_choice', 'Що означає «stol uz more»?', 'столик біля моря', '["столик біля моря", "устриці", "мідії", "восьминіг під пекою"]'::jsonb, 'A2', 2, 'PUBLISHED', 'stol uz more', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3dc49176-df28-5b2b-b083-f4cdab7acb49', 'multiple_choice', 'Що означає «brancin»?', 'сибас (риба)', '["домашнє вино", "сибас (риба)", "сардини", "восьминіг під пекою"]'::jsonb, 'A2', 3, 'PUBLISHED', 'brancin', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9a755637-aa39-5b0b-b56c-6e633c901d76', 'multiple_choice', 'Що означає «polovica porcije»?', 'пів порції', '["мідії", "окремо", "пів порції", "домашнє вино"]'::jsonb, 'A2', 4, 'PUBLISHED', 'polovica porcije', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9052a3ee-3ab3-5cfe-bea5-45505d867ec5', 'multiple_choice', 'Як хорватською «помилка в рахунку»?', 'pogreška u računu', '["pošip", "svježa riba", "srdele", "pogreška u računu"]'::jsonb, 'A2', 5, 'PUBLISHED', 'pogreška u računu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e729d2ea-e6e1-5a1e-97f1-d11509e535a1', 'multiple_choice', 'Як хорватською «окремо»?', 'zasebno', '["cijena po kilogramu", "preporučiti", "zasebno", "stol uz more"]'::jsonb, 'A2', 6, 'PUBLISHED', 'zasebno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '01c19f36-657c-5734-bc66-65c9007ee722', 'type_answer', 'Напишіть хорватською: «порадити, рекомендувати»', 'preporučiti', null, 'A2', 7, 'PUBLISHED', 'preporučiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '01ba7072-eaea-5901-9529-e14fe60fbf31', 'type_answer', 'Напишіть хорватською: «устриці»', 'kamenice', null, 'A2', 8, 'PUBLISHED', 'kamenice', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7bcbd739-46cb-58a4-be8e-959c40926760', 'type_answer', 'Напишіть хорватською: «улов дня»', 'ulov dana', null, 'A2', 9, 'PUBLISHED', 'ulov dana', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0b568473-3228-565f-8787-ad43b4d45460', 'sentence_builder', 'Складіть: «Яка фірмова страва?»', 'Što je specijalitet kuće?', '["kuće?", "Što", "je", "specijalitet"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6523a7c2-192c-517f-928c-87635a09df14', 'sentence_builder', 'Складіть: «Я хотіла б мідії на бузару.»', 'Htjela bih dagnje na buzaru.', '["Htjela", "bih", "buzaru.", "na", "dagnje"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f1438218-393d-58eb-9df1-a714ee6af298', 'listening', 'Прослухайте і складіть фразу', 'Gdje točno?', '["točno?", "Gdje"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '78f88478-650c-54dd-9016-e91dbe9ec242', 'listening_dialogue', 'Прослухайте розмову', 'годину; дві дорады', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Дар’я замовляє в рибному ресторані. Послухайте.", "script": [{"speaker": "Konobar", "hr": "Danas preporučujem hobotnicu ispod peke, ali treba čekati sat vremena.", "ua": "Сьогодні раджу восьминога під пекою, але треба чекати годину."}, {"speaker": "Darja", "hr": "Predugo je, djeca su gladna. Imate li nešto brže?", "ua": "Задовго, діти голодні. У вас є щось швидше?"}, {"speaker": "Konobar", "hr": "Oradu na žaru, gotova je za dvadeset minuta.", "ua": "Дораду на грилі, буде готова за двадцять хвилин."}, {"speaker": "Darja", "hr": "Dobro, dvije orade s krumpirom i jedan sok za djecu.", "ua": "Добре, дві дорады з картоплею і один сік для дітей."}], "questions": [{"q_ua": "Скільки треба чекати восьминога?", "options": ["20 хвилин", "пів години", "годину"], "correct": 2, "answer_turn": 0}, {"q_ua": "Що замовила Дар’я?", "options": ["дві дорады", "сибаса", "мідії"], "correct": 0, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '78f88478-650c-54dd-9016-e91dbe9ec242', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd1e3ca1-436b-505e-9aa2-536220df697b', 'speaking', 'Чи є вільний столик біля моря?', 'Imate li slobodan stol uz more?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b7593870-6c90-5efd-bbe2-c59cc5865e48', 'speaking', 'Можемо заплатити окремо?', 'Možemo li platiti zasebno?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'bae70b43-79bd-5c7d-a50e-f0b982332a6c', 'write_message', 'Напишіть у ресторан: хочете забронювати столик біля моря на суботу о 20:00 для чотирьох людей.', 'Dobar dan, htjela bih rezervirati stol uz more za četvero u subotu u 20 sati.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у ресторан: хочете забронювати столик біля моря на суботу о 20:00 для чотирьох людей.", "points": [{"ua": "столик біля моря", "keys": [["uz more"]]}, {"ua": "на суботу", "keys": [["subot"]]}, {"ua": "о 20:00", "keys": [["20"], ["osam"]]}, {"ua": "для чотирьох", "keys": [["četvero"], ["četiri"]]}], "hints": ["rezervirati stol", "uz more", "u subotu", "u 20 sati", "za četvero"], "models": ["Dobar dan, htjela bih rezervirati stol uz more za četvero u subotu u 20 sati."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'bae70b43-79bd-5c7d-a50e-f0b982332a6c', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'fb8a1faa-c3e7-5e33-a9da-baaf86a83ad0', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Moj prijatelj je alergičan na plodove mora. Što biste mu preporučili bez njih?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи офіціантові, що в мене алергія на морепродукти, і спитай, що він порадить без них.", "direction": "ua_hr", "points": [{"ua": "алергія", "keys": [["alergi"]]}, {"ua": "морепродукти", "keys": [["plodov"], ["škamp"], ["školjk"]]}, {"ua": "що порадить", "keys": [["preporuč"]]}], "hints": [], "models": ["Moj prijatelj je alergičan na plodove mora. Što biste mu preporučili bez njih?"], "source_ua": "Скажи офіціантові, що в мене алергія на морепродукти, і спитай, що він порадить без них."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'fb8a1faa-c3e7-5e33-a9da-baaf86a83ad0', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('330e7d84-3259-53c7-b1a5-fed7553d1457', v_lesson, 'Що порадите?', 'Što biste preporučili?', 5041, 'A2', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('99c9a9cd-b668-5fad-9622-a865fb1b7746', '330e7d84-3259-53c7-b1a5-fed7553d1457', 'Konobar', 'Dobra večer! Izvolite stol uz more.', 'Добрий вечір! Прошу, столик біля моря.', 1);
  perform pg_temp.turn('92955a50-af7f-514d-8c67-d53941bfd311', '330e7d84-3259-53c7-b1a5-fed7553d1457', 'Daša', 'Hvala. Što biste nam preporučili?', 'Дякую. Що б ви нам порадили?', 2);
  perform pg_temp.turn('996775d8-9f7c-5681-859c-03ceb539f26e', '330e7d84-3259-53c7-b1a5-fed7553d1457', 'Konobar', 'Ulov dana je brancin. Može na žaru, s blitvom.', 'Улов дня — сибас. Можна на грилі, з мангольдом.', 3);
  perform pg_temp.turn('7ac14cbf-fe4d-5fb9-8e49-6f12eb19427d', '330e7d84-3259-53c7-b1a5-fed7553d1457', 'Daša', 'Je li riba svježa?', 'Риба свіжа?', 4);
  perform pg_temp.turn('6349cc86-ec2b-5111-b362-d81c05a0339b', '330e7d84-3259-53c7-b1a5-fed7553d1457', 'Konobar', 'Naravno, jutros je ulovljena. Cijena po kilogramu je četrdeset eura.', 'Звісно, сьогодні вранці виловлена. Ціна за кілограм — сорок євро.', 5);
  perform pg_temp.turn('c94c8e56-809d-5f5f-b6ea-5798e6d69b47', '330e7d84-3259-53c7-b1a5-fed7553d1457', 'Daša', 'Dobro, htjela bih brancina i pola litre domaćeg vina.', 'Добре, я б хотіла сибаса й пів літра домашнього вина.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9140c599-ceba-5bbb-8214-54c16f55a70c', v_lesson, 'Рахунок', 'Račun', 5042, 'A2', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('5dbf1188-0106-5444-8545-03606e1f99f0', '9140c599-ceba-5bbb-8214-54c16f55a70c', 'Ivan', 'Oprostite, mislim da je pogreška u računu.', 'Перепрошую, здається, у рахунку помилка.', 1);
  perform pg_temp.turn('b73c6a40-44bd-59b7-be91-c79db716c351', '9140c599-ceba-5bbb-8214-54c16f55a70c', 'Konobar', 'Gdje točno?', 'Де саме?', 2);
  perform pg_temp.turn('075006d8-2294-5b9a-9be0-959142138e2f', '9140c599-ceba-5bbb-8214-54c16f55a70c', 'Ivan', 'Naplatili ste nam dvije porcije škampa, a naručili smo jednu.', 'Ви порахували нам дві порції креветок, а ми замовляли одну.', 3);
  perform pg_temp.turn('51b7f25c-98b0-5ff7-b84c-6a713e6b6f88', '9140c599-ceba-5bbb-8214-54c16f55a70c', 'Konobar', 'Imate pravo, ispričavam se. Odmah ću ispraviti.', 'Ви маєте рацію, перепрошую. Зараз виправлю.', 4);
  perform pg_temp.turn('15a9273c-6f87-51b7-8a63-2cf337f39689', '9140c599-ceba-5bbb-8214-54c16f55a70c', 'Ivan', 'Hvala. Možemo li platiti zasebno?', 'Дякую. Можемо заплатити окремо?', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.1 · урок 5: Поромом на острови — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '11809ea9-712b-5fb7-b4a6-8a5fb60f7d62';
  v_lesson constant uuid := 'd48d7fc9-54b1-5140-8d5f-c627af7bdebb';
  v_gid constant uuid := '59c6c708-59b5-5781-bf5d-4ecd5aa8b7dc';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики ZAV'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A2.1: місце 5 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 5: Поромом на острови', 'Lekcija 5: Trajektom na otoke', '["Купити квиток на пором для авто й пасажирів, зрозуміти розклад", "Зрозуміти оголошення про затримку й скасування: zbog bure, kasni"]'::jsonb, 20, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'trajektna linija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'katamaran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'red vožnje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pristanište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'karta za vozilo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ukrcati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iskrcati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čekati u koloni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prekid plovidbe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nevrijeme', v_pos);
  v_pos := pg_temp.word(v_lesson, 'valovit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'morska bolest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'paluba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pramac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krma', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prevoziti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Jadrolinija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kasniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pomorski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lučka kapetanija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljuljati se', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '24dea907-eb06-5eec-808b-79b38eb4b3b4', 'fill_in_the_blank', '___ trajekt stigne, idemo ravno na plažu.', 'Čim', '["Nego", "Dok", "Kao", "Čim"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c7f3f7a5-f547-5262-b62b-82eef5bc602a', 'multiple_choice', 'Що означає «prekid plovidbe»?', 'зупинка рейсів (на морі)', '["зійти (з борту), вивантажитися", "розклад руху", "зупинка рейсів (на морі)", "морська хвороба"]'::jsonb, 'A2', 2, 'PUBLISHED', 'prekid plovidbe', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3d9e872e-a3c4-55e8-8312-a489bfda7120', 'multiple_choice', 'Що означає «karta za vozilo»?', 'квиток на авто', '["корма", "хвилястий, з хвилями", "зійти (з борту), вивантажитися", "квиток на авто"]'::jsonb, 'A2', 3, 'PUBLISHED', 'karta za vozilo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2e55184e-dd6e-5e5c-9a38-5e6ded0bb898', 'multiple_choice', 'Що означає «čekati u koloni»?', 'чекати в черзі (автомобілів)', '["запізнюватися", "чекати в черзі (автомобілів)", "зійти (з борту), вивантажитися", "палуба"]'::jsonb, 'A2', 4, 'PUBLISHED', 'čekati u koloni', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fe76464c-2642-5223-bab1-aec4e0d2018d', 'multiple_choice', 'Як хорватською «капітанія порту (портова адміністрація)»?', 'lučka kapetanija', '["karta za vozilo", "red vožnje", "pomorski", "lučka kapetanija"]'::jsonb, 'A2', 5, 'PUBLISHED', 'lučka kapetanija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d0b9515-ad88-5264-8aa2-1b9278ce3a11', 'multiple_choice', 'Як хорватською «сісти (на борт), завантажитися»?', 'ukrcati se', '["katamaran", "red vožnje", "ljuljati se", "ukrcati se"]'::jsonb, 'A2', 6, 'PUBLISHED', 'ukrcati se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a7eb2887-83cd-5bcc-b7f6-bdda219613d4', 'type_answer', 'Напишіть хорватською: «перевозити»', 'prevoziti', null, 'A2', 7, 'PUBLISHED', 'prevoziti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9e3d50ad-331b-50c7-ae11-c8a58013f509', 'type_answer', 'Напишіть хорватською: «морська хвороба»', 'morska bolest', null, 'A2', 8, 'PUBLISHED', 'morska bolest', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '84b66b47-45c9-57ea-b475-e5f0299734a2', 'type_answer', 'Напишіть хорватською: «зійти (з борту), вивантажитися»', 'iskrcati se', null, 'A2', 9, 'PUBLISHED', 'iskrcati se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a3585384-aef1-58b0-85c2-c5038ecdc718', 'sentence_builder', 'Складіть: «Пором запізнюється на пів години.»', 'Trajekt kasni pola sata.', '["pola", "Trajekt", "kasni", "sata."]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e7737334-a7e9-5c56-a7e5-d1dab78466d0', 'sentence_builder', 'Складіть: «Катамаран не перевозить автомобілі.»', 'Katamaran ne prevozi automobile.', '["ne", "prevozi", "automobile.", "Katamaran"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1b51e12e-e1c2-58f5-95d8-1f3a98f0520a', 'listening', 'Прослухайте і складіть фразу', 'Sjedni u sredinu broda, tamo se manje ljulja.', '["sredinu", "manje", "broda,", "se", "tamo", "Sjedni", "ljulja.", "u"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '6f9ae764-3bbc-5f12-b394-1223014cc31a', 'listening_dialogue', 'Прослухайте оголошення', 'через сильний вітер (юг); їхати поромом без доплати; о 14:30', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Ви з Дашею в порту в Задарі. Послухайте оголошення.", "script": [{"hr": "Poštovani putnici, zbog jakog juga katamaran za Preko danas ne vozi.", "ua": "Шановні пасажири, через сильний юг катамаран до Преко сьогодні не ходить."}, {"hr": "Trajekt u petnaest sati vozi prema redu vožnje.", "ua": "Пором о п’ятнадцятій ходить за розкладом."}, {"hr": "Putnici s kartama za katamaran mogu putovati trajektom bez nadoplate.", "ua": "Пасажири з квитками на катамаран можуть їхати поромом без доплати."}, {"hr": "Ukrcaj vozila počinje u četrnaest i trideset.", "ua": "Посадка автомобілів починається о чотирнадцятій тридцять."}], "questions": [{"q_ua": "Чому не ходить катамаран?", "options": ["через сильний вітер (юг)", "через ремонт", "бо немає пасажирів"], "correct": 0, "answer_turn": 0}, {"q_ua": "Що можуть зробити пасажири з квитками на катамаран?", "options": ["повернути гроші", "їхати поромом без доплати", "їхати завтра"], "correct": 1, "answer_turn": 2}, {"q_ua": "Коли починається посадка авто?", "options": ["о 15:00", "о 14:00", "о 14:30"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '6f9ae764-3bbc-5f12-b394-1223014cc31a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '064dfebb-b78b-5eac-98d8-20433b6a0ee7', 'speaking', 'Один квиток на авто, будь ласка.', 'Jednu kartu za vozilo, molim.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '19d0599a-e830-5974-abed-917813e5bc04', 'speaking', 'Коли наступне відправлення?', 'Kada je sljedeći polazak?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '295512b9-a9ab-54de-8137-5b4e6097d9f3', 'write_message', 'Напишіть друзям на острові: пором запізнюється на годину через буру, ви приїдете о 17:00.', 'Trajekt kasni sat vremena zbog bure. Stižemo u 17 sati.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть друзям на острові: пором запізнюється на годину через буру, ви приїдете о 17:00.", "points": [{"ua": "пором запізнюється", "keys": [["kasn"]]}, {"ua": "через буру", "keys": [["bur"], ["vjetr"]]}, {"ua": "приїдете о 17:00", "keys": [["17"], ["pet"]]}], "hints": ["trajekt kasni", "zbog bure", "stižemo u 17 sati"], "models": ["Trajekt kasni sat vremena zbog bure. Stižemo u 17 sati."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '295512b9-a9ab-54de-8137-5b4e6097d9f3', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '44eab826-e386-5036-b273-273386134c53', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Vozi li danas katamaran do Hvara? Ako ne vozi, kada je sljedeći trajekt?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай у касира, чи ходить сьогодні катамаран до Хвара, і якщо ні — коли наступний пором.", "direction": "ua_hr", "points": [{"ua": "катамаран до Хвара", "keys": [["katamaran"]]}, {"ua": "сьогодні", "keys": [["danas"]]}, {"ua": "наступний пором", "keys": [["trajekt"]]}], "hints": [], "models": ["Vozi li danas katamaran do Hvara? Ako ne vozi, kada je sljedeći trajekt?"], "source_ua": "Спитай у касира, чи ходить сьогодні катамаран до Хвара, і якщо ні — коли наступний пором."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '44eab826-e386-5036-b273-273386134c53', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a5dd6945-138b-5abb-adde-238191a14f22', v_lesson, 'Біля каси', 'Na blagajni', 5051, 'A2', 'transport', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('c049c1f3-9590-5fcc-909f-3419e848e0a7', 'a5dd6945-138b-5abb-adde-238191a14f22', 'Darja', 'Dobar dan, jednu kartu za vozilo i tri za putnike do Supetra.', 'Добрий день, один квиток на авто й три для пасажирів до Супетара.', 1);
  perform pg_temp.turn('78d26e70-f55b-534f-aace-539ae58d6d35', 'a5dd6945-138b-5abb-adde-238191a14f22', 'Blagajnik', 'Za polazak u deset ili u podne?', 'На відправлення о десятій чи опівдні?', 2);
  perform pg_temp.turn('379ad3af-06de-50ab-999b-237c348ac3af', 'a5dd6945-138b-5abb-adde-238191a14f22', 'Darja', 'U deset, ako ima mjesta.', 'О десятій, якщо є місця.', 3);
  perform pg_temp.turn('f2e7e2a7-d4aa-5d54-8006-8ea804e977ab', 'a5dd6945-138b-5abb-adde-238191a14f22', 'Blagajnik', 'Ima. Čekajte u koloni broj tri. Ukrcaj počinje pola sata prije polaska.', 'Є. Чекайте в черзі номер три. Посадка починається за пів години до відправлення.', 4);
  perform pg_temp.turn('10091c6b-a7e4-5131-b0bf-5bbd403bfebd', 'a5dd6945-138b-5abb-adde-238191a14f22', 'Darja', 'A vozi li katamaran danas do Bola?', 'А катамаран сьогодні ходить до Бола?', 5);
  perform pg_temp.turn('e525776f-8b48-5b1a-acb8-54c643ec5a09', 'a5dd6945-138b-5abb-adde-238191a14f22', 'Blagajnik', 'Ne vozi zbog nevremena. More je jako valovito.', 'Не ходить через негоду. Море дуже хвилясте.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4493a550-9404-5c10-a88b-3d6e2ebe3ad4', v_lesson, 'На палубі', 'Na palubi', 5052, 'A2', 'transport', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('898bd50d-c9bf-5268-b6ef-9995a159fa99', '4493a550-9404-5c10-a88b-3d6e2ebe3ad4', 'Ivan', 'Dašo, dođi na pramac! Vidi se Brač.', 'Дашо, ходи на ніс! Видно Брач.', 1);
  perform pg_temp.turn('6bf7dcdb-03fc-5d38-bded-90a5e49603af', '4493a550-9404-5c10-a88b-3d6e2ebe3ad4', 'Daša', 'Ne mogu, imam morsku bolest. Ostat ću unutra.', 'Не можу, у мене морська хвороба. Залишуся всередині.', 2);
  perform pg_temp.turn('fd02e69c-10cb-5183-948d-0a4bb0b3f140', '4493a550-9404-5c10-a88b-3d6e2ebe3ad4', 'Ivan', 'Sjedni u sredinu broda, tamo se manje ljulja.', 'Сядь посередині судна, там менше гойдає.', 3);
  perform pg_temp.turn('12bd5797-1c26-5698-83c3-efd8e6b1f9e2', '4493a550-9404-5c10-a88b-3d6e2ebe3ad4', 'Daša', 'Dobro. Kad stignemo, gdje se iskrcavamo?', 'Добре. Коли припливемо, де ми сходимо?', 4);
  perform pg_temp.turn('eca1ef7f-3697-5751-9653-255a4bd55af4', '4493a550-9404-5c10-a88b-3d6e2ebe3ad4', 'Ivan', 'U Supetru. Vozači moraju sići do auta prije pristajanja.', 'У Супетарі. Водії мають спуститися до авто перед причалюванням.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.1 · урок 6: Пляж і море — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '11809ea9-712b-5fb7-b4a6-8a5fb60f7d62';
  v_lesson constant uuid := 'bd9353b6-9d9e-5192-8124-f6a2dcf3f178';
  v_gid constant uuid := '59c6c708-59b5-5781-bf5d-4ecd5aa8b7dc';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики ZAV'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A2.1: місце 6 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 6: Пляж і море', 'Lekcija 6: Plaža i more', '["Поговорити про пляж і безпеку на морі: meduze, ježinci, spasilac", "Попередити й порадити: Ako…, Dok…, Čim…"]'::jsonb, 20, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'meduza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ježinac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spasilac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cipelice za more', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uvala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stijene', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plićak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dubina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'struja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plutača', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sunčati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izgorjeti na suncu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaštitni faktor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hlad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ronilačka maska', v_pos);
  v_pos := pg_temp.word(v_lesson, 'disalica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'peraje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'napuhati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'madrac za plažu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nudistička plaža', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ubod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'temperatura mora', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2d911e7f-2b06-554e-ac1a-96d193fd424d', 'fill_in_the_blank', '___ si na suncu, stavljaj kremu svaka dva sata.', 'Dok', '["Kad bi", "Čim", "Nego", "Dok"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7a961c1f-5533-5ce6-9e57-244f3db14d86', 'multiple_choice', 'Що означає «plutača»?', 'буй', '["мілина", "ласти", "скелі, каміння (біля моря)", "буй"]'::jsonb, 'A2', 2, 'PUBLISHED', 'plutača', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '85a9031a-45f5-5d5b-abbe-45b762fc934c', 'multiple_choice', 'Що означає «sunčati se»?', 'засмагати', '["течія", "взуття для моря (аквашузи)", "засмагати", "тінь, прохолода"]'::jsonb, 'A2', 3, 'PUBLISHED', 'sunčati se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c94224b5-a523-56db-8cc1-c4b6f8e6d556', 'multiple_choice', 'Що означає «disalica»?', 'трубка (для плавання)', '["бухта, затока", "фактор захисту (SPF)", "надути", "трубка (для плавання)"]'::jsonb, 'A2', 4, 'PUBLISHED', 'disalica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '26d8c96e-e6eb-5d7e-8ec3-6c67b168991a', 'multiple_choice', 'Як хорватською «рятувальник»?', 'spasilac', '["spasilac", "struja", "izgorjeti na suncu", "disalica"]'::jsonb, 'A2', 5, 'PUBLISHED', 'spasilac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '095b9846-b816-5c83-9abc-c40b68991e9a', 'multiple_choice', 'Як хорватською «укус, ужалення»?', 'ubod', '["cipelice za more", "uvala", "ubod", "plutača"]'::jsonb, 'A2', 6, 'PUBLISHED', 'ubod', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '49d72695-0431-587b-a213-f1c8becd6ac2', 'type_answer', 'Напишіть хорватською: «тінь, прохолода»', 'hlad', null, 'A2', 7, 'PUBLISHED', 'hlad', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '98c49db4-9ed2-5bbf-b12e-c1572e14c9eb', 'type_answer', 'Напишіть хорватською: «ласти»', 'peraje', null, 'A2', 8, 'PUBLISHED', 'peraje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1da85eba-1ffa-56bb-8379-786a3a8b0908', 'type_answer', 'Напишіть хорватською: «течія»', 'struja', null, 'A2', 9, 'PUBLISHED', 'struja', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e1f1654c-c94a-5ef4-8883-2206d4fd212f', 'sentence_builder', 'Складіть: «Не можна плавати за буями.»', 'Ne smije se plivati iza plutača.', '["smije", "plutača.", "se", "Ne", "iza", "plivati"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f03ebec4-aff8-5a8d-82c7-a21db5dff098', 'sentence_builder', 'Складіть: «Я обгоріла на сонці.»', 'Izgorjela sam na suncu.', '["suncu.", "sam", "na", "Izgorjela"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4dcec91e-4f0f-5bf3-8726-530d099b00bd', 'listening', 'Прослухайте і складіть фразу', 'Samo s tatom. Tamo je dubina tri metra i jaka struja.', '["je", "tri", "Samo", "Tamo", "i", "dubina", "tatom.", "jaka", "s", "metra", "struja."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'd550a367-0f04-5575-aaf6-1bc7971b7b08', 'listening_dialogue', 'Прослухайте оголошення', 'хвилясте; надувні матраци; до 19:00', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Ви на міському пляжі. Звучить оголошення рятувальника.", "script": [{"hr": "Pažnja, pažnja! Danas je jak vjetar i more je valovito.", "ua": "Увага, увага! Сьогодні сильний вітер і море хвилясте."}, {"hr": "Molimo kupače da ne plivaju iza plutača.", "ua": "Просимо тих, хто купається, не запливати за буї."}, {"hr": "Madraci za plažu danas nisu dopušteni.", "ua": "Надувні матраци сьогодні заборонені."}, {"hr": "Spasilac je na plaži do devetnaest sati.", "ua": "Рятувальник на пляжі до дев’ятнадцятої години."}], "questions": [{"q_ua": "Яке сьогодні море?", "options": ["спокійне", "хвилясте", "холодне"], "correct": 1, "answer_turn": 0}, {"q_ua": "Що сьогодні заборонено?", "options": ["пірнати зі скель", "купатися дітям", "надувні матраци"], "correct": 2, "answer_turn": 2}, {"q_ua": "До котрої працює рятувальник?", "options": ["до 19:00", "до 17:00", "до 21:00"], "correct": 0, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'd550a367-0f04-5575-aaf6-1bc7971b7b08', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'df4a927e-f90b-52e7-b65c-9678d556e1ae', 'speaking', 'Візьми аквашузи через їжаків.', 'Uzmi cipelice za more zbog ježinaca.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '558a9a40-ada4-520e-a3ee-efbda7869584', 'speaking', 'Сядьмо в тінь.', 'Sjednimo u hlad.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'c8195bb0-54cb-57a2-a086-bf7961e02f38', 'write_message', 'Напишіть Даші: ви знайшли тиху бухту з тінню під соснами, але на скелях багато морських їжаків — хай візьме аквашузи.', 'Dašo, našli smo mirnu uvalu s hladom ispod borova. Na stijenama ima puno ježinaca, ponesi cipelice za more!', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть Даші: ви знайшли тиху бухту з тінню під соснами, але на скелях багато морських їжаків — хай візьме аквашузи.", "points": [{"ua": "тиха бухта", "keys": [["uval"]]}, {"ua": "тінь під соснами", "keys": [["hlad"], ["bor"]]}, {"ua": "їжаки", "keys": [["ježin"]]}, {"ua": "взяти аквашузи", "keys": [["cipelic"]]}], "hints": ["našli smo uvalu", "hlad ispod borova", "ježinci na stijenama", "ponesi cipelice za more"], "models": ["Dašo, našli smo mirnu uvalu s hladom ispod borova. Na stijenama ima puno ježinaca, ponesi cipelice za more!"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'c8195bb0-54cb-57a2-a086-bf7961e02f38', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'bad8229f-3729-5a76-bb86-e391ce2e87a9', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Mogu li djeca ovdje plivati? Kolika je ovdje dubina?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай рятувальника, чи можна дітям плавати тут і яка тут глибина.", "direction": "ua_hr", "points": [{"ua": "чи можуть діти плавати", "keys": [["djec"]]}, {"ua": "тут", "keys": [["ovdje"]]}, {"ua": "глибина", "keys": [["dubin"], ["duboko"]]}], "hints": [], "models": ["Mogu li djeca ovdje plivati? Kolika je ovdje dubina?"], "source_ua": "Спитай рятувальника, чи можна дітям плавати тут і яка тут глибина."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'bad8229f-3729-5a76-bb86-e391ce2e87a9', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3eccfc73-4c54-584c-afd9-2813c7919110', v_lesson, 'Обережно, їжаки!', 'Pazi, ježinci!', 5061, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('f862b2b6-76d5-5a51-8c2f-badd97025e9b', '3eccfc73-4c54-584c-afd9-2813c7919110', 'Darja', 'Filipe, ne skači sa stijena bez cipelica za more!', 'Філіпе, не стрибай зі скель без аквашузів!', 1);
  perform pg_temp.turn('5f3812f8-0e9d-53fd-8097-95eb9b9634b1', '3eccfc73-4c54-584c-afd9-2813c7919110', 'Filip', 'Zašto, mama?', 'Чому, мамо?', 2);
  perform pg_temp.turn('6a920d07-a499-568a-b81a-f2a70d8732fd', '3eccfc73-4c54-584c-afd9-2813c7919110', 'Darja', 'Na stijenama ima ježinaca. Ako staneš na ježinca, jako boli.', 'На скелях є морські їжаки. Якщо наступиш на їжака, дуже болить.', 3);
  perform pg_temp.turn('57a2c680-2278-5ebe-81d5-a0bac22fe259', '3eccfc73-4c54-584c-afd9-2813c7919110', 'Filip', 'Dobro. Mogu li plivati do plutače?', 'Добре. Можна мені плисти до буя?', 4);
  perform pg_temp.turn('7c8c939a-b8f9-5175-83e4-9a5a8ff01623', '3eccfc73-4c54-584c-afd9-2813c7919110', 'Darja', 'Samo s tatom. Tamo je dubina tri metra i jaka struja.', 'Лише з татом. Там глибина три метри й сильна течія.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ed6516c4-d500-5fd6-894d-8788c3569798', v_lesson, 'Медуза', 'Meduza', 5062, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('4f05753b-ba0e-551c-9042-f68ec77fd1d0', 'ed6516c4-d500-5fd6-894d-8788c3569798', 'Daša', 'Joj! Nešto me opeklo na nozi!', 'Ой! Щось мене обпекло за ногу!', 1);
  perform pg_temp.turn('d2880f19-0d1a-5453-84af-bd721fca31d9', 'ed6516c4-d500-5fd6-894d-8788c3569798', 'Spasilac', 'To je meduza. Izađite iz mora, molim Vas.', 'Це медуза. Вийдіть з моря, будь ласка.', 2);
  perform pg_temp.turn('ccffe508-7bf2-5b80-9067-bdb9687e0684', 'ed6516c4-d500-5fd6-894d-8788c3569798', 'Daša', 'Jako peče. Što da radim?', 'Дуже пече. Що мені робити?', 3);
  perform pg_temp.turn('3e9e8037-d878-5ebb-8e8c-b03b1638da76', 'ed6516c4-d500-5fd6-894d-8788c3569798', 'Spasilac', 'Isperite ubod morskom vodom, ne slatkom. Dok ne prestane peći, budite u hladu.', 'Промийте місце укусу морською водою, не прісною. Поки не перестане пекти, побудьте в тіні.', 4);
  perform pg_temp.turn('4d06bd80-acb9-50e8-a7ab-a0bee6e44b58', 'ed6516c4-d500-5fd6-894d-8788c3569798', 'Daša', 'Hvala Vam. Ima li danas još meduza?', 'Дякую вам. Сьогодні ще є медузи?', 5);
  perform pg_temp.turn('f568cbf6-2610-5fbb-a10a-f06b273e91ff', 'ed6516c4-d500-5fd6-894d-8788c3569798', 'Spasilac', 'Ima ih uz obalu. Čim vjetar okrene, nestat će.', 'Є біля берега. Щойно вітер зміниться, зникнуть.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.1 · урок 7: Екскурсії й національні парки — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '11809ea9-712b-5fb7-b4a6-8a5fb60f7d62';
  v_lesson constant uuid := 'b9b0bb4b-ffcb-56e0-bbb0-a927fffa9f39';
  v_gid constant uuid := '0c68352a-803a-5410-a59b-91f2c1ddc49f';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KOND'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A2.1: місце 7 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 7: Екскурсії й національні парки', 'Lekcija 7: Izleti i nacionalni parkovi', '["Купити квиток на певний час і розпитати про маршрут у нацпарку", "Зрозуміти правила парку: zabranjeno, obvezno"]'::jsonb, 20, 'PUBLISHED', 7);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'ulaznica s vremenskim terminom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'online kupnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obilazak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pješačka staza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'drvena staza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vidikovac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'panoramski vlak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brod na električni pogon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hraniti životinje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vodopad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'organizirani izlet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polazna točka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udobna obuća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dostupno za invalidska kolica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posjetitelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radno vrijeme parka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pješačenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najam bicikla', v_pos);
  v_pos := pg_temp.word(v_lesson, 'netaknut', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaštićeno područje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pravila ponašanja', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '757e15b5-4ac3-5602-a46e-183fd58bd859', 'fill_in_the_blank', 'Kako ___ došli do vidikovca?', 'bismo', '["bismo", "bih", "smo", "biste"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9e0eb1ce-155f-521c-8151-fd3615b912a8', 'multiple_choice', 'Що означає «pješačka staza»?', 'пішохідна стежка', '["огляд, обхід (маршрут)", "електрочовен", "пішохідна стежка", "незайманий"]'::jsonb, 'A2', 2, 'PUBLISHED', 'pješačka staza', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aa5c4c2c-58c6-5bee-9290-f37df41c6b00', 'multiple_choice', 'Що означає «zaštićeno područje»?', 'охоронювана територія', '["водоспад", "охоронювана територія", "годувати тварин", "години роботи парку"]'::jsonb, 'A2', 3, 'PUBLISHED', 'zaštićeno područje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9b38d40d-6da3-59b7-a29e-68d7be750ddf', 'multiple_choice', 'Що означає «ulaznica s vremenskim terminom»?', 'квиток на певний час', '["доступно для візків", "квиток на певний час", "охоронювана територія", "пішохідна стежка"]'::jsonb, 'A2', 4, 'PUBLISHED', 'ulaznica s vremenskim terminom', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '15a1bbbf-3f44-5fc8-bd0f-7d3c22a9d39d', 'multiple_choice', 'Як хорватською «незайманий»?', 'netaknut', '["zaštićeno područje", "vodopad", "brod na električni pogon", "netaknut"]'::jsonb, 'A2', 5, 'PUBLISHED', 'netaknut', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4c40c9be-0058-59c0-a921-9fe0b07e3762', 'multiple_choice', 'Як хорватською «купівля онлайн»?', 'online kupnja', '["hraniti životinje", "online kupnja", "organizirani izlet", "pješačenje"]'::jsonb, 'A2', 6, 'PUBLISHED', 'online kupnja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '084bb303-64f9-53f5-bdd6-61ae4b31327b', 'type_answer', 'Напишіть хорватською: «оглядовий майданчик»', 'vidikovac', null, 'A2', 7, 'PUBLISHED', 'vidikovac', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '376fb0f5-3135-588c-8b9d-2c6063837777', 'type_answer', 'Напишіть хорватською: «водоспад»', 'vodopad', null, 'A2', 8, 'PUBLISHED', 'vodopad', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b8758c7-5764-5a35-b3ea-344c16c4e4d1', 'type_answer', 'Напишіть хорватською: «відвідувач»', 'posjetitelj', null, 'A2', 9, 'PUBLISHED', 'posjetitelj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a2084cf0-c16e-5458-a832-842db70df75e', 'sentence_builder', 'Складіть: «Годувати тварин заборонено.»', 'Zabranjeno je hraniti životinje.', '["životinje.", "je", "hraniti", "Zabranjeno"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '98b28b63-6341-5f9c-ba64-c430d6b82d5a', 'sentence_builder', 'Складіть: «Огляд триває близько чотирьох годин.»', 'Obilazak traje oko četiri sata.', '["četiri", "oko", "Obilazak", "traje", "sata."]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0216f3ce-2ff2-547d-b085-06aa211d5e7d', 'listening', 'Прослухайте і складіть фразу', 'Molim Vas, ostanite na drvenoj stazi.', '["stazi.", "Vas,", "na", "Molim", "drvenoj", "ostanite"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'bb4c247f-b7b2-5d06-9c4c-2417993817dd', 'listening_dialogue', 'Прослухайте оголошення', 'кожні 15 хвилин; о 10:00 і 14:00; не смітити й не сходити зі стежок', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Ви біля входу в нацпарк «Крка». Послухайте оголошення.", "script": [{"hr": "Dobro došli u Nacionalni park Krka!", "ua": "Ласкаво просимо до Національного парку «Крка»!"}, {"hr": "Autobus do Skradinskog buka polazi svakih petnaest minuta.", "ua": "Автобус до Скрадинського бука відправляється кожні п’ятнадцять хвилин."}, {"hr": "Brod do Visovca vozi u deset i u četrnaest sati.", "ua": "Човен до Візовця ходить о десятій і о чотирнадцятій."}, {"hr": "Molimo posjetitelje da ostanu na stazama i ne bacaju smeće.", "ua": "Просимо відвідувачів залишатися на стежках і не смітити."}], "questions": [{"q_ua": "Як часто ходить автобус?", "options": ["кожні 15 хвилин", "кожні 50 хвилин", "двічі на день"], "correct": 0, "answer_turn": 1}, {"q_ua": "Коли ходить човен до Візовця?", "options": ["о 9:00 і 13:00", "о 11:00 і 15:00", "о 10:00 і 14:00"], "correct": 2, "answer_turn": 2}, {"q_ua": "Про що просять відвідувачів?", "options": ["купувати квитки онлайн", "не смітити й не сходити зі стежок", "не фотографувати"], "correct": 1, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'bb4c247f-b7b2-5d06-9c4c-2417993817dd', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f82f4c5-bb3e-5743-b8de-ae46f8b771e7', 'speaking', 'Квитки на десяту розпродані.', 'Ulaznice za deset su rasprodane.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '67095836-77c8-5850-b949-af4e4c3d2f11', 'speaking', 'Я хотів би квиток на одинадцяту.', 'Htio bih ulaznicu za jedanaest.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '13e2b268-65b9-5191-aed4-cc9aec5710c4', 'write_message', 'Напишіть подрузі: квитки на 9:00 розпродані, ви купили на 11:00; хай візьме зручне взуття.', 'Ulaznice za 9 su rasprodane, pa sam kupila za 11. Ponesi udobnu obuću!', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі: квитки на 9:00 розпродані, ви купили на 11:00; хай візьме зручне взуття.", "points": [{"ua": "на 9:00 розпродані", "keys": [["rasprodan"]]}, {"ua": "купили на 11:00", "keys": [["11"], ["jedanaest"]]}, {"ua": "зручне взуття", "keys": [["obuć"], ["cipel"], ["tenisic"]]}], "hints": ["ulaznice su rasprodane", "kupila sam za 11", "udobna obuća"], "models": ["Ulaznice za 9 su rasprodane, pa sam kupila za 11. Ponesi udobnu obuću!"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '13e2b268-65b9-5191-aed4-cc9aec5710c4', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '841c0a97-663e-511a-99bd-08e6f0795e03', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Postoji li staza dostupna za dječja kolica? Koliko traje?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай охоронця, чи є стежка, доступна для дитячого візка, і скільки вона триває.", "direction": "ua_hr", "points": [{"ua": "стежка", "keys": [["staz"]]}, {"ua": "для візка", "keys": [["kolic"]]}, {"ua": "скільки триває", "keys": [["traje"], ["koliko"]]}], "hints": [], "models": ["Postoji li staza dostupna za dječja kolica? Koliko traje?"], "source_ua": "Спитай охоронця, чи є стежка, доступна для дитячого візка, і скільки вона триває."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '841c0a97-663e-511a-99bd-08e6f0795e03', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6e48675f-0669-553d-ac4f-e794bd87f41d', v_lesson, 'Квитки на Плітвиці', 'Ulaznice za Plitvice', 5071, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('70528fd9-4bd6-569e-a91b-eb468440a158', '6e48675f-0669-553d-ac4f-e794bd87f41d', 'Daša', 'Darja, jesi li kupila ulaznice za Plitvice?', 'Дар’є, ти купила квитки на Плітвиці?', 1);
  perform pg_temp.turn('6bb72bc1-9113-516d-8ca1-730139d6ee94', '6e48675f-0669-553d-ac4f-e794bd87f41d', 'Darja', 'Htjela sam, ali termin u devet je rasprodan.', 'Хотіла, але час на дев’яту розпроданий.', 2);
  perform pg_temp.turn('18c4a093-a4ef-502a-85f8-7af0352b67fe', '6e48675f-0669-553d-ac4f-e794bd87f41d', 'Daša', 'Onda bih uzela termin u jedanaest. Online kupnja je jeftinija.', 'Тоді я б узяла час на одинадцяту. Онлайн дешевше.', 3);
  perform pg_temp.turn('89dfd549-ae7a-5649-9a30-42de19049211', '6e48675f-0669-553d-ac4f-e794bd87f41d', 'Darja', 'Dobro. Koliko traje obilazak?', 'Добре. Скільки триває огляд?', 4);
  perform pg_temp.turn('9e9e813f-c3cf-53a1-937a-5351daaae358', '6e48675f-0669-553d-ac4f-e794bd87f41d', 'Daša', 'Oko četiri sata. Obvezno ponesi udobnu obuću.', 'Близько чотирьох годин. Обов’язково візьми зручне взуття.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('60c77805-3f33-5f7a-988a-dcd34fc532ca', v_lesson, 'Правила в парку', 'Pravila u parku', 5072, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('8d6d2992-89ba-5a05-9a05-aac174abc5a6', '60c77805-3f33-5f7a-988a-dcd34fc532ca', 'Čuvar', 'Oprostite, kupanje u jezerima je zabranjeno.', 'Перепрошую, купатися в озерах заборонено.', 1);
  perform pg_temp.turn('0389267c-f6ac-50ee-bf65-03a3434ce31f', '60c77805-3f33-5f7a-988a-dcd34fc532ca', 'Ivan', 'Nisam znao. Htio sam samo oprati ruke.', 'Я не знав. Я хотів лише помити руки.', 2);
  perform pg_temp.turn('eef5a801-f798-5cb1-835a-3d3876859054', '60c77805-3f33-5f7a-988a-dcd34fc532ca', 'Čuvar', 'Ovo je zaštićeno područje. Molim Vas, ostanite na drvenoj stazi.', 'Це охоронювана територія. Будь ласка, залишайтеся на дерев’яній стежці.', 3);
  perform pg_temp.turn('3c301544-0def-513a-aee5-abfeab104260', '60c77805-3f33-5f7a-988a-dcd34fc532ca', 'Ivan', 'Razumijem. A kako bismo došli do velikog vodopada?', 'Зрозумів. А як би нам дістатися до великого водоспаду?', 4);
  perform pg_temp.turn('998d4eb6-425f-5d1c-85bf-36feb49455bf', '60c77805-3f33-5f7a-988a-dcd34fc532ca', 'Čuvar', 'Idite pješačkom stazom do vidikovca, pa dolje uz kanjon.', 'Ідіть пішохідною стежкою до оглядового майданчика, а тоді вниз уздовж каньйону.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.1 · урок 8: Оренда авто, скутера чи човна — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '11809ea9-712b-5fb7-b4a6-8a5fb60f7d62';
  v_lesson constant uuid := '35e0e7d1-e7a5-5633-8656-21231dc30640';
  v_gid constant uuid := '59c6c708-59b5-5781-bf5d-4ecd5aa8b7dc';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики ZAV'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 8) then
    raise exception 'A2.1: місце 8 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 8: Оренда авто, скутера чи човна', 'Lekcija 8: Najam automobila, skutera ili brodice', '["Орендувати транспорт і розпитати про страховку й заставу", "Пояснити умови: Ako vratite…, Čim…"]'::jsonb, 20, 'PUBLISHED', 8);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'rent-a-car', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skuter', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brodica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gliser', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dozvola za upravljanje brodicom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kaciga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dnevni najam', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kasko osiguranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'franšiza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blokirati na kartici', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pun spremnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vratiti s punim spremnikom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ogrebotina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oštećenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dodatni vozač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ograničenje kilometara', v_pos);
  v_pos := pg_temp.word(v_lesson, 'automatski mjenjač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vratiti vozilo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sidro', v_pos);
  v_pos := pg_temp.word(v_lesson, 'benzinska postaja na moru', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjesto preuzimanja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kilometraža', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '6ae6038d-55bc-5dfc-b3bf-cdd26df2ce18', 'fill_in_the_blank', '___ vratite auto kasnije, plaćate još jedan dan.', 'Ako', '["Čim", "Nego", "Ako", "Dok"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '08459298-158b-56dd-9aa8-d4eb34be3462', 'multiple_choice', 'Що означає «gliser»?', 'швидкісний моторний човен', '["подряпина", "повний бак", "пробіг", "швидкісний моторний човен"]'::jsonb, 'A2', 2, 'PUBLISHED', 'gliser', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7d8dca5c-81d6-5911-a6b7-84d153b135c7', 'multiple_choice', 'Що означає «rent-a-car»?', 'прокат авто', '["подряпина", "прокат авто", "якір", "додатковий водій"]'::jsonb, 'A2', 3, 'PUBLISHED', 'rent-a-car', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '192d6d13-3fa0-5d89-b992-a837380df554', 'multiple_choice', 'Що означає «brodica»?', 'човен, моторний човник', '["човен, моторний човник", "пробіг", "добова оренда", "якір"]'::jsonb, 'A2', 4, 'PUBLISHED', 'brodica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2609ca1b-f8b7-5383-8585-ccd155640386', 'multiple_choice', 'Як хорватською «заблокувати на картці (суму)»?', 'blokirati na kartici', '["gliser", "blokirati na kartici", "sidro", "dodatni vozač"]'::jsonb, 'A2', 5, 'PUBLISHED', 'blokirati na kartici', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3f59fad1-1128-5e0a-ada9-babfeb91f920', 'multiple_choice', 'Як хорватською «обмеження пробігу»?', 'ograničenje kilometara', '["pun spremnik", "ogrebotina", "sidro", "ograničenje kilometara"]'::jsonb, 'A2', 6, 'PUBLISHED', 'ograničenje kilometara', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3e42dd66-dc62-5ee4-954b-151eb02701b4', 'type_answer', 'Напишіть хорватською: «пробіг»', 'kilometraža', null, 'A2', 7, 'PUBLISHED', 'kilometraža', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3ffa2523-3922-588f-b1a5-4bdcba019f93', 'type_answer', 'Напишіть хорватською: «добова оренда»', 'dnevni najam', null, 'A2', 8, 'PUBLISHED', 'dnevni najam', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b3a984da-2e61-50ad-b5dc-a1dcfd2ffaba', 'type_answer', 'Напишіть хорватською: «франшиза (страхова)»', 'franšiza', null, 'A2', 9, 'PUBLISHED', 'franšiza', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '76b6bf0a-e870-5d10-aca9-746531550a18', 'sentence_builder', 'Складіть: «Поверніть авто з повним баком.»', 'Vratite auto s punim spremnikom.', '["Vratite", "s", "spremnikom.", "auto", "punim"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8289c888-8c46-5c13-be9b-60046328a076', 'sentence_builder', 'Складіть: «На дверях маленька подряпина.»', 'Na vratima je mala ogrebotina.', '["je", "ogrebotina.", "mala", "vratima", "Na"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd3069ca2-aec5-5ec9-8892-9c610768dbe7', 'listening', 'Прослухайте і складіть фразу', 'Koliko košta dnevni najam brodice?', '["dnevni", "košta", "najam", "Koliko", "brodice?"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'c6b0d2d5-930d-50bc-83dc-21093cf82fa6', 'listening_dialogue', 'Прослухайте розмову', '100 євро; готівкою', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Даша бере скутер в оренду на острові Хвар. Послухайте розмову.", "script": [{"speaker": "Daša", "hr": "Dobar dan, koliko košta skuter za tri dana?", "ua": "Добрий день, скільки коштує скутер на три дні?"}, {"speaker": "Iznajmljivač", "hr": "Sto eura za tri dana, s kacigom.", "ua": "Сто євро за три дні, зі шоломом."}, {"speaker": "Daša", "hr": "Treba li kaucija?", "ua": "Потрібна застава?"}, {"speaker": "Iznajmljivač", "hr": "Treba, pedeset eura u gotovini. Vratit ću je kad vratite skuter.", "ua": "Потрібна, п’ятдесят євро готівкою. Я поверну її, коли ви повернете скутер."}], "questions": [{"q_ua": "Скільки коштує оренда на три дні?", "options": ["50 євро", "100 євро", "150 євро"], "correct": 1, "answer_turn": 1}, {"q_ua": "Як платять заставу?", "options": ["готівкою", "карткою", "переказом"], "correct": 0, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'c6b0d2d5-930d-50bc-83dc-21093cf82fa6', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '86122e1e-c6e7-57bc-b9a9-cb3a22c0acf6', 'speaking', 'Мені потрібне авто з автоматичною коробкою.', 'Trebam auto s automatskim mjenjačem.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a513df5-c7d3-500e-ac3e-9f2556109bd7', 'speaking', 'Скільки коштує додатковий водій?', 'Koliko košta dodatni vozač?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '6662a111-d12e-55c9-bb14-101d809098d7', 'write_message', 'Напишіть у прокат: хочете орендувати авто з 3 до 10 липня, з автоматичною коробкою, і спитайте ціну каско.', 'Dobar dan, htio bih unajmiti auto s automatskim mjenjačem od 3. do 10. srpnja. Koliko košta kasko osiguranje?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у прокат: хочете орендувати авто з 3 до 10 липня, з автоматичною коробкою, і спитайте ціну каско.", "points": [{"ua": "з 3 до 10 липня", "keys": [["3", "10"], ["trećeg", "desetog"]]}, {"ua": "автоматична коробка", "keys": [["automatsk"]]}, {"ua": "ціна каско", "keys": [["kasko"]]}], "hints": ["htio bih unajmiti auto", "od 3. do 10. srpnja", "automatski mjenjač", "koliko košta kasko?"], "models": ["Dobar dan, htio bih unajmiti auto s automatskim mjenjačem od 3. do 10. srpnja. Koliko košta kasko osiguranje?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '6662a111-d12e-55c9-bb14-101d809098d7', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'cb008e1c-7f70-5f96-928e-afd3c1e656d8', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Moj prijatelj želi biti dodatni vozač. Koliko to košta?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи працівникові прокату, що я хочу бути додатковим водієм, і спитай, скільки це коштує.", "direction": "ua_hr", "points": [{"ua": "додатковий водій", "keys": [["dodatn"]]}, {"ua": "скільки коштує", "keys": [["košt"], ["cijen"]]}], "hints": [], "models": ["Moj prijatelj želi biti dodatni vozač. Koliko to košta?"], "source_ua": "Скажи працівникові прокату, що я хочу бути додатковим водієм, і спитай, скільки це коштує."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'cb008e1c-7f70-5f96-928e-afd3c1e656d8', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('65876ade-8fd7-5279-94b5-874a4770e2dd', v_lesson, 'У прокаті', 'U rent-a-caru', 5081, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('03367ab5-1d13-5bac-b9e7-28684e44dbfa', '65876ade-8fd7-5279-94b5-874a4770e2dd', 'Daša', 'Dobar dan, imam rezervaciju za mali auto s automatskim mjenjačem.', 'Добрий день, у мене бронь на маленьке авто з автоматичною коробкою.', 1);
  perform pg_temp.turn('e656cca1-4847-5e3f-a782-caa3f815101c', '65876ade-8fd7-5279-94b5-874a4770e2dd', 'Službenik', 'Izvolite. Hoćete li kasko osiguranje? Bez njega je franšiza tisuću eura.', 'Прошу. Бажаєте страхування каско? Без нього франшиза тисяча євро.', 2);
  perform pg_temp.turn('8eaa2149-6458-521e-9911-fc6dca526481', '65876ade-8fd7-5279-94b5-874a4770e2dd', 'Daša', 'Hoću. A kolika je kaucija?', 'Так. А яка застава?', 3);
  perform pg_temp.turn('d2022c3a-75ab-55fb-a26b-ead22f2e7ac2', '65876ade-8fd7-5279-94b5-874a4770e2dd', 'Službenik', 'Tristo eura, blokirat ćemo ih na kartici. Auto je s punim spremnikom.', 'Триста євро, ми заблокуємо їх на картці. Авто з повним баком.', 4);
  perform pg_temp.turn('2a2d7bbf-5bb4-5153-97d9-bc7994f81245', '65876ade-8fd7-5279-94b5-874a4770e2dd', 'Daša', 'Na stražnjim vratima je ogrebotina. Možete li to zapisati?', 'На задніх дверях подряпина. Можете це записати?', 5);
  perform pg_temp.turn('0c5dbb59-8217-5434-be86-a550d01573ae', '65876ade-8fd7-5279-94b5-874a4770e2dd', 'Službenik', 'Naravno. Ako vratite auto s punim spremnikom, ništa ne plaćate.', 'Звісно. Якщо повернете авто з повним баком, нічого не платите.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8d464f37-3d5d-5b25-99de-7dae9a92c908', v_lesson, 'Човен на день', 'Brodica na dan', 5082, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('2fce7eff-2142-5512-b094-aa7270f7bd3a', '8d464f37-3d5d-5b25-99de-7dae9a92c908', 'Ivan', 'Koliko košta dnevni najam brodice?', 'Скільки коштує добова оренда човна?', 1);
  perform pg_temp.turn('2f361215-c273-5c52-a843-efa1b9af3862', '8d464f37-3d5d-5b25-99de-7dae9a92c908', 'Iznajmljivač', 'Sto dvadeset eura, gorivo nije uključeno. Imate li dozvolu?', 'Сто двадцять євро, пальне не включено. У вас є посвідчення?', 2);
  perform pg_temp.turn('7f98dc8e-75d8-5c33-8275-e7de0323427e', '8d464f37-3d5d-5b25-99de-7dae9a92c908', 'Ivan', 'Nemam. Treba li za ovu brodicu?', 'Немає. Для цього човна потрібно?', 3);
  perform pg_temp.turn('01a5e8d2-a651-5e40-82d1-9de06dab6de6', '8d464f37-3d5d-5b25-99de-7dae9a92c908', 'Iznajmljivač', 'Ne treba, motor je slab. Ali gliser ne možete voziti bez dozvole.', 'Не потрібно, мотор слабкий. Але швидкісним човном без посвідчення керувати не можна.', 4);
  perform pg_temp.turn('fe658f13-5b9a-52f6-abfa-ec1259caed6b', '8d464f37-3d5d-5b25-99de-7dae9a92c908', 'Ivan', 'Dobro. Gdje možemo kupiti gorivo?', 'Добре. Де можна купити пальне?', 5);
  perform pg_temp.turn('c9cfa22d-20d0-537c-8005-248a17d91805', '8d464f37-3d5d-5b25-99de-7dae9a92c908', 'Iznajmljivač', 'Na benzinskoj postaji na moru, u luci. Vratite brodicu do sedam.', 'На плавучій заправці в порту. Поверніть човен до сьомої.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- 3. Модуль і юніт — опубліковані
update public.modules set status = 'PUBLISHED', title_ua = 'Модуль A2.1 — Туризм і подорожі: Адріатика', title_hr = 'Modul A2.1 — Turizam i putovanja: Jadran' where id = '2cfdcacf-767e-5f3f-bb15-9b245bd598c9';
update public.units set status = 'PUBLISHED' where id = '11809ea9-712b-5fb7-b4a6-8a5fb60f7d62';

-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('07da4162-a209-5893-8f3c-db3571a32f29', '2aaf70f9-5a0c-53a3-a621-e42cc4548661', '778e1a8f-01d6-5bc0-b3e3-3e3123551c8b', '098e590d-283c-56db-927d-80488d4bce45', 'd48d7fc9-54b1-5140-8d5f-c627af7bdebb', 'bd9353b6-9d9e-5192-8124-f6a2dcf3f178', 'b9b0bb4b-ffcb-56e0-bbb0-a927fffa9f39', '35e0e7d1-e7a5-5633-8656-21231dc30640')
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
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 20 or l.unit_id <> '11809ea9-712b-5fb7-b4a6-8a5fb60f7d62');
  select count(*) into v_titles from (values ('07da4162-a209-5893-8f3c-db3571a32f29'::uuid, 'Урок 1:%', 1), ('2aaf70f9-5a0c-53a3-a621-e42cc4548661'::uuid, 'Урок 2:%', 2), ('778e1a8f-01d6-5bc0-b3e3-3e3123551c8b'::uuid, 'Урок 3:%', 3), ('098e590d-283c-56db-927d-80488d4bce45'::uuid, 'Урок 4:%', 4), ('d48d7fc9-54b1-5140-8d5f-c627af7bdebb'::uuid, 'Урок 5:%', 5), ('bd9353b6-9d9e-5192-8124-f6a2dcf3f178'::uuid, 'Урок 6:%', 6), ('b9b0bb4b-ffcb-56e0-bbb0-a927fffa9f39'::uuid, 'Урок 7:%', 7), ('35e0e7d1-e7a5-5633-8656-21231dc30640'::uuid, 'Урок 8:%', 8)) as t(id, pat, o)
    left join public.lessons l on l.id = t.id and l.title_ua like t.pat and l.order_index = t.o
   where l.id is null;
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
      where l.level_code = 'A2' and l.status = 'PUBLISHED' and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A2.1: % уроків з неправильним складом', v_bad; end if;
  if v_titles > 0 then raise exception 'Модуль A2.1: % уроків не на своєму місці чи з неправильним номером', v_titles; end if;
  if v_words > 0 then raise exception 'A2: % слів повторюються в кількох уроках', v_words; end if;
  if (select status from public.modules where id = '2cfdcacf-767e-5f3f-bb15-9b245bd598c9') <> 'PUBLISHED' then raise exception 'Модуль A2.1 не опубліковано'; end if;
  raise notice 'Готово: модуль A2.1 — 8 уроків, слів 174';
end $$;

commit;
