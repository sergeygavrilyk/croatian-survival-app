-- =====================================================================
-- M5 · Закриття попереджень безпеки Supabase (Security Advisor) · 2026-10-12
-- Ідемпотентна: можна запускати повторно.
-- =====================================================================

-- 1. handle_new_user — службова тригерна функція (створює профіль після реєстрації).
--    Вона SECURITY DEFINER і була доступна через API: POST /rest/v1/rpc/handle_new_user.
--    Забираємо право виклику в усіх ролей API. Тригер on_auth_user_created працює й далі:
--    Postgres не перевіряє EXECUTE під час спрацювання тригера.
revoke execute on function public.handle_new_user() from public, anon, authenticated;

-- 2. pg_trgm — у схемі public (Security Advisor: extension_in_public).
--    Ніде не використовується; переносимо в службову схему extensions
--    (вона є в search_path бази, тож similarity() тощо працюватимуть і надалі).
do $$
begin
  if exists (
    select 1 from pg_extension e
    where e.extname = 'pg_trgm' and e.extnamespace = 'public'::regnamespace
  ) then
    alter extension pg_trgm set schema extensions;
  end if;
end $$;

-- 3. Захист від злитих паролів (auth_leaked_password_protection) — це не SQL,
--    а налаштування Auth у панелі Supabase. Див. docs/PROJECT_STATE.md.
