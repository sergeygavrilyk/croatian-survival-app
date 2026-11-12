-- =====================================================================
-- Програма A2 v2 · модуль A2.11 «Хорватія: краї, звичаї, культура» · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2.py 11 (не редагуйте вручну).
--
-- Рішення власника 2026-11-12: 20–25 нових слів на урок, 90–95 % слів — нові для рівня, діалоги під тему,
-- частіше Даша / Дар’я; «Прослухайте діалог чи оголошення» в кожному уроці; бета (PUBLISHED).
--   * Уроки 66–71 (6): слів у них 126. Кожен: 20–25 слів, 2 діалоги, 15 вправ
--     (одна — «Прослухайте діалог чи оголошення»), «Напишіть повідомлення» і «Перекажіть другу» (ua → hr, необов’язкові), 20 хв.
--   * Слова: 126 (нові — PUBLISHED; ті, що вже є в словнику, не змінюються).
--   * Модуль і юніт A2.11 → PUBLISHED. Потрібен уже запущений 20261112_curriculum_a2_v2_00_structure.sql.
--   * Нічого не видаляє. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.units where id = '3fbc4d9b-4366-5f0f-b785-eb3f750240be') then
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

-- 1. Слова уроків A2.11 (126): нові — PUBLISHED (бета); наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A2', t.ua, t.vtype, t.forms, t.examples, 'PUBLISHED', 'claude_curriculum_a2_v2'
  from jsonb_to_recordset('[{"lemma": "istarski", "normalized": "istarski", "pos": "adjective", "ua": "істрійський", "vtype": "core", "forms": {}, "examples": ["Istarski pršut se ne dimi, za razliku od dalmatinskog."]}, {"lemma": "brdski gradić", "normalized": "brdski gradic", "pos": "phrase", "ua": "містечко на пагорбі", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Motovun je brdski gradić iznad doline."]}, {"lemma": "dolina", "normalized": "dolina", "pos": "noun", "ua": "долина", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Iz Motovuna se vidi cijela dolina."]}, {"lemma": "maneštra", "normalized": "manestra", "pos": "noun", "ua": "манештра (густий овочевий суп)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Zimi kuhamo istarsku maneštru."]}, {"lemma": "fuži", "normalized": "fuzi", "pos": "noun", "ua": "фужі (істрійська паста)", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Fuži s tartufima su specijalitet."]}, {"lemma": "teran", "normalized": "teran", "pos": "noun", "ua": "теран (червоне вино з Істрії)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Uz meso pijemo teran."]}, {"lemma": "malvazija", "normalized": "malvazija", "pos": "noun", "ua": "мальвазія (біле вино)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Istarska malvazija je lagano bijelo vino."]}, {"lemma": "tartufi", "normalized": "tartufi", "pos": "noun", "ua": "трюфелі", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["U jesen se u šumama traže tartufi."]}, {"lemma": "amfiteatar", "normalized": "amfiteatar", "pos": "noun", "ua": "амфітеатр", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Pulski amfiteatar je star dvije tisuće godina."]}, {"lemma": "pulski", "normalized": "pulski", "pos": "adjective", "ua": "пульський (з Пули)", "vtype": "core", "forms": {}, "examples": ["Pulski amfiteatar zovu Arena."]}, {"lemma": "rovinjski", "normalized": "rovinjski", "pos": "adjective", "ua": "ровіньський", "vtype": "core", "forms": {}, "examples": ["Rovinjske uličice vode do crkve na brdu."]}, {"lemma": "uličica", "normalized": "ulicica", "pos": "noun", "ua": "вуличка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Uličice su uske i strme."]}, {"lemma": "dvojezičan", "normalized": "dvojezican", "pos": "adjective", "ua": "двомовний", "vtype": "core", "forms": {}, "examples": ["U Istri su natpisi dvojezični."]}, {"lemma": "talijanska manjina", "normalized": "talijanska manjina", "pos": "phrase", "ua": "італійська меншина", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U Istri živi talijanska manjina."]}, {"lemma": "agroturizam", "normalized": "agroturizam", "pos": "noun", "ua": "агротуризм, сільська садиба", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ručali smo u agroturizmu kod Pazina."]}, {"lemma": "maslinik", "normalized": "maslinik", "pos": "noun", "ua": "оливковий гай", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Iza kuće je veliki maslinik."]}, {"lemma": "kamena kuća", "normalized": "kamena kuca", "pos": "phrase", "ua": "кам’яний будинок", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Unajmili smo staru kamenu kuću."]}, {"lemma": "crvena zemlja", "normalized": "crvena zemlja", "pos": "phrase", "ua": "червона земля (теракота)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Istarska crvena zemlja je dobra za vino."]}, {"lemma": "vinska cesta", "normalized": "vinska cesta", "pos": "phrase", "ua": "винний маршрут", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Vozili smo se vinskom cestom."]}, {"lemma": "kušanje vina", "normalized": "kusanje vina", "pos": "phrase", "ua": "дегустація вина", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Na kušanju vina bilo je šest vrsta."]}, {"lemma": "poznat po", "normalized": "poznat po", "pos": "phrase", "ua": "відомий чим", "vtype": "chunk", "forms": {}, "examples": ["Motovun je poznat po filmskom festivalu."]}, {"lemma": "slavonski", "normalized": "slavonski", "pos": "adjective", "ua": "славонський", "vtype": "core", "forms": {}, "examples": ["Slavonski kulen je ljut i mirisan."]}, {"lemma": "osječki", "normalized": "osjecki", "pos": "adjective", "ua": "осієцький (з Осієка)", "vtype": "core", "forms": {}, "examples": ["Osječka Tvrđa je barokni dio grada."]}, {"lemma": "vukovarski", "normalized": "vukovarski", "pos": "adjective", "ua": "вуковарський", "vtype": "core", "forms": {}, "examples": ["Vukovarski vodotoranj je simbol grada."]}, {"lemma": "žitna polja", "normalized": "zitna polja", "pos": "phrase", "ua": "хлібні поля", "vtype": "chunk", "forms": {"gender": "n_pl"}, "examples": ["Ljeti su žitna polja žuta."]}, {"lemma": "suncokret", "normalized": "suncokret", "pos": "noun", "ua": "соняшник", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Polja suncokreta podsjećaju me na Ukrajinu."]}, {"lemma": "kukuruz", "normalized": "kukuruz", "pos": "noun", "ua": "кукурудза", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Djed je cijeli život sadio kukuruz."]}, {"lemma": "fiš paprikaš", "normalized": "fis paprikas", "pos": "phrase", "ua": "фіш-паприкаш (рибна юшка з паприкою)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Fiš paprikaš se kuha u kotliću."]}, {"lemma": "kotlić", "normalized": "kotlic", "pos": "noun", "ua": "казанок", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Na vatri je kotlić s čobancem."]}, {"lemma": "šljivovica", "normalized": "sljivovica", "pos": "noun", "ua": "сливовиця (сливова ракія)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Domaćin nas je ponudio šljivovicom."]}, {"lemma": "svinjokolja", "normalized": "svinjokolja", "pos": "noun", "ua": "свіжування свині (зимове свято)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Na svinjokolji se okuplja cijela obitelj."]}, {"lemma": "berba grožđa", "normalized": "berba grozda", "pos": "phrase", "ua": "збір винограду", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U rujnu je berba grožđa u Iloku."]}, {"lemma": "vinski podrum", "normalized": "vinski podrum", "pos": "phrase", "ua": "винний льох", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Iločki vinski podrum je jedan od najstarijih."]}, {"lemma": "tamburaši", "normalized": "tamburasi", "pos": "noun", "ua": "тамбураші (музиканти)", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Na svadbi su svirali tamburaši."]}, {"lemma": "bakin", "normalized": "bakin", "pos": "adjective", "ua": "бабусин", "vtype": "core", "forms": {}, "examples": ["Bakin kulen je najbolji."]}, {"lemma": "Dunav", "normalized": "dunav", "pos": "noun", "ua": "Дунай", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Vukovar leži na Dunavu."]}, {"lemma": "ravničarski", "normalized": "ravnicarski", "pos": "adjective", "ua": "рівнинний", "vtype": "core", "forms": {}, "examples": ["Ravničarski krajolik je miran."]}, {"lemma": "salaš", "normalized": "salas", "pos": "noun", "ua": "хутір, сільська садиба (у рівнинах)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Prespavali smo na salašu kod Osijeka."]}, {"lemma": "lipicanac", "normalized": "lipicanac", "pos": "noun", "ua": "ліпіцанер (порода коней)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["U Đakovu se uzgajaju lipicanci."]}, {"lemma": "gostoljubiv", "normalized": "gostoljubiv", "pos": "adjective", "ua": "гостинний", "vtype": "core", "forms": {}, "examples": ["Slavonci su vrlo gostoljubivi."]}, {"lemma": "domaća kobasica", "normalized": "domaca kobasica", "pos": "phrase", "ua": "домашня ковбаса", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Domaća kobasica je iz pušnice."]}, {"lemma": "pušnica", "normalized": "pusnica", "pos": "noun", "ua": "коптильня", "vtype": "core", "forms": {"gender": "f"}, "examples": ["U pušnici se suše kobasice i šunke."]}, {"lemma": "lički", "normalized": "licki", "pos": "adjective", "ua": "ліцький (з Ліки)", "vtype": "core", "forms": {}, "examples": ["Lički krumpir je poznat po okusu."]}, {"lemma": "goranski", "normalized": "goranski", "pos": "adjective", "ua": "горанський (з Горського Котару)", "vtype": "core", "forms": {}, "examples": ["Goranske šume su guste i tamne."]}, {"lemma": "velebitski", "normalized": "velebitski", "pos": "adjective", "ua": "велебітський", "vtype": "core", "forms": {}, "examples": ["Velebitski vrhovi su ljeti zeleni."]}, {"lemma": "gorje", "normalized": "gorje", "pos": "noun", "ua": "гори, гірський масив", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Gorje između mora i kopna zove se Velebit."]}, {"lemma": "vrh", "normalized": "vrh", "pos": "noun", "ua": "вершина", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Popeli smo se na vrh za tri sata."]}, {"lemma": "planinarska staza", "normalized": "planinarska staza", "pos": "phrase", "ua": "туристична (гірська) стежка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Planinarska staza je dobro označena."]}, {"lemma": "planinarska kuća", "normalized": "planinarska kuca", "pos": "phrase", "ua": "гірський притулок", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Prespavali smo u planinarskoj kući."]}, {"lemma": "markacija", "normalized": "markacija", "pos": "noun", "ua": "маркування (стежки)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Pratite crveno-bijele markacije."]}, {"lemma": "jelova šuma", "normalized": "jelova suma", "pos": "phrase", "ua": "ялицевий ліс", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Kroz jelovu šumu vodi uska staza."]}, {"lemma": "smeđi medvjed", "normalized": "smedi medvjed", "pos": "phrase", "ua": "бурий ведмідь", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["U Gorskom kotaru živi smeđi medvjed."]}, {"lemma": "divljač", "normalized": "divljac", "pos": "noun", "ua": "дичина", "vtype": "core", "forms": {"gender": "f"}, "examples": ["U restoranu služe divljač."]}, {"lemma": "špilja", "normalized": "spilja", "pos": "noun", "ua": "печера", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Posjetili smo špilju Baraćevu."]}, {"lemma": "krš", "normalized": "krs", "pos": "noun", "ua": "карст", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Lika je kraj krša i polja."]}, {"lemma": "oštra zima", "normalized": "ostra zima", "pos": "phrase", "ua": "сувора зима", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U Lici su zime oštre."]}, {"lemma": "snježni nanosi", "normalized": "snjezni nanosi", "pos": "phrase", "ua": "снігові замети", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Zbog snježnih nanosa cesta je zatvorena."]}, {"lemma": "skijalište", "normalized": "skijaliste", "pos": "noun", "ua": "гірськолижний курорт, схил", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Najbliže skijalište je u Platku."]}, {"lemma": "sanjkati se", "normalized": "sanjkati se", "pos": "verb", "ua": "кататися на санчатах", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Djeca se sanjkaju iza kuće."]}, {"lemma": "rijetko naseljen", "normalized": "rijetko naseljen", "pos": "phrase", "ua": "малонаселений", "vtype": "chunk", "forms": {}, "examples": ["Lika je rijetko naseljena."]}, {"lemma": "iseljavanje", "normalized": "iseljavanje", "pos": "noun", "ua": "еміграція, виїзд населення", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Iseljavanje je veliki problem Like."]}, {"lemma": "netaknuta priroda", "normalized": "netaknuta priroda", "pos": "phrase", "ua": "незаймана природа", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Gorski kotar je raj netaknute prirode."]}, {"lemma": "planinarski vodič", "normalized": "planinarski vodic", "pos": "phrase", "ua": "гірський гід; путівник для туристів", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Planinarski vodič nas je vodio do vrha."]}, {"lemma": "zagrebački", "normalized": "zagrebacki", "pos": "adjective", "ua": "загребський", "vtype": "core", "forms": {}, "examples": ["Zagrebačka katedrala se vidi iz cijelog grada."]}, {"lemma": "zagorski", "normalized": "zagorski", "pos": "adjective", "ua": "загорський (із Загор’я)", "vtype": "core", "forms": {}, "examples": ["Zagorski štrukli su najpoznatiji."]}, {"lemma": "Gornji grad", "normalized": "gornji grad", "pos": "phrase", "ua": "Верхнє місто (Загреб)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Na Gornji grad idemo uspinjačom."]}, {"lemma": "Donji grad", "normalized": "donji grad", "pos": "phrase", "ua": "Нижнє місто (Загреб)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Donji grad je pun muzeja i parkova."]}, {"lemma": "uspinjača", "normalized": "uspinjaca", "pos": "noun", "ua": "фунікулер", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Uspinjača je jedna od najkraćih na svijetu."]}, {"lemma": "tržnica Dolac", "normalized": "trznica dolac", "pos": "phrase", "ua": "ринок Долац", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na tržnici Dolac kupujem sir i vrhnje."]}, {"lemma": "sir i vrhnje", "normalized": "sir i vrhnje", "pos": "phrase", "ua": "сир зі сметаною", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Sir i vrhnje je zagrebački specijalitet."]}, {"lemma": "licitarsko srce", "normalized": "licitarsko srce", "pos": "phrase", "ua": "ліцитарське серце (медяник)", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Kupila sam licitarsko srce za uspomenu."]}, {"lemma": "dvorac", "normalized": "dvorac", "pos": "noun", "ua": "замок, палац", "vtype": "core", "forms": {"gender": "m"}, "examples": ["U Zagorju ima puno dvoraca."]}, {"lemma": "brežuljak", "normalized": "brezuljak", "pos": "noun", "ua": "пагорб", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Zagorje je kraj brežuljaka i vinograda."]}, {"lemma": "kajkavski", "normalized": "kajkavski", "pos": "adjective", "ua": "кайкавський (діалект)", "vtype": "core", "forms": {}, "examples": ["Bake u Zagorju govore kajkavski."]}, {"lemma": "purica s mlincima", "normalized": "purica s mlincima", "pos": "phrase", "ua": "індичка з млинцями", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za nedjeljni ručak bila je purica s mlincima."]}, {"lemma": "topličko kupalište", "normalized": "toplicko kupaliste", "pos": "phrase", "ua": "термальний курорт", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Vikendom idemo na topličko kupalište."]}, {"lemma": "termalna voda", "normalized": "termalna voda", "pos": "phrase", "ua": "термальна вода", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Termalna voda je dobra za leđa."]}, {"lemma": "advent", "normalized": "advent", "pos": "noun", "ua": "адвент (передріздвяний час)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Advent u Zagrebu je jedan od najljepših u Europi."]}, {"lemma": "božićni sajam", "normalized": "bozicni sajam", "pos": "phrase", "ua": "різдвяний ярмарок", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Na božićnom sajmu pijemo kuhano vino."]}, {"lemma": "kuhano vino", "normalized": "kuhano vino", "pos": "phrase", "ua": "глінтвейн", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Kuhano vino grije zimi."]}, {"lemma": "Teslina ulica", "normalized": "teslina ulica", "pos": "phrase", "ua": "вулиця Тесли", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Teslina ulica vodi do glavnog trga."]}, {"lemma": "glavni grad", "normalized": "glavni grad", "pos": "phrase", "ua": "столиця", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Zagreb je glavni grad Hrvatske."]}, {"lemma": "prigradski", "normalized": "prigradski", "pos": "adjective", "ua": "приміський", "vtype": "core", "forms": {}, "examples": ["Prigradski vlak vozi do Zaprešića."]}, {"lemma": "gradska četvrt", "normalized": "gradska cetvrt", "pos": "phrase", "ua": "міський район", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Trešnjevka je velika gradska četvrt."]}, {"lemma": "bonton", "normalized": "bonton", "pos": "noun", "ua": "етикет", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Bonton se uči od malih nogu."]}, {"lemma": "pristojno", "normalized": "pristojno", "pos": "adverb", "ua": "чемно, пристойно", "vtype": "core", "forms": {}, "examples": ["Pristojno je donijeti nešto domaćinu."]}, {"lemma": "nepristojno", "normalized": "nepristojno", "pos": "adverb", "ua": "нечемно, непристойно", "vtype": "core", "forms": {}, "examples": ["Nepristojno je kasniti na ručak."]}, {"lemma": "poljubiti u obraz", "normalized": "poljubiti u obraz", "pos": "phrase", "ua": "поцілувати в щоку", "vtype": "chunk", "forms": {}, "examples": ["Prijatelji se pozdravljaju poljupcem u obraz."]}, {"lemma": "papuče za goste", "normalized": "papuce za goste", "pos": "phrase", "ua": "капці для гостей", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Domaćica ima papuče za goste."]}, {"lemma": "obiteljsko okupljanje", "normalized": "obiteljsko okupljanje", "pos": "phrase", "ua": "родинна зустріч", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Nedjeljom je obiteljsko okupljanje kod bake."]}, {"lemma": "domaćičin", "normalized": "domacicin", "pos": "adjective", "ua": "господинин", "vtype": "core", "forms": {}, "examples": ["Pohvalite domaćičin kolač."]}, {"lemma": "obiteljski ručak", "normalized": "obiteljski rucak", "pos": "phrase", "ua": "сімейний обід", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Nedjeljom je obiteljski ručak kod bake."]}, {"lemma": "pomalo", "normalized": "pomalo", "pos": "adverb", "ua": "потроху, не поспішаючи", "vtype": "core", "forms": {}, "examples": ["Pomalo, nema žurbe."]}, {"lemma": "persirati", "normalized": "persirati", "pos": "verb", "ua": "звертатися на «ви»", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Starijima se persira."]}, {"lemma": "tikati", "normalized": "tikati", "pos": "verb", "ua": "звертатися на «ти»", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Kolege se uglavnom tikaju."]}, {"lemma": "ispijati kavu", "normalized": "ispijati kavu", "pos": "phrase", "ua": "попивати каву", "vtype": "chunk", "forms": {}, "examples": ["Na rivi ispijamo kavu cijelo jutro."]}, {"lemma": "riva", "normalized": "riva", "pos": "noun", "ua": "набережна (у приморському місті)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Navečer se šetamo rivom."]}, {"lemma": "običaj je", "normalized": "obicaj je", "pos": "phrase", "ua": "заведено (звичай)", "vtype": "chunk", "forms": {}, "examples": ["Običaj je donijeti vino ili cvijeće."]}, {"lemma": "poziv na kavu", "normalized": "poziv na kavu", "pos": "phrase", "ua": "запрошення на каву", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Poziv na kavu ne znači samo kavu."]}, {"lemma": "poslužiti", "normalized": "posluziti", "pos": "verb", "ua": "пригостити, подати (до столу)", "vtype": "core", "forms": {"aspect": "pfv", "pair": "posluživati"}, "examples": ["Domaćica je poslužila kolače i rakiju."]}, {"lemma": "ponašati se", "normalized": "ponasati se", "pos": "verb", "ua": "поводитися", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Djeca se moraju lijepo ponašati za stolom."]}, {"lemma": "lijepo ponašanje", "normalized": "lijepo ponasanje", "pos": "phrase", "ua": "гарна поведінка", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Lijepo ponašanje se uvijek cijeni."]}, {"lemma": "kavanska kultura", "normalized": "kavanska kultura", "pos": "phrase", "ua": "культура кав’ярень", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Kavanska kultura je dio hrvatskog života."]}, {"lemma": "gostovanje", "normalized": "gostovanje", "pos": "noun", "ua": "гостини, візит", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Gostovanje kod susjeda trajalo je do ponoći."]}, {"lemma": "poklon za domaćina", "normalized": "poklon za domacina", "pos": "phrase", "ua": "подарунок господарю", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Poklon za domaćina ne mora biti skup."]}, {"lemma": "klapsko pjevanje", "normalized": "klapsko pjevanje", "pos": "phrase", "ua": "спів клапи (далматинський хоровий спів)", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Klapsko pjevanje je na popisu UNESCO-a."]}, {"lemma": "tamburica", "normalized": "tamburica", "pos": "noun", "ua": "тамбуриця (струнний інструмент)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Djed je svirao tamburicu."]}, {"lemma": "nematerijalna baština", "normalized": "nematerijalna bastina", "pos": "phrase", "ua": "нематеріальна спадщина", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Hrvatska ima puno nematerijalne baštine."]}, {"lemma": "kulturna baština", "normalized": "kulturna bastina", "pos": "phrase", "ua": "культурна спадщина", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Dubrovnik je dio svjetske kulturne baštine."]}, {"lemma": "paška čipka", "normalized": "paska cipka", "pos": "phrase", "ua": "пазьке мереживо", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Paška čipka se radi ručno."]}, {"lemma": "sinjska alka", "normalized": "sinjska alka", "pos": "phrase", "ua": "Сіньська алка (лицарський турнір)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Sinjska alka se održava svakog kolovoza."]}, {"lemma": "viteški turnir", "normalized": "viteski turnir", "pos": "phrase", "ua": "лицарський турнір", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Alka je stari viteški turnir."]}, {"lemma": "narodna nošnja", "normalized": "narodna nosnja", "pos": "phrase", "ua": "народний костюм", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na festivalu svi nose narodne nošnje."]}, {"lemma": "folklorna skupina", "normalized": "folklorna skupina", "pos": "phrase", "ua": "фольклорний ансамбль", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Kći pleše u folklornoj skupini."]}, {"lemma": "kolo", "normalized": "kolo", "pos": "noun", "ua": "коло (народний танець)", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Na kraju svi plešu kolo."]}, {"lemma": "bećarac", "normalized": "becarac", "pos": "noun", "ua": "бечарац (славонська пісня-жарт)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Bećarac se pjeva na slavlju."]}, {"lemma": "ojkanje", "normalized": "ojkanje", "pos": "noun", "ua": "ойкання (старовинний спів)", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Ojkanje je jedan od najstarijih načina pjevanja."]}, {"lemma": "a cappella", "normalized": "a cappella", "pos": "phrase", "ua": "а капела (без інструментів)", "vtype": "chunk", "forms": {}, "examples": ["Klapa pjeva a cappella."]}, {"lemma": "glas", "normalized": "glas", "pos": "noun", "ua": "голос", "vtype": "core", "forms": {"gender": "m"}, "examples": ["U klapi pjeva osam muških glasova."]}, {"lemma": "nastup", "normalized": "nastup", "pos": "noun", "ua": "виступ", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Nastup klape je u devet na rivi."]}, {"lemma": "svjetski", "normalized": "svjetski", "pos": "adjective", "ua": "світовий", "vtype": "core", "forms": {}, "examples": ["To je svjetski poznata tradicija."]}, {"lemma": "očuvati", "normalized": "ocuvati", "pos": "verb", "ua": "зберегти", "vtype": "core", "forms": {"aspect": "pfv", "pair": "čuvati"}, "examples": ["Mladi žele očuvati stare običaje."]}, {"lemma": "prenositi s koljena na koljeno", "normalized": "prenositi s koljena na koljeno", "pos": "phrase", "ua": "передавати з покоління в покоління", "vtype": "chunk", "forms": {}, "examples": ["Čipka se prenosi s koljena na koljeno."]}, {"lemma": "ručni rad", "normalized": "rucni rad", "pos": "phrase", "ua": "ручна робота", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ovo je pravi ručni rad."]}, {"lemma": "licitar", "normalized": "licitar", "pos": "noun", "ua": "ліцитар (розписаний медяник)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Licitari su crveni i šareni."]}, {"lemma": "dalmatinski", "normalized": "dalmatinski", "pos": "adjective", "ua": "далматинський", "vtype": "core", "forms": {}, "examples": ["Dalmatinska klapa pjeva o moru i ljubavi."]}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 2. Уроки модуля A2.11
-- A2.11 · урок 66: Істрія — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '3fbc4d9b-4366-5f0f-b785-eb3f750240be';
  v_lesson constant uuid := 'df44c302-d9be-51e9-9c3f-a5faf4ca04a6';
  v_gid constant uuid := '6da44157-69d7-5261-8289-fe910fd60f59';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики POSV'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A2.11: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 66: Істрія', 'Lekcija 66: Istra', '["Розповісти про Істрію: міста на пагорбах, кухня, двомовність", "Прикметники від місць: istarski, rovinjski, pulski"]'::jsonb, 20, 'PUBLISHED', 1);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'istarski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brdski gradić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dolina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maneštra', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fuži', v_pos);
  v_pos := pg_temp.word(v_lesson, 'teran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'malvazija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tartufi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'amfiteatar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pulski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rovinjski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uličica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dvojezičan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'talijanska manjina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'agroturizam', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maslinik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kamena kuća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crvena zemlja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vinska cesta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kušanje vina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poznat po', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b0d463e8-9b68-5a8d-ab0b-6b51411862de', 'fill_in_the_blank', 'Pulski amfiteatar je jedan od najljepših u svijetu, a ___ uličice su prekrasne.', 'rovinjske', '["Rovinja", "rovinjske", "rovinjski", "Rovinj"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e606178a-cfc3-511d-ab5c-c66e84ebd8dd', 'multiple_choice', 'Що означає «vinska cesta»?', 'винний маршрут', '["ровіньський", "вуличка", "долина", "винний маршрут"]'::jsonb, 'A2', 2, 'PUBLISHED', 'vinska cesta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '21d46b81-6017-5b89-9f7a-dffa891d8c18', 'multiple_choice', 'Що означає «amfiteatar»?', 'амфітеатр', '["амфітеатр", "італійська меншина", "відомий чим", "істрійський"]'::jsonb, 'A2', 3, 'PUBLISHED', 'amfiteatar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '619bb5ef-5f55-58a8-8893-d59735a8561b', 'multiple_choice', 'Що означає «fuži»?', 'фужі (істрійська паста)', '["червона земля (теракота)", "теран (червоне вино з Істрії)", "долина", "фужі (істрійська паста)"]'::jsonb, 'A2', 4, 'PUBLISHED', 'fuži', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f851cded-9238-56b1-88d3-cec0ab5b7fbe', 'multiple_choice', 'Як хорватською «двомовний»?', 'dvojezičan', '["tartufi", "brdski gradić", "fuži", "dvojezičan"]'::jsonb, 'A2', 5, 'PUBLISHED', 'dvojezičan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a111187-141b-56b6-910d-899c174ec353', 'multiple_choice', 'Як хорватською «оливковий гай»?', 'maslinik', '["talijanska manjina", "maslinik", "fuži", "kušanje vina"]'::jsonb, 'A2', 6, 'PUBLISHED', 'maslinik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '141903d1-e9f8-5a82-ac57-5cb392270d02', 'type_answer', 'Напишіть хорватською: «вуличка»', 'uličica', null, 'A2', 7, 'PUBLISHED', 'uličica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fff2b935-f8aa-50ae-b70f-2acdd080a332', 'type_answer', 'Напишіть хорватською: «трюфелі»', 'tartufi', null, 'A2', 8, 'PUBLISHED', 'tartufi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '67fc59ed-263c-54af-a551-d5a10b1acbb0', 'type_answer', 'Напишіть хорватською: «дегустація вина»', 'kušanje vina', null, 'A2', 9, 'PUBLISHED', 'kušanje vina', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5b2eaf6b-1ec0-5200-888d-d5fd63779c32', 'sentence_builder', 'Складіть: «В Істрії написи двомовні.»', 'U Istri su natpisi dvojezični.', '["U", "dvojezični.", "su", "natpisi", "Istri"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dfdd2d6a-2e47-5e3c-a5e7-140033bc19be', 'sentence_builder', 'Складіть: «Мотовун відомий кінофестивалем.»', 'Motovun je poznat po filmskom festivalu.', '["filmskom", "festivalu.", "po", "poznat", "Motovun", "je"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf606d17-8747-5ec3-9497-0757a89a2133', 'listening', 'Прослухайте і складіть фразу', 'Po pogledu na dolinu i tartufima. I ručajte u nekom agroturizmu.', '["i", "ručajte", "u", "nekom", "na", "dolinu", "Po", "agroturizmu.", "I", "pogledu", "tartufima."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '56ae55a9-713d-5d0a-acc4-d9a2a40aa9f1', 'listening_dialogue', 'Прослухайте оголошення', '2; дегустація вина; близько 18:00', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Гід в автобусі розповідає про Істрію.", "script": [{"hr": "Dobro došli u Istru, najveći hrvatski poluotok!", "ua": "Ласкаво просимо в Істрію, найбільший хорватський півострів!"}, {"hr": "Prvo stajemo u Motovunu, gdje ćemo provesti dva sata.", "ua": "Спершу зупиняємося в Мотовуні, де проведемо дві години."}, {"hr": "Ručak je u agroturizmu, a poslije je kušanje vina.", "ua": "Обід у сільській садибі, а потім дегустація вина."}, {"hr": "U Rovinj stižemo oko šest navečer.", "ua": "У Ровінь приїжджаємо близько шостої вечора."}], "questions": [{"q_ua": "Скільки годин будуть у Мотовуні?", "answer_text": "2", "accept": ["дві", "дві години", "2 години"], "answer_turn": 1}, {"q_ua": "Що буде після обіду?", "options": ["дегустація вина", "екскурсія амфітеатром", "купання"], "correct": 0, "answer_turn": 2}, {"q_ua": "Коли приїдуть у Ровінь?", "options": ["о 16:00", "близько 18:00", "о 20:00"], "correct": 1, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '56ae55a9-713d-5d0a-acc4-d9a2a40aa9f1', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '20e4e76e-84ce-5387-bd9e-b4b934ab86e4', 'speaking', 'Чим відоме це місто?', 'Po čemu je poznat ovaj grad?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4c08224d-0031-5e5b-bb83-0eef7166ba40', 'speaking', 'Я хотіла б скуштувати істрійську манештру.', 'Htjela bih probati istarsku maneštru.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '08801841-1fb2-5a83-9f9b-1100f6c98f2c', 'write_message', 'Напишіть подрузі з Істрії: ви в Мотовуні, тут гарний вид на долину, а на обід — фужі з трюфелями.', 'Pozdrav iz Motovuna! Pogled na dolinu je prekrasan, a za ručak smo jeli fuže s tartufima.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі з Істрії: ви в Мотовуні, тут гарний вид на долину, а на обід — фужі з трюфелями.", "points": [{"ua": "ви в Мотовуні", "keys": [["motovun"]]}, {"ua": "вид на долину", "keys": [["dolin"]]}, {"ua": "фужі з трюфелями", "keys": [["fuž"], ["tartuf"]]}], "hints": ["pozdrav iz Motovuna", "pogled na dolinu", "za ručak fuži s tartufima"], "models": ["Pozdrav iz Motovuna! Pogled na dolinu je prekrasan, a za ručak smo jeli fuže s tartufima."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '08801841-1fb2-5a83-9f9b-1100f6c98f2c', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '61b4f6d7-770e-5d9a-bf07-5b63b4f5c206', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Možemo li kupiti maslinovo ulje i vino za ponijeti?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай господаря, чи можна купити в нього оливкову олію й вино з собою.", "direction": "ua_hr", "points": [{"ua": "купити", "keys": [["kupi"]]}, {"ua": "олію", "keys": [["ulj"]]}, {"ua": "вино", "keys": [["vin"]]}], "hints": [], "models": ["Možemo li kupiti maslinovo ulje i vino za ponijeti?"], "source_ua": "Спитай господаря, чи можна купити в нього оливкову олію й вино з собою."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '61b4f6d7-770e-5d9a-bf07-5b63b4f5c206', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('901816d9-4b24-5502-b329-f82ed5df6c32', v_lesson, 'Куди в Істрії?', 'Kamo u Istri?', 5661, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('0bc8a475-3670-56a9-aacd-0d09b4be4a47', '901816d9-4b24-5502-b329-f82ed5df6c32', 'Daša', 'Darja, idete li ovo ljeto u Istru?', 'Дар’є, ви їдете цього літа в Істрію?', 1);
  perform pg_temp.turn('3844956d-15a2-5864-b110-652993c62e68', '901816d9-4b24-5502-b329-f82ed5df6c32', 'Darja', 'Idemo! Što preporučuješ?', 'Їдемо! Що порадиш?', 2);
  perform pg_temp.turn('adabe06e-35c5-5509-a9b1-a8210f48dd6f', '901816d9-4b24-5502-b329-f82ed5df6c32', 'Daša', 'Rovinjske uličice, pulski amfiteatar i neki brdski gradić, recimo Motovun.', 'Ровіньські вулички, пульський амфітеатр і якесь містечко на пагорбі, наприклад, Мотовун.', 3);
  perform pg_temp.turn('741172be-d39f-5876-892f-b25d755cf2b3', '901816d9-4b24-5502-b329-f82ed5df6c32', 'Darja', 'Po čemu je Motovun poznat?', 'Чим відомий Мотовун?', 4);
  perform pg_temp.turn('82edfcaa-7ec4-53ee-b24d-c7493d0ac531', '901816d9-4b24-5502-b329-f82ed5df6c32', 'Daša', 'Po pogledu na dolinu i tartufima. I ručajte u nekom agroturizmu.', 'Видом на долину й трюфелями. І пообідайте в якійсь сільській садибі.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ea41902f-49ed-54ff-9f1e-f1784e1cdb91', v_lesson, 'В агротуризмі', 'U agroturizmu', 5662, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('be0aa262-0e8d-5a31-9300-19361dd62902', 'ea41902f-49ed-54ff-9f1e-f1784e1cdb91', 'Domaćin', 'Dobro došli! Danas imamo maneštru i fuže s tartufima.', 'Ласкаво просимо! Сьогодні маємо манештру й фужі з трюфелями.', 1);
  perform pg_temp.turn('4e61b215-4e74-5ab0-aea9-0abe1327ae95', 'ea41902f-49ed-54ff-9f1e-f1784e1cdb91', 'Ivan', 'Zvuči odlično. Što preporučujete za piće?', 'Звучить чудово. Що порадите з напоїв?', 2);
  perform pg_temp.turn('56644f11-a248-5e8a-8e50-efa18b23dbb4', 'ea41902f-49ed-54ff-9f1e-f1784e1cdb91', 'Domaćin', 'Našu malvaziju ili teran. Vino je iz našeg vinograda.', 'Нашу мальвазію або теран. Вино з нашого виноградника.', 3);
  perform pg_temp.turn('e3dbe423-7355-55ee-95ae-f102d20c54fe', 'ea41902f-49ed-54ff-9f1e-f1784e1cdb91', 'Ivan', 'Zašto su natpisi dvojezični?', 'Чому написи двомовні?', 4);
  perform pg_temp.turn('4ba65eeb-94f3-5367-ab8d-f1b762429aee', 'ea41902f-49ed-54ff-9f1e-f1784e1cdb91', 'Domaćin', 'U Istri živi talijanska manjina, pa je talijanski službeni jezik u nekim gradovima.', 'В Істрії живе італійська меншина, тож італійська — офіційна мова в деяких містах.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.11 · урок 67: Славонія — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '3fbc4d9b-4366-5f0f-b785-eb3f750240be';
  v_lesson constant uuid := '4bd3a563-65f6-596c-8f20-aabce6c7811f';
  v_gid constant uuid := '6da44157-69d7-5261-8289-fe910fd60f59';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики POSV'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A2.11: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 67: Славонія', 'Lekcija 67: Slavonija', '["Розповісти про Славонію: рівнини, кухня, тамбурашка музика", "Присвійні й прикметники від місць: slavonski, osječki, bakin kulen"]'::jsonb, 20, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'slavonski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osječki', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vukovarski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žitna polja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'suncokret', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kukuruz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fiš paprikaš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kotlić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šljivovica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svinjokolja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'berba grožđa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vinski podrum', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tamburaši', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bakin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Dunav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ravničarski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'salaš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lipicanac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gostoljubiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'domaća kobasica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pušnica', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '888f96a6-74c4-5625-97a2-a17b8cce52fc', 'fill_in_the_blank', 'Najbolji je ___ kulen, ona ga radi sama.', 'bakin', '["baka", "bake", "bakin", "bakina"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dab579b4-599a-5ce1-b59e-6e1be4ab1325', 'multiple_choice', 'Що означає «vinski podrum»?', 'винний льох', '["рівнинний", "бабусин", "фіш-паприкаш (рибна юшка з паприкою)", "винний льох"]'::jsonb, 'A2', 2, 'PUBLISHED', 'vinski podrum', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf24f052-288a-5ebc-a9a7-52c949dd50f4', 'multiple_choice', 'Що означає «salaš»?', 'хутір, сільська садиба (у рівнинах)', '["домашня ковбаса", "хутір, сільська садиба (у рівнинах)", "вуковарський", "бабусин"]'::jsonb, 'A2', 3, 'PUBLISHED', 'salaš', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e405b29e-120b-5c90-a24a-bf269add262c', 'multiple_choice', 'Що означає «ravničarski»?', 'рівнинний', '["бабусин", "рівнинний", "сливовиця (сливова ракія)", "збір винограду"]'::jsonb, 'A2', 4, 'PUBLISHED', 'ravničarski', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd4000a6f-d93a-5339-9bd1-28f1d52cfe0f', 'multiple_choice', 'Як хорватською «бабусин»?', 'bakin', '["šljivovica", "kukuruz", "bakin", "pušnica"]'::jsonb, 'A2', 5, 'PUBLISHED', 'bakin', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0869c9f8-7ec5-5380-af09-6afd932543b0', 'multiple_choice', 'Як хорватською «тамбураші (музиканти)»?', 'tamburaši', '["lipicanac", "tamburaši", "svinjokolja", "berba grožđa"]'::jsonb, 'A2', 6, 'PUBLISHED', 'tamburaši', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ee77f325-f63f-5c27-8a3a-1f14a070cbe6', 'type_answer', 'Напишіть хорватською: «кукурудза»', 'kukuruz', null, 'A2', 7, 'PUBLISHED', 'kukuruz', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '084454f8-bd49-5629-b859-a742313579d2', 'type_answer', 'Напишіть хорватською: «ліпіцанер (порода коней)»', 'lipicanac', null, 'A2', 8, 'PUBLISHED', 'lipicanac', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '62fdf650-6aed-526f-8edf-270f3b14b747', 'type_answer', 'Напишіть хорватською: «свіжування свині (зимове свято)»', 'svinjokolja', null, 'A2', 9, 'PUBLISHED', 'svinjokolja', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '809d5b07-c075-5cb7-9050-1b8aea9686ba', 'sentence_builder', 'Складіть: «Вуковар лежить на Дунаї.»', 'Vukovar leži na Dunavu.', '["leži", "Dunavu.", "na", "Vukovar"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2382494e-6279-59af-aedc-b626c8b5ba80', 'sentence_builder', 'Складіть: «Славонці дуже гостинні.»', 'Slavonci su vrlo gostoljubivi.', '["su", "Slavonci", "vrlo", "gostoljubivi."]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5112bfa7-9a79-53f8-8b0d-b6f44fbfc15a', 'listening', 'Прослухайте і складіть фразу', 'Tako je to u Slavoniji. Navečer dolaze tamburaši.', '["u", "Tako", "tamburaši.", "to", "Slavoniji.", "Navečer", "je", "dolaze"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '14514895-9d5e-5d9f-861d-839cc8328890', 'listening_dialogue', 'Прослухайте новину', 'у Джакові; 20; хода коней-ліпіцанерів', 'A2', 'PUBLISHED', '{"kind": "news", "situation_ua": "Ви слухаєте новину з фестивалю в Славонії.", "script": [{"hr": "U Đakovu su ovaj vikend Đakovački vezovi, festival folklora.", "ua": "У Джакові цими вихідними «Джаковецькі вишивки», фольклорний фестиваль."}, {"hr": "Nastupa više od dvadeset folklornih skupina i tamburaških orkestara.", "ua": "Виступає понад двадцять фольклорних колективів і тамбурашких оркестрів."}, {"hr": "U nedjelju je i povorka konja lipicanaca.", "ua": "У неділю ще й хода коней-ліпіцанерів."}], "questions": [{"q_ua": "Де фестиваль?", "options": ["у Джакові", "в Осієку", "у Вуковарі"], "correct": 0, "answer_turn": 0}, {"q_ua": "Скільки колективів виступає (понад…)?", "answer_text": "20", "accept": ["двадцять", "понад 20"], "answer_turn": 1}, {"q_ua": "Що буде в неділю?", "options": ["дегустація вина", "хода коней-ліпіцанерів", "концерт клапи"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '14514895-9d5e-5d9f-861d-839cc8328890', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3240710a-38ea-58d5-853a-fd345745458b', 'speaking', 'Поля соняшнику нагадують мені Україну.', 'Polja suncokreta podsjećaju me na Ukrajinu.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7b081581-a984-568f-b079-573f18952a1b', 'speaking', 'Бабусин кулен найкращий.', 'Bakin kulen je najbolji.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '2f08d3ad-1b2f-51d0-a582-dba853aa66e4', 'write_message', 'Напишіть другові зі Славонії: поля нагадують Україну, а господарі на салаші дуже гостинні.', 'Pozdrav iz Slavonije! Polja me podsjećaju na Ukrajinu, a domaćini na salašu su vrlo gostoljubivi.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть другові зі Славонії: поля нагадують Україну, а господарі на салаші дуже гостинні.", "points": [{"ua": "поля", "keys": [["polj"]]}, {"ua": "нагадують Україну", "keys": [["ukrajin"]]}, {"ua": "гостинні", "keys": [["gostoljubiv"]]}], "hints": ["pozdrav iz Slavonije", "polja me podsjećaju na Ukrajinu", "domaćini su gostoljubivi"], "models": ["Pozdrav iz Slavonije! Polja me podsjećaju na Ukrajinu, a domaćini na salašu su vrlo gostoljubivi."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '2f08d3ad-1b2f-51d0-a582-dba853aa66e4', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'c6a3edbe-0661-57e8-b6ff-8a08a4df1a0a', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'I u Ukrajini se kuha juha u kotliću na vatri.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи господині, що в Україні теж варять юшку в казанку на вогні.", "direction": "ua_hr", "points": [{"ua": "в Україні теж", "keys": [["ukrajin"]]}, {"ua": "юшка", "keys": [["juh"]]}, {"ua": "казанок", "keys": [["kotlić"]]}], "hints": [], "models": ["I u Ukrajini se kuha juha u kotliću na vatri."], "source_ua": "Скажи господині, що в Україні теж варять юшку в казанку на вогні."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'c6a3edbe-0661-57e8-b6ff-8a08a4df1a0a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8af96e36-7cf8-5c19-931e-dbfea4af1d55', v_lesson, 'Поля, як удома', 'Polja kao kod kuće', 5671, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('3877c9f1-4493-52e3-ae11-689ca4f18403', '8af96e36-7cf8-5c19-931e-dbfea4af1d55', 'Darja', 'Kad sam prvi put vidjela Slavoniju, mislila sam da sam u Ukrajini.', 'Коли я вперше побачила Славонію, подумала, що я в Україні.', 1);
  perform pg_temp.turn('8b7c15aa-836d-5dc8-87af-95016d3b607e', '8af96e36-7cf8-5c19-931e-dbfea4af1d55', 'Ivana', 'Zbog ravnice?', 'Через рівнину?', 2);
  perform pg_temp.turn('dbb32827-6c71-5059-87d3-ceac7efc1428', '8af96e36-7cf8-5c19-931e-dbfea4af1d55', 'Darja', 'Da! Žitna polja, suncokret, kukuruz... Ravničarski krajolik je isti.', 'Так! Хлібні поля, соняшник, кукурудза... Рівнинний краєвид такий самий.', 3);
  perform pg_temp.turn('e55d6d98-9958-5ee0-b6f8-6ee9c7540741', '8af96e36-7cf8-5c19-931e-dbfea4af1d55', 'Ivana', 'A hrana? Slavonski kulen i fiš paprikaš?', 'А їжа? Славонський кулен і фіш-паприкаш?', 4);
  perform pg_temp.turn('3a739000-3a67-5ca3-9e84-3479c3e48580', '8af96e36-7cf8-5c19-931e-dbfea4af1d55', 'Darja', 'Fiš paprikaš je kao naša juha, samo ljući!', 'Фіш-паприкаш — як наша юшка, тільки гостріший!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a0280e79-456d-5bb6-93aa-c12f292d0773', v_lesson, 'На салаші', 'Na salašu', 5672, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('196a1618-e545-5219-bfe4-30919dcd718c', 'a0280e79-456d-5bb6-93aa-c12f292d0773', 'Domaćica', 'Dobro došli! Izvolite domaću kobasicu iz pušnice i bakin kulen.', 'Ласкаво просимо! Прошу, домашня ковбаса з коптильні й бабусин кулен.', 1);
  perform pg_temp.turn('941003ca-f725-50fb-9163-9bb8b6dee73d', 'a0280e79-456d-5bb6-93aa-c12f292d0773', 'Ivan', 'Hvala, jako ste gostoljubivi.', 'Дякую, ви дуже гостинні.', 2);
  perform pg_temp.turn('49d95ffd-ddd1-5be0-8be1-fedfe9bda4dc', 'a0280e79-456d-5bb6-93aa-c12f292d0773', 'Domaćica', 'Tako je to u Slavoniji. Navečer dolaze tamburaši.', 'Так у Славонії заведено. Увечері прийдуть тамбураші.', 3);
  perform pg_temp.turn('7dc6bc05-5c45-5f46-b4c4-1a005e85751b', 'a0280e79-456d-5bb6-93aa-c12f292d0773', 'Ivan', 'Kada je ovdje berba grožđa?', 'Коли тут збір винограду?', 4);
  perform pg_temp.turn('b5c29bf2-190b-53df-a1cf-f726d1409439', 'a0280e79-456d-5bb6-93aa-c12f292d0773', 'Domaćica', 'U rujnu. Dođite onda, vidjet ćete iločki vinski podrum.', 'У вересні. Приїжджайте тоді, побачите ілоцький винний льох.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.11 · урок 68: Ліка й Горський Котар — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '3fbc4d9b-4366-5f0f-b785-eb3f750240be';
  v_lesson constant uuid := 'ab060253-8099-5e7d-bfaa-1b1a7655c229';
  v_gid constant uuid := '6da44157-69d7-5261-8289-fe910fd60f59';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики POSV'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A2.11: місце 3 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 68: Ліка й Горський Котар', 'Lekcija 68: Lika i Gorski kotar', '["Розповісти про гірські краї: природа, тварини, зима", "Прикметники від місць: lički, goranski, velebitski"]'::jsonb, 20, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'lički', v_pos);
  v_pos := pg_temp.word(v_lesson, 'goranski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'velebitski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gorje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrh', v_pos);
  v_pos := pg_temp.word(v_lesson, 'planinarska staza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'planinarska kuća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'markacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jelova šuma', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smeđi medvjed', v_pos);
  v_pos := pg_temp.word(v_lesson, 'divljač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'špilja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oštra zima', v_pos);
  v_pos := pg_temp.word(v_lesson, 'snježni nanosi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skijalište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sanjkati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rijetko naseljen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iseljavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'netaknuta priroda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'planinarski vodič', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '603e8d2c-ab84-5416-9da8-5ffc9620cec0', 'fill_in_the_blank', '___ šume su guste i tamne.', 'Goranske', '["Gorani", "Goranske", "Gorskog", "Gorski"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b510fd8a-cd00-5843-b887-b9ac81b28374', 'multiple_choice', 'Що означає «planinarska kuća»?', 'гірський притулок', '["вершина", "горанський (з Горського Котару)", "карст", "гірський притулок"]'::jsonb, 'A2', 2, 'PUBLISHED', 'planinarska kuća', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '31e2e2a6-ab27-5a29-9971-2eab968166b7', 'multiple_choice', 'Що означає «jelova šuma»?', 'ялицевий ліс', '["гірський гід; путівник для туристів", "маркування (стежки)", "ялицевий ліс", "печера"]'::jsonb, 'A2', 3, 'PUBLISHED', 'jelova šuma', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f929d9a8-3357-5b74-99de-4edfcf3b9e0d', 'multiple_choice', 'Що означає «lički»?', 'ліцький (з Ліки)', '["ліцький (з Ліки)", "сувора зима", "бурий ведмідь", "малонаселений"]'::jsonb, 'A2', 4, 'PUBLISHED', 'lički', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '86933219-7135-53e1-bed5-c9b965246f47', 'multiple_choice', 'Як хорватською «снігові замети»?', 'snježni nanosi', '["snježni nanosi", "vrh", "skijalište", "rijetko naseljen"]'::jsonb, 'A2', 5, 'PUBLISHED', 'snježni nanosi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd630d54b-d825-571f-8c54-53b3818591fd', 'multiple_choice', 'Як хорватською «горанський (з Горського Котару)»?', 'goranski', '["goranski", "špilja", "snježni nanosi", "planinarska staza"]'::jsonb, 'A2', 6, 'PUBLISHED', 'goranski', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b84e1f77-dbdc-53ed-812b-996e361fd43b', 'type_answer', 'Напишіть хорватською: «велебітський»', 'velebitski', null, 'A2', 7, 'PUBLISHED', 'velebitski', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '145b2e2e-c8a9-590e-8dd4-a9448ad1e05f', 'type_answer', 'Напишіть хорватською: «вершина»', 'vrh', null, 'A2', 8, 'PUBLISHED', 'vrh', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f9f06945-4509-5ae1-a3c4-8559f2ce3de0', 'type_answer', 'Напишіть хорватською: «дичина»', 'divljač', null, 'A2', 9, 'PUBLISHED', 'divljač', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ea1a41e2-9692-5c51-941e-6b0650e5e064', 'sentence_builder', 'Складіть: «Ідемо за червоно-білим маркуванням.»', 'Pratimo crveno-bijele markacije.', '["crveno-bijele", "Pratimo", "markacije."]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '22711c6f-b85f-546d-8da1-094949412326', 'sentence_builder', 'Складіть: «Ліка — малонаселений край.»', 'Lika je rijetko naseljen kraj.', '["Lika", "rijetko", "kraj.", "naseljen", "je"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a9a3f68-b632-5355-a5b8-e844913f5658', 'listening', 'Прослухайте і складіть фразу', 'Ima, malo skijalište u Platku. A djeca se mogu sanjkati.', '["Ima,", "sanjkati.", "skijalište", "malo", "Platku.", "djeca", "se", "mogu", "A", "u"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'f5d8ac8c-5c2f-5237-8d1f-c562a689bc75', 'listening_dialogue', 'Прослухайте прогноз', '20; до −8; про ожеледицю й замети', 'A2', 'PUBLISHED', '{"kind": "forecast", "situation_ua": "Прогноз погоди для гірських районів.", "script": [{"hr": "U Lici i Gorskom kotaru noćas se očekuje snijeg, do dvadeset centimetara.", "ua": "У Ліці й Горському Котарі сьогодні вночі очікується сніг, до двадцяти сантиметрів."}, {"hr": "Temperatura će pasti do minus osam.", "ua": "Температура впаде до мінус восьми."}, {"hr": "Vozače upozoravamo na poledicu i snježne nanose.", "ua": "Попереджаємо водіїв про ожеледицю й снігові замети."}], "questions": [{"q_ua": "Скільки снігу очікується (см)?", "answer_text": "20", "accept": ["двадцять", "до 20"], "answer_turn": 0}, {"q_ua": "До скількох градусів упаде температура?", "options": ["до −8", "до −2", "до −18"], "correct": 0, "answer_turn": 1}, {"q_ua": "Про що попереджають водіїв?", "options": ["про ремонт доріг", "про ожеледицю й замети", "про туман"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'f5d8ac8c-5c2f-5237-8d1f-c562a689bc75', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c4b2d924-1133-5dfb-b8c9-1c2c9e9e9cb1', 'speaking', 'Стежка добре позначена?', 'Je li staza dobro označena?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '72ca9ec0-d9f4-526b-a71e-9d5fdbaad784', 'speaking', 'Тут свіже повітря й тиша.', 'Ovdje je svježi zrak i mir.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '896060da-c39c-50af-9845-606bc0648cfe', 'write_message', 'Напишіть подрузі: на вихідних ви йдете в гори на Велебіт, ночуватимете в притулку; запросіть її.', 'Vikendom idemo na Velebit i spavamo u planinarskoj kući. Ideš s nama?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі: на вихідних ви йдете в гори на Велебіт, ночуватимете в притулку; запросіть її.", "points": [{"ua": "гори / Велебіт", "keys": [["velebit"], ["planin"]]}, {"ua": "ночувати в притулку", "keys": [["planinarsk"], ["spav"]]}, {"ua": "запросіть", "keys": [["ideš"], ["dođi"], ["s nama"]]}], "hints": ["vikendom idemo na Velebit", "spavamo u planinarskoj kući", "ideš s nama?"], "models": ["Vikendom idemo na Velebit i spavamo u planinarskoj kući. Ideš s nama?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '896060da-c39c-50af-9845-606bc0648cfe', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '05055c32-93da-5e9c-a909-734455a71c87', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Je li staza do vrha sigurna i koliko se dugo hoda?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай господаря притулку, чи безпечна стежка до вершини і скільки часу йти.", "direction": "ua_hr", "points": [{"ua": "безпечна стежка", "keys": [["sigurn"], ["staz"]]}, {"ua": "вершина", "keys": [["vrh"]]}, {"ua": "скільки йти", "keys": [["koliko"], ["traje"], ["sat"]]}], "hints": [], "models": ["Je li staza do vrha sigurna i koliko se dugo hoda?"], "source_ua": "Спитай господаря притулку, чи безпечна стежка до вершини і скільки часу йти."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '05055c32-93da-5e9c-a909-734455a71c87', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('fc8d293f-ae7b-51f3-8d3b-00631ee3094f', v_lesson, 'Похід на Велебіт', 'Na Velebit', 5681, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('6de9b0e8-0c73-56b0-9abc-a6dfa93cc2e8', 'fc8d293f-ae7b-51f3-8d3b-00631ee3094f', 'Marko', 'Ovaj vikend idemo na Velebit. Ideš s nama?', 'Цими вихідними йдемо на Велебіт. Підеш з нами?', 1);
  perform pg_temp.turn('88c477cd-ed17-5a7a-862a-0f89f35fb1d1', 'fc8d293f-ae7b-51f3-8d3b-00631ee3094f', 'Darja', 'Rado! Je li staza teška?', 'Охоче! Стежка важка?', 2);
  perform pg_temp.turn('44ec275c-0949-5300-b399-7aedb6382b39', 'fc8d293f-ae7b-51f3-8d3b-00631ee3094f', 'Marko', 'Nije, planinarska staza je dobro označena. Pratimo crveno-bijele markacije.', 'Ні, туристична стежка добре позначена. Ідемо за червоно-білим маркуванням.', 3);
  perform pg_temp.turn('87ac16b0-91b8-59f4-bc5f-b9f2570e04dd', 'fc8d293f-ae7b-51f3-8d3b-00631ee3094f', 'Darja', 'Gdje spavamo?', 'Де ночуємо?', 4);
  perform pg_temp.turn('9cc683c2-9eb3-5ba8-a98a-e42c0ce3d205', 'fc8d293f-ae7b-51f3-8d3b-00631ee3094f', 'Marko', 'U planinarskoj kući ispod vrha. Velebitski pogled na more je nevjerojatan.', 'У гірському притулку під вершиною. Велебітський вид на море неймовірний.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('dad647cd-914e-55dd-a213-20df3d9fc1cf', v_lesson, 'Зима в Горському Котарі', 'Zima u Gorskom kotaru', 5682, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('d8a6046a-4abc-5583-9999-c1d178cdf53f', 'dad647cd-914e-55dd-a213-20df3d9fc1cf', 'Ivan', 'Kakve su zime u Gorskom kotaru?', 'Які зими в Горському Котарі?', 1);
  perform pg_temp.turn('bbdfeb04-4620-5c71-9a4c-2daa0f32b43f', 'dad647cd-914e-55dd-a213-20df3d9fc1cf', 'Daša', 'Oštre, s puno snijega. Ponekad su ceste zatvorene zbog snježnih nanosa.', 'Суворі, з великою кількістю снігу. Іноді дороги закриті через снігові замети.', 2);
  perform pg_temp.turn('5c2cbfae-ab40-5229-b3f9-d2a8fd0c7bb6', 'dad647cd-914e-55dd-a213-20df3d9fc1cf', 'Ivan', 'Ima li skijališta?', 'Є лижні схили?', 3);
  perform pg_temp.turn('0c39c50f-82fe-5c7d-bc5d-94014a8331ec', 'dad647cd-914e-55dd-a213-20df3d9fc1cf', 'Daša', 'Ima, malo skijalište u Platku. A djeca se mogu sanjkati.', 'Є, невеликий схил у Платаку. А діти можуть кататися на санчатах.', 4);
  perform pg_temp.turn('169a7988-df66-5646-8e98-a69f89008804', 'dad647cd-914e-55dd-a213-20df3d9fc1cf', 'Ivan', 'A medvjedi?', 'А ведмеді?', 5);
  perform pg_temp.turn('8d03ae19-e834-5232-bd59-5e3d79b2c721', 'dad647cd-914e-55dd-a213-20df3d9fc1cf', 'Daša', 'Smeđi medvjed zimi spava. Ne brini!', 'Бурий ведмідь узимку спить. Не хвилюйся!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.11 · урок 69: Загреб і Загор’є — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '3fbc4d9b-4366-5f0f-b785-eb3f750240be';
  v_lesson constant uuid := 'a312ce34-22d7-56e3-a38e-106205ee21c0';
  v_gid constant uuid := '6da44157-69d7-5261-8289-fe910fd60f59';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики POSV'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A2.11: місце 4 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 69: Загреб і Загор’є', 'Lekcija 69: Zagreb i Zagorje', '["Розповісти про Загреб і Загор’є: Верхнє місто, замки, традиції", "Прикметники від місць: zagrebački, zagorski; присвійні: Tesline ulice"]'::jsonb, 20, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zagrebački', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zagorski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Gornji grad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Donji grad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uspinjača', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tržnica Dolac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sir i vrhnje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'licitarsko srce', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dvorac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brežuljak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kajkavski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'purica s mlincima', v_pos);
  v_pos := pg_temp.word(v_lesson, 'topličko kupalište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'termalna voda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'advent', v_pos);
  v_pos := pg_temp.word(v_lesson, 'božićni sajam', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kuhano vino', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Teslina ulica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glavni grad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prigradski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gradska četvrt', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '7f2b6fad-2a8f-5fc3-bf94-ddc953b41cea', 'fill_in_the_blank', 'Na Dolcu sam kupila ___ sir i vrhnje.', 'zagrebački', '["zagrebačka", "zagrebački", "Zagreba", "Zagreb"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b6560272-6f12-593f-8b13-6a6a40fbd1da', 'multiple_choice', 'Що означає «termalna voda»?', 'термальна вода', '["термальна вода", "міський район", "різдвяний ярмарок", "Верхнє місто (Загреб)"]'::jsonb, 'A2', 2, 'PUBLISHED', 'termalna voda', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ffca3bde-b433-5a5c-b7a2-306800084411', 'multiple_choice', 'Що означає «dvorac»?', 'замок, палац', '["глінтвейн", "приміський", "Нижнє місто (Загреб)", "замок, палац"]'::jsonb, 'A2', 3, 'PUBLISHED', 'dvorac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '13323b4c-13a2-5e7f-a1c5-362dbf32e091', 'multiple_choice', 'Що означає «Donji grad»?', 'Нижнє місто (Загреб)', '["фунікулер", "Нижнє місто (Загреб)", "індичка з млинцями", "сир зі сметаною"]'::jsonb, 'A2', 4, 'PUBLISHED', 'Donji grad', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '82d51509-f144-562c-9664-0f2b1a96a87a', 'multiple_choice', 'Як хорватською «різдвяний ярмарок»?', 'božićni sajam', '["topličko kupalište", "Donji grad", "božićni sajam", "kajkavski"]'::jsonb, 'A2', 5, 'PUBLISHED', 'božićni sajam', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '18cc48ce-6fd8-5031-939e-9a800630b5c0', 'multiple_choice', 'Як хорватською «глінтвейн»?', 'kuhano vino', '["prigradski", "kuhano vino", "Gornji grad", "tržnica Dolac"]'::jsonb, 'A2', 6, 'PUBLISHED', 'kuhano vino', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '01ad39d2-427b-5c13-a1fb-a5f70dc51f78', 'type_answer', 'Напишіть хорватською: «вулиця Тесли»', 'Teslina ulica', null, 'A2', 7, 'PUBLISHED', 'Teslina ulica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0b5c901b-b045-5a9f-a9e9-0c64b63c30df', 'type_answer', 'Напишіть хорватською: «загребський»', 'zagrebački', null, 'A2', 8, 'PUBLISHED', 'zagrebački', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1ab4a49a-44a5-54fc-8590-9f3957cdc5ba', 'type_answer', 'Напишіть хорватською: «загорський (із Загор’я)»', 'zagorski', null, 'A2', 9, 'PUBLISHED', 'zagorski', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c30d2b3-c985-5ba6-8478-862635e96bbb', 'sentence_builder', 'Складіть: «На Верхнє місто їдемо фунікулером.»', 'Na Gornji grad idemo uspinjačom.', '["grad", "Na", "uspinjačom.", "idemo", "Gornji"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '84e1c496-1bfc-51d2-a520-32bb447fe96e', 'sentence_builder', 'Складіть: «У Загор’ї багато замків.»', 'U Zagorju ima puno dvoraca.', '["Zagorju", "puno", "dvoraca.", "U", "ima"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '56413671-af62-5d4b-940f-4eeb31cc4d41', 'listening', 'Прослухайте і складіть фразу', 'Licitarsko srce, to je zagrebački simbol.', '["simbol.", "Licitarsko", "srce,", "zagrebački", "je", "to"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '7e97c574-d173-5736-8b6b-39f8d5eaa958', 'listening_dialogue', 'Прослухайте оголошення', '23; на площі короля Томіслава; на головній площі', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Оголошення на загребському різдвяному ярмарку.", "script": [{"hr": "Dobro došli na Advent u Zagrebu!", "ua": "Ласкаво просимо на Адвент у Загребі!"}, {"hr": "Božićni sajam na Zrinjevcu otvoren je svaki dan do dvadeset tri sata.", "ua": "Різдвяний ярмарок на Зриньєваці відкритий щодня до двадцять третьої."}, {"hr": "Klizalište je na Trgu kralja Tomislava, a koncerti su na glavnom trgu.", "ua": "Ковзанка — на площі короля Томіслава, а концерти — на головній площі."}], "questions": [{"q_ua": "До котрої відкритий ярмарок?", "answer_text": "23", "accept": ["23:00", "23.00", "двадцять третьої"], "answer_turn": 1}, {"q_ua": "Де ковзанка?", "options": ["на площі короля Томіслава", "на Зриньєваці", "на головній площі"], "correct": 0, "answer_turn": 2}, {"q_ua": "Де концерти?", "options": ["на Долаці", "на головній площі", "у Верхньому місті"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '7e97c574-d173-5736-8b6b-39f8d5eaa958', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0dcd3781-ef2d-5478-839e-e1a5521475d1', 'speaking', 'Що показати мамі в Загребі?', 'Što da pokažem mami u Zagrebu?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4c464ec8-d0a4-55a0-a184-d730e486bf68', 'speaking', 'Я купила ліцитарське серце на пам’ять.', 'Kupila sam licitarsko srce za uspomenu.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '4e3eddb4-75f6-549d-8fff-cec19ebd4e67', 'write_message', 'Порадьте подрузі, що подивитися в Загребі за один день: ринок, Верхнє місто й що скуштувати.', 'Počni na tržnici Dolac, pa idi uspinjačom na Gornji grad. Za ručak probaj zagorske štrukle!', 'A2', 'PUBLISHED', '{"situation_ua": "Порадьте подрузі, що подивитися в Загребі за один день: ринок, Верхнє місто й що скуштувати.", "points": [{"ua": "ринок", "keys": [["tržnic"], ["dolac"], ["dolc"]]}, {"ua": "Верхнє місто", "keys": [["gornji grad"]]}, {"ua": "що скуштувати", "keys": [["prob"], ["štrukl"], ["sir"]]}], "hints": ["počni na tržnici Dolac", "uspinjačom na Gornji grad", "probaj štrukle"], "models": ["Počni na tržnici Dolac, pa idi uspinjačom na Gornji grad. Za ručak probaj zagorske štrukle!"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '4e3eddb4-75f6-549d-8fff-cec19ebd4e67', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '7f686c90-5ff8-5508-8479-05af1b5f108b', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Koliko koštaju ulaznice za dvije odrasle osobe i jedno dijete?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай на касі, скільки коштує квиток на термальний курорт для двох дорослих і дитини.", "direction": "ua_hr", "points": [{"ua": "квиток", "keys": [["ulaznic"], ["kart"]]}, {"ua": "двоє дорослих", "keys": [["odrasl"]]}, {"ua": "дитина", "keys": [["dijete"], ["djet"]]}], "hints": [], "models": ["Koliko koštaju ulaznice za dvije odrasle osobe i jedno dijete?"], "source_ua": "Спитай на касі, скільки коштує квиток на термальний курорт для двох дорослих і дитини."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '7f686c90-5ff8-5508-8479-05af1b5f108b', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('628b5bb0-1a11-546f-94ea-070db3ff475a', v_lesson, 'Загреб за один день', 'Zagreb u jednom danu', 5691, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('09f8c747-0e18-5164-bd04-219d9c38ada5', '628b5bb0-1a11-546f-94ea-070db3ff475a', 'Daša', 'Moja mama dolazi u Zagreb na jedan dan. Što da joj pokažem?', 'Моя мама приїжджає до Загреба на один день. Що їй показати?', 1);
  perform pg_temp.turn('5b7e2a9a-2c47-5168-80f9-f0dfd20c7ced', '628b5bb0-1a11-546f-94ea-070db3ff475a', 'Ivan', 'Počnite na tržnici Dolac, pa uspinjačom na Gornji grad.', 'Почніть із ринку Долац, а потім фунікулером на Верхнє місто.', 2);
  perform pg_temp.turn('39dac8dd-d416-5e1b-b9f9-7a2b655b6e27', '628b5bb0-1a11-546f-94ea-070db3ff475a', 'Daša', 'A što da jede?', 'А що їй з’їсти?', 3);
  perform pg_temp.turn('414896e1-73d6-59c1-bf30-907c2eeef12d', '628b5bb0-1a11-546f-94ea-070db3ff475a', 'Ivan', 'Sir i vrhnje na tržnici i zagorske štrukle za ručak.', 'Сир зі сметаною на ринку й загорські штруклі на обід.', 4);
  perform pg_temp.turn('08902aab-c28f-5b6b-bc2b-6a2342acc58c', '628b5bb0-1a11-546f-94ea-070db3ff475a', 'Daša', 'Super. A za uspomenu?', 'Супер. А на пам’ять?', 5);
  perform pg_temp.turn('48039421-8002-5137-8257-07a6efe28ba3', '628b5bb0-1a11-546f-94ea-070db3ff475a', 'Ivan', 'Licitarsko srce, to je zagrebački simbol.', 'Ліцитарське серце, це символ Загреба.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d909c0d8-345d-569b-8c87-01b00a1d5b36', v_lesson, 'Вихідні в Загор’ї', 'Vikend u Zagorju', 5692, 'A2', 'travel', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('13000efd-ff2e-5d35-9fde-c887e383738a', 'd909c0d8-345d-569b-8c87-01b00a1d5b36', 'Darja', 'Gdje ste bili vikendom?', 'Де ви були на вихідних?', 1);
  perform pg_temp.turn('b1bedc68-209b-5acb-8d2c-76c6381e9424', 'd909c0d8-345d-569b-8c87-01b00a1d5b36', 'Marko', 'U Zagorju. Posjetili smo dvorac Trakošćan i bili na topličkom kupalištu.', 'У Загор’ї. Відвідали замок Тракошчан і були на термальному курорті.', 2);
  perform pg_temp.turn('43999198-f2ff-5a60-9dcc-8f49103e6dca', 'd909c0d8-345d-569b-8c87-01b00a1d5b36', 'Darja', 'Je li daleko od Zagreba?', 'Це далеко від Загреба?', 3);
  perform pg_temp.turn('047e7d3d-fa23-5c44-bbef-56c1529fa25f', 'd909c0d8-345d-569b-8c87-01b00a1d5b36', 'Marko', 'Sat vremena. Brežuljci, vinogradi, a bake govore kajkavski.', 'Годину. Пагорби, виноградники, а бабусі говорять кайкавською.', 4);
  perform pg_temp.turn('4abd0a14-af8a-5d88-bea2-6e983e1564c4', 'd909c0d8-345d-569b-8c87-01b00a1d5b36', 'Darja', 'Razumiješ li kajkavski?', 'Ти розумієш кайкавську?', 5);
  perform pg_temp.turn('f4bce246-1a4e-52bd-9484-3b07caaa420b', 'd909c0d8-345d-569b-8c87-01b00a1d5b36', 'Marko', 'Ponekad. Ali purica s mlincima je svima razumljiva!', 'Іноді. Але індичку з млинцями всі розуміють!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.11 · урок 70: Звичаї й етикет: як поводитися — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '3fbc4d9b-4366-5f0f-b785-eb3f750240be';
  v_lesson constant uuid := '7d3c3501-a381-5b3c-a0a2-b269f3dff137';
  v_gid constant uuid := '6da44157-69d7-5261-8289-fe910fd60f59';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики POSV'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A2.11: місце 5 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 70: Звичаї й етикет: як поводитися', 'Lekcija 70: Običaji i bonton: kako se ponašati', '["Знати, як поводитися в гостях, на каві, у церкві й на роботі", "Присвійні: domaćičin kolač, Ivanov rođendan, tuđa kuća"]'::jsonb, 20, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'bonton', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pristojno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nepristojno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poljubiti u obraz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'papuče za goste', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obiteljsko okupljanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'domaćičin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obiteljski ručak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pomalo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'persirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tikati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispijati kavu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'riva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'običaj je', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poziv na kavu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poslužiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponašati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lijepo ponašanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kavanska kultura', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gostovanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poklon za domaćina', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '02547557-6ebf-5253-8e55-b23788d4a331', 'fill_in_the_blank', 'Pohvalite ___ kolač, ona ga je pekla cijelo jutro.', 'domaćičin', '["domaćin", "domaćica", "domaćice", "domaćičin"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ca705c64-affc-5496-a773-f50f593427dd', 'multiple_choice', 'Що означає «lijepo ponašanje»?', 'гарна поведінка', '["набережна (у приморському місті)", "заведено (звичай)", "гарна поведінка", "подарунок господарю"]'::jsonb, 'A2', 2, 'PUBLISHED', 'lijepo ponašanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd56f6826-a82a-5706-90a5-d82c3a4ff5ad', 'multiple_choice', 'Що означає «kavanska kultura»?', 'культура кав’ярень', '["культура кав’ярень", "гостини, візит", "нечемно, непристойно", "запрошення на каву"]'::jsonb, 'A2', 3, 'PUBLISHED', 'kavanska kultura', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a8e94812-7fd9-595a-8a84-a8298c751f7f', 'multiple_choice', 'Що означає «papuče za goste»?', 'капці для гостей', '["сімейний обід", "чемно, пристойно", "капці для гостей", "поводитися"]'::jsonb, 'A2', 4, 'PUBLISHED', 'papuče za goste', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b5e3eafd-892e-5103-8766-4aeb2dea9cd5', 'multiple_choice', 'Як хорватською «чемно, пристойно»?', 'pristojno', '["obiteljsko okupljanje", "pristojno", "poziv na kavu", "lijepo ponašanje"]'::jsonb, 'A2', 5, 'PUBLISHED', 'pristojno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ac63dcc6-07ed-52ee-9fe9-2d1cca943e93', 'multiple_choice', 'Як хорватською «заведено (звичай)»?', 'običaj je', '["običaj je", "poljubiti u obraz", "poslužiti", "ispijati kavu"]'::jsonb, 'A2', 6, 'PUBLISHED', 'običaj je', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cc2f4f4f-6d14-5951-92c9-6006412adf29', 'type_answer', 'Напишіть хорватською: «нечемно, непристойно»', 'nepristojno', null, 'A2', 7, 'PUBLISHED', 'nepristojno', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f2b19fe9-3935-5bca-9a46-2edb6c23240b', 'type_answer', 'Напишіть хорватською: «поводитися»', 'ponašati se', null, 'A2', 8, 'PUBLISHED', 'ponašati se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '24ed2b11-efe6-5aca-96f0-dd90b8b07bd0', 'type_answer', 'Напишіть хорватською: «гостини, візит»', 'gostovanje', null, 'A2', 9, 'PUBLISHED', 'gostovanje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6f53fde5-a22a-5f71-b096-db6426ac1c45', 'sentence_builder', 'Складіть: «У чужому домі поводимося чемно.»', 'U tuđoj kući se ponašamo pristojno.', '["se", "kući", "pristojno.", "tuđoj", "ponašamo", "U"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6fd9f1b0-355e-527e-8e71-7c20171f3e72', 'sentence_builder', 'Складіть: «До старших звертаються на «ви».»', 'Starijima se persira.', '["persira.", "se", "Starijima"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '43d1d05c-4478-5f99-aa80-cc05c0e66524', 'listening', 'Прослухайте і складіть фразу', 'Teško. Uzmi barem mali komad, to je pristojno.', '["pristojno.", "to", "barem", "komad,", "Uzmi", "mali", "Teško.", "je"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '70c2ff70-2b33-569b-a0aa-662dd4fbe4db', 'listening_dialogue', 'Прослухайте розмову', 'на «ти»; тістечка', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Дар’я питає колегу про звичаї на роботі.", "script": [{"speaker": "Darja", "hr": "Mogu li šefa zvati imenom?", "ua": "Чи можу я звертатися до шефа на ім’я?"}, {"speaker": "Kolegica", "hr": "Ovdje da, svi se tikamo, i on.", "ua": "Тут так, ми всі на «ти», і він теж."}, {"speaker": "Darja", "hr": "A kad netko ima rođendan?", "ua": "А коли в когось день народження?"}, {"speaker": "Kolegica", "hr": "On donosi kolače za sve. Takav je običaj.", "ua": "Він приносить тістечка для всіх. Такий звичай."}], "questions": [{"q_ua": "Як колеги звертаються одне до одного?", "options": ["на «ти»", "на «ви»", "лише на прізвище"], "correct": 0, "answer_turn": 1}, {"q_ua": "Що приносить іменинник для всіх?", "answer_text": "тістечка", "accept": ["торт", "солодощі", "kolače"], "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '70c2ff70-2b33-569b-a0aa-662dd4fbe4db', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c4228882-7558-565c-9913-a3eebe21d3b8', 'speaking', 'Що мені принести?', 'Što da donesem?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '919fe1ca-d08b-5aff-9f0f-fb895238572d', 'speaking', 'Нам треба роззуватися?', 'Trebamo li se izuti?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '158a54f3-ae68-5abf-bce7-c89facd808d5', 'write_message', 'Напишіть подрузі, яка скоро приїде: як поводитися в гостях у хорватів (принести вино, роззутися, не відмовлятися від пирога).', 'Kad ideš u goste, običaj je donijeti vino ili cvijeće. U kući se izuj i nemoj odbiti kolač!', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі, яка скоро приїде: як поводитися в гостях у хорватів (принести вино, роззутися, не відмовлятися від пирога).", "points": [{"ua": "принести вино чи квіти", "keys": [["vin"], ["cvijeć"]]}, {"ua": "роззутися", "keys": [["izu"]]}, {"ua": "не відмовлятися", "keys": [["odbi"], ["uzmi"]]}], "hints": ["običaj je donijeti vino", "izuj se", "nemoj odbiti kolač"], "models": ["Kad ideš u goste, običaj je donijeti vino ili cvijeće. U kući se izuj i nemoj odbiti kolač!"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '158a54f3-ae68-5abf-bce7-c89facd808d5', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '6f55ceaf-371d-5abf-aa70-a8b847800468', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'I u Ukrajini je običaj donijeti nešto za stol.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи господині, що в Україні теж заведено приносити щось до столу.", "direction": "ua_hr", "points": [{"ua": "в Україні", "keys": [["ukrajin"]]}, {"ua": "теж", "keys": [["i u"], ["također"]]}, {"ua": "приносити", "keys": [["don"]]}], "hints": [], "models": ["I u Ukrajini je običaj donijeti nešto za stol."], "source_ua": "Скажи господині, що в Україні теж заведено приносити щось до столу."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '6f55ceaf-371d-5abf-aa70-a8b847800468', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1ba3da5c-7833-575c-95b1-d9c21570d40a', v_lesson, 'У гості', 'U goste', 5701, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('d12abf90-dc09-53d3-9e78-adaa643c6c27', '1ba3da5c-7833-575c-95b1-d9c21570d40a', 'Darja', 'Ivana, idemo prvi put kod tvojih roditelja. Što da donesem?', 'Івано, ми вперше йдемо до твоїх батьків. Що мені принести?', 1);
  perform pg_temp.turn('1bcc8025-b299-5788-aa77-f73d3c6f15d8', '1ba3da5c-7833-575c-95b1-d9c21570d40a', 'Ivana', 'Običaj je donijeti vino ili cvijeće. I ne kasnite.', 'Заведено приносити вино або квіти. І не запізнюйтеся.', 2);
  perform pg_temp.turn('bafec875-676b-5e70-a445-93bf373f5a3c', '1ba3da5c-7833-575c-95b1-d9c21570d40a', 'Darja', 'Trebamo li se izuti?', 'Нам треба роззуватися?', 3);
  perform pg_temp.turn('f6d51b4c-7822-57e0-9fe1-33fb3bc10904', '1ba3da5c-7833-575c-95b1-d9c21570d40a', 'Ivana', 'Da, mama će vam dati papuče. I pohvalite mamin kolač!', 'Так, мама дасть вам капці. І похваліть мамин пиріг!', 4);
  perform pg_temp.turn('e69ee1bf-b92a-51e9-933e-1122da094e43', '1ba3da5c-7833-575c-95b1-d9c21570d40a', 'Darja', 'A ako sam sita? Mogu li odbiti?', 'А якщо я сита? Можна відмовитися?', 5);
  perform pg_temp.turn('f0b8994c-d1e9-5458-b2fd-0786d3fb3221', '1ba3da5c-7833-575c-95b1-d9c21570d40a', 'Ivana', 'Teško. Uzmi barem mali komad, to je pristojno.', 'Складно. Візьми хоча б маленький шматочок, це чемно.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4b330410-5e4a-5b9e-9470-0f20bcc5f475', v_lesson, 'На «ти» чи на «ви»?', 'Ti ili Vi?', 5702, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('a86658db-576d-5add-b544-853f231b4ce5', '4b330410-5e4a-5b9e-9470-0f20bcc5f475', 'Daša', 'Ivane, kad se ovdje persira, a kad tika?', 'Іване, коли тут звертаються на «ви», а коли на «ти»?', 1);
  perform pg_temp.turn('1ed81507-c3b6-5fbc-9baa-185f964d901d', '4b330410-5e4a-5b9e-9470-0f20bcc5f475', 'Ivan', 'Starijima i nepoznatima se persira. Kolege se uglavnom tikaju.', 'До старших і незнайомих — на «ви». Колеги переважно на «ти».', 2);
  perform pg_temp.turn('cf49cf22-beff-5928-8ef0-982d30ff5737', '4b330410-5e4a-5b9e-9470-0f20bcc5f475', 'Daša', 'A pozdrav? Kod nas se rukujemo.', 'А привітання? У нас тиснуть руки.', 3);
  perform pg_temp.turn('5f03b2b7-52d6-5e5b-84d4-2dee5ea55e36', '4b330410-5e4a-5b9e-9470-0f20bcc5f475', 'Ivan', 'Prijatelji se ljube u obraz, dva poljupca. Na poslu se rukujemo.', 'Друзі цілуються в щоку, двічі. На роботі тиснемо руки.', 4);
  perform pg_temp.turn('4098b316-d07d-51a9-b692-48db5ef80f2e', '4b330410-5e4a-5b9e-9470-0f20bcc5f475', 'Daša', 'A kava? Zašto traje tako dugo?', 'А кава? Чому вона триває так довго?', 5);
  perform pg_temp.turn('cb3ff589-986a-59d1-a9d7-a1abbb1ad765', '4b330410-5e4a-5b9e-9470-0f20bcc5f475', 'Ivan', 'Kava nije piće, nego druženje. Pomalo!', 'Кава — це не напій, а спілкування. Не поспішай!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.11 · урок 71: Клапа, тамбурица й спадщина ЮНЕСКО — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '3fbc4d9b-4366-5f0f-b785-eb3f750240be';
  v_lesson constant uuid := 'c71597ab-1dac-5b9d-a304-b389f93a420a';
  v_gid constant uuid := '6da44157-69d7-5261-8289-fe910fd60f59';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики POSV'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A2.11: місце 6 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 71: Клапа, тамбурица й спадщина ЮНЕСКО', 'Lekcija 71: Klapa, tamburica i baština UNESCO-a', '["Розповісти про музику й традиції, які охороняє ЮНЕСКО", "Прикметники: paška čipka, sinjska alka, dalmatinsko pjevanje"]'::jsonb, 20, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'klapsko pjevanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tamburica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nematerijalna baština', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kulturna baština', v_pos);
  v_pos := pg_temp.word(v_lesson, 'paška čipka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sinjska alka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'viteški turnir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'narodna nošnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'folklorna skupina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bećarac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ojkanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'a cappella', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glas', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nastup', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svjetski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'očuvati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prenositi s koljena na koljeno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ručni rad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'licitar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dalmatinski', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '4db4d079-b928-5686-8b72-a83c87e1c380', 'fill_in_the_blank', '___ alka je stari viteški turnir.', 'Sinjska', '["Sinj", "Sinjski", "Sinjska", "Sinja"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '06518c7c-cbf3-51e6-b537-da2647fe4cfb', 'multiple_choice', 'Що означає «folklorna skupina»?', 'фольклорний ансамбль', '["тамбуриця (струнний інструмент)", "а капела (без інструментів)", "нематеріальна спадщина", "фольклорний ансамбль"]'::jsonb, 'A2', 2, 'PUBLISHED', 'folklorna skupina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8da637a4-cd22-5c12-8976-bd07f0ed8a06', 'multiple_choice', 'Що означає «kulturna baština»?', 'культурна спадщина', '["ручна робота", "бечарац (славонська пісня-жарт)", "коло (народний танець)", "культурна спадщина"]'::jsonb, 'A2', 3, 'PUBLISHED', 'kulturna baština', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4fe89d3d-2bfb-581b-b482-1297a51eea7a', 'multiple_choice', 'Що означає «ručni rad»?', 'ручна робота', '["лицарський турнір", "голос", "нематеріальна спадщина", "ручна робота"]'::jsonb, 'A2', 4, 'PUBLISHED', 'ručni rad', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '127b1191-5cec-5f63-a393-efdd096537f2', 'multiple_choice', 'Як хорватською «спів клапи (далматинський хоровий спів)»?', 'klapsko pjevanje', '["licitar", "glas", "kolo", "klapsko pjevanje"]'::jsonb, 'A2', 5, 'PUBLISHED', 'klapsko pjevanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f2fad734-fcce-5a69-9a3c-45cfeb319b2f', 'multiple_choice', 'Як хорватською «а капела (без інструментів)»?', 'a cappella', '["tamburica", "paška čipka", "a cappella", "sinjska alka"]'::jsonb, 'A2', 6, 'PUBLISHED', 'a cappella', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0e737b7d-e886-5f08-9ce9-85ef722865ca', 'type_answer', 'Напишіть хорватською: «ойкання (старовинний спів)»', 'ojkanje', null, 'A2', 7, 'PUBLISHED', 'ojkanje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '510e9c18-a497-5c1e-8104-01646a24a174', 'type_answer', 'Напишіть хорватською: «сіньська алка (лицарський турнір)»', 'sinjska alka', null, 'A2', 8, 'PUBLISHED', 'sinjska alka', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fe449d25-5e4d-5bfc-ae98-56db9f0f7070', 'type_answer', 'Напишіть хорватською: «коло (народний танець)»', 'kolo', null, 'A2', 9, 'PUBLISHED', 'kolo', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'edc1d044-72c3-5aa0-a5ad-437392b30fb2', 'sentence_builder', 'Складіть: «Клапа співає а капела.»', 'Klapa pjeva a cappella.', '["cappella.", "Klapa", "a", "pjeva"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4fea8f3d-f1a7-5ad6-9a46-1a2666b99d1b', 'sentence_builder', 'Складіть: «Мереживо передають з покоління в покоління.»', 'Čipka se prenosi s koljena na koljeno.', '["Čipka", "prenosi", "koljena", "na", "s", "se", "koljeno."]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f2a4780b-79a8-5735-86ee-3e194429a607', 'listening', 'Прослухайте і складіть фразу', 'Slično, ali manje. Klapsko pjevanje je na popisu UNESCO-a.', '["je", "manje.", "ali", "Slično,", "Klapsko", "na", "UNESCO-a.", "pjevanje", "popisu"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '90f85662-932e-538d-baf0-fba0155603ea', 'listening_dialogue', 'Прослухайте оголошення', '1 липня; 21; у туристичному бюро', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Оголошення про фестиваль клапи в Омишу.", "script": [{"hr": "Festival dalmatinskih klapa u Omišu počinje prvog srpnja.", "ua": "Фестиваль далматинських клап в Омиші починається першого липня."}, {"hr": "Nastupi su svake subote na trgu, od dvadeset i jedan sat.", "ua": "Виступи щосуботи на площі, з двадцять першої години."}, {"hr": "Ulaznice se kupuju u Turističkoj zajednici.", "ua": "Квитки купують у туристичному бюро."}], "questions": [{"q_ua": "Коли починається фестиваль?", "options": ["1 липня", "1 червня", "1 серпня"], "correct": 0, "answer_turn": 0}, {"q_ua": "О котрій годині виступи?", "answer_text": "21", "accept": ["21:00", "21.00", "двадцять першої"], "answer_turn": 1}, {"q_ua": "Де купити квитки?", "options": ["на площі", "у туристичному бюро", "онлайн"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '90f85662-932e-538d-baf0-fba0155603ea', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a5f24ea-cab7-5329-b4e9-7d99db5dc245', 'speaking', 'Сьогодні ввечері виступ клапи.', 'Večeras je nastup klape.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3e7172c5-19ce-518a-8d43-ceb55a781857', 'speaking', 'Важливо зберегти старі звичаї.', 'Važno je očuvati stare običaje.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '3cc62d54-84cd-516d-be88-7ddfef31cbd9', 'write_message', 'Напишіть подрузі в Україну про хорватську традицію, яка вам сподобалася (клапа, мереживо чи алка).', 'U Hrvatskoj je tradicija klapsko pjevanje. Osam glasova pjeva bez instrumenata. Jako mi se sviđa!', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі в Україну про хорватську традицію, яка вам сподобалася (клапа, мереживо чи алка).", "points": [{"ua": "традиція", "keys": [["tradicij"], ["običaj"], ["baštin"]]}, {"ua": "яка саме", "keys": [["klap"], ["čipk"], ["alk"]]}, {"ua": "сподобалася", "keys": [["sviđ"], ["svidj"], ["oduševi"]]}], "hints": ["u Hrvatskoj je tradicija", "klapsko pjevanje", "jako mi se sviđa"], "models": ["U Hrvatskoj je tradicija klapsko pjevanje. Osam glasova pjeva bez instrumenata. Jako mi se sviđa!"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '3cc62d54-84cd-516d-be88-7ddfef31cbd9', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '16c0dd78-2aa8-5ba6-9d73-c4d90843f655', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Ukrajinska vezena košulja je također ručni rad i prenosi se s koljena na koljeno.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Розкажи Іванові, що українська вишиванка теж ручна робота й передається в родині.", "direction": "ua_hr", "points": [{"ua": "вишиванка", "keys": [["vezen"], ["košulj"]]}, {"ua": "ручна робота", "keys": [["ručni rad"]]}, {"ua": "передається", "keys": [["prenosi"], ["koljena"]]}], "hints": [], "models": ["Ukrajinska vezena košulja je također ručni rad i prenosi se s koljena na koljeno."], "source_ua": "Розкажи Іванові, що українська вишиванка теж ручна робота й передається в родині."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '16c0dd78-2aa8-5ba6-9d73-c4d90843f655', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3fe77b45-5644-575f-9b9f-702263ea2c7b', v_lesson, 'Клапа на набережній', 'Klapa na rivi', 5711, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('26c7eb19-efef-5af3-9ab7-b1b753f615e9', '3fe77b45-5644-575f-9b9f-702263ea2c7b', 'Daša', 'Darja, večeras je nastup klape na rivi. Dođi!', 'Дар’є, сьогодні ввечері виступ клапи на набережній. Приходь!', 1);
  perform pg_temp.turn('80114108-a2da-5d3f-b549-013c3e5676e3', '3fe77b45-5644-575f-9b9f-702263ea2c7b', 'Darja', 'Što je klapa?', 'Що таке клапа?', 2);
  perform pg_temp.turn('aa17e454-5c14-5d5e-a4e7-6215010760a9', '3fe77b45-5644-575f-9b9f-702263ea2c7b', 'Daša', 'Dalmatinsko pjevanje, a cappella, obično osam glasova.', 'Далматинський спів а капела, зазвичай вісім голосів.', 3);
  perform pg_temp.turn('71cc69db-77ca-56bd-83f9-5c1374727fd0', '3fe77b45-5644-575f-9b9f-702263ea2c7b', 'Darja', 'Kao naš zbor?', 'Як наш хор?', 4);
  perform pg_temp.turn('aebd205e-d565-580a-85d8-5357aabcc14c', '3fe77b45-5644-575f-9b9f-702263ea2c7b', 'Daša', 'Slično, ali manje. Klapsko pjevanje je na popisu UNESCO-a.', 'Схоже, але менший. Спів клапи — у списку ЮНЕСКО.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e750f0ad-479b-5b46-bd02-ce26a4d02da2', v_lesson, 'Спадщина', 'Baština', 5712, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('8cb10c03-687e-5654-91fd-46bc884d8914', 'e750f0ad-479b-5b46-bd02-ce26a4d02da2', 'Ivan', 'Znaš li da Hrvatska ima puno nematerijalne baštine?', 'Ти знаєш, що Хорватія має багато нематеріальної спадщини?', 1);
  perform pg_temp.turn('505deed9-c659-545d-9a53-9e1a0b8376e6', 'e750f0ad-479b-5b46-bd02-ce26a4d02da2', 'Darja', 'Znam za pašku čipku. Prenosi se s koljena na koljeno.', 'Я знаю про пазьке мереживо. Його передають з покоління в покоління.', 2);
  perform pg_temp.turn('f1099457-b604-5840-9e70-5906275162f4', 'e750f0ad-479b-5b46-bd02-ce26a4d02da2', 'Ivan', 'I sinjska alka, stari viteški turnir. Svakog kolovoza.', 'І Сіньська алка, старовинний лицарський турнір. Щосерпня.', 3);
  perform pg_temp.turn('9c049e40-a968-5d9b-b793-b291b58f18e9', 'e750f0ad-479b-5b46-bd02-ce26a4d02da2', 'Darja', 'Kod nas je vez, ukrajinska vezena košulja.', 'У нас вишивка, українська вишиванка.', 4);
  perform pg_temp.turn('cdf9bf8b-2cab-5898-ad63-a185ec539241', 'e750f0ad-479b-5b46-bd02-ce26a4d02da2', 'Ivan', 'Važno je očuvati takve običaje.', 'Важливо зберігати такі звичаї.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- 3. Модуль і юніт — опубліковані
update public.modules set status = 'PUBLISHED', title_ua = 'Модуль A2.11 — Хорватія: краї, звичаї, культура', title_hr = 'Modul A2.11 — Hrvatska: krajevi, običaji, kultura' where id = '81b58843-3837-5c58-ab5d-4d16e30620b2';
update public.units set status = 'PUBLISHED' where id = '3fbc4d9b-4366-5f0f-b785-eb3f750240be';

-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('df44c302-d9be-51e9-9c3f-a5faf4ca04a6', '4bd3a563-65f6-596c-8f20-aabce6c7811f', 'ab060253-8099-5e7d-bfaa-1b1a7655c229', 'a312ce34-22d7-56e3-a38e-106205ee21c0', '7d3c3501-a381-5b3c-a0a2-b269f3dff137', 'c71597ab-1dac-5b9d-a304-b389f93a420a')
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
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 20 or l.unit_id <> '3fbc4d9b-4366-5f0f-b785-eb3f750240be');
  select count(*) into v_titles from (values ('df44c302-d9be-51e9-9c3f-a5faf4ca04a6'::uuid, 'Урок 66:%', 1), ('4bd3a563-65f6-596c-8f20-aabce6c7811f'::uuid, 'Урок 67:%', 2), ('ab060253-8099-5e7d-bfaa-1b1a7655c229'::uuid, 'Урок 68:%', 3), ('a312ce34-22d7-56e3-a38e-106205ee21c0'::uuid, 'Урок 69:%', 4), ('7d3c3501-a381-5b3c-a0a2-b269f3dff137'::uuid, 'Урок 70:%', 5), ('c71597ab-1dac-5b9d-a304-b389f93a420a'::uuid, 'Урок 71:%', 6)) as t(id, pat, o)
    left join public.lessons l on l.id = t.id and l.title_ua like t.pat and l.order_index = t.o
   where l.id is null;
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
      where l.level_code = 'A2' and l.status = 'PUBLISHED' and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A2.11: % уроків з неправильним складом', v_bad; end if;
  if v_titles > 0 then raise exception 'Модуль A2.11: % уроків не на своєму місці чи з неправильним номером', v_titles; end if;
  if v_words > 0 then raise exception 'A2: % слів повторюються в кількох уроках', v_words; end if;
  if (select status from public.modules where id = '81b58843-3837-5c58-ab5d-4d16e30620b2') <> 'PUBLISHED' then raise exception 'Модуль A2.11 не опубліковано'; end if;
  raise notice 'Готово: модуль A2.11 — 6 уроків, слів 126';
end $$;

commit;
