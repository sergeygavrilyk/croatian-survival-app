-- =====================================================================
-- M10 · Порядок уроків у юніті (§26–27 ТЗ)
-- 2026-10-12 · Адитивна, ідемпотентна. Дані не видаляє.
--
--   * lessons.order_index — номер уроку в юніті (раніше порядок брався з created_at).
--   * unique (unit_id, order_index) — два уроки не можуть стояти на одному місці.
--   * Наявні уроки нумеруються за датою створення в межах свого юніту.
-- =====================================================================

alter table public.lessons add column if not exists order_index integer;

-- Нумеруємо наявні уроки (лише ті, де номера ще немає)
with numbered as (
  select id,
         row_number() over (partition by unit_id order by created_at, id)
           + coalesce((select max(l2.order_index) from public.lessons l2 where l2.unit_id = l.unit_id), 0) as n
  from public.lessons l
  where order_index is null
)
update public.lessons l set order_index = numbered.n
from numbered where numbered.id = l.id;

alter table public.lessons alter column order_index set not null;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'lessons_unit_order_key' and conrelid = 'public.lessons'::regclass) then
    alter table public.lessons add constraint lessons_unit_order_key unique (unit_id, order_index);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'lessons_order_index_check' and conrelid = 'public.lessons'::regclass) then
    alter table public.lessons add constraint lessons_order_index_check check (order_index >= 1);
  end if;
end $$;

-- Новий урок без номера ставиться в кінець юніту
create or replace function public.lessons_default_order()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if new.order_index is null then
    select coalesce(max(l.order_index), 0) + 1 into new.order_index
    from public.lessons l where l.unit_id is not distinct from new.unit_id;
  end if;
  return new;
end;
$$;

revoke execute on function public.lessons_default_order() from public, anon, authenticated;

drop trigger if exists lessons_default_order on public.lessons;
create trigger lessons_default_order before insert on public.lessons
  for each row execute function public.lessons_default_order();
