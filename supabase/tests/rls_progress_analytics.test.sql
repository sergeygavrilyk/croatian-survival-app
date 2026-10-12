-- =====================================================================
-- Інтеграційні тести БД: M1 (user_progress, lesson_progress) + M4 (analytics_events)
-- Перевіряють обмеження і RLS від імені двох тестових користувачів.
--
-- БЕЗПЕЧНО для робочої бази: усе виконується в одній транзакції і в кінці
-- відкочується (ROLLBACK) — жодних слідів не лишається.
-- Запуск: Supabase → SQL Editor → вставити файл → Run.
-- Успіх: в останньому рядку результату «ALL TESTS PASSED».
-- Будь-яка помилка зупиняє скрипт з текстом «FAIL: …».
-- =====================================================================
begin;

create or replace function pg_temp.raises(q text) returns boolean language plpgsql as $$
begin
  execute q;
  return false;
exception when others then
  return true;
end $$;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

-- Тестові дані (від імені власника БД)
insert into auth.users (id, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'rls-test-a@example.invalid'),
  ('bbbbbbbb-0000-4000-8000-000000000002', 'rls-test-b@example.invalid');
-- профілі створює тригер on_auth_user_created; на випадок, якщо його немає:
insert into public.profiles (id, email) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'rls-test-a@example.invalid'),
  ('bbbbbbbb-0000-4000-8000-000000000002', 'rls-test-b@example.invalid')
on conflict (id) do nothing;
insert into public.lessons (id, title_ua) values ('cccccccc-0000-4000-8000-000000000003', 'RLS test lesson');
insert into public.lexemes (id, lemma, normalized, ukrainian_translation, cefr)
  values ('dddddddd-0000-4000-8000-000000000004', 'rlstestlemma', 'rlstestlemma', 'тест', 'A0');

-- ---------------------------------------------------------------- користувач A
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

select pg_temp.ok(not pg_temp.raises($q$insert into public.analytics_events (user_id, event_name, lesson_id, level, success, duration_ms, properties)
  values ('aaaaaaaa-0000-4000-8000-000000000001', 'lesson_completed', 'cccccccc-0000-4000-8000-000000000003', 'A0', true, 1000, '{"count":2}')$q$),
  'A може записати свою подію');
select pg_temp.ok(pg_temp.raises($q$insert into public.analytics_events (user_id, event_name)
  values ('bbbbbbbb-0000-4000-8000-000000000002', 'app_open')$q$),
  'A НЕ може записати подію від імені B');
select pg_temp.ok(pg_temp.raises($q$insert into public.analytics_events (user_id, event_name)
  values ('aaaaaaaa-0000-4000-8000-000000000001', 'Drop Table')$q$),
  'некоректна назва події відхиляється');
select pg_temp.ok(pg_temp.raises($q$insert into public.analytics_events (user_id, event_name, properties)
  values ('aaaaaaaa-0000-4000-8000-000000000001', 'app_open', '[1,2]')$q$),
  'properties має бути обʼєктом');
select pg_temp.ok(pg_temp.raises($q$insert into public.analytics_events (user_id, event_name, level)
  values ('aaaaaaaa-0000-4000-8000-000000000001', 'app_open', 'C2')$q$),
  'невідомий рівень відхиляється');
select pg_temp.ok(pg_temp.raises($q$update public.analytics_events set event_name = 'app_open'$q$),
  'події не можна змінювати (append-only)');
select pg_temp.ok(pg_temp.raises($q$delete from public.analytics_events$q$),
  'події не можна видаляти (append-only)');
select pg_temp.ok((select count(*) from public.analytics_events) = 1,
  'A бачить рівно одну свою подію');

select pg_temp.ok(not pg_temp.raises($q$insert into public.lesson_progress (user_id, lesson_id, status, completed_at)
  values ('aaaaaaaa-0000-4000-8000-000000000001', 'cccccccc-0000-4000-8000-000000000003', 'completed', now())$q$),
  'A може зберегти свій прогрес уроку');
select pg_temp.ok(pg_temp.raises($q$insert into public.lesson_progress (user_id, lesson_id, status)
  values ('bbbbbbbb-0000-4000-8000-000000000002', 'cccccccc-0000-4000-8000-000000000003', 'completed')$q$),
  'A НЕ може зберегти прогрес уроку за B');
select pg_temp.ok(pg_temp.raises($q$insert into public.lesson_progress (user_id, lesson_id, status)
  values ('aaaaaaaa-0000-4000-8000-000000000001', 'cccccccc-0000-4000-8000-000000000003', 'done')$q$),
  'невідомий статус уроку відхиляється');

select pg_temp.ok(not pg_temp.raises($q$insert into public.user_progress (user_id, lexeme_id)
  values ('aaaaaaaa-0000-4000-8000-000000000001', 'dddddddd-0000-4000-8000-000000000004')$q$),
  'A може додати слово в повторення');
select pg_temp.ok(pg_temp.raises($q$insert into public.user_progress (user_id, lexeme_id)
  values ('aaaaaaaa-0000-4000-8000-000000000001', 'dddddddd-0000-4000-8000-000000000004')$q$),
  'одне слово — одна картка на користувача (unique)');
select pg_temp.ok(not pg_temp.raises($q$insert into public.user_progress (user_id, lexeme_id, interval_days)
  values ('aaaaaaaa-0000-4000-8000-000000000001', 'dddddddd-0000-4000-8000-000000000004', 5)
  on conflict (user_id, lexeme_id) do nothing$q$),
  'upsert з ignoreDuplicates працює (ON CONFLICT DO NOTHING)');
select pg_temp.ok((select interval_days from public.user_progress where lexeme_id = 'dddddddd-0000-4000-8000-000000000004') = 0,
  'ignoreDuplicates не перезаписує наявний прогрес');

-- ---------------------------------------------------------------- користувач B
select set_config('request.jwt.claims', '{"sub":"bbbbbbbb-0000-4000-8000-000000000002","role":"authenticated"}', true);

select pg_temp.ok((select count(*) from public.analytics_events) = 0, 'B НЕ бачить подій A');
select pg_temp.ok((select count(*) from public.lesson_progress) = 0, 'B НЕ бачить прогресу уроків A');
select pg_temp.ok((select count(*) from public.user_progress) = 0,  'B НЕ бачить повторень A');

-- ---------------------------------------------------------------- гість
reset role;
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.raises($q$insert into public.analytics_events (user_id, event_name)
  values ('aaaaaaaa-0000-4000-8000-000000000001', 'app_open')$q$),
  'гість НЕ може писати події');
select pg_temp.ok((select count(*) from public.analytics_events) = 0, 'гість НЕ бачить подій');

reset role;
select 'ALL TESTS PASSED' as result;
rollback;
