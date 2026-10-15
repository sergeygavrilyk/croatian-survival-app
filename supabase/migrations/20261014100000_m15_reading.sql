-- =====================================================================
-- M15 · Читання (§6 ТЗ «Extensive Reading», §55–56) · 2026-10-14
-- Адитивна, ідемпотентна. Наявні дані не змінюються.
--
--   * public.reading_texts — адаптовані тексти: повідомлення, оголошення, меню, листи, чати,
--     інструкції, історії, новини… Хорватський текст, повний переклад, словничок
--     «форма слова → лема + переклад» (переклад за дотиком, §56), питання на розуміння.
--     Контент: читати можна лише PUBLISHED; змінює лише адмін (is_admin(), M3).
--   * public.reading_progress — які тексти користувач прочитав і скільки відповів правильно.
--     Лише свої рядки (auth.uid()).
--   * content_reviews / content_versions приймають entity_type = 'reading_text'.
-- Потрібні M2 (content_touch), M3 (is_admin), M14 (linguistic_error у переліку entity_type).
-- =====================================================================

-- 1. Тексти
create table if not exists public.reading_texts (
  id              uuid primary key default gen_random_uuid(),
  code            text not null unique check (code ~ '^RD-(A0|A1|A2|B1|B2)-[0-9]{3}$'),
  cefr            text not null check (cefr in ('A0', 'A1', 'A2', 'B1', 'B2')),
  text_type       text not null check (text_type in (
                    'message', 'chat', 'email', 'notice', 'ad', 'menu', 'instruction',
                    'form', 'story', 'article', 'news', 'dialogue')),
  situation       text check (situation is null or situation ~ '^[a-z][a-z_]{1,39}$'),
  module_order    smallint check (module_order is null or module_order between 1 and 20),
  title_ua        text not null check (length(title_ua) between 2 and 120),
  title_hr        text not null check (length(title_hr) between 2 and 120),
  body_hr         text not null check (length(body_hr) between 20 and 3000),
  body_ua         text not null check (length(body_ua) between 20 and 3000),
  -- [{"form": "kupujem", "lemma": "kupovati", "ua": "купувати"}, …] — для кожного слова тексту
  glossary        jsonb not null default '[]'::jsonb check (jsonb_typeof(glossary) = 'array'),
  -- [{"question_ua": "…", "options": ["…", "…", "…"], "answer": "…"}, …]
  questions       jsonb not null default '[]'::jsonb check (jsonb_typeof(questions) = 'array'),
  word_count      integer not null default 0 check (word_count >= 0),
  -- частка слів тексту, які є в уроках цього рівня й нижче (контроль незнайомих слів, §56)
  known_ratio     numeric(4, 3) check (known_ratio is null or known_ratio between 0 and 1),
  order_index     integer not null default 0,
  status          text not null default 'DRAFT'
                    check (status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED', 'PUBLISHED', 'DEPRECATED')),
  version         integer not null default 1,
  source          text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  published_at    timestamptz
);

create index if not exists idx_reading_texts_level on public.reading_texts (cefr, order_index) where status = 'PUBLISHED';

drop trigger if exists content_touch on public.reading_texts;
create trigger content_touch before insert or update on public.reading_texts
  for each row execute function public.content_touch();

alter table public.reading_texts enable row level security;

drop policy if exists "Read published reading_texts" on public.reading_texts;
create policy "Read published reading_texts" on public.reading_texts
  for select using (status = 'PUBLISHED');
drop policy if exists "Admins can read all reading_texts" on public.reading_texts;
create policy "Admins can read all reading_texts" on public.reading_texts
  for select to authenticated using ((select public.is_admin()));
drop policy if exists "Admins can insert reading_texts" on public.reading_texts;
create policy "Admins can insert reading_texts" on public.reading_texts
  for insert to authenticated with check ((select public.is_admin()));
drop policy if exists "Admins can update reading_texts" on public.reading_texts;
create policy "Admins can update reading_texts" on public.reading_texts
  for update to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

revoke delete, truncate on public.reading_texts from anon, authenticated;

-- 2. Прогрес читання (лише свої рядки)
create table if not exists public.reading_progress (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null default auth.uid() references auth.users(id) on delete cascade,
  text_id        uuid not null references public.reading_texts(id) on delete cascade,
  correct_count  integer not null default 0 check (correct_count >= 0),
  question_count integer not null default 0 check (question_count >= 0 and correct_count <= question_count),
  read_count     integer not null default 1 check (read_count >= 1),
  completed_at   timestamptz not null default now(),
  constraint reading_progress_user_text_key unique (user_id, text_id)
);

create index if not exists idx_reading_progress_user on public.reading_progress (user_id, completed_at desc);

alter table public.reading_progress enable row level security;

drop policy if exists "Users read own reading_progress" on public.reading_progress;
create policy "Users read own reading_progress" on public.reading_progress
  for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists "Users insert own reading_progress" on public.reading_progress;
create policy "Users insert own reading_progress" on public.reading_progress
  for insert to authenticated with check (user_id = (select auth.uid()));
drop policy if exists "Users update own reading_progress" on public.reading_progress;
create policy "Users update own reading_progress" on public.reading_progress
  for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

revoke all on public.reading_progress from anon;
revoke delete, truncate on public.reading_progress from authenticated;

-- 3. Журнал рев'ю й версій приймає також тексти для читання
do $$
declare
  t text;
begin
  foreach t in array array['content_reviews', 'content_versions']
  loop
    execute format('alter table public.%I drop constraint if exists %I', t, t || '_entity_type_check');
    execute format(
      'alter table public.%I add constraint %I check (entity_type in (''lexeme'', ''phrase'', ''conversation'', ''conversation_turn'', ''lesson'', ''exercise'', ''grammar_topic'', ''grammar_rule'', ''assessment'', ''assessment_item'', ''linguistic_error'', ''reading_text''))',
      t, t || '_entity_type_check');
  end loop;
end $$;
