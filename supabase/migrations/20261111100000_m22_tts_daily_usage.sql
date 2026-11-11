-- =====================================================================
-- M22: денний ліміт озвучення /api/tts — 300 запитів на добу (UTC) на користувача
-- (рішення власника 2026-11-11). Адитивно й ідемпотентно: можна запускати повторно.
--   * public.tts_daily_usage — лічильник: користувач × доба;
--   * public.consume_tts_quota() — +1 і відповідь «можна / ні» (SECURITY INVOKER, працює з правами користувача).
-- Без SECURITY DEFINER (security.test.sql): користувач може лише читати свій рядок, створити його
-- на сьогодні зі значенням 1 і збільшувати рівно на 1 (тригер). Скинути чи зменшити лічильник,
-- перенести на іншу дату, видалити або торкнутися чужого рядка — не можна.
-- Число 300 має збігатися з TTS_DAILY_LIMIT у lib/tts.ts (перевіряє lib/tts.test.ts).
-- =====================================================================

create table if not exists public.tts_daily_usage (
  user_id    uuid    not null references auth.users (id) on delete cascade,
  usage_date date    not null,
  requests   integer not null default 0 check (requests >= 0),
  primary key (user_id, usage_date)
);

comment on table public.tts_daily_usage is
  'Скільки запитів /api/tts зробив користувач за добу (UTC). Змінюється лише на +1 (тригер), видаляти не можна.';

alter table public.tts_daily_usage enable row level security;

revoke all on public.tts_daily_usage from anon;
revoke delete, truncate on public.tts_daily_usage from authenticated;
grant select, insert, update on public.tts_daily_usage to authenticated;

drop policy if exists "Users can read own tts usage" on public.tts_daily_usage;
create policy "Users can read own tts usage" on public.tts_daily_usage
  for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "Users can start own tts usage today" on public.tts_daily_usage;
create policy "Users can start own tts usage today" on public.tts_daily_usage
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and usage_date = (now() at time zone 'utc')::date
    and requests = 1
  );

drop policy if exists "Users can count own tts usage today" on public.tts_daily_usage;
create policy "Users can count own tts usage today" on public.tts_daily_usage
  for update to authenticated
  using (user_id = (select auth.uid()) and usage_date = (now() at time zone 'utc')::date)
  with check (user_id = (select auth.uid()) and usage_date = (now() at time zone 'utc')::date);

-- Лічильник лише росте на 1; користувача й дату змінити не можна
create or replace function public.tts_daily_usage_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.user_id is distinct from old.user_id
     or new.usage_date is distinct from old.usage_date
     or new.requests is distinct from old.requests + 1 then
    raise exception 'tts_daily_usage: лічильник можна лише збільшити на 1';
  end if;
  return new;
end
$$;

revoke all on function public.tts_daily_usage_guard() from public, anon, authenticated;

drop trigger if exists tts_daily_usage_guard on public.tts_daily_usage;
create trigger tts_daily_usage_guard
  before update on public.tts_daily_usage
  for each row execute function public.tts_daily_usage_guard();

create or replace function public.consume_tts_quota()
returns table (allowed boolean, used integer, daily_limit integer)
language plpgsql
volatile
security invoker
set search_path = ''
as $$
declare
  v_uid   uuid := (select auth.uid());
  v_limit constant integer := 300;
  v_used  integer;
begin
  if v_uid is null then
    return query select false, 0, v_limit;
    return;
  end if;

  insert into public.tts_daily_usage as t (user_id, usage_date, requests)
  values (v_uid, (now() at time zone 'utc')::date, 1)
  on conflict (user_id, usage_date) do update
    set requests = t.requests + 1
    where t.requests < v_limit
  returning t.requests into v_used;

  if v_used is null then
    -- рядок уже є і ліміт вичерпано: лічильник не росте
    return query select false, v_limit, v_limit;
    return;
  end if;

  return query select true, v_used, v_limit;
end
$$;

comment on function public.consume_tts_quota() is
  'Денний ліміт /api/tts: +1 до лічильника поточного користувача, якщо ще < 300; повертає allowed / used / daily_limit.';

revoke all on function public.consume_tts_quota() from public, anon;
grant execute on function public.consume_tts_quota() to authenticated;
