-- =====================================================================
-- Інтеграційні тести M2 (статуси контенту), M3 (адміни), M4b (облік AI).
-- Перевіряють RLS від імені гостя, звичайного користувача і адміна.
--
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
-- Запуск: Supabase → SQL Editor → вставити файл → Run.
-- Успіх: в останньому рядку «ALL TESTS PASSED». Помилка — «FAIL: …».
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

create or replace function pg_temp.n(q text) returns bigint language plpgsql as $$
declare r bigint;
begin
  execute 'select count(*) from (' || q || ') s' into r;
  return r;
end $$;

-- ---------------------------------------------------------------- дані (власник БД)
insert into auth.users (id, email) values
  ('a1a1a1a1-0000-4000-8000-0000000000a1', 'm2m3-user@example.invalid'),
  ('ad000000-0000-4000-8000-0000000000ad', 'm2m3-admin@example.invalid');
insert into public.app_admins (user_id, note) values ('ad000000-0000-4000-8000-0000000000ad', 'test admin');
insert into public.levels (code, title_ua, title_hr, order_index, status) values ('ZZ', 'M2 тест', 'M2 test', 9999, 'DRAFT');

insert into public.lexemes (id, lemma, normalized, ukrainian_translation, cefr, status) values
  ('e1000000-0000-4000-8000-000000000001', 'm2testpublished', 'm2testpublished', 'тест', 'A0', 'PUBLISHED'),
  ('e1000000-0000-4000-8000-000000000002', 'm2testdraft', 'm2testdraft', 'тест', 'A0', 'NEEDS_REVIEW');
insert into public.lexemes (id, lemma, normalized, ukrainian_translation, cefr)
  values ('e1000000-0000-4000-8000-000000000003', 'm2testdefault', 'm2testdefault', 'тест', 'A0');

insert into public.conversations (id, title_ua, status) values
  ('c2000000-0000-4000-8000-000000000001', 'M2 published', 'PUBLISHED'),
  ('c2000000-0000-4000-8000-000000000002', 'M2 draft', 'DRAFT');
insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation) values
  ('c2000000-0000-4000-8000-000000000001', 'A', 'Bok!', 'Привіт!'),
  ('c2000000-0000-4000-8000-000000000002', 'A', 'Skica.', 'Чернетка.');

insert into public.lessons (id, title_ua, status) values
  ('b3000000-0000-4000-8000-000000000001', 'M2 lesson published', 'PUBLISHED'),
  ('b3000000-0000-4000-8000-000000000002', 'M2 lesson draft', 'DRAFT');
insert into public.lesson_items (lesson_id, item_type, item_id, order_index) values
  ('b3000000-0000-4000-8000-000000000001', 'vocabulary', 'e1000000-0000-4000-8000-000000000001', 1),
  ('b3000000-0000-4000-8000-000000000002', 'vocabulary', 'e1000000-0000-4000-8000-000000000002', 1);

-- ---------------------------------------------------------------- схема M2
select pg_temp.ok((select status from public.lexemes where id = 'e1000000-0000-4000-8000-000000000003') = 'AI_GENERATED',
  'нове слово без статусу отримує AI_GENERATED');
select pg_temp.ok(pg_temp.raises($q$insert into public.lexemes (lemma, normalized, ukrainian_translation, status) values ('m2bad', 'm2bad', 'x', 'Published')$q$),
  'невідомий статус відхиляється (CHECK)');
select pg_temp.ok(pg_temp.raises($q$update public.lessons set status = null where id = 'b3000000-0000-4000-8000-000000000001'$q$),
  'статус уроку не може бути порожнім');
select pg_temp.ok((select published_at is not null from public.lexemes where id = 'e1000000-0000-4000-8000-000000000001'),
  'published_at ставиться при публікації');
select pg_temp.ok((select published_at is null from public.lexemes where id = 'e1000000-0000-4000-8000-000000000002'),
  'у неопублікованого слова published_at порожній');
update public.lexemes set status = 'PUBLISHED' where id = 'e1000000-0000-4000-8000-000000000002';
select pg_temp.ok((select published_at is not null and updated_at >= created_at from public.lexemes where id = 'e1000000-0000-4000-8000-000000000002'),
  'публікація оновлює published_at і updated_at');
update public.lexemes set status = 'NEEDS_REVIEW', published_at = null where id = 'e1000000-0000-4000-8000-000000000002';
select pg_temp.ok((select column_default from information_schema.columns where table_schema = 'public' and table_name = 'conversations' and column_name = 'status') like '%DRAFT%',
  'новий діалог за замовчуванням DRAFT');

-- ---------------------------------------------------------------- гість
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);

select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma like 'm2test%'$q$) = 1,
  'гість бачить лише опубліковане слово');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversation_turns where conversation_id in ('c2000000-0000-4000-8000-000000000001', 'c2000000-0000-4000-8000-000000000002')$q$) = 1,
  'гість бачить репліки лише опублікованого діалогу');
select pg_temp.ok(not public.is_admin(), 'гість не адмін');

-- ---------------------------------------------------------------- звичайний користувач
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a1a1a1a1-0000-4000-8000-0000000000a1","role":"authenticated"}', true);

select pg_temp.ok(not public.is_admin(), 'звичайний користувач не адмін');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma like 'm2test%'$q$) = 1,
  'користувач не бачить чернеток і AI_GENERATED');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in ('b3000000-0000-4000-8000-000000000001', 'b3000000-0000-4000-8000-000000000002')$q$) = 1,
  'користувач не бачить чернетку уроку');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items where lesson_id in ('b3000000-0000-4000-8000-000000000001', 'b3000000-0000-4000-8000-000000000002')$q$) = 1,
  'користувач не бачить кроки чернетки уроку');
select pg_temp.ok(pg_temp.raises($q$insert into public.lexemes (lemma, normalized, ukrainian_translation) values ('m2hack', 'm2hack', 'x')$q$),
  'користувач не може додати слово');
update public.lexemes set ukrainian_translation = 'зламано' where id = 'e1000000-0000-4000-8000-000000000001';
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where ukrainian_translation = 'зламано'$q$) = 0,
  'користувач не може змінити слово');
select pg_temp.ok(pg_temp.raises($q$insert into public.app_admins (user_id) values ('a1a1a1a1-0000-4000-8000-0000000000a1')$q$),
  'користувач не може зробити себе адміном');
select pg_temp.ok(pg_temp.n($q$select 1 from public.app_admins$q$) = 0,
  'користувач не бачить список адмінів');
select pg_temp.ok(pg_temp.raises($q$insert into public.content_reviews (entity_type, entity_id, verdict) values ('lexeme', 'e1000000-0000-4000-8000-000000000002', 'approved')$q$),
  'користувач не може записати рев''ю контенту');

-- облік AI: свої події
select pg_temp.ok(not pg_temp.raises($q$insert into public.ai_usage_events (user_id, feature, provider, model, input_tokens, output_tokens, latency_ms)
  values ('a1a1a1a1-0000-4000-8000-0000000000a1', 'quick_translate', 'gemini', 'test-model', 10, 5, 300)$q$),
  'користувач записує свою подію AI');
select pg_temp.ok(not pg_temp.raises($q$insert into public.ai_usage_events (feature, provider) values ('tts', 'google_translate_tts')$q$),
  'user_id підставляється автоматично');
select pg_temp.ok(pg_temp.raises($q$insert into public.ai_usage_events (user_id, feature, provider) values ('ad000000-0000-4000-8000-0000000000ad', 'chat', 'gemini')$q$),
  'не можна записати подію AI від імені іншого');
select pg_temp.ok(pg_temp.raises($q$insert into public.ai_usage_events (feature, provider) values ('Hack', 'gemini')$q$),
  'невідома функція AI відхиляється');
select pg_temp.ok(pg_temp.raises($q$update public.ai_usage_events set cost_usd = 0$q$),
  'події AI не можна змінювати (append-only)');

-- ---------------------------------------------------------------- адмін
select set_config('request.jwt.claims', '{"sub":"ad000000-0000-4000-8000-0000000000ad","role":"authenticated"}', true);

select pg_temp.ok(public.is_admin(), 'адмін розпізнається');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lemma like 'm2test%'$q$) = 3,
  'адмін бачить усі статуси');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items where lesson_id in ('b3000000-0000-4000-8000-000000000001', 'b3000000-0000-4000-8000-000000000002')$q$) = 2,
  'адмін бачить кроки чернетки уроку');
select pg_temp.ok(not pg_temp.raises($q$insert into public.lexemes (lemma, normalized, ukrainian_translation, cefr) values ('m2adminword', 'm2adminword', 'адмін', 'A0')$q$),
  'адмін додає слово');
select pg_temp.ok(not pg_temp.raises($q$insert into public.modules (level_code, title_ua, order_index) values ('ZZ', 'M2 test module', 1)$q$),
  'адмін створює модуль (раніше не працювало)');
update public.lexemes set status = 'APPROVED' where id = 'e1000000-0000-4000-8000-000000000002';
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where id = 'e1000000-0000-4000-8000-000000000002' and status = 'APPROVED'$q$) = 1,
  'адмін змінює статус');
delete from public.lexemes where id = 'e1000000-0000-4000-8000-000000000001';
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where id = 'e1000000-0000-4000-8000-000000000001'$q$) = 1,
  'адмін НЕ видаляє контент через API (лише DEPRECATED)');
select pg_temp.ok(not pg_temp.raises($q$insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, findings)
  values ('lexeme', 'e1000000-0000-4000-8000-000000000002', 'NEEDS_REVIEW', 'APPROVED', 'approved', '[]')$q$),
  'адмін записує рев''ю контенту');
select pg_temp.ok(pg_temp.raises($q$update public.content_reviews set verdict = 'rejected'$q$),
  'рев''ю не можна змінити (append-only)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.ai_usage_events where user_id = 'a1a1a1a1-0000-4000-8000-0000000000a1'$q$) = 2,
  'адмін бачить події AI інших користувачів');

-- ---------------------------------------------------------------- знову користувач
select set_config('request.jwt.claims', '{"sub":"a1a1a1a1-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.ai_usage_events$q$) = 2,
  'користувач бачить лише свої події AI');

reset role;
select 'ALL TESTS PASSED' as result;
rollback;
