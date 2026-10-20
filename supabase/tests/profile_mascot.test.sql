-- =====================================================================
-- Тести M18: талісман у профілі (profiles.mascot: pjegica / sime / tocka).
-- Запускати ПІСЛЯ 20261020180000_m18_profile_mascot.sql.
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

insert into auth.users (id, email) values
  ('a1800000-0000-4000-8000-0000000000a1', 'm18-user-a@example.invalid'),
  ('b1800000-0000-4000-8000-0000000000b1', 'm18-user-b@example.invalid');
insert into public.profiles (id, email) values
  ('a1800000-0000-4000-8000-0000000000a1', 'm18-user-a@example.invalid'),
  ('b1800000-0000-4000-8000-0000000000b1', 'm18-user-b@example.invalid')
on conflict (id) do nothing;

select pg_temp.ok((select mascot from public.profiles where id = 'a1800000-0000-4000-8000-0000000000a1') is null,
  'новий профіль: талісман не обрано (null)');
select pg_temp.ok(pg_temp.raises($q$update public.profiles set mascot = 'cat' where id = 'a1800000-0000-4000-8000-0000000000a1'$q$),
  'невідомий талісман відхиляється');
select pg_temp.ok(pg_temp.raises($q$update public.profiles set mascot = 'female' where id = 'a1800000-0000-4000-8000-0000000000a1'$q$),
  'старі значення female / male більше не приймаються');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a1800000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
update public.profiles set mascot = 'sime' where id = 'a1800000-0000-4000-8000-0000000000a1';
select pg_temp.ok((select mascot from public.profiles where id = 'a1800000-0000-4000-8000-0000000000a1') = 'sime',
  'користувач обирає свого талісмана');
update public.profiles set mascot = 'tocka' where id = 'b1800000-0000-4000-8000-0000000000b1';
select pg_temp.ok((select count(*) from public.profiles where id = 'b1800000-0000-4000-8000-0000000000b1') = 0,
  'чужий профіль не видно');
reset role;
select pg_temp.ok((select mascot from public.profiles where id = 'b1800000-0000-4000-8000-0000000000b1') is null,
  'чужого талісмана змінити не можна');

select 'ALL TESTS PASSED' as result;
rollback;
