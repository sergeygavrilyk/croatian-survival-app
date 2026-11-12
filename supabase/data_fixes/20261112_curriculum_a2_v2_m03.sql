-- =====================================================================
-- Програма A2 v2 · модуль A2.3 «Моє минуле: дитинство й спогади» · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2.py 3 (не редагуйте вручну).
--
-- Рішення власника 2026-11-12: 20–25 нових слів на урок, 90–95 % слів — нові для рівня, діалоги під тему,
-- частіше Даша / Дар’я; «Прослухайте діалог чи оголошення» в кожному уроці; бета (PUBLISHED).
--   * Уроки 17–22 (6): слів у них 128. Кожен: 20–25 слів, 2 діалоги, 15 вправ
--     (одна — «Прослухайте діалог чи оголошення»), «Напишіть повідомлення» і «Перекажіть другу» (ua → hr, необов’язкові), 20 хв.
--   * Слова: 128 (нові — PUBLISHED; ті, що вже є в словнику, не змінюються).
--   * Модуль і юніт A2.3 → PUBLISHED. Потрібен уже запущений 20261112_curriculum_a2_v2_00_structure.sql.
--   * Нічого не видаляє. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.units where id = '11144998-5b31-5d09-9988-9237a403f110') then
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

-- 1. Слова уроків A2.3 (128): нові — PUBLISHED (бета); наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A2', t.ua, t.vtype, t.forms, t.examples, 'PUBLISHED', 'claude_curriculum_a2_v2'
  from jsonb_to_recordset('[{"lemma": "djetinjstvo", "normalized": "djetinjstvo", "pos": "noun", "ua": "дитинство", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Djetinjstvo sam provela kod bake na selu."]}, {"lemma": "u djetinjstvu", "normalized": "u djetinjstvu", "pos": "phrase", "ua": "у дитинстві", "vtype": "chunk", "forms": {}, "examples": ["U djetinjstvu sam stalno bila vani."]}, {"lemma": "kao dijete", "normalized": "kao dijete", "pos": "phrase", "ua": "дитиною, у дитинстві", "vtype": "chunk", "forms": {}, "examples": ["Kao dijete sam se bojala pasa."]}, {"lemma": "odrastati", "normalized": "odrastati", "pos": "verb", "ua": "рости, дорослішати", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "odrasti"}, "examples": ["Odrastala sam u malom gradu blizu Poltave."]}, {"lemma": "lutka", "normalized": "lutka", "pos": "noun", "ua": "лялька", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Moja najdraža lutka imala je plavu haljinu."]}, {"lemma": "skrivača", "normalized": "skrivaca", "pos": "noun", "ua": "хованки", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Navečer smo se igrali skrivača."]}, {"lemma": "lovice", "normalized": "lovice", "pos": "noun", "ua": "квач (гра)", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Na odmoru smo igrali lovice."]}, {"lemma": "školica", "normalized": "skolica", "pos": "noun", "ua": "класики (гра)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Djevojčice su crtale školicu kredom."]}, {"lemma": "kreda", "normalized": "kreda", "pos": "noun", "ua": "крейда", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Crtali smo kredom po asfaltu."]}, {"lemma": "ljuljačka", "normalized": "ljuljacka", "pos": "noun", "ua": "гойдалка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Iza kuće je bila stara ljuljačka."]}, {"lemma": "nestašan", "normalized": "nestasan", "pos": "adjective", "ua": "пустотливий, неслухняний", "vtype": "core", "forms": {}, "examples": ["Bio sam vrlo nestašan dječak."]}, {"lemma": "penjati se", "normalized": "penjati se", "pos": "verb", "ua": "лазити, підійматися", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Penjali smo se po drveću."]}, {"lemma": "ogrebati se", "normalized": "ogrebati se", "pos": "verb", "ua": "подряпатися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "grebati se"}, "examples": ["Pala sam i ogrebala se po koljenu."]}, {"lemma": "crtići", "normalized": "crtici", "pos": "noun", "ua": "мультики", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Subotom ujutro smo gledali crtiće."]}, {"lemma": "priča za laku noć", "normalized": "prica za laku noc", "pos": "phrase", "ua": "казка на ніч", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Baka mi je svake večeri čitala priču za laku noć."]}, {"lemma": "ljetni praznici", "normalized": "ljetni praznici", "pos": "phrase", "ua": "літні канікули", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Ljetne praznike provodili smo na moru."]}, {"lemma": "susjedska djeca", "normalized": "susjedska djeca", "pos": "phrase", "ua": "сусідські діти", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Igrala sam se sa susjedskom djecom."]}, {"lemma": "cijele dane", "normalized": "cijele dane", "pos": "phrase", "ua": "цілими днями", "vtype": "chunk", "forms": {}, "examples": ["Cijele dane smo bili na rijeci."]}, {"lemma": "dok sam bila mala", "normalized": "dok sam bila mala", "pos": "phrase", "ua": "коли я була маленька", "vtype": "chunk", "forms": {}, "examples": ["Dok sam bila mala, nismo imali auto."]}, {"lemma": "obožavati", "normalized": "obozavati", "pos": "verb", "ua": "обожнювати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Obožavala sam bakine palačinke."]}, {"lemma": "maštati", "normalized": "mastati", "pos": "verb", "ua": "мріяти, фантазувати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Kao dijete sam maštala da budem pilotkinja."]}, {"lemma": "bezbrižan", "normalized": "bezbrizan", "pos": "adjective", "ua": "безтурботний", "vtype": "core", "forms": {}, "examples": ["Imala sam sretno i bezbrižno djetinjstvo."]}, {"lemma": "školski dani", "normalized": "skolski dani", "pos": "phrase", "ua": "шкільні роки", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Rado se sjećam školskih dana."]}, {"lemma": "omiljeni predmet", "normalized": "omiljeni predmet", "pos": "phrase", "ua": "улюблений предмет", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Kemija mi je bila omiljeni predmet."]}, {"lemma": "školska klupa", "normalized": "skolska klupa", "pos": "phrase", "ua": "шкільна парта", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Sjedila sam u prvoj klupi."]}, {"lemma": "kolegica iz klupe", "normalized": "kolegica iz klupe", "pos": "phrase", "ua": "сусідка по парті", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Moja kolegica iz klupe je danas liječnica."]}, {"lemma": "najbolji prijatelj", "normalized": "najbolji prijatelj", "pos": "phrase", "ua": "найкращий друг", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Moj najbolji prijatelj iz škole živi u Kanadi."]}, {"lemma": "stroga učiteljica", "normalized": "stroga uciteljica", "pos": "phrase", "ua": "сувора вчителька", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Imali smo strogu učiteljicu matematike."]}, {"lemma": "omiljeni učitelj", "normalized": "omiljeni ucitelj", "pos": "phrase", "ua": "улюблений учитель", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Moj omiljeni učitelj predavao je povijest."]}, {"lemma": "prepisivati zadaću", "normalized": "prepisivati zadacu", "pos": "phrase", "ua": "списувати домашнє завдання", "vtype": "chunk", "forms": {}, "examples": ["Ujutro smo prepisivali zadaću u hodniku."]}, {"lemma": "šalabahter", "normalized": "salabahter", "pos": "noun", "ua": "шпаргалка", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Na kontrolnom sam imala šalabahter u pernici."]}, {"lemma": "kontrolni", "normalized": "kontrolni", "pos": "noun", "ua": "контрольна робота", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Iz fizike sam uvijek pisala loše kontrolne."]}, {"lemma": "školska ekskurzija", "normalized": "skolska ekskurzija", "pos": "phrase", "ua": "шкільна поїздка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na školskoj ekskurziji bili smo u Lavovu."]}, {"lemma": "maturalna zabava", "normalized": "maturalna zabava", "pos": "phrase", "ua": "випускний вечір", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na maturalnoj zabavi sam nosila crvenu haljinu."]}, {"lemma": "generacija", "normalized": "generacija", "pos": "noun", "ua": "покоління; випуск (класу)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Naša generacija se nalazi svakih deset godina."]}, {"lemma": "susret generacije", "normalized": "susret generacije", "pos": "phrase", "ua": "зустріч випускників", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Idući mjesec je susret generacije."]}, {"lemma": "rado se sjećati", "normalized": "rado se sjecati", "pos": "phrase", "ua": "із радістю згадувати", "vtype": "chunk", "forms": {}, "examples": ["Rado se sjećam svoje prve učiteljice."]}, {"lemma": "prisjetiti se", "normalized": "prisjetiti se", "pos": "verb", "ua": "пригадати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "prisjećati se"}, "examples": ["Ne mogu se prisjetiti njegova imena."]}, {"lemma": "zaboraviti", "normalized": "zaboraviti", "pos": "verb", "ua": "забути", "vtype": "core", "forms": {"aspect": "pfv", "pair": "zaboravljati"}, "examples": ["Nikad neću zaboraviti taj dan."]}, {"lemma": "odličan učenik", "normalized": "odlican ucenik", "pos": "phrase", "ua": "відмінник", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Moj brat je uvijek bio odličan učenik."]}, {"lemma": "markirati", "normalized": "markirati", "pos": "verb", "ua": "прогулювати (уроки)", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Jednom smo markirali sat i otišli u kino."]}, {"lemma": "uhvatiti", "normalized": "uhvatiti", "pos": "verb", "ua": "спіймати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "hvatati"}, "examples": ["Ravnatelj nas je uhvatio na ulici."]}, {"lemma": "posramiti se", "normalized": "posramiti se", "pos": "verb", "ua": "засоромитися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "sramiti se"}, "examples": ["Jako sam se posramila pred razredom."]}, {"lemma": "nekoć", "normalized": "nekoc", "pos": "adverb", "ua": "колись, раніше", "vtype": "core", "forms": {}, "examples": ["Nekoć je ovdje bila tvornica."]}, {"lemma": "tada", "normalized": "tada", "pos": "adverb", "ua": "тоді", "vtype": "core", "forms": {}, "examples": ["Tada nismo imali mobitele."]}, {"lemma": "tadašnji", "normalized": "tadasnji", "pos": "adjective", "ua": "тодішній", "vtype": "core", "forms": {}, "examples": ["Tadašnji život bio je jednostavniji."]}, {"lemma": "nekadašnji", "normalized": "nekadasnji", "pos": "adjective", "ua": "колишній", "vtype": "core", "forms": {}, "examples": ["Ovo je nekadašnja zgrada pošte."]}, {"lemma": "u ono vrijeme", "normalized": "u ono vrijeme", "pos": "phrase", "ua": "у ті часи", "vtype": "chunk", "forms": {}, "examples": ["U ono vrijeme pisala su se pisma."]}, {"lemma": "prije dvadeset godina", "normalized": "prije dvadeset godina", "pos": "phrase", "ua": "двадцять років тому", "vtype": "chunk", "forms": {}, "examples": ["Prije dvadeset godina sve je bilo jeftinije."]}, {"lemma": "promijeniti se", "normalized": "promijeniti se", "pos": "verb", "ua": "змінитися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "mijenjati se"}, "examples": ["Grad se jako promijenio."]}, {"lemma": "mijenjati se", "normalized": "mijenjati se", "pos": "verb", "ua": "змінюватися", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "promijeniti se"}, "examples": ["Cijene se stalno mijenjaju."]}, {"lemma": "promjena", "normalized": "promjena", "pos": "noun", "ua": "зміна", "vtype": "core", "forms": {"gender": "f"}, "examples": ["To je bila velika promjena za cijelu obitelj."]}, {"lemma": "stari album", "normalized": "stari album", "pos": "phrase", "ua": "старий альбом", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["U starom albumu ima slika moje mame."]}, {"lemma": "crno-bijela fotografija", "normalized": "crno-bijela fotografija", "pos": "phrase", "ua": "чорно-біла фотографія", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na crno-bijeloj fotografiji je moj djed."]}, {"lemma": "pisati pisma", "normalized": "pisati pisma", "pos": "phrase", "ua": "писати листи", "vtype": "chunk", "forms": {}, "examples": ["Moji roditelji su si pisali pisma."]}, {"lemma": "telefonska govornica", "normalized": "telefonska govornica", "pos": "phrase", "ua": "телефонна будка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Zvala sam mamu iz telefonske govornice."]}, {"lemma": "videokazeta", "normalized": "videokazeta", "pos": "noun", "ua": "відеокасета", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Filmove smo gledali na videokazetama."]}, {"lemma": "ploča", "normalized": "ploca", "pos": "noun", "ua": "платівка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Tata još ima stare ploče."]}, {"lemma": "generacijski jaz", "normalized": "generacijski jaz", "pos": "phrase", "ua": "розрив між поколіннями", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Između mene i djece postoji generacijski jaz."]}, {"lemma": "više ne postoji", "normalized": "vise ne postoji", "pos": "phrase", "ua": "більше не існує", "vtype": "chunk", "forms": {}, "examples": ["Ta trgovina više ne postoji."]}, {"lemma": "nestati", "normalized": "nestati", "pos": "verb", "ua": "зникнути", "vtype": "core", "forms": {"aspect": "pfv", "pair": "nestajati"}, "examples": ["Stari kafići su nestali iz centra."]}, {"lemma": "izgraditi", "normalized": "izgraditi", "pos": "verb", "ua": "збудувати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "graditi"}, "examples": ["Izgradili su novi trgovački centar."]}, {"lemma": "srušiti", "normalized": "srusiti", "pos": "verb", "ua": "знести, зруйнувати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "rušiti"}, "examples": ["Staro kino su srušili prošle godine."]}, {"lemma": "jednostavniji", "normalized": "jednostavniji", "pos": "adjective", "ua": "простіший", "vtype": "core", "forms": {}, "examples": ["Život je tada bio jednostavniji."]}, {"lemma": "napustiti", "normalized": "napustiti", "pos": "verb", "ua": "покинути, залишити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "napuštati"}, "examples": ["Napustili smo Harkiv u ožujku."]}, {"lemma": "rodno mjesto", "normalized": "rodno mjesto", "pos": "phrase", "ua": "рідне місце, рідне село", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Moje rodno mjesto je malo selo kod Poltave."]}, {"lemma": "novi početak", "normalized": "novi pocetak", "pos": "phrase", "ua": "новий початок", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Hrvatska je za nas bila novi početak."]}, {"lemma": "prvi mjeseci", "normalized": "prvi mjeseci", "pos": "phrase", "ua": "перші місяці", "vtype": "chunk", "forms": {"gender": "m_pl"}, "examples": ["Prvi mjeseci su bili najteži."]}, {"lemma": "priviknuti se", "normalized": "priviknuti se", "pos": "verb", "ua": "звикнути", "vtype": "core", "forms": {"aspect": "pfv", "pair": "privikavati se"}, "examples": ["Brzo smo se priviknuli na novi grad."]}, {"lemma": "čežnja", "normalized": "ceznja", "pos": "noun", "ua": "туга", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Osjećam čežnju za domom."]}, {"lemma": "podrška", "normalized": "podrska", "pos": "noun", "ua": "підтримка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Susjedi su nam dali veliku podršku."]}, {"lemma": "prekretnica", "normalized": "prekretnica", "pos": "noun", "ua": "поворотний момент", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Novi posao je bio prekretnica."]}, {"lemma": "nakon što", "normalized": "nakon sto", "pos": "conjunction", "ua": "після того як", "vtype": "function_word", "forms": {}, "examples": ["Nakon što smo našli stan, sve je bilo lakše."]}, {"lemma": "prije nego što", "normalized": "prije nego sto", "pos": "conjunction", "ua": "перш ніж, перед тим як", "vtype": "function_word", "forms": {}, "examples": ["Prije nego što smo došli, nisam znala ni riječ hrvatskog."]}, {"lemma": "čim", "normalized": "cim", "pos": "conjunction", "ua": "щойно, як тільки", "vtype": "function_word", "forms": {}, "examples": ["Čim sam stigla, upisala sam tečaj."]}, {"lemma": "spakirati", "normalized": "spakirati", "pos": "verb", "ua": "спакувати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "pakirati"}, "examples": ["Spakirali smo samo dva kofera."]}, {"lemma": "kofer", "normalized": "kofer", "pos": "noun", "ua": "валіза", "vtype": "core", "forms": {"gender": "m"}, "examples": ["U jednom koferu je bila sva odjeća."]}, {"lemma": "ponijeti sa sobom", "normalized": "ponijeti sa sobom", "pos": "phrase", "ua": "взяти з собою", "vtype": "chunk", "forms": {}, "examples": ["Sa sobom smo ponijeli samo dokumente i fotografije."]}, {"lemma": "ostaviti iza sebe", "normalized": "ostaviti iza sebe", "pos": "phrase", "ua": "залишити позаду", "vtype": "chunk", "forms": {}, "examples": ["Iza sebe smo ostavili stan i posao."]}, {"lemma": "olakšanje", "normalized": "olaksanje", "pos": "noun", "ua": "полегшення", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Kad smo dobili stan, osjetila sam olakšanje."]}, {"lemma": "ponosan", "normalized": "ponosan", "pos": "adjective", "ua": "гордий", "vtype": "core", "forms": {}, "examples": ["Ponosna sam na sve što smo postigli."]}, {"lemma": "samoća", "normalized": "samoca", "pos": "noun", "ua": "самотність", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Samoća je na početku bila najteža."]}, {"lemma": "osjećati se izgubljeno", "normalized": "osjecati se izgubljeno", "pos": "phrase", "ua": "почуватися розгубленим", "vtype": "chunk", "forms": {}, "examples": ["Prvih dana sam se osjećala izgubljeno."]}, {"lemma": "preseljenje", "normalized": "preseljenje", "pos": "noun", "ua": "переселення, переїзд (в іншу країну)", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Preseljenje u drugu zemlju mijenja sve."]}, {"lemma": "hrabrost", "normalized": "hrabrost", "pos": "noun", "ua": "сміливість", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Za takvu odluku treba puno hrabrosti."]}, {"lemma": "neizvjesnost", "normalized": "neizvjesnost", "pos": "noun", "ua": "невизначеність", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Najteža je bila neizvjesnost."]}, {"lemma": "najprije", "normalized": "najprije", "pos": "adverb", "ua": "спочатку", "vtype": "core", "forms": {}, "examples": ["Najprije smo izgubili put."]}, {"lemma": "iznenada", "normalized": "iznenada", "pos": "adverb", "ua": "раптово", "vtype": "core", "forms": {}, "examples": ["Iznenada je počela padati kiša."]}, {"lemma": "napokon", "normalized": "napokon", "pos": "adverb", "ua": "нарешті", "vtype": "core", "forms": {}, "examples": ["Napokon smo stigli kući."]}, {"lemma": "srećom", "normalized": "srecom", "pos": "adverb", "ua": "на щастя", "vtype": "core", "forms": {}, "examples": ["Srećom, nitko nije bio ozlijeđen."]}, {"lemma": "nažalost", "normalized": "nazalost", "pos": "adverb", "ua": "на жаль", "vtype": "core", "forms": {}, "examples": ["Nažalost, vlak je već otišao."]}, {"lemma": "ispričati", "normalized": "ispricati", "pos": "verb", "ua": "розповісти", "vtype": "core", "forms": {"aspect": "pfv", "pair": "pričati"}, "examples": ["Ispričat ću ti što mi se dogodilo."]}, {"lemma": "zgoda", "normalized": "zgoda", "pos": "noun", "ua": "випадок, пригода", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Dogodila mi se smiješna zgoda."]}, {"lemma": "doživljaj", "normalized": "dozivljaj", "pos": "noun", "ua": "пригода, враження", "vtype": "core", "forms": {"gender": "m"}, "examples": ["To je bio nezaboravan doživljaj."]}, {"lemma": "nezaboravan", "normalized": "nezaboravan", "pos": "adjective", "ua": "незабутній", "vtype": "core", "forms": {}, "examples": ["Putovanje je bilo nezaboravno."]}, {"lemma": "uplašiti se", "normalized": "uplasiti se", "pos": "verb", "ua": "злякатися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "plašiti se"}, "examples": ["Jako sam se uplašila."]}, {"lemma": "iznenaditi se", "normalized": "iznenaditi se", "pos": "verb", "ua": "здивуватися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "iznenađivati se"}, "examples": ["Iznenadila sam se kad sam ga vidjela."]}, {"lemma": "nasmijati se", "normalized": "nasmijati se", "pos": "verb", "ua": "засміятися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "smijati se"}, "examples": ["Svi su se nasmijali."]}, {"lemma": "nestati struje", "normalized": "nestati struje", "pos": "phrase", "ua": "зникнути (про світло)", "vtype": "chunk", "forms": {}, "examples": ["Usred filma je nestalo struje."]}, {"lemma": "zaglaviti u liftu", "normalized": "zaglaviti u liftu", "pos": "phrase", "ua": "застрягнути в ліфті", "vtype": "chunk", "forms": {}, "examples": ["Zaglavila sam u liftu na sat vremena."]}, {"lemma": "izgubiti se", "normalized": "izgubiti se", "pos": "verb", "ua": "заблукати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "gubiti se"}, "examples": ["Izgubili smo se u starom gradu."]}, {"lemma": "pozvati pomoć", "normalized": "pozvati pomoc", "pos": "phrase", "ua": "покликати на допомогу", "vtype": "chunk", "forms": {}, "examples": ["Pozvala sam pomoć telefonom."]}, {"lemma": "spasiti", "normalized": "spasiti", "pos": "verb", "ua": "врятувати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "spašavati"}, "examples": ["Susjed nas je spasio."]}, {"lemma": "ispasti", "normalized": "ispasti", "pos": "verb", "ua": "випасти", "vtype": "core", "forms": {"aspect": "pfv", "pair": "ispadati"}, "examples": ["Mobitel mi je ispao u more."]}, {"lemma": "slučajno", "normalized": "slucajno", "pos": "adverb", "ua": "випадково", "vtype": "core", "forms": {}, "examples": ["Slučajno sam srela staru prijateljicu."]}, {"lemma": "u tom trenutku", "normalized": "u tom trenutku", "pos": "phrase", "ua": "у ту мить", "vtype": "chunk", "forms": {}, "examples": ["U tom trenutku zazvonio je telefon."]}, {"lemma": "rođenje", "normalized": "rodenje", "pos": "noun", "ua": "народження", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Na rođenju je imala tri kilograma."]}, {"lemma": "obljetnica", "normalized": "obljetnica", "pos": "noun", "ua": "річниця", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Slavimo desetu obljetnicu braka."]}, {"lemma": "diplomirati", "normalized": "diplomirati", "pos": "verb", "ua": "закінчити університет (здобути диплом)", "vtype": "core", "forms": {"aspect": "biasp"}, "examples": ["Diplomirala sam prije deset godina."]}, {"lemma": "umrijeti", "normalized": "umrijeti", "pos": "verb", "ua": "померти", "vtype": "core", "forms": {"aspect": "pfv", "pair": "umirati"}, "examples": ["Djed je umro kad sam imala deset godina."]}, {"lemma": "desetljeće", "normalized": "desetljece", "pos": "noun", "ua": "десятиліття", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Posljednje desetljeće živim u inozemstvu."]}, {"lemma": "dvoje", "normalized": "dvoje", "pos": "number", "ua": "двоє", "vtype": "core", "forms": {}, "examples": ["Imamo dvoje djece."]}, {"lemma": "troje", "normalized": "troje", "pos": "number", "ua": "троє", "vtype": "core", "forms": {}, "examples": ["U sobi je bilo troje ljudi."]}, {"lemma": "oboje", "normalized": "oboje", "pos": "number", "ua": "обоє", "vtype": "core", "forms": {}, "examples": ["Oboje smo rođeni u Kijevu."]}, {"lemma": "obje", "normalized": "obje", "pos": "number", "ua": "обидві", "vtype": "core", "forms": {}, "examples": ["Obje kćeri idu u školu."]}, {"lemma": "oba", "normalized": "oba", "pos": "number", "ua": "обидва", "vtype": "core", "forms": {}, "examples": ["Oba sina žive u Zagrebu."]}, {"lemma": "najstariji", "normalized": "najstariji", "pos": "adjective", "ua": "найстарший", "vtype": "core", "forms": {}, "examples": ["Ja sam najstarija od troje djece."]}, {"lemma": "najmlađi", "normalized": "najmladi", "pos": "adjective", "ua": "наймолодший", "vtype": "core", "forms": {}, "examples": ["Najmlađi brat ima dvadeset godina."]}, {"lemma": "važan događaj", "normalized": "vazan dogadaj", "pos": "phrase", "ua": "важлива подія", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Rođenje kćeri je najvažniji događaj u mom životu."]}, {"lemma": "prekretnički trenutak", "normalized": "prekretnicki trenutak", "pos": "phrase", "ua": "переломний момент", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Selidba je bila prekretnički trenutak."]}, {"lemma": "od tada", "normalized": "od tada", "pos": "phrase", "ua": "відтоді", "vtype": "chunk", "forms": {}, "examples": ["Od tada živimo u Splitu."]}, {"lemma": "iste godine", "normalized": "iste godine", "pos": "phrase", "ua": "того самого року", "vtype": "chunk", "forms": {}, "examples": ["Iste godine sam dobila posao."]}, {"lemma": "godinu dana kasnije", "normalized": "godinu dana kasnije", "pos": "phrase", "ua": "через рік (рік потому)", "vtype": "chunk", "forms": {}, "examples": ["Godinu dana kasnije rodio se sin."]}, {"lemma": "godina rođenja", "normalized": "godina rodenja", "pos": "phrase", "ua": "рік народження", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Upišite godinu rođenja u obrazac."]}, {"lemma": "srebrni pir", "normalized": "srebrni pir", "pos": "phrase", "ua": "срібне весілля", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Roditelji su proslavili srebrni pir."]}, {"lemma": "zlatni pir", "normalized": "zlatni pir", "pos": "phrase", "ua": "золоте весілля", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Djed i baka ove godine slave zlatni pir."]}, {"lemma": "otići u mirovinu", "normalized": "otici u mirovinu", "pos": "phrase", "ua": "вийти на пенсію", "vtype": "chunk", "forms": {}, "examples": ["Mama je otišla u mirovinu prošle godine."]}, {"lemma": "obiteljsko stablo", "normalized": "obiteljsko stablo", "pos": "phrase", "ua": "родинне дерево", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Djeca su nacrtala obiteljsko stablo."]}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 2. Уроки модуля A2.3
-- A2.3 · урок 17: Моє дитинство — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '11144998-5b31-5d09-9988-9237a403f110';
  v_lesson constant uuid := '65e0eec5-f830-5509-a807-db00ace41075';
  v_gid constant uuid := 'feaaa674-66e6-5521-ba6e-b5d1507cd351';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики PERF'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A2.3: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 17: Моє дитинство', 'Lekcija 17: Moje djetinjstvo', '["Розповісти, де ви росли й чим гралися", "Розрізняти в минулому: igrali smo se (часто) — jednom smo otišli (один раз)"]'::jsonb, 20, 'PUBLISHED', 1);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'djetinjstvo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u djetinjstvu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kao dijete', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odrastati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lutka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skrivača', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lovice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'školica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kreda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljuljačka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nestašan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'penjati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ogrebati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crtići', v_pos);
  v_pos := pg_temp.word(v_lesson, 'priča za laku noć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljetni praznici', v_pos);
  v_pos := pg_temp.word(v_lesson, 'susjedska djeca', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cijele dane', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dok sam bila mala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obožavati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maštati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bezbrižan', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '72551175-25eb-5e71-bc1a-efc6d9aa4f2f', 'fill_in_the_blank', 'Kao dijete sam se svaki dan ___ s prijateljima.', 'igrala', '["zaigrala", "igrala", "igram", "igrati"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'de4aa7a8-61a5-5777-85a4-d9335359febf', 'multiple_choice', 'Що означає «priča za laku noć»?', 'казка на ніч', '["крейда", "казка на ніч", "лялька", "класики (гра)"]'::jsonb, 'A2', 2, 'PUBLISHED', 'priča za laku noć', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '72a84509-adc4-5231-b41c-41b8f5f5e6fb', 'multiple_choice', 'Що означає «dok sam bila mala»?', 'коли я була маленька', '["коли я була маленька", "літні канікули", "класики (гра)", "пустотливий, неслухняний"]'::jsonb, 'A2', 3, 'PUBLISHED', 'dok sam bila mala', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '34a6f633-9191-5bf1-8532-db303e774cb9', 'multiple_choice', 'Що означає «u djetinjstvu»?', 'у дитинстві', '["класики (гра)", "у дитинстві", "мріяти, фантазувати", "казка на ніч"]'::jsonb, 'A2', 4, 'PUBLISHED', 'u djetinjstvu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4321b5bb-a632-556d-9aa1-c70e063c3b35', 'multiple_choice', 'Як хорватською «квач (гра)»?', 'lovice', '["ljuljačka", "susjedska djeca", "lovice", "obožavati"]'::jsonb, 'A2', 5, 'PUBLISHED', 'lovice', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '128f3917-a819-51e9-9814-f4768b652c13', 'multiple_choice', 'Як хорватською «пустотливий, неслухняний»?', 'nestašan', '["lutka", "nestašan", "obožavati", "kao dijete"]'::jsonb, 'A2', 6, 'PUBLISHED', 'nestašan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd55d6aa5-2ee4-5993-96b9-2c6f0a910294', 'type_answer', 'Напишіть хорватською: «мріяти, фантазувати»', 'maštati', null, 'A2', 7, 'PUBLISHED', 'maštati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a0be50d-eb33-51a6-8a22-683eab3c80ac', 'type_answer', 'Напишіть хорватською: «крейда»', 'kreda', null, 'A2', 8, 'PUBLISHED', 'kreda', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7473c99d-1390-53b2-9c01-73ef4b261d59', 'type_answer', 'Напишіть хорватською: «рости, дорослішати»', 'odrastati', null, 'A2', 9, 'PUBLISHED', 'odrastati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0c9deb2e-4c47-5632-b47d-477b289bac98', 'sentence_builder', 'Складіть: «Я росла в маленькому містечку.»', 'Odrastala sam u malom gradu.', '["Odrastala", "gradu.", "u", "malom", "sam"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '810b2516-0193-550c-b416-81432971f1f5', 'sentence_builder', 'Складіть: «Бабуся читала мені казку на ніч.»', 'Baka mi je čitala priču za laku noć.', '["laku", "čitala", "Baka", "noć.", "je", "mi", "za", "priču"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cf26d6ad-cd83-555b-92e6-80fb81ac9dfc', 'listening', 'Прослухайте і складіть фразу', 'Vrlo nestašan. Stalno sam se penjao po drveću.', '["se", "po", "Vrlo", "Stalno", "drveću.", "nestašan.", "sam", "penjao"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '5eb3c32d-e322-5982-826b-f4d653a6b617', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'старі фото; приблизно п’ять; поштою з посилкою', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Мама Дар’ї надіслала голосове повідомлення про старі фото.", "script": [{"hr": "Darja, našla sam tvoje stare fotografije iz djetinjstva!", "ua": "Дар’є, я знайшла твої старі фото з дитинства!"}, {"hr": "Na jednoj si na ljuljački kod bake, imaš možda pet godina.", "ua": "На одному ти на гойдалці в бабусі, тобі, може, п’ять років."}, {"hr": "Na drugoj držiš lutku koju si dobila za rođendan.", "ua": "На іншому ти тримаєш ляльку, яку отримала на день народження."}, {"hr": "Poslat ću ti ih poštom zajedno s paketom.", "ua": "Я надішлю тобі їх поштою разом із посилкою."}], "questions": [{"q_ua": "Що знайшла мама?", "options": ["старі фото", "старі листи", "іграшки"], "correct": 0, "answer_turn": 0}, {"q_ua": "Скільки Дар’ї на фото на гойдалці?", "options": ["десять", "приблизно п’ять", "два"], "correct": 1, "answer_turn": 1}, {"q_ua": "Як мама передасть фото?", "options": ["e-mailом", "через подругу", "поштою з посилкою"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '5eb3c32d-e322-5982-826b-f4d653a6b617', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ac0cd65a-3885-5974-88c9-c7a6363c4625', 'speaking', 'У дитинстві я боялася темряви.', 'Kao dijete sam se bojala mraka.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '95bd85b6-81d5-5a67-b7cd-0adb095bc030', 'speaking', 'Ким ти мріяв бути?', 'Što si maštao biti?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '83a51376-117c-5c31-b05b-3389863db2fd', 'write_message', 'Напишіть подрузі коротко про своє дитинство: де ви росли й у що найбільше любили гратися.', 'Odrastala sam u malom gradu blizu Kijeva. Kao dijete sam se najviše voljela igrati skrivača sa susjedskom djecom.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі коротко про своє дитинство: де ви росли й у що найбільше любили гратися.", "points": [{"ua": "де росли", "keys": [["odrast"]]}, {"ua": "у що гралися", "keys": [["igra"]]}], "hints": ["odrastala sam u…", "kao dijete", "igrali smo se skrivača", "obožavala sam"], "models": ["Odrastala sam u malom gradu blizu Kijeva. Kao dijete sam se najviše voljela igrati skrivača sa susjedskom djecom."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '83a51376-117c-5c31-b05b-3389863db2fd', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '59b1e47a-1d80-52ea-81f0-e4db034a2b16', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Kao dijete je cijele dane bio na rijeci i obožavao je bakine palačinke.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Розкажи Марку, що в дитинстві я цілими днями був біля річки й обожнював бабусині млинці.", "direction": "ua_hr", "points": [{"ua": "цілими днями біля річки", "keys": [["rijec"]]}, {"ua": "бабусині млинці", "keys": [["palačink"]]}], "hints": [], "models": ["Kao dijete je cijele dane bio na rijeci i obožavao je bakine palačinke."], "source_ua": "Розкажи Марку, що в дитинстві я цілими днями був біля річки й обожнював бабусині млинці."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '59b1e47a-1d80-52ea-81f0-e4db034a2b16', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0b220ec0-ce5d-5ced-b945-d03cf69deefe', v_lesson, 'Де ти росла?', 'Gdje si odrastala?', 5171, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('ac7f96de-a4f9-5e67-a645-e0881f4b76ec', '0b220ec0-ce5d-5ced-b945-d03cf69deefe', 'Ivana', 'Darja, gdje si odrastala?', 'Дар’є, де ти росла?', 1);
  perform pg_temp.turn('0b28c065-7670-517c-a702-d5a7a1353e91', '0b220ec0-ce5d-5ced-b945-d03cf69deefe', 'Darja', 'U malom gradu blizu Poltave. Ljetne praznike sam provodila kod bake na selu.', 'У маленькому містечку біля Полтави. Літні канікули проводила в бабусі в селі.', 2);
  perform pg_temp.turn('33cfebd3-f5fd-5cdf-961c-08ac65c777e2', '0b220ec0-ce5d-5ced-b945-d03cf69deefe', 'Ivana', 'Što ste se igrali?', 'У що ви гралися?', 3);
  perform pg_temp.turn('c4e00607-55b9-5f7c-89d6-4ece5bcf28e5', '0b220ec0-ce5d-5ced-b945-d03cf69deefe', 'Darja', 'Cijele dane smo bili vani: skrivača, lovice, ljuljačka iza kuće.', 'Цілими днями ми були надворі: хованки, квач, гойдалка за хатою.', 4);
  perform pg_temp.turn('8e94ecef-d508-5209-87c5-032a2b62837d', '0b220ec0-ce5d-5ced-b945-d03cf69deefe', 'Ivana', 'Zvuči kao bezbrižno djetinjstvo.', 'Звучить як безтурботне дитинство.', 5);
  perform pg_temp.turn('e12f1441-f995-5dd9-a3db-aa40da6128fe', '0b220ec0-ce5d-5ced-b945-d03cf69deefe', 'Darja', 'Bilo je. Jednom sam pala s drveta i ogrebala se, ali to je bilo sve.', 'Так і було. Одного разу я впала з дерева й подряпалася, але це й усе.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1c4ef7d8-30a8-59e3-b9bc-6f488d305f99', v_lesson, 'Пустун', 'Nestašan dječak', 5172, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('e7c15010-16f0-56a0-b22c-1f1dcc79e7b7', '1c4ef7d8-30a8-59e3-b9bc-6f488d305f99', 'Daša', 'Marko, kakav si bio kao dijete?', 'Марку, яким ти був у дитинстві?', 1);
  perform pg_temp.turn('62fd21a0-c87a-51fd-9cff-7db8c7b153cf', '1c4ef7d8-30a8-59e3-b9bc-6f488d305f99', 'Marko', 'Vrlo nestašan. Stalno sam se penjao po drveću.', 'Дуже пустотливим. Постійно лазив по деревах.', 2);
  perform pg_temp.turn('224c9d88-acaa-5869-adf0-7f39d6261bf6', '1c4ef7d8-30a8-59e3-b9bc-6f488d305f99', 'Daša', 'A što si maštao biti?', 'А ким ти мріяв бути?', 3);
  perform pg_temp.turn('91c4b150-1615-57b0-8b12-ee6e823e7ad8', '1c4ef7d8-30a8-59e3-b9bc-6f488d305f99', 'Marko', 'Pilot! A ti?', 'Пілотом! А ти?', 4);
  perform pg_temp.turn('3e65133b-ef5a-5614-a87e-81fe80ed2336', '1c4ef7d8-30a8-59e3-b9bc-6f488d305f99', 'Daša', 'Ja sam obožavala crtiće i maštala sam da budem glumica.', 'Я обожнювала мультики й мріяла стати актрисою.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.3 · урок 18: Шкільні роки — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '11144998-5b31-5d09-9988-9237a403f110';
  v_lesson constant uuid := '92226a59-39e3-5dba-b0df-1e91b3dd2210';
  v_gid constant uuid := '4101ee05-3efe-5a98-a9e5-f0f327436268';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики POV'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A2.3: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 18: Шкільні роки', 'Lekcija 18: Školski dani', '["Згадати шкільні роки: улюблені предмети, учителі, друзі", "Говорити про спогади: sjećam se + родовий, sjećaš li se…?"]'::jsonb, 20, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'školski dani', v_pos);
  v_pos := pg_temp.word(v_lesson, 'omiljeni predmet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'školska klupa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolegica iz klupe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najbolji prijatelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stroga učiteljica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'omiljeni učitelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prepisivati zadaću', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šalabahter', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kontrolni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'školska ekskurzija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maturalna zabava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'generacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'susret generacije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rado se sjećati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prisjetiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaboraviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odličan učenik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'markirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uhvatiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posramiti se', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2061e82f-5d19-583f-9c91-dd50ccde2431', 'fill_in_the_blank', 'Rado se ___ svojih školskih dana.', 'sjećam', '["sjećati", "sjećaš", "sjeća", "sjećam"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dff4bae3-c1bf-52cd-b969-843527c69479', 'multiple_choice', 'Що означає «kontrolni»?', 'контрольна робота', '["шкільна парта", "списувати домашнє завдання", "контрольна робота", "прогулювати (уроки)"]'::jsonb, 'A2', 2, 'PUBLISHED', 'kontrolni', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '58ab4e27-51b4-57af-a2f3-629787088be0', 'multiple_choice', 'Що означає «omiljeni učitelj»?', 'улюблений учитель', '["улюблений учитель", "відмінник", "шпаргалка", "сувора вчителька"]'::jsonb, 'A2', 3, 'PUBLISHED', 'omiljeni učitelj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '877943dc-b084-563d-a9bc-b9982c14ddf4', 'multiple_choice', 'Що означає «najbolji prijatelj»?', 'найкращий друг', '["забути", "найкращий друг", "сувора вчителька", "засоромитися"]'::jsonb, 'A2', 4, 'PUBLISHED', 'najbolji prijatelj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '37e79744-04a3-5c14-9461-bc6ea45468ce', 'multiple_choice', 'Як хорватською «покоління; випуск (класу)»?', 'generacija', '["kontrolni", "posramiti se", "šalabahter", "generacija"]'::jsonb, 'A2', 5, 'PUBLISHED', 'generacija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '44cf2991-070f-52d6-ae50-8f861dba1ebb', 'multiple_choice', 'Як хорватською «випускний вечір»?', 'maturalna zabava', '["kolegica iz klupe", "maturalna zabava", "školska klupa", "prepisivati zadaću"]'::jsonb, 'A2', 6, 'PUBLISHED', 'maturalna zabava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '637a09f7-254d-502b-9b6d-f5fcaa786a5c', 'type_answer', 'Напишіть хорватською: «відмінник»', 'odličan učenik', null, 'A2', 7, 'PUBLISHED', 'odličan učenik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5f21553e-f580-5c71-b117-d93c3a1b4b8a', 'type_answer', 'Напишіть хорватською: «прогулювати (уроки)»', 'markirati', null, 'A2', 8, 'PUBLISHED', 'markirati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7a6795ea-75b5-5dd7-8de5-e1eacd9857ea', 'type_answer', 'Напишіть хорватською: «засоромитися»', 'posramiti se', null, 'A2', 9, 'PUBLISHED', 'posramiti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cf7cf23f-89ec-5eac-9bdd-02dc936ee621', 'sentence_builder', 'Складіть: «Я не можу пригадати його ім’я.»', 'Ne mogu se prisjetiti njegova imena.', '["mogu", "se", "imena.", "Ne", "njegova", "prisjetiti"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e3795a74-4719-5294-b021-4cef6361d229', 'sentence_builder', 'Складіть: «Хімія була моїм улюбленим предметом.»', 'Kemija mi je bila omiljeni predmet.', '["bila", "mi", "predmet.", "omiljeni", "je", "Kemija"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c75f9155-c216-5b9e-8f34-efa7e169ff09', 'listening', 'Прослухайте і складіть фразу', 'Otišli smo u kino, ali ravnatelj nas je uhvatio na ulici.', '["smo", "nas", "ulici.", "u", "je", "Otišli", "kino,", "ravnatelj", "ali", "uhvatio", "na"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'bfbe2ad3-cd29-5fad-ba34-cfc3f447750e', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'зустріч випускників; двадцять; онлайн', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Колишній однокласник Дар’ї залишив повідомлення.", "script": [{"hr": "Bok Darja, ovdje Oleh iz tvog razreda! Sjećaš li me se?", "ua": "Привіт, Дар’є, це Олег з твого класу! Пам’ятаєш мене?"}, {"hr": "Organiziramo susret generacije, dvadeset godina od mature.", "ua": "Ми організовуємо зустріч випускників, двадцять років після випуску."}, {"hr": "Bit će u Kijevu, u srpnju, ali možeš se spojiti i online.", "ua": "Буде в Києві, у липні, але можна приєднатися й онлайн."}], "questions": [{"q_ua": "Що організовують?", "options": ["зустріч випускників", "весілля", "екскурсію"], "correct": 0, "answer_turn": 1}, {"q_ua": "Скільки років минуло після випуску?", "options": ["десять", "двадцять", "п’ятнадцять"], "correct": 1, "answer_turn": 1}, {"q_ua": "Як можна взяти участь, якщо не приїхати?", "options": ["написати листа", "не можна", "онлайн"], "correct": 2, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'bfbe2ad3-cd29-5fad-ba34-cfc3f447750e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1ca98457-8d13-5270-88e5-42bdd63543bb', 'speaking', 'Ти пам’ятаєш свою першу вчительку?', 'Sjećaš li se svoje prve učiteljice?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b06488aa-0996-5528-b21a-c07dae577216', 'speaking', 'Я ніколи не забуду той день.', 'Nikad neću zaboraviti taj dan.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '0eeac381-0af6-5eca-a78d-b3d18c33be25', 'write_message', 'Напишіть однокласнику: ви пам’ятаєте його, із радістю згадуєте школу й хотіли б прийти на зустріч випускників.', 'Bok Oleh, naravno da se sjećam! Rado se sjećam škole i voljela bih doći na susret generacije.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть однокласнику: ви пам’ятаєте його, із радістю згадуєте школу й хотіли б прийти на зустріч випускників.", "points": [{"ua": "пам’ятаєте його", "keys": [["sjeća"]]}, {"ua": "згадуєте школу", "keys": [["škol"]]}, {"ua": "прийти на зустріч", "keys": [["susret"], ["doći"]]}], "hints": ["naravno da se sjećam", "rado se sjećam škole", "susret generacije", "voljela bih doći"], "models": ["Bok Oleh, naravno da se sjećam! Rado se sjećam škole i voljela bih doći na susret generacije."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '0eeac381-0af6-5eca-a78d-b3d18c33be25', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '4855fc97-e51d-5c0d-a963-7d628db21f3a', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'U školi je bila odlična učenica, ali je jednom markirala sat.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи Івані, що в школі я була відмінницею, але одного разу прогуляла урок.", "direction": "ua_hr", "points": [{"ua": "відмінниця", "keys": [["odličn"]]}, {"ua": "прогуляла урок", "keys": [["markira"]]}], "hints": [], "models": ["U školi je bila odlična učenica, ali je jednom markirala sat."], "source_ua": "Скажи Івані, що в школі я була відмінницею, але одного разу прогуляла урок."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '4855fc97-e51d-5c0d-a963-7d628db21f3a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f8450cb9-701d-533a-bf6d-d951fbffb98f', v_lesson, 'Пам’ятаєш?', 'Sjećaš li se?', 5181, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('fb88a5f4-a5b8-5d44-bd05-1db355e205ee', 'f8450cb9-701d-533a-bf6d-d951fbffb98f', 'Daša', 'Darja, sjećaš li se svoje prve učiteljice?', 'Дар’є, ти пам’ятаєш свою першу вчительку?', 1);
  perform pg_temp.turn('2c868a66-8d1f-5e0f-8f34-b1cb305bc56c', 'f8450cb9-701d-533a-bf6d-d951fbffb98f', 'Darja', 'Sjećam se, bila je stroga, ali pravedna.', 'Пам’ятаю, вона була сувора, але справедлива.', 2);
  perform pg_temp.turn('513d2969-d8c4-5c67-b9e7-2b338d0b27cb', 'f8450cb9-701d-533a-bf6d-d951fbffb98f', 'Daša', 'A koji ti je bio omiljeni predmet?', 'А який у тебе був улюблений предмет?', 3);
  perform pg_temp.turn('9023a5f6-5040-55ee-b999-267029e205a2', 'f8450cb9-701d-533a-bf6d-d951fbffb98f', 'Darja', 'Kemija. A fiziku sam mrzila, uvijek sam pisala loše kontrolne.', 'Хімія. А фізику я ненавиділа, завжди писала погані контрольні.', 4);
  perform pg_temp.turn('5dbb96ce-ae2b-5a5a-bd6d-96264cf95ede', 'f8450cb9-701d-533a-bf6d-d951fbffb98f', 'Daša', 'Ja sam na kontrolnom imala šalabahter u pernici!', 'А я на контрольній мала шпаргалку в пеналі!', 5);
  perform pg_temp.turn('045fa795-506f-5a1d-a973-190e12c70aeb', 'f8450cb9-701d-533a-bf6d-d951fbffb98f', 'Darja', 'I nisu te uhvatili?', 'І тебе не спіймали?', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('493a6993-cda0-5fee-b73f-735a7978d6d9', v_lesson, 'Прогул', 'Markiranje', 5182, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('6ffaf173-9c39-54eb-9b6b-21031aa5ea09', '493a6993-cda0-5fee-b73f-735a7978d6d9', 'Marko', 'Jednom smo cijeli razred markirali sat povijesti.', 'Одного разу ми всім класом прогуляли урок історії.', 1);
  perform pg_temp.turn('5c5080c9-7768-570a-8806-6f4f07aa11f2', '493a6993-cda0-5fee-b73f-735a7978d6d9', 'Ivan', 'I što se dogodilo?', 'І що сталося?', 2);
  perform pg_temp.turn('a8b5cec9-26a5-58fb-83bb-02b67f9f8c28', '493a6993-cda0-5fee-b73f-735a7978d6d9', 'Marko', 'Otišli smo u kino, ali ravnatelj nas je uhvatio na ulici.', 'Ми пішли в кіно, але директор спіймав нас на вулиці.', 3);
  perform pg_temp.turn('463e7825-02a9-5021-989e-bf3948ad71de', '493a6993-cda0-5fee-b73f-735a7978d6d9', 'Ivan', 'Jeste li dobili kaznu?', 'Вас покарали?', 4);
  perform pg_temp.turn('69fc3a0d-0e7b-5893-944c-f65f66558c97', '493a6993-cda0-5fee-b73f-735a7978d6d9', 'Marko', 'Jesmo. Jako smo se posramili, nikad to neću zaboraviti.', 'Так. Нам було дуже соромно, я ніколи цього не забуду.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.3 · урок 19: Колись і тепер: що змінилося — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '11144998-5b31-5d09-9988-9237a403f110';
  v_lesson constant uuid := 'b22c7dff-1657-5dad-94a6-5d059e346da8';
  v_gid constant uuid := '0b2de584-05a6-5570-a129-366fcb94766d';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики VID'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A2.3: місце 3 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 19: Колись і тепер: що змінилося', 'Lekcija 19: Nekad i sad: što se promijenilo', '["Порівняти, як було колись і як тепер", "Вживати вид у минулому: mijenjalo se — promijenilo se"]'::jsonb, 20, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'nekoć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tadašnji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nekadašnji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u ono vrijeme', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prije dvadeset godina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'promijeniti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mijenjati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'promjena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stari album', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crno-bijela fotografija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pisati pisma', v_pos);
  v_pos := pg_temp.word(v_lesson, 'telefonska govornica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'videokazeta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ploča', v_pos);
  v_pos := pg_temp.word(v_lesson, 'generacijski jaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'više ne postoji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nestati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izgraditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srušiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jednostavniji', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '4f0a914c-2892-5f7a-8b53-ea022533a85e', 'fill_in_the_blank', 'Za deset godina grad se potpuno ___.', 'promijenio', '["mijenjati", "promijenio", "mijenja", "promijeniti"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '558cc909-8279-5664-a135-c13af42fc0dd', 'multiple_choice', 'Що означає «više ne postoji»?', 'більше не існує', '["більше не існує", "двадцять років тому", "змінюватися", "простіший"]'::jsonb, 'A2', 2, 'PUBLISHED', 'više ne postoji', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5b929f50-f80d-53fa-82dc-6b514c0c61ab', 'multiple_choice', 'Що означає «ploča»?', 'платівка', '["платівка", "писати листи", "простіший", "колись, раніше"]'::jsonb, 'A2', 3, 'PUBLISHED', 'ploča', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '56c0fd90-445f-5f4c-9c1a-68b27c6f412d', 'multiple_choice', 'Що означає «generacijski jaz»?', 'розрив між поколіннями', '["чорно-біла фотографія", "колись, раніше", "розрив між поколіннями", "колишній"]'::jsonb, 'A2', 4, 'PUBLISHED', 'generacijski jaz', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '52cfe696-bb05-5a06-8a43-2fcae4990f6f', 'multiple_choice', 'Як хорватською «телефонна будка»?', 'telefonska govornica', '["srušiti", "crno-bijela fotografija", "telefonska govornica", "tada"]'::jsonb, 'A2', 5, 'PUBLISHED', 'telefonska govornica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '50c9afe1-7068-5610-ab2a-4bb48ee66048', 'multiple_choice', 'Як хорватською «зміна»?', 'promjena', '["promjena", "stari album", "crno-bijela fotografija", "izgraditi"]'::jsonb, 'A2', 6, 'PUBLISHED', 'promjena', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bb0ec237-bc1d-5cff-84e1-ff2a5e53222c', 'type_answer', 'Напишіть хорватською: «тоді»', 'tada', null, 'A2', 7, 'PUBLISHED', 'tada', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '99a5bb81-a413-5888-bf57-0938005df8e4', 'type_answer', 'Напишіть хорватською: «змінитися»', 'promijeniti se', null, 'A2', 8, 'PUBLISHED', 'promijeniti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2e97bf52-1ab9-558a-93b2-dd0b144e87ef', 'type_answer', 'Напишіть хорватською: «писати листи»', 'pisati pisma', null, 'A2', 9, 'PUBLISHED', 'pisati pisma', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7d790d25-b2f8-5328-8f09-daa041d13902', 'sentence_builder', 'Складіть: «Тоді в нас не було мобільних.»', 'Tada nismo imali mobitele.', '["nismo", "Tada", "imali", "mobitele."]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cff3ccf8-950b-57c3-9ee6-83a3ec424f80', 'sentence_builder', 'Складіть: «Ця крамниця більше не існує.»', 'Ta trgovina više ne postoji.', '["ne", "više", "postoji.", "trgovina", "Ta"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1522fa34-416d-5376-b5b3-4f9c6e636eff', 'listening', 'Прослухайте і складіть фразу', 'Jesu, prije deset godina. Grad se jako promijenio.', '["Jesu,", "Grad", "prije", "jako", "promijenio.", "godina.", "deset", "se"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '88844335-187c-554d-bd93-401003ab755b', 'listening_dialogue', 'Прослухайте новину', 'тютюнова фабрика; бібліотека й кафе; два роки', 'A2', 'PUBLISHED', '{"kind": "news", "situation_ua": "Ви слухаєте коротку новину на місцевому радіо.", "script": [{"hr": "Nekadašnja tvornica duhana u centru grada dobit će novu namjenu.", "ua": "Колишня тютюнова фабрика в центрі міста отримає нове призначення."}, {"hr": "Staru zgradu neće srušiti, nego će u njoj otvoriti knjižnicu i kafić.", "ua": "Стару будівлю не знесуть, а відкриють у ній бібліотеку й кафе."}, {"hr": "Radovi počinju na proljeće i trajat će dvije godine.", "ua": "Роботи почнуться навесні й триватимуть два роки."}], "questions": [{"q_ua": "Що була ця будівля колись?", "options": ["кінотеатр", "тютюнова фабрика", "пошта"], "correct": 1, "answer_turn": 0}, {"q_ua": "Що буде в будівлі?", "options": ["бібліотека й кафе", "торговий центр", "школа"], "correct": 0, "answer_turn": 1}, {"q_ua": "Скільки триватимуть роботи?", "options": ["рік", "пів року", "два роки"], "correct": 2, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '88844335-187c-554d-bd93-401003ab755b', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c3880169-25f2-5da9-86b1-e673ba2a32cd', 'speaking', 'Місто дуже змінилося.', 'Grad se jako promijenio.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cebabfb8-c9ef-5061-b565-7d356294e389', 'speaking', 'Колись тут була фабрика.', 'Nekoć je ovdje bila tvornica.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'a7fcc2e1-6dc0-50a0-87d9-9e6630b2e887', 'write_message', 'Напишіть подрузі, як змінилося ваше рідне місто: що було тоді і що є тепер.', 'Moj grad se jako promijenio. Tada je u centru bilo kino, a sad je tamo trgovački centar.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі, як змінилося ваше рідне місто: що було тоді і що є тепер.", "points": [{"ua": "тоді", "keys": [["tada"], ["nekoć"], ["nekad"], ["prije"]]}, {"ua": "тепер", "keys": [["sad"], ["danas"]]}, {"ua": "змінилося", "keys": [["promijeni"]]}], "hints": ["moj grad se promijenio", "tada je bilo", "a sad je", "srušili su"], "models": ["Moj grad se jako promijenio. Tada je u centru bilo kino, a sad je tamo trgovački centar."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'a7fcc2e1-6dc0-50a0-87d9-9e6630b2e887', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '447e48a6-f27c-5c85-96d3-a98c59e8fc5a', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Njegov tata još ima stare ploče i videokazete.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи Даші, що в мого тата досі є старі платівки й відеокасети.", "direction": "ua_hr", "points": [{"ua": "платівки", "keys": [["ploč"]]}, {"ua": "відеокасети", "keys": [["videokazet"]]}], "hints": [], "models": ["Njegov tata još ima stare ploče i videokazete."], "source_ua": "Скажи Даші, що в мого тата досі є старі платівки й відеокасети."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '447e48a6-f27c-5c85-96d3-a98c59e8fc5a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8f2df6ca-e24c-55d7-8b3f-201d52f3353f', v_lesson, 'Старі фото', 'Stare fotografije', 5191, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('980ed0cd-a06c-548a-bf71-6a9bf4fce3ae', '8f2df6ca-e24c-55d7-8b3f-201d52f3353f', 'Darja', 'Vidi ovu crno-bijelu fotografiju. To je moja baka prije pedeset godina.', 'Подивись на цю чорно-білу фотографію. Це моя бабуся п’ятдесят років тому.', 1);
  perform pg_temp.turn('29e7fe38-7162-5ce1-8222-2106e66cf34c', '8f2df6ca-e24c-55d7-8b3f-201d52f3353f', 'Daša', 'Kako je lijepa! A gdje je ovo?', 'Яка гарна! А де це?', 2);
  perform pg_temp.turn('e6b171da-d1b0-565e-9ecc-3b6a8b2b7191', '8f2df6ca-e24c-55d7-8b3f-201d52f3353f', 'Darja', 'U centru našeg grada. Tada je tu bilo kino, a sad je trgovački centar.', 'У центрі нашого міста. Тоді тут був кінотеатр, а тепер торговий центр.', 3);
  perform pg_temp.turn('8d9323b1-e166-50d1-b973-57db18a35334', '8f2df6ca-e24c-55d7-8b3f-201d52f3353f', 'Daša', 'Kino su srušili?', 'Кінотеатр знесли?', 4);
  perform pg_temp.turn('b5848756-a02f-579b-8c1c-cf60571bf8a5', '8f2df6ca-e24c-55d7-8b3f-201d52f3353f', 'Darja', 'Jesu, prije deset godina. Grad se jako promijenio.', 'Так, десять років тому. Місто дуже змінилося.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7b6dd53a-6ee3-5b74-a9b0-b3b0cbc5eac4', v_lesson, 'Колись і тепер', 'Nekad i sad', 5192, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('11c245f6-180e-5f66-9a49-f95912a695e1', '7b6dd53a-6ee3-5b74-a9b0-b3b0cbc5eac4', 'Marko', 'Tata kaže da je nekoć sve bilo jednostavnije.', 'Тато каже, що колись усе було простіше.', 1);
  perform pg_temp.turn('a989e87c-bbbd-5fd1-8d1c-a0ff316888cd', '7b6dd53a-6ee3-5b74-a9b0-b3b0cbc5eac4', 'Ivan', 'Možda. U ono vrijeme ljudi su pisali pisma i zvali iz telefonske govornice.', 'Можливо. У ті часи писали листи й дзвонили з телефонних будок.', 2);
  perform pg_temp.turn('92b8d002-497e-54ac-b665-829fac3240ca', '7b6dd53a-6ee3-5b74-a9b0-b3b0cbc5eac4', 'Marko', 'Moja djeca ne znaju što je videokazeta.', 'Мої діти не знають, що таке відеокасета.', 3);
  perform pg_temp.turn('cf056ab2-4a3c-5c42-83f3-4c2b7328a701', '7b6dd53a-6ee3-5b74-a9b0-b3b0cbc5eac4', 'Ivan', 'To je generacijski jaz. Ali stvari se stalno mijenjaju.', 'Це конфлікт поколінь. Але все постійно змінюється.', 4);
  perform pg_temp.turn('eaec65b9-1cf1-5726-ab5d-1562a3cc0ded', '7b6dd53a-6ee3-5b74-a9b0-b3b0cbc5eac4', 'Marko', 'Istina. Samo je tatin stari album ostao isti.', 'Правда. Лише татів старий альбом лишився таким самим.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.3 · урок 20: Великий переїзд: зміни в житті — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '11144998-5b31-5d09-9988-9237a403f110';
  v_lesson constant uuid := '3dfc3a66-be3b-5760-8273-f00b5cb03871';
  v_gid constant uuid := '59c6c708-59b5-5781-bf5d-4ecd5aa8b7dc';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики ZAV'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A2.3: місце 4 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 20: Великий переїзд: зміни в житті', 'Lekcija 20: Velika selidba: promjene u životu', '["Розповісти про переїзд і перші місяці: kad, nakon što, čim", "Говорити про почуття: teško mi je bilo, navikla sam se"]'::jsonb, 20, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'napustiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rodno mjesto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'novi početak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prvi mjeseci', v_pos);
  v_pos := pg_temp.word(v_lesson, 'priviknuti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čežnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podrška', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prekretnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nakon što', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prije nego što', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čim', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spakirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kofer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponijeti sa sobom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ostaviti iza sebe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'olakšanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponosan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'samoća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osjećati se izgubljeno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preseljenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hrabrost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neizvjesnost', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c0a3de15-846e-5263-8d0b-5a2d471464af', 'fill_in_the_blank', '___ smo našli stan, sve je bilo lakše.', 'Nakon što', '["Dok", "Prije nego što", "Ako", "Nakon što"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f05e0c1-2a1f-57fd-a645-1c9eb1c3c5c0', 'multiple_choice', 'Що означає «ostaviti iza sebe»?', 'залишити позаду', '["туга", "залишити позаду", "звикнути", "після того як"]'::jsonb, 'A2', 2, 'PUBLISHED', 'ostaviti iza sebe', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bc9cc2eb-74d3-5130-9493-3bb7f9867c74', 'multiple_choice', 'Що означає «ponijeti sa sobom»?', 'взяти з собою', '["перші місяці", "переселення, переїзд (в іншу країну)", "взяти з собою", "спакувати"]'::jsonb, 'A2', 3, 'PUBLISHED', 'ponijeti sa sobom', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd4b7e5a6-20bb-5455-867d-33e244269b6c', 'multiple_choice', 'Що означає «prekretnica»?', 'поворотний момент', '["самотність", "почуватися розгубленим", "поворотний момент", "після того як"]'::jsonb, 'A2', 4, 'PUBLISHED', 'prekretnica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '77e7edc9-02ac-57b1-ad8b-8380fd7a7830', 'multiple_choice', 'Як хорватською «сміливість»?', 'hrabrost', '["napustiti", "prije nego što", "hrabrost", "spakirati"]'::jsonb, 'A2', 5, 'PUBLISHED', 'hrabrost', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0be113d5-4ff0-5532-814d-554e2d01c88e', 'multiple_choice', 'Як хорватською «новий початок»?', 'novi početak', '["napustiti", "čim", "novi početak", "ponijeti sa sobom"]'::jsonb, 'A2', 6, 'PUBLISHED', 'novi početak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ff5029e-a8d4-5d8c-b8e1-5b00c675c8ee', 'type_answer', 'Напишіть хорватською: «туга»', 'čežnja', null, 'A2', 7, 'PUBLISHED', 'čežnja', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '815b0a11-b3b0-54bf-b9a6-1162ad6a7b1f', 'type_answer', 'Напишіть хорватською: «невизначеність»', 'neizvjesnost', null, 'A2', 8, 'PUBLISHED', 'neizvjesnost', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e2a437a0-774a-5f26-967e-d520ac8f8aab', 'type_answer', 'Напишіть хорватською: «перші місяці»', 'prvi mjeseci', null, 'A2', 9, 'PUBLISHED', 'prvi mjeseci', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3e261a5f-7903-5b95-843c-57a3b11f40a5', 'sentence_builder', 'Складіть: «Перші місяці були найважчі.»', 'Prvi mjeseci su bili najteži.', '["bili", "mjeseci", "su", "najteži.", "Prvi"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b715a90b-a364-5e1b-b5a6-677ebfa794a1', 'sentence_builder', 'Складіть: «Ми швидко звикли до нового міста.»', 'Brzo smo se priviknuli na novi grad.', '["priviknuli", "smo", "Brzo", "se", "grad.", "novi", "na"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2d638f2c-9ea0-5b47-9169-9c4c70ea0f06', 'listening', 'Прослухайте і складіть фразу', 'Samo dva kofera. Spakirali smo dokumente, odjeću i fotografije.', '["dva", "dokumente,", "fotografije.", "Spakirali", "kofera.", "smo", "i", "Samo", "odjeću"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'e00e7fb2-1c2a-56e8-a9b8-d10f7fc4d684', 'listening_dialogue', 'Прослухайте розмову', 'з двома дітьми; мова; у садочку', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Журналістка місцевого радіо розмовляє з Дар’єю. Послухайте.", "script": [{"speaker": "Novinarka", "hr": "Kada ste došli u Rijeku?", "ua": "Коли ви приїхали до Рієки?"}, {"speaker": "Darja", "hr": "U travnju 2022. godine, s dvoje djece.", "ua": "У квітні 2022 року, з двома дітьми."}, {"speaker": "Novinarka", "hr": "Što Vam je bilo najteže?", "ua": "Що для вас було найважче?"}, {"speaker": "Darja", "hr": "Jezik. Ali nakon što sam završila tečaj, našla sam posao u vrtiću.", "ua": "Мова. Але після того як я закінчила курс, знайшла роботу в садочку."}], "questions": [{"q_ua": "З ким приїхала Дар’я?", "options": ["з чоловіком", "з двома дітьми", "з мамою"], "correct": 1, "answer_turn": 1}, {"q_ua": "Що було найважчим?", "options": ["мова", "житло", "клімат"], "correct": 0, "answer_turn": 3}, {"q_ua": "Де Дар’я знайшла роботу?", "options": ["у школі", "у магазині", "у садочку"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'e00e7fb2-1c2a-56e8-a9b8-d10f7fc4d684', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c2f47976-8021-5971-bb29-2f9cf9061e52', 'speaking', 'Я сумую за мамою.', 'Nedostaje mi mama.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '461dc9ef-817c-5640-ba8e-c5f71be197e7', 'speaking', 'Щойно я приїхала, записалася на курс.', 'Čim sam stigla, upisala sam tečaj.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '4de1031e-6558-5d6f-8178-5354758749f1', 'write_message', 'Напишіть кілька речень для місцевої газети: коли ви переїхали до Хорватії, що було найважче і як ви звикли.', 'U Hrvatsku smo došli 2022. godine. Najteže mi je bio jezik, ali nakon što sam upisala tečaj, priviknula sam se.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть кілька речень для місцевої газети: коли ви переїхали до Хорватії, що було найважче і як ви звикли.", "points": [{"ua": "коли переїхали", "keys": [["doš"], ["stigl"], ["preseli"]]}, {"ua": "що було найважче", "keys": [["najtež"]]}, {"ua": "як звикли", "keys": [["privik"], ["navik"], ["snaš"]]}], "hints": ["došli smo u…", "najteže mi je bilo", "nakon što sam", "priviknula sam se"], "models": ["U Hrvatsku smo došli 2022. godine. Najteže mi je bio jezik, ali nakon što sam upisala tečaj, priviknula sam se."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '4de1031e-6558-5d6f-8178-5354758749f1', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '89c93b34-dba1-577c-9d85-374bee439ab1', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Ponijeli su samo dva kofera, ali sad imaju stan i posao.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи Івані, що ми взяли з собою лише дві валізи, але тепер у нас є квартира й робота.", "direction": "ua_hr", "points": [{"ua": "дві валізи", "keys": [["kofer"]]}, {"ua": "квартира", "keys": [["stan"]]}, {"ua": "робота", "keys": [["posao"]]}], "hints": [], "models": ["Ponijeli su samo dva kofera, ali sad imaju stan i posao."], "source_ua": "Скажи Івані, що ми взяли з собою лише дві валізи, але тепер у нас є квартира й робота."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '89c93b34-dba1-577c-9d85-374bee439ab1', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7d98114a-7fb1-5f95-ac16-e140a5ecaad9', v_lesson, 'Перші місяці', 'Prvi mjeseci', 5201, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('54980392-1d92-5664-afae-017d7ec2fabc', '7d98114a-7fb1-5f95-ac16-e140a5ecaad9', 'Ivana', 'Darja, kako su izgledali prvi mjeseci u Hrvatskoj?', 'Дар’є, якими були перші місяці в Хорватії?', 1);
  perform pg_temp.turn('f21808e8-ece4-544e-b4cb-d0f05d059891', '7d98114a-7fb1-5f95-ac16-e140a5ecaad9', 'Darja', 'Teški. Nisam se znala snaći, a nedostajala mi je mama.', 'Важкими. Я не знала, як дати собі раду, а ще сумувала за мамою.', 2);
  perform pg_temp.turn('c841491f-e751-56be-bf02-21303b9e8e73', '7d98114a-7fb1-5f95-ac16-e140a5ecaad9', 'Ivana', 'Jesi li se osjećala usamljeno?', 'Ти почувалася самотньою?', 3);
  perform pg_temp.turn('bca855a9-7b88-5820-90de-953c0764abfa', '7d98114a-7fb1-5f95-ac16-e140a5ecaad9', 'Darja', 'Na početku jesam. Ali čim sam upisala tečaj, upoznala sam ljude.', 'Спочатку так. Але щойно я записалася на курс, познайомилася з людьми.', 4);
  perform pg_temp.turn('eb6fb5f3-cb45-5197-a5cb-14dc94299a94', '7d98114a-7fb1-5f95-ac16-e140a5ecaad9', 'Ivana', 'A sad?', 'А тепер?', 5);
  perform pg_temp.turn('c2e9de3a-ab21-54ef-bee2-e12dc4e9602d', '7d98114a-7fb1-5f95-ac16-e140a5ecaad9', 'Darja', 'Sad sam se priviknula. Ponosna sam na sve što smo postigli.', 'Тепер я звикла. Я пишаюся всім, чого ми досягли.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('718c8f34-e896-5b7f-9188-585ae107ad5d', v_lesson, 'Дві валізи', 'Dva kofera', 5202, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('32356436-a9a8-57e0-bea3-af51e5dc81c5', '718c8f34-e896-5b7f-9188-585ae107ad5d', 'Marko', 'Što ste ponijeli sa sobom kad ste se selili?', 'Що ви взяли з собою, коли переїжджали?', 1);
  perform pg_temp.turn('23a71383-8459-5b01-8611-fde29010ab34', '718c8f34-e896-5b7f-9188-585ae107ad5d', 'Daša', 'Samo dva kofera. Spakirali smo dokumente, odjeću i fotografije.', 'Лише дві валізи. Спакували документи, одяг і фотографії.', 2);
  perform pg_temp.turn('9e14756d-38bc-5cc1-b835-addda111478c', '718c8f34-e896-5b7f-9188-585ae107ad5d', 'Marko', 'Sve ostalo ste ostavili iza sebe?', 'А все інше залишили позаду?', 3);
  perform pg_temp.turn('c3d1189e-faf9-53dd-9302-2d6624f32ed4', '718c8f34-e896-5b7f-9188-585ae107ad5d', 'Daša', 'Jesmo. Ali nakon što smo našli stan, osjetila sam olakšanje.', 'Так. Але після того як ми знайшли квартиру, я відчула полегшення.', 4);
  perform pg_temp.turn('382f31d2-c713-5af6-a08b-4ba18fdaa5cf', '718c8f34-e896-5b7f-9188-585ae107ad5d', 'Marko', 'To je bio novi početak.', 'Це був новий початок.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.3 · урок 21: Розкажи історію: що сталося? — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '11144998-5b31-5d09-9988-9237a403f110';
  v_lesson constant uuid := '6440a67e-bb4f-507e-ae20-ebf59c66424e';
  v_gid constant uuid := 'feaaa674-66e6-5521-ba6e-b5d1507cd351';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики PERF'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A2.3: місце 5 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 21: Розкажи історію: що сталося?', 'Lekcija 21: Ispričaj priču: što se dogodilo?', '["Розповісти історію по порядку: najprije, zatim, odjednom, napokon", "Поєднувати «фон» і події: Čekala sam autobus kad je…"]'::jsonb, 20, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'najprije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iznenada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'napokon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srećom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nažalost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispričati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zgoda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'doživljaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nezaboravan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uplašiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iznenaditi se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nasmijati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nestati struje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaglaviti u liftu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izgubiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pozvati pomoć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spasiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispasti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slučajno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u tom trenutku', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd37cba23-4452-56a9-9e87-9f09e3b11a7d', 'fill_in_the_blank', 'Čekala sam autobus kad je iznenada ___ kiša.', 'počela', '["počela", "počinjala", "početi", "počinje"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '043bdcc7-c486-5ad8-ab27-1f83ae2659d6', 'multiple_choice', 'Що означає «zgoda»?', 'випадок, пригода', '["на жаль", "злякатися", "випадок, пригода", "на щастя"]'::jsonb, 'A2', 2, 'PUBLISHED', 'zgoda', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '07b6b06f-5377-5c2d-9a9f-bd1b29767d48', 'multiple_choice', 'Що означає «doživljaj»?', 'пригода, враження', '["пригода, враження", "розповісти", "зникнути (про світло)", "врятувати"]'::jsonb, 'A2', 3, 'PUBLISHED', 'doživljaj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a12b02ea-2da8-505e-bdfb-312e0b938fa1', 'multiple_choice', 'Що означає «srećom»?', 'на щастя', '["на щастя", "у ту мить", "на жаль", "випасти"]'::jsonb, 'A2', 4, 'PUBLISHED', 'srećom', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e0a61e0a-bb23-5e06-bbf3-b8cf056ccaaa', 'multiple_choice', 'Як хорватською «застрягнути в ліфті»?', 'zaglaviti u liftu', '["ispričati", "nezaboravan", "zaglaviti u liftu", "nestati struje"]'::jsonb, 'A2', 5, 'PUBLISHED', 'zaglaviti u liftu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b348c16c-c2e1-5d55-b6a9-16487169734c', 'multiple_choice', 'Як хорватською «врятувати»?', 'spasiti', '["nažalost", "spasiti", "nasmijati se", "zgoda"]'::jsonb, 'A2', 6, 'PUBLISHED', 'spasiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a16108e2-c964-5db6-a754-1defe370aacc', 'type_answer', 'Напишіть хорватською: «нарешті»', 'napokon', null, 'A2', 7, 'PUBLISHED', 'napokon', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3c1f6931-9dd2-546a-b91d-bcc12712048b', 'type_answer', 'Напишіть хорватською: «випасти»', 'ispasti', null, 'A2', 8, 'PUBLISHED', 'ispasti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1fe0feb0-25bd-5944-bd8e-4f8b8d441a70', 'type_answer', 'Напишіть хорватською: «здивуватися»', 'iznenaditi se', null, 'A2', 9, 'PUBLISHED', 'iznenaditi se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d2cd03b-4b39-5b08-8a05-a5d62da8c11e', 'sentence_builder', 'Складіть: «Нарешті ми приїхали додому.»', 'Napokon smo stigli kući.', '["stigli", "Napokon", "kući.", "smo"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5ffe127a-6eea-5d35-bd1f-008b2c716de5', 'sentence_builder', 'Складіть: «Ми заблукали в старому місті.»', 'Izgubili smo se u starom gradu.', '["starom", "gradu.", "smo", "u", "Izgubili", "se"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fb8a2846-0757-509e-8383-fe6a8424dd71', 'listening', 'Прослухайте і складіть фразу', 'Srećom, jedan dječak je skočio i izvadio ga.', '["jedan", "Srećom,", "je", "dječak", "skočio", "i", "izvadio", "ga."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'e02d856a-7917-560e-bd57-bae7ebc578e5', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'вони заблукали; колега Даші; у номері готелю', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Даша надіслала вам голосове повідомлення з поїздки.", "script": [{"hr": "Bok, nećeš vjerovati što nam se dogodilo!", "ua": "Привіт, ти не повіриш, що з нами сталося!"}, {"hr": "Najprije smo se izgubili u Dubrovniku, a zatim nam je pobjegao autobus.", "ua": "Спочатку ми заблукали в Дубровнику, а потім пропустили автобус."}, {"hr": "Slučajno smo sreli moju kolegicu i ona nas je odvezla do hotela.", "ua": "Випадково ми зустріли мою колегу, і вона відвезла нас до готелю."}, {"hr": "Napokon smo u sobi, sve je u redu!", "ua": "Нарешті ми в номері, усе гаразд!"}], "questions": [{"q_ua": "Що сталося спочатку?", "options": ["вони заблукали", "зник мобільний", "пішов дощ"], "correct": 0, "answer_turn": 1}, {"q_ua": "Хто відвіз їх до готелю?", "options": ["таксист", "колега Даші", "поліція"], "correct": 1, "answer_turn": 2}, {"q_ua": "Де вони зараз?", "options": ["на автовокзалі", "у ресторані", "у номері готелю"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'e02d856a-7917-560e-bd57-bae7ebc578e5', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '972da0ef-bb3b-5c23-aa3c-f1563337d296', 'speaking', 'Мушу розповісти тобі, що сталося.', 'Moram ti ispričati što se dogodilo.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7a580b9f-1f1c-577f-bc47-28f4b05f3119', 'speaking', 'На щастя, ніхто не постраждав.', 'Srećom, nitko nije bio ozlijeđen.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'c7b6a3cf-5195-5e7c-b0c8-323d9c3d7488', 'write_message', 'Напишіть другові коротку історію: учора ви застрягли в ліфті, злякалися, і сусід вас урятував.', 'Jučer sam zaglavila u liftu i jako sam se uplašila. Srećom, susjed me spasio nakon pola sata.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть другові коротку історію: учора ви застрягли в ліфті, злякалися, і сусід вас урятував.", "points": [{"ua": "застрягли в ліфті", "keys": [["lift"]]}, {"ua": "злякалися", "keys": [["uplaš"]]}, {"ua": "сусід урятував", "keys": [["susjed"]]}], "hints": ["jučer sam zaglavila u liftu", "uplašila sam se", "srećom", "susjed me spasio"], "models": ["Jučer sam zaglavila u liftu i jako sam se uplašila. Srećom, susjed me spasio nakon pola sata."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'c7b6a3cf-5195-5e7c-b0c8-323d9c3d7488', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'd667b465-b724-548f-864b-076c8ca4b410', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Mobitel mu je ispao u more, ali ga je jedan dječak izvadio.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Розкажи Іванові, що в мене випав телефон у море, але хлопчик його дістав.", "direction": "ua_hr", "points": [{"ua": "телефон", "keys": [["mobitel"], ["telefon"]]}, {"ua": "в море", "keys": [["more"]]}, {"ua": "хлопчик дістав", "keys": [["dječak"]]}], "hints": [], "models": ["Mobitel mu je ispao u more, ali ga je jedan dječak izvadio."], "source_ua": "Розкажи Іванові, що в мене випав телефон у море, але хлопчик його дістав."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'd667b465-b724-548f-864b-076c8ca4b410', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ae63dd4b-cd6f-5979-9c7f-86a46608e19d', v_lesson, 'У ліфті', 'U liftu', 5211, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('ddb0ab43-2276-5ff3-80cf-1cebb65d045a', 'ae63dd4b-cd6f-5979-9c7f-86a46608e19d', 'Daša', 'Moram ti ispričati što mi se jučer dogodilo!', 'Мушу розповісти тобі, що зі мною сталося вчора!', 1);
  perform pg_temp.turn('b3edaeb8-7518-52f0-a12b-af097210f14b', 'ae63dd4b-cd6f-5979-9c7f-86a46608e19d', 'Darja', 'Što?', 'Що?', 2);
  perform pg_temp.turn('289e76ba-4af9-56af-80d5-8cb1aa38ec73', 'ae63dd4b-cd6f-5979-9c7f-86a46608e19d', 'Daša', 'Vozila sam se liftom na posao kad je iznenada nestalo struje.', 'Я їхала ліфтом на роботу, коли раптом зникло світло.', 3);
  perform pg_temp.turn('8560457a-3eb6-5f09-a809-2ca174eefa20', 'ae63dd4b-cd6f-5979-9c7f-86a46608e19d', 'Darja', 'Joj! Jesi li se uplašila?', 'Ой! Ти злякалася?', 4);
  perform pg_temp.turn('2f6f02bf-4f52-5c68-baf8-7fdfeacf392a', 'ae63dd4b-cd6f-5979-9c7f-86a46608e19d', 'Daša', 'Jako. Zaglavila sam u liftu sat vremena. Najprije sam vikala, a zatim pozvala pomoć.', 'Дуже. Я застрягла в ліфті на годину. Спочатку кричала, а потім покликала на допомогу.', 5);
  perform pg_temp.turn('9a8488b3-33e3-5002-b127-d8d3fb516c31', 'ae63dd4b-cd6f-5979-9c7f-86a46608e19d', 'Darja', 'I tko te spasio?', 'І хто тебе врятував?', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5a24e65b-d934-529b-be97-ac5da283b423', v_lesson, 'Мобільний у морі', 'Mobitel u moru', 5212, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('db1af7ca-70d9-5737-9e08-48d2c897b2f8', '5a24e65b-d934-529b-be97-ac5da283b423', 'Marko', 'Ljetos mi se dogodila smiješna zgoda.', 'Цього літа зі мною стався кумедний випадок.', 1);
  perform pg_temp.turn('2d6fc193-54f6-5713-a724-f4e567e436c6', '5a24e65b-d934-529b-be97-ac5da283b423', 'Ivan', 'Pričaj!', 'Розповідай!', 2);
  perform pg_temp.turn('dadd658a-98ee-54b5-ac4b-3f906f847f56', '5a24e65b-d934-529b-be97-ac5da283b423', 'Marko', 'Slikao sam zalazak sunca s mola, i u tom trenutku mi je mobitel ispao u more.', 'Я фотографував захід сонця з молу, і в ту мить мобільний випав у море.', 3);
  perform pg_temp.turn('d67edb2f-e743-56a8-9006-a769b145ed3a', '5a24e65b-d934-529b-be97-ac5da283b423', 'Ivan', 'Ma nemoj! I što si napravio?', 'Та ти що! І що ти зробив?', 4);
  perform pg_temp.turn('3d3bb605-c1be-5583-a5a3-aef1240c8fbc', '5a24e65b-d934-529b-be97-ac5da283b423', 'Marko', 'Srećom, jedan dječak je skočio i izvadio ga. Svi su se nasmijali.', 'На щастя, один хлопчик стрибнув і дістав його. Усі засміялися.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.3 · урок 22: Важливі дати й події — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '11144998-5b31-5d09-9988-9237a403f110';
  v_lesson constant uuid := 'c8c098bc-973f-5a79-b42a-5ec5c7152d09';
  v_gid constant uuid := 'd1e0a0ca-707a-5b16-bcdf-06037cb17e0e';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики NUM'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A2.3: місце 6 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 22: Важливі дати й події', 'Lekcija 22: Važni datumi i događaji', '["Назвати дати свого життя: народження, школа, весілля, переїзд", "Правильно говорити числа й дати: petog svibnja 1990. godine, dvoje djece"]'::jsonb, 20, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'rođenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obljetnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'diplomirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'umrijeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'desetljeće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dvoje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'troje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oboje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najstariji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najmlađi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'važan događaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prekretnički trenutak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'od tada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iste godine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godinu dana kasnije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godina rođenja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srebrni pir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zlatni pir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otići u mirovinu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obiteljsko stablo', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dec6bf60-56bd-51f6-9802-d10b6935ebb6', 'fill_in_the_blank', 'Imamo ___ djece: sina i kćer.', 'dvoje', '["dvije", "dva", "dvoje", "oba"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd3cff916-989e-5db2-a67a-d30d1c1a94ea', 'multiple_choice', 'Що означає «rođenje»?', 'народження', '["обидва", "народження", "обоє", "срібне весілля"]'::jsonb, 'A2', 2, 'PUBLISHED', 'rođenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '975d536e-6a96-520b-abf2-a04da067fd31', 'multiple_choice', 'Що означає «zlatni pir»?', 'золоте весілля', '["десятиліття", "обоє", "золоте весілля", "вийти на пенсію"]'::jsonb, 'A2', 3, 'PUBLISHED', 'zlatni pir', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '65552c92-acab-5e84-bff3-6db649095dd1', 'multiple_choice', 'Що означає «prekretnički trenutak»?', 'переломний момент', '["переломний момент", "золоте весілля", "обоє", "троє"]'::jsonb, 'A2', 4, 'PUBLISHED', 'prekretnički trenutak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd063ab92-0bbc-5e18-a149-e66ade52a8fb', 'multiple_choice', 'Як хорватською «обидва»?', 'oba', '["zlatni pir", "oba", "rođenje", "troje"]'::jsonb, 'A2', 5, 'PUBLISHED', 'oba', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3bc4f2b4-9d3f-5274-b042-445e1d092763', 'multiple_choice', 'Як хорватською «важлива подія»?', 'važan događaj', '["najstariji", "važan događaj", "dvoje", "obje"]'::jsonb, 'A2', 6, 'PUBLISHED', 'važan događaj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0beb3a34-62c9-572e-936c-e9e5fd5649d5', 'type_answer', 'Напишіть хорватською: «троє»', 'troje', null, 'A2', 7, 'PUBLISHED', 'troje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd5d83068-ca76-511b-9659-4803e28ee7f7', 'type_answer', 'Напишіть хорватською: «закінчити університет (здобути диплом)»', 'diplomirati', null, 'A2', 8, 'PUBLISHED', 'diplomirati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ca89f3a3-6c1b-5cea-9e5c-71c48158162a', 'type_answer', 'Напишіть хорватською: «найстарший»', 'najstariji', null, 'A2', 9, 'PUBLISHED', 'najstariji', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f87b2519-0d4c-54e6-946a-d85ac81dd586', 'sentence_builder', 'Складіть: «Ми обоє народилися в Києві.»', 'Oboje smo rođeni u Kijevu.', '["u", "rođeni", "Kijevu.", "smo", "Oboje"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5c064673-d552-5b62-a538-5659e7d703dc', 'sentence_builder', 'Складіть: «Відтоді ми живемо в Спліті.»', 'Od tada živimo u Splitu.', '["Od", "Splitu.", "u", "živimo", "tada"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bd61353b-db06-57f8-9db1-9fe493bbf79c', 'listening', 'Прослухайте і складіть фразу', 'Obje. A roditelji su oboje u Osijeku.', '["oboje", "su", "Osijeku.", "u", "A", "Obje.", "roditelji"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'bae1567c-3070-587b-8167-4411d1ee4077', 'listening_dialogue', 'Прослухайте розмову', '21 квітня 1990; у Полтаві', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Дар’я заповнює анкету в банку. Послухайте розмову.", "script": [{"speaker": "Službenik", "hr": "Vaš datum rođenja, molim.", "ua": "Вашу дату народження, будь ласка."}, {"speaker": "Darja", "hr": "Dvadeset prvi travnja tisuću devetsto devedesete.", "ua": "Двадцять перше квітня тисяча дев’ятсот дев’яностого."}, {"speaker": "Službenik", "hr": "Mjesto rođenja?", "ua": "Місце народження?"}, {"speaker": "Darja", "hr": "Poltava, Ukrajina. Imam i dvoje djece, trebaju li i njihovi podaci?", "ua": "Полтава, Україна. У мене ще двоє дітей, їхні дані теж потрібні?"}], "questions": [{"q_ua": "Коли народилася Дар’я?", "options": ["21 квітня 1990", "12 квітня 1990", "21 травня 1999"], "correct": 0, "answer_turn": 1}, {"q_ua": "Де народилася Дар’я?", "options": ["у Києві", "у Полтаві", "в Одесі"], "correct": 1, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'bae1567c-3070-587b-8167-4411d1ee4077', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '09bc1929-1117-5905-a390-99aeccaa60ba', 'speaking', 'Я народилася п’ятого травня.', 'Rođena sam petog svibnja.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '00753b7c-5eee-57e0-882f-54d4e6a3d0ef', 'speaking', 'У нас двоє дітей.', 'Imamo dvoje djece.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'bc73d289-5165-5b87-a517-55cf52f1542d', 'write_message', 'Напишіть кілька речень про важливі дати свого життя: коли ви народилися, коли переїхали і що сталося відтоді.', 'Rođena sam 1990. godine u Poltavi. U Hrvatsku smo se preselili 2022. godine i od tada živimo u Rijeci.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть кілька речень про важливі дати свого життя: коли ви народилися, коли переїхали і що сталося відтоді.", "points": [{"ua": "коли народилися", "keys": [["rođen"]]}, {"ua": "коли переїхали", "keys": [["preseli"], ["doš"]]}, {"ua": "відтоді", "keys": [["od tada"]]}], "hints": ["rođena sam…", "preselili smo se…", "od tada…", "godine"], "models": ["Rođena sam 1990. godine u Poltavi. U Hrvatsku smo se preselili 2022. godine i od tada živimo u Rijeci."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'bc73d289-5165-5b87-a517-55cf52f1542d', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '068bd842-d681-5b6c-814a-8350c01459ea', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Ima dvoje djece i oboje idu u školu.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи службовцеві, що в мене двоє дітей і обоє ходять до школи.", "direction": "ua_hr", "points": [{"ua": "двоє дітей", "keys": [["dvoje"]]}, {"ua": "обоє до школи", "keys": [["oboje"], ["oba"], ["škol"]]}], "hints": [], "models": ["Ima dvoje djece i oboje idu u školu."], "source_ua": "Скажи службовцеві, що в мене двоє дітей і обоє ходять до школи."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '068bd842-d681-5b6c-814a-8350c01459ea', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('324f97d8-d3d9-5b76-ab60-3c6c77f195ab', v_lesson, 'Дати мого життя', 'Datumi moga života', 5221, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('b56ca631-36d6-5d42-b7c1-e24cd77e2913', '324f97d8-d3d9-5b76-ab60-3c6c77f195ab', 'Ivana', 'Kad si rođena, Darja?', 'Коли ти народилася, Дар’є?', 1);
  perform pg_temp.turn('dfd6b4bd-aa59-5b5a-9689-0ba48aa96d3e', '324f97d8-d3d9-5b76-ab60-3c6c77f195ab', 'Darja', 'Dvadeset prvog travnja tisuću devetsto devedesete.', 'Двадцять першого квітня тисяча дев’ятсот дев’яностого.', 2);
  perform pg_temp.turn('05019abe-4983-5761-a373-437d5c4a2aa9', '324f97d8-d3d9-5b76-ab60-3c6c77f195ab', 'Ivana', 'A kad ste se vjenčali?', 'А коли ви одружилися?', 3);
  perform pg_temp.turn('9ab922a1-e612-54d8-a158-ac114ee66106', '324f97d8-d3d9-5b76-ab60-3c6c77f195ab', 'Darja', 'Dvije tisuće petnaeste. Iste godine sam diplomirala.', 'Дві тисячі п’ятнадцятого. Того самого року я закінчила університет.', 4);
  perform pg_temp.turn('7c84364f-6c79-5ca2-bcc9-98c9919c2772', '324f97d8-d3d9-5b76-ab60-3c6c77f195ab', 'Ivana', 'Imate li djece?', 'У вас є діти?', 5);
  perform pg_temp.turn('5f0a1c09-2690-5bb6-8fbd-6c99daf4f6ce', '324f97d8-d3d9-5b76-ab60-3c6c77f195ab', 'Darja', 'Imamo dvoje. Filip se rodio godinu dana kasnije.', 'Маємо двох. Філіп народився через рік.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7ee5cbe6-8947-5417-94f6-cb4a8aa9da36', v_lesson, 'Велика родина', 'Velika obitelj', 5222, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('dc1607a6-2c67-5262-bfd6-6110918d6197', '7ee5cbe6-8947-5417-94f6-cb4a8aa9da36', 'Daša', 'Marko, koliko vas je u obitelji?', 'Марку, скільки вас у родині?', 1);
  perform pg_temp.turn('42a65d4a-7509-5001-98af-d4588265a5e3', '7ee5cbe6-8947-5417-94f6-cb4a8aa9da36', 'Marko', 'Nas je troje djece. Ja sam najstariji, a sestre su blizanke.', 'Нас троє дітей. Я найстарший, а сестри — близнючки.', 2);
  perform pg_temp.turn('7f431d79-e350-58ea-ac96-7f13788b691b', '7ee5cbe6-8947-5417-94f6-cb4a8aa9da36', 'Daša', 'Žive li obje u Zagrebu?', 'Обидві живуть у Загребі?', 3);
  perform pg_temp.turn('edec0a6d-179f-51a9-96f0-08edb77bd664', '7ee5cbe6-8947-5417-94f6-cb4a8aa9da36', 'Marko', 'Obje. A roditelji su oboje u Osijeku.', 'Обидві. А батьки обоє в Осієку.', 4);
  perform pg_temp.turn('ad5a30f4-e9bf-5b93-9779-dfaba3d34862', '7ee5cbe6-8947-5417-94f6-cb4a8aa9da36', 'Daša', 'Kad se nađete svi zajedno?', 'Коли ви збираєтеся всі разом?', 5);
  perform pg_temp.turn('07e310ac-d18a-5d0f-ba2b-c3269832053d', '7ee5cbe6-8947-5417-94f6-cb4a8aa9da36', 'Marko', 'Za obljetnicu braka roditelja, svake godine u lipnju.', 'На річницю шлюбу батьків, щороку в червні.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- 3. Модуль і юніт — опубліковані
update public.modules set status = 'PUBLISHED', title_ua = 'Модуль A2.3 — Моє минуле: дитинство й спогади', title_hr = 'Modul A2.3 — Moja prošlost: djetinjstvo i sjećanja' where id = '38b2ee69-f7d3-5de2-8208-b1fa31501558';
update public.units set status = 'PUBLISHED' where id = '11144998-5b31-5d09-9988-9237a403f110';

-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('65e0eec5-f830-5509-a807-db00ace41075', '92226a59-39e3-5dba-b0df-1e91b3dd2210', 'b22c7dff-1657-5dad-94a6-5d059e346da8', '3dfc3a66-be3b-5760-8273-f00b5cb03871', '6440a67e-bb4f-507e-ae20-ebf59c66424e', 'c8c098bc-973f-5a79-b42a-5ec5c7152d09')
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
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 20 or l.unit_id <> '11144998-5b31-5d09-9988-9237a403f110');
  select count(*) into v_titles from (values ('65e0eec5-f830-5509-a807-db00ace41075'::uuid, 'Урок 17:%', 1), ('92226a59-39e3-5dba-b0df-1e91b3dd2210'::uuid, 'Урок 18:%', 2), ('b22c7dff-1657-5dad-94a6-5d059e346da8'::uuid, 'Урок 19:%', 3), ('3dfc3a66-be3b-5760-8273-f00b5cb03871'::uuid, 'Урок 20:%', 4), ('6440a67e-bb4f-507e-ae20-ebf59c66424e'::uuid, 'Урок 21:%', 5), ('c8c098bc-973f-5a79-b42a-5ec5c7152d09'::uuid, 'Урок 22:%', 6)) as t(id, pat, o)
    left join public.lessons l on l.id = t.id and l.title_ua like t.pat and l.order_index = t.o
   where l.id is null;
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
      where l.level_code = 'A2' and l.status = 'PUBLISHED' and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A2.3: % уроків з неправильним складом', v_bad; end if;
  if v_titles > 0 then raise exception 'Модуль A2.3: % уроків не на своєму місці чи з неправильним номером', v_titles; end if;
  if v_words > 0 then raise exception 'A2: % слів повторюються в кількох уроках', v_words; end if;
  if (select status from public.modules where id = '38b2ee69-f7d3-5de2-8208-b1fa31501558') <> 'PUBLISHED' then raise exception 'Модуль A2.3 не опубліковано'; end if;
  raise notice 'Готово: модуль A2.3 — 6 уроків, слів 128';
end $$;

commit;
