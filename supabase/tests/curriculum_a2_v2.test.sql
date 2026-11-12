-- =====================================================================
-- Тести програми A2 v2 (погоджено власником 2026-11-12): 14 модулів, 86 уроків, 22 теми граматики,
-- 14 перевірок модулів + середина + фінал (258 завдань).
-- Запускати ПІСЛЯ пакетів 20261112_curriculum_a2_v2_00_structure.sql … _m14.sql і _t1_assessments.sql.
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK. Успіх: «ALL TESTS PASSED».
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

create temp view a2_lessons as
  select l.id, l.title_ua, l.title_hr, m.order_index as mo,
         row_number() over (order by m.order_index, u.order_index, l.order_index) as n
    from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
   where m.level_code = 'A2' and l.status = 'PUBLISHED';

-- ---------------------------------------------------------------- структура
select pg_temp.ok(pg_temp.n($q$select 1 from public.modules where level_code = 'A2' and status = 'PUBLISHED'$q$) = 14,
  'A2: рівно 14 опублікованих модулів');
select pg_temp.ok(pg_temp.n($q$select 1 from public.modules where level_code = 'A2' and status = 'PUBLISHED'
  and (title_ua not like 'Модуль A2.' || order_index || ' — %' or order_index not between 1 and 14)$q$) = 0,
  'модулі A2 пронумеровано 1–14, назва «Модуль A2.N — …»');
select pg_temp.ok(pg_temp.n($q$select 1 from a2_lessons$q$) = 86, 'A2: рівно 86 опублікованих уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from a2_lessons where title_ua not like 'Урок ' || n || ':%' or title_hr not like 'Lekcija ' || n || ':%'$q$) = 0,
  'назви уроків A2 пронумеровано підряд: «Урок 1» … «Урок 86»');
select pg_temp.ok(pg_temp.n($q$select mo from a2_lessons group by mo
  having count(*) <> (case mo when 1 then 8 when 2 then 8 when 4 then 7 when 5 then 7 when 14 then 3 when 3 then 6
                               when 6 then 6 when 7 then 5 else 6 end)$q$) = 0,
  'уроків у модулях — за програмою (8, 8, 6, 7, 7, 6, 5, 6, 6, 6, 6, 6, 6, 3)');
select pg_temp.ok(pg_temp.n($q$select 1 from backup.modules_a2_20261112$q$) = 10,
  'старі 10 модулів A2 збережено в backup.modules_a2_20261112');

-- ---------------------------------------------------------------- склад уроку
select pg_temp.ok(pg_temp.n($q$select 1 from a2_lessons v where
  (select count(*) from public.lesson_items i where i.lesson_id = v.id and i.item_type = 'lexeme') not between 20 and 25$q$) = 0,
  'у кожному уроці A2 20–25 слів і виразів (рішення 2026-10-15)');
select pg_temp.ok(pg_temp.n($q$select x.id from a2_lessons v join public.lesson_items i on i.lesson_id = v.id and i.item_type = 'lexeme'
  join public.lexemes x on x.id = i.item_id group by x.id having count(*) > 1$q$) = 0,
  'слова уроків A2 не повторюються між уроками');
select pg_temp.ok(pg_temp.n($q$select 1 from a2_lessons v join public.lesson_items i on i.lesson_id = v.id and i.item_type = 'lexeme'
  join public.lexemes x on x.id = i.item_id where x.status <> 'PUBLISHED'$q$) = 0,
  'усі слова уроків A2 опубліковано');
select pg_temp.ok(pg_temp.n($q$select distinct i.item_id from a2_lessons v join public.lesson_items i on i.lesson_id = v.id and i.item_type = 'lexeme'$q$) >= 1800,
  'в уроках A2 ≥ 1800 різних слів (програма — ≈1850)');
select pg_temp.ok(pg_temp.n($q$select 1 from a2_lessons v where
  (select count(*) from public.lesson_items i where i.lesson_id = v.id and i.item_type = 'exercise' and i.required) <> 15$q$) = 0,
  'у кожному уроці A2 рівно 15 обов’язкових вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from a2_lessons v where
  (select count(*) from public.lesson_items i join public.exercises e on e.id = i.item_id
    where i.lesson_id = v.id and i.item_type = 'exercise' and e.exercise_type = 'listening_dialogue' and i.required) <> 1$q$) = 0,
  'у кожному уроці A2 одна вправа «Прослухайте діалог чи оголошення»');
select pg_temp.ok(pg_temp.n($q$select 1 from a2_lessons v where
  (select count(*) from public.lesson_items i where i.lesson_id = v.id and i.item_type = 'exercise' and not i.required) <> 2$q$) = 0,
  'у кожному уроці A2 2 необов’язкові вправи на письмо («Напишіть повідомлення», «Перекажіть другу»)');
select pg_temp.ok(pg_temp.n($q$select 1 from a2_lessons v where
  (select count(*) from public.conversations c where c.lesson_id = v.id and c.status = 'PUBLISHED') <> 2$q$) = 0,
  'у кожному уроці A2 2 опубліковані діалоги');
select pg_temp.ok(pg_temp.n($q$select 1 from a2_lessons v where
  (select count(*) from public.lesson_grammar g where g.lesson_id = v.id) <> 1$q$) = 0,
  'кожен урок A2 пов’язано з однією темою граматики');
select pg_temp.ok(pg_temp.n($q$select 1 from a2_lessons v join public.lesson_items i on i.lesson_id = v.id and i.item_type = 'exercise'
  join public.exercises e on e.id = i.item_id where e.status <> 'PUBLISHED'$q$) = 0,
  'усі вправи уроків A2 опубліковано');
-- з A2.8 одне питання «на слух» — коротка відповідь (програма A2 v2)
select pg_temp.ok(pg_temp.n($q$select 1 from a2_lessons v join public.lesson_items i on i.lesson_id = v.id and i.item_type = 'exercise'
  join public.exercises e on e.id = i.item_id and e.exercise_type = 'listening_dialogue'
  where (select count(*) from jsonb_array_elements(e.task -> 'questions') q where q ? 'answer_text') <> (case when v.mo >= 8 then 1 else 0 end)$q$) = 0,
  '«на слух»: до A2.8 лише вибір, з A2.8 — рівно одне питання з короткою відповіддю');

-- ---------------------------------------------------------------- граматика
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_topics where cefr = 'A2' and status = 'PUBLISHED'$q$) >= 22,
  'граматика A2: ≥ 22 опубліковані теми');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_topics t where t.cefr = 'A2' and t.status = 'PUBLISHED'
  and not exists (select 1 from public.grammar_rules r where r.topic_id = t.id)$q$) = 0,
  'у кожній опублікованій темі граматики A2 є правила');
select pg_temp.ok(pg_temp.n($q$select distinct g.grammar_topic_id from a2_lessons v join public.lesson_grammar g on g.lesson_id = v.id$q$) = 22,
  'уроки A2 покривають усі 22 теми граматики програми');

-- ---------------------------------------------------------------- перевірки рівня
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments a join public.modules m on m.id = a.module_id
  where a.cefr = 'A2' and a.kind = 'module' and a.status = 'PUBLISHED' and m.level_code = 'A2' and a.slug = 'a2-m' || lpad(m.order_index::text, 2, '0')$q$) = 14,
  'A2: 14 перевірок модулів (a2-m01 … a2-m14), кожна прив’язана до свого модуля');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments a join public.modules m on m.id = a.module_id
  where a.cefr = 'A2' and a.kind = 'module'
  and (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED')
      <> greatest(12, least(20, 2 * (select count(*) from public.units u join public.lessons l on l.unit_id = u.id where u.module_id = m.id)))$q$) = 0,
  'перевірка модуля — 2 завдання на урок, від 12 до 20 (схема 2026-11-07)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments a where a.cefr = 'A2' and a.slug = 'a2-mid' and a.kind = 'mid' and a.status = 'PUBLISHED'
  and (select count(*) from public.assessment_items i where i.assessment_id = a.id) = 30$q$) = 1,
  'середина A2 — 30 завдань');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments a where a.cefr = 'A2' and a.slug = 'a2-final' and a.kind = 'final' and a.status = 'PUBLISHED'
  and (select count(*) from public.assessment_items i where i.assessment_id = a.id) = 48$q$) = 1,
  'фінал A2 — 48 завдань');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.cefr = 'A2' and a.source = 'claude_assessment_a2_v2'$q$) = 258,
  'перевірки A2 — разом 258 завдань');
select pg_temp.ok(pg_temp.n($q$select a.id from public.assessments a join public.assessment_items i on i.assessment_id = a.id
  where a.cefr = 'A2' and a.kind in ('module', 'mid', 'final') group by a.id having count(distinct i.skill) < 4$q$) = 0,
  'кожна перевірка A2 — на 4 навички');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.cefr = 'A2' and i.lesson_id is not null and i.lesson_id not in (select id from a2_lessons)$q$) = 0,
  'завдання перевірок A2 посилаються лише на уроки A2');

-- ---------------------------------------------------------------- що бачить гість
set local role anon;
select pg_temp.ok(pg_temp.n($q$select 1 from public.modules where level_code = 'A2'$q$) = 14, 'гість бачить 14 модулів A2');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments where cefr = 'A2' and kind in ('module', 'mid', 'final')$q$) = 16,
  'гість бачить 16 перевірок A2');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
