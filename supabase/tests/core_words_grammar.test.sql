-- =====================================================================
-- Тести: базові слова в уроках, правила граматики A0 / A1, мітки cefr · 2026-11-04
-- Запускати ПІСЛЯ supabase/data_fixes/20261104_core_words_grammar.sql.
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
-- Запуск: Supabase → SQL Editor → вставити файл → Run. Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

create or replace function pg_temp.n(q text) returns bigint language plpgsql as $$
declare r bigint;
begin
  execute 'select count(*) from (' || q || ') s' into r;
  return r;
end $$;

-- Слова в уроках (опубліковані уроки A0 / A1)
create temp view lw as
select le.id lesson_id, le.level_code lv, x.id lexeme_id, lower(x.lemma) lemma, x.cefr, x.status
from public.lesson_items li
join public.lessons le on le.id = li.lesson_id and le.status = 'PUBLISHED' and le.level_code in ('A0', 'A1')
join public.lexemes x on x.id = li.item_id
where li.item_type = 'lexeme';

select pg_temp.ok(pg_temp.n($q$select 1 from unnest(array['dobar','loš','lak','topao','važan','vidjeti','čuti','reći','gledati',
  'slušati','čitati','pisati','trebati','željeti','razgovarati','sjediti','trčati','ali','ili','ako','jer','kada','kao','dok','tako',
  'sve','svaki','vrlo','puno','možda','život','dom','roditelj','problem']) w
  where not exists (select 1 from lw where lw.lemma = w)$q$) = 0, '34 базові слова — у списках слів уроків');
select pg_temp.ok(pg_temp.n($q$select lesson_id from lw group by 1 having count(*) > 25$q$) = 0, 'в уроці ≤ 25 слів');
select pg_temp.ok(pg_temp.n($q$select lesson_id, lexeme_id from lw group by 1, 2 having count(*) > 1$q$) = 0, 'слово не двічі в уроці');
select pg_temp.ok(pg_temp.n($q$select 1 from lw where status <> 'PUBLISHED'$q$) = 0, 'усі слова уроків опубліковані');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items li join public.lessons le on le.id = li.lesson_id
  group by li.lesson_id, li.order_index having count(*) > 1$q$) = 0, 'місця в уроці не повторюються');
select pg_temp.ok((select ukrainian_translation from public.lexemes where lower(lemma) = 'dom') like 'дім%', 'dom — «дім», а не «гуртожиток»');
select pg_temp.ok(exists (select 1 from public.lexemes where lemma = 'vrlo' and status = 'PUBLISHED'
  and ukrainian_translation = 'дуже'), 'нове слово vrlo — «дуже»');

-- Мітка cefr = рівень першого уроку
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes x join (select lexeme_id, min(lv) lv from lw group by 1) f on f.lexeme_id = x.id
  where x.cefr is distinct from f.lv$q$) = 0, 'cefr слова = рівень уроку, де його вперше вчать');

-- Правила граматики A0 / A1
create temp view gr as
select g.cefr, g.title_hr topic, r.* from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
where g.cefr in ('A0', 'A1') and g.status = 'PUBLISHED';
select pg_temp.ok(pg_temp.n($q$select 1 from gr where length(explanation_ua) < 150$q$) = 0, 'пояснення ≥ 150 знаків');
select pg_temp.ok(pg_temp.n($q$select 1 from gr where jsonb_array_length(coalesce(examples, '[]'::jsonb)) < 4$q$) = 0, '≥ 4 приклади в правилі');
select pg_temp.ok(pg_temp.n($q$select 1 from gr, jsonb_array_elements(examples) e
  where regexp_replace(e ->> 'hr', '«[^»]*»', '', 'g') ~ '[Ѐ-ӿ]' or coalesce(e ->> 'ua', '') !~ '[Ѐ-ӿ]'$q$) = 0,
  'приклад: хорватське без кирилиці (крім слова в «»), переклад українською');
select pg_temp.ok(pg_temp.n($q$select topic_id, order_index from gr group by 1, 2 having count(*) > 1$q$) = 0, 'порядок правил у темі не повторюється');
select pg_temp.ok(exists (select 1 from gr where topic = 'Rod, množina i posvojne zamjenice' and title_ua like 'Короткі слова: grad → gradovi%'),
  'нове правило A0: grad → gradovi');
select pg_temp.ok(exists (select 1 from gr where topic = 'Lokativ' and title_ua like 'Ruka — u ruci%'), 'нове правило A1: ruka — u ruci');
select pg_temp.ok(exists (select 1 from gr where topic = 'Genitiv: osnove' and title_ua like 'Od mene, kod nas%'), 'нове правило A1: kod nas, o tebi');
select pg_temp.ok((select order_index from gr where title_ua like 'Короткі слова: grad → gradovi%')
  = (select order_index from gr where topic = 'Rod, množina i posvojne zamjenice' and title_ua = 'Множина') + 1,
  'gradovi — одразу після «Множина»');

select 'ALL TESTS PASSED' as result;
rollback;
