-- =====================================================================
-- Програма A1 v3 · модуль A1.12 «Діти, навчання й документи» · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_curriculum_a1_v3.py 12 (не редагуйте вручну).
--
-- Рішення власника 2026-10-21 / 2026-10-26: до 25 слів на урок — скільки потрібно темі, 90–95 % слів — нові для рівня,
-- діалоги під тему, частіше Даша / Дар’я; бета (PUBLISHED).
--   * Уроки 98–105: 6 наявних перебудовано, 2 нових. Слів у них: 132.
--     Кожен: 10–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 60.
--   * Нові правила до тем: «Родовий відмінок: основи» (+1), «Присвійні займенники» (+1).
--   * Виправлено: ispit — «іспит, екзамен»; uplata — «платіж; надходження (на рахунок)»; isplata — «виплата; зняття (готівки)»; uvjerenje — «свідоцтво (про закінчення курсу); довідка»; dozvola — «дозвіл; посвідка»; obavijest — «повідомлення (зокрема — поштове про відправлення)»; sklonište — «сховище, укриття» (стара версія — у content_versions).
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

-- 1. Нові слова й вирази A1.12 (60; наявні не змінюються)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('upis', 'upis', 'hr', 'noun', 'A1', 'зарахування', 'core', '{"gender": "m"}'::jsonb, '["Upis u vrtić je u svibnju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('liječnička potvrda', 'lijecnicka potvrda', 'hr', 'phrase', 'A1', 'медична довідка', 'collocation', '{"gender": "f"}'::jsonb, '["Za upis trebate liječničku potvrdu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prilagodba', 'prilagodba', 'hr', 'noun', 'A1', 'адаптація', 'core', '{"gender": "f"}'::jsonb, '["Prilagodba u vrtiću traje oko dva tjedna."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('popodnevni odmor', 'popodnevni odmor', 'hr', 'phrase', 'A1', 'денний сон (у садку), післяобідній відпочинок', 'collocation', '{"gender": "m"}'::jsonb, '["Poslije ručka djeca imaju popodnevni odmor."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rezervna odjeća', 'rezervna odjeca', 'hr', 'phrase', 'A1', 'запасний одяг', 'collocation', '{"gender": "f"}'::jsonb, '["U ormariću uvijek ostavite rezervnu odjeću."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dovesti', 'dovesti', 'hr', 'verb', 'A1', 'привести', 'core', '{"aspect": "pfv"}'::jsonb, '["Sutra ću dovesti djecu malo ranije."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pokupiti', 'pokupiti', 'hr', 'verb', 'A1', 'забрати (дитину, речі)', 'core', '{"aspect": "pfv"}'::jsonb, '["Tko danas može pokupiti Filipa iz vrtića?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('lista čekanja', 'lista cekanja', 'hr', 'phrase', 'A1', 'список очікування', 'collocation', '{"gender": "f"}'::jsonb, '["Naš sin je treći na listi čekanja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('upisnina', 'upisnina', 'hr', 'noun', 'A1', 'вступний внесок (плата за запис)', 'core', '{"gender": "f"}'::jsonb, '["U privatnom vrtiću upisnina je pedeset eura."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gimnazija', 'gimnazija', 'hr', 'noun', 'A1', 'гімназія (загальноосвітня середня школа)', 'core', '{"gender": "f"}'::jsonb, '["Poslije osnovne škole želi upisati gimnaziju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nastavnik', 'nastavnik', 'hr', 'noun', 'A1', 'учитель (у старших класах), викладач', 'core', '{"gender": "m"}'::jsonb, '["Naš nastavnik matematike je jako strog."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('razrednica', 'razrednica', 'hr', 'noun', 'A1', 'класна керівниця', 'core', '{"gender": "f"}'::jsonb, '["Razrednica nas je pozvala na razgovor."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('raspored sati', 'raspored sati', 'hr', 'phrase', 'A1', 'розклад уроків', 'collocation', '{"gender": "m"}'::jsonb, '["Raspored sati je na stranici škole."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('školski sat', 'skolski sat', 'hr', 'phrase', 'A1', 'урок (45 хвилин)', 'collocation', '{"gender": "m"}'::jsonb, '["Školski sat traje četrdeset pet minuta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('veliki odmor', 'veliki odmor', 'hr', 'phrase', 'A1', 'велика перерва (у школі)', 'collocation', '{"gender": "m"}'::jsonb, '["Za veliki odmor djeca jedu užinu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('hrvatski jezik', 'hrvatski jezik', 'hr', 'phrase', 'A1', 'хорватська мова (предмет)', 'collocation', '{"gender": "m"}'::jsonb, '["Iz hrvatskog jezika ima četvorku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tjelesni odgoj', 'tjelesni odgoj', 'hr', 'phrase', 'A1', 'фізкультура', 'collocation', '{"gender": "m"}'::jsonb, '["Za tjelesni odgoj trebaju tenisice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jutarnja smjena', 'jutarnja smjena', 'hr', 'phrase', 'A1', 'ранкова зміна (у школі)', 'collocation', '{"gender": "f"}'::jsonb, '["U jutarnjoj smjeni nastava počinje u osam."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('popodnevna smjena', 'popodnevna smjena', 'hr', 'phrase', 'A1', 'післяобідня зміна (у школі)', 'collocation', '{"gender": "f"}'::jsonb, '["Sljedeći tjedan smo u popodnevnoj smjeni."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('školska torba', 'skolska torba', 'hr', 'phrase', 'A1', 'шкільний рюкзак, портфель', 'collocation', '{"gender": "f"}'::jsonb, '["Školska torba je preteška za prvašića."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pernica', 'pernica', 'hr', 'noun', 'A1', 'пенал', 'core', '{"gender": "f"}'::jsonb, '["U pernici su olovke i gumica."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gumica', 'gumica', 'hr', 'noun', 'A1', 'гумка (для стирання)', 'core', '{"gender": "f"}'::jsonb, '["Možeš li mi posuditi gumicu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('šiljilo', 'siljilo', 'hr', 'noun', 'A1', 'чинка (точилка)', 'core', '{"gender": "n"}'::jsonb, '["Olovka je tupa, gdje je šiljilo?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ravnalo', 'ravnalo', 'hr', 'noun', 'A1', 'лінійка', 'core', '{"gender": "n"}'::jsonb, '["Nacrtaj crtu ravnalom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('udžbenik', 'udzbenik', 'hr', 'noun', 'A1', 'підручник', 'core', '{"gender": "m"}'::jsonb, '["Otvorite udžbenik na dvadesetoj stranici."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('radna bilježnica', 'radna biljeznica', 'hr', 'phrase', 'A1', 'робочий зошит', 'collocation', '{"gender": "f"}'::jsonb, '["Zadaća je u radnoj bilježnici."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bojice', 'bojice', 'hr', 'noun', 'A1', 'кольорові олівці', 'core', '{"gender": "f", "number": "pl"}'::jsonb, '["Za likovni treba kutija bojica."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('flomasteri', 'flomasteri', 'hr', 'noun', 'A1', 'фломастери', 'core', '{"gender": "m", "number": "pl"}'::jsonb, '["Djeca crtaju flomasterima."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('škare', 'skare', 'hr', 'noun', 'A1', 'ножиці', 'core', '{"gender": "f", "number": "pl"}'::jsonb, '["Za prvi razred kupite škare s oblim vrhom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('šestar', 'sestar', 'hr', 'noun', 'A1', 'циркуль', 'core', '{"gender": "m"}'::jsonb, '["Krug crtamo šestarom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('vodene boje', 'vodene boje', 'hr', 'phrase', 'A1', 'акварельні фарби', 'collocation', '{"gender": "f", "number": "pl"}'::jsonb, '["Danas na likovnom slikamo vodenim bojama."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tempere', 'tempere', 'hr', 'noun', 'A1', 'темпера (фарби)', 'core', '{"gender": "f", "number": "pl"}'::jsonb, '["Tempere su gušće od vodenih boja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kolaž papir', 'kolaz papir', 'hr', 'phrase', 'A1', 'кольоровий папір (для аплікацій)', 'collocation', '{"gender": "m"}'::jsonb, '["Od kolaž papira radimo čestitke."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('omot za knjige', 'omot za knjige', 'hr', 'phrase', 'A1', 'обкладинка для книжок', 'collocation', '{"gender": "m"}'::jsonb, '["Svaki udžbenik treba imati omot za knjige."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kutija za užinu', 'kutija za uzinu', 'hr', 'phrase', 'A1', 'ланч-бокс', 'collocation', '{"gender": "f"}'::jsonb, '["Ne zaboravi kutiju za užinu!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('popis pribora', 'popis pribora', 'hr', 'phrase', 'A1', 'список приладдя', 'collocation', '{"gender": "m"}'::jsonb, '["Učiteljica nam je poslala popis pribora."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('trokut', 'trokut', 'hr', 'noun', 'A1', 'косинець; трикутник', 'core', '{"gender": "m"}'::jsonb, '["Za geometriju trebaš trokut i šestar."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('položiti', 'poloziti', 'hr', 'verb', 'A1', 'скласти (іспит успішно)', 'core', '{"aspect": "pfv"}'::jsonb, '["Položila sam ispit iz hrvatskog!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('polaznik', 'polaznik', 'hr', 'noun', 'A1', 'слухач (курсу)', 'core', '{"gender": "m"}'::jsonb, '["Na tečaju je dvanaest polaznika."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('početnik', 'pocetnik', 'hr', 'noun', 'A1', 'початківець', 'core', '{"gender": "m"}'::jsonb, '["Ovaj tečaj je za početnike."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('napredni', 'napredni', 'hr', 'adjective', 'A1', 'просунутий (рівень)', 'core', '{}'::jsonb, '["Sljedeće godine idem na napredni tečaj."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('intenzivni tečaj', 'intenzivni tecaj', 'hr', 'phrase', 'A1', 'інтенсивний курс', 'collocation', '{"gender": "m"}'::jsonb, '["Intenzivni tečaj traje mjesec dana."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('povratnica', 'povratnica', 'hr', 'noun', 'A1', 'повідомлення про вручення', 'core', '{"gender": "f"}'::jsonb, '["Pošaljite pismo preporučeno, s povratnicom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('omotnica', 'omotnica', 'hr', 'noun', 'A1', 'конверт', 'core', '{"gender": "f"}'::jsonb, '["Na omotnicu napišite adresu primatelja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('brza pošta', 'brza posta', 'hr', 'phrase', 'A1', 'експрес-пошта', 'collocation', '{"gender": "f"}'::jsonb, '["Brzom poštom stiže sutra."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('stanje računa', 'stanje racuna', 'hr', 'phrase', 'A1', 'залишок на рахунку', 'collocation', '{"gender": "n"}'::jsonb, '["Stanje računa vidim u aplikaciji."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ubaciti karticu', 'ubaciti karticu', 'hr', 'phrase', 'A1', 'вставити картку', 'chunk', '{"aspect": "pfv"}'::jsonb, '["Ubacite karticu i unesite PIN."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('unijeti PIN', 'unijeti pin', 'hr', 'phrase', 'A1', 'ввести PIN-код', 'chunk', '{"aspect": "pfv"}'::jsonb, '["Tri puta sam krivo unijela PIN."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('otvoriti račun', 'otvoriti racun', 'hr', 'phrase', 'A1', 'відкрити рахунок', 'chunk', '{"aspect": "pfv"}'::jsonb, '["Želim otvoriti račun u ovoj banci."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('debitna kartica', 'debitna kartica', 'hr', 'phrase', 'A1', 'дебетова картка', 'collocation', '{"gender": "f"}'::jsonb, '["Debitnom karticom plaćam u trgovini."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('izvod', 'izvod', 'hr', 'noun', 'A1', 'виписка', 'core', '{"gender": "m"}'::jsonb, '["Izvod s računa stiže e-poštom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('štedni račun', 'stedni racun', 'hr', 'phrase', 'A1', 'ощадний вклад', 'collocation', '{"gender": "m"}'::jsonb, '["Svaki mjesec stavim nešto na štedni račun."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kamatna stopa', 'kamatna stopa', 'hr', 'phrase', 'A1', 'процентна ставка', 'collocation', '{"gender": "f"}'::jsonb, '["Kamatna stopa na štednju je niska."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dopušteno prekoračenje', 'dopusteno prekoracenje', 'hr', 'phrase', 'A1', 'дозволений овердрафт', 'collocation', '{"gender": "n"}'::jsonb, '["Imam dopušteno prekoračenje do petsto eura."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ovjereni prijevod', 'ovjereni prijevod', 'hr', 'phrase', 'A1', 'засвідчений переклад', 'collocation', '{"gender": "m"}'::jsonb, '["Za rodni list treba ovjereni prijevod."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dokaz o sredstvima', 'dokaz o sredstvima', 'hr', 'phrase', 'A1', 'підтвердження коштів (на утримання)', 'collocation', '{"gender": "m"}'::jsonb, '["Kao dokaz o sredstvima donesite izvod s računa."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dokaz o smještaju', 'dokaz o smjestaju', 'hr', 'phrase', 'A1', 'підтвердження житла', 'collocation', '{"gender": "m"}'::jsonb, '["Ugovor o najmu je dokaz o smještaju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('dopuna', 'dopuna', 'hr', 'noun', 'A1', 'доповнення (документів)', 'core', '{"gender": "f"}'::jsonb, '["Dobila sam poziv za dopunu dokumentacije."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('aparat za gašenje', 'aparat za gasenje', 'hr', 'phrase', 'A1', 'вогнегасник', 'collocation', '{"gender": "m"}'::jsonb, '["Aparat za gašenje je pored vrata."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gasiti', 'gasiti', 'hr', 'verb', 'A1', 'гасити (вогонь)', 'core', '{"aspect": "ipfv"}'::jsonb, '["Vatrogasci satima gase požar."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;

-- 1б. Виправлені слова (7); повторний запуск нічого не змінює
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'ispit' and ukrainian_translation = 'іспит / екзамен' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'іспит, екзамен' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'uplata' and ukrainian_translation = 'платіж / внесення' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'платіж; надходження (на рахунок)' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'isplata' and ukrainian_translation = 'виплата / зняття' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'виплата; зняття (готівки)' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'uvjerenje' and ukrainian_translation = 'свідоцтво / довідка' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'свідоцтво (про закінчення курсу); довідка' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'dozvola' and ukrainian_translation = 'дозвіл / ліцензія' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'дозвіл; посвідка' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'obavijest' and ukrainian_translation = 'повідомлення' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'повідомлення (зокрема — поштове про відправлення)' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'sklonište' and ukrainian_translation = 'сховище / укриття' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'сховище, укриття' where id = r.id;
  end loop;
end $$;

-- 1а. Граматика A1.12: нові теми (0) і нові правила до наявних тем (2)
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Родовий відмінок: основи' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Родовий відмінок: основи»'; end if;
  if exists (select 1 from public.grammar_rules where id = '102592a4-30de-510d-8674-2b7d50e57bb8') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('102592a4-30de-510d-8674-2b7d50e57bb8', v_topic, 'Родовий часу: prije, poslije, od … do, tijekom', 'Час теж часто з родовим: prije + родовий (prije ispita), poslije / nakon + родовий (poslije škole), od … do + родовий (od rujna do lipnja), tijekom + родовий (tijekom ljeta), najkasnije do + родовий (do kraja mjeseca).', 'prije ispita · poslije škole · od rujna do lipnja · tijekom ljeta', '[{"hr": "Prije ispita učim svaki dan.", "ua": "Перед іспитом я вчуся щодня."}, {"hr": "Poslije škole Filip ide na trening.", "ua": "Після школи Філіп іде на тренування."}, {"hr": "Nastava traje od rujna do lipnja.", "ua": "Навчання триває з вересня до червня."}, {"hr": "Tijekom ljeta vrtić radi skraćeno.", "ua": "Улітку садок працює за скороченим графіком."}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', '102592a4-30de-510d-8674-2b7d50e57bb8', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Присвійні займенники' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Присвійні займенники»'; end if;
  if exists (select 1 from public.grammar_rules where id = 'a5df69e0-3a82-50ab-9078-17e339aa4852') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('a5df69e0-3a82-50ab-9078-17e339aa4852', v_topic, 'Svoj: svoju torbu, svoga sina', 'Svoj (свій) — коли власник той самий, що й підмет речення, для всіх осіб: Ja nosim svoju torbu. Ona piše svoju zadaću. Njegov / njezin — коли власник інша особа: Ivan voli svoju sestru (свою) і Ana voli njegovu sestru (його).', 'ja – svoj · ti – svoj · on / ona – svoj · mi – svoj · oni – svoj', '[{"hr": "Filip uvijek nosi svoju pernicu.", "ua": "Філіп завжди носить свій пенал."}, {"hr": "Upisala sam svoju kćer u vrtić.", "ua": "Я записала свою доньку в садок."}, {"hr": "Djeca čuvaju svoje udžbenike.", "ua": "Діти бережуть свої підручники."}, {"hr": "Daša je došla sa svojim sinom.", "ua": "Даша прийшла зі своїм сином."}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', 'a5df69e0-3a82-50ab-9078-17e339aa4852', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;

-- 2. Перебудова наявних уроків модуля A1.12
-- A1.12 · урок 98: Дитячий садок — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '42c31cfb-8680-5450-8453-245f3abd475a';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Дитячий садок» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '318f4882-434f-5fb2-97f2-282591c02775') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 98: Дитячий садок', title_hr = 'Lekcija 98: Vrtić',
         objectives = '["Записати дитину в садок: upis, rodni list, lista čekanja", "Домовитися з вихователькою про адаптацію й розклад дня", "Модальні дієслова: moram donijeti, mogu li pokupiti"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Модальні дієслова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Модальні дієслова»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'vrtić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odgojiteljica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rodni list', v_pos);
  v_pos := pg_temp.word(v_lesson, 'liječnička potvrda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ravnateljica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'skupina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prilagodba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'popodnevni odmor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rezervna odjeća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dovesti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pokupiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lista čekanja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upisnina', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '2809f1e8-0627-57d6-a1dc-7b1ef7a35228', 'fill_in_the_blank', 'Moram ___ sina iz vrtića u četiri.', 'pokupiti', '["pokupim", "pokupio", "pokupila", "pokupiti"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '21ddb3f6-3406-5a0c-b926-72a14a77c55d', 'multiple_choice', 'Що означає «vrtić»?', 'дитячий садок', '["свідоцтво про народження", "адаптація", "дитячий садок", "список очікування"]'::jsonb, 'A1', 2, 'PUBLISHED', 'vrtić', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ab3d8080-b1cc-5360-98e7-bd844f632c33', 'multiple_choice', 'Що означає «upisnina»?', 'вступний внесок (плата за запис)', '["директорка (школи, садка)", "денний сон (у садку), післяобідній відпочинок", "вступний внесок (плата за запис)", "вихователька (у дитсадку)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'upisnina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd612bbba-c136-566e-8473-a6803e921f61', 'multiple_choice', 'Що означає «skupina»?', 'група', '["група", "адаптація", "дитячий садок", "список очікування"]'::jsonb, 'A1', 4, 'PUBLISHED', 'skupina', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '70eb7570-a3a9-5de5-9e0c-43f2b364acb8', 'multiple_choice', 'Як хорватською «директорка (школи, садка)»?', 'ravnateljica', '["rezervna odjeća", "prilagodba", "pokupiti", "ravnateljica"]'::jsonb, 'A1', 5, 'PUBLISHED', 'ravnateljica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cac8109f-1ce3-51a1-a374-e593545ff502', 'multiple_choice', 'Як хорватською «адаптація»?', 'prilagodba', '["prilagodba", "pokupiti", "upisnina", "odgojiteljica"]'::jsonb, 'A1', 6, 'PUBLISHED', 'prilagodba', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0d2622d6-0cec-5bdd-8bdb-de9afd3ffde1', 'type_answer', 'Напишіть хорватською: «зарахування»', 'upis', null, 'A1', 7, 'PUBLISHED', 'upis', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2c7e9c21-41ae-5a3a-ba49-77ff8a16152a', 'type_answer', 'Напишіть хорватською: «вихователька (у дитсадку)»', 'odgojiteljica', null, 'A1', 8, 'PUBLISHED', 'odgojiteljica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9d4d4608-3b3f-5b0b-88b6-cd5aa096a883', 'type_answer', 'Напишіть хорватською: «привести»', 'dovesti', null, 'A1', 9, 'PUBLISHED', 'dovesti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4a14550d-1383-532c-9b36-ce57f13c4cfa', 'sentence_builder', 'Складіть: «Я хочу записати доньку в садок.»', 'Želim upisati kćer u vrtić.', '["upisati", "vrtić.", "kćer", "u", "Želim"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '03e4908f-ab23-5ccf-928d-dc8c8999d290', 'sentence_builder', 'Складіть: «Можна забрати дитину о третій?»', 'Mogu li pokupiti dijete u tri?', '["li", "u", "Mogu", "tri?", "pokupiti", "dijete"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '411bf0b5-ce18-5f4b-bdc6-f17f0bb27bb3', 'listening', 'Прослухайте і складіть фразу', 'Koliko godina ima vaš sin?', '["Koliko", "sin?", "vaš", "ima", "godina"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '51ca451d-82ca-504f-beee-6b7117919518', 'listening', 'Прослухайте і складіть фразу', 'Spavaju li djeca poslije ručka?', '["Spavaju", "poslije", "djeca", "ručka?", "li"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fb7f281e-1beb-5322-96b3-3b33c0fe5fa1', 'speaking', 'Чи є вільні місця?', 'Ima li slobodnih mjesta?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4e6530cd-f7dc-50b7-bdfd-134621a81fc4', 'speaking', 'Я заберу його о четвертій.', 'Pokupit ću ga u četiri.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('318f4882-434f-5fb2-97f2-282591c02775', v_lesson, 'Запис у садок', 'Upis u vrtić', 3981, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('ff567d21-dcc9-5e10-aa30-82f184ee62cf', '318f4882-434f-5fb2-97f2-282591c02775', 'Daša', 'Dobar dan, htjela bih upisati sina u vrtić.', 'Добрий день, я хотіла б записати сина в садок.', 1);
  perform pg_temp.turn('fb9a5e5f-9346-5f2f-8001-0e761f181e40', '318f4882-434f-5fb2-97f2-282591c02775', 'Ravnateljica', 'Koliko godina ima vaš sin?', 'Скільки років вашому синові?', 2);
  perform pg_temp.turn('48286a15-b71d-560b-87cf-81ee5ffa0388', '318f4882-434f-5fb2-97f2-282591c02775', 'Daša', 'Četiri. Ima li slobodnih mjesta?', 'Чотири. Чи є вільні місця?', 3);
  perform pg_temp.turn('c4b2e52e-16e5-5826-bed4-bf07262d1a9b', '318f4882-434f-5fb2-97f2-282591c02775', 'Ravnateljica', 'Trenutno nema, ali možete ga staviti na listu čekanja.', 'Зараз немає, але можете поставити його в список очікування.', 4);
  perform pg_temp.turn('fe5be6e2-09de-5c48-aef4-1cafd187481c', '318f4882-434f-5fb2-97f2-282591c02775', 'Daša', 'Što moram donijeti za upis?', 'Що я маю принести для запису?', 5);
  perform pg_temp.turn('ecab50ab-2912-5234-a329-536126a2611f', '318f4882-434f-5fb2-97f2-282591c02775', 'Ravnateljica', 'Rodni list, liječničku potvrdu i vaš OIB.', 'Свідоцтво про народження, медичну довідку й ваш OIB.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ed110ee4-42ad-5171-80a7-55754f242b0b', v_lesson, 'Перший тиждень', 'Prvi tjedan', 3982, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('4281ede9-902c-56b4-8105-b9d627a16204', 'ed110ee4-42ad-5171-80a7-55754f242b0b', 'Odgojiteljica', 'Dobro jutro! Prvi tjedan je prilagodba, možete ga pokupiti već u podne.', 'Доброго ранку! Перший тиждень — адаптація, можете забрати його вже опівдні.', 1);
  perform pg_temp.turn('deccb8d8-08f2-5e80-895d-0f8da40527c2', 'ed110ee4-42ad-5171-80a7-55754f242b0b', 'Darja', 'U redu. Moram li donijeti rezervnu odjeću?', 'Гаразд. Чи треба принести запасний одяг?', 2);
  perform pg_temp.turn('e177e45d-4c83-5f04-86c4-065d0d75b60a', 'ed110ee4-42ad-5171-80a7-55754f242b0b', 'Odgojiteljica', 'Morate, i papuče. Djeca se često zaprljaju.', 'Так, і тапочки. Діти часто забруднюються.', 3);
  perform pg_temp.turn('c9b9d59b-7b2c-5ea0-8921-28f563ada799', 'ed110ee4-42ad-5171-80a7-55754f242b0b', 'Darja', 'Spavaju li djeca poslije ručka?', 'Діти сплять після обіду?', 4);
  perform pg_temp.turn('7260e92a-880d-5ed6-b0f3-a13c7db61b21', 'ed110ee4-42ad-5171-80a7-55754f242b0b', 'Odgojiteljica', 'Da, popodnevni odmor je od jedan do tri.', 'Так, денний сон — з першої до третьої.', 5);
  perform pg_temp.turn('1062b134-61d8-5057-b8b3-3e3773009a50', 'ed110ee4-42ad-5171-80a7-55754f242b0b', 'Darja', 'Super, sutra ću ga dovesti u osam.', 'Чудово, завтра приведу його о восьмій.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.12 · урок 101: Навчання й мовні курси — перебудова: 16 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '11b565a4-1e2a-50d2-8d9d-c05e84371402';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Навчання й мовні курси» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '6c813954-1c33-5440-ac42-11f712898778') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 101: Навчання й мовні курси', title_hr = 'Lekcija 101: Učenje jezika i tečajevi',
         objectives = '["Записатися на мовний курс: razina, nastava, polaznik, uvjerenje", "Розповісти про іспит і визнання документів", "Родовий часу: od rujna do prosinca, prije ispita, tijekom ljeta"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Родовий відмінок: основи' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Родовий відмінок: основи»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'nastava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'početnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'napredni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'intenzivni tečaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polaznik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispit', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polagati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'položiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uvjerenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svjedodžba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'priznavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predavanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'učionica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gradivo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stipendija', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '058e4211-2757-528d-ac61-4d2de82c76a2', 'fill_in_the_blank', 'Učila sam svaki dan prije ___.', 'ispita', '["ispit", "ispita", "ispitu", "ispitom"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '096b06c4-1890-57a1-bd2d-3052fbe2da1b', 'multiple_choice', 'Що означає «napredni»?', 'просунутий (рівень)', '["скласти (іспит успішно)", "початківець", "слухач (курсу)", "просунутий (рівень)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'napredni', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b56f41cb-9d38-5d65-832d-58e00cd62cfd', 'multiple_choice', 'Що означає «uvjerenje»?', 'свідоцтво (про закінчення курсу); довідка', '["лекція", "просунутий (рівень)", "стипендія", "свідоцтво (про закінчення курсу); довідка"]'::jsonb, 'A1', 3, 'PUBLISHED', 'uvjerenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '05a853de-b4ea-5611-b260-15215ee1bba1', 'multiple_choice', 'Що означає «nastava»?', 'заняття; навчання (уроки)', '["клас, аудиторія", "свідоцтво (про закінчення курсу); довідка", "рівень", "заняття; навчання (уроки)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'nastava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7696f9b4-3e95-5276-b550-7664e7324a71', 'multiple_choice', 'Що означає «ispit»?', 'іспит, екзамен', '["навчальний матеріал", "заняття; навчання (уроки)", "стипендія", "іспит, екзамен"]'::jsonb, 'A1', 5, 'PUBLISHED', 'ispit', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3b2d7214-b68b-5627-a055-2fb6bb2a3843', 'multiple_choice', 'Як хорватською «лекція»?', 'predavanje', '["priznavanje", "gradivo", "nastava", "predavanje"]'::jsonb, 'A1', 6, 'PUBLISHED', 'predavanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4ebbb7ff-5b43-50aa-ba56-a5af65b8b6c5', 'multiple_choice', 'Як хорватською «початківець»?', 'početnik', '["polagati", "stipendija", "polaznik", "početnik"]'::jsonb, 'A1', 7, 'PUBLISHED', 'početnik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'be088a42-fe06-541b-995a-cf36b3fa2268', 'type_answer', 'Напишіть хорватською: «стипендія»', 'stipendija', null, 'A1', 8, 'PUBLISHED', 'stipendija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd41871f8-28e1-587e-9398-afcf9a805011', 'type_answer', 'Напишіть хорватською: «визнання»', 'priznavanje', null, 'A1', 9, 'PUBLISHED', 'priznavanje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9c3257cc-0818-5fe6-9134-6991a1214224', 'sentence_builder', 'Складіть: «Заняття тривають з вересня до грудня.»', 'Nastava traje od rujna do prosinca.', '["traje", "prosinca.", "rujna", "Nastava", "od", "do"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '04a6c5a1-49d3-527c-afff-9dcf94500785', 'sentence_builder', 'Складіть: «Я склала іспит.»', 'Položila sam ispit.', '["sam", "Položila", "ispit."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ed8c7539-cab8-57ba-9e5c-caaea95043d6', 'listening', 'Прослухайте і складіть фразу', 'Dobivam li uvjerenje na kraju?', '["uvjerenje", "Dobivam", "kraju?", "na", "li"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7d637eca-9d12-551e-8088-adbab2e44661', 'listening', 'Прослухайте і складіть фразу', 'Bravo! Što ćeš sada?', '["ćeš", "sada?", "Što", "Bravo!"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b2f12bdc-bd19-5919-8d43-27126d5b1184', 'speaking', 'Який у вас рівень?', 'Koja je vaša razina?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bd18c1fd-54ca-5fb2-9ae2-ef9782977f34', 'speaking', 'Я на курсі для початківців.', 'Idem na tečaj za početnike.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6c813954-1c33-5440-ac42-11f712898778', v_lesson, 'Мовна школа', 'U školi stranih jezika', 4011, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('c2b286ab-92d9-507d-9556-ae8250c403da', '6c813954-1c33-5440-ac42-11f712898778', 'Daša', 'Dobar dan, zanima me intenzivni tečaj hrvatskog.', 'Добрий день, мене цікавить інтенсивний курс хорватської.', 1);
  perform pg_temp.turn('de828874-a0cf-5359-8260-e78d0c19417d', '6c813954-1c33-5440-ac42-11f712898778', 'Tajnica', 'Koja je vaša razina? Jeste li početnica?', 'Який у вас рівень? Ви початківка?', 2);
  perform pg_temp.turn('d6f00952-ec1f-5258-a1ae-5f950c6ae4d7', '6c813954-1c33-5440-ac42-11f712898778', 'Daša', 'Nisam, učim već godinu dana. Mislim da je A2.', 'Ні, я вчу вже рік. Думаю, A2.', 3);
  perform pg_temp.turn('943e62b8-6edd-5c35-addb-6253c343d1a8', '6c813954-1c33-5440-ac42-11f712898778', 'Tajnica', 'Onda prvo napišite kratki test. Nastava traje od rujna do prosinca.', 'Тоді спочатку напишіть короткий тест. Заняття тривають з вересня до грудня.', 4);
  perform pg_temp.turn('f6cf490e-d311-5fcc-b952-ab8cad73a427', '6c813954-1c33-5440-ac42-11f712898778', 'Daša', 'Dobivam li uvjerenje na kraju?', 'Я отримаю свідоцтво в кінці?', 5);
  perform pg_temp.turn('fbd12793-1258-5dd8-b09e-eb3831889cee', '6c813954-1c33-5440-ac42-11f712898778', 'Tajnica', 'Da, nakon tečaja svi polaznici polažu ispit.', 'Так, після курсу всі слухачі складають іспит.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8334cf71-db86-5617-87b7-e8a7d9921162', v_lesson, 'Після іспиту', 'Poslije ispita', 4012, 'A1', 'work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('e127130c-a352-5afa-b598-d30d0e3f4a19', '8334cf71-db86-5617-87b7-e8a7d9921162', 'Marko', 'Darja, kako je bilo na ispitu?', 'Даріє, як було на іспиті?', 1);
  perform pg_temp.turn('0653b564-bcf6-538a-9bc6-1701a938864b', '8334cf71-db86-5617-87b7-e8a7d9921162', 'Darja', 'Položila sam! Prije ispita sam učila svaki dan.', 'Я склала! Перед іспитом я вчилася щодня.', 2);
  perform pg_temp.turn('366114e1-7dee-56d4-928e-f2b41846247d', '8334cf71-db86-5617-87b7-e8a7d9921162', 'Marko', 'Bravo! Što ćeš sada?', 'Браво! Що тепер робитимеш?', 3);
  perform pg_temp.turn('439272f9-e5ac-5a58-b95e-0fd167c98b99', '8334cf71-db86-5617-87b7-e8a7d9921162', 'Darja', 'Upisat ću napredni tečaj, a trebam i priznavanje svjedodžbe.', 'Запишуся на курс просунутого рівня, а ще мені потрібне визнання атестата.', 4);
  perform pg_temp.turn('d4772a0a-0fa2-5e72-939b-3dbc730ae068', '8334cf71-db86-5617-87b7-e8a7d9921162', 'Marko', 'Tijekom ljeta ima i besplatnih predavanja na fakultetu.', 'Улітку є й безкоштовні лекції в університеті.', 5);
  perform pg_temp.turn('32f30912-b56a-5e5d-bd49-5f62617e4c73', '8334cf71-db86-5617-87b7-e8a7d9921162', 'Darja', 'Super, tako ću ponoviti gradivo.', 'Чудово, так я повторю матеріал.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.12 · урок 102: Пошта і банкомат — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '1c468857-b9aa-5143-aa84-6ea02aa2443c';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Пошта і банкомат» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'dc0f6059-3c96-518a-abaa-5e8bc091d3ee') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 102: Пошта і банкомат', title_hr = 'Lekcija 102: Pošta i bankomat',
         objectives = '["Надіслати лист і посилку, забрати відправлення", "Зняти гроші й перевірити залишок у банкоматі", "Наказовий спосіб: ubaci, unesi, pokažite"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Наказовий спосіб' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Наказовий спосіб»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'pošta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bankomat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'paket', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pismo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preporučeno pismo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'povratnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'omotnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vagati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'brza pošta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obavijest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'provizija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'stanje računa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ubaciti karticu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'unijeti PIN', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '4f40e817-eb21-5657-9042-6e2af33d0234', 'fill_in_the_blank', 'Molim vas, ___ PIN.', 'unesite', '["unesen", "unijeti", "unio", "unesite"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '35a7a9da-4557-59a8-9764-4d5686b9b10d', 'multiple_choice', 'Що означає «ubaciti karticu»?', 'вставити картку', '["вставити картку", "залишок на рахунку", "посилка", "лист"]'::jsonb, 'A1', 2, 'PUBLISHED', 'ubaciti karticu', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6925beae-e183-5b7f-a897-5d1ea3bed253', 'multiple_choice', 'Що означає «brza pošta»?', 'експрес-пошта', '["експрес-пошта", "зважувати", "лист", "залишок на рахунку"]'::jsonb, 'A1', 3, 'PUBLISHED', 'brza pošta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a56fe15-cd54-5749-8da0-71eb01474747', 'multiple_choice', 'Що означає «stanje računa»?', 'залишок на рахунку', '["рекомендований лист", "залишок на рахунку", "зважувати", "повідомлення про вручення"]'::jsonb, 'A1', 4, 'PUBLISHED', 'stanje računa', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '203dd694-9f5d-55b9-9cfa-a8cef5749ea0', 'multiple_choice', 'Що означає «preporučeno pismo»?', 'рекомендований лист', '["банкомат", "експрес-пошта", "рекомендований лист", "посилка"]'::jsonb, 'A1', 5, 'PUBLISHED', 'preporučeno pismo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '97da5308-5483-5459-8408-9e03a8605907', 'multiple_choice', 'Як хорватською «посилка»?', 'paket', '["paket", "obavijest", "brza pošta", "unijeti PIN"]'::jsonb, 'A1', 6, 'PUBLISHED', 'paket', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '141c1fe5-cbf8-5183-87c7-49860ffb6971', 'multiple_choice', 'Як хорватською «зважувати»?', 'vagati', '["bankomat", "vagati", "pismo", "brza pošta"]'::jsonb, 'A1', 7, 'PUBLISHED', 'vagati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c3345f96-ccfe-55b4-8621-1e8464c2436f', 'type_answer', 'Напишіть хорватською: «банкомат»', 'bankomat', null, 'A1', 8, 'PUBLISHED', 'bankomat', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f13ec423-4a1b-518e-b997-4311cb8be371', 'type_answer', 'Напишіть хорватською: «конверт»', 'omotnica', null, 'A1', 9, 'PUBLISHED', 'omotnica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '103b6bed-6e79-51ae-8384-231fc2717829', 'sentence_builder', 'Складіть: «Встав картку й введи PIN.»', 'Ubaci karticu i unesi PIN.', '["Ubaci", "karticu", "PIN.", "i", "unesi"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1876e613-ac2a-5586-bdc1-e367c5c95d09', 'sentence_builder', 'Складіть: «Надсилаю посилку в Україну.»', 'Šaljem paket u Ukrajinu.', '["paket", "u", "Šaljem", "Ukrajinu."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a4da0298-1822-5b63-8193-f85fda276258', 'listening', 'Прослухайте і складіть фразу', 'Obična ili brza pošta?', '["pošta?", "Obična", "ili", "brza"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf7c4c17-1f88-55db-b4f7-f7e5f3980e4d', 'listening', 'Прослухайте і складіть фразу', 'Piše da je provizija dva eura.', '["da", "provizija", "Piše", "dva", "eura.", "je"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e44a0850-0bdd-551e-b6df-49621d494390', 'speaking', 'Рекомендованим, будь ласка.', 'Preporučeno, molim.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '676fc031-5f34-5512-9e8f-3d6868ac8e90', 'speaking', 'Я хочу забрати посилку.', 'Želim preuzeti paket.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('dc0f6059-3c96-518a-abaa-5e8bc091d3ee', v_lesson, 'На пошті', 'Na pošti', 4021, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('22074813-c32e-5bb2-9077-b3c00b2bd991', 'dc0f6059-3c96-518a-abaa-5e8bc091d3ee', 'Daša', 'Dobar dan, šaljem ovo pismo preporučeno, s povratnicom.', 'Добрий день, надсилаю цей лист рекомендованим, з повідомленням про вручення.', 1);
  perform pg_temp.turn('7bc27521-b093-5803-b185-d14ab633d66d', 'dc0f6059-3c96-518a-abaa-5e8bc091d3ee', 'Službenik', 'Dajte mi omotnicu da je izvažem.', 'Дайте конверт, я його зважу.', 2);
  perform pg_temp.turn('db75489a-37c8-53df-9ae1-c48bb3edcdad', 'dc0f6059-3c96-518a-abaa-5e8bc091d3ee', 'Daša', 'I ovaj paket za Ukrajinu, molim.', 'І цю посилку в Україну, будь ласка.', 3);
  perform pg_temp.turn('63a94ed7-6609-52a2-8875-b72de7794f0d', 'dc0f6059-3c96-518a-abaa-5e8bc091d3ee', 'Službenik', 'Obična ili brza pošta?', 'Звичайна чи експрес-пошта?', 4);
  perform pg_temp.turn('da922597-528f-5c20-9699-87e9af707990', 'dc0f6059-3c96-518a-abaa-5e8bc091d3ee', 'Daša', 'Obična. Imam i obavijest, trebam preuzeti pošiljku.', 'Звичайна. У мене ще повідомлення, мені треба забрати відправлення.', 5);
  perform pg_temp.turn('c2ba11c5-aea0-582a-8f5b-ce24676c5935', 'dc0f6059-3c96-518a-abaa-5e8bc091d3ee', 'Službenik', 'Pokažite mi osobnu iskaznicu, molim.', 'Покажіть, будь ласка, посвідчення особи.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3c745497-6d3c-55f1-8258-16ce417fbbbf', v_lesson, 'Біля банкомата', 'Na bankomatu', 4022, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('c7f925fe-5be1-593e-9fd7-399b4458c618', '3c745497-6d3c-55f1-8258-16ce417fbbbf', 'Darja', 'Marko, kako se ovdje podiže novac?', 'Марко, як тут знімають гроші?', 1);
  perform pg_temp.turn('9cd4386b-08a8-5053-954b-505d1817fbdd', '3c745497-6d3c-55f1-8258-16ce417fbbbf', 'Marko', 'Ubaci karticu i unesi PIN.', 'Встав картку й введи PIN.', 2);
  perform pg_temp.turn('e6193a59-5b6b-5f47-88b3-45df7aea22bc', '3c745497-6d3c-55f1-8258-16ce417fbbbf', 'Darja', 'Piše da je provizija dva eura.', 'Пише, що комісія два євро.', 3);
  perform pg_temp.turn('18ce3117-12ba-5fac-9c30-fdda25dec0c1', '3c745497-6d3c-55f1-8258-16ce417fbbbf', 'Marko', 'To je bankomat druge banke. Idi na bankomat svoje banke.', 'Це банкомат іншого банку. Іди до банкомата свого банку.', 4);
  perform pg_temp.turn('7882e96c-8546-5e2e-ac3b-531ca967ede0', '3c745497-6d3c-55f1-8258-16ce417fbbbf', 'Darja', 'Dobro. Mogu li vidjeti i stanje računa?', 'Добре. Можу ще подивитися залишок на рахунку?', 5);
  perform pg_temp.turn('430241c6-76b2-55d5-87da-cca51cd1a3b1', '3c745497-6d3c-55f1-8258-16ce417fbbbf', 'Marko', 'Možeš, pritisni tipku za stanje računa.', 'Можеш, натисни кнопку «залишок на рахунку».', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.12 · урок 103: У банку — перебудова: 16 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'fee5b77b-dc3b-5fd5-818a-c5496e95c23b';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «У банку» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '3f4fb8ff-2285-5d71-b0e7-f87fc265df15') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 103: У банку', title_hr = 'Lekcija 103: U banci',
         objectives = '["Відкрити рахунок у банку: tekući račun, IBAN, naknada", "Запитати про виписку, ощадний рахунок і відсоток", "Знахідний: trebam izvod, želim debitnu karticu"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Знахідний відмінок' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Знахідний відмінок»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'tekući račun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otvoriti račun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'IBAN', v_pos);
  v_pos := pg_temp.word(v_lesson, 'naknada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'debitna kartica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kreditna kartica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izvod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uplata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'štednja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'devizni račun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'štedni račun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kamata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kamatna stopa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dopušteno prekoračenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'OIB', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osobna iskaznica', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '08c6d73f-0a8c-584e-a550-385cb85a9439', 'fill_in_the_blank', 'Želim otvoriti ___ račun.', 'tekući', '["tekući", "tekućem", "tekuća", "tekućeg"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '29d97bf7-deec-56ae-865a-2bc065461e0d', 'multiple_choice', 'Що означає «kreditna kartica»?', 'кредитна картка', '["валютний рахунок", "кредитна картка", "процентна ставка", "виписка"]'::jsonb, 'A1', 2, 'PUBLISHED', 'kreditna kartica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '74be381f-ce6c-5ccd-96ea-561135a4aed4', 'multiple_choice', 'Що означає «devizni račun»?', 'валютний рахунок', '["заощадження", "посвідчення особи", "кредитна картка", "валютний рахунок"]'::jsonb, 'A1', 3, 'PUBLISHED', 'devizni račun', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fa39f282-aa66-55bf-980d-267a25353b64', 'multiple_choice', 'Що означає «uplata»?', 'платіж; надходження (на рахунок)', '["IBAN (номер банківського рахунку)", "виписка", "платіж; надходження (на рахунок)", "заощадження"]'::jsonb, 'A1', 4, 'PUBLISHED', 'uplata', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7621f611-6378-54fa-a783-7f1f143e306f', 'multiple_choice', 'Що означає «kamata»?', 'відсоток (банківський)', '["IBAN (номер банківського рахунку)", "відсоток (банківський)", "валютний рахунок", "ощадний вклад"]'::jsonb, 'A1', 5, 'PUBLISHED', 'kamata', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '28261281-7702-5158-bf4c-c9d70f43bffb', 'multiple_choice', 'Як хорватською «виписка»?', 'izvod', '["izvod", "debitna kartica", "štedni račun", "naknada"]'::jsonb, 'A1', 6, 'PUBLISHED', 'izvod', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '88802863-c155-5a95-ba38-cea1babcd9a7', 'multiple_choice', 'Як хорватською «процентна ставка»?', 'kamatna stopa', '["devizni račun", "kamata", "osobna iskaznica", "kamatna stopa"]'::jsonb, 'A1', 7, 'PUBLISHED', 'kamatna stopa', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '177b6e9e-4ff5-5b39-a544-d0dc4f0bfd94', 'type_answer', 'Напишіть хорватською: «заощадження»', 'štednja', null, 'A1', 8, 'PUBLISHED', 'štednja', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3ab2680a-50dd-5640-90ff-fcfcf0556891', 'type_answer', 'Напишіть хорватською: «ощадний вклад»', 'štedni račun', null, 'A1', 9, 'PUBLISHED', 'štedni račun', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f8265f25-d30d-591c-8c74-859778ee99ca', 'sentence_builder', 'Складіть: «Мені потрібна виписка з рахунку.»', 'Trebam izvod s računa.', '["Trebam", "s", "računa.", "izvod"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0335f757-104b-5910-87ea-6544d374630c', 'sentence_builder', 'Складіть: «Я хочу відкрити рахунок.»', 'Želim otvoriti račun.', '["otvoriti", "račun.", "Želim"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e014b0db-1c90-5505-9594-c776aa6b1d39', 'listening', 'Прослухайте і складіть фразу', 'Kolika je mjesečna naknada?', '["je", "naknada?", "mjesečna", "Kolika"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '709086cc-e332-5e8e-86f1-1b64d4893168', 'listening', 'Прослухайте і складіть фразу', 'Izvolite. Vidim da imate redovite uplate.', '["uplate.", "Vidim", "imate", "da", "redovite", "Izvolite."]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b67a9022-e1e9-5219-846f-95dbb7050559', 'speaking', 'Яка плата за рахунок?', 'Kolika je naknada za račun?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fe0d5b4d-57a8-536e-9f43-6b7cdc2237c8', 'speaking', 'Мені потрібна дебетова картка.', 'Trebam debitnu karticu.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('3f4fb8ff-2285-5d71-b0e7-f87fc265df15', v_lesson, 'Відкриваю рахунок', 'Otvaram račun', 4031, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('b36cbd05-1b22-5c8f-b520-5f7d1555429e', '3f4fb8ff-2285-5d71-b0e7-f87fc265df15', 'Daša', 'Dobar dan, želim otvoriti tekući račun.', 'Добрий день, я хочу відкрити поточний рахунок.', 1);
  perform pg_temp.turn('0c76e39b-14ad-5d5d-b5ff-6bb32e31676f', '3f4fb8ff-2285-5d71-b0e7-f87fc265df15', 'Službenica', 'Može. Trebam vašu osobnu iskaznicu ili boravišnu dozvolu i OIB.', 'Можна. Мені потрібне ваше посвідчення особи або посвідка на проживання та OIB.', 2);
  perform pg_temp.turn('3565ab5f-ec99-5e55-9525-5f3c8c8b7266', '3f4fb8ff-2285-5d71-b0e7-f87fc265df15', 'Daša', 'Kolika je mjesečna naknada?', 'Яка щомісячна плата?', 3);
  perform pg_temp.turn('a3c7da20-686e-5076-9389-8e935c2956fb', '3f4fb8ff-2285-5d71-b0e7-f87fc265df15', 'Službenica', 'Tri eura. Uz račun dobivate debitnu karticu i mobilno bankarstvo.', 'Три євро. До рахунку ви отримуєте дебетову картку й мобільний банкінг.', 4);
  perform pg_temp.turn('a151f6f3-f914-5495-9919-4634a117cd98', '3f4fb8ff-2285-5d71-b0e7-f87fc265df15', 'Daša', 'Mogu li otvoriti i devizni račun?', 'Можна відкрити й валютний рахунок?', 5);
  perform pg_temp.turn('b51d96a5-3fd4-576b-95c9-9c797b9e1c70', '3f4fb8ff-2285-5d71-b0e7-f87fc265df15', 'Službenica', 'Naravno. Evo vašeg IBAN-a, dajte ga poslodavcu za plaću.', 'Звісно. Ось ваш IBAN, дайте його роботодавцю для зарплати.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('15ccc6bf-00ef-531e-8a1a-ce0ef852febd', v_lesson, 'Виписка й заощадження', 'Izvod i štednja', 4032, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('54ceba18-cbb3-52f9-9583-d46d1386cad0', '15ccc6bf-00ef-531e-8a1a-ce0ef852febd', 'Darja', 'Trebam izvod s računa za zadnja tri mjeseca.', 'Мені потрібна виписка з рахунку за останні три місяці.', 1);
  perform pg_temp.turn('82355a73-b303-58fd-9d98-2a81d9a2d245', '15ccc6bf-00ef-531e-8a1a-ce0ef852febd', 'Službenik', 'Izvolite. Vidim da imate redovite uplate.', 'Прошу. Бачу, у вас регулярні надходження.', 2);
  perform pg_temp.turn('972e0ef6-ce3e-536b-a6e2-138906c8d405', '15ccc6bf-00ef-531e-8a1a-ce0ef852febd', 'Darja', 'Da. Zanima me i štedni račun. Kolika je kamata?', 'Так. Мене цікавить і ощадний рахунок. Який відсоток?', 3);
  perform pg_temp.turn('ee932cc0-648d-5d40-9df7-2fa6088a50dd', '15ccc6bf-00ef-531e-8a1a-ce0ef852febd', 'Službenik', 'Dva posto godišnje. Želite li i kreditnu karticu?', 'Два відсотки на рік. Бажаєте також кредитну картку?', 4);
  perform pg_temp.turn('6e37a35b-c68a-51cc-b2ce-9691d63a508f', '15ccc6bf-00ef-531e-8a1a-ce0ef852febd', 'Darja', 'Ne, hvala. Mogu li dobiti dopušteno prekoračenje?', 'Ні, дякую. А можна дозволений овердрафт?', 5);
  perform pg_temp.turn('a3e9b8bb-0885-543f-b2ca-e188b0b75245', '15ccc6bf-00ef-531e-8a1a-ce0ef852febd', 'Službenik', 'Možete, do iznosa jedne plaće.', 'Можна, до суми однієї зарплати.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.12 · урок 104: Продовження перебування — перебудова: 15 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'fe2839bc-fd72-5e8b-bc0e-937d48a90aa8';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Продовження перебування» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '4efe252b-39b0-5f19-bca5-8248a2f14d78') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 104: Продовження перебування', title_hr = 'Lekcija 104: Produljenje boravka',
         objectives = '["Продовжити тимчасове проживання: zahtjev, dokaz o smještaju, rješenje", "Підготувати переклад і засвідчені копії документів", "Родовий часу: prije isteka, najkasnije do…"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Родовий відмінок: основи' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Родовий відмінок: основи»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'produljenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'privremeni boravak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rješenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dozvola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'istjecati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dokaz o smještaju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dokaz o sredstvima', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upravna pristojba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'biljeg', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dopuna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovjereni prijevod', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sudski tumač', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preslika', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovjera', v_pos);
  v_pos := pg_temp.word(v_lesson, 'javni bilježnik', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e7991138-8762-50b5-a2b6-d0e1718ab922', 'fill_in_the_blank', 'Zahtjev predajte prije ___ dozvole.', 'isteka', '["istekom", "isteku", "istek", "isteka"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '46c770e2-eaaf-5658-9bbf-51109af882d5', 'multiple_choice', 'Що означає «biljeg»?', 'гербова марка (збір)', '["нотаріус", "гербова марка (збір)", "дозвіл; посвідка", "доповнення (документів)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'biljeg', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '84f4b8b2-8eb3-5367-97aa-b97b4d137855', 'multiple_choice', 'Що означає «privremeni boravak»?', 'тимчасове проживання (дозвіл)', '["підтвердження житла", "нотаріус", "тимчасове проживання (дозвіл)", "спливати (про термін дії)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'privremeni boravak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5386ed99-6f67-5f69-9d3c-fb0cf90d60ee', 'multiple_choice', 'Що означає «dopuna»?', 'доповнення (документів)', '["копія (ксерокопія)", "спливати (про термін дії)", "гербова марка (збір)", "доповнення (документів)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'dopuna', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5117908a-2b2b-5454-98e1-3e20e820e838', 'multiple_choice', 'Як хорватською «засвідчення (підпису, копії)»?', 'ovjera', '["produljenje", "sudski tumač", "ovjera", "rješenje"]'::jsonb, 'A1', 5, 'PUBLISHED', 'ovjera', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dba2d0ba-93b4-556a-b607-c089c906b1f0', 'multiple_choice', 'Як хорватською «нотаріус»?', 'javni bilježnik', '["istjecati", "preslika", "privremeni boravak", "javni bilježnik"]'::jsonb, 'A1', 6, 'PUBLISHED', 'javni bilježnik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '915cddf3-1893-51cb-97c8-a9834c124766', 'type_answer', 'Напишіть хорватською: «продовження (терміну)»', 'produljenje', null, 'A1', 7, 'PUBLISHED', 'produljenje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3bdd7a28-5e81-55ea-850b-2efbd115278f', 'type_answer', 'Напишіть хорватською: «офіційне рішення»', 'rješenje', null, 'A1', 8, 'PUBLISHED', 'rješenje', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '04b8de4a-374b-5050-9c88-8374b7feb1e2', 'type_answer', 'Напишіть хорватською: «присяжний перекладач»', 'sudski tumač', null, 'A1', 9, 'PUBLISHED', 'sudski tumač', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cffb54bd-eca8-504f-b2eb-be79c9bcd8b2', 'sentence_builder', 'Складіть: «Мій дозвіл спливає в червні.»', 'Moja dozvola istječe u lipnju.', '["u", "istječe", "lipnju.", "Moja", "dozvola"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd0a50ac5-ca27-595b-b413-a9fb3bcfbea4', 'sentence_builder', 'Складіть: «Мені потрібен засвідчений переклад.»', 'Trebam ovjereni prijevod.', '["ovjereni", "Trebam", "prijevod."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '49fc1514-53b1-5061-bfac-1afeaa1d0b08', 'listening', 'Прослухайте і складіть фразу', 'Što trebam donijeti?', '["Što", "donijeti?", "trebam"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd3eb59e4-d68f-5390-ad9b-65f937a72e99', 'listening', 'Прослухайте і складіть фразу', 'A preslika putovnice? Mora li biti ovjerena?', '["A", "preslika", "biti", "li", "Mora", "ovjerena?", "putovnice?"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7f46aa30-8285-5d46-aa52-e0a223fcb24e', 'speaking', 'Коли спливає ваш дозвіл?', 'Kada vam istječe dozvola?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ab451082-8ddc-5735-9bff-f36894a9e34d', 'speaking', 'Де нотаріус?', 'Gdje je javni bilježnik?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4efe252b-39b0-5f19-bca5-8248a2f14d78', v_lesson, 'У відділі для іноземців', 'U policijskoj upravi', 4041, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('c3381a58-c12a-51fc-a84d-c1cec65838b6', '4efe252b-39b0-5f19-bca5-8248a2f14d78', 'Daša', 'Dobar dan, moj privremeni boravak istječe sljedeći mjesec.', 'Добрий день, у мене наступного місяця спливає тимчасове проживання.', 1);
  perform pg_temp.turn('899c6021-ca69-5bea-bc0d-9d9185b5ae76', '4efe252b-39b0-5f19-bca5-8248a2f14d78', 'Službenica', 'Zahtjev za produljenje predajte najkasnije šezdeset dana prije isteka.', 'Заяву на продовження подайте не пізніше ніж за шістдесят днів до закінчення терміну.', 2);
  perform pg_temp.turn('028f55bb-0953-54ea-a442-86251a57ca00', '4efe252b-39b0-5f19-bca5-8248a2f14d78', 'Daša', 'Što trebam donijeti?', 'Що мені треба принести?', 3);
  perform pg_temp.turn('b65ab7ac-8f33-5ca5-9a73-5f9e071fbf45', '4efe252b-39b0-5f19-bca5-8248a2f14d78', 'Službenica', 'Putovnicu, dokaz o smještaju i dokaz o sredstvima za uzdržavanje.', 'Паспорт, підтвердження житла й підтвердження коштів на утримання.', 4);
  perform pg_temp.turn('5ce34281-a11f-571d-91a1-9160d23a5b6c', '4efe252b-39b0-5f19-bca5-8248a2f14d78', 'Daša', 'A upravna pristojba?', 'А адміністративний збір?', 5);
  perform pg_temp.turn('a63d4905-f337-5de9-b49c-afbfbbd710be', '4efe252b-39b0-5f19-bca5-8248a2f14d78', 'Službenica', 'Platite je prije predaje. Rješenje dobivate poštom.', 'Сплатіть його до подання. Рішення отримаєте поштою.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5cd5d5ae-15a5-5454-877a-be0e31a848c6', v_lesson, 'Переклад документів', 'Prijevod dokumenata', 4042, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('fd4ef905-49ec-5540-83d1-cb1aac94e9c8', '5cd5d5ae-15a5-5454-877a-be0e31a848c6', 'Darja', 'Traže od mene dopunu, ovjereni prijevod rodnog lista.', 'Від мене просять доповнення — засвідчений переклад свідоцтва про народження.', 1);
  perform pg_temp.turn('a9d9253c-544c-500b-b294-b9154ef5a135', '5cd5d5ae-15a5-5454-877a-be0e31a848c6', 'Marko', 'Treba ti sudski tumač za ukrajinski.', 'Тобі потрібен присяжний перекладач з української.', 2);
  perform pg_temp.turn('6473483b-6822-5bc6-a767-65212f06fbdf', '5cd5d5ae-15a5-5454-877a-be0e31a848c6', 'Darja', 'A preslika putovnice? Mora li biti ovjerena?', 'А копія паспорта? Вона має бути засвідчена?', 3);
  perform pg_temp.turn('d0657c0b-95cc-5fb2-9bb9-c538c4fc6373', '5cd5d5ae-15a5-5454-877a-be0e31a848c6', 'Marko', 'Ovjeru možeš napraviti kod javnog bilježnika, blizu je.', 'Засвідчити можна в нотаріуса, це поруч.', 4);
  perform pg_temp.turn('bcc461a6-d63e-537b-9645-05c4dffe36bf', '5cd5d5ae-15a5-5454-877a-be0e31a848c6', 'Darja', 'Koliko se dugo čeka odgovor?', 'Скільки чекати на відповідь?', 5);
  perform pg_temp.turn('04ff3cb3-34ec-5d5c-8394-cce800741a06', '5cd5d5ae-15a5-5454-877a-be0e31a848c6', 'Marko', 'Obično mjesec dana. Kad ti odobre, dobiješ novu iskaznicu.', 'Зазвичай місяць. Коли схвалять, отримаєш нову картку.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.12 · урок 105: Надзвичайні ситуації — перебудова: 17 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '692e9310-7a5b-5adf-9f0a-a66b72fc5459';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Надзвичайні ситуації» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '1aecb865-2ac1-5bdc-b870-e95404f11c4a') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 105: Надзвичайні ситуації', title_hr = 'Lekcija 105: Hitne situacije',
         objectives = '["Викликати допомогу: požar, dim, hitna služba, 112", "Знати, що робити під час пожежі й землетрусу", "Заперечення: ne koristite dizalo, ne gasite sami, nema opasnosti"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Заперечення' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Заперечення»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'požar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vatrogasac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dim', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gasiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'aparat za gašenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izlaz u nuždi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'evakuacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hitna služba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'opasnost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spasiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potres', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poplava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sklonište', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sirena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uzbuna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'upozorenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'baterijska svjetiljka', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '0eb53859-c0b9-5855-b2f9-1999b1b17fa7', 'fill_in_the_blank', '___ koristite dizalo za vrijeme požara!', 'Ne', '["Nije", "Ne", "Nemojte", "Ni"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '990744bd-8f82-5a51-b3ed-890afb736dca', 'multiple_choice', 'Що означає «hitna služba»?', 'екстрена служба', '["ліхтарик", "екстрена служба", "пожежник", "повінь"]'::jsonb, 'A1', 2, 'PUBLISHED', 'hitna služba', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '90364de6-b56b-5533-ae33-15ff270835b0', 'multiple_choice', 'Що означає «evakuacija»?', 'евакуація', '["ліхтарик", "попередження", "евакуація", "аварійний вихід"]'::jsonb, 'A1', 3, 'PUBLISHED', 'evakuacija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cb6481d2-b702-54b4-98f5-59ab96082803', 'multiple_choice', 'Що означає «opasnost»?', 'небезпека', '["повінь", "тривога", "аварійний вихід", "небезпека"]'::jsonb, 'A1', 4, 'PUBLISHED', 'opasnost', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1035b291-aa33-5ab1-9dcf-3eec80df3291', 'multiple_choice', 'Як хорватською «пожежник»?', 'vatrogasac', '["dim", "poplava", "uzbuna", "vatrogasac"]'::jsonb, 'A1', 5, 'PUBLISHED', 'vatrogasac', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0b1a9b3f-f229-50dc-9916-b01ed1abf566', 'multiple_choice', 'Як хорватською «ліхтарик»?', 'baterijska svjetiljka', '["gasiti", "baterijska svjetiljka", "poplava", "evakuacija"]'::jsonb, 'A1', 6, 'PUBLISHED', 'baterijska svjetiljka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '38f86fca-90e4-55d8-a156-211b07c83f68', 'type_answer', 'Напишіть хорватською: «гасити (вогонь)»', 'gasiti', null, 'A1', 7, 'PUBLISHED', 'gasiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5a3bfbbb-18d9-5e26-b514-6426787fe198', 'type_answer', 'Напишіть хорватською: «сховище, укриття»', 'sklonište', null, 'A1', 8, 'PUBLISHED', 'sklonište', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd83abf47-3bce-5b1d-898a-504878fe35e9', 'type_answer', 'Напишіть хорватською: «пожежа»', 'požar', null, 'A1', 9, 'PUBLISHED', 'požar', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fba28a44-53f8-5cc6-82b6-d1f1b86930e4', 'sentence_builder', 'Складіть: «У будинку пожежа!»', 'U zgradi je požar!', '["požar!", "zgradi", "je", "U"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9f224eae-9885-5221-b63a-dd76235f91ee', 'sentence_builder', 'Складіть: «Не користуйтеся ліфтом.»', 'Ne koristite dizalo.', '["dizalo.", "Ne", "koristite"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ff128abf-6c55-58ae-819e-2ef0744acc22', 'listening', 'Прослухайте і складіть фразу', 'Smirite se. Koja je adresa?', '["adresa?", "je", "se.", "Smirite", "Koja"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '76a49a6c-2908-5566-9969-8d4cd0ac2dee', 'listening', 'Прослухайте і складіть фразу', 'A ako nema struje?', '["struje?", "nema", "ako", "A"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a61452c6-0b25-51fd-b0e2-b1dfd0144f26', 'speaking', 'Допоможіть! Пожежа!', 'Upomoć! Požar!', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '02a5e1eb-8888-5682-be4b-a105c7369516', 'speaking', 'Подзвоніть на 112!', 'Nazovite sto dvanaest!', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1aecb865-2ac1-5bdc-b870-e95404f11c4a', v_lesson, 'Пожежа в будинку', 'Požar u zgradi', 4051, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('359b2388-0088-5ad4-9863-b8d749326646', '1aecb865-2ac1-5bdc-b870-e95404f11c4a', 'Daša', 'Halo, sto dvanaest? U zgradi je požar, vidim dim na stubištu!', 'Алло, сто дванадцять? У будинку пожежа, бачу дим на сходах!', 1);
  perform pg_temp.turn('7f322b7f-e73d-52a7-85a6-acf08cf5bcfb', '1aecb865-2ac1-5bdc-b870-e95404f11c4a', 'Dispečer', 'Smirite se. Koja je adresa?', 'Заспокойтеся. Яка адреса?', 2);
  perform pg_temp.turn('449a0fd1-26ba-59b5-9255-9741ad964986', '1aecb865-2ac1-5bdc-b870-e95404f11c4a', 'Daša', 'Vukovarska dvadeset, treći kat.', 'Вуковарська, двадцять, третій поверх.', 3);
  perform pg_temp.turn('b39edd60-7443-5e34-8344-bd476cd07f02', '1aecb865-2ac1-5bdc-b870-e95404f11c4a', 'Dispečer', 'Vatrogasci su na putu. Ne koristite dizalo!', 'Пожежники вже їдуть. Не користуйтеся ліфтом!', 4);
  perform pg_temp.turn('c01a3af5-9741-5c0e-b7b7-92fc1a5750c4', '1aecb865-2ac1-5bdc-b870-e95404f11c4a', 'Daša', 'Ima li ovdje negdje aparat za gašenje?', 'Тут десь є вогнегасник?', 5);
  perform pg_temp.turn('26620a3e-4fcc-566d-961d-67347d00c51f', '1aecb865-2ac1-5bdc-b870-e95404f11c4a', 'Dispečer', 'Ne gasite sami. Izađite kroz izlaz u nuždi i čekajte vani.', 'Не гасіть самі. Вийдіть через аварійний вихід і чекайте надворі.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cbf5cf9e-5506-5f8e-9235-b7ba583fd226', v_lesson, 'Сирена й землетрус', 'Sirena i potres', 4052, 'A1', 'basics', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('5313172d-ea13-5bc9-a56b-b919cf8e7841', 'cbf5cf9e-5506-5f8e-9235-b7ba583fd226', 'Filip', 'Mama, kakva je ovo sirena?', 'Мамо, що це за сирена?', 1);
  perform pg_temp.turn('268dea18-08d9-5761-bd0c-865d97c23f86', 'cbf5cf9e-5506-5f8e-9235-b7ba583fd226', 'Darja', 'To je samo proba uzbune, svake prve subote u mjesecu.', 'Це лише перевірка тривоги, щопершої суботи місяця.', 2);
  perform pg_temp.turn('17e74148-af02-536f-b478-635f5ecf2326', 'cbf5cf9e-5506-5f8e-9235-b7ba583fd226', 'Filip', 'A što radimo kad je potres?', 'А що робимо, коли землетрус?', 3);
  perform pg_temp.turn('216b54be-663c-5b4b-bfe4-47c561f07229', 'cbf5cf9e-5506-5f8e-9235-b7ba583fd226', 'Darja', 'Ne paničarimo. Idemo pod stol i čekamo da prestane.', 'Не панікуємо. Ховаємося під стіл і чекаємо, поки скінчиться.', 4);
  perform pg_temp.turn('53d30c50-cbbf-523f-ab74-f811e117ab8f', 'cbf5cf9e-5506-5f8e-9235-b7ba583fd226', 'Filip', 'A ako nema struje?', 'А якщо немає світла?', 5);
  perform pg_temp.turn('dc2b523d-8754-5ac9-8d20-3cc2600d3be8', 'cbf5cf9e-5506-5f8e-9235-b7ba583fd226', 'Darja', 'Imamo baterijsku svjetiljku i vodu. Nema opasnosti, ne boj se.', 'У нас є ліхтарик і вода. Небезпеки немає, не бійся.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- 3. Нові уроки модуля A1.12
-- A1.12 · урок 99: Школа: класи, уроки, розклад — новий урок: 20 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := 'e0fc94e0-c41d-5f59-adf7-db0c97c4575c';
  v_lesson constant uuid := '7c8e16ec-03f3-55dd-a61a-fb59c2401692';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A1.12: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 99: Школа: класи, уроки, розклад', 'Lekcija 99: Škola: razredi, sati i raspored', '["Розповісти про школу: razred, razrednica, školski sat, smjena", "Поговорити з класною керівницею про навчання дитини", "Svoj (свій): piše svoju zadaću, nosi svoju torbu"]'::jsonb, 15, 'PUBLISHED', 2);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Присвійні займенники' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Присвійні займенники»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'osnovna škola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srednja škola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gimnazija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razred', v_pos);
  v_pos := pg_temp.word(v_lesson, 'učiteljica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'učenik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'učenica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nastavnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'razrednica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'raspored sati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'školski sat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'veliki odmor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'hrvatski jezik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tjelesni odgoj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ocjena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zadaća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jutarnja smjena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'popodnevna smjena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'produženi boravak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'roditeljski sastanak', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '888be3c8-4dd9-5b61-a815-b6f34c0c0250', 'fill_in_the_blank', 'Filip uvijek nosi ___ torbu.', 'svoju', '["svojom", "svoj", "svoju", "svoja"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aee79509-963d-5b67-bede-25292cae207b', 'multiple_choice', 'Що означає «gimnazija»?', 'гімназія (загальноосвітня середня школа)', '["фізкультура", "учитель (у старших класах), викладач", "учениця", "гімназія (загальноосвітня середня школа)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'gimnazija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '23eb359c-cda0-569c-949e-5dcddb7b0145', 'multiple_choice', 'Що означає «osnovna škola»?', 'початкова школа', '["велика перерва (у школі)", "початкова школа", "учитель (у старших класах), викладач", "учень"]'::jsonb, 'A1', 3, 'PUBLISHED', 'osnovna škola', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0451c07f-f58a-5ed1-92a8-c57c064d7fc3', 'multiple_choice', 'Що означає «zadaća»?', 'домашнє завдання', '["післяобідня зміна (у школі)", "середня школа", "учениця", "домашнє завдання"]'::jsonb, 'A1', 4, 'PUBLISHED', 'zadaća', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2485c34c-acdc-583c-9d49-a9e3798652f2', 'multiple_choice', 'Як хорватською «фізкультура»?', 'tjelesni odgoj', '["tjelesni odgoj", "nastavnik", "roditeljski sastanak", "osnovna škola"]'::jsonb, 'A1', 5, 'PUBLISHED', 'tjelesni odgoj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '997dc30f-fcb9-58cf-82fc-e39f27d31754', 'multiple_choice', 'Як хорватською «учень»?', 'učenik', '["veliki odmor", "ocjena", "razred", "učenik"]'::jsonb, 'A1', 6, 'PUBLISHED', 'učenik', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b94cb6fd-eee1-5f1b-af37-ad4b40409def', 'type_answer', 'Напишіть хорватською: «учителька»', 'učiteljica', null, 'A1', 7, 'PUBLISHED', 'učiteljica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '48678659-d02a-5eae-b91f-75f5222f63c1', 'type_answer', 'Напишіть хорватською: «класна керівниця»', 'razrednica', null, 'A1', 8, 'PUBLISHED', 'razrednica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1dfeb791-152a-5d99-8806-73e2da6b608b', 'type_answer', 'Напишіть хорватською: «учениця»', 'učenica', null, 'A1', 9, 'PUBLISHED', 'učenica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '65bc97be-eacd-53a9-9f58-6cd7974af6b2', 'sentence_builder', 'Складіть: «Я в третьому класі.»', 'Ja sam u trećem razredu.', '["razredu.", "Ja", "u", "trećem", "sam"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e02d21ab-0e1b-59f3-a2c8-9dd2e2ba7fae', 'sentence_builder', 'Складіть: «Урок триває сорок п’ять хвилин.»', 'Školski sat traje četrdeset pet minuta.', '["pet", "četrdeset", "traje", "Školski", "sat", "minuta."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c6d81a90-4aa3-5241-aba2-4b9d61e45409', 'listening', 'Прослухайте і складіть фразу', 'Koliko traje školski sat?', '["Koliko", "školski", "sat?", "traje"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0ab1c7b1-0c61-5514-b6cb-d44dfdc1475e', 'listening', 'Прослухайте і складіть фразу', 'Ima, a tjelesni odgoj dvaput tjedno.', '["Ima,", "odgoj", "a", "tjedno.", "tjelesni", "dvaput"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e124f99e-57b3-576e-be94-f51ec2b64d84', 'speaking', 'У якому ти класі?', 'U kojem si razredu?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '83eeb0ae-92c0-5c83-8083-7473ed865268', 'speaking', 'Де розклад уроків?', 'Gdje je raspored sati?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a2b4b753-4230-54f6-aa82-7cb78d1eab7e', v_lesson, 'Перший день у школі', 'Prvi dan u školi', 3991, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('ebce906d-fa48-5908-8590-4c25ee1128fa', 'a2b4b753-4230-54f6-aa82-7cb78d1eab7e', 'Filip', 'Mama, u kojem sam razredu?', 'Мамо, у якому я класі?', 1);
  perform pg_temp.turn('e0202225-fb54-5533-8729-6aba9f21a2de', 'a2b4b753-4230-54f6-aa82-7cb78d1eab7e', 'Daša', 'U trećem b. Tvoja razrednica je učiteljica Ana.', 'У третьому «б». Твоя класна керівниця — учителька Ана.', 2);
  perform pg_temp.turn('e87823e5-8f84-5bbe-98c1-649eee21aad8', 'a2b4b753-4230-54f6-aa82-7cb78d1eab7e', 'Filip', 'Koliko traje školski sat?', 'Скільки триває урок?', 3);
  perform pg_temp.turn('f919890d-de35-5e6c-825f-bc2381bc6ab5', 'a2b4b753-4230-54f6-aa82-7cb78d1eab7e', 'Daša', 'Četrdeset pet minuta, a veliki odmor dvadeset minuta.', 'Сорок п’ять хвилин, а велика перерва — двадцять хвилин.', 4);
  perform pg_temp.turn('a877f457-48e6-528e-9b85-a2ab3721d456', 'a2b4b753-4230-54f6-aa82-7cb78d1eab7e', 'Filip', 'Idem li ujutro ili popodne?', 'Я ходжу зранку чи по обіді?', 5);
  perform pg_temp.turn('62240c28-e9c4-5074-b51c-3a1a6f4aa8f4', 'a2b4b753-4230-54f6-aa82-7cb78d1eab7e', 'Daša', 'Ovaj tjedan si u jutarnjoj smjeni, a poslije škole ideš u produženi boravak.', 'Цього тижня ти в ранковій зміні, а після школи йдеш у групу продовженого дня.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('25c4d022-3d89-5175-9ef3-016fa3d548af', v_lesson, 'Батьківські збори', 'Roditeljski sastanak', 3992, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('f53116a3-ceab-5fe5-be92-1d36bc40f612', '25c4d022-3d89-5175-9ef3-016fa3d548af', 'Razrednica', 'Dobro došli na roditeljski sastanak. Ovo je raspored sati.', 'Ласкаво просимо на батьківські збори. Ось розклад уроків.', 1);
  perform pg_temp.turn('29499c86-4cbf-5a22-80a3-8197bb9afa2c', '25c4d022-3d89-5175-9ef3-016fa3d548af', 'Darja', 'Ima li moja kći hrvatski jezik svaki dan?', 'Чи в моєї доньки хорватська мова щодня?', 2);
  perform pg_temp.turn('f31a0bfd-4315-5606-9b2b-b4828ea09b7b', '25c4d022-3d89-5175-9ef3-016fa3d548af', 'Razrednica', 'Ima, a tjelesni odgoj dvaput tjedno.', 'Так, а фізкультуру двічі на тиждень.', 3);
  perform pg_temp.turn('6ca3bdee-7ea5-5540-a5de-f30453c0477e', '25c4d022-3d89-5175-9ef3-016fa3d548af', 'Darja', 'Kako joj ide? Još slabo govori hrvatski.', 'Як у неї справи? Вона ще погано говорить хорватською.', 4);
  perform pg_temp.turn('7c430511-e407-5789-80a6-e1025701a9ee', '25c4d022-3d89-5175-9ef3-016fa3d548af', 'Razrednica', 'Dobro napreduje. Uvijek napiše svoju zadaću i ima dobre ocjene.', 'Добре прогресує. Завжди робить своє домашнє завдання й має гарні оцінки.', 5);
  perform pg_temp.turn('9e6e74f0-3e09-5aac-8994-350e37c3c26f', '25c4d022-3d89-5175-9ef3-016fa3d548af', 'Darja', 'Hvala, to me jako veseli!', 'Дякую, мене це дуже тішить!', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A1 v3 (слова за темою, 2 діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.12 · урок 100: Шкільне приладдя — новий урок: 20 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := 'e0fc94e0-c41d-5f59-adf7-db0c97c4575c';
  v_lesson constant uuid := 'e4904007-82bc-5759-89a9-05fb7a2c65c5';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A1.12: місце 3 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 100: Шкільне приладдя', 'Lekcija 100: Školski pribor', '["Назвати шкільне приладдя: pernica, gumica, šiljilo, ravnalo, bojice", "Купити приладдя за списком", "Числа: dvije olovke, tri kemijske, deset omota"]'::jsonb, 15, 'PUBLISHED', 3);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Числа й кількість: dva kruha, pet jaja' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Числа й кількість: dva kruha, pet jaja»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'školska torba', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pernica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'olovka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kemijska', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gumica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šiljilo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ravnalo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'trokut', v_pos);
  v_pos := pg_temp.word(v_lesson, 'šestar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'udžbenik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'radna bilježnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bojice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'flomasteri', v_pos);
  v_pos := pg_temp.word(v_lesson, 'škare', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vodene boje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tempere', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kolaž papir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'omot za knjige', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kutija za užinu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'popis pribora', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '152d5241-135c-545a-842a-5121076d9c15', 'fill_in_the_blank', 'Trebam dvije ___.', 'olovke', '["olovke", "olovka", "olovaka", "olovku"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9c3b585e-5985-569f-81f2-122ba34048c6', 'multiple_choice', 'Що означає «školska torba»?', 'шкільний рюкзак, портфель', '["косинець; трикутник", "темпера (фарби)", "шкільний рюкзак, портфель", "чинка (точилка)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'školska torba', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6bb488d1-3916-5790-b34f-f1ccb25b47eb', 'multiple_choice', 'Що означає «omot za knjige»?', 'обкладинка для книжок', '["обкладинка для книжок", "список приладдя", "косинець; трикутник", "гумка (для стирання)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'omot za knjige', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7dc20551-c20d-54bd-b039-8df0e597d26d', 'multiple_choice', 'Що означає «tempere»?', 'темпера (фарби)', '["пенал", "темпера (фарби)", "олівець", "кольоровий папір (для аплікацій)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'tempere', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '10cd28f1-e6ca-5d08-be75-f5225bd4f829', 'multiple_choice', 'Як хорватською «гумка (для стирання)»?', 'gumica', '["gumica", "omot za knjige", "trokut", "kolaž papir"]'::jsonb, 'A1', 5, 'PUBLISHED', 'gumica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6a63b7e2-2f76-5f3e-98de-4b75c7145755', 'multiple_choice', 'Як хорватською «лінійка»?', 'ravnalo', '["ravnalo", "školska torba", "škare", "trokut"]'::jsonb, 'A1', 6, 'PUBLISHED', 'ravnalo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8a40f407-7fc4-5344-88ca-7b20926287c7', 'type_answer', 'Напишіть хорватською: «косинець; трикутник»', 'trokut', null, 'A1', 7, 'PUBLISHED', 'trokut', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '178e532e-9c18-58f7-bae6-3a10f425774f', 'type_answer', 'Напишіть хорватською: «чинка (точилка)»', 'šiljilo', null, 'A1', 8, 'PUBLISHED', 'šiljilo', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'adc57cf7-d210-50ac-83cc-6bb052edb894', 'type_answer', 'Напишіть хорватською: «кулькова ручка»', 'kemijska', null, 'A1', 9, 'PUBLISHED', 'kemijska', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3d9651bd-a612-511c-a11c-3d072a104509', 'sentence_builder', 'Складіть: «Мені потрібні три зошити.»', 'Trebam tri bilježnice.', '["tri", "bilježnice.", "Trebam"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '09735a59-4589-5d0d-be82-fef0f7620883', 'sentence_builder', 'Складіть: «Де мій пенал?»', 'Gdje je moja pernica?', '["moja", "Gdje", "je", "pernica?"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e094fe7e-ae64-598a-acfe-6c2dfc40b7dc', 'listening', 'Прослухайте і складіть фразу', 'Trebaju mi dvije olovke, gumica i šiljilo.', '["gumica", "Trebaju", "dvije", "i", "šiljilo.", "olovke,", "mi"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0c0143dd-be55-5bbe-bb0e-6ccd8d16bd0f', 'listening', 'Прослухайте і складіть фразу', 'Joj, puno toga! Koliko je sve ukupno?', '["toga!", "sve", "puno", "Koliko", "ukupno?", "Joj,", "je"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '724d58f0-f019-5175-987e-af5838d5bffb', 'speaking', 'Мені потрібні два олівці.', 'Trebaju mi dvije olovke.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9454037b-f8c7-5ab4-b21e-a4014c1dafde', 'speaking', 'Скільки коштує пенал?', 'Koliko košta pernica?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('dd9dfb49-fbef-5ba6-97d2-f9e74a355a2f', v_lesson, 'Список приладдя', 'Popis pribora', 4001, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('eafdd5a5-349a-5614-8797-a2889688f050', 'dd9dfb49-fbef-5ba6-97d2-f9e74a355a2f', 'Daša', 'Filipe, imamo popis pribora za treći razred. Idemo redom.', 'Філіпе, у нас є список приладдя для третього класу. Ідемо по черзі.', 1);
  perform pg_temp.turn('e8299f01-5187-57f2-9578-34ef71237a3c', 'dd9dfb49-fbef-5ba6-97d2-f9e74a355a2f', 'Filip', 'Trebaju mi dvije olovke, gumica i šiljilo.', 'Мені потрібні два олівці, гумка й чинка.', 2);
  perform pg_temp.turn('2c747bb6-1125-57d3-9c12-78285600df8e', 'dd9dfb49-fbef-5ba6-97d2-f9e74a355a2f', 'Daša', 'A kemijske?', 'А ручки?', 3);
  perform pg_temp.turn('13118e08-3dfa-5f9e-8314-a1424854eebc', 'dd9dfb49-fbef-5ba6-97d2-f9e74a355a2f', 'Filip', 'Tri kemijske: plava, crvena i crna.', 'Три ручки: синя, червона й чорна.', 4);
  perform pg_temp.turn('84374130-d918-511f-a6de-44e155b70298', 'dd9dfb49-fbef-5ba6-97d2-f9e74a355a2f', 'Daša', 'Ravnalo i trokut imaš od prošle godine.', 'Лінійку й косинець маєш з минулого року.', 5);
  perform pg_temp.turn('fccfc63d-9d83-5de2-8374-1b5c99ee0b46', 'dd9dfb49-fbef-5ba6-97d2-f9e74a355a2f', 'Filip', 'Ali trebam novu pernicu, stara je potrgana!', 'Але мені потрібен новий пенал, старий порвався!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('52d2ca64-4f90-5758-9e43-235900768b5b', v_lesson, 'У книгарні', 'U knjižari', 4002, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('bc7922e4-e023-5906-93cb-35654c133b18', '52d2ca64-4f90-5758-9e43-235900768b5b', 'Darja', 'Dobar dan, trebam radne bilježnice za drugi razred.', 'Добрий день, мені потрібні робочі зошити для другого класу.', 1);
  perform pg_temp.turn('bd7dcea9-19c4-5dd1-83bc-a74c2327e0f2', '52d2ca64-4f90-5758-9e43-235900768b5b', 'Prodavačica', 'Izvolite. Trebate li i omote za knjige?', 'Прошу. Вам потрібні й обкладинки для книжок?', 2);
  perform pg_temp.turn('acab34c7-eee8-590e-84aa-1503534eae96', '52d2ca64-4f90-5758-9e43-235900768b5b', 'Darja', 'Da, deset omota. I bojice, flomastere i škare.', 'Так, десять обкладинок. І кольорові олівці, фломастери й ножиці.', 3);
  perform pg_temp.turn('0b84d761-4436-53cb-b03e-c9ef413e593d', '52d2ca64-4f90-5758-9e43-235900768b5b', 'Prodavačica', 'Za likovni trebate i vodene boje, tempere i kolaž papir.', 'Для малювання потрібні ще акварель, темпера й кольоровий папір.', 4);
  perform pg_temp.turn('757eae54-684c-5ced-913c-556fe272f681', '52d2ca64-4f90-5758-9e43-235900768b5b', 'Darja', 'Joj, puno toga! Koliko je sve ukupno?', 'Ой, як багато! Скільки все разом?', 5);
  perform pg_temp.turn('73459df4-0231-53cf-94fe-1ca3358cb1b1', '52d2ca64-4f90-5758-9e43-235900768b5b', 'Prodavačica', 'Pedeset dva eura. Želite li vrećicu?', 'П’ятдесят два євро. Бажаєте пакет?', 6);
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
   where l.id in ('42c31cfb-8680-5450-8453-245f3abd475a', '7c8e16ec-03f3-55dd-a61a-fb59c2401692', 'e4904007-82bc-5759-89a9-05fb7a2c65c5', '11b565a4-1e2a-50d2-8d9d-c05e84371402', '1c468857-b9aa-5143-aa84-6ea02aa2443c', 'fee5b77b-dc3b-5fd5-818a-c5496e95c23b', 'fe2839bc-fd72-5e8b-bc0e-937d48a90aa8', '692e9310-7a5b-5adf-9f0a-a66b72fc5459')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 10 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_order from (values ('42c31cfb-8680-5450-8453-245f3abd475a'::uuid, 1), ('7c8e16ec-03f3-55dd-a61a-fb59c2401692'::uuid, 2), ('e4904007-82bc-5759-89a9-05fb7a2c65c5'::uuid, 3), ('11b565a4-1e2a-50d2-8d9d-c05e84371402'::uuid, 4), ('1c468857-b9aa-5143-aa84-6ea02aa2443c'::uuid, 5), ('fee5b77b-dc3b-5fd5-818a-c5496e95c23b'::uuid, 6), ('fe2839bc-fd72-5e8b-bc0e-937d48a90aa8'::uuid, 7), ('692e9310-7a5b-5adf-9f0a-a66b72fc5459'::uuid, 8)) as t(id, o)
    join public.lessons l on l.id = t.id and l.order_index = t.o and l.unit_id = 'e0fc94e0-c41d-5f59-adf7-db0c97c4575c';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A1' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('42c31cfb-8680-5450-8453-245f3abd475a', '7c8e16ec-03f3-55dd-a61a-fb59c2401692', 'e4904007-82bc-5759-89a9-05fb7a2c65c5', '11b565a4-1e2a-50d2-8d9d-c05e84371402', '1c468857-b9aa-5143-aa84-6ea02aa2443c', 'fee5b77b-dc3b-5fd5-818a-c5496e95c23b', 'fe2839bc-fd72-5e8b-bc0e-937d48a90aa8', '692e9310-7a5b-5adf-9f0a-a66b72fc5459') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A1.12: % уроків з неправильним складом', v_bad; end if;
  if v_order <> 8 then raise exception 'Модуль A1.12: на своїх місцях % уроків з 8', v_order; end if;
  if v_titles > 0 then raise exception 'A1: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A1.12: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A1.12 — 8 уроків за темою (6 перебудовано, 2 нових)';
end $$;

commit;
