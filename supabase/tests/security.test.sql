-- =====================================================================
-- Тести безпеки схеми (дзеркало Supabase Security Advisor). Лише читання.
-- Запуск: Supabase → SQL Editor → Run. Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

-- RLS увімкнено на кожній таблиці схеми public
select pg_temp.ok(
  not exists (
    select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relkind = 'r' and not c.relrowsecurity
  ),
  'RLS увімкнено на всіх таблицях public');

-- Жодна SECURITY DEFINER функція в public не доступна гостю чи користувачу через API
select pg_temp.ok(
  not exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.prosecdef
      and (has_function_privilege('anon', p.oid, 'execute') or has_function_privilege('authenticated', p.oid, 'execute'))
  ),
  'SECURITY DEFINER функції не викликаються через API');

-- SECURITY DEFINER функції мають зафіксований search_path
select pg_temp.ok(
  not exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.prosecdef
      and not exists (select 1 from unnest(coalesce(p.proconfig, '{}')) c where c like 'search_path=%')
  ),
  'SECURITY DEFINER функції мають search_path');

-- Розширення не лежать у public
select pg_temp.ok(
  not exists (select 1 from pg_extension where extnamespace = 'public'::regnamespace),
  'жодного розширення в схемі public');

-- Журнал аналітики append-only
select pg_temp.ok(
  not has_table_privilege('authenticated', 'public.analytics_events', 'update')
  and not has_table_privilege('authenticated', 'public.analytics_events', 'delete'),
  'analytics_events не можна змінювати чи видаляти');

-- M2: таблиця з колонкою status не має політики «читати все» (using true) — лише PUBLISHED (§124, §126)
select pg_temp.ok(
  not exists (
    select 1 from pg_policies p
    join information_schema.columns c
      on c.table_schema = p.schemaname and c.table_name = p.tablename and c.column_name = 'status'
    where p.schemaname = 'public' and p.cmd in ('SELECT', 'ALL') and p.qual = 'true'
  ),
  'контент зі статусом не відкритий для читання всім');

-- M3: адміністраторів не можна додати через API; email не є межею безпеки
select pg_temp.ok(
  not has_table_privilege('authenticated', 'public.app_admins', 'insert')
  and not has_table_privilege('authenticated', 'public.app_admins', 'update')
  and not has_table_privilege('anon', 'public.app_admins', 'insert'),
  'app_admins не змінюється через API');
select pg_temp.ok(
  not exists (
    select 1 from pg_policies
    where schemaname = 'public' and (coalesce(qual, '') ilike '%email%' or coalesce(with_check, '') ilike '%email%')
  ),
  'жодна політика не перевіряє email');

-- Журнали append-only: облік AI, рев'ю і версії контенту
select pg_temp.ok(
  not exists (
    select 1 from unnest(array['public.ai_usage_events', 'public.content_reviews', 'public.content_versions', 'public.speaking_attempts', 'public.assessment_attempts', 'public.ai_messages']) t
    where has_table_privilege('authenticated', t, 'update') or has_table_privilege('authenticated', t, 'delete')
  ),
  'журнали AI, рев''ю, версій, говоріння, тестів і повідомлень AI не можна змінювати чи видаляти');

select 'ALL TESTS PASSED' as result;
rollback;
