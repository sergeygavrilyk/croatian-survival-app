-- =====================================================================
-- M28: журнал дій, що прийшли з черги на телефоні (офлайн без втрат, рішення власника 2026-11-16).
-- Адитивно й ідемпотентно: можна запускати повторно.
--   * public.client_ops — номер кожної дії (op_id, uuid з телефону) і коли людина її зробила;
--     сервер записує номер після того, як застосував дію, і пропускає повтор того самого номера —
--     так дія з черги зараховується рівно один раз, навіть якщо телефон надіслав її двічі.
-- Лише номери й час, без змісту дії. Журнал лише доповнюється: користувач може додати й читати
-- свої рядки; змінити, видалити чи торкнутися чужого рядка — не можна.
-- Види мають збігатися з OFFLINE_OP_KINDS у lib/offline-queue.ts (перевіряє lib/offline-queue.test.ts);
-- `srs_rating` — для етапу 2 (тренажер без мережі).
-- План — docs/proposals/2026-11-16_offline_sync.md.
-- =====================================================================

create table if not exists public.client_ops (
  op_id       uuid        primary key,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  kind        text        not null check (kind in ('lesson_completed', 'reading_completed', 'word_saved', 'event', 'srs_rating')),
  occurred_at timestamptz not null,
  received_at timestamptz not null default now()
);

comment on table public.client_ops is
  'Дії з черги на телефоні (офлайн): номер дії, вид і коли людина її зробила. Повтор номера не приймається; змінювати й видаляти не можна.';

create index if not exists client_ops_user_received_idx on public.client_ops (user_id, received_at);

alter table public.client_ops enable row level security;

revoke all on public.client_ops from anon;
revoke update, delete, truncate on public.client_ops from authenticated;
grant select, insert on public.client_ops to authenticated;

drop policy if exists "Users can read own client ops" on public.client_ops;
create policy "Users can read own client ops" on public.client_ops
  for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "Users can add own client ops" on public.client_ops;
create policy "Users can add own client ops" on public.client_ops
  for insert to authenticated
  with check (user_id = (select auth.uid()));
