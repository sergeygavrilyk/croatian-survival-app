-- =====================================================================
-- Пакет 20261117_course_titles.sql — нові назви 7 уроків і 2 модулів
-- (план «Дублі й сенс уроків A0–A2», docs/proposals/2026-11-16_lesson_duplicates.md, пакет П1;
--  рішення власника 2026-11-17).
--
-- Що робить:
--   * 7 уроків (A0 42, A0 52, A1 93, A2 13, A2 27, A2 38, A2 72): нові title_ua / title_hr,
--     номер уроку не змінюється; стара версія — content_versions, запис — content_reviews;
--   * 2 модулі (A1.12, A2.9): нові назви; модулів немає в content_versions (CHECK entity_type),
--     тому старі назви — копія в backup.modules_20261117.
-- Повторний запуск нічого не змінює (оновлюється лише рядок зі старою назвою).
-- Тест: supabase/tests/course_titles.test.sql → «ALL TESTS PASSED».
-- =====================================================================
do $titles$
declare
  r record;
  n_lessons int := 0;
  n_modules int := 0;
  c_note constant text := 'course_titles 2026-11-17: нова назва за планом «Дублі й сенс уроків» (П1), рішення власника 2026-11-17';
begin
  -- ---------------------------------------------------------------- уроки
  for r in select * from jsonb_to_recordset($j$[
    {"id": "e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9", "old_ua": "Урок 42: Техніка й комунальні послуги",
     "ua": "Урок 42: Побутова техніка й поломки", "hr": "Lekcija 42: Kućanski aparati i kvarovi"},
    {"id": "b01e2f67-3e7a-5ab6-99bb-fae374f431e0", "old_ua": "Урок 52: Скільки коштує ця футболка?",
     "ua": "Урок 52: Одяг: що купити?", "hr": "Lekcija 52: Odjeća: što kupiti?"},
    {"id": "d9ef1de4-f4db-590e-bafd-474f84c8e03f", "old_ua": "Урок 93: Старе місто: екскурсія",
     "ua": "Урок 93: Дубровник і Спліт: історія й архітектура", "hr": "Lekcija 93: Dubrovnik i Split: povijest i arhitektura"},
    {"id": "24894494-1af7-5153-a7b0-7f0ef3c0bdce", "old_ua": "Урок 13: Перекваліфікація й курси для дорослих",
     "ua": "Урок 13: Перекваліфікація: нова професія", "hr": "Lekcija 13: Prekvalifikacija: novo zanimanje"},
    {"id": "f029711f-710e-5327-be4d-2310435e6eac", "old_ua": "Урок 27: Згоден чи ні? Моя думка",
     "ua": "Урок 27: Аргументи й компроміс", "hr": "Lekcija 27: Argumenti i kompromis"},
    {"id": "bf43b6bd-d547-596b-8981-55a4043cf238", "old_ua": "Урок 38: Майстер удома",
     "ua": "Урок 38: Майстер удома: кошторис і гарантія", "hr": "Lekcija 38: Majstor u kući: predračun i jamstvo"},
    {"id": "5e298915-e179-5d58-bca0-6531c7b43a46", "old_ua": "Урок 72: Статус і документи: продовжуємо перебування",
     "ua": "Урок 72: Тимчасовий захист: статус і документи", "hr": "Lekcija 72: Privremena zaštita: status i dokumenti"}
  ]$j$::jsonb) as x(id uuid, old_ua text, ua text, hr text)
  loop
    if not exists (select 1 from public.lessons where id = r.id) then
      raise exception 'Немає уроку % (%)', r.id, r.old_ua;
    end if;
    continue when exists (select 1 from public.lessons where id = r.id and title_ua = r.ua and title_hr = r.hr);
    if not exists (select 1 from public.lessons where id = r.id and title_ua = r.old_ua) then
      raise exception 'Урок % має неочікувану назву (очікувано «%»)', r.id, r.old_ua;
    end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    select 'lesson', l.id,
           coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = l.id), 0) + 1,
           to_jsonb(l), c_note || ' — стара версія'
    from public.lessons l where l.id = r.id;
    update public.lessons set title_ua = r.ua, title_hr = r.hr, updated_at = now() where id = r.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('lesson', r.id, 'PUBLISHED', 'PUBLISHED', 'approved', 'ai',
            jsonb_build_array(jsonb_build_object('old_title_ua', r.old_ua, 'new_title_ua', r.ua, 'new_title_hr', r.hr)), c_note);
    n_lessons := n_lessons + 1;
  end loop;

  -- ---------------------------------------------------------------- модулі
  create table if not exists backup.modules_20261117 as table public.modules with no data;
  for r in select * from jsonb_to_recordset($j$[
    {"id": "5a6eadc1-9da1-52c0-a50d-943a3fbffe70", "old_ua": "Модуль A1.12 — Діти, навчання й документи",
     "ua": "Модуль A1.12 — Сім’я й установи: школа, банк, документи", "hr": "Modul A1.12 — Obitelj i ustanove: škola, banka, dokumenti"},
    {"id": "a198575a-bafc-51b5-b325-95aa7d6c9d8a", "old_ua": "Модуль A2.9 — Неприємності в місті й довкілля",
     "ua": "Модуль A2.9 — Місто й довкілля: неприємності, сміття, природа", "hr": "Modul A2.9 — Grad i okoliš: nevolje, otpad, priroda"}
  ]$j$::jsonb) as x(id uuid, old_ua text, ua text, hr text)
  loop
    if not exists (select 1 from public.modules where id = r.id) then
      raise exception 'Немає модуля % (%)', r.id, r.old_ua;
    end if;
    continue when exists (select 1 from public.modules where id = r.id and title_ua = r.ua and title_hr = r.hr);
    if not exists (select 1 from public.modules where id = r.id and title_ua = r.old_ua) then
      raise exception 'Модуль % має неочікувану назву (очікувано «%»)', r.id, r.old_ua;
    end if;
    insert into backup.modules_20261117 select * from public.modules where id = r.id
      and not exists (select 1 from backup.modules_20261117 b where b.id = r.id);
    update public.modules set title_ua = r.ua, title_hr = r.hr where id = r.id;
    n_modules := n_modules + 1;
  end loop;

  raise notice 'course_titles: оновлено уроків — %, модулів — %', n_lessons, n_modules;
end $titles$;

-- ---------------------------------------------------------------- самоперевірка
do $check$
declare n int;
begin
  select count(*) into n from public.lessons where (id, title_ua) in (
    ('e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9'::uuid, 'Урок 42: Побутова техніка й поломки'),
    ('b01e2f67-3e7a-5ab6-99bb-fae374f431e0'::uuid, 'Урок 52: Одяг: що купити?'),
    ('d9ef1de4-f4db-590e-bafd-474f84c8e03f'::uuid, 'Урок 93: Дубровник і Спліт: історія й архітектура'),
    ('24894494-1af7-5153-a7b0-7f0ef3c0bdce'::uuid, 'Урок 13: Перекваліфікація: нова професія'),
    ('f029711f-710e-5327-be4d-2310435e6eac'::uuid, 'Урок 27: Аргументи й компроміс'),
    ('bf43b6bd-d547-596b-8981-55a4043cf238'::uuid, 'Урок 38: Майстер удома: кошторис і гарантія'),
    ('5e298915-e179-5d58-bca0-6531c7b43a46'::uuid, 'Урок 72: Тимчасовий захист: статус і документи'));
  if n <> 7 then raise exception 'Очікувано 7 нових назв уроків, є %', n; end if;
  select count(*) into n from public.modules where (id, title_ua) in (
    ('5a6eadc1-9da1-52c0-a50d-943a3fbffe70'::uuid, 'Модуль A1.12 — Сім’я й установи: школа, банк, документи'),
    ('a198575a-bafc-51b5-b325-95aa7d6c9d8a'::uuid, 'Модуль A2.9 — Місто й довкілля: неприємності, сміття, природа'));
  if n <> 2 then raise exception 'Очікувано 2 нові назви модулів, є %', n; end if;
  select count(*) into n from backup.modules_20261117;
  if n <> 2 then raise exception 'Очікувано 2 старі назви модулів у backup.modules_20261117, є %', n; end if;
  select count(*) into n from public.content_versions
    where entity_type = 'lesson' and change_reason like 'course_titles 2026-11-17%';
  if n <> 7 then raise exception 'Очікувано 7 старих версій уроків у content_versions, є %', n; end if;
  raise notice 'Готово: 20261117_course_titles.sql — 7 уроків і 2 модулі з новими назвами';
end $check$;
