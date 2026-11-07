-- =====================================================================
-- Тести: письмо й переказ у всіх уроках, де вони вже є (партії після пілоту) · з 2026-11-07
-- Пілот A0.1 / A1.1 — writing_mediation.test.sql. Тут — модулі, які покрили партії scripts/gen_writing.py:
--   A0.2–A0.5 (20261107_writing_a0_m02_m05.sql), A0.6–A0.10 (20261107_writing_a0_m06_m10.sql).
--   Нова партія → розширити діапазон модулів нижче (посилення тесту).
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

-- уроки, які мають бути покриті: рівень → модулі
create temp table wl_scope (level text, mo int);
insert into wl_scope select 'A0', g from generate_series(1, 10) g;

create temp view wl_lessons as
select le.id, le.level_code, m.order_index mo
from public.lessons le
join public.units u on u.id = le.unit_id
join public.modules m on m.id = u.module_id
join wl_scope s on s.level = le.level_code and s.mo = m.order_index
where le.status = 'PUBLISHED';

create temp view wl_ex as
select li.lesson_id, li.required, e.*
from public.lesson_items li
join public.exercises e on e.id = li.item_id
where li.item_type = 'exercise' and e.exercise_type in ('write_message', 'mediation') and e.status = 'PUBLISHED';

select pg_temp.ok((select count(*) from wl_lessons where level_code = 'A0' and mo between 2 and 5) = 33,
  'A0.2–A0.5: 33 опубліковані уроки (як у партії)');
select pg_temp.ok((select count(*) from wl_lessons where level_code = 'A0' and mo between 6 and 10) = 29,
  'A0.6–A0.10: 29 опублікованих уроків (як у партії)');
select pg_temp.ok(pg_temp.n($q$select 1 from wl_lessons l, unnest(array['write_message', 'mediation']) k(t)
  where (select count(*) from wl_ex where wl_ex.lesson_id = l.id and wl_ex.exercise_type = k.t) <> 1$q$) = 0,
  'у кожному уроці A0.1–A0.10 — рівно одне «Напишіть повідомлення» і одне «Перекажіть другу»');
select pg_temp.ok(pg_temp.n($q$select 1 from wl_ex join wl_lessons l on l.id = wl_ex.lesson_id where wl_ex.required$q$) = 0,
  'письмо й переказ — необов’язкові');
select pg_temp.ok(pg_temp.n($q$select 1 from wl_ex join wl_lessons l on l.id = wl_ex.lesson_id
  where jsonb_array_length(task -> 'points') not between 1 and 5 or jsonb_array_length(task -> 'models') < 1
     or coalesce(task ->> 'situation_ua', '') !~ '[Ѐ-ӿ]'
     or exists (select 1 from jsonb_array_elements(task -> 'points') p
                where coalesce(p ->> 'ua', '') = '' or jsonb_typeof(p -> 'keys') <> 'array' or jsonb_array_length(p -> 'keys') < 1)$q$) = 0,
  'завдання: 1–5 пунктів з описом і ключами, зразок, ситуація українською');
select pg_temp.ok(pg_temp.n($q$select 1 from wl_ex join wl_lessons l on l.id = wl_ex.lesson_id
  where exercise_type = 'write_message' and ((task -> 'models')::text ~ '[Ѐ-ӿ]' or (task -> 'hints')::text ~ '[Ѐ-ӿ]')$q$) = 0,
  'зразки й підказки повідомлень — хорватською, без кирилиці');
select pg_temp.ok(pg_temp.n($q$select 1 from wl_ex join wl_lessons l on l.id = wl_ex.lesson_id
  where exercise_type = 'mediation' and l.level_code = 'A0'
    and (task ->> 'direction' <> 'hr_ua' or coalesce(task ->> 'source_hr', '') = '' or task ->> 'source_hr' ~ '[Ѐ-ӿ]'
         or (task -> 'models' ->> 0) !~ '[Ѐ-ӿ]')$q$) = 0,
  'переказ A0: хорватський текст → відповідь українською');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_reviews r join wl_ex on wl_ex.id = r.entity_id
  where r.entity_type = 'exercise' and r.notes like 'writing 20261107 (a0_m02_m05)%'$q$) = 66,
  'журнал перевірок: 66 записів партії A0.2–A0.5');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_reviews r join wl_ex on wl_ex.id = r.entity_id
  where r.entity_type = 'exercise' and r.notes like 'writing 20261107 (a0_m06_m10)%'$q$) = 58,
  'журнал перевірок: 58 записів партії A0.6–A0.10');

select 'ALL TESTS PASSED' as result;
rollback;
