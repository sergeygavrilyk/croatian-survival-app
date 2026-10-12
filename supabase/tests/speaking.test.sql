-- =====================================================================
-- Інтеграційні тести M8: говоріння (speaking_sessions, speaking_attempts).
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

insert into auth.users (id, email) values
  ('a8a8a8a8-0000-4000-8000-0000000000a8', 'm8-user-a@example.invalid'),
  ('b8b8b8b8-0000-4000-8000-0000000000b8', 'm8-user-b@example.invalid');
insert into public.speaking_sessions (id, user_id, source, mode) values
  ('5b000000-0000-4000-8000-0000000000b8', 'b8b8b8b8-0000-4000-8000-0000000000b8', 'situation', 'repeat');

-- ---------------------------------------------------------------- користувач A
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a8a8a8a8-0000-4000-8000-0000000000a8","role":"authenticated"}', true);

select pg_temp.ok(not pg_temp.raises($q$insert into public.speaking_sessions (id, source, situation, mode)
  values ('5a000000-0000-4000-8000-0000000000a8', 'situation', 'health', 'repeat')$q$),
  'A починає сесію говоріння (user_id підставляється)');
select pg_temp.ok(not pg_temp.raises($q$insert into public.speaking_attempts (session_id, target_text, mode, transcript, verdict, match_score, missed_words, retry_number, duration_ms)
  values ('5a000000-0000-4000-8000-0000000000a8', 'Boli me glava.', 'repeat', 'boli me glava', 'great', 1, '{}', 0, 2100)$q$),
  'A записує спробу у свою сесію');
select pg_temp.ok(pg_temp.raises($q$insert into public.speaking_attempts (session_id, target_text, mode, verdict)
  values ('5b000000-0000-4000-8000-0000000000b8', 'x', 'repeat', 'great')$q$),
  'A не може записати спробу в чужу сесію');
select pg_temp.ok(pg_temp.raises($q$insert into public.speaking_attempts (user_id, target_text, mode, verdict)
  values ('b8b8b8b8-0000-4000-8000-0000000000b8', 'x', 'repeat', 'great')$q$),
  'A не може записати спробу за іншого');
select pg_temp.ok(pg_temp.raises($q$insert into public.speaking_attempts (target_text, mode, verdict) values ('x', 'repeat', 'perfect')$q$),
  'невідомий вердикт відхиляється');
select pg_temp.ok(pg_temp.raises($q$insert into public.speaking_attempts (target_text, mode, verdict, match_score) values ('x', 'repeat', 'great', 1.5)$q$),
  'частка збігу лише 0…1');
select pg_temp.ok(pg_temp.raises($q$insert into public.speaking_sessions (source, situation, mode) values ('situation', '../admin', 'repeat')$q$),
  'некоректний код ситуації відхиляється');
select pg_temp.ok(pg_temp.raises($q$update public.speaking_attempts set verdict = 'great'$q$),
  'спроби не можна змінювати (append-only)');
update public.speaking_sessions set ended_at = now(), attempts_count = 1 where id = '5a000000-0000-4000-8000-0000000000a8';
select pg_temp.ok(pg_temp.n($q$select 1 from public.speaking_sessions where ended_at is not null and attempts_count = 1$q$) = 1,
  'A завершує свою сесію');
update public.speaking_sessions set attempts_count = 99 where id = '5b000000-0000-4000-8000-0000000000b8';
select pg_temp.ok(pg_temp.n($q$select 1 from public.speaking_sessions$q$) = 1, 'A бачить лише свою сесію');
select pg_temp.ok(pg_temp.raises($q$update public.speaking_sessions set user_id = 'b8b8b8b8-0000-4000-8000-0000000000b8' where id = '5a000000-0000-4000-8000-0000000000a8'$q$),
  'сесію не можна передати іншому');

-- ---------------------------------------------------------------- користувач B
select set_config('request.jwt.claims', '{"sub":"b8b8b8b8-0000-4000-8000-0000000000b8","role":"authenticated"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.speaking_attempts$q$) = 0, 'B не бачить спроб A');
select pg_temp.ok((select attempts_count from public.speaking_sessions where id = '5b000000-0000-4000-8000-0000000000b8') = 0,
  'A не змінив сесію B');

-- ---------------------------------------------------------------- гість
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.speaking_attempts$q$) = 0, 'гість не бачить спроб');
select pg_temp.ok(pg_temp.raises($q$insert into public.speaking_sessions (source, mode) values ('free', 'repeat')$q$),
  'гість не може почати сесію');

reset role;
select 'ALL TESTS PASSED' as result;
rollback;
