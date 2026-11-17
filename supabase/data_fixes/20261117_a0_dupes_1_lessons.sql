-- =====================================================================
-- Дублі A0 · 2026-11-17 (план «Дублі й сенс уроків A0–A2», PR 2б)
-- Згенеровано: python3 -B scripts/gen_a0_dupes.py (не редагуйте вручну).
--
-- Рішення власника 2026-11-17: Д12 (варіант Б) — урок 68 «У лікаря й в аптеці» → «У лікаря» (68) і новий «В аптеці» (69);
-- Д4 (урок 64), Д9 (58), Д10 (30), Д11 (69 → 70); назва діалогу уроку 26. Уроків A0 72 → 73.
--   * Нові слова: 25 (з мітками), наявні — 7 (рівень → A0). Прибрані з A0 слова, які вчать в A1 (8), —
--     рівень A1 (A1-24, A1-96, A1-97); kabina, probati, pristajati — в A1-24 (там їх ще не було).
--   * Слово в уроці — заміна на тому самому місці; вправи на прибрані слова й діалоги — нові на тому самому місці.
--   * Нічого не видаляється: старі діалоги й вправи → DEPRECATED; копія складу уроків — backup.lesson_items_a0dupes_20261117;
--     старі версії уроків і діалогу — у content_versions. Прогрес користувачів не змінюється.
--   * Далі за назвою: 20261117_a0_dupes_2_reading.sql (тексти A0.6), 20261117_a0_dupes_3_tests.sql (перевірки).
--   * Повторний запуск нічого не змінює. Бета: PUBLISHED.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: 20261117_a0_dupes_1_lessons.sql — …».
-- =====================================================================

begin;

-- 0. Копія складу уроків до змін (схема backup без доступу для anon / authenticated)
create schema if not exists backup;
create table if not exists backup.lesson_items_a0dupes_20261117 (like public.lesson_items including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'lesson_items_a0dupes_20261117_pkey') then
    alter table backup.lesson_items_a0dupes_20261117 add constraint lesson_items_a0dupes_20261117_pkey primary key (id);
  end if;
end $$;
revoke all on backup.lesson_items_a0dupes_20261117 from anon, authenticated;

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

-- слово уроку: заміна на тому самому місці (рядок lesson_items той самий — змінюється лише слово)
create or replace function pg_temp.swap_word(p_lesson uuid, p_old text, p_new text) returns void language plpgsql as $f$
declare v_new uuid; v_n int;
begin
  select id into v_new from public.lexemes where lower(lemma) = lower(p_new) and status = 'PUBLISHED' order by created_at limit 1;
  if v_new is null then raise exception 'Немає опублікованого слова «%»', p_new; end if;
  update public.lesson_items set item_id = v_new
   where lesson_id = p_lesson and item_type = 'lexeme' and item_id in (select id from public.lexemes where lower(lemma) = lower(p_old));
  get diagnostics v_n = row_count;
  if v_n <> 1 then raise exception 'Слово «%» в уроці: % рядків замість 1 — звірте базу', p_old, v_n; end if;
end $f$;

-- вправа: нова на місці старої (той самий тип і місце); стара — DEPRECATED, якщо більше ніде не використовується
create or replace function pg_temp.swap_ex(p_lesson uuid, p_old uuid, p_new uuid, p_type text, p_question text, p_answer text,
                                           p_options jsonb, p_lemma text, p_task jsonb) returns void language plpgsql as $f$
declare v_lex uuid; v_n int;
begin
  if p_lemma is not null then
    select id into v_lex from public.lexemes where lower(lemma) = lower(p_lemma) and status = 'PUBLISHED' order by created_at limit 1;
    if v_lex is null then raise exception 'Немає опублікованого слова «%»', p_lemma; end if;
  end if;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id, task)
  select p_new, p_type, p_question, p_answer, p_options, e.level, e.order_index, 'PUBLISHED', v_lex, p_task
    from public.exercises e where e.id = p_old and e.exercise_type = p_type
  on conflict (id) do nothing;
  update public.lesson_items set item_id = p_new where lesson_id = p_lesson and item_type = 'exercise' and item_id = p_old;
  get diagnostics v_n = row_count;
  if v_n <> 1 or not exists (select 1 from public.exercises where id = p_new) then
    raise exception 'Вправу % в уроці не замінено — звірте базу', p_old;
  end if;
  update public.exercises e set status = 'DEPRECATED' where e.id = p_old and e.status = 'PUBLISHED'
     and not exists (select 1 from public.lesson_items x where x.item_type = 'exercise' and x.item_id = e.id);
end $f$;

-- копія складу уроку до змін і стара версія уроку (разом з опублікованими діалогами) — у content_versions
create or replace function pg_temp.snapshot_lesson(p_lesson uuid, p_reason text) returns void language plpgsql as $f$
begin
  insert into backup.lesson_items_a0dupes_20261117 select li.* from public.lesson_items li where li.lesson_id = p_lesson on conflict (id) do nothing;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'lesson', l.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = l.id), 0) + 1,
         jsonb_build_object('lesson', to_jsonb(l),
           'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = l.id),
           'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c
                              where c.lesson_id = l.id and c.status = 'PUBLISHED')), p_reason
    from public.lessons l where l.id = p_lesson;
end $f$;

-- 1. Нові слова (25): PUBLISHED (бета), з мітками; наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples,
                            register, regionality, usage_tags, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A0', t.ua, t.vtype, t.forms, t.examples,
       t.register, t.regionality, array(select jsonb_array_elements_text(t.usage_tags)), 'PUBLISHED', 'claude_curriculum_a0_dupes'
  from jsonb_to_recordset('[{"lemma": "hvala na čestitki", "normalized": "hvala na cestitki", "pos": "phrase", "ua": "дякую за привітання", "vtype": "formulaic", "forms": {}, "examples": ["Hvala na čestitki, Dašo! Baš si draga."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "poželjeti", "normalized": "pozeljeti", "pos": "verb", "ua": "побажати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "željeti"}, "examples": ["Svi su mi poželjeli sretan rođendan."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "zaželjeti želju", "normalized": "zazeljeti zelju", "pos": "phrase", "ua": "загадати бажання", "vtype": "formulaic", "forms": {}, "examples": ["Ugasi svjećice i zaželi želju!"], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "obući", "normalized": "obuci", "pos": "verb", "ua": "одягнути, вдягнути", "vtype": "core", "forms": {"aspect": "pfv", "pair": "oblačiti"}, "examples": ["Što ćeš obući na vjenčanje?"], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "izlog", "normalized": "izlog", "pos": "noun", "ua": "вітрина", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ona crvena haljina u izlogu je jako lijepa."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "bluza", "normalized": "bluza", "pos": "noun", "ua": "блузка", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Kupila sam bijelu bluzu za posao."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "donje rublje", "normalized": "donje rublje", "pos": "phrase", "ua": "нижня білизна", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Donje rublje je na drugom katu."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "sljedeća stanica", "normalized": "sljedeca stanica", "pos": "phrase", "ua": "наступна зупинка", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Sljedeća stanica je Glavni kolodvor."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "automat za karte", "normalized": "automat za karte", "pos": "phrase", "ua": "квитковий автомат", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Kartu možete kupiti na automatu za karte."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "slobodno mjesto", "normalized": "slobodno mjesto", "pos": "phrase", "ua": "вільне місце", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["U tramvaju nema nijednog slobodnog mjesta."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "dežurni liječnik", "normalized": "dezurni lijecnik", "pos": "phrase", "ua": "черговий лікар", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Subotom u domu zdravlja radi dežurni liječnik."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "ostati u krevetu", "normalized": "ostati u krevetu", "pos": "phrase", "ua": "залишатися в ліжку, лежати (коли хворий)", "vtype": "chunk", "forms": {}, "examples": ["Liječnica kaže da trebam ostati u krevetu dva dana."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "tekućina", "normalized": "tekucina", "pos": "noun", "ua": "рідина", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Kad imate temperaturu, pijte puno tekućine."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "ljekarnica", "normalized": "ljekarnica", "pos": "noun", "ua": "фармацевтка (жінка-провізор)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ljekarnica mi je objasnila kako uzimati lijek."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "na recept", "normalized": "na recept", "pos": "phrase", "ua": "за рецептом", "vtype": "chunk", "forms": {}, "examples": ["Ovaj lijek možete kupiti samo na recept."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "dežurna ljekarna", "normalized": "dezurna ljekarna", "pos": "phrase", "ua": "чергова аптека", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Noću radi samo dežurna ljekarna."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "paracetamol", "normalized": "paracetamol", "pos": "noun", "ua": "парацетамол", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Za temperaturu uzmite paracetamol."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "tablete za grlo", "normalized": "tablete za grlo", "pos": "phrase", "ua": "таблетки для горла", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Kupila sam tablete za grlo bez šećera."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "grlobolja", "normalized": "grlobolja", "pos": "noun", "ua": "біль у горлі", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Imam grlobolju i teško govorim."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "uputa", "normalized": "uputa", "pos": "noun", "ua": "інструкція (до ліків)", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Prije uzimanja lijeka pročitajte uputu."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "za djecu", "normalized": "za djecu", "pos": "phrase", "ua": "для дітей", "vtype": "chunk", "forms": {}, "examples": ["Imate li sirup za djecu?"], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "dječji", "normalized": "djecji", "pos": "adjective", "ua": "дитячий", "vtype": "core", "forms": {}, "examples": ["Trebam dječji sirup protiv kašlja."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "maska", "normalized": "maska", "pos": "noun", "ua": "маска", "vtype": "core", "forms": {"gender": "f"}, "examples": ["U ljekarni možete kupiti masku za lice."], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "sve zajedno", "normalized": "sve zajedno", "pos": "phrase", "ua": "усе разом", "vtype": "formulaic", "forms": {}, "examples": ["Koliko košta sve zajedno?"], "register": "standard", "regionality": "general", "usage_tags": []}, {"lemma": "zovite vatrogasce", "normalized": "zovite vatrogasce", "pos": "phrase", "ua": "викликайте пожежників", "vtype": "formulaic", "forms": {}, "examples": ["Kuća gori, zovite vatrogasce!"], "register": "standard", "regionality": "general", "usage_tags": []}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb, register text, regionality text, usage_tags jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 1а. Наявні слова, які вперше вчать в уроках A0 (7): рівень слова — A0; стара версія — у content_versions
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) in ('odijelo', 'glavobolja', 'bolest', 'slab', 'jak', 'izmjeriti', 'sredstvo') and status = 'PUBLISHED' and cefr is distinct from 'A0' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'a0_dupes: рівень слова A0 — його вперше вчать в уроці A0 — стара версія');
    update public.lexemes set cefr = 'A0', version = version + 1 where id = r.id;
  end loop;
end $$;

-- 1б. Прибрані з уроків A0 слова, які вчать в A1 (8; kabina, probati, pristajati — тепер в A1-24): рівень — A1; стара версія — у content_versions
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) in ('neradni dan', 'pisanica', 'dan državnosti', 'probati', 'kabina', 'pristajati', 'prevelik', 'premalen') and status = 'PUBLISHED' and cefr is distinct from 'A1' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'a0_dupes: рівень слова A1 — в уроках A0 його більше немає, його вчать в A1 — стара версія');
    update public.lexemes set cefr = 'A1', version = version + 1 where id = r.id;
  end loop;
end $$;

-- 2. Новий урок 69 «В аптеці» (A0.11, місце 4): 20 слів, 2 діалоги, 15 вправ + письмо й переказ; наступні уроки модуля — на місце далі
do $$
declare
  v_unit constant uuid := '7c5becd1-c264-59f4-972e-fd095492d394';
  v_lesson constant uuid := 'a4455f67-27c7-5ad7-a454-771a94ca4e02';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if (select title_ua from public.lessons where id = 'fbc71f82-e715-5bab-a990-b8542fb0fe01') not like 'Урок 68:%'
     or (select count(*) from public.lessons where unit_id = v_unit and status = 'PUBLISHED') <> 7 then
    raise exception 'Модуль A0.11: очікувалось 7 уроків і урок 68 «У лікаря й в аптеці» — звірте базу';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Ввічливість: ti і Vi' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Ввічливість: ti і Vi»'; end if;
  -- місця 4–7 → 5–8 через 100+ (unique (unit_id, order_index))
  update public.lessons set order_index = order_index + 100 where unit_id = v_unit and order_index >= 4;
  update public.lessons set order_index = order_index - 99 where unit_id = v_unit and order_index > 100;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 69: В аптеці', 'Lekcija 69: U ljekarni', '["Купити ліки в аптеці: lijek, tableta, sirup, protiv bolova", "Запитати, чи потрібен рецепт, і зрозуміти інструкцію", "Знайти чергову аптеку вночі й купити щось для дитини"]'::jsonb, 15, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'ljekarna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljekarnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'recept', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lijek', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tableta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sirup', v_pos);
  v_pos := pg_temp.word(v_lesson, 'protiv bolova', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dnevno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljekarnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na recept', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dežurna ljekarna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'paracetamol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tablete za grlo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grlobolja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uputa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'za djecu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dječji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maska', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sve zajedno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sredstvo', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ca7e8ad1-2d82-53d6-a77f-e593e5dfe70a', 'fill_in_the_blank', 'Gospođo, ___ li recept?', 'imate', '["ima", "imate", "imam", "imaš"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f2422342-71ed-53ce-8848-a61e1e1bb96d', 'multiple_choice', 'Що означає «dežurna ljekarna»?', 'чергова аптека', '["біль у горлі", "інструкція (до ліків)", "чергова аптека", "дитячий"]'::jsonb, 'A0', 2, 'PUBLISHED', 'dežurna ljekarna', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2e761429-c9aa-51c7-a436-8a7d7027e288', 'multiple_choice', 'Що означає «ljekarna»?', 'аптека', '["усе разом", "рецепт", "ліки / медикамент", "аптека"]'::jsonb, 'A0', 3, 'PUBLISHED', 'ljekarna', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8dfc3b8-dcad-5a67-a67f-e6d6e743dfef', 'multiple_choice', 'Що означає «tableta»?', 'таблетка', '["маска", "дитячий", "таблетка", "щодня; на день"]'::jsonb, 'A0', 4, 'PUBLISHED', 'tableta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4fc74308-d2a1-5b0a-ba5b-e04893bb78f7', 'multiple_choice', 'Як хорватською «біль у горлі»?', 'grlobolja', '["ljekarnica", "na recept", "grlobolja", "maska"]'::jsonb, 'A0', 5, 'PUBLISHED', 'grlobolja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b7e0ace1-66ea-548d-974e-d9d52012aa5f', 'multiple_choice', 'Як хорватською «сироп»?', 'sirup', '["ljekarnica", "sirup", "paracetamol", "uputa"]'::jsonb, 'A0', 6, 'PUBLISHED', 'sirup', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ccca4015-b331-50ab-99a1-0dfcc85544da', 'type_answer', 'Напишіть хорватською: «інструкція (до ліків)»', 'uputa', null, 'A0', 7, 'PUBLISHED', 'uputa', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a042bfdd-e5fa-553e-8691-678a9111a236', 'type_answer', 'Напишіть хорватською: «від болю (знеболювальне)»', 'protiv bolova', null, 'A0', 8, 'PUBLISHED', 'protiv bolova', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '57f91eb8-901d-5f61-b479-967f1f79b9f1', 'type_answer', 'Напишіть хорватською: «рецепт»', 'recept', null, 'A0', 9, 'PUBLISHED', 'recept', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '60f298c3-122a-5bcf-bc82-b2ebca5f9bf6', 'sentence_builder', 'Де чергова аптека?', 'Gdje je dežurna ljekarna?', '["je", "Gdje", "dežurna", "ljekarna?"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b7d5828f-3bfb-51ce-a988-2eee818c4463', 'sentence_builder', 'Мені потрібні таблетки від болю.', 'Trebam tablete protiv bolova.', '["Trebam", "protiv", "tablete", "bolova."]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f75d1d16-a39d-5efe-a568-54deecb05e61', 'listening', 'Прослухайте і складіть фразу', 'Imate li i nešto protiv bolova?', '["protiv", "li", "i", "bolova?", "nešto", "Imate"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e1a060ba-f34e-5ecf-a276-0924ad1250e0', 'listening', 'Прослухайте і складіть фразу', 'Imamo dječji sirup s paracetamolom.', '["s", "paracetamolom.", "Imamo", "dječji", "sirup"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cace280e-4e30-5711-996d-ee2d57c72b7d', 'speaking', 'Де найближча аптека?', 'Gdje je najbliža ljekarna?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ed12fa0e-995c-5ab4-91c6-29b9b12a131c', 'speaking', 'Цей сироп продають за рецептом?', 'Je li ovaj sirup na recept?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '4aa8af49-1e54-5744-a579-32764ebaa430', 'write_message', 'Дар’я пише в чаті: «Idem u ljekarnu. Trebaš li nešto?» Відповідайте: так, купи, будь ласка, таблетки від болю й дитячий сироп.', 'Da, molim te, kupi tablete protiv bolova i dječji sirup.', 'A0', 'PUBLISHED', '{"situation_ua": "Дар’я пише в чаті: «Idem u ljekarnu. Trebaš li nešto?» Відповідайте: так, купи, будь ласка, таблетки від болю й дитячий сироп.", "points": [{"ua": "таблетки від болю", "keys": [["tablet", "bolov"], ["lijek", "bolov"], ["paracetamol"]]}, {"ua": "дитячий сироп", "keys": [["sirup"]]}], "hints": ["molim te", "kupi", "tablete", "protiv bolova", "dječji sirup"], "models": ["Da, molim te, kupi tablete protiv bolova i dječji sirup.", "Trebam lijek protiv bolova i sirup za djecu. Hvala!"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '4aa8af49-1e54-5744-a579-32764ebaa430', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_dupes 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) — новий урок «В аптеці». Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '25488edf-9175-57c5-9b1b-1c2175d4614d', 'mediation', 'Друг не знає хорватської. Перекажіть йому українською головне.', 'Так, це чергова аптека, вона відчинена цілодобово. Уночі треба подзвонити в дзвінок.', 'A0', 'PUBLISHED', '{"situation_ua": "Друг не знає хорватської. Перекажіть йому українською головне.", "friend_ua": "Що тут написано? Аптека відчинена вночі?", "direction": "hr_ua", "points": [{"ua": "працює цілодобово", "keys": [["цілодоб"], ["24"]]}, {"ua": "уночі треба подзвонити", "keys": [["дзвін"], ["дзвон"], ["подзвон"]]}], "hints": [], "models": ["Так, це чергова аптека, вона відчинена цілодобово. Уночі треба подзвонити в дзвінок."], "source_hr": "DEŽURNA LJEKARNA\nOtvoreno 0 – 24 h\nNoću pozvonite na zvono."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '25488edf-9175-57c5-9b1b-1c2175d4614d', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_dupes 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) — новий урок «В аптеці». Бета, потрібна перевірка носієм.');
  -- діалог 1 «U ljekarni» — з уроку 68 (той самий запис, лише інший урок)
  update public.conversations set lesson_id = v_lesson, order_index = 2691 where id = '1e4899ae-60f8-5de7-91fb-9517b913cbda' and status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «U ljekarni» уроку 68 — звірте базу'; end if;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  -- source — як в інших діалогів уроків A0 за темою (програма curriculum_a0_v4); звідки діалог — у content_reviews
  values ('905ef41c-64b3-55cf-8d4f-705679d7acf8', v_lesson, 'Чергова аптека', 'Dežurna ljekarna', 2692, 'A0', 'health', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('28f1945c-c214-5467-8353-e1ce1dceecc9', '905ef41c-64b3-55cf-8d4f-705679d7acf8', 'Daša', 'Dobra večer. Je li ovo dežurna ljekarna?', 'Добрий вечір. Це чергова аптека?', 1);
  perform pg_temp.turn('4605fe42-1b9c-5326-b05b-b0f7afdc5f33', '905ef41c-64b3-55cf-8d4f-705679d7acf8', 'Ljekarnica', 'Jest, izvolite. Što trebate?', 'Так, прошу. Що вам потрібно?', 2);
  perform pg_temp.turn('0e55d5f4-e294-50c8-b26b-6b3c030cd492', '905ef41c-64b3-55cf-8d4f-705679d7acf8', 'Daša', 'Kći ima grlobolju i temperaturu. Imate li nešto za djecu?', 'У доньки болить горло й температура. У вас є щось для дітей?', 3);
  perform pg_temp.turn('00a61926-9c0d-59cc-90a4-02151f09890a', '905ef41c-64b3-55cf-8d4f-705679d7acf8', 'Ljekarnica', 'Imamo dječji sirup s paracetamolom. Nije na recept, ali prije uzimanja pročitajte uputu.', 'Є дитячий сироп з парацетамолом. Він без рецепта, але перед прийомом прочитайте інструкцію.', 4);
  perform pg_temp.turn('971eb56b-ea8f-5ed4-834b-d574554216ad', '905ef41c-64b3-55cf-8d4f-705679d7acf8', 'Daša', 'Dobro. I tablete za grlo, molim. Koliko je sve zajedno?', 'Добре. І таблетки для горла, будь ласка. Скільки все разом?', 5);
  perform pg_temp.turn('ebc9b601-001c-5036-ab9c-b185b003b3ec', '905ef41c-64b3-55cf-8d4f-705679d7acf8', 'Ljekarnica', 'Dvanaest eura. Neka kći brzo ozdravi!', 'Дванадцять євро. Хай донька швидко одужує!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок «В аптеці» (A0-62 «У лікаря й в аптеці» → два уроки, рішення власника 2026-11-17, Д12) за схемою уроків за темою (curriculum_a0_v4: 20–25 слів, 2 діалоги, 15 вправ) + письмо й переказ. Потрібна перевірка носієм.');
end $$;

-- 3. Урок 30: урок «Свята й привітання» — лише привітання (Д10)
do $$
declare
  v_lesson constant uuid := 'd7cf3059-0d92-5215-8ef4-ad699e317b10';
begin
  if exists (select 1 from public.conversations where id = 'b94fcb8f-1649-5cd5-9f2c-ffcb4577e160') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a0_dupes: урок «Свята й привітання» — лише привітання (Д10) — стара версія');
  perform pg_temp.swap_word(v_lesson, 'neradni dan', 'hvala na čestitki');
  perform pg_temp.swap_word(v_lesson, 'pisanica', 'poželjeti');
  perform pg_temp.swap_word(v_lesson, 'Dan državnosti', 'zaželjeti želju');
  perform pg_temp.swap_ex(v_lesson, '0b7251fa-6cec-5a20-bcab-fa08134cae63', '3585123e-d881-5589-9f67-75a4ebbec614', 'type_answer', 'Напишіть хорватською: «побажати»', 'poželjeti', null, 'poželjeti', null);
  perform pg_temp.swap_ex(v_lesson, 'af2b831a-2579-5412-946d-35bdc93e93f4', 'cfd9e468-1c8f-5049-8b92-f2167fb2948a', 'listening', 'Прослухайте і складіть фразу', 'A sad zaželi želju!', '["sad", "zaželi", "želju!", "A"]'::jsonb, null, null);
  -- діалог «Prije Božića» → «Sretan rođendan, Dašo!» (старий — DEPRECATED, не видаляється)
  update public.conversations set status = 'DEPRECATED' where id = '131ad945-b721-555a-9dcd-bb89a6d97acd' and status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Prije Božića» — звірте базу'; end if;
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  -- source — як в інших діалогів уроку (програма curriculum_a0_v4); звідки діалог — у content_reviews
  values ('b94fcb8f-1649-5cd5-9f2c-ffcb4577e160', v_lesson, 'З днем народження, Дашо!', 'Sretan rođendan, Dašo!', 2301, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4');
  perform pg_temp.turn('0a3f8544-b4ac-5db2-8f10-95e0c30dfb5f', 'b94fcb8f-1649-5cd5-9f2c-ffcb4577e160', 'Ivana', 'Sretan rođendan, Dašo! Sve najbolje!', 'З днем народження, Дашо! Всього найкращого!', 1);
  perform pg_temp.turn('2b36fbf9-7669-56b8-8ea8-77274a900002', 'b94fcb8f-1649-5cd5-9f2c-ffcb4577e160', 'Daša', 'Hvala, Ivana! Uđi, torta je na stolu.', 'Дякую, Івано! Заходь, торт на столі.', 2);
  perform pg_temp.turn('d902f6ac-cda6-55a5-8158-4cbceb361f4e', 'b94fcb8f-1649-5cd5-9f2c-ffcb4577e160', 'Ivana', 'Evo, mali poklon za tebe. Želim ti puno sreće!', 'Ось маленький подарунок для тебе. Бажаю тобі багато щастя!', 3);
  perform pg_temp.turn('c9480a5b-e176-5f96-bbeb-851eec9d2ed3', 'b94fcb8f-1649-5cd5-9f2c-ffcb4577e160', 'Daša', 'Kako lijepo! Hvala na čestitki i na poklonu.', 'Як гарно! Дякую за привітання й за подарунок.', 4);
  perform pg_temp.turn('4597cf37-d3fd-54e1-9aa4-f0f6b1faeafe', 'b94fcb8f-1649-5cd5-9f2c-ffcb4577e160', 'Ivana', 'A sad zaželi želju!', 'А тепер загадай бажання!', 5);
  perform pg_temp.turn('209731c5-e55c-5989-80de-b0622c203a73', 'b94fcb8f-1649-5cd5-9f2c-ffcb4577e160', 'Daša', 'Već sam je zaželjela. Ali to je tajna!', 'Я вже загадала. Але це таємниця!', 6);
  update public.lessons set objectives = '["Назвати головні свята в Хорватії: Božić, Uskrs, Nova godina", "Привітати зі святом і з днем народження: Sretan Božić! Sve najbolje!", "Подякувати за привітання й побажати щось: hvala na čestitki, želim ti…"]'::jsonb where id = v_lesson;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_dupes 20261117: план «Дублі й сенс уроків» (PR 2б, рішення власника 2026-11-17) — урок «Свята й привітання» — лише привітання (Д10). Бета, потрібна перевірка носієм.');
end $$;

-- 3. Урок 58: урок «Одяг: що купити?» без приміряльні (Д9)
do $$
declare
  v_lesson constant uuid := 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0';
begin
  if exists (select 1 from public.conversations where id = '4f4b48e8-c309-5b8e-9098-67cfc15dbf87') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a0_dupes: урок «Одяг: що купити?» без приміряльні (Д9) — стара версія');
  perform pg_temp.swap_word(v_lesson, 'probati', 'obući');
  perform pg_temp.swap_word(v_lesson, 'kabina', 'izlog');
  perform pg_temp.swap_word(v_lesson, 'pristajati', 'bluza');
  perform pg_temp.swap_word(v_lesson, 'prevelik', 'odijelo');
  perform pg_temp.swap_word(v_lesson, 'premalen', 'donje rublje');
  perform pg_temp.swap_ex(v_lesson, '991570fc-67e1-599f-8ddb-da6672d50ac4', 'd38340d0-8d06-5e0e-a12e-f91fe4853343', 'multiple_choice', 'Що означає «izlog»?', 'вітрина', '["сорочка", "спідниця", "вітрина", "пальто"]'::jsonb, 'izlog', null);
  perform pg_temp.swap_ex(v_lesson, '1b1fe6a6-bae8-5763-8d88-e54afb83d628', 'a81a6a8f-b8fe-5674-a943-2fbdf0bba278', 'sentence_builder', 'Складіть: «Мені подобається он та блузка у вітрині.»', 'Sviđa mi se ona bluza u izlogu.', '["bluza", "ona", "izlogu.", "u", "mi", "se", "Sviđa"]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, 'e98d25d4-2ce8-54ff-98e6-ba410e0c1d68', '7d35eb46-4897-59f6-b837-e992cd447dd6', 'sentence_builder', 'Складіть: «Що ти вдягнеш завтра?»', 'Što ćeš obući sutra?', '["ćeš", "Što", "sutra?", "obući"]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, 'abf12f34-afac-5e4c-9260-41e5a188acbd', 'a1d42dc2-8b37-5016-bba3-e6cc9ac79f94', 'listening', 'Прослухайте і складіть фразу', 'Ovu plavu haljinu i crne cipele.', '["i", "crne", "Ovu", "plavu", "haljinu", "cipele."]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, '0be9426c-c9ab-5095-b400-180edf5719d5', '169ebe56-26fc-594f-908a-f0bb5a242755', 'listening', 'Прослухайте і складіть фразу', 'Trebam čarape i topli džemper.', '["čarape", "topli", "i", "džemper.", "Trebam"]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, '616c94dd-8fc7-5ed2-8d6d-2ad7a2a8e8ea', 'd6321ff2-b5a3-5a58-a61d-1a42169a9f56', 'speaking', 'Скільки коштує ця блузка?', 'Koliko košta ova bluza?', null, null, null);
  perform pg_temp.swap_ex(v_lesson, '5b80e4bc-1303-59c1-b7b9-ee4e422aa340', '556fad9b-efe6-5fe8-9c44-d0804261fb27', 'speaking', 'Мені подобається той светр.', 'Sviđa mi se taj džemper.', null, null, null);
  perform pg_temp.swap_ex(v_lesson, 'bd8ef91a-3b57-5407-b4a3-de72cba81b5e', '2916688c-f645-55c6-9cd2-2d504a5ac483', 'write_message', 'Ви в торговому центрі. Напишіть Дар’ї в чат, що ви купили: білу блузку й теплий светр, а Маркові — костюм.', 'Kupila sam bijelu bluzu i topli džemper. Marku sam kupila odijelo.', null, null, '{"situation_ua": "Ви в торговому центрі. Напишіть Дар’ї в чат, що ви купили: білу блузку й теплий светр, а Маркові — костюм.", "points": [{"ua": "блузка", "keys": [["bluz"]]}, {"ua": "светр", "keys": [["džemper"]]}, {"ua": "костюм для Марка", "keys": [["odijel"]]}], "hints": ["kupila sam", "bluza", "džemper", "odijelo"], "models": ["Kupila sam bijelu bluzu i topli džemper. Marku sam kupila odijelo.", "Kupio sam bluzu i džemper, a za Marka odijelo."]}'::jsonb);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '2916688c-f645-55c6-9cd2-2d504a5ac483', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_dupes 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) — урок «Одяг: що купити?» без приміряльні (Д9). Бета, потрібна перевірка носієм.');
  perform pg_temp.swap_ex(v_lesson, '247c8973-1547-55bf-8a45-0feeb958ce29', 'ded5bc5f-6dc5-52bc-ba92-a1d31896d51a', 'mediation', 'Друг не знає хорватської. Перекажіть йому українською головне.', 'Так, на весь одяг знижка 30 %. Нижня білизна — на другому поверсі.', null, null, '{"situation_ua": "Друг не знає хорватської. Перекажіть йому українською головне.", "friend_ua": "Що тут написано? Є знижки?", "direction": "hr_ua", "points": [{"ua": "знижка 30 % на весь одяг", "keys": [["30"], ["знижк"]]}, {"ua": "білизна — на другому поверсі", "keys": [["білизн", "друг"]]}], "hints": [], "models": ["Так, на весь одяг знижка 30 %. Нижня білизна — на другому поверсі."], "source_hr": "SNIŽENJE!\nSva odjeća –30 %.\nDonje rublje je na drugom katu."}'::jsonb);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'ded5bc5f-6dc5-52bc-ba92-a1d31896d51a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_dupes 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) — урок «Одяг: що купити?» без приміряльні (Д9). Бета, потрібна перевірка носієм.');
  -- діалог «U trgovini odjećom» → «Ispred izloga» (старий — DEPRECATED, не видаляється)
  update public.conversations set status = 'DEPRECATED' where id = '0119ff02-cf85-577b-8109-b72609a0212e' and status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «U trgovini odjećom» — звірте базу'; end if;
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  -- source — як в інших діалогів уроку (програма curriculum_a0_v4); звідки діалог — у content_reviews
  values ('4f4b48e8-c309-5b8e-9098-67cfc15dbf87', v_lesson, 'Біля вітрини', 'Ispred izloga', 2581, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v4');
  perform pg_temp.turn('9178f8e1-704d-50d1-bee6-4aaa88c76b76', '4f4b48e8-c309-5b8e-9098-67cfc15dbf87', 'Darja', 'Dašo, vidi ovu bluzu u izlogu!', 'Дашо, глянь на цю блузку у вітрині!', 1);
  perform pg_temp.turn('5659bdce-9f45-5f30-b596-0eaa6e6458f6', '4f4b48e8-c309-5b8e-9098-67cfc15dbf87', 'Daša', 'Lijepa je! A sviđa li ti se ono odijelo?', 'Гарна! А тобі подобається он той костюм?', 2);
  perform pg_temp.turn('12b5dceb-4210-57a2-9032-469f5624ec23', '4f4b48e8-c309-5b8e-9098-67cfc15dbf87', 'Darja', 'Sviđa mi se. Marku treba odijelo za vjenčanje.', 'Подобається. Маркові потрібен костюм на весілля.', 3);
  perform pg_temp.turn('9136b842-2c48-5220-9f82-21796c3a2550', '4f4b48e8-c309-5b8e-9098-67cfc15dbf87', 'Daša', 'A što ćeš ti obući na vjenčanje?', 'А що вдягнеш ти на весілля?', 4);
  perform pg_temp.turn('0ffe4f82-7966-5b54-ad2e-4508d0c068d9', '4f4b48e8-c309-5b8e-9098-67cfc15dbf87', 'Darja', 'Ovu plavu haljinu i crne cipele.', 'Цю синю сукню й чорні туфлі.', 5);
  perform pg_temp.turn('9fab0bd0-a172-5791-b719-c0a446049eef', '4f4b48e8-c309-5b8e-9098-67cfc15dbf87', 'Daša', 'Super! Uđimo, imaju i donje rublje na popustu.', 'Чудово! Заходьмо, у них і нижня білизна зі знижкою.', 6);
  update public.lessons set objectives = '["Назвати одяг і взуття: majica, hlače, haljina, bluza, odijelo", "Показати, що купити: ovaj, taj, onaj («ova bluza», «ono odijelo»)", "Сказати, що ви вдягнете: «Što ćeš obući?»"]'::jsonb where id = v_lesson;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_dupes 20261117: план «Дублі й сенс уроків» (PR 2б, рішення власника 2026-11-17) — урок «Одяг: що купити?» без приміряльні (Д9). Бета, потрібна перевірка носієм.');
end $$;

-- 3. Урок 64: урок «Квиток на автобус» без проїзного й пересадки (Д4)
do $$
declare
  v_lesson constant uuid := 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b';
begin
  if exists (select 1 from public.conversations where id = 'e3b826c8-f59b-5bc5-b354-0a286eb4838f') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a0_dupes: урок «Квиток на автобус» без проїзного й пересадки (Д4) — стара версія');
  perform pg_temp.swap_word(v_lesson, 'mjesečna karta', 'sljedeća stanica');
  perform pg_temp.swap_word(v_lesson, 'presjesti', 'automat za karte');
  perform pg_temp.swap_word(v_lesson, 'kontrolor', 'slobodno mjesto');
  perform pg_temp.swap_ex(v_lesson, '6300f2dd-00f7-5c5c-a14a-606124597966', '1c4a195b-4364-5dd5-aa96-ca1e01956b15', 'multiple_choice', 'Як хорватською «наступна зупинка»?', 'sljedeća stanica', '["linija", "putnik", "sljedeća stanica", "peron"]'::jsonb, 'sljedeća stanica', null);
  perform pg_temp.swap_ex(v_lesson, '1623e661-c631-5c9a-9cb3-231bd642ead7', '85b131fd-e129-5f6e-aa2c-d249897bc575', 'listening', 'Прослухайте і складіть фразу', 'Koja je sljedeća stanica?', '["Koja", "sljedeća", "stanica?", "je"]'::jsonb, null, null);
  -- діалог «Kojim tramvajem?» → «Koja je sljedeća stanica?» (старий — DEPRECATED, не видаляється)
  update public.conversations set status = 'DEPRECATED' where id = 'd7497f57-33d8-51d1-bb45-c01cad0a2698' and status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «Kojim tramvajem?» — звірте базу'; end if;
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  -- source — як в інших діалогів уроку (програма curriculum_a0_v4); звідки діалог — у content_reviews
  values ('e3b826c8-f59b-5bc5-b354-0a286eb4838f', v_lesson, 'Яка наступна зупинка?', 'Koja je sljedeća stanica?', 2642, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_a0_v4');
  perform pg_temp.turn('a4695298-975f-537a-a64b-12e46c147493', 'e3b826c8-f59b-5bc5-b354-0a286eb4838f', 'Darja', 'Oprostite, je li ovo mjesto slobodno?', 'Перепрошую, це місце вільне?', 1);
  perform pg_temp.turn('229fec65-9e95-5884-8294-f75c4648de98', 'e3b826c8-f59b-5bc5-b354-0a286eb4838f', 'Gospođa', 'Jest, izvolite sjesti.', 'Так, сідайте.', 2);
  perform pg_temp.turn('b213def2-235d-56ec-95b5-10130209705d', 'e3b826c8-f59b-5bc5-b354-0a286eb4838f', 'Darja', 'Hvala. Koja je sljedeća stanica?', 'Дякую. Яка наступна зупинка?', 3);
  perform pg_temp.turn('23fd8834-503c-51b5-b382-75634667e319', 'e3b826c8-f59b-5bc5-b354-0a286eb4838f', 'Gospođa', 'Glavni kolodvor. Gdje vi izlazite?', 'Головний вокзал. А ви де виходите?', 4);
  perform pg_temp.turn('3f928e0a-e9f5-585f-bb22-5605c5a19982', 'e3b826c8-f59b-5bc5-b354-0a286eb4838f', 'Darja', 'Na kolodvoru. Kartu sam kupila na automatu.', 'На вокзалі. Квиток я купила в автоматі.', 5);
  perform pg_temp.turn('570e7250-af07-550f-8126-654b90d3688c', 'e3b826c8-f59b-5bc5-b354-0a286eb4838f', 'Gospođa', 'Onda izađite sada, evo stanice!', 'Тоді виходьте зараз, ось зупинка!', 6);
  update public.lessons set objectives = '["Купити квиток: povratna karta, karta u jednom smjeru, automat za karte", "Запитати, який автобус чи трамвай їде і де виходити", "Зрозуміти, з якого перону відправлення і яка наступна зупинка"]'::jsonb where id = v_lesson;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_dupes 20261117: план «Дублі й сенс уроків» (PR 2б, рішення власника 2026-11-17) — урок «Квиток на автобус» без проїзного й пересадки (Д4). Бета, потрібна перевірка носієм.');
end $$;

-- 3. Урок 68: урок «У лікаря й в аптеці» → «У лікаря» (Д12)
do $$
declare
  v_lesson constant uuid := 'fbc71f82-e715-5bab-a990-b8542fb0fe01';
begin
  if exists (select 1 from public.conversations where id = 'ea8c847f-01ba-523c-a989-9b6e824734c6') then return; end if;  -- уже зроблено
  if not exists (select 1 from public.lessons where id = 'a4455f67-27c7-5ad7-a454-771a94ca4e02') then raise exception 'Спершу — новий урок «В аптеці»'; end if;
  perform pg_temp.snapshot_lesson(v_lesson, 'a0_dupes: урок «У лікаря й в аптеці» → «У лікаря» (Д12) — стара версія');
  perform pg_temp.swap_word(v_lesson, 'ljekarna', 'glavobolja');
  perform pg_temp.swap_word(v_lesson, 'ljekarnik', 'bolest');
  perform pg_temp.swap_word(v_lesson, 'recept', 'slab');
  perform pg_temp.swap_word(v_lesson, 'lijek', 'jak');
  perform pg_temp.swap_word(v_lesson, 'tableta', 'izmjeriti');
  perform pg_temp.swap_word(v_lesson, 'sirup', 'dežurni liječnik');
  perform pg_temp.swap_word(v_lesson, 'protiv bolova', 'ostati u krevetu');
  perform pg_temp.swap_word(v_lesson, 'dnevno', 'tekućina');
  -- 8 слів аптеки — у новому уроці «В аптеці» (вище), тут на їхніх місцях — слова про лікаря
  perform pg_temp.swap_ex(v_lesson, 'f68a9298-6710-5236-8b44-c752a862f24e', '930dec19-305d-52c1-938e-b559eeecb44a', 'multiple_choice', 'Що означає «glavobolja»?', 'головний біль', '["головний біль", "поліклініка", "тиск", "кашель"]'::jsonb, 'glavobolja', null);
  perform pg_temp.swap_ex(v_lesson, '2073170a-ade8-5736-9461-d429a946c28e', '1377ce18-3b58-5fe1-afb3-24278714a8f1', 'multiple_choice', 'Як хорватською «рідина»?', 'tekućina', '["tlak", "uputnica", "tekućina", "gripa"]'::jsonb, 'tekućina', null);
  perform pg_temp.swap_ex(v_lesson, '0d8b677f-3a7a-5bbd-a48a-e098fa6a0715', '42e34ad5-1497-580e-ba44-5fb701e05e72', 'type_answer', 'Напишіть хорватською: «виміряти»', 'izmjeriti', null, 'izmjeriti', null);
  perform pg_temp.swap_ex(v_lesson, '6082b60d-3933-5cc2-9fa8-7dec0b7ef675', '982dd6e3-1a32-567a-8bb9-a835bf081f5c', 'listening', 'Прослухайте і складіть фразу', 'Ostanite u krevetu dva dana i pijte puno tekućine.', '["pijte", "puno", "i", "Ostanite", "dva", "krevetu", "u", "dana", "tekućine."]'::jsonb, null, null);
  perform pg_temp.swap_ex(v_lesson, '5f01a6d9-9e91-5eb6-909e-6c0669c7a8c8', 'a6782162-51f4-5279-a796-17a4c34ebdd2', 'speaking', 'У мене сильний головний біль.', 'Imam jaku glavobolju.', null, null, null);
  perform pg_temp.swap_ex(v_lesson, 'ec2766d8-b2e0-5011-8111-081f57370e09', '177abe64-8ed6-5ac0-9571-e2acfa5fa7ca', 'mediation', 'Друг не знає хорватської. Перекажіть йому українською головне.', 'Так, тут написано: черговий лікар працює в суботу й неділю з 8 до 20, вхід B.', null, null, '{"situation_ua": "Друг не знає хорватської. Перекажіть йому українською головне.", "friend_ua": "Що тут написано? Лікар працює у вихідні?", "direction": "hr_ua", "points": [{"ua": "черговий лікар", "keys": [["чергов"]]}, {"ua": "у суботу й неділю", "keys": [["субот"], ["неділ"], ["вихідн"]]}, {"ua": "з 8 до 20", "keys": [["8", "20"]]}], "hints": [], "models": ["Так, тут написано: черговий лікар працює в суботу й неділю з 8 до 20, вхід B."], "source_hr": "DEŽURNI LIJEČNIK\nSubota i nedjelja: 8 – 20 h\nUlaz B"}'::jsonb);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '177abe64-8ed6-5ac0-9571-e2acfa5fa7ca', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_dupes 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) — урок «У лікаря й в аптеці» → «У лікаря» (Д12). Бета, потрібна перевірка носієм.');
  -- новий другий діалог «Kod dežurnog liječnika» (на місці «U ljekarni», що перейшов в урок «В аптеці»)
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  -- source — як в інших діалогів уроку (програма curriculum_a0_v4); звідки діалог — у content_reviews
  values ('ea8c847f-01ba-523c-a989-9b6e824734c6', v_lesson, 'У чергового лікаря', 'Kod dežurnog liječnika', 2682, 'A0', 'health', 'PUBLISHED', 'claude_curriculum_a0_v4');
  perform pg_temp.turn('8e521abd-a275-538d-8fac-60a7934e278d', 'ea8c847f-01ba-523c-a989-9b6e824734c6', 'Liječnik', 'Dobra večer. Kako vam mogu pomoći?', 'Добрий вечір. Чим можу допомогти?', 1);
  perform pg_temp.turn('a67c3f13-f4d9-542d-a067-eb149a5532aa', 'ea8c847f-01ba-523c-a989-9b6e824734c6', 'Darja', 'Imam jaku glavobolju i osjećam se slabo.', 'У мене сильний головний біль, і я почуваюся слабкою.', 2);
  perform pg_temp.turn('f22d995f-a698-584d-9fb9-3fee708cea10', 'ea8c847f-01ba-523c-a989-9b6e824734c6', 'Liječnik', 'Sjednite, molim. Da vam izmjerim tlak i temperaturu.', 'Сідайте, будь ласка. Зараз виміряю вам тиск і температуру.', 3);
  perform pg_temp.turn('37e335ce-4a20-50a0-8238-82eb765cef69', 'ea8c847f-01ba-523c-a989-9b6e824734c6', 'Darja', 'Je li to nešto opasno?', 'Це щось небезпечне?', 4);
  perform pg_temp.turn('d9a12d64-3ade-5be5-b13d-b675462881d2', 'ea8c847f-01ba-523c-a989-9b6e824734c6', 'Liječnik', 'Nije, to je prehlada. Ostanite u krevetu dva dana i pijte puno tekućine.', 'Ні, це застуда. Полежте в ліжку два дні й пийте багато рідини.', 5);
  perform pg_temp.turn('98b84197-527d-532d-aa96-d974c6db4259', 'ea8c847f-01ba-523c-a989-9b6e824734c6', 'Darja', 'Hvala, doktore.', 'Дякую, лікарю.', 6);
  update public.lessons set title_ua = 'Урок 68: У лікаря', title_hr = 'Lekcija 68: Kod liječnika' where id = v_lesson;
  update public.lessons set objectives = '["Записатися до лікаря й розповісти про симптоми: imam temperaturu, kašalj, glavobolju", "Зрозуміти лікаря: pregled, uputnica, bolovanje, «ostanite u krevetu»", "Знайти чергового лікаря ввечері чи у вихідні"]'::jsonb where id = v_lesson;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_dupes 20261117: план «Дублі й сенс уроків» (PR 2б, рішення власника 2026-11-17) — урок «У лікаря й в аптеці» → «У лікаря» (Д12). Бета, потрібна перевірка носієм.');
end $$;

-- 3. Урок 69: урок «Допоможіть!» + «zovite vatrogasce» (Д11)
do $$
declare
  v_lesson constant uuid := '48f26e9d-96c5-5189-8ec6-db1f9d58e200';
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = 'zovite vatrogasce') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a0_dupes: урок «Допоможіть!» + «zovite vatrogasce» (Д11) — стара версія');
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill)
  select v_lesson, 'lexeme', (select id from public.lexemes where lower(lemma) = lower('zovite vatrogasce') and status = 'PUBLISHED' order by created_at limit 1),
         (select max(order_index) + 1 from public.lesson_items where lesson_id = v_lesson), 'vocabulary';
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_dupes 20261117: план «Дублі й сенс уроків» (PR 2б, рішення власника 2026-11-17) — урок «Допоможіть!» + «zovite vatrogasce» (Д11). Бета, потрібна перевірка носієм.');
end $$;

-- 4. A1-24 «У приміряльні»: + kabina, probati, pristajati (з уроку A0-58 — їх більше ніде немає)
do $$
declare v_lesson constant uuid := '7fb1b6e5-93b4-5776-b82b-25e7769fd32d'; w text;
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id
              where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = 'kabina') then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, 'a0_dupes: + kabina, probati, pristajati з уроку A0 «Одяг: що купити?» (Д9) — слова не зникають з курсу — стара версія');
  foreach w in array array['kabina', 'probati', 'pristajati'] loop
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill)
    select v_lesson, 'lexeme', (select id from public.lexemes where lower(lemma) = w and status = 'PUBLISHED' order by created_at limit 1),
           (select max(order_index) + 1 from public.lesson_items where lesson_id = v_lesson), 'vocabulary';
  end loop;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'a0_dupes 20261117: план «Дублі й сенс уроків» (PR 2б, рішення власника 2026-11-17) — kabina, probati, pristajati з уроку A0 «Одяг: що купити?» (Д9) — слова не зникають з курсу. Бета, потрібна перевірка носієм.');
end $$;

-- 5. Назва діалогу уроку 26 «Na kolodvoru» → «Vlak za Rijeku» (така сама назва — в уроці 7); стара — у content_versions
do $$
declare v_conv constant uuid := '31f40ede-635a-54e2-9a86-c6b199479205';
begin
  if (select title_hr from public.conversations where id = v_conv) = 'Vlak za Rijeku' then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a0_dupes: нова назва діалогу (така сама — в уроці 7) — стара версія'
    from public.conversations c where c.id = v_conv and c.title_hr = 'Na kolodvoru';
  if not found then raise exception 'Немає діалогу «Na kolodvoru» уроку 26 — звірте базу'; end if;
  update public.conversations set title_ua = 'Потяг до Рієки', title_hr = 'Vlak za Rijeku' where id = v_conv;
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
            v_payload, 'a0_dupes: новий номер уроку ' || r.n || ' (новий урок «В аптеці»)');
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_lex int;
begin
  -- уроки A0: 73, номери 1…73 без пропусків; у модулі A0.11 — 8 уроків, «В аптеці» — 69-й
  if (select count(*) from public.lessons where level_code = 'A0' and status = 'PUBLISHED') <> 73
     or exists (select 1 from (select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) n
                                 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                                where m.level_code = 'A0' and l.status = 'PUBLISHED') t
                 where t.title_ua !~ ('^Урок ' || t.n || ':') or t.title_hr !~ ('^Lekcija ' || t.n || ':')) then
    raise exception 'Уроки A0: очікувалось 73 з номерами 1…73';
  end if;
  if (select count(*) from public.lessons where unit_id = '7c5becd1-c264-59f4-972e-fd095492d394' and status = 'PUBLISHED') <> 8
     or (select title_ua from public.lessons where id = 'a4455f67-27c7-5ad7-a454-771a94ca4e02') <> 'Урок 69: В аптеці'
     or (select title_ua from public.lessons where id = 'fbc71f82-e715-5bab-a990-b8542fb0fe01') <> 'Урок 68: У лікаря'
     or (select title_ua from public.lessons where id = '48f26e9d-96c5-5189-8ec6-db1f9d58e200') <> 'Урок 70: Допоможіть!' then
    raise exception 'Модуль A0.11: очікувалось 8 уроків, 68 «У лікаря», 69 «В аптеці», 70 «Допоможіть!»';
  end if;
  -- змінені й новий уроки: 20–25 слів, 2 опубліковані діалоги по 5–8 реплік, 15 обов’язкових вправ (усі опубліковані) + письмо й переказ
  select count(*) into v_bad from public.lessons l
   where l.id in ('d7cf3059-0d92-5215-8ef4-ad699e317b10', 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0', 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b', 'fbc71f82-e715-5bab-a990-b8542fb0fe01', '48f26e9d-96c5-5189-8ec6-db1f9d58e200', 'a4455f67-27c7-5ad7-a454-771a94ca4e02')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or exists (select 1 from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED'
                      and (select count(*) from public.conversation_turns t where t.conversation_id = c.id) not between 5 and 8)
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and li.required) <> 15
          or exists (select 1 from public.lesson_items li join public.exercises e on e.id = li.item_id
                      where li.lesson_id = l.id and li.item_type = 'exercise' and e.status <> 'PUBLISHED')
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and not li.required
                 and e.exercise_type in ('write_message', 'mediation')) <> 2);
  if v_bad > 0 then raise exception 'Уроки пакета: % з неправильним складом', v_bad; end if;
  -- прибраних слів більше немає в уроках A0; kabina, probati, pristajati — в A1-24
  if exists (select 1 from public.lesson_items li join public.lessons l on l.id = li.lesson_id and l.level_code = 'A0' and l.status = 'PUBLISHED'
              join public.lexemes x on x.id = li.item_id where li.item_type = 'lexeme' and lower(x.lemma) in ('dan državnosti', 'kabina', 'kontrolor', 'mjesečna karta', 'neradni dan', 'pisanica', 'premalen', 'presjesti', 'prevelik', 'pristajati', 'probati')) then
    raise exception 'Прибрані слова ще в уроках A0';
  end if;
  if (select count(*) from public.lesson_items li join public.lexemes x on x.id = li.item_id
       where li.lesson_id = '7fb1b6e5-93b4-5776-b82b-25e7769fd32d' and li.item_type = 'lexeme' and lower(x.lemma) in ('kabina', 'probati', 'pristajati')) <> 3 then
    raise exception 'A1-24: немає слів з уроку A0-58';
  end if;
  -- нові слова: опубліковані, з мітками
  select count(*) into v_lex from public.lexemes where lower(lemma) in ('hvala na čestitki', 'poželjeti', 'zaželjeti želju', 'obući', 'izlog', 'bluza', 'donje rublje', 'sljedeća stanica', 'automat za karte', 'slobodno mjesto', 'dežurni liječnik', 'ostati u krevetu', 'tekućina', 'ljekarnica', 'na recept', 'dežurna ljekarna', 'paracetamol', 'tablete za grlo', 'grlobolja', 'uputa', 'za djecu', 'dječji', 'maska', 'sve zajedno', 'zovite vatrogasce') and status = 'PUBLISHED'
     and register is not null and regionality is not null and usage_tags is not null;
  if v_lex <> 25 then raise exception 'Нових слів: % (очікувалось 25)', v_lex; end if;
  if exists (select 1 from public.lexemes where lower(lemma) in ('odijelo', 'glavobolja', 'bolest', 'slab', 'jak', 'izmjeriti', 'sredstvo') and status = 'PUBLISHED' and cefr <> 'A0') then
    raise exception 'Наявні слова нових уроків — не рівня A0';
  end if;
  -- діалог уроку 26 — нова назва
  if (select title_hr from public.conversations where id = '31f40ede-635a-54e2-9a86-c6b199479205') <> 'Vlak za Rijeku' then
    raise exception 'Діалог уроку 26 не перейменовано';
  end if;
  raise notice 'Готово: 20261117_a0_dupes_1_lessons.sql — урок «В аптеці» (69), уроки 30, 58, 64, 68, 70 без дублів, 25 нових слів, уроків A0 — 73';
end $$;

commit;
