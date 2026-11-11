-- =====================================================================
-- Тести M22: денний ліміт озвучення (public.tts_daily_usage, public.consume_tts_quota()).
-- Запускати ПІСЛЯ 20261111100000_m22_tts_daily_usage.sql.
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
  ('a2200000-0000-4000-8000-0000000000a1', 'm22-user-a@example.invalid'),
  ('b2200000-0000-4000-8000-0000000000b1', 'm22-user-b@example.invalid');

-- Користувачу B ліміт уже вичерпано сьогодні
insert into public.tts_daily_usage (user_id, usage_date, requests)
values ('b2200000-0000-4000-8000-0000000000b1', (now() at time zone 'utc')::date, 300);

-- Без входу (anon) функцію викликати не можна
set local role anon;
select pg_temp.ok(pg_temp.raises($q$select * from public.consume_tts_quota()$q$),
  'без входу consume_tts_quota() недоступна');
reset role;

-- Користувач A: перший запит дозволено, лічильник = 1
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a2200000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
select pg_temp.ok((select allowed and used = 1 and daily_limit = 300 from public.consume_tts_quota()),
  'перший запит за добу дозволено, used = 1, ліміт 300');
select pg_temp.ok((select allowed and used = 2 from public.consume_tts_quota()),
  'другий запит — used = 2');
select pg_temp.ok((select count(*) from public.tts_daily_usage) = 1,
  'користувач бачить лише свій рядок лічильника');
select pg_temp.ok(pg_temp.raises($q$update public.tts_daily_usage set requests = 0$q$),
  'скинути свій лічильник напряму не можна');
select pg_temp.ok(pg_temp.raises($q$update public.tts_daily_usage set requests = requests - 1$q$),
  'зменшити свій лічильник не можна');
select pg_temp.ok(pg_temp.raises($q$update public.tts_daily_usage set usage_date = usage_date - 1$q$),
  'перенести лічильник на іншу дату не можна');
select pg_temp.ok(pg_temp.raises($q$delete from public.tts_daily_usage$q$),
  'видалити свій лічильник не можна');
select pg_temp.ok(pg_temp.raises($q$insert into public.tts_daily_usage (user_id, usage_date, requests)
  values ('a2200000-0000-4000-8000-0000000000a1', current_date + 1, 0)$q$),
  'додати рядок лічильника напряму не можна');
reset role;

-- Доводимо A до 299 (тригер не дає міняти рядок, тож замінюємо його) і перевіряємо межу: 300-й — так, 301-й — ні
delete from public.tts_daily_usage where user_id = 'a2200000-0000-4000-8000-0000000000a1';
insert into public.tts_daily_usage (user_id, usage_date, requests)
values ('a2200000-0000-4000-8000-0000000000a1', (now() at time zone 'utc')::date, 299);
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a2200000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
select pg_temp.ok((select allowed and used = 300 from public.consume_tts_quota()),
  '300-й запит за добу ще дозволено');
select pg_temp.ok((select not allowed and used = 300 from public.consume_tts_quota()),
  '301-й запит — ліміт вичерпано');
reset role;
select pg_temp.ok((select requests from public.tts_daily_usage
  where user_id = 'a2200000-0000-4000-8000-0000000000a1') = 300,
  'після відмови лічильник не росте далі 300');

-- Користувач B (уже 300) — відмова; чужий лічильник не видно
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"b2200000-0000-4000-8000-0000000000b1","role":"authenticated"}', true);
select pg_temp.ok((select not allowed from public.consume_tts_quota()),
  'користувач з вичерпаним лімітом отримує відмову');
select pg_temp.ok((select count(*) from public.tts_daily_usage
  where user_id = 'a2200000-0000-4000-8000-0000000000a1') = 0,
  'чужий лічильник не видно');
update public.tts_daily_usage set requests = requests + 1
  where user_id = 'a2200000-0000-4000-8000-0000000000a1';
reset role;
select pg_temp.ok((select requests from public.tts_daily_usage
  where user_id = 'a2200000-0000-4000-8000-0000000000a1') = 300,
  'чужий лічильник змінити не можна');
set local role authenticated;
reset role;

-- Учорашній рядок не заважає сьогоднішньому ліміту
delete from public.tts_daily_usage where user_id = 'b2200000-0000-4000-8000-0000000000b1';
insert into public.tts_daily_usage (user_id, usage_date, requests)
values ('b2200000-0000-4000-8000-0000000000b1', (now() at time zone 'utc')::date - 1, 300);
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"b2200000-0000-4000-8000-0000000000b1","role":"authenticated"}', true);
select pg_temp.ok((select allowed and used = 1 from public.consume_tts_quota()),
  'нова доба — ліміт знову повний');
reset role;

rollback;
select 'ALL TESTS PASSED' as result;
