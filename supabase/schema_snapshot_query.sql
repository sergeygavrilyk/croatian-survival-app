-- Знімок схеми бази Croatia survival (тільки читання, нічого не змінює).
-- Виконайте в Supabase → SQL Editor → Run. Результат — одна клітинка з JSON.
-- Скопіюйте її вміст і збережіть у файл supabase/schema_snapshot.json у папці проєкту.
with
cols as (
  select c.table_name,
         json_agg(json_build_object(
           'column', c.column_name,
           'type', case when c.data_type = 'USER-DEFINED' then c.udt_name else c.data_type end,
           'nullable', c.is_nullable = 'YES',
           'default', c.column_default
         ) order by c.ordinal_position) as columns
  from information_schema.columns c
  where c.table_schema = 'public'
  group by c.table_name
),
cons as (
  select rel.relname as table_name,
         json_agg(json_build_object('name', con.conname, 'def', pg_get_constraintdef(con.oid)) order by con.conname) as constraints
  from pg_constraint con
  join pg_class rel on rel.oid = con.conrelid
  join pg_namespace n on n.oid = rel.relnamespace
  where n.nspname = 'public'
  group by rel.relname
),
idx as (
  select tablename as table_name, json_agg(indexdef order by indexname) as indexes
  from pg_indexes where schemaname = 'public'
  group by tablename
),
pol as (
  select tablename as table_name,
         json_agg(json_build_object('name', policyname, 'cmd', cmd, 'roles', roles,
                                    'using', qual, 'check', with_check) order by policyname) as policies
  from pg_policies where schemaname = 'public'
  group by tablename
),
tbl as (
  select c.relname as table_name, c.relrowsecurity as rls_enabled,
         greatest(c.reltuples, 0)::bigint as approx_rows
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public' and c.relkind = 'r'
),
enums as (
  select t.typname as name, json_agg(e.enumlabel order by e.enumsortorder) as labels
  from pg_type t join pg_enum e on e.enumtypid = t.oid
  join pg_namespace n on n.oid = t.typnamespace
  where n.nspname = 'public'
  group by t.typname
),
funcs as (
  select p.proname as name, pg_get_function_identity_arguments(p.oid) as args,
         pg_get_function_result(p.oid) as returns
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
),
trg as (
  select event_object_table as table_name,
         json_agg(json_build_object('name', trigger_name, 'event', event_manipulation,
                                    'timing', action_timing, 'action', action_statement)) as triggers
  from information_schema.triggers where trigger_schema = 'public'
  group by event_object_table
)
select json_build_object(
  'generated_at', now(),
  'tables', (select json_agg(json_build_object(
      'table', tbl.table_name,
      'rls_enabled', tbl.rls_enabled,
      'approx_rows', tbl.approx_rows,
      'columns', cols.columns,
      'constraints', coalesce(cons.constraints, '[]'::json),
      'indexes', coalesce(idx.indexes, '[]'::json),
      'policies', coalesce(pol.policies, '[]'::json),
      'triggers', coalesce(trg.triggers, '[]'::json)
    ) order by tbl.table_name)
    from tbl
    left join cols on cols.table_name = tbl.table_name
    left join cons on cons.table_name = tbl.table_name
    left join idx  on idx.table_name  = tbl.table_name
    left join pol  on pol.table_name  = tbl.table_name
    left join trg  on trg.table_name  = tbl.table_name),
  'views', (select json_agg(table_name order by table_name) from information_schema.views where table_schema = 'public'),
  'enums', (select json_agg(json_build_object('name', name, 'labels', labels)) from enums),
  'functions', (select json_agg(json_build_object('name', name, 'args', args, 'returns', returns) order by name) from funcs),
  'storage_buckets', (select json_agg(json_build_object('id', id, 'public', public)) from storage.buckets)
)::text as schema_snapshot;
