-- =====================================================================
-- Інтеграційні тести M11: збережені переклади (translation_cache).
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
  ('a1111111-0000-4000-8000-0000000000a1', 'm11-user-a@example.invalid'),
  ('b1111111-0000-4000-8000-0000000000b1', 'm11-user-b@example.invalid');
insert into public.translation_cache (user_id, source_norm, source_text, translation_hr) values
  ('b1111111-0000-4000-8000-0000000000b1', 'де аптека', 'Де аптека?', 'Gdje je ljekarna?');

-- ---------------------------------------------------------------- користувач A
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a1111111-0000-4000-8000-0000000000a1","role":"authenticated"}', true);

select pg_temp.ok(not pg_temp.raises($q$insert into public.translation_cache (source_norm, source_text, translation_hr, model)
  values ('де каса', 'Де каса?', 'Gdje je blagajna?', 'gemini-3.6-flash')$q$), 'A зберігає свій переклад (user_id — автоматично)');
select pg_temp.ok((select user_id from public.translation_cache where source_norm = 'де каса') = 'a1111111-0000-4000-8000-0000000000a1',
  'user_id = поточний користувач');
select pg_temp.ok(pg_temp.raises($q$insert into public.translation_cache (source_norm, source_text, translation_hr)
  values ('де каса', 'де каса', 'x')$q$), 'дубль тієї самої фрази — заборонено (unique)');
select pg_temp.ok(pg_temp.raises($q$insert into public.translation_cache (user_id, source_norm, source_text, translation_hr)
  values ('b1111111-0000-4000-8000-0000000000b1', 'чуже', 'чуже', 'x')$q$), 'A не може записати переклад від імені B');
select pg_temp.ok(pg_temp.raises($q$insert into public.translation_cache (source_norm, source_text, translation_hr)
  values ('', 'x', 'x')$q$), 'порожній ключ — заборонено');
select pg_temp.ok(pg_temp.raises($q$insert into public.translation_cache (source_norm, source_text, translation_hr)
  values ('довгий', 'x', repeat('a', 501))$q$), 'переклад довший за 500 символів — заборонено');
select pg_temp.ok(pg_temp.n($q$select 1 from public.translation_cache$q$) = 1, 'A бачить лише свій переклад');
update public.translation_cache set hits = hits + 1, last_used_at = now() where source_norm = 'де каса';
select pg_temp.ok((select hits from public.translation_cache where source_norm = 'де каса') = 1, 'A оновлює лічильник свого перекладу');
update public.translation_cache set translation_hr = 'зламано' where source_norm = 'де аптека';
select pg_temp.ok(pg_temp.raises($q$update public.translation_cache set user_id = 'b1111111-0000-4000-8000-0000000000b1' where source_norm = 'де каса'$q$),
  'A не може передати свій переклад B');

-- ---------------------------------------------------------------- користувач B
select set_config('request.jwt.claims', '{"sub":"b1111111-0000-4000-8000-0000000000b1","role":"authenticated"}', true);
select pg_temp.ok((select translation_hr from public.translation_cache where source_norm = 'де аптека') = 'Gdje je ljekarna?',
  'A не зміг змінити переклад B');
select pg_temp.ok(pg_temp.n($q$select 1 from public.translation_cache where source_norm = 'де каса'$q$) = 0, 'B не бачить переклад A');
delete from public.translation_cache where source_norm = 'де каса';

-- ---------------------------------------------------------------- гість
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.raises($q$select 1 from public.translation_cache$q$), 'гість не має доступу до перекладів');

reset role;
select pg_temp.ok(pg_temp.n($q$select 1 from public.translation_cache where source_norm = 'де каса'$q$) = 1, 'B не видалив переклад A');
select 'ALL TESTS PASSED' as result;
rollback;
