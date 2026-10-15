-- =====================================================================
-- Тести M17 + тести рівня A0 і A1 (assessment_v1, §60) · 2026-10-15
-- Запускати ПІСЛЯ M17, 20261015_assessments_a0_v1.sql і 20261015_assessments_a1_v1.sql.
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK (тимчасових таблиць немає).
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

-- ---------------------------------------------------------------- M17: схема
select pg_temp.ok(pg_temp.n($q$select 1 from information_schema.columns where table_schema = 'public'
  and (table_name, column_name) in (('assessments', 'cefr'), ('assessments', 'module_id'), ('assessments', 'pass_ratio'),
       ('assessments', 'area_min_ratio'), ('assessment_items', 'area'), ('assessment_items', 'audio_hr'),
       ('assessment_items', 'passage_hr'), ('assessment_items', 'answer_text'), ('assessment_items', 'lesson_id'),
       ('assessment_attempts', 'score'), ('assessment_attempts', 'passed'), ('assessment_attempts', 'area_scores'))$q$) = 12,
  'M17: нові колонки тестів, завдань і спроб');

select pg_temp.ok(pg_temp.raises($q$insert into public.assessment_items (assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, options, answer_text)
  select id, 999, 'A0', 'writing', 'produce', 'type_answer', 'x', '["a","b"]', 'kava' from public.assessments where slug = 'a0-m01'$q$),
  'M17: «напишіть» без варіантів відповіді');
select pg_temp.ok(pg_temp.raises($q$insert into public.assessment_items (assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, options)
  select id, 999, 'A0', 'writing', 'produce', 'speaking', 'x', '[]' from public.assessments where slug = 'a0-m01'$q$),
  'M17: «скажіть» без правильної відповіді відхиляється');
select pg_temp.ok(pg_temp.raises($q$insert into public.assessment_items (assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, options)
  select id, 999, 'A0', 'listening', 'understand', 'multiple_choice', 'x', '["a","b"]' from public.assessments where slug = 'a0-m01'$q$),
  'M17: вибір без правильного індексу відхиляється');
select pg_temp.ok(pg_temp.raises($q$insert into public.assessment_items (assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, options, correct_index)
  select id, 999, 'A0', 'listening', 'speak_well', 'multiple_choice', 'x', '["a","b"]', 0 from public.assessments where slug = 'a0-m01'$q$),
  'M17: невідома навичка §60 відхиляється');
select pg_temp.ok(pg_temp.raises($q$insert into public.assessment_items (assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, options, correct_index, audio_hr)
  select id, 999, 'A0', 'listening', 'understand', 'multiple_choice', 'x', '["a","b"]', 0, 'Добрий день' from public.assessments where slug = 'a0-m01'$q$),
  'M17: кирилиця в хорватській фразі відхиляється');
select pg_temp.ok(pg_temp.raises($q$insert into public.assessments (slug, kind, title_ua, cefr) values ('m17-bad-module', 'module', 'x', 'A0')$q$),
  'M17: тест модуля без модуля відхиляється');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug = 'placement-v1' and i.item_type = 'multiple_choice' and i.correct_index is not null$q$)
  = pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id where a.slug = 'placement-v1'$q$),
  'M17: питання тесту рівня (placement) не змінилися — усі з вибором');

-- ---------------------------------------------------------------- тести A0 і A1
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments where source = 'claude_assessment_v1' and status = 'PUBLISHED'
  and cefr in ('A0', 'A1')$q$) = 24, 'A0 і A1: по 12 тестів (10 модулів + середина + кінець), опубліковано (бета)');
select pg_temp.ok(pg_temp.n($q$select cefr from public.assessments where source = 'claude_assessment_v1'
  group by cefr having count(*) filter (where kind = 'module') = 10 and count(distinct module_id) filter (where kind = 'module') = 10
     and count(*) filter (where kind = 'mid') = 1 and count(*) filter (where kind = 'final') = 1$q$) = 2,
  'кожен рівень: тест на кожен із 10 модулів, один тест середини й один фінальний');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments a join public.modules m on m.id = a.module_id
  where a.source = 'claude_assessment_v1' and (m.level_code <> a.cefr or a.slug <> lower(a.cefr) || '-m' || lpad(m.order_index::text, 2, '0'))$q$) = 0,
  'тест модуля прив''язаний до свого модуля (адреса a0-m03 = модуль A0.3)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments a where a.source = 'claude_assessment_v1'
  and (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED')
      <> case a.kind when 'module' then 10 when 'mid' then 20 else 30 end$q$) = 0,
  'завдань: модуль — 10, середина — 20, фінал — 30');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments a where a.source = 'claude_assessment_v1'
  and exists (select 1 from unnest(array['understand', 'produce', 'interact', 'mediate']) ar
              where (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.area = ar)
                    < case a.kind when 'module' then 2 else 5 end)$q$) = 0,
  'кожен тест перевіряє всі 4 навички §60 (розумію, кажу, спілкуюся, переказую)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments a where a.source = 'claude_assessment_v1'
  and not exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.item_type = 'speaking')$q$) = 0,
  'у кожному тесті є завдання «скажіть уголос» (його можна пропустити)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments where source = 'claude_assessment_v1'
  and (pass_ratio <> 0.70 or area_min_ratio <> 0.50)$q$) = 0,
  'поріг — рішення власника: ≥ 70 % загалом і ≥ 50 % у кожній навичці');

-- ---------------------------------------------------------------- якість завдань
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.source = 'claude_assessment_v1' and (i.area is null or i.cefr <> a.cefr or i.prompt_ua !~ '[А-Яа-яІіЇїЄєҐґ]')$q$) = 0,
  'у кожного завдання — навичка, рівень тесту й питання українською');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.source = 'claude_assessment_v1' and i.item_type = 'multiple_choice'
    and (select count(distinct lower(o)) from jsonb_array_elements_text(i.options) o) <> jsonb_array_length(i.options)$q$) = 0,
  'варіанти відповіді не повторюються');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.source = 'claude_assessment_v1' and i.skill = 'interaction'
    and (i.prompt_hr is null or exists (select 1 from jsonb_array_elements_text(i.options) o where o ~ '[Ѐ-ӿ]'))$q$) = 0,
  '«Спілкуюся»: репліка й варіанти відповіді — хорватською');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.source = 'claude_assessment_v1' and i.skill = 'listening'
    and (i.audio_hr is null or exists (select 1 from jsonb_array_elements_text(i.options) o where o !~ '[А-Яа-яІіЇїЄєҐґ]'))$q$) = 0,
  '«На слух»: є фраза для озвучення, варіанти — українською');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.source = 'claude_assessment_v1' and (i.item_type <> 'multiple_choice' and coalesce(i.answer_text, '') = ''
     or i.item_type = 'sentence_builder' and (select string_agg(o, ' ' order by o) from jsonb_array_elements_text(i.options) o)
        <> (select string_agg(w, ' ' order by w) from regexp_split_to_table(trim(i.answer_text), '\s+') w))$q$) = 0,
  '«Складіть»: плитки — рівно слова правильного речення');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.source = 'claude_assessment_v1' and i.skill <> 'reading'
    and not exists (select 1 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                    where l.id = i.lesson_id and l.status = 'PUBLISHED' and m.level_code = a.cefr
                      and (a.kind <> 'module' or m.id = a.module_id)
                      and (a.kind <> 'mid' or m.order_index <= 5))$q$) = 0,
  'кожне завдання — з опублікованого уроку свого рівня (тест модуля — з цього модуля, середина — з модулів 1–5)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.source = 'claude_assessment_v1' and (i::text ~* 'osnovni_pojam|базовий термін|placeholder|todo|переклад»')$q$) = 0,
  'без заглушок');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments a where a.source = 'claude_assessment_v1'
  and not exists (select 1 from public.content_reviews c where c.entity_type = 'assessment' and c.entity_id = a.id)$q$) = 0,
  'журнал перевірки має запис для кожного тесту');

-- ---------------------------------------------------------------- спроби: лише свої, лише додавання
insert into auth.users (id, email) values
  ('a1700000-0000-4000-8000-0000000000a1', 'm17-user-a@example.invalid'),
  ('b1700000-0000-4000-8000-0000000000b1', 'm17-user-b@example.invalid');
insert into public.profiles (id, email) values
  ('a1700000-0000-4000-8000-0000000000a1', 'm17-user-a@example.invalid'),
  ('b1700000-0000-4000-8000-0000000000b1', 'm17-user-b@example.invalid')
on conflict (id) do nothing;

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a1700000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
select pg_temp.ok(not pg_temp.raises($q$insert into public.assessment_attempts (user_id, assessment_id, answers, score, passed, area_scores,
    skill_profile, estimated_cefr, confidence, recommended_start)
  select 'a1700000-0000-4000-8000-0000000000a1', id, '[]', 0.8, true,
    '{"understand": {"correct": 3, "total": 3, "skipped": 0}}', '{}', 'A0', 'medium', 'A0'
  from public.assessments where slug = 'a0-m01'$q$), 'користувач зберігає свою спробу з балом і «пройдено»');
select pg_temp.ok(pg_temp.raises($q$insert into public.assessment_attempts (user_id, assessment_id, score, estimated_cefr, confidence, recommended_start)
  select 'a1700000-0000-4000-8000-0000000000a1', id, 1.5, 'A0', 'low', 'A0' from public.assessments where slug = 'a0-m01'$q$),
  'бал поза 0…1 відхиляється');
select pg_temp.ok(pg_temp.raises($q$insert into public.assessment_attempts (user_id, assessment_id, estimated_cefr, confidence, recommended_start)
  select 'b1700000-0000-4000-8000-0000000000b1', id, 'A0', 'low', 'A0' from public.assessments where slug = 'a0-m01'$q$),
  'чужу спробу записати не можна');
select pg_temp.ok(pg_temp.raises($q$update public.assessment_attempts set passed = false where user_id = 'a1700000-0000-4000-8000-0000000000a1'$q$)
  and pg_temp.n($q$select 1 from public.assessment_attempts where user_id = 'a1700000-0000-4000-8000-0000000000a1' and passed$q$) = 1,
  'результат спроби змінити не можна');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments where source = 'claude_assessment_v1'$q$) = 24,
  'користувач бачить усі 24 тести');

select set_config('request.jwt.claims', '{"sub":"b1700000-0000-4000-8000-0000000000b1","role":"authenticated"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_attempts where user_id = 'a1700000-0000-4000-8000-0000000000a1'$q$) = 0,
  'інший користувач не бачить чужих спроб');
reset role;

set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.source = 'claude_assessment_v1'$q$) = 300, 'гість бачить опубліковані завдання (300)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_attempts$q$) = 0, 'гість не бачить спроб');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
