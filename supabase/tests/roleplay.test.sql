-- =====================================================================
-- Інтеграційні тести M9: рольова гра (ai_conversations, ai_messages, user_errors).
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
-- Запуск: Supabase → SQL Editor → вставити файл → Run. Успіх: «ALL TESTS PASSED».
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

insert into auth.users (id, email) values
  ('a9a9a9a9-0000-4000-8000-0000000000a9', 'm9-user-a@example.invalid'),
  ('b9b9b9b9-0000-4000-8000-0000000000b9', 'm9-user-b@example.invalid');
insert into public.ai_conversations (id, user_id, mode, situation, level) values
  ('c9b00000-0000-4000-8000-0000000000b9', 'b9b9b9b9-0000-4000-8000-0000000000b9', 'roleplay', 'bank', 'A2');

-- ---------------------------------------------------------------- користувач A
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a9a9a9a9-0000-4000-8000-0000000000a9","role":"authenticated"}', true);

select pg_temp.ok(not pg_temp.raises($q$insert into public.ai_conversations (id, user_id, mode, situation, level)
  values ('c9a00000-0000-4000-8000-0000000000a9', 'a9a9a9a9-0000-4000-8000-0000000000a9', 'roleplay', 'cafe_restaurant', 'A1')$q$),
  'A починає рольову гру');
select pg_temp.ok(pg_temp.raises($q$insert into public.ai_conversations (user_id, mode, situation, level)
  values ('a9a9a9a9-0000-4000-8000-0000000000a9', 'roleplay', 'cafe', 'C2')$q$),
  'невідомий рівень відхиляється');
select pg_temp.ok(not pg_temp.raises($q$insert into public.ai_messages (conversation_id, role, content, translation_ua)
  values ('c9a00000-0000-4000-8000-0000000000a9', 'assistant', 'Dobar dan! Izvolite?', 'Добрий день! Прошу?')$q$),
  'A додає репліку AI у свою розмову');
select pg_temp.ok(not pg_temp.raises($q$insert into public.ai_messages (conversation_id, role, content, correction)
  values ('c9a00000-0000-4000-8000-0000000000a9', 'user', 'jedna kava', '{"corrected_hr":"Jednu kavu, molim.","explanation_ua":"Відмінок","type":"grammar"}')$q$),
  'A додає свою репліку з виправленням');
select pg_temp.ok(pg_temp.raises($q$insert into public.ai_messages (conversation_id, role, content)
  values ('c9b00000-0000-4000-8000-0000000000b9', 'user', 'hack')$q$),
  'A не може писати в чужу розмову');
select pg_temp.ok(pg_temp.raises($q$insert into public.ai_messages (conversation_id, role, content)
  values ('c9a00000-0000-4000-8000-0000000000a9', 'hacker', 'x')$q$),
  'невідома роль повідомлення відхиляється');
select pg_temp.ok(pg_temp.raises($q$update public.ai_messages set content = 'змінено'$q$),
  'повідомлення не можна змінювати');
update public.ai_conversations set user_turns = 1, ended_at = now(), goal_reached = true,
  summary = '{"task_completed":true}' where id = 'c9a00000-0000-4000-8000-0000000000a9';
select pg_temp.ok((select goal_reached from public.ai_conversations where id = 'c9a00000-0000-4000-8000-0000000000a9'),
  'A завершує свою розмову');
select pg_temp.ok(pg_temp.raises($q$update public.ai_conversations set user_id = 'b9b9b9b9-0000-4000-8000-0000000000b9' where id = 'c9a00000-0000-4000-8000-0000000000a9'$q$),
  'розмову не можна передати іншому');

select pg_temp.ok(not pg_temp.raises($q$insert into public.user_errors (source, conversation_id, situation, original_text, corrected_text, explanation_ua, error_type)
  values ('roleplay', 'c9a00000-0000-4000-8000-0000000000a9', 'cafe_restaurant', 'jedna kava', 'jednu kavu', 'Відмінок', 'grammar')$q$),
  'A зберігає свою помилку для повторення');
select pg_temp.ok(pg_temp.raises($q$insert into public.user_errors (source, conversation_id, original_text, corrected_text)
  values ('roleplay', 'c9b00000-0000-4000-8000-0000000000b9', 'x', 'y')$q$),
  'помилку не можна прив''язати до чужої розмови');
select pg_temp.ok(pg_temp.raises($q$insert into public.user_errors (user_id, source, original_text, corrected_text)
  values ('b9b9b9b9-0000-4000-8000-0000000000b9', 'roleplay', 'x', 'y')$q$),
  'не можна записати помилку за іншого');
select pg_temp.ok(pg_temp.raises($q$insert into public.user_errors (source, original_text, corrected_text, error_type) values ('roleplay', 'x', 'y', 'hack')$q$),
  'невідомий тип помилки відхиляється');
update public.user_errors set resolved_at = now();
select pg_temp.ok(pg_temp.n($q$select 1 from public.user_errors where resolved_at is not null$q$) = 1,
  'A позначає свою помилку засвоєною');
select pg_temp.ok(pg_temp.raises($q$delete from public.user_errors$q$) or pg_temp.n($q$select 1 from public.user_errors$q$) = 1,
  'помилки не видаляються');

-- ---------------------------------------------------------------- користувач B
select set_config('request.jwt.claims', '{"sub":"b9b9b9b9-0000-4000-8000-0000000000b9","role":"authenticated"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.ai_messages where conversation_id = 'c9a00000-0000-4000-8000-0000000000a9'$q$) = 0,
  'B не бачить повідомлень A');
select pg_temp.ok(pg_temp.n($q$select 1 from public.user_errors$q$) = 0, 'B не бачить помилок A');
select pg_temp.ok(pg_temp.n($q$select 1 from public.ai_conversations$q$) = 1, 'B бачить лише свою розмову');

-- ---------------------------------------------------------------- гість
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.ai_conversations$q$) = 0, 'гість не бачить розмов');
select pg_temp.ok(pg_temp.n($q$select 1 from public.user_errors$q$) = 0, 'гість не бачить помилок');

reset role;
select 'ALL TESTS PASSED' as result;
rollback;
