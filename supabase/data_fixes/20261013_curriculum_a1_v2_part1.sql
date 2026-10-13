-- =====================================================================
-- Доповнення A1 · curriculum_a1_v2 · частина 1 з 4 · 2026-10-13
-- Згенеровано: python3 scripts/gen_curriculum_a1_v2.py (не редагуйте вручну).
-- Запуск: Supabase → SQL Editor → вставити ВЕСЬ файл → Run. Частини запускайте по черзі (1 → 4).
--
--   * 10 нових уроків (модулі A1.1–A1.3), у плані програми № 6–25:
--       A1.1 «Сон і відпочинок»
--       A1.1 «З дитиною вдома»
--       A1.1 «Домашній улюбленець»
--       A1.1 «Мій тиждень»
--       A1.2 «Що на сніданок?»
--       A1.2 «Готуємо суп»
--       A1.2 «У м’ясника й на рибному ринку»
--       A1.2 «Обід на роботі»
--       A1.3 «Зимовий одяг»
--       A1.3 «Меблі для квартири»
--   * У кожному 14 нових слів, 2 діалоги (105 реплік разом), граматика, 12 вправ, ~12 хв.
--   * Нові слова у словнику: 83. Виправлення словника: 5 (стара версія — у content_versions).
--   * Назви всіх уроків A1 перенумеровано підряд («Урок N»); старі назви — у content_versions.
--   * Статус PUBLISHED: бета, як решта A1 (носій ще не перевіряв). Наявні дані не видаляються.
--   * Потрібна програма A1 v1 (20261013_curriculum_a1_v1_part1.sql і _part2.sql). Повторний запуск безпечний.
-- =====================================================================

begin;

do $$
begin
  if not exists (select 1 from public.lessons where id = 'fee5b77b-dc3b-5fd5-818a-c5496e95c23b' and status = 'PUBLISHED') then
    raise exception 'Спершу запустіть програму A1 v1 (20261013_curriculum_a1_v1_part1.sql і _part2.sql)';
  end if;
  if not exists (select 1 from pg_constraint where conname = 'exercises_type_check'
                 and pg_get_constraintdef(oid) like '%speaking%') then
    raise exception 'Спершу запустіть міграцію M13 (20261013140000_m13_exercise_types.sql)';
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

-- 1. Нові слова (83), яких ще немає у словнику
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jastuk', 'jastuk', 'hr', 'noun', 'A1', 'подушка', 'core', '{"gender": "m"}'::jsonb, '["Ovaj jastuk mi je premekan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pokrivač', 'pokrivac', 'hr', 'noun', 'A1', 'ковдра', 'core', '{"gender": "m"}'::jsonb, '["Zimi spavam pod debelim pokrivačem."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('plahta', 'plahta', 'hr', 'noun', 'A1', 'простирадло', 'core', '{"gender": "f"}'::jsonb, '["Plahte mijenjam svaki tjedan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('budilica', 'budilica', 'hr', 'noun', 'A1', 'будильник', 'core', '{"gender": "f"}'::jsonb, '["Budilica mi zvoni u šest."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zvoniti', 'zvoniti', 'hr', 'verb', 'A1', 'дзвонити (про дзвінок, будильник, телефон)', 'core', '{"aspect": "ipfv"}'::jsonb, '["Telefon zvoni, javi se!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('drijemati', 'drijemati', 'hr', 'verb', 'A1', 'дрімати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Djed poslije ručka drijema na kauču."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nesanica', 'nesanica', 'hr', 'noun', 'A1', 'безсоння', 'core', '{"gender": "f"}'::jsonb, '["Zbog stresa imam nesanicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('hrkati', 'hrkati', 'hr', 'verb', 'A1', 'хропіти', 'core', '{"aspect": "ipfv"}'::jsonb, '["Moj muž glasno hrče."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zijevati', 'zijevati', 'hr', 'verb', 'A1', 'позіхати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Zašto stalno zijevaš?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('igračka', 'igracka', 'hr', 'noun', 'A1', 'іграшка', 'core', '{"gender": "f"}'::jsonb, '["Spremi igračke u kutiju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('igralište', 'igraliste', 'hr', 'noun', 'A1', 'дитячий майданчик', 'core', '{"gender": "n"}'::jsonb, '["Poslije vrtića idemo na igralište."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ljuljačka', 'ljuljacka', 'hr', 'noun', 'A1', 'гойдалка', 'core', '{"gender": "f"}'::jsonb, '["Djeca čekaju red za ljuljačku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tobogan', 'tobogan', 'hr', 'noun', 'A1', 'гірка (дитяча)', 'core', '{"gender": "m"}'::jsonb, '["Na igralištu je novi tobogan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kupati', 'kupati', 'hr', 'verb', 'A1', 'купати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Navečer kupam bebu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('crtić', 'crtic', 'hr', 'noun', 'A1', 'мультфільм', 'core', '{"gender": "m"}'::jsonb, '["Djeca gledaju crtić na televiziji."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('presvući', 'presvuci', 'hr', 'verb', 'A1', 'перевдягнути', 'core', '{"aspect": "pfv"}'::jsonb, '["Presvuci dijete, mokro je."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dadilja', 'dadilja', 'hr', 'noun', 'A1', 'няня', 'core', '{"gender": "f"}'::jsonb, '["Dadilja dolazi u osam."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uspavati', 'uspavati', 'hr', 'verb', 'A1', 'приспати; вкласти спати', 'core', '{"aspect": "pfv"}'::jsonb, '["Teško je uspavati malu bebu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kućni ljubimac', 'kucni ljubimac', 'hr', 'phrase', 'A1', 'домашній улюбленець', 'collocation', '{"gender": "m"}'::jsonb, '["Imate li kućnog ljubimca?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('hraniti', 'hraniti', 'hr', 'verb', 'A1', 'годувати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Mačku hranim dvaput dnevno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zdjelica', 'zdjelica', 'hr', 'noun', 'A1', 'мисочка', 'core', '{"gender": "f"}'::jsonb, '["Stavi vodu u zdjelicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('granule', 'granule', 'hr', 'noun', 'A1', 'сухий корм (гранули)', 'core', '{"gender": "f", "number": "pl"}'::jsonb, '["Kupujem granule za mačke."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('raspored', 'raspored', 'hr', 'noun', 'A1', 'розклад', 'core', '{"gender": "m"}'::jsonb, '["Moj raspored je ovaj tjedan pun."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('podsjetnik', 'podsjetnik', 'hr', 'noun', 'A1', 'нагадування', 'core', '{"gender": "m"}'::jsonb, '["Stavi podsjetnik u mobitel."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zapisati', 'zapisati', 'hr', 'verb', 'A1', 'записати', 'core', '{"aspect": "pfv"}'::jsonb, '["Zapiši termin u kalendar."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dvaput', 'dvaput', 'hr', 'adverb', 'A1', 'двічі', 'core', '{}'::jsonb, '["Treniram dvaput tjedno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tjedno', 'tjedno', 'hr', 'adverb', 'A1', 'щотижня; на тиждень', 'core', '{}'::jsonb, '["Radim četrdeset sati tjedno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('med', 'med', 'hr', 'noun', 'A1', 'мед', 'core', '{"gender": "m"}'::jsonb, '["Čaj pijem s medom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pekmez', 'pekmez', 'hr', 'noun', 'A1', 'джем; повидло', 'core', '{"gender": "m"}'::jsonb, '["Kruh s maslacem i pekmezom je moj doručak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pahuljice', 'pahuljice', 'hr', 'noun', 'A1', 'пластівці', 'core', '{"gender": "f", "number": "pl"}'::jsonb, '["Djeca jedu pahuljice s mlijekom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kobasica', 'kobasica', 'hr', 'noun', 'A1', 'сосиска; ковбаска', 'core', '{"gender": "f"}'::jsonb, '["Za doručak jedemo jaja i kobasice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('salama', 'salama', 'hr', 'noun', 'A1', 'салямі', 'core', '{"gender": "f"}'::jsonb, '["Sendvič sa salamom i sirom, molim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kajgana', 'kajgana', 'hr', 'noun', 'A1', 'яєчня-бовтанка', 'core', '{"gender": "f"}'::jsonb, '["Napravi mi kajganu od dva jaja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tost', 'tost', 'hr', 'noun', 'A1', 'тост', 'core', '{"gender": "m"}'::jsonb, '["Za doručak jedem tost sa sirom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kakao', 'kakao', 'hr', 'noun', 'A1', 'какао', 'core', '{"gender": "m"}'::jsonb, '["Djeca piju topli kakao."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vrhnje', 'vrhnje', 'hr', 'noun', 'A1', 'сметана; вершки', 'core', '{"gender": "n"}'::jsonb, '["Kavu pijem s vrhnjem."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('namaz', 'namaz', 'hr', 'noun', 'A1', 'намазка (для хліба)', 'core', '{"gender": "m"}'::jsonb, '["Kupi neki namaz za kruh."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('krafna', 'krafna', 'hr', 'noun', 'A1', 'пончик', 'core', '{"gender": "f"}'::jsonb, '["U pekari kupujem krafnu s čokoladom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('integralni', 'integralni', 'hr', 'adjective', 'A1', 'цільнозерновий', 'core', '{}'::jsonb, '["Jedem samo integralni kruh."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('oguliti', 'oguliti', 'hr', 'verb', 'A1', 'почистити (від шкірки)', 'core', '{"aspect": "pfv"}'::jsonb, '["Oguli krumpir i mrkvu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mrkva', 'mrkva', 'hr', 'noun', 'A1', 'морква', 'core', '{"gender": "f"}'::jsonb, '["Mrkvu reži na kolutiće."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kupus', 'kupus', 'hr', 'noun', 'A1', 'капуста', 'core', '{"gender": "m"}'::jsonb, '["Zimi jedemo puno kiselog kupusa."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('grah', 'grah', 'hr', 'noun', 'A1', 'квасоля', 'core', '{"gender": "m"}'::jsonb, '["Grah je jeftin i zdrav."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zagrijati', 'zagrijati', 'hr', 'verb', 'A1', 'розігріти; нагріти', 'core', '{"aspect": "pfv"}'::jsonb, '["Zagrij pećnicu na dvjesto stupnjeva."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('posoliti', 'posoliti', 'hr', 'verb', 'A1', 'посолити', 'core', '{"aspect": "pfv"}'::jsonb, '["Juhu posoli na kraju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('janjetina', 'janjetina', 'hr', 'noun', 'A1', 'баранина (ягнятина)', 'core', '{"gender": "f"}'::jsonb, '["Za Uskrs jedemo janjetinu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('puretina', 'puretina', 'hr', 'noun', 'A1', 'індичатина', 'core', '{"gender": "f"}'::jsonb, '["Puretina je lagana i zdrava."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mljeveno meso', 'mljeveno meso', 'hr', 'phrase', 'A1', 'фарш', 'collocation', '{"gender": "n"}'::jsonb, '["Za umak trebam pola kile mljevenog mesa."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odrezak', 'odrezak', 'hr', 'noun', 'A1', 'відбивна; стейк', 'core', '{"gender": "m"}'::jsonb, '["Za ručak je pureći odrezak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('lignja', 'lignja', 'hr', 'noun', 'A1', 'кальмар', 'core', '{"gender": "f"}'::jsonb, '["Lignje na žaru su odlične."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('srdela', 'srdela', 'hr', 'noun', 'A1', 'сардина', 'core', '{"gender": "f"}'::jsonb, '["Svježe srdele su ljeti jeftine."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dagnja', 'dagnja', 'hr', 'noun', 'A1', 'мідія', 'core', '{"gender": "f"}'::jsonb, '["Dagnje kuhamo s bijelim vinom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kost', 'kost', 'hr', 'noun', 'A1', 'кістка', 'core', '{"gender": "f"}'::jsonb, '["Ova riba ima puno kostiju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('file', 'file', 'hr', 'noun', 'A1', 'філе', 'core', '{"gender": "m"}'::jsonb, '["Uzmite file, nema kostiju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('očistiti', 'ocistiti', 'hr', 'verb', 'A1', 'почистити; випатрати (рибу)', 'core', '{"aspect": "pfv"}'::jsonb, '["Možete li mi očistiti ribu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('plodovi mora', 'plodovi mora', 'hr', 'phrase', 'A1', 'морепродукти', 'collocation', '{"gender": "m", "number": "pl"}'::jsonb, '["Volim plodove mora."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gablec', 'gablec', 'hr', 'noun', 'A1', 'гарячий обід на роботі (загреб.)', 'core', '{"gender": "m"}'::jsonb, '["U podne idemo na gablec."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('menza', 'menza', 'hr', 'noun', 'A1', 'їдальня', 'core', '{"gender": "f"}'::jsonb, '["Studenti ručaju u menzi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('varivo', 'varivo', 'hr', 'noun', 'A1', 'рагу (густа страва з овочів)', 'core', '{"gender": "n"}'::jsonb, '["Danas je varivo od graha."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('porcija', 'porcija', 'hr', 'noun', 'A1', 'порція', 'core', '{"gender": "f"}'::jsonb, '["Jednu porciju, molim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prilog', 'prilog', 'hr', 'noun', 'A1', 'гарнір', 'core', '{"gender": "m"}'::jsonb, '["Što želite kao prilog?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pečen', 'pecen', 'hr', 'adjective', 'A1', 'запечений; смажений (у духовці)', 'core', '{}'::jsonb, '["Pečena piletina je odlična."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kuhan', 'kuhan', 'hr', 'adjective', 'A1', 'варений', 'core', '{}'::jsonb, '["Kuhana jaja su zdrava."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pohan', 'pohan', 'hr', 'adjective', 'A1', 'у паніровці', 'core', '{}'::jsonb, '["Pohani sir je popularan u Hrvatskoj."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pire', 'pire', 'hr', 'noun', 'A1', 'пюре', 'core', '{"gender": "m"}'::jsonb, '["Uz meso želim pire od krumpira."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mahune', 'mahune', 'hr', 'noun', 'A1', 'стручкова квасоля', 'core', '{"gender": "f", "number": "pl"}'::jsonb, '["Mahune kuham s krumpirom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pladanj', 'pladanj', 'hr', 'noun', 'A1', 'таця', 'core', '{"gender": "m"}'::jsonb, '["Uzmite pladanj i pribor."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('grašak', 'grasak', 'hr', 'noun', 'A1', 'горошок', 'core', '{"gender": "m"}'::jsonb, '["Rižoto s graškom je moje omiljeno jelo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pidžama', 'pidzama', 'hr', 'noun', 'A1', 'піжама', 'core', '{"gender": "f"}'::jsonb, '["Djeca su već u pidžamama."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('debeo', 'debeo', 'hr', 'adjective', 'A1', 'товстий', 'core', '{}'::jsonb, '["Zimi nosim debele čarape."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tanak', 'tanak', 'hr', 'adjective', 'A1', 'тонкий', 'core', '{}'::jsonb, '["Ova jakna je pretanka za zimu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vuna', 'vuna', 'hr', 'noun', 'A1', 'вовна', 'core', '{"gender": "f"}'::jsonb, '["Ovaj džemper je od vune."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nepromočiv', 'nepromociv', 'hr', 'adjective', 'A1', 'непромокальний', 'core', '{}'::jsonb, '["Trebam nepromočive čizme."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('madrac', 'madrac', 'hr', 'noun', 'A1', 'матрац', 'core', '{"gender": "m"}'::jsonb, '["Ovaj madrac je pretvrd."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('posteljina', 'posteljina', 'hr', 'noun', 'A1', 'постільна білизна', 'core', '{"gender": "f"}'::jsonb, '["Mijenjam posteljinu svake subote."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ladica', 'ladica', 'hr', 'noun', 'A1', 'шухляда', 'core', '{"gender": "f"}'::jsonb, '["Ključevi su u gornjoj ladici."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('komoda', 'komoda', 'hr', 'noun', 'A1', 'комод', 'core', '{"gender": "f"}'::jsonb, '["Komoda ima četiri ladice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vješalica', 'vjesalica', 'hr', 'noun', 'A1', 'вішалка', 'core', '{"gender": "f"}'::jsonb, '["Objesi kaput na vješalicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stolić', 'stolic', 'hr', 'noun', 'A1', 'столик', 'core', '{"gender": "m"}'::jsonb, '["Daljinski je na stoliću."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('naslonjač', 'naslonjac', 'hr', 'noun', 'A1', 'крісло', 'core', '{"gender": "m"}'::jsonb, '["U dnevnom boravku je udoban naslonjač."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sklopiti', 'sklopiti', 'hr', 'verb', 'A1', 'зібрати (меблі); скласти', 'core', '{"aspect": "pfv"}'::jsonb, '["Ormar moramo sami sklopiti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vijak', 'vijak', 'hr', 'noun', 'A1', 'гвинт; шуруп', 'core', '{"gender": "m"}'::jsonb, '["Nedostaje jedan vijak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('montirati', 'montirati', 'hr', 'verb', 'A1', 'монтувати; встановлювати', 'core', '{"aspect": "ipfv/pfv"}'::jsonb, '["Majstor montira kuhinju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;

-- 2. Виправлення словника для слів цих уроків (стара версія — у content_versions)
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('povodac') and ukrainian_translation = 'Повідець';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «Повідець» → «повідець»');
  update public.lexemes set ukrainian_translation = 'повідець' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «Повідець» → «повідець»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('peći') and ukrainian_translation = 'випікати, смажити';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «випікати, смажити» → «пекти; запікати»');
  update public.lexemes set ukrainian_translation = 'пекти; запікати' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «випікати, смажити» → «пекти; запікати»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('miješati') and ukrainian_translation = 'мішати';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «мішати» → «мішати; перемішувати»');
  update public.lexemes set ukrainian_translation = 'мішати; перемішувати' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «мішати» → «мішати; перемішувати»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('obveza') and ukrainian_translation = 'зобов''язання';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «зобов''язання» → «обов''язок; справа»');
  update public.lexemes set ukrainian_translation = 'обов''язок; справа' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «зобов''язання» → «обов''язок; справа»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lemma = 'Povodac';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: лема «Povodac» → «povodac»');
  update public.lexemes set lemma = 'povodac' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: лема «Povodac» → «povodac»');
end $$;

-- 3. Уроки
-- A1.1 · урок 6: Сон і відпочинок
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '63a4a6d8-1cae-5e0e-90ff-98efcfe8b4c7';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A1.1: місце уроку 6 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.1.6'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 6: Сон і відпочинок', 'Lekcija 6: San i odmor', '["Розповісти, як ви спите", "Пояснити, що заважає спати", "Назвати речі в ліжку: подушка, ковдра, простирадло"]'::jsonb, 12, 'PUBLISHED', 6);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'san', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sanjati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jastuk', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pokrivač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plahta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'budilica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvoniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'drijemati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nesanica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hrkati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zijevati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'leći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odmoran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tišina', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f607b1f8-e1c7-5733-8c34-1e9c784bdf67', 'fill_in_the_blank', 'Moj muž glasno ___.', 'hrče', '["hrčemo", "hrče", "hrčeš", "hrčem"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2343f6c4-9501-547c-9db3-3ad8d89a1981', 'multiple_choice', 'Що означає «san»?', 'сон', '["відпочилий", "сон", "тиша", "мріяти, бачити сни"]'::jsonb, 'A1', 2, 'PUBLISHED', 'san', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a8a16bd4-1893-5204-bb53-53d7222e1c42', 'multiple_choice', 'Що означає «leći»?', 'лягти', '["лягти", "хропіти", "відпочилий", "простирадло"]'::jsonb, 'A1', 3, 'PUBLISHED', 'leći', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd3ded2ee-3edf-5b6b-95b9-0ecd681b8a3b', 'multiple_choice', 'Як хорватською «дрімати»?', 'drijemati', '["san", "drijemati", "hrkati", "zvoniti"]'::jsonb, 'A1', 4, 'PUBLISHED', 'drijemati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e2a80e5c-1893-55b5-b3d6-d00df5e580ec', 'type_answer', 'Напишіть хорватською: «хропіти»', 'hrkati', null, 'A1', 5, 'PUBLISHED', 'hrkati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '64570975-cc83-55a6-a80f-40579876fce9', 'type_answer', 'Напишіть хорватською: «безсоння»', 'nesanica', null, 'A1', 6, 'PUBLISHED', 'nesanica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4db13de9-ff01-5161-a93d-ddfdfd9fa500', 'sentence_builder', 'Складіть: «Мені потрібна нова подушка.»', 'Trebam novi jastuk.', '["jastuk.", "novi", "Trebam"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1db0f2ac-5e09-5da1-ab3f-0cb01f672847', 'sentence_builder', 'Складіть: «Будильник дзвонить о шостій.»', 'Budilica zvoni u šest.', '["u", "zvoni", "šest.", "Budilica"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '34608660-7761-507a-a1c8-38c386eaf674', 'listening', 'Прослухайте і складіть фразу', 'Imam nesanicu.', '["nesanicu.", "Imam"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '393ae3c3-a10d-5076-aee0-e4ac70a42da2', 'listening', 'Прослухайте і складіть фразу', 'Još malo drijemam.', '["Još", "drijemam.", "malo"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3b8a2086-f6cb-59f0-a195-ad428e2fcc51', 'speaking', 'Добрий сон дуже важливий.', 'Dobar san je jako važan.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ec86e58-bec1-59f8-8cd4-982187e42c0f', 'speaking', 'Мені потрібні нова ковдра й простирадло.', 'Trebam novi pokrivač i plahtu.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d9657ddd-ba01-5ef6-9eb7-d66ffadec860', v_lesson, 'Погана ніч', 'Loša noć', 1061, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('22c8d768-f614-5a1d-83a7-8fd0c628a806', 'd9657ddd-ba01-5ef6-9eb7-d66ffadec860', 'Marija', 'Izgledaš umorno. Zašto stalno zijevaš?', 'Ти виглядаєш утомленою. Чому ти весь час позіхаєш?', 1);
  perform pg_temp.turn('607a92f1-26c5-54e9-83e1-a0968c54e628', 'd9657ddd-ba01-5ef6-9eb7-d66ffadec860', 'Olena', 'Imam nesanicu. Ne mogu zaspati prije dva sata.', 'У мене безсоння. Не можу заснути до другої години.', 2);
  perform pg_temp.turn('eb4de191-fe77-546f-86cf-b83d5481c612', 'd9657ddd-ba01-5ef6-9eb7-d66ffadec860', 'Marija', 'A što radiš kad ležiš u krevetu?', 'А що ти робиш, коли лежиш у ліжку?', 3);
  perform pg_temp.turn('79382e40-87f5-52fe-9e80-3b360b1d1d51', 'd9657ddd-ba01-5ef6-9eb7-d66ffadec860', 'Olena', 'Gledam mobitel. A muž glasno hrče.', 'Дивлюся в телефон. А чоловік голосно хропе.', 4);
  perform pg_temp.turn('d3b1a377-5693-53cd-a9f3-86e88a5e69b4', 'd9657ddd-ba01-5ef6-9eb7-d66ffadec860', 'Marija', 'Lezi ranije i ostavi mobitel u kuhinji.', 'Лягай раніше і залишай телефон на кухні.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1cae409b-ffee-57f2-9e51-e9162193adea', v_lesson, 'Субота вранці', 'Subota ujutro', 1062, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('f4716d49-1272-56f3-9d42-18eeb9db8c5b', '1cae409b-ffee-57f2-9e51-e9162193adea', 'Taras', 'Budilica zvoni! Ustaješ li?', 'Будильник дзвонить! Ти встаєш?', 1);
  perform pg_temp.turn('8e9aeacf-f3d1-50b4-9d33-63cb72665f05', '1cae409b-ffee-57f2-9e51-e9162193adea', 'Ana', 'Ne, danas je subota. Još malo drijemam.', 'Ні, сьогодні субота. Я ще трохи подрімаю.', 2);
  perform pg_temp.turn('f2b552ed-afbb-5520-8570-e4cf48a05051', '1cae409b-ffee-57f2-9e51-e9162193adea', 'Taras', 'Sanjaš li često?', 'Тобі часто сняться сни?', 3);
  perform pg_temp.turn('e5dd3a20-9450-53bd-9d5a-8ea114eae7ec', '1cae409b-ffee-57f2-9e51-e9162193adea', 'Ana', 'Da, svaku noć. Najbolje spavam u tišini.', 'Так, щоночі. Найкраще я сплю в тиші.', 4);
  perform pg_temp.turn('caa67c61-52a2-5840-bf6a-4bc38acd745b', '1cae409b-ffee-57f2-9e51-e9162193adea', 'Taras', 'Dobro, idem po kruh. Spavaj!', 'Добре, я піду по хліб. Спи!', 5);
  perform pg_temp.turn('d4345d22-a62b-5b92-acc9-3468daeae8d4', '1cae409b-ffee-57f2-9e51-e9162193adea', 'Ana', 'Hvala! Kad sam odmorna, imam više energije.', 'Дякую! Коли я відпочила, у мене більше енергії.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 7: З дитиною вдома
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A1.1: місце уроку 7 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.1.7'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 7: З дитиною вдома', 'Lekcija 7: S djetetom kod kuće', '["Попросити дитину щось зробити або не робити", "Описати вечір із дитиною", "Назвати іграшки й місця для гри"]'::jsonb, 12, 'PUBLISHED', 7);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'igračka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'igralište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljuljačka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tobogan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bajka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crtić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dječja kolica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'presvući', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plakati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smijati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pijesak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dadilja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uspavati', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '6cdfa9fe-881b-53bd-9ec3-9eaf01500a48', 'fill_in_the_blank', 'Molim te, ___ dijete, mokro je.', 'presvuci', '["presvuci", "presvučeš", "presvući", "presvlačim"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '78c3b733-1be9-585a-aa7a-d4326c45cd6c', 'multiple_choice', 'Що означає «igračka»?', 'іграшка', '["іграшка", "купати", "няня", "сміятися"]'::jsonb, 'A1', 2, 'PUBLISHED', 'igračka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd4b04c19-c0bc-55d4-826b-9783a6a69666', 'multiple_choice', 'Що означає «ljuljačka»?', 'гойдалка', '["пісок", "гойдалка", "няня", "іграшка"]'::jsonb, 'A1', 3, 'PUBLISHED', 'ljuljačka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f43d21bf-2633-5bcd-83f2-eb3abaeb74b0', 'multiple_choice', 'Як хорватською «купати»?', 'kupati', '["dječja kolica", "kupati", "smijati se", "crtić"]'::jsonb, 'A1', 4, 'PUBLISHED', 'kupati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '798f9860-4ee7-57d8-bde2-7bf52b560694', 'type_answer', 'Напишіть хорватською: «няня»', 'dadilja', null, 'A1', 5, 'PUBLISHED', 'dadilja', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '174b4914-136a-54f8-8f92-9c9016b66f69', 'type_answer', 'Напишіть хорватською: «сміятися»', 'smijati se', null, 'A1', 6, 'PUBLISHED', 'smijati se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '04ac7aaa-ca9f-5f4c-9eac-496b4ee68022', 'sentence_builder', 'Складіть: «Почитай йому казку.»', 'Čitaj mu bajku.', '["bajku.", "mu", "Čitaj"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '241026db-f77c-5b6e-bb96-62c4728ea039', 'sentence_builder', 'Складіть: «Няня приходить о восьмій.»', 'Dadilja dolazi u osam.', '["osam.", "Dadilja", "u", "dolazi"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd75bceac-9a7d-5b95-b20f-ec258f231809', 'listening', 'Прослухайте і складіть фразу', 'Mama, mogu li na tobogan?', '["tobogan?", "li", "mogu", "na", "Mama,"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aa196098-464a-5341-b6e2-2d537a647363', 'listening', 'Прослухайте і складіть фразу', 'Može li gledati crtić prije spavanja?', '["spavanja?", "Može", "prije", "gledati", "li", "crtić"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be35f896-70d0-5526-8f08-dff549633861', 'speaking', 'Не плач, усе добре.', 'Ne plači, sve je u redu.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a0c4d7cb-77a3-54f9-aa40-d1bc392da301', 'speaking', 'Поклади іграшки у візочок.', 'Stavi igračke u dječja kolica.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e62ee7c5-bdd1-5644-99b7-5279a8613c05', v_lesson, 'На майданчику', 'Na igralištu', 1071, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('97da4b37-d53c-5233-8b04-64d2644994dc', 'e62ee7c5-bdd1-5644-99b7-5279a8613c05', 'Olena', 'Sofija, pazi! Ne trči kod ljuljačke.', 'Софіє, обережно! Не бігай біля гойдалки.', 1);
  perform pg_temp.turn('1681cbb5-c203-5917-a740-095179b5b514', 'e62ee7c5-bdd1-5644-99b7-5279a8613c05', 'Sofija', 'Mama, mogu li na tobogan?', 'Мамо, можна мені на гірку?', 2);
  perform pg_temp.turn('02a1f201-8446-587b-bcfb-5f4b1d937d39', 'e62ee7c5-bdd1-5644-99b7-5279a8613c05', 'Olena', 'Možeš. Ali prvo obuci jaknu.', 'Можна. Але спершу вдягни куртку.', 3);
  perform pg_temp.turn('dfa248bf-d2e1-5d92-9298-f4cdfe3826ce', 'e62ee7c5-bdd1-5644-99b7-5279a8613c05', 'Sofija', 'Mama, u cipelama imam pijesak!', 'Мамо, в мене в черевиках пісок!', 4);
  perform pg_temp.turn('8556827b-c846-57ca-b039-e47a950f0b96', 'e62ee7c5-bdd1-5644-99b7-5279a8613c05', 'Olena', 'Nema veze. Igraj se još pet minuta.', 'Нічого страшного. Пограйся ще п’ять хвилин.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7d7cb91d-f74a-519b-9963-6de783061911', v_lesson, 'Вечір удома', 'Večer kod kuće', 1072, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('2236afd8-bb5d-5da3-9d24-b280c704dd47', '7d7cb91d-f74a-519b-9963-6de783061911', 'Taras', 'Mali plače. Što mu je?', 'Малий плаче. Що з ним?', 1);
  perform pg_temp.turn('3936ecc3-855d-5f10-89f1-c2c9a8cf1c01', '7d7cb91d-f74a-519b-9963-6de783061911', 'Olena', 'Umoran je. Prvo ga kupamo, a onda ga presvuci.', 'Він утомився. Спочатку його скупаємо, а потім перевдягни його.', 2);
  perform pg_temp.turn('04a94a1c-7154-5c30-8e83-a4ef5b18cd80', '7d7cb91d-f74a-519b-9963-6de783061911', 'Taras', 'Može li gledati crtić prije spavanja?', 'Можна йому подивитися мультик перед сном?', 3);
  perform pg_temp.turn('9ad6c66c-f9e3-569c-91f4-2795dd315253', '7d7cb91d-f74a-519b-9963-6de783061911', 'Olena', 'Ne, čitaj mu bajku. Tako ga lakše uspavaš.', 'Ні, почитай йому казку. Так його легше приспати.', 4);
  perform pg_temp.turn('4cf18149-a649-5aa1-84e2-41530c99e397', '7d7cb91d-f74a-519b-9963-6de783061911', 'Taras', 'Dobro. Gle, već se smije!', 'Добре. Дивись, він уже сміється!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 8: Домашній улюбленець
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '1968c7d5-4e3a-5b1e-92f6-88df711e9c54';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 8) then
    raise exception 'A1.1: місце уроку 8 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.1.8'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 8: Домашній улюбленець', 'Lekcija 8: Kućni ljubimac', '["Розповісти про свою тварину", "Прийти з твариною до ветеринара", "Назвати, що потрібно собаці чи кішці"]'::jsonb, 12, 'PUBLISHED', 8);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kućni ljubimac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mačka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hraniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'veterinar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povodac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zdjelica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dlaka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šapa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rep', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lajati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'granule', v_pos);
  v_pos := pg_temp.word(v_lesson, 'štene', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mačić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cijepiti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fe2a8a40-5f38-5e67-a30e-b8678531993c', 'fill_in_the_blank', 'Svako jutro hranim ___.', 'mačku', '["mačke", "mačku", "mačka", "mački"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '88c60318-273a-53ee-bfa6-714d1e9ec613', 'multiple_choice', 'Що означає «štene»?', 'цуценя', '["кошеня", "годувати", "ветеринар", "цуценя"]'::jsonb, 'A1', 2, 'PUBLISHED', 'štene', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be0c83a2-c009-5df1-b6a8-5efbe629b3fd', 'multiple_choice', 'Що означає «povodac»?', 'повідець', '["цуценя", "мисочка", "повідець", "ветеринар"]'::jsonb, 'A1', 3, 'PUBLISHED', 'povodac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0c6185fe-340b-58db-a74b-9e03e4b66e04', 'multiple_choice', 'Як хорватською «кошеня»?', 'mačić', '["mačić", "dlaka", "kućni ljubimac", "zdjelica"]'::jsonb, 'A1', 4, 'PUBLISHED', 'mačić', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1b8a5b61-2df1-50af-8133-4408c733dfb6', 'type_answer', 'Напишіть хорватською: «хвіст»', 'rep', null, 'A1', 5, 'PUBLISHED', 'rep', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '10635fc9-5429-5dd3-b076-7ef9a01d40d7', 'type_answer', 'Напишіть хорватською: «вакцинувати»', 'cijepiti', null, 'A1', 6, 'PUBLISHED', 'cijepiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fdbbf904-2ff7-5f7d-871b-7838880d4690', 'sentence_builder', 'Складіть: «Пес гавкає на сусіда.»', 'Pas laje na susjeda.', '["Pas", "na", "susjeda.", "laje"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4ee843f1-d9a1-5d7e-a9be-ad77fd4e705f', 'sentence_builder', 'Складіть: «Візьми повідець і мисочку.»', 'Uzmi povodac i zdjelicu.', '["i", "povodac", "Uzmi", "zdjelicu."]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '586c6399-a647-5c32-b947-12e60e202b77', 'listening', 'Прослухайте і складіть фразу', 'Ovo je Max, naše štene.', '["štene.", "naše", "Ovo", "Max,", "je"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a238dcb6-086c-5c74-9ba7-875f6d552ec1', 'listening', 'Прослухайте і складіть фразу', 'Imaš li kućnog ljubimca?', '["kućnog", "li", "ljubimca?", "Imaš"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3d50a6d7-9d70-54eb-87f3-a0e38d4c59cd', 'speaking', 'Мій пес махає хвостом.', 'Moj pas maše repom.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a8afe5ae-42f3-51a1-bfbe-527d7a4d707c', 'speaking', 'Коли треба щепити кошеня?', 'Kada treba cijepiti mačića?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5b1765bd-c094-53ea-98d6-b512a725a2b0', v_lesson, 'У ветеринара', 'Kod veterinara', 1081, 'A1', 'vet', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('52a82bfa-6fb2-5de2-95f6-e7e7915f39d9', '5b1765bd-c094-53ea-98d6-b512a725a2b0', 'Veterinarka', 'Dobar dan. Koga imamo danas?', 'Добрий день. Кого ми маємо сьогодні?', 1);
  perform pg_temp.turn('5400eb99-5341-517f-831d-99c60a99f316', '5b1765bd-c094-53ea-98d6-b512a725a2b0', 'Andrij', 'Ovo je Max, naše štene. Ima tri mjeseca.', 'Це Макс, наше цуценя. Йому три місяці.', 2);
  perform pg_temp.turn('49904470-88d5-500c-861a-964c27a20c20', '5b1765bd-c094-53ea-98d6-b512a725a2b0', 'Veterinarka', 'Danas ga cijepimo. Držite ga, molim.', 'Сьогодні ми його щепимо. Потримайте його, будь ласка.', 3);
  perform pg_temp.turn('ac32588f-acdf-5d2b-85ee-6375db766e16', '5b1765bd-c094-53ea-98d6-b512a725a2b0', 'Andrij', 'Stalno liže šapu. Je li to problem?', 'Він постійно лиже лапу. Це проблема?', 4);
  perform pg_temp.turn('1d62ad19-d610-52b8-bb70-aaa2b8c868fc', '5b1765bd-c094-53ea-98d6-b512a725a2b0', 'Veterinarka', 'Da vidimo. Ne, šapa je u redu.', 'Подивимося. Ні, з лапою все гаразд.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d7d2d995-90ba-5044-87b5-2c42f937b4ae', v_lesson, 'Нове кошеня', 'Novi mačić', 1082, 'A1', 'vet', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('9298d604-3ec2-5aa5-b25a-1afe64c8bfa7', 'd7d2d995-90ba-5044-87b5-2c42f937b4ae', 'Ana', 'Imaš li kućnog ljubimca?', 'У тебе є домашній улюбленець?', 1);
  perform pg_temp.turn('b6bf9f8b-793e-513a-9617-c8abd061f63c', 'd7d2d995-90ba-5044-87b5-2c42f937b4ae', 'Oksana', 'Imam mačića. Djeca ga jako vole.', 'У мене є кошеня. Діти його дуже люблять.', 2);
  perform pg_temp.turn('584ff140-23b1-57ff-a1df-44cb60e4915f', 'd7d2d995-90ba-5044-87b5-2c42f937b4ae', 'Ana', 'Što jede?', 'Що він їсть?', 3);
  perform pg_temp.turn('868e95e7-e79f-542c-9349-58cf3bca8c09', 'd7d2d995-90ba-5044-87b5-2c42f937b4ae', 'Oksana', 'Jede granule i malo mesa. Vodu ima u zdjelici.', 'Їсть сухий корм і трохи м’яса. Вода в нього в мисочці.', 4);
  perform pg_temp.turn('2fcdcfeb-d8ff-599f-a16c-b98098ceecf5', 'd7d2d995-90ba-5044-87b5-2c42f937b4ae', 'Ana', 'A dlaka po kauču?', 'А шерсть на дивані?', 5);
  perform pg_temp.turn('cb252a37-c189-5382-b20d-42ecfacc36ae', 'd7d2d995-90ba-5044-87b5-2c42f937b4ae', 'Oksana', 'Da, usisavam svaki dan!', 'Так, пилососю щодня!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 9: Мій тиждень
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '3365f423-e694-5b55-baa1-3205fba11aff';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 9) then
    raise exception 'A1.1: місце уроку 9 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.1.9'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 9: Мій тиждень', 'Lekcija 9: Moj tjedan', '["Домовитися про час зустрічі", "Розповісти про свій розклад на тиждень", "Перенести або скасувати запис"]'::jsonb, 12, 'PUBLISHED', 9);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'raspored', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obveza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kalendar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podsjetnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaboraviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sjetiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dogovoriti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otkazati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odgoditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'planirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zapisati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dvaput', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tjedno', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '1437b94e-c1c4-53af-8051-dbde7c855fa3', 'fill_in_the_blank', 'Ja ne ___ doći u četvrtak.', 'mogu', '["možeš", "možemo", "može", "mogu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '79f75005-3f6a-5d74-92ac-c756e8610950', 'multiple_choice', 'Що означає «tjedno»?', 'щотижня; на тиждень', '["відкласти", "розклад", "щотижня; на тиждень", "скасувати"]'::jsonb, 'A1', 2, 'PUBLISHED', 'tjedno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5aa2dffd-a075-54b5-b6e5-a57d2140d0f2', 'multiple_choice', 'Що означає «kalendar»?', 'календар', '["обов''язок; справа", "домовитися", "розклад", "календар"]'::jsonb, 'A1', 3, 'PUBLISHED', 'kalendar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0d0b6305-2647-5821-bc32-e57d65902e4b', 'multiple_choice', 'Як хорватською «домовитися»?', 'dogovoriti se', '["odgoditi", "dogovoriti se", "obveza", "dvaput"]'::jsonb, 'A1', 4, 'PUBLISHED', 'dogovoriti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a114c1b3-6b75-5205-8196-fef0b65daf95', 'type_answer', 'Напишіть хорватською: «двічі»', 'dvaput', null, 'A1', 5, 'PUBLISHED', 'dvaput', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d1def45-78c4-50b3-bef3-9e2cb4d99aa3', 'type_answer', 'Напишіть хорватською: «відкласти»', 'odgoditi', null, 'A1', 6, 'PUBLISHED', 'odgoditi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4e87816a-dd2d-577c-958e-59d5204278c6', 'sentence_builder', 'Складіть: «Мушу подивитися розклад.»', 'Moram pogledati raspored.', '["raspored.", "Moram", "pogledati"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '40440391-547a-51ba-ad2b-2193c098f789', 'sentence_builder', 'Складіть: «Я тренуюся двічі на тиждень.»', 'Treniram dvaput tjedno.', '["tjedno.", "Treniram", "dvaput"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aa973178-b5c0-513d-8750-11b0f2e56f8e', 'listening', 'Прослухайте і складіть фразу', 'Može u četvrtak navečer?', '["navečer?", "u", "Može", "četvrtak"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b99eecca-c24c-59bd-88f8-38ad08217967', 'listening', 'Прослухайте і складіть фразу', 'Uvijek zaboravim zapisati.', '["Uvijek", "zapisati.", "zaboravim"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'df70d7e1-18d7-5a84-bf96-efd6f080e6b6', 'speaking', 'Який у тебе план на вихідні?', 'Koji je tvoj plan za vikend?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d255451-79c8-5e1d-a474-3462410f41e2', 'speaking', 'Я хочу спланувати тиждень.', 'Želim planirati tjedan.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8be246de-1a57-5ba0-aae7-767151463b9c', v_lesson, 'Коли ти вільний?', 'Kada si slobodan?', 1091, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('5b74ac92-141b-5fa8-b7e0-da741b76aae3', '8be246de-1a57-5ba0-aae7-767151463b9c', 'Ivan', 'Možemo li se naći ovaj tjedan?', 'Можемо зустрітися цього тижня?', 1);
  perform pg_temp.turn('459fca43-77ec-5bc9-8e69-9dcb5bded8fc', '8be246de-1a57-5ba0-aae7-767151463b9c', 'Taras', 'Moram pogledati raspored. Imam puno obveza.', 'Мушу подивитися розклад. У мене багато справ.', 2);
  perform pg_temp.turn('54f77e3d-9cc7-5573-9fe0-198e9c1c495d', '8be246de-1a57-5ba0-aae7-767151463b9c', 'Ivan', 'Može u četvrtak navečer?', 'Можна в четвер увечері?', 3);
  perform pg_temp.turn('06f0338a-2c44-530c-b7df-b9a13eaa1b6c', '8be246de-1a57-5ba0-aae7-767151463b9c', 'Taras', 'Ne mogu, četvrtkom imam tečaj. Dvaput tjedno.', 'Не можу, по четвергах у мене курси. Двічі на тиждень.', 4);
  perform pg_temp.turn('2f9ccf9d-3adb-5338-a65d-c8dd369222ff', '8be246de-1a57-5ba0-aae7-767151463b9c', 'Ivan', 'Dobro, onda se dogovorimo za subotu.', 'Добре, тоді домовмося на суботу.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('85d47c5f-388e-5c76-9aad-d34aef989404', v_lesson, 'Нагадування', 'Podsjetnik', 1092, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('69a9aeb0-763c-52cd-9b08-18d107bc3ba4', '85d47c5f-388e-5c76-9aad-d34aef989404', 'Olena', 'Joj, ne mogu se sjetiti kada je termin kod zubara.', 'Ой, не можу згадати, коли прийом у стоматолога.', 1);
  perform pg_temp.turn('a3305ab1-972c-56ce-862b-1311bc7f1442', '85d47c5f-388e-5c76-9aad-d34aef989404', 'Marija', 'Pogledaj u kalendar u mobitelu.', 'Подивися в календар у телефоні.', 2);
  perform pg_temp.turn('4acecd2f-e62b-5c55-ab13-b81c1a099ea2', '85d47c5f-388e-5c76-9aad-d34aef989404', 'Olena', 'Nije tamo. Uvijek zaboravim zapisati.', 'Там немає. Я завжди забуваю записати.', 3);
  perform pg_temp.turn('5fa9dabe-45fc-5d38-9364-9781a0aa045b', '85d47c5f-388e-5c76-9aad-d34aef989404', 'Marija', 'Nazovi ordinaciju. Termin možeš odgoditi ili otkazati.', 'Подзвони в кабінет. Прийом можна перенести або скасувати.', 4);
  perform pg_temp.turn('e6aef01a-c355-580d-b14c-0430aec40e1c', '85d47c5f-388e-5c76-9aad-d34aef989404', 'Olena', 'Dobra ideja. I odmah stavljam podsjetnik!', 'Гарна ідея. І одразу ставлю нагадування!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 15: Що на сніданок?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'bb7bc159-cb40-5a8a-91b7-c6da05c6342a';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A1.2: місце уроку 6 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.2.6'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 15: Що на сніданок?', 'Lekcija 15: Što za doručak?', '["Розповісти, що ви їсте на сніданок", "Купити випічку в пекарні", "Назвати продукти для сніданку"]'::jsonb, 12, 'PUBLISHED', 6);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'maslac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'med', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pekmez', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pahuljice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kobasica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'salama', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kajgana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'keks', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kakao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrhnje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'namaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krafna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'integralni', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a9b9cae-1e8e-5363-a8c8-8466d98e01c8', 'fill_in_the_blank', 'Za doručak jedem ___.', 'kajganu', '["kajganom", "kajgana", "kajgani", "kajganu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b417c660-1fd1-571a-a819-061a0b000b39', 'multiple_choice', 'Що означає «med»?', 'мед', '["пластівці", "салямі", "цільнозерновий", "мед"]'::jsonb, 'A1', 2, 'PUBLISHED', 'med', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '50e36ce1-9df1-5d95-bef9-b8350024cdb1', 'multiple_choice', 'Що означає «tost»?', 'тост', '["сосиска; ковбаска", "тост", "какао", "пластівці"]'::jsonb, 'A1', 3, 'PUBLISHED', 'tost', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '54130b0d-b5f7-543c-9b3a-41d42e358aa7', 'multiple_choice', 'Як хорватською «джем; повидло»?', 'pekmez', '["pekmez", "keks", "kajgana", "salama"]'::jsonb, 'A1', 4, 'PUBLISHED', 'pekmez', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '181e976e-14a8-52dd-b652-5b411f635a76', 'type_answer', 'Напишіть хорватською: «цільнозерновий»', 'integralni', null, 'A1', 5, 'PUBLISHED', 'integralni', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '915b7622-0561-5f5d-a587-a9755de4c192', 'type_answer', 'Напишіть хорватською: «пончик»', 'krafna', null, 'A1', 6, 'PUBLISHED', 'krafna', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f3d7d2e6-065c-5960-9024-b63a8e863796', 'sentence_builder', 'Складіть: «Я п’ю каву з вершками.»', 'Pijem kavu s vrhnjem.', '["s", "kavu", "vrhnjem.", "Pijem"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aa25cfa7-29f7-5f54-86d5-932add6c0259', 'sentence_builder', 'Складіть: «Діти їдять пластівці з молоком.»', 'Djeca jedu pahuljice s mlijekom.', '["s", "jedu", "pahuljice", "Djeca", "mlijekom."]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '484ce723-4297-5218-83f2-84ddf32d2cfd', 'listening', 'Прослухайте і складіть фразу', 'Kajganu i tost, molim.', '["i", "tost,", "molim.", "Kajganu"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '849c30c9-9259-5579-b717-0db1264d96bf', 'listening', 'Прослухайте і складіть фразу', 'Jedan integralni kruh i dvije krafne.', '["krafne.", "integralni", "Jedan", "dvije", "i", "kruh"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '667eff0b-ee36-5e8c-a08f-40cd026cc60e', 'speaking', 'Купи, будь ласка, сосиски й печиво.', 'Kupi, molim te, kobasice i kekse.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '13dd68d7-f059-598f-a316-e50750ea57fd', 'speaking', 'Я не їм солодкого на сніданок.', 'Ne jedem slatko za doručak.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5e29f630-589f-5e2b-b03e-90117bddc9b0', v_lesson, 'Сніданок удома', 'Doručak kod kuće', 1151, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('989d70cb-e4ac-513e-8b96-b2f96c6c81dc', '5e29f630-589f-5e2b-b03e-90117bddc9b0', 'Mama', 'Što želiš za doručak? Pahuljice ili kajganu?', 'Що хочеш на сніданок? Пластівці чи яєчню?', 1);
  perform pg_temp.turn('87f91bbb-b6dd-59a1-9576-dffdf384dc3b', '5e29f630-589f-5e2b-b03e-90117bddc9b0', 'Danilo', 'Kajganu i tost, molim.', 'Яєчню й тост, будь ласка.', 2);
  perform pg_temp.turn('c2986046-4e3f-5a6f-9947-8d1a9d1d5122', '5e29f630-589f-5e2b-b03e-90117bddc9b0', 'Mama', 'Tost s maslacem ili s pekmezom?', 'Тост з маслом чи з джемом?', 3);
  perform pg_temp.turn('24d89576-5840-5385-8ec0-d372edb239bf', '5e29f630-589f-5e2b-b03e-90117bddc9b0', 'Danilo', 'S medom! I topli kakao.', 'З медом! І гаряче какао.', 4);
  perform pg_temp.turn('e1553785-9e55-55f9-af34-9286834fb0f1', '5e29f630-589f-5e2b-b03e-90117bddc9b0', 'Mama', 'Evo. Jedi polako.', 'Ось. Їж повільно.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ce598cb5-91ef-5431-bc14-cbab86de8bef', v_lesson, 'У пекарні', 'U pekari', 1152, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('7fd9ad6b-d179-5f52-80e2-10981e4315eb', 'ce598cb5-91ef-5431-bc14-cbab86de8bef', 'Prodavačica', 'Izvolite?', 'Прошу?', 1);
  perform pg_temp.turn('533d8915-fb6c-53a1-b3eb-345f764725cc', 'ce598cb5-91ef-5431-bc14-cbab86de8bef', 'Oksana', 'Jedan integralni kruh i dvije krafne.', 'Одну цільнозернову хлібину і два пончики.', 2);
  perform pg_temp.turn('ab2b8242-c1bf-5502-ae0a-29bb0563afe2', 'ce598cb5-91ef-5431-bc14-cbab86de8bef', 'Prodavačica', 'Krafne s čokoladom ili s marmeladom?', 'Пончики з шоколадом чи з мармеладом?', 3);
  perform pg_temp.turn('3db5a22c-f5b5-5713-90ed-b4fd36afd540', 'ce598cb5-91ef-5431-bc14-cbab86de8bef', 'Oksana', 'S čokoladom. Imate li i neki slani namaz?', 'З шоколадом. А у вас є якась солона намазка?', 4);
  perform pg_temp.turn('ab85e9c8-2c9e-56a9-afc8-f3b346eed590', 'ce598cb5-91ef-5431-bc14-cbab86de8bef', 'Prodavačica', 'Imamo namaz od sira i salamu.', 'Є сирна намазка і салямі.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 16: Готуємо суп
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '17fcd38a-e295-5849-9ba3-1ef240c6be78';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A1.2: місце уроку 7 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.2.7'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 16: Готуємо суп', 'Lekcija 16: Kuhamo juhu', '["Зрозуміти простий рецепт", "Пояснити, як приготувати страву", "Назвати посуд і овочі на кухні"]'::jsonb, 12, 'PUBLISHED', 7);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'lonac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rezati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'miješati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pržiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'peći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oguliti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mrkva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupus', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grah', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zagrijati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dodati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posoliti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poklopac', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '88af5f9e-0aab-5c7f-af05-2f10e5225de3', 'fill_in_the_blank', '___ mrkvu na male komade.', 'Reži', '["Reže", "Reži", "Režem", "Rezati"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cea304b1-89a9-512d-abfe-64f6afc0b1b0', 'multiple_choice', 'Що означає «tava»?', 'сковорідка', '["смажити", "додати", "розігріти; нагріти", "сковорідка"]'::jsonb, 'A1', 2, 'PUBLISHED', 'tava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '184d0eac-82d4-5cf2-9bb9-ad79ce760468', 'multiple_choice', 'Що означає «miješati»?', 'мішати; перемішувати', '["кришка", "каструля", "розігріти; нагріти", "мішати; перемішувати"]'::jsonb, 'A1', 3, 'PUBLISHED', 'miješati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '421dca51-811e-5840-a7ba-6424191a4c8d', 'multiple_choice', 'Як хорватською «смажити»?', 'pržiti', '["oguliti", "grah", "kupus", "pržiti"]'::jsonb, 'A1', 4, 'PUBLISHED', 'pržiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f0a0b11-980f-529c-8114-610ab526036f', 'type_answer', 'Напишіть хорватською: «пекти; запікати»', 'peći', null, 'A1', 5, 'PUBLISHED', 'peći', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b879992d-52ad-562f-b514-a7905b976365', 'type_answer', 'Напишіть хорватською: «кришка»', 'poklopac', null, 'A1', 6, 'PUBLISHED', 'poklopac', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd534891-707a-5228-ab6c-6bf3b95ef5ca', 'sentence_builder', 'Складіть: «Спочатку почисть картоплю.»', 'Prvo oguli krumpir.', '["krumpir.", "Prvo", "oguli"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e897aee5-d3e5-5927-b0d4-6b65e42ca2bb', 'sentence_builder', 'Складіть: «Посоли суп наприкінці.»', 'Posoli juhu na kraju.', '["juhu", "na", "Posoli", "kraju."]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd8e206ec-0a7c-52ba-bbba-313ae1552e0f', 'listening', 'Прослухайте і складіть фразу', 'Trebam li dodati grah?', '["Trebam", "li", "grah?", "dodati"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ef29913d-bc29-57da-bb1a-6c7f41740d2c', 'listening', 'Прослухайте і складіть фразу', 'Pržimo kupus s lukom u tavi.', '["kupus", "Pržimo", "u", "lukom", "s", "tavi."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd8c76227-3f11-57b1-8444-874a3305dda7', 'speaking', 'Перемішай і накрий кришкою.', 'Promiješaj i stavi poklopac.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '822e9001-2703-5d01-9838-e07de7269060', 'speaking', 'Розігрій суп, будь ласка.', 'Zagrij juhu, molim te.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ba528052-1169-59cd-a100-a7ebb3fb1d79', v_lesson, 'Бабусин рецепт', 'Bakin recept', 1161, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('ecd2e079-c7e7-5d77-82c5-b5e36648f357', 'ba528052-1169-59cd-a100-a7ebb3fb1d79', 'Baka', 'Prvo oguli mrkvu i krumpir.', 'Спочатку почисть моркву й картоплю.', 1);
  perform pg_temp.turn('60a6c338-637c-5d77-8989-40b0650110b1', 'ba528052-1169-59cd-a100-a7ebb3fb1d79', 'Ivana', 'Gotovo. Što sada?', 'Готово. Що тепер?', 2);
  perform pg_temp.turn('391b3989-aaca-5223-a7e4-380b92031bdd', 'ba528052-1169-59cd-a100-a7ebb3fb1d79', 'Baka', 'Reži ih na male komade i stavi u lonac.', 'Наріж їх маленькими шматками й поклади в каструлю.', 3);
  perform pg_temp.turn('efb4eed4-e0ef-5f5c-91c8-b0c0f2cb81ba', 'ba528052-1169-59cd-a100-a7ebb3fb1d79', 'Ivana', 'Trebam li dodati grah?', 'Мені додати квасолю?', 4);
  perform pg_temp.turn('2677b275-36f7-5f59-886b-3cc8d01c294c', 'ba528052-1169-59cd-a100-a7ebb3fb1d79', 'Baka', 'Da. Kuhaj pola sata, miješaj i stavi poklopac.', 'Так. Вари пів години, помішуй і накрий кришкою.', 5);
  perform pg_temp.turn('b687b205-55b7-5fa3-a8a1-d60ded55fab0', 'ba528052-1169-59cd-a100-a7ebb3fb1d79', 'Ivana', 'I posolim na kraju, zar ne?', 'І посолю наприкінці, так?', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('94da4c0e-5407-58ca-b861-635cd861787e', v_lesson, 'Вечеря на сковороді', 'Večera u tavi', 1162, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('4941189b-4746-5e9f-b378-2a6275e8a5c8', '94da4c0e-5407-58ca-b861-635cd861787e', 'Taras', 'Što danas kuhamo?', 'Що сьогодні готуємо?', 1);
  perform pg_temp.turn('173127a9-4694-543e-b96f-aa89ca26ebf1', '94da4c0e-5407-58ca-b861-635cd861787e', 'Olena', 'Pržimo kupus s lukom u tavi.', 'Смажимо капусту з цибулею на сковороді.', 2);
  perform pg_temp.turn('7db81a3f-5ed3-5a62-a66c-9ec11a1542e4', '94da4c0e-5407-58ca-b861-635cd861787e', 'Taras', 'A meso?', 'А м’ясо?', 3);
  perform pg_temp.turn('c8c15a4a-47d7-5d80-a75f-7dac72b2be81', '94da4c0e-5407-58ca-b861-635cd861787e', 'Olena', 'Meso pečemo u pećnici. Zagrij je na dvjesto stupnjeva.', 'М’ясо запікаємо в духовці. Розігрій її до двохсот градусів.', 4);
  perform pg_temp.turn('f319d0c3-51ae-5bc0-ac4f-c8556ec1f63a', '94da4c0e-5407-58ca-b861-635cd861787e', 'Taras', 'Dobro. Već je vruće!', 'Добре. Уже гаряче!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 17: У м’ясника й на рибному ринку
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'ae33e31a-f937-5305-908e-3d957df15f6a';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 8) then
    raise exception 'A1.2: місце уроку 8 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.2.8'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 17: У м’ясника й на рибному ринку', 'Lekcija 17: U mesnici i ribarnici', '["Купити м’ясо в м’ясника", "Купити рибу й попросити її почистити", "Сказати кількість: пів кіло, кілограм"]'::jsonb, 12, 'PUBLISHED', 8);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'mesnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ribarnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'govedina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'janjetina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'puretina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mljeveno meso', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odrezak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lignja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srdela', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dagnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'file', v_pos);
  v_pos := pg_temp.word(v_lesson, 'očistiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plodovi mora', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a4779a3f-3ec3-55d9-ad4c-842375351ed0', 'fill_in_the_blank', 'Trebam kilogram ___.', 'govedine', '["govedine", "govedini", "govedina", "govedinu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '382fc23d-1135-5ef6-af6e-a1c36b55433f', 'multiple_choice', 'Що означає «odrezak»?', 'відбивна; стейк', '["ринок риби", "відбивна; стейк", "фарш", "баранина (ягнятина)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'odrezak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '48434ad2-a2fe-5789-adc8-1c28a2e6d2e8', 'multiple_choice', 'Що означає «mljeveno meso»?', 'фарш', '["фарш", "яловичина", "баранина (ягнятина)", "відбивна; стейк"]'::jsonb, 'A1', 3, 'PUBLISHED', 'mljeveno meso', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b45ea9d4-3f3b-5528-a357-f28cec4ecbe2', 'multiple_choice', 'Як хорватською «філе»?', 'file', '["ribarnica", "mesnica", "file", "janjetina"]'::jsonb, 'A1', 4, 'PUBLISHED', 'file', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2ec9fbdd-2ecc-59d7-8113-87d422b32c0e', 'type_answer', 'Напишіть хорватською: «мідія»', 'dagnja', null, 'A1', 5, 'PUBLISHED', 'dagnja', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c80398ba-91e3-5d08-ad18-316063c5db3b', 'type_answer', 'Напишіть хорватською: «кальмар»', 'lignja', null, 'A1', 6, 'PUBLISHED', 'lignja', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '20f3b7a0-ab2c-512d-ad4b-720ecf455b1f', 'sentence_builder', 'Складіть: «Мені потрібно пів кілограма фаршу.»', 'Trebam pola kile mljevenog mesa.', '["kile", "Trebam", "pola", "mljevenog", "mesa."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a25b1287-0a97-5ecb-9d9a-f2c11bdb263a', 'sentence_builder', 'Складіть: «Ця риба без кісток.»', 'Ova riba je bez kostiju.', '["bez", "kostiju.", "je", "Ova", "riba"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3cd9c498-a4ac-5012-b8ee-810b9ac1b775', 'listening', 'Прослухайте і складіть фразу', 'Govedine ili svinjetine?', '["Govedine", "svinjetine?", "ili"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'de2e3d3f-6740-59a2-b795-02f64b46d325', 'listening', 'Прослухайте і складіть фразу', 'Možete li ih očistiti?', '["ih", "očistiti?", "li", "Možete"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '763d4159-20c7-5387-baf4-355f3879b9f2', 'speaking', 'Скільки коштує кілограм кальмарів?', 'Koliko košta kilogram lignji?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c112e0df-d06d-5337-bbd6-24b1baf66e83', 'speaking', 'Де тут м’ясна крамниця?', 'Gdje je ovdje mesnica?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c83ddcd8-c649-5fa3-aa64-ce66626ea769', v_lesson, 'У м’ясника', 'U mesnici', 1171, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('8903aab9-1b73-500f-93c8-20d539c7fddb', 'c83ddcd8-c649-5fa3-aa64-ce66626ea769', 'Mesar', 'Dobar dan, izvolite.', 'Добрий день, прошу.', 1);
  perform pg_temp.turn('a97b2e36-4d7d-52af-a540-cbc74bea7add', 'c83ddcd8-c649-5fa3-aa64-ce66626ea769', 'Olena', 'Trebam pola kile mljevenog mesa.', 'Мені потрібно пів кілограма фаршу.', 2);
  perform pg_temp.turn('4dc15bde-bd79-5a53-936e-36feea46ab02', 'c83ddcd8-c649-5fa3-aa64-ce66626ea769', 'Mesar', 'Govedine ili svinjetine?', 'Яловичого чи свинячого?', 3);
  perform pg_temp.turn('9185a0ef-4161-505d-9100-2d463cb680c6', 'c83ddcd8-c649-5fa3-aa64-ce66626ea769', 'Olena', 'Govedine. I dva odreska od puretine, molim.', 'Яловичого. І дві відбивні з індички, будь ласка.', 4);
  perform pg_temp.turn('edd535d6-d8c1-5583-a8cb-cbbb896b5df7', 'c83ddcd8-c649-5fa3-aa64-ce66626ea769', 'Mesar', 'Još nešto? Danas imamo i janjetinu.', 'Ще щось? Сьогодні в нас є й баранина.', 5);
  perform pg_temp.turn('d2748ac4-463a-51a2-96ae-7fc3bd110587', 'c83ddcd8-c649-5fa3-aa64-ce66626ea769', 'Olena', 'Ne, hvala. To je sve.', 'Ні, дякую. Це все.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c7f1b189-c4c7-5e48-bcca-29de67e387e7', v_lesson, 'На рибному ринку', 'U ribarnici', 1172, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('119d967f-8d05-54e1-b9f5-e6a2ee650e80', 'c7f1b189-c4c7-5e48-bcca-29de67e387e7', 'Taras', 'Koliko košta kilogram srdela?', 'Скільки коштує кілограм сардин?', 1);
  perform pg_temp.turn('9fa7ba67-2ee9-5410-9ade-f4e4fbb2a232', 'c7f1b189-c4c7-5e48-bcca-29de67e387e7', 'Prodavač', 'Pet eura. Svježe su, od jutros.', 'П’ять євро. Свіжі, з самого ранку.', 2);
  perform pg_temp.turn('b50454f9-04d4-54c0-9e06-ac2cccb9c0aa', 'c7f1b189-c4c7-5e48-bcca-29de67e387e7', 'Taras', 'Možete li ih očistiti?', 'Можете їх почистити?', 3);
  perform pg_temp.turn('3b78602d-b1ce-5a56-b8b0-9d814e2a445f', 'c7f1b189-c4c7-5e48-bcca-29de67e387e7', 'Prodavač', 'Naravno. Želite li i malo lignji ili dagnji?', 'Звісно. Хочете ще трохи кальмарів чи мідій?', 4);
  perform pg_temp.turn('6af8cdeb-8f23-5651-87a4-002e500d0ca0', 'c7f1b189-c4c7-5e48-bcca-29de67e387e7', 'Taras', 'Ne, žena ne voli plodove mora. Ali uzimam file bez kostiju.', 'Ні, дружина не любить морепродукти. Але візьму філе без кісток.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 18: Обід на роботі
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '2c192d05-f259-53b6-a6ec-55ebfb25ec01';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 9) then
    raise exception 'A1.2: місце уроку 9 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.2.9'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 18: Обід на роботі', 'Lekcija 18: Gablec i marenda', '["Пообідати в їдальні", "Запитати про денне меню й гарнір", "Зрозуміти слова «gablec» і «marenda»"]'::jsonb, 12, 'PUBLISHED', 9);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'gablec', v_pos);
  v_pos := pg_temp.word(v_lesson, 'marenda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'menza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'varivo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dnevni meni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'porcija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prilog', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pečen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kuhan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pohan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pire', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mahune', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pladanj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grašak', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'feae11d3-f80d-5c60-9ab2-5737f4f0434b', 'fill_in_the_blank', '___ košta jedna porcija?', 'Koliko', '["Koliko", "Čiji", "Kamo", "Tko"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2a9b771e-f6cd-5431-b4bf-0929604310c9', 'multiple_choice', 'Що означає «pladanj»?', 'таця', '["запечений; смажений (у духовці)", "їдальня", "варений", "таця"]'::jsonb, 'A1', 2, 'PUBLISHED', 'pladanj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b02ea4d9-5057-5f02-bdf3-51285cacea02', 'multiple_choice', 'Що означає «varivo»?', 'рагу (густа страва з овочів)', '["рагу (густа страва з овочів)", "денне меню", "порція", "таця"]'::jsonb, 'A1', 3, 'PUBLISHED', 'varivo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '07c1f0e2-a089-59ad-be59-250859cc3dc5', 'multiple_choice', 'Як хорватською «перекус / пізній сніданок»?', 'marenda', '["gablec", "marenda", "dnevni meni", "prilog"]'::jsonb, 'A1', 4, 'PUBLISHED', 'marenda', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b3254638-0a38-5fbe-869a-0303ababeea0', 'type_answer', 'Напишіть хорватською: «горошок»', 'grašak', null, 'A1', 5, 'PUBLISHED', 'grašak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b8c56057-10ea-5e9a-a82b-177f7226202a', 'type_answer', 'Напишіть хорватською: «гарнір»', 'prilog', null, 'A1', 6, 'PUBLISHED', 'prilog', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '96ef9e56-de37-5a74-8ed2-bae4cb5e4b2e', 'sentence_builder', 'Складіть: «Який сьогодні гарнір?»', 'Koji je danas prilog?', '["je", "prilog?", "danas", "Koji"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8ea63ffb-9a98-508a-a9c9-6700754bc29c', 'sentence_builder', 'Складіть: «Візьміть тацю, будь ласка.»', 'Uzmite pladanj, molim.', '["pladanj,", "Uzmite", "molim."]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9611b853-fcde-5495-a15f-50b1f5336bef', 'listening', 'Прослухайте і складіть фразу', 'Što je danas dnevni meni?', '["meni?", "danas", "dnevni", "Što", "je"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b9354dfa-fe8a-5363-bb54-8217532e83b3', 'listening', 'Прослухайте і складіть фразу', 'Kamo ideš na gablec?', '["gablec?", "Kamo", "ideš", "na"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8bc849d1-0cbc-5dae-a401-30b6b2b95eab', 'speaking', 'Одну порцію рагу, будь ласка.', 'Jednu porciju variva, molim.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '64775b20-08cb-5560-9e9c-3608a140f065', 'speaking', 'Де тут їдальня?', 'Gdje je ovdje menza?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('697b4f7f-f650-501a-96d1-e0b5737d3b04', v_lesson, 'У їдальні', 'U menzi', 1181, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('617a88f9-0631-531b-8ddf-3d1ad31009e4', '697b4f7f-f650-501a-96d1-e0b5737d3b04', 'Kuharica', 'Izvolite, što želite?', 'Прошу, що бажаєте?', 1);
  perform pg_temp.turn('0aea1962-45c1-5113-a661-4e930327a9d4', '697b4f7f-f650-501a-96d1-e0b5737d3b04', 'Andrij', 'Što je danas dnevni meni?', 'Що сьогодні в денному меню?', 2);
  perform pg_temp.turn('d626eb3c-07c2-53b6-8272-2e8a684ba698', '697b4f7f-f650-501a-96d1-e0b5737d3b04', 'Kuharica', 'Pohana piletina ili varivo od mahuna.', 'Курка в паніровці або рагу зі стручкової квасолі.', 3);
  perform pg_temp.turn('54ea1147-34ef-5bc0-81b0-c2731f15e9f8', '697b4f7f-f650-501a-96d1-e0b5737d3b04', 'Andrij', 'Piletinu, molim. Koji je prilog?', 'Курку, будь ласка. Який гарнір?', 4);
  perform pg_temp.turn('dbc5665a-c087-58a5-b9f0-ae7e9ee3c586', '697b4f7f-f650-501a-96d1-e0b5737d3b04', 'Kuharica', 'Pire ili kuhani krumpir. Uzmite pladanj.', 'Пюре або варена картопля. Візьміть тацю.', 5);
  perform pg_temp.turn('bba33124-3846-501f-813a-56c3a5a81969', '697b4f7f-f650-501a-96d1-e0b5737d3b04', 'Andrij', 'Pire, molim. Koliko to košta?', 'Пюре, будь ласка. Скільки це коштує?', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7aaa41af-8f4c-590b-8b57-450657ac5a6b', v_lesson, 'Перерва на обід', 'Pauza za gablec', 1182, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('ff9c79d5-2d25-5302-bc55-6e6316fa4d7a', '7aaa41af-8f4c-590b-8b57-450657ac5a6b', 'Ivan', 'Kamo ideš na gablec?', 'Куди ти йдеш обідати?', 1);
  perform pg_temp.turn('c3eaf263-9b80-5d23-ac31-dc5bc8b7029e', '7aaa41af-8f4c-590b-8b57-450657ac5a6b', 'Taras', 'Što je gablec?', 'Що таке «габлец»?', 2);
  perform pg_temp.turn('1be9681b-fa16-563d-85b3-cb1dc0e4f0cc', '7aaa41af-8f4c-590b-8b57-450657ac5a6b', 'Ivan', 'U Zagrebu tako zovemo topli obrok na poslu. U Dalmaciji je to marenda.', 'У Загребі так називаємо гарячу їжу на роботі. У Далмації це «маренда».', 3);
  perform pg_temp.turn('5e12e5c1-2cb6-5dbf-89ff-37baeb5f2464', '7aaa41af-8f4c-590b-8b57-450657ac5a6b', 'Taras', 'Zanimljivo! Gdje jedemo?', 'Цікаво! Де поїмо?', 4);
  perform pg_temp.turn('47920f1a-33f3-575c-91c3-1e3d2c111664', '7aaa41af-8f4c-590b-8b57-450657ac5a6b', 'Ivan', 'Ovdje blizu. Imaju pečenu piletinu s graškom.', 'Тут поруч. У них є запечена курка з горошком.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 24: Зимовий одяг
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'c8297811-44ed-55a2-8cb5-d1bd9b8a6a73';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A1.3: місце уроку 6 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.3.6'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 24: Зимовий одяг', 'Lekcija 24: Zimska odjeća', '["Вибрати одяг за погодою", "Порівняти речі: тепліший, дешевший, кращий", "Назвати зимовий одяг і взуття"]'::jsonb, 12, 'PUBLISHED', 6);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kaput', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šal', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kapa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rukavice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čizme', v_pos);
  v_pos := pg_temp.word(v_lesson, 'džemper', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čarape', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tenisice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pidžama', v_pos);
  v_pos := pg_temp.word(v_lesson, 'debeo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tanak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vuna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nepromočiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'suknja', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b67a8b79-dd84-5913-a0d7-eb068316b18b', 'fill_in_the_blank', 'Kaput je ___ od jakne.', 'topliji', '["topao", "toplo", "topliji", "najtopliji"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cab60b57-d1f6-553c-9aa8-5acc6616c8ae', 'multiple_choice', 'Що означає «vuna»?', 'вовна', '["непромокальний", "спідниця", "рукавички", "вовна"]'::jsonb, 'A1', 2, 'PUBLISHED', 'vuna', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c00a8f9b-17db-56f1-b496-792bf4300fd8', 'multiple_choice', 'Що означає «čarape»?', 'шкарпетки', '["светр", "тонкий", "спідниця", "шкарпетки"]'::jsonb, 'A1', 3, 'PUBLISHED', 'čarape', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a8be1a4-a123-572f-a2f3-0b26037f56e3', 'multiple_choice', 'Як хорватською «спідниця»?', 'suknja', '["tanak", "suknja", "džemper", "vuna"]'::jsonb, 'A1', 4, 'PUBLISHED', 'suknja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e4c2d124-c8a9-5e5b-b801-279901ac9848', 'type_answer', 'Напишіть хорватською: «непромокальний»', 'nepromočiv', null, 'A1', 5, 'PUBLISHED', 'nepromočiv', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7fcbea9e-3284-5697-9047-e11640b12414', 'type_answer', 'Напишіть хорватською: «тонкий»', 'tanak', null, 'A1', 6, 'PUBLISHED', 'tanak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ce4fc168-011f-5a7a-9bae-9d5aea48e977', 'sentence_builder', 'Складіть: «Цей светр з вовни.»', 'Ovaj džemper je od vune.', '["je", "Ovaj", "džemper", "vune.", "od"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f7c7f11a-afd0-5e52-bc45-489cad2fec4f', 'sentence_builder', 'Складіть: «Кросівки зручніші за чоботи.»', 'Tenisice su udobnije od čizama.', '["Tenisice", "su", "čizama.", "od", "udobnije"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '529de739-5339-52ad-8c11-7e71e5e2e6b1', 'listening', 'Прослухайте і складіть фразу', 'Onda jaknu i debeli džemper.', '["Onda", "džemper.", "debeli", "i", "jaknu"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fb3b3ca1-29bd-5b70-9f52-3f4167704eb3', 'listening', 'Прослухайте і складіть фразу', 'Tražim nepromočive čizme za kćer.', '["Tražim", "za", "čizme", "kćer.", "nepromočive"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a638614-d359-5db8-94e3-78302ca34ec6', 'speaking', 'Мені потрібні тепла шапка й шарф.', 'Trebam toplu kapu i šal.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '765900df-111d-5691-ad30-8a1020f1ab77', 'speaking', 'Ця спідниця коротша за ту.', 'Ova suknja je kraća od one.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2f3d3ccf-45bb-5031-973b-3adbc818c2d8', v_lesson, 'Що вдягти?', 'Što obući?', 1241, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('fe84bb16-0700-528e-9fce-288b1f47f6af', '2f3d3ccf-45bb-5031-973b-3adbc818c2d8', 'Ana', 'Sutra je minus pet. Obuci kaput, ne jaknu!', 'Завтра мінус п’ять. Вдягни пальто, а не куртку!', 1);
  perform pg_temp.turn('69c1c316-cfe6-596c-9005-8c4adb24a0a2', '2f3d3ccf-45bb-5031-973b-3adbc818c2d8', 'Olena', 'Kaput je topliji, ali jakna je udobnija.', 'Пальто тепліше, але куртка зручніша.', 2);
  perform pg_temp.turn('56d7f8dc-68ff-528d-8990-909beb3313af', '2f3d3ccf-45bb-5031-973b-3adbc818c2d8', 'Ana', 'Onda jaknu i debeli džemper. I kapu i šal!', 'Тоді куртку й товстий светр. І шапку, і шарф!', 3);
  perform pg_temp.turn('48640cc6-2f8c-5d5b-899b-63f516bdc758', '2f3d3ccf-45bb-5031-973b-3adbc818c2d8', 'Olena', 'A rukavice? Gdje su mi rukavice?', 'А рукавички? Де мої рукавички?', 4);
  perform pg_temp.turn('03dc253c-5aea-55fc-bcc0-03a153944943', '2f3d3ccf-45bb-5031-973b-3adbc818c2d8', 'Ana', 'U ladici, pored čarapa.', 'У шухляді, біля шкарпеток.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('20091aa3-b7a3-533f-a445-e8a28db9d7c2', v_lesson, 'Купуємо чоботи', 'Kupujemo čizme', 1242, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('ca9fa8d6-ab11-5a31-8091-2985d6c3788a', '20091aa3-b7a3-533f-a445-e8a28db9d7c2', 'Prodavač', 'Trebate li pomoć?', 'Вам допомогти?', 1);
  perform pg_temp.turn('0de9ea5a-279e-5995-b1e6-c06f77364b1d', '20091aa3-b7a3-533f-a445-e8a28db9d7c2', 'Taras', 'Tražim nepromočive čizme za kćer.', 'Шукаю непромокальні чоботи для доньки.', 2);
  perform pg_temp.turn('bbc5e924-84f0-57be-a91d-930035851403', '20091aa3-b7a3-533f-a445-e8a28db9d7c2', 'Prodavač', 'Ove su najbolje. A ove su jeftinije, ali tanje.', 'Ці найкращі. А ці дешевші, але тонші.', 3);
  perform pg_temp.turn('aeb68b2d-ac36-5d7b-a5f8-69fc14e31eb5', '20091aa3-b7a3-533f-a445-e8a28db9d7c2', 'Taras', 'Uzimam bolje. I jednu pidžamu od pamuka.', 'Беру кращі. І одну бавовняну піжаму.', 4);
  perform pg_temp.turn('08eaeedf-034c-5240-80e7-5cbf9c362d52', '20091aa3-b7a3-533f-a445-e8a28db9d7c2', 'Prodavač', 'Pidžame su lijevo, kod suknji.', 'Піжами ліворуч, біля спідниць.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 25: Меблі для квартири
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'de93d3ab-6769-5daf-9560-8858285a8136';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A1.3: місце уроку 7 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.3.7'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 25: Меблі для квартири', 'Lekcija 25: Namještaj za stan', '["Купити меблі й домовитися про доставку", "Сказати, де лежать речі", "Зібрати меблі за інструкцією"]'::jsonb, 12, 'PUBLISHED', 7);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'madrac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zavjesa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posteljina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ladica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'komoda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vješalica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stolić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naslonjač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sklopiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vijak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'montirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dostaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'širok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uzak', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '14277300-d425-5001-9c77-e6b013554f99', 'fill_in_the_blank', 'Ključevi su u ___.', 'ladici', '["ladici", "ladice", "ladica", "ladicu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '293ba234-a2b9-5df2-ac63-cfb25d910308', 'multiple_choice', 'Що означає «ladica»?', 'шухляда', '["шухляда", "постільна білизна", "широкий", "завіса, штора"]'::jsonb, 'A1', 2, 'PUBLISHED', 'ladica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c30641d-c494-5689-834b-ced61ac571a3', 'multiple_choice', 'Що означає «širok»?', 'широкий', '["столик", "постільна білизна", "широкий", "гвинт; шуруп"]'::jsonb, 'A1', 3, 'PUBLISHED', 'širok', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '21d7de9f-16dd-5cc0-9140-4364092faff8', 'multiple_choice', 'Як хорватською «вузький»?', 'uzak', '["širok", "uzak", "zavjesa", "stolić"]'::jsonb, 'A1', 4, 'PUBLISHED', 'uzak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a2010731-092c-5365-90d6-4931b4e0f5fc', 'type_answer', 'Напишіть хорватською: «гвинт; шуруп»', 'vijak', null, 'A1', 5, 'PUBLISHED', 'vijak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '82848cfb-a1b2-5cd5-94e7-7733c6bb20a9', 'type_answer', 'Напишіть хорватською: «монтувати; встановлювати»', 'montirati', null, 'A1', 6, 'PUBLISHED', 'montirati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1732977b-43da-556a-b14b-346468eace10', 'sentence_builder', 'Складіть: «Повісь пальто на вішалку.»', 'Objesi kaput na vješalicu.', '["vješalicu.", "Objesi", "na", "kaput"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5c6b48e8-b5a7-5fed-bf55-14fdaaccf269', 'sentence_builder', 'Складіть: «Постіль лежить у комоді.»', 'Posteljina je u komodi.', '["je", "u", "Posteljina", "komodi."]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '93e6912a-5933-502a-996f-139eefe8f5c0', 'listening', 'Прослухайте і складіть фразу', 'Trebamo madrac i komodu za spavaću sobu.', '["Trebamo", "komodu", "za", "i", "spavaću", "madrac", "sobu."]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '03a95033-f332-55fd-a4c4-e8eb69f254b4', 'listening', 'Прослухайте і складіть фразу', 'Gdje je odvijač?', '["je", "Gdje", "odvijač?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c13c4dbd-df1b-5c79-9e54-7eb9f916afe3', 'speaking', 'Шафу треба зібрати самим.', 'Ormar moramo sami sklopiti.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a05f6c7e-e778-5b19-a67a-8bdeaac39cf3', 'speaking', 'Пульт лежить на столику.', 'Daljinski je na stoliću.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3ede0ee4-f761-56e4-8c18-e58a6e5a1ca5', v_lesson, 'У меблевому магазині', 'U trgovini namještajem', 1251, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('402cb848-80f4-5f55-bf8a-47a440d067c6', '3ede0ee4-f761-56e4-8c18-e58a6e5a1ca5', 'Prodavačica', 'Izvolite, što tražite?', 'Прошу, що шукаєте?', 1);
  perform pg_temp.turn('f1bf2156-2cc5-5fea-9eec-e845e9c37662', '3ede0ee4-f761-56e4-8c18-e58a6e5a1ca5', 'Oksana', 'Trebamo madrac i komodu za spavaću sobu.', 'Нам потрібні матрац і комод для спальні.', 2);
  perform pg_temp.turn('83a50bcb-a57e-5e02-acb4-fe72a8492ac7', '3ede0ee4-f761-56e4-8c18-e58a6e5a1ca5', 'Prodavačica', 'Kolika je soba? Ova komoda je široka, a ona je uska.', 'Яка у вас кімната? Цей комод широкий, а той вузький.', 3);
  perform pg_temp.turn('2a889f35-86af-5ea8-88d9-b3a5dc4bea02', '3ede0ee4-f761-56e4-8c18-e58a6e5a1ca5', 'Oksana', 'Soba je mala. Uzimamo usku. Možete li je dostaviti?', 'Кімната маленька. Беремо вузький. Можете його доставити?', 4);
  perform pg_temp.turn('36c70b4d-87b4-5330-a1d6-41db0744110d', '3ede0ee4-f761-56e4-8c18-e58a6e5a1ca5', 'Prodavačica', 'Da, u subotu. Za deset eura je i montiramo.', 'Так, у суботу. За десять євро ми його й зберемо.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('33e00683-1c03-5f74-8e06-fd003a905e64', v_lesson, 'Збираємо шафу', 'Sklapamo ormar', 1252, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('dbb967b6-882b-509a-a033-b744519a3c57', '33e00683-1c03-5f74-8e06-fd003a905e64', 'Taras', 'U uputama piše dvadeset vijaka. Ja imam devetnaest!', 'В інструкції написано двадцять гвинтів. А в мене дев’ятнадцять!', 1);
  perform pg_temp.turn('eb375d68-3255-5ddb-9edf-03bec9567c07', '33e00683-1c03-5f74-8e06-fd003a905e64', 'Olena', 'Pogledaj u kutiji. Možda je na dnu.', 'Подивися в коробці. Може, він на дні.', 2);
  perform pg_temp.turn('b1f1e752-7bac-560f-9c2a-71fcabc4a168', '33e00683-1c03-5f74-8e06-fd003a905e64', 'Taras', 'Nije. Gdje je odvijač?', 'Нема. Де викрутка?', 3);
  perform pg_temp.turn('52695656-d5de-5416-820d-e05a6be7c1e2', '33e00683-1c03-5f74-8e06-fd003a905e64', 'Olena', 'Na stoliću, pored zavjese.', 'На столику, біля штори.', 4);
  perform pg_temp.turn('30959d21-180b-580d-b5d7-3d28c03e8f0e', '33e00683-1c03-5f74-8e06-fd003a905e64', 'Taras', 'Evo ga! Vijak je u naslonjaču.', 'Ось він! Гвинт у кріслі.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- 4. Наскрізні номери всіх уроків A1 («Урок N: …» / «Lekcija N: …») за модулем і місцем; стара назва — у content_versions
do $$
declare r record; v_payload jsonb; v_ua text; v_hr text;
begin
  for r in
    select l.id, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where m.level_code = 'A1' and l.status <> 'DEPRECATED'
  loop
    select to_jsonb(l), regexp_replace(l.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':'),
           regexp_replace(l.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':')
      into v_payload, v_ua, v_hr
      from public.lessons l where l.id = r.id;
    if v_ua is not distinct from (v_payload->>'title_ua') and v_hr is not distinct from (v_payload->>'title_hr') then continue; end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'curriculum_a1_v2: новий номер уроку ' || r.n);
    update public.lessons set title_ua = v_ua, title_hr = v_hr where id = r.id;
  end loop;
end $$;

-- 5. Самоперевірка частини 1: якщо щось не так — уся частина відкочується
do $$
declare v_new int; v_short int; v_scenes int; v_words int; v_total int; v_bad_titles int;
begin
  select count(*) into v_new from public.lessons where id in ('63a4a6d8-1cae-5e0e-90ff-98efcfe8b4c7', 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2', '1968c7d5-4e3a-5b1e-92f6-88df711e9c54', '3365f423-e694-5b55-baa1-3205fba11aff', 'bb7bc159-cb40-5a8a-91b7-c6da05c6342a', '17fcd38a-e295-5849-9ba3-1ef240c6be78', 'ae33e31a-f937-5305-908e-3d957df15f6a', '2c192d05-f259-53b6-a6ec-55ebfb25ec01', 'c8297811-44ed-55a2-8cb5-d1bd9b8a6a73', 'de93d3ab-6769-5daf-9560-8858285a8136') and status = 'PUBLISHED';
  select count(*) into v_short from public.lessons l where l.id in ('63a4a6d8-1cae-5e0e-90ff-98efcfe8b4c7', 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2', '1968c7d5-4e3a-5b1e-92f6-88df711e9c54', '3365f423-e694-5b55-baa1-3205fba11aff', 'bb7bc159-cb40-5a8a-91b7-c6da05c6342a', '17fcd38a-e295-5849-9ba3-1ef240c6be78', 'ae33e31a-f937-5305-908e-3d957df15f6a', '2c192d05-f259-53b6-a6ec-55ebfb25ec01', 'c8297811-44ed-55a2-8cb5-d1bd9b8a6a73', 'de93d3ab-6769-5daf-9560-8858285a8136')
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') < 12;
  select count(*) into v_scenes from public.lessons l where l.id in ('63a4a6d8-1cae-5e0e-90ff-98efcfe8b4c7', 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2', '1968c7d5-4e3a-5b1e-92f6-88df711e9c54', '3365f423-e694-5b55-baa1-3205fba11aff', 'bb7bc159-cb40-5a8a-91b7-c6da05c6342a', '17fcd38a-e295-5849-9ba3-1ef240c6be78', 'ae33e31a-f937-5305-908e-3d957df15f6a', '2c192d05-f259-53b6-a6ec-55ebfb25ec01', 'c8297811-44ed-55a2-8cb5-d1bd9b8a6a73', 'de93d3ab-6769-5daf-9560-8858285a8136')
     and (select count(*) from public.conversations c where c.lesson_id = l.id) < 2;
  select count(*) into v_words from public.lessons l where l.id in ('63a4a6d8-1cae-5e0e-90ff-98efcfe8b4c7', 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2', '1968c7d5-4e3a-5b1e-92f6-88df711e9c54', '3365f423-e694-5b55-baa1-3205fba11aff', 'bb7bc159-cb40-5a8a-91b7-c6da05c6342a', '17fcd38a-e295-5849-9ba3-1ef240c6be78', 'ae33e31a-f937-5305-908e-3d957df15f6a', '2c192d05-f259-53b6-a6ec-55ebfb25ec01', 'c8297811-44ed-55a2-8cb5-d1bd9b8a6a73', 'de93d3ab-6769-5daf-9560-8858285a8136')
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'lexeme') < 12;
  select count(*) into v_total from public.lessons where level_code = 'A1' and status = 'PUBLISHED';
  select count(*) into v_bad_titles from (
    select l.title_ua, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where m.level_code = 'A1' and l.status <> 'DEPRECATED') t
   where t.title_ua not like 'Урок ' || t.n || ':%';
  if v_new <> 10 then raise exception 'Частина 1: створено % уроків з 10', v_new; end if;
  if v_short > 0 then raise exception 'Частина 1: % уроків мають менше 12 вправ', v_short; end if;
  if v_scenes > 0 then raise exception 'Частина 1: % уроків без двох діалогів', v_scenes; end if;
  if v_words > 0 then raise exception 'Частина 1: % уроків мають менше 12 слів', v_words; end if;
  if v_bad_titles > 0 then raise exception 'Частина 1: % назв уроків A1 не за порядком', v_bad_titles; end if;
  raise notice 'Готово: частина 1 — 10 нових уроків; усього уроків A1 — %', v_total;
end $$;

commit;
