-- =====================================================================
-- Типові помилки українців (§19) · interference_v2 · 2026-11-13
-- Згенеровано: python3 -B scripts/gen_interference_v2_20261113.py (не редагуйте вручну).
-- Борг docs/PROJECT_STATE.md: «типові помилки: вимова — підказки кирилицею; мало «артиклів» і «виду дієслова»».
--
--   * +12 помилок, коди UKR-HR-0075…UKR-HR-0086: aspect 6, articles 3, pronunciation 3.
--     Разом у каталозі стане 86: вид дієслова 2 → 8, артиклі 1 → 4, вимова 5 → 8.
--   * Прив'язка до тем граматики A0 / A1 і слів — картка «Українці часто помиляються» в уроці.
--   * Виправлено 1 запис(и) v1: UKR-HR-0060 (підказка вимови). Стара версія — у content_versions.
--   * Статус PUBLISHED: бета (носій ще не перевіряв). Повторний запуск нічого не змінює.
-- Після нього: тест supabase/tests/interference_v2.test.sql → «ALL TESTS PASSED».
-- Очікуване повідомлення: «Готово: типових помилок — 86, нових — 12, вид дієслова — 8, артиклі — 4, вимова — 8».
-- =====================================================================

begin;

do $$
begin
  if (select count(*) from public.linguistic_errors where code between 'UKR-HR-0001' and 'UKR-HR-0074') < 74 then
    raise exception 'Спершу потрібен каталог v1 (20261013_interference_v1.sql)';
  end if;
end $$;

insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0075', 'aspect', 'A1', 'Майбутнє — «kupit ću», а не «kupim»', 'Sutra kupim karte.', 'Sutra ću kupiti karte.', 'Українською «куплю», «напишу» вже означають майбутнє. У хорватській доконане kupim, napišem саме по собі майбутнього не означає — воно стоїть після kad, ako, čim, da. Майбутнє — з ću: kupit ću, napisat ću. У розмові іноді чуєте «javim ti se sutra», але в стандартній мові й на письмі — з ću.', '[{"hr": "Nazvat ću te večeras.", "ua": "Я подзвоню тобі ввечері."}, {"hr": "Kad kupim karte, javit ću ti.", "ua": "Коли куплю квитки, дам тобі знати."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A1' and title_ua = 'Майбутній час: ići ću, bit će' and status = 'PUBLISHED' order by created_at limit 1), (select id from public.lexemes where lower(lemma) = lower('kupiti') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v2')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0076', 'aspect', 'A1', 'Прохання про одну дію — доконаний вид', 'Možeš li mi dodavati sol?', 'Možeš li mi dodati sol?', 'Коли просимо зробити щось один раз, після moći, htjeti, trebati ставимо доконане дієслово: dodati, otvoriti, pomoći. Недоконане (dodavati, otvarati) — про дію, що повторюється або триває.', '[{"hr": "Možete li otvoriti prozor?", "ua": "Можете відчинити вікно?"}, {"hr": "Trebam platiti račun.", "ua": "Мені треба оплатити рахунок."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A1' and title_ua = 'Модальні дієслова' and status = 'PUBLISHED' order by created_at limit 1), (select id from public.lexemes where lower(lemma) = lower('dodati') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v2')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0077', 'aspect', 'A1', 'Справу зроблено — доконаний вид', 'Jesi li već plaćao račun?', 'Jesi li već platio račun?', 'Коли питаємо чи кажемо, що справу завершено і є результат, — доконаний вид: platio, kupio, završio. Недоконаний (plaćao, kupovao) — про процес або звичку: «оплачував», «купував».', '[{"hr": "Već sam kupila kruh.", "ua": "Я вже купила хліб."}, {"hr": "Jesi li završio posao?", "ua": "Ти закінчив роботу?"}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1), (select id from public.lexemes where lower(lemma) = lower('platiti') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v2')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0078', 'aspect', 'A1', 'Скільки тривало — недоконаний вид', 'Cijelo jutro sam napisao izvještaj.', 'Cijelo jutro sam pisao izvještaj.', 'Зі словами cijeli dan, cijelo jutro, dva sata, dugo дія тривала — потрібен недоконаний вид: pisao, čekao, učio. Доконаний (napisao) показує результат: Napisao sam izvještaj za dva sata — за дві години.', '[{"hr": "Dva sata smo čekali autobus.", "ua": "Ми дві години чекали автобус."}, {"hr": "Cijelu večer je učila hrvatski.", "ua": "Увесь вечір вона вчила хорватську."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A1' and title_ua = 'Минулий час: radio sam, bila sam' and status = 'PUBLISHED' order by created_at limit 1), (select id from public.lexemes where lower(lemma) = lower('pisati') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v2')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0079', 'aspect', 'A2', 'Після početi і prestati — недоконаний вид', 'Počela sam naučiti hrvatski.', 'Počela sam učiti hrvatski.', 'Після početi, prestati, nastaviti — лише недоконане дієслово: početi raditi, prestati pušiti, nastaviti učiti. Так само українською: «почала вчити», а не «почала вивчити».', '[{"hr": "Prestao je pušiti prošle godine.", "ua": "Він кинув курити минулого року."}, {"hr": "Kada počinješ raditi?", "ua": "Коли ти починаєш працювати?"}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('početi') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v2')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0080', 'aspect', 'A1', 'Робіть регулярно — наказ від недоконаного', 'Nazovi me ponekad!', 'Zovi me ponekad!', 'Наказ від доконаного дієслова (nazovi, napiši) — про одну конкретну дію. Якщо дія повторюється (ponekad, svaki dan, uvijek), наказ — від недоконаного: zovi, piši, dolazi.', '[{"hr": "Napiši mi kad stigneš!", "ua": "Напиши мені, коли доїдеш!"}, {"hr": "Zovi me kad god ti nešto treba.", "ua": "Дзвони мені щоразу, коли тобі щось треба."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A1' and title_ua = 'Наказовий спосіб' and status = 'PUBLISHED' order by created_at limit 1), (select id from public.lexemes where lower(lemma) = lower('zvati') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v2')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0081', 'articles', 'A0', 'Taj — не англійське the', 'Taj život je lijep.', 'Život je lijep.', 'Taj означає «той / цей» — коли показуємо на щось або про нього вже йшлося. Загальні поняття (život, ljubav, novac) і речі взагалі — без жодного слова перед ними, як в українській.', '[{"hr": "Novac nije najvažniji.", "ua": "Гроші — не найголовніше."}, {"hr": "Volim more.", "ua": "Я люблю море."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Цей, той, он той: ovaj, taj, onaj' and status = 'PUBLISHED' order by created_at limit 1), (select id from public.lexemes where lower(lemma) = lower('taj') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v2')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0082', 'articles', 'A0', '«У центр» — просто «u centar»', 'Idem u taj centar.', 'Idem u centar.', 'Англійське the city centre не перекладаємо словом taj. «Іду в центр» — Idem u centar. U taj centar означає «саме в той центр», про який уже говорили.', '[{"hr": "Je li ovo autobus za centar?", "ua": "Це автобус до центру?"}, {"hr": "Pošta je u centru.", "ua": "Пошта в центрі."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Цей, той, он той: ovaj, taj, onaj' and status = 'PUBLISHED' order by created_at limit 1), (select id from public.lexemes where lower(lemma) = lower('centar') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v2')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0083', 'articles', 'A0', 'Після kao — без jedan', 'Radim kao jedan programer.', 'Radim kao programer.', 'Англійське I work as a programmer не потребує jedan. Після kao професію чи роль ставимо саму: radim kao konobar, kao vozač, kao učiteljica.', '[{"hr": "Darja radi kao medicinska sestra.", "ua": "Дар’я працює медсестрою."}, {"hr": "Ljeti radim kao konobar.", "ua": "Улітку я працюю офіціантом."}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('kao') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v2')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0084', 'pronunciation', 'A0', 'C — це «ц», а не «к»', 'cijena — «кієна»', 'cijena — «цієна»', 'Хорватська c завжди читається як «ц»: cijena, centar, crkva. Не читайте її як англійське «к».', '[{"hr": "Kolika je cijena?", "ua": "Яка ціна? [цієна]"}, {"hr": "Centar je blizu.", "ua": "Центр поруч. [центар]"}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Вимова: хорватські літери' and status = 'PUBLISHED' order by created_at limit 1), (select id from public.lexemes where lower(lemma) = lower('cijena') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v2')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0085', 'pronunciation', 'A0', 'J — це «й», а не «дж»', 'jutro — «джутро»', 'jutro — «ютро»', 'Хорватська j — завжди «й»: ja — «я», jutro — «ютро», Jelena — «Єлена». Не читайте її як англійське «дж».', '[{"hr": "Dobro jutro!", "ua": "Доброго ранку! [добро ютро]"}, {"hr": "Jelena je moja prijateljica.", "ua": "Єлена — моя подруга. [єлена]"}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Вимова: хорватські літери' and status = 'PUBLISHED' order by created_at limit 1), (select id from public.lexemes where lower(lemma) = lower('jutro') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v2')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0086', 'pronunciation', 'A0', 'Đ і dž — різні звуки', 'rođendan — тверде «дж», як у слові «джміль»', 'rođendan — м’якше «дж» (між «дж» і «дь»)', 'dž — тверде «дж», як в українській: džep (кишеня). đ — м’якша пара до ć: rođendan, međutim, Đurđa. Різниця між dž і đ така сама, як між č і ć.', '[{"hr": "Sretan rođendan!", "ua": "З днем народження!"}, {"hr": "Ključ je u džepu.", "ua": "Ключ у кишені."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Вимова: хорватські літери' and status = 'PUBLISHED' order by created_at limit 1), (select id from public.lexemes where lower(lemma) = lower('rođendan') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v2')
on conflict (code) do nothing;

-- Журнал перевірки (один запис на кожну нову помилку)
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'linguistic_error', e.id, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: типові помилки v2 (вид дієслова, артиклі, вимова) — борг PROJECT_STATE 2026-11-13. Потрібна перевірка носієм.'
from public.linguistic_errors e
where e.source = 'claude_interference_v2'
  and not exists (select 1 from public.content_reviews r where r.entity_id = e.id and r.notes = 'Бета: типові помилки v2 (вид дієслова, артиклі, вимова) — борг PROJECT_STATE 2026-11-13. Потрібна перевірка носієм.');

-- Виправлення UKR-HR-0060
do $fix$
declare x public.linguistic_errors%rowtype;
begin
  select * into x from public.linguistic_errors where code = 'UKR-HR-0060';
  if x.id is null then raise exception 'Немає запису UKR-HR-0060'; end if;
  if x.correct_text is distinct from 'kuća — м’якше «ч» (між «ч» і «ть»)' then
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('linguistic_error', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'linguistic_error' and entity_id = x.id), 0) + 1,
            to_jsonb(x), 'interference_v2 2026-11-13: уточнено підказку вимови кирилицею (було «майже «кутя»» — плутає з «т»). Потрібна перевірка носієм.');
    update public.linguistic_errors set correct_text = 'kuća — м’якше «ч» (між «ч» і «ть»)', version = version + 1 where id = x.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('linguistic_error', x.id, x.status, x.status, 'auto_passed', 'ai', '[]'::jsonb, 'interference_v2 2026-11-13: уточнено підказку вимови кирилицею (було «майже «кутя»» — плутає з «т»). Потрібна перевірка носієм.');
  end if;
end $fix$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_total int; v_new int; v_aspect int; v_art int; v_pron int; v_no_link int; v_bad_grammar int;
begin
  select count(*) into v_total from public.linguistic_errors where status = 'PUBLISHED';
  select count(*) into v_new from public.linguistic_errors where source = 'claude_interference_v2' and status = 'PUBLISHED';
  select count(*) filter (where category = 'aspect'), count(*) filter (where category = 'articles'), count(*) filter (where category = 'pronunciation')
    into v_aspect, v_art, v_pron from public.linguistic_errors where status = 'PUBLISHED';
  select count(*) into v_no_link from public.linguistic_errors
   where source = 'claude_interference_v2' and grammar_topic_id is null and lexeme_id is null
     and code in ('UKR-HR-0075', 'UKR-HR-0076', 'UKR-HR-0077', 'UKR-HR-0078', 'UKR-HR-0079', 'UKR-HR-0080', 'UKR-HR-0081', 'UKR-HR-0082', 'UKR-HR-0083', 'UKR-HR-0084', 'UKR-HR-0085', 'UKR-HR-0086');
  select count(*) into v_bad_grammar from public.linguistic_errors e
   where e.source = 'claude_interference_v2' and e.grammar_topic_id is not null
     and not exists (select 1 from public.grammar_topics g where g.id = e.grammar_topic_id and g.cefr in ('A0', 'A1'));
  if v_new < 12 then raise exception 'Нових типових помилок %, очікувалось 12', v_new; end if;
  if v_no_link > 0 then raise exception '% нових помилок не знайшли свою тему граматики чи слово', v_no_link; end if;
  if v_bad_grammar > 0 then raise exception '% нових помилок прив''язано не до тем A0 / A1', v_bad_grammar; end if;
  if exists (select 1 from public.linguistic_errors where code = 'UKR-HR-0060' and correct_text like '%кутя%') then
    raise exception 'UKR-HR-0060 не виправлено';
  end if;
  raise notice 'Готово: типових помилок — %, нових — %, вид дієслова — %, артиклі — %, вимова — %', v_total, v_new, v_aspect, v_art, v_pron;
end $$;

commit;
