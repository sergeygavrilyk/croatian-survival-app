-- =====================================================================
-- Програма A1 v3 · модуль A1.8 «Здоров’я» · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_curriculum_a1_v3.py 8 (не редагуйте вручну).
--
-- Рішення власника 2026-10-21 / 2026-10-26: до 25 слів на урок — скільки потрібно темі, 90–95 % слів — нові для рівня,
-- діалоги під тему, частіше Даша / Дар’я; бета (PUBLISHED).
--   * Уроки 66–75: 9 наявних перебудовано, 1 нових. Слів у них: 135.
--     Кожен: 10–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 48.
--   * Нові правила до тем: «Наказовий спосіб» (+1), «Минулий час: radio sam, bila sam» (+1).
--   * Виправлено: cjepivo — «вакцина»; težina — «вага (тіла); складність»; hitan — «терміновий, невідкладний» (стара версія — у content_versions).
--   * Стара версія кожного зміненого уроку — у content_versions; копія кроків — у backup.lesson_items_20261015;
--     старі вправи й діалоги → DEPRECATED (не видаляються). Назви всіх уроків A1 — наскрізні номери.
--   * Потрібен уже запущений 20261026_curriculum_a1_v3_structure.sql. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.modules where id = '09e7c668-b622-56b2-82e9-b1c0c0db54c6') then
    raise exception 'Спершу запустіть 20261026_curriculum_a1_v3_structure.sql (нова програма A1)';
  end if;
end $$;

create schema if not exists backup;
create table if not exists backup.lesson_items_20261015 (like public.lesson_items including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'lesson_items_20261015_pkey') then
    alter table backup.lesson_items_20261015 add constraint lesson_items_20261015_pkey primary key (id);
  end if;
end $$;
revoke all on backup.lesson_items_20261015 from anon, authenticated;

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

-- 1. Нові слова й вирази A1.8 (48; наявні не змінюються)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zdravstvena iskaznica', 'zdravstvena iskaznica', 'hr', 'phrase', 'A1', 'картка медичного страхування', 'collocation', '{"gender": "f"}'::jsonb, '["Kod liječnika uvijek ponesite zdravstvenu iskaznicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dopunsko osiguranje', 'dopunsko osiguranje', 'hr', 'phrase', 'A1', 'додаткове медичне страхування', 'collocation', '{"gender": "n"}'::jsonb, '["S dopunskim osiguranjem ne plaćam participaciju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('participacija', 'participacija', 'hr', 'noun', 'A1', 'доплата пацієнта (за медичну послугу)', 'core', '{"gender": "f"}'::jsonb, '["Bez dopunskog osiguranja plaćate participaciju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('hitan slučaj', 'hitan slucaj', 'hr', 'phrase', 'A1', 'невідкладний випадок', 'collocation', '{"gender": "m"}'::jsonb, '["Ovo je hitan slučaj, dijete ima visoku temperaturu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prvi slobodni termin', 'prvi slobodni termin', 'hr', 'phrase', 'A1', 'найближчий вільний час (для запису)', 'collocation', '{"gender": "m"}'::jsonb, '["Prvi slobodni termin je u četvrtak u deset."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pluća', 'pluca', 'hr', 'noun', 'A1', 'легені', 'core', '{"gender": "n_pl"}'::jsonb, '["Pušenje šteti plućima."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jetra', 'jetra', 'hr', 'noun', 'A1', 'печінка', 'core', '{"gender": "f"}'::jsonb, '["Alkohol je loš za jetru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bubreg', 'bubreg', 'hr', 'noun', 'A1', 'нирка', 'core', '{"gender": "m"}'::jsonb, '["Boli me s lijeve strane, možda je bubreg."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('želudac', 'zeludac', 'hr', 'noun', 'A1', 'шлунок', 'core', '{"gender": "m"}'::jsonb, '["Imam osjetljiv želudac."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('crijeva', 'crijeva', 'hr', 'noun', 'A1', 'кишківник', 'core', '{"gender": "n_pl"}'::jsonb, '["Jogurt je dobar za crijeva."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mozak', 'mozak', 'hr', 'noun', 'A1', 'мозок', 'core', '{"gender": "m"}'::jsonb, '["Mozak treba puno vode i sna."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mišić', 'misic', 'hr', 'noun', 'A1', 'м’яз', 'core', '{"gender": "m"}'::jsonb, '["Nakon teretane bole me mišići."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zglob', 'zglob', 'hr', 'noun', 'A1', 'суглоб; зап’ястя', 'core', '{"gender": "m"}'::jsonb, '["Zimi me bole zglobovi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kralježnica', 'kraljeznica', 'hr', 'noun', 'A1', 'хребет', 'core', '{"gender": "f"}'::jsonb, '["Za kralježnicu je važno sjediti ravno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('štitnjača', 'stitnjaca', 'hr', 'noun', 'A1', 'щитоподібна залоза', 'core', '{"gender": "f"}'::jsonb, '["Liječnica me poslala na pregled štitnjače."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('probava', 'probava', 'hr', 'noun', 'A1', 'травлення', 'core', '{"gender": "f"}'::jsonb, '["Povrće je dobro za probavu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('živac', 'zivac', 'hr', 'noun', 'A1', 'нерв', 'core', '{"gender": "m"}'::jsonb, '["Zubar je rekao da je upaljen živac."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vrtoglavica', 'vrtoglavica', 'hr', 'noun', 'A1', 'запаморочення', 'core', '{"gender": "f"}'::jsonb, '["Ujutro imam vrtoglavicu kad ustanem."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('slabost', 'slabost', 'hr', 'noun', 'A1', 'слабкість', 'core', '{"gender": "f"}'::jsonb, '["Osjećam slabost u cijelom tijelu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('umor', 'umor', 'hr', 'noun', 'A1', 'втома', 'core', '{"gender": "m"}'::jsonb, '["Od umora ne mogu zaspati."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zimica', 'zimica', 'hr', 'noun', 'A1', 'озноб', 'core', '{"gender": "f"}'::jsonb, '["Imam temperaturu i zimicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('znojiti se', 'znojiti se', 'hr', 'verb', 'A1', 'пітніти', 'core', '{"aspect": "ipfv", "present": {"1s": "znojim se", "2s": "znojiš se", "3s": "znoji se"}}'::jsonb, '["Noću se jako znojim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('curi mi nos', 'curi mi nos', 'hr', 'phrase', 'A1', 'у мене нежить (тече з носа)', 'chunk', '{}'::jsonb, '["Curi mi nos i stalno kišem."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('začepljen nos', 'zacepljen nos', 'hr', 'phrase', 'A1', 'закладений ніс', 'collocation', '{"gender": "m"}'::jsonb, '["Ne mogu spavati, imam začepljen nos."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('antibiotik', 'antibiotik', 'hr', 'noun', 'A1', 'антибіотик', 'core', '{"gender": "m"}'::jsonb, '["Antibiotik pijte svakih dvanaest sati."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kroničan', 'kronican', 'hr', 'adjective', 'A1', 'хронічний', 'core', '{"f": "kronična", "n": "kronično"}'::jsonb, '["Imam kroničnu bolest, redovito idem na kontrolu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mirovanje', 'mirovanje', 'hr', 'noun', 'A1', 'спокій, постільний режим', 'core', '{"gender": "n"}'::jsonb, '["Liječnik mi je preporučio tri dana mirovanja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kapsula', 'kapsula', 'hr', 'noun', 'A1', 'капсула', 'core', '{"gender": "f"}'::jsonb, '["Uzmite jednu kapsulu ujutro."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pastila', 'pastila', 'hr', 'noun', 'A1', 'пастилка, льодяник (від горла)', 'core', '{"gender": "f"}'::jsonb, '["Pastile za grlo su bez recepta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sprej za nos', 'sprej za nos', 'hr', 'phrase', 'A1', 'спрей для носа', 'collocation', '{"gender": "m"}'::jsonb, '["Sprej za nos koristite najviše pet dana."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('progutati', 'progutati', 'hr', 'verb', 'A1', 'проковтнути', 'core', '{"aspect": "pfv", "present": {"1s": "progutam", "2s": "progutaš", "3s": "proguta"}}'::jsonb, '["Tabletu progutajte s čašom vode."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('otopiti', 'otopiti', 'hr', 'verb', 'A1', 'розчинити', 'core', '{"aspect": "pfv", "present": {"1s": "otopim", "2s": "otopiš", "3s": "otopi"}}'::jsonb, '["Prašak otopite u čaši tople vode."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bez recepta', 'bez recepta', 'hr', 'phrase', 'A1', 'без рецепта', 'chunk', '{}'::jsonb, '["Ovaj lijek možete kupiti bez recepta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nuspojava', 'nuspojava', 'hr', 'noun', 'A1', 'побічна дія', 'core', '{"gender": "f"}'::jsonb, '["Pospanost je česta nuspojava ovog lijeka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('karijes', 'karijes', 'hr', 'noun', 'A1', 'карієс', 'core', '{"gender": "m"}'::jsonb, '["Imate mali karijes na kutnjaku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('desni', 'desni', 'hr', 'noun', 'A1', 'ясна', 'core', '{"gender": "f_pl"}'::jsonb, '["Desni mi krvare kad perem zube."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('krunica', 'krunica', 'hr', 'noun', 'A1', 'коронка (зубна)', 'core', '{"gender": "f"}'::jsonb, '["Na ovaj zub trebate staviti krunicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('konac za zube', 'konac za zube', 'hr', 'phrase', 'A1', 'зубна нитка', 'collocation', '{"gender": "m"}'::jsonb, '["Konac za zube koristite svaku večer."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vaditi krv', 'vaditi krv', 'hr', 'phrase', 'A1', 'брати кров (на аналіз)', 'collocation', '{"aspect": "ipfv", "present": {"1s": "vadim krv", "2s": "vadiš krv", "3s": "vadi krv"}}'::jsonb, '["Krv se vadi ujutro od sedam do devet."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uzorak urina', 'uzorak urina', 'hr', 'phrase', 'A1', 'зразок сечі', 'collocation', '{"gender": "m"}'::jsonb, '["Uzorak urina donesite u laboratorij."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('šećer u krvi', 'secer u krvi', 'hr', 'phrase', 'A1', 'цукор у крові', 'collocation', '{"gender": "m"}'::jsonb, '["Šećer u krvi vam je u redu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kolesterol', 'kolesterol', 'hr', 'noun', 'A1', 'холестерин', 'core', '{"gender": "m"}'::jsonb, '["Kolesterol mi je malo povišen."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('magnetska rezonancija', 'magnetska rezonancija', 'hr', 'phrase', 'A1', 'МРТ (магнітно-резонансна томографія)', 'collocation', '{"gender": "f"}'::jsonb, '["Na magnetsku rezonanciju se čeka dva mjeseca."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('posjeći se', 'posjeci se', 'hr', 'verb', 'A1', 'порізатися', 'core', '{"aspect": "pfv", "present": {"1s": "posiječem se", "2s": "posiječeš se", "3s": "posiječe se"}}'::jsonb, '["Pazi da se ne posiječeš, nož je oštar."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('udariti se', 'udariti se', 'hr', 'verb', 'A1', 'вдаритися', 'core', '{"aspect": "pfv", "present": {"1s": "udarim se", "2s": "udariš se", "3s": "udari se"}}'::jsonb, '["Udario sam se u glavu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('upala uha', 'upala uha', 'hr', 'phrase', 'A1', 'запалення вуха (отит)', 'collocation', '{"gender": "f"}'::jsonb, '["Dijete ima upalu uha i plače."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vodene kozice', 'vodene kozice', 'hr', 'phrase', 'A1', 'вітряна віспа', 'collocation', '{"gender": "f_pl"}'::jsonb, '["U vrtiću su djeca imala vodene kozice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('čepić', 'cepic', 'hr', 'noun', 'A1', 'свічка (ліки)', 'core', '{"gender": "m"}'::jsonb, '["Za temperaturu bebi dajte čepić."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;

-- 1б. Виправлені слова (3); повторний запуск нічого не змінює
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'cjepivo' and ukrainian_translation = 'вакцина / щеплення' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'вакцина' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'težina' and ukrainian_translation = 'вага, складність' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'вага (тіла); складність' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'hitan' and ukrainian_translation = 'терміновий' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'терміновий, невідкладний' where id = r.id;
  end loop;
end $$;

-- 1а. Граматика A1.8: нові теми (0) і нові правила до наявних тем (2)
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Наказовий спосіб' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Наказовий спосіб»'; end if;
  if exists (select 1 from public.grammar_rules where id = '2d5d931f-e704-5006-8e19-3418fd54c5af') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('2d5d931f-e704-5006-8e19-3418fd54c5af', v_topic, '«Давайте»: uzmimo, idemo; neka uzme', 'Наказовий для «ми» — -mo: uzmimo, popijmo, pričekajmo (ići → idemo). Порада для третьої особи — neka + теперішній час: Neka uzme dvije tablete. Neka leži tri dana. У рецептах і порадах лікаря — Vi-форма: Uzimajte, Pijte, Ne pijte alkohol.', 'uzmimo · pričekajmo · idemo · neka uzme', '[{"hr": "Pričekajmo nalaz.", "ua": "Почекаймо на результат аналізу."}, {"hr": "Idemo kod liječnika.", "ua": "Ходімо до лікаря."}, {"hr": "Neka dijete pije puno vode.", "ua": "Нехай дитина п’є багато води."}, {"hr": "Ne pijte alkohol uz antibiotik.", "ua": "Не пийте алкоголь з антибіотиком."}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', '2d5d931f-e704-5006-8e19-3418fd54c5af', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Минулий час: radio sam, bila sam»'; end if;
  if exists (select 1 from public.grammar_rules where id = '55c2c257-234b-5d49-aa39-01aa04f53ac4') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('55c2c257-234b-5d49-aa39-01aa04f53ac4', v_topic, 'Se в минулому: ozlijedio sam se, on se ozlijedio', 'Зворотні дієслова в минулому: sam / si + se — Ozlijedila sam se. Jesi li se udario? У третій особі je зазвичай випадає перед se: On se ozlijedio (а не «on se je ozlijedio»), Ona se posjekla. Заперечення: Nisam se ozlijedio.', 'ozlijedio sam se · on se ozlijedio · nisam se udario', '[{"hr": "Posjekla sam se nožem.", "ua": "Я порізалася ножем."}, {"hr": "Filip je pao i udario se u koljeno.", "ua": "Філіп упав і вдарився коліном."}, {"hr": "Jesi li se ozlijedio?", "ua": "Ти травмувався?"}, {"hr": "Nisam se dobro osjećala.", "ua": "Я погано почувалася."}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', '55c2c257-234b-5d49-aa39-01aa04f53ac4', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;

-- 2. Перебудова наявних уроків модуля A1.8
-- A1.8 · урок 66: Запис до лікаря — перебудова: 13 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '08e31e8b-f8f7-5a80-89ed-093bc68dae03';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Запис до лікаря» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '41373d2a-09b8-540a-8ef8-51b27b30f188') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'grammar', (select coalesce(jsonb_agg(lg.grammar_topic_id), '[]'::jsonb) from public.lesson_grammar lg where lg.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a1_v3: урок перебудовано за темою — стара версія (слова, вправи, діалоги, граматика)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 66: Запис до лікаря', title_hr = 'Lekcija 66: Naručivanje kod liječnika',
         objectives = '["Записатися до сімейного лікаря й описати проблему", "Запитати про страховку й доплату", "Модальні: mogu li se naručiti, moram li platiti"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Модальні дієслова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Модальні дієслова»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'obiteljski liječnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ambulanta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ordinacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pacijent', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zdravstvena iskaznica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dopunsko osiguranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'participacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hitan slučaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prvi slobodni termin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'simptom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hitan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opisati', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '19482e1b-ec7f-58ea-80ba-fcd5c0de9c0d', 'fill_in_the_blank', 'Mogu li se ___ kod liječnika?', 'naručiti', '["naručim", "naručio", "naruči", "naručiti"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '94c5b1ed-9bda-5868-8cd4-03477ea3d8ff', 'multiple_choice', 'Що означає «participacija»?', 'доплата пацієнта (за медичну послугу)', '["найближчий вільний час (для запису)", "доплата пацієнта (за медичну послугу)", "амбулаторія", "біль"]'::jsonb, 'A1', 2, 'PUBLISHED', 'participacija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9a851698-a2e4-512f-9332-5af953a42a75', 'multiple_choice', 'Що означає «hitan»?', 'терміновий, невідкладний', '["описати", "доплата пацієнта (за медичну послугу)", "терміновий, невідкладний", "амбулаторія"]'::jsonb, 'A1', 3, 'PUBLISHED', 'hitan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4e8f27bc-9a12-50b0-8a76-78e011697d64', 'multiple_choice', 'Що означає «zdravstvena iskaznica»?', 'картка медичного страхування', '["терміновий, невідкладний", "сімейний лікар", "картка медичного страхування", "описати"]'::jsonb, 'A1', 4, 'PUBLISHED', 'zdravstvena iskaznica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7f95e953-3033-52dd-8731-86dc1944ed02', 'multiple_choice', 'Що означає «obiteljski liječnik»?', 'сімейний лікар', '["сімейний лікар", "терміновий, невідкладний", "додаткове медичне страхування", "доплата пацієнта (за медичну послугу)"]'::jsonb, 'A1', 5, 'PUBLISHED', 'obiteljski liječnik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9cc1c730-5277-53c2-a024-858e145c1f3c', 'multiple_choice', 'Як хорватською «амбулаторія»?', 'ambulanta', '["pacijent", "simptom", "ambulanta", "prvi slobodni termin"]'::jsonb, 'A1', 6, 'PUBLISHED', 'ambulanta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0c402663-6863-5a9c-8f88-88f00c2e9e81', 'multiple_choice', 'Як хорватською «пацієнт»?', 'pacijent', '["hitan", "pacijent", "prvi slobodni termin", "bol"]'::jsonb, 'A1', 7, 'PUBLISHED', 'pacijent', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9aedf3c9-9c45-5b55-b8dd-72874dbdbde9', 'type_answer', 'Напишіть хорватською: «описати»', 'opisati', null, 'A1', 8, 'PUBLISHED', 'opisati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'adbd7992-adb5-50d0-afb5-c9cfc227c55a', 'type_answer', 'Напишіть хорватською: «симптом»', 'simptom', null, 'A1', 9, 'PUBLISHED', 'simptom', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c4067b6e-e7cd-5401-9121-6c71cbaa6d66', 'sentence_builder', 'Складіть: «Можна записатися на четвер?»', 'Mogu li se naručiti za četvrtak?', '["za", "li", "se", "Mogu", "četvrtak?", "naručiti"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b71c6d20-dbf7-5480-a951-4991eaa3bc18', 'sentence_builder', 'Складіть: «У мене сильний біль.»', 'Imam jake bolove.', '["bolove.", "jake", "Imam"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6f316f7e-aa78-569c-b47d-764f7efc52b9', 'listening', 'Прослухайте і складіть фразу', 'Moram li nešto ponijeti?', '["li", "nešto", "Moram", "ponijeti?"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd800cbc0-1b7b-5429-a17f-0826f330d037', 'listening', 'Прослухайте і складіть фразу', 'Nisam, prvi put sam ovdje.', '["sam", "ovdje.", "prvi", "put", "Nisam,"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b4f88e00-cf9e-582a-9b68-ca0238918a2e', 'speaking', 'Мені потрібен найближчий вільний час.', 'Trebam prvi slobodni termin.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2d0758f7-aaa3-5791-ae60-c0dbf87f9729', 'speaking', 'Це невідкладний випадок.', 'Ovo je hitan slučaj.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('41373d2a-09b8-540a-8ef8-51b27b30f188', v_lesson, 'Дзвінок в амбулаторію', 'Poziv u ambulantu', 3661, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('9ee36fa6-7a96-5699-a545-97e234867f73', '41373d2a-09b8-540a-8ef8-51b27b30f188', 'Daša', 'Dobar dan, mogu li se naručiti kod doktorice Horvat?', 'Добрий день, можна записатися до лікарки Горват?', 1);
  perform pg_temp.turn('18e3acc2-7758-598d-aed1-dbd757568629', '41373d2a-09b8-540a-8ef8-51b27b30f188', 'Sestra', 'Prvi slobodni termin je u četvrtak u deset.', 'Найближчий вільний час — у четвер о десятій.', 2);
  perform pg_temp.turn('741fc940-175d-5901-8367-4cf1b6ee6be5', '41373d2a-09b8-540a-8ef8-51b27b30f188', 'Daša', 'Može li ranije? Imam jake bolove u leđima.', 'А можна раніше? У мене сильний біль у спині.', 3);
  perform pg_temp.turn('1f45e652-e2f0-5ffa-b35c-191d54678ed4', '41373d2a-09b8-540a-8ef8-51b27b30f188', 'Sestra', 'Ako je hitan slučaj, dođite danas do podne.', 'Якщо це невідкладно, приходьте сьогодні до обіду.', 4);
  perform pg_temp.turn('f02fe069-2466-54f4-b4b4-b70be6e6e352', '41373d2a-09b8-540a-8ef8-51b27b30f188', 'Daša', 'Moram li nešto ponijeti?', 'Мені щось треба взяти з собою?', 5);
  perform pg_temp.turn('692f9f10-b285-5014-af79-32c4c3aaaed1', '41373d2a-09b8-540a-8ef8-51b27b30f188', 'Sestra', 'Zdravstvenu iskaznicu i popis lijekova.', 'Картку медичного страхування й список ліків.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cc22289a-fc73-5ff9-af46-b7e79e8511be', v_lesson, 'В кабінеті', 'U ordinaciji', 3662, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('0a83919c-0240-5144-ab32-7f850978c3ae', 'cc22289a-fc73-5ff9-af46-b7e79e8511be', 'Liječnica', 'Izvolite, sjednite. Opišite mi simptome.', 'Прошу, сідайте. Опишіть мені симптоми.', 1);
  perform pg_temp.turn('92c67496-874d-523e-9e2a-4bf6fbe858b8', 'cc22289a-fc73-5ff9-af46-b7e79e8511be', 'Luka', 'Tri dana me boli grlo i imam temperaturu.', 'Три дні в мене болить горло й температура.', 2);
  perform pg_temp.turn('68224750-52b4-5130-a60a-db77ba3ba37c', 'cc22289a-fc73-5ff9-af46-b7e79e8511be', 'Liječnica', 'Jeste li već bili kod nas kao pacijent?', 'Ви вже були в нас як пацієнт?', 3);
  perform pg_temp.turn('542c793f-173e-5da2-a5cc-3b82899b69cb', 'cc22289a-fc73-5ff9-af46-b7e79e8511be', 'Luka', 'Nisam, prvi put sam ovdje.', 'Ні, я тут уперше.', 4);
  perform pg_temp.turn('d642fa16-d61a-5c90-83b4-581dae7dad40', 'cc22289a-fc73-5ff9-af46-b7e79e8511be', 'Liječnica', 'Imate li dopunsko osiguranje?', 'У вас є додаткове страхування?', 5);
  perform pg_temp.turn('960f0c6a-773f-5cee-b6c9-378a684186a4', 'cc22289a-fc73-5ff9-af46-b7e79e8511be', 'Luka', 'Nemam. Koliko je participacija?', 'Немає. Скільки доплата?', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 68: Симптоми: що з вами сталося? — перебудова: 11 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '878c0712-e4e5-5a7d-aab5-510c781da0c7';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Симптоми: що з вами сталося?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '87314585-851f-5353-8c67-871d4ab485cf') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'grammar', (select coalesce(jsonb_agg(lg.grammar_topic_id), '[]'::jsonb) from public.lesson_grammar lg where lg.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a1_v3: урок перебудовано за темою — стара версія (слова, вправи, діалоги, граматика)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 68: Симптоми: що з вами сталося?', title_hr = 'Lekcija 68: Simptomi: što vam se dogodilo?',
         objectives = '["Розповісти, як почалася хвороба: imala sam temperaturu, pala sam", "Описати симптоми: vrtoglavica, zimica, slabost", "Минулий час і se: nisam se dobro osjećala"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Минулий час: radio sam, bila sam»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'vrtoglavica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slabost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'umor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zimica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'znojiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'groznica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nesvjestica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kihati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kašljati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'curi mi nos', v_pos);
  v_pos := pg_temp.word(v_lesson, 'začepljen nos', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c69353be-1bec-5e15-bbd7-8f9f2ab227ae', 'fill_in_the_blank', 'Jučer sam ___ temperaturu.', 'imala', '["imam", "imati", "imala", "imat ću"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '54d1e6bf-00ea-5d74-9a81-325e579b0f96', 'multiple_choice', 'Що означає «curi mi nos»?', 'у мене нежить (тече з носа)', '["у мене нежить (тече з носа)", "озноб", "закладений ніс", "втома"]'::jsonb, 'A1', 2, 'PUBLISHED', 'curi mi nos', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '079acf5c-a2ee-59d0-a32d-f842dc989b9a', 'multiple_choice', 'Що означає «vrtoglavica»?', 'запаморочення', '["кашляти", "у мене нежить (тече з носа)", "непритомність", "запаморочення"]'::jsonb, 'A1', 3, 'PUBLISHED', 'vrtoglavica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '11c0d99a-044a-5174-8a33-7bd7dc9fa340', 'multiple_choice', 'Що означає «začepljen nos»?', 'закладений ніс', '["гарячка", "кашляти", "закладений ніс", "запаморочення"]'::jsonb, 'A1', 4, 'PUBLISHED', 'začepljen nos', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf776171-a946-51a3-b0f6-0f2a90642f55', 'multiple_choice', 'Як хорватською «кашляти»?', 'kašljati', '["kašljati", "začepljen nos", "groznica", "zimica"]'::jsonb, 'A1', 5, 'PUBLISHED', 'kašljati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6ba7057d-7ace-5d08-8cfd-2ae2bc218edc', 'multiple_choice', 'Як хорватською «слабкість»?', 'slabost', '["znojiti se", "groznica", "kihati", "slabost"]'::jsonb, 'A1', 6, 'PUBLISHED', 'slabost', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cf350600-1191-580d-abcd-b7e10d36e095', 'type_answer', 'Напишіть хорватською: «озноб»', 'zimica', null, 'A1', 7, 'PUBLISHED', 'zimica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '54d9280e-f371-5fae-a86c-047d98d9326d', 'type_answer', 'Напишіть хорватською: «пітніти»', 'znojiti se', null, 'A1', 8, 'PUBLISHED', 'znojiti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f8626879-f48d-5399-9dfe-54305ef9f49a', 'type_answer', 'Напишіть хорватською: «гарячка»', 'groznica', null, 'A1', 9, 'PUBLISHED', 'groznica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e9673034-c568-5b1b-ba53-226993c65f53', 'sentence_builder', 'Складіть: «Учора мені було погано.»', 'Jučer mi je bilo loše.', '["mi", "loše.", "Jučer", "je", "bilo"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9f1c5911-4a53-5f5f-accd-d47bced82b97', 'sentence_builder', 'Складіть: «Я погано почувалася.»', 'Nisam se dobro osjećala.', '["osjećala.", "Nisam", "dobro", "se"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6c56ada7-a399-5618-851f-573334c4ea83', 'listening', 'Прослухайте і складіть фразу', 'Jeste li pali u nesvijest?', '["li", "Jeste", "pali", "u", "nesvijest?"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '48ec16ca-05e5-5e2c-949a-3b89e31d8be0', 'listening', 'Прослухайте і складіть фразу', 'Kada je počelo?', '["je", "Kada", "počelo?"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0621ec14-2032-5389-86c3-90781f9d4af4', 'speaking', 'У мене запаморочення.', 'Imam vrtoglavicu.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ccb99f8b-8204-5c6a-a0b7-809336f9885a', 'speaking', 'У мене нежить.', 'Curi mi nos.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('87314585-851f-5353-8c67-871d4ab485cf', v_lesson, 'Що сталося?', 'Što vam se dogodilo?', 3681, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('eab5bd19-2053-5ebe-8623-7d81cce6bf0b', '87314585-851f-5353-8c67-871d4ab485cf', 'Liječnica', 'Što vam se dogodilo?', 'Що з вами сталося?', 1);
  perform pg_temp.turn('6bd44f03-c7ea-579f-aacc-2d0009ce7abc', '87314585-851f-5353-8c67-871d4ab485cf', 'Daša', 'Jučer sam se jako loše osjećala. Imala sam vrtoglavicu.', 'Учора я дуже погано почувалася. У мене було запаморочення.', 2);
  perform pg_temp.turn('d643a4a6-018b-56a7-9629-0395733d8ca6', '87314585-851f-5353-8c67-871d4ab485cf', 'Liječnica', 'Jeste li pali u nesvijest?', 'Ви знепритомніли?', 3);
  perform pg_temp.turn('3b66bb13-795e-5590-8068-74d91c27063e', '87314585-851f-5353-8c67-871d4ab485cf', 'Daša', 'Nisam, ali sam morala leći.', 'Ні, але мені довелося лягти.', 4);
  perform pg_temp.turn('bf519777-0256-5418-90ad-3c4d42eb7308', '87314585-851f-5353-8c67-871d4ab485cf', 'Liječnica', 'Jeste li imali temperaturu?', 'У вас була температура?', 5);
  perform pg_temp.turn('71771111-f3dc-500a-b5ed-7c24e78c47ed', '87314585-851f-5353-8c67-871d4ab485cf', 'Daša', 'Jesam, noću sam imala zimicu i jako sam se znojila.', 'Так, уночі мене морозило, і я дуже пітніла.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a9976eed-825f-524a-b0dc-c4d05757463c', v_lesson, 'Застуда', 'Prehlada', 3682, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('94640f65-f973-525f-bc9f-92f048303025', 'a9976eed-825f-524a-b0dc-c4d05757463c', 'Luka', 'Darja, cijeli dan kišeš.', 'Даріє, ти цілий день чхаєш.', 1);
  perform pg_temp.turn('2bddf76f-c33d-5d05-8458-d8e1af86723f', 'a9976eed-825f-524a-b0dc-c4d05757463c', 'Darja', 'Da, curi mi nos, a noću imam začepljen nos.', 'Так, у мене нежить, а вночі закладений ніс.', 2);
  perform pg_temp.turn('555a1219-a6df-5c81-a0f7-265849da5f80', 'a9976eed-825f-524a-b0dc-c4d05757463c', 'Luka', 'Kašlješ li?', 'Кашляєш?', 3);
  perform pg_temp.turn('6bdb0373-5ad9-54c1-b383-5e9d4ce28d7d', 'a9976eed-825f-524a-b0dc-c4d05757463c', 'Darja', 'Malo. Najgori je umor, osjećam veliku slabost.', 'Трохи. Найгірше — втома, я відчуваю сильну слабкість.', 4);
  perform pg_temp.turn('165f13a8-ab68-501f-bcc0-95b869b1ff0b', 'a9976eed-825f-524a-b0dc-c4d05757463c', 'Luka', 'Kada je počelo?', 'Коли це почалося?', 5);
  perform pg_temp.turn('9af6aae8-cafa-58b4-bdb2-65ca404046c0', 'a9976eed-825f-524a-b0dc-c4d05757463c', 'Darja', 'U nedjelju. Bila sam na moru i smrzla sam se.', 'У неділю. Я була на морі й замерзла.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 69: Діагноз і лікування — перебудова: 13 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '431b51ad-baa3-5387-94ac-a7273fdb9263';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Діагноз і лікування» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '99cd56e1-e49e-5da5-9bde-1e4ee91c8e60') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'grammar', (select coalesce(jsonb_agg(lg.grammar_topic_id), '[]'::jsonb) from public.lesson_grammar lg where lg.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a1_v3: урок перебудовано за темою — стара версія (слова, вправи, діалоги, граматика)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 69: Діагноз і лікування', title_hr = 'Lekcija 69: Dijagnoza i liječenje',
         objectives = '["Зрозуміти діагноз: upala, infekcija, virus", "Запитати, як лікуватися й скільки триває одужання", "Сполучники: jer, ako, ali, pa"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Сполучники' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Сполучники»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'dijagnoza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'liječenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'terapija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'infekcija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'virus', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gripa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'antibiotik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'propisati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kroničan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oporavak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izliječiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mirovanje', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fe9b6fce-4ec0-5c86-bd01-2cc0a4b8f686', 'fill_in_the_blank', 'Ostanite kod kuće, ___ imate temperaturu.', 'jer', '["a", "ali", "jer", "ili"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9128f55f-d667-526c-9bda-a36d04ab6bb6', 'multiple_choice', 'Що означає «propisati»?', 'виписати (рецепт)', '["спокій, постільний режим", "виписати (рецепт)", "грип", "діагноз"]'::jsonb, 'A1', 2, 'PUBLISHED', 'propisati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '310df311-3852-5094-9f80-d5645349f221', 'multiple_choice', 'Що означає «mirovanje»?', 'спокій, постільний режим', '["спокій, постільний режим", "антибіотик", "грип", "запалення"]'::jsonb, 'A1', 3, 'PUBLISHED', 'mirovanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '64f78203-0cd8-5a0b-87b4-bbfdf42d2afe', 'multiple_choice', 'Що означає «upala»?', 'запалення', '["інфекція", "відновлення", "запалення", "виписати (рецепт)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'upala', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5c5e8854-5bb3-5e8d-9c8a-d04dbe6556b6', 'multiple_choice', 'Як хорватською «лікування»?', 'liječenje', '["kroničan", "mirovanje", "liječenje", "infekcija"]'::jsonb, 'A1', 5, 'PUBLISHED', 'liječenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4bc455f7-9396-521d-b3cf-d55eae5b8e33', 'multiple_choice', 'Як хорватською «хронічний»?', 'kroničan', '["gripa", "kroničan", "propisati", "izliječiti"]'::jsonb, 'A1', 6, 'PUBLISHED', 'kroničan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '05098a88-ceca-5648-a5a2-442e4eb9f0bd', 'type_answer', 'Напишіть хорватською: «інфекція»', 'infekcija', null, 'A1', 7, 'PUBLISHED', 'infekcija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'adf1719b-b72d-5583-803c-33e0351560a9', 'type_answer', 'Напишіть хорватською: «вилікувати»', 'izliječiti', null, 'A1', 8, 'PUBLISHED', 'izliječiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c16ddc84-3880-5e74-ab80-55a7a372635e', 'type_answer', 'Напишіть хорватською: «антибіотик»', 'antibiotik', null, 'A1', 9, 'PUBLISHED', 'antibiotik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '88667003-3ada-54ea-a166-793278732a5e', 'sentence_builder', 'Складіть: «Який діагноз?»', 'Kakva je dijagnoza?', '["je", "Kakva", "dijagnoza?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '96b636a0-d18d-5812-913f-1c17f8fbb0ce', 'sentence_builder', 'Складіть: «Мені потрібен антибіотик?»', 'Trebam li antibiotik?', '["li", "Trebam", "antibiotik?"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9cf56b60-3bf7-5340-badc-000456c4f80a', 'listening', 'Прослухайте і складіть фразу', 'Trebam li antibiotik?', '["li", "antibiotik?", "Trebam"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4982e6a2-0979-5a91-995b-391dff6f121a', 'listening', 'Прослухайте і складіть фразу', 'Kako je tvoja mama?', '["mama?", "je", "tvoja", "Kako"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e97a9f59-df4a-56e5-b15c-6b4ec532b49d', 'speaking', 'У мене запалення горла.', 'Imam upalu grla.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bb2f6be8-3a72-5a2b-880a-5dcb8a0bf197', 'speaking', 'Скільки триває лікування?', 'Koliko traje liječenje?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('99cd56e1-e49e-5da5-9bde-1e4ee91c8e60', v_lesson, 'Що зі мною?', 'Što mi je?', 3691, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('e8c99f62-6b82-5d79-9125-a16f2252c57c', '99cd56e1-e49e-5da5-9bde-1e4ee91c8e60', 'Daša', 'Doktorice, kakva je dijagnoza?', 'Пані лікарко, який діагноз?', 1);
  perform pg_temp.turn('2b837264-6b0e-5fd6-b7c1-2301c53ea44d', '99cd56e1-e49e-5da5-9bde-1e4ee91c8e60', 'Liječnica', 'Imate upalu grla. To je bakterijska infekcija.', 'У вас запалення горла. Це бактеріальна інфекція.', 2);
  perform pg_temp.turn('b4165756-421d-5aab-a36a-dde070e6c61d', '99cd56e1-e49e-5da5-9bde-1e4ee91c8e60', 'Daša', 'Trebam li antibiotik?', 'Мені потрібен антибіотик?', 3);
  perform pg_temp.turn('6be02158-2d44-53e7-8ea3-80cf1583f928', '99cd56e1-e49e-5da5-9bde-1e4ee91c8e60', 'Liječnica', 'Da, propisat ću vam antibiotik za sedam dana.', 'Так, я випишу вам антибіотик на сім днів.', 4);
  perform pg_temp.turn('495a7e86-576f-5410-a1a5-fee8bf8b36c3', '99cd56e1-e49e-5da5-9bde-1e4ee91c8e60', 'Daša', 'Mogu li raditi?', 'Можна працювати?', 5);
  perform pg_temp.turn('01ad1460-d481-500f-8cc0-acce8e7428fe', '99cd56e1-e49e-5da5-9bde-1e4ee91c8e60', 'Liječnica', 'Ne, jer trebate tri dana mirovanja.', 'Ні, бо вам потрібно три дні постільного режиму.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ded201d0-7973-5038-ab5d-e95a72966a7f', v_lesson, 'Довге лікування', 'Dugo liječenje', 3692, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('ec1ad7ad-7bda-545b-b1a7-88807f992cb3', 'ded201d0-7973-5038-ab5d-e95a72966a7f', 'Marko', 'Kako je tvoja mama?', 'Як твоя мама?', 1);
  perform pg_temp.turn('4942e625-9aff-53cc-8249-9988349f8045', 'ded201d0-7973-5038-ab5d-e95a72966a7f', 'Darja', 'Bolje. Imala je gripu, ali virus je prošao.', 'Краще. У неї був грип, але вірус минув.', 2);
  perform pg_temp.turn('a02e241a-368d-5f9b-bcaf-b97fc69b3790', 'ded201d0-7973-5038-ab5d-e95a72966a7f', 'Marko', 'A ono s leđima?', 'А та проблема зі спиною?', 3);
  perform pg_temp.turn('b08aa599-4622-5c94-a2ae-fad4b44fee69', 'ded201d0-7973-5038-ab5d-e95a72966a7f', 'Darja', 'To je kronično, pa ide na terapiju dvaput tjedno.', 'Це хронічне, тож вона ходить на терапію двічі на тиждень.', 4);
  perform pg_temp.turn('9c23e0e1-c462-5f25-ace1-c7bda39a2184', 'ded201d0-7973-5038-ab5d-e95a72966a7f', 'Marko', 'Može li se to izliječiti?', 'Це можна вилікувати?', 5);
  perform pg_temp.turn('411bd94c-f186-57b3-a627-e38e1303d0e9', 'ded201d0-7973-5038-ab5d-e95a72966a7f', 'Darja', 'Ne potpuno, ali oporavak je dobar ako redovito vježba.', 'Не повністю, але відновлення добре, якщо регулярно займатися.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 70: В аптеці: як приймати ліки — перебудова: 15 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '123e68fa-291f-5ad6-8403-51db7020d641';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «В аптеці: як приймати ліки» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'b8e7a2bd-e518-5df5-91d9-df80f72fff30') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'grammar', (select coalesce(jsonb_agg(lg.grammar_topic_id), '[]'::jsonb) from public.lesson_grammar lg where lg.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a1_v3: урок перебудовано за темою — стара версія (слова, вправи, діалоги, граматика)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 70: В аптеці: як приймати ліки', title_hr = 'Lekcija 70: U ljekarni: kako uzimati lijek',
         objectives = '["Купити ліки без рецепта: pastile, sprej za nos, sirup", "Зрозуміти, як приймати: natašte, poslije jela", "Наказовий: uzmite, progutajte, ne pijte"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Наказовий спосіб' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Наказовий спосіб»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'sirup protiv kašlja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lijek protiv bolova', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tableta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kapsula', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pastila', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kapi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mast', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sprej za nos', v_pos);
  v_pos := pg_temp.word(v_lesson, 'doza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uzimati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'progutati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otopiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'natašte', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bez recepta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nuspojava', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b7717822-c73e-542d-97f1-ba93becfb858', 'fill_in_the_blank', 'Tabletu ___ s vodom.', 'progutajte', '["progutati", "progutam", "progutao", "progutajte"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '70bf200c-8a2f-52e5-9999-27f7a87d8b12', 'multiple_choice', 'Що означає «lijek protiv bolova»?', 'знеболювальне', '["сироп від кашлю", "проковтнути", "знеболювальне", "без рецепта"]'::jsonb, 'A1', 2, 'PUBLISHED', 'lijek protiv bolova', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6e094afa-fc78-5fad-974d-c04642330ef4', 'multiple_choice', 'Що означає «uzimati»?', 'брати; приймати (ліки)', '["знеболювальне", "проковтнути", "натщесерце", "брати; приймати (ліки)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'uzimati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a273ece0-7e79-5419-98a1-a4737ef7f2e9', 'multiple_choice', 'Що означає «bez recepta»?', 'без рецепта', '["капсула", "без рецепта", "розчинити", "таблетка"]'::jsonb, 'A1', 4, 'PUBLISHED', 'bez recepta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b5c3941b-83e4-5ace-b143-2d86eb71ca54', 'multiple_choice', 'Як хорватською «таблетка»?', 'tableta', '["tableta", "mast", "otopiti", "kapsula"]'::jsonb, 'A1', 5, 'PUBLISHED', 'tableta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8bf54a92-0831-5b09-b6f3-3598bd9ddbed', 'multiple_choice', 'Як хорватською «розчинити»?', 'otopiti', '["mast", "tableta", "uzimati", "otopiti"]'::jsonb, 'A1', 6, 'PUBLISHED', 'otopiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '50b49b52-a702-5353-bde6-4e9a4c655a8b', 'type_answer', 'Напишіть хорватською: «пастилка, льодяник (від горла)»', 'pastila', null, 'A1', 7, 'PUBLISHED', 'pastila', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0e4b962d-917f-516a-9c13-6ca03715f65d', 'type_answer', 'Напишіть хорватською: «доза»', 'doza', null, 'A1', 8, 'PUBLISHED', 'doza', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '09abc842-9687-5680-9121-94a5b4715d90', 'type_answer', 'Напишіть хорватською: «мазь»', 'mast', null, 'A1', 9, 'PUBLISHED', 'mast', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bfac9fc1-8617-5d0a-9be4-33262692d3be', 'sentence_builder', 'Складіть: «Приймайте натщесерце.»', 'Uzimajte lijek natašte.', '["Uzimajte", "natašte.", "lijek"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '00d4ee0e-ca9d-5e06-b419-9b70faa0a066', 'sentence_builder', 'Складіть: «Мені потрібні ліки без рецепта.»', 'Trebam lijek bez recepta.', '["lijek", "bez", "recepta.", "Trebam"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7132e111-b980-5079-98f0-0d8237c19986', 'listening', 'Прослухайте і складіть фразу', 'Ima li nuspojava?', '["nuspojava?", "li", "Ima"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd38a066e-a88c-57ac-99a0-4ff1033f3124', 'listening', 'Прослухайте і складіть фразу', 'Kako uzimati ove kapsule?', '["uzimati", "kapsule?", "Kako", "ove"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '93786061-10ed-5170-b269-b8d5fafce5da', 'speaking', 'Як приймати ці ліки?', 'Kako uzimati ovaj lijek?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cf730f0b-d29e-54bd-b95b-b2b913a2c053', 'speaking', 'Мені щось від горла.', 'Trebam nešto za grlo.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b8e7a2bd-e518-5df5-91d9-df80f72fff30', v_lesson, 'Від горла й нежитю', 'Za grlo i nos', 3701, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('384f0b44-ed25-5473-a443-ee4948122788', 'b8e7a2bd-e518-5df5-91d9-df80f72fff30', 'Daša', 'Dobar dan, trebam nešto za grlo, bez recepta.', 'Добрий день, мені щось від горла, без рецепта.', 1);
  perform pg_temp.turn('f0a766f4-8839-561c-9779-75931a09b5c0', 'b8e7a2bd-e518-5df5-91d9-df80f72fff30', 'Ljekarnica', 'Ove pastile su dobre. Uzmite jednu svaka tri sata.', 'Ці пастилки добрі. Беріть одну кожні три години.', 2);
  perform pg_temp.turn('e5344765-a5b7-5da7-b5f7-203b17539ade', 'b8e7a2bd-e518-5df5-91d9-df80f72fff30', 'Daša', 'Imam i začepljen nos.', 'У мене ще закладений ніс.', 3);
  perform pg_temp.turn('fd24d8f9-f212-53ba-90e3-6526c5babf7b', 'b8e7a2bd-e518-5df5-91d9-df80f72fff30', 'Ljekarnica', 'Ovaj sprej za nos, ali najviše pet dana.', 'Ось цей спрей для носа, але щонайбільше п’ять днів.', 4);
  perform pg_temp.turn('f574eb3b-dabb-58c0-bba5-6d169376548e', 'b8e7a2bd-e518-5df5-91d9-df80f72fff30', 'Daša', 'Ima li nuspojava?', 'Є побічні дії?', 5);
  perform pg_temp.turn('029de979-7c9d-5ab7-8b72-5e03287feb6a', 'b8e7a2bd-e518-5df5-91d9-df80f72fff30', 'Ljekarnica', 'Rijetko. Pročitajte upute u kutiji.', 'Рідко. Прочитайте інструкцію в коробці.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('915ed0a4-7d9f-5525-add9-a2e3cf2c6dce', v_lesson, 'Як приймати?', 'Kako uzimati?', 3702, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('d2fad54e-4738-518e-ac12-0518f4c2d397', '915ed0a4-7d9f-5525-add9-a2e3cf2c6dce', 'Luka', 'Kako uzimati ove kapsule?', 'Як приймати ці капсули?', 1);
  perform pg_temp.turn('59348701-58b9-530c-a959-387c69b767c1', '915ed0a4-7d9f-5525-add9-a2e3cf2c6dce', 'Ljekarnik', 'Natašte, ujutro. Progutajte ih s puno vode.', 'Натщесерце, зранку. Ковтайте їх, запиваючи великою кількістю води.', 2);
  perform pg_temp.turn('f79bbe30-6748-551e-aece-2f3052a150d6', '915ed0a4-7d9f-5525-add9-a2e3cf2c6dce', 'Luka', 'A prašak za djecu?', 'А порошок для дітей?', 3);
  perform pg_temp.turn('51f3f363-92e3-5801-83a0-57e55d0ea563', '915ed0a4-7d9f-5525-add9-a2e3cf2c6dce', 'Ljekarnik', 'Otopite ga u vodi. Doza piše na vrećici.', 'Розчиніть його у воді. Доза написана на пакетику.', 4);
  perform pg_temp.turn('d17b9951-eb7c-5070-84c5-b1234684e50a', '915ed0a4-7d9f-5525-add9-a2e3cf2c6dce', 'Luka', 'Imate li mast za modrice?', 'У вас є мазь від синців?', 5);
  perform pg_temp.turn('b66f0599-8802-5b7e-a723-7d83df84e423', '915ed0a4-7d9f-5525-add9-a2e3cf2c6dce', 'Ljekarnik', 'Imamo. Mažite tri puta dnevno.', 'Є. Мажте тричі на день.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 71: У стоматолога — перебудова: 11 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '247c3445-6ba3-50f0-a441-9073d6734451';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «У стоматолога» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'aa3bc669-ed50-5956-9f64-ae672a501aa8') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'grammar', (select coalesce(jsonb_agg(lg.grammar_topic_id), '[]'::jsonb) from public.lesson_grammar lg where lg.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a1_v3: урок перебудовано за темою — стара версія (слова, вправи, діалоги, граматика)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 71: У стоматолога', title_hr = 'Lekcija 71: Kod zubara',
         objectives = '["Пояснити стоматологу проблему: zubobolja, desni krvare", "Зрозуміти лікування: plomba, krunica, karijes", "Питання: Boli li? Koliko košta? Trebam li…?"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Побудова питань' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Побудова питань»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zubar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zubobolja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'karijes', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plomba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'desni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krunica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'konac za zube', v_pos);
  v_pos := pg_temp.word(v_lesson, 'injekcija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'anestezija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izvaditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'popravljati', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '77a46998-0307-559d-8f2f-00feff52dee7', 'fill_in_the_blank', '___ zub vas boli?', 'Koji', '["Kakvo", "Koja", "Koje", "Koji"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '928955d8-ec00-58ad-826c-c805426719b4', 'multiple_choice', 'Що означає «desni»?', 'ясна', '["видалити (зуб); вийняти", "укол", "ясна", "коронка (зубна)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'desni', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4daf70c2-9bee-5999-8ae1-9b439142a08d', 'multiple_choice', 'Що означає «izvaditi»?', 'видалити (зуб); вийняти', '["зубний біль", "укол", "видалити (зуб); вийняти", "ремонтувати (процес)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'izvaditi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f66aec94-ee80-5662-834a-ca0eb9f519d7', 'multiple_choice', 'Що означає «konac za zube»?', 'зубна нитка', '["анестезія", "карієс", "ясна", "зубна нитка"]'::jsonb, 'A1', 4, 'PUBLISHED', 'konac za zube', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e38abe58-5bb6-5d44-af9b-f5e49181af4d', 'multiple_choice', 'Як хорватською «стоматолог»?', 'zubar', '["desni", "zubar", "popravljati", "plomba"]'::jsonb, 'A1', 5, 'PUBLISHED', 'zubar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5b5269aa-69c9-56b9-a955-502a782791af', 'multiple_choice', 'Як хорватською «карієс»?', 'karijes', '["konac za zube", "karijes", "popravljati", "injekcija"]'::jsonb, 'A1', 6, 'PUBLISHED', 'karijes', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '73aa8caf-dc3a-575a-bf7a-1643ade26321', 'type_answer', 'Напишіть хорватською: «укол»', 'injekcija', null, 'A1', 7, 'PUBLISHED', 'injekcija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fbff7806-0d0a-5378-ab51-f3d0173d9c2e', 'type_answer', 'Напишіть хорватською: «ремонтувати (процес)»', 'popravljati', null, 'A1', 8, 'PUBLISHED', 'popravljati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8c5a5c93-65a5-509c-9aaf-4176450fe53e', 'type_answer', 'Напишіть хорватською: «анестезія»', 'anestezija', null, 'A1', 9, 'PUBLISHED', 'anestezija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '628a5614-5ea4-5f06-9811-28be55cbd837', 'sentence_builder', 'Складіть: «Мені потрібна пломба?»', 'Trebam li plombu?', '["li", "Trebam", "plombu?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '93b91810-53d7-53ef-8188-fa677a8bd10e', 'sentence_builder', 'Складіть: «У мене болить зуб.»', 'Boli me zub.', '["me", "zub.", "Boli"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9999a65c-edcb-57a2-a8ec-8878a504786a', 'listening', 'Прослухайте і складіть фразу', 'Koji zub vas boli?', '["Koji", "zub", "boli?", "vas"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1da74edb-e41c-580b-8b37-a248295df65d', 'listening', 'Прослухайте і складіть фразу', 'Koliko košta krunica?', '["košta", "Koliko", "krunica?"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '216610d7-bfbb-5c5f-96dd-d8e5ec9e6418', 'speaking', 'У мене сильно болить зуб.', 'Imam jaku zubobolju.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '05193732-a9b5-589d-8e5d-667a6d05287f', 'speaking', 'Буде боляче?', 'Hoće li boljeti?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('aa3bc669-ed50-5956-9f64-ae672a501aa8', v_lesson, 'Болить зуб', 'Boli me zub', 3711, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('c74914b5-f1bc-561a-b58d-63190e1e8669', 'aa3bc669-ed50-5956-9f64-ae672a501aa8', 'Daša', 'Dobar dan, imam jaku zubobolju od jučer.', 'Добрий день, у мене з учора сильно болить зуб.', 1);
  perform pg_temp.turn('e7f6160e-a15a-56b2-bd7f-8e9fad30db7d', 'aa3bc669-ed50-5956-9f64-ae672a501aa8', 'Zubar', 'Koji zub vas boli?', 'Який зуб вас болить?', 2);
  perform pg_temp.turn('a125c392-c832-5b7b-8f75-497c756f7569', 'aa3bc669-ed50-5956-9f64-ae672a501aa8', 'Daša', 'Dolje lijevo, kad pijem hladno.', 'Знизу ліворуч, коли п’ю холодне.', 3);
  perform pg_temp.turn('6cf8ff5f-7112-51cc-ba0b-b99d26c64c23', 'aa3bc669-ed50-5956-9f64-ae672a501aa8', 'Zubar', 'Imate karijes. Trebate plombu.', 'У вас карієс. Потрібна пломба.', 4);
  perform pg_temp.turn('5fb2daca-22e9-5ed8-952c-2ea40d37f708', 'aa3bc669-ed50-5956-9f64-ae672a501aa8', 'Daša', 'Hoće li boljeti?', 'Буде боляче?', 5);
  perform pg_temp.turn('b393e941-30df-5f1a-9d21-3c2877a8ddf1', 'aa3bc669-ed50-5956-9f64-ae672a501aa8', 'Zubar', 'Nećete ništa osjetiti, dobit ćete anesteziju.', 'Ви нічого не відчуєте, вам зроблять знеболення.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('50f17c24-f702-508c-aae9-322de5d105ea', v_lesson, 'Ясна й коронка', 'Desni i krunica', 3712, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('2441f082-b3f7-5801-8d33-ce4f4591eaf1', '50f17c24-f702-508c-aae9-322de5d105ea', 'Marko', 'Desni mi krvare kad perem zube.', 'У мене кровоточать ясна, коли чищу зуби.', 1);
  perform pg_temp.turn('4bf92f8e-6ab5-5f39-a9ac-c4076ce2a547', '50f17c24-f702-508c-aae9-322de5d105ea', 'Zubarica', 'Koristite li konac za zube?', 'Ви користуєтеся зубною ниткою?', 2);
  perform pg_temp.turn('e709aa99-3ca4-5632-a38e-33cd5d2e6737', '50f17c24-f702-508c-aae9-322de5d105ea', 'Marko', 'Ne baš. A što je sa starim zubom?', 'Не дуже. А що зі старим зубом?', 3);
  perform pg_temp.turn('ad3c3508-6a47-5c95-b3e6-ab3b7accf7fa', '50f17c24-f702-508c-aae9-322de5d105ea', 'Zubarica', 'Ne trebamo ga izvaditi, stavit ćemo krunicu.', 'Нам не треба його видаляти, поставимо коронку.', 4);
  perform pg_temp.turn('4e7d62dd-c518-557c-ad18-6a73bec1af75', '50f17c24-f702-508c-aae9-322de5d105ea', 'Marko', 'Koliko košta krunica?', 'Скільки коштує коронка?', 5);
  perform pg_temp.turn('ab22732f-632c-5129-a9ca-e98dd7301927', '50f17c24-f702-508c-aae9-322de5d105ea', 'Zubarica', 'Ovisi o materijalu. Prvo ga popravljamo, pa vidimo.', 'Залежить від матеріалу. Спершу лікуємо, потім побачимо.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 72: Аналізи й обстеження — перебудова: 15 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '293af384-4ee2-5746-80a8-e8ffdc7009bc';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Аналізи й обстеження» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'b3e85487-06c1-58c0-bebc-ed356e4c90e3') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'grammar', (select coalesce(jsonb_agg(lg.grammar_topic_id), '[]'::jsonb) from public.lesson_grammar lg where lg.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a1_v3: урок перебудовано за темою — стара версія (слова, вправи, діалоги, граматика)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 72: Аналізи й обстеження', title_hr = 'Lekcija 72: Pretrage i nalazi',
         objectives = '["Здати аналізи: vaditi krv, uzorak urina, natašte", "Зрозуміти результат: šećer u krvi, kolesterol", "Родовий: nalaz krvi, razina šećera, do devet sati"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Родовий відмінок: основи' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Родовий відмінок: основи»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'specijalist', v_pos);
  v_pos := pg_temp.word(v_lesson, 'laboratorij', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nalaz krvi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'liječnički nalaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vaditi krv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uzorak urina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šećer u krvi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolesterol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pretraga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kontrola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rendgen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ultrazvuk', v_pos);
  v_pos := pg_temp.word(v_lesson, 'magnetska rezonancija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjeriti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tlakomjer', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b12293f-5853-55da-8bff-9773818357d7', 'fill_in_the_blank', 'Imam uputnicu za nalaz ___.', 'krvi', '["krv", "krvlju", "krvi", "krvi li"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '33bf0b39-348c-512f-ba76-2603b37adb92', 'multiple_choice', 'Що означає «liječnički nalaz»?', 'медичний висновок', '["вимірювати", "рентген", "медичний висновок", "контрольний огляд; контроль"]'::jsonb, 'A1', 2, 'PUBLISHED', 'liječnički nalaz', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5d5da63e-a1cc-56d7-aa35-79c46c6dacf5', 'multiple_choice', 'Що означає «magnetska rezonancija»?', 'МРТ (магнітно-резонансна томографія)', '["МРТ (магнітно-резонансна томографія)", "зразок сечі", "обстеження; аналіз", "рентген"]'::jsonb, 'A1', 3, 'PUBLISHED', 'magnetska rezonancija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '04312c1a-a807-5f12-bbf3-a46ba2e8b5e7', 'multiple_choice', 'Що означає «vaditi krv»?', 'брати кров (на аналіз)', '["цукор у крові", "рентген", "лабораторія", "брати кров (на аналіз)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'vaditi krv', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5fc77e4b-a877-573d-a2ae-d4a394c04411', 'multiple_choice', 'Як хорватською «спеціаліст»?', 'specijalist', '["ultrazvuk", "tlakomjer", "specijalist", "vaditi krv"]'::jsonb, 'A1', 5, 'PUBLISHED', 'specijalist', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '220dec0a-b92e-5dfe-9914-fd162588f80f', 'multiple_choice', 'Як хорватською «вимірювати»?', 'mjeriti', '["uzorak urina", "laboratorij", "mjeriti", "nalaz krvi"]'::jsonb, 'A1', 6, 'PUBLISHED', 'mjeriti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '88fa72b4-d54e-5b2b-9fb1-4d52ad2a174a', 'type_answer', 'Напишіть хорватською: «ультразвук (УЗД)»', 'ultrazvuk', null, 'A1', 7, 'PUBLISHED', 'ultrazvuk', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd98f50d0-fe90-5999-9e24-f1f65350aa1a', 'type_answer', 'Напишіть хорватською: «рентген»', 'rendgen', null, 'A1', 8, 'PUBLISHED', 'rendgen', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '894fb1b9-d54c-50f8-bad2-649a397072c7', 'type_answer', 'Напишіть хорватською: «холестерин»', 'kolesterol', null, 'A1', 9, 'PUBLISHED', 'kolesterol', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ed98b6b5-4c9a-56a2-a5d9-4f7226640dcd', 'sentence_builder', 'Складіть: «Я прийшла здати кров.»', 'Došla sam vaditi krv.', '["krv.", "Došla", "vaditi", "sam"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b6152614-8d1c-5af4-90cd-8606a26b2ebb', 'sentence_builder', 'Складіть: «Коли будуть результати?»', 'Kada su nalazi gotovi?', '["su", "Kada", "nalazi", "gotovi?"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd1db581-bae8-5384-a955-fd838e094127', 'listening', 'Прослухайте і складіть фразу', 'Jeste li natašte?', '["natašte?", "Jeste", "li"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e0386903-14c8-5d29-8f72-dfe364c372c0', 'listening', 'Прослухайте і складіть фразу', 'Prvo rendgen, pa vidimo.', '["pa", "rendgen,", "vidimo.", "Prvo"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '68d64568-d3d9-54ee-9eeb-9213b7e0bdce', 'speaking', 'Я натщесерце.', 'Natašte sam.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '35494ca1-2c43-55a9-ab23-4d0048a57598', 'speaking', 'Мені потрібне ще обстеження?', 'Trebam li još neku pretragu?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b3e85487-06c1-58c0-bebc-ed356e4c90e3', v_lesson, 'У лабораторії', 'U laboratoriju', 3721, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('4c56bdda-3120-56b5-9e60-6c52eca10b94', 'b3e85487-06c1-58c0-bebc-ed356e4c90e3', 'Daša', 'Dobar dan, imam uputnicu za nalaz krvi.', 'Добрий день, у мене направлення на аналіз крові.', 1);
  perform pg_temp.turn('0ce9aede-e33c-50c3-a500-bf79dfd67f45', 'b3e85487-06c1-58c0-bebc-ed356e4c90e3', 'Sestra', 'Jeste li natašte?', 'Ви натщесерце?', 2);
  perform pg_temp.turn('b5d3eabe-e914-5659-ba4a-8c409c9ef8d6', 'b3e85487-06c1-58c0-bebc-ed356e4c90e3', 'Daša', 'Jesam, nisam ništa jela od jučer.', 'Так, я нічого не їла з учора.', 3);
  perform pg_temp.turn('3b303272-9e32-5a61-a5b6-6c802de33fda', 'b3e85487-06c1-58c0-bebc-ed356e4c90e3', 'Sestra', 'Dobro. Donijeli ste i uzorak urina?', 'Добре. Ви принесли й зразок сечі?', 4);
  perform pg_temp.turn('ea53ea6c-277b-5793-bf2a-6b2b1daadb4f', 'b3e85487-06c1-58c0-bebc-ed356e4c90e3', 'Daša', 'Jesam, evo ga. Kada su nalazi gotovi?', 'Так, ось він. Коли будуть готові результати?', 5);
  perform pg_temp.turn('004488d5-91b2-5c84-b6cf-76c8eee30ee8', 'b3e85487-06c1-58c0-bebc-ed356e4c90e3', 'Sestra', 'Sutra poslije podne, vidjet ćete ih u e-Građanima.', 'Завтра по обіді, побачите їх у e-Građani.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('934687bb-b0c3-5c16-8b9f-84bc386709f1', v_lesson, 'Результати', 'Rezultati', 3722, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('e625161c-0b1d-5d53-b1fc-f9982f347a34', '934687bb-b0c3-5c16-8b9f-84bc386709f1', 'Liječnik', 'Šećer u krvi vam je u redu, ali kolesterol je malo visok.', 'Цукор у крові в нормі, а холестерин трохи високий.', 1);
  perform pg_temp.turn('b541b582-3c47-534d-a6b3-df093242fc76', '934687bb-b0c3-5c16-8b9f-84bc386709f1', 'Luka', 'Trebam li još neku pretragu?', 'Мені потрібне ще якесь обстеження?', 2);
  perform pg_temp.turn('a85aac9d-c8d3-5b46-9fed-692d4c261d8e', '934687bb-b0c3-5c16-8b9f-84bc386709f1', 'Liječnik', 'Ultrazvuk srca i kontrolu za tri mjeseca.', 'УЗД серця й контроль через три місяці.', 3);
  perform pg_temp.turn('338051d2-23e6-584c-a7a3-37794e453167', '934687bb-b0c3-5c16-8b9f-84bc386709f1', 'Luka', 'A koljeno? Specijalist je spomenuo magnetsku rezonanciju.', 'А коліно? Спеціаліст згадував МРТ.', 4);
  perform pg_temp.turn('deb1d9f2-1185-5303-a358-fe45105a6e60', '934687bb-b0c3-5c16-8b9f-84bc386709f1', 'Liječnik', 'Prvo rendgen, pa vidimo.', 'Спершу рентген, а там побачимо.', 5);
  perform pg_temp.turn('a6a62b74-bb19-5bbc-ab5f-724e686a7e0a', '934687bb-b0c3-5c16-8b9f-84bc386709f1', 'Luka', 'Trebam li mjeriti tlak kod kuće?', 'Мені вимірювати тиск удома?', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 73: Травма й швидка допомога — перебудова: 16 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'd5dee6c5-f510-57b9-a1ed-4b0a60e8e09a';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Травма й швидка допомога» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '03da13fc-06e9-5739-8690-5c2f40fadb92') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'grammar', (select coalesce(jsonb_agg(lg.grammar_topic_id), '[]'::jsonb) from public.lesson_grammar lg where lg.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a1_v3: урок перебудовано за темою — стара версія (слова, вправи, діалоги, граматика)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 73: Травма й швидка допомога', title_hr = 'Lekcija 73: Ozljeda i hitna pomoć',
         objectives = '["Розповісти, що сталося: pao sam, posjekla sam se, udario sam se", "Надати першу допомогу: zavoj, flaster", "Минулий час зі se: ozlijedio se, posjekla sam se"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Минулий час: radio sam, bila sam»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'ozljeda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ozlijediti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pasti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udariti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posjeći se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slomiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uganuti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krvariti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'modrica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otečen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opeklina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zavoj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'flaster', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gips', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hitni prijem', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e124d5be-4bc2-5302-8c0b-1641ff2cc99e', 'fill_in_the_blank', 'Pao sam i ___ se u glavu.', 'udario', '["udaren", "udariti", "udario", "udarim"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '86cfe2cb-e746-5478-9359-9a8170c8d8fa', 'multiple_choice', 'Що означає «hitni prijem»?', 'приймальне відділення (невідкладна допомога)', '["кровоточити", "бинт / пов''язка", "впасти", "приймальне відділення (невідкладна допомога)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'hitni prijem', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f3a7f20f-3e42-5a7a-8473-547614ccce72', 'multiple_choice', 'Що означає «modrica»?', 'синець', '["підвернути; вивихнути", "рана", "синець", "кровоточити"]'::jsonb, 'A1', 3, 'PUBLISHED', 'modrica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a3430185-97f2-546d-88de-ea77dd7e6188', 'multiple_choice', 'Що означає «posjeći se»?', 'порізатися', '["пластир", "порізатися", "синець", "кровоточити"]'::jsonb, 'A1', 4, 'PUBLISHED', 'posjeći se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '87153933-96c0-50c1-9a13-b169008424a2', 'multiple_choice', 'Як хорватською «зламати»?', 'slomiti', '["posjeći se", "opeklina", "rana", "slomiti"]'::jsonb, 'A1', 5, 'PUBLISHED', 'slomiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '454c75d9-7441-5071-95b4-f59ca0c3b93c', 'multiple_choice', 'Як хорватською «вдаритися»?', 'udariti se', '["udariti se", "hitni prijem", "pasti", "modrica"]'::jsonb, 'A1', 6, 'PUBLISHED', 'udariti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '45f7fa7a-1599-537c-9756-e95d82345b6b', 'type_answer', 'Напишіть хорватською: «пластир»', 'flaster', null, 'A1', 7, 'PUBLISHED', 'flaster', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '18a09b19-3b09-503b-9348-139ef2445d6e', 'type_answer', 'Напишіть хорватською: «рана»', 'rana', null, 'A1', 8, 'PUBLISHED', 'rana', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e2ad9d14-b7b7-5fd7-b8d1-0a841dc07326', 'type_answer', 'Напишіть хорватською: «травма»', 'ozljeda', null, 'A1', 9, 'PUBLISHED', 'ozljeda', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae80d8de-7fad-59ee-9e3f-dae16f81ff83', 'sentence_builder', 'Складіть: «Я впала й підвернула ногу.»', 'Pala sam i uganula nogu.', '["Pala", "uganula", "i", "nogu.", "sam"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '746560e8-e73f-5586-9ad0-f3d0c6bc3de4', 'sentence_builder', 'Складіть: «Рана кровоточить.»', 'Rana krvari.', '["krvari.", "Rana"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8b35f1e3-27f9-5fe5-a561-aa65f93d7ff8', 'listening', 'Прослухайте і складіть фразу', 'Pokaži. Rana jako krvari.', '["Pokaži.", "krvari.", "jako", "Rana"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd4bef072-f7d8-511a-bf02-2598d7ed1c99', 'listening', 'Прослухайте і складіть фразу', 'Mogu, ali jako boli.', '["jako", "Mogu,", "ali", "boli."]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa53d308-b510-5e9e-9061-b4d1dc9a3568', 'speaking', 'Я порізався.', 'Posjekao sam se.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b0c77c0e-fce7-50aa-8b3b-e66607d6df6f', 'speaking', 'Що сталося?', 'Što se dogodilo?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('03da13fc-06e9-5739-8690-5c2f40fadb92', v_lesson, 'Удома', 'Kod kuće', 3731, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('a9ba3eab-44ee-5b01-90cf-195a12748f2d', '03da13fc-06e9-5739-8690-5c2f40fadb92', 'Daša', 'Joj! Posjekla sam se nožem.', 'Ой! Я порізалася ножем.', 1);
  perform pg_temp.turn('aa464ba8-c5c7-5998-acbc-7f6a358810c2', '03da13fc-06e9-5739-8690-5c2f40fadb92', 'Luka', 'Pokaži. Rana jako krvari.', 'Покажи. Рана сильно кровоточить.', 2);
  perform pg_temp.turn('ffffc22e-d780-56f1-9a5d-c5c08c6dedb9', '03da13fc-06e9-5739-8690-5c2f40fadb92', 'Daša', 'Daj mi flaster, brzo!', 'Дай мені пластир, швидко!', 3);
  perform pg_temp.turn('82fec6b2-e9f3-5473-ae36-e9e1019686b1', '03da13fc-06e9-5739-8690-5c2f40fadb92', 'Luka', 'Flaster je premali, stavit ću zavoj.', 'Пластир замалий, я накладу бинт.', 4);
  perform pg_temp.turn('3ff382d0-e223-5970-8267-8a8d3361dbf8', '03da13fc-06e9-5739-8690-5c2f40fadb92', 'Daša', 'Jučer sam se i opekla na pećnici.', 'А вчора я ще й обпеклася об духовку.', 5);
  perform pg_temp.turn('bd52bd5e-aca3-5b08-b1c4-bf465cb19c18', '03da13fc-06e9-5739-8690-5c2f40fadb92', 'Luka', 'Danas kuham ja!', 'Сьогодні готую я!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('522874fe-7f8a-5f77-84bb-15523a83121b', v_lesson, 'У приймальному відділенні', 'Na hitnom prijemu', 3732, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('45fc7053-ce67-5a2f-bcd9-33cfb1ea99cd', '522874fe-7f8a-5f77-84bb-15523a83121b', 'Liječnica', 'Što se dogodilo?', 'Що сталося?', 1);
  perform pg_temp.turn('120dc670-44bc-5ed4-b710-135733f1e2cc', '522874fe-7f8a-5f77-84bb-15523a83121b', 'Marko', 'Pao sam s bicikla i udario se u ruku.', 'Я впав з велосипеда й ударив руку.', 2);
  perform pg_temp.turn('b5cb444e-626d-55be-80f6-9d6196fe1bdf', '522874fe-7f8a-5f77-84bb-15523a83121b', 'Liječnica', 'Ruka je otečena. Možete li pomaknuti prste?', 'Рука набрякла. Можете поворушити пальцями?', 3);
  perform pg_temp.turn('3cd2cd98-ae1a-509b-8976-d5ba5220f2e1', '522874fe-7f8a-5f77-84bb-15523a83121b', 'Marko', 'Mogu, ali jako boli.', 'Можу, але дуже боляче.', 4);
  perform pg_temp.turn('ad842a91-ec7a-5849-bfa5-2958df4e5ec9', '522874fe-7f8a-5f77-84bb-15523a83121b', 'Liječnica', 'Rendgen pokazuje da ste slomili kost. Trebate gips.', 'Рентген показує, що у вас перелом. Потрібен гіпс.', 5);
  perform pg_temp.turn('5b4727a2-c92a-5b2d-90eb-182a5bb0ca53', '522874fe-7f8a-5f77-84bb-15523a83121b', 'Marko', 'A ova modrica na koljenu?', 'А цей синець на коліні?', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 74: У педіатра — перебудова: 12 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '0df023bb-17fb-5006-91bf-3b911dd30295';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «У педіатра» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'a67c2941-5e04-5f17-bbab-e24f0ab4afc0') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'grammar', (select coalesce(jsonb_agg(lg.grammar_topic_id), '[]'::jsonb) from public.lesson_grammar lg where lg.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a1_v3: урок перебудовано за темою — стара версія (слова, вправи, діалоги, граматика)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 74: У педіатра', title_hr = 'Lekcija 74: Kod pedijatra',
         objectives = '["Описати симптоми дитини: povraća, ima osip, proljev", "Зрозуміти поради педіатра й щеплення", "Наказовий: dajte, neka pije, mjerite"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Наказовий спосіб' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Наказовий спосіб»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'pedijatar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dojenče', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pregledati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'toplomjer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osip', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povraćati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'proljev', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upala uha', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vodene kozice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cijepljenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cjepivo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čepić', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '78fb8d59-d1dc-5963-ad4e-7e1f962125ce', 'fill_in_the_blank', '___ mu puno vode, molim vas.', 'Dajte', '["Dajte", "Dam", "Dati", "Daje"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d5d2fc0-a92a-51d7-ae4f-3c24e1225d2e', 'multiple_choice', 'Що означає «dojenče»?', 'немовля', '["щеплення", "немовля", "блювати", "вакцина"]'::jsonb, 'A1', 2, 'PUBLISHED', 'dojenče', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6040d16e-e832-59a8-b6b1-354c09a2d585', 'multiple_choice', 'Що означає «upala uha»?', 'запалення вуха (отит)', '["свічка (ліки)", "вакцина", "немовля", "запалення вуха (отит)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'upala uha', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'edc1cf53-040f-5f55-b9da-166c8f03e5ff', 'multiple_choice', 'Що означає «čepić»?', 'свічка (ліки)', '["немовля", "термометр", "свічка (ліки)", "оглянути (лікарем)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'čepić', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a38e334d-e5e7-5f4c-9742-f8804b081d5b', 'multiple_choice', 'Як хорватською «блювати»?', 'povraćati', '["pedijatar", "proljev", "cjepivo", "povraćati"]'::jsonb, 'A1', 5, 'PUBLISHED', 'povraćati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '587293d4-2f2c-5c57-bddb-6e8cdaff85da', 'multiple_choice', 'Як хорватською «пронос; діарея»?', 'proljev', '["proljev", "povraćati", "osip", "cjepivo"]'::jsonb, 'A1', 6, 'PUBLISHED', 'proljev', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae8550dd-ba4f-5ef7-a43f-63777c1e68d0', 'type_answer', 'Напишіть хорватською: «висип»', 'osip', null, 'A1', 7, 'PUBLISHED', 'osip', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a53c419b-1252-5d23-87e1-02f42a56a05e', 'type_answer', 'Напишіть хорватською: «оглянути (лікарем)»', 'pregledati', null, 'A1', 8, 'PUBLISHED', 'pregledati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f7c490e0-d9fa-5c86-a2af-9a22a3338390', 'type_answer', 'Напишіть хорватською: «педіатр»', 'pedijatar', null, 'A1', 9, 'PUBLISHED', 'pedijatar', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '43fff5a7-0e9c-5ed2-a39e-11044cc0336a', 'sentence_builder', 'Складіть: «Дитина блює з ранку.»', 'Dijete povraća od jutra.', '["povraća", "jutra.", "od", "Dijete"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'db24d778-5304-5503-aad5-d0de12b88b3e', 'sentence_builder', 'Складіть: «Нехай п’є багато води.»', 'Neka pije puno vode.', '["vode.", "Neka", "puno", "pije"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa94698b-eb46-5581-a6b7-7fe0ff9fdace', 'listening', 'Прослухайте і складіть фразу', 'Ima li temperaturu?', '["li", "Ima", "temperaturu?"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa6c4754-72e2-5bed-a3d1-e0c1a277d516', 'listening', 'Прослухайте і складіть фразу', 'Koliko je beba stara?', '["beba", "Koliko", "stara?", "je"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f8990344-f1e3-5bec-8f34-8b9f2edf5504', 'speaking', 'У дитини висип.', 'Dijete ima osip.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '42c3d3de-4fe0-5e45-b84c-7671f4948e01', 'speaking', 'Ми прийшли на щеплення.', 'Došli smo na cijepljenje.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a67c2941-5e04-5f17-bbab-e24f0ab4afc0', v_lesson, 'Дитина хворіє', 'Dijete je bolesno', 3741, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('8b846369-2629-54b1-aa25-a06150b5675e', 'a67c2941-5e04-5f17-bbab-e24f0ab4afc0', 'Daša', 'Doktore, mali od jutros povraća i ima proljev.', 'Пане лікарю, малий з ранку блює, і в нього пронос.', 1);
  perform pg_temp.turn('ff1ff02d-8cb8-5b04-ab90-550c451a1781', 'a67c2941-5e04-5f17-bbab-e24f0ab4afc0', 'Pedijatar', 'Ima li temperaturu?', 'У нього температура?', 2);
  perform pg_temp.turn('006e7ad9-1b94-5578-8364-cd732d52b93f', 'a67c2941-5e04-5f17-bbab-e24f0ab4afc0', 'Daša', 'Toplomjer je pokazao trideset osam i pol.', 'Термометр показав тридцять вісім з половиною.', 3);
  perform pg_temp.turn('79792cce-2c7a-5054-8d1f-e0e378f22668', 'a67c2941-5e04-5f17-bbab-e24f0ab4afc0', 'Pedijatar', 'Dajte mu čepić za temperaturu i neka pije puno vode.', 'Дайте йому свічку від температури, і хай п’є багато води.', 4);
  perform pg_temp.turn('4312e3b0-05c4-51bb-a1ea-18ac2dc892ef', 'a67c2941-5e04-5f17-bbab-e24f0ab4afc0', 'Daša', 'Plače i drži se za uho.', 'Він плаче й тримається за вухо.', 5);
  perform pg_temp.turn('1c461b57-fe22-50f0-922e-3ae22e982ffe', 'a67c2941-5e04-5f17-bbab-e24f0ab4afc0', 'Pedijatar', 'Pregledat ću ga, možda je upala uha.', 'Я його огляну, може, це запалення вуха.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('eb108604-1364-5a1e-8739-e9fca3db5d4e', v_lesson, 'Щеплення', 'Cijepljenje', 3742, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('741b0738-3a39-56f6-a387-20d3401be00b', 'eb108604-1364-5a1e-8739-e9fca3db5d4e', 'Darja', 'Dobar dan, došle smo na cijepljenje.', 'Добрий день, ми прийшли на щеплення.', 1);
  perform pg_temp.turn('1cd7d739-2222-5d8c-ae07-15646ff1dfa2', 'eb108604-1364-5a1e-8739-e9fca3db5d4e', 'Sestra', 'Koliko je beba stara?', 'Скільки маляті?', 2);
  perform pg_temp.turn('b4f33dda-4c6a-5140-a668-31a63cc5c7b8', 'eb108604-1364-5a1e-8739-e9fca3db5d4e', 'Darja', 'Šest mjeseci. Ima i mali osip na licu.', 'Шість місяців. У неї ще невеликий висип на обличчі.', 3);
  perform pg_temp.turn('ec8aceaa-2100-57b5-bd9c-342a5dc66b40', 'eb108604-1364-5a1e-8739-e9fca3db5d4e', 'Sestra', 'Doktorica će prvo pregledati dojenče.', 'Лікарка спершу огляне немовля.', 4);
  perform pg_temp.turn('a7a486ba-6dd8-5d4e-a1ff-08d15179e42a', 'eb108604-1364-5a1e-8739-e9fca3db5d4e', 'Darja', 'Je li u vrtiću opasno zbog vodenih kozica?', 'У садочку небезпечно через вітрянку?', 5);
  perform pg_temp.turn('8758f8ac-5b74-5994-938b-b57164970207', 'eb108604-1364-5a1e-8739-e9fca3db5d4e', 'Sestra', 'Za to postoji cjepivo, pitajte doktoricu.', 'Від неї є вакцина, запитайте лікарку.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 75: Здоровий спосіб життя — перебудова: 15 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '4bcf3852-7d28-5ceb-80ca-1870222d6834';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Здоровий спосіб життя» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '1464b1cd-c511-5ccc-9266-948042cf5e61') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'grammar', (select coalesce(jsonb_agg(lg.grammar_topic_id), '[]'::jsonb) from public.lesson_grammar lg where lg.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a1_v3: урок перебудовано за темою — стара версія (слова, вправи, діалоги, граматика)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 75: Здоровий спосіб життя', title_hr = 'Lekcija 75: Zdrav način života',
         objectives = '["Поговорити про звички: kretanje, san, pravilna prehrana", "Порадити, як жити здоровіше", "Порівняння: zdravije, više, manje, bolje"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Ступені порівняння' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Ступені порівняння»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zdrav život', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zdravlje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pravilna prehrana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vitamin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svježi zrak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kretanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vježbati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spavati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'težina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dijeta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mršaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'debljati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pušenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stres', v_pos);
  v_pos := pg_temp.word(v_lesson, 'navika', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '5120ffe9-83a3-51bd-8f5b-2e217d6c5d63', 'fill_in_the_blank', 'Sada jedem ___ povrća nego prije.', 'više', '["mnogo", "najviše", "puno", "više"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b763c456-90c7-520b-80d5-0a65888e06df', 'multiple_choice', 'Що означає «zdravlje»?', 'здоров''я', '["вага (тіла); складність", "дієта", "стрес", "здоров''я"]'::jsonb, 'A1', 2, 'PUBLISHED', 'zdravlje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '77be9deb-c85d-53bd-b1e0-4e4e0219cf92', 'multiple_choice', 'Що означає «kretanje»?', 'рух', '["звичка", "рух", "здоровий спосіб життя", "правильне харчування"]'::jsonb, 'A1', 3, 'PUBLISHED', 'kretanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '27f7e95f-48c8-5d5f-8be7-3fc2f51ed8e5', 'multiple_choice', 'Що означає «svježi zrak»?', 'свіже повітря', '["свіже повітря", "вітамін", "правильне харчування", "дієта"]'::jsonb, 'A1', 4, 'PUBLISHED', 'svježi zrak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'af8c51b0-4de7-5bfc-b3d1-c2916533fe0f', 'multiple_choice', 'Як хорватською «тренуватися; виконувати вправи»?', 'vježbati', '["pušenje", "težina", "vježbati", "mršaviti"]'::jsonb, 'A1', 5, 'PUBLISHED', 'vježbati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a3434db3-6829-5bd0-ae2b-7f36d0ddcabf', 'multiple_choice', 'Як хорватською «стрес»?', 'stres', '["stres", "zdravlje", "vježbati", "kretanje"]'::jsonb, 'A1', 6, 'PUBLISHED', 'stres', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a9f58a17-6806-5144-b281-e0a5a4df66b3', 'type_answer', 'Напишіть хорватською: «вітамін»', 'vitamin', null, 'A1', 7, 'PUBLISHED', 'vitamin', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4d23cd8a-584f-5afd-8be8-56a5cdc3f823', 'type_answer', 'Напишіть хорватською: «гладшати; набирати вагу»', 'debljati se', null, 'A1', 8, 'PUBLISHED', 'debljati se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9b47fe2b-4658-5ea6-9398-ce23c86b4798', 'type_answer', 'Напишіть хорватською: «звичка»', 'navika', null, 'A1', 9, 'PUBLISHED', 'navika', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '569c5db4-a66d-5bbe-97e9-257eb3bdfbf2', 'sentence_builder', 'Складіть: «Я більше ходжу пішки.»', 'Više hodam pješice.', '["hodam", "pješice.", "Više"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cdee29c5-aa80-561e-8756-4fd5dac8430d', 'sentence_builder', 'Складіть: «Рух — найкращі ліки.»', 'Kretanje je najbolji lijek.', '["je", "Kretanje", "lijek.", "najbolji"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '184d0436-5785-5f0e-8bf3-904c1e468f2d', 'listening', 'Прослухайте і складіть фразу', 'Što si promijenila?', '["si", "Što", "promijenila?"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bc6e76ab-c063-59e2-a4ba-fc2fd3325482', 'listening', 'Прослухайте і складіть фразу', 'Pušim, ali manje nego prije.', '["Pušim,", "prije.", "ali", "manje", "nego"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0ab928ed-78a0-5157-8caa-5d13ce3757c3', 'speaking', 'Я живу здоровіше.', 'Živim zdravije.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '08f8c585-d6d4-5ae0-9fec-3c1dc1638cec', 'speaking', 'Займайтеся спортом щодня.', 'Vježbajte svaki dan.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1464b1cd-c511-5ccc-9266-948042cf5e61', v_lesson, 'Нові звички', 'Nove navike', 3751, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('c261528a-f993-530e-903c-1fe28fb6092d', '1464b1cd-c511-5ccc-9266-948042cf5e61', 'Daša', 'Od ove godine živim zdravije.', 'З цього року я живу здоровіше.', 1);
  perform pg_temp.turn('a63e920f-f821-5be1-87b9-6140dd823fb6', '1464b1cd-c511-5ccc-9266-948042cf5e61', 'Ivana', 'Što si promijenila?', 'Що ти змінила?', 2);
  perform pg_temp.turn('4b38c72d-dac6-5a76-b0a0-0423c4f5b684', '1464b1cd-c511-5ccc-9266-948042cf5e61', 'Daša', 'Više hodam, manje sjedim i rano idem spavati.', 'Більше ходжу, менше сиджу й рано лягаю спати.', 3);
  perform pg_temp.turn('ca0ceb97-502a-577d-bcd8-4639962a2abf', '1464b1cd-c511-5ccc-9266-948042cf5e61', 'Ivana', 'A prehrana?', 'А харчування?', 4);
  perform pg_temp.turn('329e74a6-085d-5756-ac1f-80390e228df3', '1464b1cd-c511-5ccc-9266-948042cf5e61', 'Daša', 'Jedem više povrća, a manje slatkiša.', 'Їм більше овочів і менше солодкого.', 5);
  perform pg_temp.turn('80456bd5-5e01-5ffc-8e01-e527022a1662', '1464b1cd-c511-5ccc-9266-948042cf5e61', 'Ivana', 'Super! Kretanje i svježi zrak su najbolji lijek.', 'Чудово! Рух і свіже повітря — найкращі ліки.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('18ae28d1-c55c-596e-9f33-c2e98c1a32b1', v_lesson, 'Порада лікаря', 'Savjet liječnika', 3752, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('70d2ee00-d439-5712-a450-d5c65d0ebde2', '18ae28d1-c55c-596e-9f33-c2e98c1a32b1', 'Liječnik', 'Pušite li?', 'Ви курите?', 1);
  perform pg_temp.turn('3a762bc4-ee94-5be7-b09d-03633dbd730d', '18ae28d1-c55c-596e-9f33-c2e98c1a32b1', 'Marko', 'Pušim, ali manje nego prije.', 'Курю, але менше, ніж раніше.', 2);
  perform pg_temp.turn('810b5d8c-2e57-50b3-ae39-8d908242d692', '18ae28d1-c55c-596e-9f33-c2e98c1a32b1', 'Liječnik', 'Pušenje je najgora navika za zdravlje. Probajte prestati.', 'Куріння — найгірша звичка для здоров’я. Спробуйте кинути.', 3);
  perform pg_temp.turn('1481c793-8f9e-54ea-adb5-450cb0ff0230', '18ae28d1-c55c-596e-9f33-c2e98c1a32b1', 'Marko', 'Kad imam stres, teško mi je.', 'Коли в мене стрес, мені важко.', 4);
  perform pg_temp.turn('f74a6307-783c-5059-85d6-f354d3d95290', '18ae28d1-c55c-596e-9f33-c2e98c1a32b1', 'Liječnik', 'Vježbajte, to smanjuje stres.', 'Займайтеся спортом, це знижує стрес.', 5);
  perform pg_temp.turn('78bc77fe-bbc2-5331-8ab1-dbf467b9b73c', '18ae28d1-c55c-596e-9f33-c2e98c1a32b1', 'Marko', 'Trebam li uzimati vitamine?', 'Мені приймати вітаміни?', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- 3. Нові уроки модуля A1.8
-- A1.8 · урок 67: Внутрішні органи — новий урок: 14 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := '2eec2289-6a8a-5fb2-9988-e52433d5a242';
  v_lesson constant uuid := 'b6859b5e-db71-543a-8d05-db9b43811d8a';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.8: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 67: Внутрішні органи', 'Lekcija 67: Unutarnji organi', '["Назвати внутрішні органи: pluća, jetra, bubreg, želudac", "Сказати лікарю, де саме болить", "Місцевий: u želucu, u plućima, u zglobovima"]'::jsonb, 15, 'PUBLISHED', 2);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Місцевий відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Місцевий відмінок»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'pluća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jetra', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bubreg', v_pos);
  v_pos := pg_temp.word(v_lesson, 'želudac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crijeva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mozak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mišić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zglob', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kralježnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'štitnjača', v_pos);
  v_pos := pg_temp.word(v_lesson, 'probava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'živac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srce', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koža', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bd2a344e-bf59-531a-b9c0-0be58e4b284c', 'fill_in_the_blank', 'Imam problema sa ___.', 'želucem', '["želuca", "želudac", "želucem", "želucu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0d7adee2-dae0-50ef-807f-e84bc67cecfc', 'multiple_choice', 'Що означає «kralježnica»?', 'хребет', '["суглоб; зап’ястя", "серце", "хребет", "нерв"]'::jsonb, 'A1', 2, 'PUBLISHED', 'kralježnica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '08e28ce1-1441-5787-8952-ad4b1bb5fb13', 'multiple_choice', 'Що означає «živac»?', 'нерв', '["серце", "нирка", "нерв", "хребет"]'::jsonb, 'A1', 3, 'PUBLISHED', 'živac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9fe322c6-652b-51d7-8a00-dc199fcdb81f', 'multiple_choice', 'Що означає «mišić»?', 'м’яз', '["мозок", "шлунок", "хребет", "м’яз"]'::jsonb, 'A1', 4, 'PUBLISHED', 'mišić', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b88332fc-a907-586e-9e14-77c7bf45da0b', 'multiple_choice', 'Як хорватською «шлунок»?', 'želudac', '["mišić", "koža", "želudac", "mozak"]'::jsonb, 'A1', 5, 'PUBLISHED', 'želudac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '201dc8d1-1c1c-5ea7-8d2d-11bd5b2234a3', 'multiple_choice', 'Як хорватською «печінка»?', 'jetra', '["zglob", "jetra", "bubreg", "mozak"]'::jsonb, 'A1', 6, 'PUBLISHED', 'jetra', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'da338cb2-9062-5a11-ac4a-2ae1eb8d4c9b', 'type_answer', 'Напишіть хорватською: «нирка»', 'bubreg', null, 'A1', 7, 'PUBLISHED', 'bubreg', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b867a493-cf99-5ecb-8d37-326e56a0eb9b', 'type_answer', 'Напишіть хорватською: «кишківник»', 'crijeva', null, 'A1', 8, 'PUBLISHED', 'crijeva', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '90c634a7-86b9-5adb-bda3-5b775fa412ad', 'type_answer', 'Напишіть хорватською: «серце»', 'srce', null, 'A1', 9, 'PUBLISHED', 'srce', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd2292555-ff35-5271-87c1-2bb1641910b3', 'sentence_builder', 'Складіть: «У мене болять суглоби.»', 'Bole me zglobovi.', '["Bole", "zglobovi.", "me"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9b764c6e-2d25-52b4-9773-510874afc87c', 'sentence_builder', 'Складіть: «Біль у шлунку.»', 'Bol je u želucu.', '["Bol", "je", "želucu.", "u"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2bc9b163-e286-5774-9fa9-3f9c32631fbb', 'listening', 'Прослухайте і складіть фразу', 'Gdje točno osjećate bol?', '["bol?", "osjećate", "Gdje", "točno"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eec4905b-41ce-5cfe-9a84-68a26cfe3306', 'listening', 'Прослухайте і складіть фразу', 'Jesam. I kralježnica me boli.', '["Jesam.", "boli.", "me", "kralježnica", "I"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '80bc796b-e6e7-5b92-9110-62939342b7ec', 'speaking', 'Мені болить праворуч, під ребрами.', 'Boli me s desne strane, ispod rebara.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d499499-565a-5d1a-93fd-dbe7d7afc462', 'speaking', 'У мене проблеми з травленням.', 'Imam problema s probavom.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2086aeac-38c6-5df4-8ea1-79d6de2eab45', v_lesson, 'Де болить?', 'Gdje vas boli?', 3671, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('a1244d6b-2e66-584b-92f4-32b6d55486d7', '2086aeac-38c6-5df4-8ea1-79d6de2eab45', 'Liječnik', 'Gdje točno osjećate bol?', 'Де саме ви відчуваєте біль?', 1);
  perform pg_temp.turn('f680c076-75a8-5256-9b60-b8a7566fbc56', '2086aeac-38c6-5df4-8ea1-79d6de2eab45', 'Daša', 'Ovdje s desne strane, ispod rebara.', 'Ось тут, праворуч, під ребрами.', 2);
  perform pg_temp.turn('83b6cb74-c1aa-5c41-8ba3-f2d0abe0c5a9', '2086aeac-38c6-5df4-8ea1-79d6de2eab45', 'Liječnik', 'To može biti jetra ili žučni mjehur.', 'Це може бути печінка або жовчний міхур.', 3);
  perform pg_temp.turn('ac014994-964d-55cd-94d9-802734ad49af', '2086aeac-38c6-5df4-8ea1-79d6de2eab45', 'Daša', 'A može li biti bubreg?', 'А може бути нирка?', 4);
  perform pg_temp.turn('b3055f43-1ba6-5926-9cfc-cefa3bca51ff', '2086aeac-38c6-5df4-8ea1-79d6de2eab45', 'Liječnik', 'Bubreg je straga. Napravit ćemo ultrazvuk.', 'Нирка ззаду. Зробимо УЗД.', 5);
  perform pg_temp.turn('71d9081a-ace3-5619-a711-9ffa52e84471', '2086aeac-38c6-5df4-8ea1-79d6de2eab45', 'Daša', 'Imam i problema s probavom.', 'У мене ще й проблеми з травленням.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('fe918e0d-21ff-5dc9-b37a-fbf2af2bfccd', v_lesson, 'Після тренування', 'Poslije treninga', 3672, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('b6922629-d132-539c-9308-6f1c083991b9', 'fe918e0d-21ff-5dc9-b37a-fbf2af2bfccd', 'Marko', 'Darja, sve me boli, i mišići i zglobovi!', 'Даріє, у мене все болить — і м’язи, і суглоби!', 1);
  perform pg_temp.turn('c1b318c8-0a93-52b1-9056-da06c50616d1', 'fe918e0d-21ff-5dc9-b37a-fbf2af2bfccd', 'Darja', 'Prvi put si bio u teretani?', 'Ти вперше був у спортзалі?', 2);
  perform pg_temp.turn('f00764f2-7a94-5ae0-a61c-28c380d68dd8', 'fe918e0d-21ff-5dc9-b37a-fbf2af2bfccd', 'Marko', 'Jesam. I kralježnica me boli.', 'Так. І хребет болить.', 3);
  perform pg_temp.turn('4929c698-f4e1-5812-9bd5-acb0f453a23c', 'fe918e0d-21ff-5dc9-b37a-fbf2af2bfccd', 'Darja', 'Pazi na leđa. A diši duboko, to je dobro za pluća i srce.', 'Бережи спину. І дихай глибоко, це добре для легенів і серця.', 4);
  perform pg_temp.turn('d3edefdc-c000-5e73-a6ba-8b9d063bcbe6', 'fe918e0d-21ff-5dc9-b37a-fbf2af2bfccd', 'Marko', 'Moja mama kaže da je sport dobar i za mozak.', 'Моя мама каже, що спорт корисний і для мозку.', 5);
  perform pg_temp.turn('9f587343-b862-5527-9595-70598023e511', 'fe918e0d-21ff-5dc9-b37a-fbf2af2bfccd', 'Darja', 'Istina, i za kožu, i za živce!', 'Правда, і для шкіри, і для нервів!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A1 v3 (слова за темою, 2 діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- Наскрізні номери всіх уроків A1 («Урок N: …» / «Lekcija N: …»); стара назва — у content_versions
do $$
declare r record; v_payload jsonb; v_new_ua text; v_new_hr text;
begin
  for r in select l.id, l.title_ua, l.title_hr,
                  row_number() over (order by m.order_index, u.order_index, l.order_index) as n
             from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
            where m.level_code = 'A1' and l.status = 'PUBLISHED' loop
    v_new_ua := regexp_replace(r.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':');
    v_new_hr := regexp_replace(r.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':');
    if v_new_ua is not distinct from r.title_ua and v_new_hr is not distinct from r.title_hr then continue; end if;
    select to_jsonb(l) into v_payload from public.lessons l where l.id = r.id;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'curriculum_a1_v3: новий номер уроку ' || r.n);
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;

-- 5. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_order int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('08e31e8b-f8f7-5a80-89ed-093bc68dae03', 'b6859b5e-db71-543a-8d05-db9b43811d8a', '878c0712-e4e5-5a7d-aab5-510c781da0c7', '431b51ad-baa3-5387-94ac-a7273fdb9263', '123e68fa-291f-5ad6-8403-51db7020d641', '247c3445-6ba3-50f0-a441-9073d6734451', '293af384-4ee2-5746-80a8-e8ffdc7009bc', 'd5dee6c5-f510-57b9-a1ed-4b0a60e8e09a', '0df023bb-17fb-5006-91bf-3b911dd30295', '4bcf3852-7d28-5ceb-80ca-1870222d6834')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 10 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_order from (values ('08e31e8b-f8f7-5a80-89ed-093bc68dae03'::uuid, 1), ('b6859b5e-db71-543a-8d05-db9b43811d8a'::uuid, 2), ('878c0712-e4e5-5a7d-aab5-510c781da0c7'::uuid, 3), ('431b51ad-baa3-5387-94ac-a7273fdb9263'::uuid, 4), ('123e68fa-291f-5ad6-8403-51db7020d641'::uuid, 5), ('247c3445-6ba3-50f0-a441-9073d6734451'::uuid, 6), ('293af384-4ee2-5746-80a8-e8ffdc7009bc'::uuid, 7), ('d5dee6c5-f510-57b9-a1ed-4b0a60e8e09a'::uuid, 8), ('0df023bb-17fb-5006-91bf-3b911dd30295'::uuid, 9), ('4bcf3852-7d28-5ceb-80ca-1870222d6834'::uuid, 10)) as t(id, o)
    join public.lessons l on l.id = t.id and l.order_index = t.o and l.unit_id = '2eec2289-6a8a-5fb2-9988-e52433d5a242';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A1' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('08e31e8b-f8f7-5a80-89ed-093bc68dae03', 'b6859b5e-db71-543a-8d05-db9b43811d8a', '878c0712-e4e5-5a7d-aab5-510c781da0c7', '431b51ad-baa3-5387-94ac-a7273fdb9263', '123e68fa-291f-5ad6-8403-51db7020d641', '247c3445-6ba3-50f0-a441-9073d6734451', '293af384-4ee2-5746-80a8-e8ffdc7009bc', 'd5dee6c5-f510-57b9-a1ed-4b0a60e8e09a', '0df023bb-17fb-5006-91bf-3b911dd30295', '4bcf3852-7d28-5ceb-80ca-1870222d6834') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A1.8: % уроків з неправильним складом', v_bad; end if;
  if v_order <> 10 then raise exception 'Модуль A1.8: на своїх місцях % уроків з 10', v_order; end if;
  if v_titles > 0 then raise exception 'A1: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A1.8: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A1.8 — 10 уроків за темою (9 перебудовано, 1 нових)';
end $$;

commit;
