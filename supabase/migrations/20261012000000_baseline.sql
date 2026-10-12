-- =====================================================================
-- BASELINE: знімок реальної схеми Supabase-проєкту «New app for learning»
-- (ref mhdgozragkkogvxpjksp) станом на 2026-10-12.
--
-- Цей файл ДОКУМЕНТУЄ те, що вже є в базі. Його НЕ треба виконувати на
-- робочій базі — таблиці там уже існують. Він потрібен, щоб:
--   1) Claude і люди бачили точну схему без вгадування;
--   2) можна було підняти локальну/тестову копію бази.
-- Усі наступні зміни — окремими файлами в supabase/migrations/.
-- =====================================================================

-- Розширення (вже встановлені в Supabase): pgcrypto, uuid-ossp, pg_stat_statements, supabase_vault
create extension if not exists pg_trgm with schema public;

-- ---------------------------------------------------------------------
-- Користувачі
-- ---------------------------------------------------------------------
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text not null unique,
  created_at  timestamptz not null default timezone('utc', now())
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path to '' as $$
begin
  insert into public.profiles (id, email, created_at)
  values (new.id, new.email, now());
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- Програма: levels → modules → units → lessons → lesson_items
-- ---------------------------------------------------------------------
create table if not exists public.levels (
  code         text primary key,
  title_ua     text not null,
  title_hr     text not null,
  order_index  integer not null,
  status       text default 'DRAFT',
  created_at   timestamptz default now()
);

create table if not exists public.modules (
  id           uuid primary key default gen_random_uuid(),
  level_code   text references public.levels(code),
  title_ua     text not null,
  title_hr     text,
  description  text,
  order_index  integer not null,
  status       text default 'DRAFT',
  created_at   timestamptz default now(),
  unique (level_code, order_index)
);

create table if not exists public.units (
  id           uuid primary key default gen_random_uuid(),
  module_id    uuid references public.modules(id) on delete cascade,
  title_ua     text not null,
  title_hr     text,
  objectives   jsonb,
  order_index  integer not null,
  status       text default 'DRAFT',
  created_at   timestamptz default now(),
  unique (module_id, order_index)
);

create table if not exists public.lessons (
  id                 uuid primary key default gen_random_uuid(),
  unit_id            uuid references public.units(id) on delete cascade,
  level_code         text references public.levels(code),
  title_ua           text not null,
  title_hr           text,
  objectives         jsonb,
  estimated_minutes  integer,
  status             text default 'DRAFT',
  version            text default '1.0',
  created_at         timestamptz default now(),
  published_at       timestamptz
);

-- item_id — поліморфне посилання (lexeme / exercise / grammar), без FK
create table if not exists public.lesson_items (
  id            uuid primary key default gen_random_uuid(),
  lesson_id     uuid references public.lessons(id) on delete cascade,
  item_type     text not null,
  item_id       uuid not null,
  order_index   integer not null,
  required      boolean default true,
  target_skill  text,
  unique (lesson_id, order_index)
);

-- ---------------------------------------------------------------------
-- Словник
-- ---------------------------------------------------------------------
create table if not exists public.word_families (
  id           uuid primary key default gen_random_uuid(),
  family_name  text not null,
  description  text,
  created_at   timestamptz default timezone('utc', now())
);

create table if not exists public.lexemes (
  id                     uuid primary key default gen_random_uuid(),
  lemma                  text not null,
  normalized             text not null,
  language               text default 'hr',
  part_of_speech         text,
  gender                 text,
  number                 text,
  aspect                 text,
  transitivity           text,
  cefr                   text check (cefr = any (array['A0','A1','A2','B1','B2'])),
  frequency_rank         integer,
  frequency_score        numeric,
  ukrainian_translation  text not null,
  ukrainian_explanation  text,
  register               text,
  regionality            text,
  vocabulary_type        text,
  word_family_id         uuid references public.word_families(id) on delete set null,
  forms                  jsonb default '{}'::jsonb,
  collocations           jsonb default '[]'::jsonb,
  phrases                jsonb default '[]'::jsonb,
  examples               jsonb default '[]'::jsonb,
  pronunciation          text,
  audio_url              text,
  common_errors          text,
  ukrainian_interference text,
  status                 text default 'PUBLISHED',
  version                integer default 1,
  created_at             timestamptz default timezone('utc', now()),
  constraint lexemes_vocabulary_type_check
    check (vocabulary_type = any (array['core','function_word','formulaic','collocation','chunk']))
);
create unique index if not exists unique_lower_lemma on public.lexemes (lower(lemma));
create index if not exists idx_lexemes_cefr on public.lexemes (cefr);
create index if not exists idx_lexemes_type on public.lexemes (vocabulary_type);

-- ---------------------------------------------------------------------
-- Граматика
-- ---------------------------------------------------------------------
create table if not exists public.grammar_topics (
  id           uuid primary key default gen_random_uuid(),
  cefr         text not null,
  title_ua     text not null,
  title_hr     text,
  description  text,
  status       text default 'DRAFT',
  created_at   timestamptz default now()
);

create table if not exists public.grammar_rules (
  id              uuid primary key default gen_random_uuid(),
  topic_id        uuid references public.grammar_topics(id) on delete cascade,
  title_ua        text not null,
  explanation_ua  text not null,
  pattern_hr      text,
  examples        jsonb default '[]'::jsonb,
  order_index     integer not null,
  created_at      timestamptz default now()
);

create table if not exists public.lesson_grammar (
  lesson_id         uuid not null references public.lessons(id) on delete cascade,
  grammar_topic_id  uuid not null references public.grammar_topics(id) on delete cascade,
  primary key (lesson_id, grammar_topic_id)
);

-- ---------------------------------------------------------------------
-- Вправи і діалоги (статичний контент)
-- ---------------------------------------------------------------------
create table if not exists public.exercises (
  id              uuid primary key default gen_random_uuid(),
  exercise_type   text not null,
  question_text   text not null,
  correct_answer  text not null,
  options         jsonb,
  level           text default 'A1',
  order_index     integer not null default 0,
  created_at      timestamptz not null default timezone('utc', now()),
  lexeme_id       uuid references public.lexemes(id) on delete cascade,
  constraint exercises_type_check
    check (exercise_type = any (array['fill_in_the_blank','sentence_builder','listening','multiple_choice']))
);
create index if not exists idx_exercises_type on public.exercises (exercise_type);

create table if not exists public.conversations (
  id           uuid primary key default gen_random_uuid(),
  lesson_id    uuid references public.lessons(id) on delete cascade,
  title_ua     text,
  title_hr     text,
  order_index  integer default 0,
  created_at   timestamptz default timezone('utc', now())
);

create table if not exists public.conversation_turns (
  id               uuid primary key default gen_random_uuid(),
  conversation_id  uuid references public.conversations(id) on delete cascade,
  speaker_name     text not null,
  hr_text          text not null,
  ua_translation   text not null,
  audio_url        text,
  order_index      integer default 0,
  created_at       timestamptz default timezone('utc', now())
);

-- ---------------------------------------------------------------------
-- Стан навчання користувача
-- ---------------------------------------------------------------------
-- УВАГА: немає unique (user_id, lexeme_id) — upsert по цій парі зараз неможливий
create table if not exists public.user_progress (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid references public.profiles(id) on delete cascade,
  repetition_count  integer not null default 0,
  ease_factor       real not null default 2.5,
  interval_days     integer not null default 0,
  next_review_date  timestamptz not null default timezone('utc', now()),
  last_reviewed_at  timestamptz,
  created_at        timestamptz not null default timezone('utc', now()),
  lexeme_id         uuid references public.lexemes(id) on delete cascade
);

create table if not exists public.srs_reviews (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid references auth.users(id) on delete cascade,
  result            integer not null,
  response_time_ms  integer,
  old_interval      integer,
  new_interval      integer,
  old_ease          double precision,
  new_ease          double precision,
  created_at        timestamptz default now(),
  lexeme_id         uuid references public.lexemes(id) on delete cascade
);

create table if not exists public.skill_progress (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid references auth.users(id) on delete cascade,
  skill           text not null,
  level_estimate  text,
  xp_or_score     integer default 0,
  updated_at      timestamptz default now(),
  unique (user_id, skill)
);

-- ---------------------------------------------------------------------
-- AI runtime
-- ---------------------------------------------------------------------
create table if not exists public.ai_conversations (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid references auth.users(id) on delete cascade,
  scenario_id  uuid,               -- таблиці scenarios ще немає
  mode         text not null,
  status       text default 'active',
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

create table if not exists public.ai_messages (
  id               uuid primary key default gen_random_uuid(),
  conversation_id  uuid references public.ai_conversations(id) on delete cascade,
  role             text not null,
  content          text not null,
  audio_url        text,
  created_at       timestamptz default now()
);

-- ---------------------------------------------------------------------
-- Застаріла функція: посилається на таблиці topic_progress і vocabulary,
-- яких у базі НЕМАЄ. Виклик завершиться помилкою.
-- ---------------------------------------------------------------------
create or replace function public.complete_lesson_and_start_srs(p_user_id uuid, p_topic_id uuid)
returns void language plpgsql as $$
begin
  insert into public.topic_progress (user_id, topic_id, status, completed_at)
  values (p_user_id, p_topic_id, 'completed', now())
  on conflict (user_id, topic_id)
  do update set status = 'completed', completed_at = now();

  insert into public.user_progress (user_id, vocabulary_id, interval_days, next_review_date)
  select p_user_id, v.id, 1, now() + interval '1 day'
  from public.vocabulary v
  where v.topic_id = p_topic_id
  on conflict (user_id, vocabulary_id) do nothing;
end;
$$;

-- ---------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------
alter table public.profiles           enable row level security;
alter table public.levels             enable row level security;
alter table public.modules            enable row level security;
alter table public.units              enable row level security;
alter table public.lessons            enable row level security;
alter table public.lesson_items       enable row level security;
alter table public.word_families      enable row level security;
alter table public.lexemes            enable row level security;
alter table public.grammar_topics     enable row level security;
alter table public.grammar_rules      enable row level security;
alter table public.lesson_grammar     enable row level security;
alter table public.exercises          enable row level security;
alter table public.conversations      enable row level security;
alter table public.conversation_turns enable row level security;
alter table public.user_progress      enable row level security;
alter table public.srs_reviews        enable row level security;
alter table public.skill_progress     enable row level security;
alter table public.ai_conversations   enable row level security;
alter table public.ai_messages        enable row level security;

-- Профіль
create policy "Users can view own profile"   on public.profiles for select using (auth.uid() = id);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);

-- Публічне читання контенту (зараз — УСІХ рядків, не лише PUBLISHED)
create policy "Enable read access for all users" on public.levels             for select using (true);
create policy "Enable read access for all users" on public.modules            for select using (true);
create policy "Enable read access for all users" on public.units              for select using (true);
create policy "Enable read access for all users" on public.lessons            for select using (true);
create policy "Enable read access for all users" on public.lesson_items       for select using (true);
create policy "Enable read access for all users" on public.word_families      for select using (true);
create policy "Enable read access for all users" on public.lexemes            for select using (true);
create policy "Enable read access for all users" on public.grammar_topics     for select using (true);
create policy "Enable read access for all users" on public.grammar_rules      for select using (true);
create policy "Enable read access for all users" on public.lesson_grammar     for select using (true);
create policy "Enable read access for all users" on public.exercises          for select using (true);
create policy "Enable read access for all users" on public.conversations      for select using (true);
create policy "Enable read access for all users" on public.conversation_turns for select using (true);

-- Адмін-запис за email (ТЗ §126 вимагає ролі через app_admins).
-- У робочій базі тут був email власника; у репозиторії — заглушка. M3 видаляє ці політики.
create policy "Allow inserts only for admins" on public.lexemes            for insert with check ((auth.jwt() ->> 'email') = 'admin@example.invalid');
create policy "Allow updates only for admins" on public.lexemes            for update using      ((auth.jwt() ->> 'email') = 'admin@example.invalid');
create policy "Allow inserts only for admins" on public.conversations      for insert with check ((auth.jwt() ->> 'email') = 'admin@example.invalid');
create policy "Allow updates only for admins" on public.conversations      for update using      ((auth.jwt() ->> 'email') = 'admin@example.invalid');
create policy "Allow inserts only for admins" on public.conversation_turns for insert with check ((auth.jwt() ->> 'email') = 'admin@example.invalid');
create policy "Allow updates only for admins" on public.conversation_turns for update using      ((auth.jwt() ->> 'email') = 'admin@example.invalid');

-- Дані користувача
create policy "Users can view own progress"   on public.user_progress for select using (auth.uid() = user_id);
create policy "Users can insert own progress" on public.user_progress for insert with check (auth.uid() = user_id);
create policy "Users can update own progress" on public.user_progress for update using (auth.uid() = user_id);
create policy "Users can view own reviews"    on public.srs_reviews   for select using (auth.uid() = user_id);
create policy "Users can insert own reviews"  on public.srs_reviews   for insert with check (auth.uid() = user_id);
create policy "Users can manage own skill progress" on public.skill_progress for all using (auth.uid() = user_id);
create policy "Users can manage own ai_conversations" on public.ai_conversations for all using (auth.uid() = user_id);
create policy "Users can view own ai_messages" on public.ai_messages for select
  using (exists (select 1 from public.ai_conversations c where c.id = ai_messages.conversation_id and c.user_id = auth.uid()));
create policy "Users can insert own ai_messages" on public.ai_messages for insert
  with check (exists (select 1 from public.ai_conversations c where c.id = ai_messages.conversation_id and c.user_id = auth.uid()));

-- Storage: публічний bucket «audio»
