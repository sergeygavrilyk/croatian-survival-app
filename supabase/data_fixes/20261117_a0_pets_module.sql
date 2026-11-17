-- =====================================================================
-- Модуль A0.6 «Kućni ljubimci» (домашні тварини) · 2026-11-17
-- Згенеровано: python3 -B scripts/gen_a0_pets_module.py (не редагуйте вручну).
--
-- Рішення власника 2026-11-17: новий модуль A0.6 одразу після A0.5; урок 37 «Домашні тварини» — першим у ньому;
-- 6 нових уроків (38–43): «Собака в місті», «Кішки», «У ветеринара», «Тварини на фермі», «Подорож з улюбленцем»,
-- «Притулок і загублена тварина». Модулі A0.6–A0.10 → A0.7–A0.11; уроків A0 66 → 72.
--   * Нові слова: 100 (з мітками). Нових уроків: 6, слів у них: 123. Нова тема граматики: 1.
--   * Нічого не видаляється: старий діалог і вправа уроку 37 → DEPRECATED; копії — backup.modules_a0_20261117,
--     backup.reading_texts_a0_20261117, backup.lesson_items_a0pets_20261117; старі версії уроків — у content_versions.
--   * Перевірки модулів — окремим пакетом 20261117_a0_pets_assessments.sql (запускати після цього).
--   * Повторний запуск нічого не змінює. Бета: PUBLISHED.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: 20261117_a0_pets_module.sql — модуль A0.6 …».
-- =====================================================================

begin;

-- 0. Копії до змін (схема backup без доступу для anon / authenticated)
create schema if not exists backup;
create table if not exists backup.modules_a0_20261117 (like public.modules including defaults);
create table if not exists backup.reading_texts_a0_20261117 (id uuid primary key, code text, module_order smallint);
create table if not exists backup.lesson_items_a0pets_20261117 (like public.lesson_items including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'modules_a0_20261117_pkey') then
    alter table backup.modules_a0_20261117 add constraint modules_a0_20261117_pkey primary key (id);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'lesson_items_a0pets_20261117_pkey') then
    alter table backup.lesson_items_a0pets_20261117 add constraint lesson_items_a0pets_20261117_pkey primary key (id);
  end if;
end $$;
revoke all on backup.modules_a0_20261117, backup.reading_texts_a0_20261117, backup.lesson_items_a0pets_20261117 from anon, authenticated;

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

-- 1. Новий модуль A0.6: модулі A0.6–A0.10 → A0.7–A0.11, урок 37 — у новий модуль, тексти для читання — за модулем
do $$
declare
  v_module constant uuid := 'fd6730dd-07aa-590d-b7db-c639e3ed3919';
  v_unit constant uuid := 'aaf6ad60-560f-5720-9a19-24398989dd00';
  v_l37 constant uuid := '40b9da1d-1686-5b78-8317-0439067d5f8e';
begin
  if exists (select 1 from public.modules where id = v_module) then return; end if;  -- уже зроблено
  if (select count(*) from public.modules where level_code = 'A0') <> 10 then
    raise exception 'Очікувалось 10 модулів A0 — звірте базу';
  end if;
  if (select m.order_index from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
       where l.id = v_l37) is distinct from 5 then
    raise exception 'Урок 37 «Домашні тварини» не в модулі A0.5 — звірте базу';
  end if;
  insert into backup.modules_a0_20261117 select * from public.modules where level_code = 'A0' on conflict (id) do nothing;
  insert into backup.reading_texts_a0_20261117 select id, code, module_order from public.reading_texts where cefr = 'A0'
  on conflict (id) do nothing;
  -- місця 6–10 → 7–11 через 100+ (unique (level_code, order_index)); номер у назві — за новим місцем
  update public.modules set order_index = order_index + 100 where level_code = 'A0' and order_index >= 6;
  update public.modules
     set order_index = order_index - 99,
         title_ua = regexp_replace(title_ua, '^Модуль A0\.[0-9]+', 'Модуль A0.' || (order_index - 99)),
         title_hr = regexp_replace(title_hr, '^Modul A0\.[0-9]+', 'Modul A0.' || (order_index - 99))
   where level_code = 'A0' and order_index > 100;
  insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
  values (v_module, 'A0', 'Модуль A0.6 — Kućni ljubimci (домашні тварини)', 'Modul A0.6 — Kućni ljubimci', 'Собака й кішка в місті, ветеринар, ферма, подорож з улюбленцем, притулок і загублена тварина.', 6, 'PUBLISHED');
  insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
  values (v_unit, v_module, 'Домашні тварини', 'Kućni ljubimci', '["Розповісти про свою тварину", "Порозумітися з ветеринаром", "Подорожувати з улюбленцем і знайти загублену тварину"]'::jsonb, 1, 'PUBLISHED');
  -- урок 37 — першим у новий модуль (стара версія — у content_versions)
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'lesson', l.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = l.id), 0) + 1,
         to_jsonb(l), 'a0_pets: урок перенесено з модуля A0.5 у новий модуль A0.6 — стара версія'
    from public.lessons l where l.id = v_l37;
  update public.lessons set unit_id = v_unit, order_index = 1 where id = v_l37;
  -- тексти для читання A0 — за своїм модулем
  update public.reading_texts set module_order = module_order + 1 where cefr = 'A0' and module_order >= 6;
end $$;

-- 2. Нова тема граматики A0 (1)
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '7e3330d6-e522-5292-aaa6-4f25cd6c7480', 'A0', 'Можна чи не можна? Smjeti і команди', 'Smije li? Glagol smjeti i naredbe', 'Дієслово smjeti («можна, мати дозвіл»): smijem, smiješ, smije… + інфінітив; заборона — ne smije. Команди собаці — наказовий спосіб: Sjedi! Lezi! Dođi!', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Можна чи не можна? Smjeti і команди');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'b20563db-8893-5e38-90e4-646056fb0d3c', '7e3330d6-e522-5292-aaa6-4f25cd6c7480', 'Smjeti — «можна, мати дозвіл»', 'Smjeti кажуть про дозвіл: чи можна щось робити за правилами. Після нього — інфінітив: smijem ući — мені можна увійти. Питання ставимо так: Smije li…? Smijem li…? Відповідь: Smije. / Ne smije. Форми: smijem, smiješ, smije.', 'smijem, smiješ, smije, smijemo, smijete, smiju + інфінітив', '[{"hr": "Smije li pas ući?", "ua": "Чи можна собаці увійти?"}, {"hr": "Ovdje smijemo pustiti psa.", "ua": "Тут нам можна відпустити собаку."}, {"hr": "Smijem li sjesti ovdje?", "ua": "Можна мені сісти тут?"}, {"hr": "Smijemo li parkirati ovdje?", "ua": "Нам можна тут паркуватися?"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '7e3330d6-e522-5292-aaa6-4f25cd6c7480')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '6b75bda1-3d78-5e5a-84dd-df89749380bf', '7e3330d6-e522-5292-aaa6-4f25cd6c7480', 'Заборона: ne smije', 'Заперечення ne пишемо окремо: ne smijem, ne smiješ, ne smije, ne smiju. Так звучать заборони на табличках і в правилах: Psi ne smiju ući. Не плутайте з ne mogu — «не можу» (немає змоги), а ne smijem — «мені не можна».', 'ne + smjeti + інфінітив', '[{"hr": "Psi ne smiju ući u trgovinu.", "ua": "Собакам не можна заходити в магазин."}, {"hr": "Ne smiješ hraniti psa čokoladom.", "ua": "Не можна годувати собаку шоколадом."}, {"hr": "Ovdje ne smijete pušiti.", "ua": "Тут вам не можна курити."}, {"hr": "Pas ne smije na kauč.", "ua": "Собаці не можна на диван."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '7e3330d6-e522-5292-aaa6-4f25cd6c7480')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '77cb762d-1ebf-5d7c-b3b0-1d11aa1ad561', '7e3330d6-e522-5292-aaa6-4f25cd6c7480', 'Команди: Sjedi! Lezi! Dođi!', 'Команда собаці (і будь-яке коротке прохання до «ти») — наказовий спосіб однини. Його треба запам’ятати разом із дієсловом: sjediti → sjedi, leći → lezi, doći → dođi, dati → daj, čekati → čekaj. До «ви» додаємо -te: Sjedite!', 'Sjedi! · Lezi! · Dođi! · Daj šapu! · Čekaj!', '[{"hr": "Bruno, sjedi!", "ua": "Бруно, сидіти!"}, {"hr": "Lola, dođi ovamo!", "ua": "Лоло, до мене!"}, {"hr": "Lezi i čekaj!", "ua": "Лежати й чекати!"}, {"hr": "Daj šapu, Medo!", "ua": "Дай лапу, Медо!"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '7e3330d6-e522-5292-aaa6-4f25cd6c7480')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '7e3330d6-e522-5292-aaa6-4f25cd6c7480', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нова тема граматики A0 для уроку «Собака в місті» (модуль A0.6, рішення власника 2026-11-17). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '7e3330d6-e522-5292-aaa6-4f25cd6c7480')
  and not exists (select 1 from public.content_reviews where entity_id = '7e3330d6-e522-5292-aaa6-4f25cd6c7480' and notes = 'Бета: нова тема граматики A0 для уроку «Собака в місті» (модуль A0.6, рішення власника 2026-11-17). Потрібна перевірка носієм.');

-- 3. Нові слова модуля (100): PUBLISHED (бета), з мітками; наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples,
                            register, regionality, usage_tags, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A0', t.ua, t.vtype, t.forms, t.examples,
       t.register, t.regionality, array(select jsonb_array_elements_text(t.usage_tags)), 'PUBLISHED', 'claude_curriculum_a0_pets'
  from jsonb_to_recordset('[{"lemma": "brnjica", "normalized": "brnjica", "pos": "noun", "ua": "намордник", "vtype": "core", "forms": {"gender": "f"}, "examples": ["U autobusu pas mora nositi brnjicu."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "park za pse", "normalized": "park za pse", "pos": "phrase", "ua": "парк для собак", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Navečer vodim psa u park za pse."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "počistiti", "normalized": "pocistiti", "pos": "verb", "ua": "прибрати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "čistiti"}, "examples": ["Molimo, počistite za svojim psom."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "loptica", "normalized": "loptica", "pos": "noun", "ua": "м’ячик", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Daša baca psu lopticu u parku."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "pasmina", "normalized": "pasmina", "pos": "noun", "ua": "порода", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Koje je pasmine tvoj pas?"], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "mješanac", "normalized": "mjesanac", "pos": "noun", "ua": "метис; безпородний собака", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Naš pas nije čiste pasmine, on je mješanac."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "njušiti", "normalized": "njusiti", "pos": "verb", "ua": "нюхати", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "onjušiti"}, "examples": ["Pas njuši svako drvo u parku."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "mahati", "normalized": "mahati", "pos": "verb", "ua": "махати", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "mahnuti"}, "examples": ["Kad me vidi, pas veselo maše repom."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "gristi", "normalized": "gristi", "pos": "verb", "ua": "кусатися; гризти", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "ugristi"}, "examples": ["Ne bojte se, moj pas ne grize."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "pseći", "normalized": "pseci", "pos": "adjective", "ua": "собачий", "vtype": "core", "forms": {}, "examples": ["U dućanu kupujem pseću hranu."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "pas vodič", "normalized": "pas vodic", "pos": "phrase", "ua": "собака-поводир", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Pas vodič smije ući u svaku trgovinu."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "zabranjen", "normalized": "zabranjen", "pos": "adjective", "ua": "заборонений", "vtype": "core", "forms": {}, "examples": ["Ulaz psima je zabranjen."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "dozvoljen", "normalized": "dozvoljen", "pos": "adjective", "ua": "дозволений", "vtype": "core", "forms": {}, "examples": ["Na terasi kafića psi su dozvoljeni."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "daj šapu", "normalized": "daj sapu", "pos": "phrase", "ua": "дай лапу", "vtype": "formulaic", "forms": {}, "examples": ["Lola, sjedi i daj šapu!"], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "naredba", "normalized": "naredba", "pos": "noun", "ua": "команда; наказ", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Moj pas zna pet naredbi."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "povesti", "normalized": "povesti", "pos": "verb", "ua": "взяти з собою (кого-небудь)", "vtype": "core", "forms": {"aspect": "pfv"}, "examples": ["Mogu li povesti psa u restoran?"], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "trgovina za kućne ljubimce", "normalized": "trgovina za kucne ljubimce", "pos": "phrase", "ua": "зоомагазин", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Lopticu sam kupila u trgovini za kućne ljubimce."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "zavezati", "normalized": "zavezati", "pos": "verb", "ua": "прив’язати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "vezati"}, "examples": ["Zavežite psa ispred trgovine, molim."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "mačak", "normalized": "macak", "pos": "noun", "ua": "кіт", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Naš mačak cijeli dan spava na suncu."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "maca", "normalized": "maca", "pos": "noun", "ua": "киця", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Maca čeka večeru ispred vrata."], "register": "informal", "regionality": "general", "usage_tags": []}, {"lemma": "mic mic", "normalized": "mic mic", "pos": "interjection", "ua": "кис-кис", "vtype": "formulaic", "forms": {}, "examples": ["Mic mic, dođi ovamo!"], "register": "informal", "regionality": "general", "usage_tags": []}, {"lemma": "presti", "normalized": "presti", "pos": "verb", "ua": "муркотіти", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Mačka prede kad je sretna."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "mijaukati", "normalized": "mijaukati", "pos": "verb", "ua": "нявкати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Mačak glasno mijauče kad je gladan."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "kandža", "normalized": "kandza", "pos": "noun", "ua": "кіготь (у кішки)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Mačka ima oštre kandže."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "krzno", "normalized": "krzno", "pos": "noun", "ua": "хутро", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Ova maca ima mekano bijelo krzno."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "loviti", "normalized": "loviti", "pos": "verb", "ua": "ловити; полювати", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "uloviti"}, "examples": ["Mačke vole loviti ptice."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "grebalica", "normalized": "grebalica", "pos": "noun", "ua": "дряпка (кігтеточка)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Kupili smo mački novu grebalicu."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "ogrebati", "normalized": "ogrebati", "pos": "verb", "ua": "подряпати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "grebati"}, "examples": ["Mače me ogrebalo po ruci."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "lizati", "normalized": "lizati", "pos": "verb", "ua": "лизати", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "polizati"}, "examples": ["Mačka liže svoje krzno."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "umiljat", "normalized": "umiljat", "pos": "adjective", "ua": "лагідний; ласкавий", "vtype": "core", "forms": {}, "examples": ["Moja mačka je jako umiljata."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "prugast", "normalized": "prugast", "pos": "adjective", "ua": "смугастий", "vtype": "core", "forms": {}, "examples": ["Tražim sivog prugastog mačka."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "zaštitna mreža", "normalized": "zastitna mreza", "pos": "phrase", "ua": "захисна сітка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na balkonu imamo zaštitnu mrežu za mačku."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "mačji", "normalized": "macji", "pos": "adjective", "ua": "котячий", "vtype": "core", "forms": {}, "examples": ["Molim te, kupi mačju hranu."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "klupko", "normalized": "klupko", "pos": "noun", "ua": "клубок", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Mače se igra s klupkom vune."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "sklupčati se", "normalized": "sklupcati se", "pos": "verb", "ua": "згорнутися клубочком", "vtype": "core", "forms": {"aspect": "pfv", "pair": "sklupčavati se"}, "examples": ["Mačka se sklupčala na kauču."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "veterinarska ambulanta", "normalized": "veterinarska ambulanta", "pos": "phrase", "ua": "ветеринарна клініка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Veterinarska ambulanta radi i subotom."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "čip", "normalized": "cip", "pos": "noun", "ua": "мікрочип", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Svaki pas u Hrvatskoj mora imati čip."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "krpelj", "normalized": "krpelj", "pos": "noun", "ua": "кліщ", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Nakon šetnje sam našla krpelja na psu."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "parazit", "normalized": "parazit", "pos": "noun", "ua": "паразит", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ove tablete štite psa od parazita."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "kastrirati", "normalized": "kastrirati", "pos": "verb", "ua": "каструвати", "vtype": "core", "forms": {"aspect": "biasp"}, "examples": ["Našeg mačka ćemo kastrirati na proljeće."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "sterilizirati", "normalized": "sterilizirati", "pos": "verb", "ua": "стерилізувати", "vtype": "core", "forms": {"aspect": "biasp"}, "examples": ["Našu mačku smo sterilizirali prošle godine."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "vaga", "normalized": "vaga", "pos": "noun", "ua": "ваги", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Stavite psa na vagu, molim."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "otrov", "normalized": "otrov", "pos": "noun", "ua": "отрута", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Neke biljke su otrov za mačke."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "apetit", "normalized": "apetit", "pos": "noun", "ua": "апетит", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Mačak nema apetita već dva dana."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "što mu je", "normalized": "sto mu je", "pos": "phrase", "ua": "що з ним?", "vtype": "formulaic", "forms": {}, "examples": ["Što mu je? Cijeli dan samo leži."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "šepati", "normalized": "sepati", "pos": "verb", "ua": "кульгати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Pas šepa na lijevu nogu."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "zaštitni ovratnik", "normalized": "zastitni ovratnik", "pos": "phrase", "ua": "захисний комір", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Nakon operacije pas mora nositi zaštitni ovratnik."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "dežurni veterinar", "normalized": "dezurni veterinar", "pos": "phrase", "ua": "черговий ветеринар", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Noću zovemo dežurnog veterinara."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "cijepljen", "normalized": "cijepljen", "pos": "adjective", "ua": "щеплений", "vtype": "core", "forms": {}, "examples": ["Je li vaš pas cijepljen?"], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "podrezati", "normalized": "podrezati", "pos": "verb", "ua": "підрізати; підстригти", "vtype": "core", "forms": {"aspect": "pfv", "pair": "podrezivati"}, "examples": ["Veterinar će psu podrezati nokte."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "nokat", "normalized": "nokat", "pos": "noun", "ua": "ніготь; кіготь (у собаки)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Psu je nokat predug."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "mirno", "normalized": "mirno", "pos": "adverb", "ua": "спокійно", "vtype": "core", "forms": {}, "examples": ["Držite psa mirno, molim vas."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "farma", "normalized": "farma", "pos": "noun", "ua": "ферма", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Baka ima malu farmu blizu Osijeka."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "tele", "normalized": "tele", "pos": "noun", "ua": "теля", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Tele spava pokraj mame u štali."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "magarac", "normalized": "magarac", "pos": "noun", "ua": "віслюк", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Na otoku smo vidjeli magarca."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "janje", "normalized": "janje", "pos": "noun", "ua": "ягня", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Malo janje trči za ovcom."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "pijetao", "normalized": "pijetao", "pos": "noun", "ua": "півень", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Pijetao nas budi svako jutro."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "guska", "normalized": "guska", "pos": "noun", "ua": "гуска", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Guske plivaju u jezeru."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "štala", "normalized": "stala", "pos": "noun", "ua": "стайня; хлів", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Krave su navečer u štali."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "sijeno", "normalized": "sijeno", "pos": "noun", "ua": "сіно", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Konji jedu sijeno."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "trava", "normalized": "trava", "pos": "noun", "ua": "трава", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ovce jedu travu na livadi."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "musti", "normalized": "musti", "pos": "verb", "ua": "доїти", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "pomusti"}, "examples": ["Baka ujutro muze kravu."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "jahati", "normalized": "jahati", "pos": "verb", "ua": "їздити верхи", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Darja voli jahati konja."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "mukati", "normalized": "mukati", "pos": "verb", "ua": "мукати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Krava muče u štali."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "putovnica za kućne ljubimce", "normalized": "putovnica za kucne ljubimce", "pos": "phrase", "ua": "паспорт домашньої тварини", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Za put u Italiju pas treba putovnicu za kućne ljubimce."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "bjesnoća", "normalized": "bjesnoca", "pos": "noun", "ua": "сказ", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Pas mora biti cijepljen protiv bjesnoće."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "veterinarska potvrda", "normalized": "veterinarska potvrda", "pos": "phrase", "ua": "ветеринарна довідка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Na granici su tražili veterinarsku potvrdu."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "transporter", "normalized": "transporter", "pos": "noun", "ua": "переноска (для тварини)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Mačka putuje u transporteru."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "plaža za pse", "normalized": "plaza za pse", "pos": "phrase", "ua": "пляж для собак", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Blizu apartmana je plaža za pse."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "doplata", "normalized": "doplata", "pos": "noun", "ua": "доплата", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Za psa je doplata deset eura po noći."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "pansion za pse", "normalized": "pansion za pse", "pos": "phrase", "ua": "готель для собак", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Dok smo na moru, pas je u pansionu za pse."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "sigurnosni pojas", "normalized": "sigurnosni pojas", "pos": "phrase", "ua": "ремінь безпеки", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["U autu pas nosi poseban sigurnosni pojas."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "aviokompanija", "normalized": "aviokompanija", "pos": "noun", "ua": "авіакомпанія", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ova aviokompanija prevozi male pse u kabini."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "sredstvo za smirenje", "normalized": "sredstvo za smirenje", "pos": "phrase", "ua": "заспокійливий засіб", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Veterinar nam je dao sredstvo za smirenje za put."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "ograničenje", "normalized": "ogranicenje", "pos": "noun", "ua": "обмеження", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Postoji ograničenje: pas može imati najviše osam kilograma."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "čipiran", "normalized": "cipiran", "pos": "adjective", "ua": "чипований", "vtype": "core", "forms": {}, "examples": ["Je li vaš pas čipiran?"], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "zrakoplov", "normalized": "zrakoplov", "pos": "noun", "ua": "літак", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Mačka je prvi put letjela zrakoplovom."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "Europska unija", "normalized": "europska unija", "pos": "phrase", "ua": "Європейський Союз", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Pas putuje po Europskoj uniji s putovnicom."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "najmanje", "normalized": "najmanje", "pos": "adverb", "ua": "щонайменше", "vtype": "core", "forms": {}, "examples": ["Cijepljenje mora biti najmanje tri tjedna prije puta."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "noćiti", "normalized": "nociti", "pos": "verb", "ua": "ночувати", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "prenoćiti"}, "examples": ["Na putu ćemo noćiti u hotelu koji prima pse."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "granična policija", "normalized": "granicna policija", "pos": "phrase", "ua": "прикордонна поліція", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Granična policija je provjerila psa i dokumente."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "dobrodošao", "normalized": "dobrodosao", "pos": "adjective", "ua": "бажаний (гість); ласкаво просимо", "vtype": "core", "forms": {}, "examples": ["U našem hotelu kućni ljubimci su dobrodošli."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "pojilica", "normalized": "pojilica", "pos": "noun", "ua": "поїлка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Na put uvijek nosim pojilicu za psa."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "sklonište za životinje", "normalized": "skloniste za zivotinje", "pos": "phrase", "ua": "притулок для тварин", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["U skloništu za životinje čeka pedeset pasa."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "udomiti", "normalized": "udomiti", "pos": "verb", "ua": "взяти тварину з притулку; прихистити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "udomljavati"}, "examples": ["Prošle godine smo udomili mačku."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "udomljavanje", "normalized": "udomljavanje", "pos": "noun", "ua": "прилаштування тварини (з притулку)", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Udomljavanje u skloništu je besplatno."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "napušten", "normalized": "napusten", "pos": "adjective", "ua": "покинутий", "vtype": "core", "forms": {}, "examples": ["Našli smo napuštenog psa pokraj ceste."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "lutalica", "normalized": "lutalica", "pos": "noun", "ua": "безпритульна тварина", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ova mačka je prije bila lutalica."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "izgubljen", "normalized": "izgubljen", "pos": "adjective", "ua": "загублений", "vtype": "core", "forms": {}, "examples": ["Na stupu je oglas za izgubljenog psa."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "novi dom", "normalized": "novi dom", "pos": "phrase", "ua": "новий дім", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ovaj mačić traži novi dom."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "zbrinuti", "normalized": "zbrinuti", "pos": "verb", "ua": "прилаштувати; подбати (про кого)", "vtype": "core", "forms": {"aspect": "pfv", "pair": "zbrinjavati"}, "examples": ["Volonteri su zbrinuli sve mačiće."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "udomitelj", "normalized": "udomitelj", "pos": "noun", "ua": "новий господар (тварини з притулку)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Sklonište traži dobrog udomitelja za Belu."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "boks", "normalized": "boks", "pos": "noun", "ua": "вольєр", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Svaki pas u skloništu ima svoj boks."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "privremeni smještaj", "normalized": "privremeni smjestaj", "pos": "phrase", "ua": "тимчасова перетримка", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Štene je kod nas na privremenom smještaju."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "pronađen", "normalized": "pronaden", "pos": "adjective", "ua": "знайдений", "vtype": "core", "forms": {}, "examples": ["Pronađen pas! Vlasnik se može javiti skloništu."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "dobrovoljac", "normalized": "dobrovoljac", "pos": "noun", "ua": "доброволець", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Luka je dobrovoljac u skloništu."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "nahraniti", "normalized": "nahraniti", "pos": "verb", "ua": "нагодувати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "hraniti"}, "examples": ["Možeš li nahraniti mačku večeras?"], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "zalutati", "normalized": "zalutati", "pos": "verb", "ua": "заблукати", "vtype": "core", "forms": {"aspect": "pfv"}, "examples": ["Mače je zalutalo u naš vrt."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "ženka", "normalized": "zenka", "pos": "noun", "ua": "самка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ova mačka je ženka, ima dvije godine."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "mužjak", "normalized": "muzjak", "pos": "noun", "ua": "самець", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Je li tvoj hrčak mužjak ili ženka?"], "register": "standard", "regionality": "general", "usage_tags": []}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb, register text, regionality text, usage_tags jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 3а. Наявні слова, які вперше вчать в уроках модуля A0.6 (23): рівень слова — A0 (cefr = рівень першого уроку);
--     стара версія — у content_versions
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) in ('pustiti', 'oprez', 'opasan', 'bojati se', 'skočiti', 'pobjeći', 'sakriti se', 'operacija', 'čokolada', 'protiv', 'krava', 'konj', 'ovca', 'koza', 'svinja', 'kokoš', 'patka', 'seljak', 'livada', 'dopustiti', 'plašljiv', 'šansa', 'prepoznati') and status = 'PUBLISHED' and cefr is distinct from 'A0' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'a0_pets: рівень слова A0 — його вперше вчать в уроці модуля A0.6 — стара версія');
    update public.lexemes set cefr = 'A0', version = version + 1 where id = r.id;
  end loop;
end $$;

-- 4. Нові уроки модуля A0.6
-- A0.6 · урок 38: Собака в місті — 22 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'aaf6ad60-560f-5720-9a19-24398989dd00';
  v_lesson constant uuid := '64ad8ee5-741e-54e5-b31d-88f1130e3f3e';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A0.6: місце 2 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Можна чи не можна? Smjeti і команди' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Можна чи не можна? Smjeti і команди»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 38: Собака в місті', 'Lekcija 38: Pas u gradu', '["Зрозуміти таблички про собак у місті", "Запитати, чи можна із собакою", "Дати собаці прості команди"]'::jsonb, 15, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'brnjica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'park za pse', v_pos);
  v_pos := pg_temp.word(v_lesson, 'počistiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'loptica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pasmina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mješanac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'njušiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mahati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gristi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pseći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pas vodič', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zabranjen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dozvoljen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'daj šapu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naredba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povesti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trgovina za kućne ljubimce', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zavezati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pustiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oprez', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opasan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bojati se', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '5463a8aa-736b-55bb-a13f-a89b0e07141a', 'fill_in_the_blank', 'Psi ne ___ ući u trgovinu.', 'smiju', '["smiju", "smijem", "smije", "smijemo"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ab9813e4-9683-58b0-9406-6c9505a193b5', 'multiple_choice', 'Що означає «trgovina za kućne ljubimce»?', 'зоомагазин', '["собака-поводир", "зоомагазин", "відпустити", "команда; наказ"]'::jsonb, 'A0', 2, 'PUBLISHED', 'trgovina za kućne ljubimce', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ca302ee5-45b6-53ea-878d-28d420d6b1d8', 'multiple_choice', 'Що означає «zavezati»?', 'прив’язати', '["метис; безпородний собака", "прив’язати", "прибрати", "дай лапу"]'::jsonb, 'A0', 3, 'PUBLISHED', 'zavezati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f31034dd-6aec-5aa1-b8c0-4b664c4366b7', 'multiple_choice', 'Що означає «loptica»?', 'м’ячик', '["м’ячик", "команда; наказ", "дозволений", "взяти з собою (кого-небудь)"]'::jsonb, 'A0', 4, 'PUBLISHED', 'loptica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '26110edc-c1e4-5c90-89b4-46893cd81dbf', 'multiple_choice', 'Як хорватською «намордник»?', 'brnjica', '["bojati se", "brnjica", "zabranjen", "povesti"]'::jsonb, 'A0', 5, 'PUBLISHED', 'brnjica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a13088ab-9bc9-5a3f-8554-ffa14b24696c', 'multiple_choice', 'Як хорватською «команда; наказ»?', 'naredba', '["počistiti", "brnjica", "povesti", "naredba"]'::jsonb, 'A0', 6, 'PUBLISHED', 'naredba', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c37d90db-3f52-5b37-ab93-ad600af92dfd', 'type_answer', 'Напишіть хорватською: «кусатися; гризти»', 'gristi', null, 'A0', 7, 'PUBLISHED', 'gristi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '795d86e4-2e79-5146-a425-e53ecbf3a53a', 'type_answer', 'Напишіть хорватською: «порода»', 'pasmina', null, 'A0', 8, 'PUBLISHED', 'pasmina', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cec53c51-6517-57ab-8432-206c1c6eede0', 'type_answer', 'Напишіть хорватською: «небезпечний»', 'opasan', null, 'A0', 9, 'PUBLISHED', 'opasan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '274f4b04-e999-52d3-b0bd-0d392ef2eb5a', 'sentence_builder', 'Собакам не можна заходити.', 'Psi ne smiju ući.', '["ne", "Psi", "smiju", "ući."]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4b4b30b2-c6bc-58d8-bbbb-ace444e96913', 'sentence_builder', 'Мій собака не кусається.', 'Moj pas ne grize.', '["pas", "Moj", "grize.", "ne"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '547eed77-a08e-5a4a-ab61-9e0926569a36', 'listening', 'Прослухайте і складіть фразу', 'Vidite, maše repom!', '["Vidite,", "repom!", "maše"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '30052089-b58b-5464-883f-cadfa52df474', 'listening', 'Прослухайте і складіть фразу', 'Samo pas vodič smije ući.', '["pas", "Samo", "ući.", "smije", "vodič"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '684289b6-cd04-543b-8a15-cae251ef719a', 'speaking', 'Собаці можна всередину?', 'Smije li pas unutra?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e4e1b529-facb-5b3e-b81b-6356be814a16', 'speaking', 'Не бійтеся, він не кусається.', 'Ne bojte se, on ne grize.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'ba6156fc-85ca-5a16-ab6e-b10c0fbb1df5', 'write_message', 'Подруга Дар’я питає в чаті: «Smije li moj pas doći k tebi?» Відповідайте: так, можна; собаці не можна на диван; у вас є для нього м’ячик.', 'Naravno, smije! Ali ne smije na kauč. Imam lopticu za njega.', 'A0', 'PUBLISHED', '{"situation_ua": "Подруга Дар’я питає в чаті: «Smije li moj pas doći k tebi?» Відповідайте: так, можна; собаці не можна на диван; у вас є для нього м’ячик.", "points": [{"ua": "можна прийти", "keys": [["smije"], ["može"], ["naravno"], ["da"]]}, {"ua": "на диван не можна", "keys": [["ne smije", "kauč"], ["ne smije", "krevet"]]}, {"ua": "у вас є м’ячик для собаки", "keys": [["loptic"]]}], "hints": ["smije", "ne smije", "kauč", "loptica", "imam"], "models": ["Naravno, smije! Ali ne smije na kauč. Imam lopticu za njega.", "Da, može doći. Pas ne smije na kauč. Imam novu lopticu."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'ba6156fc-85ca-5a16-ab6e-b10c0fbb1df5', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_pets 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) у новому уроці модуля A0.6. Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'bc2959b6-92d4-502f-a5d7-fa91c38dbd9e', 'mediation', 'Друг не знає хорватської. Перекажіть йому українською головне.', 'Тут написано: обережно, собака! Собакам заходити заборонено, можна лише собакам-поводирям.', 'A0', 'PUBLISHED', '{"situation_ua": "Друг не знає хорватської. Перекажіть йому українською головне.", "friend_ua": "Що тут написано? Можна з собакою?", "direction": "hr_ua", "points": [{"ua": "собакам заходити не можна", "keys": [["не можна"], ["заборон"]]}, {"ua": "можна лише собакам-поводирям", "keys": [["поводир"]]}], "hints": [], "models": ["Тут написано: обережно, собака! Собакам заходити заборонено, можна лише собакам-поводирям."], "source_hr": "OPREZ, PAS!\nUlaz psima zabranjen.\nPsi vodiči smiju ući."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'bc2959b6-92d4-502f-a5d7-fa91c38dbd9e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_pets 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) у новому уроці модуля A0.6. Бета, потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e5bf704b-252a-5852-b02d-d075d07e1c28', v_lesson, 'У парку для собак', 'U parku za pse', 2381, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_pets') on conflict (id) do nothing;
  perform pg_temp.turn('295cab7e-8cfa-54c3-86b9-4a58e7980811', 'e5bf704b-252a-5852-b02d-d075d07e1c28', 'Luka', 'Dobar dan! Smije li moj pas ovdje bez povodca?', 'Добрий день! Моєму собаці тут можна без повідця?', 1);
  perform pg_temp.turn('755165f3-7044-5f4f-81a2-4fe203017310', 'e5bf704b-252a-5852-b02d-d075d07e1c28', 'Daša', 'Smije, ovo je park za pse. Ovdje ga možete pustiti.', 'Можна, це парк для собак. Тут його можна відпустити.', 2);
  perform pg_temp.turn('baa4690d-be97-5b6e-acc9-43cb4f7fbf7e', 'e5bf704b-252a-5852-b02d-d075d07e1c28', 'Luka', 'Super! Bruno, idi se igrati! Koje je pasmine vaš pas?', 'Чудово! Бруно, йди погратися! Якої породи ваш собака?', 3);
  perform pg_temp.turn('341010ac-69c4-5ebd-a8a9-58d31c6b8461', 'e5bf704b-252a-5852-b02d-d075d07e1c28', 'Daša', 'Nije čiste pasmine, mješanac je. Zove se Medo.', 'Не породистий, це метис. Його звати Медо.', 4);
  perform pg_temp.turn('555078fb-d267-5517-a22d-30f84f24cdb6', 'e5bf704b-252a-5852-b02d-d075d07e1c28', 'Luka', 'Medo njuši Bruna. Grize li?', 'Медо обнюхує Бруно. Він кусається?', 5);
  perform pg_temp.turn('0dad6fe3-2f14-5020-9346-6142f0a0a88b', 'e5bf704b-252a-5852-b02d-d075d07e1c28', 'Daša', 'Ne, ne grize. Vidite, maše repom! Ne bojte se.', 'Ні, не кусається. Бачите, махає хвостом! Не бійтеся.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('78a8dd8b-1b3a-5f84-8566-c5433cccf41b', v_lesson, 'Чи можна собаці всередину?', 'Smije li pas unutra?', 2382, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_pets') on conflict (id) do nothing;
  perform pg_temp.turn('845109c7-ca6a-5751-8607-3fdfb2936c4b', '78a8dd8b-1b3a-5f84-8566-c5433cccf41b', 'Darja', 'Oprostite, smije li pas unutra?', 'Перепрошую, собаці можна всередину?', 1);
  perform pg_temp.turn('e1bfb7e2-3cd7-55f0-81a7-09d3cbc131ba', '78a8dd8b-1b3a-5f84-8566-c5433cccf41b', 'Konobar', 'Nažalost, ulaz psima je zabranjen. Samo pas vodič smije ući.', 'На жаль, вхід собакам заборонено. Заходити може лише собака-поводир.', 2);
  perform pg_temp.turn('d941187e-0464-5b29-b265-de66addf536d', '78a8dd8b-1b3a-5f84-8566-c5433cccf41b', 'Darja', 'Šteta. A na terasi?', 'Шкода. А на терасі?', 3);
  perform pg_temp.turn('98f28e29-b64f-5f7d-ad1c-a1a139b25873', '78a8dd8b-1b3a-5f84-8566-c5433cccf41b', 'Konobar', 'Na terasi su psi dozvoljeni. Donijet ću mu vode.', 'На терасі собаки дозволені. Я принесу йому води.', 4);
  perform pg_temp.turn('fc5495c6-c909-5ccd-a212-f374d22b18b9', '78a8dd8b-1b3a-5f84-8566-c5433cccf41b', 'Darja', 'Hvala! Lola, sjedi! Bravo, daj šapu!', 'Дякую! Лоло, сидіти! Молодець, дай лапу!', 5);
  perform pg_temp.turn('13e98ace-189d-52de-8cbf-44858b366b55', '78a8dd8b-1b3a-5f84-8566-c5433cccf41b', 'Konobar', 'Kako je poslušna! Zna li još neku naredbu?', 'Яка слухняна! Вона знає ще якусь команду?', 6);
  perform pg_temp.turn('5bf870ee-0f2a-5d89-afd6-f836462a7426', '78a8dd8b-1b3a-5f84-8566-c5433cccf41b', 'Darja', 'Zna: lezi i dođi!', 'Знає: «лежати» і «до мене»!', 7);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок модуля A0.6 «Kućni ljubimci» за схемою уроків за темою (curriculum_a0_v4: 20–25 слів, 2 діалоги, 15 вправ) + письмо й переказ, за рішенням власника 2026-11-17. Потрібна перевірка носієм.');
end $$;

-- A0.6 · урок 39: Кішки — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'aaf6ad60-560f-5720-9a19-24398989dd00';
  v_lesson constant uuid := '5c421c03-f070-538e-b152-8c50b31f4daf';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A0.6: місце 3 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Прикметники: узгодження з іменником' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Прикметники: узгодження з іменником»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 39: Кішки', 'Lekcija 39: Mačke', '["Описати кішку: колір і характер", "Розповісти, що робить кішка", "Попросити сусідів допомогти знайти кішку"]'::jsonb, 15, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'mačak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maca', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mic mic', v_pos);
  v_pos := pg_temp.word(v_lesson, 'presti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mijaukati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kandža', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krzno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'loviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grebalica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ogrebati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lizati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'umiljat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prugast', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaštitna mreža', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mačji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'klupko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sklupčati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skočiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pobjeći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sakriti se', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa3a799d-6c2a-56c5-9be3-f58870544239', 'fill_in_the_blank', 'Moja mačka je ___.', 'prugasta', '["prugasti", "prugasto", "prugast", "prugasta"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8510495f-440b-5b1b-9b38-f71df74e0f43', 'multiple_choice', 'Що означає «sakriti se»?', 'сховатися', '["муркотіти", "дряпка (кігтеточка)", "сховатися", "киця"]'::jsonb, 'A0', 2, 'PUBLISHED', 'sakriti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b77a474e-2062-5feb-9727-e1744940acc7', 'multiple_choice', 'Що означає «klupko»?', 'клубок', '["киця", "клубок", "згорнутися клубочком", "муркотіти"]'::jsonb, 'A0', 3, 'PUBLISHED', 'klupko', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '15977d9a-e0c8-576c-8c2f-cc35fb6a845a', 'multiple_choice', 'Що означає «presti»?', 'муркотіти', '["лагідний; ласкавий", "лизати", "муркотіти", "захисна сітка"]'::jsonb, 'A0', 4, 'PUBLISHED', 'presti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'de3592f5-45c6-5e35-ab0f-a44ba216e738', 'multiple_choice', 'Як хорватською «стрибнути»?', 'skočiti', '["kandža", "zaštitna mreža", "pobjeći", "skočiti"]'::jsonb, 'A0', 5, 'PUBLISHED', 'skočiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5735ce47-db40-5788-8e31-facd575c0942', 'multiple_choice', 'Як хорватською «згорнутися клубочком»?', 'sklupčati se', '["lizati", "sklupčati se", "mačak", "klupko"]'::jsonb, 'A0', 6, 'PUBLISHED', 'sklupčati se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7d0d52c5-76b8-58b1-a2fd-abd320ff0d76', 'type_answer', 'Напишіть хорватською: «кіт»', 'mačak', null, 'A0', 7, 'PUBLISHED', 'mačak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b4b51a75-c1d1-5d3b-baf0-678bb38f6747', 'type_answer', 'Напишіть хорватською: «котячий»', 'mačji', null, 'A0', 8, 'PUBLISHED', 'mačji', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'faab6b99-ab21-5325-8b63-8621988d0022', 'type_answer', 'Напишіть хорватською: «подряпати»', 'ogrebati', null, 'A0', 9, 'PUBLISHED', 'ogrebati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0f7e7fcd-42d0-5b61-adc2-83ce74d63be2', 'sentence_builder', 'Мій кіт дуже лагідний.', 'Moj mačak je jako umiljat.', '["mačak", "jako", "umiljat.", "Moj", "je"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd4b8d4cf-b4e4-5d1f-811a-576d1a2372f5', 'sentence_builder', 'Кішка лиже лапу.', 'Mačka liže šapu.', '["liže", "šapu.", "Mačka"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '18152670-9024-5b9f-89a4-7e71701d3165', 'listening', 'Прослухайте і складіть фразу', 'Siv je i prugast.', '["i", "Siv", "je", "prugast."]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ce3aa6dd-d664-52f7-b2fc-027618b79647', 'listening', 'Прослухайте і складіть фразу', 'Pobjegla je s balkona.', '["s", "je", "balkona.", "Pobjegla"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '14912120-defc-5a53-ba50-7f1f2813e18f', 'speaking', 'Ви не бачили мою кішку?', 'Jeste li vidjeli moju mačku?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2031c0e7-0188-5240-9a0c-5655923ecc85', 'speaking', 'Мій кіт сірий і смугастий.', 'Moj mačak je siv i prugast.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'fba1cc22-bcbd-5bc8-9602-5ee7b814c961', 'write_message', 'Ваш кіт утік. Напишіть у чат будинку: кіт утік, якого він кольору, і попросіть сусідів зателефонувати.', 'Pobjegao je moj mačak Tigar! Siv je i prugast. Molim vas, nazovite me!', 'A0', 'PUBLISHED', '{"situation_ua": "Ваш кіт утік. Напишіть у чат будинку: кіт утік, якого він кольору, і попросіть сусідів зателефонувати.", "points": [{"ua": "кіт утік / зник", "keys": [["pobjeg"], ["nesta"]]}, {"ua": "колір кота", "keys": [["siv"], ["crn"], ["bijel"], ["prugast"], ["riđ"]]}, {"ua": "попросіть зателефонувати", "keys": [["nazov"], ["zovite"], ["javi"]]}], "hints": ["pobjegao je", "mačak", "siv", "prugast", "nazovite me"], "models": ["Pobjegao je moj mačak Tigar! Siv je i prugast. Molim vas, nazovite me!", "Moja mačka je nestala. Crna je, s bijelim šapama. Javite se, molim vas!"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'fba1cc22-bcbd-5bc8-9602-5ee7b814c961', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_pets 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) у новому уроці модуля A0.6. Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'e6c851e7-8064-531b-a62c-fd9588d12a45', 'mediation', 'Друг не знає хорватської. Перекажіть йому українською головне.', 'Мешканців просять не годувати кішок на сходах.', 'A0', 'PUBLISHED', '{"situation_ua": "Друг не знає хорватської. Перекажіть йому українською головне.", "friend_ua": "Що тут написано?", "direction": "hr_ua", "points": [{"ua": "не годувати кішок", "keys": [["не году", "кіш"], ["не году", "кот"]]}, {"ua": "на сходах / у під’їзді", "keys": [["сход"], ["під"]]}], "hints": [], "models": ["Мешканців просять не годувати кішок на сходах."], "source_hr": "Poštovani stanari,\nmolimo vas da ne hranite mačke na stubištu.\nHvala!"}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'e6c851e7-8064-531b-a62c-fd9588d12a45', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_pets 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) у новому уроці модуля A0.6. Бета, потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('34ed0d8e-3b91-554b-94ba-d199acabcdc5', v_lesson, 'Нова киця', 'Nova maca', 2391, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_pets') on conflict (id) do nothing;
  perform pg_temp.turn('90d5c2e3-0849-5398-acc2-9a683dfd73ff', '34ed0d8e-3b91-554b-94ba-d199acabcdc5', 'Ana', 'Dašo, je li to vaša nova maca?', 'Дашо, це ваша нова киця?', 1);
  perform pg_temp.turn('d5bc32bd-534c-5c33-8a1c-2595a7673238', '34ed0d8e-3b91-554b-94ba-d199acabcdc5', 'Daša', 'Nije maca, to je mačak! Zove se Tigar.', 'Це не киця, це кіт! Його звати Тигр.', 2);
  perform pg_temp.turn('a10c7a91-6ca5-525c-bf60-8c0aa1778c8c', '34ed0d8e-3b91-554b-94ba-d199acabcdc5', 'Ana', 'Lijep je! Siv je i prugast.', 'Гарний! Сірий і смугастий.', 3);
  perform pg_temp.turn('66e73825-2ceb-52c6-be09-9fac49f3a011', '34ed0d8e-3b91-554b-94ba-d199acabcdc5', 'Daša', 'I jako umiljat. Kad ga mazim, prede.', 'І дуже лагідний. Коли я його гладжу, він муркоче.', 4);
  perform pg_temp.turn('b1904d87-d968-5df8-b8b2-36a8faf2d4bd', '34ed0d8e-3b91-554b-94ba-d199acabcdc5', 'Ana', 'A grebe li namještaj?', 'А меблі він дряпає?', 5);
  perform pg_temp.turn('99c60f23-ba07-55e2-b91b-9594a12b0a0d', '34ed0d8e-3b91-554b-94ba-d199acabcdc5', 'Daša', 'Ne, ima grebalicu. Ali često skoči na stol!', 'Ні, у нього є дряпка. Але часто стрибає на стіл!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c7879292-3a62-5926-afca-94a08336e1ac', v_lesson, 'Кішка втекла', 'Mačka je pobjegla', 2392, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_pets') on conflict (id) do nothing;
  perform pg_temp.turn('27f70b8f-f5ee-5787-a6dc-7321ba664616', 'c7879292-3a62-5926-afca-94a08336e1ac', 'Darja', 'Dobar dan, susjede! Jeste li vidjeli moju mačku?', 'Добрий день, сусіде! Ви не бачили мою кішку?', 1);
  perform pg_temp.turn('2ad91be0-c637-5d39-9ff0-aef2646570c0', 'c7879292-3a62-5926-afca-94a08336e1ac', 'Susjed', 'Kakva je?', 'Яка вона?', 2);
  perform pg_temp.turn('f1f2aa48-d6d5-5622-a92f-c07dcd8c6721', 'c7879292-3a62-5926-afca-94a08336e1ac', 'Darja', 'Mala je, crna, s bijelim šapama. Pobjegla je s balkona.', 'Маленька, чорна, з білими лапками. Втекла з балкона.', 3);
  perform pg_temp.turn('a9bb1a1c-f079-5dd2-a83a-5c4b212875df', 'c7879292-3a62-5926-afca-94a08336e1ac', 'Susjed', 'Zar na balkonu nema zaštitne mreže?', 'Хіба на балконі немає захисної сітки?', 4);
  perform pg_temp.turn('c8ba82a4-ddab-51de-a8b9-7823e67e7e58', 'c7879292-3a62-5926-afca-94a08336e1ac', 'Darja', 'Ima, ali u mreži je mala rupa.', 'Є, але в сітці маленька дірка.', 5);
  perform pg_temp.turn('613384d2-2f10-538d-a282-e6e35c31734b', 'c7879292-3a62-5926-afca-94a08336e1ac', 'Susjed', 'Mačke se često sakriju ispod auta. Mic mic!', 'Кішки часто ховаються під машинами. Кис-кис!', 6);
  perform pg_temp.turn('60fe32ce-6025-54f3-94e0-203660a38c18', 'c7879292-3a62-5926-afca-94a08336e1ac', 'Darja', 'Eno je! Mijauče ispod auta!', 'Он вона! Нявкає під машиною!', 7);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок модуля A0.6 «Kućni ljubimci» за схемою уроків за темою (curriculum_a0_v4: 20–25 слів, 2 діалоги, 15 вправ) + письмо й переказ, за рішенням власника 2026-11-17. Потрібна перевірка носієм.');
end $$;

-- A0.6 · урок 40: У ветеринара — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'aaf6ad60-560f-5720-9a19-24398989dd00';
  v_lesson constant uuid := 'fa7fd153-275f-5214-b759-2db31e50a4b4';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A0.6: місце 4 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Що болить? Boli me…, bole me…' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Що болить? Boli me…, bole me…»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 40: У ветеринара', 'Lekcija 40: Kod veterinara', '["Пояснити ветеринару, що з твариною", "Зрозуміти поради ветеринара", "Записатися на огляд"]'::jsonb, 15, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'veterinarska ambulanta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čip', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krpelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'parazit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kastrirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sterilizirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vaga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otrov', v_pos);
  v_pos := pg_temp.word(v_lesson, 'apetit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'što mu je', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šepati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaštitni ovratnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dežurni veterinar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cijepljen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podrezati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nokat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mirno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'operacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čokolada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'protiv', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'da0434d4-f502-56c9-8c24-b0862948d634', 'fill_in_the_blank', 'Psa ___ šapa.', 'boli', '["bolim", "boli", "boljeti", "bole"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1561a5ed-df6c-538f-bc6e-23870fedbf2d', 'multiple_choice', 'Що означає «cijepljen»?', 'щеплений', '["стерилізувати", "щеплений", "підрізати; підстригти", "каструвати"]'::jsonb, 'A0', 2, 'PUBLISHED', 'cijepljen', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bebf5150-669c-527f-a50f-1ec85e687e24', 'multiple_choice', 'Що означає «operacija»?', 'операція', '["операція", "каструвати", "спокійно", "проти"]'::jsonb, 'A0', 3, 'PUBLISHED', 'operacija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4da3afea-44d4-5dbe-a104-a94e913a1e09', 'multiple_choice', 'Що означає «otrov»?', 'отрута', '["операція", "стерилізувати", "отрута", "проти"]'::jsonb, 'A0', 4, 'PUBLISHED', 'otrov', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '40b81862-6b41-572f-845d-146f6359b95f', 'multiple_choice', 'Як хорватською «ваги»?', 'vaga', '["kastrirati", "šepati", "apetit", "vaga"]'::jsonb, 'A0', 5, 'PUBLISHED', 'vaga', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '26f3e695-6ced-5c4b-9778-2a1930c45b3c', 'multiple_choice', 'Як хорватською «паразит»?', 'parazit', '["veterinarska ambulanta", "što mu je", "parazit", "cijepljen"]'::jsonb, 'A0', 6, 'PUBLISHED', 'parazit', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6e7d49e1-dd54-5b81-8382-00baefdc44b8', 'type_answer', 'Напишіть хорватською: «спокійно»', 'mirno', null, 'A0', 7, 'PUBLISHED', 'mirno', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '477fad36-4838-5643-94e4-178f3eba1cbc', 'type_answer', 'Напишіть хорватською: «кліщ»', 'krpelj', null, 'A0', 8, 'PUBLISHED', 'krpelj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '30a61834-948c-58d3-aa3f-635a9b0c5c55', 'type_answer', 'Напишіть хорватською: «проти»', 'protiv', null, 'A0', 9, 'PUBLISHED', 'protiv', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '71facb03-4c0a-52bb-bcf1-dca0ad678aa9', 'sentence_builder', 'Що з ним?', 'Što mu je?', '["mu", "Što", "je?"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9872fac1-ddfa-50c9-928d-e7d80578449b', 'sentence_builder', 'Шоколад — отрута для собак.', 'Čokolada je otrov za pse.', '["Čokolada", "pse.", "otrov", "je", "za"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f4cad7b5-0967-54a0-bf91-af558a56a03b', 'listening', 'Прослухайте і складіть фразу', 'Šepa od jučer.', '["od", "Šepa", "jučer."]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '588d84e2-b31c-5d6e-8728-ccd52e8cc2d9', 'listening', 'Прослухайте і складіть фразу', 'Krpelji su opasni paraziti.', '["su", "paraziti.", "Krpelji", "opasni"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '79c1ec4e-5df3-54a8-9bd2-ab08e2dd80f4', 'speaking', 'Що з ним? Він кульгає.', 'Što mu je? Šepa.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '72c51885-fe0b-581f-960b-24599849c1e8', 'speaking', 'У вас є засіб проти кліщів?', 'Imate li sredstvo protiv krpelja?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '6ba31edb-30a5-5af4-a336-7bf9c73551fa', 'write_message', 'Напишіть у ветеринарну клініку: ваш собака кульгає; попросіть записати вас на огляд завтра.', 'Dobar dan! Moj pas šepa. Imate li termin za sutra? Hvala!', 'A0', 'PUBLISHED', '{"situation_ua": "Напишіть у ветеринарну клініку: ваш собака кульгає; попросіть записати вас на огляд завтра.", "points": [{"ua": "собака кульгає", "keys": [["šep"]]}, {"ua": "попросіть термін або огляд", "keys": [["termin"], ["pregled"], ["mogu li doći"], ["možemo li doći"]]}, {"ua": "коли: завтра", "keys": [["sutra"]]}], "hints": ["moj pas šepa", "termin", "sutra", "molim vas"], "models": ["Dobar dan! Moj pas šepa. Imate li termin za sutra? Hvala!", "Poštovani, pas mi šepa od jučer. Možemo li doći sutra ujutro na pregled?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '6ba31edb-30a5-5af4-a336-7bf9c73551fa', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_pets 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) у новому уроці модуля A0.6. Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '5be1c4eb-0ef0-5eed-a2e2-8f3b4e67eeb9', 'mediation', 'Друг не знає хорватської. Перекажіть йому українською головне.', 'Клініка працює з понеділка по п’ятницю з 8 до 19, а в суботу з 8 до 12. Для термінових випадків є телефон.', 'A0', 'PUBLISHED', '{"situation_ua": "Друг не знає хорватської. Перекажіть йому українською головне.", "friend_ua": "Коли працює ця клініка?", "direction": "hr_ua", "points": [{"ua": "у будні з 8 до 19", "keys": [["понеділ", "19"], ["будн", "19"]]}, {"ua": "у суботу з 8 до 12", "keys": [["субот", "12"]]}], "hints": [], "models": ["Клініка працює з понеділка по п’ятницю з 8 до 19, а в суботу з 8 до 12. Для термінових випадків є телефон."], "source_hr": "VETERINARSKA AMBULANTA\nRadno vrijeme: pon – pet 8 – 19, sub 8 – 12\nHitni slučajevi: 091 555 0101"}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '5be1c4eb-0ef0-5eed-a2e2-8f3b4e67eeb9', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_pets 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) у новому уроці модуля A0.6. Бета, потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a994ace1-8c18-5a3d-8637-d34cac43f6b9', v_lesson, 'У ветеринара', 'Kod veterinara', 2401, 'A0', 'vet', 'PUBLISHED', 'claude_curriculum_a0_pets') on conflict (id) do nothing;
  perform pg_temp.turn('d8b51d6b-c3c9-5b3d-b715-6124fda2e1c7', 'a994ace1-8c18-5a3d-8637-d34cac43f6b9', 'Veterinarka', 'Dobar dan! Što mu je?', 'Добрий день! Що з ним?', 1);
  perform pg_temp.turn('47a7325a-55e5-5f7d-88fc-7b393552ed13', 'a994ace1-8c18-5a3d-8637-d34cac43f6b9', 'Daša', 'Šepa od jučer. Mislim da ga boli šapa.', 'Кульгає з учора. Думаю, у нього болить лапа.', 2);
  perform pg_temp.turn('929ade3a-f1ba-5fb5-bd6b-99d4fa8384ce', 'a994ace1-8c18-5a3d-8637-d34cac43f6b9', 'Veterinarka', 'Stavite ga na vagu, molim. Držite ga mirno.', 'Поставте його на ваги, будь ласка. Тримайте його спокійно.', 3);
  perform pg_temp.turn('cacd388e-6408-5a10-a439-d7c467ef4eb7', 'a994ace1-8c18-5a3d-8637-d34cac43f6b9', 'Daša', 'Dobro. Mirno, Medo!', 'Добре. Спокійно, Медо!', 4);
  perform pg_temp.turn('dbf391a5-30a4-5bb5-9886-d2b9cb27d690', 'a994ace1-8c18-5a3d-8637-d34cac43f6b9', 'Veterinarka', 'Aha, nokat mu je predug. Podrezat ću ga.', 'Ага, кіготь у нього задовгий. Я його підріжу.', 5);
  perform pg_temp.turn('47c5bca2-a86b-5827-81e9-e9c29ea20431', 'a994ace1-8c18-5a3d-8637-d34cac43f6b9', 'Daša', 'Hvala! Treba li mu i cijepljenje?', 'Дякую! Йому ще потрібне щеплення?', 6);
  perform pg_temp.turn('e09c2965-203c-5c79-a5b1-be5f404e164f', 'a994ace1-8c18-5a3d-8637-d34cac43f6b9', 'Veterinarka', 'Ne, cijepljen je. Ali ima li čip?', 'Ні, він щеплений. А чип у нього є?', 7);
  perform pg_temp.turn('2e1569e6-11bb-5a41-920f-41262b87b72d', 'a994ace1-8c18-5a3d-8637-d34cac43f6b9', 'Daša', 'Ima, evo broja čipa.', 'Є, ось номер чипа.', 8);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b1a76a3d-be4c-5e7c-b5f0-870337dd7a16', v_lesson, 'Кліщ', 'Krpelj', 2402, 'A0', 'vet', 'PUBLISHED', 'claude_curriculum_a0_pets') on conflict (id) do nothing;
  perform pg_temp.turn('24e3c559-5732-585e-b27e-84e2f3123ec5', 'b1a76a3d-be4c-5e7c-b5f0-870337dd7a16', 'Darja', 'Dobar dan, je li to dežurni veterinar?', 'Добрий день, це черговий ветеринар?', 1);
  perform pg_temp.turn('7e5cd3c7-46b9-5101-95c1-50fbd57405ce', 'b1a76a3d-be4c-5e7c-b5f0-870337dd7a16', 'Veterinar', 'Da, izvolite.', 'Так, слухаю.', 2);
  perform pg_temp.turn('0e5bb892-253b-5093-845e-201c164aafe5', 'b1a76a3d-be4c-5e7c-b5f0-870337dd7a16', 'Darja', 'Moja mačka nema apetita i samo leži.', 'Моя кішка не має апетиту й тільки лежить.', 3);
  perform pg_temp.turn('449e909b-9eda-5265-9534-83740c66886f', 'b1a76a3d-be4c-5e7c-b5f0-870337dd7a16', 'Veterinar', 'Je li pojela nešto čudno? Čokolada je otrov za mačke.', 'Вона не з’їла чогось дивного? Шоколад — отрута для котів.', 4);
  perform pg_temp.turn('0e6ed087-f43a-597e-a92c-364848a7eab0', 'b1a76a3d-be4c-5e7c-b5f0-870337dd7a16', 'Darja', 'Ne znam. Ali danas sam našla krpelja na njoj.', 'Не знаю. Але сьогодні я знайшла на ній кліща.', 5);
  perform pg_temp.turn('83ae349b-0402-5c57-bde1-2afba96be644', 'b1a76a3d-be4c-5e7c-b5f0-870337dd7a16', 'Veterinar', 'Dođite odmah. Krpelji su opasni paraziti.', 'Приїжджайте негайно. Кліщі — небезпечні паразити.', 6);
  perform pg_temp.turn('9892c3ad-697a-57c7-a37c-75d233606b96', 'b1a76a3d-be4c-5e7c-b5f0-870337dd7a16', 'Darja', 'Dolazim! Imate li sredstvo protiv krpelja?', 'Їду! У вас є засіб проти кліщів?', 7);
  perform pg_temp.turn('10c5fb1f-6aab-52af-85c7-1c0f1c0a69e8', 'b1a76a3d-be4c-5e7c-b5f0-870337dd7a16', 'Veterinar', 'Imamo. Vidimo se za pola sata.', 'Є. Побачимося за пів години.', 8);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок модуля A0.6 «Kućni ljubimci» за схемою уроків за темою (curriculum_a0_v4: 20–25 слів, 2 діалоги, 15 вправ) + письмо й переказ, за рішенням власника 2026-11-17. Потрібна перевірка носієм.');
end $$;

-- A0.6 · урок 41: Тварини на фермі — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'aaf6ad60-560f-5720-9a19-24398989dd00';
  v_lesson constant uuid := '5ffbe419-6abc-574e-907e-2dc427276abd';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A0.6: місце 5 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Рід, множина і «мій / моя / моє»' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Рід, множина і «мій / моя / моє»»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 41: Тварини на фермі', 'Lekcija 41: Životinje na farmi', '["Назвати тварин на фермі", "Сказати, скільки тварин: одна корова — дві корови", "Розповісти про село й ферму"]'::jsonb, 15, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'farma', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tele', v_pos);
  v_pos := pg_temp.word(v_lesson, 'magarac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'janje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pijetao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'guska', v_pos);
  v_pos := pg_temp.word(v_lesson, 'štala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sijeno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'musti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jahati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mukati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'konj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovca', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svinja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kokoš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'patka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'seljak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'livada', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a586a10a-3a56-5ff8-a267-7d506c8433c7', 'fill_in_the_blank', 'Na farmi su dvije ___.', 'krave', '["krava", "krave", "kravu", "kravi"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '95cff122-75ba-58c0-b070-5b8b066d6feb', 'multiple_choice', 'Що означає «magarac»?', 'віслюк', '["качка", "віслюк", "півень", "доїти"]'::jsonb, 'A0', 2, 'PUBLISHED', 'magarac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4820ff76-c5ae-5af8-b5a8-e79517728baf', 'multiple_choice', 'Що означає «patka»?', 'качка', '["гуска", "качка", "їздити верхи", "селянин"]'::jsonb, 'A0', 3, 'PUBLISHED', 'patka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '95aa6225-4af5-5597-abf2-86ae4e846662', 'multiple_choice', 'Що означає «seljak»?', 'селянин', '["кіза", "селянин", "корова", "мукати"]'::jsonb, 'A0', 4, 'PUBLISHED', 'seljak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa5f4ca1-5bd0-5096-b18e-2347ded5a0fa', 'multiple_choice', 'Як хорватською «сіно»?', 'sijeno', '["magarac", "mukati", "sijeno", "livada"]'::jsonb, 'A0', 5, 'PUBLISHED', 'sijeno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ab2b7dd8-bd06-5e07-a7f3-b77f7742ea23', 'multiple_choice', 'Як хорватською «луг / галявина»?', 'livada', '["pijetao", "janje", "livada", "konj"]'::jsonb, 'A0', 6, 'PUBLISHED', 'livada', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3d0995a8-5490-5407-9646-c85f7fd16eef', 'type_answer', 'Напишіть хорватською: «доїти»', 'musti', null, 'A0', 7, 'PUBLISHED', 'musti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '15d96930-c5c3-5311-8309-457ac7f885a4', 'type_answer', 'Напишіть хорватською: «свиня»', 'svinja', null, 'A0', 8, 'PUBLISHED', 'svinja', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '441ef5b7-a47b-5e47-a860-84cfbcf4c4cd', 'type_answer', 'Напишіть хорватською: «теля»', 'tele', null, 'A0', 9, 'PUBLISHED', 'tele', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '22ca656f-83eb-59b3-a040-96fac493865b', 'sentence_builder', 'У бабусі є корова й кози.', 'Baka ima kravu i koze.', '["Baka", "kravu", "ima", "i", "koze."]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '98ad0a19-1fa4-55d7-8490-7c3fbc19a8e5', 'sentence_builder', 'Півень співає щоранку.', 'Pijetao pjeva svako jutro.', '["pjeva", "jutro.", "Pijetao", "svako"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '75e701e8-cfda-5301-9be2-1803617c76a0', 'listening', 'Прослухайте і складіть фразу', 'To je pijetao!', '["je", "To", "pijetao!"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c4a3b766-3f7e-51b6-b36a-208854b91e21', 'listening', 'Прослухайте і складіть фразу', 'Deset eura za pola sata.', '["za", "sata.", "eura", "Deset", "pola"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8608fae-96cb-56a3-bec6-7eb0ef0e9fbe', 'speaking', 'Можна поїздити верхи?', 'Mogu li jahati?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '72222864-0bb6-5d5d-846e-340f09e78766', 'speaking', 'Скільки тварин у тебе на фермі?', 'Koliko životinja imaš na farmi?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '46e0ac44-0412-5317-8519-f421bc9c472a', 'write_message', 'Ви на вихідних у бабусі на фермі. Напишіть Даші: де ви, які тварини тут є, і запросіть її приїхати.', 'Bok, Dašo! Na farmi sam kod bake. Ovdje su krave, koze i konji. Dođi i ti!', 'A0', 'PUBLISHED', '{"situation_ua": "Ви на вихідних у бабусі на фермі. Напишіть Даші: де ви, які тварини тут є, і запросіть її приїхати.", "points": [{"ua": "де ви: на фермі чи в селі", "keys": [["farm"], ["sel"]]}, {"ua": "які тварини тут є", "keys": [["krav"], ["konj"], ["koz"], ["ovc"], ["svinj"], ["kokoš"], ["patk"], ["gusk"]]}, {"ua": "запросіть приїхати", "keys": [["dođi"], ["dođite"]]}], "hints": ["na farmi sam", "krave", "konji", "dođi"], "models": ["Bok, Dašo! Na farmi sam kod bake. Ovdje su krave, koze i konji. Dođi i ti!", "Ja sam na selu. Imamo kokoši i jednu kravu. Dođi sutra!"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '46e0ac44-0412-5317-8519-f421bc9c472a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_pets 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) у новому уроці модуля A0.6. Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '8f64d42f-01b6-58c7-878f-b226f39ced53', 'mediation', 'Друг не знає хорватської. Перекажіть йому українською головне.', 'Тут щодня продають свіже молоко і яйця. А в суботу й неділю можна їздити верхи.', 'A0', 'PUBLISHED', '{"situation_ua": "Друг не знає хорватської. Перекажіть йому українською головне.", "friend_ua": "Що тут продають і що можна робити?", "direction": "hr_ua", "points": [{"ua": "молоко і яйця", "keys": [["молок", "яй"]]}, {"ua": "у вихідні можна їздити верхи", "keys": [["верхи"]]}], "hints": [], "models": ["Тут щодня продають свіже молоко і яйця. А в суботу й неділю можна їздити верхи."], "source_hr": "Farma Zeleni Gaj\nSvježe mlijeko i jaja svaki dan.\nJahanje: subotom i nedjeljom."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '8f64d42f-01b6-58c7-878f-b226f39ced53', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_pets 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) у новому уроці модуля A0.6. Бета, потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f94d949f-13b4-534b-82de-60f4ea65257e', v_lesson, 'У бабусі на селі', 'Kod bake na selu', 2411, 'A0', 'travel', 'PUBLISHED', 'claude_curriculum_a0_pets') on conflict (id) do nothing;
  perform pg_temp.turn('7f0a80b2-8f5b-5e8d-914f-0e840d2920c4', 'f94d949f-13b4-534b-82de-60f4ea65257e', 'Daša', 'Bako, koliko životinja imaš na farmi?', 'Бабусю, скільки тварин у тебе на фермі?', 1);
  perform pg_temp.turn('c8b30868-2a86-51b2-9cbd-2d8c57497d86', 'f94d949f-13b4-534b-82de-60f4ea65257e', 'Baka', 'Imam jednu kravu, dvije koze i deset kokoši.', 'У мене одна корова, дві кози й десять курей.', 2);
  perform pg_temp.turn('b6c3d964-edd7-5c0d-bda3-f5fd29c9c0e5', 'f94d949f-13b4-534b-82de-60f4ea65257e', 'Daša', 'A tko to tako rano viče?', 'А хто це так рано кричить?', 3);
  perform pg_temp.turn('7c0ec4db-936b-515c-a1e1-127fcd704764', 'f94d949f-13b4-534b-82de-60f4ea65257e', 'Baka', 'To je pijetao! Svako jutro u pet sati.', 'Це півень! Щоранку о п’ятій.', 4);
  perform pg_temp.turn('ba5cc757-1f85-5fd9-ba32-a7ac9bb78e32', 'f94d949f-13b4-534b-82de-60f4ea65257e', 'Daša', 'Mogu li vidjeti tele u štali?', 'Можна подивитися на теля в стайні?', 5);
  perform pg_temp.turn('6838d88f-1a7e-569a-a1c7-56de91fe8ae8', 'f94d949f-13b4-534b-82de-60f4ea65257e', 'Baka', 'Možeš. Ali prvo moram pomusti kravu.', 'Можна. Але спершу мені треба подоїти корову.', 6);
  perform pg_temp.turn('e609f386-2ab1-5ab5-b6bb-dfd29502a6b9', 'f94d949f-13b4-534b-82de-60f4ea65257e', 'Daša', 'Mogu li ja probati musti?', 'А можна я спробую доїти?', 7);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('141bd37d-8f0c-5955-8076-2d86e751ffd6', v_lesson, 'Їзда верхи', 'Jahanje', 2412, 'A0', 'travel', 'PUBLISHED', 'claude_curriculum_a0_pets') on conflict (id) do nothing;
  perform pg_temp.turn('507101fe-dea8-53c6-b67e-294c6ecbf2dc', '141bd37d-8f0c-5955-8076-2d86e751ffd6', 'Darja', 'Gledaj, Dašo, konji na livadi!', 'Дивись, Дашо, коні на лузі!', 1);
  perform pg_temp.turn('501b5e82-0914-52d5-a08b-fc8c5044c936', '141bd37d-8f0c-5955-8076-2d86e751ffd6', 'Daša', 'I magarac! Jede travu.', 'І віслюк! Їсть траву.', 2);
  perform pg_temp.turn('f423ba37-c0c8-55e7-92fd-bf1f460c24b6', '141bd37d-8f0c-5955-8076-2d86e751ffd6', 'Seljak', 'Dobar dan! Želite li jahati?', 'Добрий день! Хочете поїздити верхи?', 3);
  perform pg_temp.turn('bd2a0f99-2ae2-5a7d-8776-6c59d2645d68', '141bd37d-8f0c-5955-8076-2d86e751ffd6', 'Darja', 'Želimo, ali nikad nismo jahale.', 'Хочемо, але ми ніколи не їздили верхи.', 4);
  perform pg_temp.turn('fa272441-4002-5f6f-9de7-19c9d27bfbe2', '141bd37d-8f0c-5955-8076-2d86e751ffd6', 'Seljak', 'Nema problema, ovaj konj je miran.', 'Без проблем, цей кінь спокійний.', 5);
  perform pg_temp.turn('fac7c2c8-4ab0-5c60-a573-23ff7b1f4b28', '141bd37d-8f0c-5955-8076-2d86e751ffd6', 'Daša', 'Koliko košta jahanje?', 'Скільки коштує їзда верхи?', 6);
  perform pg_temp.turn('2b2570e6-bf33-52dd-a6e3-af8eae12f811', '141bd37d-8f0c-5955-8076-2d86e751ffd6', 'Seljak', 'Deset eura za pola sata.', 'Десять євро за пів години.', 7);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок модуля A0.6 «Kućni ljubimci» за схемою уроків за темою (curriculum_a0_v4: 20–25 слів, 2 діалоги, 15 вправ) + письмо й переказ, за рішенням власника 2026-11-17. Потрібна перевірка носієм.');
end $$;

-- A0.6 · урок 42: Подорож з улюбленцем — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'aaf6ad60-560f-5720-9a19-24398989dd00';
  v_lesson constant uuid := 'd3008969-de66-509c-a2d4-88987322edb5';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A0.6: місце 6 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Питальні слова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Питальні слова»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 42: Подорож з улюбленцем', 'Lekcija 42: Putovanje s ljubimcem', '["Дізнатися, які документи потрібні тварині в подорожі", "Запитати в житлі, чи можна з собакою", "Зрозуміти правила перевезення тварин"]'::jsonb, 15, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'putovnica za kućne ljubimce', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bjesnoća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'veterinarska potvrda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'transporter', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plaža za pse', v_pos);
  v_pos := pg_temp.word(v_lesson, 'doplata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pansion za pse', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sigurnosni pojas', v_pos);
  v_pos := pg_temp.word(v_lesson, 'aviokompanija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sredstvo za smirenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ograničenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čipiran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zrakoplov', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Europska unija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'najmanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'noćiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'granična policija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobrodošao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pojilica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dopustiti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '81825b21-5956-59b1-8ee1-ed2daff3c328', 'fill_in_the_blank', '___ košta doplata za psa?', 'Koliko', '["Gdje", "Kada", "Koliko", "Tko"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e8f78564-ed73-5e3b-93c7-2075b6e161cc', 'multiple_choice', 'Що означає «sredstvo za smirenje»?', 'заспокійливий засіб', '["ветеринарна довідка", "заспокійливий засіб", "ночувати", "літак"]'::jsonb, 'A0', 2, 'PUBLISHED', 'sredstvo za smirenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '14457a5d-5f9e-5ae2-8074-c039d7615498', 'multiple_choice', 'Що означає «ograničenje»?', 'обмеження', '["переноска (для тварини)", "ремінь безпеки", "ночувати", "обмеження"]'::jsonb, 'A0', 3, 'PUBLISHED', 'ograničenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c6cbd69-4267-5a2b-a3e2-88d3b117f272', 'multiple_choice', 'Що означає «sigurnosni pojas»?', 'ремінь безпеки', '["Європейський Союз", "ремінь безпеки", "готель для собак", "щонайменше"]'::jsonb, 'A0', 4, 'PUBLISHED', 'sigurnosni pojas', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2434e3fe-9ff9-5b84-9840-9802cb6d5612', 'multiple_choice', 'Як хорватською «щонайменше»?', 'najmanje', '["plaža za pse", "pojilica", "sredstvo za smirenje", "najmanje"]'::jsonb, 'A0', 5, 'PUBLISHED', 'najmanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '12a3ab33-c478-5a49-af08-c954edbfd7a4', 'multiple_choice', 'Як хорватською «чипований»?', 'čipiran', '["noćiti", "aviokompanija", "čipiran", "doplata"]'::jsonb, 'A0', 6, 'PUBLISHED', 'čipiran', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd12c74ae-8524-52b7-ba7a-9382749f7397', 'type_answer', 'Напишіть хорватською: «авіакомпанія»', 'aviokompanija', null, 'A0', 7, 'PUBLISHED', 'aviokompanija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '20f802f6-39bd-546a-ac49-0f12dc075c22', 'type_answer', 'Напишіть хорватською: «Європейський Союз»', 'Europska unija', null, 'A0', 8, 'PUBLISHED', 'Europska unija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c276ca07-c080-5afb-a320-8034b615aa05', 'type_answer', 'Напишіть хорватською: «ночувати»', 'noćiti', null, 'A0', 9, 'PUBLISHED', 'noćiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0e8bc003-58f3-5beb-98bf-2b152ce7df0a', 'sentence_builder', 'Мій собака подорожує в переносці.', 'Moj pas putuje u transporteru.', '["putuje", "pas", "u", "Moj", "transporteru."]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5ca7b230-0bcf-5c1f-9ef5-e2d651064f36', 'sentence_builder', 'Де пляж для собак?', 'Gdje je plaža za pse?', '["pse?", "Gdje", "je", "plaža", "za"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b51f6554-0d40-546b-8c20-f8728d777857', 'listening', 'Прослухайте і складіть фразу', 'Je li čipiran?', '["Je", "čipiran?", "li"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'df56c127-6adf-5faf-aade-c276d16ebf66', 'listening', 'Прослухайте і складіть фразу', 'Dvije osobe i jedan mali pas.', '["pas.", "mali", "i", "osobe", "Dvije", "jedan"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '991e2129-2adb-5dd7-852c-993fc096ac9d', 'speaking', 'Можна приїхати до вас із собакою?', 'Smijem li doći sa psom?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '18694df6-1f0d-5939-893d-c5e22fb1523f', 'speaking', 'Ось паспорт мого собаки.', 'Evo putovnice mog psa.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '105b495f-dd83-5c66-ad00-c034e1751c05', 'write_message', 'Ви бронюєте апартаменти на морі. Напишіть господарю: ви приїдете із собакою; запитайте, чи можна, і скільки коштує доплата.', 'Dobar dan! Dolazimo sa psom. Smije li pas u apartman? Koliko košta doplata?', 'A0', 'PUBLISHED', '{"situation_ua": "Ви бронюєте апартаменти на морі. Напишіть господарю: ви приїдете із собакою; запитайте, чи можна, і скільки коштує доплата.", "points": [{"ua": "ви приїдете із собакою", "keys": [["psom"], ["psa"], ["pas"], ["psi"]]}, {"ua": "запитайте, чи можна", "keys": [["smije"], ["može li"], ["je li u redu"], ["dozvoljen"]]}, {"ua": "скільки доплата", "keys": [["koliko", "doplat"], ["koliko košta"]]}], "hints": ["dolazimo sa psom", "smije li", "koliko košta", "doplata"], "models": ["Dobar dan! Dolazimo sa psom. Smije li pas u apartman? Koliko košta doplata?", "Poštovani, imamo malog psa. Može li i on doći? Koliko je doplata?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '105b495f-dd83-5c66-ad00-c034e1751c05', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_pets 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) у новому уроці модуля A0.6. Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '721e8c7c-1db1-5f0c-8419-deb7e285be03', 'mediation', 'Друг не знає хорватської. Перекажіть йому українською головне.', 'Тварин приймають, але треба доплатити 10 євро за ніч. І собакам не можна в басейн.', 'A0', 'PUBLISHED', '{"situation_ua": "Друг не знає хорватської. Перекажіть йому українською головне.", "friend_ua": "Що тут написано про тварин?", "direction": "hr_ua", "points": [{"ua": "тварин приймають, доплата 10 євро за ніч", "keys": [["10"], ["десять"]]}, {"ua": "собакам не можна в басейн", "keys": [["басейн"]]}], "hints": [], "models": ["Тварин приймають, але треба доплатити 10 євро за ніч. І собакам не можна в басейн."], "source_hr": "Poštovani gosti,\nkućni ljubimci su dobrodošli uz doplatu od 10 € po noći.\nPsi ne smiju u bazen."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '721e8c7c-1db1-5f0c-8419-deb7e285be03', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_pets 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) у новому уроці модуля A0.6. Бета, потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('61b6424e-78ba-5288-9de4-c833f2c0a18d', v_lesson, 'На кордоні із собакою', 'Na granici sa psom', 2421, 'A0', 'border', 'PUBLISHED', 'claude_curriculum_a0_pets') on conflict (id) do nothing;
  perform pg_temp.turn('d27a6971-8010-5f92-9c5b-6887ae6aed68', '61b6424e-78ba-5288-9de4-c833f2c0a18d', 'Policajac', 'Dobar dan. Putujete li sa životinjom?', 'Добрий день. Ви подорожуєте з твариною?', 1);
  perform pg_temp.turn('5c0e4b49-de04-5d8a-989d-a375520a0694', '61b6424e-78ba-5288-9de4-c833f2c0a18d', 'Daša', 'Da, sa psom. Evo njegove putovnice za kućne ljubimce.', 'Так, із собакою. Ось його паспорт домашньої тварини.', 2);
  perform pg_temp.turn('5383db6f-ab32-5af2-9f71-a36b97045c8f', '61b6424e-78ba-5288-9de4-c833f2c0a18d', 'Policajac', 'Je li čipiran?', 'Він чипований?', 3);
  perform pg_temp.turn('7c463d55-dfb9-562b-b769-3b5829bb5162', '61b6424e-78ba-5288-9de4-c833f2c0a18d', 'Daša', 'Jest, i cijepljen je protiv bjesnoće.', 'Так, і щеплений від сказу.', 4);
  perform pg_temp.turn('97ff18dc-9211-5a09-b240-30ceff033f1a', '61b6424e-78ba-5288-9de4-c833f2c0a18d', 'Policajac', 'Kada je bilo cijepljenje?', 'Коли було щеплення?', 5);
  perform pg_temp.turn('d65050de-6e3a-59d6-8da8-46c8b76d9aed', '61b6424e-78ba-5288-9de4-c833f2c0a18d', 'Daša', 'Prije dva mjeseca. Imam i veterinarsku potvrdu.', 'Два місяці тому. Ще в мене є ветеринарна довідка.', 6);
  perform pg_temp.turn('e39ac499-cd08-5042-99d3-77bbe01313c5', '61b6424e-78ba-5288-9de4-c833f2c0a18d', 'Policajac', 'U redu, sretan put!', 'Гаразд, щасливої дороги!', 7);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5ec87a2b-dc8a-55bb-a249-ede71dd6ba04', v_lesson, 'Житло із собакою', 'Smještaj sa psom', 2422, 'A0', 'border', 'PUBLISHED', 'claude_curriculum_a0_pets') on conflict (id) do nothing;
  perform pg_temp.turn('a6ae88e6-a65a-5597-8a77-509f4585174d', '5ec87a2b-dc8a-55bb-a249-ede71dd6ba04', 'Darja', 'Dobar dan, imate li slobodan apartman za vikend?', 'Добрий день, у вас є вільні апартаменти на вихідні?', 1);
  perform pg_temp.turn('ac51d237-07f2-523f-aa8a-69a7570c2ceb', '5ec87a2b-dc8a-55bb-a249-ede71dd6ba04', 'Domaćica', 'Imamo. Koliko osoba?', 'Є. На скільки осіб?', 2);
  perform pg_temp.turn('4637335a-282d-5f7e-9331-dcbd0586f99e', '5ec87a2b-dc8a-55bb-a249-ede71dd6ba04', 'Darja', 'Dvije osobe i jedan mali pas. Je li to problem?', 'Дві особи й маленький собака. Це проблема?', 3);
  perform pg_temp.turn('69c17a9d-3154-5cc9-8bf8-156ebf32e455', '5ec87a2b-dc8a-55bb-a249-ede71dd6ba04', 'Domaćica', 'Nije. Psi su dobrodošli, ali je doplata pet eura po noći.', 'Ні. Собакам раді, але доплата п’ять євро за ніч.', 4);
  perform pg_temp.turn('76e695e2-116e-5101-a9af-48005d784755', '5ec87a2b-dc8a-55bb-a249-ede71dd6ba04', 'Darja', 'Može. Gdje je najbliža plaža za pse?', 'Добре. Де найближчий пляж для собак?', 5);
  perform pg_temp.turn('8b6e2483-7216-5237-bf93-bdb0b63da9a8', '5ec87a2b-dc8a-55bb-a249-ede71dd6ba04', 'Domaćica', 'Deset minuta pješice. Tamo pas smije bez povodca.', 'Десять хвилин пішки. Там собаці можна без повідця.', 6);
  perform pg_temp.turn('5b7b7e28-3e68-563f-a727-1fa828d793b7', '5ec87a2b-dc8a-55bb-a249-ede71dd6ba04', 'Darja', 'Odlično, hvala!', 'Чудово, дякую!', 7);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок модуля A0.6 «Kućni ljubimci» за схемою уроків за темою (curriculum_a0_v4: 20–25 слів, 2 діалоги, 15 вправ) + письмо й переказ, за рішенням власника 2026-11-17. Потрібна перевірка носієм.');
end $$;

-- A0.6 · урок 43: Притулок і загублена тварина — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := 'aaf6ad60-560f-5720-9a19-24398989dd00';
  v_lesson constant uuid := '0a9c3362-e49a-5e17-bb46-9f3a345b67e4';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A0.6: місце 7 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Цей, той, он той: ovaj, taj, onaj' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Цей, той, он той: ovaj, taj, onaj»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 43: Притулок і загублена тварина', 'Lekcija 43: Sklonište i izgubljena životinja', '["Запитати про тварин у притулку", "Розповісти, що ви загубили чи знайшли тварину", "Описати тварину: самець чи самка, вік, характер"]'::jsonb, 15, 'PUBLISHED', 7);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'sklonište za životinje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udomiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udomljavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'napušten', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lutalica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izgubljen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'novi dom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zbrinuti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udomitelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'boks', v_pos);
  v_pos := pg_temp.word(v_lesson, 'privremeni smještaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pronađen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobrovoljac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nahraniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zalutati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ženka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mužjak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plašljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šansa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prepoznati', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '99e62bd0-6abe-571f-a739-02d6388d659d', 'fill_in_the_blank', 'Želim udomiti ___ psa, a ne onog.', 'ovog', '["ova", "ovo", "ovaj", "ovog"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8ca2e13f-e4b0-5706-bf08-8caa0cc933a0', 'multiple_choice', 'Що означає «zalutati»?', 'заблукати', '["нагодувати", "заблукати", "впізнати", "знайдений"]'::jsonb, 'A0', 2, 'PUBLISHED', 'zalutati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '850328b0-e955-5bcd-b535-d8e47b2b60d7', 'multiple_choice', 'Що означає «dobrovoljac»?', 'доброволець', '["нагодувати", "доброволець", "самець", "новий господар (тварини з притулку)"]'::jsonb, 'A0', 3, 'PUBLISHED', 'dobrovoljac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ecb96111-6347-5c41-a15d-b841298e6932', 'multiple_choice', 'Що означає «udomiti»?', 'взяти тварину з притулку; прихистити', '["самка", "взяти тварину з притулку; прихистити", "доброволець", "безпритульна тварина"]'::jsonb, 'A0', 4, 'PUBLISHED', 'udomiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '00f72fa6-d195-5988-880e-55e216f4060d', 'multiple_choice', 'Як хорватською «нагодувати»?', 'nahraniti', '["izgubljen", "udomljavanje", "nahraniti", "ženka"]'::jsonb, 'A0', 5, 'PUBLISHED', 'nahraniti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cf8d3b64-8a7a-5a47-aa91-a1dac0ffe75b', 'multiple_choice', 'Як хорватською «вольєр»?', 'boks', '["plašljiv", "boks", "izgubljen", "mužjak"]'::jsonb, 'A0', 6, 'PUBLISHED', 'boks', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '03e75370-f19d-58bb-9551-b7521c8bb2fb', 'type_answer', 'Напишіть хорватською: «безпритульна тварина»', 'lutalica', null, 'A0', 7, 'PUBLISHED', 'lutalica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b26268ff-eebb-54fb-a8c9-821b2472235a', 'type_answer', 'Напишіть хорватською: «загублений»', 'izgubljen', null, 'A0', 8, 'PUBLISHED', 'izgubljen', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8114cf93-92a5-5fa6-83de-7079f485f8f7', 'type_answer', 'Напишіть хорватською: «самець»', 'mužjak', null, 'A0', 9, 'PUBLISHED', 'mužjak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '41921c6d-8f66-54f5-8657-b40af8d43127', 'sentence_builder', 'Цей собака загубився.', 'Ovaj pas je izgubljen.', '["Ovaj", "izgubljen.", "pas", "je"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7e0937f1-223b-5050-af7d-f800cc57dfec', 'sentence_builder', 'Ми хочемо взяти кішку з притулку.', 'Želimo udomiti mačku.', '["Želimo", "mačku.", "udomiti"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bfe6f728-126a-5c04-a49c-adb45d5b32f8', 'listening', 'Прослухайте і складіть фразу', 'Ovaj crni je mužjak, ima tri godine.', '["ima", "mužjak,", "Ovaj", "tri", "godine.", "je", "crni"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '82aaa2da-f59d-5e83-af63-db18da0fb837', 'listening', 'Прослухайте і складіть фразу', 'Je li imao ogrlicu?', '["li", "ogrlicu?", "imao", "Je"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a3a260b-90c4-5a4f-a4c9-a95a7c2367d9', 'speaking', 'Ми хочемо взяти собаку з притулку.', 'Želimo udomiti psa.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a3674a6f-27a4-5a20-93c2-a18a2c582a8c', 'speaking', 'Ви не бачили цього собаки?', 'Jeste li vidjeli ovog psa?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '34213505-a2d3-5c40-9fd1-c9e0ab3d022f', 'write_message', 'Ви знайшли на вулиці собаку без власника. Напишіть у чат району: де знайшли, який він, і попросіть власника зателефонувати.', 'Našla sam psa u parku! Mali je i crni. Vlasniče, nazovite me!', 'A0', 'PUBLISHED', '{"situation_ua": "Ви знайшли на вулиці собаку без власника. Напишіть у чат району: де знайшли, який він, і попросіть власника зателефонувати.", "points": [{"ua": "ви знайшли собаку", "keys": [["našl", "ps"], ["našao", "ps"], ["pronađen"]]}, {"ua": "який він", "keys": [["mal"], ["velik"], ["crn"], ["bijel"], ["smeđ"], ["siv"]]}, {"ua": "власник, зателефонуйте", "keys": [["vlasni"]]}], "hints": ["našla sam psa", "mali", "crni", "vlasnik", "nazovite me"], "models": ["Našla sam psa u parku! Mali je i crni. Vlasniče, nazovite me!", "Pronađen pas kod škole! Velik je i bijel. Neka me vlasnik nazove."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '34213505-a2d3-5c40-9fd1-c9e0ab3d022f', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_pets 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) у новому уроці модуля A0.6. Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '7ac4a985-56c5-53d9-9e90-bbb5a9f21b62', 'mediation', 'Друг не знає хорватської. Перекажіть йому українською головне.', 'Загубився собака на ім’я Бруно. Він маленький, коричневий, із червоним нашийником. Тому, хто знайде, обіцяють винагороду.', 'A0', 'PUBLISHED', '{"situation_ua": "Друг не знає хорватської. Перекажіть йому українською головне.", "friend_ua": "Що тут написано?", "direction": "hr_ua", "points": [{"ua": "загубився собака Бруно", "keys": [["загуб", "бруно"]]}, {"ua": "маленький, коричневий", "keys": [["коричнев"], ["малень"]]}, {"ua": "є винагорода", "keys": [["винагород"], ["нагород"]]}], "hints": [], "models": ["Загубився собака на ім’я Бруно. Він маленький, коричневий, із червоним нашийником. Тому, хто знайде, обіцяють винагороду."], "source_hr": "IZGUBLJEN PAS!\nIme: Bruno. Mali, smeđi, s crvenom ogrlicom.\nNagrada za pronalazača! Tel. 098 123 456"}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '7ac4a985-56c5-53d9-9e90-bbb5a9f21b62', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_pets 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) у новому уроці модуля A0.6. Бета, потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5d4e2e45-212b-58b2-8599-3da0d7de91fa', v_lesson, 'У притулку', 'U skloništu', 2431, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_pets') on conflict (id) do nothing;
  perform pg_temp.turn('610fbc2b-b815-5dc7-bca8-079e11046c7f', '5d4e2e45-212b-58b2-8599-3da0d7de91fa', 'Daša', 'Dobar dan! Želimo udomiti psa.', 'Добрий день! Ми хочемо взяти собаку з притулку.', 1);
  perform pg_temp.turn('ce465f2f-5472-5ecc-8a8d-8cbccb230c65', '5d4e2e45-212b-58b2-8599-3da0d7de91fa', 'Volonterka', 'Divno! Ovaj crni je mužjak, ima tri godine.', 'Чудово! Цей чорний — самець, йому три роки.', 2);
  perform pg_temp.turn('80440659-599f-5192-ad3f-b725b3fc5e69', '5d4e2e45-212b-58b2-8599-3da0d7de91fa', 'Daša', 'A onaj mali u boksu?', 'А он той маленький у вольєрі?', 3);
  perform pg_temp.turn('ea5a82f9-33f2-519d-ba21-515d6e6200d1', '5d4e2e45-212b-58b2-8599-3da0d7de91fa', 'Volonterka', 'To je ženka, Bela. Bila je lutalica, pa je malo plašljiva.', 'Це самка, Бела. Вона була безпритульною, тож трохи полохлива.', 4);
  perform pg_temp.turn('3dabab3b-5091-55c0-b5a3-310a1c6019e7', '5d4e2e45-212b-58b2-8599-3da0d7de91fa', 'Daša', 'Jadna! Smijemo li je prošetati?', 'Бідолашна! Можна нам її вигуляти?', 5);
  perform pg_temp.turn('468a8614-dcd3-56e7-a87b-07c4251ca365', '5d4e2e45-212b-58b2-8599-3da0d7de91fa', 'Volonterka', 'Naravno. Ako vam se svidi, Bela dobiva novi dom.', 'Звісно. Якщо вона вам сподобається, Бела отримає новий дім.', 6);
  perform pg_temp.turn('bc653d7f-9dd2-58c3-88d1-e132732d4a13', '5d4e2e45-212b-58b2-8599-3da0d7de91fa', 'Daša', 'Svaki pas zaslužuje drugu šansu.', 'Кожен собака заслуговує на другий шанс.', 7);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2bcd46a0-dbf4-592c-bfb5-da3b9b1150da', v_lesson, 'Загублений собака', 'Izgubljeni pas', 2432, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_pets') on conflict (id) do nothing;
  perform pg_temp.turn('4d110ec8-a970-5814-9455-c3f9624d631f', '2bcd46a0-dbf4-592c-bfb5-da3b9b1150da', 'Darja', 'Susjede, jeste li vidjeli ovog psa? Izgubljen je.', 'Сусіде, ви не бачили цього собаки? Він загубився.', 1);
  perform pg_temp.turn('b2b79ed4-aa43-5b0e-93b4-7e1df7929666', '2bcd46a0-dbf4-592c-bfb5-da3b9b1150da', 'Susjed', 'Mislim da jesam. Jutros je jedan pas zalutao u naše dvorište.', 'Здається, бачив. Сьогодні вранці якийсь собака заблукав у наше подвір’я.', 2);
  perform pg_temp.turn('40df87de-3b09-509c-b198-41711d9ea453', '2bcd46a0-dbf4-592c-bfb5-da3b9b1150da', 'Darja', 'Stvarno? Je li imao ogrlicu?', 'Справді? На ньому був нашийник?', 3);
  perform pg_temp.turn('1e7a9f85-ee5a-56c1-97e7-a8f950e108f0', '2bcd46a0-dbf4-592c-bfb5-da3b9b1150da', 'Susjed', 'Imao je. Nahranio sam ga i nazvao sklonište za životinje.', 'Був. Я його нагодував і подзвонив у притулок для тварин.', 4);
  perform pg_temp.turn('d2325306-079f-5537-be8d-554d191b4034', '2bcd46a0-dbf4-592c-bfb5-da3b9b1150da', 'Darja', 'Hvala vam! Je li sada u skloništu?', 'Дякую вам! Він зараз у притулку?', 5);
  perform pg_temp.turn('dd8979fe-1fb3-5de2-be09-50bad941b072', '2bcd46a0-dbf4-592c-bfb5-da3b9b1150da', 'Susjed', 'Da, tamo je na sigurnom. Pronađeni psi čekaju vlasnika.', 'Так, там він у безпеці. Знайдені собаки чекають на власника.', 6);
  perform pg_temp.turn('c942f825-b55b-539b-8c59-df6f2f2cd6b5', '2bcd46a0-dbf4-592c-bfb5-da3b9b1150da', 'Darja', 'Idem odmah! Moj Bruno će me sigurno prepoznati.', 'Іду негайно! Мій Бруно мене точно впізнає.', 7);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок модуля A0.6 «Kućni ljubimci» за схемою уроків за темою (curriculum_a0_v4: 20–25 слів, 2 діалоги, 15 вправ) + письмо й переказ, за рішенням власника 2026-11-17. Потрібна перевірка носієм.');
end $$;

-- 5. Урок 37 «Домашні тварини»: новий другий діалог і нова вправа «Прослухайте» з нього
do $$
declare
  v_lesson constant uuid := '40b9da1d-1686-5b78-8317-0439067d5f8e';
  v_conv constant uuid := 'e9f0f3fa-76e4-53ff-bdf4-cf066b44096c';
  v_old_ex constant uuid := 'fcca6bae-5d7c-5a25-82ad-f868a53dc5f4';
  v_new_ex constant uuid := '90f9e5d0-4dac-5570-b8ab-b6eb4ce35937';
  v_payload jsonb;
begin
  if exists (select 1 from public.conversations where id = v_conv) then return; end if;  -- уже зроблено
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise' and item_id = v_old_ex) then
    raise exception 'В уроці 37 немає вправи «Je li cijepljen?» — звірте базу';
  end if;
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'a0_pets: новий другий діалог і вправа «Прослухайте» — стара версія');
  insert into backup.lesson_items_a0pets_20261117 select li.* from public.lesson_items li where li.lesson_id = v_lesson and li.item_id = v_old_ex
  on conflict (id) do nothing;
  -- старий діалог «Kod veterinara» — застарілий (не видаляється)
  update public.conversations set status = 'DEPRECATED' where id = '0e3f3dab-4cd9-5f9c-a4f5-7a1525c83f38' and status = 'PUBLISHED';
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  -- source — як в інших діалогів уроку 37 (урок програми curriculum_a0_v4); звідки діалог — у content_reviews
  values (v_conv, v_lesson, 'Кого візьмемо?', 'Koga ćemo uzeti?', 2372, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4');
  perform pg_temp.turn('4bf3a273-4fed-5559-b5b3-3632d8722f0a', v_conv, 'Darja', 'Dašo, djeca žele kućnog ljubimca. Što misliš?', 'Дашо, діти хочуть домашнього улюбленця. Що думаєш?', 1);
  perform pg_temp.turn('daf6a4e3-23f0-53e7-86c5-1c1af7617a36', v_conv, 'Daša', 'Može, ali koga? Psa ili mačku?', 'Можна, але кого? Собаку чи кішку?', 2);
  perform pg_temp.turn('0b33c978-0747-50c4-8865-a78cb61c1b55', v_conv, 'Darja', 'Psa treba šetati svaki dan, a mi radimo cijeli dan.', 'Собаку треба вигулювати щодня, а ми працюємо цілий день.', 3);
  perform pg_temp.turn('9319aba1-cf40-5b1f-88a3-f62afb848a98', v_conv, 'Daša', 'Onda mače? Ili hrčka, on je mali.', 'Тоді кошеня? Або хом’ячка, він маленький.', 4);
  perform pg_temp.turn('ac4f2b73-878e-5650-b491-1eeb601bdd01', v_conv, 'Darja', 'Ne znam, Marko je alergičan na dlaku.', 'Не знаю, у Марка алергія на шерсть.', 5);
  perform pg_temp.turn('13d5a233-fd7f-5d60-b934-e81ee21117e8', v_conv, 'Daša', 'Onda kornjača ili ribica! One nemaju dlaku.', 'Тоді черепаха або рибка! У них немає шерсті.', 6);
  -- нова вправа «Прослухайте і складіть фразу» на місці старої
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  select v_new_ex, 'listening', 'Прослухайте і складіть фразу', 'Onda kornjača ili ribica!', '["Onda", "ili", "ribica!", "kornjača"]'::jsonb, 'A0', e.order_index, 'PUBLISHED'
    from public.exercises e where e.id = v_old_ex
  on conflict (id) do nothing;
  update public.lesson_items set item_id = v_new_ex where lesson_id = v_lesson and item_type = 'exercise' and item_id = v_old_ex;
  update public.exercises e set status = 'DEPRECATED' where e.id = v_old_ex and e.status = 'PUBLISHED'
     and not exists (select 1 from public.lesson_items x where x.item_type = 'exercise' and x.item_id = e.id);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_pets 20261117: урок перенесено в модуль A0.6; другий діалог «Kod veterinara» замінено на «Koga ćemo uzeti?» (ветеринар — окремий урок модуля), вправу «Прослухайте» — з нового діалогу.');
end $$;

-- 6. Наскрізні номери всіх уроків A0 («Урок N: …» / «Lekcija N: …»); стара назва — у content_versions;
--    порядок діалогів уроків v4 (2000 + N·10 + k) — за новим номером
do $$
declare r record; v_payload jsonb; v_new_ua text; v_new_hr text;
begin
  for r in select l.id, l.title_ua, l.title_hr,
                  row_number() over (order by m.order_index, u.order_index, l.order_index) as n
             from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
            where m.level_code = 'A0' and l.status = 'PUBLISHED' loop
    update public.conversations set order_index = 2000 + r.n * 10 + order_index % 10
     where lesson_id = r.id and order_index between 2000 and 2999 and order_index / 10 <> 200 + r.n;
    v_new_ua := regexp_replace(r.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':');
    v_new_hr := regexp_replace(r.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':');
    if v_new_ua is not distinct from r.title_ua and v_new_hr is not distinct from r.title_hr then continue; end if;
    select to_jsonb(l) into v_payload from public.lessons l where l.id = r.id;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'a0_pets: новий номер уроку ' || r.n || ' (новий модуль A0.6)');
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_lex int;
begin
  -- 11 модулів A0 на місцях 1–11, номер у назві = місце; у новому модулі — 7 уроків (37–43)
  select count(*) into v_bad from public.modules
   where level_code = 'A0' and (title_ua !~ ('^Модуль A0\.' || order_index || ' ') or coalesce(title_hr, '') !~ ('^Modul A0\.' || order_index || ' '));
  if v_bad > 0 or (select count(*) from public.modules where level_code = 'A0') <> 11
     or (select max(order_index) from public.modules where level_code = 'A0') <> 11 then
    raise exception 'Модулі A0: очікувалось 11 на місцях 1–11 з правильними назвами (помилок %)', v_bad;
  end if;
  if (select count(*) from public.lessons l join public.units u on u.id = l.unit_id where u.module_id = 'fd6730dd-07aa-590d-b7db-c639e3ed3919' and l.status = 'PUBLISHED') <> 7
     or (select order_index from public.lessons where id = '40b9da1d-1686-5b78-8317-0439067d5f8e') <> 1 then
    raise exception 'Модуль A0.6: очікувалось 7 уроків, урок 37 — першим';
  end if;
  -- нові уроки: 20–25 слів, 2 діалоги по 6–8 реплік, 15 вправ + письмо й переказ
  select count(*) into v_bad from public.lessons l
   where l.id in ('64ad8ee5-741e-54e5-b31d-88f1130e3f3e', '5c421c03-f070-538e-b152-8c50b31f4daf', 'fa7fd153-275f-5214-b759-2db31e50a4b4', '5ffbe419-6abc-574e-907e-2dc427276abd', 'd3008969-de66-509c-a2d4-88987322edb5', '0a9c3362-e49a-5e17-bb46-9f3a345b67e4')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or exists (select 1 from public.conversations c where c.lesson_id = l.id
                      and (select count(*) from public.conversation_turns t where t.conversation_id = c.id) not between 6 and 8)
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and li.required) <> 15
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and not li.required
                 and e.exercise_type in ('write_message', 'mediation')) <> 2);
  if v_bad > 0 then raise exception 'Нові уроки: % з неправильним складом', v_bad; end if;
  -- урок 37: 2 опубліковані діалоги, новий — «Koga ćemo uzeti?»
  if (select count(*) from public.conversations where lesson_id = '40b9da1d-1686-5b78-8317-0439067d5f8e' and status = 'PUBLISHED') <> 2
     or not exists (select 1 from public.conversations where id = 'e9f0f3fa-76e4-53ff-bdf4-cf066b44096c' and status = 'PUBLISHED') then
    raise exception 'Урок 37: діалоги не замінено';
  end if;
  -- наскрізна нумерація A0: 1…72 без пропусків
  if (select count(*) from public.lessons where level_code = 'A0' and status = 'PUBLISHED') <> 72
     or exists (select 1 from (select l.title_ua, row_number() over (order by m.order_index, u.order_index, l.order_index) n
                                 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                                where m.level_code = 'A0' and l.status = 'PUBLISHED') t
                 where t.title_ua !~ ('^Урок ' || t.n || ':')) then
    raise exception 'Уроки A0: очікувалось 72 з номерами 1…72';
  end if;
  -- нові слова: опубліковані, з мітками
  select count(*) into v_lex from public.lexemes where lower(lemma) in ('brnjica', 'park za pse', 'počistiti', 'loptica', 'pasmina', 'mješanac', 'njušiti', 'mahati', 'gristi', 'pseći', 'pas vodič', 'zabranjen', 'dozvoljen', 'daj šapu', 'naredba', 'povesti', 'trgovina za kućne ljubimce', 'zavezati', 'mačak', 'maca', 'mic mic', 'presti', 'mijaukati', 'kandža', 'krzno', 'loviti', 'grebalica', 'ogrebati', 'lizati', 'umiljat', 'prugast', 'zaštitna mreža', 'mačji', 'klupko', 'sklupčati se', 'veterinarska ambulanta', 'čip', 'krpelj', 'parazit', 'kastrirati', 'sterilizirati', 'vaga', 'otrov', 'apetit', 'što mu je', 'šepati', 'zaštitni ovratnik', 'dežurni veterinar', 'cijepljen', 'podrezati', 'nokat', 'mirno', 'farma', 'tele', 'magarac', 'janje', 'pijetao', 'guska', 'štala', 'sijeno', 'trava', 'musti', 'jahati', 'mukati', 'putovnica za kućne ljubimce', 'bjesnoća', 'veterinarska potvrda', 'transporter', 'plaža za pse', 'doplata', 'pansion za pse', 'sigurnosni pojas', 'aviokompanija', 'sredstvo za smirenje', 'ograničenje', 'čipiran', 'zrakoplov', 'europska unija', 'najmanje', 'noćiti', 'granična policija', 'dobrodošao', 'pojilica', 'sklonište za životinje', 'udomiti', 'udomljavanje', 'napušten', 'lutalica', 'izgubljen', 'novi dom', 'zbrinuti', 'udomitelj', 'boks', 'privremeni smještaj', 'pronađen', 'dobrovoljac', 'nahraniti', 'zalutati', 'ženka', 'mužjak') and status = 'PUBLISHED'
     and register is not null and regionality is not null and usage_tags is not null;
  if v_lex <> 100 then raise exception 'Нових слів: % (очікувалось 100)', v_lex; end if;
  if exists (select 1 from public.lexemes where lower(lemma) in ('pustiti', 'oprez', 'opasan', 'bojati se', 'skočiti', 'pobjeći', 'sakriti se', 'operacija', 'čokolada', 'protiv', 'krava', 'konj', 'ovca', 'koza', 'svinja', 'kokoš', 'patka', 'seljak', 'livada', 'dopustiti', 'plašljiv', 'šansa', 'prepoznati') and status = 'PUBLISHED'
              and cefr <> 'A0') then
    raise exception 'Наявні слова модуля — не рівня A0';
  end if;
  -- тексти для читання A0 — за своїм модулем (модуль A0.6 поки без текстів)
  if exists (select 1 from public.reading_texts where cefr = 'A0' and module_order = 6) then
    raise exception 'Тексти A0 не зсунуто за модулями';
  end if;
  raise notice 'Готово: 20261117_a0_pets_module.sql — модуль A0.6 «Kućni ljubimci» (7 уроків), 100 нових слів, уроків A0 — 72';
end $$;

commit;
