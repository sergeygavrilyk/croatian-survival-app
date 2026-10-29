-- =====================================================================
-- Програма A1 v3 · модуль A1.10 «Подорожуємо Хорватією» · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_curriculum_a1_v3.py 10 (не редагуйте вручну).
--
-- Рішення власника 2026-10-21 / 2026-10-26: до 25 слів на урок — скільки потрібно темі, 90–95 % слів — нові для рівня,
-- діалоги під тему, частіше Даша / Дар’я; бета (PUBLISHED).
--   * Уроки 86–92: 4 наявних перебудовано, 3 нових. Слів у них: 93.
--     Кожен: 10–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 58.
--   * Нові теми граматики: «Майбутній час: ići ću, bit će».
--   * Нові правила до тем: «Ступені порівняння» (+1).
--   * Виправлено: obala — «берег; узбережжя»; odmor — «відпочинок; відпустка»; brod — «корабель; човен, катер» (стара версія — у content_versions).
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

-- 1. Нові слова й вирази A1.10 (58; наявні не змінюються)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('maestral', 'maestral', 'hr', 'noun', 'A1', 'маестраль (літній вітер з моря)', 'core', '{"gender": "m"}'::jsonb, '["Popodne puše maestral i nije prevruće."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('munja', 'munja', 'hr', 'noun', 'A1', 'блискавка', 'core', '{"gender": "f"}'::jsonb, '["Za vrijeme oluje vidjeli smo munje nad morem."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pljusak', 'pljusak', 'hr', 'noun', 'A1', 'злива', 'core', '{"gender": "m"}'::jsonb, '["Poslije podne su mogući pljuskovi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('toplinski val', 'toplinski val', 'hr', 'phrase', 'A1', 'спека (хвиля спеки)', 'collocation', '{"gender": "m"}'::jsonb, '["Toplinski val će trajati do petka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('razvedriti se', 'razvedriti se', 'hr', 'verb', 'A1', 'проясниться (про небо)', 'core', '{"aspect": "pfv", "present": {"1s": "razvedrim se", "2s": "razvedriš se", "3s": "razvedri se"}}'::jsonb, '["Popodne će se razvedriti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('naoblačiti se', 'naoblaciti se', 'hr', 'verb', 'A1', 'захмаритися', 'core', '{"aspect": "pfv", "present": {"1s": "naoblačim se", "2s": "naoblačiš se", "3s": "naoblači se"}}'::jsonb, '["Navečer će se naoblačiti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vjetrovit', 'vjetrovit', 'hr', 'adjective', 'A1', 'вітряний', 'core', '{"f": "vjetrovita", "n": "vjetrovito"}'::jsonb, '["Sutra će biti vjetrovito na obali."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kišovit', 'kisovit', 'hr', 'adjective', 'A1', 'дощовий', 'core', '{"f": "kišovita", "n": "kišovito"}'::jsonb, '["Studeni je kišovit mjesec."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('plan puta', 'plan puta', 'hr', 'phrase', 'A1', 'план подорожі, маршрут', 'collocation', '{"gender": "m"}'::jsonb, '["Napravit ćemo plan puta za cijeli tjedan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kampirati', 'kampirati', 'hr', 'verb', 'A1', 'жити в кемпінгу, кемпінгувати', 'core', '{"aspect": "ipfv", "present": {"1s": "kampiram", "2s": "kampiraš", "3s": "kampira"}}'::jsonb, '["Ljeti kampiramo na Krku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('šator', 'sator', 'hr', 'noun', 'A1', 'намет', 'core', '{"gender": "m"}'::jsonb, '["Ponijet ćemo šator i vreće za spavanje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('privatni smještaj', 'privatni smjestaj', 'hr', 'phrase', 'A1', 'приватне житло (апартаменти, кімнати)', 'collocation', '{"gender": "m"}'::jsonb, '["Privatni smještaj je jeftiniji od hotela."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('polupansion', 'polupansion', 'hr', 'noun', 'A1', 'напівпансіон', 'core', '{"gender": "m"}'::jsonb, '["Uzeli smo polupansion, doručak i večeru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('putno osiguranje', 'putno osiguranje', 'hr', 'phrase', 'A1', 'туристичне страхування', 'collocation', '{"gender": "n"}'::jsonb, '["Prije puta kupi putno osiguranje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sezona', 'sezona', 'hr', 'noun', 'A1', 'сезон', 'core', '{"gender": "f"}'::jsonb, '["U sezoni su cijene više."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('predsezona', 'predsezona', 'hr', 'noun', 'A1', 'початок сезону (до липня)', 'core', '{"gender": "f"}'::jsonb, '["U predsezoni je mirnije i jeftinije."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('razgledavanje', 'razgledavanje', 'hr', 'noun', 'A1', 'огляд визначних місць, екскурсія', 'core', '{"gender": "n"}'::jsonb, '["Prvi dan je za razgledavanje grada."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Istra', 'istra', 'hr', 'noun', 'A1', 'Істрія', 'core', '{"gender": "f"}'::jsonb, '["Istra je poznata po tartufima i vinu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Dalmacija', 'dalmacija', 'hr', 'noun', 'A1', 'Далмація', 'core', '{"gender": "f"}'::jsonb, '["Dalmacija ima puno otoka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Slavonija', 'slavonija', 'hr', 'noun', 'A1', 'Славонія', 'core', '{"gender": "f"}'::jsonb, '["U Slavoniji su velike ravnice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Zagorje', 'zagorje', 'hr', 'noun', 'A1', 'Загор’є (край на північ від Загреба)', 'core', '{"gender": "n"}'::jsonb, '["Zagorje ima puno dvoraca i brda."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Lika', 'lika', 'hr', 'noun', 'A1', 'Ліка (гірський край)', 'core', '{"gender": "f"}'::jsonb, '["Zima u Lici je hladna i snježna."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kontinentalni', 'kontinentalni', 'hr', 'adjective', 'A1', 'континентальний', 'core', '{"f": "kontinentalna", "n": "kontinentalno"}'::jsonb, '["Zagreb ima kontinentalnu klimu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('primorski', 'primorski', 'hr', 'adjective', 'A1', 'приморський', 'core', '{"f": "primorska", "n": "primorsko"}'::jsonb, '["Rijeka je primorski grad."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('narječje', 'narjecje', 'hr', 'noun', 'A1', 'наріччя, діалект', 'core', '{"gender": "n"}'::jsonb, '["U Zagorju govore kajkavsko narječje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dalmatinski', 'dalmatinski', 'hr', 'adjective', 'A1', 'далматинський', 'core', '{"f": "dalmatinska", "n": "dalmatinsko"}'::jsonb, '["Volim dalmatinsku kuhinju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('morske orgulje', 'morske orgulje', 'hr', 'phrase', 'A1', 'Морський орган (у Задарі)', 'collocation', '{"gender": "f_pl"}'::jsonb, '["Morske orgulje sviraju kad more udara o stube."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Pozdrav Suncu', 'pozdrav suncu', 'hr', 'phrase', 'A1', 'Вітання Сонцю (інсталяція в Задарі)', 'chunk', '{}'::jsonb, '["Navečer Pozdrav Suncu svijetli u svim bojama."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rimski', 'rimski', 'hr', 'adjective', 'A1', 'римський', 'core', '{"f": "rimska", "n": "rimsko"}'::jsonb, '["U centru Zadra je rimski forum."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('forum', 'forum', 'hr', 'noun', 'A1', 'форум (давня площа)', 'core', '{"gender": "m"}'::jsonb, '["Djeca se igraju na forumu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zvonik', 'zvonik', 'hr', 'noun', 'A1', 'дзвіниця', 'core', '{"gender": "m"}'::jsonb, '["Sa zvonika se vidi cijeli grad."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('klapa', 'klapa', 'hr', 'noun', 'A1', 'клапа (далматинський чоловічий спів)', 'core', '{"gender": "f"}'::jsonb, '["Na rivi pjeva klapa."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('maraskino', 'maraskino', 'hr', 'noun', 'A1', 'мараскіно (вишневий лікер)', 'core', '{"gender": "m"}'::jsonb, '["Maraskino se radi od višnje maraske."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('šetnica', 'setnica', 'hr', 'noun', 'A1', 'набережна, прогулянкова алея', 'core', '{"gender": "f"}'::jsonb, '["Navečer šetamo šetnicom uz more."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kupalište', 'kupaliste', 'hr', 'noun', 'A1', 'місце для купання, міський пляж', 'core', '{"gender": "n"}'::jsonb, '["Gradsko kupalište je blizu centra."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('otočje', 'otocje', 'hr', 'noun', 'A1', 'архіпелаг', 'core', '{"gender": "n"}'::jsonb, '["Ispred Zadra je veliko otočje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('katamaran', 'katamaran', 'hr', 'noun', 'A1', 'катамаран', 'core', '{"gender": "m"}'::jsonb, '["Katamaran do otoka je brži od trajekta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ukrcaj', 'ukrcaj', 'hr', 'noun', 'A1', 'посадка (на судно, літак)', 'core', '{"gender": "m"}'::jsonb, '["Ukrcaj automobila počinje pola sata prije polaska."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uvala', 'uvala', 'hr', 'noun', 'A1', 'бухта', 'core', '{"gender": "f"}'::jsonb, '["Našli smo malu mirnu uvalu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('suncobran', 'suncobran', 'hr', 'noun', 'A1', 'парасолька від сонця', 'core', '{"gender": "m"}'::jsonb, '["Ponesi suncobran na plažu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ležaljka', 'lezaljka', 'hr', 'noun', 'A1', 'шезлонг', 'core', '{"gender": "f"}'::jsonb, '["Najam ležaljke je deset eura na dan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ronjenje', 'ronjenje', 'hr', 'noun', 'A1', 'пірнання; дайвінг', 'core', '{"gender": "n"}'::jsonb, '["Na otoku ima škola ronjenja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kanjon', 'kanjon', 'hr', 'noun', 'A1', 'каньйон', 'core', '{"gender": "m"}'::jsonb, '["Rijeka teče kroz duboki kanjon."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zabranjeno kupanje', 'zabranjeno kupanje', 'hr', 'phrase', 'A1', 'купатися заборонено', 'chunk', '{}'::jsonb, '["Na Plitvicama je zabranjeno kupanje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('divlji', 'divlji', 'hr', 'adjective', 'A1', 'дикий', 'core', '{"f": "divlja", "n": "divlje"}'::jsonb, '["U šumi žive divlje životinje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vuk', 'vuk', 'hr', 'noun', 'A1', 'вовк', 'core', '{"gender": "m"}'::jsonb, '["Vukovi žive u Gorskom kotaru i Lici."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('lisica', 'lisica', 'hr', 'noun', 'A1', 'лисиця', 'core', '{"gender": "f"}'::jsonb, '["Lisica je pretrčala cestu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ris', 'ris', 'hr', 'noun', 'A1', 'рись', 'core', '{"gender": "m"}'::jsonb, '["Ris je rijedak i jako plah."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jelen', 'jelen', 'hr', 'noun', 'A1', 'олень', 'core', '{"gender": "m"}'::jsonb, '["U jesen se čuju jeleni u šumi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('srna', 'srna', 'hr', 'noun', 'A1', 'козуля', 'core', '{"gender": "f"}'::jsonb, '["Ujutro smo vidjeli srnu na livadi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('divlja svinja', 'divlja svinja', 'hr', 'phrase', 'A1', 'дикий кабан', 'collocation', '{"gender": "f"}'::jsonb, '["Divlje svinje noću dolaze do sela."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vjeverica', 'vjeverica', 'hr', 'noun', 'A1', 'білка', 'core', '{"gender": "f"}'::jsonb, '["U parku ima puno vjeverica."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sova', 'sova', 'hr', 'noun', 'A1', 'сова', 'core', '{"gender": "f"}'::jsonb, '["Noću se čuje sova."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('orao', 'orao', 'hr', 'noun', 'A1', 'орел', 'core', '{"gender": "m"}'::jsonb, '["Iznad kanjona leti orao."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zmija', 'zmija', 'hr', 'noun', 'A1', 'змія', 'core', '{"gender": "f"}'::jsonb, '["Na kamenju se sunča zmija."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('poskok', 'poskok', 'hr', 'noun', 'A1', 'носата гадюка (поскок)', 'core', '{"gender": "m"}'::jsonb, '["Poskok je otrovan, pazi na kamenju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dupin', 'dupin', 'hr', 'noun', 'A1', 'дельфін', 'core', '{"gender": "m"}'::jsonb, '["S broda smo vidjeli dupine."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('galeb', 'galeb', 'hr', 'noun', 'A1', 'чайка', 'core', '{"gender": "m"}'::jsonb, '["Galebovi su ukrali sendvič s plaže."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;

-- 1б. Виправлені слова (3); повторний запуск нічого не змінює
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'obala' and ukrainian_translation = 'берег / узбережжя' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'берег; узбережжя' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'odmor' and ukrainian_translation = 'відпочинок / відпустка' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'відпочинок; відпустка' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'brod' and ukrainian_translation = 'корабель' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'корабель; човен, катер' where id = r.id;
  end loop;
end $$;

-- 1а. Граматика A1.10: нові теми (1) і нові правила до наявних тем (1)
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '15163f41-aab2-587a-a920-768f085e93e2', 'A1', 'Майбутній час: ići ću, bit će', 'Futur I: ići ću, bit će', 'Майбутній час (futur I) = короткі форми htjeti (ću, ćeš, će, ćemo, ćete, će) + інфінітив. Без займенника: putovat ću, bit će; заперечення neću; питання hoćeš li…?', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Майбутній час: ići ću, bit će');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '92800d1a-5196-5f13-8a5e-dc87bf7d0de0', '15163f41-aab2-587a-a920-768f085e93e2', 'Ću + інфінітив: ja ću putovati', 'Майбутній час: ću, ćeš, će, ćemo, ćete, će + інфінітив. Коротка форма — на другому місці: Ja ću putovati. Sutra ćemo ići na more. Oni će doći u petak.', 'ja ću · ti ćeš · on će · mi ćemo · vi ćete · oni će + інфінітив', '[{"hr": "Ja ću putovati vlakom.", "ua": "Я поїду потягом."}, {"hr": "Sutra ćemo ići na Plitvice.", "ua": "Завтра ми поїдемо на Плітвіце."}, {"hr": "Oni će doći u petak.", "ua": "Вони приїдуть у п’ятницю."}, {"hr": "Što ćeš raditi ljeti?", "ua": "Що ти робитимеш улітку?"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '15163f41-aab2-587a-a920-768f085e93e2')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '88b7f817-9c47-502e-ac87-3124bb2c7d5c', '15163f41-aab2-587a-a920-768f085e93e2', 'Putovat ću, ići ću, bit će', 'Без займенника дієслово йде першим, і з інфінітива на -ti випадає -i: putovati → putovat ću, raditi → radit ću, biti → bit će. Дієслова на -ći не змінюються: ići ću, doći ćeš, moći će.', 'putovat ću · radit ćemo · bit će · ići ću', '[{"hr": "Putovat ću u Zadar.", "ua": "Я поїду в Задар."}, {"hr": "Bit će sunčano i toplo.", "ua": "Буде сонячно й тепло."}, {"hr": "Ići ćemo trajektom.", "ua": "Поїдемо поромом."}, {"hr": "Radit ću do petka.", "ua": "Працюватиму до п’ятниці."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '15163f41-aab2-587a-a920-768f085e93e2')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'ecbdc80f-619d-578f-9783-4e60ab9ef96d', '15163f41-aab2-587a-a920-768f085e93e2', 'Neću, hoćeš li…?', 'Заперечення — neću, nećeš, neće, nećemo, nećete, neće: Neću ići. Neće padati kiša. Питання — hoćeš li + інфінітив: Hoćeš li doći? Відповідь: Hoću. / Neću.', 'neću ići · Hoćeš li doći? — Hoću. / Neću.', '[{"hr": "Neću ići na posao sutra.", "ua": "Завтра я не піду на роботу."}, {"hr": "Neće padati kiša.", "ua": "Дощу не буде."}, {"hr": "Hoćeš li ići s nama?", "ua": "Ти поїдеш з нами?"}, {"hr": "Hoću, rado!", "ua": "Так, із задоволенням!"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '15163f41-aab2-587a-a920-768f085e93e2')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '8425a8c5-94b4-5ca9-b8fa-56ec85daab2d', '15163f41-aab2-587a-a920-768f085e93e2', 'Bit će: погода й плани', 'Про погоду й стан — bit će: Bit će sunčano. Bit će hladno. Sutra će biti oblačno. Про дію — će + дієслово: Puhat će bura. Padat će kiša. Порівняйте: bilo je (минуле), jest / je (тепер), bit će (майбутнє).', 'bilo je → je → bit će', '[{"hr": "Sutra će biti oblačno.", "ua": "Завтра буде хмарно."}, {"hr": "Puhat će jaka bura.", "ua": "Дутиме сильна бура."}, {"hr": "Bit će vruće, ponesi vodu.", "ua": "Буде спекотно, візьми воду."}, {"hr": "Jučer je bilo hladno, a sutra će biti toplo.", "ua": "Учора було холодно, а завтра буде тепло."}]'::jsonb, 4
where exists (select 1 from public.grammar_topics where id = '15163f41-aab2-587a-a920-768f085e93e2')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '15163f41-aab2-587a-a920-768f085e93e2', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '15163f41-aab2-587a-a920-768f085e93e2')
  and not exists (select 1 from public.content_reviews where entity_id = '15163f41-aab2-587a-a920-768f085e93e2' and notes = 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.');
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Ступені порівняння' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Ступені порівняння»'; end if;
  if exists (select 1 from public.grammar_rules where id = '0410f8da-f4ec-5a8f-88c1-a5ae36e80227') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('0410f8da-f4ec-5a8f-88c1-a5ae36e80227', v_topic, 'Najljepši u…, jedan od najljepših', 'Найвищий ступінь часто з u + місцевий або od + родовий: najljepši grad u Hrvatskoj, najviši od svih. «Один із найкращих» — jedan od + родовий множини: jedan od najljepših otoka, jedna od najstarijih crkava.', 'najljepši u Hrvatskoj · jedan od najljepših otoka', '[{"hr": "Plitvice su najpoznatiji park u Hrvatskoj.", "ua": "Плітвіце — найвідоміший парк у Хорватії."}, {"hr": "Hvar je jedan od najsunčanijih otoka.", "ua": "Хвар — один із найсонячніших островів."}, {"hr": "Ovo je najviši vrh u Lici.", "ua": "Це найвища вершина в Ліці."}, {"hr": "Zadar ima jedan od najljepših zalazaka sunca.", "ua": "У Задарі один із найгарніших заходів сонця."}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', '0410f8da-f4ec-5a8f-88c1-a5ae36e80227', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;

-- 2. Перебудова наявних уроків модуля A1.10
-- A1.10 · урок 86: Прогноз погоди — перебудова: 12 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '0cb42e87-0ece-5e12-a07c-05cb5c370157';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Прогноз погоди» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '3b8c9682-a1b1-5258-ba5b-9609db55ff78') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 86: Прогноз погоди', title_hr = 'Lekcija 86: Vremenska prognoza',
         objectives = '["Зрозуміти прогноз: bura, jugo, pljusak, toplinski val", "Розповісти, яка буде погода й що взяти", "Майбутній час: bit će sunčano, puhat će bura"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Майбутній час: ići ću, bit će' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Майбутній час: ići ću, bit će»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'bura', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jugo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maestral', v_pos);
  v_pos := pg_temp.word(v_lesson, 'munja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pljusak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'toplinski val', v_pos);
  v_pos := pg_temp.word(v_lesson, 'temperatura zraka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'godišnja doba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razvedriti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naoblačiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vjetrovit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kišovit', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '0451a616-e7c6-5b7e-b1a9-ffed1c9e4f69', 'fill_in_the_blank', 'Sutra ___ biti sunčano.', 'će', '["bi", "će", "ću", "je"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2825fe77-1000-5ab7-9039-ab6834e512b6', 'multiple_choice', 'Що означає «munja»?', 'блискавка', '["бура (сильний північний вітер)", "блискавка", "спека (хвиля спеки)", "проясниться (про небо)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'munja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c8f4699-a620-5bc2-a75d-c40cdc507ddd', 'multiple_choice', 'Що означає «maestral»?', 'маестраль (літній вітер з моря)', '["проясниться (про небо)", "злива", "спека (хвиля спеки)", "маестраль (літній вітер з моря)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'maestral', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c905597-5df8-5749-87a7-f29f8c4672d6', 'multiple_choice', 'Що означає «jugo»?', 'юго (південний вітер)', '["злива", "дощовий", "юго (південний вітер)", "проясниться (про небо)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'jugo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf7cb914-aa15-52e3-bd65-6a5c0b6f00ff', 'multiple_choice', 'Що означає «razvedriti se»?', 'проясниться (про небо)', '["злива", "проясниться (про небо)", "температура повітря", "блискавка"]'::jsonb, 'A1', 5, 'PUBLISHED', 'razvedriti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd731fe23-a25f-5f47-b127-f0df3d887917', 'multiple_choice', 'Як хорватською «вітряний»?', 'vjetrovit', '["maestral", "munja", "vjetrovit", "godišnja doba"]'::jsonb, 'A1', 6, 'PUBLISHED', 'vjetrovit', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8529c1ee-0d6d-5443-984f-c11faf8deacb', 'multiple_choice', 'Як хорватською «дощовий»?', 'kišovit', '["kišovit", "maestral", "razvedriti se", "temperatura zraka"]'::jsonb, 'A1', 7, 'PUBLISHED', 'kišovit', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '19180c87-6e1f-5319-a70f-37de53d563e5', 'type_answer', 'Напишіть хорватською: «захмаритися»', 'naoblačiti se', null, 'A1', 8, 'PUBLISHED', 'naoblačiti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3da0006a-976f-5d8a-9cc0-3966148fa1d8', 'type_answer', 'Напишіть хорватською: «злива»', 'pljusak', null, 'A1', 9, 'PUBLISHED', 'pljusak', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '99f92a43-b268-5d20-a8cf-75ac6b65387a', 'sentence_builder', 'Складіть: «Завтра буде вітряно.»', 'Sutra će biti vjetrovito.', '["Sutra", "biti", "će", "vjetrovito."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fececac5-5bf3-5ccb-ae1c-a55ca68fc7bf', 'sentence_builder', 'Складіть: «Дутиме сильна бура.»', 'Puhat će jaka bura.', '["će", "jaka", "bura.", "Puhat"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c87b0211-43fe-5222-9293-72c2fb199513', 'listening', 'Прослухайте і складіть фразу', 'A u nedjelju?', '["A", "nedjelju?", "u"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '401c2759-c4ef-5bd3-bb7c-dd621fe1f705', 'listening', 'Прослухайте і складіть фразу', 'Koliko će biti stupnjeva?', '["stupnjeva?", "će", "biti", "Koliko"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '851a5fa4-b8d3-5386-bab5-241413be303a', 'speaking', 'Яка буде погода завтра?', 'Kakvo će biti vrijeme sutra?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2e1563ca-fddb-535c-a7dd-99e34c221ee2', 'speaking', 'Буде дощ.', 'Padat će kiša.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3b8c9682-a1b1-5258-ba5b-9609db55ff78', v_lesson, 'Прогноз на вихідні', 'Prognoza za vikend', 3861, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('9dcb955c-82ad-5254-abcc-2882b56e24ad', '3b8c9682-a1b1-5258-ba5b-9609db55ff78', 'Luka', 'Dašo, kakvo će biti vrijeme za vikend?', 'Дашо, яка буде погода на вихідні?', 1);
  perform pg_temp.turn('797f1b7d-b2c1-531b-9cf6-738a5e9980f5', '3b8c9682-a1b1-5258-ba5b-9609db55ff78', 'Daša', 'U subotu će puhati bura, bit će hladno i vjetrovito.', 'У суботу дутиме бура, буде холодно й вітряно.', 2);
  perform pg_temp.turn('b28a1f45-d120-503d-8134-e8cda310908c', '3b8c9682-a1b1-5258-ba5b-9609db55ff78', 'Luka', 'A u nedjelju?', 'А в неділю?', 3);
  perform pg_temp.turn('0693fe4a-c333-5287-8029-953daefcbea4', '3b8c9682-a1b1-5258-ba5b-9609db55ff78', 'Daša', 'Ujutro će se razvedriti, ali popodne su mogući pljuskovi.', 'Зранку проясниться, але по обіді можливі зливи.', 4);
  perform pg_temp.turn('1af3f70f-be69-53c3-b961-2539dd7b29c4', '3b8c9682-a1b1-5258-ba5b-9609db55ff78', 'Luka', 'Onda ćemo ići na izlet u subotu ujutro.', 'Тоді поїдемо на прогулянку в суботу зранку.', 5);
  perform pg_temp.turn('6753e749-3522-54cb-9946-a3412037160a', '3b8c9682-a1b1-5258-ba5b-9609db55ff78', 'Daša', 'Može, ali ponijet ću jaknu.', 'Добре, але я візьму куртку.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('db7eb327-1bcd-5d5b-8276-f54558652b1b', v_lesson, 'Літо на морі', 'Ljeto na moru', 3862, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('9542f6f0-f0d5-56e8-a96b-8d6a7efa5705', 'db7eb327-1bcd-5d5b-8276-f54558652b1b', 'Marko', 'Darja, na radiju kažu da dolazi toplinski val.', 'Даріє, по радіо кажуть, що наближається спека.', 1);
  perform pg_temp.turn('8c7c6a9e-3a9d-5626-b4e3-e23f75e1541a', 'db7eb327-1bcd-5d5b-8276-f54558652b1b', 'Darja', 'Koliko će biti stupnjeva?', 'Скільки буде градусів?', 2);
  perform pg_temp.turn('9bc2f489-fe39-525b-9739-f22038e0baee', 'db7eb327-1bcd-5d5b-8276-f54558652b1b', 'Marko', 'Temperatura zraka do trideset osam.', 'Температура повітря до тридцяти восьми.', 3);
  perform pg_temp.turn('07e10069-245d-57a9-a449-f4725bab8cd2', 'db7eb327-1bcd-5d5b-8276-f54558652b1b', 'Darja', 'Joj! A hoće li puhati maestral?', 'Ой! А маестраль дутиме?', 4);
  perform pg_temp.turn('f5295d6c-0a33-5918-80e5-f73bb9c40e8f', 'db7eb327-1bcd-5d5b-8276-f54558652b1b', 'Marko', 'Hoće, popodne, pa neće biti tako vruće.', 'Так, по обіді, тож не буде так спекотно.', 5);
  perform pg_temp.turn('3292f583-827a-547c-b01e-d51ec6881659', 'db7eb327-1bcd-5d5b-8276-f54558652b1b', 'Darja', 'Samo da ne bude juga, onda je more nemirno.', 'Аби тільки не було юга, тоді море неспокійне.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 88: Краї Хорватії — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '8633c234-d638-57f1-ad92-1c78be43fb07';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Краї Хорватії» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'd2290764-0de6-5876-aca5-798cdec8a609') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 88: Краї Хорватії', title_hr = 'Lekcija 88: Hrvatski krajevi',
         objectives = '["Назвати краї Хорватії: Istra, Dalmacija, Slavonija, Zagorje, Lika", "Порівняти краї: найбільший, один із найгарніших", "Найвищий ступінь: najveći u…, jedan od najljepših"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Ступені порівняння' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Ступені порівняння»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'Istra', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Dalmacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Slavonija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Zagorje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Lika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poluotok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ravnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brdo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dolina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rijeka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kontinentalni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'primorski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'narječje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvučati', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '36b06828-fcd1-565a-8c2b-0135dd197f18', 'fill_in_the_blank', 'Istra je ___ poluotok u Hrvatskoj.', 'najveći', '["najveće", "najviše", "najveći", "najveća"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '32c72706-8e63-56df-884d-10acf8fdfb56', 'multiple_choice', 'Що означає «Lika»?', 'Ліка (гірський край)', '["Ліка (гірський край)", "Далмація", "річка", "долина"]'::jsonb, 'A1', 2, 'PUBLISHED', 'Lika', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '00745061-6c6c-5802-a4f7-1737ffb6d803', 'multiple_choice', 'Що означає «Zagorje»?', 'Загор’є (край на північ від Загреба)', '["Істрія", "рівнина", "Загор’є (край на північ від Загреба)", "річка"]'::jsonb, 'A1', 3, 'PUBLISHED', 'Zagorje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c1aa9aab-6dd5-529b-8e32-7076f6305330', 'multiple_choice', 'Що означає «Dalmacija»?', 'Далмація', '["приморський", "Загор’є (край на північ від Загреба)", "наріччя, діалект", "Далмація"]'::jsonb, 'A1', 4, 'PUBLISHED', 'Dalmacija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e2bf4765-ebf9-5ca4-ad69-47da863300b2', 'multiple_choice', 'Як хорватською «Істрія»?', 'Istra', '["rijeka", "Dalmacija", "zvučati", "Istra"]'::jsonb, 'A1', 5, 'PUBLISHED', 'Istra', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '75528215-c958-54da-963c-0e898675316c', 'multiple_choice', 'Як хорватською «пагорб»?', 'brdo', '["primorski", "rijeka", "zvučati", "brdo"]'::jsonb, 'A1', 6, 'PUBLISHED', 'brdo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6fcaefbb-74d7-50da-96a0-fa671a664833', 'type_answer', 'Напишіть хорватською: «приморський»', 'primorski', null, 'A1', 7, 'PUBLISHED', 'primorski', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '72b2f068-715e-5106-aced-c58418343fde', 'type_answer', 'Напишіть хорватською: «Славонія»', 'Slavonija', null, 'A1', 8, 'PUBLISHED', 'Slavonija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '02e5bb05-7623-506d-94e0-502dce36650e', 'type_answer', 'Напишіть хорватською: «наріччя, діалект»', 'narječje', null, 'A1', 9, 'PUBLISHED', 'narječje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '600d5864-44ca-51d1-bcea-5f1f2a6ec3fa', 'sentence_builder', 'Складіть: «Славонія на сході.»', 'Slavonija je na istoku.', '["je", "Slavonija", "na", "istoku."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0918dcf4-f4dc-5d31-a608-aa0801ee0f65', 'sentence_builder', 'Складіть: «Це один із найгарніших островів.»', 'To je jedan od najljepših otoka.', '["je", "najljepših", "otoka.", "jedan", "od", "To"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '07c89287-680a-589e-b7c4-9b28f8aa17c1', 'listening', 'Прослухайте і складіть фразу', 'A gdje su ravnice?', '["gdje", "A", "ravnice?", "su"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '16d03b6b-50e8-509f-b9f4-a9fa31144acc', 'listening', 'Прослухайте і складіть фразу', 'Koji je kraj najljepši?', '["najljepši?", "Koji", "kraj", "je"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a7cf1046-2c7e-56ba-a8ca-735844b5ddaa', 'speaking', 'Звідки ти, з якого краю?', 'Iz kojeg si kraja?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3419920d-ba88-5b88-bf34-6215a3975064', 'speaking', 'Далмація найгарніша.', 'Dalmacija je najljepša.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d2290764-0de6-5876-aca5-798cdec8a609', v_lesson, 'Карта Хорватії', 'Karta Hrvatske', 3881, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('75fcb4ff-f79d-56a1-90b3-e4ec1e4eebc1', 'd2290764-0de6-5876-aca5-798cdec8a609', 'Filip', 'Mama, koji je najveći poluotok u Hrvatskoj?', 'Мамо, який найбільший півострів у Хорватії?', 1);
  perform pg_temp.turn('b59dcfa0-b63f-534b-bfce-5d7fd630b2e2', 'd2290764-0de6-5876-aca5-798cdec8a609', 'Daša', 'Istra. Tamo su najbolji tartufi.', 'Істрія. Там найкращі трюфелі.', 2);
  perform pg_temp.turn('b3475625-d735-51e5-876b-6b86a6e14a6d', 'd2290764-0de6-5876-aca5-798cdec8a609', 'Filip', 'A gdje su ravnice?', 'А де рівнини?', 3);
  perform pg_temp.turn('0a35e44e-3921-5254-81f8-da7591c7bd6d', 'd2290764-0de6-5876-aca5-798cdec8a609', 'Daša', 'U Slavoniji, na istoku. Tamo teku velike rijeke.', 'У Славонії, на сході. Там течуть великі річки.', 4);
  perform pg_temp.turn('552a0a8a-0062-5d35-b9c9-ce97895d0816', 'd2290764-0de6-5876-aca5-798cdec8a609', 'Filip', 'A Zagorje?', 'А Загор’є?', 5);
  perform pg_temp.turn('2f49655c-22c6-53b5-89bf-db513c3b6c56', 'd2290764-0de6-5876-aca5-798cdec8a609', 'Daša', 'Sjeverno od Zagreba, puno brda i dolina.', 'На північ від Загреба, багато пагорбів і долин.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d4183797-ac5e-5cc4-ae8b-28172503d20b', v_lesson, 'Як вони говорять?', 'Kako govore?', 3882, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('d239942a-cc0a-52d7-9135-ca1db259d095', 'd4183797-ac5e-5cc4-ae8b-28172503d20b', 'Darja', 'Zašto ljudi u Zagorju drugačije govore?', 'Чому люди в Загор’ї говорять інакше?', 1);
  perform pg_temp.turn('684987e5-aa2a-5c42-9412-0cab3c7f2982', 'd4183797-ac5e-5cc4-ae8b-28172503d20b', 'Marko', 'To je kajkavsko narječje. U Dalmaciji zvuči opet drugačije.', 'Це кайкавське наріччя. У Далмації звучить знову інакше.', 2);
  perform pg_temp.turn('d73a4172-8ef6-5e9a-902f-aba202b16537', 'd4183797-ac5e-5cc4-ae8b-28172503d20b', 'Darja', 'A Lika?', 'А Ліка?', 3);
  perform pg_temp.turn('ddf35a6e-74fc-5f60-949e-da76c909df42', 'd4183797-ac5e-5cc4-ae8b-28172503d20b', 'Marko', 'Lika je kontinentalna, zime su najhladnije.', 'Ліка — континентальна, зими там найхолодніші.', 4);
  perform pg_temp.turn('cfa38e75-549b-5e79-b848-dc2720bef1dd', 'd4183797-ac5e-5cc4-ae8b-28172503d20b', 'Darja', 'Koji je kraj najljepši?', 'Який край найгарніший?', 5);
  perform pg_temp.turn('4c0b5061-4108-5317-b974-16051eaa4be2', 'd4183797-ac5e-5cc4-ae8b-28172503d20b', 'Marko', 'Za mene primorski, Dalmacija je jedna od najljepših regija.', 'Для мене приморський, Далмація — один із найгарніших регіонів.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 90: На острів: пором і море — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '71ab330d-abbe-57a7-870e-77e59daf3627';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «На острів: пором і море» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'df1e30a3-97c0-597a-8fb7-ad47d9cc7cf1') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 90: На острів: пором і море', title_hr = 'Lekcija 90: Na otok: trajekt i more',
         objectives = '["Поїхати на острів поромом чи катамараном", "Обрати пляж і взяти шезлонг", "Місцевий: na otoku, u uvali, na plaži"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Місцевий відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Місцевий відмінок»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'otok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trajektna luka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'katamaran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ukrcaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uvala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pješčana plaža', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šljunčana plaža', v_pos);
  v_pos := pg_temp.word(v_lesson, 'suncobran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ležaljka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'val', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ronjenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odmor', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '780654b9-8950-5856-8445-dda0f6c420fc', 'fill_in_the_blank', 'Ljeti živimo na ___.', 'otoku', '["otoka", "otokom", "otok", "otoku"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b03a80f8-4aba-5d0f-aa21-808c13a5be54', 'multiple_choice', 'Що означає «kupati se»?', 'купатися', '["катамаран", "посадка (на судно, літак)", "купатися", "відпочинок; відпустка"]'::jsonb, 'A1', 2, 'PUBLISHED', 'kupati se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4362f4a8-11de-5b84-acbb-b3537d6fc825', 'multiple_choice', 'Що означає «pješčana plaža»?', 'піщаний пляж', '["піщаний пляж", "берег; узбережжя", "пірнання; дайвінг", "бухта"]'::jsonb, 'A1', 3, 'PUBLISHED', 'pješčana plaža', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7df9878e-2001-56bf-ae1b-7df2b1082326', 'multiple_choice', 'Що означає «ukrcaj»?', 'посадка (на судно, літак)', '["посадка (на судно, літак)", "відпочинок; відпустка", "поромний порт", "берег; узбережжя"]'::jsonb, 'A1', 4, 'PUBLISHED', 'ukrcaj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '694a8664-ebf8-51ef-a5e9-50bfb7297a73', 'multiple_choice', 'Як хорватською «шезлонг»?', 'ležaljka', '["šljunčana plaža", "katamaran", "ležaljka", "ronjenje"]'::jsonb, 'A1', 5, 'PUBLISHED', 'ležaljka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'df31f3d3-b5c6-5b6c-ac51-c84432956bfd', 'multiple_choice', 'Як хорватською «катамаран»?', 'katamaran', '["suncobran", "otok", "uvala", "katamaran"]'::jsonb, 'A1', 6, 'PUBLISHED', 'katamaran', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '32eba7a7-b50f-566e-8372-52ac54c7058d', 'type_answer', 'Напишіть хорватською: «поромний порт»', 'trajektna luka', null, 'A1', 7, 'PUBLISHED', 'trajektna luka', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9c0d8b81-7be6-54ac-a0b7-4bd272dbd723', 'type_answer', 'Напишіть хорватською: «острів»', 'otok', null, 'A1', 8, 'PUBLISHED', 'otok', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f3cae1eb-29f9-520f-9695-15a68c3237d0', 'type_answer', 'Напишіть хорватською: «пірнання; дайвінг»', 'ronjenje', null, 'A1', 9, 'PUBLISHED', 'ronjenje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a75d3a7-7c2f-59e1-a143-b7e9dd9fe2e5', 'sentence_builder', 'Складіть: «Ми на пляжі.»', 'Mi smo na plaži.', '["na", "Mi", "plaži.", "smo"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '33b00953-91d1-5d09-bd8b-8898d04da29a', 'sentence_builder', 'Складіть: «Коли відправляється пором?»', 'Kada polazi trajekt?', '["trajekt?", "polazi", "Kada"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '302015b1-1115-5086-9029-541ef504869c', 'listening', 'Прослухайте і складіть фразу', 'Je li danas more mirno?', '["mirno?", "danas", "more", "Je", "li"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '640a2f04-03dd-503e-8ae9-8b347259a081', 'listening', 'Прослухайте і складіть фразу', 'Smijem li se kupati odmah?', '["odmah?", "Smijem", "li", "kupati", "se"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '67dea768-627a-5258-8284-b776ea92c403', 'speaking', 'Квиток на пором, будь ласка.', 'Kartu za trajekt, molim.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9a973770-9f2c-5a65-994c-bfa512c4eb4a', 'speaking', 'Скільки коштує шезлонг?', 'Koliko košta ležaljka?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('df1e30a3-97c0-597a-8fb7-ad47d9cc7cf1', v_lesson, 'У поромному порту', 'U trajektnoj luci', 3901, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('752d3586-b338-5acf-a4e5-08ff827949a5', 'df1e30a3-97c0-597a-8fb7-ad47d9cc7cf1', 'Daša', 'Dobar dan, kada polazi trajekt za Brač?', 'Добрий день, коли відправляється пором на Брач?', 1);
  perform pg_temp.turn('3de4ee5d-a681-5c12-903a-8ae7a8fed0d0', 'df1e30a3-97c0-597a-8fb7-ad47d9cc7cf1', 'Blagajnik', 'U devet. Katamaran je u deset i brži je.', 'О дев’ятій. Катамаран о десятій, і він швидший.', 2);
  perform pg_temp.turn('960509be-6ea3-552f-9c65-80a164ec39bf', 'df1e30a3-97c0-597a-8fb7-ad47d9cc7cf1', 'Daša', 'Putujemo autom, pa uzimamo trajekt.', 'Ми їдемо машиною, тож беремо пором.', 3);
  perform pg_temp.turn('05ab5188-8aa2-5947-9d8a-729fe2575d55', 'df1e30a3-97c0-597a-8fb7-ad47d9cc7cf1', 'Blagajnik', 'Ukrcaj automobila počinje pola sata prije polaska.', 'Посадка автомобілів починається за пів години до відправлення.', 4);
  perform pg_temp.turn('180d552d-b06e-5de5-84d9-60f7162b0d9c', 'df1e30a3-97c0-597a-8fb7-ad47d9cc7cf1', 'Daša', 'Je li danas more mirno?', 'Сьогодні море спокійне?', 5);
  perform pg_temp.turn('7165aec6-7ded-54ad-a8df-137f8dc35801', 'df1e30a3-97c0-597a-8fb7-ad47d9cc7cf1', 'Blagajnik', 'Ima malo valova, ali trajekt vozi.', 'Є невеликі хвилі, але пором ходить.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c047cffc-eeee-570b-9b78-9fdd74681a68', v_lesson, 'На пляжі', 'Na plaži', 3902, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('ace7e998-3506-544b-91f5-30f779a22591', 'c047cffc-eeee-570b-9b78-9fdd74681a68', 'Filip', 'Mama, idemo na pješčanu plažu!', 'Мамо, ходімо на піщаний пляж!', 1);
  perform pg_temp.turn('34ca48f2-866b-58c4-a7c8-ea001207f287', 'c047cffc-eeee-570b-9b78-9fdd74681a68', 'Darja', 'Na otoku su uglavnom šljunčane plaže.', 'На острові здебільшого гальковий пляж.', 2);
  perform pg_temp.turn('668d8c6f-e896-5a84-97bc-b7d254bb6c9d', 'c047cffc-eeee-570b-9b78-9fdd74681a68', 'Filip', 'Može li onda u onu malu uvalu?', 'Тоді можна в ту маленьку бухту?', 3);
  perform pg_temp.turn('82622ecd-bff1-5526-8715-ffce87f9c9ef', 'c047cffc-eeee-570b-9b78-9fdd74681a68', 'Darja', 'Može. Uzmi suncobran, ja nosim ležaljku.', 'Можна. Візьми парасольку, а я понесу шезлонг.', 4);
  perform pg_temp.turn('5de3a797-e259-558c-8daa-9b68a25b1ea0', 'c047cffc-eeee-570b-9b78-9fdd74681a68', 'Filip', 'Smijem li se kupati odmah?', 'Можна мені одразу купатися?', 5);
  perform pg_temp.turn('0cd8cdf2-4aed-5285-b723-ed46b531e1e6', 'c047cffc-eeee-570b-9b78-9fdd74681a68', 'Darja', 'Smiješ, a poslije ćemo probati ronjenje uz obalu.', 'Можна, а потім спробуємо пірнати біля берега.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 91: Національні парки — перебудова: 12 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '84a20a00-701a-5ce5-a3c8-fca72986f912';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Національні парки» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '5836cb6f-36e1-5bf8-a17a-6ffd43783b62') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 91: Національні парки', title_hr = 'Lekcija 91: Nacionalni parkovi',
         objectives = '["Відвідати національний парк: slap, jezero, kanjon, špilja", "Зрозуміти правила парку", "Куди? — na Plitvice; де? — na Plitvicama"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Kamo? і Gdje?: u grad — u gradu' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Kamo? і Gdje?: u grad — u gradu»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'nacionalni park', v_pos);
  v_pos := pg_temp.word(v_lesson, 'park prirode', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slap', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jezero', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šuma', v_pos);
  v_pos := pg_temp.word(v_lesson, 'špilja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kanjon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izvor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'priroda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaštićen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zabranjeno kupanje', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '9a5c3376-0af4-5610-bc81-97894ab9380f', 'fill_in_the_blank', 'Sutra idemo ___ Plitvice.', 'na', '["kod", "iz", "u", "na"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '93c01db5-3dbc-57cf-b377-c800f6706413', 'multiple_choice', 'Що означає «zabranjeno kupanje»?', 'купатися заборонено', '["озеро", "захищений; заповідний", "купатися заборонено", "джерело"]'::jsonb, 'A1', 2, 'PUBLISHED', 'zabranjeno kupanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e93aec2b-a0a0-58e4-8274-ed28106c7cc7', 'multiple_choice', 'Що означає «park prirode»?', 'природний парк', '["каньйон", "природний парк", "печера", "природа"]'::jsonb, 'A1', 3, 'PUBLISHED', 'park prirode', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1eb9e521-c545-5a40-aea3-9a4d5b0084f8', 'multiple_choice', 'Що означає «nacionalni park»?', 'національний парк', '["національний парк", "джерело", "печера", "ліс"]'::jsonb, 'A1', 4, 'PUBLISHED', 'nacionalni park', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '41d4d6b1-0b40-5812-802a-6a62fb421aae', 'multiple_choice', 'Як хорватською «захищений; заповідний»?', 'zaštićen', '["špilja", "kanjon", "zaštićen", "jezero"]'::jsonb, 'A1', 5, 'PUBLISHED', 'zaštićen', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4efc8d1f-bd72-5b94-9824-4427a387aecd', 'multiple_choice', 'Як хорватською «печера»?', 'špilja', '["priroda", "šuma", "špilja", "park prirode"]'::jsonb, 'A1', 6, 'PUBLISHED', 'špilja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3fa4a485-e298-583b-ba87-fbf070dc9b05', 'type_answer', 'Напишіть хорватською: «ліс»', 'šuma', null, 'A1', 7, 'PUBLISHED', 'šuma', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '29be0059-2f75-5a3f-ad11-469e4abdf43b', 'type_answer', 'Напишіть хорватською: «джерело»', 'izvor', null, 'A1', 8, 'PUBLISHED', 'izvor', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3f85d831-7d01-56dd-b6b8-1e7d9b078d2d', 'type_answer', 'Напишіть хорватською: «каньйон»', 'kanjon', null, 'A1', 9, 'PUBLISHED', 'kanjon', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ca8d815d-0cda-5281-b459-2ea9d9d165da', 'sentence_builder', 'Складіть: «Купатися заборонено.»', 'Ovdje je zabranjeno kupanje.', '["Ovdje", "zabranjeno", "kupanje.", "je"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '29ea04ba-6545-5341-82a6-b757b034f1b3', 'sentence_builder', 'Складіть: «Ми були в національному парку.»', 'Bili smo u nacionalnom parku.', '["Bili", "u", "nacionalnom", "parku.", "smo"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c882a275-7ac2-5b3c-b875-1ece94d274bf', 'listening', 'Прослухайте і складіть фразу', 'Može li se kupati u jezerima?', '["kupati", "se", "li", "u", "jezerima?", "Može"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9a0fb326-fe41-537f-962b-e236280d8b3b', 'listening', 'Прослухайте і складіть фразу', 'Nisam. Što ima ondje?', '["ondje?", "ima", "Što", "Nisam."]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eec2b96e-aa34-533a-90ec-c592c68e749e', 'speaking', 'Поїдемо на Плітвіце.', 'Idemo na Plitvice.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5700b209-996d-5022-a055-e44c0ecca1ad', 'speaking', 'Я люблю природу.', 'Volim prirodu.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5836cb6f-36e1-5bf8-a17a-6ffd43783b62', v_lesson, 'Плітвіце', 'Na Plitvicama', 3911, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('8a263cfc-158a-581a-8f2e-5b1eea1be02f', '5836cb6f-36e1-5bf8-a17a-6ffd43783b62', 'Daša', 'Idemo li sutra na Plitvice ili na Krku?', 'Поїдемо завтра на Плітвіце чи на Крку?', 1);
  perform pg_temp.turn('442dc4b7-b2ee-53f2-9e09-1228c30ffc93', '5836cb6f-36e1-5bf8-a17a-6ffd43783b62', 'Luka', 'Na Plitvice. Ondje su najljepša jezera i slapovi.', 'На Плітвіце. Там найгарніші озера й водоспади.', 2);
  perform pg_temp.turn('3998d899-e647-5a89-9b9b-7dfccecc06b5', '5836cb6f-36e1-5bf8-a17a-6ffd43783b62', 'Daša', 'Može li se kupati u jezerima?', 'Можна купатися в озерах?', 3);
  perform pg_temp.turn('637787b8-e207-530c-9427-c98f9c0e1ef7', '5836cb6f-36e1-5bf8-a17a-6ffd43783b62', 'Luka', 'Ne, zabranjeno je kupanje, cijeli park je zaštićen.', 'Ні, купатися заборонено, весь парк заповідний.', 4);
  perform pg_temp.turn('c6bfda0d-8c4e-5e91-9977-acc7899cced0', '5836cb6f-36e1-5bf8-a17a-6ffd43783b62', 'Daša', 'A na Krki?', 'А на Крці?', 5);
  perform pg_temp.turn('efaf9e5d-f8cb-5114-b1d5-c08abc748bf2', '5836cb6f-36e1-5bf8-a17a-6ffd43783b62', 'Luka', 'Ni ondje više nije dopušteno. Ali vozi brod po rijeci.', 'Там теж більше не дозволено. Але по річці ходить катер.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a6af3a8f-f45c-526b-a461-050e7a7ab940', v_lesson, 'Печера й каньйон', 'Špilja i kanjon', 3912, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('975e3e07-e356-501d-a2a8-2ae001106ba5', 'a6af3a8f-f45c-526b-a461-050e7a7ab940', 'Marko', 'Darja, jesi li bila u parku prirode Velebit?', 'Даріє, ти була в природному парку Велебіт?', 1);
  perform pg_temp.turn('15acda0f-6d40-5874-b37f-4d9c876d69b5', 'a6af3a8f-f45c-526b-a461-050e7a7ab940', 'Darja', 'Nisam. Što ima ondje?', 'Ні. Що там є?', 2);
  perform pg_temp.turn('b9184e68-2f3a-5e29-acf6-5ffa27733155', 'a6af3a8f-f45c-526b-a461-050e7a7ab940', 'Marko', 'Duboke špilje, kanjon i šume.', 'Глибокі печери, каньйон і ліси.', 3);
  perform pg_temp.turn('0a91cdfe-14bb-530b-bab2-c8412016c302', 'a6af3a8f-f45c-526b-a461-050e7a7ab940', 'Darja', 'Ima li izvora pitke vode?', 'Там є джерела питної води?', 4);
  perform pg_temp.turn('cf05ad19-071a-570f-ad86-a6c9bddd3e81', 'a6af3a8f-f45c-526b-a461-050e7a7ab940', 'Marko', 'Ima, ali ponesi i svoju vodu.', 'Є, але візьми й свою воду.', 5);
  perform pg_temp.turn('51351021-8af9-5786-8169-050d74d3d201', 'a6af3a8f-f45c-526b-a461-050e7a7ab940', 'Darja', 'Volim prirodu, idemo u rujnu!', 'Я люблю природу, поїдьмо у вересні!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- 3. Нові уроки модуля A1.10
-- A1.10 · урок 87: Плани на відпустку — новий урок: 11 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := '704b6312-30cc-5a3c-94ff-c2a2dfd1b17c';
  v_lesson constant uuid := '373074e1-3c4b-5d0f-a4f3-3ed06e0904f2';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.10: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 87: Плани на відпустку', 'Lekcija 87: Planovi za godišnji odmor', '["Розповісти про плани на відпустку: kampirati, privatni smještaj, polupansion", "Домовитися про маршрут і житло", "Майбутній час: putovat ćemo, ostat ćemo, nećemo"]'::jsonb, 15, 'PUBLISHED', 2);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Майбутній час: ići ću, bit će' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Майбутній час: ići ću, bit će»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'plan puta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kamp', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kampirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šator', v_pos);
  v_pos := pg_temp.word(v_lesson, 'privatni smještaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polupansion', v_pos);
  v_pos := pg_temp.word(v_lesson, 'putno osiguranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sezona', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predsezona', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razgledavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'boravak', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'faca5d34-8441-5a27-9ddb-02e00139eea0', 'fill_in_the_blank', 'Ljeti ___ putovati u Istru.', 'ćemo', '["smo", "ćeš li", "ćemo", "bismo"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b4632931-d5ba-5f90-9a1f-e5558bba03f3', 'multiple_choice', 'Що означає «razgledavanje»?', 'огляд визначних місць, екскурсія', '["початок сезону (до липня)", "огляд визначних місць, екскурсія", "туристичне страхування", "кемпінг"]'::jsonb, 'A1', 2, 'PUBLISHED', 'razgledavanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3f4bc640-5828-5707-b4ed-572563e4d61c', 'multiple_choice', 'Що означає «predsezona»?', 'початок сезону (до липня)', '["огляд визначних місць, екскурсія", "початок сезону (до липня)", "кемпінг", "напівпансіон"]'::jsonb, 'A1', 3, 'PUBLISHED', 'predsezona', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f138d45b-9aa6-5d16-9b22-aedc2ec2bebb', 'multiple_choice', 'Що означає «kampirati»?', 'жити в кемпінгу, кемпінгувати', '["намет", "жити в кемпінгу, кемпінгувати", "план подорожі, маршрут", "приватне житло (апартаменти, кімнати)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'kampirati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a22f08f-0eb1-53f0-835d-e8238b03d421', 'multiple_choice', 'Що означає «privatni smještaj»?', 'приватне житло (апартаменти, кімнати)', '["план подорожі, маршрут", "приватне житло (апартаменти, кімнати)", "намет", "кемпінг"]'::jsonb, 'A1', 5, 'PUBLISHED', 'privatni smještaj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'de1f2912-9c22-5192-a998-4fcc8b25b04c', 'multiple_choice', 'Як хорватською «сезон»?', 'sezona', '["plan puta", "sezona", "šator", "predsezona"]'::jsonb, 'A1', 6, 'PUBLISHED', 'sezona', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '587f5851-fb71-5103-9dcc-47225de71772', 'multiple_choice', 'Як хорватською «напівпансіон»?', 'polupansion', '["polupansion", "šator", "predsezona", "plan puta"]'::jsonb, 'A1', 7, 'PUBLISHED', 'polupansion', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '302281af-f5df-5d14-bd0c-63f74eee6699', 'type_answer', 'Напишіть хорватською: «намет»', 'šator', null, 'A1', 8, 'PUBLISHED', 'šator', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd6e132d1-919d-50f3-baae-2ec3498dd1d5', 'type_answer', 'Напишіть хорватською: «кемпінг»', 'kamp', null, 'A1', 9, 'PUBLISHED', 'kamp', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7d4af3d5-bc93-5178-9717-6f8b3120319b', 'sentence_builder', 'Складіть: «Ми поїдемо в Далмацію.»', 'Putovat ćemo u Dalmaciju.', '["ćemo", "u", "Dalmaciju.", "Putovat"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '431ab92e-baa0-5607-9503-127463a40897', 'sentence_builder', 'Складіть: «Я не спатиму в наметі.»', 'Neću spavati u šatoru.', '["spavati", "Neću", "u", "šatoru."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aae887ca-ed23-5ed0-9fba-2cb0e27e2dc9', 'listening', 'Прослухайте і складіть фразу', 'Djeca žele kamp i šator!', '["i", "Djeca", "kamp", "žele", "šator!"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fc25c7d8-13f6-5815-8961-99cbdd9d5fbf', 'listening', 'Прослухайте і складіть фразу', 'Imamo. Koliko će trajati vaš boravak?', '["će", "Koliko", "boravak?", "Imamo.", "trajati", "vaš"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f36bd218-212d-50e9-823a-75dd44790626', 'speaking', 'Куди поїдеш у відпустку?', 'Kamo ćeš ići na godišnji?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c77d9db5-d988-50c7-b1d4-f1e853d53f7e', 'speaking', 'Я складу план подорожі.', 'Napravit ću plan puta.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('728ab0ff-3e9b-5229-aef9-fa9184477a8f', v_lesson, 'Куди поїдемо?', 'Kamo ćemo ići?', 3871, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('fdf78283-1bab-59a3-b741-51406fb5ca1f', '728ab0ff-3e9b-5229-aef9-fa9184477a8f', 'Luka', 'Dašo, kamo ćemo ići na godišnji ove godine?', 'Дашо, куди поїдемо у відпустку цього року?', 1);
  perform pg_temp.turn('279aa98f-75c5-552c-a977-441f9b325e15', '728ab0ff-3e9b-5229-aef9-fa9184477a8f', 'Daša', 'Mislim da ćemo putovati u Dalmaciju, u predsezoni.', 'Думаю, поїдемо в Далмацію, на початку сезону.', 2);
  perform pg_temp.turn('dc0d8715-7f14-5928-92ee-b910b5b72fde', '728ab0ff-3e9b-5229-aef9-fa9184477a8f', 'Luka', 'Hoćemo li kampirati ili uzeti privatni smještaj?', 'Будемо жити в наметі чи візьмемо приватне житло?', 3);
  perform pg_temp.turn('96525efa-d65a-50ff-98a6-9c71f1a97bce', '728ab0ff-3e9b-5229-aef9-fa9184477a8f', 'Daša', 'Djeca žele kamp i šator!', 'Діти хочуть кемпінг і намет!', 4);
  perform pg_temp.turn('c45889e1-5bc4-550c-a4e1-dc36e7bf0af6', '728ab0ff-3e9b-5229-aef9-fa9184477a8f', 'Luka', 'Dobro, ali u sezoni neću kampirati, prevruće je.', 'Добре, але в сезон я в наметі не житиму, надто спекотно.', 5);
  perform pg_temp.turn('77339063-9661-519f-9bda-9f0c519f6da5', '728ab0ff-3e9b-5229-aef9-fa9184477a8f', 'Daša', 'Napravit ću plan puta večeras.', 'Я складу план подорожі сьогодні ввечері.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c64cb884-4c0d-5567-ba6e-b1a7459d0a9a', v_lesson, 'Бронюємо готель', 'Rezervacija hotela', 3872, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('c85939a4-ba97-5a6f-a4aa-52adf13c8086', 'c64cb884-4c0d-5567-ba6e-b1a7459d0a9a', 'Darja', 'Dobar dan, imate li slobodnu sobu za lipanj?', 'Добрий день, у вас є вільний номер на червень?', 1);
  perform pg_temp.turn('79ae64dc-9ffe-5c05-8f22-6a4830f6a17a', 'c64cb884-4c0d-5567-ba6e-b1a7459d0a9a', 'Recepcionerka', 'Imamo. Koliko će trajati vaš boravak?', 'Є. Скільки триватиме ваше перебування?', 2);
  perform pg_temp.turn('7f72310c-721a-5950-bd70-a04fbf6e9783', 'c64cb884-4c0d-5567-ba6e-b1a7459d0a9a', 'Darja', 'Sedam noćenja. Nudite li polupansion?', 'Сім ночей. Ви пропонуєте напівпансіон?', 3);
  perform pg_temp.turn('f4990c0e-961a-54ef-987d-afc3d314d247', 'c64cb884-4c0d-5567-ba6e-b1a7459d0a9a', 'Recepcionerka', 'Nudimo, doručak i večera su uključeni.', 'Так, сніданок і вечеря включені.', 4);
  perform pg_temp.turn('b902430c-d8bc-57c8-973d-37fac4e29a46', 'c64cb884-4c0d-5567-ba6e-b1a7459d0a9a', 'Darja', 'Super. Organizirate li i razgledavanje otoka?', 'Чудово. Ви організовуєте й екскурсії островом?', 5);
  perform pg_temp.turn('88232c7d-b8c2-59bd-b2c2-7a1b511e6d22', 'c64cb884-4c0d-5567-ba6e-b1a7459d0a9a', 'Recepcionerka', 'Da. I preporučujemo putno osiguranje.', 'Так. І радимо туристичне страхування.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A1 v3 (слова за темою, 2 діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 89: Далмація: Задар — новий урок: 14 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := '704b6312-30cc-5a3c-94ff-c2a2dfd1b17c';
  v_lesson constant uuid := '9a44edc5-7e46-5377-bfcb-20cd93ac333b';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.10: місце 4 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 89: Далмація: Задар', 'Lekcija 89: Dalmacija: Zadar', '["Розповісти про Задар: morske orgulje, Pozdrav Suncu, forum", "Поділитися враженнями від поїздки", "Минулий час: bili smo, vidjeli smo, slušali smo"]'::jsonb, 15, 'PUBLISHED', 4);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Минулий час: radio sam, bila sam»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'dalmatinski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'morske orgulje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Pozdrav Suncu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rimski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'forum', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvonik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zalazak sunca', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šetnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupalište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otočje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'klapa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maraskino', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kamen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'fjaka', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '0ac19bca-f0f3-5190-a96b-d34f8924dc47', 'fill_in_the_blank', 'Jučer smo ___ morske orgulje.', 'slušali', '["slušamo", "slušali", "slušati", "slušat ćemo"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5c9e122b-2cf7-58ca-ad6e-e662088128b4', 'multiple_choice', 'Що означає «fjaka»?', 'фяка (стан ліні через спеку)', '["місце для купання, міський пляж", "далматинський", "архіпелаг", "фяка (стан ліні через спеку)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'fjaka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c5462daf-db88-5e41-9c19-85d74efb9f97', 'multiple_choice', 'Що означає «kupalište»?', 'місце для купання, міський пляж', '["мараскіно (вишневий лікер)", "морський орган (у Задарі)", "місце для купання, міський пляж", "фяка (стан ліні через спеку)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'kupalište', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4d898a2f-059a-5ada-b23d-2dbc2e080fcd', 'multiple_choice', 'Що означає «dalmatinski»?', 'далматинський', '["далматинський", "захід сонця", "дзвіниця", "римський"]'::jsonb, 'A1', 4, 'PUBLISHED', 'dalmatinski', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a7bcfc23-0579-5d0f-b8d0-ad3af6bcd7c1', 'multiple_choice', 'Як хорватською «римський»?', 'rimski', '["kupalište", "kamen", "rimski", "zvonik"]'::jsonb, 'A1', 5, 'PUBLISHED', 'rimski', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5f12f016-6a1c-532a-a3e3-e8e7fd96f7b9', 'multiple_choice', 'Як хорватською «мараскіно (вишневий лікер)»?', 'maraskino', '["Pozdrav Suncu", "zalazak sunca", "maraskino", "otočje"]'::jsonb, 'A1', 6, 'PUBLISHED', 'maraskino', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '60b47c54-d531-589b-86fa-fc795bba4482', 'type_answer', 'Напишіть хорватською: «дзвіниця»', 'zvonik', null, 'A1', 7, 'PUBLISHED', 'zvonik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '456983e0-e7df-5d7d-8063-bd2daff4e3ff', 'type_answer', 'Напишіть хорватською: «набережна, прогулянкова алея»', 'šetnica', null, 'A1', 8, 'PUBLISHED', 'šetnica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7bcefda6-abc0-5013-acb5-df1c6ac807f5', 'type_answer', 'Напишіть хорватською: «камінь»', 'kamen', null, 'A1', 9, 'PUBLISHED', 'kamen', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '828e362a-5245-5087-b924-fe2821cf4962', 'sentence_builder', 'Складіть: «Ми бачили захід сонця.»', 'Vidjeli smo zalazak sunca.', '["sunca.", "smo", "Vidjeli", "zalazak"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5915cf9c-7c2e-50d6-a438-3d46934b3f8a', 'sentence_builder', 'Складіть: «Співала клапа.»', 'Pjevala je klapa.', '["klapa.", "je", "Pjevala"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6bb78def-7e9d-59c6-abca-d821b108b4af', 'listening', 'Прослухайте і складіть фразу', 'Jeste li vidjeli zalazak sunca?', '["vidjeli", "zalazak", "Jeste", "li", "sunca?"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f0b50557-93ef-5f93-a46a-d0df4bcbd7ef', 'listening', 'Прослухайте і складіть фразу', 'Je li bilo glazbe?', '["bilo", "li", "glazbe?", "Je"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1aacd095-daf7-587d-b390-a0150c53a852', 'speaking', 'Як було в Задарі?', 'Kako je bilo u Zadru?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7b0d1f8e-0a80-510b-98ae-a7c01b91d610', 'speaking', 'Ми гуляли набережною.', 'Šetali smo šetnicom.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('48ae328f-a414-5201-888d-5ab4d5ee9a76', v_lesson, 'Вихідні в Задарі', 'Vikend u Zadru', 3891, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('99a1ae76-589c-5e8b-9e34-0266cf01969a', '48ae328f-a414-5201-888d-5ab4d5ee9a76', 'Ivana', 'Dašo, kako je bilo u Zadru?', 'Дашо, як було в Задарі?', 1);
  perform pg_temp.turn('9b71a24f-2b4e-540d-9167-e5726e5c5a31', '48ae328f-a414-5201-888d-5ab4d5ee9a76', 'Daša', 'Predivno! Slušali smo morske orgulje na rivi.', 'Чудово! Ми слухали Морський орган на набережній.', 2);
  perform pg_temp.turn('81558482-add0-549e-a3d4-091117ff505c', '48ae328f-a414-5201-888d-5ab4d5ee9a76', 'Ivana', 'Jeste li vidjeli zalazak sunca?', 'Ви бачили захід сонця?', 3);
  perform pg_temp.turn('58b4b7d0-72fb-547e-8e49-dd732425f3f4', '48ae328f-a414-5201-888d-5ab4d5ee9a76', 'Daša', 'Jesmo, a poslije je Pozdrav Suncu svijetlio u svim bojama.', 'Так, а потім «Вітання Сонцю» світилося всіма кольорами.', 4);
  perform pg_temp.turn('f0d46c64-af11-5d64-9510-c8932904de57', '48ae328f-a414-5201-888d-5ab4d5ee9a76', 'Ivana', 'Jeste li se popeli na zvonik?', 'Ви піднялися на дзвіницю?', 5);
  perform pg_temp.turn('e529af38-dd5e-5416-afed-aadaa9d37d37', '48ae328f-a414-5201-888d-5ab4d5ee9a76', 'Daša', 'Jesmo. Odozgo se vidi cijelo otočje.', 'Так. Згори видно весь архіпелаг.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('81c3583d-0572-502d-bb30-e11a4fbd0273', v_lesson, 'Далматинський вечір', 'Dalmatinska večer', 3892, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('576938a2-c6a8-5f3a-8b4b-e09367029126', '81c3583d-0572-502d-bb30-e11a4fbd0273', 'Luka', 'Gdje ste bili jučer navečer?', 'Де ви були вчора ввечері?', 1);
  perform pg_temp.turn('f986f594-92fe-561f-9713-363a0027aa9b', '81c3583d-0572-502d-bb30-e11a4fbd0273', 'Darja', 'Šetali smo šetnicom do rimskog foruma.', 'Ми гуляли набережною до римського форуму.', 2);
  perform pg_temp.turn('5d50b4c1-035f-59ac-bb49-70bb301aae59', '81c3583d-0572-502d-bb30-e11a4fbd0273', 'Luka', 'Je li bilo glazbe?', 'Була музика?', 3);
  perform pg_temp.turn('685451fa-c854-5aa5-974b-7701898e4cd5', '81c3583d-0572-502d-bb30-e11a4fbd0273', 'Darja', 'Da, pjevala je klapa. A u kafiću smo probali maraskino.', 'Так, співала клапа. А в кафе ми скуштували мараскіно.', 4);
  perform pg_temp.turn('b659dc42-07d4-5444-a15a-79c6d2d36975', '81c3583d-0572-502d-bb30-e11a4fbd0273', 'Luka', 'A danas?', 'А сьогодні?', 5);
  perform pg_temp.turn('61c85127-0029-5d2c-b3d1-8769a7576575', '81c3583d-0572-502d-bb30-e11a4fbd0273', 'Darja', 'Danas je fjaka: kupalište, kamen pod nogama i more.', 'Сьогодні фяка: пляж, камінь під ногами й море.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A1 v3 (слова за темою, 2 діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.10 · урок 92: Дикі тварини — новий урок: 16 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := '704b6312-30cc-5a3c-94ff-c2a2dfd1b17c';
  v_lesson constant uuid := '88e6f563-29dd-5e5d-865b-67fa47474b07';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 7) then
    raise exception 'A1.10: місце 7 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 92: Дикі тварини', 'Lekcija 92: Divlje životinje', '["Назвати диких тварин Хорватії: medvjed, vuk, ris, dupin", "Розповісти, кого ви бачили в природі", "Знахідний для живого: vidjeli smo medvjeda, vuka, srnu"]'::jsonb, 15, 'PUBLISHED', 7);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Знахідний відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Знахідний відмінок»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'divlji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'životinja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'medvjed', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vuk', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lisica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ris', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jelen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'divlja svinja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vjeverica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sova', v_pos);
  v_pos := pg_temp.word(v_lesson, 'orao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zmija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poskok', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dupin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'galeb', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '0406bcd1-bd81-5471-b973-c09a72e2211b', 'fill_in_the_blank', 'U šumi smo vidjeli ___.', 'medvjeda', '["medvjedu", "medvjed", "medvjedom", "medvjeda"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '82c7a174-c672-53d5-94aa-c989f6277d63', 'multiple_choice', 'Що означає «divlja svinja»?', 'дикий кабан', '["чайка", "орел", "дикий кабан", "олень"]'::jsonb, 'A1', 2, 'PUBLISHED', 'divlja svinja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c3e8a04-bb01-5990-bfb0-1060abb2a392', 'multiple_choice', 'Що означає «srna»?', 'козуля', '["дельфін", "дикий кабан", "олень", "козуля"]'::jsonb, 'A1', 3, 'PUBLISHED', 'srna', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f0b1d110-fb1f-5cb9-90c0-92fe587ea2fc', 'multiple_choice', 'Що означає «ris»?', 'рись', '["рись", "чайка", "тварина", "козуля"]'::jsonb, 'A1', 4, 'PUBLISHED', 'ris', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e0d075d0-0e69-593b-8340-41dcf9f0c050', 'multiple_choice', 'Як хорватською «чайка»?', 'galeb', '["jelen", "srna", "galeb", "poskok"]'::jsonb, 'A1', 5, 'PUBLISHED', 'galeb', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dd14c465-0b7d-53ea-a88a-109462793724', 'multiple_choice', 'Як хорватською «білка»?', 'vjeverica', '["životinja", "orao", "divlja svinja", "vjeverica"]'::jsonb, 'A1', 6, 'PUBLISHED', 'vjeverica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b656506-31a6-5287-b3d1-b31784de64e2', 'type_answer', 'Напишіть хорватською: «дельфін»', 'dupin', null, 'A1', 7, 'PUBLISHED', 'dupin', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7debc40a-25f4-574b-85bc-6a49f451c483', 'type_answer', 'Напишіть хорватською: «ведмідь»', 'medvjed', null, 'A1', 8, 'PUBLISHED', 'medvjed', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '65ab91ce-fa0f-5add-a183-8d07f694b4e7', 'type_answer', 'Напишіть хорватською: «носата гадюка (поскок)»', 'poskok', null, 'A1', 9, 'PUBLISHED', 'poskok', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6f46c2c3-610e-583e-ad3a-5644b5e147ba', 'sentence_builder', 'Складіть: «Я вперше бачу дельфіна.»', 'Prvi put vidim dupina.', '["Prvi", "dupina.", "put", "vidim"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd205f44d-8045-5ffb-8f3c-220288c7d0bd', 'sentence_builder', 'Складіть: «Тут живуть вовки.»', 'Ovdje žive vukovi.', '["žive", "vukovi.", "Ovdje"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '37372866-aa10-5114-8faf-026be75e8522', 'listening', 'Прослухайте і складіть фразу', 'Tata, žive li ovdje medvjedi?', '["li", "Tata,", "medvjedi?", "ovdje", "žive"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '30ad65a0-90e4-5a4e-9a59-eb412bbca72c', 'listening', 'Прослухайте і складіть фразу', 'Je li poskok opasan?', '["opasan?", "poskok", "Je", "li"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2bb72521-37ce-58d4-b03a-1f3fd19936b2', 'speaking', 'Дивись, дельфіни!', 'Gledaj, dupini!', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '75e9cec7-a80a-5c29-a882-b7763eecf529', 'speaking', 'Ми бачили оленя.', 'Vidjeli smo jelena.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4c329c70-4a0c-5ab1-8708-14618561ed35', v_lesson, 'У Горському Котарі', 'U Gorskom kotaru', 3921, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('664cda65-a124-5a12-86f7-89fb78ff103f', '4c329c70-4a0c-5ab1-8708-14618561ed35', 'Filip', 'Tata, žive li ovdje medvjedi?', 'Тату, тут живуть ведмеді?', 1);
  perform pg_temp.turn('95aa1408-563d-5a6c-a34d-80b482fa58b8', '4c329c70-4a0c-5ab1-8708-14618561ed35', 'Luka', 'Žive, i vukovi i risovi, ali su jako plahi.', 'Живуть, і вовки, і рисі, але вони дуже полохливі.', 2);
  perform pg_temp.turn('a305dbcb-a536-5d0e-bb19-a69738e7cafd', '4c329c70-4a0c-5ab1-8708-14618561ed35', 'Filip', 'Hoćemo li vidjeti nekog medvjeda?', 'Ми побачимо якогось ведмедя?', 3);
  perform pg_temp.turn('2cf9a68c-6e09-5017-97bd-b453aca5bf41', '4c329c70-4a0c-5ab1-8708-14618561ed35', 'Luka', 'Vjerojatno nećemo. Ali jutros sam vidio srnu i jelena.', 'Мабуть, ні. Але зранку я бачив козулю й оленя.', 4);
  perform pg_temp.turn('d43b52b0-10bd-5b3d-865a-c08c0b11ebdb', '4c329c70-4a0c-5ab1-8708-14618561ed35', 'Filip', 'A što je ono na drvetu?', 'А що ото на дереві?', 5);
  perform pg_temp.turn('356fda0e-5478-577b-a496-1ba03ae2dfc6', '4c329c70-4a0c-5ab1-8708-14618561ed35', 'Luka', 'Vjeverica! A noću ćemo čuti sovu.', 'Білка! А вночі почуємо сову.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('07e55cdb-7f13-529a-bdbd-04c34bae0ee4', v_lesson, 'На морі', 'Na moru', 3922, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('0e86fb6e-2e4e-5fb0-96b2-d286116e0ea8', '07e55cdb-7f13-529a-bdbd-04c34bae0ee4', 'Darja', 'Gledaj, dupini pored broda!', 'Дивись, дельфіни біля човна!', 1);
  perform pg_temp.turn('d06b391d-8290-536b-aa5d-e41bd1745e4c', '07e55cdb-7f13-529a-bdbd-04c34bae0ee4', 'Marko', 'Prekrasno! Prvi put vidim dupina u moru.', 'Чудово! Я вперше бачу дельфіна в морі.', 2);
  perform pg_temp.turn('af7b5c47-eb5b-5c17-94d7-4167025b6270', '07e55cdb-7f13-529a-bdbd-04c34bae0ee4', 'Darja', 'A galebovi su nam ukrali kruh.', 'А чайки вкрали в нас хліб.', 3);
  perform pg_temp.turn('bf29cbaf-444d-5615-9c77-c47d19c1e21e', '07e55cdb-7f13-529a-bdbd-04c34bae0ee4', 'Marko', 'Na otoku pazi kuda hodaš, ima zmija.', 'На острові дивись під ноги, там є змії.', 4);
  perform pg_temp.turn('e7283bed-4099-5985-9f51-4ec5071127a7', '07e55cdb-7f13-529a-bdbd-04c34bae0ee4', 'Darja', 'Je li poskok opasan?', 'Поскок небезпечний?', 5);
  perform pg_temp.turn('47ae5735-88aa-5e62-8d46-342bab4ecb68', '07e55cdb-7f13-529a-bdbd-04c34bae0ee4', 'Marko', 'Jest, otrovan je. Ali bježi od ljudi.', 'Так, отруйний. Але він тікає від людей.', 6);
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
   where l.id in ('0cb42e87-0ece-5e12-a07c-05cb5c370157', '373074e1-3c4b-5d0f-a4f3-3ed06e0904f2', '8633c234-d638-57f1-ad92-1c78be43fb07', '9a44edc5-7e46-5377-bfcb-20cd93ac333b', '71ab330d-abbe-57a7-870e-77e59daf3627', '84a20a00-701a-5ce5-a3c8-fca72986f912', '88e6f563-29dd-5e5d-865b-67fa47474b07')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 10 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_order from (values ('0cb42e87-0ece-5e12-a07c-05cb5c370157'::uuid, 1), ('373074e1-3c4b-5d0f-a4f3-3ed06e0904f2'::uuid, 2), ('8633c234-d638-57f1-ad92-1c78be43fb07'::uuid, 3), ('9a44edc5-7e46-5377-bfcb-20cd93ac333b'::uuid, 4), ('71ab330d-abbe-57a7-870e-77e59daf3627'::uuid, 5), ('84a20a00-701a-5ce5-a3c8-fca72986f912'::uuid, 6), ('88e6f563-29dd-5e5d-865b-67fa47474b07'::uuid, 7)) as t(id, o)
    join public.lessons l on l.id = t.id and l.order_index = t.o and l.unit_id = '704b6312-30cc-5a3c-94ff-c2a2dfd1b17c';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A1' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('0cb42e87-0ece-5e12-a07c-05cb5c370157', '373074e1-3c4b-5d0f-a4f3-3ed06e0904f2', '8633c234-d638-57f1-ad92-1c78be43fb07', '9a44edc5-7e46-5377-bfcb-20cd93ac333b', '71ab330d-abbe-57a7-870e-77e59daf3627', '84a20a00-701a-5ce5-a3c8-fca72986f912', '88e6f563-29dd-5e5d-865b-67fa47474b07') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A1.10: % уроків з неправильним складом', v_bad; end if;
  if v_order <> 7 then raise exception 'Модуль A1.10: на своїх місцях % уроків з 7', v_order; end if;
  if v_titles > 0 then raise exception 'A1: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A1.10: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A1.10 — 7 уроків за темою (4 перебудовано, 3 нових)';
end $$;

commit;
