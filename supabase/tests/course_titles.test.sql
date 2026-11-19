-- =====================================================================
-- Тест пакета 20261117_course_titles.sql: нові назви 7 уроків і 2 модулів (план «Дублі й сенс уроків», П1).
-- Запускати ПІСЛЯ пакета. БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
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

select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where status = 'PUBLISHED' and (id, title_ua, title_hr) in (
  ('e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9'::uuid, 'Урок 48: Побутова техніка й поломки', 'Lekcija 48: Kućanski aparati i kvarovi'),
  ('b01e2f67-3e7a-5ab6-99bb-fae374f431e0'::uuid, 'Урок 58: Одяг: що купити?', 'Lekcija 58: Odjeća: što kupiti?'),
  ('d9ef1de4-f4db-590e-bafd-474f84c8e03f'::uuid, 'Урок 94: Дубровник і Спліт: історія й архітектура', 'Lekcija 94: Dubrovnik i Split: povijest i arhitektura'),  -- номер з 20261117_a1_dupes_1_lessons.sql (було 93)
  ('24894494-1af7-5153-a7b0-7f0ef3c0bdce'::uuid, 'Урок 13: Перекваліфікація: нова професія', 'Lekcija 13: Prekvalifikacija: novo zanimanje'),
  ('f029711f-710e-5327-be4d-2310435e6eac'::uuid, 'Урок 27: Аргументи й компроміс', 'Lekcija 27: Argumenti i kompromis'),
  ('bf43b6bd-d547-596b-8981-55a4043cf238'::uuid, 'Урок 38: Майстер удома: кошторис і гарантія', 'Lekcija 38: Majstor u kući: predračun i jamstvo'),
  ('5e298915-e179-5d58-bca0-6531c7b43a46'::uuid, 'Урок 73: Тимчасовий захист: статус і документи', 'Lekcija 73: Privremena zaštita: status i dokumenti'))$q$) = 7,  -- номер з 20261119_a2_dupes_1_lessons.sql (було 72)
  '7 уроків — нові назви українською й хорватською');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l
  where l.id in ('e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9', 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0', 'd9ef1de4-f4db-590e-bafd-474f84c8e03f',
                 '24894494-1af7-5153-a7b0-7f0ef3c0bdce', 'f029711f-710e-5327-be4d-2310435e6eac', 'bf43b6bd-d547-596b-8981-55a4043cf238',
                 '5e298915-e179-5d58-bca0-6531c7b43a46')
    and substring(l.title_ua from 'Урок (\d+):') = substring(l.title_hr from 'Lekcija (\d+):')$q$) = 7,
  'номери уроків не змінились і однакові в обох мовах');
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_versions v join public.lessons l on l.id = v.entity_id
  where v.entity_type = 'lesson' and v.change_reason like 'course_titles 2026-11-17%' and v.payload->>'title_ua' <> l.title_ua$q$) = 7
  and pg_temp.n($q$select 1 from public.content_reviews where entity_type = 'lesson' and notes like 'course_titles 2026-11-17%'$q$) = 7,
  'старі назви уроків — у content_versions (7), записи в content_reviews (7)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.modules where status = 'PUBLISHED' and (id, title_ua, title_hr) in (
  ('5a6eadc1-9da1-52c0-a50d-943a3fbffe70'::uuid, 'Модуль A1.12 — Сім’я й установи: школа, банк, документи', 'Modul A1.12 — Obitelj i ustanove: škola, banka, dokumenti'),
  ('a198575a-bafc-51b5-b325-95aa7d6c9d8a'::uuid, 'Модуль A2.9 — Місто й довкілля: неприємності, сміття, природа', 'Modul A2.9 — Grad i okoliš: nevolje, otpad, priroda'))$q$) = 2,
  'модулі A1.12 і A2.9 — нові назви');
select pg_temp.ok(pg_temp.n($q$select 1 from backup.modules_20261117 where (id, title_ua) in (
  ('5a6eadc1-9da1-52c0-a50d-943a3fbffe70'::uuid, 'Модуль A1.12 — Діти, навчання й документи'),
  ('a198575a-bafc-51b5-b325-95aa7d6c9d8a'::uuid, 'Модуль A2.9 — Неприємності в місті й довкілля'))$q$) = 2,
  'старі назви модулів — у backup.modules_20261117');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code in ('A0', 'A1', 'A2') and status = 'PUBLISHED'$q$) = 271
  and pg_temp.n($q$select 1 from public.modules where level_code in ('A0', 'A1', 'A2') and status = 'PUBLISHED'$q$) = 38,
  'кількість уроків (271) і модулів (38) A0–A2 (2026-11-17: + модуль A0.6 і 6 уроків; номери A0 після 37 — +6; + «В аптеці», PR 2б; + 3 уроки A1.11, PR 3; + «Далмація: Задар і околиці», PR 4)');

select 'ALL TESTS PASSED';
rollback;
