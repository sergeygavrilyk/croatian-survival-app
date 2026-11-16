-- =====================================================================
-- Тести M28: журнал дій з черги на телефоні (public.client_ops).
-- Запускати ПІСЛЯ 20261116120000_m28_client_ops.sql.
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
  ('a2800000-0000-4000-8000-0000000000a1', 'm28-user-a@example.invalid'),
  ('b2800000-0000-4000-8000-0000000000b1', 'm28-user-b@example.invalid');

-- Дія користувача B (вставляє адмін, щоб перевірити, що A її не бачить)
insert into public.client_ops (op_id, user_id, kind, occurred_at)
values ('b2800000-0000-4000-8000-00000000000b', 'b2800000-0000-4000-8000-0000000000b1', 'lesson_completed', now() - interval '1 day');

-- Структура
select pg_temp.ok((select relrowsecurity from pg_class where oid = 'public.client_ops'::regclass),
  'RLS увімкнено');
select pg_temp.ok((select count(*) from pg_policies where schemaname = 'public' and tablename = 'client_ops'
  and cmd in ('UPDATE', 'DELETE', 'ALL')) = 0,
  'політик на зміну й видалення немає');
select pg_temp.ok(not has_table_privilege('authenticated', 'public.client_ops', 'UPDATE')
  and not has_table_privilege('authenticated', 'public.client_ops', 'DELETE'),
  'користувачу не дано прав UPDATE / DELETE');

-- Гість (anon): нічого
set local role anon;
select pg_temp.ok(pg_temp.raises($q$select count(*) from public.client_ops$q$),
  'гість не читає журнал');
select pg_temp.ok(pg_temp.raises($q$insert into public.client_ops (op_id, user_id, kind, occurred_at)
  values (gen_random_uuid(), 'a2800000-0000-4000-8000-0000000000a1', 'event', now())$q$),
  'гість не додає дій');
reset role;

-- Користувач A
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a2800000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
insert into public.client_ops (op_id, user_id, kind, occurred_at)
values ('a2800000-0000-4000-8000-00000000000a', 'a2800000-0000-4000-8000-0000000000a1', 'reading_completed', now() - interval '2 hours');
select pg_temp.ok((select count(*) from public.client_ops) = 1,
  'користувач бачить лише свої дії');
select pg_temp.ok((select received_at is not null from public.client_ops where op_id = 'a2800000-0000-4000-8000-00000000000a'),
  'час отримання ставить сервер');
select pg_temp.ok(pg_temp.raises($q$insert into public.client_ops (op_id, user_id, kind, occurred_at)
  values ('a2800000-0000-4000-8000-00000000000a', 'a2800000-0000-4000-8000-0000000000a1', 'reading_completed', now())$q$),
  'той самий номер дії вдруге не приймається');
select pg_temp.ok(pg_temp.raises($q$insert into public.client_ops (op_id, user_id, kind, occurred_at)
  values (gen_random_uuid(), 'b2800000-0000-4000-8000-0000000000b1', 'event', now())$q$),
  'дію від імені іншого користувача не додати');
select pg_temp.ok(pg_temp.raises($q$insert into public.client_ops (op_id, user_id, kind, occurred_at)
  values (gen_random_uuid(), 'a2800000-0000-4000-8000-0000000000a1', 'unknown_kind', now())$q$),
  'невідомий вид дії не приймається');
select pg_temp.ok(pg_temp.raises($q$update public.client_ops set occurred_at = now()$q$),
  'змінити свою дію не можна');
select pg_temp.ok(pg_temp.raises($q$delete from public.client_ops$q$),
  'видалити свою дію не можна');
reset role;

select pg_temp.ok((select count(*) from public.client_ops where user_id = 'b2800000-0000-4000-8000-0000000000b1') = 1,
  'дія користувача B на місці');

-- Видалення акаунта прибирає його журнал
delete from auth.users where id = 'b2800000-0000-4000-8000-0000000000b1';
select pg_temp.ok((select count(*) from public.client_ops where user_id = 'b2800000-0000-4000-8000-0000000000b1') = 0,
  'видалення акаунта прибирає журнал');

select 'ALL TESTS PASSED' as result;
rollback;
