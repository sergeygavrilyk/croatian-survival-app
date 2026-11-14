-- =====================================================================
-- Тести M26: перемикач «Показувати контент 18+» (profiles.adult_content).
-- Запускати ПІСЛЯ 20261114100000_m26_profile_adult_content.sql.
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
-- Успіх: «ALL TESTS PASSED».
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
  ('a2600000-0000-4000-8000-0000000000a1', 'm26-user-a@example.invalid'),
  ('b2600000-0000-4000-8000-0000000000b1', 'm26-user-b@example.invalid');
insert into public.profiles (id, email) values
  ('a2600000-0000-4000-8000-0000000000a1', 'm26-user-a@example.invalid'),
  ('b2600000-0000-4000-8000-0000000000b1', 'm26-user-b@example.invalid')
on conflict (id) do nothing;

select pg_temp.ok((select adult_content from public.profiles where id = 'a2600000-0000-4000-8000-0000000000a1') = false,
  'новий профіль: контент 18+ вимкнено');
select pg_temp.ok((select count(*) from public.profiles where adult_content is null) = 0,
  'порожніх значень немає (not null, default false)');
select pg_temp.ok(pg_temp.raises($q$update public.profiles set adult_content = null where id = 'a2600000-0000-4000-8000-0000000000a1'$q$),
  'null не приймається');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a2600000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
update public.profiles set adult_content = true where id = 'a2600000-0000-4000-8000-0000000000a1';
select pg_temp.ok((select adult_content from public.profiles where id = 'a2600000-0000-4000-8000-0000000000a1') = true,
  'користувач вмикає контент 18+ у своєму профілі');
update public.profiles set adult_content = true where id = 'b2600000-0000-4000-8000-0000000000b1';
select pg_temp.ok((select count(*) from public.profiles where id = 'b2600000-0000-4000-8000-0000000000b1') = 0,
  'чужий профіль не видно');
reset role;
select pg_temp.ok((select adult_content from public.profiles where id = 'b2600000-0000-4000-8000-0000000000b1') = false,
  'чужий перемикач змінити не можна');

select 'ALL TESTS PASSED' as result;
rollback;
