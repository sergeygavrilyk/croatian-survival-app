-- =====================================================================
-- M3 · Адміни за роллю замість email (§124, §126 ТЗ) · 2026-10-12
-- Адитивна, ідемпотентна (можна запускати повторно).
--
--   * public.app_admins — хто адмін (за user_id, а не за email).
--   * public.is_admin() — чи поточний користувач адмін; використовується в RLS.
--   * Політики «лише для email …» на lexemes / conversations / conversation_turns
--     замінено на політики за роллю.
--   * Адмін може читати все (включно з чернетками), додавати й змінювати контент
--     у всіх таблицях контенту. ВИДАЛЯТИ контент через застосунок не можна —
--     застарілий контент позначаємо DEPRECATED (видалення — лише в SQL Editor).
--   * Адмін бачить усі події аналітики (для звітів); користувач — лише свої.
--
-- ВАЖЛИВО: після цієї міграції email у політиках більше не діє.
-- Додайте себе в app_admins тим самим запуском (див. інструкцію в PROJECT_STATE.md):
--   insert into public.app_admins (user_id)
--   select id from auth.users where email = '<ваш email>'
--   on conflict (user_id) do nothing;
-- =====================================================================

-- 1. Хто адмін
create table if not exists public.app_admins (
  user_id     uuid primary key references auth.users(id) on delete cascade,
  role        text not null default 'admin' check (role in ('admin')),
  note        text,
  created_at  timestamptz not null default now()
);

alter table public.app_admins enable row level security;

-- Користувач бачить лише власний рядок (так is_admin() працює без SECURITY DEFINER).
-- Записів через API немає: адмінів додає лише власник БД у SQL Editor.
drop policy if exists "Users can see own admin row" on public.app_admins;
create policy "Users can see own admin row" on public.app_admins
  for select to authenticated
  using (user_id = (select auth.uid()));

revoke insert, update, delete, truncate on public.app_admins from anon, authenticated;

-- 2. Перевірка ролі (SECURITY INVOKER: читає лише власний рядок через RLS вище)
create or replace function public.is_admin()
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select exists (
    select 1 from public.app_admins a
    where a.user_id = (select auth.uid()) and a.role = 'admin'
  );
$$;

grant execute on function public.is_admin() to anon, authenticated;

-- 3. Прибрати політики за email (§124: email не може бути межею безпеки)
drop policy if exists "Allow inserts only for admins" on public.lexemes;
drop policy if exists "Allow updates only for admins" on public.lexemes;
drop policy if exists "Allow inserts only for admins" on public.conversations;
drop policy if exists "Allow updates only for admins" on public.conversations;
drop policy if exists "Allow inserts only for admins" on public.conversation_turns;
drop policy if exists "Allow updates only for admins" on public.conversation_turns;

-- 4. Адмін: читати все, додавати, змінювати — у всіх таблицях контенту
do $$
declare
  t text;
begin
  foreach t in array array[
    'levels', 'modules', 'units', 'lessons', 'lesson_items', 'lesson_grammar',
    'exercises', 'grammar_topics', 'grammar_rules', 'word_families',
    'lexemes', 'phrases', 'conversations', 'conversation_turns'
  ]
  loop
    execute format('drop policy if exists "Admins can read all %1$s" on public.%1$I', t);
    execute format('create policy "Admins can read all %1$s" on public.%1$I for select to authenticated using ((select public.is_admin()))', t);

    execute format('drop policy if exists "Admins can insert %1$s" on public.%1$I', t);
    execute format('create policy "Admins can insert %1$s" on public.%1$I for insert to authenticated with check ((select public.is_admin()))', t);

    execute format('drop policy if exists "Admins can update %1$s" on public.%1$I', t);
    execute format('create policy "Admins can update %1$s" on public.%1$I for update to authenticated using ((select public.is_admin())) with check ((select public.is_admin()))', t);
  end loop;
end $$;

-- 5. Аналітика: адмін бачить усі події (журнал лишається append-only)
drop policy if exists "Admins can view all analytics events" on public.analytics_events;
create policy "Admins can view all analytics events" on public.analytics_events
  for select to authenticated
  using ((select public.is_admin()));

-- 6. Нагадування, якщо адміна ще немає
do $$
begin
  if not exists (select 1 from public.app_admins) then
    raise notice 'M3: у app_admins ще немає жодного адміна — додайте себе (див. коментар угорі файлу).';
  end if;
end $$;
