-- =====================================================================
-- Доповнення A1 · curriculum_a1_v2 · частина 2 з 4 · 2026-10-13
-- Згенеровано: python3 scripts/gen_curriculum_a1_v2.py (не редагуйте вручну).
-- Запуск: Supabase → SQL Editor → вставити ВЕСЬ файл → Run. Частини запускайте по черзі (1 → 4).
--
--   * 10 нових уроків (модулі A1.3–A1.5), у плані програми № 26–44:
--       A1.3 «Магазин електроніки»
--       A1.3 «Покупки в інтернеті»
--       A1.4 «Велосипед і самокат»
--       A1.4 «На автомагістралі»
--       A1.4 «В автосервісі»
--       A1.4 «Міжміський автобус»
--       A1.5 «Переїзд»
--       A1.5 «Правила будинку»
--       A1.5 «Опалення й холод»
--       A1.5 «Дрібний ремонт»
--   * У кожному 14 нових слів, 2 діалоги (104 реплік разом), граматика, 12 вправ, ~12 хв.
--   * Нові слова у словнику: 86. Виправлення словника: 7 (стара версія — у content_versions).
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

-- 1. Нові слова (86), яких ще немає у словнику
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('laptop', 'laptop', 'hr', 'noun', 'A1', 'ноутбук', 'core', '{"gender": "m"}'::jsonb, '["Za posao trebam novi laptop."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kabel', 'kabel', 'hr', 'noun', 'A1', 'кабель', 'core', '{"gender": "m"}'::jsonb, '["Ovaj kabel je prekratak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tablet', 'tablet', 'hr', 'noun', 'A1', 'планшет', 'core', '{"gender": "m"}'::jsonb, '["Djeca gledaju crtiće na tabletu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uključiti', 'ukljuciti', 'hr', 'verb', 'A1', 'увімкнути', 'core', '{"aspect": "pfv"}'::jsonb, '["Uključi računalo, molim te."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ispravan', 'ispravan', 'hr', 'adjective', 'A1', 'справний', 'core', '{}'::jsonb, '["Je li ovaj uređaj ispravan?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bežični', 'bezicni', 'hr', 'adjective', 'A1', 'бездротовий', 'core', '{}'::jsonb, '["Imam bežične slušalice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('narudžba', 'narudzba', 'hr', 'noun', 'A1', 'замовлення', 'core', '{"gender": "f"}'::jsonb, '["Narudžba stiže za tri dana."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('paketomat', 'paketomat', 'hr', 'noun', 'A1', 'поштомат', 'core', '{"gender": "m"}'::jsonb, '["Paket podižem u paketomatu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kurir', 'kurir', 'hr', 'noun', 'A1', 'кур’єр', 'core', '{"gender": "m"}'::jsonb, '["Kurir zove prije dostave."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('internetska trgovina', 'internetska trgovina', 'hr', 'phrase', 'A1', 'інтернет-магазин', 'collocation', '{"gender": "f"}'::jsonb, '["Odjeću često kupujem u internetskoj trgovini."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('oštećen', 'ostecen', 'hr', 'adjective', 'A1', 'пошкоджений', 'core', '{}'::jsonb, '["Pakiranje je oštećeno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('reklamacija', 'reklamacija', 'hr', 'noun', 'A1', 'скарга (на товар); рекламація', 'core', '{"gender": "f"}'::jsonb, '["Pišem reklamaciju trgovini."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('povrat novca', 'povrat novca', 'hr', 'phrase', 'A1', 'повернення грошей', 'collocation', '{"gender": "m"}'::jsonb, '["Tražim povrat novca."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pouzećem', 'pouzecem', 'hr', 'adverb', 'A1', 'післяплатою', 'core', '{}'::jsonb, '["Plaćam pouzećem, gotovinom kuriru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pakiranje', 'pakiranje', 'hr', 'noun', 'A1', 'упаковка', 'core', '{"gender": "n"}'::jsonb, '["Pakiranje je od kartona."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('praćenje pošiljke', 'pracenje posiljke', 'hr', 'phrase', 'A1', 'відстеження посилки', 'collocation', '{"gender": "n"}'::jsonb, '["Broj za praćenje pošiljke je u mailu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('romobil', 'romobil', 'hr', 'noun', 'A1', 'самокат', 'core', '{"gender": "m"}'::jsonb, '["Na posao idem električnim romobilom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kaciga', 'kaciga', 'hr', 'noun', 'A1', 'шолом', 'core', '{"gender": "f"}'::jsonb, '["Bez kacige ne voziš bicikl!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('biciklistička staza', 'biciklisticka staza', 'hr', 'phrase', 'A1', 'велодоріжка', 'collocation', '{"gender": "f"}'::jsonb, '["Uz rijeku je biciklistička staza."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('lanac', 'lanac', 'hr', 'noun', 'A1', 'ланцюг', 'core', '{"gender": "m"}'::jsonb, '["Lanac na biciklu treba podmazati."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('lokot', 'lokot', 'hr', 'noun', 'A1', 'замок (навісний; для велосипеда)', 'core', '{"gender": "m"}'::jsonb, '["Bicikl uvijek zaključaj lokotom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kočiti', 'kociti', 'hr', 'verb', 'A1', 'гальмувати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Na mokroj cesti koči polako."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pločnik', 'plocnik', 'hr', 'noun', 'A1', 'тротуар', 'core', '{"gender": "m"}'::jsonb, '["Po pločniku hodaju pješaci."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pažljivo', 'pazljivo', 'hr', 'adverb', 'A1', 'обережно; уважно', 'core', '{}'::jsonb, '["Vozi pažljivo!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('električni', 'elektricni', 'hr', 'adjective', 'A1', 'електричний', 'core', '{}'::jsonb, '["Imam električni bicikl."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('autocesta', 'autocesta', 'hr', 'noun', 'A1', 'автомагістраль', 'core', '{"gender": "f"}'::jsonb, '["Autocestom do Splita treba četiri sata."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('cestarina', 'cestarina', 'hr', 'noun', 'A1', 'плата за проїзд (на магістралі)', 'core', '{"gender": "f"}'::jsonb, '["Cestarina do Rijeke nije jeftina."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('naplatna kućica', 'naplatna kucica', 'hr', 'phrase', 'A1', 'пункт оплати проїзду', 'collocation', '{"gender": "f"}'::jsonb, '["Na naplatnoj kućici plaćam karticom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('izlaz', 'izlaz', 'hr', 'noun', 'A1', 'вихід; виїзд', 'core', '{"gender": "m"}'::jsonb, '["Uzmi sljedeći izlaz."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ograničenje brzine', 'ogranicenje brzine', 'hr', 'phrase', 'A1', 'обмеження швидкості', 'collocation', '{"gender": "n"}'::jsonb, '["Ograničenje brzine na autocesti je sto trideset."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prometna nesreća', 'prometna nesreca', 'hr', 'phrase', 'A1', 'ДТП; аварія', 'collocation', '{"gender": "f"}'::jsonb, '["Na autocesti je prometna nesreća."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odmorište', 'odmoriste', 'hr', 'noun', 'A1', 'зона відпочинку (на трасі)', 'core', '{"gender": "n"}'::jsonb, '["Stajemo na odmorištu na kavu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('obilaznica', 'obilaznica', 'hr', 'noun', 'A1', 'об’їзна дорога', 'core', '{"gender": "f"}'::jsonb, '["Idi obilaznicom, u gradu je gužva."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prometni znak', 'prometni znak', 'hr', 'phrase', 'A1', 'дорожній знак', 'collocation', '{"gender": "m"}'::jsonb, '["Pazi na prometne znakove."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kolona', 'kolona', 'hr', 'noun', 'A1', 'колона (машин); затор', 'core', '{"gender": "f"}'::jsonb, '["Na izlazu je kolona od pet kilometara."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pretjecati', 'pretjecati', 'hr', 'verb', 'A1', 'обганяти', 'core', '{"aspect": "ipfv"}'::jsonb, '["Ovdje je zabranjeno pretjecati."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('akumulator', 'akumulator', 'hr', 'noun', 'A1', 'акумулятор', 'core', '{"gender": "m"}'::jsonb, '["Akumulator je prazan, auto ne pali."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tehnički pregled', 'tehnicki pregled', 'hr', 'phrase', 'A1', 'техогляд', 'collocation', '{"gender": "m"}'::jsonb, '["Auto mora na tehnički pregled svake godine."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('registracija', 'registracija', 'hr', 'noun', 'A1', 'реєстрація (авто)', 'core', '{"gender": "f"}'::jsonb, '["Registracija vrijedi godinu dana."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mjenjač', 'mjenjac', 'hr', 'noun', 'A1', 'коробка передач', 'core', '{"gender": "m"}'::jsonb, '["Mjenjač čudno radi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('filter', 'filter', 'hr', 'noun', 'A1', 'фільтр', 'core', '{"gender": "m"}'::jsonb, '["Treba promijeniti filter za ulje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gotov', 'gotov', 'hr', 'adjective', 'A1', 'готовий (завершений)', 'core', '{}'::jsonb, '["Auto je gotov u petak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('autobusni kolodvor', 'autobusni kolodvor', 'hr', 'phrase', 'A1', 'автовокзал', 'collocation', '{"gender": "m"}'::jsonb, '["Autobusni kolodvor je blizu centra."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('međugradski', 'medugradski', 'hr', 'adjective', 'A1', 'міжміський', 'core', '{}'::jsonb, '["Međugradski autobusi kreću s kolodvora."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('polazak', 'polazak', 'hr', 'noun', 'A1', 'відправлення', 'core', '{"gender": "m"}'::jsonb, '["Polazak je u osam i petnaest."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sjedalo', 'sjedalo', 'hr', 'noun', 'A1', 'сидіння; місце', 'core', '{"gender": "n"}'::jsonb, '["Vaše sjedalo je broj dvanaest."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prtljažni prostor', 'prtljazni prostor', 'hr', 'phrase', 'A1', 'багажне відділення', 'collocation', '{"gender": "m"}'::jsonb, '["Kofer stavite u prtljažni prostor."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vožnja', 'voznja', 'hr', 'noun', 'A1', 'поїздка; їзда', 'core', '{"gender": "f"}'::jsonb, '["Vožnja do Splita traje pet sati."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('relacija', 'relacija', 'hr', 'noun', 'A1', 'маршрут; напрямок (рейсу)', 'core', '{"gender": "f"}'::jsonb, '["Trebam kartu za relaciju Zagreb – Osijek."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pojas', 'pojas', 'hr', 'noun', 'A1', 'пасок безпеки; пояс', 'core', '{"gender": "m"}'::jsonb, '["Vežite pojas, molim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vezati', 'vezati', 'hr', 'verb', 'A1', 'зав’язувати; пристібати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Djeca u autu moraju vezati pojas."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('izravan', 'izravan', 'hr', 'adjective', 'A1', 'прямий (без пересадок)', 'core', '{}'::jsonb, '["Ima li izravna linija za Pulu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('noćni', 'nocni', 'hr', 'adjective', 'A1', 'нічний', 'core', '{}'::jsonb, '["Noćni autobus kreće u ponoć."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('selidba', 'selidba', 'hr', 'noun', 'A1', 'переїзд', 'core', '{"gender": "f"}'::jsonb, '["Selidba je u subotu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('seliti se', 'seliti se', 'hr', 'verb', 'A1', 'переїжджати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Selimo se u novi stan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kutija', 'kutija', 'hr', 'noun', 'A1', 'коробка', 'core', '{"gender": "f"}'::jsonb, '["Knjige stavi u ovu kutiju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kombi', 'kombi', 'hr', 'noun', 'A1', 'мікроавтобус; бус', 'core', '{"gender": "m"}'::jsonb, '["Za selidbu unajmljujemo kombi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('lomljiv', 'lomljiv', 'hr', 'adjective', 'A1', 'крихкий', 'core', '{}'::jsonb, '["Pazi, ovo je lomljivo!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kućni red', 'kucni red', 'hr', 'phrase', 'A1', 'правила будинку', 'collocation', '{"gender": "m"}'::jsonb, '["Kućni red visi na oglasnoj ploči."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('upravitelj zgrade', 'upravitelj zgrade', 'hr', 'phrase', 'A1', 'управитель будинку', 'collocation', '{"gender": "m"}'::jsonb, '["Kvar prijavite upravitelju zgrade."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pričuva', 'pricuva', 'hr', 'noun', 'A1', 'внесок на утримання будинку', 'core', '{"gender": "f"}'::jsonb, '["Pričuvu plaćamo svaki mjesec."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tavan', 'tavan', 'hr', 'noun', 'A1', 'горище', 'core', '{"gender": "m"}'::jsonb, '["Stare stvari su na tavanu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sušiti', 'susiti', 'hr', 'verb', 'A1', 'сушити', 'core', '{"aspect": "ipfv"}'::jsonb, '["Rublje sušimo na balkonu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ulaz', 'ulaz', 'hr', 'noun', 'A1', 'вхід; під’їзд', 'core', '{"gender": "m"}'::jsonb, '["Naš ulaz je broj tri."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zabranjeno', 'zabranjeno', 'hr', 'adverb', 'A1', 'заборонено', 'core', '{}'::jsonb, '["Pušenje je ovdje zabranjeno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dopušteno', 'dopusteno', 'hr', 'adverb', 'A1', 'дозволено', 'core', '{}'::jsonb, '["Je li dopušteno imati psa?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('radijator', 'radijator', 'hr', 'noun', 'A1', 'радіатор; батарея (опалення)', 'core', '{"gender": "m"}'::jsonb, '["Radijator u sobi je hladan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('peć', 'pec', 'hr', 'noun', 'A1', 'піч; обігрівач', 'core', '{"gender": "f"}'::jsonb, '["U kući grijemo peć na drva."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('drva', 'drva', 'hr', 'noun', 'A1', 'дрова', 'core', '{"gender": "n", "number": "pl"}'::jsonb, '["Drva kupujemo u jesen."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prozračiti', 'prozraciti', 'hr', 'verb', 'A1', 'провітрити', 'core', '{"aspect": "pfv"}'::jsonb, '["Prozrači sobu deset minuta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vlaga', 'vlaga', 'hr', 'noun', 'A1', 'вологість; сирість', 'core', '{"gender": "f"}'::jsonb, '["U kupaonici je velika vlaga."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('plijesan', 'plijesan', 'hr', 'noun', 'A1', 'пліснява', 'core', '{"gender": "f"}'::jsonb, '["Na zidu je plijesan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('termostat', 'termostat', 'hr', 'noun', 'A1', 'термостат', 'core', '{"gender": "m"}'::jsonb, '["Termostat je na dvadeset stupnjeva."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('smrznuti se', 'smrznuti se', 'hr', 'verb', 'A1', 'замерзнути', 'core', '{"aspect": "pfv"}'::jsonb, '["Bez kape se brzo smrznem."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('brojilo', 'brojilo', 'hr', 'noun', 'A1', 'лічильник', 'core', '{"gender": "n"}'::jsonb, '["Brojilo za plin je u podrumu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('brtva', 'brtva', 'hr', 'noun', 'A1', 'прокладка (у крані)', 'core', '{"gender": "f"}'::jsonb, '["Slavina kaplje, treba nova brtva."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pločica', 'plocica', 'hr', 'noun', 'A1', 'плитка', 'core', '{"gender": "f"}'::jsonb, '["Jedna pločica u kupaonici je razbijena."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('čavao', 'cavao', 'hr', 'noun', 'A1', 'цвях', 'core', '{"gender": "m"}'::jsonb, '["Za sliku mi treba čavao."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('čekić', 'cekic', 'hr', 'noun', 'A1', 'молоток', 'core', '{"gender": "m"}'::jsonb, '["Daj mi čekić, molim te."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bušilica', 'busilica', 'hr', 'noun', 'A1', 'дриль', 'core', '{"gender": "f"}'::jsonb, '["Posudi mi bušilicu, molim te."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odvijač', 'odvijac', 'hr', 'noun', 'A1', 'викрутка', 'core', '{"gender": "m"}'::jsonb, '["Gdje je odvijač?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ličiti', 'liciti', 'hr', 'verb', 'A1', 'фарбувати (стіни)', 'core', '{"aspect": "ipfv"}'::jsonb, '["Ovaj vikend ličimo dnevni boravak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('objesiti', 'objesiti', 'hr', 'verb', 'A1', 'повісити', 'core', '{"aspect": "pfv"}'::jsonb, '["Objesi sliku na zid."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('slavina', 'slavina', 'hr', 'noun', 'A1', 'кран (водопровідний)', 'core', '{"gender": "f"}'::jsonb, '["Slavina u kuhinji kaplje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kapati', 'kapati', 'hr', 'verb', 'A1', 'капати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Voda kaplje sa stropa."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('žarulja', 'zarulja', 'hr', 'noun', 'A1', 'лампочка', 'core', '{"gender": "f"}'::jsonb, '["Promijeni žarulju u hodniku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v2')
on conflict do nothing;

-- 2. Виправлення словника для слів цих уроків (стара версія — у content_versions)
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('ekran') and ukrainian_translation = 'екрані / дисплей';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «екрані / дисплей» → «екран; дисплей»');
  update public.lexemes set ukrainian_translation = 'екран; дисплей' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «екрані / дисплей» → «екран; дисплей»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('kvačilo') and ukrainian_translation = 'Зчеплення';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «Зчеплення» → «зчеплення»');
  update public.lexemes set ukrainian_translation = 'зчеплення' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «Зчеплення» → «зчеплення»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('mir') and ukrainian_translation = 'мир';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «мир» → «спокій; мир»');
  update public.lexemes set ukrainian_translation = 'спокій; мир' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «мир» → «спокій; мир»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('preuzeti') and ukrainian_translation = 'завантажити; взяти';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «завантажити; взяти» → «забрати; отримати; завантажити»');
  update public.lexemes set ukrainian_translation = 'забрати; отримати; завантажити' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «завантажити; взяти» → «забрати; отримати; завантажити»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('mijenjati') and ukrainian_translation = 'змінювати';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «змінювати» → «міняти; змінювати»');
  update public.lexemes set ukrainian_translation = 'міняти; змінювати' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «змінювати» → «міняти; змінювати»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('prijevoz') and ukrainian_translation = 'транспорт';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: переклад «транспорт» → «транспорт; перевезення»');
  update public.lexemes set ukrainian_translation = 'транспорт; перевезення' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: переклад «транспорт» → «транспорт; перевезення»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lemma = 'Kvačilo';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v2: лема «Kvačilo» → «kvačilo»');
  update public.lexemes set lemma = 'kvačilo' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v2: лема «Kvačilo» → «kvačilo»');
end $$;

-- 3. Уроки
-- A1.3 · урок 26: Магазин електроніки
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '31bbedca-4b51-5478-8513-df5cb996ffd9';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 8) then
    raise exception 'A1.3: місце уроку 8 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.3.8'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 26: Магазин електроніки', 'Lekcija 26: Trgovina elektronike', '["Купити техніку й запитати про гарантію", "Пояснити, що пристрій не працює", "Назвати комп’ютерні речі"]'::jsonb, 12, 'PUBLISHED', 8);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'slušalice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'baterija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'laptop', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kabel', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jamstvo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ekran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tipkovnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'miš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvučnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tablet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uključiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'isključiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispravan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bežični', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'def4e61e-cc40-5e8c-ae80-132fdd71c1ef', 'fill_in_the_blank', '___ tipkovnicu želite, bežičnu ili s kabelom?', 'Kakvu', '["Kakva", "Kakvo", "Kakvu", "Kakav"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f6e5cfe8-b61f-545b-a660-cd7d6e13498c', 'multiple_choice', 'Що означає «ispravan»?', 'справний', '["вимкнути; виключити", "кабель", "екран; дисплей", "справний"]'::jsonb, 'A1', 2, 'PUBLISHED', 'ispravan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '87a1175e-1de2-543e-abc6-aea53e333b65', 'multiple_choice', 'Що означає «kabel»?', 'кабель', '["кабель", "навушники", "планшет", "батарея / акумулятор"]'::jsonb, 'A1', 3, 'PUBLISHED', 'kabel', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8ea86bbf-dafc-5333-b518-2184fe9e8d62', 'multiple_choice', 'Як хорватською «планшет»?', 'tablet', '["ekran", "tablet", "bežični", "isključiti"]'::jsonb, 'A1', 4, 'PUBLISHED', 'tablet', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e57e087-69fe-597d-b02d-a55b5c869b07', 'type_answer', 'Напишіть хорватською: «миша»', 'miš', null, 'A1', 5, 'PUBLISHED', 'miš', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '150bc125-92f8-5470-8678-0da997176607', 'type_answer', 'Напишіть хорватською: «клавіатура»', 'tipkovnica', null, 'A1', 6, 'PUBLISHED', 'tipkovnica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4f281565-8e27-50e0-9650-52e64211479f', 'sentence_builder', 'Складіть: «Яка гарантія на ноутбук?»', 'Koliko je jamstvo za laptop?', '["jamstvo", "laptop?", "Koliko", "za", "je"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '49793682-ac2c-5572-a79e-eff914c34a45', 'sentence_builder', 'Складіть: «У мене бездротові навушники.»', 'Imam bežične slušalice.', '["bežične", "slušalice.", "Imam"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '78e2d911-33ba-5321-91d0-798d95b611c0', 'listening', 'Прослухайте і складіть фразу', 'Koliko je jamstvo?', '["je", "Koliko", "jamstvo?"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '15f5f365-d69d-58a4-9e53-e57c8499fae7', 'listening', 'Прослухайте і складіть фразу', 'Ovaj zvučnik ne radi.', '["ne", "zvučnik", "Ovaj", "radi."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1e719521-045d-5729-993e-fe12099f66ac', 'speaking', 'Вимкни телефон, будь ласка.', 'Isključi mobitel, molim te.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '735db0cc-34b6-5d6e-af3a-dca5e0cf7182', 'speaking', 'Чи справний цей планшет?', 'Je li ovaj tablet ispravan?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ca47ba6f-9073-526f-b95f-f1d973de41cd', v_lesson, 'Купую ноутбук', 'Kupujem laptop', 1261, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('a2f9c78c-dd96-534d-83f5-b25c2c8e0850', 'ca47ba6f-9073-526f-b95f-f1d973de41cd', 'Prodavač', 'Kakav laptop tražite?', 'Який ноутбук шукаєте?', 1);
  perform pg_temp.turn('8c39c88a-7131-5e0d-8ac1-9b61f1262ff6', 'ca47ba6f-9073-526f-b95f-f1d973de41cd', 'Andrij', 'Za posao. Koliko traje baterija?', 'Для роботи. Скільки тримає батарея?', 2);
  perform pg_temp.turn('9d6008ce-de49-599f-8310-b52ef3e9d705', 'ca47ba6f-9073-526f-b95f-f1d973de41cd', 'Prodavač', 'Do deset sati. Ekran je velik, a tipkovnica ima svjetlo.', 'До десяти годин. Екран великий, а клавіатура з підсвіткою.', 3);
  perform pg_temp.turn('8cdd7fc3-0e74-5728-ac33-d6953e3f9390', 'ca47ba6f-9073-526f-b95f-f1d973de41cd', 'Andrij', 'Koliko je jamstvo?', 'Яка гарантія?', 4);
  perform pg_temp.turn('6fdbdccd-9241-501a-9ef6-defddbc07388', 'ca47ba6f-9073-526f-b95f-f1d973de41cd', 'Prodavač', 'Dvije godine. Bežični miš dobivate gratis.', 'Два роки. Бездротову мишку отримуєте в подарунок.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ceb02630-fcc1-5b76-9d1c-8ac7ca6007de', v_lesson, 'Не працює!', 'Ne radi!', 1262, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('f933193c-b37d-5911-9f29-f758f60bc564', 'ceb02630-fcc1-5b76-9d1c-8ac7ca6007de', 'Oksana', 'Ovaj zvučnik ne radi. Imam račun.', 'Ця колонка не працює. У мене є чек.', 1);
  perform pg_temp.turn('ce84d7b7-40b9-51a5-a02c-adba30c96f4a', 'ceb02630-fcc1-5b76-9d1c-8ac7ca6007de', 'Prodavačica', 'Koji je problem? Ne može se uključiti?', 'Яка проблема? Не вмикається?', 2);
  perform pg_temp.turn('cab39201-fefc-5a4b-8fa4-e8d07a579d9a', 'ceb02630-fcc1-5b76-9d1c-8ac7ca6007de', 'Oksana', 'Uključuje se, ali nema zvuka. Ni kabel ne pomaže.', 'Вмикається, але немає звуку. І кабель не допомагає.', 3);
  perform pg_temp.turn('7d1d871e-d81a-5a3b-bc50-4613e6d16439', 'ceb02630-fcc1-5b76-9d1c-8ac7ca6007de', 'Prodavačica', 'Dobro, provjeravamo. Ako nije ispravan, dobivate novi.', 'Добре, перевіримо. Якщо вона несправна, отримаєте нову.', 4);
  perform pg_temp.turn('fd421b1a-c538-5e2b-8ddd-b523d338f50e', 'ceb02630-fcc1-5b76-9d1c-8ac7ca6007de', 'Oksana', 'Hvala. A imate li slušalice za tablet?', 'Дякую. А у вас є навушники для планшета?', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 27: Покупки в інтернеті
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '91d4c9b3-c9a8-5e94-8691-6683835c375b';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 9) then
    raise exception 'A1.3: місце уроку 9 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b89a9004-2c03-567a-b23e-31db18f92dea';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.3.9'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 27: Покупки в інтернеті', 'Lekcija 27: Kupnja preko interneta', '["Відстежити замовлення з інтернет-магазину", "Поскаржитися на пошкоджену посилку", "Попросити повернути гроші"]'::jsonb, 12, 'PUBLISHED', 9);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'narudžba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'paketomat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kurir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pošiljka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dostava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'internetska trgovina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pratiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oštećen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'reklamacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povrat novca', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pouzećem', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pakiranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'praćenje pošiljke', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '7211f908-1c19-5221-a548-2d7a3affdf48', 'fill_in_the_blank', 'Kurir ___ dolazi danas.', 'ne', '["ni", "nema", "nije", "ne"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c12097e9-be4a-51fd-a048-363035dcb952', 'multiple_choice', 'Що означає «pratiti»?', 'стежити, супроводжувати', '["післяплатою", "кур’єр", "стежити, супроводжувати", "покупець"]'::jsonb, 'A1', 2, 'PUBLISHED', 'pratiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4055be6b-5e55-541c-860c-ce123b15911b', 'multiple_choice', 'Що означає «narudžba»?', 'замовлення', '["повернення грошей", "інтернет-магазин", "упаковка", "замовлення"]'::jsonb, 'A1', 3, 'PUBLISHED', 'narudžba', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7abebcfa-303a-552d-8f84-41ff9689e76c', 'multiple_choice', 'Як хорватською «кур’єр»?', 'kurir', '["pouzećem", "kupac", "pakiranje", "kurir"]'::jsonb, 'A1', 4, 'PUBLISHED', 'kurir', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4d1bbe5a-00b1-59a8-abbd-de27945610c6', 'type_answer', 'Напишіть хорватською: «доставка»', 'dostava', null, 'A1', 5, 'PUBLISHED', 'dostava', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '181c1cd7-4d88-5a83-91aa-7680da6ad495', 'type_answer', 'Напишіть хорватською: «пошкоджений»', 'oštećen', null, 'A1', 6, 'PUBLISHED', 'oštećen', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '988d5d5a-d140-5599-a7ee-d7b971d26dc8', 'sentence_builder', 'Складіть: «Я плачу післяплатою.»', 'Plaćam pouzećem.', '["pouzećem.", "Plaćam"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '04c16402-bc80-56fd-8dcb-9c53a1b396ab', 'sentence_builder', 'Складіть: «Упаковка не пошкоджена.»', 'Pakiranje nije oštećeno.', '["oštećeno.", "Pakiranje", "nije"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2ee86821-eb30-5433-9d99-4fcb11041fd4', 'listening', 'Прослухайте і складіть фразу', 'Imaš li broj za praćenje pošiljke?', '["broj", "Imaš", "pošiljke?", "li", "praćenje", "za"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1768deef-54a8-52fe-93bd-1e962107a806', 'listening', 'Прослухайте і складіть фразу', 'Recite, koji je problem?', '["koji", "Recite,", "je", "problem?"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '47208ec6-f67a-5127-8672-9a4391979f0c', 'speaking', 'Покупець не задоволений.', 'Kupac nije zadovoljan.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4300585f-1e69-58c1-a356-53e47dfa765a', 'speaking', 'Мені не потрібна доставка.', 'Ne trebam dostavu.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9758fb38-d629-5eb0-aa26-a88d040f87ef', v_lesson, 'Де моє замовлення?', 'Gdje je moja narudžba?', 1271, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('f890c976-e3fa-5aad-88da-96dee075a5c6', '9758fb38-d629-5eb0-aa26-a88d040f87ef', 'Olena', 'Čekam narudžbu već tjedan dana.', 'Я чекаю на замовлення вже тиждень.', 1);
  perform pg_temp.turn('b6b46dff-e212-5492-a1f0-117ff154f250', '9758fb38-d629-5eb0-aa26-a88d040f87ef', 'Marija', 'Imaš li broj za praćenje pošiljke?', 'У тебе є номер для відстеження посилки?', 2);
  perform pg_temp.turn('2530e3f1-09b3-58f4-8a2c-cc9cc8daea38', '9758fb38-d629-5eb0-aa26-a88d040f87ef', 'Olena', 'Imam. Pratim pošiljku, piše: kod kurira.', 'Є. Відстежую посилку, написано: у кур’єра.', 3);
  perform pg_temp.turn('9fd6f411-cca1-5ddf-a1f4-4acc2b15a51e', '9758fb38-d629-5eb0-aa26-a88d040f87ef', 'Marija', 'Onda stiže danas. Plaćaš li pouzećem?', 'Тоді прийде сьогодні. Ти платиш післяплатою?', 4);
  perform pg_temp.turn('0f86b29c-ead0-540a-9902-1fd0c66ac3b5', '9758fb38-d629-5eb0-aa26-a88d040f87ef', 'Olena', 'Ne, karticom. I dostava nije na adresu, nego u paketomat.', 'Ні, карткою. І доставка не на адресу, а в поштомат.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('43828796-4671-5b3d-b26b-29be70d01f25', v_lesson, 'Пошкоджена посилка', 'Oštećena pošiljka', 1272, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('fffe960c-bb81-50aa-957d-662cccf5b2b5', '43828796-4671-5b3d-b26b-29be70d01f25', 'Taras', 'Dobar dan, zovem zbog reklamacije.', 'Добрий день, дзвоню щодо скарги.', 1);
  perform pg_temp.turn('b7ef1bdb-be2a-5983-88b2-7aa164d23927', '43828796-4671-5b3d-b26b-29be70d01f25', 'Službenica', 'Recite, koji je problem?', 'Скажіть, яка проблема?', 2);
  perform pg_temp.turn('75e5a5fa-560b-54df-9765-c19a728dd3b9', '43828796-4671-5b3d-b26b-29be70d01f25', 'Taras', 'Pakiranje je oštećeno, a šalica unutra je razbijena.', 'Упаковка пошкоджена, а чашка всередині розбита.', 3);
  perform pg_temp.turn('6bb4aa40-68d9-5c8c-8fb4-89ed9b1039ca', '43828796-4671-5b3d-b26b-29be70d01f25', 'Službenica', 'Žao mi je. Želite li novu šalicu ili povrat novca?', 'Мені шкода. Хочете нову чашку чи повернення грошей?', 4);
  perform pg_temp.turn('d359e1ec-1707-5f42-addf-d0285bff3bc7', '43828796-4671-5b3d-b26b-29be70d01f25', 'Taras', 'Povrat novca. Ne kupujem više u toj internetskoj trgovini.', 'Повернення грошей. Більше не купую в цьому інтернет-магазині.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 33: Велосипед і самокат
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '0b04119b-4d38-5d99-8237-caa95fdcfd95';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A1.4: місце уроку 6 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.4.6'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 33: Велосипед і самокат', 'Lekcija 33: Bicikl i romobil', '["Орендувати велосипед", "Зрозуміти правила для велосипеда й самоката", "Сказати, де можна їздити"]'::jsonb, 12, 'PUBLISHED', 6);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'romobil', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kaciga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'biciklistička staza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kotač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lanac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lokot', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iznajmiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pješak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kočiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kočnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pločnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opasno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pažljivo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'električni', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '34c8ce45-b04d-59fb-b25d-f8656f1e5079', 'fill_in_the_blank', 'Pješaci hodaju po ___.', 'pločniku', '["pločnik", "pločniku", "pločnika", "pločnikom"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e36db181-0cf6-5268-9a4b-d3f0cbf35734', 'multiple_choice', 'Що означає «pločnik»?', 'тротуар', '["шолом", "тротуар", "електричний", "пішохід"]'::jsonb, 'A1', 2, 'PUBLISHED', 'pločnik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '951fd437-b1c7-50e2-85f4-48be19ac9af3', 'multiple_choice', 'Що означає «kaciga»?', 'шолом', '["шолом", "пішохід", "гальмо", "небезпечно"]'::jsonb, 'A1', 3, 'PUBLISHED', 'kaciga', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1430077f-a3c9-5b3b-a053-3f4bf61f6a79', 'multiple_choice', 'Як хорватською «обережно; уважно»?', 'pažljivo', '["lanac", "pažljivo", "lokot", "kaciga"]'::jsonb, 'A1', 4, 'PUBLISHED', 'pažljivo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5497987f-523d-59a4-9913-8a916ff43a27', 'type_answer', 'Напишіть хорватською: «гальмо»', 'kočnica', null, 'A1', 5, 'PUBLISHED', 'kočnica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd9e95a0d-54bb-517f-879b-73d2c5744fcb', 'type_answer', 'Напишіть хорватською: «гальмувати»', 'kočiti', null, 'A1', 6, 'PUBLISHED', 'kočiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a361b73d-e193-5d47-af28-66fef906dd65', 'sentence_builder', 'Складіть: «Їдь обережно по велодоріжці.»', 'Vozi pažljivo po biciklističkoj stazi.', '["biciklističkoj", "po", "pažljivo", "Vozi", "stazi."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a52399dd-94a3-56de-8ec9-cf193862b6ae', 'sentence_builder', 'Складіть: «Колесо й ланцюг у порядку.»', 'Kotač i lanac su u redu.', '["u", "su", "i", "redu.", "lanac", "Kotač"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '36d517db-6c02-5dfe-a473-ebb670972523', 'listening', 'Прослухайте і складіть фразу', 'Običan ili električni?', '["ili", "Običan", "električni?"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a8819d76-9819-5f29-b990-289c51a9d58c', 'listening', 'Прослухайте і складіть фразу', 'Oprostite, ne znam pravila.', '["znam", "pravila.", "Oprostite,", "ne"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c7d727c5-cc74-563d-8a3b-6e982baf3803', 'speaking', 'Гальмуй повільно, дорога мокра.', 'Koči polako, cesta je mokra.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e9bfcd9e-22d4-5b7b-a82f-cd49aae46899', 'speaking', 'Без шолома небезпечно.', 'Bez kacige je opasno.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5b41648a-e2ef-5540-913d-fba94c6ffcf0', v_lesson, 'Прокат велосипеда', 'Najam bicikla', 1331, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('0b4502ba-f3cd-5c11-9bfd-f3147c3eb952', '5b41648a-e2ef-5540-913d-fba94c6ffcf0', 'Andrij', 'Mogu li iznajmiti bicikl na jedan dan?', 'Можна орендувати велосипед на один день?', 1);
  perform pg_temp.turn('763bbc2d-d62c-5ae0-8cba-bc13b28bb768', '5b41648a-e2ef-5540-913d-fba94c6ffcf0', 'Djelatnik', 'Može. Običan ili električni?', 'Можна. Звичайний чи електричний?', 2);
  perform pg_temp.turn('fac2b562-20a0-5d16-8fee-d6f87777a6fa', '5b41648a-e2ef-5540-913d-fba94c6ffcf0', 'Andrij', 'Običan. Imate li i kacigu?', 'Звичайний. А шолом у вас є?', 3);
  perform pg_temp.turn('36026b04-9b5f-51b9-b9c2-8614d36feab9', '5b41648a-e2ef-5540-913d-fba94c6ffcf0', 'Djelatnik', 'Imamo. Lokot je u torbi na biciklu.', 'Є. Замок у сумці на велосипеді.', 4);
  perform pg_temp.turn('5391003e-d1b5-5d93-b9d4-62c5d074d7f1', '5b41648a-e2ef-5540-913d-fba94c6ffcf0', 'Andrij', 'Gdje je biciklistička staza?', 'Де велодоріжка?', 5);
  perform pg_temp.turn('acc72898-2693-5402-ab1a-8ef60910073d', '5b41648a-e2ef-5540-913d-fba94c6ffcf0', 'Djelatnik', 'Uz rijeku, na lijevoj strani.', 'Уздовж річки, з лівого боку.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2d178792-2a0b-58ff-baa0-4fd68f0334a1', v_lesson, 'Не на тротуарі!', 'Ne po pločniku!', 1332, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('67bec37b-b675-5360-8fcd-131ca162e508', '2d178792-2a0b-58ff-baa0-4fd68f0334a1', 'Policajac', 'Stanite! Ne smijete voziti romobil po pločniku.', 'Зупиніться! Не можна їздити на самокаті по тротуару.', 1);
  perform pg_temp.turn('98070b0b-b260-58de-98c1-cb57006b0a82', '2d178792-2a0b-58ff-baa0-4fd68f0334a1', 'Taras', 'Oprostite, ne znam pravila.', 'Вибачте, я не знаю правил.', 2);
  perform pg_temp.turn('180af962-47d3-5e24-9244-704db360d835', '2d178792-2a0b-58ff-baa0-4fd68f0334a1', 'Policajac', 'Na pločniku su pješaci. To je opasno.', 'На тротуарі пішоходи. Це небезпечно.', 3);
  perform pg_temp.turn('aec35918-3856-50ca-a5c8-41af68f445e9', '2d178792-2a0b-58ff-baa0-4fd68f0334a1', 'Taras', 'Razumijem. A gdje mogu voziti?', 'Зрозумів. А де можна їздити?', 4);
  perform pg_temp.turn('66c9aaaf-3858-5cce-a9e8-9f267b95f2c9', '2d178792-2a0b-58ff-baa0-4fd68f0334a1', 'Policajac', 'Na stazi ili na cesti. I vozite pažljivo, kočnica Vam ne radi dobro.', 'На доріжці або на дорозі. І їдьте обережно, у вас погано працює гальмо.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 34: На автомагістралі
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '06f927cf-f38c-51b5-a1f9-696698ad23fb';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A1.4: місце уроку 7 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.4.7'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 34: На автомагістралі', 'Lekcija 34: Na autocesti', '["Поїхати магістраллю й заплатити за проїзд", "Зрозуміти новини про затор", "Назвати знаки й правила на дорозі"]'::jsonb, 12, 'PUBLISHED', 7);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'autocesta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'cestarina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naplatna kućica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izlaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smjer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kružni tok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ograničenje brzine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brzina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prometna nesreća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odmorište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obilaznica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prometni znak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolona', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pretjecati', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c22c192e-6475-5631-aca8-077a38b085bf', 'fill_in_the_blank', 'Kolona je duga tri ___.', 'kilometra', '["kilometru", "kilometar", "kilometra", "kilometrom"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e8ff85f7-bd13-5099-997f-eda7cf3a7346', 'multiple_choice', 'Що означає «ograničenje brzine»?', 'обмеження швидкості', '["швидкість", "обмеження швидкості", "дорожній знак", "напрямок"]'::jsonb, 'A1', 2, 'PUBLISHED', 'ograničenje brzine', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2970d4d1-f1f0-5b38-9f98-78a101e52582', 'multiple_choice', 'Що означає «izlaz»?', 'вихід; виїзд', '["автомагістраль", "вихід; виїзд", "плата за проїзд (на магістралі)", "зона відпочинку (на трасі)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'izlaz', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aea08594-5799-5eee-991c-391cbf48c8f0', 'multiple_choice', 'Як хорватською «пункт оплати проїзду»?', 'naplatna kućica', '["pretjecati", "autocesta", "cestarina", "naplatna kućica"]'::jsonb, 'A1', 4, 'PUBLISHED', 'naplatna kućica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f2dbb5b-a972-549d-927d-de41fbe818f5', 'type_answer', 'Напишіть хорватською: «автомагістраль»', 'autocesta', null, 'A1', 5, 'PUBLISHED', 'autocesta', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ef6e4f7a-19c1-5650-be81-8a3e1a2dbc85', 'type_answer', 'Напишіть хорватською: «об’їзна дорога»', 'obilaznica', null, 'A1', 6, 'PUBLISHED', 'obilaznica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bc7b4b81-16fc-54be-b06a-80aac04e0c73', 'sentence_builder', 'Складіть: «Візьми наступний виїзд.»', 'Uzmi sljedeći izlaz.', '["sljedeći", "izlaz.", "Uzmi"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '51d756ca-1501-57a4-aab0-779f5200b1a0', 'sentence_builder', 'Складіть: «Скільки коштує проїзд до Рієки?»', 'Koliko košta cestarina do Rijeke?', '["košta", "cestarina", "Rijeke?", "Koliko", "do"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '298de1e5-ffbb-5bf1-8d0b-ba1281ad03d4', 'listening', 'Прослухайте і складіть фразу', 'Koliko košta cestarina?', '["cestarina?", "Koliko", "košta"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f50b33f5-97e7-5fec-a8a7-6b6beca2832f', 'listening', 'Прослухайте і складіть фразу', 'Ima li obilaznica?', '["obilaznica?", "Ima", "li"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ccd50d46-c06a-5624-986d-747d07d85b1d', 'speaking', 'Яке тут обмеження швидкості?', 'Koje je ovdje ograničenje brzine?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f7c882a4-b885-5dab-aaaa-68f4152df029', 'speaking', 'Їдь повільніше, швидкість велика.', 'Vozi sporije, brzina je velika.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('868d18fd-e45e-5fac-afe9-40969dd34959', v_lesson, 'Дорога до Спліта', 'Prema Splitu', 1341, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('5127041b-0369-5567-976c-7e010cf86b66', '868d18fd-e45e-5fac-afe9-40969dd34959', 'Olena', 'Koliko kilometara ima do Splita?', 'Скільки кілометрів до Спліта?', 1);
  perform pg_temp.turn('f40208f8-eb20-5872-bd17-3adee446e482', '868d18fd-e45e-5fac-afe9-40969dd34959', 'Taras', 'Oko četiristo. Autocestom treba četiri sata.', 'Близько чотирьохсот. Магістраллю — чотири години.', 2);
  perform pg_temp.turn('8b64da6f-17b5-50d4-825b-f71b6e82d5fe', '868d18fd-e45e-5fac-afe9-40969dd34959', 'Olena', 'Koliko košta cestarina?', 'Скільки коштує проїзд?', 3);
  perform pg_temp.turn('c62abca3-3499-56ca-9630-f012e19362f9', '868d18fd-e45e-5fac-afe9-40969dd34959', 'Taras', 'Oko trideset eura. Plaćamo na naplatnoj kućici.', 'Близько тридцяти євро. Платимо на пункті оплати.', 4);
  perform pg_temp.turn('021860bb-9aac-5d7b-bd2f-5dc1754fb75d', '868d18fd-e45e-5fac-afe9-40969dd34959', 'Olena', 'Stanimo na odmorištu, trebam kavu.', 'Зупинімося на зоні відпочинку, мені треба кави.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('707ab4f0-a72d-539c-b1c0-d19759597d67', v_lesson, 'Затор', 'Kolona', 1342, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('9cc91722-4851-582f-a19a-9adfcdd1a7f2', '707ab4f0-a72d-539c-b1c0-d19759597d67', 'Radio', 'Zbog prometne nesreće kod izlaza Karlovac je kolona od tri kilometra.', 'Через ДТП біля виїзду Карловац затор три кілометри.', 1);
  perform pg_temp.turn('f0026c68-865a-5a1e-8a2a-abadaeaad6cf', '707ab4f0-a72d-539c-b1c0-d19759597d67', 'Taras', 'Opet kolona! Ima li obilaznica?', 'Знову затор! Є об’їзна дорога?', 2);
  perform pg_temp.turn('d0751f87-2c0f-5ac8-9c12-7fa1fde8e34f', '707ab4f0-a72d-539c-b1c0-d19759597d67', 'Olena', 'Ima. Na kružnom toku skreni u smjeru Zagreba.', 'Є. На кільці поверни в напрямку Загреба.', 3);
  perform pg_temp.turn('66b3a2c3-b279-5ed8-bc71-bbb5b3c8edf9', '707ab4f0-a72d-539c-b1c0-d19759597d67', 'Taras', 'Pazi, ograničenje brzine je pedeset.', 'Обережно, обмеження швидкості — п’ятдесят.', 4);
  perform pg_temp.turn('bf6051e9-d985-5d61-b0dd-f843d26a6c3b', '707ab4f0-a72d-539c-b1c0-d19759597d67', 'Olena', 'Vidim prometni znak. I ne pretječi ovdje!', 'Бачу дорожній знак. І не обганяй тут!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 35: В автосервісі
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'cd5db261-a421-511d-8100-f86bf2335bbe';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 8) then
    raise exception 'A1.4: місце уроку 8 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.4.8'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 35: В автосервісі', 'Lekcija 35: Na servisu', '["Пояснити механікові, що з машиною", "Пройти техогляд і продовжити реєстрацію", "Запитати про ціну й терміни ремонту"]'::jsonb, 12, 'PUBLISHED', 8);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'servis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mehaničar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'akumulator', v_pos);
  v_pos := pg_temp.word(v_lesson, 'motor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svjetlo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tehnički pregled', v_pos);
  v_pos := pg_temp.word(v_lesson, 'registracija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mijenjati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kvačilo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mjenjač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'filter', v_pos);
  v_pos := pg_temp.word(v_lesson, 'popravak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gotov', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvuk', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '3c1d6e84-e03c-5ce7-9bab-bfb6de5d8a78', 'fill_in_the_blank', 'Auto ___ na tehnički pregled svake godine.', 'mora', '["moraš", "moram", "mora", "moraju"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '15b455c8-a82f-5701-aacc-4a3dfc23c739', 'multiple_choice', 'Що означає «motor»?', 'двигун', '["механік", "фільтр", "двигун", "ремонт"]'::jsonb, 'A1', 2, 'PUBLISHED', 'motor', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd8be2e21-02d9-5515-bfab-6d78dfe1cc9b', 'multiple_choice', 'Що означає «popravak»?', 'ремонт', '["фільтр", "коробка передач", "механік", "ремонт"]'::jsonb, 'A1', 3, 'PUBLISHED', 'popravak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'db3e44c4-3b4b-5d7d-979f-c8a9c784002a', 'multiple_choice', 'Як хорватською «звук»?', 'zvuk', '["zvuk", "tehnički pregled", "servis", "motor"]'::jsonb, 'A1', 4, 'PUBLISHED', 'zvuk', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b1626ab7-bae3-5a99-80f7-ba669e0de6e0', 'type_answer', 'Напишіть хорватською: «зчеплення»', 'kvačilo', null, 'A1', 5, 'PUBLISHED', 'kvačilo', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '95fc9cd0-a020-5f8b-a631-e81d22d3f4d0', 'type_answer', 'Напишіть хорватською: «сервіс; майстерня»', 'servis', null, 'A1', 6, 'PUBLISHED', 'servis', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '60cf77fc-7c79-53f5-83fe-9b90ca7eda35', 'sentence_builder', 'Складіть: «Акумулятор розряджений.»', 'Akumulator je prazan.', '["je", "Akumulator", "prazan."]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8f6a53e6-3796-5c85-85cc-ab0f588ed39b', 'sentence_builder', 'Складіть: «Коли машина буде готова?»', 'Kada je auto gotov?', '["gotov?", "auto", "je", "Kada"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7079a698-c6ac-590d-ac0a-28109c6c413d', 'listening', 'Прослухайте і складіть фразу', 'Koliko košta popravak?', '["Koliko", "popravak?", "košta"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '45a98f7f-9288-5e5a-afd1-156148beb251', 'listening', 'Прослухайте і складіть фразу', 'Može li to napraviti servis ovdje?', '["ovdje?", "Može", "to", "napraviti", "li", "servis"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '22a41577-1cb6-5d66-9db8-e9ef0d89f45b', 'speaking', 'Треба поміняти фільтр.', 'Treba promijeniti filter.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a44e975-7dd3-5dac-b989-7fb750a5f277', 'speaking', 'Механік ремонтує двигун.', 'Mehaničar popravlja motor.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('082e54ec-1b76-57d6-a9eb-2cef543b3d3e', v_lesson, 'Дивний звук', 'Čudan zvuk', 1351, 'A1', 'car_service', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('875f35e7-37c9-5f12-869d-293278a06445', '082e54ec-1b76-57d6-a9eb-2cef543b3d3e', 'Taras', 'Dobar dan. Motor ima neki čudan zvuk.', 'Добрий день. Двигун якось дивно звучить.', 1);
  perform pg_temp.turn('7062b249-b190-593b-898b-668b683856fd', '082e54ec-1b76-57d6-a9eb-2cef543b3d3e', 'Mehaničar', 'Kada? Kad mijenjate brzine?', 'Коли? Коли перемикаєте передачі?', 2);
  perform pg_temp.turn('9fe4dae6-24a6-5b20-850a-a3d46180d7ab', '082e54ec-1b76-57d6-a9eb-2cef543b3d3e', 'Taras', 'Da. Mislim da je problem kvačilo ili mjenjač.', 'Так. Думаю, проблема в зчепленні або коробці передач.', 3);
  perform pg_temp.turn('94da2e4c-6f00-5de5-9d28-7cb08d46097f', '082e54ec-1b76-57d6-a9eb-2cef543b3d3e', 'Mehaničar', 'Moram pogledati. Možete li ostaviti auto do sutra?', 'Мушу подивитися. Можете залишити авто до завтра?', 4);
  perform pg_temp.turn('9c0bf8fd-104d-552d-8c0c-f37bb1615467', '082e54ec-1b76-57d6-a9eb-2cef543b3d3e', 'Taras', 'Mogu. Koliko košta popravak?', 'Можу. Скільки коштує ремонт?', 5);
  perform pg_temp.turn('e1179f31-97f1-5648-8df6-9154ebe5d489', '082e54ec-1b76-57d6-a9eb-2cef543b3d3e', 'Mehaničar', 'Ne znam još. Zovem Vas kad je gotov.', 'Ще не знаю. Подзвоню вам, коли буде готовий.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('653cdaf4-9e91-52d8-9be5-80145b2f35f8', v_lesson, 'Техогляд', 'Tehnički pregled', 1352, 'A1', 'car_service', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('b558dd54-df0a-50f5-96be-5f4ed625f41a', '653cdaf4-9e91-52d8-9be5-80145b2f35f8', 'Olena', 'Trebam tehnički pregled i registraciju.', 'Мені потрібні техогляд і реєстрація.', 1);
  perform pg_temp.turn('86db3528-7d4c-5e34-92cd-5471be55cc8b', '653cdaf4-9e91-52d8-9be5-80145b2f35f8', 'Službenik', 'Svjetla ne rade dobro. Morate promijeniti žarulju.', 'Фари погано працюють. Треба поміняти лампочку.', 2);
  perform pg_temp.turn('98a76b5d-2836-5a44-bec6-5cae7a102dc1', '653cdaf4-9e91-52d8-9be5-80145b2f35f8', 'Olena', 'Može li to napraviti servis ovdje?', 'Чи може це зробити сервіс тут?', 3);
  perform pg_temp.turn('380edbaa-de94-500f-bb2e-4c625c1718c6', '653cdaf4-9e91-52d8-9be5-80145b2f35f8', 'Službenik', 'Može. I akumulator je star, a filter je prljav.', 'Може. І акумулятор старий, а фільтр брудний.', 4);
  perform pg_temp.turn('58b5056d-1309-51e5-b7ed-8095e9463e22', '653cdaf4-9e91-52d8-9be5-80145b2f35f8', 'Olena', 'Dobro, mijenjajte sve. Ne smijem voziti bez registracije.', 'Добре, міняйте все. Мені не можна їздити без реєстрації.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 36: Міжміський автобус
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'c1b32b15-8f3c-5f75-bba9-e831d544ec7b';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 9) then
    raise exception 'A1.4: місце уроку 9 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.4.9'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 36: Міжміський автобус', 'Lekcija 36: Međugradski autobus', '["Купити квиток на міжміський автобус", "Дізнатися про відправлення й пересадки", "Знайти своє місце й багаж"]'::jsonb, 12, 'PUBLISHED', 9);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'autobusni kolodvor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'međugradski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polazak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sjedalo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prtljažni prostor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vožnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trajati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'relacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'putnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pojas', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vezati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'presjedanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izravan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'noćni', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '51c253db-b686-5b6e-a595-8ab3c041ca10', 'fill_in_the_blank', 'Je li ovo ___ sjedalo, gospođo?', 'Vaše', '["Vaš", "Vaši", "Vaša", "Vaše"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '638deb5b-7700-507b-bc6a-ce1c2f229c94', 'multiple_choice', 'Що означає «sjedalo»?', 'сидіння; місце', '["сидіння; місце", "маршрут; напрямок (рейсу)", "автовокзал", "відправлення"]'::jsonb, 'A1', 2, 'PUBLISHED', 'sjedalo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6bb97cb1-247c-5b07-ae4b-912b2a48533d', 'multiple_choice', 'Що означає «noćni»?', 'нічний', '["багажне відділення", "міжміський", "нічний", "зав’язувати; пристібати"]'::jsonb, 'A1', 3, 'PUBLISHED', 'noćni', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c3dd8b66-daeb-58e9-ad75-727235255634', 'multiple_choice', 'Як хорватською «зав’язувати; пристібати»?', 'vezati', '["presjedanje", "prtljažni prostor", "vezati", "pojas"]'::jsonb, 'A1', 4, 'PUBLISHED', 'vezati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aac724a9-9276-5b93-a555-0d43cf649afd', 'type_answer', 'Напишіть хорватською: «міжміський»', 'međugradski', null, 'A1', 5, 'PUBLISHED', 'međugradski', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '873fac3a-712e-527b-8db1-89483f136c85', 'type_answer', 'Напишіть хорватською: «пересадка (на транспорті)»', 'presjedanje', null, 'A1', 6, 'PUBLISHED', 'presjedanje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '63bc9d2e-5c3e-5e5a-a6ca-1a9cf22a5044', 'sentence_builder', 'Складіть: «Поїздка триває п’ять годин.»', 'Vožnja traje pet sati.', '["sati.", "Vožnja", "pet", "traje"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '48edac1b-3a0e-5fa4-9dce-a29b16115ef2', 'sentence_builder', 'Складіть: «Пристебніть пасок, будь ласка.»', 'Vežite pojas, molim.', '["pojas,", "Vežite", "molim."]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '628f6e87-de96-5280-9c1b-6b52a91ad9e1', 'listening', 'Прослухайте і складіть фразу', 'Je li to izravna linija?', '["to", "li", "Je", "izravna", "linija?"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e650b531-7655-5b8e-b722-14d97c1827a4', 'listening', 'Прослухайте і складіть фразу', 'Vaša karta, molim.', '["Vaša", "molim.", "karta,"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dbf3e1d5-828c-587c-9273-6a07928b7f47', 'speaking', 'Де міжміські автобуси?', 'Gdje su međugradski autobusi?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4761b08d-7381-5be3-9d89-778e0827fc11', 'speaking', 'Коли відправлення нічного автобуса?', 'Kada je polazak noćnog autobusa?', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('69f565be-ff93-5fa1-8f3b-66dfbccc0a7d', v_lesson, 'На автовокзалі', 'Na autobusnom kolodvoru', 1361, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('c9f0a890-0529-5caf-8274-4c7ea71b3f78', '69f565be-ff93-5fa1-8f3b-66dfbccc0a7d', 'Oksana', 'Jednu kartu za Split, molim. Kada je sljedeći polazak?', 'Один квиток до Спліта, будь ласка. Коли наступне відправлення?', 1);
  perform pg_temp.turn('bd410cf5-82ee-5afe-9381-4b7c2a7a81bd', '69f565be-ff93-5fa1-8f3b-66dfbccc0a7d', 'Blagajnica', 'U deset. Ili noćni autobus u jedanaest navečer.', 'О десятій. Або нічний автобус об одинадцятій вечора.', 2);
  perform pg_temp.turn('4746f187-9646-5b47-ae84-d7663bf82fa5', '69f565be-ff93-5fa1-8f3b-66dfbccc0a7d', 'Oksana', 'Je li to izravna linija?', 'Це прямий рейс?', 3);
  perform pg_temp.turn('dad2ad56-6c67-569b-825c-f2a011a9002a', '69f565be-ff93-5fa1-8f3b-66dfbccc0a7d', 'Blagajnica', 'Da, bez presjedanja. Vožnja traje pet sati.', 'Так, без пересадок. Поїздка триває п’ять годин.', 4);
  perform pg_temp.turn('8ebef077-1dd4-5d55-aa44-f6259f156f18', '69f565be-ff93-5fa1-8f3b-66dfbccc0a7d', 'Oksana', 'Koje je moje sjedalo?', 'Яке моє місце?', 5);
  perform pg_temp.turn('9287644b-e502-5c03-a49c-ca5d5432f8b7', '69f565be-ff93-5fa1-8f3b-66dfbccc0a7d', 'Blagajnica', 'Vaše sjedalo je broj četrnaest.', 'Ваше місце — номер чотирнадцять.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3d61b438-2c87-5998-bdfe-216f41bb84a4', v_lesson, 'В автобусі', 'U autobusu', 1362, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('e3853b95-3ec7-5e61-9a8b-c2ab3b7284e2', '3d61b438-2c87-5998-bdfe-216f41bb84a4', 'Vozač', 'Vaš kofer stavite u prtljažni prostor.', 'Вашу валізу покладіть у багажне відділення.', 1);
  perform pg_temp.turn('87326c46-ec27-5ac2-bc27-c91d205867ab', '3d61b438-2c87-5998-bdfe-216f41bb84a4', 'Andrij', 'Je li ovo autobus na relaciji Zagreb – Zadar?', 'Це автобус за маршрутом Загреб – Задар?', 2);
  perform pg_temp.turn('25ee4d88-203a-5319-9f27-90398edd93b0', '3d61b438-2c87-5998-bdfe-216f41bb84a4', 'Vozač', 'Da. Vaša karta, molim.', 'Так. Ваш квиток, будь ласка.', 3);
  perform pg_temp.turn('9ed8553f-e3be-5d05-9d2b-d986fe464757', '3d61b438-2c87-5998-bdfe-216f41bb84a4', 'Putnica', 'Oprostite, je li ovo Vaše mjesto ili moje?', 'Перепрошую, це ваше місце чи моє?', 4);
  perform pg_temp.turn('568599df-55a0-5f27-9f29-97ac9236f119', '3d61b438-2c87-5998-bdfe-216f41bb84a4', 'Vozač', 'Dragi putnici, vežite pojas. Krećemo!', 'Шановні пасажири, пристебніть паски. Вирушаємо!', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 41: Переїзд
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '23f3aad6-4447-5b75-9dd1-891773457f7e';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.5: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '765ac66f-d54b-505b-9b11-c48e5ad26018';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.5.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 41: Переїзд', 'Lekcija 41: Selidba', '["Спланувати переїзд і запакувати речі", "Домовитися з орендодавцем про ключі й заставу", "Пояснити причину: бо, тому що"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'selidba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'seliti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kutija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nositi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pakirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kombi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iseliti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preuzeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stvar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lomljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'težak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prazan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijevoz', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '50d824cf-6498-542b-a0fd-0573ffaeed67', 'fill_in_the_blank', 'Napiši "lomljivo", ___ su čaše unutra.', 'jer', '["ili", "jer", "ali", "nego"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a7d1fbaf-faf7-5323-bdb4-92589e02fd5d', 'multiple_choice', 'Що означає «selidba»?', 'переїзд', '["переїзд", "носити / одягати", "коробка", "порожній"]'::jsonb, 'A1', 2, 'PUBLISHED', 'selidba', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b7e83d53-a1f8-58d4-8ba7-a682f2e1aa5b', 'multiple_choice', 'Що означає «lomljiv»?', 'крихкий', '["здати, передати", "переїзд", "транспорт; перевезення", "крихкий"]'::jsonb, 'A1', 3, 'PUBLISHED', 'lomljiv', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '295b6837-1154-56a2-bc76-680e9cf423a5', 'multiple_choice', 'Як хорватською «мікроавтобус; бус»?', 'kombi', '["kombi", "predati", "nositi", "iseliti se"]'::jsonb, 'A1', 4, 'PUBLISHED', 'kombi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ecab11af-869f-5c5f-8dea-0b884c7f4f5e', 'type_answer', 'Напишіть хорватською: «переїжджати»', 'seliti se', null, 'A1', 5, 'PUBLISHED', 'seliti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3c1d1c90-1397-56e6-aa85-c5a5d6976e45', 'type_answer', 'Напишіть хорватською: «носити / одягати»', 'nositi', null, 'A1', 6, 'PUBLISHED', 'nositi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f9c50cb4-2114-588b-a86a-f9625c5106c0', 'sentence_builder', 'Складіть: «Ми переїжджаємо в нову квартиру.»', 'Selimo se u novi stan.', '["stan.", "Selimo", "se", "novi", "u"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ff7f0512-7232-59c1-aaf7-f609f633eb37', 'sentence_builder', 'Складіть: «Коробка велика, але не важка.»', 'Kutija je velika, ali nije teška.', '["velika,", "Kutija", "je", "ali", "teška.", "nije"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e19ef069-e7bf-5518-a30b-c2c7f96cffad', 'listening', 'Прослухайте і складіть фразу', 'Ne mogu je nositi.', '["nositi.", "Ne", "mogu", "je"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e3d131d8-f029-5e42-a0ba-df506813b956', 'listening', 'Прослухайте і складіть фразу', 'Dobro. A polog?', '["polog?", "A", "Dobro."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'caaa083a-d20b-5da3-9af0-c45333644829', 'speaking', 'Коли переїзд?', 'Kada je selidba?', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '59c10e15-b060-5c2b-a199-20131de56b60', 'speaking', 'Обережно, це крихке!', 'Pazi, ovo je lomljivo!', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('330c62f0-e29c-55fd-b643-a383c698b85f', v_lesson, 'Пакуємо речі', 'Pakiramo stvari', 1411, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('0fc1fe3c-1c2d-5c74-bbbb-53128c577663', '330c62f0-e29c-55fd-b643-a383c698b85f', 'Olena', 'Selimo se u subotu, a imamo puno stvari!', 'Ми переїжджаємо в суботу, а в нас багато речей!', 1);
  perform pg_temp.turn('2b84728c-0c29-531b-b7e8-0414919f0728', '330c62f0-e29c-55fd-b643-a383c698b85f', 'Taras', 'Ne brini. Danas pakiram knjige, a sutra kuhinju.', 'Не хвилюйся. Сьогодні пакую книжки, а завтра кухню.', 2);
  perform pg_temp.turn('585f4187-729e-5cdb-9253-cb99afc53be6', '330c62f0-e29c-55fd-b643-a383c698b85f', 'Olena', 'Ova kutija je preteška. Ne mogu je nositi.', 'Ця коробка заважка. Не можу її нести.', 3);
  perform pg_temp.turn('57a5a61a-f644-5c72-b716-fd890f81870e', '330c62f0-e29c-55fd-b643-a383c698b85f', 'Taras', 'Onda stavi manje knjiga. Gdje su čaše?', 'Тоді поклади менше книжок. Де склянки?', 4);
  perform pg_temp.turn('e2b1bbd5-b3ac-526c-8307-e53f25543757', '330c62f0-e29c-55fd-b643-a383c698b85f', 'Olena', 'U onoj kutiji. Napiši na nju "lomljivo", jer su čaše unutra.', 'У тій коробці. Напиши на ній «крихке», бо там склянки.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('fd1efb00-01cb-5118-8395-8917399a917c', v_lesson, 'Віддаємо ключі', 'Predajemo ključeve', 1412, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('c11334de-5ebc-5df5-9066-f7b3717e01de', 'fd1efb00-01cb-5118-8395-8917399a917c', 'Stanodavac', 'Kad se iselite, stan mora biti prazan i čist.', 'Коли виїдете, квартира має бути порожня й чиста.', 1);
  perform pg_temp.turn('f8636f72-e70e-528a-b82b-618342f56409', 'fd1efb00-01cb-5118-8395-8917399a917c', 'Taras', 'Naravno. Kombi dolazi u devet, a ključeve predajemo u podne.', 'Звісно. Бус приїжджає о дев’ятій, а ключі віддаємо опівдні.', 2);
  perform pg_temp.turn('d3fa9eec-cfc1-5319-a727-5e540e5c7f65', 'fd1efb00-01cb-5118-8395-8917399a917c', 'Stanodavac', 'Dobro. A polog?', 'Добре. А застава?', 3);
  perform pg_temp.turn('082b869c-3458-592a-9061-6e2a7e456105', 'fd1efb00-01cb-5118-8395-8917399a917c', 'Taras', 'Polog preuzimam kad Vi pregledate stan.', 'Заставу заберу, коли ви оглянете квартиру.', 4);
  perform pg_temp.turn('ebed68df-c2bb-5ee1-9a40-91ec96849e2d', 'fd1efb00-01cb-5118-8395-8917399a917c', 'Stanodavac', 'Može. Kako ide selidba?', 'Добре. Як іде переїзд?', 5);
  perform pg_temp.turn('5b2d8d09-0f3b-50f8-8bf9-ffed4270705b', 'fd1efb00-01cb-5118-8395-8917399a917c', 'Taras', 'Teško, ali prijevoz je jeftin jer prijatelj ima kombi.', 'Важко, але перевезення дешеве, бо в друга є бус.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 42: Правила будинку
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'f296bc84-8059-5981-a5b9-9d4531627e18';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A1.5: місце уроку 6 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b89a9004-2c03-567a-b23e-31db18f92dea';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.5.6'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 42: Правила будинку', 'Lekcija 42: Kućni red', '["Зрозуміти правила будинку", "Запитати, що можна й чого не можна", "Знайти поштову скриньку, підвал і горище"]'::jsonb, 12, 'PUBLISHED', 6);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'kućni red', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upravitelj zgrade', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pričuva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zajednički', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podrum', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tavan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sušiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poštanski sandučić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ulaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zabranjeno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dopušteno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poštovati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pravilo', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'de843045-16c8-5887-a535-74ff930a94ac', 'fill_in_the_blank', 'Pušenje u ulazu ___ dopušteno.', 'nije', '["nisu", "nije", "nema", "ne"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9ee524da-28db-5575-b3f9-36b361f2ba16', 'multiple_choice', 'Що означає «kućni red»?', 'правила будинку', '["правила будинку", "спокій; мир", "сушити", "підвал"]'::jsonb, 'A1', 2, 'PUBLISHED', 'kućni red', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '01c571c8-8fc9-5518-b10b-47e645ad8b82', 'multiple_choice', 'Що означає «dopušteno»?', 'дозволено', '["дозволено", "сушити", "поважати", "вхід; під’їзд"]'::jsonb, 'A1', 3, 'PUBLISHED', 'dopušteno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2115fefa-ea2b-5e73-ad32-e89a3c0bbe76', 'multiple_choice', 'Як хорватською «спільний»?', 'zajednički', '["pravilo", "zabranjeno", "zajednički", "ulaz"]'::jsonb, 'A1', 4, 'PUBLISHED', 'zajednički', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be9ae85c-db69-5db3-b843-f9c631b19cc0', 'type_answer', 'Напишіть хорватською: «сушити»', 'sušiti', null, 'A1', 5, 'PUBLISHED', 'sušiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '51c97218-7dde-5252-9555-1392daf4a372', 'type_answer', 'Напишіть хорватською: «підвал»', 'podrum', null, 'A1', 6, 'PUBLISHED', 'podrum', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2754d96f-bd3f-547d-ae33-a24c92c2cdf4', 'sentence_builder', 'Складіть: «Не залишайте велосипед у коридорі.»', 'Ne ostavljajte bicikl u hodniku.', '["ostavljajte", "hodniku.", "bicikl", "u", "Ne"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '60c669b1-3a6b-5cdb-a7f2-6d01bf951661', 'sentence_builder', 'Складіть: «Старі речі на горищі.»', 'Stare stvari su na tavanu.', '["stvari", "Stare", "tavanu.", "na", "su"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f468b8ac-b76f-5192-a477-30180a9a2a4d', 'listening', 'Прослухайте і складіть фразу', 'Što nije dopušteno?', '["nije", "dopušteno?", "Što"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c0747e93-62bd-5213-984a-22511b11a685', 'listening', 'Прослухайте і складіть фразу', 'Gdje je naš poštanski sandučić?', '["je", "sandučić?", "poštanski", "Gdje", "naš"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a844eec0-6a49-56f0-9093-050f459b5bec', 'speaking', 'Тут заборонено курити.', 'Ovdje je zabranjeno pušiti.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5820bc13-b65f-5636-ac29-4c9fca3477f2', 'speaking', 'Ми поважаємо правила будинку.', 'Poštujemo kućni red.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c83395a0-e16e-5534-8f2a-5dfab41169f2', v_lesson, 'Правила будинку', 'Kućni red', 1421, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('cdc02c55-764b-5bf1-b04f-511ce3bb9ffc', 'c83395a0-e16e-5534-8f2a-5dfab41169f2', 'Upravitelj', 'Dobro došli! Ovo je kućni red zgrade.', 'Ласкаво просимо! Це правила будинку.', 1);
  perform pg_temp.turn('62195802-9f82-56ea-972e-17dc9220451e', 'c83395a0-e16e-5534-8f2a-5dfab41169f2', 'Oksana', 'Što nije dopušteno?', 'Що не дозволено?', 2);
  perform pg_temp.turn('887d6ea8-55b6-541f-9762-9d1e2dde2dee', 'c83395a0-e16e-5534-8f2a-5dfab41169f2', 'Upravitelj', 'Od deset navečer do šest ujutro mora biti mir. Pušenje u ulazu je zabranjeno.', 'З десятої вечора до шостої ранку має бути тиша. Курити в під’їзді заборонено.', 3);
  perform pg_temp.turn('e9d719f3-c736-5e33-b0c7-6b7ec34b329f', 'c83395a0-e16e-5534-8f2a-5dfab41169f2', 'Oksana', 'Smijem li sušiti rublje na balkonu?', 'Чи можна сушити білизну на балконі?', 4);
  perform pg_temp.turn('5097e365-7514-5432-b57c-b50865e289f7', 'c83395a0-e16e-5534-8f2a-5dfab41169f2', 'Upravitelj', 'Ne na balkonu prema ulici. Za to je zajednički prostor na tavanu.', 'Не на балконі з боку вулиці. Для цього є спільне приміщення на горищі.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0fdf6415-9c46-5822-b1d1-b8873c3e7040', v_lesson, 'Сусідка', 'Susjeda', 1422, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('3048007f-d376-5921-8afc-a04fb4d6600f', '0fdf6415-9c46-5822-b1d1-b8873c3e7040', 'Susjeda', 'Vi ste novi? Ja sam Vesna s drugog kata.', 'Ви нові? Я Весна з другого поверху.', 1);
  perform pg_temp.turn('1fe12406-f389-5ac8-bde4-d41f48bcdf76', '0fdf6415-9c46-5822-b1d1-b8873c3e7040', 'Taras', 'Drago mi je. Gdje je naš poštanski sandučić?', 'Приємно познайомитися. Де наша поштова скринька?', 2);
  perform pg_temp.turn('0d1a0fbe-851a-591a-914e-2d23b9d3ec79', '0fdf6415-9c46-5822-b1d1-b8873c3e7040', 'Susjeda', 'Dolje kod ulaza. A bicikl ne ostavljajte u hodniku, nego u podrumu.', 'Внизу біля входу. А велосипед не залишайте в коридорі, а в підвалі.', 3);
  perform pg_temp.turn('8f762304-f3d6-597f-beff-834a73658699', '0fdf6415-9c46-5822-b1d1-b8873c3e7040', 'Taras', 'Hvala. Plaćamo li pričuvu upravitelju zgrade?', 'Дякую. Внесок на будинок платимо управителю?', 4);
  perform pg_temp.turn('ce457af9-491c-57a9-80e8-343b039de44c', '0fdf6415-9c46-5822-b1d1-b8873c3e7040', 'Susjeda', 'Ne, plaćate je uplatnicom. Svi ovdje poštuju pravila.', 'Ні, платите за квитанцією. Тут усі дотримуються правил.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 43: Опалення й холод
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '62b118f9-a5e0-587b-82f8-39de181ddeba';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A1.5: місце уроку 7 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '318b394b-c622-5dd6-8494-4c1472b6df62';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.5.7'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 43: Опалення й холод', 'Lekcija 43: Grijanje i hladnoća', '["Поговорити про опалення й холод", "Пояснити орендодавцеві проблему з вологою", "Економити тепло, газ і електрику"]'::jsonb, 12, 'PUBLISHED', 7);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'radijator', v_pos);
  v_pos := pg_temp.word(v_lesson, 'klima', v_pos);
  v_pos := pg_temp.word(v_lesson, 'peć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'drva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prozračiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vlaga', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plijesan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'štedjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hladnoća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'termostat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stupanj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smrznuti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potrošnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brojilo', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '4852c94d-1245-5419-9910-d83b79cb3a86', 'fill_in_the_blank', 'Mi zimi ___ stan svako jutro.', 'prozračujemo', '["prozračujemo", "prozračuješ", "prozračuju", "prozračujem"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1a9567f9-5d6e-5bb0-93f5-aa979ebb8d53', 'multiple_choice', 'Що означає «plijesan»?', 'пліснява', '["термостат", "споживання; витрати", "ступінь, градус", "пліснява"]'::jsonb, 'A1', 2, 'PUBLISHED', 'plijesan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bc4f09de-9f71-58ca-ad29-0db2ebac8728', 'multiple_choice', 'Що означає «termostat»?', 'термостат', '["радіатор; батарея (опалення)", "пліснява", "лічильник", "термостат"]'::jsonb, 'A1', 3, 'PUBLISHED', 'termostat', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '13c38b06-0d5e-5498-afda-816621d1fa55', 'multiple_choice', 'Як хорватською «вологість; сирість»?', 'vlaga', '["peć", "klima", "potrošnja", "vlaga"]'::jsonb, 'A1', 4, 'PUBLISHED', 'vlaga', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '05381ea6-140b-5878-b5ac-bd9222ebb70a', 'type_answer', 'Напишіть хорватською: «дрова»', 'drva', null, 'A1', 5, 'PUBLISHED', 'drva', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '98781243-de96-5e73-9924-97b89dc46cd7', 'type_answer', 'Напишіть хорватською: «піч; обігрівач»', 'peć', null, 'A1', 6, 'PUBLISHED', 'peć', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '58662489-548a-51db-9fd0-e2497b1f9115', 'sentence_builder', 'Складіть: «Провітри кімнату десять хвилин.»', 'Prozrači sobu deset minuta.', '["Prozrači", "sobu", "minuta.", "deset"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'df123f87-f325-594c-b00b-2ce34baf6529', 'sentence_builder', 'Складіть: «Лічильник у підвалі.»', 'Brojilo je u podrumu.', '["je", "podrumu.", "u", "Brojilo"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0f46cf0e-f289-5811-91d0-0b5c45be1219', 'listening', 'Прослухайте і складіть фразу', 'A klima? Grije li i ona?', '["Grije", "i", "ona?", "li", "A", "klima?"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f763cd9a-f6cd-5d54-ac48-7174537e5c68', 'listening', 'Прослухайте і складіть фразу', 'Rijetko, zbog hladnoće.', '["hladnoće.", "Rijetko,", "zbog"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e95da0b7-c15c-530c-9bd8-a3b35c8e125a', 'speaking', 'Без шапки я швидко замерзну.', 'Bez kape se brzo smrznem.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd04555d6-0567-5c03-ae02-327fdd1e0557', 'speaking', 'Нам треба економити газ.', 'Moramo štedjeti plin.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ded61081-905d-5db5-9a3a-d8007b6a8971', v_lesson, 'Холодно в квартирі', 'Hladno je u stanu', 1431, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('92d45033-ca50-57e6-8ac9-32f96539fa09', 'ded61081-905d-5db5-9a3a-d8007b6a8971', 'Olena', 'Radijatori su hladni! Smrzavam se.', 'Батареї холодні! Я мерзну.', 1);
  perform pg_temp.turn('c7f07051-4c5a-5768-ac07-18d49ea49648', 'ded61081-905d-5db5-9a3a-d8007b6a8971', 'Taras', 'Termostat je na osamnaest stupnjeva. Stavljam dvadeset dva.', 'Термостат на вісімнадцяти градусах. Ставлю двадцять два.', 2);
  perform pg_temp.turn('3ea876ee-ea04-55b7-a16f-d315d1272373', 'ded61081-905d-5db5-9a3a-d8007b6a8971', 'Olena', 'A klima? Grije li i ona?', 'А кондиціонер? Він теж гріє?', 3);
  perform pg_temp.turn('84b0b7a8-91a1-50a3-8924-721e992f1d11', 'ded61081-905d-5db5-9a3a-d8007b6a8971', 'Taras', 'Grije, ali potrošnja struje je velika. Moramo štedjeti.', 'Гріє, але споживання електрики велике. Мусимо економити.', 4);
  perform pg_temp.turn('7e4cf18c-5835-5774-850d-b393505e56ca', 'ded61081-905d-5db5-9a3a-d8007b6a8971', 'Olena', 'Dobro, onda pijem čaj i nosim džemper.', 'Добре, тоді п’ю чай і вдягаю светр.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d179cc8c-9cd1-5c47-993a-4fe43a89f720', v_lesson, 'Пліснява у ванній', 'Plijesan u kupaonici', 1432, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('c6952068-14c1-5c39-b912-753db1083b2d', 'd179cc8c-9cd1-5c47-993a-4fe43a89f720', 'Oksana', 'Na zidu u kupaonici je plijesan.', 'На стіні у ванній пліснява.', 1);
  perform pg_temp.turn('1af664b6-503c-5a7d-9505-c3dfa4b5074a', 'd179cc8c-9cd1-5c47-993a-4fe43a89f720', 'Stanodavac', 'To je od vlage. Prozračujete li stan?', 'Це від вологи. Ви провітрюєте квартиру?', 2);
  perform pg_temp.turn('e847675c-0317-5923-81f7-a4a8f83d1e50', 'd179cc8c-9cd1-5c47-993a-4fe43a89f720', 'Oksana', 'Rijetko, zbog hladnoće.', 'Рідко, через холод.', 3);
  perform pg_temp.turn('2a7f30d9-bcdd-5554-95dc-52f73c12afa5', 'd179cc8c-9cd1-5c47-993a-4fe43a89f720', 'Stanodavac', 'Prozračujte svako jutro deset minuta. I pošaljite mi stanje brojila za plin.', 'Провітрюйте щоранку десять хвилин. І надішліть мені показники лічильника газу.', 4);
  perform pg_temp.turn('9da93c56-99ca-570e-9d33-5a64d1ce364e', 'd179cc8c-9cd1-5c47-993a-4fe43a89f720', 'Oksana', 'Dobro. Kod moje bake na selu grije peć na drva i nema vlage.', 'Добре. У моєї бабусі в селі гріє піч на дровах, і вологи немає.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 44: Дрібний ремонт
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'dd2c0f3c-19f2-5c73-b448-a0631cd97e69';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 8) then
    raise exception 'A1.5: місце уроку 8 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.5.8'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 44: Дрібний ремонт', 'Lekcija 44: Mali popravci', '["Попросити інструмент і допомогу", "Пояснити майстрові, що зламалося", "Назвати частини кімнати: стіна, стеля"]'::jsonb, 12, 'PUBLISHED', 8);
  -- слова
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zid', v_pos);
  v_pos := pg_temp.word(v_lesson, 'strop', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brtva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pločica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čavao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čekić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bušilica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odvijač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'alat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ličiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'objesiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slavina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kapati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žarulja', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b05587c5-f5ef-57ea-9648-867a6bd29e04', 'fill_in_the_blank', '___ sliku na zid, molim te.', 'Objesi', '["Objesio", "Objesim", "Objesiti", "Objesi"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3dbfb950-6b28-596d-a280-d8bed72e67eb', 'multiple_choice', 'Що означає «ličiti»?', 'фарбувати (стіни)', '["фарбувати (стіни)", "стеля", "інструмент", "повісити"]'::jsonb, 'A1', 2, 'PUBLISHED', 'ličiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '19d3fc68-e816-5aac-94fb-a1fb940e8f78', 'multiple_choice', 'Що означає «strop»?', 'стеля', '["стеля", "фарбувати (стіни)", "інструмент", "цвях"]'::jsonb, 'A1', 3, 'PUBLISHED', 'strop', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '114b2194-105e-54dd-b72c-03646ace8de8', 'multiple_choice', 'Як хорватською «стіна»?', 'zid', '["pločica", "zid", "objesiti", "brtva"]'::jsonb, 'A1', 4, 'PUBLISHED', 'zid', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '86e9893b-badd-5c67-b204-5a556dd0ff6a', 'type_answer', 'Напишіть хорватською: «кран (водопровідний)»', 'slavina', null, 'A1', 5, 'PUBLISHED', 'slavina', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '99b0ef0f-3a26-5197-adbd-34fb1f07ece5', 'type_answer', 'Напишіть хорватською: «капати»', 'kapati', null, 'A1', 6, 'PUBLISHED', 'kapati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9c8bab0b-5da0-524a-a6d8-2f9d883af617', 'sentence_builder', 'Складіть: «Дай мені молоток і цвях.»', 'Daj mi čekić i čavao.', '["Daj", "čavao.", "mi", "čekić", "i"]'::jsonb, 'A1', 7, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5bc2eb0e-40a8-57e0-979c-60681dea199b', 'sentence_builder', 'Складіть: «Поміняй лампочку в коридорі.»', 'Promijeni žarulju u hodniku.', '["hodniku.", "žarulju", "u", "Promijeni"]'::jsonb, 'A1', 8, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ff336b18-8fdc-5e5e-8e6e-e892929cacbc', 'listening', 'Прослухайте і складіть фразу', 'Gdje je bušilica?', '["bušilica?", "Gdje", "je"]'::jsonb, 'A1', 9, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c70b50fd-47aa-5cb1-9d41-1d2b73c687fd', 'listening', 'Прослухайте і складіть фразу', 'I jedna pločica na podu je razbijena.', '["jedna", "I", "podu", "na", "je", "pločica", "razbijena."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1bfda0ef-25d0-5f69-98fd-742fa409b737', 'speaking', 'Цими вихідними ми фарбуємо вітальню.', 'Ovaj vikend ličimo dnevni boravak.', null, 'A1', 11, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1bac69d1-f682-5caf-af92-9d5e323deba8', 'speaking', 'Кран на кухні капає.', 'Slavina u kuhinji kaplje.', null, 'A1', 12, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('eaffc4b6-1211-56d2-8293-641002348d2a', v_lesson, 'Вішаємо полицю', 'Vješamo policu', 1441, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('57aefd3a-2bfb-5761-b862-ecc2f6432ab5', 'eaffc4b6-1211-56d2-8293-641002348d2a', 'Taras', 'Gdje je bušilica? Želim objesiti policu.', 'Де дриль? Хочу повісити полицю.', 1);
  perform pg_temp.turn('99ca49c6-a9e8-5224-ace4-2ef4f2dae17f', 'eaffc4b6-1211-56d2-8293-641002348d2a', 'Olena', 'U kutiji s alatom, pored čekića.', 'У ящику з інструментами, біля молотка.', 2);
  perform pg_temp.turn('e52fe0fb-adae-5314-89ea-c74e11081674', 'eaffc4b6-1211-56d2-8293-641002348d2a', 'Taras', 'Zid je tvrd. Daj mi i odvijač, molim te.', 'Стіна тверда. Дай мені ще викрутку, будь ласка.', 3);
  perform pg_temp.turn('3af921cd-c135-522d-8741-7d32b9216790', 'eaffc4b6-1211-56d2-8293-641002348d2a', 'Olena', 'Evo. Pazi, ne buši blizu utičnice!', 'Ось. Обережно, не свердли біля розетки!', 4);
  perform pg_temp.turn('dd546cbc-6f49-549d-99a6-1ecf90f747f9', 'eaffc4b6-1211-56d2-8293-641002348d2a', 'Taras', 'Znam. A sliku vješam na čavao.', 'Знаю. А картину вішаю на цвях.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0c568f05-c0e9-5a93-979c-cbd53f0abdc5', v_lesson, 'Кран капає', 'Slavina kaplje', 1442, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v2') on conflict (id) do nothing;
  perform pg_temp.turn('5f9e3db0-b833-5b1b-861d-d016b11f89ae', '0c568f05-c0e9-5a93-979c-cbd53f0abdc5', 'Oksana', 'Majstore, slavina u kupaonici stalno kaplje.', 'Майстре, кран у ванній постійно капає.', 1);
  perform pg_temp.turn('944b5ed0-348d-53b2-af22-af2863bd18b0', '0c568f05-c0e9-5a93-979c-cbd53f0abdc5', 'Majstor', 'Pokažite mi. Aha, treba nova brtva.', 'Покажіть. Ага, потрібна нова прокладка.', 2);
  perform pg_temp.turn('c13646cf-d579-568c-a99c-a36b38a85a9f', '0c568f05-c0e9-5a93-979c-cbd53f0abdc5', 'Oksana', 'I jedna pločica na podu je razbijena.', 'І одна плитка на підлозі розбита.', 3);
  perform pg_temp.turn('fca36c86-bc74-56a1-a4b9-268fa5a0f9d7', '0c568f05-c0e9-5a93-979c-cbd53f0abdc5', 'Majstor', 'Nema problema. Imate li još pločica?', 'Без проблем. У вас є ще плитки?', 4);
  perform pg_temp.turn('abe34ca1-5699-5cfa-8153-a09cee2e6d76', '0c568f05-c0e9-5a93-979c-cbd53f0abdc5', 'Oksana', 'Imam. I promijenite, molim Vas, žarulju na stropu.', 'Є. І поміняйте, будь ласка, лампочку на стелі.', 5);
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

-- 5. Самоперевірка частини 2: якщо щось не так — уся частина відкочується
do $$
declare v_new int; v_short int; v_scenes int; v_words int; v_total int; v_bad_titles int;
begin
  select count(*) into v_new from public.lessons where id in ('31bbedca-4b51-5478-8513-df5cb996ffd9', '91d4c9b3-c9a8-5e94-8691-6683835c375b', '0b04119b-4d38-5d99-8237-caa95fdcfd95', '06f927cf-f38c-51b5-a1f9-696698ad23fb', 'cd5db261-a421-511d-8100-f86bf2335bbe', 'c1b32b15-8f3c-5f75-bba9-e831d544ec7b', '23f3aad6-4447-5b75-9dd1-891773457f7e', 'f296bc84-8059-5981-a5b9-9d4531627e18', '62b118f9-a5e0-587b-82f8-39de181ddeba', 'dd2c0f3c-19f2-5c73-b448-a0631cd97e69') and status = 'PUBLISHED';
  select count(*) into v_short from public.lessons l where l.id in ('31bbedca-4b51-5478-8513-df5cb996ffd9', '91d4c9b3-c9a8-5e94-8691-6683835c375b', '0b04119b-4d38-5d99-8237-caa95fdcfd95', '06f927cf-f38c-51b5-a1f9-696698ad23fb', 'cd5db261-a421-511d-8100-f86bf2335bbe', 'c1b32b15-8f3c-5f75-bba9-e831d544ec7b', '23f3aad6-4447-5b75-9dd1-891773457f7e', 'f296bc84-8059-5981-a5b9-9d4531627e18', '62b118f9-a5e0-587b-82f8-39de181ddeba', 'dd2c0f3c-19f2-5c73-b448-a0631cd97e69')
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') < 12;
  select count(*) into v_scenes from public.lessons l where l.id in ('31bbedca-4b51-5478-8513-df5cb996ffd9', '91d4c9b3-c9a8-5e94-8691-6683835c375b', '0b04119b-4d38-5d99-8237-caa95fdcfd95', '06f927cf-f38c-51b5-a1f9-696698ad23fb', 'cd5db261-a421-511d-8100-f86bf2335bbe', 'c1b32b15-8f3c-5f75-bba9-e831d544ec7b', '23f3aad6-4447-5b75-9dd1-891773457f7e', 'f296bc84-8059-5981-a5b9-9d4531627e18', '62b118f9-a5e0-587b-82f8-39de181ddeba', 'dd2c0f3c-19f2-5c73-b448-a0631cd97e69')
     and (select count(*) from public.conversations c where c.lesson_id = l.id) < 2;
  select count(*) into v_words from public.lessons l where l.id in ('31bbedca-4b51-5478-8513-df5cb996ffd9', '91d4c9b3-c9a8-5e94-8691-6683835c375b', '0b04119b-4d38-5d99-8237-caa95fdcfd95', '06f927cf-f38c-51b5-a1f9-696698ad23fb', 'cd5db261-a421-511d-8100-f86bf2335bbe', 'c1b32b15-8f3c-5f75-bba9-e831d544ec7b', '23f3aad6-4447-5b75-9dd1-891773457f7e', 'f296bc84-8059-5981-a5b9-9d4531627e18', '62b118f9-a5e0-587b-82f8-39de181ddeba', 'dd2c0f3c-19f2-5c73-b448-a0631cd97e69')
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'lexeme') < 12;
  select count(*) into v_total from public.lessons where level_code = 'A1' and status = 'PUBLISHED';
  select count(*) into v_bad_titles from (
    select l.title_ua, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where m.level_code = 'A1' and l.status <> 'DEPRECATED') t
   where t.title_ua not like 'Урок ' || t.n || ':%';
  if v_new <> 10 then raise exception 'Частина 2: створено % уроків з 10', v_new; end if;
  if v_short > 0 then raise exception 'Частина 2: % уроків мають менше 12 вправ', v_short; end if;
  if v_scenes > 0 then raise exception 'Частина 2: % уроків без двох діалогів', v_scenes; end if;
  if v_words > 0 then raise exception 'Частина 2: % уроків мають менше 12 слів', v_words; end if;
  if v_bad_titles > 0 then raise exception 'Частина 2: % назв уроків A1 не за порядком', v_bad_titles; end if;
  raise notice 'Готово: частина 2 — 10 нових уроків; усього уроків A1 — %', v_total;
end $$;

commit;
