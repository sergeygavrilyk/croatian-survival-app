-- =====================================================================
-- Інтеграційні тести M12: повторення помилок (user_errors: correct_streak, next_review_at…).
-- Запускати після M9 і M12. БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
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
  ('a1200000-0000-4000-8000-0000000000a1', 'm12-user-a@example.invalid'),
  ('b1200000-0000-4000-8000-0000000000b1', 'm12-user-b@example.invalid');
insert into public.user_errors (id, user_id, source, original_text, corrected_text, error_type) values
  ('e1200000-0000-4000-8000-0000000000a1', 'a1200000-0000-4000-8000-0000000000a1', 'roleplay', 'jedna kava molim', 'Jednu kavu, molim.', 'grammar'),
  ('e1200000-0000-4000-8000-0000000000b1', 'b1200000-0000-4000-8000-0000000000b1', 'roleplay', 'tak dobro', 'Da, molim.', 'vocabulary');

select pg_temp.ok((select correct_streak = 0 and review_count = 0 and next_review_at is null
  from public.user_errors where id = 'e1200000-0000-4000-8000-0000000000a1'), 'нова помилка: лічильники 0, повторити зараз');

-- ---------------------------------------------------------------- користувач A
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a1200000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);

update public.user_errors set correct_streak = 1, review_count = 1, next_review_at = now() + interval '1 day', last_reviewed_at = now()
  where id = 'e1200000-0000-4000-8000-0000000000a1';
select pg_temp.ok((select correct_streak from public.user_errors where id = 'e1200000-0000-4000-8000-0000000000a1') = 1,
  'A оновлює розклад своєї помилки');
select pg_temp.ok(pg_temp.n($q$select 1 from public.user_errors where resolved_at is null and (next_review_at is null or next_review_at <= now())$q$) = 0,
  'після правильної відповіді помилка не «на сьогодні»');
select pg_temp.ok(pg_temp.raises($q$update public.user_errors set correct_streak = -1 where id = 'e1200000-0000-4000-8000-0000000000a1'$q$),
  'від''ємна серія — заборонено');
select pg_temp.ok(pg_temp.raises($q$update public.user_errors set correct_streak = 5, review_count = 1 where id = 'e1200000-0000-4000-8000-0000000000a1'$q$),
  'серія не більша за кількість повторень');
update public.user_errors set correct_streak = 9, review_count = 9 where id = 'e1200000-0000-4000-8000-0000000000b1';
select pg_temp.ok(pg_temp.raises($q$delete from public.user_errors$q$)
  or pg_temp.n($q$select 1 from public.user_errors$q$) = 1, 'помилки не видаляються');

-- ---------------------------------------------------------------- перевірка від імені власника БД
reset role;
select pg_temp.ok((select review_count from public.user_errors where id = 'e1200000-0000-4000-8000-0000000000b1') = 0,
  'A не зміг змінити помилку B');
select pg_temp.ok(pg_temp.n($q$select 1 from public.user_errors where id in ('e1200000-0000-4000-8000-0000000000a1', 'e1200000-0000-4000-8000-0000000000b1')$q$) = 2,
  'обидві помилки на місці');

select 'ALL TESTS PASSED' as result;
rollback;
