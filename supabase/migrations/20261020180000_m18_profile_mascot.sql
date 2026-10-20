-- =====================================================================
-- M18 · Талісман-далматинець у профілі · 2026-10-20
-- Рішення власника: користувач обирає одного з трьох мультяшних далматинців.
--   * profiles.mascot: 'pjegica' | 'sime' | 'tocka' | null (не обрано → застосунок показує Pjegica).
--   * Лише додає колонку й обмеження; дані не видаляються. RLS профілю вже діє:
--     користувач читає й змінює лише свій рядок (політики baseline + M7).
--   * Якщо вже запускали першу версію цього файлу (female / male): вибір переноситься
--     (female → pjegica, male → sime), обмеження оновлюється.
--   * Повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run.
-- =====================================================================

alter table public.profiles add column if not exists mascot text;

do $$
begin
  -- перша версія файлу (female / male) → три далматинці
  if exists (select 1 from pg_constraint where conname = 'profiles_mascot_check'
             and pg_get_constraintdef(oid) like '%female%') then
    alter table public.profiles drop constraint profiles_mascot_check;
    update public.profiles set mascot = case mascot when 'female' then 'pjegica' when 'male' then 'sime' else mascot end
     where mascot in ('female', 'male');
  end if;
  if not exists (select 1 from pg_constraint where conname = 'profiles_mascot_check') then
    alter table public.profiles add constraint profiles_mascot_check
      check (mascot is null or mascot in ('pjegica', 'sime', 'tocka'));
  end if;
end $$;

comment on column public.profiles.mascot is 'Талісман-далматинець: pjegica, sime або tocka; null — не обрано (показуємо pjegica)';
