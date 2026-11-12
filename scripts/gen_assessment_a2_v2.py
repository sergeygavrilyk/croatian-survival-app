#!/usr/bin/env python3
"""
Перевірки рівня A2 під програму A2 v2 (погоджено власником 2026-11-12).

  python3 -B scripts/gen_assessment_a2_v2.py              →  supabase/data_fixes/20261112_curriculum_a2_v2_t1_assessments.sql
  python3 -B scripts/gen_assessment_a2_v2.py --report     →  завдання (для звіту носію)

Схема (рішення власника 2026-11-07, програма A2 v2): модуль — 2 завдання на урок, від 12 до 20; середина рівня (після A2.7) — 30;
фінал (після A2.14) — 48. Разом 180 + 30 + 48 = 258. 4 навички §60 (розумію, спілкуюся, переказую, кажу) — у тих самих частках,
що в перевірках A0 / A1. Завдання складаються лише з діалогів і вправ уроків A2 v2 (scripts/gen_curriculum_a2_v2.py)
і текстів для читання A2 (scripts/reading_data_a2.py, група → модуль за програмою); нових хорватських речень генератор не пише.
Середина й фінал — без джерел і речень тестів модулів; у фіналі кожен модуль — щонайменше 2 завдання.
Тест не блокує уроки; пройдено = ≥ 70 % і ≥ 50 % у кожній навичці; говоріння можна пропустити. Бета (PUBLISHED).
"""
from __future__ import annotations

import copy
import sys
from collections import Counter
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
import gen_assessment as A  # noqa: E402
import gen_assessment_a1_v3 as A1  # noqa: E402  (fill_test_balanced, clashes, shown, prune, same_pair)
import gen_curriculum_a2_v2 as V  # noqa: E402
import reading_data_a2 as R  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'supabase' / 'data_fixes' / f'{V.DATE}_curriculum_a2_v2_t1_assessments.sql'
LEVEL = 'A2'
NOTE = 'Бета: перевірка рівня A2 (програма A2 v2, схема 2026-11-07) — завдання з діалогів і вправ уроків A2. Потрібна перевірка носієм.'
SOURCE = 'claude_assessment_a2_v2'
KINDS = ['listen', 'read', 'reply', 'relay', 'ua2hr', 'type', 'build', 'speak']
# Частки навичок як у A.PLAN (розумію 30 %, спілкуюся 20–23 %, переказую 20–23 %, кажу 30 %)
MODULE_PLANS = {
    12: [('listen', 2), ('read', 1), ('reply', 3), ('relay', 2), ('ua2hr', 1), ('type', 1), ('build', 1), ('speak', 1)],
    14: [('listen', 3), ('read', 1), ('reply', 3), ('relay', 2), ('ua2hr', 2), ('type', 1), ('build', 1), ('speak', 1)],
    16: [('listen', 3), ('read', 2), ('reply', 3), ('relay', 2), ('ua2hr', 2), ('type', 1), ('build', 2), ('speak', 1)],
}
A.PLAN['a2-mid'] = [('listen', 5), ('read', 3), ('reply', 7), ('relay', 4), ('ua2hr', 3), ('type', 3), ('build', 3), ('speak', 2)]
A.PLAN['a2-final'] = [('listen', 8), ('read', 5), ('reply', 11), ('relay', 6), ('ua2hr', 5), ('type', 5), ('build', 5), ('speak', 3)]
MINUTES = {'module': 8, 'mid': 15, 'final': 25}
DESCRIPTION = {
    'module': 'Після модуля: {n} завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~{m} хв.',
    'mid': 'Середина рівня (модулі A2.1–A2.7): 30 завдань на 4 навички. ~15 хв.',
    'final': 'Кінець рівня (усі 14 модулів A2): 48 завдань на 4 навички. ~25 хв.',
}


def n_items(m: int) -> int:
    return max(12, min(20, 2 * V.D.PROGRAM[m]['lessons']))


def reading_of(m: int) -> list[dict]:
    groups = V.D.PROGRAM[m]['reading']
    out = []
    for t in R.TEXTS:
        if t['module'] in groups:
            out.append({'code': t['code'], 'type': t['type'], 'title_hr': t['title'][1], 'title_ua': t['title'][0],
                        'body_hr': t['hr'], 'body_ua': t['ua'],
                        'questions': [{'question_ua': qq, 'options': opts, 'answer': ans} for qq, opts, ans in t['questions']]})
    return out


_CACHE: dict = {}


def lessons_of(m: int) -> list[dict]:
    if m not in _CACHE:
        c = V.build_course(m)
        out = []
        for key in sorted(c.lessons):
            L = c.lessons[key]
            mm, o = key
            n = V.PLACE[key]
            out.append({
                'id': V.lesson_id(mm, o), 'order': o, 'title_ua': f'Урок {n}: {L["title"][0]}', 'title_hr': f'Lekcija {n}: {L["title"][1]}',
                'dialogues': [{'id': V.uid('conversation_a2v2', LEVEL, mm, o, si), 'title_ua': s_ua, 'title_hr': s_hr,
                               'turns': [{'speaker': sp, 'hr': hr, 'ua': ua} for sp, hr, ua in turns]}
                              for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1)],
                'exercises': [{'type': ex['type'], 'q': ex['question'], 'a': ex['answer'], 'options': ex['options'], 'skill': ex['skill']}
                              for ex in c.lesson_exercises(key) if ex['type'] != 'listening_dialogue'],
            })
        _CACHE[m] = out
    return copy.deepcopy(_CACHE[m])


def level_a2(upto: int) -> dict:
    """Модулі 1…upto: з них і завдання, і хибні варіанти (учень пізніших ще не бачив)."""
    modules = []
    for m in sorted(V.D.PROGRAM):
        if m > upto:
            break
        t_ua, t_hr = V.module_title(m)
        modules.append({'id': V.module_id(m), 'order': m, 'lessons': lessons_of(m), 'reading': reading_of(m), 'title_ua': t_ua, 'title_hr': t_hr})
    return {'level': LEVEL, 'modules': modules}


def module_plan(pools, m: int) -> list[tuple[str, int]]:
    plan = list(MODULE_PLANS[n_items(m)])
    if not pools.by_module[m]['read']:   # модулю без текстів для читання — замість «прочитай» ще «на слух» (та сама навичка)
        n = dict(plan)['read']
        plan = [(k, c + n if k == 'listen' else c) for k, c in plan if k != 'read']
    return plan


def module_test(m: int, used: set | None = None) -> tuple[list[dict], list]:
    pools = A.Pools(level_a2(max(m, 2)))
    plan = module_plan(pools, m)
    return A.fill_test(pools, used if used is not None else set(), plan, [m], f'a2-m{m:02d}'), plan


def module_tests() -> list[dict]:
    out = []
    for m in sorted(V.D.PROGRAM):
        slug = f'a2-m{m:02d}'
        items, plan = module_test(m)
        A.PLAN[slug] = plan
        for i, it in enumerate(items, 1):
            it['order'] = i
            it['id'] = A.uid('assessment', slug, 'a2v2', 'item', i)
        out.append({'slug': slug, 'kind': slug, 'db_kind': 'module', 'module': m, 'order': m, 'title_ua': f'Перевірка модуля A2.{m}',
                    'module_title': V.module_title(m)[0], 'items': items})
    return out


def module_tests_used(upto: int) -> tuple[set, set[str]]:
    used_all: set = set()
    seen: set[str] = set()
    for m in range(1, upto + 1):
        used: set = set()
        items, _ = module_test(m, used)
        used_all |= used
        seen |= {x for it in items for x in A1.shown(it)}
    return A1.same_pair(used_all), seen


def fill_balanced(pools, used: set, kind_plan, mods: list[int], slug: str, seed: str) -> list[dict]:
    """Як A1.fill_test_balanced (завдання — з модуля, де їх поки найменше), але кожне нове завдання одразу перевіряється на
    «жорсткий» збіг з уже вибраними (речення-відповідь одного завдання видно в іншому) — такі джерела пропускаються."""
    import random
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
                    k, sh = set(A1.key_lines(cand)), set(A1.shown(cand))
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


LEVEL_TESTS = [('a2-mid', 'mid', 'Перевірка середини рівня A2', V.D.MID_AFTER), ('a2-final', 'final', 'Фінальна перевірка рівня A2', 14)]


def level_tests() -> list[dict]:
    out = []
    used, seen = set(), set()
    for slug, kind, title, upto in LEVEL_TESTS:
        mu, ms = module_tests_used(upto)
        used, seen = used | mu, seen | ms
        pools = A.Pools(level_a2(upto))
        A1.prune(pools, seen)
        mods = sorted(pools.by_module)
        best = None
        for attempt in range(60):
            trial = set(used)
            try:
                items = fill_balanced(pools, trial, A.PLAN[slug], mods, slug, seed=slug if attempt == 0 else f'{slug}:{attempt}')
            except SystemExit:
                continue
            per = Counter(it['module'] for it in items)
            hard, soft = A1.clashes(items)
            if all(per[m] >= 2 for m in mods) and hard == 0 and (best is None or soft < best[0]):
                best = (soft, attempt, items, trial)
                if soft == 0:
                    break
        if best is None:
            raise SystemExit(f'{slug}: не вдалося покрити всі модулі без повторів')
        soft, attempt, items, trial = best
        used = A1.same_pair(trial)
        seen |= {x for it in items for x in A1.shown(it)}
        for i, it in enumerate(items, 1):
            it['order'] = i
            it['id'] = A.uid('assessment', slug, 'a2v2', 'item', i)
        out.append({'slug': slug, 'kind': slug, 'db_kind': kind, 'module': None, 'upto': upto, 'order': 50 if kind == 'mid' else 100,
                    'title_ua': title, 'items': items})
    return out


def tests() -> list[dict]:
    if not hasattr(tests, '_c'):
        ts = module_tests() + level_tests()
        tests._c = A.finalize(ts, LEVEL)
    return tests._c


def item_row(it: dict) -> str:
    q, qj = A.q, A.qj
    lesson_sql = f"(select id from public.lessons where id = {q(it['lesson'])})" if it['lesson'] else 'null'
    return (f"  ({q(it['id'])}, v_aid, {it['order']}, {q(LEVEL)}, {q(it['skill'])}, {q(it['area'])}, {q(it['item_type'])}, "
            f"{q(it['prompt_ua'])}, {q(it['prompt_hr'])}, {qj(it['options'])}, "
            f"{it['correct_index'] if it['correct_index'] is not None else 'null'}, {q(it['answer_text'])}, "
            f"{q(it['audio_hr'])}, {q(it['passage_hr'])}, {q(it['passage_ua'])}, {q(it['explanation_ua'])}, {lesson_sql}, "
            f"{q(A.STATUS)}, {q(SOURCE)})")


def build() -> str:
    q = A.q
    ts = tests()
    total = sum(len(t['items']) for t in ts)
    sizes = ', '.join(f"{t['slug']} — {len(t['items'])}" for t in ts)
    out = [f"""-- =====================================================================
-- Перевірки рівня A2 під програму A2 v2: 14 модулів + середина + фінал · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_assessment_a2_v2.py (не редагуйте вручну).
--
-- Схема 2026-11-07: модуль — 2 завдання на урок (12–20), середина — 30, фінал — 48. Разом {total} завдань:
--   {sizes}.
--   * Завдання — з діалогів і вправ уроків A2 v2 і текстів для читання A2; нових речень немає. 4 навички §60.
--   * Нові тести — PUBLISHED (бета). Пройдено = ≥ 70 % і ≥ 50 % у кожній навичці (як A0 / A1).
--   * Потрібні: SQL структури й модулів A2 v2 (20261112_curriculum_a2_v2_00…m14). Повторний запуск нічого не змінює.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;
"""]
    for t in ts:
        rows = ',\n'.join(item_row(it) for it in t['items'])
        kind = t['db_kind']
        n = len(t['items'])
        minutes = MINUTES[kind] if kind != 'module' else max(6, n // 2)
        desc = DESCRIPTION[kind].format(n=n, m=minutes)
        mid = q(V.module_id(t['module'])) if t['module'] else 'null'
        out.append(f"""-- {t['title_ua']}{' · ' + t['module_title'] if t.get('module_title') else ''} · {n} завдань
do $$
declare v_aid uuid := {q(A.uid('assessment', t['slug'], 'a2v2'))};
begin
  if exists (select 1 from public.assessment_items where id = {q(t['items'][0]['id'])}) then return; end if;  -- уже створено
  if exists (select 1 from public.assessments where slug = {q(t['slug'])} and id <> v_aid) then
    raise exception 'Тест {t['slug']} уже є з іншим id — звірте базу';
  end if;
  insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index, pass_ratio,
                                  area_min_ratio, estimated_minutes, description_ua)
  values (v_aid, {q(t['slug'])}, {q(kind)}, {q(t['title_ua'])}, 1, {q(A.STATUS)}, {q(SOURCE)}, {q(LEVEL)},
          {mid}, {t['order']}, 0.70, 0.50, {minutes}, {q(desc)})
  on conflict (id) do nothing;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
{rows};
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, null, 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, {q(NOTE)});
end $$;
""")
    expected = ', '.join(f"({q(t['slug'])}, {len(t['items'])})" for t in ts)
    out.append(f"""-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_total int;
begin
  select count(*) into v_bad from (values {expected}) e(slug, n) left join public.assessments a on a.slug = e.slug and a.cefr = {q(LEVEL)} and a.status = 'PUBLISHED'
   where a.id is null or (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> e.n;
  select count(*) into v_total from public.assessment_items i join public.assessments a on a.id = i.assessment_id
   where a.cefr = {q(LEVEL)} and a.source = {q(SOURCE)} and i.status = 'PUBLISHED';
  if v_bad > 0 or v_total <> {total} then raise exception 'Перевірки A2: тестів з помилкою %, завдань % (очікувалось {total})', v_bad, v_total; end if;
  raise notice 'Готово: перевірки рівня A2 — {len(ts)} тестів, % завдань', v_total;
end $$;

commit;
""")
    return '\n'.join(out)


def report() -> str:
    lines = ['# Перевірки рівня A2 (програма A2 v2), звіт для носія', '',
             '> Згенеровано `scripts/gen_assessment_a2_v2.py --report` 2026-11-12. Бета: завдання з діалогів і вправ уроків A2.', '']
    for t in tests():
        lines += [f"## `{t['slug']}` {t['title_ua']} ({len(t['items'])})", '', '| # | Навичка | Завдання | Відповідь | Модуль |', '|---|---|---|---|---|']
        for it in t['items']:
            prompt = it['prompt_ua'] + (f" *{it['prompt_hr']}*" if it['prompt_hr'] and it['kind'] != 'read' else '')
            if it['audio_hr'] and it['kind'] == 'listen':
                prompt += f" 🔊 *{it['audio_hr']}*"
            ans = it['options'][it['correct_index']] if it['correct_index'] is not None else it['answer_text']
            lines.append(f"| {it['order']} | {A.KIND_UA[it['kind']]} | {prompt.replace(chr(10), ' ')} | {ans} | A2.{it['module']} |")
        lines.append('')
    return '\n'.join(lines) + '\n'


def main():
    if '--report' in sys.argv:
        out = ROOT / 'content' / 'reviews' / '2026-11-12_curriculum_a2_v2_assessments.md'
        out.write_text(report(), encoding='utf-8')
        print(out.relative_to(ROOT))
        return
    sql = build()
    OUT.write_text(sql, encoding='utf-8')
    print(f'{OUT.relative_to(ROOT)}: {len(sql.encode()) // 1024} КБ; завдань: {sum(len(t["items"]) for t in tests())}')


if __name__ == '__main__':
    main()
