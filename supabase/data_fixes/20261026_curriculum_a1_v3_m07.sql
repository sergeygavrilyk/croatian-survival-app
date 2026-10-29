-- =====================================================================
-- Програма A1 v3 · модуль A1.7 «Комп’ютер, телефон та інтернет» · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_curriculum_a1_v3.py 7 (не редагуйте вручну).
--
-- Рішення власника 2026-10-21 / 2026-10-26: до 25 слів на урок — скільки потрібно темі, 90–95 % слів — нові для рівня,
-- діалоги під тему, частіше Даша / Дар’я; бета (PUBLISHED).
--   * Уроки 59–65: 3 наявних перебудовано, 4 нових. Слів у них: 104.
--     Кожен: 10–25 слів, 2 діалоги, 15 вправ, 15 хв.
--   * Нові слова й вирази: 43.
--   * Нові правила до тем: «Минулий час: radio sam, bila sam» (+2).
--   * Виправлено: bon — «ваучер поповнення (мобільного рахунку)»; odjaviti se — «виписатися; вийти (з акаунта)»; kliknuti — «клікнути, клацнути (мишкою)» (стара версія — у content_versions).
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

-- 1. Нові слова й вирази A1.7 (43; наявні не змінюються)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pametni telefon', 'pametni telefon', 'hr', 'phrase', 'A1', 'смартфон', 'collocation', '{"gender": "m"}'::jsonb, '["Na pametnom telefonu čitam vijesti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tipka', 'tipka', 'hr', 'noun', 'A1', 'кнопка, клавіша', 'core', '{"gender": "f"}'::jsonb, '["Pritisni tipku sa strane telefona."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('glasnoća', 'glasnoca', 'hr', 'noun', 'A1', 'гучність', 'core', '{"gender": "f"}'::jsonb, '["Smanji glasnoću, dijete spava."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('instalirati', 'instalirati', 'hr', 'verb', 'A1', 'встановити (програму), інсталювати', 'core', '{"aspect": "biasp", "present": {"1s": "instaliram", "2s": "instaliraš", "3s": "instalira"}}'::jsonb, '["Moram instalirati novu aplikaciju za banku."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('ponovno pokrenuti', 'ponovno pokrenuti', 'hr', 'phrase', 'A1', 'перезавантажити, перезапустити', 'collocation', '{"aspect": "pfv", "present": {"1s": "ponovno pokrenem", "2s": "ponovno pokreneš", "3s": "ponovno pokrene"}}'::jsonb, '["Ako računalo ne radi, ponovno ga pokreni."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('napuniti', 'napuniti', 'hr', 'verb', 'A1', 'зарядити; наповнити', 'core', '{"aspect": "pfv", "present": {"1s": "napunim", "2s": "napuniš", "3s": "napuni"}}'::jsonb, '["Moram napuniti mobitel prije puta."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pametni sat', 'pametni sat', 'hr', 'phrase', 'A1', 'смарт-годинник', 'collocation', '{"gender": "m"}'::jsonb, '["Pametni sat broji moje korake."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('adapter', 'adapter', 'hr', 'noun', 'A1', 'адаптер, перехідник', 'core', '{"gender": "m"}'::jsonb, '["Za ovu utičnicu trebaš adapter."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('futrola', 'futrola', 'hr', 'noun', 'A1', 'чохол', 'core', '{"gender": "f"}'::jsonb, '["Kupila sam novu futrolu za mobitel."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('zaštitno staklo', 'zastitno staklo', 'hr', 'phrase', 'A1', 'захисне скло (для екрана)', 'collocation', '{"gender": "n"}'::jsonb, '["Zaštitno staklo čuva ekran od ogrebotina."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('USB ključić', 'usb kljucic', 'hr', 'phrase', 'A1', 'флешка', 'collocation', '{"gender": "m"}'::jsonb, '["Prezentaciju imam na USB ključiću."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('operater', 'operater', 'hr', 'noun', 'A1', 'оператор (зв’язку)', 'core', '{"gender": "m"}'::jsonb, '["Koji mobilni operater imaš?"]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('paket podataka', 'paket podataka', 'hr', 'phrase', 'A1', 'пакет мобільного інтернету', 'collocation', '{"gender": "m"}'::jsonb, '["Kupila sam paket podataka od deset giga."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mobilni podaci', 'mobilni podaci', 'hr', 'phrase', 'A1', 'мобільний інтернет (дані)', 'collocation', '{"gender": "m_pl"}'::jsonb, '["Uključi mobilne podatke, ovdje nema wifija."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('neograničen', 'neogranicen', 'hr', 'adjective', 'A1', 'необмежений, безлімітний', 'core', '{"f": "neograničena", "n": "neograničeno"}'::jsonb, '["Imam neograničene pozive i poruke."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('roming', 'roming', 'hr', 'noun', 'A1', 'роумінг', 'core', '{"gender": "m"}'::jsonb, '["U Europskoj uniji roming se ne plaća posebno."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pokrivenost', 'pokrivenost', 'hr', 'noun', 'A1', 'покриття (мережі)', 'core', '{"gender": "f"}'::jsonb, '["Na otoku je pokrivenost signalom slaba."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('propušteni poziv', 'propusteni poziv', 'hr', 'phrase', 'A1', 'пропущений дзвінок', 'collocation', '{"gender": "m"}'::jsonb, '["Imaš tri propuštena poziva od mame."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('govorna pošta', 'govorna posta', 'hr', 'phrase', 'A1', 'голосова пошта', 'collocation', '{"gender": "f"}'::jsonb, '["Ostavila sam ti poruku na govornoj pošti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('prijenos broja', 'prijenos broja', 'hr', 'phrase', 'A1', 'перенесення номера (до іншого оператора)', 'collocation', '{"gender": "m"}'::jsonb, '["Prijenos broja traje jedan dan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('adresa e-pošte', 'adresa e-poste', 'hr', 'phrase', 'A1', 'адреса електронної пошти', 'collocation', '{"gender": "f"}'::jsonb, '["Napišite svoju adresu e-pošte tiskanim slovima."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('predmet', 'predmet', 'hr', 'noun', 'A1', 'тема (листа); предмет', 'core', '{"gender": "m"}'::jsonb, '["U predmet napiši «Ponuda za stan»."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('neželjena pošta', 'nezeljena posta', 'hr', 'phrase', 'A1', 'спам', 'collocation', '{"gender": "f"}'::jsonb, '["Mail je završio u neželjenoj pošti."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('nepročitan', 'neprocitan', 'hr', 'adjective', 'A1', 'непрочитаний', 'core', '{"f": "nepročitana", "n": "nepročitano"}'::jsonb, '["Imam dvadeset nepročitanih poruka."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pošiljatelj', 'posiljatelj', 'hr', 'noun', 'A1', 'відправник', 'core', '{"gender": "m"}'::jsonb, '["Ne otvaraj privitak ako ne znaš pošiljatelja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('primatelj', 'primatelj', 'hr', 'noun', 'A1', 'одержувач', 'core', '{"gender": "m"}'::jsonb, '["Provjeri adresu primatelja prije slanja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('korisnički račun', 'korisnicki racun', 'hr', 'phrase', 'A1', 'обліковий запис, акаунт', 'collocation', '{"gender": "m"}'::jsonb, '["Za kupnju trebaš otvoriti korisnički račun."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('unijeti', 'unijeti', 'hr', 'verb', 'A1', 'ввести (дані); внести', 'core', '{"aspect": "pfv", "present": {"1s": "unesem", "2s": "uneseš", "3s": "unese"}}'::jsonb, '["Unesite lozinku i kliknite «Prijava»."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('resetirati', 'resetirati', 'hr', 'verb', 'A1', 'скинути (пароль), перезавантажити', 'core', '{"aspect": "biasp", "present": {"1s": "resetiram", "2s": "resetiraš", "3s": "resetira"}}'::jsonb, '["Lozinku možete resetirati preko maila."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('kod za potvrdu', 'kod za potvrdu', 'hr', 'phrase', 'A1', 'код підтвердження', 'collocation', '{"gender": "m"}'::jsonb, '["Kod za potvrdu stiže SMS-om."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('potvrda u dva koraka', 'potvrda u dva koraka', 'hr', 'phrase', 'A1', 'двоетапна перевірка', 'collocation', '{"gender": "f"}'::jsonb, '["Uključi potvrdu u dva koraka, sigurnije je."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('sigurnosno pitanje', 'sigurnosno pitanje', 'hr', 'phrase', 'A1', 'контрольне (секретне) питання', 'collocation', '{"gender": "n"}'::jsonb, '["Sigurnosno pitanje je ime mog prvog psa."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('e-Građani', 'e-gradani', 'hr', 'noun', 'A1', 'е-Громадяни (державний портал Хорватії)', 'core', '{"gender": "m_pl"}'::jsonb, '["Potvrdu o prebivalištu možeš preuzeti u e-Građanima."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('internetsko bankarstvo', 'internetsko bankarstvo', 'hr', 'phrase', 'A1', 'інтернет-банкінг', 'collocation', '{"gender": "n"}'::jsonb, '["Račune plaćam internetskim bankarstvom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('mobilni token', 'mobilni token', 'hr', 'phrase', 'A1', 'мобільний токен (для входу)', 'collocation', '{"gender": "m"}'::jsonb, '["Za prijavu u e-Građane koristim mobilni token banke."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('e-naručivanje', 'e-narucivanje', 'hr', 'noun', 'A1', 'онлайн-запис (до лікаря, в установу)', 'core', '{"gender": "n"}'::jsonb, '["Pregled kod specijalista dogovorila sam preko e-naručivanja."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('elektronički potpis', 'elektronicki potpis', 'hr', 'phrase', 'A1', 'електронний підпис', 'collocation', '{"gender": "m"}'::jsonb, '["Ugovor možete potpisati elektroničkim potpisom."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('certifikat', 'certifikat', 'hr', 'noun', 'A1', 'сертифікат', 'core', '{"gender": "m"}'::jsonb, '["Na osobnoj iskaznici je certifikat za prijavu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('učitati', 'ucitati', 'hr', 'verb', 'A1', 'завантажити (на сайт)', 'core', '{"aspect": "pfv", "present": {"1s": "učitam", "2s": "učitaš", "3s": "učita"}}'::jsonb, '["Učitajte sken putovnice u PDF-u."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('pretraživati', 'pretrazivati', 'hr', 'verb', 'A1', 'шукати (в інтернеті)', 'core', '{"aspect": "ipfv", "present": {"1s": "pretražujem", "2s": "pretražuješ", "3s": "pretražuje"}}'::jsonb, '["Pretražujem oglase za stan."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('tražilica', 'trazilica', 'hr', 'noun', 'A1', 'пошуковик, рядок пошуку', 'core', '{"gender": "f"}'::jsonb, '["Upiši naziv ureda u tražilicu."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('web-stranica', 'web-stranica', 'hr', 'noun', 'A1', 'вебсайт', 'core', '{"gender": "f"}'::jsonb, '["Radno vrijeme piše na web-stranici."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('digitalni', 'digitalni', 'hr', 'adjective', 'A1', 'цифровий', 'core', '{"f": "digitalna", "n": "digitalno"}'::jsonb, '["Recept je sada digitalni."]'::jsonb, 'PUBLISHED', 'claude_curriculum_a1_v3')
on conflict do nothing;

-- 1б. Виправлені слова (3); повторний запуск нічого не змінює
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'bon' and ukrainian_translation = 'передплата (поповнення рахунку)' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'ваучер поповнення (мобільного рахунку)' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'odjaviti se' and ukrainian_translation = 'виписатися' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'виписатися; вийти (з акаунта)' where id = r.id;
  end loop;
end $$;
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = 'kliknuti' and ukrainian_translation = 'натиснути; клікнути' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія');
    update public.lexemes set ukrainian_translation = 'клікнути, клацнути (мишкою)' where id = r.id;
  end loop;
end $$;

-- 1а. Граматика A1.7: нові теми (0) і нові правила до наявних тем (2)
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Минулий час: radio sam, bila sam»'; end if;
  if exists (select 1 from public.grammar_rules where id = '933a9359-84ed-5868-8982-7dc186feda69') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('933a9359-84ed-5868-8982-7dc186feda69', v_topic, 'Короткі слова разом: Poslao sam ti ga', 'Якщо в реченні кілька коротких слів, вони стоять разом на другому місці в такому порядку: li → sam / si / smo / ste / su → кому? (mi, ti, mu, joj, nam, vam, im) → кого? що? (me, te, ga, je, ih) → se → je. Тобто je (3-тя особа від biti) — останнє: Mama mi ga je kupila.', 'Poslao sam ti ga. · Jesi li mu ga dao? · Mama mi ga je kupila.', '[{"hr": "Poslao sam ti ga jučer.", "ua": "Я надіслав тобі його вчора."}, {"hr": "Jesi li mu ga proslijedila?", "ua": "Ти переслала йому його?"}, {"hr": "Nisam ti ga obrisala.", "ua": "Я тобі його не видалила."}, {"hr": "Kolega mi ga je pokazao.", "ua": "Колега мені його показав."}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', '933a9359-84ed-5868-8982-7dc186feda69', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;
do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «Минулий час: radio sam, bila sam»'; end if;
  if exists (select 1 from public.grammar_rules where id = 'c8d83e8d-2521-510f-a90f-bcc544dc6159') then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ('c8d83e8d-2521-510f-a90f-bcc544dc6159', v_topic, 'Pisala sam і napisala sam', 'Вид дієслова в минулому, як в українській: недоконаний — процес або повтор (pisala sam mailove cijeli dan — писала), доконаний — результат (napisala sam mail — написала). Пари: slati — poslati, čitati — pročitati, mijenjati — promijeniti.', 'pisao sam (писав) · napisao sam (написав)', '[{"hr": "Cijelo jutro sam pisala mailove.", "ua": "Увесь ранок я писала листи."}, {"hr": "Napisala sam mail šefu.", "ua": "Я написала листа начальнику."}, {"hr": "Čitao sam poruke u tramvaju.", "ua": "Я читав повідомлення в трамваї."}, {"hr": "Jesi li pročitao moju poruku?", "ua": "Ти прочитав моє повідомлення?"}]'::jsonb,
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', 'c8d83e8d-2521-510f-a90f-bcc544dc6159', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.');
end $$;

-- 2. Перебудова наявних уроків модуля A1.7
-- A1.7 · урок 60: Магазин електроніки — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '31bbedca-4b51-5478-8513-df5cb996ffd9';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Магазин електроніки» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'd5586443-a55b-5511-bd81-4e35b455d408') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 60: Магазин електроніки', title_hr = 'Lekcija 60: Trgovina elektroničkom opremom',
         objectives = '["Купити техніку: laptop, slušalice, pametni sat", "Порівняти моделі: lakši, bolji, veća memorija", "Порівняння: lakši od, bolji nego"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Ступені порівняння' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Ступені порівняння»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'laptop', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tablet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pametni sat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slušalice', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bežični', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvučnik', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mikrofon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kabel', v_pos);
  v_pos := pg_temp.word(v_lesson, 'adapter', v_pos);
  v_pos := pg_temp.word(v_lesson, 'futrola', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaštitno staklo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'memorija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'USB ključić', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ekran', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ff783f74-c333-5d64-8c9c-8005477cefe7', 'fill_in_the_blank', 'Ovaj laptop je ___ od onog.', 'lakši', '["lak", "lakši", "najlakši", "lagan"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c2deb70c-df53-5205-97a1-e4a27f066909', 'multiple_choice', 'Що означає «ekran»?', 'екран; дисплей', '["екран; дисплей", "чохол", "флешка", "навушники"]'::jsonb, 'A1', 2, 'PUBLISHED', 'ekran', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2b538b68-31fd-591c-9990-604eabb8d55b', 'multiple_choice', 'Що означає «memorija»?', 'пам''ять', '["кабель", "ноутбук", "адаптер, перехідник", "пам''ять"]'::jsonb, 'A1', 3, 'PUBLISHED', 'memorija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8e8262c5-b6cf-5921-a6db-82a6549f14f0', 'multiple_choice', 'Що означає «mikrofon»?', 'мікрофон', '["мікрофон", "ноутбук", "смарт-годинник", "чохол"]'::jsonb, 'A1', 4, 'PUBLISHED', 'mikrofon', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fe19bbf5-9fae-5af6-9716-4a47a6bab4f5', 'multiple_choice', 'Як хорватською «адаптер, перехідник»?', 'adapter', '["zvučnik", "tablet", "adapter", "memorija"]'::jsonb, 'A1', 5, 'PUBLISHED', 'adapter', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c235cb9e-9b75-5b08-8418-bba71612891e', 'multiple_choice', 'Як хорватською «бездротовий»?', 'bežični', '["tablet", "bežični", "ekran", "futrola"]'::jsonb, 'A1', 6, 'PUBLISHED', 'bežični', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f1e8ed3e-5607-516a-9f5c-51b357af7fdf', 'type_answer', 'Напишіть хорватською: «планшет»', 'tablet', null, 'A1', 7, 'PUBLISHED', 'tablet', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f3334050-8722-566c-b71c-f0e7c300c199', 'type_answer', 'Напишіть хорватською: «чохол»', 'futrola', null, 'A1', 8, 'PUBLISHED', 'futrola', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'db1d0c28-587f-577a-a88b-c3248dc49251', 'type_answer', 'Напишіть хорватською: «динамік»', 'zvučnik', null, 'A1', 9, 'PUBLISHED', 'zvučnik', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3e79ab26-cd9c-58d2-acaf-0dfcb6ca3f15', 'sentence_builder', 'Складіть: «Цей екран кращий.»', 'Ovaj ekran je bolji.', '["ekran", "bolji.", "je", "Ovaj"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1e1622c9-18b1-5805-a2a2-f9e2578b1013', 'sentence_builder', 'Складіть: «Мені потрібні бездротові навушники.»', 'Trebam bežične slušalice.', '["slušalice.", "Trebam", "bežične"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '419530fe-042d-5508-a6d9-a21f439bad97', 'listening', 'Прослухайте і складіть фразу', 'Koji ima bolji ekran?', '["Koji", "ima", "ekran?", "bolji"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bf07938c-9132-5534-b9e7-73b4688df791', 'listening', 'Прослухайте і складіть фразу', 'Moj sin želi i pametni sat.', '["sin", "i", "pametni", "Moj", "želi", "sat."]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e3245651-b63b-548e-a6cb-6f0d792ec9aa', 'speaking', 'Я шукаю ноутбук.', 'Tražim laptop.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e84d648e-6f26-5ffc-8208-44ff5791f01b', 'speaking', 'Який кращий?', 'Koji je bolji?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d5586443-a55b-5511-bd81-4e35b455d408', v_lesson, 'Ноутбук для навчання', 'Laptop za školu', 3601, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('1bc7eac6-8270-52fa-945f-825345e1bca6', 'd5586443-a55b-5511-bd81-4e35b455d408', 'Daša', 'Dobar dan, tražim laptop za kćer, za školu.', 'Добрий день, я шукаю ноутбук для доньки, для навчання.', 1);
  perform pg_temp.turn('cb942ab1-7177-58bc-875e-45dd7038ba31', 'd5586443-a55b-5511-bd81-4e35b455d408', 'Prodavač', 'Ovaj je lakši, a ovaj ima veću memoriju.', 'Цей легший, а в цього більша пам’ять.', 2);
  perform pg_temp.turn('c56acbcc-4ab5-5dae-8958-9be17777b81f', 'd5586443-a55b-5511-bd81-4e35b455d408', 'Daša', 'Koji ima bolji ekran?', 'У якого кращий екран?', 3);
  perform pg_temp.turn('50ed039b-05f9-5bbe-8de4-66db9c54a327', 'd5586443-a55b-5511-bd81-4e35b455d408', 'Prodavač', 'Drugi, i baterija mu traje duže.', 'У другого, і батарея в нього тримає довше.', 4);
  perform pg_temp.turn('88148ee9-e202-5f6d-a0fe-5687791b74bb', 'd5586443-a55b-5511-bd81-4e35b455d408', 'Daša', 'Dobro, uzimam njega. Treba li mi adapter?', 'Добре, беру його. Мені потрібен перехідник?', 5);
  perform pg_temp.turn('668b5691-b2fa-5378-9e91-b820a3e67522', 'd5586443-a55b-5511-bd81-4e35b455d408', 'Prodavač', 'Ne treba, kabel je u kutiji.', 'Не потрібен, кабель у коробці.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ae56c2e4-4769-527b-840a-2c0a9ef6f8f8', v_lesson, 'Подарунок синові', 'Poklon za sina', 3602, 'A1', 'shopping', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('350b4e23-4026-51e7-9c66-59fddb34aab2', 'ae56c2e4-4769-527b-840a-2c0a9ef6f8f8', 'Marko', 'Imate li bežične slušalice s mikrofonom?', 'У вас є бездротові навушники з мікрофоном?', 1);
  perform pg_temp.turn('8b7d501d-86e7-5332-abcd-78c97a656203', 'ae56c2e4-4769-527b-840a-2c0a9ef6f8f8', 'Prodavačica', 'Imamo, ove su jeftinije od onih.', 'Є, ці дешевші за ті.', 2);
  perform pg_temp.turn('6cd21eb9-d787-55e9-b6db-52d65ea0bea7', 'ae56c2e4-4769-527b-840a-2c0a9ef6f8f8', 'Marko', 'Moj sin želi i pametni sat.', 'Мій син хоче ще й смарт-годинник.', 3);
  perform pg_temp.turn('7740b9c3-3eb3-5027-bcdd-5abcf2acc184', 'ae56c2e4-4769-527b-840a-2c0a9ef6f8f8', 'Prodavačica', 'Uz sat dobijete futrolu i zaštitno staklo na poklon.', 'До годинника ви отримаєте в подарунок чохол і захисне скло.', 4);
  perform pg_temp.turn('a3540baa-764a-50b8-868f-3b401733a09a', 'ae56c2e4-4769-527b-840a-2c0a9ef6f8f8', 'Marko', 'Super. A mali zvučnik za tablet?', 'Чудово. А маленький динамік для планшета?', 5);
  perform pg_temp.turn('ee40d353-6b45-50e4-ac97-0ca9f235ed6c', 'ae56c2e4-4769-527b-840a-2c0a9ef6f8f8', 'Prodavačica', 'Na polici pored USB ključića.', 'На полиці біля флешок.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 61: Мобільний зв’язок — перебудова: 16 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '35203547-5f9a-5857-95a0-3a0d596f715d';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Мобільний зв’язок» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = '33c49164-729b-5d67-bcb8-f16f8edd2e31') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 61: Мобільний зв’язок', title_hr = 'Lekcija 61: Mobilna mreža',
         objectives = '["Обрати тариф і пакет інтернету", "Запитати про роумінг, покриття й перенесення номера", "Питання: Koliko košta…? Ima li…? Mogu li…?"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Побудова питань' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Побудова питань»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'operater', v_pos);
  v_pos := pg_temp.word(v_lesson, 'SIM kartica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tarifa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zvati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'paket podataka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mobilni podaci', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neograničen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'roming', v_pos);
  v_pos := pg_temp.word(v_lesson, 'signal', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pokrivenost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'broj mobitela', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poziv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'propušteni poziv', v_pos);
  v_pos := pg_temp.word(v_lesson, 'govorna pošta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prijenos broja', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ecd98f8f-7287-5116-be31-b4a8b02672e5', 'fill_in_the_blank', '___ košta ova tarifa?', 'Koliko', '["Kolika", "Koliko", "Koja", "Kakva"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '04d73de3-1ea8-5545-8728-ab071f982ca1', 'multiple_choice', 'Що означає «govorna pošta»?', 'голосова пошта', '["сигнал", "необмежений, безлімітний", "голосова пошта", "перенесення номера (до іншого оператора)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'govorna pošta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '46f5ef5c-2a42-564f-abe0-c14ffb11f8f2', 'multiple_choice', 'Що означає «SIM kartica»?', 'SIM-картка', '["SIM-картка", "дзвінок / запрошення", "дзвонити; кликати", "перенесення номера (до іншого оператора)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'SIM kartica', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'db5e42eb-8493-5055-a867-6ca1e0465ebc', 'multiple_choice', 'Що означає «bon»?', 'ваучер поповнення (мобільного рахунку)', '["дзвонити; кликати", "необмежений, безлімітний", "мобільний інтернет (дані)", "ваучер поповнення (мобільного рахунку)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'bon', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a1dc445c-2942-50c4-ad7a-34be41bcff1d', 'multiple_choice', 'Як хорватською «оператор (зв’язку)»?', 'operater', '["tarifa", "operater", "SIM kartica", "bon"]'::jsonb, 'A1', 5, 'PUBLISHED', 'operater', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c508e127-dbff-57ce-80b0-bba98d2b82ad', 'multiple_choice', 'Як хорватською «сигнал»?', 'signal', '["mobilni podaci", "paket podataka", "operater", "signal"]'::jsonb, 'A1', 6, 'PUBLISHED', 'signal', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c867e0a7-2e50-5dd8-a5ec-06f86bb5c4e1', 'type_answer', 'Напишіть хорватською: «тариф»', 'tarifa', null, 'A1', 7, 'PUBLISHED', 'tarifa', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e0acfcc3-8da6-5912-aeb6-1a3080534c22', 'type_answer', 'Напишіть хорватською: «роумінг»', 'roming', null, 'A1', 8, 'PUBLISHED', 'roming', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b8148c3-5ab3-5f8f-bcc9-d2ed1d684337', 'type_answer', 'Напишіть хорватською: «необмежений, безлімітний»', 'neograničen', null, 'A1', 9, 'PUBLISHED', 'neograničen', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '11455093-55f4-5737-8062-57c0b8210aeb', 'sentence_builder', 'Складіть: «Тут немає сигналу.»', 'Ovdje nema signala.', '["signala.", "Ovdje", "nema"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fd533de4-e021-540e-a30b-5b5446930927', 'sentence_builder', 'Складіть: «Увімкни мобільний інтернет.»', 'Uključi mobilne podatke.', '["podatke.", "mobilne", "Uključi"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7c68f0fe-66f6-57ae-9e18-c6c7808fcdca', 'listening', 'Прослухайте і складіть фразу', 'Želite li bonove ili mjesečnu tarifu?', '["tarifu?", "li", "mjesečnu", "bonove", "ili", "Želite"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '759acee6-54f4-5b40-84c1-6ed5fd876556', 'listening', 'Прослухайте і складіть фразу', 'Nisam, na otoku nema signala.', '["na", "signala.", "nema", "otoku", "Nisam,"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e3a3df41-6c1d-5e3b-b953-1f28a3026e04', 'speaking', 'Мені потрібна SIM-картка.', 'Trebam SIM karticu.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2e13d93c-dd19-5f7b-82d8-3dea2a64a2d2', 'speaking', 'Роумінг платний?', 'Plaća li se roming?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('33c49164-729b-5d67-bcb8-f16f8edd2e31', v_lesson, 'У салоні зв’язку', 'Kod operatera', 3611, 'A1', 'it_work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('0011ac4e-a63b-56f9-9a8a-631603555834', '33c49164-729b-5d67-bcb8-f16f8edd2e31', 'Daša', 'Dobar dan, trebam SIM karticu s hrvatskim brojem.', 'Добрий день, мені потрібна SIM-картка з хорватським номером.', 1);
  perform pg_temp.turn('c2dc8cd5-145c-5aca-84b0-75a1f14267ea', '33c49164-729b-5d67-bcb8-f16f8edd2e31', 'Prodavač', 'Želite li bonove ili mjesečnu tarifu?', 'Хочете поповнення ваучерами чи місячний тариф?', 2);
  perform pg_temp.turn('58ec502a-a810-5623-a477-81ecbeb5787e', '33c49164-729b-5d67-bcb8-f16f8edd2e31', 'Daša', 'Tarifu. Koliko košta paket s neograničenim pozivima?', 'Тариф. Скільки коштує пакет з безлімітними дзвінками?', 3);
  perform pg_temp.turn('e1389de6-6115-58bf-acdb-33f030a3946f', '33c49164-729b-5d67-bcb8-f16f8edd2e31', 'Prodavač', 'Petnaest eura mjesečno, s dvadeset giga podataka.', 'П’ятнадцять євро на місяць, з двадцятьма гігабайтами.', 4);
  perform pg_temp.turn('0138d535-f9c7-566c-b62e-74d3fc1763c6', '33c49164-729b-5d67-bcb8-f16f8edd2e31', 'Daša', 'Plaća li se roming u Ukrajini?', 'Роумінг в Україні платний?', 5);
  perform pg_temp.turn('7b7bd8ad-50ed-5c54-ae3d-b36a8bfab996', '33c49164-729b-5d67-bcb8-f16f8edd2e31', 'Prodavač', 'Plaća, ali možete kupiti poseban paket podataka.', 'Платний, але можна купити окремий пакет інтернету.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('4028e7eb-ff21-51b3-83fa-b4a998804b64', v_lesson, 'Немає сигналу', 'Nema signala', 3612, 'A1', 'it_work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('e573b98b-0a4d-5b9e-b0d4-0bc322668a96', '4028e7eb-ff21-51b3-83fa-b4a998804b64', 'Luka', 'Zvao sam te tri puta. Jesi li vidjela propuštene pozive?', 'Я дзвонив тобі тричі. Ти бачила пропущені дзвінки?', 1);
  perform pg_temp.turn('681dce4a-4d85-5f18-92ca-1d855dd704c2', '4028e7eb-ff21-51b3-83fa-b4a998804b64', 'Darja', 'Nisam, na otoku nema signala.', 'Ні, на острові немає сигналу.', 2);
  perform pg_temp.turn('315b4d1e-95e4-5556-b4d1-7266551e56a6', '4028e7eb-ff21-51b3-83fa-b4a998804b64', 'Luka', 'Ostavio sam ti poruku na govornoj pošti.', 'Я залишив тобі повідомлення на голосовій пошті.', 3);
  perform pg_temp.turn('677bdd54-87f8-5cd5-b2b9-19e51d910014', '4028e7eb-ff21-51b3-83fa-b4a998804b64', 'Darja', 'Pokrivenost je ovdje loša. Mijenjam operatera.', 'Покриття тут погане. Я міняю оператора.', 4);
  perform pg_temp.turn('d7771396-7b19-5f53-8a63-abdba38e5ebb', '4028e7eb-ff21-51b3-83fa-b4a998804b64', 'Luka', 'Hoćeš li zadržati broj mobitela?', 'Ти збережеш номер мобільного?', 5);
  perform pg_temp.turn('5afdbc96-3077-5a73-8fe9-e7cc65d9b847', '4028e7eb-ff21-51b3-83fa-b4a998804b64', 'Darja', 'Hoću, prijenos broja je besplatan.', 'Так, перенесення номера безкоштовне.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 65: Соцмережі — перебудова: 14 слів, 2 нові діалоги, 15 вправ
do $$
declare
  v_lesson constant uuid := '4edd1556-f088-5d14-8f59-529b35747609';
  v_gid uuid;
  v_pos int := 0;
  v_payload jsonb;
begin
  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «Соцмережі» не знайдено'; end if;
  if exists (select 1 from public.conversations where id = 'fe9e7ea9-534e-5a31-9074-a7cc3193edea') then return; end if;  -- уже перебудовано
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
  update public.lessons set title_ua = 'Урок 65: Соцмережі', title_hr = 'Lekcija 65: Društvene mreže',
         objectives = '["Поговорити про соцмережі: objava, komentar, pratitelji", "Розповісти, що ви опублікували чи побачили", "Минулий час: objavila sam, jesi li vidio"]'::jsonb, estimated_minutes = 15 where id = v_lesson;
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Минулий час: radio sam, bila sam»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'društvene mreže', v_pos);
  v_pos := pg_temp.word(v_lesson, 'profil', v_pos);
  v_pos := pg_temp.word(v_lesson, 'objava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'objaviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'komentar', v_pos);
  v_pos := pg_temp.word(v_lesson, 'komentirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dijeliti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grupa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pratitelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'video', v_pos);
  v_pos := pg_temp.word(v_lesson, 'snimiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vijest', v_pos);
  v_pos := pg_temp.word(v_lesson, 'privatan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'javan', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '5b218ea7-daa8-50db-b0af-141d74af3f4d', 'fill_in_the_blank', 'Jučer sam ___ video na profil.', 'stavila', '["staviti", "stavila", "stavljati", "stavim"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd6d6e633-e67c-5126-82d4-a609209cddc6', 'multiple_choice', 'Що означає «snimiti»?', 'записати, зняти', '["коментар", "коментувати", "публікація", "записати, зняти"]'::jsonb, 'A1', 2, 'PUBLISHED', 'snimiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8bd3beb2-518b-5581-a219-ae0eaa5ec084', 'multiple_choice', 'Що означає «društvene mreže»?', 'соціальні мережі', '["опублікувати", "приватний", "новина", "соціальні мережі"]'::jsonb, 'A1', 3, 'PUBLISHED', 'društvene mreže', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '56b34db9-53fd-502a-9818-43215e1ca09b', 'multiple_choice', 'Що означає «grupa»?', 'група', '["група", "відео", "публікація", "коментувати"]'::jsonb, 'A1', 4, 'PUBLISHED', 'grupa', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '720eddec-f4e7-5c73-815e-bdad367fee5b', 'multiple_choice', 'Як хорватською «публічний»?', 'javan', '["javan", "video", "objava", "grupa"]'::jsonb, 'A1', 5, 'PUBLISHED', 'javan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fac67a52-d467-51c9-a415-5e07ff37ca29', 'multiple_choice', 'Як хорватською «приватний»?', 'privatan', '["snimiti", "profil", "grupa", "privatan"]'::jsonb, 'A1', 6, 'PUBLISHED', 'privatan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1b160453-7dfb-554b-90b9-c2f6cbc00805', 'type_answer', 'Напишіть хорватською: «новина»', 'vijest', null, 'A1', 7, 'PUBLISHED', 'vijest', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '02161738-10cd-5a5e-9d03-f648bc6fe43f', 'type_answer', 'Напишіть хорватською: «опублікувати»', 'objaviti', null, 'A1', 8, 'PUBLISHED', 'objaviti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c359dbb9-588f-520f-beaa-31c049354ed0', 'type_answer', 'Напишіть хорватською: «публікація»', 'objava', null, 'A1', 9, 'PUBLISHED', 'objava', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5eff1e38-7050-5929-96f8-e116e7f99c43', 'sentence_builder', 'Складіть: «Я опублікувала фото вчора.»', 'Objavila sam fotografiju jučer.', '["Objavila", "jučer.", "sam", "fotografiju"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e196dbcd-b01b-5d47-aa87-88b417093079', 'sentence_builder', 'Складіть: «Мій профіль приватний.»', 'Moj profil je privatan.', '["je", "profil", "privatan.", "Moj"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '66137172-6e13-563a-b478-c654ebd911dc', 'listening', 'Прослухайте і складіть фразу', 'Jesam! Snimila si ga na Plitvicama?', '["ga", "na", "Jesam!", "Snimila", "Plitvicama?", "si"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f0095278-3634-5931-b151-cece8ec2d265', 'listening', 'Прослухайте і складіть фразу', 'Ponekad, ali ne komentiram.', '["Ponekad,", "komentiram.", "ne", "ali"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8bda9f3c-ad32-5f4f-9b31-91a2af26ad17', 'speaking', 'Ти бачила моє відео?', 'Jesi li vidjela moj video?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b2cbca1b-2175-56ea-b645-e52841465800', 'speaking', 'Я поширила допис у групі.', 'Podijelila sam objavu u grupi.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('fe9e7ea9-534e-5a31-9074-a7cc3193edea', v_lesson, 'Ти бачила моє відео?', 'Jesi li vidjela moj video?', 3651, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('96d33e27-8496-5e4a-b987-eddbb893daa4', 'fe9e7ea9-534e-5a31-9074-a7cc3193edea', 'Ivana', 'Dašo, jesi li vidjela moj novi video?', 'Дашо, ти бачила моє нове відео?', 1);
  perform pg_temp.turn('08e5ec55-7b6c-5a12-8242-be44c382b064', 'fe9e7ea9-534e-5a31-9074-a7cc3193edea', 'Daša', 'Jesam! Snimila si ga na Plitvicama?', 'Так! Ти зняла його на Плітвіцях?', 2);
  perform pg_temp.turn('51f37e10-9849-5128-a2d8-b30cc4293198', 'fe9e7ea9-534e-5a31-9074-a7cc3193edea', 'Ivana', 'Da. Objavila sam ga jučer i već ima sto komentara.', 'Так. Я опублікувала його вчора, і вже сто коментарів.', 3);
  perform pg_temp.turn('fbc5e89f-94b7-52d0-9d14-146c4d040ba3', 'fe9e7ea9-534e-5a31-9074-a7cc3193edea', 'Daša', 'Podijelila sam ga u grupi Ukrajinci u Zagrebu.', 'Я поширила його в групі «Українці в Загребі».', 4);
  perform pg_temp.turn('c3a0b32d-aaf1-5cb5-ab1d-461d55ae60f0', 'fe9e7ea9-534e-5a31-9074-a7cc3193edea', 'Ivana', 'Hvala! Sad imam dvjesto novih pratitelja.', 'Дякую! Тепер у мене двісті нових підписників.', 5);
  perform pg_temp.turn('b84ca25a-67c8-5199-b2c3-33438e6e2d54', 'fe9e7ea9-534e-5a31-9074-a7cc3193edea', 'Daša', 'Super, ali tvoj profil je javan, pazi.', 'Чудово, але твій профіль публічний, обережно.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('58d6a6de-df60-52e6-80e5-c8212c63cf1c', v_lesson, 'Новини й коментарі', 'Vijesti i komentari', 3652, 'A1', 'small_talk', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('4578a026-ddeb-57cf-a2e2-e6d949c49a7d', '58d6a6de-df60-52e6-80e5-c8212c63cf1c', 'Marko', 'Čitaš li vijesti na društvenim mrežama?', 'Ти читаєш новини в соцмережах?', 1);
  perform pg_temp.turn('b7c6302d-c151-577b-98f9-2535b472373a', '58d6a6de-df60-52e6-80e5-c8212c63cf1c', 'Darja', 'Ponekad, ali ne komentiram.', 'Іноді, але не коментую.', 2);
  perform pg_temp.turn('76d8bd27-95bb-5c38-913f-9d7ca6e1d450', '58d6a6de-df60-52e6-80e5-c8212c63cf1c', 'Marko', 'Ja sam jučer napisao komentar i svi su me napali.', 'А я вчора написав коментар, і всі на мене накинулися.', 3);
  perform pg_temp.turn('fcc2f0ba-4137-598a-a5d4-91cbec9b6df1', '58d6a6de-df60-52e6-80e5-c8212c63cf1c', 'Darja', 'Zato je moj profil privatan.', 'Тому мій профіль приватний.', 4);
  perform pg_temp.turn('bd657a3c-c305-546d-9b5a-576eeff934a9', '58d6a6de-df60-52e6-80e5-c8212c63cf1c', 'Marko', 'Pametno. Što si zadnje objavila?', 'Розумно. Що ти останнє опублікувала?', 5);
  perform pg_temp.turn('9b056368-bf58-5ce7-93bb-8e5fc4a8979b', '58d6a6de-df60-52e6-80e5-c8212c63cf1c', 'Darja', 'Objavu o tečaju hrvatskog, tražim partnera za razgovor.', 'Допис про курси хорватської, шукаю партнера для розмов.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- 3. Нові уроки модуля A1.7
-- A1.7 · урок 59: Комп’ютер і телефон — новий урок: 17 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := 'f5b3441e-2c2a-52bf-825e-a316aae00588';
  v_lesson constant uuid := '8e08a8e3-8969-52fc-bc82-5a403dd7ad35';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A1.7: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 59: Комп’ютер і телефон', 'Lekcija 59: Računalo i mobitel', '["Назвати частини комп’ютера й телефону: tipkovnica, miš, ekran na dodir", "Пояснити, що натиснути й увімкнути", "Наказовий: klikni, uključi, ponovno pokreni"]'::jsonb, 15, 'PUBLISHED', 1);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Наказовий спосіб' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Наказовий спосіб»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'računalo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pametni telefon', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tipkovnica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'miš', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tipka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kliknuti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ekran na dodir', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dodirnuti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'postavke', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glasnoća', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ažuriranje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'instalirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ponovno pokrenuti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uključiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'isključiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'napuniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'baterija', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b7e4b71a-1e80-5236-8375-8cefe4001d16', 'fill_in_the_blank', '___ računalo i pričekaj minutu.', 'Isključi', '["Isključim", "Isključiti", "Isključi", "Isključen"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cc3b048f-bd9a-5037-a173-10e036f5d528', 'multiple_choice', 'Що означає «uključiti»?', 'увімкнути', '["торкнутися", "сенсорний екран", "увімкнути", "батарея / акумулятор"]'::jsonb, 'A1', 2, 'PUBLISHED', 'uključiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '34e6ecb3-6c90-54ac-b7d3-a434c44a25b0', 'multiple_choice', 'Що означає «tipka»?', 'кнопка, клавіша', '["миша", "оновлення", "кнопка, клавіша", "перезавантажити, перезапустити"]'::jsonb, 'A1', 3, 'PUBLISHED', 'tipka', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ee7a084f-9e83-530a-9e23-82981a581b79', 'multiple_choice', 'Що означає «baterija»?', 'батарея / акумулятор', '["увімкнути", "смартфон", "батарея / акумулятор", "кнопка, клавіша"]'::jsonb, 'A1', 4, 'PUBLISHED', 'baterija', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c989d16d-f925-5ef9-89f9-6e4f11fd11b5', 'multiple_choice', 'Як хорватською «комп''ютер»?', 'računalo', '["tipka", "računalo", "tipkovnica", "napuniti"]'::jsonb, 'A1', 5, 'PUBLISHED', 'računalo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '46936a7b-f2f7-58ed-a36e-01469228c436', 'multiple_choice', 'Як хорватською «смартфон»?', 'pametni telefon', '["napuniti", "baterija", "pametni telefon", "tipkovnica"]'::jsonb, 'A1', 6, 'PUBLISHED', 'pametni telefon', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eb03b0fe-5d68-56bb-9ee3-ac1d6456c498', 'type_answer', 'Напишіть хорватською: «налаштування»', 'postavke', null, 'A1', 7, 'PUBLISHED', 'postavke', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd92a6108-9340-55f9-8f0a-6592c2f4ac63', 'type_answer', 'Напишіть хорватською: «торкнутися»', 'dodirnuti', null, 'A1', 8, 'PUBLISHED', 'dodirnuti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '94584412-36e6-5884-937b-e84371a56af7', 'type_answer', 'Напишіть хорватською: «зарядити; наповнити»', 'napuniti', null, 'A1', 9, 'PUBLISHED', 'napuniti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5c8d0cab-d5f3-54a0-9836-6dfbd0cd96a1', 'sentence_builder', 'Складіть: «Натисни цю кнопку.»', 'Pritisni ovu tipku.', '["ovu", "tipku.", "Pritisni"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e6511aa6-0e24-5367-a5d3-05cf290033a5', 'sentence_builder', 'Складіть: «Спершу зарядь телефон.»', 'Prvo napuni mobitel.', '["mobitel.", "napuni", "Prvo"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cb52bab4-9482-5550-a0c9-854171822cbf', 'listening', 'Прослухайте і складіть фразу', 'Ništa se ne događa.', '["se", "Ništa", "ne", "događa."]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cc3d2473-943a-51b2-8130-77ba1af959f2', 'listening', 'Прослухайте і складіть фразу', 'Nisam. Gdje se to radi?', '["se", "to", "Nisam.", "radi?", "Gdje"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fe4f2b2a-5da6-5ebc-8422-fba2d1d74bbe', 'speaking', 'Як це вмикається?', 'Kako se ovo uključuje?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4292d742-c912-5afd-8bec-e4723d99a58e', 'speaking', 'Перезавантаж комп’ютер.', 'Ponovno pokreni računalo.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e6f6f9a6-bcbf-504a-ae13-4ce9a55e3f2b', v_lesson, 'Бабуся й смартфон', 'Baka i pametni telefon', 3591, 'A1', 'it_work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('694ab1c8-0cc8-597b-b376-feffab11a9a2', 'e6f6f9a6-bcbf-504a-ae13-4ce9a55e3f2b', 'Baka', 'Dašo, kako se ovo uključuje?', 'Дашо, як це вмикається?', 1);
  perform pg_temp.turn('297a32c4-d17a-50db-a719-7ec4ae966017', 'e6f6f9a6-bcbf-504a-ae13-4ce9a55e3f2b', 'Daša', 'Drži ovu tipku sa strane, bako.', 'Тримай цю кнопку збоку, бабусю.', 2);
  perform pg_temp.turn('26702471-4da1-5484-b59a-5bb0d7a97288', 'e6f6f9a6-bcbf-504a-ae13-4ce9a55e3f2b', 'Baka', 'Ništa se ne događa.', 'Нічого не відбувається.', 3);
  perform pg_temp.turn('4697ffb6-c9cc-51b6-8617-43330552b472', 'e6f6f9a6-bcbf-504a-ae13-4ce9a55e3f2b', 'Daša', 'Baterija je prazna. Prvo ga napuni.', 'Батарея розряджена. Спершу зарядь його.', 4);
  perform pg_temp.turn('8234140a-dc14-518c-b281-01c9b3250f52', 'e6f6f9a6-bcbf-504a-ae13-4ce9a55e3f2b', 'Baka', 'A kako se pojačava glasnoća?', 'А як зробити гучніше?', 5);
  perform pg_temp.turn('134e261a-8495-506a-bce7-86c31e90db28', 'e6f6f9a6-bcbf-504a-ae13-4ce9a55e3f2b', 'Daša', 'Dodirni ekran ovdje, u postavkama.', 'Торкнися екрана ось тут, у налаштуваннях.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('79ee2d97-3391-5ea1-a8b7-c5c45bd0f54a', v_lesson, 'Комп’ютер гальмує', 'Računalo je sporo', 3592, 'A1', 'it_work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('64f6b6cf-f2bd-5ce4-94fb-4340e37c6468', '79ee2d97-3391-5ea1-a8b7-c5c45bd0f54a', 'Luka', 'Darja, računalo mi je jako sporo.', 'Даріє, мій комп’ютер дуже гальмує.', 1);
  perform pg_temp.turn('22a5fd05-cce0-5a9a-8314-20bbafe78c3b', '79ee2d97-3391-5ea1-a8b7-c5c45bd0f54a', 'Darja', 'Jesi li instalirao ažuriranje?', 'Ти встановив оновлення?', 2);
  perform pg_temp.turn('93b08feb-ac62-5eec-a902-ac0e9b185cc5', '79ee2d97-3391-5ea1-a8b7-c5c45bd0f54a', 'Luka', 'Nisam. Gdje se to radi?', 'Ні. Де це робиться?', 3);
  perform pg_temp.turn('c215bf1b-9138-5dc5-83fe-6d2a1dd55698', '79ee2d97-3391-5ea1-a8b7-c5c45bd0f54a', 'Darja', 'Klikni mišem na postavke, pa na «Ažuriranje».', 'Клацни мишкою на налаштування, а потім на «Оновлення».', 4);
  perform pg_temp.turn('3ed0df8c-81cc-51aa-b66f-46e1e59c95ae', '79ee2d97-3391-5ea1-a8b7-c5c45bd0f54a', 'Luka', 'Piše da ga moram ponovno pokrenuti.', 'Пише, що його треба перезавантажити.', 5);
  perform pg_temp.turn('1093671b-4448-55b0-8de7-eb3e8b7e63bf', '79ee2d97-3391-5ea1-a8b7-c5c45bd0f54a', 'Darja', 'Onda ga pokreni, a tipkovnicu i miš ne diraj.', 'Тоді перезавантаж, а клавіатуру й мишку не чіпай.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A1 v3 (слова за темою, 2 діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 62: Електронна пошта й повідомлення — новий урок: 14 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := 'f5b3441e-2c2a-52bf-825e-a316aae00588';
  v_lesson constant uuid := '71537166-9f48-503f-b564-3a4f99a192c5';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A1.7: місце 4 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 62: Електронна пошта й повідомлення', 'Lekcija 62: E-pošta i poruke', '["Написати, переслати й зберегти лист: privitak, predmet, primatelj", "Запитати, чи отримали лист", "Минулий час: Jesi li dobio mail? Nisam ga primila."]'::jsonb, 15, 'PUBLISHED', 4);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Минулий час: radio sam, bila sam»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'adresa e-pošte', v_pos);
  v_pos := pg_temp.word(v_lesson, 'predmet', v_pos);
  v_pos := pg_temp.word(v_lesson, 'privitak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'datoteka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'poslati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'primiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'proslijediti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'spremiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obrisati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'neželjena pošta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nepročitan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pošiljatelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'primatelj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pročitati', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '3e0231ec-a71f-5d7c-9eee-c5494b5560c0', 'fill_in_the_blank', 'Jesi li ___ moj mail?', 'primio', '["primio", "primim", "primljen", "primiti"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '933ffea4-672a-525b-831a-c58062967fc0', 'multiple_choice', 'Що означає «pošiljatelj»?', 'відправник', '["спам", "надіслати / відправити", "відправник", "одержувач"]'::jsonb, 'A1', 2, 'PUBLISHED', 'pošiljatelj', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '591cd360-ce40-55ce-a09f-983382d14607', 'multiple_choice', 'Що означає «privitak»?', 'вкладення (в листі)', '["одержувач", "відправник", "отримати", "вкладення (в листі)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'privitak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cabefd3e-2bb5-5afa-b0c2-b50340a22e58', 'multiple_choice', 'Що означає «proslijediti»?', 'переслати', '["одержувач", "отримати", "переслати", "адреса електронної пошти"]'::jsonb, 'A1', 4, 'PUBLISHED', 'proslijediti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3ae10e36-e305-512e-a01c-7729655962a0', 'multiple_choice', 'Як хорватською «непрочитаний»?', 'nepročitan', '["nepročitan", "proslijediti", "pročitati", "spremiti"]'::jsonb, 'A1', 5, 'PUBLISHED', 'nepročitan', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8f72dbf9-c62e-5576-98d1-90943e928f66', 'multiple_choice', 'Як хорватською «спам»?', 'neželjena pošta', '["poslati", "neželjena pošta", "primatelj", "datoteka"]'::jsonb, 'A1', 6, 'PUBLISHED', 'neželjena pošta', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '579f234d-4fb4-527c-8d80-03d0f12aa2ac', 'type_answer', 'Напишіть хорватською: «видалити»', 'obrisati', null, 'A1', 7, 'PUBLISHED', 'obrisati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '00afa3aa-4569-52aa-8917-9c80a064bf6f', 'type_answer', 'Напишіть хорватською: «прочитати»', 'pročitati', null, 'A1', 8, 'PUBLISHED', 'pročitati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2a567951-7079-5065-80ab-6af7da681e35', 'type_answer', 'Напишіть хорватською: «зберегти»', 'spremiti', null, 'A1', 9, 'PUBLISHED', 'spremiti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a104071f-bbf2-5a21-9a02-3326381530f6', 'sentence_builder', 'Складіть: «Я не отримала лист.»', 'Nisam primila mail.', '["mail.", "primila", "Nisam"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '41d0a49b-fe80-57d7-86d9-7f9b2ce12608', 'sentence_builder', 'Складіть: «Ти переслав йому файл?»', 'Jesi li mu proslijedio datoteku?', '["mu", "datoteku?", "Jesi", "li", "proslijedio"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4dbdd9d5-c43f-588f-a67b-33c79351c27e', 'listening', 'Прослухайте і складіть фразу', 'Evo ga, završio je u neželjenoj pošti!', '["Evo", "neželjenoj", "ga,", "pošti!", "u", "je", "završio"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e46e233b-c96e-5fcf-8449-3e4404be5e58', 'listening', 'Прослухайте і складіть фразу', 'Ovaj pošiljatelj mi je nepoznat.', '["mi", "pošiljatelj", "Ovaj", "nepoznat.", "je"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '09d27108-bc68-5082-bb27-dca948d06d8f', 'speaking', 'Я надіслав тобі листа.', 'Poslao sam ti mail.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c6785b27-bf36-5145-b615-d315ae1330ac', 'speaking', 'Збережи вкладення.', 'Spremi privitak.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1b9c0ef1-47b4-5806-a751-bf2f1c83d967', v_lesson, 'Ти отримала лист?', 'Jesi li dobila mail?', 3621, 'A1', 'it_work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('40efc156-16f2-59d3-9e6b-c44b862da9f6', '1b9c0ef1-47b4-5806-a751-bf2f1c83d967', 'Luka', 'Dašo, jesi li primila moj mail?', 'Дашо, ти отримала мій лист?', 1);
  perform pg_temp.turn('fb573e7c-f8b5-52ad-990b-4d84fbd0485b', '1b9c0ef1-47b4-5806-a751-bf2f1c83d967', 'Daša', 'Nisam. Na koju adresu e-pošte si ga poslao?', 'Ні. На яку адресу пошти ти його надіслав?', 2);
  perform pg_temp.turn('a61bc1b2-0d18-50e0-b56c-5d8cb3abef41', '1b9c0ef1-47b4-5806-a751-bf2f1c83d967', 'Luka', 'Na tvoju poslovnu. Predmet je «Ugovor».', 'На твою робочу. Тема — «Договір».', 3);
  perform pg_temp.turn('e8474841-31bf-5df8-bca6-8bdbd8b85b87', '1b9c0ef1-47b4-5806-a751-bf2f1c83d967', 'Daša', 'Evo ga, završio je u neželjenoj pošti!', 'Ось він, потрапив у спам!', 4);
  perform pg_temp.turn('26ffd8fe-cef2-5209-b54d-f301e206b908', '1b9c0ef1-47b4-5806-a751-bf2f1c83d967', 'Luka', 'Otvori privitak i spremi datoteku.', 'Відкрий вкладення й збережи файл.', 5);
  perform pg_temp.turn('305e2ee1-97d5-520a-9e19-0c3baf8eb8cb', '1b9c0ef1-47b4-5806-a751-bf2f1c83d967', 'Daša', 'Spremila sam je. Sad je prosljeđujem i šefici.', 'Зберегла. Зараз пересилаю його й начальниці.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('5fa0613f-ec63-5c69-9a1a-f4726b753bed', v_lesson, 'Повна скринька', 'Puni sandučić', 3622, 'A1', 'it_work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('93b64a3f-1277-50a7-b519-bae43ed08c12', '5fa0613f-ec63-5c69-9a1a-f4726b753bed', 'Darja', 'Imam sto nepročitanih poruka!', 'У мене сто непрочитаних повідомлень!', 1);
  perform pg_temp.turn('15677629-6f2c-5cba-9fca-c379ab0dd6db', '5fa0613f-ec63-5c69-9a1a-f4726b753bed', 'Marko', 'Obriši reklame, a važne pročitaj.', 'Видали рекламу, а важливі прочитай.', 2);
  perform pg_temp.turn('f86f5543-39c1-536c-b726-bb355e407a68', '5fa0613f-ec63-5c69-9a1a-f4726b753bed', 'Darja', 'Ovaj pošiljatelj mi je nepoznat.', 'Цей відправник мені незнайомий.', 3);
  perform pg_temp.turn('21363b99-3638-5aa1-a0fb-12600499fea5', '5fa0613f-ec63-5c69-9a1a-f4726b753bed', 'Marko', 'Ne otvaraj privitak, može biti virus.', 'Не відкривай вкладення, там може бути вірус.', 4);
  perform pg_temp.turn('9c7da7c2-c1f8-5561-909f-46d9175507a6', '5fa0613f-ec63-5c69-9a1a-f4726b753bed', 'Darja', 'Dobro. A kome sam poslala ponudu?', 'Добре. А кому я надіслала пропозицію?', 5);
  perform pg_temp.turn('3226e90b-3f44-5404-9a8c-bf719d995e52', '5fa0613f-ec63-5c69-9a1a-f4726b753bed', 'Marko', 'Pogledaj primatelja u poslanim porukama.', 'Подивися одержувача в надісланих.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A1 v3 (слова за темою, 2 діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 63: Акаунт і пароль: я забув пароль — новий урок: 14 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := 'f5b3441e-2c2a-52bf-825e-a316aae00588';
  v_lesson constant uuid := 'f355be7d-c423-5651-938e-71b8ca970a62';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A1.7: місце 5 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 63: Акаунт і пароль: я забув пароль', 'Lekcija 63: Korisnički račun: zaboravio sam lozinku', '["Створити акаунт і увійти: korisničko ime, lozinka, kod za potvrdu", "Пояснити, що забули пароль і акаунт заблоковано", "Минулий час із запереченням: nisam dobio kod"]'::jsonb, 15, 'PUBLISHED', 5);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Минулий час: radio sam, bila sam»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'korisnički račun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'korisničko ime', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lozinka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'unijeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zaboraviti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'promijeniti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'resetirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kod za potvrdu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potvrda u dva koraka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sigurnosno pitanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'blokiran', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odblokirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'haker', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odjaviti se', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '9aed9d5d-a5fc-53ef-98a9-45a7bb02f9a8', 'fill_in_the_blank', 'Nisam ___ kod za potvrdu.', 'dobila', '["dobijem", "dobila", "dobiti", "dobivam"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'eebc4d51-ce82-5b55-bca4-ede8ca45d4f6', 'multiple_choice', 'Що означає «resetirati»?', 'скинути (пароль), перезавантажити', '["скинути (пароль), перезавантажити", "виписатися; вийти (з акаунта)", "змінити", "хакер"]'::jsonb, 'A1', 2, 'PUBLISHED', 'resetirati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '241ebc9e-88fa-51d4-81c2-f82efe46ebaa', 'multiple_choice', 'Що означає «korisničko ime»?', 'ім''я користувача', '["двоетапна перевірка", "заблокований", "ім''я користувача", "контрольне (секретне) питання"]'::jsonb, 'A1', 3, 'PUBLISHED', 'korisničko ime', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ea9232ab-9ac0-5001-b1e6-40a5311716d7', 'multiple_choice', 'Що означає «sigurnosno pitanje»?', 'контрольне (секретне) питання', '["контрольне (секретне) питання", "код підтвердження", "хакер", "скинути (пароль), перезавантажити"]'::jsonb, 'A1', 4, 'PUBLISHED', 'sigurnosno pitanje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6377cd06-f130-551d-a0a1-25f015055360', 'multiple_choice', 'Як хорватською «розблокувати»?', 'odblokirati', '["potvrda u dva koraka", "odblokirati", "korisnički račun", "resetirati"]'::jsonb, 'A1', 5, 'PUBLISHED', 'odblokirati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d8bd4ef-b782-5c16-8a28-cee931d62130', 'multiple_choice', 'Як хорватською «хакер»?', 'haker', '["odblokirati", "zaboraviti", "haker", "odjaviti se"]'::jsonb, 'A1', 6, 'PUBLISHED', 'haker', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f8566bb3-867c-500b-b1f6-617ee9ffb0b6', 'type_answer', 'Напишіть хорватською: «змінити»', 'promijeniti', null, 'A1', 7, 'PUBLISHED', 'promijeniti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '93d7ffa1-e105-521a-87ef-7bcdfd8555b3', 'type_answer', 'Напишіть хорватською: «заблокований»', 'blokiran', null, 'A1', 8, 'PUBLISHED', 'blokiran', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c5fa8bf8-7dfc-51bd-a9ab-87b52f8af202', 'type_answer', 'Напишіть хорватською: «забути»', 'zaboraviti', null, 'A1', 9, 'PUBLISHED', 'zaboraviti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dc062bae-3c57-5f5b-81c8-c4bfcd7b90e7', 'sentence_builder', 'Складіть: «Я забув пароль.»', 'Zaboravio sam lozinku.', '["lozinku.", "sam", "Zaboravio"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f7f417fc-095f-53f7-8777-e39a42b8226d', 'sentence_builder', 'Складіть: «Мій акаунт заблоковано.»', 'Račun mi je blokiran.', '["Račun", "blokiran.", "mi", "je"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b2027e70-ff52-5716-89c0-a5477277eeda', 'listening', 'Прослухайте і складіть фразу', 'Jesi li provjerila poruke na mobitelu?', '["li", "poruke", "provjerila", "na", "Jesi", "mobitelu?"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'dfde11d9-2fe2-5ff4-b106-9734b348d51b', 'listening', 'Прослухайте і складіть фразу', 'Mogu. Odgovorite na sigurnosno pitanje.', '["na", "Mogu.", "pitanje.", "Odgovorite", "sigurnosno"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '568b839b-71a2-5ae5-9c7f-6b575e84ce69', 'speaking', 'Я забула пароль.', 'Zaboravila sam lozinku.', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6b3f798e-f9e4-5d1b-91f7-a30c7e650aa6', 'speaking', 'Можете розблокувати акаунт?', 'Možete li odblokirati račun?', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d1bfb478-98da-5170-81ed-ee452eacdbeb', v_lesson, 'Я забула пароль', 'Zaboravila sam lozinku', 3631, 'A1', 'it_work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('09269d16-c831-53dc-a421-f9da092b0a90', 'd1bfb478-98da-5170-81ed-ee452eacdbeb', 'Daša', 'Luka, zaboravila sam lozinku za banku!', 'Луко, я забула пароль від банку!', 1);
  perform pg_temp.turn('46f034e6-13f3-57fd-a4c0-1ee16b0e0f02', 'd1bfb478-98da-5170-81ed-ee452eacdbeb', 'Luka', 'Klikni na «Zaboravili ste lozinku?».', 'Натисни «Забули пароль?».', 2);
  perform pg_temp.turn('004336e8-9cf0-5b19-8e9b-1828ed8fc00e', 'd1bfb478-98da-5170-81ed-ee452eacdbeb', 'Daša', 'Unijela sam korisničko ime, ali nisam dobila kod za potvrdu.', 'Я ввела ім’я користувача, але не отримала код підтвердження.', 3);
  perform pg_temp.turn('6d2ff473-95fe-5399-8aac-a80e370c6e19', 'd1bfb478-98da-5170-81ed-ee452eacdbeb', 'Luka', 'Jesi li provjerila poruke na mobitelu?', 'Ти перевірила повідомлення на телефоні?', 4);
  perform pg_temp.turn('3b9b255b-f766-58a7-ae64-e257a9cbf794', 'd1bfb478-98da-5170-81ed-ee452eacdbeb', 'Daša', 'Jesam, evo ga sad. Kako da resetiram lozinku?', 'Так, ось він прийшов. Як мені скинути пароль?', 5);
  perform pg_temp.turn('f7229386-63b4-5f35-a874-8502761b217b', 'd1bfb478-98da-5170-81ed-ee452eacdbeb', 'Luka', 'Unesi kod i promijeni lozinku. Napravi jaku!', 'Введи код і зміни пароль. Зроби надійний!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1c3207cb-2911-5ab9-8aee-e392ccd0fd17', v_lesson, 'Заблокований акаунт', 'Blokiran račun', 3632, 'A1', 'it_work', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('cb30ffcd-749e-509f-be75-713bbd569f18', '1c3207cb-2911-5ab9-8aee-e392ccd0fd17', 'Marko', 'Dobar dan, korisnički račun mi je blokiran.', 'Добрий день, мій акаунт заблоковано.', 1);
  perform pg_temp.turn('f3e43477-aea3-5f54-9e26-7e3a0e26c446', '1c3207cb-2911-5ab9-8aee-e392ccd0fd17', 'Podrška', 'Tri puta ste unijeli krivu lozinku.', 'Ви тричі ввели неправильний пароль.', 2);
  perform pg_temp.turn('94dfe97c-aa66-5876-b945-d84f501234b6', '1c3207cb-2911-5ab9-8aee-e392ccd0fd17', 'Marko', 'Možete li ga odblokirati?', 'Можете його розблокувати?', 3);
  perform pg_temp.turn('9f291d16-6c9a-58f4-825c-5c87d05890b4', '1c3207cb-2911-5ab9-8aee-e392ccd0fd17', 'Podrška', 'Mogu. Odgovorite na sigurnosno pitanje.', 'Можу. Дайте відповідь на контрольне питання.', 4);
  perform pg_temp.turn('9d8a9d8c-5ec8-5054-839f-e39925f880e3', '1c3207cb-2911-5ab9-8aee-e392ccd0fd17', 'Marko', 'Je li me netko hakirao? Bojim se hakera.', 'Мене хтось зламав? Я боюся хакерів.', 5);
  perform pg_temp.turn('7ecfc4a2-0e4f-5cb1-bbb4-01a6f325db68', '1c3207cb-2911-5ab9-8aee-e392ccd0fd17', 'Podrška', 'Nije. Ali uključite potvrdu u dva koraka i odjavite se s tuđih uređaja.', 'Ні. Але увімкніть двоетапну перевірку й вийдіть з чужих пристроїв.', 6);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A1 v3 (слова за темою, 2 діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.');
end $$;

-- A1.7 · урок 64: Онлайн-послуги: запис, оплата, e-Građani — новий урок: 15 слів, 2 діалоги, 15 вправ
do $$
declare
  v_unit constant uuid := 'f5b3441e-2c2a-52bf-825e-a316aae00588';
  v_lesson constant uuid := '953e12fb-a6f6-5ae5-aa7a-ebfe248d24da';
  v_gid uuid;
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A1.7: місце 6 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A1', 'Урок 64: Онлайн-послуги: запис, оплата, e-Građani', 'Lekcija 64: Usluge na internetu: e-Građani', '["Знайти послугу на сайті й записатися онлайн", "Увійти в e-Građani й завантажити документ", "Модальні: moram se prijaviti, mogu li učitati"]'::jsonb, 15, 'PUBLISHED', 6);
  select id into v_gid from public.grammar_topics where cefr = 'A1' and title_ua = 'Модальні дієслова' and status = 'PUBLISHED' order by created_at limit 1;
  if v_gid is null then raise exception 'Немає теми граматики «Модальні дієслова»'; end if;
  -- слова
  v_pos := pg_temp.word(v_lesson, 'e-Građani', v_pos);
  v_pos := pg_temp.word(v_lesson, 'internetsko bankarstvo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mobilni token', v_pos);
  v_pos := pg_temp.word(v_lesson, 'e-naručivanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'elektronički potpis', v_pos);
  v_pos := pg_temp.word(v_lesson, 'certifikat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'sustav', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pristup', v_pos);
  v_pos := pg_temp.word(v_lesson, 'učitati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pretraživati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'tražilica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'web-stranica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'digitalni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obrazac', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispuniti', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  delete from public.lesson_grammar where lesson_id = v_lesson;
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a2a05444-3e55-5011-b71f-c23d8edef865', 'fill_in_the_blank', 'Ne ___ ići u ured, sve je na internetu.', 'moraš', '["mogu", "trebaš li", "moraš", "moram li"]'::jsonb, 'A1', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'c6e3afd9-45e0-58ca-83f2-d19996a1204e', 'multiple_choice', 'Що означає «internetsko bankarstvo»?', 'інтернет-банкінг', '["вебсайт", "інтернет-банкінг", "заповнити", "мобільний токен (для входу)"]'::jsonb, 'A1', 2, 'PUBLISHED', 'internetsko bankarstvo', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '17e78325-1166-5e7f-b721-de7a8f515eed', 'multiple_choice', 'Що означає «mobilni token»?', 'мобільний токен (для входу)', '["мобільний токен (для входу)", "сертифікат", "пошуковик, рядок пошуку", "онлайн-запис (до лікаря, в установу)"]'::jsonb, 'A1', 3, 'PUBLISHED', 'mobilni token', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd9f36298-f517-55a8-8537-bb4ea107f67c', 'multiple_choice', 'Що означає «učitati»?', 'завантажити (на сайт)', '["е-Громадяни (державний портал Хорватії)", "заповнити", "онлайн-запис (до лікаря, в установу)", "завантажити (на сайт)"]'::jsonb, 'A1', 4, 'PUBLISHED', 'učitati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'effb6239-5fb9-54bd-aed1-7fcc27a346b4', 'multiple_choice', 'Як хорватською «шукати (в інтернеті)»?', 'pretraživati', '["elektronički potpis", "digitalni", "pretraživati", "e-Građani"]'::jsonb, 'A1', 5, 'PUBLISHED', 'pretraživati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '64d3a244-7550-5f45-8412-00e847433b16', 'multiple_choice', 'Як хорватською «заповнити»?', 'ispuniti', '["obrazac", "certifikat", "učitati", "ispuniti"]'::jsonb, 'A1', 6, 'PUBLISHED', 'ispuniti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8e0a2579-4c70-5b7c-8e3d-85a4e3c6efa5', 'type_answer', 'Напишіть хорватською: «система»', 'sustav', null, 'A1', 7, 'PUBLISHED', 'sustav', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '61d556ac-b9a9-5430-be92-62a7ce43b989', 'type_answer', 'Напишіть хорватською: «доступ»', 'pristup', null, 'A1', 8, 'PUBLISHED', 'pristup', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '69eeb4c4-a7f4-5524-ad45-ad2351750412', 'type_answer', 'Напишіть хорватською: «вебсайт»', 'web-stranica', null, 'A1', 9, 'PUBLISHED', 'web-stranica', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '53ae9860-c72f-5fe8-a030-41b21fa06305', 'sentence_builder', 'Складіть: «Як мені увійти в систему?»', 'Kako se prijavljujem u sustav?', '["Kako", "prijavljujem", "sustav?", "u", "se"]'::jsonb, 'A1', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '255394a9-d0b4-51c8-948e-76b9f7970b2a', 'sentence_builder', 'Складіть: «Треба заповнити бланк.»', 'Treba ispuniti obrazac.', '["ispuniti", "obrazac.", "Treba"]'::jsonb, 'A1', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a55077f3-530a-5207-9b9c-100775c93efa', 'listening', 'Прослухайте і складіть фразу', 'A gdje je ta usluga?', '["usluga?", "je", "ta", "gdje", "A"]'::jsonb, 'A1', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5e4bdccd-9107-5b78-9780-1523eb487e6f', 'listening', 'Прослухайте і складіть фразу', 'Treba ispuniti obrazac i učitati uputnicu.', '["Treba", "obrazac", "i", "učitati", "uputnicu.", "ispuniti"]'::jsonb, 'A1', 13, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3cf11a24-d33d-50a3-a89a-452138fdffe4', 'speaking', 'Як отримати довідку онлайн?', 'Kako mogu dobiti potvrdu preko interneta?', null, 'A1', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0402999b-2a80-5f78-b271-8603f358479f', 'speaking', 'Завантажте документ.', 'Učitajte dokument.', null, 'A1', 15, 'PUBLISHED', null, 'speaking');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f0d16280-3a33-5ca3-88ba-1d59e9d49a4c', v_lesson, 'Довідка через e-Građani', 'Potvrda preko e-Građana', 3641, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('ecf56858-e52b-5874-a2f6-528ce2c47609', 'f0d16280-3a33-5ca3-88ba-1d59e9d49a4c', 'Daša', 'Ivana, kako mogu dobiti potvrdu o prebivalištu?', 'Івано, як мені отримати довідку про місце проживання?', 1);
  perform pg_temp.turn('8c1ba45a-3268-5ef7-804e-698b94355290', 'f0d16280-3a33-5ca3-88ba-1d59e9d49a4c', 'Ivana', 'Preko e-Građana, ne moraš ići u ured.', 'Через e-Građani, не треба йти в установу.', 2);
  perform pg_temp.turn('eed2dbad-cc6b-5472-b451-1f56bbd15b1e', 'f0d16280-3a33-5ca3-88ba-1d59e9d49a4c', 'Daša', 'Kako se prijavljujem u sustav?', 'Як увійти в систему?', 3);
  perform pg_temp.turn('afdefdc7-e8d3-5743-a137-0663a802dd05', 'f0d16280-3a33-5ca3-88ba-1d59e9d49a4c', 'Ivana', 'Mobilnim tokenom banke ili osobnom iskaznicom s certifikatom.', 'Мобільним токеном банку або ID-карткою із сертифікатом.', 4);
  perform pg_temp.turn('950035bb-176a-5cca-84a7-658b51ba2127', 'f0d16280-3a33-5ca3-88ba-1d59e9d49a4c', 'Daša', 'A gdje je ta usluga?', 'А де ця послуга?', 5);
  perform pg_temp.turn('f48ffa7b-729c-530a-9379-7ce40e02d979', 'f0d16280-3a33-5ca3-88ba-1d59e9d49a4c', 'Ivana', 'Upiši «prebivalište» u tražilicu na stranici.', 'Напиши «prebivalište» в пошуку на сайті.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('debe2e28-4fbd-5ed5-8bcf-3a4c597b2c0e', v_lesson, 'Запис до лікаря', 'Narudžba kod doktora', 3642, 'A1', 'administration', 'PUBLISHED', 'claude_curriculum_a1_v3') on conflict (id) do nothing;
  perform pg_temp.turn('8c161c4a-4ec3-57b3-b8b7-de857bfd678a', 'debe2e28-4fbd-5ed5-8bcf-3a4c597b2c0e', 'Luka', 'Moram se naručiti na pregled, a ne mogu dobiti ambulantu.', 'Мені треба записатися на огляд, а я не можу додзвонитися в амбулаторію.', 1);
  perform pg_temp.turn('347ba0ff-8f39-58e0-a927-0bfd49f0af33', 'debe2e28-4fbd-5ed5-8bcf-3a4c597b2c0e', 'Darja', 'Probaj e-naručivanje na web-stranici doma zdravlja.', 'Спробуй онлайн-запис на сайті поліклініки.', 2);
  perform pg_temp.turn('5672f57e-3911-5a1d-a5cb-b6eded3f80f3', 'debe2e28-4fbd-5ed5-8bcf-3a4c597b2c0e', 'Luka', 'Treba ispuniti obrazac i učitati uputnicu.', 'Треба заповнити бланк і завантажити направлення.', 3);
  perform pg_temp.turn('9a4814f4-6f2b-507b-a47a-bb59d8bfa9a7', 'debe2e28-4fbd-5ed5-8bcf-3a4c597b2c0e', 'Darja', 'Uputnica je digitalna, ne moraš je učitati.', 'Направлення електронне, його не треба завантажувати.', 4);
  perform pg_temp.turn('1a3b6c2f-94a0-5ef8-b186-05caefc27a36', 'debe2e28-4fbd-5ed5-8bcf-3a4c597b2c0e', 'Luka', 'Super. A smijem li platiti internetskim bankarstvom?', 'Чудово. А можна заплатити через інтернет-банкінг?', 5);
  perform pg_temp.turn('7a7986e9-2db8-563b-82cc-41586346dd2b', 'debe2e28-4fbd-5ed5-8bcf-3a4c597b2c0e', 'Darja', 'Smiješ, a ugovore možeš potpisati elektroničkim potpisom.', 'Можна, а договори можеш підписати електронним підписом.', 6);
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
   where l.id in ('8e08a8e3-8969-52fc-bc82-5a403dd7ad35', '31bbedca-4b51-5478-8513-df5cb996ffd9', '35203547-5f9a-5857-95a0-3a0d596f715d', '71537166-9f48-503f-b564-3a4f99a192c5', 'f355be7d-c423-5651-938e-71b8ca970a62', '953e12fb-a6f6-5ae5-aa7a-ebfe248d24da', '4edd1556-f088-5d14-8f59-529b35747609')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 10 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 15);
  select count(*) into v_order from (values ('8e08a8e3-8969-52fc-bc82-5a403dd7ad35'::uuid, 1), ('31bbedca-4b51-5478-8513-df5cb996ffd9'::uuid, 2), ('35203547-5f9a-5857-95a0-3a0d596f715d'::uuid, 3), ('71537166-9f48-503f-b564-3a4f99a192c5'::uuid, 4), ('f355be7d-c423-5651-938e-71b8ca970a62'::uuid, 5), ('953e12fb-a6f6-5ae5-aa7a-ebfe248d24da'::uuid, 6), ('4edd1556-f088-5d14-8f59-529b35747609'::uuid, 7)) as t(id, o)
    join public.lessons l on l.id = t.id and l.order_index = t.o and l.unit_id = 'f5b3441e-2c2a-52bf-825e-a316aae00588';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A1' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ('8e08a8e3-8969-52fc-bc82-5a403dd7ad35', '31bbedca-4b51-5478-8513-df5cb996ffd9', '35203547-5f9a-5857-95a0-3a0d596f715d', '71537166-9f48-503f-b564-3a4f99a192c5', 'f355be7d-c423-5651-938e-71b8ca970a62', '953e12fb-a6f6-5ae5-aa7a-ebfe248d24da', '4edd1556-f088-5d14-8f59-529b35747609') and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A1.7: % уроків з неправильним складом', v_bad; end if;
  if v_order <> 7 then raise exception 'Модуль A1.7: на своїх місцях % уроків з 7', v_order; end if;
  if v_titles > 0 then raise exception 'A1: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A1.7: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A1.7 — 7 уроків за темою (3 перебудовано, 4 нових)';
end $$;

commit;
