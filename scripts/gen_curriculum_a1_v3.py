#!/usr/bin/env python3
"""
Генератор SQL для програми A1 v3 (уроки за темою; програма погоджена власником 2026-10-26):
content/reviews/2026-10-21_curriculum_a1_v3_program.md.

  python3 -B scripts/gen_curriculum_a1_v3.py structure    →  supabase/data_fixes/20261026_curriculum_a1_v3_structure.sql
                                                             (13 модулів, усі 89 теперішніх уроків — на нові місця; запускати першим)
  python3 -B scripts/gen_curriculum_a1_v3.py 1            →  SQL модуля A1.1 (і далі — номер модуля)
  python3 -B scripts/gen_curriculum_a1_v3.py --review 1   →  звіт для перевірки модуля носієм (слова, діалоги, вправи)

Дані: scripts/curriculum_a1_v3_data.py; знімок робочої бази — scripts/curriculum_a1_v3_snapshot.json
(id теперішніх уроків A1, слова уроків A0, наявні слова з перекладом).

Правила (власник 2026-10-21): до 25 слів на урок — скільки потрібно темі; 90–95 % слів — нові для рівня (зі слів уроків A0 —
не більше 2 на урок); слово не повторюється в уроках A1 v3; 2 діалоги, 15 вправ, 15 хв; бета (PUBLISHED).

Структура (structure): id модуля лишається з його темою — «Здоров’я» (старий A1.7) стає A1.8, «Соціальне життя» (A1.8) — A1.9,
«Хорватія» (A1.9) — A1.10, «Підсумок» (A1.10) — A1.13; нові модулі A1.7, A1.11, A1.12. Уроки переносяться на свої місця;
місця нових уроків лишаються вільними до SQL їхнього модуля. Нічого не видаляє; стара версія уроків — у content_versions, модулів і юнітів — у backup.

Модуль (1…13): як curriculum_a0_v4 — стара версія уроку в content_versions і backup.lesson_items_20261015; старі вправи й діалоги
→ DEPRECATED; нові слова, теми й правила граматики; нові уроки; наскрізні номери «Урок N»; самоперевірка. Повторний запуск безпечний.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
import curriculum_a1_v3_data as D  # noqa: E402
from full_lessons import HELPERS_SQL, Course, Place, q, qj, uid  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
HERE = Path(__file__).parent
FIXES = ROOT / 'supabase' / 'data_fixes'
SNAPSHOT = json.loads((HERE / 'curriculum_a1_v3_snapshot.json').read_text(encoding='utf-8'))
LEVEL = 'A1'
MINUTES = 15
STATUS = 'PUBLISHED'  # бета, як A0 / A1
SOURCE = 'claude_curriculum_a1_v3'
BACKUP = 'backup.lesson_items_20261015'
WORDS_RANGE = (10, 25)
A0_MAX = 2  # слів з уроків A0 в уроці A1 — не більше (90–95 % нових)
SITUATIONS = set(re.findall(r"code: '([a-z_]+)'", (ROOT / 'lib' / 'situations.ts').read_text(encoding='utf-8')))
STRUCTURE_OUT = FIXES / '20261026_curriculum_a1_v3_structure.sql'

# Теми граматики A1, що вже є в базі (назва title_ua)
A1_GRAMMAR = {'Наказовий спосіб', 'Ступені порівняння', 'Побудова питань', 'Заперечення', 'Сполучники', 'Теперішній час',
              'Правильні дієслова', 'Часті неправильні дієслова', 'Знахідний відмінок', 'Місцевий відмінок', 'Родовий відмінок: основи',
              'Присвійні займенники', 'Модальні дієслова'}

MODULES = {
    1: dict(lessons=D.LESSONS_M01, new_lexemes=D.NEW_LEXEMES_M01, no_vocab=D.NO_VOCAB_M01, new_grammar=D.NEW_GRAMMAR_M01,
            extra_rules=D.EXTRA_RULES_M01, fix_lemmas=[('Uglavnom', 'uglavnom')],
            fix_translations=[('čuvati', 'берегти', 'берегти; доглядати, наглядати (за дитиною)'),
                              ('ponovno', 'знову', 'знову, ще раз')],
            date='2026-10-26'),
    2: dict(lessons=D.LESSONS_M02, new_lexemes=D.NEW_LEXEMES_M02, no_vocab=D.NO_VOCAB_M02, new_grammar=D.NEW_GRAMMAR_M02,
            extra_rules=D.EXTRA_RULES_M02, fix_translations=[('kava za van', 'Кава з собою.', 'кава з собою')],
            date='2026-10-26'),
    3: dict(lessons=D.LESSONS_M03, new_lexemes=D.NEW_LEXEMES_M03, no_vocab=D.NO_VOCAB_M03, new_grammar=D.NEW_GRAMMAR_M03,
            extra_rules=D.EXTRA_RULES_M03,
            fix_translations=[('svidjeti se', 'подобатися', 'сподобатися'),
                              ('stajati', 'коштувати, стояти', 'стояти; коштувати; личити (stoji ti dobro)'),
                              ('odgovarati', 'відповідати', 'відповідати; підходити (за розміром, часом)'),
                              ('isti', 'однаковий', 'той самий; однаковий')],
            date='2026-10-26'),
    4: dict(lessons=D.LESSONS_M04, new_lexemes=D.NEW_LEXEMES_M04, no_vocab=D.NO_VOCAB_M04, new_grammar=D.NEW_GRAMMAR_M04,
            extra_rules=D.EXTRA_RULES_M04,
            fix_translations=[('kuda', 'куди', 'куди, якою дорогою'),
                              ('pumpa', 'заправка', 'заправка (АЗС); насос'),
                              ('zastoj', 'блокер (перешкода)', 'затримка, зупинка; перешкода (блокер у роботі)')],
            date='2026-10-26'),
    5: dict(lessons=D.LESSONS_M05, new_lexemes=D.NEW_LEXEMES_M05, no_vocab=D.NO_VOCAB_M05, new_grammar=D.NEW_GRAMMAR_M05,
            extra_rules=D.EXTRA_RULES_M05,
            fix_translations=[('blizina', 'близькість; околиці', 'близькість (u blizini — поруч)'),
                              ('peć', 'піч; обігрівач', 'піч')],
            date='2026-10-26'),
    6: dict(lessons=D.LESSONS_M06, new_lexemes=D.NEW_LEXEMES_M06, no_vocab=D.NO_VOCAB_M06, new_grammar=D.NEW_GRAMMAR_M06,
            extra_rules=D.EXTRA_RULES_M06,
            fix_translations=[('dnevni sastanak', 'дейлі (стендап)', 'щоденна нарада; дейлі (стендап)'),
                              ('natječaj', 'конкурс / вакансія', 'конкурс (на посаду), вакансія')],
            date='2026-10-26'),
    7: dict(lessons=D.LESSONS_M07, new_lexemes=D.NEW_LEXEMES_M07, no_vocab=D.NO_VOCAB_M07, new_grammar=D.NEW_GRAMMAR_M07,
            extra_rules=D.EXTRA_RULES_M07,
            fix_translations=[('bon', 'передплата (поповнення рахунку)', 'ваучер поповнення (мобільного рахунку)'),
                              ('odjaviti se', 'виписатися', 'виписатися; вийти (з акаунта)'),
                              ('kliknuti', 'натиснути; клікнути', 'клікнути, клацнути (мишкою)')],
            date='2026-10-26'),
    8: dict(lessons=D.LESSONS_M08, new_lexemes=D.NEW_LEXEMES_M08, no_vocab=D.NO_VOCAB_M08, new_grammar=D.NEW_GRAMMAR_M08,
            extra_rules=D.EXTRA_RULES_M08,
            fix_translations=[('cjepivo', 'вакцина / щеплення', 'вакцина'),
                              ('težina', 'вага, складність', 'вага (тіла); складність'),
                              ('hitan', 'терміновий', 'терміновий, невідкладний')],
            date='2026-10-26'),
    9: dict(lessons=D.LESSONS_M09, new_lexemes=D.NEW_LEXEMES_M09, no_vocab=D.NO_VOCAB_M09, new_grammar=D.NEW_GRAMMAR_M09,
            extra_rules=D.EXTRA_RULES_M09,
            fix_translations=[('veza', 'зв\'язок', 'зв’язок; стосунки (бути у стосунках — biti u vezi)'),
                              ('prekinuti', 'перервати, зупинити', 'перервати, зупинити; розійтися (prekinuti s nekim)'),
                              ('slikati', 'фотографувати / малювати', 'малювати (фарбами); фотографувати'),
                              ('ponosan', 'гордий', 'гордий; який пишається')],
            date='2026-10-26'),
    10: dict(lessons=D.LESSONS_M10, new_lexemes=D.NEW_LEXEMES_M10, no_vocab=D.NO_VOCAB_M10, new_grammar=D.NEW_GRAMMAR_M10,
             extra_rules=D.EXTRA_RULES_M10,
             fix_translations=[('obala', 'берег / узбережжя', 'берег; узбережжя'),
                               ('odmor', 'відпочинок / відпустка', 'відпочинок; відпустка'),
                               ('brod', 'корабель', 'корабель; човен, катер')],
             date='2026-10-26'),
    11: dict(lessons=D.LESSONS_M11, new_lexemes=D.NEW_LEXEMES_M11, no_vocab=D.NO_VOCAB_M11, new_grammar=D.NEW_GRAMMAR_M11,
             extra_rules=D.EXTRA_RULES_M11,
             fix_translations=[('specijalitet', 'фірмова страва; специалітет', 'фірмова страва; місцевий делікатес'),
                               ('obnoviti', 'відновити, реконструювати', 'відновити, відреставрувати')],
             date='2026-10-26'),
    12: dict(lessons=D.LESSONS_M12, new_lexemes=D.NEW_LEXEMES_M12, no_vocab=D.NO_VOCAB_M12, new_grammar=D.NEW_GRAMMAR_M12,
             extra_rules=D.EXTRA_RULES_M12,
             fix_translations=[('ispit', 'іспит / екзамен', 'іспит, екзамен'),
                               ('uplata', 'платіж / внесення', 'платіж; надходження (на рахунок)'),
                               ('isplata', 'виплата / зняття', 'виплата; зняття (готівки)'),
                               ('uvjerenje', 'свідоцтво / довідка', 'свідоцтво (про закінчення курсу); довідка'),
                               ('dozvola', 'дозвіл / ліцензія', 'дозвіл; посвідка'),
                               ('obavijest', 'повідомлення', 'повідомлення (зокрема — поштове про відправлення)'),
                               ('sklonište', 'сховище / укриття', 'сховище, укриття')],
             date='2026-10-26'),
    13: dict(lessons=D.LESSONS_M13, new_lexemes=D.NEW_LEXEMES_M13, no_vocab=D.NO_VOCAB_M13, new_grammar=D.NEW_GRAMMAR_M13,
             extra_rules=D.EXTRA_RULES_M13,
             fix_translations=[('otvoren', 'відчинений / відкритий', 'відчинений; відкритий (про людину)'),
                               ('uspjeti', 'змогти / досягти успіху / вдатися', 'вдатися, досягти успіху; встигнути'),
                               ('napredovati', 'просуватися', 'просуватися (у навчанні, по службі), прогресувати'),
                               ('postati', 'стати (кимсь / чимось)', 'стати (кимось, чимось)')],
             date='2026-10-26'),
}

# ----------------------------------------------------------------------------- програма
PLACE: dict = {}       # (модуль, місце) → номер уроку на рівні (1…108)
WHERE_OLD: dict = {}   # номер теперішнього уроку → (модуль, місце)
WHERE_SLUG: dict = {}  # slug нового уроку → (модуль, місце)
_n = 0
for _m in sorted(D.PROGRAM):
    for _o, _x in enumerate(D.PROGRAM[_m]['lessons'], 1):
        _n += 1
        PLACE[(_m, _o)] = _n
        (WHERE_OLD if isinstance(_x, int) else WHERE_SLUG)[_x] = (_m, _o)
TOTAL = _n


def module_id(m: int) -> str:
    old = D.PROGRAM[m]['old_module']
    return uid('module', LEVEL, old) if old else uid('module_v3', LEVEL, m)


def unit_id(m: int) -> str:
    old = D.PROGRAM[m]['old_module']
    return uid('unit', LEVEL, old, 1) if old else uid('unit_v3', LEVEL, m, 1)


def old_lesson_id(n: int) -> str:
    return SNAPSHOT['lessons'][str(n)]['id']


def lesson_id(m: int, o: int) -> str:
    L = MODULES[m]['lessons'][(m, o)]
    return old_lesson_id(L['old']) if 'old' in L else uid('lesson_v3', LEVEL, m, L['slug'])


def module_title(m: int) -> tuple[str, str]:
    ua, hr = D.PROGRAM[m]['title']
    return f'Модуль A1.{m} — {ua}', f'Modul A1.{m} — {hr}'


# ----------------------------------------------------------------------------- спільний SQL
RENUMBER_SQL = f"""-- Наскрізні номери всіх уроків A1 («Урок N: …» / «Lekcija N: …»); стара назва — у content_versions
do $$
declare r record; v_payload jsonb; v_new_ua text; v_new_hr text;
begin
  for r in select l.id, l.title_ua, l.title_hr,
                  row_number() over (order by m.order_index, u.order_index, l.order_index) as n
             from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
            where m.level_code = {q(LEVEL)} and l.status = 'PUBLISHED' loop
    v_new_ua := regexp_replace(r.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':');
    v_new_hr := regexp_replace(r.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':');
    if v_new_ua is not distinct from r.title_ua and v_new_hr is not distinct from r.title_hr then continue; end if;
    select to_jsonb(l) into v_payload from public.lessons l where l.id = r.id;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'curriculum_a1_v3: новий номер уроку ' || r.n);
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;
"""

TITLES_CHECK = f"""  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = {q(LEVEL)} and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';"""


def version_sql(entity: str, table: str, ident: str, reason: str) -> str:
    return (f"  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)\n"
            f"  select {q(entity)}, x.id, coalesce((select max(version) from public.content_versions where entity_type = {q(entity)} and entity_id = x.id), 0) + 1,\n"
            f"         to_jsonb(x), {q(reason)} from public.{table} x where x.id = {q(ident)};")


# ----------------------------------------------------------------------------- структура (13 модулів)
def structure_sql() -> str:
    reason = 'curriculum_a1_v3: нова програма A1 (13 модулів) — стара версія'
    guard = uid('module_v3', LEVEL, 7)
    s = [f"""-- =====================================================================
-- Програма A1 v3 · структура: 13 модулів, теперішні 89 уроків — на нові місця · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_curriculum_a1_v3.py structure (не редагуйте вручну).
--
-- Програма погоджена власником 2026-10-26 (content/reviews/2026-10-21_curriculum_a1_v3_program.md).
--   * Модулі A1.1–A1.6 — ті самі (нові назви й описи); «Здоров’я» → A1.8, «Соціальне життя» → A1.9 «Люди й вільний час»,
--     «Хорватія» → A1.10 «Подорожуємо Хорватією», «Підсумок» → A1.13; нові модулі A1.7 «Комп’ютер, телефон та інтернет»,
--     A1.11 «Хорватська культура», A1.12 «Діти, навчання й документи». id модуля лишається з темою; перевірки модулів
--     (a1-m07 → a1-m08, a1-m08 → a1-m09, a1-m09 → a1-m10, a1-m10 → a1-m13) і тексти для читання — теж за своїм модулем.
--   * Уроки переносяться на свої місця в програмі (уроки 23, 26, 71 → A1.7; 25 → A1.5; 74, 76, 77, 79, 80 → A1.11;
--     82, 84–88 → A1.12); місця 19 нових уроків лишаються вільними до SQL їхнього модуля. Назви уроків поки старі,
--     номери «Урок N» — підряд.
--   * Нічого не видаляє; стара версія уроків — у content_versions, модулів і юнітів — у backup.modules_a1_20261026 /
--     backup.units_a1_20261026. Повторний запуск нічого не змінює.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- Далі: 20261026_curriculum_a1_v3_m01.sql (модуль A1.1).
-- =====================================================================

begin;

create schema if not exists backup;
create table if not exists backup.modules_a1_20261026 (like public.modules including defaults);
create table if not exists backup.units_a1_20261026 (like public.units including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'modules_a1_20261026_pkey') then
    alter table backup.modules_a1_20261026 add constraint modules_a1_20261026_pkey primary key (id);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'units_a1_20261026_pkey') then
    alter table backup.units_a1_20261026 add constraint units_a1_20261026_pkey primary key (id);
  end if;
end $$;
revoke all on backup.modules_a1_20261026, backup.units_a1_20261026 from anon, authenticated;

do $$
begin
  if exists (select 1 from public.modules where id = {q(guard)}) then
    raise notice 'Структуру A1 v3 уже застосовано — пропускаю';
    return;
  end if;
  if (select count(*) from public.lessons where level_code = {q(LEVEL)} and status = 'PUBLISHED') <> 89 then
    raise exception 'Очікувалось 89 уроків A1 (теперішня програма) — спершу звірте базу';
  end if;
  -- 1. стара версія: модулі й юніти A1 — копія в backup (content_versions їх не приймає), уроки — у content_versions
  insert into backup.modules_a1_20261026 select x.* from public.modules x where x.level_code = {q(LEVEL)} on conflict (id) do nothing;
  insert into backup.units_a1_20261026 select x.* from public.units x join public.modules m on m.id = x.module_id
   where m.level_code = {q(LEVEL)} on conflict (id) do nothing;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'lesson', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = x.id), 0) + 1,
         to_jsonb(x), {q(reason)} from public.lessons x where x.level_code = {q(LEVEL)};
  -- 2. модулі: тимчасово +100 (unique (level_code, order_index)), потім — нові місця, назви, описи
  update public.modules set order_index = order_index + 100 where level_code = {q(LEVEL)} and order_index < 100;"""]
    for m in sorted(D.PROGRAM):
        t_ua, t_hr = module_title(m)
        desc, objectives = D.PROGRAM_DESC[m]
        u_ua, u_hr = D.PROGRAM[m]['title']
        if D.PROGRAM[m]['old_module']:
            s.append(f"  update public.modules set order_index = {m}, title_ua = {q(t_ua)}, title_hr = {q(t_hr)}, description = {q(desc)}, status = 'PUBLISHED'\n"
                     f"   where id = {q(module_id(m))};")
            s.append(f"  update public.units set title_ua = {q(u_ua)}, title_hr = {q(u_hr)}, objectives = {qj(objectives)} where id = {q(unit_id(m))};")
        else:
            s.append("  insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)\n"
                     f"  values ({q(module_id(m))}, {q(LEVEL)}, {q(t_ua)}, {q(t_hr)}, {q(desc)}, {m}, 'PUBLISHED');")
            s.append("  insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)\n"
                     f"  values ({q(unit_id(m))}, {q(module_id(m))}, {q(u_ua)}, {q(u_hr)}, {qj(objectives)}, 1, 'PUBLISHED');")
    moved = sorted(((D.PROGRAM[m]['old_module'], m) for m in D.PROGRAM if D.PROGRAM[m]['old_module'] and D.PROGRAM[m]['old_module'] != m),
                   reverse=True)
    s.append('  -- 2а. перевірки модулів і тексти для читання йдуть за своїм модулем (новий номер); стара версія — у content_versions')
    for old, m in moved:
        slug_old, slug_new = f'a1-m{old:02d}', f'a1-m{m:02d}'
        s.append(f"""  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = x.id), 0) + 1,
         to_jsonb(x), {q(reason)} from public.assessments x where x.slug = {q(slug_old)} and x.module_id = {q(module_id(m))};
  update public.assessments set slug = {q(slug_new)}, title_ua = {q(f'Перевірка модуля A1.{m}')}, order_index = {m}
   where slug = {q(slug_old)} and module_id = {q(module_id(m))};
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'reading_text', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'reading_text' and entity_id = x.id), 0) + 1,
         to_jsonb(x), {q(reason)} from public.reading_texts x where x.cefr = {q(LEVEL)} and x.module_order = {old};
  update public.reading_texts set module_order = {m} where cefr = {q(LEVEL)} and module_order = {old};""")  # від більшого номера до меншого
    s.append('  -- 3. уроки: тимчасово +1000 (unique (unit_id, order_index)), потім — юніт і місце за програмою')
    s.append(f"  update public.lessons set order_index = order_index + 1000 where level_code = {q(LEVEL)} and order_index < 1000;")
    rows = ',\n      '.join(f"({q(old_lesson_id(n))}::uuid, {q(unit_id(m))}::uuid, {o})" for n, (m, o) in sorted(WHERE_OLD.items()))
    s.append(f"""  update public.lessons l set unit_id = t.unit_id, order_index = t.o
    from (values
      {rows}
    ) as t(id, unit_id, o)
   where l.id = t.id;
end $$;
""")
    s.append(RENUMBER_SQL)
    checks = ', '.join(f"({q(old_lesson_id(n))}::uuid, {m}, {o})" for n, (m, o) in sorted(WHERE_OLD.items()))
    s.append(f"""-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_modules int; v_placed int; v_titles int; v_lessons int;
begin
  select count(*) into v_modules from public.modules where level_code = {q(LEVEL)} and order_index between 1 and {len(D.PROGRAM)} and status = 'PUBLISHED';
  select count(*) into v_placed from (values {checks}) as t(id, m, o)
    join public.lessons l on l.id = t.id and l.order_index = t.o
    join public.units u on u.id = l.unit_id join public.modules md on md.id = u.module_id and md.order_index = t.m;
  select count(*) into v_lessons from public.lessons where level_code = {q(LEVEL)} and status = 'PUBLISHED';
{TITLES_CHECK}
  if v_modules <> {len(D.PROGRAM)} then raise exception 'A1: модулів %, очікувалось {len(D.PROGRAM)}', v_modules; end if;
  if v_placed <> {len(WHERE_OLD)} then raise exception 'A1: на своїх місцях % уроків з {len(WHERE_OLD)}', v_placed; end if;
  if v_titles > 0 then raise exception 'A1: % уроків з неправильним номером у назві', v_titles; end if;
  raise notice 'Готово: програма A1 v3 — {len(D.PROGRAM)} модулів, уроків %', v_lessons;
end $$;

commit;
""")
    return '\n'.join(s)


# ----------------------------------------------------------------------------- модуль
def lex_base(module: int) -> dict:
    lex = {k: (v[0], v[1]) for k, v in SNAPSHOT['a0_pool'].items()}
    lex.update({k: (v[0], v[1]) for k, v in SNAPSHOT['lex'].items()})
    for m in sorted(MODULES):
        if m > module:
            break
        for lemma, new in MODULES[m].get('fix_lemmas', []):
            if lemma.lower() in lex:
                lex[lemma.lower()] = (new, lex[lemma.lower()][1])
        for lemma, _old, new in MODULES[m].get('fix_translations', []):
            if lemma.lower() in lex:
                lex[lemma.lower()] = (lex[lemma.lower()][0], new)
        for lemma, _n, ua, *_ in MODULES[m]['new_lexemes']:
            lex[lemma.lower()] = (lemma, ua)
    return lex


def grammar_titles(module: int) -> set:
    out = set(A1_GRAMMAR)
    for m in MODULES:
        if m <= module:
            out |= {g['title_ua'] for g in MODULES[m].get('new_grammar', {}).values()}
    return out


class CourseA1(Course):
    """Як Course, але спершу добирає слова для «як хорватською» і «напишіть» (їм потрібні однозначні переклади),
    а «що означає» — з решти; якщо однозначних слів замало, замість «як хорватською» / «напишіть» — ще одна «що означає».
    Так урок, де багато близьких за змістом слів (уже / ще / саме; столик на двох / на чотирьох), теж має 15 вправ."""

    def vocab_exercises(self, key) -> list[dict]:
        import random
        from full_lessons import fold_ua, shuffled, typable
        rng = random.Random(f'{self.seed_prefix}:{key}')
        order = list(self.lessons[key]['words'])
        rng.shuffle(order)
        taken: set[str] = set()

        def pick(cond):
            for w in order:
                if w.lower() not in taken and w.lower() not in self.no_vocab and cond(w):
                    taken.add(w.lower())
                    return w
            return None

        n_meaning, n_choose, n_type = self.vocab_counts
        plan = ([('choose_hr', lambda w: not self.ambiguous(w))] * n_choose
                + [('type', lambda w: not self.ambiguous(w) and typable(w))] * n_type
                + [('meaning', lambda w: True)] * n_meaning)
        picked = []
        for kind, cond in plan:
            w = pick(cond)
            if w is None and kind != 'meaning':
                # однозначних слів замало (уроки з близькими за змістом словами) — замість цієї вправи «що означає»
                kind, w = 'meaning', pick(lambda w: True)
            if w is None:
                self.errors.append(f'{self.name(key)}: не вистачає слів для вправи {kind}')
                continue
            picked.append((kind, w))
        rank = {'meaning': 0, 'choose_hr': 1, 'type': 2}
        out: list[dict] = []
        for kind, w in sorted(picked, key=lambda x: rank[x[0]]):
            lemma = self.lemma_of(w)
            if kind == 'meaning':
                ds = self.distractors(key, w, lambda x: fold_ua(self.display_ua(x)), rng)
                answer = self.display_ua(w)
                out.append(dict(type='multiple_choice', word=w, question=f'Що означає «{lemma}»?', answer=answer,
                                options=shuffled([answer, *[self.display_ua(d) for d in ds]], f'{key}:{w}'),
                                skill='vocabulary', n_opts=len(ds) + 1))
            elif kind == 'choose_hr':
                ds = self.distractors(key, w, lambda x: self.lemma_of(x).lower(), rng)
                out.append(dict(type='multiple_choice', word=w, question=f'Як хорватською «{self.display_ua(w)}»?', answer=lemma,
                                options=shuffled([lemma, *[self.lemma_of(d) for d in ds]], f'{key}:{w}'),
                                skill='vocabulary', n_opts=len(ds) + 1))
            else:
                out.append(dict(type='type_answer', word=w, question=f'Напишіть хорватською: «{self.display_ua(w)}»',
                                answer=lemma, options=None, skill='writing'))
        for ex in out:
            if ex.get('n_opts', 4) != 4:
                self.errors.append(f'{self.name(key)}: для «{ex["word"]}» лише {ex["n_opts"]} варіанти')
        return out


def build_course(module: int) -> Course:
    M = MODULES[module]
    places = {k: Place(k[0], k[1], PLACE[k]) for k in M['lessons']}
    pool = [v[0] for v in SNAPSHOT['a0_pool'].values()]
    pool += [w for m in MODULES if m < module for L in MODULES[m]['lessons'].values() for w in L['words']]
    return CourseA1(level=LEVEL, lessons=M['lessons'], place=places, lex=lex_base(module), situations=SITUATIONS,
                  grammar_keys=grammar_titles(module), seed_prefix='a1v3', no_vocab=M['no_vocab'], extra_pool=pool,
                  words_range=WORDS_RANGE, vocab_counts=(3, 2, 3))


def lexemes_sql(module: int) -> list[str]:
    M = MODULES[module]
    out = [f'-- 1. Нові слова й вирази A1.{module} ({len(M["new_lexemes"])}; наявні не змінюються)']
    for lemma, norm, ua, pos, vtype, forms, example in M['new_lexemes']:
        out.append(
            'insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)\n'
            f"values ({q(lemma)}, {q(norm)}, 'hr', {q(pos)}, 'A1', {q(ua)}, {q(vtype)}, {qj(forms)}, {qj([example])}, {q(STATUS)}, {q(SOURCE)})\n"
            'on conflict do nothing;')
    out.append('')
    return out


FIX_NOTE = 'curriculum_a1_v3: виправлено слово (переклад за темою уроку / лема з малої літери) — стара версія'


def fixes_sql(module: int) -> list[str]:
    M = MODULES[module]
    out = []
    for lemma, new in M.get('fix_lemmas', []):
        out.append(f"""do $$
declare r record;
begin
  for r in select * from public.lexemes where lemma = {q(lemma)} loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), {q(FIX_NOTE)});
    update public.lexemes set lemma = {q(new)} where id = r.id;
  end loop;
end $$;""")
    for lemma, old, new in M.get('fix_translations', []):
        out.append(f"""do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = {q(lemma.lower())} and ukrainian_translation = {q(old)} loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), {q(FIX_NOTE)});
    update public.lexemes set ukrainian_translation = {q(new)} where id = r.id;
  end loop;
end $$;""")
    if out:
        out.insert(0, f'-- 1б. Виправлені слова ({len(M.get("fix_lemmas", [])) + len(M.get("fix_translations", []))}); повторний запуск нічого не змінює')
        out.append('')
    return out


GRAMMAR_NOTE = 'Бета: нова тема граматики A1 для програми A1 v3 (рішення власника 2026-10-21 / 2026-10-26). Потрібна перевірка носієм.'
RULE_NOTE = 'Бета: нове правило до теми граматики A1 (програма A1 v3). Потрібна перевірка носієм.'


def grammar_sql(module: int) -> list[str]:
    M = MODULES[module]
    G, X = M.get('new_grammar', {}), M.get('extra_rules', {})
    if not G and not X:
        return []
    out = [f'-- 1а. Граматика A1.{module}: нові теми ({len(G)}) і нові правила до наявних тем ({sum(len(v) for v in X.values())})']
    for key, g in G.items():
        gid = uid('grammar_v3', LEVEL, key)
        out.append(
            'insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)\n'
            f"select {q(gid)}, {q(LEVEL)}, {q(g['title_ua'])}, {q(g['title_hr'])}, {q(g['description'])}, {q(STATUS)}\n"
            f"where not exists (select 1 from public.grammar_topics where cefr = {q(LEVEL)} and title_ua = {q(g['title_ua'])});")
        for i, (title, expl, pattern, examples) in enumerate(g['rules'], 1):
            ex = [{'hr': hr, 'ua': ua} for hr, ua in examples]
            out.append(
                'insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)\n'
                f"select {q(uid('grammar_rule_v3', LEVEL, key, i))}, {q(gid)}, {q(title)}, {q(expl)}, {q(pattern)}, {qj(ex)}, {i}\n"
                f'where exists (select 1 from public.grammar_topics where id = {q(gid)})\n'
                'on conflict (id) do nothing;')
        out.append(
            'insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)\n'
            f"select 'grammar_topic', {q(gid)}, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(GRAMMAR_NOTE)}\n"
            f'where exists (select 1 from public.grammar_topics where id = {q(gid)})\n'
            f'  and not exists (select 1 from public.content_reviews where entity_id = {q(gid)} and notes = {q(GRAMMAR_NOTE)});')
    for topic, rules in X.items():
        for i, (title, expl, pattern, examples) in enumerate(rules, 1):
            rid = uid('grammar_rule_v3', LEVEL, module, topic, i)
            ex = [{'hr': hr, 'ua': ua} for hr, ua in examples]
            out.append(f"""do $$
declare v_topic uuid;
begin
  select id into v_topic from public.grammar_topics where cefr = {q(LEVEL)} and title_ua = {q(topic)} and status = 'PUBLISHED' order by created_at limit 1;
  if v_topic is null then raise exception 'Немає теми граматики «{topic}»'; end if;
  if exists (select 1 from public.grammar_rules where id = {q(rid)}) then return; end if;
  insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
  values ({q(rid)}, v_topic, {q(title)}, {q(expl)}, {q(pattern)}, {qj(ex)},
          coalesce((select max(order_index) from public.grammar_rules where topic_id = v_topic), 0) + 1);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('grammar_rule', {q(rid)}, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(RULE_NOTE)});
end $$;""")
    out.append('')
    return out


def content_sql(c: Course, key, s: list[str]):
    L = c.lessons[key]
    m, o = key
    n = PLACE[key]
    s += [f"  select id into v_gid from public.grammar_topics where cefr = {q(LEVEL)} and title_ua = {q(L['grammar'])} and status = 'PUBLISHED' order by created_at limit 1;",
          f"  if v_gid is null then raise exception 'Немає теми граматики «{L['grammar']}»'; end if;",
          '  -- слова']
    for word in L['words']:
        s.append(f'  v_pos := pg_temp.word(v_lesson, {q(word)}, v_pos);')
    s += ['  -- граматика',
          '  v_pos := v_pos + 1;',
          "  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');",
          '  delete from public.lesson_grammar where lesson_id = v_lesson;',
          '  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;',
          '  -- вправи']
    for ei, ex in enumerate(c.lesson_exercises(key), 1):
        opts = qj(ex['options']) if ex['options'] is not None else 'null'
        lemma = q(ex['word']) if ex.get('word') else 'null'
        s.append(f"  v_pos := pg_temp.ex(v_lesson, v_pos, {q(uid('exercise_v3', LEVEL, m, o, ei))}, {q(ex['type'])}, {q(ex['question'])}, "
                 f"{q(ex['answer'])}, {opts}, {q(LEVEL)}, {ei}, {q(STATUS)}, {lemma}, {q(ex['skill'])});")
    for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1):
        cid = uid('conversation_v3', LEVEL, m, o, si)
        s.append(f'  -- діалог {si}')
        s.append('  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)')
        s.append(f"  values ({q(cid)}, v_lesson, {q(s_ua)}, {q(s_hr)}, {3000 + n * 10 + si}, {q(LEVEL)}, {q(L['situation'])}, {q(STATUS)}, {q(SOURCE)}) on conflict (id) do nothing;")
        for ti, (speaker, hr, ua) in enumerate(turns, 1):
            s.append(f"  perform pg_temp.turn({q(uid('turn_v3', LEVEL, m, o, si, ti))}, {q(cid)}, {q(speaker)}, {q(hr)}, {q(ua)}, {ti});")


REVIEW_NOTE = 'Бета: урок перебудовано за програмою A1 v3 (слова за темою, нові діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.'
NEW_NOTE = 'Бета: новий урок програми A1 v3 (слова за темою, 2 діалоги, 15 вправ) за рішенням власника 2026-10-26. Потрібна перевірка носієм.'
VERSION_NOTE = 'curriculum_a1_v3: урок перебудовано за темою — стара версія (слова, вправи, діалоги, граматика)'


def rebuild_sql(c: Course, key) -> list[str]:
    L = c.lessons[key]
    m, o = key
    n = PLACE[key]
    t_ua, t_hr = L['title']
    first_conv = uid('conversation_v3', LEVEL, m, o, 1)
    s = [f'-- A1.{m} · урок {n}: {t_ua} — перебудова: {len(L["words"])} слів, 2 нові діалоги, {len(c.lesson_exercises(key))} вправ',
         'do $$', 'declare',
         f'  v_lesson constant uuid := {q(lesson_id(m, o))};', '  v_gid uuid;', '  v_pos int := 0;', '  v_payload jsonb;', 'begin',
         f"  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «{t_ua}» не знайдено'; end if;",
         f'  if exists (select 1 from public.conversations where id = {q(first_conv)}) then return; end if;  -- уже перебудовано',
         '  -- стара версія: знімок і копія кроків',
         "  select jsonb_build_object('lesson', to_jsonb(l),",
         "         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),",
         "         'grammar', (select coalesce(jsonb_agg(lg.grammar_topic_id), '[]'::jsonb) from public.lesson_grammar lg where lg.lesson_id = v_lesson),",
         "         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))",
         '    into v_payload from public.lessons l where l.id = v_lesson;',
         '  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)',
         "  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,",
         f'          v_payload, {q(VERSION_NOTE)});',
         f'  insert into {BACKUP} select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;',
         '  -- старі вправи й діалоги — застарілі (не видаляються)',
         "  update public.exercises e set status = 'DEPRECATED'",
         "   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')",
         "     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);",
         "  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';",
         '  delete from public.lesson_items where lesson_id = v_lesson;',
         f"  update public.lessons set title_ua = {q(f'Урок {n}: {t_ua}')}, title_hr = {q(f'Lekcija {n}: {t_hr}')},",
         f"         objectives = {qj(L['objectives'])}, estimated_minutes = {MINUTES} where id = v_lesson;"]
    content_sql(c, key, s)
    s += ['  -- журнал перевірки',
          '  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
          f"  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(REVIEW_NOTE)});",
          'end $$;', '']
    return s


def create_sql(c: Course, key) -> list[str]:
    L = c.lessons[key]
    m, o = key
    n = PLACE[key]
    t_ua, t_hr = L['title']
    s = [f'-- A1.{m} · урок {n}: {t_ua} — новий урок: {len(L["words"])} слів, 2 діалоги, {len(c.lesson_exercises(key))} вправ',
         'do $$', 'declare',
         f'  v_unit constant uuid := {q(unit_id(m))};', f'  v_lesson constant uuid := {q(lesson_id(m, o))};', '  v_gid uuid;', '  v_pos int := 0;',
         'begin',
         '  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено',
         f'  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = {o}) then',
         f"    raise exception 'A1.{m}: місце {o} зайняте іншим уроком';",
         '  end if;',
         '  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)',
         f"  values (v_lesson, v_unit, {q(LEVEL)}, {q(f'Урок {n}: {t_ua}')}, {q(f'Lekcija {n}: {t_hr}')}, {qj(L['objectives'])}, {MINUTES}, {q(STATUS)}, {o});"]
    content_sql(c, key, s)
    s += ['  -- журнал перевірки',
          '  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
          f"  values ('lesson', v_lesson, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(NEW_NOTE)});",
          'end $$;', '']
    return s


def module_out(module: int) -> Path:
    return FIXES / f"{MODULES[module]['date'].replace('-', '')}_curriculum_a1_v3_m{module:02d}.sql"


def build_module(c: Course, module: int) -> str:
    M = MODULES[module]
    keys = sorted(M['lessons'])
    rebuilt = [k for k in keys if 'old' in M['lessons'][k]]
    created = [k for k in keys if 'old' not in M['lessons'][k]]
    words_total = sum(len(M['lessons'][k]['words']) for k in keys)
    first, last = PLACE[keys[0]], PLACE[keys[-1]]
    ids = ', '.join(q(lesson_id(*k)) for k in keys)
    order_check = ', '.join(f"({q(lesson_id(*k))}::uuid, {k[1]})" for k in keys)
    lo, hi = WORDS_RANGE
    G = M.get('new_grammar', {})
    X = M.get('extra_rules', {})
    grammar_line = (f"\n--   * Нові теми граматики: {', '.join('«' + g['title_ua'] + '»' for g in G.values())}." if G else '')
    rules_line = (f"\n--   * Нові правила до тем: {', '.join(f'«{t}» (+{len(r)})' for t, r in X.items())}." if X else '')
    fixes = [f'{a} → {b}' for a, b in M.get('fix_lemmas', [])] + [f'{a} — «{n}»' for a, _o, n in M.get('fix_translations', [])]
    fix_line = f"\n--   * Виправлено: {'; '.join(fixes)} (стара версія — у content_versions)." if fixes else ''
    ua_title = D.PROGRAM[module]['title'][0]
    out = [f"""-- =====================================================================
-- Програма A1 v3 · модуль A1.{module} «{ua_title}» · {M['date']}
-- Згенеровано: python3 -B scripts/gen_curriculum_a1_v3.py {module} (не редагуйте вручну).
--
-- Рішення власника 2026-10-21 / 2026-10-26: до 25 слів на урок — скільки потрібно темі, 90–95 % слів — нові для рівня,
-- діалоги під тему, частіше Даша / Дар’я; бета (PUBLISHED).
--   * Уроки {first}–{last}: {len(rebuilt)} наявних перебудовано, {len(created)} нових. Слів у них: {words_total}.
--     Кожен: {lo}–{hi} слів, 2 діалоги, 15 вправ, {MINUTES} хв.
--   * Нові слова й вирази: {len(M['new_lexemes'])}.{grammar_line}{rules_line}{fix_line}
--   * Стара версія кожного зміненого уроку — у content_versions; копія кроків — у {BACKUP};
--     старі вправи й діалоги → DEPRECATED (не видаляються). Назви всіх уроків A1 — наскрізні номери.
--   * Потрібен уже запущений 20261026_curriculum_a1_v3_structure.sql. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.modules where id = {q(uid('module_v3', LEVEL, 7))}) then
    raise exception 'Спершу запустіть 20261026_curriculum_a1_v3_structure.sql (нова програма A1)';
  end if;
end $$;

create schema if not exists backup;
create table if not exists {BACKUP} (like public.lesson_items including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'lesson_items_20261015_pkey') then
    alter table {BACKUP} add constraint lesson_items_20261015_pkey primary key (id);
  end if;
end $$;
revoke all on {BACKUP} from anon, authenticated;
""", HELPERS_SQL]
    out += lexemes_sql(module)
    out += fixes_sql(module)
    out += grammar_sql(module)
    out.append(f'-- 2. Перебудова наявних уроків модуля A1.{module}')
    for key in rebuilt:
        out += rebuild_sql(c, key)
    out.append(f'-- 3. Нові уроки модуля A1.{module}')
    for key in created:
        out += create_sql(c, key)
    out.append(RENUMBER_SQL)
    out.append(f"""-- 5. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_order int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ({ids})
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between {lo} and {hi}
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> {MINUTES});
  select count(*) into v_order from (values {order_check}) as t(id, o)
    join public.lessons l on l.id = t.id and l.order_index = t.o and l.unit_id = {q(unit_id(module))};
{TITLES_CHECK}
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ({ids}) and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A1.{module}: % уроків з неправильним складом', v_bad; end if;
  if v_order <> {len(keys)} then raise exception 'Модуль A1.{module}: на своїх місцях % уроків з {len(keys)}', v_order; end if;
  if v_titles > 0 then raise exception 'A1: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A1.{module}: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A1.{module} — {len(keys)} {'уроки' if len(keys) in (2, 3, 4) else 'уроків'} за темою ({len(rebuilt)} перебудовано, {len(created)} нових)';
end $$;

commit;
""")
    return '\n'.join(out)


# ----------------------------------------------------------------------------- перевірки
def validate(c: Course, module: int):
    M = MODULES[module]
    a0 = set(SNAPSHOT['a0_words'])
    for key in sorted(M['lessons']):
        c.validate_lesson(key)
        c.lesson_exercises(key)
        L = M['lessons'][key]
        n = PLACE.get(key)
        # місце в програмі
        ref = L.get('old', L.get('slug'))
        where = (WHERE_OLD if 'old' in L else WHERE_SLUG).get(ref)
        if where != key:
            c.errors.append(f'{key}: у програмі {ref!r} стоїть на місці {where}, а не {key}')
        if ('old' in L) == ('slug' in L):
            c.errors.append(f'{key}: потрібне одне з old / slug')
        types = {ex['type'] for ex in c.lesson_exercises(key)}
        if len(types) < 6:
            c.errors.append(f'урок {n}: лише {len(types)} типи вправ з 6 (бракує однозначних слів для «напишіть» — додайте слово)')
        from_a0 = [w for w in L['words'] if w.lower() in a0]
        if len(from_a0) > A0_MAX:
            c.errors.append(f'урок {n}: слів з уроків A0 {len(from_a0)} (не більше {A0_MAX}): {from_a0}')
        for sp, hr, ua in (t for s in L['scenes'] for t in s[2]):
            if '  ' in hr or hr != hr.strip():
                c.errors.append(f'урок {n}: зайві пробіли в репліці {hr!r}')
    if sorted(M['lessons']) != [(module, o) for o in range(1, len(D.PROGRAM[module]['lessons']) + 1)]:
        c.errors.append(f'A1.{module}: уроки модуля мають бути 1…{len(D.PROGRAM[module]["lessons"])}, як у програмі')
    known = set(SNAPSHOT['lex']) | set(SNAPSHOT['a0_pool'])
    for lemma, norm, ua, pos, vtype, forms, ex in M['new_lexemes']:
        if re.search(r'[čćđšž]', norm) or norm != norm.lower():
            c.errors.append(f'{lemma}: normalized має бути без діакритики й малими літерами')
        if re.search(r'[Ѐ-ӿ]', lemma + ex):
            c.errors.append(f'{lemma}: кирилиця в лемі чи прикладі')
        if not re.search(r'[Ѐ-ӿ]', ua):
            c.errors.append(f'{lemma}: переклад без кирилиці')
        if vtype not in ('core', 'function_word', 'formulaic', 'collocation', 'chunk'):
            c.errors.append(f'{lemma}: невідомий vocabulary_type')
        if lemma.lower() in known:
            c.errors.append(f'{lemma}: уже є в робочій базі — не додавайте як нове слово')
    new_lc = [l[0].lower() for l in M['new_lexemes']]
    if len(new_lc) != len(set(new_lc)):
        c.errors.append('дублікати серед нових слів')
    used = {w.lower() for L in M['lessons'].values() for w in L['words']}
    for l in new_lc:
        if l not in used:
            c.errors.append(f'нове слово «{l}» не використано в жодному уроці')
    seen: dict = {}
    for key in sorted(M['lessons']):
        for w in M['lessons'][key]['words']:
            if w.lower() in seen:
                c.errors.append(f'«{w}» є і в уроці {PLACE[seen[w.lower()]]}, і в уроці {PLACE[key]}')
            seen[w.lower()] = key
    earlier = {w.lower(): m for m in MODULES if m < module for L in MODULES[m]['lessons'].values() for w in L['words']}
    for w, key in seen.items():
        if w in earlier:
            c.errors.append(f'«{w}» (урок {PLACE[key]}) уже є в модулі A1.{earlier[w]}')
    for key, L in M['lessons'].items():
        if L['grammar'] not in grammar_titles(module):
            c.errors.append(f'{key}: невідома тема граматики {L["grammar"]!r}')


def review(c: Course, module: int) -> str:
    M = MODULES[module]
    keys = sorted(M['lessons'])
    a0 = set(SNAPSHOT['a0_words'])
    out = [f'# Програма A1 v3 — модуль A1.{module} «{D.PROGRAM[module]["title"][0]}», звіт для перевірки', '',
           f'> Згенеровано `scripts/gen_curriculum_a1_v3.py --review {module}` {M["date"]}. Бета за рішенням власника: слова за темою '
           '(до 25, скільки потрібно), 90–95 % нових для рівня, діалоги під тему.', '',
           'Порядок уроків модуля: ' + ' → '.join(f'{PLACE[k]} «{M["lessons"][k]["title"][0]}»' + ('' if 'old' in M['lessons'][k] else ' (новий)')
                                                 for k in keys) + '.', '',
           '## Що варто глянути носію', '', *M.get('review_notes', REVIEW_NOTES.get(module, [])), '',
           '## Нові слова', '', '| Лема | Переклад | Приклад |', '|---|---|---|']
    for lemma, _n, ua, _p, _v, _f, ex in M['new_lexemes']:
        out.append(f'| {lemma} | {ua} | {ex} |')
    G = M.get('new_grammar', {})
    X = M.get('extra_rules', {})
    if G or X:
        out += ['', '## Граматика', '']
        for g in G.values():
            out.append(f'**Нова тема «{g["title_ua"]}»** ({g["title_hr"]})')
            out.append('')
            for title, expl, pattern, examples in g['rules']:
                out.append(f'- *{title}.* {expl} Зразок: {pattern}. Приклади: ' + '; '.join(f'{hr} — {ua}' for hr, ua in examples))
            out.append('')
        for topic, rules in X.items():
            out.append(f'**Нові правила до теми «{topic}»**')
            out.append('')
            for title, expl, pattern, examples in rules:
                out.append(f'- *{title}.* {expl} Зразок: {pattern}. Приклади: ' + '; '.join(f'{hr} — {ua}' for hr, ua in examples))
            out.append('')
    for key in keys:
        L = M['lessons'][key]
        n = PLACE[key]
        types = {ex['type'] for ex in c.lesson_exercises(key)}
        if len(types) < 6:
            c.errors.append(f'урок {n}: лише {len(types)} типи вправ з 6 (бракує однозначних слів для «напишіть» — додайте слово)')
        from_a0 = [w for w in L['words'] if w.lower() in a0]
        out += ['', f'## Урок {n}: {L["title"][0]} · {L["title"][1]}' + ('' if 'old' in L else ' (новий урок)'), '',
                f'Граматика: «{L["grammar"]}».', '',
                f'**Слова ({len(L["words"])}' + (f', з A0: {", ".join(from_a0)}' if from_a0 else '') + '):** '
                + ', '.join(f'{c.lemma_of(w)} — {c.display_ua(w)}' for w in L['words']), '']
        for s_ua, s_hr, turns in L['scenes']:
            out.append(f'**Діалог «{s_hr}»** ({s_ua})')
            out.append('')
            for sp, hr, ua in turns:
                out.append(f'- *{sp}:* {hr} — {ua}')
            out.append('')
        out.append('| Тип | Питання | Відповідь | Варіанти |')
        out.append('|---|---|---|---|')
        for ex in c.lesson_exercises(key):
            opts = ' · '.join(ex['options']) if ex['options'] else ''
            out.append(f"| {ex['type']} | {ex['question']} | {ex['answer']} | {opts} |")
    return '\n'.join(out) + '\n'


REVIEW_NOTES = {
    1: ['1. Нова тема граматики «Зворотні дієслова: se» (4 правила): місце *se* у реченні (*Svake večeri se vraćam*, *Zašto se ne češljaš?*, '
        '*Tuširaš li se ujutro?*), відмінності від «-ся» (*odmarati se* — відпочивати, *počinjati* — починатися, *učiti* — вчитися).',
        '2. Нові правила: «Дієслова на -ovati, -nuti і -ći» і «Прислівники частоти» (тема «Теперішній час»), «Ще не, більше не, зовсім не» '
        '(тема «Заперечення»). Особливо *Vlak krene u sedam.* (доконаний вид у розкладі).',
        '3. Нові слова-вирази: *svakog jutra*, *svake večeri*, *radnim danom*, *vikendom*, *svaki drugi dan*, *gotovo nikad*, *više ne*, *još ne*, '
        '*prati zube*, *sušiti kosu*, *brisati prašinu*, *šetati psa*, *izvesti psa*, *pijesak za mačke* («наповнювач»), *imati vremena* — чи природно як окремі одиниці словника.',
        '4. Дієслова: *obuti se* (imperativ obuj se), *lijegati* (liježem), *mjaukati* (mjauče), *mesti* (metem), *naspavati se*, *izležavati se*, *šminkati se*.',
        '5. Діалоги: *Obično krećem u sedam, a na posao dolazim u pola osam.*, *Radimo roštilj u vrtu*, *Pada kiša, od piknika nema ništa.*, '
        '*Zaljuljaj me na ljuljački*, *Kupite mu grebalicu*, *Ja trebam tišinu da zaspim*, *Danas ga triput vodim u šetnju*.',
        '6. Виправлено в словнику: лема *Uglavnom* → *uglavnom*; *čuvati* — «берегти; доглядати, наглядати (за дитиною)»; *ponovno* — «знову, ще раз».',
        '7. Слова з A0 у цих уроках не повторюються (крім 0–2 на урок): *ujutro*, *navečer*, *uvijek*, *ponekad*, *budilica*, *jastuk*, *kasniti*, '
        '*dlaka*, *hraniti* та ін. уже вивчені в A0 — тому їх немає серед слів, лише в діалогах.'],
}
REVIEW_NOTES[2] = [
    '1. Нова тема граматики «Числа й кількість: dva kruha, pet jaja» (3 правила): *dvije jabuke*, *četiri kotleta*, *pet kruhova*, '
    '*kilogram trešanja*, *dvije glavice salate*, *tri litre mlijeka*; нове правило «Знахідний відмінок: множина» (*kupujem jabuke, Djeca vole kolače*).',
    '2. Новий урок «Посуд і сервірування»: *duboki / plitki tanjur*, *zdjela*, *žličica*, *pribor za jelo*, *vrč*, *otvarač*, *kuhača*, '
    '*daska za rezanje*, *postaviti stol*, *pospremiti stol*, *Gdje da stavim čaše za vino?*',
    '3. Назви продуктів: *kotlet* («відбивна на кістці»), *pileća prsa*, *oslić* («хек»), *orada*, *brancin*, *kifla* («рогалик»), *perec*, '
    '*pita*, *tegla* і *konzerva*, *mladi luk*, *zelena salata*, *grozd*, *kockica za juhu*, *rezanci*.',
    '4. Ринок і кафе: *Subotom na placu*, *Peršin vam dajem gratis, stalna ste mušterija.*, *Dajte mi kilogram trešanja*, '
    '*Jedan burek sa sirom i dvije kifle*, *Može topla čokolada, ali ne prevruća.*',
    '5. Кухня: *Stavim piletinu u veliki lonac i zakuham vodu.*, *Grah mora još malo prokuhati.*, *Pusti da juha prokuha deset minuta.*, '
    '*Zagrij pećnicu na sto osamdeset*, *Meso posoli i popapri.*',
    '6. Вирази: *ne podnosim* («не переношу»), *za koliko osoba*, *na ime*, *zauzeto*, *specijalitet kuće*, *bez glutena*, '
    '*bljutav* («прісний»), *začinjen*.',
    '7. Виправлено переклад *kava za van*: «Кава з собою.» → «кава з собою». Продукти з A0 (*kruh, mlijeko, jaje, jabuka, riba, meso, '
    'tanjur, vilica, nož, žlica, šalica, jelovnik…*) тут лише в діалогах.',
]

REVIEW_NOTES[3] = [
    '1. Нова тема граматики «Короткі форми давального: sviđa mi se» (4 правила): *mi, ti, mu, joj, nam, vam, im*; *sviđa mi se / sviđaju mi se*; '
    '*treba mi, stoji ti, žao mi je*; місце: *Sviđa mi se*, *Kako ti stoji?*, *Meni se ne sviđa*, *Mami se sviđa srebro*.',
    '2. Нові правила: «Прикметник + іменник у знахідному» (*Tražim zimsku kapu*, *Imate li crni kaput?*) і «Особливі форми: bolji, gori, veći, manji» '
    '(тема «Ступені порівняння»; A0 уже мав -iji / -ji й naj-).',
    '3. Нові уроки: «Подобається чи ні?» (*ukus, stil, staromodan, elegantan, ležeran, uzorak*), «У приміряльні: розмір і фасон» '
    '(*tijesan, labav, rukav, nogavica, džep, gumb, patentni zatvarač, ovratnik, kroj, skratiti, krojačica*), «Прикраси й подарунки» '
    '(*zlatarna, lančić, privjesak, ručni sat, zamotati, ukrasni papir, vrpca, poklon bon*).',
    '4. Косметика: *regenerator* («бальзам-ополіскувач»), *omekšivač* («кондиціонер для білизни»), *šminka*, *ruž za usne*, *maskara*, '
    '*lak za nokte*, *britvica*, *vlažne maramice*, *krema za sunčanje*.',
    '5. Діалоги: *Visoke pete mi se ne sviđaju.*, *Ako ti se svidi, uzmi je!*, *Kroj je lijep, ali rukavi su ti predugi.*, '
    '*U struku su mi malo labave.*, *Na košulji nedostaje jedan gumb na ovratniku.*, *Druga je skuplja zbog imena.*, '
    '*Usporedite ih na miru, ne žurimo se.*, *Ne mogu, plaćanje je pouzećem.*',
    '6. Уточнено переклади: *svidjeti se* — «сподобатися» (було «подобатися», як у *sviđati se*); *stajati* — «стояти; коштувати; личити»; '
    '*odgovarati* — «відповідати; підходити (за розміром, часом)»; *isti* — «той самий; однаковий».',
    '7. Одяг, розмір і повернення товару вже були в A0 (*jakna, haljina, veličina, probati, kabina, uzak, širok, vratiti, zamijeniti, '
    'reklamacija, jamstvo, povrat novca…*) — тут вони лише в діалогах; *ništa, nitko* перейдуть у A1.9 («Неозначені займенники»).',
]

REVIEW_NOTES[4] = [
    '1. Дві нові теми граматики: «Kamo? і Gdje?: u grad — u gradu» (4 правила: u / na + знахідний — куди; u / na + місцевий — де; '
    'iz / s + родовий — звідки; *kamo / kuda*, *ovdje / ovamo*, *vani / van*) і «Орудний відмінок: autobusom, s prijateljem» '
    '(4 правила: транспорт *tramvajem, vlakom*; *s / sa* + орудний; *sa mnom, s tobom*; *pred, pod, nad, između* + орудний).',
    '2. Новий урок «Куди йдемо? Kamo чи gdje?» — головна помилка українців (*Idem u gradu*). Перевірте пояснення й приклади.',
    '3. Нові слова: *ovamo*, *van* («надвір»), *svratiti*, *odvesti*, *poništiti* («прокомпостувати»), *nadoplatiti*, *okretište*, '
    '*ustupiti mjesto*, *gurati se*, *kolosijek*, *kupe*, *stanka*, *mučnina*, *taksimetar*, *zaobići*, *pauk* («евакуатор», розм.), '
    '*odvući*, *traka*, *zaustavna traka*, *lampica* («індикатор»), *ispuh*, *brisač*.',
    '4. Діалоги: *Ovim tramvajem stižete ravno do kolodvora.*, *Karta nije važeća, mjesec je završio.*, *Otkazan je zbog radova na pruzi.*, '
    '*Željeznica ima zamjenski autobus ispred kolodvora.*, *Za prtljažni prostor naplaćujemo dva eura.*, *Prednja lijeva guma je malo mekana.*, '
    '*Parkirnu kartu stavite iza stakla.*, *Kad mijenjam brzinu, svijetli lampica akumulatora.*',
    '5. Уточнено переклади: *kuda* — «куди, якою дорогою» (було «куди», як *kamo*); *pumpa* — «заправка (АЗС); насос»; '
    '*zastoj* — «затримка, зупинка; перешкода (блокер у роботі)» (було лише «блокер»).',
    '6. Квитки, вокзал, таксі й заправка вже були в A0 (*karta, kolodvor, peron, vozni red, taksi, benzin, parkirati, autocesta…*) — '
    'тут вони лише в діалогах.',
]

REVIEW_NOTES[5] = [
    '1. Нові правила: «Прикметник у місцевому: u novom stanu, na prvom katu» (тема «Місцевий відмінок») і '
    '«Blizu, pokraj, preko puta, nasuprot, oko + родовий» (тема «Родовий відмінок: основи», з прикметником: *blizu velikog parka*).',
    '2. Новий урок «Мій район: що поруч?» (*okolica, nasuprot, prometan, kiosk, groblje, spomenik, klupa, pješačka zona, stara jezgra, '
    'sportski centar, zelenilo*). Діалог згадує Мирогой лише в прикладі до слова *groblje*.',
    '3. Нові слова: *potkrovlje* («мансарда»), *novogradnja*, *useljiv*, *ugaona garnitura*, *jastučnica*, *ljepljiva traka* («скотч»), '
    '*selidbena tvrtka*, *trajni nalog* («автоплатіж»), *opomena*, *očitanje*, *začepljen*, *odvod*, *kratki spoj*, *domar*, '
    '*kliješta*, *ljestve*, *kist*, *valjak*, *propuh*, *odvlaživač*, *dobrodošlica*, *zalijevati*, *noćni mir*.',
    '4. Діалоги: *Stan je odmah useljiv i ima veliki balkon.*, *Dvije najamnine.*, *Na kutiju napiši: «Pažljivo, lomljivo!»*, '
    '*Bolje napravi trajni nalog, pa nema opomena.*, *Vodokotlić stalno radi.*, *Zovite odvoz glomaznog otpada.*, *Odmah stišavam.*',
    '5. Уточнено переклади: *blizina* — «близькість (u blizini — поруч)» (було «близькість; околиці», як *okolica*); *peć* — «піч».',
    '6. Квартира, кімнати, меблі й рахунки вже були в A0 (*stan, najam, režije, kauč, ormar, ladica, kvar, majstor, susjed…*) — '
    'тут вони лише в діалогах. Минулого часу (*perfekt*) у діалогах свідомо немає — він з’явиться в A1.6.',
]

REVIEW_NOTES[6] = [
    '1. Нова тема граматики «Минулий час: radio sam, bila sam» (4 правила: утворення з *biti*; рід і число *radio / radila / radili*; '
    'порядок слів, *nisam radio*, *Jesi li radio? — Jesam*; часті неправильні *išao, došao, mogao, htio, rekao*). Минулий час — '
    'у діалогах уроків 53, 55, 57 і далі.',
    '2. Нове правило «Ne moraš і ne smiješ» (тема «Модальні дієслова»): «не обов’язково» проти «не можна».',
    '3. Нові слова: *tvornica*, *dostavljač*, *čuvar*, *nadređeni*, *prekovremeno*, *rad od kuće*, *oglas za posao*, *motivacijsko pismo*, '
    '*honorarni posao*, *nepuno radno vrijeme*, *razgovor za posao*, *prethodni*, *bivši*, *timski rad*, *ugovor na određeno / neodređeno*, '
    '*doprinosi*, *regres* («відпускні»), *božićnica*, *otkazni rok*, *mentor*, *obuka*, *pravilnik*, *zaštita na radu*, *dopust*, '
    '*doznaka* («лікарняний лист»), *prehlađen*, *nadoknaditi*, *spajalica*, *klamerica* («степлер»), *registrator*, *sala za sastanke*.',
    '4. Діалоги: *Došla sam u Hrvatsku, pa sam dala otkaz.*, *Na bivšem poslu vodio sam tim od pet ljudi.*, '
    '*Od bruto plaće se plaćaju porez i doprinosi.*, *U lipnju dobiješ i regres, a u prosincu božićnicu.*, '
    '*Mentorica mi je objasnila program.*, *Nažalost, razboljela sam se.*, *Recite joj da sam bolestan i da danas ne dolazim.*',
    '5. Уточнено переклади: *dnevni sastanak* — «щоденна нарада; дейлі (стендап)»; *natječaj* — «конкурс (на посаду), вакансія».',
    '6. Файли й пошта (*datoteka, privitak, proslijediti, spremiti, obrisati, računalo*) перейшли в A1.7 «Комп’ютер, телефон та інтернет».',
]

REVIEW_NOTES[7] = [
    '1. Нові правила до теми «Минулий час»: «Короткі слова разом: Poslao sam ti ga» (порядок *li → sam → mi → ga → se → je*; '
    '*Mama mi ga je kupila*) і «Pisala sam і napisala sam» (вид дієслова в минулому).',
    '2. Чотири нові уроки: «Комп’ютер і телефон», «Електронна пошта й повідомлення», «Акаунт і пароль: я забув пароль», '
    '«Онлайн-послуги: запис, оплата, e-Građani». Перевірте назви реальних послуг: *e-Građani*, *e-naručivanje*, *mobilni token*, '
    '«osobna iskaznica s certifikatom».',
    '3. Нові слова: *pametni telefon*, *tipka*, *glasnoća*, *ponovno pokrenuti*, *napuniti*, *futrola* («чохол»), *zaštitno staklo*, '
    '*USB ključić* («флешка»), *paket podataka*, *mobilni podaci*, *roming*, *pokrivenost*, *govorna pošta*, *prijenos broja*, *predmet* '
    '(«тема листа»), *neželjena pošta* («спам»), *pošiljatelj / primatelj*, *korisnički račun*, *unijeti*, *resetirati*, '
    '*kod za potvrdu*, *potvrda u dva koraka*, *učitati* («завантажити на сайт»), *tražilica*, *web-stranica*.',
    '4. Діалоги: *Dodirni ekran ovdje, u postavkama.*, *Evo ga, završio je u neželjenoj pošti!*, *Tri puta ste unijeli krivu lozinku.*, '
    '*Uputnica je digitalna, ne moraš je učitati.*, *Ja sam jučer napisao komentar i svi su me napali.*',
    '5. Уточнено переклади: *bon* — «ваучер поповнення (мобільного рахунку)»; *odjaviti se* — «виписатися; вийти (з акаунта)»; '
    '*kliknuti* — «клікнути, клацнути (мишкою)».',
    '6. Новий модуль ще не має текстів для читання — у перевірці a1-m07 замість «прочитай» ще одне «на слух».',
]

REVIEW_NOTES[8] = [
    '1. Нові правила: «„Давайте“: uzmimo, idemo; neka uzme» (тема «Наказовий спосіб»: *pričekajmo, neka pije puno vode*, поради лікаря у Vi-формі) '
    'і «Se в минулому: ozlijedio sam se, on se ozlijedio» (тема «Минулий час»: у 3-й особі *je* випадає перед *se*).',
    '2. Новий урок «Внутрішні органи» (*pluća, jetra, bubreg, želudac, crijeva, mozak, mišić, zglob, kralježnica, štitnjača, probava, živac*).',
    '3. Медичні реалії Хорватії: *dopunsko osiguranje*, *participacija*, *zdravstvena iskaznica*, *obiteljski liječnik*, *e-Građani* для результатів аналізів — перевірте, чи природно.',
    '4. Нові слова: *vrtoglavica*, *zimica*, *znojiti se*, *curi mi nos*, *začepljen nos*, *mirovanje* («постільний режим»), *kapsula*, *pastila*, '
    '*progutati*, *otopiti*, *nuspojava*, *karijes*, *desni*, *krunica*, *konac za zube*, *vaditi krv*, *uzorak urina*, *magnetska rezonancija*, '
    '*posjeći se*, *udariti se*, *upala uha*, *vodene kozice*, *čepić*.',
    '5. Діалоги: *Jučer sam se jako loše osjećala.*, *Noću sam imala zimicu i jako sam se znojila.*, *Bila sam na moru i smrzla sam se.*, '
    '*Pao sam s bicikla i udario se u ruku.*, *Dajte mu čepić za temperaturu i neka pije puno vode.*, *Nećete ništa osjetiti, dobit ćete anesteziju.*',
    '6. Уточнено переклади: *cjepivo* — «вакцина» (було «вакцина / щеплення», як *cijepljenje*); *težina* — «вага (тіла); складність»; *hitan* — «терміновий, невідкладний».',
    '7. Частини тіла, «Що болить?», аптека й лікар уже були в A0 — тому колишні уроки «Як ви почуваєтеся?» і «Що болить?» стали «Симптоми» й «Діагноз і лікування».',
]

REVIEW_NOTES[9] = [
    '1. Дві нові теми граматики: «Кличний відмінок: Dašo! Ivane! Gospodine!» (4 правила: чоловічий *-e / -u*, жіночий *-o* або без змін '
    '— *Dašo, mamo, gospođo*, але *Ana, Ivana*; *gospodine Kovaču / gospođo Babić*; множина) і «Неозначені займенники: netko, nešto, negdje» '
    '(4 правила: *ne-*, *ni-* + заперечення, *i- / bilo-*, *sve-*). Перевірте, які жіночі імена в розмові мають *-o*.',
    '2. Нове правило «Da, kad, ako: Mislim da…» (тема «Сполучники»).',
    '3. Нові уроки: «Як звернутися? Dašo! Gospodine!» (*persirati, tikati, oslovljavati, poštovani, dame i gospodo, čika, titula*) і «Хтось, щось, десь».',
    '4. Нові слова: *dobro raspoložen*, *loše volje*, *razočaran*, *uzbuđen*, *ljubomoran*, *bijesan*, *uplašen*, *domjenak* («корпоратив»), '
    '*pratnja*, *planinarski dom*, *izletnik*, *okupiti se*, *šah*, *društvene igre*, *pecati*, *vrtlarenje*, *neriješeno*, *premijera*, *pljeskati*, '
    '*ikad*, *nekad*, *svatko*, *po mom mišljenju*, *u pravu*, *griješiti*, *simpatija*, *zaljubljen*, *zaručiti se*.',
    '5. Діалоги: *Možemo se tikati, ja sam Ivo.*, *A kako se ti zoveš, mladiću?*, *Drago mi je, gospođice Ana!*, '
    '*Mjesto sastanka je na tramvajskoj stanici Mihaljevac.*, *Hrvatska je pobijedila dva jedan.*, *Moj dečko me pitao na plaži, za zalazak sunca.*',
    '6. Уточнено переклади: *veza* (+ «стосунки»), *prekinuti* (+ «розійтися»), *slikati* — «малювати (фарбами); фотографувати», *ponosan* (+ «який пишається»).',
    '7. Читання: сполучники *ali, ili, jer* лишаються «знайомими» (вивчаються в темі «Сполучники»), *film, knjiga, igrati* — у словах уроків 81 і 84.',
]


REVIEW_NOTES[10] = [
    '1. Нова тема граматики «Майбутній час: ići ću, bit će» (4 правила: *ću + інфінітив*, коротка форма без займенника *putovat ću*, '
    '*neću / hoćeš li*, *bit će*). Діалоги в уроках «Прогноз погоди» й «Плани на відпустку» — у майбутньому часі.',
    '2. Нове правило «Najljepši u…, jedan od najljepših» (тема «Ступені порівняння»).',
    '3. Нові уроки: «Плани на відпустку» (*kampirati, šator, privatni smještaj, polupansion, putno osiguranje, predsezona*), '
    '«Далмація: Задар» (одразу після «Краї Хорватії», за рішенням власника: *morske orgulje, Pozdrav Suncu, forum, zvonik, klapa, maraskino, fjaka*) '
    'і «Дикі тварини» (*medvjed, vuk, ris, srna, poskok, dupin, galeb*).',
    '4. Нові слова: *maestral, munja, pljusak, toplinski val, razvedriti se, naoblačiti se, kišovit*; краї *Istra, Dalmacija, Slavonija, Zagorje, Lika*; '
    '*narječje, primorski, kontinentalni, otočje, šetnica, kupalište, katamaran, ukrcaj, uvala, ležaljka, suncobran, ronjenje, kanjon, zabranjeno kupanje*.',
    '5. Факти для перевірки: на Крці купатися заборонено з 2021 р. (*Ni ondje više nije dopušteno*), поскок — отруйна змія островів, '
    'у Горському Котарі живуть ведмеді, вовки й рисі.',
    '6. Діалоги: *Ujutro će se razvedriti, ali popodne su mogući pljuskovi.*, *Samo da ne bude juga, onda je more nemirno.*, '
    '*Danas je fjaka: kupalište, kamen pod nogama i more.*, *Idemo li sutra na Plitvice ili na Krku?*',
    '7. Уточнено переклади: *obala* — «берег; узбережжя», *odmor* — «відпочинок; відпустка», *brod* (+ «човен, катер»).',
    '8. Читання: *način, putovanje, topao* більше не в словах уроків (рівень знято); усі тексти — ≥ 75 % знайомих слів.',
]


REVIEW_NOTES[11] = [
    '1. Новий модуль «Хорватська культура» (5 уроків, 93–97) з уроків колишнього модуля «Подорожі й культура». Нових тем граматики немає — '
    'нагадування: минулий час (екскурсія), ступені порівняння (кухня), зворотні дієслова (*rukuju se, ljube se, izuti se*), майбутній час (свята), '
    'родовий у датах (*tridesetog svibnja*).',
    '2. Слова, що вже були в уроках A0 («Старе місто», «Свята й привітання»), не повторюються: замість *Božić, Uskrs, Nova godina, bor* — '
    '*advent, jaslice, polnoćka, korizma, Cvjetnica*; державні свята — за чинним законом (з 2020 р.): *Sveta tri kralja … Sveti Stjepan*.',
    '3. Нові слова: *tvrđava, samostan, kip, gradska vrata, ruševine, srednjovjekovni, barokni, uličica*; *kulen, čobanac, pašticada, crni rižot*; '
    '*nazdraviti, imendan, rukovati se, ljubiti se, izuti se, ići na kavu, gostoljubiv, red je*; *adventski vijenac, božićna kuglica, lampice, bojiti jaja*; '
    '*Tijelovo, Velika Gospa, Svi sveti, Dan sjećanja, produženi vikend, zastava, himna*.',
    '4. Факти для перевірки: Ловрієнац, статуя Григорія Нинського (палець на щастя), дзвіниця собору в Спліті; чобіток на вікні до Святого Миколая; '
    'ялинку прикрашають на Badnjak; бакалар на Святвечір; на Cvjetnicu — гілочки оливи; Dan pobjede — свято в Кніні; Велика Госпа — Синь, Марія-Бистриця.',
    '5. Діалоги: *Kod nas je običaj da se izujemo.*, *Muškarci se rukuju, a prijatelji se ljube dvaput u obraz.*, '
    '*Danas ja častim, red je, imam imendan!*, *Čobanac je ljući od gulaša!*, *Ni za Sve svete ni za Svetog Stjepana.*',
    '6. Уточнено переклади: *specijalitet* — «фірмова страва; місцевий делікатес», *obnoviti* — «відновити, відреставрувати».',
    '7. Модуль новий, текстів для читання в ньому немає — у перевірці a1-m11 замість читання ще одне завдання на слух. '
    'Читання: *dugo, luka, misa, pričati, riva, sjediti, sjesti, slavlje* більше не в словах уроків (рівень знято); усі тексти — ≥ 75 % знайомих.',
]


REVIEW_NOTES[12] = [
    '1. Новий модуль «Діти, навчання й документи» (8 уроків, 98–105): колишній урок «Дитячий садок і школа» розділено на «Дитячий садок» '
    'і два нові уроки — «Школа: класи, уроки, розклад» і «Шкільне приладдя» (теми власника).',
    '2. Нові правила: «Родовий часу: prije, poslije, od … do, tijekom» (тема «Родовий відмінок») і «Svoj: svoju torbu, svoga sina» '
    '(тема «Присвійні займенники»). Перевірте пояснення різниці *svoj / njegov*.',
    '3. Нові слова: *upis, upisnina, prilagodba, popodnevni odmor, pokupiti, lista čekanja*; *gimnazija, razrednica, raspored sati, školski sat, '
    'veliki odmor, tjelesni odgoj, jutarnja / popodnevna smjena*; *pernica, gumica, šiljilo, ravnalo, udžbenik, radna bilježnica, bojice, tempere, '
    'kolaž papir, omot za knjige*; *položiti, polaznik, početnik, intenzivni tečaj*; *povratnica, omotnica, brza pošta, stanje računa*; '
    '*izvod, štedni račun, kamatna stopa, dopušteno prekoračenje*; *ovjereni prijevod, dokaz o sredstvima, dokaz o smještaju, dopuna*; *aparat za gašenje, gasiti*.',
    '4. Факти для перевірки: заява на продовження тимчасового перебування — не пізніше ніж за 60 днів до закінчення; перевірка сирен — '
    'щопершої суботи місяця; урок — 45 хвилин, школа працює в дві зміни.',
    '5. Діалоги: *Trenutno nema, ali možete ga staviti na listu čekanja.*, *Ovaj tjedan si u jutarnjoj smjeni…*, *Tri kemijske: plava, crvena i crna.*, '
    '*Dajte mi omotnicu da je izvažem.*, *Mogu li dobiti dopušteno prekoračenje?*, *Ne gasite sami.*',
    '6. Уточнено переклади: *ispit, uplata, isplata, uvjerenje, dozvola* (+ «посвідка»), *obavijest*, *sklonište*. Щоб у вправах «напишіть» '
    'була одна відповідь: *upis* — «зарахування», *izvod* — «виписка», *štedni račun* — «ощадний вклад».',
    '7. Модуль новий, текстів для читання в ньому немає — у перевірці a1-m12 замість читання ще одне завдання на слух. Читання: *dokaz, prijevod* '
    'лишаються «знайомими» (вони у виразах уроку 104), інакше RD-A1-037 мав би 73 %; *bankovni račun, dobiti, kriv, rječnik, slabo, vježba* — рівень знято.',
]


REVIEW_NOTES[13] = [
    '1. Підсумковий модуль (3 уроки, 106–108) — розповідь про себе, перший рік і плани: теперішній, минулий і майбутній час разом. Нових тем граматики немає.',
    '2. Нові слова: *podrijetlo, odrasti, zanimati se, osobina, znatiželjan, komunikativan, pouzdan, samouvjeren, samostalan*; '
    '*doseliti se, nostalgija, volontirati, sjećati se, korak po korak*; *usavršiti*. Решта — з робочої бази (*snaći se, naviknuti se, mentalitet, '
    'zajednica, cilj, napredovati, ostvariti, prednost, nedostatak, izazov*).',
    '3. Діалоги: *Podrijetlom sam iz Ukrajine. Odrasla sam u Poltavi.*, *Po struci sam knjigovođa…*, *Ali korak po korak, snašla sam se.*, '
    '*Iznenadilo me koliko ljudi ovdje imaju vremena za kavu.*, *Nadam se da ću napredovati i postati voditeljica smjene.*',
    '4. Уточнено переклади: *otvoren* (+ «відкритий (про людину)»), *uspjeti* (+ «встигнути»), *napredovati*, *postati*.',
    '5. Фінальна перевірка рівня a1-final — 30 завдань з усіх 13 модулів (кожен — щонайменше 2); середина a1-mid не змінилася. '
    'Читання: *nada, razgovarati, život* більше не в словах уроків (рівень знято).',
]


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    if args == ['structure']:
        STRUCTURE_OUT.write_text(structure_sql(), encoding='utf-8')
        print(f'{STRUCTURE_OUT.relative_to(ROOT)}: {STRUCTURE_OUT.stat().st_size // 1024} КБ; уроків у програмі: {TOTAL}')
        return
    modules = [int(a) for a in args] or sorted(MODULES)
    courses, errors = {}, []
    for module in modules:
        c = build_course(module)
        validate(c, module)
        errors += [f'A1.{module}: {e}' for e in c.errors]
        courses[module] = c
    if errors:
        print('Перевірка не пройдена:', *errors, sep='\n  ', file=sys.stderr)
        sys.exit(1)
    if '--review' in sys.argv:
        for module in modules:
            sys.stdout.write(review(courses[module], module))
        return
    for module in modules:
        sql = build_module(courses[module], module)
        out = module_out(module)
        out.write_text(sql, encoding='utf-8')
        print(f'{out.relative_to(ROOT)}: {len(sql.encode()) // 1024} КБ')


if __name__ == '__main__':
    main()
