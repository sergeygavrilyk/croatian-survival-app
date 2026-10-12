-- =====================================================================
-- M2 · Статуси контенту і читання лише опублікованого (§64–65, §124, §126 ТЗ)
-- 2026-10-12 · Адитивна, ідемпотентна. Потребує M3 (функція is_admin()).
--
--   * Статуси: DRAFT → AI_GENERATED → AUTO_VALIDATED → NEEDS_REVIEW → APPROVED
--     → PUBLISHED → DEPRECATED — CHECK і NOT NULL у всіх таблицях контенту.
--   * Нові слова (lexemes) за замовчуванням AI_GENERATED, нові діалоги — DRAFT:
--     жоден AI-контент не потрапляє користувачу без перевірки.
--   * Наявні рядки НЕ змінюються: що було PUBLISHED, лишається PUBLISHED.
--   * Гість і звичайний користувач бачать лише PUBLISHED (і частини опублікованих
--     уроків / діалогів / тем). Адмін бачить усе (політики з M3).
--   * updated_at / published_at / source — для простежуваності (§65).
--   * content_reviews і content_versions — журнал перевірок і версій (§124).
-- =====================================================================

-- 1. Статус у вправах (раніше не було). Наявні вправи — PUBLISHED, нові — DRAFT.
alter table public.exercises add column if not exists status text not null default 'PUBLISHED';
alter table public.exercises alter column status set default 'DRAFT';

-- 2. CHECK + NOT NULL на статус у всіх таблицях контенту
do $$
declare
  t text;
begin
  foreach t in array array['lexemes', 'lessons', 'units', 'modules', 'levels', 'grammar_topics', 'exercises']
  loop
    if not exists (select 1 from pg_constraint where conname = t || '_status_check' and conrelid = format('public.%I', t)::regclass) then
      execute format(
        'alter table public.%1$I add constraint %2$I check (status in (''DRAFT'', ''AI_GENERATED'', ''AUTO_VALIDATED'', ''NEEDS_REVIEW'', ''APPROVED'', ''PUBLISHED'', ''DEPRECATED''))',
        t, t || '_status_check');
    end if;
    execute format('alter table public.%I alter column status set not null', t);
  end loop;
end $$;

-- 3. Значення за замовчуванням для нового контенту
alter table public.lexemes alter column status set default 'AI_GENERATED';
alter table public.conversations alter column status set default 'DRAFT';

-- 4. Простежуваність (§65): джерело, час зміни, час публікації
alter table public.lexemes add column if not exists source text;
alter table public.lexemes add column if not exists updated_at timestamptz not null default now();
alter table public.lexemes add column if not exists published_at timestamptz;
alter table public.phrases add column if not exists published_at timestamptz;
alter table public.conversations add column if not exists published_at timestamptz;
alter table public.lessons add column if not exists updated_at timestamptz not null default now();

update public.lexemes set published_at = coalesce(created_at, now()) where status = 'PUBLISHED' and published_at is null;
update public.phrases set published_at = coalesce(created_at, now()) where status = 'PUBLISHED' and published_at is null;
update public.conversations set published_at = coalesce(created_at, now()) where status = 'PUBLISHED' and published_at is null;
update public.lessons set published_at = coalesce(created_at, now()) where status = 'PUBLISHED' and published_at is null;

-- Тригер: оновлює updated_at при зміні і ставить published_at при публікації
create or replace function public.content_touch()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' then
    new.updated_at := now();
  end if;
  if new.status = 'PUBLISHED' and new.published_at is null then
    new.published_at := now();
  end if;
  return new;
end;
$$;

revoke execute on function public.content_touch() from public, anon, authenticated;

do $$
declare
  t text;
begin
  foreach t in array array['lexemes', 'phrases', 'conversations', 'lessons']
  loop
    execute format('drop trigger if exists content_touch on public.%I', t);
    execute format('create trigger content_touch before insert or update on public.%I for each row execute function public.content_touch()', t);
  end loop;
end $$;

-- 5. Читання: лише PUBLISHED (адмін бачить усе через політики M3)
do $$
declare
  t text;
begin
  foreach t in array array['lexemes', 'lessons', 'units', 'modules', 'levels', 'grammar_topics', 'exercises', 'conversations']
  loop
    execute format('drop policy if exists "Enable read access for all users" on public.%I', t);
    execute format('drop policy if exists "Read published %1$s" on public.%1$I', t);
    execute format('create policy "Read published %1$s" on public.%1$I for select using (status = ''PUBLISHED'')', t);
  end loop;
end $$;

-- Частини контенту без власного статусу видно, коли опубліковано «батька»
drop policy if exists "Enable read access for all users" on public.conversation_turns;
drop policy if exists "Read turns of published conversations" on public.conversation_turns;
create policy "Read turns of published conversations" on public.conversation_turns
  for select using (exists (
    select 1 from public.conversations c
    where c.id = conversation_turns.conversation_id and c.status = 'PUBLISHED'));

drop policy if exists "Enable read access for all users" on public.lesson_items;
drop policy if exists "Read items of published lessons" on public.lesson_items;
create policy "Read items of published lessons" on public.lesson_items
  for select using (exists (
    select 1 from public.lessons l
    where l.id = lesson_items.lesson_id and l.status = 'PUBLISHED'));

drop policy if exists "Enable read access for all users" on public.lesson_grammar;
drop policy if exists "Read grammar of published lessons" on public.lesson_grammar;
create policy "Read grammar of published lessons" on public.lesson_grammar
  for select using (exists (
    select 1 from public.lessons l
    where l.id = lesson_grammar.lesson_id and l.status = 'PUBLISHED'));

drop policy if exists "Enable read access for all users" on public.grammar_rules;
drop policy if exists "Read rules of published topics" on public.grammar_rules;
create policy "Read rules of published topics" on public.grammar_rules
  for select using (exists (
    select 1 from public.grammar_topics g
    where g.id = grammar_rules.topic_id and g.status = 'PUBLISHED'));

-- word_families лишається відкритим довідником (статусу немає, рядків 0).

-- 6. Журнал перевірок і версій контенту (§124). Лише адмін; append-only.
create table if not exists public.content_reviews (
  id             uuid primary key default gen_random_uuid(),
  entity_type    text not null check (entity_type in ('lexeme', 'phrase', 'conversation', 'conversation_turn', 'lesson', 'exercise', 'grammar_topic', 'grammar_rule')),
  entity_id      uuid not null,
  from_status    text,
  to_status      text,
  verdict        text not null check (verdict in ('approved', 'changes_requested', 'rejected', 'auto_passed', 'auto_failed')),
  reviewer_kind  text not null default 'human' check (reviewer_kind in ('human', 'ai', 'script')),
  reviewer_id    uuid references auth.users(id) on delete set null default auth.uid(),
  findings       jsonb not null default '[]'::jsonb check (jsonb_typeof(findings) = 'array'),
  notes          text,
  created_at     timestamptz not null default now()
);
create index if not exists idx_content_reviews_entity on public.content_reviews (entity_type, entity_id, created_at desc);

create table if not exists public.content_versions (
  id             uuid primary key default gen_random_uuid(),
  entity_type    text not null check (entity_type in ('lexeme', 'phrase', 'conversation', 'conversation_turn', 'lesson', 'exercise', 'grammar_topic', 'grammar_rule')),
  entity_id      uuid not null,
  version        integer not null check (version >= 1),
  payload        jsonb not null check (jsonb_typeof(payload) = 'object'),
  change_reason  text,
  created_by     uuid references auth.users(id) on delete set null default auth.uid(),
  created_at     timestamptz not null default now(),
  unique (entity_type, entity_id, version)
);

alter table public.content_reviews enable row level security;
alter table public.content_versions enable row level security;

drop policy if exists "Admins can read content reviews" on public.content_reviews;
create policy "Admins can read content reviews" on public.content_reviews
  for select to authenticated using ((select public.is_admin()));
drop policy if exists "Admins can add content reviews" on public.content_reviews;
create policy "Admins can add content reviews" on public.content_reviews
  for insert to authenticated with check ((select public.is_admin()));

drop policy if exists "Admins can read content versions" on public.content_versions;
create policy "Admins can read content versions" on public.content_versions
  for select to authenticated using ((select public.is_admin()));
drop policy if exists "Admins can add content versions" on public.content_versions;
create policy "Admins can add content versions" on public.content_versions
  for insert to authenticated with check ((select public.is_admin()));

revoke update, delete, truncate on public.content_reviews from anon, authenticated;
revoke update, delete, truncate on public.content_versions from anon, authenticated;

-- 7. Індекси під фільтр за статусом
create index if not exists idx_lexemes_status_cefr on public.lexemes (status, cefr);
create index if not exists idx_conversations_status on public.conversations (status);
