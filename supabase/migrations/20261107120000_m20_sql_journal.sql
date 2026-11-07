-- M20: журнал SQL-файлів, які запустив у робочій базі workflow «Apply SQL (production)» (.github/workflows/db-apply.yml).
--   * Один рядок на файл: шлях від supabase/ (`migrations/…`, `data_fixes/…`), sha256 вмісту, коли, ким (запуск GitHub Actions або baseline).
--   * Файли, що були в репозиторії до автоматизації (запущені вручну в SQL Editor або свідомо не запускались), — у
--     supabase/sql_journal_baseline.txt; scripts/db/apply.sh додає їх сюди з applied_by = 'baseline' і не запускає.
--   * Схема ops не відкрита через API Supabase (лише public / graphql_public); RLS увімкнено без політик — anon / authenticated не бачать нічого.
--   * Ідемпотентна: scripts/db/apply.sh запускає цей файл на початку кожного прогону (журнал має існувати до вибору нових файлів).

create schema if not exists ops;

create table if not exists ops.sql_journal (
  filename    text primary key check (filename ~ '^(migrations|data_fixes)/[^/]+\.sql$'),
  sha256      text check (sha256 is null or sha256 ~ '^[0-9a-f]{64}$'),
  applied_at  timestamptz not null default now(),
  applied_by  text not null,
  run_url     text
);

comment on table ops.sql_journal is 'SQL-файли з supabase/, запущені в робочій базі (workflow db-apply або baseline до 2026-11-07).';

alter table ops.sql_journal enable row level security;

revoke all on schema ops from public;
revoke all on all tables in schema ops from public;
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    revoke all on schema ops from anon;
    revoke all on all tables in schema ops from anon;
  end if;
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    revoke all on schema ops from authenticated;
    revoke all on all tables in schema ops from authenticated;
  end if;
end $$;
