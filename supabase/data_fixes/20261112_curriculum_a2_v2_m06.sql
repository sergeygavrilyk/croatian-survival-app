-- =====================================================================
-- Програма A2 v2 · модуль A2.6 «Установи, послуги й гроші» · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2.py 6 (не редагуйте вручну).
--
-- Рішення власника 2026-11-12: 20–25 нових слів на урок, 90–95 % слів — нові для рівня, діалоги під тему,
-- частіше Даша / Дар’я; «Прослухайте діалог чи оголошення» в кожному уроці; бета (PUBLISHED).
--   * Уроки 37–42 (6): слів у них 126. Кожен: 20–25 слів, 2 діалоги, 15 вправ
--     (одна — «Прослухайте діалог чи оголошення»), «Напишіть повідомлення» і «Перекажіть другу» (ua → hr, необов’язкові), 20 хв.
--   * Слова: 126 (нові — PUBLISHED; ті, що вже є в словнику, не змінюються).
--   * Модуль і юніт A2.6 → PUBLISHED. Потрібен уже запущений 20261112_curriculum_a2_v2_00_structure.sql.
--   * Нічого не видаляє. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.units where id = '6ce8eeae-3862-5515-9d3a-963bbf590733') then
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

-- 1. Слова уроків A2.6 (126): нові — PUBLISHED (бета); наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A2', t.ua, t.vtype, t.forms, t.examples, 'PUBLISHED', 'claude_curriculum_a2_v2'
  from jsonb_to_recordset('[{"lemma": "frizerski salon", "normalized": "frizerski salon", "pos": "phrase", "ua": "перукарня, салон", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Frizerski salon je odmah iza ugla."]}, {"lemma": "šišanje", "normalized": "sisanje", "pos": "noun", "ua": "стрижка", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Šišanje i feniranje koštaju trideset eura."]}, {"lemma": "ošišati se", "normalized": "osisati se", "pos": "verb", "ua": "підстригтися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "šišati se"}, "examples": ["Sutra se idem ošišati."]}, {"lemma": "podšišati", "normalized": "podsisati", "pos": "verb", "ua": "підрівняти (волосся)", "vtype": "core", "forms": {"aspect": "pfv", "pair": "podšišavati"}, "examples": ["Samo me malo podšišajte."]}, {"lemma": "šiške", "normalized": "siske", "pos": "noun", "ua": "чубчик", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Htjela bih kraće šiške."]}, {"lemma": "bojanje kose", "normalized": "bojanje kose", "pos": "phrase", "ua": "фарбування волосся", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Bojanje kose traje dva sata."]}, {"lemma": "pramenovi", "normalized": "pramenovi", "pos": "noun", "ua": "мелірування, пасма", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Napravila sam svijetle pramenove."]}, {"lemma": "brijačnica", "normalized": "brijacnica", "pos": "noun", "ua": "барбершоп, чоловіча перукарня", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Muž ide u brijačnicu svaki mjesec."]}, {"lemma": "naručiti se", "normalized": "naruciti se", "pos": "verb", "ua": "записатися (на прийом, послугу)", "vtype": "core", "forms": {"aspect": "pfv", "pair": "naručivati se"}, "examples": ["Naručila sam se kod frizerke za petak."]}, {"lemma": "kemijska čistionica", "normalized": "kemijska cistionica", "pos": "phrase", "ua": "хімчистка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Kaput sam odnijela u kemijsku čistionicu."]}, {"lemma": "skinuti mrlju", "normalized": "skinuti mrlju", "pos": "phrase", "ua": "вивести пляму", "vtype": "chunk", "forms": {}, "examples": ["Mrlju od vina teško je skinuti."]}, {"lemma": "krojač", "normalized": "krojac", "pos": "noun", "ua": "кравець", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Krojač će mi skratiti hlače."]}, {"lemma": "skratiti", "normalized": "skratiti", "pos": "verb", "ua": "укоротити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "skraćivati"}, "examples": ["Treba skratiti rukave za dva centimetra."]}, {"lemma": "suziti", "normalized": "suziti", "pos": "verb", "ua": "звузити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "sužavati"}, "examples": ["Haljinu treba suziti u struku."]}, {"lemma": "zamijeniti patent", "normalized": "zamijeniti patent", "pos": "phrase", "ua": "замінити застібку-блискавку", "vtype": "chunk", "forms": {}, "examples": ["Na jakni treba zamijeniti patent."]}, {"lemma": "postolar", "normalized": "postolar", "pos": "noun", "ua": "швець", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Postolar je popravio moje čizme."]}, {"lemma": "potpetica", "normalized": "potpetica", "pos": "noun", "ua": "підбор", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Slomila mi se potpetica."]}, {"lemma": "đon", "normalized": "don", "pos": "noun", "ua": "підошва", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Đon se odlijepio."]}, {"lemma": "biti gotov", "normalized": "biti gotov", "pos": "phrase", "ua": "бути готовим", "vtype": "chunk", "forms": {}, "examples": ["Kada će kaput biti gotov?"]}, {"lemma": "potvrdnica", "normalized": "potvrdnica", "pos": "noun", "ua": "квитанція (на замовлення)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ne zaboravite potvrdnicu kad dođete."]}, {"lemma": "feniranje", "normalized": "feniranje", "pos": "noun", "ua": "укладання феном", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Feniranje je uključeno u cijenu."]}, {"lemma": "kozmetički salon", "normalized": "kozmeticki salon", "pos": "phrase", "ua": "косметичний салон", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["U kozmetičkom salonu radim manikuru."]}, {"lemma": "bravar", "normalized": "bravar", "pos": "noun", "ua": "слюсар (замки)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Zaključala sam se vani, zvala sam bravara."]}, {"lemma": "serviser", "normalized": "serviser", "pos": "noun", "ua": "майстер з ремонту техніки", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Serviser za perilicu dolazi u utorak."]}, {"lemma": "stolar", "normalized": "stolar", "pos": "noun", "ua": "столяр", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Stolar je napravio novi ormar."]}, {"lemma": "soboslikar", "normalized": "soboslikar", "pos": "noun", "ua": "маляр (стін)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Soboslikar će okrečiti stan za dva dana."]}, {"lemma": "keramičar", "normalized": "keramicar", "pos": "noun", "ua": "плиточник", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Keramičar je postavio nove pločice."]}, {"lemma": "okrečiti", "normalized": "okreciti", "pos": "verb", "ua": "побілити, пофарбувати стіни", "vtype": "core", "forms": {"aspect": "pfv", "pair": "krečiti"}, "examples": ["Prije useljenja treba okrečiti zidove."]}, {"lemma": "pločice", "normalized": "plocice", "pos": "noun", "ua": "плитка", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["U kupaonici su popucale pločice."]}, {"lemma": "brava", "normalized": "brava", "pos": "noun", "ua": "замок", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Brava se zaglavila."]}, {"lemma": "zamijeniti bravu", "normalized": "zamijeniti bravu", "pos": "phrase", "ua": "замінити замок", "vtype": "chunk", "forms": {}, "examples": ["Zamijenili smo staru bravu."]}, {"lemma": "predračun", "normalized": "predracun", "pos": "noun", "ua": "попередній рахунок, кошторис", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Pošaljite mi predračun prije radova."]}, {"lemma": "procjena", "normalized": "procjena", "pos": "noun", "ua": "оцінка (вартості)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Procjena je oko dvjesto eura."]}, {"lemma": "materijal", "normalized": "materijal", "pos": "noun", "ua": "матеріал", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Materijal nije uključen u cijenu."]}, {"lemma": "izlazak na teren", "normalized": "izlazak na teren", "pos": "phrase", "ua": "виїзд майстра", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Izlazak na teren košta dvadeset eura."]}, {"lemma": "iskočio je osigurač", "normalized": "iskocio je osigurac", "pos": "phrase", "ua": "вибило запобіжник", "vtype": "chunk", "forms": {}, "examples": ["Iskočio je osigurač i nemamo struje."]}, {"lemma": "začepiti se", "normalized": "zacepiti se", "pos": "verb", "ua": "засмітитися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "začepljivati se"}, "examples": ["Začepio se odvod u kuhinji."]}, {"lemma": "kapati", "normalized": "kapati", "pos": "verb", "ua": "капати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Slavina kapa cijelu noć."]}, {"lemma": "ugraditi", "normalized": "ugraditi", "pos": "verb", "ua": "встановити, вмонтувати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "ugrađivati"}, "examples": ["Ugradili su novi bojler."]}, {"lemma": "dijelovi", "normalized": "dijelovi", "pos": "noun", "ua": "запчастини", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Treba naručiti dijelove za perilicu."]}, {"lemma": "jamstvo na radove", "normalized": "jamstvo na radove", "pos": "phrase", "ua": "гарантія на роботи", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Imate jamstvo na radove godinu dana."]}, {"lemma": "hitna intervencija", "normalized": "hitna intervencija", "pos": "phrase", "ua": "терміновий виклик", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Hitna intervencija noću je skuplja."]}, {"lemma": "dogovoriti termin", "normalized": "dogovoriti termin", "pos": "phrase", "ua": "домовитися про час", "vtype": "chunk", "forms": {}, "examples": ["Možemo li dogovoriti termin za srijedu?"]}, {"lemma": "bilježnik", "normalized": "biljeznik", "pos": "noun", "ua": "нотаріус (розм.)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Bilježnik radi do četiri."]}, {"lemma": "javnobilježnički ured", "normalized": "javnobiljeznicki ured", "pos": "phrase", "ua": "нотаріальна контора", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Javnobilježnički ured je na prvom katu."]}, {"lemma": "ovjeriti potpis", "normalized": "ovjeriti potpis", "pos": "phrase", "ua": "засвідчити підпис", "vtype": "chunk", "forms": {}, "examples": ["Moram ovjeriti potpis na ugovoru."]}, {"lemma": "ovjeriti presliku", "normalized": "ovjeriti presliku", "pos": "phrase", "ua": "засвідчити копію", "vtype": "chunk", "forms": {}, "examples": ["Bilježnik može ovjeriti presliku diplome."]}, {"lemma": "punomoć", "normalized": "punomoc", "pos": "noun", "ua": "довіреність", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Dala sam sestri punomoć za banku."]}, {"lemma": "opunomoćenik", "normalized": "opunomocenik", "pos": "noun", "ua": "довірена особа", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Opunomoćenik može potpisati umjesto Vas."]}, {"lemma": "izjava", "normalized": "izjava", "pos": "noun", "ua": "заява, декларація (письмова)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Trebate potpisati izjavu pred bilježnikom."]}, {"lemma": "suglasnost za putovanje djeteta", "normalized": "suglasnost za putovanje djeteta", "pos": "phrase", "ua": "згода на виїзд дитини", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za putovanje s bakom treba suglasnost za putovanje djeteta."]}, {"lemma": "ugovor o najmu", "normalized": "ugovor o najmu", "pos": "phrase", "ua": "договір оренди", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ugovor o najmu treba ovjeriti kod bilježnika."]}, {"lemma": "kupoprodajni ugovor", "normalized": "kupoprodajni ugovor", "pos": "phrase", "ua": "договір купівлі-продажу", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Kupoprodajni ugovor potpisali smo kod bilježnika."]}, {"lemma": "solemnizacija", "normalized": "solemnizacija", "pos": "noun", "ua": "нотаріальне посвідчення (договору)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Solemnizacija ugovora traje pola sata."]}, {"lemma": "javnobilježnička pristojba", "normalized": "javnobiljeznicka pristojba", "pos": "phrase", "ua": "нотаріальний збір", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Javnobilježnička pristojba je propisana."]}, {"lemma": "original", "normalized": "original", "pos": "noun", "ua": "оригінал", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Donesite original i presliku."]}, {"lemma": "preslika", "normalized": "preslika", "pos": "noun", "ua": "копія", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Preslika se ovjerava uz original."]}, {"lemma": "identificirati se", "normalized": "identificirati se", "pos": "verb", "ua": "посвідчити особу", "vtype": "core", "forms": {"aspect": "biasp"}, "examples": ["Pred bilježnikom se identificirate putovnicom."]}, {"lemma": "vlastoručno", "normalized": "vlastorucno", "pos": "adverb", "ua": "власноруч", "vtype": "core", "forms": {}, "examples": ["Izjavu potpišite vlastoručno."]}, {"lemma": "pečat", "normalized": "pecat", "pos": "noun", "ua": "печатка", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Na ovjeri je pečat i potpis bilježnika."]}, {"lemma": "vjerodostojan", "normalized": "vjerodostojan", "pos": "adjective", "ua": "достовірний, автентичний", "vtype": "core", "forms": {}, "examples": ["Dokument je vjerodostojan."]}, {"lemma": "prevesti i ovjeriti", "normalized": "prevesti i ovjeriti", "pos": "phrase", "ua": "перекласти й засвідчити", "vtype": "chunk", "forms": {}, "examples": ["Rodni list treba prevesti i ovjeriti."]}, {"lemma": "ovjereno", "normalized": "ovjereno", "pos": "adverb", "ua": "засвідчено", "vtype": "core", "forms": {}, "examples": ["Na kraju piše: ovjereno."]}, {"lemma": "ovjera prijevoda", "normalized": "ovjera prijevoda", "pos": "phrase", "ua": "засвідчення перекладу", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Ovjera prijevoda radi se kod sudskog tumača."]}, {"lemma": "Porezna uprava", "normalized": "porezna uprava", "pos": "phrase", "ua": "Податкова управа", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Porezna uprava ima ispostavu u svakom gradu."]}, {"lemma": "ispostava", "normalized": "ispostava", "pos": "noun", "ua": "відділення (установи)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Idem u ispostavu Porezne uprave na Trešnjevci."]}, {"lemma": "osobni identifikacijski broj", "normalized": "osobni identifikacijski broj", "pos": "phrase", "ua": "особистий ідентифікаційний номер (OIB)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Osobni identifikacijski broj ima jedanaest znamenki."]}, {"lemma": "potvrda o OIB-u", "normalized": "potvrda o oib-u", "pos": "phrase", "ua": "довідка про OIB", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Banka traži potvrdu o OIB-u."]}, {"lemma": "porezni obveznik", "normalized": "porezni obveznik", "pos": "phrase", "ua": "платник податків", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Svaki porezni obveznik ima svoj OIB."]}, {"lemma": "e-Porezna", "normalized": "e-porezna", "pos": "noun", "ua": "е-Порезна (онлайн-кабінет податкової)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Prijavu možete predati preko e-Porezne."]}, {"lemma": "potvrda o dohotku", "normalized": "potvrda o dohotku", "pos": "phrase", "ua": "довідка про доходи", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za stan trebam potvrdu o dohotku."]}, {"lemma": "porezni dug", "normalized": "porezni dug", "pos": "phrase", "ua": "податковий борг", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Nemam porezni dug."]}, {"lemma": "potvrda o nepostojanju duga", "normalized": "potvrda o nepostojanju duga", "pos": "phrase", "ua": "довідка про відсутність боргу", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za natječaj treba potvrda o nepostojanju duga."]}, {"lemma": "porez na nekretnine", "normalized": "porez na nekretnine", "pos": "phrase", "ua": "податок на нерухомість", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Porez na nekretnine plaća vlasnik."]}, {"lemma": "rješenje o porezu", "normalized": "rjesenje o porezu", "pos": "phrase", "ua": "податкове повідомлення-рішення", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Rješenje o porezu stiglo je poštom."]}, {"lemma": "uplatiti porez", "normalized": "uplatiti porez", "pos": "phrase", "ua": "сплатити податок", "vtype": "chunk", "forms": {}, "examples": ["Porez treba uplatiti u roku od osam dana."]}, {"lemma": "poziv na broj", "normalized": "poziv na broj", "pos": "phrase", "ua": "призначення платежу (номер)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Na uplatnici upišite poziv na broj."]}, {"lemma": "kamata", "normalized": "kamata", "pos": "noun", "ua": "відсоток, пеня", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ako kasnite, plaćate kamate."]}, {"lemma": "šalter", "normalized": "salter", "pos": "noun", "ua": "віконце (обслуговування)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Pričekajte na šalteru broj tri."]}, {"lemma": "broj u redu", "normalized": "broj u redu", "pos": "phrase", "ua": "номер у черзі", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Uzmite broj u redu na ulazu."]}, {"lemma": "elektronički", "normalized": "elektronicki", "pos": "adverb", "ua": "електронно", "vtype": "core", "forms": {}, "examples": ["Potvrdu možete dobiti i elektronički."]}, {"lemma": "NIAS", "normalized": "nias", "pos": "noun", "ua": "НІАС (система входу в е-сервіси)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Za e-Poreznu se prijavljujete preko NIAS-a."]}, {"lemma": "vjerodajnica", "normalized": "vjerodajnica", "pos": "noun", "ua": "облікові дані (для входу)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Za prijavu trebate vjerodajnicu."]}, {"lemma": "ovlaštenje", "normalized": "ovlastenje", "pos": "noun", "ua": "повноваження, дозвіл", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Knjigovođa ima ovlaštenje za moju e-Poreznu."]}, {"lemma": "predati prijavu", "normalized": "predati prijavu", "pos": "phrase", "ua": "подати декларацію", "vtype": "chunk", "forms": {}, "examples": ["Prijava se predaje do kraja veljače."]}, {"lemma": "polica osiguranja", "normalized": "polica osiguranja", "pos": "phrase", "ua": "страховий поліс", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Policu osiguranja dobit ćete e-mailom."]}, {"lemma": "osiguravajuće društvo", "normalized": "osiguravajuce drustvo", "pos": "phrase", "ua": "страхова компанія", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Usporedila sam tri osiguravajuća društva."]}, {"lemma": "premija", "normalized": "premija", "pos": "noun", "ua": "страховий внесок", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Godišnja premija je dvjesto eura."]}, {"lemma": "obvezno osiguranje", "normalized": "obvezno osiguranje", "pos": "phrase", "ua": "обов’язкове страхування", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Obvezno osiguranje za auto plaća se svake godine."]}, {"lemma": "osnovno zdravstveno osiguranje", "normalized": "osnovno zdravstveno osiguranje", "pos": "phrase", "ua": "базове медичне страхування", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Osnovno zdravstveno osiguranje plaća poslodavac."]}, {"lemma": "HZZO", "normalized": "hzzo", "pos": "noun", "ua": "HZZO (Хорватський фонд медичного страхування)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Prijavila sam se u HZZO."]}, {"lemma": "participacija", "normalized": "participacija", "pos": "noun", "ua": "доплата пацієнта (за медпослугу)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["S dopunskim ne plaćate participaciju."]}, {"lemma": "osiguranje kućanstva", "normalized": "osiguranje kucanstva", "pos": "phrase", "ua": "страхування домашнього майна", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Osiguranje kućanstva pokriva i krađu."]}, {"lemma": "pokrivati", "normalized": "pokrivati", "pos": "verb", "ua": "покривати (про страховку)", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Polica ne pokriva štetu od potresa."]}, {"lemma": "osigurani slučaj", "normalized": "osigurani slucaj", "pos": "phrase", "ua": "страховий випадок", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Je li ovo osigurani slučaj?"]}, {"lemma": "prijava štete", "normalized": "prijava stete", "pos": "phrase", "ua": "заява про збиток", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Prijavu štete možete poslati online."]}, {"lemma": "prijaviti štetu", "normalized": "prijaviti stetu", "pos": "phrase", "ua": "заявити про збиток", "vtype": "chunk", "forms": {}, "examples": ["Štetu treba prijaviti u roku od tri dana."]}, {"lemma": "procjenitelj", "normalized": "procjenitelj", "pos": "noun", "ua": "оцінювач (страхової)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Procjenitelj dolazi pogledati štetu."]}, {"lemma": "isplata štete", "normalized": "isplata stete", "pos": "phrase", "ua": "страхова виплата", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Isplata štete trajala je mjesec dana."]}, {"lemma": "poplava", "normalized": "poplava", "pos": "noun", "ua": "затоплення, повінь", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Poplava je oštetila podrum."]}, {"lemma": "bonus", "normalized": "bonus", "pos": "noun", "ua": "бонус (знижка за безаварійну їзду)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Zbog bonusa plaćam manju premiju."]}, {"lemma": "obnoviti policu", "normalized": "obnoviti policu", "pos": "phrase", "ua": "продовжити поліс", "vtype": "chunk", "forms": {}, "examples": ["Policu treba obnoviti prije isteka."]}, {"lemma": "istek", "normalized": "istek", "pos": "noun", "ua": "закінчення (строку)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Istek police je u ožujku."]}, {"lemma": "uvjeti osiguranja", "normalized": "uvjeti osiguranja", "pos": "phrase", "ua": "умови страхування", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Pažljivo pročitajte uvjete osiguranja."]}, {"lemma": "osiguranje od odgovornosti", "normalized": "osiguranje od odgovornosti", "pos": "phrase", "ua": "страхування відповідальності", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Osiguranje od odgovornosti pokriva štetu susjedu."]}, {"lemma": "osiguranik", "normalized": "osiguranik", "pos": "noun", "ua": "застрахована особа", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Osiguranik mora prijaviti promjenu adrese."]}, {"lemma": "molba", "normalized": "molba", "pos": "noun", "ua": "прохання, заява (офіційна)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Napisala sam molbu za smještaj djeteta u vrtić."]}, {"lemma": "podnositelj zahtjeva", "normalized": "podnositelj zahtjeva", "pos": "phrase", "ua": "заявник", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Podnositelj zahtjeva mora potpisati obrazac."]}, {"lemma": "naslovljeno na", "normalized": "naslovljeno na", "pos": "phrase", "ua": "адресовано (кому)", "vtype": "chunk", "forms": {}, "examples": ["Zahtjev je naslovljen na Gradski ured."]}, {"lemma": "predmet", "normalized": "predmet", "pos": "noun", "ua": "тема (офіційного листа)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Predmet: zahtjev za izdavanje potvrde."]}, {"lemma": "ovim putem", "normalized": "ovim putem", "pos": "phrase", "ua": "цим листом, таким чином", "vtype": "chunk", "forms": {}, "examples": ["Ovim putem molim izdavanje potvrde."]}, {"lemma": "molim izdavanje", "normalized": "molim izdavanje", "pos": "phrase", "ua": "прошу видати", "vtype": "chunk", "forms": {}, "examples": ["Molim izdavanje potvrde o prebivalištu."]}, {"lemma": "obrazloženje", "normalized": "obrazlozenje", "pos": "noun", "ua": "обґрунтування", "vtype": "core", "forms": {"gender": "n"}, "examples": ["U obrazloženju napišite zašto trebate potvrdu."]}, {"lemma": "u prilogu", "normalized": "u prilogu", "pos": "phrase", "ua": "у додатку", "vtype": "chunk", "forms": {}, "examples": ["U prilogu dostavljam presliku putovnice."]}, {"lemma": "pisarnica", "normalized": "pisarnica", "pos": "noun", "ua": "канцелярія (приймання документів)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Zahtjev se predaje u pisarnici."]}, {"lemma": "urudžbeni broj", "normalized": "urudzbeni broj", "pos": "phrase", "ua": "вхідний номер (реєстраційний)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Zapišite urudžbeni broj zahtjeva."]}, {"lemma": "klasa", "normalized": "klasa", "pos": "noun", "ua": "класифікаційний номер (справи)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Na rješenju piše klasa i urudžbeni broj."]}, {"lemma": "žalba", "normalized": "zalba", "pos": "noun", "ua": "скарга, оскарження", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Na rješenje možete podnijeti žalbu."]}, {"lemma": "pravo na žalbu", "normalized": "pravo na zalbu", "pos": "phrase", "ua": "право на оскарження", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Imate pravo na žalbu u roku od petnaest dana."]}, {"lemma": "zakonski rok", "normalized": "zakonski rok", "pos": "phrase", "ua": "установлений законом строк", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ured mora odgovoriti u zakonskom roku."]}, {"lemma": "nadležan", "normalized": "nadlezan", "pos": "adjective", "ua": "компетентний, відповідальний (орган)", "vtype": "core", "forms": {}, "examples": ["Koji ured je nadležan za to?"]}, {"lemma": "povratnica", "normalized": "povratnica", "pos": "noun", "ua": "повідомлення про вручення", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Preporučeno pismo s povratnicom."]}, {"lemma": "službena osoba", "normalized": "sluzbena osoba", "pos": "phrase", "ua": "посадова особа", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Zahtjev je zaprimila službena osoba."]}, {"lemma": "ispuniti obrazac", "normalized": "ispuniti obrazac", "pos": "phrase", "ua": "заповнити бланк", "vtype": "chunk", "forms": {}, "examples": ["Ispunite obrazac tiskanim slovima."]}, {"lemma": "tiskana slova", "normalized": "tiskana slova", "pos": "phrase", "ua": "друковані літери", "vtype": "chunk", "forms": {"gender": "n_pl"}, "examples": ["Ime napišite tiskanim slovima."]}, {"lemma": "dopuna zahtjeva", "normalized": "dopuna zahtjeva", "pos": "phrase", "ua": "доповнення заяви", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Dobili smo poziv za dopunu zahtjeva."]}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 2. Уроки модуля A2.6
-- A2.6 · урок 37: Перукарня, хімчистка, ремонт одягу — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6ce8eeae-3862-5515-9d3a-963bbf590733';
  v_lesson constant uuid := '8ab1c1e5-b217-5175-ab89-325106da3504';
  v_gid constant uuid := 'b7103d09-8e69-53f7-8f17-a90c771fa1a2';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики GEN'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A2.6: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 37: Перукарня, хімчистка, ремонт одягу', 'Lekcija 37: Frizer, kemijska čistionica i popravak odjeće', '["Замовити послугу в перукарні, хімчистці, у кравця й шевця", "Вживати родовий: bez šiški, do petka, puno mrlja"]'::jsonb, 20, 'PUBLISHED', 1);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'frizerski salon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šišanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ošišati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podšišati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šiške', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bojanje kose', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pramenovi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brijačnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naručiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kemijska čistionica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skinuti mrlju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krojač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skratiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'suziti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zamijeniti patent', v_pos);
  v_pos := pg_temp.word(v_lesson, 'postolar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potpetica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'đon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'biti gotov', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potvrdnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'feniranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kozmetički salon', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '64e14ff2-62d5-5afd-9499-9ef93c4c4575', 'fill_in_the_blank', 'Kaput će biti gotov do ___.', 'petka', '["petka", "petku", "petak", "petkom"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c888f8d9-b9cc-5258-9bdf-24f894294959', 'multiple_choice', 'Що означає «brijačnica»?', 'барбершоп, чоловіча перукарня', '["швець", "вивести пляму", "звузити", "барбершоп, чоловіча перукарня"]'::jsonb, 'A2', 2, 'PUBLISHED', 'brijačnica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5ade31a5-25db-56f3-8720-b82d1b5a1056', 'multiple_choice', 'Що означає «kozmetički salon»?', 'косметичний салон', '["косметичний салон", "підрівняти (волосся)", "підошва", "бути готовим"]'::jsonb, 'A2', 3, 'PUBLISHED', 'kozmetički salon', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0bf46863-18ca-5ad6-a44f-42265bc80ff1', 'multiple_choice', 'Що означає «kemijska čistionica»?', 'хімчистка', '["косметичний салон", "бути готовим", "хімчистка", "підстригтися"]'::jsonb, 'A2', 4, 'PUBLISHED', 'kemijska čistionica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '91050ef2-63d4-575f-bbbf-22e4dce6997d', 'multiple_choice', 'Як хорватською «укоротити»?', 'skratiti', '["šišanje", "naručiti se", "đon", "skratiti"]'::jsonb, 'A2', 5, 'PUBLISHED', 'skratiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '79816644-24a9-5649-a10d-dfa911c741c2', 'multiple_choice', 'Як хорватською «підбор»?', 'potpetica', '["potpetica", "ošišati se", "skratiti", "naručiti se"]'::jsonb, 'A2', 6, 'PUBLISHED', 'potpetica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b39d98fc-00d5-5fb8-b070-d354fb153a34', 'type_answer', 'Напишіть хорватською: «підрівняти (волосся)»', 'podšišati', null, 'A2', 7, 'PUBLISHED', 'podšišati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a90894c7-a6b0-56cc-8208-a62085493822', 'type_answer', 'Напишіть хорватською: «стрижка»', 'šišanje', null, 'A2', 8, 'PUBLISHED', 'šišanje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d3f41ee-ccff-52e9-bd1a-6f9833397bef', 'type_answer', 'Напишіть хорватською: «квитанція (на замовлення)»', 'potvrdnica', null, 'A2', 9, 'PUBLISHED', 'potvrdnica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b3ba0470-d36c-5c7e-8ab2-62f972dbb8ae', 'sentence_builder', 'Складіть: «Я записалася до перукарки на п’ятницю.»', 'Naručila sam se kod frizerke za petak.', '["sam", "kod", "petak.", "Naručila", "za", "frizerke", "se"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '22189621-ddd5-51df-a34c-2e7ee7bfd53c', 'sentence_builder', 'Складіть: «Треба вкоротити рукави.»', 'Treba skratiti rukave.', '["skratiti", "Treba", "rukave."]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4b7b6949-2d40-5546-9a7a-1c7e21bf2377', 'listening', 'Прослухайте і складіть фразу', 'Probat ćemo. Kaput će biti gotov do petka.', '["petka.", "ćemo.", "Probat", "biti", "do", "Kaput", "gotov", "će"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '7cd8491a-80e9-53f5-83e1-8dd4e4a9bbeb', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'куртка; від кави; квитанцію', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Вам телефонували з хімчистки.", "script": [{"hr": "Dobar dan, ovdje kemijska čistionica Bijela.", "ua": "Добрий день, це хімчистка «Біла»."}, {"hr": "Vaša jakna je gotova, ali mrlju od kave nismo mogli potpuno skinuti.", "ua": "Ваша куртка готова, але пляму від кави ми не змогли повністю вивести."}, {"hr": "Možete je preuzeti od sutra, od osam do osamnaest sati.", "ua": "Можете забрати її із завтрашнього дня, з восьмої до вісімнадцятої."}, {"hr": "Ne zaboravite potvrdnicu.", "ua": "Не забудьте квитанцію."}], "questions": [{"q_ua": "Що готове?", "options": ["куртка", "пальто", "костюм"], "correct": 0, "answer_turn": 1}, {"q_ua": "Яку пляму не вивели повністю?", "options": ["від вина", "від кави", "від фарби"], "correct": 1, "answer_turn": 1}, {"q_ua": "Що треба взяти?", "options": ["паспорт", "гроші готівкою", "квитанцію"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '7cd8491a-80e9-53f5-83e1-8dd4e4a9bbeb', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '416fb002-20bb-5a4a-a6c0-e5ff0f5f81b6', 'speaking', 'Просто трохи підрівняйте, будь ласка.', 'Samo me malo podšišajte, molim.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b751541b-b4ab-5334-9bed-2c51e2de824e', 'speaking', 'Коли буде готове пальто?', 'Kada će kaput biti gotov?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '943b7813-f441-5ab4-bd5b-e3dd483e99a5', 'write_message', 'Напишіть у перукарню: хочете записатися на стрижку й фарбування в суботу зранку.', 'Dobar dan, htjela bih se naručiti za šišanje i bojanje u subotu ujutro. Imate li slobodan termin?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у перукарню: хочете записатися на стрижку й фарбування в суботу зранку.", "points": [{"ua": "записатися", "keys": [["naruč"], ["termin"]]}, {"ua": "стрижка й фарбування", "keys": [["šišan"], ["bojan"]]}, {"ua": "у суботу зранку", "keys": [["subot"]]}], "hints": ["htjela bih se naručiti", "za šišanje i bojanje", "u subotu ujutro", "imate li slobodan termin?"], "models": ["Dobar dan, htjela bih se naručiti za šišanje i bojanje u subotu ujutro. Imate li slobodan termin?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '943b7813-f441-5ab4-bd5b-e3dd483e99a5', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'e5e9a72d-50b7-53d7-8729-8b3146328778', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Na cipeli se odlijepio đon. Kada će biti gotovo?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи шевцеві, що в мене відклеїлася підошва, і спитай, коли буде готово.", "direction": "ua_hr", "points": [{"ua": "відклеїлася підошва", "keys": [["đon"]]}, {"ua": "коли готово", "keys": [["gotov"], ["kad"]]}], "hints": [], "models": ["Na cipeli se odlijepio đon. Kada će biti gotovo?"], "source_ua": "Скажи шевцеві, що в мене відклеїлася підошва, і спитай, коли буде готово."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'e5e9a72d-50b7-53d7-8729-8b3146328778', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('71a64779-1ad1-5c46-bff1-87afa103e81f', v_lesson, 'У перукарні', 'Kod frizerke', 5371, 'A2', 'shopping', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('8bc7a161-a335-54bc-9b21-32c2895d7c3e', '71a64779-1ad1-5c46-bff1-87afa103e81f', 'Frizerka', 'Dobar dan! Jeste li naručeni?', 'Добрий день! Ви записані?', 1);
  perform pg_temp.turn('884b6f24-6bfb-5c6a-8b8f-17862f6e27a0', '71a64779-1ad1-5c46-bff1-87afa103e81f', 'Darja', 'Jesam, za šišanje u deset. Samo me malo podšišajte.', 'Так, на стрижку о десятій. Просто трохи підрівняйте.', 2);
  perform pg_temp.turn('9a332cc8-4847-50ba-9f13-d6e7782e1f38', '71a64779-1ad1-5c46-bff1-87afa103e81f', 'Frizerka', 'A šiške?', 'А чубчик?', 3);
  perform pg_temp.turn('c2422594-da83-578f-a83d-bcfb15a5ff22', '71a64779-1ad1-5c46-bff1-87afa103e81f', 'Darja', 'Kraće, molim. I htjela bih svijetle pramenove.', 'Коротший, будь ласка. І я хотіла б світле мелірування.', 4);
  perform pg_temp.turn('3f45f2d7-4b1a-5e2f-b7b5-7767675b6e4d', '71a64779-1ad1-5c46-bff1-87afa103e81f', 'Frizerka', 'Bojanje traje dva sata. Može li sljedeći tjedan?', 'Фарбування триває дві години. Можна наступного тижня?', 5);
  perform pg_temp.turn('4093dc7c-7c06-5dc4-b892-5c51ee860173', '71a64779-1ad1-5c46-bff1-87afa103e81f', 'Darja', 'Može. Naručit ću se za utorak.', 'Можна. Я запишуся на вівторок.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0e14e05f-8a1f-5de0-9bf5-a5da8d9b7700', v_lesson, 'Хімчистка й кравець', 'Čistionica i krojač', 5372, 'A2', 'shopping', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('f24befb2-3e5e-533c-ab46-f9b95eeb4df9', '0e14e05f-8a1f-5de0-9bf5-a5da8d9b7700', 'Daša', 'Dobar dan, na kaputu je mrlja od vina. Možete li je skinuti?', 'Добрий день, на пальті пляма від вина. Можете її вивести?', 1);
  perform pg_temp.turn('93765b29-4beb-5d4e-ba27-68ad139d4029', '0e14e05f-8a1f-5de0-9bf5-a5da8d9b7700', 'Radnica', 'Probat ćemo. Kaput će biti gotov do petka.', 'Спробуємо. Пальто буде готове до п’ятниці.', 2);
  perform pg_temp.turn('62cdbba9-72ea-58dd-bf63-c9789f91f4a7', '0e14e05f-8a1f-5de0-9bf5-a5da8d9b7700', 'Daša', 'Odlično. A znate li dobrog krojača? Treba skratiti hlače.', 'Чудово. А ви знаєте доброго кравця? Треба вкоротити штани.', 3);
  perform pg_temp.turn('a1b24f18-2e01-517a-b2d4-f236a146f3a6', '0e14e05f-8a1f-5de0-9bf5-a5da8d9b7700', 'Radnica', 'Krojač je pored postolara, preko puta.', 'Кравець поруч зі шевцем, навпроти.', 4);
  perform pg_temp.turn('2b65c1b3-1718-50c3-9dea-709e6ed3f681', '0e14e05f-8a1f-5de0-9bf5-a5da8d9b7700', 'Daša', 'Hvala. Slomila mi se i potpetica, odnijet ću i čizme.', 'Дякую. У мене ще й підбор зламався, віднесу й чоботи.', 5);
  perform pg_temp.turn('ca600aa6-7fb6-5dd1-aa8c-78e2fba5456a', '0e14e05f-8a1f-5de0-9bf5-a5da8d9b7700', 'Radnica', 'Izvolite potvrdnicu za kaput.', 'Ось квитанція на пальто.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.6 · урок 38: Майстер удома — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6ce8eeae-3862-5515-9d3a-963bbf590733';
  v_lesson constant uuid := 'bf43b6bd-d547-596b-8981-55a4043cf238';
  v_gid constant uuid := 'b7103d09-8e69-53f7-8f17-a90c771fa1a2';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики GEN'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A2.6: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 38: Майстер удома', 'Lekcija 38: Majstor u kući', '["Пояснити майстру проблему й домовитися про ціну й час", "Родовий: bez struje, zbog kvara, umjesto stare brave"]'::jsonb, 20, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'bravar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'serviser', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stolar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'soboslikar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'keramičar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'okrečiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pločice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zamijeniti bravu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predračun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'procjena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'materijal', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izlazak na teren', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iskočio je osigurač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'začepiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kapati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugraditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dijelovi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jamstvo na radove', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hitna intervencija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dogovoriti termin', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d4860f1-6fdd-5448-b272-eb745116fcb0', 'fill_in_the_blank', 'Nemamo struje zbog ___ na bojleru.', 'kvara', '["kvara", "kvaru", "kvar", "kvarom"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '077804c2-c057-50d8-b879-7ee5cadbaa4a', 'multiple_choice', 'Що означає «brava»?', 'замок', '["вибило запобіжник", "маляр (стін)", "замок", "встановити, вмонтувати"]'::jsonb, 'A2', 2, 'PUBLISHED', 'brava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1b36ac92-9071-5aca-950c-0d12757b1b24', 'multiple_choice', 'Що означає «izlazak na teren»?', 'виїзд майстра', '["виїзд майстра", "терміновий виклик", "майстер з ремонту техніки", "попередній рахунок, кошторис"]'::jsonb, 'A2', 3, 'PUBLISHED', 'izlazak na teren', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '224c887f-bce0-5c14-996c-8c831dcd0034', 'multiple_choice', 'Що означає «okrečiti»?', 'побілити, пофарбувати стіни', '["слюсар (замки)", "майстер з ремонту техніки", "побілити, пофарбувати стіни", "матеріал"]'::jsonb, 'A2', 4, 'PUBLISHED', 'okrečiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8cd3c477-7b16-56de-b9ec-e16ca6288439', 'multiple_choice', 'Як хорватською «маляр (стін)»?', 'soboslikar', '["stolar", "soboslikar", "začepiti se", "procjena"]'::jsonb, 'A2', 5, 'PUBLISHED', 'soboslikar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '57bc2188-30a8-5ae3-a808-0ea684f71f58', 'multiple_choice', 'Як хорватською «запчастини»?', 'dijelovi', '["dogovoriti termin", "brava", "bravar", "dijelovi"]'::jsonb, 'A2', 6, 'PUBLISHED', 'dijelovi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fbfce519-1431-5a27-92ad-44755f3904df', 'type_answer', 'Напишіть хорватською: «плиточник»', 'keramičar', null, 'A2', 7, 'PUBLISHED', 'keramičar', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f3a9769-2a65-56ed-90d4-b51d63bcefc2', 'type_answer', 'Напишіть хорватською: «столяр»', 'stolar', null, 'A2', 8, 'PUBLISHED', 'stolar', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '10723ec7-e51a-5fa3-9865-a487dbd26132', 'type_answer', 'Напишіть хорватською: «встановити, вмонтувати»', 'ugraditi', null, 'A2', 9, 'PUBLISHED', 'ugraditi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4cfaf13f-1e59-50c7-a05c-8022193578bd', 'sentence_builder', 'Складіть: «Кран капає всю ніч.»', 'Slavina kapa cijelu noć.', '["kapa", "noć.", "cijelu", "Slavina"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '61a518d0-83e1-5462-89ab-8985387d220b', 'sentence_builder', 'Складіть: «Надішліть мені кошторис перед роботами.»', 'Pošaljite mi predračun prije radova.', '["Pošaljite", "predračun", "radova.", "prije", "mi"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6e3a138a-a4f4-5eee-9601-1e0dc9f1332d', 'listening', 'Прослухайте і складіть фразу', 'Opet iskače zbog perilice.', '["perilice.", "iskače", "zbog", "Opet"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '85ab52df-8384-567c-85ad-caa3b5064a98', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'запчастини; у четвер близько 15:00; 120 євро', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Майстер залишив вам повідомлення.", "script": [{"hr": "Dobar dan, ovdje majstor Kovač.", "ua": "Добрий день, це майстер Ковач."}, {"hr": "Dijelovi za Vašu perilicu stigli su danas.", "ua": "Запчастини для вашої пральної машини надійшли сьогодні."}, {"hr": "Mogu doći u četvrtak poslije podne, oko tri.", "ua": "Я можу прийти в четвер після обіду, близько третьої."}, {"hr": "Popravak s dijelovima bit će sto dvadeset eura.", "ua": "Ремонт із запчастинами коштуватиме сто двадцять євро."}], "questions": [{"q_ua": "Що надійшло?", "options": ["запчастини", "нова пральна машина", "рахунок"], "correct": 0, "answer_turn": 1}, {"q_ua": "Коли прийде майстер?", "options": ["у вівторок зранку", "у четвер близько 15:00", "у п’ятницю"], "correct": 1, "answer_turn": 2}, {"q_ua": "Скільки коштуватиме ремонт?", "options": ["20 євро", "100 євро", "120 євро"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '85ab52df-8384-567c-85ad-caa3b5064a98', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4b53554b-8c82-5e77-9aa5-fcfb5ed1dd9c', 'speaking', 'Засмітився злив на кухні.', 'Začepio se odvod u kuhinji.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ef5be1ce-2c9e-514f-b08f-052773a2f89f', 'speaking', 'Чи можемо домовитися на середу?', 'Možemo li dogovoriti termin za srijedu?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '43598d39-1b4a-5fa6-8878-b55306c76d80', 'write_message', 'Напишіть майстрові: у ванній тріснула плитка і капає кран; спитайте, коли він може прийти і скільки це коштуватиме.', 'Dobar dan, u kupaonici su popucale pločice i slavina kapa. Kada možete doći i koliko će koštati?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть майстрові: у ванній тріснула плитка і капає кран; спитайте, коли він може прийти і скільки це коштуватиме.", "points": [{"ua": "плитка", "keys": [["pločic"]]}, {"ua": "кран капає", "keys": [["kap"], ["slavin"]]}, {"ua": "коли прийти", "keys": [["kad", "doć"], ["termin"]]}, {"ua": "ціна", "keys": [["košt"], ["cijen"], ["procjen"]]}], "hints": ["u kupaonici su popucale pločice", "slavina kapa", "kada možete doći?", "koliko će koštati?"], "models": ["Dobar dan, u kupaonici su popucale pločice i slavina kapa. Kada možete doći i koliko će koštati?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '43598d39-1b4a-5fa6-8878-b55306c76d80', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '8ae6f3d8-b813-56b9-b8c2-c2114c0a3752', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Zaključala se vani i treba zamijeniti bravu još danas.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи майстрові, що я замкнулася ззовні й мені потрібно замінити замок сьогодні.", "direction": "ua_hr", "points": [{"ua": "замкнулася ззовні", "keys": [["vani"], ["zaključa"]]}, {"ua": "замінити замок", "keys": [["brav"]]}, {"ua": "сьогодні", "keys": [["danas"]]}], "hints": [], "models": ["Zaključala se vani i treba zamijeniti bravu još danas."], "source_ua": "Скажи майстрові, що я замкнулася ззовні й мені потрібно замінити замок сьогодні."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '8ae6f3d8-b813-56b9-b8c2-c2114c0a3752', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3b36368a-5bfe-5451-a5a1-b345a714350f', v_lesson, 'Тече кран', 'Kapa slavina', 5381, 'A2', 'housing', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('81590f6a-47f3-58c4-abc7-55ea0a079362', '3b36368a-5bfe-5451-a5a1-b345a714350f', 'Darja', 'Dobar dan, trebam majstora. Slavina kapa, a začepio se i odvod.', 'Добрий день, мені потрібен майстер. Кран капає, а ще засмітився злив.', 1);
  perform pg_temp.turn('6ff5f486-c790-50ee-96bc-3fb2e8a97936', '3b36368a-5bfe-5451-a5a1-b345a714350f', 'Majstor', 'Mogu doći sutra. Izlazak na teren je dvadeset eura.', 'Можу прийти завтра. Виїзд — двадцять євро.', 2);
  perform pg_temp.turn('b0d32f60-6b3d-5bfa-8c2a-1dd8608f3000', '3b36368a-5bfe-5451-a5a1-b345a714350f', 'Darja', 'Kolika je procjena za cijeli posao?', 'Яка орієнтовна вартість усієї роботи?', 3);
  perform pg_temp.turn('e76c79cc-6324-5297-8923-98ef33e880f4', '3b36368a-5bfe-5451-a5a1-b345a714350f', 'Majstor', 'Oko sto eura, ali materijal nije uključen.', 'Близько ста євро, але матеріали не включено.', 4);
  perform pg_temp.turn('290ca892-d450-5028-b9d5-c98893dead6b', '3b36368a-5bfe-5451-a5a1-b345a714350f', 'Darja', 'Možete li mi poslati predračun?', 'Можете надіслати мені кошторис?', 5);
  perform pg_temp.turn('2dd177ba-e20d-5011-91d3-fd50eef47abc', '3b36368a-5bfe-5451-a5a1-b345a714350f', 'Majstor', 'Naravno. Dogovorimo termin za sutra u devet.', 'Звісно. Домовмося на завтра на дев’яту.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('83c1bbe5-d130-5039-bf75-94e1be89f88a', v_lesson, 'Без світла', 'Bez struje', 5382, 'A2', 'housing', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('be4055a8-206b-5c71-845c-a3132cc376e1', '83c1bbe5-d130-5039-bf75-94e1be89f88a', 'Ivan', 'Dašo, nemamo struje u kuhinji!', 'Дашо, у нас на кухні немає світла!', 1);
  perform pg_temp.turn('8a0465d2-f38a-5705-9712-ecac234fd426', '83c1bbe5-d130-5039-bf75-94e1be89f88a', 'Daša', 'Iskočio je osigurač. Probaj ga vratiti.', 'Вибило запобіжник. Спробуй його повернути.', 2);
  perform pg_temp.turn('413a0c69-92fc-5b8b-b756-32aac7935067', '83c1bbe5-d130-5039-bf75-94e1be89f88a', 'Ivan', 'Opet iskače zbog perilice.', 'Знову вибиває через пральну машину.', 3);
  perform pg_temp.turn('812bf5d5-06a3-5d7a-82fe-bc46d58c955b', '83c1bbe5-d130-5039-bf75-94e1be89f88a', 'Daša', 'Onda zovemo servisera. Možda trebaju novi dijelovi.', 'Тоді викликаємо майстра. Може, потрібні нові запчастини.', 4);
  perform pg_temp.turn('800e8b61-1344-5192-a4b0-1e47f5d88ecc', '83c1bbe5-d130-5039-bf75-94e1be89f88a', 'Ivan', 'Nadam se da je još pod jamstvom.', 'Сподіваюся, що вона ще на гарантії.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.6 · урок 39: Нотаріус і засвідчення документів — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6ce8eeae-3862-5515-9d3a-963bbf590733';
  v_lesson constant uuid := '856c691f-4467-561f-a344-377ca275dbba';
  v_gid constant uuid := 'a6dba6b3-0b0a-588c-acd4-7eedced88519';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики PAS'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A2.6: місце 3 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 39: Нотаріус і засвідчення документів', 'Lekcija 39: Javni bilježnik i ovjera dokumenata', '["Засвідчити підпис, копію чи довіреність у нотаріуса", "Розуміти пасив: Potpis se ovjerava…, Punomoć mora biti ovjerena"]'::jsonb, 20, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'bilježnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'javnobilježnički ured', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovjeriti potpis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovjeriti presliku', v_pos);
  v_pos := pg_temp.word(v_lesson, 'punomoć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opunomoćenik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izjava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'suglasnost za putovanje djeteta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugovor o najmu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupoprodajni ugovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'solemnizacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'javnobilježnička pristojba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'original', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preslika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'identificirati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vlastoručno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pečat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vjerodostojan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prevesti i ovjeriti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovjereno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovjera prijevoda', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '71bbf745-0b60-51d5-a46d-15b870eea5cd', 'fill_in_the_blank', 'Preslika ___ ovjerava uz original.', 'se', '["ih", "su", "je", "se"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '08e00a34-65b0-5289-8701-2b858f000f87', 'multiple_choice', 'Що означає «opunomoćenik»?', 'довірена особа', '["копія", "довірена особа", "договір оренди", "нотаріус (розм.)"]'::jsonb, 'A2', 2, 'PUBLISHED', 'opunomoćenik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0590d24c-589d-576d-8a1e-7afa9c65d7e4', 'multiple_choice', 'Що означає «izjava»?', 'заява, декларація (письмова)', '["засвідчено", "нотаріальний збір", "оригінал", "заява, декларація (письмова)"]'::jsonb, 'A2', 3, 'PUBLISHED', 'izjava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '99ba2f57-1d88-50bd-9fe3-5b737dae59f7', 'multiple_choice', 'Що означає «preslika»?', 'копія', '["засвідчити копію", "копія", "достовірний, автентичний", "довірена особа"]'::jsonb, 'A2', 4, 'PUBLISHED', 'preslika', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b640ba78-e67e-534a-bc4a-e2b98ae42c0d', 'multiple_choice', 'Як хорватською «власноруч»?', 'vlastoručno', '["punomoć", "ovjereno", "vlastoručno", "ugovor o najmu"]'::jsonb, 'A2', 5, 'PUBLISHED', 'vlastoručno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ac8df9f7-7e6e-511e-8c6b-bea0480ae11b', 'multiple_choice', 'Як хорватською «оригінал»?', 'original', '["ovjeriti presliku", "original", "javnobilježnički ured", "javnobilježnička pristojba"]'::jsonb, 'A2', 6, 'PUBLISHED', 'original', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f390d9b-3d3f-56c6-b095-b0f78e6b71bb', 'type_answer', 'Напишіть хорватською: «печатка»', 'pečat', null, 'A2', 7, 'PUBLISHED', 'pečat', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0ece075b-df56-5809-8916-c19d688ef0f6', 'type_answer', 'Напишіть хорватською: «засвідчено»', 'ovjereno', null, 'A2', 8, 'PUBLISHED', 'ovjereno', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '58fcb011-c341-53b1-bb02-b482f961b4d7', 'type_answer', 'Напишіть хорватською: «довіреність»', 'punomoć', null, 'A2', 9, 'PUBLISHED', 'punomoć', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b0e7149d-c47a-5ec9-9cba-ea3fbf5fe202', 'sentence_builder', 'Складіть: «Підпис ви маєте поставити особисто.»', 'Potpis morate dati osobno.', '["dati", "Potpis", "morate", "osobno."]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '78c8fbd5-ac31-5715-a962-a65381bfff65', 'sentence_builder', 'Складіть: «Принесіть оригінал і копію.»', 'Donesite original i presliku.', '["Donesite", "presliku.", "original", "i"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '87792a2f-3e16-5d40-86ba-fe52c444fbf2', 'listening', 'Прослухайте і складіть фразу', 'Možete, ako imate original.', '["ako", "imate", "original.", "Možete,"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'f5d05891-07c8-5370-ba6c-fdc3020e8993', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'договір оренди; з власником квартири; карткою або готівкою', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Вам телефонували з нотаріальної контори.", "script": [{"hr": "Dobar dan, zovem iz ureda javne bilježnice Marić.", "ua": "Добрий день, телефоную з контори нотаріуса Маріч."}, {"hr": "Vaš ugovor o najmu je spreman za potpis.", "ua": "Ваш договір оренди готовий до підпису."}, {"hr": "Dođite u petak u jedanaest, zajedno s vlasnikom stana.", "ua": "Приходьте в п’ятницю об одинадцятій разом з власником квартири."}, {"hr": "Ponesite osobne dokumente, a pristojba se plaća karticom ili gotovinom.", "ua": "Візьміть документи, що посвідчують особу, а збір можна сплатити карткою або готівкою."}], "questions": [{"q_ua": "Що готове до підпису?", "options": ["договір оренди", "довіреність", "копія диплома"], "correct": 0, "answer_turn": 1}, {"q_ua": "З ким треба прийти?", "options": ["з перекладачем", "з власником квартири", "із сестрою"], "correct": 1, "answer_turn": 2}, {"q_ua": "Як можна сплатити збір?", "options": ["лише готівкою", "лише переказом", "карткою або готівкою"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'f5d05891-07c8-5370-ba6c-fdc3020e8993', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2df38314-75ec-53b1-936f-81d17961dd4a', 'speaking', 'Мені потрібна довіреність на сестру.', 'Trebam punomoć za sestru.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '22c72df2-09f7-546f-b83a-b5704df7101e', 'speaking', 'Чи можете засвідчити мій підпис?', 'Možete li ovjeriti moj potpis?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '0bdbe568-4014-5a16-9230-d735c2fb1c00', 'write_message', 'Напишіть у нотаріальну контору: хочете засвідчити копію диплома й переклад свідоцтва про народження; спитайте вільний час.', 'Poštovani, htjela bih ovjeriti presliku diplome i prijevod rodnog lista. Imate li slobodan termin ovaj tjedan?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у нотаріальну контору: хочете засвідчити копію диплома й переклад свідоцтва про народження; спитайте вільний час.", "points": [{"ua": "засвідчити копію диплома", "keys": [["diplom"]]}, {"ua": "свідоцтво про народження", "keys": [["rodn"]]}, {"ua": "вільний час", "keys": [["termin"], ["kad"]]}], "hints": ["htjela bih ovjeriti presliku diplome", "prijevod rodnog lista", "imate li slobodan termin?"], "models": ["Poštovani, htjela bih ovjeriti presliku diplome i prijevod rodnog lista. Imate li slobodan termin ovaj tjedan?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '0bdbe568-4014-5a16-9230-d735c2fb1c00', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '899842bf-27c6-5771-94dd-775279483d7b', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Treba li suglasnost oca da dijete putuje s bakom u Ukrajinu?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай нотаріуса, чи потрібна згода батька, щоб дитина поїхала з бабусею в Україну.", "direction": "ua_hr", "points": [{"ua": "згода", "keys": [["suglasnost"]]}, {"ua": "дитина поїде з бабусею", "keys": [["bak"]]}, {"ua": "в Україну", "keys": [["Ukrajin"]]}], "hints": [], "models": ["Treba li suglasnost oca da dijete putuje s bakom u Ukrajinu?"], "source_ua": "Спитай нотаріуса, чи потрібна згода батька, щоб дитина поїхала з бабусею в Україну."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '899842bf-27c6-5771-94dd-775279483d7b', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('73f110cb-ceae-53d9-9d05-a5d70b6ce710', v_lesson, 'Довіреність', 'Punomoć', 5391, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('b5932680-5de0-517b-bf81-ab1af1a7a780', '73f110cb-ceae-53d9-9d05-a5d70b6ce710', 'Darja', 'Dobar dan, trebam punomoć za sestru. Ona će umjesto mene ići u banku.', 'Добрий день, мені потрібна довіреність на сестру. Вона ходитиме в банк замість мене.', 1);
  perform pg_temp.turn('311844f1-7a38-5d9b-9193-8d2f3cfb9486', '73f110cb-ceae-53d9-9d05-a5d70b6ce710', 'Bilježnica', 'Je li sestra ovdje?', 'Сестра тут?', 2);
  perform pg_temp.turn('e17e4f35-64cd-5a0f-ab28-8814ae6543de', '73f110cb-ceae-53d9-9d05-a5d70b6ce710', 'Darja', 'Nije, ona je u Ukrajini. Treba li i ona doći?', 'Ні, вона в Україні. Їй теж треба прийти?', 3);
  perform pg_temp.turn('d1a062f1-2e58-5d15-a0fa-db66a57604b8', '73f110cb-ceae-53d9-9d05-a5d70b6ce710', 'Bilježnica', 'Ne treba. Vi potpisujete osobno, a ja ovjeravam potpis.', 'Не треба. Ви підписуєте особисто, а я засвідчую підпис.', 4);
  perform pg_temp.turn('b0ee77d7-e2f6-56a3-8980-54bc54d5a0f9', '73f110cb-ceae-53d9-9d05-a5d70b6ce710', 'Darja', 'Što trebam donijeti?', 'Що мені треба принести?', 5);
  perform pg_temp.turn('97c82470-6bce-5704-8f62-f1cb607c8ffd', '73f110cb-ceae-53d9-9d05-a5d70b6ce710', 'Bilježnica', 'Putovnicu i sestrine podatke. Punomoć se može napisati i na engleskom.', 'Паспорт і дані сестри. Довіреність можна написати й англійською.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8ee39140-d78a-5371-ae97-9bf142da507c', v_lesson, 'Копія диплома', 'Preslika diplome', 5392, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('3ef6e0fa-6b67-5ae9-93b5-0de8e807ebd7', '8ee39140-d78a-5371-ae97-9bf142da507c', 'Ivan', 'Mogu li ovdje ovjeriti presliku diplome?', 'Чи можу я тут засвідчити копію диплома?', 1);
  perform pg_temp.turn('db987d4a-5aa8-59b6-811a-22c95c8fdce5', '8ee39140-d78a-5371-ae97-9bf142da507c', 'Bilježnik', 'Možete, ako imate original.', 'Можете, якщо маєте оригінал.', 2);
  perform pg_temp.turn('7b6ac031-2a73-51a2-a140-8c23af6cccd1', '8ee39140-d78a-5371-ae97-9bf142da507c', 'Ivan', 'Imam. A koliko košta?', 'Маю. А скільки коштує?', 3);
  perform pg_temp.turn('961bd00b-dc08-55a0-a682-56adf3719ba6', '8ee39140-d78a-5371-ae97-9bf142da507c', 'Bilježnik', 'Javnobilježnička pristojba je propisana, ovisi o broju stranica.', 'Нотаріальний збір установлений, залежить від кількості сторінок.', 4);
  perform pg_temp.turn('3f97a4f7-f8f6-59d9-befa-20beff275d0d', '8ee39140-d78a-5371-ae97-9bf142da507c', 'Ivan', 'Dobro. Hoće li biti pečat?', 'Добре. Чи буде печатка?', 5);
  perform pg_temp.turn('46cc9bfe-be3a-5aa6-b38e-eb32c91c5775', '8ee39140-d78a-5371-ae97-9bf142da507c', 'Bilježnik', 'Hoće. Na kraju piše „ovjereno“, s pečatom i potpisom.', 'Буде. Наприкінці написано «засвідчено», з печаткою й підписом.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.6 · урок 40: Податкова й OIB — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6ce8eeae-3862-5515-9d3a-963bbf590733';
  v_lesson constant uuid := '5f9af92b-06e1-5179-81a3-19625a5b8273';
  v_gid constant uuid := 'a6dba6b3-0b0a-588c-acd4-7eedced88519';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики PAS'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A2.6: місце 4 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 40: Податкова й OIB', 'Lekcija 40: Porezna uprava i OIB', '["Отримати потрібну довідку в податковій, розібратися з OIB", "Розуміти пасив: Prijava se predaje…, Porez se plaća…"]'::jsonb, 20, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'Porezna uprava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispostava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osobni identifikacijski broj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potvrda o OIB-u', v_pos);
  v_pos := pg_temp.word(v_lesson, 'porezni obveznik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'e-Porezna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potvrda o dohotku', v_pos);
  v_pos := pg_temp.word(v_lesson, 'porezni dug', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potvrda o nepostojanju duga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'porez na nekretnine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rješenje o porezu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uplatiti porez', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poziv na broj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kamata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šalter', v_pos);
  v_pos := pg_temp.word(v_lesson, 'broj u redu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'elektronički', v_pos);
  v_pos := pg_temp.word(v_lesson, 'NIAS', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vjerodajnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovlaštenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predati prijavu', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e7ddebc3-f7f4-5d14-8274-d10587566ffc', 'fill_in_the_blank', 'Porez ___ plaća u roku od petnaest dana.', 'se', '["si", "se", "su", "je"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c118c5ce-5d26-542c-a85d-d04c686120c0', 'multiple_choice', 'Що означає «uplatiti porez»?', 'сплатити податок', '["призначення платежу (номер)", "віконце (обслуговування)", "податковий борг", "сплатити податок"]'::jsonb, 'A2', 2, 'PUBLISHED', 'uplatiti porez', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0bcea0c9-463e-59a1-80a4-dde6f0ebef48', 'multiple_choice', 'Що означає «potvrda o nepostojanju duga»?', 'довідка про відсутність боргу', '["особистий ідентифікаційний номер (OIB)", "довідка про відсутність боргу", "електронно", "податкове повідомлення-рішення"]'::jsonb, 'A2', 3, 'PUBLISHED', 'potvrda o nepostojanju duga', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e46d8401-da89-5374-b293-8af0f702b8c4', 'multiple_choice', 'Що означає «potvrda o dohotku»?', 'довідка про доходи', '["податок на нерухомість", "е-Порезна (онлайн-кабінет податкової)", "довідка про доходи", "відсоток, пеня"]'::jsonb, 'A2', 4, 'PUBLISHED', 'potvrda o dohotku', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4e91fb11-9613-5f0d-a072-5717a2d6a273', 'multiple_choice', 'Як хорватською «НІАС (система входу в е-сервіси)»?', 'NIAS', '["šalter", "broj u redu", "porez na nekretnine", "NIAS"]'::jsonb, 'A2', 5, 'PUBLISHED', 'NIAS', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3c731225-105c-5c94-837f-9fd1cbdce289', 'multiple_choice', 'Як хорватською «повноваження, дозвіл»?', 'ovlaštenje', '["porezni dug", "osobni identifikacijski broj", "poziv na broj", "ovlaštenje"]'::jsonb, 'A2', 6, 'PUBLISHED', 'ovlaštenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f3af7b16-39ee-5eb8-bdc9-df1fdf4aa195', 'type_answer', 'Напишіть хорватською: «електронно»', 'elektronički', null, 'A2', 7, 'PUBLISHED', 'elektronički', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '06ba569b-543d-5edf-8158-eda2a13f87fe', 'type_answer', 'Напишіть хорватською: «е-Порезна (онлайн-кабінет податкової)»', 'e-Porezna', null, 'A2', 8, 'PUBLISHED', 'e-Porezna', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '81bb3444-b5b7-5030-8070-f9fe2bcf6c1b', 'type_answer', 'Напишіть хорватською: «віконце (обслуговування)»', 'šalter', null, 'A2', 9, 'PUBLISHED', 'šalter', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ab14c9cc-459c-550b-b157-a979a6d6456a', 'sentence_builder', 'Складіть: «Візьміть номер у черзі на вході.»', 'Uzmite broj u redu na ulazu.', '["redu", "na", "ulazu.", "Uzmite", "broj", "u"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '98f6195d-2da9-5d1a-84cf-cd328479a84a', 'sentence_builder', 'Складіть: «Декларацію подають до кінця лютого.»', 'Prijava se predaje do kraja veljače.', '["kraja", "Prijava", "veljače.", "predaje", "do", "se"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e950ba9b-5149-520f-b832-9915733589e5', 'listening', 'Прослухайте і складіть фразу', 'U roku od petnaest dana. Na uplatnici je poziv na broj.', '["je", "roku", "Na", "dana.", "na", "poziv", "petnaest", "uplatnici", "od", "broj.", "U"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'e8780da9-bb90-596d-b6aa-ac6efc44e2e5', 'listening_dialogue', 'Прослухайте оголошення', 'до п’ятого; через е-Порезну; до 15:00', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Оголошення в залі податкової. Послухайте.", "script": [{"hr": "Poštovani, broj sto dvadeset tri na šalter broj pet.", "ua": "Шановні, номер сто двадцять три — до віконця номер п’ять."}, {"hr": "Potvrde o dohotku izdaju se i elektronički, preko e-Porezne.", "ua": "Довідки про доходи видають і електронно, через е-Порезну."}, {"hr": "Ispostava danas radi do petnaest sati.", "ua": "Відділення сьогодні працює до п’ятнадцятої."}], "questions": [{"q_ua": "До якого віконця номер 123?", "options": ["до п’ятого", "до третього", "до першого"], "correct": 0, "answer_turn": 0}, {"q_ua": "Як ще можна отримати довідку?", "options": ["поштою", "через е-Порезну", "у банку"], "correct": 1, "answer_turn": 1}, {"q_ua": "До котрої працює відділення сьогодні?", "options": ["до 18:00", "до 13:00", "до 15:00"], "correct": 2, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'e8780da9-bb90-596d-b6aa-ac6efc44e2e5', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3e00709f-24e0-5c1f-b899-3524e242e608', 'speaking', 'Мені потрібна довідка про доходи.', 'Trebam potvrdu o dohotku.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7b8df5e8-a0bf-5aae-a873-bbab3d670ff9', 'speaking', 'Чи можна отримати довідку електронно?', 'Može li se potvrda dobiti elektronički?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'a6d107a3-bc89-52f6-a43b-882c85b4628f', 'write_message', 'Напишіть у податкову: вам потрібна довідка про доходи за минулий рік для оренди квартири; спитайте, чи можна отримати її e-mailом.', 'Poštovani, trebam potvrdu o dohotku za prošlu godinu za najam stana. Mogu li je dobiti e-mailom?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у податкову: вам потрібна довідка про доходи за минулий рік для оренди квартири; спитайте, чи можна отримати її e-mailом.", "points": [{"ua": "довідка про доходи", "keys": [["dohot"]]}, {"ua": "за минулий рік", "keys": [["prošl"]]}, {"ua": "e-mailом", "keys": [["e-mail"], ["elektronič"]]}], "hints": ["trebam potvrdu o dohotku", "za prošlu godinu", "mogu li je dobiti e-mailom?"], "models": ["Poštovani, trebam potvrdu o dohotku za prošlu godinu za najam stana. Mogu li je dobiti e-mailom?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'a6d107a3-bc89-52f6-a43b-882c85b4628f', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '1a44f4b3-4b2a-5a6e-b32a-3a26a68bb069', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Može li njegov knjigovođa dobiti ovlaštenje za njegovu e-Poreznu?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай, чи може мій бухгалтер отримати доступ до моєї е-Порезної.", "direction": "ua_hr", "points": [{"ua": "бухгалтер", "keys": [["knjigovo"]]}, {"ua": "доступ", "keys": [["ovlašten"], ["pristup"]]}, {"ua": "е-Порезна", "keys": [["porezn"]]}], "hints": [], "models": ["Može li njegov knjigovođa dobiti ovlaštenje za njegovu e-Poreznu?"], "source_ua": "Спитай, чи може мій бухгалтер отримати доступ до моєї е-Порезної."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '1a44f4b3-4b2a-5a6e-b32a-3a26a68bb069', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('99709354-c555-5ee1-bddf-aa9fb65fadae', v_lesson, 'У податковій', 'U Poreznoj upravi', 5401, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('705542ea-94f2-5011-ba59-df3d37cbb01f', '99709354-c555-5ee1-bddf-aa9fb65fadae', 'Darja', 'Dobar dan, trebam potvrdu o dohotku za najam stana.', 'Добрий день, мені потрібна довідка про доходи для оренди квартири.', 1);
  perform pg_temp.turn('92b44982-f5a0-5da3-923f-4cfece9d712e', '99709354-c555-5ee1-bddf-aa9fb65fadae', 'Službenik', 'Vaš OIB, molim.', 'Ваш OIB, будь ласка.', 2);
  perform pg_temp.turn('604a6595-4b39-5ba9-9839-793499228fb4', '99709354-c555-5ee1-bddf-aa9fb65fadae', 'Darja', 'Izvolite. Mogu li dobiti i potvrdu o nepostojanju duga?', 'Прошу. Чи можу я отримати ще й довідку про відсутність боргу?', 3);
  perform pg_temp.turn('4209a740-3c92-5ace-9aff-a634ded593a6', '99709354-c555-5ee1-bddf-aa9fb65fadae', 'Službenik', 'Možete. Obje potvrde se mogu dobiti i elektronički, preko e-Porezne.', 'Можете. Обидві довідки можна отримати й електронно, через е-Порезну.', 4);
  perform pg_temp.turn('ff70ec07-5ef6-5afd-83d9-b9dc8207722a', '99709354-c555-5ee1-bddf-aa9fb65fadae', 'Darja', 'Kako se prijavljujem?', 'Як мені увійти?', 5);
  perform pg_temp.turn('affde75d-79ec-5644-b2ab-f31af01dbb74', '99709354-c555-5ee1-bddf-aa9fb65fadae', 'Službenik', 'Preko NIAS-a, trebate vjerodajnicu, na primjer iz banke.', 'Через НІАС, вам потрібні облікові дані, наприклад, з банку.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9b75b305-9e89-51eb-bf45-af802baee4ac', v_lesson, 'Податок на нерухомість', 'Porez na nekretnine', 5402, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('d97db197-6f78-517a-9e57-71ad1331c702', '9b75b305-9e89-51eb-bf45-af802baee4ac', 'Ivan', 'Dašo, stiglo je rješenje o porezu na nekretnine.', 'Дашо, надійшло податкове рішення про податок на нерухомість.', 1);
  perform pg_temp.turn('521c3e6e-8697-589e-8cfb-76fc6cb9f3a2', '9b75b305-9e89-51eb-bf45-af802baee4ac', 'Daša', 'Do kada se porez plaća?', 'До коли треба сплатити податок?', 2);
  perform pg_temp.turn('9c791869-66c5-53cd-a0a9-d734ab34c364', '9b75b305-9e89-51eb-bf45-af802baee4ac', 'Ivan', 'U roku od petnaest dana. Na uplatnici je poziv na broj.', 'Протягом п’ятнадцяти днів. На квитанції є призначення платежу.', 3);
  perform pg_temp.turn('c9b71f75-e620-5d23-9816-d0955eb2d6a9', '9b75b305-9e89-51eb-bf45-af802baee4ac', 'Daša', 'Platimo ga odmah, inače se plaćaju kamate.', 'Заплатімо одразу, інакше нараховують пеню.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.6 · урок 41: Страховка: здоров’я, авто, дім — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6ce8eeae-3862-5515-9d3a-963bbf590733';
  v_lesson constant uuid := 'f3cfca9e-efc9-5b58-8fe9-772fa631e0c2';
  v_gid constant uuid := 'b7103d09-8e69-53f7-8f17-a90c771fa1a2';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики GEN'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A2.6: місце 5 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 41: Страховка: здоров’я, авто, дім', 'Lekcija 41: Osiguranje: zdravlje, auto i dom', '["Розпитати про поліс і заявити страховий випадок", "Родовий: bez osiguranja, tijekom godine, osim štete od poplave"]'::jsonb, 20, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'polica osiguranja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osiguravajuće društvo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'premija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obvezno osiguranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osnovno zdravstveno osiguranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'HZZO', v_pos);
  v_pos := pg_temp.word(v_lesson, 'participacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osiguranje kućanstva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pokrivati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osigurani slučaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijava štete', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijaviti štetu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'procjenitelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'isplata štete', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poplava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bonus', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obnoviti policu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'istek', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uvjeti osiguranja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osiguranje od odgovornosti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osiguranik', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2aa73aa2-f655-5acd-85f3-8004c71494b4', 'fill_in_the_blank', 'Procjenitelj će doći tijekom ___.', 'tjedna', '["tjedan", "tjedna", "tjednu", "tjednom"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9732acce-76f0-531e-a271-590cf746cffd', 'multiple_choice', 'Що означає «prijava štete»?', 'заява про збиток', '["доплата пацієнта (за медпослугу)", "заява про збиток", "бонус (знижка за безаварійну їзду)", "закінчення (строку)"]'::jsonb, 'A2', 2, 'PUBLISHED', 'prijava štete', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5b2595af-ddbf-58d9-856d-13af15f9e9df', 'multiple_choice', 'Що означає «osiguranje od odgovornosti»?', 'страхування відповідальності', '["затоплення, повінь", "HZZO (Хорватський фонд медичного страхування)", "оцінювач (страхової)", "страхування відповідальності"]'::jsonb, 'A2', 3, 'PUBLISHED', 'osiguranje od odgovornosti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0d355476-8861-576b-9a7c-b4b768619f11', 'multiple_choice', 'Що означає «osnovno zdravstveno osiguranje»?', 'базове медичне страхування', '["затоплення, повінь", "продовжити поліс", "страховий внесок", "базове медичне страхування"]'::jsonb, 'A2', 4, 'PUBLISHED', 'osnovno zdravstveno osiguranje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9336bcd8-6bb6-584f-b3fe-c3955c5db139', 'multiple_choice', 'Як хорватською «бонус (знижка за безаварійну їзду)»?', 'bonus', '["bonus", "pokrivati", "polica osiguranja", "osiguranik"]'::jsonb, 'A2', 5, 'PUBLISHED', 'bonus', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'feea880d-169e-56cb-852d-117e3746e403', 'multiple_choice', 'Як хорватською «HZZO (Хорватський фонд медичного страхування)»?', 'HZZO', '["bonus", "HZZO", "osiguranik", "pokrivati"]'::jsonb, 'A2', 6, 'PUBLISHED', 'HZZO', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6762c4eb-5a45-59cc-8acd-844411f3ee7a', 'type_answer', 'Напишіть хорватською: «оцінювач (страхової)»', 'procjenitelj', null, 'A2', 7, 'PUBLISHED', 'procjenitelj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '36ae9ba8-3908-5de8-a204-165676e5cbe5', 'type_answer', 'Напишіть хорватською: «покривати (про страховку)»', 'pokrivati', null, 'A2', 8, 'PUBLISHED', 'pokrivati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '56edc952-43fc-5324-b1c9-3b6f8a9bf1e5', 'type_answer', 'Напишіть хорватською: «затоплення, повінь»', 'poplava', null, 'A2', 9, 'PUBLISHED', 'poplava', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a659a3c9-b55b-5d06-b419-f21dea3cfc6c', 'sentence_builder', 'Складіть: «Поліс не покриває збиток від землетрусу.»', 'Polica ne pokriva štetu od potresa.', '["štetu", "od", "pokriva", "ne", "Polica", "potresa."]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '50c779af-c584-5d03-8981-68d11dbc57b2', 'sentence_builder', 'Складіть: «Поліс треба продовжити до закінчення строку.»', 'Policu treba obnoviti prije isteka.', '["prije", "isteka.", "Policu", "obnoviti", "treba"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b72b54b2-2928-59e5-b90c-8d68e8792585', 'listening', 'Прослухайте і складіть фразу', 'Imamo, broj police je u e-mailu.', '["je", "broj", "e-mailu.", "police", "u", "Imamo,"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '425f4bef-8b0f-599d-8d64-10f0a3c7d2aa', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'ванну; 300 євро; до кінця місяця', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Вам телефонували зі страхової компанії.", "script": [{"hr": "Dobar dan, zovem iz osiguranja Adria vezano uz Vašu prijavu štete.", "ua": "Добрий день, телефоную зі страхової «Адрія» щодо вашої заяви про збиток."}, {"hr": "Procjenitelj je pregledao kupaonicu.", "ua": "Оцінювач оглянув ванну."}, {"hr": "Isplata štete bit će tristo eura, na Vaš račun do kraja mjeseca.", "ua": "Страхова виплата становитиме триста євро, на ваш рахунок до кінця місяця."}], "questions": [{"q_ua": "Що оглянув оцінювач?", "options": ["ванну", "авто", "кухню"], "correct": 0, "answer_turn": 1}, {"q_ua": "Яка сума виплати?", "options": ["200 євро", "300 євро", "30 євро"], "correct": 1, "answer_turn": 2}, {"q_ua": "Коли надійдуть гроші?", "options": ["завтра", "за тиждень", "до кінця місяця"], "correct": 2, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '425f4bef-8b0f-599d-8d64-10f0a3c7d2aa', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3cfa747f-8e6c-52a1-a22c-959d7f7d4d0a', 'speaking', 'Я хочу заявити про збиток.', 'Želim prijaviti štetu.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5d943bbc-f766-5060-b55f-e0618e55f40c', 'speaking', 'Що покриває поліс?', 'Što pokriva polica?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '7b22dadb-6479-5d56-88a9-bf5bba1639d1', 'write_message', 'Напишіть у страхову: учора сусід затопив вашу кухню, ви хочете заявити про збиток і надсилаєте фото.', 'Poštovani, jučer nam je susjed poplavio kuhinju. Želim prijaviti štetu. U privitku šaljem fotografije.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у страхову: учора сусід затопив вашу кухню, ви хочете заявити про збиток і надсилаєте фото.", "points": [{"ua": "сусід затопив", "keys": [["poplav"]]}, {"ua": "заявити про збиток", "keys": [["štet"]]}, {"ua": "надсилаєте фото", "keys": [["fotografi"], ["slik"]]}], "hints": ["jučer nam je susjed poplavio kuhinju", "želim prijaviti štetu", "u privitku šaljem fotografije"], "models": ["Poštovani, jučer nam je susjed poplavio kuhinju. Želim prijaviti štetu. U privitku šaljem fotografije."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '7b22dadb-6479-5d56-88a9-bf5bba1639d1', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'af9dd114-00d2-5923-a2c4-60bb449b25f0', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Pokriva li polica krađu bicikla iz podruma?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай агентку, чи покриває поліс крадіжку велосипеда з підвалу.", "direction": "ua_hr", "points": [{"ua": "покриває", "keys": [["pokriva"]]}, {"ua": "крадіжка", "keys": [["krađ"]]}, {"ua": "велосипед", "keys": [["bicikl"]]}], "hints": [], "models": ["Pokriva li polica krađu bicikla iz podruma?"], "source_ua": "Спитай агентку, чи покриває поліс крадіжку велосипеда з підвалу."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'af9dd114-00d2-5923-a2c4-60bb449b25f0', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7e25e3e7-161a-5d8b-8b2b-65e08ddeacdc', v_lesson, 'Страхування квартири', 'Osiguranje stana', 5411, 'A2', 'bank', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('2ee1dcab-0759-5fe8-9460-c5b6669e76c0', '7e25e3e7-161a-5d8b-8b2b-65e08ddeacdc', 'Darja', 'Dobar dan, zanima me osiguranje kućanstva.', 'Добрий день, мене цікавить страхування домашнього майна.', 1);
  perform pg_temp.turn('a51f9212-cf7d-5a46-90ce-3d3909bc5fe2', '7e25e3e7-161a-5d8b-8b2b-65e08ddeacdc', 'Agentica', 'Polica pokriva požar, poplavu i krađu. Godišnja premija je osamdeset eura.', 'Поліс покриває пожежу, затоплення й крадіжку. Річний внесок — вісімдесят євро.', 2);
  perform pg_temp.turn('9869d8b4-4d5a-5a64-a43e-21d9ee7ed628', '7e25e3e7-161a-5d8b-8b2b-65e08ddeacdc', 'Darja', 'A štetu od potresa?', 'А збиток від землетрусу?', 3);
  perform pg_temp.turn('4e12fe3b-73bc-583d-91e4-060b5e0b5253', '7e25e3e7-161a-5d8b-8b2b-65e08ddeacdc', 'Agentica', 'Potres nije uključen, osim uz dodatnu premiju.', 'Землетрус не включено, хіба що з додатковим внеском.', 4);
  perform pg_temp.turn('26b8f981-8ace-54a5-ac98-de735924885c', '7e25e3e7-161a-5d8b-8b2b-65e08ddeacdc', 'Darja', 'Mogu li pročitati uvjete osiguranja?', 'Можу прочитати умови страхування?', 5);
  perform pg_temp.turn('a6d8dcf1-0d9c-5938-aaf4-620e33b546de', '7e25e3e7-161a-5d8b-8b2b-65e08ddeacdc', 'Agentica', 'Naravno, izvolite. Policu ćete dobiti e-mailom.', 'Звісно, прошу. Поліс ви отримаєте e-mailом.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2fb6ce2d-1734-5a31-994e-3b96d36c0522', v_lesson, 'Затоплення', 'Poplava', 5412, 'A2', 'bank', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('fa510f25-6ae8-5268-a287-9b341bc1a2a6', '2fb6ce2d-1734-5a31-994e-3b96d36c0522', 'Ivan', 'Dobar dan, želim prijaviti štetu. Susjed nam je poplavio kupaonicu.', 'Добрий день, я хочу заявити про збиток. Сусід затопив нам ванну.', 1);
  perform pg_temp.turn('048e2174-ed61-578c-afea-72659ad43b61', '2fb6ce2d-1734-5a31-994e-3b96d36c0522', 'Službenica', 'Imate li osiguranje kućanstva?', 'У вас є страхування домашнього майна?', 2);
  perform pg_temp.turn('da67dd14-dd3a-5dbb-af73-206fdb20559c', '2fb6ce2d-1734-5a31-994e-3b96d36c0522', 'Ivan', 'Imamo, broj police je u e-mailu.', 'Є, номер поліса в листі.', 3);
  perform pg_temp.turn('58864de9-a231-504b-83ac-73c9582eafaa', '2fb6ce2d-1734-5a31-994e-3b96d36c0522', 'Službenica', 'Pošaljite fotografije. Procjenitelj će doći tijekom tjedna.', 'Надішліть фотографії. Оцінювач прийде протягом тижня.', 4);
  perform pg_temp.turn('b777e5b1-691b-5ef4-b94c-fbfca4867553', '2fb6ce2d-1734-5a31-994e-3b96d36c0522', 'Ivan', 'Koliko traje isplata štete?', 'Скільки триває страхова виплата?', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.6 · урок 42: Пишемо заяву до установи — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6ce8eeae-3862-5515-9d3a-963bbf590733';
  v_lesson constant uuid := '0b5f1880-b274-51c1-9d55-32a9873040a2';
  v_gid constant uuid := 'a6dba6b3-0b0a-588c-acd4-7eedced88519';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики PAS'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A2.6: місце 6 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 42: Пишемо заяву до установи', 'Lekcija 42: Pišemo zahtjev ustanovi', '["Написати офіційну заяву: адресат, тема, прохання, додатки", "Офіційні формули з пасивом: Zahtjev se podnosi…, Prilaže se…"]'::jsonb, 20, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'molba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podnositelj zahtjeva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naslovljeno na', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predmet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovim putem', v_pos);
  v_pos := pg_temp.word(v_lesson, 'molim izdavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obrazloženje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u prilogu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pisarnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'urudžbeni broj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'klasa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žalba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pravo na žalbu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zakonski rok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nadležan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povratnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'službena osoba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispuniti obrazac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tiskana slova', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dopuna zahtjeva', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a9251824-b54c-5f8b-9ce3-7a25168eee61', 'fill_in_the_blank', 'Zahtjev ___ predaje u pisarnici.', 'se', '["je", "ga", "se", "su"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6667164f-3092-5bbc-b670-9b81988b47f3', 'multiple_choice', 'Що означає «urudžbeni broj»?', 'вхідний номер (реєстраційний)', '["доповнення заяви", "скарга, оскарження", "адресовано (кому)", "вхідний номер (реєстраційний)"]'::jsonb, 'A2', 2, 'PUBLISHED', 'urudžbeni broj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd0ec1876-2f59-5161-8331-5b2c339b5748', 'multiple_choice', 'Що означає «molba»?', 'прохання, заява (офіційна)', '["право на оскарження", "прохання, заява (офіційна)", "заповнити бланк", "тема (офіційного листа)"]'::jsonb, 'A2', 3, 'PUBLISHED', 'molba', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cd7cbda8-8a9c-5a12-8b48-197790a38790', 'multiple_choice', 'Що означає «zakonski rok»?', 'установлений законом строк', '["посадова особа", "канцелярія (приймання документів)", "установлений законом строк", "адресовано (кому)"]'::jsonb, 'A2', 4, 'PUBLISHED', 'zakonski rok', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e74da282-2f28-5464-ad4a-c54581c81b8e', 'multiple_choice', 'Як хорватською «прошу видати»?', 'molim izdavanje', '["službena osoba", "molim izdavanje", "urudžbeni broj", "molba"]'::jsonb, 'A2', 5, 'PUBLISHED', 'molim izdavanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae1f241b-3395-590f-991b-eaec29f9612a', 'multiple_choice', 'Як хорватською «компетентний, відповідальний (орган)»?', 'nadležan', '["obrazloženje", "povratnica", "podnositelj zahtjeva", "nadležan"]'::jsonb, 'A2', 6, 'PUBLISHED', 'nadležan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8aa018c5-be92-5c4b-8026-36cff6b16c73', 'type_answer', 'Напишіть хорватською: «цим листом, таким чином»', 'ovim putem', null, 'A2', 7, 'PUBLISHED', 'ovim putem', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '741d364d-8c84-5f6c-bf3d-1221359f8c70', 'type_answer', 'Напишіть хорватською: «канцелярія (приймання документів)»', 'pisarnica', null, 'A2', 8, 'PUBLISHED', 'pisarnica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '25a4be17-8823-5410-a943-ff7d4e1a7140', 'type_answer', 'Напишіть хорватською: «обґрунтування»', 'obrazloženje', null, 'A2', 9, 'PUBLISHED', 'obrazloženje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6fe081b5-1027-56da-9bee-8abde5933241', 'sentence_builder', 'Складіть: «Цим листом прошу видати довідку.»', 'Ovim putem molim izdavanje potvrde.', '["potvrde.", "izdavanje", "molim", "Ovim", "putem"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7faeee69-0a7c-57fc-b589-1b1412ea8824', 'sentence_builder', 'Складіть: «Заповніть бланк друкованими літерами.»', 'Ispunite obrazac tiskanim slovima.', '["Ispunite", "tiskanim", "slovima.", "obrazac"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ad85de97-9ac1-569e-b149-8fc92993e184', 'listening', 'Прослухайте і складіть фразу', 'Ovdje, u pisarnici. Ovo je Vaš urudžbeni broj.', '["Ovo", "urudžbeni", "Vaš", "broj.", "pisarnici.", "je", "u", "Ovdje,"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'ad23b52e-6bba-5072-8059-9733a597d051', 'listening_dialogue', 'Прослухайте оголошення', 'до 15 травня; рекомендованим листом; до кінця червня', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Інформація на автовідповідачі міської установи.", "script": [{"hr": "Dobili ste Gradski ured za obrazovanje.", "ua": "Ви зателефонували до Міського відділу освіти."}, {"hr": "Zahtjevi za upis u vrtić primaju se do petnaestog svibnja.", "ua": "Заяви на вступ до садочка приймають до п’ятнадцятого травня."}, {"hr": "Zahtjev možete predati u pisarnici ili poslati preporučenim pismom.", "ua": "Заяву можна подати в канцелярії або надіслати рекомендованим листом."}, {"hr": "Rješenja se šalju poštom do kraja lipnja.", "ua": "Рішення надсилають поштою до кінця червня."}], "questions": [{"q_ua": "До коли приймають заяви?", "options": ["до 15 травня", "до 15 червня", "до кінця травня"], "correct": 0, "answer_turn": 1}, {"q_ua": "Як ще можна подати заяву?", "options": ["e-mailом", "рекомендованим листом", "по телефону"], "correct": 1, "answer_turn": 2}, {"q_ua": "Коли надішлють рішення?", "options": ["протягом тижня", "у вересні", "до кінця червня"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'ad23b52e-6bba-5072-8059-9733a597d051', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7b46f060-3f36-50ef-8fe5-7c6355c6d336', 'speaking', 'Де подають заяву?', 'Gdje se predaje zahtjev?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a8a81133-6614-5a08-9e7b-7a8df01cfb40', 'speaking', 'Який відділ за це відповідає?', 'Koji ured je nadležan za to?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'd25637cf-9fc1-5001-9b08-4acef1149a35', 'write_message', 'Напишіть коротку офіційну заяву: тема — видача довідки про місце проживання; прохання; у додатку — копія паспорта.', 'Predmet: zahtjev za izdavanje potvrde o prebivalištu. Ovim putem molim izdavanje potvrde o prebivalištu. U prilogu: preslika putovnice. S poštovanjem, Darja Kovalenko', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть коротку офіційну заяву: тема — видача довідки про місце проживання; прохання; у додатку — копія паспорта.", "points": [{"ua": "тема", "keys": [["predmet"], ["zahtjev za"]]}, {"ua": "прохання", "keys": [["molim"]]}, {"ua": "довідка про проживання", "keys": [["prebivališt"]]}, {"ua": "у додатку копія паспорта", "keys": [["privitk", "putovnic"], ["prilog", "putovnic"]]}], "hints": ["Predmet: zahtjev za izdavanje potvrde", "ovim putem molim", "potvrda o prebivalištu", "u prilogu: preslika putovnice"], "models": ["Predmet: zahtjev za izdavanje potvrde o prebivalištu. Ovim putem molim izdavanje potvrde o prebivalištu. U prilogu: preslika putovnice. S poštovanjem, Darja Kovalenko"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'd25637cf-9fc1-5001-9b08-4acef1149a35', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '0540fca3-931c-55f3-a2e9-5e10c2b20ef7', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Kada će dobiti odgovor i što može napraviti ako zahtjev bude odbijen?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай у канцелярії, коли я отримаю відповідь і що робити, якщо заяву відхилять.", "direction": "ua_hr", "points": [{"ua": "коли відповідь", "keys": [["odgovor"]]}, {"ua": "якщо відхилять", "keys": [["odbij"]]}, {"ua": "що робити", "keys": [["što"], ["žalb"]]}], "hints": [], "models": ["Kada će dobiti odgovor i što može napraviti ako zahtjev bude odbijen?"], "source_ua": "Спитай у канцелярії, коли я отримаю відповідь і що робити, якщо заяву відхилять."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '0540fca3-931c-55f3-a2e9-5e10c2b20ef7', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('241502ec-f363-572c-abe2-2f7b975255eb', v_lesson, 'Як написати заяву?', 'Kako napisati zahtjev?', 5421, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('2f18da67-1331-549c-ae2c-434e3bf5b28c', '241502ec-f363-572c-abe2-2f7b975255eb', 'Darja', 'Ivana, kako da napišem zahtjev za potvrdu o prebivalištu?', 'Івано, як мені написати заяву на довідку про місце проживання?', 1);
  perform pg_temp.turn('3c3bfd95-75aa-5fbb-9069-b4c96cff55c4', '241502ec-f363-572c-abe2-2f7b975255eb', 'Ivana', 'Gore napiši svoje podatke, a ispod naslovljeno na Gradski ured.', 'Угорі напиши свої дані, а нижче — кому адресовано: міському відділу.', 2);
  perform pg_temp.turn('519252df-65f5-5310-a149-1ef2eda48e44', '241502ec-f363-572c-abe2-2f7b975255eb', 'Darja', 'A što piše u predmetu?', 'А що писати в темі?', 3);
  perform pg_temp.turn('621a0f6e-afd7-51fc-9e77-30bd2f6923ad', '241502ec-f363-572c-abe2-2f7b975255eb', 'Ivana', '„Zahtjev za izdavanje potvrde.“ Onda: „Ovim putem molim izdavanje…“', '«Заява про видачу довідки». Потім: «Цим листом прошу видати…»', 4);
  perform pg_temp.turn('8aaec6d8-7f58-53c4-b07f-b03f24ee3f07', '241502ec-f363-572c-abe2-2f7b975255eb', 'Darja', 'I na kraju „u prilogu“ i dokumenti?', 'А наприкінці «у додатку» і документи?', 5);
  perform pg_temp.turn('2651ee95-475b-5951-ba48-52505084c497', '241502ec-f363-572c-abe2-2f7b975255eb', 'Ivana', 'Točno. I ne zaboravi potpis.', 'Точно. І не забудь підпис.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7513accd-4905-5e4f-80a9-4a3accde548e', v_lesson, 'У канцелярії', 'U pisarnici', 5422, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('0a6c9cdb-be27-5c85-accf-9d20b68d022f', '7513accd-4905-5e4f-80a9-4a3accde548e', 'Daša', 'Dobar dan, gdje se predaje zahtjev za vrtić?', 'Добрий день, де подають заяву до садочка?', 1);
  perform pg_temp.turn('bd73acf5-4d22-578c-b912-c3bc8180e326', '7513accd-4905-5e4f-80a9-4a3accde548e', 'Službenica', 'Ovdje, u pisarnici. Ovo je Vaš urudžbeni broj.', 'Тут, у канцелярії. Ось ваш вхідний номер.', 2);
  perform pg_temp.turn('88d2dd2c-5646-5186-8fd0-67b8999d0b77', '7513accd-4905-5e4f-80a9-4a3accde548e', 'Daša', 'Kada ću dobiti odgovor?', 'Коли я отримаю відповідь?', 3);
  perform pg_temp.turn('7a21a228-731e-5a1f-989d-f07b029f2b73', '7513accd-4905-5e4f-80a9-4a3accde548e', 'Službenica', 'U zakonskom roku, do trideset dana. Rješenje se šalje poštom.', 'У визначений законом строк, до тридцяти днів. Рішення надсилають поштою.', 4);
  perform pg_temp.turn('e358695d-8ee8-5850-9f5b-959dc4a9f152', '7513accd-4905-5e4f-80a9-4a3accde548e', 'Daša', 'A ako zahtjev bude odbijen?', 'А якщо заяву відхилять?', 5);
  perform pg_temp.turn('910b3a57-3cc2-5698-b066-e9cc4955888c', '7513accd-4905-5e4f-80a9-4a3accde548e', 'Službenica', 'Imate pravo na žalbu u roku od petnaest dana.', 'Ви маєте право на оскарження протягом п’ятнадцяти днів.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- 3. Модуль і юніт — опубліковані
update public.modules set status = 'PUBLISHED', title_ua = 'Модуль A2.6 — Установи, послуги й гроші', title_hr = 'Modul A2.6 — Ustanove, usluge i novac' where id = 'f811eff6-8d8a-5fac-8ae7-6b78020976f1';
update public.units set status = 'PUBLISHED' where id = '6ce8eeae-3862-5515-9d3a-963bbf590733';

-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('8ab1c1e5-b217-5175-ab89-325106da3504', 'bf43b6bd-d547-596b-8981-55a4043cf238', '856c691f-4467-561f-a344-377ca275dbba', '5f9af92b-06e1-5179-81a3-19625a5b8273', 'f3cfca9e-efc9-5b58-8fe9-772fa631e0c2', '0b5f1880-b274-51c1-9d55-32a9873040a2')
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
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 20 or l.unit_id <> '6ce8eeae-3862-5515-9d3a-963bbf590733');
  select count(*) into v_titles from (values ('8ab1c1e5-b217-5175-ab89-325106da3504'::uuid, 'Урок 37:%', 1), ('bf43b6bd-d547-596b-8981-55a4043cf238'::uuid, 'Урок 38:%', 2), ('856c691f-4467-561f-a344-377ca275dbba'::uuid, 'Урок 39:%', 3), ('5f9af92b-06e1-5179-81a3-19625a5b8273'::uuid, 'Урок 40:%', 4), ('f3cfca9e-efc9-5b58-8fe9-772fa631e0c2'::uuid, 'Урок 41:%', 5), ('0b5f1880-b274-51c1-9d55-32a9873040a2'::uuid, 'Урок 42:%', 6)) as t(id, pat, o)
    left join public.lessons l on l.id = t.id and l.title_ua like t.pat and l.order_index = t.o
   where l.id is null;
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
      where l.level_code = 'A2' and l.status = 'PUBLISHED' and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A2.6: % уроків з неправильним складом', v_bad; end if;
  if v_titles > 0 then raise exception 'Модуль A2.6: % уроків не на своєму місці чи з неправильним номером', v_titles; end if;
  if v_words > 0 then raise exception 'A2: % слів повторюються в кількох уроках', v_words; end if;
  if (select status from public.modules where id = 'f811eff6-8d8a-5fac-8ae7-6b78020976f1') <> 'PUBLISHED' then raise exception 'Модуль A2.6 не опубліковано'; end if;
  raise notice 'Готово: модуль A2.6 — 6 уроків, слів 126';
end $$;

commit;
