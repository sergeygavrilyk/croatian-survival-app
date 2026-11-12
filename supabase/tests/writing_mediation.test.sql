-- =====================================================================
-- Тести: письмо й переказ в уроці (M19) і пілот A0.1 / A1.1 · 2026-11-05
-- Запускати ПІСЛЯ міграції 20261105100000_m19_writing_mediation.sql і пакета 20261105_writing_pilot.sql.
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

create or replace function pg_temp.raises(q text) returns boolean language plpgsql as $$
begin
  execute q;
  return false;
exception when others then
  return true;
end $$;

-- ---------------------------------------------------------------- вправи пілоту
create temp view wx as
select le.id lesson_id, le.level_code, m.order_index mo, e.*
from public.lesson_items li
join public.exercises e on e.id = li.item_id
join public.lessons le on le.id = li.lesson_id and le.status = 'PUBLISHED'
join public.units u on u.id = le.unit_id
join public.modules m on m.id = u.module_id
where li.item_type = 'exercise' and e.exercise_type in ('write_message', 'mediation') and e.status = 'PUBLISHED';

select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons le join public.units u on u.id = le.unit_id join public.modules m on m.id = u.module_id
  where le.status = 'PUBLISHED' and le.level_code in ('A0', 'A1') and m.order_index = 1
    and (select count(*) from wx where wx.lesson_id = le.id and wx.exercise_type = 'write_message') <> 1
     or le.status = 'PUBLISHED' and le.level_code in ('A0', 'A1') and m.order_index = 1
    and (select count(*) from wx where wx.lesson_id = le.id and wx.exercise_type = 'mediation') <> 1$q$) = 0,
  'у кожному уроці A0.1 і A1.1 — одне «Напишіть повідомлення» і одне «Перекажіть другу»');
select pg_temp.ok(pg_temp.n($q$select 1 from wx where jsonb_array_length(task -> 'points') not between 1 and 5
  or jsonb_array_length(task -> 'models') < 1 or coalesce(task ->> 'situation_ua', '') !~ '[Ѐ-ӿ]'$q$) = 0,
  'завдання: 1–5 пунктів, зразок, ситуація українською');
select pg_temp.ok(pg_temp.n($q$select 1 from wx, jsonb_array_elements(task -> 'points') p
  where jsonb_typeof(p -> 'keys') <> 'array' or jsonb_array_length(p -> 'keys') < 1 or coalesce(p ->> 'ua', '') = ''$q$) = 0,
  'кожен пункт має опис і ключі для перевірки');
select pg_temp.ok(pg_temp.n($q$select 1 from wx where exercise_type = 'write_message'
  and (task -> 'models')::text ~ '[Ѐ-ӿ]'$q$) = 0, 'зразки повідомлень — хорватською, без кирилиці');
select pg_temp.ok(pg_temp.n($q$select 1 from wx where exercise_type = 'mediation' and (level_code = 'A0' or level_code = 'A1' and mo <= 10)
  and (task ->> 'direction' <> 'hr_ua' or coalesce(task ->> 'source_hr', '') ~ '[Ѐ-ӿ]' or coalesce(task ->> 'source_hr', '') = ''
       or (task -> 'models' ->> 0) !~ '[Ѐ-ӿ]')$q$) = 0,
  'переказ A0–A1.10: хорватський текст → відповідь українською');
select pg_temp.ok(pg_temp.n($q$select 1 from wx where exercise_type = 'mediation' and level_code = 'A2'
  and (task ->> 'direction' <> 'ua_hr' or coalesce(task ->> 'friend_ua', '') !~ '[Ѐ-ӿ]' or (task -> 'models' ->> 0) ~ '[Ѐ-ӿ]')$q$) = 0,
  'переказ A2 (рішення 2026-11-12): прохання друга українською → відповідь хорватською (ua_hr)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items li join public.exercises e on e.id = li.item_id
  where li.item_type = 'exercise' and e.exercise_type in ('write_message', 'mediation') and li.required$q$) = 0,
  'письмо й переказ — необов’язкові (можна пропустити)');
select pg_temp.ok(pg_temp.raises($q$insert into public.exercises (exercise_type, question_text, correct_answer, task)
  values ('write_message', 'Тест', 'Test.', '{"points": [], "models": ["Test."]}'::jsonb)$q$), 'завдання без пунктів — не приймається');
select pg_temp.ok(pg_temp.raises($q$insert into public.exercises (exercise_type, question_text, correct_answer, task)
  values ('multiple_choice', 'Тест', 'a', '{"points": []}'::jsonb)$q$), 'task лише для письма й переказу');

-- ---------------------------------------------------------------- спроби: RLS, лише текст
insert into auth.users (id, email) values
  ('a1900000-0000-4000-8000-0000000000a1', 'm19-user-a@example.invalid'),
  ('b1900000-0000-4000-8000-0000000000b1', 'm19-user-b@example.invalid');

set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.raises($q$select 1 from public.writing_attempts$q$)
  or pg_temp.n($q$select 1 from public.writing_attempts$q$) = 0, 'гість не бачить спроб письма');
select pg_temp.ok(pg_temp.raises($q$insert into public.writing_attempts (user_id, text, points_total, points_ok, outcome)
  values ('a1900000-0000-4000-8000-0000000000a1', 'Bok', 1, 1, 'correct')$q$), 'гість не може записати спробу');

reset role;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a1900000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
insert into public.writing_attempts (user_id, exercise_id, text, points_total, points_ok, outcome)
select 'a1900000-0000-4000-8000-0000000000a1', id, 'Bok, Dašo! Dobro sam, hvala. A ti?', 3, 3, 'correct'
from public.exercises where exercise_type = 'write_message' and status = 'PUBLISHED' limit 1;
insert into public.mediation_attempts (user_id, exercise_id, direction, text, points_total, points_ok, outcome)
select 'a1900000-0000-4000-8000-0000000000a1', id, 'hr_ua', 'У неділю зачинено.', 2, 1, 'wrong'
from public.exercises where exercise_type = 'mediation' and status = 'PUBLISHED' limit 1;
select pg_temp.ok(pg_temp.n($q$select 1 from public.writing_attempts$q$) = 1
  and pg_temp.n($q$select 1 from public.mediation_attempts$q$) = 1, 'A записує свої спроби письма й переказу');
select pg_temp.ok(pg_temp.raises($q$insert into public.writing_attempts (user_id, text, points_total, points_ok, outcome)
  values ('b1900000-0000-4000-8000-0000000000b1', 'Bok', 1, 1, 'correct')$q$), 'A не може записати спробу від імені B');
select pg_temp.ok(pg_temp.raises($q$insert into public.writing_attempts (user_id, text, points_total, points_ok, outcome)
  values ('a1900000-0000-4000-8000-0000000000a1', 'Bok', 1, 2, 'correct')$q$), 'виконаних пунктів не більше, ніж усього');
select pg_temp.ok(pg_temp.raises($q$update public.writing_attempts set text = 'x'$q$)
  or pg_temp.n($q$select 1 from public.writing_attempts where text = 'x'$q$) = 0, 'спробу не можна змінити');

select set_config('request.jwt.claims', '{"sub":"b1900000-0000-4000-8000-0000000000b1","role":"authenticated"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.writing_attempts$q$) = 0
  and pg_temp.n($q$select 1 from public.mediation_attempts$q$) = 0, 'B не бачить спроб A');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
