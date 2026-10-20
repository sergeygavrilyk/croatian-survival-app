-- =====================================================================
-- Тести: середина й фінал рівня A0 під уроки за темою (curriculum_a0_v4) · 2026-10-20
-- Запускати ПІСЛЯ supabase/data_fixes/20261020_assessments_a0_v4_level.sql.
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

-- Опубліковані завдання середини й фіналу з модулем уроку-джерела
create temp view lvl as
select a.slug, i.*, m.order_index as module_order, l.status as lesson_status, l.level_code as lesson_level
from public.assessment_items i
join public.assessments a on a.id = i.assessment_id
left join public.lessons l on l.id = i.lesson_id
left join public.units u on u.id = l.unit_id
left join public.modules m on m.id = u.module_id
where a.slug in ('a0-mid', 'a0-final') and i.status = 'PUBLISHED';

-- ---------------------------------------------------------------- склад
select pg_temp.ok(pg_temp.n($q$select 1 from lvl where slug = 'a0-mid'$q$) = 20, 'a0-mid: 20 опублікованих завдань');
select pg_temp.ok(pg_temp.n($q$select 1 from lvl where slug = 'a0-final'$q$) = 30, 'a0-final: 30 опублікованих завдань');
select pg_temp.ok(pg_temp.n($q$select area, count(*) from lvl where slug = 'a0-mid' group by area having count(*) = 5$q$) = 4,
  'a0-mid: по 5 завдань на кожну з 4 навичок §60');
select pg_temp.ok(pg_temp.n($q$select 1 from lvl where slug = 'a0-final' group by area
  having (area in ('understand', 'produce') and count(*) = 8) or (area in ('interact', 'mediate') and count(*) = 7)$q$) = 4,
  'a0-final: 8 / 7 / 7 / 8 завдань на навички');
select pg_temp.ok(pg_temp.n($q$select slug, order_index from lvl group by 1, 2 having count(*) > 1$q$) = 0
  and pg_temp.n($q$select 1 from lvl where order_index not between 1 and 30$q$) = 0,
  'місця завдань 1…N без повторів');

-- ---------------------------------------------------------------- старі завдання не видалено
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug in ('a0-mid', 'a0-final') and i.status = 'DEPRECATED' and i.order_index > 100$q$) = 50,
  'старі 50 завдань — DEPRECATED (місця зсунуто на +100), не видалені');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_versions cv join public.assessments a on a.id = cv.entity_id
  where cv.entity_type = 'assessment' and a.slug in ('a0-mid', 'a0-final')
    and cv.change_reason like 'curriculum_a0_v4: перевірку рівня%' and jsonb_array_length(cv.payload->'items') > 0$q$) = 2,
  'стара версія обох тестів — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_reviews r join public.assessments a on a.id = r.entity_id
  where r.entity_type = 'assessment' and a.slug in ('a0-mid', 'a0-final') and r.notes like 'Бета: перевірку рівня оновлено%'$q$) = 2,
  'запис у журналі перевірки для обох тестів');

-- ---------------------------------------------------------------- джерела — нові уроки A0
select pg_temp.ok(pg_temp.n($q$select 1 from lvl where lesson_id is null and passage_hr is null$q$) = 0,
  'кожне завдання, крім читання, посилається на урок');
select pg_temp.ok(pg_temp.n($q$select 1 from lvl where lesson_id is not null and (lesson_status <> 'PUBLISHED' or lesson_level <> 'A0')$q$) = 0,
  'уроки-джерела — опубліковані уроки A0');
select pg_temp.ok(pg_temp.n($q$select 1 from lvl where slug = 'a0-mid' and module_order > 5$q$) = 0,
  'a0-mid: лише модулі A0.1–A0.5');
select pg_temp.ok(pg_temp.n($q$select distinct module_order from lvl where slug = 'a0-final' and module_order is not null$q$) = 10,
  'a0-final: завдання з усіх 10 модулів');
select pg_temp.ok(pg_temp.n($q$select 1 from lvl where lesson_id is not null and not exists (
    select 1 from public.lessons l2 where l2.id = lvl.lesson_id and l2.title_ua ~ '^Урок [0-9]+: ')$q$) = 0,
  'уроки-джерела — нумеровані уроки за темою');

-- ---------------------------------------------------------------- без повторів з перевірками модулів
select pg_temp.ok(pg_temp.n($q$select 1 from lvl x join public.assessment_items i on i.status = 'PUBLISHED'
  join public.assessments a on a.id = i.assessment_id and a.slug ~ '^a0-m[0-9]{2}$'
  where coalesce(x.audio_hr, x.answer_text) is not null
    and lower(coalesce(x.audio_hr, x.answer_text)) in (lower(i.audio_hr), lower(i.answer_text), lower(i.prompt_hr))$q$) = 0,
  'репліки й відповіді середини та фіналу не повторюють перевірок модулів');
select pg_temp.ok(pg_temp.n($q$select 1 from lvl x join lvl y on x.slug = 'a0-mid' and y.slug = 'a0-final'
  where lower(coalesce(x.audio_hr, x.answer_text, '-')) = lower(coalesce(y.audio_hr, y.answer_text, '+'))$q$) = 0,
  'середина й фінал не повторюють одна одну');

-- ---------------------------------------------------------------- якість
select pg_temp.ok(pg_temp.n($q$select 1 from lvl where coalesce(audio_hr, '') || coalesce(answer_text, '') || coalesce(passage_hr, '') ~ '[Ѐ-ӿ]'$q$) = 0,
  'хорватське без кирилиці');
select pg_temp.ok(pg_temp.n($q$select 1 from lvl where item_type = 'multiple_choice'
  and (correct_index is null or correct_index >= jsonb_array_length(options) or jsonb_array_length(options) < 3)$q$) = 0,
  'вибір: 3 варіанти й правильний індекс у межах');
select pg_temp.ok(pg_temp.n($q$select 1 from lvl where (prompt_ua || coalesce(explanation_ua, '')) ~* 'placeholder|todo|osnovni_pojam|базовий термін'$q$) = 0,
  'без заглушок');

-- ---------------------------------------------------------------- гість бачить лише опубліковане
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug in ('a0-mid', 'a0-final')$q$) = 50, 'гість бачить 50 опублікованих завдань, старих — ні');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
