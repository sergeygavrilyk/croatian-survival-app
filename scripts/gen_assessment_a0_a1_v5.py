#!/usr/bin/env python3
"""
Перевірки рівня A0 і A1 за новою схемою (рішення власника 2026-11-07; зразок — A2 v2, scripts/gen_assessment_a2_v2.py).

  python3 -B scripts/gen_assessment_a0_a1_v5.py            →  supabase/data_fixes/20261116_assessments_a0_v5.sql,
                                                              20261116_assessments_a1_v5_part1.sql, …_part2.sql
  python3 -B scripts/gen_assessment_a0_a1_v5.py --check    →  лише перевірка (нічого не пише)
  python3 -B scripts/gen_assessment_a0_a1_v5.py --report   →  content/reviews/2026-11-16_assessments_a0_a1_v5.md (для носія)

Схема 2026-11-07: модуль — 2 завдання на урок, від 12 до 20; середина рівня — 30 (A0 — після A0.5, A1 — після A1.6);
фінал — 48; у середині й фіналі кожен модуль — щонайменше 2 завдання. 4 навички §60 у тих самих частках, що в A2 v2.
Було: модуль — 10, середина — 20, фінал — 30 (схема 2026-10-15).

Джерела: знімок опублікованих уроків і текстів A0 / A1 — scripts/assessment_a0_a1_v5_snapshot.json (запит —
scripts/assessment_v5_source.sql; зроблено з локальної бази curdb.sh, збіг з робочою базою перевірено хешами реплік,
вправ «напишіть / складіть / скажіть» і текстів 2026-11-16). Нових хорватських речень генератор не пише: завдання
складаються з реплік діалогів, вправ уроків і текстів для читання, як у gen_assessment.py.
Середина й фінал — без джерел і речень тестів модулів (як A2 v2).
«Складіть»: інші правильні порядки слів — scripts/sentence_order_alternatives.py (колонка answer_alternatives, M27).

SQL (нічого не видаляє): стара версія завдань — у content_versions; старі завдання → DEPRECATED (місця зсуваються за
найбільше наявне, щоб звільнити 1…N); нові — PUBLISHED (бета); опис і хвилини тесту оновлюються; запис у content_reviews.
Повторний запуск нічого не змінює (оновлений тест пропускається). Спроби й результати користувачів не змінюються.
"""
from __future__ import annotations

import json
import random
import sys
from collections import Counter
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
import gen_assessment as A  # noqa: E402
from sentence_order_alternatives import ALTERNATIVES, check_alternatives  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
SNAPSHOT = ROOT / 'scripts' / 'assessment_a0_a1_v5_snapshot.json'
DATE = '20261116'
VER = 'v5'
SOURCE = 'claude_assessment_v5'
NOTE = 'Бета: перевірки рівня {lv} за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків {lv}. Потрібна перевірка носієм.'
VERSION_NOTE = 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання'
LEVELS = {'A0': {'mid_after': 5}, 'A1': {'mid_after': 6}}

# Частки навичок як у A2 v2 (розумію ~30 %, спілкуюся ~20–25 %, переказую ~20–25 %, кажу ~25–30 %)
MODULE_PLANS = {
    12: [('listen', 2), ('read', 1), ('reply', 3), ('relay', 2), ('ua2hr', 1), ('type', 1), ('build', 1), ('speak', 1)],
    14: [('listen', 3), ('read', 1), ('reply', 3), ('relay', 2), ('ua2hr', 2), ('type', 1), ('build', 1), ('speak', 1)],
    16: [('listen', 3), ('read', 2), ('reply', 3), ('relay', 2), ('ua2hr', 2), ('type', 1), ('build', 2), ('speak', 1)],
    18: [('listen', 3), ('read', 2), ('reply', 4), ('relay', 2), ('ua2hr', 2), ('type', 2), ('build', 2), ('speak', 1)],
    20: [('listen', 3), ('read', 2), ('reply', 4), ('relay', 3), ('ua2hr', 2), ('type', 2), ('build', 3), ('speak', 1)],
}
LEVEL_PLANS = {
    'mid': [('listen', 5), ('read', 3), ('reply', 7), ('relay', 4), ('ua2hr', 3), ('type', 3), ('build', 3), ('speak', 2)],
    'final': [('listen', 8), ('read', 5), ('reply', 11), ('relay', 6), ('ua2hr', 5), ('type', 5), ('build', 5), ('speak', 3)],
}
MINUTES = {'mid': 15, 'final': 25}
# Частина SQL ≤ ~300 КБ (content-sql-pack): A1 — двома файлами
PARTS = {'A0': [None], 'A1': [range(1, 8), None]}  # None — решта (і середина з фіналом)

# Репліки, що повторюють слово, яке пояснюють («Naravno. Hvala!» — «Звісно. „Hvala“!»), — як у gen_assessment_a0_v4.py
META_REPLIES = {'naravno hvala'}
_generic = A.generic
A.generic = lambda s: _generic(s) or A.norm(s) in META_REPLIES


def load() -> dict[str, dict]:
    data = json.loads(SNAPSHOT.read_text(encoding='utf-8'))
    return {L['level']: L for L in data['levels']}


LEVEL_DATA = load()


def level(lv: str, upto: int) -> dict:
    """Модулі 1…upto: з них і завдання, і хибні варіанти (учень пізніших ще не бачив)."""
    mods = [m for m in LEVEL_DATA[lv]['modules'] if m['order'] <= upto]
    return {'level': lv, 'modules': json.loads(json.dumps(mods))}


def module_count(lv: str) -> int:
    return len(LEVEL_DATA[lv]['modules'])


def lessons_in(lv: str, m: int) -> int:
    return len(next(x for x in LEVEL_DATA[lv]['modules'] if x['order'] == m)['lessons'])


def n_items(lv: str, m: int) -> int:
    return max(12, min(20, 2 * lessons_in(lv, m)))


def module_plan(pools, lv: str, m: int) -> list[tuple[str, int]]:
    plan = list(MODULE_PLANS[n_items(lv, m)])
    if not pools.by_module[m]['read']:  # модуль без текстів — замість «прочитай» ще «на слух» (та сама навичка)
        n = dict(plan)['read']
        plan = [(k, c + n if k == 'listen' else c) for k, c in plan if k != 'read']
    return plan


def dedupe_ok(items: list[dict], slug: str) -> bool:
    """Чи вдасться прибрати повтори хибних варіантів (A.dedupe_options) — інакше беремо інше зерно."""
    trial = {'slug': slug, 'items': [dict(it, options=list(it['options']), order=i) for i, it in enumerate(items, 1)]}
    try:
        A.dedupe_options(trial)
    except SystemExit:
        return False
    return True


def module_test(lv: str, m: int, used: set | None = None) -> tuple[list[dict], list]:
    """Тест модуля: завдання — лише з модуля m; хибні варіанти «Спілкуюся» — з інших модулів 1…upto.
    upto = max(m, 2), а якщо там замало різних відповідей для хибних варіантів (A0.1–A0.2: 4 і 9 уроків) — ще наступний модуль
    (незнайома репліка як хибний варіант не робить завдання важчим)."""
    slug = f'{lv.lower()}-m{m:02d}'
    for upto in range(max(m, 2), module_count(lv) + 1):
        pools = A.Pools(level(lv, upto))
        plan = module_plan(pools, lv, m)
        best = None
        for attempt in range(40):  # перше зерно — slug; інші — лише якщо є «жорсткий» збіг речень чи повтор хибних варіантів
            trial = set(used) if used is not None else set()
            try:
                items = A.fill_test(pools, trial, plan, [m], slug, seed=slug if attempt == 0 else f'{slug}:{attempt}')
            except SystemExit:
                continue
            hard, soft = clashes(items)
            if hard == 0 and dedupe_ok(items, slug) and (best is None or soft < best[0]):
                best = (soft, items, trial)
                if soft == 0:
                    break
        if best is not None:
            if used is not None:
                used |= best[2]
            return best[1], plan
    raise SystemExit(f'{slug}: не вдалося скласти тест без повторів речень')


# ---------------------------------------------------------------- повтори речень між завданнями (як gen_assessment_a1_v3)
import re  # noqa: E402


def split(texts: list[str]) -> list[str]:
    out = []
    for t in texts:
        out += [A.norm(x) for x in re.split(r'(?<=[.!?…])\s+', t.strip()) if A.nwords(x) >= 3]
    return out


def key_lines(it: dict) -> list[str]:
    out = [it[f] for f in ('audio_hr', 'answer_text') if it.get(f)]
    if it.get('prompt_hr') and it['kind'] != 'read':
        out.append(it['prompt_hr'])
    if it['kind'] in ('reply', 'ua2hr'):
        out.append(it['options'][it['correct_index']])
    if it['kind'] == 'relay':
        lines = [line.split(': ', 1)[-1] for line in it['passage_hr'].split('\n')]
        out += [lines[i + 1] for i, line in enumerate(lines[:-1]) if A.norm(line) == A.norm(it['prompt_hr'])][:1]
    return split(out)


def shown(it: dict) -> list[str]:
    out = list(key_lines(it))
    if it['kind'] in ('reply', 'ua2hr'):
        out += split(it['options'])
    if it['kind'] == 'relay':
        out += split([line.split(': ', 1)[-1] for line in it['passage_hr'].split('\n')])
    return out


def clashes(items: list[dict]) -> tuple[int, int]:
    """hard — відповідь одного завдання видно в іншому; soft — два завдання показують одне речення."""
    sets = [(set(key_lines(it)), set(shown(it))) for it in items]
    hard = soft = 0
    for i, (kx, sx) in enumerate(sets):
        for ky, sy in sets[i + 1:]:
            if (kx & sy) or (ky & sx):
                hard += 1
            elif sx & sy:
                soft += 1
    return hard, soft


def prune(pools, seen: set[str]) -> None:
    def hit(x: dict) -> bool:
        texts = [x[f] for f in ('hr', 'prompt_hr', 'q_hr') if x.get(f)] + [t['hr'] for t in x.get('turns', [])]
        return any(t in seen for t in split(texts))
    for pm in pools.by_module.values():
        for kind, lst in pm.items():
            pm[kind] = [x for x in lst if not hit(x)]


def same_pair(used: set) -> set:
    """Репліка-відповідь з «Переказую» (r) не повторюється як «Спілкуюся» / «на слух» (s), і навпаки."""
    return used | {(('s' if k[0] == 'r' else 'r'),) + k[1:] for k in used if k[0] in ('r', 's')}


def fill_balanced(pools, used: set, kind_plan, mods: list[int], slug: str, seed: str) -> list[dict]:
    """Як у gen_assessment_a2_v2.fill_balanced: завдання — з модуля, де їх поки найменше; нове завдання одразу
    перевіряється на «жорсткий» збіг з уже вибраними."""
    rng = random.Random(seed)
    items, in_test, keys, shows = [], set(), set(), set()
    per: Counter = Counter()
    scarce = ['relay', 'reply', 'read', 'ua2hr', 'speak', 'build', 'type', 'listen']
    for kind, count in sorted(kind_plan, key=lambda kc: scarce.index(kc[0])):
        got = 0
        for _ in range(400):
            if got >= count:
                break
            for mo in sorted(mods, key=lambda m: (per[m], rng.random())):
                pool = [x for x in pools.by_module[mo][kind] if x['key'] not in used and x['key'][1:] not in in_test]
                rng.shuffle(pool)
                item = None
                for src in pool[:12]:
                    cand = A.make_item(kind, src, pools, mo, rng)
                    if cand is None:
                        continue
                    k, sh = set(key_lines(cand)), set(shown(cand))
                    if k & shows or keys & sh:
                        continue
                    item = cand
                    break
                if item is None:
                    continue
                used.add(src['key'])
                in_test.add(src['key'][1:])
                keys |= k
                shows |= sh
                item['module'] = mo
                items.append(item)
                per[mo] += 1
                got += 1
                break
        if got < count:
            raise SystemExit(f'{slug}: замало джерел для «{kind}» ({got} з {count})')
    display = [k for k, _ in kind_plan]
    return sorted(items, key=lambda it: display.index(it['kind']))


# ---------------------------------------------------------------- тести рівня
def module_tests(lv: str) -> list[dict]:
    out = []
    for m in range(1, module_count(lv) + 1):
        slug = f'{lv.lower()}-m{m:02d}'
        items, plan = module_test(lv, m)
        A.PLAN[slug] = plan
        for it in items:
            it['module'] = m
        out.append({'slug': slug, 'kind': slug, 'db_kind': 'module', 'module': m, 'title_ua': f'Перевірка модуля {lv}.{m}',
                    'items': items})
    return out


def module_tests_used(lv: str, upto: int) -> tuple[set, set[str]]:
    used_all: set = set()
    seen: set[str] = set()
    for m in range(1, upto + 1):
        used: set = set()
        items, _ = module_test(lv, m, used)
        used_all |= used
        seen |= {x for it in items for x in shown(it)}
    return same_pair(used_all), seen


def level_tests(lv: str) -> list[dict]:
    out = []
    used, seen = set(), set()
    n = module_count(lv)
    for kind, upto in (('mid', LEVELS[lv]['mid_after']), ('final', n)):
        slug = f'{lv.lower()}-{kind}'
        A.PLAN[slug] = LEVEL_PLANS[kind]
        mu, ms = module_tests_used(lv, upto)
        used, seen = used | mu, seen | ms
        pools = A.Pools(level(lv, upto))
        prune(pools, seen)
        mods = sorted(pools.by_module)
        best = None
        for attempt in range(80):
            trial = set(used)
            try:
                items = fill_balanced(pools, trial, LEVEL_PLANS[kind], mods, slug, seed=slug if attempt == 0 else f'{slug}:{attempt}')
            except SystemExit:
                continue
            per = Counter(it['module'] for it in items)
            hard, soft = clashes(items)
            if all(per[m] >= 2 for m in mods) and hard == 0 and dedupe_ok(items, slug) and (best is None or soft < best[0]):
                best = (soft, items, trial)
                if soft == 0:
                    break
        if best is None:
            raise SystemExit(f'{slug}: не вдалося покрити всі модулі без повторів')
        soft, items, trial = best
        used = same_pair(trial)
        seen |= {x for it in items for x in shown(it)}
        title = f'Перевірка середини рівня {lv}' if kind == 'mid' else f'Фінальна перевірка рівня {lv}'
        out.append({'slug': slug, 'kind': slug, 'db_kind': kind, 'module': None, 'upto': upto, 'title_ua': title, 'items': items})
    return out


def with_alternatives(tests: list[dict]) -> list[dict]:
    for t in tests:
        for it in t['items']:
            it['answer_alternatives'] = list(ALTERNATIVES.get(it['answer_text'], [])) if it['item_type'] == 'sentence_builder' else []
    return tests


_CACHE: dict[str, list[dict]] = {}


def tests(lv: str) -> list[dict]:
    if lv not in _CACHE:
        ts = module_tests(lv) + level_tests(lv)
        for t in ts:
            for i, it in enumerate(t['items'], 1):
                it['order'] = i
                it['id'] = A.uid('assessment', t['slug'], VER, 'item', i)
        ts = A.finalize(ts, lv)  # хибні варіанти не повторюються в тесті (2026-11-03)
        _CACHE[lv] = with_alternatives(ts)
    return _CACHE[lv]


def description(lv: str, t: dict) -> tuple[str, int]:
    n = len(t['items'])
    if t['db_kind'] == 'module':
        minutes = max(6, n // 2)
        return f'Після модуля: {n} завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~{minutes} хв.', minutes
    if t['db_kind'] == 'mid':
        return f'Середина рівня (модулі {lv}.1–{lv}.{t["upto"]}): {n} завдань на 4 навички. ~{MINUTES["mid"]} хв.', MINUTES['mid']
    return f'Кінець рівня (усі {t["upto"]} модулів {lv}): {n} завдань на 4 навички. ~{MINUTES["final"]} хв.', MINUTES['final']


def check(lv: str) -> list[str]:
    """Перевірки поверх A.validate: кількості за схемою, покриття модулів, альтернативи «Складіть»."""
    problems = []
    ts = tests(lv)
    n = module_count(lv)
    for t in ts:
        want = n_items(lv, t['module']) if t['db_kind'] == 'module' else (30 if t['db_kind'] == 'mid' else 48)
        if len(t['items']) != want:
            problems.append(f"{t['slug']}: {len(t['items'])} завдань, а за схемою {want}")
        if len(t['items']) > 60:
            problems.append(f"{t['slug']}: більше 60 завдань (MAX_ITEMS у app/actions/assessment.ts)")
        if t['db_kind'] != 'module':
            per = Counter(it['module'] for it in t['items'])
            short = [m for m in range(1, t['upto'] + 1) if per[m] < 2]
            if short:
                problems.append(f"{t['slug']}: модулі з < 2 завдань: {short}")
    slugs = [t['slug'] for t in ts]
    if len(ts) != n + 2 or len(set(slugs)) != len(slugs):
        problems.append(f'{lv}: тестів {len(ts)}, очікувалось {n + 2}')
    builds = [it for t in ts for it in t['items'] if it['item_type'] == 'sentence_builder']
    problems += check_alternatives(it['answer_text'] for it in builds)
    return problems


# ---------------------------------------------------------------- SQL
def item_row(lv: str, it: dict) -> str:
    q, qj = A.q, A.qj
    lesson_sql = f"(select id from public.lessons where id = {q(it['lesson'])})" if it['lesson'] else 'null'
    alts = 'array[' + ', '.join(q(a) for a in it['answer_alternatives']) + ']::text[]' if it['answer_alternatives'] else "'{}'::text[]"
    return (f"  ({q(it['id'])}, v_aid, {it['order']}, {q(lv)}, {q(it['skill'])}, {q(it['area'])}, {q(it['item_type'])}, "
            f"{q(it['prompt_ua'])}, {q(it['prompt_hr'])}, {qj(it['options'])}, "
            f"{it['correct_index'] if it['correct_index'] is not None else 'null'}, {q(it['answer_text'])}, {alts}, "
            f"{q(it['audio_hr'])}, {q(it['passage_hr'])}, {q(it['passage_ua'])}, {q(it['explanation_ua'])}, {lesson_sql}, "
            f"{q(A.STATUS)}, {q(SOURCE)})")


def test_block(lv: str, t: dict) -> str:
    q = A.q
    desc, minutes = description(lv, t)
    rows = ',\n'.join(item_row(lv, it) for it in t['items'])
    mod = next((m for m in LEVEL_DATA[lv]['modules'] if m['order'] == t['module']), None)
    mod_check = (f"""  if (select module_id from public.assessments where id = v_aid) is distinct from {q(mod['id'])}::uuid then
    raise exception 'Тест {t['slug']} прив’язаний не до модуля {lv}.{t['module']} — звірте базу';
  end if;
""" if mod else '')
    return f"""-- {t['title_ua']}{' · ' + mod['title_ua'] if mod else ''} · {len(t['items'])} завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = {q(t['slug'])} and cefr = {q(lv)};
  if v_aid is null then raise exception 'Немає тесту {t['slug']} — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = {q(t['items'][0]['id'])}) then return; end if;  -- уже оновлено
{mod_check}  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, {q(VERSION_NOTE)});
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = {q(desc)}, estimated_minutes = {minutes} where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
{rows};
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, {q(NOTE.format(lv=lv))});
end $$;
"""


def build_part(lv: str, ts: list[dict], part: int, parts: int) -> str:
    q = A.q
    total = sum(len(t['items']) for t in ts)
    sizes = ', '.join(f"{t['slug']} — {len(t['items'])}" for t in ts)
    ids = ', '.join(q(it['id']) for t in ts for it in t['items'])
    expected = ', '.join(f"({q(t['slug'])}, {len(t['items'])})" for t in ts)
    part_note = f' · частина {part} з {parts}' if parts > 1 else ''
    fname = out_path(lv, part, parts).name
    head = f"""-- =====================================================================
-- Перевірки рівня {lv} за схемою 2026-11-07{part_note} · 2026-11-16
-- Згенеровано: python3 -B scripts/gen_assessment_a0_a1_v5.py (не редагуйте вручну).
--
-- Схема (рішення власника 2026-11-07): модуль — 2 завдання на урок (12–20), середина — 30, фінал — 48.
-- Було: модуль — 10, середина — 20, фінал — 30. У цьому файлі {total} нових завдань:
--   {sizes}.
--   * Завдання — з діалогів, вправ і текстів для читання уроків {lv}; нових хорватських речень немає. 4 навички §60.
--   * «Складіть» — з іншими правильними порядками слів (answer_alternatives), де вони є. Потрібна міграція M27.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються). Нові — PUBLISHED (бета).
--   * Спроби й результати користувачів не змінюються. Повторний запуск нічого не змінює.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення:
--   «Готово: {fname} — {len(ts)} тестів, {total} нових завдань».
-- =====================================================================

begin;
"""
    body = '\n'.join(test_block(lv, t) for t in ts)
    tail = f"""
-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ({ids}) and status = 'PUBLISHED';
  select count(*) into v_bad from (values {expected}) e(slug, n) left join public.assessments a on a.slug = e.slug and a.cefr = {q(lv)} and a.status = 'PUBLISHED'
   where a.id is null
      or (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> e.n
      or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ({ids}));
  if v_new <> {total} or v_bad > 0 then raise exception 'Перевірки {lv}: нових завдань % (очікувалось {total}), тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: {fname} — {len(ts)} тестів, % нових завдань', v_new;
end $$;

commit;
"""
    return head + body + tail


def out_path(lv: str, part: int, parts: int) -> Path:
    suffix = f'_part{part}' if parts > 1 else ''
    return ROOT / 'supabase' / 'data_fixes' / f'{DATE}_assessments_{lv.lower()}_{VER}{suffix}.sql'


def split_parts(lv: str) -> list[list[dict]]:
    ts = tests(lv)
    spec = PARTS[lv]
    out, rest = [], list(ts)
    for rng in spec:
        if rng is None:
            out.append(rest)
            break
        chunk = [t for t in rest if t['module'] in rng]
        rest = [t for t in rest if t not in chunk]
        out.append(chunk)
    return out


def report() -> str:
    lines = ['# Перевірки рівня A0 і A1 за схемою 2026-11-07 — звіт для носія', '',
             '> Згенеровано `scripts/gen_assessment_a0_a1_v5.py --report` 2026-11-16. Бета: завдання з діалогів, вправ і текстів уроків;',
             '> нових хорватських речень немає. Нове — лише поєднання (хибні варіанти) і **інші порядки слів у «Складіть»**.', '',
             '## Що варто глянути носію', '',
             '1. **«Складіть речення»** — чи правильні записані «інші порядки» і чи немає ще одного природного порядку (повний список — `content/reviews/2026-11-16_sentence_orders.md`).',
             '2. **«Спілкуюся»** — чи не підходить одна з «неправильних» відповідей теж.',
             '3. **«Переказую»** — чи точний переклад відповіді з діалогу.', '',
             '## Склад', '', '| Тест | Завдань | Розумію | Спілкуюся | Переказую | Кажу |', '|---|---|---|---|---|---|']
    for lv in LEVELS:
        for t in tests(lv):
            c = Counter(it['area'] for it in t['items'])
            lines.append(f"| `{t['slug']}` {t['title_ua']} | {len(t['items'])} | {c['understand']} | {c['interact']} | {c['mediate']} | {c['produce']} |")
    lines.append('')
    for lv in LEVELS:
        for t in tests(lv):
            lines += [f"## `{t['slug']}` {t['title_ua']} ({len(t['items'])})", '', '| # | Навичка | Завдання | Відповідь | Модуль |', '|---|---|---|---|---|']
            for it in t['items']:
                prompt = it['prompt_ua'] + (f" *{it['prompt_hr']}*" if it['prompt_hr'] and it['kind'] != 'read' else '')
                if it['audio_hr'] and it['kind'] == 'listen':
                    prompt += f" 🔊 *{it['audio_hr']}*"
                ans = it['options'][it['correct_index']] if it['correct_index'] is not None else it['answer_text']
                if it['answer_alternatives']:
                    ans += ' (також: ' + ' · '.join(it['answer_alternatives']) + ')'
                lines.append(f"| {it['order']} | {A.KIND_UA[it['kind']]} | {prompt.replace(chr(10), ' ').replace('|', '/')} | {ans} | {lv}.{it['module']} |")
            lines.append('')
    return '\n'.join(lines) + '\n'


def main():
    problems = [p for lv in LEVELS for p in check(lv)]
    if problems:
        raise SystemExit('Перевірка не пройдена:\n' + '\n'.join(problems))
    if '--check' in sys.argv:
        for lv in LEVELS:
            ts = tests(lv)
            print(lv, sum(len(t['items']) for t in ts), 'завдань:', ', '.join(f"{t['slug']} {len(t['items'])}" for t in ts))
        return
    if '--report' in sys.argv:
        out = ROOT / 'content' / 'reviews' / '2026-11-16_assessments_a0_a1_v5.md'
        out.write_text(report(), encoding='utf-8')
        print(out.relative_to(ROOT))
        return
    for lv in LEVELS:
        parts = split_parts(lv)
        for i, ts in enumerate(parts, 1):
            sql = build_part(lv, ts, i, len(parts))
            path = out_path(lv, i, len(parts))
            path.write_text(sql, encoding='utf-8')
            kb = len(sql.encode()) // 1024
            print(f'{path.relative_to(ROOT)}: {kb} КБ; завдань: {sum(len(t["items"]) for t in ts)}')
            if kb > 300:
                raise SystemExit(f'{path.name}: більше 300 КБ — розбийте на частини (PARTS)')


if __name__ == '__main__':
    main()
