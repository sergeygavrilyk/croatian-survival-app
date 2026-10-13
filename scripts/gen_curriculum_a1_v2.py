#!/usr/bin/env python3
"""
Генератор SQL для доповнення A1 (curriculum_a1_v2, 2026-10-13): +40 уроків, 4 файли по 10 уроків.

  python3 scripts/gen_curriculum_a1_v2.py            →  supabase/data_fixes/20261013_curriculum_a1_v2_part1.sql … _part4.sql
  python3 scripts/gen_curriculum_a1_v2.py --review   →  таблиця вправ на слова (для звіту)
  python3 scripts/gen_curriculum_a1_v2.py --stats    →  скільки нових слів в уроках A1

Дані: scripts/curriculum_a1_v2_data.py; переклади слів — scripts/curriculum_a1_v2_snapshot.json (знімок робочої бази)
+ дані й знімок A1 v1 (уроки A1 v1 потрібні для нумерації і хибних варіантів у вправах).

Що робить кожна частина SQL:
  * нові слова й виправлення словника — лише ті, що потрібні урокам цієї частини;
  * 10 уроків (місця 6–9 у юнітах модулів), повна структура: 14 слів, 2 діалоги, граматика, 12 вправ;
  * наскрізна нумерація назв усіх уроків A1 («Урок N»), стара назва — у content_versions;
  * самоперевірка; помилка — і вся частина відкочується.
Частини незалежні одна від одної (потрібна лише програма A1 v1), але запускати краще по черзі 1 → 4.
Файл ≤ ~150 КБ: SQL Editor Supabase не приймає великих запитів.
"""
import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True  # без __pycache__ у репозиторії
sys.path.insert(0, str(Path(__file__).parent))
import curriculum_a1_data as D1  # noqa: E402
import curriculum_a1_v2_data as D  # noqa: E402
from full_lessons import HELPERS_SQL, Course, ordered_places, q, qj, uid  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / 'supabase' / 'data_fixes'
OUT_NAME = '20261013_curriculum_a1_v2_part{}.sql'
HERE = Path(__file__).parent
SNAP1 = json.loads((HERE / 'curriculum_a1_snapshot.json').read_text(encoding='utf-8'))['lexemes']
SNAP2 = json.loads((HERE / 'curriculum_a1_v2_snapshot.json').read_text(encoding='utf-8'))['lexemes']
SOURCE = 'claude_curriculum_a1_v2'
LEVEL = 'A1'
MINUTES = 12
STATUS = 'PUBLISHED'  # бета, як A0 і A1 v1 (рішення власника)
REVIEW_NOTE = 'Бета: доповнення A1 за запитом власника 2026-10-13 (curriculum_a1_v2). Потрібна перевірка носієм.'
SITUATIONS = set(re.findall(r"code: '([a-z_]+)'", (ROOT / 'lib' / 'situations.ts').read_text(encoding='utf-8')))
V1_LAST = uid('lesson', LEVEL, 10, 5)  # останній урок A1 v1 — ознака, що v1 застосовано

errors: list[str] = []


def base_order(key) -> tuple[int, int]:
    if isinstance(key, int):
        return (key - 1) // 3 + 1, (key - 1) % 3 + 1
    m, o = key.split('.')
    return int(m), int(o)


# ---------------------------------------------------------------- переклади: v1 → v2 (пізніше перекриває раніше)
LEX: dict[str, tuple[str, str]] = {k: (v[0], v[1]) for k, v in SNAP1.items()}
for lex in D1.NEW_LEXEMES:
    LEX[lex[0].lower()] = (lex[0], lex[2])
for low, (old, new) in D1.TRANSLATION_FIXES.items():
    if low in LEX and LEX[low][1] == old:
        LEX[low] = (LEX[low][0], new)
for low, (old, new) in D1.LEMMA_FIXES.items():
    if low in LEX and LEX[low][0] == old:
        LEX[low] = (new, LEX[low][1])
for k, v in SNAP2.items():
    LEX[k] = (v[0], v[1])
NEW = {lex[0].lower(): lex for lex in D.NEW_LEXEMES}
for low, lex in NEW.items():
    LEX[low] = (lex[0], lex[2])
for low, (old, new) in D.TRANSLATION_FIXES.items():
    if low in LEX and LEX[low][1] == old:
        LEX[low] = (LEX[low][0], new)
for low, (old, new) in D.LEMMA_FIXES.items():
    if low in LEX and LEX[low][0] == old:
        LEX[low] = (new, LEX[low][1])

ALL_LESSONS = {**D1.LESSONS, **D.LESSONS}
PLACES = ordered_places(ALL_LESSONS, base_order)
KEYS = [k for k in PLACES if k in D.LESSONS]  # нові уроки в порядку програми
C = Course(level=LEVEL, lessons=ALL_LESSONS, place=PLACES, lex=LEX, situations=SITUATIONS,
           grammar_keys=set(D1.GRAMMAR_A1), seed_prefix='a1', no_vocab=D.NO_VOCAB_EXERCISE,
           words_range=(12, 14), errors=errors)


def v1_words() -> set[str]:
    return {w.lower() for L in D1.LESSONS.values() for w in L['words']}


def validate():
    parts_flat = [k for p in D.PARTS for k in p]
    if sorted(parts_flat) != sorted(D.LESSONS) or len(parts_flat) != len(set(parts_flat)):
        errors.append('PARTS: кожен новий урок має бути рівно в одній частині')
    if parts_flat != KEYS:
        errors.append('PARTS: уроки мають іти в порядку програми')
    for m in range(1, 11):
        orders = sorted(p.order for p in PLACES.values() if p.module == m)
        if orders != list(range(1, len(orders) + 1)):
            errors.append(f'A1.{m}: місця уроків {orders} мають іти підряд')
    for key in D.LESSONS:
        if base_order(key) in {base_order(k) for k in D1.LESSONS}:
            errors.append(f'{key}: це місце вже зайняте уроком A1 v1')
    old = v1_words()
    seen: dict[str, str] = {}
    for key in KEYS:
        C.validate_lesson(key)
        for w in D.LESSONS[key]['words']:
            if w.lower() in old:
                errors.append(f'{C.name(key)}: «{w}» уже є в уроках A1 v1 — потрібні нові слова')
            if w.lower() in seen:
                errors.append(f'{C.name(key)}: «{w}» уже є в уроці {seen[w.lower()]}')
            seen[w.lower()] = key
    for lemma, norm, ua, pos, vtype, forms, example in D.NEW_LEXEMES:
        w = f'lexeme {lemma}'
        C.check_hr(lemma, w)
        C.check_ua(ua, w)
        C.check_hr(example, w)
        if vtype not in ('core', 'function_word', 'formulaic', 'collocation', 'chunk'):
            errors.append(f'{w}: vocabulary_type {vtype!r}')
        if lemma.lower() in SNAP2 or lemma.lower() in SNAP1 or lemma.lower() in {x[0].lower() for x in D1.NEW_LEXEMES}:
            errors.append(f'{w}: уже є в базі (знімок) — не додаємо вдруге')
        if lemma.lower() not in seen:
            errors.append(f'{w}: нове слово не використано в жодному уроці')
        if not example.strip().endswith(('.', '!', '?')):
            errors.append(f'{w}: приклад має бути реченням: {example!r}')
    if len(NEW) != len(D.NEW_LEXEMES):
        errors.append('NEW_LEXEMES: леми повторюються')
    for low, (old_t, new_t) in D.TRANSLATION_FIXES.items():
        if SNAP2.get(low, [None, None])[1] != old_t:
            errors.append(f'виправлення перекладу {low}: у знімку не {old_t!r}')
        C.check_ua(new_t, f'виправлення {low}')
    for low, (old_l, new_l) in D.LEMMA_FIXES.items():
        if SNAP2.get(low, [None])[0] != old_l:
            errors.append(f'виправлення леми {low}: у знімку не {old_l!r}')
        if new_l.lower() != low or old_l.lower() != low:
            errors.append(f'виправлення леми {low}: можна міняти лише регістр')


# ---------------------------------------------------------------- SQL
def fix_block(where: str, set_sql: str, note: str) -> str:
    return f"""do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where {where};
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, {q(note)});
  update public.lexemes set {set_sql} where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(note)});
end $$;"""


def part_words(keys) -> set[str]:
    return {w.lower() for k in keys for w in D.LESSONS[k]['words']}


def lexemes_sql(out: list[str], keys):
    words = part_words(keys)
    rows = [lex for lex in D.NEW_LEXEMES if lex[0].lower() in words]
    out.append(f'-- 1. Нові слова ({len(rows)}), яких ще немає у словнику')
    for lemma, norm, ua, pos, vtype, forms, example in rows:
        out.append(
            'insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)\n'
            f"values ({q(lemma)}, {q(norm)}, 'hr', {q(pos)}, {q(LEVEL)}, {q(ua)}, {q(vtype)}, {qj(forms)}, {qj([example])}, 'PUBLISHED', {q(SOURCE)})\n"
            'on conflict do nothing;'
        )
    out.append('')
    return len(rows)


def fixes_sql(out: list[str], keys) -> int:
    words = part_words(keys)
    n = 0
    out.append('-- 2. Виправлення словника для слів цих уроків (стара версія — у content_versions)')
    for low, (old, new) in D.TRANSLATION_FIXES.items():
        if low in words:
            n += 1
            out.append(fix_block(f'lower(lemma) = lower({q(low)}) and ukrainian_translation = {q(old)}',
                                 f'ukrainian_translation = {q(new)}', f'curriculum_a1_v2: переклад «{old}» → «{new}»'))
    for low, (old, new) in D.LEMMA_FIXES.items():
        if low in words:
            n += 1
            out.append(fix_block(f'lemma = {q(old)}', f'lemma = {q(new)}', f'curriculum_a1_v2: лема «{old}» → «{new}»'))
    out.append('')
    return n


def lesson_sql(out: list[str], key):
    gid = uid('grammar', LEVEL, D1.GRAMMAR_A1[D.LESSONS[key]['grammar']]['skeleton'])
    out.extend(C.lesson_sql(key, status=STATUS, source=SOURCE, note=REVIEW_NOTE, minutes=MINUTES,
                            grammar_lookup=f'select id into v_gid from public.grammar_topics where id = {q(gid)};', compact=True))


RENUMBER_SQL = """-- 4. Наскрізні номери всіх уроків A1 («Урок N: …» / «Lekcija N: …») за модулем і місцем; стара назва — у content_versions
do $$
declare r record; v_payload jsonb; v_ua text; v_hr text;
begin
  for r in
    select l.id, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where m.level_code = 'A1' and l.status <> 'DEPRECATED'
  loop
    select to_jsonb(l), regexp_replace(l.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':'),
           regexp_replace(l.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':')
      into v_payload, v_ua, v_hr
      from public.lessons l where l.id = r.id;
    if v_ua is not distinct from (v_payload->>'title_ua') and v_hr is not distinct from (v_payload->>'title_hr') then continue; end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'curriculum_a1_v2: новий номер уроку ' || r.n);
    update public.lessons set title_ua = v_ua, title_hr = v_hr where id = r.id;
  end loop;
end $$;
"""


def build_part(pi: int, keys: list) -> str:
    n_turns = sum(len(t) for k in keys for _, _, t in D.LESSONS[k]['scenes'])
    first, last = PLACES[keys[0]], PLACES[keys[-1]]
    modules = sorted({PLACES[k].module for k in keys})
    body: list[str] = []
    n_lex = lexemes_sql(body, keys)
    n_fix = fixes_sql(body, keys)
    body.append('-- 3. Уроки')
    for key in keys:
        lesson_sql(body, key)
    body.append(RENUMBER_SQL)
    ids = ', '.join(q(uid('lesson', LEVEL, PLACES[k].module, PLACES[k].order)) for k in keys)
    titles = '; '.join(f"A1.{PLACES[k].module} «{D.LESSONS[k]['title'][0]}»" for k in keys)
    head = [
        '-- =====================================================================',
        f'-- Доповнення A1 · curriculum_a1_v2 · частина {pi} з {len(D.PARTS)} · 2026-10-13',
        '-- Згенеровано: python3 scripts/gen_curriculum_a1_v2.py (не редагуйте вручну).',
        '-- Запуск: Supabase → SQL Editor → вставити ВЕСЬ файл → Run. Частини запускайте по черзі (1 → 4).',
        '--',
        f'--   * {len(keys)} нових уроків (модулі A1.{modules[0]}–A1.{modules[-1]}), у плані програми № {first.number}–{last.number}:',
        *[f'--       {x}' for x in titles.split('; ')],
        f'--   * У кожному 14 нових слів, 2 діалоги ({n_turns} реплік разом), граматика, 12 вправ, ~{MINUTES} хв.',
        f'--   * Нові слова у словнику: {n_lex}. Виправлення словника: {n_fix} (стара версія — у content_versions).',
        '--   * Назви всіх уроків A1 перенумеровано підряд («Урок N»); старі назви — у content_versions.',
        f'--   * Статус {STATUS}: бета, як решта A1 (носій ще не перевіряв). Наявні дані не видаляються.',
        '--   * Потрібна програма A1 v1 (20261013_curriculum_a1_v1_part1.sql і _part2.sql). Повторний запуск безпечний.',
        '-- =====================================================================',
        '',
        'begin;',
        '',
        f"""do $$
begin
  if not exists (select 1 from public.lessons where id = {q(V1_LAST)} and status = 'PUBLISHED') then
    raise exception 'Спершу запустіть програму A1 v1 (20261013_curriculum_a1_v1_part1.sql і _part2.sql)';
  end if;
  if not exists (select 1 from pg_constraint where conname = 'exercises_type_check'
                 and pg_get_constraintdef(oid) like '%speaking%') then
    raise exception 'Спершу запустіть міграцію M13 (20261013140000_m13_exercise_types.sql)';
  end if;
end $$;
""",
        HELPERS_SQL,
    ]
    tail = f"""-- 5. Самоперевірка частини {pi}: якщо щось не так — уся частина відкочується
do $$
declare v_new int; v_short int; v_scenes int; v_words int; v_total int; v_bad_titles int;
begin
  select count(*) into v_new from public.lessons where id in ({ids}) and status = '{STATUS}';
  select count(*) into v_short from public.lessons l where l.id in ({ids})
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') < 12;
  select count(*) into v_scenes from public.lessons l where l.id in ({ids})
     and (select count(*) from public.conversations c where c.lesson_id = l.id) < 2;
  select count(*) into v_words from public.lessons l where l.id in ({ids})
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'lexeme') < 12;
  select count(*) into v_total from public.lessons where level_code = '{LEVEL}' and status = '{STATUS}';
  select count(*) into v_bad_titles from (
    select l.title_ua, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where m.level_code = '{LEVEL}' and l.status <> 'DEPRECATED') t
   where t.title_ua not like 'Урок ' || t.n || ':%';
  if v_new <> {len(keys)} then raise exception 'Частина {pi}: створено % уроків з {len(keys)}', v_new; end if;
  if v_short > 0 then raise exception 'Частина {pi}: % уроків мають менше 12 вправ', v_short; end if;
  if v_scenes > 0 then raise exception 'Частина {pi}: % уроків без двох діалогів', v_scenes; end if;
  if v_words > 0 then raise exception 'Частина {pi}: % уроків мають менше 12 слів', v_words; end if;
  if v_bad_titles > 0 then raise exception 'Частина {pi}: % назв уроків A1 не за порядком', v_bad_titles; end if;
  raise notice 'Готово: частина {pi} — {len(keys)} нових уроків; усього уроків A1 — %', v_total;
end $$;

commit;
"""
    return '\n'.join(head + body) + '\n' + tail


def stats() -> str:
    a1 = {w.lower() for L in ALL_LESSONS.values() for w in L['words']}
    new = part_words(KEYS)
    return (f'уроків A1: {len(ALL_LESSONS)} (нових {len(KEYS)}); різних слів в уроках A1: {len(a1)}; '
            f'нових слів у доповненні: {len(new)}; нових лексем у словнику: {len(D.NEW_LEXEMES)}')


def review_table() -> str:
    return '| Урок | Тип | Завдання | Відповідь | Варіанти |\n|---|---|---|---|---|\n' + '\n'.join(C.review_rows(KEYS))


if __name__ == '__main__':
    validate()
    if errors:
        print('ПОМИЛКИ В ДАНИХ:', *errors, sep='\n  ')
        sys.exit(1)
    parts = [build_part(i, keys) for i, keys in enumerate(D.PARTS, 1)]
    if errors:
        print('ПОМИЛКИ В ДАНИХ:', *errors, sep='\n  ')
        sys.exit(1)
    if '--review' in sys.argv:
        print(review_table())
        sys.exit(0)
    if '--stats' in sys.argv:
        print(stats())
        sys.exit(0)
    for i, sql in enumerate(parts, 1):
        (OUT_DIR / OUT_NAME.format(i)).write_text(sql, encoding='utf-8')
        print(f'OK → supabase/data_fixes/{OUT_NAME.format(i)}: {len(sql.encode()) // 1024} КБ')
