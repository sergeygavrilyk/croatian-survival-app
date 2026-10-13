-- =====================================================================
-- M12 · Повторення помилок («Практика» → «Помилки») · 2026-10-13
-- Адитивна, ідемпотентна. Наявні помилки не змінюються (стають «на сьогодні»).
--
--   * correct_streak — скільки разів поспіль правильно; 2 у різні дні → resolved_at (засвоєно);
--   * review_count   — скільки разів повторювали;
--   * next_review_at — коли показати знову (null = зараз);
--   * last_reviewed_at — коли повторювали востаннє.
-- Права не змінюються: користувач оновлює лише свої помилки (політика з M9), видаляти не може.
-- =====================================================================

alter table public.user_errors add column if not exists correct_streak   integer not null default 0;
alter table public.user_errors add column if not exists review_count     integer not null default 0;
alter table public.user_errors add column if not exists next_review_at   timestamptz;
alter table public.user_errors add column if not exists last_reviewed_at timestamptz;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'user_errors_review_counts_check' and conrelid = 'public.user_errors'::regclass) then
    alter table public.user_errors add constraint user_errors_review_counts_check
      check (correct_streak >= 0 and review_count >= 0 and correct_streak <= review_count + 1);
  end if;
end $$;

-- Вибірка «що повторити зараз»: незасвоєні помилки користувача за датою
create index if not exists idx_user_errors_due
  on public.user_errors (user_id, next_review_at)
  where resolved_at is null;
