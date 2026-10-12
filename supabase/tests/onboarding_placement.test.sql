-- =====================================================================
-- Інтеграційні тести M7: профіль (онбординг) і тест рівня.
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
-- Запуск: Supabase → SQL Editor → вставити файл → Run. Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.raises(q text) returns boolean language plpgsql as $$
begin
  execute q;
  return false;
exception when others then
  return true;
end $$;

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

-- ---------------------------------------------------------------- дані (власник БД)
insert into auth.users (id, email) values
  ('a7a7a7a7-0000-4000-8000-0000000000a7', 'm7-user-a@example.invalid'),
  ('b7b7b7b7-0000-4000-8000-0000000000b7', 'm7-user-b@example.invalid');
insert into public.profiles (id, email) values
  ('a7a7a7a7-0000-4000-8000-0000000000a7', 'm7-user-a@example.invalid'),
  ('b7b7b7b7-0000-4000-8000-0000000000b7', 'm7-user-b@example.invalid')
on conflict (id) do nothing;

insert into public.assessments (id, slug, kind, title_ua, status) values
  ('a5000000-0000-4000-8000-000000000001', 'm7-test-published', 'placement', 'M7 тест', 'PUBLISHED'),
  ('a5000000-0000-4000-8000-000000000002', 'm7-test-draft', 'placement', 'M7 чернетка', 'NEEDS_REVIEW');
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, options, correct_index, status) values
  ('a5000000-0000-4000-8000-000000000001', 1, 'A0', 'vocabulary', 'тест', '["da","ne"]', 0, 'PUBLISHED'),
  ('a5000000-0000-4000-8000-000000000001', 2, 'A0', 'vocabulary', 'тест', '["da","ne"]', 1, 'NEEDS_REVIEW'),
  ('a5000000-0000-4000-8000-000000000002', 1, 'A0', 'vocabulary', 'тест', '["da","ne"]', 0, 'NEEDS_REVIEW');

-- схема
select pg_temp.ok(pg_temp.raises($q$insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, options, correct_index)
  values ('a5000000-0000-4000-8000-000000000001', 9, 'A0', 'vocabulary', 'x', '["a","b"]', 2)$q$),
  'правильна відповідь має бути серед варіантів');
select pg_temp.ok(pg_temp.raises($q$insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, options, correct_index)
  values ('a5000000-0000-4000-8000-000000000001', 9, 'C2', 'vocabulary', 'x', '["a","b"]', 0)$q$),
  'невідомий рівень питання відхиляється');

-- ---------------------------------------------------------------- користувач A
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a7a7a7a7-0000-4000-8000-0000000000a7","role":"authenticated"}', true);

select pg_temp.ok(not pg_temp.raises($q$update public.profiles set learning_goals = '{work,documents}', daily_goal_minutes = 15,
  current_level = 'A1', timezone = 'Europe/Zagreb', onboarding_completed = true, onboarding_completed_at = now()
  where id = 'a7a7a7a7-0000-4000-8000-0000000000a7'$q$),
  'користувач зберігає онбординг у свій профіль');
select pg_temp.ok((select onboarding_completed from public.profiles where id = 'a7a7a7a7-0000-4000-8000-0000000000a7'),
  'онбординг позначено завершеним');
select pg_temp.ok(pg_temp.raises($q$update public.profiles set daily_goal_minutes = 7 where id = 'a7a7a7a7-0000-4000-8000-0000000000a7'$q$),
  'щоденна ціль лише 5 / 15 / 30 / 60');
select pg_temp.ok(pg_temp.raises($q$update public.profiles set learning_goals = '{hack}' where id = 'a7a7a7a7-0000-4000-8000-0000000000a7'$q$),
  'невідома мета відхиляється');
select pg_temp.ok(pg_temp.raises($q$update public.profiles set timezone = 'x''; drop table' where id = 'a7a7a7a7-0000-4000-8000-0000000000a7'$q$),
  'некоректний часовий пояс відхиляється');
select pg_temp.ok(pg_temp.raises($q$update public.profiles set id = 'b7b7b7b7-0000-4000-8000-0000000000b7' where id = 'a7a7a7a7-0000-4000-8000-0000000000a7'$q$),
  'не можна переписати id профілю');
update public.profiles set daily_goal_minutes = 60 where id = 'b7b7b7b7-0000-4000-8000-0000000000b7';
select pg_temp.ok(pg_temp.n($q$select 1 from public.profiles where id = 'b7b7b7b7-0000-4000-8000-0000000000b7'$q$) = 0,
  'користувач не бачить чужий профіль');

select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments where slug like 'm7-test-%'$q$) = 1,
  'користувач бачить лише опублікований тест');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items where assessment_id in ('a5000000-0000-4000-8000-000000000001', 'a5000000-0000-4000-8000-000000000002')$q$) = 1,
  'користувач бачить лише опубліковані питання');
select pg_temp.ok(pg_temp.raises($q$insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, options, correct_index)
  values ('a5000000-0000-4000-8000-000000000001', 5, 'A0', 'vocabulary', 'x', '["a","b"]', 0)$q$),
  'користувач не може додати питання');

select pg_temp.ok(not pg_temp.raises($q$insert into public.assessment_attempts (assessment_id, estimated_cefr, confidence, recommended_start, answers)
  values ('a5000000-0000-4000-8000-000000000001', 'A0', 'high', 'A1', '[]')$q$),
  'користувач зберігає свою спробу (user_id підставляється)');
select pg_temp.ok(pg_temp.raises($q$insert into public.assessment_attempts (user_id, assessment_id, estimated_cefr, confidence, recommended_start)
  values ('b7b7b7b7-0000-4000-8000-0000000000b7', 'a5000000-0000-4000-8000-000000000001', 'B1', 'high', 'B1')$q$),
  'не можна записати спробу за іншого');
select pg_temp.ok(pg_temp.raises($q$insert into public.assessment_attempts (assessment_id, estimated_cefr, confidence, recommended_start, is_official)
  values ('a5000000-0000-4000-8000-000000000001', 'B2', 'high', 'B1', true)$q$),
  'результат не може бути «офіційним» сертифікатом');
select pg_temp.ok(pg_temp.raises($q$update public.assessment_attempts set estimated_cefr = 'B2'$q$),
  'результат тесту не можна змінити');

-- ---------------------------------------------------------------- користувач B
select set_config('request.jwt.claims', '{"sub":"b7b7b7b7-0000-4000-8000-0000000000b7","role":"authenticated"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_attempts$q$) = 0,
  'B не бачить спроби A');
select pg_temp.ok((select daily_goal_minutes is null from public.profiles where id = 'b7b7b7b7-0000-4000-8000-0000000000b7'),
  'A не змінив профіль B');

-- ---------------------------------------------------------------- гість
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_attempts$q$) = 0, 'гість не бачить спроб');
select pg_temp.ok(pg_temp.n($q$select 1 from public.profiles$q$) = 0, 'гість не бачить профілів');

reset role;
select 'ALL TESTS PASSED' as result;
rollback;
