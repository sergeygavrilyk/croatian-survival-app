-- =====================================================================
-- Доповнення програми A0 · curriculum_a0_v3 · 2026-10-13
-- Згенеровано: python3 scripts/gen_curriculum_a0_v3.py (не редагуйте вручну).
--
--   * +17 уроків (місця 4–5 у модулях, де тема була неповна) → разом 47 уроків A0.
--     Кожен: 10–12 слів, 2 діалоги (149 реплік разом), граматика, 12 вправ, ~12 хв.
--   * Нова тема граматики «Порядок слів» (§21 ТЗ).
--   * Нові слова: 49. Виправлення словника: 4 переклади + 3 написання леми.
--   * Назви всіх уроків A0 перенумеровано підряд («Урок N»); старі назви — у content_versions.
--   * Статус PUBLISHED: бета, як решта A0. Носій ще не перевіряв.
--   * Наявні дані не видаляються. Повторний запуск безпечний.
--   * Потрібні M13 і curriculum_a0_v2.
-- =====================================================================

begin;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'exercises_type_check'
                 and pg_get_constraintdef(oid) like '%speaking%') then
    raise exception 'Спершу запустіть міграцію M13 (20261013140000_m13_exercise_types.sql)';
  end if;
  if (select count(*) from public.lessons where level_code = 'A0' and status = 'PUBLISHED') < 30 then
    raise exception 'Немає 30 уроків A0 — спершу curriculum_a0_v1';
  end if;
  if not exists (select 1 from public.conversations where source = 'claude_curriculum_v2') then
    raise exception 'Спершу запустіть 20261013_curriculum_a0_v2.sql';
  end if;
end $$;

-- 1. Нові слова A0 (яких ще немає у словнику)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('do sutra', 'do sutra', 'hr', 'phrase', 'A0', 'до завтра', 'formulaic', '{}'::jsonb, '["Hvala na svemu, do sutra!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ugodna večer', 'ugodna vecer', 'hr', 'phrase', 'A0', 'гарного вечора', 'formulaic', '{}'::jsonb, '["Laku noć i ugodna večer!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sretno', 'sretno', 'hr', 'interjection', 'A0', 'успіхів; щасти', 'formulaic', '{}'::jsonb, '["Sutra imaš ispit? Sretno!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('čestitam', 'cestitam', 'hr', 'phrase', 'A0', 'вітаю (з чимось)', 'formulaic', '{}'::jsonb, '["Čestitam na rođendanu!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('i tebi', 'i tebi', 'hr', 'phrase', 'A0', 'і тобі (теж)', 'formulaic', '{}'::jsonb, '["Ugodan dan! — Hvala, i tebi!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kvart', 'kvart', 'hr', 'noun', 'A0', 'район (міста)', 'core', '{"gender": "m"}'::jsonb, '["Naš kvart ima lijep park."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kućni broj', 'kucni broj', 'hr', 'phrase', 'A0', 'номер будинку', 'collocation', '{}'::jsonb, '["Napišite ulicu i kućni broj."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('poštanski broj', 'postanski broj', 'hr', 'phrase', 'A0', 'поштовий індекс', 'collocation', '{}'::jsonb, '["Poštanski broj Splita je 21000."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Ukrajinka', 'ukrajinka', 'hr', 'noun', 'A0', 'українка', 'core', '{"gender": "f"}'::jsonb, '["Moja susjeda je Ukrajinka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Hrvatica', 'hrvatica', 'hr', 'noun', 'A0', 'хорватка', 'core', '{"gender": "f"}'::jsonb, '["Ana je Hrvatica iz Zadra."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ukrajinski', 'ukrajinski', 'hr', 'adjective', 'A0', 'українська (мова); український', 'core', '{}'::jsonb, '["Djeca doma govore ukrajinski."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('njemački', 'njemacki', 'hr', 'adjective', 'A0', 'німецька (мова); німецький', 'core', '{}'::jsonb, '["Moj brat govori njemački."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('poljski', 'poljski', 'hr', 'adjective', 'A0', 'польська (мова); польський', 'core', '{}'::jsonb, '["Razumijem malo poljski."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('talijanski', 'talijanski', 'hr', 'adjective', 'A0', 'італійська (мова); італійський', 'core', '{}'::jsonb, '["U Istri mnogi govore talijanski."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('profesorica', 'profesorica', 'hr', 'noun', 'A0', 'викладачка; вчителька', 'core', '{"gender": "f"}'::jsonb, '["Profesorica govori polako."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('broj telefona', 'broj telefona', 'hr', 'phrase', 'A0', 'номер телефону', 'collocation', '{}'::jsonb, '["Napišite ovdje svoj broj telefona."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prijepodne', 'prijepodne', 'hr', 'adverb', 'A0', 'до обіду; першу половину дня', 'core', '{}'::jsonb, '["Prijepodne radim, a poslijepodne učim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('podne', 'podne', 'hr', 'noun', 'A0', 'полудень', 'core', '{"gender": "n"}'::jsonb, '["Ručak je u podne."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('poslijepodne', 'poslijepodne', 'hr', 'adverb', 'A0', 'після обіду; пополудні', 'core', '{}'::jsonb, '["Poslijepodne idemo u park."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ponoć', 'ponoc', 'hr', 'noun', 'A0', 'північ (час)', 'core', '{"gender": "f"}'::jsonb, '["Kafić radi do ponoći."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('praznici', 'praznici', 'hr', 'noun', 'A0', 'канікули; свята', 'core', '{"gender": "m"}'::jsonb, '["Djeca su na praznicima."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('teta', 'teta', 'hr', 'noun', 'A0', 'тітка', 'core', '{"gender": "f"}'::jsonb, '["Moja teta živi u Zagrebu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ujak', 'ujak', 'hr', 'noun', 'A0', 'дядько (брат матері)', 'core', '{"gender": "m"}'::jsonb, '["Ujak ima veliku kuću na moru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bratić', 'bratic', 'hr', 'noun', 'A0', 'двоюрідний брат', 'core', '{"gender": "m"}'::jsonb, '["Moj bratić ima deset godina."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sestrična', 'sestricna', 'hr', 'noun', 'A0', 'двоюрідна сестра', 'core', '{"gender": "f"}'::jsonb, '["Sestrična dolazi k nama u petak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('oženjen', 'ozenjen', 'hr', 'adjective', 'A0', 'одружений (про чоловіка)', 'core', '{}'::jsonb, '["Moj brat je oženjen."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('udana', 'udana', 'hr', 'adjective', 'A0', 'заміжня', 'core', '{}'::jsonb, '["Moja sestra je udana i ima sina."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('spavaća soba', 'spavaca soba', 'hr', 'phrase', 'A0', 'спальня', 'collocation', '{}'::jsonb, '["Spavaća soba je mala, ali mirna."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('limunada', 'limunada', 'hr', 'noun', 'A0', 'лимонад', 'core', '{"gender": "f"}'::jsonb, '["Ljeti pijem hladnu limunadu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('riža', 'riza', 'hr', 'noun', 'A0', 'рис', 'core', '{"gender": "f"}'::jsonb, '["Kupi kilu riže, molim te."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pomfrit', 'pomfrit', 'hr', 'noun', 'A0', 'картопля фрі', 'core', '{"gender": "m"}'::jsonb, '["Djeca vole pomfrit."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('umak', 'umak', 'hr', 'noun', 'A0', 'соус', 'core', '{"gender": "m"}'::jsonb, '["Tjestenina s umakom od rajčice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('slan', 'slan', 'hr', 'adjective', 'A0', 'солоний', 'core', '{}'::jsonb, '["Sir je malo previše slan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('deka', 'deka', 'hr', 'noun', 'A0', 'десять грамів (у кількостях: deset deka = 100 г)', 'core', '{"gender": "f"}'::jsonb, '["Dvadeset deka sira, molim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kila', 'kila', 'hr', 'noun', 'A0', 'кілограм (розм.)', 'core', '{"gender": "f"}'::jsonb, '["Kila jabuka košta dva eura."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('litra', 'litra', 'hr', 'noun', 'A0', 'літр', 'core', '{"gender": "f"}'::jsonb, '["Trebam litru mlijeka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('šunka', 'sunka', 'hr', 'noun', 'A0', 'шинка', 'core', '{"gender": "f"}'::jsonb, '["Za doručak jedem kruh i šunku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dosta', 'dosta', 'hr', 'adverb', 'A0', 'досить; достатньо', 'core', '{}'::jsonb, '["Imamo dosta vremena."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('popis', 'popis', 'hr', 'noun', 'A0', 'список', 'core', '{"gender": "m"}'::jsonb, '["Napiši popis za trgovinu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ružičast', 'ruzicast', 'hr', 'adjective', 'A0', 'рожевий', 'core', '{}'::jsonb, '["Kći voli ružičastu haljinu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('narančast', 'narancast', 'hr', 'adjective', 'A0', 'помаранчевий', 'core', '{}'::jsonb, '["Autobus je narančast."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ljubičast', 'ljubicast', 'hr', 'adjective', 'A0', 'фіолетовий', 'core', '{}'::jsonb, '["Imam ljubičastu torbu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('omiljen', 'omiljen', 'hr', 'adjective', 'A0', 'улюблений', 'core', '{}'::jsonb, '["Ovo je moj omiljeni kafić."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ugao', 'ugao', 'hr', 'noun', 'A0', 'ріг (вулиці); кут', 'core', '{"gender": "m"}'::jsonb, '["Pekara je iza ugla."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('skrenuti', 'skrenuti', 'hr', 'verb', 'A0', 'повернути (ліворуч, праворуч)', 'core', '{"aspect": "pfv"}'::jsonb, '["Na semaforu skrenite lijevo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prijeći', 'prijeci', 'hr', 'verb', 'A0', 'перейти', 'core', '{"aspect": "pfv"}'::jsonb, '["Prijeđite cestu na zebri."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pješački prijelaz', 'pjesacki prijelaz', 'hr', 'phrase', 'A0', 'пішохідний перехід', 'collocation', '{}'::jsonb, '["Pješački prijelaz je kod škole."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gužva', 'guzva', 'hr', 'noun', 'A0', 'затор; тиснява', 'core', '{"gender": "f"}'::jsonb, '["Ujutro je u gradu velika gužva."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kožni', 'kozni', 'hr', 'adjective', 'A0', 'шкіряний', 'core', '{}'::jsonb, '["Imam crnu kožnu jaknu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a0_v3')
on conflict do nothing;

-- 2. Виправлення словника (стара версія — у content_versions)
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('evo') and ukrainian_translation = 'тут';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a0_v3: переклад «тут» → «ось; ось тут»');
  update public.lexemes set ukrainian_translation = 'ось; ось тут' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a0_v3: переклад «тут» → «ось; ось тут»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('kuća') and ukrainian_translation = 'дім';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a0_v3: переклад «дім» → «будинок; дім»');
  update public.lexemes set ukrainian_translation = 'будинок; дім' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a0_v3: переклад «дім» → «будинок; дім»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('drag') and ukrainian_translation = 'дорогий';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a0_v3: переклад «дорогий» → «дорогий; милий, приємний»');
  update public.lexemes set ukrainian_translation = 'дорогий; милий, приємний' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a0_v3: переклад «дорогий» → «дорогий; милий, приємний»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lower(lemma) = lower('tek') and ukrainian_translation = 'тільки-но, щойно';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a0_v3: переклад «тільки-но, щойно» → «лише; тільки-но, щойно»');
  update public.lexemes set ukrainian_translation = 'лише; тільки-но, щойно' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a0_v3: переклад «тільки-но, щойно» → «лише; тільки-но, щойно»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lemma = 'mUP';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a0_v3: лема «mUP» → «MUP»');
  update public.lexemes set lemma = 'MUP' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a0_v3: лема «mUP» → «MUP»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lemma = 'hrvat';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a0_v3: лема «hrvat» → «Hrvat»');
  update public.lexemes set lemma = 'Hrvat' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a0_v3: лема «hrvat» → «Hrvat»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lemma = 'ukrajinac';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a0_v3: лема «ukrajinac» → «Ukrajinac»');
  update public.lexemes set lemma = 'Ukrajinac' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a0_v3: лема «ukrajinac» → «Ukrajinac»');
end $$;

-- 3. Нова тема граматики A0
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '7c11e829-8de6-56a8-b260-519efad8481d', 'A0', 'Порядок слів', 'Red riječi', 'Як будувати речення: звичайний порядок, короткі слова на другому місці, питання.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Порядок слів');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '395483bb-e438-5538-b0f4-24c1162afe5e', '7c11e829-8de6-56a8-b260-519efad8481d', 'Звичайний порядок', 'Як і в українській: хто — що робить — що. Порядок вільний, але найважливіше зазвичай у кінці речення.', 'Ja pijem kavu.', '[{"hr": "Ja pijem kavu.", "ua": "Я п’ю каву."}, {"hr": "Ana radi u banci.", "ua": "Ана працює в банку."}, {"hr": "Kavu pijem ujutro.", "ua": "Каву я п’ю зранку."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '7c11e829-8de6-56a8-b260-519efad8481d')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'f31b4d8c-1c30-5da4-97d2-ea15166d9ff1', '7c11e829-8de6-56a8-b260-519efad8481d', 'Короткі слова — на другому місці', 'Короткі слова sam, si, je, se, me, li стоять на другому місці в реченні, а не на початку: Zovem se Ana. Umoran sam.', 'Zovem se… · Gdje je…?', '[{"hr": "Zovem se Ana.", "ua": "Мене звати Ана."}, {"hr": "Umoran sam.", "ua": "Я втомлений."}, {"hr": "Gdje je stanica?", "ua": "Де зупинка?"}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '7c11e829-8de6-56a8-b260-519efad8481d')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '1ba2931d-8ef1-5c5e-b409-8391070c1fa3', '7c11e829-8de6-56a8-b260-519efad8481d', 'Питання', 'Питання «так / ні»: дієслово + li на початку (Imate li…? Govorite li…?) або Je li…? Питальне слово стоїть першим: Gdje…? Kada…?', 'Imate li…? · Je li…?', '[{"hr": "Imate li vodu?", "ua": "У вас є вода?"}, {"hr": "Je li to daleko?", "ua": "Це далеко?"}, {"hr": "Kada polazi vlak?", "ua": "Коли відправляється поїзд?"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '7c11e829-8de6-56a8-b260-519efad8481d')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '7c11e829-8de6-56a8-b260-519efad8481d', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '7c11e829-8de6-56a8-b260-519efad8481d')
  and not exists (select 1 from public.content_reviews where entity_id = '7c11e829-8de6-56a8-b260-519efad8481d' and notes = 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');

-- 4. Нові уроки A0
-- A0.1 · урок 4: Прощання і ввічливість
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'e704760a-f743-5762-9c1a-027b10ca030a';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A0.1: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Ввічливість: ti і Vi' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.1.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 4: Прощання і ввічливість', 'Lekcija 4: Pozdravi i pristojnost', '["Попрощатися з колегою чи сусідом", "Перепросити й відповісти на вибачення", "Привітати й побажати успіху"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('vidimo se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vidimo se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('do sutra') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'do sutra'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ugodna večer') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ugodna večer'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pozdraviti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pozdraviti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sretno') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sretno'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ispričavam se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ispričavam se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('nema problema') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'nema problema'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('čestitam') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'čestitam'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('i tebi') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'i tebi'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kasniti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kasniti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('928be8b1-8a1e-54e7-a553-97289316c959', 'fill_in_the_blank', 'Hvala ___, gospođo Horvat!', 'Vam', '["ti", "Vam", "tebe", "Vas"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '928be8b1-8a1e-54e7-a553-97289316c959', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('nema problema') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('32407494-4c68-50eb-bb3a-2d547d6fbae4', 'multiple_choice', 'Що означає «nema problema»?', 'немає проблем', '["гарного вечора", "запізнюватися", "немає проблем", "успіхів; щасти"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '32407494-4c68-50eb-bb3a-2d547d6fbae4', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('čestitam') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e1ba7373-bbef-5a24-88cb-ebe13988ca5b', 'multiple_choice', 'Що означає «čestitam»?', 'вітаю (з чимось)', '["вітаю (з чимось)", "до завтра", "і тобі (теж)", "успіхів; щасти"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e1ba7373-bbef-5a24-88cb-ebe13988ca5b', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vidimo se') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('096f9492-f74d-5191-8eca-df91b0d8e7d4', 'multiple_choice', 'Як хорватською «побачимося»?', 'vidimo se', '["do sutra", "sretno", "čestitam", "vidimo se"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '096f9492-f74d-5191-8eca-df91b0d8e7d4', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sretno') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f3b53347-406b-5fef-b444-ee584e2ffb03', 'type_answer', 'Напишіть хорватською: «успіхів; щасти»', 'sretno', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f3b53347-406b-5fef-b444-ee584e2ffb03', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('kasniti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('cafcde79-f4e3-5f41-b63f-466f0ad578aa', 'type_answer', 'Напишіть хорватською: «запізнюватися»', 'kasniti', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'cafcde79-f4e3-5f41-b63f-466f0ad578aa', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('29bf0ce8-e3ed-5eec-9715-90fe59c023f0', 'sentence_builder', 'Складіть: «Побачимося завтра!»', 'Vidimo se sutra!', '["se", "sutra!", "Vidimo"]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '29bf0ce8-e3ed-5eec-9715-90fe59c023f0', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('55c19a34-bc23-52e1-b89b-bc56ff8708bb', 'sentence_builder', 'Складіть: «Перепрошую, я запізнююся.»', 'Ispričavam se, kasnim.', '["kasnim.", "Ispričavam", "se,"]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '55c19a34-bc23-52e1-b89b-bc56ff8708bb', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f90cd3f6-2d39-5747-90f0-070bcc7f60b4', 'listening', 'Прослухайте і складіть фразу', 'Do sutra! Ugodna večer!', '["sutra!", "večer!", "Ugodna", "Do"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f90cd3f6-2d39-5747-90f0-070bcc7f60b4', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('358522e5-27b4-5d7e-9807-486e341c0cf5', 'listening', 'Прослухайте і складіть фразу', 'Nema problema. Sjednite.', '["Nema", "Sjednite.", "problema."]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '358522e5-27b4-5d7e-9807-486e341c0cf5', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a438e1e5-6969-51e5-8f9d-558eb7ebc590', 'speaking', 'Успіхів!', 'Sretno!', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a438e1e5-6969-51e5-8f9d-558eb7ebc590', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ad53fa7e-0063-5534-8144-f8b7628e5250', 'speaking', 'Передавай привіт родині!', 'Pozdravi obitelj!', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ad53fa7e-0063-5534-8144-f8b7628e5250', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2b979e80-862b-59f2-9899-d5b7a3198b26', v_lesson, 'Після роботи', 'Poslije posla', 1041, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('48bc9f3b-3e6c-5655-a423-63ce466dde57', '2b979e80-862b-59f2-9899-d5b7a3198b26', 'Marija', 'Ja idem. Vidimo se sutra!', 'Я йду. Побачимося завтра!', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cbe127e5-4181-5086-9790-a5a4fc209730', '2b979e80-862b-59f2-9899-d5b7a3198b26', 'Taras', 'Do sutra! Ugodna večer!', 'До завтра! Гарного вечора!', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b6fd9a4d-93f0-5820-a9b4-24a1b854ce22', '2b979e80-862b-59f2-9899-d5b7a3198b26', 'Marija', 'Hvala, i tebi. Pozdravi obitelj!', 'Дякую, і тобі. Передавай привіт родині!', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a80f483f-fc34-5d54-994f-a0e73d06e70c', '2b979e80-862b-59f2-9899-d5b7a3198b26', 'Taras', 'Hoću. Bok!', 'Обов’язково. Бувай!', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('eaa41916-bfc0-5199-a910-3d4be3e6f01c', v_lesson, 'Перепрошую!', 'Ispričavam se!', 1042, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4f0bbd67-c45d-50a4-a0cd-654eeafa0ee2', 'eaa41916-bfc0-5199-a910-3d4be3e6f01c', 'Olena', 'Ispričavam se, kasnim pet minuta.', 'Перепрошую, я запізнююся на п’ять хвилин.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('36dde1fa-834f-526b-9596-c9bddad2c196', 'eaa41916-bfc0-5199-a910-3d4be3e6f01c', 'Gospođa Horvat', 'Nema problema. Sjednite.', 'Нічого страшного. Сідайте.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d62c9eb5-79a9-52cb-8137-440abb39c750', 'eaa41916-bfc0-5199-a910-3d4be3e6f01c', 'Olena', 'Hvala Vam. Čestitam na novom poslu!', 'Дякую вам. Вітаю з новою роботою!', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2de1a7a4-3ff4-51f8-a1ea-ea4c89a64303', 'eaa41916-bfc0-5199-a910-3d4be3e6f01c', 'Gospođa Horvat', 'Hvala! Sretno i Vama!', 'Дякую! Успіхів і вам!', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- A0.2 · урок 8: Де ви живете?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'adf335ee-0cba-5c9a-b86a-8baac868edbc';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A0.2: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Де? Прийменники місця' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.2.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 8: Де ви живете?', 'Lekcija 8: Gdje živite?', '["Назвати свою адресу", "Сказати, на якому поверсі ви живете", "Розповісти про свій будинок і район"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('kuća') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kuća'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zgrada') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zgrada'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kat') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kat'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kvart') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kvart'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('miran') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'miran'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('susjed') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'susjed'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('poštanski broj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'poštanski broj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kućni broj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kućni broj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tisuća') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tisuća'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('drag') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'drag'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('91c96414-17de-5d97-b628-9535f8dc115b', 'fill_in_the_blank', 'Živim ___ Zagrebu.', 'u', '["na", "iz", "u", "od"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '91c96414-17de-5d97-b628-9535f8dc115b', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('poštanski broj') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d479bde8-bee7-5e94-9fda-33b86e328b41', 'multiple_choice', 'Що означає «poštanski broj»?', 'поштовий індекс', '["поштовий індекс", "дорогий; милий, приємний", "спокійний", "район (міста)"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd479bde8-bee7-5e94-9fda-33b86e328b41', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('susjed') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2c9f5a0a-3cb0-53dd-90d1-d5a176315562', 'multiple_choice', 'Що означає «susjed»?', 'сусід', '["дорогий; милий, приємний", "сусід", "тисяча", "поштовий індекс"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2c9f5a0a-3cb0-53dd-90d1-d5a176315562', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('miran') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3a52512b-dbdd-5d1f-a5e8-313a6c00ca6f', 'multiple_choice', 'Як хорватською «спокійний»?', 'miran', '["miran", "susjed", "zgrada", "poštanski broj"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3a52512b-dbdd-5d1f-a5e8-313a6c00ca6f', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kuća') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3f50cb62-80e0-5b9c-bc03-973310139e03', 'type_answer', 'Напишіть хорватською: «будинок; дім»', 'kuća', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3f50cb62-80e0-5b9c-bc03-973310139e03', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('kat') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6b7b2213-ec1b-5488-9d5d-58819d9e6343', 'type_answer', 'Напишіть хорватською: «поверх»', 'kat', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6b7b2213-ec1b-5488-9d5d-58819d9e6343', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d90dad5b-514a-54c5-ac05-268f702c482f', 'sentence_builder', 'Складіть: «Я живу в Загребі.»', 'Živim u Zagrebu.', '["u", "Živim", "Zagrebu."]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd90dad5b-514a-54c5-ac05-268f702c482f', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c3ed24df-9654-54f2-8f7b-680349c06c72', 'sentence_builder', 'Складіть: «Район спокійний?»', 'Je li kvart miran?', '["li", "Je", "miran?", "kvart"]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c3ed24df-9654-54f2-8f7b-680349c06c72', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('cc08416d-2c38-5052-a62a-35c13d17e4cf', 'listening', 'Прослухайте і складіть фразу', 'Dvadeset dva, treći kat.', '["kat.", "dva,", "Dvadeset", "treći"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'cc08416d-2c38-5052-a62a-35c13d17e4cf', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d9691e69-2744-5e26-a57d-28d12d8c041e', 'listening', 'Прослухайте і складіть фразу', 'U stanu, u velikoj zgradi.', '["u", "U", "velikoj", "stanu,", "zgradi."]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd9691e69-2744-5e26-a57d-28d12d8c041e', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e6050dbd-6ad4-5051-b522-0823c31767d7', 'speaking', 'Де ви живете?', 'Gdje živite?', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e6050dbd-6ad4-5051-b522-0823c31767d7', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d9a54076-d040-5288-8881-dbb26a0fb935', 'speaking', 'Я живу на другому поверсі.', 'Živim na drugom katu.', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd9a54076-d040-5288-8881-dbb26a0fb935', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ce1dbefe-c98c-5ca0-bc12-1bdb30480267', v_lesson, 'Яка ваша адреса?', 'Koja je Vaša adresa?', 1081, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2d5bafef-a2fb-5057-985e-2ac0937d3594', 'ce1dbefe-c98c-5ca0-bc12-1bdb30480267', 'Službenica', 'Gdje živite?', 'Де ви живете?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7b18bb9f-4001-562c-8c34-a2c339ba8e9d', 'ce1dbefe-c98c-5ca0-bc12-1bdb30480267', 'Oleg', 'Živim u Zagrebu, u Vukovarskoj ulici.', 'Я живу в Загребі, на Вуковарській вулиці.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('bed8b226-b424-5c29-af0e-93e39eb9f0cd', 'ce1dbefe-c98c-5ca0-bc12-1bdb30480267', 'Službenica', 'Koji je kućni broj?', 'Який номер будинку?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('347ab862-5ccd-57bc-83cb-fabc4ce934b9', 'ce1dbefe-c98c-5ca0-bc12-1bdb30480267', 'Oleg', 'Dvadeset dva, treći kat.', 'Двадцять два, третій поверх.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('efd6c378-4c16-5680-939d-d7ddcc77484c', 'ce1dbefe-c98c-5ca0-bc12-1bdb30480267', 'Službenica', 'A poštanski broj?', 'А поштовий індекс?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3dc856b2-9098-5188-9ca8-51de8b464dd3', 'ce1dbefe-c98c-5ca0-bc12-1bdb30480267', 'Oleg', 'Deset tisuća.', 'Десять тисяч.', 6) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5b112403-f427-5930-adcf-8b3c9ee11e7d', v_lesson, 'Будинок чи квартира?', 'Kuća ili stan?', 1082, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ce1404b8-68da-53ee-b9e1-2a8fc9434e6a', '5b112403-f427-5930-adcf-8b3c9ee11e7d', 'Ana', 'Živiš li u kući ili u stanu?', 'Ти живеш у будинку чи в квартирі?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7e1171a1-b819-5b41-a5dd-a6e499c3ccba', '5b112403-f427-5930-adcf-8b3c9ee11e7d', 'Oksana', 'U stanu, u velikoj zgradi.', 'У квартирі, у великому будинку.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('31648655-aebc-5b30-99b2-8b61f8d9e4a6', '5b112403-f427-5930-adcf-8b3c9ee11e7d', 'Ana', 'Je li kvart miran?', 'Район спокійний?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('15b70483-7ea4-57bf-91de-f8b0de81f678', '5b112403-f427-5930-adcf-8b3c9ee11e7d', 'Oksana', 'Jest, i susjedi su dragi.', 'Так, і сусіди приємні.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- A0.2 · урок 9: Мови й національності
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'a9944193-2dfb-5944-b94c-41c41fdb7ca1';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A0.2: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Особові займенники та дієслово BITI' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.2.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 9: Мови й національності', 'Lekcija 9: Jezici i narodnosti', '["Сказати, хто ви за національністю", "Назвати мови, якими говорите", "Запитати співрозмовника про мови"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('Ukrajinka') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'Ukrajinka'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('Hrvatica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'Hrvatica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ukrajinski') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ukrajinski'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('njemački') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'njemački'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('poljski') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'poljski'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('talijanski') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'talijanski'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('stranac') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'stranac'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('razumjeti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'razumjeti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tečaj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tečaj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('profesorica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'profesorica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1dfdcf21-2aef-5b91-88c3-3e57ba5633ca', 'fill_in_the_blank', 'Ja ___ Ukrajinka.', 'sam', '["si", "sam", "smo", "je"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1dfdcf21-2aef-5b91-88c3-3e57ba5633ca', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('Hrvatica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3f1bfb38-1334-554c-a8a1-afe9326eea13', 'multiple_choice', 'Що означає «Hrvatica»?', 'хорватка', '["хорватка", "німецька (мова); німецький", "викладачка; вчителька", "розуміти"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3f1bfb38-1334-554c-a8a1-afe9326eea13', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('njemački') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0ebeea3a-5b30-5261-a61b-fcc254b334bb', 'multiple_choice', 'Що означає «njemački»?', 'німецька (мова); німецький', '["українка", "німецька (мова); німецький", "хорватка", "викладачка; вчителька"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0ebeea3a-5b30-5261-a61b-fcc254b334bb', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('poljski') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ccd91684-d8aa-5fda-af8b-6b6867d5bc28', 'multiple_choice', 'Як хорватською «польська (мова); польський»?', 'poljski', '["Ukrajinka", "poljski", "talijanski", "njemački"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ccd91684-d8aa-5fda-af8b-6b6867d5bc28', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('profesorica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ddc1953f-8898-524d-bc78-aaa641115bae', 'type_answer', 'Напишіть хорватською: «викладачка; вчителька»', 'profesorica', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ddc1953f-8898-524d-bc78-aaa641115bae', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('tečaj') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4144650e-13ba-52d4-838b-596e8dc65c97', 'type_answer', 'Напишіть хорватською: «курс (навчальний / валютний)»', 'tečaj', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4144650e-13ba-52d4-838b-596e8dc65c97', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ac7caac9-9ab2-530d-ac39-de7a4141bc05', 'sentence_builder', 'Складіть: «Я говорю українською й англійською.»', 'Govorim ukrajinski i engleski.', '["Govorim", "i", "engleski.", "ukrajinski"]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ac7caac9-9ab2-530d-ac39-de7a4141bc05', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7aef4151-fd68-5ac1-9f11-4944f3e1b777', 'sentence_builder', 'Складіть: «А ти хорватка?»', 'A ti si Hrvatica?', '["ti", "A", "Hrvatica?", "si"]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7aef4151-fd68-5ac1-9f11-4944f3e1b777', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('dd096103-dd0a-5058-b9c8-661ee702386f', 'listening', 'Прослухайте і складіть фразу', 'Jesam. Govoriš li hrvatski?', '["Govoriš", "hrvatski?", "Jesam.", "li"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'dd096103-dd0a-5058-b9c8-661ee702386f', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('89a47bff-8ef5-5a0b-96b5-34f05f1bf31c', 'listening', 'Прослухайте і складіть фразу', 'Ne razumijem, nažalost.', '["Ne", "nažalost.", "razumijem,"]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '89a47bff-8ef5-5a0b-96b5-34f05f1bf31c', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('99cf94cc-5c40-5a1e-9fa0-c2b8fdd22a80', 'speaking', 'Я українець.', 'Ja sam Ukrajinac.', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '99cf94cc-5c40-5a1e-9fa0-c2b8fdd22a80', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a1fb3093-ce02-5a81-b88f-1e04e1d8c7f1', 'speaking', 'Якими мовами ви говорите?', 'Koje jezike govorite?', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a1fb3093-ce02-5a81-b88f-1e04e1d8c7f1', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4669d4a2-ecf4-5925-ba97-d0ae78bf1c21', v_lesson, 'Ти українка?', 'Jesi li Ukrajinka?', 1091, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('591e9522-d18e-5623-862b-6776abec4c31', '4669d4a2-ecf4-5925-ba97-d0ae78bf1c21', 'Petra', 'Jesi li ti Ukrajinka?', 'Ти українка?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ee5249ff-284d-571c-a412-0d89a6d5e929', '4669d4a2-ecf4-5925-ba97-d0ae78bf1c21', 'Olena', 'Da, ja sam Ukrajinka. A ti si Hrvatica?', 'Так, я українка. А ти хорватка?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('62884b0b-a326-541a-880d-07326eaedbdb', '4669d4a2-ecf4-5925-ba97-d0ae78bf1c21', 'Petra', 'Jesam. Govoriš li hrvatski?', 'Так. Ти говориш хорватською?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('154d47d9-87c6-51ca-bcec-4c05b53a7a08', '4669d4a2-ecf4-5925-ba97-d0ae78bf1c21', 'Olena', 'Malo. Govorim ukrajinski i engleski.', 'Трохи. Я говорю українською й англійською.', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('35cba33a-bc29-5953-ac6d-2ea36f5fb51a', v_lesson, 'Іноземці на курсі', 'Stranci na tečaju', 1092, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('37e38503-2cdb-5b8c-a89f-03e827de7b3f', '35cba33a-bc29-5953-ac6d-2ea36f5fb51a', 'Profesorica', 'Koje jezike govorite?', 'Якими мовами ви говорите?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a54a0c9c-128e-5938-b2bd-3c23489785a9', '35cba33a-bc29-5953-ac6d-2ea36f5fb51a', 'Andrij', 'Ukrajinski, poljski i malo njemački.', 'Українською, польською і трохи німецькою.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4b883a0f-c310-58f3-8756-057bdb7a902f', '35cba33a-bc29-5953-ac6d-2ea36f5fb51a', 'Profesorica', 'Odlično! A razumijete li talijanski?', 'Чудово! А італійську ви розумієте?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e143460c-97c2-5d26-ab50-a0520b57bdba', '35cba33a-bc29-5953-ac6d-2ea36f5fb51a', 'Andrij', 'Ne razumijem, nažalost.', 'На жаль, не розумію.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- A0.3 · урок 13: Числа від 11 до 19
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'e30c65f2-1a30-5b51-85e7-6a460cd1799f';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A0.3: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Числа 0–100' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.3.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 13: Числа від 11 до 19', 'Lekcija 13: Brojevi od 11 do 19', '["Рахувати від 11 до 19", "Сказати, скільки вас людей", "Зрозуміти номер автобуса й час у хвилинах"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('jedanaest') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jedanaest'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dvanaest') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dvanaest'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('trinaest') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'trinaest'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('četrnaest') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'četrnaest'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('petnaest') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'petnaest'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('šesnaest') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'šesnaest'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sedamnaest') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sedamnaest'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('osamnaest') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'osamnaest'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('devetnaest') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'devetnaest'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('otprilike') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'otprilike'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('osoba') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'osoba'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c56864fa-d3ec-5866-9c90-b88e13cb5cf6', 'fill_in_the_blank', 'Deset i pet je ___.', 'petnaest', '["dvadeset pet", "petnaest", "pedeset", "pet"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c56864fa-d3ec-5866-9c90-b88e13cb5cf6', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('otprilike') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('60b724d3-4ac5-521c-ad47-402bebd8973f', 'multiple_choice', 'Що означає «otprilike»?', 'приблизно', '["дев''ятнадцять", "сімнадцять", "приблизно", "вісімнадцять"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '60b724d3-4ac5-521c-ad47-402bebd8973f', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('osamnaest') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('46f7ebcb-904a-542d-8031-94c639fb0e70', 'multiple_choice', 'Що означає «osamnaest»?', 'вісімнадцять', '["одинадцять", "п''ятнадцять", "тринадцять", "вісімнадцять"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '46f7ebcb-904a-542d-8031-94c639fb0e70', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('osoba') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5ddfba02-5d65-599a-baf3-02670b95f9a2', 'multiple_choice', 'Як хорватською «особа»?', 'osoba', '["dvanaest", "četrnaest", "osamnaest", "osoba"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5ddfba02-5d65-599a-baf3-02670b95f9a2', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('četrnaest') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9eaa247a-f518-530f-8a70-172c02f43a68', 'type_answer', 'Напишіть хорватською: «чотирнадцять»', 'četrnaest', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9eaa247a-f518-530f-8a70-172c02f43a68', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('jedanaest') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6b56f913-a098-5c74-a909-e92f2042ac74', 'type_answer', 'Напишіть хорватською: «одинадцять»', 'jedanaest', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6b56f913-a098-5c74-a909-e92f2042ac74', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('25395eef-f71e-57bb-a18f-ed1999d87944', 'sentence_builder', 'Складіть: «Приблизно п’ятнадцять хвилин.»', 'Otprilike petnaest minuta.', '["minuta.", "Otprilike", "petnaest"]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '25395eef-f71e-57bb-a18f-ed1999d87944', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1b7f95c8-3bbc-535a-a6df-c78e553e42e3', 'sentence_builder', 'Складіть: «У нас є стіл на чотирнадцять.»', 'Imamo stol za četrnaest.', '["stol", "za", "Imamo", "četrnaest."]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1b7f95c8-3bbc-535a-a6df-c78e553e42e3', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5af93690-32cb-5bd0-b0bc-d9e76857fe96', 'listening', 'Прослухайте і складіть фразу', 'Imamo stol za četrnaest, na terasi.', '["Imamo", "stol", "četrnaest,", "terasi.", "na", "za"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5af93690-32cb-5bd0-b0bc-d9e76857fe96', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('544e7c98-5bec-5eb1-bbe1-4cbfef8246f8', 'listening', 'Прослухайте і складіть фразу', 'Sedamnaest ili devetnaest.', '["devetnaest.", "Sedamnaest", "ili"]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '544e7c98-5bec-5eb1-bbe1-4cbfef8246f8', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8e40135f-00ea-5d7d-b431-9b45812fab00', 'speaking', 'Мені вісімнадцять років.', 'Imam osamnaest godina.', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8e40135f-00ea-5d7d-b431-9b45812fab00', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('345d2cb9-8fa1-52a7-b878-fe5ca60e4bf8', 'speaking', 'Автобус номер одинадцять.', 'Autobus broj jedanaest.', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '345d2cb9-8fa1-52a7-b878-fe5ca60e4bf8', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6d5fa0b1-02d9-503c-a217-c93ad68b81c4', v_lesson, 'Скільки вас?', 'Koliko vas je?', 1131, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e7ebdb9e-ba75-592f-9f27-fc5014260e77', '6d5fa0b1-02d9-503c-a217-c93ad68b81c4', 'Konobar', 'Dobra večer! Koliko vas je?', 'Добрий вечір! Скільки вас?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b8ff0d60-9be7-5a7a-b1e4-f9f49c64e265', '6d5fa0b1-02d9-503c-a217-c93ad68b81c4', 'Marko', 'Dvanaest. Imate li stol za dvanaest osoba?', 'Дванадцять. У вас є стіл на дванадцять осіб?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3d07b3a9-6cf3-5338-b182-7bca9957b45b', '6d5fa0b1-02d9-503c-a217-c93ad68b81c4', 'Konobar', 'Imamo stol za četrnaest, na terasi.', 'У нас є стіл на чотирнадцять, на терасі.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('855c82e0-7a49-5789-adaf-98300288f52d', '6d5fa0b1-02d9-503c-a217-c93ad68b81c4', 'Marko', 'Odlično, hvala!', 'Чудово, дякую!', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4df7ddd8-664b-5acc-aa6c-18f2ecb48f6b', v_lesson, 'Який автобус?', 'Koji autobus?', 1132, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6528e6be-4356-539b-9bdb-06767c2a02b6', '4df7ddd8-664b-5acc-aa6c-18f2ecb48f6b', 'Turistkinja', 'Koji autobus ide u centar?', 'Який автобус їде в центр?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c2c22ebc-91e9-541e-95d4-363a7c6dc309', '4df7ddd8-664b-5acc-aa6c-18f2ecb48f6b', 'Gospodin', 'Sedamnaest ili devetnaest.', 'Сімнадцятий або дев’ятнадцятий.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1487a59b-66e6-5565-b2b4-cdd7c509cba4', '4df7ddd8-664b-5acc-aa6c-18f2ecb48f6b', 'Turistkinja', 'Koliko minuta do centra?', 'Скільки хвилин до центру?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('067ece3a-fba2-56f8-b79f-bf85c072d28b', '4df7ddd8-664b-5acc-aa6c-18f2ecb48f6b', 'Gospodin', 'Otprilike petnaest minuta.', 'Приблизно п’ятнадцять хвилин.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- A0.3 · урок 14: До ста і номер телефону
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A0.3: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Числа 0–100' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.3.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 14: До ста і номер телефону', 'Lekcija 14: Do sto i broj telefona', '["Рахувати десятками до 100", "Продиктувати номер телефону", "Зрозуміти ціну до 100 євро"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('šezdeset') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'šezdeset'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sedamdeset') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sedamdeset'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('osamdeset') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'osamdeset'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('devedeset') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'devedeset'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sto') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sto'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('broj telefona') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'broj telefona'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ponoviti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ponoviti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pisati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pisati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('telefon') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'telefon'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('evo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'evo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('78d54de8-8be3-5226-9c1b-6bbd16d8477f', 'fill_in_the_blank', 'Pedeset i deset je ___.', 'šezdeset', '["šesnaest", "šezdeset", "sedamdeset", "šest"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '78d54de8-8be3-5226-9c1b-6bbd16d8477f', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('telefon') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4673033e-1041-53fa-b98d-f9ba74ddde4b', 'multiple_choice', 'Що означає «telefon»?', 'телефон', '["номер телефону", "шістдесят", "писати", "телефон"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4673033e-1041-53fa-b98d-f9ba74ddde4b', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ponoviti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('906f6922-49cb-57bb-9ec4-c1de8b74c2d0', 'multiple_choice', 'Що означає «ponoviti»?', 'повторити', '["повторити", "номер телефону", "телефон", "вісімдесят"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '906f6922-49cb-57bb-9ec4-c1de8b74c2d0', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sto') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('21feeff2-d6ae-5250-b4af-deb116956024', 'multiple_choice', 'Як хорватською «сто»?', 'sto', '["telefon", "broj telefona", "pisati", "sto"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '21feeff2-d6ae-5250-b4af-deb116956024', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sedamdeset') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('12416dc1-58cd-53df-9a7a-209442576bb9', 'type_answer', 'Напишіть хорватською: «сімдесят»', 'sedamdeset', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '12416dc1-58cd-53df-9a7a-209442576bb9', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('osamdeset') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7efa2f04-38d1-5a43-8d07-4df93f772fa2', 'type_answer', 'Напишіть хорватською: «вісімдесят»', 'osamdeset', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7efa2f04-38d1-5a43-8d07-4df93f772fa2', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d0827521-f696-5acd-9ef7-455edd4c94a8', 'sentence_builder', 'Складіть: «Який ваш номер телефону?»', 'Koji je Vaš broj telefona?', '["je", "Koji", "telefona?", "broj", "Vaš"]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd0827521-f696-5acd-9ef7-455edd4c94a8', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3d1e92e6-fb87-5d1e-8a49-7f733011b0fe', 'sentence_builder', 'Складіть: «Ось сто євро.»', 'Evo sto eura.', '["eura.", "sto", "Evo"]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3d1e92e6-fb87-5d1e-8a49-7f733011b0fe', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b29a0f94-4aa0-5384-9c55-c3c0f481e560', 'listening', 'Прослухайте і складіть фразу', 'Možete li ponoviti polako?', '["polako?", "ponoviti", "li", "Možete"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b29a0f94-4aa0-5384-9c55-c3c0f481e560', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('06555887-f0e8-5b81-a02e-bb5ff932b20b', 'listening', 'Прослухайте і складіть фразу', 'Devedeset eura.', '["eura.", "Devedeset"]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '06555887-f0e8-5b81-a02e-bb5ff932b20b', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('72cecbe0-0f3e-50c7-8044-a5ab12151d0a', 'speaking', 'Сто євро.', 'Sto eura.', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '72cecbe0-0f3e-50c7-8044-a5ab12151d0a', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0ddc9239-cb1a-517a-a117-e107975e549e', 'speaking', 'Скажіть, будь ласка, ваш номер телефону.', 'Recite mi, molim, Vaš broj telefona.', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0ddc9239-cb1a-517a-a117-e107975e549e', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('be71d3b5-6448-53fa-b4df-7fbcdd379af2', v_lesson, 'Номер телефону', 'Broj telefona', 1141, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('aa6bb242-7693-5d55-8b72-bf0bf916a262', 'be71d3b5-6448-53fa-b4df-7fbcdd379af2', 'Službenica', 'Koji je Vaš broj telefona?', 'Який ваш номер телефону?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7735abbe-4685-5435-95d2-9b5c3f72167b', 'be71d3b5-6448-53fa-b4df-7fbcdd379af2', 'Iryna', 'Nula devedeset jedan, šezdeset sedam, osamdeset dva, sedamdeset tri.', 'Нуль дев’яносто один, шістдесят сім, вісімдесят два, сімдесят три.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('29eb78eb-d7b2-5057-b347-0ecf71a34322', 'be71d3b5-6448-53fa-b4df-7fbcdd379af2', 'Službenica', 'Možete li ponoviti polako?', 'Можете повторити повільно?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e40aafc6-f055-5a21-a0fc-08f74b27ccf2', 'be71d3b5-6448-53fa-b4df-7fbcdd379af2', 'Iryna', 'Naravno. Evo, ovdje piše.', 'Звісно. Ось, тут написано.', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a5bb2170-04a6-5054-8cf6-d7cac47fd74f', v_lesson, 'Скільки коштує?', 'Koliko košta?', 1142, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cfd6a7ea-e582-5a3e-8568-df06f5f79c19', 'a5bb2170-04a6-5054-8cf6-d7cac47fd74f', 'Kupac', 'Koliko košta ova jakna?', 'Скільки коштує ця куртка?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('502435a0-2d5e-52f5-98fa-399eebaf6bb9', 'a5bb2170-04a6-5054-8cf6-d7cac47fd74f', 'Prodavačica', 'Devedeset eura.', 'Дев’яносто євро.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7fc07d86-c6c1-587b-87ca-71316df3c0d1', 'a5bb2170-04a6-5054-8cf6-d7cac47fd74f', 'Kupac', 'A ona plava?', 'А он та синя?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('38812d7b-f731-5c40-84a9-d85d321f4cc4', 'a5bb2170-04a6-5054-8cf6-d7cac47fd74f', 'Prodavačica', 'Sedamdeset pet. Danas je sve na popustu.', 'Сімдесят п’ять. Сьогодні на все знижка.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('aa8db6ab-e195-552a-92cb-c0ccc2995843', 'a5bb2170-04a6-5054-8cf6-d7cac47fd74f', 'Kupac', 'Uzimam plavu. Evo sto eura.', 'Беру синю. Ось сто євро.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- A0.4 · урок 18: Учора, сьогодні, завтра
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '238d9508-3c2e-5ee6-910f-0ae8863c2dc7';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A0.4: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Час: дні, години, місяці' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.4.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 18: Учора, сьогодні, завтра', 'Lekcija 18: Jučer, danas, sutra', '["Вживати jučer, prekjučer, prekosutra", "Назвати частину дня: ujutro, poslijepodne, navečer", "Домовитися про день і час"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('jučer') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jučer'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prekjučer') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prekjučer'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prekosutra') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prekosutra'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tjedan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tjedan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ujutro') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ujutro'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prijepodne') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prijepodne'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('podne') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'podne'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('poslijepodne') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'poslijepodne'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('navečer') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'navečer'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ponoć') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ponoć'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tek') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tek'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('872e33e6-2169-5986-9731-e226f035b9a1', 'fill_in_the_blank', 'Danas je petak, a sutra je ___.', 'subota', '["nedjelja", "četvrtak", "subota", "ponedjeljak"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '872e33e6-2169-5986-9731-e226f035b9a1', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('ponoć') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('19f44a5b-56d6-5f25-a63d-8411eb54951f', 'multiple_choice', 'Що означає «ponoć»?', 'північ (час)', '["ввечері", "тиждень", "вранці", "північ (час)"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '19f44a5b-56d6-5f25-a63d-8411eb54951f', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prekosutra') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b75faf61-e6ec-5228-8fff-927a16c62d40', 'multiple_choice', 'Що означає «prekosutra»?', 'післязавтра', '["після обіду; пополудні", "полудень", "вчора", "післязавтра"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b75faf61-e6ec-5228-8fff-927a16c62d40', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('navečer') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e0b86f2c-6a0e-5afd-a3b3-08d564585c5a', 'multiple_choice', 'Як хорватською «ввечері»?', 'navečer', '["podne", "navečer", "tek", "prekjučer"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e0b86f2c-6a0e-5afd-a3b3-08d564585c5a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jučer') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('be69d90a-b286-54cf-b92b-daac11515297', 'type_answer', 'Напишіть хорватською: «вчора»', 'jučer', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'be69d90a-b286-54cf-b92b-daac11515297', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('tjedan') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9e67a0e2-a57c-5989-a18d-63bf5d8b0b10', 'type_answer', 'Напишіть хорватською: «тиждень»', 'tjedan', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9e67a0e2-a57c-5989-a18d-63bf5d8b0b10', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('08184f98-990b-5b3a-bd16-b78082f36b9a', 'sentence_builder', 'Складіть: «Післязавтра можна.»', 'Prekosutra može.', '["može.", "Prekosutra"]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '08184f98-990b-5b3a-bd16-b78082f36b9a', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f1651164-12ef-562a-b910-e69def931c4f', 'sentence_builder', 'Складіть: «Учора робота, сьогодні курс.»', 'Jučer posao, danas tečaj.', '["danas", "posao,", "tečaj.", "Jučer"]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f1651164-12ef-562a-b910-e69def931c4f', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3bd530ea-350f-539a-96f0-a3a649e67d1b', 'listening', 'Прослухайте і складіть фразу', 'Prijepodne, u deset.', '["u", "deset.", "Prijepodne,"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3bd530ea-350f-539a-96f0-a3a649e67d1b', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f82c3d0c-2c29-5aeb-84d0-7d4b18b4e5a1', 'listening', 'Прослухайте і складіть фразу', 'A navečer?', '["navečer?", "A"]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f82c3d0c-2c29-5aeb-84d0-7d4b18b4e5a1', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('424e5a14-ebef-5eac-b6f7-7403ed60bba3', 'speaking', 'Учора, сьогодні, завтра.', 'Jučer, danas, sutra.', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '424e5a14-ebef-5eac-b6f7-7403ed60bba3', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d3cc8b93-7e42-54f1-adcd-f634cd5b2968', 'speaking', 'Побачимося післязавтра!', 'Vidimo se prekosutra!', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd3cc8b93-7e42-54f1-adcd-f634cd5b2968', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f8f85040-5e64-5549-94eb-336c1b6508fd', v_lesson, 'Коли зустрінемося?', 'Kada se vidimo?', 1181, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cad3fe99-0d16-58d3-a504-d66198673a64', 'f8f85040-5e64-5549-94eb-336c1b6508fd', 'Ana', 'Imaš li vremena sutra poslijepodne?', 'Маєш час завтра після обіду?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8d183022-8484-5d36-b53f-5701c4ad3873', 'f8f85040-5e64-5549-94eb-336c1b6508fd', 'Taras', 'Sutra ne, radim do večeri. Prekosutra može.', 'Завтра ні, працюю до вечора. Післязавтра можна.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9014204d-8b0f-550a-b2c6-75ac37239731', 'f8f85040-5e64-5549-94eb-336c1b6508fd', 'Ana', 'Prekosutra je subota. Prijepodne ili poslijepodne?', 'Післязавтра субота. До обіду чи після обіду?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('90f5bcd7-3efe-51c3-baab-c0793b93fe6b', 'f8f85040-5e64-5549-94eb-336c1b6508fd', 'Taras', 'Prijepodne, u deset.', 'До обіду, о десятій.', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('597f0bf0-dd6e-5d41-a92a-5b9a71a42928', v_lesson, 'Мій тиждень', 'Moj tjedan', 1182, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d55c26a8-cdae-5a49-9956-849d7b9554e9', '597f0bf0-dd6e-5d41-a92a-5b9a71a42928', 'Marko', 'Koliko dugo si u Hrvatskoj?', 'Як довго ти в Хорватії?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ed9a502c-dbd7-53ec-94e1-1978dccb6291', '597f0bf0-dd6e-5d41-a92a-5b9a71a42928', 'Iryna', 'Tek tjedan dana.', 'Лише тиждень.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('136f0513-2255-58b3-91fe-be6c30d16de1', '597f0bf0-dd6e-5d41-a92a-5b9a71a42928', 'Marko', 'I kakav ti je tjedan?', 'І який у тебе тиждень?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('741e849b-5ad2-550e-bc12-08165f282b96', '597f0bf0-dd6e-5d41-a92a-5b9a71a42928', 'Iryna', 'Pun! Jučer posao, danas tečaj, a sutra more!', 'Насичений! Учора робота, сьогодні курс, а завтра — море!', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('be568d8c-287c-5a90-9bec-36a08e593596', '597f0bf0-dd6e-5d41-a92a-5b9a71a42928', 'Marko', 'A navečer?', 'А ввечері?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e99536c5-ac16-5056-bb30-56737108e1a8', '597f0bf0-dd6e-5d41-a92a-5b9a71a42928', 'Iryna', 'Navečer spavam!', 'Увечері сплю!', 6) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- A0.4 · урок 19: Місяці й дати
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'b36b4550-ff36-50cb-89fb-8246b351c8d6';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A0.4: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Час: дні, години, місяці' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.4.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 19: Місяці й дати', 'Lekcija 19: Mjeseci i datumi', '["Назвати всі місяці", "Сказати дату свого дня народження", "Запитати, яке сьогодні число"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('veljača') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'veljača'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ožujak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ožujak'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('travanj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'travanj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('svibanj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'svibanj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('lipanj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'lipanj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('listopad') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'listopad'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('studeni') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'studeni'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prosinac') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prosinac'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('datum') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'datum'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prvi') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prvi'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('treći') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'treći'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('praznici') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'praznici'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('dfde673b-a617-5eaf-9c36-36af2c853959', 'fill_in_the_blank', 'Rođendan mi je u ___.', 'svibnju', '["svibnjem", "svibanj", "svibnju", "svibnja"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'dfde673b-a617-5eaf-9c36-36af2c853959', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('listopad') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1a097408-609e-5868-a00a-11567551dff1', 'multiple_choice', 'Що означає «listopad»?', 'жовтень', '["квітень", "канікули; свята", "жовтень", "березень"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1a097408-609e-5868-a00a-11567551dff1', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('treći') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8872aa90-d5d6-5db0-9e61-0e971200c346', 'multiple_choice', 'Що означає «treći»?', 'третій', '["травень", "лютий", "грудень", "третій"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8872aa90-d5d6-5db0-9e61-0e971200c346', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prvi') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('adb352b6-ba1b-52da-a36e-91f2e584a268', 'multiple_choice', 'Як хорватською «перший»?', 'prvi', '["datum", "prvi", "listopad", "svibanj"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'adb352b6-ba1b-52da-a36e-91f2e584a268', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('lipanj') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d424167d-3f8a-579f-9826-632159a09ccc', 'type_answer', 'Напишіть хорватською: «червень»', 'lipanj', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd424167d-3f8a-579f-9826-632159a09ccc', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('svibanj') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f8f90e5e-6a0e-59e6-af15-a4e302507056', 'type_answer', 'Напишіть хорватською: «травень»', 'svibanj', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f8f90e5e-6a0e-59e6-af15-a4e302507056', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b8d9128a-4344-51e4-981a-c81d732165e2', 'sentence_builder', 'Складіть: «Коли в тебе день народження?»', 'Kada ti je rođendan?', '["ti", "rođendan?", "je", "Kada"]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b8d9128a-4344-51e4-981a-c81d732165e2', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3f343efd-9c52-5075-ac92-0c183d793baa', 'sentence_builder', 'Складіть: «Яке сьогодні число?»', 'Koji je danas datum?', '["datum?", "je", "danas", "Koji"]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3f343efd-9c52-5075-ac92-0c183d793baa', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2aacc9b4-44cd-5fc3-ace0-61f7843d0d8b', 'listening', 'Прослухайте і складіть фразу', 'Trećeg studenog.', '["studenog.", "Trećeg"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2aacc9b4-44cd-5fc3-ace0-61f7843d0d8b', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('80cf2fe4-8e65-5219-9cdd-d0997b99e797', 'listening', 'Прослухайте і складіть фразу', 'A zimski praznici?', '["praznici?", "zimski", "A"]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '80cf2fe4-8e65-5219-9cdd-d0997b99e797', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('685b075a-bff2-5ecb-b5b6-9f28bdeca412', 'speaking', 'Мій день народження в травні.', 'Rođendan mi je u svibnju.', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '685b075a-bff2-5ecb-b5b6-9f28bdeca412', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2055a5d7-8d35-5e54-961b-a460cd345baf', 'speaking', 'Сьогодні перше квітня.', 'Danas je prvi travnja.', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2055a5d7-8d35-5e54-961b-a460cd345baf', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a1c3f77d-6697-5ee9-8e1e-9e58e22d0271', v_lesson, 'Коли твій день народження?', 'Kada ti je rođendan?', 1191, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f1bf486c-d0c5-563b-8ce2-77666419d26f', 'a1c3f77d-6697-5ee9-8e1e-9e58e22d0271', 'Lana', 'Kada ti je rođendan?', 'Коли в тебе день народження?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3d23437a-7dbc-5e0d-a2c1-51bf4cb8fd63', 'a1c3f77d-6697-5ee9-8e1e-9e58e22d0271', 'Oleg', 'Dvadeset prvog ožujka. A tvoj?', 'Двадцять першого березня. А твій?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a6a17636-4ff9-5f09-8ae9-e0a3adc2079e', 'a1c3f77d-6697-5ee9-8e1e-9e58e22d0271', 'Lana', 'Trećeg studenog.', 'Третього листопада.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f0127c23-6534-55f4-9e4b-cba9b44cf97f', 'a1c3f77d-6697-5ee9-8e1e-9e58e22d0271', 'Oleg', 'Znači, u jesen. A koji je danas datum?', 'Отже, восени. А яке сьогодні число?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a8d40d87-4781-5e0c-957e-fb1fc5744cf1', 'a1c3f77d-6697-5ee9-8e1e-9e58e22d0271', 'Lana', 'Danas je trinaesti listopada.', 'Сьогодні тринадцяте жовтня.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cfa7ea16-b5e0-575a-8a2d-e9e2ce23372e', v_lesson, 'Шкільний рік', 'Školska godina', 1192, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ec312064-8bab-5bde-849d-551decf08bf3', 'cfa7ea16-b5e0-575a-8a2d-e9e2ce23372e', 'Mama', 'Kada počinje škola u Hrvatskoj?', 'Коли в Хорватії починається школа?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cbfe1bb8-d2b6-581c-8e9e-d243941ca199', 'cfa7ea16-b5e0-575a-8a2d-e9e2ce23372e', 'Učiteljica', 'Početkom rujna, a završava u lipnju.', 'На початку вересня, а закінчується в червні.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9c51cfa8-fdb4-5ddc-9487-c0a751eaf1f4', 'cfa7ea16-b5e0-575a-8a2d-e9e2ce23372e', 'Mama', 'A zimski praznici?', 'А зимові канікули?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4ff47cbb-d266-51f5-aaa5-7d5618936cdf', 'cfa7ea16-b5e0-575a-8a2d-e9e2ce23372e', 'Učiteljica', 'Od kraja prosinca do sredine siječnja.', 'З кінця грудня до середини січня.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- A0.5 · урок 23: Родичі й стосунки
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'cec08ff0-a97d-5847-88cc-dee22fed2f8c';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A0.5: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Дієслово «imati» (мати)' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.5.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 23: Родичі й стосунки', 'Lekcija 23: Rodbina i veze', '["Назвати родичів: тітка, дядько, двоюрідні брати й сестри", "Сказати, чи ви одружені", "Розповісти про свою родину в Хорватії"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('rodbina') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rodbina'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('teta') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'teta'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ujak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ujak'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('bratić') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'bratić'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sestrična') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sestrična'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('oženjen') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'oženjen'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('udana') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'udana'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('cura') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'cura'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dečko') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dečko'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('unuk') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'unuk'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('mlad') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'mlad'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6e9144f3-8fae-52f8-b721-711581a573fd', 'fill_in_the_blank', 'Oni ___ dvoje djece.', 'imaju', '["ima", "imaš", "imam", "imaju"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6e9144f3-8fae-52f8-b721-711581a573fd', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('mlad') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8179ceff-6cac-5a2e-97bf-0b1e4b52e3cc', 'multiple_choice', 'Що означає «mlad»?', 'молодий', '["родичі", "хлопець (романтично)", "онук", "молодий"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8179ceff-6cac-5a2e-97bf-0b1e4b52e3cc', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dečko') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('51eb7964-ca1f-5ada-9f9c-7333ce5ab722', 'multiple_choice', 'Що означає «dečko»?', 'хлопець (романтично)', '["онук", "двоюрідний брат", "хлопець (романтично)", "двоюрідна сестра"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '51eb7964-ca1f-5ada-9f9c-7333ce5ab722', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('udana') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('301f5635-88e4-562b-bb9b-d60f39083a02', 'multiple_choice', 'Як хорватською «заміжня»?', 'udana', '["udana", "mlad", "rodbina", "bratić"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '301f5635-88e4-562b-bb9b-d60f39083a02', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('teta') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e62d644e-77da-56c3-870c-74806b3e0ab9', 'type_answer', 'Напишіть хорватською: «тітка»', 'teta', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e62d644e-77da-56c3-870c-74806b3e0ab9', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('oženjen') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0eb7f991-bf8a-51cf-a5a5-c1e61e64f267', 'type_answer', 'Напишіть хорватською: «одружений (про чоловіка)»', 'oženjen', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0eb7f991-bf8a-51cf-a5a5-c1e61e64f267', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('30127148-3098-5589-8270-fc7ed298ff68', 'sentence_builder', 'Складіть: «Моя тітка живе в Рієці.»', 'Moja teta živi u Rijeci.', '["Moja", "Rijeci.", "živi", "u", "teta"]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '30127148-3098-5589-8270-fc7ed298ff68', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c54d296b-16c6-5798-b339-4f6483d83eb1', 'sentence_builder', 'Складіть: «Ти одружений?»', 'Jesi li oženjen?', '["oženjen?", "Jesi", "li"]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c54d296b-16c6-5798-b339-4f6483d83eb1', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4cb1904f-c442-5e6a-ab32-79907d5d1a2b', 'listening', 'Прослухайте і складіть фразу', 'Imaju li djecu?', '["Imaju", "djecu?", "li"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4cb1904f-c442-5e6a-ab32-79907d5d1a2b', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d3a2d8fd-96f2-594f-9351-98874eeef77b', 'listening', 'Прослухайте і складіть фразу', 'Unuka? Pa ti si mlad!', '["si", "ti", "mlad!", "Unuka?", "Pa"]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd3a2d8fd-96f2-594f-9351-98874eeef77b', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ca296508-350d-51e1-96be-831a536e86c4', 'speaking', 'У мене є хлопець.', 'Imam dečka.', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ca296508-350d-51e1-96be-831a536e86c4', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('86eda954-c07e-565a-8c5d-6025c5cbe861', 'speaking', 'Моя сестра заміжня.', 'Moja sestra je udana.', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '86eda954-c07e-565a-8c5d-6025c5cbe861', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('bd07af69-0076-55f6-9d19-22ca49369591', v_lesson, 'Родичі в Хорватії', 'Rodbina u Hrvatskoj', 1231, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cf163406-6015-5ddc-8c72-52f867ed93de', 'bd07af69-0076-55f6-9d19-22ca49369591', 'Ana', 'Imaš li rodbinu u Hrvatskoj?', 'У тебе є родичі в Хорватії?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('11cfb6c0-e973-509c-b639-840f1aeedb68', 'bd07af69-0076-55f6-9d19-22ca49369591', 'Oksana', 'Imam. Moja teta i ujak žive u Rijeci.', 'Так. Моя тітка й дядько живуть у Рієці.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1c624202-267b-50a0-a4d8-448d4ed03af9', 'bd07af69-0076-55f6-9d19-22ca49369591', 'Ana', 'Imaju li djecu?', 'У них є діти?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3129e6f2-fb0d-5f69-8076-d514c969d0c7', 'bd07af69-0076-55f6-9d19-22ca49369591', 'Oksana', 'Imaju. Moj bratić ima dvadeset godina, a sestrična petnaest.', 'Так. Моєму двоюрідному братові двадцять років, а двоюрідній сестрі п’ятнадцять.', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('327886e7-c152-516d-8e3f-d3475bd7819b', v_lesson, 'Ти одружений?', 'Jesi li oženjen?', 1232, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e261b886-d828-5441-9e84-1e132ec26dd1', '327886e7-c152-516d-8e3f-d3475bd7819b', 'Marko', 'Jesi li oženjen?', 'Ти одружений?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('15078cc3-6963-5748-9f71-06f8dc26098e', '327886e7-c152-516d-8e3f-d3475bd7819b', 'Andrij', 'Nisam, ali imam curu. A ti?', 'Ні, але в мене є дівчина. А ти?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('98c5758d-8554-5841-b96e-c0b1a096b743', '327886e7-c152-516d-8e3f-d3475bd7819b', 'Marko', 'Ja sam oženjen i imam unuka!', 'Я одружений, і в мене є онук!', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('36fe68dd-6199-5b71-9b16-110e29aed957', '327886e7-c152-516d-8e3f-d3475bd7819b', 'Andrij', 'Unuka? Pa ti si mlad!', 'Онука? Та ти ж молодий!', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- A0.6 · урок 27: Кімнати й техніка
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A0.6: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Де? Прийменники місця' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.6.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 27: Кімнати й техніка', 'Lekcija 27: Prostorije i aparati', '["Назвати кімнати: спальня, коридор, туалет", "Назвати побутову техніку", "Сказати, де що стоїть"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('hodnik') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hodnik'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('spavaća soba') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'spavaća soba'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zahod') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zahod'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('perilica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'perilica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pećnica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pećnica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('štednjak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'štednjak'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('hladnjak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hladnjak'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vrt') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vrt'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dvorište') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dvorište'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ogledalo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ogledalo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3908466a-3093-5b12-9572-f4a9b90a7c1c', 'fill_in_the_blank', 'Perilica je ___ kupaonici.', 'u', '["iz", "na", "do", "u"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3908466a-3093-5b12-9572-f4a9b90a7c1c', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('hodnik') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('64246e07-a82b-57d1-9c48-8410fc7baded', 'multiple_choice', 'Що означає «hodnik»?', 'коридор', '["туалет", "дзеркало", "духовка", "коридор"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '64246e07-a82b-57d1-9c48-8410fc7baded', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('hladnjak') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9f968aa3-b398-5f4f-a348-a55b7deb6b11', 'multiple_choice', 'Що означає «hladnjak»?', 'холодильник', '["спальня", "холодильник", "плита (для готування)", "коридор"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9f968aa3-b398-5f4f-a348-a55b7deb6b11', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('spavaća soba') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7497bd56-3ab3-5990-97b7-343d2ca413d7', 'multiple_choice', 'Як хорватською «спальня»?', 'spavaća soba', '["perilica", "štednjak", "spavaća soba", "pećnica"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7497bd56-3ab3-5990-97b7-343d2ca413d7', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zahod') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4ca222ba-09a2-5ee9-8674-ec52417579e0', 'type_answer', 'Напишіть хорватською: «туалет»', 'zahod', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4ca222ba-09a2-5ee9-8674-ec52417579e0', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('ogledalo') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7bd0e3cb-15e9-5ed4-8535-fa6ee3f1820d', 'type_answer', 'Напишіть хорватською: «дзеркало»', 'ogledalo', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7bd0e3cb-15e9-5ed4-8535-fa6ee3f1820d', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('cdfedc14-a8a2-53bf-befa-e5c0f7b64134', 'sentence_builder', 'Складіть: «Ліворуч — спальня.»', 'Lijevo je spavaća soba.', '["soba.", "je", "spavaća", "Lijevo"]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'cdfedc14-a8a2-53bf-befa-e5c0f7b64134', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a552c5db-3aed-5fe2-a052-5b82a7c53a93', 'sentence_builder', 'Складіть: «А де туалет?»', 'A gdje je zahod?', '["zahod?", "A", "je", "gdje"]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a552c5db-3aed-5fe2-a052-5b82a7c53a93', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9b70f106-977c-54e0-b77d-e97d1fba08ef', 'listening', 'Прослухайте і складіть фразу', 'Pored kupaonice.', '["kupaonice.", "Pored"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9b70f106-977c-54e0-b77d-e97d1fba08ef', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8a330d9a-6b72-5e22-b4e6-7c4a058b8cfa', 'listening', 'Прослухайте і складіть фразу', 'Gdje je moja soba?', '["je", "soba?", "moja", "Gdje"]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8a330d9a-6b72-5e22-b4e6-7c4a058b8cfa', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8e4fa181-faa7-51e6-8d39-4c642780fea0', 'speaking', 'Де ванна кімната?', 'Gdje je kupaonica?', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8e4fa181-faa7-51e6-8d39-4c642780fea0', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f623678b-5382-5685-a698-b3d2a5232de1', 'speaking', 'У мене немає духовки.', 'Nemam pećnice.', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f623678b-5382-5685-a698-b3d2a5232de1', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('46411001-2c2d-5945-b3ad-f9777a78960c', v_lesson, 'Огляд квартири', 'Razgledavanje stana', 1271, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9120548b-09a7-59c0-ac94-baf27dd43ffd', '46411001-2c2d-5945-b3ad-f9777a78960c', 'Agentica', 'Ovo je hodnik. Lijevo je spavaća soba.', 'Це коридор. Ліворуч — спальня.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e2022114-23f0-5348-bd69-fe702197ceb0', '46411001-2c2d-5945-b3ad-f9777a78960c', 'Iryna', 'A gdje je zahod?', 'А де туалет?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0dabd6ae-9fc6-59e4-87a9-39b9d1196f35', '46411001-2c2d-5945-b3ad-f9777a78960c', 'Agentica', 'Pored kupaonice. Kupaonica ima i perilicu.', 'Поруч із ванною. У ванній є й пральна машина.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('066d7ddf-a852-5f9f-9b52-8a22caa34d46', '46411001-2c2d-5945-b3ad-f9777a78960c', 'Iryna', 'Super! Ima li kuhinja pećnicu?', 'Чудово! На кухні є духовка?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9cb2156f-b537-5898-ae46-1001d1266e89', '46411001-2c2d-5945-b3ad-f9777a78960c', 'Agentica', 'Ima, i štednjak i hladnjak.', 'Є, і плита, і холодильник.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('fc5dc2ce-0ea2-5ff4-b6fc-8e874728885b', v_lesson, 'Будинок із садом', 'Kuća s vrtom', 1272, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0010b51a-58e8-5026-9479-f2dda2fe9193', 'fc5dc2ce-0ea2-5ff4-b6fc-8e874728885b', 'Baka', 'Naša kuća ima vrt i dvorište.', 'У нашого будинку є сад і подвір’я.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('fb229c1b-55b1-5221-9aa9-29ffc6c506a2', 'fc5dc2ce-0ea2-5ff4-b6fc-8e874728885b', 'Unuk', 'Gdje je moja soba?', 'Де моя кімната?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c1d3d6cf-6e8d-5e04-bb15-da1b0151ca1c', 'fc5dc2ce-0ea2-5ff4-b6fc-8e874728885b', 'Baka', 'Gore, na katu, pored velikog ogledala.', 'Нагорі, на поверсі, біля великого дзеркала.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('76303ed5-beb5-5ba7-bdc9-adb064eed924', 'fc5dc2ce-0ea2-5ff4-b6fc-8e874728885b', 'Unuk', 'Super, vidim more!', 'Супер, я бачу море!', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- A0.7 · урок 31: Напої
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '77d640c4-4190-544a-8094-4e699f9a0a10';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A0.7: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Питальні слова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.7.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 31: Напої', 'Lekcija 31: Pića', '["Замовити напій: пиво, вино, чай", "Сказати, з цукром чи без", "Назвати посуд: склянка, чашка, пляшка"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('pivo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pivo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vino') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vino'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('čaj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'čaj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('šećer') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'šećer'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('čaša') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'čaša'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('šalica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'šalica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('boca') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'boca'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('mineralna voda') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'mineralna voda'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('limunada') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'limunada'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('led') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'led'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('topao') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'topao'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('95cea0bb-7d7b-5f72-b253-0b4554d7c855', 'fill_in_the_blank', '___ želite piti?', 'Što', '["Što", "Tko", "Kada", "Gdje"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '95cea0bb-7d7b-5f72-b253-0b4554d7c855', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('čaša') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('607629ba-16b4-56a7-b3ae-a6c100a058d6', 'multiple_choice', 'Що означає «čaša»?', 'склянка / келих', '["мінеральна вода", "лід", "склянка / келих", "пиво"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '607629ba-16b4-56a7-b3ae-a6c100a058d6', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('topao') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('926f2f04-ac97-5d58-8e32-caede012ab17', 'multiple_choice', 'Що означає «topao»?', 'теплий', '["мінеральна вода", "теплий", "лід", "пиво"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '926f2f04-ac97-5d58-8e32-caede012ab17', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('led') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c876d8a9-770d-5695-8742-c2454b6d2e10', 'multiple_choice', 'Як хорватською «лід»?', 'led', '["topao", "led", "šećer", "šalica"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c876d8a9-770d-5695-8742-c2454b6d2e10', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('boca') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('202f155f-aba0-5f2a-ad14-0c0ed51afb89', 'type_answer', 'Напишіть хорватською: «пляшка»', 'boca', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '202f155f-aba0-5f2a-ad14-0c0ed51afb89', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('vino') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1d541033-4faa-5bd6-bdc4-6d4531f72d08', 'type_answer', 'Напишіть хорватською: «вино»', 'vino', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1d541033-4faa-5bd6-bdc4-6d4531f72d08', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c96b631f-fce2-5981-a7ce-de801261db2c', 'sentence_builder', 'Складіть: «Одне пиво, будь ласка.»', 'Jedno pivo, molim.', '["pivo,", "Jedno", "molim."]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c96b631f-fce2-5981-a7ce-de801261db2c', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('076714d9-c049-56b0-98ce-f853dc5c23a9', 'sentence_builder', 'Складіть: «Ні, без цукру.»', 'Ne, bez šećera.', '["šećera.", "Ne,", "bez"]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '076714d9-c049-56b0-98ce-f853dc5c23a9', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('53597877-35a8-5e27-a5f7-75c2435efd05', 'listening', 'Прослухайте і складіть фразу', 'Za mene čašu bijelog vina.', '["čašu", "vina.", "Za", "bijelog", "mene"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '53597877-35a8-5e27-a5f7-75c2435efd05', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f875e905-6454-520d-a1b2-547e3bc6f87d', 'listening', 'Прослухайте і складіть фразу', 'Sa šećerom?', '["šećerom?", "Sa"]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f875e905-6454-520d-a1b2-547e3bc6f87d', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('45c60a5e-6a9a-5775-89dd-275af862b3ac', 'speaking', 'Склянку води, будь ласка.', 'Čašu vode, molim.', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '45c60a5e-6a9a-5775-89dd-275af862b3ac', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('214dd7be-07fe-5290-94c9-c4ad51a85c3d', 'speaking', 'Я не п’ю каву.', 'Ne pijem kavu.', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '214dd7be-07fe-5290-94c9-c4ad51a85c3d', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('65bc9874-d12c-58c8-a8d1-de4085276cc4', v_lesson, 'Що будете пити?', 'Što želite piti?', 1311, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5cd6296d-7388-51d4-b844-5d39994b6bc0', '65bc9874-d12c-58c8-a8d1-de4085276cc4', 'Konobar', 'Dobra večer! Što želite piti?', 'Добрий вечір! Що будете пити?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('11a4e7bd-d54a-5666-a389-531e31b99069', '65bc9874-d12c-58c8-a8d1-de4085276cc4', 'Oleg', 'Jedno pivo, molim. Veliko.', 'Одне пиво, будь ласка. Велике.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('05fa7c4e-aba6-5dd4-9146-fbe057fede60', '65bc9874-d12c-58c8-a8d1-de4085276cc4', 'Olga', 'Za mene čašu bijelog vina.', 'Мені келих білого вина.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6fc1abb8-e03a-566d-9633-fb3d314f5e3c', '65bc9874-d12c-58c8-a8d1-de4085276cc4', 'Konobar', 'Može. Još nešto?', 'Добре. Ще щось?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4206b832-7b15-5845-89e4-27c8cf729681', '65bc9874-d12c-58c8-a8d1-de4085276cc4', 'Olga', 'Bocu mineralne vode, molim.', 'Пляшку мінеральної води, будь ласка.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d6f866c4-8114-53f1-a31a-4838e2bc69a9', v_lesson, 'Чай чи кава?', 'Čaj ili kava?', 1312, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('eb8198c2-ef3e-551d-8c63-bb2d6942625d', 'd6f866c4-8114-53f1-a31a-4838e2bc69a9', 'Ana', 'Želiš li čaj ili kavu?', 'Хочеш чаю чи кави?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b9ed5949-27bd-5b12-aaaa-4f3777108d75', 'd6f866c4-8114-53f1-a31a-4838e2bc69a9', 'Iryna', 'Čaj, molim. Šalicu toplog čaja.', 'Чай, будь ласка. Чашку гарячого чаю.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('fd89d3a5-caf8-509b-bfde-1811e8d51962', 'd6f866c4-8114-53f1-a31a-4838e2bc69a9', 'Ana', 'Sa šećerom?', 'З цукром?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0d9edd6e-db79-514d-9833-0edd4cce7166', 'd6f866c4-8114-53f1-a31a-4838e2bc69a9', 'Iryna', 'Ne, bez šećera. A ti?', 'Ні, без цукру. А ти?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c986220f-4525-5cae-b850-4b1446bb3574', 'd6f866c4-8114-53f1-a31a-4838e2bc69a9', 'Ana', 'Ja pijem limunadu s ledom.', 'Я п’ю лимонад з льодом.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- A0.7 · урок 32: Вечеря
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A0.7: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Прикметники: узгодження з іменником' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.7.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 32: Вечеря', 'Lekcija 32: Večera', '["Назвати страви на вечерю", "Сказати, що смачно, солоно чи гостро", "Побажати смачного"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('večera') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'večera'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('piletina') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'piletina'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('svinjetina') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'svinjetina'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('riža') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'riža'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pomfrit') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pomfrit'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('umak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'umak'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kolač') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kolač'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dobar tek') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dobar tek'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ukusan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ukusan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('slan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'slan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ljut') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ljut'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('opet') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'opet'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('74985a41-5dc1-5f62-b697-44e6c611593b', 'fill_in_the_blank', 'Meso je jako ___.', 'ukusno', '["ukusan", "ukusni", "ukusna", "ukusno"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '74985a41-5dc1-5f62-b697-44e6c611593b', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('pomfrit') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6ae98389-fcd0-5035-9e36-ef4d3567934d', 'multiple_choice', 'Що означає «pomfrit»?', 'картопля фрі', '["смачний", "картопля фрі", "солоний", "соус"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6ae98389-fcd0-5035-9e36-ef4d3567934d', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('večera') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fba6373f-e6c5-508d-b194-feada5a74e62', 'multiple_choice', 'Що означає «večera»?', 'вечеря', '["свинина", "тістечко / пиріг", "соус", "вечеря"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fba6373f-e6c5-508d-b194-feada5a74e62', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('umak') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b2832ff6-78d0-5c4c-a039-440693a5a314', 'multiple_choice', 'Як хорватською «соус»?', 'umak', '["pomfrit", "umak", "večera", "opet"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b2832ff6-78d0-5c4c-a039-440693a5a314', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('opet') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5c7dd57f-9e1b-590c-b4cd-2076f001934a', 'type_answer', 'Напишіть хорватською: «знову»', 'opet', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5c7dd57f-9e1b-590c-b4cd-2076f001934a', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('riža') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('dcfaf2af-47a6-53ef-b77a-be54f515d4bf', 'type_answer', 'Напишіть хорватською: «рис»', 'riža', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'dcfaf2af-47a6-53ef-b77a-be54f515d4bf', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e89306ac-f80c-515c-9905-ead7b353d28e', 'sentence_builder', 'Складіть: «Курятина з рисом і салатом.»', 'Piletina s rižom i salatom.', '["Piletina", "rižom", "s", "i", "salatom."]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e89306ac-f80c-515c-9905-ead7b353d28e', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('20fb6fc4-11be-5e9b-97f7-160a190efd11', 'sentence_builder', 'Складіть: «М’ясо дуже смачне.»', 'Meso je jako ukusno.', '["ukusno.", "jako", "Meso", "je"]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '20fb6fc4-11be-5e9b-97f7-160a190efd11', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('54ab42df-da10-5ef9-827f-f1b24e79978d', 'listening', 'Прослухайте і складіть фразу', 'Opet piletina? Ima li pomfrita?', '["Opet", "li", "Ima", "pomfrita?", "piletina?"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '54ab42df-da10-5ef9-827f-f1b24e79978d', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9cfe8741-38f5-5791-b538-02ade6d6a634', 'listening', 'Прослухайте і складіть фразу', 'Dobar tek!', '["tek!", "Dobar"]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9cfe8741-38f5-5791-b538-02ade6d6a634', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8665a092-0e69-5526-9868-73851ff552ce', 'speaking', 'Що на вечерю?', 'Što je za večeru?', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8665a092-0e69-5526-9868-73851ff552ce', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c6d70608-fc7b-50f3-9260-ce4c06901238', 'speaking', 'Це дуже смачно!', 'Ovo je jako ukusno!', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c6d70608-fc7b-50f3-9260-ce4c06901238', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('97e35517-b05c-5f51-bfdb-ec4c268f8721', v_lesson, 'Що на вечерю?', 'Što je za večeru?', 1321, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3847a9c1-5965-55f9-9a85-2ea739931573', '97e35517-b05c-5f51-bfdb-ec4c268f8721', 'Sin', 'Mama, što je za večeru?', 'Мамо, що на вечерю?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('622e1cd5-5b94-5919-a55e-ce9010c6d6a3', '97e35517-b05c-5f51-bfdb-ec4c268f8721', 'Mama', 'Piletina s rižom i salatom.', 'Курятина з рисом і салатом.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f50b189b-caec-5db3-b376-1566f332c83c', '97e35517-b05c-5f51-bfdb-ec4c268f8721', 'Sin', 'Opet piletina? Ima li pomfrita?', 'Знову курятина? А картопля фрі є?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d0adfd1e-00ac-542b-9018-c40e0ffbbeb0', '97e35517-b05c-5f51-bfdb-ec4c268f8721', 'Mama', 'Nema. Ali ima kolača za desert!', 'Немає. Зате є тістечка на десерт!', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('56e2e241-e97f-5ae7-8dfe-e1529be05056', v_lesson, 'Смачного!', 'Dobar tek!', 1322, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('693c7cc0-9fa0-5157-9153-d4643d329607', '56e2e241-e97f-5ae7-8dfe-e1529be05056', 'Ana', 'Dobar tek!', 'Смачного!', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d54cca95-c5dd-5bf0-9fdc-81f3f4816195', '56e2e241-e97f-5ae7-8dfe-e1529be05056', 'Taras', 'Hvala! Meso je jako ukusno.', 'Дякую! М’ясо дуже смачне.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7d2bc32e-7196-5ccb-8d62-00678fe226c5', '56e2e241-e97f-5ae7-8dfe-e1529be05056', 'Ana', 'To je svinjetina u umaku. Nije previše ljuto?', 'Це свинина в соусі. Не надто гостро?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b2c00595-2297-5f2e-b8d6-a40cb7ea3f76', '56e2e241-e97f-5ae7-8dfe-e1529be05056', 'Taras', 'Nije, odlično je. Malo je slano, ali dobro.', 'Ні, чудово. Трохи солоне, але добре.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- A0.8 · урок 36: Скільки вам?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '0e925295-2766-5931-b031-2412682bc6f8';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A0.8: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Цей, той, он той: ovaj, taj, onaj' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.8.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 36: Скільки вам?', 'Lekcija 36: Koliko trebate?', '["Купити продукти на вагу: deka, pola kile", "Сказати «більше», «досить», «багато»", "Скласти список покупок"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('deka') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'deka'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kila') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kila'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pola') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pola'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('litra') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'litra'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('paket') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'paket'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('šunka') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'šunka'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dosta') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dosta'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('više') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'više'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('puno') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'puno'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('popis') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'popis'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8c05281d-7060-5376-bd79-386e42df9cd9', 'fill_in_the_blank', 'Pola kile ___ sira, molim.', 'ovog', '["ovaj", "ovog", "ova", "ovo"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8c05281d-7060-5376-bd79-386e42df9cd9', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('puno') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1f44cd05-ddba-5b86-b1d1-4836ad060108', 'multiple_choice', 'Що означає «puno»?', 'багато', '["список", "багато", "шинка", "більше"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1f44cd05-ddba-5b86-b1d1-4836ad060108', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dosta') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f3a60e9b-cfd0-5d16-9ef4-3f789c661a62', 'multiple_choice', 'Що означає «dosta»?', 'досить; достатньо', '["літр", "половина", "досить; достатньо", "шинка"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f3a60e9b-cfd0-5d16-9ef4-3f789c661a62', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kila') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e9a0afce-fadb-5589-8a5b-2cbeba1647ae', 'multiple_choice', 'Як хорватською «кілограм (розм.)»?', 'kila', '["šunka", "više", "kila", "pola"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e9a0afce-fadb-5589-8a5b-2cbeba1647ae', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('litra') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d574396e-e83b-5b30-a22f-82dc3d02aa68', 'type_answer', 'Напишіть хорватською: «літр»', 'litra', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd574396e-e83b-5b30-a22f-82dc3d02aa68', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('šunka') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6cc4a583-8ab3-557c-90f2-7c330b7f5528', 'type_answer', 'Напишіть хорватською: «шинка»', 'šunka', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6cc4a583-8ab3-557c-90f2-7c330b7f5528', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('54d76c5d-6a30-5612-aabd-941a25afdfab', 'sentence_builder', 'Складіть: «Півкіло шинки, будь ласка.»', 'Pola kile šunke, molim.', '["šunke,", "Pola", "molim.", "kile"]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '54d76c5d-6a30-5612-aabd-941a25afdfab', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('808e5dac-84c6-5798-88e7-4ab8d7b6cd05', 'sentence_builder', 'Складіть: «Ні, досить, дякую.»', 'Ne, dosta je, hvala.', '["je,", "hvala.", "Ne,", "dosta"]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '808e5dac-84c6-5798-88e7-4ab8d7b6cd05', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('57d69b97-c7e7-50fd-8345-51f987bfd99b', 'listening', 'Прослухайте і складіть фразу', 'Može malo više?', '["malo", "Može", "više?"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '57d69b97-c7e7-50fd-8345-51f987bfd99b', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('649b6bbf-a375-5174-84e0-9305b8baa0b2', 'listening', 'Прослухайте і складіть фразу', 'Koliko kruha?', '["kruha?", "Koliko"]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '649b6bbf-a375-5174-84e0-9305b8baa0b2', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1d6cea6a-9b4d-58a5-8e44-54bf040723ff', 'speaking', 'Літр молока, будь ласка.', 'Litru mlijeka, molim.', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1d6cea6a-9b4d-58a5-8e44-54bf040723ff', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a0431d94-6b25-5f55-880d-9c5b52122b89', 'speaking', 'Трохи більше, будь ласка.', 'Malo više, molim.', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a0431d94-6b25-5f55-880d-9c5b52122b89', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('25c87d8f-0401-566e-aeaa-729a354474c7', v_lesson, 'За прилавком', 'Za pultom', 1361, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ebd0d0da-a5d5-5f32-a99a-7b91de39aa22', '25c87d8f-0401-566e-aeaa-729a354474c7', 'Prodavačica', 'Izvolite?', 'Слухаю вас?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ba606c38-a448-50b4-9af1-32f9794eea37', '25c87d8f-0401-566e-aeaa-729a354474c7', 'Olena', 'Trideset deka ovog sira, molim.', 'Триста грамів цього сиру, будь ласка.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5a8d909c-861b-58d9-94ec-061752eda51b', '25c87d8f-0401-566e-aeaa-729a354474c7', 'Prodavačica', 'Može malo više?', 'Можна трохи більше?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e1dca58a-3705-58d6-98a2-d9935e66d50b', '25c87d8f-0401-566e-aeaa-729a354474c7', 'Olena', 'Može. I pola kile šunke.', 'Можна. І півкіло шинки.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('440caae0-7485-570e-9bd1-9a84c10dad63', '25c87d8f-0401-566e-aeaa-729a354474c7', 'Prodavačica', 'Još nešto?', 'Ще щось?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('af92abb8-527d-5e6d-977c-6dde6fb06cb6', '25c87d8f-0401-566e-aeaa-729a354474c7', 'Olena', 'Ne, dosta je, hvala.', 'Ні, досить, дякую.', 6) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1d1fa788-a9ec-5088-9774-ebebaa2da598', v_lesson, 'Список покупок', 'Popis za trgovinu', 1362, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('da88cbb4-88b0-571f-9834-d2583963cb02', '1d1fa788-a9ec-5088-9774-ebebaa2da598', 'Taras', 'Što trebamo?', 'Що нам треба?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('adbbb823-874e-5376-bf6f-35ad0e711ae3', '1d1fa788-a9ec-5088-9774-ebebaa2da598', 'Olena', 'Litru mlijeka, paket tjestenine i šest jaja.', 'Літр молока, пачку макаронів і шість яєць.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('14da4863-76c0-544a-9966-1d8885ed235b', '1d1fa788-a9ec-5088-9774-ebebaa2da598', 'Taras', 'Koliko kruha?', 'Скільки хліба?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b836bd2c-0a1a-516e-8ec5-fa009ac5129f', '1d1fa788-a9ec-5088-9774-ebebaa2da598', 'Olena', 'Jedan. I puno voća za djecu!', 'Одну хлібину. І багато фруктів для дітей!', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- A0.8 · урок 37: Кольори
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '288e7610-99c8-5696-989a-86f60ce38b0a';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A0.8: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Прикметники: узгодження з іменником' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.8.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 37: Кольори', 'Lekcija 37: Boje', '["Назвати основні кольори", "Попросити річ іншого кольору", "Узгоджувати колір з іменником: crna jakna, crni kaput"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('boja') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'boja'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('bijel') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'bijel'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('crn') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'crn'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zelen') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zelen'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('žut') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'žut'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('siv') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'siv'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('smeđ') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'smeđ'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ružičast') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ružičast'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('narančast') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'narančast'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ljubičast') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ljubičast'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('omiljen') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'omiljen'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8d58e884-581f-5a1d-94c0-8ff4dc7b6b68', 'fill_in_the_blank', 'Želim ___ jaknu.', 'crnu', '["crnu", "crni", "crna", "crn"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8d58e884-581f-5a1d-94c0-8ff4dc7b6b68', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('ljubičast') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('997e9ad5-dd55-5060-becc-3afb72e07eeb', 'multiple_choice', 'Що означає «ljubičast»?', 'фіолетовий', '["фіолетовий", "білий", "зелений", "помаранчевий"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '997e9ad5-dd55-5060-becc-3afb72e07eeb', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('boja') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('900210d6-bb8c-5021-b216-6861fd9bc67e', 'multiple_choice', 'Що означає «boja»?', 'колір', '["колір", "зелений", "жовтий", "чорний"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '900210d6-bb8c-5021-b216-6861fd9bc67e', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('crn') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e331e229-2177-53bf-9103-80e8e2e7652b', 'multiple_choice', 'Як хорватською «чорний»?', 'crn', '["žut", "siv", "omiljen", "crn"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e331e229-2177-53bf-9103-80e8e2e7652b', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zelen') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4f181407-5906-51a2-95f3-3a6c3e84d93b', 'type_answer', 'Напишіть хорватською: «зелений»', 'zelen', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4f181407-5906-51a2-95f3-3a6c3e84d93b', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('smeđ') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e64c2d42-6279-5843-82d6-4983968bd39f', 'type_answer', 'Напишіть хорватською: «коричневий»', 'smeđ', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e64c2d42-6279-5843-82d6-4983968bd39f', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5713174b-e3b6-5539-9523-2700bbef472d', 'sentence_builder', 'Складіть: «Який колір бажаєте?»', 'Koju boju želite?', '["Koju", "želite?", "boju"]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5713174b-e3b6-5539-9523-2700bbef472d', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3742f1ac-62b5-508c-8545-293416b2f996', 'sentence_builder', 'Складіть: «Сіра підійде.»', 'Siva je dobra.', '["Siva", "dobra.", "je"]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3742f1ac-62b5-508c-8545-293416b2f996', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7b5d570a-6c9d-546f-bfbb-ef5c376ed76f', 'listening', 'Прослухайте і складіть фразу', 'Zelenu ili žutu.', '["žutu.", "Zelenu", "ili"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7b5d570a-6c9d-546f-bfbb-ef5c376ed76f', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4f00468d-76d0-5ef0-9b9d-f9b016349175', 'listening', 'Прослухайте і складіть фразу', 'Nemamo crnu. Imamo sivu i smeđu.', '["Nemamo", "i", "Imamo", "crnu.", "sivu", "smeđu."]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4f00468d-76d0-5ef0-9b9d-f9b016349175', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('74ac687b-79c8-53c1-b72d-360dd573db8f', 'speaking', 'Мій улюблений колір — синій.', 'Moja omiljena boja je plava.', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '74ac687b-79c8-53c1-b72d-360dd573db8f', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4e3110e4-4f9f-517d-8920-a71ce61b0c32', 'speaking', 'У вас є біла?', 'Imate li bijelu?', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4e3110e4-4f9f-517d-8920-a71ce61b0c32', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a5b34d8f-b371-5876-833c-0107cdd2001e', v_lesson, 'Яку сукню?', 'Koju haljinu?', 1371, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c401d1b0-92fb-5fe0-881a-2ccc0e80b7d3', 'a5b34d8f-b371-5876-833c-0107cdd2001e', 'Prodavačica', 'Koju boju želite?', 'Який колір бажаєте?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1e5ff749-2e9f-5b31-9bcd-4501beb41d67', 'a5b34d8f-b371-5876-833c-0107cdd2001e', 'Oksana', 'Zelenu ili žutu.', 'Зелену або жовту.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('129a36e2-e092-597f-8d8a-fac5438ba40a', 'a5b34d8f-b371-5876-833c-0107cdd2001e', 'Prodavačica', 'Imamo zelenu, ali žute nema. Može ružičasta?', 'Є зелена, а жовтої немає. Може, рожева?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('eaf4e996-2bc7-5ec7-82dd-ff410eb21691', 'a5b34d8f-b371-5876-833c-0107cdd2001e', 'Oksana', 'Ne, hvala. Zelena je lijepa.', 'Ні, дякую. Зелена гарна.', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('fb49001c-7796-5711-a20b-c86bad904851', v_lesson, 'Шукаю куртку', 'Tražim jaknu', 1372, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8b5ea17f-af92-5dcf-a761-e366bb38ea56', 'fb49001c-7796-5711-a20b-c86bad904851', 'Andrij', 'Imate li ovu jaknu u crnoj boji?', 'У вас є ця куртка чорного кольору?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('45155fd8-f1ac-53dc-a8b8-5ac8bb286653', 'fb49001c-7796-5711-a20b-c86bad904851', 'Prodavač', 'Nemamo crnu. Imamo sivu i smeđu.', 'Чорної немає. Є сіра й коричнева.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('873721ca-50d6-598c-a5ce-7cb31422e52e', 'fb49001c-7796-5711-a20b-c86bad904851', 'Andrij', 'Siva je dobra. A bijele majice?', 'Сіра підійде. А білі футболки?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('07754991-7ebd-5143-86fd-04f7bc11065c', 'fb49001c-7796-5711-a20b-c86bad904851', 'Prodavač', 'Bijele su tamo, pored narančastih.', 'Білі он там, біля помаранчевих.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- A0.9 · урок 41: Місця в місті
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '0addd5be-230b-582f-baed-a5d18eb1d619';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A0.9: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Де? Прийменники місця' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.9.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 41: Місця в місті', 'Lekcija 41: Mjesta u gradu', '["Назвати місця в місті: пошта, банк, лікарня", "Запитати, чи є щось поруч", "Пояснити, де розташоване місце"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('trgovina') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'trgovina'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pošta') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pošta'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('banka') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'banka'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('bolnica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'bolnica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('park') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'park'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kino') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kino'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('knjižnica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'knjižnica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kafić') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kafić'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sladoled') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sladoled'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ugao') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ugao'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ac427f0b-2274-59b2-97dc-95a2ab41070e', 'fill_in_the_blank', 'Pošta je ___ puta banke.', 'preko', '["ispod", "iza", "pored", "preko"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ac427f0b-2274-59b2-97dc-95a2ab41070e', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('park') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('247f099b-8c87-5415-bab8-6a144980fabf', 'multiple_choice', 'Що означає «park»?', 'парк', '["морозиво", "лікарня", "парк", "кінотеатр"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '247f099b-8c87-5415-bab8-6a144980fabf', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sladoled') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('310639e2-4646-50cb-a438-98dd346a7da3', 'multiple_choice', 'Що означає «sladoled»?', 'морозиво', '["банк", "кафе / кав''ярня", "бібліотека", "морозиво"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '310639e2-4646-50cb-a438-98dd346a7da3', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kino') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5db99114-ed79-5344-a811-fee98e35f998', 'multiple_choice', 'Як хорватською «кінотеатр»?', 'kino', '["banka", "kino", "knjižnica", "park"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5db99114-ed79-5344-a811-fee98e35f998', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ugao') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a603f59e-230b-56f0-9387-360a752c8b3e', 'type_answer', 'Напишіть хорватською: «ріг (вулиці); кут»', 'ugao', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a603f59e-230b-56f0-9387-360a752c8b3e', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('bolnica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1127efde-09ce-5e64-8930-3d0219f9399f', 'type_answer', 'Напишіть хорватською: «лікарня»', 'bolnica', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1127efde-09ce-5e64-8930-3d0219f9399f', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('06a3ac4d-b5b4-5c73-bc8d-91288b6da421', 'sentence_builder', 'Складіть: «Аптека за рогом.»', 'Ljekarna je iza ugla.', '["je", "iza", "Ljekarna", "ugla."]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '06a3ac4d-b5b4-5c73-bc8d-91288b6da421', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c5fd38e7-c4ab-55ac-96b9-ce3fb53a723f', 'sentence_builder', 'Складіть: «Підемо в парк чи в кіно?»', 'Idemo u park ili kino?', '["ili", "u", "kino?", "Idemo", "park"]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c5fd38e7-c4ab-55ac-96b9-ce3fb53a723f', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f1596016-4900-563a-ba4c-ce1db999b0c8', 'listening', 'Прослухайте і складіть фразу', 'A bolnica?', '["bolnica?", "A"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f1596016-4900-563a-ba4c-ce1db999b0c8', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('cecef4cc-6703-5410-b254-b01b585d181f', 'listening', 'Прослухайте і складіть фразу', 'Knjižnica nije otvorena nedjeljom.', '["otvorena", "Knjižnica", "nije", "nedjeljom."]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'cecef4cc-6703-5410-b254-b01b585d181f', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('89882599-2057-59ae-8c4d-5fddaa160169', 'speaking', 'Де лікарня?', 'Gdje je bolnica?', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '89882599-2057-59ae-8c4d-5fddaa160169', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('dafa156f-b1cc-5f4f-aab2-db9203907676', 'speaking', 'Тут поруч є банк?', 'Je li blizu neka banka?', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'dafa156f-b1cc-5f4f-aab2-db9203907676', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2afb6d94-f8a0-5665-9122-584599419d9c', v_lesson, 'Що тут поруч?', 'Što je blizu?', 1411, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e6a11df3-7d60-5173-9c9e-986819628970', '2afb6d94-f8a0-5665-9122-584599419d9c', 'Iryna', 'Oprostite, je li blizu neka trgovina?', 'Вибачте, тут поруч є якийсь магазин?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d9ef93e8-0b0f-556c-a0ff-934ad2b62a3b', '2afb6d94-f8a0-5665-9122-584599419d9c', 'Gospođa', 'Jest, pored pošte, a pošta je preko puta banke.', 'Так, біля пошти, а пошта навпроти банку.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6218779d-2486-57f0-b5e9-aeddf7f5a7ab', '2afb6d94-f8a0-5665-9122-584599419d9c', 'Iryna', 'A bolnica?', 'А лікарня?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3d3ed2b7-f6f4-561b-8247-70d0bff36429', '2afb6d94-f8a0-5665-9122-584599419d9c', 'Gospođa', 'Bolnica je daleko. Ali ljekarna je ovdje, iza ugla.', 'Лікарня далеко. Але аптека тут, за рогом.', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('570d9a25-53f8-5c73-ac0e-e535fe9130ab', v_lesson, 'Вихідні з дітьми', 'Vikend s djecom', 1412, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ee8fcd0d-171e-576d-8587-00fc718d648f', '570d9a25-53f8-5c73-ac0e-e535fe9130ab', 'Tata', 'Idemo u park ili u kino?', 'Підемо в парк чи в кіно?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('dcbc5663-140c-56b4-b27a-27694ed07b8d', '570d9a25-53f8-5c73-ac0e-e535fe9130ab', 'Kći', 'U park! A onda u knjižnicu.', 'У парк! А потім у бібліотеку.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('fd2bed3e-8977-5d58-af4e-1ebf79bd6849', '570d9a25-53f8-5c73-ac0e-e535fe9130ab', 'Tata', 'Knjižnica nije otvorena nedjeljom.', 'Бібліотека в неділю не працює.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('82f8a99c-1c43-5d38-b26b-b3c189cd4494', '570d9a25-53f8-5c73-ac0e-e535fe9130ab', 'Kći', 'Onda kafić i sladoled!', 'Тоді кафе й морозиво!', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- A0.9 · урок 42: Як пройти?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '55af257e-e4d1-51ed-9637-388a7e0b4baf';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A0.9: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Порядок слів' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.9.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 42: Як пройти?', 'Lekcija 42: Kako doći do…?', '["Запитати дорогу", "Зрозуміти: прямо, поверніть, перейдіть міст", "Вирішити: пішки чи трамваєм"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('skrenuti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'skrenuti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('semafor') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'semafor'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('most') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'most'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prijeći') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prijeći'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('raskrižje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'raskrižje'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pješački prijelaz') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pješački prijelaz'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tramvaj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tramvaj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('bicikl') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'bicikl'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('auto') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'auto'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('gužva') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'gužva'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7c2481c7-9c22-53e3-ad4f-e5a6d68bb326', 'fill_in_the_blank', 'Gdje ___ stanica?', 'je', '["je", "se", "sam", "li"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7c2481c7-9c22-53e3-ad4f-e5a6d68bb326', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('semafor') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('db6c7eea-6ca2-5bbe-9b08-257736a33704', 'multiple_choice', 'Що означає «semafor»?', 'світлофор', '["повернути (ліворуч, праворуч)", "світлофор", "затор; тиснява", "перейти"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'db6c7eea-6ca2-5bbe-9b08-257736a33704', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('raskrižje') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d53434b7-439c-566e-82da-b2418b33cbea', 'multiple_choice', 'Що означає «raskrižje»?', 'перехрестя', '["велосипед", "перейти", "перехрестя", "затор; тиснява"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd53434b7-439c-566e-82da-b2418b33cbea', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('most') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d41b6333-ac3e-545b-ac52-1d8418260ce5', 'multiple_choice', 'Як хорватською «міст»?', 'most', '["raskrižje", "most", "semafor", "pješački prijelaz"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd41b6333-ac3e-545b-ac52-1d8418260ce5', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prijeći') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('bd7d644e-2256-56f6-893b-8b9003780dc2', 'type_answer', 'Напишіть хорватською: «перейти»', 'prijeći', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'bd7d644e-2256-56f6-893b-8b9003780dc2', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('auto') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('daa47646-cdec-5672-80fc-823a4f3fe8bc', 'type_answer', 'Напишіть хорватською: «автомобіль»', 'auto', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'daa47646-cdec-5672-80fc-823a4f3fe8bc', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e8a92a8b-48c1-5fbf-82e5-fb983cc80030', 'sentence_builder', 'Складіть: «Поверніть праворуч.»', 'Skrenite desno.', '["desno.", "Skrenite"]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e8a92a8b-48c1-5fbf-82e5-fb983cc80030', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('790318e6-03d5-5fc0-849d-de983c44327d', 'sentence_builder', 'Складіть: «Де пішохідний перехід?»', 'Gdje je pješački prijelaz?', '["Gdje", "je", "prijelaz?", "pješački"]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '790318e6-03d5-5fc0-849d-de983c44327d', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9d0d7df7-6ad0-5a3f-b444-90c56d8526a5', 'listening', 'Прослухайте і складіть фразу', 'Je li to daleko?', '["daleko?", "li", "Je", "to"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9d0d7df7-6ad0-5a3f-b444-90c56d8526a5', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('cc49811b-6956-55a7-b6c7-715731aac2cd', 'listening', 'Прослухайте і складіть фразу', 'Tramvajem, autom je gužva.', '["gužva.", "Tramvajem,", "je", "autom"]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'cc49811b-6956-55a7-b6c7-715731aac2cd', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b0759edd-3388-5f06-9c09-b616238046af', 'speaking', 'Як мені дійти до центру?', 'Kako mogu doći do centra?', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b0759edd-3388-5f06-9c09-b616238046af', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('22ebae96-98ff-56a8-8256-f80412576db7', 'speaking', 'Ідіть прямо.', 'Idite ravno.', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '22ebae96-98ff-56a8-8256-f80412576db7', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d4f2cf68-ccff-5a81-90a2-4dbe63e01d17', v_lesson, 'Як дійти до вокзалу?', 'Kako do kolodvora?', 1421, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('015db466-9578-5548-ab87-34f6ea5c6072', 'd4f2cf68-ccff-5a81-90a2-4dbe63e01d17', 'Turist', 'Oprostite, kako mogu doći do kolodvora?', 'Вибачте, як мені дійти до вокзалу?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5147e2ee-6a60-551d-ad4a-c32ae745b203', 'd4f2cf68-ccff-5a81-90a2-4dbe63e01d17', 'Gospodin', 'Idite ravno do semafora, pa skrenite desno.', 'Ідіть прямо до світлофора, потім поверніть праворуч.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2fe5a5bb-2e29-5e5c-b0dc-37343cd71f8e', 'd4f2cf68-ccff-5a81-90a2-4dbe63e01d17', 'Turist', 'Je li to daleko?', 'Це далеко?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cb8e1b3d-f538-5465-a401-a1036b428b71', 'd4f2cf68-ccff-5a81-90a2-4dbe63e01d17', 'Gospodin', 'Nije. Prijeđite most i tamo je.', 'Ні. Перейдіть міст — і ви там.', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1b3d66dc-fc4a-541f-8483-86c35013b680', v_lesson, 'Пішки чи трамваєм?', 'Pješice ili tramvajem?', 1422, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('bbfe3167-e3c1-5b72-a0be-c8f6a9cb759b', '1b3d66dc-fc4a-541f-8483-86c35013b680', 'Oksana', 'Idemo pješice ili tramvajem?', 'Ідемо пішки чи трамваєм?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3690f0f2-0593-5447-9fbf-400a3cb0da50', '1b3d66dc-fc4a-541f-8483-86c35013b680', 'Ivan', 'Tramvajem, autom je gužva. Stanica je na raskrižju.', 'Трамваєм, машиною — затор. Зупинка на перехресті.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7a52c420-cd5c-5ff4-95c3-2f8f0d14e197', '1b3d66dc-fc4a-541f-8483-86c35013b680', 'Oksana', 'Gdje je pješački prijelaz?', 'Де пішохідний перехід?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cd3f607f-9eed-548e-b842-fb9ba97c3b26', '1b3d66dc-fc4a-541f-8483-86c35013b680', 'Ivan', 'Tamo, kod semafora. Pazi na bicikle!', 'Он там, біля світлофора. Обережно, велосипеди!', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- A0.10 · урок 46: Документи в MUP
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '19df3241-90f3-5450-94ac-642d79fb2869';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A0.10: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Питальні слова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.10.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 46: Документи в MUP', 'Lekcija 46: U MUP-u', '["Стати в чергу й узяти номерок", "Подати документи на віконці", "Зрозуміти, яких документів бракує"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('MUP') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'MUP'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('boravak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'boravak'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('red') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'red'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('čekati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'čekati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dokument') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dokument'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('fotografija') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'fotografija'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('OIB') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'OIB'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kopija') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kopija'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('šalter') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'šalter'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sljedeći') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sljedeći'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d25d2478-9906-50ed-8fcf-3261efe9ab61', 'fill_in_the_blank', '___ dugo čekamo?', 'Koliko', '["Tko", "Koliko", "Kada", "Gdje"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd25d2478-9906-50ed-8fcf-3261efe9ab61', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('dokument') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f4d8645a-dbf3-50fb-8c06-7fa8bdc9405b', 'multiple_choice', 'Що означає «dokument»?', 'документ', '["Ідентифікаційний номер (OIB)", "документ", "чекати", "черга"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f4d8645a-dbf3-50fb-8c06-7fa8bdc9405b', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('čekati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4c850025-06d6-5695-a399-569b12843f7b', 'multiple_choice', 'Що означає «čekati»?', 'чекати', '["чекати", "МВС / Міністерство внутрішніх справ", "черга", "Ідентифікаційний номер (OIB)"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4c850025-06d6-5695-a399-569b12843f7b', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('boravak') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('319729a7-a14b-59af-b510-aca1214af138', 'multiple_choice', 'Як хорватською «перебування; проживання»?', 'boravak', '["red", "boravak", "šalter", "čekati"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '319729a7-a14b-59af-b510-aca1214af138', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kopija') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c952acc3-a3db-550e-895b-10b4ecc12c90', 'type_answer', 'Напишіть хорватською: «копія»', 'kopija', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c952acc3-a3db-550e-895b-10b4ecc12c90', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('šalter') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2a0f2e1a-a2c4-5d85-8255-eb04f10d9e3d', 'type_answer', 'Напишіть хорватською: «віконце (в установі)»', 'šalter', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2a0f2e1a-a2c4-5d85-8255-eb04f10d9e3d', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c316ede0-c77d-5fbb-9b46-6ae072480137', 'sentence_builder', 'Складіть: «Візьміть номерок в автоматі.»', 'Uzmite broj na automatu.', '["automatu.", "na", "Uzmite", "broj"]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c316ede0-c77d-5fbb-9b46-6ae072480137', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('52472667-43a9-5eed-a38a-e66661cc8afb', 'sentence_builder', 'Складіть: «Мені потрібна копія паспорта.»', 'Trebam kopiju putovnice.', '["putovnice.", "Trebam", "kopiju"]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '52472667-43a9-5eed-a38a-e66661cc8afb', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('200ee9fa-4588-556a-af34-582350aa3141', 'listening', 'Прослухайте і складіть фразу', 'Koliko dugo čekamo?', '["čekamo?", "dugo", "Koliko"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '200ee9fa-4588-556a-af34-582350aa3141', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6e8923da-97e1-5b00-b0fd-c9d233b89962', 'listening', 'Прослухайте і складіть фразу', 'Preko puta, u knjižari.', '["knjižari.", "Preko", "u", "puta,"]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6e8923da-97e1-5b00-b0fd-c9d233b89962', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8fad7be3-f5e6-5d1a-9c6d-a493c30144bc', 'speaking', 'Де черга?', 'Gdje je red?', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8fad7be3-f5e6-5d1a-9c6d-a493c30144bc', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('238e12ac-28b8-5663-b431-86bc2e0cecfd', 'speaking', 'Ось мій паспорт.', 'Evo moje putovnice.', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '238e12ac-28b8-5663-b431-86bc2e0cecfd', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d773d341-a0e7-53e6-a537-7d306ac5d525', v_lesson, 'У черзі', 'U redu', 1461, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6170e5c2-eccc-5f12-973f-658e9bd25dec', 'd773d341-a0e7-53e6-a537-7d306ac5d525', 'Oleg', 'Oprostite, je li ovo red za boravak?', 'Вибачте, це черга щодо дозволу на проживання?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('70c7af3d-7b52-555d-9931-9fac2dad3931', 'd773d341-a0e7-53e6-a537-7d306ac5d525', 'Gospođa', 'Jest. Uzmite broj na automatu.', 'Так. Візьміть номерок в автоматі.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f944aae1-72a0-58d3-a3cf-2723a46b07a8', 'd773d341-a0e7-53e6-a537-7d306ac5d525', 'Oleg', 'Koliko dugo čekamo?', 'Скільки ми чекаємо?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f2b74202-0e44-5003-b712-0d6244f0f005', 'd773d341-a0e7-53e6-a537-7d306ac5d525', 'Gospođa', 'Oko sat vremena. Ja čekam od osam.', 'Близько години. Я чекаю з восьмої.', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cc192c9d-ef71-5c2e-9a9a-37f77d11f394', v_lesson, 'На віконці', 'Na šalteru', 1462, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f4c45745-eef2-522d-9d89-6789afa4d175', 'cc192c9d-ef71-5c2e-9a9a-37f77d11f394', 'Službenica', 'Sljedeći! Izvolite, Vaše dokumente.', 'Наступний! Прошу ваші документи.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('66afa2bf-53de-58e1-95ad-a388aa8f0554', 'cc192c9d-ef71-5c2e-9a9a-37f77d11f394', 'Oleg', 'Evo putovnice, fotografije i OIB-a.', 'Ось паспорт, фотографія й OIB.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f1bd0204-f4a3-5c03-b082-150bbac16347', 'cc192c9d-ef71-5c2e-9a9a-37f77d11f394', 'Službenica', 'Trebam i kopiju putovnice.', 'Мені потрібна ще копія паспорта.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('90f54627-56bf-54fc-825e-27bde18df600', 'cc192c9d-ef71-5c2e-9a9a-37f77d11f394', 'Oleg', 'Nemam kopiju. Gdje je mogu napraviti?', 'У мене немає копії. Де її можна зробити?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('38e10c2b-d65d-554a-a259-3bef9af5c1d6', 'cc192c9d-ef71-5c2e-9a9a-37f77d11f394', 'Službenica', 'Preko puta, u knjižari.', 'Навпроти, у книгарні.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- A0.10 · урок 47: Не можу знайти гаманець
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'd2689a70-cb73-515f-9d81-6bb0f0fc1cff';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A0.10: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = 'Заперечення і питання з «biti»' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A0.10.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 47: Не можу знайти гаманець', 'Lekcija 47: Ne mogu naći novčanik', '["Сказати, що ви не можете щось знайти", "Заявити в поліцію", "Описати річ: колір, матеріал"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('novčanik') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'novčanik'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('naći') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'naći'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('policija') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'policija'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('policajac') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'policajac'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prijaviti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prijaviti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('osobna iskaznica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'osobna iskaznica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('unutra') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'unutra'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kožni') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kožni'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pomoć') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pomoć'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('odmah') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'odmah'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b0591043-238a-5f66-977d-8575355a6982', 'fill_in_the_blank', 'Novčanik ___ u torbi.', 'nije', '["ne", "nisam", "nema", "nije"]'::jsonb, 'A0', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b0591043-238a-5f66-977d-8575355a6982', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('prijaviti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4c794594-b791-5ce6-b08c-753a943487b4', 'multiple_choice', 'Що означає «prijaviti»?', 'зареєструвати; повідомити', '["всередині / всередину", "гаманець", "посвідчення особи", "зареєструвати; повідомити"]'::jsonb, 'A0', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4c794594-b791-5ce6-b08c-753a943487b4', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('naći') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('28151020-5482-5119-845a-698ac7490689', 'multiple_choice', 'Що означає «naći»?', 'знайти', '["знайти", "одразу", "зареєструвати; повідомити", "поліція"]'::jsonb, 'A0', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '28151020-5482-5119-845a-698ac7490689', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('policija') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8a100a0e-b1b3-550e-85dc-6d70cee631cf', 'multiple_choice', 'Як хорватською «поліція»?', 'policija', '["kožni", "odmah", "osobna iskaznica", "policija"]'::jsonb, 'A0', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8a100a0e-b1b3-550e-85dc-6d70cee631cf', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kožni') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9b3f0087-c903-5ea4-b792-ef61d1b25152', 'type_answer', 'Напишіть хорватською: «шкіряний»', 'kožni', null, 'A0', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9b3f0087-c903-5ea4-b792-ef61d1b25152', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('odmah') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('19f7aa5b-be40-5f27-a380-d24106b41891', 'type_answer', 'Напишіть хорватською: «одразу»', 'odmah', null, 'A0', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '19f7aa5b-be40-5f27-a380-d24106b41891', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('21b1a660-f77e-51d4-83d8-9b7d42d6e838', 'sentence_builder', 'Складіть: «Не можу знайти гаманець!»', 'Ne mogu naći novčanik!', '["Ne", "novčanik!", "mogu", "naći"]'::jsonb, 'A0', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '21b1a660-f77e-51d4-83d8-9b7d42d6e838', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e3af52aa-0568-5501-bc36-f42882084c82', 'sentence_builder', 'Складіть: «Хочу про це заявити.»', 'Želim to prijaviti.', '["Želim", "prijaviti.", "to"]'::jsonb, 'A0', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e3af52aa-0568-5501-bc36-f42882084c82', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a3011808-14c3-50d0-b651-d000d8088cce', 'listening', 'Прослухайте і складіть фразу', 'Nije u torbi?', '["u", "torbi?", "Nije"]'::jsonb, 'A0', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a3011808-14c3-50d0-b651-d000d8088cce', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a624375d-f341-567d-b309-adbc80cbf3ce', 'listening', 'Прослухайте і складіть фразу', 'Kakav je novčanik?', '["je", "novčanik?", "Kakav"]'::jsonb, 'A0', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a624375d-f341-567d-b309-adbc80cbf3ce', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('653c0ca2-b3d4-5ac1-b558-76fbdccf21f3', 'speaking', 'Мені потрібна допомога поліції.', 'Trebam pomoć policije.', null, 'A0', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '653c0ca2-b3d4-5ac1-b558-76fbdccf21f3', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b522b7a6-3a90-5020-9c91-e3f9d26da5f4', 'speaking', 'Мого паспорта немає.', 'Nema moje putovnice.', null, 'A0', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b522b7a6-3a90-5020-9c91-e3f9d26da5f4', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6e6293e8-da2f-539c-9b4e-b2999c57bbfa', v_lesson, 'Де мій гаманець?', 'Gdje je moj novčanik?', 1471, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7fa8c7aa-2609-5598-bc38-3fdd149fa405', '6e6293e8-da2f-539c-9b4e-b2999c57bbfa', 'Taras', 'Ne mogu naći novčanik!', 'Не можу знайти гаманець!', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('018c31f4-7a17-5efb-b68e-2f1587870fd7', '6e6293e8-da2f-539c-9b4e-b2999c57bbfa', 'Olena', 'Nije u torbi?', 'Його немає в сумці?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9f86082b-c67c-5f03-aa56-5d5cbac4cd8d', '6e6293e8-da2f-539c-9b4e-b2999c57bbfa', 'Taras', 'Nije. Ni u jakni. Unutra su kartice i osobna iskaznica!', 'Ні. І в куртці немає. А в ньому картки й посвідчення особи!', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('33e5243e-4b0e-5b05-bb3a-e0fb2568e4e9', '6e6293e8-da2f-539c-9b4e-b2999c57bbfa', 'Olena', 'Idemo odmah u policiju.', 'Ходімо одразу в поліцію.', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cbc6dea4-16b3-5fb0-a289-0665980710e7', v_lesson, 'У поліції', 'U policiji', 1472, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_a0_v3') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('592fc37a-460b-52d9-9ff3-35815b028679', 'cbc6dea4-16b3-5fb0-a289-0665980710e7', 'Policajac', 'Izvolite, kako Vam mogu pomoći?', 'Прошу, чим можу допомогти?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e5df59df-31ae-5ec3-842a-39c66537aaaa', 'cbc6dea4-16b3-5fb0-a289-0665980710e7', 'Taras', 'Nema mog novčanika. Želim to prijaviti.', 'Мого гаманця немає. Хочу про це заявити.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c990b23b-93f3-5332-b168-b848bf5ccd9c', 'cbc6dea4-16b3-5fb0-a289-0665980710e7', 'Policajac', 'Kakav je novčanik?', 'Який гаманець?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9ee8cbdc-79f9-5a6d-8919-e3bbabc7e26c', 'cbc6dea4-16b3-5fb0-a289-0665980710e7', 'Taras', 'Smeđi, kožni. Unutra nema novca, samo dokumenti.', 'Коричневий, шкіряний. Грошей там немає, тільки документи.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('797a32b0-2f4b-5303-86f1-3b9b4ca2a5ec', 'cbc6dea4-16b3-5fb0-a289-0665980710e7', 'Policajac', 'Dobro. Ispunite ovaj obrazac.', 'Добре. Заповніть цей бланк.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.');
end $$;

-- 5. Наскрізні номери уроків A0 («Урок N: …» / «Lekcija N: …»); стара назва — у content_versions
do $$
declare r record; v_payload jsonb; v_new_ua text; v_new_hr text;
begin
  for r in select * from (values
    ('c0000000-0000-0000-0000-000000000001'::uuid, 1),
    ('d8cffb46-8a62-538a-b864-e227a6d8b863'::uuid, 2),
    ('a17f2f16-1be9-50f2-8e16-2bebfcced33b'::uuid, 3),
    ('2b6ed342-cc80-5bd9-baf0-b66109624d62'::uuid, 5),
    ('04167753-db83-5163-a91c-9f71dac18ab5'::uuid, 6),
    ('2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'::uuid, 7),
    ('c0941bd8-57b5-5e7e-981f-9be423f24208'::uuid, 10),
    ('4c5db9c0-aa58-55c5-b647-7f7cfc8396c2'::uuid, 11),
    ('427e5058-7381-58a0-8f21-bd170866dbae'::uuid, 12),
    ('8e372ece-ae10-50ae-9cf3-07b52ef2f72d'::uuid, 15),
    ('39b1e31f-b573-5000-9713-1660688c3cc9'::uuid, 16),
    ('036fc4fb-1bf2-5100-9fd0-6f6a612554a1'::uuid, 17),
    ('4e003796-1ce0-5a02-8a2d-59a0de38f3dd'::uuid, 20),
    ('f9ca38e4-3a61-56a6-b5f5-060933516c9a'::uuid, 21),
    ('2b0e9742-99e1-57e1-a574-67ffb78d2607'::uuid, 22),
    ('78f28f85-dd8b-5e81-8a52-1b2dbce4eb34'::uuid, 24),
    ('0ecb6f19-2630-533d-9f1b-85102442af08'::uuid, 25),
    ('1436c20e-0aea-550a-b66d-fb3149a1c2e2'::uuid, 26),
    ('7bbaf7ff-10bb-512a-91c5-798b59ec92a5'::uuid, 28),
    ('c9e045fb-91ff-52a2-9916-1b698d30eb19'::uuid, 29),
    ('8b30911e-4e57-5648-9ff6-bd11c1b0e27e'::uuid, 30),
    ('e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0'::uuid, 33),
    ('b01e2f67-3e7a-5ab6-99bb-fae374f431e0'::uuid, 34),
    ('28913ad6-490f-5d89-bad7-9b303c673fcd'::uuid, 35),
    ('e0b9d742-0418-597b-9482-b6e2d82469da'::uuid, 38),
    ('1e0384e5-6097-56ed-ab56-cf530f02ab73'::uuid, 39),
    ('e5b81eb1-8ea8-5ff4-a987-e5e46421302b'::uuid, 40),
    ('edbae9ca-c4f4-575d-b876-d50b0a1fd9b5'::uuid, 43),
    ('fbc71f82-e715-5bab-a990-b8542fb0fe01'::uuid, 44),
    ('b095637e-0644-507e-8f3d-d323483dd3e4'::uuid, 45)
  ) as t(id, n) loop
    select to_jsonb(l), regexp_replace(l.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':'),
           regexp_replace(l.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':')
      into v_payload, v_new_ua, v_new_hr
      from public.lessons l where l.id = r.id;
    if v_payload is null then continue; end if;
    if v_new_ua is not distinct from (v_payload->>'title_ua') and v_new_hr is not distinct from (v_payload->>'title_hr') then continue; end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'curriculum_a0_v3: новий номер уроку ' || r.n);
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;

-- 6. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_lessons int; v_short int; v_bad_title int;
begin
  select count(*) into v_lessons from public.lessons where level_code = 'A0' and status = 'PUBLISHED';
  select count(*) into v_short from public.lessons l where l.level_code = 'A0' and l.status = 'PUBLISHED'
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') < 12;
  select count(*) into v_bad_title from (
     select l.title_ua, row_number() over (order by m.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where l.level_code = 'A0' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%';
  if v_lessons < 47 then raise exception 'A0: уроків %, очікувалось 47', v_lessons; end if;
  if v_short > 0 then raise exception 'A0: % уроків мають менше 12 вправ', v_short; end if;
  if v_bad_title > 0 then raise exception 'A0: % уроків з неправильним номером у назві', v_bad_title; end if;
  raise notice 'Готово: A0 — % уроків', v_lessons;
end $$;

commit;
