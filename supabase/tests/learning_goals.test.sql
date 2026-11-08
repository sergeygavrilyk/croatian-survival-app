-- =====================================================================
-- Тести: мети навчання в профілі (M7 + M21 «Навчання») · 2026-11-08
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK. Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

create or replace function pg_temp.raises(q text) returns boolean language plpgsql as $$
begin
  execute q;
  return false;
exception when others then
  return true;
end $$;

select pg_temp.ok((select pg_get_constraintdef(oid) from pg_constraint
  where conname = 'profiles_learning_goals_check' and conrelid = 'public.profiles'::regclass) like '%study%',
  'обмеження мет знає «study»');
select pg_temp.ok((select count(*) from pg_constraint
  where conname = 'profiles_learning_goals_check' and conrelid = 'public.profiles'::regclass) = 1,
  'обмеження мет — одне');

insert into auth.users (id, email) values ('b8b8b8b8-0000-4000-8000-0000000000b8', 'goals-test@example.com')
  on conflict (id) do nothing;
insert into public.profiles (id, email) values ('b8b8b8b8-0000-4000-8000-0000000000b8', 'goals-test@example.com') on conflict (id) do nothing;

select pg_temp.ok(not pg_temp.raises($q$update public.profiles set learning_goals = '{study,travel}'
  where id = 'b8b8b8b8-0000-4000-8000-0000000000b8'$q$), 'мети «Навчання» і «Туризм і подорожі» зберігаються');
select pg_temp.ok(not pg_temp.raises($q$update public.profiles set learning_goals = '{daily_life,work,documents,social,travel,study}'
  where id = 'b8b8b8b8-0000-4000-8000-0000000000b8'$q$), 'усі шість мет разом');
select pg_temp.ok(pg_temp.raises($q$update public.profiles set learning_goals = '{tourism}'
  where id = 'b8b8b8b8-0000-4000-8000-0000000000b8'$q$), 'невідома мета відхиляється');

select 'ALL TESTS PASSED' as result;
rollback;
