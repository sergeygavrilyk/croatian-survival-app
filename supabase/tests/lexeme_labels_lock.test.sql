-- =====================================================================
-- Тести: «замок» маркування (M25) — мітки слів і речень обов'язкові, без default · 2026-11-13
-- Запускати ПІСЛЯ міграції 20261113120000_m25_lexeme_labels_lock.sql (а вона — після пакета 20261113_lexeme_labels.sql).
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK. Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

create or replace function pg_temp.raises(q text) returns boolean language plpgsql as $$
begin
  execute q;
  return false;
exception when others then
  return true;
end $$;

-- ---------------------------------------------------------------- схема
select pg_temp.ok((select count(*) from information_schema.columns where table_schema = 'public'
                     and table_name in ('lexemes', 'phrases') and column_name in ('register', 'regionality', 'usage_tags')
                     and is_nullable = 'NO' and column_default is null) = 6,
  'register / regionality / usage_tags у lexemes і phrases — NOT NULL, без значення за замовчуванням');
select pg_temp.ok((select convalidated from pg_constraint where conname = 'lexemes_register_check'
                     and conrelid = 'public.lexemes'::regclass), 'lexemes_register_check — чинна для всіх рядків (VALIDATE)');
select pg_temp.ok((select count(*) from pg_constraint where conrelid in ('public.lexemes'::regclass, 'public.phrases'::regclass)
                     and conname ~ '_(register|regionality|usage_tags)_check$' and not convalidated) = 0,
  'жодної перевірки міток у стані NOT VALID');

-- ---------------------------------------------------------------- слово без міток — ні
select pg_temp.ok(pg_temp.raises($q$insert into public.lexemes (lemma, normalized, ukrainian_translation, cefr, status)
  values ('m25testbez', 'm25testbez', 'тест', 'B1', 'DRAFT')$q$), 'слово без трьох міток — ні');
select pg_temp.ok(pg_temp.raises($q$insert into public.lexemes (lemma, normalized, ukrainian_translation, cefr, status, register, regionality)
  values ('m25testtags', 'm25testtags', 'тест', 'B1', 'DRAFT', 'standard', 'general')$q$), 'слово без usage_tags — ні');
select pg_temp.ok(pg_temp.raises($q$insert into public.lexemes (lemma, normalized, ukrainian_translation, cefr, status, register, usage_tags)
  values ('m25testreg', 'm25testreg', 'тест', 'B1', 'DRAFT', 'standard', '{}')$q$), 'слово без regionality — ні');
select pg_temp.ok(not pg_temp.raises($q$insert into public.lexemes (lemma, normalized, ukrainian_translation, cefr, status, register, regionality, usage_tags)
  values ('m25testok', 'm25testok', 'тест', 'B1', 'DRAFT', 'standard', 'general', '{}')$q$), 'слово з мітками standard / general / {} — можна');
select pg_temp.ok(pg_temp.raises($q$update public.lexemes set register = null where lower(lemma) = 'm25testok'$q$),
  'стерти мітку наявного слова — ні');

-- ---------------------------------------------------------------- речення
select pg_temp.ok(pg_temp.raises($q$insert into public.phrases (text_hr, normalized, ukrainian_translation, status)
  values ('M25 test bez.', 'm25 test bez.', 'тест', 'DRAFT')$q$), 'речення без міток — ні');
select pg_temp.ok(not pg_temp.raises($q$insert into public.phrases (text_hr, normalized, ukrainian_translation, status, register, regionality, usage_tags)
  values ('M25 test ok.', 'm25 test ok.', 'тест', 'DRAFT', 'informal', 'general', '{}')$q$), 'речення з мітками — можна');

select 'ALL TESTS PASSED';
rollback;
