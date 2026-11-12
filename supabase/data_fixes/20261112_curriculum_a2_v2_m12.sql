-- =====================================================================
-- Програма A2 v2 · модуль A2.12 «Українці в Хорватії» · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2.py 12 (не редагуйте вручну).
--
-- Рішення власника 2026-11-12: 20–25 нових слів на урок, 90–95 % слів — нові для рівня, діалоги під тему,
-- частіше Даша / Дар’я; «Прослухайте діалог чи оголошення» в кожному уроці; бета (PUBLISHED).
--   * Уроки 72–77 (6): слів у них 125. Кожен: 20–25 слів, 2 діалоги, 15 вправ
--     (одна — «Прослухайте діалог чи оголошення»), «Напишіть повідомлення» і «Перекажіть другу» (ua → hr, необов’язкові), 20 хв.
--   * Слова: 125 (нові — PUBLISHED; ті, що вже є в словнику, не змінюються).
--   * Модуль і юніт A2.12 → PUBLISHED. Потрібен уже запущений 20261112_curriculum_a2_v2_00_structure.sql.
--   * Нічого не видаляє. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.units where id = '6bdd7152-8541-5f3c-bf86-bc301e283140') then
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

-- 1. Слова уроків A2.12 (125): нові — PUBLISHED (бета); наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A2', t.ua, t.vtype, t.forms, t.examples, 'PUBLISHED', 'claude_curriculum_a2_v2'
  from jsonb_to_recordset('[{"lemma": "status privremene zaštite", "normalized": "status privremene zastite", "pos": "phrase", "ua": "статус тимчасового захисту", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Status privremene zaštite traje do iduće godine."]}, {"lemma": "iskaznica stranca", "normalized": "iskaznica stranca", "pos": "phrase", "ua": "посвідка іноземця", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Iskaznicu stranca podižem za dva tjedna."]}, {"lemma": "dozvola boravka", "normalized": "dozvola boravka", "pos": "phrase", "ua": "дозвіл на проживання", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za posao trebam dozvolu boravka i rada."]}, {"lemma": "produljiti boravak", "normalized": "produljiti boravak", "pos": "phrase", "ua": "продовжити перебування", "vtype": "chunk", "forms": {}, "examples": ["Boravak moram produljiti prije isteka."]}, {"lemma": "stalni boravak", "normalized": "stalni boravak", "pos": "phrase", "ua": "постійне проживання", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Nakon pet godina možete tražiti stalni boravak."]}, {"lemma": "raseljena osoba", "normalized": "raseljena osoba", "pos": "phrase", "ua": "переміщена особа", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Raseljene osobe imaju pravo na smještaj."]}, {"lemma": "istek valjanosti iskaznice", "normalized": "istek valjanosti iskaznice", "pos": "phrase", "ua": "закінчення строку дії посвідки", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Prije isteka valjanosti iskaznice predajte zahtjev."]}, {"lemma": "biometrijska fotografija", "normalized": "biometrijska fotografija", "pos": "phrase", "ua": "біометричне фото", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Biometrijska fotografija se radi u policiji."]}, {"lemma": "otisak prsta", "normalized": "otisak prsta", "pos": "phrase", "ua": "відбиток пальця", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Uzeli su mi otiske prstiju."]}, {"lemma": "odjel za strance", "normalized": "odjel za strance", "pos": "phrase", "ua": "відділ у справах іноземців", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Odjel za strance radi do podne."]}, {"lemma": "naručiti termin online", "normalized": "naruciti termin online", "pos": "phrase", "ua": "записатися онлайн", "vtype": "chunk", "forms": {}, "examples": ["Termin u policiji možete naručiti online."]}, {"lemma": "maloljetno dijete", "normalized": "maloljetno dijete", "pos": "phrase", "ua": "неповнолітня дитина", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Za maloljetno dijete dolazi roditelj."]}, {"lemma": "članovi obitelji", "normalized": "clanovi obitelji", "pos": "phrase", "ua": "члени родини", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Svim članovima obitelji produljuje se status."]}, {"lemma": "ukrajinska putovnica", "normalized": "ukrajinska putovnica", "pos": "phrase", "ua": "український паспорт", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Ukrajinska putovnica mi ističe za godinu dana."]}, {"lemma": "konzulat", "normalized": "konzulat", "pos": "noun", "ua": "консульство", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Novu putovnicu radim u konzulatu."]}, {"lemma": "potvrda o prebivalištu", "normalized": "potvrda o prebivalistu", "pos": "phrase", "ua": "довідка про місце проживання", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za produljenje treba potvrda o prebivalištu."]}, {"lemma": "prijaviti adresu", "normalized": "prijaviti adresu", "pos": "phrase", "ua": "зареєструвати адресу", "vtype": "chunk", "forms": {}, "examples": ["Novu adresu morate prijaviti u roku od osam dana."]}, {"lemma": "obavijestiti", "normalized": "obavijestiti", "pos": "verb", "ua": "повідомити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "obavještavati"}, "examples": ["O selidbi obavijestite policiju."]}, {"lemma": "rok važenja", "normalized": "rok vazenja", "pos": "phrase", "ua": "строк дії", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Rok važenja iskaznice je godinu dana."]}, {"lemma": "pravo na rad", "normalized": "pravo na rad", "pos": "phrase", "ua": "право на роботу", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["S ovim statusom imate pravo na rad."]}, {"lemma": "ostati u Hrvatskoj", "normalized": "ostati u hrvatskoj", "pos": "phrase", "ua": "залишитися в Хорватії", "vtype": "chunk", "forms": {}, "examples": ["Još ne znamo hoćemo li ostati u Hrvatskoj."]}, {"lemma": "ukrajinska zajednica", "normalized": "ukrajinska zajednica", "pos": "phrase", "ua": "українська громада", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Ukrajinska zajednica u Zagrebu je velika."]}, {"lemma": "udruga", "normalized": "udruga", "pos": "noun", "ua": "асоціація, громадська організація", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Udruga organizira tečajeve hrvatskog."]}, {"lemma": "pridružiti se", "normalized": "pridruziti se", "pos": "verb", "ua": "приєднатися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "pridruživati se"}, "examples": ["Pridružila sam se udruzi prošle godine."]}, {"lemma": "članarina u udruzi", "normalized": "clanarina u udruzi", "pos": "phrase", "ua": "членський внесок в асоціації", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Članarina u udruzi je simbolična."]}, {"lemma": "okupljanje", "normalized": "okupljanje", "pos": "noun", "ua": "зустріч, збори", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Okupljanje je svake nedjelje poslije mise."]}, {"lemma": "subotnja škola", "normalized": "subotnja skola", "pos": "phrase", "ua": "суботня школа", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Djeca idu u subotnju školu ukrajinskog."]}, {"lemma": "grkokatolička crkva", "normalized": "grkokatolicka crkva", "pos": "phrase", "ua": "греко-католицька церква", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Grkokatolička crkva je u centru grada."]}, {"lemma": "pravoslavna crkva", "normalized": "pravoslavna crkva", "pos": "phrase", "ua": "православна церква", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na Uskrs idemo u pravoslavnu crkvu."]}, {"lemma": "nacionalna manjina", "normalized": "nacionalna manjina", "pos": "phrase", "ua": "національна меншина", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Ukrajinci su u Hrvatskoj nacionalna manjina."]}, {"lemma": "Rusini", "normalized": "rusini", "pos": "noun", "ua": "русини", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Rusini i Ukrajinci žive u Slavoniji stoljećima."]}, {"lemma": "kulturno društvo", "normalized": "kulturno drustvo", "pos": "phrase", "ua": "культурне товариство", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Kulturno društvo ima zbor i folklor."]}, {"lemma": "obilježiti", "normalized": "obiljeziti", "pos": "verb", "ua": "відзначити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "obilježavati"}, "examples": ["Dan neovisnosti obilježili smo zajedno."]}, {"lemma": "Dan neovisnosti Ukrajine", "normalized": "dan neovisnosti ukrajine", "pos": "phrase", "ua": "День Незалежності України", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Dan neovisnosti Ukrajine je dvadeset četvrtog kolovoza."]}, {"lemma": "druženje", "normalized": "druzenje", "pos": "noun", "ua": "спілкування, дружні зустрічі", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Druženje nam je važno."]}, {"lemma": "međusobna pomoć", "normalized": "medusobna pomoc", "pos": "phrase", "ua": "взаємодопомога", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Međusobna pomoć je temelj zajednice."]}, {"lemma": "savjetovati", "normalized": "savjetovati", "pos": "verb", "ua": "радити, консультувати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Udruga savjetuje ljude oko dokumenata."]}, {"lemma": "prevoditelj volonter", "normalized": "prevoditelj volonter", "pos": "phrase", "ua": "перекладач-волонтер", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Prevoditelj volonter ide s ljudima liječniku."]}, {"lemma": "Facebook grupa", "normalized": "facebook grupa", "pos": "phrase", "ua": "група у Facebook", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Sve novosti su u Facebook grupi."]}, {"lemma": "novopridošli", "normalized": "novopridosli", "pos": "noun", "ua": "новоприбулі", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Novopridošlima pomažemo naći stan."]}, {"lemma": "osjećati se kao kod kuće", "normalized": "osjecati se kao kod kuce", "pos": "phrase", "ua": "почуватися як удома", "vtype": "chunk", "forms": {}, "examples": ["Ovdje se osjećam kao kod kuće."]}, {"lemma": "volontiranje", "normalized": "volontiranje", "pos": "noun", "ua": "волонтерство", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Volontiranje mi daje smisao."]}, {"lemma": "volonterka", "normalized": "volonterka", "pos": "noun", "ua": "волонтерка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Volonterke pakiraju pakete subotom."]}, {"lemma": "humanitarna pomoć", "normalized": "humanitarna pomoc", "pos": "phrase", "ua": "гуманітарна допомога", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Humanitarna pomoć ide kamionom u Ukrajinu."]}, {"lemma": "humanitarna akcija", "normalized": "humanitarna akcija", "pos": "phrase", "ua": "благодійна акція", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U školi je humanitarna akcija za bolnicu."]}, {"lemma": "donacija", "normalized": "donacija", "pos": "noun", "ua": "пожертва", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Primamo donacije u novcu i hrani."]}, {"lemma": "donirati", "normalized": "donirati", "pos": "verb", "ua": "пожертвувати", "vtype": "core", "forms": {"aspect": "biasp"}, "examples": ["Donirala sam odjeću za djecu."]}, {"lemma": "prikupljanje", "normalized": "prikupljanje", "pos": "noun", "ua": "збір (допомоги)", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Prikupljanje traje do petka."]}, {"lemma": "prikupiti", "normalized": "prikupiti", "pos": "verb", "ua": "зібрати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "prikupljati"}, "examples": ["Prikupili smo dvije tone hrane."]}, {"lemma": "dugotrajna hrana", "normalized": "dugotrajna hrana", "pos": "phrase", "ua": "їжа тривалого зберігання", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Trebamo dugotrajnu hranu i vodu."]}, {"lemma": "higijenske potrepštine", "normalized": "higijenske potrepstine", "pos": "phrase", "ua": "засоби гігієни", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Skupljamo higijenske potrepštine za majke."]}, {"lemma": "generator", "normalized": "generator", "pos": "noun", "ua": "генератор", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Kupili smo generator za bolnicu."]}, {"lemma": "sabirno mjesto", "normalized": "sabirno mjesto", "pos": "phrase", "ua": "пункт збору", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Sabirno mjesto je u dvorani škole."]}, {"lemma": "pakirati", "normalized": "pakirati", "pos": "verb", "ua": "пакувати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Volonteri pakiraju kutije."]}, {"lemma": "pomagati starijima", "normalized": "pomagati starijima", "pos": "phrase", "ua": "допомагати літнім людям", "vtype": "chunk", "forms": {}, "examples": ["Subotom pomažem starijima u domu."]}, {"lemma": "dom za starije", "normalized": "dom za starije", "pos": "phrase", "ua": "будинок для літніх людей", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Volontiram u domu za starije."]}, {"lemma": "pučka kuhinja", "normalized": "pucka kuhinja", "pos": "phrase", "ua": "соціальна їдальня", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["U pučkoj kuhinji dijelimo ručak."]}, {"lemma": "zahvaliti volonterima", "normalized": "zahvaliti volonterima", "pos": "phrase", "ua": "подякувати волонтерам", "vtype": "chunk", "forms": {}, "examples": ["Gradonačelnik je zahvalio volonterima."]}, {"lemma": "solidarnost", "normalized": "solidarnost", "pos": "noun", "ua": "солідарність", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Solidarnost Hrvata nas je dirnula."]}, {"lemma": "dirnuti", "normalized": "dirnuti", "pos": "verb", "ua": "зворушити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "dirati"}, "examples": ["Njihova pomoć me jako dirnula."]}, {"lemma": "vratiti dobrotu", "normalized": "vratiti dobrotu", "pos": "phrase", "ua": "віддячити добром", "vtype": "chunk", "forms": {}, "examples": ["Volontiram da vratim dobrotu."]}, {"lemma": "dobrotvorni", "normalized": "dobrotvorni", "pos": "adjective", "ua": "благодійний", "vtype": "core", "forms": {}, "examples": ["Dobrotvorni koncert je prikupio novac za bolnicu."]}, {"lemma": "neprofitni", "normalized": "neprofitni", "pos": "adjective", "ua": "неприбутковий", "vtype": "core", "forms": {}, "examples": ["To je neprofitna organizacija."]}, {"lemma": "kurirska služba", "normalized": "kurirska sluzba", "pos": "phrase", "ua": "кур’єрська служба", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Paket šaljem kurirskom službom."]}, {"lemma": "poslati paket", "normalized": "poslati paket", "pos": "phrase", "ua": "надіслати посилку", "vtype": "chunk", "forms": {}, "examples": ["Svaki mjesec šaljem paket mami."]}, {"lemma": "primatelj", "normalized": "primatelj", "pos": "noun", "ua": "одержувач", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Upišite ime i telefon primatelja."]}, {"lemma": "pošiljatelj", "normalized": "posiljatelj", "pos": "noun", "ua": "відправник", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Pošiljatelj plaća dostavu."]}, {"lemma": "težina paketa", "normalized": "tezina paketa", "pos": "phrase", "ua": "вага посилки", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Cijena ovisi o težini paketa."]}, {"lemma": "carinska deklaracija", "normalized": "carinska deklaracija", "pos": "phrase", "ua": "митна декларація", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za Ukrajinu treba carinska deklaracija."]}, {"lemma": "sadržaj paketa", "normalized": "sadrzaj paketa", "pos": "phrase", "ua": "вміст посилки", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["U deklaraciju upišite sadržaj paketa."]}, {"lemma": "zabranjeni predmeti", "normalized": "zabranjeni predmeti", "pos": "phrase", "ua": "заборонені предмети", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Lijekovi su ponekad zabranjeni predmeti."]}, {"lemma": "broj za praćenje", "normalized": "broj za pracenje", "pos": "phrase", "ua": "номер для відстеження", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Pošaljite mami broj za praćenje."]}, {"lemma": "pratiti pošiljku", "normalized": "pratiti posiljku", "pos": "phrase", "ua": "відстежувати посилку", "vtype": "chunk", "forms": {}, "examples": ["Pošiljku možete pratiti online."]}, {"lemma": "rok dostave", "normalized": "rok dostave", "pos": "phrase", "ua": "строк доставки", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Rok dostave je pet do sedam dana."]}, {"lemma": "poslati novac", "normalized": "poslati novac", "pos": "phrase", "ua": "надіслати гроші", "vtype": "chunk", "forms": {}, "examples": ["Roditeljima šaljem novac svaki mjesec."]}, {"lemma": "prijenos novca", "normalized": "prijenos novca", "pos": "phrase", "ua": "грошовий переказ", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Prijenos novca stiže za nekoliko minuta."]}, {"lemma": "naknada za prijenos", "normalized": "naknada za prijenos", "pos": "phrase", "ua": "комісія за переказ", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Naknada za prijenos je tri eura."]}, {"lemma": "devizni tečaj", "normalized": "devizni tecaj", "pos": "phrase", "ua": "валютний курс", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Devizni tečaj se mijenja svaki dan."]}, {"lemma": "hrivnja", "normalized": "hrivnja", "pos": "noun", "ua": "гривня", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Novac stiže u hrivnjama."]}, {"lemma": "primiti novac", "normalized": "primiti novac", "pos": "phrase", "ua": "отримати гроші", "vtype": "chunk", "forms": {}, "examples": ["Mama je primila novac jučer."]}, {"lemma": "međunarodni", "normalized": "medunarodni", "pos": "adjective", "ua": "міжнародний", "vtype": "core", "forms": {}, "examples": ["Međunarodni prijenos je skuplji."]}, {"lemma": "adresa primatelja", "normalized": "adresa primatelja", "pos": "phrase", "ua": "адреса одержувача", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Adresu primatelja napišite čitko."]}, {"lemma": "aplikacija za plaćanje", "normalized": "aplikacija za placanje", "pos": "phrase", "ua": "платіжний застосунок", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Novac šaljem preko aplikacije za plaćanje."]}, {"lemma": "pouzeće", "normalized": "pouzece", "pos": "noun", "ua": "накладений платіж", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Paket plaćam pouzećem."]}, {"lemma": "dvojezična obitelj", "normalized": "dvojezicna obitelj", "pos": "phrase", "ua": "двомовна родина", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Mi smo dvojezična obitelj."]}, {"lemma": "dvojezičnost", "normalized": "dvojezicnost", "pos": "noun", "ua": "двомовність", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Dvojezičnost je prednost za djecu."]}, {"lemma": "materinji jezik", "normalized": "materinji jezik", "pos": "phrase", "ua": "рідна мова", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ukrajinski mi je materinji jezik."]}, {"lemma": "miješati jezike", "normalized": "mijesati jezike", "pos": "phrase", "ua": "змішувати мови", "vtype": "chunk", "forms": {}, "examples": ["Djeca ponekad miješaju jezike."]}, {"lemma": "zaboravljati", "normalized": "zaboravljati", "pos": "verb", "ua": "забувати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Sin polako zaboravlja ukrajinski."]}, {"lemma": "naglasak", "normalized": "naglasak", "pos": "noun", "ua": "акцент; наголос", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Kći govori hrvatski bez naglaska."]}, {"lemma": "progovoriti", "normalized": "progovoriti", "pos": "verb", "ua": "заговорити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "govoriti"}, "examples": ["Mali je progovorio na dva jezika."]}, {"lemma": "jezik okoline", "normalized": "jezik okoline", "pos": "phrase", "ua": "мова оточення", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Djeca brzo nauče jezik okoline."]}, {"lemma": "ćirilica", "normalized": "cirilica", "pos": "noun", "ua": "кирилиця", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Kći uči čitati ćirilicu."]}, {"lemma": "latinica", "normalized": "latinica", "pos": "noun", "ua": "латиниця", "vtype": "core", "forms": {"gender": "f"}, "examples": ["U školi pišu latinicom."]}, {"lemma": "obiteljsko pravilo", "normalized": "obiteljsko pravilo", "pos": "phrase", "ua": "сімейне правило", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Naše obiteljsko pravilo je: kod kuće samo ukrajinski."]}, {"lemma": "slikovnica", "normalized": "slikovnica", "pos": "noun", "ua": "дитяча книжка з малюнками", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Sinu čitam ukrajinske slikovnice."]}, {"lemma": "online škola", "normalized": "online skola", "pos": "phrase", "ua": "онлайн-школа", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Kći pohađa ukrajinsku online školu."]}, {"lemma": "dvojezični odgoj", "normalized": "dvojezicni odgoj", "pos": "phrase", "ua": "двомовне виховання", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Dvojezični odgoj traži puno strpljenja."]}, {"lemma": "prilagodba djeteta", "normalized": "prilagodba djeteta", "pos": "phrase", "ua": "адаптація дитини", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Prilagodba djeteta trajala je pola godine."]}, {"lemma": "prijatelji iz razreda", "normalized": "prijatelji iz razreda", "pos": "phrase", "ua": "однокласники (друзі з класу)", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Prijatelji iz razreda su Hrvati."]}, {"lemma": "identitet", "normalized": "identitet", "pos": "noun", "ua": "ідентичність", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Važno nam je očuvati identitet."]}, {"lemma": "korijeni", "normalized": "korijeni", "pos": "noun", "ua": "коріння", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Djeca trebaju znati svoje korijene."]}, {"lemma": "prevoditi roditeljima", "normalized": "prevoditi roditeljima", "pos": "phrase", "ua": "перекладати батькам", "vtype": "chunk", "forms": {}, "examples": ["Sin nam prevodi kod liječnika."]}, {"lemma": "ponosan na", "normalized": "ponosan na", "pos": "phrase", "ua": "гордий за", "vtype": "chunk", "forms": {}, "examples": ["Ponosna sam na kćer, govori tri jezika."]}, {"lemma": "tečno", "normalized": "tecno", "pos": "adverb", "ua": "вільно (про мову)", "vtype": "core", "forms": {}, "examples": ["Kći tečno govori hrvatski."]}, {"lemma": "usporedba", "normalized": "usporedba", "pos": "noun", "ua": "порівняння", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Usporedba nije uvijek fer."]}, {"lemma": "sličnost", "normalized": "slicnost", "pos": "noun", "ua": "схожість", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ima puno sličnosti između naših jezika."]}, {"lemma": "drukčiji", "normalized": "drukciji", "pos": "adjective", "ua": "інакший", "vtype": "core", "forms": {}, "examples": ["Ritam života ovdje je drukčiji."]}, {"lemma": "ritam života", "normalized": "ritam zivota", "pos": "phrase", "ua": "ритм життя", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ritam života na moru je sporiji."]}, {"lemma": "birokracija", "normalized": "birokracija", "pos": "noun", "ua": "бюрократія", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Birokracija je ovdje sporija nego kod nas."]}, {"lemma": "digitalne usluge", "normalized": "digitalne usluge", "pos": "phrase", "ua": "цифрові послуги", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["U Ukrajini su digitalne usluge brže."]}, {"lemma": "troškovi života", "normalized": "troskovi zivota", "pos": "phrase", "ua": "вартість життя", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Troškovi života su viši u Zagrebu nego u Kijevu."]}, {"lemma": "blaga klima", "normalized": "blaga klima", "pos": "phrase", "ua": "м’який клімат", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Blaga klima mi je velika prednost."]}, {"lemma": "godišnja doba", "normalized": "godisnja doba", "pos": "phrase", "ua": "пори року", "vtype": "chunk", "forms": {"gender": "n_pl"}, "examples": ["U Ukrajini su godišnja doba izraženija."]}, {"lemma": "srdačan", "normalized": "srdacan", "pos": "adjective", "ua": "сердечний, привітний", "vtype": "core", "forms": {}, "examples": ["Ljudi su srdačni i otvoreni."]}, {"lemma": "opušteniji", "normalized": "opusteniji", "pos": "adjective", "ua": "розслабленіший", "vtype": "core", "forms": {}, "examples": ["Hrvati su opušteniji od nas."]}, {"lemma": "marljiviji", "normalized": "marljiviji", "pos": "adjective", "ua": "працьовитіший", "vtype": "core", "forms": {}, "examples": ["Ne mislim da je itko marljiviji od drugih."]}, {"lemma": "nedostaju mi", "normalized": "nedostaju mi", "pos": "phrase", "ua": "мені бракує, я сумую за (мн.)", "vtype": "chunk", "forms": {}, "examples": ["Nedostaju mi prijatelji i ukrajinski kruh."]}, {"lemma": "naviknuti se", "normalized": "naviknuti se", "pos": "verb", "ua": "звикнути", "vtype": "core", "forms": {"aspect": "pfv", "pair": "navikavati se"}, "examples": ["Navikla sam se na fjaku."]}, {"lemma": "isti kao", "normalized": "isti kao", "pos": "phrase", "ua": "такий самий, як", "vtype": "chunk", "forms": {}, "examples": ["Boršč nije isti kao maneštra."]}, {"lemma": "za razliku od", "normalized": "za razliku od", "pos": "phrase", "ua": "на відміну від", "vtype": "chunk", "forms": {}, "examples": ["Za razliku od Kijeva, Split je malen."]}, {"lemma": "u usporedbi s", "normalized": "u usporedbi s", "pos": "phrase", "ua": "у порівнянні з", "vtype": "chunk", "forms": {}, "examples": ["U usporedbi s Ukrajinom, ovdje je više sunca."]}, {"lemma": "kad se sve zbroji", "normalized": "kad se sve zbroji", "pos": "phrase", "ua": "якщо все підсумувати", "vtype": "chunk", "forms": {}, "examples": ["Kad se sve zbroji, ovdje nam je dobro."]}, {"lemma": "druga domovina", "normalized": "druga domovina", "pos": "phrase", "ua": "друга батьківщина", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Hrvatska mi je postala druga domovina."]}, {"lemma": "jednog dana", "normalized": "jednog dana", "pos": "phrase", "ua": "одного дня, колись", "vtype": "chunk", "forms": {}, "examples": ["Jednog dana ćemo se vratiti."]}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 2. Уроки модуля A2.12
-- A2.12 · урок 72: Статус і документи: продовжуємо перебування — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6bdd7152-8541-5f3c-bf86-bc301e283140';
  v_lesson constant uuid := '5e298915-e179-5d58-bca0-6531c7b43a46';
  v_gid constant uuid := '78491f05-4871-51e6-aa8e-7f81fe2f6099';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики DAT'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A2.12: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 72: Статус і документи: продовжуємо перебування', 'Lekcija 72: Status i dokumenti: produljujemo boravak', '["Продовжити статус і документи в поліцейському управлінні", "Давальний: službeniku, djeci, mojoj obitelji"]'::jsonb, 20, 'PUBLISHED', 1);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'status privremene zaštite', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iskaznica stranca', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dozvola boravka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'produljiti boravak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stalni boravak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'raseljena osoba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'istek valjanosti iskaznice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'biometrijska fotografija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otisak prsta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odjel za strance', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naručiti termin online', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maloljetno dijete', v_pos);
  v_pos := pg_temp.word(v_lesson, 'članovi obitelji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ukrajinska putovnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'konzulat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potvrda o prebivalištu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijaviti adresu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obavijestiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rok važenja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pravo na rad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ostati u Hrvatskoj', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '7eee449a-0bb8-5537-8bb4-a1abd7f4cd40', 'fill_in_the_blank', 'Dokumente sam predala ___ na šalteru.', 'službeniku', '["službenik", "službenika", "službenikom", "službeniku"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4d1e5285-b246-52f8-9bc0-562d8088f685', 'multiple_choice', 'Що означає «produljiti boravak»?', 'продовжити перебування', '["право на роботу", "посвідка іноземця", "продовжити перебування", "закінчення строку дії посвідки"]'::jsonb, 'A2', 2, 'PUBLISHED', 'produljiti boravak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '116795a1-ff39-5e79-b259-c3a10f4aac44', 'multiple_choice', 'Що означає «obavijestiti»?', 'повідомити', '["статус тимчасового захисту", "закінчення строку дії посвідки", "повідомити", "посвідка іноземця"]'::jsonb, 'A2', 3, 'PUBLISHED', 'obavijestiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd9faee81-eec6-5ea7-ac69-dfa7e509e99f', 'multiple_choice', 'Що означає «raseljena osoba»?', 'переміщена особа', '["переміщена особа", "український паспорт", "повідомити", "відбиток пальця"]'::jsonb, 'A2', 4, 'PUBLISHED', 'raseljena osoba', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'da0e09ad-36ee-55a9-b42d-9e3ca5bc5113', 'multiple_choice', 'Що означає «odjel za strance»?', 'відділ у справах іноземців', '["члени родини", "консульство", "зареєструвати адресу", "відділ у справах іноземців"]'::jsonb, 'A2', 5, 'PUBLISHED', 'odjel za strance', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '105ac0a3-fa65-58e9-bafd-a6cfd4389ea0', 'multiple_choice', 'Що означає «pravo na rad»?', 'право на роботу', '["залишитися в Хорватії", "право на роботу", "український паспорт", "повідомити"]'::jsonb, 'A2', 6, 'PUBLISHED', 'pravo na rad', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '42a1a61f-da97-5de3-ae68-09406d707600', 'multiple_choice', 'Як хорватською «український паспорт»?', 'ukrajinska putovnica', '["biometrijska fotografija", "ukrajinska putovnica", "pravo na rad", "prijaviti adresu"]'::jsonb, 'A2', 7, 'PUBLISHED', 'ukrajinska putovnica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8537f6c2-cc1a-521d-9f95-3b7f59dc909e', 'multiple_choice', 'Як хорватською «консульство»?', 'konzulat', '["potvrda o prebivalištu", "konzulat", "odjel za strance", "ukrajinska putovnica"]'::jsonb, 'A2', 8, 'PUBLISHED', 'konzulat', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0391cbf9-32df-57fd-9f1f-70fe319ad5bf', 'type_answer', 'Напишіть хорватською: «відбиток пальця»', 'otisak prsta', null, 'A2', 9, 'PUBLISHED', 'otisak prsta', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '56e6c182-d9eb-5ea1-8d0f-bee584eca8d0', 'sentence_builder', 'Складіть: «Нову адресу треба зареєструвати.»', 'Novu adresu treba prijaviti.', '["treba", "Novu", "prijaviti.", "adresu"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '97be1a26-5205-5b18-b7f0-91a7c81452ee', 'sentence_builder', 'Складіть: «З цим статусом ви маєте право на роботу.»', 'S ovim statusom imate pravo na rad.', '["pravo", "rad.", "imate", "statusom", "S", "ovim", "na"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3cad87a4-cb60-5e70-bece-7c63eba9b171', 'listening', 'Прослухайте і складіть фразу', 'Nova se radi u konzulatu.', '["radi", "konzulatu.", "se", "u", "Nova"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'd810df1d-4392-53f7-bf91-787aec32f19a', 'listening_dialogue', 'Прослухайте оголошення', 'онлайн; 10; медична довідка', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Інформація на сайті поліцейського управління (озвучена).", "script": [{"hr": "Zahtjeve za produljenje statusa privremene zaštite primamo uz prethodnu najavu.", "ua": "Заяви на продовження статусу тимчасового захисту приймаємо за попереднім записом."}, {"hr": "Termin naručite online, a na šalter dođite deset minuta ranije.", "ua": "Запишіться онлайн, а до віконця прийдіть на десять хвилин раніше."}, {"hr": "Ponesite putovnicu, iskaznicu stranca i potvrdu o prebivalištu.", "ua": "Візьміть паспорт, посвідку іноземця й довідку про місце проживання."}], "questions": [{"q_ua": "Як записатися?", "options": ["онлайн", "по телефону", "без запису"], "correct": 0, "answer_turn": 1}, {"q_ua": "На скільки хвилин раніше прийти?", "answer_text": "10", "accept": ["десять", "10 хвилин"], "answer_turn": 1}, {"q_ua": "Що НЕ згадано серед документів?", "options": ["паспорт", "посвідка іноземця", "медична довідка"], "correct": 2, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'd810df1d-4392-53f7-bf91-787aec32f19a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dd8bbc83-a5de-5ebe-b1bf-efb39dc11ed1', 'speaking', 'Я прийшла продовжити статус.', 'Došla sam produljiti status.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3c8652b1-aac5-5390-96a9-7f6edf69783f', 'speaking', 'Дітям теж продовжуєте?', 'Djeci isto produljujete?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '54e96b07-3714-5174-ae26-d695d98ab0f3', 'write_message', 'Напишіть у відділ у справах іноземців: ви змінили адресу й питаєте, які документи принести для реєстрації.', 'Poštovani, promijenila sam adresu. Koje dokumente trebam donijeti za prijavu nove adrese?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у відділ у справах іноземців: ви змінили адресу й питаєте, які документи принести для реєстрації.", "points": [{"ua": "змінили адресу", "keys": [["adres"]]}, {"ua": "які документи", "keys": [["dokument"]]}, {"ua": "реєстрація", "keys": [["prijav"]]}], "hints": ["promijenila sam adresu", "koje dokumente trebam donijeti", "za prijavu adrese"], "models": ["Poštovani, promijenila sam adresu. Koje dokumente trebam donijeti za prijavu nove adrese?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '54e96b07-3714-5174-ae26-d695d98ab0f3', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'ab919dcb-363e-52ab-9959-29417aeae5a1', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Njegova putovnica je u konzulatu. Može li doći kasnije?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи службовцю, що мій паспорт у консульстві, і спитай, чи можна прийти пізніше.", "direction": "ua_hr", "points": [{"ua": "паспорт у консульстві", "keys": [["konzulat"]]}, {"ua": "прийти пізніше", "keys": [["kasnij"]]}], "hints": [], "models": ["Njegova putovnica je u konzulatu. Može li doći kasnije?"], "source_ua": "Скажи службовцю, що мій паспорт у консульстві, і спитай, чи можна прийти пізніше."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'ab919dcb-363e-52ab-9959-29417aeae5a1', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('349a8577-da3b-56d6-897c-a9535fb587b8', v_lesson, 'Продовження статусу', 'Produljenje statusa', 5721, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('ef31fcdb-7ac7-5ddc-bfc7-10956de62d62', '349a8577-da3b-56d6-897c-a9535fb587b8', 'Darja', 'Dobar dan, došla sam produljiti status privremene zaštite za cijelu obitelj.', 'Добрий день, я прийшла продовжити статус тимчасового захисту для всієї родини.', 1);
  perform pg_temp.turn('f44828a3-35e4-5c36-a986-ca162ea72353', '349a8577-da3b-56d6-897c-a9535fb587b8', 'Službenik', 'Jeste li naručili termin online?', 'Ви записувалися онлайн?', 2);
  perform pg_temp.turn('44b215ec-5faf-5ac2-9488-5fc98ce5a9d3', '349a8577-da3b-56d6-897c-a9535fb587b8', 'Darja', 'Jesam, za deset sati. Ovo su putovnice i iskaznice stranca.', 'Так, на десяту. Ось паспорти й посвідки іноземця.', 3);
  perform pg_temp.turn('5dffe31a-dcee-597b-902d-a68bdd8d6432', '349a8577-da3b-56d6-897c-a9535fb587b8', 'Službenik', 'Trebam i potvrdu o prebivalištu. Za maloljetnu djecu dolazi roditelj.', 'Мені потрібна ще довідка про місце проживання. За неповнолітніх дітей приходить один із батьків.', 4);
  perform pg_temp.turn('0d97363e-1014-50e6-8ee3-cbc580360b1d', '349a8577-da3b-56d6-897c-a9535fb587b8', 'Darja', 'Djeci isto produljujete?', 'Дітям теж продовжуєте?', 5);
  perform pg_temp.turn('357be7b1-c9aa-5108-afb2-3cab80010432', '349a8577-da3b-56d6-897c-a9535fb587b8', 'Službenik', 'Da, svim članovima obitelji. Nove iskaznice podižete za dva tjedna.', 'Так, усім членам родини. Нові посвідки забираєте через два тижні.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d853d368-6258-563b-90f4-35dde0a4b08c', v_lesson, 'Новий паспорт', 'Nova putovnica', 5722, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('7791a007-d6d8-50cc-a8f2-00240a16becd', 'd853d368-6258-563b-90f4-35dde0a4b08c', 'Ivan', 'Darja, tvoja ukrajinska putovnica uskoro ističe.', 'Дар’є, твій український паспорт скоро закінчується.', 1);
  perform pg_temp.turn('2e306ed9-71dd-57ac-8871-c4542b92e094', 'd853d368-6258-563b-90f4-35dde0a4b08c', 'Darja', 'Znam. Nova se radi u konzulatu. Naručila sam se za listopad.', 'Знаю. Новий роблять у консульстві, я записалася на жовтень.', 2);
  perform pg_temp.turn('061b081b-4af5-565f-88ef-bb587ab7177d', 'd853d368-6258-563b-90f4-35dde0a4b08c', 'Ivan', 'Moraš li onda obavijestiti policiju?', 'Тоді тобі треба повідомити поліцію?', 3);
  perform pg_temp.turn('caca973c-4a86-51ba-821e-c2de431716c6', 'd853d368-6258-563b-90f4-35dde0a4b08c', 'Darja', 'Moram, kad dobijem novu putovnicu. I službeniku donijeti presliku.', 'Так, коли отримаю новий паспорт. І принести копію службовцю.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.12 · урок 73: Українська громада й організації — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6bdd7152-8541-5f3c-bf86-bc301e283140';
  v_lesson constant uuid := '695e119d-c66c-5c02-9f3e-a2a161403585';
  v_gid constant uuid := '78491f05-4871-51e6-aa8e-7f81fe2f6099';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики DAT'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A2.12: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 73: Українська громада й організації', 'Lekcija 73: Ukrajinska zajednica i udruge', '["Розповісти про українську громаду, асоціації, суботню школу", "Давальний: pomagati ljudima, pridružiti se udruzi"]'::jsonb, 20, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'ukrajinska zajednica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udruga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pridružiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'članarina u udruzi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'okupljanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'subotnja škola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grkokatolička crkva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pravoslavna crkva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nacionalna manjina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Rusini', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kulturno društvo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obilježiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Dan neovisnosti Ukrajine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'druženje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'međusobna pomoć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'savjetovati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prevoditelj volonter', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Facebook grupa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'novopridošli', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osjećati se kao kod kuće', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a872e33f-73d4-5115-9007-ebbca216c673', 'fill_in_the_blank', 'Pomažemo ___ naći stan.', 'novopridošlima', '["novopridošlih", "novopridošli", "novopridošlima", "novopridošle"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4efc00b7-7abb-5c4d-96da-692796781e97', 'multiple_choice', 'Що означає «osjećati se kao kod kuće»?', 'почуватися як удома', '["почуватися як удома", "членський внесок в асоціації", "русини", "зустріч, збори"]'::jsonb, 'A2', 2, 'PUBLISHED', 'osjećati se kao kod kuće', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '07cfefe0-264b-5ca1-b3d1-3ffd1dbc63a7', 'multiple_choice', 'Що означає «nacionalna manjina»?', 'національна меншина', '["греко-католицька церква", "перекладач-волонтер", "русини", "національна меншина"]'::jsonb, 'A2', 3, 'PUBLISHED', 'nacionalna manjina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cd8fb2f4-c2cf-5964-970b-1f24ce4d09f1', 'multiple_choice', 'Що означає «subotnja škola»?', 'суботня школа', '["асоціація, громадська організація", "греко-католицька церква", "українська громада", "суботня школа"]'::jsonb, 'A2', 4, 'PUBLISHED', 'subotnja škola', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0f714070-26e9-55f9-9acc-445a9e50ac6a', 'multiple_choice', 'Як хорватською «культурне товариство»?', 'kulturno društvo', '["ukrajinska zajednica", "prevoditelj volonter", "Dan neovisnosti Ukrajine", "kulturno društvo"]'::jsonb, 'A2', 5, 'PUBLISHED', 'kulturno društvo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0f522022-97b6-52e8-93b4-aefa27cf27f2', 'multiple_choice', 'Як хорватською «приєднатися»?', 'pridružiti se', '["subotnja škola", "pridružiti se", "Rusini", "međusobna pomoć"]'::jsonb, 'A2', 6, 'PUBLISHED', 'pridružiti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b3a34c5c-c190-58c5-bc80-637c825c27b4', 'type_answer', 'Напишіть хорватською: «новоприбулі»', 'novopridošli', null, 'A2', 7, 'PUBLISHED', 'novopridošli', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e38006cd-fefe-5713-a01b-0c0bbfa6b975', 'type_answer', 'Напишіть хорватською: «спілкування, дружні зустрічі»', 'druženje', null, 'A2', 8, 'PUBLISHED', 'druženje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5500da83-c75c-542f-a34c-2a9383aeee12', 'type_answer', 'Напишіть хорватською: «відзначити»', 'obilježiti', null, 'A2', 9, 'PUBLISHED', 'obilježiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '14c758ca-0a09-5334-b22f-3bc96d083fcc', 'sentence_builder', 'Складіть: «Я приєдналася до асоціації.»', 'Pridružila sam se udruzi.', '["se", "Pridružila", "sam", "udruzi."]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f3001fc0-2484-5752-8777-1d028f480ffb', 'sentence_builder', 'Складіть: «Тут я почуваюся як удома.»', 'Ovdje se osjećam kao kod kuće.', '["kao", "osjećam", "Ovdje", "kuće.", "kod", "se"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e20d84f6-7f01-588b-9c0f-0c80e26d0184', 'listening', 'Прослухайте і складіть фразу', 'Idu u subotnju školu. Uče ukrajinski i povijest.', '["školu.", "i", "povijest.", "ukrajinski", "u", "Idu", "subotnju", "Uče"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '6fd160bd-9e18-5d24-82ec-48260722c015', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'у бібліотеці; 10; перекладачів-волонтерів', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Голова асоціації залишила вам повідомлення.", "script": [{"hr": "Bok Darja, ovdje Oksana iz udruge.", "ua": "Привіт, Дар’є, це Оксана з асоціації."}, {"hr": "U subotu u deset imamo okupljanje u knjižnici.", "ua": "У суботу о десятій у нас зустріч у бібліотеці."}, {"hr": "Trebamo prevoditelje volontere za liječnike i škole.", "ua": "Нам потрібні перекладачі-волонтери для лікарів і шкіл."}, {"hr": "Javi mi možeš li pomoći.", "ua": "Дай знати, чи можеш допомогти."}], "questions": [{"q_ua": "Де зустріч?", "options": ["у бібліотеці", "у церкві", "у школі"], "correct": 0, "answer_turn": 1}, {"q_ua": "О котрій зустріч у суботу?", "answer_text": "10", "accept": ["10:00", "10.00", "десятій"], "answer_turn": 1}, {"q_ua": "Кого шукає асоціація?", "options": ["учителів", "перекладачів-волонтерів", "водіїв"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '6fd160bd-9e18-5d24-82ec-48260722c015', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7de0d7ba-2b96-567d-84bf-8ac59a63a5c4', 'speaking', 'Діти ходять у суботню школу.', 'Djeca idu u subotnju školu.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ffc6e3ca-7e91-56bc-b34a-9ea5d13a6769', 'speaking', 'Ми допомагаємо людям з документами.', 'Pomažemo ljudima oko dokumenata.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '8cc2a0ff-200f-51bc-8f5d-14b4200d0801', 'write_message', 'Напишіть в асоціацію: ви хочете приєднатися й можете допомагати як перекладач у суботу.', 'Bok, htjela bih se pridružiti udruzi. Mogu pomagati kao prevoditeljica subotom.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть в асоціацію: ви хочете приєднатися й можете допомагати як перекладач у суботу.", "points": [{"ua": "приєднатися", "keys": [["pridruž"]]}, {"ua": "перекладач", "keys": [["prevod"]]}, {"ua": "у суботу", "keys": [["subot"]]}], "hints": ["htjela bih se pridružiti udruzi", "mogu pomagati kao prevoditeljica", "subotom"], "models": ["Bok, htjela bih se pridružiti udruzi. Mogu pomagati kao prevoditeljica subotom."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '8cc2a0ff-200f-51bc-8f5d-14b4200d0801', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'b6e6bb4b-d907-56e5-82cd-57c60ab26a65', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Njihovo kulturno društvo ima zbor i poziva sve na koncert.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи Іванові, що наше культурне товариство має хор і всіх запрошує на концерт.", "direction": "ua_hr", "points": [{"ua": "культурне товариство", "keys": [["društv"]]}, {"ua": "хор", "keys": [["zbor"]]}, {"ua": "запрошує на концерт", "keys": [["koncert"]]}], "hints": [], "models": ["Njihovo kulturno društvo ima zbor i poziva sve na koncert."], "source_ua": "Скажи Іванові, що наше культурне товариство має хор і всіх запрошує на концерт."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'b6e6bb4b-d907-56e5-82cd-57c60ab26a65', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0fa13582-42a3-547d-a18a-2bb02a6f277a', v_lesson, 'Асоціація', 'Udruga', 5731, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('77449319-b48b-533d-8792-e0785ae13fdf', '0fa13582-42a3-547d-a18a-2bb02a6f277a', 'Daša', 'Darja, jesi li čula za ukrajinsku udrugu u Rijeci?', 'Дар’є, ти чула про українську асоціацію в Рієці?', 1);
  perform pg_temp.turn('e06ec472-f138-571b-8a7b-49d045aeed6c', '0fa13582-42a3-547d-a18a-2bb02a6f277a', 'Darja', 'Jesam! Pridružila sam se prošle godine.', 'Так! Я приєдналася минулого року.', 2);
  perform pg_temp.turn('6ab14511-47d3-54f8-8b66-b6ece0033ade', '0fa13582-42a3-547d-a18a-2bb02a6f277a', 'Daša', 'Što radite?', 'Що ви робите?', 3);
  perform pg_temp.turn('e41c8765-1b35-5d30-b6c6-35b523919cc3', '0fa13582-42a3-547d-a18a-2bb02a6f277a', 'Darja', 'Pomažemo novopridošlima naći stan i savjetujemo ljude oko dokumenata.', 'Допомагаємо новоприбулим знайти житло й радимо людям щодо документів.', 4);
  perform pg_temp.turn('edfcb39e-6eef-508b-ab91-5921c1cbcb5c', '0fa13582-42a3-547d-a18a-2bb02a6f277a', 'Daša', 'A djeca?', 'А діти?', 5);
  perform pg_temp.turn('59b07203-8f22-5c81-97f2-c37d6590c717', '0fa13582-42a3-547d-a18a-2bb02a6f277a', 'Darja', 'Idu u subotnju školu. Uče ukrajinski i povijest.', 'Ходять у суботню школу. Вчать українську й історію.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e47f499c-ffdb-5965-af60-4485408432bb', v_lesson, 'День Незалежності', 'Dan neovisnosti', 5732, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('4da882ec-7360-5fad-91de-6c2d9bbd380e', 'e47f499c-ffdb-5965-af60-4485408432bb', 'Ivan', 'Što obilježavate dvadeset četvrtog kolovoza?', 'Що ви відзначаєте двадцять четвертого серпня?', 1);
  perform pg_temp.turn('ef5da0ac-64ce-54b5-b03d-85439a437e13', 'e47f499c-ffdb-5965-af60-4485408432bb', 'Darja', 'Dan neovisnosti Ukrajine. Kulturno društvo organizira koncert.', 'День Незалежності України. Культурне товариство організовує концерт.', 2);
  perform pg_temp.turn('3d575d34-bb1e-51d1-a085-156c5a9749d0', 'e47f499c-ffdb-5965-af60-4485408432bb', 'Ivan', 'Mogu li i ja doći?', 'Можна й мені прийти?', 3);
  perform pg_temp.turn('068486a2-4844-5465-89a0-36da2441364e', 'e47f499c-ffdb-5965-af60-4485408432bb', 'Darja', 'Naravno! Druženje je otvoreno svima.', 'Звісно! Зустріч відкрита для всіх.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.12 · урок 74: Волонтерство й допомога — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6bdd7152-8541-5f3c-bf86-bc301e283140';
  v_lesson constant uuid := '55fdd530-ac46-5ba9-a5de-9fd5944b0c8c';
  v_gid constant uuid := '78491f05-4871-51e6-aa8e-7f81fe2f6099';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики DAT'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A2.12: місце 3 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 74: Волонтерство й допомога', 'Lekcija 74: Volontiranje i pomoć', '["Розповісти про волонтерство й гуманітарну допомогу", "Давальний: donirati djeci, pomoći starijima, zahvaliti volonterima"]'::jsonb, 20, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'volontiranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'volonterka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'humanitarna pomoć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'humanitarna akcija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'donacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'donirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prikupljanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prikupiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dugotrajna hrana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'higijenske potrepštine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'generator', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sabirno mjesto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pakirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pomagati starijima', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dom za starije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pučka kuhinja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zahvaliti volonterima', v_pos);
  v_pos := pg_temp.word(v_lesson, 'solidarnost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dirnuti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vratiti dobrotu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobrotvorni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neprofitni', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2b83bd69-b83a-56a6-8730-e839200c83d7', 'fill_in_the_blank', 'Susjedi su donirali ___ odjeću i igračke.', 'djeci', '["djeci", "djeca", "djecom", "djecu"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b620da27-c23d-5ea7-a935-f9e0bd597d63', 'multiple_choice', 'Що означає «humanitarna akcija»?', 'благодійна акція', '["неприбутковий", "благодійна акція", "збір (допомоги)", "зворушити"]'::jsonb, 'A2', 2, 'PUBLISHED', 'humanitarna akcija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fafaabb3-9aed-51ac-a25c-d99fb930afa8', 'multiple_choice', 'Що означає «higijenske potrepštine»?', 'засоби гігієни', '["волонтерка", "солідарність", "засоби гігієни", "соціальна їдальня"]'::jsonb, 'A2', 3, 'PUBLISHED', 'higijenske potrepštine', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ac42e95b-62be-5997-a896-dce2aa1aff93', 'multiple_choice', 'Що означає «pomagati starijima»?', 'допомагати літнім людям', '["зібрати", "пакувати", "допомагати літнім людям", "пожертвувати, подарувати"]'::jsonb, 'A2', 4, 'PUBLISHED', 'pomagati starijima', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ba80adfc-96c5-56d7-8d46-ec7c8008cd14', 'multiple_choice', 'Як хорватською «віддячити добром»?', 'vratiti dobrotu', '["pakirati", "volontiranje", "solidarnost", "vratiti dobrotu"]'::jsonb, 'A2', 5, 'PUBLISHED', 'vratiti dobrotu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4d35842f-ae2e-58fa-9235-56d744c9113c', 'multiple_choice', 'Як хорватською «їжа тривалого зберігання»?', 'dugotrajna hrana', '["pomagati starijima", "pakirati", "dugotrajna hrana", "dirnuti"]'::jsonb, 'A2', 6, 'PUBLISHED', 'dugotrajna hrana', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '161834c6-51d9-55f7-a8a9-80c48016560c', 'type_answer', 'Напишіть хорватською: «пожертва»', 'donacija', null, 'A2', 7, 'PUBLISHED', 'donacija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '52341836-b97d-51fa-bf11-d103a64eb2c9', 'type_answer', 'Напишіть хорватською: «неприбутковий»', 'neprofitni', null, 'A2', 8, 'PUBLISHED', 'neprofitni', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a8d9d8f8-be1b-5096-a515-a430b13aca6a', 'type_answer', 'Напишіть хорватською: «волонтерка»', 'volonterka', null, 'A2', 9, 'PUBLISHED', 'volonterka', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '31ce26b3-7597-5742-9ba2-51517e4c29dc', 'sentence_builder', 'Складіть: «Ми зібрали дві тонни їжі.»', 'Prikupili smo dvije tone hrane.', '["smo", "hrane.", "Prikupili", "dvije", "tone"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '01d685e5-a4ae-59bb-b71d-2fafbdc0707d', 'sentence_builder', 'Складіть: «Я волонтерю в будинку для літніх людей.»', 'Volontiram u domu za starije.', '["u", "Volontiram", "domu", "starije.", "za"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '65a4d522-301f-53b6-93aa-0a547767bfc5', 'listening', 'Прослухайте і складіть фразу', 'U dvorani škole. Trebamo dugotrajnu hranu i higijenske potrepštine.', '["U", "dugotrajnu", "hranu", "škole.", "i", "higijenske", "potrepštine.", "Trebamo", "dvorani"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '0e6ccf08-eae6-5cfb-9ae2-43d01568f7fe', 'listening_dialogue', 'Прослухайте оголошення', 'шкільне приладдя й теплі куртки; у шкільну залу; 15', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Оголошення про благодійну акцію в школі.", "script": [{"hr": "Dragi roditelji, naša škola organizira humanitarnu akciju.", "ua": "Дорогі батьки, наша школа організовує благодійну акцію."}, {"hr": "Prikupljamo školski pribor i tople jakne za djecu u Ukrajini.", "ua": "Збираємо шкільне приладдя й теплі куртки для дітей в Україні."}, {"hr": "Donacije donesite u školsku dvoranu do petnaestog studenog.", "ua": "Пожертви приносьте до шкільної зали до п’ятнадцятого листопада."}], "questions": [{"q_ua": "Що збирають?", "options": ["шкільне приладдя й теплі куртки", "їжу й воду", "гроші"], "correct": 0, "answer_turn": 1}, {"q_ua": "Куди приносити?", "options": ["у бібліотеку", "у шкільну залу", "у церкву"], "correct": 1, "answer_turn": 2}, {"q_ua": "До котрого числа листопада?", "answer_text": "15", "accept": ["п’ятнадцятого", "15."], "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '0e6ccf08-eae6-5cfb-9ae2-43d01568f7fe', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ec05aae5-7884-5119-9ecd-45b495c98baf', 'speaking', 'Де пункт збору?', 'Gdje je sabirno mjesto?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8eae4ec5-d803-55e0-a452-3843fde4d2e4', 'speaking', 'Я хочу віддячити добром.', 'Želim vratiti dobrotu.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'bab2b62c-cd08-563e-a70a-8f5b62c3cd43', 'write_message', 'Напишіть сусідам у групу будинку: у суботу збір допомоги в школі, потрібні їжа тривалого зберігання й засоби гігієни.', 'Dragi susjedi, u subotu je u školi prikupljanje pomoći. Trebamo dugotrajnu hranu i higijenske potrepštine.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть сусідам у групу будинку: у суботу збір допомоги в школі, потрібні їжа тривалого зберігання й засоби гігієни.", "points": [{"ua": "збір допомоги", "keys": [["prikuplj"], ["pomoć"]]}, {"ua": "у суботу в школі", "keys": [["subot"], ["škol"]]}, {"ua": "їжа", "keys": [["hran"]]}, {"ua": "засоби гігієни", "keys": [["higijensk"]]}], "hints": ["u subotu je prikupljanje pomoći", "u školi", "dugotrajna hrana", "higijenske potrepštine"], "models": ["Dragi susjedi, u subotu je u školi prikupljanje pomoći. Trebamo dugotrajnu hranu i higijenske potrepštine."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'bab2b62c-cd08-563e-a70a-8f5b62c3cd43', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '39f951e9-597d-56fe-af55-e6864c32b277', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Jako je zahvalna Hrvatima na solidarnosti.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи журналістці, що я дуже вдячна хорватам за солідарність.", "direction": "ua_hr", "points": [{"ua": "вдячна", "keys": [["zahvaln"], ["hval"]]}, {"ua": "хорватам", "keys": [["hrvat"]]}, {"ua": "солідарність", "keys": [["solidarnost"]]}], "hints": [], "models": ["Jako je zahvalna Hrvatima na solidarnosti."], "source_ua": "Скажи журналістці, що я дуже вдячна хорватам за солідарність."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '39f951e9-597d-56fe-af55-e6864c32b277', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5cbe41fd-394e-5799-94e1-9ffe2627dda3', v_lesson, 'Пункт збору', 'Sabirno mjesto', 5741, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('74291c39-1f58-5047-9bd0-733e4862a0c5', '5cbe41fd-394e-5799-94e1-9ffe2627dda3', 'Daša', 'Ivane, u subotu je prikupljanje humanitarne pomoći. Možeš li pomoći?', 'Іване, у суботу збір гуманітарної допомоги. Можеш допомогти?', 1);
  perform pg_temp.turn('90240fd4-8105-5758-89d5-d19728c2a1ce', '5cbe41fd-394e-5799-94e1-9ffe2627dda3', 'Ivan', 'Mogu. Gdje je sabirno mjesto?', 'Можу. Де пункт збору?', 2);
  perform pg_temp.turn('49ff181b-0c6e-5e0b-b8af-40f2d7e58101', '5cbe41fd-394e-5799-94e1-9ffe2627dda3', 'Daša', 'U dvorani škole. Trebamo dugotrajnu hranu i higijenske potrepštine.', 'У шкільній залі. Нам потрібна їжа тривалого зберігання й засоби гігієни.', 3);
  perform pg_temp.turn('abe076ff-4cdb-5165-b43c-44eb68df2796', '5cbe41fd-394e-5799-94e1-9ffe2627dda3', 'Ivan', 'Donijet ću i nešto za djecu.', 'Я принесу й щось для дітей.', 4);
  perform pg_temp.turn('cad2ea36-331d-5b18-b813-afdaf6f6b0ee', '5cbe41fd-394e-5799-94e1-9ffe2627dda3', 'Daša', 'Hvala! Volonteri pakiraju kutije od devet.', 'Дякую! Волонтери пакують коробки з дев’ятої.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e1464610-4de1-54b2-bc69-512bc44e558d', v_lesson, 'Чому я волонтерю', 'Zašto volontiram', 5742, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('b02c3f1f-d8cd-5fdd-a04b-810fcaa1690c', 'e1464610-4de1-54b2-bc69-512bc44e558d', 'Novinarka', 'Darja, zašto volontirate u pučkoj kuhinji?', 'Дар’є, чому ви волонтерите в соціальній їдальні?', 1);
  perform pg_temp.turn('674b8d27-0f7f-51d4-8693-00e1633963d2', 'e1464610-4de1-54b2-bc69-512bc44e558d', 'Darja', 'Kad smo došli, ljudi su nam puno pomogli. Želim vratiti dobrotu.', 'Коли ми приїхали, люди нам дуже допомогли. Хочу віддячити добром.', 2);
  perform pg_temp.turn('6addd543-464b-5d5e-8a6f-75a819a501d9', 'e1464610-4de1-54b2-bc69-512bc44e558d', 'Novinarka', 'Što vas je najviše dirnulo?', 'Що вас найбільше зворушило?', 3);
  perform pg_temp.turn('526c7bca-24c3-5a43-929b-350e5638d01f', 'e1464610-4de1-54b2-bc69-512bc44e558d', 'Darja', 'Solidarnost. Susjedi su donirali djeci odjeću i igračke.', 'Солідарність. Сусіди подарували дітям одяг та іграшки.', 4);
  perform pg_temp.turn('770df08e-1165-5120-b639-0eefe9034f9a', 'e1464610-4de1-54b2-bc69-512bc44e558d', 'Novinarka', 'Hvala Vam i svim volonterima.', 'Дякуємо вам і всім волонтерам.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.12 · урок 75: Посилки й перекази в Україну — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6bdd7152-8541-5f3c-bf86-bc301e283140';
  v_lesson constant uuid := 'bc5bde26-5065-560b-8877-1302e7048471';
  v_gid constant uuid := '78491f05-4871-51e6-aa8e-7f81fe2f6099';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики DAT'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A2.12: місце 4 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 75: Посилки й перекази в Україну', 'Lekcija 75: Paketi i novac u Ukrajinu', '["Надіслати посилку й гроші в Україну", "Давальний: poslati mami, platiti kuriru, objasniti službenici"]'::jsonb, 20, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kurirska služba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poslati paket', v_pos);
  v_pos := pg_temp.word(v_lesson, 'primatelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pošiljatelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'težina paketa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'carinska deklaracija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sadržaj paketa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zabranjeni predmeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'broj za praćenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pratiti pošiljku', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rok dostave', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poslati novac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijenos novca', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naknada za prijenos', v_pos);
  v_pos := pg_temp.word(v_lesson, 'devizni tečaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hrivnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'primiti novac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'međunarodni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'adresa primatelja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'aplikacija za plaćanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pouzeće', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '4ddf11dd-a30e-5b5e-ae21-b845bfbb8312', 'fill_in_the_blank', 'Svaki mjesec šaljem paket ___.', 'mami', '["mama", "mami", "mamu", "mamom"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '92c573eb-6007-527a-a59d-a58e5ca3b2b5', 'multiple_choice', 'Що означає «adresa primatelja»?', 'адреса одержувача', '["номер для відстеження", "вага посилки", "надіслати гроші", "адреса одержувача"]'::jsonb, 'A2', 2, 'PUBLISHED', 'adresa primatelja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f9fcefb8-7153-5d14-a36f-039138fef2c9', 'multiple_choice', 'Що означає «pratiti pošiljku»?', 'відстежувати посилку', '["отримати гроші", "одержувач", "митна декларація", "відстежувати посилку"]'::jsonb, 'A2', 3, 'PUBLISHED', 'pratiti pošiljku', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1eb6a62e-0e97-5fc0-a233-f57d9ed97f51', 'multiple_choice', 'Що означає «poslati novac»?', 'надіслати гроші', '["відправник", "кур’єрська служба", "надіслати гроші", "строк доставки"]'::jsonb, 'A2', 4, 'PUBLISHED', 'poslati novac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '00de12ae-9b7d-555c-9a5e-83cc47dec198', 'multiple_choice', 'Що означає «težina paketa»?', 'вага посилки', '["надіслати посилку", "відправник", "номер для відстеження", "вага посилки"]'::jsonb, 'A2', 5, 'PUBLISHED', 'težina paketa', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2d8bc5b5-83d2-5ba2-9fea-83befd217e7f', 'multiple_choice', 'Як хорватською «гривня»?', 'hrivnja', '["primiti novac", "pouzeće", "hrivnja", "devizni tečaj"]'::jsonb, 'A2', 6, 'PUBLISHED', 'hrivnja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b3d2c968-80ae-5de3-860d-373a72a41b56', 'multiple_choice', 'Як хорватською «міжнародний»?', 'međunarodni', '["međunarodni", "hrivnja", "prijenos novca", "rok dostave"]'::jsonb, 'A2', 7, 'PUBLISHED', 'međunarodni', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '010cda70-991a-5b91-a7c5-43ec722f5e99', 'type_answer', 'Напишіть хорватською: «відправник»', 'pošiljatelj', null, 'A2', 8, 'PUBLISHED', 'pošiljatelj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a0a3196b-4f48-50a8-bfed-85fff76e2d77', 'type_answer', 'Напишіть хорватською: «одержувач»', 'primatelj', null, 'A2', 9, 'PUBLISHED', 'primatelj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8740bb6f-53f6-53b6-8ac2-eeec9dcba1d5', 'sentence_builder', 'Складіть: «Ціна залежить від ваги посилки.»', 'Cijena ovisi o težini paketa.', '["težini", "Cijena", "paketa.", "ovisi", "o"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6125cd31-6b13-55ad-8738-e8a37cc5554b', 'sentence_builder', 'Складіть: «Мама отримала гроші вчора.»', 'Mama je primila novac jučer.', '["novac", "je", "primila", "jučer.", "Mama"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd5ae4af9-aa84-57bd-9b9c-a7d2dc5bb95e', 'listening', 'Прослухайте і складіть фразу', 'Novac stiže za nekoliko minuta.', '["stiže", "nekoliko", "Novac", "za", "minuta."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '28bf9120-9221-525f-8c9d-1b7e7e5083cb', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'до Львова; 34; завтра між 9 і 12', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Кур’єрська служба залишила вам повідомлення.", "script": [{"hr": "Dobar dan, ovdje kurirska služba.", "ua": "Добрий день, це кур’єрська служба."}, {"hr": "Vaš paket za Lavov je težak dvanaest kilograma.", "ua": "Ваша посилка до Львова важить дванадцять кілограмів."}, {"hr": "Cijena dostave je trideset četiri eura.", "ua": "Вартість доставки — тридцять чотири євро."}, {"hr": "Kurir dolazi po paket sutra između devet i dvanaest.", "ua": "Кур’єр приїде по посилку завтра між дев’ятою і дванадцятою."}], "questions": [{"q_ua": "Куди посилка?", "options": ["до Львова", "до Києва", "до Одеси"], "correct": 0, "answer_turn": 1}, {"q_ua": "Скільки коштує доставка (євро)?", "answer_text": "34", "accept": ["тридцять чотири", "34 євро"], "answer_turn": 2}, {"q_ua": "Коли приїде кур’єр?", "options": ["сьогодні ввечері", "завтра між 9 і 12", "у понеділок"], "correct": 1, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '28bf9120-9221-525f-8c9d-1b7e7e5083cb', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'daaccad3-4e9e-553d-b107-b8683f2d4f6e', 'speaking', 'Я хотіла б надіслати посилку в Україну.', 'Htjela bih poslati paket u Ukrajinu.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd9a5b21e-dd12-5cd9-a79f-c66266c3a72b', 'speaking', 'Скільки триває доставка?', 'Koliko traje dostava?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '6422a28f-556f-5152-b834-f028efcfeca5', 'write_message', 'Напишіть мамі: ви надіслали посилку кур’єром, вона прийде за тиждень, номер для відстеження — у повідомленні.', 'Mama, poslala sam ti paket kurirom. Stiže za tjedan dana. Broj za praćenje je u poruci.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть мамі: ви надіслали посилку кур’єром, вона прийде за тиждень, номер для відстеження — у повідомленні.", "points": [{"ua": "надіслали посилку", "keys": [["paket"]]}, {"ua": "за тиждень", "keys": [["tjed"]]}, {"ua": "номер для відстеження", "keys": [["prać"]]}], "hints": ["poslala sam ti paket", "stiže za tjedan dana", "broj za praćenje"], "models": ["Mama, poslala sam ti paket kurirom. Stiže za tjedan dana. Broj za praćenje je u poruci."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '6422a28f-556f-5152-b834-f028efcfeca5', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '2345b51e-2ad9-59d5-aacc-c5daf0b1b7bb', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Koliko košta prijenos novca u Ukrajinu i kada novac stiže?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай у касі, скільки коштує переказ до України і за скільки гроші прийдуть.", "direction": "ua_hr", "points": [{"ua": "скільки коштує переказ", "keys": [["naknad"], ["košt"]]}, {"ua": "до України", "keys": [["ukrajin"]]}, {"ua": "за скільки прийдуть", "keys": [["stiž"], ["kad"]]}], "hints": [], "models": ["Koliko košta prijenos novca u Ukrajinu i kada novac stiže?"], "source_ua": "Спитай у касі, скільки коштує переказ до України і за скільки гроші прийдуть."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '2345b51e-2ad9-59d5-aacc-c5daf0b1b7bb', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('24206769-8574-5525-b2ef-a8e2e29dbcb5', v_lesson, 'Посилка мамі', 'Paket mami', 5751, 'A2', 'bank', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('0769ccc1-d89e-5bbc-b3ee-0fdad3ad0171', '24206769-8574-5525-b2ef-a8e2e29dbcb5', 'Darja', 'Dobar dan, htjela bih poslati paket mami u Ukrajinu.', 'Добрий день, я хотіла б надіслати посилку мамі в Україну.', 1);
  perform pg_temp.turn('b3ed1747-c025-54e2-8557-66abf4b14136', '24206769-8574-5525-b2ef-a8e2e29dbcb5', 'Službenica', 'Što je u paketu? Trebate ispuniti carinsku deklaraciju.', 'Що в посилці? Вам треба заповнити митну декларацію.', 2);
  perform pg_temp.turn('cf01a22e-f588-5eb9-922d-9cd3cca9d003', '24206769-8574-5525-b2ef-a8e2e29dbcb5', 'Darja', 'Odjeća, kava i čokolada. Smijem li poslati lijekove?', 'Одяг, кава й шоколад. Чи можна надіслати ліки?', 3);
  perform pg_temp.turn('8645178e-53aa-5c49-9abd-83773b250af2', '24206769-8574-5525-b2ef-a8e2e29dbcb5', 'Službenica', 'Neke lijekove ne smijete, to su zabranjeni predmeti.', 'Деякі ліки не можна, це заборонені предмети.', 4);
  perform pg_temp.turn('5b647d7a-387c-549a-9f7e-97a5856052f1', '24206769-8574-5525-b2ef-a8e2e29dbcb5', 'Darja', 'Koliko traje dostava?', 'Скільки триває доставка?', 5);
  perform pg_temp.turn('87d71b37-773a-52de-b6f2-a0c198b05486', '24206769-8574-5525-b2ef-a8e2e29dbcb5', 'Službenica', 'Pet do sedam dana. Mami pošaljite broj za praćenje.', 'Від п’яти до семи днів. Надішліть мамі номер для відстеження.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ebb9c4b4-84f1-5b71-8fd4-9624d0a68027', v_lesson, 'Переказ', 'Prijenos novca', 5752, 'A2', 'bank', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('63569b2e-ce76-52d1-9241-99eece4d34f6', 'ebb9c4b4-84f1-5b71-8fd4-9624d0a68027', 'Ivan', 'Kako šalješ novac roditeljima?', 'Як ти надсилаєш гроші батькам?', 1);
  perform pg_temp.turn('1b1e9f9f-dacc-5b38-b195-4c98ca30c8b0', 'ebb9c4b4-84f1-5b71-8fd4-9624d0a68027', 'Darja', 'Preko aplikacije za plaćanje. Novac stiže za nekoliko minuta.', 'Через платіжний застосунок. Гроші надходять за кілька хвилин.', 2);
  perform pg_temp.turn('ede69b25-5c83-5cf7-8095-5691c37f1d34', 'ebb9c4b4-84f1-5b71-8fd4-9624d0a68027', 'Ivan', 'A naknada za prijenos?', 'А комісія за переказ?', 3);
  perform pg_temp.turn('5ccfad2c-8273-54e6-98c8-da026349534d', 'ebb9c4b4-84f1-5b71-8fd4-9624d0a68027', 'Darja', 'Mala, ali pazim na devizni tečaj. Roditelji primaju hrivnje.', 'Невелика, але я стежу за валютним курсом. Батьки отримують гривні.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.12 · урок 76: Двомовна родина: діти й рідна мова — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6bdd7152-8541-5f3c-bf86-bc301e283140';
  v_lesson constant uuid := '56d06c34-2631-5ca9-a3a3-b0df910556dc';
  v_gid constant uuid := '78491f05-4871-51e6-aa8e-7f81fe2f6099';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики DAT'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A2.12: місце 5 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 76: Двомовна родина: діти й рідна мова', 'Lekcija 76: Dvojezična obitelj: djeca i materinski jezik', '["Поговорити про дві мови в родині й навчання дітей", "Давальний: govorim djeci ukrajinski, čitam sinu, kćeri je lakše"]'::jsonb, 20, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'dvojezična obitelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dvojezičnost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'materinji jezik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'miješati jezike', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaboravljati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naglasak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'progovoriti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jezik okoline', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ćirilica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'latinica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obiteljsko pravilo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slikovnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'online škola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dvojezični odgoj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prilagodba djeteta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijatelji iz razreda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'identitet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'korijeni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prevoditi roditeljima', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponosan na', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tečno', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '518538f8-496e-5851-a964-0f17fec72624', 'fill_in_the_blank', 'Svake večeri čitam ___ priču na ukrajinskom.', 'sinu', '["sina", "sin", "sinom", "sinu"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '82ee6111-55eb-5fdb-a42a-746cee52ab79', 'multiple_choice', 'Що означає «dvojezična obitelj»?', 'двомовна родина', '["сімейне правило", "рідна мова", "заговорити", "двомовна родина"]'::jsonb, 'A2', 2, 'PUBLISHED', 'dvojezična obitelj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '70cf4d01-4292-5511-a12e-4a44e6207980', 'multiple_choice', 'Що означає «materinji jezik»?', 'рідна мова', '["наголос; акцент", "рідна мова", "мова оточення", "вільно (про мову)"]'::jsonb, 'A2', 3, 'PUBLISHED', 'materinji jezik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bac10f7b-34a7-5828-b362-02d53074fc5e', 'multiple_choice', 'Що означає «prilagodba djeteta»?', 'адаптація дитини', '["адаптація дитини", "сімейне правило", "змішувати мови", "онлайн-школа"]'::jsonb, 'A2', 4, 'PUBLISHED', 'prilagodba djeteta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd3c8ff2-8795-584d-963c-ea8eba349950', 'multiple_choice', 'Як хорватською «забувати»?', 'zaboravljati', '["zaboravljati", "naglasak", "obiteljsko pravilo", "ćirilica"]'::jsonb, 'A2', 5, 'PUBLISHED', 'zaboravljati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1e2c25ce-fb0f-5053-b7be-e6fd690efceb', 'multiple_choice', 'Як хорватською «сімейне правило»?', 'obiteljsko pravilo', '["ponosan na", "obiteljsko pravilo", "dvojezičnost", "dvojezični odgoj"]'::jsonb, 'A2', 6, 'PUBLISHED', 'obiteljsko pravilo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b61d22c1-12d2-5852-9c85-57e6026187ed', 'type_answer', 'Напишіть хорватською: «заговорити»', 'progovoriti', null, 'A2', 7, 'PUBLISHED', 'progovoriti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6432e114-d1d4-51c8-964b-a4f9d88b4bf5', 'type_answer', 'Напишіть хорватською: «вільно (про мову)»', 'tečno', null, 'A2', 8, 'PUBLISHED', 'tečno', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a538d286-3973-5e3e-a951-f06d9937d036', 'type_answer', 'Напишіть хорватською: «двомовність»', 'dvojezičnost', null, 'A2', 9, 'PUBLISHED', 'dvojezičnost', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '62d25fff-9fed-544d-b213-08fc63947b3e', 'sentence_builder', 'Складіть: «Діти іноді змішують мови.»', 'Djeca ponekad miješaju jezike.', '["jezike.", "Djeca", "miješaju", "ponekad"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9ac72e73-c5c7-575a-ae83-2a0d320a9a8b', 'sentence_builder', 'Складіть: «Українська — моя рідна мова.»', 'Ukrajinski mi je materinji jezik.', '["je", "Ukrajinski", "mi", "jezik.", "materinji"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a8443dfa-313e-5b07-8234-95504c10de20', 'listening', 'Прослухайте і складіть фразу', 'Ponekad. Sin polako zaboravlja ukrajinski, zato mu čitam svake večeri.', '["polako", "mu", "zaboravlja", "Ponekad.", "svake", "zato", "ukrajinski,", "večeri.", "Sin", "čitam"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '4c5d1d2f-211f-5194-9389-322e8e408e1f', 'listening_dialogue', 'Прослухайте розмову', 'майже без акценту; що він забуває українську; перевага', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Дар’я говорить з учителькою про двомовність сина.", "script": [{"speaker": "Učiteljica", "hr": "Filip odlično napreduje, govori hrvatski skoro bez naglaska.", "ua": "Філіп чудово робить успіхи, говорить хорватською майже без акценту."}, {"speaker": "Darja", "hr": "Bojim se da zaboravlja ukrajinski.", "ua": "Я боюся, що він забуває українську."}, {"speaker": "Učiteljica", "hr": "Govorite mu kod kuće ukrajinski. Dvojezičnost je velika prednost.", "ua": "Говоріть з ним удома українською. Двомовність — велика перевага."}], "questions": [{"q_ua": "Як Філіп говорить хорватською?", "options": ["майже без акценту", "з сильним акцентом", "ще не говорить"], "correct": 0, "answer_turn": 0}, {"q_ua": "Чого боїться Дар’я?", "options": ["що він погано вчиться", "що він забуває українську", "що в нього немає друзів"], "correct": 1, "answer_turn": 1}, {"q_ua": "Що, за словами вчительки, двомовність?", "answer_text": "перевага", "accept": ["велика перевага", "prednost", "плюс"], "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '4c5d1d2f-211f-5194-9389-322e8e408e1f', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '741cd40c-1e69-5b92-80f1-4a488e48c36e', 'speaking', 'Удома ми говоримо українською.', 'Kod kuće govorimo ukrajinski.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4d641c8d-10f5-59d8-9400-a1a58ea736c0', 'speaking', 'Я пишаюся донькою.', 'Ponosna sam na kćer.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '9fe561f1-2673-52c3-873d-f0b16e9d202e', 'write_message', 'Напишіть подрузі, як у вашій родині з мовами: удома українська, у школі хорватська, і чи змішують діти мови.', 'Kod kuće govorimo ukrajinski, a u školi djeca govore hrvatski. Ponekad miješaju jezike, ali brzo uče.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі, як у вашій родині з мовами: удома українська, у школі хорватська, і чи змішують діти мови.", "points": [{"ua": "удома українська", "keys": [["ukrajinsk"]]}, {"ua": "у школі хорватська", "keys": [["hrvatsk"]]}, {"ua": "змішують мови", "keys": [["miješa"]]}], "hints": ["kod kuće govorimo ukrajinski", "u školi hrvatski", "djeca ponekad miješaju jezike"], "models": ["Kod kuće govorimo ukrajinski, a u školi djeca govore hrvatski. Ponekad miješaju jezike, ali brzo uče."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '9fe561f1-2673-52c3-873d-f0b16e9d202e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '34b7a720-5d68-5285-83ea-d484e99050c3', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Njezin sin ide i u ukrajinsku online školu i teško mu je.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи вчительці, що мій син ходить ще й в українську онлайн-школу і йому важко.", "direction": "ua_hr", "points": [{"ua": "онлайн-школа", "keys": [["online"]]}, {"ua": "українська", "keys": [["ukrajinsk"]]}, {"ua": "йому важко", "keys": [["teško"]]}], "hints": [], "models": ["Njezin sin ide i u ukrajinsku online školu i teško mu je."], "source_ua": "Скажи вчительці, що мій син ходить ще й в українську онлайн-школу і йому важко."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '34b7a720-5d68-5285-83ea-d484e99050c3', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0148e3ee-d789-5139-a6ff-97df233eab26', v_lesson, 'Дві мови', 'Dva jezika', 5761, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('865c8b01-191e-52fd-8dd0-501862c5e888', '0148e3ee-d789-5139-a6ff-97df233eab26', 'Ivana', 'Darja, na kojem jeziku govoriš djeci?', 'Дар’є, якою мовою ти говориш з дітьми?', 1);
  perform pg_temp.turn('85af3a67-2bdc-5b2f-8b49-9d6e9525e330', '0148e3ee-d789-5139-a6ff-97df233eab26', 'Darja', 'Kod kuće ukrajinski, vani hrvatski. To je naše pravilo.', 'Удома українською, надворі хорватською. Це наше правило.', 2);
  perform pg_temp.turn('c1e57140-037d-5ba7-9521-1611dab14858', '0148e3ee-d789-5139-a6ff-97df233eab26', 'Ivana', 'Miješaju li jezike?', 'Вони змішують мови?', 3);
  perform pg_temp.turn('d1c28d59-e44c-5f87-9926-5c995fc868cb', '0148e3ee-d789-5139-a6ff-97df233eab26', 'Darja', 'Ponekad. Sin polako zaboravlja ukrajinski, zato mu čitam svake večeri.', 'Іноді. Син потроху забуває українську, тому я читаю йому щовечора.', 4);
  perform pg_temp.turn('ff27ff36-e4da-511e-81a0-4bd454bde9a0', '0148e3ee-d789-5139-a6ff-97df233eab26', 'Ivana', 'A kći?', 'А донька?', 5);
  perform pg_temp.turn('d095b7f0-e7e9-56fb-95d5-c461c113564c', '0148e3ee-d789-5139-a6ff-97df233eab26', 'Darja', 'Kćeri je lakše. Govori hrvatski bez naglaska i uči ćirilicu.', 'Доньці легше. Вона говорить хорватською без акценту і вчить кирилицю.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('61382e6d-9f75-54f2-b62d-b32f8a46a426', v_lesson, 'Син-перекладач', 'Sin prevoditelj', 5762, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('7f2829b8-b9d4-50c5-aaa1-be057a667abe', '61382e6d-9f75-54f2-b62d-b32f8a46a426', 'Marko', 'Kako je Filip u školi?', 'Як Філіп у школі?', 1);
  perform pg_temp.turn('e73243d5-88c4-51df-9cbc-a78b13a4b448', '61382e6d-9f75-54f2-b62d-b32f8a46a426', 'Darja', 'Dobro, prijatelji iz razreda su mu Hrvati. Čak nam prevodi kod liječnika.', 'Добре, його друзі з класу — хорвати. Він навіть перекладає нам у лікаря.', 2);
  perform pg_temp.turn('adde94b7-ac7a-5395-9983-b07f1192a65c', '61382e6d-9f75-54f2-b62d-b32f8a46a426', 'Marko', 'Bravo! Ide li i u ukrajinsku školu?', 'Молодець! Він ходить ще й в українську школу?', 3);
  perform pg_temp.turn('7901cdd3-b2fc-5ef9-a889-0579204e9df1', '61382e6d-9f75-54f2-b62d-b32f8a46a426', 'Darja', 'U online školu. Teško je s dvije škole, ali važni su nam korijeni.', 'В онлайн-школу. Важко з двома школами, але нам важливе коріння.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.12 · урок 77: Хорватія й Україна: порівнюємо — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '6bdd7152-8541-5f3c-bf86-bc301e283140';
  v_lesson constant uuid := '0465a2cd-1da9-5a6e-a47d-434fc8bee342';
  v_gid constant uuid := '926638d7-1396-512e-8a05-065c4464b85a';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики POR'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A2.12: місце 6 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 77: Хорватія й Україна: порівнюємо', 'Lekcija 77: Hrvatska i Ukrajina: usporedba', '["Порівняти життя в Хорватії й Україні: ціни, ритм, природа, люди", "Порівняльні конструкції: skuplji nego, isti kao, sve više"]'::jsonb, 20, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'usporedba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sličnost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'drukčiji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ritam života', v_pos);
  v_pos := pg_temp.word(v_lesson, 'birokracija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'digitalne usluge', v_pos);
  v_pos := pg_temp.word(v_lesson, 'troškovi života', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blaga klima', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godišnja doba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srdačan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opušteniji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'marljiviji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nedostaju mi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naviknuti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'isti kao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'za razliku od', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u usporedbi s', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kad se sve zbroji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'druga domovina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jednog dana', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '458275cd-f3b4-5431-a4b9-dcedac85055c', 'fill_in_the_blank', 'Stanovi su ovdje skuplji ___ u Kijevu.', 'nego', '["nego", "kao", "od", "isti"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bed83f82-62f4-5610-a460-d1e97f728e09', 'multiple_choice', 'Що означає «kad se sve zbroji»?', 'якщо все підсумувати', '["одного дня, колись", "якщо все підсумувати", "інакший", "працьовитіший"]'::jsonb, 'A2', 2, 'PUBLISHED', 'kad se sve zbroji', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aa0d23ae-00ee-58a7-89b1-6cb51df4c737', 'multiple_choice', 'Що означає «naviknuti se»?', 'звикнути', '["інакший", "звикнути", "ритм життя", "пори року"]'::jsonb, 'A2', 3, 'PUBLISHED', 'naviknuti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b3217952-e920-512d-8491-512a82a56c2a', 'multiple_choice', 'Що означає «jednog dana»?', 'одного дня, колись', '["друга батьківщина", "такий самий, як", "розслабленіший", "одного дня, колись"]'::jsonb, 'A2', 4, 'PUBLISHED', 'jednog dana', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '64292590-1bea-5abb-8ed4-2672a1b5e2cc', 'multiple_choice', 'Як хорватською «у порівнянні з»?', 'u usporedbi s', '["u usporedbi s", "druga domovina", "godišnja doba", "isti kao"]'::jsonb, 'A2', 5, 'PUBLISHED', 'u usporedbi s', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f003458-a045-5b0c-8454-d015548e7634', 'multiple_choice', 'Як хорватською «друга батьківщина»?', 'druga domovina', '["ritam života", "druga domovina", "sličnost", "kad se sve zbroji"]'::jsonb, 'A2', 6, 'PUBLISHED', 'druga domovina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a1aca50e-e66e-5354-a353-bde964098eb8', 'type_answer', 'Напишіть хорватською: «розслабленіший»', 'opušteniji', null, 'A2', 7, 'PUBLISHED', 'opušteniji', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '59358943-bd69-5911-9351-f3cf376ea179', 'type_answer', 'Напишіть хорватською: «інакший»', 'drukčiji', null, 'A2', 8, 'PUBLISHED', 'drukčiji', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '175f00f7-eec8-5e13-a4b6-fb79978750b5', 'type_answer', 'Напишіть хорватською: «мені бракує, я сумую за (мн.)»', 'nedostaju mi', null, 'A2', 9, 'PUBLISHED', 'nedostaju mi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0996c4f8-5bd9-5444-adaf-d952b80a55dd', 'sentence_builder', 'Складіть: «Ритм життя тут повільніший.»', 'Ritam života ovdje je sporiji.', '["je", "Ritam", "života", "ovdje", "sporiji."]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9794f801-3695-5b3d-a67f-a5c0decf7749', 'sentence_builder', 'Складіть: «Хорватія стала мені другою батьківщиною.»', 'Hrvatska mi je postala druga domovina.', '["postala", "mi", "Hrvatska", "domovina.", "je", "druga"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5f41ee6f-4dfb-540e-9e03-07b2bf9397fa', 'listening', 'Прослухайте і складіть фразу', 'Jako. Nedostaju mi prijatelji i naš kruh.', '["prijatelji", "naš", "i", "kruh.", "Jako.", "Nedostaju", "mi"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '071c109d-e594-5603-9bb2-c97281b36490', 'listening_dialogue', 'Прослухайте новину', '20000; мова; у хорватські школи', 'A2', 'PUBLISHED', '{"kind": "news", "situation_ua": "Радіорепортаж про українців у Хорватії.", "script": [{"hr": "U Hrvatskoj trenutačno živi oko dvadeset tisuća Ukrajinaca s privremenom zaštitom.", "ua": "Зараз у Хорватії живе близько двадцяти тисяч українців з тимчасовим захистом."}, {"hr": "Većina kaže da im je najveći problem jezik, a zatim stan.", "ua": "Більшість каже, що найбільша проблема — мова, а потім житло."}, {"hr": "Mnogi su već našli posao i djeca idu u hrvatske škole.", "ua": "Багато хто вже знайшов роботу, а діти ходять у хорватські школи."}], "questions": [{"q_ua": "Скільки приблизно українців з тимчасовим захистом?", "answer_text": "20000", "accept": ["20 000", "20.000", "двадцять тисяч"], "answer_turn": 0}, {"q_ua": "Яка найбільша проблема?", "options": ["мова", "житло", "робота"], "correct": 0, "answer_turn": 1}, {"q_ua": "Куди ходять діти?", "options": ["лише в онлайн-школу", "у хорватські школи", "у приватні школи"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '071c109d-e594-5603-9bb2-c97281b36490', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c48765be-5ebf-5abf-849c-5615091a8682', 'speaking', 'Мені бракує друзів.', 'Nedostaju mi prijatelji.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '534e6bc1-d320-5705-a679-9ea4216a1434', 'speaking', 'На відміну від Києва, Спліт маленький.', 'Za razliku od Kijeva, Split je malen.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '0f15e40c-8bfb-54d8-bf1b-aab8fb894fb3', 'write_message', 'Напишіть подрузі в Україну, що в Хорватії інакше: що краще і чого вам бракує.', 'Ovdje je drukčije: ritam života je sporiji i ima više sunca. Ali nedostaju mi prijatelji i naš kruh.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі в Україну, що в Хорватії інакше: що краще і чого вам бракує.", "points": [{"ua": "що інакше / краще", "keys": [["drukčij"], ["bolj"], ["više"]]}, {"ua": "чого бракує", "keys": [["nedostaj"]]}], "hints": ["ovdje je drukčije", "ritam života je sporiji", "više sunca", "nedostaju mi"], "models": ["Ovdje je drukčije: ritam života je sporiji i ima više sunca. Ali nedostaju mi prijatelji i naš kruh."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '0f15e40c-8bfb-54d8-bf1b-aab8fb894fb3', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'b781fbbd-9a9f-5339-86d1-94fbe08f14ff', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Po njegovom mišljenju, hrvatski i ukrajinski imaju puno sličnosti.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи Іванові, що, на мою думку, хорватська й українська мови мають багато схожого.", "direction": "ua_hr", "points": [{"ua": "хорватська й українська", "keys": [["hrvatsk", "ukrajinsk"]]}, {"ua": "багато схожого", "keys": [["sličnost"], ["slič"]]}], "hints": [], "models": ["Po njegovom mišljenju, hrvatski i ukrajinski imaju puno sličnosti."], "source_ua": "Скажи Іванові, що, на мою думку, хорватська й українська мови мають багато схожого."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'b781fbbd-9a9f-5339-86d1-94fbe08f14ff', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d487bf73-de06-503b-bf3b-7c52b51898b2', v_lesson, 'Що інакше?', 'Što je drukčije?', 5771, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('17909bf6-f885-5f6a-bea2-ead6efad73c6', 'd487bf73-de06-503b-bf3b-7c52b51898b2', 'Ivan', 'Darja, što je najviše drukčije u Hrvatskoj nego u Ukrajini?', 'Дар’є, що найбільше відрізняється в Хорватії від України?', 1);
  perform pg_temp.turn('4e22af1a-0e65-5d60-8076-bef8c91244e7', 'd487bf73-de06-503b-bf3b-7c52b51898b2', 'Darja', 'Ritam života. Ovdje je sporiji, ljudi su opušteniji.', 'Ритм життя. Тут він повільніший, люди розслабленіші.', 2);
  perform pg_temp.turn('403f6c78-090c-59e9-acfd-663a6422d9f5', 'd487bf73-de06-503b-bf3b-7c52b51898b2', 'Ivan', 'A što ti se ne sviđa?', 'А що тобі не подобається?', 3);
  perform pg_temp.turn('0ef0bbfa-e87a-5977-85c5-ab13769d98b6', 'd487bf73-de06-503b-bf3b-7c52b51898b2', 'Darja', 'Birokracija. U Ukrajini su digitalne usluge puno brže.', 'Бюрократія. В Україні цифрові послуги набагато швидші.', 4);
  perform pg_temp.turn('0421017c-45bc-5920-9ffd-1408b5b9be7f', 'd487bf73-de06-503b-bf3b-7c52b51898b2', 'Ivan', 'A troškovi života?', 'А вартість життя?', 5);
  perform pg_temp.turn('6833dcaa-21d9-5853-abb8-279a0a21c8c5', 'd487bf73-de06-503b-bf3b-7c52b51898b2', 'Darja', 'U usporedbi s Kijevom, stanovi su skuplji, ali hrana je slična.', 'У порівнянні з Києвом, квартири дорожчі, але їжа схожа.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7679418d-1dc1-5393-ac80-9a13519ac4e1', v_lesson, 'Друга батьківщина', 'Druga domovina', 5772, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('9cd1193d-31b2-525c-a82d-1818ebbacd3c', '7679418d-1dc1-5393-ac80-9a13519ac4e1', 'Daša', 'Nedostaje li ti Ukrajina?', 'Ти сумуєш за Україною?', 1);
  perform pg_temp.turn('6441eb84-c794-54ea-8090-55abb916f971', '7679418d-1dc1-5393-ac80-9a13519ac4e1', 'Darja', 'Jako. Nedostaju mi prijatelji i naš kruh.', 'Дуже. Мені бракує друзів і нашого хліба.', 2);
  perform pg_temp.turn('77c3dcf8-de9a-5d29-9bfb-6b637ff5bc2d', '7679418d-1dc1-5393-ac80-9a13519ac4e1', 'Daša', 'A što voliš ovdje?', 'А що ти любиш тут?', 3);
  perform pg_temp.turn('ed8926bb-caa5-592a-b2bc-5df9e23360e9', '7679418d-1dc1-5393-ac80-9a13519ac4e1', 'Darja', 'More, blagu klimu i srdačne ljude. Navikla sam se i na fjaku!', 'Море, м’який клімат і привітних людей. Я звикла навіть до «фяки»!', 4);
  perform pg_temp.turn('328ccb7f-6a04-52af-bc4c-8e6763c51c7f', '7679418d-1dc1-5393-ac80-9a13519ac4e1', 'Daša', 'Je li ti Hrvatska postala druga domovina?', 'Хорватія стала тобі другою батьківщиною?', 5);
  perform pg_temp.turn('5a276291-15b1-5075-a6d3-15aa354c254f', '7679418d-1dc1-5393-ac80-9a13519ac4e1', 'Darja', 'Kad se sve zbroji, jest.', 'Якщо все підсумувати, так.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- 3. Модуль і юніт — опубліковані
update public.modules set status = 'PUBLISHED', title_ua = 'Модуль A2.12 — Українці в Хорватії', title_hr = 'Modul A2.12 — Ukrajinci u Hrvatskoj' where id = '5b885d2c-55ee-5635-91be-a4746da43999';
update public.units set status = 'PUBLISHED' where id = '6bdd7152-8541-5f3c-bf86-bc301e283140';

-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('5e298915-e179-5d58-bca0-6531c7b43a46', '695e119d-c66c-5c02-9f3e-a2a161403585', '55fdd530-ac46-5ba9-a5de-9fd5944b0c8c', 'bc5bde26-5065-560b-8877-1302e7048471', '56d06c34-2631-5ca9-a3a3-b0df910556dc', '0465a2cd-1da9-5a6e-a47d-434fc8bee342')
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
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 20 or l.unit_id <> '6bdd7152-8541-5f3c-bf86-bc301e283140');
  select count(*) into v_titles from (values ('5e298915-e179-5d58-bca0-6531c7b43a46'::uuid, 'Урок 72:%', 1), ('695e119d-c66c-5c02-9f3e-a2a161403585'::uuid, 'Урок 73:%', 2), ('55fdd530-ac46-5ba9-a5de-9fd5944b0c8c'::uuid, 'Урок 74:%', 3), ('bc5bde26-5065-560b-8877-1302e7048471'::uuid, 'Урок 75:%', 4), ('56d06c34-2631-5ca9-a3a3-b0df910556dc'::uuid, 'Урок 76:%', 5), ('0465a2cd-1da9-5a6e-a47d-434fc8bee342'::uuid, 'Урок 77:%', 6)) as t(id, pat, o)
    left join public.lessons l on l.id = t.id and l.title_ua like t.pat and l.order_index = t.o
   where l.id is null;
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
      where l.level_code = 'A2' and l.status = 'PUBLISHED' and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A2.12: % уроків з неправильним складом', v_bad; end if;
  if v_titles > 0 then raise exception 'Модуль A2.12: % уроків не на своєму місці чи з неправильним номером', v_titles; end if;
  if v_words > 0 then raise exception 'A2: % слів повторюються в кількох уроках', v_words; end if;
  if (select status from public.modules where id = '5b885d2c-55ee-5635-91be-a4746da43999') <> 'PUBLISHED' then raise exception 'Модуль A2.12 не опубліковано'; end if;
  raise notice 'Готово: модуль A2.12 — 6 уроків, слів 125';
end $$;

commit;
