-- =====================================================================
-- Програма A1 · curriculum_a1_v1 · 2026-10-13
-- Згенеровано: python3 scripts/gen_curriculum_a1.py (не редагуйте вручну).
--
--   * 10 модулів A1 (вже були як DRAFT) → опис, юніт, статус PUBLISHED.
--   * 13 граматичних тем A1 → 39 правил з прикладами, статус PUBLISHED.
--   * 49 уроків (3–5 у модулі): 10–14 слів, 2 діалоги (474 реплік разом), граматика, 588 вправ разом (по 12), ~12 хв.
--   * Нові слова: 104. Виправлення словника: 11 переклади + 3 написання леми (старі — у content_versions).
--   * Статус PUBLISHED: бета, як A0 (запит власника 2026-10-13). Носій ще не перевіряв.
--   * Наявні дані не видаляються. Повторний запуск безпечний.
--   * Потрібна міграція M13 (типи вправ type_answer і speaking).
-- =====================================================================

begin;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'exercises_type_check'
                 and pg_get_constraintdef(oid) like '%speaking%') then
    raise exception 'Спершу запустіть міграцію M13 (20261013140000_m13_exercise_types.sql)';
  end if;
  if (select count(*) from public.modules where level_code = 'A1') < 10 then
    raise exception 'Немає 10 модулів A1 (каркас) — спершу curriculum_a0_v1';
  end if;
end $$;

-- 1. Нові слова A1 (яких ще немає у словнику)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kilogram', 'kilogram', 'hr', 'noun', 'A1', 'кілограм', 'core', '{"gender": "m"}'::jsonb, '["Kilogram jabuka košta dva eura."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pušiti', 'pusiti', 'hr', 'verb', 'A1', 'курити', 'core', '{"aspect": "ipfv"}'::jsonb, '["Ovdje se ne smije pušiti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uzimati', 'uzimati', 'hr', 'verb', 'A1', 'брати; приймати (ліки)', 'core', '{"aspect": "ipfv"}'::jsonb, '["Lijek uzimajte poslije jela."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dnevno', 'dnevno', 'hr', 'adverb', 'A1', 'щодня; на день', 'core', '{}'::jsonb, '["Pijte dvije litre vode dnevno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('večeras', 'veceras', 'hr', 'adverb', 'A1', 'сьогодні ввечері', 'core', '{}'::jsonb, '["Večeras idemo u kino."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rado', 'rado', 'hr', 'adverb', 'A1', 'охоче; із задоволенням', 'core', '{}'::jsonb, '["Rado čitam knjige na hrvatskom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nogomet', 'nogomet', 'hr', 'noun', 'A1', 'футбол', 'core', '{"gender": "m"}'::jsonb, '["Nedjeljom igramo nogomet u parku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kupati se', 'kupati se', 'hr', 'verb', 'A1', 'купатися', 'core', '{"aspect": "ipfv"}'::jsonb, '["Ljeti se kupamo u moru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Božić', 'bozic', 'hr', 'noun', 'A1', 'Різдво', 'core', '{"gender": "m"}'::jsonb, '["Za Božić je cijela obitelj zajedno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('blagdan', 'blagdan', 'hr', 'noun', 'A1', 'свято', 'core', '{"gender": "m"}'::jsonb, '["Uskrs je veliki blagdan u Hrvatskoj."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kućanski poslovi', 'kucanski poslovi', 'hr', 'phrase', 'A1', 'домашні справи', 'collocation', '{}'::jsonb, '["Kućanske poslove dijelimo napola."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('suđe', 'sude', 'hr', 'noun', 'A1', 'посуд', 'core', '{"gender": "n"}'::jsonb, '["Tko danas pere suđe?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rublje', 'rublje', 'hr', 'noun', 'A1', 'білизна (для прання)', 'core', '{"gender": "n"}'::jsonb, '["Rublje se suši na balkonu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prašina', 'prasina', 'hr', 'noun', 'A1', 'пил', 'core', '{"gender": "f"}'::jsonb, '["Na polici ima puno prašine."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('cimerica', 'cimerica', 'hr', 'noun', 'A1', 'сусідка по квартирі', 'core', '{"gender": "f"}'::jsonb, '["Moja cimerica je iz Zadra."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('umiti se', 'umiti se', 'hr', 'verb', 'A1', 'умитися', 'core', '{"aspect": "pfv"}'::jsonb, '["Umij se hladnom vodom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('obući se', 'obuci se', 'hr', 'verb', 'A1', 'одягнутися', 'core', '{"aspect": "pfv"}'::jsonb, '["Obuci se toplo, vani je hladno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('češljati se', 'cesljati se', 'hr', 'verb', 'A1', 'причісуватися', 'core', '{"aspect": "ipfv"}'::jsonb, '["Ona se češlja pred ogledalom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('četkica za zube', 'cetkica za zube', 'hr', 'phrase', 'A1', 'зубна щітка', 'collocation', '{}'::jsonb, '["Trebam novu četkicu za zube."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('žuriti se', 'zuriti se', 'hr', 'verb', 'A1', 'поспішати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Ne žuri se, imamo vremena."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('burek', 'burek', 'hr', 'noun', 'A1', 'бурек (листковий пиріг)', 'core', '{"gender": "m"}'::jsonb, '["Za doručak jedem burek sa sirom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pecivo', 'pecivo', 'hr', 'noun', 'A1', 'булочка; випічка', 'core', '{"gender": "n"}'::jsonb, '["Pecivo je još toplo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jogurt', 'jogurt', 'hr', 'noun', 'A1', 'йогурт', 'core', '{"gender": "m"}'::jsonb, '["Djeca vole jogurt s voćem."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('domaći', 'domaci', 'hr', 'adjective', 'A1', 'домашній', 'core', '{}'::jsonb, '["Ovo je domaći kruh."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vegetarijanac', 'vegetarijanac', 'hr', 'noun', 'A1', 'вегетаріанець', 'core', '{"gender": "m"}'::jsonb, '["Moj brat je vegetarijanac."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('orah', 'orah', 'hr', 'noun', 'A1', 'горіх', 'core', '{"gender": "m"}'::jsonb, '["U ovom kolaču ima oraha."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('slan', 'slan', 'hr', 'adjective', 'A1', 'солоний', 'core', '{}'::jsonb, '["Sir je malo previše slan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kiseo', 'kiseo', 'hr', 'adjective', 'A1', 'кислий', 'core', '{}'::jsonb, '["Ova jabuka je kisela."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('previše', 'previse', 'hr', 'adverb', 'A1', 'надто; забагато', 'core', '{}'::jsonb, '["Ne jedi previše slatkiša."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('drogerija', 'drogerija', 'hr', 'noun', 'A1', 'магазин побутової хімії й косметики', 'core', '{"gender": "f"}'::jsonb, '["Šampon kupujem u drogeriji."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pasta za zube', 'pasta za zube', 'hr', 'phrase', 'A1', 'зубна паста', 'collocation', '{}'::jsonb, '["Nestalo nam je paste za zube."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pelene', 'pelene', 'hr', 'noun', 'A1', 'підгузки', 'core', '{"gender": "f"}'::jsonb, '["Pelene su na akciji."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('deterdžent', 'deterdzent', 'hr', 'noun', 'A1', 'засіб для прання; мийний засіб', 'core', '{"gender": "m"}'::jsonb, '["Kupi deterdžent za rublje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('SIM kartica', 'sim kartica', 'hr', 'phrase', 'A1', 'SIM-картка', 'collocation', '{}'::jsonb, '["Novu SIM karticu možete kupiti na kiosku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bon', 'bon', 'hr', 'noun', 'A1', 'передплата (поповнення рахунку)', 'core', '{"gender": "m"}'::jsonb, '["Imam bon, a ne ugovor."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tarifa', 'tarifa', 'hr', 'noun', 'A1', 'тариф', 'core', '{"gender": "f"}'::jsonb, '["Ova tarifa ima neograničen internet."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mjesečno', 'mjesecno', 'hr', 'adverb', 'A1', 'щомісяця; на місяць', 'core', '{}'::jsonb, '["Najam je petsto eura mjesečno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zvati', 'zvati', 'hr', 'verb', 'A1', 'дзвонити; кликати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Mama me zove svaki dan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('puniti', 'puniti', 'hr', 'verb', 'A1', 'заряджати; наповнювати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Mobitel punim preko noći."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('broj mobitela', 'broj mobitela', 'hr', 'phrase', 'A1', 'номер мобільного телефону', 'collocation', '{}'::jsonb, '["Koji je tvoj broj mobitela?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('taksist', 'taksist', 'hr', 'noun', 'A1', 'таксист', 'core', '{"gender": "m"}'::jsonb, '["Taksist zna kraći put."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gužva', 'guzva', 'hr', 'noun', 'A1', 'затор; тиснява', 'core', '{"gender": "f"}'::jsonb, '["Ujutro je u gradu velika gužva."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('na vrijeme', 'na vrijeme', 'hr', 'adverb', 'A1', 'вчасно', 'chunk', '{}'::jsonb, '["Vlak stiže na vrijeme."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('benzinska postaja', 'benzinska postaja', 'hr', 'phrase', 'A1', 'автозаправна станція', 'collocation', '{}'::jsonb, '["Benzinska postaja radi cijelu noć."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rezervoar', 'rezervoar', 'hr', 'noun', 'A1', 'бак (паливний)', 'core', '{"gender": "m"}'::jsonb, '["Rezervoar je skoro prazan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('provjeriti', 'provjeriti', 'hr', 'verb', 'A1', 'перевірити', 'core', '{"aspect": "pfv"}'::jsonb, '["Možete li provjeriti ulje?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('automat', 'automat', 'hr', 'noun', 'A1', 'автомат (паркомат, автомат з продажу)', 'core', '{"gender": "m"}'::jsonb, '["Kartu možete kupiti na automatu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('račun za struju', 'racun za struju', 'hr', 'phrase', 'A1', 'рахунок за електрику', 'collocation', '{}'::jsonb, '["Račun za struju dolazi svaki mjesec."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uplatnica', 'uplatnica', 'hr', 'noun', 'A1', 'платіжна квитанція', 'core', '{"gender": "f"}'::jsonb, '["Uplatnicu možete platiti na pošti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ruter', 'ruter', 'hr', 'noun', 'A1', 'роутер', 'core', '{"gender": "m"}'::jsonb, '["Ugasi ruter i upali ga ponovno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uključen', 'ukljucen', 'hr', 'adjective', 'A1', 'увімкнений; включений', 'core', '{}'::jsonb, '["Je li grijanje uključeno u cijenu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tehničar', 'tehnicar', 'hr', 'noun', 'A1', 'технік', 'core', '{"gender": "m"}'::jsonb, '["Tehničar dolazi u utorak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('probni rad', 'probni rad', 'hr', 'phrase', 'A1', 'випробувальний термін', 'collocation', '{}'::jsonb, '["Probni rad traje tri mjeseca."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('puno radno vrijeme', 'puno radno vrijeme', 'hr', 'phrase', 'A1', 'повний робочий день', 'collocation', '{}'::jsonb, '["Tražim posao na puno radno vrijeme."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('smjena', 'smjena', 'hr', 'noun', 'A1', 'зміна (на роботі)', 'core', '{"gender": "f"}'::jsonb, '["Ovaj tjedan radim u drugoj smjeni."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('radna dozvola', 'radna dozvola', 'hr', 'phrase', 'A1', 'дозвіл на роботу', 'collocation', '{}'::jsonb, '["Za ovaj posao trebate radnu dozvolu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('privremena zaštita', 'privremena zastita', 'hr', 'phrase', 'A1', 'тимчасовий захист', 'collocation', '{}'::jsonb, '["Imam status privremene zaštite."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bruto', 'bruto', 'hr', 'adjective', 'A1', 'брутто (до податків)', 'core', '{}'::jsonb, '["Plaća je tisuću petsto eura bruto."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('neto', 'neto', 'hr', 'adjective', 'A1', 'нетто (після податків)', 'core', '{}'::jsonb, '["Neto plaća je manja od bruto plaće."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prekovremeni sati', 'prekovremeni sati', 'hr', 'phrase', 'A1', 'понаднормові години', 'collocation', '{}'::jsonb, '["Ovaj mjesec imam deset prekovremenih sati."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('platna lista', 'platna lista', 'hr', 'phrase', 'A1', 'розрахунковий листок', 'collocation', '{}'::jsonb, '["Platnu listu dobivate svaki mjesec."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('posebno', 'posebno', 'hr', 'adverb', 'A1', 'окремо; особливо', 'core', '{}'::jsonb, '["Piće se plaća posebno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('javiti se', 'javiti se', 'hr', 'verb', 'A1', 'обізватися; відповісти (на дзвінок); зголоситися', 'core', '{"aspect": "pfv"}'::jsonb, '["Javi se kad stigneš."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('videopoziv', 'videopoziv', 'hr', 'noun', 'A1', 'відеодзвінок', 'core', '{"gender": "m"}'::jsonb, '["Svake večeri imam videopoziv s mamom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('link', 'link', 'hr', 'noun', 'A1', 'посилання', 'core', '{"gender": "m"}'::jsonb, '["Pošalji mi link, molim te."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mail', 'mail', 'hr', 'noun', 'A1', 'електронний лист; імейл', 'core', '{"gender": "m"}'::jsonb, '["Odgovaram na mail poslije sastanka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rame', 'rame', 'hr', 'noun', 'A1', 'плече', 'core', '{"gender": "n"}'::jsonb, '["Torbu nosim na ramenu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vrat', 'vrat', 'hr', 'noun', 'A1', 'шия', 'core', '{"gender": "m"}'::jsonb, '["Od računala me boli vrat."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zubobolja', 'zubobolja', 'hr', 'noun', 'A1', 'зубний біль', 'core', '{"gender": "f"}'::jsonb, '["Zubobolja ne prolazi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('plomba', 'plomba', 'hr', 'noun', 'A1', 'пломба (зубна)', 'core', '{"gender": "f"}'::jsonb, '["Trebam novu plombu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('izvaditi', 'izvaditi', 'hr', 'verb', 'A1', 'видалити (зуб); вийняти', 'core', '{"aspect": "pfv"}'::jsonb, '["Zubar mora izvaditi zub."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('osjetljiv', 'osjetljiv', 'hr', 'adjective', 'A1', 'чутливий', 'core', '{}'::jsonb, '["Imam osjetljivu kožu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('usamljen', 'usamljen', 'hr', 'adjective', 'A1', 'самотній', 'core', '{}'::jsonb, '["U novom gradu sam ponekad usamljen."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nervozan', 'nervozan', 'hr', 'adjective', 'A1', 'знервований; схвильований', 'core', '{}'::jsonb, '["Prije ispita sam uvijek nervozan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zadovoljan', 'zadovoljan', 'hr', 'adjective', 'A1', 'задоволений', 'core', '{}'::jsonb, '["Šef je zadovoljan mojim radom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sasvim', 'sasvim', 'hr', 'adverb', 'A1', 'цілком; зовсім', 'core', '{}'::jsonb, '["To je sasvim normalno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vrh', 'vrh', 'hr', 'noun', 'A1', 'вершина', 'core', '{"gender": "m"}'::jsonb, '["S vrha se vidi cijeli grad."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nalaziti se', 'nalaziti se', 'hr', 'verb', 'A1', 'знаходитися; зустрічатися', 'core', '{"aspect": "ipfv"}'::jsonb, '["Nalazimo se ispred kina u osam."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sendvič', 'sendvic', 'hr', 'noun', 'A1', 'сендвіч', 'core', '{"gender": "m"}'::jsonb, '["Za put nosim sendvič i vodu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('udoban', 'udoban', 'hr', 'adjective', 'A1', 'зручний', 'core', '{}'::jsonb, '["Ovaj kauč je jako udoban."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('hod', 'hod', 'hr', 'noun', 'A1', 'ходьба', 'core', '{"gender": "m"}'::jsonb, '["Do plaže je pet minuta hoda."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sjever', 'sjever', 'hr', 'noun', 'A1', 'північ', 'core', '{"gender": "m"}'::jsonb, '["Zagreb je na sjeveru Hrvatske."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jug', 'jug', 'hr', 'noun', 'A1', 'південь', 'core', '{"gender": "m"}'::jsonb, '["Dubrovnik je na jugu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('istok', 'istok', 'hr', 'noun', 'A1', 'схід', 'core', '{"gender": "m"}'::jsonb, '["Sunce izlazi na istoku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zapad', 'zapad', 'hr', 'noun', 'A1', 'захід', 'core', '{"gender": "m"}'::jsonb, '["Istra je na zapadu Hrvatske."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ravnica', 'ravnica', 'hr', 'noun', 'A1', 'рівнина', 'core', '{"gender": "f"}'::jsonb, '["Slavonija je velika ravnica."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('glavni grad', 'glavni grad', 'hr', 'phrase', 'A1', 'столиця', 'collocation', '{}'::jsonb, '["Kijev je glavni grad Ukrajine."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zvučati', 'zvucati', 'hr', 'verb', 'A1', 'звучати', 'core', '{"aspect": "ipfv"}'::jsonb, '["Tvoj plan zvuči dobro."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dugo', 'dugo', 'hr', 'adverb', 'A1', 'довго', 'core', '{}'::jsonb, '["Dugo čekamo autobus."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pričati', 'pricati', 'hr', 'verb', 'A1', 'розповідати; розмовляти', 'core', '{"aspect": "ipfv"}'::jsonb, '["Baka voli pričati o mladosti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vrtić', 'vrtic', 'hr', 'noun', 'A1', 'дитячий садок', 'core', '{"gender": "m"}'::jsonb, '["Kći ide u vrtić od osam do četiri."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('upisati', 'upisati', 'hr', 'verb', 'A1', 'записати (в садок, школу); вписати', 'core', '{"aspect": "pfv"}'::jsonb, '["Sina želimo upisati u školu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('cijepljenje', 'cijepljenje', 'hr', 'noun', 'A1', 'щеплення', 'core', '{"gender": "n"}'::jsonb, '["Cijepljenje je besplatno za djecu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ravnateljica', 'ravnateljica', 'hr', 'noun', 'A1', 'директорка (школи, садка)', 'core', '{"gender": "f"}'::jsonb, '["Ravnateljica nas čeka u uredu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('učenica', 'ucenica', 'hr', 'noun', 'A1', 'учениця', 'core', '{"gender": "f"}'::jsonb, '["Ona je učenica trećeg razreda."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('učiteljica', 'uciteljica', 'hr', 'noun', 'A1', 'учителька', 'core', '{"gender": "f"}'::jsonb, '["Učiteljica je jako strpljiva."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('slabo', 'slabo', 'hr', 'adverb', 'A1', 'слабо; погано', 'core', '{}'::jsonb, '["Još slabo govorim hrvatski."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('produženi boravak', 'produzeni boravak', 'hr', 'phrase', 'A1', 'група продовженого дня (у школі)', 'collocation', '{}'::jsonb, '["Poslije nastave djeca idu u produženi boravak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('roditeljski sastanak', 'roditeljski sastanak', 'hr', 'phrase', 'A1', 'батьківські збори', 'collocation', '{}'::jsonb, '["Roditeljski sastanak je u četvrtak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('naknada', 'naknada', 'hr', 'noun', 'A1', 'плата; комісія; компенсація', 'core', '{"gender": "f"}'::jsonb, '["Banka uzima malu naknadu za podizanje novca."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('IBAN', 'iban', 'hr', 'noun', 'A1', 'IBAN (номер банківського рахунку)', 'core', '{"gender": "m"}'::jsonb, '["Pošaljite mi svoj IBAN."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('PIN', 'pin', 'hr', 'noun', 'A1', 'PIN-код', 'core', '{"gender": "m"}'::jsonb, '["Nikome ne govorite svoj PIN."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('blokiran', 'blokiran', 'hr', 'adjective', 'A1', 'заблокований', 'core', '{}'::jsonb, '["Račun je privremeno blokiran."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odblokirati', 'odblokirati', 'hr', 'verb', 'A1', 'розблокувати', 'core', '{"aspect": "pfv"}'::jsonb, '["Karticu možete odblokirati u aplikaciji."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v1')
on conflict do nothing;

-- 2. Виправлення словника (стара версія — у content_versions)
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('luk') and ukrainian_translation = 'цибуля / часник';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «цибуля / часник» → «цибуля»');
  update public.lexemes set ukrainian_translation = 'цибуля' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «цибуля / часник» → «цибуля»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('slobodno vrijeme') and ukrainian_translation = 'віільний час';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «віільний час» → «вільний час»');
  update public.lexemes set ukrainian_translation = 'вільний час' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «віільний час» → «вільний час»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('uho') and ukrainian_translation = 'вхо';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «вхо» → «вухо»');
  update public.lexemes set ukrainian_translation = 'вухо' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «вхо» → «вухо»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('polica') and ukrainian_translation = 'страховий поліс';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «страховий поліс» → «полиця; страховий поліс»');
  update public.lexemes set ukrainian_translation = 'полиця; страховий поліс' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «страховий поліс» → «полиця; страховий поліс»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('spremati') and ukrainian_translation = 'зберігати';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «зберігати» → «прибирати; готувати; зберігати»');
  update public.lexemes set ukrainian_translation = 'прибирати; готувати; зберігати' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «зберігати» → «прибирати; готувати; зберігати»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('kraj') and ukrainian_translation = 'кінець';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «кінець» → «кінець; край, місцевість»');
  update public.lexemes set ukrainian_translation = 'кінець; край, місцевість' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «кінець» → «кінець; край, місцевість»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('hladno') and ukrainian_translation = 'холодне';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «холодне» → «холодно; холодне»');
  update public.lexemes set ukrainian_translation = 'холодно; холодне' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «холодне» → «холодно; холодне»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('dokaz') and ukrainian_translation = 'доказ';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «доказ» → «доказ; підтвердження»');
  update public.lexemes set ukrainian_translation = 'доказ; підтвердження' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «доказ» → «доказ; підтвердження»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('mobilno bankarstvo') and ukrainian_translation = 'Мобільний банкінг';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «Мобільний банкінг» → «мобільний банкінг»');
  update public.lexemes set ukrainian_translation = 'мобільний банкінг' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «Мобільний банкінг» → «мобільний банкінг»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('prtljažnik') and ukrainian_translation = 'Багажник';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «Багажник» → «багажник»');
  update public.lexemes set ukrainian_translation = 'багажник' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «Багажник» → «багажник»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower('živjeli') and ukrainian_translation = 'Будьмо! (Тост)';
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: переклад «Будьмо! (Тост)» → «будьмо! (тост)»');
  update public.lexemes set ukrainian_translation = 'будьмо! (тост)' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: переклад «Будьмо! (Тост)» → «будьмо! (тост)»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lemma = 'Vozačka dozvola';
  if v_id is null then return; end if;  -- уже виправлено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: лема «Vozačka dozvola» → «vozačka dozvola»');
  update public.lexemes set lemma = 'vozačka dozvola' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: лема «Vozačka dozvola» → «vozačka dozvola»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lemma = 'Mobilno bankarstvo';
  if v_id is null then return; end if;  -- уже виправлено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: лема «Mobilno bankarstvo» → «mobilno bankarstvo»');
  update public.lexemes set lemma = 'mobilno bankarstvo' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: лема «Mobilno bankarstvo» → «mobilno bankarstvo»');
end $$;
do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lemma = 'Prtljažnik';
  if v_id is null then return; end if;  -- уже виправлено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, 'curriculum_a1_v1: лема «Prtljažnik» → «prtljažnik»');
  update public.lexemes set lemma = 'prtljažnik' where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a1_v1: лема «Prtljažnik» → «prtljažnik»');
end $$;

-- 3. Граматика A1: правила й публікація (теми вже є в каркасі як DRAFT)
update public.grammar_topics set description = 'Як змінюються дієслова в теперішньому часі: три типи закінчень.', status = 'PUBLISHED'
where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '40151a44-ae08-5a62-906c-f1687e499720', '387f7bea-839e-56ae-bbfd-213aacbe7c26', 'Дієслова на -am: čitati', 'Більшість дієслів на -ati мають закінчення -am, -aš, -a, -amo, -ate, -aju.', 'čitam, čitaš, čita, čitamo, čitate, čitaju', '[{"hr": "Čitam knjigu.", "ua": "Я читаю книжку."}, {"hr": "Gdje radiš?", "ua": "Де ти працюєш?"}, {"hr": "Oni gledaju film.", "ua": "Вони дивляться фільм."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '07ac2a81-2cc1-5d4f-bb3d-7847ab7a8ffd', '387f7bea-839e-56ae-bbfd-213aacbe7c26', 'Дієслова на -im: govoriti', 'Дієслова на -iti і частина на -jeti мають закінчення -im, -iš, -i, -imo, -ite, -e.', 'govorim, govoriš, govori, govorimo, govorite, govore', '[{"hr": "Govorim malo hrvatski.", "ua": "Я трохи говорю хорватською."}, {"hr": "Kada ručaš?", "ua": "Коли ти обідаєш?"}, {"hr": "Oni žive u Splitu.", "ua": "Вони живуть у Спліті."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'ecc08256-b531-5fc1-83ea-92473592fbaa', '387f7bea-839e-56ae-bbfd-213aacbe7c26', 'Дієслова на -em: pisati, piti, doručkovati', 'Решта дієслів мають -em, -eš, -e, -emo, -ete, -u. Основа часто змінюється: pisati → pišem, piti → pijem, doručkovati → doručkujem.', 'pišem, pišeš, piše, pišemo, pišete, pišu', '[{"hr": "Pijem kavu bez šećera.", "ua": "Я п’ю каву без цукру."}, {"hr": "Doručkujem u sedam.", "ua": "Я снідаю о сьомій."}, {"hr": "Što pišeš?", "ua": "Що ти пишеш?"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '387f7bea-839e-56ae-bbfd-213aacbe7c26', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '387f7bea-839e-56ae-bbfd-213aacbe7c26' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Інфінітив, дієслово + інфінітив, питання й заперечення з дієсловами.', status = 'PUBLISHED'
where id = '318b394b-c622-5dd6-8494-4c1472b6df62' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '54f5c417-a734-51fb-a128-1cc620ed6c30', '318b394b-c622-5dd6-8494-4c1472b6df62', 'Інфінітив: -ti або -ći', 'У словнику дієслова стоять в інфінітиві: raditi, gledati, ići, moći. Від нього утворюємо теперішній час.', 'gledati → gledam · raditi → radim', '[{"hr": "Volim gledati filmove.", "ua": "Я люблю дивитися фільми."}, {"hr": "Želim raditi ovdje.", "ua": "Я хочу працювати тут."}, {"hr": "Moram ići.", "ua": "Мені треба йти."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '318b394b-c622-5dd6-8494-4c1472b6df62')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'e2b038a6-5c04-5753-ae96-79a675c75f57', '318b394b-c622-5dd6-8494-4c1472b6df62', 'Дієслово + інфінітив', 'Після voljeti, željeti, htjeti, moći, morati друге дієслово стоїть в інфінітиві — як в українській.', 'Volim + plivati', '[{"hr": "Volim plivati.", "ua": "Я люблю плавати."}, {"hr": "Želimo kuhati zajedno.", "ua": "Ми хочемо готувати разом."}, {"hr": "Učim govoriti hrvatski.", "ua": "Я вчуся говорити хорватською."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '318b394b-c622-5dd6-8494-4c1472b6df62')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '052e29e6-98b5-5fc8-bd83-5a3703f2dde1', '318b394b-c622-5dd6-8494-4c1472b6df62', 'Питання і заперечення', 'Питання: дієслово + li (Čitaš li?). Заперечення: ne перед дієсловом (Ne čitam).', 'Gledaš li? · Ne gledam.', '[{"hr": "Gledaš li seriju?", "ua": "Ти дивишся серіал?"}, {"hr": "Ne gledam, čitam.", "ua": "Не дивлюся, читаю."}, {"hr": "Kuhate li doma?", "ua": "Ви готуєте вдома?"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '318b394b-c622-5dd6-8494-4c1472b6df62')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '318b394b-c622-5dd6-8494-4c1472b6df62', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '318b394b-c622-5dd6-8494-4c1472b6df62' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Найчастіші дієслова, які змінюються не за правилом: ići, htjeti, moći, jesti, piti.', status = 'PUBLISHED'
where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '18d86872-bbd7-58b8-a968-97cbd9fe8eed', '6ba7fa0f-46cc-5679-85bb-23c1329bfa18', 'Ići — іти, їхати', 'Ići означає і «йти», і «їхати». Теперішній час: idem, ideš, ide, idemo, idete, idu.', 'idem, ideš, ide, idemo, idete, idu', '[{"hr": "Idem na posao.", "ua": "Я йду на роботу."}, {"hr": "Idemo autobusom.", "ua": "Ми їдемо автобусом."}, {"hr": "Kamo ideš?", "ua": "Куди ти йдеш?"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '6dfda313-836e-5098-a7b3-80c045d487d8', '6ba7fa0f-46cc-5679-85bb-23c1329bfa18', 'Htjeti і moći', 'Htjeti (хотіти): hoću, hoćeš, hoće, hoćemo, hoćete, hoće. Moći (могти): mogu, možeš, može, možemo, možete, mogu. Після них — інфінітив або li-питання: Hoćeš li…? Mogu li…?', 'hoću · mogu', '[{"hr": "Hoćeš li kavu?", "ua": "Хочеш кави?"}, {"hr": "Danas ne mogu.", "ua": "Сьогодні я не можу."}, {"hr": "Možete li ponoviti?", "ua": "Можете повторити?"}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '7e64b6d4-0e82-5c5e-a1cf-ff8f0ac03012', '6ba7fa0f-46cc-5679-85bb-23c1329bfa18', 'Jesti і piti', 'Jesti (їсти): jedem, jedeš, jede, jedemo, jedete, jedu. Piti (пити): pijem, piješ, pije, pijemo, pijete, piju. Основа змінюється — форми треба запам’ятати.', 'jedem · pijem', '[{"hr": "Što jedeš?", "ua": "Що ти їси?"}, {"hr": "Pijemo vodu.", "ua": "Ми п’ємо воду."}, {"hr": "Djeca jedu voće.", "ua": "Діти їдять фрукти."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '6ba7fa0f-46cc-5679-85bb-23c1329bfa18', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Кого? Що? — знахідний відмінок після дієслів: želim kavu, vidim brata, boli me glava.', status = 'PUBLISHED'
where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '3691ec21-3052-5fab-91d7-bc13629aa97a', '0db658cb-b2ed-5719-bced-f95a93cf15ce', 'Жіночий рід: -a → -u', 'Іменники жіночого роду на -a мають -u — як в українській: «кава — каву».', 'kava → kavu · juha → juhu', '[{"hr": "Želim kavu.", "ua": "Я хочу каву."}, {"hr": "Jedem juhu.", "ua": "Я їм суп."}, {"hr": "Imam sestru.", "ua": "У мене є сестра."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '3d5ae2cf-932d-55a0-adda-09523c6b6993', '0db658cb-b2ed-5719-bced-f95a93cf15ce', 'Чоловічий рід: неживе не змінюється, живе → -a', 'Неживі іменники чоловічого роду не змінюються: Trebam ključ. Живі отримують -a: Čekam prijatelja. Середній рід не змінюється.', 'ključ → ključ · prijatelj → prijatelja', '[{"hr": "Trebam ključ.", "ua": "Мені потрібен ключ."}, {"hr": "Čekam prijatelja.", "ua": "Я чекаю друга."}, {"hr": "Naručujem vino.", "ua": "Я замовляю вино."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'f2fb8e78-785a-5cf3-855e-156ebfffa954', '0db658cb-b2ed-5719-bced-f95a93cf15ce', 'Займенники: me, te, ga, je', 'Короткі форми: me (мене), te (тебе), ga (його), je (її), nas, vas, ih. «Boli me glava» — дослівно «болить мене голова».', 'Boli me glava. · Vidim te.', '[{"hr": "Boli me grlo.", "ua": "У мене болить горло."}, {"hr": "Volim te.", "ua": "Я тебе люблю."}, {"hr": "Zovem ga sutra.", "ua": "Я подзвоню йому завтра."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '0db658cb-b2ed-5719-bced-f95a93cf15ce', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '0db658cb-b2ed-5719-bced-f95a93cf15ce' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Де? Про що? — місцевий відмінок після u, na, o.', status = 'PUBLISHED'
where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '92f89436-6b06-551f-b319-34715c0c9d5b', 'f891e65a-d7be-5542-ae6e-dbee5bfe415c', 'Де? — u / na + місцевий', 'Чоловічий і середній рід: -u (u gradu, na moru). Жіночий рід на -a: -i (u kući, na plaži).', 'grad → u gradu · plaža → na plaži', '[{"hr": "Živim u Zagrebu.", "ua": "Я живу в Загребі."}, {"hr": "Ona je na poslu.", "ua": "Вона на роботі."}, {"hr": "Čekam na stanici.", "ua": "Я чекаю на зупинці."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'd233f971-d086-5069-9713-49dab2159f35', 'f891e65a-d7be-5542-ae6e-dbee5bfe415c', 'U чи na?', 'U — всередині (u stanu, u trgovini). Na — на поверхні, на відкритому місці й у сталих виразах (na moru, na poslu, na tržnici, na otoku).', 'u trgovini · na tržnici', '[{"hr": "Kupujem u trgovini.", "ua": "Я купую в магазині."}, {"hr": "Voće je na tržnici.", "ua": "Фрукти — на ринку."}, {"hr": "Ljeti smo na otoku.", "ua": "Влітку ми на острові."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '678aa2e5-cc44-5e58-bb6e-148782e8076e', 'f891e65a-d7be-5542-ae6e-dbee5bfe415c', 'O + місцевий: про кого, про що', 'Після o (про) теж місцевий відмінок: pričamo o poslu.', 'o poslu · o Hrvatskoj', '[{"hr": "Pričamo o filmu.", "ua": "Ми говоримо про фільм."}, {"hr": "Čitam o Hrvatskoj.", "ua": "Я читаю про Хорватію."}, {"hr": "Knjiga je o moru.", "ua": "Книжка про море."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', 'f891e65a-d7be-5542-ae6e-dbee5bfe415c', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Чого? Скільки? Звідки? — родовий відмінок після кількості, nema і прийменників.', status = 'PUBLISHED'
where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '6677f562-23a4-558a-9ccf-cf154ed81bab', 'd27ae527-a8d6-512f-acd2-a6cfec39c01f', 'Кількість + родовий', 'Після слів кількості (kilogram, boca, malo, puno) — родовий: жіночий рід -a → -e, чоловічий і середній отримують -a.', 'voda → boca vode · sir → malo sira', '[{"hr": "Bocu vode, molim.", "ua": "Пляшку води, будь ласка."}, {"hr": "Kilogram grožđa.", "ua": "Кілограм винограду."}, {"hr": "Malo šećera?", "ua": "Трохи цукру?"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '59347e30-33da-5e33-8bb0-e9cabb0a801b', 'd27ae527-a8d6-512f-acd2-a6cfec39c01f', 'Nema + родовий', 'Nema — «немає»: nema mlijeka. Nemam — «у мене немає»: nemam vremena.', 'nema + mlijeka', '[{"hr": "Nema tople vode.", "ua": "Немає гарячої води."}, {"hr": "Nemam vremena.", "ua": "У мене немає часу."}, {"hr": "Danas nema kruha.", "ua": "Сьогодні немає хліба."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '2cdc36c9-1c4e-579f-b815-132a0d48feca', 'd27ae527-a8d6-512f-acd2-a6cfec39c01f', 'Iz, od, do, kod, preko puta + родовий', 'Після цих прийменників — родовий: iz Ukrajine, do centra, kod liječnika, preko puta pošte.', 'iz Ukrajine · do centra · kod banke', '[{"hr": "Ja sam iz Ukrajine.", "ua": "Я з України."}, {"hr": "Idem do centra.", "ua": "Я їду до центру."}, {"hr": "Bankomat je kod banke.", "ua": "Банкомат біля банку."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', 'd27ae527-a8d6-512f-acd2-a6cfec39c01f', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Наш, ваш, його, її, їхній — і питання «чий?».', status = 'PUBLISHED'
where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'a59cc0ae-f9c0-5703-bfd6-98c7c7dc81b6', '94ab9b5e-95b0-5edb-8322-52293bdb5d05', 'Naš, vaš', 'Naš — наш, vaš — ваш. Закінчення — як у прикметника: naš stan, naša kuća, naše dijete. «Vaš» у ввічливому звертанні пишемо з великої: Vaš.', 'naš · naša · naše', '[{"hr": "Ovo je naš stan.", "ua": "Це наша квартира."}, {"hr": "Je li ovo Vaša torba?", "ua": "Це ваша сумка?"}, {"hr": "Naše dijete ide u vrtić.", "ua": "Наша дитина ходить у садок."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '8d340287-844c-512a-bc71-5526a79f7972', '94ab9b5e-95b0-5edb-8322-52293bdb5d05', 'Njegov, njezin, njihov', 'Njegov — його, njezin — її, njihov — їхній. Закінчення залежить від того, що належить: njezin brat, njezina sestra.', 'njegov · njezina · njihovo', '[{"hr": "To je njegov auto.", "ua": "Це його машина."}, {"hr": "Njezina mama je liječnica.", "ua": "Її мама — лікарка."}, {"hr": "Njihova djeca su u školi.", "ua": "Їхні діти в школі."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'a4f85731-c2b1-5b6a-80b6-e882bf118063', '94ab9b5e-95b0-5edb-8322-52293bdb5d05', 'Čiji? — чий?', 'Питання: čiji (чий), čija (чия), čije (чиє).', 'Čiji je ovo kofer?', '[{"hr": "Čiji je ovo ključ?", "ua": "Чий це ключ?"}, {"hr": "Čija je ovo jakna?", "ua": "Чия це куртка?"}, {"hr": "Moja!", "ua": "Моя!"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '94ab9b5e-95b0-5edb-8322-52293bdb5d05', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Можу, мушу, треба, можна: moći, morati, trebati, smjeti.', status = 'PUBLISHED'
where id = '61247c65-c284-51c5-a9ed-1626afbd77ac' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'e91eedbd-788e-538a-af75-508e4aa4c06d', '61247c65-c284-51c5-a9ed-1626afbd77ac', 'Moći — могти', 'Mogu, možeš, može… «Mogu li…?» — ввічливе прохання: «Можна…?»', 'Mogu li platiti karticom?', '[{"hr": "Mogu li probati?", "ua": "Можна поміряти?"}, {"hr": "Ne mogu doći.", "ua": "Я не можу прийти."}, {"hr": "Možete li mi pomoći?", "ua": "Можете мені допомогти?"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'd11240eb-be89-5de7-a23f-e95094302ddc', '61247c65-c284-51c5-a9ed-1626afbd77ac', 'Morati і trebati', 'Moram — я мушу, мені треба. Trebam + іменник — мені потрібне щось: trebam liječnika.', 'Moram ići. · Trebam vrećicu.', '[{"hr": "Moram raditi.", "ua": "Я мушу працювати."}, {"hr": "Trebam pomoć.", "ua": "Мені потрібна допомога."}, {"hr": "Moraš li danas raditi?", "ua": "Тобі сьогодні треба працювати?"}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'a703e2b8-1680-5ce4-bc63-263dc7968b76', '61247c65-c284-51c5-a9ed-1626afbd77ac', 'Smjeti — можна (дозвіл)', 'Smijem, smiješ, smije… «Smijem li?» — «чи можна мені?». «Ne smijete» — «вам не можна».', 'Smijem li ući? · Ne smijete pušiti.', '[{"hr": "Smijem li ući?", "ua": "Можна увійти?"}, {"hr": "Ovdje ne smijete parkirati.", "ua": "Тут не можна паркуватися."}, {"hr": "Djeca ne smiju plivati sama.", "ua": "Дітям не можна плавати самим."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '61247c65-c284-51c5-a9ed-1626afbd77ac', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '61247c65-c284-51c5-a9ed-1626afbd77ac' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Прохання й поради: dodaj, uzmite, nemojte.', status = 'PUBLISHED'
where id = '45c5cb39-daf7-5dab-8413-9a5302b33553' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '92d8b179-0b0d-5147-9851-b314799a2a39', '45c5cb39-daf7-5dab-8413-9a5302b33553', 'Ти: -i / -j', 'Прохання до однієї людини на «ти»: čekati → čekaj, dodati → dodaj, uzeti → uzmi, doći → dođi.', 'Dodaj sol! · Dođi!', '[{"hr": "Čekaj me!", "ua": "Зачекай мене!"}, {"hr": "Dodaj malo soli.", "ua": "Додай трохи солі."}, {"hr": "Dođi u nedjelju!", "ua": "Приходь у неділю!"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'a39d68a6-c8bf-5e01-ad04-4c1dc4b69a4d', '45c5cb39-daf7-5dab-8413-9a5302b33553', 'Ви: -ite / -jte', 'До кількох людей або ввічливо: čekajte, uzmite, izvolite, ispunite.', 'Uzmite · Pijte · Izvolite', '[{"hr": "Uzmite jednu tabletu.", "ua": "Прийміть одну таблетку."}, {"hr": "Pijte puno vode.", "ua": "Пийте багато води."}, {"hr": "Pričekajte malo, molim.", "ua": "Зачекайте трохи, будь ласка."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'b3c4bdb0-89b8-5862-9e75-df0ee53d16eb', '45c5cb39-daf7-5dab-8413-9a5302b33553', 'Не роби: nemoj / nemojte + інфінітив', 'Заборона або порада «не роби»: nemoj (ти), nemojte (ви) + інфінітив.', 'Nemoj kasniti! · Nemojte pušiti.', '[{"hr": "Nemoj zaboraviti ključ!", "ua": "Не забудь ключ!"}, {"hr": "Nemojte parkirati ovdje.", "ua": "Не паркуйтеся тут."}, {"hr": "Nemoj se brinuti.", "ua": "Не хвилюйся."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '45c5cb39-daf7-5dab-8413-9a5302b33553', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '45c5cb39-daf7-5dab-8413-9a5302b33553' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Більший, дешевший, найкращий: вищий і найвищий ступінь прикметників.', status = 'PUBLISHED'
where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '1f00b1c7-432b-59a3-a501-3b0f09c4fec1', 'b58103b4-a259-5384-aa65-ffc0e2a195c8', 'Вищий ступінь: -iji, -ji', 'Jeftin → jeftiniji, topao → topliji, skup → skuplji. Неправильні: velik → veći, mali → manji, dobar → bolji, loš → gori.', 'jeftin → jeftiniji · dobar → bolji', '[{"hr": "Ova jakna je jeftinija.", "ua": "Ця куртка дешевша."}, {"hr": "Ovaj stan je veći.", "ua": "Ця квартира більша."}, {"hr": "Kava je ovdje bolja.", "ua": "Кава тут краща."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '2ce7b65f-71a8-506c-9f1f-0d419cfad61b', 'b58103b4-a259-5384-aa65-ffc0e2a195c8', 'Ніж: nego', 'Порівняння: X je … nego Y.', 'Danas je toplije nego jučer.', '[{"hr": "Split je topliji nego Zagreb.", "ua": "Спліт тепліший, ніж Загреб."}, {"hr": "Vlak je sporiji nego autobus.", "ua": "Поїзд повільніший, ніж автобус."}, {"hr": "Danas je hladnije nego jučer.", "ua": "Сьогодні холодніше, ніж учора."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '02d95098-1270-5676-9014-268a1731d748', 'b58103b4-a259-5384-aa65-ffc0e2a195c8', 'Найвищий ступінь: naj-', 'Naj- + вищий ступінь: najbolji, najjeftiniji, najveći.', 'najbolji · najljepši', '[{"hr": "Ovo je najbolja pekara.", "ua": "Це найкраща пекарня."}, {"hr": "Ljeto je najtoplije.", "ua": "Літо найтепліше."}, {"hr": "Koja je najjeftinija?", "ua": "Яка найдешевша?"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', 'b58103b4-a259-5384-aa65-ffc0e2a195c8', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Питання з li і питальні слова: kada, koliko, zašto, koji, kakav.', status = 'PUBLISHED'
where id = '1435d343-6721-5eb7-8dc2-af7f9a027716' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '2b222d54-3708-5ce5-9e35-fab772d62efc', '1435d343-6721-5eb7-8dc2-af7f9a027716', 'Питання з li', 'Питання «так / ні»: дієслово + li: Imate li…? Možete li…? З «je»: Je li…?', 'Imate li vremena? · Je li daleko?', '[{"hr": "Imate li sobu?", "ua": "У вас є кімната?"}, {"hr": "Je li ovo Vaš kofer?", "ua": "Це ваша валіза?"}, {"hr": "Govorite li engleski?", "ua": "Ви говорите англійською?"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'a24dbd9c-93ee-58fc-adb3-440ec7a9b904', '1435d343-6721-5eb7-8dc2-af7f9a027716', 'Питальні слова', 'Kada? — коли? Koliko? — скільки? Zašto? — чому? Kako? — як? Odakle? — звідки? Kamo? — куди?', 'Kada polazi vlak?', '[{"hr": "Koliko traje vožnja?", "ua": "Скільки триває поїздка?"}, {"hr": "Zašto učiš hrvatski?", "ua": "Чому ти вчиш хорватську?"}, {"hr": "Odakle ste?", "ua": "Звідки ви?"}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'f775c72c-254d-5d58-9db1-b79d7cea6196', '1435d343-6721-5eb7-8dc2-af7f9a027716', 'Koji і kakav — який?', 'Koji — який саме, з кількох: koji autobus? Kakav — який на вигляд, за якістю: kakvo je vrijeme?', 'Koji autobus? · Kakvo vrijeme?', '[{"hr": "Koji vlak ide u Split?", "ua": "Який поїзд їде до Спліта?"}, {"hr": "Kakvo je vrijeme danas?", "ua": "Яка сьогодні погода?"}, {"hr": "Kakav je stan?", "ua": "Яка квартира?"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '1435d343-6721-5eb7-8dc2-af7f9a027716', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '1435d343-6721-5eb7-8dc2-af7f9a027716' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Ne, nisam, nemam, ništa, nitko, nikad — і подвійне заперечення, як в українській.', status = 'PUBLISHED'
where id = 'b89a9004-2c03-567a-b23e-31db18f92dea' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '3f86e34f-45ba-5f5e-94ac-285743798fda', 'b89a9004-2c03-567a-b23e-31db18f92dea', 'Ne + дієслово', 'Ne ставимо перед дієсловом: ne razumijem, ne radi.', 'ne + radi', '[{"hr": "Mobitel ne radi.", "ua": "Телефон не працює."}, {"hr": "Ne pijem kavu.", "ua": "Я не п’ю каву."}, {"hr": "Ne znam.", "ua": "Я не знаю."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = 'b89a9004-2c03-567a-b23e-31db18f92dea')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '343f5db5-566c-5ade-a8f5-549243c8a5b8', 'b89a9004-2c03-567a-b23e-31db18f92dea', 'Nisam, nemam, neću, nema', 'Деякі дієслова зливаються з ne: nisam (я не…), nemam (не маю), neću (не хочу), nema (немає).', 'nisam · nemam · neću', '[{"hr": "Nisam umoran.", "ua": "Я не втомлений."}, {"hr": "Nemam vremena.", "ua": "У мене немає часу."}, {"hr": "Neću kavu, hvala.", "ua": "Я не хочу кави, дякую."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = 'b89a9004-2c03-567a-b23e-31db18f92dea')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '046da53a-fb5c-5816-81b8-e1ae9ba551f3', 'b89a9004-2c03-567a-b23e-31db18f92dea', 'Подвійне заперечення', 'Як в українській: ništa, nitko, nikad, nigdje + ne: Nitko ne zna. Nikad ne kasnim.', 'Ništa ne vidim.', '[{"hr": "Nitko ne zna.", "ua": "Ніхто не знає."}, {"hr": "Nikad ne kasnim.", "ua": "Я ніколи не запізнююся."}, {"hr": "Ništa mi se ne sviđa.", "ua": "Мені нічого не подобається."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = 'b89a9004-2c03-567a-b23e-31db18f92dea')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', 'b89a9004-2c03-567a-b23e-31db18f92dea', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = 'b89a9004-2c03-567a-b23e-31db18f92dea' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
update public.grammar_topics set description = 'Як поєднати думки: i, a, ali, ili, jer, zato što.', status = 'PUBLISHED'
where id = '765ac66f-d54b-505b-9b11-c48e5ad26018' and cefr = 'A1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'd9fde9a0-a876-5b33-817b-c6d9ab56e820', '765ac66f-d54b-505b-9b11-c48e5ad26018', 'I, a, ali', 'I — і; a — а (протиставлення: «я — так, а ти…»); ali — але.', 'Ja pijem čaj, a ti kavu.', '[{"hr": "Stan je mali, ali lijep.", "ua": "Квартира мала, але гарна."}, {"hr": "Ja radim, a on spava.", "ua": "Я працюю, а він спить."}, {"hr": "Imam brata i sestru.", "ua": "У мене є брат і сестра."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '765ac66f-d54b-505b-9b11-c48e5ad26018')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '3ae30ad9-f446-576b-95a5-4f7e1461b204', '765ac66f-d54b-505b-9b11-c48e5ad26018', 'Ili — або, чи', 'Ili — вибір: kava ili čaj?', 'X ili Y?', '[{"hr": "Kava ili čaj?", "ua": "Кава чи чай?"}, {"hr": "Platite karticom ili gotovinom.", "ua": "Заплатіть карткою або готівкою."}, {"hr": "Danas ili sutra?", "ua": "Сьогодні чи завтра?"}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '765ac66f-d54b-505b-9b11-c48e5ad26018')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '1862eaaa-050d-5596-a6b0-c6b3dc64d2f6', '765ac66f-d54b-505b-9b11-c48e5ad26018', 'Jer, zato što — бо, тому що', 'Причина: jer і zato što. Питання — zašto?', 'Zašto? — Zato što…', '[{"hr": "Učim hrvatski jer živim ovdje.", "ua": "Я вчу хорватську, бо живу тут."}, {"hr": "Ne idem, zato što sam umorna.", "ua": "Я не йду, тому що втомилася."}, {"hr": "Sviđa mi se jer je tiho.", "ua": "Мені подобається, бо тут тихо."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '765ac66f-d54b-505b-9b11-c48e5ad26018')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '765ac66f-d54b-505b-9b11-c48e5ad26018', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
where not exists (select 1 from public.content_reviews where entity_id = '765ac66f-d54b-505b-9b11-c48e5ad26018' and notes = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');

-- 4. Модулі A1: опис, юніт, публікація (модулі вже є в каркасі як DRAFT)
update public.modules set description = 'Розпорядок дня, вихідні й звички. Теперішній час дієслів.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 1 and status <> 'DEPRECATED';
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '893000a6-3e62-528c-8ecf-e644f677823c', m.id, 'Мій день', 'Moj dan', '["Розповісти про свій день", "Сказати, що ви робите у вихідні", "Сказати, як часто ви щось робите"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 1
on conflict do nothing;
update public.modules set description = 'Ресторан, кухня і ринок. Знахідний і родовий відмінки, наказовий спосіб.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 2 and status <> 'DEPRECATED';
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '54c21ee3-db66-5d1e-9eca-7223a2e6f6e4', m.id, 'Їжа і ресторани', 'Hrana i restorani', '["Замовити страву в ресторані", "Приготувати просту страву за рецептом", "Купити продукти на ринку"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 2
on conflict do nothing;
update public.modules set description = 'Одяг, супермаркет, повернення товару. Ступені порівняння, модальні дієслова, заперечення.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 3 and status <> 'DEPRECATED';
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '480b3ca1-58c7-5b6f-8a52-eff47d53b3e4', m.id, 'Покупки', 'Kupovina', '["Порівняти речі за ціною і розміром", "Сказати, що вам треба купити", "Повернути або обміняти товар"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 3
on conflict do nothing;
update public.modules set description = 'Трамвай, поїзд і літак. Місцевий відмінок, питання, присвійні займенники.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 4 and status <> 'DEPRECATED';
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '72a3eec1-fb04-5e99-a0ea-da4f6bc07ed5', m.id, 'Транспорт', 'Prijevoz', '["Купити квиток і зробити пересадку", "Дізнатися розклад поїздів", "Пройти реєстрацію в аеропорту"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 4
on conflict do nothing;
update public.modules set description = 'Оренда, поломки, сусіди. Сполучники, місцевий відмінок, наказовий спосіб.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 5 and status <> 'DEPRECATED';
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select 'c80b7070-95f0-54de-b4dd-90d024f5b830', m.id, 'Житло', 'Stanovanje', '["Знайти квартиру й запитати про умови", "Пояснити, що в квартирі не працює", "Познайомитися із сусідом"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 5
on conflict do nothing;
update public.modules set description = 'Робочий день, правила, співбесіда. Теперішній час, модальні дієслова, питання.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 6 and status <> 'DEPRECATED';
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '874caaa6-f5e5-5c4f-acf4-cfdb0e510116', m.id, 'Робота', 'Posao', '["Розповісти про свою роботу", "Зрозуміти правила на роботі", "Пройти просту співбесіду"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 6
on conflict do nothing;
update public.modules set description = 'Лікар, аптека, самопочуття. Знахідний відмінок, наказовий спосіб, заперечення.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 7 and status <> 'DEPRECATED';
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '2eec2289-6a8a-5fb2-9988-e52433d5a242', m.id, 'Здоров’я', 'Zdravlje', '["Записатися до лікаря", "Купити ліки й зрозуміти, як їх приймати", "Розповісти про своє самопочуття"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 7
on conflict do nothing;
update public.modules set description = 'Запрошення, хобі, думки. Модальні дієслова, теперішній час, сполучники.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 8 and status <> 'DEPRECATED';
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '0df70119-403a-517e-af33-8073d14fca03', m.id, 'Друзі й вільний час', 'Društveni život', '["Запросити когось і відповісти на запрошення", "Розповісти про свої хобі", "Висловити думку і пояснити чому"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 8
on conflict do nothing;
update public.modules set description = 'Погода, острови, свята. Ступені порівняння, місцевий відмінок, присвійні займенники.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 9 and status <> 'DEPRECATED';
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '704b6312-30cc-5a3c-94ff-c2a2dfd1b17c', m.id, 'Хорватія', 'Hrvatska', '["Поговорити про погоду", "Поїхати на острів поромом", "Розповісти про свята своєї родини"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 9
on conflict do nothing;
update public.modules set description = 'Повторення: теми A1 у нових життєвих ситуаціях.', status = 'PUBLISHED'
where level_code = 'A1' and order_index = 10 and status <> 'DEPRECATED';
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '90bce36b-b9de-5168-b120-49d8e33aa6cf', m.id, 'Підсумок A1', 'Ponavljanje A1', '["Розповісти про себе", "Впоратися на пошті й у банку", "Поговорити про своє життя в Хорватії"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A1' and m.order_index = 10
on conflict do nothing;

-- 5. Уроки A1
-- A1.1 · урок 1: Мій звичайний день
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '4bf48151-be83-5108-bc92-645c0603a1a3';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.1: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.1.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 1: Мій звичайний день', 'Lekcija 1: Moj običan dan', '["Розповісти, коли ви встаєте й лягаєте спати", "Назвати щоденні справи", "Змінювати дієслова в теперішньому часі"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('buditi se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'buditi se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ustajati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ustajati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tuširati se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tuširati se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('doručkovati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'doručkovati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('raditi') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'raditi'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ručati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ručati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('večerati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'večerati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('spavati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'spavati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('obično') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'obično'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('svaki dan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'svaki dan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rano') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rano'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kasno') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kasno'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('51cddd7d-7232-5856-9611-9a0af94bcba9', 'fill_in_the_blank', 'Ja se ___ u šest.', 'budim', '["budim", "budiš", "budimo", "budi"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '51cddd7d-7232-5856-9611-9a0af94bcba9', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('rano') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8f588e91-b18f-517e-aaf1-870199b5865f', 'multiple_choice', 'Що означає «rano»?', 'рано', '["пізно", "рано", "обідати", "вечеряти"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8f588e91-b18f-517e-aaf1-870199b5865f', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ustajati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d0147081-5d55-5e3e-98ce-894a3b0a8db4', 'multiple_choice', 'Що означає «ustajati»?', 'вставати (прокидатися і підніматися)', '["приймати душ", "вставати (прокидатися і підніматися)", "працювати, робити", "рано"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd0147081-5d55-5e3e-98ce-894a3b0a8db4', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('obično') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('05749173-d0b3-5c26-93ef-bce6861ab292', 'multiple_choice', 'Як хорватською «зазвичай»?', 'obično', '["kasno", "buditi se", "tuširati se", "obično"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '05749173-d0b3-5c26-93ef-bce6861ab292', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('večerati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1373f322-9db9-55f0-9f6f-2f8a04a35e3f', 'type_answer', 'Напишіть хорватською: «вечеряти»', 'večerati', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1373f322-9db9-55f0-9f6f-2f8a04a35e3f', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('doručkovati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e9d5fd7c-f239-5d34-93ca-765e79316767', 'type_answer', 'Напишіть хорватською: «снідати»', 'doručkovati', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e9d5fd7c-f239-5d34-93ca-765e79316767', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fb2c9477-fd59-51ae-a1bf-a3df6b0ec13b', 'sentence_builder', 'Складіть: «Спочатку приймаю душ, потім снідаю.»', 'Prvo se tuširam, onda doručkujem.', '["doručkujem.", "se", "onda", "Prvo", "tuširam,"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fb2c9477-fd59-51ae-a1bf-a3df6b0ec13b', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b8cd99ee-448d-5291-8343-227f48099b9c', 'sentence_builder', 'Складіть: «Обідаю на роботі.»', 'Ručam na poslu.', '["poslu.", "na", "Ručam"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b8cd99ee-448d-5291-8343-227f48099b9c', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e54b0f29-90c0-550e-9b8f-827962a4b07d', 'listening', 'Прослухайте і складіть фразу', 'Budim se u šest i pol.', '["pol.", "i", "u", "šest", "se", "Budim"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e54b0f29-90c0-550e-9b8f-827962a4b07d', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('089e554a-43a2-516d-b867-9807f51ef14b', 'listening', 'Прослухайте і складіть фразу', 'Ne, večeramo u sedam.', '["večeramo", "Ne,", "sedam.", "u"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '089e554a-43a2-516d-b867-9807f51ef14b', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('18513d05-5595-5813-bac7-bf72760e5353', 'speaking', 'Я прокидаюся о сьомій.', 'Budim se u sedam.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '18513d05-5595-5813-bac7-bf72760e5353', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('737c71b1-4f4a-5fb0-b294-292f11094ea6', 'speaking', 'Зазвичай я обідаю о дванадцятій.', 'Obično ručam u dvanaest.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '737c71b1-4f4a-5fb0-b294-292f11094ea6', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b257ea30-5241-541b-8ca8-5e0711eaf75b', v_lesson, 'Ранок Тараса', 'Tarasovo jutro', 1011, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7465c771-034a-57c8-8c23-592d6135b3c4', 'b257ea30-5241-541b-8ca8-5e0711eaf75b', 'Ana', 'Kada se obično budiš?', 'Коли ти зазвичай прокидаєшся?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ab56ed36-adc8-5645-a650-0b119ffdb071', 'b257ea30-5241-541b-8ca8-5e0711eaf75b', 'Taras', 'Budim se u šest i pol.', 'Я прокидаюся о пів на сьому.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f60c1f45-103b-52b5-8aba-1ea1bf979530', 'b257ea30-5241-541b-8ca8-5e0711eaf75b', 'Ana', 'Tako rano! Zašto?', 'Так рано! Чому?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('57e55006-7cca-55d7-9956-906974e9a0d7', 'b257ea30-5241-541b-8ca8-5e0711eaf75b', 'Taras', 'Radim od osam. Prvo se tuširam, onda doručkujem.', 'Я працюю з восьмої. Спочатку приймаю душ, потім снідаю.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('57d5cd65-4009-5213-a94c-50b2e9462f6a', 'b257ea30-5241-541b-8ca8-5e0711eaf75b', 'Ana', 'A kada ideš spavati?', 'А коли ти лягаєш спати?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ab4c1707-24c1-515f-a2a4-aec80efca643', 'b257ea30-5241-541b-8ca8-5e0711eaf75b', 'Taras', 'Obično u jedanaest.', 'Зазвичай об одинадцятій.', 6) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9045e6af-47b3-515c-87ad-ea5864d940de', v_lesson, 'Робочий день Олени', 'Olenin radni dan', 1012, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('50ab2c0d-da30-585c-bbc0-9167748c2c09', '9045e6af-47b3-515c-87ad-ea5864d940de', 'Marija', 'Gdje ručaš?', 'Де ти обідаєш?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f7b9a119-fdb4-52a0-86c8-d8316f4b8395', '9045e6af-47b3-515c-87ad-ea5864d940de', 'Olena', 'Ručam na poslu, u dvanaest.', 'Обідаю на роботі, о дванадцятій.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('364674ed-85f3-5dbe-8c8d-3dbac4b0dea2', '9045e6af-47b3-515c-87ad-ea5864d940de', 'Marija', 'Kada završavaš?', 'Коли ти закінчуєш?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6aead209-20ef-534a-9261-c59aa5ba1bf5', '9045e6af-47b3-515c-87ad-ea5864d940de', 'Olena', 'U četiri. Onda kuham večeru.', 'О четвертій. Потім готую вечерю.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2a1c9519-a195-5fca-b096-4948697755bb', '9045e6af-47b3-515c-87ad-ea5864d940de', 'Marija', 'Večeraš li kasno?', 'Ти пізно вечеряєш?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0032f60f-3104-5b00-9233-80b084deb7a7', '9045e6af-47b3-515c-87ad-ea5864d940de', 'Olena', 'Ne, večeramo u sedam.', 'Ні, ми вечеряємо о сьомій.', 6) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 2: Вихідні
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '458b73de-d6b3-5bd3-98ad-c243a2fff03f';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.1: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '318b394b-c622-5dd6-8494-4c1472b6df62';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.1.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 2: Вихідні', 'Lekcija 2: Vikend', '["Розповісти, що ви робите у вихідні", "Запитати про плани друга", "Сказати, що ви любите робити"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('vikend') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vikend'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('gledati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'gledati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('čitati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'čitati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('šetati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'šetati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kuhati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kuhati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('slušati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'slušati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('glazba') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'glazba'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('film') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'film'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('knjiga') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'knjiga'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('odmarati se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'odmarati se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('park') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'park'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prijatelj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prijatelj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('bef58b13-44f9-595c-9652-e9de604fdec9', 'fill_in_the_blank', 'Mi ___ film.', 'gledamo', '["gledaju", "gledamo", "gledaš", "gledam"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'bef58b13-44f9-595c-9652-e9de604fdec9', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('šetati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9778c444-680c-52d3-b840-00a36ed19167', 'multiple_choice', 'Що означає «šetati»?', 'прогулюватися / гуляти', '["книга", "відпочивати", "прогулюватися / гуляти", "фільм"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9778c444-680c-52d3-b840-00a36ed19167', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prijatelj') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('be626c63-382a-53db-85b7-e6091a4a7aaf', 'multiple_choice', 'Що означає «prijatelj»?', 'друг', '["слухати", "дивитися", "читати", "друг"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'be626c63-382a-53db-85b7-e6091a4a7aaf', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('glazba') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ac7fca54-6e3e-5506-958e-aa9b16c9a21f', 'multiple_choice', 'Як хорватською «музика»?', 'glazba', '["čitati", "glazba", "knjiga", "film"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ac7fca54-6e3e-5506-958e-aa9b16c9a21f', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('film') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('80a29f6a-7651-5dca-a932-5355285f0abe', 'type_answer', 'Напишіть хорватською: «фільм»', 'film', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '80a29f6a-7651-5dca-a932-5355285f0abe', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('slušati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4c263e95-960f-53f1-91a2-f6877ef66d9c', 'type_answer', 'Напишіть хорватською: «слухати»', 'slušati', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4c263e95-960f-53f1-91a2-f6877ef66d9c', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2f185e99-9083-5401-a3bc-9b1745d8f5e9', 'sentence_builder', 'Складіть: «Зранку гуляю в парку.»', 'Ujutro šetam u parku.', '["šetam", "u", "parku.", "Ujutro"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2f185e99-9083-5401-a3bc-9b1745d8f5e9', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('92c20a0d-4d1e-5380-9171-5f54a2ce4a4a', 'sentence_builder', 'Складіть: «Готую і слухаю музику.»', 'Kuham i slušam glazbu.', '["i", "Kuham", "glazbu.", "slušam"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '92c20a0d-4d1e-5380-9171-5f54a2ce4a4a', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ff46d092-8009-551a-81c3-635b4e9ff655', 'listening', 'Прослухайте і складіть фразу', 'Što radiš u subotu?', '["radiš", "subotu?", "u", "Što"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ff46d092-8009-551a-81c3-635b4e9ff655', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('95baebc5-46b3-53a6-83d1-402c0773e91f', 'listening', 'Прослухайте і складіть фразу', 'Koju glazbu slušaš?', '["Koju", "slušaš?", "glazbu"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '95baebc5-46b3-53a6-83d1-402c0773e91f', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('df8001d8-0985-50ef-8968-0ee6f76e4465', 'speaking', 'Що ти робиш у суботу?', 'Što radiš u subotu?', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'df8001d8-0985-50ef-8968-0ee6f76e4465', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4e2ce2f5-1d45-5e9e-8136-eb683287c2da', 'speaking', 'Я читаю книжку.', 'Čitam knjigu.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4e2ce2f5-1d45-5e9e-8136-eb683287c2da', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7c220f4a-7621-5bb8-8846-e09bc7d4b653', v_lesson, 'Плани на суботу', 'Planovi za subotu', 1021, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ebba57ee-f502-55f0-b2ca-b8a0a3b58a17', '7c220f4a-7621-5bb8-8846-e09bc7d4b653', 'Ivan', 'Što radiš u subotu?', 'Що ти робиш у суботу?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('aa51d8f4-f589-5036-97bc-61f2d29864b0', '7c220f4a-7621-5bb8-8846-e09bc7d4b653', 'Iryna', 'Ujutro šetam u parku, a popodne čitam.', 'Зранку гуляю в парку, а після обіду читаю.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('498a1418-232f-53d0-b82d-e496a8dad5e7', '7c220f4a-7621-5bb8-8846-e09bc7d4b653', 'Ivan', 'Što čitaš?', 'Що ти читаєш?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0c5f8db7-7147-5b32-9a81-473c2ea1e3bd', '7c220f4a-7621-5bb8-8846-e09bc7d4b653', 'Iryna', 'Knjigu na hrvatskom. Polako, ali čitam!', 'Книжку хорватською. Повільно, але читаю!', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('770df97f-4d6b-56b8-b40b-7a5264782bc7', '7c220f4a-7621-5bb8-8846-e09bc7d4b653', 'Ivan', 'Bravo! Ja gledam film s prijateljima.', 'Браво! А я дивлюся фільм із друзями.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('14f7df31-c5a5-5701-a656-b7060da94b74', v_lesson, 'Спокійні вихідні', 'Miran vikend', 1022, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0580d871-233c-564d-9026-cb66a66ded0c', '14f7df31-c5a5-5701-a656-b7060da94b74', 'Petra', 'Kako provodiš vikend?', 'Як ти проводиш вихідні?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f1f530d4-82ec-5372-b97c-acb70a4e7781', '14f7df31-c5a5-5701-a656-b7060da94b74', 'Andrij', 'Odmaram se. Kuham i slušam glazbu.', 'Відпочиваю. Готую і слухаю музику.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('059e4bf1-8ac7-5cf7-8238-7576359ae1c3', '14f7df31-c5a5-5701-a656-b7060da94b74', 'Petra', 'Koju glazbu slušaš?', 'Яку музику ти слухаєш?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ae60691d-c415-5e40-9f55-4ee3bab9d16e', '14f7df31-c5a5-5701-a656-b7060da94b74', 'Andrij', 'Hrvatsku i ukrajinsku.', 'Хорватську й українську.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2fbe8eb3-d1d7-5ce1-8d0a-b2c5647acfa5', '14f7df31-c5a5-5701-a656-b7060da94b74', 'Petra', 'I ja volim hrvatsku glazbu!', 'Я теж люблю хорватську музику!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 3: Як часто?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '959e879f-a28d-5bed-9c09-16cff91ef456';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.1: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.1.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 3: Як часто?', 'Lekcija 3: Koliko često?', '["Сказати, як часто ви щось робите", "Розповісти про спорт і їжу", "Вживати дієслова ići, jesti, piti, moći, htjeti"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('uvijek') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'uvijek'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('često') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'često'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ponekad') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ponekad'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rijetko') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rijetko'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('nikad') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'nikad'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ići') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ići'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('piti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'piti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jesti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jesti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('htjeti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'htjeti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('moći') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'moći'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('trčati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'trčati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sport') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sport'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('700e5d09-f7aa-5284-9d43-ff53b84a6bac', 'fill_in_the_blank', 'Ja ___ u grad.', 'idem', '["idu", "ideš", "idem", "ide"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '700e5d09-f7aa-5284-9d43-ff53b84a6bac', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('sport') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('cf2068ba-cbfe-539f-b3c7-4b7a18ea0422', 'multiple_choice', 'Що означає «sport»?', 'спорт', '["спорт", "пити", "іноді / часом", "могти"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'cf2068ba-cbfe-539f-b3c7-4b7a18ea0422', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('moći') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8f44eed3-ee1d-59fb-b047-c4359f16f964', 'multiple_choice', 'Що означає «moći»?', 'могти', '["ніколи", "могти", "завжди", "спорт"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8f44eed3-ee1d-59fb-b047-c4359f16f964', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jesti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0e259b82-ef3a-58d3-b7df-7c277ffc7886', 'multiple_choice', 'Як хорватською «їсти»?', 'jesti', '["često", "ponekad", "jesti", "rijetko"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0e259b82-ef3a-58d3-b7df-7c277ffc7886', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('nikad') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9c8459b6-940b-56c5-a7ef-c584902c824e', 'type_answer', 'Напишіть хорватською: «ніколи»', 'nikad', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9c8459b6-940b-56c5-a7ef-c584902c824e', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('trčati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e5726227-8ccd-518a-a3c9-fdc3ca58aaaa', 'type_answer', 'Напишіть хорватською: «бігати»', 'trčati', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e5726227-8ccd-518a-a3c9-fdc3ca58aaaa', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e3f1f1e6-4f55-592f-af2d-3b0ce4db6259', 'sentence_builder', 'Складіть: «Ходжу двічі на тиждень.»', 'Idem dva puta tjedno.', '["dva", "tjedno.", "puta", "Idem"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e3f1f1e6-4f55-592f-af2d-3b0ce4db6259', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9810be7e-a70f-5624-aa23-ce6f72ef990b', 'sentence_builder', 'Складіть: «Зазвичай я п’ю чай.»', 'Obično pijem čaj.', '["pijem", "čaj.", "Obično"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9810be7e-a70f-5624-aa23-ce6f72ef990b', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f4ac5e9e-4406-57c1-ab2d-80ee7471b60e', 'listening', 'Прослухайте і складіть фразу', 'Ja trčim svaki dan, ujutro.', '["Ja", "dan,", "trčim", "svaki", "ujutro."]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f4ac5e9e-4406-57c1-ab2d-80ee7471b60e', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('df5d2152-80ad-5a68-aae6-ad0e54f4ec68', 'listening', 'Прослухайте і складіть фразу', 'Uvijek jedem kruh i jaja.', '["kruh", "i", "jaja.", "Uvijek", "jedem"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'df5d2152-80ad-5a68-aae6-ad0e54f4ec68', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('48af1a74-d053-5fca-a8d3-3a8b01df3a0e', 'speaking', 'Я часто ходжу в парк.', 'Često idem u park.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '48af1a74-d053-5fca-a8d3-3a8b01df3a0e', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c23bc9a5-d812-517c-ab47-fc4bcdde3796', 'speaking', 'Я ніколи не п’ю каву.', 'Nikad ne pijem kavu.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c23bc9a5-d812-517c-ab47-fc4bcdde3796', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b719021b-6485-5ac7-b85d-366c14029fcd', v_lesson, 'Спорт', 'Sport', 1031, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7d52d23f-5f11-58c5-8ca0-65e4e6b33a71', 'b719021b-6485-5ac7-b85d-366c14029fcd', 'Luka', 'Ideš li često na trening?', 'Ти часто ходиш на тренування?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3569afc3-6d0f-5f43-ba64-19d1eae8f9cc', 'b719021b-6485-5ac7-b85d-366c14029fcd', 'Oksana', 'Idem dva puta tjedno. A ti?', 'Ходжу двічі на тиждень. А ти?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2ba71fe7-dcdd-55e2-8b0b-01791225f172', 'b719021b-6485-5ac7-b85d-366c14029fcd', 'Luka', 'Ja trčim svaki dan, ujutro.', 'Я бігаю щодня, зранку.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('686afda5-e743-587e-bc4b-212c56c7c98c', 'b719021b-6485-5ac7-b85d-366c14029fcd', 'Oksana', 'Svaki dan? Ja to ne mogu!', 'Щодня? Я так не можу!', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('57263962-a5be-54a7-aded-027c23923644', 'b719021b-6485-5ac7-b85d-366c14029fcd', 'Luka', 'Možeš! Hoćeš li trčati sa mnom?', 'Можеш! Хочеш бігати зі мною?', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('884a5a61-45b8-5b11-93a4-dff5ab4bb0be', v_lesson, 'Кава чи чай?', 'Kava ili čaj?', 1032, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('45d2e7a5-4d67-5c33-86af-3b6e90f7e8c0', '884a5a61-45b8-5b11-93a4-dff5ab4bb0be', 'Marta', 'Piješ li kavu?', 'Ти п’єш каву?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('89a4d0bf-ae4b-5142-8768-4535d17e6adb', '884a5a61-45b8-5b11-93a4-dff5ab4bb0be', 'Taras', 'Rijetko. Obično pijem čaj.', 'Рідко. Зазвичай я п’ю чай.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('059e220d-6df9-5013-8157-04f9186443e7', '884a5a61-45b8-5b11-93a4-dff5ab4bb0be', 'Marta', 'A što jedeš za doručak?', 'А що ти їси на сніданок?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5b1b9f08-de02-50d9-9ea8-d8ae1d93dc02', '884a5a61-45b8-5b11-93a4-dff5ab4bb0be', 'Taras', 'Uvijek jedem kruh i jaja.', 'Я завжди їм хліб і яйця.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ec110dec-02cc-595e-a4f8-132c3c5fe364', '884a5a61-45b8-5b11-93a4-dff5ab4bb0be', 'Marta', 'Ja nikad ne jedem ujutro.', 'А я ніколи не їм зранку.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 4: Домашні справи
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '9c38f909-9275-5194-9a6e-f799c6e416ce';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.1: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.1.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 4: Домашні справи', 'Lekcija 4: Kućanski poslovi', '["Розподілити домашні справи", "Назвати, хто що робить удома", "Вживати prati, čistiti, usisavati в теперішньому часі"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('kućanski poslovi') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kućanski poslovi'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('čistiti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'čistiti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('usisavati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'usisavati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('peglati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'peglati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('spremati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'spremati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('suđe') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'suđe'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rublje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rublje'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('iznositi') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'iznositi'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('cimerica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'cimerica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pomagati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pomagati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prašina') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prašina'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3218e589-0ba3-5603-a17a-ae9ec3d699a0', 'fill_in_the_blank', 'Tata ___ suđe.', 'pere', '["perem", "pere", "peru", "pereš"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3218e589-0ba3-5603-a17a-ae9ec3d699a0', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('kućanski poslovi') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2b0649ae-3e7a-5a8a-861f-39e9e02018c3', 'multiple_choice', 'Що означає «kućanski poslovi»?', 'домашні справи', '["пилососити", "домашні справи", "прибирати; готувати; зберігати", "виносити"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2b0649ae-3e7a-5a8a-861f-39e9e02018c3', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('usisavati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('69585e77-3d3f-5a05-905a-ee5e798ae255', 'multiple_choice', 'Що означає «usisavati»?', 'пилососити', '["пилососити", "прасувати", "прибирати; готувати; зберігати", "білизна (для прання)"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '69585e77-3d3f-5a05-905a-ee5e798ae255', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pomagati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4b79d1e0-dfeb-5feb-8ac2-21f75e8672db', 'multiple_choice', 'Як хорватською «допомагати»?', 'pomagati', '["pomagati", "prati", "peglati", "prašina"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4b79d1e0-dfeb-5feb-8ac2-21f75e8672db', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('48ff61fb-e8b1-520a-ab59-f74ea629f284', 'type_answer', 'Напишіть хорватською: «мити / прати»', 'prati', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '48ff61fb-e8b1-520a-ab59-f74ea629f284', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('suđe') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('78cbd093-4a32-546a-9b17-3c0281127797', 'type_answer', 'Напишіть хорватською: «посуд»', 'suđe', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '78cbd093-4a32-546a-9b17-3c0281127797', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3a00f34d-e4d6-569d-b3b3-e1723a31bd09', 'sentence_builder', 'Складіть: «Ти пилососиш кімнати.»', 'Ti usisavaš sobe.', '["usisavaš", "Ti", "sobe."]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3a00f34d-e4d6-569d-b3b3-e1723a31bd09', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9202fa2c-2e09-5d3a-acbc-d03d31b24652', 'sentence_builder', 'Складіть: «Я перу білизну й прасую.»', 'Ja perem rublje i peglam.', '["peglam.", "rublje", "perem", "Ja", "i"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9202fa2c-2e09-5d3a-acbc-d03d31b24652', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fed6efb0-033f-589a-b1e6-3711de3a3ca8', 'listening', 'Прослухайте і складіть фразу', 'Danas je subota. Čistimo stan!', '["Danas", "stan!", "Čistimo", "subota.", "je"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fed6efb0-033f-589a-b1e6-3711de3a3ca8', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c266c2ff-e584-528f-a8aa-6c809eb7f7f7', 'listening', 'Прослухайте і складіть фразу', 'I iznosiš smeće?', '["I", "smeće?", "iznosiš"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c266c2ff-e584-528f-a8aa-6c809eb7f7f7', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('65b1adc4-abc6-52d1-bc97-56460656ddae', 'speaking', 'Я мию посуд.', 'Perem suđe.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '65b1adc4-abc6-52d1-bc97-56460656ddae', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0f52a311-8606-5249-92c6-32b6c104b42e', 'speaking', 'Хто прибирає кухню?', 'Tko sprema kuhinju?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0f52a311-8606-5249-92c6-32b6c104b42e', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cbbe13fb-d190-5755-b414-a88db7351083', v_lesson, 'Субота вдома', 'Subota kod kuće', 1041, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3af6c813-f667-56bf-b7f1-05e48a7093a2', 'cbbe13fb-d190-5755-b414-a88db7351083', 'Mama', 'Danas je subota. Čistimo stan!', 'Сьогодні субота. Прибираємо квартиру!', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ed571ed5-722a-5df8-bd41-c4805a032c65', 'cbbe13fb-d190-5755-b414-a88db7351083', 'Sin', 'Opet? Što ja radim?', 'Знову? А що роблю я?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('13f40c6b-ba14-5705-b0ec-7c537da01308', 'cbbe13fb-d190-5755-b414-a88db7351083', 'Mama', 'Ti usisavaš sobe, a tata pere suđe.', 'Ти пилососиш кімнати, а тато миє посуд.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8a844170-b88b-5220-ac6f-9d006a95015a', 'cbbe13fb-d190-5755-b414-a88db7351083', 'Sin', 'A ti?', 'А ти?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c7f245a8-69be-5bf3-b687-406759ea6f46', 'cbbe13fb-d190-5755-b414-a88db7351083', 'Mama', 'Ja perem rublje i peglam.', 'Я перу білизну й прасую.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('915d9951-0f5e-518d-86b1-0eeb5f45495f', v_lesson, 'Сусідка по квартирі', 'Cimerica', 1042, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a8a93dd7-2c68-54af-bcd7-a8700554cbdf', '915d9951-0f5e-518d-86b1-0eeb5f45495f', 'Olena', 'Tko danas sprema kuhinju?', 'Хто сьогодні прибирає кухню?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('165bed66-00a0-5f71-9a2a-70aa14f72506', '915d9951-0f5e-518d-86b1-0eeb5f45495f', 'Lana', 'Ja spremam kuhinju ponedjeljkom i srijedom.', 'Я прибираю кухню по понеділках і середах.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a3a5fab1-4943-5cab-af11-fa65a5e9dde0', '915d9951-0f5e-518d-86b1-0eeb5f45495f', 'Olena', 'Dobro, onda ja čistim kupaonicu i brišem prašinu.', 'Добре, тоді я мию ванну й витираю пил.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('31d3dda6-81b8-505d-95ac-784b17287fb3', '915d9951-0f5e-518d-86b1-0eeb5f45495f', 'Lana', 'I iznosiš smeće?', 'І виносиш сміття?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('78dae8d1-e317-5b7c-96df-0975531b1d14', '915d9951-0f5e-518d-86b1-0eeb5f45495f', 'Olena', 'Može. Hvala ti što pomažeš!', 'Добре. Дякую, що допомагаєш!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.1 · урок 5: Збираємося зранку
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '54f17cf7-3c17-5978-b400-b6b6888c9f84';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.1: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.1.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 5: Збираємося зранку', 'Lekcija 5: Jutarnje spremanje', '["Попросити дитину вмитися й одягнутися", "Назвати речі у ванній", "Вживати наказовий спосіб: umij se, obuci se"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('umiti se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'umiti se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('oprati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'oprati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zub') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zub'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('četkica za zube') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'četkica za zube'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sapun') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sapun'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ručnik') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ručnik'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('obući se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'obući se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('češljati se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'češljati se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('žuriti se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'žuriti se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('brzo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'brzo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('spreman') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'spreman'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vani') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vani'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2da1eb38-2c23-56ac-9790-d808905e0308', 'fill_in_the_blank', '___ zube, molim te!', 'Operi', '["Pere", "Oprati", "Operi", "Perem"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2da1eb38-2c23-56ac-9790-d808905e0308', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('obući se') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6f411e7d-3c03-5e3b-861e-e4483218ac17', 'multiple_choice', 'Що означає «obući se»?', 'одягнутися', '["поспішати", "рушник", "надворі", "одягнутися"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6f411e7d-3c03-5e3b-861e-e4483218ac17', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('spreman') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d8b21aa9-69f6-55aa-996d-915d5d7b8ecb', 'multiple_choice', 'Що означає «spreman»?', 'готовий', '["зубна щітка", "мило", "умитися", "готовий"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd8b21aa9-69f6-55aa-996d-915d5d7b8ecb', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('češljati se') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1b0b8ec7-cea9-5e69-8e09-1561a165e64f', 'multiple_choice', 'Як хорватською «причісуватися»?', 'češljati se', '["češljati se", "ručnik", "sapun", "oprati"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1b0b8ec7-cea9-5e69-8e09-1561a165e64f', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ručnik') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('519193c5-5b31-58ba-b85f-2daf829341a5', 'type_answer', 'Напишіть хорватською: «рушник»', 'ručnik', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '519193c5-5b31-58ba-b85f-2daf829341a5', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('vani') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('69625641-dc23-5c47-84fb-397261614f21', 'type_answer', 'Напишіть хорватською: «надворі»', 'vani', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '69625641-dc23-5c47-84fb-397261614f21', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f9c97067-b05a-5c4d-8e28-2e4d0195ac1a', 'sentence_builder', 'Складіть: «Де моя зубна щітка?»', 'Gdje je moja četkica za zube?', '["je", "za", "Gdje", "zube?", "moja", "četkica"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f9c97067-b05a-5c4d-8e28-2e4d0195ac1a', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('058d9056-7afe-574f-baf1-c163ebc86926', 'sentence_builder', 'Складіть: «Вдягни сині штани.»', 'Obuci plave hlače.', '["plave", "hlače.", "Obuci"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '058d9056-7afe-574f-baf1-c163ebc86926', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1a74ecbe-d9ff-56a9-8eb1-a55133aea3af', 'listening', 'Прослухайте і складіть фразу', 'U kupaonici, pored sapuna. Brzo!', '["kupaonici,", "pored", "U", "sapuna.", "Brzo!"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1a74ecbe-d9ff-56a9-8eb1-a55133aea3af', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('be27d30c-9ea4-5004-962f-42cfef211d22', 'listening', 'Прослухайте і складіть фразу', 'Spreman sam!', '["sam!", "Spreman"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'be27d30c-9ea4-5004-962f-42cfef211d22', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5872b4e7-14e7-5b3b-aa24-087fa630d800', 'speaking', 'Мені треба поспішати.', 'Moram se žuriti.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5872b4e7-14e7-5b3b-aa24-087fa630d800', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('409860e0-d2ce-5d50-989b-11762a16820f', 'speaking', 'Де рушник?', 'Gdje je ručnik?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '409860e0-d2ce-5d50-989b-11762a16820f', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('41d1fcde-eee7-5dcb-b733-c0c42fa651f9', v_lesson, 'Вставай!', 'Ustani!', 1051, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3f8952a4-89ce-505d-86e0-9376f2e137cd', '41d1fcde-eee7-5dcb-b733-c0c42fa651f9', 'Mama', 'Dino, ustani! Kasnimo!', 'Діно, вставай! Ми запізнюємося!', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a76f3a7a-dafa-5e4e-8cf7-2a36b4fd840f', '41d1fcde-eee7-5dcb-b733-c0c42fa651f9', 'Dino', 'Još pet minuta, molim te.', 'Ще п’ять хвилин, будь ласка.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('bb021269-08dc-56da-8741-fcb87cae8772', '41d1fcde-eee7-5dcb-b733-c0c42fa651f9', 'Mama', 'Ne! Umij se i operi zube.', 'Ні! Умийся й почисть зуби.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('33611345-69e9-53e5-b271-070058636184', '41d1fcde-eee7-5dcb-b733-c0c42fa651f9', 'Dino', 'Gdje je moja četkica za zube?', 'Де моя зубна щітка?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a0dc461b-068b-5b8f-b7dd-84f37c396175', '41d1fcde-eee7-5dcb-b733-c0c42fa651f9', 'Mama', 'U kupaonici, pored sapuna. Brzo!', 'У ванній, біля мила. Швидко!', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c57e5b9d-bdd9-59c3-aad1-b597214a0681', v_lesson, 'Що вдягнути?', 'Što obući?', 1052, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('385ae438-83b5-5ec8-bef6-0fc0a5f8f219', 'c57e5b9d-bdd9-59c3-aad1-b597214a0681', 'Dino', 'Mama, što da obučem?', 'Мамо, що мені вдягнути?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7cbe840e-eaab-5132-8d55-39e4685ef8e7', 'c57e5b9d-bdd9-59c3-aad1-b597214a0681', 'Mama', 'Obuci plave hlače i bijelu majicu.', 'Вдягни сині штани й білу футболку.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a5ffd6c8-ae25-57cf-95cb-ede4e5402162', 'c57e5b9d-bdd9-59c3-aad1-b597214a0681', 'Dino', 'A jaknu?', 'А куртку?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('86a4cb96-ab36-5cf5-a5cb-96f60cc86b2f', 'c57e5b9d-bdd9-59c3-aad1-b597214a0681', 'Mama', 'Da, vani je hladno. Počešljaj se i idemo!', 'Так, надворі холодно. Причешися — і ходімо!', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cf62bd78-66f7-5150-81cf-075cd0d6f910', 'c57e5b9d-bdd9-59c3-aad1-b597214a0681', 'Dino', 'Spreman sam!', 'Я готовий!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 6: Столик на двох
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '5e4a1c56-3931-58bb-81af-cb598966da77';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.2: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.2.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 6: Столик на двох', 'Lekcija 6: Stol za dvoje', '["Забронювати столик", "Замовити закуску, основну страву і напій", "Вживати знахідний відмінок: juhu, ribu, salatu"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('restoran') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'restoran'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rezervirati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rezervirati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jelovnik') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jelovnik'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('predjelo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'predjelo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('glavno jelo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'glavno jelo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('desert') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'desert'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('naručiti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'naručiti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('juha') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'juha'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('riba') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'riba'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('salata') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'salata'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vino') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vino'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('račun') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'račun'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3ca18091-c017-55ac-ac74-db6cc55f1a7d', 'fill_in_the_blank', 'Želim ___, molim.', 'juhu', '["juhom", "juhu", "juhe", "juha"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3ca18091-c017-55ac-ac74-db6cc55f1a7d', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('vino') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c0491339-dce7-5cd4-94b4-d1e64c9bded0', 'multiple_choice', 'Що означає «vino»?', 'вино', '["головна страва", "закуска", "вино", "меню"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c0491339-dce7-5cd4-94b4-d1e64c9bded0', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('desert') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c5b63813-b43e-5c2d-ad0b-a62279a130f2', 'multiple_choice', 'Що означає «desert»?', 'десерт', '["суп / юшка", "головна страва", "замовити", "десерт"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c5b63813-b43e-5c2d-ad0b-a62279a130f2', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('restoran') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e0487cef-20ad-5062-a923-bed0076168d9', 'multiple_choice', 'Як хорватською «ресторан»?', 'restoran', '["riba", "salata", "predjelo", "restoran"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e0487cef-20ad-5062-a923-bed0076168d9', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rezervirati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d7a69b44-7029-52c8-9da8-95e91b6658a2', 'type_answer', 'Напишіть хорватською: «забронювати»', 'rezervirati', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd7a69b44-7029-52c8-9da8-95e91b6658a2', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('naručiti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1118d499-a5e5-5363-b8fc-554f6a542589', 'type_answer', 'Напишіть хорватською: «замовити»', 'naručiti', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1118d499-a5e5-5363-b8fc-554f6a542589', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('46412f32-28a5-5361-9ec9-cb2d6ad7c4c6', 'sentence_builder', 'Складіть: «Я хочу забронювати столик на двох.»', 'Želim rezervirati stol za dvoje.', '["rezervirati", "stol", "Želim", "za", "dvoje."]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '46412f32-28a5-5361-9ec9-cb2d6ad7c4c6', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0d0f8b02-1bfb-5013-a826-ed3d523aa322', 'sentence_builder', 'Складіть: «Тільки рахунок, будь ласка.»', 'Samo račun, molim.', '["molim.", "račun,", "Samo"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0d0f8b02-1bfb-5013-a826-ed3d523aa322', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('97dd09d5-a3b7-5b96-83fe-7b7a0cb6c483', 'listening', 'Прослухайте і складіть фразу', 'Za petak u osam.', '["petak", "osam.", "u", "Za"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '97dd09d5-a3b7-5b96-83fe-7b7a0cb6c483', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9f2a0afc-fca6-56ce-a35b-d1c1b72b390a', 'listening', 'Прослухайте і складіть фразу', 'Želite li desert?', '["li", "desert?", "Želite"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9f2a0afc-fca6-56ce-a35b-d1c1b72b390a', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('abfad817-51d9-57ab-b87f-fea531cda18c', 'speaking', 'Я хочу рибу і салат.', 'Želim ribu i salatu.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'abfad817-51d9-57ab-b87f-fea531cda18c', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('34e56167-26f8-518a-bccc-4bd1f7f853ec', 'speaking', 'Можна меню?', 'Mogu li dobiti jelovnik?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '34e56167-26f8-518a-bccc-4bd1f7f853ec', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8b18710c-9d6f-5b9d-bed3-755a930d4963', v_lesson, 'Бронювання', 'Rezervacija', 1061, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('94830879-e88b-5d8a-af9f-8ae00981bc15', '8b18710c-9d6f-5b9d-bed3-755a930d4963', 'Konobar', 'Restoran Lavanda, izvolite.', 'Ресторан «Лаванда», слухаю.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('93a5ffe1-8fcf-58ef-8b7d-4a0fc8022aef', '8b18710c-9d6f-5b9d-bed3-755a930d4963', 'Andrij', 'Dobar dan. Želim rezervirati stol za dvoje.', 'Добрий день. Я хочу забронювати столик на двох.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('58288cf0-c3f6-54d1-8aa5-98f0f3b2293b', '8b18710c-9d6f-5b9d-bed3-755a930d4963', 'Konobar', 'Za kada?', 'На коли?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e8991c69-a1e1-57b0-80e3-2c0f9b603c8a', '8b18710c-9d6f-5b9d-bed3-755a930d4963', 'Andrij', 'Za petak u osam.', 'На п’ятницю на восьму.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4c42a128-8317-52b5-86de-9e44b9204da5', '8b18710c-9d6f-5b9d-bed3-755a930d4963', 'Konobar', 'U redu. Na koje ime?', 'Добре. На яке ім’я?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cb2cc3c4-ba32-5b25-aa41-e490bce0d992', '8b18710c-9d6f-5b9d-bed3-755a930d4963', 'Andrij', 'Na ime Kovalenko.', 'На ім’я Коваленко.', 6) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('301ad81c-8cb3-5aaa-b933-fc0b5875b593', v_lesson, 'Замовлення', 'Narudžba', 1062, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('64f46d36-13e2-509e-b9a5-e9f989ac3246', '301ad81c-8cb3-5aaa-b933-fc0b5875b593', 'Konobarica', 'Što želite naručiti?', 'Що бажаєте замовити?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('58c76d25-2d8d-5fa5-a34c-5202a7704725', '301ad81c-8cb3-5aaa-b933-fc0b5875b593', 'Iryna', 'Za predjelo juhu, a za glavno jelo ribu.', 'На закуску суп, а на основну страву рибу.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d2e4a418-a299-557e-917b-aff33a7b958f', '301ad81c-8cb3-5aaa-b933-fc0b5875b593', 'Konobarica', 'A za piće?', 'А що питимете?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4d7d57fd-bcf8-5b4c-918d-83088c07f496', '301ad81c-8cb3-5aaa-b933-fc0b5875b593', 'Iryna', 'Čašu bijelog vina, molim.', 'Келих білого вина, будь ласка.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b812f7b6-4438-53c7-8371-e4dbd4f83d1f', '301ad81c-8cb3-5aaa-b933-fc0b5875b593', 'Konobarica', 'Želite li desert?', 'Бажаєте десерт?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('764a2c1e-0a9b-5ba6-b3cc-19f89c20722d', '301ad81c-8cb3-5aaa-b933-fc0b5875b593', 'Iryna', 'Ne, hvala. Samo račun, molim.', 'Ні, дякую. Тільки рахунок, будь ласка.', 6) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 7: Готуємо вдома
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '3e652232-866b-5edf-ac05-d61ee7a325fe';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.2: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.2.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 7: Готуємо вдома', 'Lekcija 7: Kuhamo kod kuće', '["Зрозуміти простий рецепт", "Попросити щось подати чи принести", "Вживати наказовий спосіб: dodaj, donesi"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('kuhati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kuhati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ulje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ulje'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sol') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sol'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('papar') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'papar'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('luk') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'luk'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('češnjak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'češnjak'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rajčica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rajčica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tjestenina') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tjestenina'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tanjur') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tanjur'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vilica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vilica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('žlica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'žlica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('nož') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'nož'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1ca90b02-c1e8-54df-8f97-0a068c941509', 'fill_in_the_blank', '___ sol, molim te!', 'Dodaj', '["Dodati", "Dodaj", "Dodam", "Doda"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1ca90b02-c1e8-54df-8f97-0a068c941509', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('ulje') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fd40d32d-161b-5f5b-b2c3-f3bb2789f070', 'multiple_choice', 'Що означає «ulje»?', 'олія', '["сіль", "олія", "часник", "ніж"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fd40d32d-161b-5f5b-b2c3-f3bb2789f070', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kuhati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('250cc7cb-ec9c-5cb0-88ec-09531b618f4a', 'multiple_choice', 'Що означає «kuhati»?', 'варити / готувати їжу', '["перець", "цибуля", "ложка", "варити / готувати їжу"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '250cc7cb-ec9c-5cb0-88ec-09531b618f4a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('luk') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8f523e27-c2f6-51e6-ab05-ec2318ad5332', 'multiple_choice', 'Як хорватською «цибуля»?', 'luk', '["sol", "tanjur", "luk", "rajčica"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8f523e27-c2f6-51e6-ab05-ec2318ad5332', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rajčica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d894989a-83bf-5eba-9a6a-eb8c3ecfdc24', 'type_answer', 'Напишіть хорватською: «помідор»', 'rajčica', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd894989a-83bf-5eba-9a6a-eb8c3ecfdc24', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('tanjur') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('230e3f8f-21ba-57d5-8504-244b18ea356e', 'type_answer', 'Напишіть хорватською: «тарілка»', 'tanjur', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '230e3f8f-21ba-57d5-8504-244b18ea356e', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b8b5e742-391f-5d81-9cc8-2d9fc0a111cd', 'sentence_builder', 'Складіть: «Наріж цибулю й часник.»', 'Nareži luk i češnjak.', '["Nareži", "i", "češnjak.", "luk"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b8b5e742-391f-5d81-9cc8-2d9fc0a111cd', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('960f75df-6c41-550b-97dd-051894c25426', 'sentence_builder', 'Складіть: «Будь ласка, принеси тарілки.»', 'Molim te, donesi tanjure.', '["donesi", "Molim", "tanjure.", "te,"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '960f75df-6c41-550b-97dd-051894c25426', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8beb42ce-f2e2-5d7f-8d74-cf159ba5b1a8', 'listening', 'Прослухайте і складіть фразу', 'Prvo zakuhaj vodu.', '["zakuhaj", "Prvo", "vodu."]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8beb42ce-f2e2-5d7f-8d74-cf159ba5b1a8', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ee0a6cba-ef57-5219-85cb-946501c76ada', 'listening', 'Прослухайте і складіть фразу', 'Pazi, vruće je!', '["Pazi,", "je!", "vruće"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ee0a6cba-ef57-5219-85cb-946501c76ada', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0c1756f3-fcf0-5a62-8b89-7d204fc738d9', 'speaking', 'Додай сіль, будь ласка.', 'Dodaj sol, molim te.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0c1756f3-fcf0-5a62-8b89-7d204fc738d9', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fc92968e-e9f3-5a30-a89f-5b2339dd1d01', 'speaking', 'Можна скуштувати?', 'Mogu li probati?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fc92968e-e9f3-5a30-a89f-5b2339dd1d01', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('91c0b399-3bf9-53ec-a78f-3758d61bd81a', v_lesson, 'Рецепт пасти', 'Recept za tjesteninu', 1071, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3f42db1f-6b5b-5ccb-b443-a034ba77a521', '91c0b399-3bf9-53ec-a78f-3758d61bd81a', 'Baka', 'Prvo zakuhaj vodu.', 'Спочатку закип’яти воду.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9208a6e0-d282-57c7-86f8-641d27fe75f2', '91c0b399-3bf9-53ec-a78f-3758d61bd81a', 'Dino', 'A onda?', 'А потім?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('748887e3-d893-558d-965b-386f1244f2a2', '91c0b399-3bf9-53ec-a78f-3758d61bd81a', 'Baka', 'Nareži luk i češnjak.', 'Наріж цибулю й часник.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('917b571b-39a9-50fb-8d72-80b79c97fb50', '91c0b399-3bf9-53ec-a78f-3758d61bd81a', 'Dino', 'Koliko ulja?', 'Скільки олії?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e77445d9-43c0-58c2-92b7-14b8bf3bc3c8', '91c0b399-3bf9-53ec-a78f-3758d61bd81a', 'Baka', 'Malo. Dodaj rajčice, sol i papar.', 'Трохи. Додай помідори, сіль і перець.', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('459f63df-919c-5aa2-8a2d-22c772cee035', '91c0b399-3bf9-53ec-a78f-3758d61bd81a', 'Dino', 'Mmm, miriše odlično!', 'Ммм, чудово пахне!', 6) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a05d1db3-4804-5ea4-86a9-83e3af2c9e4a', v_lesson, 'Накриваємо на стіл', 'Postavljamo stol', 1072, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3b9b774a-9c68-5f60-8e16-68a45ba18085', 'a05d1db3-4804-5ea4-86a9-83e3af2c9e4a', 'Mama', 'Molim te, donesi tanjure.', 'Будь ласка, принеси тарілки.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('093e44e1-33f6-50ee-8de1-32bb96172c9f', 'a05d1db3-4804-5ea4-86a9-83e3af2c9e4a', 'Sofija', 'Koliko tanjura?', 'Скільки тарілок?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7abc6787-3b66-5ac8-933b-6463ab3c0a6f', 'a05d1db3-4804-5ea4-86a9-83e3af2c9e4a', 'Mama', 'Četiri. I vilice, noževe i žlice.', 'Чотири. І виделки, ножі й ложки.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9098fa79-c4b9-562c-896c-7f0154385b42', 'a05d1db3-4804-5ea4-86a9-83e3af2c9e4a', 'Sofija', 'Evo. Mogu li probati?', 'Ось. Можна скуштувати?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('deb1799e-3369-5c5e-a41b-53d241e1247a', 'a05d1db3-4804-5ea4-86a9-83e3af2c9e4a', 'Mama', 'Možeš. Pazi, vruće je!', 'Можна. Обережно, гаряче!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 8: На ринку
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '46a89cf5-41e0-50a2-99b1-f4e66a5ff146';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.2: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.2.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 8: На ринку', 'Lekcija 8: Na tržnici', '["Купити фрукти й овочі на вагу", "Запитати, чи є товар", "Вживати родовий відмінок: kilogram grožđa, boca mlijeka"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('tržnica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tržnica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kilogram') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kilogram'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('svježe') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'svježe'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('voće') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'voće'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('povrće') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'povrće'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('grožđe') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'grožđe'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kruška') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kruška'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('breskva') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'breskva'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sir') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sir'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('komad') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'komad'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('boca') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'boca'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('mlijeko') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'mlijeko'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7721f275-35e8-54bb-a67b-7839cc6342ef', 'fill_in_the_blank', 'Kilogram ___, molim.', 'grožđa', '["grožđu", "grožđe", "grožđem", "grožđa"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7721f275-35e8-54bb-a67b-7839cc6342ef', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('voće') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4948b85e-c772-5ad7-8a6a-10c1ef996103', 'multiple_choice', 'Що означає «voće»?', 'фрукти', '["груша", "фрукти", "виноград", "кілограм"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4948b85e-c772-5ad7-8a6a-10c1ef996103', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('komad') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('41835e1a-f223-5f98-899a-3079bedbdd12', 'multiple_choice', 'Що означає «komad»?', 'шматок, штука', '["кілограм", "груша", "шматок, штука", "овочі"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '41835e1a-f223-5f98-899a-3079bedbdd12', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sir') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6b61adec-1b1c-50ca-85ca-d64b8236c97e', 'multiple_choice', 'Як хорватською «сир»?', 'sir', '["sir", "grožđe", "komad", "kilogram"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6b61adec-1b1c-50ca-85ca-d64b8236c97e', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tržnica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7020f443-edfe-5813-bf91-4f3aad04c082', 'type_answer', 'Напишіть хорватською: «ринок / базар»', 'tržnica', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7020f443-edfe-5813-bf91-4f3aad04c082', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('povrće') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('11167aba-4fcc-5191-8866-281fd6a4cbea', 'type_answer', 'Напишіть хорватською: «овочі»', 'povrće', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '11167aba-4fcc-5191-8866-281fd6a4cbea', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('054d8612-46d2-5f81-aa98-accae1f74029', 'sentence_builder', 'Складіть: «Кілограм винограду, будь ласка.»', 'Kilogram grožđa, molim.', '["molim.", "grožđa,", "Kilogram"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '054d8612-46d2-5f81-aa98-accae1f74029', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4c2d2fe5-b088-5966-9277-14cd9a582935', 'sentence_builder', 'Складіть: «Один шматок і пляшку молока.»', 'Jedan komad i bocu mlijeka.', '["Jedan", "komad", "mlijeka.", "i", "bocu"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4c2d2fe5-b088-5966-9277-14cd9a582935', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('07f862bd-cf89-5881-8f34-155786616904', 'listening', 'Прослухайте і складіть фразу', 'Izvolite, sve je svježe!', '["svježe!", "sve", "je", "Izvolite,"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '07f862bd-cf89-5881-8f34-155786616904', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c8733fae-52de-5622-ba64-11a297ea6e57', 'listening', 'Прослухайте і складіть фразу', 'Mlijeka danas nemam, nažalost.', '["nažalost.", "danas", "Mlijeka", "nemam,"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c8733fae-52de-5622-ba64-11a297ea6e57', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8ecd3597-e3cf-5c2b-82d6-07984179643d', 'speaking', 'Пляшку води, будь ласка.', 'Bocu vode, molim.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8ecd3597-e3cf-5c2b-82d6-07984179643d', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('83cfa532-bdb3-5afa-b8ca-1c5ef57c6783', 'speaking', 'Скільки коштує кілограм?', 'Koliko košta kilogram?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '83cfa532-bdb3-5afa-b8ca-1c5ef57c6783', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('278e7d05-5ad8-5266-80ae-ded17ba4bcba', v_lesson, 'Фрукти', 'Voće', 1081, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4bdf0b6c-d785-5744-a8d0-8cccb49d13bf', '278e7d05-5ad8-5266-80ae-ded17ba4bcba', 'Prodavačica', 'Izvolite, sve je svježe!', 'Прошу, усе свіже!', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('58cb2e08-817c-5d4d-8276-8821a750d1dc', '278e7d05-5ad8-5266-80ae-ded17ba4bcba', 'Olena', 'Kilogram grožđa i pola kilograma krušaka, molim.', 'Кілограм винограду й півкілограма груш, будь ласка.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3defb6a2-4fad-5e34-aee3-89858fdaf169', '278e7d05-5ad8-5266-80ae-ded17ba4bcba', 'Prodavačica', 'Još nešto? Breskve su danas jako slatke.', 'Ще щось? Персики сьогодні дуже солодкі.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ed79eaeb-8370-57cc-a99b-a00862582f0a', '278e7d05-5ad8-5266-80ae-ded17ba4bcba', 'Olena', 'Dobro, i tri breskve.', 'Добре, і три персики.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1fc592b7-7b33-5bad-9577-754dd57cbf1e', '278e7d05-5ad8-5266-80ae-ded17ba4bcba', 'Prodavačica', 'To je sedam eura.', 'Це сім євро.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f41e10b5-4923-5cb9-b388-c5ea3e85e4d8', v_lesson, 'Сир і молоко', 'Sir i mlijeko', 1082, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('55416bb8-8786-5e7a-895d-12b03f438939', 'f41e10b5-4923-5cb9-b388-c5ea3e85e4d8', 'Kupac', 'Imate li domaćeg sira?', 'У вас є домашній сир?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8376aef3-2d00-568c-8ff4-d89b8dcda1d8', 'f41e10b5-4923-5cb9-b388-c5ea3e85e4d8', 'Prodavač', 'Imam. Koliko želite?', 'Є. Скільки бажаєте?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('593c1cdc-5a6c-59da-a5af-7717e954bac5', 'f41e10b5-4923-5cb9-b388-c5ea3e85e4d8', 'Kupac', 'Jedan komad. I bocu mlijeka.', 'Один шматок. І пляшку молока.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('76779b5a-026d-522d-b7fd-7c504a1eb023', 'f41e10b5-4923-5cb9-b388-c5ea3e85e4d8', 'Prodavač', 'Mlijeka danas nemam, nažalost.', 'Молока сьогодні, на жаль, немає.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('56c4289f-5bf6-51a0-af94-04394b98b7bc', 'f41e10b5-4923-5cb9-b388-c5ea3e85e4d8', 'Kupac', 'Nema problema. Hvala!', 'Нічого страшного. Дякую!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 9: У кафе й пекарні
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '1e8c2d0e-28f6-5873-aa9f-5d0ad2567fb8';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.2: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.2.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 9: У кафе й пекарні', 'Lekcija 9: U kafiću i pekari', '["Замовити каву, чай і щось солодке", "Купити випічку з собою", "Вживати знахідний відмінок: kavu, jednu kavu"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('kafić') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kafić'; end if;
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
  select id into v_id from public.lexemes where lower(lemma) = lower('kolač') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kolač'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sladoled') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sladoled'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('burek') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'burek'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pecivo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pecivo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jogurt') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jogurt'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kava za van') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kava za van'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('domaći') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'domaći'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('konobar') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'konobar'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('slatko') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'slatko'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('91426657-ee30-55ea-bb5c-8294399728b5', 'fill_in_the_blank', 'Molim jednu ___.', 'kavu', '["kava", "kave", "kavu", "kavom"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '91426657-ee30-55ea-bb5c-8294399728b5', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('šećer') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c2b34dae-fbd0-5a64-b637-841af985bfaa', 'multiple_choice', 'Що означає «šećer»?', 'цукор', '["кафе / кав''ярня", "домашній", "цукор", "тістечко / пиріг"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c2b34dae-fbd0-5a64-b637-841af985bfaa', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('burek') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('649bec92-f455-5128-8389-dea1b7c05c9f', 'multiple_choice', 'Що означає «burek»?', 'бурек (листковий пиріг)', '["офіціант", "йогурт", "кафе / кав''ярня", "бурек (листковий пиріг)"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '649bec92-f455-5128-8389-dea1b7c05c9f', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('konobar') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1715166b-8c8d-5fe9-a6a7-05068109edea', 'multiple_choice', 'Як хорватською «офіціант»?', 'konobar', '["kava za van", "slatko", "burek", "konobar"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1715166b-8c8d-5fe9-a6a7-05068109edea', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kafić') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('062380db-9279-5d43-bd16-7529aae08abc', 'type_answer', 'Напишіть хорватською: «кафе / кав''ярня»', 'kafić', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '062380db-9279-5d43-bd16-7529aae08abc', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('jogurt') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ef540a9a-f8fd-5314-b368-b9bcd8e7f66d', 'type_answer', 'Напишіть хорватською: «йогурт»', 'jogurt', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ef540a9a-f8fd-5314-b368-b9bcd8e7f66d', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6753eded-a784-541d-adef-14f78c3ed80c', 'sentence_builder', 'Складіть: «Один бурек із сиром, будь ласка.»', 'Jedan burek sa sirom, molim.', '["molim.", "sa", "sirom,", "burek", "Jedan"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6753eded-a784-541d-adef-14f78c3ed80c', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a697b4aa-ebfd-5eb0-8389-e9c77622dd51', 'sentence_builder', 'Складіть: «Цукор на столі.»', 'Šećer je na stolu.', '["je", "stolu.", "na", "Šećer"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a697b4aa-ebfd-5eb0-8389-e9c77622dd51', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7495ac8f-86dd-564f-b69c-aa2ced2d8998', 'listening', 'Прослухайте і складіть фразу', 'Želite li nešto slatko?', '["Želite", "slatko?", "li", "nešto"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7495ac8f-86dd-564f-b69c-aa2ced2d8998', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2c4a4234-0eb3-5286-bbd5-fcdf0d6bfefb', 'listening', 'Прослухайте і складіть фразу', 'Još nešto? Jogurt?', '["nešto?", "Jogurt?", "Još"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2c4a4234-0eb3-5286-bbd5-fcdf0d6bfefb', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('54c1c306-a8b3-500f-9239-3416b676b079', 'speaking', 'Каву з собою, будь ласка.', 'Kavu za van, molim.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '54c1c306-a8b3-500f-9239-3416b676b079', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('cf4237e7-f1ae-57da-a798-3e2573f1f9a3', 'speaking', 'Чай без цукру, будь ласка.', 'Čaj bez šećera, molim.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'cf4237e7-f1ae-57da-a798-3e2573f1f9a3', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3a8a259b-c688-54a9-b3f3-2538a7806e6a', v_lesson, 'У кафе', 'U kafiću', 1091, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f36d094f-dbbc-5c08-bddf-486204e4e31f', '3a8a259b-c688-54a9-b3f3-2538a7806e6a', 'Konobar', 'Dobar dan! Što želite?', 'Добрий день! Що бажаєте?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cf8e775d-8bfa-55d8-9a3a-c5bba26c116c', '3a8a259b-c688-54a9-b3f3-2538a7806e6a', 'Iryna', 'Jednu kavu s mlijekom i čaj od mente, molim.', 'Одну каву з молоком і м’ятний чай, будь ласка.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a18ce650-a0b4-5c8d-8817-03a45dfb87ae', '3a8a259b-c688-54a9-b3f3-2538a7806e6a', 'Konobar', 'Želite li nešto slatko? Imamo domaće kolače.', 'Бажаєте щось солодке? У нас домашні тістечка.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('fdd60345-6574-572d-88fa-a08376ff0505', '3a8a259b-c688-54a9-b3f3-2538a7806e6a', 'Iryna', 'Može jedan kolač od čokolade.', 'Можна одне шоколадне тістечко.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('22274622-9e53-53c4-a264-333291df48c6', '3a8a259b-c688-54a9-b3f3-2538a7806e6a', 'Konobar', 'Šećer je na stolu.', 'Цукор на столі.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('954a8b27-5c1e-5e97-a4b9-acff635802cf', v_lesson, 'У пекарні', 'U pekari', 1092, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c1caefa1-43e1-59ec-9ebc-756a14de29f7', '954a8b27-5c1e-5e97-a4b9-acff635802cf', 'Prodavačica', 'Izvolite?', 'Слухаю вас?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2c07e20a-a229-51f1-a678-c5d9689200c8', '954a8b27-5c1e-5e97-a4b9-acff635802cf', 'Taras', 'Jedan burek sa sirom i dva peciva, molim.', 'Один бурек із сиром і дві булочки, будь ласка.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a7958e47-af57-561f-8d15-a6c8cb5a4cc4', '954a8b27-5c1e-5e97-a4b9-acff635802cf', 'Prodavačica', 'Još nešto? Jogurt?', 'Ще щось? Йогурт?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6280bf4d-1f21-5a9a-894a-5b03092dae52', '954a8b27-5c1e-5e97-a4b9-acff635802cf', 'Taras', 'Da, jedan jogurt. I kavu za van.', 'Так, один йогурт. І каву з собою.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('abc417dd-6f4e-53a0-bb7b-1627191a6ab0', '954a8b27-5c1e-5e97-a4b9-acff635802cf', 'Prodavačica', 'Ukupno pet eura.', 'Разом п’ять євро.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 10: Алергія і смаки
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '6af82dd3-beb1-54cf-9c1b-44ec3cb12a35';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.2: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b89a9004-2c03-567a-b23e-31db18f92dea';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.2.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 10: Алергія і смаки', 'Lekcija 10: Alergija i okusi', '["Сказати, чого ви не їсте", "Повідомити про алергію", "Поскаржитися на страву: надто солоне, гостре"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('alergija') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'alergija'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('alergičan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'alergičan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vegetarijanac') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vegetarijanac'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('orah') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'orah'; end if;
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
  select id into v_id from public.lexemes where lower(lemma) = lower('kiseo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kiseo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ukusan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ukusan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('okus') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'okus'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('previše') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'previše'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jelo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jelo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('donijeti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'donijeti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6614669c-6ce7-5429-a297-29e36b639717', 'fill_in_the_blank', 'Juha ___ slana.', 'nije', '["ne", "nije", "nema", "nisam"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6614669c-6ce7-5429-a297-29e36b639717', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('previše') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('62c7a451-c566-5e35-aa75-26c7bc210028', 'multiple_choice', 'Що означає «previše»?', 'надто; забагато', '["алергія", "вегетаріанець", "принести", "надто; забагато"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '62c7a451-c566-5e35-aa75-26c7bc210028', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('orah') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2737bc90-56d3-5e74-8549-99a07ab740c1', 'multiple_choice', 'Що означає «orah»?', 'горіх', '["вегетаріанець", "горіх", "алергічний", "смак"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2737bc90-56d3-5e74-8549-99a07ab740c1', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kiseo') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9bcb35fe-7f7d-5922-859c-f1e815b8ebc8', 'multiple_choice', 'Як хорватською «кислий»?', 'kiseo', '["okus", "jelo", "orah", "kiseo"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9bcb35fe-7f7d-5922-859c-f1e815b8ebc8', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ljut') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4e0a3bc0-afe3-5111-b8b6-9e4a492f93b2', 'type_answer', 'Напишіть хорватською: «злий / сердитий»', 'ljut', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4e0a3bc0-afe3-5111-b8b6-9e4a492f93b2', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('ukusan') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('dabc613c-50da-529d-bce9-33c04263ee31', 'type_answer', 'Напишіть хорватською: «смачний»', 'ukusan', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'dabc613c-50da-529d-bce9-33c04263ee31', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f37f6c6d-d54c-5449-9f6e-44f98ae810f5', 'sentence_builder', 'Складіть: «Я не їм м’яса.»', 'Ja ne jedem meso.', '["meso.", "ne", "Ja", "jedem"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f37f6c6d-d54c-5449-9f6e-44f98ae810f5', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a060c13d-da36-536d-9f59-81ddfea1d3e7', 'sentence_builder', 'Складіть: «Суп надто солоний.»', 'Juha je previše slana.', '["Juha", "slana.", "je", "previše"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a060c13d-da36-536d-9f59-81ddfea1d3e7', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('31214492-2a6f-5fea-a901-6f2662ac7209', 'listening', 'Прослухайте і складіть фразу', 'Onda rižoto s povrćem?', '["povrćem?", "rižoto", "Onda", "s"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '31214492-2a6f-5fea-a901-6f2662ac7209', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('037086b4-4106-5697-997a-5e433145d5d3', 'listening', 'Прослухайте і складіть фразу', 'I ovo jelo je jako ljuto.', '["ovo", "jelo", "jako", "I", "ljuto.", "je"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '037086b4-4106-5697-997a-5e433145d5d3', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('bffdaf1d-3f9f-51d5-a398-80796c4b709b', 'speaking', 'У мене алергія на горіхи.', 'Alergičan sam na orahe.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'bffdaf1d-3f9f-51d5-a398-80796c4b709b', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6b9b5606-224c-54c9-bad1-4b6eec7e00d1', 'speaking', 'Це дуже смачно!', 'Ovo je jako ukusno!', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6b9b5606-224c-54c9-bad1-4b6eec7e00d1', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('05dc3e18-d557-56ba-9550-a5317ddf2ddc', v_lesson, 'Я вегетаріанка', 'Ja sam vegetarijanka', 1101, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('bd1937b2-3382-5a49-9caa-08e0984b6cd3', '05dc3e18-d557-56ba-9550-a5317ddf2ddc', 'Konobarica', 'Preporučujem gulaš, jako je ukusan.', 'Раджу гуляш, він дуже смачний.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2ce3b0cb-b20d-5fc8-922c-19f639cb4d24', '05dc3e18-d557-56ba-9550-a5317ddf2ddc', 'Oksana', 'Hvala, ali ja ne jedem meso. Vegetarijanka sam.', 'Дякую, але я не їм м’яса. Я вегетаріанка.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('96e9fb12-c11e-50b5-9449-2e94c244b597', '05dc3e18-d557-56ba-9550-a5317ddf2ddc', 'Konobarica', 'Onda rižoto s povrćem?', 'Тоді різото з овочами?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6ed27adc-bdb6-5065-8711-b6d6b4699ef5', '05dc3e18-d557-56ba-9550-a5317ddf2ddc', 'Oksana', 'Može. Ima li u njemu oraha? Alergična sam na orahe.', 'Можна. У ньому є горіхи? У мене алергія на горіхи.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ef699c5a-8bfa-5105-95a2-62c102b0c39f', '05dc3e18-d557-56ba-9550-a5317ddf2ddc', 'Konobarica', 'Nema, ne brinite.', 'Немає, не хвилюйтеся.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('15a9e1f7-ccaa-5505-b937-5387bb713b9f', v_lesson, 'Надто солоно', 'Previše slano', 1102, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4d613401-ad6d-5a01-a877-db32af888d74', '15a9e1f7-ccaa-5505-b937-5387bb713b9f', 'Andrij', 'Oprostite, juha je previše slana.', 'Перепрошую, суп надто солоний.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('be0bceb9-c03c-5ace-b8f4-3937e7f7386f', '15a9e1f7-ccaa-5505-b937-5387bb713b9f', 'Konobar', 'Žao mi je! Odmah donosim novu.', 'Мені шкода! Зараз принесу новий.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0db37a17-9d9b-51b8-b290-c9bf7267fec2', '15a9e1f7-ccaa-5505-b937-5387bb713b9f', 'Andrij', 'I ovo jelo je jako ljuto.', 'І ця страва дуже гостра.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0381c29a-e075-5369-88af-a357cc736a29', '15a9e1f7-ccaa-5505-b937-5387bb713b9f', 'Konobar', 'Nema problema, mogu ga zamijeniti.', 'Без проблем, можу її замінити.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 11: Яка краща?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '7042ff57-9a20-514a-ab80-71b6f63579f7';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.3: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.3.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 11: Яка краща?', 'Lekcija 11: Koja je bolja?', '["Порівняти дві речі", "Попросити інший розмір", "Вживати вищий ступінь: jeftiniji, veći, bolji"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('jakna') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jakna'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('haljina') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'haljina'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('košulja') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'košulja'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('traperice') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'traperice'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('boja') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'boja'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('veličina') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'veličina'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('skup') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'skup'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jeftin') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jeftin'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('veliki') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'veliki'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('mali') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'mali'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('probati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'probati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kabina') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kabina'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d7da6d66-2a78-5c5d-8b5a-ebda1b218b6a', 'fill_in_the_blank', 'Crna jakna je ___ od plave.', 'toplija', '["topliji", "najtoplija", "toplija", "topla"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd7da6d66-2a78-5c5d-8b5a-ebda1b218b6a', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('jeftin') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4a2ae94e-e787-530f-92d8-05f45e406102', 'multiple_choice', 'Що означає «jeftin»?', 'дешевий', '["дешевий", "примірочна / кабінка", "сорочка", "сукня"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4a2ae94e-e787-530f-92d8-05f45e406102', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jakna') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5a5f71cc-e61c-542f-83ab-2c21e91a0bac', 'multiple_choice', 'Що означає «jakna»?', 'куртка', '["дешевий", "куртка", "джинси", "примірочна / кабінка"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5a5f71cc-e61c-542f-83ab-2c21e91a0bac', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('košulja') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('050e157b-7d64-59d2-afbf-7b337e768cd4', 'multiple_choice', 'Як хорватською «сорочка»?', 'košulja', '["mali", "košulja", "jakna", "haljina"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '050e157b-7d64-59d2-afbf-7b337e768cd4', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('mali') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ff3b1625-83ad-50d6-b286-76369a8f1308', 'type_answer', 'Напишіть хорватською: «малий»', 'mali', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ff3b1625-83ad-50d6-b286-76369a8f1308', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('traperice') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('52766e7c-5ecc-5e7a-9328-3d3e3637d000', 'type_answer', 'Напишіть хорватською: «джинси»', 'traperice', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '52766e7c-5ecc-5e7a-9328-3d3e3637d000', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5813af54-0628-5a1d-98da-222034a59635', 'sentence_builder', 'Складіть: «Яка куртка краща?»', 'Koja jakna je bolja?', '["bolja?", "Koja", "je", "jakna"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5813af54-0628-5a1d-98da-222034a59635', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('156231a9-a655-5efd-8d96-fc6bf47fef83', 'sentence_builder', 'Складіть: «У вас є дешевші?»', 'Imate li jeftinije?', '["jeftinije?", "li", "Imate"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '156231a9-a655-5efd-8d96-fc6bf47fef83', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2d99654b-5556-5919-9f19-6c053427f726', 'listening', 'Прослухайте і складіть фразу', 'Crna je i skuplja.', '["je", "skuplja.", "i", "Crna"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2d99654b-5556-5919-9f19-6c053427f726', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d329163c-352e-5844-98e1-008bc699ac6a', 'listening', 'Прослухайте і складіть фразу', 'Ove traperice su mi male.', '["male.", "Ove", "traperice", "mi", "su"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd329163c-352e-5844-98e1-008bc699ac6a', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fc0e22d1-34f7-5f09-8aa1-2eddaf21949d', 'speaking', 'Ця сукня дешевша.', 'Ova haljina je jeftinija.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fc0e22d1-34f7-5f09-8aa1-2eddaf21949d', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('34a3c536-ebe6-5697-927d-f5ee371f5850', 'speaking', 'Можна поміряти?', 'Mogu li probati?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '34a3c536-ebe6-5697-927d-f5ee371f5850', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ee6d92cf-eb53-5fb9-8d3b-db7de3ef7033', v_lesson, 'Куртка', 'Jakna', 1111, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('05d0ca8c-cda6-5da0-b37b-42c32664f910', 'ee6d92cf-eb53-5fb9-8d3b-db7de3ef7033', 'Iryna', 'Koja jakna je bolja, plava ili crna?', 'Яка куртка краща, синя чи чорна?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a2cbe74e-d8f7-5b1a-965d-f622cfcc3bf9', 'ee6d92cf-eb53-5fb9-8d3b-db7de3ef7033', 'Lana', 'Plava je ljepša, ali crna je toplija.', 'Синя гарніша, але чорна тепліша.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('91110a9d-aa7d-5327-a533-9ef35139b435', 'ee6d92cf-eb53-5fb9-8d3b-db7de3ef7033', 'Iryna', 'Crna je i skuplja.', 'Чорна ще й дорожча.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('49635b78-d03a-508f-9e4f-bb66765e0922', 'ee6d92cf-eb53-5fb9-8d3b-db7de3ef7033', 'Lana', 'Da, ali je bolja za zimu.', 'Так, але вона краща для зими.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b57e9a9f-b304-5b8f-9a4f-ab0395efe4fa', 'ee6d92cf-eb53-5fb9-8d3b-db7de3ef7033', 'Iryna', 'Dobro, uzimam crnu.', 'Добре, беру чорну.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cfe29472-4cd7-577e-85c2-7f69646a9bb8', v_lesson, 'У примірочній', 'U kabini', 1112, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6ff598f3-7f12-5761-8acf-c86b3831402f', 'cfe29472-4cd7-577e-85c2-7f69646a9bb8', 'Andrij', 'Ove traperice su mi male.', 'Ці джинси мені малі.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('393ba053-09d9-5a39-ad21-901c5278bce0', 'cfe29472-4cd7-577e-85c2-7f69646a9bb8', 'Prodavačica', 'Probajte veće. Ovo je veličina trideset dva.', 'Поміряйте більші. Це розмір тридцять два.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b29598ce-d19b-5db8-9ef3-533c121b1bbe', 'cfe29472-4cd7-577e-85c2-7f69646a9bb8', 'Andrij', 'Imate li jeftinije?', 'У вас є дешевші?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8e5ab9ab-bb0b-5f5f-a9dc-ffd329f5ddad', 'cfe29472-4cd7-577e-85c2-7f69646a9bb8', 'Prodavačica', 'Imamo. Ove su na popustu.', 'Є. Ці зі знижкою.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e888a4bf-7d9a-54c1-b166-9bbe94f1b394', 'cfe29472-4cd7-577e-85c2-7f69646a9bb8', 'Andrij', 'Super, njih probam.', 'Чудово, їх і поміряю.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 12: У супермаркеті
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '0c19643d-57ff-5030-820f-ba330833ea88';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.3: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.3.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 12: У супермаркеті', 'Lekcija 12: U supermarketu', '["Сказати, що вам треба купити", "Запитати, чи можна заплатити карткою", "Вживати moram, mogu, trebam"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('trebati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'trebati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('morati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'morati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('željeti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'željeti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kupiti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kupiti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('platiti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'platiti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('uzeti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'uzeti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('košarica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'košarica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('supermarket') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'supermarket'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('blagajna') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'blagajna'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vrećica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vrećica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kartica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kartica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('red') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'red'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('11cc5462-4ac8-5495-9e7b-53101a92c22d', 'fill_in_the_blank', 'Ja ___ kupiti kruh.', 'moram', '["mora", "moraš", "moram", "moraju"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '11cc5462-4ac8-5495-9e7b-53101a92c22d', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('platiti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9dc82923-928c-5950-8e98-76a08e43c30a', 'multiple_choice', 'Що означає «platiti»?', 'заплатити', '["черга", "мусити / бути зобов''язаним", "потребувати", "заплатити"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9dc82923-928c-5950-8e98-76a08e43c30a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kupiti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9ae68757-dcae-5721-8a7a-44a182ec873d', 'multiple_choice', 'Що означає «kupiti»?', 'купити', '["взяти", "купити", "пакет", "заплатити"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9ae68757-dcae-5721-8a7a-44a182ec873d', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('morati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('97375a5f-b6e8-5905-a096-5e852c99b474', 'multiple_choice', 'Як хорватською «мусити / бути зобов''язаним»?', 'morati', '["vrećica", "željeti", "morati", "kartica"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '97375a5f-b6e8-5905-a096-5e852c99b474', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('košarica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0f3de0af-a885-580d-b299-2c122917a419', 'type_answer', 'Напишіть хорватською: «кошик (для покупок)»', 'košarica', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0f3de0af-a885-580d-b299-2c122917a419', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('red') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('cf85dccb-b3e8-5dcf-b624-7490ff5d9c06', 'type_answer', 'Напишіть хорватською: «черга»', 'red', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'cf85dccb-b3e8-5dcf-b624-7490ff5d9c06', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2b4eebaf-5004-5f1e-b5b0-3a7f855d9179', 'sentence_builder', 'Складіть: «Мені треба купити молоко й хліб.»', 'Moram kupiti mlijeko i kruh.', '["mlijeko", "kupiti", "Moram", "i", "kruh."]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2b4eebaf-5004-5f1e-b5b0-3a7f855d9179', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6d121f68-7551-544e-8a3f-5aa2c865b972', 'sentence_builder', 'Складіть: «Можна заплатити карткою?»', 'Mogu li platiti karticom?', '["karticom?", "li", "Mogu", "platiti"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6d121f68-7551-544e-8a3f-5aa2c865b972', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('559c5614-7829-5c9d-9fc4-3ec0fc179956', 'listening', 'Прослухайте і складіть фразу', 'Možeš li uzeti košaricu?', '["Možeš", "košaricu?", "li", "uzeti"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '559c5614-7829-5c9d-9fc4-3ec0fc179956', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('71263c9f-3300-5219-80f5-f65fd8e42764', 'listening', 'Прослухайте і складіть фразу', 'Trebate li vrećicu?', '["vrećicu?", "li", "Trebate"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '71263c9f-3300-5219-80f5-f65fd8e42764', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6bb15115-e3c4-53f4-9cf7-a844af59b17f', 'speaking', 'Мені потрібен пакет.', 'Trebam vrećicu.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6bb15115-e3c4-53f4-9cf7-a844af59b17f', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f951bd16-c2d9-5de9-9f0b-7e06f3d0e30b', 'speaking', 'Мені треба платити готівкою?', 'Moram li platiti gotovinom?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f951bd16-c2d9-5de9-9f0b-7e06f3d0e30b', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('52acf9ac-7b1e-554a-824a-ae291cbfa5a4', v_lesson, 'Список покупок', 'Popis za kupovinu', 1121, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('28cb8de7-1644-5cb6-ab8c-59e6ef66d933', '52acf9ac-7b1e-554a-824a-ae291cbfa5a4', 'Taras', 'Moram kupiti mlijeko i kruh.', 'Мені треба купити молоко й хліб.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('fda1c4aa-5f7e-57eb-a2bb-ab75425bd74b', '52acf9ac-7b1e-554a-824a-ae291cbfa5a4', 'Olena', 'Trebamo i jaja.', 'Нам ще потрібні яйця.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('08e2e6b9-8c05-59e4-8314-c0419fbde071', '52acf9ac-7b1e-554a-824a-ae291cbfa5a4', 'Taras', 'Možeš li uzeti košaricu?', 'Можеш узяти кошик?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('64f52482-a496-5ca0-92a8-df27f79137f9', '52acf9ac-7b1e-554a-824a-ae291cbfa5a4', 'Olena', 'Mogu. Gdje je mlijeko?', 'Можу. Де молоко?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d6eec0bb-ccab-56d7-9172-69e2ec648f95', '52acf9ac-7b1e-554a-824a-ae291cbfa5a4', 'Taras', 'Tamo, lijevo.', 'Там, ліворуч.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('29cd6000-dd31-53ed-8774-be5866cf437f', v_lesson, 'На касі', 'Na blagajni', 1122, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('787bfe7d-65d6-5270-a210-305c4d4168a1', '29cd6000-dd31-53ed-8774-be5866cf437f', 'Blagajnica', 'Trebate li vrećicu?', 'Вам потрібен пакет?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a697a31c-a572-5ced-92e6-5fd2b15dadfe', '29cd6000-dd31-53ed-8774-be5866cf437f', 'Olena', 'Da, jednu. Mogu li platiti karticom?', 'Так, один. Можна заплатити карткою?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d4db8950-402f-595f-82e6-7c73de772ac5', '29cd6000-dd31-53ed-8774-be5866cf437f', 'Blagajnica', 'Naravno. Unesite PIN.', 'Звісно. Введіть PIN.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7457d564-0ba9-55bf-b655-c3c7f55e7cc9', '29cd6000-dd31-53ed-8774-be5866cf437f', 'Olena', 'Evo. Hvala!', 'Ось. Дякую!', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('54ca78ab-b83b-5849-97b0-0697e2d3a89d', '29cd6000-dd31-53ed-8774-be5866cf437f', 'Blagajnica', 'Hvala Vama! Ugodan dan!', 'Дякую вам! Гарного дня!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 13: Повернення товару
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '6a7b0f42-510b-521e-9cc0-f77b2659d838';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.3: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b89a9004-2c03-567a-b23e-31db18f92dea';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.3.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 13: Повернення товару', 'Lekcija 13: Povrat robe', '["Сказати, що річ не працює", "Попросити обміняти товар або повернути гроші", "Вживати заперечення: ne radi, nema, ništa"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('vratiti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vratiti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zamijeniti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zamijeniti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pokvareno') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pokvareno'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('račun') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'račun'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('novac') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'novac'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ništa') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ništa'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('nitko') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'nitko'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('nikad') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'nikad'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prodavač') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prodavač'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kvar') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kvar'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sviđati se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sviđati se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fc472d19-2b83-577d-93dc-081571e7dce8', 'fill_in_the_blank', 'Punjač ___ radi.', 'ne', '["nije", "nema", "ni", "ne"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fc472d19-2b83-577d-93dc-081571e7dce8', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('vratiti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9daa9ee6-2fcd-5df4-9662-befbcd3ea838', 'multiple_choice', 'Що означає «vratiti»?', 'повернути', '["ніколи", "повернути", "продавець", "рахунок / чек"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9daa9ee6-2fcd-5df4-9662-befbcd3ea838', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('račun') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('421295e1-46e1-568a-850a-f8ec9b2cf5ce', 'multiple_choice', 'Що означає «račun»?', 'рахунок / чек', '["повернути", "ніхто", "продавець", "рахунок / чек"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '421295e1-46e1-568a-850a-f8ec9b2cf5ce', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prodavač') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8bd3ff32-d27a-5505-a913-fa6e780f37ec', 'multiple_choice', 'Як хорватською «продавець»?', 'prodavač', '["prodavač", "ništa", "sviđati se", "nikad"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8bd3ff32-d27a-5505-a913-fa6e780f37ec', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kvar') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('52ef7b54-1004-5de2-85f1-9fe79e2aad29', 'type_answer', 'Напишіть хорватською: «несправність / поломка»', 'kvar', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '52ef7b54-1004-5de2-85f1-9fe79e2aad29', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('zamijeniti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e0d393c6-aba6-556d-822c-ed949533ad33', 'type_answer', 'Напишіть хорватською: «замінити»', 'zamijeniti', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e0d393c6-aba6-556d-822c-ed949533ad33', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('cea4de34-47ac-5145-b04a-f92d5da2fb11', 'sentence_builder', 'Складіть: «Цей зарядний пристрій не працює.»', 'Ovaj punjač ne radi.', '["punjač", "Ovaj", "ne", "radi."]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'cea4de34-47ac-5145-b04a-f92d5da2fb11', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('19111b42-b8ed-55ff-9f29-c97a57019b77', 'sentence_builder', 'Складіть: «Мені нічого не подобається.»', 'Ništa mi se ne sviđa.', '["se", "sviđa.", "mi", "Ništa", "ne"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '19111b42-b8ed-55ff-9f29-c97a57019b77', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('43288778-9f5d-57e2-ac0d-a61ef179a2a8', 'listening', 'Прослухайте і складіть фразу', 'Imate li račun?', '["račun?", "li", "Imate"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '43288778-9f5d-57e2-ac0d-a61ef179a2a8', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('839ef982-ad14-5f41-842e-112e1343afdd', 'listening', 'Прослухайте і складіть фразу', 'Nema moje veličine.', '["moje", "veličine.", "Nema"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '839ef982-ad14-5f41-842e-112e1343afdd', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('330a903a-955e-58c0-8486-88375079324e', 'speaking', 'Це не працює.', 'Ovo ne radi.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '330a903a-955e-58c0-8486-88375079324e', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('13e05920-4c40-5fa4-ab58-e66677308367', 'speaking', 'Я нічого не купую.', 'Ništa ne kupujem.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '13e05920-4c40-5fa4-ab58-e66677308367', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('728fcebb-e240-5ac4-9139-cfda3cc7984a', v_lesson, 'Зарядка не працює', 'Punjač ne radi', 1131, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('da0f1307-5629-557a-8861-be5f3003372d', '728fcebb-e240-5ac4-9139-cfda3cc7984a', 'Prodavač', 'Izvolite, kako mogu pomoći?', 'Прошу, чим можу допомогти?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4b25622b-5f5e-579f-8738-af43acf18874', '728fcebb-e240-5ac4-9139-cfda3cc7984a', 'Andrij', 'Ovaj punjač ne radi.', 'Цей зарядний пристрій не працює.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4d7578ec-e5dc-510d-a614-2dd037b552c0', '728fcebb-e240-5ac4-9139-cfda3cc7984a', 'Prodavač', 'Imate li račun?', 'У вас є чек?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d4d78d56-00b0-5d23-9454-b0834d08553d', '728fcebb-e240-5ac4-9139-cfda3cc7984a', 'Andrij', 'Imam, evo ga.', 'Є, ось він.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('35a14328-9d2d-51dd-86f3-47c4600ec016', '728fcebb-e240-5ac4-9139-cfda3cc7984a', 'Prodavač', 'Možemo ga zamijeniti ili vratiti novac.', 'Можемо його обміняти або повернути гроші.', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cabe93d0-3ae4-52c3-8239-01752556eb8e', '728fcebb-e240-5ac4-9139-cfda3cc7984a', 'Andrij', 'Molim Vas, vratite novac.', 'Поверніть, будь ласка, гроші.', 6) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6dccf29e-3564-5366-b7d0-b39698bc65fa', v_lesson, 'Нічого не подобається', 'Ništa mi se ne sviđa', 1132, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('602c8e93-b567-5de9-9e2f-6a7efa4a55ef', '6dccf29e-3564-5366-b7d0-b39698bc65fa', 'Lana', 'Kupuješ li nešto?', 'Ти щось купуєш?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7fe9091c-6e76-5d82-afaa-4584cdbf38a9', '6dccf29e-3564-5366-b7d0-b39698bc65fa', 'Oksana', 'Ne, ništa mi se ne sviđa.', 'Ні, мені нічого не подобається.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('06849bce-862a-5d1f-bdc3-bcda0155de17', '6dccf29e-3564-5366-b7d0-b39698bc65fa', 'Lana', 'A ova haljina?', 'А ця сукня?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d9963baf-bc68-5525-8564-5866c738ccfa', '6dccf29e-3564-5366-b7d0-b39698bc65fa', 'Oksana', 'Nema moje veličine.', 'Немає мого розміру.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7eb6d373-c61e-5970-aa02-f2b1070aadcf', '6dccf29e-3564-5366-b7d0-b39698bc65fa', 'Lana', 'Ni ja nikad ne nalazim ništa ovdje!', 'Я теж ніколи нічого тут не знаходжу!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 14: У дрогерії
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '9ba8e62a-83fd-5b08-9e01-760bc0f7219f';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.3: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.3.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 14: У дрогерії', 'Lekcija 14: U drogeriji', '["Купити засоби гігієни й побутову хімію", "Знайти товар у магазині", "Вживати родовий відмінок: nema šampona"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('drogerija') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'drogerija'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('šampon') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'šampon'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pasta za zube') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pasta za zube'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pelene') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pelene'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('krema') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'krema'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('deterdžent') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'deterdžent'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('toaletni papir') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'toaletni papir'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('akcija') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'akcija'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('polica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'polica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kosa') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kosa'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('suh') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'suh'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('beba') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'beba'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('85d93558-60d2-5db9-8829-53cd4446b36f', 'fill_in_the_blank', 'Danas nema ___.', 'šampona', '["šamponom", "šampona", "šampon", "šamponu"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '85d93558-60d2-5db9-8829-53cd4446b36f', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('krema') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('34af2be4-0ae2-5b14-af04-004c5920e09e', 'multiple_choice', 'Що означає «krema»?', 'крем', '["зубна паста", "шампунь", "крем", "акція; спеціальна пропозиція"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '34af2be4-0ae2-5b14-af04-004c5920e09e', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pelene') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e43b6ac5-e8b8-51d4-b82f-99490a4049f4', 'multiple_choice', 'Що означає «pelene»?', 'підгузки', '["волосся", "шампунь", "полиця; страховий поліс", "підгузки"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e43b6ac5-e8b8-51d4-b82f-99490a4049f4', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('drogerija') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('11b4c1c6-ea65-565f-9523-024c7f60ed8d', 'multiple_choice', 'Як хорватською «магазин побутової хімії й косметики»?', 'drogerija', '["drogerija", "deterdžent", "krema", "polica"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '11b4c1c6-ea65-565f-9523-024c7f60ed8d', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('šampon') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f2baafab-686b-50eb-86a9-31abb5cb62c6', 'type_answer', 'Напишіть хорватською: «шампунь»', 'šampon', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f2baafab-686b-50eb-86a9-31abb5cb62c6', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('suh') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6190f7a8-7009-502e-a565-76f6db482903', 'type_answer', 'Напишіть хорватською: «сухий»', 'suh', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6190f7a8-7009-502e-a565-76f6db482903', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1e7f24ba-dd84-55f3-9380-b4ccfd591769', 'sentence_builder', 'Складіть: «Вибачте, де підгузки?»', 'Oprostite, gdje su pelene?', '["Oprostite,", "pelene?", "gdje", "su"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1e7f24ba-dd84-55f3-9380-b4ccfd591769', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('56cc82b5-4409-5c90-8869-183eccc4567c', 'sentence_builder', 'Складіть: «Мені потрібна зубна паста.»', 'Trebam pastu za zube.', '["za", "zube.", "pastu", "Trebam"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '56cc82b5-4409-5c90-8869-183eccc4567c', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3722f574-39e1-52af-86ac-1b762a862126', 'listening', 'Прослухайте і складіть фразу', 'Imate li veći paket?', '["li", "veći", "Imate", "paket?"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3722f574-39e1-52af-86ac-1b762a862126', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e8be9c48-72bb-5029-967e-53a6c83a0052', 'listening', 'Прослухайте і складіть фразу', 'Ima li deterdženta za rublje?', '["Ima", "li", "rublje?", "za", "deterdženta"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e8be9c48-72bb-5029-967e-53a6c83a0052', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('08165527-06b4-5e02-bbeb-6bbbaf7d150c', 'speaking', 'Де туалетний папір?', 'Gdje je toaletni papir?', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '08165527-06b4-5e02-bbeb-6bbbaf7d150c', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5e94db4a-9961-58d2-a1cd-0ca719a2dc69', 'speaking', 'Це по акції?', 'Je li ovo na akciji?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5e94db4a-9961-58d2-a1cd-0ca719a2dc69', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ded88657-9ec2-5846-a64b-92e777bed924', v_lesson, 'Для малюка', 'Za bebu', 1141, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2a68f733-f854-516a-824c-9203c6f00c40', 'ded88657-9ec2-5846-a64b-92e777bed924', 'Olena', 'Oprostite, gdje su pelene?', 'Вибачте, де підгузки?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('225f080c-7293-5a3e-9fd0-f4a7aca19627', 'ded88657-9ec2-5846-a64b-92e777bed924', 'Prodavačica', 'Na kraju, desno, pored kreme za bebe.', 'У кінці, праворуч, біля дитячого крему.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ebc4aede-9692-5428-93ab-e813d72a2a90', 'ded88657-9ec2-5846-a64b-92e777bed924', 'Olena', 'Imate li veći paket?', 'У вас є більша упаковка?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('bec9fdee-f4dc-5d8d-adb3-eb83421a7152', 'ded88657-9ec2-5846-a64b-92e777bed924', 'Prodavačica', 'Imamo, i danas je na akciji.', 'Є, і сьогодні вона по акції.', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a5602db1-b844-5266-9759-95d92b05ebf1', v_lesson, 'Немає шампуню', 'Nema šampona', 1142, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('fbd78819-34a0-5f37-a925-ffd173cefacb', 'a5602db1-b844-5266-9759-95d92b05ebf1', 'Taras', 'Trebam šampon i pastu za zube.', 'Мені потрібні шампунь і зубна паста.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b31ae2b0-f3a3-596a-b01d-33eb4284cb12', 'a5602db1-b844-5266-9759-95d92b05ebf1', 'Prodavač', 'Pasta za zube je ovdje. Šampona za suhu kosu danas nema.', 'Зубна паста тут. Шампуню для сухого волосся сьогодні немає.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4cc10ac1-f40d-5907-9663-59defbea47d3', 'a5602db1-b844-5266-9759-95d92b05ebf1', 'Taras', 'Ima li deterdženta za rublje?', 'А засіб для прання є?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ae6e4785-3fa2-59e5-a45c-5e1eca6db7a4', 'a5602db1-b844-5266-9759-95d92b05ebf1', 'Prodavač', 'Ima, na zadnjoj polici. I toaletni papir je tamo.', 'Є, на останній полиці. Туалетний папір теж там.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 15: Мобільний зв’язок
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '35203547-5f9a-5857-95a0-3a0d596f715d';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.3: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.3.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 15: Мобільний зв’язок', 'Lekcija 15: Mobilna mreža', '["Купити SIM-картку й обрати тариф", "Запитати про інтернет і дзвінки в Україну", "Віддати телефон у ремонт"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('SIM kartica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'SIM kartica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('bon') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'bon'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tarifa') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tarifa'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('internet') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'internet'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('mjesečno') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'mjesečno'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zvati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zvati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('punjač') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'punjač'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('puniti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'puniti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('broj mobitela') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'broj mobitela'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('poruka') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'poruka'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ostaviti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ostaviti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('aplikacija') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'aplikacija'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fc1a004b-bfd2-526a-b762-f9b53f796682', 'fill_in_the_blank', '___ košta internet?', 'Koliko', '["Kada", "Koliko", "Gdje", "Koji"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fc1a004b-bfd2-526a-b762-f9b53f796682', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('poruka') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d1a58bf9-6547-59dd-89c0-8e63b05760f8', 'multiple_choice', 'Що означає «poruka»?', 'повідомлення', '["передплата (поповнення рахунку)", "SIM-картка", "повідомлення", "дзвонити; кликати"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd1a58bf9-6547-59dd-89c0-8e63b05760f8', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zvati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3f920b13-9699-5e7d-8b3e-5b1a3cde902e', 'multiple_choice', 'Що означає «zvati»?', 'дзвонити; кликати', '["дзвонити; кликати", "номер мобільного телефону", "повідомлення", "SIM-картка"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3f920b13-9699-5e7d-8b3e-5b1a3cde902e', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('internet') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1dfc85ca-c600-539c-81dd-2f41838f8f5e', 'multiple_choice', 'Як хорватською «інтернет»?', 'internet', '["internet", "ostaviti", "bon", "aplikacija"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1dfc85ca-c600-539c-81dd-2f41838f8f5e', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('aplikacija') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c8ba8af2-b2cb-5f2b-8f0f-8046c2bb8c4f', 'type_answer', 'Напишіть хорватською: «додаток (app)»', 'aplikacija', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c8ba8af2-b2cb-5f2b-8f0f-8046c2bb8c4f', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('punjač') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1a6f719c-6eb7-5abf-91ea-2ae254de8c02', 'type_answer', 'Напишіть хорватською: «зарядний пристрій»', 'punjač', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1a6f719c-6eb7-5abf-91ea-2ae254de8c02', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e23b7220-8f81-568f-96e3-bfa2ae0ac922', 'sentence_builder', 'Складіть: «Мені потрібна SIM-картка.»', 'Trebam SIM karticu.', '["karticu.", "SIM", "Trebam"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e23b7220-8f81-568f-96e3-bfa2ae0ac922', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('11f2e5ac-19e4-5d5f-919b-bcd5c734fe9a', 'sentence_builder', 'Складіть: «Мій телефон не заряджається.»', 'Moj mobitel se ne puni.', '["se", "mobitel", "Moj", "ne", "puni."]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '11f2e5ac-19e4-5d5f-919b-bcd5c734fe9a', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('88ac26d6-3bbc-5055-a6ad-72301f141e43', 'listening', 'Прослухайте і складіть фразу', 'Mogu li zvati u Ukrajinu?', '["u", "zvati", "Ukrajinu?", "li", "Mogu"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '88ac26d6-3bbc-5055-a6ad-72301f141e43', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ecfa0654-9418-5153-b2af-7749264a7e68', 'listening', 'Прослухайте і складіть фразу', 'Koji punjač imate?', '["punjač", "imate?", "Koji"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ecfa0654-9418-5153-b2af-7749264a7e68', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a5204f17-1f59-5a12-a5e0-89f92fff1dfe', 'speaking', 'Скільки коштує інтернет?', 'Koliko košta internet?', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a5204f17-1f59-5a12-a5e0-89f92fff1dfe', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('259e7d53-7c56-548b-b8e2-cf096e10c62b', 'speaking', 'Мені потрібен зарядний пристрій.', 'Trebam punjač.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '259e7d53-7c56-548b-b8e2-cf096e10c62b', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('20cfacc9-ff3c-525d-b4a5-b75f2ea18dbe', v_lesson, 'Нова SIM-картка', 'Nova SIM kartica', 1151, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c362aabb-37e5-5894-9f0a-5beeeb730f92', '20cfacc9-ff3c-525d-b4a5-b75f2ea18dbe', 'Andrij', 'Dobar dan, trebam SIM karticu.', 'Добрий день, мені потрібна SIM-картка.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8c5739a7-d00e-5736-a5f2-ec08c924c1aa', '20cfacc9-ff3c-525d-b4a5-b75f2ea18dbe', 'Prodavačica', 'Želite li bon ili tarifu s ugovorom?', 'Бажаєте передплачену картку чи тариф із договором?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e2ff6045-2cb9-566a-b6f3-8a4bc44bec46', '20cfacc9-ff3c-525d-b4a5-b75f2ea18dbe', 'Andrij', 'Bon. Koliko košta internet?', 'Передплачену. Скільки коштує інтернет?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8623871b-4a39-5371-ac7a-85e0fe7b4001', '20cfacc9-ff3c-525d-b4a5-b75f2ea18dbe', 'Prodavačica', 'Deset eura mjesečno za dvadeset giga.', 'Десять євро на місяць за двадцять гігабайтів.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ea1d9468-7c2a-5e59-9d84-6dce35dc5863', '20cfacc9-ff3c-525d-b4a5-b75f2ea18dbe', 'Andrij', 'Mogu li zvati u Ukrajinu?', 'Чи можу я дзвонити в Україну?', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8e713d59-523e-5fe4-a126-d33e6c027b1e', v_lesson, 'Телефон не заряджається', 'Mobitel se ne puni', 1152, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4c9e145a-cbd5-5d97-b8ab-f19504af15b9', '8e713d59-523e-5fe4-a126-d33e6c027b1e', 'Iryna', 'Moj mobitel se ne puni.', 'Мій телефон не заряджається.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('50edb3bf-e13e-5aef-9dec-a8b4bfeb1b15', '8e713d59-523e-5fe4-a126-d33e6c027b1e', 'Prodavač', 'Koji punjač imate?', 'Який у вас зарядний пристрій?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0a47ecd8-d731-52de-a27c-6656cce574ea', '8e713d59-523e-5fe4-a126-d33e6c027b1e', 'Iryna', 'Ovaj. Kada mogu doći po mobitel?', 'Ось цей. Коли я можу прийти по телефон?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('060905eb-8ae5-5393-bde4-fd5ae92339f1', '8e713d59-523e-5fe4-a126-d33e6c027b1e', 'Prodavač', 'Sutra poslijepodne. Ostavite broj mobitela, molim.', 'Завтра після обіду. Залиште, будь ласка, номер телефону.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 16: У трамваї
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '0ef458c5-53cf-530a-99cf-4ccd6e0132e5';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.4: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.4.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 16: У трамваї', 'Lekcija 16: U tramvaju', '["Купити квиток на трамвай чи автобус", "Запитати, де пересісти", "Вживати місцевий відмінок: u tramvaju, na stanici"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('tramvaj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tramvaj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('autobus') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'autobus'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('stanica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'stanica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('karta') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'karta'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('poništač karata') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'poništač karata'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kontrolor karata') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kontrolor karata'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('javni prijevoz') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'javni prijevoz'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('linija') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'linija'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('presjedati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'presjedati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vozač') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vozač'; end if;
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
  values ('69ba93db-7996-5afb-a43c-b9ea4d271329', 'fill_in_the_blank', 'Čekam na ___.', 'stanici', '["stanice", "stanici", "stanica", "stanicu"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '69ba93db-7996-5afb-a43c-b9ea4d271329', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('presjedati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ee72dcec-b1c4-58bf-9167-1ae3f9471803', 'multiple_choice', 'Що означає «presjedati»?', 'робити пересадку', '["трамвай", "контролер", "робити пересадку", "зупинка / станція"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ee72dcec-b1c4-58bf-9167-1ae3f9471803', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vozač') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('00d82720-cced-5889-b290-39dac33c58fe', 'multiple_choice', 'Що означає «vozač»?', 'водій', '["водій", "зупинка / станція", "квиток / карта", "робити пересадку"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '00d82720-cced-5889-b290-39dac33c58fe', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('javni prijevoz') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f980d9db-6603-5e6a-a4cb-ddfdd6105694', 'multiple_choice', 'Як хорватською «громадський транспорт»?', 'javni prijevoz', '["poništač karata", "kontrolor karata", "javni prijevoz", "sljedeći"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f980d9db-6603-5e6a-a4cb-ddfdd6105694', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('autobus') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c6ec6379-67c3-5aa5-b865-72039199fc5e', 'type_answer', 'Напишіть хорватською: «автобус»', 'autobus', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c6ec6379-67c3-5aa5-b865-72039199fc5e', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('sljedeći') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4fb4725a-4fac-5074-9bf8-a020e7dedb69', 'type_answer', 'Напишіть хорватською: «наступний»', 'sljedeći', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4fb4725a-4fac-5074-9bf8-a020e7dedb69', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('000a06ef-dc7b-5845-977a-0649e4a603c0', 'sentence_builder', 'Складіть: «Де я можу купити квиток?»', 'Gdje mogu kupiti kartu?', '["kupiti", "Gdje", "mogu", "kartu?"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '000a06ef-dc7b-5845-977a-0649e4a603c0', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('37e47a3d-5cdb-556f-b102-84de69da4d2a', 'sentence_builder', 'Складіть: «На якій зупинці?»', 'Na kojoj stanici?', '["stanici?", "kojoj", "Na"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '37e47a3d-5cdb-556f-b102-84de69da4d2a', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('375dfa40-3c8a-52dc-b044-3a25e9380548', 'listening', 'Прослухайте і складіть фразу', 'Na kiosku ili u tramvaju, kod vozača.', '["Na", "ili", "u", "tramvaju,", "kiosku", "kod", "vozača."]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '375dfa40-3c8a-52dc-b044-3a25e9380548', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e9725e94-2bdc-5592-8b2c-adf262960153', 'listening', 'Прослухайте і складіть фразу', 'Na sljedećoj. Onda uzmite šesticu.', '["Na", "sljedećoj.", "Onda", "šesticu.", "uzmite"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e9725e94-2bdc-5592-8b2c-adf262960153', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('151724db-a8ac-5772-985b-276e172a7fd9', 'speaking', 'Я в трамваї.', 'U tramvaju sam.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '151724db-a8ac-5772-985b-276e172a7fd9', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('19c797b3-ece1-5658-9349-c3492180b6bd', 'speaking', 'Я чекаю на зупинці.', 'Čekam na stanici.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '19c797b3-ece1-5658-9349-c3492180b6bd', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e1f64e62-cc75-5697-ae23-9d7524e2a387', v_lesson, 'Де купити квиток?', 'Gdje kupiti kartu?', 1161, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c5e872f0-ded7-553f-a37e-fb86e95dc64d', 'e1f64e62-cc75-5697-ae23-9d7524e2a387', 'Olena', 'Oprostite, gdje mogu kupiti kartu?', 'Вибачте, де я можу купити квиток?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6524ce01-7b4e-5030-bdb6-49f631a3be2f', 'e1f64e62-cc75-5697-ae23-9d7524e2a387', 'Gospođa', 'Na kiosku ili u tramvaju, kod vozača.', 'У кіоску або в трамваї, у водія.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ef7cc83d-e104-59fc-beb2-538f9a3cb65c', 'e1f64e62-cc75-5697-ae23-9d7524e2a387', 'Olena', 'Koliko košta?', 'Скільки коштує?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2edd7129-bf33-5186-ae61-55542f7c3e7f', 'e1f64e62-cc75-5697-ae23-9d7524e2a387', 'Gospođa', 'Kod vozača dva eura. Ne zaboravite je poništiti!', 'У водія два євро. Не забудьте її прокомпостувати!', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1bd599b8-38a7-5b61-b351-192813743c40', 'e1f64e62-cc75-5697-ae23-9d7524e2a387', 'Olena', 'Hvala na pomoći!', 'Дякую за допомогу!', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('12c3f895-5d6d-5c1c-923f-980ab2090ced', v_lesson, 'Пересадка', 'Presjedanje', 1162, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('987f86a3-b05f-5a3d-912c-9bb8e98aee1a', '12c3f895-5d6d-5c1c-923f-980ab2090ced', 'Taras', 'Ide li ovaj tramvaj do kolodvora?', 'Цей трамвай їде до вокзалу?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f1d32935-2907-5afd-b2e2-4c255a84f299', '12c3f895-5d6d-5c1c-923f-980ab2090ced', 'Mladić', 'Ne ide. Morate presjesti na Trgu bana Jelačića.', 'Не їде. Вам треба пересісти на площі бана Єлачича.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e42b7c04-9d1c-59f9-95fa-86f066909b9b', '12c3f895-5d6d-5c1c-923f-980ab2090ced', 'Taras', 'Na kojoj stanici?', 'На якій зупинці?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('076b0518-d492-52f6-9656-b777ff328c79', '12c3f895-5d6d-5c1c-923f-980ab2090ced', 'Mladić', 'Na sljedećoj. Onda uzmite šesticu.', 'На наступній. Потім сідайте на шістку.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a9e60db1-4fb2-5747-b3c6-3dd146e1a4fe', '12c3f895-5d6d-5c1c-923f-980ab2090ced', 'Taras', 'Hvala!', 'Дякую!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 17: Розклад поїздів
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'cae7a47d-7fb4-5b03-a8cc-5a0df2ccd92f';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.4: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.4.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 17: Розклад поїздів', 'Lekcija 17: Vozni red', '["Дізнатися, коли відправляється поїзд", "Купити квиток туди й назад", "Ставити питання: kada, koliko, zašto"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('vlak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vlak'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kolodvor') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kolodvor'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('peron') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'peron'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vozni red') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vozni red'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('polaziti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'polaziti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dolazak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dolazak'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kasniti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kasniti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kašnjenje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kašnjenje'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('povratna karta') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'povratna karta'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jednosmjerna karta') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jednosmjerna karta'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kada') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kada'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('koliko') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'koliko'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e633ff89-e16e-5e55-9869-d256fac7cbf1', 'fill_in_the_blank', '___ polazi vlak? — U tri.', 'Kada', '["Koliko", "Kada", "Tko", "Gdje"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e633ff89-e16e-5e55-9869-d256fac7cbf1', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('vlak') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5d5cd976-f9fe-5715-86a7-f6d4a8e6c904', 'multiple_choice', 'Що означає «vlak»?', 'поїзд', '["скільки", "запізнення", "поїзд", "квиток туди і назад"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5d5cd976-f9fe-5715-86a7-f6d4a8e6c904', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kada') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0dd8a571-ac58-5030-828f-6b3330c04d34', 'multiple_choice', 'Що означає «kada»?', 'коли', '["поїзд", "запізнення", "коли", "вокзал"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0dd8a571-ac58-5030-828f-6b3330c04d34', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('peron') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7987f3db-834a-5fe2-be1d-ec6ffd09741e', 'multiple_choice', 'Як хорватською «перон»?', 'peron', '["dolazak", "kada", "peron", "vozni red"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7987f3db-834a-5fe2-be1d-ec6ffd09741e', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('polaziti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c298432b-ed46-5ad6-86c0-dca08b11670c', 'type_answer', 'Напишіть хорватською: «відправлятися»', 'polaziti', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c298432b-ed46-5ad6-86c0-dca08b11670c', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('kolodvor') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('81d032cc-e7c0-5aee-8009-70c188f680ae', 'type_answer', 'Напишіть хорватською: «вокзал»', 'kolodvor', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '81d032cc-e7c0-5aee-8009-70c188f680ae', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c95a7553-4284-56f2-9148-06aa3aaefdf9', 'sentence_builder', 'Складіть: «Коли відправляється поїзд до Рієки?»', 'Kada polazi vlak za Rijeku?', '["vlak", "za", "Rijeku?", "Kada", "polazi"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c95a7553-4284-56f2-9148-06aa3aaefdf9', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('54632ac3-1d83-56c7-a2e6-7ab0720f198f', 'sentence_builder', 'Складіть: «Де можна випити кави?»', 'Gdje mogu popiti kavu?', '["popiti", "Gdje", "kavu?", "mogu"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '54632ac3-1d83-56c7-a2e6-7ab0720f198f', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('88b27787-b24a-51ae-b92e-ff5982396c6b', 'listening', 'Прослухайте і складіть фразу', 'Oko četiri sata.', '["četiri", "Oko", "sata."]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '88b27787-b24a-51ae-b92e-ff5982396c6b', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('09f6f165-80c2-552f-9eae-8b33208e44a3', 'listening', 'Прослухайте і складіть фразу', 'Kasni dvadeset minuta.', '["Kasni", "minuta.", "dvadeset"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '09f6f165-80c2-552f-9eae-8b33208e44a3', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5a19592c-b7fd-5a74-816e-080b7dfabc7e', 'speaking', 'Скільки триває поїздка?', 'Koliko traje vožnja?', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5a19592c-b7fd-5a74-816e-080b7dfabc7e', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('be41c2c9-feec-597c-8a24-c29bc9542e50', 'speaking', 'З якої платформи?', 'S kojeg perona?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'be41c2c9-feec-597c-8a24-c29bc9542e50', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('35d68ca5-c995-5530-b5d8-468ffc0db2d3', v_lesson, 'На вокзалі', 'Na kolodvoru', 1171, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('bf0e5efa-9b3f-52fb-8f0e-7037eac396cb', '35d68ca5-c995-5530-b5d8-468ffc0db2d3', 'Andrij', 'Kada polazi vlak za Rijeku?', 'Коли відправляється поїзд до Рієки?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1ef0aceb-a8c6-51bc-895d-55a66e0cdc7f', '35d68ca5-c995-5530-b5d8-468ffc0db2d3', 'Službenica', 'U četrnaest i dvadeset, s trećeg perona.', 'О чотирнадцятій двадцять, з третьої платформи.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('aab973ae-c5b8-5756-ab4c-fbcab1aac2c1', '35d68ca5-c995-5530-b5d8-468ffc0db2d3', 'Andrij', 'Koliko traje vožnja?', 'Скільки триває поїздка?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('86bdb99d-f484-53ec-9d5e-00de9ed6ccc7', '35d68ca5-c995-5530-b5d8-468ffc0db2d3', 'Službenica', 'Oko četiri sata.', 'Близько чотирьох годин.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('da9e4cc7-04e2-5759-979a-5ded4adcd097', '35d68ca5-c995-5530-b5d8-468ffc0db2d3', 'Andrij', 'Jednu povratnu kartu, molim.', 'Один квиток туди й назад, будь ласка.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e2ae8424-68e4-5b92-80e2-9d83f79c79cd', v_lesson, 'Поїзд запізнюється', 'Vlak kasni', 1172, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b8387074-15c6-57ca-abd6-efdedfe1fe9f', 'e2ae8424-68e4-5b92-80e2-9d83f79c79cd', 'Putnica', 'Zašto vlak još nije ovdje?', 'Чому поїзда досі немає?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f05b07b1-d107-5c8b-aad2-73468263300d', 'e2ae8424-68e4-5b92-80e2-9d83f79c79cd', 'Kondukter', 'Kasni dvadeset minuta.', 'Він запізнюється на двадцять хвилин.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('52f0fa12-1424-5c69-a47d-091d95e1a488', 'e2ae8424-68e4-5b92-80e2-9d83f79c79cd', 'Putnica', 'Kada stiže?', 'Коли він прибуває?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f5685fe3-468c-51ad-8ad8-446f6089fb9f', 'e2ae8424-68e4-5b92-80e2-9d83f79c79cd', 'Kondukter', 'U pola tri.', 'О пів на третю.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4e43596c-95cf-5127-b2c9-67e5ecf8d179', 'e2ae8424-68e4-5b92-80e2-9d83f79c79cd', 'Putnica', 'Gdje mogu popiti kavu?', 'Де можна випити кави?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4fef423a-b5ce-5be0-a1a9-046414792ac7', 'e2ae8424-68e4-5b92-80e2-9d83f79c79cd', 'Kondukter', 'U kafiću pored izlaza.', 'У кафе біля виходу.', 6) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 18: В аеропорту
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '69ec0776-4f69-5f86-afac-6652234a7da5';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.4: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.4.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 18: В аеропорту', 'Lekcija 18: U zračnoj luci', '["Пройти реєстрацію на рейс", "Запитати, чия це річ", "Вживати moj, Vaš, njegov, čiji"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('zračna luka') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zračna luka'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('let') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'let'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kofer') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kofer'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prtljaga') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prtljaga'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ručna prtljaga') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ručna prtljaga'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('putovnica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'putovnica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('izlaz za ukrcaj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'izlaz za ukrcaj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ukrcajna propusnica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ukrcajna propusnica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sjedalo do prozora') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sjedalo do prozora'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('avion') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'avion'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('torba') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'torba'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8ff86f1e-01fa-5aea-87d9-69672362f30e', 'fill_in_the_blank', 'Je li ovo ___ kofer? — Da, moj.', 'Vaš', '["Vaš", "Vaše", "Vaša", "Vašu"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8ff86f1e-01fa-5aea-87d9-69672362f30e', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('avion') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7de2c257-a4d4-50da-8bd1-42a4a2eb652a', 'multiple_choice', 'Що означає «avion»?', 'літак', '["аеропорт", "вихід на посадку", "валіза", "літак"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7de2c257-a4d4-50da-8bd1-42a4a2eb652a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('torba') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('138d064e-416c-5f7a-80aa-49c7e7d0a097', 'multiple_choice', 'Що означає «torba»?', 'сумка', '["ручна поклажа", "аеропорт", "посадковий талон", "сумка"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '138d064e-416c-5f7a-80aa-49c7e7d0a097', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('putovnica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e4ee0d25-3fbb-55d2-8aea-65f809453b29', 'multiple_choice', 'Як хорватською «закордонний паспорт»?', 'putovnica', '["prtljaga", "putovnica", "izlaz za ukrcaj", "sjedalo do prozora"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e4ee0d25-3fbb-55d2-8aea-65f809453b29', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ručna prtljaga') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9e6ced9b-dc78-5672-bf0e-51436855ffa5', 'type_answer', 'Напишіть хорватською: «ручна поклажа»', 'ručna prtljaga', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9e6ced9b-dc78-5672-bf0e-51436855ffa5', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('let') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('540a992d-5728-5701-88a1-50bff8b2a7ea', 'type_answer', 'Напишіть хорватською: «рейс / політ»', 'let', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '540a992d-5728-5701-88a1-50bff8b2a7ea', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('385c54b0-52ac-529c-8be3-14d9c1e9897e', 'sentence_builder', 'Складіть: «Це ваша валіза?»', 'Je li ovo Vaš kofer?', '["Vaš", "kofer?", "li", "Je", "ovo"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '385c54b0-52ac-529c-8be3-14d9c1e9897e', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1c4735af-43f1-5811-b955-8a64b8ccc061', 'sentence_builder', 'Складіть: «Не моя. Моя чорна.»', 'Nije moja. Moja je crna.', '["crna.", "Nije", "moja.", "Moja", "je"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1c4735af-43f1-5811-b955-8a64b8ccc061', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('feb1daac-2437-52fc-aa2d-bff5ab64d935', 'listening', 'Прослухайте і складіть фразу', 'Želite li sjedalo do prozora?', '["Želite", "li", "do", "prozora?", "sjedalo"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'feb1daac-2437-52fc-aa2d-bff5ab64d935', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0a25d610-28a9-5755-87c8-19a6c3d8d7d2', 'listening', 'Прослухайте і складіть фразу', 'Možda je njegova?', '["je", "Možda", "njegova?"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0a25d610-28a9-5755-87c8-19a6c3d8d7d2', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('95ecdbca-1cc4-5e6a-b182-223d21d75fcc', 'speaking', 'Це мій паспорт.', 'Ovo je moja putovnica.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '95ecdbca-1cc4-5e6a-b182-223d21d75fcc', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('02d5b4b4-5747-55db-8338-b23de5096484', 'speaking', 'Де вихід на посадку?', 'Gdje je izlaz za ukrcaj?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '02d5b4b4-5747-55db-8338-b23de5096484', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5bafa277-ad88-5368-a150-bb114f14b3e9', v_lesson, 'Реєстрація', 'Prijava za let', 1181, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3f189dff-a3bd-5896-ada0-789dd0220c38', '5bafa277-ad88-5368-a150-bb114f14b3e9', 'Službenik', 'Vašu putovnicu, molim.', 'Ваш паспорт, будь ласка.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1860b992-8333-54ae-be66-0849d0badcbf', '5bafa277-ad88-5368-a150-bb114f14b3e9', 'Iryna', 'Izvolite.', 'Прошу.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b2d6c9b0-ca3a-5cb2-a6d6-bfaed220d0d6', '5bafa277-ad88-5368-a150-bb114f14b3e9', 'Službenik', 'Je li ovo Vaš kofer?', 'Це ваша валіза?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3efc85f5-069f-5133-a1a0-cecbde81677e', '5bafa277-ad88-5368-a150-bb114f14b3e9', 'Iryna', 'Da, moj. A ova torba je ručna prtljaga.', 'Так, моя. А ця сумка — ручна поклажа.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1295a4b9-01a3-50bd-a3de-8f5c3a33a9bb', '5bafa277-ad88-5368-a150-bb114f14b3e9', 'Službenik', 'Želite li sjedalo do prozora?', 'Бажаєте місце біля вікна?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('dfd7e085-0c8e-50e1-b4cd-c96e0d25e553', '5bafa277-ad88-5368-a150-bb114f14b3e9', 'Iryna', 'Da, molim.', 'Так, будь ласка.', 6) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('339d93c7-d0b9-5780-a4d6-7045aee416bc', v_lesson, 'Чия це сумка?', 'Čija je ovo torba?', 1182, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('931b93f8-c8bf-5099-9925-1a82755aacdc', '339d93c7-d0b9-5780-a4d6-7045aee416bc', 'Djevojka', 'Oprostite, je li ovo Vaša torba?', 'Вибачте, це ваша сумка?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3f05be51-01a2-5f1e-9cb5-21b5b03aa071', '339d93c7-d0b9-5780-a4d6-7045aee416bc', 'Taras', 'Nije moja. Moja je crna.', 'Не моя. Моя чорна.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d33ffd11-a950-5c7d-bcab-65881449f049', '339d93c7-d0b9-5780-a4d6-7045aee416bc', 'Djevojka', 'Možda je njegova?', 'Може, це його?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5ea549ab-31f4-527a-9f97-cac653f16987', '339d93c7-d0b9-5780-a4d6-7045aee416bc', 'Muškarac', 'Da, moja je! Hvala Vam.', 'Так, моя! Дякую вам.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('15f1157e-54a5-510f-b18a-8795d07fb8fb', '339d93c7-d0b9-5780-a4d6-7045aee416bc', 'Djevojka', 'Nema na čemu.', 'Нема за що.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 19: Таксі
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '458ee6ec-31d1-5758-adef-03612626088a';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.4: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.4.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 19: Таксі', 'Lekcija 19: Taksi', '["Викликати таксі", "Попросити водія зупинитися", "Запитати, скільки платити"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('taksi') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'taksi'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('taksist') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'taksist'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('odmah') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'odmah'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('stići') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'stići'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prtljažnik') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prtljažnik'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('staviti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'staviti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('gužva') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'gužva'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('stati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'stati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('na vrijeme') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'na vrijeme'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('plaćati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'plaćati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('voziti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'voziti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9f402257-8f8c-574b-8ec3-afb95069c93d', 'fill_in_the_blank', '___ ovdje, molim!', 'Stanite', '["Stane", "Stanem", "Stanite", "Stati"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9f402257-8f8c-574b-8ec3-afb95069c93d', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('stići') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('eaaa7606-fa52-5fda-a9d5-ecd992f0551a', 'multiple_choice', 'Що означає «stići»?', 'прибути / доїхати', '["прибути / доїхати", "таксі", "таксист", "водити (авто) / везти"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'eaaa7606-fa52-5fda-a9d5-ecd992f0551a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('taksi') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c6bfcedc-fd38-5169-be50-a4ecc463d93f', 'multiple_choice', 'Що означає «taksi»?', 'таксі', '["платити", "водити (авто) / везти", "прибути / доїхати", "таксі"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c6bfcedc-fd38-5169-be50-a4ecc463d93f', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('na vrijeme') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1daa66e9-311c-54f8-8a3f-653b69c20d67', 'multiple_choice', 'Як хорватською «вчасно»?', 'na vrijeme', '["plaćati", "stići", "gužva", "na vrijeme"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1daa66e9-311c-54f8-8a3f-653b69c20d67', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('stati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8705161b-e383-5e35-8daa-f9be4182632d', 'type_answer', 'Напишіть хорватською: «зупинитися»', 'stati', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8705161b-e383-5e35-8daa-f9be4182632d', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('plaćati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2a276ba4-2755-5ee0-b080-00584cd86f5c', 'type_answer', 'Напишіть хорватською: «платити»', 'plaćati', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2a276ba4-2755-5ee0-b080-00584cd86f5c', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3cad4b82-fd01-51ae-87d5-ff4fdf9c0d5e', 'sentence_builder', 'Складіть: «Мені потрібне таксі до вокзалу.»', 'Trebam taksi do kolodvora.', '["Trebam", "kolodvora.", "do", "taksi"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3cad4b82-fd01-51ae-87d5-ff4fdf9c0d5e', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('258f1a32-1a02-5187-9c6a-ce3d51bd9b79', 'sentence_builder', 'Складіть: «Зупиніться тут, будь ласка.»', 'Stanite ovdje, molim.', '["Stanite", "molim.", "ovdje,"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '258f1a32-1a02-5187-9c6a-ce3d51bd9b79', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1c6828b9-97a3-5a05-8a7b-b5704231f191', 'listening', 'Прослухайте і складіть фразу', 'Odmah, molim. Idem na kolodvor.', '["molim.", "kolodvor.", "na", "Idem", "Odmah,"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1c6828b9-97a3-5a05-8a7b-b5704231f191', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6da4f022-fb78-5955-beef-f891aec21793', 'listening', 'Прослухайте і складіть фразу', 'Ima gužve, ali stižemo na vrijeme.', '["na", "vrijeme.", "gužve,", "ali", "Ima", "stižemo"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6da4f022-fb78-5955-beef-f891aec21793', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c46a0f83-6257-5d7a-8f9c-eeace227eba4', 'speaking', 'Покладіть валізу в багажник.', 'Stavite kofer u prtljažnik.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c46a0f83-6257-5d7a-8f9c-eeace227eba4', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b7ea4cc1-4a9c-5750-89e2-64080bce62e7', 'speaking', 'Скільки з мене?', 'Koliko plaćam?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b7ea4cc1-4a9c-5750-89e2-64080bce62e7', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b3441025-0dcd-5dd6-a31b-6ceb2f3fb110', v_lesson, 'Виклик таксі', 'Naručivanje taksija', 1191, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('eb15cdf9-4435-5b9d-b8e8-f615436060ce', 'b3441025-0dcd-5dd6-a31b-6ceb2f3fb110', 'Oksana', 'Dobar dan, trebam taksi na adresu Ilica deset.', 'Добрий день, мені потрібне таксі на адресу Іліца, 10.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('86c100cd-d921-52d3-9846-bc40ded8e86b', 'b3441025-0dcd-5dd6-a31b-6ceb2f3fb110', 'Dispečerica', 'Kada?', 'Коли?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('929ef4b3-1def-5b0f-942e-52017d5e0f41', 'b3441025-0dcd-5dd6-a31b-6ceb2f3fb110', 'Oksana', 'Odmah, molim. Idem na kolodvor.', 'Негайно, будь ласка. Я їду на вокзал.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cbcdd603-3bfe-547e-b733-0f502d2ce5ed', 'b3441025-0dcd-5dd6-a31b-6ceb2f3fb110', 'Dispečerica', 'Taksi stiže za pet minuta. Bijela Škoda.', 'Таксі приїде за п’ять хвилин. Біла «Шкода».', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('40840853-432e-5f67-9a65-c970305bd771', v_lesson, 'У таксі', 'U taksiju', 1192, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c6410e83-1406-52ff-a0ff-81b8fc6cceca', '40840853-432e-5f67-9a65-c970305bd771', 'Taksist', 'Stavite kofer u prtljažnik.', 'Покладіть валізу в багажник.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('762f72ef-6a1e-5d51-a0e6-eb02c3f16804', '40840853-432e-5f67-9a65-c970305bd771', 'Oksana', 'Hvala. Možete li voziti malo brže? Žurim se.', 'Дякую. Можете їхати трохи швидше? Я поспішаю.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5ab2b8e6-0eab-5ecb-b5d0-8e30ae5eb0f6', '40840853-432e-5f67-9a65-c970305bd771', 'Taksist', 'Ima gužve, ali stižemo na vrijeme.', 'Є затор, але ми встигаємо вчасно.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cb277687-7dcc-5717-b471-203ceb35663d', '40840853-432e-5f67-9a65-c970305bd771', 'Oksana', 'Stanite ovdje, molim. Koliko plaćam?', 'Зупиніться тут, будь ласка. Скільки з мене?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3cd93f08-5406-5209-92a3-6c0c5f7b4f28', '40840853-432e-5f67-9a65-c970305bd771', 'Taksist', 'Dvanaest eura.', 'Дванадцять євро.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.4 · урок 20: Заправка й паркування
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'd6ca64d8-4c71-5936-a930-51e400f5681d';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.4: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.4.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 20: Заправка й паркування', 'Lekcija 20: Benzinska i parkiranje', '["Заправити машину", "Запитати, чи можна тут паркуватися", "Вживати smijem li, moram"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('auto') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'auto'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('benzinska postaja') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'benzinska postaja'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('benzin') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'benzin'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dizel') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dizel'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rezervoar') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rezervoar'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('guma') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'guma'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('provjeriti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'provjeriti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('parkirati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'parkirati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zona') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zona'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('automat') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'automat'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kazna') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kazna'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pun') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pun'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('619e50e5-b4a2-5480-844e-201ae7798a01', 'fill_in_the_blank', 'Mi ___ platiti parking.', 'moramo', '["moraju", "moram", "moramo", "moraš"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '619e50e5-b4a2-5480-844e-201ae7798a01', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('rezervoar') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('55c87292-dfcb-5563-920b-ae3b64dce1b6', 'multiple_choice', 'Що означає «rezervoar»?', 'бак (паливний)', '["автомат (паркомат, автомат з продажу)", "бак (паливний)", "перевірити", "штраф / покарання"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '55c87292-dfcb-5563-920b-ae3b64dce1b6', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('automat') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d2fb5076-ed0d-579f-9611-b16fdf9f5bcb', 'multiple_choice', 'Що означає «automat»?', 'автомат (паркомат, автомат з продажу)', '["штраф / покарання", "зона", "паркуватися", "автомат (паркомат, автомат з продажу)"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd2fb5076-ed0d-579f-9611-b16fdf9f5bcb', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('parkirati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('260037eb-4f7d-59ca-b322-c86cb53372f2', 'multiple_choice', 'Як хорватською «паркуватися»?', 'parkirati', '["benzinska postaja", "parkirati", "dizel", "auto"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '260037eb-4f7d-59ca-b322-c86cb53372f2', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kazna') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2dcc5d2b-a55f-5ac6-affd-4fc8448d7b41', 'type_answer', 'Напишіть хорватською: «штраф / покарання»', 'kazna', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2dcc5d2b-a55f-5ac6-affd-4fc8448d7b41', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('zona') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a3556eff-72de-5b68-b2fb-759fdb091720', 'type_answer', 'Напишіть хорватською: «зона»', 'zona', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a3556eff-72de-5b68-b2fb-759fdb091720', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('68c5837f-100c-5aea-a19b-714042803ced', 'sentence_builder', 'Складіть: «Дизель, повний бак, будь ласка.»', 'Dizel, pun rezervoar, molim.', '["pun", "molim.", "Dizel,", "rezervoar,"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '68c5837f-100c-5aea-a19b-714042803ced', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3bade5dc-91e8-515d-8d29-f972a5fdeefb', 'sentence_builder', 'Складіть: «Мені можна тут паркуватися?»', 'Smijem li ovdje parkirati?', '["li", "ovdje", "Smijem", "parkirati?"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3bade5dc-91e8-515d-8d29-f972a5fdeefb', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('07f9a9c4-2643-51c5-b64d-1b62ab1b2f18', 'listening', 'Прослухайте і складіть фразу', 'Plaćate unutra, na blagajni.', '["unutra,", "Plaćate", "blagajni.", "na"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '07f9a9c4-2643-51c5-b64d-1b62ab1b2f18', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a157a95e-2f37-5649-98aa-29ae2d29f29e', 'listening', 'Прослухайте і складіть фразу', 'Gdje je automat?', '["automat?", "Gdje", "je"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a157a95e-2f37-5649-98aa-29ae2d29f29e', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('717bf3b0-897c-5a94-9e57-9f8270cf2260', 'speaking', 'Де заправка?', 'Gdje je benzinska postaja?', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '717bf3b0-897c-5a94-9e57-9f8270cf2260', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3e904d4a-579f-545e-b4e5-fb35ade4c254', 'speaking', 'Тут треба платити?', 'Moram li ovdje platiti?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3e904d4a-579f-545e-b4e5-fb35ade4c254', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('563e541a-ac09-5faf-bc22-75c0b21594c5', v_lesson, 'На заправці', 'Na benzinskoj', 1201, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('dcb5c234-1331-5b88-9383-218628abe1d1', '563e541a-ac09-5faf-bc22-75c0b21594c5', 'Radnik', 'Dobar dan! Benzin ili dizel?', 'Добрий день! Бензин чи дизель?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0947b7c7-8481-59be-ac65-59b696336d4e', '563e541a-ac09-5faf-bc22-75c0b21594c5', 'Taras', 'Dizel, pun rezervoar, molim.', 'Дизель, повний бак, будь ласка.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('36ce15cd-3874-5305-8f9c-f86c1abb46fb', '563e541a-ac09-5faf-bc22-75c0b21594c5', 'Radnik', 'Plaćate unutra, na blagajni.', 'Платите всередині, на касі.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('617213f4-0e2a-5252-bc74-5f65794beb6a', '563e541a-ac09-5faf-bc22-75c0b21594c5', 'Taras', 'Mogu li ovdje provjeriti gume?', 'Чи можу я тут перевірити шини?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ceb395d8-098b-503b-8bf9-7e71e19d4de9', '563e541a-ac09-5faf-bc22-75c0b21594c5', 'Radnik', 'Možete, zrak je iza postaje.', 'Можете, повітря — за заправкою.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8fff3581-695c-50fd-8ec0-fdde50e3b3df', v_lesson, 'Де можна паркуватися?', 'Gdje smijem parkirati?', 1202, 'A1', 'transport', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('572df6b3-43cb-5924-ab76-9f15d3841e5b', '8fff3581-695c-50fd-8ec0-fdde50e3b3df', 'Iryna', 'Oprostite, smijem li ovdje parkirati?', 'Вибачте, мені можна тут паркуватися?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1707de0f-36d6-53e8-8a50-2fbf4c82c5e8', '8fff3581-695c-50fd-8ec0-fdde50e3b3df', 'Prolaznik', 'Smijete, ali morate platiti. Ovo je druga zona.', 'Можна, але треба заплатити. Це друга зона.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('20ee163e-bed2-52df-a3fb-481c57b272f7', '8fff3581-695c-50fd-8ec0-fdde50e3b3df', 'Iryna', 'Gdje je automat?', 'Де паркомат?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('86fd9344-9f0a-5a70-a2bf-5865de5d1d72', '8fff3581-695c-50fd-8ec0-fdde50e3b3df', 'Prolaznik', 'Tamo. Ili platite SMS-om.', 'Он там. Або заплатіть через SMS.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9aa1bcd0-e152-52ee-8dc8-0f22ae051eb3', '8fff3581-695c-50fd-8ec0-fdde50e3b3df', 'Iryna', 'Hvala! Ne želim kaznu.', 'Дякую! Не хочу штрафу.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 21: Шукаю квартиру
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '278947e3-ae50-5818-abd7-7f07b8ab5c44';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.5: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '765ac66f-d54b-505b-9b11-c48e5ad26018';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.5.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 21: Шукаю квартиру', 'Lekcija 21: Tražim stan', '["Зателефонувати щодо оголошення", "Запитати про оренду, заставу й комунальні", "Поєднувати думки: i, ali, jer"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('stan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'stan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('najam') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'najam'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('najamnina') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'najamnina'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('režije') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'režije'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('namješten') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'namješten'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('polog') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'polog'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ugovor') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ugovor'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kat') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kat'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dizalo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dizalo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('garaža') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'garaža'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('stanodavac') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'stanodavac'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('useliti se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'useliti se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('09fad40f-2d4e-5317-8001-0f68cf481e69', 'fill_in_the_blank', 'Stan je lijep, ___ je skup.', 'ali', '["ali", "ili", "jer", "i"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '09fad40f-2d4e-5317-8001-0f68cf481e69', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('stanodavac') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('576ca0d4-188a-5566-8b90-49987a29be7b', 'multiple_choice', 'Що означає «stanodavac»?', 'власник житла / орендодавець', '["власник житла / орендодавець", "комунальні послуги / рахунки", "договір / контракт", "в''їхати (в житло)"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '576ca0d4-188a-5566-8b90-49987a29be7b', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('režije') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2941c116-ca5f-5514-9c9f-f0bf17c1f384', 'multiple_choice', 'Що означає «režije»?', 'комунальні послуги / рахунки', '["поверх", "комунальні послуги / рахунки", "орендна плата / квартплата", "оренда"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2941c116-ca5f-5514-9c9f-f0bf17c1f384', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('garaža') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5c3b1dc8-da30-5772-b437-c41cefc88564', 'multiple_choice', 'Як хорватською «гараж»?', 'garaža', '["useliti se", "garaža", "režije", "namješten"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5c3b1dc8-da30-5772-b437-c41cefc88564', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kat') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9c085aa2-e725-5454-aa8f-ccc5958d13ba', 'type_answer', 'Напишіть хорватською: «поверх»', 'kat', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9c085aa2-e725-5454-aa8f-ccc5958d13ba', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('polog') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c52e4b12-45dc-5ec0-a96d-1b385fb86b7c', 'type_answer', 'Напишіть хорватською: «застава / депозит»', 'polog', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c52e4b12-45dc-5ec0-a96d-1b385fb86b7c', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9fb2edbd-b484-57d8-aa98-788f8680f427', 'sentence_builder', 'Складіть: «Квартира ще вільна.»', 'Stan je još slobodan.', '["je", "još", "slobodan.", "Stan"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9fb2edbd-b484-57d8-aa98-788f8680f427', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9c9ca28b-98c1-5395-9fef-6919e7ee78b8', 'sentence_builder', 'Складіть: «Мені подобається, бо вона світла.»', 'Sviđa mi se jer je svijetao.', '["mi", "je", "jer", "Sviđa", "svijetao.", "se"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9c9ca28b-98c1-5395-9fef-6919e7ee78b8', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('bd25dad4-e17b-50d0-9f7b-f88bdca55700', 'listening', 'Прослухайте і складіть фразу', 'Je li namješten?', '["namješten?", "Je", "li"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'bd25dad4-e17b-50d0-9f7b-f88bdca55700', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('aeffce8b-a604-5401-8f60-16921bd82762', 'listening', 'Прослухайте і складіть фразу', 'Polog je jedna najamnina.', '["najamnina.", "Polog", "je", "jedna"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'aeffce8b-a604-5401-8f60-16921bd82762', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('623107eb-d795-513a-ac9d-b517a602520d', 'speaking', 'Скільки коштує оренда?', 'Koliko je najamnina?', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '623107eb-d795-513a-ac9d-b517a602520d', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('77789058-042a-5e38-a769-ab6c94332edc', 'speaking', 'Квартира гарна, але дорога.', 'Stan je lijep, ali skup.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '77789058-042a-5e38-a769-ab6c94332edc', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b168f346-76bc-5225-8397-42b6b17bac28', v_lesson, 'Дзвінок щодо оголошення', 'Poziv zbog oglasa', 1211, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('44d7eeb1-9b3d-5080-9eca-54ab6574a0e1', 'b168f346-76bc-5225-8397-42b6b17bac28', 'Oksana', 'Dobar dan, zovem zbog oglasa za stan.', 'Добрий день, я телефоную щодо оголошення про квартиру.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c68ca67f-08c3-596a-a2fc-38533d8cf70e', 'b168f346-76bc-5225-8397-42b6b17bac28', 'Stanodavac', 'Da, stan je još slobodan.', 'Так, квартира ще вільна.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('217151df-b434-5852-936f-0c635806cf67', 'b168f346-76bc-5225-8397-42b6b17bac28', 'Oksana', 'Je li namješten?', 'Вона мебльована?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('88fbe72a-0e74-54d4-b631-72f432fa910d', 'b168f346-76bc-5225-8397-42b6b17bac28', 'Stanodavac', 'Jest, ali nema perilice.', 'Так, але немає пральної машини.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('26f9e522-0498-5366-8ad8-76d31e9d304b', 'b168f346-76bc-5225-8397-42b6b17bac28', 'Oksana', 'Koliko je najamnina?', 'Скільки коштує оренда?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a7ec4721-b85c-53fa-b6ab-21d41587ef01', 'b168f346-76bc-5225-8397-42b6b17bac28', 'Stanodavac', 'Petsto pedeset eura i režije.', 'П’ятсот п’ятдесят євро плюс комунальні.', 6) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b5990243-0ca2-513d-82bc-5693910cde2a', v_lesson, 'Огляд квартири', 'Razgled stana', 1212, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0b3d6462-cfac-58e2-80fe-8600fbfc7ba2', 'b5990243-0ca2-513d-82bc-5693910cde2a', 'Stanodavac', 'Stan je na trećem katu, a dizalo radi.', 'Квартира на третьому поверсі, і ліфт працює.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('116505f8-f8e9-5e45-8b02-d2588c06d49c', 'b5990243-0ca2-513d-82bc-5693910cde2a', 'Oksana', 'Sviđa mi se jer je svijetao.', 'Мені подобається, бо вона світла.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b995e8b8-b7f3-5e9d-8649-b99f7a99e482', 'b5990243-0ca2-513d-82bc-5693910cde2a', 'Stanodavac', 'Polog je jedna najamnina.', 'Застава — одна місячна оплата.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('eae6b635-506e-592b-9892-0cdb8455e66b', 'b5990243-0ca2-513d-82bc-5693910cde2a', 'Oksana', 'Mogu li se useliti prvog?', 'Чи можу я в’їхати першого числа?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c9c63d86-ddbb-5729-a2c3-ee0396d123df', 'b5990243-0ca2-513d-82bc-5693910cde2a', 'Stanodavac', 'Možete. Ugovor potpisujemo sutra.', 'Можете. Договір підписуємо завтра.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 22: Щось не працює
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '8fc3399d-0405-5517-9358-d3ad6308d860';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.5: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.5.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 22: Щось не працює', 'Lekcija 22: Nešto ne radi', '["Пояснити орендодавцю, що зламалося", "Домовитися про прихід майстра", "Сказати, де проблема: u kupaonici, u kuhinji"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('kvar') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kvar'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('popraviti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'popraviti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('majstor') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'majstor'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('grijanje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'grijanje'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('struja') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'struja'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('perilica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'perilica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tuš') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tuš'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('hladnjak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hladnjak'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kupaonica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kupaonica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kuhinja') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kuhinja'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('utičnica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'utičnica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('voda') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'voda'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c68404e1-46eb-54d4-8d23-78d7d47bff64', 'fill_in_the_blank', 'Problem je u ___.', 'kuhinji', '["kuhinje", "kuhinju", "kuhinji", "kuhinja"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c68404e1-46eb-54d4-8d23-78d7d47bff64', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('perilica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('eae06fb7-dc5c-5fc1-86ce-ee4a6d964036', 'multiple_choice', 'Що означає «perilica»?', 'пральна машина', '["кухня", "майстер", "ванна кімната", "пральна машина"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'eae06fb7-dc5c-5fc1-86ce-ee4a6d964036', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('voda') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d112938f-fa9d-5411-9129-fc21954d2a29', 'multiple_choice', 'Що означає «voda»?', 'вода', '["холодильник", "опалення", "вода", "пральна машина"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd112938f-fa9d-5411-9129-fc21954d2a29', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('grijanje') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e4c525b3-385a-5411-8fc1-045f7691e932', 'multiple_choice', 'Як хорватською «опалення»?', 'grijanje', '["hladnjak", "utičnica", "kvar", "grijanje"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e4c525b3-385a-5411-8fc1-045f7691e932', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kuhinja') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9eee176d-16dc-5d4c-91f1-30416660553c', 'type_answer', 'Напишіть хорватською: «кухня»', 'kuhinja', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9eee176d-16dc-5d4c-91f1-30416660553c', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('hladnjak') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('511d0913-e787-5a27-b98d-881d5218f305', 'type_answer', 'Напишіть хорватською: «холодильник»', 'hladnjak', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '511d0913-e787-5a27-b98d-881d5218f305', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('60896779-d711-5d00-898f-cf49991e5ea3', 'sentence_builder', 'Складіть: «У ванній щось не працює.»', 'U kupaonici nešto ne radi.', '["ne", "nešto", "radi.", "U", "kupaonici"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '60896779-d711-5d00-898f-cf49991e5ea3', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('65b9c819-b8fc-5537-b432-61bc812817a6', 'sentence_builder', 'Складіть: «Холодильник не охолоджує.»', 'Hladnjak ne hladi.', '["ne", "hladi.", "Hladnjak"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '65b9c819-b8fc-5537-b432-61bc812817a6', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b593363c-3481-5546-8556-86108348bfc9', 'listening', 'Прослухайте і складіть фразу', 'Tuš. Nema tople vode.', '["tople", "Tuš.", "vode.", "Nema"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b593363c-3481-5546-8556-86108348bfc9', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('42f3a007-3a50-5d5f-86f4-2d838422cd9f', 'listening', 'Прослухайте і складіть фразу', 'A struja? Je li utičnica u redu?', '["Je", "li", "redu?", "A", "utičnica", "struja?", "u"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '42f3a007-3a50-5d5f-86f4-2d838422cd9f', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('aaa3b616-3655-59f9-8f0f-fbe3359f0832', 'speaking', 'Холодильник не працює.', 'Hladnjak ne radi.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'aaa3b616-3655-59f9-8f0f-fbe3359f0832', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a8d97ec9-aede-57c0-85e0-b866482e136b', 'speaking', 'Я вдома після п’ятої.', 'Doma sam poslije pet.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a8d97ec9-aede-57c0-85e0-b866482e136b', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('44dab520-fbf0-5338-b23c-bb81cb058602', v_lesson, 'Дзвінок орендодавцю', 'Poziv stanodavcu', 1221, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b19e06c6-af7f-52df-bcec-3d871891df91', '44dab520-fbf0-5338-b23c-bb81cb058602', 'Andrij', 'Dobar dan, gospodine Horvat. U kupaonici nešto ne radi.', 'Добрий день, пане Горват. У ванній щось не працює.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e1d5d19b-9136-5946-9d47-1f64876922ea', '44dab520-fbf0-5338-b23c-bb81cb058602', 'Stanodavac', 'Što točno?', 'Що саме?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('821d9f16-0af6-5b0a-8c9f-475913c3b3eb', '44dab520-fbf0-5338-b23c-bb81cb058602', 'Andrij', 'Tuš. Nema tople vode.', 'Душ. Немає гарячої води.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d0445922-72f5-5350-b788-c339b894bb4f', '44dab520-fbf0-5338-b23c-bb81cb058602', 'Stanodavac', 'Sutra šaljem majstora.', 'Завтра надішлю майстра.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c30d6bf5-6b0b-53f5-a05b-46ba20435ca2', '44dab520-fbf0-5338-b23c-bb81cb058602', 'Andrij', 'Hvala. Ja sam doma poslije pet.', 'Дякую. Я вдома після п’ятої.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('98101c6a-101b-5e5a-bd6f-35abb0296ce0', v_lesson, 'Майстер', 'Majstor', 1222, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e0d45f68-5d3f-5800-a776-da3c571b9e9d', '98101c6a-101b-5e5a-bd6f-35abb0296ce0', 'Majstor', 'Gdje je problem?', 'Де проблема?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3c37393e-4cc7-5ba4-8b30-47496d53084f', '98101c6a-101b-5e5a-bd6f-35abb0296ce0', 'Andrij', 'U kuhinji. Hladnjak ne hladi.', 'На кухні. Холодильник не охолоджує.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('59e6aa25-b799-548c-9f5c-bcbe7e299407', '98101c6a-101b-5e5a-bd6f-35abb0296ce0', 'Majstor', 'A struja? Je li utičnica u redu?', 'А електрика? Розетка в порядку?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0d52456f-1fc0-5824-b891-9017c97dd999', '98101c6a-101b-5e5a-bd6f-35abb0296ce0', 'Andrij', 'Mislim da jest.', 'Думаю, що так.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('26b4dccc-af71-55e2-995e-cf2b2463e7aa', '98101c6a-101b-5e5a-bd6f-35abb0296ce0', 'Majstor', 'Dobro, sad gledam.', 'Добре, зараз подивлюся.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 23: Новий сусід
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'a42b9121-2ec0-5064-909b-f59f315b3c4a';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.5: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.5.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 23: Новий сусід', 'Lekcija 23: Novi susjed', '["Познайомитися із сусідом", "Запитати про правила будинку", "Ввічливо попросити: stišajte, nemojte"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('susjed') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'susjed'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('smeće') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'smeće'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kanta za smeće') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kanta za smeće'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('buka') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'buka'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tiho') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tiho'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('glasno') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'glasno'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('stepenice') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'stepenice'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vrata') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vrata'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zvono') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zvono'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('parkiralište') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'parkiralište'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('upoznati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'upoznati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pozdraviti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pozdraviti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6994db6c-1567-51bf-8e95-1e117c2f3fe3', 'fill_in_the_blank', 'Molim Vas, ___ glazbu.', 'stišajte', '["stišati", "stišaju", "stišam", "stišajte"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6994db6c-1567-51bf-8e95-1e117c2f3fe3', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('smeće') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d9a2325d-82c4-58e7-8bfe-b73f9fdd2716', 'multiple_choice', 'Що означає «smeće»?', 'сміття', '["сусід", "голосно", "шум", "сміття"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd9a2325d-82c4-58e7-8bfe-b73f9fdd2716', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('parkiralište') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('429d246d-7882-5fa5-965c-adc3c1d60534', 'multiple_choice', 'Що означає «parkiralište»?', 'автостоянка / парковка', '["шум", "познайомитися / пізнати", "автостоянка / парковка", "тихо"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '429d246d-7882-5fa5-965c-adc3c1d60534', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('buka') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('009a1a53-87c8-5f38-9bee-4c9ebe65e048', 'multiple_choice', 'Як хорватською «шум»?', 'buka', '["vrata", "glasno", "smeće", "buka"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '009a1a53-87c8-5f38-9bee-4c9ebe65e048', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('upoznati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('66970083-6969-55e7-a251-f7c564162793', 'type_answer', 'Напишіть хорватською: «познайомитися / пізнати»', 'upoznati', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '66970083-6969-55e7-a251-f7c564162793', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('vrata') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('90ea7387-0cdf-5ab7-866b-d3763494c27b', 'type_answer', 'Напишіть хорватською: «двері»', 'vrata', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '90ea7387-0cdf-5ab7-866b-d3763494c27b', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4e89e9ef-9d47-5486-ab99-534cf0ff297e', 'sentence_builder', 'Складіть: «Я живу на другому поверсі.»', 'Živim na drugom katu.', '["drugom", "Živim", "katu.", "na"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4e89e9ef-9d47-5486-ab99-534cf0ff297e', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('92244612-6441-5e98-96e8-60d43f71edad', 'sentence_builder', 'Складіть: «Розумію, зараз вимкну.»', 'Razumijem, odmah gasim.', '["Razumijem,", "gasim.", "odmah"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '92244612-6441-5e98-96e8-60d43f71edad', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('791d1f1e-db5d-5bff-8903-432f586cfe7a', 'listening', 'Прослухайте і складіть фразу', 'Dolje, pored parkirališta.', '["parkirališta.", "pored", "Dolje,"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '791d1f1e-db5d-5bff-8903-432f586cfe7a', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('54c226d7-12bc-5d2b-a764-d4d329e707ef', 'listening', 'Прослухайте і складіть фразу', 'Jest. Djeca već spavaju.', '["spavaju.", "Djeca", "Jest.", "već"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '54c226d7-12bc-5d2b-a764-d4d329e707ef', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fa9e666d-673b-517a-ab28-8a1fa5ff3b08', 'speaking', 'Я ваш новий сусід.', 'Ja sam Vaš novi susjed.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fa9e666d-673b-517a-ab28-8a1fa5ff3b08', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('dfd4ef87-1511-591f-af51-4164a8079625', 'speaking', 'Не паркуйтеся тут, будь ласка.', 'Molim Vas, nemojte parkirati ovdje.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'dfd4ef87-1511-591f-af51-4164a8079625', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1f226b65-81ec-57ff-94a0-9dd29e532379', v_lesson, 'Знайомство на сходах', 'Na stepenicama', 1231, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a33403bb-a21c-55ca-8aa3-804a590612fd', '1f226b65-81ec-57ff-94a0-9dd29e532379', 'Susjeda', 'Dobar dan! Vi ste novi susjed?', 'Добрий день! Ви новий сусід?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3236fcfc-2ef6-5ffd-9ef7-053c01d7d544', '1f226b65-81ec-57ff-94a0-9dd29e532379', 'Taras', 'Da, ja sam Taras. Živim na drugom katu.', 'Так, я Тарас. Живу на другому поверсі.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f741e895-1b8b-5bd7-abe9-05452767f4e8', '1f226b65-81ec-57ff-94a0-9dd29e532379', 'Susjeda', 'Ja sam Ana, iz stana pet. Drago mi je!', 'Я Ана, з п’ятої квартири. Приємно познайомитися!', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9f58f104-d35e-5311-b9a7-dfce2276cddf', '1f226b65-81ec-57ff-94a0-9dd29e532379', 'Taras', 'I meni. Gdje bacamo smeće?', 'Мені теж. Куди ми викидаємо сміття?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('afca38f3-bacd-5e2d-a68f-b9736cc32554', '1f226b65-81ec-57ff-94a0-9dd29e532379', 'Susjeda', 'Dolje, pored parkirališta. Plava kanta je za papir.', 'Унизу, біля парковки. Синій бак — для паперу.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('14cae966-24cb-55f9-99e5-08012cc7ca02', v_lesson, 'Тихіше, будь ласка', 'Malo tiše, molim', 1232, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e450580c-7bb1-5adc-8982-ea058a87d6ba', '14cae966-24cb-55f9-99e5-08012cc7ca02', 'Susjed', 'Oprostite, molim Vas, stišajte glazbu.', 'Перепрошую, будь ласка, зробіть музику тихіше.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2a5ec911-2597-5e15-97f5-8c3a571dfdc7', '14cae966-24cb-55f9-99e5-08012cc7ca02', 'Iryna', 'Oprostite! Je li preglasna?', 'Вибачте! Занадто гучно?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c245addb-397a-5b95-8a9a-a30b6a41fad4', '14cae966-24cb-55f9-99e5-08012cc7ca02', 'Susjed', 'Jest. Djeca već spavaju.', 'Так. Діти вже сплять.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('df06f9a4-80d6-5789-b459-7ee6ac960bcb', '14cae966-24cb-55f9-99e5-08012cc7ca02', 'Iryna', 'Razumijem, odmah gasim.', 'Розумію, зараз вимкну.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('44cb9f6d-1238-5f4e-860b-c080b395e1f1', '14cae966-24cb-55f9-99e5-08012cc7ca02', 'Susjed', 'Hvala i laku noć!', 'Дякую і на добраніч!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.5 · урок 24: Рахунки й інтернет
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'b69a8cca-4918-562f-8ae5-22f8d7ba2f76';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.5: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.5.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 24: Рахунки й інтернет', 'Lekcija 24: Računi i internet', '["Дізнатися, хто платить комунальні", "Оплатити квитанцію", "Повідомити, що не працює інтернет"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('račun za struju') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'račun za struju'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('plin') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'plin'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('uplatnica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'uplatnica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('mobilno bankarstvo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'mobilno bankarstvo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rok') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rok'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('internet') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'internet'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ruter') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ruter'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('uključen') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'uključen'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('lozinka') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'lozinka'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tehničar') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tehničar'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('korisnik') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'korisnik'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('abbcf325-4ccc-5f57-90e5-fe6a1e7877fc', 'fill_in_the_blank', '___ internet ne radi.', 'Naš', '["Našu", "Naše", "Naša", "Naš"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'abbcf325-4ccc-5f57-90e5-fe6a1e7877fc', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('korisnik') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a6b35c31-ce4a-5c52-b722-5d1231ae388a', 'multiple_choice', 'Що означає «korisnik»?', 'користувач', '["рахунок за електрику", "користувач", "пароль", "увімкнений; включений"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a6b35c31-ce4a-5c52-b722-5d1231ae388a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rok') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('eb8ddbeb-8e43-5fe0-8857-f54bcc541fa6', 'multiple_choice', 'Що означає «rok»?', 'дедлайн / термін', '["платіжна квитанція", "дедлайн / термін", "мобільний банкінг", "роутер"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'eb8ddbeb-8e43-5fe0-8857-f54bcc541fa6', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('uključen') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('40f6eaff-8bd1-574d-966a-35778028507f', 'multiple_choice', 'Як хорватською «увімкнений; включений»?', 'uključen', '["mobilno bankarstvo", "uključen", "uplatnica", "tehničar"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '40f6eaff-8bd1-574d-966a-35778028507f', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('plin') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7864ba4c-309f-5b8d-bade-645f05e2d461', 'type_answer', 'Напишіть хорватською: «газ»', 'plin', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7864ba4c-309f-5b8d-bade-645f05e2d461', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('lozinka') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9192df41-9524-59de-aef9-184d3963371c', 'type_answer', 'Напишіть хорватською: «пароль»', 'lozinka', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9192df41-9524-59de-aef9-184d3963371c', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fa95942f-353b-5376-9556-d3b539b94dd0', 'sentence_builder', 'Складіть: «Хто оплачує рахунок?»', 'Tko plaća račun?', '["plaća", "Tko", "račun?"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fa95942f-353b-5376-9556-d3b539b94dd0', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('671d5912-e90c-5b27-b860-8462b933098b', 'sentence_builder', 'Складіть: «Наш інтернет не працює.»', 'Naš internet ne radi.', '["Naš", "ne", "radi.", "internet"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '671d5912-e90c-5b27-b860-8462b933098b', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5e18600c-40d5-5ebe-b7de-750734aac4d0', 'listening', 'Прослухайте і складіть фразу', 'Koji je rok?', '["rok?", "Koji", "je"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5e18600c-40d5-5ebe-b7de-750734aac4d0', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4a8a3a50-b691-5f2e-8e83-9c2765fc24d6', 'listening', 'Прослухайте і складіть фразу', 'Je li ruter uključen?', '["ruter", "li", "uključen?", "Je"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4a8a3a50-b691-5f2e-8e83-9c2765fc24d6', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('85b09878-f3b1-52be-b7f3-3a0e3a90b2ac', 'speaking', 'Як я можу заплатити?', 'Kako mogu platiti?', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '85b09878-f3b1-52be-b7f3-3a0e3a90b2ac', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ac797985-e910-5ef5-a87b-289a4a5e7055', 'speaking', 'Роутер не працює.', 'Ruter ne radi.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ac797985-e910-5ef5-a87b-289a4a5e7055', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d7d11f11-7094-5b3a-840a-2bb3b3a2efbb', v_lesson, 'Рахунок за електрику', 'Račun za struju', 1241, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('16590664-dc33-5268-8823-d39c844a84a1', 'd7d11f11-7094-5b3a-840a-2bb3b3a2efbb', 'Oksana', 'Gospodine Horvat, imam račun za struju. Tko ga plaća?', 'Пане Горват, у мене рахунок за електрику. Хто його оплачує?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('47f10afc-214a-5b39-9e19-0dfc48a5bc85', 'd7d11f11-7094-5b3a-840a-2bb3b3a2efbb', 'Stanodavac', 'Vi plaćate struju i plin, a ja vodu.', 'Ви платите за електрику й газ, а я — за воду.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ebabde22-e5db-5892-b02a-35c65d839680', 'd7d11f11-7094-5b3a-840a-2bb3b3a2efbb', 'Oksana', 'Kako mogu platiti uplatnicu?', 'Як я можу оплатити квитанцію?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('969b74e8-325b-5ca0-8e78-642e8d52cb26', 'd7d11f11-7094-5b3a-840a-2bb3b3a2efbb', 'Stanodavac', 'U banci, na pošti ili mobilnim bankarstvom.', 'У банку, на пошті або через мобільний банкінг.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2fc3ef96-c073-5d8f-bc5b-8250648ab310', 'd7d11f11-7094-5b3a-840a-2bb3b3a2efbb', 'Oksana', 'Koji je rok?', 'Який термін?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('63805cf2-2efb-5604-9dc6-555561ceb481', 'd7d11f11-7094-5b3a-840a-2bb3b3a2efbb', 'Stanodavac', 'Do petnaestog u mjesecu.', 'До п’ятнадцятого числа.', 6) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('770a1204-d504-51d5-b6f7-ff6d234aee5b', v_lesson, 'Інтернет не працює', 'Internet ne radi', 1242, 'A1', 'housing', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5757e7af-9031-51eb-8796-8624abd326c6', '770a1204-d504-51d5-b6f7-ff6d234aee5b', 'Taras', 'Dobar dan, naš internet ne radi od jutra.', 'Добрий день, наш інтернет не працює з ранку.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4f618ef0-50c6-570f-82b8-83a7664f1b2b', '770a1204-d504-51d5-b6f7-ff6d234aee5b', 'Operaterka', 'Je li ruter uključen?', 'Роутер увімкнений?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ebc17163-086a-5735-bf10-28bfe262af74', '770a1204-d504-51d5-b6f7-ff6d234aee5b', 'Taras', 'Jest, ali lampica je crvena. I lozinka ne radi.', 'Так, але лампочка червона. І пароль не підходить.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b8725c06-1006-51e4-be8a-cbde0eb78ad3', '770a1204-d504-51d5-b6f7-ff6d234aee5b', 'Operaterka', 'Sutra šaljemo tehničara. Vaš broj korisnika, molim?', 'Завтра надішлемо техніка. Ваш номер абонента, будь ласка?', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 25: Мій робочий день
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'd813e9c0-2331-59d8-90f1-cea7e9a61c7d';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.6: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '387f7bea-839e-56ae-bbfd-213aacbe7c26';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.6.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 25: Мій робочий день', 'Lekcija 25: Moj radni dan', '["Дізнатися робочий час і перерви", "Розповісти, що ви робите на роботі", "Поговорити з колегою"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('posao') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'posao'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ured') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ured'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kolega') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kolega'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kolegica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kolegica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('šef') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'šef'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sastanak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sastanak'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('radno vrijeme') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'radno vrijeme'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('počinjati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'počinjati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('završavati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'završavati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('plaća') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'plaća'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tvrtka') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tvrtka'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('klijent') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'klijent'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('376da6c2-bd0f-51f1-86c9-bbd5e98ec38c', 'fill_in_the_blank', 'Mi ___ u četiri.', 'završavamo', '["završavamo", "završavam", "završavaju", "završava"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '376da6c2-bd0f-51f1-86c9-bbd5e98ec38c', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('ured') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2d4a76ae-caba-5132-a758-4fc6986eac57', 'multiple_choice', 'Що означає «ured»?', 'офіс / кабінет', '["заробітна плата", "закінчувати", "офіс / кабінет", "робочий час"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2d4a76ae-caba-5132-a758-4fc6986eac57', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('klijent') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0bf2334b-e3ba-5b0b-943f-2af2a2e9c920', 'multiple_choice', 'Що означає «klijent»?', 'клієнт', '["колега (жінка)", "клієнт", "робочий час", "офіс / кабінет"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0bf2334b-e3ba-5b0b-943f-2af2a2e9c920', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('počinjati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b2f8c55b-73bb-5513-a2e0-3f097cb30ba2', 'multiple_choice', 'Як хорватською «починати»?', 'počinjati', '["šef", "ured", "plaća", "počinjati"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b2f8c55b-73bb-5513-a2e0-3f097cb30ba2', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('završavati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('df9ede8c-7a79-5f68-9391-cd3ddf6bd676', 'type_answer', 'Напишіть хорватською: «закінчувати»', 'završavati', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'df9ede8c-7a79-5f68-9391-cd3ddf6bd676', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('šef') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0ecc5eb9-68c5-57c8-9aa2-8ed25a6535da', 'type_answer', 'Напишіть хорватською: «начальник / шеф»', 'šef', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0ecc5eb9-68c5-57c8-9aa2-8ed25a6535da', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c630afa6-f631-578e-b53f-c92d52bb81c9', 'sentence_builder', 'Складіть: «Коли починається робочий день?»', 'Kada počinje radno vrijeme?', '["počinje", "radno", "Kada", "vrijeme?"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c630afa6-f631-578e-b53f-c92d52bb81c9', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0281f85a-3edc-5098-be7f-508fc231210a', 'sentence_builder', 'Складіть: «Я працюю з клієнтами.»', 'Radim s klijentima.', '["s", "Radim", "klijentima."]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0281f85a-3edc-5098-be7f-508fc231210a', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fdf7e45c-d4f6-5a71-8b16-b3197d88a41b', 'listening', 'Прослухайте і складіть фразу', 'U osam. Završavamo u četiri.', '["četiri.", "Završavamo", "osam.", "u", "U"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fdf7e45c-d4f6-5a71-8b16-b3197d88a41b', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3c0171dd-93be-54ab-8dbf-87638491ec17', 'listening', 'Прослухайте і складіть фразу', 'Imamo danas sastanak u deset.', '["deset.", "u", "Imamo", "sastanak", "danas"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3c0171dd-93be-54ab-8dbf-87638491ec17', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c9e3a51e-6ffe-5b1a-b517-3975926a468b', 'speaking', 'Я працюю в офісі.', 'Radim u uredu.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c9e3a51e-6ffe-5b1a-b517-3975926a468b', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('141e3b85-7224-5665-8472-1b03ee1b37ce', 'speaking', 'Нарада о десятій.', 'Sastanak je u deset.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '141e3b85-7224-5665-8472-1b03ee1b37ce', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2b7fa201-2f79-57f7-8d13-862e4afa2659', v_lesson, 'Перший день', 'Prvi dan', 1251, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0c7cac22-26d4-546c-8936-040577cd86d0', '2b7fa201-2f79-57f7-8d13-862e4afa2659', 'Šefica', 'Dobrodošli! Ovo je Vaš stol.', 'Ласкаво просимо! Це ваш стіл.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ef553f96-756a-58d2-8b83-8cf38f32934c', '2b7fa201-2f79-57f7-8d13-862e4afa2659', 'Oleg', 'Hvala. Kada počinje radno vrijeme?', 'Дякую. Коли починається робочий день?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c5ec4e9c-2da5-579a-bcd3-49a25c6fb691', '2b7fa201-2f79-57f7-8d13-862e4afa2659', 'Šefica', 'U osam. Završavamo u četiri.', 'О восьмій. Закінчуємо о четвертій.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8309795c-9217-5558-b5ee-cc79a2745863', '2b7fa201-2f79-57f7-8d13-862e4afa2659', 'Oleg', 'A pauza za ručak?', 'А обідня перерва?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('58bd5e4a-8594-54ca-a9bc-849451230880', '2b7fa201-2f79-57f7-8d13-862e4afa2659', 'Šefica', 'U podne, pola sata.', 'Опівдні, пів години.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9a28aaba-c0d9-5446-af55-b43ba17dadb2', v_lesson, 'Кава з колегою', 'Kava s kolegicom', 1252, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8927c548-5859-5e60-a60f-0fdcc4d17e01', '9a28aaba-c0d9-5446-af55-b43ba17dadb2', 'Kolegica', 'Gdje radiš, u kojem odjelu?', 'Де ти працюєш, у якому відділі?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b7007915-77f2-5be8-a190-e0123f812f06', '9a28aaba-c0d9-5446-af55-b43ba17dadb2', 'Oleg', 'U prodaji. Radim s klijentima.', 'У відділі продажів. Працюю з клієнтами.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5e4fcbe0-aa7b-5294-8cca-9afe8ae0ff5b', '9a28aaba-c0d9-5446-af55-b43ba17dadb2', 'Kolegica', 'Sviđa li ti se?', 'Тобі подобається?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('916a5da6-7084-5a4f-a923-da2d88f44a5b', '9a28aaba-c0d9-5446-af55-b43ba17dadb2', 'Oleg', 'Da, kolege su jako dragi.', 'Так, колеги дуже приємні.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('128bddde-57c5-5ce2-9a07-577c8545fc04', '9a28aaba-c0d9-5446-af55-b43ba17dadb2', 'Kolegica', 'Imamo danas sastanak u deset.', 'Сьогодні в нас нарада о десятій.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 26: Правила на роботі
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '99088d92-0f0c-52c2-b51f-548d903fc9ef';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.6: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.6.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 26: Правила на роботі', 'Lekcija 26: Pravila na poslu', '["Запитати, що можна, а що ні", "Повідомити, що ви захворіли", "Вживати smijem, moram, mogu"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('smjeti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'smjeti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('morati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'morati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pušiti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pušiti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('bolovanje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'bolovanje'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('potvrda') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'potvrda'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('liječnik') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'liječnik'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('slobodan dan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'slobodan dan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('godišnji odmor') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'godišnji odmor'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pitati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pitati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kasniti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kasniti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('šef') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'šef'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2a95e246-90ea-55c7-bad1-f091edaa8c01', 'fill_in_the_blank', 'Vi ovdje ne ___ pušiti.', 'smijete', '["smijete", "smijem", "smiju", "smije"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2a95e246-90ea-55c7-bad1-f091edaa8c01', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('pitati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a7be2822-f35d-5f4d-9786-4c1b58c590a0', 'multiple_choice', 'Що означає «pitati»?', 'питати', '["вихідний день", "питати", "начальник / шеф", "довідка / підтвердження"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a7be2822-f35d-5f4d-9786-4c1b58c590a0', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pušiti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c356ad55-2057-5213-90ac-0541f15859f2', 'multiple_choice', 'Що означає «pušiti»?', 'курити', '["курити", "мусити / бути зобов''язаним", "вихідний день", "сміти, мати дозвіл"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c356ad55-2057-5213-90ac-0541f15859f2', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('morati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('66276c5f-dd5c-5c3d-86e0-03a47508884f', 'multiple_choice', 'Як хорватською «мусити / бути зобов''язаним»?', 'morati', '["šef", "godišnji odmor", "potvrda", "morati"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '66276c5f-dd5c-5c3d-86e0-03a47508884f', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('šef') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('59fea773-0bef-5291-9768-5e29f8997046', 'type_answer', 'Напишіть хорватською: «начальник / шеф»', 'šef', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '59fea773-0bef-5291-9768-5e29f8997046', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('bolovanje') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d7ac6d65-acb0-575b-967d-1dee47d502bd', 'type_answer', 'Напишіть хорватською: «лікарняний»', 'bolovanje', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd7ac6d65-acb0-575b-967d-1dee47d502bd', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a00038d0-ab2f-5214-a942-bd5bbc7bf5de', 'sentence_builder', 'Складіть: «Тут можна курити?»', 'Smijem li ovdje pušiti?', '["li", "ovdje", "Smijem", "pušiti?"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a00038d0-ab2f-5214-a942-bd5bbc7bf5de', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('46044d85-b534-570e-99f2-e242282c130f', 'sentence_builder', 'Складіть: «Мені треба принести довідку?»', 'Trebam li donijeti potvrdu?', '["donijeti", "Trebam", "potvrdu?", "li"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '46044d85-b534-570e-99f2-e242282c130f', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d0da34f3-6ff5-5316-97d6-3dbd704bb2e6', 'listening', 'Прослухайте і складіть фразу', 'Ne smiješ. Moraš izaći van.', '["izaći", "Moraš", "van.", "smiješ.", "Ne"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd0da34f3-6ff5-5316-97d6-3dbd704bb2e6', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('317d7242-e8a1-547f-a674-4559d6b34372', 'listening', 'Прослухайте і складіть фразу', 'Žao mi je. Morate ići liječniku.', '["mi", "Žao", "ići", "Morate", "je.", "liječniku."]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '317d7242-e8a1-547f-a674-4559d6b34372', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('09255bad-dbd4-5d34-b393-ed496c1e1e30', 'speaking', 'Мені треба йти до лікаря.', 'Moram ići liječniku.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '09255bad-dbd4-5d34-b393-ed496c1e1e30', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1013b77d-2cde-5442-ae6e-5bd1116d362f', 'speaking', 'Можна працювати з дому?', 'Smijem li raditi od kuće?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1013b77d-2cde-5442-ae6e-5bd1116d362f', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2ac7ca24-cf19-5fc8-8b74-0aec42f4e427', v_lesson, 'Що можна, а що ні', 'Što smijem, a što ne', 1261, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7733eecd-1d88-5844-9242-e8a927b5129b', '2ac7ca24-cf19-5fc8-8b74-0aec42f4e427', 'Oleg', 'Smijem li ovdje pušiti?', 'Тут можна курити?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5e086a43-d714-527b-bae2-b58ab3b3c17f', '2ac7ca24-cf19-5fc8-8b74-0aec42f4e427', 'Kolega', 'Ne smiješ. Moraš izaći van.', 'Не можна. Треба вийти надвір.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('99297345-0060-54bb-b285-da19af4e03c3', '2ac7ca24-cf19-5fc8-8b74-0aec42f4e427', 'Oleg', 'A smijem li raditi od kuće?', 'А можна працювати з дому?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1355be24-cca3-58f4-a542-a76ec9798dc1', '2ac7ca24-cf19-5fc8-8b74-0aec42f4e427', 'Kolega', 'Petkom smiješ, ali moraš pitati šefa.', 'По п’ятницях можна, але треба спитати шефа.', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e17a0f51-adeb-53d9-801e-6da66b9cb36e', v_lesson, 'Лікарняний', 'Bolovanje', 1262, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f587ccce-8fdf-5360-96e9-5a380d31d39d', 'e17a0f51-adeb-53d9-801e-6da66b9cb36e', 'Oksana', 'Dobro jutro. Bolesna sam i danas ne mogu doći.', 'Доброго ранку. Я захворіла й сьогодні не можу прийти.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('64af9052-7aba-5d09-85b3-f7dd231d807a', 'e17a0f51-adeb-53d9-801e-6da66b9cb36e', 'Šef', 'Žao mi je. Morate ići liječniku.', 'Мені шкода. Вам треба піти до лікаря.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f4303b48-64d1-5253-b2ac-b609800124a6', 'e17a0f51-adeb-53d9-801e-6da66b9cb36e', 'Oksana', 'Znam. Trebam li donijeti potvrdu?', 'Знаю. Мені треба принести довідку?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b1d19147-7de6-5901-b517-73eaf3665504', 'e17a0f51-adeb-53d9-801e-6da66b9cb36e', 'Šef', 'Da, za bolovanje. Ozdravite brzo!', 'Так, для лікарняного. Одужуйте швидше!', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 27: Співбесіда
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '92858dbe-ede1-5bc5-b80a-c796c5598019';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.6: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.6.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 27: Співбесіда', 'Lekcija 27: Razgovor za posao', '["Розповісти про свій досвід", "Запитати про зарплату й договір", "Відповідати на питання kakav, koliko, kada"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('razgovor') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'razgovor'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('iskustvo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'iskustvo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zanimanje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zanimanje'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('plaća') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'plaća'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ugovor') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ugovor'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zaposliti se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zaposliti se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jezik') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jezik'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('znati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'znati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('govoriti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'govoriti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('početi') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'početi'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vozačka dozvola') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vozačka dozvola'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vozač') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vozač'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c948e1d1-4d3f-587a-bd50-30a748d3fe95', 'fill_in_the_blank', '___ dugo živite ovdje?', 'Koliko', '["Koliko", "Gdje", "Kada", "Tko"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c948e1d1-4d3f-587a-bd50-30a748d3fe95', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('vozačka dozvola') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('788bd2d8-e0cd-5b5c-aef0-2f1207b190db', 'multiple_choice', 'Що означає «vozačka dozvola»?', 'водійське посвідчення', '["водійське посвідчення", "почати", "досвід", "розмова / бесіда"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '788bd2d8-e0cd-5b5c-aef0-2f1207b190db', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('plaća') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e8e3ec0d-c739-5eec-af6b-579fad2ebd38', 'multiple_choice', 'Що означає «plaća»?', 'заробітна плата', '["говорити", "знати", "досвід", "заробітна плата"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e8e3ec0d-c739-5eec-af6b-579fad2ebd38', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('razgovor') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('049e768d-2dd6-5998-9240-a88bd0fc640f', 'multiple_choice', 'Як хорватською «розмова / бесіда»?', 'razgovor', '["govoriti", "ugovor", "razgovor", "vozač"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '049e768d-2dd6-5998-9240-a88bd0fc640f', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vozač') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('df67affc-9566-567a-9ad3-20a19a745ded', 'type_answer', 'Напишіть хорватською: «водій»', 'vozač', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'df67affc-9566-567a-9ad3-20a19a745ded', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('govoriti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('da33aaba-6d62-5aab-86d7-377a37055e02', 'type_answer', 'Напишіть хорватською: «говорити»', 'govoriti', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'da33aaba-6d62-5aab-86d7-377a37055e02', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c7d9a4b8-3bf1-52a7-a143-e6ef562d0234', 'sentence_builder', 'Складіть: «Я живу тут два роки.»', 'Živim ovdje dvije godine.', '["ovdje", "dvije", "Živim", "godine."]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c7d9a4b8-3bf1-52a7-a143-e6ef562d0234', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('cbd34969-1eb6-5c26-80f6-a218c847a6b5', 'sentence_builder', 'Складіть: «Коли я можу почати?»', 'Kada mogu početi?', '["Kada", "početi?", "mogu"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'cbd34969-1eb6-5c26-80f6-a218c847a6b5', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4ce7e331-4f8c-5e56-b769-1412144e84a7', 'listening', 'Прослухайте і складіть фразу', 'Kakvo iskustvo imate?', '["imate?", "iskustvo", "Kakvo"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4ce7e331-4f8c-5e56-b769-1412144e84a7', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('740ada9b-dd32-5a71-9d4a-15889adfb066', 'listening', 'Прослухайте і складіть фразу', 'Kolika je plaća?', '["je", "Kolika", "plaća?"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '740ada9b-dd32-5a71-9d4a-15889adfb066', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fc8cb2be-9b18-57f1-979b-e5ce5c1b9e57', 'speaking', 'Який у вас досвід?', 'Kakvo iskustvo imate?', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fc8cb2be-9b18-57f1-979b-e5ce5c1b9e57', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7fad616e-f591-58f8-b20e-8d366f075df0', 'speaking', 'Я говорю українською й англійською.', 'Govorim ukrajinski i engleski.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7fad616e-f591-58f8-b20e-8d366f075df0', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2ce70360-9c38-58f4-b7b0-f810fa7949af', v_lesson, 'Досвід', 'Iskustvo', 1271, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5ac6a959-2efd-516c-bbbe-3879f02fc2d8', '2ce70360-9c38-58f4-b7b0-f810fa7949af', 'Direktor', 'Odakle ste i koliko dugo živite u Hrvatskoj?', 'Звідки ви і як довго живете в Хорватії?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5fb860ac-0f11-5db9-a51c-3a031c42726b', '2ce70360-9c38-58f4-b7b0-f810fa7949af', 'Taras', 'Iz Ukrajine. Živim ovdje dvije godine.', 'З України. Живу тут два роки.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1777aff4-8846-52e4-94a3-de3d2d315286', '2ce70360-9c38-58f4-b7b0-f810fa7949af', 'Direktor', 'Kakvo iskustvo imate?', 'Який у вас досвід?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0b618667-1501-51e4-a39e-3abf413de548', '2ce70360-9c38-58f4-b7b0-f810fa7949af', 'Taras', 'Radim kao vozač već pet godina.', 'Я працюю водієм уже п’ять років.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('10f40966-5c02-5025-9868-8930748d635e', '2ce70360-9c38-58f4-b7b0-f810fa7949af', 'Direktor', 'Imate li vozačku dozvolu za kamion?', 'У вас є посвідчення на вантажівку?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ebbb1851-8eba-5d33-8126-21bb037f814c', '2ce70360-9c38-58f4-b7b0-f810fa7949af', 'Taras', 'Imam, kategoriju C.', 'Так, категорії C.', 6) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('721e1ea0-da62-526e-bb59-49509e2564f0', v_lesson, 'Умови', 'Uvjeti', 1272, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c0a0be9e-c729-506a-a264-b843a0ce0685', '721e1ea0-da62-526e-bb59-49509e2564f0', 'Taras', 'Kada mogu početi?', 'Коли я можу почати?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('81764251-5bd7-5ef3-84d6-101f259b7c74', '721e1ea0-da62-526e-bb59-49509e2564f0', 'Direktor', 'Od prvog. Ugovor je na godinu dana.', 'З першого числа. Договір на рік.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ca1383dc-d373-5e27-9fa3-ef939f545eda', '721e1ea0-da62-526e-bb59-49509e2564f0', 'Taras', 'Kolika je plaća?', 'Яка зарплата?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('43adaabc-2976-58f8-880a-fe879c5ceb7f', '721e1ea0-da62-526e-bb59-49509e2564f0', 'Direktor', 'Tisuću dvjesto eura neto.', 'Тисяча двісті євро чистими.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('efa19384-5189-5bf6-9a08-7c9cd22dc09d', '721e1ea0-da62-526e-bb59-49509e2564f0', 'Taras', 'To mi odgovara. Hvala!', 'Мене це влаштовує. Дякую!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 28: Договір і зарплата
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '4d6f3498-2cc5-54a0-b4e4-c66add71ef12';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.6: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.6.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 28: Договір і зарплата', 'Lekcija 28: Ugovor i plaća', '["Зрозуміти умови договору", "Запитати про зарплату й зміни", "Вживати trebam, moram, mogu"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('probni rad') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'probni rad'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('puno radno vrijeme') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'puno radno vrijeme'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('smjena') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'smjena'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('radna dozvola') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'radna dozvola'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('privremena zaštita') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'privremena zaštita'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('bruto') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'bruto'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('neto') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'neto'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('porez') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'porez'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('isplata') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'isplata'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prekovremeni sati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prekovremeni sati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('platna lista') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'platna lista'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('posebno') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'posebno'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('acc696ac-9bd6-501a-978c-8875209c4c38', 'fill_in_the_blank', 'Trebate li radnu dozvolu? — Ne, ne ___.', 'trebam', '["treba", "trebaš", "trebaju", "trebam"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'acc696ac-9bd6-501a-978c-8875209c4c38', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('prekovremeni sati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('92584266-9889-5028-aa5e-52b0ed17256c', 'multiple_choice', 'Що означає «prekovremeni sati»?', 'понаднормові години', '["понаднормові години", "окремо; особливо", "повний робочий день", "тимчасовий захист"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '92584266-9889-5028-aa5e-52b0ed17256c', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('probni rad') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4eba8cd3-b2a6-551a-b81f-aeed7b2b2be9', 'multiple_choice', 'Що означає «probni rad»?', 'випробувальний термін', '["виплата / зняття", "випробувальний термін", "зміна (на роботі)", "повний робочий день"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4eba8cd3-b2a6-551a-b81f-aeed7b2b2be9', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('platna lista') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4ee23ec0-9cbd-5e76-b0bc-d72cfeb849c4', 'multiple_choice', 'Як хорватською «розрахунковий листок»?', 'platna lista', '["privremena zaštita", "platna lista", "radna dozvola", "posebno"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4ee23ec0-9cbd-5e76-b0bc-d72cfeb849c4', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('porez') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('86acebb5-2784-5b7e-8ff3-3904ea86695d', 'type_answer', 'Напишіть хорватською: «податок»', 'porez', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '86acebb5-2784-5b7e-8ff3-3904ea86695d', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('smjena') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2adf115f-3e97-50ac-abd0-6787cf81a312', 'type_answer', 'Напишіть хорватською: «зміна (на роботі)»', 'smjena', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2adf115f-3e97-50ac-abd0-6787cf81a312', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('31366ef3-906a-5695-93ac-53d23ecbcd81', 'sentence_builder', 'Складіть: «Це повний робочий день?»', 'Je li puno radno vrijeme?', '["Je", "vrijeme?", "radno", "puno", "li"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '31366ef3-906a-5695-93ac-53d23ecbcd81', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9b575fa2-b08b-51c3-80b3-a0209b648b2b', 'sentence_builder', 'Складіть: «Зарплата брутто чи нетто?»', 'Je li plaća bruto ili neto?', '["li", "bruto", "Je", "ili", "neto?", "plaća"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9b575fa2-b08b-51c3-80b3-a0209b648b2b', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0727828f-549b-58b0-bc42-6eb903a99b02', 'listening', 'Прослухайте і складіть фразу', 'Da, osam sati dnevno. Radimo u dvije smjene.', '["dvije", "smjene.", "sati", "Radimo", "u", "dnevno.", "osam", "Da,"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0727828f-549b-58b0-bc42-6eb903a99b02', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d8c5e036-13ff-594f-93d7-98b689d73ea2', 'listening', 'Прослухайте і складіть фразу', 'A prekovremeni sati?', '["A", "sati?", "prekovremeni"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd8c5e036-13ff-594f-93d7-98b689d73ea2', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2f285757-1361-5f73-8568-dac27b4f5ed7', 'speaking', 'Мені потрібен дозвіл на роботу?', 'Trebam li radnu dozvolu?', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2f285757-1361-5f73-8568-dac27b4f5ed7', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c319f5a3-6544-51fa-9e82-8fdfc9adac8c', 'speaking', 'Коли виплата?', 'Kada je isplata?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c319f5a3-6544-51fa-9e82-8fdfc9adac8c', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('982110e5-9fda-5d21-9c81-54b064cf657e', v_lesson, 'Договір', 'Ugovor o radu', 1281, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f290648f-db0f-5951-abb1-1882c5cc77d9', '982110e5-9fda-5d21-9c81-54b064cf657e', 'Šefica', 'Ovo je Vaš ugovor. Prvo je probni rad, tri mjeseca.', 'Це ваш договір. Спочатку випробувальний термін, три місяці.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ac645499-b639-5a9f-94fe-418a1e5bfd36', '982110e5-9fda-5d21-9c81-54b064cf657e', 'Oleg', 'Je li puno radno vrijeme?', 'Це повний робочий день?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ef322b2a-b3d9-5135-80c3-0187f6030401', '982110e5-9fda-5d21-9c81-54b064cf657e', 'Šefica', 'Da, osam sati dnevno. Radimo u dvije smjene.', 'Так, вісім годин на день. Працюємо у дві зміни.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('51eda58c-5ca3-51e4-a41b-6ec013b7a408', '982110e5-9fda-5d21-9c81-54b064cf657e', 'Oleg', 'Trebam li radnu dozvolu?', 'Мені потрібен дозвіл на роботу?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9919c1ed-7642-5bbb-9afd-51c6c0a5555d', '982110e5-9fda-5d21-9c81-54b064cf657e', 'Šefica', 'Ne trebate, imate privremenu zaštitu.', 'Не потрібен, у вас тимчасовий захист.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('88ae3d58-6389-5fdd-a95e-fe4efdde5c51', v_lesson, 'Зарплата', 'Plaća', 1282, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('32afd68b-26d5-5e03-b8b7-2062dc14c022', '88ae3d58-6389-5fdd-a95e-fe4efdde5c51', 'Oleg', 'Je li plaća bruto ili neto?', 'Зарплата брутто чи нетто?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8aa50f94-97d6-526c-8c56-f22015c4cb87', '88ae3d58-6389-5fdd-a95e-fe4efdde5c51', 'Računovotkinja', 'Neto, poslije poreza. Isplata je do desetog u mjesecu.', 'Нетто, після податків. Виплата — до десятого числа.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6b54580b-6264-577d-b6c8-8f0b1cbff206', '88ae3d58-6389-5fdd-a95e-fe4efdde5c51', 'Oleg', 'A prekovremeni sati?', 'А понаднормові години?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('dadcb5f4-fb30-567e-a69f-3d25c8bc0318', '88ae3d58-6389-5fdd-a95e-fe4efdde5c51', 'Računovotkinja', 'Plaćaju se posebno. Sve piše na platnoj listi.', 'Оплачуються окремо. Усе написано в розрахунковому листку.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.6 · урок 29: Дзвінок на роботу
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'e806dd39-4d38-5781-ad2d-949961dd95f9';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.6: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.6.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 29: Дзвінок на роботу', 'Lekcija 29: Telefonski poziv', '["Попросити до телефону потрібну людину", "Попередити колегу, що не прийдете", "Вживати mogu, hoću, ne mogu"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('nazvati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'nazvati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zauzet') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zauzet'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kasnije') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kasnije'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('poruka') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'poruka'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ostaviti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ostaviti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tajnica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tajnica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('javiti se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'javiti se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('videopoziv') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'videopoziv'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('link') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'link'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('mail') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'mail'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('bolestan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'bolestan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a39a01dc-d767-59d3-b582-7a2495c9b79b', 'fill_in_the_blank', 'Oni ___ razgovarati s Vama.', 'hoće', '["hoću", "hoćemo", "hoće", "hoćeš"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a39a01dc-d767-59d3-b582-7a2495c9b79b', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('javiti se') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ef5ff88d-493e-5d52-8865-16aff18a5707', 'multiple_choice', 'Що означає «javiti se»?', 'обізватися; відповісти (на дзвінок); зголоситися', '["електронний лист; імейл", "подзвонити / назвати", "обізватися; відповісти (на дзвінок); зголоситися", "відеодзвінок"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ef5ff88d-493e-5d52-8865-16aff18a5707', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('videopoziv') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('bb6e6548-088c-59c6-906f-863c28a2df2d', 'multiple_choice', 'Що означає «videopoziv»?', 'відеодзвінок', '["повідомлення", "залишити", "відеодзвінок", "пізніше"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'bb6e6548-088c-59c6-906f-863c28a2df2d', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('bolestan') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a5f94b16-bde3-5c7b-a1a5-2c8bc28ca42c', 'multiple_choice', 'Як хорватською «хворий»?', 'bolestan', '["link", "videopoziv", "bolestan", "javiti se"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a5f94b16-bde3-5c7b-a1a5-2c8bc28ca42c', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ostaviti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7253a1a2-2572-5ae9-b615-8e69d91fa53f', 'type_answer', 'Напишіть хорватською: «залишити»', 'ostaviti', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7253a1a2-2572-5ae9-b615-8e69d91fa53f', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('poruka') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8dbf3c6f-22a0-54e2-b5ff-f44d4d8456c1', 'type_answer', 'Напишіть хорватською: «повідомлення»', 'poruka', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8dbf3c6f-22a0-54e2-b5ff-f44d4d8456c1', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('bcdba6ef-02f0-5984-b99d-90fc63f0e78a', 'sentence_builder', 'Складіть: «Можете подзвонити пізніше?»', 'Možete li nazvati kasnije?', '["kasnije?", "nazvati", "Možete", "li"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'bcdba6ef-02f0-5984-b99d-90fc63f0e78a', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4c6c158e-1495-56ea-a513-971c51184b68', 'sentence_builder', 'Складіть: «Я не можу прийти на нараду.»', 'Ne mogu doći na sastanak.', '["mogu", "doći", "Ne", "sastanak.", "na"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4c6c158e-1495-56ea-a513-971c51184b68', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6306e5a6-9263-56e8-a172-e63c689ca021', 'listening', 'Прослухайте і складіть фразу', 'Nažalost, sada je zauzet.', '["zauzet.", "Nažalost,", "je", "sada"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6306e5a6-9263-56e8-a172-e63c689ca021', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2c02b773-7d8e-5207-b273-f32dc1c81dcc', 'listening', 'Прослухайте і складіть фразу', 'Mogu, pošalji mi link.', '["pošalji", "link.", "Mogu,", "mi"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2c02b773-7d8e-5207-b273-f32dc1c81dcc', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5775ef09-8773-5ded-9d2e-bb6f2b968470', 'speaking', 'Можу я поговорити з паном Бабичем?', 'Mogu li razgovarati s gospodinom Babićem?', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5775ef09-8773-5ded-9d2e-bb6f2b968470', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8f480e6a-00a9-5315-bdb0-76011dec2d41', 'speaking', 'Подзвоніть мені, будь ласка.', 'Nazovite me, molim.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8f480e6a-00a9-5315-bdb0-76011dec2d41', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('92864bdd-493f-5304-9b90-c78683c3bd65', v_lesson, 'Дзвінок в офіс', 'Poziv u ured', 1291, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2b9fad62-02c2-500f-941b-49e1cc1eb082', '92864bdd-493f-5304-9b90-c78683c3bd65', 'Tajnica', 'Tvrtka Adria, dobar dan.', 'Компанія «Адрія», добрий день.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6780343a-1f8c-5d56-a84c-83768045ed65', '92864bdd-493f-5304-9b90-c78683c3bd65', 'Oleg', 'Dobar dan, ovdje Oleg Kovalenko. Mogu li razgovarati s gospodinom Babićem?', 'Добрий день, це Олег Коваленко. Можу я поговорити з паном Бабичем?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b713c223-59be-5dac-bb22-a5718c737a0a', '92864bdd-493f-5304-9b90-c78683c3bd65', 'Tajnica', 'Nažalost, sada je zauzet. Možete li nazvati kasnije?', 'На жаль, зараз він зайнятий. Можете подзвонити пізніше?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d405dcc9-889b-5ee2-bdcc-104c44b7392e', '92864bdd-493f-5304-9b90-c78683c3bd65', 'Oleg', 'Mogu. Ili mu ostavite poruku da me nazove.', 'Можу. Або передайте йому, щоб він мені передзвонив.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c4816709-85b3-51b8-b7d3-d4276c66014d', '92864bdd-493f-5304-9b90-c78683c3bd65', 'Tajnica', 'Naravno. Koji je Vaš broj?', 'Звісно. Який ваш номер?', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('058d9554-1cca-5329-baba-46b470cad59c', v_lesson, 'Повідомлення колезі', 'Poruka kolegi', 1292, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1eed44e6-7c3c-5eb8-a2a9-2182c68c5e25', '058d9554-1cca-5329-baba-46b470cad59c', 'Iryna', 'Bok Marko, ne mogu doći na sastanak. Bolesna sam.', 'Привіт, Марку, я не можу прийти на нараду. Я захворіла.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5afd2919-d517-5894-918a-5f6e0de864f9', '058d9554-1cca-5329-baba-46b470cad59c', 'Marko', 'Nema problema. Možeš li se uključiti na videopoziv?', 'Без проблем. Можеш підключитися відеодзвінком?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2cec44f7-ab7b-557e-87fb-85b0f3da81b1', '058d9554-1cca-5329-baba-46b470cad59c', 'Iryna', 'Mogu, pošalji mi link.', 'Можу, надішли мені посилання.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('52d945db-8c3c-555c-ad46-f173cbf816e6', '058d9554-1cca-5329-baba-46b470cad59c', 'Marko', 'Šaljem ti mail. Javi se ako nešto trebaš.', 'Надсилаю тобі мейл. Озвися, якщо щось треба.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 30: Запис до лікаря
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '08e31e8b-f8f7-5a80-89ed-093bc68dae03';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.7: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.7.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 30: Запис до лікаря', 'Lekcija 30: Naručivanje kod liječnika', '["Записатися до лікаря телефоном", "Пояснити, що болить", "Вживати boli me, bole me"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('dom zdravlja') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dom zdravlja'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pregled') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pregled'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('termin') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'termin'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zdravstveno osiguranje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zdravstveno osiguranje'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('boljeti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'boljeti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('glava') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'glava'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('grlo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'grlo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('leđa') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'leđa'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('bol') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'bol'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('temperatura') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'temperatura'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kašalj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kašalj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('liječnica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'liječnica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7bdce927-ed8e-5de6-95d8-afafb4b1ce16', 'fill_in_the_blank', 'Boli ___ glava.', 'me', '["ja", "meni", "moja", "me"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7bdce927-ed8e-5de6-95d8-afafb4b1ce16', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('pregled') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7f96c842-4814-55eb-a367-86352f3b19cc', 'multiple_choice', 'Що означає «pregled»?', 'медичний огляд / обстеження', '["медичне страхування", "температура (жар)", "медичний огляд / обстеження", "біль"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7f96c842-4814-55eb-a367-86352f3b19cc', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('glava') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4fad1b78-9915-5bc8-8614-333bfd9ade5f', 'multiple_choice', 'Що означає «glava»?', 'голова', '["медичне страхування", "голова", "горло", "біль"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4fad1b78-9915-5bc8-8614-333bfd9ade5f', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('boljeti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('bb8a2807-ed77-5938-83a3-d8e604d01651', 'multiple_choice', 'Як хорватською «болити»?', 'boljeti', '["leđa", "boljeti", "zdravstveno osiguranje", "termin"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'bb8a2807-ed77-5938-83a3-d8e604d01651', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('leđa') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3ec442cd-e8e7-589e-9d5f-05df37c9c79b', 'type_answer', 'Напишіть хорватською: «спина»', 'leđa', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3ec442cd-e8e7-589e-9d5f-05df37c9c79b', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('kašalj') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2fa5b21f-18ed-5181-ad37-8a2a63571c71', 'type_answer', 'Напишіть хорватською: «кашель»', 'kašalj', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2fa5b21f-18ed-5181-ad37-8a2a63571c71', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('52a6b3e6-34ca-5a52-8bc1-a9e879089d5e', 'sentence_builder', 'Складіть: «Мені потрібен запис до лікаря.»', 'Trebam termin kod liječnika.', '["Trebam", "liječnika.", "kod", "termin"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '52a6b3e6-34ca-5a52-8bc1-a9e879089d5e', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('46613f26-9f49-5c7a-b838-081f95985805', 'sentence_builder', 'Складіть: «У мене болить горло.»', 'Boli me grlo.', '["Boli", "grlo.", "me"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '46613f26-9f49-5c7a-b838-081f95985805', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('95b1f432-d12d-5cae-afad-397f64b66b72', 'listening', 'Прослухайте і складіть фразу', 'Imate li zdravstveno osiguranje?', '["Imate", "zdravstveno", "osiguranje?", "li"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '95b1f432-d12d-5cae-afad-397f64b66b72', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e914f118-aaca-5626-bf54-a77d9e16c051', 'listening', 'Прослухайте і складіть фразу', 'Malo, trideset sedam i pet.', '["Malo,", "pet.", "sedam", "i", "trideset"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e914f118-aaca-5626-bf54-a77d9e16c051', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6c012a8a-54cc-5221-a3e5-5bc5290c7d38', 'speaking', 'У мене болить спина.', 'Bole me leđa.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6c012a8a-54cc-5221-a3e5-5bc5290c7d38', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9194e3f8-b260-579b-bc76-8aaae80979c1', 'speaking', 'У мене кашель.', 'Imam kašalj.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9194e3f8-b260-579b-bc76-8aaae80979c1', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b94f5c8b-ab08-54c3-9968-ee219046202d', v_lesson, 'Телефоном', 'Telefonom', 1301, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('66f51ca0-cf56-59a0-b89e-3f7a6038a859', 'b94f5c8b-ab08-54c3-9968-ee219046202d', 'Sestra', 'Dom zdravlja, izvolite.', 'Поліклініка, слухаю.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a9d46994-f9fc-553a-9866-b415621b9e63', 'b94f5c8b-ab08-54c3-9968-ee219046202d', 'Olena', 'Dobar dan, trebam termin kod doktorice Babić.', 'Добрий день, мені потрібен запис до лікарки Бабич.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('60c61907-d43e-54fd-8137-30d4243ea2d7', 'b94f5c8b-ab08-54c3-9968-ee219046202d', 'Sestra', 'Imate li zdravstveno osiguranje?', 'У вас є медичне страхування?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5235220c-5c67-5c03-ab00-b1d317eb854e', 'b94f5c8b-ab08-54c3-9968-ee219046202d', 'Olena', 'Imam.', 'Так.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2dc2b9a2-92b0-5659-a996-f62d24bbbd62', 'b94f5c8b-ab08-54c3-9968-ee219046202d', 'Sestra', 'Može sutra u devet i petnaest.', 'Можна завтра о дев’ятій п’ятнадцять.', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a482d338-39c3-5951-aa77-4e9efd4450df', 'b94f5c8b-ab08-54c3-9968-ee219046202d', 'Olena', 'Odlično, hvala.', 'Чудово, дякую.', 6) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('85984398-4598-5d46-a4ce-1b81b0d7d502', v_lesson, 'У кабінеті', 'U ordinaciji', 1302, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('428f122a-a95b-50d1-a5d6-d7f088579e23', '85984398-4598-5d46-a4ce-1b81b0d7d502', 'Doktorica', 'Što Vas boli?', 'Що у вас болить?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6b51a72f-adcf-5212-a249-a71a51b2f02c', '85984398-4598-5d46-a4ce-1b81b0d7d502', 'Olena', 'Boli me grlo i imam kašalj.', 'У мене болить горло і кашель.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6c761c03-9c3d-52ce-bba7-a907f167069d', '85984398-4598-5d46-a4ce-1b81b0d7d502', 'Doktorica', 'Imate li temperaturu?', 'У вас є температура?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('58e8b581-8cac-50bd-95e3-6b954f49e641', '85984398-4598-5d46-a4ce-1b81b0d7d502', 'Olena', 'Malo, trideset sedam i pet.', 'Трохи, тридцять сім і п’ять.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d68d89b0-b4ee-579f-8819-bd3060523028', '85984398-4598-5d46-a4ce-1b81b0d7d502', 'Doktorica', 'Otvorite usta, molim. Da vidim.', 'Відкрийте рот, будь ласка. Подивимося.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 31: В аптеці
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '123e68fa-291f-5ad6-8403-51db7020d641';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.7: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '45c5cb39-daf7-5dab-8413-9a5302b33553';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.7.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 31: В аптеці', 'Lekcija 31: U ljekarni', '["Купити ліки від застуди", "Зрозуміти, як приймати ліки", "Розуміти поради: uzmite, pijte"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('ljekarna') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ljekarna'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ljekarnik') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ljekarnik'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('lijek') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'lijek'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tableta') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tableta'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sirup protiv kašlja') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sirup protiv kašlja'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('recept') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'recept'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('lijek protiv bolova') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'lijek protiv bolova'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prehlada') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prehlada'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('uzimati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'uzimati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dnevno') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dnevno'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('voda') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'voda'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d08e89db-d7b1-518e-acb9-b4b0720bc4f7', 'fill_in_the_blank', '___ jednu tabletu dnevno.', 'Uzmite', '["Uzeti", "Uzmem", "Uzme", "Uzmite"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd08e89db-d7b1-518e-acb9-b4b0720bc4f7', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('sirup protiv kašlja') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3a2a7722-367b-5670-a9cd-de420e2c933a', 'multiple_choice', 'Що означає «sirup protiv kašlja»?', 'сироп від кашлю', '["сироп від кашлю", "аптека", "ліки / медикамент", "застуда"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3a2a7722-367b-5670-a9cd-de420e2c933a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('lijek protiv bolova') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c1f67a24-f169-55db-b8d7-f482aaa28de1', 'multiple_choice', 'Що означає «lijek protiv bolova»?', 'знеболювальне', '["знеболювальне", "щодня; на день", "аптека", "вода"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c1f67a24-f169-55db-b8d7-f482aaa28de1', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('recept') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a29bb569-743f-5894-89d2-e2b3d57aa777', 'multiple_choice', 'Як хорватською «рецепт»?', 'recept', '["ljekarnik", "ljekarna", "recept", "tableta"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a29bb569-743f-5894-89d2-e2b3d57aa777', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tableta') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('deb408de-142a-564e-8b1c-164ce0b90c08', 'type_answer', 'Напишіть хорватською: «таблетка»', 'tableta', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'deb408de-142a-564e-8b1c-164ce0b90c08', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('prehlada') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4047ce55-80e7-5dd9-9d4d-bfba6afce5eb', 'type_answer', 'Напишіть хорватською: «застуда»', 'prehlada', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4047ce55-80e7-5dd9-9d4d-bfba6afce5eb', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('13b92aed-7e0f-515b-b1a3-dbee0922c936', 'sentence_builder', 'Складіть: «У вас є щось від застуди?»', 'Imate li nešto za prehladu?', '["Imate", "nešto", "prehladu?", "li", "za"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '13b92aed-7e0f-515b-b1a3-dbee0922c936', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e38ee11c-162e-54e0-a6b2-b86296ff4989', 'sentence_builder', 'Складіть: «До чи після їжі?»', 'Prije ili poslije jela?', '["Prije", "poslije", "ili", "jela?"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e38ee11c-162e-54e0-a6b2-b86296ff4989', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ba5b6513-c968-53ab-a2af-c24d41ff8f62', 'listening', 'Прослухайте і складіть фразу', 'Ne, ne trebate.', '["trebate.", "Ne,", "ne"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ba5b6513-c968-53ab-a2af-c24d41ff8f62', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('62f93f91-2c2c-531a-94ea-273616ae620f', 'listening', 'Прослухайте і складіть фразу', 'Poslije jela. I pijte puno vode.', '["Poslije", "jela.", "puno", "pijte", "vode.", "I"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '62f93f91-2c2c-531a-94ea-273616ae620f', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('13936d8f-5100-5b91-8b52-587df2eddfbd', 'speaking', 'Мені потрібні ліки від болю.', 'Trebam lijek protiv bolova.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '13936d8f-5100-5b91-8b52-587df2eddfbd', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3a76dbc7-d75c-532f-a62c-67b228a138c5', 'speaking', 'Пийте багато води.', 'Pijte puno vode.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3a76dbc7-d75c-532f-a62c-67b228a138c5', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1d36e4c1-d72d-5d78-b5f7-bd00d5ce36c2', v_lesson, 'Ліки від застуди', 'Lijek za prehladu', 1311, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('04c1efcc-926c-584f-93bc-eae32e57c6fd', '1d36e4c1-d72d-5d78-b5f7-bd00d5ce36c2', 'Ljekarnica', 'Izvolite?', 'Слухаю вас?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('dd0588b1-5ec5-50c0-823f-556120f2808d', '1d36e4c1-d72d-5d78-b5f7-bd00d5ce36c2', 'Andrij', 'Imate li nešto za prehladu?', 'У вас є щось від застуди?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('bc0a0fb0-ce61-51ff-a680-4fe6eac1f7ec', '1d36e4c1-d72d-5d78-b5f7-bd00d5ce36c2', 'Ljekarnica', 'Imamo ove tablete i sirup protiv kašlja.', 'Є ці таблетки й сироп від кашлю.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f1ff55bf-8f95-5693-8929-94252f1b408e', '1d36e4c1-d72d-5d78-b5f7-bd00d5ce36c2', 'Andrij', 'Trebam li recept?', 'Мені потрібен рецепт?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1ab8dfae-0b4f-562c-ab7b-4bd02bd3d914', '1d36e4c1-d72d-5d78-b5f7-bd00d5ce36c2', 'Ljekarnica', 'Ne, ne trebate.', 'Ні, не потрібен.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1e40287e-e618-5a21-8ed8-5c2bb3c0c147', v_lesson, 'Як приймати', 'Kako uzimati', 1312, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0dbe87c7-54f4-5719-9459-8f213decbc44', '1e40287e-e618-5a21-8ed8-5c2bb3c0c147', 'Andrij', 'Kako trebam uzimati tablete?', 'Як мені приймати таблетки?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('60a7409a-ca51-5d69-bddc-a0ad6d29f233', '1e40287e-e618-5a21-8ed8-5c2bb3c0c147', 'Ljekarnica', 'Uzmite jednu tabletu tri puta dnevno.', 'Приймайте одну таблетку тричі на день.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('02aca639-dccf-5276-866f-feb5e1c6492e', '1e40287e-e618-5a21-8ed8-5c2bb3c0c147', 'Andrij', 'Prije ili poslije jela?', 'До чи після їжі?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0f3d3325-a22c-5bc4-97fe-a50440f3eec6', '1e40287e-e618-5a21-8ed8-5c2bb3c0c147', 'Ljekarnica', 'Poslije jela. I pijte puno vode.', 'Після їжі. І пийте багато води.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a7343c49-e185-5cbb-95dd-8930c395b9c5', '1e40287e-e618-5a21-8ed8-5c2bb3c0c147', 'Andrij', 'Hvala, doviđenja!', 'Дякую, до побачення!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 32: Як ви почуваєтеся?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '878c0712-e4e5-5a7d-aab5-510c781da0c7';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.7: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b89a9004-2c03-567a-b23e-31db18f92dea';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.7.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 32: Як ви почуваєтеся?', 'Lekcija 32: Kako se osjećate?', '["Сказати, як ви почуваєтеся", "Порадити другові відпочити", "Вживати nisam, nemam, ne"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('osjećati se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'osjećati se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zdrav') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zdrav'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('umoran') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'umoran'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('spavati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'spavati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('odmarati se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'odmarati se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zdravlje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zdravlje'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('svježi zrak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'svježi zrak'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('šetati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'šetati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vitamin') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vitamin'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dobro') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dobro'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('loše') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'loše'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a300fb09-d01f-55a8-b5c7-5ab0879950dc', 'fill_in_the_blank', 'Ja danas ___ dobro.', 'nisam', '["ne", "nemam", "nisam", "nema"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a300fb09-d01f-55a8-b5c7-5ab0879950dc', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('spavati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('207895a6-7422-5463-91c7-3b4d6b53418f', 'multiple_choice', 'Що означає «spavati»?', 'спати', '["спати", "втомлений", "добре", "вітамін"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '207895a6-7422-5463-91c7-3b4d6b53418f', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zdrav') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d44b4556-80cd-56fd-9edb-b76763368a9a', 'multiple_choice', 'Що означає «zdrav»?', 'здоровий', '["здоровий", "почуватися", "відпочивати", "втомлений"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd44b4556-80cd-56fd-9edb-b76763368a9a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dobro') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('85378c5a-eed9-5da6-a1ec-8706be4a6893', 'multiple_choice', 'Як хорватською «добре»?', 'dobro', '["svježi zrak", "loše", "zdrav", "dobro"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '85378c5a-eed9-5da6-a1ec-8706be4a6893', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vitamin') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9b27bbe2-49f2-594a-ac24-0777fde7883f', 'type_answer', 'Напишіть хорватською: «вітамін»', 'vitamin', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9b27bbe2-49f2-594a-ac24-0777fde7883f', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('osjećati se') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('03f70d67-c630-5b42-ab7c-422969d11bf5', 'type_answer', 'Напишіть хорватською: «почуватися»', 'osjećati se', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '03f70d67-c630-5b42-ab7c-422969d11bf5', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2c8c509f-3cd7-5c1f-8134-f4ff53e9b45f', 'sentence_builder', 'Складіть: «Як ти сьогодні почуваєшся?»', 'Kako se osjećaš danas?', '["se", "osjećaš", "danas?", "Kako"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2c8c509f-3cd7-5c1f-8134-f4ff53e9b45f', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e1a68bef-e6ef-55c1-af52-b55026b83de8', 'sentence_builder', 'Складіть: «Я вже не хворий.»', 'Više nisam bolestan.', '["bolestan.", "Više", "nisam"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e1a68bef-e6ef-55c1-af52-b55026b83de8', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7520860c-3406-5044-89ce-e74eb45996fc', 'listening', 'Прослухайте і складіть фразу', 'Nemam, samo sam jako umoran.', '["jako", "samo", "Nemam,", "umoran.", "sam"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7520860c-3406-5044-89ce-e74eb45996fc', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e1dc9767-6aa5-5cc8-8eab-e6c1fa084243', 'listening', 'Прослухайте і складіть фразу', 'Super! Idemo u šetnju?', '["Super!", "u", "Idemo", "šetnju?"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e1dc9767-6aa5-5cc8-8eab-e6c1fa084243', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('90800cdb-8f12-5d1a-b3ec-98d6100f5143', 'speaking', 'Мені недобре.', 'Nije mi dobro.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '90800cdb-8f12-5d1a-b3ec-98d6100f5143', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('71b96112-5873-59c3-aea8-f103f76f12cf', 'speaking', 'Я погано сплю.', 'Ne spavam dobro.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '71b96112-5873-59c3-aea8-f103f76f12cf', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('40d80acd-3716-5fc1-83c0-6da6f5aecc85', v_lesson, 'Другові недобре', 'Prijatelju nije dobro', 1321, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('16c0b552-a975-5929-88ec-7b91d48fd85e', '40d80acd-3716-5fc1-83c0-6da6f5aecc85', 'Lana', 'Kako se osjećaš danas?', 'Як ти сьогодні почуваєшся?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('44c52e5f-9fde-541b-8716-e1ef5518b6ad', '40d80acd-3716-5fc1-83c0-6da6f5aecc85', 'Taras', 'Nisam dobro. Ne spavam dobro i nemam apetita.', 'Мені недобре. Погано сплю, і немає апетиту.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d51cd91c-0ef4-5103-806d-b5cb9498e138', '40d80acd-3716-5fc1-83c0-6da6f5aecc85', 'Lana', 'Imaš li temperaturu?', 'У тебе є температура?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a32aa0fd-b6a8-52da-8ab7-70c2ad910bfd', '40d80acd-3716-5fc1-83c0-6da6f5aecc85', 'Taras', 'Nemam, samo sam jako umoran.', 'Немає, просто дуже втомлений.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8d67ced2-f529-5ee9-ac8d-5a53cfa52abf', '40d80acd-3716-5fc1-83c0-6da6f5aecc85', 'Lana', 'Odmaraj se i pij čaj!', 'Відпочивай і пий чай!', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cb93fa2d-981e-5d48-b7df-f9140d4b4490', v_lesson, 'Через тиждень', 'Tjedan dana kasnije', 1322, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b78c8c53-7588-51c3-b3e1-d928202c1edf', 'cb93fa2d-981e-5d48-b7df-f9140d4b4490', 'Lana', 'Kako si sada?', 'Як ти зараз?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f64253f8-1822-588c-bea1-f3f9b1b40330', 'cb93fa2d-981e-5d48-b7df-f9140d4b4490', 'Taras', 'Puno bolje! Više nisam bolestan.', 'Набагато краще! Я вже не хворий.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('73332bc3-bc67-56d8-8f30-9271b13f2278', 'cb93fa2d-981e-5d48-b7df-f9140d4b4490', 'Lana', 'Super! Idemo u šetnju?', 'Супер! Підемо на прогулянку?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f8769f9a-28b2-5213-a57d-d270fc399986', 'cb93fa2d-981e-5d48-b7df-f9140d4b4490', 'Taras', 'Može. Treba mi svježeg zraka.', 'Давай. Мені потрібне свіже повітря.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 33: Що болить?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '431b51ad-baa3-5387-94ac-a7273fdb9263';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.7: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.7.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 33: Що болить?', 'Lekcija 33: Što boli?', '["Назвати частини тіла", "Пояснити лікарю, що болить", "Вживати boli me / bole me"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('tijelo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tijelo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ruka') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ruka'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('oko') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'oko'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('uho') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'uho'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zub') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zub'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('trbuh') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'trbuh'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prst') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prst'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('srce') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'srce'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('koljeno') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'koljeno'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vrat') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vrat'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rame') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rame'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('usta') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'usta'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('15e1d406-76ac-5d03-8fb3-4db9031950fa', 'fill_in_the_blank', 'Bole me ___.', 'oči', '["oči", "oko", "okom", "oka"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '15e1d406-76ac-5d03-8fb3-4db9031950fa', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('usta') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4f768547-cf16-53a8-9796-e1161d0d461c', 'multiple_choice', 'Що означає «usta»?', 'рот', '["вухо", "рот", "око", "палець"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4f768547-cf16-53a8-9796-e1161d0d461c', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prst') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b0a0cd92-4db4-502c-ae59-600d2ae14a94', 'multiple_choice', 'Що означає «prst»?', 'палець', '["коліно", "око", "палець", "плече"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b0a0cd92-4db4-502c-ae59-600d2ae14a94', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('uho') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3a696b49-ee50-50f3-9632-a423088cbbd5', 'multiple_choice', 'Як хорватською «вухо»?', 'uho', '["rame", "oko", "uho", "vrat"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3a696b49-ee50-50f3-9632-a423088cbbd5', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('srce') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('303a0a94-cd20-5a3b-9abc-9fb4681f537c', 'type_answer', 'Напишіть хорватською: «серце»', 'srce', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '303a0a94-cd20-5a3b-9abc-9fb4681f537c', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('tijelo') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c7991d5d-167d-5a82-874f-922d1560087a', 'type_answer', 'Напишіть хорватською: «тіло»', 'tijelo', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c7991d5d-167d-5a82-874f-922d1560087a', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d6580900-5de7-515c-a90c-fddd5d8f036f', 'sentence_builder', 'Складіть: «У мене болить коліно.»', 'Boli me koljeno.', '["koljeno.", "Boli", "me"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd6580900-5de7-515c-a90c-fddd5d8f036f', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5131007d-0c8b-5ad0-946f-9595a9c3e2ed', 'sentence_builder', 'Складіть: «У нього болить живіт.»', 'Boli ga trbuh.', '["ga", "trbuh.", "Boli"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5131007d-0c8b-5ad0-946f-9595a9c3e2ed', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2fe30e5d-50bf-52e7-a5a1-9650f772aaa2', 'listening', 'Прослухайте і складіть фразу', 'Možete li pomaknuti ruku?', '["pomaknuti", "li", "Možete", "ruku?"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2fe30e5d-50bf-52e7-a5a1-9650f772aaa2', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('446c4f2d-be62-53da-8f03-2d711b788323', 'listening', 'Прослухайте і складіть фразу', 'Otvori usta i pokaži jezik.', '["Otvori", "pokaži", "jezik.", "i", "usta"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '446c4f2d-be62-53da-8f03-2d711b788323', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a7b48a2a-5e67-5e09-b379-8cb01e66b30d', 'speaking', 'У мене болить рука.', 'Boli me ruka.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a7b48a2a-5e67-5e09-b379-8cb01e66b30d', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a7997a7d-0dfc-584b-ae60-36f7cc854090', 'speaking', 'У мене болять очі.', 'Bole me oči.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a7997a7d-0dfc-584b-ae60-36f7cc854090', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('efff311e-2e91-5683-ac5e-0e5f0adc32e3', v_lesson, 'Після футболу', 'Poslije nogometa', 1331, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('36be24eb-c16d-51fb-af16-349fae747a93', 'efff311e-2e91-5683-ac5e-0e5f0adc32e3', 'Liječnik', 'Što Vas boli?', 'Що у вас болить?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('930de80e-b07f-51ae-b45a-45fe782e35e2', 'efff311e-2e91-5683-ac5e-0e5f0adc32e3', 'Taras', 'Boli me koljeno, a i rame.', 'У мене болить коліно, а ще плече.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2e7b53c6-1f2f-5fd9-ab35-c3f33b6a9313', 'efff311e-2e91-5683-ac5e-0e5f0adc32e3', 'Liječnik', 'Od kada?', 'Відколи?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a66e50f0-0e9f-502e-bbbf-6c2bd3912215', 'efff311e-2e91-5683-ac5e-0e5f0adc32e3', 'Taras', 'Od subote, od nogometa.', 'Із суботи, після футболу.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('518a7f4b-b9ba-5f35-9f7b-a02244b229cb', 'efff311e-2e91-5683-ac5e-0e5f0adc32e3', 'Liječnik', 'Možete li pomaknuti ruku?', 'Можете поворушити рукою?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f4b99d9f-0923-571c-8e8a-eb09a94a68e3', 'efff311e-2e91-5683-ac5e-0e5f0adc32e3', 'Taras', 'Mogu, ali boli.', 'Можу, але болить.', 6) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('77d8eae7-65a5-5813-ab44-1672ac72c575', v_lesson, 'Дитина хворіє', 'Dijete je bolesno', 1332, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9e47fcbc-2bee-5c34-bbb6-1d2873085a5a', '77d8eae7-65a5-5813-ab44-1672ac72c575', 'Mama', 'Doktorice, sinu je loše. Boli ga trbuh i uho.', 'Лікарко, синові погано. У нього болить живіт і вухо.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c0b7d524-0c15-5463-86cb-cf27832f5934', '77d8eae7-65a5-5813-ab44-1672ac72c575', 'Doktorica', 'Ima li temperaturu?', 'У нього є температура?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ee30739c-afba-53b4-8faf-49a26e00771b', '77d8eae7-65a5-5813-ab44-1672ac72c575', 'Mama', 'Ima, trideset osam.', 'Є, тридцять вісім.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('803ec261-62cb-54e7-bf94-792cb1ea62cb', '77d8eae7-65a5-5813-ab44-1672ac72c575', 'Doktorica', 'Otvori usta i pokaži jezik.', 'Відкрий рот і покажи язик.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 34: У стоматолога
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '247c3445-6ba3-50f0-a441-9073d6734451';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.7: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.7.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 34: У стоматолога', 'Lekcija 34: Kod zubara', '["Записатися до стоматолога терміново", "Пояснити, який зуб болить", "Зрозуміти, що зробить лікар"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('zubar') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zubar'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zubobolja') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zubobolja'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('hitan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hitan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('plomba') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'plomba'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('injekcija') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'injekcija'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('izvaditi') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'izvaditi'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('osjetljiv') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'osjetljiv'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('hladno') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hladno'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('gore') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'gore'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dolje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dolje'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('osiguranje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'osiguranje'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('popravljati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'popravljati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1d65f9e1-bd2e-5599-a83b-b3ff2b57abbb', 'fill_in_the_blank', '___ zub Vas boli?', 'Koji', '["Koja", "Koju", "Koje", "Koji"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1d65f9e1-bd2e-5599-a83b-b3ff2b57abbb', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('dolje') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c242c57a-5ddb-5fd3-b107-a42f02892e2d', 'multiple_choice', 'Що означає «dolje»?', 'внизу', '["внизу", "терміновий", "зубний біль", "пломба (зубна)"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c242c57a-5ddb-5fd3-b107-a42f02892e2d', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('popravljati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a1a09105-7a2b-5f32-8c5c-a19546b40329', 'multiple_choice', 'Що означає «popravljati»?', 'ремонтувати (процес)', '["укол", "ремонтувати (процес)", "вгорі", "пломба (зубна)"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a1a09105-7a2b-5f32-8c5c-a19546b40329', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('hitan') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ca61ced3-5963-58d5-bbb0-4dc92dbdd3a0', 'multiple_choice', 'Як хорватською «терміновий»?', 'hitan', '["hitan", "osiguranje", "zubobolja", "zubar"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ca61ced3-5963-58d5-bbb0-4dc92dbdd3a0', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zubar') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c662d3aa-9961-549d-94b1-8cd8b62f83f2', 'type_answer', 'Напишіть хорватською: «стоматолог»', 'zubar', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c662d3aa-9961-549d-94b1-8cd8b62f83f2', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('gore') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d1a151e2-553d-5cd0-b383-5477a0244911', 'type_answer', 'Напишіть хорватською: «вгорі»', 'gore', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd1a151e2-553d-5cd0-b383-5477a0244911', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ebd6d402-0b31-56db-9d72-f09d59023614', 'sentence_builder', 'Складіть: «Мені потрібен терміновий запис.»', 'Trebam hitan termin.', '["Trebam", "termin.", "hitan"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ebd6d402-0b31-56db-9d72-f09d59023614', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0302df37-c7a8-5112-97ce-69710c5f90a3', 'sentence_builder', 'Складіть: «Він чутливий до холодного.»', 'Osjetljiv je na hladno.', '["je", "Osjetljiv", "na", "hladno."]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0302df37-c7a8-5112-97ce-69710c5f90a3', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('48d95580-c963-56f5-ad81-770a1901cc9d', 'listening', 'Прослухайте і складіть фразу', 'Možete li doći danas u tri?', '["li", "danas", "tri?", "Možete", "u", "doći"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '48d95580-c963-56f5-ad81-770a1901cc9d', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2b09aa69-e3d3-54ca-a0b0-07c248bf4f65', 'listening', 'Прослухайте і складіть фразу', 'Trebate plombu. Želite li injekciju?', '["plombu.", "Želite", "li", "injekciju?", "Trebate"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2b09aa69-e3d3-54ca-a0b0-07c248bf4f65', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('cb1069d3-ee18-56b3-ae00-035a38726ac6', 'speaking', 'Мені потрібен стоматолог.', 'Trebam zubara.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'cb1069d3-ee18-56b3-ae00-035a38726ac6', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9d338096-0569-55b5-a504-94f56acc6c23', 'speaking', 'Скільки коштує огляд?', 'Koliko košta pregled?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9d338096-0569-55b5-a504-94f56acc6c23', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4c59828f-76ec-5364-bac4-339e13a88d8c', v_lesson, 'Терміновий запис', 'Hitan termin', 1341, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('59af35d8-25dd-5f92-bacc-9e1198fbf04f', '4c59828f-76ec-5364-bac4-339e13a88d8c', 'Iryna', 'Dobar dan, imam jaku zubobolju. Trebam hitan termin.', 'Добрий день, у мене сильно болить зуб. Мені потрібен терміновий запис.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c4447e1a-68e3-5ad5-92f4-c2fb5d864baf', '4c59828f-76ec-5364-bac4-339e13a88d8c', 'Sestra', 'Možete li doći danas u tri?', 'Можете прийти сьогодні о третій?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('09ebbe53-306d-5557-ad90-3895c9a997ea', '4c59828f-76ec-5364-bac4-339e13a88d8c', 'Iryna', 'Mogu. Koliko košta pregled?', 'Можу. Скільки коштує огляд?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7c51d00f-4cd0-5ff7-a7e2-51caf944440e', '4c59828f-76ec-5364-bac4-339e13a88d8c', 'Sestra', 'S osiguranjem ne plaćate ništa.', 'Зі страховкою ви нічого не платите.', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8d399aa0-15f7-57cc-bd88-c1f6d2bfa03a', v_lesson, 'У кріслі', 'U stolici', 1342, 'A1', 'health', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9de4d08e-e79a-5718-8f4b-99b47e888ae5', '8d399aa0-15f7-57cc-bd88-c1f6d2bfa03a', 'Zubar', 'Koji zub Vas boli?', 'Який зуб у вас болить?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('20d09588-925c-5f31-b161-a1d8cfe1856b', '8d399aa0-15f7-57cc-bd88-c1f6d2bfa03a', 'Iryna', 'Ovaj gore, lijevo. Osjetljiv je na hladno.', 'Ось цей угорі ліворуч. Він чутливий до холодного.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1011f5a8-8507-50bf-9766-07b458c11d25', '8d399aa0-15f7-57cc-bd88-c1f6d2bfa03a', 'Zubar', 'Trebate plombu. Želite li injekciju?', 'Вам потрібна пломба. Хочете укол?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('794169d7-50e2-590d-b7e3-99b4fba53fc9', '8d399aa0-15f7-57cc-bd88-c1f6d2bfa03a', 'Iryna', 'Da, molim! Morate li ga izvaditi?', 'Так, будь ласка! Його треба видаляти?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('afcd993e-5e1d-5d18-8ae9-845864fb4994', '8d399aa0-15f7-57cc-bd88-c1f6d2bfa03a', 'Zubar', 'Ne, samo ga popravljamo.', 'Ні, тільки лікуємо.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 35: Запрошення
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '3ed8282d-b9fa-5151-b184-73fd352f8ba7';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.8: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '61247c65-c284-51c5-a9ed-1626afbd77ac';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.8.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 35: Запрошення', 'Lekcija 35: Poziv', '["Запросити друга", "Погодитися або відмовитися", "Вживати hoćeš li, mogu, ne mogu"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('pozvati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pozvati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('poziv') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'poziv'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zabava') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zabava'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rođendan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rođendan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('doći') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'doći'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('htjeti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'htjeti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('moći') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'moći'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vidimo se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vidimo se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('slaviti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'slaviti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kino') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kino'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('večeras') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'večeras'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rado') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rado'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a271dbd0-520f-507b-972b-fc6b129a662c', 'fill_in_the_blank', 'Nažalost, ja ne ___ doći.', 'mogu', '["možeš", "mogu", "može", "moći"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a271dbd0-520f-507b-972b-fc6b129a662c', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('slaviti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('815ca078-f42a-5eb4-8389-5ea5c748f5a8', 'multiple_choice', 'Що означає «slaviti»?', 'святкувати', '["святкувати", "запросити", "сьогодні ввечері", "день народження"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '815ca078-f42a-5eb4-8389-5ea5c748f5a8', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('poziv') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('31374717-29b1-5f39-ac4c-c642c068831b', 'multiple_choice', 'Що означає «poziv»?', 'дзвінок / запрошення', '["побачимося", "день народження", "могти", "дзвінок / запрошення"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '31374717-29b1-5f39-ac4c-c642c068831b', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vidimo se') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f6b3c127-e913-52c8-bf7e-193bb1e89e7b', 'multiple_choice', 'Як хорватською «побачимося»?', 'vidimo se', '["slaviti", "htjeti", "poziv", "vidimo se"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f6b3c127-e913-52c8-bf7e-193bb1e89e7b', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('moći') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f8176496-7b92-517f-952b-3310747826e5', 'type_answer', 'Напишіть хорватською: «могти»', 'moći', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f8176496-7b92-517f-952b-3310747826e5', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('večeras') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('14dd814d-c27c-5870-8654-383e33e15763', 'type_answer', 'Напишіть хорватською: «сьогодні ввечері»', 'večeras', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '14dd814d-c27c-5870-8654-383e33e15763', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('262636df-e854-5748-a8e2-ee63395ed471', 'sentence_builder', 'Складіть: «У суботу я святкую день народження.»', 'U subotu slavim rođendan.', '["U", "slavim", "rođendan.", "subotu"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '262636df-e854-5748-a8e2-ee63395ed471', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('760bdb89-1797-5aed-8c02-b91f9136ca94', 'sentence_builder', 'Складіть: «На жаль, не можу.»', 'Nažalost, ne mogu.', '["Nažalost,", "mogu.", "ne"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '760bdb89-1797-5aed-8c02-b91f9136ca94', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('911cb1c6-d66e-51be-bd1d-1aa172180f9f', 'listening', 'Прослухайте і складіть фразу', 'U osam, kod mene.', '["kod", "osam,", "mene.", "U"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '911cb1c6-d66e-51be-bd1d-1aa172180f9f', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('98dad53b-1f9d-5fab-b836-570783fe43da', 'listening', 'Прослухайте і складіть фразу', 'Sutra mogu. Vidimo se u sedam!', '["Vidimo", "Sutra", "se", "mogu.", "sedam!", "u"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '98dad53b-1f9d-5fab-b836-570783fe43da', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8970522d-f5f0-5211-8e50-af14bac63e9d', 'speaking', 'Хочеш піти в кіно?', 'Hoćeš li ići u kino?', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8970522d-f5f0-5211-8e50-af14bac63e9d', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ed8ac0cd-9419-5859-b2e2-8ef7f6fafe1b', 'speaking', 'Із задоволенням!', 'S veseljem!', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ed8ac0cd-9419-5859-b2e2-8ef7f6fafe1b', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('67c17c91-b780-51a6-bfb7-342077a804b0', v_lesson, 'День народження', 'Rođendan', 1351, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('da70dc7e-bfed-5618-b86b-2d2d2ed0b1af', '67c17c91-b780-51a6-bfb7-342077a804b0', 'Marko', 'U subotu slavim rođendan. Hoćeš li doći?', 'У суботу я святкую день народження. Прийдеш?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('27ccd9b4-9b25-50dc-a817-693383f4ca97', '67c17c91-b780-51a6-bfb7-342077a804b0', 'Iryna', 'Hoću, rado! U koliko sati?', 'Так, із радістю! О котрій?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('31541477-422c-5c35-9645-a50a4fed182f', '67c17c91-b780-51a6-bfb7-342077a804b0', 'Marko', 'U osam, kod mene.', 'О восьмій, у мене.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7c3d8edc-2cc8-5207-84e1-9e7a0ab6e9e3', '67c17c91-b780-51a6-bfb7-342077a804b0', 'Iryna', 'Trebam li nešto donijeti?', 'Мені щось принести?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9a71c62b-e304-54d3-9126-8a6815dc9882', '67c17c91-b780-51a6-bfb7-342077a804b0', 'Marko', 'Ne trebaš, samo dobro raspoloženje!', 'Не треба, тільки гарний настрій!', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('591c3e6f-a91b-530d-a75a-077509f11a51', v_lesson, 'Не можу', 'Ne mogu', 1352, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e6f8f637-448f-570f-b59c-46b52dab4e89', '591c3e6f-a91b-530d-a75a-077509f11a51', 'Ana', 'Idemo u kino večeras?', 'Підемо сьогодні ввечері в кіно?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('432c8501-a359-54e5-bfd3-9054e5966b42', '591c3e6f-a91b-530d-a75a-077509f11a51', 'Taras', 'Nažalost, ne mogu. Moram raditi.', 'На жаль, не можу. Мушу працювати.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1de3119f-c4b3-5b43-977c-e3c9a40b8bf2', '591c3e6f-a91b-530d-a75a-077509f11a51', 'Ana', 'A sutra?', 'А завтра?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9b7f6302-8a73-54d8-98a8-7960ba557d43', '591c3e6f-a91b-530d-a75a-077509f11a51', 'Taras', 'Sutra mogu. Vidimo se u sedam!', 'Завтра можу. Побачимося о сьомій!', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 36: Хобі
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '1c16ceee-5f42-536a-98b4-7dcabaa3be6d';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.8: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '318b394b-c622-5dd6-8494-4c1472b6df62';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.8.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 36: Хобі', 'Lekcija 36: Hobiji', '["Розповісти про свої хобі", "Запитати, що любить робити співрозмовник", "Вживати volim + інфінітив"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('hobi') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hobi'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('voljeti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'voljeti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('plivati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'plivati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('plesati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'plesati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pjevati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pjevati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('crtati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'crtati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('fotografirati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'fotografirati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('igrati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'igrati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('nogomet') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'nogomet'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('bazen') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'bazen'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('slobodno vrijeme') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'slobodno vrijeme'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sport') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sport'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a0ebefc5-7f08-59c6-89a2-5e9ade0d0bf3', 'fill_in_the_blank', 'Ja ___ plivati.', 'volim', '["vole", "voliš", "voli", "volim"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a0ebefc5-7f08-59c6-89a2-5e9ade0d0bf3', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('fotografirati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a1608e64-acf4-55a1-b055-dd170d21bef0', 'multiple_choice', 'Що означає «fotografirati»?', 'фотографувати', '["плавати", "танцювати", "фотографувати", "вільний час"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a1608e64-acf4-55a1-b055-dd170d21bef0', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('igrati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c2ec3d11-c2e1-5103-8faf-8a0634d1d692', 'multiple_choice', 'Що означає «igrati»?', 'грати', '["хобі / улюблена справа", "грати", "співати", "футбол"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c2ec3d11-c2e1-5103-8faf-8a0634d1d692', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('plivati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d7526c73-8164-573e-91bf-d4a2072ab797', 'multiple_choice', 'Як хорватською «плавати»?', 'plivati', '["fotografirati", "slobodno vrijeme", "plivati", "igrati"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd7526c73-8164-573e-91bf-d4a2072ab797', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pjevati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f136044c-5640-5313-98a0-b954763f2f92', 'type_answer', 'Напишіть хорватською: «співати»', 'pjevati', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f136044c-5640-5313-98a0-b954763f2f92', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('sport') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('777632cd-9931-55f4-bafd-2b1605cd6b03', 'type_answer', 'Напишіть хорватською: «спорт»', 'sport', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '777632cd-9931-55f4-bafd-2b1605cd6b03', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('daeb6338-8e44-5994-9c0a-9d99b27909b2', 'sentence_builder', 'Складіть: «Я люблю плавати й фотографувати.»', 'Volim plivati i fotografirati.', '["Volim", "plivati", "fotografirati.", "i"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'daeb6338-8e44-5994-9c0a-9d99b27909b2', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('be619a29-c303-57d5-8a6c-4a88a74c5b42', 'sentence_builder', 'Складіть: «Ти граєш у футбол?»', 'Igraš li nogomet?', '["li", "nogomet?", "Igraš"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'be619a29-c303-57d5-8a6c-4a88a74c5b42', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a6933b0d-b9be-5a27-a14a-1b43334254b9', 'listening', 'Прослухайте і складіть фразу', 'Ja više volim plesati.', '["više", "volim", "plesati.", "Ja"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a6933b0d-b9be-5a27-a14a-1b43334254b9', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('630789ee-d9ef-5621-b33b-b3b67ce3c2f8', 'listening', 'Прослухайте і складіть фразу', 'Igram, svake nedjelje s kolegama.', '["kolegama.", "nedjelje", "svake", "Igram,", "s"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '630789ee-d9ef-5621-b33b-b3b67ce3c2f8', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('aabab1a4-1d41-5c2f-b418-32aea4be6b4d', 'speaking', 'Я люблю співати.', 'Volim pjevati.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'aabab1a4-1d41-5c2f-b418-32aea4be6b4d', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b2b0d44f-edee-55bb-8163-b60978932cd4', 'speaking', 'Що ти любиш робити?', 'Što voliš raditi?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b2b0d44f-edee-55bb-8163-b60978932cd4', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7381d5b8-4e9c-5e8c-a5f4-ea90f3569d97', v_lesson, 'Що ти любиш робити?', 'Što voliš raditi?', 1361, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('45bbeb84-0b58-53a7-b2ba-a5b3011eb477', '7381d5b8-4e9c-5e8c-a5f4-ea90f3569d97', 'Petra', 'Što voliš raditi u slobodno vrijeme?', 'Що ти любиш робити у вільний час?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d88f86d5-1a39-5847-aa0a-c73033fa6462', '7381d5b8-4e9c-5e8c-a5f4-ea90f3569d97', 'Andrij', 'Volim plivati i fotografirati.', 'Я люблю плавати й фотографувати.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('323ad068-7ad3-5eb2-9daf-12ee53227819', '7381d5b8-4e9c-5e8c-a5f4-ea90f3569d97', 'Petra', 'Gdje plivaš?', 'Де ти плаваєш?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f8827e57-897b-57c8-b5dc-f6ff04efc209', '7381d5b8-4e9c-5e8c-a5f4-ea90f3569d97', 'Andrij', 'Ljeti na moru, a zimi na bazenu.', 'Влітку в морі, а взимку в басейні.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e2ca7c4d-453a-56f6-99d7-19706b23e490', '7381d5b8-4e9c-5e8c-a5f4-ea90f3569d97', 'Petra', 'Ja više volim plesati.', 'А я більше люблю танцювати.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3c3ae8fb-c1e7-5136-842c-2b8dfe862b23', v_lesson, 'Футбол', 'Nogomet', 1362, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2ed0c178-e4b8-5277-b05a-72b97257c8c9', '3c3ae8fb-c1e7-5136-842c-2b8dfe862b23', 'Luka', 'Igraš li nogomet?', 'Ти граєш у футбол?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('55e71f6d-b08e-5f2d-8cc5-cca4c84709bf', '3c3ae8fb-c1e7-5136-842c-2b8dfe862b23', 'Taras', 'Igram, svake nedjelje s kolegama.', 'Граю, щонеділі з колегами.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7a7aa967-c5a0-5469-9200-a06b529c6af6', '3c3ae8fb-c1e7-5136-842c-2b8dfe862b23', 'Luka', 'Mogu li i ja igrati s vama?', 'Можна й мені грати з вами?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a3a45419-9bd3-591b-a809-89c6a1cf8809', '3c3ae8fb-c1e7-5136-842c-2b8dfe862b23', 'Taras', 'Naravno! Dođi u nedjelju u deset.', 'Звісно! Приходь у неділю о десятій.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 37: Що ти думаєш?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'ec1b7982-c092-5504-a233-4162f92f512a';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.8: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '765ac66f-d54b-505b-9b11-c48e5ad26018';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.8.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 37: Що ти думаєш?', 'Lekcija 37: Što misliš?', '["Сказати, що вам подобається, а що ні", "Пояснити чому: jer, zato što", "Порадити книжку чи фільм"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('misliti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'misliti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('mišljenje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'mišljenje'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zanimljiv') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zanimljiv'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dosadan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dosadan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('film') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'film'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('knjiga') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'knjiga'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zato što') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zato što'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jer') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jer'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ali') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ali'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ili') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ili'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sviđati se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sviđati se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('preporučiti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'preporučiti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b39572a1-ece4-550c-8bf6-002750f1923a', 'fill_in_the_blank', 'Volim ovaj film ___ je zanimljiv.', 'jer', '["a", "ali", "jer", "ili"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b39572a1-ece4-550c-8bf6-002750f1923a', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('mišljenje') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b87360cd-d5c5-5995-a68d-5ff6d7864e1d', 'multiple_choice', 'Що означає «mišljenje»?', 'думка', '["але", "подобатися", "думка", "цікавий"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b87360cd-d5c5-5995-a68d-5ff6d7864e1d', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zato što') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('765970f6-399e-5ecc-9067-a5fa1f89a661', 'multiple_choice', 'Що означає «zato što»?', 'тому що', '["подобатися", "фільм", "тому що", "нудний"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '765970f6-399e-5ecc-9067-a5fa1f89a661', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('preporučiti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e83c4ab8-d07d-5871-b533-cfcb3dbe49de', 'multiple_choice', 'Як хорватською «рекомендувати»?', 'preporučiti', '["mišljenje", "dosadan", "preporučiti", "misliti"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e83c4ab8-d07d-5871-b533-cfcb3dbe49de', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ili') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ec9b7d0a-60a7-53b1-9821-1d10ddae646c', 'type_answer', 'Напишіть хорватською: «або»', 'ili', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ec9b7d0a-60a7-53b1-9821-1d10ddae646c', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('dosadan') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e7c99f6b-0539-5ca9-9626-acd173fd254c', 'type_answer', 'Напишіть хорватською: «нудний»', 'dosadan', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e7c99f6b-0539-5ca9-9626-acd173fd254c', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2edfea9e-3775-5da3-9784-74bdc1b01f27', 'sentence_builder', 'Складіть: «Цікавий, але задовгий.»', 'Zanimljiv je, ali predug.', '["Zanimljiv", "predug.", "je,", "ali"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2edfea9e-3775-5da3-9784-74bdc1b01f27', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5ca839e7-1bf1-55af-9f78-78a20d6aedca', 'sentence_builder', 'Складіть: «Спробуй комікси, бо вони легкі.»', 'Probaj stripove jer su laki.', '["su", "jer", "Probaj", "laki.", "stripove"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5ca839e7-1bf1-55af-9f78-78a20d6aedca', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2332c850-7a87-57e6-96a5-388af42d8ecf', 'listening', 'Прослухайте і складіть фразу', 'Meni je dosadan.', '["je", "dosadan.", "Meni"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2332c850-7a87-57e6-96a5-388af42d8ecf', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9c39d8e5-e68f-5c1b-979f-8fa25b195bb3', 'listening', 'Прослухайте і складіть фразу', 'Mislim da jest.', '["da", "jest.", "Mislim"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9c39d8e5-e68f-5c1b-979f-8fa25b195bb3', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('108b29a9-b49a-50f5-b6f1-6766f1295c99', 'speaking', 'Я думаю, що це цікаво.', 'Mislim da je to zanimljivo.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '108b29a9-b49a-50f5-b6f1-6766f1295c99', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5648bc2d-fae4-5598-8e0e-6f64a5d065e5', 'speaking', 'Мені подобається, бо це легко.', 'Sviđa mi se jer je lako.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5648bc2d-fae4-5598-8e0e-6f64a5d065e5', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('85f95ab6-8f99-5214-b1cc-99a4d2539237', v_lesson, 'Після кіно', 'Poslije kina', 1371, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c24637da-cbe5-589f-9cad-716b48c13381', '85f95ab6-8f99-5214-b1cc-99a4d2539237', 'Ana', 'Kako ti se sviđa film?', 'Як тобі фільм?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('aff89dc3-3fb1-5e99-ac54-8a26b5d7747b', '85f95ab6-8f99-5214-b1cc-99a4d2539237', 'Oleg', 'Zanimljiv je, ali predug.', 'Цікавий, але задовгий.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b1c4b164-390d-50bb-bc67-74242dc65053', '85f95ab6-8f99-5214-b1cc-99a4d2539237', 'Ana', 'Meni je dosadan.', 'А мені нудний.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('bca8d6d6-7335-5723-9550-168bfa2ad29f', '85f95ab6-8f99-5214-b1cc-99a4d2539237', 'Oleg', 'Zašto?', 'Чому?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('df54d199-0228-55cb-8fb7-27aae03680d6', '85f95ab6-8f99-5214-b1cc-99a4d2539237', 'Ana', 'Zato što znam kraj od početka!', 'Бо я знаю кінець від самого початку!', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e0a9f7ce-277a-506b-930f-9ae425f73016', v_lesson, 'Порада', 'Preporuka', 1372, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7cb92bfc-aa09-5538-99a7-716c31bdc1c4', 'e0a9f7ce-277a-506b-930f-9ae425f73016', 'Iryna', 'Što da čitam na hrvatskom?', 'Що мені почитати хорватською?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1878f16f-36b4-5655-825f-59a8f21c1c59', 'e0a9f7ce-277a-506b-930f-9ae425f73016', 'Marko', 'Probaj stripove jer su laki.', 'Спробуй комікси, бо вони легкі.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a2a4c758-d9e5-519b-92f0-7a2ef69f41fd', 'e0a9f7ce-277a-506b-930f-9ae425f73016', 'Iryna', 'Misliš li da je to dobro za učenje?', 'Думаєш, це добре для навчання?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8697096d-efca-5ea3-b9f4-df6cd9118926', 'e0a9f7ce-277a-506b-930f-9ae425f73016', 'Marko', 'Mislim da jest. Ili gledaj filmove s titlovima.', 'Думаю, що так. Або дивись фільми із субтитрами.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 38: Почуття
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'fac55dd6-0020-5997-8461-45ee2f94d3c5';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.8: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '765ac66f-d54b-505b-9b11-c48e5ad26018';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.8.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 38: Почуття', 'Lekcija 38: Osjećaji', '["Сказати, як ви почуваєтеся", "Підтримати друга", "Пояснити причину: jer, zato što"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('osjećaj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'osjećaj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tužan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tužan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('usamljen') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'usamljen'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('nedostajati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'nedostajati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('nervozan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'nervozan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zabrinut') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zabrinut'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('brinuti se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'brinuti se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ljut') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ljut'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zadovoljan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zadovoljan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('iznenađen') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'iznenađen'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('izgledati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'izgledati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sasvim') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sasvim'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fda2a9c0-42d4-5883-aace-5fe14ecaf1a2', 'fill_in_the_blank', 'Sretna sam ___ si ovdje.', 'jer', '["ali", "jer", "ili", "a"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fda2a9c0-42d4-5883-aace-5fe14ecaf1a2', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('nervozan') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('dbc0576c-2451-515b-beee-7e24cb2b64d2', 'multiple_choice', 'Що означає «nervozan»?', 'знервований; схвильований', '["турбуватися", "почуття", "знепокоєний / стурбований", "знервований; схвильований"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'dbc0576c-2451-515b-beee-7e24cb2b64d2', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ljut') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('867e5d6f-44ff-56f8-a151-39f10aed436d', 'multiple_choice', 'Що означає «ljut»?', 'злий / сердитий', '["злий / сердитий", "знервований; схвильований", "здивований", "самотній"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '867e5d6f-44ff-56f8-a151-39f10aed436d', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('usamljen') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('89ea482b-e4c8-5c2d-a5a9-663ae5fd5350', 'multiple_choice', 'Як хорватською «самотній»?', 'usamljen', '["usamljen", "iznenađen", "izgledati", "ljut"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '89ea482b-e4c8-5c2d-a5a9-663ae5fd5350', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('osjećaj') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('94724e0e-1aa0-5441-b20c-6e62a007af37', 'type_answer', 'Напишіть хорватською: «почуття»', 'osjećaj', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '94724e0e-1aa0-5441-b20c-6e62a007af37', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('brinuti se') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e76c7732-7d3d-5c51-8745-a42523dd76a4', 'type_answer', 'Напишіть хорватською: «турбуватися»', 'brinuti se', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e76c7732-7d3d-5c51-8745-a42523dd76a4', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1d975b58-3248-5cb5-a0bd-71218cf5c7a9', 'sentence_builder', 'Складіть: «Я сумую за родиною.»', 'Nedostaje mi obitelj.', '["Nedostaje", "obitelj.", "mi"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1d975b58-3248-5cb5-a0bd-71218cf5c7a9', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0b21e4be-bbe8-50fd-b9bf-b630b493a26e', 'sentence_builder', 'Складіть: «Я дуже нервую.»', 'Jako sam nervozan.', '["sam", "Jako", "nervozan."]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0b21e4be-bbe8-50fd-b9bf-b630b493a26e', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f2b6e37f-fca8-5f22-a913-837e86931227', 'listening', 'Прослухайте і складіть фразу', 'Razumijem. Hoćeš li doći k meni na kavu?', '["meni", "na", "Hoćeš", "Razumijem.", "k", "kavu?", "li", "doći"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f2b6e37f-fca8-5f22-a913-837e86931227', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('40f2713e-d3a2-54a7-a84b-6ee1a73c4b1a', 'listening', 'Прослухайте і складіть фразу', 'Zašto? Ti si odličan!', '["odličan!", "Ti", "Zašto?", "si"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '40f2713e-d3a2-54a7-a84b-6ee1a73c4b1a', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('69f81e45-af65-513c-ac54-ea32737feaff', 'speaking', 'Я сьогодні щасливий.', 'Danas sam sretan.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '69f81e45-af65-513c-ac54-ea32737feaff', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('92eaaabd-e635-56f6-8b0e-829c790a8883', 'speaking', 'Не хвилюйся!', 'Ne brini!', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '92eaaabd-e635-56f6-8b0e-829c790a8883', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6f18ed19-9bfe-540a-aa29-5a9f55a88925', v_lesson, 'Що з тобою?', 'Što ti je?', 1381, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('db25e7a7-14c5-528a-8802-45812afefc30', '6f18ed19-9bfe-540a-aa29-5a9f55a88925', 'Ana', 'Što ti je? Izgledaš tužno.', 'Що з тобою? Ти сумно виглядаєш.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('aee7deb7-d265-54d5-91f3-e46e758ba97f', '6f18ed19-9bfe-540a-aa29-5a9f55a88925', 'Oksana', 'Nedostaje mi obitelj. Ponekad sam usamljena.', 'Я сумую за родиною. Іноді мені самотньо.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f13530c3-5480-505d-9e58-ca5d0c28422e', '6f18ed19-9bfe-540a-aa29-5a9f55a88925', 'Ana', 'Razumijem. Hoćeš li doći k meni na kavu?', 'Розумію. Хочеш прийти до мене на каву?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('64ac74dc-f985-5939-923c-0993ce129b0b', '6f18ed19-9bfe-540a-aa29-5a9f55a88925', 'Oksana', 'Hoću, hvala. Sretna sam jer te imam.', 'Так, дякую. Я щаслива, що ти в мене є.', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('20ab6801-b0bb-5638-bbd7-39ee863ba76f', v_lesson, 'Перед співбесідою', 'Prije razgovora za posao', 1382, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('79c3ae7e-4335-5dcb-8739-41de67c5fcaa', '20ab6801-b0bb-5638-bbd7-39ee863ba76f', 'Taras', 'Jako sam nervozan.', 'Я дуже нервую.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('74969ab1-7644-51d9-b320-39b9a9350562', '20ab6801-b0bb-5638-bbd7-39ee863ba76f', 'Marko', 'Zašto? Ti si odličan!', 'Чому? Ти чудовий!', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e725327c-9cd9-58c4-85c5-b4e4d5bbf8c2', '20ab6801-b0bb-5638-bbd7-39ee863ba76f', 'Taras', 'Zabrinut sam jer ne govorim dobro hrvatski.', 'Я хвилююся, бо погано говорю хорватською.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('85d6ffa1-fe97-5012-b9bc-f6513b8cc0d2', '20ab6801-b0bb-5638-bbd7-39ee863ba76f', 'Marko', 'Govoriš sasvim dobro. Ne brini!', 'Ти говориш цілком добре. Не хвилюйся!', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.8 · урок 39: Домовляємося про зустріч
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'dde31f54-28b8-505b-aba6-3e578601fccb';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.8: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.8.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 39: Домовляємося про зустріч', 'Lekcija 39: Dogovor', '["Запросити на прогулянку", "Домовитися, де й коли зустрітися", "Запитати, що взяти з собою"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('izlet') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'izlet'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('planina') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'planina'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vrh') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vrh'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('nalaziti se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'nalaziti se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ispred') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ispred'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('točno') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'točno'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ponijeti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ponijeti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sendvič') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sendvič'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('udoban') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'udoban'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('hod') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hod'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dogovor') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dogovor'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('iza') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'iza'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('af38f920-2c4e-5cc2-bfcd-728d59926763', 'fill_in_the_blank', '___ se nalazimo? — Ispred kolodvora.', 'Gdje', '["Gdje", "Tko", "Kako", "Kada"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'af38f920-2c4e-5cc2-bfcd-728d59926763', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('izlet') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('123e13f1-1da9-5200-a950-625c9d8f1f1a', 'multiple_choice', 'Що означає «izlet»?', 'поїздка; екскурсія', '["домовленість", "вершина", "поїздка; екскурсія", "перед"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '123e13f1-1da9-5200-a950-625c9d8f1f1a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('točno') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('5fcdca3d-3dfe-59e4-b514-f6d13382a67a', 'multiple_choice', 'Що означає «točno»?', 'точно, правильно', '["за / позаду", "точно, правильно", "сендвіч", "зручний"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5fcdca3d-3dfe-59e4-b514-f6d13382a67a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('udoban') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3be65fdd-3dbb-5b5a-af15-0e7dbb5f56ad', 'multiple_choice', 'Як хорватською «зручний»?', 'udoban', '["ponijeti", "nalaziti se", "sendvič", "udoban"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3be65fdd-3dbb-5b5a-af15-0e7dbb5f56ad', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vrh') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a5aa85e7-3c9a-5072-9167-9cc8f049fb80', 'type_answer', 'Напишіть хорватською: «вершина»', 'vrh', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a5aa85e7-3c9a-5072-9167-9cc8f049fb80', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('sendvič') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3a699b27-4dc2-5a80-94f2-7710282cf3da', 'type_answer', 'Напишіть хорватською: «сендвіч»', 'sendvič', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3a699b27-4dc2-5a80-94f2-7710282cf3da', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c505fa1b-716f-5a6e-b7fd-3af8840c1f83', 'sentence_builder', 'Складіть: «Ти вільна в неділю?»', 'Jesi li slobodna u nedjelju?', '["u", "Jesi", "li", "slobodna", "nedjelju?"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c505fa1b-716f-5a6e-b7fd-3af8840c1f83', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1ed393dd-5d8b-5bd6-8930-e27373d2e337', 'sentence_builder', 'Складіть: «Що мені взяти з собою?»', 'Što trebam ponijeti?', '["trebam", "Što", "ponijeti?"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1ed393dd-5d8b-5bd6-8930-e27373d2e337', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d8f7e876-bcb9-5248-846d-49ecaf5be672', 'listening', 'Прослухайте і складіть фразу', 'Ispred kolodvora, u devet točno.', '["devet", "Ispred", "kolodvora,", "u", "točno."]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd8f7e876-bcb9-5248-846d-49ecaf5be672', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('63085953-e8af-555f-ba33-99efc5b3e50c', 'listening', 'Прослухайте і складіть фразу', 'Oko dva sata hoda.', '["hoda.", "Oko", "sata", "dva"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '63085953-e8af-555f-ba33-99efc5b3e50c', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('73a44a8f-4eb3-53e4-8d11-9b187a23aa28', 'speaking', 'Де зустрічаємося?', 'Gdje se nalazimo?', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '73a44a8f-4eb3-53e4-8d11-9b187a23aa28', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4aa9faf9-40cc-5612-a0d7-79a405f3ae8c', 'speaking', 'О котрій?', 'U koliko sati?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4aa9faf9-40cc-5612-a0d7-79a405f3ae8c', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8779ae61-6f07-55c5-a0ec-39963b35cfb2', v_lesson, 'Плани на неділю', 'Planovi za nedjelju', 1391, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0f0e7364-ea22-55f2-b6fb-8ea72eb386b8', '8779ae61-6f07-55c5-a0ec-39963b35cfb2', 'Luka', 'Bok! Jesi li slobodna u nedjelju?', 'Привіт! Ти вільна в неділю?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('fe549e36-9e18-5743-a5ba-4aa2c8c27023', '8779ae61-6f07-55c5-a0ec-39963b35cfb2', 'Iryna', 'Jesam. Zašto?', 'Так. А що?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ec039af6-816d-51e4-81bf-8f6e5fcbba2c', '8779ae61-6f07-55c5-a0ec-39963b35cfb2', 'Luka', 'Idemo na izlet na Sljeme. Hoćeš s nama?', 'Ми йдемо в похід на Слеме. Хочеш з нами?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('fd800710-66f7-5855-8ada-7c1a23d6a5da', '8779ae61-6f07-55c5-a0ec-39963b35cfb2', 'Iryna', 'Hoću! Gdje se nalazimo?', 'Хочу! Де зустрічаємося?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('47b80126-c894-53e8-a5db-d627dbc45447', '8779ae61-6f07-55c5-a0ec-39963b35cfb2', 'Luka', 'Ispred kolodvora, u devet točno.', 'Перед вокзалом, рівно о дев’ятій.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0d0e10a6-6b58-5a8b-bef8-eef55c884fed', v_lesson, 'Що взяти?', 'Što ponijeti?', 1392, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('bbfd6fd7-5c1f-599d-983c-2edf3ea7d605', '0d0e10a6-6b58-5a8b-bef8-eef55c884fed', 'Iryna', 'Što trebam ponijeti?', 'Що мені взяти з собою?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('efa4cf51-0807-5dc5-b987-c21e64b9b123', '0d0e10a6-6b58-5a8b-bef8-eef55c884fed', 'Luka', 'Vodu, sendvič i udobne cipele.', 'Воду, сендвіч і зручне взуття.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1bd1feb4-ec67-5668-a4cb-7c141ca5ef38', '0d0e10a6-6b58-5a8b-bef8-eef55c884fed', 'Iryna', 'Je li daleko do vrha planine?', 'Далеко до вершини гори?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5a57ae8f-403e-5bd1-88fb-3b7b68625520', '0d0e10a6-6b58-5a8b-bef8-eef55c884fed', 'Luka', 'Oko dva sata hoda.', 'Близько двох годин пішки.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 40: Погода
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '0cb42e87-0ece-5e12-a07c-05cb5c370157';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.9: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.9.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 40: Погода', 'Lekcija 40: Vrijeme', '["Запитати про прогноз погоди", "Порівняти погоду: toplije, hladnije", "Сказати, яку пору року ви любите"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('vremenska prognoza') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vremenska prognoza'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sunce') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sunce'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kiša') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kiša'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vjetar') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vjetar'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('snijeg') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'snijeg'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('oblak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'oblak'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('hladan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hladan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('topao') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'topao'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kišobran') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kišobran'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('magla') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'magla'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('godišnja doba') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'godišnja doba'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jesen') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jesen'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ea0980dc-a70b-54b6-922e-9ec5dbcf6a19', 'fill_in_the_blank', 'Danas je ___ nego jučer.', 'toplije', '["toplo", "toplije", "najtoplije", "topao"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ea0980dc-a70b-54b6-922e-9ec5dbcf6a19', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('hladan') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d5abc7bb-fef0-5d54-a581-21681995943a', 'multiple_choice', 'Що означає «hladan»?', 'холодний', '["вітер", "хмара", "холодний", "осінь"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd5abc7bb-fef0-5d54-a581-21681995943a', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('topao') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c5b6e22a-d3e5-51da-a024-853b40d7f13e', 'multiple_choice', 'Що означає «topao»?', 'теплий', '["теплий", "дощ", "сніг", "прогноз погоди"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c5b6e22a-d3e5-51da-a024-853b40d7f13e', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kiša') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('56b4a540-8896-523a-9a11-6607ae921fba', 'multiple_choice', 'Як хорватською «дощ»?', 'kiša', '["kiša", "godišnja doba", "kišobran", "oblak"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '56b4a540-8896-523a-9a11-6607ae921fba', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('godišnja doba') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a73dd8cc-0a96-5759-9589-d4a80cf6fa15', 'type_answer', 'Напишіть хорватською: «пори року»', 'godišnja doba', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a73dd8cc-0a96-5759-9589-d4a80cf6fa15', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('oblak') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ce25f8cd-9176-5a53-ac0f-15e49cbbc99a', 'type_answer', 'Напишіть хорватською: «хмара»', 'oblak', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ce25f8cd-9176-5a53-ac0f-15e49cbbc99a', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('00d69c74-4a9a-59e5-a770-55a5b32c6cae', 'sentence_builder', 'Складіть: «Який прогноз на завтра?»', 'Kakva je prognoza za sutra?', '["je", "Kakva", "za", "sutra?", "prognoza"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '00d69c74-4a9a-59e5-a770-55a5b32c6cae', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7d461881-d606-513c-92c8-61b8369ff11a', 'sentence_builder', 'Складіть: «У Загребі зима холодніша, ніж у Спліті.»', 'U Zagrebu je zima hladnija nego u Splitu.', '["u", "U", "je", "Zagrebu", "hladnija", "zima", "Splitu.", "nego"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7d461881-d606-513c-92c8-61b8369ff11a', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('78c58eaa-e5e7-5a55-97bb-516f0d4ae01b', 'listening', 'Прослухайте і складіть фразу', 'Opet kiša? Danas je ljepše.', '["Opet", "kiša?", "je", "Danas", "ljepše."]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '78c58eaa-e5e7-5a55-97bb-516f0d4ae01b', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d1ca9c3e-46c7-5e45-a572-1c5b38d861cd', 'listening', 'Прослухайте і складіть фразу', 'Ja volim jesen jer je najmirnija.', '["volim", "Ja", "jesen", "jer", "najmirnija.", "je"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd1ca9c3e-46c7-5e45-a572-1c5b38d861cd', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a1881d74-7c8c-5a54-8dd6-ba0bd03e0a8b', 'speaking', 'Сьогодні холодніше, ніж учора.', 'Danas je hladnije nego jučer.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a1881d74-7c8c-5a54-8dd6-ba0bd03e0a8b', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0df474e8-70eb-5fdc-9585-da0c3e32a867', 'speaking', 'Візьми парасолю!', 'Ponesi kišobran!', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0df474e8-70eb-5fdc-9585-da0c3e32a867', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3c61e8f6-867f-5f60-8ea6-bcb94946b0a9', v_lesson, 'Прогноз', 'Prognoza', 1401, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7f113cdd-d635-5ac8-a493-04819f95a7bc', '3c61e8f6-867f-5f60-8ea6-bcb94946b0a9', 'Ivan', 'Kakva je prognoza za sutra?', 'Який прогноз на завтра?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('adb30abb-ab78-5a12-af75-4fecfb134ba0', '3c61e8f6-867f-5f60-8ea6-bcb94946b0a9', 'Olena', 'Kiša i vjetar.', 'Дощ і вітер.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2b0379f0-677a-52f3-b9a5-c8b75f7f3bc7', '3c61e8f6-867f-5f60-8ea6-bcb94946b0a9', 'Ivan', 'Opet kiša? Danas je ljepše.', 'Знову дощ? Сьогодні гарніше.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('810ce523-601b-560c-b891-6be5a1467e5c', '3c61e8f6-867f-5f60-8ea6-bcb94946b0a9', 'Olena', 'Ponesi sutra kišobran!', 'Візьми завтра парасолю!', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c0d17e56-5dcc-58bd-842e-dfcc55ddc1b7', v_lesson, 'Найкраща пора року', 'Najljepše godišnje doba', 1402, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3a5ebb83-650d-5ff7-9cdb-f7d1ba638fdd', 'c0d17e56-5dcc-58bd-842e-dfcc55ddc1b7', 'Maja', 'Koje godišnje doba voliš najviše?', 'Яку пору року ти любиш найбільше?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0bfa8981-df5e-519e-b1c1-48387388feac', 'c0d17e56-5dcc-58bd-842e-dfcc55ddc1b7', 'Taras', 'Proljeće. Toplije je nego zimi, a nije prevruće.', 'Весну. Тепліше, ніж узимку, і не надто спекотно.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8a7136d3-61f1-5722-a68d-41838938a08d', 'c0d17e56-5dcc-58bd-842e-dfcc55ddc1b7', 'Maja', 'Ja volim jesen jer je najmirnija.', 'А я люблю осінь, бо вона найспокійніша.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5a62de2d-720e-5cc2-ac8a-c0c74423053f', 'c0d17e56-5dcc-58bd-842e-dfcc55ddc1b7', 'Taras', 'U Zagrebu je zima hladnija nego u Splitu.', 'У Загребі зима холодніша, ніж у Спліті.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 41: На острів
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '71ab330d-abbe-57a7-870e-77e59daf3627';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.9: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'f891e65a-d7be-5542-ae6e-dbee5bfe415c';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.9.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 41: На острів', 'Lekcija 41: Na otok', '["Купити квиток на пором", "Сказати, де ви зупинилися", "Вживати na otoku, na plaži, u Bolu"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('otok') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'otok'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('trajekt') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'trajekt'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('trajektna luka') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'trajektna luka'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('plaža') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'plaža'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('more') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'more'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('obala') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'obala'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kupati se') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kupati se'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ljeto') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ljeto'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('apartman') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'apartman'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sunce') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sunce'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('odmor') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'odmor'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('putovanje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'putovanje'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('bf396dea-6aec-5d5f-b665-4e1df023d88f', 'fill_in_the_blank', 'Ljeti živimo na ___.', 'otoku', '["otoku", "otoka", "otok", "otokom"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'bf396dea-6aec-5d5f-b665-4e1df023d88f', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('obala') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2f254317-c74e-53e4-ae44-76e3c8753a10', 'multiple_choice', 'Що означає «obala»?', 'берег / узбережжя', '["подорож", "берег / узбережжя", "апартаменти / квартира", "поромний порт"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2f254317-c74e-53e4-ae44-76e3c8753a10', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('trajekt') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8af672f1-806f-58ad-9925-e9c2e1dce5e8', 'multiple_choice', 'Що означає «trajekt»?', 'пором', '["апартаменти / квартира", "літо", "поромний порт", "пором"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8af672f1-806f-58ad-9925-e9c2e1dce5e8', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('trajektna luka') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('cb5403d8-a4b0-5755-b8d8-71bae2ec734d', 'multiple_choice', 'Як хорватською «поромний порт»?', 'trajektna luka', '["apartman", "odmor", "ljeto", "trajektna luka"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'cb5403d8-a4b0-5755-b8d8-71bae2ec734d', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kupati se') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e95f79b2-4b0a-5cc5-85bf-69d73287cbd3', 'type_answer', 'Напишіть хорватською: «купатися»', 'kupati se', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e95f79b2-4b0a-5cc5-85bf-69d73287cbd3', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('sunce') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('02fd3d4f-743c-542e-acf8-53e3d7a68f2f', 'type_answer', 'Напишіть хорватською: «сонце»', 'sunce', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '02fd3d4f-743c-542e-acf8-53e3d7a68f2f', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('40847451-e1d5-5645-85b7-9a6690630538', 'sentence_builder', 'Складіть: «Пором відправляється о десятій.»', 'Trajekt polazi u deset sati.', '["polazi", "u", "sati.", "Trajekt", "deset"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '40847451-e1d5-5645-85b7-9a6690630538', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b9e16224-249d-5a8c-b28b-04b72f58cdc6', 'sentence_builder', 'Складіть: «На якому ви пляжі?»', 'Na kojoj plaži ste?', '["kojoj", "Na", "ste?", "plaži"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b9e16224-249d-5a8c-b28b-04b72f58cdc6', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('849808ae-f506-5e9b-9185-75e16481db80', 'listening', 'Прослухайте і складіть фразу', 'Pedeset minuta. Čekajte u drugom redu.', '["drugom", "Pedeset", "minuta.", "u", "Čekajte", "redu."]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '849808ae-f506-5e9b-9185-75e16481db80', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7a484c44-5add-50e8-807d-f32e5023ceaa', 'listening', 'Прослухайте і складіть фразу', 'U malom apartmanu u Bolu.', '["malom", "Bolu.", "U", "apartmanu", "u"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7a484c44-5add-50e8-807d-f32e5023ceaa', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8485c65c-ef36-54e1-8b0c-4276bb287430', 'speaking', 'Ми на пляжі.', 'Na plaži smo.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8485c65c-ef36-54e1-8b0c-4276bb287430', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('04ea1a44-b623-505a-883a-2687162de52c', 'speaking', 'Ми відпочиваємо на острові.', 'Odmaramo se na otoku.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '04ea1a44-b623-505a-883a-2687162de52c', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ed410612-b8b1-555a-9c0a-444f5d66a57c', v_lesson, 'Квиток на пором', 'Karta za trajekt', 1411, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4d285160-d21b-51d3-b1f4-e2b20f5a49b5', 'ed410612-b8b1-555a-9c0a-444f5d66a57c', 'Oksana', 'Dvije karte za Brač i jedan auto, molim.', 'Два квитки на Брач і одне авто, будь ласка.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('78423447-6747-58f6-b70d-bcae7ff3c67c', 'ed410612-b8b1-555a-9c0a-444f5d66a57c', 'Blagajnik', 'Trajekt polazi u deset sati.', 'Пором відправляється о десятій.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cbbd5971-a00e-5142-a042-0f1130f33dec', 'ed410612-b8b1-555a-9c0a-444f5d66a57c', 'Oksana', 'Koliko dugo traje vožnja?', 'Скільки триває поїздка?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('43aadb09-b4f4-5d8d-a6bb-7c9f8dbb3fd0', 'ed410612-b8b1-555a-9c0a-444f5d66a57c', 'Blagajnik', 'Pedeset minuta. Čekajte u drugom redu.', 'П’ятдесят хвилин. Чекайте в другому ряду.', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6faa3705-d7a9-5745-b594-6384e846a8ff', v_lesson, 'На пляжі', 'Na plaži', 1412, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a6153179-74b8-533a-9b1d-01d624a1c52f', '6faa3705-d7a9-5745-b594-6384e846a8ff', 'Andrij', 'Gdje spavate na otoku?', 'Де ви ночуєте на острові?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('15ddbd23-1438-59a7-81dc-f07c92044f05', '6faa3705-d7a9-5745-b594-6384e846a8ff', 'Petra', 'U malom apartmanu u Bolu.', 'У маленьких апартаментах у Болі.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('02dab047-7aef-52e8-84d9-f21863927e13', '6faa3705-d7a9-5745-b594-6384e846a8ff', 'Andrij', 'I mi smo u Bolu! Na kojoj plaži ste?', 'Ми теж у Болі! На якому ви пляжі?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e741d6bf-1ca0-5e3b-8f65-2e18f9a348f2', '6faa3705-d7a9-5745-b594-6384e846a8ff', 'Petra', 'Na Zlatnom ratu. More je predivno, kupamo se svaki dan!', 'На Златному Раті. Море чудове, ми купаємося щодня!', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 42: Свята
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'f67bd38c-a41c-51df-b9c0-081737600fce';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.9: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '94ab9b5e-95b0-5edb-8322-52293bdb5d05';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.9.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 42: Свята', 'Lekcija 42: Blagdani', '["Розповісти, як ваша родина святкує", "Привітати зі святом", "Вживати naš, vaš, njihov"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('Božić') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'Božić'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('blagdan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'blagdan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('obitelj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'obitelj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tradicija') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tradicija'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('poklon') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'poklon'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('slaviti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'slaviti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sretan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sretan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zajedno') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zajedno'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('naš') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'naš'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vaš') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vaš'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('njihov') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'njihov'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('djeca') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'djeca'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('37935ea0-49cc-5dc7-9620-4e10e2188396', 'fill_in_the_blank', 'Ovo je ___ obitelj.', 'naša', '["naše", "naša", "našu", "naš"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '37935ea0-49cc-5dc7-9620-4e10e2188396', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('naš') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a02e132a-0b41-51d1-b667-f2c6cf50e4c7', 'multiple_choice', 'Що означає «naš»?', 'наш', '["сім''я, родина", "традиція", "наш", "їхній"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a02e132a-0b41-51d1-b667-f2c6cf50e4c7', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('njihov') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('367926cd-1212-5cb3-aad0-4c99a6e6c42f', 'multiple_choice', 'Що означає «njihov»?', 'їхній', '["Різдво", "свято", "подарунок", "їхній"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '367926cd-1212-5cb3-aad0-4c99a6e6c42f', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('vaš') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ec4685e8-b351-5c62-bfbc-b1a948114101', 'multiple_choice', 'Як хорватською «ваш»?', 'vaš', '["njihov", "tradicija", "zajedno", "vaš"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ec4685e8-b351-5c62-bfbc-b1a948114101', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tradicija') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('940b4003-e758-58f5-8e99-180f6c62b864', 'type_answer', 'Напишіть хорватською: «традиція»', 'tradicija', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '940b4003-e758-58f5-8e99-180f6c62b864', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('sretan') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2dfcb53d-e4a3-50c2-b7d8-8482c8b83a40', 'type_answer', 'Напишіть хорватською: «щасливий»', 'sretan', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2dfcb53d-e4a3-50c2-b7d8-8482c8b83a40', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('646f3e54-a96b-5068-b818-5693f7eb9540', 'sentence_builder', 'Складіть: «Наша родина святкує двадцять п’ятого грудня.»', 'Naša obitelj slavi dvadeset petog prosinca.', '["Naša", "dvadeset", "slavi", "prosinca.", "petog", "obitelj"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '646f3e54-a96b-5068-b818-5693f7eb9540', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0d0845f9-40ec-503f-b218-dc11be00bfdb', 'sentence_builder', 'Складіть: «Наші діти люблять шоколад.»', 'Naša djeca vole čokoladu.', '["vole", "čokoladu.", "Naša", "djeca"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0d0845f9-40ec-503f-b218-dc11be00bfdb', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('6945d233-bba6-59f4-99c6-4061b4c0e4f4', 'listening', 'Прослухайте і складіть фразу', 'I mi! Što je vaše tradicionalno jelo?', '["jelo?", "je", "vaše", "I", "Što", "mi!", "tradicionalno"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6945d233-bba6-59f4-99c6-4061b4c0e4f4', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a87f5941-32e8-56fd-b41c-150296f77cd3', 'listening', 'Прослухайте і складіть фразу', 'Sretan Božić vama i vašoj obitelji!', '["vama", "i", "Božić", "obitelji!", "vašoj", "Sretan"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a87f5941-32e8-56fd-b41c-150296f77cd3', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d22f4736-04d1-5fc4-9390-423d29ed6b13', 'speaking', 'Щасливого Різдва!', 'Sretan Božić!', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd22f4736-04d1-5fc4-9390-423d29ed6b13', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7b4c9a79-eb69-599a-b617-ba9ebf8230bc', 'speaking', 'Це наша традиція.', 'To je naša tradicija.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7b4c9a79-eb69-599a-b617-ba9ebf8230bc', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ae41c9a6-560e-5a09-bdc0-7cd74e0cafb1', v_lesson, 'Різдво', 'Božić', 1421, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c1bee22e-6f0f-50f6-a13a-da81fb8ea44d', 'ae41c9a6-560e-5a09-bdc0-7cd74e0cafb1', 'Ana', 'Koji je najveći blagdan u vašoj obitelji?', 'Яке найбільше свято у вашій родині?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c50734dd-89d8-5a3c-b20c-1194f8eeff9d', 'ae41c9a6-560e-5a09-bdc0-7cd74e0cafb1', 'Iryna', 'Božić. Naša obitelj slavi dvadeset petog prosinca.', 'Різдво. Наша родина святкує двадцять п’ятого грудня.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('361d75d0-2a5e-5f61-bb3b-0b2d8d530d3b', 'ae41c9a6-560e-5a09-bdc0-7cd74e0cafb1', 'Ana', 'I mi! Što je vaše tradicionalno jelo?', 'І ми! Яка ваша традиційна страва?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('128ba101-0bb7-5951-a699-70cdbc624fba', 'ae41c9a6-560e-5a09-bdc0-7cd74e0cafb1', 'Iryna', 'Kutja. A vaše?', 'Кутя. А ваша?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('be79c5a3-d5c3-5666-ac3b-d51ae11a9319', 'ae41c9a6-560e-5a09-bdc0-7cd74e0cafb1', 'Ana', 'Bakalar i sarma. Moja baka kuha najbolju sarmu!', 'Тріска й сарма. Моя бабуся готує найкращу сарму!', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4fe44aa5-3595-5214-827a-3e5de2c99c68', v_lesson, 'Подарунок', 'Poklon', 1422, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ed20fcea-3d9d-5513-abe1-066f2789a4aa', '4fe44aa5-3595-5214-827a-3e5de2c99c68', 'Marko', 'Ovo je za tebe i tvoju djecu.', 'Це для тебе і твоїх дітей.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c84443f8-8f2b-5bc1-898f-c482afd1cd95', '4fe44aa5-3595-5214-827a-3e5de2c99c68', 'Taras', 'Hvala puno! Naša djeca vole čokoladu.', 'Дуже дякую! Наші діти люблять шоколад.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('80527b56-7927-54f7-b6bc-bf51bfde5461', '4fe44aa5-3595-5214-827a-3e5de2c99c68', 'Marko', 'Sretan Božić vama i vašoj obitelji!', 'Щасливого Різдва вам і вашій родині!', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3984f29b-8a9c-5502-8624-bc0dc044dc71', '4fe44aa5-3595-5214-827a-3e5de2c99c68', 'Taras', 'Hvala, i tebi i tvojima!', 'Дякую, і тобі, і твоїм рідним!', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 43: Краї Хорватії
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '8633c234-d638-57f1-ad92-1c78be43fb07';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.9: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'b58103b4-a259-5384-aa65-ffc0e2a195c8';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.9.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 43: Краї Хорватії', 'Lekcija 43: Hrvatski krajevi', '["Сказати, де розташоване місто: на півночі, на півдні", "Розповісти про різні краї Хорватії", "Порівняти міста: veći, ljepši"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('kraj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kraj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sjever') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sjever'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jug') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jug'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('istok') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'istok'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zapad') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zapad'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rijeka') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rijeka'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ravnica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ravnica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('glavni grad') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'glavni grad'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('poznat') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'poznat'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('maslinovo ulje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'maslinovo ulje'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('način') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'način'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zvučati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zvučati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('32212ec4-0ddf-5b24-8b3f-0a78954e203d', 'fill_in_the_blank', 'Split je ___ od Osijeka.', 'veći', '["veliki", "najveći", "velik", "veći"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '32212ec4-0ddf-5b24-8b3f-0a78954e203d', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('rijeka') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1f1c36ca-cd59-54ed-b82e-59ec8cfb37ae', 'multiple_choice', 'Що означає «rijeka»?', 'річка', '["річка", "південь", "рівнина", "схід"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1f1c36ca-cd59-54ed-b82e-59ec8cfb37ae', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('glavni grad') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('905deb83-bb67-52d5-822b-53a04ac50651', 'multiple_choice', 'Що означає «glavni grad»?', 'столиця', '["південь", "спосіб", "схід", "столиця"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '905deb83-bb67-52d5-822b-53a04ac50651', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sjever') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('59654261-e3a6-5abf-9621-c3d3a3402c5f', 'multiple_choice', 'Як хорватською «північ»?', 'sjever', '["način", "maslinovo ulje", "sjever", "rijeka"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '59654261-e3a6-5abf-9621-c3d3a3402c5f', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('istok') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('dcbaaea8-cd30-5d25-a58a-36d8d272f394', 'type_answer', 'Напишіть хорватською: «схід»', 'istok', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'dcbaaea8-cd30-5d25-a58a-36d8d272f394', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('jug') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('639acd09-a4a8-5b77-b60b-9ce0a94e78fa', 'type_answer', 'Напишіть хорватською: «південь»', 'jug', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '639acd09-a4a8-5b77-b60b-9ce0a94e78fa', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('13172209-e42e-5099-8581-7ca62274e65d', 'sentence_builder', 'Складіть: «Спліт на півдні Хорватії.»', 'Split je na jugu Hrvatske.', '["na", "Split", "jugu", "je", "Hrvatske."]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '13172209-e42e-5099-8581-7ca62274e65d', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('25c5f800-d3d0-5687-9fbf-c91be2867afc', 'sentence_builder', 'Складіть: «Кожен гарний по-своєму.»', 'Svaki je lijep na svoj način.', '["na", "svoj", "način.", "je", "lijep", "Svaki"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '25c5f800-d3d0-5687-9fbf-c91be2867afc', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7bd2f4a5-dc3b-517e-a5a4-271665efe786', 'listening', 'Прослухайте і складіть фразу', 'A Ana je iz Slavonije?', '["je", "Slavonije?", "iz", "A", "Ana"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7bd2f4a5-dc3b-517e-a5a4-271665efe786', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('e22f666f-676c-5512-b172-d1d4b6eabdef', 'listening', 'Прослухайте і складіть фразу', 'Oko tri sata autom. Na zapadu je.', '["zapadu", "autom.", "tri", "sata", "Na", "Oko", "je."]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e22f666f-676c-5512-b172-d1d4b6eabdef', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('118a083c-b240-5732-b607-8b21db278879', 'speaking', 'Загреб — столиця Хорватії.', 'Zagreb je glavni grad Hrvatske.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '118a083c-b240-5732-b607-8b21db278879', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('ff414850-bbbb-5eb4-82d2-c2bb75fa0885', 'speaking', 'Я живу на півночі.', 'Živim na sjeveru.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'ff414850-bbbb-5eb4-82d2-c2bb75fa0885', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('924ca9af-4b03-5128-9db0-76fb98f9b934', v_lesson, 'Звідки ти?', 'Odakle si?', 1431, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('289cc6b4-969c-5a06-8079-a63e56d66f2a', '924ca9af-4b03-5128-9db0-76fb98f9b934', 'Iryna', 'Marko, ti si iz Dalmacije?', 'Марку, ти з Далмації?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('97e3dbff-d799-50d2-a879-92a8529ed75f', '924ca9af-4b03-5128-9db0-76fb98f9b934', 'Marko', 'Da, iz Splita. To je na jugu, na moru.', 'Так, зі Спліта. Це на півдні, біля моря.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e30c76af-441b-5e7d-8d0d-d2c7115a9409', '924ca9af-4b03-5128-9db0-76fb98f9b934', 'Iryna', 'A Ana je iz Slavonije?', 'А Ана зі Славонії?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4e3b0012-06ce-5c4d-9d5c-27793c9658a8', '924ca9af-4b03-5128-9db0-76fb98f9b934', 'Marko', 'Da, iz Osijeka, na istoku. Tamo su ravnice i rijeke.', 'Так, з Осієка, на сході. Там рівнини й річки.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5cd3ad24-5472-5e54-b41a-385678dba706', '924ca9af-4b03-5128-9db0-76fb98f9b934', 'Iryna', 'Koji je kraj najljepši?', 'Який край найкрасивіший?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('41601682-1ee0-54ae-9fb4-830512220b06', '924ca9af-4b03-5128-9db0-76fb98f9b934', 'Marko', 'Svaki je lijep na svoj način!', 'Кожен гарний по-своєму!', 6) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d9dd0b07-8133-56ae-8d2d-04401378d1d4', v_lesson, 'Поїздка в Істрію', 'Izlet u Istru', 1432, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2b6cb4cf-e8f5-52e7-966c-64ee27fec5d6', 'd9dd0b07-8133-56ae-8d2d-04401378d1d4', 'Taras', 'Je li Istra daleko od Zagreba?', 'Істрія далеко від Загреба?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('202e0575-67de-51d2-81fe-7da5d68737c4', 'd9dd0b07-8133-56ae-8d2d-04401378d1d4', 'Lana', 'Oko tri sata autom. Na zapadu je.', 'Близько трьох годин машиною. Вона на заході.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c0e6eb16-1d26-5ea1-ae27-4a011ef7579c', 'd9dd0b07-8133-56ae-8d2d-04401378d1d4', 'Taras', 'Po čemu je Istra poznata?', 'Чим відома Істрія?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c8eb8496-2b22-5091-8b4b-cd5a92aac078', 'd9dd0b07-8133-56ae-8d2d-04401378d1d4', 'Lana', 'Po tartufima, maslinovom ulju i starim gradovima.', 'Трюфелями, оливковою олією і старими містечками.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('08ef8cbd-946b-50d6-b224-f62a23d8805f', 'd9dd0b07-8133-56ae-8d2d-04401378d1d4', 'Taras', 'Zvuči odlično!', 'Звучить чудово!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.9 · урок 44: Хорватські звичаї
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '2fabcd03-324d-5355-b96e-022723fbeda7';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.9: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.9.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 44: Хорватські звичаї', 'Lekcija 44: Hrvatski običaji', '["Зрозуміти, чому кава в Хорватії — це зустріч", "Поводитися в гостях за столом", "Сказати тост: Živjeli!"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('običaj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'običaj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('druženje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'druženje'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('terasa') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'terasa'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sjediti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sjediti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pričati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pričati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dugo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dugo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dobro došli') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dobro došli'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sjesti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sjesti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('gost') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'gost'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('živjeli') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'živjeli'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tradicionalan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tradicionalan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('piće') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'piće'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9e5827c5-d200-58d8-8782-9da0d8c66f03', 'fill_in_the_blank', 'Hrvati ___ kavu na terasi.', 'piju', '["piju", "piješ", "pijem", "pije"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9e5827c5-d200-58d8-8782-9da0d8c66f03', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('živjeli') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7b1e4f10-b1be-5971-9c2a-7f183d79d906', 'multiple_choice', 'Що означає «živjeli»?', 'будьмо! (тост)', '["напій", "будьмо! (тост)", "сидіти", "звичай"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7b1e4f10-b1be-5971-9c2a-7f183d79d906', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('gost') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f67c144f-8fca-5fdb-af70-08f8cde18cd0', 'multiple_choice', 'Що означає «gost»?', 'гість / відвідувач', '["будьмо! (тост)", "довго", "гість / відвідувач", "розповідати; розмовляти"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f67c144f-8fca-5fdb-af70-08f8cde18cd0', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dobro došli') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('728bd2be-762a-567f-b0f3-15c2f95c9057', 'multiple_choice', 'Як хорватською «ласкаво просимо»?', 'dobro došli', '["dobro došli", "pričati", "živjeli", "običaj"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '728bd2be-762a-567f-b0f3-15c2f95c9057', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tradicionalan') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('68a56491-751f-59aa-81dc-696585299d00', 'type_answer', 'Напишіть хорватською: «традиційний»', 'tradicionalan', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '68a56491-751f-59aa-81dc-696585299d00', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('terasa') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('9aa4957c-ae35-5d9c-b105-c2189bb3ac09', 'type_answer', 'Напишіть хорватською: «тераса»', 'terasa', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9aa4957c-ae35-5d9c-b105-c2189bb3ac09', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('84f0dbb3-b7bd-5e1b-a0b4-78ddc75ade3f', 'sentence_builder', 'Складіть: «Кава — це не просто напій.»', 'Kava nije samo piće.', '["nije", "piće.", "samo", "Kava"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '84f0dbb3-b7bd-5e1b-a0b4-78ddc75ade3f', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('474532a4-a9c4-5ce2-bf35-e06927f0eb3d', 'sentence_builder', 'Складіть: «Сідайте, обід готовий.»', 'Sjednite, ručak je spreman.', '["Sjednite,", "je", "spreman.", "ručak"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '474532a4-a9c4-5ce2-bf35-e06927f0eb3d', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3e86de47-4052-56bf-8354-0cfe858a82c6', 'listening', 'Прослухайте і складіть фразу', 'Naravno! Sjedimo na terasi i pričamo.', '["pričamo.", "na", "terasi", "Sjedimo", "i", "Naravno!"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3e86de47-4052-56bf-8354-0cfe858a82c6', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('eda04e04-b8ca-50a3-a11b-f97985dbb64e', 'listening', 'Прослухайте і складіть фразу', 'Hvala, dušo! Živjeli!', '["Živjeli!", "dušo!", "Hvala,"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'eda04e04-b8ca-50a3-a11b-f97985dbb64e', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('eec9c478-f2f5-5583-bb1f-0bb9bf644abd', 'speaking', 'Будьмо!', 'Živjeli!', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'eec9c478-f2f5-5583-bb1f-0bb9bf644abd', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c1537581-c108-5564-996d-35e5b1652189', 'speaking', 'Ласкаво просимо!', 'Dobro došli!', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c1537581-c108-5564-996d-35e5b1652189', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('91b5a690-9711-5104-8831-55789fcb6081', v_lesson, 'Кава — це зустріч', 'Kava je druženje', 1441, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6cdbfb3a-e428-51c8-8770-be70b412af2f', '91b5a690-9711-5104-8831-55789fcb6081', 'Iryna', 'Zašto Hrvati piju kavu tako dugo?', 'Чому хорвати так довго п’ють каву?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ade344f6-0096-5450-b587-5a84f9e0703e', '91b5a690-9711-5104-8831-55789fcb6081', 'Ivan', 'Kava nije samo piće. To je druženje!', 'Кава — це не просто напій. Це спілкування!', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8628c2d4-1830-5a08-8d19-358b2bf5adb8', '91b5a690-9711-5104-8831-55789fcb6081', 'Iryna', 'Sat vremena za jednu kavu?', 'Година на одну каву?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1e2627de-bac7-51f4-9206-c6a069e71eae', '91b5a690-9711-5104-8831-55789fcb6081', 'Ivan', 'Naravno! Sjedimo na terasi i pričamo.', 'Звісно! Сидимо на терасі й розмовляємо.', 4) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c5bfaa23-7a1d-5def-b9a8-08ee4715a852', v_lesson, 'Недільний обід', 'Nedjeljni ručak', 1442, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4ab7b73a-0228-51ea-99c8-5baee2b82c89', 'c5bfaa23-7a1d-5def-b9a8-08ee4715a852', 'Baka', 'Dobro došli! Sjednite, ručak je spreman.', 'Ласкаво просимо! Сідайте, обід готовий.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0d3fb02d-338d-51c5-b2d7-1deaff18f3ae', 'c5bfaa23-7a1d-5def-b9a8-08ee4715a852', 'Taras', 'Hvala! Ovo vino je za Vas.', 'Дякую! Це вино для вас.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3b8eecfc-9949-5a02-b0d1-14d319be5e3f', 'c5bfaa23-7a1d-5def-b9a8-08ee4715a852', 'Baka', 'Hvala, dušo! Živjeli!', 'Дякую, любий! Будьмо!', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7a5aabc2-6cbc-535b-b74f-f60e9fcf5b0c', 'c5bfaa23-7a1d-5def-b9a8-08ee4715a852', 'Taras', 'Živjeli! U Ukrajini kažemo «Budmo!».', 'Будьмо! В Україні кажемо «Будьмо!».', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 45: Розкажіть про себе
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'fc1baff0-0e48-5676-bd3c-47d88d31e582';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.10: місце уроку 1 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '1435d343-6721-5eb7-8dc2-af7f9a027716';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.10.1'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 45: Розкажіть про себе', 'Lekcija 45: Recite nešto o sebi', '["Розповісти про себе, роботу й родину", "Пояснити, чому ви вчите хорватську", "Поставити питання новому знайомому"]'::jsonb, 12, 'PUBLISHED', 1);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('živjeti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'živjeti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('raditi') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'raditi'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('učiti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'učiti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jezik') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jezik'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('obitelj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'obitelj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('djeca') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'djeca'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('stan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'stan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('grad') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'grad'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('godina') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'godina'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('posao') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'posao'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('hobi') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hobi'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('razgovarati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'razgovarati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('d53e4466-3081-5dc3-bab0-fe12b20f3169', 'fill_in_the_blank', '___ učite hrvatski? — Zato što radim ovdje.', 'Zašto', '["Zašto", "Gdje", "Kada", "Kako"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd53e4466-3081-5dc3-bab0-fe12b20f3169', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('grad') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fde24d06-ec02-5d6d-81e2-6a9a92756310', 'multiple_choice', 'Що означає «grad»?', 'місто', '["робота / справа", "місто", "квартира", "розмовляти"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fde24d06-ec02-5d6d-81e2-6a9a92756310', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('godina') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f67f1ab8-6d1a-5813-a514-cab32f1acbe3', 'multiple_choice', 'Що означає «godina»?', 'рік', '["квартира", "рік", "сім''я, родина", "мова"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f67f1ab8-6d1a-5813-a514-cab32f1acbe3', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('živjeti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('674366c2-066a-5a17-86fe-16b000006958', 'multiple_choice', 'Як хорватською «жити»?', 'živjeti', '["raditi", "godina", "živjeti", "učiti"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '674366c2-066a-5a17-86fe-16b000006958', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('učiti') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('de91415c-99cc-5667-8d9a-e3adc0902e59', 'type_answer', 'Напишіть хорватською: «вчити (ся)»', 'učiti', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'de91415c-99cc-5667-8d9a-e3adc0902e59', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('djeca') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1f5383fc-a7be-5942-8012-449016094516', 'type_answer', 'Напишіть хорватською: «діти»', 'djeca', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1f5383fc-a7be-5942-8012-449016094516', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c95c7996-3162-5549-82bd-7e6e61bc5cfc', 'sentence_builder', 'Складіть: «Розкажіть щось про себе.»', 'Recite nešto o sebi.', '["o", "Recite", "nešto", "sebi."]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c95c7996-3162-5549-82bd-7e6e61bc5cfc', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fbc551e5-559f-5df0-8353-dafb2bf14f12', 'sentence_builder', 'Складіть: «Що ти робиш на вихідних?»', 'Što radiš vikendom?', '["vikendom?", "Što", "radiš"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fbc551e5-559f-5df0-8353-dafb2bf14f12', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a190b0e8-10f5-5e6f-9054-0e23366dc867', 'listening', 'Прослухайте і складіть фразу', 'Čime se bavite?', '["se", "bavite?", "Čime"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a190b0e8-10f5-5e6f-9054-0e23366dc867', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8171f65a-6948-5c21-9e4f-bbbed1f57167', 'listening', 'Прослухайте і складіть фразу', 'Tri godine. Volim Rijeku, ali mi nedostaje dom.', '["Volim", "dom.", "Tri", "nedostaje", "godine.", "mi", "Rijeku,", "ali"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8171f65a-6948-5c21-9e4f-bbbed1f57167', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2a8e4d22-f2d0-5a75-b5a5-12d33ecfe666', 'speaking', 'Я вчу хорватську, бо працюю тут.', 'Učim hrvatski jer radim ovdje.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2a8e4d22-f2d0-5a75-b5a5-12d33ecfe666', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0bc35778-f844-512b-a4d4-5007ce863460', 'speaking', 'Чим ви займаєтеся?', 'Čime se bavite?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0bc35778-f844-512b-a4d4-5007ce863460', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2bffcc25-5ca2-5e5f-912f-5e35138384aa', v_lesson, 'На курсі', 'Na tečaju', 1451, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ac392a0f-1690-536f-8f95-65e966b320da', '2bffcc25-5ca2-5e5f-912f-5e35138384aa', 'Profesorica', 'Recite nešto o sebi.', 'Розкажіть щось про себе.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ac1e91d7-5d1c-5336-ad8f-5a38e2d19478', '2bffcc25-5ca2-5e5f-912f-5e35138384aa', 'Oleg', 'Zovem se Oleg. Imam četrdeset godina i živim u Rijeci.', 'Мене звати Олег. Мені сорок років, і я живу в Рієці.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2b257e7c-f0b6-5919-a0e5-4507fdb12124', '2bffcc25-5ca2-5e5f-912f-5e35138384aa', 'Profesorica', 'Čime se bavite?', 'Чим ви займаєтеся?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c934cfba-4bbb-5c7a-a4f4-508a5aa08f10', '2bffcc25-5ca2-5e5f-912f-5e35138384aa', 'Oleg', 'Radim u luci. Imam ženu i dvoje djece.', 'Працюю в порту. У мене дружина і двоє дітей.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d9b3244c-a666-55e8-8e09-3db03522a291', '2bffcc25-5ca2-5e5f-912f-5e35138384aa', 'Profesorica', 'Zašto učite hrvatski?', 'Чому ви вчите хорватську?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a33110dc-17a7-5958-adde-546e2bc63daf', '2bffcc25-5ca2-5e5f-912f-5e35138384aa', 'Oleg', 'Zato što želim razgovarati s kolegama.', 'Тому що хочу розмовляти з колегами.', 6) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ff9314b3-e6ae-54d1-96f2-2b73af4e3846', v_lesson, 'Нова знайома', 'Nova poznanica', 1452, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('614888df-74b0-5073-9f81-98e3b60670de', 'ff9314b3-e6ae-54d1-96f2-2b73af4e3846', 'Iva', 'Koliko dugo si u Hrvatskoj?', 'Як довго ти в Хорватії?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8ee8d1e8-b026-5d0f-84f1-67b539ba0a38', 'ff9314b3-e6ae-54d1-96f2-2b73af4e3846', 'Oksana', 'Tri godine. Volim Rijeku, ali mi nedostaje dom.', 'Три роки. Люблю Рієку, але сумую за домом.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cfc82ad4-7d42-5b46-809d-db19e00bd383', 'ff9314b3-e6ae-54d1-96f2-2b73af4e3846', 'Iva', 'Razumijem. Što radiš vikendom?', 'Розумію. Що ти робиш на вихідних?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6a0396b6-926a-538e-aebe-b674fb9ca315', 'ff9314b3-e6ae-54d1-96f2-2b73af4e3846', 'Oksana', 'Šetam uz more i učim kuhati hrvatska jela.', 'Гуляю вздовж моря і вчуся готувати хорватські страви.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 46: Пошта і банкомат
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '1c468857-b9aa-5143-aa84-6ea02aa2443c';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.10: місце уроку 2 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.10.2'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 46: Пошта і банкомат', 'Lekcija 46: Pošta i bankomat', '["Надіслати посилку", "Знайти банкомат", "Вживати kod banke, preko puta pošte, do centra"]'::jsonb, 12, 'PUBLISHED', 2);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('pošta') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pošta'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('banka') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'banka'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('bankomat') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'bankomat'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('paket') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'paket'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pismo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pismo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('poslati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'poslati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('bankovni račun') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'bankovni račun'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('novac') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'novac'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('šalter') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'šalter'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('red') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'red'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('obrazac') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'obrazac'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('blizu') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'blizu'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('c8183c3e-9555-5331-9a81-b8605a3b9dff', 'fill_in_the_blank', 'Bankomat je preko puta ___.', 'pošte', '["poštu", "pošti", "pošta", "pošte"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c8183c3e-9555-5331-9a81-b8605a3b9dff', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('poslati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('2e0af783-4b8a-5a29-99b0-b8cd69666f54', 'multiple_choice', 'Що означає «poslati»?', 'надіслати / відправити', '["пошта", "надіслати / відправити", "банк", "черга"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2e0af783-4b8a-5a29-99b0-b8cd69666f54', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('blizu') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('69b249de-a6dc-5f68-9640-1263908b6207', 'multiple_choice', 'Що означає «blizu»?', 'поруч / близько', '["банкомат", "поруч / близько", "бланк / анкета", "гроші"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '69b249de-a6dc-5f68-9640-1263908b6207', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('obrazac') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f91b7bc8-fb3c-58c1-afcb-c027283ea35e', 'multiple_choice', 'Як хорватською «бланк / анкета»?', 'obrazac', '["pismo", "obrazac", "red", "poslati"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f91b7bc8-fb3c-58c1-afcb-c027283ea35e', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('red') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('629fa843-1cc4-5d48-a279-6786df97beae', 'type_answer', 'Напишіть хорватською: «черга»', 'red', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '629fa843-1cc4-5d48-a279-6786df97beae', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('pošta') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('da6f4775-eb5c-5e9a-ad96-b1b1789be935', 'type_answer', 'Напишіть хорватською: «пошта»', 'pošta', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'da6f4775-eb5c-5e9a-ad96-b1b1789be935', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('decc5a5d-aa2b-5c22-8438-7888f6a47896', 'sentence_builder', 'Складіть: «Я хочу надіслати цю посилку в Україну.»', 'Želim poslati ovaj paket u Ukrajinu.', '["ovaj", "paket", "Želim", "u", "poslati", "Ukrajinu."]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'decc5a5d-aa2b-5c22-8438-7888f6a47896', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('3f86575a-e3c5-5d59-9f78-310daf7b3d93', 'sentence_builder', 'Складіть: «Тут поблизу є якийсь банкомат?»', 'Ima li ovdje blizu neki bankomat?', '["bankomat?", "ovdje", "li", "Ima", "blizu", "neki"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3f86575a-e3c5-5d59-9f78-310daf7b3d93', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a60395d5-4cf6-59e2-8eec-66f05b57e2ad', 'listening', 'Прослухайте і складіть фразу', 'Oko deset dana.', '["Oko", "dana.", "deset"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a60395d5-4cf6-59e2-8eec-66f05b57e2ad', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('af281d9c-cfa5-565b-bf3d-ac4085e63d9f', 'listening', 'Прослухайте і складіть фразу', 'Nije, dvije minute pješice.', '["Nije,", "dvije", "pješice.", "minute"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'af281d9c-cfa5-565b-bf3d-ac4085e63d9f', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fd7c1990-b037-50e5-92af-b3287e87901e', 'speaking', 'Де найближча пошта?', 'Gdje je najbliža pošta?', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fd7c1990-b037-50e5-92af-b3287e87901e', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('35d6f393-fab6-53d5-be99-841b599fc9e9', 'speaking', 'Я хочу відкрити рахунок.', 'Želim otvoriti račun.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '35d6f393-fab6-53d5-be99-841b599fc9e9', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('315b0e9a-e716-5d36-b70e-18cc134885bd', v_lesson, 'На пошті', 'Na pošti', 1461, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9ed287ac-2ca7-5f40-941a-780ff7416b4f', '315b0e9a-e716-5d36-b70e-18cc134885bd', 'Službenica', 'Sljedeći, molim.', 'Наступний, будь ласка.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9b076c9d-a92b-5a47-8b18-5f353d01d7d6', '315b0e9a-e716-5d36-b70e-18cc134885bd', 'Taras', 'Želim poslati ovaj paket u Ukrajinu.', 'Я хочу надіслати цю посилку в Україну.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6c2c57fd-ac91-50c9-9cce-b77578193010', '315b0e9a-e716-5d36-b70e-18cc134885bd', 'Službenica', 'Ispunite ovaj obrazac, molim.', 'Заповніть цей бланк, будь ласка.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('13c446a8-c23c-5961-bf29-6530a0e96366', '315b0e9a-e716-5d36-b70e-18cc134885bd', 'Taras', 'Koliko dugo putuje?', 'Скільки часу вона йде?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ba712d0e-96a1-578d-b18d-6d6d5ad4d082', '315b0e9a-e716-5d36-b70e-18cc134885bd', 'Službenica', 'Oko deset dana.', 'Близько десяти днів.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('54c57bec-9cf4-58a3-857a-f3125c5b348f', v_lesson, 'Де банкомат?', 'Gdje je bankomat?', 1462, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1c2e2eef-7b2b-5d2b-8286-2f3b8209facc', '54c57bec-9cf4-58a3-857a-f3125c5b348f', 'Olena', 'Oprostite, ima li ovdje blizu neki bankomat?', 'Вибачте, тут поблизу є якийсь банкомат?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5afcf091-1668-550b-8f60-7e815c1d3146', '54c57bec-9cf4-58a3-857a-f3125c5b348f', 'Prolaznik', 'Ima, kod banke, preko puta pošte.', 'Є, біля банку, навпроти пошти.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f8882c82-4b5c-56c5-8834-74c7c9ccda06', '54c57bec-9cf4-58a3-857a-f3125c5b348f', 'Olena', 'Je li daleko od tržnice?', 'Це далеко від ринку?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1e7c6392-d25b-5d63-b868-64708579afec', '54c57bec-9cf4-58a3-857a-f3125c5b348f', 'Prolaznik', 'Nije, dvije minute pješice.', 'Ні, дві хвилини пішки.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 47: Моє життя в Хорватії
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.10: місце уроку 3 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '6ba7fa0f-46cc-5679-85bb-23c1329bfa18';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.10.3'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 47: Моє життя в Хорватії', 'Lekcija 47: Moj život u Hrvatskoj', '["Розповісти про свої плани на літо", "Сказати, що у вас уже є в Хорватії", "Підсумувати, що ви вмієте хорватською"]'::jsonb, 12, 'PUBLISHED', 3);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('život') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'život'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('grad') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'grad'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prijatelj') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prijatelj'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('more') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'more'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dolaziti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dolaziti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('doći') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'doći'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ići') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ići'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('htjeti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'htjeti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('posjetiti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'posjetiti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sretan') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sretan'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zajedno') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zajedno'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pokazati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pokazati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('7b7200e0-3c6e-54a1-9ad2-d27d6326ad79', 'fill_in_the_blank', 'Moja mama ___ k meni.', 'dolazi', '["dolaze", "dolazi", "dolaziš", "dolazim"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7b7200e0-3c6e-54a1-9ad2-d27d6326ad79', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('život') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('546ae909-fcaf-5388-a72b-a59e78fa16cf', 'multiple_choice', 'Що означає «život»?', 'життя', '["життя", "хотіти", "щасливий", "приходити"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '546ae909-fcaf-5388-a72b-a59e78fa16cf', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sretan') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('bf3d40a1-612b-55e2-868e-760eaa41c090', 'multiple_choice', 'Що означає «sretan»?', 'щасливий', '["життя", "щасливий", "друг", "море"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'bf3d40a1-612b-55e2-868e-760eaa41c090', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zajedno') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('12939ac8-3e5e-52f3-9b5e-68785f19ac24', 'multiple_choice', 'Як хорватською «разом»?', 'zajedno', '["pokazati", "ići", "život", "zajedno"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '12939ac8-3e5e-52f3-9b5e-68785f19ac24', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('grad') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('141d81b5-f1bf-5396-9f79-a74417e36c8a', 'type_answer', 'Напишіть хорватською: «місто»', 'grad', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '141d81b5-f1bf-5396-9f79-a74417e36c8a', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('doći') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('083ab7d7-f632-565d-a4fe-a966b6836fec', 'type_answer', 'Напишіть хорватською: «прийти»', 'doći', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '083ab7d7-f632-565d-a4fe-a966b6836fec', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('70e643d1-90a4-59f1-bcea-e93dca02fb23', 'sentence_builder', 'Складіть: «Моя мама приїжджає до мене.»', 'Moja mama dolazi k meni.', '["k", "Moja", "meni.", "mama", "dolazi"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '70e643d1-90a4-59f1-bcea-e93dca02fb23', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('63e5500d-1f7f-5987-b331-e8c07fbd1bf3', 'sentence_builder', 'Складіть: «Щодня розумію більше.»', 'Svaki dan razumijem više.', '["više.", "Svaki", "dan", "razumijem"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '63e5500d-1f7f-5987-b331-e8c07fbd1bf3', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('78d34f96-ace8-59d4-a9f8-6b005fcc955c', 'listening', 'Прослухайте і складіть фразу', 'Super! Što želite vidjeti?', '["želite", "vidjeti?", "Što", "Super!"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '78d34f96-ace8-59d4-a9f8-6b005fcc955c', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('322355da-de1a-5fa9-834f-921e8d546626', 'listening', 'Прослухайте і складіть фразу', 'Jesam. Imam posao, stan i prijatelje.', '["stan", "Jesam.", "i", "posao,", "prijatelje.", "Imam"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '322355da-de1a-5fa9-834f-921e8d546626', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('398b2d78-b9a4-5a01-b9d3-c280a78cc94b', 'speaking', 'Мені тут добре.', 'Dobro mi je ovdje.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '398b2d78-b9a4-5a01-b9d3-c280a78cc94b', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('76e410e0-8454-5b7c-878a-5fe8c94f99d0', 'speaking', 'Тепер я можу розмовляти хорватською.', 'Sada mogu razgovarati na hrvatskom.', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '76e410e0-8454-5b7c-878a-5fe8c94f99d0', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1827ec73-ba93-5991-b4ad-597db8705634', v_lesson, 'Плани на літо', 'Planovi za ljeto', 1471, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d7549f9f-baf5-56f1-9679-694cbab4cb8c', '1827ec73-ba93-5991-b4ad-597db8705634', 'Ivan', 'Ideš li ljeti u Ukrajinu?', 'Ти їдеш улітку в Україну?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0e9fdc4a-dea3-5133-927c-3cfe386f2f7f', '1827ec73-ba93-5991-b4ad-597db8705634', 'Iryna', 'Ne idem. Moja mama dolazi k meni.', 'Ні. Моя мама приїжджає до мене.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('66f18a6d-1644-59f6-895a-8d1ed8b597de', '1827ec73-ba93-5991-b4ad-597db8705634', 'Ivan', 'Super! Što želite vidjeti?', 'Чудово! Що ви хочете побачити?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('427589e7-148a-531f-8633-1978a3e963aa', '1827ec73-ba93-5991-b4ad-597db8705634', 'Iryna', 'Želim joj pokazati Plitvice i more.', 'Хочу показати їй Плітвіце й море.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2a2fb11b-a27a-5784-b2ae-a0066e4eed09', '1827ec73-ba93-5991-b4ad-597db8705634', 'Ivan', 'Ako hoćete, mogu vas voziti.', 'Якщо хочете, можу вас повозити.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('abc34f51-8f2f-5121-a748-8ff6a048e6f3', v_lesson, 'Рік у Хорватії', 'Godina u Hrvatskoj', 1472, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('73b49471-5d2a-5067-a80b-46278896b2be', 'abc34f51-8f2f-5121-a748-8ff6a048e6f3', 'Ana', 'Jesi li sretna ovdje?', 'Ти щаслива тут?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('35de419d-10da-53b8-9270-b40847e7d3e0', 'abc34f51-8f2f-5121-a748-8ff6a048e6f3', 'Iryna', 'Jesam. Imam posao, stan i prijatelje.', 'Так. У мене є робота, квартира й друзі.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f80a399a-7451-59c7-ae1e-1c240fca4452', 'abc34f51-8f2f-5121-a748-8ff6a048e6f3', 'Ana', 'A jezik?', 'А мова?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5d6286f7-03c3-53bf-a46c-eaf9e24a5de9', 'abc34f51-8f2f-5121-a748-8ff6a048e6f3', 'Iryna', 'Svaki dan razumijem više. Sada mogu razgovarati s tobom!', 'Щодня розумію більше. Тепер можу розмовляти з тобою!', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 48: Дитячий садок і школа
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '42c31cfb-8680-5450-8453-245f3abd475a';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.10: місце уроку 4 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = 'd27ae527-a8d6-512f-acd2-a6cfec39c01f';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.10.4'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 48: Дитячий садок і школа', 'Lekcija 48: Vrtić i škola', '["Записати дитину в садок", "Знати, які документи потрібні", "Поговорити з учителькою"]'::jsonb, 12, 'PUBLISHED', 4);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('vrtić') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vrtić'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('upisati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'upisati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rodni list') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rodni list'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('cijepljenje') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'cijepljenje'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('mjesto') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'mjesto'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ravnateljica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ravnateljica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('učenica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'učenica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zadaća') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zadaća'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('slabo') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'slabo'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('produženi boravak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'produženi boravak'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('roditeljski sastanak') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'roditeljski sastanak'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('učiteljica') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'učiteljica'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('755482e7-c777-53ca-b131-e6eb384275ea', 'fill_in_the_blank', 'Ima li ___ u vrtiću?', 'mjesta', '["mjestom", "mjesta", "mjesto", "mjestu"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '755482e7-c777-53ca-b131-e6eb384275ea', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('učiteljica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('888ca97e-55eb-557c-85f5-da4fcb143b05', 'multiple_choice', 'Що означає «učiteljica»?', 'учителька', '["слабо; погано", "дитячий садок", "учителька", "домашнє завдання"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '888ca97e-55eb-557c-85f5-da4fcb143b05', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zadaća') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b82923bb-5ae1-5494-8a3a-bdefbba49ae8', 'multiple_choice', 'Що означає «zadaća»?', 'домашнє завдання', '["директорка (школи, садка)", "дитячий садок", "місце", "домашнє завдання"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b82923bb-5ae1-5494-8a3a-bdefbba49ae8', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('cijepljenje') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('25e2ff9c-39f9-52e9-a4ca-98f161069470', 'multiple_choice', 'Як хорватською «щеплення»?', 'cijepljenje', '["rodni list", "učiteljica", "vrtić", "cijepljenje"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '25e2ff9c-39f9-52e9-a4ca-98f161069470', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ravnateljica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('76e12f6e-a4d7-5eb3-b088-4a9e2727764b', 'type_answer', 'Напишіть хорватською: «директорка (школи, садка)»', 'ravnateljica', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '76e12f6e-a4d7-5eb3-b088-4a9e2727764b', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('učenica') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('1aa39a5b-be32-543b-8844-00178bb54a39', 'type_answer', 'Напишіть хорватською: «учениця»', 'učenica', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1aa39a5b-be32-543b-8844-00178bb54a39', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('77d040a9-1573-5d27-8f75-0c90c529d6a4', 'sentence_builder', 'Складіть: «Я хочу записати сина в садок.»', 'Želim upisati sina u vrtić.', '["Želim", "upisati", "u", "sina", "vrtić."]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '77d040a9-1573-5d27-8f75-0c90c529d6a4', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('205f968c-8afc-57de-b3c8-0c392824d6b0', 'sentence_builder', 'Складіть: «Коли батьківські збори?»', 'Kada je roditeljski sastanak?', '["je", "sastanak?", "roditeljski", "Kada"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '205f968c-8afc-57de-b3c8-0c392824d6b0', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f2fea7fa-b879-50be-89ec-6728c1fa42f0', 'listening', 'Прослухайте і складіть фразу', 'Četiri. Koji su dokumenti potrebni?', '["su", "Koji", "dokumenti", "Četiri.", "potrebni?"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f2fea7fa-b879-50be-89ec-6728c1fa42f0', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('22ca1450-f441-5899-899b-01e09139336a', 'listening', 'Прослухайте і складіть фразу', 'Hm. Ona još slabo čita hrvatski.', '["Ona", "slabo", "Hm.", "još", "čita", "hrvatski."]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '22ca1450-f441-5899-899b-01e09139336a', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('4db5bd53-0ffc-536c-89e6-58eedf33428f', 'speaking', 'Мій син ходить у садок.', 'Moj sin ide u vrtić.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4db5bd53-0ffc-536c-89e6-58eedf33428f', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('61d4613f-6d63-5c44-b855-11ff82898d87', 'speaking', 'Що задали додому?', 'Što je za zadaću?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '61d4613f-6d63-5c44-b855-11ff82898d87', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1eabbc55-0245-5d95-92be-00b4dd1f4b22', v_lesson, 'Запис у садок', 'Upis u vrtić', 1481, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('afc650f6-74c6-578d-a889-1bbc28de23e0', '1eabbc55-0245-5d95-92be-00b4dd1f4b22', 'Mama', 'Dobar dan, želim upisati sina u vrtić.', 'Добрий день, я хочу записати сина в садок.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('22da15b1-6fd1-55dd-be15-5dcb430497b4', '1eabbc55-0245-5d95-92be-00b4dd1f4b22', 'Ravnateljica', 'Koliko ima godina?', 'Скільки йому років?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b16aec0c-9907-5f91-a915-7e920611a784', '1eabbc55-0245-5d95-92be-00b4dd1f4b22', 'Mama', 'Četiri. Koji su dokumenti potrebni?', 'Чотири. Які документи потрібні?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2ca15bf5-da56-5962-a075-3ebbbb3790e9', '1eabbc55-0245-5d95-92be-00b4dd1f4b22', 'Ravnateljica', 'Rodni list, potvrda o cijepljenju i Vaš OIB.', 'Свідоцтво про народження, довідка про щеплення і ваш OIB.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('61356c00-84d3-5cf4-9706-8088d6fcf175', '1eabbc55-0245-5d95-92be-00b4dd1f4b22', 'Mama', 'Ima li mjesta od rujna?', 'Чи є місце з вересня?', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('81710b48-fe17-57cd-ae5f-db7f9ae87afe', v_lesson, 'Розмова з учителькою', 'Razgovor s učiteljicom', 1482, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f468a8dc-aa5b-5f2f-8ab5-81416c9cf488', '81710b48-fe17-57cd-ae5f-db7f9ae87afe', 'Učiteljica', 'Vaša kći je dobra učenica, ali ne piše zadaću.', 'Ваша донька хороша учениця, але не робить домашнього завдання.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9fd8605c-e01b-5b95-bb9b-896ae6e0fd7b', '81710b48-fe17-57cd-ae5f-db7f9ae87afe', 'Tata', 'Hm. Ona još slabo čita hrvatski.', 'Хм. Вона ще погано читає хорватською.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2f965722-658b-5ba9-b63a-fbd922259d99', '81710b48-fe17-57cd-ae5f-db7f9ae87afe', 'Učiteljica', 'Razumijem. Može ostati u produženom boravku i učiti s nama.', 'Розумію. Вона може лишатися на продовженому дні й вчитися з нами.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f99c6e8f-8ab9-530e-98ab-4e30d4d20c79', '81710b48-fe17-57cd-ae5f-db7f9ae87afe', 'Tata', 'Odlično, hvala. Kada je roditeljski sastanak?', 'Чудово, дякую. Коли батьківські збори?', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 49: У банку
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'fee5b77b-dc3b-5fd5-818a-c5496e95c23b';
  v_id uuid;
  v_gid uuid;
  v_pos int := 0;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A1' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A1.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.10: місце уроку 5 вже зайняте іншим уроком';
  end if;
  select id into v_gid from public.grammar_topics where id = '0db658cb-b2ed-5719-bced-f95a93cf15ce';
  if v_gid is null then raise exception 'Немає граматичної теми для уроку A1.10.5'; end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 49: У банку', 'Lekcija 49: U banci', '["Відкрити рахунок у банку", "Дізнатися про щомісячну плату", "Розблокувати картку"]'::jsonb, 12, 'PUBLISHED', 5);
  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('otvoriti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'otvoriti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tekući račun') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tekući račun'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('IBAN') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'IBAN'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('naknada') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'naknada'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dokaz') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dokaz'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dobiti') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dobiti'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('blokiran') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'blokiran'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('odblokirati') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'odblokirati'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('PIN') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'PIN'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('aplikacija') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'aplikacija'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('podići') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'podići'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kriv') and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kriv'; end if;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b1ed5867-bab9-5fb4-a4fb-3408cccc5cd4', 'fill_in_the_blank', 'Želim otvoriti ___ račun.', 'tekući', '["tekuća", "tekućem", "tekuće", "tekući"]'::jsonb, 'A1', 1, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b1ed5867-bab9-5fb4-a4fb-3408cccc5cd4', v_pos, 'grammar');
  select id into v_id from public.lexemes where lower(lemma) = lower('kriv') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('36454c24-b2a7-5371-8590-95bd98d2b768', 'multiple_choice', 'Що означає «kriv»?', 'неправильний / винний', '["неправильний / винний", "підняти; зняти гроші", "поточний рахунок у банку", "відчинити / відкрити"]'::jsonb, 'A1', 2, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '36454c24-b2a7-5371-8590-95bd98d2b768', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('PIN') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('b9ab92eb-436c-582c-95ad-182309e8fad7', 'multiple_choice', 'Що означає «PIN»?', 'PIN-код', '["PIN-код", "підняти; зняти гроші", "додаток (app)", "заблокований"]'::jsonb, 'A1', 3, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b9ab92eb-436c-582c-95ad-182309e8fad7', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('odblokirati') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('8cd80526-90e4-5711-bc7c-f68861342041', 'multiple_choice', 'Як хорватською «розблокувати»?', 'odblokirati', '["blokiran", "tekući račun", "odblokirati", "dobiti"]'::jsonb, 'A1', 4, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8cd80526-90e4-5711-bc7c-f68861342041', v_pos, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('aplikacija') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0288b8a2-0b2f-5c22-b491-f1e0d79b4eb7', 'type_answer', 'Напишіть хорватською: «додаток (app)»', 'aplikacija', null, 'A1', 5, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0288b8a2-0b2f-5c22-b491-f1e0d79b4eb7', v_pos, 'writing');
  select id into v_id from public.lexemes where lower(lemma) = lower('blokiran') and status = 'PUBLISHED' order by created_at limit 1;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('0017a12a-0f12-5c27-b40b-275118d7fa10', 'type_answer', 'Напишіть хорватською: «заблокований»', 'blokiran', null, 'A1', 6, 'PUBLISHED', v_id) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0017a12a-0f12-5c27-b40b-275118d7fa10', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('df5279dc-2bdf-52ea-9510-6d1a4a04f2ea', 'sentence_builder', 'Складіть: «Я хочу відкрити поточний рахунок.»', 'Želim otvoriti tekući račun.', '["tekući", "otvoriti", "račun.", "Želim"]'::jsonb, 'A1', 7, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'df5279dc-2bdf-52ea-9510-6d1a4a04f2ea', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('85ef62aa-d8df-5035-a6d7-7ac8b088d6a2', 'sentence_builder', 'Складіть: «Моя картка не працює.»', 'Moja kartica ne radi.', '["kartica", "radi.", "ne", "Moja"]'::jsonb, 'A1', 8, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '85ef62aa-d8df-5035-a6d7-7ac8b088d6a2', v_pos, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('05003b98-5322-5f67-991d-be0442cc3919', 'listening', 'Прослухайте і складіть фразу', 'Kolika je mjesečna naknada?', '["Kolika", "naknada?", "mjesečna", "je"]'::jsonb, 'A1', 9, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '05003b98-5322-5f67-991d-be0442cc3919', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('fbb65d34-5895-54c9-8471-8820a7abc742', 'listening', 'Прослухайте і складіть фразу', 'Možete li je odblokirati?', '["li", "je", "Možete", "odblokirati?"]'::jsonb, 'A1', 10, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fbb65d34-5895-54c9-8471-8820a7abc742', v_pos, 'listening');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('f196812a-ede5-5dcc-88ac-a11687f2c170', 'speaking', 'Мені потрібно зняти гроші.', 'Trebam podići novac.', null, 'A1', 11, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f196812a-ede5-5dcc-88ac-a11687f2c170', v_pos, 'speaking');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values ('a8c3c2b4-3b60-5fd2-b4f5-2415a5fcddca', 'speaking', 'Який ваш IBAN?', 'Koji je Vaš IBAN?', null, 'A1', 12, 'PUBLISHED', null) on conflict (id) do nothing;
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a8c3c2b4-3b60-5fd2-b4f5-2415a5fcddca', v_pos, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('38f0ec41-eee4-5deb-8b81-53deefbb3803', v_lesson, 'Відкрити рахунок', 'Otvaranje računa', 1491, 'A1', 'bank', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2afc28a7-6f4c-5033-b9c2-2fb3a292d0d9', '38f0ec41-eee4-5deb-8b81-53deefbb3803', 'Službenica', 'Izvolite, kako Vam mogu pomoći?', 'Прошу, чим можу допомогти?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('44f63f1c-9066-5120-8d1a-82c12162bad3', '38f0ec41-eee4-5deb-8b81-53deefbb3803', 'Andrij', 'Želim otvoriti tekući račun.', 'Я хочу відкрити поточний рахунок.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('fb8cba19-c6fb-5b63-b2b6-5a41233eac3d', '38f0ec41-eee4-5deb-8b81-53deefbb3803', 'Službenica', 'Trebam Vašu putovnicu, OIB i dokaz o adresi.', 'Мені потрібні ваш паспорт, OIB і підтвердження адреси.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a7cea101-5c19-5152-a783-005b4cb5d1d0', '38f0ec41-eee4-5deb-8b81-53deefbb3803', 'Andrij', 'Kolika je mjesečna naknada?', 'Яка щомісячна плата?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3a8a920c-e645-5f73-9c30-a10d97e14c5c', '38f0ec41-eee4-5deb-8b81-53deefbb3803', 'Službenica', 'Dva eura. Karticu dobivate za deset dana.', 'Два євро. Картку отримаєте за десять днів.', 5) on conflict (id) do nothing;
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('58dc6c16-4c46-5746-a966-3381c61ec43d', v_lesson, 'Картку заблоковано', 'Kartica je blokirana', 1492, 'A1', 'bank', 'PUBLISHED', 'claude_curriculum_a1_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('89fc72bb-ec2a-5ebe-9481-1e14456b4ad2', '58dc6c16-4c46-5746-a966-3381c61ec43d', 'Oksana', 'Moja kartica ne radi. Bankomat ne daje novac.', 'Моя картка не працює. Банкомат не видає гроші.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('27a8b4f0-f572-5a2a-b66e-db9d151a7490', '58dc6c16-4c46-5746-a966-3381c61ec43d', 'Službenik', 'Kartica je blokirana zbog krivog PIN-a.', 'Картку заблоковано через неправильний PIN.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f89a8e3e-e523-5695-8cc4-af866e4d2f73', '58dc6c16-4c46-5746-a966-3381c61ec43d', 'Oksana', 'Možete li je odblokirati?', 'Можете її розблокувати?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('37968c0a-832b-562d-848e-0fec3021917b', '58dc6c16-4c46-5746-a966-3381c61ec43d', 'Službenik', 'Mogu. Novi PIN dobivate u aplikaciji.', 'Можу. Новий PIN отримаєте в застосунку.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.');
end $$;

-- 6. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare
  v_modules int; v_lessons int; v_short int; v_scenes int; v_grammar int; v_rules int;
begin
  select count(*) into v_modules from public.modules where level_code = 'A1' and status = 'PUBLISHED';
  select count(*) into v_lessons from public.lessons where level_code = 'A1' and status = 'PUBLISHED';
  select count(*) into v_short from public.lessons l where l.level_code = 'A1'
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') < 12;
  select count(*) into v_scenes from public.lessons l where l.level_code = 'A1'
     and (select count(*) from public.conversations c where c.lesson_id = l.id) < 2;
  select count(*) into v_grammar from public.grammar_topics where cefr = 'A1' and status = 'PUBLISHED';
  select count(*) into v_rules from public.grammar_topics g where g.cefr = 'A1'
     and not exists (select 1 from public.grammar_rules r where r.topic_id = g.id);
  if v_modules < 10 then raise exception 'A1: модулів %, очікувалось 10', v_modules; end if;
  if v_lessons < 49 then raise exception 'A1: уроків %, очікувалось 49', v_lessons; end if;
  if v_short > 0 then raise exception 'A1: % уроків мають менше 12 вправ', v_short; end if;
  if v_scenes > 0 then raise exception 'A1: % уроків без двох діалогів', v_scenes; end if;
  if v_grammar < 13 or v_rules > 0 then raise exception 'A1: граматика — тем %, без правил %', v_grammar, v_rules; end if;
  raise notice 'Готово: A1 — % модулів, % уроків, % граматичних тем', v_modules, v_lessons, v_grammar;
end $$;

commit;

-- Перевірка (окремим запитом після запуску):
-- select m.order_index as модуль, m.title_ua, count(l.id) as уроків
-- from public.modules m join public.units u on u.module_id = m.id
-- left join public.lessons l on l.unit_id = u.id
-- where m.level_code = 'A1' group by m.order_index, m.title_ua order by 1;
