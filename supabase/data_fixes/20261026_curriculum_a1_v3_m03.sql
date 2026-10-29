-- =====================================================================
-- Програма A1 v3 · модуль A1.3 «Покупки» · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_curriculum_a1_v3.py 3 (не редагуйте вручну).
--
-- Рішення власника 2026-10-21 / 2026-10-26: до 25 слів на урок — скільки потрібно темі, 90–95 % слів — нові для рівня,
-- діалоги під тему, частіше Даша / Дар’я; бета (PUBLISHED).
--   * Уроки 22–29: 5 наявних перебудовано, 3 нових. Слів у них: 137.
--     Кожен: 10–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 68.
--   * Нові теми граматики: «Короткі форми давального: sviđa mi se».
--   * Нові правила до тем: «Знахідний відмінок» (+1), «Ступені порівняння» (+1).
--   * Виправлено: svidjeti se — «сподобатися»; stajati — «стояти; коштувати; личити (stoji ti dobro)»; odgovarati — «відповідати; підходити (за розміром, часом)»; isti — «той самий; однаковий» (стара версія — у content_versions).
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

-- 1. Нові слова й вирази A1.3 (68; наявні не змінюються)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ukus', 'ukus', 'hr', 'noun', 'A1', 'смак (у виборі), уподобання', 'core', '{"gender": "m"}'::jsonb, '["Ta haljina nije po mom ukusu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stil', 'stil', 'hr', 'noun', 'A1', 'стиль', 'core', '{"gender": "m"}'::jsonb, '["Sviđa mi se tvoj stil."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('staromodan', 'staromodan', 'hr', 'adjective', 'A1', 'старомодний', 'core', '{"f": "staromodna", "n": "staromodno"}'::jsonb, '["Ovaj kaput je malo staromodan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('elegantan', 'elegantan', 'hr', 'adjective', 'A1', 'елегантний', 'core', '{"f": "elegantna", "n": "elegantno"}'::jsonb, '["Za vjenčanje trebam elegantnu haljinu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ležeran', 'lezeran', 'hr', 'adjective', 'A1', 'невимушений, повсякденний (про одяг, стиль)', 'core', '{"f": "ležerna", "n": "ležerno"}'::jsonb, '["Petkom na posao nosim ležernu odjeću."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('predivan', 'predivan', 'hr', 'adjective', 'A1', 'чудовий, прекрасний', 'core', '{"f": "predivna", "n": "predivno"}'::jsonb, '["Kakav predivan šal!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('grozan', 'grozan', 'hr', 'adjective', 'A1', 'жахливий', 'core', '{"f": "grozna", "n": "grozno"}'::jsonb, '["Ta boja mi je grozna."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uzorak', 'uzorak', 'hr', 'noun', 'A1', 'візерунок; зразок', 'core', '{"gender": "m"}'::jsonb, '["Sviđa mi se uzorak na ovoj košulji."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kabanica', 'kabanica', 'hr', 'noun', 'A1', 'дощовик (плащ від дощу)', 'core', '{"gender": "f"}'::jsonb, '["Kad pada kiša, djeca nose kabanice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prsluk', 'prsluk', 'hr', 'noun', 'A1', 'жилет, безрукавка', 'core', '{"gender": "m"}'::jsonb, '["Ujutro je hladno, obuci prsluk."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kratke hlače', 'kratke hlace', 'hr', 'phrase', 'A1', 'шорти', 'collocation', '{"gender": "f_pl"}'::jsonb, '["Ljeti nosim kratke hlače."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kupaći kostim', 'kupaci kostim', 'hr', 'phrase', 'A1', 'купальник', 'collocation', '{"gender": "m"}'::jsonb, '["Ne zaboravi kupaći kostim!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('trenirka', 'trenirka', 'hr', 'noun', 'A1', 'спортивний костюм', 'core', '{"gender": "f"}'::jsonb, '["Kod kuće nosim trenirku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pamuk', 'pamuk', 'hr', 'noun', 'A1', 'бавовна', 'core', '{"gender": "m"}'::jsonb, '["Ova majica je od pamuka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zimski', 'zimski', 'hr', 'adjective', 'A1', 'зимовий', 'core', '{"f": "zimska", "n": "zimsko"}'::jsonb, '["Trebam nove zimske čizme."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ljetni', 'ljetni', 'hr', 'adjective', 'A1', 'літній', 'core', '{"f": "ljetna", "n": "ljetno"}'::jsonb, '["Tražim laganu ljetnu haljinu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tijesan', 'tijesan', 'hr', 'adjective', 'A1', 'тісний', 'core', '{"f": "tijesna", "n": "tijesno"}'::jsonb, '["Ove cipele su mi tijesne."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('labav', 'labav', 'hr', 'adjective', 'A1', 'вільний, завеликий (про одяг); хиткий', 'core', '{"f": "labava", "n": "labavo"}'::jsonb, '["Hlače su mi labave u struku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rukav', 'rukav', 'hr', 'noun', 'A1', 'рукав', 'core', '{"gender": "m"}'::jsonb, '["Rukavi su mi predugi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nogavica', 'nogavica', 'hr', 'noun', 'A1', 'холоша (штанина)', 'core', '{"gender": "f"}'::jsonb, '["Nogavice su preduge, treba ih skratiti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('džep', 'dzep', 'hr', 'noun', 'A1', 'кишеня', 'core', '{"gender": "m"}'::jsonb, '["Ključ je u džepu jakne."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gumb', 'gumb', 'hr', 'noun', 'A1', 'ґудзик; кнопка', 'core', '{"gender": "m"}'::jsonb, '["Na košulji nedostaje jedan gumb."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('patentni zatvarač', 'patentni zatvarac', 'hr', 'phrase', 'A1', 'застібка-блискавка', 'collocation', '{"gender": "m"}'::jsonb, '["Patentni zatvarač na jakni ne radi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ovratnik', 'ovratnik', 'hr', 'noun', 'A1', 'комір', 'core', '{"gender": "m"}'::jsonb, '["Ova košulja ima uski ovratnik."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kroj', 'kroj', 'hr', 'noun', 'A1', 'крій, фасон', 'core', '{"gender": "m"}'::jsonb, '["Kroj ove haljine je jednostavan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('skratiti', 'skratiti', 'hr', 'verb', 'A1', 'укоротити; скоротити', 'core', '{"aspect": "pfv", "present": {"1s": "skratim", "2s": "skratiš", "3s": "skrati"}}'::jsonb, '["Možete li mi skratiti hlače?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('krojačica', 'krojacica', 'hr', 'noun', 'A1', 'кравчиня', 'core', '{"gender": "f"}'::jsonb, '["Krojačica radi u ulici pored tržnice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('regenerator', 'regenerator', 'hr', 'noun', 'A1', 'бальзам-ополіскувач для волосся', 'core', '{"gender": "m"}'::jsonb, '["Nakon šampona stavljam regenerator."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gel za tuširanje', 'gel za tusiranje', 'hr', 'phrase', 'A1', 'гель для душу', 'collocation', '{"gender": "m"}'::jsonb, '["Ovaj gel za tuširanje lijepo miriše."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dezodorans', 'dezodorans', 'hr', 'noun', 'A1', 'дезодорант', 'core', '{"gender": "m"}'::jsonb, '["Kupi mi dezodorans bez alkohola."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('parfem', 'parfem', 'hr', 'noun', 'A1', 'парфуми', 'core', '{"gender": "m"}'::jsonb, '["Mama za rođendan želi novi parfem."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('krema za sunčanje', 'krema za suncanje', 'hr', 'phrase', 'A1', 'сонцезахисний крем', 'collocation', '{"gender": "f"}'::jsonb, '["Na plaži djeci stavljam kremu za sunčanje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('šminka', 'sminka', 'hr', 'noun', 'A1', 'макіяж; декоративна косметика', 'core', '{"gender": "f"}'::jsonb, '["Na posao nosim malo šminke."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ruž za usne', 'ruz za usne', 'hr', 'phrase', 'A1', 'губна помада', 'collocation', '{"gender": "m"}'::jsonb, '["Tražim crveni ruž za usne."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('maskara', 'maskara', 'hr', 'noun', 'A1', 'туш для вій', 'core', '{"gender": "f"}'::jsonb, '["Maskara mi je u torbici."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('lak za nokte', 'lak za nokte', 'hr', 'phrase', 'A1', 'лак для нігтів', 'collocation', '{"gender": "m"}'::jsonb, '["Imate li ovaj lak za nokte u ružičastoj boji?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('britvica', 'britvica', 'hr', 'noun', 'A1', 'бритва (станок)', 'core', '{"gender": "f"}'::jsonb, '["Trebam nove britvice za brijanje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vlažne maramice', 'vlazne maramice', 'hr', 'phrase', 'A1', 'вологі серветки', 'collocation', '{"gender": "f_pl"}'::jsonb, '["U torbi uvijek imam vlažne maramice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('omekšivač', 'omeksivac', 'hr', 'noun', 'A1', 'кондиціонер (ополіскувач) для білизни', 'core', '{"gender": "m"}'::jsonb, '["Stavi omekšivač u perilicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zlatarna', 'zlatarna', 'hr', 'noun', 'A1', 'ювелірний магазин', 'core', '{"gender": "f"}'::jsonb, '["Zlatarna je pored ljekarne."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('lančić', 'lancic', 'hr', 'noun', 'A1', 'ланцюжок', 'core', '{"gender": "m"}'::jsonb, '["Nosi tanki zlatni lančić."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('privjesak', 'privjesak', 'hr', 'noun', 'A1', 'кулон, підвіска; брелок', 'core', '{"gender": "m"}'::jsonb, '["Na lančiću je mali privjesak u obliku srca."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ručni sat', 'rucni sat', 'hr', 'phrase', 'A1', 'наручний годинник', 'collocation', '{"gender": "m"}'::jsonb, '["Tati kupujem ručni sat."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zlato', 'zlato', 'hr', 'noun', 'A1', 'золото', 'core', '{"gender": "n"}'::jsonb, '["Ovaj prsten je od zlata."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('srebro', 'srebro', 'hr', 'noun', 'A1', 'срібло', 'core', '{"gender": "n"}'::jsonb, '["Naušnice su od srebra."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zamotati', 'zamotati', 'hr', 'verb', 'A1', 'загорнути, запакувати', 'core', '{"aspect": "pfv", "present": {"1s": "zamotam", "2s": "zamotaš", "3s": "zamota"}}'::jsonb, '["Možete li zamotati poklon?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ukrasni papir', 'ukrasni papir', 'hr', 'phrase', 'A1', 'подарунковий (пакувальний) папір', 'collocation', '{"gender": "m"}'::jsonb, '["Poklon zamotamo u ukrasni papir."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vrpca', 'vrpca', 'hr', 'noun', 'A1', 'стрічка', 'core', '{"gender": "f"}'::jsonb, '["Na poklonu je crvena vrpca."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('poklon bon', 'poklon bon', 'hr', 'phrase', 'A1', 'подарунковий сертифікат', 'collocation', '{"gender": "m"}'::jsonb, '["Za rođendan joj dajemo poklon bon."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kvalitetan', 'kvalitetan', 'hr', 'adjective', 'A1', 'якісний', 'core', '{"f": "kvalitetna", "n": "kvalitetno"}'::jsonb, '["Ove cipele su skupe, ali kvalitetne."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('trajan', 'trajan', 'hr', 'adjective', 'A1', 'довговічний, міцний', 'core', '{"f": "trajna", "n": "trajno"}'::jsonb, '["Treba mi trajan ruksak za školu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('povoljan', 'povoljan', 'hr', 'adjective', 'A1', 'вигідний, недорогий', 'core', '{"f": "povoljna", "n": "povoljno"}'::jsonb, '["U ovoj trgovini su cijene povoljne."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('neispravan', 'neispravan', 'hr', 'adjective', 'A1', 'несправний, бракований', 'core', '{"f": "neispravna", "n": "neispravno"}'::jsonb, '["Punjač je neispravan, uopće ne puni."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pokvariti se', 'pokvariti se', 'hr', 'verb', 'A1', 'зламатися, зіпсуватися', 'core', '{"aspect": "pfv", "present": {"1s": "pokvarim se", "2s": "pokvariš se", "3s": "pokvari se"}}'::jsonb, '["Ako se perilica pokvari, zovemo majstora."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ogrebotina', 'ogrebotina', 'hr', 'noun', 'A1', 'подряпина', 'core', '{"gender": "f"}'::jsonb, '["Na ekranu je mala ogrebotina."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mrlja', 'mrlja', 'hr', 'noun', 'A1', 'пляма', 'core', '{"gender": "f"}'::jsonb, '["Na košulji je mrlja od kave."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rupa', 'rupa', 'hr', 'noun', 'A1', 'дірка, отвір', 'core', '{"gender": "f"}'::jsonb, '["Na čarapi je rupa."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('etiketa', 'etiketa', 'hr', 'noun', 'A1', 'етикетка, бирка', 'core', '{"gender": "f"}'::jsonb, '["Ne skidajte etiketu ako želite vratiti robu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('originalno pakiranje', 'originalno pakiranje', 'hr', 'phrase', 'A1', 'оригінальна упаковка', 'collocation', '{"gender": "n"}'::jsonb, '["Robu vratite u originalnom pakiranju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rok za povrat', 'rok za povrat', 'hr', 'phrase', 'A1', 'термін повернення (товару)', 'collocation', '{"gender": "m"}'::jsonb, '["Rok za povrat je trideset dana."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zamjena', 'zamjena', 'hr', 'noun', 'A1', 'заміна; обмін (товару)', 'core', '{"gender": "f"}'::jsonb, '["Želim zamjenu za veći broj."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('služba za korisnike', 'sluzba za korisnike', 'hr', 'phrase', 'A1', 'служба підтримки клієнтів', 'collocation', '{"gender": "f"}'::jsonb, '["Za reklamaciju nazovite službu za korisnike."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dodati u košaricu', 'dodati u kosaricu', 'hr', 'phrase', 'A1', 'додати в кошик', 'collocation', '{"aspect": "pfv", "present": {"1s": "dodam u košaricu", "2s": "dodaš u košaricu", "3s": "doda u košaricu"}}'::jsonb, '["Odaberi veličinu i dodaj tenisice u košaricu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('na zalihi', 'na zalihi', 'hr', 'phrase', 'A1', 'у наявності (на складі)', 'chunk', '{}'::jsonb, '["Je li ova veličina na zalihi?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kod za popust', 'kod za popust', 'hr', 'phrase', 'A1', 'промокод, код знижки', 'collocation', '{"gender": "m"}'::jsonb, '["Upiši kod za popust prije plaćanja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('besplatna dostava', 'besplatna dostava', 'hr', 'phrase', 'A1', 'безкоштовна доставка', 'collocation', '{"gender": "f"}'::jsonb, '["Za narudžbe iznad pedeset eura dostava je besplatna."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('adresa za dostavu', 'adresa za dostavu', 'hr', 'phrase', 'A1', 'адреса доставки', 'collocation', '{"gender": "f"}'::jsonb, '["Provjeri adresu za dostavu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('recenzija', 'recenzija', 'hr', 'noun', 'A1', 'відгук (про товар); рецензія', 'core', '{"gender": "f"}'::jsonb, '["Prije kupnje čitam recenzije."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;

-- 1б. Виправлені слова (4); повторний запуск нічого не змінює
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'svidjeti se' and ukrainian_translation = 'подобатися' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'сподобатися' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'stajati' and ukrainian_translation = 'коштувати, стояти' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'стояти; коштувати; личити (stoji ti dobro)' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'odgovarati' and ukrainian_translation = 'відповідати' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'відповідати; підходити (за розміром, часом)' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'isti' and ukrainian_translation = 'однаковий' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'той самий; однаковий' where id = r.id;
  end loop;
end $$;

-- 1а. Граматика A1.3: нові теми (1) і нові правила до наявних тем (2)
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '8e4a02a1-af3e-5224-9ddc-cf22440d7e00', 'A1', 'Короткі форми давального: sviđa mi se', 'Kratki oblici dativa: sviđa mi se', 'Короткі займенники mi, ti, mu, joj, nam, vam, im (кому?) у частих виразах: sviđa mi se, treba mi, stoji ti, žao mi je; їхнє місце в реченні.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Короткі форми давального: sviđa mi se');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '69d33b3a-f0d4-5cab-9d7b-480164772b43', '8e4a02a1-af3e-5224-9ddc-cf22440d7e00', 'Mi, ti, mu, joj — «мені, тобі, йому, їй»', 'Давальний відмінок відповідає на питання komu? — кому? Короткі форми займенників: mi (мені), ti (тобі), mu (йому), joj (їй), nam (нам), vam (вам), im (їм). Повні форми — meni, tebi, njemu, njoj, nama, vama, njima — для наголосу, протиставлення й на початку речення: Meni se sviđa, a tebi?', 'ja → mi · ti → ti · on → mu · ona → joj · mi → nam · vi → vam · oni → im', '[{"hr": "Kupujem mu poklon.", "ua": "Я купую йому подарунок."}, {"hr": "Pomažem joj s torbama.", "ua": "Я допомагаю їй із сумками."}, {"hr": "Dajte nam račun, molim.", "ua": "Дайте нам рахунок, будь ласка."}, {"hr": "Meni se sviđa, a tebi?", "ua": "Мені подобається, а тобі?"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '8e4a02a1-af3e-5224-9ddc-cf22440d7e00')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'a9380168-6062-5194-8864-d1458e3b3a83', '8e4a02a1-af3e-5224-9ddc-cf22440d7e00', 'Sviđa mi se — «мені подобається»', 'Як в українській: те, що подобається, — підмет, а людина — у давальному. Дієслово узгоджується з річчю: sviđa mi se haljina, sviđaju mi se cipele. Заперечення: ne sviđa mi se. Питання: Sviđa li ti se? Volim — «люблю», про те, що подобається завжди: Volim kavu.', 'sviđa mi se + однина · sviđaju mi se + множина', '[{"hr": "Sviđa mi se ova jakna.", "ua": "Мені подобається ця куртка."}, {"hr": "Sviđaju li ti se ove cipele?", "ua": "Тобі подобаються ці туфлі?"}, {"hr": "Ne sviđa mu se boja.", "ua": "Йому не подобається колір."}, {"hr": "Djeci se sviđa more.", "ua": "Дітям подобається море."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '8e4a02a1-af3e-5224-9ddc-cf22440d7e00')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'd91d5368-1186-53da-9a3b-841d5b8d14b8', '8e4a02a1-af3e-5224-9ddc-cf22440d7e00', 'Treba mi, stoji ti, žao mi je', 'Так само будуються інші часті вирази: treba mi (мені треба), stoji ti dobro (тобі личить), hladno mi je (мені холодно), žao mi je (мені шкода), dosadno mi je (мені нудно). Те, що треба або личить, — підмет: treba mi kruh, trebaju mi cipele, ta boja ti stoji.', 'treba mi + однина · trebaju mi + множина · dobro ti stoji', '[{"hr": "Treba mi veći broj.", "ua": "Мені потрібен більший розмір."}, {"hr": "Ta boja ti stvarno stoji.", "ua": "Цей колір тобі справді личить."}, {"hr": "Trebaju mi nove čizme.", "ua": "Мені потрібні нові чоботи."}, {"hr": "Žao mi je, nemamo vaš broj.", "ua": "На жаль, вашого розміру немає."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '8e4a02a1-af3e-5224-9ddc-cf22440d7e00')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'cfba351b-4b44-53c3-9c71-f4d8be03b3b7', '8e4a02a1-af3e-5224-9ddc-cf22440d7e00', 'Де стоять mi, ti, mu', 'Короткі форми стоять на другому місці в реченні, як se. Якщо є і se, спершу займенник: Sviđa mi se. Ne sviđa mu se. Kako ti stoji? Повна форма або іменник можуть стояти на початку: Meni se ne sviđa. Mami se sviđa srebro.', 'Sviđa mi se · Kako ti stoji? · Meni se ne sviđa', '[{"hr": "Kako mi stoji ova haljina?", "ua": "Як мені ця сукня?"}, {"hr": "Ne sviđa joj se ovaj kroj.", "ua": "Їй не подобається цей фасон."}, {"hr": "Mami se sviđa srebro.", "ua": "Мамі подобається срібло."}, {"hr": "Što ti se najviše sviđa?", "ua": "Що тобі найбільше подобається?"}]'::jsonb, 4
where exists (select 1 from public.grammar_topics where id = '8e4a02a1-af3e-5224-9ddc-cf22440d7e00')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '8e4a02a1-af3e-5224-9ddc-cf22440d7e00', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '8e4a02a1-af3e-5224-9ddc-cf22440d7e00')
  and not exists (select 1 from public.content_reviews where entity_id = '8e4a02a1-af3e-5224-9ddc-cf22440d7e00' and notes = 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.');
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Знахідний відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Знахідний відмінок»'; end if;
  if exists (select 1 from public.grammar_rules where id = '1753bc87-985d-5585-85f5-84481ae4f950') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('1753bc87-985d-5585-85f5-84481ae4f950', v_topic, 'Прикметник + іменник: novu jaknu, topli šal', 'Прикметник у знахідному змінюється разом з іменником. Жіночий рід: -u — nova jakna → novu jaknu, zimska kapa → zimsku kapu. Чоловічий рід, неживе — як у називному: topli šal, zlatni prsten; живе — -og: novog prijatelja. Множина: -e — nove cipele, vunene rukavice; середній рід — без змін: novo odijelo.', 'nova jakna → novu jaknu · topli šal → topli šal · novi prijatelj → novog prijatelja', '[{"hr": "Tražim zimsku kapu.", "ua": "Я шукаю зимову шапку."}, {"hr": "Kupujem mami srebrnu narukvicu.", "ua": "Я купую мамі срібний браслет."}, {"hr": "Nosim vunene rukavice.", "ua": "Я ношу вовняні рукавички."}, {"hr": "Imate li crni kaput?", "ua": "У вас є чорне пальто?"}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', '1753bc87-985d-5585-85f5-84481ae4f950', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Ступені порівняння' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Ступені порівняння»'; end if;
  if exists (select 1 from public.grammar_rules where id = '3be5d539-98ae-5809-b299-f510a37830e6') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('3be5d539-98ae-5809-b299-f510a37830e6', v_topic, 'Особливі форми: bolji, gori, veći, manji', 'Кілька частих прикметників мають особливий вищий ступінь, як і в українській: dobar → bolji, loš → lošiji або gori, velik → veći, malen / mali → manji, dug → duži (dulji), kratak → kraći, lak → lakši, težak → teži. Найвищий — з naj-: najbolji, najveći, najmanji. Порівнюємо з od + родовий або nego: bolja od one, bolja nego prošla.', 'dobar → bolji → najbolji · velik → veći → najveći · mali → manji → najmanji', '[{"hr": "Ova jakna je bolja od one.", "ua": "Ця куртка краща за ту."}, {"hr": "Trebam veći broj.", "ua": "Мені потрібен більший розмір."}, {"hr": "Plave cipele su manje od crnih.", "ua": "Сині туфлі менші за чорні."}, {"hr": "Ovo je najbolji izbor.", "ua": "Це найкращий вибір."}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', '3be5d539-98ae-5809-b299-f510a37830e6', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;

-- 2. Перебудова наявних уроків модуля A1.3
-- A1.3 · урок 23: Одяг на сезон — перебудова: 19 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'c8297811-44ed-55a2-8cb5-d1bd9b8a6a73';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Одяг на сезон» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'dc9da069-cdfc-5215-b10f-806993f9a205') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 23: Одяг на сезон', title_hr = 'Lekcija 23: Odjeća za svako doba godine',
         objectives = '["Назвати зимовий і літній одяг: kapa, šal, kabanica, kratke hlače", "Сказати, що взяти з собою в дорогу", "Прикметник + іменник у знахідному: toplu kapu, nepromočive čizme"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Знахідний відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Знахідний відмінок»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'šal', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kapa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rukavice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čizme', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kapuljača', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kabanica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prsluk', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trenirka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šešir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sandale', v_pos);
  v_pos := pg_temp.word(v_lesson, 'papuče', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kratke hlače', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupaći kostim', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vuna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pamuk', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tanak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nepromočiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zimski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljetni', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ad66e3bc-f97a-5bf9-a19a-27198bc59014', 'fill_in_the_blank', 'Kupujem ___ kapu za zimu.', 'toplu', '["toploj", "topla", "toplom", "toplu"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b9862aaa-95be-5ae0-bebf-245c07b6cef0', 'multiple_choice', 'Що означає «pamuk»?', 'бавовна', '["зимовий", "сандалі", "шарф", "бавовна"]'::jsonb, 'A1', 2, 'PUBLISHED', 'pamuk', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '40181484-aee7-5778-a395-37b5f10ce8ef', 'multiple_choice', 'Що означає «trenirka»?', 'спортивний костюм', '["капюшон", "шорти", "спортивний костюм", "тапочки"]'::jsonb, 'A1', 3, 'PUBLISHED', 'trenirka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3f532b57-8103-5b61-846f-1356b48cbe8e', 'multiple_choice', 'Що означає «rukavice»?', 'рукавички', '["тонкий", "рукавички", "дощовик (плащ від дощу)", "вовна"]'::jsonb, 'A1', 4, 'PUBLISHED', 'rukavice', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5353256b-5dd6-51ed-ab47-eb0a6aa615a2', 'multiple_choice', 'Як хорватською «дощовик (плащ від дощу)»?', 'kabanica', '["zimski", "kabanica", "papuče", "trenirka"]'::jsonb, 'A1', 5, 'PUBLISHED', 'kabanica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '101277a9-3abd-5882-ac3e-d7e6cf366a89', 'multiple_choice', 'Як хорватською «шорти»?', 'kratke hlače', '["kratke hlače", "prsluk", "sandale", "papuče"]'::jsonb, 'A1', 6, 'PUBLISHED', 'kratke hlače', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d5349e6-1f77-5c81-b0cc-c9a048a211d4', 'type_answer', 'Напишіть хорватською: «зимовий»', 'zimski', null, 'A1', 7, 'PUBLISHED', 'zimski', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ec16270d-f000-5cd5-851c-39d1ce03582f', 'type_answer', 'Напишіть хорватською: «вовна»', 'vuna', null, 'A1', 8, 'PUBLISHED', 'vuna', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '50b93d8f-9f88-50d3-bd6b-508e6e46526f', 'type_answer', 'Напишіть хорватською: «сандалі»', 'sandale', null, 'A1', 9, 'PUBLISHED', 'sandale', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '761c110d-f8a6-5cf1-94db-531dda572256', 'sentence_builder', 'Складіть: «Я ношу теплий шарф.»', 'Nosim topli šal.', '["topli", "šal.", "Nosim"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cc0a9377-b8d5-5db9-bc4c-f723e1c35013', 'sentence_builder', 'Складіть: «Візьми непромокальні чоботи.»', 'Uzmi nepromočive čizme.', '["čizme.", "Uzmi", "nepromočive"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd2b4d5d4-ddb8-5e0d-bc6c-efebf2a9cc28', 'listening', 'Прослухайте і складіть фразу', 'Mama, gdje mi je zimska kapa?', '["je", "gdje", "zimska", "Mama,", "mi", "kapa?"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ded51b48-52b9-5444-892b-89dd39af050c', 'listening', 'Прослухайте і складіть фразу', 'Ne zaboravi šešir, sunce je jako.', '["sunce", "šešir,", "zaboravi", "je", "jako.", "Ne"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1b6f75c2-b4ca-5208-aa3b-0f4977212f51', 'speaking', 'Де моя зимова шапка?', 'Gdje je moja zimska kapa?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2b5854ee-b2f2-5639-a23e-37bfca8371a7', 'speaking', 'Я беру купальник і шорти.', 'Uzimam kupaći kostim i kratke hlače.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('dc9da069-cdfc-5215-b10f-806993f9a205', v_lesson, 'Зима йде', 'Zima dolazi', 3231, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('c52db955-f6d5-5e9a-b4ab-2c3469c73682', 'dc9da069-cdfc-5215-b10f-806993f9a205', 'Daša', 'Filipe, vani je minus pet. Obuci toplu jaknu!', 'Філіпе, надворі мінус п’ять. Вдягни теплу куртку!', 1);
  perform pg_temp.turn('62e6ca08-151d-55e9-9112-a5760cff8cca', 'dc9da069-cdfc-5215-b10f-806993f9a205', 'Filip', 'Mama, gdje mi je zimska kapa?', 'Мамо, де моя зимова шапка?', 2);
  perform pg_temp.turn('6593eb0e-43ad-596e-9139-b1213ade3a36', 'dc9da069-cdfc-5215-b10f-806993f9a205', 'Daša', 'U ormaru, pored vunenih rukavica.', 'У шафі, біля вовняних рукавичок.', 3);
  perform pg_temp.turn('2040931f-c796-55db-a9a0-83383b62eeb1', 'dc9da069-cdfc-5215-b10f-806993f9a205', 'Filip', 'Trebam li i šal?', 'Шарф теж треба?', 4);
  perform pg_temp.turn('4e05cbf3-837b-5ca9-a4b5-50af46490a9a', 'dc9da069-cdfc-5215-b10f-806993f9a205', 'Daša', 'Trebaš. I obuj nepromočive čizme, pada snijeg.', 'Треба. І взуй непромокальні чоботи, падає сніг.', 5);
  perform pg_temp.turn('e9a67c32-68be-53e5-bf7b-e10303ef479b', 'dc9da069-cdfc-5215-b10f-806993f9a205', 'Filip', 'Dobro, ali kapuljaču ne stavljam.', 'Добре, але капюшон я не вдягаю.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6f366c15-c36e-5091-bdfa-8d6368e711e1', v_lesson, 'Валіза на море', 'Kofer za more', 3232, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('db5db3b6-6911-5082-8b81-c48392436bc7', '6f366c15-c36e-5091-bdfa-8d6368e711e1', 'Darja', 'Što nosiš na more?', 'Що ти береш на море?', 1);
  perform pg_temp.turn('9b69bc5b-7877-5c36-8659-3debd09770b9', '6f366c15-c36e-5091-bdfa-8d6368e711e1', 'Ana', 'Kupaći kostim, kratke hlače i nekoliko tankih majica.', 'Купальник, шорти й кілька тонких футболок.', 2);
  perform pg_temp.turn('840f89d9-4cea-5b94-8c4f-d69ee682a438', '6f366c15-c36e-5091-bdfa-8d6368e711e1', 'Darja', 'Ne zaboravi šešir, sunce je jako.', 'Не забудь капелюх, сонце сильне.', 3);
  perform pg_temp.turn('2bd08cd1-fc59-5022-b8db-7b8fa36381fe', '6f366c15-c36e-5091-bdfa-8d6368e711e1', 'Ana', 'Imam ga. Nosim i sandale i papuče.', 'Він у мене є. Беру й сандалі, і капці.', 4);
  perform pg_temp.turn('061820e1-3ab7-5a02-98f4-e80562095990', '6f366c15-c36e-5091-bdfa-8d6368e711e1', 'Darja', 'A ako pada kiša?', 'А якщо буде дощ?', 5);
  perform pg_temp.turn('f3feb254-b79c-523f-8815-c273911c9944', '6f366c15-c36e-5091-bdfa-8d6368e711e1', 'Ana', 'Uzimam kabanicu i trenirku za hladne večeri.', 'Беру дощовик і спортивний костюм на прохолодні вечори.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 25: Дрогерія й косметика — перебудова: 19 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '9ba8e62a-83fd-5b08-9e01-760bc0f7219f';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Дрогерія й косметика» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '689cf0d0-2b6e-5606-9e9a-61e115e4f09d') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 25: Дрогерія й косметика', title_hr = 'Lekcija 25: Drogerija i kozmetika',
         objectives = '["Купити засоби догляду: šampon, regenerator, krema za sunčanje", "Назвати косметику: ruž za usne, maskara, lak za nokte", "Родовий: bočica šampona, nema maramica"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Родовий відмінок: основи' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Родовий відмінок: основи»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'drogerija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šampon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'regenerator', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gel za tuširanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dezodorans', v_pos);
  v_pos := pg_temp.word(v_lesson, 'parfem', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krema', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krema za sunčanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šminka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ruž za usne', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maskara', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lak za nokte', v_pos);
  v_pos := pg_temp.word(v_lesson, 'britvica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vlažne maramice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'deterdžent', v_pos);
  v_pos := pg_temp.word(v_lesson, 'omekšivač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osjetljiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'suh', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mastan', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '6bc4fb52-be7b-513c-beff-154a7ecd019f', 'fill_in_the_blank', 'Kupi mi bočicu ___, molim te.', 'šampona', '["šamponom", "šampon", "šamponu", "šampona"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '71bde360-fb2b-54a9-bbce-cd54375dde6a', 'multiple_choice', 'Що означає «drogerija»?', 'магазин побутової хімії й косметики', '["масний, жирний", "губна помада", "сухий", "магазин побутової хімії й косметики"]'::jsonb, 'A1', 2, 'PUBLISHED', 'drogerija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2eae1786-88d1-57b5-b345-3b4c5b99fadf', 'multiple_choice', 'Що означає «suh»?', 'сухий', '["шампунь", "лак для нігтів", "губна помада", "сухий"]'::jsonb, 'A1', 3, 'PUBLISHED', 'suh', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9e78f7fe-76e4-55e7-9f5c-1007b8525bdd', 'multiple_choice', 'Що означає «krema za sunčanje»?', 'сонцезахисний крем', '["сонцезахисний крем", "губна помада", "лак для нігтів", "парфуми"]'::jsonb, 'A1', 4, 'PUBLISHED', 'krema za sunčanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a24d906a-2a2a-5b8d-a243-338abb1e1f8f', 'multiple_choice', 'Як хорватською «туш для вій»?', 'maskara', '["osjetljiv", "lak za nokte", "britvica", "maskara"]'::jsonb, 'A1', 5, 'PUBLISHED', 'maskara', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cd7f90af-cacd-5f4b-b3f7-bf409b19b183', 'multiple_choice', 'Як хорватською «губна помада»?', 'ruž za usne', '["ruž za usne", "suh", "dezodorans", "lak za nokte"]'::jsonb, 'A1', 6, 'PUBLISHED', 'ruž za usne', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '37524429-99be-54d6-a63b-908673d94f6c', 'type_answer', 'Напишіть хорватською: «шампунь»', 'šampon', null, 'A1', 7, 'PUBLISHED', 'šampon', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5adbeb52-e703-5f8f-8a01-64dd2f6930f0', 'type_answer', 'Напишіть хорватською: «чутливий»', 'osjetljiv', null, 'A1', 8, 'PUBLISHED', 'osjetljiv', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '25d10040-9610-57cc-a314-8c721f820eaf', 'type_answer', 'Напишіть хорватською: «парфуми»', 'parfem', null, 'A1', 9, 'PUBLISHED', 'parfem', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b3364388-439c-5db9-b5fb-79c0c5b8a890', 'sentence_builder', 'Складіть: «У нас немає гелю для душу.»', 'Nemamo gela za tuširanje.', '["za", "tuširanje.", "gela", "Nemamo"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a4f6100d-aabf-5ff9-ae20-5dd57a451b0d', 'sentence_builder', 'Складіть: «Мені потрібен сонцезахисний крем.»', 'Trebam kremu za sunčanje.', '["sunčanje.", "kremu", "Trebam", "za"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '460992f3-0d20-52fa-8825-71a7b517ecec', 'listening', 'Прослухайте і складіть фразу', 'Super. Trebam i kremu za osjetljivu kožu.', '["osjetljivu", "kožu.", "i", "kremu", "Super.", "Trebam", "za"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7492624d-9398-5266-9b7e-61898b7a90ee', 'listening', 'Прослухайте і складіть фразу', 'Idem u drogeriju. Što trebamo?', '["Što", "drogeriju.", "trebamo?", "u", "Idem"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '975c2b93-078d-5993-91f3-f39e819ab5d3', 'speaking', 'Мені потрібен дезодорант і гель для душу.', 'Trebam dezodorans i gel za tuširanje.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '926967e9-e559-5049-9d30-2a3232c03a02', 'speaking', 'У вас є крем для чутливої шкіри?', 'Imate li kremu za osjetljivu kožu?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('689cf0d0-2b6e-5606-9e9a-61e115e4f09d', v_lesson, 'Для волосся й шкіри', 'Za kosu i kožu', 3251, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('03245fa2-df83-5619-b7f1-2f4b709bdb29', '689cf0d0-2b6e-5606-9e9a-61e115e4f09d', 'Daša', 'Oprostite, imate li šampon za suhu kosu?', 'Перепрошую, у вас є шампунь для сухого волосся?', 1);
  perform pg_temp.turn('7876c499-f335-5c3c-8fee-277006f24363', '689cf0d0-2b6e-5606-9e9a-61e115e4f09d', 'Prodavačica', 'Imamo. Ovaj je bez parfema, a ima i regenerator.', 'Є. Цей без запаху, і до нього є бальзам.', 2);
  perform pg_temp.turn('0c563ff7-d6a2-5b5f-9e84-8e7082f3c22e', '689cf0d0-2b6e-5606-9e9a-61e115e4f09d', 'Daša', 'Super. Trebam i kremu za osjetljivu kožu.', 'Чудово. Мені ще потрібен крем для чутливої шкіри.', 3);
  perform pg_temp.turn('8fe9489e-ffcb-5545-b842-c29cce2be0a9', '689cf0d0-2b6e-5606-9e9a-61e115e4f09d', 'Prodavačica', 'Ova je dobra i za suhu i za masnu kožu.', 'Цей підходить і для сухої, і для жирної шкіри.', 4);
  perform pg_temp.turn('e658ad03-1f9e-55c9-8c9c-791cab94cdbf', '689cf0d0-2b6e-5606-9e9a-61e115e4f09d', 'Daša', 'A krema za sunčanje za djecu?', 'А дитячий сонцезахисний крем?', 5);
  perform pg_temp.turn('a91a0da2-31c8-5cff-bfa7-96eaa045c62b', '689cf0d0-2b6e-5606-9e9a-61e115e4f09d', 'Prodavačica', 'Nažalost, nema je. Stiže tek u svibnju.', 'На жаль, його немає. Надійде тільки в травні.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('31ad2601-f162-5b87-bff0-b775584c072f', v_lesson, 'Список для дрогерії', 'Popis za drogeriju', 3252, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('2d5c7b11-1bbd-5f5e-b05d-90772078ec4d', '31ad2601-f162-5b87-bff0-b775584c072f', 'Luka', 'Idem u drogeriju. Što trebamo?', 'Я йду в дрогерію. Що нам треба?', 1);
  perform pg_temp.turn('ff8b49f3-4c59-5134-891f-bb3c660ae0a2', '31ad2601-f162-5b87-bff0-b775584c072f', 'Darja', 'Gel za tuširanje, deterdžent i omekšivač.', 'Гель для душу, засіб для прання й кондиціонер.', 2);
  perform pg_temp.turn('2d176dbd-0f81-5038-a4b6-e4916098c786', '31ad2601-f162-5b87-bff0-b775584c072f', 'Luka', 'Imamo li još vlažnih maramica?', 'У нас ще є вологі серветки?', 3);
  perform pg_temp.turn('dc71a337-343d-5d1a-85b5-2a7070122ecd', '31ad2601-f162-5b87-bff0-b775584c072f', 'Darja', 'Nemamo, kupi dva pakiranja. I meni maskaru.', 'Немає, купи дві пачки. І мені туш.', 4);
  perform pg_temp.turn('43f249c7-fdcf-5be6-ad36-b6c18246a452', '31ad2601-f162-5b87-bff0-b775584c072f', 'Luka', 'Koju maskaru? Ima ih sto vrsta.', 'Яку туш? Їх сто видів.', 5);
  perform pg_temp.turn('f5043482-9fef-541b-bddc-f8ce01a31f8a', '31ad2601-f162-5b87-bff0-b775584c072f', 'Darja', 'Bilo koju crnu. A tebi trebaju nove britvice.', 'Будь-яку чорну. А тобі потрібні нові бритви.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 27: Яка краща? Порівнюємо товари — перебудова: 16 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '7042ff57-9a20-514a-ab80-71b6f63579f7';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Яка краща? Порівнюємо товари» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '9b7c2d5f-6993-5653-b804-8da1577432a5') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 27: Яка краща? Порівнюємо товари', title_hr = 'Lekcija 27: Koja je bolja? Uspoređujemo proizvode',
         objectives = '["Порівняти два товари: ціна, якість, матеріал", "Запитати, у чому різниця, і обрати", "Особливі форми: bolji, veći, manji"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Ступені порівняння' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Ступені порівняння»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'usporediti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razlika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'isti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sličan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'različit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kvaliteta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kvalitetan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'materijal', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trajan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'marka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'proizvod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izbor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odabrati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povoljan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skup', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jeftin', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '16760d68-d8b3-5971-b2e8-312ed36af86c', 'fill_in_the_blank', 'Ova jakna je ___ od one.', 'bolja', '["dobro", "dobra", "bolja", "najbolje"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6ec18dd1-aded-57ae-af06-e1c8720f6eee', 'multiple_choice', 'Що означає «proizvod»?', 'продукт / товар', '["продукт / товар", "різниця", "матеріал", "вигідний, недорогий"]'::jsonb, 'A1', 2, 'PUBLISHED', 'proizvod', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa54711a-8632-5c8c-9feb-cd3f686a4335', 'multiple_choice', 'Що означає «isti»?', 'той самий; однаковий', '["довговічний, міцний", "дорогий (за ціною)", "той самий; однаковий", "вигідний, недорогий"]'::jsonb, 'A1', 3, 'PUBLISHED', 'isti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '74fc2b99-b956-5471-9d18-fbceb6ef1f78', 'multiple_choice', 'Що означає «različit»?', 'різний; відмінний', '["дешевий", "матеріал", "різний; відмінний", "якісний"]'::jsonb, 'A1', 4, 'PUBLISHED', 'različit', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7d389de6-2063-5d8f-b412-c8f101504305', 'multiple_choice', 'Як хорватською «якісний»?', 'kvalitetan', '["usporediti", "proizvod", "kvalitetan", "kvaliteta"]'::jsonb, 'A1', 5, 'PUBLISHED', 'kvalitetan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f458297f-6557-599b-b3f5-fdef20decbb0', 'multiple_choice', 'Як хорватською «порівняти»?', 'usporediti', '["trajan", "kvalitetan", "razlika", "usporediti"]'::jsonb, 'A1', 6, 'PUBLISHED', 'usporediti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '56042d51-86d3-5f57-8d6d-1ead86f9d74b', 'type_answer', 'Напишіть хорватською: «схожий»', 'sličan', null, 'A1', 7, 'PUBLISHED', 'sličan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a1c05ab5-3254-5066-9d54-b6d3f4fee0a5', 'type_answer', 'Напишіть хорватською: «різниця»', 'razlika', null, 'A1', 8, 'PUBLISHED', 'razlika', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c9241977-1ba7-5835-8e36-2c9a2fc16d68', 'type_answer', 'Напишіть хорватською: «якість»', 'kvaliteta', null, 'A1', 9, 'PUBLISHED', 'kvaliteta', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '852f7669-9feb-5f42-925b-ba387870bd89', 'sentence_builder', 'Складіть: «Ці кросівки кращі за ті.»', 'Ove tenisice su bolje od onih.', '["su", "Ove", "od", "onih.", "tenisice", "bolje"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '04d963b8-90c7-5cbe-8c36-60965c941417', 'sentence_builder', 'Складіть: «Яка між ними різниця?»', 'Kakva je razlika između njih?', '["između", "njih?", "razlika", "je", "Kakva"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f17779b9-c218-5118-b8e3-e924c5613cac', 'listening', 'Прослухайте і складіть фразу', 'Ima li velike razlike u materijalu?', '["velike", "li", "razlike", "materijalu?", "u", "Ima"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a2cc2e21-c56b-58de-afb8-79f4680e3e17', 'listening', 'Прослухайте і складіть фразу', 'Je li i kvaliteta ista?', '["ista?", "kvaliteta", "i", "li", "Je"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '10cce282-10cb-5099-b3de-6f6c4050e0e5', 'speaking', 'Ця куртка краща й дешевша.', 'Ova jakna je bolja i jeftinija.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9fd5ab7e-9532-5ce4-8b5c-0e83ebe33ce2', 'speaking', 'Ці дві марки схожі.', 'Ove dvije marke su slične.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9b7c2d5f-6993-5653-b804-8da1577432a5', v_lesson, 'Які кросівки?', 'Koje tenisice?', 3271, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('53a0c14b-c6fc-5ae5-9bb4-d9e340bde891', '9b7c2d5f-6993-5653-b804-8da1577432a5', 'Luka', 'Dašo, koje su bolje, plave ili crne?', 'Дашо, які кращі — сині чи чорні?', 1);
  perform pg_temp.turn('e7c74155-d24a-579c-a9b3-4aad9f411d04', '9b7c2d5f-6993-5653-b804-8da1577432a5', 'Daša', 'Plave su jeftinije, ali crne su kvalitetnije.', 'Сині дешевші, але чорні якісніші.', 2);
  perform pg_temp.turn('0e2ef2e4-ba86-55b8-850c-4ea8826b8acb', '9b7c2d5f-6993-5653-b804-8da1577432a5', 'Luka', 'Ima li velike razlike u materijalu?', 'А матеріал сильно відрізняється?', 3);
  perform pg_temp.turn('3b6393d9-b2cc-50f4-ad5d-17ac7666ea92', '9b7c2d5f-6993-5653-b804-8da1577432a5', 'Daša', 'Ima. Crne su od kože i puno su trajnije.', 'Так. Чорні шкіряні й набагато міцніші.', 4);
  perform pg_temp.turn('b0649774-ecaa-5215-af02-428818fe719f', '9b7c2d5f-6993-5653-b804-8da1577432a5', 'Luka', 'Onda uzimam crne. Loša kvaliteta se ne isplati.', 'Тоді беру чорні. Погана якість не окупається.', 5);
  perform pg_temp.turn('5e30a521-65d0-57b9-990b-d9f9c3195560', '9b7c2d5f-6993-5653-b804-8da1577432a5', 'Daša', 'Slažem se. Bolje platiti više nego kupovati dvaput.', 'Згодна. Краще заплатити більше, ніж купувати двічі.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('50f84771-678b-5afd-a87c-76c3ab25bbf4', v_lesson, 'Дві марки', 'Dvije marke', 3272, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('2fd2bb4b-19e0-5e2b-800d-1fbd76082459', '50f84771-678b-5afd-a87c-76c3ab25bbf4', 'Darja', 'Koju marku mi preporučujete?', 'Яку марку ви мені радите?', 1);
  perform pg_temp.turn('0d77b062-6400-5632-a40e-6434db17de6c', '50f84771-678b-5afd-a87c-76c3ab25bbf4', 'Prodavač', 'Ove dvije su slične, ali ova je povoljnija.', 'Ці дві схожі, але ця вигідніша.', 2);
  perform pg_temp.turn('1877aa2a-1804-5a30-82c2-a19683e31f76', '50f84771-678b-5afd-a87c-76c3ab25bbf4', 'Darja', 'Je li i kvaliteta ista?', 'А якість однакова?', 3);
  perform pg_temp.turn('4c51ea0b-57a4-5547-a417-3e3963f4235b', '50f84771-678b-5afd-a87c-76c3ab25bbf4', 'Prodavač', 'Gotovo ista. Druga je skuplja zbog imena.', 'Майже однакова. Інша дорожча через назву.', 4);
  perform pg_temp.turn('43b0dd1d-cc25-58bd-a80f-1c10d34c7d83', '50f84771-678b-5afd-a87c-76c3ab25bbf4', 'Darja', 'Izbor je velik, teško je odabrati.', 'Вибір великий, важко обрати.', 5);
  perform pg_temp.turn('7b0a61fa-23ae-53a7-aa9a-ec257d12bfe0', '50f84771-678b-5afd-a87c-76c3ab25bbf4', 'Prodavač', 'Usporedite ih na miru, ne žurimo se.', 'Порівняйте їх спокійно, ми не поспішаємо.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 28: Повернення товару — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '6a7b0f42-510b-521e-9cc0-f77b2659d838';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Повернення товару» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '1bf934a2-a7b4-51cb-ae87-c0f3bf15cbc3') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 28: Повернення товару', title_hr = 'Lekcija 28: Povrat robe',
         objectives = '["Пояснити, що з товаром не так: neispravan, mrlja, rupa", "Попросити заміну або повернення грошей", "Mogu li…? Moram li…? — модальні дієслова в магазині"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Модальні дієслова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Модальні дієслова»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'neispravan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispravan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pokvariti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oštećen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ogrebotina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mrlja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rupa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'etiketa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'originalno pakiranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rok za povrat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zamjena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razlog', v_pos);
  v_pos := pg_temp.word(v_lesson, 'služba za korisnike', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upute', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '9403ee67-08a7-539f-9eba-7f7cb5a6ee11', 'fill_in_the_blank', 'Mogu li ___ ove cipele?', 'vratiti', '["vrati", "vratiti", "vraćam", "vratim"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5c962e17-70db-52f3-9e00-e2fc4ecc62b4', 'multiple_choice', 'Що означає «rok za povrat»?', 'термін повернення (товару)', '["пошкоджений", "несправний, бракований", "справний", "термін повернення (товару)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'rok za povrat', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '45f250dd-19b7-5c0b-a2ee-0601a4775587', 'multiple_choice', 'Що означає «zamjena»?', 'заміна; обмін (товару)', '["служба підтримки клієнтів", "заміна; обмін (товару)", "пошкоджений", "оригінальна упаковка"]'::jsonb, 'A1', 3, 'PUBLISHED', 'zamjena', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0d26dfe0-5e2d-5efd-a4bb-8e52dbfddee4', 'multiple_choice', 'Що означає «upute»?', 'інструкції', '["справний", "інструкції", "пошкоджений", "дірка, отвір"]'::jsonb, 'A1', 4, 'PUBLISHED', 'upute', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '33395943-4204-52d9-8d00-24d4bc57a5c3', 'multiple_choice', 'Як хорватською «дірка, отвір»?', 'rupa', '["rupa", "razlog", "rok za povrat", "pokvariti se"]'::jsonb, 'A1', 5, 'PUBLISHED', 'rupa', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bb039b46-fea2-5f3a-acb7-e6423c24a686', 'multiple_choice', 'Як хорватською «подряпина»?', 'ogrebotina', '["razlog", "oštećen", "rok za povrat", "ogrebotina"]'::jsonb, 'A1', 6, 'PUBLISHED', 'ogrebotina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '51b93bdf-25cb-56da-b6e7-335c0a59ad67', 'type_answer', 'Напишіть хорватською: «несправний, бракований»', 'neispravan', null, 'A1', 7, 'PUBLISHED', 'neispravan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5258c619-4778-5e36-8552-8bf6d1966495', 'type_answer', 'Напишіть хорватською: «зламатися, зіпсуватися»', 'pokvariti se', null, 'A1', 8, 'PUBLISHED', 'pokvariti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e967d28e-0ac4-567d-90b2-9c1b37074f44', 'type_answer', 'Напишіть хорватською: «справний»', 'ispravan', null, 'A1', 9, 'PUBLISHED', 'ispravan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fedff8b5-4e89-5ff5-b1a3-c4febdef782e', 'sentence_builder', 'Складіть: «Чи треба показати чек?»', 'Moram li pokazati račun?', '["li", "pokazati", "račun?", "Moram"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1eb3be06-7765-50b8-8239-8245327598ed', 'sentence_builder', 'Складіть: «На светрі є пляма.»', 'Na džemperu je mrlja.', '["džemperu", "je", "mrlja.", "Na"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '17da8f40-0432-5f82-b120-7d9f2fc20e50', 'listening', 'Прослухайте і складіть фразу', 'Imate li račun i originalno pakiranje?', '["račun", "originalno", "li", "pakiranje?", "i", "Imate"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '01730447-3d25-5a22-af29-ed806a3226d8', 'listening', 'Прослухайте і складіть фразу', 'Mogu li dobiti novac natrag?', '["dobiti", "natrag?", "li", "novac", "Mogu"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f8a9a2c4-2fce-5c8f-83ab-3ba9dc15b393', 'speaking', 'Ці навушники не працюють.', 'Ove slušalice ne rade.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ab8dbee7-965a-5d3e-8992-1b95f633ec17', 'speaking', 'Можу я їх обміняти?', 'Mogu li ih zamijeniti?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1bf934a2-a7b4-51cb-ae87-c0f3bf15cbc3', v_lesson, 'Навушники не працюють', 'Slušalice ne rade', 3281, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('2f007ccc-a7fb-5142-ad13-bbb618f529e3', '1bf934a2-a7b4-51cb-ae87-c0f3bf15cbc3', 'Daša', 'Dobar dan, ove slušalice ne rade. Jedna strana je neispravna.', 'Добрий день, ці навушники не працюють. Одна сторона несправна.', 1);
  perform pg_temp.turn('b646449b-1cdd-5a12-ac1e-84a435f9cebf', '1bf934a2-a7b4-51cb-ae87-c0f3bf15cbc3', 'Prodavač', 'Imate li račun i originalno pakiranje?', 'У вас є чек і оригінальна упаковка?', 2);
  perform pg_temp.turn('c8536575-5c70-501e-b225-9e719d509422', '1bf934a2-a7b4-51cb-ae87-c0f3bf15cbc3', 'Daša', 'Imam oboje. Mogu li ih zamijeniti?', 'Є і те, і те. Можу їх обміняти?', 3);
  perform pg_temp.turn('35fef0ce-6d91-5f5c-bac1-657c5fcf2f3e', '1bf934a2-a7b4-51cb-ae87-c0f3bf15cbc3', 'Prodavač', 'Možete. Rok za povrat je trideset dana.', 'Можете. Термін повернення — тридцять днів.', 4);
  perform pg_temp.turn('9e45f157-bda9-533f-b155-da4d7a120333', '1bf934a2-a7b4-51cb-ae87-c0f3bf15cbc3', 'Daša', 'Želim zamjenu, ne povrat novca.', 'Я хочу обмін, а не повернення грошей.', 5);
  perform pg_temp.turn('8b10412a-630b-5e79-86e7-288ac7fa172c', '1bf934a2-a7b4-51cb-ae87-c0f3bf15cbc3', 'Prodavač', 'Nema problema, evo novih. Probajte ih ovdje.', 'Без проблем, ось нові. Спробуйте їх тут.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8af6f7d7-52ce-560b-95f6-fe52d07c7be9', v_lesson, 'Пляма на светрі', 'Mrlja na džemperu', 3282, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('98627413-8920-5c20-884a-079bb628cf6a', '8af6f7d7-52ce-560b-95f6-fe52d07c7be9', 'Darja', 'Ovaj džemper ima mrlju i malu rupu na rukavu.', 'На цьому светрі пляма й маленька дірка на рукаві.', 1);
  perform pg_temp.turn('b2629fa8-5bc0-59cf-ae16-9309c6f5925a', '8af6f7d7-52ce-560b-95f6-fe52d07c7be9', 'Prodavačica', 'Žao mi je. Je li etiketa još na njemu?', 'Мені шкода. Етикетка ще на ньому?', 2);
  perform pg_temp.turn('cda6d861-a064-51d0-9931-2141f52f1618', '8af6f7d7-52ce-560b-95f6-fe52d07c7be9', 'Darja', 'Jest. Moram li reći razlog povrata?', 'Так. Мені треба пояснювати причину повернення?', 3);
  perform pg_temp.turn('80b186cf-4f21-5d61-a32a-4c73f6c5bf7b', '8af6f7d7-52ce-560b-95f6-fe52d07c7be9', 'Prodavačica', 'Ne morate, vidi se da je oštećen.', 'Не треба, видно, що він пошкоджений.', 4);
  perform pg_temp.turn('c71fd659-0d48-54d3-8e70-15df3b2c8708', '8af6f7d7-52ce-560b-95f6-fe52d07c7be9', 'Darja', 'Mogu li dobiti novac natrag?', 'Можна отримати гроші назад?', 5);
  perform pg_temp.turn('a6625254-c51e-505b-948d-99a7805de0d4', '8af6f7d7-52ce-560b-95f6-fe52d07c7be9', 'Prodavačica', 'Možete, ali za to idite u službu za korisnike.', 'Можна, але для цього йдіть у службу підтримки клієнтів.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 29: Покупки в інтернеті — перебудова: 17 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '91d4c9b3-c9a8-5e94-8691-6683835c375b';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Покупки в інтернеті» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '00b83b3b-e0bc-5328-9e24-f99df29ab14d') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 29: Покупки в інтернеті', title_hr = 'Lekcija 29: Kupnja preko interneta',
         objectives = '["Замовити товар в інтернет-магазині: košarica, kod za popust", "Домовитися з кур’єром про доставку", "Питання: Je li…? Kada…? Koliko…?"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Побудова питань' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Побудова питань»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'internetska trgovina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'narudžba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dodati u košaricu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na zalihi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rasprodan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kod za popust', v_pos);
  v_pos := pg_temp.word(v_lesson, 'recenzija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plaćanje karticom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pouzećem', v_pos);
  v_pos := pg_temp.word(v_lesson, 'besplatna dostava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'adresa za dostavu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dostava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kurir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'paketomat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pošiljka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'praćenje pošiljke', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pratiti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a49ccc9-2d33-5f21-9dc5-d6b085682f2b', 'fill_in_the_blank', '___ stiže moja narudžba?', 'Kada', '["Koji", "Tko", "Što", "Kada"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f3819c43-b99b-5ffb-a0f8-3582d9085221', 'multiple_choice', 'Що означає «recenzija»?', 'відгук (про товар); рецензія', '["поштомат", "кур’єр", "відстеження посилки", "відгук (про товар); рецензія"]'::jsonb, 'A1', 2, 'PUBLISHED', 'recenzija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8689f265-5811-5f45-a89f-9324c0b552ec', 'multiple_choice', 'Що означає «pošiljka»?', 'поштове відправлення', '["поштомат", "поштове відправлення", "стежити, супроводжувати", "відгук (про товар); рецензія"]'::jsonb, 'A1', 3, 'PUBLISHED', 'pošiljka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '71b624be-fb4c-5750-be0e-4f2f040b1faf', 'multiple_choice', 'Що означає «besplatna dostava»?', 'безкоштовна доставка', '["замовлення", "безкоштовна доставка", "поштомат", "інтернет-магазин"]'::jsonb, 'A1', 4, 'PUBLISHED', 'besplatna dostava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '87703a55-047f-5379-a6ce-65ee429a22a1', 'multiple_choice', 'Як хорватською «адреса доставки»?', 'adresa za dostavu', '["adresa za dostavu", "paketomat", "dostava", "kod za popust"]'::jsonb, 'A1', 5, 'PUBLISHED', 'adresa za dostavu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a7d46164-edb5-5faa-a61f-bad848b37553', 'multiple_choice', 'Як хорватською «відстеження посилки»?', 'praćenje pošiljke', '["recenzija", "paketomat", "pouzećem", "praćenje pošiljke"]'::jsonb, 'A1', 6, 'PUBLISHED', 'praćenje pošiljke', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '22788453-0fab-5364-9b3f-8ec9dd1869db', 'type_answer', 'Напишіть хорватською: «розпроданий»', 'rasprodan', null, 'A1', 7, 'PUBLISHED', 'rasprodan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '646b51aa-ce93-50e7-93dc-e1aa893eb6dc', 'type_answer', 'Напишіть хорватською: «післяплатою»', 'pouzećem', null, 'A1', 8, 'PUBLISHED', 'pouzećem', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '288b9b9f-18a3-5b7e-bc1a-0ae025f5c3ab', 'type_answer', 'Напишіть хорватською: «поштомат»', 'paketomat', null, 'A1', 9, 'PUBLISHED', 'paketomat', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '489e65ff-0f60-5687-b43e-339ed228b906', 'sentence_builder', 'Складіть: «Ця куртка є в наявності?»', 'Je li ova jakna na zalihi?', '["Je", "zalihi?", "li", "jakna", "na", "ova"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '437df1c4-2448-50c2-8827-783c3995f594', 'sentence_builder', 'Складіть: «Доставка безкоштовна.»', 'Dostava je besplatna.', '["besplatna.", "Dostava", "je"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6198151b-cec5-5b17-96a1-628360281560', 'listening', 'Прослухайте і складіть фразу', 'Kakve su recenzije?', '["Kakve", "recenzije?", "su"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0c2703fd-8486-55e7-9eb4-59817512b1f9', 'listening', 'Прослухайте і складіть фразу', 'Ne mogu, plaćanje je pouzećem.', '["Ne", "je", "plaćanje", "pouzećem.", "mogu,"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2df1a91d-231e-580c-94d4-4b87017437d5', 'speaking', 'Де моя посилка?', 'Gdje je moja pošiljka?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e9beaae3-46e5-512a-9642-8ec26a71b293', 'speaking', 'Ви можете залишити її в поштоматі?', 'Možete li je ostaviti u paketomatu?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('00b83b3b-e0bc-5328-9e24-f99df29ab14d', v_lesson, 'Замовляємо онлайн', 'Naručujemo preko interneta', 3291, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('eab22a3c-8589-55d7-82a0-f62581f23ea4', '00b83b3b-e0bc-5328-9e24-f99df29ab14d', 'Daša', 'Luka, ova internetska trgovina ima besplatnu dostavu.', 'Луко, в цьому інтернет-магазині безкоштовна доставка.', 1);
  perform pg_temp.turn('ef0fdeee-34d0-5c72-a98d-50342dd50c33', '00b83b3b-e0bc-5328-9e24-f99df29ab14d', 'Luka', 'Je li ta jakna na zalihi?', 'А ця куртка є в наявності?', 2);
  perform pg_temp.turn('d4597c4e-2b86-50c4-9f84-b83518fd8104', '00b83b3b-e0bc-5328-9e24-f99df29ab14d', 'Daša', 'Crna je rasprodana, ali plave ima.', 'Чорну розпродали, але сині є.', 3);
  perform pg_temp.turn('e557ab6d-1ee6-5888-b6bc-cd89752c15a6', '00b83b3b-e0bc-5328-9e24-f99df29ab14d', 'Luka', 'Kakve su recenzije?', 'А які відгуки?', 4);
  perform pg_temp.turn('7ecf98bb-8b47-58fc-9d02-16845f0ff960', '00b83b3b-e0bc-5328-9e24-f99df29ab14d', 'Daša', 'Odlične. Dodajem je u košaricu.', 'Чудові. Додаю її в кошик.', 5);
  perform pg_temp.turn('9379c5cb-99b8-53cd-ae57-d2b14a4aa8c4', '00b83b3b-e0bc-5328-9e24-f99df29ab14d', 'Luka', 'Imaš li kod za popust? Upiši ga prije plaćanja.', 'У тебе є промокод? Введи його перед оплатою.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1fda3bff-bc10-58e0-b683-ec4f0700c5a5', v_lesson, 'Дзвонить кур’єр', 'Zove kurir', 3292, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('783807e9-972e-5b2b-8cc4-0d095f3f53f9', '1fda3bff-bc10-58e0-b683-ec4f0700c5a5', 'Kurir', 'Dobar dan, ovdje kurir. Imam pošiljku za vas.', 'Добрий день, це кур’єр. У мене для вас посилка.', 1);
  perform pg_temp.turn('b581ec71-2bb1-5add-a12a-e87127a900c1', '1fda3bff-bc10-58e0-b683-ec4f0700c5a5', 'Darja', 'Super! Možete li je ostaviti u paketomatu?', 'Чудово! Можете залишити її в поштоматі?', 2);
  perform pg_temp.turn('1600978e-4fa8-510c-900b-5d9c9f285540', '1fda3bff-bc10-58e0-b683-ec4f0700c5a5', 'Kurir', 'Ne mogu, plaćanje je pouzećem.', 'Не можу, оплата післяплатою.', 3);
  perform pg_temp.turn('b3e17f7c-1994-5932-8391-c3788b869f3d', '1fda3bff-bc10-58e0-b683-ec4f0700c5a5', 'Darja', 'Aha. Koliko trebam platiti?', 'А, ясно. Скільки мені треба заплатити?', 4);
  perform pg_temp.turn('f86cfff6-cb6e-5564-b9be-daf77a1f5401', '1fda3bff-bc10-58e0-b683-ec4f0700c5a5', 'Kurir', 'Trideset eura. Kada ste kod kuće?', 'Тридцять євро. Коли ви будете вдома?', 5);
  perform pg_temp.turn('ed27a304-95c4-54ad-8d1c-a4d9fd657eca', '1fda3bff-bc10-58e0-b683-ec4f0700c5a5', 'Darja', 'Za pola sata. Pratim pošiljku u aplikaciji.', 'За пів години. Я відстежую посилку в застосунку.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- 3. Нові уроки модуля A1.3
-- A1.3 · урок 22: Подобається чи ні? — новий урок: 16 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := '480b3ca1-58c7-5b6f-8a52-eff47d53b3e4';
  v_lesson constant uuid := '9a979d32-2f4b-5127-bc22-7292763c7de4';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.3: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 22: Подобається чи ні?', 'Lekcija 22: Sviđa li ti se?', '["Сказати, що вам подобається й що ні: sviđa mi se, ne sviđa mi se", "Описати стиль: elegantan, ležeran, staromodan", "Короткі форми давального: mi, ti, mu, joj"]'::jsonb, 15, 'PUBLISHED', 1);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Короткі форми давального: sviđa mi se' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Короткі форми давального: sviđa mi se»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'sviđati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svidjeti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ukus', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stil', v_pos);
  v_pos := pg_temp.word(v_lesson, 'moderan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'staromodan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'elegantan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ležeran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sportski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predivan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grozan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ružan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uzorak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obožavati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mrziti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preferirati', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f62b950-c6e0-5917-ae28-ef052bcf80fe', 'fill_in_the_blank', 'Ova jakna ___ se jako sviđa.', 'mi', '["ja", "mi", "moja", "me"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '064b550c-0cef-5383-8eba-95f1fd7cb72f', 'multiple_choice', 'Що означає «ukus»?', 'смак (у виборі), уподобання', '["спортивний", "візерунок; зразок", "смак (у виборі), уподобання", "сподобатися"]'::jsonb, 'A1', 2, 'PUBLISHED', 'ukus', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2812d572-5328-5257-9275-d681d1210aee', 'multiple_choice', 'Що означає «stil»?', 'стиль', '["візерунок; зразок", "сучасний", "стиль", "віддавати перевагу"]'::jsonb, 'A1', 3, 'PUBLISHED', 'stil', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '057d0984-f450-59a1-91e6-b64977b19d2c', 'multiple_choice', 'Що означає «ležeran»?', 'невимушений, повсякденний (про одяг, стиль)', '["обожнювати", "візерунок; зразок", "елегантний", "невимушений, повсякденний (про одяг, стиль)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'ležeran', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '980e1ebd-ba51-5aeb-b9bb-1ecd5b89555f', 'multiple_choice', 'Як хорватською «сучасний»?', 'moderan', '["staromodan", "moderan", "ukus", "ležeran"]'::jsonb, 'A1', 5, 'PUBLISHED', 'moderan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f7848a8-791d-58e3-9518-26045bb58d14', 'multiple_choice', 'Як хорватською «жахливий»?', 'grozan', '["grozan", "staromodan", "stil", "sportski"]'::jsonb, 'A1', 6, 'PUBLISHED', 'grozan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b9ed1c9e-9713-5378-af34-24b2782aef49', 'type_answer', 'Напишіть хорватською: «обожнювати»', 'obožavati', null, 'A1', 7, 'PUBLISHED', 'obožavati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '61de683d-93f9-5dd7-acb0-1a2d575abe97', 'type_answer', 'Напишіть хорватською: «сподобатися»', 'svidjeti se', null, 'A1', 8, 'PUBLISHED', 'svidjeti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '55acc63d-dc01-59ee-b5f3-3db50c1c6813', 'type_answer', 'Напишіть хорватською: «старомодний»', 'staromodan', null, 'A1', 9, 'PUBLISHED', 'staromodan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '12f3d44b-3943-5067-b8e4-50ce3cb9d77a', 'sentence_builder', 'Складіть: «Мені подобається твій стиль.»', 'Sviđa mi se tvoj stil.', '["stil.", "se", "tvoj", "Sviđa", "mi"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7f137dc4-92c8-50c5-967f-bd7cbbe00a99', 'sentence_builder', 'Складіть: «Ці туфлі мені не подобаються.»', 'Ove cipele mi se ne sviđaju.', '["mi", "sviđaju.", "cipele", "se", "ne", "Ove"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ed30e504-b0e6-55cb-a258-d14cf1ea50cb', 'listening', 'Прослухайте і складіть фразу', 'Meni se sviđa. Elegantna je, a nije skupa.', '["a", "se", "skupa.", "Elegantna", "nije", "je,", "Meni", "sviđa."]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '19ec99b1-9acc-5f90-8d8a-45f02d5c13b0', 'listening', 'Прослухайте і складіть фразу', 'Šarene košulje. Grozne su!', '["su!", "Grozne", "košulje.", "Šarene"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4b712372-bc7c-527f-a7e3-d14ddc3a7aab', 'speaking', 'Тобі подобається ця сукня?', 'Sviđa li ti se ova haljina?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8027ae91-2044-5b61-a828-50358a0b8cef', 'speaking', 'Я більше люблю спортивний одяг.', 'Više volim sportsku odjeću.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ef6fbfbe-1a13-56fc-b742-b5919e371d6d', v_lesson, 'Тобі подобається?', 'Sviđa li ti se?', 3221, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('0556d03a-dae5-5da7-a536-b0da9661e4e7', 'ef6fbfbe-1a13-56fc-b742-b5919e371d6d', 'Daša', 'Ivana, sviđa li ti se ova haljina?', 'Івано, тобі подобається ця сукня?', 1);
  perform pg_temp.turn('fb88ee3b-70f2-5813-a6c1-1519d6f6f07a', 'ef6fbfbe-1a13-56fc-b742-b5919e371d6d', 'Ivana', 'Boja mi se sviđa, ali uzorak je malo staromodan.', 'Колір мені подобається, але візерунок трохи старомодний.', 2);
  perform pg_temp.turn('9fa6efa3-0376-529c-bee1-94472fc101b3', 'ef6fbfbe-1a13-56fc-b742-b5919e371d6d', 'Daša', 'Meni se sviđa. Elegantna je, a nije skupa.', 'А мені подобається. Вона елегантна й недорога.', 3);
  perform pg_temp.turn('6c8dbbfb-b3e3-5dd7-81fa-82dc3d5acb9f', 'ef6fbfbe-1a13-56fc-b742-b5919e371d6d', 'Ivana', 'Istina, ali ja više volim ležeran stil.', 'Правда, але я більше люблю невимушений стиль.', 4);
  perform pg_temp.turn('704a8625-bf2b-57e7-a1d5-8f3d6c63c97c', 'ef6fbfbe-1a13-56fc-b742-b5919e371d6d', 'Daša', 'Znam, ti obožavaš traperice i tenisice.', 'Знаю, ти обожнюєш джинси й кросівки.', 5);
  perform pg_temp.turn('e7170e87-6409-5c82-9de2-4ae8e04c9a30', 'ef6fbfbe-1a13-56fc-b742-b5919e371d6d', 'Ivana', 'Tako je. Ako ti se svidi, uzmi je!', 'Саме так. Якщо тобі сподобається — бери!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('88452cda-09d5-540d-90b3-ea6a4b66c93e', v_lesson, 'Про смаки', 'O ukusima', 3222, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('ffd9e64c-0478-57de-bb65-334e08feb6c0', '88452cda-09d5-540d-90b3-ea6a4b66c93e', 'Marko', 'Darja, kakav je tvoj stil?', 'Даріє, який у тебе стиль?', 1);
  perform pg_temp.turn('8fd7f269-ca57-5b4f-b82c-3d1eadeb31f1', '88452cda-09d5-540d-90b3-ea6a4b66c93e', 'Darja', 'Volim sportsku odjeću. Visoke pete mi se ne sviđaju.', 'Люблю спортивний одяг. Високі підбори мені не подобаються.', 2);
  perform pg_temp.turn('03f6e328-19eb-5ea5-898c-d5dc5552f406', '88452cda-09d5-540d-90b3-ea6a4b66c93e', 'Marko', 'A meni se sviđaju moderni kaputi.', 'А мені подобаються сучасні пальта.', 3);
  perform pg_temp.turn('95d190fe-14c2-5b04-bf84-3ec3ba4de1c3', '88452cda-09d5-540d-90b3-ea6a4b66c93e', 'Darja', 'A što ti se uopće ne sviđa?', 'А що тобі зовсім не подобається?', 4);
  perform pg_temp.turn('b37c1283-5cf9-5ed9-a03c-e34f47519ccb', '88452cda-09d5-540d-90b3-ea6a4b66c93e', 'Marko', 'Šarene košulje. Grozne su!', 'Строкаті сорочки. Вони жахливі!', 5);
  perform pg_temp.turn('ba9a0e94-a57e-53b3-bacb-44265f4052a7', '88452cda-09d5-540d-90b3-ea6a4b66c93e', 'Darja', 'Stvarno? Moj brat ih obožava.', 'Справді? А мій брат їх обожнює.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A1 v3 (слова за темою, 2 діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 24: У приміряльні: розмір і фасон — новий урок: 17 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := '480b3ca1-58c7-5b6f-8a52-eff47d53b3e4';
  v_lesson constant uuid := '7fb1b6e5-93b4-5776-b82b-25e7769fd32d';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.3: місце 3 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 24: У приміряльні: розмір і фасон', 'Lekcija 24: U kabini: veličina i kroj', '["Сказати, як сидить одяг: tijesan, labav, predug", "Попросити кравчиню вкоротити чи пришити ґудзик", "Stoji ti, tijesno mi je: короткі форми давального"]'::jsonb, 15, 'PUBLISHED', 3);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Короткі форми давального: sviđa mi se' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Короткі форми давального: sviđa mi se»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'tijesan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'labav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prevelik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'premalen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rukav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nogavica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'džep', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gumb', v_pos);
  v_pos := pg_temp.word(v_lesson, 'patentni zatvarač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovratnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kroj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'model', v_pos);
  v_pos := pg_temp.word(v_lesson, 'duljina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stajati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odgovarati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skratiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krojačica', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2fe5bf2d-c332-54b1-83ad-eac74848bf4a', 'fill_in_the_blank', 'Ova jakna ti dobro ___.', 'stoji', '["stojim", "stoji", "stojiš", "stoje"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ef19f081-b95e-5a41-aaa2-e410354d4b1d', 'multiple_choice', 'Що означає «odgovarati»?', 'відповідати; підходити (за розміром, часом)', '["замалий", "тісний", "відповідати; підходити (за розміром, часом)", "модель"]'::jsonb, 'A1', 2, 'PUBLISHED', 'odgovarati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aaa60c01-2a5e-5c1a-8d8b-652f5219a3ff', 'multiple_choice', 'Що означає «stajati»?', 'стояти; коштувати; личити (stoji ti dobro)', '["стояти; коштувати; личити (stoji ti dobro)", "холоша (штанина)", "ґудзик; кнопка", "тісний"]'::jsonb, 'A1', 3, 'PUBLISHED', 'stajati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '109be072-db58-58cc-bf43-066946e877c9', 'multiple_choice', 'Що означає «labav»?', 'вільний, завеликий (про одяг); хиткий', '["ґудзик; кнопка", "кишеня", "вільний, завеликий (про одяг); хиткий", "кравчиня"]'::jsonb, 'A1', 4, 'PUBLISHED', 'labav', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '10ddcc69-a3aa-56b7-a097-7e780fe6b33d', 'multiple_choice', 'Як хорватською «кравчиня»?', 'krojačica', '["ovratnik", "stajati", "krojačica", "gumb"]'::jsonb, 'A1', 5, 'PUBLISHED', 'krojačica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ae3bf62d-85ba-554c-9f38-777615617188', 'multiple_choice', 'Як хорватською «замалий»?', 'premalen', '["premalen", "skratiti", "nogavica", "prevelik"]'::jsonb, 'A1', 6, 'PUBLISHED', 'premalen', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f0d006b6-65cb-5f37-a051-f85263075f14', 'type_answer', 'Напишіть хорватською: «комір»', 'ovratnik', null, 'A1', 7, 'PUBLISHED', 'ovratnik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1bf36ce8-3e69-5fe4-8f0b-e47add137970', 'type_answer', 'Напишіть хорватською: «тісний»', 'tijesan', null, 'A1', 8, 'PUBLISHED', 'tijesan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '20ee59c9-e7cb-560c-aea7-7e7dec7ada04', 'type_answer', 'Напишіть хорватською: «ґудзик; кнопка»', 'gumb', null, 'A1', 9, 'PUBLISHED', 'gumb', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a3181fb5-49d9-5ec5-befb-6b6311deed19', 'sentence_builder', 'Складіть: «Ці штани мені тісні.»', 'Ove hlače su mi tijesne.', '["tijesne.", "Ove", "su", "mi", "hlače"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '82703376-8bdb-50d8-b605-b2f9affac0ef', 'sentence_builder', 'Складіть: «Рукави тобі задовгі.»', 'Rukavi su ti predugi.', '["predugi.", "su", "ti", "Rukavi"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '66fe1c28-9c5a-5ded-9b58-8830939f8b07', 'listening', 'Прослухайте і складіть фразу', 'Nije, baš ti dobro stoji.', '["baš", "stoji.", "Nije,", "dobro", "ti"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2404e512-9aa3-5b94-9984-a0c42cd247b0', 'listening', 'Прослухайте і складіть фразу', 'Mogu ih skratiti. Koliko želite?', '["ih", "želite?", "skratiti.", "Mogu", "Koliko"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2866d8fc-bff7-5d07-a33f-4c119928881f', 'speaking', 'Як мені ця куртка?', 'Kako mi stoji ova jakna?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '460cf909-b965-5606-b5da-77968f78565e', 'speaking', 'Можете вкоротити ці штани?', 'Možete li skratiti ove hlače?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4c5f814c-b984-5ebb-9fe5-788fc3f03f88', v_lesson, 'У примірочній', 'U kabini', 3241, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('7a99d988-909e-5a0c-a22c-9e42af2d46d6', '4c5f814c-b984-5ebb-9fe5-788fc3f03f88', 'Daša', 'Ivana, kako mi stoji ova jakna?', 'Івано, як мені ця куртка?', 1);
  perform pg_temp.turn('1e89c4bb-477f-57da-a9c4-7647d36dbe54', '4c5f814c-b984-5ebb-9fe5-788fc3f03f88', 'Ivana', 'Kroj je lijep, ali rukavi su ti predugi.', 'Крій гарний, але рукави тобі задовгі.', 2);
  perform pg_temp.turn('81c93153-a503-5af0-8eb4-c17fb8f6ae62', '4c5f814c-b984-5ebb-9fe5-788fc3f03f88', 'Daša', 'A je li mi tijesna u ramenima?', 'А в плечах не тісна?', 3);
  perform pg_temp.turn('0245d73d-d6db-5a20-9a89-020595e42795', '4c5f814c-b984-5ebb-9fe5-788fc3f03f88', 'Ivana', 'Nije, baš ti dobro stoji.', 'Ні, вона тобі якраз пасує.', 4);
  perform pg_temp.turn('8b2075f1-5040-54e7-9663-4f01fec0ffdc', '4c5f814c-b984-5ebb-9fe5-788fc3f03f88', 'Daša', 'Šteta što nema džepova.', 'Шкода, що немає кишень.', 5);
  perform pg_temp.turn('6fc4e709-bc6f-55f6-9921-c7e4b552d437', '4c5f814c-b984-5ebb-9fe5-788fc3f03f88', 'Ivana', 'Ima, ovdje su, pored patentnog zatvarača.', 'Є, ось вони, біля блискавки.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('25bbf9a8-bff1-55e2-b965-20178164c2de', v_lesson, 'У кравчині', 'Kod krojačice', 3242, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('8318580c-9d4b-5ecd-8723-e66c61c8a44b', '25bbf9a8-bff1-55e2-b965-20178164c2de', 'Marko', 'Dobar dan, ove hlače su mi preduge.', 'Добрий день, ці штани мені задовгі.', 1);
  perform pg_temp.turn('6d49a813-2d8c-5467-add8-694d60c1f354', '25bbf9a8-bff1-55e2-b965-20178164c2de', 'Krojačica', 'Mogu ih skratiti. Koliko želite?', 'Можу їх укоротити. На скільки?', 2);
  perform pg_temp.turn('36a72711-064f-5273-bcb6-5747ee420321', '25bbf9a8-bff1-55e2-b965-20178164c2de', 'Marko', 'Tri centimetra. U struku su mi malo labave.', 'На три сантиметри. І в поясі вони трохи завеликі.', 3);
  perform pg_temp.turn('a7c28cca-8c70-560f-9646-e7c244fd1452', '25bbf9a8-bff1-55e2-b965-20178164c2de', 'Krojačica', 'Dobro. Trebate li još nešto?', 'Добре. Ще щось потрібно?', 4);
  perform pg_temp.turn('b3de84b9-5113-5109-a423-401b497617f0', '25bbf9a8-bff1-55e2-b965-20178164c2de', 'Marko', 'Na košulji nedostaje jedan gumb na ovratniku.', 'На сорочці бракує одного ґудзика на комірі.', 5);
  perform pg_temp.turn('e5b9afcd-886b-5465-a035-7e19f52c0948', '25bbf9a8-bff1-55e2-b965-20178164c2de', 'Krojačica', 'Sve će biti gotovo u petak.', 'Усе буде готово в п’ятницю.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A1 v3 (слова за темою, 2 діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.3 · урок 26: Прикраси й подарунки — новий урок: 19 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := '480b3ca1-58c7-5b6f-8a52-eff47d53b3e4';
  v_lesson constant uuid := '86d268a5-7193-53c5-955b-cf6cc69116f1';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.3: місце 5 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 26: Прикраси й подарунки', 'Lekcija 26: Nakit i pokloni', '["Вибрати прикрасу в ювелірному: prsten, lančić, naušnice", "Попросити загорнути подарунок", "Знахідний з прикметником: srebrnu narukvicu, zlatni prsten"]'::jsonb, 15, 'PUBLISHED', 5);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Знахідний відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Знахідний відмінок»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'nakit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zlatarna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prsten', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ogrlica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lančić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'privjesak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'narukvica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naušnice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'broš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ručni sat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zlato', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srebro', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pokloniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iznenađenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zamotati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ukrasni papir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrpca', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poklon bon', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f52a15f1-645f-5988-9e1f-82c1bc275007', 'fill_in_the_blank', 'Kupujem mami srebrnu ___.', 'narukvicu', '["narukvicu", "narukvica", "narukvicom", "narukvici"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '543d500a-61b6-5e19-9316-cc517e20bef9', 'multiple_choice', 'Що означає «dar»?', 'подарунок', '["подарунок", "наручний годинник", "подарувати", "намисто"]'::jsonb, 'A1', 2, 'PUBLISHED', 'dar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fabc855b-47eb-5546-8d61-9d241314aa55', 'multiple_choice', 'Що означає «zlato»?', 'золото', '["золото", "браслет", "подарувати", "ланцюжок"]'::jsonb, 'A1', 3, 'PUBLISHED', 'zlato', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2b862302-6c4f-58d3-a804-d1e42ed595fd', 'multiple_choice', 'Що означає «poklon bon»?', 'подарунковий сертифікат', '["стрічка", "кулон, підвіска; брелок", "подарунковий сертифікат", "подарувати"]'::jsonb, 'A1', 4, 'PUBLISHED', 'poklon bon', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '67112994-361f-52f1-9428-de63af475619', 'multiple_choice', 'Як хорватською «брошка»?', 'broš', '["nakit", "ručni sat", "iznenađenje", "broš"]'::jsonb, 'A1', 5, 'PUBLISHED', 'broš', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '74025a80-9efa-5e2b-91e5-1fd57bbadeae', 'multiple_choice', 'Як хорватською «сережки»?', 'naušnice', '["privjesak", "naušnice", "narukvica", "zamotati"]'::jsonb, 'A1', 6, 'PUBLISHED', 'naušnice', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e0df0dd-7422-5bd8-b0cd-633781829bb2', 'type_answer', 'Напишіть хорватською: «браслет»', 'narukvica', null, 'A1', 7, 'PUBLISHED', 'narukvica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '72be8525-699d-59a6-88f8-1ef60477ad46', 'type_answer', 'Напишіть хорватською: «намисто»', 'ogrlica', null, 'A1', 8, 'PUBLISHED', 'ogrlica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c03db46f-626e-5a8d-858a-ed909cfb18ce', 'type_answer', 'Напишіть хорватською: «загорнути, запакувати»', 'zamotati', null, 'A1', 9, 'PUBLISHED', 'zamotati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7d1b7aa7-882d-5816-892c-5e77f1962f55', 'sentence_builder', 'Складіть: «Я шукаю золоту каблучку.»', 'Tražim zlatni prsten.', '["Tražim", "prsten.", "zlatni"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '713d0126-e382-5bb2-9a9b-f838b97c6dd2', 'sentence_builder', 'Складіть: «Можете це загорнути?»', 'Možete li to zamotati?', '["li", "zamotati?", "Možete", "to"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a800b862-d9d4-59c8-9e89-deb127f32d45', 'listening', 'Прослухайте і складіть фразу', 'Srebro voli više nego zlato.', '["voli", "zlato.", "nego", "više", "Srebro"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '11d05ca5-831a-5658-a19f-2c23f69d32fc', 'listening', 'Прослухайте і складіть фразу', 'Dobra ideja. A za tatu ručni sat?', '["sat?", "ideja.", "tatu", "ručni", "Dobra", "za", "A"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2ed1d81d-68db-52ff-9fec-0fba761b77d2', 'speaking', 'Я шукаю подарунок для мами.', 'Tražim poklon za mamu.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '63ffb8cf-859f-5c74-b287-c8300ffbdbba', 'speaking', 'Загорніть, будь ласка, у подарунковий папір.', 'Zamotajte u ukrasni papir, molim.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('499b99ac-2eb8-5151-8931-80ec8d6f9261', v_lesson, 'У ювелірному', 'U zlatarni', 3261, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('e35123fe-358b-55f0-b6ee-a1bae114f4f9', '499b99ac-2eb8-5151-8931-80ec8d6f9261', 'Daša', 'Dobar dan, tražim poklon za mamu.', 'Добрий день, я шукаю подарунок для мами.', 1);
  perform pg_temp.turn('65203795-89fb-559a-84ce-feef9c1dac91', '499b99ac-2eb8-5151-8931-80ec8d6f9261', 'Zlatar', 'Imamo lijepe ogrlice i narukvice. Što ona voli?', 'У нас є гарні намиста й браслети. Що вона любить?', 2);
  perform pg_temp.turn('8388626d-23b7-5a32-942c-de6cb0a6eaaa', '499b99ac-2eb8-5151-8931-80ec8d6f9261', 'Daša', 'Srebro voli više nego zlato.', 'Срібло вона любить більше, ніж золото.', 3);
  perform pg_temp.turn('1366a29d-68be-5cf0-851b-f2aa237c4ef3', '499b99ac-2eb8-5151-8931-80ec8d6f9261', 'Zlatar', 'Pogledajte ovaj srebrni lančić s malim privjeskom.', 'Подивіться на цей срібний ланцюжок з маленьким кулоном.', 4);
  perform pg_temp.turn('7d198396-a4ea-5420-9dd5-2f9d25cfc6f3', '499b99ac-2eb8-5151-8931-80ec8d6f9261', 'Daša', 'Predivan je! Možete li ga zamotati?', 'Чудовий! Можете його загорнути?', 5);
  perform pg_temp.turn('e1c1e389-13be-5008-bb88-5bbaf706b83a', '499b99ac-2eb8-5151-8931-80ec8d6f9261', 'Zlatar', 'Naravno, u ukrasni papir s crvenom vrpcom.', 'Звісно, у подарунковий папір із червоною стрічкою.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b535b92f-2a0c-5a60-b82d-382e3714d145', v_lesson, 'Що подарувати?', 'Što pokloniti?', 3262, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('defc283e-da29-5992-bd35-39edda97fdfe', 'b535b92f-2a0c-5a60-b82d-382e3714d145', 'Marko', 'Darja, što da poklonim Ani za rođendan?', 'Даріє, що мені подарувати Ані на день народження?', 1);
  perform pg_temp.turn('853b2478-0be9-515e-92a1-c8ecf175cabf', 'b535b92f-2a0c-5a60-b82d-382e3714d145', 'Darja', 'Možda naušnice? Ona obožava nakit.', 'Може, сережки? Вона обожнює прикраси.', 2);
  perform pg_temp.turn('c56d44db-ebfc-5cc8-bf47-88c41491fe99', 'b535b92f-2a0c-5a60-b82d-382e3714d145', 'Marko', 'Ne znam kakve voli. Bojim se da pogriješim.', 'Не знаю, які вона любить. Боюся помилитися.', 3);
  perform pg_temp.turn('9e885d18-2158-543c-8024-673b533fe675', 'b535b92f-2a0c-5a60-b82d-382e3714d145', 'Darja', 'Onda joj kupi poklon bon za zlatarnu.', 'Тоді купи їй подарунковий сертифікат у ювелірний.', 4);
  perform pg_temp.turn('3d680512-bf71-570e-8a6c-b128800403fb', 'b535b92f-2a0c-5a60-b82d-382e3714d145', 'Marko', 'Dobra ideja. A za tatu ručni sat?', 'Гарна ідея. А татові наручний годинник?', 5);
  perform pg_temp.turn('95cb42fa-a6a7-5d62-b09a-a92efdab6232', 'b535b92f-2a0c-5a60-b82d-382e3714d145', 'Darja', 'Da, to će mu biti pravo iznenađenje.', 'Так, для нього це буде справжній сюрприз.', 6);
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
   where l.id in ('9a979d32-2f4b-5127-bc22-7292763c7de4', 'c8297811-44ed-55a2-8cb5-d1bd9b8a6a73', '7fb1b6e5-93b4-5776-b82b-25e7769fd32d', '9ba8e62a-83fd-5b08-9e01-760bc0f7219f', '86d268a5-7193-53c5-955b-cf6cc69116f1', '7042ff57-9a20-514a-ab80-71b6f63579f7', '6a7b0f42-510b-521e-9cc0-f77b2659d838', '91d4c9b3-c9a8-5e94-8691-6683835c375b')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 10 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_order from (values ('9a979d32-2f4b-5127-bc22-7292763c7de4'::uuid, 1), ('c8297811-44ed-55a2-8cb5-d1bd9b8a6a73'::uuid, 2), ('7fb1b6e5-93b4-5776-b82b-25e7769fd32d'::uuid, 3), ('9ba8e62a-83fd-5b08-9e01-760bc0f7219f'::uuid, 4), ('86d268a5-7193-53c5-955b-cf6cc69116f1'::uuid, 5), ('7042ff57-9a20-514a-ab80-71b6f63579f7'::uuid, 6), ('6a7b0f42-510b-521e-9cc0-f77b2659d838'::uuid, 7), ('91d4c9b3-c9a8-5e94-8691-6683835c375b'::uuid, 8)) as t(id, o)
    join public.lessons l on l.id = t.id and l.order_index = t.o and l.unit_id = '480b3ca1-58c7-5b6f-8a52-eff47d53b3e4';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A1' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('9a979d32-2f4b-5127-bc22-7292763c7de4', 'c8297811-44ed-55a2-8cb5-d1bd9b8a6a73', '7fb1b6e5-93b4-5776-b82b-25e7769fd32d', '9ba8e62a-83fd-5b08-9e01-760bc0f7219f', '86d268a5-7193-53c5-955b-cf6cc69116f1', '7042ff57-9a20-514a-ab80-71b6f63579f7', '6a7b0f42-510b-521e-9cc0-f77b2659d838', '91d4c9b3-c9a8-5e94-8691-6683835c375b') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A1.3: % уроків з неправильним складом', v_bad; end if;
  if v_order <> 8 then raise exception 'Модуль A1.3: на своїх місцях % уроків з 8', v_order; end if;
  if v_titles > 0 then raise exception 'A1: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A1.3: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A1.3 — 8 уроків за темою (5 перебудовано, 3 нових)';
end $$;

commit;
