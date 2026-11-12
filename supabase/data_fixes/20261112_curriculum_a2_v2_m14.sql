-- =====================================================================
-- Програма A2 v2 · модуль A2.14 «Підсумок A2: моє життя в Хорватії» · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2.py 14 (не редагуйте вручну).
--
-- Рішення власника 2026-11-12: 20–25 нових слів на урок, 90–95 % слів — нові для рівня, діалоги під тему,
-- частіше Даша / Дар’я; «Прослухайте діалог чи оголошення» в кожному уроці; бета (PUBLISHED).
--   * Уроки 84–86 (3): слів у них 60. Кожен: 20–25 слів, 2 діалоги, 15 вправ
--     (одна — «Прослухайте діалог чи оголошення»), «Напишіть повідомлення» і «Перекажіть другу» (ua → hr, необов’язкові), 20 хв.
--   * Слова: 60 (нові — PUBLISHED; ті, що вже є в словнику, не змінюються).
--   * Модуль і юніт A2.14 → PUBLISHED. Потрібен уже запущений 20261112_curriculum_a2_v2_00_structure.sql.
--   * Нічого не видаляє. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.units where id = 'c3460d2a-06db-5b7c-946e-2f7d316dcca2') then
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

-- 1. Слова уроків A2.14 (60): нові — PUBLISHED (бета); наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A2', t.ua, t.vtype, t.forms, t.examples, 'PUBLISHED', 'claude_curriculum_a2_v2'
  from jsonb_to_recordset('[{"lemma": "životni put", "normalized": "zivotni put", "pos": "phrase", "ua": "життєвий шлях", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Moj životni put nije bio jednostavan."]}, {"lemma": "životna priča", "normalized": "zivotna prica", "pos": "phrase", "ua": "історія життя", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Svatko ima svoju životnu priču."]}, {"lemma": "mladost", "normalized": "mladost", "pos": "noun", "ua": "молодість", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Mladost sam provela u Harkivu."]}, {"lemma": "odrastanje", "normalized": "odrastanje", "pos": "noun", "ua": "дорослішання", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Odrastanje na selu me naučilo raditi."]}, {"lemma": "tijekom godina", "normalized": "tijekom godina", "pos": "phrase", "ua": "протягом років", "vtype": "chunk", "forms": {}, "examples": ["Tijekom godina sam se puno promijenila."]}, {"lemma": "trenutačno", "normalized": "trenutacno", "pos": "adverb", "ua": "наразі, зараз", "vtype": "core", "forms": {}, "examples": ["Trenutačno radim u vrtiću."]}, {"lemma": "ubuduće", "normalized": "ubuduce", "pos": "adverb", "ua": "надалі, в майбутньому", "vtype": "core", "forms": {}, "examples": ["Ubuduće želim raditi kao učiteljica."]}, {"lemma": "za pet godina", "normalized": "za pet godina", "pos": "phrase", "ua": "через п’ять років", "vtype": "chunk", "forms": {}, "examples": ["Za pet godina vidim se u vlastitom stanu."]}, {"lemma": "namjeravati", "normalized": "namjeravati", "pos": "verb", "ua": "мати намір", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Namjeravam položiti ispit B1."]}, {"lemma": "postići", "normalized": "postici", "pos": "verb", "ua": "досягти", "vtype": "core", "forms": {"aspect": "pfv", "pair": "postizati"}, "examples": ["Postigla sam više nego što sam mislila."]}, {"lemma": "postignuće", "normalized": "postignuce", "pos": "noun", "ua": "досягнення", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Moje najveće postignuće su djeca."]}, {"lemma": "neuspjeh", "normalized": "neuspjeh", "pos": "noun", "ua": "невдача", "vtype": "core", "forms": {"gender": "m"}, "examples": ["I neuspjeh je iskustvo."]}, {"lemma": "naučiti iz pogrešaka", "normalized": "nauciti iz pogresaka", "pos": "phrase", "ua": "вчитися на помилках", "vtype": "chunk", "forms": {}, "examples": ["Naučila sam iz pogrešaka."]}, {"lemma": "ne žalim ni za čim", "normalized": "ne zalim ni za cim", "pos": "phrase", "ua": "ні про що не шкодую", "vtype": "chunk", "forms": {}, "examples": ["Ne žalim ni za čim."]}, {"lemma": "zahvalan", "normalized": "zahvalan", "pos": "adjective", "ua": "вдячний", "vtype": "core", "forms": {}, "examples": ["Zahvalna sam svima koji su nam pomogli."]}, {"lemma": "ispunjen", "normalized": "ispunjen", "pos": "adjective", "ua": "сповнений, наповнений (про життя)", "vtype": "core", "forms": {}, "examples": ["Sada imam ispunjen život."]}, {"lemma": "sazrijeti", "normalized": "sazrijeti", "pos": "verb", "ua": "подорослішати, дозріти", "vtype": "core", "forms": {"aspect": "pfv", "pair": "sazrijevati"}, "examples": ["U ovim godinama sam jako sazrela."]}, {"lemma": "nadati se", "normalized": "nadati se", "pos": "verb", "ua": "сподіватися", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Nadam se miru i povratku."]}, {"lemma": "korak naprijed", "normalized": "korak naprijed", "pos": "phrase", "ua": "крок уперед", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Svaki dan je mali korak naprijed."]}, {"lemma": "novo poglavlje", "normalized": "novo poglavlje", "pos": "phrase", "ua": "новий розділ (життя)", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Hrvatska je novo poglavlje mog života."]}, {"lemma": "samostalno", "normalized": "samostalno", "pos": "adverb", "ua": "самостійно", "vtype": "core", "forms": {}, "examples": ["Danas sam sve riješila samostalno."]}, {"lemma": "pojašnjenje", "normalized": "pojasnjenje", "pos": "noun", "ua": "роз’яснення", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Trebam pojašnjenje, nisam sve razumjela."]}, {"lemma": "zamoliti za pojašnjenje", "normalized": "zamoliti za pojasnjenje", "pos": "phrase", "ua": "попросити роз’яснення", "vtype": "chunk", "forms": {}, "examples": ["Slobodno zamolite za pojašnjenje."]}, {"lemma": "što točno", "normalized": "sto tocno", "pos": "phrase", "ua": "що саме", "vtype": "chunk", "forms": {}, "examples": ["Što točno trebam donijeti?"]}, {"lemma": "sljedeći korak", "normalized": "sljedeci korak", "pos": "phrase", "ua": "наступний крок", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Koji je sljedeći korak?"]}, {"lemma": "riješeno", "normalized": "rijeseno", "pos": "adverb", "ua": "вирішено", "vtype": "core", "forms": {}, "examples": ["Super, to je riješeno!"]}, {"lemma": "ponovite, molim Vas", "normalized": "ponovite, molim vas", "pos": "phrase", "ua": "повторіть, будь ласка", "vtype": "chunk", "forms": {}, "examples": ["Ponovite, molim Vas, malo sporije."]}, {"lemma": "jesam li dobro razumjela", "normalized": "jesam li dobro razumjela", "pos": "phrase", "ua": "чи правильно я зрозуміла", "vtype": "chunk", "forms": {}, "examples": ["Jesam li dobro razumjela: dolazim u ponedjeljak?"]}, {"lemma": "zapisati", "normalized": "zapisati", "pos": "verb", "ua": "записати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "zapisivati"}, "examples": ["Možete li mi to zapisati?"]}, {"lemma": "kome se mogu obratiti", "normalized": "kome se mogu obratiti", "pos": "phrase", "ua": "до кого я можу звернутися", "vtype": "chunk", "forms": {}, "examples": ["Kome se mogu obratiti za pomoć?"]}, {"lemma": "nadležna osoba", "normalized": "nadlezna osoba", "pos": "phrase", "ua": "відповідальна особа", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Nadležna osoba danas nije tu."]}, {"lemma": "snalaziti se", "normalized": "snalaziti se", "pos": "verb", "ua": "давати собі раду, орієнтуватися", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Sve bolje se snalazim na hrvatskom."]}, {"lemma": "bez prevoditelja", "normalized": "bez prevoditelja", "pos": "phrase", "ua": "без перекладача", "vtype": "chunk", "forms": {}, "examples": ["Kod liječnika sam bila bez prevoditelja."]}, {"lemma": "opisati simptome", "normalized": "opisati simptome", "pos": "phrase", "ua": "описати симптоми", "vtype": "chunk", "forms": {}, "examples": ["Znam opisati simptome na hrvatskom."]}, {"lemma": "dogovoriti se sa šefom", "normalized": "dogovoriti se sa sefom", "pos": "phrase", "ua": "домовитися з шефом", "vtype": "chunk", "forms": {}, "examples": ["Dogovorila sam se sa šefom oko godišnjeg."]}, {"lemma": "samopouzdanje", "normalized": "samopouzdanje", "pos": "noun", "ua": "впевненість у собі", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Jezik mi je dao samopouzdanje."]}, {"lemma": "izaći na kraj", "normalized": "izaci na kraj", "pos": "phrase", "ua": "впоратися", "vtype": "chunk", "forms": {}, "examples": ["Izašla sam na kraj i s birokracijom."]}, {"lemma": "svakodnevna situacija", "normalized": "svakodnevna situacija", "pos": "phrase", "ua": "повсякденна ситуація", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Svakodnevne situacije više nisu problem."]}, {"lemma": "dati mi ga", "normalized": "dati mi ga", "pos": "phrase", "ua": "дати мені його", "vtype": "chunk", "forms": {}, "examples": ["Imate li obrazac? Možete li mi ga dati?"]}, {"lemma": "reći ću mu", "normalized": "reci cu mu", "pos": "phrase", "ua": "я скажу йому", "vtype": "chunk", "forms": {}, "examples": ["Reći ću mu da Vas nazove."]}, {"lemma": "osobno pismo", "normalized": "osobno pismo", "pos": "phrase", "ua": "особистий лист", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Osobno pismo počinje s „Dragi“."]}, {"lemma": "službeno pismo", "normalized": "sluzbeno pismo", "pos": "phrase", "ua": "офіційний лист", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Službeno pismo počinje s „Poštovani“."]}, {"lemma": "obraćanje", "normalized": "obracanje", "pos": "noun", "ua": "звертання", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Obraćanje ovisi o tome kome pišete."]}, {"lemma": "srdačno", "normalized": "srdacno", "pos": "adverb", "ua": "сердечно, щиро", "vtype": "core", "forms": {}, "examples": ["Srdačno te pozdravljam."]}, {"lemma": "puno pozdrava", "normalized": "puno pozdrava", "pos": "phrase", "ua": "щирі вітання", "vtype": "chunk", "forms": {}, "examples": ["Puno pozdrava iz Rijeke!"]}, {"lemma": "jedva čekam", "normalized": "jedva cekam", "pos": "phrase", "ua": "не можу дочекатися", "vtype": "chunk", "forms": {}, "examples": ["Jedva čekam da se vidimo."]}, {"lemma": "piši mi", "normalized": "pisi mi", "pos": "phrase", "ua": "пиши мені", "vtype": "chunk", "forms": {}, "examples": ["Piši mi kad stigneš."]}, {"lemma": "javi se", "normalized": "javi se", "pos": "phrase", "ua": "озвися", "vtype": "chunk", "forms": {}, "examples": ["Javi se kad budeš imala vremena."]}, {"lemma": "bila bih Vam zahvalna", "normalized": "bila bih vam zahvalna", "pos": "phrase", "ua": "я була б вам вдячна", "vtype": "chunk", "forms": {}, "examples": ["Bila bih Vam zahvalna na brzom odgovoru."]}, {"lemma": "molila bih", "normalized": "molila bih", "pos": "phrase", "ua": "я б просила", "vtype": "chunk", "forms": {}, "examples": ["Molila bih Vas za informaciju o roku."]}, {"lemma": "u iščekivanju odgovora", "normalized": "u iscekivanju odgovora", "pos": "phrase", "ua": "в очікуванні відповіді", "vtype": "chunk", "forms": {}, "examples": ["U iščekivanju Vašeg odgovora, srdačno Vas pozdravljam."]}, {"lemma": "poštovana gospođo", "normalized": "postovana gospodo", "pos": "phrase", "ua": "шановна пані", "vtype": "chunk", "forms": {}, "examples": ["Poštovana gospođo Kovač, pišem Vam zbog upisa."]}, {"lemma": "pišem Vam zbog", "normalized": "pisem vam zbog", "pos": "phrase", "ua": "пишу вам щодо", "vtype": "chunk", "forms": {}, "examples": ["Pišem Vam zbog svog zahtjeva."]}, {"lemma": "ukratko", "normalized": "ukratko", "pos": "adverb", "ua": "коротко", "vtype": "core", "forms": {}, "examples": ["Ukratko, sve je u redu."]}, {"lemma": "novosti", "normalized": "novosti", "pos": "noun", "ua": "новини (особисті)", "vtype": "core", "forms": {"gender": "f_pl"}, "examples": ["Imam puno novosti za tebe."]}, {"lemma": "nedostaješ mi", "normalized": "nedostajes mi", "pos": "phrase", "ua": "я сумую за тобою", "vtype": "chunk", "forms": {}, "examples": ["Jako mi nedostaješ."]}, {"lemma": "dopisati", "normalized": "dopisati", "pos": "verb", "ua": "дописати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "dopisivati"}, "examples": ["Na kraju sam dopisala još jednu rečenicu."]}, {"lemma": "pozdravi", "normalized": "pozdravi", "pos": "phrase", "ua": "передавай вітання", "vtype": "chunk", "forms": {}, "examples": ["Pozdravi sve doma."]}, {"lemma": "s poštovanjem i zahvalnošću", "normalized": "s postovanjem i zahvalnoscu", "pos": "phrase", "ua": "з повагою й вдячністю", "vtype": "chunk", "forms": {}, "examples": ["Završila sam pismo s poštovanjem i zahvalnošću."]}, {"lemma": "ton pisma", "normalized": "ton pisma", "pos": "phrase", "ua": "тон листа", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ton pisma mora biti ljubazan."]}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 2. Уроки модуля A2.14
-- A2.14 · урок 84: Моя історія: тоді, тепер, потім — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'c3460d2a-06db-5b7c-946e-2f7d316dcca2';
  v_lesson constant uuid := '9b5d0ec7-4573-5f83-8cec-acc6997335de';
  v_gid constant uuid := '0b2de584-05a6-5570-a129-366fcb94766d';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики VID'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A2.14: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 84: Моя історія: тоді, тепер, потім', 'Lekcija 84: Moja priča: tada, sada, poslije', '["Розповісти свою історію в минулому, теперішньому й майбутньому", "Повторити вид дієслова в усіх часах"]'::jsonb, 20, 'PUBLISHED', 1);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'životni put', v_pos);
  v_pos := pg_temp.word(v_lesson, 'životna priča', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mladost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odrastanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tijekom godina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trenutačno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ubuduće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'za pet godina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'namjeravati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'postići', v_pos);
  v_pos := pg_temp.word(v_lesson, 'postignuće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neuspjeh', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naučiti iz pogrešaka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ne žalim ni za čim', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zahvalan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispunjen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sazrijeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nadati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'korak naprijed', v_pos);
  v_pos := pg_temp.word(v_lesson, 'novo poglavlje', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cb1df8fb-5e45-53c4-ad71-b81039aed8ed', 'fill_in_the_blank', 'Prve mjesece sam ___ jezik, a onda sam našla posao.', 'učila', '["učila", "naučit ću", "učim", "naučila"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '42744cab-e739-5906-a637-dd37054b4e37', 'multiple_choice', 'Що означає «namjeravati»?', 'мати намір', '["крок уперед", "вчитися на помилках", "мати намір", "новий розділ (життя)"]'::jsonb, 'A2', 2, 'PUBLISHED', 'namjeravati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '23b46f3e-cdf6-51e8-b4e1-34fff270037f', 'multiple_choice', 'Що означає «korak naprijed»?', 'крок уперед', '["вдячний", "новий розділ (життя)", "невдача", "крок уперед"]'::jsonb, 'A2', 3, 'PUBLISHED', 'korak naprijed', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2295c9a9-5e7c-51dd-b75f-c59eca120871', 'multiple_choice', 'Що означає «ne žalim ni za čim»?', 'ні про що не шкодую', '["новий розділ (життя)", "досягнення", "мати намір", "ні про що не шкодую"]'::jsonb, 'A2', 4, 'PUBLISHED', 'ne žalim ni za čim', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ef784b11-738a-553d-a650-c741b9c8b61f', 'multiple_choice', 'Як хорватською «вчитися на помилках»?', 'naučiti iz pogrešaka', '["odrastanje", "naučiti iz pogrešaka", "novo poglavlje", "korak naprijed"]'::jsonb, 'A2', 5, 'PUBLISHED', 'naučiti iz pogrešaka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '53decd0e-68c3-5866-b7d7-2be681d342eb', 'multiple_choice', 'Як хорватською «досягнення»?', 'postignuće', '["za pet godina", "postignuće", "neuspjeh", "zahvalan"]'::jsonb, 'A2', 6, 'PUBLISHED', 'postignuće', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '97c9f57c-1f92-5fb0-ad53-a6c4897ba9cd', 'type_answer', 'Напишіть хорватською: «молодість»', 'mladost', null, 'A2', 7, 'PUBLISHED', 'mladost', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f86290e3-d3d2-53f9-a0bd-29025a802e5c', 'type_answer', 'Напишіть хорватською: «життєвий шлях»', 'životni put', null, 'A2', 8, 'PUBLISHED', 'životni put', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '574f8a8a-fabb-509d-b244-e86bbc36174a', 'type_answer', 'Напишіть хорватською: «сподіватися»', 'nadati se', null, 'A2', 9, 'PUBLISHED', 'nadati se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '57117ff9-14ab-5f05-b5e0-84786db53cdb', 'sentence_builder', 'Складіть: «Я навчилася на помилках.»', 'Naučila sam iz pogrešaka.', '["pogrešaka.", "iz", "sam", "Naučila"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0f9131cb-2849-5f21-a712-dc37cd36ea01', 'sentence_builder', 'Складіть: «Наразі я працюю в садочку.»', 'Trenutačno radim u vrtiću.', '["u", "radim", "vrtiću.", "Trenutačno"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9079fecc-5c24-5b7e-85da-37c5c7441b2e', 'listening', 'Прослухайте і складіть фразу', 'Nadam se miru. Svaki dan je mali korak naprijed.', '["Svaki", "naprijed.", "miru.", "je", "mali", "korak", "dan", "se", "Nadam"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'aa640b8a-0f44-53f2-9995-ce3c2bdd5783', 'listening_dialogue', 'Прослухайте розмову', 'у Шибенику; 10; маленьку конову', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Марко розповідає Даші свою історію.", "script": [{"speaker": "Marko", "hr": "Rođen sam u Šibeniku, ali sam deset godina radio u Njemačkoj.", "ua": "Я народився в Шибенику, але десять років працював у Німеччині."}, {"speaker": "Daša", "hr": "Zašto si se vratio?", "ua": "Чому ти повернувся?"}, {"speaker": "Marko", "hr": "Nedostajalo mi je more. Prije dvije godine otvorio sam obrt.", "ua": "Мені бракувало моря. Два роки тому я відкрив власну справу."}, {"speaker": "Daša", "hr": "A planovi?", "ua": "А плани?"}, {"speaker": "Marko", "hr": "Za pet godina želim imati malu konobu.", "ua": "Через п’ять років я хочу мати маленьку конову."}], "questions": [{"q_ua": "Де народився Марко?", "options": ["у Шибенику", "у Спліті", "у Німеччині"], "correct": 0, "answer_turn": 0}, {"q_ua": "Скільки років він працював у Німеччині?", "answer_text": "10", "accept": ["десять", "10 років"], "answer_turn": 0}, {"q_ua": "Що він хоче мати через п’ять років?", "options": ["готель", "маленьку конову", "човен"], "correct": 1, "answer_turn": 4}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'aa640b8a-0f44-53f2-9995-ce3c2bdd5783', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4555f5f7-7b1a-52ad-a042-8903b29df349', 'speaking', 'Я виросла в маленькому містечку.', 'Odrasla sam u malom gradu.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '80329602-80ee-5e64-b217-14894a86c8bc', 'speaking', 'Через п’ять років я бачу себе у власній квартирі.', 'Za pet godina vidim se u vlastitom stanu.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '657a624a-a65e-5594-bd1c-ffcc64fa9d98', 'write_message', 'Напишіть коротко свою історію: де ви виросли, що робите зараз і що плануєте через п’ять років.', 'Odrasla sam u Poltavi. Trenutačno radim u vrtiću u Rijeci. Za pet godina namjeravam raditi kao učiteljica.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть коротко свою історію: де ви виросли, що робите зараз і що плануєте через п’ять років.", "points": [{"ua": "де виросли", "keys": [["odras"], ["rođen"]]}, {"ua": "що робите зараз", "keys": [["sad"], ["trenutačno"], ["danas"]]}, {"ua": "плани", "keys": [["za pet godina"], ["planir"], ["namjerav"], ["ću"]]}], "hints": ["odrasla sam u", "trenutačno radim", "za pet godina", "namjeravam"], "models": ["Odrasla sam u Poltavi. Trenutačno radim u vrtiću u Rijeci. Za pet godina namjeravam raditi kao učiteljica."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '657a624a-a65e-5594-bd1c-ffcc64fa9d98', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'e19054d3-dfcd-55d6-8425-360548025e42', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Zahvalna je svima koji su joj pomogli. Hrvatska je novo poglavlje njezina života.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Розкажи журналістці, що я вдячна всім, хто нам допоміг, і що Хорватія — новий розділ мого життя.", "direction": "ua_hr", "points": [{"ua": "вдячна", "keys": [["zahvaln"]]}, {"ua": "новий розділ", "keys": [["poglavlj"]]}], "hints": [], "models": ["Zahvalna je svima koji su joj pomogli. Hrvatska je novo poglavlje njezina života."], "source_ua": "Розкажи журналістці, що я вдячна всім, хто нам допоміг, і що Хорватія — новий розділ мого життя."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'e19054d3-dfcd-55d6-8425-360548025e42', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2e57839f-f789-5f47-ba04-3c1ff86c9f0d', v_lesson, 'Інтерв’ю для журналу', 'Intervju za časopis', 5841, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('df5fc5f1-aaac-5998-832a-567c3f731a44', '2e57839f-f789-5f47-ba04-3c1ff86c9f0d', 'Novinarka', 'Darja, ispričajte nam svoju životnu priču.', 'Дар’є, розкажіть нам свою історію життя.', 1);
  perform pg_temp.turn('3665dd77-da83-5d56-a0b2-a7e7c38aad57', '2e57839f-f789-5f47-ba04-3c1ff86c9f0d', 'Darja', 'Odrasla sam u malom gradu, a mladost sam provela u Harkivu. Tamo sam studirala i radila.', 'Я виросла в маленькому містечку, а молодість провела в Харкові. Там навчалася й працювала.', 2);
  perform pg_temp.turn('b36e746f-3498-5b51-b6fe-aec0001694b7', '2e57839f-f789-5f47-ba04-3c1ff86c9f0d', 'Novinarka', 'A onda ste došli u Hrvatsku.', 'А потім ви приїхали до Хорватії.', 3);
  perform pg_temp.turn('7b517d13-b8cc-523f-9196-b6a77bd1109d', '2e57839f-f789-5f47-ba04-3c1ff86c9f0d', 'Darja', 'Da, 2022. Prve mjesece sam učila jezik, a onda sam našla posao u vrtiću.', 'Так, у 2022-му. Перші місяці я вчила мову, а потім знайшла роботу в садочку.', 4);
  perform pg_temp.turn('fdd0cadd-b3aa-5681-958d-7bbf1c0f347b', '2e57839f-f789-5f47-ba04-3c1ff86c9f0d', 'Novinarka', 'Što namjeravate ubuduće?', 'Що ви плануєте надалі?', 5);
  perform pg_temp.turn('8773ca66-91a9-5790-a171-a1955eb87d0c', '2e57839f-f789-5f47-ba04-3c1ff86c9f0d', 'Darja', 'Položit ću ispit B1 i htjela bih raditi kao učiteljica.', 'Я складу іспит B1 і хотіла б працювати вчителькою.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ae0bfa2e-de7a-5fbd-8e42-565e22ccf331', v_lesson, 'Підсумок', 'Sažetak', 5842, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('019d9d4f-7f1f-5e33-b9f6-3474cf5d1c08', 'ae0bfa2e-de7a-5fbd-8e42-565e22ccf331', 'Daša', 'Kad pogledaš unatrag, što ti je najveće postignuće?', 'Коли озираєшся назад, що твоє найбільше досягнення?', 1);
  perform pg_temp.turn('9adf2255-ca1e-59fe-93a9-b6a01fe4d7b0', 'ae0bfa2e-de7a-5fbd-8e42-565e22ccf331', 'Darja', 'Djeca. Prilagodila su se i govore dva jezika.', 'Діти. Вони адаптувалися й говорять двома мовами.', 2);
  perform pg_temp.turn('6cc95879-d912-57e8-9851-62a3c03a28da', 'ae0bfa2e-de7a-5fbd-8e42-565e22ccf331', 'Daša', 'A neuspjesi?', 'А невдачі?', 3);
  perform pg_temp.turn('9d6262e6-a4fd-54c4-8940-c6b196393940', 'ae0bfa2e-de7a-5fbd-8e42-565e22ccf331', 'Darja', 'Bilo ih je, ali naučila sam iz pogrešaka. Ne žalim ni za čim.', 'Були, але я навчилася на помилках. Ні про що не шкодую.', 4);
  perform pg_temp.turn('9933bfb0-fb72-50d5-8005-bf82d5c4080a', 'ae0bfa2e-de7a-5fbd-8e42-565e22ccf331', 'Daša', 'Za pet godina?', 'А через п’ять років?', 5);
  perform pg_temp.turn('4c87e935-a728-5b73-822b-f593959a734e', 'ae0bfa2e-de7a-5fbd-8e42-565e22ccf331', 'Darja', 'Nadam se miru. Svaki dan je mali korak naprijed.', 'Сподіваюся на мир. Кожен день — маленький крок уперед.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.14 · урок 85: Ситуації без підказок: установа, лікар, робота — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'c3460d2a-06db-5b7c-946e-2f7d316dcca2';
  v_lesson constant uuid := 'e7b7f159-25f2-53dc-b20e-df56f5dae94b';
  v_gid constant uuid := 'ec75057c-1f8d-51e1-9946-1ff5bbfeebca';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики ENK'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A2.14: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 85: Ситуації без підказок: установа, лікар, робота', 'Lekcija 85: Situacije bez pomoći: ured, liječnik, posao', '["Самостійно впоратися з типовими ситуаціями A2", "Повторити порядок коротких слів: Možete li mi ga…? Javit ću Vam se."]'::jsonb, 20, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'samostalno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pojašnjenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zamoliti za pojašnjenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'što točno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sljedeći korak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'riješeno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponovite, molim Vas', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jesam li dobro razumjela', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zapisati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kome se mogu obratiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nadležna osoba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'snalaziti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bez prevoditelja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opisati simptome', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dogovoriti se sa šefom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'samopouzdanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izaći na kraj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svakodnevna situacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dati mi ga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'reći ću mu', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b15a057e-8718-534f-b9f2-5b3c7b06fa10', 'fill_in_the_blank', 'Prijevod? Donijet ću ___ ga sutra.', 'Vam', '["Vaš", "Vas", "Vi", "Vam"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a41ec504-45cd-5c27-a57b-95e70a7c86ed', 'multiple_choice', 'Що означає «reći ću mu»?', 'я скажу йому', '["я скажу йому", "повсякденна ситуація", "без перекладача", "попросити роз’яснення"]'::jsonb, 'A2', 2, 'PUBLISHED', 'reći ću mu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4152014a-6bd9-58af-b178-8adf630e964f', 'multiple_choice', 'Що означає «ponovite, molim Vas»?', 'повторіть, будь ласка', '["повторіть, будь ласка", "що саме", "впоратися", "самостійно"]'::jsonb, 'A2', 3, 'PUBLISHED', 'ponovite, molim Vas', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b00978bb-985d-5f62-ba9f-5d122d660360', 'multiple_choice', 'Що означає «zapisati»?', 'записати', '["описати симптоми", "записати", "самостійно", "давати собі раду, орієнтуватися"]'::jsonb, 'A2', 4, 'PUBLISHED', 'zapisati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dcb2a7be-4c9c-5fec-a9e2-6a152e5fdb44', 'multiple_choice', 'Що означає «kome se mogu obratiti»?', 'до кого я можу звернутися', '["до кого я можу звернутися", "повторіть, будь ласка", "описати симптоми", "записати"]'::jsonb, 'A2', 5, 'PUBLISHED', 'kome se mogu obratiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '94199760-7fd2-5068-98bd-c941b35673f2', 'multiple_choice', 'Як хорватською «самостійно»?', 'samostalno', '["izaći na kraj", "opisati simptome", "samostalno", "pojašnjenje"]'::jsonb, 'A2', 6, 'PUBLISHED', 'samostalno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3348a5d4-ee5a-5574-a6b5-9bb60030ed95', 'multiple_choice', 'Як хорватською «описати симптоми»?', 'opisati simptome', '["izaći na kraj", "opisati simptome", "ponovite, molim Vas", "jesam li dobro razumjela"]'::jsonb, 'A2', 7, 'PUBLISHED', 'opisati simptome', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd4b0957d-04d8-56c9-a56e-a0c1fef62094', 'type_answer', 'Напишіть хорватською: «впевненість у собі»', 'samopouzdanje', null, 'A2', 8, 'PUBLISHED', 'samopouzdanje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9be3ab6d-93dc-566f-9772-0668c80ea2c2', 'type_answer', 'Напишіть хорватською: «вирішено»', 'riješeno', null, 'A2', 9, 'PUBLISHED', 'riješeno', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '841e9124-0242-568d-b962-fc57ed67219c', 'sentence_builder', 'Складіть: «До кого я можу звернутися?»', 'Kome se mogu obratiti?', '["mogu", "Kome", "se", "obratiti?"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2659cde3-62d3-5e65-894a-7618525b5c9e', 'sentence_builder', 'Складіть: «Чи можете мені це записати?»', 'Možete li mi to zapisati?', '["zapisati?", "li", "Možete", "mi", "to"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '76a812f7-2f3c-5b3b-ac28-2c79684e7873', 'listening', 'Прослухайте і складіть фразу', 'Točno. To je zadnji korak.', '["To", "zadnji", "Točno.", "korak.", "je"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '37ca15a1-8339-56e9-a8e8-442e12b7c721', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'заяву до садочка; Leptirići; у садочку', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Повідомлення з установи. Слухайте без підказок.", "script": [{"hr": "Dobar dan, zovem iz Gradskog ureda.", "ua": "Добрий день, телефоную з Міського відділу."}, {"hr": "Vaš zahtjev za vrtić je odobren.", "ua": "Вашу заяву до садочка схвалено."}, {"hr": "Dijete može početi prvog rujna, u skupini Leptirići.", "ua": "Дитина може почати першого вересня, у групі «Метелики»."}, {"hr": "Ugovor potpišite u vrtiću do kraja kolovoza.", "ua": "Договір підпишіть у садочку до кінця серпня."}], "questions": [{"q_ua": "Що схвалили?", "options": ["заяву до садочка", "дозвіл на проживання", "відпустку"], "correct": 0, "answer_turn": 1}, {"q_ua": "Як називається група?", "answer_text": "Leptirići", "accept": ["Метелики", "leptirići"], "answer_turn": 2}, {"q_ua": "Де підписати договір?", "options": ["у Міському відділі", "у садочку", "у поліції"], "correct": 1, "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '37ca15a1-8339-56e9-a8e8-442e12b7c721', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ea9ca4e3-1659-5ace-bf61-55e405012eab', 'speaking', 'Чи правильно я зрозуміла?', 'Jesam li dobro razumjela?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9a9a4e90-9e80-5af0-9b95-b3d084e4356b', 'speaking', 'Який наступний крок?', 'Koji je sljedeći korak?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'b2ab53b0-461a-537a-93bc-ab036cd90f1d', 'write_message', 'Напишіть в установу: ви не все зрозуміли в листі й просите пояснити, які документи потрібні та який наступний крок.', 'Poštovani, nisam sve razumjela u pismu. Koji dokumenti su potrebni i koji je sljedeći korak?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть в установу: ви не все зрозуміли в листі й просите пояснити, які документи потрібні та який наступний крок.", "points": [{"ua": "не все зрозуміли", "keys": [["razumje"]]}, {"ua": "які документи", "keys": [["dokument"]]}, {"ua": "наступний крок", "keys": [["korak"]]}], "hints": ["nisam sve razumjela", "koji dokumenti su potrebni", "koji je sljedeći korak?"], "models": ["Poštovani, nisam sve razumjela u pismu. Koji dokumenti su potrebni i koji je sljedeći korak?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'b2ab53b0-461a-537a-93bc-ab036cd90f1d', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'f240a6ad-11ef-5170-8685-b541b9607795', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Već tri dana je boli grlo i ima temperaturu 38.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи лікарці, що в мене третій день болить горло й температура 38.", "direction": "ua_hr", "points": [{"ua": "третій день", "keys": [["tri dana"], ["treći"]]}, {"ua": "горло", "keys": [["grl"]]}, {"ua": "температура 38", "keys": [["38"], ["trideset osam"]]}], "hints": [], "models": ["Već tri dana je boli grlo i ima temperaturu 38."], "source_ua": "Скажи лікарці, що в мене третій день болить горло й температура 38."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'f240a6ad-11ef-5170-8685-b541b9607795', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a8b41a8d-5a33-5d3b-8ff7-a5dd5f166a16', v_lesson, 'В установі', 'U uredu', 5851, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('a2ef6c21-f577-58f0-ba82-1edc50b70c2f', 'a8b41a8d-5a33-5d3b-8ff7-a5dd5f166a16', 'Darja', 'Dobar dan, trebam potvrdu za vrtić. Kome se mogu obratiti?', 'Добрий день, мені потрібна довідка для садочка. До кого я можу звернутися?', 1);
  perform pg_temp.turn('dc9a9d0a-b359-5483-9469-a5371874efe7', 'a8b41a8d-5a33-5d3b-8ff7-a5dd5f166a16', 'Službenica', 'Meni. Trebam rodni list i Vašu iskaznicu.', 'До мене. Мені потрібне свідоцтво про народження й ваша посвідка.', 2);
  perform pg_temp.turn('3cb7826a-3d5c-567d-99df-4a63482a9974', 'a8b41a8d-5a33-5d3b-8ff7-a5dd5f166a16', 'Darja', 'Rodni list imam samo na ukrajinskom. Što točno trebate?', 'Свідоцтво в мене лише українською. Що саме вам потрібно?', 3);
  perform pg_temp.turn('93384be5-6028-599b-9c54-ebf4854b20ba', 'a8b41a8d-5a33-5d3b-8ff7-a5dd5f166a16', 'Službenica', 'Ovjereni prijevod. Možete mi ga donijeti sutra.', 'Засвідчений переклад. Можете принести мені його завтра.', 4);
  perform pg_temp.turn('e994506e-5615-5631-bde2-142dab4ca458', 'a8b41a8d-5a33-5d3b-8ff7-a5dd5f166a16', 'Darja', 'Jesam li dobro razumjela: sutra prijevod, i onda je riješeno?', 'Чи правильно я зрозуміла: завтра переклад, і тоді все вирішено?', 5);
  perform pg_temp.turn('df2c075e-7900-533c-a2d0-b80bca056562', 'a8b41a8d-5a33-5d3b-8ff7-a5dd5f166a16', 'Službenica', 'Točno. To je zadnji korak.', 'Саме так. Це останній крок.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d498861a-4927-5dbb-bf81-e2adf7bb9ea9', v_lesson, 'Без перекладача', 'Bez prevoditelja', 5852, 'A2', 'administration', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('2e76d70f-d438-53ff-8986-a2cf3be752e4', 'd498861a-4927-5dbb-bf81-e2adf7bb9ea9', 'Daša', 'Kako je bilo kod liječnika?', 'Як було в лікаря?', 1);
  perform pg_temp.turn('9ee41679-7891-547e-a5c0-f956dfe58687', 'd498861a-4927-5dbb-bf81-e2adf7bb9ea9', 'Darja', 'Bila sam sama, bez prevoditelja! Znala sam opisati simptome.', 'Я була сама, без перекладача! Змогла описати симптоми.', 2);
  perform pg_temp.turn('9cf7e387-c374-556f-9d25-e0c0c5b96982', 'd498861a-4927-5dbb-bf81-e2adf7bb9ea9', 'Daša', 'Bravo! A na poslu?', 'Молодець! А на роботі?', 3);
  perform pg_temp.turn('6aabb3f5-a287-5383-a36a-983c5d7f40e5', 'd498861a-4927-5dbb-bf81-e2adf7bb9ea9', 'Darja', 'Dogovorila sam se sa šefom oko godišnjeg. Izašla sam na kraj sa svime.', 'Домовилася з шефом про відпустку. Впоралася з усім.', 4);
  perform pg_temp.turn('bd463a1f-4e55-5a2b-91bf-24917abe5855', 'd498861a-4927-5dbb-bf81-e2adf7bb9ea9', 'Daša', 'Vidiš, jezik ti je dao samopouzdanje.', 'Бачиш, мова дала тобі впевненість.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.14 · урок 86: Два листи: другові й до установи — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'c3460d2a-06db-5b7c-946e-2f7d316dcca2';
  v_lesson constant uuid := 'f4f20a90-406f-58fa-9369-2df5aceb93a2';
  v_gid constant uuid := '0c68352a-803a-5410-a59b-91f2c1ddc49f';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KOND'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A2.14: місце 3 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 86: Два листи: другові й до установи', 'Lekcija 86: Dva pisma: prijatelju i ustanovi', '["Написати особистий лист другові й офіційний лист до установи", "Ввічливі формули з kondicionalom: Bila bih Vam zahvalna…, Molila bih…"]'::jsonb, 20, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'osobno pismo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'službeno pismo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obraćanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srdačno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'puno pozdrava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jedva čekam', v_pos);
  v_pos := pg_temp.word(v_lesson, 'piši mi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'javi se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bila bih Vam zahvalna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'molila bih', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u iščekivanju odgovora', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poštovana gospođo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pišem Vam zbog', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ukratko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'novosti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nedostaješ mi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dopisati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pozdravi', v_pos);
  v_pos := pg_temp.word(v_lesson, 's poštovanjem i zahvalnošću', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ton pisma', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'faa84f73-bffb-522c-8884-d410ddc3cdfa', 'fill_in_the_blank', 'Bila ___ Vam zahvalna na brzom odgovoru.', 'bih', '["bi", "bih", "sam", "biste"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '94f9ad55-4168-5c03-ad27-a5efff5b30b4', 'multiple_choice', 'Що означає «u iščekivanju odgovora»?', 'в очікуванні відповіді', '["в очікуванні відповіді", "пиши мені", "озвися", "щирі вітання"]'::jsonb, 'A2', 2, 'PUBLISHED', 'u iščekivanju odgovora', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e68116f9-591e-5535-af2a-fa534a3f4677', 'multiple_choice', 'Що означає «srdačno»?', 'сердечно, щиро', '["пишу вам щодо", "звертання", "я сумую за тобою", "сердечно, щиро"]'::jsonb, 'A2', 3, 'PUBLISHED', 'srdačno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d2ed3f2-590f-5bcc-abcf-7bcb07c21ca9', 'multiple_choice', 'Що означає «s poštovanjem i zahvalnošću»?', 'з повагою й вдячністю', '["шановна пані", "не можу дочекатися", "з повагою й вдячністю", "коротко"]'::jsonb, 'A2', 4, 'PUBLISHED', 's poštovanjem i zahvalnošću', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5aefde49-f69f-50f2-a5ba-dd231a8eb83c', 'multiple_choice', 'Як хорватською «коротко»?', 'ukratko', '["ukratko", "poštovana gospođo", "obraćanje", "srdačno"]'::jsonb, 'A2', 5, 'PUBLISHED', 'ukratko', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e211097e-6ece-5ae5-a997-fc22144dae42', 'multiple_choice', 'Як хорватською «шановна пані»?', 'poštovana gospođo', '["ukratko", "službeno pismo", "piši mi", "poštovana gospođo"]'::jsonb, 'A2', 6, 'PUBLISHED', 'poštovana gospođo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5a66a115-25be-5fd8-bcb9-93922d5cea58', 'type_answer', 'Напишіть хорватською: «пиши мені»', 'piši mi', null, 'A2', 7, 'PUBLISHED', 'piši mi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e41ac0ae-93fe-5cf1-8150-e03a46ecea49', 'type_answer', 'Напишіть хорватською: «звертання»', 'obraćanje', null, 'A2', 8, 'PUBLISHED', 'obraćanje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '18cf7475-33f4-5c43-845a-2cc2e6a45346', 'type_answer', 'Напишіть хорватською: «озвися»', 'javi se', null, 'A2', 9, 'PUBLISHED', 'javi se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '80f01d0b-f19b-55b8-8cf2-e8e3aed70094', 'sentence_builder', 'Складіть: «Я дуже сумую за тобою.»', 'Jako mi nedostaješ.', '["nedostaješ.", "Jako", "mi"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'feb9f307-cc6f-5288-8521-1da975529839', 'sentence_builder', 'Складіть: «Пишу вам щодо своєї заяви.»', 'Pišem Vam zbog svog zahtjeva.', '["Vam", "svog", "zbog", "zahtjeva.", "Pišem"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '884dfc21-f015-5114-927e-e1e39635027a', 'listening', 'Прослухайте і складіть фразу', '„Draga Olena“. Onda napiši novosti, ukratko.', '["Olena“.", "napiši", "novosti,", "„Draga", "Onda", "ukratko."]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'df57848b-55bb-57a9-944e-ef31c75c571a', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'хорватською; 10; зустріти на вокзалі', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Подруга з Києва надіслала вам голосове.", "script": [{"hr": "Darja, dobila sam tvoje pismo na hrvatskom! Sve sam razumjela s prevoditeljem.", "ua": "Дар’є, я отримала твій лист хорватською! Усе зрозуміла з перекладачем."}, {"hr": "Jako mi nedostaješ. Dolazim u Rijeku u srpnju, na deset dana.", "ua": "Я дуже сумую за тобою. Приїду до Рієки в липні, на десять днів."}, {"hr": "Javi mi možeš li me dočekati na kolodvoru.", "ua": "Дай знати, чи можеш зустріти мене на вокзалі."}], "questions": [{"q_ua": "Якою мовою був лист Дар’ї?", "options": ["хорватською", "українською", "англійською"], "correct": 0, "answer_turn": 0}, {"q_ua": "На скільки днів приїде подруга?", "answer_text": "10", "accept": ["десять", "10 днів"], "answer_turn": 1}, {"q_ua": "Про що вона просить?", "options": ["знайти житло", "зустріти на вокзалі", "купити квиток"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'df57848b-55bb-57a9-944e-ef31c75c571a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '483af24d-7a7f-503b-9e89-4a3ee61f51bb', 'speaking', 'Не можу дочекатися зустрічі.', 'Jedva čekam da se vidimo.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4394c4e5-11ff-5248-877e-43bb181404cc', 'speaking', 'Я була б вам вдячна за відповідь.', 'Bila bih Vam zahvalna na odgovoru.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'e36256c0-68d4-593e-b0f3-eea309b5fde3', 'write_message', 'Напишіть офіційний лист: звертання до пані Ковач, ви пишете щодо запису дитини до школи, просите інформацію про строк; ввічливе завершення.', 'Poštovana gospođo Kovač, pišem Vam zbog upisa djeteta u školu. Molila bih Vas za informaciju o roku. S poštovanjem, Darja Kovalenko', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть офіційний лист: звертання до пані Ковач, ви пишете щодо запису дитини до школи, просите інформацію про строк; ввічливе завершення.", "points": [{"ua": "звертання", "keys": [["poštovan"]]}, {"ua": "щодо запису", "keys": [["upis"]]}, {"ua": "прохання", "keys": [["molila bih"], ["bila bih"], ["zahvaln"]]}, {"ua": "завершення", "keys": [["s poštovanjem"]]}], "hints": ["Poštovana gospođo Kovač", "pišem Vam zbog upisa", "molila bih Vas", "S poštovanjem"], "models": ["Poštovana gospođo Kovač, pišem Vam zbog upisa djeteta u školu. Molila bih Vas za informaciju o roku. S poštovanjem, Darja Kovalenko"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'e36256c0-68d4-593e-b0f3-eea309b5fde3', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '5d1635e7-46cb-5a94-a0ea-93fdd93f99f6', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Jako mi nedostaješ i jedva čekam da dođeš u srpnju.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Напиши від мене подрузі: я дуже сумую й не можу дочекатися, коли вона приїде в липні.", "direction": "ua_hr", "points": [{"ua": "сумую", "keys": [["nedostaj"]]}, {"ua": "не можу дочекатися", "keys": [["jedva čeka"]]}, {"ua": "липень", "keys": [["srpnj"]]}], "hints": [], "models": ["Jako mi nedostaješ i jedva čekam da dođeš u srpnju."], "source_ua": "Напиши від мене подрузі: я дуже сумую й не можу дочекатися, коли вона приїде в липні."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '5d1635e7-46cb-5a94-a0ea-93fdd93f99f6', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('36fee9fc-891e-56bd-b4ba-50104fc4aa31', v_lesson, 'Лист подрузі', 'Pismo prijateljici', 5861, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('69ba9afa-d07d-5087-9f7f-c60187f4e7f4', '36fee9fc-891e-56bd-b4ba-50104fc4aa31', 'Darja', 'Daša, pišem pismo prijateljici u Kijev. Kako da počnem na hrvatskom?', 'Дашо, я пишу лист подрузі до Києва. Як почати хорватською?', 1);
  perform pg_temp.turn('3c9af4c9-b69b-5e56-bdc7-75c6866ef236', '36fee9fc-891e-56bd-b4ba-50104fc4aa31', 'Daša', '„Draga Olena“. Onda napiši novosti, ukratko.', '«Дорога Олено». Потім напиши новини, коротко.', 2);
  perform pg_temp.turn('31ecb315-ddaf-54e4-81d0-113bd7ab68bb', '36fee9fc-891e-56bd-b4ba-50104fc4aa31', 'Darja', 'A na kraju?', 'А наприкінці?', 3);
  perform pg_temp.turn('06ca5676-c480-565e-ab2e-5d92614db705', '36fee9fc-891e-56bd-b4ba-50104fc4aa31', 'Daša', '„Jako mi nedostaješ, jedva čekam da se vidimo. Puno pozdrava!“', '«Я дуже сумую за тобою, не можу дочекатися зустрічі. Щирі вітання!»', 4);
  perform pg_temp.turn('958538cc-bb4e-5ae7-978a-43f731907bce', '36fee9fc-891e-56bd-b4ba-50104fc4aa31', 'Darja', 'I P. S. — pozdravi mamu!', 'І P. S. — передавай вітання мамі!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f4a84eb1-c893-5aa8-b7c9-96c0bb841d2f', v_lesson, 'Офіційний лист', 'Službeno pismo', 5862, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('e7a35d97-f524-52f0-a09b-fa55f1e43b62', 'f4a84eb1-c893-5aa8-b7c9-96c0bb841d2f', 'Ivan', 'A službeno pismo? Što je drukčije?', 'А офіційний лист? Що інакше?', 1);
  perform pg_temp.turn('de9be338-3446-52c9-91b6-a7228ed2a019', 'f4a84eb1-c893-5aa8-b7c9-96c0bb841d2f', 'Daša', 'Obraćanje: „Poštovana gospođo“. Ton pisma mora biti ljubazan.', 'Звертання: «Шановна пані». Тон листа має бути ввічливим.', 2);
  perform pg_temp.turn('3c874f6b-db2c-526c-ae64-9706478d54a3', 'f4a84eb1-c893-5aa8-b7c9-96c0bb841d2f', 'Ivan', 'Kako da zamolim nešto?', 'Як мені про щось попросити?', 3);
  perform pg_temp.turn('1d7d3898-7a9a-5b35-884d-d147c16b2319', 'f4a84eb1-c893-5aa8-b7c9-96c0bb841d2f', 'Daša', '„Molila bih Vas…“ ili „Bila bih Vam zahvalna…“', '«Я б просила вас…» або «Я була б вам вдячна…»', 4);
  perform pg_temp.turn('c143d02a-5b53-5082-ae37-9564462e2943', 'f4a84eb1-c893-5aa8-b7c9-96c0bb841d2f', 'Ivan', 'A kraj?', 'А кінець?', 5);
  perform pg_temp.turn('d12ce784-7a96-50a6-9a5d-a88bf2646baa', 'f4a84eb1-c893-5aa8-b7c9-96c0bb841d2f', 'Daša', '„U iščekivanju Vašeg odgovora, s poštovanjem.“', '«В очікуванні вашої відповіді, з повагою».', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- 3. Модуль і юніт — опубліковані
update public.modules set status = 'PUBLISHED', title_ua = 'Модуль A2.14 — Підсумок A2: моє життя в Хорватії', title_hr = 'Modul A2.14 — Sažetak A2: moj život u Hrvatskoj' where id = 'a22f1345-0879-5cde-ad47-4a76556dcf7e';
update public.units set status = 'PUBLISHED' where id = 'c3460d2a-06db-5b7c-946e-2f7d316dcca2';

-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('9b5d0ec7-4573-5f83-8cec-acc6997335de', 'e7b7f159-25f2-53dc-b20e-df56f5dae94b', 'f4f20a90-406f-58fa-9369-2df5aceb93a2')
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
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 20 or l.unit_id <> 'c3460d2a-06db-5b7c-946e-2f7d316dcca2');
  select count(*) into v_titles from (values ('9b5d0ec7-4573-5f83-8cec-acc6997335de'::uuid, 'Урок 84:%', 1), ('e7b7f159-25f2-53dc-b20e-df56f5dae94b'::uuid, 'Урок 85:%', 2), ('f4f20a90-406f-58fa-9369-2df5aceb93a2'::uuid, 'Урок 86:%', 3)) as t(id, pat, o)
    left join public.lessons l on l.id = t.id and l.title_ua like t.pat and l.order_index = t.o
   where l.id is null;
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
      where l.level_code = 'A2' and l.status = 'PUBLISHED' and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A2.14: % уроків з неправильним складом', v_bad; end if;
  if v_titles > 0 then raise exception 'Модуль A2.14: % уроків не на своєму місці чи з неправильним номером', v_titles; end if;
  if v_words > 0 then raise exception 'A2: % слів повторюються в кількох уроках', v_words; end if;
  if (select status from public.modules where id = 'a22f1345-0879-5cde-ad47-4a76556dcf7e') <> 'PUBLISHED' then raise exception 'Модуль A2.14 не опубліковано'; end if;
  raise notice 'Готово: модуль A2.14 — 3 уроки, слів 60';
end $$;

commit;
