#!/usr/bin/env python3
"""
Перевірки модулів A1 під програму A1 v3 (уроки за темою, 2026-10-26).

  python3 -B scripts/gen_assessment_a1_v3.py 1            →  supabase/data_fixes/20261026_assessments_a1_v3_m01.sql
  python3 -B scripts/gen_assessment_a1_v3.py 1 --report   →  завдання нової перевірки (для звіту носію)

Як для A0 (scripts/gen_assessment_a0_v4.py): рівень A1 збирається за програмою v3 — у перебудованих модулях уроки рівно ті,
що пише scripts/gen_curriculum_a1_v3.py, в інших — теперішні уроки зі знімка scripts/assessment_source_snapshot.json
(на своїх нових місцях), тексти для читання — за своїм модулем; далі той самий fill_test з gen_assessment.py
(10 завдань на 4 навички). Беремо лише тест цільового модуля.

SQL (нічого не видаляє): стара версія завдань — у content_versions; старі завдання → DEPRECATED (місця +100);
нові — PUBLISHED (бета); запис у журналі перевірки. Повторний запуск безпечний: оновлений тест пропускається.
Модулю без перевірки (нові A1.7, A1.11, A1.12) SQL створює тест a1-mNN.
"""
from __future__ import annotations

import copy
import json
import re
import sys
from collections import Counter
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
import gen_assessment as A  # noqa: E402
import gen_curriculum_a1_v3 as V  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
NOTE = 'Бета: перевірку модуля оновлено під програму A1 v3 — завдання з нових діалогів і вправ. Потрібна перевірка носієм.'
VERSION_NOTE = 'curriculum_a1_v3: перевірку модуля оновлено під нові уроки — старі завдання'
TARGET = [int(a) for a in sys.argv[1:] if a.isdigit()] or [max(V.MODULES)]
LEVEL_MODE = 'level' in sys.argv[1:]  # середина (після A1.6) і фінал (після A1.13) рівня A1
MID_MODULES = 6


_V3_CACHE: dict = {}


def v3_lessons(module: int) -> list[dict]:
    if module in _V3_CACHE:
        return copy.deepcopy(_V3_CACHE[module])
    c = V.build_course(module)
    out = []
    for key in sorted(V.MODULES[module]['lessons']):
        L = c.lessons[key]
        m, o = key
        n = V.PLACE[key]
        out.append({
            'id': V.lesson_id(m, o), 'order': o,
            'title_ua': f'Урок {n}: {L["title"][0]}', 'title_hr': f'Lekcija {n}: {L["title"][1]}',
            'dialogues': [{'id': V.uid('conversation_v3', V.LEVEL, m, o, si), 'title_ua': s_ua, 'title_hr': s_hr,
                           'turns': [{'speaker': sp, 'hr': hr, 'ua': ua} for sp, hr, ua in turns]}
                          for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1)],
            'exercises': [{'type': ex['type'], 'q': ex['question'], 'a': ex['answer'], 'options': ex['options'], 'skill': ex['skill']}
                          for ex in c.lesson_exercises(key)],
        })
    _V3_CACHE[module] = copy.deepcopy(out)
    return out


def level_a1(upto: int | None = None) -> dict:
    """Рівень A1 за програмою v3. upto — лише модулі 1…upto (учень ще не бачив пізніших): з них і завдання,
    і хибні варіанти; так тест модуля не змінюється, коли перебудовують наступні модулі."""
    data = json.loads(A.SNAPSHOT.read_text(encoding='utf-8'))
    old = next(L for L in data['levels'] if L['level'] == 'A1')
    old_lessons = {l['id']: l for m in old['modules'] for l in m['lessons']}
    old_reading = {m['order']: m['reading'] for m in old['modules']}
    modules = []
    for m in sorted(V.D.PROGRAM):
        if upto is not None and m > upto:
            continue
        P = V.D.PROGRAM[m]
        if m in V.MODULES:
            lessons = v3_lessons(m)
        else:
            lessons = [old_lessons[V.old_lesson_id(x)] for x in P['lessons'] if isinstance(x, int)]
        t_ua, t_hr = V.module_title(m)
        modules.append({'id': V.module_id(m), 'order': m, 'lessons': lessons, 'reading': old_reading.get(P['old_module'], []),
                        'title_ua': t_ua, 'title_hr': t_hr})
    return {'level': 'A1', 'modules': modules}


def module_plan(pools, m: int) -> list[tuple[str, int]]:
    """План тесту модуля. Новий модуль програми v3 (A1.7, A1.11, A1.12) ще не має текстів для читання —
    тоді замість «прочитай» ще одне «на слух» (та сама навичка «розуміння»)."""
    plan = list(A.PLAN['module'])
    if not pools.by_module[m]['read']:
        n = dict(plan).get('read', 0)
        plan = [(k, c + n if k == 'listen' else c) for k, c in plan if k != 'read']
    return plan


def module_test(m: int) -> list[dict]:
    pools = A.Pools(level_a1(max(m, 2)))
    return A.fill_test(pools, set(), module_plan(pools, m), [m], f'a1-m{m:02d}')


def tests() -> list[dict]:
    if LEVEL_MODE:
        return level_tests()
    out = []
    for m in TARGET:
        slug = f'a1-m{m:02d}'
        items = module_test(m)
        for i, it in enumerate(items, 1):
            it['order'] = i
            it['id'] = A.uid('assessment', slug, 'v3', 'item', i)
        out.append({'slug': slug, 'kind': 'module', 'module': m, 'order': m, 'title_ua': f'Перевірка модуля A1.{m}',
                    'module_title': V.module_title(m)[0], 'items': items})
    return A.finalize(out, 'A1')  # хибні варіанти не повторюються в тесті (2026-11-03)


# ---------------------------------------------------------------- середина й фінал (як gen_assessment_a0_v4.level_tests)
def same_pair(used: set) -> set:
    """Репліка-відповідь з «Переказую» (r) не повторюється як «Спілкуюся» / «на слух» (s), і навпаки."""
    return used | {(('s' if k[0] == 'r' else 'r'),) + k[1:] for k in used if k[0] in ('r', 's')}


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


def module_tests_used(upto: int) -> tuple[set, set[str]]:
    """Джерела й речення тестів модулів a1-m01…a1-m{upto} (кожен — зі своїм набором модулів, як module_test)."""
    used_all: set = set()
    seen: set[str] = set()
    for m in range(1, upto + 1):
        pools = A.Pools(level_a1(max(m, 2)))
        used: set = set()
        items = A.fill_test(pools, used, module_plan(pools, m), [m], f'a1-m{m:02d}')
        used_all |= used
        seen |= {x for it in items for x in shown(it)}
    return same_pair(used_all), seen


LEVEL_TESTS = [('a1-mid', 'mid', 'Перевірка середини рівня A1', MID_MODULES, 'v3'),
               ('a1-final', 'final', 'Фінальна перевірка рівня A1', 13, 'v3')]
LEVEL_DESCRIPTION = {'mid': 'Середина рівня (модулі A1.1–A1.6): 20 завдань на 4 навички. ~10 хв.',
                     'final': 'Кінець рівня (усі 13 модулів A1): 30 завдань на 4 навички. ~15 хв.'}


def fill_test_balanced(pools, used: set, kind_plan, mods: list[int], slug: str, seed: str) -> list[dict]:
    """Як A.fill_test, але кожне наступне завдання — з модуля, де завдань поки найменше (фінал: 13 модулів на 30 завдань,
    кожен — щонайменше 2). Для середини лишається A.fill_test, щоб її завдання не змінилися."""
    import random
    rng = random.Random(seed)
    items, in_test = [], set()
    per: Counter = Counter()
    scarce = ['relay', 'reply', 'read', 'ua2hr', 'speak', 'build', 'type', 'listen']
    for kind, count in sorted(kind_plan, key=lambda kc: scarce.index(kc[0])):
        got = 0
        for _ in range(60):
            if got >= count:
                break
            order = sorted(mods, key=lambda m: (per[m], rng.random()))
            for mo in order:
                pool = [x for x in pools.by_module[mo][kind] if x['key'] not in used and x['key'][1:] not in in_test]
                if not pool:
                    continue
                src = rng.choice(pool)
                used.add(src['key'])
                item = A.make_item(kind, src, pools, mo, rng)
                if item is None:
                    break
                in_test.add(src['key'][1:])
                item['module'] = mo
                items.append(item)
                per[mo] += 1
                got += 1
                break
        if got < count:
            raise SystemExit(f'{slug}: замало джерел для «{kind}» ({got} з {count})')
    display = [k for k, _ in kind_plan]
    return sorted(items, key=lambda it: display.index(it['kind']))


def level_tests() -> list[dict]:
    """Середина (A1.1–A1.6, 20 завдань) і — коли перебудовано все — фінал (A1.1–A1.13, 30) з нових уроків,
    без джерел і речень тестів модулів. Кожен модуль діапазону — щонайменше 2 завдання; до 200 зерен."""
    out = []
    ready = [t for t in LEVEL_TESTS if all(m in V.MODULES for m in range(1, t[3] + 1))]
    if not ready:
        raise SystemExit('Середина — після A1.6, фінал — після A1.13')
    used, seen = set(), set()
    for slug, kind, title, upto, ver in ready:
        # джерела й речення тестів модулів свого діапазону (середина — A1.1–A1.6, як і до фіналу: її завдання не змінюються)
        mu, ms = module_tests_used(upto)
        used, seen = used | mu, seen | ms
        pools = A.Pools(level_a1(upto))
        prune(pools, seen)
        mods = sorted(pools.by_module)
        best = None
        for attempt in range(200):
            trial = set(used)
            try:
                fill = fill_test_balanced if kind == 'final' else A.fill_test
                items = fill(pools, trial, A.PLAN[kind], mods, slug, seed=slug if attempt == 0 else f'{slug}:{attempt}')
            except SystemExit:
                continue
            per = Counter(it['module'] for it in items)
            hard, soft = clashes(items)
            if all(per[m] >= 2 for m in mods) and hard == 0 and (best is None or soft < best[0]):
                best = (soft, attempt, items, trial)
                if soft == 0:
                    break
        if best is None:
            raise SystemExit(f'{slug}: не вдалося покрити всі модулі без повторів')
        soft, attempt, items, trial = best
        used = same_pair(trial)
        seen |= {x for it in items for x in shown(it)}
        for i, it in enumerate(items, 1):
            it['order'] = i
            it['id'] = A.uid('assessment', slug, ver, 'item', i)
        out.append({'slug': slug, 'kind': kind, 'module': None, 'upto': upto, 'title_ua': title, 'seed_attempt': attempt,
                    'soft_clashes': soft, 'items': items})
    return A.finalize(out, 'A1')  # хибні варіанти не повторюються в тесті (2026-11-03)


def item_row(it: dict) -> str:
    q, qj = A.q, A.qj
    lesson_sql = f"(select id from public.lessons where id = {q(it['lesson'])})" if it['lesson'] else 'null'
    return (f"  ({q(it['id'])}, v_aid, {it['order']}, 'A1', {q(it['skill'])}, {q(it['area'])}, {q(it['item_type'])}, "
            f"{q(it['prompt_ua'])}, {q(it['prompt_hr'])}, {qj(it['options'])}, "
            f"{it['correct_index'] if it['correct_index'] is not None else 'null'}, {q(it['answer_text'])}, "
            f"{q(it['audio_hr'])}, {q(it['passage_hr'])}, {q(it['passage_ua'])}, {q(it['explanation_ua'])}, {lesson_sql}, "
            f"{q(A.STATUS)}, {q(A.SOURCE)})")


def build() -> str:
    q = A.q
    ts = tests()
    m0 = TARGET[0]
    date = V.MODULES[m0]['date']
    out = [f"""-- =====================================================================
-- Перевірка модуля A1.{m0} під програму A1 v3 · {date}
-- Згенеровано: python3 -B scripts/gen_assessment_a1_v3.py {' '.join(map(str, TARGET))} (не редагуйте вручну).
--
-- Тести: {', '.join(t['slug'] for t in ts)} — по {len(ts[0]['items'])} завдань із нових діалогів і вправ модуля.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A1). Середину й фінал рівня A1 не змінено (їх — після всього A1).
--   * Потрібні: 20261026_curriculum_a1_v3_structure.sql і {', '.join(V.module_out(m).name for m in TARGET)}.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;
"""]
    for t in ts:
        rows = ',\n'.join(item_row(it) for it in t['items'])
        mid = V.module_id(t['module'])
        out.append(f"""-- {t['title_ua']} · {t['module_title']}
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = {q(t['slug'])};
  if v_aid is null then  -- новий модуль програми v3: тесту ще немає
    insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index, pass_ratio,
                                    area_min_ratio, estimated_minutes, description_ua)
    values ({q(A.uid('assessment', t['slug'], 'v3'))}, {q(t['slug'])}, 'module', {q(t['title_ua'])}, 1, {q(A.STATUS)}, {q(A.SOURCE)}, 'A1',
            {q(mid)}, {t['module']}, 0.70, 0.50, {A.MINUTES['module']}, {q(A.DESCRIPTION['module'])})
    returning id into v_aid;
  end if;
  if exists (select 1 from public.assessment_items where id = {q(t['items'][0]['id'])}) then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from {q(mid)}::uuid then
    raise exception 'Тест {t['slug']} прив’язаний не до модуля A1.{t['module']} — спершу 20261026_curriculum_a1_v3_structure.sql';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, {q(VERSION_NOTE)});
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + 100
   where assessment_id = v_aid and status = 'PUBLISHED' and order_index <= 100;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
{rows};
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, {q(NOTE)});
end $$;
""")
    slugs = ', '.join(q(t['slug']) for t in ts)
    ids = ', '.join(q(it['id']) for t in ts for it in t['items'])
    n_items = sum(len(t['items']) for t in ts)
    out.append(f"""-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ({ids}) and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ({slugs})
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ({ids})));
  if v_new <> {n_items} or v_bad > 0 then raise exception 'Перевірки модулів A1: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірку {", ".join(t["slug"] for t in ts)} оновлено — % нових завдань', v_new;
end $$;

commit;
""")
    return '\n'.join(out)


def build_level_sql() -> str:
    q = A.q
    ts = tests()
    ids = ', '.join(q(it['id']) for t in ts for it in t['items'])
    expected = ', '.join(f"({q(t['slug'])}, {len(t['items'])})" for t in ts)
    n_items = sum(len(t['items']) for t in ts)
    mods = Counter(it['module'] for t in ts for it in t['items'])
    names = ' і '.join(f"{t['slug']} (A1.1–A1.{t['upto']}, {len(t['items'])} завдань)" for t in ts)
    out = [f"""-- =====================================================================
-- Рівень A1 під програму A1 v3: {', '.join(t['slug'] for t in ts)} · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_assessment_a1_v3.py level (не редагуйте вручну).
--
-- Тести: {names} — з нових діалогів і вправ; джерел і речень перевірок модулів тут немає.
--   Завдань за модулями: {', '.join(f'A1.{m} — {n}' for m, n in sorted(mods.items()))}.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета). Прогрес і результати користувачів не змінюються.
--   * Потрібні: 20261026_curriculum_a1_v3_structure.sql і SQL модулів A1.1–A1.{max(t['upto'] for t in ts)}.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;
"""]
    for t in ts:
        rows = ',\n'.join(item_row(it) for it in t['items'])
        out.append(f"""-- {t['title_ua']} · {len(t['items'])} завдань
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = {q(t['slug'])};
  if v_aid is null then raise exception 'Немає тесту {t['slug']}'; end if;
  if exists (select 1 from public.assessment_items where id = {q(t['items'][0]['id'])}) then return; end if;  -- уже оновлено
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, {q(VERSION_NOTE)});
  update public.assessments set description_ua = {q(LEVEL_DESCRIPTION[t['kind']])} where id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + 100
   where assessment_id = v_aid and status = 'PUBLISHED' and order_index <= 100;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
{rows};
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, {q(NOTE)});
end $$;
""")
    out.append(f"""-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ({ids}) and status = 'PUBLISHED';
  select count(*) into v_bad from (values {expected}) e(slug, n) join public.assessments a on a.slug = e.slug
   where (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> e.n
      or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'
                 and i.id not in ({ids}));
  if v_new <> {n_items} or v_bad > 0 then raise exception 'Рівень A1: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: {", ".join(t["slug"] for t in ts)} оновлено — % нових завдань', v_new;
end $$;

commit;
""")
    return '\n'.join(out)


def report() -> str:
    lines = ['## Перевірки рівня A1 (оновлено під нові уроки)' if LEVEL_MODE else '## Перевірка модуля (оновлено під нові уроки)', '']
    for t in tests():
        lines += [f"### `{t['slug']}` {t['title_ua']}", '', '| # | Навичка | Завдання | Відповідь |' + (' Модуль |' if LEVEL_MODE else ''),
                  '|---|---|---|---|' + ('---|' if LEVEL_MODE else '')]
        for it in t['items']:
            prompt = it['prompt_ua'] + (f" *{it['prompt_hr']}*" if it['prompt_hr'] and it['kind'] != 'read' else '')
            if it['audio_hr'] and it['kind'] == 'listen':
                prompt += f" 🔊 *{it['audio_hr']}*"
            ans = it['options'][it['correct_index']] if it['correct_index'] is not None else it['answer_text']
            lines.append(f"| {it['order']} | {A.KIND_UA[it['kind']]} | {prompt.replace(chr(10), ' ')} | {ans} |"
                         + (f" A1.{it['module']} |" if LEVEL_MODE else ''))
        lines.append('')
    return '\n'.join(lines)


def main():
    if '--report' in sys.argv:
        print(report())
        return
    if LEVEL_MODE:
        sql = build_level_sql()
        slugs = '_'.join(t[0].split('-')[1] for t in LEVEL_TESTS if all(m in V.MODULES for m in range(1, t[3] + 1)))
        out = ROOT / 'supabase' / 'data_fixes' / f'20261026_assessments_a1_v3_{slugs}.sql'
        out.write_text(sql, encoding='utf-8')
        print(f'{out.relative_to(ROOT)}: {len(sql.encode()) // 1024} КБ')
        return
    sql = build()
    m0 = TARGET[0]
    out = ROOT / 'supabase' / 'data_fixes' / f"{V.MODULES[m0]['date'].replace('-', '')}_assessments_a1_v3_m{m0:02d}.sql"
    out.write_text(sql, encoding='utf-8')
    print(f'{out.relative_to(ROOT)}: {len(sql.encode()) // 1024} КБ')


if __name__ == '__main__':
    main()
