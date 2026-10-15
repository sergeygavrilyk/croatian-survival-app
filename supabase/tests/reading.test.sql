-- =====================================================================
-- Тести M15 «Читання» (§6 ТЗ): reading_texts + reading_progress, тексти reading_a1_v1.
-- Запускати ПІСЛЯ M15, 20261014_reading_a1_v1.sql і 20261015_reading_a1_grammar.sql.
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
-- Запуск: Supabase → SQL Editor → вставити файл → Run. Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

create or replace function pg_temp.n(q text) returns bigint language plpgsql as $$
declare r bigint;
begin
  execute 'select count(*) from (' || q || ') s' into r;
  return r;
end $$;

create or replace function pg_temp.raises(q text) returns boolean language plpgsql as $$
begin
  execute q;
  return false;
exception when others then
  return true;
end $$;

-- ---------------------------------------------------------------- тексти
select pg_temp.ok((select relrowsecurity from pg_class where oid = 'public.reading_texts'::regclass)
  and (select relrowsecurity from pg_class where oid = 'public.reading_progress'::regclass), 'RLS увімкнено на обох таблицях');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where cefr = 'A1' and status = 'PUBLISHED'$q$) >= 40,
  'опубліковано ≥ 40 текстів A1');
select pg_temp.ok(pg_temp.n($q$select distinct text_type from public.reading_texts where status = 'PUBLISHED'$q$) >= 10,
  'щонайменше 10 видів текстів (повідомлення, чат, лист, оголошення, меню, інструкція…)');
select pg_temp.ok(pg_temp.n($q$select distinct module_order from public.reading_texts where cefr = 'A1' and status = 'PUBLISHED'$q$) = 10,
  'тексти є для кожного з 10 модулів A1');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where status = 'PUBLISHED' and cefr = 'A1'
  and (jsonb_array_length(questions) <> 3 or jsonb_array_length(glossary) < 10 or body_ua !~ '[Ѐ-ӿ]' or body_hr ~ '[Ѐ-ӿ]'
       or known_ratio < 0.75 or word_count < 20)$q$) = 0,
  'у кожного тексту A1 3 питання, словничок, переклад, ≥ 75 % знайомих слів (A0 і A2 — reading_a0_a2.test.sql)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r, jsonb_array_elements(r.glossary) g
  where r.status = 'PUBLISHED' and (lower(g->>'ua') in ('переклад', 'translation', 'todo', '') and lower(g->>'lemma') <> 'prijevod'
     or g->>'ua' !~ '[А-Яа-яІіЇїЄєҐґ]')$q$) = 0,
  'у словничку немає перекладів-заглушок («переклад») і кожен переклад — українською');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r, jsonb_array_elements(r.glossary) g
  where r.status = 'PUBLISHED' and (coalesce(g->>'pos', '') !~ '[А-Яа-яІіЇїЄєҐґ]'
     or g->>'form' <> lower(g->>'lemma') and coalesce(g->>'gram', '') !~ '[А-Яа-яІіЇїЄєҐґ]')$q$) = 0,
  'граматика (§56): у кожного слова — частина мови, у кожної зміненої форми — підказка (відмінок, особа…)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r
  where r.status = 'PUBLISHED' and r.version > 1
    and not exists (select 1 from public.content_versions v where v.entity_type = 'reading_text' and v.entity_id = r.id and v.version = r.version - 1)$q$) = 0,
  'змінений текст має знімок попередньої версії в content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r, jsonb_array_elements(r.questions) q
  where r.status = 'PUBLISHED' and not (q->'options') ? (q->>'answer')$q$) = 0,
  'правильна відповідь є серед варіантів');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts r, jsonb_array_elements(r.glossary) g
  where r.status = 'PUBLISHED' and (coalesce(g->>'form', '') = '' or coalesce(g->>'lemma', '') = '' or coalesce(g->>'ua', '') !~ '[Ѐ-ӿ]')$q$) = 0,
  'у словничку кожне слово має форму, лему й переклад');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_reviews c join public.reading_texts r on r.id = c.entity_id
  where c.entity_type = 'reading_text'$q$) >= 40, 'журнал перевірки має запис для кожного тексту');
select pg_temp.ok(pg_temp.raises($q$insert into public.reading_texts (code, cefr, text_type, title_ua, title_hr, body_hr, body_ua)
  values ('RD-A1-999', 'A1', 'poem', 'Тест', 'Test', 'Ovo je test tekst za provjeru.', 'Це тестовий текст для перевірки.')$q$),
  'невідомий вид тексту — заборонено');
select pg_temp.ok(pg_temp.raises($q$insert into public.reading_texts (code, cefr, text_type, title_ua, title_hr, body_hr, body_ua)
  values ('TEXT-1', 'A1', 'story', 'Тест', 'Test', 'Ovo je test tekst za provjeru.', 'Це тестовий текст для перевірки.')$q$),
  'код не за форматом — заборонено');

-- чернетка для перевірки видимості
insert into public.reading_texts (code, cefr, text_type, title_ua, title_hr, body_hr, body_ua, status)
values ('RD-A1-990', 'A1', 'story', 'Чернетка', 'Nacrt', 'Ovo je nacrt teksta za test.', 'Це чернетка тексту для тесту.', 'DRAFT');

insert into auth.users (id, email) values
  ('a1500000-0000-4000-8000-0000000000a1', 'm15-user-a@example.invalid'),
  ('b1500000-0000-4000-8000-0000000000b1', 'm15-user-b@example.invalid');

-- ---------------------------------------------------------------- гість
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts$q$) >= 40, 'гість бачить опубліковані тексти');
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where code = 'RD-A1-990'$q$) = 0, 'гість не бачить чернетки');
select pg_temp.ok(pg_temp.raises($q$select 1 from public.reading_progress$q$)
  or pg_temp.n($q$select 1 from public.reading_progress$q$) = 0, 'гість не бачить прогресу читання');

-- ---------------------------------------------------------------- користувач A
reset role;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a1500000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
select pg_temp.ok(pg_temp.raises($q$update public.reading_texts set title_ua = 'Зламано' where code = 'RD-A1-001'$q$)
  or (select title_ua from public.reading_texts where code = 'RD-A1-001') <> 'Зламано', 'користувач не може змінити текст');
insert into public.reading_progress (user_id, text_id, correct_count, question_count)
select 'a1500000-0000-4000-8000-0000000000a1', id, 2, 3 from public.reading_texts where code = 'RD-A1-001';
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_progress$q$) = 1, 'A записує свій прогрес читання');
select pg_temp.ok(pg_temp.raises($q$insert into public.reading_progress (user_id, text_id, correct_count, question_count)
  select 'a1500000-0000-4000-8000-0000000000a1', id, 3, 3 from public.reading_texts where code = 'RD-A1-001'$q$),
  'той самий текст удруге — не дублюється (оновлюється)');
select pg_temp.ok(pg_temp.raises($q$insert into public.reading_progress (user_id, text_id, correct_count, question_count)
  select 'a1500000-0000-4000-8000-0000000000a1', id, 4, 3 from public.reading_texts where code = 'RD-A1-002'$q$),
  'правильних відповідей не більше, ніж питань');
select pg_temp.ok(pg_temp.raises($q$insert into public.reading_progress (user_id, text_id)
  select 'b1500000-0000-4000-8000-0000000000b1', id from public.reading_texts where code = 'RD-A1-003'$q$),
  'A не може записати прогрес від імені B');
select pg_temp.ok(pg_temp.raises($q$delete from public.reading_progress$q$)
  or pg_temp.n($q$select 1 from public.reading_progress$q$) = 1, 'видаляти прогрес через API не можна');

-- ---------------------------------------------------------------- користувач B
reset role;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"b1500000-0000-4000-8000-0000000000b1","role":"authenticated"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_progress$q$) = 0, 'B не бачить прогресу A');
update public.reading_progress set correct_count = 0;
reset role;
select pg_temp.ok((select correct_count from public.reading_progress limit 1) = 2, 'B не може змінити прогрес A');

select 'ALL TESTS PASSED' as result;
rollback;
