-- =====================================================================
-- Уроки A0 за темою · curriculum_a0_v4 · модуль A0.4 · 2026-10-19
-- Згенеровано: python3 scripts/gen_curriculum_a0_v4.py (не редагуйте вручну).
--
-- Рішення власника 2026-10-15: слова уроку — за темою уроку, 20–25 слів і виразів, діалоги під тему; бета (PUBLISHED).
--   * Уроки 24–30: 5 наявних перебудовано, 2 нових тематичних уроків. Слів у них: 154.
--     Кожен: 20–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 35.
--   * Нові теми граматики: «Погода: безособові речення».
--   * Новий порядок уроків у модулі; назви всіх уроків A0 перенумеровано підряд (разом 58).
--   * Стара версія кожного зміненого уроку — у content_versions; копія кроків — у backup.lesson_items_20261015;
--     старі вправи й діалоги → DEPRECATED (не видаляються).
--   * Усе в одній транзакції; безпечно запускати повторно (зроблене пропускається).
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

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

-- 1. Нові слова й вирази A0 (наявні не змінюються)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('radni dan', 'radni dan', 'hr', 'phrase', 'A0', 'робочий день', 'collocation', '{}'::jsonb, '["Subota mi je radni dan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jutros', 'jutros', 'hr', 'adverb', 'A0', 'сьогодні вранці', 'core', '{}'::jsonb, '["Jutros sam popila samo kavu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sinoć', 'sinoc', 'hr', 'adverb', 'A0', 'учора ввечері', 'core', '{}'::jsonb, '["Sinoć smo gledali film."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('noću', 'nocu', 'hr', 'adverb', 'A0', 'уночі', 'core', '{}'::jsonb, '["Noću je u našoj ulici jako tiho."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('u koliko sati', 'u koliko sati', 'hr', 'phrase', 'A0', 'о котрій (годині)?', 'chunk', '{}'::jsonb, '["U koliko sati počinje film?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('četvrt', 'cetvrt', 'hr', 'noun', 'A0', 'чверть', 'core', '{"gender": "f"}'::jsonb, '["Vlak kreće za četvrt sata."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('i pol', 'i pol', 'hr', 'phrase', 'A0', 'з половиною (šest i pol — пів на сьому)', 'chunk', '{}'::jsonb, '["Dođi u šest i pol."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sat vremena', 'sat vremena', 'hr', 'phrase', 'A0', 'година (скільки триває)', 'collocation', '{}'::jsonb, '["Čekam te već sat vremena."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zakasniti', 'zakasniti', 'hr', 'verb', 'A0', 'запізнитися', 'core', '{"aspect": "pf", "present": {"1s": "zakasnim", "2s": "zakasniš", "3s": "zakasni"}, "past": "zakasnio"}'::jsonb, '["Požuri, zakasnit ćemo na vlak!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('godišnje doba', 'godisnje doba', 'hr', 'phrase', 'A0', 'пора року', 'collocation', '{"gender": "n", "plural": "godišnja doba"}'::jsonb, '["Proljeće je moje omiljeno godišnje doba."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ljeti', 'ljeti', 'hr', 'adverb', 'A0', 'улітку', 'core', '{}'::jsonb, '["Ljeti je u Dalmaciji jako vruće."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zimi', 'zimi', 'hr', 'adverb', 'A0', 'узимку', 'core', '{}'::jsonb, '["Zimi u Gorskom kotaru često pada snijeg."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('u proljeće', 'u proljece', 'hr', 'phrase', 'A0', 'навесні', 'chunk', '{}'::jsonb, '["U proljeće je u parku puno cvijeća."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('na jesen', 'na jesen', 'hr', 'phrase', 'A0', 'восени', 'chunk', '{}'::jsonb, '["Na jesen beremo grožđe."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('koji je danas datum', 'koji je danas datum', 'hr', 'phrase', 'A0', 'яке сьогодні число?', 'chunk', '{}'::jsonb, '["Oprostite, koji je danas datum?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rok trajanja', 'rok trajanja', 'hr', 'phrase', 'A0', 'термін придатності', 'collocation', '{}'::jsonb, '["Provjeri rok trajanja na mlijeku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('produžiti', 'produziti', 'hr', 'verb', 'A0', 'продовжити (термін, документ)', 'core', '{"aspect": "pf", "present": {"1s": "produžim", "2s": "produžiš", "3s": "produži"}, "past": "produžio"}'::jsonb, '["Moram produžiti boravišnu dozvolu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('boravišna dozvola', 'boravisna dozvola', 'hr', 'phrase', 'A0', 'дозвіл на проживання; посвідка', 'collocation', '{"gender": "f"}'::jsonb, '["Boravišna dozvola vrijedi godinu dana."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('početkom', 'pocetkom', 'hr', 'adverb', 'A0', 'на початку (місяця, року)', 'core', '{}'::jsonb, '["Plaća stiže početkom mjeseca."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('krajem', 'krajem', 'hr', 'adverb', 'A0', 'наприкінці (тижня, місяця)', 'core', '{}'::jsonb, '["Krajem tjedna idemo na more."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('za tjedan dana', 'za tjedan dana', 'hr', 'phrase', 'A0', 'через тиждень', 'chunk', '{}'::jsonb, '["Vidimo se za tjedan dana."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ove godine', 'ove godine', 'hr', 'phrase', 'A0', 'цього року', 'chunk', '{}'::jsonb, '["Ove godine učim hrvatski."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prošle godine', 'prosle godine', 'hr', 'phrase', 'A0', 'торік; минулого року', 'chunk', '{}'::jsonb, '["Prošle godine smo došli u Hrvatsku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sljedeće godine', 'sljedece godine', 'hr', 'phrase', 'A0', 'наступного року', 'chunk', '{}'::jsonb, '["Sljedeće godine moj sin ide u školu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kakvo je vrijeme', 'kakvo je vrijeme', 'hr', 'phrase', 'A0', 'яка погода?', 'chunk', '{}'::jsonb, '["Kakvo je vrijeme u Zagrebu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sunčano', 'suncano', 'hr', 'adverb', 'A0', 'сонячно', 'core', '{}'::jsonb, '["Danas je sunčano i toplo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('oblačno', 'oblacno', 'hr', 'adverb', 'A0', 'хмарно', 'core', '{}'::jsonb, '["Jutros je bilo oblačno, a sada je sunčano."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pada kiša', 'pada kisa', 'hr', 'phrase', 'A0', 'іде дощ', 'chunk', '{}'::jsonb, '["Pada kiša, uzmi kišobran."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('koliko je stupnjeva', 'koliko je stupnjeva', 'hr', 'phrase', 'A0', 'скільки градусів?', 'chunk', '{}'::jsonb, '["Koliko je stupnjeva vani?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sretan Uskrs', 'sretan uskrs', 'hr', 'phrase', 'A0', 'з Великоднем!; щасливого Великодня', 'formulaic', '{}'::jsonb, '["Sretan Uskrs svima!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sretni blagdani', 'sretni blagdani', 'hr', 'phrase', 'A0', 'веселих свят!', 'formulaic', '{}'::jsonb, '["Sretni blagdani i sretna Nova godina!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Valentinovo', 'valentinovo', 'hr', 'noun', 'A0', 'День святого Валентина (14 лютого)', 'core', '{"gender": "n"}'::jsonb, '["Za Valentinovo smo išli na večeru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Majčin dan', 'majcin dan', 'hr', 'phrase', 'A0', 'День матері', 'collocation', '{}'::jsonb, '["Za Majčin dan djeca su mami nacrtala čestitku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sve najbolje', 'sve najbolje', 'hr', 'phrase', 'A0', 'всього найкращого', 'formulaic', '{}'::jsonb, '["Sve najbolje za rođendan!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('želim ti', 'zelim ti', 'hr', 'phrase', 'A0', 'бажаю тобі', 'chunk', '{}'::jsonb, '["Želim ti puno sreće na ispitu!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v4')
on conflict do nothing;

-- 1а. Нові теми граматики A0 (1)
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '8feb6432-33f0-5645-ad22-b4215fe3771f', 'A0', 'Погода: безособові речення', 'Vrijeme: bezlične rečenice', 'Як сказати про погоду: Hladno je. Pada kiša. Puše bura. Учора було, завтра буде.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Погода: безособові речення');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '926f184a-c82c-5b16-b090-8dcafbfb831b', '8feb6432-33f0-5645-ad22-b4215fe3771f', 'Холодно, тепло: прислівник + je', 'Про погоду кажуть без підмета, як і українською («холодно»), але хорватською потрібне «je»: Hladno je. Toplo je. Sunčano je. Слово vrijeme («погода») — середнього роду: Kakvo je vrijeme? Lijepo vrijeme.', 'Danas je hladno. · Vani je sunčano.', '[{"hr": "Danas je sunčano.", "ua": "Сьогодні сонячно."}, {"hr": "Vani je jako hladno.", "ua": "Надворі дуже холодно."}, {"hr": "Kakvo je vrijeme u Splitu?", "ua": "Яка погода в Спліті?"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '8feb6432-33f0-5645-ad22-b4215fe3771f')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'e366d9c9-171e-5c71-9508-a2ba63328c02', '8feb6432-33f0-5645-ad22-b4215fe3771f', 'Дощ «падає», вітер «дме»', 'Дощ і сніг «падають»: pada kiša, pada snijeg. Вітер «дме»: puše vjetar, puše bura, puše jugo.', 'Pada kiša. · Puše bura.', '[{"hr": "Pada kiša, uzmi kišobran.", "ua": "Іде дощ, візьми парасолю."}, {"hr": "Cijeli dan pada snijeg.", "ua": "Цілий день іде сніг."}, {"hr": "Danas puše jaka bura.", "ua": "Сьогодні дме сильна бура."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '8feb6432-33f0-5645-ad22-b4215fe3771f')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'd0e3b071-f1f2-5e89-8218-4f04ae51c464', '8feb6432-33f0-5645-ad22-b4215fe3771f', 'Було й буде: bilo je, bit će', 'Минуле — bilo je + слово про погоду: Jučer je bilo hladno. Майбутнє — bit će: Sutra će biti toplo. Bit će kiše — «буде дощ».', 'Jučer je bilo hladno. · Sutra će biti toplo.', '[{"hr": "Jučer je bilo oblačno.", "ua": "Учора було хмарно."}, {"hr": "Sutra će biti sunčano.", "ua": "Завтра буде сонячно."}, {"hr": "Sutra će puhati jugo.", "ua": "Завтра дутиме юго."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '8feb6432-33f0-5645-ad22-b4215fe3771f')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '8feb6432-33f0-5645-ad22-b4215fe3771f', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нова тема граматики A0 для уроків за темою (curriculum_a0_v4) за запитом власника 2026-10-19. Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '8feb6432-33f0-5645-ad22-b4215fe3771f')
  and not exists (select 1 from public.content_reviews where entity_id = '8feb6432-33f0-5645-ad22-b4215fe3771f' and notes = 'Бета: нова тема граматики A0 для уроків за темою (curriculum_a0_v4) за запитом власника 2026-10-19. Потрібна перевірка носієм.');

-- 2. Перебудова наявних уроків модуля A0.4
-- A0.4 · урок 24: Дні тижня — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '8e372ece-ae10-50ae-9cf3-07b52ef2f72d';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Дні тижня» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'aeb635f4-ad1d-5ed5-a4cb-7468bef06858') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a0_v4: урок перебудовано за темою — стара версія (слова, вправи, діалоги)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  -- новий склад уроку (тема граматики та сама)
  select grammar_topic_id into v_gid from public.lesson_grammar where lesson_id = v_lesson limit 1;
  if v_gid is null then select item_id into v_gid from public.lesson_items where lesson_id = v_lesson and item_type = 'grammar' limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 24: Дні тижня', title_hr = 'Lekcija 24: Dani u tjednu',
         objectives = '["Назвати дні тижня", "Сказати, коли ви працюєте і коли вільні: u subotu, u nedjelju", "Домовитися про запис на певний день"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'ponedjeljak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'utorak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srijeda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'četvrtak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'petak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'subota', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nedjelja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tjedan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vikend', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radni dan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slobodan dan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koji je danas dan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svaki dan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tjedno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sljedeći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prošli', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zauzet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slobodan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'termin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odmarati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obveza', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2fe82d84-56f6-58d8-b637-2ae72db40ae4', 'fill_in_the_blank', 'Vidimo se u ___!', 'subotu', '["subotom", "subota", "subote", "subotu"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '18ab024b-3cf3-55dd-8947-19baa2b7d447', 'multiple_choice', 'Що означає «zauzet»?', 'зайнятий', '["обов''язок; справа", "неділя", "вихідний день", "зайнятий"]'::jsonb, 'A0', 2, 'PUBLISHED', 'zauzet', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '79efe5f2-bdbf-545d-817a-451a340f6e83', 'multiple_choice', 'Що означає «radni dan»?', 'робочий день', '["тиждень", "кожного дня", "минулий", "робочий день"]'::jsonb, 'A0', 3, 'PUBLISHED', 'radni dan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e8eede20-17fe-5376-a777-455810f8c761', 'multiple_choice', 'Що означає «vikend»?', 'вихідні', '["субота", "вихідні", "щотижня; на тиждень", "робочий день"]'::jsonb, 'A0', 4, 'PUBLISHED', 'vikend', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f0498a4c-9bdd-5193-9f16-cf0480e44861', 'multiple_choice', 'Як хорватською «вівторок»?', 'utorak', '["svaki dan", "ponedjeljak", "utorak", "zauzet"]'::jsonb, 'A0', 5, 'PUBLISHED', 'utorak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c9d5ba42-bd42-5144-9c68-413319be5aef', 'multiple_choice', 'Як хорватською «неділя»?', 'nedjelja', '["odmarati se", "nedjelja", "svaki dan", "slobodan"]'::jsonb, 'A0', 6, 'PUBLISHED', 'nedjelja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7148193a-810a-5ec5-ba67-95bb316a19c2', 'type_answer', 'Напишіть хорватською: «середа»', 'srijeda', null, 'A0', 7, 'PUBLISHED', 'srijeda', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f6fd162c-6667-51e2-9a97-fb0ff97af02a', 'type_answer', 'Напишіть хорватською: «наступний»', 'sljedeći', null, 'A0', 8, 'PUBLISHED', 'sljedeći', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '355e3428-1d0c-5e8e-bb20-2ff2688f034e', 'type_answer', 'Напишіть хорватською: «минулий»', 'prošli', null, 'A0', 9, 'PUBLISHED', 'prošli', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bc33ae78-8b1e-5415-aaff-36a4a5aed9c3', 'sentence_builder', 'Складіть: «У суботу я працюю.»', 'U subotu radim.', '["radim.", "subotu", "U"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '504e82ae-3503-5188-a43a-27bffe1946ae', 'sentence_builder', 'Складіть: «Цього тижня я дуже зайнята.»', 'Ovaj tjedan sam jako zauzeta.', '["zauzeta.", "Ovaj", "tjedan", "sam", "jako"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3505e5dd-d121-5f9a-9ab8-3af6b73f7db7', 'listening', 'Прослухайте і складіть фразу', 'U subotu radim, ali u nedjelju sam slobodna.', '["sam", "radim,", "ali", "slobodna.", "u", "U", "subotu", "nedjelju"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '28d211db-b034-52d7-afc1-160650338095', 'listening', 'Прослухайте і складіть фразу', 'Imate li slobodan termin u četvrtak?', '["slobodan", "Imate", "u", "termin", "četvrtak?", "li"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a8e87b4-c191-5e68-a089-3feead38b952', 'speaking', 'Який сьогодні день?', 'Koji je danas dan?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '368665be-48b2-5b27-bc45-68da3ec18677', 'speaking', 'Побачимося в понеділок!', 'Vidimo se u ponedjeljak!', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('aeb635f4-ad1d-5ed5-a4cb-7468bef06858', v_lesson, 'Плани на вихідні', 'Planovi za vikend', 2241, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('cc7fada0-3400-5f93-8e14-3036f0ea0c85', 'aeb635f4-ad1d-5ed5-a4cb-7468bef06858', 'Luka', 'Dašo, imaš li plan za vikend?', 'Дашо, у тебе є план на вихідні?', 1);
  perform pg_temp.turn('ae67af7b-4e3c-5554-978d-3f6e4b14fafa', 'aeb635f4-ad1d-5ed5-a4cb-7468bef06858', 'Daša', 'U subotu radim, ali u nedjelju sam slobodna.', 'У суботу я працюю, але в неділю вільна.', 2);
  perform pg_temp.turn('bcec15cf-15dc-5436-b4c0-8804a5ee4328', 'aeb635f4-ad1d-5ed5-a4cb-7468bef06858', 'Luka', 'Super! Idemo u nedjelju na izlet?', 'Чудово! Поїдемо в неділю за місто?', 3);
  perform pg_temp.turn('b5aec70b-8a23-5a2f-b806-9aef59150b17', 'aeb635f4-ad1d-5ed5-a4cb-7468bef06858', 'Daša', 'Može! Ovaj tjedan imam puno obveza.', 'Можна! Цього тижня в мене багато справ.', 4);
  perform pg_temp.turn('6969272f-2ac6-523c-947c-9e9e690d77b9', 'aeb635f4-ad1d-5ed5-a4cb-7468bef06858', 'Luka', 'Onda se u nedjelju odmaramo. Dogovoreno!', 'Тоді в неділю відпочиваємо. Домовилися!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('db8a2ff8-6069-5255-9167-14fb1af52873', v_lesson, 'Запис до перукарні', 'Termin kod frizerke', 2242, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('999d04cb-0e96-5e64-998b-d2ecbb6e3cd6', 'db8a2ff8-6069-5255-9167-14fb1af52873', 'Frizerka', 'Salon Ivana, dobar dan!', 'Салон «Івана», добрий день!', 1);
  perform pg_temp.turn('6d9749f7-8468-5c29-b548-1abe993acc08', 'db8a2ff8-6069-5255-9167-14fb1af52873', 'Darja', 'Dobar dan! Imate li slobodan termin u četvrtak?', 'Добрий день! У вас є вільний час у четвер?', 2);
  perform pg_temp.turn('0dd5685a-95e7-5b0b-95b8-5aea54b3fd67', 'db8a2ff8-6069-5255-9167-14fb1af52873', 'Frizerka', 'Nažalost, u četvrtak sam zauzeta. Može u petak u deset?', 'На жаль, у четвер я зайнята. Можна в п’ятницю о десятій?', 3);
  perform pg_temp.turn('85b1f0ab-83d6-53c7-b9a5-1300749cf0f6', 'db8a2ff8-6069-5255-9167-14fb1af52873', 'Darja', 'U petak radim. A sljedeći ponedjeljak?', 'У п’ятницю я працюю. А наступного понеділка?', 4);
  perform pg_temp.turn('1353fe39-034c-5abc-b5d6-c80cf9249186', 'db8a2ff8-6069-5255-9167-14fb1af52873', 'Frizerka', 'Sljedeći ponedjeljak u devet imam slobodan termin.', 'Наступного понеділка о дев’ятій у мене є вільний час.', 5);
  perform pg_temp.turn('640a9dd6-1448-59f3-a277-8e94f648f9c9', 'db8a2ff8-6069-5255-9167-14fb1af52873', 'Darja', 'Odlično, vidimo se u ponedjeljak!', 'Чудово, побачимося в понеділок!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.4 · урок 25: Учора, сьогодні, завтра — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '238d9508-3c2e-5ee6-910f-0ae8863c2dc7';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Учора, сьогодні, завтра» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '041facd6-6950-5e78-a640-8648ff480c5e') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a0_v4: урок перебудовано за темою — стара версія (слова, вправи, діалоги)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  -- новий склад уроку (тема граматики та сама)
  select grammar_topic_id into v_gid from public.lesson_grammar where lesson_id = v_lesson limit 1;
  if v_gid is null then select item_id into v_gid from public.lesson_items where lesson_id = v_lesson and item_type = 'grammar' limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 25: Учора, сьогодні, завтра', title_hr = 'Lekcija 25: Jučer, danas, sutra',
         objectives = '["Вживати jučer, danas, sutra, prekjučer, prekosutra", "Назвати частину дня: ujutro, poslijepodne, navečer, noću", "Сказати, коли щось було чи буде: jutros, sinoć, večeras"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'jučer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'danas', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sutra', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prekjučer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prekosutra', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jutros', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sinoć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'večeras', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ujutro', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijepodne', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podne', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poslijepodne', v_pos);
  v_pos := pg_temp.word(v_lesson, 'navečer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'noću', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponoć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uskoro', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odmah', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kasnije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poslije', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tek', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uvijek', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponekad', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '0a1c77a1-a486-5975-a7bb-54ac87f8815b', 'fill_in_the_blank', 'Danas je ponedjeljak, a ___ je bila nedjelja.', 'jučer', '["večeras", "jučer", "prekosutra", "sutra"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e621a0bc-9c6f-5456-b29a-22f5771876e5', 'multiple_choice', 'Що означає «uvijek»?', 'завжди', '["після / пізніше", "північ (час)", "завжди", "ввечері"]'::jsonb, 'A0', 2, 'PUBLISHED', 'uvijek', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9ba66988-6ffd-58ae-8f58-7255a47f709d', 'multiple_choice', 'Що означає «ponoć»?', 'північ (час)', '["північ (час)", "післязавтра", "завтра", "до обіду; першу половину дня"]'::jsonb, 'A0', 3, 'PUBLISHED', 'ponoć', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '772aa921-67ca-5f9c-bbff-c1b4cc0c6300', 'multiple_choice', 'Що означає «odmah»?', 'одразу', '["іноді / часом", "завжди", "одразу", "позавчора"]'::jsonb, 'A0', 4, 'PUBLISHED', 'odmah', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ead3dd80-703d-5d41-ae1a-7999c7666c6e', 'multiple_choice', 'Як хорватською «полудень»?', 'podne', '["uvijek", "danas", "podne", "noću"]'::jsonb, 'A0', 5, 'PUBLISHED', 'podne', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '64e0e5d2-88e2-5550-918d-be609a72dacc', 'multiple_choice', 'Як хорватською «позавчора»?', 'prekjučer', '["odmah", "noću", "prekjučer", "poslije"]'::jsonb, 'A0', 6, 'PUBLISHED', 'prekjučer', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a101df38-4d2d-5944-89a5-e39f1f994339', 'type_answer', 'Напишіть хорватською: «післязавтра»', 'prekosutra', null, 'A0', 7, 'PUBLISHED', 'prekosutra', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3fd9f442-15d0-515c-934a-86964e06a464', 'type_answer', 'Напишіть хорватською: «вчора»', 'jučer', null, 'A0', 8, 'PUBLISHED', 'jučer', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9ee0c94b-b555-58fc-9b1f-10b75694acd2', 'type_answer', 'Напишіть хорватською: «незабаром»', 'uskoro', null, 'A0', 9, 'PUBLISHED', 'uskoro', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ac445d31-f866-535f-adad-d5e333c2ac69', 'sentence_builder', 'Складіть: «Побачимося завтра після обіду.»', 'Vidimo se sutra poslijepodne.', '["sutra", "Vidimo", "se", "poslijepodne."]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'af534ace-e2fe-57d2-93c8-d39515cbb34a', 'sentence_builder', 'Складіть: «Сьогодні ввечері я працюю до півночі.»', 'Večeras radim do ponoći.', '["ponoći.", "Večeras", "do", "radim"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '038ef18e-cbfa-5def-ad27-66daea6a0c6b', 'listening', 'Прослухайте і складіть фразу', 'A sutra poslijepodne?', '["sutra", "poslijepodne?", "A"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5398ba91-52f8-5ea3-bba3-4cfad0151247', 'listening', 'Прослухайте і складіть фразу', 'Jutros sam se probudila u šest.', '["se", "probudila", "sam", "u", "šest.", "Jutros"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d3d85cf-8c1c-5810-b8fe-eea9ed855b07', 'speaking', 'Учора, сьогодні, завтра.', 'Jučer, danas, sutra.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3091557f-9513-5319-97c0-6ab8a94cf4b3', 'speaking', 'Ти вільна сьогодні ввечері?', 'Jesi li slobodna večeras?', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('041facd6-6950-5e78-a640-8648ff480c5e', v_lesson, 'Коли зустрінемося?', 'Kada se vidimo?', 2251, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('905ce6e7-5af4-5387-822c-97df6d100583', '041facd6-6950-5e78-a640-8648ff480c5e', 'Ivana', 'Dašo, jesi li slobodna večeras?', 'Дашо, ти вільна сьогодні ввечері?', 1);
  perform pg_temp.turn('3102a3e8-b087-56c2-9fba-3f6f3314bcc2', '041facd6-6950-5e78-a640-8648ff480c5e', 'Daša', 'Večeras ne mogu, radim do ponoći.', 'Сьогодні ввечері не можу, працюю до півночі.', 2);
  perform pg_temp.turn('febef4cb-9be2-5824-9ebf-014a47a3bdee', '041facd6-6950-5e78-a640-8648ff480c5e', 'Ivana', 'A sutra poslijepodne?', 'А завтра після обіду?', 3);
  perform pg_temp.turn('1b976c48-16d8-59e2-8860-f56c764d2bb6', '041facd6-6950-5e78-a640-8648ff480c5e', 'Daša', 'Sutra prijepodne sam kod liječnika, a poslijepodne sam slobodna.', 'Завтра до обіду я в лікаря, а після обіду вільна.', 4);
  perform pg_temp.turn('beb8ab4c-7ca4-5680-a82f-4140f004cfd4', '041facd6-6950-5e78-a640-8648ff480c5e', 'Ivana', 'Onda se vidimo sutra u četiri.', 'Тоді побачимося завтра о четвертій.', 5);
  perform pg_temp.turn('d5aecf34-6171-5d57-941a-b5fd74a600a9', '041facd6-6950-5e78-a640-8648ff480c5e', 'Daša', 'Dogovoreno!', 'Домовилися!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b3edd7f7-124e-5771-892b-d362179834f2', v_lesson, 'Довгий день', 'Dug dan', 2252, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('95f9cebb-5348-5e8b-afe3-7adbd4180734', 'b3edd7f7-124e-5771-892b-d362179834f2', 'Marko', 'Dobro jutro, Dašo! Izgledaš umorno.', 'Доброго ранку, Дашо! Ти виглядаєш утомленою.', 1);
  perform pg_temp.turn('30054fe8-b1ab-51af-bc5c-4c1099bc1d01', 'b3edd7f7-124e-5771-892b-d362179834f2', 'Daša', 'Sinoć sam tek u ponoć došla kući.', 'Учора ввечері я прийшла додому тільки опівночі.', 2);
  perform pg_temp.turn('aef58b96-a612-5e9a-9572-474f5c5b1fa9', 'b3edd7f7-124e-5771-892b-d362179834f2', 'Marko', 'A jutros?', 'А сьогодні вранці?', 3);
  perform pg_temp.turn('e4bc947a-cb45-5d2d-9575-b994f3b1c37c', 'b3edd7f7-124e-5771-892b-d362179834f2', 'Daša', 'Jutros sam se probudila u šest.', 'Сьогодні вранці я прокинулася о шостій.', 4);
  perform pg_temp.turn('015ac00a-54c8-5c51-ba27-00a4d925d748', 'b3edd7f7-124e-5771-892b-d362179834f2', 'Marko', 'Odmori se večeras. Prekosutra je subota!', 'Відпочинь сьогодні ввечері. Післязавтра субота!', 5);
  perform pg_temp.turn('4c3413db-a2ba-5b0b-9567-1893b67ab598', 'b3edd7f7-124e-5771-892b-d362179834f2', 'Daša', 'Imaš pravo, večeras idem rano spavati.', 'Маєш рацію, сьогодні ввечері ляжу спати рано.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.4 · урок 26: Котра година? — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '39b1e31f-b573-5000-9713-1660688c3cc9';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Котра година?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '31f40ede-635a-54e2-9a86-c6b199479205') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a0_v4: урок перебудовано за темою — стара версія (слова, вправи, діалоги)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  -- новий склад уроку (тема граматики та сама)
  select grammar_topic_id into v_gid from public.lesson_grammar where lesson_id = v_lesson limit 1;
  if v_gid is null then select item_id into v_gid from public.lesson_items where lesson_id = v_lesson and item_type = 'grammar' limit 1; end if;
  if v_gid is null then select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Час: дні, години, місяці' and status = 'PUBLISHED' order by created_at limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 26: Котра година?', title_hr = 'Lekcija 26: Koliko je sati?',
         objectives = '["Запитати й сказати, котра година", "Розуміти «četvrt», «i pol» і «sat vremena»", "Дізнатися розклад і робочий час"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'koliko je sati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u koliko sati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'minuta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sekunda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'četvrt', v_pos);
  v_pos := pg_temp.word(v_lesson, 'i pol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sat vremena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rano', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kasno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na vrijeme', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zakasniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žuriti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'budilica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radno vrijeme', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otvoreno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zatvoreno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pauza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vozni red', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polazak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dolazak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kašnjenje', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '25a88340-6bb7-590e-a0c0-1cf07742e783', 'fill_in_the_blank', 'Autobus ide u osam ___.', 'sati', '["sata", "sat", "sati", "satu"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cea42f9d-620c-57ea-a419-5ba410e7bca4', 'multiple_choice', 'Що означає «otvoreno»?', 'відчинено', '["прибуття", "рано", "відчинено", "вчасно"]'::jsonb, 'A0', 2, 'PUBLISHED', 'otvoreno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '373eb268-d23a-5f8c-bf4a-f61c24135593', 'multiple_choice', 'Що означає «dolazak»?', 'прибуття', '["хвилина", "запізнення", "прибуття", "о котрій (годині)?"]'::jsonb, 'A0', 3, 'PUBLISHED', 'dolazak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5dfe667a-20cf-5e16-b39b-f938ba5325b5', 'multiple_choice', 'Що означає «žuriti se»?', 'поспішати', '["поспішати", "відправлення", "прибуття", "котра година"]'::jsonb, 'A0', 4, 'PUBLISHED', 'žuriti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '512f2521-454a-5fdf-b48d-568140b96b89', 'multiple_choice', 'Як хорватською «рано»?', 'rano', '["zakasniti", "otvoreno", "koliko je sati", "rano"]'::jsonb, 'A0', 5, 'PUBLISHED', 'rano', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd3f3359c-ef54-54d5-bc30-3e9d6ad6ec2f', 'multiple_choice', 'Як хорватською «вчасно»?', 'na vrijeme', '["na vrijeme", "u koliko sati", "kasno", "budilica"]'::jsonb, 'A0', 6, 'PUBLISHED', 'na vrijeme', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '062953de-ba8a-51ac-94fb-a2d247eb6e4a', 'type_answer', 'Напишіть хорватською: «відправлення»', 'polazak', null, 'A0', 7, 'PUBLISHED', 'polazak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eea6f97c-4d7d-51cb-a6ff-def96c16df0c', 'type_answer', 'Напишіть хорватською: «запізнитися»', 'zakasniti', null, 'A0', 8, 'PUBLISHED', 'zakasniti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1da57b0a-3c9d-5a0e-af50-c77401073a9d', 'type_answer', 'Напишіть хорватською: «хвилина»', 'minuta', null, 'A0', 9, 'PUBLISHED', 'minuta', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae4d8da4-ad4e-5b33-a760-b28dd53028bd', 'sentence_builder', 'Складіть: «О котрій їде потяг?»', 'U koliko sati ide vlak?', '["vlak?", "U", "ide", "sati", "koliko"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '49802c75-b956-576c-b072-20c4c3e65e03', 'sentence_builder', 'Складіть: «Ми не хочемо запізнитися.»', 'Ne želimo zakasniti.', '["zakasniti.", "Ne", "želimo"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9ea337bc-3916-5a7e-9b20-6affab988726', 'listening', 'Прослухайте і складіть фразу', 'Polazak je u deset i petnaest.', '["Polazak", "petnaest.", "deset", "je", "u", "i"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ac700a38-044a-5106-86a4-a18b20466898', 'listening', 'Прослухайте і складіть фразу', 'Ne možemo, škola počinje u osam.', '["osam.", "Ne", "možemo,", "škola", "u", "počinje"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '20e795ef-1e91-5a0d-a1d6-30eac8c24f84', 'speaking', 'Котра година?', 'Koliko je sati?', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7122b8ad-c6ee-5a30-a66c-64973b42fa97', 'speaking', 'Я поспішаю.', 'Žurim se.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('31f40ede-635a-54e2-9a86-c6b199479205', v_lesson, 'На вокзалі', 'Na kolodvoru', 2261, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('8d47dcef-ae4d-5bbb-b500-f953aff1d779', '31f40ede-635a-54e2-9a86-c6b199479205', 'Daša', 'Oprostite, u koliko sati ide vlak za Rijeku?', 'Вибачте, о котрій їде потяг до Рієки?', 1);
  perform pg_temp.turn('f55ebf62-835c-5a9f-9634-2e0611db3932', '31f40ede-635a-54e2-9a86-c6b199479205', 'Službenica', 'Polazak je u deset i petnaest.', 'Відправлення о десятій п’ятнадцять.', 2);
  perform pg_temp.turn('072aac80-5bae-5e1a-beac-b16fc75c9c69', '31f40ede-635a-54e2-9a86-c6b199479205', 'Daša', 'A koliko je sati sada?', 'А котра зараз година?', 3);
  perform pg_temp.turn('b035be3c-edd6-5ce3-8a33-b58371eaf8b0', '31f40ede-635a-54e2-9a86-c6b199479205', 'Službenica', 'Točno deset. Imate još četvrt sata.', 'Рівно десята. У вас ще чверть години.', 4);
  perform pg_temp.turn('c33955a6-3e29-551c-ab07-993861f3e28c', '31f40ede-635a-54e2-9a86-c6b199479205', 'Daša', 'Ima li kašnjenja?', 'Є затримка?', 5);
  perform pg_temp.turn('ea14be3c-7b82-52c1-af67-e9441a289dfa', '31f40ede-635a-54e2-9a86-c6b199479205', 'Službenica', 'Nema, vlak ide na vrijeme. Dolazak u Rijeku je u jedan i pol.', 'Ні, потяг іде вчасно. Прибуття до Рієки о пів на другу.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b0cf6499-4f95-5688-a0b6-db90a2d3f3c0', v_lesson, 'Ранок удома', 'Jutro kod kuće', 2262, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('ab40e53c-db03-5cfb-8745-6a3e3aff5990', 'b0cf6499-4f95-5688-a0b6-db90a2d3f3c0', 'Daša', 'Mia, budilica zvoni! Već je sedam sati.', 'Міє, будильник дзвонить! Уже сьома година.', 1);
  perform pg_temp.turn('c3bca868-2a8b-5c5c-92f1-ae175bf82fbd', 'b0cf6499-4f95-5688-a0b6-db90a2d3f3c0', 'Mia', 'Još pet minuta, mama…', 'Ще п’ять хвилин, мамо…', 2);
  perform pg_temp.turn('7ed0786e-00ae-5594-b1be-3b84ac90910e', 'b0cf6499-4f95-5688-a0b6-db90a2d3f3c0', 'Daša', 'Ne možemo, škola počinje u osam. Ne želimo zakasniti.', 'Не можна, школа починається о восьмій. Ми не хочемо запізнитися.', 3);
  perform pg_temp.turn('012d4be1-63ac-5dea-afb4-6d48e25b9a2c', 'b0cf6499-4f95-5688-a0b6-db90a2d3f3c0', 'Mia', 'Dobro, ustajem! Zašto se uvijek žurimo?', 'Добре, встаю! Чому ми завжди поспішаємо?', 4);
  perform pg_temp.turn('8b9a21d7-9868-512e-a33c-f559e3524e3b', 'b0cf6499-4f95-5688-a0b6-db90a2d3f3c0', 'Daša', 'Zato što uvijek kasno ustaješ!', 'Бо ти завжди пізно встаєш!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.4 · урок 27: Місяці й пори року — перебудова: 22 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '036fc4fb-1bf2-5100-9fd0-6f6a612554a1';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Місяці й пори року» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '2720a5a4-196b-5113-9c57-1ba5973b4421') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a0_v4: урок перебудовано за темою — стара версія (слова, вправи, діалоги)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  -- новий склад уроку (тема граматики та сама)
  select grammar_topic_id into v_gid from public.lesson_grammar where lesson_id = v_lesson limit 1;
  if v_gid is null then select item_id into v_gid from public.lesson_items where lesson_id = v_lesson and item_type = 'grammar' limit 1; end if;
  if v_gid is null then select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Час: дні, години, місяці' and status = 'PUBLISHED' order by created_at limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 27: Місяці й пори року', title_hr = 'Lekcija 27: Mjeseci i godišnja doba',
         objectives = '["Назвати всі місяці хорватською", "Назвати пори року й сказати, що ви робите влітку чи взимку", "Сказати, у якому місяці щось буває: u srpnju, u prosincu"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'siječanj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'veljača', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ožujak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'travanj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svibanj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lipanj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srpanj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolovoz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rujan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'listopad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'studeni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prosinac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godišnje doba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'proljeće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljeto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jesen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zima', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zimi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u proljeće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na jesen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godišnji odmor', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '18f37d07-f781-52af-b925-d67bf5fc75dd', 'fill_in_the_blank', 'Rođendan mi je u ___.', 'svibnju', '["svibnjem", "svibnju", "svibnja", "svibanj"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c6586641-9053-59ef-8431-8e9cd1137c9c', 'multiple_choice', 'Що означає «ožujak»?', 'березень', '["пора року", "восени", "березень", "літо"]'::jsonb, 'A0', 2, 'PUBLISHED', 'ožujak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'af2d776b-954d-5b8c-a20a-1ccd4affc655', 'multiple_choice', 'Що означає «studeni»?', 'листопад', '["восени", "листопад", "навесні", "січень"]'::jsonb, 'A0', 3, 'PUBLISHED', 'studeni', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c086b8a3-1eef-5c26-ac2f-97cb6c4f65ff', 'multiple_choice', 'Що означає «kolovoz»?', 'серпень', '["вересень", "серпень", "листопад", "пора року"]'::jsonb, 'A0', 4, 'PUBLISHED', 'kolovoz', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3f9109ed-6b8c-52ff-9d55-a444e48f33c4', 'multiple_choice', 'Як хорватською «лютий»?', 'veljača', '["jesen", "veljača", "kolovoz", "proljeće"]'::jsonb, 'A0', 5, 'PUBLISHED', 'veljača', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '47d2af44-4d9b-5c55-a74f-a2267dd981a9', 'multiple_choice', 'Як хорватською «квітень»?', 'travanj', '["prosinac", "travanj", "proljeće", "studeni"]'::jsonb, 'A0', 6, 'PUBLISHED', 'travanj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a117f1d0-834a-5cf9-aaab-405142e4ab17', 'type_answer', 'Напишіть хорватською: «зима»', 'zima', null, 'A0', 7, 'PUBLISHED', 'zima', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '93d3eb65-f6c1-5d7c-be73-1265e9ab8e3b', 'type_answer', 'Напишіть хорватською: «січень»', 'siječanj', null, 'A0', 8, 'PUBLISHED', 'siječanj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a8456ca-de6a-5c39-bf26-2d3ba48e0e70', 'type_answer', 'Напишіть хорватською: «весна»', 'proljeće', null, 'A0', 9, 'PUBLISHED', 'proljeće', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aea8f197-22c7-5e2d-a313-1fe69db494a1', 'sentence_builder', 'Складіть: «Улітку я їжджу на море.»', 'Ljeti idem na more.', '["idem", "Ljeti", "more.", "na"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf7eb378-bab3-5a69-a240-9f4bc346e40c', 'sentence_builder', 'Складіть: «Яку пору року ти любиш?»', 'Koje godišnje doba voliš?', '["doba", "voliš?", "Koje", "godišnje"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a78a13d8-794a-5ef5-80f7-aa76a0db11b9', 'listening', 'Прослухайте і складіть фразу', 'Volim proljeće, posebno travanj i svibanj.', '["i", "posebno", "proljeće,", "Volim", "svibanj.", "travanj"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a2944340-f75e-5e13-82ff-c9a3e63c16f0', 'listening', 'Прослухайте і складіть фразу', 'U kolovozu, prva dva tjedna.', '["prva", "kolovozu,", "tjedna.", "dva", "U"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4c49cfab-bc23-5290-abf6-1c63a7ce6250', 'speaking', 'Я люблю літо.', 'Volim ljeto.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b08cf714-1d5d-5d50-8443-628b04cedee0', 'speaking', 'У грудні холодно.', 'U prosincu je hladno.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2720a5a4-196b-5113-9c57-1ba5973b4421', v_lesson, 'Улюблена пора року', 'Omiljeno godišnje doba', 2271, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('338b0c52-23ae-5f9c-ad77-9b3951065fac', '2720a5a4-196b-5113-9c57-1ba5973b4421', 'Luka', 'Dašo, koje godišnje doba voliš najviše?', 'Дашо, яку пору року ти любиш найбільше?', 1);
  perform pg_temp.turn('f04f9210-c4f7-58b0-b7cf-7671ea4489af', '2720a5a4-196b-5113-9c57-1ba5973b4421', 'Daša', 'Volim proljeće, posebno travanj i svibanj.', 'Я люблю весну, особливо квітень і травень.', 2);
  perform pg_temp.turn('7c5bc1c6-dd93-5f22-bcda-8402fcd01b04', '2720a5a4-196b-5113-9c57-1ba5973b4421', 'Luka', 'Ja volim ljeto. Ljeti idem na more.', 'А я люблю літо. Улітку я їжджу на море.', 3);
  perform pg_temp.turn('cea01453-3f4e-5aa3-8bc1-7ed6a5e3cdb3', '2720a5a4-196b-5113-9c57-1ba5973b4421', 'Daša', 'A zimi?', 'А взимку?', 4);
  perform pg_temp.turn('76ecaabe-2517-5260-ad0c-84fbeb9cac61', '2720a5a4-196b-5113-9c57-1ba5973b4421', 'Luka', 'Zimi puno radim, a u veljači idem na skijanje.', 'Узимку я багато працюю, а в лютому їду кататися на лижах.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c5bb27c3-d06a-59ea-81ee-0aa9803a132f', v_lesson, 'Плани на відпустку', 'Planovi za godišnji odmor', 2272, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('88407639-aafc-5836-a6fa-1b9924a30e05', 'c5bb27c3-d06a-59ea-81ee-0aa9803a132f', 'Gospođa Horvat', 'Darja, kada imate godišnji odmor?', 'Дар’є, коли у вас відпустка?', 1);
  perform pg_temp.turn('85f4a325-2964-5c23-8273-d95a6d7bc0ab', 'c5bb27c3-d06a-59ea-81ee-0aa9803a132f', 'Darja', 'U kolovozu, prva dva tjedna.', 'У серпні, перші два тижні.', 2);
  perform pg_temp.turn('c0b11475-176c-55ec-a45f-46ba364b431d', 'c5bb27c3-d06a-59ea-81ee-0aa9803a132f', 'Gospođa Horvat', 'Ja idem u rujnu. Tada je more još toplo, a nema gužve.', 'А я йду у вересні. Тоді море ще тепле, а людей небагато.', 3);
  perform pg_temp.turn('5eeeddd7-b0f2-5f61-89db-c31e84b18302', 'c5bb27c3-d06a-59ea-81ee-0aa9803a132f', 'Darja', 'Dobra ideja! Na jesen idem kući, u Ukrajinu.', 'Гарна ідея! Восени я поїду додому, в Україну.', 4);
  perform pg_temp.turn('9c479dd5-9dd4-5583-a396-1bc41216e2af', 'c5bb27c3-d06a-59ea-81ee-0aa9803a132f', 'Gospođa Horvat', 'Lijepo! Sretan put!', 'Чудово! Щасливої дороги!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.4 · урок 28: Яке сьогодні число? — перебудова: 21 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'b36b4550-ff36-50cb-89fb-8246b351c8d6';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Яке сьогодні число?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '52394e8e-38ec-5db9-92c0-1333cdf832f2') then return; end if;  -- уже перебудовано
  -- стара версія: знімок і копія кроків
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'curriculum_a0_v4: урок перебудовано за темою — стара версія (слова, вправи, діалоги)');
  insert into backup.lesson_items_20261015 select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;
  -- старі вправи й діалоги — застарілі (не видаляються)
  update public.exercises e set status = 'DEPRECATED'
   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')
     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);
  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';
  -- новий склад уроку (тема граматики та сама)
  select grammar_topic_id into v_gid from public.lesson_grammar where lesson_id = v_lesson limit 1;
  if v_gid is null then select item_id into v_gid from public.lesson_items where lesson_id = v_lesson and item_type = 'grammar' limit 1; end if;
  delete from public.lesson_items where lesson_id = v_lesson;
  update public.lessons set title_ua = 'Урок 28: Яке сьогодні число?', title_hr = 'Lekcija 28: Koji je danas datum?',
         objectives = '["Запитати й назвати дату: dvadeseti listopada", "Розуміти дату в документах: datum rođenja, vrijedi do, rok trajanja", "Сказати «на початку / наприкінці місяця» і «наступного року»"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'datum', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koji je danas datum', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kalendar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'datum rođenja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godišnjica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rok trajanja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrijedi do', v_pos);
  v_pos := pg_temp.word(v_lesson, 'isteći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'produžiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'boravišna dozvola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'početak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kraj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sredina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'početkom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krajem', v_pos);
  v_pos := pg_temp.word(v_lesson, 'za tjedan dana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ove godine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prošle godine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sljedeće godine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stoljeće', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '95080c26-21ae-5226-a2b4-9aeade90fcbc', 'fill_in_the_blank', 'Danas je dvadeseti ___.', 'listopada', '["listopadu", "listopadom", "listopada", "listopad"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5498680b-c091-55ae-9148-e634eba6035b', 'multiple_choice', 'Що означає «sredina»?', 'середина', '["на початку (місяця, року)", "середина", "продовжити (термін, документ)", "календар"]'::jsonb, 'A0', 2, 'PUBLISHED', 'sredina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '11bf9972-7eb0-50c5-916f-6ee1e26f26c5', 'multiple_choice', 'Що означає «datum rođenja»?', 'дата народження', '["дата народження", "торік; минулого року", "продовжити (термін, документ)", "діє до"]'::jsonb, 'A0', 3, 'PUBLISHED', 'datum rođenja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '25905dc2-b5a3-571e-89f1-6481d5ae379e', 'multiple_choice', 'Що означає «za tjedan dana»?', 'через тиждень', '["наприкінці (тижня, місяця)", "середина", "дата народження", "через тиждень"]'::jsonb, 'A0', 4, 'PUBLISHED', 'za tjedan dana', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a2cd70e6-5cba-5793-b764-330dec13fa4f', 'multiple_choice', 'Як хорватською «річниця»?', 'godišnjica', '["sredina", "isteći", "godišnjica", "ove godine"]'::jsonb, 'A0', 5, 'PUBLISHED', 'godišnjica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a1485d5-8015-51b1-8329-f066c585b59f', 'multiple_choice', 'Як хорватською «закінчитися; спливти»?', 'isteći', '["godišnjica", "kalendar", "prošle godine", "isteći"]'::jsonb, 'A0', 6, 'PUBLISHED', 'isteći', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '504cfd73-3cd1-552f-bc63-8d1946946e7f', 'type_answer', 'Напишіть хорватською: «початок»', 'početak', null, 'A0', 7, 'PUBLISHED', 'početak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'da79d04e-0431-56cf-8020-a17f1b287a2e', 'type_answer', 'Напишіть хорватською: «кінець; край, місцевість»', 'kraj', null, 'A0', 8, 'PUBLISHED', 'kraj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3dab926c-f350-5ce3-9a6c-4ec244526c05', 'type_answer', 'Напишіть хорватською: «діє до»', 'vrijedi do', null, 'A0', 9, 'PUBLISHED', 'vrijedi do', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3504edeb-864a-594c-b67b-6df4036d909b', 'sentence_builder', 'Складіть: «Яке сьогодні число?»', 'Koji je danas datum?', '["datum?", "Koji", "je", "danas"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'adf1da4c-c541-598c-ade5-5e568bf20c6e', 'sentence_builder', 'Складіть: «Дозвіл дійсний до березня.»', 'Dozvola vrijedi do ožujka.', '["ožujka.", "do", "Dozvola", "vrijedi"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dbcfd056-2927-5d5a-ad16-af277e07da51', 'listening', 'Прослухайте і складіть фразу', 'Danas je dvadeseti listopada.', '["dvadeseti", "listopada.", "je", "Danas"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4422d8da-3f25-5817-87ee-06231425d71d', 'listening', 'Прослухайте і складіть фразу', 'Vrijedi do četvrtog ožujka sljedeće godine.', '["sljedeće", "četvrtog", "ožujka", "Vrijedi", "godine.", "do"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '20f3fd90-8a33-59b2-a0db-824759a45375', 'speaking', 'Я народилася п’ятого травня.', 'Rođena sam petog svibnja.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7675f088-9231-5e3c-a662-95be55cbc5e1', 'speaking', 'Наступного року.', 'Sljedeće godine.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('52394e8e-38ec-5db9-92c0-1333cdf832f2', v_lesson, 'Яке сьогодні число?', 'Koji je danas datum?', 2281, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('b3b5e2b2-3e35-5e07-ae5d-957b2c91e0bb', '52394e8e-38ec-5db9-92c0-1333cdf832f2', 'Daša', 'Luka, koji je danas datum?', 'Луко, яке сьогодні число?', 1);
  perform pg_temp.turn('ab0e7058-4591-506d-847d-67fe1a007984', '52394e8e-38ec-5db9-92c0-1333cdf832f2', 'Luka', 'Danas je dvadeseti listopada.', 'Сьогодні двадцяте жовтня.', 2);
  perform pg_temp.turn('6db8ef9a-8f09-5bc3-af40-7e8ef752e847', '52394e8e-38ec-5db9-92c0-1333cdf832f2', 'Daša', 'Joj, sutra mi je godišnjica braka!', 'Ой, завтра в мене річниця весілля!', 3);
  perform pg_temp.turn('71aa935a-f275-56b6-a3af-cde163ff7cc0', '52394e8e-38ec-5db9-92c0-1333cdf832f2', 'Luka', 'Imaš li već poklon?', 'У тебе вже є подарунок?', 4);
  perform pg_temp.turn('aacc9c1d-3ec8-5996-ba2a-404145ced436', '52394e8e-38ec-5db9-92c0-1333cdf832f2', 'Daša', 'Nemam. Moram ga kupiti danas poslijepodne.', 'Немає. Мушу купити його сьогодні після обіду.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2c15084e-80f1-53cc-b8de-add041ec1f51', v_lesson, 'Дозвіл на проживання', 'Boravišna dozvola', 2282, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('4bbd18a7-6da8-5688-8b85-40efbb44a0bd', '2c15084e-80f1-53cc-b8de-add041ec1f51', 'Službenik', 'Dobar dan. Do kada vrijedi Vaša boravišna dozvola?', 'Добрий день. До якого числа дійсний ваш дозвіл на проживання?', 1);
  perform pg_temp.turn('b80c472f-b800-520e-be64-6f793104ec0a', '2c15084e-80f1-53cc-b8de-add041ec1f51', 'Darja', 'Vrijedi do četvrtog ožujka sljedeće godine.', 'Він дійсний до четвертого березня наступного року.', 2);
  perform pg_temp.turn('f9dbb5a3-5292-5ff7-8b55-d95948871fb3', '2c15084e-80f1-53cc-b8de-add041ec1f51', 'Službenik', 'Dozvolu morate produžiti prije nego što istekne.', 'Дозвіл треба продовжити до того, як він закінчиться.', 3);
  perform pg_temp.turn('3244e135-d7a6-525b-a8e1-f2dfcc70874b', '2c15084e-80f1-53cc-b8de-add041ec1f51', 'Darja', 'Koji je rok?', 'Який термін?', 4);
  perform pg_temp.turn('a3bbdd9d-e6c5-51f0-bfef-13a5b7c367b7', '2c15084e-80f1-53cc-b8de-add041ec1f51', 'Službenik', 'Dođite najkasnije početkom veljače.', 'Прийдіть не пізніше початку лютого.', 5);
  perform pg_temp.turn('18b986e2-0e00-5696-88a9-169f18421705', '2c15084e-80f1-53cc-b8de-add041ec1f51', 'Darja', 'Hvala, zapisat ću to u kalendar.', 'Дякую, запишу це в календар.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- 3. Новий порядок уроків у модулі A0.4: наявні уроки тимчасово переносяться на місця 100+
--    (unique (unit_id, order_index)), щоб звільнити місця для нових; у кроці 5 — на остаточні місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 4 and u.order_index = 1;
  update public.lessons l set order_index = t.o + 100
    from (values
    ('8e372ece-ae10-50ae-9cf3-07b52ef2f72d'::uuid, 1),
    ('238d9508-3c2e-5ee6-910f-0ae8863c2dc7'::uuid, 2),
    ('39b1e31f-b573-5000-9713-1660688c3cc9'::uuid, 3),
    ('036fc4fb-1bf2-5100-9fd0-6f6a612554a1'::uuid, 4),
    ('b36b4550-ff36-50cb-89fb-8246b351c8d6'::uuid, 5)
    ) as t(id, o)
   where l.id = t.id and l.unit_id = v_unit and l.order_index <> t.o and l.order_index < 100;
end $$;

-- 4. Нові тематичні уроки модуля A0.4
-- A0.4 · урок 29: Яка сьогодні погода? — новий урок: 22 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'efcf49e0-c058-5986-9cf7-aee921887a81';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A0.4: місце 6 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Погода: безособові речення' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Погода: безособові речення»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 29: Яка сьогодні погода?', 'Lekcija 29: Kakvo je danas vrijeme?', '["Запитати й розповісти, яка погода", "Сказати «холодно», «тепло», «іде дощ», «дме бура»", "Зрозуміти прогноз погоди: градуси, сонце, хмари"]'::jsonb, 15, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'vrijeme', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kakvo je vrijeme', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vremenska prognoza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sunce', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sunčano', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kiša', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pada kiša', v_pos);
  v_pos := pg_temp.word(v_lesson, 'snijeg', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vjetar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oblak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oblačno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'magla', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oluja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grmljavina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'toplo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hladno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vruće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stupanj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koliko je stupnjeva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kišobran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bura', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jugo', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '301f096b-8592-522a-8dfe-b8af92571036', 'fill_in_the_blank', 'Uzmi kišobran, vani pada ___.', 'kiša', '["kišom", "kiše", "kiša", "kišu"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '57ae8d6a-a044-5d58-aa84-cdcd26baef93', 'multiple_choice', 'Що означає «vjetar»?', 'вітер', '["парасоля", "вітер", "сніг", "гроза / грім"]'::jsonb, 'A0', 2, 'PUBLISHED', 'vjetar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd45f30b-9276-5712-81b1-d2d92b4d09c8', 'multiple_choice', 'Що означає «vrijeme»?', 'погода / час', '["ступінь, градус", "тепле", "іде дощ", "погода / час"]'::jsonb, 'A0', 3, 'PUBLISHED', 'vrijeme', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ec484db1-5b7b-51df-9a7f-e828cbca0b7c', 'multiple_choice', 'Що означає «sunce»?', 'сонце', '["дощ", "вітер", "сніг", "сонце"]'::jsonb, 'A0', 4, 'PUBLISHED', 'sunce', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '36484b21-50ad-5079-9b56-58a77a8707ab', 'multiple_choice', 'Як хорватською «туман»?', 'magla', '["vruće", "magla", "oluja", "oblačno"]'::jsonb, 'A0', 5, 'PUBLISHED', 'magla', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d33a118-dbe9-5070-b567-454113bf87a1', 'multiple_choice', 'Як хорватською «хмара»?', 'oblak', '["vjetar", "grmljavina", "oblak", "pada kiša"]'::jsonb, 'A0', 6, 'PUBLISHED', 'oblak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4f94e05a-27b9-58f4-96a7-d8e7663fc19d', 'type_answer', 'Напишіть хорватською: «гаряче; спекотно»', 'vruće', null, 'A0', 7, 'PUBLISHED', 'vruće', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f19a5eac-c416-5df9-a27c-97c5e3be2933', 'type_answer', 'Напишіть хорватською: «парасоля»', 'kišobran', null, 'A0', 8, 'PUBLISHED', 'kišobran', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ebfb11b-3d30-5b08-aaaf-54448ca330e9', 'type_answer', 'Напишіть хорватською: «сонячно»', 'sunčano', null, 'A0', 9, 'PUBLISHED', 'sunčano', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fb1a1cab-e392-5519-bab9-5e249ac72c3a', 'sentence_builder', 'Складіть: «Яка сьогодні погода?»', 'Kakvo je danas vrijeme?', '["danas", "vrijeme?", "Kakvo", "je"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa1142a1-dada-5953-95fa-e5217093d456', 'sentence_builder', 'Складіть: «Сонячно й тепло.»', 'Sunčano je i toplo.', '["Sunčano", "je", "toplo.", "i"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6172f9f6-a51b-5d03-9497-1cf1c997d397', 'listening', 'Прослухайте і складіть фразу', 'Sunčano je i toplo, dvadeset stupnjeva.', '["Sunčano", "je", "toplo,", "stupnjeva.", "i", "dvadeset"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '114b53a7-abb6-5645-9367-ab9cb84a2cac', 'listening', 'Прослухайте і складіть фразу', 'Sutra će puhati jaka bura.', '["bura.", "Sutra", "puhati", "jaka", "će"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '74df3b3f-70a7-5109-863d-cb8cf84bee0c', 'speaking', 'Холодно.', 'Hladno je.', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '61ed3dd1-9336-5d5b-9cd7-96679e597283', 'speaking', 'Іде дощ.', 'Pada kiša.', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('736d955f-5a6a-5e5c-b9f7-347d44d22bbc', v_lesson, 'Яка погода?', 'Kakvo je vrijeme?', 2291, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('6e996b34-89bb-5838-bd2a-6f2aa1817cda', '736d955f-5a6a-5e5c-b9f7-347d44d22bbc', 'Ivana', 'Bok, Dašo! Kakvo je vrijeme u Splitu?', 'Привіт, Дашо! Яка погода в Спліті?', 1);
  perform pg_temp.turn('73eb99c2-a9f1-5a05-abf6-ba60d3c1e925', '736d955f-5a6a-5e5c-b9f7-347d44d22bbc', 'Daša', 'Sunčano je i toplo, dvadeset stupnjeva.', 'Сонячно й тепло, двадцять градусів.', 2);
  perform pg_temp.turn('89332ce3-0188-52a9-8a63-e4883684edc8', '736d955f-5a6a-5e5c-b9f7-347d44d22bbc', 'Ivana', 'Blago tebi! U Zagrebu pada kiša cijeli dan.', 'Щаслива ти! У Загребі цілий день іде дощ.', 3);
  perform pg_temp.turn('a59a7526-01c5-504a-bfab-e0e218e1ebf1', '736d955f-5a6a-5e5c-b9f7-347d44d22bbc', 'Daša', 'A koliko je stupnjeva?', 'А скільки градусів?', 4);
  perform pg_temp.turn('e02ff7b3-2bb5-53db-b8d1-e48ee6f02d8c', '736d955f-5a6a-5e5c-b9f7-347d44d22bbc', 'Ivana', 'Samo deset. Hladno je i oblačno.', 'Лише десять. Холодно й хмарно.', 5);
  perform pg_temp.turn('d0ac3f80-71db-537a-b591-8bad4a0b54d4', '736d955f-5a6a-5e5c-b9f7-347d44d22bbc', 'Daša', 'Onda ne zaboravi kišobran!', 'Тоді не забудь парасолю!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('76cbbaac-1b63-56be-b82f-0925dbf2391f', v_lesson, 'Прогноз погоди', 'Vremenska prognoza', 2292, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('92f507ef-45d9-53ad-aae6-3ea29e6e5b31', '76cbbaac-1b63-56be-b82f-0925dbf2391f', 'Marko', 'Jesi li čula vremensku prognozu za sutra?', 'Ти чула прогноз погоди на завтра?', 1);
  perform pg_temp.turn('819aee78-6a6a-57c7-819e-21a21d04cfc0', '76cbbaac-1b63-56be-b82f-0925dbf2391f', 'Daša', 'Jesam. Sutra će puhati jaka bura.', 'Так. Завтра дутиме сильна бура.', 2);
  perform pg_temp.turn('98fb3dee-8666-5cb3-8ce7-3995ecc6933b', '76cbbaac-1b63-56be-b82f-0925dbf2391f', 'Marko', 'Bura? Onda će biti hladno, ali bez kiše.', 'Бура? Тоді буде холодно, але без дощу.', 3);
  perform pg_temp.turn('195c494a-e8ca-570c-a8aa-c9721deae357', '76cbbaac-1b63-56be-b82f-0925dbf2391f', 'Daša', 'A u nedjelju stiže jugo, s kišom i grmljavinom.', 'А в неділю прийде юго, з дощем і грозою.', 4);
  perform pg_temp.turn('7131fe6e-18a6-51ab-88de-5d746dd1b83c', '76cbbaac-1b63-56be-b82f-0925dbf2391f', 'Marko', 'Znači, vikend kod kuće!', 'Отже, вихідні вдома!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- A0.4 · урок 30: Свята й привітання — новий урок: 23 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'd7cf3059-0d92-5215-8ef4-ad699e317b10';
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A0.4: місце 7 зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Прикметники: узгодження з іменником' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Прикметники: узгодження з іменником»'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 30: Свята й привітання', 'Lekcija 30: Blagdani i čestitke', '["Назвати головні свята в Хорватії", "Привітати зі святом: Sretan Božić! Sretna Nova godina!", "Знати, що свято — неробочий день: багато магазинів зачинено"]'::jsonb, 15, 'PUBLISHED', 7);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'blagdan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'praznik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neradni dan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Božić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Badnjak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Nova godina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Uskrs', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sretan Božić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sretna Nova godina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sretan Uskrs', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sretni blagdani', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čestitati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čestitka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poklon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'proslava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vatromet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pisanica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Valentinovo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Majčin dan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Dan državnosti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sve najbolje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'želim ti', v_pos);
  -- граматика
  if v_gid is not null then
    v_pos := v_pos + 1;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  end if;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fdbeb230-09ea-5e88-94fb-46548737282d', 'fill_in_the_blank', '___ Nova godina!', 'Sretna', '["Sretna", "Sretno", "Sretan", "Sretni"]'::jsonb, 'A0', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa6e12e7-d9a7-5e79-9fbc-5ec5ede11895', 'multiple_choice', 'Що означає «poklon»?', 'подарунок', '["бажаю тобі", "подарунок", "сосна; ялинка (різдвяна)", "святкування"]'::jsonb, 'A0', 2, 'PUBLISHED', 'poklon', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f759f393-8591-57d7-9389-2d0258daa3a1', 'multiple_choice', 'Що означає «Božić»?', 'Різдво', '["з Великоднем!; щасливого Великодня", "Різдво", "листівка з привітанням", "сосна; ялинка (різдвяна)"]'::jsonb, 'A0', 3, 'PUBLISHED', 'Božić', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b741c5e8-ea9f-56ea-b74b-62c38df6df48', 'multiple_choice', 'Що означає «Uskrs»?', 'Великдень', '["свято, вихідний", "вітати", "писанка", "Великдень"]'::jsonb, 'A0', 4, 'PUBLISHED', 'Uskrs', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '777dc6b5-34a4-5c0a-ac5e-5f26c1ee3eb9', 'multiple_choice', 'Як хорватською «феєрверк»?', 'vatromet', '["Badnjak", "praznik", "poklon", "vatromet"]'::jsonb, 'A0', 5, 'PUBLISHED', 'vatromet', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0d7aa824-3b7e-585f-8a24-0dbb1c3319c9', 'multiple_choice', 'Як хорватською «веселих свят!»?', 'sretni blagdani', '["Nova godina", "Uskrs", "sretni blagdani", "čestitati"]'::jsonb, 'A0', 6, 'PUBLISHED', 'sretni blagdani', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9f9386e0-23f4-542c-a1f0-f283fbe03375', 'type_answer', 'Напишіть хорватською: «Святвечір (24 грудня)»', 'Badnjak', null, 'A0', 7, 'PUBLISHED', 'Badnjak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bd56bc90-0ea2-5c6a-9632-3c427239cd13', 'type_answer', 'Напишіть хорватською: «сосна; ялинка (різдвяна)»', 'bor', null, 'A0', 8, 'PUBLISHED', 'bor', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0b7251fa-6cec-5a20-bcab-fa08134cae63', 'type_answer', 'Напишіть хорватською: «писанка»', 'pisanica', null, 'A0', 9, 'PUBLISHED', 'pisanica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b46da5bc-5e6f-5e59-b76a-e45ff69d2772', 'sentence_builder', 'Складіть: «Щасливого Різдва, Дашо!»', 'Sretan Božić, Dašo!', '["Božić,", "Sretan", "Dašo!"]'::jsonb, 'A0', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3d91a09a-856e-52f0-9973-df0ae45029a6', 'sentence_builder', 'Складіть: «Бажаю тобі щасливого Нового року!»', 'Želim ti sretnu Novu godinu!', '["sretnu", "ti", "Novu", "Želim", "godinu!"]'::jsonb, 'A0', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'af2b831a-2579-5412-946d-35bdc93e93f4', 'listening', 'Прослухайте і складіть фразу', 'Na Badnjak smo kod mojih roditelja.', '["roditelja.", "Na", "Badnjak", "smo", "mojih", "kod"]'::jsonb, 'A0', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4615eb2f-e6ff-5dc6-af9a-d1a13b35b45a', 'listening', 'Прослухайте і складіть фразу', 'Bit će koncert i vatromet.', '["vatromet.", "će", "koncert", "i", "Bit"]'::jsonb, 'A0', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd4709867-96a3-5e7a-a822-0c147af2cc65', 'speaking', 'Веселих свят!', 'Sretni blagdani!', null, 'A0', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b7a8062b-d02e-56e8-8665-75cca7144c26', 'speaking', 'З Великоднем!', 'Sretan Uskrs!', null, 'A0', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('131ad945-b721-555a-9dcd-bb89a6d97acd', v_lesson, 'Перед Різдвом', 'Prije Božića', 2301, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('df6d8087-d765-55b4-bece-1afa1b297568', '131ad945-b721-555a-9dcd-bb89a6d97acd', 'Daša', 'Ivana, što radite za Božić?', 'Івано, що ви робите на Різдво?', 1);
  perform pg_temp.turn('1c6540d2-b00e-57f8-b4ab-f1d5ea58348e', '131ad945-b721-555a-9dcd-bb89a6d97acd', 'Ivana', 'Na Badnjak smo kod mojih roditelja. Kitimo bor i jedemo bakalar.', 'На Святвечір ми в моїх батьків. Прикрашаємо ялинку і їмо бакалар.', 2);
  perform pg_temp.turn('a64f5e2d-fc46-5a50-b929-75f4d6ecbd67', '131ad945-b721-555a-9dcd-bb89a6d97acd', 'Daša', 'I kod nas je Badnjak važan. Na stolu je dvanaest jela.', 'У нас Святвечір теж важливий. На столі дванадцять страв.', 3);
  perform pg_temp.turn('5adbd488-1271-5f03-95bf-ea44a9b726aa', '131ad945-b721-555a-9dcd-bb89a6d97acd', 'Ivana', 'Lijepa tradicija! Sretan Božić, Dašo!', 'Гарна традиція! Щасливого Різдва, Дашо!', 4);
  perform pg_temp.turn('5b4758c1-cb53-5600-9640-d34e32ebeb5c', '131ad945-b721-555a-9dcd-bb89a6d97acd', 'Daša', 'Hvala, i tebi! Sretni blagdani!', 'Дякую, і тобі! Веселих свят!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c84d6b38-e99a-54ca-b553-97d2de6f5771', v_lesson, 'Новий рік', 'Nova godina', 2302, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v4') on conflict (id) do nothing;
  perform pg_temp.turn('27b0d86e-4b7e-5e04-a61f-e8476741b3bb', 'c84d6b38-e99a-54ca-b553-97d2de6f5771', 'Marko', 'Dašo, gdje dočekuješ Novu godinu?', 'Дашо, де ти зустрічаєш Новий рік?', 1);
  perform pg_temp.turn('6e292cda-078a-51a1-bf4e-94ad7fd9fe64', 'c84d6b38-e99a-54ca-b553-97d2de6f5771', 'Daša', 'Na trgu u centru. Bit će koncert i vatromet.', 'На площі в центрі. Буде концерт і феєрверк.', 2);
  perform pg_temp.turn('d6f6b710-87dc-525d-ba27-125d3b909473', 'c84d6b38-e99a-54ca-b553-97d2de6f5771', 'Marko', 'Super! A prvi siječnja je neradni dan, možemo se naspavati.', 'Чудово! А перше січня — неробочий день, можна виспатися.', 3);
  perform pg_temp.turn('43072a91-8a71-5ffa-b0b4-96987f29fbe3', 'c84d6b38-e99a-54ca-b553-97d2de6f5771', 'Daša', 'Da! Želim ti sretnu Novu godinu!', 'Так! Бажаю тобі щасливого Нового року!', 4);
  perform pg_temp.turn('33458aae-829d-5054-a953-fb172e742c95', 'c84d6b38-e99a-54ca-b553-97d2de6f5771', 'Marko', 'Hvala, sve najbolje i tebi!', 'Дякую, і тобі всього найкращого!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.');
end $$;

-- 5. Наявні уроки модуля A0.4 — на нові місця
do $$
declare v_unit uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 4 and u.order_index = 1;
  update public.lessons set order_index = order_index - 100 where unit_id = v_unit and order_index > 100;
end $$;

-- 6. Наскрізні номери всіх уроків A0 («Урок N: …» / «Lekcija N: …»); стара назва — у content_versions
do $$
declare r record; v_payload jsonb; v_new_ua text; v_new_hr text;
begin
  for r in select l.id, l.title_ua, l.title_hr,
                  row_number() over (order by m.order_index, u.order_index, l.order_index) as n
             from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
            where m.level_code = 'A0' and l.status = 'PUBLISHED' loop
    v_new_ua := regexp_replace(r.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':');
    v_new_hr := regexp_replace(r.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':');
    if v_new_ua is not distinct from r.title_ua and v_new_hr is not distinct from r.title_hr then continue; end if;
    select to_jsonb(l) into v_payload from public.lessons l where l.id = r.id;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'curriculum_a0_v4: новий номер уроку ' || r.n);
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;

-- 7. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_lessons int; v_titles int; v_order int; v_module int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('8e372ece-ae10-50ae-9cf3-07b52ef2f72d', '238d9508-3c2e-5ee6-910f-0ae8863c2dc7', '39b1e31f-b573-5000-9713-1660688c3cc9', '036fc4fb-1bf2-5100-9fd0-6f6a612554a1', 'b36b4550-ff36-50cb-89fb-8246b351c8d6', 'efcf49e0-c058-5986-9cf7-aee921887a81', 'd7cf3059-0d92-5215-8ef4-ad699e317b10')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or not exists (select 1 from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar')
             and exists (select 1 from public.lesson_grammar lg where lg.lesson_id = l.id)
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_module from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 4;
  select count(*) into v_order from (values ('8e372ece-ae10-50ae-9cf3-07b52ef2f72d'::uuid, 1), ('238d9508-3c2e-5ee6-910f-0ae8863c2dc7'::uuid, 2), ('39b1e31f-b573-5000-9713-1660688c3cc9'::uuid, 3), ('036fc4fb-1bf2-5100-9fd0-6f6a612554a1'::uuid, 4), ('b36b4550-ff36-50cb-89fb-8246b351c8d6'::uuid, 5), ('efcf49e0-c058-5986-9cf7-aee921887a81'::uuid, 6), ('d7cf3059-0d92-5215-8ef4-ad699e317b10'::uuid, 7)) as t(id, o) join public.lessons l on l.id = t.id and l.order_index = t.o;
  select count(*) into v_lessons from public.lessons where level_code = 'A0' and status = 'PUBLISHED';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A0' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('8e372ece-ae10-50ae-9cf3-07b52ef2f72d', '238d9508-3c2e-5ee6-910f-0ae8863c2dc7', '39b1e31f-b573-5000-9713-1660688c3cc9', '036fc4fb-1bf2-5100-9fd0-6f6a612554a1', 'b36b4550-ff36-50cb-89fb-8246b351c8d6', 'efcf49e0-c058-5986-9cf7-aee921887a81', 'd7cf3059-0d92-5215-8ef4-ad699e317b10') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A0.4: % уроків з неправильним складом', v_bad; end if;
  if v_module <> 7 or v_order <> 7 then raise exception 'Модуль A0.4: уроків %, на своїх місцях % (очікувалось 7)', v_module, v_order; end if;
  if v_lessons < 58 then raise exception 'A0: уроків %, очікувалось щонайменше 58', v_lessons; end if;  -- наступні модулі додають уроки
  if v_titles > 0 then raise exception 'A0: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A0.4: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A0.4 — 7 уроків (24–30) за темою; уроків A0 — %', v_lessons;
end $$;

commit;
