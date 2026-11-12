-- =====================================================================
-- Програма A2 v2 · модуль A2.5 «Робота й кар’єра» · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2.py 5 (не редагуйте вручну).
--
-- Рішення власника 2026-11-12: 20–25 нових слів на урок, 90–95 % слів — нові для рівня, діалоги під тему,
-- частіше Даша / Дар’я; «Прослухайте діалог чи оголошення» в кожному уроці; бета (PUBLISHED).
--   * Уроки 30–36 (7): слів у них 149. Кожен: 20–25 слів, 2 діалоги, 15 вправ
--     (одна — «Прослухайте діалог чи оголошення»), «Напишіть повідомлення» і «Перекажіть другу» (ua → hr, необов’язкові), 20 хв.
--   * Слова: 149 (нові — PUBLISHED; ті, що вже є в словнику, не змінюються).
--   * Модуль і юніт A2.5 → PUBLISHED. Потрібен уже запущений 20261112_curriculum_a2_v2_00_structure.sql.
--   * Нічого не видаляє. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.units where id = 'b8e81d83-8ed4-5446-b36d-e6d23ee6fcd4') then
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

-- 1. Слова уроків A2.5 (149): нові — PUBLISHED (бета); наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A2', t.ua, t.vtype, t.forms, t.examples, 'PUBLISHED', 'claude_curriculum_a2_v2'
  from jsonb_to_recordset('[{"lemma": "dnevni red", "normalized": "dnevni red", "pos": "phrase", "ua": "порядок денний", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Prva točka dnevnog reda je budžet."]}, {"lemma": "točka dnevnog reda", "normalized": "tocka dnevnog reda", "pos": "phrase", "ua": "пункт порядку денного", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Prijeđimo na sljedeću točku dnevnog reda."]}, {"lemma": "krajnji rok", "normalized": "krajnji rok", "pos": "phrase", "ua": "кінцевий строк, дедлайн", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Krajnji rok je petak u podne."]}, {"lemma": "zaduženje", "normalized": "zaduzenje", "pos": "noun", "ua": "доручення, обов’язок", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Svatko ima svoje zaduženje."]}, {"lemma": "zadužiti", "normalized": "zaduziti", "pos": "verb", "ua": "доручити (комусь)", "vtype": "core", "forms": {"aspect": "pfv", "pair": "zaduživati"}, "examples": ["Šef me zadužio za prezentaciju."]}, {"lemma": "prioritet", "normalized": "prioritet", "pos": "noun", "ua": "пріоритет", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ovaj projekt nam je prioritet."]}, {"lemma": "voditelj projekta", "normalized": "voditelj projekta", "pos": "phrase", "ua": "керівник проєкту", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Voditelj projekta je sazvao sastanak."]}, {"lemma": "sazvati sastanak", "normalized": "sazvati sastanak", "pos": "phrase", "ua": "скликати нараду", "vtype": "chunk", "forms": {}, "examples": ["Direktorica je sazvala hitan sastanak."]}, {"lemma": "status projekta", "normalized": "status projekta", "pos": "phrase", "ua": "стан проєкту", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Kakav je status projekta?"]}, {"lemma": "kasniti s rokom", "normalized": "kasniti s rokom", "pos": "phrase", "ua": "не встигати в строк", "vtype": "chunk", "forms": {}, "examples": ["Kasnimo s rokom dva dana."]}, {"lemma": "pomaknuti rok", "normalized": "pomaknuti rok", "pos": "phrase", "ua": "перенести строк", "vtype": "chunk", "forms": {}, "examples": ["Možemo li pomaknuti rok na ponedjeljak?"]}, {"lemma": "obaviti", "normalized": "obaviti", "pos": "verb", "ua": "виконати, зробити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "obavljati"}, "examples": ["Obavila sam sve zadatke."]}, {"lemma": "preuzeti odgovornost", "normalized": "preuzeti odgovornost", "pos": "phrase", "ua": "взяти відповідальність", "vtype": "chunk", "forms": {}, "examples": ["Preuzimam odgovornost za grešku."]}, {"lemma": "raspodijeliti", "normalized": "raspodijeliti", "pos": "verb", "ua": "розподілити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "raspodjeljivati"}, "examples": ["Raspodijelimo posao među sobom."]}, {"lemma": "opterećen", "normalized": "opterecen", "pos": "adjective", "ua": "перевантажений", "vtype": "core", "forms": {}, "examples": ["Ovaj tjedan sam jako opterećena."]}, {"lemma": "učinkovit", "normalized": "ucinkovit", "pos": "adjective", "ua": "ефективний", "vtype": "core", "forms": {}, "examples": ["Kratki sastanci su učinkovitiji."]}, {"lemma": "zaključak", "normalized": "zakljucak", "pos": "noun", "ua": "висновок, рішення (наради)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Zaključak sastanka je jasan."]}, {"lemma": "pratiti napredak", "normalized": "pratiti napredak", "pos": "phrase", "ua": "відстежувати прогрес", "vtype": "chunk", "forms": {}, "examples": ["Napredak pratimo svaki tjedan."]}, {"lemma": "online sastanak", "normalized": "online sastanak", "pos": "phrase", "ua": "онлайн-нарада", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Online sastanak počinje u devet."]}, {"lemma": "podijeliti zaslon", "normalized": "podijeliti zaslon", "pos": "phrase", "ua": "показати екран", "vtype": "chunk", "forms": {}, "examples": ["Možete li podijeliti zaslon?"]}, {"lemma": "isključiti mikrofon", "normalized": "iskljuciti mikrofon", "pos": "phrase", "ua": "вимкнути мікрофон", "vtype": "chunk", "forms": {}, "examples": ["Molim sve da isključe mikrofon."]}, {"lemma": "kratak sažetak", "normalized": "kratak sazetak", "pos": "phrase", "ua": "коротке резюме", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Pošaljite mi kratak sažetak."]}, {"lemma": "poslovni e-mail", "normalized": "poslovni e-mail", "pos": "phrase", "ua": "діловий e-mail", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Poslovni e-mail mora biti kratak i jasan."]}, {"lemma": "s poštovanjem", "normalized": "s postovanjem", "pos": "phrase", "ua": "з повагою", "vtype": "chunk", "forms": {}, "examples": ["S poštovanjem, Darja Kovalenko."]}, {"lemma": "srdačan pozdrav", "normalized": "srdacan pozdrav", "pos": "phrase", "ua": "щиро, з найкращими побажаннями (наприкінці листа)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Srdačan pozdrav iz Zagreba!"]}, {"lemma": "u privitku", "normalized": "u privitku", "pos": "phrase", "ua": "у вкладенні", "vtype": "chunk", "forms": {}, "examples": ["U privitku Vam šaljem ponudu."]}, {"lemma": "predmet e-maila", "normalized": "predmet e-maila", "pos": "phrase", "ua": "тема листа", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Predmet e-maila treba biti kratak."]}, {"lemma": "u kopiji", "normalized": "u kopiji", "pos": "phrase", "ua": "у копії (листа)", "vtype": "chunk", "forms": {}, "examples": ["Stavila sam šefa u kopiju."]}, {"lemma": "potvrditi primitak", "normalized": "potvrditi primitak", "pos": "phrase", "ua": "підтвердити отримання", "vtype": "chunk", "forms": {}, "examples": ["Molim Vas da potvrdite primitak."]}, {"lemma": "unaprijed zahvaljujem", "normalized": "unaprijed zahvaljujem", "pos": "phrase", "ua": "заздалегідь дякую", "vtype": "chunk", "forms": {}, "examples": ["Unaprijed zahvaljujem na odgovoru."]}, {"lemma": "obratiti se", "normalized": "obratiti se", "pos": "verb", "ua": "звернутися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "obraćati se"}, "examples": ["Obraćam Vam se zbog narudžbe."]}, {"lemma": "vezano uz", "normalized": "vezano uz", "pos": "phrase", "ua": "щодо, стосовно", "vtype": "chunk", "forms": {}, "examples": ["Vezano uz Vaš upit, šaljem cijene."]}, {"lemma": "upit", "normalized": "upit", "pos": "noun", "ua": "запит", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Hvala na Vašem upitu."]}, {"lemma": "ispričavam se zbog kašnjenja", "normalized": "ispricavam se zbog kasnjenja", "pos": "phrase", "ua": "перепрошую за затримку", "vtype": "chunk", "forms": {}, "examples": ["Ispričavam se zbog kašnjenja odgovora."]}, {"lemma": "javiti se", "normalized": "javiti se", "pos": "verb", "ua": "озватися, відповісти", "vtype": "core", "forms": {"aspect": "pfv", "pair": "javljati se"}, "examples": ["Javit ću Vam se sutra."]}, {"lemma": "stojim na raspolaganju", "normalized": "stojim na raspolaganju", "pos": "phrase", "ua": "я до ваших послуг (відповім на питання)", "vtype": "chunk", "forms": {}, "examples": ["Za dodatna pitanja stojim na raspolaganju."]}, {"lemma": "dodatna pitanja", "normalized": "dodatna pitanja", "pos": "phrase", "ua": "додаткові питання", "vtype": "chunk", "forms": {"gender": "n_pl"}, "examples": ["Ako imate dodatnih pitanja, javite se."]}, {"lemma": "potpis", "normalized": "potpis", "pos": "noun", "ua": "підпис", "vtype": "core", "forms": {"gender": "m"}, "examples": ["U potpisu stavite broj telefona."]}, {"lemma": "službeni", "normalized": "sluzbeni", "pos": "adjective", "ua": "офіційний, службовий", "vtype": "core", "forms": {}, "examples": ["Ovo je službeni dopis."]}, {"lemma": "dopis", "normalized": "dopis", "pos": "noun", "ua": "офіційний лист", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Dobili smo dopis iz ministarstva."]}, {"lemma": "poslati ponovno", "normalized": "poslati ponovno", "pos": "phrase", "ua": "надіслати повторно", "vtype": "chunk", "forms": {}, "examples": ["Možete li mi poslati ponovno privitak?"]}, {"lemma": "slijedom Vašeg upita", "normalized": "slijedom vaseg upita", "pos": "phrase", "ua": "у відповідь на ваш запит", "vtype": "chunk", "forms": {}, "examples": ["Slijedom Vašeg upita šaljem cjenik."]}, {"lemma": "cjenik", "normalized": "cjenik", "pos": "noun", "ua": "прайс-лист", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Novi cjenik vrijedi od siječnja."]}, {"lemma": "ovdje je", "normalized": "ovdje je", "pos": "phrase", "ua": "це (говорить)…", "vtype": "chunk", "forms": {}, "examples": ["Dobar dan, ovdje je Darja Kovalenko."]}, {"lemma": "mogu li razgovarati s", "normalized": "mogu li razgovarati s", "pos": "phrase", "ua": "чи можу я поговорити з", "vtype": "chunk", "forms": {}, "examples": ["Mogu li razgovarati s gospodinom Horvatom?"]}, {"lemma": "spojiti", "normalized": "spojiti", "pos": "verb", "ua": "з’єднати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "spajati"}, "examples": ["Spojit ću Vas s odjelom prodaje."]}, {"lemma": "linija je zauzeta", "normalized": "linija je zauzeta", "pos": "phrase", "ua": "лінія зайнята", "vtype": "chunk", "forms": {}, "examples": ["Linija je zauzeta, pričekajte."]}, {"lemma": "trenutno nije dostupan", "normalized": "trenutno nije dostupan", "pos": "phrase", "ua": "зараз недоступний", "vtype": "chunk", "forms": {}, "examples": ["Gospodin Horvat trenutno nije dostupan."]}, {"lemma": "prenijeti poruku", "normalized": "prenijeti poruku", "pos": "phrase", "ua": "передати повідомлення", "vtype": "chunk", "forms": {}, "examples": ["Mogu li mu prenijeti poruku?"]}, {"lemma": "uzvratiti poziv", "normalized": "uzvratiti poziv", "pos": "phrase", "ua": "передзвонити (у відповідь)", "vtype": "chunk", "forms": {}, "examples": ["Uzvratit će Vam poziv poslijepodne."]}, {"lemma": "slabo se čuje", "normalized": "slabo se cuje", "pos": "phrase", "ua": "погано чути", "vtype": "chunk", "forms": {}, "examples": ["Oprostite, slabo se čuje."]}, {"lemma": "prekinula se veza", "normalized": "prekinula se veza", "pos": "phrase", "ua": "зв’язок перервався", "vtype": "chunk", "forms": {}, "examples": ["Prekinula se veza, nazvat ću ponovno."]}, {"lemma": "slovkati", "normalized": "slovkati", "pos": "verb", "ua": "продиктувати по літерах", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Možete li slovkati svoje prezime?"]}, {"lemma": "interni broj", "normalized": "interni broj", "pos": "phrase", "ua": "внутрішній номер (телефону)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Moj interni broj je dvjesto četiri."]}, {"lemma": "centrala", "normalized": "centrala", "pos": "noun", "ua": "комутатор, приймальня", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Nazovite centralu i tražite odjel."]}, {"lemma": "glasovna pošta", "normalized": "glasovna posta", "pos": "phrase", "ua": "голосова пошта", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Ostavite poruku na glasovnoj pošti."]}, {"lemma": "zapisati broj", "normalized": "zapisati broj", "pos": "phrase", "ua": "записати номер", "vtype": "chunk", "forms": {}, "examples": ["Čekajte, da zapišem broj."]}, {"lemma": "nazvati natrag", "normalized": "nazvati natrag", "pos": "phrase", "ua": "передзвонити", "vtype": "chunk", "forms": {}, "examples": ["Nazvat ću Vas natrag za pet minuta."]}, {"lemma": "krivi broj", "normalized": "krivi broj", "pos": "phrase", "ua": "неправильний номер", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Oprostite, nazvali ste krivi broj."]}, {"lemma": "hvala na pozivu", "normalized": "hvala na pozivu", "pos": "phrase", "ua": "дякую за дзвінок", "vtype": "chunk", "forms": {}, "examples": ["Hvala na pozivu, doviđenja."]}, {"lemma": "o čemu se radi", "normalized": "o cemu se radi", "pos": "phrase", "ua": "про що йдеться", "vtype": "chunk", "forms": {}, "examples": ["Recite mi, o čemu se radi?"]}, {"lemma": "ostati na liniji", "normalized": "ostati na liniji", "pos": "phrase", "ua": "залишатися на лінії", "vtype": "chunk", "forms": {}, "examples": ["Ostanite na liniji, spajam Vas."]}, {"lemma": "telefonska sekretarica", "normalized": "telefonska sekretarica", "pos": "phrase", "ua": "автовідповідач", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Javila se telefonska sekretarica."]}, {"lemma": "nedostupan", "normalized": "nedostupan", "pos": "adjective", "ua": "недоступний", "vtype": "core", "forms": {}, "examples": ["Broj je trenutno nedostupan."]}, {"lemma": "zahtjev za godišnji", "normalized": "zahtjev za godisnji", "pos": "phrase", "ua": "заява на відпустку", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Predala sam zahtjev za godišnji."]}, {"lemma": "iskoristiti godišnji", "normalized": "iskoristiti godisnji", "pos": "phrase", "ua": "використати відпустку", "vtype": "chunk", "forms": {}, "examples": ["Moram iskoristiti godišnji do lipnja."]}, {"lemma": "dani godišnjeg", "normalized": "dani godisnjeg", "pos": "phrase", "ua": "дні відпустки", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Imam još deset dana godišnjeg."]}, {"lemma": "plan godišnjih odmora", "normalized": "plan godisnjih odmora", "pos": "phrase", "ua": "графік відпусток", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Plan godišnjih odmora radi se u proljeće."]}, {"lemma": "neplaćeni dopust", "normalized": "neplaceni dopust", "pos": "phrase", "ua": "відпустка за свій рахунок", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Uzela sam tjedan neplaćenog dopusta."]}, {"lemma": "rodiljni dopust", "normalized": "rodiljni dopust", "pos": "phrase", "ua": "декретна відпустка (у пологах)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Kolegica je na rodiljnom dopustu."]}, {"lemma": "roditeljski dopust", "normalized": "roditeljski dopust", "pos": "phrase", "ua": "відпустка по догляду за дитиною", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["I otac može koristiti roditeljski dopust."]}, {"lemma": "otvoriti bolovanje", "normalized": "otvoriti bolovanje", "pos": "phrase", "ua": "відкрити лікарняний", "vtype": "chunk", "forms": {}, "examples": ["Liječnik mi je otvorio bolovanje."]}, {"lemma": "zatvoriti bolovanje", "normalized": "zatvoriti bolovanje", "pos": "phrase", "ua": "закрити лікарняний", "vtype": "chunk", "forms": {}, "examples": ["U petak zatvaram bolovanje."]}, {"lemma": "biti na bolovanju", "normalized": "biti na bolovanju", "pos": "phrase", "ua": "бути на лікарняному", "vtype": "chunk", "forms": {}, "examples": ["Marko je na bolovanju do petka."]}, {"lemma": "javiti se bolestan", "normalized": "javiti se bolestan", "pos": "phrase", "ua": "повідомити, що захворів", "vtype": "chunk", "forms": {}, "examples": ["Jutros sam se javila bolesna."]}, {"lemma": "zamjenik", "normalized": "zamjenik", "pos": "noun", "ua": "заступник (на час відсутності)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Dok sam na godišnjem, zamjenik mi je Ivan."]}, {"lemma": "primopredaja", "normalized": "primopredaja", "pos": "noun", "ua": "передача справ", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Prije godišnjeg napravi primopredaju."]}, {"lemma": "automatski odgovor", "normalized": "automatski odgovor", "pos": "phrase", "ua": "автовідповідь", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Uključila sam automatski odgovor."]}, {"lemma": "vratiti se na posao", "normalized": "vratiti se na posao", "pos": "phrase", "ua": "повернутися на роботу", "vtype": "chunk", "forms": {}, "examples": ["Na posao se vraćam u ponedjeljak."]}, {"lemma": "odobriti zahtjev", "normalized": "odobriti zahtjev", "pos": "phrase", "ua": "погодити заяву", "vtype": "chunk", "forms": {}, "examples": ["Šefica je odobrila moj zahtjev."]}, {"lemma": "poklapati se", "normalized": "poklapati se", "pos": "verb", "ua": "збігатися", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Naš godišnji se poklapa s kolegom."]}, {"lemma": "hitan slučaj", "normalized": "hitan slucaj", "pos": "phrase", "ua": "невідкладний випадок", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["U hitnom slučaju me nazovi."]}, {"lemma": "produženi vikend", "normalized": "produzeni vikend", "pos": "phrase", "ua": "довгі вихідні", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Uzet ću petak za produženi vikend."]}, {"lemma": "godišnji u dijelovima", "normalized": "godisnji u dijelovima", "pos": "phrase", "ua": "відпустка частинами", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Godišnji mogu koristiti u dijelovima."]}, {"lemma": "preostali dani", "normalized": "preostali dani", "pos": "phrase", "ua": "решта днів", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Preostale dane godišnjeg koristim u prosincu."]}, {"lemma": "bruto plaća", "normalized": "bruto placa", "pos": "phrase", "ua": "зарплата брутто (до податків)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Moja bruto plaća je tisuću osamsto eura."]}, {"lemma": "neto plaća", "normalized": "neto placa", "pos": "phrase", "ua": "зарплата нетто («на руки»)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Neto plaća sjeda na račun desetog."]}, {"lemma": "porez na dohodak", "normalized": "porez na dohodak", "pos": "phrase", "ua": "податок на доходи", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Porez na dohodak ovisi o gradu."]}, {"lemma": "mirovinski doprinos", "normalized": "mirovinski doprinos", "pos": "phrase", "ua": "пенсійний внесок", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Mirovinski doprinos se uplaćuje u dva stupa."]}, {"lemma": "osobni odbitak", "normalized": "osobni odbitak", "pos": "phrase", "ua": "неоподатковувана сума (особиста знижка)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Za djecu imate veći osobni odbitak."]}, {"lemma": "uzdržavani član", "normalized": "uzdrzavani clan", "pos": "phrase", "ua": "утриманець (член сім’ї)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Djeca su uzdržavani članovi."]}, {"lemma": "sjesti na račun", "normalized": "sjesti na racun", "pos": "phrase", "ua": "надійти на рахунок", "vtype": "chunk", "forms": {}, "examples": ["Plaća još nije sjela na račun."]}, {"lemma": "obračun plaće", "normalized": "obracun place", "pos": "phrase", "ua": "нарахування зарплати", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["U obračunu plaće je greška."]}, {"lemma": "dodatak za noćni rad", "normalized": "dodatak za nocni rad", "pos": "phrase", "ua": "доплата за нічну роботу", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Imam dodatak za noćni rad."]}, {"lemma": "povišica", "normalized": "povisica", "pos": "noun", "ua": "підвищення зарплати", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Tražila sam povišicu."]}, {"lemma": "nagrada", "normalized": "nagrada", "pos": "noun", "ua": "премія, винагорода", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Za dobar rad dobili smo nagradu."]}, {"lemma": "topli obrok", "normalized": "topli obrok", "pos": "phrase", "ua": "компенсація за харчування", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Topli obrok se ne oporezuje."]}, {"lemma": "putni troškovi", "normalized": "putni troskovi", "pos": "phrase", "ua": "проїзні витрати (компенсація)", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Tvrtka plaća putne troškove."]}, {"lemma": "porezna kartica", "normalized": "porezna kartica", "pos": "phrase", "ua": "податкова картка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Poslodavac mora imati Vašu poreznu karticu."]}, {"lemma": "godišnja porezna prijava", "normalized": "godisnja porezna prijava", "pos": "phrase", "ua": "річна податкова декларація", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Povrat poreza dobivate nakon godišnje porezne prijave."]}, {"lemma": "povrat poreza", "normalized": "povrat poreza", "pos": "phrase", "ua": "повернення податку", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ove godine imam povrat poreza."]}, {"lemma": "oporezivati", "normalized": "oporezivati", "pos": "verb", "ua": "оподатковувати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Nagrade se oporezuju."]}, {"lemma": "razlika", "normalized": "razlika", "pos": "noun", "ua": "різниця", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Razlika između bruto i neto plaće je velika."]}, {"lemma": "objasniti", "normalized": "objasniti", "pos": "verb", "ua": "пояснити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "objašnjavati"}, "examples": ["Možete li mi objasniti ovu stavku?"]}, {"lemma": "stavka", "normalized": "stavka", "pos": "noun", "ua": "пункт, позиція (у документі)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ova stavka mi nije jasna."]}, {"lemma": "neoporeziv", "normalized": "neoporeziv", "pos": "adjective", "ua": "неоподатковуваний", "vtype": "core", "forms": {}, "examples": ["Topli obrok je neoporeziv do određenog iznosa."]}, {"lemma": "akontacija poreza", "normalized": "akontacija poreza", "pos": "phrase", "ua": "авансовий платіж податку", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Poslodavac svaki mjesec plaća akontaciju poreza."]}, {"lemma": "dobiti otkaz", "normalized": "dobiti otkaz", "pos": "phrase", "ua": "отримати звільнення (бути звільненим)", "vtype": "chunk", "forms": {}, "examples": ["Prošli mjesec je dobio otkaz."]}, {"lemma": "poslovno uvjetovani otkaz", "normalized": "poslovno uvjetovani otkaz", "pos": "phrase", "ua": "звільнення з економічних причин", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Zbog smanjenja posla dobili smo poslovno uvjetovani otkaz."]}, {"lemma": "sporazumni raskid", "normalized": "sporazumni raskid", "pos": "phrase", "ua": "розірвання договору за згодою сторін", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Dogovorili smo sporazumni raskid ugovora."]}, {"lemma": "otpremnina", "normalized": "otpremnina", "pos": "noun", "ua": "вихідна допомога", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Nakon pet godina rada imate pravo na otpremninu."]}, {"lemma": "radni staž", "normalized": "radni staz", "pos": "phrase", "ua": "трудовий стаж", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Otkazni rok ovisi o radnom stažu."]}, {"lemma": "potvrda o zaposlenju", "normalized": "potvrda o zaposlenju", "pos": "phrase", "ua": "довідка з місця роботи", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za kredit trebam potvrdu o zaposlenju."]}, {"lemma": "naknada za nezaposlenost", "normalized": "naknada za nezaposlenost", "pos": "phrase", "ua": "допомога з безробіття", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Prijavila sam se za naknadu za nezaposlenost."]}, {"lemma": "smanjenje broja radnika", "normalized": "smanjenje broja radnika", "pos": "phrase", "ua": "скорочення працівників", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Tvrtka najavljuje smanjenje broja radnika."]}, {"lemma": "istek ugovora", "normalized": "istek ugovora", "pos": "phrase", "ua": "закінчення договору", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ugovor mi ističe u lipnju."]}, {"lemma": "produžiti ugovor", "normalized": "produziti ugovor", "pos": "phrase", "ua": "продовжити договір", "vtype": "chunk", "forms": {}, "examples": ["Nisu mi produžili ugovor."]}, {"lemma": "ponuda za posao", "normalized": "ponuda za posao", "pos": "phrase", "ua": "пропозиція роботи", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Dobila sam ponudu za posao u Splitu."]}, {"lemma": "prihvatiti ponudu", "normalized": "prihvatiti ponudu", "pos": "phrase", "ua": "прийняти пропозицію", "vtype": "chunk", "forms": {}, "examples": ["Prihvatila sam ponudu."]}, {"lemma": "odbiti ponudu", "normalized": "odbiti ponudu", "pos": "phrase", "ua": "відхилити пропозицію", "vtype": "chunk", "forms": {}, "examples": ["Odbio je ponudu jer je plaća mala."]}, {"lemma": "poslodavac", "normalized": "poslodavac", "pos": "noun", "ua": "роботодавець", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Novi poslodavac nudi bolje uvjete."]}, {"lemma": "radnik", "normalized": "radnik", "pos": "noun", "ua": "працівник", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Radnik ima pravo na godišnji odmor."]}, {"lemma": "sindikat", "normalized": "sindikat", "pos": "noun", "ua": "профспілка", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Javila sam se sindikatu."]}, {"lemma": "radno pravo", "normalized": "radno pravo", "pos": "phrase", "ua": "трудове право", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Pitajte odvjetnika za radno pravo."]}, {"lemma": "inspektorat rada", "normalized": "inspektorat rada", "pos": "phrase", "ua": "інспекція праці", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Prijavila sam poslodavca inspektoratu rada."]}, {"lemma": "davati otkaz", "normalized": "davati otkaz", "pos": "phrase", "ua": "звільнятися (подавати заяву), звільняти", "vtype": "chunk", "forms": {}, "examples": ["Mnogi ljudi ove godine daju otkaz."]}, {"lemma": "nastaviti dalje", "normalized": "nastaviti dalje", "pos": "phrase", "ua": "рухатися далі", "vtype": "chunk", "forms": {}, "examples": ["Teško je, ali treba nastaviti dalje."]}, {"lemma": "prilika", "normalized": "prilika", "pos": "noun", "ua": "нагода, можливість", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ovo je dobra prilika za mene."]}, {"lemma": "obrt", "normalized": "obrt", "pos": "noun", "ua": "обрт (ФОП, дрібне підприємництво)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Otvorila sam obrt za čišćenje."]}, {"lemma": "obrtnik", "normalized": "obrtnik", "pos": "noun", "ua": "підприємець (власник обрту)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Moj susjed je obrtnik, ima stolariju."]}, {"lemma": "otvoriti obrt", "normalized": "otvoriti obrt", "pos": "phrase", "ua": "відкрити обрт", "vtype": "chunk", "forms": {}, "examples": ["Kako se otvara obrt?"]}, {"lemma": "paušalni obrt", "normalized": "pausalni obrt", "pos": "phrase", "ua": "обрт на фіксованому податку", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Paušalni obrt je jednostavniji za početak."]}, {"lemma": "obrtni registar", "normalized": "obrtni registar", "pos": "phrase", "ua": "реєстр підприємців", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Obrt se upisuje u obrtni registar."]}, {"lemma": "djelatnost", "normalized": "djelatnost", "pos": "noun", "ua": "вид діяльності", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Koja je Vaša djelatnost?"]}, {"lemma": "sjedište", "normalized": "sjediste", "pos": "noun", "ua": "юридична адреса, осідок", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Sjedište obrta je u mom stanu."]}, {"lemma": "poslovni račun", "normalized": "poslovni racun", "pos": "phrase", "ua": "бізнес-рахунок", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Za obrt trebaš poslovni račun u banci."]}, {"lemma": "fiskalizacija", "normalized": "fiskalizacija", "pos": "noun", "ua": "фіскалізація (реєстрація чеків)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Fiskalizacija je obvezna za gotovinu."]}, {"lemma": "izdati račun", "normalized": "izdati racun", "pos": "phrase", "ua": "виписати рахунок", "vtype": "chunk", "forms": {}, "examples": ["Svakom kupcu moram izdati račun."]}, {"lemma": "PDV", "normalized": "pdv", "pos": "noun", "ua": "ПДВ", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Mali obrtnici često nisu u sustavu PDV-a."]}, {"lemma": "prihod", "normalized": "prihod", "pos": "noun", "ua": "дохід", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ove godine imam veći prihod."]}, {"lemma": "trošak", "normalized": "trosak", "pos": "noun", "ua": "витрата", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Najveći trošak mi je najam prostora."]}, {"lemma": "dobit", "normalized": "dobit", "pos": "noun", "ua": "прибуток", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Dobit je bila mala prve godine."]}, {"lemma": "knjigovodstveni servis", "normalized": "knjigovodstveni servis", "pos": "phrase", "ua": "бухгалтерська фірма (аутсорс)", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Knjigovodstveni servis vodi moje knjige."]}, {"lemma": "poduzetnik", "normalized": "poduzetnik", "pos": "noun", "ua": "підприємець", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Mladi poduzetnici mogu dobiti potporu."]}, {"lemma": "potpora", "normalized": "potpora", "pos": "noun", "ua": "грант, підтримка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Zavod daje potporu za samozapošljavanje."]}, {"lemma": "samozapošljavanje", "normalized": "samozaposljavanje", "pos": "noun", "ua": "самозайнятість", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Potpora za samozapošljavanje pomogla mi je na početku."]}, {"lemma": "poslovni plan", "normalized": "poslovni plan", "pos": "phrase", "ua": "бізнес-план", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Za potporu treba napisati poslovni plan."]}, {"lemma": "rizik", "normalized": "rizik", "pos": "noun", "ua": "ризик", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Vlastiti posao je uvijek rizik."]}, {"lemma": "isplatiti se", "normalized": "isplatiti se", "pos": "verb", "ua": "окупитися, бути вигідним", "vtype": "core", "forms": {"aspect": "pfv", "pair": "isplaćivati se"}, "examples": ["Ne znam hoće li se isplatiti."]}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 2. Уроки модуля A2.5
-- A2.5 · урок 30: Наради, завдання й терміни — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'b8e81d83-8ed4-5446-b36d-e6d23ee6fcd4';
  v_lesson constant uuid := '97f1ba90-fe04-5907-803f-2ec0854b0a09';
  v_gid constant uuid := '0b2de584-05a6-5570-a129-366fcb94766d';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики VID'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A2.5: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 30: Наради, завдання й терміни', 'Lekcija 30: Sastanci, zadaci i rokovi', '["Обговорити на нараді завдання, пріоритети й строки", "Розрізняти вид у планах: završavati — završiti, slati — poslati"]'::jsonb, 20, 'PUBLISHED', 1);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'dnevni red', v_pos);
  v_pos := pg_temp.word(v_lesson, 'točka dnevnog reda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krajnji rok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaduženje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zadužiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prioritet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'voditelj projekta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sazvati sastanak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'status projekta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kasniti s rokom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pomaknuti rok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preuzeti odgovornost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'raspodijeliti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opterećen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'učinkovit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaključak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pratiti napredak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'online sastanak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podijeliti zaslon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'isključiti mikrofon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kratak sažetak', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd4c7fdc6-4da4-50de-ae40-73118e46da34', 'fill_in_the_blank', 'Do petka moram ___ izvještaj.', 'završiti', '["završiti", "završavam", "završavati", "završila"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '871a8bc9-7aa7-5606-9a4f-06736cf1c186', 'multiple_choice', 'Що означає «pomaknuti rok»?', 'перенести строк', '["керівник проєкту", "перенести строк", "виконати, зробити", "ефективний"]'::jsonb, 'A2', 2, 'PUBLISHED', 'pomaknuti rok', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '652fd310-d091-55d4-822f-93277eea627c', 'multiple_choice', 'Що означає «točka dnevnog reda»?', 'пункт порядку денного', '["взяти відповідальність", "доручити (комусь)", "пункт порядку денного", "перевантажений"]'::jsonb, 'A2', 3, 'PUBLISHED', 'točka dnevnog reda', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '54675b85-1de4-58b9-97a0-ccb4781fd0f2', 'multiple_choice', 'Що означає «status projekta»?', 'стан проєкту', '["доручення, обов’язок", "порядок денний", "скликати нараду", "стан проєкту"]'::jsonb, 'A2', 4, 'PUBLISHED', 'status projekta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7da1d544-fd4f-52d7-bd16-d3516a7e202e', 'multiple_choice', 'Як хорватською «скликати нараду»?', 'sazvati sastanak', '["sazvati sastanak", "zadužiti", "dnevni red", "opterećen"]'::jsonb, 'A2', 5, 'PUBLISHED', 'sazvati sastanak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd0fe2b0e-7490-5fcb-9bed-a34d7b249f00', 'multiple_choice', 'Як хорватською «розподілити»?', 'raspodijeliti', '["raspodijeliti", "zaduženje", "učinkovit", "krajnji rok"]'::jsonb, 'A2', 6, 'PUBLISHED', 'raspodijeliti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c790bc44-9fe4-5b42-8c62-1a2f815abe25', 'type_answer', 'Напишіть хорватською: «пріоритет»', 'prioritet', null, 'A2', 7, 'PUBLISHED', 'prioritet', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ac556d25-9da3-5d3b-90a5-11b41e8bbbff', 'type_answer', 'Напишіть хорватською: «порядок денний»', 'dnevni red', null, 'A2', 8, 'PUBLISHED', 'dnevni red', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9ded104d-3b6d-5070-a9b6-7623fe8d5704', 'type_answer', 'Напишіть хорватською: «коротке резюме»', 'kratak sažetak', null, 'A2', 9, 'PUBLISHED', 'kratak sažetak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ec5c1cb7-33b8-54c9-bab8-146789d864ff', 'sentence_builder', 'Складіть: «Кінцевий строк — п’ятниця опівдні.»', 'Krajnji rok je petak u podne.', '["je", "u", "podne.", "rok", "Krajnji", "petak"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6678abe8-c422-55e3-82e2-8c92b9870a4e', 'sentence_builder', 'Складіть: «Я виконала всі завдання.»', 'Obavila sam sve zadatke.', '["Obavila", "sve", "sam", "zadatke."]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6cf7b9ec-16bb-5414-a193-3e080fe9eae3', 'listening', 'Прослухайте і складіть фразу', 'Dobro. Marko, tebe zadužujem za prezentaciju.', '["tebe", "zadužujem", "prezentaciju.", "za", "Marko,", "Dobro."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'b1216c9e-18d9-5894-ac28-b582390e51fc', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'у середу о 10:00; стан проєкту й резюме; кінцевий строк', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Керівник проєкту залишив вам голосове повідомлення.", "script": [{"hr": "Darja, ovdje Tomislav. Sastanak je pomaknut na srijedu u deset.", "ua": "Дар’є, це Томіслав. Нараду перенесли на середу о десятій."}, {"hr": "Molim te, pripremi status projekta i kratak sažetak.", "ua": "Будь ласка, підготуй стан проєкту й коротке резюме."}, {"hr": "Klijent je pomaknuo krajnji rok na kraj mjeseca.", "ua": "Клієнт переніс кінцевий строк на кінець місяця."}], "questions": [{"q_ua": "Коли нарада?", "options": ["у середу о 10:00", "у вівторок о 9:00", "у четвер о 10:00"], "correct": 0, "answer_turn": 0}, {"q_ua": "Що треба підготувати?", "options": ["презентацію для клієнта", "стан проєкту й резюме", "договір"], "correct": 1, "answer_turn": 1}, {"q_ua": "Що змінив клієнт?", "options": ["бюджет", "команду", "кінцевий строк"], "correct": 2, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'b1216c9e-18d9-5894-ac28-b582390e51fc', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ee5cf408-d5d0-5de3-9851-e4ecc26ddd71', 'speaking', 'Чи можемо перенести строк?', 'Možemo li pomaknuti rok?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '98997758-0cbe-5b4c-8f36-256887d7c0dc', 'speaking', 'Цього тижня я дуже перевантажена.', 'Ovaj tjedan sam jako opterećena.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'fe496030-f383-5c8b-a61f-c42f091eae48', 'write_message', 'Напишіть керівникові: ви не встигаєте зі звітом і просите перенести строк на понеділок.', 'Poštovani, kasnim s izvještajem. Možemo li pomaknuti rok na ponedjeljak?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть керівникові: ви не встигаєте зі звітом і просите перенести строк на понеділок.", "points": [{"ua": "не встигаєте", "keys": [["kasn"], ["ne stižem"]]}, {"ua": "звіт", "keys": [["izvještaj"]]}, {"ua": "перенести на понеділок", "keys": [["ponedjelj"]]}], "hints": ["kasnim s izvještajem", "možemo li pomaknuti rok", "na ponedjeljak"], "models": ["Poštovani, kasnim s izvještajem. Možemo li pomaknuti rok na ponedjeljak?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'fe496030-f383-5c8b-a61f-c42f091eae48', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '1ca861b8-f822-53b0-9d10-8fd0b4d502a3', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Moja kolegica će preuzeti prezentaciju i poslat će je u četvrtak.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи керівникові, що я візьму на себе презентацію і надішлю її в четвер.", "direction": "ua_hr", "points": [{"ua": "візьме презентацію", "keys": [["prezentacij"]]}, {"ua": "надішле в четвер", "keys": [["četvrt"]]}], "hints": [], "models": ["Moja kolegica će preuzeti prezentaciju i poslat će je u četvrtak."], "source_ua": "Скажи керівникові, що я візьму на себе презентацію і надішлю її в четвер."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '1ca861b8-f822-53b0-9d10-8fd0b4d502a3', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c3418200-c6a3-5355-bb30-a8328afc0c5a', v_lesson, 'Нарада в понеділок', 'Sastanak u ponedjeljak', 5301, 'A2', 'work', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('7b36b9ba-0c30-5f2a-b103-0cec2b7aa90a', 'c3418200-c6a3-5355-bb30-a8328afc0c5a', 'Voditelj', 'Dobro jutro. Prva točka dnevnog reda je status projekta. Darja?', 'Доброго ранку. Перший пункт порядку денного — стан проєкту. Дар’є?', 1);
  perform pg_temp.turn('94bf2e1b-8d50-55fa-a576-c6be1444be0d', 'c3418200-c6a3-5355-bb30-a8328afc0c5a', 'Darja', 'Kasnimo s rokom dva dana. Tim je jako opterećen.', 'Ми не встигаємо на два дні. Команда дуже перевантажена.', 2);
  perform pg_temp.turn('4dcd91ad-d1e9-53aa-9dbe-130b2c8078ec', 'c3418200-c6a3-5355-bb30-a8328afc0c5a', 'Voditelj', 'Možemo li pomaknuti rok na ponedjeljak?', 'Чи можемо перенести строк на понеділок?', 3);
  perform pg_temp.turn('10edf859-2cc3-5e03-9a16-33a7080d9d9e', 'c3418200-c6a3-5355-bb30-a8328afc0c5a', 'Darja', 'Možemo, ako raspodijelimo zadatke. Ja ću preuzeti izvještaj.', 'Можемо, якщо розподілимо завдання. Я візьму звіт.', 4);
  perform pg_temp.turn('dbe1bfa9-ed8c-5b02-a552-4ed23610ad0b', 'c3418200-c6a3-5355-bb30-a8328afc0c5a', 'Voditelj', 'Dobro. Marko, tebe zadužujem za prezentaciju.', 'Добре. Марку, тобі доручаю презентацію.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('929b5f4b-6026-53a7-bb3c-bd90736f3acf', v_lesson, 'Онлайн-нарада', 'Online sastanak', 5302, 'A2', 'work', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('82394046-e255-5537-a4c3-6bb61fa953b5', '929b5f4b-6026-53a7-bb3c-bd90736f3acf', 'Daša', 'Čujete li me? Mogu li podijeliti zaslon?', 'Ви мене чуєте? Можу показати екран?', 1);
  perform pg_temp.turn('23ce2c72-17d4-5867-a9be-658cbae3542a', '929b5f4b-6026-53a7-bb3c-bd90736f3acf', 'Ivan', 'Čujemo. Molim sve ostale da isključe mikrofon.', 'Чуємо. Прошу всіх інших вимкнути мікрофон.', 2);
  perform pg_temp.turn('5499eb09-1bb3-5a9a-9678-a902b00bbf5d', '929b5f4b-6026-53a7-bb3c-bd90736f3acf', 'Daša', 'Ovo je plan za sljedeći tjedan. Prioritet je novi klijent.', 'Ось план на наступний тиждень. Пріоритет — новий клієнт.', 3);
  perform pg_temp.turn('abb324a8-57ca-5122-a5ba-6c7e79326346', '929b5f4b-6026-53a7-bb3c-bd90736f3acf', 'Ivan', 'Super. Tko će poslati kratak sažetak?', 'Супер. Хто надішле коротке резюме?', 4);
  perform pg_temp.turn('88047831-7589-5573-9086-1ba26b31625a', '929b5f4b-6026-53a7-bb3c-bd90736f3acf', 'Daša', 'Ja ću ga poslati danas poslije podne.', 'Я надішлю його сьогодні після обіду.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.5 · урок 31: Діловий лист і e-mail — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'b8e81d83-8ed4-5446-b36d-e6d23ee6fcd4';
  v_lesson constant uuid := '531f3eac-8358-513b-ab35-d57fe69eb64b';
  v_gid constant uuid := 'ec75057c-1f8d-51e1-9946-1ff5bbfeebca';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики ENK'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A2.5: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 31: Діловий лист і e-mail', 'Lekcija 31: Poslovno pismo i e-mail', '["Написати діловий e-mail: звертання, тема, вкладення, підпис", "Ставити короткі слова на місце: Poslat ću Vam ga…"]'::jsonb, 20, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'poslovni e-mail', v_pos);
  v_pos := pg_temp.word(v_lesson, 's poštovanjem', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srdačan pozdrav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u privitku', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predmet e-maila', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u kopiji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potvrditi primitak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'unaprijed zahvaljujem', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obratiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vezano uz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispričavam se zbog kašnjenja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'javiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stojim na raspolaganju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dodatna pitanja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potpis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'službeni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dopis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poslati ponovno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slijedom Vašeg upita', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cjenik', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '181547ff-023a-5870-b281-d8261c226e71', 'fill_in_the_blank', 'Ugovor? Poslala sam ___ ga jučer.', 'Vam', '["Vi", "Vaš", "Vam", "Vas"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '61b7b1b4-52b9-5afe-894d-e9368372345e', 'multiple_choice', 'Що означає «službeni»?', 'офіційний, службовий', '["щодо, стосовно", "офіційний, службовий", "підпис", "прайс-лист"]'::jsonb, 'A2', 2, 'PUBLISHED', 'službeni', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd4c25cb7-0779-5939-8ef5-c1b49a3dc78a', 'multiple_choice', 'Що означає «srdačan pozdrav»?', 'щиро, з найкращими побажаннями (наприкінці листа)', '["з повагою", "діловий e-mail", "офіційний, службовий", "щиро, з найкращими побажаннями (наприкінці листа)"]'::jsonb, 'A2', 3, 'PUBLISHED', 'srdačan pozdrav', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b17bd74f-b3ac-5a43-af3c-24f08ec4e3c1', 'multiple_choice', 'Що означає «poslovni e-mail»?', 'діловий e-mail', '["озватися, відповісти", "надіслати повторно", "діловий e-mail", "щиро, з найкращими побажаннями (наприкінці листа)"]'::jsonb, 'A2', 4, 'PUBLISHED', 'poslovni e-mail', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7333d868-a57a-569c-b1ed-733a355a1f86', 'multiple_choice', 'Як хорватською «підпис»?', 'potpis', '["upit", "potvrditi primitak", "potpis", "s poštovanjem"]'::jsonb, 'A2', 5, 'PUBLISHED', 'potpis', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b1531e5b-76c8-5f85-a2ef-b0eb133d2a20', 'multiple_choice', 'Як хорватською «я до ваших послуг (відповім на питання)»?', 'stojim na raspolaganju', '["srdačan pozdrav", "potpis", "poslati ponovno", "stojim na raspolaganju"]'::jsonb, 'A2', 6, 'PUBLISHED', 'stojim na raspolaganju', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9285a49d-f518-5b8a-ae14-a8f578d07fa2', 'type_answer', 'Напишіть хорватською: «озватися, відповісти»', 'javiti se', null, 'A2', 7, 'PUBLISHED', 'javiti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '60d9366a-813c-5071-9f6b-5c8b91ac3c89', 'type_answer', 'Напишіть хорватською: «у вкладенні»', 'u privitku', null, 'A2', 8, 'PUBLISHED', 'u privitku', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '50b84dcb-a1bc-5a05-86e7-f262fe714bc0', 'type_answer', 'Напишіть хорватською: «з повагою»', 's poštovanjem', null, 'A2', 9, 'PUBLISHED', 's poštovanjem', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '43c4a941-c273-5c65-b827-be774c49f60e', 'sentence_builder', 'Складіть: «У вкладенні надсилаю вам пропозицію.»', 'U privitku Vam šaljem ponudu.', '["šaljem", "U", "privitku", "Vam", "ponudu."]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c2b3fd4f-5699-55db-bdf3-052370520cfc', 'sentence_builder', 'Складіть: «Я озвуся до вас завтра.»', 'Javit ću Vam se sutra.', '["ću", "Vam", "Javit", "sutra.", "se"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c5ff0529-6293-55cc-a8e0-49991cba8ffe', 'listening', 'Прослухайте і складіть фразу', 'Ispričavam se! Poslat ću Vam ga ponovno odmah.', '["ponovno", "se!", "Poslat", "Ispričavam", "ga", "odmah.", "ću", "Vam"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'bcf819e5-838b-5b04-a384-b06ce8a31147', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'пропозицію; ціни на перевезення до Австрії; до четверга', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Клієнт залишив повідомлення на вашому робочому телефоні.", "script": [{"hr": "Dobar dan, ovdje Marija Babić iz tvrtke Adria Trans.", "ua": "Добрий день, це Марія Бабич з компанії «Адрія Транс»."}, {"hr": "Dobila sam Vašu ponudu, hvala.", "ua": "Я отримала вашу пропозицію, дякую."}, {"hr": "Možete li mi poslati i cijene za prijevoz u Austriju?", "ua": "Можете надіслати мені ще й ціни на перевезення до Австрії?"}, {"hr": "Odgovor mi treba do četvrtka.", "ua": "Відповідь мені потрібна до четверга."}], "questions": [{"q_ua": "Що отримала пані Бабич?", "options": ["пропозицію", "рахунок", "договір"], "correct": 0, "answer_turn": 1}, {"q_ua": "Про що вона просить?", "options": ["знижку", "ціни на перевезення до Австрії", "зустріч"], "correct": 1, "answer_turn": 2}, {"q_ua": "До коли потрібна відповідь?", "options": ["до понеділка", "до п’ятниці", "до четверга"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'bcf819e5-838b-5b04-a384-b06ce8a31147', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ced98b4b-c431-5fc2-ad8e-aa01e68a2b7a', 'speaking', 'Заздалегідь дякую за відповідь.', 'Unaprijed zahvaljujem na odgovoru.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '10707b57-f63e-512f-b9b1-c9b6014cf804', 'speaking', 'Перепрошую за затримку.', 'Ispričavam se zbog kašnjenja.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'd82ad693-242b-5bd1-b3e5-6c31ecde77ca', 'write_message', 'Напишіть діловий e-mail: у вкладенні надсилаєте пропозицію, просите підтвердити отримання; підпишіться.', 'Poštovani gospodine Horvat, u privitku Vam šaljem ponudu. Molim Vas da potvrdite primitak. S poštovanjem, Darja Kovalenko', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть діловий e-mail: у вкладенні надсилаєте пропозицію, просите підтвердити отримання; підпишіться.", "points": [{"ua": "звертання", "keys": [["poštovan"]]}, {"ua": "у вкладенні пропозиція", "keys": [["privitk"]]}, {"ua": "підтвердити отримання", "keys": [["primitak"], ["potvrdi"]]}, {"ua": "підпис", "keys": [["s poštovanjem"], ["pozdrav"]]}], "hints": ["Poštovani", "u privitku Vam šaljem", "molim Vas da potvrdite primitak", "S poštovanjem"], "models": ["Poštovani gospodine Horvat, u privitku Vam šaljem ponudu. Molim Vas da potvrdite primitak. S poštovanjem, Darja Kovalenko"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'd82ad693-242b-5bd1-b3e5-6c31ecde77ca', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'cdb7ba6e-a6ce-57b3-a2a0-2ab797ea2270', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Poslat ćemo Vam cijene do četvrtka. Stojimo Vam na raspolaganju.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Відповідай клієнтові, що я надішлю ціни до четверга і що я до його послуг.", "direction": "ua_hr", "points": [{"ua": "надішле ціни", "keys": [["cijen"]]}, {"ua": "до четверга", "keys": [["četvrt"]]}, {"ua": "до послуг", "keys": [["raspolaganju"]]}], "hints": [], "models": ["Poslat ćemo Vam cijene do četvrtka. Stojimo Vam na raspolaganju."], "source_ua": "Відповідай клієнтові, що я надішлю ціни до четверга і що я до його послуг."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'cdb7ba6e-a6ce-57b3-a2a0-2ab797ea2270', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('90a0465c-1c15-5395-9dab-63c6d9ccbf3b', v_lesson, 'Лист клієнтові', 'E-mail klijentu', 5311, 'A2', 'work', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('808e9a09-02c4-5abd-9f36-2ecb77a444e6', '90a0465c-1c15-5395-9dab-63c6d9ccbf3b', 'Darja', 'Ivane, kako da počnem e-mail novom klijentu?', 'Іване, як мені почати e-mail новому клієнтові?', 1);
  perform pg_temp.turn('3a680f36-5a29-53a1-8d2a-32b46031f96d', '90a0465c-1c15-5395-9dab-63c6d9ccbf3b', 'Ivan', 'Napiši „Poštovani gospodine Horvat“, ne „Bok“.', 'Напиши «Шановний пане Хорват», а не «Привіт».', 2);
  perform pg_temp.turn('2fd08937-ea0b-548c-8dde-fdb1762b2f0a', '90a0465c-1c15-5395-9dab-63c6d9ccbf3b', 'Darja', 'A kako da mu pošaljem ponudu?', 'А як надіслати йому пропозицію?', 3);
  perform pg_temp.turn('90f7a4d0-5946-5f8d-a3e0-3ee77b7b1df1', '90a0465c-1c15-5395-9dab-63c6d9ccbf3b', 'Ivan', 'Napiši: „U privitku Vam šaljem ponudu.“ Na kraju: „S poštovanjem“.', 'Напиши: «У вкладенні надсилаю вам пропозицію». Наприкінці: «З повагою».', 4);
  perform pg_temp.turn('58fcd3fd-551d-5808-b43d-f1957fadd0fc', '90a0465c-1c15-5395-9dab-63c6d9ccbf3b', 'Darja', 'Trebam li staviti šefa u kopiju?', 'Мені треба поставити шефа в копію?', 5);
  perform pg_temp.turn('e0089d7d-4125-5e65-8e56-1ffdfcfddbec', '90a0465c-1c15-5395-9dab-63c6d9ccbf3b', 'Ivan', 'Da, i zamoli klijenta da potvrdi primitak.', 'Так, і попроси клієнта підтвердити отримання.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ea4a1f58-c1f0-55c7-8248-9c6dd4fe5286', v_lesson, 'Немає вкладення', 'Nema privitka', 5312, 'A2', 'work', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('975b8590-b2c8-54a5-9d38-9828c15d6d4f', 'ea4a1f58-c1f0-55c7-8248-9c6dd4fe5286', 'Klijent', 'Dobar dan, dobio sam Vaš e-mail, ali nema privitka.', 'Добрий день, я отримав ваш лист, але немає вкладення.', 1);
  perform pg_temp.turn('e10d9849-c992-58e2-92ab-95bea864e638', 'ea4a1f58-c1f0-55c7-8248-9c6dd4fe5286', 'Darja', 'Ispričavam se! Poslat ću Vam ga ponovno odmah.', 'Перепрошую! Я надішлю вам його повторно негайно.', 2);
  perform pg_temp.turn('284d5c9f-6e4c-5e8b-83e9-3d0dd6c4e9b3', 'ea4a1f58-c1f0-55c7-8248-9c6dd4fe5286', 'Klijent', 'Hvala. Vezano uz ponudu, imam dodatna pitanja.', 'Дякую. Щодо пропозиції, у мене є додаткові питання.', 3);
  perform pg_temp.turn('3b69db5b-9ce6-52fa-969b-5f8512a80a44', 'ea4a1f58-c1f0-55c7-8248-9c6dd4fe5286', 'Darja', 'Naravno, stojim na raspolaganju.', 'Звісно, я до ваших послуг.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.5 · урок 32: Телефонна розмова на роботі — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'b8e81d83-8ed4-5446-b36d-e6d23ee6fcd4';
  v_lesson constant uuid := 'd7b6bad3-d46a-5f73-b796-dca7b1538853';
  v_gid constant uuid := 'ec75057c-1f8d-51e1-9946-1ff5bbfeebca';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики ENK'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A2.5: місце 3 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 32: Телефонна розмова на роботі', 'Lekcija 32: Telefonski razgovor na poslu', '["Ділова розмова телефоном: представитися, з’єднати, залишити повідомлення", "Короткі слова в проханнях: Možete li mi ga dati? Reći ću mu."]'::jsonb, 20, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'ovdje je', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mogu li razgovarati s', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spojiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'linija je zauzeta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trenutno nije dostupan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prenijeti poruku', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uzvratiti poziv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slabo se čuje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prekinula se veza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slovkati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'interni broj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'centrala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glasovna pošta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zapisati broj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nazvati natrag', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krivi broj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hvala na pozivu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'o čemu se radi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ostati na liniji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'telefonska sekretarica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nedostupan', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '33ab55bc-1481-5bdc-8d56-17c00beb0503', 'fill_in_the_blank', 'Možete li ___ ga dati, molim Vas?', 'mi', '["me", "mene", "mi", "moj"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b8fc5773-b1d4-5a3e-861a-b542fb6ea169', 'multiple_choice', 'Що означає «hvala na pozivu»?', 'дякую за дзвінок', '["продиктувати по літерах", "недоступний", "дякую за дзвінок", "лінія зайнята"]'::jsonb, 'A2', 2, 'PUBLISHED', 'hvala na pozivu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '52639e62-5b96-5e7a-8659-6eef02b8b8cc', 'multiple_choice', 'Що означає «prekinula se veza»?', 'зв’язок перервався', '["недоступний", "передзвонити (у відповідь)", "зв’язок перервався", "внутрішній номер (телефону)"]'::jsonb, 'A2', 3, 'PUBLISHED', 'prekinula se veza', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '274dd01b-7644-5c33-b505-19fc44b96b94', 'multiple_choice', 'Що означає «zapisati broj»?', 'записати номер', '["недоступний", "записати номер", "комутатор, приймальня", "передзвонити"]'::jsonb, 'A2', 4, 'PUBLISHED', 'zapisati broj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cef2630b-12bc-55bf-a9e4-9f0eac9ab499', 'multiple_choice', 'Як хорватською «це (говорить)…»?', 'ovdje je', '["linija je zauzeta", "nedostupan", "ovdje je", "o čemu se radi"]'::jsonb, 'A2', 5, 'PUBLISHED', 'ovdje je', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '26d4e4e9-37c7-5a9d-a710-0765fc79f44f', 'multiple_choice', 'Як хорватською «передати повідомлення»?', 'prenijeti poruku', '["zapisati broj", "prekinula se veza", "prenijeti poruku", "ovdje je"]'::jsonb, 'A2', 6, 'PUBLISHED', 'prenijeti poruku', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '340bb918-a532-5de0-92ae-0bb73b8f705f', 'type_answer', 'Напишіть хорватською: «комутатор, приймальня»', 'centrala', null, 'A2', 7, 'PUBLISHED', 'centrala', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e0779b68-87b1-5d29-a259-1bf6a09908d0', 'type_answer', 'Напишіть хорватською: «продиктувати по літерах»', 'slovkati', null, 'A2', 8, 'PUBLISHED', 'slovkati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7dafb59f-9391-50ca-b964-8e611ba61007', 'type_answer', 'Напишіть хорватською: «з’єднати»', 'spojiti', null, 'A2', 9, 'PUBLISHED', 'spojiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '26c109d8-4707-5540-8379-98e2fde94b25', 'sentence_builder', 'Складіть: «Я з’єднаю вас з відділом продажу.»', 'Spojit ću Vas s odjelom prodaje.', '["prodaje.", "odjelom", "Spojit", "s", "Vas", "ću"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b864ab07-c952-5511-bcd2-4e3aa8f143e0', 'sentence_builder', 'Складіть: «Можете говорити трохи повільніше?»', 'Možete li govoriti malo sporije?', '["Možete", "sporije?", "govoriti", "malo", "li"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae9906da-cd9a-5467-a1d9-1917b80ac5a9', 'listening', 'Прослухайте і складіть фразу', 'Naravno. Reći ću mu da Vam uzvrati poziv.', '["poziv.", "Reći", "Naravno.", "Vam", "da", "mu", "ću", "uzvrati"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'bb3889bb-5a7d-59ea-91c3-dbd6301bf05a', 'listening_dialogue', 'Прослухайте розмову', 'у бухгалтерію; 312; після обіду', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Дар’я телефонує в бухгалтерію. Послухайте розмову.", "script": [{"speaker": "Centrala", "hr": "Dobar dan, kako Vam mogu pomoći?", "ua": "Добрий день, чим можу допомогти?"}, {"speaker": "Darja", "hr": "Trebam računovodstvo, zbog moje platne liste.", "ua": "Мені потрібна бухгалтерія, щодо мого розрахункового листа."}, {"speaker": "Centrala", "hr": "Linija je zauzeta. Njihov interni broj je tristo dvanaest.", "ua": "Лінія зайнята. Їхній внутрішній номер — триста дванадцять."}, {"speaker": "Darja", "hr": "Hvala, nazvat ću ih poslije podne.", "ua": "Дякую, я подзвоню їм після обіду."}], "questions": [{"q_ua": "Куди дзвонить Дар’я?", "options": ["у бухгалтерію", "у відділ продажу", "директорові"], "correct": 0, "answer_turn": 1}, {"q_ua": "Який внутрішній номер?", "options": ["312", "213", "302"], "correct": 0, "answer_turn": 2}, {"q_ua": "Коли Дар’я подзвонить знову?", "options": ["завтра", "за п’ять хвилин", "після обіду"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'bb3889bb-5a7d-59ea-91c3-dbd6301bf05a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '625f0755-5cd7-51f8-894a-28ebb2cf5229', 'speaking', 'Чи можу я поговорити з пані Бабич?', 'Mogu li razgovarati s gospođom Babić?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '25ceac5f-a80d-5145-9cc5-6d2be7fa03ea', 'speaking', 'Можете передати їй повідомлення?', 'Možete li joj prenijeti poruku?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'aeee8770-6ecf-5ed0-a147-15cf1d7a380b', 'write_message', 'Напишіть колезі записку: дзвонила пані Бабич з «Адрія Транс», просить передзвонити до 15:00.', 'Zvala je gospođa Babić iz Adria Transa. Molim te da je nazoveš do 15 sati.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть колезі записку: дзвонила пані Бабич з «Адрія Транс», просить передзвонити до 15:00.", "points": [{"ua": "дзвонила пані Бабич", "keys": [["babić"], ["zvala"]]}, {"ua": "передзвонити", "keys": [["uzvrat"], ["nazov"], ["natrag"]]}, {"ua": "до 15:00", "keys": [["15"], ["tri"]]}], "hints": ["zvala je gospođa Babić", "iz Adria Transa", "molim te da je nazoveš", "do 15 sati"], "models": ["Zvala je gospođa Babić iz Adria Transa. Molim te da je nazoveš do 15 sati."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'aeee8770-6ecf-5ed0-a147-15cf1d7a380b', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'bb316280-3a02-5606-8e66-a11c9830d6bc', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Nazvat će Vas natrag za pet minuta jer se slabo čuje.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи секретарці, що я перетелефоную через п’ять хвилин, бо зв’язок поганий.", "direction": "ua_hr", "points": [{"ua": "перетелефонує", "keys": [["nazvat"], ["nazvati"], ["natrag"]]}, {"ua": "п’ять хвилин", "keys": [["pet minut"]]}, {"ua": "зв’язок поганий", "keys": [["čuje"], ["veza"]]}], "hints": [], "models": ["Nazvat će Vas natrag za pet minuta jer se slabo čuje."], "source_ua": "Скажи секретарці, що я перетелефоную через п’ять хвилин, бо зв’язок поганий."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'bb316280-3a02-5606-8e66-a11c9830d6bc', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8a03a451-ed01-5889-8ab0-604b3713cfed', v_lesson, 'Дзвінок у компанію', 'Poziv u tvrtku', 5321, 'A2', 'work', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('3076d69b-fbb8-5b14-b3c1-ea7782ee9767', '8a03a451-ed01-5889-8ab0-604b3713cfed', 'Tajnica', 'Tvrtka Adria Trans, izvolite.', 'Компанія «Адрія Транс», слухаю вас.', 1);
  perform pg_temp.turn('8fe341cb-db63-566d-a1a9-7786ef9e126a', '8a03a451-ed01-5889-8ab0-604b3713cfed', 'Darja', 'Dobar dan, ovdje je Darja Kovalenko. Mogu li razgovarati s gospodinom Horvatom?', 'Добрий день, це Дар’я Коваленко. Чи можу я поговорити з паном Хорватом?', 2);
  perform pg_temp.turn('9d8a3cbd-ecc5-56d6-932b-f1b4f872e3e4', '8a03a451-ed01-5889-8ab0-604b3713cfed', 'Tajnica', 'Nažalost, trenutno nije dostupan, na sastanku je. O čemu se radi?', 'На жаль, зараз недоступний, він на нараді. Про що йдеться?', 3);
  perform pg_temp.turn('4b18a14a-f406-5117-89f2-2c0663ae97df', '8a03a451-ed01-5889-8ab0-604b3713cfed', 'Darja', 'O ponudi koju sam mu poslala. Možete li mu prenijeti poruku?', 'Про пропозицію, яку я йому надіслала. Можете передати йому повідомлення?', 4);
  perform pg_temp.turn('88c9f9c6-da95-51c6-b5a2-3500cec4f843', '8a03a451-ed01-5889-8ab0-604b3713cfed', 'Tajnica', 'Naravno. Reći ću mu da Vam uzvrati poziv.', 'Звісно. Я скажу йому, щоб він вам передзвонив.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('681580a7-f33b-5bd7-863c-f20f2f497e92', v_lesson, 'Погано чути', 'Slabo se čuje', 5322, 'A2', 'work', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('3b083f53-d4c4-5561-888a-940a8952b7ef', '681580a7-f33b-5bd7-863c-f20f2f497e92', 'Ivan', 'Halo? Oprostite, slabo se čuje.', 'Алло? Перепрошую, погано чути.', 1);
  perform pg_temp.turn('eac6fb69-f2b9-5a33-bf21-ad17cf348124', '681580a7-f33b-5bd7-863c-f20f2f497e92', 'Daša', 'Možete li govoriti malo sporije?', 'Можете говорити трохи повільніше?', 2);
  perform pg_temp.turn('edac8b97-d28b-57b9-b4ac-4246ab8433d5', '681580a7-f33b-5bd7-863c-f20f2f497e92', 'Ivan', 'Trebam Vaše prezime. Možete li ga slovkati?', 'Мені потрібне ваше прізвище. Можете продиктувати його по літерах?', 3);
  perform pg_temp.turn('546a49bf-c17b-58db-9db2-8a3548148d69', '681580a7-f33b-5bd7-863c-f20f2f497e92', 'Daša', 'K-O-V-A-L-E-N-K-O. Prekinula se veza?', 'К-О-В-А-Л-Е-Н-К-О. Зв’язок перервався?', 4);
  perform pg_temp.turn('8f42517e-d7ec-57a1-b8bd-60ac4fdb6c34', '681580a7-f33b-5bd7-863c-f20f2f497e92', 'Ivan', 'Ne, tu sam. Zapisao sam, hvala na pozivu.', 'Ні, я тут. Записав, дякую за дзвінок.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.5 · урок 33: Відпустка й лікарняний — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'b8e81d83-8ed4-5446-b36d-e6d23ee6fcd4';
  v_lesson constant uuid := '0e0d07a2-2a6c-5090-ab84-3089f20a48b8';
  v_gid constant uuid := '0c68352a-803a-5410-a59b-91f2c1ddc49f';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KOND'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A2.5: місце 4 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 33: Відпустка й лікарняний', 'Lekcija 33: Godišnji i bolovanje', '["Попросити відпустку й домовитися про заміну", "Ввічливо: Bih li mogla uzeti…? Htjela bih iskoristiti…"]'::jsonb, 20, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zahtjev za godišnji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iskoristiti godišnji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dani godišnjeg', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plan godišnjih odmora', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neplaćeni dopust', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rodiljni dopust', v_pos);
  v_pos := pg_temp.word(v_lesson, 'roditeljski dopust', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otvoriti bolovanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zatvoriti bolovanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'biti na bolovanju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'javiti se bolestan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zamjenik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'primopredaja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'automatski odgovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vratiti se na posao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odobriti zahtjev', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poklapati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hitan slučaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'produženi vikend', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godišnji u dijelovima', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preostali dani', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '748ca962-d3b2-5503-ac4c-08bba20d4098', 'fill_in_the_blank', '___ li mogla uzeti slobodan petak?', 'Bih', '["Bih", "Bi", "Bismo", "Biste"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bade65a4-b487-5668-8cb5-353ffc4a0071', 'multiple_choice', 'Що означає «iskoristiti godišnji»?', 'використати відпустку', '["дні відпустки", "збігатися", "використати відпустку", "передача справ"]'::jsonb, 'A2', 2, 'PUBLISHED', 'iskoristiti godišnji', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3933abb2-38b2-53ce-ba8b-a332fc8ce8f5', 'multiple_choice', 'Що означає «zahtjev za godišnji»?', 'заява на відпустку', '["передача справ", "бути на лікарняному", "заява на відпустку", "відпустка по догляду за дитиною"]'::jsonb, 'A2', 3, 'PUBLISHED', 'zahtjev za godišnji', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4fe32f23-4220-52b8-9da8-8b62616c915d', 'multiple_choice', 'Що означає «rodiljni dopust»?', 'декретна відпустка (у пологах)', '["погодити заяву", "відкрити лікарняний", "декретна відпустка (у пологах)", "дні відпустки"]'::jsonb, 'A2', 4, 'PUBLISHED', 'rodiljni dopust', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7fd9b8b0-d81c-56b0-846b-801f3780577d', 'multiple_choice', 'Як хорватською «автовідповідь»?', 'automatski odgovor', '["roditeljski dopust", "primopredaja", "dani godišnjeg", "automatski odgovor"]'::jsonb, 'A2', 5, 'PUBLISHED', 'automatski odgovor', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '89355606-2d62-5afa-b223-5df7cf556ae4', 'multiple_choice', 'Як хорватською «повідомити, що захворів»?', 'javiti se bolestan', '["vratiti se na posao", "biti na bolovanju", "neplaćeni dopust", "javiti se bolestan"]'::jsonb, 'A2', 6, 'PUBLISHED', 'javiti se bolestan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '930e81e6-9b1c-5105-8abe-e02132c41991', 'type_answer', 'Напишіть хорватською: «збігатися»', 'poklapati se', null, 'A2', 7, 'PUBLISHED', 'poklapati se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '642c39ab-904c-5369-9128-853346568674', 'type_answer', 'Напишіть хорватською: «заступник (на час відсутності)»', 'zamjenik', null, 'A2', 8, 'PUBLISHED', 'zamjenik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f93bcce4-5d07-58ae-bade-c65c10c8926a', 'type_answer', 'Напишіть хорватською: «решта днів»', 'preostali dani', null, 'A2', 9, 'PUBLISHED', 'preostali dani', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8fab576f-3931-5ca5-9508-d15462ff4e3e', 'sentence_builder', 'Складіть: «Я відсутня до двадцятого серпня.»', 'Odsutna sam do dvadesetog kolovoza.', '["Odsutna", "kolovoza.", "sam", "do", "dvadesetog"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cb1c5220-ae32-5b8e-8edf-3a683e0ff57f', 'sentence_builder', 'Складіть: «Марко на лікарняному до п’ятниці.»', 'Marko je na bolovanju do petka.', '["petka.", "na", "Marko", "bolovanju", "je", "do"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa827041-d737-510c-866f-4f4db2d931e0', 'listening', 'Прослухайте і складіть фразу', 'Idem danas. Otvorit će mi bolovanje.', '["bolovanje.", "Otvorit", "danas.", "će", "mi", "Idem"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '3822f98e-57f8-505d-9ea6-7608abd919ae', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'до 15 липня; заступниці Даші; 202', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Автовідповідь колеги по телефону. Послухайте.", "script": [{"hr": "Dobar dan, ovdje Ivan Perić.", "ua": "Добрий день, це Іван Перич."}, {"hr": "Do petnaestog srpnja sam na godišnjem odmoru.", "ua": "До п’ятнадцятого липня я у відпустці."}, {"hr": "U hitnom slučaju nazovite moju zamjenicu, Dašu, na broj dvjesto dva.", "ua": "У невідкладному випадку телефонуйте моїй заступниці Даші на номер двісті два."}], "questions": [{"q_ua": "До коли Іван у відпустці?", "options": ["до 15 липня", "до 5 липня", "до 15 серпня"], "correct": 0, "answer_turn": 1}, {"q_ua": "Кому дзвонити в невідкладному випадку?", "options": ["шефові", "заступниці Даші", "на комутатор"], "correct": 1, "answer_turn": 2}, {"q_ua": "Який номер Даші?", "options": ["220", "212", "202"], "correct": 2, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '3822f98e-57f8-505d-9ea6-7608abd919ae', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c57aa3d3-4df7-5215-8900-e753518789db', 'speaking', 'Я хотіла б використати відпустку в серпні.', 'Htjela bih iskoristiti godišnji u kolovozu.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '44cce3d0-24f1-5c18-83ee-3e5d84d51e85', 'speaking', 'Повідомляю, що захворіла.', 'Javljam se bolesna.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '72ae82e5-9754-5c90-a60c-bb4875eb13f4', 'write_message', 'Напишіть автовідповідь: ви у відпустці до 20 серпня, у невідкладному випадку — до колеги Даші.', 'Odsutna sam do 20. kolovoza, na godišnjem odmoru. U hitnom slučaju javite se kolegici Daši.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть автовідповідь: ви у відпустці до 20 серпня, у невідкладному випадку — до колеги Даші.", "points": [{"ua": "у відпустці", "keys": [["godišnj"], ["odsutn"]]}, {"ua": "до 20 серпня", "keys": [["20"], ["dvadeset"]]}, {"ua": "колега Даша", "keys": [["daš"]]}], "hints": ["odsutna sam", "na godišnjem odmoru", "do 20. kolovoza", "u hitnom slučaju"], "models": ["Odsutna sam do 20. kolovoza, na godišnjem odmoru. U hitnom slučaju javite se kolegici Daši."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '72ae82e5-9754-5c90-a60c-bb4875eb13f4', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '032b0d9b-5a28-54d5-81fb-2f2a1e307310', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Moja kolegica je bolesna. Liječnik joj je otvorio bolovanje do srijede.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи шефові, що я захворіла і лікар відкрив мені лікарняний до середи.", "direction": "ua_hr", "points": [{"ua": "захворіла", "keys": [["bolesn"]]}, {"ua": "лікарняний", "keys": [["bolovanj"]]}, {"ua": "до середи", "keys": [["srijed"]]}], "hints": [], "models": ["Moja kolegica je bolesna. Liječnik joj je otvorio bolovanje do srijede."], "source_ua": "Скажи шефові, що я захворіла і лікар відкрив мені лікарняний до середи."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '032b0d9b-5a28-54d5-81fb-2f2a1e307310', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a6159e27-ad5d-515e-af8d-2ab1bc7ee06e', v_lesson, 'Прошу відпустку', 'Molim godišnji', 5331, 'A2', 'work', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('01a1848a-fb65-5aa6-989e-71050ed16338', 'a6159e27-ad5d-515e-af8d-2ab1bc7ee06e', 'Darja', 'Šefice, bih li mogla uzeti godišnji od petog do dvadesetog kolovoza?', 'Пані керівнице, чи могла б я взяти відпустку з п’ятого до двадцятого серпня?', 1);
  perform pg_temp.turn('5f9a9292-d263-5e9f-a884-01fcb3f71f26', 'a6159e27-ad5d-515e-af8d-2ab1bc7ee06e', 'Šefica', 'Ivan je tada na godišnjem. Poklapa li se to?', 'Іван тоді у відпустці. Це збігається?', 2);
  perform pg_temp.turn('4f70f4d7-9aac-556c-9af8-99423fe441d1', 'a6159e27-ad5d-515e-af8d-2ab1bc7ee06e', 'Darja', 'Djelomično. Mogla bih krenuti tjedan kasnije.', 'Частково. Я могла б почати на тиждень пізніше.', 3);
  perform pg_temp.turn('9027c324-685f-54a0-bf60-264eb5789f37', 'a6159e27-ad5d-515e-af8d-2ab1bc7ee06e', 'Šefica', 'Dobro, odobrit ću zahtjev. Tko će ti biti zamjenik?', 'Добре, я погоджу заяву. Хто тебе заступатиме?', 4);
  perform pg_temp.turn('e02582e6-814f-5c33-be93-d85af99fa71c', 'a6159e27-ad5d-515e-af8d-2ab1bc7ee06e', 'Darja', 'Daša. Napravit ću s njom primopredaju i uključiti automatski odgovor.', 'Даша. Я передам їй справи й увімкну автовідповідь.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b5b1477b-4b6a-54e0-84a7-be89bf1dd927', v_lesson, 'Захворіла', 'Bolesna sam', 5332, 'A2', 'work', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('5fe72b7a-98e7-5340-aa25-a7091b09a368', 'b5b1477b-4b6a-54e0-84a7-be89bf1dd927', 'Daša', 'Dobro jutro, javljam se bolesna. Imam temperaturu.', 'Доброго ранку, повідомляю, що захворіла. У мене температура.', 1);
  perform pg_temp.turn('8afee9b7-61e8-51f1-b5d6-70b8063013ae', 'b5b1477b-4b6a-54e0-84a7-be89bf1dd927', 'Šef', 'Žao mi je. Jesi li bila kod liječnika?', 'Мені шкода. Ти була в лікаря?', 2);
  perform pg_temp.turn('3d0778ed-1794-59a3-a8ff-c4da34113179', 'b5b1477b-4b6a-54e0-84a7-be89bf1dd927', 'Daša', 'Idem danas. Otvorit će mi bolovanje.', 'Іду сьогодні. Мені відкриють лікарняний.', 3);
  perform pg_temp.turn('ace52c11-929b-5202-97a6-20cd19cee21d', 'b5b1477b-4b6a-54e0-84a7-be89bf1dd927', 'Šef', 'U redu. Pošalji mi doznaku kad je dobiješ.', 'Гаразд. Надішли мені довідку, коли отримаєш.', 4);
  perform pg_temp.turn('ae3f7283-449d-5dd0-8d23-25c6942b5242', 'b5b1477b-4b6a-54e0-84a7-be89bf1dd927', 'Daša', 'Hoću. Javit ću Vam se kad zatvorim bolovanje.', 'Добре. Я повідомлю вас, коли закрию лікарняний.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.5 · урок 34: Зарплата: бруто, нето, податки — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'b8e81d83-8ed4-5446-b36d-e6d23ee6fcd4';
  v_lesson constant uuid := 'b9bcea21-08a3-56cf-be72-edf6b6c7b03f';
  v_gid constant uuid := 'ec75057c-1f8d-51e1-9946-1ff5bbfeebca';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики ENK'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A2.5: місце 5 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 34: Зарплата: бруто, нето, податки', 'Lekcija 34: Plaća: bruto, neto i porezi', '["Зрозуміти розрахунковий лист: бруто, нето, внески, податок", "Попросити пояснення й підвищення: Biste li mi objasnili…?"]'::jsonb, 20, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'bruto plaća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neto plaća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'porez na dohodak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mirovinski doprinos', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osobni odbitak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uzdržavani član', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sjesti na račun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obračun plaće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dodatak za noćni rad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povišica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nagrada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'topli obrok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'putni troškovi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'porezna kartica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godišnja porezna prijava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povrat poreza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oporezivati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razlika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'objasniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stavka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neoporeziv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'akontacija poreza', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '9bd4a26b-952c-5950-8280-03dfeb02b39d', 'fill_in_the_blank', 'Platnu listu? Računovotkinja ___ ju je već poslala.', 'mi', '["me", "moj", "mi", "mene"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b58764b-46ad-5677-9fa5-04326561ba42', 'multiple_choice', 'Що означає «akontacija poreza»?', 'авансовий платіж податку', '["оподатковувати", "зарплата брутто (до податків)", "авансовий платіж податку", "підвищення зарплати"]'::jsonb, 'A2', 2, 'PUBLISHED', 'akontacija poreza', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e54ff538-a472-5c16-a854-aba96bd36411', 'multiple_choice', 'Що означає «stavka»?', 'пункт, позиція (у документі)', '["річна податкова декларація", "доплата за нічну роботу", "пункт, позиція (у документі)", "повернення податку"]'::jsonb, 'A2', 3, 'PUBLISHED', 'stavka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b83390f6-a209-5b7f-a35e-120c2351e994', 'multiple_choice', 'Що означає «mirovinski doprinos»?', 'пенсійний внесок', '["зарплата нетто («на руки»)", "компенсація за харчування", "пенсійний внесок", "авансовий платіж податку"]'::jsonb, 'A2', 4, 'PUBLISHED', 'mirovinski doprinos', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8793015-ab00-5dae-b9de-de573cb582dd', 'multiple_choice', 'Як хорватською «неоподатковувана сума (особиста знижка)»?', 'osobni odbitak', '["porezna kartica", "topli obrok", "neto plaća", "osobni odbitak"]'::jsonb, 'A2', 5, 'PUBLISHED', 'osobni odbitak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8169e867-b208-5ed6-86bd-aa525458d3c2', 'multiple_choice', 'Як хорватською «різниця»?', 'razlika', '["neto plaća", "neoporeziv", "topli obrok", "razlika"]'::jsonb, 'A2', 6, 'PUBLISHED', 'razlika', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '50b738bd-e622-5e8f-be67-f326311fc76e', 'type_answer', 'Напишіть хорватською: «премія, винагорода»', 'nagrada', null, 'A2', 7, 'PUBLISHED', 'nagrada', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3261c41d-dc28-5d0f-b2a4-3e3d49e11d9b', 'type_answer', 'Напишіть хорватською: «оподатковувати»', 'oporezivati', null, 'A2', 8, 'PUBLISHED', 'oporezivati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a7ccb839-577d-55e9-afd1-682e2ff40d18', 'type_answer', 'Напишіть хорватською: «проїзні витрати (компенсація)»', 'putni troškovi', null, 'A2', 9, 'PUBLISHED', 'putni troškovi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd352b9a5-46e6-5b40-b455-8347eec38433', 'sentence_builder', 'Складіть: «Зарплата ще не надійшла на рахунок.»', 'Plaća još nije sjela na račun.', '["još", "račun.", "Plaća", "sjela", "nije", "na"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '154e3aff-9948-5a39-b0c2-12ef8c92c30d', 'sentence_builder', 'Складіть: «Можете пояснити мені цей пункт?»', 'Možete li mi objasniti ovu stavku?', '["stavku?", "Možete", "li", "ovu", "mi", "objasniti"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dabefa22-3256-510d-8dfc-e1519af6cfe5', 'listening', 'Прослухайте і складіть фразу', 'Deset posto. Preuzeo sam i nove zadatke.', '["posto.", "Preuzeo", "sam", "zadatke.", "Deset", "nove", "i"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '01bfe5d2-ab9f-52bd-addc-9c6071fb1f25', 'listening_dialogue', 'Прослухайте оголошення', '10 листопада; різдвяну премію; у бухгалтерію', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Внутрішнє оголошення для працівників компанії.", "script": [{"hr": "Poštovani zaposlenici, plaća za listopad bit će isplaćena desetog studenog.", "ua": "Шановні працівники, зарплату за жовтень виплатять десятого листопада."}, {"hr": "Svi zaposlenici dobit će i božićnicu u prosincu.", "ua": "Усі працівники отримають ще й різдвяну премію в грудні."}, {"hr": "Ako imate pitanja o obračunu, javite se u računovodstvo.", "ua": "Якщо маєте питання щодо нарахувань, звертайтеся до бухгалтерії."}], "questions": [{"q_ua": "Коли виплатять зарплату за жовтень?", "options": ["10 листопада", "1 листопада", "15 жовтня"], "correct": 0, "answer_turn": 0}, {"q_ua": "Що отримають у грудні?", "options": ["підвищення", "різдвяну премію", "вихідний"], "correct": 1, "answer_turn": 1}, {"q_ua": "Куди звертатися з питаннями?", "options": ["до директора", "у відділ кадрів", "у бухгалтерію"], "correct": 2, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '01bfe5d2-ab9f-52bd-addc-9c6071fb1f25', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9765d681-a079-5417-a6b9-e039836e63eb', 'speaking', 'Яка в мене нетто-зарплата?', 'Kolika je moja neto plaća?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd1869ed8-24f9-5677-9bf1-4c02faa26a8e', 'speaking', 'Я хотіла б поговорити про підвищення.', 'Htjela bih razgovarati o povišici.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'ce3b37aa-0f0d-5086-b127-f12de940bc18', 'write_message', 'Напишіть у бухгалтерію: у вас двоє дітей, і ви хочете змінити податкову картку; спитайте, які документи принести.', 'Poštovani, imam dvoje djece i htjela bih promijeniti poreznu karticu. Koje dokumente trebam donijeti?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у бухгалтерію: у вас двоє дітей, і ви хочете змінити податкову картку; спитайте, які документи принести.", "points": [{"ua": "двоє дітей", "keys": [["dvoje"]]}, {"ua": "податкова картка", "keys": [["porezn"]]}, {"ua": "які документи", "keys": [["dokument"]]}], "hints": ["imam dvoje djece", "promijeniti poreznu karticu", "koje dokumente trebam donijeti?"], "models": ["Poštovani, imam dvoje djece i htjela bih promijeniti poreznu karticu. Koje dokumente trebam donijeti?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'ce3b37aa-0f0d-5086-b127-f12de940bc18', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '164ac45b-1070-524a-b57d-adb8fe84ffeb', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Zašto je njegova neto plaća ovaj mjesec manja?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай бухгалтерку, чому моя зарплата нетто цього місяця менша.", "direction": "ua_hr", "points": [{"ua": "нетто-зарплата", "keys": [["neto"], ["plać"]]}, {"ua": "менша", "keys": [["manj"]]}, {"ua": "цього місяця", "keys": [["mjesec"]]}], "hints": [], "models": ["Zašto je njegova neto plaća ovaj mjesec manja?"], "source_ua": "Спитай бухгалтерку, чому моя зарплата нетто цього місяця менша."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '164ac45b-1070-524a-b57d-adb8fe84ffeb', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f00297e8-db6e-579a-93a5-2a51fb5a5f56', v_lesson, 'Розрахунковий лист', 'Platna lista', 5341, 'A2', 'work', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('4b8b8670-f4d2-5d49-bdb1-b9811143fa5d', 'f00297e8-db6e-579a-93a5-2a51fb5a5f56', 'Darja', 'Dobar dan, imam pitanje o platnoj listi. Biste li mi objasnili ovu stavku?', 'Добрий день, у мене питання щодо розрахункового листа. Чи не пояснили б ви цей пункт?', 1);
  perform pg_temp.turn('ef3d2e90-eefb-594c-8b28-9f7c6b09eb5f', 'f00297e8-db6e-579a-93a5-2a51fb5a5f56', 'Računovotkinja', 'To je mirovinski doprinos. On se odbija od bruto plaće.', 'Це пенсійний внесок. Його віднімають від брутто-зарплати.', 2);
  perform pg_temp.turn('3d812428-8002-590b-93dd-b6d8e786d247', 'f00297e8-db6e-579a-93a5-2a51fb5a5f56', 'Darja', 'A zašto mi je neto plaća manja nego prošli mjesec?', 'А чому моя нетто-зарплата менша, ніж минулого місяця?', 3);
  perform pg_temp.turn('b1876b7a-36ca-575d-a618-1c1e5fce79c4', 'f00297e8-db6e-579a-93a5-2a51fb5a5f56', 'Računovotkinja', 'Prošli mjesec ste imali dodatak za noćni rad.', 'Минулого місяця у вас була доплата за нічну роботу.', 4);
  perform pg_temp.turn('fbe94cb6-1fd5-5145-a290-a4b8ddcf64e4', 'f00297e8-db6e-579a-93a5-2a51fb5a5f56', 'Darja', 'Razumijem. Imam dvoje djece. Mogu li imati veći osobni odbitak?', 'Зрозуміло. У мене двоє дітей. Чи можу я мати більшу неоподатковувану суму?', 5);
  perform pg_temp.turn('921f50e2-0e2b-5e50-b6b9-dacac3fc6a59', 'f00297e8-db6e-579a-93a5-2a51fb5a5f56', 'Računovotkinja', 'Možete. Donesite nam njihove podatke i promijenit ćemo poreznu karticu.', 'Можете. Принесіть нам їхні дані, і ми змінимо податкову картку.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3deb423c-490e-5967-85c0-df41c37f3091', v_lesson, 'Підвищення', 'Povišica', 5342, 'A2', 'work', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('3502038b-2bb6-55d4-a6ed-171f656587c1', '3deb423c-490e-5967-85c0-df41c37f3091', 'Marko', 'Šefe, radim ovdje dvije godine. Htio bih razgovarati o povišici.', 'Шефе, я працюю тут два роки. Я хотів би поговорити про підвищення зарплати.', 1);
  perform pg_temp.turn('e8fb1227-e043-55b5-aa87-15244f019ebb', '3deb423c-490e-5967-85c0-df41c37f3091', 'Šef', 'Koliko biste htjeli?', 'Скільки ви хотіли б?', 2);
  perform pg_temp.turn('267fa11f-975a-5541-925a-2b0daa7853f4', '3deb423c-490e-5967-85c0-df41c37f3091', 'Marko', 'Deset posto. Preuzeo sam i nove zadatke.', 'Десять відсотків. Я взяв на себе й нові завдання.', 3);
  perform pg_temp.turn('884cab7b-3e57-5f55-b7bd-d49f146745de', '3deb423c-490e-5967-85c0-df41c37f3091', 'Šef', 'Mogu Vam dati pet posto i nagradu na kraju godine.', 'Можу дати вам п’ять відсотків і премію наприкінці року.', 4);
  perform pg_temp.turn('b0eec961-9939-5043-ad67-f6b7f40176b4', '3deb423c-490e-5967-85c0-df41c37f3091', 'Marko', 'Dobro, to mi odgovara. Hvala.', 'Добре, мені це підходить. Дякую.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.5 · урок 35: Звільнення й нова робота — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'b8e81d83-8ed4-5446-b36d-e6d23ee6fcd4';
  v_lesson constant uuid := '3ceb812b-6a68-5204-beba-52e0cb3031ad';
  v_gid constant uuid := '0b2de584-05a6-5570-a129-366fcb94766d';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики VID'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A2.5: місце 6 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 35: Звільнення й нова робота', 'Lekcija 35: Otkaz i novi posao', '["Поговорити про звільнення, договір і строк попередження", "Розрізняти вид: davati / dati otkaz, tražiti / naći posao"]'::jsonb, 20, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'dobiti otkaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poslovno uvjetovani otkaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sporazumni raskid', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otpremnina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radni staž', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potvrda o zaposlenju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naknada za nezaposlenost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smanjenje broja radnika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'istek ugovora', v_pos);
  v_pos := pg_temp.word(v_lesson, 'produžiti ugovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponuda za posao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prihvatiti ponudu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odbiti ponudu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poslodavac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sindikat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radno pravo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'inspektorat rada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'davati otkaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nastaviti dalje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prilika', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '9087a04e-d746-5ea0-b8b9-034700b1e9ca', 'fill_in_the_blank', 'Nakon dva mjeseca traženja konačno sam ___ posao.', 'našla', '["tražila", "nalazim", "našla", "nalazila"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae8e4e02-fea4-5bcc-8664-8e7feaee11bb', 'multiple_choice', 'Що означає «odbiti ponudu»?', 'відхилити пропозицію', '["рухатися далі", "відхилити пропозицію", "звільнення з економічних причин", "трудовий стаж"]'::jsonb, 'A2', 2, 'PUBLISHED', 'odbiti ponudu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b3fa1fb9-c632-5abd-985f-026e53755d3d', 'multiple_choice', 'Що означає «sporazumni raskid»?', 'розірвання договору за згодою сторін', '["довідка з місця роботи", "скорочення працівників", "рухатися далі", "розірвання договору за згодою сторін"]'::jsonb, 'A2', 3, 'PUBLISHED', 'sporazumni raskid', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5a30bc96-8ec5-5f6a-a7f2-bc88c074c9d9', 'multiple_choice', 'Що означає «istek ugovora»?', 'закінчення договору', '["пропозиція роботи", "профспілка", "інспекція праці", "закінчення договору"]'::jsonb, 'A2', 4, 'PUBLISHED', 'istek ugovora', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '787d6bf8-403c-567c-9325-17b2d265c599', 'multiple_choice', 'Як хорватською «трудовий стаж»?', 'radni staž', '["davati otkaz", "istek ugovora", "radni staž", "nastaviti dalje"]'::jsonb, 'A2', 5, 'PUBLISHED', 'radni staž', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '97253691-c749-5a76-a12a-28a4b554bb1f', 'multiple_choice', 'Як хорватською «звільнятися (подавати заяву), звільняти»?', 'davati otkaz', '["istek ugovora", "inspektorat rada", "davati otkaz", "nastaviti dalje"]'::jsonb, 'A2', 6, 'PUBLISHED', 'davati otkaz', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '849af643-e877-5ba5-8249-3fc9d1f874f8', 'type_answer', 'Напишіть хорватською: «нагода, можливість»', 'prilika', null, 'A2', 7, 'PUBLISHED', 'prilika', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6888e8bd-1870-5927-a218-be77c43e208c', 'type_answer', 'Напишіть хорватською: «роботодавець»', 'poslodavac', null, 'A2', 8, 'PUBLISHED', 'poslodavac', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3385624c-56bb-530b-bac9-3074fe2e710f', 'type_answer', 'Напишіть хорватською: «трудове право»', 'radno pravo', null, 'A2', 9, 'PUBLISHED', 'radno pravo', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ea905260-bd7c-5b83-b842-5dd927492795', 'sentence_builder', 'Складіть: «Я прийняла пропозицію.»', 'Prihvatila sam ponudu.', '["sam", "Prihvatila", "ponudu."]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7f43b080-cf25-5439-997e-38f96ae5e652', 'sentence_builder', 'Складіть: «Строк попередження залежить від стажу.»', 'Otkazni rok ovisi o radnom stažu.', '["o", "stažu.", "Otkazni", "radnom", "rok", "ovisi"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '21d2905f-ee62-5e40-b953-0e6520e1705d', 'listening', 'Прослухайте і складіть фразу', 'Dobila sam ponudu u Splitu.', '["Dobila", "sam", "ponudu", "Splitu.", "u"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '2cb7cd04-d2ff-5b17-90be-f1a26f0beb29', 'listening_dialogue', 'Прослухайте новину', 'скорочення працівників; 120; більшої вихідної допомоги', 'A2', 'PUBLISHED', '{"kind": "news", "situation_ua": "Ви чуєте новину на радіо про місцеву фабрику.", "script": [{"hr": "Tvornica namještaja u Vinkovcima najavila je smanjenje broja radnika.", "ua": "Меблева фабрика у Вінковцях оголосила скорочення працівників."}, {"hr": "Otkaz će dobiti sto dvadeset radnika do kraja godine.", "ua": "До кінця року звільнять сто двадцять працівників."}, {"hr": "Sindikat traži veće otpremnine i pomoć u traženju novog posla.", "ua": "Профспілка вимагає більшої вихідної допомоги й допомоги в пошуку нової роботи."}], "questions": [{"q_ua": "Що оголосила фабрика?", "options": ["скорочення працівників", "нові вакансії", "підвищення зарплат"], "correct": 0, "answer_turn": 0}, {"q_ua": "Скільки людей звільнять?", "options": ["20", "120", "200"], "correct": 1, "answer_turn": 1}, {"q_ua": "Чого вимагає профспілка?", "options": ["нового директора", "коротшого робочого дня", "більшої вихідної допомоги"], "correct": 2, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '2cb7cd04-d2ff-5b17-90be-f1a26f0beb29', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '10620fd0-d7aa-5308-b7d1-0490ddc30156', 'speaking', 'Мене звільнили.', 'Dobio sam otkaz.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cf7fb6df-8077-55dc-9a58-f7b428ca949b', 'speaking', 'Мені не продовжили договір.', 'Nisu mi produžili ugovor.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '4f0f94a7-b51a-5cc4-b87a-a6415b32b1cc', 'write_message', 'Напишіть новому роботодавцеві: дякуєте за пропозицію, приймаєте її й можете почати 1 липня.', 'Poštovani, zahvaljujem na ponudi i rado je prihvaćam. Mogu početi 1. srpnja.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть новому роботодавцеві: дякуєте за пропозицію, приймаєте її й можете почати 1 липня.", "points": [{"ua": "дякуєте", "keys": [["hval"], ["zahvalj"]]}, {"ua": "приймаєте пропозицію", "keys": [["prihvać"]]}, {"ua": "почати 1 липня", "keys": [["srpnj"], ["1."]]}], "hints": ["zahvaljujem na ponudi", "prihvaćam", "mogu početi 1. srpnja"], "models": ["Poštovani, zahvaljujem na ponudi i rado je prihvaćam. Mogu početi 1. srpnja."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '4f0f94a7-b51a-5cc4-b87a-a6415b32b1cc', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'cdf497b6-95c0-5174-a6bb-01f8c9ab7338', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Ima li pravo na naknadu za nezaposlenost nakon isteka ugovora?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай у службовця, чи маю я право на допомогу з безробіття після закінчення договору.", "direction": "ua_hr", "points": [{"ua": "допомога з безробіття", "keys": [["naknad"]]}, {"ua": "закінчення договору", "keys": [["ugovor"]]}], "hints": [], "models": ["Ima li pravo na naknadu za nezaposlenost nakon isteka ugovora?"], "source_ua": "Спитай у службовця, чи маю я право на допомогу з безробіття після закінчення договору."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'cdf497b6-95c0-5174-a6bb-01f8c9ab7338', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('14d9a946-c3e1-58cf-bff8-0c2cca867149', v_lesson, 'Погана новина', 'Loša vijest', 5351, 'A2', 'work', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('bf57f444-0ed8-5c93-a94a-2dc0830dd3da', '14d9a946-c3e1-58cf-bff8-0c2cca867149', 'Marko', 'Darja, dobio sam otkaz.', 'Дар’є, мене звільнили.', 1);
  perform pg_temp.turn('e58aa4b7-3ff1-5a6c-85ee-cc2c25b54099', '14d9a946-c3e1-58cf-bff8-0c2cca867149', 'Darja', 'Što? Zašto?', 'Що? Чому?', 2);
  perform pg_temp.turn('dc53126c-78a3-5bdc-9c37-3d77f9a67b09', '14d9a946-c3e1-58cf-bff8-0c2cca867149', 'Marko', 'Tvrtka ima smanjenje broja radnika. Poslovno uvjetovani otkaz.', 'У компанії скорочення працівників. Звільнення з економічних причин.', 3);
  perform pg_temp.turn('8e91a5a4-f59a-57d6-8c65-9bd04498333e', '14d9a946-c3e1-58cf-bff8-0c2cca867149', 'Darja', 'Imaš li pravo na otpremninu?', 'Ти маєш право на вихідну допомогу?', 4);
  perform pg_temp.turn('0dd39c93-7b4e-5d36-9467-4ad1c77bac0f', '14d9a946-c3e1-58cf-bff8-0c2cca867149', 'Marko', 'Imam, radio sam šest godina. I otkazni rok je mjesec dana.', 'Маю, я працював шість років. І строк попередження — місяць.', 5);
  perform pg_temp.turn('ab210d79-1365-596e-b6cb-9dad1c98f6dc', '14d9a946-c3e1-58cf-bff8-0c2cca867149', 'Darja', 'Prijavi se na Zavod za naknadu. I samo nastavi dalje.', 'Стань на облік у службі зайнятості для допомоги. І просто рухайся далі.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a4f83775-7879-50fb-815e-4ff8891ebd65', v_lesson, 'Нова пропозиція', 'Nova ponuda', 5352, 'A2', 'work', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('bdb6f6ef-c3d7-5f35-9653-a0f231c9c187', 'a4f83775-7879-50fb-815e-4ff8891ebd65', 'Daša', 'Ugovor mi ističe u lipnju, a nisu mi ga produžili.', 'Мій договір закінчується в червні, а мені його не продовжили.', 1);
  perform pg_temp.turn('e8d5462b-ae85-58e5-a509-9b3ac08c36bc', 'a4f83775-7879-50fb-815e-4ff8891ebd65', 'Ivan', 'Žao mi je. Tražiš li novi posao?', 'Мені шкода. Ти шукаєш нову роботу?', 2);
  perform pg_temp.turn('efef8045-bfc2-5824-a7d7-67bbab5700fd', 'a4f83775-7879-50fb-815e-4ff8891ebd65', 'Daša', 'Tražila sam i našla sam! Dobila sam ponudu u Splitu.', 'Шукала й знайшла! Я отримала пропозицію в Спліті.', 3);
  perform pg_temp.turn('d4c0bdfb-5dfd-55ab-9e6b-88b8b656fe78', 'a4f83775-7879-50fb-815e-4ff8891ebd65', 'Ivan', 'Odlično! Hoćeš li prihvatiti ponudu?', 'Чудово! Приймеш пропозицію?', 4);
  perform pg_temp.turn('4c3ebe79-bd7a-5938-8d0f-65950cb24f89', 'a4f83775-7879-50fb-815e-4ff8891ebd65', 'Daša', 'Hoću. Novi poslodavac nudi ugovor na neodređeno. To je dobra prilika.', 'Так. Новий роботодавець пропонує безстроковий договір. Це гарна нагода.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.5 · урок 36: Власна справа: obrt — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'b8e81d83-8ed4-5446-b36d-e6d23ee6fcd4';
  v_lesson constant uuid := 'd9c5c952-3ae5-521d-9ccb-c22ccaeb8aab';
  v_gid constant uuid := '0c68352a-803a-5410-a59b-91f2c1ddc49f';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KOND'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A2.5: місце 7 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 36: Власна справа: obrt', 'Lekcija 36: Vlastiti posao: obrt', '["Розпитати, як відкрити obrt: реєстрація, податки, бухгалтер", "Говорити про плани й умови: Otvorila bih…, Kad bih imala…"]'::jsonb, 20, 'PUBLISHED', 7);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'obrt', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obrtnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otvoriti obrt', v_pos);
  v_pos := pg_temp.word(v_lesson, 'paušalni obrt', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obrtni registar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'djelatnost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sjedište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poslovni račun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fiskalizacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izdati račun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'PDV', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prihod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trošak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'knjigovodstveni servis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poduzetnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potpora', v_pos);
  v_pos := pg_temp.word(v_lesson, 'samozapošljavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poslovni plan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rizik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'isplatiti se', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '6d6d9861-aa65-5870-b54a-438b9c5ce9df', 'fill_in_the_blank', 'Kad ___ imala više vremena, otvorila bih obrt.', 'bih', '["bismo", "biste", "bi", "bih"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c590fe11-3597-5563-8482-b476fd44726b', 'multiple_choice', 'Що означає «isplatiti se»?', 'окупитися, бути вигідним', '["окупитися, бути вигідним", "витрата", "обрт на фіксованому податку", "ризик"]'::jsonb, 'A2', 2, 'PUBLISHED', 'isplatiti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5a5629f4-5701-523e-a387-802078724c55', 'multiple_choice', 'Що означає «poslovni račun»?', 'бізнес-рахунок', '["бізнес-рахунок", "вид діяльності", "грант, підтримка", "окупитися, бути вигідним"]'::jsonb, 'A2', 3, 'PUBLISHED', 'poslovni račun', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '84169ff3-b904-572d-b153-8477fec9e06d', 'multiple_choice', 'Що означає «otvoriti obrt»?', 'відкрити обрт', '["окупитися, бути вигідним", "відкрити обрт", "витрата", "бізнес-план"]'::jsonb, 'A2', 4, 'PUBLISHED', 'otvoriti obrt', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e6008b64-edd4-5ee9-98c7-95baefffd46f', 'multiple_choice', 'Як хорватською «ПДВ»?', 'PDV', '["PDV", "poslovni plan", "izdati račun", "prihod"]'::jsonb, 'A2', 5, 'PUBLISHED', 'PDV', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1b85fcb2-e6e8-571c-af89-9cc10da92f3a', 'multiple_choice', 'Як хорватською «прибуток»?', 'dobit', '["poslovni plan", "otvoriti obrt", "dobit", "knjigovodstveni servis"]'::jsonb, 'A2', 6, 'PUBLISHED', 'dobit', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '699bb786-fdbf-5bcc-ae97-ad8acf0b2d03', 'type_answer', 'Напишіть хорватською: «ремісник; власник обрту (підприємець)»', 'obrtnik', null, 'A2', 7, 'PUBLISHED', 'obrtnik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fcacf45a-d800-582e-97e3-ed8e9e08a602', 'type_answer', 'Напишіть хорватською: «дохід»', 'prihod', null, 'A2', 8, 'PUBLISHED', 'prihod', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '04c311ed-762d-5137-8813-ec137ecc3252', 'type_answer', 'Напишіть хорватською: «ризик»', 'rizik', null, 'A2', 9, 'PUBLISHED', 'rizik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ccaf97cc-1a96-532a-8295-c61cf291d08b', 'sentence_builder', 'Складіть: «Кожному покупцеві треба виписати рахунок.»', 'Svakom kupcu treba izdati račun.', '["račun.", "kupcu", "Svakom", "izdati", "treba"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '32dd3056-4f9a-573e-9415-8d6f37fb8ec1', 'sentence_builder', 'Складіть: «Власна справа — це завжди ризик.»', 'Vlastiti posao je uvijek rizik.', '["rizik.", "uvijek", "je", "posao", "Vlastiti"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '71f8720d-3e4e-513c-9269-fd8ab53cc1b9', 'listening', 'Прослухайте і складіть фразу', 'Morate, i račun mora biti fiskaliziran.', '["Morate,", "mora", "račun", "biti", "i", "fiskaliziran."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '42148f4e-4c60-5776-b3e7-dcec75275238', 'listening_dialogue', 'Прослухайте оголошення', 'безкоштовно; писати бізнес-план і отримати грант; на сайті Ремісничої палати', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Реклама семінару для підприємців на радіо.", "script": [{"hr": "Želite otvoriti obrt, a ne znate kako?", "ua": "Хочете відкрити обрт, але не знаєте як?"}, {"hr": "Dođite na besplatnu radionicu za buduće poduzetnike u srijedu u šesnaest sati.", "ua": "Приходьте на безкоштовний воркшоп для майбутніх підприємців у середу о шістнадцятій."}, {"hr": "Naučit ćete kako napisati poslovni plan i dobiti potporu.", "ua": "Ви дізнаєтеся, як написати бізнес-план і отримати грант."}, {"hr": "Prijave na stranici Obrtničke komore.", "ua": "Реєстрація на сайті Ремісничої палати."}], "questions": [{"q_ua": "Скільки коштує воркшоп?", "options": ["безкоштовно", "20 євро", "50 євро"], "correct": 0, "answer_turn": 1}, {"q_ua": "Чого навчать?", "options": ["вести бухгалтерію", "писати бізнес-план і отримати грант", "шити одяг"], "correct": 1, "answer_turn": 2}, {"q_ua": "Де зареєструватися?", "options": ["у службі зайнятості", "по телефону", "на сайті Ремісничої палати"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '42148f4e-4c60-5776-b3e7-dcec75275238', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8b265c52-d753-5e87-8926-3a1cd1aaefec', 'speaking', 'Я хотіла б відкрити обрт.', 'Htjela bih otvoriti obrt.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd26c195b-6aa7-52f8-aca9-559ae5754f9c', 'speaking', 'Мені потрібен бізнес-рахунок у банку.', 'Trebam poslovni račun u banci.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '653d876d-9059-5505-80ed-497513e5c674', 'write_message', 'Напишіть у бухгалтерську фірму: ви хочете відкрити обрт для шиття й питаєте, скільки коштують їхні послуги на місяць.', 'Poštovani, htjela bih otvoriti obrt za šivanje. Koliko koštaju vaše usluge mjesečno?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у бухгалтерську фірму: ви хочете відкрити обрт для шиття й питаєте, скільки коштують їхні послуги на місяць.", "points": [{"ua": "відкрити обрт", "keys": [["obrt"]]}, {"ua": "для шиття", "keys": [["šivan"]]}, {"ua": "скільки коштують послуги", "keys": [["košta"], ["cijen"]]}], "hints": ["htjela bih otvoriti obrt", "za šivanje", "koliko koštaju vaše usluge mjesečno?"], "models": ["Poštovani, htjela bih otvoriti obrt za šivanje. Koliko koštaju vaše usluge mjesečno?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '653d876d-9059-5505-80ed-497513e5c674', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '35667583-1a15-5994-ba39-4cd2bfdf0155', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Može li dobiti potporu za samozapošljavanje ako je stranac s privremenom zaštitom?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай, чи можна отримати грант на самозайнятість, якщо я іноземець з тимчасовим захистом.", "direction": "ua_hr", "points": [{"ua": "грант", "keys": [["potpor"]]}, {"ua": "самозайнятість", "keys": [["samozapošljavanj"]]}, {"ua": "тимчасовий захист", "keys": [["zaštit"]]}], "hints": [], "models": ["Može li dobiti potporu za samozapošljavanje ako je stranac s privremenom zaštitom?"], "source_ua": "Спитай, чи можна отримати грант на самозайнятість, якщо я іноземець з тимчасовим захистом."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '35667583-1a15-5994-ba39-4cd2bfdf0155', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c254a28a-93ef-5d68-bd89-118ada686b5d', v_lesson, 'Хочу свою справу', 'Želim svoj posao', 5361, 'A2', 'work', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('a1013ca6-2b73-53da-a252-2c3b561ffbdb', 'c254a28a-93ef-5d68-bd89-118ada686b5d', 'Darja', 'Ivana, htjela bih otvoriti obrt za šivanje. Kako se to radi?', 'Івано, я хотіла б відкрити обрт для шиття. Як це робиться?', 1);
  perform pg_temp.turn('88088082-b3ef-568d-bddb-424ca75799e1', 'c254a28a-93ef-5d68-bd89-118ada686b5d', 'Ivana', 'Prvo odabereš djelatnost i upišeš obrt u obrtni registar.', 'Спочатку обираєш вид діяльності й вписуєш обрт до реєстру.', 2);
  perform pg_temp.turn('56900a05-3bfe-501c-94a5-af53895894c2', 'c254a28a-93ef-5d68-bd89-118ada686b5d', 'Darja', 'Je li paušalni obrt bolji za početak?', 'Обрт на фіксованому податку кращий для початку?', 3);
  perform pg_temp.turn('8d4087fb-1559-5714-a286-332eae5ac6bc', 'c254a28a-93ef-5d68-bd89-118ada686b5d', 'Ivana', 'Jest, jednostavniji je. Ali trebaš poslovni račun i fiskalizaciju.', 'Так, він простіший. Але тобі потрібен бізнес-рахунок і фіскалізація.', 4);
  perform pg_temp.turn('72a4a957-e4ce-53cd-88b4-46c6bdc71344', 'c254a28a-93ef-5d68-bd89-118ada686b5d', 'Darja', 'Kad bih imala malo više novca, unajmila bih i prostor.', 'Якби я мала трохи більше грошей, я б ще й орендувала приміщення.', 5);
  perform pg_temp.turn('2ba72767-ca90-5273-8b9c-c7d9dc1464c1', 'c254a28a-93ef-5d68-bd89-118ada686b5d', 'Ivana', 'Pitaj Zavod za potporu za samozapošljavanje.', 'Спитай у службі зайнятості про грант на самозайнятість.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3d7a025d-2f19-5f4b-962d-642b6a926820', v_lesson, 'Розмова з бухгалтеркою', 'Razgovor s knjigovotkinjom', 5362, 'A2', 'work', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('e74765f4-144f-581c-9f81-fbc20df7d63f', '3d7a025d-2f19-5f4b-962d-642b6a926820', 'Darja', 'Trebam li knjigovodstveni servis?', 'Мені потрібна бухгалтерська фірма?', 1);
  perform pg_temp.turn('dcb5577f-85c3-57c6-a44c-33bf9b7b7672', '3d7a025d-2f19-5f4b-962d-642b6a926820', 'Knjigovotkinja', 'Preporučujem. Mi vodimo prihode, troškove i porez.', 'Раджу. Ми ведемо доходи, витрати й податок.', 2);
  perform pg_temp.turn('8e7979f9-db7f-57de-9546-f9dde17aec7e', '3d7a025d-2f19-5f4b-962d-642b6a926820', 'Darja', 'Moram li izdati račun svakom kupcu?', 'Чи мушу я виписувати рахунок кожному покупцеві?', 3);
  perform pg_temp.turn('80b1565a-ef6b-56e8-83d3-7b6fc137627e', '3d7a025d-2f19-5f4b-962d-642b6a926820', 'Knjigovotkinja', 'Morate, i račun mora biti fiskaliziran.', 'Мусите, і рахунок має бути фіскалізований.', 4);
  perform pg_temp.turn('01eb4eee-63c2-5c77-84c5-861c2b2c76fe', '3d7a025d-2f19-5f4b-962d-642b6a926820', 'Darja', 'Dobro. Bi li se isplatilo prve godine?', 'Добре. Чи окупилося б це першого року?', 5);
  perform pg_temp.turn('80fcb0e5-e69e-5891-9cdc-594105f53b0b', '3d7a025d-2f19-5f4b-962d-642b6a926820', 'Knjigovotkinja', 'Ovisi o prihodu. Napravimo zajedno poslovni plan.', 'Залежить від доходу. Складімо разом бізнес-план.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- 3. Модуль і юніт — опубліковані
update public.modules set status = 'PUBLISHED', title_ua = 'Модуль A2.5 — Робота й кар’єра', title_hr = 'Modul A2.5 — Posao i karijera' where id = 'aa10630b-c7e4-5d3a-b3dc-739e9eea9e06';
update public.units set status = 'PUBLISHED' where id = 'b8e81d83-8ed4-5446-b36d-e6d23ee6fcd4';

-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('97f1ba90-fe04-5907-803f-2ec0854b0a09', '531f3eac-8358-513b-ab35-d57fe69eb64b', 'd7b6bad3-d46a-5f73-b796-dca7b1538853', '0e0d07a2-2a6c-5090-ab84-3089f20a48b8', 'b9bcea21-08a3-56cf-be72-edf6b6c7b03f', '3ceb812b-6a68-5204-beba-52e0cb3031ad', 'd9c5c952-3ae5-521d-9ccb-c22ccaeb8aab')
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
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 20 or l.unit_id <> 'b8e81d83-8ed4-5446-b36d-e6d23ee6fcd4');
  select count(*) into v_titles from (values ('97f1ba90-fe04-5907-803f-2ec0854b0a09'::uuid, 'Урок 30:%', 1), ('531f3eac-8358-513b-ab35-d57fe69eb64b'::uuid, 'Урок 31:%', 2), ('d7b6bad3-d46a-5f73-b796-dca7b1538853'::uuid, 'Урок 32:%', 3), ('0e0d07a2-2a6c-5090-ab84-3089f20a48b8'::uuid, 'Урок 33:%', 4), ('b9bcea21-08a3-56cf-be72-edf6b6c7b03f'::uuid, 'Урок 34:%', 5), ('3ceb812b-6a68-5204-beba-52e0cb3031ad'::uuid, 'Урок 35:%', 6), ('d9c5c952-3ae5-521d-9ccb-c22ccaeb8aab'::uuid, 'Урок 36:%', 7)) as t(id, pat, o)
    left join public.lessons l on l.id = t.id and l.title_ua like t.pat and l.order_index = t.o
   where l.id is null;
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
      where l.level_code = 'A2' and l.status = 'PUBLISHED' and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A2.5: % уроків з неправильним складом', v_bad; end if;
  if v_titles > 0 then raise exception 'Модуль A2.5: % уроків не на своєму місці чи з неправильним номером', v_titles; end if;
  if v_words > 0 then raise exception 'A2: % слів повторюються в кількох уроках', v_words; end if;
  if (select status from public.modules where id = 'aa10630b-c7e4-5d3a-b3dc-739e9eea9e06') <> 'PUBLISHED' then raise exception 'Модуль A2.5 не опубліковано'; end if;
  raise notice 'Готово: модуль A2.5 — 7 уроків, слів 149';
end $$;

commit;
