-- =====================================================================
-- Програма A1 v3 · модуль A1.11 «Хорватська культура» · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_curriculum_a1_v3.py 11 (не редагуйте вручну).
--
-- Рішення власника 2026-10-21 / 2026-10-26: до 25 слів на урок — скільки потрібно темі, 90–95 % слів — нові для рівня,
-- діалоги під тему, частіше Даша / Дар’я; бета (PUBLISHED).
--   * Уроки 93–97: 5 наявних перебудовано, 0 нових. Слів у них: 81.
--     Кожен: 10–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 51.
--   * Виправлено: specijalitet — «фірмова страва; місцевий делікатес»; obnoviti — «відновити, відреставрувати» (стара версія — у content_versions).
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

-- 1. Нові слова й вирази A1.11 (51; наявні не змінюються)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tvrđava', 'tvrdava', 'hr', 'noun', 'A1', 'фортеця', 'core', '{"gender": "f"}'::jsonb, '["Na brdu iznad grada stoji stara tvrđava."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('samostan', 'samostan', 'hr', 'noun', 'A1', 'монастир', 'core', '{"gender": "m"}'::jsonb, '["U samostanu je jedna od najstarijih ljekarni u Europi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kip', 'kip', 'hr', 'noun', 'A1', 'статуя, пам’ятник (скульптура)', 'core', '{"gender": "m"}'::jsonb, '["Turisti se slikaju pored kipa na trgu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gradska vrata', 'gradska vrata', 'hr', 'phrase', 'A1', 'міські ворота', 'collocation', '{"gender": "n", "number": "pl"}'::jsonb, '["U stari grad ulazimo kroz gradska vrata."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ruševine', 'rusevine', 'hr', 'noun', 'A1', 'руїни', 'core', '{"gender": "f", "number": "pl"}'::jsonb, '["Na otoku smo vidjeli ruševine rimske vile."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('srednjovjekovni', 'srednjovjekovni', 'hr', 'adjective', 'A1', 'середньовічний', 'core', '{}'::jsonb, '["Motovun je mali srednjovjekovni grad na brdu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('barokni', 'barokni', 'hr', 'adjective', 'A1', 'бароковий', 'core', '{}'::jsonb, '["Varaždin je poznat po baroknim palačama."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('izgraditi', 'izgraditi', 'hr', 'verb', 'A1', 'побудувати', 'core', '{"aspect": "pfv"}'::jsonb, '["Ovu crkvu izgradili su u petnaestom stoljeću."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('uličica', 'ulicica', 'hr', 'noun', 'A1', 'вуличка', 'core', '{"gender": "f"}'::jsonb, '["Volim šetati uskim uličicama starog grada."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kameni', 'kameni', 'hr', 'adjective', 'A1', 'кам’яний', 'core', '{}'::jsonb, '["Kuće na otoku su stare i kamene."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kulen', 'kulen', 'hr', 'noun', 'A1', 'кулен (гостра славонська ковбаса)', 'core', '{"gender": "m"}'::jsonb, '["Iz Slavonije smo donijeli domaći kulen."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('čobanac', 'cobanac', 'hr', 'noun', 'A1', 'чобанац (гостре м’ясне рагу зі Славонії)', 'core', '{"gender": "m"}'::jsonb, '["Čobanac se dugo kuha u kotliću."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pašticada', 'pasticada', 'hr', 'noun', 'A1', 'паштицада (далматинська тушкована яловичина)', 'core', '{"gender": "f"}'::jsonb, '["Baka svake nedjelje radi pašticadu s njokima."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('crni rižot', 'crni rizot', 'hr', 'phrase', 'A1', 'чорне різото (з чорнилом каракатиці)', 'collocation', '{"gender": "m"}'::jsonb, '["Crni rižot je crn zbog tinte od sipe."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nazdraviti', 'nazdraviti', 'hr', 'verb', 'A1', 'виголосити тост, цокнутися', 'core', '{"aspect": "pfv"}'::jsonb, '["Nazdravimo za mladence!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nedjeljni ručak', 'nedjeljni rucak', 'hr', 'phrase', 'A1', 'недільний обід (з родиною)', 'collocation', '{"gender": "m"}'::jsonb, '["Nedjeljni ručak kod bake počinje juhom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('imendan', 'imendan', 'hr', 'noun', 'A1', 'іменини', 'core', '{"gender": "m"}'::jsonb, '["Danas Ivan slavi imendan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('rukovati se', 'rukovati se', 'hr', 'verb', 'A1', 'потиснути руку, привітатися за руку', 'core', '{"aspect": "ipfv"}'::jsonb, '["Na sastanku se svi rukuju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ljubiti se', 'ljubiti se', 'hr', 'verb', 'A1', 'цілуватися', 'core', '{"aspect": "ipfv"}'::jsonb, '["Prijatelji se pri susretu ljube u obraz."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('izuti se', 'izuti se', 'hr', 'verb', 'A1', 'роззутися', 'core', '{"aspect": "pfv"}'::jsonb, '["Moram li se izuti u stanu?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ići na kavu', 'ici na kavu', 'hr', 'phrase', 'A1', 'піти на каву (зустрітися з кимось)', 'chunk', '{}'::jsonb, '["Hoćemo li ići na kavu poslije posla?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gostoljubiv', 'gostoljubiv', 'hr', 'adjective', 'A1', 'гостинний', 'core', '{}'::jsonb, '["Ljudi na otoku su jako gostoljubivi."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('red je', 'red je', 'hr', 'phrase', 'A1', 'так годиться, так заведено', 'formulaic', '{}'::jsonb, '["Red je donijeti nešto kad ideš u goste."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('gledati u oči', 'gledati u oci', 'hr', 'phrase', 'A1', 'дивитися в очі', 'chunk', '{}'::jsonb, '["Kad nazdravljamo, gledamo se u oči."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('adventski vijenac', 'adventski vijenac', 'hr', 'phrase', 'A1', 'адвентовий вінок', 'collocation', '{"gender": "m"}'::jsonb, '["Na adventskom vijencu su četiri svijeće."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('svijeća', 'svijeca', 'hr', 'noun', 'A1', 'свічка', 'core', '{"gender": "f"}'::jsonb, '["Svake nedjelje u adventu palimo jednu svijeću."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('božićno drvce', 'bozicno drvce', 'hr', 'phrase', 'A1', 'різдвяна ялинка', 'collocation', '{"gender": "n"}'::jsonb, '["Božićno drvce kitimo na Badnjak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('božićna kuglica', 'bozicna kuglica', 'hr', 'phrase', 'A1', 'ялинкова кулька', 'collocation', '{"gender": "f"}'::jsonb, '["Djeca su objesila crvene božićne kuglice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('lampice', 'lampice', 'hr', 'noun', 'A1', 'гірлянда, вогники', 'core', '{"gender": "f", "number": "pl"}'::jsonb, '["U prosincu cijeli grad svijetli od lampica."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('jaslice', 'jaslice', 'hr', 'noun', 'A1', 'вертеп (різдвяна сцена з яслами)', 'core', '{"gender": "f", "number": "pl"}'::jsonb, '["Pored crkve su velike jaslice."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('polnoćka', 'polnocka', 'hr', 'noun', 'A1', 'опівнічна різдвяна меса', 'core', '{"gender": "f"}'::jsonb, '["Na Badnjak idemo na polnoćku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Sveti Nikola', 'sveti nikola', 'hr', 'phrase', 'A1', 'Святий Миколай (6 грудня)', 'collocation', '{"gender": "m"}'::jsonb, '["Sveti Nikola djeci donosi slatkiše u čizmicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bakalar', 'bakalar', 'hr', 'noun', 'A1', 'бакалар (сушена тріска)', 'core', '{"gender": "m"}'::jsonb, '["Na Badnjak u Dalmaciji jedemo bakalar."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('korizma', 'korizma', 'hr', 'noun', 'A1', 'Великий піст', 'core', '{"gender": "f"}'::jsonb, '["Korizma traje četrdeset dana prije Uskrsa."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Cvjetnica', 'cvjetnica', 'hr', 'noun', 'A1', 'Квітна (Вербна) неділя', 'core', '{"gender": "f"}'::jsonb, '["Na Cvjetnicu ljudi nose maslinove grančice u crkvu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('bojiti jaja', 'bojiti jaja', 'hr', 'phrase', 'A1', 'фарбувати яйця', 'chunk', '{"aspect": "ipfv"}'::jsonb, '["Uoči Uskrsa djeca boje jaja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('državni praznik', 'drzavni praznik', 'hr', 'phrase', 'A1', 'державне свято', 'collocation', '{"gender": "m"}'::jsonb, '["Na državni praznik trgovine ne rade."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Sveta tri kralja', 'sveta tri kralja', 'hr', 'phrase', 'A1', 'Богоявлення (6 січня)', 'collocation', '{"gender": "m", "number": "pl"}'::jsonb, '["Na Sveta tri kralja skidamo božićno drvce."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Uskrsni ponedjeljak', 'uskrsni ponedjeljak', 'hr', 'phrase', 'A1', 'Великодній понеділок', 'collocation', '{"gender": "m"}'::jsonb, '["Uskrsni ponedjeljak je neradni dan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Praznik rada', 'praznik rada', 'hr', 'phrase', 'A1', 'День праці (1 травня)', 'collocation', '{"gender": "m"}'::jsonb, '["Za Praznik rada idemo na izlet."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Tijelovo', 'tijelovo', 'hr', 'noun', 'A1', 'Свято Тіла Христового (четвер)', 'core', '{"gender": "n"}'::jsonb, '["Tijelovo je uvijek u četvrtak."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Dan antifašističke borbe', 'dan antifasisticke borbe', 'hr', 'phrase', 'A1', 'День антифашистської боротьби (22 червня)', 'collocation', '{"gender": "m"}'::jsonb, '["Dan antifašističke borbe obilježava se dvadeset drugog lipnja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Dan pobjede', 'dan pobjede', 'hr', 'phrase', 'A1', 'День перемоги й вдячності батьківщині (5 серпня)', 'collocation', '{"gender": "m"}'::jsonb, '["Na Dan pobjede u Kninu je velika proslava."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Velika Gospa', 'velika gospa', 'hr', 'phrase', 'A1', 'Успіння Богородиці (15 серпня)', 'collocation', '{"gender": "f"}'::jsonb, '["Za Veliku Gospu mnogi idu u Sinj ili Mariju Bistricu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Svi sveti', 'svi sveti', 'hr', 'phrase', 'A1', 'День усіх святих (1 листопада)', 'collocation', '{"gender": "m", "number": "pl"}'::jsonb, '["Za Sve svete ljudi pale svijeće na groblju."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Dan sjećanja', 'dan sjecanja', 'hr', 'phrase', 'A1', 'День пам’яті жертв Вітчизняної війни, Вуковара й Шкабрні (18 листопада)', 'collocation', '{"gender": "m"}'::jsonb, '["Na Dan sjećanja tisuće ljudi dolaze u Vukovar."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('Sveti Stjepan', 'sveti stjepan', 'hr', 'phrase', 'A1', 'День святого Стефана (26 грудня)', 'collocation', '{"gender": "m"}'::jsonb, '["Na Svetog Stjepana idemo u goste rodbini."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('produženi vikend', 'produzeni vikend', 'hr', 'phrase', 'A1', 'довгі вихідні', 'collocation', '{"gender": "m"}'::jsonb, '["Zbog praznika imamo produženi vikend."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zastava', 'zastava', 'hr', 'noun', 'A1', 'прапор', 'core', '{"gender": "f"}'::jsonb, '["Hrvatska zastava je crveno-bijelo-plava."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('himna', 'himna', 'hr', 'noun', 'A1', 'гімн', 'core', '{"gender": "f"}'::jsonb, '["Hrvatska himna zove se «Lijepa naša domovino»."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('doček Nove godine', 'docek nove godine', 'hr', 'phrase', 'A1', 'зустріч Нового року', 'collocation', '{"gender": "m"}'::jsonb, '["Doček Nove godine bit će na glavnom trgu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;

-- 1б. Виправлені слова (2); повторний запуск нічого не змінює
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'specijalitet' and ukrainian_translation = 'фірмова страва; специалітет' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'фірмова страва; місцевий делікатес' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'obnoviti' and ukrainian_translation = 'відновити, реконструювати' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'відновити, відреставрувати' where id = r.id;
  end loop;
end $$;

-- 2. Перебудова наявних уроків модуля A1.11
-- A1.11 · урок 93: Старе місто: екскурсія — перебудова: 15 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'd9ef1de4-f4db-590e-bafd-474f84c8e03f';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Старе місто: екскурсія» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'cbe604e8-d0b2-5f61-8ee8-4c0c3bc3d639') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 93: Старе місто: екскурсія', title_hr = 'Lekcija 93: Stari grad: razgledavanje',
         objectives = '["Розповісти про старе місто: zidine, tvrđava, toranj, gradska vrata", "Розпитати гіда про історію міста", "Минулий час: šetala sam, izgradili su"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Минулий час: radio sam, bila sam»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'zidine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'katedrala', v_pos);
  v_pos := pg_temp.word(v_lesson, 'toranj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tvrđava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'samostan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kip', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gradska vrata', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ruševine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'srednjovjekovni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'barokni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izgraditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obnoviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uličica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kameni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'turistički vodič', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dd5d4823-4ae9-5785-bfc9-bd216521f94b', 'fill_in_the_blank', 'Jučer smo ___ stari grad s vodičem.', 'razgledali', '["razgledat ćemo", "razgledali", "razgledamo", "razgledati"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '42e5b804-09d9-5efe-bba6-fc4144a29833', 'multiple_choice', 'Що означає «toranj»?', 'дзвіниця; вежа', '["міські ворота", "вуличка", "дзвіниця; вежа", "статуя, пам’ятник (скульптура)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'toranj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '19fe1e06-3fe4-5c78-af85-28da7b3fbedf', 'multiple_choice', 'Що означає «zidine»?', 'міські мури', '["вуличка", "статуя, пам’ятник (скульптура)", "середньовічний", "міські мури"]'::jsonb, 'A1', 3, 'PUBLISHED', 'zidine', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7b58dd0a-a491-5b0f-b168-8e29d8303c09', 'multiple_choice', 'Що означає «kip»?', 'статуя, пам’ятник (скульптура)', '["руїни", "кам’яний", "середньовічний", "статуя, пам’ятник (скульптура)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'kip', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '439f7eff-5776-5c27-a6e4-0b081880db71', 'multiple_choice', 'Як хорватською «побудувати»?', 'izgraditi', '["toranj", "samostan", "izgraditi", "turistički vodič"]'::jsonb, 'A1', 5, 'PUBLISHED', 'izgraditi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4ba2a254-ee91-5b4d-9c77-3b5a6dfa3106', 'multiple_choice', 'Як хорватською «середньовічний»?', 'srednjovjekovni', '["turistički vodič", "srednjovjekovni", "kip", "obnoviti"]'::jsonb, 'A1', 6, 'PUBLISHED', 'srednjovjekovni', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fe1ca7b2-9031-5758-a54e-c6aff38a3598', 'type_answer', 'Напишіть хорватською: «руїни»', 'ruševine', null, 'A1', 7, 'PUBLISHED', 'ruševine', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ff509eb1-aaf4-529e-8131-3c4aaf690757', 'type_answer', 'Напишіть хорватською: «відновити, відреставрувати»', 'obnoviti', null, 'A1', 8, 'PUBLISHED', 'obnoviti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0ee510ce-a831-5072-b317-705aae0b2bdd', 'type_answer', 'Напишіть хорватською: «кам’яний»', 'kameni', null, 'A1', 9, 'PUBLISHED', 'kameni', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '79d4cff4-73db-5115-b5a7-3982ca916a51', 'sentence_builder', 'Складіть: «Ми гуляли вузькими вуличками.»', 'Šetali smo uskim uličicama.', '["smo", "Šetali", "uskim", "uličicama."]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '88e2f80e-e035-5be3-8a88-f8b89d1d7541', 'sentence_builder', 'Складіть: «Фортеця дуже стара.»', 'Tvrđava je jako stara.', '["je", "Tvrđava", "stara.", "jako"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8456e592-e4b2-56ee-9852-8572f42bbe58', 'listening', 'Прослухайте і складіть фразу', 'A što je ona velika tvrđava?', '["je", "velika", "tvrđava?", "ona", "A", "što"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '46dcedbd-d448-50e9-83c7-925567494006', 'listening', 'Прослухайте і складіть фразу', 'Jesi li vidjela kip Grgura Ninskog?', '["vidjela", "kip", "Ninskog?", "Grgura", "Jesi", "li"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1ff1bf03-e926-5ffa-9eb7-ee9cf9600333', 'speaking', 'Коли збудували ці мури?', 'Kada su izgradili ove zidine?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '41097559-6d27-5f43-bfa5-aa1b476145f7', 'speaking', 'Я гуляла старим містом.', 'Šetala sam starim gradom.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('cbe604e8-d0b2-5f61-8ee8-4c0c3bc3d639', v_lesson, 'Екскурсія Дубровником', 'Razgledavanje Dubrovnika', 3931, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('4ec69643-2afd-54d3-98b8-775b7c0dd7c6', 'cbe604e8-d0b2-5f61-8ee8-4c0c3bc3d639', 'Ivan', 'Dobro došli! Ja sam vaš turistički vodič.', 'Ласкаво просимо! Я ваш туристичний гід.', 1);
  perform pg_temp.turn('2cc277e7-6c35-5e31-aa2a-598c9a5244ae', 'cbe604e8-d0b2-5f61-8ee8-4c0c3bc3d639', 'Daša', 'Kada su izgradili ove zidine?', 'Коли збудували ці мури?', 2);
  perform pg_temp.turn('8b0f48e6-e968-52cd-8f95-817a223d873e', 'cbe604e8-d0b2-5f61-8ee8-4c0c3bc3d639', 'Ivan', 'Gradili su ih stoljećima, još u srednjem vijeku.', 'Їх будували століттями, ще в середньовіччі.', 3);
  perform pg_temp.turn('588c7742-7a59-5678-89d2-c0b5606bf9f9', 'cbe604e8-d0b2-5f61-8ee8-4c0c3bc3d639', 'Daša', 'A što je ona velika tvrđava?', 'А що це за велика фортеця?', 4);
  perform pg_temp.turn('53e955a4-7cc4-5fbc-843a-e0f00ffce533', 'cbe604e8-d0b2-5f61-8ee8-4c0c3bc3d639', 'Ivan', 'To je Lovrijenac. Nekada su ondje živjeli vojnici.', 'Це Ловрієнац. Колись там жили вояки.', 5);
  perform pg_temp.turn('16a005db-77e6-5337-86cb-05d417a6b9e7', 'cbe604e8-d0b2-5f61-8ee8-4c0c3bc3d639', 'Daša', 'Možemo li se popeti gore?', 'Можна піднятися нагору?', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d9a717d1-5935-5925-aed8-169c6933391a', v_lesson, 'Прогулянка Сплітом', 'Šetnja Splitom', 3932, 'A1', 'travel', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('bb913d59-089a-5ba8-9f88-2129463dd32b', 'd9a717d1-5935-5925-aed8-169c6933391a', 'Marko', 'Darja, jesi li bila u Dioklecijanovoj palači?', 'Даріє, ти була в Діоклетіановому палаці?', 1);
  perform pg_temp.turn('09bd7378-0573-52ec-a30b-d43c79284bf8', 'd9a717d1-5935-5925-aed8-169c6933391a', 'Darja', 'Jesam! Šetala sam uskim kamenim uličicama.', 'Так! Я гуляла вузькими кам’яними вуличками.', 2);
  perform pg_temp.turn('0e16292b-949b-59e3-80aa-c2d36d5e4bfe', 'd9a717d1-5935-5925-aed8-169c6933391a', 'Marko', 'Jesi li vidjela kip Grgura Ninskog?', 'Ти бачила статую Григорія Нинського?', 3);
  perform pg_temp.turn('306eb07c-fc96-5ee6-a75d-45e1cde98471', 'd9a717d1-5935-5925-aed8-169c6933391a', 'Darja', 'Jesam, i protrljala sam mu nožni palac za sreću.', 'Так, і потерла йому великий палець ноги на щастя.', 4);
  perform pg_temp.turn('d602704e-278a-558c-a147-fb4ccef282f3', 'd9a717d1-5935-5925-aed8-169c6933391a', 'Marko', 'A jesi li se popela na toranj katedrale?', 'А ти піднялася на дзвіницю собору?', 5);
  perform pg_temp.turn('558efb55-06fd-5537-8f38-ab0a89dbc53a', 'd9a717d1-5935-5925-aed8-169c6933391a', 'Darja', 'Nisam, bilo je previše ljudi. Idem sutra ujutro.', 'Ні, було забагато людей. Піду завтра зранку.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.11 · урок 94: Хорватська кухня — перебудова: 17 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'f1b2093d-9699-59af-92b9-ed7bdf7fad49';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Хорватська кухня» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '792f97a8-edd2-5495-958c-a2d9254e8f70') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 94: Хорватська кухня', title_hr = 'Lekcija 94: Hrvatska kuhinja',
         objectives = '["Назвати хорватські страви: pršut, sarma, peka, štrukli, kulen", "Замовити фірмову страву й порадити, що скуштувати", "Порівняння: najbolji, ljući od…"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Ступені порівняння' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Ступені порівняння»'; end if;
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
  v_pos := pg_temp.word(v_lesson, 'kremšnita', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ćevapi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'specijalitet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tartuf', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kulen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čobanac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pašticada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'crni rižot', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '5b524238-6ea4-5705-bc67-f35c9749b151', 'fill_in_the_blank', 'Ovo je ___ pršut koji sam ikad jeo!', 'najbolji', '["bolje", "najbolje", "najbolji", "najbolja"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '647a36ab-647c-5825-961a-06a66975067a', 'multiple_choice', 'Що означає «peka»?', 'пека (страва під залізною кришкою на жару)', '["паґський сир (овечий, з острова Паґ)", "кулен (гостра славонська ковбаса)", "пека (страва під залізною кришкою на жару)", "трюфель"]'::jsonb, 'A1', 2, 'PUBLISHED', 'peka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0c638d30-5490-5334-8430-62d58bce73ee', 'multiple_choice', 'Що означає «brudet»?', 'брудет (рибне рагу)', '["паґський сир (овечий, з острова Паґ)", "брудет (рибне рагу)", "оливка", "чорне різото (з чорнилом каракатиці)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'brudet', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a5bd9209-1e7c-5f49-bf40-1c20020a9ed9', 'multiple_choice', 'Що означає «pašticada»?', 'паштицада (далматинська тушкована яловичина)', '["кулен (гостра славонська ковбаса)", "кремшніта (тістечко з кремом)", "чорне різото (з чорнилом каракатиці)", "паштицада (далматинська тушкована яловичина)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'pašticada', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6ca9d5c2-5bfd-5005-bf9f-89b4f407d78e', 'multiple_choice', 'Як хорватською «фрітуле (маленькі пончики)»?', 'fritule', '["paški sir", "tartuf", "sarma", "fritule"]'::jsonb, 'A1', 5, 'PUBLISHED', 'fritule', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0682954a-20ce-5ff8-ad3d-401f63de6682', 'multiple_choice', 'Як хорватською «мангольд»?', 'blitva', '["blitva", "specijalitet", "pršut", "fritule"]'::jsonb, 'A1', 6, 'PUBLISHED', 'blitva', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6fe90a71-80f6-523c-8b95-8178841421f1', 'type_answer', 'Напишіть хорватською: «кулен (гостра славонська ковбаса)»', 'kulen', null, 'A1', 7, 'PUBLISHED', 'kulen', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0952d881-4a8e-59e5-b822-29e908ef0cda', 'type_answer', 'Напишіть хорватською: «чорне різото (з чорнилом каракатиці)»', 'crni rižot', null, 'A1', 8, 'PUBLISHED', 'crni rižot', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd486f50a-b287-5023-9a27-5855f114ca37', 'type_answer', 'Напишіть хорватською: «оливка»', 'maslina', null, 'A1', 9, 'PUBLISHED', 'maslina', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'df12bd02-4080-508f-9997-3c04485254a2', 'sentence_builder', 'Складіть: «Пршут смачніший за шинку.»', 'Pršut je ukusniji od šunke.', '["Pršut", "ukusniji", "šunke.", "od", "je"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '18b4e371-dfa7-5797-a47f-024541f8c8a1', 'sentence_builder', 'Складіть: «Я хочу скуштувати сарму.»', 'Želim probati sarmu.', '["probati", "Želim", "sarmu."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cd190679-f6ec-589c-ae97-af6f96b5ceaf', 'listening', 'Прослухайте і складіть фразу', 'Može, i malo maslina.', '["Može,", "malo", "i", "maslina."]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4fc17472-8de8-5a7f-b123-a0ea29d77a75', 'listening', 'Прослухайте і складіть фразу', 'A u Slavoniji?', '["Slavoniji?", "A", "u"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9c4f7a1e-3ce5-5f4d-b5a7-f680a4dac39c', 'speaking', 'Яка у вас фірмова страва?', 'Koji je vaš specijalitet?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '340a9877-36f9-5a3f-9ccc-a952a1132b4d', 'speaking', 'Це найкраща страва.', 'Ovo je najbolje jelo.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('792f97a8-edd2-5495-958c-a2d9254e8f70', v_lesson, 'У конобі', 'U konobi', 3941, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('a17d8e61-508d-5fa6-9f76-b06a795db2b6', '792f97a8-edd2-5495-958c-a2d9254e8f70', 'Konobar', 'Dobra večer! Danas je specijalitet kuće peka od hobotnice.', 'Добрий вечір! Сьогодні фірмова страва — пека з восьминога.', 1);
  perform pg_temp.turn('de3359e7-70ad-552f-9eb8-eeb9e34d0e25', '792f97a8-edd2-5495-958c-a2d9254e8f70', 'Daša', 'Peka zvuči odlično. Koliko se čeka?', 'Пека звучить чудово. Скільки чекати?', 2);
  perform pg_temp.turn('f00b66a2-a372-51ac-b3a2-258e67a0249d', '792f97a8-edd2-5495-958c-a2d9254e8f70', 'Konobar', 'Oko sat vremena. Za početak preporučujem pršut i paški sir.', 'Близько години. Для початку раджу пршут і паґський сир.', 3);
  perform pg_temp.turn('d4f258c4-e01b-5df7-8908-1f4ea979c642', '792f97a8-edd2-5495-958c-a2d9254e8f70', 'Daša', 'Može, i malo maslina.', 'Добре, і трохи оливок.', 4);
  perform pg_temp.turn('88c1c1a4-d729-5939-b78a-8557194c16a4', '792f97a8-edd2-5495-958c-a2d9254e8f70', 'Konobar', 'A kao prilog blitva s krumpirom?', 'А на гарнір мангольд з картоплею?', 5);
  perform pg_temp.turn('4cac6215-014d-5562-8233-6b62b36847bc', '792f97a8-edd2-5495-958c-a2d9254e8f70', 'Daša', 'Naravno, to je najbolji prilog!', 'Звісно, це найкращий гарнір!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('24c7d68c-9487-5ccc-afec-e5baec90bbbc', v_lesson, 'Що скуштувати?', 'Što probati?', 3942, 'A1', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('2a0781a9-a036-5bfb-b850-fbf98fdd4ff2', '24c7d68c-9487-5ccc-afec-e5baec90bbbc', 'Darja', 'Marko, što moram probati u Hrvatskoj?', 'Марко, що я маю скуштувати в Хорватії?', 1);
  perform pg_temp.turn('1f2a2e6c-79f6-5374-837e-b6f54cd3b1d5', '24c7d68c-9487-5ccc-afec-e5baec90bbbc', 'Marko', 'Ovisi o kraju. U Istri tartufe, u Dalmaciji pašticadu i crni rižot.', 'Залежить від краю. В Істрії — трюфелі, у Далмації — паштицаду й чорне різото.', 2);
  perform pg_temp.turn('371a0fb9-8d84-5916-a498-1e58b31e1d73', '24c7d68c-9487-5ccc-afec-e5baec90bbbc', 'Darja', 'A u Slavoniji?', 'А в Славонії?', 3);
  perform pg_temp.turn('f7ecfa96-9e43-5250-90a7-b2ec68ad5b3f', '24c7d68c-9487-5ccc-afec-e5baec90bbbc', 'Marko', 'Kulen i čobanac. Čobanac je ljući od gulaša!', 'Кулен і чобанац. Чобанац гостріший за гуляш!', 4);
  perform pg_temp.turn('a3919ba5-4dae-5985-8ce4-4dc77a9c3aae', '24c7d68c-9487-5ccc-afec-e5baec90bbbc', 'Darja', 'A koji je kolač najbolji?', 'А яке тістечко найкраще?', 5);
  perform pg_temp.turn('19620f07-05e0-5c35-b7d4-4e642e49be07', '24c7d68c-9487-5ccc-afec-e5baec90bbbc', 'Marko', 'Za mene samoborska kremšnita, ali probaj i fritule.', 'Для мене самоборська кремшніта, але скуштуй і фрітуле.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.11 · урок 95: Хорватські звичаї — перебудова: 15 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '2fabcd03-324d-5355-b96e-022723fbeda7';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Хорватські звичаї» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'c20e364e-301d-540e-8594-e82262cc1fe8') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 95: Хорватські звичаї', title_hr = 'Lekcija 95: Hrvatski običaji',
         objectives = '["Знати хорватські звичаї: ljubiti se u obraz, nazdraviti, častiti", "Поводитися в гостях і на каві", "Зворотні дієслова: rukuju se, ljube se, izuti se"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Зворотні дієслова: se' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Зворотні дієслова: se»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'običaj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tradicionalan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nazdraviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'živjeli', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gledati u oči', v_pos);
  v_pos := pg_temp.word(v_lesson, 'domaćica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nedjeljni ručak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'imendan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rukovati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ljubiti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'izuti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ići na kavu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'gostoljubiv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'častiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'red je', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f4f7f528-6111-5ace-9d8e-766f71a7e0c6', 'fill_in_the_blank', 'Prijatelji se ___ u obraz.', 'ljube', '["ljubiti", "ljube", "ljubimo se", "ljubi"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0fde8794-6876-5dc9-a461-80ae6f818779', 'multiple_choice', 'Що означає «red je»?', 'так годиться, так заведено', '["так годиться, так заведено", "господиня", "потиснути руку, привітатися за руку", "виголосити тост, цокнутися"]'::jsonb, 'A1', 2, 'PUBLISHED', 'red je', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a68599e9-b1c0-533e-b573-23d38c748548', 'multiple_choice', 'Що означає «nedjeljni ručak»?', 'недільний обід (з родиною)', '["потиснути руку, привітатися за руку", "недільний обід (з родиною)", "піти на каву (зустрітися з кимось)", "традиційний"]'::jsonb, 'A1', 3, 'PUBLISHED', 'nedjeljni ručak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '47c1ddbe-8bba-5654-a1a3-b83c684b0391', 'multiple_choice', 'Що означає «gostoljubiv»?', 'гостинний', '["будьмо! (тост)", "так годиться, так заведено", "недільний обід (з родиною)", "гостинний"]'::jsonb, 'A1', 4, 'PUBLISHED', 'gostoljubiv', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7698c4ce-31a7-5c5a-89fd-53fb9ed825b4', 'multiple_choice', 'Як хорватською «дивитися в очі»?', 'gledati u oči', '["domaćica", "ljubiti se", "častiti", "gledati u oči"]'::jsonb, 'A1', 5, 'PUBLISHED', 'gledati u oči', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '352a0333-27a7-5712-861b-109d6984be10', 'multiple_choice', 'Як хорватською «роззутися»?', 'izuti se', '["red je", "izuti se", "običaj", "imendan"]'::jsonb, 'A1', 6, 'PUBLISHED', 'izuti se', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1295bac5-96a6-5395-b526-8587a9167bd3', 'type_answer', 'Напишіть хорватською: «традиційний»', 'tradicionalan', null, 'A1', 7, 'PUBLISHED', 'tradicionalan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '456e52ee-98e8-5011-a171-d390945b98c4', 'type_answer', 'Напишіть хорватською: «господиня»', 'domaćica', null, 'A1', 8, 'PUBLISHED', 'domaćica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4d9ca1e3-8d2d-5e55-9498-b664a60d1b8a', 'type_answer', 'Напишіть хорватською: «цілуватися»', 'ljubiti se', null, 'A1', 9, 'PUBLISHED', 'ljubiti se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '60eb6550-52d7-5cb3-8db3-e993168137fa', 'sentence_builder', 'Складіть: «Сьогодні я пригощаю.»', 'Danas ja častim.', '["ja", "častim.", "Danas"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e8011d1-88a8-58ca-b87a-7a54984e29da', 'sentence_builder', 'Складіть: «Чоловіки тиснуть руки.»', 'Muškarci se rukuju.', '["se", "Muškarci", "rukuju."]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a8af202a-8e9d-5cec-9196-c865a94c138d', 'listening', 'Прослухайте і складіть фразу', 'Kako se ovdje ljudi pozdravljaju?', '["Kako", "ovdje", "ljudi", "pozdravljaju?", "se"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '63c17dd0-2999-5b4e-a5a4-968d5ce29489', 'listening', 'Прослухайте і складіть фразу', 'Dobro. A tko plaća kavu?', '["Dobro.", "kavu?", "plaća", "tko", "A"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6af46757-a6c9-55a9-83db-3fec0178f09b', 'speaking', 'Будьмо!', 'Živjeli!', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9b3ba582-5732-5c84-89ff-c9790e0377f0', 'speaking', 'З іменинами!', 'Sretan imendan!', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c20e364e-301d-540e-8594-e82262cc1fe8', v_lesson, 'У гостях', 'U gostima', 3951, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('ab2a6cad-b782-5b6a-bfc8-6022f8710fbf', 'c20e364e-301d-540e-8594-e82262cc1fe8', 'Ivana', 'Dašo, uđi! Ne moraš se izuti.', 'Дашо, заходь! Не треба роззуватися.', 1);
  perform pg_temp.turn('c8b89627-db94-53fa-a21a-6dd35769539f', 'c20e364e-301d-540e-8594-e82262cc1fe8', 'Daša', 'Hvala! Kod nas je običaj da se izujemo.', 'Дякую! У нас звичай роззуватися.', 2);
  perform pg_temp.turn('e8258719-4874-5f49-ab84-2d86394040bf', 'c20e364e-301d-540e-8594-e82262cc1fe8', 'Ivana', 'I kod nas, ali domaćica ti uvijek da papuče.', 'І в нас так, але господиня завжди дасть тобі тапочки.', 3);
  perform pg_temp.turn('4447a74d-e0d4-57f8-a4b2-5f9202817862', 'c20e364e-301d-540e-8594-e82262cc1fe8', 'Daša', 'Kako se ovdje ljudi pozdravljaju?', 'Як тут люди вітаються?', 4);
  perform pg_temp.turn('2db48632-6c6f-5ba0-987c-1e65ae566519', 'c20e364e-301d-540e-8594-e82262cc1fe8', 'Ivana', 'Muškarci se rukuju, a prijatelji se ljube dvaput u obraz.', 'Чоловіки тиснуть руки, а друзі цілуються двічі в щоку.', 5);
  perform pg_temp.turn('5657195a-78fb-5f2b-9c2d-71f478e327fd', 'c20e364e-301d-540e-8594-e82262cc1fe8', 'Daša', 'Dobro je znati!', 'Добре знати!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('690da125-5708-59bb-882a-892bb10ae381', v_lesson, 'Тост', 'Zdravica', 3952, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('0eefc0c5-78a3-58a3-9b8b-ee8ab49b2486', '690da125-5708-59bb-882a-892bb10ae381', 'Luka', 'Živjeli! Darja, gledaj me u oči kad nazdravljamo.', 'Будьмо! Даріє, дивись мені в очі, коли цокаємося.', 1);
  perform pg_temp.turn('e5cb95cc-28ea-5477-8872-9a7bf49df057', '690da125-5708-59bb-882a-892bb10ae381', 'Darja', 'Zašto?', 'Чому?', 2);
  perform pg_temp.turn('062f8d39-da06-564e-b120-37040d0f3833', '690da125-5708-59bb-882a-892bb10ae381', 'Luka', 'To je običaj, tako se pokazuje poštovanje.', 'Такий звичай, так показують повагу.', 3);
  perform pg_temp.turn('4b006601-21e1-5f6f-afd0-6143b0784c2d', '690da125-5708-59bb-882a-892bb10ae381', 'Darja', 'Dobro. A tko plaća kavu?', 'Добре. А хто платить за каву?', 4);
  perform pg_temp.turn('ee8206f5-5ba7-55fb-a864-eeb4c39c8fa9', '690da125-5708-59bb-882a-892bb10ae381', 'Luka', 'Danas ja častim, red je, imam imendan!', 'Сьогодні я пригощаю, так годиться — у мене іменини!', 5);
  perform pg_temp.turn('9aa8e648-3cec-5231-966e-fe5cbd1e4234', '690da125-5708-59bb-882a-892bb10ae381', 'Darja', 'Sretan imendan! U nedjelju dođi k nama na ručak.', 'З іменинами! У неділю приходь до нас на обід.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.11 · урок 96: Святкуємо: Різдво, Великдень — перебудова: 17 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := 'f67bd38c-a41c-51df-b9c0-081737600fce';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Святкуємо: Різдво, Великдень» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '1bac41e7-19ba-50c6-9735-0d3a5d94724a') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 96: Святкуємо: Різдво, Великдень', title_hr = 'Lekcija 96: Slavimo Božić i Uskrs',
         objectives = '["Розповісти про Різдво й Великдень: advent, jaslice, polnoćka, pisanica", "Розпитати про святкові звичаї", "Майбутній час: okitit ćemo, ići ćemo"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Майбутній час: ići ću, bit će' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Майбутній час: ići ću, bit će»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'advent', v_pos);
  v_pos := pg_temp.word(v_lesson, 'adventski vijenac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svijeća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'okititi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'božićno drvce', v_pos);
  v_pos := pg_temp.word(v_lesson, 'božićna kuglica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lampice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jaslice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polnoćka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Sveti Nikola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bakalar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'korizma', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Cvjetnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bojiti jaja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pisanica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'darivati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tradicija', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '5ce7e515-8f63-54b3-9e29-33e31cb530fd', 'fill_in_the_blank', 'Na Badnjak ___ jesti bakalar.', 'ćemo', '["bismo", "ćemo", "ste", "smo"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '66bf016c-1bb5-5edb-a738-63a0aa0a0e11', 'multiple_choice', 'Що означає «bojiti jaja»?', 'фарбувати яйця', '["фарбувати яйця", "дарувати; обдаровувати", "свічка", "адвентовий вінок"]'::jsonb, 'A1', 2, 'PUBLISHED', 'bojiti jaja', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd0b7320f-3461-56ff-bc48-0dffd4fc7c00', 'multiple_choice', 'Що означає «advent»?', 'адвент (час перед Різдвом)', '["адвент (час перед Різдвом)", "адвентовий вінок", "свічка", "традиція"]'::jsonb, 'A1', 3, 'PUBLISHED', 'advent', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0f05f719-acb3-5fce-a7f0-b25184cbed0f', 'multiple_choice', 'Що означає «polnoćka»?', 'опівнічна різдвяна меса', '["адвент (час перед Різдвом)", "свічка", "фарбувати яйця", "опівнічна різдвяна меса"]'::jsonb, 'A1', 4, 'PUBLISHED', 'polnoćka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1e286214-f279-5d75-9f33-3fb959fabc44', 'multiple_choice', 'Як хорватською «бакалар (сушена тріска)»?', 'bakalar', '["Cvjetnica", "tradicija", "pisanica", "bakalar"]'::jsonb, 'A1', 5, 'PUBLISHED', 'bakalar', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '11064ae8-cd30-57e2-b147-db9ef9155595', 'multiple_choice', 'Як хорватською «гірлянда, вогники»?', 'lampice', '["bojiti jaja", "Sveti Nikola", "jaslice", "lampice"]'::jsonb, 'A1', 6, 'PUBLISHED', 'lampice', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ba11ae5c-4146-5dd5-9f44-39664abfbf8b', 'type_answer', 'Напишіть хорватською: «дарувати; обдаровувати»', 'darivati', null, 'A1', 7, 'PUBLISHED', 'darivati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '85ffbec3-dc8a-58a8-b9cc-e2abfb905d15', 'type_answer', 'Напишіть хорватською: «традиція»', 'tradicija', null, 'A1', 8, 'PUBLISHED', 'tradicija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b61c1b7c-8fbd-5141-9256-1890e8dfe621', 'type_answer', 'Напишіть хорватською: «прикрасити (ялинку)»', 'okititi', null, 'A1', 9, 'PUBLISHED', 'okititi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '53ea567d-f1a9-5317-8a73-487607750d0f', 'sentence_builder', 'Складіть: «Ми прикрасимо ялинку.»', 'Okitit ćemo božićno drvce.', '["božićno", "drvce.", "ćemo", "Okitit"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0df0aa67-4ef6-544a-b5d2-f066f186e073', 'sentence_builder', 'Складіть: «Діти фарбуватимуть яйця.»', 'Djeca će bojiti jaja.', '["jaja.", "bojiti", "će", "Djeca"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bc414fa4-8186-5e18-a884-2f88f59a13ee', 'listening', 'Прослухайте і складіть фразу', 'A hoće li doći Sveti Nikola?', '["Sveti", "hoće", "doći", "A", "li", "Nikola?"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5ab9046c-c458-5c6c-83a1-6656bac3e071', 'listening', 'Прослухайте і складіть фразу', 'Hoćemo li bojiti jaja?', '["li", "jaja?", "bojiti", "Hoćemo"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1d67c120-b288-5808-bab7-1da3a6849d87', 'speaking', 'Веселого Різдва!', 'Sretan Božić!', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8f1cbf28-0cf1-5462-8340-aeeafb67ff81', 'speaking', 'Ми підемо на різдвяну месу.', 'Ići ćemo na polnoćku.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1bac41e7-19ba-50c6-9735-0d3a5d94724a', v_lesson, 'Перед Різдвом', 'Prije Božića', 3961, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('5c18fa76-6111-5664-9fe4-c3b4950b161e', '1bac41e7-19ba-50c6-9735-0d3a5d94724a', 'Filip', 'Mama, kada ćemo okititi božićno drvce?', 'Мамо, коли ми прикрасимо ялинку?', 1);
  perform pg_temp.turn('8e2bc11a-b62f-5c3d-9bc0-f4ecd4b16c3a', '1bac41e7-19ba-50c6-9735-0d3a5d94724a', 'Daša', 'Na Badnjak, kao i svi ovdje. Ti ćeš staviti kuglice i lampice.', 'На Святвечір, як усі тут. Ти почепиш кульки й гірлянду.', 2);
  perform pg_temp.turn('0a32a994-85b0-5a8b-a1d4-b0cbebf656e6', '1bac41e7-19ba-50c6-9735-0d3a5d94724a', 'Filip', 'A hoće li doći Sveti Nikola?', 'А Святий Миколай прийде?', 3);
  perform pg_temp.turn('12c81661-de95-5216-85fe-0631f317814d', '1bac41e7-19ba-50c6-9735-0d3a5d94724a', 'Daša', 'Hoće, šestog prosinca. Ostavi čizmicu na prozoru!', 'Прийде, шостого грудня. Залиш чобіток на вікні!', 4);
  perform pg_temp.turn('d3a07a98-33ba-51ca-a2f5-cb64039c4f32', '1bac41e7-19ba-50c6-9735-0d3a5d94724a', 'Filip', 'A što ćemo jesti na Badnjak?', 'А що ми їстимемо на Святвечір?', 5);
  perform pg_temp.turn('aaa5c882-20ca-5ddb-9369-28852510ff40', '1bac41e7-19ba-50c6-9735-0d3a5d94724a', 'Daša', 'Bakalar, a u ponoć ćemo ići na polnoćku.', 'Бакалар, а опівночі підемо на різдвяну месу.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d03bbb7f-6a68-5f80-96e4-7974ac685294', v_lesson, 'Великдень', 'Uskrs', 3962, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('fcafbdfe-93c1-5c3a-87c9-54d7be226f0e', 'd03bbb7f-6a68-5f80-96e4-7974ac685294', 'Darja', 'Ivana, kako se ovdje slavi Uskrs?', 'Іванно, як тут святкують Великдень?', 1);
  perform pg_temp.turn('98ef1d7d-c6c1-5a3f-8d54-93d2a8bd4df4', 'd03bbb7f-6a68-5f80-96e4-7974ac685294', 'Ivana', 'Prije Uskrsa je korizma, a tjedan prije je Cvjetnica.', 'Перед Великоднем — Великий піст, а за тиждень до нього — Квітна неділя.', 2);
  perform pg_temp.turn('e7600c1a-6c1b-57d4-a0c4-499873ae7c53', 'd03bbb7f-6a68-5f80-96e4-7974ac685294', 'Darja', 'Hoćemo li bojiti jaja?', 'Будемо фарбувати яйця?', 3);
  perform pg_temp.turn('b03b493c-d3a1-56ce-a830-2633ef29a418', 'd03bbb7f-6a68-5f80-96e4-7974ac685294', 'Ivana', 'Hoćemo! Djeca će napraviti pisanice.', 'Будемо! Діти зроблять писанки.', 4);
  perform pg_temp.turn('ad3f76f5-a381-5832-a6a6-1d2c422b536a', 'd03bbb7f-6a68-5f80-96e4-7974ac685294', 'Darja', 'A darivate li se?', 'А ви даруєте одне одному подарунки?', 5);
  perform pg_temp.turn('58482842-55e2-57d9-8035-e292d2aacb15', 'd03bbb7f-6a68-5f80-96e4-7974ac685294', 'Ivana', 'Malo, djeci darujemo slatkiše. To je lijepa tradicija.', 'Трохи, дітям даруємо солодощі. Це гарна традиція.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.11 · урок 97: Державні свята й неробочі дні — перебудова: 17 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '33c041a0-e71a-55c1-94c8-64941876c6d2';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Державні свята й неробочі дні» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '52acfc4f-77ed-5944-8d68-4989605da7da') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 97: Державні свята й неробочі дні', title_hr = 'Lekcija 97: Državni praznici i neradni dani',
         objectives = '["Знати державні свята й неробочі дні Хорватії", "Домовитися про роботу й вихідні перед святом", "Родовий у датах: tridesetog svibnja, petog kolovoza"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Родовий відмінок: основи' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Родовий відмінок: основи»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'državni praznik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neradni dan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Dan državnosti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Sveta tri kralja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Uskrsni ponedjeljak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Praznik rada', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Tijelovo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Dan antifašističke borbe', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Dan pobjede', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Velika Gospa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Svi sveti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Dan sjećanja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'Sveti Stjepan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'produženi vikend', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zastava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'himna', v_pos);
  v_pos := pg_temp.word(v_lesson, 'doček Nove godine', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ac3b1e20-d12f-5c0c-9a25-c9fd1618dd25', 'fill_in_the_blank', 'Dan državnosti je tridesetog ___.', 'svibnja', '["svibnjem", "svibanj", "svibnju", "svibnja"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6fa93449-0589-5dd7-9d18-e1c90f02e23d', 'multiple_choice', 'Що означає «Svi sveti»?', 'День усіх святих (1 листопада)', '["гімн", "державне свято", "День усіх святих (1 листопада)", "Великодній понеділок"]'::jsonb, 'A1', 2, 'PUBLISHED', 'Svi sveti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '90362fa7-4b61-5f4c-9c35-135ace2360c6', 'multiple_choice', 'Що означає «Sveti Stjepan»?', 'День святого Стефана (26 грудня)', '["зустріч Нового року", "Успіння Богородиці (15 серпня)", "прапор", "День святого Стефана (26 грудня)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'Sveti Stjepan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '09deecb9-0b83-56f0-b063-9a5b6cff196d', 'multiple_choice', 'Що означає «Dan antifašističke borbe»?', 'День антифашистської боротьби (22 червня)', '["довгі вихідні", "державне свято", "День антифашистської боротьби (22 червня)", "Успіння Богородиці (15 серпня)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'Dan antifašističke borbe', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b8282547-2f97-5598-88c6-a11da4c07fac', 'multiple_choice', 'Що означає «Dan državnosti»?', 'День державності (30 травня)', '["День державності (30 травня)", "зустріч Нового року", "Богоявлення (6 січня)", "Свято Тіла Христового (четвер)"]'::jsonb, 'A1', 5, 'PUBLISHED', 'Dan državnosti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1baba6d2-c98b-5451-a531-4926abdd2b16', 'multiple_choice', 'Що означає «Praznik rada»?', 'День праці (1 травня)', '["державне свято", "гімн", "довгі вихідні", "День праці (1 травня)"]'::jsonb, 'A1', 6, 'PUBLISHED', 'Praznik rada', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f5e98fca-2438-531a-b033-65b17dc33f1e', 'multiple_choice', 'Як хорватською «прапор»?', 'zastava', '["himna", "zastava", "produženi vikend", "Dan antifašističke borbe"]'::jsonb, 'A1', 7, 'PUBLISHED', 'zastava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '70f33a1c-4c80-5c05-9918-5de63744040b', 'multiple_choice', 'Як хорватською «Великодній понеділок»?', 'Uskrsni ponedjeljak', '["Sveta tri kralja", "Velika Gospa", "Uskrsni ponedjeljak", "himna"]'::jsonb, 'A1', 8, 'PUBLISHED', 'Uskrsni ponedjeljak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c1012f8d-6523-54e1-92d7-044858798ade', 'type_answer', 'Напишіть хорватською: «гімн»', 'himna', null, 'A1', 9, 'PUBLISHED', 'himna', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7e005f88-c948-5c37-a386-4a1da9779635', 'sentence_builder', 'Складіть: «Це неробочий день.»', 'To je neradni dan.', '["neradni", "dan.", "To", "je"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6141e50e-57b5-5393-815f-caa090ca42c7', 'sentence_builder', 'Складіть: «Магазини не працюють.»', 'Trgovine ne rade.', '["rade.", "ne", "Trgovine"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '256eb1da-e233-58a6-8405-902b6879e842', 'listening', 'Прослухайте і складіть фразу', 'A u kolovozu?', '["u", "kolovozu?", "A"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3ed508e7-8cee-5de2-a4cb-e185657b22d7', 'listening', 'Прослухайте і складіть фразу', 'Rade li trgovine prvog siječnja?', '["siječnja?", "trgovine", "li", "Rade", "prvog"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '606b4717-d289-59b7-b5ee-3b8b0a6be877', 'speaking', 'Щасливого Нового року!', 'Sretna Nova godina!', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fcf34253-199f-595c-8f96-ff557f45f54e', 'speaking', 'Ти працюєш у понеділок?', 'Radiš li u ponedjeljak?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('52acfc4f-77ed-5944-8d68-4989605da7da', v_lesson, 'Календар свят', 'Kalendar praznika', 3971, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('9a56cbf8-2e79-5486-b0bd-5de9f40d6f0d', '52acfc4f-77ed-5944-8d68-4989605da7da', 'Daša', 'Marko, radiš li tridesetog svibnja?', 'Марко, ти працюєш тридцятого травня?', 1);
  perform pg_temp.turn('40babc56-c1f9-54b0-a794-07aa1572f09a', '52acfc4f-77ed-5944-8d68-4989605da7da', 'Marko', 'Ne, to je Dan državnosti, neradni dan.', 'Ні, це День державності, неробочий день.', 2);
  perform pg_temp.turn('73e3d6f6-9175-5c38-897f-92e94370d918', '52acfc4f-77ed-5944-8d68-4989605da7da', 'Daša', 'A Tijelovo? Ono je uvijek u četvrtak.', 'А Тіла Христового? Воно завжди в четвер.', 3);
  perform pg_temp.turn('dd0a14b4-87e4-5862-99e6-2a1350228329', '52acfc4f-77ed-5944-8d68-4989605da7da', 'Marko', 'Onda uzmem petak i imam produženi vikend!', 'Тоді візьму п’ятницю, і в мене довгі вихідні!', 4);
  perform pg_temp.turn('0cca05e7-84b4-5b01-9def-16f1fd6b9d7a', '52acfc4f-77ed-5944-8d68-4989605da7da', 'Daša', 'A u kolovozu?', 'А в серпні?', 5);
  perform pg_temp.turn('2bf0a294-1e1d-5b42-9bfd-4d9830665977', '52acfc4f-77ed-5944-8d68-4989605da7da', 'Marko', 'Petog kolovoza je Dan pobjede, a petnaestog Velika Gospa.', 'П’ятого серпня — День перемоги, а п’ятнадцятого — Успіння Богородиці.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('79101ca6-8008-5d8e-998b-7e30d1ec5ea3', v_lesson, 'Новорічна ніч', 'Doček Nove godine', 3972, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('000fb726-1a48-5712-97f2-490dc461d4fc', '79101ca6-8008-5d8e-998b-7e30d1ec5ea3', 'Darja', 'Gdje ćete dočekati Novu godinu?', 'Де ви зустрічатимете Новий рік?', 1);
  perform pg_temp.turn('31ae4515-007c-5085-8cd7-89a44734946c', '79101ca6-8008-5d8e-998b-7e30d1ec5ea3', 'Ivana', 'Na trgu, bit će koncert i vatromet u ponoć.', 'На площі, буде концерт і феєрверк опівночі.', 2);
  perform pg_temp.turn('9988c67e-56ed-53d4-bbef-f1661287ed6b', '79101ca6-8008-5d8e-998b-7e30d1ec5ea3', 'Darja', 'Rade li trgovine prvog siječnja?', 'Магазини працюють першого січня?', 3);
  perform pg_temp.turn('40ec193a-ba40-5159-9fea-aa583df57e46', '79101ca6-8008-5d8e-998b-7e30d1ec5ea3', 'Ivana', 'Većina ne radi. Ni za Sve svete ni za Svetog Stjepana.', 'Більшість ні. Ні на День усіх святих, ні на Святого Стефана.', 4);
  perform pg_temp.turn('78362088-8185-5779-994e-8cfb174f8cbc', '79101ca6-8008-5d8e-998b-7e30d1ec5ea3', 'Darja', 'A Praznik rada?', 'А День праці?', 5);
  perform pg_temp.turn('f19dbb91-63eb-57e2-a69e-a226d0f5ae39', '79101ca6-8008-5d8e-998b-7e30d1ec5ea3', 'Ivana', 'Prvi svibnja je također neradni dan, mnogi idu na izlet.', 'Перше травня — теж неробочий день, багато хто їде на прогулянку.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- 3. Нові уроки модуля A1.11
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
   where l.id in ('d9ef1de4-f4db-590e-bafd-474f84c8e03f', 'f1b2093d-9699-59af-92b9-ed7bdf7fad49', '2fabcd03-324d-5355-b96e-022723fbeda7', 'f67bd38c-a41c-51df-b9c0-081737600fce', '33c041a0-e71a-55c1-94c8-64941876c6d2')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 10 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_order from (values ('d9ef1de4-f4db-590e-bafd-474f84c8e03f'::uuid, 1), ('f1b2093d-9699-59af-92b9-ed7bdf7fad49'::uuid, 2), ('2fabcd03-324d-5355-b96e-022723fbeda7'::uuid, 3), ('f67bd38c-a41c-51df-b9c0-081737600fce'::uuid, 4), ('33c041a0-e71a-55c1-94c8-64941876c6d2'::uuid, 5)) as t(id, o)
    join public.lessons l on l.id = t.id and l.order_index = t.o and l.unit_id = '1fb51162-343f-5587-89cf-d2594a3091db';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A1' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('d9ef1de4-f4db-590e-bafd-474f84c8e03f', 'f1b2093d-9699-59af-92b9-ed7bdf7fad49', '2fabcd03-324d-5355-b96e-022723fbeda7', 'f67bd38c-a41c-51df-b9c0-081737600fce', '33c041a0-e71a-55c1-94c8-64941876c6d2') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A1.11: % уроків з неправильним складом', v_bad; end if;
  if v_order <> 5 then raise exception 'Модуль A1.11: на своїх місцях % уроків з 5', v_order; end if;
  if v_titles > 0 then raise exception 'A1: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A1.11: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A1.11 — 5 уроків за темою (5 перебудовано, 0 нових)';
end $$;

commit;
