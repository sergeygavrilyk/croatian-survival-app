-- =====================================================================
-- M14 · Типові помилки українців (§19 ТЗ «Ukrainian Interference Engine», §119) · 2026-10-13
-- Адитивна, ідемпотентна. Наявні дані не змінюються.
--
--   * public.linguistic_errors — каталог типових помилок: код UKR-HR-0001, одна з 12 категорій ТЗ,
--     рівень, «неправильно» / «правильно», пояснення українською, приклади.
--     Прив'язка до теми граматики й слова — щоб показувати помилку в потрібному уроці.
--     Контент: читати можна лише PUBLISHED; змінює лише адмін (is_admin(), M3).
--   * user_errors.linguistic_error_id — особиста помилка може посилатися на типову
--     (користувач помилився у вправі «Яке речення правильне?» → помилка йде в повторення).
-- =====================================================================

create table if not exists public.linguistic_errors (
  id                uuid primary key default gen_random_uuid(),
  code              text not null unique check (code ~ '^UKR-HR-[0-9]{4}$'),
  category          text not null check (category in (
                      'cases', 'gender', 'aspect', 'word_order', 'prepositions', 'false_friends',
                      'pronunciation', 'verb_patterns', 'plural', 'articles', 'stress', 'collocations')),
  cefr              text not null check (cefr in ('A0', 'A1', 'A2', 'B1', 'B2')),
  title_ua          text not null check (length(title_ua) between 3 and 120),
  incorrect_text    text not null check (length(incorrect_text) between 1 and 200),
  correct_text      text not null check (length(correct_text) between 1 and 200),
  explanation_ua    text not null check (length(explanation_ua) between 10 and 600),
  examples          jsonb not null default '[]'::jsonb check (jsonb_typeof(examples) = 'array'),
  grammar_topic_id  uuid references public.grammar_topics(id) on delete set null,
  lexeme_id         uuid references public.lexemes(id) on delete set null,
  status            text not null default 'DRAFT'
                      check (status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED', 'PUBLISHED', 'DEPRECATED')),
  version           integer not null default 1,
  source            text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  published_at      timestamptz,
  constraint linguistic_errors_texts_differ check (incorrect_text <> correct_text)
);

create index if not exists idx_linguistic_errors_grammar on public.linguistic_errors (grammar_topic_id) where status = 'PUBLISHED';
create index if not exists idx_linguistic_errors_lexeme on public.linguistic_errors (lexeme_id) where status = 'PUBLISHED';
create index if not exists idx_linguistic_errors_level on public.linguistic_errors (cefr, category);

-- updated_at / published_at — та сама функція, що для решти контенту (M2)
drop trigger if exists content_touch on public.linguistic_errors;
create trigger content_touch before insert or update on public.linguistic_errors
  for each row execute function public.content_touch();

alter table public.linguistic_errors enable row level security;

drop policy if exists "Read published linguistic_errors" on public.linguistic_errors;
create policy "Read published linguistic_errors" on public.linguistic_errors
  for select using (status = 'PUBLISHED');
drop policy if exists "Admins can read all linguistic_errors" on public.linguistic_errors;
create policy "Admins can read all linguistic_errors" on public.linguistic_errors
  for select to authenticated using ((select public.is_admin()));
drop policy if exists "Admins can insert linguistic_errors" on public.linguistic_errors;
create policy "Admins can insert linguistic_errors" on public.linguistic_errors
  for insert to authenticated with check ((select public.is_admin()));
drop policy if exists "Admins can update linguistic_errors" on public.linguistic_errors;
create policy "Admins can update linguistic_errors" on public.linguistic_errors
  for update to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

revoke delete, truncate on public.linguistic_errors from anon, authenticated;

-- Особисті помилки ↔ типові
alter table public.user_errors add column if not exists linguistic_error_id uuid
  references public.linguistic_errors(id) on delete set null;

-- Одна особиста копія типової помилки на користувача (нова помилка — знову відкриває її, а не дублює)
create unique index if not exists user_errors_user_linguistic_key
  on public.user_errors (user_id, linguistic_error_id)
  where linguistic_error_id is not null;

-- Журнал рев'ю й версій (M2, M7) приймає також типові помилки
do $$
declare
  t text;
begin
  foreach t in array array['content_reviews', 'content_versions']
  loop
    execute format('alter table public.%I drop constraint if exists %I', t, t || '_entity_type_check');
    execute format(
      'alter table public.%I add constraint %I check (entity_type in (''lexeme'', ''phrase'', ''conversation'', ''conversation_turn'', ''lesson'', ''exercise'', ''grammar_topic'', ''grammar_rule'', ''assessment'', ''assessment_item'', ''linguistic_error''))',
      t, t || '_entity_type_check');
  end loop;
end $$;
