-- =====================================================================
-- Програма A1 v3 · модуль A1.2 «Їжа й кухня» · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_curriculum_a1_v3.py 2 (не редагуйте вручну).
--
-- Рішення власника 2026-10-21 / 2026-10-26: до 25 слів на урок — скільки потрібно темі, 90–95 % слів — нові для рівня,
-- діалоги під тему, частіше Даша / Дар’я; бета (PUBLISHED).
--   * Уроки 11–21: 10 наявних перебудовано, 1 нових. Слів у них: 150.
--     Кожен: 10–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 87.
--   * Нові теми граматики: «Числа й кількість: dva kruha, pet jaja».
--   * Нові правила до тем: «Знахідний відмінок» (+1).
--   * Виправлено: kava za van — «кава з собою» (стара версія — у content_versions).
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

-- 1. Нові слова й вирази A1.2 (87; наявні не змінюються)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zobene pahuljice', 'zobene pahuljice', 'hr', 'phrase', 'A1', 'вівсяні пластівці', 'collocation', '{"gender": "f_pl"}'::jsonb, '["Za doručak jedem zobene pahuljice s voćem."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('žitarice', 'zitarice', 'hr', 'noun', 'A1', 'сухі сніданки, злаки', 'core', '{"gender": "f_pl"}'::jsonb, '["Djeca vole žitarice s mlijekom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jaje na oko', 'jaje na oko', 'hr', 'phrase', 'A1', 'глазунья', 'collocation', '{"gender": "n"}'::jsonb, '["Za doručak želim dva jaja na oko."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kuhano jaje', 'kuhano jaje', 'hr', 'phrase', 'A1', 'варене яйце', 'collocation', '{"gender": "n"}'::jsonb, '["Kuhano jaje kuham sedam minuta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sirni namaz', 'sirni namaz', 'hr', 'phrase', 'A1', 'сирна намазка', 'collocation', '{"gender": "m"}'::jsonb, '["Na kruh stavljam sirni namaz."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('čokoladni namaz', 'cokoladni namaz', 'hr', 'phrase', 'A1', 'шоколадний крем (для хліба)', 'collocation', '{"gender": "m"}'::jsonb, '["Djeca obožavaju čokoladni namaz."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sok od naranče', 'sok od narance', 'hr', 'phrase', 'A1', 'апельсиновий сік', 'collocation', '{"gender": "m"}'::jsonb, '["Čašu soka od naranče, molim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('popis za kupovinu', 'popis za kupovinu', 'hr', 'phrase', 'A1', 'список покупок', 'collocation', '{"gender": "m"}'::jsonb, '["Napiši popis za kupovinu da ništa ne zaboravimo."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('odjel', 'odjel', 'hr', 'noun', 'A1', 'відділ (у магазині, установі)', 'core', '{"gender": "m"}'::jsonb, '["Sir je na odjelu mliječnih proizvoda."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('konzerva', 'konzerva', 'hr', 'noun', 'A1', 'консерва, бляшанка', 'core', '{"gender": "f"}'::jsonb, '["Kupi dvije konzerve tune."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tegla', 'tegla', 'hr', 'noun', 'A1', 'скляна банка (для меду, варення)', 'core', '{"gender": "f"}'::jsonb, '["Uzmi jednu teglu meda."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('smrznut', 'smrznut', 'hr', 'adjective', 'A1', 'заморожений', 'core', '{"f": "smrznuta", "n": "smrznuto"}'::jsonb, '["Smrznuto povrće je u zamrzivaču."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gotovo jelo', 'gotovo jelo', 'hr', 'phrase', 'A1', 'готова страва', 'collocation', '{"gender": "n", "plural": "gotova jela"}'::jsonb, '["Nemam vremena kuhati pa kupujem gotova jela."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mliječni proizvodi', 'mlijecni proizvodi', 'hr', 'phrase', 'A1', 'молочні продукти', 'collocation', '{"gender": "m_pl"}'::jsonb, '["Mliječni proizvodi su na kraju trgovine."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('štand', 'stand', 'hr', 'noun', 'A1', 'прилавок, ятка (на ринку)', 'core', '{"gender": "m"}'::jsonb, '["Na ovom štandu je voće najsvježije."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('glavica', 'glavica', 'hr', 'noun', 'A1', 'головка (салату, капусти, часнику)', 'core', '{"gender": "f"}'::jsonb, '["Glavica salate košta euro."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vezica', 'vezica', 'hr', 'noun', 'A1', 'пучок (зелені)', 'core', '{"gender": "f"}'::jsonb, '["Dajte mi jednu vezicu peršina."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('grozd', 'grozd', 'hr', 'noun', 'A1', 'гроно (винограду)', 'core', '{"gender": "m"}'::jsonb, '["Ovaj grozd grožđa je jako sladak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('smokva', 'smokva', 'hr', 'noun', 'A1', 'інжир', 'core', '{"gender": "f"}'::jsonb, '["Dalmatinske smokve su slatke kao med."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('trešnja', 'tresnja', 'hr', 'noun', 'A1', 'черешня', 'core', '{"gender": "f", "genitive_pl": "trešanja"}'::jsonb, '["Trešnje su u lipnju najjeftinije."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dinja', 'dinja', 'hr', 'noun', 'A1', 'диня', 'core', '{"gender": "f"}'::jsonb, '["Dinja je zrela i jako mirisna."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kupina', 'kupina', 'hr', 'noun', 'A1', 'ожина', 'core', '{"gender": "f"}'::jsonb, '["Kupine beremo uz šumu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tikvica', 'tikvica', 'hr', 'noun', 'A1', 'кабачок', 'core', '{"gender": "f"}'::jsonb, '["Tikvice su dobre na roštilju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('patlidžan', 'patlidzan', 'hr', 'noun', 'A1', 'баклажан', 'core', '{"gender": "m"}'::jsonb, '["Od patlidžana radim umak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('peršin', 'persin', 'hr', 'noun', 'A1', 'петрушка', 'core', '{"gender": "m"}'::jsonb, '["Juhu posipam peršinom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zelena salata', 'zelena salata', 'hr', 'phrase', 'A1', 'салат (листя)', 'collocation', '{"gender": "f"}'::jsonb, '["Kupi jednu glavicu zelene salate."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mladi luk', 'mladi luk', 'hr', 'phrase', 'A1', 'зелена цибуля', 'collocation', '{"gender": "m"}'::jsonb, '["Mladi luk stavljam u salatu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mesar', 'mesar', 'hr', 'noun', 'A1', 'м’ясник', 'core', '{"gender": "m"}'::jsonb, '["Mesar mi je samljeo meso."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kotlet', 'kotlet', 'hr', 'noun', 'A1', 'котлета на кістці, відбивна', 'core', '{"gender": "m"}'::jsonb, '["Svinjski kotleti su danas na akciji."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pileća prsa', 'pileca prsa', 'hr', 'phrase', 'A1', 'курячі грудки, куряче філе', 'collocation', '{"gender": "n_pl"}'::jsonb, '["Trebam pola kile pilećih prsa."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('oslić', 'oslic', 'hr', 'noun', 'A1', 'хек', 'core', '{"gender": "m"}'::jsonb, '["Pohani oslić je omiljeno jelo djece."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('orada', 'orada', 'hr', 'noun', 'A1', 'дорада (риба)', 'core', '{"gender": "f"}'::jsonb, '["Orada s roštilja je pravi specijalitet."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('brancin', 'brancin', 'hr', 'noun', 'A1', 'сібас, морський окунь', 'core', '{"gender": "m"}'::jsonb, '["Brancin pečemo u pećnici s krumpirom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kifla', 'kifla', 'hr', 'noun', 'A1', 'рогалик', 'core', '{"gender": "f"}'::jsonb, '["Dvije kifle i jedan jogurt, molim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('perec', 'perec', 'hr', 'noun', 'A1', 'брецель', 'core', '{"gender": "m"}'::jsonb, '["Perec je slan i hrskav."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pita', 'pita', 'hr', 'noun', 'A1', 'пиріг (листковий)', 'core', '{"gender": "f"}'::jsonb, '["Pita od jabuka je još topla."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('štrudla', 'strudla', 'hr', 'noun', 'A1', 'штрудель', 'core', '{"gender": "f"}'::jsonb, '["Štrudla od višanja je naša najbolja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('topla čokolada', 'topla cokolada', 'hr', 'phrase', 'A1', 'гарячий шоколад', 'collocation', '{"gender": "f"}'::jsonb, '["Zimi pijem toplu čokoladu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('duboki tanjur', 'duboki tanjur', 'hr', 'phrase', 'A1', 'глибока тарілка', 'collocation', '{"gender": "m"}'::jsonb, '["Juhu jedemo iz dubokog tanjura."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('plitki tanjur', 'plitki tanjur', 'hr', 'phrase', 'A1', 'мілка тарілка', 'collocation', '{"gender": "m"}'::jsonb, '["Za glavno jelo trebaju plitki tanjuri."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zdjela', 'zdjela', 'hr', 'noun', 'A1', 'миска', 'core', '{"gender": "f"}'::jsonb, '["Stavi salatu u veliku zdjelu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('žličica', 'zlicica', 'hr', 'noun', 'A1', 'чайна ложечка', 'core', '{"gender": "f"}'::jsonb, '["Jedna žličica šećera, molim."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('čaša za vino', 'casa za vino', 'hr', 'phrase', 'A1', 'келих для вина', 'collocation', '{"gender": "f"}'::jsonb, '["Fali nam još jedna čaša za vino."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pribor za jelo', 'pribor za jelo', 'hr', 'phrase', 'A1', 'столові прибори', 'collocation', '{"gender": "m"}'::jsonb, '["Pribor za jelo je u ladici."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stolnjak', 'stolnjak', 'hr', 'noun', 'A1', 'скатертина', 'core', '{"gender": "m"}'::jsonb, '["Na stol stavimo bijeli stolnjak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vrč', 'vrc', 'hr', 'noun', 'A1', 'глечик', 'core', '{"gender": "m"}'::jsonb, '["Napuni vrč vodom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('otvarač', 'otvarac', 'hr', 'noun', 'A1', 'відкривачка', 'core', '{"gender": "m"}'::jsonb, '["Gdje je otvarač za boce?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kuhača', 'kuhaca', 'hr', 'noun', 'A1', 'кухонна ложка, лопатка', 'core', '{"gender": "f"}'::jsonb, '["Juhu miješaj drvenom kuhačom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('daska za rezanje', 'daska za rezanje', 'hr', 'phrase', 'A1', 'обробна дошка', 'collocation', '{"gender": "f"}'::jsonb, '["Luk režem na dasci za rezanje."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('postaviti stol', 'postaviti stol', 'hr', 'phrase', 'A1', 'накрити на стіл', 'collocation', '{"aspect": "pfv", "present": {"1s": "postavim stol", "2s": "postaviš stol", "3s": "postavi stol"}}'::jsonb, '["Možeš li postaviti stol za šest osoba?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pospremiti stol', 'pospremiti stol', 'hr', 'phrase', 'A1', 'прибрати зі столу', 'collocation', '{"aspect": "pfv", "present": {"1s": "pospremim stol", "2s": "pospremiš stol", "3s": "pospremi stol"}}'::jsonb, '["Nakon ručka djeca pospreme stol."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sastojak', 'sastojak', 'hr', 'noun', 'A1', 'інгредієнт', 'core', '{"gender": "m", "plural": "sastojci"}'::jsonb, '["Imamo li sve sastojke za kolač?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tijesto', 'tijesto', 'hr', 'noun', 'A1', 'тісто', 'core', '{"gender": "n"}'::jsonb, '["Tijesto mora stajati pola sata."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('začin', 'zacin', 'hr', 'noun', 'A1', 'спеція, приправа', 'core', '{"gender": "m"}'::jsonb, '["Koje začine stavljaš u gulaš?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nasjeckati', 'nasjeckati', 'hr', 'verb', 'A1', 'посікти, дрібно нарізати', 'core', '{"aspect": "pfv", "present": {"1s": "nasjeckam", "2s": "nasjeckaš", "3s": "nasjecka"}}'::jsonb, '["Nasjeckaj luk i češnjak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('izmiješati', 'izmijesati', 'hr', 'verb', 'A1', 'змішати', 'core', '{"aspect": "pfv", "present": {"1s": "izmiješam", "2s": "izmiješaš", "3s": "izmiješa"}}'::jsonb, '["Sve sastojke dobro izmiješaj."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ispeći', 'ispeci', 'hr', 'verb', 'A1', 'спекти; засмажити', 'core', '{"aspect": "pfv", "present": {"1s": "ispečem", "2s": "ispečeš", "3s": "ispeče"}}'::jsonb, '["Kolač se ispeče za četrdeset minuta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('popapriti', 'popapriti', 'hr', 'verb', 'A1', 'поперчити', 'core', '{"aspect": "pfv", "present": {"1s": "popaprim", "2s": "popapriš", "3s": "popapri"}}'::jsonb, '["Meso posoli i popapri."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zakuhati', 'zakuhati', 'hr', 'verb', 'A1', 'закип’ятити', 'core', '{"aspect": "pfv", "present": {"1s": "zakuham", "2s": "zakuhaš", "3s": "zakuha"}}'::jsonb, '["Zakuhaj vodu za tjesteninu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prokuhati', 'prokuhati', 'hr', 'verb', 'A1', 'прокип’ятити; прокипіти', 'core', '{"aspect": "pfv", "present": {"1s": "prokuham", "2s": "prokuhaš", "3s": "prokuha"}}'::jsonb, '["Pusti da juha prokuha deset minuta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ohladiti', 'ohladiti', 'hr', 'verb', 'A1', 'охолодити', 'core', '{"aspect": "pfv", "present": {"1s": "ohladim", "2s": "ohladiš", "3s": "ohladi"}}'::jsonb, '["Ohladi juhu prije nego što je daš djetetu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rezanci', 'rezanci', 'hr', 'noun', 'A1', 'локшина', 'core', '{"gender": "m_pl"}'::jsonb, '["U juhu stavljam domaće rezance."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kockica za juhu', 'kockica za juhu', 'hr', 'phrase', 'A1', 'бульйонний кубик', 'collocation', '{"gender": "f"}'::jsonb, '["Bez kockice za juhu juha mi je bljutava."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('celer', 'celer', 'hr', 'noun', 'A1', 'селера', 'core', '{"gender": "m"}'::jsonb, '["Za juhu trebam mrkvu, celer i peršin."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('na ime', 'na ime', 'hr', 'phrase', 'A1', 'на ім’я', 'chunk', '{}'::jsonb, '["Imam rezervaciju na ime Kovalenko."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('slobodan stol', 'slobodan stol', 'hr', 'phrase', 'A1', 'вільний столик', 'collocation', '{"gender": "m"}'::jsonb, '["Imate li slobodan stol za dvoje?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stol uz prozor', 'stol uz prozor', 'hr', 'phrase', 'A1', 'столик біля вікна', 'collocation', '{"gender": "m"}'::jsonb, '["Možemo li dobiti stol uz prozor?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stol za četvero', 'stol za cetvero', 'hr', 'phrase', 'A1', 'столик на чотирьох', 'collocation', '{"gender": "m"}'::jsonb, '["Rezervirala sam stol za četvero."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('za koliko osoba', 'za koliko osoba', 'hr', 'phrase', 'A1', 'на скільки осіб', 'chunk', '{}'::jsonb, '["Za koliko osoba želite stol?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zauzeto', 'zauzeto', 'hr', 'adverb', 'A1', 'зайнято', 'core', '{}'::jsonb, '["Nažalost, večeras je sve zauzeto."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('specijalitet kuće', 'specijalitet kuce', 'hr', 'phrase', 'A1', 'фірмова страва закладу', 'collocation', '{"gender": "m"}'::jsonb, '["Specijalitet kuće je riba na žaru."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('unaprijed', 'unaprijed', 'hr', 'adverb', 'A1', 'заздалегідь, наперед', 'core', '{}'::jsonb, '["Stol je bolje rezervirati unaprijed."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('otkazati rezervaciju', 'otkazati rezervaciju', 'hr', 'phrase', 'A1', 'скасувати бронювання', 'collocation', '{"aspect": "pfv", "present": {"1s": "otkažem rezervaciju", "2s": "otkažeš rezervaciju", "3s": "otkaže rezervaciju"}}'::jsonb, '["Moram otkazati rezervaciju za subotu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kikiriki', 'kikiriki', 'hr', 'noun', 'A1', 'арахіс', 'core', '{"gender": "m"}'::jsonb, '["Imam alergiju na kikiriki."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gluten', 'gluten', 'hr', 'noun', 'A1', 'глютен', 'core', '{"gender": "m"}'::jsonb, '["Ova tjestenina nema glutena."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bez glutena', 'bez glutena', 'hr', 'phrase', 'A1', 'без глютену', 'chunk', '{}'::jsonb, '["Imate li kruh bez glutena?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('laktoza', 'laktoza', 'hr', 'noun', 'A1', 'лактоза', 'core', '{"gender": "f"}'::jsonb, '["Ovaj jogurt je bez laktoze."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('netolerancija', 'netolerancija', 'hr', 'noun', 'A1', 'непереносимість (харчова)', 'core', '{"gender": "f"}'::jsonb, '["Imam netoleranciju na laktozu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vegan', 'vegan', 'hr', 'noun', 'A1', 'веган', 'core', '{"gender": "m", "f": "veganka"}'::jsonb, '["Moja sestra je veganka, a ja nisam vegan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ne podnosim', 'ne podnosim', 'hr', 'phrase', 'A1', 'я не переношу, мені не підходить', 'chunk', '{}'::jsonb, '["Ne podnosim ljutu hranu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sastav', 'sastav', 'hr', 'noun', 'A1', 'склад (продукту)', 'core', '{"gender": "m"}'::jsonb, '["Pročitaj sastav na pakiranju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bljutav', 'bljutav', 'hr', 'adjective', 'A1', 'прісний, несмачний (без смаку)', 'core', '{"f": "bljutava", "n": "bljutavo"}'::jsonb, '["Juha je bljutava, treba još soli."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('začinjen', 'zacinjen', 'hr', 'adjective', 'A1', 'приправлений, гострий (зі спеціями)', 'core', '{"f": "začinjena", "n": "začinjeno"}'::jsonb, '["Ovo jelo je jako začinjeno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('podgrijati', 'podgrijati', 'hr', 'verb', 'A1', 'підігріти', 'core', '{"aspect": "pfv", "present": {"1s": "podgrijem", "2s": "podgriješ", "3s": "podgrije"}}'::jsonb, '["Ručak mogu podgrijati u mikrovalnoj."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pauza za ručak', 'pauza za rucak', 'hr', 'phrase', 'A1', 'обідня перерва', 'collocation', '{"gender": "f"}'::jsonb, '["Pauza za ručak traje pola sata."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dostava hrane', 'dostava hrane', 'hr', 'phrase', 'A1', 'доставка їжі', 'collocation', '{"gender": "f"}'::jsonb, '["Danas naručujemo dostavu hrane."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kutija za ručak', 'kutija za rucak', 'hr', 'phrase', 'A1', 'ланч-бокс, контейнер для обіду', 'collocation', '{"gender": "f"}'::jsonb, '["Ručak nosim na posao u kutiji za ručak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;

-- 1б. Виправлені слова (1); повторний запуск нічого не змінює
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'kava za van' and ukrainian_translation = 'Кава з собою.' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'кава з собою' where id = r.id;
  end loop;
end $$;

-- 1а. Граматика A1.2: нові теми (1) і нові правила до наявних тем (1)
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '675637da-972c-5e45-a29d-7fc9dc671291', 'A1', 'Числа й кількість: dva kruha, pet jaja', 'Brojevi i količina: dva kruha, pet jaja', 'Іменник після чисел: jedan kruh, dva kruha, pet kruhova; dva / dvije; родовий після слів міри (litra mlijeka, vezica peršina) і після koliko, puno, malo.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Числа й кількість: dva kruha, pet jaja');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '6b4ad14e-4b79-5827-a63b-1bafbbda120c', '675637da-972c-5e45-a29d-7fc9dc671291', 'Один і два–чотири: dva kruha, dvije jabuke', 'Після jedan / jedna / jedno іменник стоїть у називному відмінку: jedan kruh, jedna jabuka. Після 2, 3, 4 — форма, як родовий однини: dva kruha, tri kotleta, četiri jaja; у жіночому роді — -e: dvije jabuke, tri kifle. Для жіночого роду кажемо dvije, а не dva.', 'jedan kruh → dva kruha · jedna jabuka → dvije jabuke', '[{"hr": "Dva kruha, molim.", "ua": "Два хліби, будь ласка."}, {"hr": "Dvije kifle i jedan burek.", "ua": "Два рогалики й один бурек."}, {"hr": "Trebam četiri jaja.", "ua": "Мені потрібно чотири яйця."}, {"hr": "Kupi tri litre mlijeka.", "ua": "Купи три літри молока."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '675637da-972c-5e45-a29d-7fc9dc671291')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '41681c16-90e8-51af-8dd1-a229b0f5e7d4', '675637da-972c-5e45-a29d-7fc9dc671291', 'П’ять і більше: pet jaja, deset jabuka', 'Після 5 і більших чисел, а також після koliko, puno, malo, nekoliko — родовий множини. Він часто закінчується на -a: pet kotleta, deset jabuka, šest jaja. Односкладові слова чоловічого роду мають -ova / -eva: pet kruhova; іноді з’являється a: trešnja → kilogram trešanja.', 'pet kotleta · deset jabuka · puno trešanja', '[{"hr": "Pet jaja i deset jabuka.", "ua": "П’ять яєць і десять яблук."}, {"hr": "Koliko kruhova trebamo?", "ua": "Скільки хлібин нам треба?"}, {"hr": "Imamo puno trešanja.", "ua": "У нас багато черешень."}, {"hr": "Šest kotleta, molim.", "ua": "Шість відбивних, будь ласка."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '675637da-972c-5e45-a29d-7fc9dc671291')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'cca9a419-7a41-5c8b-a628-ccef31916fa6', '675637da-972c-5e45-a29d-7fc9dc671291', 'Міра й упаковка + родовий: litra mlijeka', 'Після слів міри й упаковки — родовий: litra mlijeka, kilogram brašna, boca vode, vezica peršina, glavica salate, konzerva tune. Саме слово міри підкоряється правилам 1–2: dvije konzerve, tri litre, pet boca.', 'litra + mlijeko → litra mlijeka · dvije konzerve tune', '[{"hr": "Litru ulja i kilogram brašna.", "ua": "Літр олії й кілограм борошна."}, {"hr": "Dvije glavice salate, molim.", "ua": "Дві головки салату, будь ласка."}, {"hr": "Vezicu peršina i pola kile luka.", "ua": "Пучок петрушки й пів кіло цибулі."}, {"hr": "Kupi pet boca vode.", "ua": "Купи п’ять пляшок води."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '675637da-972c-5e45-a29d-7fc9dc671291')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '675637da-972c-5e45-a29d-7fc9dc671291', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '675637da-972c-5e45-a29d-7fc9dc671291')
  and not exists (select 1 from public.content_reviews where entity_id = '675637da-972c-5e45-a29d-7fc9dc671291' and notes = 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.');
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Знахідний відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Знахідний відмінок»'; end if;
  if exists (select 1 from public.grammar_rules where id = 'ded83a95-08f8-5d3b-9ab8-f91b5ce613a5') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('ded83a95-08f8-5d3b-9ab8-f91b5ce613a5', v_topic, 'Множина: kupujem jabuke, trebam jaja', 'У множині знахідний відмінок має -e в чоловічому й жіночому роді (kolači → kupujem kolače, jabuke → jedem jabuke) і -a в середньому (jaja, jela). На відміну від однини, живе й неживе в множині однакові: vidim pse, volim kolače.', 'kolači → kolače · jabuke → jabuke · jaja → jaja', '[{"hr": "Kupujem jabuke i kruške.", "ua": "Я купую яблука й груші."}, {"hr": "Trebamo jaja i brašno.", "ua": "Нам потрібні яйця й борошно."}, {"hr": "Djeca vole kolače.", "ua": "Діти люблять тістечка."}, {"hr": "Uzmi kotlete za ručak.", "ua": "Візьми відбивні на обід."}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', 'ded83a95-08f8-5d3b-9ab8-f91b5ce613a5', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;

-- 2. Перебудова наявних уроків модуля A1.2
-- A1.2 · урок 11: Що на сніданок? — перебудова: 13 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'bb7bc159-cb40-5a8a-91b7-c6da05c6342a';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Що на сніданок?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'a0c5ea8a-2043-53f4-acde-48d45ee98767') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 11: Що на сніданок?', title_hr = 'Lekcija 11: Što za doručak?',
         objectives = '["Розповісти, що ви їсте на сніданок: kajgana, tost, pahuljice", "Запропонувати й попросити: Hoćeš li…? Dodaj mi…", "Знахідний відмінок: jedem kajganu, pijem sok"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Знахідний відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Знахідний відмінок»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zobene pahuljice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žitarice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kajgana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jaje na oko', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kuhano jaje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sirni namaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čokoladni namaz', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pekmez', v_pos);
  v_pos := pg_temp.word(v_lesson, 'keks', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrhnje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'integralni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sok od naranče', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c077a8a9-d139-52bb-8a91-1431358b5ce2', 'fill_in_the_blank', 'Za doručak jedem ___ i tost.', 'kajganu', '["kajganom", "kajgane", "kajganu", "kajgana"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '269d0eee-d520-5427-9d6d-ef06cd9db246', 'multiple_choice', 'Що означає «tost»?', 'тост', '["сирна намазка", "печиво", "сухі сніданки, злаки", "тост"]'::jsonb, 'A1', 2, 'PUBLISHED', 'tost', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '51856c95-794b-5404-9251-1fedf5bccc54', 'multiple_choice', 'Що означає «sok od naranče»?', 'апельсиновий сік', '["варене яйце", "джем; повидло", "шоколадний крем (для хліба)", "апельсиновий сік"]'::jsonb, 'A1', 3, 'PUBLISHED', 'sok od naranče', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6ae9e86e-f9d2-5b88-b0e3-78acde32a2b9', 'multiple_choice', 'Що означає «vrhnje»?', 'сметана; вершки', '["вівсяні пластівці", "сметана; вершки", "глазунья", "печиво"]'::jsonb, 'A1', 4, 'PUBLISHED', 'vrhnje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '50335ee0-162e-5f12-8e20-4ce28fce9f91', 'multiple_choice', 'Як хорватською «печиво»?', 'keks', '["žitarice", "keks", "kuhano jaje", "jaje na oko"]'::jsonb, 'A1', 5, 'PUBLISHED', 'keks', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '75d5224e-405f-55a9-ab76-794960efa7cd', 'multiple_choice', 'Як хорватською «вівсяні пластівці»?', 'zobene pahuljice', '["žitarice", "zobene pahuljice", "vrhnje", "keks"]'::jsonb, 'A1', 6, 'PUBLISHED', 'zobene pahuljice', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '53745f42-632a-5ad5-97fe-8aa34f8e58e2', 'type_answer', 'Напишіть хорватською: «яєчня-бовтанка»', 'kajgana', null, 'A1', 7, 'PUBLISHED', 'kajgana', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '79f1d4d0-9200-5704-bc4f-aa9e54e42fcc', 'type_answer', 'Напишіть хорватською: «цільнозерновий»', 'integralni', null, 'A1', 8, 'PUBLISHED', 'integralni', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3ede2c0a-9c45-5d4c-9dfa-352bea38aeed', 'type_answer', 'Напишіть хорватською: «сухі сніданки, злаки»', 'žitarice', null, 'A1', 9, 'PUBLISHED', 'žitarice', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6d030916-877f-5029-9fd1-c51bf60078f5', 'sentence_builder', 'Складіть: «Я п’ю апельсиновий сік.»', 'Pijem sok od naranče.', '["Pijem", "od", "naranče.", "sok"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '69f810e8-7a80-51af-a683-1487202a6b37', 'sentence_builder', 'Складіть: «Діти їдять сухі сніданки з молоком.»', 'Djeca jedu žitarice s mlijekom.', '["s", "jedu", "mlijekom.", "Djeca", "žitarice"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ac5e64f1-e9b4-55d9-bf68-071d23af8b4f', 'listening', 'Прослухайте і складіть фразу', 'Hoćeš li sirni namaz ili pekmez?', '["pekmez?", "li", "sirni", "ili", "Hoćeš", "namaz"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dc6d715c-ed51-565f-9add-b0a8704328ea', 'listening', 'Прослухайте і складіть фразу', 'Ja jedem integralni kruh i kuhano jaje.', '["jaje.", "Ja", "kuhano", "integralni", "kruh", "i", "jedem"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '83bca20e-fdce-5f6c-adf6-19249d98c95b', 'speaking', 'Я хочу дві яєчні-глазуньї.', 'Želim dva jaja na oko.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '534be127-cd99-5cc2-bc00-f390cc73bdaa', 'speaking', 'Передай мені джем, будь ласка.', 'Dodaj mi pekmez, molim te.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a0c5ea8a-2043-53f4-acde-48d45ee98767', v_lesson, 'Сніданок удома', 'Doručak kod kuće', 3111, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('2b9c94a9-29a5-5a81-bbac-7e6965465e78', 'a0c5ea8a-2043-53f4-acde-48d45ee98767', 'Luka', 'Dašo, što želiš za doručak?', 'Дашо, що хочеш на сніданок?', 1);
  perform pg_temp.turn('79c01b13-23d7-5086-b1e7-039786007157', 'a0c5ea8a-2043-53f4-acde-48d45ee98767', 'Daša', 'Napravi mi kajganu i jedan tost, molim te.', 'Зроби мені яєчню й один тост, будь ласка.', 2);
  perform pg_temp.turn('064e227b-082b-529e-853e-9c607152f3e9', 'a0c5ea8a-2043-53f4-acde-48d45ee98767', 'Luka', 'Hoćeš li sirni namaz ili pekmez?', 'Хочеш сирну намазку чи джем?', 3);
  perform pg_temp.turn('c4f76b18-4f4a-5859-a58d-de3ea1974c28', 'a0c5ea8a-2043-53f4-acde-48d45ee98767', 'Daša', 'Pekmez od marelica, ako ga još imamo.', 'Абрикосовий джем, якщо він у нас ще є.', 4);
  perform pg_temp.turn('f960c715-ba64-521e-8a4c-54d858d2b1c0', 'a0c5ea8a-2043-53f4-acde-48d45ee98767', 'Luka', 'Imamo. I sok od naranče?', 'Є. І апельсиновий сік?', 5);
  perform pg_temp.turn('bb671175-202e-5269-9d59-b49bcc760433', 'a0c5ea8a-2043-53f4-acde-48d45ee98767', 'Daša', 'Može, ali samo pola čaše.', 'Давай, але тільки пів склянки.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('48ce1b39-babe-51f4-aaf3-0b5adf3c5663', v_lesson, 'Здоровий сніданок', 'Zdrav doručak', 3112, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('69050212-ce6d-5c5b-b46e-383394848ea1', '48ce1b39-babe-51f4-aaf3-0b5adf3c5663', 'Petra', 'Što ti jedeš ujutro?', 'Що ти їси зранку?', 1);
  perform pg_temp.turn('e7b3dfa0-40b5-5066-883d-9fa52cf34517', '48ce1b39-babe-51f4-aaf3-0b5adf3c5663', 'Darja', 'Obično zobene pahuljice s voćem i malo meda.', 'Зазвичай вівсянку з фруктами й трохи меду.', 2);
  perform pg_temp.turn('6077bb77-a721-5f02-9160-5497dad5e7ba', '48ce1b39-babe-51f4-aaf3-0b5adf3c5663', 'Petra', 'Ja jedem integralni kruh i kuhano jaje.', 'А я їм цільнозерновий хліб і варене яйце.', 3);
  perform pg_temp.turn('4ffcb9e4-700c-58f0-a74f-882eb6d59a8f', '48ce1b39-babe-51f4-aaf3-0b5adf3c5663', 'Darja', 'A djeca? Moja traže samo čokoladni namaz.', 'А діти? Мої просять лише шоколадну пасту.', 4);
  perform pg_temp.turn('14b5f894-770a-5ea5-a1d3-2bec1c040215', '48ce1b39-babe-51f4-aaf3-0b5adf3c5663', 'Petra', 'Moja jedu žitarice s mlijekom, a vikendom kekse.', 'Мої їдять сухі сніданки з молоком, а на вихідних — печиво.', 5);
  perform pg_temp.turn('5103b916-b3c6-52cf-bfcd-69d86857bc53', '48ce1b39-babe-51f4-aaf3-0b5adf3c5663', 'Darja', 'Kod nas su vikendom jaja na oko i palačinke.', 'А в нас на вихідних яєчня-глазунья й млинці.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 12: Список покупок у супермаркеті — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '0c19643d-57ff-5030-820f-ba330833ea88';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Список покупок у супермаркеті» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'c483c41a-0c1c-586f-bef2-7cd400ef62bb') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 12: Список покупок у супермаркеті', title_hr = 'Lekcija 12: Popis za kupovinu',
         objectives = '["Скласти список покупок і знайти потрібний відділ", "Сказати кількість: dvije konzerve, pet jaja, litra ulja", "Числа з іменниками: 2–4 і 5+"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Числа й кількість: dva kruha, pet jaja' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Числа й кількість: dva kruha, pet jaja»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'popis za kupovinu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'košarica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odjel', v_pos);
  v_pos := pg_temp.word(v_lesson, 'konzerva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tegla', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smrznut', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gotovo jelo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mliječni proizvodi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brašno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ocat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ulje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'papar', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd32656e5-fba9-5609-84fe-bc072daf8f30', 'fill_in_the_blank', 'Kupi tri ___ mlijeka.', 'litre', '["litra", "litru", "litre", "litrom"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ba65f6fa-52a0-5b06-9053-09cd488ccd93', 'multiple_choice', 'Що означає «papar»?', 'перець', '["перець", "заморожений", "оцет", "візок (у супермаркеті)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'papar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '50f13de6-60c1-5807-b7a4-80b3c589be60', 'multiple_choice', 'Що означає «ulje»?', 'олія', '["заморожений", "список покупок", "олія", "скляна банка (для меду, варення)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'ulje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5c488d75-b530-53ec-b9f0-5aa080b9a14c', 'multiple_choice', 'Що означає «mliječni proizvodi»?', 'молочні продукти', '["кошик (для покупок)", "заморожений", "консерва, бляшанка", "молочні продукти"]'::jsonb, 'A1', 4, 'PUBLISHED', 'mliječni proizvodi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c6431ab-e1ce-51fa-9ea3-4ff17c923bf6', 'multiple_choice', 'Як хорватською «заморожений»?', 'smrznut', '["brašno", "sol", "papar", "smrznut"]'::jsonb, 'A1', 5, 'PUBLISHED', 'smrznut', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b99be521-917e-5479-91d1-dde499afa89f', 'multiple_choice', 'Як хорватською «сіль»?', 'sol', '["tegla", "gotovo jelo", "smrznut", "sol"]'::jsonb, 'A1', 6, 'PUBLISHED', 'sol', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5391d05d-4835-5275-bbb0-47975379d7ae', 'type_answer', 'Напишіть хорватською: «борошно»', 'brašno', null, 'A1', 7, 'PUBLISHED', 'brašno', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f53cfbe-3c98-5962-86dc-1a2276ec79ac', 'type_answer', 'Напишіть хорватською: «оцет»', 'ocat', null, 'A1', 8, 'PUBLISHED', 'ocat', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dc35cdd1-c6ff-5663-8381-f5e80a5ddae4', 'type_answer', 'Напишіть хорватською: «візок (у супермаркеті)»', 'kolica', null, 'A1', 9, 'PUBLISHED', 'kolica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5ccb94c9-6107-50cf-b28c-1b34fe23549b', 'sentence_builder', 'Складіть: «Нам треба п’ять яєць.»', 'Trebamo pet jaja.', '["Trebamo", "jaja.", "pet"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c774ee08-4180-596a-af42-499554e03c1f', 'sentence_builder', 'Складіть: «Візьми дві банки тунця.»', 'Uzmi dvije konzerve tune.', '["konzerve", "dvije", "Uzmi", "tune."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e08ae49-acea-5932-a753-3a5a0c10cda2', 'listening', 'Прослухайте і складіть фразу', 'Imam. Trebamo dvije konzerve rajčice i litru ulja.', '["i", "litru", "rajčice", "Trebamo", "ulja.", "konzerve", "dvije", "Imam."]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a618ed32-9fcc-5b0b-9de4-3f7e0451e198', 'listening', 'Прослухайте і складіть фразу', 'Ocat je kod ulja, u trećem redu.', '["je", "u", "trećem", "kod", "Ocat", "ulja,", "redu."]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '232076c2-bfe0-52b7-ae11-535c896e0c6a', 'speaking', 'Два хліби, будь ласка.', 'Dva kruha, molim.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c4725690-4173-585a-8dd6-290443cd89f6', 'speaking', 'Де відділ молочних продуктів?', 'Gdje je odjel mliječnih proizvoda?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c483c41a-0c1c-586f-bef2-7cd400ef62bb', v_lesson, 'Що купити?', 'Što trebamo kupiti?', 3121, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('4f720a29-894f-5ee6-9492-5b63ead708ba', 'c483c41a-0c1c-586f-bef2-7cd400ef62bb', 'Luka', 'Dašo, imaš li popis za kupovinu?', 'Дашо, у тебе є список покупок?', 1);
  perform pg_temp.turn('04919465-1cc3-5e36-bd10-bbdb30a7cbf2', 'c483c41a-0c1c-586f-bef2-7cd400ef62bb', 'Daša', 'Imam. Trebamo dvije konzerve rajčice i litru ulja.', 'Є. Нам треба дві банки помідорів і літр олії.', 2);
  perform pg_temp.turn('777755e9-7969-59d8-be6b-03955dd9cc8d', 'c483c41a-0c1c-586f-bef2-7cd400ef62bb', 'Luka', 'A brašno?', 'А борошно?', 3);
  perform pg_temp.turn('f82f3476-8490-5a72-b522-c26e3a4fd873', 'c483c41a-0c1c-586f-bef2-7cd400ef62bb', 'Daša', 'Jedan kilogram brašna i deset jaja.', 'Кілограм борошна і десять яєць.', 4);
  perform pg_temp.turn('6917385f-88d1-5e3a-8f83-78e042a93252', 'c483c41a-0c1c-586f-bef2-7cd400ef62bb', 'Luka', 'Uzmi kolica, ja idem po mliječne proizvode.', 'Візьми візок, а я піду по молочні продукти.', 5);
  perform pg_temp.turn('19a84aef-2693-5f85-b7b0-4fba3f6ce083', 'c483c41a-0c1c-586f-bef2-7cd400ef62bb', 'Daša', 'Dobro. Nađimo se kod smrznutog povrća.', 'Добре. Зустрінемося біля заморожених овочів.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b72c7227-7275-5b25-8b34-c19d32745e7c', v_lesson, 'Де знайти?', 'Gdje mogu naći…?', 3122, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('386f9d73-b2fa-5f84-8892-eea12c2caf12', 'b72c7227-7275-5b25-8b34-c19d32745e7c', 'Darja', 'Oprostite, na kojem je odjelu ocat?', 'Перепрошую, у якому відділі оцет?', 1);
  perform pg_temp.turn('d5e9f576-0787-573f-b24d-eefb69f66e1f', 'b72c7227-7275-5b25-8b34-c19d32745e7c', 'Prodavačica', 'Ocat je kod ulja, u trećem redu.', 'Оцет біля олії, у третьому ряду.', 2);
  perform pg_temp.turn('b32e9800-44aa-57c8-a390-52edf1172af9', 'b72c7227-7275-5b25-8b34-c19d32745e7c', 'Darja', 'A sol i papar?', 'А сіль і перець?', 3);
  perform pg_temp.turn('00f85048-9106-5bad-bb03-40668aac90b2', 'b72c7227-7275-5b25-8b34-c19d32745e7c', 'Prodavačica', 'Isto tamo, pored začina.', 'Там само, біля спецій.', 4);
  perform pg_temp.turn('9de04b90-c112-5cc3-92bb-0a0087085107', 'b72c7227-7275-5b25-8b34-c19d32745e7c', 'Darja', 'Hvala. Imate li gotova jela?', 'Дякую. У вас є готові страви?', 5);
  perform pg_temp.turn('eed9490b-1f19-5bdb-bd50-4f27f89212e2', 'b72c7227-7275-5b25-8b34-c19d32745e7c', 'Prodavačica', 'Imamo, u hladnjaku na kraju trgovine.', 'Є, в холодильнику в кінці магазину.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 13: Ринок на тиждень: скільки чого? — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '46a89cf5-41e0-50a2-99b1-f4e66a5ff146';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Ринок на тиждень: скільки чого?» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '01e53678-8e41-5923-93e4-c1fe72cf00e4') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 13: Ринок на тиждень: скільки чого?', title_hr = 'Lekcija 13: Tržnica za cijeli tjedan',
         objectives = '["Купити овочі й фрукти на тиждень: glavica, vezica, grozd", "Запитати, що сезонне й місцеве", "Кількість + родовий: vezica peršina, kilogram trešanja"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Родовий відмінок: основи' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Родовий відмінок: основи»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'štand', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sezonski', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glavica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vezica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grozd', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smokva', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trešnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dinja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kupina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tikvica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'patlidžan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'peršin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zelena salata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mladi luk', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd1a42850-c0b7-5eb8-9a01-f470ef461534', 'fill_in_the_blank', 'Dajte mi vezicu ___, molim.', 'peršina', '["peršinu", "peršin", "peršina", "peršinom"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3df15f23-19c5-5eb0-adf2-5353d87a5782', 'multiple_choice', 'Що означає «zelena salata»?', 'салат (листя)', '["кабачок", "салат (листя)", "інжир", "головка (салату, капусти, часнику)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'zelena salata', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e80c82e3-dd5c-50f9-8f61-f327a1a937c0', 'multiple_choice', 'Що означає «sezonski»?', 'сезонний', '["пучок (зелені)", "гроно (винограду)", "диня", "сезонний"]'::jsonb, 'A1', 3, 'PUBLISHED', 'sezonski', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0fdc9440-f6cd-50f8-9e5c-ca8d72477429', 'multiple_choice', 'Що означає «smokva»?', 'інжир', '["диня", "інжир", "сезонний", "гроно (винограду)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'smokva', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8a6e4d41-ba1d-5c32-bb3f-05e751307e73', 'multiple_choice', 'Як хорватською «баклажан»?', 'patlidžan', '["peršin", "vezica", "patlidžan", "kupina"]'::jsonb, 'A1', 5, 'PUBLISHED', 'patlidžan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7f068037-271f-5b17-9d18-43a6dfafca64', 'multiple_choice', 'Як хорватською «пучок (зелені)»?', 'vezica', '["grozd", "patlidžan", "vezica", "dinja"]'::jsonb, 'A1', 6, 'PUBLISHED', 'vezica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8c5a751a-3d2c-5973-9ddc-e4811d52f891', 'type_answer', 'Напишіть хорватською: «головка (салату, капусти, часнику)»', 'glavica', null, 'A1', 7, 'PUBLISHED', 'glavica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a5a67b2b-4ea2-50d4-a329-fd7c0f4ea144', 'type_answer', 'Напишіть хорватською: «черешня»', 'trešnja', null, 'A1', 8, 'PUBLISHED', 'trešnja', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '336949f6-ca65-552a-9b0e-1e94defd47ec', 'type_answer', 'Напишіть хорватською: «петрушка»', 'peršin', null, 'A1', 9, 'PUBLISHED', 'peršin', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f07c2c8a-1b5f-508e-9fbb-baf8b46c6f19', 'sentence_builder', 'Складіть: «Кілограм черешень, будь ласка.»', 'Kilogram trešanja, molim.', '["trešanja,", "molim.", "Kilogram"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9da7ade6-8439-5925-b0c2-f0cbe4aae3ce', 'sentence_builder', 'Складіть: «Кабачки місцеві?»', 'Jesu li tikvice domaće?', '["Jesu", "tikvice", "domaće?", "li"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'baf64101-6dcc-51de-aefc-20d0fdad9b7d', 'listening', 'Прослухайте і складіть фразу', 'Dajte mi kilogram trešanja i jednu dinju.', '["mi", "kilogram", "dinju.", "jednu", "i", "Dajte", "trešanja"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ecf54894-8f99-5fde-a270-5b9190b41263', 'listening', 'Прослухайте і складіть фразу', 'Onda tri tikvice i dva patlidžana.', '["tri", "tikvice", "i", "Onda", "dva", "patlidžana."]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '76dc3723-dc7b-5ab0-8e20-049ac9610cf6', 'speaking', 'Що сьогодні сезонне?', 'Što je danas sezonsko?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c7fb743a-ca82-5af5-9c06-81aee1a45b90', 'speaking', 'Дайте мені дві головки салату.', 'Dajte mi dvije glavice salate.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('01e53678-8e41-5923-93e4-c1fe72cf00e4', v_lesson, 'Субота на ринку', 'Subotom na placu', 3131, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('075ea1b0-46c6-5320-9729-abbacc0e940d', '01e53678-8e41-5923-93e4-c1fe72cf00e4', 'Daša', 'Dobro jutro! Što je danas sezonsko?', 'Доброго ранку! Що сьогодні сезонне?', 1);
  perform pg_temp.turn('f9cee27d-f281-5e7f-8da4-c82e69c20f0e', '01e53678-8e41-5923-93e4-c1fe72cf00e4', 'Ivo', 'Trešnje, smokve i prve dinje.', 'Черешні, інжир і перші дині.', 2);
  perform pg_temp.turn('039fec3a-7390-5f99-a797-1f110e850a61', '01e53678-8e41-5923-93e4-c1fe72cf00e4', 'Daša', 'Dajte mi kilogram trešanja i jednu dinju.', 'Дайте мені кілограм черешень і одну диню.', 3);
  perform pg_temp.turn('af9cb313-141e-57d7-aef1-3fcbf82b57c3', '01e53678-8e41-5923-93e4-c1fe72cf00e4', 'Ivo', 'Izvolite. Trebate li još nešto?', 'Прошу. Потрібно ще щось?', 4);
  perform pg_temp.turn('7bfb8866-4d5e-5490-b4f6-de9f90f62a50', '01e53678-8e41-5923-93e4-c1fe72cf00e4', 'Daša', 'Dvije glavice zelene salate i vezicu peršina.', 'Дві головки салату й пучок петрушки.', 5);
  perform pg_temp.turn('79262daf-28be-5bd7-bc8a-b8ebe64fbdd1', '01e53678-8e41-5923-93e4-c1fe72cf00e4', 'Ivo', 'Peršin vam dajem gratis, stalna ste mušterija.', 'Петрушку даю вам безкоштовно, ви постійна покупчиня.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f5f7ee21-21d4-512f-9c62-7d362db80010', v_lesson, 'Овочі для рагу', 'Povrće za varivo', 3132, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('0d6c432d-bf94-5858-b294-b8cadc5561bc', 'f5f7ee21-21d4-512f-9c62-7d362db80010', 'Darja', 'Jesu li tikvice domaće?', 'Кабачки місцеві?', 1);
  perform pg_temp.turn('5b419371-6099-55b2-805b-11531dbf638c', 'f5f7ee21-21d4-512f-9c62-7d362db80010', 'Marija', 'Jesu, iz mog vrta. I patlidžani su domaći.', 'Так, з мого городу. І баклажани місцеві.', 2);
  perform pg_temp.turn('20ca41a1-aa1a-5d79-ae59-dc11d1369f5f', 'f5f7ee21-21d4-512f-9c62-7d362db80010', 'Darja', 'Onda tri tikvice i dva patlidžana.', 'Тоді три кабачки й два баклажани.', 3);
  perform pg_temp.turn('b15d100c-2079-5d31-acaf-84466d9a2123', 'f5f7ee21-21d4-512f-9c62-7d362db80010', 'Marija', 'Hoćete li i mladi luk? Svjež je od jutros.', 'Хочете ще й зелену цибулю? Свіжа, з самого ранку.', 4);
  perform pg_temp.turn('d6d1bab5-7b41-5543-b4eb-c012328dfa3b', 'f5f7ee21-21d4-512f-9c62-7d362db80010', 'Darja', 'Može jedna vezica. A koliko košta grozd grožđa?', 'Давайте один пучок. А скільки коштує гроно винограду?', 5);
  perform pg_temp.turn('ea755465-95af-513a-ae53-fff78e592f25', 'f5f7ee21-21d4-512f-9c62-7d362db80010', 'Marija', 'Dva eura. Uzmite i kupine, slatke su.', 'Два євро. Візьміть і ожину, вона солодка.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 14: У м’ясника й на рибному ринку — перебудова: 17 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'ae33e31a-f937-5305-908e-3d957df15f6a';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «У м’ясника й на рибному ринку» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'fb74c6b6-f5c4-5e7b-be73-58b7913d6cac') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 14: У м’ясника й на рибному ринку', title_hr = 'Lekcija 14: U mesnici i ribarnici',
         objectives = '["Купити м’ясо й рибу: odrezak, kotlet, pileća prsa, orada", "Попросити почистити рибу чи нарізати м’ясо", "Кількість: pola kile, tri komada, četiri kotleta"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Числа й кількість: dva kruha, pet jaja' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Числа й кількість: dva kruha, pet jaja»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'mesar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ribarnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'janjetina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'puretina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odrezak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kotlet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pileća prsa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'file', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lignja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srdela', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dagnja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oslić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'orada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brancin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plodovi mora', v_pos);
  v_pos := pg_temp.word(v_lesson, 'očistiti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ebaeb5fc-04d8-54fa-9635-bcc6d6cfcf32', 'fill_in_the_blank', 'Dajte mi četiri ___, molim.', 'kotleta', '["kotletima", "kotleta", "kotlet", "kotleti"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd321f7cd-43ec-550c-844c-da61a30ff6c1', 'multiple_choice', 'Що означає «orada»?', 'дорада (риба)', '["мідія", "котлета на кістці, відбивна", "дорада (риба)", "кістка"]'::jsonb, 'A1', 2, 'PUBLISHED', 'orada', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b51ac7c-700d-5e2e-8ae7-abd96376a22c', 'multiple_choice', 'Що означає «mesar»?', 'м’ясник', '["дорада (риба)", "ринок риби", "м’ясник", "відбивна; стейк"]'::jsonb, 'A1', 3, 'PUBLISHED', 'mesar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7c905f0c-a9e8-5143-8aba-b3dd28170daf', 'multiple_choice', 'Що означає «očistiti»?', 'почистити; випатрати (рибу)', '["м’ясник", "мідія", "хек", "почистити; випатрати (рибу)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'očistiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '981d14db-2983-5748-83e6-0a1c4812b31b', 'multiple_choice', 'Як хорватською «кальмар»?', 'lignja', '["plodovi mora", "lignja", "kost", "file"]'::jsonb, 'A1', 5, 'PUBLISHED', 'lignja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c2e8db44-2c9b-551a-8dfe-7742322085d6', 'multiple_choice', 'Як хорватською «кістка»?', 'kost', '["orada", "ribarnica", "file", "kost"]'::jsonb, 'A1', 6, 'PUBLISHED', 'kost', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a79939bb-2553-571e-9ac6-8c01b36efd4a', 'type_answer', 'Напишіть хорватською: «індичатина»', 'puretina', null, 'A1', 7, 'PUBLISHED', 'puretina', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7c69db5a-a84a-5d91-96d5-98a1ceb92714', 'type_answer', 'Напишіть хорватською: «хек»', 'oslić', null, 'A1', 8, 'PUBLISHED', 'oslić', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cc29724b-d784-5246-b234-fd48d56c3622', 'type_answer', 'Напишіть хорватською: «сардина»', 'srdela', null, 'A1', 9, 'PUBLISHED', 'srdela', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c51f1582-bbaf-52be-9ac2-cf531bdb9912', 'sentence_builder', 'Складіть: «Можете почистити рибу?»', 'Možete li očistiti ribu?', '["ribu?", "očistiti", "li", "Možete"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4c2eb85b-93a8-5a13-9bc3-389c65a00b89', 'sentence_builder', 'Складіть: «Пів кіло сардин, будь ласка.»', 'Pola kile srdela, molim.', '["kile", "Pola", "molim.", "srdela,"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a9b135f7-a934-5595-8bcf-aaa9b9da967f', 'listening', 'Прослухайте і складіть фразу', 'Pola kile pilećih prsa i četiri svinjska kotleta.', '["kotleta.", "pilećih", "Pola", "prsa", "i", "kile", "četiri", "svinjska"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '05a63d04-cad6-5218-9176-29a6fbd505d0', 'listening', 'Прослухайте і складіть фразу', 'Je li ova orada svježa?', '["li", "Je", "orada", "ova", "svježa?"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7e76f60d-ef79-5f0f-88db-f7a93131bf1a', 'speaking', 'Дайте мені два стейки.', 'Dajte mi dva odreska.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1dbab77a-2b01-5b44-a746-4f976e2f9700', 'speaking', 'У вас є морепродукти?', 'Imate li plodove mora?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('fb74c6b6-f5c4-5e7b-be73-58b7913d6cac', v_lesson, 'У м’ясника', 'Kod mesara', 3141, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('a8dcecd8-779c-5b63-8a96-7c433723b4a3', 'fb74c6b6-f5c4-5e7b-be73-58b7913d6cac', 'Mesar', 'Izvolite, gospođo, što vam treba?', 'Прошу, пані, що вам потрібно?', 1);
  perform pg_temp.turn('dab0519b-53c8-5182-aaa2-c6a294ea5dc1', 'fb74c6b6-f5c4-5e7b-be73-58b7913d6cac', 'Daša', 'Pola kile pilećih prsa i četiri svinjska kotleta.', 'Пів кіло курячих грудок і чотири свинячі відбивні.', 2);
  perform pg_temp.turn('a77e12ba-93b7-5445-b159-e213b91ca43b', 'fb74c6b6-f5c4-5e7b-be73-58b7913d6cac', 'Mesar', 'Imam i lijepu janjetinu i puretinu.', 'Є ще гарна ягнятина й індичатина.', 3);
  perform pg_temp.turn('15f3b27b-24b3-52a7-8e16-fbf7878bc33b', 'fb74c6b6-f5c4-5e7b-be73-58b7913d6cac', 'Daša', 'Ne danas. Možete li mi narezati dva odreska?', 'Не сьогодні. Можете нарізати мені два стейки?', 4);
  perform pg_temp.turn('3ae8df5d-50af-5e5c-b3c4-7d06cfe2de55', 'fb74c6b6-f5c4-5e7b-be73-58b7913d6cac', 'Mesar', 'Mogu. Kosti za juhu vam dajem besplatno.', 'Можу. Кістки для супу даю вам безкоштовно.', 5);
  perform pg_temp.turn('f1fbb6db-76ea-550d-9e0f-41efcdfc1424', 'fb74c6b6-f5c4-5e7b-be73-58b7913d6cac', 'Daša', 'Hvala, to je super za nedjeljnu juhu.', 'Дякую, це чудово для недільного супу.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a526cad8-1bd8-542e-bdc4-7dbb9e7b1200', v_lesson, 'На рибному ринку', 'U ribarnici', 3142, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('64271ec8-16ce-5321-9359-ac3e4139aa0c', 'a526cad8-1bd8-542e-bdc4-7dbb9e7b1200', 'Darja', 'Je li ova orada svježa?', 'Ця дорада свіжа?', 1);
  perform pg_temp.turn('2230414b-e282-5f0c-ae06-36c39d6b41b0', 'a526cad8-1bd8-542e-bdc4-7dbb9e7b1200', 'Toni', 'Jutros je ulovljena, kao i brancin.', 'Її впіймали сьогодні вранці, як і сібаса.', 2);
  perform pg_temp.turn('155de4d5-b2f4-5dbc-98b1-b0cf89ff2518', 'a526cad8-1bd8-542e-bdc4-7dbb9e7b1200', 'Darja', 'Dajte mi dvije orade. Možete li ih očistiti?', 'Дайте мені дві доради. Можете їх почистити?', 3);
  perform pg_temp.turn('2bf91024-48f9-565c-9709-eb25e0edf036', 'a526cad8-1bd8-542e-bdc4-7dbb9e7b1200', 'Toni', 'Naravno. Imamo i lignje i srdele.', 'Звісно. Є ще кальмари й сардини.', 4);
  perform pg_temp.turn('16eca25f-f61f-5a02-9165-ce3193a12303', 'a526cad8-1bd8-542e-bdc4-7dbb9e7b1200', 'Darja', 'Pola kile srdela za roštilj, molim.', 'Пів кіло сардин для гриля, будь ласка.', 5);
  perform pg_temp.turn('cfde911e-187d-5325-8777-eff2cee0fabc', 'a526cad8-1bd8-542e-bdc4-7dbb9e7b1200', 'Toni', 'Izvolite. Za djecu je dobar file oslića, nema kostiju.', 'Прошу. Для дітей добре філе хека, у ньому немає кісток.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 15: У кафе й пекарні — перебудова: 10 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '1e8c2d0e-28f6-5873-aa9f-5d0ad2567fb8';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «У кафе й пекарні» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'f58385dd-73d9-587e-893a-6d66a21608de') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 15: У кафе й пекарні', title_hr = 'Lekcija 15: U kafiću i pekari',
         objectives = '["Купити випічку в пекарні: burek, kifla, perec, pita", "Замовити напій з собою: kava za van, topla čokolada", "Знахідний відмінок: Uzet ću burek i jednu kiflu."]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Знахідний відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Знахідний відмінок»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'burek', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kifla', v_pos);
  v_pos := pg_temp.word(v_lesson, 'perec', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pita', v_pos);
  v_pos := pg_temp.word(v_lesson, 'štrudla', v_pos);
  v_pos := pg_temp.word(v_lesson, 'krafna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kava za van', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čaj s limunom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'topla čokolada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slatko', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a0233116-8869-5334-858c-65baff0d4155', 'fill_in_the_blank', 'Uzet ću jednu ___ od jabuka.', 'pitu', '["pitu", "pite", "pita", "pitom"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4bd41e6e-0702-5edc-a439-146d78f5b64b', 'multiple_choice', 'Що означає «pita»?', 'пиріг (листковий)', '["брецель", "кава з собою", "гарячий шоколад", "пиріг (листковий)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'pita', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cce0c029-b3dd-5ce8-a6a8-b16089331ce0', 'multiple_choice', 'Що означає «topla čokolada»?', 'гарячий шоколад', '["рогалик", "пончик", "чай з лимоном", "гарячий шоколад"]'::jsonb, 'A1', 3, 'PUBLISHED', 'topla čokolada', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d1e02b9-cd3f-52d3-ad0e-46866b980815', 'multiple_choice', 'Що означає «čaj s limunom»?', 'чай з лимоном', '["чай з лимоном", "гарячий шоколад", "кава з собою", "брецель"]'::jsonb, 'A1', 4, 'PUBLISHED', 'čaj s limunom', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '69823502-de5d-5526-8be8-adc4f8518fd6', 'multiple_choice', 'Як хорватською «рогалик»?', 'kifla', '["kifla", "štrudla", "pita", "perec"]'::jsonb, 'A1', 5, 'PUBLISHED', 'kifla', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d2268f1-2329-5f3a-b661-b8e77c2b1a2c', 'multiple_choice', 'Як хорватською «пончик»?', 'krafna', '["kava za van", "krafna", "perec", "čaj s limunom"]'::jsonb, 'A1', 6, 'PUBLISHED', 'krafna', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6edb4028-105a-5e44-8d94-9608da08537a', 'type_answer', 'Напишіть хорватською: «штрудель»', 'štrudla', null, 'A1', 7, 'PUBLISHED', 'štrudla', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd7d27050-ef0c-51d0-b815-f66c68b9f8e5', 'type_answer', 'Напишіть хорватською: «солодке»', 'slatko', null, 'A1', 8, 'PUBLISHED', 'slatko', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '433ad5e4-2fc5-5faa-93eb-25868fae55ee', 'type_answer', 'Напишіть хорватською: «брецель»', 'perec', null, 'A1', 9, 'PUBLISHED', 'perec', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '249f32c6-9701-5532-9b83-983af15eb589', 'sentence_builder', 'Складіть: «Одну каву з собою, будь ласка.»', 'Jednu kavu za van, molim.', '["van,", "molim.", "Jednu", "za", "kavu"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd62286e1-58c3-5c17-99d3-1a55acfad635', 'sentence_builder', 'Складіть: «Син обожнює брецелі.»', 'Sin obožava perece.', '["obožava", "Sin", "perece."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7085128a-0c84-53af-8ba6-69765c0d5de9', 'listening', 'Прослухайте і складіть фразу', 'Jedan burek sa sirom i dvije kifle, molim.', '["kifle,", "Jedan", "sirom", "burek", "i", "molim.", "dvije", "sa"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2e67e83c-5203-5d06-ba00-84be1eb495e3', 'listening', 'Прослухайте і складіть фразу', 'A za malu? Imamo toplu čokoladu.', '["za", "malu?", "toplu", "Imamo", "A", "čokoladu."]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cbab013f-9277-5c3f-9e5e-f9a79fa318a8', 'speaking', 'Гарячий шоколад, будь ласка.', 'Toplu čokoladu, molim.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ef3745df-897c-5891-987e-f038887b700d', 'speaking', 'У вас є щось солодке?', 'Imate li nešto slatko?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f58385dd-73d9-587e-893a-6d66a21608de', v_lesson, 'У пекарні', 'U pekari', 3151, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('d7a33d64-c56c-556c-9d11-af6cc8e76241', 'f58385dd-73d9-587e-893a-6d66a21608de', 'Ana', 'Dobro jutro, izvolite!', 'Доброго ранку, прошу!', 1);
  perform pg_temp.turn('6f0a9ff7-fe43-55a7-ae5a-056414c0cc8a', 'f58385dd-73d9-587e-893a-6d66a21608de', 'Daša', 'Jedan burek sa sirom i dvije kifle, molim.', 'Один бурек із сиром і два рогалики, будь ласка.', 2);
  perform pg_temp.turn('f75e4c7b-a7cf-52e7-b07c-d719ad29d733', 'f58385dd-73d9-587e-893a-6d66a21608de', 'Ana', 'Želite li još nešto slatko? Štrudla je topla.', 'Бажаєте ще щось солодке? Штрудель теплий.', 3);
  perform pg_temp.turn('3bcb11cd-1f96-5ba2-aabc-72910e6f0108', 'f58385dd-73d9-587e-893a-6d66a21608de', 'Daša', 'Može jedna štrudla od jabuka.', 'Давайте один яблучний штрудель.', 4);
  perform pg_temp.turn('331b62b9-721f-5605-a072-d8703415035d', 'f58385dd-73d9-587e-893a-6d66a21608de', 'Ana', 'Izvolite. To je sedam eura.', 'Прошу. Це сім євро.', 5);
  perform pg_temp.turn('e00a2ed7-2327-5b53-82a3-ab738daaad2b', 'f58385dd-73d9-587e-893a-6d66a21608de', 'Daša', 'Imate li i perece? Sin ih obožava.', 'А брецелі у вас є? Син їх обожнює.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('dd088dad-8042-58f2-99c3-ff225c7a8848', v_lesson, 'Кава з собою', 'Kava za van', 3152, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('ac4d1074-1f1d-59cf-bf13-0571eaaa054d', 'dd088dad-8042-58f2-99c3-ff225c7a8848', 'Marko', 'Dobar dan, što ćete popiti?', 'Добрий день, що будете пити?', 1);
  perform pg_temp.turn('e9c4d49d-c2a8-519d-b250-5a1c3c85b632', 'dd088dad-8042-58f2-99c3-ff225c7a8848', 'Darja', 'Jednu kavu za van i jedan čaj s limunom.', 'Одну каву з собою й один чай з лимоном.', 2);
  perform pg_temp.turn('7ab1ecdd-af9b-54ec-9872-5e8ae37d23d7', 'dd088dad-8042-58f2-99c3-ff225c7a8848', 'Marko', 'A za malu? Imamo toplu čokoladu.', 'А для малої? У нас є гарячий шоколад.', 3);
  perform pg_temp.turn('1411bb7f-4cf7-5a17-be10-182947baa45c', 'dd088dad-8042-58f2-99c3-ff225c7a8848', 'Darja', 'Može topla čokolada, ali ne prevruća.', 'Давайте гарячий шоколад, але не надто гарячий.', 4);
  perform pg_temp.turn('ab98df82-50ba-5133-a8ec-ec676554bdf3', 'dd088dad-8042-58f2-99c3-ff225c7a8848', 'Marko', 'Nema problema. Želite li i krafnu?', 'Без проблем. Бажаєте ще пончик?', 5);
  perform pg_temp.turn('95cfb903-e684-56ba-8077-8c529170cc49', 'dd088dad-8042-58f2-99c3-ff225c7a8848', 'Darja', 'Ne, hvala, kupile smo pitu u pekari.', 'Ні, дякую, ми купили пиріг у пекарні.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 17: Готуємо вдома: рецепт — перебудова: 16 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '3e652232-866b-5edf-ac05-d61ee7a325fe';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Готуємо вдома: рецепт» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'db2d343e-894a-5f19-907f-bae36749775c') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 17: Готуємо вдома: рецепт', title_hr = 'Lekcija 17: Kuhamo po receptu',
         objectives = '["Зрозуміти й переказати простий рецепт: oguli, nasjeckaj, prži, peci", "Назвати інгредієнти й спеції", "Наказовий спосіб для рецепта: ti і vi"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Наказовий спосіб' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Наказовий спосіб»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'sastojak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tijesto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'začin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rezati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nasjeckati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'oguliti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'miješati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izmiješati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pržiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'peći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispeći', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zagrijati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dodati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posoliti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'popapriti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maslinovo ulje', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c560ba4e-22d4-5901-a8ee-c182cc50e9e7', 'fill_in_the_blank', 'Prvo ___ jabuke, a onda ih nasjeckaj.', 'oguli', '["oguliti", "oguli", "gulim", "oguljen"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'da23e2ea-0671-542b-ac9f-55985f56f17e', 'multiple_choice', 'Що означає «nasjeckati»?', 'посікти, дрібно нарізати', '["різати", "посікти, дрібно нарізати", "розігріти; нагріти", "смажити"]'::jsonb, 'A1', 2, 'PUBLISHED', 'nasjeckati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd0061ae-05d4-5380-903c-dbb0ffacd318', 'multiple_choice', 'Що означає «dodati»?', 'додати', '["змішати", "додати", "почистити (від шкірки)", "поперчити"]'::jsonb, 'A1', 3, 'PUBLISHED', 'dodati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '659cd778-0aab-5c63-9026-bea26c9c4fc6', 'multiple_choice', 'Що означає «pržiti»?', 'смажити', '["спекти; засмажити", "додати", "оливкова олія", "смажити"]'::jsonb, 'A1', 4, 'PUBLISHED', 'pržiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ba01ae51-a289-5d2d-98dc-7487fe9f5c1c', 'multiple_choice', 'Як хорватською «пекти; запікати»?', 'peći', '["tijesto", "ispeći", "peći", "miješati"]'::jsonb, 'A1', 5, 'PUBLISHED', 'peći', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8fe3dd02-3bd8-5361-bca8-8d928cb42583', 'multiple_choice', 'Як хорватською «інгредієнт»?', 'sastojak', '["peći", "sastojak", "posoliti", "pržiti"]'::jsonb, 'A1', 6, 'PUBLISHED', 'sastojak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '80f7cec1-7846-54eb-964a-3144e1ebd219', 'type_answer', 'Напишіть хорватською: «спеція, приправа»', 'začin', null, 'A1', 7, 'PUBLISHED', 'začin', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2b9c9b1a-3328-52e2-a701-a67ffb113327', 'type_answer', 'Напишіть хорватською: «поперчити»', 'popapriti', null, 'A1', 8, 'PUBLISHED', 'popapriti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c16dd4b2-8012-58b8-bc38-a4815b969e86', 'type_answer', 'Напишіть хорватською: «мішати; перемішувати»', 'miješati', null, 'A1', 9, 'PUBLISHED', 'miješati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0479ddb0-119b-5515-8bbd-7d591036cfc0', 'sentence_builder', 'Складіть: «Розігрій духовку до двохсот градусів.»', 'Zagrij pećnicu na dvjesto stupnjeva.', '["pećnicu", "na", "dvjesto", "stupnjeva.", "Zagrij"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '44271151-a8bd-55f5-999b-9eaecf73af00', 'sentence_builder', 'Складіть: «Посоли й поперчи м’ясо.»', 'Posoli i popapri meso.', '["meso.", "Posoli", "popapri", "i"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '002a0181-8be2-5acf-a21e-30d60c15da10', 'listening', 'Прослухайте і складіть фразу', 'Izmiješaj brašno, jaja, šećer i malo ulja.', '["Izmiješaj", "šećer", "jaja,", "ulja.", "i", "brašno,", "malo"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c268febc-0a4a-5f0c-8d5a-d9757b534f9f', 'listening', 'Прослухайте і складіть фразу', 'Pržim ga na maslinovom ulju?', '["ulju?", "na", "ga", "maslinovom", "Pržim"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e6a6b2c6-835e-5d1d-a2be-b17a48278386', 'speaking', 'Поріж цибулю, будь ласка.', 'Nasjeckaj luk, molim te.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '045d6224-00de-5580-a37a-c6f738dcfc4d', 'speaking', 'Додайте трохи солі.', 'Dodajte malo soli.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('db2d343e-894a-5f19-907f-bae36749775c', v_lesson, 'Бабусин рецепт', 'Bakin recept', 3171, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('b59ddfc7-3751-5bf1-8a69-f01417086137', 'db2d343e-894a-5f19-907f-bae36749775c', 'Daša', 'Bako, kako se radi tvoj kolač s jabukama?', 'Бабусю, як робиться твій пиріг з яблуками?', 1);
  perform pg_temp.turn('b368b897-0101-55e8-b658-32c05321c204', 'db2d343e-894a-5f19-907f-bae36749775c', 'Baka', 'Prvo oguli jabuke i nasjeckaj ih.', 'Спочатку почисть яблука й поріж їх.', 2);
  perform pg_temp.turn('36c9c8af-0fd5-5f60-b887-e015785d078c', 'db2d343e-894a-5f19-907f-bae36749775c', 'Daša', 'A tijesto?', 'А тісто?', 3);
  perform pg_temp.turn('ef444c24-1cb9-5fa8-8e9c-6570ec37ac89', 'db2d343e-894a-5f19-907f-bae36749775c', 'Baka', 'Izmiješaj brašno, jaja, šećer i malo ulja.', 'Змішай борошно, яйця, цукор і трохи олії.', 4);
  perform pg_temp.turn('b11cc274-9600-50ee-ac48-3443e703aa13', 'db2d343e-894a-5f19-907f-bae36749775c', 'Daša', 'Koliko ga dugo pečeš?', 'Скільки часу ти його печеш?', 5);
  perform pg_temp.turn('4b4a793b-06c1-5a7d-8915-1dd93a35a43e', 'db2d343e-894a-5f19-907f-bae36749775c', 'Baka', 'Zagrij pećnicu na sto osamdeset i peci ga četrdeset minuta.', 'Розігрій духовку до ста вісімдесяти й печи сорок хвилин.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f91ba100-6fe4-5544-b40e-84b330585cc0', v_lesson, 'Курка з овочами', 'Piletina s povrćem', 3172, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('bb282e3a-4f3d-55c5-bb56-5a8d95ba5a69', 'f91ba100-6fe4-5544-b40e-84b330585cc0', 'Luka', 'Što kuhamo večeras?', 'Що готуємо сьогодні ввечері?', 1);
  perform pg_temp.turn('b38570eb-00e9-5f2f-94e8-0bb39a425952', 'f91ba100-6fe4-5544-b40e-84b330585cc0', 'Darja', 'Piletinu s povrćem. Imamo li sve sastojke?', 'Курку з овочами. У нас є всі інгредієнти?', 2);
  perform pg_temp.turn('96743a3b-b758-5605-be9e-196445d2b025', 'f91ba100-6fe4-5544-b40e-84b330585cc0', 'Luka', 'Imamo. Koje začine trebamo?', 'Є. Які спеції потрібні?', 3);
  perform pg_temp.turn('ae217b54-8201-5faa-8a2f-cab276c1412a', 'f91ba100-6fe4-5544-b40e-84b330585cc0', 'Darja', 'Ružmarin i češnjak. Meso posoli i popapri.', 'Розмарин і часник. М’ясо посоли й поперчи.', 4);
  perform pg_temp.turn('c2b3f488-b219-51ab-a85b-d1649eaf3ded', 'f91ba100-6fe4-5544-b40e-84b330585cc0', 'Luka', 'Pržim ga na maslinovom ulju?', 'Смажу його на оливковій олії?', 5);
  perform pg_temp.turn('4f56283b-2a11-54d1-a5b4-01553eb33f70', 'f91ba100-6fe4-5544-b40e-84b330585cc0', 'Darja', 'Da, pa dodaj povrće i miješaj deset minuta.', 'Так, потім додай овочі й помішуй десять хвилин.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 18: Готуємо суп — перебудова: 13 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '17fcd38a-e295-5849-9ba3-1ef240c6be78';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Готуємо суп» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'e995d1ea-023d-5f85-97c9-aa6e0c96ed5f') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 18: Готуємо суп', title_hr = 'Lekcija 18: Kuhamo juhu',
         objectives = '["Розповісти, як ви варите суп: zakuham vodu, dodam povrće", "Назвати кухонний посуд: lonac, tava, poklopac", "Теперішній час: kuham, kuhaš, kuha; dodam, dodaš"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Теперішній час' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Теперішній час»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'lonac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poklopac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kuhati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zakuhati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prokuhati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ohladiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gust', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vruć', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rezanci', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kockica za juhu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'celer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grah', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '6f2f6bd8-0fb9-5f7f-b5d5-65c9d9abf6aa', 'fill_in_the_blank', 'Juha je gotova, ali je još ___.', 'vruća', '["vruća", "vruće", "vrućom", "vruć"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1ecd24dc-fe8e-5bdb-b75c-605ebe07269a', 'multiple_choice', 'Що означає «vruć»?', 'гарячий', '["варити / готувати їжу", "гарячий", "охолодити", "локшина"]'::jsonb, 'A1', 2, 'PUBLISHED', 'vruć', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1480053e-67d2-5f41-b1bb-bd4590e9789e', 'multiple_choice', 'Що означає «kockica za juhu»?', 'бульйонний кубик', '["каструля", "бульйонний кубик", "прокип’ятити; прокипіти", "селера"]'::jsonb, 'A1', 3, 'PUBLISHED', 'kockica za juhu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c738e5a-b164-52a1-8df9-654d87c95e98', 'multiple_choice', 'Що означає «gust»?', 'густий', '["кришка", "густий", "каструля", "варити / готувати їжу"]'::jsonb, 'A1', 4, 'PUBLISHED', 'gust', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '43a844bc-714b-5093-995e-2f8dbf5cf7bd', 'multiple_choice', 'Як хорватською «сковорідка»?', 'tava', '["lonac", "vruć", "tava", "rezanci"]'::jsonb, 'A1', 5, 'PUBLISHED', 'tava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2ac5e833-9731-59ac-bd89-ad0a87ab9c0f', 'multiple_choice', 'Як хорватською «кришка»?', 'poklopac', '["kuhati", "grah", "poklopac", "ohladiti"]'::jsonb, 'A1', 6, 'PUBLISHED', 'poklopac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '405c32bf-375a-5e9b-a1a8-5048f89f60bc', 'type_answer', 'Напишіть хорватською: «каструля»', 'lonac', null, 'A1', 7, 'PUBLISHED', 'lonac', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eaf89480-54e1-5646-8fd2-dc8abb0b7e3f', 'type_answer', 'Напишіть хорватською: «селера»', 'celer', null, 'A1', 8, 'PUBLISHED', 'celer', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7e34f3ee-2b02-5803-b6c7-448b22f35ec3', 'type_answer', 'Напишіть хорватською: «локшина»', 'rezanci', null, 'A1', 9, 'PUBLISHED', 'rezanci', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'df2722bc-3f28-5479-afb0-76e9cbf50074', 'sentence_builder', 'Складіть: «Я варю суп у великій каструлі.»', 'Kuham juhu u velikom loncu.', '["Kuham", "loncu.", "juhu", "velikom", "u"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd6d66910-a098-5ac9-8f12-4e7b387046ac', 'sentence_builder', 'Складіть: «Накрий каструлю кришкою.»', 'Pokrij lonac poklopcem.', '["Pokrij", "poklopcem.", "lonac"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5cb465c5-4813-5786-bd0e-caecfd767d70', 'listening', 'Прослухайте і складіть фразу', 'Stavljaš li kockicu za juhu?', '["juhu?", "li", "za", "Stavljaš", "kockicu"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c2843302-832f-5c77-8039-249c3d0841c7', 'listening', 'Прослухайте і складіть фразу', 'Mogu li maknuti poklopac?', '["maknuti", "poklopac?", "Mogu", "li"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2f10a822-273b-5991-ad20-1564c97298ed', 'speaking', 'Що ти вариш?', 'Što kuhaš?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd33fa21f-b988-50a9-a1a2-2389d7dae309', 'speaking', 'Сковорідка гаряча, обережно!', 'Tava je vruća, pazi!', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e995d1ea-023d-5f85-97c9-aa6e0c96ed5f', v_lesson, 'Курячий суп', 'Pileća juha', 3181, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('4f6683bd-c20c-5086-b2eb-765db2861c93', 'e995d1ea-023d-5f85-97c9-aa6e0c96ed5f', 'Ivana', 'Dašo, kako ti kuhaš pileću juhu?', 'Дашо, як ти вариш курячий суп?', 1);
  perform pg_temp.turn('3c76f286-2e64-5a61-9ef2-c2253c1a2ea1', 'e995d1ea-023d-5f85-97c9-aa6e0c96ed5f', 'Daša', 'Stavim piletinu u veliki lonac i zakuham vodu.', 'Кладу курку у велику каструлю й закип’ячую воду.', 2);
  perform pg_temp.turn('17683f43-72c9-54cf-b5be-bf61ae69df79', 'e995d1ea-023d-5f85-97c9-aa6e0c96ed5f', 'Ivana', 'A povrće?', 'А овочі?', 3);
  perform pg_temp.turn('d942014d-9357-5e0e-b24a-14c53f124562', 'e995d1ea-023d-5f85-97c9-aa6e0c96ed5f', 'Daša', 'Dodam mrkvu, celer i peršin i kuham sat vremena.', 'Додаю моркву, селеру й петрушку і варю годину.', 4);
  perform pg_temp.turn('423f0534-b471-5269-91b0-3e28bfa5c229', 'e995d1ea-023d-5f85-97c9-aa6e0c96ed5f', 'Ivana', 'Stavljaš li kockicu za juhu?', 'Ти кладеш бульйонний кубик?', 5);
  perform pg_temp.turn('1a1afc6d-547b-574d-a35f-246a3e4ac342', 'e995d1ea-023d-5f85-97c9-aa6e0c96ed5f', 'Daša', 'Ne, na kraju dodam samo domaće rezance.', 'Ні, наприкінці додаю тільки домашню локшину.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('685cbe6d-7c68-5d12-a5b2-28f228a5ce60', v_lesson, 'Обережно, гаряче!', 'Pazi, vruće je!', 3182, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('54463808-1e4b-5f22-ae50-5b49f5cda936', '685cbe6d-7c68-5d12-a5b2-28f228a5ce60', 'Filip', 'Mama, je li juha gotova?', 'Мамо, суп готовий?', 1);
  perform pg_temp.turn('9d7d1ec3-e3fa-560c-b911-93a19d4c3cbd', '685cbe6d-7c68-5d12-a5b2-28f228a5ce60', 'Darja', 'Skoro. Grah mora još malo prokuhati.', 'Майже. Квасоля має ще трохи прокипіти.', 2);
  perform pg_temp.turn('979a7141-663c-590a-85ee-c341d4265b08', '685cbe6d-7c68-5d12-a5b2-28f228a5ce60', 'Filip', 'Mogu li maknuti poklopac?', 'Можна зняти кришку?', 3);
  perform pg_temp.turn('e0d06026-f729-58df-aecf-ef9dd603be87', '685cbe6d-7c68-5d12-a5b2-28f228a5ce60', 'Darja', 'Ne diraj, lonac je vruć!', 'Не чіпай, каструля гаряча!', 4);
  perform pg_temp.turn('6f5ff437-6997-5853-9ccf-b92d27b4e959', '685cbe6d-7c68-5d12-a5b2-28f228a5ce60', 'Filip', 'Juha je jako gusta.', 'Суп дуже густий.', 5);
  perform pg_temp.turn('8e0cb67a-5ab6-5e34-9f51-8f849c8db2e3', '685cbe6d-7c68-5d12-a5b2-28f228a5ce60', 'Darja', 'Takva treba biti. Prvo je malo ohladimo.', 'Таким він і має бути. Спершу трохи його охолодимо.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 19: Столик на двох: бронювання — перебудова: 12 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '5e4a1c56-3931-58bb-81af-cb598966da77';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Столик на двох: бронювання» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '0fa25888-cb87-53d8-926d-4b1c273d3aff') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 19: Столик на двох: бронювання', title_hr = 'Lekcija 19: Rezervacija stola',
         objectives = '["Забронювати столик телефоном: za koliko osoba, na ime", "Попросити місце біля вікна й винну карту", "Модальні дієслова: Mogu li…? Moram otkazati…"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Модальні дієслова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Модальні дієслова»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'na ime', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slobodan stol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stol uz prozor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stol za četvero', v_pos);
  v_pos := pg_temp.word(v_lesson, 'za koliko osoba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zauzeto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'unaprijed', v_pos);
  v_pos := pg_temp.word(v_lesson, 'specijalitet kuće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preporuka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vinska karta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potvrditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otkazati rezervaciju', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '459576af-0cec-545c-b542-20c1290cfd42', 'fill_in_the_blank', 'Možete li nam ___ vinsku kartu?', 'donijeti', '["donosi", "donesite", "donio", "donijeti"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '95695755-6633-5fc5-93ef-55c1f6579965', 'multiple_choice', 'Що означає «otkazati rezervaciju»?', 'скасувати бронювання', '["скасувати бронювання", "фірмова страва закладу", "заздалегідь, наперед", "на скільки осіб"]'::jsonb, 'A1', 2, 'PUBLISHED', 'otkazati rezervaciju', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '262f7283-ef99-5ca2-bdbd-b52d64409137', 'multiple_choice', 'Що означає «na ime»?', 'на ім’я', '["заздалегідь, наперед", "столик біля вікна", "винна карта", "на ім’я"]'::jsonb, 'A1', 3, 'PUBLISHED', 'na ime', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c7aa905f-9cb1-511c-b243-19f9f989c008', 'multiple_choice', 'Що означає «slobodan stol»?', 'вільний столик', '["рекомендація", "вільний столик", "фірмова страва закладу", "скасувати бронювання"]'::jsonb, 'A1', 4, 'PUBLISHED', 'slobodan stol', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '81b20abe-e803-511d-b7de-77596b2bbf59', 'multiple_choice', 'Що означає «stol za četvero»?', 'столик на чотирьох', '["винна карта", "столик на чотирьох", "підтвердити", "на скільки осіб"]'::jsonb, 'A1', 5, 'PUBLISHED', 'stol za četvero', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd1026f66-2066-588d-8499-a43030282dcb', 'multiple_choice', 'Як хорватською «рекомендація»?', 'preporuka', '["preporuka", "za koliko osoba", "slobodan stol", "na ime"]'::jsonb, 'A1', 6, 'PUBLISHED', 'preporuka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7f3ddcdb-f73b-58b4-bac1-25360d6f2512', 'multiple_choice', 'Як хорватською «підтвердити»?', 'potvrditi', '["potvrditi", "na ime", "otkazati rezervaciju", "slobodan stol"]'::jsonb, 'A1', 7, 'PUBLISHED', 'potvrditi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '49e6b37c-9ce5-5f81-a0b7-e2309e130f6b', 'type_answer', 'Напишіть хорватською: «заздалегідь, наперед»', 'unaprijed', null, 'A1', 8, 'PUBLISHED', 'unaprijed', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e96f534-b777-5ca4-8f08-2873ba0aeee9', 'type_answer', 'Напишіть хорватською: «зайнято»', 'zauzeto', null, 'A1', 9, 'PUBLISHED', 'zauzeto', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b47c1247-7712-554a-b091-7ed0dd94350c', 'sentence_builder', 'Складіть: «У вас є вільний столик на двох?»', 'Imate li slobodan stol za dvoje?', '["slobodan", "dvoje?", "li", "Imate", "za", "stol"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '142711be-f979-5f09-9be3-b146d1d02c78', 'sentence_builder', 'Складіть: «Мені треба скасувати бронювання.»', 'Moram otkazati rezervaciju.', '["rezervaciju.", "otkazati", "Moram"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'abbde0ec-d323-5875-8bca-62c6cdcbe876', 'listening', 'Прослухайте і складіть фразу', 'Stol za četvero u osam. Može li uz prozor?', '["osam.", "četvero", "li", "Stol", "prozor?", "za", "u", "Može", "uz"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6ac189df-279b-57fd-bd73-e4bb23b62b60', 'listening', 'Прослухайте і складіть фразу', 'Darja Petrenko. Možemo li doći u subotu?', '["Darja", "li", "u", "subotu?", "doći", "Petrenko.", "Možemo"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '37f740b2-e495-58a6-9f2d-4b54d35c2775', 'speaking', 'Можна винну карту?', 'Mogu li dobiti vinsku kartu?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c4f580f1-634a-5120-90b7-1ae24d689def', 'speaking', 'Столик на чотирьох, будь ласка.', 'Stol za četvero, molim.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0fa25888-cb87-53d8-926d-4b1c273d3aff', v_lesson, 'Дзвінок у ресторан', 'Poziv u restoran', 3191, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('b96c54b7-681c-5692-80dd-431d01b9cade', '0fa25888-cb87-53d8-926d-4b1c273d3aff', 'Konobarica', 'Restoran Mornar, izvolite.', 'Ресторан «Морнар», слухаю.', 1);
  perform pg_temp.turn('1193c208-e5b9-526b-b9d1-268570bd622c', '0fa25888-cb87-53d8-926d-4b1c273d3aff', 'Daša', 'Dobar dan, imate li slobodan stol za subotu navečer?', 'Добрий день, у вас є вільний столик на суботу ввечері?', 2);
  perform pg_temp.turn('dba2da1f-66ef-5dc6-af28-be17f34df6e3', '0fa25888-cb87-53d8-926d-4b1c273d3aff', 'Konobarica', 'Za koliko osoba i u koliko sati?', 'На скільки осіб і о котрій?', 3);
  perform pg_temp.turn('5f55d365-5351-581a-8dca-791e9fa95869', '0fa25888-cb87-53d8-926d-4b1c273d3aff', 'Daša', 'Stol za četvero u osam. Može li uz prozor?', 'Столик на чотирьох о восьмій. Можна біля вікна?', 4);
  perform pg_temp.turn('e9e9cf6a-6049-567a-a600-bec1237d64eb', '0fa25888-cb87-53d8-926d-4b1c273d3aff', 'Konobarica', 'Može. Na koje ime?', 'Можна. На яке ім’я?', 5);
  perform pg_temp.turn('6885ed6d-15a6-51dd-afef-4317203ea645', '0fa25888-cb87-53d8-926d-4b1c273d3aff', 'Daša', 'Na ime Kovalenko. Hvala!', 'На ім’я Коваленко. Дякую!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ffce2e6c-23d5-5ab6-9a44-2676da07b2a7', v_lesson, 'Зміна планів', 'Promjena plana', 3192, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('8ebbdfb5-2b57-5ec1-8130-a0d0fb255353', 'ffce2e6c-23d5-5ab6-9a44-2676da07b2a7', 'Darja', 'Dobar dan, moram otkazati rezervaciju za petak.', 'Добрий день, мені треба скасувати бронювання на п’ятницю.', 1);
  perform pg_temp.turn('4ad657d3-0dcd-52e1-a5aa-6007ac25dbf7', 'ffce2e6c-23d5-5ab6-9a44-2676da07b2a7', 'Konobar', 'Recite mi, na koje ime?', 'Скажіть, на яке ім’я?', 2);
  perform pg_temp.turn('3a315aed-d8db-5557-9745-5e22756a1843', 'ffce2e6c-23d5-5ab6-9a44-2676da07b2a7', 'Darja', 'Darja Petrenko. Možemo li doći u subotu?', 'Дар’я Петренко. Можемо прийти в суботу?', 3);
  perform pg_temp.turn('f2e2e120-fa9d-5444-b30b-cc1c682eec78', 'ffce2e6c-23d5-5ab6-9a44-2676da07b2a7', 'Konobar', 'Nažalost, u subotu je sve zauzeto, ali u nedjelju imamo slobodan stol.', 'На жаль, у суботу все зайнято, але в неділю є вільний столик.', 4);
  perform pg_temp.turn('d96b69ee-57af-558a-aa97-b2b2b18ed1a8', 'ffce2e6c-23d5-5ab6-9a44-2676da07b2a7', 'Darja', 'Može nedjelja. Što je specijalitet kuće? Imate li neku preporuku?', 'Неділя підходить. Яка у вас фірмова страва? Що порадите?', 5);
  perform pg_temp.turn('25f7f2d3-04b9-5d5f-9e55-221ba0b22479', 'ffce2e6c-23d5-5ab6-9a44-2676da07b2a7', 'Konobar', 'Riba na žaru. Potvrdit ću vam rezervaciju porukom.', 'Риба на грилі. Я підтверджу вам бронювання повідомленням.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 20: Алергія і смаки — перебудова: 11 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '6af82dd3-beb1-54cf-9c1b-44ec3cb12a35';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Алергія і смаки» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'bad9e75a-bbc0-5395-ad63-635a51f36efc') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 20: Алергія і смаки', title_hr = 'Lekcija 20: Alergije i okusi',
         objectives = '["Попередити про алергію й непереносимість: alergična sam na…, ne podnosim…", "Запитати про склад страви", "Заперечення: Ne jedem meso. Ni sir ni jaja."]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Заперечення' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Заперечення»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'orah', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kikiriki', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gluten', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bez glutena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'laktoza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'netolerancija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vegan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ne podnosim', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sastav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bljutav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'začinjen', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '65bdd8a2-88b3-576b-adab-0fb39b144db6', 'fill_in_the_blank', 'Moj brat ___ jede meso, on je vegan.', 'ne', '["ne", "nije", "nema", "ni"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c21b8a8-c81c-5ddd-8a94-657fbe894e2a', 'multiple_choice', 'Що означає «bez glutena»?', 'без глютену', '["арахіс", "горіх", "без глютену", "глютен"]'::jsonb, 'A1', 2, 'PUBLISHED', 'bez glutena', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1f9de690-a947-5bae-92b9-71cebef680ff', 'multiple_choice', 'Що означає «ne podnosim»?', 'я не переношу, мені не підходить', '["лактоза", "я не переношу, мені не підходить", "веган", "прісний, несмачний (без смаку)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'ne podnosim', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7c380987-c414-5347-adef-ce397ce4cbc9', 'multiple_choice', 'Що означає «bljutav»?', 'прісний, несмачний (без смаку)', '["склад (продукту)", "приправлений, гострий (зі спеціями)", "веган", "прісний, несмачний (без смаку)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'bljutav', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bd2620ad-ae30-574f-a321-d10355bccfd7', 'multiple_choice', 'Як хорватською «веган»?', 'vegan', '["vegan", "bez glutena", "netolerancija", "orah"]'::jsonb, 'A1', 5, 'PUBLISHED', 'vegan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e92c456-c109-5963-a1a5-86289bb9636c', 'multiple_choice', 'Як хорватською «непереносимість (харчова)»?', 'netolerancija', '["netolerancija", "orah", "laktoza", "kikiriki"]'::jsonb, 'A1', 6, 'PUBLISHED', 'netolerancija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '839f2b7e-9136-5c0f-b05e-7f152f15679a', 'type_answer', 'Напишіть хорватською: «лактоза»', 'laktoza', null, 'A1', 7, 'PUBLISHED', 'laktoza', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e83cd933-2c86-568d-9f9b-74c3f3c89e50', 'type_answer', 'Напишіть хорватською: «склад (продукту)»', 'sastav', null, 'A1', 8, 'PUBLISHED', 'sastav', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b0c69b0f-ff1f-5e15-b982-dd7db3b55498', 'type_answer', 'Напишіть хорватською: «горіх»', 'orah', null, 'A1', 9, 'PUBLISHED', 'orah', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd814d0fa-44e3-56c2-82ff-b61620aa12a1', 'sentence_builder', 'Складіть: «У мене алергія на горіхи.»', 'Imam alergiju na orahe.', '["na", "alergiju", "Imam", "orahe."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0d5c6575-0c6d-5767-b194-32eec8cb9587', 'sentence_builder', 'Складіть: «Я не переношу лактозу.»', 'Ne podnosim laktozu.', '["laktozu.", "podnosim", "Ne"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a1787420-255b-50cb-9cda-3df24bac8c5e', 'listening', 'Прослухайте і складіть фразу', 'Onda ne mogu, alergična sam na kikiriki.', '["mogu,", "sam", "ne", "alergična", "Onda", "kikiriki.", "na"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bc743428-8c6a-5eb5-8ee2-8099f0b262d9', 'listening', 'Прослухайте і складіть фразу', 'Jedem, ali moj brat je vegan.', '["je", "vegan.", "moj", "brat", "Jedem,", "ali"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e9b2c2e9-e723-558c-a223-546c29c35699', 'speaking', 'У вас є хліб без глютену?', 'Imate li kruh bez glutena?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '85a1f6a8-8f56-5a0a-8644-1337df89fb45', 'speaking', 'Суп прісний.', 'Juha je bljutava.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('bad9e75a-bbc0-5395-ad63-635a51f36efc', v_lesson, 'У ресторані з алергією', 'Alergija u restoranu', 3201, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('2e27b344-85e0-5dae-a6ef-b5f8abe49950', 'bad9e75a-bbc0-5395-ad63-635a51f36efc', 'Daša', 'Oprostite, ima li u ovom kolaču oraha?', 'Перепрошую, у цьому тістечку є горіхи?', 1);
  perform pg_temp.turn('b2a8328e-569b-50dd-8f0f-933027dee851', 'bad9e75a-bbc0-5395-ad63-635a51f36efc', 'Ivan', 'Ima oraha i malo kikirikija.', 'Є волоські горіхи й трохи арахісу.', 2);
  perform pg_temp.turn('c7e763df-edfa-513f-bc9a-7f5ee174c6a9', 'bad9e75a-bbc0-5395-ad63-635a51f36efc', 'Daša', 'Onda ne mogu, alergična sam na kikiriki.', 'Тоді не можу, у мене алергія на арахіс.', 3);
  perform pg_temp.turn('0b2d0fa0-6b0d-5711-8cb1-a159f66b3c06', 'bad9e75a-bbc0-5395-ad63-635a51f36efc', 'Ivan', 'Imamo voćnu salatu, ona je bez oraha.', 'У нас є фруктовий салат, він без горіхів.', 4);
  perform pg_temp.turn('d5e6c470-a9da-57cd-9d6b-a78188af292d', 'bad9e75a-bbc0-5395-ad63-635a51f36efc', 'Daša', 'Super. A je li tjestenina bez glutena?', 'Чудово. А паста без глютену?', 5);
  perform pg_temp.turn('f995b4db-d235-546f-80e5-f84c89fe70b9', 'bad9e75a-bbc0-5395-ad63-635a51f36efc', 'Ivan', 'Imamo i tjesteninu bez glutena, samo recite.', 'У нас є й паста без глютену, тільки скажіть.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('93d1a380-9e48-5244-92c8-f564e9778c6c', v_lesson, 'Що ти не їси?', 'Što ne jedeš?', 3202, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('d40d154e-b55d-55b9-892b-c0577525ef91', '93d1a380-9e48-5244-92c8-f564e9778c6c', 'Mia', 'Darja, jedeš li meso?', 'Дар’є, ти їси м’ясо?', 1);
  perform pg_temp.turn('95d9830b-770f-5870-b079-6ef4ac0febe2', '93d1a380-9e48-5244-92c8-f564e9778c6c', 'Darja', 'Jedem, ali moj brat je vegan.', 'Їм, а от мій брат — веган.', 2);
  perform pg_temp.turn('ffd22bb5-10cb-5853-ac9b-e4c9b7bfc6c3', '93d1a380-9e48-5244-92c8-f564e9778c6c', 'Mia', 'A smije li jesti sir?', 'А сир йому можна?', 3);
  perform pg_temp.turn('a6cfcad6-fac9-5c14-a247-ae967c3dd4e6', '93d1a380-9e48-5244-92c8-f564e9778c6c', 'Darja', 'Ne, ni sir ni jaja. I ne podnosi začinjenu hranu.', 'Ні, ні сиру, ні яєць. І він погано переносить гостру їжу.', 4);
  perform pg_temp.turn('a8158c10-e4af-592b-a56e-d282dd84854c', '93d1a380-9e48-5244-92c8-f564e9778c6c', 'Mia', 'Dobro, kuham nešto blago. Nadam se da neće biti bljutavo.', 'Добре, приготую щось неперчене. Сподіваюся, не буде прісним.', 5);
  perform pg_temp.turn('332f70b3-5bae-5d05-b9d9-7792a5b54b7d', '93d1a380-9e48-5244-92c8-f564e9778c6c', 'Darja', 'Pročitaj sastav na pakiranju, tamo sve piše.', 'Прочитай склад на упаковці, там усе написано.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.2 · урок 21: Обід на роботі — перебудова: 13 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '2c192d05-f259-53b6-a6ec-55ebfb25ec01';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Обід на роботі» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'ab7fdff9-adaa-5825-8f27-701ab9b52810') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 21: Обід на роботі', title_hr = 'Lekcija 21: Gablec i marenda',
         objectives = '["Поговорити з колегами про обід: menza, dnevni meni, gablec", "Розігріти їжу й замовити доставку", "Питання: Što je danas u menzi? Koliko košta?"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Побудова питань' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Побудова питань»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'gablec', v_pos);
  v_pos := pg_temp.word(v_lesson, 'marenda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'menza', v_pos);
  v_pos := pg_temp.word(v_lesson, 'varivo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dnevni meni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pire', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mahune', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grašak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pohan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podgrijati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pauza za ručak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dostava hrane', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kutija za ručak', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f85efba7-e49f-5c40-8d04-afc9cb944007', 'fill_in_the_blank', '___ košta dnevni meni?', 'Koliko', '["Kada", "Koliko", "Tko", "Gdje"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b6d1b6fb-cccd-52dc-8047-0786a7363ee6', 'multiple_choice', 'Що означає «dnevni meni»?', 'денне меню', '["доставка їжі", "стручкова квасоля", "гарячий обід на роботі (загреб.)", "денне меню"]'::jsonb, 'A1', 2, 'PUBLISHED', 'dnevni meni', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b42f860d-98e7-548d-81f2-0ed9ad57ecc4', 'multiple_choice', 'Що означає «gablec»?', 'гарячий обід на роботі (загреб.)', '["їдальня", "підігріти", "денне меню", "гарячий обід на роботі (загреб.)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'gablec', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '95d75703-4e02-5e2c-ac3b-f34665b25611', 'multiple_choice', 'Що означає «marenda»?', 'перекус / пізній сніданок', '["перекус / пізній сніданок", "ланч-бокс, контейнер для обіду", "горошок", "доставка їжі"]'::jsonb, 'A1', 4, 'PUBLISHED', 'marenda', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b9658509-7363-5278-9039-c1e4a92735dd', 'multiple_choice', 'Що означає «grašak»?', 'горошок', '["доставка їжі", "перекус / пізній сніданок", "ланч-бокс, контейнер для обіду", "горошок"]'::jsonb, 'A1', 5, 'PUBLISHED', 'grašak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c8bfb3cc-5c2c-5115-8b61-79a3353de699', 'multiple_choice', 'Як хорватською «підігріти»?', 'podgrijati', '["kutija za ručak", "dostava hrane", "grašak", "podgrijati"]'::jsonb, 'A1', 6, 'PUBLISHED', 'podgrijati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '19f89f3f-e54e-5076-a53d-ef75b406cb88', 'multiple_choice', 'Як хорватською «їдальня»?', 'menza', '["kutija za ručak", "varivo", "menza", "pire"]'::jsonb, 'A1', 7, 'PUBLISHED', 'menza', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '494f1869-30fd-5f7c-8fbf-17e9ddad0a49', 'type_answer', 'Напишіть хорватською: «у паніровці»', 'pohan', null, 'A1', 8, 'PUBLISHED', 'pohan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7c83c494-ddf0-5063-90ad-fb0dfc17844f', 'type_answer', 'Напишіть хорватською: «пюре»', 'pire', null, 'A1', 9, 'PUBLISHED', 'pire', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd8d075d0-24d7-53c2-a033-60235e275fe4', 'sentence_builder', 'Складіть: «Де я можу розігріти обід?»', 'Gdje mogu podgrijati ručak?', '["Gdje", "ručak?", "mogu", "podgrijati"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '14b67d88-36ca-5924-9c3f-d0284fe446eb', 'sentence_builder', 'Складіть: «Що сьогодні в їдальні?»', 'Što je danas u menzi?', '["u", "Što", "je", "danas", "menzi?"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '01ea9f86-26dc-5b83-819b-a839d1af5a5c', 'listening', 'Прослухайте і складіть фразу', 'U podne. Što je danas u menzi?', '["menzi?", "podne.", "Što", "danas", "u", "je", "U"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e08e48a5-1136-54c7-b325-75b619265157', 'listening', 'Прослухайте і складіть фразу', 'Gdje ga možeš podgrijati?', '["možeš", "podgrijati?", "ga", "Gdje"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7fc890b1-aa4a-517a-aa7d-5ab0ca1b8c8b', 'speaking', 'Коли в тебе обідня перерва?', 'Kada ti je pauza za ručak?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7f4bbb99-a531-5ff9-aa78-6fdb7f4a74b8', 'speaking', 'Замовимо доставку їжі?', 'Hoćemo li naručiti dostavu hrane?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ab7fdff9-adaa-5825-8f27-701ab9b52810', v_lesson, 'У їдальні', 'U menzi', 3211, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('bc16874e-b06c-594a-bde9-abf0496347ef', 'ab7fdff9-adaa-5825-8f27-701ab9b52810', 'Ivana', 'Dašo, kada ti je pauza za ručak?', 'Дашо, коли в тебе обідня перерва?', 1);
  perform pg_temp.turn('e0d70d10-d256-5f7d-99c3-810eee17923e', 'ab7fdff9-adaa-5825-8f27-701ab9b52810', 'Daša', 'U podne. Što je danas u menzi?', 'Опівдні. Що сьогодні в їдальні?', 2);
  perform pg_temp.turn('e4c6eac8-7f31-51d0-85f0-9eb08f892b99', 'ab7fdff9-adaa-5825-8f27-701ab9b52810', 'Ivana', 'Dnevni meni je varivo od mahuna ili pohana piletina s pireom.', 'Денне меню — рагу зі стручкової квасолі або курка в паніровці з пюре.', 3);
  perform pg_temp.turn('e77d1178-e2d3-551c-b6ce-af20a741b14b', 'ab7fdff9-adaa-5825-8f27-701ab9b52810', 'Daša', 'Koliko košta gablec?', 'Скільки коштує обід?', 4);
  perform pg_temp.turn('89ce3525-da42-5244-8006-a52884fae00e', 'ab7fdff9-adaa-5825-8f27-701ab9b52810', 'Ivana', 'Šest eura, a juha je besplatna.', 'Шість євро, а суп безкоштовно.', 5);
  perform pg_temp.turn('1c51616d-3e24-56de-aa75-3f787dbb8e9f', 'ab7fdff9-adaa-5825-8f27-701ab9b52810', 'Daša', 'Super, onda idemo zajedno.', 'Чудово, тоді підемо разом.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b8cda3c9-9c11-537e-b0ab-658577e32b76', v_lesson, 'Обід із собою', 'Ručak od kuće', 3212, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('18d90a19-d686-5633-b8a9-d34c61103d57', 'b8cda3c9-9c11-537e-b0ab-658577e32b76', 'Tomislav', 'Darja, ideš li s nama na marendu?', 'Дар’є, підеш з нами на перекус?', 1);
  perform pg_temp.turn('8ad0b247-f2ef-5136-b18b-ce8f8194f9ce', 'b8cda3c9-9c11-537e-b0ab-658577e32b76', 'Darja', 'Ne danas, ponijela sam ručak u kutiji.', 'Не сьогодні, я взяла обід із собою в ланч-боксі.', 2);
  perform pg_temp.turn('d6e05023-7224-523f-aaf8-eda5fa0e0ed5', 'b8cda3c9-9c11-537e-b0ab-658577e32b76', 'Tomislav', 'Gdje ga možeš podgrijati?', 'Де ти можеш його розігріти?', 3);
  perform pg_temp.turn('7951bd88-31a0-5ef4-87c9-8e5adf7d9a78', 'b8cda3c9-9c11-537e-b0ab-658577e32b76', 'Darja', 'U kuhinji imamo mikrovalnu.', 'На кухні в нас є мікрохвильовка.', 4);
  perform pg_temp.turn('3fc50667-d473-596d-b341-2a231b5fb6c2', 'b8cda3c9-9c11-537e-b0ab-658577e32b76', 'Tomislav', 'Mi u petak naručujemo dostavu hrane. Hoćeš li i ti?', 'Ми в п’ятницю замовляємо доставку їжі. Будеш і ти?', 5);
  perform pg_temp.turn('8f7b534d-4421-54e9-b219-7972c15278f9', 'b8cda3c9-9c11-537e-b0ab-658577e32b76', 'Darja', 'Hoću! Ali bez graška, molim.', 'Буду! Але без горошку, будь ласка.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- 3. Нові уроки модуля A1.2
-- A1.2 · урок 16: Посуд і сервірування — новий урок: 17 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := '54c21ee3-db66-5d1e-9eca-7223a2e6f6e4';
  v_lesson constant uuid := '213ab10f-63a4-5e1c-8b2e-156c433de874';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A1.2: місце 6 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 16: Посуд і сервірування', 'Lekcija 16: Posuđe i postavljanje stola', '["Назвати посуд і прибори: duboki tanjur, zdjela, žličica, vrč", "Накрити на стіл і прибрати після їжі", "Наказовий спосіб: Postavi stol! Donesi pladanj!"]'::jsonb, 15, 'PUBLISHED', 6);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Наказовий спосіб' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Наказовий спосіб»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'posuđe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tanjurić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'duboki tanjur', v_pos);
  v_pos := pg_temp.word(v_lesson, 'plitki tanjur', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zdjela', v_pos);
  v_pos := pg_temp.word(v_lesson, 'žličica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čaša za vino', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pribor za jelo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'salveta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stolnjak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pladanj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrč', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otvarač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kuhača', v_pos);
  v_pos := pg_temp.word(v_lesson, 'daska za rezanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'postaviti stol', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pospremiti stol', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '4e221580-7c13-5629-8d36-73c5b2c135b1', 'fill_in_the_blank', 'Filipe, ___ stol, gosti dolaze!', 'postavi', '["postavim", "postaviti", "postavi", "postavlja"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6633c262-eb8d-5ec0-947a-39d2c92724ab', 'multiple_choice', 'Що означає «pospremiti stol»?', 'прибрати зі столу', '["відкривачка", "прибрати зі столу", "накрити на стіл", "глибока тарілка"]'::jsonb, 'A1', 2, 'PUBLISHED', 'pospremiti stol', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8b6d51bc-9e16-511b-af7a-8fb2d3564d50', 'multiple_choice', 'Що означає «čaša za vino»?', 'келих для вина', '["келих для вина", "скатертина", "столові прибори", "блюдце"]'::jsonb, 'A1', 3, 'PUBLISHED', 'čaša za vino', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a45ec3eb-1b89-521d-84de-54ced5a3cfe7', 'multiple_choice', 'Що означає «kuhača»?', 'кухонна ложка, лопатка', '["чайна ложечка", "прибрати зі столу", "кухонна ложка, лопатка", "таця"]'::jsonb, 'A1', 4, 'PUBLISHED', 'kuhača', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e5aa3009-b581-517d-936f-7aed487a976f', 'multiple_choice', 'Як хорватською «блюдце»?', 'tanjurić', '["daska za rezanje", "salveta", "tanjurić", "zdjela"]'::jsonb, 'A1', 5, 'PUBLISHED', 'tanjurić', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d9c9c7b-37b7-5c1b-9fa2-cf8681b09889', 'multiple_choice', 'Як хорватською «відкривачка»?', 'otvarač', '["žličica", "otvarač", "stolnjak", "pladanj"]'::jsonb, 'A1', 6, 'PUBLISHED', 'otvarač', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b18345b7-f7c5-582b-a03b-36260bbc34fc', 'type_answer', 'Напишіть хорватською: «глечик»', 'vrč', null, 'A1', 7, 'PUBLISHED', 'vrč', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd285fe2-aa6f-56c0-ae19-83fa1219e58d', 'type_answer', 'Напишіть хорватською: «серветка»', 'salveta', null, 'A1', 8, 'PUBLISHED', 'salveta', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8b68fa54-ffff-5ed4-91d5-d3f110802ced', 'type_answer', 'Напишіть хорватською: «чайна ложечка»', 'žličica', null, 'A1', 9, 'PUBLISHED', 'žličica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ed6651d8-273c-5ce2-8868-7a786a9abde6', 'sentence_builder', 'Складіть: «Принеси тацю з кухні.»', 'Donesi pladanj iz kuhinje.', '["iz", "Donesi", "pladanj", "kuhinje."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3a9e2456-05cf-5a57-8568-4718bed47389', 'sentence_builder', 'Складіть: «Де відкривачка для пляшок?»', 'Gdje je otvarač za boce?', '["boce?", "Gdje", "za", "otvarač", "je"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9ba0751e-bad7-5783-8cc3-3423ea7f8cca', 'listening', 'Прослухайте і складіть фразу', 'Gdje je pribor za jelo?', '["jelo?", "je", "pribor", "Gdje", "za"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e2126d99-2d20-54bf-9e0a-1fbb2514e0ae', 'listening', 'Прослухайте і складіть фразу', 'Hvala. Donesi pladanj iz kuhinje.', '["Donesi", "kuhinje.", "pladanj", "iz", "Hvala."]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '54197d4d-223b-54a8-8311-1a94014416c3', 'speaking', 'Накрий на стіл, будь ласка.', 'Postavi stol, molim te.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2ceda42f-1314-5315-81fb-37f50194ccd4', 'speaking', 'Дай мені чайну ложечку.', 'Daj mi žličicu.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1293b739-ac3e-5558-82fa-d58abb510f0f', v_lesson, 'Накриваємо на стіл', 'Postavljamo stol', 3161, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('8741b2db-9628-562c-94cf-16954759cc6d', '1293b739-ac3e-5558-82fa-d58abb510f0f', 'Daša', 'Filipe, gosti dolaze za pola sata. Postavi stol, molim te.', 'Філіпе, гості прийдуть через пів години. Накрий на стіл, будь ласка.', 1);
  perform pg_temp.turn('4c342184-ef3a-54b0-8ed2-39569b2e7c4e', '1293b739-ac3e-5558-82fa-d58abb510f0f', 'Filip', 'Koliko tanjura trebam?', 'Скільки тарілок потрібно?', 2);
  perform pg_temp.turn('01b554bc-5776-5c75-8602-07ab682d674f', '1293b739-ac3e-5558-82fa-d58abb510f0f', 'Daša', 'Šest dubokih tanjura za juhu i šest plitkih za glavno jelo.', 'Шість глибоких тарілок для супу й шість мілких для другої страви.', 3);
  perform pg_temp.turn('91b2b87b-accf-51de-99e3-f92fb70e9f79', '1293b739-ac3e-5558-82fa-d58abb510f0f', 'Filip', 'Gdje je pribor za jelo?', 'Де столові прибори?', 4);
  perform pg_temp.turn('2acd95ec-8b80-5a6d-9269-00898bbc1a50', '1293b739-ac3e-5558-82fa-d58abb510f0f', 'Daša', 'U ladici. Stavi i salvete pored tanjura.', 'У шухляді. Поклади ще серветки біля тарілок.', 5);
  perform pg_temp.turn('52972005-8555-5163-b541-1f75e14deb69', '1293b739-ac3e-5558-82fa-d58abb510f0f', 'Filip', 'A koji stolnjak, bijeli ili plavi?', 'А яку скатертину, білу чи синю?', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('585fc628-6229-5eba-9a81-dfda96586ad9', v_lesson, 'Після вечері', 'Nakon večere', 3162, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('2318c63b-03fa-5684-ba7f-9b28701cc836', '585fc628-6229-5eba-9a81-dfda96586ad9', 'Luka', 'Večera je bila odlična! Pomoći ću ti pospremiti stol.', 'Вечеря була чудова! Я допоможу тобі прибрати зі столу.', 1);
  perform pg_temp.turn('3fa7a35c-17b6-5f42-8f0f-8b30a2144c87', '585fc628-6229-5eba-9a81-dfda96586ad9', 'Darja', 'Hvala. Donesi pladanj iz kuhinje.', 'Дякую. Принеси тацю з кухні.', 2);
  perform pg_temp.turn('ca8959dd-c0cf-505a-82cf-791ee1d225aa', '585fc628-6229-5eba-9a81-dfda96586ad9', 'Luka', 'Gdje da stavim čaše za vino?', 'Куди поставити келихи для вина?', 3);
  perform pg_temp.turn('3ab57d3e-0b0b-506b-9079-dc7cd27f440d', '585fc628-6229-5eba-9a81-dfda96586ad9', 'Darja', 'U ormar, ali prvo ih operi rukom.', 'У шафу, але спершу помий їх руками.', 4);
  perform pg_temp.turn('1d9bceb2-037e-59cf-b71e-52525ab81ba8', '585fc628-6229-5eba-9a81-dfda96586ad9', 'Luka', 'A ostatak salate iz zdjele?', 'А залишки салату з миски?', 5);
  perform pg_temp.turn('02011473-7997-5ccd-8b9f-f06086b6a99c', '585fc628-6229-5eba-9a81-dfda96586ad9', 'Darja', 'Stavi ga u hladnjak, sutra ćemo ga pojesti.', 'Поклади в холодильник, завтра доїмо.', 6);
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
   where l.id in ('bb7bc159-cb40-5a8a-91b7-c6da05c6342a', '0c19643d-57ff-5030-820f-ba330833ea88', '46a89cf5-41e0-50a2-99b1-f4e66a5ff146', 'ae33e31a-f937-5305-908e-3d957df15f6a', '1e8c2d0e-28f6-5873-aa9f-5d0ad2567fb8', '213ab10f-63a4-5e1c-8b2e-156c433de874', '3e652232-866b-5edf-ac05-d61ee7a325fe', '17fcd38a-e295-5849-9ba3-1ef240c6be78', '5e4a1c56-3931-58bb-81af-cb598966da77', '6af82dd3-beb1-54cf-9c1b-44ec3cb12a35', '2c192d05-f259-53b6-a6ec-55ebfb25ec01')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 10 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_order from (values ('bb7bc159-cb40-5a8a-91b7-c6da05c6342a'::uuid, 1), ('0c19643d-57ff-5030-820f-ba330833ea88'::uuid, 2), ('46a89cf5-41e0-50a2-99b1-f4e66a5ff146'::uuid, 3), ('ae33e31a-f937-5305-908e-3d957df15f6a'::uuid, 4), ('1e8c2d0e-28f6-5873-aa9f-5d0ad2567fb8'::uuid, 5), ('213ab10f-63a4-5e1c-8b2e-156c433de874'::uuid, 6), ('3e652232-866b-5edf-ac05-d61ee7a325fe'::uuid, 7), ('17fcd38a-e295-5849-9ba3-1ef240c6be78'::uuid, 8), ('5e4a1c56-3931-58bb-81af-cb598966da77'::uuid, 9), ('6af82dd3-beb1-54cf-9c1b-44ec3cb12a35'::uuid, 10), ('2c192d05-f259-53b6-a6ec-55ebfb25ec01'::uuid, 11)) as t(id, o)
    join public.lessons l on l.id = t.id and l.order_index = t.o and l.unit_id = '54c21ee3-db66-5d1e-9eca-7223a2e6f6e4';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A1' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('bb7bc159-cb40-5a8a-91b7-c6da05c6342a', '0c19643d-57ff-5030-820f-ba330833ea88', '46a89cf5-41e0-50a2-99b1-f4e66a5ff146', 'ae33e31a-f937-5305-908e-3d957df15f6a', '1e8c2d0e-28f6-5873-aa9f-5d0ad2567fb8', '213ab10f-63a4-5e1c-8b2e-156c433de874', '3e652232-866b-5edf-ac05-d61ee7a325fe', '17fcd38a-e295-5849-9ba3-1ef240c6be78', '5e4a1c56-3931-58bb-81af-cb598966da77', '6af82dd3-beb1-54cf-9c1b-44ec3cb12a35', '2c192d05-f259-53b6-a6ec-55ebfb25ec01') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A1.2: % уроків з неправильним складом', v_bad; end if;
  if v_order <> 11 then raise exception 'Модуль A1.2: на своїх місцях % уроків з 11', v_order; end if;
  if v_titles > 0 then raise exception 'A1: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A1.2: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A1.2 — 11 уроків за темою (10 перебудовано, 1 нових)';
end $$;

commit;
