-- =====================================================================
-- Доповнення A1 · curriculum_a1_v2 · частина 4 з 4 · 2026-10-13
-- Згенеровано: python3 scripts/gen_curriculum_a1_v2.py (не редагуйте вручну).
-- Запуск: Supabase → SQL Editor → вставити ВЕСЬ файл → Run. Частини запускайте по черзі (1 → 4).
--
--   * 10 нових уроків (модулі A1.8–A1.10), у плані програми № 70–89:
--       A1.8 «Театр і концерти»
--       A1.8 «Соцмережі»
--       A1.9 «Хорватська кухня»
--       A1.9 «Національні парки»
--       A1.9 «Старе місто»
--       A1.9 «Свята й неробочі дні»
--       A1.10 «Продовження перебування»
--       A1.10 «Навчання й мовні курси»
--       A1.10 «Надзвичайні ситуації»
--       A1.10 «Нове життя в Хорватії»
--   * У кожному 14 нових слів, 2 діалоги (101 реплік разом), граматика, 12 вправ, ~12 хв.
--   * Нові слова у словнику: 69. Виправлення словника: 2 (стара версія — у content_versions).
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

-- 1. Нові слова (69), яких ще немає у словнику
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bend', 'bend', 'hr', 'noun', 'A1', 'гурт (музичний)', 'core', '{"gender": "m"}'::jsonb, '["Moj omiljeni bend svira u subotu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nastup', 'nastup', 'hr', 'noun', 'A1', 'виступ', 'core', '{"gender": "m"}'::jsonb, '["Nastup počinje u devet."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rasprodan', 'rasprodan', 'hr', 'adjective', 'A1', 'розпроданий', 'core', '{}'::jsonb, '["Koncert je rasprodan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pratitelj', 'pratitelj', 'hr', 'noun', 'A1', 'підписник', 'core', '{"gender": "m"}'::jsonb, '["Ona ima tisuću pratitelja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pročitati', 'procitati', 'hr', 'verb', 'A1', 'прочитати', 'core', '{"aspect": "pfv"}'::jsonb, '["Moram pročitati ovaj mail."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pršut', 'prsut', 'hr', 'noun', 'A1', 'пршут (в’ялена шинка)', 'core', '{"gender": "m"}'::jsonb, '["Za predjelo uzimamo pršut i sir."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('paški sir', 'paski sir', 'hr', 'phrase', 'A1', 'паґський сир (овечий, з острова Паґ)', 'collocation', '{"gender": "m"}'::jsonb, '["Paški sir je skup, ali odličan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sarma', 'sarma', 'hr', 'noun', 'A1', 'сарма (голубці з квашеної капусти)', 'core', '{"gender": "f"}'::jsonb, '["Baka zimi kuha sarmu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('štrukli', 'strukli', 'hr', 'noun', 'A1', 'штрукли (тісто із сиром, загребська страва)', 'core', '{"gender": "m", "number": "pl"}'::jsonb, '["U Zagrebu jedemo štrukle sa sirom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('fritule', 'fritule', 'hr', 'noun', 'A1', 'фрітуле (маленькі пончики)', 'core', '{"gender": "f", "number": "pl"}'::jsonb, '["Za Božić pečemo fritule."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('peka', 'peka', 'hr', 'noun', 'A1', 'пека (страва під залізною кришкою на жару)', 'core', '{"gender": "f"}'::jsonb, '["Janjetinu ispod peke treba naručiti unaprijed."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('brudet', 'brudet', 'hr', 'noun', 'A1', 'брудет (рибне рагу)', 'core', '{"gender": "m"}'::jsonb, '["Brudet jedemo s palentom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('blitva', 'blitva', 'hr', 'noun', 'A1', 'мангольд', 'core', '{"gender": "f"}'::jsonb, '["Riba s blitvom je tipična dalmatinska hrana."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('maslina', 'maslina', 'hr', 'noun', 'A1', 'оливка', 'core', '{"gender": "f"}'::jsonb, '["Na Korčuli rastu masline."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rakija', 'rakija', 'hr', 'noun', 'A1', 'ракія (фруктовий самогон)', 'core', '{"gender": "f"}'::jsonb, '["Djed sam pravi rakiju od šljiva."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kremšnita', 'kremsnita', 'hr', 'noun', 'A1', 'кремшніта (тістечко з кремом)', 'core', '{"gender": "f"}'::jsonb, '["Samoborska kremšnita je poznata."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ćevapi', 'cevapi', 'hr', 'noun', 'A1', 'чевапі (ковбаски з фаршу на грилі)', 'core', '{"gender": "m", "number": "pl"}'::jsonb, '["Ćevapi se jedu s lukom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('specijalitet', 'specijalitet', 'hr', 'noun', 'A1', 'фірмова страва; специалітет', 'core', '{"gender": "m"}'::jsonb, '["Koji je specijalitet kuće?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tartuf', 'tartuf', 'hr', 'noun', 'A1', 'трюфель', 'core', '{"gender": "m"}'::jsonb, '["Istra je poznata po tartufima."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nacionalni park', 'nacionalni park', 'hr', 'phrase', 'A1', 'національний парк', 'collocation', '{"gender": "m"}'::jsonb, '["Hrvatska ima osam nacionalnih parkova."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('slap', 'slap', 'hr', 'noun', 'A1', 'водоспад', 'core', '{"gender": "m"}'::jsonb, '["Najveći slap je na kraju staze."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('staza', 'staza', 'hr', 'noun', 'A1', 'стежка; доріжка', 'core', '{"gender": "f"}'::jsonb, '["Ova staza vodi do jezera."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('planinariti', 'planinariti', 'hr', 'verb', 'A1', 'ходити в гори (у походи)', 'core', '{"aspect": "ipfv"}'::jsonb, '["Vikendom planinarimo na Medvednici."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('park prirode', 'park prirode', 'hr', 'phrase', 'A1', 'природний парк', 'collocation', '{"gender": "m"}'::jsonb, '["Velebit je park prirode."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('medvjed', 'medvjed', 'hr', 'noun', 'A1', 'ведмідь', 'core', '{"gender": "m"}'::jsonb, '["U Gorskom kotaru žive medvjedi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zaštićen', 'zasticen', 'hr', 'adjective', 'A1', 'захищений; заповідний', 'core', '{}'::jsonb, '["Medvjed je zaštićena životinja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vidikovac', 'vidikovac', 'hr', 'noun', 'A1', 'оглядовий майданчик', 'core', '{"gender": "m"}'::jsonb, '["S vidikovca je pogled prekrasan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('špilja', 'spilja', 'hr', 'noun', 'A1', 'печера', 'core', '{"gender": "f"}'::jsonb, '["U špilji je hladno i ljeti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zidine', 'zidine', 'hr', 'noun', 'A1', 'міські мури', 'core', '{"gender": "f", "number": "pl"}'::jsonb, '["Dubrovačke zidine su duge skoro dva kilometra."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('palača', 'palaca', 'hr', 'noun', 'A1', 'палац', 'core', '{"gender": "f"}'::jsonb, '["Dioklecijanova palača je u Splitu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('katedrala', 'katedrala', 'hr', 'noun', 'A1', 'собор', 'core', '{"gender": "f"}'::jsonb, '["Katedrala je u centru grada."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('toranj', 'toranj', 'hr', 'noun', 'A1', 'дзвіниця; вежа', 'core', '{"gender": "m"}'::jsonb, '["S tornja se vidi cijeli grad."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kula', 'kula', 'hr', 'noun', 'A1', 'фортечна вежа', 'core', '{"gender": "f"}'::jsonb, '["Na zidinama je pet kula."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('razgledati', 'razgledati', 'hr', 'verb', 'A1', 'оглядати (пам’ятки)', 'core', '{"aspect": "ipfv"}'::jsonb, '["Danas razgledamo stari grad."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Uskrs', 'uskrs', 'hr', 'noun', 'A1', 'Великдень', 'core', '{"gender": "m"}'::jsonb, '["Za Uskrs cijela obitelj ruča zajedno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Nova godina', 'nova godina', 'hr', 'phrase', 'A1', 'Новий рік', 'collocation', '{"gender": "f"}'::jsonb, '["Za Novu godinu idemo na trg."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Badnjak', 'badnjak', 'hr', 'noun', 'A1', 'Святвечір (24 грудня)', 'core', '{"gender": "m"}'::jsonb, '["Na Badnjak jedemo ribu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Dan državnosti', 'dan drzavnosti', 'hr', 'phrase', 'A1', 'День державності (30 травня)', 'collocation', '{"gender": "m"}'::jsonb, '["Dan državnosti je trideseti svibnja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('neradni dan', 'neradni dan', 'hr', 'phrase', 'A1', 'неробочий день', 'collocation', '{"gender": "m"}'::jsonb, '["Nedjelja je neradni dan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vatromet', 'vatromet', 'hr', 'noun', 'A1', 'феєрверк', 'core', '{"gender": "m"}'::jsonb, '["U ponoć gledamo vatromet."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('misa', 'misa', 'hr', 'noun', 'A1', 'меса (церковна служба)', 'core', '{"gender": "f"}'::jsonb, '["Na Badnjak idemo na misu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('advent', 'advent', 'hr', 'noun', 'A1', 'адвент (час перед Різдвом)', 'core', '{"gender": "m"}'::jsonb, '["Advent u Zagrebu je jako lijep."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pisanica', 'pisanica', 'hr', 'noun', 'A1', 'писанка', 'core', '{"gender": "f"}'::jsonb, '["Djeca boje pisanice za Uskrs."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('darivati', 'darivati', 'hr', 'verb', 'A1', 'дарувати; обдаровувати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Za Božić darujemo djecu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('čestitka', 'cestitka', 'hr', 'noun', 'A1', 'листівка з привітанням', 'core', '{"gender": "f"}'::jsonb, '["Pišem čestitku baki."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('okititi', 'okititi', 'hr', 'verb', 'A1', 'прикрасити (ялинку)', 'core', '{"aspect": "pfv"}'::jsonb, '["Djeca žele okititi bor."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bor', 'bor', 'hr', 'noun', 'A1', 'сосна; ялинка (різдвяна)', 'core', '{"gender": "m"}'::jsonb, '["Imate li pravi bor ili umjetni?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('produljenje', 'produljenje', 'hr', 'noun', 'A1', 'продовження (терміну)', 'core', '{"gender": "n"}'::jsonb, '["Predajem zahtjev za produljenje boravka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ovjera', 'ovjera', 'hr', 'noun', 'A1', 'засвідчення (підпису, копії)', 'core', '{"gender": "f"}'::jsonb, '["Za ugovor trebam ovjeru potpisa."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('javni bilježnik', 'javni biljeznik', 'hr', 'phrase', 'A1', 'нотаріус', 'collocation', '{"gender": "m"}'::jsonb, '["Javni bilježnik radi do četiri."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sudski tumač', 'sudski tumac', 'hr', 'phrase', 'A1', 'присяжний перекладач', 'collocation', '{"gender": "m"}'::jsonb, '["Prijevod mora napraviti sudski tumač."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('preslika', 'preslika', 'hr', 'noun', 'A1', 'копія (ксерокопія)', 'core', '{"gender": "f"}'::jsonb, '["Trebate presliku putovnice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('upravna pristojba', 'upravna pristojba', 'hr', 'phrase', 'A1', 'адміністративний збір', 'collocation', '{"gender": "f"}'::jsonb, '["Upravnu pristojbu plaćate na šalteru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('biljeg', 'biljeg', 'hr', 'noun', 'A1', 'гербова марка (збір)', 'core', '{"gender": "m"}'::jsonb, '["Na zahtjev stavite biljeg."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('važeći', 'vazeci', 'hr', 'adjective', 'A1', 'чинний; дійсний', 'core', '{}'::jsonb, '["Putovnica mora biti važeća."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('istjecati', 'istjecati', 'hr', 'verb', 'A1', 'спливати (про термін дії)', 'core', '{"aspect": "ipfv"}'::jsonb, '["Dozvola mi istječe u ožujku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nastava', 'nastava', 'hr', 'noun', 'A1', 'заняття; навчання (уроки)', 'core', '{"gender": "f"}'::jsonb, '["Nastava počinje u osam."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('svjedodžba', 'svjedodzba', 'hr', 'noun', 'A1', 'свідоцтво; атестат', 'core', '{"gender": "f"}'::jsonb, '["Na kraju tečaja dobivate svjedodžbu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('priznavanje', 'priznavanje', 'hr', 'noun', 'A1', 'визнання', 'core', '{"gender": "n"}'::jsonb, '["Priznavanje diplome traje nekoliko mjeseci."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('polagati', 'polagati', 'hr', 'verb', 'A1', 'складати (іспит)', 'core', '{"aspect": "ipfv"}'::jsonb, '["Sutra polažem ispit iz hrvatskog."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gradivo', 'gradivo', 'hr', 'noun', 'A1', 'навчальний матеріал', 'core', '{"gender": "n"}'::jsonb, '["Gradivo ponavljamo svaki petak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dim', 'dim', 'hr', 'noun', 'A1', 'дим', 'core', '{"gender": "m"}'::jsonb, '["Iz kuhinje izlazi dim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gorjeti', 'gorjeti', 'hr', 'verb', 'A1', 'горіти', 'core', '{"aspect": "ipfv"}'::jsonb, '["Pazi, nešto gori!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('baterijska svjetiljka', 'baterijska svjetiljka', 'hr', 'phrase', 'A1', 'ліхтарик', 'collocation', '{"gender": "f"}'::jsonb, '["Baterijska svjetiljka je u ladici."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('izlaz u nuždi', 'izlaz u nuzdi', 'hr', 'phrase', 'A1', 'аварійний вихід', 'collocation', '{"gender": "m"}'::jsonb, '["Izlaz u nuždi je na kraju hodnika."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('različit', 'razlicit', 'hr', 'adjective', 'A1', 'різний; відмінний', 'core', '{}'::jsonb, '["Naši jezici su slični, ali različiti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('naviknuti se', 'naviknuti se', 'hr', 'verb', 'A1', 'звикнути', 'core', '{"aspect": "pfv"}'::jsonb, '["Brzo se navikneš na sporiji život."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('domovina', 'domovina', 'hr', 'noun', 'A1', 'батьківщина', 'core', '{"gender": "f"}'::jsonb, '["Domovina mi jako nedostaje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mentalitet', 'mentalitet', 'hr', 'noun', 'A1', 'менталітет', 'core', '{"gender": "m"}'::jsonb, '["Mentalitet na moru je opušten."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;

-- 2. Виправлення словника для слів цих уроків (стара версія — у content_versions)
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('boravište') and ukrainian_translation = 'тимчасове перебування / реєстрація';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «тимчасове перебування / реєстрація» → «місце тимчасового проживання»');
  update public.lexemes set ukrainian_translation = 'місце тимчасового проживання' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «тимчасове перебування / реєстрація» → «місце тимчасового проживання»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('prebivalište') and ukrainian_translation = 'постійне місце проживання / прописка';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «постійне місце проживання / прописка» → «місце постійного проживання»');
  update public.lexemes set ukrainian_translation = 'місце постійного проживання' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «постійне місце проживання / прописка» → «місце постійного проживання»');
end $$;

-- 3. Уроки
-- A1.8 · урок 70: Театр і концерти
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '631c7f59-de43-5081-adb7-77bdf23ce805';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 8) then
    raise exception 'A1.8: місце уроку 8 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.8.8'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 70: Театр і концерти', 'Lekcija 70: Kazalište i koncerti', '["Купити квитки на концерт чи виставу", "Поговорити про виставу й виставку", "Сказати, де щось відбувається"]'::jsonb, 12, 'PUBLISHED', 8);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kazalište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'koncert', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predstava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pjevač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glumac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bend', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nastup', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izložba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'galerija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'publika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pozornica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rasprodan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'festival', v_pos);
  v_pos := pg_temp.word(v_lesson, 'umjetnost', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '26868703-f6f7-5d10-a1b0-7f44c73a9e39', 'fill_in_the_blank', 'Pjevač je na ___.', 'pozornici', '["pozornici", "pozornicu", "pozornice", "pozornica"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ba8c469-eebd-58ef-a20f-46f1ffa41732', 'multiple_choice', 'Що означає «festival»?', 'фестиваль', '["розпроданий", "виступ", "фестиваль", "публіка"]'::jsonb, 'A1', 2, 'PUBLISHED', 'festival', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c25e9be4-1a3c-5329-b543-6291ec020c28', 'multiple_choice', 'Що означає «kazalište»?', 'театр', '["галерея", "театр", "гурт (музичний)", "вистава"]'::jsonb, 'A1', 3, 'PUBLISHED', 'kazalište', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd800c169-744b-5001-8452-0e5feca41c5f', 'multiple_choice', 'Як хорватською «гурт (музичний)»?', 'bend', '["predstava", "bend", "koncert", "publika"]'::jsonb, 'A1', 4, 'PUBLISHED', 'bend', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f81e65a4-c290-56ad-be0d-e238c023c495', 'type_answer', 'Напишіть хорватською: «публіка»', 'publika', null, 'A1', 5, 'PUBLISHED', 'publika', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2b7112a4-1d6a-5511-9da8-29f9a4e15178', 'type_answer', 'Напишіть хорватською: «галерея»', 'galerija', null, 'A1', 6, 'PUBLISHED', 'galerija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7e6f65bd-be32-578a-b1dd-82e868733ee7', 'sentence_builder', 'Складіть: «Я люблю сучасне мистецтво.»', 'Volim modernu umjetnost.', '["Volim", "umjetnost.", "modernu"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c54a8c23-20cc-57a0-aa5e-78e7c7d8949c', 'sentence_builder', 'Складіть: «Виставка в галереї.»', 'Izložba je u galeriji.', '["je", "u", "galeriji.", "Izložba"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4d213d6e-1420-5517-9e1a-ce75068f7f78', 'listening', 'Прослухайте і складіть фразу', 'Gdje je koncert?', '["je", "Gdje", "koncert?"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a156c00f-b1b0-59da-9866-8e2d059f96b9', 'listening', 'Прослухайте і складіть фразу', 'Kakva je predstava?', '["predstava?", "je", "Kakva"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b663be9-cf93-5d39-b71b-627ad1d22437', 'speaking', 'Квитки на виставу розпродані.', 'Karte za predstavu su rasprodane.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bba85431-178a-5aee-82ee-613574c781f6', 'speaking', 'Ми сидимо в театрі.', 'Sjedimo u kazalištu.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e1d35cba-e232-5c28-9690-0221ab2a174d', v_lesson, 'Квитки на концерт', 'Karte za koncert', 1701, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('7f265d57-cd09-5b19-bc33-dc6f0824dd3f', 'e1d35cba-e232-5c28-9690-0221ab2a174d', 'Ana', 'U subotu je koncert mog omiljenog benda!', 'У суботу концерт мого улюбленого гурту!', 1);
  perform pg_temp.turn('7f34be6e-5d5d-5ead-978c-153794c41ecf', 'e1d35cba-e232-5c28-9690-0221ab2a174d', 'Oksana', 'Gdje je koncert?', 'Де концерт?', 2);
  perform pg_temp.turn('27e9d1e6-a568-5d36-a005-52118adb284e', 'e1d35cba-e232-5c28-9690-0221ab2a174d', 'Ana', 'Na festivalu u Puli, u Areni.', 'На фестивалі в Пулі, на Арені.', 3);
  perform pg_temp.turn('69f2450d-0ad5-59a6-8d16-9e68926f01a2', 'e1d35cba-e232-5c28-9690-0221ab2a174d', 'Oksana', 'Ima li još karata?', 'Ще є квитки?', 4);
  perform pg_temp.turn('ea782f58-8e3e-53a6-8aff-739e8041458a', 'e1d35cba-e232-5c28-9690-0221ab2a174d', 'Ana', 'Nažalost, koncert je rasprodan. Ali nastup gledam na televiziji.', 'На жаль, концерт розпроданий. Але виступ дивлюся по телевізору.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('110b0f01-50d0-5b48-bd41-c3056f0f876e', v_lesson, 'У театрі', 'U kazalištu', 1702, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('2f02fcb9-1c99-540b-a26f-2ecb4ec02635', '110b0f01-50d0-5b48-bd41-c3056f0f876e', 'Taras', 'Kakva je predstava?', 'Яка вистава?', 1);
  perform pg_temp.turn('76a5c58d-95a3-5c30-8d54-43bd1787d91a', '110b0f01-50d0-5b48-bd41-c3056f0f876e', 'Marija', 'Odlična! Glumac u glavnoj ulozi je fantastičan.', 'Чудова! Актор у головній ролі фантастичний.', 2);
  perform pg_temp.turn('ba6dbde3-2eab-5e6d-a8d9-4b97b9022265', '110b0f01-50d0-5b48-bd41-c3056f0f876e', 'Taras', 'I publika je oduševljena.', 'І публіка в захваті.', 3);
  perform pg_temp.turn('9f56b1fb-283f-5051-828f-de90e1468b77', '110b0f01-50d0-5b48-bd41-c3056f0f876e', 'Marija', 'Gledaj, pjevač izlazi na pozornicu!', 'Дивись, співак виходить на сцену!', 4);
  perform pg_temp.turn('17687c4b-a02b-5cfb-80f3-e77da5aca2d4', '110b0f01-50d0-5b48-bd41-c3056f0f876e', 'Taras', 'Super. Sutra idemo i na izložbu u galeriji?', 'Чудово. Завтра підемо ще й на виставку в галерею?', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 71: Соцмережі
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '4edd1556-f088-5d14-8f59-529b35747609';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 9) then
    raise exception 'A1.8: місце уроку 9 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '765ac66f-d54b-505b-9b11-c48e5ad26018';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.8.9'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 71: Соцмережі', 'Lekcija 71: Društvene mreže', '["Поговорити про соцмережі", "Знайти групу й новини для українців", "Поєднувати речення: і, а, але, бо"]'::jsonb, 12, 'PUBLISHED', 9);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'društvene mreže', v_pos);
  v_pos := pg_temp.word(v_lesson, 'objaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'komentar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dijeliti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'profil', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grupa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pratitelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'video', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stranica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vijest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'snimiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pročitati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odgovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'privatan', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '45614f7e-262c-5147-a693-774c912e1737', 'fill_in_the_blank', 'Moj profil je privatan, ___ tvoj je javan.', 'a', '["jer", "da", "ili", "a"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0b95e63a-c8cc-57d1-bcee-2ec0fb4c3815', 'multiple_choice', 'Що означає «privatan»?', 'приватний', '["коментар", "прочитати", "соціальні мережі", "приватний"]'::jsonb, 'A1', 2, 'PUBLISHED', 'privatan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7e7e7d2e-8d3d-5e8a-b085-e6ad5c6bee40', 'multiple_choice', 'Що означає «video»?', 'відео', '["профіль", "група", "відео", "відповідь"]'::jsonb, 'A1', 3, 'PUBLISHED', 'video', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '03423eaf-85b9-5266-82cb-2ca9ba12b310', 'multiple_choice', 'Як хорватською «соціальні мережі»?', 'društvene mreže', '["privatan", "vijest", "društvene mreže", "objaviti"]'::jsonb, 'A1', 4, 'PUBLISHED', 'društvene mreže', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4afe1ebe-3470-51d6-98fb-c6d77a1cbbb5', 'type_answer', 'Напишіть хорватською: «прочитати»', 'pročitati', null, 'A1', 5, 'PUBLISHED', 'pročitati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e0417ed6-2d87-510f-971b-fd91efea9622', 'type_answer', 'Напишіть хорватською: «ділитися»', 'dijeliti', null, 'A1', 6, 'PUBLISHED', 'dijeliti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '01d39494-b511-5cb6-893b-b390ee671c19', 'sentence_builder', 'Складіть: «Я ділюся відео з родиною.»', 'Dijelim video s obitelji.', '["video", "s", "Dijelim", "obitelji."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c5125666-48e5-534f-bdd0-8a9b9554ad04', 'sentence_builder', 'Складіть: «Прочитай новину на сторінці.»', 'Pročitaj vijest na stranici.', '["na", "stranici.", "vijest", "Pročitaj"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4db54e2a-555d-5c27-b625-edf8f10c076d', 'listening', 'Прослухайте і складіть фразу', 'Ovaj video snimam za Instagram.', '["video", "Ovaj", "Instagram.", "snimam", "za"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '14d2b443-8c8f-56b0-9010-997de84e88b3', 'listening', 'Прослухайте і складіть фразу', 'Znaš li grupu za Ukrajince u Zagrebu?', '["za", "Ukrajince", "li", "u", "Znaš", "grupu", "Zagrebu?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'db5e7bdb-5262-5694-b6dd-c2b72a5e4025', 'speaking', 'Я не публікую фото дітей.', 'Ne objavljujem fotografije djece.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae77b1c9-7d17-53be-ae67-5deba61237b4', 'speaking', 'Скільки в тебе підписників?', 'Koliko imaš pratitelja?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('72340c1d-67e4-5f25-b455-ac3976415df9', v_lesson, 'Відео з моря', 'Video s mora', 1711, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('02c962e8-f1da-54e4-984c-353de30cb125', '72340c1d-67e4-5f25-b455-ac3976415df9', 'Ivana', 'Ovaj video snimam za Instagram.', 'Це відео знімаю для інстаграму.', 1);
  perform pg_temp.turn('e3d0530d-afdc-501a-ac30-4bd7ab13f77f', '72340c1d-67e4-5f25-b455-ac3976415df9', 'Oksana', 'Objavljuješ li sve na društvenim mrežama?', 'Ти все публікуєш у соцмережах?', 2);
  perform pg_temp.turn('e2242ea0-3658-588a-9f46-2591062ca372', '72340c1d-67e4-5f25-b455-ac3976415df9', 'Ivana', 'Ne sve, jer mi je profil javan. Imam puno pratitelja.', 'Не все, бо мій профіль публічний. У мене багато підписників.', 3);
  perform pg_temp.turn('a2e78aed-0f3c-5f89-80e6-4be81b80c686', '72340c1d-67e4-5f25-b455-ac3976415df9', 'Oksana', 'Moj je privatan, ali često dijelim fotografije s obitelji.', 'Мій приватний, але я часто ділюся фотографіями з родиною.', 4);
  perform pg_temp.turn('60edde93-ba09-54e5-9eb8-be13ab0e7345', '72340c1d-67e4-5f25-b455-ac3976415df9', 'Ivana', 'Pošalji mi link pa te pratim!', 'Надішли мені посилання, і я на тебе підпишуся!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7b08a2c5-020b-534a-b537-88e66845d4eb', v_lesson, 'Група для українців', 'Grupa za Ukrajince', 1712, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('10ddb41d-66ad-5542-8d82-1b676abb2064', '7b08a2c5-020b-534a-b537-88e66845d4eb', 'Taras', 'Znaš li grupu za Ukrajince u Zagrebu?', 'Ти знаєш групу для українців у Загребі?', 1);
  perform pg_temp.turn('ce578ef0-b307-57ba-8a59-5dcd41e0da61', '7b08a2c5-020b-534a-b537-88e66845d4eb', 'Olena', 'Znam. Tamo su sve važne vijesti i savjeti.', 'Знаю. Там усі важливі новини й поради.', 2);
  perform pg_temp.turn('b3a9e5b8-7538-578e-975b-0310705f5452', '7b08a2c5-020b-534a-b537-88e66845d4eb', 'Taras', 'Pitam za vrtić, ali nema odgovora.', 'Я питаю про садок, але відповіді немає.', 3);
  perform pg_temp.turn('d1a0cc91-6bcc-59f7-9ed3-9d45bca0f906', '7b08a2c5-020b-534a-b537-88e66845d4eb', 'Olena', 'Pročitaj komentare ispod ili napiši na stranici grada.', 'Прочитай коментарі нижче або напиши на сторінці міста.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 77: Хорватська кухня
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'f1b2093d-9699-59af-92b9-ed7bdf7fad49';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A1.9: місце уроку 6 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.9.6'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 77: Хорватська кухня', 'Lekcija 77: Hrvatska kuhinja', '["Замовити хорватські страви", "Розповісти, що їдять у різних краях", "Назвати хорватські специалітети"]'::jsonb, 12, 'PUBLISHED', 6);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'pršut', v_pos);
  v_pos := pg_temp.word(v_lesson, 'paški sir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sarma', v_pos);
  v_pos := pg_temp.word(v_lesson, 'štrukli', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fritule', v_pos);
  v_pos := pg_temp.word(v_lesson, 'peka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brudet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blitva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maslina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rakija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kremšnita', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ćevapi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'specijalitet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tartuf', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f6ab8542-aa90-5882-b4a2-191991aed831', 'fill_in_the_blank', 'Moram probati ___ iz Samobora.', 'kremšnitu', '["kremšnite", "kremšniti", "kremšnita", "kremšnitu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '32265a9a-9ec2-5c63-a7a2-7398d2d998be', 'multiple_choice', 'Що означає «sarma»?', 'сарма (голубці з квашеної капусти)', '["сарма (голубці з квашеної капусти)", "пека (страва під залізною кришкою на жару)", "паґський сир (овечий, з острова Паґ)", "пршут (в’ялена шинка)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'sarma', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5fd4b433-f312-50e0-b638-a3ba5ee36329', 'multiple_choice', 'Що означає «tartuf»?', 'трюфель', '["трюфель", "фірмова страва; специалітет", "ракія (фруктовий самогон)", "фрітуле (маленькі пончики)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'tartuf', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9bfccfc2-deba-5f11-95e5-50714ff157cd', 'multiple_choice', 'Як хорватською «мангольд»?', 'blitva', '["paški sir", "blitva", "sarma", "maslina"]'::jsonb, 'A1', 4, 'PUBLISHED', 'blitva', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e9ed1966-2640-5f26-aece-4620cb6b4601', 'type_answer', 'Напишіть хорватською: «оливка»', 'maslina', null, 'A1', 5, 'PUBLISHED', 'maslina', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f096ea97-b6a4-5b4b-9696-62ce55138761', 'type_answer', 'Напишіть хорватською: «фрітуле (маленькі пончики)»', 'fritule', null, 'A1', 6, 'PUBLISHED', 'fritule', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '86ed0708-8e58-5061-b16d-3a84c8e379a1', 'sentence_builder', 'Складіть: «Раджу фірмову страву закладу.»', 'Preporučujem specijalitet kuće.', '["kuće.", "specijalitet", "Preporučujem"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0b615291-1aa7-5b93-a5a5-32244a5d1a2e', 'sentence_builder', 'Складіть: «Я люблю оливки й пршут.»', 'Volim masline i pršut.', '["Volim", "i", "masline", "pršut."]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d3c1a6e-1fbd-53e5-9ca2-a175250e2cb5', 'listening', 'Прослухайте і складіть фразу', 'Što je peka?', '["je", "peka?", "Što"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a371a375-5724-5eb3-aeff-2174f1763472', 'listening', 'Прослухайте і складіть фразу', 'A slatko?', '["slatko?", "A"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2836c44a-50f7-5061-8bb1-560169c0aab7', 'speaking', 'Одну порцію чевапі, будь ласка.', 'Jednu porciju ćevapa, molim.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7cc5a704-eef7-5f79-a6ac-743e77fd041c', 'speaking', 'Сарма — це зимова страва.', 'Sarma je zimsko jelo.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('17f1626f-9729-5c4d-88ee-07d7036bf36f', v_lesson, 'У коноби', 'U konobi', 1771, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('48d2bfcf-7b6c-5a8e-82a5-ea2e9209f05a', '17f1626f-9729-5c4d-88ee-07d7036bf36f', 'Konobar', 'Preporučujem specijalitet kuće: janjetinu ispod peke.', 'Раджу фірмову страву: баранину під пекою.', 1);
  perform pg_temp.turn('a21a2be5-20dd-5e9c-b5dc-beab8114e17d', '17f1626f-9729-5c4d-88ee-07d7036bf36f', 'Taras', 'Što je peka?', 'Що таке пека?', 2);
  perform pg_temp.turn('868ed6d4-79a9-5c94-b7d9-1fc5453f41ad', '17f1626f-9729-5c4d-88ee-07d7036bf36f', 'Konobar', 'Meso i krumpir pečemo pod metalnim poklopcem, na žaru.', 'М’ясо й картоплю печемо під металевою кришкою на жару.', 3);
  perform pg_temp.turn('59ca9d06-72aa-566d-907e-c4edfcb8099f', '17f1626f-9729-5c4d-88ee-07d7036bf36f', 'Taras', 'Odlično, uzimam peku. A za predjelo?', 'Чудово, беру пеку. А на закуску?', 4);
  perform pg_temp.turn('3a15ca75-34de-554c-85b8-21b1ac1044ef', '17f1626f-9729-5c4d-88ee-07d7036bf36f', 'Konobar', 'Pršut, paški sir i masline.', 'Пршут, паґський сир і оливки.', 5);
  perform pg_temp.turn('44a6632c-d02b-5102-a197-c897ed46a230', '17f1626f-9729-5c4d-88ee-07d7036bf36f', 'Taras', 'Može. I čašicu rakije na kraju!', 'Можна. І чарочку ракії наприкінці!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('650d26e1-39ec-5820-853d-3cee052ff2ed', v_lesson, 'Що спробувати?', 'Što probati?', 1772, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('d09eec54-41bb-52cb-92f6-77b6a08265fe', '650d26e1-39ec-5820-853d-3cee052ff2ed', 'Olena', 'Što moram probati u Hrvatskoj?', 'Що я мушу спробувати в Хорватії?', 1);
  perform pg_temp.turn('efdb8a5c-31f6-5154-97e8-10f82a173166', '650d26e1-39ec-5820-853d-3cee052ff2ed', 'Ivan', 'U Zagrebu štrukle, u Istri tartufe, a na moru brudet i blitvu.', 'У Загребі штрукли, в Істрії трюфелі, а на морі брудет і мангольд.', 2);
  perform pg_temp.turn('851d28dc-53de-5c8d-a9db-548115392c2a', '650d26e1-39ec-5820-853d-3cee052ff2ed', 'Olena', 'A slatko?', 'А солодке?', 3);
  perform pg_temp.turn('91de2b86-f699-5270-b5fa-1c13e3858d12', '650d26e1-39ec-5820-853d-3cee052ff2ed', 'Ivan', 'Kremšnitu iz Samobora i fritule za Božić.', 'Кремшніту із Самобора і фрітуле на Різдво.', 4);
  perform pg_temp.turn('bd3d8407-294a-551f-aa98-2732e9223eea', '650d26e1-39ec-5820-853d-3cee052ff2ed', 'Olena', 'A sarmu i ćevape?', 'А сарму й чевапі?', 5);
  perform pg_temp.turn('5310b81e-34e7-512b-b043-dbd8a556d1a4', '650d26e1-39ec-5820-853d-3cee052ff2ed', 'Ivan', 'Sarmu zimi, a ćevape kad god želiš!', 'Сарму взимку, а чевапі — коли захочеш!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 78: Національні парки
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '84a20a00-701a-5ce5-a3c8-fca72986f912';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A1.9: місце уроку 7 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.9.7'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 78: Національні парки', 'Lekcija 78: Nacionalni parkovi', '["Відвідати національний парк", "Запитати про маршрут і пам’ятки природи", "Сказати, де щось є: у лісі, на озері"]'::jsonb, 12, 'PUBLISHED', 7);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'nacionalni park', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slap', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jezero', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šuma', v_pos);
  v_pos := pg_temp.word(v_lesson, 'staza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'planinariti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'priroda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'park prirode', v_pos);
  v_pos := pg_temp.word(v_lesson, 'životinja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'medvjed', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaštićen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vidikovac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'špilja', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '92b66c79-00d9-55b0-a284-8eece42f6fbe', 'fill_in_the_blank', 'Medvjedi žive u ___.', 'šumi', '["šume", "šumi", "šumu", "šuma"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '87f12f08-aa59-5adf-84af-3e7f00956d02', 'multiple_choice', 'Що означає «brod»?', 'корабель', '["природа", "природний парк", "стежка; доріжка", "корабель"]'::jsonb, 'A1', 2, 'PUBLISHED', 'brod', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf574251-99c0-55bc-ba8e-89163f153913', 'multiple_choice', 'Що означає «šuma»?', 'ліс', '["озеро", "ліс", "природний парк", "тварина"]'::jsonb, 'A1', 3, 'PUBLISHED', 'šuma', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b0d86e70-2ba5-5242-8d54-5869a340340b', 'multiple_choice', 'Як хорватською «природа»?', 'priroda', '["jezero", "priroda", "nacionalni park", "slap"]'::jsonb, 'A1', 4, 'PUBLISHED', 'priroda', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '39bdc007-5cdc-5a07-b1ed-c3e176f135ff', 'type_answer', 'Напишіть хорватською: «водоспад»', 'slap', null, 'A1', 5, 'PUBLISHED', 'slap', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bc767132-9cc4-5ada-835b-40b3edf0047f', 'type_answer', 'Напишіть хорватською: «тварина»', 'životinja', null, 'A1', 6, 'PUBLISHED', 'životinja', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '20e7b528-ebc7-5021-8cb1-d2ed8e7bac4d', 'sentence_builder', 'Складіть: «Ця стежка веде до озера.»', 'Ova staza vodi do jezera.', '["jezera.", "do", "vodi", "staza", "Ova"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eb060aae-c802-5881-b7d9-3be0dc0af22e', 'sentence_builder', 'Складіть: «З оглядового майданчика видно водоспад.»', 'S vidikovca vidimo slap.', '["S", "slap.", "vidikovca", "vidimo"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6245cace-8109-5f69-ba42-43d28b813361', 'listening', 'Прослухайте і складіть фразу', 'Gdje je najveći slap?', '["je", "najveći", "Gdje", "slap?"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3614055b-96ac-515b-a06a-f96251de0395', 'listening', 'Прослухайте і складіть фразу', 'A što još vidimo?', '["vidimo?", "što", "još", "A"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '85644456-7030-5bd6-b197-e009556f9b48', 'speaking', 'Велебіт — природний парк.', 'Velebit je park prirode.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e9f9573f-b6f3-51ae-8932-794128c2f3dd', 'speaking', 'У печері холодно.', 'U špilji je hladno.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('56458bff-0dec-512b-9750-4800838a0d12', v_lesson, 'На Плітвіцьких озерах', 'Na Plitvičkim jezerima', 1781, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('26467972-a9d9-5ab2-ad9d-24abc6e1c552', '56458bff-0dec-512b-9750-4800838a0d12', 'Vodič', 'Dobro došli u Nacionalni park Plitvička jezera!', 'Ласкаво просимо до Національного парку Плітвіцькі озера!', 1);
  perform pg_temp.turn('e5539428-ebbe-5435-b8f9-db2220757a31', '56458bff-0dec-512b-9750-4800838a0d12', 'Andrij', 'Koliko dugo traje obilazak?', 'Скільки триває екскурсія?', 2);
  perform pg_temp.turn('85b9b623-6262-5fb3-b003-ba003a7d932f', '56458bff-0dec-512b-9750-4800838a0d12', 'Vodič', 'Ova staza traje četiri sata. Idemo pješice i brodom preko jezera.', 'Цей маршрут триває чотири години. Ідемо пішки і кораблем через озеро.', 3);
  perform pg_temp.turn('3522dbad-6dad-57ae-9bba-3ff89a713790', '56458bff-0dec-512b-9750-4800838a0d12', 'Andrij', 'Gdje je najveći slap?', 'Де найбільший водоспад?', 4);
  perform pg_temp.turn('890d0780-67a1-5be7-a5fd-6aee69d32c48', '56458bff-0dec-512b-9750-4800838a0d12', 'Vodič', 'Na kraju staze. S vidikovca je pogled prekrasan.', 'Наприкінці стежки. З оглядового майданчика вид чудовий.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('51be8c7e-2ffa-5222-b93d-c8fd622544e0', v_lesson, 'У горах', 'U planini', 1782, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('d80aaa0b-7b03-5dce-a3fd-acf0ef04defd', '51be8c7e-2ffa-5222-b93d-c8fd622544e0', 'Ivan', 'Vikendom planinarim na Velebitu. Ideš sa mnom?', 'На вихідних ходжу в гори на Велебіт. Підеш зі мною?', 1);
  perform pg_temp.turn('2efd888d-122a-59b6-8197-24e4f3915aee', '51be8c7e-2ffa-5222-b93d-c8fd622544e0', 'Taras', 'Rado! Ima li u šumi medvjeda?', 'Охоче! А в лісі є ведмеді?', 2);
  perform pg_temp.turn('f0d1e502-94c7-539f-baad-c959341c3742', '51be8c7e-2ffa-5222-b93d-c8fd622544e0', 'Ivan', 'Ima, ali rijetko. Medvjed je zaštićena životinja.', 'Є, але рідко. Ведмідь — захищена тварина.', 3);
  perform pg_temp.turn('ccfcec5e-7c19-59a3-8337-ac8430f87190', '51be8c7e-2ffa-5222-b93d-c8fd622544e0', 'Taras', 'A što još vidimo?', 'А що ще побачимо?', 4);
  perform pg_temp.turn('382ab0ed-c55b-5175-98d4-0e32414a48ea', '51be8c7e-2ffa-5222-b93d-c8fd622544e0', 'Ivan', 'Jednu veliku špilju. Priroda je tamo divna.', 'Одну велику печеру. Природа там чудова.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 79: Старе місто
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'd9ef1de4-f4db-590e-bafd-474f84c8e03f';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 8) then
    raise exception 'A1.9: місце уроку 8 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.9.8'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 79: Старе місто', 'Lekcija 79: Stari grad', '["Оглянути старе місто з гідом", "Порівняти пам’ятки: старіший, довший, відоміший", "Назвати частини старого міста"]'::jsonb, 12, 'PUBLISHED', 8);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zidine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'palača', v_pos);
  v_pos := pg_temp.word(v_lesson, 'katedrala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'toranj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'luka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'riva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stara jezgra', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spomenik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'znamenitost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kula', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razgledati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'turistički vodič', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stoljeće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povijest', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f209f2df-fb91-5a8b-92f8-a670b2f75494', 'fill_in_the_blank', 'Zidine u Stonu su ___ od zidina u Dubrovniku.', 'duže', '["duga", "duže", "najduže", "dugo"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '642a84de-a946-58a2-8d4f-91cbc068d992', 'multiple_choice', 'Що означає «znamenitost»?', 'визначна пам''ятка', '["порт", "набережна", "собор", "визначна пам''ятка"]'::jsonb, 'A1', 2, 'PUBLISHED', 'znamenitost', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b07a02a0-6b32-5341-aea5-873aa3ae07d4', 'multiple_choice', 'Що означає «razgledati»?', 'оглядати (пам’ятки)', '["туристичний гід", "оглядати (пам’ятки)", "старе місто", "історія"]'::jsonb, 'A1', 3, 'PUBLISHED', 'razgledati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '825b56de-20ee-52e2-9e76-a40ccd238945', 'multiple_choice', 'Як хорватською «палац»?', 'palača', '["razgledati", "turistički vodič", "kula", "palača"]'::jsonb, 'A1', 4, 'PUBLISHED', 'palača', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '35aa0a07-d198-5365-85ff-dc8a5a8b8884', 'type_answer', 'Напишіть хорватською: «століття»', 'stoljeće', null, 'A1', 5, 'PUBLISHED', 'stoljeće', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '630071dc-f372-5879-9e7a-24410a40575d', 'type_answer', 'Напишіть хорватською: «набережна»', 'riva', null, 'A1', 6, 'PUBLISHED', 'riva', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '02344eb4-3142-526b-ae57-f340b72262bf', 'sentence_builder', 'Складіть: «Сьогодні оглядаємо старе місто.»', 'Danas razgledamo staru jezgru.', '["staru", "Danas", "jezgru.", "razgledamo"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '68a8143a-c383-548b-90ec-77fc28d2eae3', 'sentence_builder', 'Складіть: «З вежі найкращий вид.»', 'S kule je najljepši pogled.', '["najljepši", "je", "kule", "pogled.", "S"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2a2b8e9b-075f-5215-981f-609d8305a923', 'listening', 'Прослухайте і складіть фразу', 'Možemo li se popeti na kulu?', '["Možemo", "na", "popeti", "se", "li", "kulu?"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3206d046-c1a7-57cf-bf9b-05a9b209e1bc', 'listening', 'Прослухайте і складіть фразу', 'A katedrala?', '["katedrala?", "A"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3c21b22f-7548-5746-a253-df4714ff94b4', 'speaking', 'Хорватія має довгу історію.', 'Hrvatska ima dugu povijest.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0a8b10fb-0a04-5b5f-84ad-e46bd7a28d7a', 'speaking', 'Пам’ятник старіший за собор.', 'Spomenik je stariji od katedrale.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a51f7492-8248-5d55-9247-f5a8c64ee533', v_lesson, 'У Дубровнику', 'U Dubrovniku', 1791, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('2eb8a82d-59bd-5255-8705-72dcd8f3729c', 'a51f7492-8248-5d55-9247-f5a8c64ee533', 'Vodička', 'Ovo su gradske zidine iz trinaestog stoljeća.', 'Це міські мури тринадцятого століття.', 1);
  perform pg_temp.turn('789c11d1-627d-5ac6-9df0-96d44d48ebb3', 'a51f7492-8248-5d55-9247-f5a8c64ee533', 'Oksana', 'Jesu li duže od zidina u Stonu?', 'Вони довші за мури в Стоні?', 2);
  perform pg_temp.turn('ecb959bc-e7de-5782-9547-c2ae987d8279', 'a51f7492-8248-5d55-9247-f5a8c64ee533', 'Vodička', 'Ne, zidine u Stonu su duže, ali ove su poznatije.', 'Ні, мури в Стоні довші, але ці відоміші.', 3);
  perform pg_temp.turn('18c66aba-2883-5d36-a64e-d855dc2dde56', 'a51f7492-8248-5d55-9247-f5a8c64ee533', 'Oksana', 'Možemo li se popeti na kulu?', 'Можна піднятися на вежу?', 4);
  perform pg_temp.turn('a65f690d-b96c-5d34-b426-97aaddd412f6', 'a51f7492-8248-5d55-9247-f5a8c64ee533', 'Vodička', 'Možete. S kule je najljepši pogled na luku.', 'Можна. З вежі найкращий вид на порт.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5551d5e7-3cee-55bf-85bf-2de8e6f67585', v_lesson, 'У Спліті', 'U Splitu', 1792, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('87a5bfe8-97da-522c-a948-a5f67e336609', '5551d5e7-3cee-55bf-85bf-2de8e6f67585', 'Andrij', 'Koja je najvažnija znamenitost Splita?', 'Яка найголовніша пам’ятка Спліта?', 1);
  perform pg_temp.turn('ac173e33-da68-51b0-9115-51380253b3ff', '5551d5e7-3cee-55bf-85bf-2de8e6f67585', 'Turistički vodič', 'Dioklecijanova palača. Stara je oko sedamnaest stoljeća.', 'Палац Діоклетіана. Йому близько сімнадцяти століть.', 2);
  perform pg_temp.turn('3f9f7380-c967-5a39-92a8-01f9951947df', '5551d5e7-3cee-55bf-85bf-2de8e6f67585', 'Andrij', 'A katedrala?', 'А собор?', 3);
  perform pg_temp.turn('8a61961d-87d7-59f4-9d6d-475d5e3b8205', '5551d5e7-3cee-55bf-85bf-2de8e6f67585', 'Turistički vodič', 'U palači je. Toranj katedrale je viši od svih zgrada u staroj jezgri.', 'Він у палаці. Дзвіниця собору вища за всі будівлі в старому місті.', 4);
  perform pg_temp.turn('a9ddc713-bd68-54b6-bfaf-43b947c775d9', '5551d5e7-3cee-55bf-85bf-2de8e6f67585', 'Andrij', 'Super! Prvo razgledamo palaču, a onda pijemo kavu na rivi.', 'Чудово! Спочатку оглянемо палац, а потім вип’ємо кави на набережній.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 80: Свята й неробочі дні
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '33c041a0-e71a-55c1-94c8-64941876c6d2';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 9) then
    raise exception 'A1.9: місце уроку 9 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.9.9'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 80: Свята й неробочі дні', 'Lekcija 80: Blagdani i neradni dani', '["Розповісти, як ваша родина святкує", "Дізнатися про неробочі дні в Хорватії", "Привітати зі святом"]'::jsonb, 12, 'PUBLISHED', 9);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'Uskrs', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Nova godina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Badnjak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Dan državnosti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neradni dan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vatromet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slavlje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'misa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'advent', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pisanica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'darivati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čestitka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'okititi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bor', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '96ba193f-b14e-5c5f-99a9-8d5fd19cf830', 'fill_in_the_blank', 'Kako slavite Božić u ___ obitelji?', 'vašoj', '["vaše", "vašoj", "vaša", "vašu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8c778b84-9ab4-5af7-9802-c5b9431d909d', 'multiple_choice', 'Що означає «slavlje»?', 'святкування', '["меса (церковна служба)", "писанка", "святкування", "Святвечір (24 грудня)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'slavlje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0c51e891-e13c-5b4e-ae37-40b4eca8e12b', 'multiple_choice', 'Що означає «Badnjak»?', 'Святвечір (24 грудня)', '["Святвечір (24 грудня)", "меса (церковна служба)", "сосна; ялинка (різдвяна)", "неробочий день"]'::jsonb, 'A1', 3, 'PUBLISHED', 'Badnjak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7c98819a-7c29-5d6f-98e6-d51a906f2d03', 'multiple_choice', 'Як хорватською «сосна; ялинка (різдвяна)»?', 'bor', '["vatromet", "Badnjak", "Uskrs", "bor"]'::jsonb, 'A1', 4, 'PUBLISHED', 'bor', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7ec1268c-99a1-5a15-9080-76695d5fd2a3', 'type_answer', 'Напишіть хорватською: «писанка»', 'pisanica', null, 'A1', 5, 'PUBLISHED', 'pisanica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1822fe0f-e1f2-51f2-950e-17955256c1ab', 'type_answer', 'Напишіть хорватською: «меса (церковна служба)»', 'misa', null, 'A1', 6, 'PUBLISHED', 'misa', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5bbc1880-4d38-5d0b-9d4e-d2f38cd0992d', 'sentence_builder', 'Складіть: «Наш адвент у Загребі чудовий.»', 'Naš advent u Zagrebu je prekrasan.', '["u", "je", "Naš", "advent", "Zagrebu", "prekrasan."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '20f78ef7-a448-5030-bf0b-413582ecb992', 'sentence_builder', 'Складіть: «Це неробочий день.»', 'To je neradni dan.', '["neradni", "To", "je", "dan."]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '01851372-3c4c-5d9f-8e88-72bbe6b6497b', 'listening', 'Прослухайте і складіть фразу', 'I mi darujemo djecu.', '["djecu.", "I", "darujemo", "mi"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '908bff5f-5caf-59a0-9230-2c5e35808478', 'listening', 'Прослухайте і складіть фразу', 'A Nova godina?', '["Nova", "godina?", "A"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4fde72a9-4807-5e44-8fcb-5df4e1317abc', 'speaking', 'Я пишу листівку бабусі.', 'Pišem čestitku baki.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '690c5029-c583-557c-bd4a-b1cb88fdf76c', 'speaking', 'Прикрась ялинку з дітьми!', 'Okiti bor s djecom!', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8dfcccdf-60eb-5237-bc90-fb505364c451', v_lesson, 'Різдво в Хорватії', 'Božić u Hrvatskoj', 1801, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('c614de7a-1a8e-527f-ae24-d886b7af0328', '8dfcccdf-60eb-5237-bc90-fb505364c451', 'Marija', 'Kako slavite Božić u vašoj obitelji?', 'Як ви святкуєте Різдво у вашій родині?', 1);
  perform pg_temp.turn('1df99255-ad65-50e2-a9c1-9d7b4f27a899', '8dfcccdf-60eb-5237-bc90-fb505364c451', 'Olena', 'Kod nas je Božić sada isto dvadeset petog prosinca. A vi?', 'У нас Різдво тепер теж двадцять п’ятого грудня. А у вас?', 2);
  perform pg_temp.turn('93893217-1bd2-5783-9237-3b0073ce9057', '8dfcccdf-60eb-5237-bc90-fb505364c451', 'Marija', 'Na Badnjak kitimo bor, a navečer idemo na misu.', 'На Святвечір прикрашаємо ялинку, а ввечері йдемо на месу.', 3);
  perform pg_temp.turn('bd4e4072-248d-5230-a96c-a92889830a35', '8dfcccdf-60eb-5237-bc90-fb505364c451', 'Olena', 'I mi darujemo djecu.', 'І ми обдаровуємо дітей.', 4);
  perform pg_temp.turn('093f7130-8941-5a46-8b0b-05bd1e231f78', '8dfcccdf-60eb-5237-bc90-fb505364c451', 'Marija', 'Naš advent u Zagrebu je prekrasan, dođite!', 'Наш адвент у Загребі чудовий, приходьте!', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('da73ac8e-a084-5a00-a6db-829973fc1ae2', v_lesson, 'Неробочі дні', 'Neradni dani', 1802, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('5dfb3d5b-360d-5e08-b00a-d8c526cf2cb2', 'da73ac8e-a084-5a00-a6db-829973fc1ae2', 'Taras', 'Radi li trgovina na Dan državnosti?', 'Чи працює магазин у День державності?', 1);
  perform pg_temp.turn('fa15d67f-b1a2-58e2-a0e6-8b41c01941be', 'da73ac8e-a084-5a00-a6db-829973fc1ae2', 'Ivan', 'Ne, to je neradni dan. Trideseti svibnja.', 'Ні, це неробочий день. Тридцяте травня.', 2);
  perform pg_temp.turn('cb737df3-2b0f-575b-b704-bcffd794ecc9', 'da73ac8e-a084-5a00-a6db-829973fc1ae2', 'Taras', 'A Nova godina? Gdje je najbolji vatromet?', 'А Новий рік? Де найкращий феєрверк?', 3);
  perform pg_temp.turn('340c2cca-3671-5295-a550-38e7c643c499', 'da73ac8e-a084-5a00-a6db-829973fc1ae2', 'Ivan', 'Na trgu u centru. Slavlje traje do jutra!', 'На площі в центрі. Святкування триває до ранку!', 4);
  perform pg_temp.turn('7b3aede0-5b44-5e9a-8471-667bc878e02b', 'da73ac8e-a084-5a00-a6db-829973fc1ae2', 'Taras', 'Super. A za Uskrs djeca boje pisanice, kao kod nas.', 'Чудово. А на Великдень діти фарбують писанки, як у нас.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 86: Продовження перебування
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'fe2839bc-fd72-5e8b-bc0e-937d48a90aa8';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A1.10: місце уроку 6 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.10.6'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 86: Продовження перебування', 'Lekcija 86: Produljenje boravka', '["Подати документи на продовження перебування", "Зрозуміти: копія, переклад, засвідчення", "Засвідчити підпис у нотаріуса"]'::jsonb, 12, 'PUBLISHED', 6);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'produljenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rješenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'boravište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prebivalište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovjera', v_pos);
  v_pos := pg_temp.word(v_lesson, 'javni bilježnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijevod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sudski tumač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preslika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upravna pristojba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'biljeg', v_pos);
  v_pos := pg_temp.word(v_lesson, 'važeći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'istjecati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dozvola', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '99d1c955-6a88-5e62-a064-daab4db59ec2', 'fill_in_the_blank', 'Trebate presliku ___.', 'putovnice', '["putovnica", "putovnice", "putovnici", "putovnicu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '408c60f9-aa08-50b5-b7ae-d7a471158ce0', 'multiple_choice', 'Що означає «preslika»?', 'копія (ксерокопія)', '["місце постійного проживання", "засвідчення (підпису, копії)", "продовження (терміну)", "копія (ксерокопія)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'preslika', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a1271978-52c4-552a-b354-3760add1c551', 'multiple_choice', 'Що означає «sudski tumač»?', 'присяжний перекладач', '["засвідчення (підпису, копії)", "присяжний перекладач", "чинний; дійсний", "гербова марка (збір)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'sudski tumač', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f16373c4-4f20-5ea6-a5c0-fe87217ab135', 'multiple_choice', 'Як хорватською «продовження (терміну)»?', 'produljenje', '["produljenje", "upravna pristojba", "rješenje", "važeći"]'::jsonb, 'A1', 4, 'PUBLISHED', 'produljenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3f425534-1d3d-5ea4-8697-9244634d3f58', 'type_answer', 'Напишіть хорватською: «чинний; дійсний»', 'važeći', null, 'A1', 5, 'PUBLISHED', 'važeći', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4aac1ce6-3b77-5698-b7c6-a0385044a17f', 'type_answer', 'Напишіть хорватською: «офіційне рішення»', 'rješenje', null, 'A1', 6, 'PUBLISHED', 'rješenje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4cd7bb25-01ab-56b8-96bc-f728ffdf527c', 'sentence_builder', 'Складіть: «Мій дозвіл спливає в березні.»', 'Moja dozvola istječe u ožujku.', '["ožujku.", "dozvola", "istječe", "Moja", "u"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8831cf9-9b2c-5b13-a593-79026c1729f3', 'sentence_builder', 'Складіть: «Потрібен переклад присяжного перекладача.»', 'Treba prijevod sudskog tumača.', '["prijevod", "sudskog", "Treba", "tumača."]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c77f1ebd-d72e-53b5-bdd3-c2f083bf250b', 'listening', 'Прослухайте і складіть фразу', 'Koji su dokumenti potrebni?', '["Koji", "dokumenti", "potrebni?", "su"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7d464e43-ea23-5da2-b0a2-7deae4b58b19', 'listening', 'Прослухайте і складіть фразу', 'Imate li osobni dokument?', '["osobni", "li", "Imate", "dokument?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c190076a-0e84-5fe2-b3cb-9b14267fc3cc', 'speaking', 'Де можна купити гербову марку?', 'Gdje mogu kupiti biljeg?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '97cc2a58-abba-5467-abad-dc49323a3f82', 'speaking', 'Подаю заяву на продовження перебування.', 'Predajem zahtjev za produljenje boravka.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2b23460f-24cc-537c-9e0e-80c9576d39a0', v_lesson, 'Документи для продовження', 'Dokumenti za produljenje', 1861, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('618b8042-29bd-5227-b968-476bb6833d18', '2b23460f-24cc-537c-9e0e-80c9576d39a0', 'Službenica', 'Dozvola Vam istječe za mjesec dana. Trebate zahtjev za produljenje.', 'Ваш дозвіл спливає через місяць. Потрібна заява на продовження.', 1);
  perform pg_temp.turn('b7be83f7-bd18-5f7f-956d-a54e69496043', '2b23460f-24cc-537c-9e0e-80c9576d39a0', 'Oksana', 'Koji su dokumenti potrebni?', 'Які документи потрібні?', 2);
  perform pg_temp.turn('0bb9fe36-3071-5b69-b2ea-ed3a7c9ff068', '2b23460f-24cc-537c-9e0e-80c9576d39a0', 'Službenica', 'Važeća putovnica, preslika putovnice i dokaz o prebivalištu ili boravištu.', 'Чинний паспорт, копія паспорта й підтвердження місця проживання.', 3);
  perform pg_temp.turn('e60a2032-966f-55c2-bbf9-476dd7f7bbc5', '2b23460f-24cc-537c-9e0e-80c9576d39a0', 'Oksana', 'A rodni list djeteta?', 'А свідоцтво про народження дитини?', 4);
  perform pg_temp.turn('6f0d41b5-c707-50a5-8306-6d9030f1d585', '2b23460f-24cc-537c-9e0e-80c9576d39a0', 'Službenica', 'Treba prijevod sudskog tumača. I platite upravnu pristojbu.', 'Потрібен переклад присяжного перекладача. І сплатіть адміністративний збір.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cf26fdbb-3d1b-5139-a0b6-29f91e00be46', v_lesson, 'У нотаріуса', 'Kod javnog bilježnika', 1862, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('42aa1035-a087-5070-9e87-56cc86829eb5', 'cf26fdbb-3d1b-5139-a0b6-29f91e00be46', 'Andrij', 'Dobar dan, trebam ovjeru potpisa.', 'Добрий день, мені потрібно засвідчити підпис.', 1);
  perform pg_temp.turn('6f9a4f54-9148-5d5b-8078-5ce18f192ea2', 'cf26fdbb-3d1b-5139-a0b6-29f91e00be46', 'Bilježnica', 'Imate li osobni dokument?', 'У вас є документ, що посвідчує особу?', 2);
  perform pg_temp.turn('d19ceb00-b90a-5717-83ad-4d62c78b5dda', 'cf26fdbb-3d1b-5139-a0b6-29f91e00be46', 'Andrij', 'Imam putovnicu. Koliko košta ovjera?', 'Є паспорт. Скільки коштує засвідчення?', 3);
  perform pg_temp.turn('85032e05-1212-5168-9f46-53c416d29a3c', 'cf26fdbb-3d1b-5139-a0b6-29f91e00be46', 'Bilježnica', 'Nekoliko eura. Ovjeru dobivate odmah.', 'Кілька євро. Засвідчення отримаєте одразу.', 4);
  perform pg_temp.turn('4d73a923-9c03-5b12-8bb0-10dbec20cb2f', 'cf26fdbb-3d1b-5139-a0b6-29f91e00be46', 'Andrij', 'Hvala. Rješenje o boravku čekam već dva mjeseca.', 'Дякую. Рішення про перебування я чекаю вже два місяці.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 87: Навчання й мовні курси
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '11b565a4-1e2a-50d2-8d9d-c05e84371402';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A1.10: місце уроку 7 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.10.7'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 87: Навчання й мовні курси', 'Lekcija 87: Učenje jezika', '["Записатися на курс хорватської", "Запитати про іспит і свідоцтво", "Дізнатися, як визнати диплом"]'::jsonb, 12, 'PUBLISHED', 7);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'nastava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svjedodžba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'diploma', v_pos);
  v_pos := pg_temp.word(v_lesson, 'priznavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fakultet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'učionica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polagati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gradivo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vježba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ocjena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rječnik', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'caab6b93-b836-5ed3-86a1-e7982e535991', 'fill_in_the_blank', 'Sutra ___ ispit iz hrvatskog.', 'polažem', '["polažim", "polagati", "polagam", "polažem"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '61d27246-2b43-58ea-a810-3cdce022eccf', 'multiple_choice', 'Що означає «razina»?', 'рівень', '["диплом", "свідоцтво; атестат", "рівень", "клас, аудиторія"]'::jsonb, 'A1', 2, 'PUBLISHED', 'razina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b7320637-e103-5f68-975f-48ad5c4ac3f0', 'multiple_choice', 'Що означає «vježba»?', 'вправа / тренування', '["клас, аудиторія", "визнання", "вправа / тренування", "свідоцтво; атестат"]'::jsonb, 'A1', 3, 'PUBLISHED', 'vježba', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f8bc7e28-f5f0-5ef4-9252-b67691feb6ce', 'multiple_choice', 'Як хорватською «визнання»?', 'priznavanje', '["nastava", "predavanje", "učionica", "priznavanje"]'::jsonb, 'A1', 4, 'PUBLISHED', 'priznavanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7fdcb3c5-8ad7-5917-a299-1bd726f8427a', 'type_answer', 'Напишіть хорватською: «лекція»', 'predavanje', null, 'A1', 5, 'PUBLISHED', 'predavanje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c014eaea-1b22-51f2-9575-f18d53d7c4f0', 'type_answer', 'Напишіть хорватською: «словник»', 'rječnik', null, 'A1', 6, 'PUBLISHED', 'rječnik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ecd3b48b-7535-5351-a202-795df83092dc', 'sentence_builder', 'Складіть: «Заняття починаються о восьмій.»', 'Nastava počinje u osam.', '["u", "Nastava", "počinje", "osam."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9190cb85-cc58-522a-95cd-9963ef8ab4cf', 'sentence_builder', 'Складіть: «Я хочу вищий рівень.»', 'Želim višu razinu.', '["razinu.", "Želim", "višu"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3b497b78-833f-521e-95f0-fb761a8c17c6', 'listening', 'Прослухайте і складіть фразу', 'Trebam li rječnik?', '["Trebam", "rječnik?", "li"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7c079aff-15ba-5322-b690-d47502959359', 'listening', 'Прослухайте і складіть фразу', 'Idem po dokumente.', '["po", "Idem", "dokumente."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '029e82e6-dcd8-5676-bd46-2d280ca2b900', 'speaking', 'Наш клас на другому поверсі.', 'Naša učionica je na drugom katu.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '554df708-de15-535b-91f6-478bb73ee377', 'speaking', 'Я йду на лекцію.', 'Idem na predavanje.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('64f6011a-6b21-52f1-a0fe-d64b55e751d4', v_lesson, 'Курс хорватської', 'Tečaj hrvatskoga', 1871, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('5ca3e6d1-66e6-53e2-a92a-048159fda624', '64f6011a-6b21-52f1-a0fe-d64b55e751d4', 'Profesorica', 'Dobro došli! Ovo je razina A1. Nastava je ponedjeljkom i srijedom.', 'Ласкаво просимо! Це рівень A1. Заняття по понеділках і середах.', 1);
  perform pg_temp.turn('b86aca7d-14aa-5d8e-ab43-5217666d2c10', '64f6011a-6b21-52f1-a0fe-d64b55e751d4', 'Oksana', 'Trebam li rječnik?', 'Мені потрібен словник?', 2);
  perform pg_temp.turn('0a3f8a91-d0aa-5869-8c0c-2fa74ce7975d', '64f6011a-6b21-52f1-a0fe-d64b55e751d4', 'Profesorica', 'Ne, sve gradivo dobivate od mene. Doma pišete vježbe.', 'Ні, весь матеріал отримуєте від мене. Вдома пишете вправи.', 3);
  perform pg_temp.turn('63306e00-0a5d-502e-9169-486b6c5956f5', '64f6011a-6b21-52f1-a0fe-d64b55e751d4', 'Oksana', 'Ima li na kraju ispit?', 'А наприкінці є іспит?', 4);
  perform pg_temp.turn('8a7bd8b1-d59a-5867-82c6-8260a84d3733', '64f6011a-6b21-52f1-a0fe-d64b55e751d4', 'Profesorica', 'Ima. Ako ga položite, dobivate svjedodžbu.', 'Є. Якщо складете, отримаєте свідоцтво.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('77ca8cff-a4c1-5b9a-a357-6a5473a111c1', v_lesson, 'Визнання диплома', 'Priznavanje diplome', 1872, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('3c5a08dc-830d-596c-a435-808ad408c960', '77ca8cff-a4c1-5b9a-a357-6a5473a111c1', 'Andrij', 'Želim raditi kao inženjer. Treba li mi priznavanje diplome?', 'Хочу працювати інженером. Мені потрібне визнання диплома?', 1);
  perform pg_temp.turn('b9df2965-6c97-547d-ad0d-4421e08b659f', '77ca8cff-a4c1-5b9a-a357-6a5473a111c1', 'Službenica', 'Treba. Donesite diplomu i prijevod.', 'Потрібне. Принесіть диплом і переклад.', 2);
  perform pg_temp.turn('75c666c3-3163-5ee5-ba82-91f5c8f15d9a', '77ca8cff-a4c1-5b9a-a357-6a5473a111c1', 'Andrij', 'Jesu li potrebne i ocjene s fakulteta?', 'Потрібні також оцінки з університету?', 3);
  perform pg_temp.turn('668acb6e-2fda-5fb4-b475-6f38693dd335', '77ca8cff-a4c1-5b9a-a357-6a5473a111c1', 'Službenica', 'Jesu, i popis predavanja.', 'Так, і перелік предметів.', 4);
  perform pg_temp.turn('50328aa8-5533-5f07-a408-54d774928229', '77ca8cff-a4c1-5b9a-a357-6a5473a111c1', 'Andrij', 'Dobro. Idem po dokumente.', 'Добре. Піду по документи.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 88: Надзвичайні ситуації
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '692e9310-7a5b-5adf-9f0a-a66b72fc5459';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 8) then
    raise exception 'A1.10: місце уроку 8 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b89a9004-2c03-567a-b23e-31db18f92dea';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.10.8'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 88: Надзвичайні ситуації', 'Lekcija 88: Hitne situacije', '["Викликати допомогу при пожежі", "Знати, що робити при землетрусі й повені", "Зрозуміти попередження й заборони"]'::jsonb, 12, 'PUBLISHED', 8);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'požar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vatrogasac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dim', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poplava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potres', v_pos);
  v_pos := pg_temp.word(v_lesson, 'evakuacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opasnost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sklonište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upozorenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spasiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gorjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uzbuna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'baterijska svjetiljka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izlaz u nuždi', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '1fc1d638-d851-5e93-8849-901ec70a9522', 'fill_in_the_blank', '___ koristite dizalo za vrijeme požara!', 'Ne', '["Nije", "Ne", "Nemojte", "Nema"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '672f8a97-8e69-57ee-a88b-267d400bd0d2', 'multiple_choice', 'Що означає «poplava»?', 'повінь', '["ліхтарик", "землетрус", "повінь", "небезпека"]'::jsonb, 'A1', 2, 'PUBLISHED', 'poplava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f936df75-a462-5b38-9c7b-fcd6eaa489a3', 'multiple_choice', 'Що означає «baterijska svjetiljka»?', 'ліхтарик', '["повінь", "ліхтарик", "горіти", "евакуація"]'::jsonb, 'A1', 3, 'PUBLISHED', 'baterijska svjetiljka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '52e21fbd-b054-56ab-9cb1-ff05c02d81d8', 'multiple_choice', 'Як хорватською «сховище / укриття»?', 'sklonište', '["gorjeti", "uzbuna", "sklonište", "potres"]'::jsonb, 'A1', 4, 'PUBLISHED', 'sklonište', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '99d832e5-aa85-5b19-badc-4eef2270fad4', 'type_answer', 'Напишіть хорватською: «землетрус»', 'potres', null, 'A1', 5, 'PUBLISHED', 'potres', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3ac5fcb2-448c-53fe-acd3-d12113b3bceb', 'type_answer', 'Напишіть хорватською: «пожежа»', 'požar', null, 'A1', 6, 'PUBLISHED', 'požar', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '444d1854-b6f0-55fd-a729-44c65e0f9a71', 'sentence_builder', 'Складіть: «Пожежники рятують людей.»', 'Vatrogasci spašavaju ljude.', '["ljude.", "spašavaju", "Vatrogasci"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '171724b3-8b0d-5545-8047-f524cabc07d9', 'sentence_builder', 'Складіть: «Тут немає небезпеки.»', 'Ovdje nema opasnosti.', '["opasnosti.", "Ovdje", "nema"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6211ac0f-88cb-5d27-971a-de0033b58ca0', 'listening', 'Прослухайте і складіть фразу', 'Gdje je izlaz u nuždi?', '["Gdje", "je", "nuždi?", "u", "izlaz"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4eb432a6-ed82-565a-9c51-a5def6489553', 'listening', 'Прослухайте і складіть фразу', 'A što radimo kod potresa?', '["radimo", "što", "kod", "A", "potresa?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '84bcd25e-4bee-5b12-a5c1-f61ed1f5ef5e', 'speaking', 'Під час повені не їдь машиною.', 'Za vrijeme poplave ne vozi auto.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1b9355e2-d02b-59a2-9f5a-c1549278bbd5', 'speaking', 'Де найближче укриття?', 'Gdje je najbliže sklonište?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('fbab0a54-6993-53a6-b672-f7f04b21bae1', v_lesson, 'Пожежа!', 'Požar!', 1881, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('f4fb7d45-447d-5956-857d-7a205cba9660', 'fbab0a54-6993-53a6-b672-f7f04b21bae1', 'Susjed', 'Osjećate li dim? Nešto gori!', 'Відчуваєте дим? Щось горить!', 1);
  perform pg_temp.turn('05e0844c-012d-5e99-8176-e08adad2ef95', 'fbab0a54-6993-53a6-b672-f7f04b21bae1', 'Olena', 'Gori u podrumu! Zovite 112!', 'Горить у підвалі! Дзвоніть 112!', 2);
  perform pg_temp.turn('b696d499-755f-5d2f-bb6e-c75fe6d7fd04', 'fbab0a54-6993-53a6-b672-f7f04b21bae1', 'Susjed', 'Ne koristite dizalo! Idemo stepenicama.', 'Не користуйтеся ліфтом! Ідемо сходами.', 3);
  perform pg_temp.turn('345e907c-ed01-5f04-b017-51b86a07b11f', 'fbab0a54-6993-53a6-b672-f7f04b21bae1', 'Olena', 'Gdje je izlaz u nuždi?', 'Де аварійний вихід?', 4);
  perform pg_temp.turn('081cb66e-a5c8-5427-b61c-34267583ab5e', 'fbab0a54-6993-53a6-b672-f7f04b21bae1', 'Susjed', 'Ondje, lijevo. Vatrogasci već dolaze.', 'Там, ліворуч. Пожежники вже їдуть.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('881d45eb-3837-51f1-be67-e135729b3743', v_lesson, 'Сирена й землетрус', 'Uzbuna i potres', 1882, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('c69b555d-f12e-5138-9de9-4c6b1cae6417', '881d45eb-3837-51f1-be67-e135729b3743', 'Ivana', 'Čuješ li sirenu? To je samo proba uzbune, svake prve subote u mjesecu.', 'Чуєш сирену? Це лише перевірка сигналу тривоги, щопершої суботи місяця.', 1);
  perform pg_temp.turn('f0f99b44-9d2d-5c97-ba03-0e9136fd38ff', '881d45eb-3837-51f1-be67-e135729b3743', 'Taras', 'Dobro. A što radimo kod potresa?', 'Добре. А що робимо під час землетрусу?', 2);
  perform pg_temp.turn('6e9eb22e-15c5-5942-93c1-7561cb2653b2', '881d45eb-3837-51f1-be67-e135729b3743', 'Ivana', 'Ne bježi van! Sakrij se ispod stola, dalje od prozora.', 'Не вибігай надвір! Сховайся під стіл, подалі від вікон.', 3);
  perform pg_temp.turn('1b9882f6-d73a-5b73-b9b4-f9309ec364c9', '881d45eb-3837-51f1-be67-e135729b3743', 'Taras', 'Trebamo li imati baterijsku svjetiljku i vodu?', 'Нам треба мати ліхтарик і воду?', 4);
  perform pg_temp.turn('c7d915ca-78eb-5df6-885a-95f1e638ef6b', '881d45eb-3837-51f1-be67-e135729b3743', 'Ivana', 'Da. I pratite upozorenja na mobitelu.', 'Так. І стежте за попередженнями на телефоні.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 89: Нове життя в Хорватії
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'dbb91fa1-4a97-5c04-99a8-8ac1d508b952';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 9) then
    raise exception 'A1.10: місце уроку 9 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '765ac66f-d54b-505b-9b11-c48e5ad26018';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.10.9'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 89: Нове життя в Хорватії', 'Lekcija 89: Novi život u Hrvatskoj', '["Порівняти життя в Україні й Хорватії", "Дати пораду новачкові", "Пояснити думку: бо, але, а"]'::jsonb, 12, 'PUBLISHED', 9);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'razlika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sličan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'različit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naviknuti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'domovina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'savjet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prednost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nedostatak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mentalitet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'strpljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljubazan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opušten', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zajednica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nada', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a5bc1408-0eb6-565d-89ab-08b77c79528f', 'fill_in_the_blank', 'Jezik je sličan, ___ i jako različit.', 'ali', '["ili", "jer", "da", "ali"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0058ed79-fb1a-5947-9873-4691419bdbd6', 'multiple_choice', 'Що означає «razlika»?', 'різниця', '["різниця", "батьківщина", "менталітет", "надія"]'::jsonb, 'A1', 2, 'PUBLISHED', 'razlika', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '709a4390-22a8-5945-9002-9abd1d269872', 'multiple_choice', 'Що означає «ljubazan»?', 'ввічливий; добрий', '["ввічливий; добрий", "схожий", "різний; відмінний", "недолік; нестача"]'::jsonb, 'A1', 3, 'PUBLISHED', 'ljubazan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7230079d-8e55-5ef5-bfa7-daae82570d7e', 'multiple_choice', 'Як хорватською «схожий»?', 'sličan', '["opušten", "domovina", "sličan", "savjet"]'::jsonb, 'A1', 4, 'PUBLISHED', 'sličan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9969f73e-bed2-5252-a0be-dc6bfd6fce22', 'type_answer', 'Напишіть хорватською: «терплячий»', 'strpljiv', null, 'A1', 5, 'PUBLISHED', 'strpljiv', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8aaf952f-6ad4-5a16-a430-7a6e4c9400eb', 'type_answer', 'Напишіть хорватською: «звикнути»', 'naviknuti se', null, 'A1', 6, 'PUBLISHED', 'naviknuti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bafa2a77-cb47-5f9c-9156-61bf6216978b', 'sentence_builder', 'Складіть: «Люди тут привітні й розслаблені.»', 'Ljudi su ovdje ljubazni i opušteni.', '["i", "ljubazni", "su", "ovdje", "opušteni.", "Ljudi"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4f59d08d-ae39-5ad7-bd83-0ed699b47c29', 'sentence_builder', 'Складіть: «Яка найбільша перевага?»', 'Koja je najveća prednost?', '["Koja", "najveća", "je", "prednost?"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '85be108a-fdea-56b5-8065-ed12448a2407', 'listening', 'Прослухайте і складіть фразу', 'A jezik? Je li sličan ukrajinskom?', '["Je", "li", "ukrajinskom?", "jezik?", "A", "sličan"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be2f5bd4-ec57-5ecd-91a0-5be67d1cbd58', 'listening', 'Прослухайте і складіть фразу', 'A nedostaci?', '["nedostaci?", "A"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '934e6656-ee4b-57c4-af70-a9fbc2b0a7fc', 'speaking', 'Менталітет тут інший.', 'Mentalitet je ovdje drukčiji.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f3ffc367-6b99-50af-b946-968397079577', 'speaking', 'Я звикаю до нового життя.', 'Navikavam se na novi život.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5f956f80-e783-57dc-8b3b-49c68606d168', v_lesson, 'Різниця', 'Razlike', 1891, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('9a823cdf-be66-55d2-9bde-84ae4183f6e3', '5f956f80-e783-57dc-8b3b-49c68606d168', 'Ivan', 'Koja je najveća razlika između Ukrajine i Hrvatske?', 'Яка найбільша різниця між Україною і Хорватією?', 1);
  perform pg_temp.turn('19f2446a-903c-564e-83d0-51b2a66df105', '5f956f80-e783-57dc-8b3b-49c68606d168', 'Olena', 'Ljudi su ovdje opušteni, a kod nas svi žure.', 'Люди тут розслаблені, а в нас усі поспішають.', 2);
  perform pg_temp.turn('453de6d4-d925-57ba-bd74-740391560bec', '5f956f80-e783-57dc-8b3b-49c68606d168', 'Ivan', 'A jezik? Je li sličan ukrajinskom?', 'А мова? Схожа на українську?', 3);
  perform pg_temp.turn('1f543def-e90d-520d-bc5c-e91259c6671e', '5f956f80-e783-57dc-8b3b-49c68606d168', 'Olena', 'Sličan je, ali i jako različit. Treba biti strpljiv.', 'Схожа, але й дуже відмінна. Треба бути терплячим.', 4);
  perform pg_temp.turn('a65ce737-5f43-58fc-ac33-8de623f6b0b0', '5f956f80-e783-57dc-8b3b-49c68606d168', 'Ivan', 'Polako se navikneš na sve.', 'Поступово звикаєш до всього.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7c0b7dd3-3258-5cea-9a66-5103362958b4', v_lesson, 'Порада новачкові', 'Savjet za nove', 1892, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('013f89aa-04ba-512a-b62a-0793cf686065', '7c0b7dd3-3258-5cea-9a66-5103362958b4', 'Taras', 'Moja sestra dolazi u Hrvatsku. Imaš li neki savjet?', 'Моя сестра приїжджає до Хорватії. Маєш якусь пораду?', 1);
  perform pg_temp.turn('4bb8ab11-7233-57d9-9926-a1f1a92158bf', '7c0b7dd3-3258-5cea-9a66-5103362958b4', 'Oksana', 'Neka uči jezik i upoznaje ljude, jer je to najveća prednost.', 'Нехай учить мову і знайомиться з людьми, бо це найбільша перевага.', 2);
  perform pg_temp.turn('4ba2ecdc-5c15-5909-9bb7-4655d81128b7', '7c0b7dd3-3258-5cea-9a66-5103362958b4', 'Taras', 'A nedostaci?', 'А недоліки?', 3);
  perform pg_temp.turn('959a5d5b-c8df-5de9-a6e6-001e8eef6604', '7c0b7dd3-3258-5cea-9a66-5103362958b4', 'Oksana', 'Papiri traju dugo. Ali ljudi su ljubazni, a ukrajinska zajednica je velika.', 'Документи оформлюються довго. Але люди привітні, а українська громада велика.', 4);
  perform pg_temp.turn('71d612dc-8060-5c92-a955-e11274854866', '7c0b7dd3-3258-5cea-9a66-5103362958b4', 'Taras', 'Hvala! Domovina joj nedostaje, ali ima nadu.', 'Дякую! Їй бракує батьківщини, але вона має надію.', 5);
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

-- 5. Самоперевірка частини 4: якщо щось не так — уся частина відкочується
do $$
declare v_new int; v_short int; v_scenes int; v_words int; v_total int; v_bad_titles int;
begin
  select count(*) into v_new from public.lessons where id in ('631c7f59-de43-5081-adb7-77bdf23ce805', '4edd1556-f088-5d14-8f59-529b35747609', 'f1b2093d-9699-59af-92b9-ed7bdf7fad49', '84a20a00-701a-5ce5-a3c8-fca72986f912', 'd9ef1de4-f4db-590e-bafd-474f84c8e03f', '33c041a0-e71a-55c1-94c8-64941876c6d2', 'fe2839bc-fd72-5e8b-bc0e-937d48a90aa8', '11b565a4-1e2a-50d2-8d9d-c05e84371402', '692e9310-7a5b-5adf-9f0a-a66b72fc5459', 'dbb91fa1-4a97-5c04-99a8-8ac1d508b952') and status = 'PUBLISHED';
  select count(*) into v_short from public.lessons l where l.id in ('631c7f59-de43-5081-adb7-77bdf23ce805', '4edd1556-f088-5d14-8f59-529b35747609', 'f1b2093d-9699-59af-92b9-ed7bdf7fad49', '84a20a00-701a-5ce5-a3c8-fca72986f912', 'd9ef1de4-f4db-590e-bafd-474f84c8e03f', '33c041a0-e71a-55c1-94c8-64941876c6d2', 'fe2839bc-fd72-5e8b-bc0e-937d48a90aa8', '11b565a4-1e2a-50d2-8d9d-c05e84371402', '692e9310-7a5b-5adf-9f0a-a66b72fc5459', 'dbb91fa1-4a97-5c04-99a8-8ac1d508b952')
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') < 12;
  select count(*) into v_scenes from public.lessons l where l.id in ('631c7f59-de43-5081-adb7-77bdf23ce805', '4edd1556-f088-5d14-8f59-529b35747609', 'f1b2093d-9699-59af-92b9-ed7bdf7fad49', '84a20a00-701a-5ce5-a3c8-fca72986f912', 'd9ef1de4-f4db-590e-bafd-474f84c8e03f', '33c041a0-e71a-55c1-94c8-64941876c6d2', 'fe2839bc-fd72-5e8b-bc0e-937d48a90aa8', '11b565a4-1e2a-50d2-8d9d-c05e84371402', '692e9310-7a5b-5adf-9f0a-a66b72fc5459', 'dbb91fa1-4a97-5c04-99a8-8ac1d508b952')
     and (select count(*) from public.conversations c where c.lesson_id = l.id) < 2;
  select count(*) into v_words from public.lessons l where l.id in ('631c7f59-de43-5081-adb7-77bdf23ce805', '4edd1556-f088-5d14-8f59-529b35747609', 'f1b2093d-9699-59af-92b9-ed7bdf7fad49', '84a20a00-701a-5ce5-a3c8-fca72986f912', 'd9ef1de4-f4db-590e-bafd-474f84c8e03f', '33c041a0-e71a-55c1-94c8-64941876c6d2', 'fe2839bc-fd72-5e8b-bc0e-937d48a90aa8', '11b565a4-1e2a-50d2-8d9d-c05e84371402', '692e9310-7a5b-5adf-9f0a-a66b72fc5459', 'dbb91fa1-4a97-5c04-99a8-8ac1d508b952')
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'lexeme') < 12;
  select count(*) into v_total from public.lessons where level_code = 'A1' and status = 'PUBLISHED';
  select count(*) into v_bad_titles from (
    select l.title_ua, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where m.level_code = 'A1' and l.status <> 'DEPRECATED') t
   where t.title_ua not like 'Урок ' || t.n || ':%';
  if v_new <> 10 then raise exception 'Частина 4: створено % уроків з 10', v_new; end if;
  if v_short > 0 then raise exception 'Частина 4: % уроків мають менше 12 вправ', v_short; end if;
  if v_scenes > 0 then raise exception 'Частина 4: % уроків без двох діалогів', v_scenes; end if;
  if v_words > 0 then raise exception 'Частина 4: % уроків мають менше 12 слів', v_words; end if;
  if v_bad_titles > 0 then raise exception 'Частина 4: % назв уроків A1 не за порядком', v_bad_titles; end if;
  raise notice 'Готово: частина 4 — 10 нових уроків; усього уроків A1 — %', v_total;
end $$;

commit;
