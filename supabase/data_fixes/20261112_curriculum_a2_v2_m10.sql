-- =====================================================================
-- Програма A2 v2 · модуль A2.10 «Медіа, культура й думки» · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2.py 10 (не редагуйте вручну).
--
-- Рішення власника 2026-11-12: 20–25 нових слів на урок, 90–95 % слів — нові для рівня, діалоги під тему,
-- частіше Даша / Дар’я; «Прослухайте діалог чи оголошення» в кожному уроці; бета (PUBLISHED).
--   * Уроки 60–65 (6): слів у них 124. Кожен: 20–25 слів, 2 діалоги, 15 вправ
--     (одна — «Прослухайте діалог чи оголошення»), «Напишіть повідомлення» і «Перекажіть другу» (ua → hr, необов’язкові), 20 хв.
--   * Слова: 124 (нові — PUBLISHED; ті, що вже є в словнику, не змінюються).
--   * Модуль і юніт A2.10 → PUBLISHED. Потрібен уже запущений 20261112_curriculum_a2_v2_00_structure.sql.
--   * Нічого не видаляє. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.units where id = 'e9d667aa-87ee-5ea7-a0b5-a94f070e6f1d') then
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

-- 1. Слова уроків A2.10 (124): нові — PUBLISHED (бета); наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A2', t.ua, t.vtype, t.forms, t.examples, 'PUBLISHED', 'claude_curriculum_a2_v2'
  from jsonb_to_recordset('[{"lemma": "vijesti", "normalized": "vijesti", "pos": "noun", "ua": "новини", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Vijesti slušam u autu."]}, {"lemma": "članak", "normalized": "clanak", "pos": "noun", "ua": "стаття", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Pročitala sam zanimljiv članak o Splitu."]}, {"lemma": "portal", "normalized": "portal", "pos": "noun", "ua": "новинний сайт, портал", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Vijesti čitam na portalima."]}, {"lemma": "novinar", "normalized": "novinar", "pos": "noun", "ua": "журналіст", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Novinar je razgovarao s gradonačelnikom."]}, {"lemma": "naslov", "normalized": "naslov", "pos": "noun", "ua": "заголовок", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Naslov je bolji od članka."]}, {"lemma": "naslovnica", "normalized": "naslovnica", "pos": "noun", "ua": "перша шпальта, головна сторінка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ta vijest je na naslovnici."]}, {"lemma": "lažne vijesti", "normalized": "lazne vijesti", "pos": "phrase", "ua": "фейкові новини", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Lažne vijesti se brzo šire."]}, {"lemma": "provjeriti izvor", "normalized": "provjeriti izvor", "pos": "phrase", "ua": "перевірити джерело", "vtype": "chunk", "forms": {}, "examples": ["Uvijek provjeri izvor informacije."]}, {"lemma": "radijska postaja", "normalized": "radijska postaja", "pos": "phrase", "ua": "радіостанція", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Koja je tvoja omiljena radijska postaja?"]}, {"lemma": "emisija", "normalized": "emisija", "pos": "noun", "ua": "передача", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Slušam jutarnju emisiju na Radiju Rijeka."]}, {"lemma": "slušatelj", "normalized": "slusatelj", "pos": "noun", "ua": "слухач", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Slušatelji mogu nazvati u studio."]}, {"lemma": "podcast", "normalized": "podcast", "pos": "noun", "ua": "подкаст", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Slušam podcast o povijesti."]}, {"lemma": "epizoda", "normalized": "epizoda", "pos": "noun", "ua": "епізод, серія", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Nova epizoda izlazi svakog petka."]}, {"lemma": "pretplatiti se", "normalized": "pretplatiti se", "pos": "verb", "ua": "підписатися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "pretplaćivati se"}, "examples": ["Pretplatila sam se na njihov kanal."]}, {"lemma": "Dnevnik", "normalized": "dnevnik", "pos": "noun", "ua": "вечірні новини (на HRT)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Moj djed gleda Dnevnik u sedam."]}, {"lemma": "pročitala sam da", "normalized": "procitala sam da", "pos": "phrase", "ua": "я прочитала, що", "vtype": "chunk", "forms": {}, "examples": ["Pročitala sam da se gradi novi most."]}, {"lemma": "kažu da", "normalized": "kazu da", "pos": "phrase", "ua": "кажуть, що", "vtype": "chunk", "forms": {}, "examples": ["Kažu da će cijene opet rasti."]}, {"lemma": "prema najavi", "normalized": "prema najavi", "pos": "phrase", "ua": "за анонсом, як повідомляють", "vtype": "chunk", "forms": {}, "examples": ["Prema najavi, koncert počinje u devet."]}, {"lemma": "najava", "normalized": "najava", "pos": "noun", "ua": "анонс", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Vidjela sam najavu za novu emisiju."]}, {"lemma": "aktualno", "normalized": "aktualno", "pos": "adverb", "ua": "актуально, на часі", "vtype": "core", "forms": {}, "examples": ["Što je danas aktualno u gradu?"]}, {"lemma": "lokalne vijesti", "normalized": "lokalne vijesti", "pos": "phrase", "ua": "місцеві новини", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Lokalne vijesti čitam na portalu grada."]}, {"lemma": "mali oglasi", "normalized": "mali oglasi", "pos": "phrase", "ua": "приватні оголошення", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Bicikl sam prodala preko malih oglasa."]}, {"lemma": "oglašavati", "normalized": "oglasavati", "pos": "verb", "ua": "рекламувати, давати оголошення", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Tvrtka se oglašava na radiju."]}, {"lemma": "reklama", "normalized": "reklama", "pos": "noun", "ua": "реклама", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ova reklama je posvuda."]}, {"lemma": "letak", "normalized": "letak", "pos": "noun", "ua": "листівка (рекламна)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["U poštanskom sandučiću je letak trgovine."]}, {"lemma": "plakat", "normalized": "plakat", "pos": "noun", "ua": "плакат", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Na plakatu piše da je koncert otkazan."]}, {"lemma": "prodaje se", "normalized": "prodaje se", "pos": "phrase", "ua": "продається", "vtype": "chunk", "forms": {}, "examples": ["Prodaju se dječja kolica, kao nova."]}, {"lemma": "kao nov", "normalized": "kao nov", "pos": "phrase", "ua": "як новий", "vtype": "chunk", "forms": {}, "examples": ["Bicikl je kao nov."]}, {"lemma": "malo korišten", "normalized": "malo koristen", "pos": "phrase", "ua": "мало вживаний", "vtype": "chunk", "forms": {}, "examples": ["Prodajem malo korištenu perilicu."]}, {"lemma": "po dogovoru", "normalized": "po dogovoru", "pos": "phrase", "ua": "за домовленістю", "vtype": "chunk", "forms": {}, "examples": ["Cijena po dogovoru."]}, {"lemma": "hitno prodajem", "normalized": "hitno prodajem", "pos": "phrase", "ua": "терміново продам", "vtype": "chunk", "forms": {}, "examples": ["Hitno prodajem auto zbog selidbe."]}, {"lemma": "poklanjam", "normalized": "poklanjam", "pos": "phrase", "ua": "віддаю безкоштовно", "vtype": "chunk", "forms": {}, "examples": ["Poklanjam mačiće u dobre ruke."]}, {"lemma": "u dobre ruke", "normalized": "u dobre ruke", "pos": "phrase", "ua": "у добрі руки", "vtype": "chunk", "forms": {}, "examples": ["Tražimo dom u dobre ruke."]}, {"lemma": "tražim", "normalized": "trazim", "pos": "phrase", "ua": "шукаю", "vtype": "chunk", "forms": {}, "examples": ["Tražim stan koji ima balkon."]}, {"lemma": "nudim", "normalized": "nudim", "pos": "phrase", "ua": "пропоную", "vtype": "chunk", "forms": {}, "examples": ["Nudim instrukcije iz matematike."]}, {"lemma": "kontakt", "normalized": "kontakt", "pos": "noun", "ua": "контакт", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Kontakt je na dnu oglasa."]}, {"lemma": "ozbiljni kupci", "normalized": "ozbiljni kupci", "pos": "phrase", "ua": "серйозні покупці", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Samo ozbiljni kupci, molim."]}, {"lemma": "primamljiv", "normalized": "primamljiv", "pos": "adjective", "ua": "привабливий, спокусливий", "vtype": "core", "forms": {}, "examples": ["Ponuda je primamljiva."]}, {"lemma": "akcijska cijena", "normalized": "akcijska cijena", "pos": "phrase", "ua": "акційна ціна", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Akcijska cijena vrijedi do nedjelje."]}, {"lemma": "do isteka zaliha", "normalized": "do isteka zaliha", "pos": "phrase", "ua": "поки є в наявності", "vtype": "chunk", "forms": {}, "examples": ["Popust vrijedi do isteka zaliha."]}, {"lemma": "besplatna dostava", "normalized": "besplatna dostava", "pos": "phrase", "ua": "безкоштовна доставка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za narudžbe iznad pedeset eura dostava je besplatna."]}, {"lemma": "slogan", "normalized": "slogan", "pos": "noun", "ua": "слоган", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Slogan te reklame svi znaju."]}, {"lemma": "roman", "normalized": "roman", "pos": "noun", "ua": "роман", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Čitam roman o životu na otoku."]}, {"lemma": "pisac", "normalized": "pisac", "pos": "noun", "ua": "письменник", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Taj pisac je dobio veliku nagradu."]}, {"lemma": "spisateljica", "normalized": "spisateljica", "pos": "noun", "ua": "письменниця", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Moja omiljena spisateljica je iz Rijeke."]}, {"lemma": "poglavlje", "normalized": "poglavlje", "pos": "noun", "ua": "розділ", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Pročitala sam samo prvo poglavlje."]}, {"lemma": "glavni lik", "normalized": "glavni lik", "pos": "phrase", "ua": "головний герой", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Glavni lik je mlada liječnica."]}, {"lemma": "radnja", "normalized": "radnja", "pos": "noun", "ua": "сюжет, дія", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Radnja se događa u Zagrebu."]}, {"lemma": "žanr", "normalized": "zanr", "pos": "noun", "ua": "жанр", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Koji žanr najviše voliš?"]}, {"lemma": "kriminalistički roman", "normalized": "kriminalisticki roman", "pos": "phrase", "ua": "детектив", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ljeti čitam kriminalističke romane."]}, {"lemma": "biografija", "normalized": "biografija", "pos": "noun", "ua": "біографія", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Čitam biografiju Nikole Tesle."]}, {"lemma": "zvučna knjiga", "normalized": "zvucna knjiga", "pos": "phrase", "ua": "аудіокнига", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U autu slušam zvučne knjige."]}, {"lemma": "e-knjiga", "normalized": "e-knjiga", "pos": "noun", "ua": "електронна книга", "vtype": "core", "forms": {"gender": "f"}, "examples": ["E-knjige su lakše za putovanje."]}, {"lemma": "članska iskaznica", "normalized": "clanska iskaznica", "pos": "phrase", "ua": "читацький квиток", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za knjižnicu trebaš člansku iskaznicu."]}, {"lemma": "posudba", "normalized": "posudba", "pos": "noun", "ua": "позика (книжок)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Posudba traje tri tjedna."]}, {"lemma": "produžiti posudbu", "normalized": "produziti posudbu", "pos": "phrase", "ua": "продовжити термін позики", "vtype": "chunk", "forms": {}, "examples": ["Posudbu možeš produžiti online."]}, {"lemma": "zakasnina", "normalized": "zakasnina", "pos": "noun", "ua": "пеня за прострочення", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Platila sam zakasninu za dvije knjige."]}, {"lemma": "čitatelj", "normalized": "citatelj", "pos": "noun", "ua": "читач", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ova knjiga ima puno čitatelja."]}, {"lemma": "uzbudljiv", "normalized": "uzbudljiv", "pos": "adjective", "ua": "захопливий", "vtype": "core", "forms": {}, "examples": ["Knjiga je uzbudljiva do zadnje stranice."]}, {"lemma": "zanimljiviji od", "normalized": "zanimljiviji od", "pos": "phrase", "ua": "цікавіший за", "vtype": "chunk", "forms": {}, "examples": ["Roman je zanimljiviji od filma."]}, {"lemma": "sve više", "normalized": "sve vise", "pos": "phrase", "ua": "дедалі більше", "vtype": "chunk", "forms": {}, "examples": ["Sve više čitam na hrvatskom."]}, {"lemma": "ispustiti iz ruku", "normalized": "ispustiti iz ruku", "pos": "phrase", "ua": "випустити з рук; відірватися (від книжки)", "vtype": "chunk", "forms": {}, "examples": ["Ova knjiga je odlična, ne mogu je ispustiti iz ruku."]}, {"lemma": "lektira za odrasle", "normalized": "lektira za odrasle", "pos": "phrase", "ua": "читання для дорослих", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Klub čitatelja bira lektiru za odrasle."]}, {"lemma": "serija", "normalized": "serija", "pos": "noun", "ua": "серіал", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Gledam seriju koja ima pet sezona."]}, {"lemma": "glumica", "normalized": "glumica", "pos": "noun", "ua": "акторка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Glavna glumica je odlična."]}, {"lemma": "redatelj", "normalized": "redatelj", "pos": "noun", "ua": "режисер", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Redatelj je snimio film u Dubrovniku."]}, {"lemma": "uloga", "normalized": "uloga", "pos": "noun", "ua": "роль", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Dobio je nagradu za glavnu ulogu."]}, {"lemma": "snimati", "normalized": "snimati", "pos": "verb", "ua": "знімати (фільм)", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Ovdje su snimali poznatu seriju."]}, {"lemma": "titlovi", "normalized": "titlovi", "pos": "noun", "ua": "субтитри", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Gledam filmove s hrvatskim titlovima."]}, {"lemma": "sinkroniziran", "normalized": "sinkroniziran", "pos": "adjective", "ua": "дубльований", "vtype": "core", "forms": {}, "examples": ["Crtići su sinkronizirani na hrvatski."]}, {"lemma": "trailer", "normalized": "trailer", "pos": "noun", "ua": "трейлер", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Trailer je bolji od filma."]}, {"lemma": "iznenađujući kraj", "normalized": "iznenadujuci kraj", "pos": "phrase", "ua": "несподіваний фінал", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Film ima iznenađujući kraj."]}, {"lemma": "dirljiv", "normalized": "dirljiv", "pos": "adjective", "ua": "зворушливий", "vtype": "core", "forms": {}, "examples": ["Kraj je bio dirljiv, plakala sam."]}, {"lemma": "napetost", "normalized": "napetost", "pos": "noun", "ua": "напруга, інтрига", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Napetost raste do kraja."]}, {"lemma": "glumiti", "normalized": "glumiti", "pos": "verb", "ua": "грати (роль)", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Ona glumi doktoricu."]}, {"lemma": "radi se o", "normalized": "radi se o", "pos": "phrase", "ua": "йдеться про", "vtype": "chunk", "forms": {}, "examples": ["Radi se o obitelji koja seli na otok."]}, {"lemma": "na početku", "normalized": "na pocetku", "pos": "phrase", "ua": "на початку", "vtype": "chunk", "forms": {}, "examples": ["Na početku je sve mirno."]}, {"lemma": "u međuvremenu", "normalized": "u meduvremenu", "pos": "phrase", "ua": "тим часом", "vtype": "chunk", "forms": {}, "examples": ["U međuvremenu njezin brat nestaje."]}, {"lemma": "ispostavi se", "normalized": "ispostavi se", "pos": "phrase", "ua": "виявляється", "vtype": "chunk", "forms": {}, "examples": ["Na kraju se ispostavi da je on kriv."]}, {"lemma": "nemoj mi otkriti kraj", "normalized": "nemoj mi otkriti kraj", "pos": "phrase", "ua": "не розповідай мені кінця", "vtype": "chunk", "forms": {}, "examples": ["Nemoj mi otkriti kraj, još gledam!"]}, {"lemma": "strujanje", "normalized": "strujanje", "pos": "noun", "ua": "стримінг", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Serije gledam na platformi za strujanje."]}, {"lemma": "kino projekcija", "normalized": "kino projekcija", "pos": "phrase", "ua": "кіносеанс", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Kino projekcija počinje u dvadeset i trideset."]}, {"lemma": "kino ulaznica", "normalized": "kino ulaznica", "pos": "phrase", "ua": "квиток у кіно", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Kino ulaznica je šest eura."]}, {"lemma": "premijera", "normalized": "premijera", "pos": "noun", "ua": "прем’єра", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Premijera je u petak."]}, {"lemma": "vrijedi pogledati", "normalized": "vrijedi pogledati", "pos": "phrase", "ua": "варто подивитися", "vtype": "chunk", "forms": {}, "examples": ["Taj film vrijedi pogledati."]}, {"lemma": "vrijedi posjetiti", "normalized": "vrijedi posjetiti", "pos": "phrase", "ua": "варто відвідати", "vtype": "chunk", "forms": {}, "examples": ["Muzej vrijedi posjetiti."]}, {"lemma": "ne propusti", "normalized": "ne propusti", "pos": "phrase", "ua": "не пропусти", "vtype": "chunk", "forms": {}, "examples": ["Ne propusti koncert u subotu!"]}, {"lemma": "toplo preporučujem", "normalized": "toplo preporucujem", "pos": "phrase", "ua": "щиро раджу", "vtype": "chunk", "forms": {}, "examples": ["Toplo preporučujem ovaj restoran."]}, {"lemma": "nije mi se svidjelo", "normalized": "nije mi se svidjelo", "pos": "phrase", "ua": "мені не сподобалося", "vtype": "chunk", "forms": {}, "examples": ["Iskreno, nije mi se svidjelo."]}, {"lemma": "razočaranje", "normalized": "razocaranje", "pos": "noun", "ua": "розчарування", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Nastavak je bio veliko razočaranje."]}, {"lemma": "precijenjen", "normalized": "precijenjen", "pos": "adjective", "ua": "переоцінений", "vtype": "core", "forms": {}, "examples": ["Taj restoran je precijenjen."]}, {"lemma": "podcijenjen", "normalized": "podcijenjen", "pos": "adjective", "ua": "недооцінений", "vtype": "core", "forms": {}, "examples": ["Ovo je podcijenjen film."]}, {"lemma": "nezaobilazan", "normalized": "nezaobilazan", "pos": "adjective", "ua": "обов’язковий для відвідування, неминучий", "vtype": "core", "forms": {}, "examples": ["Ovaj muzej je nezaobilazan."]}, {"lemma": "isplati se otići", "normalized": "isplati se otici", "pos": "phrase", "ua": "варто сходити", "vtype": "chunk", "forms": {}, "examples": ["Isplati se otići rano ujutro."]}, {"lemma": "bolji nego što sam očekivao", "normalized": "bolji nego sto sam ocekivao", "pos": "phrase", "ua": "кращий, ніж я очікував", "vtype": "chunk", "forms": {}, "examples": ["Film je bolji nego što sam očekivao."]}, {"lemma": "što prije", "normalized": "sto prije", "pos": "phrase", "ua": "якнайшвидше", "vtype": "chunk", "forms": {}, "examples": ["Rezervirajte što prije, mjesta brzo nestanu."]}, {"lemma": "ukus", "normalized": "ukus", "pos": "noun", "ua": "смак (вподобання)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["O ukusima se ne raspravlja."]}, {"lemma": "dojam", "normalized": "dojam", "pos": "noun", "ua": "враження", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Prvi dojam je bio odličan."]}, {"lemma": "atmosfera", "normalized": "atmosfera", "pos": "noun", "ua": "атмосфера", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Atmosfera u kafiću je opuštena."]}, {"lemma": "omjer cijene i kvalitete", "normalized": "omjer cijene i kvalitete", "pos": "phrase", "ua": "співвідношення ціни й якості", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Omjer cijene i kvalitete je odličan."]}, {"lemma": "skriveni dragulj", "normalized": "skriveni dragulj", "pos": "phrase", "ua": "прихована перлина", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ova konoba je skriveni dragulj."]}, {"lemma": "vrhunski", "normalized": "vrhunski", "pos": "adjective", "ua": "чудовий, найвищого рівня", "vtype": "core", "forms": {}, "examples": ["Hrana je vrhunska."]}, {"lemma": "prosječan", "normalized": "prosjecan", "pos": "adjective", "ua": "посередній", "vtype": "core", "forms": {}, "examples": ["Film je prosječan, ništa posebno."]}, {"lemma": "ništa posebno", "normalized": "nista posebno", "pos": "phrase", "ua": "нічого особливого", "vtype": "chunk", "forms": {}, "examples": ["Hotel je u redu, ali ništa posebno."]}, {"lemma": "čini mi se da", "normalized": "cini mi se da", "pos": "phrase", "ua": "мені здається, що", "vtype": "chunk", "forms": {}, "examples": ["Čini mi se da je to dobra odluka."]}, {"lemma": "uvjeren sam da", "normalized": "uvjeren sam da", "pos": "phrase", "ua": "я переконаний, що", "vtype": "chunk", "forms": {}, "examples": ["Uvjeren sam da će uspjeti."]}, {"lemma": "sumnjam da", "normalized": "sumnjam da", "pos": "phrase", "ua": "сумніваюся, що", "vtype": "chunk", "forms": {}, "examples": ["Sumnjam da će cijene pasti."]}, {"lemma": "ovisi o", "normalized": "ovisi o", "pos": "phrase", "ua": "залежить від", "vtype": "chunk", "forms": {}, "examples": ["Ovisi o situaciji."]}, {"lemma": "iako", "normalized": "iako", "pos": "conjunction", "ua": "хоча", "vtype": "function_word", "forms": {}, "examples": ["Iako je skupo, vrijedi."]}, {"lemma": "zato što", "normalized": "zato sto", "pos": "conjunction", "ua": "тому що", "vtype": "function_word", "forms": {}, "examples": ["Ne idem, zato što sam umorna."]}, {"lemma": "osim toga", "normalized": "osim toga", "pos": "phrase", "ua": "крім того", "vtype": "chunk", "forms": {}, "examples": ["Osim toga, nemamo vremena."]}, {"lemma": "naime", "normalized": "naime", "pos": "adverb", "ua": "а саме, річ у тім, що", "vtype": "core", "forms": {}, "examples": ["Kasnim. Naime, autobus nije došao."]}, {"lemma": "dakle", "normalized": "dakle", "pos": "conjunction", "ua": "отже", "vtype": "function_word", "forms": {}, "examples": ["Dakle, slažemo se."]}, {"lemma": "unatoč tome", "normalized": "unatoc tome", "pos": "phrase", "ua": "попри це", "vtype": "chunk", "forms": {}, "examples": ["Unatoč tome, ostali smo."]}, {"lemma": "glavni razlog", "normalized": "glavni razlog", "pos": "phrase", "ua": "головна причина", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Glavni razlog je cijena."]}, {"lemma": "moglo bi se reći", "normalized": "moglo bi se reci", "pos": "phrase", "ua": "можна було б сказати", "vtype": "chunk", "forms": {}, "examples": ["Moglo bi se reći da je grad prenapučen."]}, {"lemma": "nema smisla", "normalized": "nema smisla", "pos": "phrase", "ua": "немає сенсу", "vtype": "chunk", "forms": {}, "examples": ["Nema smisla svađati se."]}, {"lemma": "ima smisla", "normalized": "ima smisla", "pos": "phrase", "ua": "має сенс", "vtype": "chunk", "forms": {}, "examples": ["Tvoj prijedlog ima smisla."]}, {"lemma": "tema", "normalized": "tema", "pos": "noun", "ua": "тема", "vtype": "core", "forms": {"gender": "f"}, "examples": ["To je osjetljiva tema."]}, {"lemma": "gledište", "normalized": "glediste", "pos": "noun", "ua": "точка зору", "vtype": "core", "forms": {"gender": "n"}, "examples": ["S mog gledišta, to je pogrešno."]}, {"lemma": "javno mnijenje", "normalized": "javno mnijenje", "pos": "phrase", "ua": "громадська думка", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Javno mnijenje je podijeljeno."]}, {"lemma": "podijeljen", "normalized": "podijeljen", "pos": "adjective", "ua": "поділений, розділений", "vtype": "core", "forms": {}, "examples": ["Mišljenja su podijeljena."]}, {"lemma": "zaključiti", "normalized": "zakljuciti", "pos": "verb", "ua": "дійти висновку", "vtype": "core", "forms": {"aspect": "pfv", "pair": "zaključivati"}, "examples": ["Zaključili smo da je bolje čekati."]}, {"lemma": "primjerice", "normalized": "primjerice", "pos": "adverb", "ua": "наприклад", "vtype": "core", "forms": {}, "examples": ["Primjerice, u Zagrebu je najam skuplji."]}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 2. Уроки модуля A2.10
-- A2.10 · урок 60: Новини, радіо й подкасти — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'e9d667aa-87ee-5ea7-a0b5-a94f070e6f1d';
  v_lesson constant uuid := '92bd4e0c-f9df-5edb-a65e-9549fe1ef1b8';
  v_gid constant uuid := '59c6c708-59b5-5781-bf5d-4ecd5aa8b7dc';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики ZAV'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A2.10: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 60: Новини, радіо й подкасти', 'Lekcija 60: Vijesti, radio i podcasti', '["Переказати новину: Pročitala sam da…, Kažu da…", "Обговорити, звідки ви дізнаєтеся новини"]'::jsonb, 20, 'PUBLISHED', 1);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'vijesti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'članak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'portal', v_pos);
  v_pos := pg_temp.word(v_lesson, 'novinar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naslov', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naslovnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lažne vijesti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'provjeriti izvor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radijska postaja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'emisija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slušatelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podcast', v_pos);
  v_pos := pg_temp.word(v_lesson, 'epizoda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pretplatiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Dnevnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pročitala sam da', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kažu da', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prema najavi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'aktualno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lokalne vijesti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a827e63a-6257-50a7-8a0d-c41784eb0010', 'fill_in_the_blank', 'Pročitala sam ___ se gradi novi most.', 'da', '["kad", "da", "ako", "što"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0014fa6c-75e8-51c6-972c-4931afc6c87a', 'multiple_choice', 'Що означає «Dnevnik»?', 'вечірні новини (на HRT)', '["новинний сайт, портал", "вечірні новини (на HRT)", "слухач", "перша шпальта, головна сторінка"]'::jsonb, 'A2', 2, 'PUBLISHED', 'Dnevnik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '08a2ef41-ffd9-59b5-b67e-eb8ba97e421b', 'multiple_choice', 'Що означає «lažne vijesti»?', 'фейкові новини', '["перевірити джерело", "фейкові новини", "передача", "слухач"]'::jsonb, 'A2', 3, 'PUBLISHED', 'lažne vijesti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4becf72b-1e4c-5c61-b24f-b22fc76ffcb0', 'multiple_choice', 'Що означає «provjeriti izvor»?', 'перевірити джерело', '["заголовок", "перевірити джерело", "перша шпальта, головна сторінка", "місцеві новини"]'::jsonb, 'A2', 4, 'PUBLISHED', 'provjeriti izvor', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f05a043-91e3-5b7c-9a86-2ef6bb4b595d', 'multiple_choice', 'Як хорватською «актуально, на часі»?', 'aktualno', '["Dnevnik", "najava", "aktualno", "pretplatiti se"]'::jsonb, 'A2', 5, 'PUBLISHED', 'aktualno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3c297806-4211-582c-bb2b-d8c7b8476c94', 'multiple_choice', 'Як хорватською «новинний сайт, портал»?', 'portal', '["portal", "epizoda", "kažu da", "emisija"]'::jsonb, 'A2', 6, 'PUBLISHED', 'portal', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1a818f39-f61a-56b6-9ec7-f8ac46bed613', 'type_answer', 'Напишіть хорватською: «заголовок»', 'naslov', null, 'A2', 7, 'PUBLISHED', 'naslov', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2d8399df-e07b-57ad-bb41-a5fb31c0cfea', 'type_answer', 'Напишіть хорватською: «журналіст»', 'novinar', null, 'A2', 8, 'PUBLISHED', 'novinar', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f6f98d83-145a-50ae-baa0-0bb3c35eaa4d', 'type_answer', 'Напишіть хорватською: «за анонсом, як повідомляють»', 'prema najavi', null, 'A2', 9, 'PUBLISHED', 'prema najavi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '87114313-8342-5f92-8158-774a1f096e63', 'sentence_builder', 'Складіть: «Завжди перевіряй джерело.»', 'Uvijek provjeri izvor.', '["izvor.", "provjeri", "Uvijek"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '238e7622-98c7-5078-aaf9-a1929eb367b0', 'sentence_builder', 'Складіть: «Новий епізод виходить щоп’ятниці.»', 'Nova epizoda izlazi svakog petka.', '["petka.", "izlazi", "Nova", "epizoda", "svakog"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '97c333b4-90d2-5939-abc3-bfd63251d438', 'listening', 'Прослухайте і складіть фразу', 'Pošalji mi link, pretplatit ću se.', '["link,", "mi", "ću", "se.", "pretplatit", "Pošalji"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '44a366f0-a923-576b-8a8e-e602edbd622e', 'listening_dialogue', 'Прослухайте новину', '6; три тижні; у суботу о 20:00', 'A2', 'PUBLISHED', '{"kind": "news", "situation_ua": "Ви слухаєте місцеві новини по радіо.", "script": [{"hr": "Dobro jutro, ovo su lokalne vijesti.", "ua": "Доброго ранку, це місцеві новини."}, {"hr": "Od ponedjeljka tramvaj broj šest ne vozi kroz centar zbog radova.", "ua": "З понеділка трамвай номер шість не ходить через центр через ремонтні роботи."}, {"hr": "Radovi će trajati tri tjedna.", "ua": "Роботи триватимуть три тижні."}, {"hr": "U subotu je na glavnom trgu besplatan koncert u dvadeset sati.", "ua": "У суботу на головній площі безкоштовний концерт о двадцятій."}], "questions": [{"q_ua": "Який трамвай не ходить через центр?", "answer_text": "6", "accept": ["шостий", "номер 6", "шість"], "answer_turn": 1}, {"q_ua": "Скільки триватимуть роботи?", "options": ["три тижні", "три дні", "три місяці"], "correct": 0, "answer_turn": 2}, {"q_ua": "Коли безкоштовний концерт?", "options": ["у неділю о 19:00", "у суботу о 20:00", "у п’ятницю о 21:00"], "correct": 1, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '44a366f0-a923-576b-8a8e-e602edbd622e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9cdb9abe-5bf3-570d-a43d-c869157d5d2c', 'speaking', 'Я прочитала, що будують новий міст.', 'Pročitala sam da se gradi novi most.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6ce38a83-13fd-5473-bda2-41413586eb09', 'speaking', 'Кажуть, що ціни знову зростуть.', 'Kažu da će cijene opet rasti.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '4eb9ea40-0a44-5658-b70f-6251d78bbb15', 'write_message', 'Напишіть подрузі: ви прочитали на порталі, що в суботу на площі безкоштовний концерт; запропонуйте піти.', 'Pročitala sam na portalu da je u subotu besplatan koncert na trgu. Idemo?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі: ви прочитали на порталі, що в суботу на площі безкоштовний концерт; запропонуйте піти.", "points": [{"ua": "прочитали, що", "keys": [["pročita"], ["da"]]}, {"ua": "безкоштовний концерт", "keys": [["koncert"]]}, {"ua": "у суботу", "keys": [["subot"]]}, {"ua": "запропонуйте піти", "keys": [["idemo"], ["ideš"]]}], "hints": ["pročitala sam na portalu da", "besplatan koncert", "u subotu na trgu", "idemo?"], "models": ["Pročitala sam na portalu da je u subotu besplatan koncert na trgu. Idemo?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '4eb9ea40-0a44-5658-b70f-6251d78bbb15', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'b15667f5-d0a0-58b6-8452-6d6164f917f6', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Prema vijestima, tramvaj neće voziti tri tjedna.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи Іванові, що, як повідомляють новини, трамвай не ходитиме три тижні.", "direction": "ua_hr", "points": [{"ua": "трамвай не ходитиме", "keys": [["tramvaj"]]}, {"ua": "три тижні", "keys": [["tri tjedna"]]}], "hints": [], "models": ["Prema vijestima, tramvaj neće voziti tri tjedna."], "source_ua": "Скажи Іванові, що, як повідомляють новини, трамвай не ходитиме три тижні."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'b15667f5-d0a0-58b6-8452-6d6164f917f6', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('db8f6605-1bab-5f3a-a4fe-2fcaea004bde', v_lesson, 'Що в новинах?', 'Što ima u vijestima?', 5601, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('b8a22a93-b0b4-5b39-b9ef-81e0783798af', 'db8f6605-1bab-5f3a-a4fe-2fcaea004bde', 'Daša', 'Jesi li čula vijesti? Pročitala sam da se gradi novi most na Savi.', 'Ти чула новини? Я прочитала, що будують новий міст через Саву.', 1);
  perform pg_temp.turn('ef3b15b4-753f-5232-a474-880cedad48eb', 'db8f6605-1bab-5f3a-a4fe-2fcaea004bde', 'Darja', 'Nisam. Gdje si to pročitala?', 'Ні. Де ти це прочитала?', 2);
  perform pg_temp.turn('ab458d80-4700-556f-b1d6-17b23b83edcd', 'db8f6605-1bab-5f3a-a4fe-2fcaea004bde', 'Daša', 'Na jednom portalu. Bilo je na naslovnici.', 'На одному порталі. Було на головній.', 3);
  perform pg_temp.turn('c0a8b23e-5cbf-56bd-8683-bad65d5001ea', 'db8f6605-1bab-5f3a-a4fe-2fcaea004bde', 'Darja', 'Provjeri izvor. Danas ima puno lažnih vijesti.', 'Перевір джерело. Сьогодні багато фейкових новин.', 4);
  perform pg_temp.turn('761d81ef-b6ba-554e-a9c5-47e7f97588c8', 'db8f6605-1bab-5f3a-a4fe-2fcaea004bde', 'Daša', 'U pravu si. Pogledat ću večeras Dnevnik.', 'Твоя правда. Подивлюся сьогодні ввечері новини.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b20264d2-384c-52c9-a0fd-e30b9b99cb4c', v_lesson, 'Улюблений подкаст', 'Omiljeni podcast', 5602, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('a2772dd3-c7fb-5dd0-88a6-90d602a08c49', 'b20264d2-384c-52c9-a0fd-e30b9b99cb4c', 'Ivan', 'Što slušaš u autu?', 'Що ти слухаєш в авто?', 1);
  perform pg_temp.turn('31c067ae-10af-54a6-9477-3391f0d7d953', 'b20264d2-384c-52c9-a0fd-e30b9b99cb4c', 'Marko', 'Podcast o hrvatskoj povijesti. Nova epizoda izlazi petkom.', 'Подкаст про історію Хорватії. Новий епізод виходить по п’ятницях.', 2);
  perform pg_temp.turn('1c2e11ad-db65-5768-9f41-14bd30b0b2da', 'b20264d2-384c-52c9-a0fd-e30b9b99cb4c', 'Ivan', 'Zvuči zanimljivo. A radio?', 'Звучить цікаво. А радіо?', 3);
  perform pg_temp.turn('c4668264-f2ac-5c86-8250-5a7644f889c6', 'b20264d2-384c-52c9-a0fd-e30b9b99cb4c', 'Marko', 'Ujutro slušam jutarnju emisiju. Kažu da je najslušanija u gradu.', 'Уранці слухаю ранкову передачу. Кажуть, що вона найпопулярніша в місті.', 4);
  perform pg_temp.turn('4f725010-20dc-5a81-acb3-719802594f69', 'b20264d2-384c-52c9-a0fd-e30b9b99cb4c', 'Ivan', 'Pošalji mi link, pretplatit ću se.', 'Надішли мені посилання, я підпишуся.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.10 · урок 61: Оголошення й реклама — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'e9d667aa-87ee-5ea7-a0b5-a94f070e6f1d';
  v_lesson constant uuid := '3fc81316-dca8-5661-88c1-eaf2b61aec07';
  v_gid constant uuid := '12a1a49d-9117-5e9d-a64e-66be7a371810';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KOJI'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A2.10: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 61: Оголошення й реклама', 'Lekcija 61: Oglasi i reklame', '["Зрозуміти й написати коротке оголошення", "Описати річ чи людину реченням з koji: Tražim stan koji…"]'::jsonb, 20, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'mali oglasi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oglašavati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'reklama', v_pos);
  v_pos := pg_temp.word(v_lesson, 'letak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plakat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prodaje se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kao nov', v_pos);
  v_pos := pg_temp.word(v_lesson, 'malo korišten', v_pos);
  v_pos := pg_temp.word(v_lesson, 'po dogovoru', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hitno prodajem', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poklanjam', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u dobre ruke', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tražim', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nudim', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kontakt', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ozbiljni kupci', v_pos);
  v_pos := pg_temp.word(v_lesson, 'primamljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'akcijska cijena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'do isteka zaliha', v_pos);
  v_pos := pg_temp.word(v_lesson, 'besplatna dostava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slogan', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '606f396d-ea72-5b5a-b840-fe9232d0d363', 'fill_in_the_blank', 'Tražim stan ___ ima balkon.', 'koji', '["koja", "kojeg", "koji", "koje"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f2041c8c-d859-5a3f-9e4c-71647b5372de', 'multiple_choice', 'Що означає «kao nov»?', 'як новий', '["контакт", "як новий", "віддаю безкоштовно", "слоган"]'::jsonb, 'A2', 2, 'PUBLISHED', 'kao nov', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4676c7c0-ed3a-5776-b787-ade2f62b3e16', 'multiple_choice', 'Що означає «u dobre ruke»?', 'у добрі руки', '["у добрі руки", "віддаю безкоштовно", "привабливий, спокусливий", "серйозні покупці"]'::jsonb, 'A2', 3, 'PUBLISHED', 'u dobre ruke', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0c040424-c634-5eae-adc9-f26f9a022320', 'multiple_choice', 'Що означає «akcijska cijena»?', 'акційна ціна', '["контакт", "мало вживаний", "акційна ціна", "листівка (рекламна)"]'::jsonb, 'A2', 4, 'PUBLISHED', 'akcijska cijena', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5191ecf4-6d81-5ed3-86a6-b1d0c2269bf3', 'multiple_choice', 'Як хорватською «привабливий, спокусливий»?', 'primamljiv', '["malo korišten", "primamljiv", "po dogovoru", "besplatna dostava"]'::jsonb, 'A2', 5, 'PUBLISHED', 'primamljiv', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b0b0b21e-d83a-5c0e-910f-3499d59f3873', 'multiple_choice', 'Як хорватською «терміново продам»?', 'hitno prodajem', '["hitno prodajem", "letak", "slogan", "primamljiv"]'::jsonb, 'A2', 6, 'PUBLISHED', 'hitno prodajem', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8ac41976-bd8d-573d-a885-f1a1a7003bd9', 'type_answer', 'Напишіть хорватською: «шукаю»', 'tražim', null, 'A2', 7, 'PUBLISHED', 'tražim', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ac83afbe-27e2-5691-9137-c91e69b94b33', 'type_answer', 'Напишіть хорватською: «серйозні покупці»', 'ozbiljni kupci', null, 'A2', 8, 'PUBLISHED', 'ozbiljni kupci', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7fa26d7d-91cb-5fee-ab10-159a276316b8', 'type_answer', 'Напишіть хорватською: «контакт»', 'kontakt', null, 'A2', 9, 'PUBLISHED', 'kontakt', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '02da06b3-42a3-5418-802f-0216f1647509', 'sentence_builder', 'Складіть: «Ціна за домовленістю.»', 'Cijena po dogovoru.', '["dogovoru.", "Cijena", "po"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ee7c1568-f604-531b-a9c1-5c5aca49f5cf', 'sentence_builder', 'Складіть: «Терміново продам авто.»', 'Hitno prodajem auto.', '["prodajem", "auto.", "Hitno"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '348664e8-2bd3-508e-af50-549cfe6e9d3f', 'listening', 'Прослухайте і складіть фразу', 'Do isteka zaliha. I dostava je besplatna.', '["zaliha.", "isteka", "Do", "je", "dostava", "besplatna.", "I"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'b7cee1e7-6fdc-5218-a472-44ee94be8128', 'listening_dialogue', 'Прослухайте оголошення', 'кава; 30; безкоштовну сумку', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Реклама в супермаркеті через гучномовець.", "script": [{"hr": "Poštovani kupci, samo danas kava je trideset posto jeftinija.", "ua": "Шановні покупці, лише сьогодні кава на тридцять відсотків дешевша."}, {"hr": "Akcija vrijedi do isteka zaliha.", "ua": "Акція діє, поки є в наявності."}, {"hr": "Za kupnju iznad pedeset eura dobivate besplatnu vrećicu.", "ua": "За покупку понад п’ятдесят євро ви отримуєте безкоштовну сумку."}], "questions": [{"q_ua": "Що сьогодні дешевше?", "options": ["кава", "хліб", "вино"], "correct": 0, "answer_turn": 0}, {"q_ua": "На скільки відсотків дешевше?", "answer_text": "30", "accept": ["тридцять", "30%", "30 %"], "answer_turn": 0}, {"q_ua": "Що отримуєш за покупку понад 50 євро?", "options": ["каву", "безкоштовну сумку", "знижку 10 %"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'b7cee1e7-6fdc-5218-a472-44ee94be8128', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f6075552-34c0-506d-83cf-a7389ebed4d6', 'speaking', 'Продається велосипед, як новий.', 'Prodaje se bicikl, kao nov.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '35717dc6-3ae0-5cae-b651-3578192b7b31', 'speaking', 'Шукаю квартиру, яка має балкон.', 'Tražim stan koji ima balkon.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'e73eb4d8-c103-5e2b-ba79-2cc523fcf91c', 'write_message', 'Напишіть оголошення: продаєте мало вживаний велосипед для дитини, ціна за домовленістю, контакт — ваш номер.', 'Prodaje se dječji bicikl, malo korišten. Cijena po dogovoru. Kontakt: 091 234 5678.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть оголошення: продаєте мало вживаний велосипед для дитини, ціна за домовленістю, контакт — ваш номер.", "points": [{"ua": "продаєте велосипед", "keys": [["prodaj", "bicikl"]]}, {"ua": "мало вживаний", "keys": [["malo korišten"], ["kao nov"]]}, {"ua": "ціна за домовленістю", "keys": [["dogovor"]]}, {"ua": "контакт", "keys": [["kontakt"], ["broj"], ["nazovite"]]}], "hints": ["prodaje se dječji bicikl", "malo korišten", "cijena po dogovoru", "kontakt"], "models": ["Prodaje se dječji bicikl, malo korišten. Cijena po dogovoru. Kontakt: 091 234 5678."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'e73eb4d8-c103-5e2b-ba79-2cc523fcf91c', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'c8c5ae31-37a3-5f43-8d9c-1557b2a9ec06', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Poklanjam mače u dobre ruke.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Напиши в оголошенні від мене: віддаю кошеня в добрі руки, безкоштовно.", "direction": "ua_hr", "points": [{"ua": "віддаю", "keys": [["poklanj"]]}, {"ua": "кошеня", "keys": [["mač"]]}, {"ua": "в добрі руки", "keys": [["dobre ruke"]]}], "hints": [], "models": ["Poklanjam mače u dobre ruke."], "source_ua": "Напиши в оголошенні від мене: віддаю кошеня в добрі руки, безкоштовно."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'c8c5ae31-37a3-5f43-8d9c-1557b2a9ec06', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e9cd1078-9c46-51a9-baff-67d16fdd53bd', v_lesson, 'Продаю візок', 'Prodajem kolica', 5611, 'A2', 'shopping', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('f4a27292-d0ac-563d-a55f-5a5da9d7708a', 'e9cd1078-9c46-51a9-baff-67d16fdd53bd', 'Darja', 'Daša, pomozi mi napisati oglas. Prodajem kolica koja su malo korištena.', 'Дашо, допоможи мені написати оголошення. Продаю візок, який мало вживаний.', 1);
  perform pg_temp.turn('9a25aebc-d713-50aa-8e79-6e6e578e6725', 'e9cd1078-9c46-51a9-baff-67d16fdd53bd', 'Daša', 'Napiši: „Prodaju se dječja kolica, kao nova. Cijena po dogovoru.“', 'Напиши: «Продається дитячий візок, як новий. Ціна за домовленістю».', 2);
  perform pg_temp.turn('a7208e9f-2962-52b5-b7d9-7497519e732e', 'e9cd1078-9c46-51a9-baff-67d16fdd53bd', 'Darja', 'Trebam li napisati „samo ozbiljni kupci“?', 'Треба написати «лише серйозні покупці»?', 3);
  perform pg_temp.turn('c9358a2d-08cd-57a9-8157-ea5635131933', 'e9cd1078-9c46-51a9-baff-67d16fdd53bd', 'Daša', 'Može. I stavi kontakt na dno oglasa.', 'Можна. І постав контакт унизу оголошення.', 4);
  perform pg_temp.turn('36661dd6-1ad5-5029-8bfe-48c7a024c3b8', 'e9cd1078-9c46-51a9-baff-67d16fdd53bd', 'Darja', 'Super. Stavit ću ga na male oglase.', 'Супер. Розміщу його серед приватних оголошень.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('fb0e71a3-40ab-520f-8332-006b7095a15e', v_lesson, 'Акція', 'Akcija', 5612, 'A2', 'shopping', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('cae48877-6e68-5714-b19b-8fc50852372e', 'fb0e71a3-40ab-520f-8332-006b7095a15e', 'Ivan', 'Vidi letak! Akcijska cijena za perilicu koja je prošli tjedan bila skuplja.', 'Подивись на листівку! Акційна ціна на пральну машину, яка минулого тижня була дорожча.', 1);
  perform pg_temp.turn('a01dfc20-9f71-5d8c-b91f-ed4d998cb886', 'fb0e71a3-40ab-520f-8332-006b7095a15e', 'Marko', 'Primamljivo. Do kada vrijedi?', 'Спокусливо. До коли діє?', 2);
  perform pg_temp.turn('e782367d-85f3-52ab-80cb-a862e6461e5f', 'fb0e71a3-40ab-520f-8332-006b7095a15e', 'Ivan', 'Do isteka zaliha. I dostava je besplatna.', 'Поки є в наявності. І доставка безкоштовна.', 3);
  perform pg_temp.turn('c53cd4c2-d26e-529e-a86c-fc090443e6b7', 'fb0e71a3-40ab-520f-8332-006b7095a15e', 'Marko', 'Pazi, reklame uvijek obećavaju više nego što daju.', 'Обережно, реклама завжди обіцяє більше, ніж дає.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.10 · урок 62: Книги й читання — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'e9d667aa-87ee-5ea7-a0b5-a94f070e6f1d';
  v_lesson constant uuid := '2e7e2800-1867-5d3e-9cee-d712b2e8e9e0';
  v_gid constant uuid := '926638d7-1396-512e-8a05-065c4464b85a';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики POR'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A2.10: місце 3 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 62: Книги й читання', 'Lekcija 62: Knjige i čitanje', '["Розповісти про книжку, яку читаєте, і порівняти з іншою", "Порівняння: zanimljivija od, isti kao, sve više čitam"]'::jsonb, 20, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'roman', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pisac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spisateljica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poglavlje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glavni lik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žanr', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kriminalistički roman', v_pos);
  v_pos := pg_temp.word(v_lesson, 'biografija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvučna knjiga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'e-knjiga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'članska iskaznica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posudba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'produžiti posudbu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zakasnina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čitatelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uzbudljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zanimljiviji od', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sve više', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispustiti iz ruku', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lektira za odrasle', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '5a88548d-b3fa-5ad9-8f0e-e74c9963e900', 'fill_in_the_blank', 'Roman je bio zanimljiviji ___ filma.', 'od', '["kao", "za", "od", "nego"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f60a2a22-4e7f-5659-b2bf-7cad722e353c', 'multiple_choice', 'Що означає «produžiti posudbu»?', 'продовжити термін позики', '["продовжити термін позики", "пеня за прострочення", "головний герой", "читач"]'::jsonb, 'A2', 2, 'PUBLISHED', 'produžiti posudbu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa51b1c5-0686-5b1e-bc78-1d5176185f3b', 'multiple_choice', 'Що означає «članska iskaznica»?', 'читацький квиток', '["роман", "біографія", "читацький квиток", "головний герой"]'::jsonb, 'A2', 3, 'PUBLISHED', 'članska iskaznica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aae740aa-6542-5839-9bd8-89a18f9a33b3', 'multiple_choice', 'Що означає «zakasnina»?', 'пеня за прострочення', '["пеня за прострочення", "захопливий", "аудіокнига", "дедалі більше"]'::jsonb, 'A2', 4, 'PUBLISHED', 'zakasnina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf16d992-b7f1-51bb-89ad-9ec2ef2a9d36', 'multiple_choice', 'Як хорватською «сюжет, дія»?', 'radnja', '["članska iskaznica", "lektira za odrasle", "radnja", "zakasnina"]'::jsonb, 'A2', 5, 'PUBLISHED', 'radnja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9b59f3bb-3ef4-5a24-89c6-20ca70bca267', 'multiple_choice', 'Як хорватською «захопливий»?', 'uzbudljiv', '["glavni lik", "ispustiti iz ruku", "uzbudljiv", "biografija"]'::jsonb, 'A2', 6, 'PUBLISHED', 'uzbudljiv', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f4c1815f-f205-55df-ab7d-d13d339ced3e', 'type_answer', 'Напишіть хорватською: «позика (книжок)»', 'posudba', null, 'A2', 7, 'PUBLISHED', 'posudba', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4bdf69f6-b5f9-5cc8-a757-a519eee7b5c5', 'type_answer', 'Напишіть хорватською: «розділ»', 'poglavlje', null, 'A2', 8, 'PUBLISHED', 'poglavlje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd9f6db70-7f41-53e1-b3a4-5ab6aea71ffc', 'type_answer', 'Напишіть хорватською: «роман»', 'roman', null, 'A2', 9, 'PUBLISHED', 'roman', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3b352c3a-928d-56bb-929c-db576369649d', 'sentence_builder', 'Складіть: «Дія відбувається в Загребі.»', 'Radnja se događa u Zagrebu.', '["Zagrebu.", "Radnja", "u", "događa", "se"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bd23f964-a9b6-5e45-848c-19d4d4068380', 'sentence_builder', 'Складіть: «Я читаю дедалі більше хорватською.»', 'Sve više čitam na hrvatskom.', '["čitam", "na", "više", "Sve", "hrvatskom."]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '124ff75b-fd24-5fcc-bd05-191fa72a5ab7', 'listening', 'Прослухайте і складіть фразу', 'Imamo, i e-knjige. Posudba traje tri tjedna.', '["i", "traje", "Imamo,", "e-knjige.", "tri", "Posudba", "tjedna."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '51e5968a-e703-5e10-8f84-addfd3b5c1c4', 'listening_dialogue', 'Прослухайте оголошення', 'щопершого вівторка о 18:00; про роман молодої авторки; безкоштовно', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Оголошення в міській бібліотеці.", "script": [{"hr": "Klub čitatelja sastaje se svakog prvog utorka u mjesecu u osamnaest sati.", "ua": "Клуб читачів збирається щопершого вівторка місяця о вісімнадцятій."}, {"hr": "Ovaj mjesec razgovaramo o romanu jedne mlade hrvatske autorice.", "ua": "Цього місяця обговорюємо роман однієї молодої хорватської авторки."}, {"hr": "Novi članovi su dobrodošli, ulaz je besplatan.", "ua": "Нові учасники — ласкаво просимо, вхід безкоштовний."}], "questions": [{"q_ua": "Коли збирається клуб читачів?", "options": ["щопершого вівторка о 18:00", "щоп’ятниці о 18:00", "щосуботи вранці"], "correct": 0, "answer_turn": 0}, {"q_ua": "Про що говорять цього місяця?", "options": ["про поезію", "про біографію", "про роман молодої авторки"], "correct": 2, "answer_turn": 1}, {"q_ua": "Скільки коштує вхід?", "answer_text": "безкоштовно", "accept": ["безкоштовний", "0", "нічого"], "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '51e5968a-e703-5e10-8f84-addfd3b5c1c4', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cc81e815-7b56-51b1-89f1-fbc864867898', 'speaking', 'Який твій улюблений жанр?', 'Koji je tvoj omiljeni žanr?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f7283b3-2a95-55e9-aa15-c701a36b5fa5', 'speaking', 'Книжка цікавіша за фільм.', 'Knjiga je zanimljivija od filma.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '313058ee-7350-574e-9762-9faba53bd44b', 'write_message', 'Порадьте подрузі книжку: що це за жанр, про що вона і чому краща за попередню.', 'Čitam kriminalistički roman, radnja se događa u Splitu. Bolji je od prošlog, preporučujem ti ga!', 'A2', 'PUBLISHED', '{"situation_ua": "Порадьте подрузі книжку: що це за жанр, про що вона і чому краща за попередню.", "points": [{"ua": "жанр", "keys": [["roman"], ["žanr"], ["biografij"]]}, {"ua": "про що", "keys": [["radnja"], ["o "]]}, {"ua": "краща за попередню", "keys": [["bolj"], ["zanimljivij"]]}], "hints": ["čitam kriminalistički roman", "radnja se događa", "bolji je od prošlog", "preporučujem"], "models": ["Čitam kriminalistički roman, radnja se događa u Splitu. Bolji je od prošlog, preporučujem ti ga!"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '313058ee-7350-574e-9762-9faba53bd44b', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '8608952f-a54e-5a31-85b6-65e66dad6e4f', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Može li se posudba produžiti online? Imate li zvučne knjige za djecu?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай бібліотекарку, чи можна продовжити позику онлайн і чи є аудіокниги для дітей.", "direction": "ua_hr", "points": [{"ua": "продовжити онлайн", "keys": [["produž"], ["online"]]}, {"ua": "аудіокниги", "keys": [["zvučn"]]}, {"ua": "для дітей", "keys": [["djec"]]}], "hints": [], "models": ["Može li se posudba produžiti online? Imate li zvučne knjige za djecu?"], "source_ua": "Спитай бібліотекарку, чи можна продовжити позику онлайн і чи є аудіокниги для дітей."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '8608952f-a54e-5a31-85b6-65e66dad6e4f', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('909a0933-12e5-54e9-a0d3-94a2ac9b8f78', v_lesson, 'Що ти читаєш?', 'Što čitaš?', 5621, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('f7a96ee6-ae1d-5078-b414-499c437ef704', '909a0933-12e5-54e9-a0d3-94a2ac9b8f78', 'Daša', 'Darja, što čitaš?', 'Дар’є, що ти читаєш?', 1);
  perform pg_temp.turn('48f7d8de-b9a9-5e08-a6ca-82a0c2eb28f3', '909a0933-12e5-54e9-a0d3-94a2ac9b8f78', 'Darja', 'Kriminalistički roman jedne hrvatske spisateljice. Radnja se događa u Splitu.', 'Детектив однієї хорватської письменниці. Дія відбувається у Спліті.', 2);
  perform pg_temp.turn('eeb59c1a-6786-57ea-84b6-e42ee36d37df', '909a0933-12e5-54e9-a0d3-94a2ac9b8f78', 'Daša', 'Je li težak za čitanje na hrvatskom?', 'Важко читати хорватською?', 3);
  perform pg_temp.turn('fa65b915-23fb-5b72-b723-3023d9daa75d', '909a0933-12e5-54e9-a0d3-94a2ac9b8f78', 'Darja', 'Malo, ali sve više razumijem. Napet je, ne mogu ga ispustiti iz ruku.', 'Трохи, але розумію дедалі більше. Він захопливий, не можу відірватися.', 4);
  perform pg_temp.turn('e83af7a6-2e6c-52a4-aba2-3cf7848c198c', '909a0933-12e5-54e9-a0d3-94a2ac9b8f78', 'Daša', 'Je li bolji od prošlog?', 'Він кращий за попередній?', 5);
  perform pg_temp.turn('c66b8f26-8443-5f00-94eb-fbf442f996c9', '909a0933-12e5-54e9-a0d3-94a2ac9b8f78', 'Darja', 'Puno je zanimljiviji od prošlog. Glavni lik je mlada policajka.', 'Набагато цікавіший за попередній. Головна героїня — молода поліцейська.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6e627a7d-1e99-57a3-b459-fbacb7caa739', v_lesson, 'У бібліотеці', 'U knjižnici', 5622, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('4082bda5-07d0-5ee2-8469-de6577c6786a', '6e627a7d-1e99-57a3-b459-fbacb7caa739', 'Ivan', 'Dobar dan, htio bih produžiti posudbu.', 'Добрий день, я хотів би продовжити термін позики.', 1);
  perform pg_temp.turn('8bada065-8f1e-5603-9ca6-bf0fd3f93111', '6e627a7d-1e99-57a3-b459-fbacb7caa739', 'Knjižničarka', 'Vaša članska iskaznica, molim. Jedna knjiga kasni, morate platiti zakasninu.', 'Ваш читацький квиток, будь ласка. Одна книжка прострочена, вам треба заплатити пеню.', 2);
  perform pg_temp.turn('a4e8ea3c-a040-5d9b-9c54-be9058ae07dc', '6e627a7d-1e99-57a3-b459-fbacb7caa739', 'Ivan', 'U redu. Imate li zvučne knjige na hrvatskom?', 'Гаразд. У вас є аудіокниги хорватською?', 3);
  perform pg_temp.turn('41997792-7cfc-5633-91c9-f4b0823fffd7', '6e627a7d-1e99-57a3-b459-fbacb7caa739', 'Knjižničarka', 'Imamo, i e-knjige. Posudba traje tri tjedna.', 'Є, і електронні книги. Позика — на три тижні.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.10 · урок 63: Фільм чи серіал: розкажи сюжет — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'e9d667aa-87ee-5ea7-a0b5-a94f070e6f1d';
  v_lesson constant uuid := 'ef11286d-512d-524a-9edc-e760010d1037';
  v_gid constant uuid := '12a1a49d-9117-5e9d-a64e-66be7a371810';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KOJI'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A2.10: місце 4 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 63: Фільм чи серіал: розкажи сюжет', 'Lekcija 63: Film ili serija: ispričaj radnju', '["Переказати сюжет фільму чи серіалу", "Описати героїв реченнями з koji: To je film koji…, lik kojem…"]'::jsonb, 20, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'serija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glumica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'redatelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uloga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'snimati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'titlovi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sinkroniziran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trailer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iznenađujući kraj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dirljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'napetost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glumiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radi se o', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na početku', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u međuvremenu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispostavi se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nemoj mi otkriti kraj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'strujanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kino projekcija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kino ulaznica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'premijera', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ceb2ff0f-125a-56c6-b3b5-8626bb0e3a0c', 'fill_in_the_blank', 'Gledam seriju ___ ima pet sezona.', 'koja', '["koje", "koja", "koji", "koju"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3e8f859a-e004-5b84-968a-0f43e74bdee4', 'multiple_choice', 'Що означає «u međuvremenu»?', 'тим часом', '["субтитри", "напруга, інтрига", "прем’єра", "тим часом"]'::jsonb, 'A2', 2, 'PUBLISHED', 'u međuvremenu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '28f2d9e2-eefc-5e68-92f2-41b92f52cc41', 'multiple_choice', 'Що означає «redatelj»?', 'режисер', '["йдеться про", "режисер", "субтитри", "грати (роль)"]'::jsonb, 'A2', 3, 'PUBLISHED', 'redatelj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0e709972-8e5d-575b-a09f-2abc86c1347f', 'multiple_choice', 'Що означає «nemoj mi otkriti kraj»?', 'не розповідай мені кінця', '["несподіваний фінал", "прем’єра", "трейлер", "не розповідай мені кінця"]'::jsonb, 'A2', 4, 'PUBLISHED', 'nemoj mi otkriti kraj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b530e61b-f5d9-596b-97d1-b9c796e5b973', 'multiple_choice', 'Як хорватською «грати (роль)»?', 'glumiti', '["redatelj", "glumiti", "radi se o", "ispostavi se"]'::jsonb, 'A2', 5, 'PUBLISHED', 'glumiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3bcd2de4-9b86-58e1-b7da-fbb4a968393b', 'multiple_choice', 'Як хорватською «виявляється»?', 'ispostavi se', '["redatelj", "sinkroniziran", "ispostavi se", "radi se o"]'::jsonb, 'A2', 6, 'PUBLISHED', 'ispostavi se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9bfd3733-0fe1-532d-bd6f-6d6002ac858b', 'type_answer', 'Напишіть хорватською: «трейлер»', 'trailer', null, 'A2', 7, 'PUBLISHED', 'trailer', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ed96684-5fce-507c-ba4c-0db5a7c435b3', 'type_answer', 'Напишіть хорватською: «стримінг»', 'strujanje', null, 'A2', 8, 'PUBLISHED', 'strujanje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f419903a-c327-5c1a-a735-8bd3f412c71b', 'type_answer', 'Напишіть хорватською: «серіал»', 'serija', null, 'A2', 9, 'PUBLISHED', 'serija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c5d57e5-df54-5dec-b4eb-7be6aab08d68', 'sentence_builder', 'Складіть: «Ідеться про родину, яка переїжджає на острів.»', 'Radi se o obitelji koja seli na otok.', '["otok.", "obitelji", "se", "na", "Radi", "o", "koja", "seli"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '066ef3c8-d55e-5738-91c6-f0fc518f7c7f', 'sentence_builder', 'Складіть: «Не розповідай мені кінця!»', 'Nemoj mi otkriti kraj!', '["kraj!", "mi", "Nemoj", "otkriti"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fab87177-9804-547e-b71c-1b1b95a2a3c5', 'listening', 'Прослухайте і складіть фразу', 'Kažu da ima iznenađujući kraj.', '["ima", "Kažu", "iznenađujući", "da", "kraj."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'b220e2c3-a186-51e4-ae2c-6c2a131a8f96', 'listening_dialogue', 'Прослухайте розмову', 'комедію; 19.40; онлайн', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Даша й Дар’я обирають фільм у кіно.", "script": [{"speaker": "Daša", "hr": "Imaju dva filma: komediju i dramu.", "ua": "Є два фільми: комедія й драма."}, {"speaker": "Darja", "hr": "Drama je dirljiva, a meni treba nešto smiješno.", "ua": "Драма зворушлива, а мені потрібно щось смішне."}, {"speaker": "Daša", "hr": "Onda komedija. Projekcija je u devetnaest i četrdeset.", "ua": "Тоді комедія. Сеанс о дев’ятнадцятій сорок."}, {"speaker": "Darja", "hr": "Super, kupit ću ulaznice online.", "ua": "Супер, я куплю квитки онлайн."}], "questions": [{"q_ua": "Що вони обирають?", "options": ["комедію", "драму", "мультфільм"], "correct": 0, "answer_turn": 2}, {"q_ua": "О котрій сеанс?", "answer_text": "19.40", "accept": ["19:40", "19,40", "сьома сорок"], "answer_turn": 2}, {"q_ua": "Як Дар’я купить квитки?", "options": ["у касі", "онлайн", "по телефону"], "correct": 1, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'b220e2c3-a186-51e4-ae2c-6c2a131a8f96', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fbe1b326-cc07-5d23-9c06-dcc277f602af', 'speaking', 'Про що цей фільм?', 'O čemu je ovaj film?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c2073434-db22-5d55-9e12-9283138b55d1', 'speaking', 'Я дивлюся фільми з субтитрами.', 'Gledam filmove s titlovima.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '0b6c2569-8af0-5b8c-b109-44bc1083fb49', 'write_message', 'Перекажіть подрузі в повідомленні коротко сюжет фільму, який ви бачили: про кого він і що сталося.', 'Gledala sam film koji se događa u Dubrovniku. Radi se o mladoj liječnici. Na kraju se ispostavi da je njezin brat živ.', 'A2', 'PUBLISHED', '{"situation_ua": "Перекажіть подрузі в повідомленні коротко сюжет фільму, який ви бачили: про кого він і що сталося.", "points": [{"ua": "про кого", "keys": [["radi se o"], ["glavni lik"], ["o "]]}, {"ua": "що сталося", "keys": [["dogodi"], ["ispostavi"], ["nestaj"], ["na kraju"]]}], "hints": ["gledala sam film koji", "radi se o", "na početku", "na kraju se ispostavi"], "models": ["Gledala sam film koji se događa u Dubrovniku. Radi se o mladoj liječnici. Na kraju se ispostavi da je njezin brat živ."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '0b6c2569-8af0-5b8c-b109-44bc1083fb49', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'b40e5d2c-602c-585b-809b-1a116ea44d37', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Je li film sinkroniziran? Njezin sin još ne čita titlove.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай касира, чи фільм дубльований, бо мій син ще не читає субтитрів.", "direction": "ua_hr", "points": [{"ua": "дубльований", "keys": [["sinkroniz"]]}, {"ua": "син не читає субтитри", "keys": [["titlov"]]}], "hints": [], "models": ["Je li film sinkroniziran? Njezin sin još ne čita titlove."], "source_ua": "Спитай касира, чи фільм дубльований, бо мій син ще не читає субтитрів."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'b40e5d2c-602c-585b-809b-1a116ea44d37', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('08280a16-657c-5011-a9dd-63f74b21961b', v_lesson, 'Про що серіал?', 'O čemu je serija?', 5631, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('6064473f-65f4-5559-9510-5a36cdaf7578', '08280a16-657c-5011-a9dd-63f74b21961b', 'Darja', 'Gledam jednu hrvatsku seriju koja ima tri sezone.', 'Я дивлюся один хорватський серіал, у якого три сезони.', 1);
  perform pg_temp.turn('89e5a42d-6082-591f-b534-705e9eaf9072', '08280a16-657c-5011-a9dd-63f74b21961b', 'Daša', 'O čemu se radi?', 'Про що він?', 2);
  perform pg_temp.turn('503a751c-1e8a-5844-89f0-28ed0056f826', '08280a16-657c-5011-a9dd-63f74b21961b', 'Darja', 'Radi se o obitelji koja seli iz Zagreba na mali otok.', 'Ідеться про родину, яка переїжджає із Загреба на маленький острів.', 3);
  perform pg_temp.turn('1cda788f-509a-51b9-b60a-2279cdd168a1', '08280a16-657c-5011-a9dd-63f74b21961b', 'Daša', 'A što se dogodi?', 'А що трапляється?', 4);
  perform pg_temp.turn('e20d2191-9796-5de4-bfe3-e416aaa01ac5', '08280a16-657c-5011-a9dd-63f74b21961b', 'Darja', 'Na početku je sve mirno. U međuvremenu nestaje susjed kojem su pomagali.', 'Спочатку все спокійно. Тим часом зникає сусід, якому вони допомагали.', 5);
  perform pg_temp.turn('46be00ca-a495-5998-b9fd-df6d6bed42a0', '08280a16-657c-5011-a9dd-63f74b21961b', 'Daša', 'Nemoj mi otkriti kraj, i ja ću je gledati!', 'Не розповідай мені кінця, я теж його дивитимусь!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7f258d5d-ed0e-5352-a471-6be87a3d2eb6', v_lesson, 'Ідемо в кіно', 'Idemo u kino', 5632, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('a4455e92-9f09-53fa-a051-337de5a44cfd', '7f258d5d-ed0e-5352-a471-6be87a3d2eb6', 'Ivan', 'U petak je premijera filma koji su snimali u Dubrovniku.', 'У п’ятницю прем’єра фільму, який знімали в Дубровнику.', 1);
  perform pg_temp.turn('50672577-220c-5313-96be-71d89f3823e4', '7f258d5d-ed0e-5352-a471-6be87a3d2eb6', 'Marko', 'Je li s titlovima ili sinkroniziran?', 'Він із субтитрами чи дубльований?', 2);
  perform pg_temp.turn('5131416f-1bcc-589e-8967-a4d0fb1e0908', '7f258d5d-ed0e-5352-a471-6be87a3d2eb6', 'Ivan', 'S hrvatskim titlovima. Kino projekcija je u dvadeset i trideset.', 'З хорватськими субтитрами. Сеанс о двадцятій тридцять.', 3);
  perform pg_temp.turn('96633a49-db1d-5ad2-8c10-a1340d9504d7', '7f258d5d-ed0e-5352-a471-6be87a3d2eb6', 'Marko', 'Vidio sam trailer, izgleda napeto.', 'Я бачив трейлер, виглядає напружено.', 4);
  perform pg_temp.turn('07edf392-3ea2-58cf-9673-4bf62e9603d1', '7f258d5d-ed0e-5352-a471-6be87a3d2eb6', 'Ivan', 'Kažu da ima iznenađujući kraj.', 'Кажуть, що в нього несподіваний фінал.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.10 · урок 64: Порадь мені! Рекомендації — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'e9d667aa-87ee-5ea7-a0b5-a94f070e6f1d';
  v_lesson constant uuid := '57ba42b9-17e0-5dda-9de1-f0354b45f845';
  v_gid constant uuid := '926638d7-1396-512e-8a05-065c4464b85a';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики POR'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A2.10: місце 5 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 64: Порадь мені! Рекомендації', 'Lekcija 64: Preporuči mi! Preporuke', '["Порадити місце, фільм чи книжку й пояснити чому", "Порівняння: najbolji koji, bolji nego, što prije to bolje"]'::jsonb, 20, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'vrijedi pogledati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrijedi posjetiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ne propusti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'toplo preporučujem', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nije mi se svidjelo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razočaranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'precijenjen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podcijenjen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nezaobilazan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'isplati se otići', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bolji nego što sam očekivao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'što prije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ukus', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dojam', v_pos);
  v_pos := pg_temp.word(v_lesson, 'atmosfera', v_pos);
  v_pos := pg_temp.word(v_lesson, 'omjer cijene i kvalitete', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skriveni dragulj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrhunski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prosječan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ništa posebno', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '9b6aaaba-cc3e-562d-8e37-bff32b5c15ec', 'fill_in_the_blank', 'Film je bolji ___ što sam očekivao.', 'nego', '["kao", "koji", "od", "nego"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cb07fbda-6498-5bbb-9503-38879a85317d', 'multiple_choice', 'Що означає «vrijedi posjetiti»?', 'варто відвідати', '["варто відвідати", "розчарування", "кращий, ніж я очікував", "недооцінений"]'::jsonb, 'A2', 2, 'PUBLISHED', 'vrijedi posjetiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eadaf590-451b-5c28-a5a0-30f5b702f083', 'multiple_choice', 'Що означає «bolji nego što sam očekivao»?', 'кращий, ніж я очікував', '["варто подивитися", "розчарування", "кращий, ніж я очікував", "мені не сподобалося"]'::jsonb, 'A2', 3, 'PUBLISHED', 'bolji nego što sam očekivao', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d073667-5752-5159-ba36-c3dca3dfc661', 'multiple_choice', 'Що означає «skriveni dragulj»?', 'прихована перлина', '["варто відвідати", "смак (вподобання)", "прихована перлина", "недооцінений"]'::jsonb, 'A2', 4, 'PUBLISHED', 'skriveni dragulj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '367748d4-e75d-59ee-9fe5-cd35c013a025', 'multiple_choice', 'Як хорватською «посередній»?', 'prosječan', '["ukus", "razočaranje", "vrijedi pogledati", "prosječan"]'::jsonb, 'A2', 5, 'PUBLISHED', 'prosječan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'edd21769-585e-5aaf-b3ce-335c2311fc43', 'multiple_choice', 'Як хорватською «недооцінений»?', 'podcijenjen', '["ništa posebno", "podcijenjen", "dojam", "što prije"]'::jsonb, 'A2', 6, 'PUBLISHED', 'podcijenjen', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dbc7ff77-9005-5d52-baf7-4c011817ac7a', 'type_answer', 'Напишіть хорватською: «смак (вподобання)»', 'ukus', null, 'A2', 7, 'PUBLISHED', 'ukus', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a89d6403-43b1-5a2a-91d3-e3536f772e6b', 'type_answer', 'Напишіть хорватською: «переоцінений»', 'precijenjen', null, 'A2', 8, 'PUBLISHED', 'precijenjen', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4cc231ab-1847-5d6b-8465-60a3f236a498', 'type_answer', 'Напишіть хорватською: «не пропусти»', 'ne propusti', null, 'A2', 9, 'PUBLISHED', 'ne propusti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1812c8b2-f5ee-5d25-98ac-e216c082827f', 'sentence_builder', 'Складіть: «Цей фільм варто подивитися.»', 'Taj film vrijedi pogledati.', '["vrijedi", "Taj", "film", "pogledati."]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ced9aab7-4f62-528a-b5ae-3371461d7537', 'sentence_builder', 'Складіть: «Бронюйте якнайшвидше.»', 'Rezervirajte što prije.', '["prije.", "Rezervirajte", "što"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8ccb1a4f-a633-579f-801c-1b48886b8268', 'listening', 'Прослухайте і складіть фразу', 'Vikendom da. Isplati se otići rano ujutro.', '["otići", "ujutro.", "Isplati", "se", "Vikendom", "rano", "da."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'aea5b922-58d0-57dc-a3bb-4d5d6ce97666', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'у вересні; великий натовп; онлайн', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Подруга надіслала вам голосове з порадою.", "script": [{"hr": "Bok, ovdje Ivana! Pitala si me za Plitvice.", "ua": "Привіт, це Івана! Ти питала мене про Плітвиці."}, {"hr": "Toplo preporučujem, ali idi u rujnu jer je ljeti velika gužva.", "ua": "Щиро раджу, але їдь у вересні, бо влітку великий натовп."}, {"hr": "Ulaznice kupi online što prije, jeftinije su.", "ua": "Квитки купуй онлайн якнайшвидше, вони дешевші."}], "questions": [{"q_ua": "Коли Івана радить їхати?", "options": ["у вересні", "у липні", "у травні"], "correct": 0, "answer_turn": 1}, {"q_ua": "Чому не влітку?", "options": ["спекотно", "великий натовп", "зачинено"], "correct": 1, "answer_turn": 1}, {"q_ua": "Як купити квитки?", "answer_text": "онлайн", "accept": ["online", "через інтернет", "на сайті"], "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'aea5b922-58d0-57dc-a3bb-4d5d6ce97666', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '154e27ee-b1e0-5f00-a24d-c101f773e6e2', 'speaking', 'Порадь мені якийсь ресторан.', 'Preporuči mi neki restoran.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '95769281-76ed-5ae9-be87-6501e28d6584', 'speaking', 'Щиро раджу цю книжку.', 'Toplo preporučujem ovu knjigu.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'be40045e-fb04-52ab-99b4-ac6eba5190bd', 'write_message', 'Порадьте колезі ресторан: де він, що там варто скуштувати і чому він кращий за інші.', 'Toplo preporučujem malu konobu iza tržnice. Svakako probaj ribu, bolja je nego u centru.', 'A2', 'PUBLISHED', '{"situation_ua": "Порадьте колезі ресторан: де він, що там варто скуштувати і чому він кращий за інші.", "points": [{"ua": "порада", "keys": [["preporuč"]]}, {"ua": "що скуштувати", "keys": [["prob"], ["jel"], ["rib"]]}, {"ua": "кращий", "keys": [["bolj"], ["najbolj"]]}], "hints": ["toplo preporučujem", "konoba iza tržnice", "svakako probaj", "bolja je od"], "models": ["Toplo preporučujem malu konobu iza tržnice. Svakako probaj ribu, bolja je nego u centru."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'be40045e-fb04-52ab-99b4-ac6eba5190bd', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'cde9822d-b2bf-509a-b498-ade8d186cead', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Film je prosječan i nije mu se svidio.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи Марку, що фільм посередній і мені не сподобався.", "direction": "ua_hr", "points": [{"ua": "посередній", "keys": [["prosječ"], ["ništa posebno"]]}, {"ua": "не сподобався", "keys": [["nije mu se svidio"], ["svidio"]]}], "hints": [], "models": ["Film je prosječan i nije mu se svidio."], "source_ua": "Скажи Марку, що фільм посередній і мені не сподобався."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'cde9822d-b2bf-509a-b498-ade8d186cead', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7480d7ba-a645-56e4-b0eb-98fdce226b36', v_lesson, 'Куди піти у вихідні?', 'Kamo vikendom?', 5641, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('538ecb68-13eb-559a-b84d-dbed5a52c964', '7480d7ba-a645-56e4-b0eb-98fdce226b36', 'Darja', 'Daša, preporuči mi neko mjesto za vikend.', 'Дашо, порадь мені якесь місце на вихідні.', 1);
  perform pg_temp.turn('ee3fdc70-12ff-55c5-9c23-27a56b791178', '7480d7ba-a645-56e4-b0eb-98fdce226b36', 'Daša', 'Toplo preporučujem Samobor. To je skriveni dragulj blizu Zagreba.', 'Щиро раджу Самобор. Це прихована перлина біля Загреба.', 2);
  perform pg_temp.turn('2b697037-a745-59c8-9535-8e13dd88f053', '7480d7ba-a645-56e4-b0eb-98fdce226b36', 'Darja', 'Što vrijedi posjetiti?', 'Що варто відвідати?', 3);
  perform pg_temp.turn('06f55447-4e9e-5381-b101-e9ea9e101e25', '7480d7ba-a645-56e4-b0eb-98fdce226b36', 'Daša', 'Stari grad i šetnicu uz potok. I svakako probaj kremšnitu!', 'Старе місто й стежку вздовж потічка. І обов’язково скуштуй кремшниту!', 4);
  perform pg_temp.turn('8a337e52-98f1-5f5c-8167-fd096b3e1b4a', '7480d7ba-a645-56e4-b0eb-98fdce226b36', 'Darja', 'Je li tamo velika gužva?', 'Там великий натовп?', 5);
  perform pg_temp.turn('7c210378-160d-5780-aa4a-ac27bb6729d0', '7480d7ba-a645-56e4-b0eb-98fdce226b36', 'Daša', 'Vikendom da. Isplati se otići rano ujutro.', 'На вихідних так. Варто поїхати рано вранці.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('391a105e-0fee-5a1d-a055-904748c47409', v_lesson, 'Ресторан', 'Restoran', 5642, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('7f5acaae-1b3a-5dac-83a7-c3814fa81f99', '391a105e-0fee-5a1d-a055-904748c47409', 'Ivan', 'Jesi li bio u onom novom restoranu u centru?', 'Ти був у тому новому ресторані в центрі?', 1);
  perform pg_temp.turn('82978c50-b54b-56ec-afc9-c5a74c6be4fa', '391a105e-0fee-5a1d-a055-904748c47409', 'Marko', 'Jesam. Iskreno, precijenjen je. Hrana je prosječna, a cijene visoke.', 'Так. Чесно, він переоцінений. Їжа посередня, а ціни високі.', 2);
  perform pg_temp.turn('983a074b-4929-5daa-a462-05f47d1fa0b6', '391a105e-0fee-5a1d-a055-904748c47409', 'Ivan', 'Šteta. A neki bolji?', 'Шкода. А якийсь кращий?', 3);
  perform pg_temp.turn('f45fdb9a-6d74-58b6-843a-778df4bf6a27', '391a105e-0fee-5a1d-a055-904748c47409', 'Marko', 'Mala konoba iza tržnice. Omjer cijene i kvalitete je odličan.', 'Маленька коноба за ринком. Співвідношення ціни й якості чудове.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.10 · урок 65: Що ти про це думаєш? — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'e9d667aa-87ee-5ea7-a0b5-a94f070e6f1d';
  v_lesson constant uuid := 'd6b9db92-a933-5d45-8f17-f6e911a97ab1';
  v_gid constant uuid := '59c6c708-59b5-5781-bf5d-4ecd5aa8b7dc';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики ZAV'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A2.10: місце 6 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 65: Що ти про це думаєш?', 'Lekcija 65: Što misliš o tome?', '["Висловити й обґрунтувати думку: Čini mi se da…, Mislim da… jer…", "Поєднувати аргументи: zato što, iako, osim toga"]'::jsonb, 20, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'čini mi se da', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uvjeren sam da', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sumnjam da', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovisi o', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iako', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zato što', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osim toga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naime', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dakle', v_pos);
  v_pos := pg_temp.word(v_lesson, 'unatoč tome', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glavni razlog', v_pos);
  v_pos := pg_temp.word(v_lesson, 'moglo bi se reći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nema smisla', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ima smisla', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tema', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gledište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'javno mnijenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podijeljen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaključiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'primjerice', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f62d088a-f438-5628-ae2a-296ede25351b', 'fill_in_the_blank', '___ je skupo, isplati se.', 'Iako', '["Naime", "Dakle", "Zato što", "Iako"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ff58c6f3-3076-52d7-a8b7-4b7bef529d8c', 'multiple_choice', 'Що означає «moglo bi se reći»?', 'можна було б сказати', '["головна причина", "можна було б сказати", "залежить від", "точка зору"]'::jsonb, 'A2', 2, 'PUBLISHED', 'moglo bi se reći', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '669c933b-4b2d-5050-9f03-7a2364c1bab4', 'multiple_choice', 'Що означає «glavni razlog»?', 'головна причина', '["я переконаний, що", "головна причина", "немає сенсу", "попри це"]'::jsonb, 'A2', 3, 'PUBLISHED', 'glavni razlog', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '377bef37-d5ab-54bd-b2d2-fad5890d5c95', 'multiple_choice', 'Що означає «tema»?', 'тема', '["тому що", "сумніваюся, що", "отже", "тема"]'::jsonb, 'A2', 4, 'PUBLISHED', 'tema', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '14c302d2-f379-56dd-940f-9a835997f969', 'multiple_choice', 'Як хорватською «має сенс»?', 'ima smisla', '["iako", "ima smisla", "čini mi se da", "unatoč tome"]'::jsonb, 'A2', 5, 'PUBLISHED', 'ima smisla', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aea4a3fe-f0f8-5b50-ba4d-981173dab4c9', 'multiple_choice', 'Як хорватською «мені здається, що»?', 'čini mi se da', '["čini mi se da", "ima smisla", "uvjeren sam da", "zato što"]'::jsonb, 'A2', 6, 'PUBLISHED', 'čini mi se da', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9b30c973-adf9-5d4d-ba6a-dd29bbe4153a', 'type_answer', 'Напишіть хорватською: «отже»', 'dakle', null, 'A2', 7, 'PUBLISHED', 'dakle', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd08278c3-1b02-56c4-b4da-6cc975664c6e', 'type_answer', 'Напишіть хорватською: «хоча»', 'iako', null, 'A2', 8, 'PUBLISHED', 'iako', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2ab38857-a19a-5293-8a82-ec975fc58055', 'type_answer', 'Напишіть хорватською: «наприклад»', 'primjerice', null, 'A2', 9, 'PUBLISHED', 'primjerice', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '12a58ed9-06d8-53d9-8b59-c1e9de6dcaa3', 'sentence_builder', 'Складіть: «Мені здається, що це добре рішення.»', 'Čini mi se da je to dobra odluka.', '["odluka.", "je", "dobra", "to", "da", "Čini", "se", "mi"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0b56e58b-a5f9-53c8-bef1-986066baeed8', 'sentence_builder', 'Складіть: «Головна причина — ціна.»', 'Glavni razlog je cijena.', '["je", "Glavni", "razlog", "cijena."]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3db5a050-b7df-50f6-b5a1-eecfadc9e765', 'listening', 'Прослухайте і складіть фразу', 'Najam. Primjerice, mladi ne mogu naći stan zato što su svi stanovi za turiste.', '["što", "stan", "za", "mladi", "ne", "stanovi", "turiste.", "svi", "su", "Primjerice,", "Najam.", "mogu", "zato", "naći"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '16c4de58-ef9f-5a6e-a87d-b44d546e720e', 'listening_dialogue', 'Прослухайте новину', 'про нові ціни на паркування; ціни зависокі; велосипед', 'A2', 'PUBLISHED', '{"kind": "news", "situation_ua": "Ви слухаєте радіоопитування на вулиці.", "script": [{"hr": "Pitali smo građane što misle o novim cijenama parkiranja.", "ua": "Ми запитали громадян, що вони думають про нові ціни на паркування."}, {"hr": "Većina misli da su previsoke, iako se slažu da u centru ima premalo mjesta.", "ua": "Більшість вважає, що вони зависокі, хоча погоджуються, що в центрі замало місць."}, {"hr": "Mladi kažu da ionako voze bicikl.", "ua": "Молодь каже, що все одно їздить на велосипеді."}], "questions": [{"q_ua": "Про що опитування?", "options": ["про нові ціни на паркування", "про туризм", "про транспорт уночі"], "correct": 0, "answer_turn": 0}, {"q_ua": "Що думає більшість?", "options": ["ціни нормальні", "ціни зависокі", "паркування не потрібне"], "correct": 1, "answer_turn": 1}, {"q_ua": "На чому, за їхніми словами, їздить молодь?", "answer_text": "велосипед", "accept": ["на велосипеді", "велосипедом", "bicikl"], "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '16c4de58-ef9f-5a6e-a87d-b44d546e720e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f4054649-ab77-5582-a2de-8c191a032e30', 'speaking', 'Залежить від ситуації.', 'Ovisi o situaciji.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b31c0584-e65b-50bc-bb45-d18060e3b2f8', 'speaking', 'Сумніваюся, що ціни впадуть.', 'Sumnjam da će cijene pasti.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '409b42dc-2123-55f9-a3e5-494fb3fb0f7f', 'write_message', 'Напишіть думку в коментарі на міському порталі: ви вважаєте, що в центрі потрібно більше велосипедних доріжок, і поясніть чому.', 'Mislim da u centru treba više biciklističkih staza, zato što je promet prevelik. Osim toga, zrak bi bio čišći.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть думку в коментарі на міському порталі: ви вважаєте, що в центрі потрібно більше велосипедних доріжок, і поясніть чому.", "points": [{"ua": "думка", "keys": [["mislim"], ["čini mi se"], ["uvjeren"]]}, {"ua": "велосипедні доріжки", "keys": [["bicikl"]]}, {"ua": "чому", "keys": [["zato"], ["jer"]]}], "hints": ["mislim da", "u centru treba više biciklističkih staza", "zato što", "osim toga"], "models": ["Mislim da u centru treba više biciklističkih staza, zato što je promet prevelik. Osim toga, zrak bi bio čišći."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '409b42dc-2123-55f9-a3e5-494fb3fb0f7f', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '1008a03c-9463-5112-9de6-354578a3d6ef', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Po njegovom mišljenju, rad od kuće ima smisla, iako ne svaki dan.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи колегам, що, на мою думку, робота з дому має сенс, хоча не кожного дня.", "direction": "ua_hr", "points": [{"ua": "має сенс", "keys": [["smisl"]]}, {"ua": "робота з дому", "keys": [["kuć"]]}, {"ua": "не кожного дня", "keys": [["svaki dan"], ["iako"]]}], "hints": [], "models": ["Po njegovom mišljenju, rad od kuće ima smisla, iako ne svaki dan."], "source_ua": "Скажи колегам, що, на мою думку, робота з дому має сенс, хоча не кожного дня."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '1008a03c-9463-5112-9de6-354578a3d6ef', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('59f4ea4d-c462-5701-a23a-35ed4f03fcc8', v_lesson, 'Туризм у Спліті', 'Turizam u Splitu', 5651, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('109115ce-cd4c-5e36-bb7f-a4ee1bf1024a', '59f4ea4d-c462-5701-a23a-35ed4f03fcc8', 'Ivan', 'Što misliš o turizmu u Splitu? Ljeti je grad prenapučen.', 'Що ти думаєш про туризм у Спліті? Улітку місто переповнене.', 1);
  perform pg_temp.turn('0278abc1-9981-520d-8f36-7c95eea9b997', '59f4ea4d-c462-5701-a23a-35ed4f03fcc8', 'Darja', 'Čini mi se da je turizam dobar za grad, iako ima problema.', 'Мені здається, що туризм добрий для міста, хоча є проблеми.', 2);
  perform pg_temp.turn('2974b37a-31d0-5054-b6a1-b330e9736dab', '59f4ea4d-c462-5701-a23a-35ed4f03fcc8', 'Ivan', 'Koji je glavni problem?', 'Яка головна проблема?', 3);
  perform pg_temp.turn('92f98c7d-d58d-5524-a626-b4353721b65a', '59f4ea4d-c462-5701-a23a-35ed4f03fcc8', 'Darja', 'Najam. Primjerice, mladi ne mogu naći stan zato što su svi stanovi za turiste.', 'Оренда. Наприклад, молоді не можуть знайти квартиру, бо всі квартири для туристів.', 4);
  perform pg_temp.turn('7ac9faab-7ed3-512e-8388-9cdc3a71fa67', '59f4ea4d-c462-5701-a23a-35ed4f03fcc8', 'Ivan', 'Osim toga, cijene su sve više.', 'Крім того, ціни дедалі вищі.', 5);
  perform pg_temp.turn('733e838b-c711-5c03-86a5-1f21fad1bff4', '59f4ea4d-c462-5701-a23a-35ed4f03fcc8', 'Darja', 'Dakle, treba naći ravnotežu.', 'Отже, треба знайти рівновагу.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b4dd1542-9a39-5b6b-b285-9b12c3a68061', v_lesson, 'Робота з дому', 'Rad od kuće', 5652, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('b76c7380-07e8-51c1-9c97-649c43e66ba0', 'b4dd1542-9a39-5b6b-b285-9b12c3a68061', 'Daša', 'Je li rad od kuće dobar ili loš?', 'Робота з дому — це добре чи погано?', 1);
  perform pg_temp.turn('05399335-4aa4-5257-be38-aaee9e45e0f7', 'b4dd1542-9a39-5b6b-b285-9b12c3a68061', 'Marko', 'Ovisi o poslu. Za mene ima smisla, naime živim daleko.', 'Залежить від роботи. Для мене це має сенс, річ у тім, що я живу далеко.', 2);
  perform pg_temp.turn('5e1f0c19-9284-5a2e-b5c4-e26438b5c0c1', 'b4dd1542-9a39-5b6b-b285-9b12c3a68061', 'Daša', 'Sumnjam da je dobro za timski rad.', 'Сумніваюся, що це добре для командної роботи.', 3);
  perform pg_temp.turn('890c041f-9acd-5e1d-aa21-644524825d7b', 'b4dd1542-9a39-5b6b-b285-9b12c3a68061', 'Marko', 'Mišljenja su podijeljena. S mog gledišta, dva dana od kuće su idealna.', 'Думки розділилися. З моєї точки зору, два дні з дому — ідеально.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- 3. Модуль і юніт — опубліковані
update public.modules set status = 'PUBLISHED', title_ua = 'Модуль A2.10 — Медіа, культура й думки', title_hr = 'Modul A2.10 — Mediji, kultura i mišljenja' where id = '285d2a27-68a4-5302-afc3-9595d071647a';
update public.units set status = 'PUBLISHED' where id = 'e9d667aa-87ee-5ea7-a0b5-a94f070e6f1d';

-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('92bd4e0c-f9df-5edb-a65e-9549fe1ef1b8', '3fc81316-dca8-5661-88c1-eaf2b61aec07', '2e7e2800-1867-5d3e-9cee-d712b2e8e9e0', 'ef11286d-512d-524a-9edc-e760010d1037', '57ba42b9-17e0-5dda-9de1-f0354b45f845', 'd6b9db92-a933-5d45-8f17-f6e911a97ab1')
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
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 20 or l.unit_id <> 'e9d667aa-87ee-5ea7-a0b5-a94f070e6f1d');
  select count(*) into v_titles from (values ('92bd4e0c-f9df-5edb-a65e-9549fe1ef1b8'::uuid, 'Урок 60:%', 1), ('3fc81316-dca8-5661-88c1-eaf2b61aec07'::uuid, 'Урок 61:%', 2), ('2e7e2800-1867-5d3e-9cee-d712b2e8e9e0'::uuid, 'Урок 62:%', 3), ('ef11286d-512d-524a-9edc-e760010d1037'::uuid, 'Урок 63:%', 4), ('57ba42b9-17e0-5dda-9de1-f0354b45f845'::uuid, 'Урок 64:%', 5), ('d6b9db92-a933-5d45-8f17-f6e911a97ab1'::uuid, 'Урок 65:%', 6)) as t(id, pat, o)
    left join public.lessons l on l.id = t.id and l.title_ua like t.pat and l.order_index = t.o
   where l.id is null;
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
      where l.level_code = 'A2' and l.status = 'PUBLISHED' and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A2.10: % уроків з неправильним складом', v_bad; end if;
  if v_titles > 0 then raise exception 'Модуль A2.10: % уроків не на своєму місці чи з неправильним номером', v_titles; end if;
  if v_words > 0 then raise exception 'A2: % слів повторюються в кількох уроках', v_words; end if;
  if (select status from public.modules where id = '285d2a27-68a4-5302-afc3-9595d071647a') <> 'PUBLISHED' then raise exception 'Модуль A2.10 не опубліковано'; end if;
  raise notice 'Готово: модуль A2.10 — 6 уроків, слів 124';
end $$;

commit;
