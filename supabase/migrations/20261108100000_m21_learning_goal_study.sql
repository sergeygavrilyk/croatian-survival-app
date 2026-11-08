-- M21: нова мета навчання «Навчання» (study) — рішення власника 2026-11-07 / 08
--   («Навчання» — і дорослі: курси, університет, визнання диплома; і діти: садок і школа).
--   «Подорожі» стають «Туризм і подорожі» — лише назва в застосунку (ключ travel той самий, дані не змінюються).
-- Розширює CHECK profiles.learning_goals (M7) значенням 'study'. Ідемпотентна: повторний запуск нічого не змінює.

do $$
begin
  if exists (select 1 from pg_constraint where conname = 'profiles_learning_goals_check'
             and conrelid = 'public.profiles'::regclass
             and pg_get_constraintdef(oid) not like '%study%') then
    alter table public.profiles drop constraint profiles_learning_goals_check;
  end if;
  if not exists (select 1 from pg_constraint where conname = 'profiles_learning_goals_check'
                 and conrelid = 'public.profiles'::regclass) then
    alter table public.profiles add constraint profiles_learning_goals_check
      check (learning_goals <@ array['daily_life', 'work', 'documents', 'social', 'travel', 'study']::text[]);
  end if;
end $$;
