-- =====================================================================
-- Тест пакетів 20261117_a0_pets_module.sql і 20261117_a0_pets_tests_m05_m06.sql: новий модуль A0.6 «Kućni ljubimci»
-- (урок 37 + 6 нових уроків), модулі A0.6–A0.10 → A0.7–A0.11, уроків A0 — 72, перевірки модулів A0 — 11.
-- Запускати ПІСЛЯ обох пакетів. БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
-- Успіх: «ALL TESTS PASSED».
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

-- нові уроки 38–43 (id, місце в модулі)
create or replace function pg_temp.pets() returns table (lid uuid, o int, n int) language sql as $$
  select * from (values ('64ad8ee5-741e-54e5-b31d-88f1130e3f3e'::uuid, 2, 38), ('5c421c03-f070-538e-b152-8c50b31f4daf'::uuid, 3, 39),
                        ('fa7fd153-275f-5214-b759-2db31e50a4b4'::uuid, 4, 40), ('5ffbe419-6abc-574e-907e-2dc427276abd'::uuid, 5, 41),
                        ('d3008969-de66-509c-a2d4-88987322edb5'::uuid, 6, 42), ('0a9c3362-e49a-5e17-bb46-9f3a345b67e4'::uuid, 7, 43)) as t(lid, o, n)
$$;

-- ---------------------------------------------------------------- модулі
select pg_temp.ok(pg_temp.n($q$select 1 from public.modules where level_code = 'A0' and status = 'PUBLISHED'$q$) = 11
  and pg_temp.n($q$select 1 from public.modules where level_code = 'A0'
                   and title_ua ~ ('^Модуль A0\.' || order_index || ' ') and title_hr ~ ('^Modul A0\.' || order_index || ' ')$q$) = 11
  and (select max(order_index) from public.modules where level_code = 'A0') = 11,
  'A0: 11 модулів на місцях 1–11, номер у назві = місце');
select pg_temp.ok((select title_ua from public.modules where id = 'fd6730dd-07aa-590d-b7db-c639e3ed3919' and order_index = 6)
  = 'Модуль A0.6 — Kućni ljubimci (домашні тварини)'
  and (select title_ua from public.modules where id = 'c65b21ca-4c8b-5b74-8b12-7014e57210db') = 'Модуль A0.7 — Moj dom (мій дім)'
  and (select title_ua from public.modules where id = '588b0086-831d-5577-b992-b00f68e9dd87') = 'Модуль A0.11 — Survival Croatian (виживання)',
  'новий A0.6 «Kućni ljubimci»; Moj dom — A0.7, Survival — A0.11');
select pg_temp.ok(pg_temp.n($q$select 1 from backup.modules_a0_20261117$q$) = 10
  and not has_table_privilege('anon', 'backup.modules_a0_20261117', 'select'),
  'стара версія 10 модулів A0 — у backup (без доступу для anon)');

-- ---------------------------------------------------------------- уроки модуля
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id
  where u.module_id = 'fd6730dd-07aa-590d-b7db-c639e3ed3919' and l.status = 'PUBLISHED'$q$) = 7
  and (select order_index from public.lessons where id = '40b9da1d-1686-5b78-8317-0439067d5f8e') = 1
  and pg_temp.n($q$select 1 from pg_temp.pets() t join public.lessons l on l.id = t.lid and l.order_index = t.o
                   and l.unit_id = 'aaf6ad60-560f-5720-9a19-24398989dd00' and l.title_ua like 'Урок ' || t.n || ':%'$q$) = 6,
  'A0.6: урок 37 першим, далі уроки 38–43');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A0' and status = 'PUBLISHED'$q$) = 73
  and pg_temp.n($q$select 1 from (select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = 'A0' and l.status = 'PUBLISHED') t
     where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%'$q$) = 0,
  'A0: 73 уроки (2026-11-17: + «В аптеці», PR 2б), пронумеровані підряд');
select pg_temp.ok((select title_ua from public.lessons where id = '78f28f85-dd8b-5e81-8a52-1b2dbce4eb34') = 'Урок 44: Моя квартира'
  and pg_temp.n($q$select 1 from public.content_versions where entity_type = 'lesson' and change_reason like 'a0_pets: новий номер уроку%'$q$) = 29,
  'уроки 38–66 → 44–72; старі назви — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.pets() v
  where (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'lexeme') not between 20 and 25
     or (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'exercise' and i.required) <> 15
     or (select count(distinct e.exercise_type) from public.lesson_items i join public.exercises e on e.id = i.item_id
          where i.lesson_id = v.lid and i.item_type = 'exercise' and i.required) <> 6
     or (select count(*) from public.lesson_items i join public.exercises e on e.id = i.item_id
          where i.lesson_id = v.lid and i.item_type = 'exercise' and not i.required and e.exercise_type in ('write_message', 'mediation')) <> 2
     or (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'grammar') <> 1$q$) = 0,
  'кожен новий урок: 20–25 слів, 15 вправ (6 типів), граматика, письмо й переказ (необов’язкові)');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.pets() v join public.conversations c on c.lesson_id = v.lid and c.status = 'PUBLISHED'
  where c.situation is not null and (select count(*) from public.conversation_turns t where t.conversation_id = c.id) between 6 and 8$q$) = 12,
  'кожен новий урок: 2 діалоги по 6–8 реплік з кодом ситуації');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.pets() v join public.lessons l on l.id = v.lid
  where l.estimated_minutes <> 15 or jsonb_array_length(l.objectives) < 2$q$) = 0, 'урок — 15 хвилин, щонайменше 2 цілі');
select pg_temp.ok(pg_temp.n($q$select i.item_id from public.lesson_items i join public.lessons l on l.id = i.lesson_id
  where i.item_type = 'lexeme' and l.status = 'PUBLISHED'
    and i.item_id in (select i2.item_id from public.lesson_items i2 where i2.item_type = 'lexeme' and i2.lesson_id in (select lid from pg_temp.pets()))
  group by 1 having count(*) > 1$q$) = 0,
  'слова нових уроків не повторюються ні в модулі, ні в жодному іншому уроці (усі рівні)');

-- ---------------------------------------------------------------- слова
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a0_pets'$q$) = 100
  and pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a0_pets' and status = 'PUBLISHED' and cefr = 'A0'
     and normalized !~ '[čćđšž]' and normalized = lower(normalized) and lemma !~ '[Ѐ-ӿ]' and ukrainian_translation ~ '[Ѐ-ӿ]'
     and jsonb_array_length(examples) = 1 and regionality = 'general' and usage_tags = '{}'
     and (part_of_speech <> 'noun' or forms->>'gender' is not null) and (part_of_speech <> 'verb' or forms->>'aspect' is not null)$q$) = 100,
  '100 нових слів: A0, опубліковані, рід / вид, приклад, мітки');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a0_pets' and register <> 'standard'$q$) = 2
  and pg_temp.n($q$select 1 from public.lexemes where lemma in ('maca', 'mic mic') and register = 'informal'$q$) = 2,
  'регістр: усі standard, крім maca і mic mic (informal)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where lower(lemma) in ('pustiti', 'oprez', 'opasan', 'bojati se', 'skočiti', 'pobjeći',
  'sakriti se', 'operacija', 'čokolada', 'protiv', 'krava', 'konj', 'ovca', 'koza', 'svinja', 'kokoš', 'patka', 'seljak', 'livada',
  'dopustiti', 'plašljiv', 'šansa', 'prepoznati') and status = 'PUBLISHED' and cefr = 'A0'$q$) = 23
  and pg_temp.n($q$select 1 from public.content_versions v join public.lexemes x on x.id = v.entity_id
                   where v.entity_type = 'lexeme' and v.change_reason like 'a0_pets: рівень слова A0%' and x.cefr = 'A0'$q$) = 21,
  '23 наявні слова, які вперше вчать у A0.6, — рівень A0 (21 змінено, стара версія — у content_versions; oprez, opasan уже A0)');

-- ---------------------------------------------------------------- граматика
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
  where g.cefr = 'A0' and g.status = 'PUBLISHED' and g.title_ua = 'Можна чи не можна? Smjeti і команди'
    and length(r.explanation_ua) >= 150 and jsonb_array_length(r.examples) >= 4$q$) = 3
  and pg_temp.n($q$select 1 from public.lesson_grammar lg join public.grammar_topics g on g.id = lg.grammar_topic_id
    where lg.lesson_id = '64ad8ee5-741e-54e5-b31d-88f1130e3f3e' and g.title_ua = 'Можна чи не можна? Smjeti і команди'$q$) = 1,
  'нова тема «Smjeti і команди»: 3 правила по ≥ 4 приклади; урок 38 — з нею');

-- ---------------------------------------------------------------- урок 37
select pg_temp.ok((select status from public.conversations where id = '0e3f3dab-4cd9-5f9c-a4f5-7a1525c83f38') = 'DEPRECATED'
  and (select title_hr from public.conversations where id = 'e9f0f3fa-76e4-53ff-bdf4-cf066b44096c' and status = 'PUBLISHED') = 'Koga ćemo uzeti?'
  and pg_temp.n($q$select 1 from public.conversations where lesson_id = '40b9da1d-1686-5b78-8317-0439067d5f8e' and status = 'PUBLISHED'$q$) = 2
  and pg_temp.n($q$select 1 from public.conversation_turns where conversation_id = 'e9f0f3fa-76e4-53ff-bdf4-cf066b44096c'$q$) = 6,
  'урок 37: «Kod veterinara» → «Koga ćemo uzeti?» (6 реплік), старий діалог — DEPRECATED');
select pg_temp.ok((select status from public.exercises where id = 'fcca6bae-5d7c-5a25-82ad-f868a53dc5f4') = 'DEPRECATED'
  and exists (select 1 from public.lesson_items where lesson_id = '40b9da1d-1686-5b78-8317-0439067d5f8e' and item_type = 'exercise'
              and item_id = '90f9e5d0-4dac-5570-b8ab-b6eb4ce35937' and order_index = 37)
  and (select correct_answer from public.exercises where id = '90f9e5d0-4dac-5570-b8ab-b6eb4ce35937') = 'Onda kornjača ili ribica!'
  and pg_temp.n($q$select 1 from backup.lesson_items_a0pets_20261117 where item_id = 'fcca6bae-5d7c-5a25-82ad-f868a53dc5f4'$q$) = 1,
  'урок 37: «Прослухайте» — з нового діалогу на тому самому місці, стара вправа — DEPRECATED, крок — у backup');

-- ---------------------------------------------------------------- тексти для читання
select pg_temp.ok(pg_temp.n($q$select 1 from public.reading_texts where cefr = 'A0' and module_order = 6$q$) = 2
  and pg_temp.n($q$select 1 from public.reading_texts where cefr = 'A0' and module_order = 6 and code in ('RD-A0-021', 'RD-A0-022')$q$) = 2
  and (select module_order from public.reading_texts where code = 'RD-A0-011') = 7
  and (select module_order from public.reading_texts where code = 'RD-A0-010') = 5
  and pg_temp.n($q$select 1 from backup.reading_texts_a0_20261117$q$) >= 20,
  'тексти A0 — за своїм модулем (Moj dom — 7, Obitelj — 5; в A0.6 — 2 нові тексти PR 2б, 2026-11-17); старі номери — у backup');

-- ---------------------------------------------------------------- перевірки модулів
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments a join public.modules m on m.id = a.module_id
  where a.cefr = 'A0' and a.kind = 'module' and a.status = 'PUBLISHED'
    and a.slug = 'a0-m' || lpad(m.order_index::text, 2, '0') and a.title_ua = 'Перевірка модуля A0.' || m.order_index$q$) = 11
  and (select slug from public.assessments where id = '42a4bbc9-186a-586d-ab42-fa6916e79e67') = 'a0-m07'
  and (select module_id from public.assessments where slug = 'a0-m06') = 'fd6730dd-07aa-590d-b7db-c639e3ed3919',
  '11 тестів модулів A0: адреса й назва = номер модуля; старий a0-m06 (Moj dom) — тепер a0-m07');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug = 'a0-m05' and i.status = 'PUBLISHED'$q$) = 12
  and pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug = 'a0-m06' and i.status = 'PUBLISHED'$q$) = 14,
  'a0-m05 — 12 завдань (6 уроків), a0-m06 — 14 (7 уроків)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  join public.lessons l on l.id = i.lesson_id join public.units u on u.id = l.unit_id
  where a.slug in ('a0-m05', 'a0-m06') and i.status = 'PUBLISHED' and u.module_id <> a.module_id$q$) = 0
  and pg_temp.n($q$select distinct i.lesson_id from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug = 'a0-m06' and i.status = 'PUBLISHED' and i.lesson_id is not null$q$) >= 6,
  'завдання a0-m05 / a0-m06 — з уроків свого модуля; a0-m06 охоплює щонайменше 6 уроків з 7');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug = 'a0-m05' and i.status = 'DEPRECATED'$q$) >= 14
  and exists (select 1 from public.content_versions where entity_type = 'assessment'
              and entity_id = '792592a4-b105-53d8-a093-32f4e9ebac4a' and change_reason like 'a0_pets:%'),
  'старі завдання a0-m05 — DEPRECATED і в content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  join public.lessons l on l.id = i.lesson_id join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where a.slug = 'a0-mid' and i.status = 'PUBLISHED' and m.order_index > 5$q$) = 0
  and pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug in ('a0-mid', 'a0-final') and i.status = 'PUBLISHED'$q$) = 78,
  'середина (30) і фінал (48) не змінились; середина — лише з модулів A0.1–A0.5');

-- ---------------------------------------------------------------- гість бачить нове
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in (select lid from pg_temp.pets())$q$) = 6
  and pg_temp.n($q$select 1 from public.modules where id = 'fd6730dd-07aa-590d-b7db-c639e3ed3919'$q$) = 1
  and pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id where a.slug = 'a0-m06'$q$) = 14,
  'гість бачить новий модуль, 6 уроків і тест a0-m06');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
