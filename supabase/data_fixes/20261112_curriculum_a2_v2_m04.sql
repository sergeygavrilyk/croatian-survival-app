-- =====================================================================
-- Програма A2 v2 · модуль A2.4 «Люди й стосунки: характер, свята, конфлікти» · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2.py 4 (не редагуйте вручну).
--
-- Рішення власника 2026-11-12: 20–25 нових слів на урок, 90–95 % слів — нові для рівня, діалоги під тему,
-- частіше Даша / Дар’я; «Прослухайте діалог чи оголошення» в кожному уроці; бета (PUBLISHED).
--   * Уроки 23–29 (7): слів у них 147. Кожен: 20–25 слів, 2 діалоги, 15 вправ
--     (одна — «Прослухайте діалог чи оголошення»), «Напишіть повідомлення» і «Перекажіть другу» (ua → hr, необов’язкові), 20 хв.
--   * Слова: 147 (нові — PUBLISHED; ті, що вже є в словнику, не змінюються).
--   * Модуль і юніт A2.4 → PUBLISHED. Потрібен уже запущений 20261112_curriculum_a2_v2_00_structure.sql.
--   * Нічого не видаляє. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.units where id = 'dbef7f5b-f911-5816-b398-c641f7d16dff') then
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

-- 1. Слова уроків A2.4 (147): нові — PUBLISHED (бета); наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A2', t.ua, t.vtype, t.forms, t.examples, 'PUBLISHED', 'claude_curriculum_a2_v2'
  from jsonb_to_recordset('[{"lemma": "karakter", "normalized": "karakter", "pos": "noun", "ua": "характер", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ima jak karakter."]}, {"lemma": "narav", "normalized": "narav", "pos": "noun", "ua": "вдача, натура", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Po naravi je vrlo mirna."]}, {"lemma": "iskren", "normalized": "iskren", "pos": "adjective", "ua": "щирий, відвертий", "vtype": "core", "forms": {}, "examples": ["Cijenim iskrene ljude."]}, {"lemma": "pošten", "normalized": "posten", "pos": "adjective", "ua": "чесний", "vtype": "core", "forms": {}, "examples": ["On je pošten čovjek, ne laže."]}, {"lemma": "marljiv", "normalized": "marljiv", "pos": "adjective", "ua": "працьовитий, старанний", "vtype": "core", "forms": {}, "examples": ["Darja je marljiva i uvijek sve završi na vrijeme."]}, {"lemma": "tvrdoglav", "normalized": "tvrdoglav", "pos": "adjective", "ua": "упертий", "vtype": "core", "forms": {}, "examples": ["Moj brat je tvrdoglav kao mazga."]}, {"lemma": "nestrpljiv", "normalized": "nestrpljiv", "pos": "adjective", "ua": "нетерплячий", "vtype": "core", "forms": {}, "examples": ["Djeca su nestrpljiva prije Božića."]}, {"lemma": "sebičan", "normalized": "sebican", "pos": "adjective", "ua": "егоїстичний", "vtype": "core", "forms": {}, "examples": ["Ne budi sebičan, podijeli s bratom."]}, {"lemma": "velikodušan", "normalized": "velikodusan", "pos": "adjective", "ua": "щедрий, великодушний", "vtype": "core", "forms": {}, "examples": ["Susjed je velikodušan, uvijek nam pomaže."]}, {"lemma": "škrt", "normalized": "skrt", "pos": "adjective", "ua": "скупий", "vtype": "core", "forms": {}, "examples": ["Nije škrt, samo štedi."]}, {"lemma": "skroman", "normalized": "skroman", "pos": "adjective", "ua": "скромний", "vtype": "core", "forms": {}, "examples": ["Unatoč uspjehu, ostala je skromna."]}, {"lemma": "hvalisav", "normalized": "hvalisav", "pos": "adjective", "ua": "хвалькуватий", "vtype": "core", "forms": {}, "examples": ["Ne volim hvalisave ljude."]}, {"lemma": "uporan", "normalized": "uporan", "pos": "adjective", "ua": "наполегливий", "vtype": "core", "forms": {}, "examples": ["Uporna je i nikad ne odustaje."]}, {"lemma": "povučen", "normalized": "povucen", "pos": "adjective", "ua": "замкнутий, стриманий", "vtype": "core", "forms": {}, "examples": ["Novi kolega je povučen i malo govori."]}, {"lemma": "duhovit", "normalized": "duhovit", "pos": "adjective", "ua": "дотепний", "vtype": "core", "forms": {}, "examples": ["Marko je duhovit, s njim se uvijek smijemo."]}, {"lemma": "brižan", "normalized": "brizan", "pos": "adjective", "ua": "турботливий", "vtype": "core", "forms": {}, "examples": ["Ona je brižna mama."]}, {"lemma": "dobroćudan", "normalized": "dobrocudan", "pos": "adjective", "ua": "добродушний", "vtype": "core", "forms": {}, "examples": ["Djed je bio dobroćudan i nikad se nije ljutio."]}, {"lemma": "nesiguran u sebe", "normalized": "nesiguran u sebe", "pos": "phrase", "ua": "невпевнений у собі", "vtype": "chunk", "forms": {}, "examples": ["Kao tinejdžerica sam bila nesigurna u sebe."]}, {"lemma": "vrlina", "normalized": "vrlina", "pos": "noun", "ua": "чеснота, позитивна риса", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Strpljenje je velika vrlina."]}, {"lemma": "mana", "normalized": "mana", "pos": "noun", "ua": "вада, недолік", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Svatko ima neku manu."]}, {"lemma": "nalikovati", "normalized": "nalikovati", "pos": "verb", "ua": "бути схожим (на когось)", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Po karakteru nalikuje ocu."]}, {"lemma": "slagati se s ljudima", "normalized": "slagati se s ljudima", "pos": "phrase", "ua": "ладнати з людьми", "vtype": "chunk", "forms": {}, "examples": ["Lako se slaže s ljudima."]}, {"lemma": "svadba", "normalized": "svadba", "pos": "noun", "ua": "весілля (святкування)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Na svadbi je bilo dvjesto gostiju."]}, {"lemma": "mladenka", "normalized": "mladenka", "pos": "noun", "ua": "наречена", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Mladenka je nosila dugu bijelu haljinu."]}, {"lemma": "mladoženja", "normalized": "mladozenja", "pos": "noun", "ua": "наречений", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Mladoženja je bio jako nervozan."]}, {"lemma": "mladenci", "normalized": "mladenci", "pos": "noun", "ua": "молодята", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Mladenci su otvorili ples."]}, {"lemma": "svatovi", "normalized": "svatovi", "pos": "noun", "ua": "весільні гості", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Svatovi su pjevali cijelu noć."]}, {"lemma": "vjenčani prsten", "normalized": "vjencani prsten", "pos": "phrase", "ua": "обручка", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Vjenčani prsten nosi na desnoj ruci."]}, {"lemma": "zaruke", "normalized": "zaruke", "pos": "noun", "ua": "заручини", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Zaruke su bile prošle godine."]}, {"lemma": "zaprositi", "normalized": "zaprositi", "pos": "verb", "ua": "освідчитися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "prositi"}, "examples": ["Zaprosio ju je na plaži."]}, {"lemma": "krštenje", "normalized": "krstenje", "pos": "noun", "ua": "хрестини", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Krštenje je u nedjelju u crkvi."]}, {"lemma": "krstiti", "normalized": "krstiti", "pos": "verb", "ua": "хрестити", "vtype": "core", "forms": {"aspect": "biasp"}, "examples": ["Dijete su krstili u lipnju."]}, {"lemma": "kumstvo", "normalized": "kumstvo", "pos": "noun", "ua": "кумівство", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Kumstvo je u Hrvatskoj važna veza."]}, {"lemma": "jubilej", "normalized": "jubilej", "pos": "noun", "ua": "ювілей", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Djed slavi jubilej, osamdeset godina."]}, {"lemma": "zdravica", "normalized": "zdravica", "pos": "noun", "ua": "тост", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Kum je održao zdravicu."]}, {"lemma": "nazdravlje", "normalized": "nazdravlje", "pos": "interjection", "ua": "будьмо! (тост)", "vtype": "formulaic", "forms": {}, "examples": ["Živjeli! Nazdravlje mladencima!"]}, {"lemma": "živjeli", "normalized": "zivjeli", "pos": "interjection", "ua": "будьмо! (тост)", "vtype": "formulaic", "forms": {}, "examples": ["Podignimo čaše. Živjeli!"]}, {"lemma": "svečana odjeća", "normalized": "svecana odjeca", "pos": "phrase", "ua": "святковий одяг", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na krštenje se dolazi u svečanoj odjeći."]}, {"lemma": "omotnica s novcem", "normalized": "omotnica s novcem", "pos": "phrase", "ua": "конверт з грошима", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Mladencima se obično daje omotnica s novcem."]}, {"lemma": "običaj", "normalized": "obicaj", "pos": "noun", "ua": "звичай", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Kod nas je običaj da mladenka baci buket."]}, {"lemma": "buket", "normalized": "buket", "pos": "noun", "ua": "букет", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Buket je uhvatila moja sestra."]}, {"lemma": "slavlje", "normalized": "slavlje", "pos": "noun", "ua": "свято, святкування", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Slavlje je trajalo do jutra."]}, {"lemma": "ugostiti", "normalized": "ugostiti", "pos": "verb", "ua": "приймати (гостей), почастувати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "ugošćivati"}, "examples": ["Ugostili su nas kao rodbinu."]}, {"lemma": "vjenčani ples", "normalized": "vjencani ples", "pos": "phrase", "ua": "перший танець молодят", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Vjenčani ples je bio valcer."]}, {"lemma": "čestit Božić", "normalized": "cestit bozic", "pos": "phrase", "ua": "з Різдвом (вітання)", "vtype": "chunk", "forms": {}, "examples": ["Čestit Božić i sretna Nova godina!"]}, {"lemma": "sretan imendan", "normalized": "sretan imendan", "pos": "phrase", "ua": "з іменинами", "vtype": "chunk", "forms": {}, "examples": ["Sretan imendan, Ivane!"]}, {"lemma": "puno sreće", "normalized": "puno srece", "pos": "phrase", "ua": "щастя (побажання)", "vtype": "chunk", "forms": {}, "examples": ["Puno sreće na novom poslu!"]}, {"lemma": "puno zdravlja", "normalized": "puno zdravlja", "pos": "phrase", "ua": "міцного здоров’я", "vtype": "chunk", "forms": {}, "examples": ["Želim ti puno zdravlja i uspjeha."]}, {"lemma": "brzo ozdravi", "normalized": "brzo ozdravi", "pos": "phrase", "ua": "одужуй швидше", "vtype": "chunk", "forms": {}, "examples": ["Čula sam da si bolestan. Brzo ozdravi!"]}, {"lemma": "iskrena sućut", "normalized": "iskrena sucut", "pos": "phrase", "ua": "щирі співчуття", "vtype": "chunk", "forms": {}, "examples": ["Iskrena sućut tebi i obitelji."]}, {"lemma": "sućut", "normalized": "sucut", "pos": "noun", "ua": "співчуття", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Izrazila sam joj sućut."]}, {"lemma": "sve najljepše", "normalized": "sve najljepse", "pos": "phrase", "ua": "усього найкращого", "vtype": "chunk", "forms": {}, "examples": ["Sve najljepše za rođendan!"]}, {"lemma": "od srca", "normalized": "od srca", "pos": "phrase", "ua": "від щирого серця", "vtype": "chunk", "forms": {}, "examples": ["Čestitam ti od srca."]}, {"lemma": "ispunjenje želja", "normalized": "ispunjenje zelja", "pos": "phrase", "ua": "здійснення бажань", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Želim ti ispunjenje svih želja."]}, {"lemma": "čestitati rođendan", "normalized": "cestitati rodendan", "pos": "phrase", "ua": "привітати з днем народження", "vtype": "chunk", "forms": {}, "examples": ["Zaboravila sam mu čestitati rođendan."]}, {"lemma": "poslati čestitku", "normalized": "poslati cestitku", "pos": "phrase", "ua": "надіслати листівку", "vtype": "chunk", "forms": {}, "examples": ["Baki ćemo poslati čestitku poštom."]}, {"lemma": "blagdanski", "normalized": "blagdanski", "pos": "adjective", "ua": "святковий", "vtype": "core", "forms": {}, "examples": ["Blagdanski ukrasi su već u gradu."]}, {"lemma": "Dan državnosti", "normalized": "dan drzavnosti", "pos": "phrase", "ua": "День державності", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Dan državnosti je trideseti svibnja."]}, {"lemma": "slaviti", "normalized": "slaviti", "pos": "verb", "ua": "святкувати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Kako slavite Novu godinu?"]}, {"lemma": "obradovati", "normalized": "obradovati", "pos": "verb", "ua": "потішити, порадувати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "radovati"}, "examples": ["Tvoja poruka me jako obradovala."]}, {"lemma": "čestitam na", "normalized": "cestitam na", "pos": "phrase", "ua": "вітаю з (подією)", "vtype": "chunk", "forms": {}, "examples": ["Čestitam na novom poslu!"]}, {"lemma": "zaslužio si", "normalized": "zasluzio si", "pos": "phrase", "ua": "ти заслужив", "vtype": "chunk", "forms": {}, "examples": ["Zaslužio si ovu nagradu."]}, {"lemma": "lijepo se provedi", "normalized": "lijepo se provedi", "pos": "phrase", "ua": "гарно проведи час", "vtype": "chunk", "forms": {}, "examples": ["Lijepo se provedi na moru!"]}, {"lemma": "drži se", "normalized": "drzi se", "pos": "phrase", "ua": "тримайся", "vtype": "chunk", "forms": {}, "examples": ["Drži se, sve će proći."]}, {"lemma": "svađa", "normalized": "svada", "pos": "noun", "ua": "сварка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Svađa je počela zbog sitnice."]}, {"lemma": "posvađati se", "normalized": "posvadati se", "pos": "verb", "ua": "посваритися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "svađati se"}, "examples": ["Posvađala sam se sa sestrom."]}, {"lemma": "svađati se", "normalized": "svadati se", "pos": "verb", "ua": "сваритися", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "posvađati se"}, "examples": ["Ne svađajte se pred djecom."]}, {"lemma": "nesporazum", "normalized": "nesporazum", "pos": "noun", "ua": "непорозуміння", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Sve je bio samo nesporazum."]}, {"lemma": "isprika", "normalized": "isprika", "pos": "noun", "ua": "вибачення", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Dugujem ti ispriku."]}, {"lemma": "uvrijediti", "normalized": "uvrijediti", "pos": "verb", "ua": "образити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "vrijeđati"}, "examples": ["Nisam te htjela uvrijediti."]}, {"lemma": "uvrijeđen", "normalized": "uvrijeden", "pos": "adjective", "ua": "ображений", "vtype": "core", "forms": {}, "examples": ["Još je uvrijeđen i ne javlja se."]}, {"lemma": "naljutiti se", "normalized": "naljutiti se", "pos": "verb", "ua": "розсердитися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "ljutiti se"}, "examples": ["Naljutio se jer sam zakasnila."]}, {"lemma": "povrijediti", "normalized": "povrijediti", "pos": "verb", "ua": "зачепити, скривдити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "vrijeđati"}, "examples": ["Tvoje riječi su me povrijedile."]}, {"lemma": "oprostiti", "normalized": "oprostiti", "pos": "verb", "ua": "пробачити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "opraštati"}, "examples": ["Molim te, oprosti mi."]}, {"lemma": "pomiriti se", "normalized": "pomiriti se", "pos": "verb", "ua": "помиритися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "miriti se"}, "examples": ["Pomirile smo se uz kavu."]}, {"lemma": "krivnja", "normalized": "krivnja", "pos": "noun", "ua": "провина", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Priznajem svoju krivnju."]}, {"lemma": "nisam to tako mislio", "normalized": "nisam to tako mislio", "pos": "phrase", "ua": "я не це мав на увазі", "vtype": "chunk", "forms": {}, "examples": ["Oprosti, nisam to tako mislio."]}, {"lemma": "vikati", "normalized": "vikati", "pos": "verb", "ua": "кричати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Nemoj vikati na mene."]}, {"lemma": "smiriti se", "normalized": "smiriti se", "pos": "verb", "ua": "заспокоїтися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "smirivati se"}, "examples": ["Smiri se, razgovarajmo normalno."]}, {"lemma": "sitnica", "normalized": "sitnica", "pos": "noun", "ua": "дрібниця", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ne ljuti se zbog sitnica."]}, {"lemma": "razgovarati iskreno", "normalized": "razgovarati iskreno", "pos": "phrase", "ua": "поговорити відверто", "vtype": "chunk", "forms": {}, "examples": ["Moramo razgovarati iskreno."]}, {"lemma": "povjerenje", "normalized": "povjerenje", "pos": "noun", "ua": "довіра", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Izgubila sam povjerenje u njega."]}, {"lemma": "prekinuti", "normalized": "prekinuti", "pos": "verb", "ua": "перервати; розійтися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "prekidati"}, "examples": ["Prekinula je s dečkom."]}, {"lemma": "ljubomora", "normalized": "ljubomora", "pos": "noun", "ua": "ревнощі", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ljubomora uništava odnose."]}, {"lemma": "slagati se", "normalized": "slagati se", "pos": "verb", "ua": "погоджуватися; ладнати", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "složiti se"}, "examples": ["Slažem se s tobom."]}, {"lemma": "ne slažem se", "normalized": "ne slazem se", "pos": "phrase", "ua": "я не згоден", "vtype": "chunk", "forms": {}, "examples": ["Ne slažem se s tim prijedlogom."]}, {"lemma": "u pravu si", "normalized": "u pravu si", "pos": "phrase", "ua": "ти маєш рацію", "vtype": "chunk", "forms": {}, "examples": ["U pravu si, tako je bolje."]}, {"lemma": "nisi u pravu", "normalized": "nisi u pravu", "pos": "phrase", "ua": "ти не маєш рації", "vtype": "chunk", "forms": {}, "examples": ["Mislim da nisi u pravu."]}, {"lemma": "po meni", "normalized": "po meni", "pos": "phrase", "ua": "як на мене", "vtype": "chunk", "forms": {}, "examples": ["Po meni, to je loša ideja."]}, {"lemma": "stav", "normalized": "stav", "pos": "noun", "ua": "позиція, ставлення", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Kakav je tvoj stav o tome?"]}, {"lemma": "argument", "normalized": "argument", "pos": "noun", "ua": "аргумент", "vtype": "core", "forms": {"gender": "m"}, "examples": ["To je dobar argument."]}, {"lemma": "uvjeriti", "normalized": "uvjeriti", "pos": "verb", "ua": "переконати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "uvjeravati"}, "examples": ["Uvjerila me da ostanem."]}, {"lemma": "kompromis", "normalized": "kompromis", "pos": "noun", "ua": "компроміс", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Moramo naći kompromis."]}, {"lemma": "raspravljati", "normalized": "raspravljati", "pos": "verb", "ua": "обговорювати, сперечатися", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Satima smo raspravljali o tome."]}, {"lemma": "rasprava", "normalized": "rasprava", "pos": "noun", "ua": "дискусія, суперечка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Rasprava je bila zanimljiva."]}, {"lemma": "donekle", "normalized": "donekle", "pos": "adverb", "ua": "певною мірою", "vtype": "core", "forms": {}, "examples": ["Donekle se slažem."]}, {"lemma": "nikako", "normalized": "nikako", "pos": "adverb", "ua": "аж ніяк, у жодному разі", "vtype": "core", "forms": {}, "examples": ["Nikako se ne slažem s njima."]}, {"lemma": "istina je da", "normalized": "istina je da", "pos": "phrase", "ua": "правда в тому, що", "vtype": "chunk", "forms": {}, "examples": ["Istina je da je skupo, ali kvalitetno."]}, {"lemma": "s jedne strane", "normalized": "s jedne strane", "pos": "phrase", "ua": "з одного боку", "vtype": "chunk", "forms": {}, "examples": ["S jedne strane, plaća je dobra."]}, {"lemma": "s druge strane", "normalized": "s druge strane", "pos": "phrase", "ua": "з іншого боку", "vtype": "chunk", "forms": {}, "examples": ["S druge strane, posao je daleko."]}, {"lemma": "prednost", "normalized": "prednost", "pos": "noun", "ua": "перевага", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Prednost malog grada je mir."]}, {"lemma": "nedostatak", "normalized": "nedostatak", "pos": "noun", "ua": "недолік", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Nedostatak je loš prijevoz."]}, {"lemma": "prijedlog", "normalized": "prijedlog", "pos": "noun", "ua": "пропозиція", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Imam prijedlog za vikend."]}, {"lemma": "predložiti", "normalized": "predloziti", "pos": "verb", "ua": "запропонувати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "predlagati"}, "examples": ["Predlažem da idemo vlakom."]}, {"lemma": "protuargument", "normalized": "protuargument", "pos": "noun", "ua": "контраргумент", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Na to imam jedan protuargument."]}, {"lemma": "prigovor", "normalized": "prigovor", "pos": "noun", "ua": "скарга, претензія", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Napisala sam prigovor trgovini."]}, {"lemma": "pisani prigovor", "normalized": "pisani prigovor", "pos": "phrase", "ua": "письмова скарга", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Pisani prigovor možete poslati e-mailom."]}, {"lemma": "žaliti se", "normalized": "zaliti se", "pos": "verb", "ua": "скаржитися", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Žalim se na loše usluge."]}, {"lemma": "potrošač", "normalized": "potrosac", "pos": "noun", "ua": "споживач", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Kao potrošač imate pravo na prigovor."]}, {"lemma": "prava potrošača", "normalized": "prava potrosaca", "pos": "phrase", "ua": "права споживачів", "vtype": "chunk", "forms": {"gender": "n_pl"}, "examples": ["Prava potrošača su zaštićena zakonom."]}, {"lemma": "knjiga žalbe", "normalized": "knjiga zalbe", "pos": "phrase", "ua": "книга скарг", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Tražila sam knjigu žalbe."]}, {"lemma": "voditelj trgovine", "normalized": "voditelj trgovine", "pos": "phrase", "ua": "керівник магазину", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Želim razgovarati s voditeljem trgovine."]}, {"lemma": "nezadovoljan", "normalized": "nezadovoljan", "pos": "adjective", "ua": "незадоволений", "vtype": "core", "forms": {}, "examples": ["Nezadovoljna sam uslugom."]}, {"lemma": "neprihvatljiv", "normalized": "neprihvatljiv", "pos": "adjective", "ua": "неприйнятний", "vtype": "core", "forms": {}, "examples": ["Takvo ponašanje je neprihvatljivo."]}, {"lemma": "servis", "normalized": "servis", "pos": "noun", "ua": "сервіс, ремонтна майстерня", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Odnijela sam perilicu u servis."]}, {"lemma": "jamstveni list", "normalized": "jamstveni list", "pos": "phrase", "ua": "гарантійний талон", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ponesite jamstveni list i račun."]}, {"lemma": "rok za odgovor", "normalized": "rok za odgovor", "pos": "phrase", "ua": "строк відповіді", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Rok za odgovor na prigovor je petnaest dana."]}, {"lemma": "zahtijevati", "normalized": "zahtijevati", "pos": "verb", "ua": "вимагати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Zahtijevam povrat novca."]}, {"lemma": "nadoknaditi", "normalized": "nadoknaditi", "pos": "verb", "ua": "відшкодувати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "nadoknađivati"}, "examples": ["Trgovina će nam nadoknaditi štetu."]}, {"lemma": "šteta", "normalized": "steta", "pos": "noun", "ua": "збиток, шкода", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Tko će platiti štetu?"]}, {"lemma": "ispričati se kupcu", "normalized": "ispricati se kupcu", "pos": "phrase", "ua": "вибачитися перед покупцем", "vtype": "chunk", "forms": {}, "examples": ["Prodavač se ispričao kupcu."]}, {"lemma": "nevaljao", "normalized": "nevaljao", "pos": "adjective", "ua": "неякісний, бракований", "vtype": "core", "forms": {}, "examples": ["Prodali su mi nevaljalu robu."]}, {"lemma": "ispravak", "normalized": "ispravak", "pos": "noun", "ua": "виправлення", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Tražim ispravak računa."]}, {"lemma": "udruga za zaštitu potrošača", "normalized": "udruga za zastitu potrosaca", "pos": "phrase", "ua": "спілка захисту споживачів", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Javila sam se udruzi za zaštitu potrošača."]}, {"lemma": "reklamirati", "normalized": "reklamirati", "pos": "verb", "ua": "подати рекламацію (повернути з претензією)", "vtype": "core", "forms": {"aspect": "biasp"}, "examples": ["Cipele sam reklamirala nakon tjedan dana."]}, {"lemma": "neljubazan", "normalized": "neljubazan", "pos": "adjective", "ua": "неввічливий", "vtype": "core", "forms": {}, "examples": ["Prodavač je bio neljubazan."]}, {"lemma": "stanar", "normalized": "stanar", "pos": "noun", "ua": "мешканець (будинку)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Svi stanari su dobili obavijest."]}, {"lemma": "suvlasnici", "normalized": "suvlasnici", "pos": "noun", "ua": "співвласники", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Suvlasnici odlučuju o popravku krova."]}, {"lemma": "predstavnik suvlasnika", "normalized": "predstavnik suvlasnika", "pos": "phrase", "ua": "представник співвласників (голова будинку)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Javite se predstavniku suvlasnika."]}, {"lemma": "sastanak stanara", "normalized": "sastanak stanara", "pos": "phrase", "ua": "збори мешканців", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Sastanak stanara je u četvrtak."]}, {"lemma": "oglasna ploča", "normalized": "oglasna ploca", "pos": "phrase", "ua": "дошка оголошень", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Obavijest je na oglasnoj ploči u ulazu."]}, {"lemma": "glasna glazba", "normalized": "glasna glazba", "pos": "phrase", "ua": "гучна музика", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Susjed pušta glasnu glazbu do ponoći."]}, {"lemma": "lupati", "normalized": "lupati", "pos": "verb", "ua": "грюкати, стукати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Netko stalno lupa vratima."]}, {"lemma": "smetati", "normalized": "smetati", "pos": "verb", "ua": "заважати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Smeta li Vam buka?"]}, {"lemma": "obzir", "normalized": "obzir", "pos": "noun", "ua": "зважання, повага (до інших)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Malo obzira prema susjedima, molim."]}, {"lemma": "obziran", "normalized": "obziran", "pos": "adjective", "ua": "тактовний, уважний до інших", "vtype": "core", "forms": {}, "examples": ["Novi susjedi su vrlo obzirni."]}, {"lemma": "prekršiti", "normalized": "prekrsiti", "pos": "verb", "ua": "порушити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "kršiti"}, "examples": ["Prekršili su kućni red."]}, {"lemma": "pritužiti se", "normalized": "prituziti se", "pos": "verb", "ua": "поскаржитися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "pritužiti"}, "examples": ["Susjedi su se pritužili na psa."]}, {"lemma": "komunalni redar", "normalized": "komunalni redar", "pos": "phrase", "ua": "комунальний інспектор", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ako se ne dogovorimo, zvat ću komunalnog redara."]}, {"lemma": "zajednički prostor", "normalized": "zajednicki prostor", "pos": "phrase", "ua": "спільне приміщення", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["U zajedničkom prostoru nema mjesta za bicikle."]}, {"lemma": "parkirati se", "normalized": "parkirati se", "pos": "verb", "ua": "припаркуватися", "vtype": "core", "forms": {"aspect": "biasp"}, "examples": ["Parkirali ste se na moje mjesto."]}, {"lemma": "ulaz u zgradu", "normalized": "ulaz u zgradu", "pos": "phrase", "ua": "під’їзд", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ulaz u zgradu mora biti zaključan."]}, {"lemma": "vlaga u stanu", "normalized": "vlaga u stanu", "pos": "phrase", "ua": "вогкість у квартирі", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Zbog vlage u stanu zvali smo susjeda odozgo."]}, {"lemma": "poplaviti", "normalized": "poplaviti", "pos": "verb", "ua": "затопити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "plaviti"}, "examples": ["Susjed nam je poplavio kupaonicu."]}, {"lemma": "susjedski", "normalized": "susjedski", "pos": "adjective", "ua": "сусідський", "vtype": "core", "forms": {}, "examples": ["Dobri susjedski odnosi su važni."]}, {"lemma": "izaći u susret", "normalized": "izaci u susret", "pos": "phrase", "ua": "піти назустріч", "vtype": "chunk", "forms": {}, "examples": ["Hvala što ste nam izašli u susret."]}, {"lemma": "utišati", "normalized": "utisati", "pos": "verb", "ua": "зробити тихіше, притишити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "utišavati"}, "examples": ["Molim Vas, utišajte televizor."]}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 2. Уроки модуля A2.4
-- A2.4 · урок 23: Який він? Характер людини — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'dbef7f5b-f911-5816-b398-c641f7d16dff';
  v_lesson constant uuid := '7b43692b-44ae-5e4f-9022-4290ce7b5eaa';
  v_gid constant uuid := 'b5076495-20a1-53e5-be78-eee365980865';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики PROS'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A2.4: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 23: Який він? Характер людини', 'Lekcija 23: Kakav je? Karakter osobe', '["Описати характер людини: iskren, tvrdoglav, velikodušan", "Говорити про людей у множині: ljudi, djeca, braća"]'::jsonb, 20, 'PUBLISHED', 1);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'karakter', v_pos);
  v_pos := pg_temp.word(v_lesson, 'narav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iskren', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pošten', v_pos);
  v_pos := pg_temp.word(v_lesson, 'marljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tvrdoglav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nestrpljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sebičan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'velikodušan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'škrt', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skroman', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hvalisav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uporan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povučen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'duhovit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brižan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobroćudan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nesiguran u sebe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrlina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nalikovati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slagati se s ljudima', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aa377990-9196-5a3d-a635-e163349e68b6', 'fill_in_the_blank', 'Moja ___ žive u Lavovu, a sestra u Zagrebu.', 'braća', '["bratovi", "brati", "brata", "braća"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ab38bb9e-7e1f-5aca-9a87-945324aebf30', 'multiple_choice', 'Що означає «duhovit»?', 'дотепний', '["характер", "егоїстичний", "замкнутий, стриманий", "дотепний"]'::jsonb, 'A2', 2, 'PUBLISHED', 'duhovit', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f5f44dbf-3aca-5d5c-b149-19b595c8d605', 'multiple_choice', 'Що означає «nestrpljiv»?', 'нетерплячий', '["вдача, натура", "турботливий", "добродушний", "нетерплячий"]'::jsonb, 'A2', 3, 'PUBLISHED', 'nestrpljiv', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3bb2f584-e68c-5585-8f21-d8f6159ebdef', 'multiple_choice', 'Що означає «nalikovati»?', 'бути схожим (на когось)', '["щедрий, великодушний", "бути схожим (на когось)", "наполегливий", "невпевнений у собі"]'::jsonb, 'A2', 4, 'PUBLISHED', 'nalikovati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '71b285e2-897b-56bb-bbe0-e586b6734eb8', 'multiple_choice', 'Як хорватською «характер»?', 'karakter', '["karakter", "uporan", "velikodušan", "marljiv"]'::jsonb, 'A2', 5, 'PUBLISHED', 'karakter', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '71df9837-351a-57db-9c16-cb809c2f8bec', 'multiple_choice', 'Як хорватською «добродушний»?', 'dobroćudan', '["slagati se s ljudima", "karakter", "uporan", "dobroćudan"]'::jsonb, 'A2', 6, 'PUBLISHED', 'dobroćudan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '64ce71e2-ce5e-5eeb-b02c-4fb445576bda', 'type_answer', 'Напишіть хорватською: «скупий»', 'škrt', null, 'A2', 7, 'PUBLISHED', 'škrt', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2ebf47a2-79f7-54b4-9f70-701c27d4358d', 'type_answer', 'Напишіть хорватською: «чеснота, позитивна риса»', 'vrlina', null, 'A2', 8, 'PUBLISHED', 'vrlina', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ee62d582-34cc-5783-82e4-0b4ab7e5bfd0', 'type_answer', 'Напишіть хорватською: «скромний»', 'skroman', null, 'A2', 9, 'PUBLISHED', 'skroman', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1ca382de-2050-5d06-a732-d5f6ecf7b3cd', 'sentence_builder', 'Складіть: «Він легко ладнає з людьми.»', 'Lako se slaže s ljudima.', '["s", "slaže", "Lako", "se", "ljudima."]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2ec1abaf-691b-509d-9f1d-be67412c4648', 'sentence_builder', 'Складіть: «Терпіння — велика чеснота.»', 'Strpljenje je velika vrlina.', '["velika", "Strpljenje", "vrlina.", "je"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f6b4dacb-cb43-5f23-b8d3-c17cdaa9d54e', 'listening', 'Прослухайте і складіть фразу', 'Malo povučen, ali iskren i marljiv.', '["marljiv.", "Malo", "i", "ali", "povučen,", "iskren"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'b61630c0-13b9-5282-92f7-89a8e27bf25c', 'listening_dialogue', 'Прослухайте розмову', 'дотепна й щедра; тістечка; він замкнутий', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Даша й Іван говорять про нову сусідку. Послухайте.", "script": [{"speaker": "Daša", "hr": "Upoznala sam novu susjedu. Zove se Vesna.", "ua": "Я познайомилася з новою сусідкою. Її звати Весна."}, {"speaker": "Ivan", "hr": "Kakva je?", "ua": "Яка вона?"}, {"speaker": "Daša", "hr": "Vrlo duhovita i velikodušna, donijela nam je kolače.", "ua": "Дуже дотепна й щедра, принесла нам тістечка."}, {"speaker": "Ivan", "hr": "A muž?", "ua": "А чоловік?"}, {"speaker": "Daša", "hr": "Njega još ne znam, kažu da je povučen.", "ua": "Його я ще не знаю, кажуть, він замкнутий."}], "questions": [{"q_ua": "Яка нова сусідка?", "options": ["дотепна й щедра", "сувора й мовчазна", "хвалькувата"], "correct": 0, "answer_turn": 2}, {"q_ua": "Що вона принесла?", "options": ["квіти", "тістечка", "вино"], "correct": 1, "answer_turn": 2}, {"q_ua": "Що кажуть про її чоловіка?", "options": ["він дотепний", "він сварливий", "він замкнутий"], "correct": 2, "answer_turn": 4}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'b61630c0-13b9-5282-92f7-89a8e27bf25c', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6e349b9e-9e1e-588f-97ac-b30bd9d967dd', 'speaking', 'Я ціную щирих людей.', 'Cijenim iskrene ljude.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '867dc60c-c7c6-53f8-9c40-264c4064c4d4', 'speaking', 'За характером він схожий на батька.', 'Po karakteru nalikuje ocu.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '13077e68-718a-5a84-be42-97f29159b004', 'write_message', 'Опишіть подрузі свою нову колегу: яка вона за характером (дві-три риси).', 'Moja nova kolegica je iskrena i marljiva, ali malo povučena.', 'A2', 'PUBLISHED', '{"situation_ua": "Опишіть подрузі свою нову колегу: яка вона за характером (дві-три риси).", "points": [{"ua": "нова колега", "keys": [["kolegic"]]}, {"ua": "риси характеру", "keys": [["iskren"], ["marljiv"], ["duhovit"], ["uporn"], ["povučen"], ["skromn"]]}], "hints": ["moja nova kolegica", "iskrena", "marljiva", "malo povučena"], "models": ["Moja nova kolegica je iskrena i marljiva, ali malo povučena."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '13077e68-718a-5a84-be42-97f29159b004', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '9b1bd2df-2306-54f3-8016-c47aab67c670', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Njezin muž je tvrdoglav, ali vrlo brižan.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи Даші, що мій чоловік упертий, але дуже турботливий.", "direction": "ua_hr", "points": [{"ua": "упертий", "keys": [["tvrdoglav"]]}, {"ua": "турботливий", "keys": [["brižan"], ["brižn"]]}], "hints": [], "models": ["Njezin muž je tvrdoglav, ali vrlo brižan."], "source_ua": "Скажи Даші, що мій чоловік упертий, але дуже турботливий."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '9b1bd2df-2306-54f3-8016-c47aab67c670', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a4e75699-8b3a-5d5e-8f5b-074528b9c01b', v_lesson, 'Новий колега', 'Novi kolega', 5231, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('504aa80c-5946-56c8-ad93-8865105d3d17', 'a4e75699-8b3a-5d5e-8f5b-074528b9c01b', 'Daša', 'Kakav je novi kolega?', 'Який новий колега?', 1);
  perform pg_temp.turn('e00003b0-beb7-5d8c-ba35-a36b61efbaec', 'a4e75699-8b3a-5d5e-8f5b-074528b9c01b', 'Darja', 'Malo povučen, ali iskren i marljiv.', 'Трохи замкнутий, але щирий і працьовитий.', 2);
  perform pg_temp.turn('e8868f77-0716-5cc6-b720-c69f570c509d', 'a4e75699-8b3a-5d5e-8f5b-074528b9c01b', 'Daša', 'Je li duhovit?', 'Він дотепний?', 3);
  perform pg_temp.turn('60d91858-0e55-53c5-a6a3-73cf306d449c', 'a4e75699-8b3a-5d5e-8f5b-074528b9c01b', 'Darja', 'Jest, kad ga bolje upoznaš. Lako se slaže s ljudima.', 'Так, коли краще його пізнаєш. Він легко ладнає з людьми.', 4);
  perform pg_temp.turn('b23b7122-2b06-5c6f-82d9-53970e153c25', 'a4e75699-8b3a-5d5e-8f5b-074528b9c01b', 'Daša', 'Dobro, jer prošli je bio hvalisav i sebičan.', 'Добре, бо попередній був хвалькуватий і егоїстичний.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('97be6792-8206-58bf-9b69-a928bd12a9b4', v_lesson, 'Брати й сестри', 'Braća i sestre', 5232, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('686007a3-0734-543d-9557-18d82cc8f6c6', '97be6792-8206-58bf-9b69-a928bd12a9b4', 'Ivan', 'Jesu li tvoja braća slična tebi?', 'Твої брати схожі на тебе?', 1);
  perform pg_temp.turn('2c6331bd-0757-57f9-b425-d28b99c45338', '97be6792-8206-58bf-9b69-a928bd12a9b4', 'Marko', 'Nisu. Stariji brat je tvrdoglav, a mlađi je skroman i dobroćudan.', 'Ні. Старший брат упертий, а молодший скромний і добродушний.', 2);
  perform pg_temp.turn('03ab3c2f-863f-5b78-b410-d25a544923f9', '97be6792-8206-58bf-9b69-a928bd12a9b4', 'Ivan', 'A ti?', 'А ти?', 3);
  perform pg_temp.turn('1f8f58d2-71d0-5331-9b62-8c9e5987cfaa', '97be6792-8206-58bf-9b69-a928bd12a9b4', 'Marko', 'Ja sam uporan, ali nestrpljiv. To mi je mana.', 'Я наполегливий, але нетерплячий. Це моя вада.', 4);
  perform pg_temp.turn('639d44f5-7ccf-552a-8d5f-6588741c13cb', '97be6792-8206-58bf-9b69-a928bd12a9b4', 'Ivan', 'Svi ljudi imaju neku manu. Bitno je da si pošten.', 'Усі люди мають якусь ваду. Головне, що ти чесний.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.4 · урок 24: Весілля, хрестини, ювілей — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'dbef7f5b-f911-5816-b398-c641f7d16dff';
  v_lesson constant uuid := '68f2ada8-2352-5450-a073-72754ae0feb8';
  v_gid constant uuid := 'b5076495-20a1-53e5-be78-eee365980865';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики PROS'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A2.4: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 24: Весілля, хрестини, ювілей', 'Lekcija 24: Svadba, krštenje, jubilej', '["Поговорити про родинні свята й звичаї: svadba, kumovi, zdravica", "Вживати неправильну множину: svatovi, gosti, ljudi"]'::jsonb, 20, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'svadba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mladenka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mladoženja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mladenci', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svatovi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vjenčani prsten', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaruke', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaprositi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krštenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krstiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kumstvo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jubilej', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zdravica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nazdravlje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'živjeli', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svečana odjeća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'omotnica s novcem', v_pos);
  v_pos := pg_temp.word(v_lesson, 'običaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'buket', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slavlje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ugostiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vjenčani ples', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '180b1c2d-d847-5fb0-bdde-c966842fd3f5', 'fill_in_the_blank', 'Na svadbi je bilo puno ___ iz cijele Hrvatske.', 'ljudi', '["čovjek", "ljudi", "ljudima", "čovjeka"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3ff6fabf-40a1-54b5-9b5a-9ac999d20f10', 'multiple_choice', 'Що означає «nazdravlje»?', 'будьмо! (тост)', '["весільні гості", "звичай", "будьмо! (тост)", "заручини"]'::jsonb, 'A2', 2, 'PUBLISHED', 'nazdravlje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd8d67353-c6fd-545c-a6cd-f8943fe32261', 'multiple_choice', 'Що означає «zaruke»?', 'заручини', '["хрестини", "заручини", "приймати (гостей), почастувати", "будьмо! (тост)"]'::jsonb, 'A2', 3, 'PUBLISHED', 'zaruke', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '00076cea-b60d-5e57-aa19-d41e480fb25d', 'multiple_choice', 'Що означає «svečana odjeća»?', 'святковий одяг', '["святковий одяг", "будьмо! (тост)", "кумівство", "тост"]'::jsonb, 'A2', 4, 'PUBLISHED', 'svečana odjeća', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a53b54d3-50a1-573a-9078-c2a8998a5fb7', 'multiple_choice', 'Як хорватською «весільні гості»?', 'svatovi', '["slavlje", "jubilej", "ugostiti", "svatovi"]'::jsonb, 'A2', 5, 'PUBLISHED', 'svatovi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d7d57d5-9191-5d56-840f-62ff1fcb6874', 'multiple_choice', 'Як хорватською «наречений»?', 'mladoženja', '["krštenje", "svatovi", "mladenci", "mladoženja"]'::jsonb, 'A2', 6, 'PUBLISHED', 'mladoženja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'af3b10dd-4cec-53df-b92a-314724c0641a', 'type_answer', 'Напишіть хорватською: «хрестини»', 'krštenje', null, 'A2', 7, 'PUBLISHED', 'krštenje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c58286c2-f5f1-5ecc-8697-98e207db0203', 'type_answer', 'Напишіть хорватською: «свято, святкування»', 'slavlje', null, 'A2', 8, 'PUBLISHED', 'slavlje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a891fab6-be41-5e09-92f3-3752f8338cc5', 'type_answer', 'Напишіть хорватською: «звичай»', 'običaj', null, 'A2', 9, 'PUBLISHED', 'običaj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c330f0f-6c7e-51b1-96fb-66f6f470045f', 'sentence_builder', 'Складіть: «Хрестини в неділю вранці.»', 'Krštenje je u nedjelju ujutro.', '["nedjelju", "je", "ujutro.", "Krštenje", "u"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0036f37d-a39f-52de-912b-daf6352d979c', 'sentence_builder', 'Складіть: «Він освідчився їй на пляжі.»', 'Zaprosio ju je na plaži.', '["plaži.", "Zaprosio", "je", "na", "ju"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '83fd0967-0afa-5244-8c9a-15b6f3594766', 'listening', 'Прослухайте і складіть фразу', 'U lipnju. Bit će oko dvjesto svatova.', '["će", "svatova.", "lipnju.", "Bit", "dvjesto", "oko", "U"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'd2d9009d-39e7-56bb-a621-1cfb5c6783a6', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'у неділю об 11:00; у батьків Івани; нічого', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Подруга Івана залишила вам повідомлення.", "script": [{"hr": "Bok, ovdje Ivana! Krštenje naše bebe je u nedjelju u jedanaest.", "ua": "Привіт, це Івана! Хрестини нашої дитини в неділю об одинадцятій."}, {"hr": "Crkva je svetog Vida, blizu tržnice.", "ua": "Церква святого Віта, біля ринку."}, {"hr": "Poslije krštenja idemo na ručak kod mojih roditelja.", "ua": "Після хрестин ідемо на обід до моїх батьків."}, {"hr": "Ne trebate ništa donijeti, samo dođite!", "ua": "Нічого не треба приносити, просто приходьте!"}], "questions": [{"q_ua": "Коли хрестини?", "options": ["у неділю об 11:00", "у суботу о 10:00", "у неділю о 12:00"], "correct": 0, "answer_turn": 0}, {"q_ua": "Де буде обід?", "options": ["у ресторані", "у батьків Івани", "у церкві"], "correct": 1, "answer_turn": 2}, {"q_ua": "Що треба принести?", "options": ["торт", "подарунок", "нічого"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'd2d9009d-39e7-56bb-a621-1cfb5c6783a6', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd57ea815-a118-599c-9843-cd3486c3fe17', 'speaking', 'Що тут дарують молодятам?', 'Što se ovdje poklanja mladencima?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '07e32dd9-4f8c-5c58-8b6a-83c66626e1a1', 'speaking', 'Будьмо! За молодят!', 'Živjeli! Za mladence!', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'f44ef6e0-ac30-514d-b427-bf426577450b', 'write_message', 'Напишіть Івані: дякуєте за запрошення на весілля, прийдете вдвох і питаєте, який дрес-код.', 'Ivana, hvala na pozivnici za svadbu! Doći ćemo oboje. Kakva odjeća je potrebna?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть Івані: дякуєте за запрошення на весілля, прийдете вдвох і питаєте, який дрес-код.", "points": [{"ua": "дякуєте за запрошення", "keys": [["hvala"], ["zahvalj"]]}, {"ua": "прийдете вдвох", "keys": [["dvoje"], ["oboje"], ["doći ćemo"]]}, {"ua": "дрес-код", "keys": [["odjeć"], ["obući"], ["dress"]]}], "hints": ["hvala na pozivnici", "doći ćemo oboje", "kakva je odjeća?"], "models": ["Ivana, hvala na pozivnici za svadbu! Doći ćemo oboje. Kakva odjeća je potrebna?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'f44ef6e0-ac30-514d-b427-bf426577450b', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'e8272809-0787-5f55-a829-6958dd65473b', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'U Ukrajini se na svadbi također drže zdravice i poklanja se novac.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи кумові, що в Україні на весіллі теж кажуть тости і дарують гроші.", "direction": "ua_hr", "points": [{"ua": "в Україні", "keys": [["Ukrajin"]]}, {"ua": "тости", "keys": [["zdravic"]]}, {"ua": "гроші", "keys": [["novac"], ["novc"]]}], "hints": [], "models": ["U Ukrajini se na svadbi također drže zdravice i poklanja se novac."], "source_ua": "Скажи кумові, що в Україні на весіллі теж кажуть тости і дарують гроші."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'e8272809-0787-5f55-a829-6958dd65473b', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('300b5143-b0eb-545b-8bb2-d35c66fd2004', v_lesson, 'Запрошення', 'Pozivnica', 5241, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('cfdb227e-3268-53da-81b6-e0dc3b68945e', '300b5143-b0eb-545b-8bb2-d35c66fd2004', 'Daša', 'Darja, dobili smo pozivnicu za svadbu! Ivana i Tomislav se vjenčaju.', 'Дар’є, ми отримали запрошення на весілля! Івана й Томіслав одружуються.', 1);
  perform pg_temp.turn('eea71ece-da3e-5c16-8a3c-580c5302cba5', '300b5143-b0eb-545b-8bb2-d35c66fd2004', 'Darja', 'Super! Kada?', 'Супер! Коли?', 2);
  perform pg_temp.turn('e91d7774-cc8d-5f33-a6b6-ea7417c5930e', '300b5143-b0eb-545b-8bb2-d35c66fd2004', 'Daša', 'U lipnju. Bit će oko dvjesto svatova.', 'У червні. Буде близько двохсот гостей.', 3);
  perform pg_temp.turn('77a6d890-240c-5eaf-95fa-1a7ff5773620', '300b5143-b0eb-545b-8bb2-d35c66fd2004', 'Darja', 'Što se ovdje poklanja mladencima?', 'Що тут дарують молодятам?', 4);
  perform pg_temp.turn('3f8ff0ce-d7bf-50ce-8d72-39739572dbdc', '300b5143-b0eb-545b-8bb2-d35c66fd2004', 'Daša', 'Obično omotnica s novcem. Takav je običaj.', 'Зазвичай конверт з грошима. Такий звичай.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a2b89823-8228-5c50-8632-746a8bff3f24', v_lesson, 'На весіллі', 'Na svadbi', 5242, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('6aaf606b-061f-54b6-9c75-8bf82b0d2142', 'a2b89823-8228-5c50-8632-746a8bff3f24', 'Kum', 'Dragi gosti, podignimo čaše za mladence! Živjeli!', 'Дорогі гості, піднімімо келихи за молодят! Будьмо!', 1);
  perform pg_temp.turn('cdf439b5-322e-555d-8c7f-3c275649cc16', 'a2b89823-8228-5c50-8632-746a8bff3f24', 'Svi', 'Živjeli!', 'Будьмо!', 2);
  perform pg_temp.turn('fded8d34-c68a-59da-920e-212acbd680b9', 'a2b89823-8228-5c50-8632-746a8bff3f24', 'Darja', 'Kako lijepa zdravica! Tko je ovaj čovjek?', 'Який гарний тост! Хто цей чоловік?', 3);
  perform pg_temp.turn('11f32c40-eb62-5cee-8483-451e509dc123', 'a2b89823-8228-5c50-8632-746a8bff3f24', 'Daša', 'To je kum. Kumstvo je ovdje jako važno, kum je kao član obitelji.', 'Це кум. Кумівство тут дуже важливе, кум — як член родини.', 4);
  perform pg_temp.turn('430055ca-69aa-56f4-93df-393074ee7d40', 'a2b89823-8228-5c50-8632-746a8bff3f24', 'Darja', 'A sad? Svi trče prema mladenki.', 'А зараз? Усі біжать до нареченої.', 5);
  perform pg_temp.turn('321d83f2-7f70-549b-ad1c-6edef6e26af9', 'a2b89823-8228-5c50-8632-746a8bff3f24', 'Daša', 'Mladenka će baciti buket. Hajde, probaj ga uhvatiti!', 'Наречена кидатиме букет. Давай, спробуй його спіймати!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.4 · урок 25: Привітання й побажання — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'dbef7f5b-f911-5816-b398-c641f7d16dff';
  v_lesson constant uuid := '75a84442-280d-56be-b746-81ca57caa0b5';
  v_gid constant uuid := '2d4021eb-fd3e-5388-a44b-3f541c5990f8';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики ZAM'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A2.4: місце 3 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 25: Привітання й побажання', 'Lekcija 25: Čestitke i želje', '["Привітати зі святом, побажати здоров’я, висловити співчуття", "Вживати короткі й повні займенники: Želim ti…, Tebi i obitelji…"]'::jsonb, 20, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'čestit Božić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sretan imendan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'puno sreće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'puno zdravlja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brzo ozdravi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iskrena sućut', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sućut', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sve najljepše', v_pos);
  v_pos := pg_temp.word(v_lesson, 'od srca', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispunjenje želja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čestitati rođendan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poslati čestitku', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blagdanski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Dan državnosti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obradovati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čestitam na', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaslužio si', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lijepo se provedi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'drži se', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ce663142-ee81-58cc-a8ea-0ea026bcb46c', 'fill_in_the_blank', 'Čestitam ___ od srca, Ivane!', 'ti', '["tebe", "te", "ti", "tvoj"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e0e203b5-279f-5b6c-a9d5-b135b7a14e7d', 'multiple_choice', 'Що означає «blagdanski»?', 'святковий', '["гарно проведи час", "потішити, порадувати", "ти заслужив", "святковий"]'::jsonb, 'A2', 2, 'PUBLISHED', 'blagdanski', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f88e8950-6f4b-5bfb-9fe6-0db76306c076', 'multiple_choice', 'Що означає «puno sreće»?', 'щастя (побажання)', '["потішити, порадувати", "щастя (побажання)", "від щирого серця", "усього найкращого"]'::jsonb, 'A2', 3, 'PUBLISHED', 'puno sreće', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f476f2cc-567d-5299-a13c-b92076d152a5', 'multiple_choice', 'Що означає «lijepo se provedi»?', 'гарно проведи час', '["святкувати", "вітаю з (подією)", "одужуй швидше", "гарно проведи час"]'::jsonb, 'A2', 4, 'PUBLISHED', 'lijepo se provedi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6445618a-0b98-50f3-a573-d401ecb6e7c6', 'multiple_choice', 'Як хорватською «усього найкращого»?', 'sve najljepše', '["ispunjenje želja", "sve najljepše", "blagdanski", "poslati čestitku"]'::jsonb, 'A2', 5, 'PUBLISHED', 'sve najljepše', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '83bb2ca6-c563-504f-9d21-710758a83ad2', 'multiple_choice', 'Як хорватською «здійснення бажань»?', 'ispunjenje želja', '["lijepo se provedi", "čestit Božić", "ispunjenje želja", "slaviti"]'::jsonb, 'A2', 6, 'PUBLISHED', 'ispunjenje želja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bfaa1b64-b95b-599b-aaae-3e6dd0b2e456', 'type_answer', 'Напишіть хорватською: «тримайся»', 'drži se', null, 'A2', 7, 'PUBLISHED', 'drži se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '976e6a41-f390-5810-b05e-e4b722d0caf6', 'type_answer', 'Напишіть хорватською: «від щирого серця»', 'od srca', null, 'A2', 8, 'PUBLISHED', 'od srca', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d0e8cc0-9d7b-5929-87c3-742dd4f19b81', 'type_answer', 'Напишіть хорватською: «з Різдвом (вітання)»', 'čestit Božić', null, 'A2', 9, 'PUBLISHED', 'čestit Božić', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '30c6e112-8a31-5d36-9ad2-aa0a6fa9d603', 'sentence_builder', 'Складіть: «Бажаю тобі міцного здоров’я.»', 'Želim ti puno zdravlja.', '["puno", "ti", "zdravlja.", "Želim"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '83b9f6ba-9bf7-5c51-b17c-ed74f7392f2d', 'sentence_builder', 'Складіть: «Твоє повідомлення мене дуже потішило.»', 'Tvoja poruka me jako obradovala.', '["jako", "me", "obradovala.", "Tvoja", "poruka"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '79a098ba-b546-56b7-86e5-e7605b22046a', 'listening', 'Прослухайте і складіть фразу', 'Hvala, Dašo! Kako si znala?', '["znala?", "si", "Kako", "Hvala,", "Dašo!"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '75b98934-cc14-5e08-adc1-6ab0c8fa2804', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'з днем народження; маленький торт', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Колега залишив вам голосове привітання.", "script": [{"hr": "Bok Darja, ovdje Tomislav s posla.", "ua": "Привіт, Дар’є, це Томіслав з роботи."}, {"hr": "Čestitam ti rođendan i želim ti puno sreće i uspjeha!", "ua": "Вітаю тебе з днем народження й бажаю багато щастя й успіху!"}, {"hr": "U ponedjeljak te čeka mala torta u uredu.", "ua": "У понеділок на тебе чекає маленький торт в офісі."}], "questions": [{"q_ua": "З чим вітає Томіслав?", "options": ["з днем народження", "з іменинами", "з новою роботою"], "correct": 0, "answer_turn": 1}, {"q_ua": "Що чекає в понеділок?", "options": ["квіти", "маленький торт", "вечірка"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '75b98934-cc14-5e08-adc1-6ab0c8fa2804', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d5e4810-1273-5e30-aef4-16c75e0526b9', 'speaking', 'З Різдвом і Новим роком!', 'Čestit Božić i sretna Nova godina!', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a432061-6cf1-5f8b-9eb2-2edfaa3a0761', 'speaking', 'Щирі співчуття тобі й родині.', 'Iskrena sućut tebi i obitelji.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'a323b27f-5860-53fe-a6aa-11757b81325d', 'write_message', 'Напишіть колезі привітання з днем народження: побажайте здоров’я й успіху.', 'Sretan rođendan! Želim ti puno zdravlja i uspjeha.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть колезі привітання з днем народження: побажайте здоров’я й успіху.", "points": [{"ua": "привітання з днем народження", "keys": [["rođendan"]]}, {"ua": "здоров’я", "keys": [["zdravlj"]]}, {"ua": "успіх", "keys": [["uspjeh"]]}], "hints": ["sretan rođendan", "želim ti", "puno zdravlja", "puno uspjeha"], "models": ["Sretan rođendan! Želim ti puno zdravlja i uspjeha."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'a323b27f-5860-53fe-a6aa-11757b81325d', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '2af5c20f-5f7c-5e0a-9a50-cd7ae6f24815', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Moja prijateljica ti izražava iskrenu sućut. Misli na tvoju obitelj.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Передай Марку від мене щирі співчуття й скажи, що я думаю про його родину.", "direction": "ua_hr", "points": [{"ua": "співчуття", "keys": [["sućut"]]}, {"ua": "думаю про родину", "keys": [["obitelj"]]}], "hints": [], "models": ["Moja prijateljica ti izražava iskrenu sućut. Misli na tvoju obitelj."], "source_ua": "Передай Марку від мене щирі співчуття й скажи, що я думаю про його родину."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '2af5c20f-5f7c-5e0a-9a50-cd7ae6f24815', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1591e4d1-207d-50a3-bf72-4155db9ddbf0', v_lesson, 'Іменини', 'Imendan', 5251, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('5e5bda01-60f9-5333-a49b-b9954b9e0954', '1591e4d1-207d-50a3-bf72-4155db9ddbf0', 'Daša', 'Ivane, sretan imendan! Želim ti puno zdravlja i sreće.', 'Іване, з іменинами! Бажаю тобі міцного здоров’я й щастя.', 1);
  perform pg_temp.turn('ba094062-5089-5a5e-8ee6-2d91e1cf4a42', '1591e4d1-207d-50a3-bf72-4155db9ddbf0', 'Ivan', 'Hvala, Dašo! Kako si znala?', 'Дякую, Дашо! Як ти знала?', 2);
  perform pg_temp.turn('f86e3b16-0314-5a4b-901d-05c00959289c', '1591e4d1-207d-50a3-bf72-4155db9ddbf0', 'Daša', 'Pisalo je u kalendaru. Kod nas se imendan rijetko slavi.', 'Було написано в календарі. У нас іменини рідко святкують.', 3);
  perform pg_temp.turn('ec21f357-5e53-5e2d-94d8-4ac657874b2e', '1591e4d1-207d-50a3-bf72-4155db9ddbf0', 'Ivan', 'Ovdje mnogi slave. Tvoja čestitka me jako obradovala.', 'Тут багато хто святкує. Твоє привітання мене дуже потішило.', 4);
  perform pg_temp.turn('f3242b35-96b8-5822-8c55-52d910f69e85', '1591e4d1-207d-50a3-bf72-4155db9ddbf0', 'Daša', 'Drago mi je. Sve najljepše tebi i obitelji!', 'Мені приємно. Усього найкращого тобі й родині!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f92d0f91-7b93-5941-a011-49fdb4554d12', v_lesson, 'Погана новина', 'Loša vijest', 5252, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('ad2d49a4-334a-518f-9986-b35e309d371a', 'f92d0f91-7b93-5941-a011-49fdb4554d12', 'Darja', 'Marko, čula sam da ti je umro djed. Iskrena sućut.', 'Марку, я чула, що в тебе помер дідусь. Щирі співчуття.', 1);
  perform pg_temp.turn('6451384b-2443-5ec0-8141-b78436aec4bd', 'f92d0f91-7b93-5941-a011-49fdb4554d12', 'Marko', 'Hvala ti. Bio je dug i lijep život.', 'Дякую тобі. Це було довге й гарне життя.', 2);
  perform pg_temp.turn('8fd975c0-02f2-59aa-890a-ab9cc16ba4e1', 'f92d0f91-7b93-5941-a011-49fdb4554d12', 'Darja', 'Ako ti bilo što treba, javi mi.', 'Якщо тобі щось буде потрібно, дай мені знати.', 3);
  perform pg_temp.turn('6030aab4-bc2e-5648-b0e3-4669578cea2d', 'f92d0f91-7b93-5941-a011-49fdb4554d12', 'Marko', 'Hoću. Meni je sad najvažnije da je baka dobro.', 'Добре. Мені зараз найважливіше, щоб бабуся була в порядку.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.4 · урок 26: Посварилися: суперечка й вибачення — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'dbef7f5b-f911-5816-b398-c641f7d16dff';
  v_lesson constant uuid := '6fbe028c-f4c3-50b2-b282-84f62f5d4c78';
  v_gid constant uuid := '2d4021eb-fd3e-5388-a44b-3f541c5990f8';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики ZAM'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A2.4: місце 4 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 26: Посварилися: суперечка й вибачення', 'Lekcija 26: Posvađali smo se: svađa i isprika', '["Пояснити, чому посварилися, і вибачитися", "Вживати займенники: Uvrijedila sam ga, oprosti mi, nije mu žao"]'::jsonb, 20, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'svađa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posvađati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svađati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nesporazum', v_pos);
  v_pos := pg_temp.word(v_lesson, 'isprika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uvrijediti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uvrijeđen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naljutiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povrijediti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oprostiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pomiriti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krivnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nisam to tako mislio', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vikati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smiriti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sitnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razgovarati iskreno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povjerenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prekinuti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljubomora', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eef04e37-b633-5d23-9037-613aaf3aee8c', 'fill_in_the_blank', 'Molim te, oprosti ___, nisam to tako mislila.', 'mi', '["moj", "mi", "mene", "me"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e32b3f1b-444c-59d5-9cc6-d8a5f72fd675', 'multiple_choice', 'Що означає «razgovarati iskreno»?', 'поговорити відверто', '["кричати", "образити", "вибачення", "поговорити відверто"]'::jsonb, 'A2', 2, 'PUBLISHED', 'razgovarati iskreno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '41fb7fca-8eb8-546b-be8e-7f09ee0432c5', 'multiple_choice', 'Що означає «pomiriti se»?', 'помиритися', '["посваритися", "помиритися", "зачепити, скривдити", "поговорити відверто"]'::jsonb, 'A2', 3, 'PUBLISHED', 'pomiriti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '79571436-9113-5283-b442-97b2764cb23f', 'multiple_choice', 'Що означає «prekinuti»?', 'перервати; розійтися', '["зачепити, скривдити", "довіра", "перервати; розійтися", "розсердитися"]'::jsonb, 'A2', 4, 'PUBLISHED', 'prekinuti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0a02e7f8-85db-50bc-897f-5773e574bf39', 'multiple_choice', 'Як хорватською «довіра»?', 'povjerenje', '["svađati se", "smiriti se", "isprika", "povjerenje"]'::jsonb, 'A2', 5, 'PUBLISHED', 'povjerenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fc681e7f-8e73-50d3-afd5-9b0c755f09fb', 'multiple_choice', 'Як хорватською «сварка»?', 'svađa', '["naljutiti se", "vikati", "posvađati se", "svađa"]'::jsonb, 'A2', 6, 'PUBLISHED', 'svađa', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7fc29d32-f9f3-5da1-a2e9-3f99d9762503', 'type_answer', 'Напишіть хорватською: «посваритися»', 'posvađati se', null, 'A2', 7, 'PUBLISHED', 'posvađati se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '73200382-a5d9-5f09-972b-f53593c03e4c', 'type_answer', 'Напишіть хорватською: «сваритися»', 'svađati se', null, 'A2', 8, 'PUBLISHED', 'svađati se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c4323f7c-e0d9-5b7f-a71f-41515541e73c', 'type_answer', 'Напишіть хорватською: «заспокоїтися»', 'smiriti se', null, 'A2', 9, 'PUBLISHED', 'smiriti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '37c639c9-de45-5978-9059-11e7b39abdd0', 'sentence_builder', 'Складіть: «Я не хотіла тебе образити.»', 'Nisam te htjela uvrijediti.', '["uvrijediti.", "htjela", "te", "Nisam"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c7d82ba3-1a24-52d7-95ff-ffa7621a61a7', 'sentence_builder', 'Складіть: «Усе це було лише непорозуміння.»', 'Sve je bio samo nesporazum.', '["samo", "je", "nesporazum.", "bio", "Sve"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3e2d21c0-1509-5b8b-b7c8-aa7a48879aae', 'listening', 'Прослухайте і складіть фразу', 'Jest. Ne javlja mi se dva dana.', '["Ne", "Jest.", "javlja", "mi", "dva", "se", "dana."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '28333b23-bbac-5310-b369-236612057161', 'listening_dialogue', 'Прослухайте розмову', 'він розсердився й кричав; трохи образився; піти на перерву', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Марко й Іван розмовляють після сварки на роботі.", "script": [{"speaker": "Marko", "hr": "Ivane, žao mi je zbog jučer. Naljutio sam se bez razloga.", "ua": "Іване, мені шкода через учорашнє. Я розсердився без причини."}, {"speaker": "Ivan", "hr": "Iskreno, malo sam bio uvrijeđen.", "ua": "Чесно, я трохи образився."}, {"speaker": "Marko", "hr": "Imao sam težak dan, ali nisam trebao vikati.", "ua": "У мене був важкий день, але мені не слід було кричати."}, {"speaker": "Ivan", "hr": "U redu, zaboravimo. Idemo na pauzu?", "ua": "Гаразд, забудьмо. Підемо на перерву?"}], "questions": [{"q_ua": "Чому Марко вибачається?", "options": ["він розсердився й кричав", "він запізнився", "він забув про зустріч"], "correct": 0, "answer_turn": 0}, {"q_ua": "Як почувався Іван?", "options": ["був радий", "трохи образився", "був байдужий"], "correct": 1, "answer_turn": 1}, {"q_ua": "Що пропонує Іван наприкінці?", "options": ["поговорити з шефом", "піти додому", "піти на перерву"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '28333b23-bbac-5310-b369-236612057161', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '36034317-42a3-54f8-a4f4-f588e2d292d1', 'speaking', 'Пробач мені, будь ласка.', 'Oprosti mi, molim te.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '35231322-9b9f-5ea4-b9dc-951b1781dea4', 'speaking', 'Заспокойся, поговорімо нормально.', 'Smiri se, razgovarajmo normalno.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '2b92a90c-bb54-5708-b1e5-c9eed34d9acd', 'write_message', 'Напишіть подрузі вибачення: ви не хотіли її образити, вам шкода, і пропонуєте зустрітися на каву.', 'Oprosti mi, nisam te htjela uvrijediti. Jako mi je žao. Idemo sutra na kavu?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі вибачення: ви не хотіли її образити, вам шкода, і пропонуєте зустрітися на каву.", "points": [{"ua": "не хотіли образити", "keys": [["uvrijed"]]}, {"ua": "вам шкода", "keys": [["žao"], ["oprosti"]]}, {"ua": "зустрітися на каву", "keys": [["kav"]]}], "hints": ["nisam te htjela uvrijediti", "žao mi je", "oprosti mi", "idemo na kavu?"], "models": ["Oprosti mi, nisam te htjela uvrijediti. Jako mi je žao. Idemo sutra na kavu?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '2b92a90c-bb54-5708-b1e5-c9eed34d9acd', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'f4e50df2-5a70-5880-851e-56324cb215cb', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Moja prijateljica nije ljuta na tebe. To je bio samo nesporazum.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи Оксані, що я її не ображалася і що це було непорозуміння.", "direction": "ua_hr", "points": [{"ua": "не ображається", "keys": [["uvrijeđen"], ["ljut"]]}, {"ua": "непорозуміння", "keys": [["nesporazum"]]}], "hints": [], "models": ["Moja prijateljica nije ljuta na tebe. To je bio samo nesporazum."], "source_ua": "Скажи Оксані, що я її не ображалася і що це було непорозуміння."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'f4e50df2-5a70-5880-851e-56324cb215cb', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6ef718ff-5a58-5f11-9b4b-b5a6e74da42f', v_lesson, 'Сварка з сестрою', 'Svađa sa sestrom', 5261, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('f81fe151-4c69-5a23-b808-7ee7ca3ac911', '6ef718ff-5a58-5f11-9b4b-b5a6e74da42f', 'Daša', 'Darja, zašto si tužna?', 'Дар’є, чому ти сумна?', 1);
  perform pg_temp.turn('69be7a10-1db0-55e1-9bb1-88b14b2bfceb', '6ef718ff-5a58-5f11-9b4b-b5a6e74da42f', 'Darja', 'Posvađala sam se sa sestrom. Rekla sam joj nešto ružno.', 'Я посварилася з сестрою. Я сказала їй щось негарне.', 2);
  perform pg_temp.turn('652b531c-1074-5131-9221-5af6925c0b2a', '6ef718ff-5a58-5f11-9b4b-b5a6e74da42f', 'Daša', 'Je li uvrijeđena?', 'Вона ображена?', 3);
  perform pg_temp.turn('8674b4b1-c0bc-51fd-b501-fdc92ef5405f', '6ef718ff-5a58-5f11-9b4b-b5a6e74da42f', 'Darja', 'Jest. Ne javlja mi se dva dana.', 'Так. Не озивається до мене два дні.', 4);
  perform pg_temp.turn('88f0a9cd-6257-57bf-8322-ac5285c41ec2', '6ef718ff-5a58-5f11-9b4b-b5a6e74da42f', 'Daša', 'Nazovi je i reci joj da ti je žao. Svađa zbog sitnice ne vrijedi.', 'Подзвони їй і скажи, що тобі шкода. Сварка через дрібницю того не варта.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('04f55de9-0ed7-5819-b4a7-0ae321a99b66', v_lesson, 'Вибачення', 'Isprika', 5262, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('15ff7de9-4b39-572f-89e4-58ff419cded3', '04f55de9-0ed7-5819-b4a7-0ae321a99b66', 'Darja', 'Oksana, dugujem ti ispriku. Nisam te htjela uvrijediti.', 'Оксано, я винна тобі вибачення. Я не хотіла тебе образити.', 1);
  perform pg_temp.turn('90f33d17-290c-58a2-b8cd-e513bea4cc40', '04f55de9-0ed7-5819-b4a7-0ae321a99b66', 'Oksana', 'Tvoje riječi su me povrijedile.', 'Твої слова мене зачепили.', 2);
  perform pg_temp.turn('cf36dd89-a403-5e3f-9d34-265ad9d0937e', '04f55de9-0ed7-5819-b4a7-0ae321a99b66', 'Darja', 'Znam. Bila sam umorna i nisam to tako mislila. Oprosti mi.', 'Знаю. Я була втомлена й не це мала на увазі. Пробач мені.', 3);
  perform pg_temp.turn('0bb99391-9224-5333-a296-2ba2dd3756f3', '04f55de9-0ed7-5819-b4a7-0ae321a99b66', 'Oksana', 'Dobro, opraštam ti. I ja sam vikala na tebe.', 'Добре, я тобі пробачаю. Я теж на тебе кричала.', 4);
  perform pg_temp.turn('1a0a1176-db29-5e73-9ac3-9be2a933a6fb', '04f55de9-0ed7-5819-b4a7-0ae321a99b66', 'Darja', 'Onda se pomirimo uz kavu?', 'Тоді помиримося за кавою?', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.4 · урок 27: Згоден чи ні? Моя думка — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'dbef7f5b-f911-5816-b398-c641f7d16dff';
  v_lesson constant uuid := 'f029711f-710e-5327-be4d-2310435e6eac';
  v_gid constant uuid := 'd777c847-266e-57ef-a5a2-f417f12f1b3e';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики INS'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A2.4: місце 5 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 27: Згоден чи ні? Моя думка', 'Lekcija 27: Slažem se ili ne? Moje mišljenje', '["Погодитися чи заперечити й пояснити чому", "Вживати орудний: slažem se s tobom / s kolegama, ne slažem se s njima"]'::jsonb, 20, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'slagati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ne slažem se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u pravu si', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nisi u pravu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'po meni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'argument', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uvjeriti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kompromis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'raspravljati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rasprava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'donekle', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nikako', v_pos);
  v_pos := pg_temp.word(v_lesson, 'istina je da', v_pos);
  v_pos := pg_temp.word(v_lesson, 's jedne strane', v_pos);
  v_pos := pg_temp.word(v_lesson, 's druge strane', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prednost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nedostatak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijedlog', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predložiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'protuargument', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '50a09b20-cbc0-5e37-ba9d-8e980261eedd', 'fill_in_the_blank', 'Slažem se ___ kolegama, to je dobar prijedlog.', 's', '["od", "za", "s", "sa"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '838044ce-76ea-500c-80ea-b6a1d40d5d93', 'multiple_choice', 'Що означає «u pravu si»?', 'ти маєш рацію', '["з іншого боку", "компроміс", "пропозиція", "ти маєш рацію"]'::jsonb, 'A2', 2, 'PUBLISHED', 'u pravu si', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e6391f10-1d7c-592a-8ea6-7f5894a2a9e0', 'multiple_choice', 'Що означає «rasprava»?', 'дискусія, суперечка', '["як на мене", "пропозиція", "дискусія, суперечка", "запропонувати"]'::jsonb, 'A2', 3, 'PUBLISHED', 'rasprava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ad082e2c-6a48-5164-b80e-d20aa4b4ab4e', 'multiple_choice', 'Що означає «nisi u pravu»?', 'ти не маєш рації', '["певною мірою", "аргумент", "компроміс", "ти не маєш рації"]'::jsonb, 'A2', 4, 'PUBLISHED', 'nisi u pravu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4f1b6981-33d2-5799-b0fd-3169ae1d5ca9', 'multiple_choice', 'Як хорватською «перевага»?', 'prednost', '["protuargument", "prednost", "stav", "raspravljati"]'::jsonb, 'A2', 5, 'PUBLISHED', 'prednost', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '03825d02-031e-5f68-9f83-7da0109b1762', 'multiple_choice', 'Як хорватською «я не згоден»?', 'ne slažem se', '["u pravu si", "nikako", "ne slažem se", "po meni"]'::jsonb, 'A2', 6, 'PUBLISHED', 'ne slažem se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '99f0be0d-b009-5161-95bc-d932cad23526', 'type_answer', 'Напишіть хорватською: «як на мене»', 'po meni', null, 'A2', 7, 'PUBLISHED', 'po meni', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf29cde6-8c6d-5611-851a-ee9206c2ce7f', 'type_answer', 'Напишіть хорватською: «позиція, ставлення»', 'stav', null, 'A2', 8, 'PUBLISHED', 'stav', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1b9556a7-f8f8-522d-bf32-679cb8ed1f70', 'type_answer', 'Напишіть хорватською: «певною мірою»', 'donekle', null, 'A2', 9, 'PUBLISHED', 'donekle', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4336f5da-3c6d-5132-95ff-4cc9e48031ef', 'sentence_builder', 'Складіть: «Я з тобою не згоден.»', 'Ne slažem se s tobom.', '["slažem", "se", "tobom.", "Ne", "s"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0f6e402c-31ce-5804-b7c3-1ab98a710afa', 'sentence_builder', 'Складіть: «Треба знайти компроміс.»', 'Moramo naći kompromis.', '["naći", "Moramo", "kompromis."]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '81a94378-f158-5914-bbe9-fcb0a9e18021', 'listening', 'Прослухайте і складіть фразу', 'Svakako se slažem s Vama.', '["s", "Vama.", "se", "Svakako", "slažem"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'dfb3f99b-dba5-5632-914d-300b7097114c', 'listening_dialogue', 'Прослухайте розмову', 'задалеко; в Опатію; годину', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Даша й Дар’я обговорюють, куди поїхати у вихідні.", "script": [{"speaker": "Daša", "hr": "Predlažem da idemo u Rovinj.", "ua": "Пропоную поїхати в Ровінь."}, {"speaker": "Darja", "hr": "Ne slažem se, to je predaleko za jedan dan.", "ua": "Не згодна, це задалеко для одного дня."}, {"speaker": "Daša", "hr": "U pravu si. Što kažeš na Opatiju? Sat vremena vožnje.", "ua": "Твоя правда. Що скажеш про Опатію? Година їзди."}, {"speaker": "Darja", "hr": "Svakako! Tamo je lijepa šetnica uz more.", "ua": "Безумовно! Там гарна набережна вздовж моря."}], "questions": [{"q_ua": "Чому Дар’я не хоче в Ровінь?", "options": ["там дорого", "задалеко", "там дощ"], "correct": 1, "answer_turn": 1}, {"q_ua": "Куди вони поїдуть?", "options": ["в Опатію", "у Ровінь", "у Пулу"], "correct": 0, "answer_turn": 2}, {"q_ua": "Скільки їхати?", "options": ["пів години", "дві години", "годину"], "correct": 2, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'dfb3f99b-dba5-5632-914d-300b7097114c', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '98627a8b-045d-59fd-a5ef-34d9dcf35e77', 'speaking', 'Як на мене, це погана ідея.', 'Po meni, to je loša ideja.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ec5ae53-8222-5db2-91fa-3a2b9e5af042', 'speaking', 'Певною мірою я погоджуюся.', 'Donekle se slažem.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '76123415-d885-5e95-b2c6-325949d6be13', 'write_message', 'Напишіть колезі, що ви згодні з її пропозицією працювати з дому, але не в п’ятницю, а в середу.', 'Slažem se s tobom da je rad od kuće dobra ideja, ali ne petkom. Srijeda je bolja.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть колезі, що ви згодні з її пропозицією працювати з дому, але не в п’ятницю, а в середу.", "points": [{"ua": "згодні", "keys": [["slaž"]]}, {"ua": "з дому", "keys": [["kuć"]]}, {"ua": "у середу, не в п’ятницю", "keys": [["srijed"]]}], "hints": ["slažem se s tobom", "rad od kuće", "ali ne petkom", "srijeda je bolja"], "models": ["Slažem se s tobom da je rad od kuće dobra ideja, ali ne petkom. Srijeda je bolja."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '76123415-d885-5e95-b2c6-325949d6be13', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'cc008d2f-35e9-5082-96aa-3e0afaefe4f3', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Moj kolega se slaže s Vama, ali s druge strane to će biti skuplje.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи шефові, що я згоден з ним, але з іншого боку це буде дорожче.", "direction": "ua_hr", "points": [{"ua": "згоден", "keys": [["slaže"]]}, {"ua": "з іншого боку", "keys": [["druge strane"]]}, {"ua": "дорожче", "keys": [["skuplj"]]}], "hints": [], "models": ["Moj kolega se slaže s Vama, ali s druge strane to će biti skuplje."], "source_ua": "Скажи шефові, що я згоден з ним, але з іншого боку це буде дорожче."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'cc008d2f-35e9-5082-96aa-3e0afaefe4f3', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7bef337d-7c05-5914-ac05-1dabb977a838', v_lesson, 'Місто чи село?', 'Grad ili selo?', 5271, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('184a1959-b34c-5e78-97cd-fe9e195e5cdf', '7bef337d-7c05-5914-ac05-1dabb977a838', 'Ivan', 'Po meni, život na selu je bolji za djecu.', 'Як на мене, життя в селі краще для дітей.', 1);
  perform pg_temp.turn('a4bedc7e-f2df-567b-ba28-7b0491900852', '7bef337d-7c05-5914-ac05-1dabb977a838', 'Darja', 'Donekle se slažem. S jedne strane, tamo je mir i priroda.', 'Певною мірою погоджуюся. З одного боку, там тиша й природа.', 2);
  perform pg_temp.turn('2dc14996-28bf-5e13-8f51-731b63fababb', '7bef337d-7c05-5914-ac05-1dabb977a838', 'Ivan', 'A s druge strane?', 'А з іншого боку?', 3);
  perform pg_temp.turn('9b9af980-f8ae-5fd7-8f90-2493725a8edf', '7bef337d-7c05-5914-ac05-1dabb977a838', 'Darja', 'Nedostatak je loš prijevoz i nema škole blizu.', 'Недолік — поганий транспорт і немає школи поблизу.', 4);
  perform pg_temp.turn('8a821d26-addd-504d-a460-7cfb4e7ccb91', '7bef337d-7c05-5914-ac05-1dabb977a838', 'Ivan', 'To je dobar argument. Moramo naći kompromis — kuća blizu grada.', 'Це добрий аргумент. Треба знайти компроміс — будинок біля міста.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a6eba3f3-9c23-5ded-b7e1-5f6bb3eb9d56', v_lesson, 'Нарада', 'Sastanak', 5272, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('6210dcc4-d018-54d2-832c-8aa5ee4bbb64', 'a6eba3f3-9c23-5ded-b7e1-5f6bb3eb9d56', 'Šef', 'Kolege, predlažem da radimo od kuće petkom. Slažete li se?', 'Колеги, пропоную працювати з дому по п’ятницях. Ви згодні?', 1);
  perform pg_temp.turn('a99e4f6b-e960-5ae4-8c6e-1aeebad4f2da', 'a6eba3f3-9c23-5ded-b7e1-5f6bb3eb9d56', 'Daša', 'Svakako se slažem s Vama.', 'Безумовно, я з вами згодна.', 2);
  perform pg_temp.turn('3938c341-09ab-59b9-a4ef-d9860871101c', 'a6eba3f3-9c23-5ded-b7e1-5f6bb3eb9d56', 'Marko', 'Ja se nikako ne slažem. Petkom imamo najviše klijenata.', 'А я аж ніяк не згоден. По п’ятницях у нас найбільше клієнтів.', 3);
  perform pg_temp.turn('3e052d3b-6c98-5fa1-8351-6cb529a262ee', 'a6eba3f3-9c23-5ded-b7e1-5f6bb3eb9d56', 'Šef', 'U pravu ste, Marko. Što mislite o srijedi?', 'Ви маєте рацію, Марку. Що думаєте про середу?', 4);
  perform pg_temp.turn('1c8eb77c-55e7-5b14-9ce6-e87599badedc', 'a6eba3f3-9c23-5ded-b7e1-5f6bb3eb9d56', 'Marko', 'Srijeda je dobar kompromis.', 'Середа — добрий компроміс.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.4 · урок 28: Скарга й рекламація — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'dbef7f5b-f911-5816-b398-c641f7d16dff';
  v_lesson constant uuid := '2760a712-4fa2-56fd-b036-8427682ad804';
  v_gid constant uuid := '2d4021eb-fd3e-5388-a44b-3f541c5990f8';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики ZAM'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A2.4: місце 6 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 28: Скарга й рекламація', 'Lekcija 28: Prigovor i žalba', '["Поскаржитися в магазині чи сервісі й вимагати своїх прав", "Вживати займенники: Prodali su mi ga…, Vratite mi novac"]'::jsonb, 20, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'prigovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pisani prigovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žaliti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potrošač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prava potrošača', v_pos);
  v_pos := pg_temp.word(v_lesson, 'knjiga žalbe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'voditelj trgovine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nezadovoljan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neprihvatljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'servis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jamstveni list', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rok za odgovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zahtijevati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nadoknaditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šteta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispričati se kupcu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nevaljao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispravak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udruga za zaštitu potrošača', v_pos);
  v_pos := pg_temp.word(v_lesson, 'reklamirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neljubazan', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '32e9645d-1277-583e-8864-49eed1135aa5', 'fill_in_the_blank', 'Prodali ste ___ neispravnu perilicu.', 'mi', '["moj", "mene", "mi", "me"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c3e0f72b-2012-530d-b66f-0f23ac235d78', 'multiple_choice', 'Що означає «ispričati se kupcu»?', 'вибачитися перед покупцем', '["керівник магазину", "письмова скарга", "вибачитися перед покупцем", "неввічливий"]'::jsonb, 'A2', 2, 'PUBLISHED', 'ispričati se kupcu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b1028bac-9446-5b87-bd97-d8cec886abf8', 'multiple_choice', 'Що означає «prava potrošača»?', 'права споживачів', '["письмова скарга", "незадоволений", "вибачитися перед покупцем", "права споживачів"]'::jsonb, 'A2', 3, 'PUBLISHED', 'prava potrošača', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ddd46ed5-df8e-5d4f-b90b-57e5457da4e2', 'multiple_choice', 'Що означає «prigovor»?', 'скарга, претензія', '["вимагати", "скарга, претензія", "неввічливий", "строк відповіді"]'::jsonb, 'A2', 4, 'PUBLISHED', 'prigovor', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e545dbf5-fb1d-5d8b-b2bf-35c4058ffef0', 'multiple_choice', 'Як хорватською «книга скарг»?', 'knjiga žalbe', '["knjiga žalbe", "jamstveni list", "žaliti se", "prava potrošača"]'::jsonb, 'A2', 5, 'PUBLISHED', 'knjiga žalbe', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '387f10a2-e062-550c-a0bc-54a211d026d7', 'multiple_choice', 'Як хорватською «виправлення»?', 'ispravak', '["ispravak", "pisani prigovor", "potrošač", "žaliti se"]'::jsonb, 'A2', 6, 'PUBLISHED', 'ispravak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f3036313-8ca2-55cb-8b05-de4ee2754397', 'type_answer', 'Напишіть хорватською: «неприйнятний»', 'neprihvatljiv', null, 'A2', 7, 'PUBLISHED', 'neprihvatljiv', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '06ec403b-6353-5b66-b3af-716951b879e6', 'type_answer', 'Напишіть хорватською: «вимагати»', 'zahtijevati', null, 'A2', 8, 'PUBLISHED', 'zahtijevati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cf1bfe1d-b67b-5edc-84d4-a8910ca571b9', 'type_answer', 'Напишіть хорватською: «скаржитися»', 'žaliti se', null, 'A2', 9, 'PUBLISHED', 'žaliti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c603c387-a14a-5d77-b8b1-613b5f749d20', 'sentence_builder', 'Складіть: «Вимагаю повернення грошей.»', 'Zahtijevam povrat novca.', '["povrat", "novca.", "Zahtijevam"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5464458a-98ae-50cc-8599-97103b3270e1', 'sentence_builder', 'Складіть: «Я незадоволена послугою.»', 'Nezadovoljna sam uslugom.', '["uslugom.", "sam", "Nezadovoljna"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dffe0bd3-7bb8-523e-aa8f-1d01316678b1', 'listening', 'Прослухайте і складіть фразу', 'Izvolite, ja sam voditeljica. Što se dogodilo?', '["voditeljica.", "sam", "se", "Izvolite,", "ja", "dogodilo?", "Što"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'd0c9c1fc-abfe-596d-88ea-42ef44163d74', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'машина несправна; нову машину або гроші; чек', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Вам телефонували з магазину щодо вашої скарги.", "script": [{"hr": "Dobar dan, zovem iz trgovine Elektro Plus zbog Vašeg prigovora.", "ua": "Добрий день, телефоную з магазину «Електро Плюс» щодо вашої скарги."}, {"hr": "Servis je potvrdio da je perilica neispravna.", "ua": "Сервіс підтвердив, що пральна машина несправна."}, {"hr": "Možete doći po novu perilicu ili dobiti povrat novca.", "ua": "Ви можете прийти по нову пральну машину або отримати гроші назад."}, {"hr": "Ponesite račun, radimo do osam navečer.", "ua": "Візьміть чек, ми працюємо до восьмої вечора."}], "questions": [{"q_ua": "Що підтвердив сервіс?", "options": ["машина несправна", "машина в порядку", "потрібна доплата"], "correct": 0, "answer_turn": 1}, {"q_ua": "Що можна отримати?", "options": ["лише ремонт", "нову машину або гроші", "знижку"], "correct": 1, "answer_turn": 2}, {"q_ua": "Що треба взяти?", "options": ["паспорт", "гарантійний талон", "чек"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'd0c9c1fc-abfe-596d-88ea-42ef44163d74', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fe267802-c6b0-5dd2-b71b-dd3d4802ce83', 'speaking', 'Я хочу поговорити з керівником.', 'Želim razgovarati s voditeljem.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '18c6c960-d6fc-554d-869e-f5adde88360f', 'speaking', 'Пральна машина зламалася через місяць.', 'Perilica se pokvarila nakon mjesec dana.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '5b5dfca2-85e2-57d8-bd69-49f38faee08b', 'write_message', 'Напишіть письмову скаргу в магазин: ви купили пилосос 3 травня, він не працює; вимагаєте заміну або повернення грошей.', 'Poštovani, 3. svibnja kupila sam usisavač koji ne radi. Zahtijevam zamjenu ili povrat novca.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть письмову скаргу в магазин: ви купили пилосос 3 травня, він не працює; вимагаєте заміну або повернення грошей.", "points": [{"ua": "купили пилосос", "keys": [["usisavač"]]}, {"ua": "не працює", "keys": [["ne radi"], ["pokvari"]]}, {"ua": "заміна або повернення грошей", "keys": [["povrat"], ["zamjen"]]}], "hints": ["kupila sam usisavač", "ne radi", "zahtijevam zamjenu ili povrat novca"], "models": ["Poštovani, 3. svibnja kupila sam usisavač koji ne radi. Zahtijevam zamjenu ili povrat novca."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '5b5dfca2-85e2-57d8-bd69-49f38faee08b', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'c5487c78-f716-5fff-ba40-f6033bfb046a', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Naplatili ste mu dvaput. Molim Vas, ispravite račun.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи продавцеві, що з мене взяли гроші двічі, і попроси виправити рахунок.", "direction": "ua_hr", "points": [{"ua": "взяли двічі", "keys": [["dvaput"], ["dva puta"]]}, {"ua": "виправити рахунок", "keys": [["ispravi"], ["ispravak"]]}], "hints": [], "models": ["Naplatili ste mu dvaput. Molim Vas, ispravite račun."], "source_ua": "Скажи продавцеві, що з мене взяли гроші двічі, і попроси виправити рахунок."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'c5487c78-f716-5fff-ba40-f6033bfb046a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a9c306d1-db8a-5122-89ad-6e73d4201236', v_lesson, 'Зламана пральна машина', 'Pokvarena perilica', 5281, 'A2', 'shopping', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('abdf9ee3-cc4d-5c9a-b15c-5ec16d73850f', 'a9c306d1-db8a-5122-89ad-6e73d4201236', 'Darja', 'Dobar dan. Perilica koju sam kupila se pokvarila nakon mjesec dana.', 'Добрий день. Пральна машина, яку я купила, зламалася через місяць.', 1);
  perform pg_temp.turn('723a72f7-9de2-536b-a9b5-19920840da47', 'a9c306d1-db8a-5122-89ad-6e73d4201236', 'Prodavač', 'Imate li račun i jamstveni list?', 'У вас є чек і гарантійний талон?', 2);
  perform pg_temp.turn('e490f5bf-cffe-5c72-8e8c-b722741bf812', 'a9c306d1-db8a-5122-89ad-6e73d4201236', 'Darja', 'Imam. Prodali ste mi je kao novu, a ne radi.', 'Є. Ви продали її мені як нову, а вона не працює.', 3);
  perform pg_temp.turn('c7dbc56e-5b15-583e-9fed-bbefbe231674', 'a9c306d1-db8a-5122-89ad-6e73d4201236', 'Prodavač', 'Odnijet ćemo je u servis.', 'Ми віддамо її в сервіс.', 4);
  perform pg_temp.turn('a8389a15-bddc-5c48-90a5-710cbe7a98f4', 'a9c306d1-db8a-5122-89ad-6e73d4201236', 'Darja', 'Ne slažem se. Zahtijevam novu perilicu ili povrat novca.', 'Я не згодна. Вимагаю нову пральну машину або повернення грошей.', 5);
  perform pg_temp.turn('ce06c124-6373-5199-9023-0ca7adf0210c', 'a9c306d1-db8a-5122-89ad-6e73d4201236', 'Prodavač', 'Onda napišite pisani prigovor. Rok za odgovor je petnaest dana.', 'Тоді напишіть письмову скаргу. Строк відповіді — п’ятнадцять днів.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3e091178-a6fb-514b-9c2f-c1b53290a288', v_lesson, 'З керівником', 'S voditeljem', 5282, 'A2', 'shopping', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('c5d4c5de-82e9-5297-a4a8-885902b22b45', '3e091178-a6fb-514b-9c2f-c1b53290a288', 'Ivan', 'Želim razgovarati s voditeljem trgovine.', 'Я хочу поговорити з керівником магазину.', 1);
  perform pg_temp.turn('d3178419-4b28-59db-a053-33cb04f7c0da', '3e091178-a6fb-514b-9c2f-c1b53290a288', 'Voditeljica', 'Izvolite, ja sam voditeljica. Što se dogodilo?', 'Прошу, я керівниця. Що сталося?', 2);
  perform pg_temp.turn('6e84a042-3d62-5213-b601-937350865bd3', '3e091178-a6fb-514b-9c2f-c1b53290a288', 'Ivan', 'Prodavač je bio neljubazan. To je neprihvatljivo.', 'Продавець був неввічливий. Це неприйнятно.', 3);
  perform pg_temp.turn('e3d8c31e-7aaf-5074-8ce9-b738c24a1358', '3e091178-a6fb-514b-9c2f-c1b53290a288', 'Voditeljica', 'Ispričavam Vam se. Razgovarat ću s njim.', 'Перепрошую вас. Я поговорю з ним.', 4);
  perform pg_temp.turn('5530a38c-c6b0-515a-ac65-d4d9664fdf19', '3e091178-a6fb-514b-9c2f-c1b53290a288', 'Ivan', 'Hvala. I tražim ispravak računa, naplatili su mi dvaput.', 'Дякую. І прошу виправити рахунок, з мене взяли двічі.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.4 · урок 29: Сусіди й шум: домовляємося — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'dbef7f5b-f911-5816-b398-c641f7d16dff';
  v_lesson constant uuid := '5252662a-abfc-517a-9bde-8683121a53c5';
  v_gid constant uuid := 'd777c847-266e-57ef-a5a2-f417f12f1b3e';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики INS'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A2.4: місце 7 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 29: Сусіди й шум: домовляємося', 'Lekcija 29: Susjedi i buka: dogovaramo se', '["Ввічливо поговорити із сусідом про шум, паркування, домашніх тварин", "Вживати орудний: razgovarati sa susjedima, pred zgradom, među stanarima"]'::jsonb, 20, 'PUBLISHED', 7);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'stanar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'suvlasnici', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predstavnik suvlasnika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sastanak stanara', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oglasna ploča', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glasna glazba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lupati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smetati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obzir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obziran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prekršiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pritužiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'komunalni redar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zajednički prostor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'parkirati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ulaz u zgradu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vlaga u stanu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poplaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'susjedski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izaći u susret', v_pos);
  v_pos := pg_temp.word(v_lesson, 'utišati', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e508569-9d16-5835-88ea-90e78a51be08', 'fill_in_the_blank', 'Razgovarala sam ___ susjedima o buci.', 'sa', '["sa", "od", "s", "kod"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bbb38742-4bab-512b-a528-df5d53a4e8fe', 'multiple_choice', 'Що означає «vlaga u stanu»?', 'вогкість у квартирі', '["сусідський", "вогкість у квартирі", "під’їзд", "піти назустріч"]'::jsonb, 'A2', 2, 'PUBLISHED', 'vlaga u stanu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '63dbfe40-befb-511e-b48a-96255b1753fe', 'multiple_choice', 'Що означає «oglasna ploča»?', 'дошка оголошень', '["припаркуватися", "дошка оголошень", "грюкати, стукати", "під’їзд"]'::jsonb, 'A2', 3, 'PUBLISHED', 'oglasna ploča', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0ced8a6e-4356-541e-9efe-d032e2879c6c', 'multiple_choice', 'Що означає «susjedski»?', 'сусідський', '["порушити", "сусідський", "вогкість у квартирі", "дошка оголошень"]'::jsonb, 'A2', 4, 'PUBLISHED', 'susjedski', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9b4f6a49-4fe3-57fd-8933-10c28c91af39', 'multiple_choice', 'Як хорватською «припаркуватися»?', 'parkirati se', '["stanar", "predstavnik suvlasnika", "parkirati se", "susjedski"]'::jsonb, 'A2', 5, 'PUBLISHED', 'parkirati se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd06ea13e-7d0d-5b57-ba6f-bed0ec5873f7', 'multiple_choice', 'Як хорватською «поскаржитися»?', 'pritužiti se', '["suvlasnici", "pritužiti se", "oglasna ploča", "ulaz u zgradu"]'::jsonb, 'A2', 6, 'PUBLISHED', 'pritužiti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '71048f18-8cd0-50f4-bbc0-9309aa43fa6a', 'type_answer', 'Напишіть хорватською: «гучна музика»', 'glasna glazba', null, 'A2', 7, 'PUBLISHED', 'glasna glazba', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ee0e32c-f29c-5888-a59a-1e8208f316df', 'type_answer', 'Напишіть хорватською: «затопити»', 'poplaviti', null, 'A2', 8, 'PUBLISHED', 'poplaviti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '018f22b9-1a2e-52b2-9d37-3e58ccb73fcd', 'type_answer', 'Напишіть хорватською: «порушити»', 'prekršiti', null, 'A2', 9, 'PUBLISHED', 'prekršiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '01f7d1e3-7332-5a2d-9ad1-4428cc5b1c9d', 'sentence_builder', 'Складіть: «Перепрошую, що турбую.»', 'Oprostite što smetam.', '["što", "Oprostite", "smetam."]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '72f6b1ea-654a-5173-8a67-ee951bbb5cd7', 'sentence_builder', 'Складіть: «Збори мешканців у четвер.»', 'Sastanak stanara je u četvrtak.', '["četvrtak.", "Sastanak", "je", "stanara", "u"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f8c7f1ee-aa3d-5958-88fa-23cbc615abba', 'listening', 'Прослухайте і складіть фразу', 'Oh, oprostite, nisam znao da se čuje. Utišat ću.', '["znao", "da", "oprostite,", "nisam", "ću.", "se", "čuje.", "Oh,", "Utišat"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'a51b58cd-5ae2-5e64-b38f-0768bfec6808', 'listening_dialogue', 'Прослухайте оголошення', 'ліфт; до 16:00; прибрати велосипеди', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Представник будинку читає оголошення на зборах.", "script": [{"hr": "Poštovani stanari, sljedeći tjedan se mijenja lift.", "ua": "Шановні мешканці, наступного тижня міняють ліфт."}, {"hr": "Radovi traju od ponedjeljka do petka, od osam do šesnaest sati.", "ua": "Роботи тривають з понеділка до п’ятниці, з восьмої до шістнадцятої."}, {"hr": "Molimo vas da bicikle maknete iz zajedničkog prostora.", "ua": "Просимо прибрати велосипеди зі спільного приміщення."}], "questions": [{"q_ua": "Що міняють?", "options": ["ліфт", "двері під’їзду", "дах"], "correct": 0, "answer_turn": 0}, {"q_ua": "До котрої тривають роботи щодня?", "options": ["до 12:00", "до 16:00", "до 20:00"], "correct": 1, "answer_turn": 1}, {"q_ua": "Що просять зробити?", "options": ["не паркуватися", "заплатити внесок", "прибрати велосипеди"], "correct": 2, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'a51b58cd-5ae2-5e64-b38f-0768bfec6808', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4c5cf1ca-356b-5737-a98f-30bab1e339af', 'speaking', 'Музика дуже гучна.', 'Glazba je jako glasna.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6e7c59d7-5669-54d0-9b88-7c89aa3671a6', 'speaking', 'Ви припаркувалися на моє місце.', 'Parkirali ste se na moje mjesto.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '1bdceef1-45a5-5bd8-9291-d5aa2eda8a0a', 'write_message', 'Напишіть записку сусідові: ваш син спить після обіду, ви просите не свердлити з 14 до 16.', 'Poštovani susjede, moj sin spava poslije ručka. Molim Vas da ne bušite od 14 do 16 sati. Hvala!', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть записку сусідові: ваш син спить після обіду, ви просите не свердлити з 14 до 16.", "points": [{"ua": "син спить", "keys": [["spava"]]}, {"ua": "не свердлити", "keys": [["buši"]]}, {"ua": "з 14 до 16", "keys": [["14"], ["dva"]]}], "hints": ["poštovani susjede", "moj sin spava poslije ručka", "molim Vas da ne bušite", "od 14 do 16"], "models": ["Poštovani susjede, moj sin spava poslije ručka. Molim Vas da ne bušite od 14 do 16 sati. Hvala!"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '1bdceef1-45a5-5bd8-9291-d5aa2eda8a0a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'eeafc6d5-de69-5e7a-8811-81b40b0e49fc', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'U njezinoj kupaonici je vlaga. Čini se da ste ih poplavili.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи сусідові, що в нас у ванній вогкість і, здається, він нас затопив.", "direction": "ua_hr", "points": [{"ua": "вогкість у ванній", "keys": [["vlag"]]}, {"ua": "затопив", "keys": [["poplavi"]]}], "hints": [], "models": ["U njezinoj kupaonici je vlaga. Čini se da ste ih poplavili."], "source_ua": "Скажи сусідові, що в нас у ванній вогкість і, здається, він нас затопив."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'eeafc6d5-de69-5e7a-8811-81b40b0e49fc', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('318010bf-019c-5e76-86ff-4cb83577f32c', v_lesson, 'Шум увечері', 'Buka navečer', 5291, 'A2', 'housing', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('175194f2-c446-54fa-88a9-be1293781ab4', '318010bf-019c-5e76-86ff-4cb83577f32c', 'Darja', 'Dobra večer, susjede. Oprostite što smetam.', 'Добрий вечір, сусіде. Перепрошую, що турбую.', 1);
  perform pg_temp.turn('6b0eac7d-08ed-5eb3-8c5f-751ee44842fd', '318010bf-019c-5e76-86ff-4cb83577f32c', 'Susjed', 'Dobra večer. Što je bilo?', 'Добрий вечір. Що сталося?', 2);
  perform pg_temp.turn('3e5e1211-5139-50c7-be1b-ba91bc35663f', '318010bf-019c-5e76-86ff-4cb83577f32c', 'Darja', 'Glazba je jako glasna, a djeca moraju spavati.', 'Музика дуже гучна, а діти мають спати.', 3);
  perform pg_temp.turn('14e9a1f4-57fe-5491-be7f-7cbb9078cd3a', '318010bf-019c-5e76-86ff-4cb83577f32c', 'Susjed', 'Oh, oprostite, nisam znao da se čuje. Utišat ću.', 'Ой, перепрошую, я не знав, що чути. Зроблю тихіше.', 4);
  perform pg_temp.turn('011e9fad-068d-5e97-89a1-1a1e9ccf6ac2', '318010bf-019c-5e76-86ff-4cb83577f32c', 'Darja', 'Hvala što ste nam izašli u susret.', 'Дякую, що пішли нам назустріч.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4be1d05d-bb39-5efc-a3fb-366c30c32bf7', v_lesson, 'Збори мешканців', 'Sastanak stanara', 5292, 'A2', 'housing', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('795070ea-8ceb-5b54-bf2a-0d4451ea1243', '4be1d05d-bb39-5efc-a3fb-366c30c32bf7', 'Predstavnica', 'Dobro došli na sastanak stanara. Imamo nekoliko pritužbi.', 'Ласкаво просимо на збори мешканців. У нас кілька скарг.', 1);
  perform pg_temp.turn('90596d03-9988-5b14-81d2-0a68aa8850ec', '4be1d05d-bb39-5efc-a3fb-366c30c32bf7', 'Marko', 'Netko se stalno parkira pred ulazom u zgradu.', 'Хтось постійно паркується перед під’їздом.', 2);
  perform pg_temp.turn('a3200200-eb6e-56ea-8420-12d74eec9e3f', '4be1d05d-bb39-5efc-a3fb-366c30c32bf7', 'Darja', 'I bicikli su u zajedničkom prostoru među kolicima.', 'І велосипеди в спільному приміщенні серед дитячих візків.', 3);
  perform pg_temp.turn('f3b28f3f-dc1d-561f-85ca-fe861afd997a', '4be1d05d-bb39-5efc-a3fb-366c30c32bf7', 'Predstavnica', 'Dogovorimo se: bicikli idu u podrum. Obavijest ću staviti na oglasnu ploču.', 'Домовмося: велосипеди — у підвал. Оголошення я повішу на дошку.', 4);
  perform pg_temp.turn('dbd8fe83-9949-5a17-a80b-c6141820f78b', '4be1d05d-bb39-5efc-a3fb-366c30c32bf7', 'Marko', 'Slažem se. Malo obzira i svi ćemo živjeti mirno.', 'Згоден. Трохи поваги до інших — і всі житимемо спокійно.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- 3. Модуль і юніт — опубліковані
update public.modules set status = 'PUBLISHED', title_ua = 'Модуль A2.4 — Люди й стосунки: характер, свята, конфлікти', title_hr = 'Modul A2.4 — Ljudi i odnosi: karakter, slavlja, sukobi' where id = '8fad33b4-f461-5119-b5e5-f94b700e283c';
update public.units set status = 'PUBLISHED' where id = 'dbef7f5b-f911-5816-b398-c641f7d16dff';

-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('7b43692b-44ae-5e4f-9022-4290ce7b5eaa', '68f2ada8-2352-5450-a073-72754ae0feb8', '75a84442-280d-56be-b746-81ca57caa0b5', '6fbe028c-f4c3-50b2-b282-84f62f5d4c78', 'f029711f-710e-5327-be4d-2310435e6eac', '2760a712-4fa2-56fd-b036-8427682ad804', '5252662a-abfc-517a-9bde-8683121a53c5')
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
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 20 or l.unit_id <> 'dbef7f5b-f911-5816-b398-c641f7d16dff');
  select count(*) into v_titles from (values ('7b43692b-44ae-5e4f-9022-4290ce7b5eaa'::uuid, 'Урок 23:%', 1), ('68f2ada8-2352-5450-a073-72754ae0feb8'::uuid, 'Урок 24:%', 2), ('75a84442-280d-56be-b746-81ca57caa0b5'::uuid, 'Урок 25:%', 3), ('6fbe028c-f4c3-50b2-b282-84f62f5d4c78'::uuid, 'Урок 26:%', 4), ('f029711f-710e-5327-be4d-2310435e6eac'::uuid, 'Урок 27:%', 5), ('2760a712-4fa2-56fd-b036-8427682ad804'::uuid, 'Урок 28:%', 6), ('5252662a-abfc-517a-9bde-8683121a53c5'::uuid, 'Урок 29:%', 7)) as t(id, pat, o)
    left join public.lessons l on l.id = t.id and l.title_ua like t.pat and l.order_index = t.o
   where l.id is null;
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
      where l.level_code = 'A2' and l.status = 'PUBLISHED' and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A2.4: % уроків з неправильним складом', v_bad; end if;
  if v_titles > 0 then raise exception 'Модуль A2.4: % уроків не на своєму місці чи з неправильним номером', v_titles; end if;
  if v_words > 0 then raise exception 'A2: % слів повторюються в кількох уроках', v_words; end if;
  if (select status from public.modules where id = '8fad33b4-f461-5119-b5e5-f94b700e283c') <> 'PUBLISHED' then raise exception 'Модуль A2.4 не опубліковано'; end if;
  raise notice 'Готово: модуль A2.4 — 7 уроків, слів 147';
end $$;

commit;
