#!/usr/bin/env python3
"""
«Складіть» у перевірках рівня приймає кілька порядків слів (рішення власника 2026-11-15) — пакет для A2 і звіт для носія.

  python3 -B scripts/gen_sentence_orders_20261116.py  →  supabase/data_fixes/20261116_assessment_sentence_orders_a2.sql
                                                          content/reviews/2026-11-16_sentence_orders.md

Інші порядки — scripts/sentence_order_alternatives.py. A0 / A1 отримують їх разом із новими перевірками
(scripts/gen_assessment_a0_a1_v5.py); тут — 24 наявні завдання «Складіть» перевірок A2 (знімок
scripts/sentence_orders_a2_snapshot.json). SQL лише заповнює answer_alternatives (M27) там, де вона порожня;
стара версія тесту — у content_versions, запис — у content_reviews. Повторний запуск нічого не змінює.
"""
from __future__ import annotations

import json
import sys
from collections import OrderedDict
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
import gen_assessment as A  # noqa: E402
from sentence_order_alternatives import ALTERNATIVES, check_alternatives  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
SNAP = ROOT / 'scripts' / 'sentence_orders_a2_snapshot.json'
OUT = ROOT / 'supabase' / 'data_fixes' / '20261116_assessment_sentence_orders_a2.sql'
REPORT = ROOT / 'content' / 'reviews' / '2026-11-16_sentence_orders.md'
NOTE = 'Бета: «Складіть» приймає інші правильні порядки слів (answer_alternatives, M27; рішення власника 2026-11-15). Потрібна перевірка носієм.'
VERSION_NOTE = 'sentence_orders_20261116: до «Складіть» додано інші правильні порядки слів — стара версія завдань'


def a2_items() -> list[dict]:
    return json.loads(SNAP.read_text(encoding='utf-8'))['items']


def build() -> str:
    q = A.q
    items = [it for it in a2_items() if it['answer_text'] in ALTERNATIVES]
    by_test: OrderedDict[str, list[dict]] = OrderedDict()
    for it in items:
        by_test.setdefault(it['slug'], []).append(it)
    blocks = []
    for slug, its in by_test.items():
        rows = ',\n'.join(f"    ({q(it['id'])}::uuid, {q(it['answer_text'])}, array[{', '.join(q(a) for a in ALTERNATIVES[it['answer_text']])}]::text[])"
                          for it in its)
        blocks.append(f"""-- {slug}: {len(its)}
do $$
declare v_aid uuid; v_n int;
begin
  select id into v_aid from public.assessments where slug = {q(slug)} and cefr = 'A2';
  if v_aid is null then raise exception 'Немає тесту {slug}'; end if;
  if not exists (select 1 from public.assessment_items i
                  join (values
{rows}
                  ) d(id, answer, alts) on d.id = i.id
                  where i.answer_alternatives = '{{}}') then return; end if;  -- уже заповнено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
         jsonb_build_object('items', (select jsonb_agg(to_jsonb(i) order by i.order_index) from public.assessment_items i
                                       where i.assessment_id = v_aid and i.status = 'PUBLISHED' and i.item_type = 'sentence_builder')),
         {q(VERSION_NOTE)};
  update public.assessment_items i set answer_alternatives = d.alts
    from (values
{rows}
    ) d(id, answer, alts)
   where i.id = d.id and i.assessment_id = v_aid and i.item_type = 'sentence_builder' and i.status = 'PUBLISHED'
     and i.answer_text = d.answer and i.answer_alternatives = '{{}}';
  get diagnostics v_n = row_count;
  if v_n <> {len(its)} then raise exception 'Тест {slug}: оновлено % завдань «Складіть», очікувалось {len(its)} — звірте базу', v_n; end if;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, {q(NOTE)});
end $$;
""")
    ids = ', '.join(q(it['id']) for it in items)
    n_alts = sum(len(ALTERNATIVES[it['answer_text']]) for it in items)
    return f"""-- =====================================================================
-- «Складіть» у перевірках A2: інші правильні порядки слів · 2026-11-16
-- Згенеровано: python3 -B scripts/gen_sentence_orders_20261116.py (не редагуйте вручну).
-- Рішення власника 2026-11-15: «Складіть» приймає кілька порядків слів; інші порядки — колонка answer_alternatives (M27).
--
--   * {len(items)} з {len(a2_items())} завдань «Складіть» A2 отримують {n_alts} інших порядків (у решти природний лише один порядок).
--   * Лише заповнює порожню answer_alternatives; тексти завдань і відповіді не змінюються.
--   * Стара версія — у content_versions, запис — у content_reviews. Повторний запуск нічого не змінює.
--   * Потрібна міграція 20261116100000_m27_assessment_answer_alternatives.sql. A0 / A1 — у пакетах 20261116_assessments_a*_v5*.sql.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: «Складіть» A2 — з іншими порядками {len(items)} завдань».
-- =====================================================================

begin;

{chr(10).join(blocks)}
-- Самоперевірка
do $$
declare v_n int;
begin
  select count(*) into v_n from public.assessment_items where id in ({ids}) and cardinality(answer_alternatives) > 0;
  if v_n <> {len(items)} then raise exception '«Складіть» A2: з іншими порядками % завдань, очікувалось {len(items)}', v_n; end if;
  raise notice 'Готово: «Складіть» A2 — з іншими порядками % завдань', v_n;
end $$;

commit;
"""


def report() -> str:
    import gen_assessment_a0_a1_v5 as G
    lines = ['# «Складіть речення» в перевірках рівня: інші порядки слів — для носія', '',
             '> Згенеровано `scripts/gen_sentence_orders_20261116.py` 2026-11-16. Рішення власника 2026-11-15: «Складіть» приймає кілька',
             '> порядків слів. Інші порядки записав Claude вручну (`scripts/sentence_order_alternatives.py`) — **потрібна перевірка носієм**.', '',
             '## Що глянути', '',
             '1. Чи кожен «інший порядок» природний і має те саме значення (переклад завдання лишається правильним).',
             '2. Де записано «лише один порядок» — чи немає ще одного звичного порядку (тоді учневі зарахують помилку несправедливо).',
             '3. Свідомо не записано порядки з наголосом чи протиставленням (*Zahtjev želim predati.*, *Na posao idem.*) — чи погоджуєтеся.', '',
             '| Перевірка | Завдання (переклад) | Головна відповідь | Інші порядки |', '|---|---|---|---|']
    rows = []
    for lv in G.LEVELS:
        for t in G.tests(lv):
            for it in t['items']:
                if it['item_type'] == 'sentence_builder':
                    rows.append((t['slug'], it['explanation_ua'].split('» — «')[0].lstrip('«'), it['answer_text']))
    for it in a2_items():
        rows.append((it['slug'], '', it['answer_text']))
    for slug, ua, ans in rows:
        alts = ' · '.join(f'*{a}*' for a in ALTERNATIVES.get(ans, [])) or 'лише один порядок'
        lines.append(f'| `{slug}` | {ua} | *{ans}* | {alts} |')
    with_alts = sum(1 for _, _, a in rows if a in ALTERNATIVES)
    lines += ['', f'Разом: {len(rows)} завдань «Складіть», з іншими порядками — {with_alts}.', '']
    return '\n'.join(lines)


def main():
    import gen_assessment_a0_a1_v5 as G
    used = {it['answer_text'] for lv in G.LEVELS for t in G.tests(lv) for it in t['items'] if it['item_type'] == 'sentence_builder'}
    used |= {it['answer_text'] for it in a2_items()}
    problems = check_alternatives()
    problems += [f'«{k}»: такого завдання «Складіть» немає' for k in ALTERNATIVES if k not in used]
    if problems:
        raise SystemExit('Перевірка не пройдена:\n' + '\n'.join(problems))
    OUT.write_text(build(), encoding='utf-8')
    REPORT.write_text(report(), encoding='utf-8')
    print(OUT.relative_to(ROOT), REPORT.relative_to(ROOT))


if __name__ == '__main__':
    main()
