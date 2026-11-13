-- =====================================================================
-- Тести: маркування живої лексики (M24) — register / regionality / usage_tags, standard_lexeme_id · 2026-11-13
-- Запускати ПІСЛЯ міграції 20261113100000_m24_lexeme_labels.sql.
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

-- Слово для перевірок (лема, якої точно немає в базі)
create or replace function pg_temp.lex(reg text, region text, tags text) returns text language sql as $$
  select format($f$insert into public.lexemes (lemma, normalized, ukrainian_translation, part_of_speech, cefr, vocabulary_type,
                                               status, register, regionality, usage_tags)
                   values ('m24test' || %s, 'm24test', 'тест', 'noun', 'B1', 'core', 'DRAFT', %L, %L, %L::text[])$f$,
                (random() * 1e9)::bigint, reg, region, tags)
$$;

-- ---------------------------------------------------------------- колонки й обмеження
select pg_temp.ok((select count(*) from information_schema.columns where table_schema = 'public'
                     and (table_name, column_name) in (('lexemes', 'usage_tags'), ('lexemes', 'standard_lexeme_id'),
                                                       ('phrases', 'register'), ('phrases', 'regionality'), ('phrases', 'usage_tags'))) = 5,
  'нові колонки: lexemes.usage_tags, lexemes.standard_lexeme_id, phrases.register / regionality / usage_tags');
select pg_temp.ok((select not convalidated from pg_constraint where conname = 'lexemes_register_check'
                     and conrelid = 'public.lexemes'::regclass),
  'lexemes_register_check — NOT VALID (старі regional / non_standard нормалізує крок 2)');
select pg_temp.ok((select count(*) from pg_constraint where convalidated and conname in
                     ('lexemes_regionality_check', 'lexemes_usage_tags_check', 'lexemes_standard_not_self_check',
                      'phrases_register_check', 'phrases_regionality_check', 'phrases_usage_tags_check')) = 6,
  'решта перевірок — чинні для всіх рядків');
select pg_temp.ok((select count(*) from public.lexemes where usage_tags is not null or standard_lexeme_id is not null) = 0
  and (select count(*) from public.phrases where register is not null or regionality is not null or usage_tags is not null) = 0,
  'міграція наявних даних не змінює: нові поля порожні (= ще не розмічено)');

-- ---------------------------------------------------------------- lexemes: переліки
select pg_temp.ok(not pg_temp.raises(pg_temp.lex('standard', 'general', '{}')), 'standard / general / {} — можна');
select pg_temp.ok(not pg_temp.raises(pg_temp.lex('slang', 'Zagreb', '{youth_slang,anglicism}')), 'slang / Zagreb / дві ознаки — можна');
select pg_temp.ok(not pg_temp.raises(pg_temp.lex('vulgar', 'general', '{offensive}')), 'vulgar / offensive — можна');
select pg_temp.ok(not pg_temp.raises(pg_temp.lex(null, null, null)), 'порожні мітки поки можна (ще не розмічено, до кроку 3)');
select pg_temp.ok(pg_temp.raises(pg_temp.lex('regional', 'Dalmatia', '{}')), 'старе regional у новому рядку — ні');
select pg_temp.ok(pg_temp.raises(pg_temp.lex('non_standard', 'general', '{}')), 'старе non_standard у новому рядку — ні');
select pg_temp.ok(pg_temp.raises(pg_temp.lex('casual', 'general', '{}')), 'невідомий register — ні');
select pg_temp.ok(pg_temp.raises(pg_temp.lex('standard', 'dalmatia', '{}')), 'регіон з малої літери — ні');
select pg_temp.ok(pg_temp.raises(pg_temp.lex('standard', 'Split', '{}')), 'невідомий регіон — ні');
select pg_temp.ok(pg_temp.raises(pg_temp.lex('colloquial', 'general', '{anglicism,regionalism}')), 'невідома ознака — ні');
select pg_temp.ok(pg_temp.raises(pg_temp.lex('colloquial', 'general', '{NULL}')), 'порожній елемент в ознаках — ні');
select pg_temp.ok(pg_temp.raises(pg_temp.lex('colloquial', 'Zagreb', '{kajkavian,Zagreb}')), 'регіон серед ознак — ні');

-- ---------------------------------------------------------------- standard_lexeme_id
insert into public.lexemes (id, lemma, normalized, ukrainian_translation, part_of_speech, cefr, vocabulary_type, status,
                            register, regionality, usage_tags)
values ('00000000-0000-4000-8000-0000000c0024', 'm24stdtest', 'm24stdtest', 'розуміти', 'verb', 'B1', 'core', 'DRAFT',
        'standard', 'general', '{}'),
       ('00000000-0000-4000-8000-0000000d0024', 'm24coltest', 'm24coltest', 'розуміти (розм.)', 'verb', 'B1', 'core', 'DRAFT',
        'colloquial', 'general', '{}');
select pg_temp.ok(not pg_temp.raises($q$update public.lexemes set standard_lexeme_id = '00000000-0000-4000-8000-0000000c0024'
  where id = '00000000-0000-4000-8000-0000000d0024'$q$), 'розмовне → стандартний відповідник — можна');
select pg_temp.ok(pg_temp.raises($q$update public.lexemes set standard_lexeme_id = id
  where id = '00000000-0000-4000-8000-0000000c0024'$q$), 'відповідник сам на себе — ні');
select pg_temp.ok(pg_temp.raises($q$update public.lexemes set standard_lexeme_id = '00000000-0000-4000-8000-0000000e0024'
  where id = '00000000-0000-4000-8000-0000000d0024'$q$), 'відповідник — неіснуюча лексема — ні');
delete from public.lexemes where id = '00000000-0000-4000-8000-0000000c0024';
select pg_temp.ok((select standard_lexeme_id is null from public.lexemes where id = '00000000-0000-4000-8000-0000000d0024'),
  'видалили відповідник — зв’язок порожніє (on delete set null), слово лишається');

-- ---------------------------------------------------------------- phrases
select pg_temp.ok(not pg_temp.raises($q$insert into public.phrases (text_hr, normalized, ukrainian_translation, status,
  register, regionality, usage_tags) values ('Ma daj, ne zezaj m24test!', 'ma daj, ne zezaj m24test!', 'Та ну, не жартуй!', 'DRAFT',
  'colloquial', 'general', '{}')$q$), 'речення з мітками — можна');
select pg_temp.ok(pg_temp.raises($q$insert into public.phrases (text_hr, normalized, ukrainian_translation, status, register)
  values ('M24 test jedan.', 'm24 test jedan.', 'тест', 'DRAFT', 'regional')$q$), 'речення: старе regional — ні');
select pg_temp.ok(pg_temp.raises($q$insert into public.phrases (text_hr, normalized, ukrainian_translation, status, regionality)
  values ('M24 test dva.', 'm24 test dva.', 'тест', 'DRAFT', 'zagreb')$q$), 'речення: регіон з малої — ні');
select pg_temp.ok(pg_temp.raises($q$insert into public.phrases (text_hr, normalized, ukrainian_translation, status, usage_tags)
  values ('M24 test tri.', 'm24 test tri.', 'тест', 'DRAFT', '{slang}')$q$), 'речення: невідома ознака — ні');

select 'ALL TESTS PASSED';
rollback;
