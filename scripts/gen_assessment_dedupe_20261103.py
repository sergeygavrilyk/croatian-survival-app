#!/usr/bin/env python3
"""
Хибні варіанти без повторів у перевірках рівня A0 / A1 (2026-11-03).

  python3 -B scripts/gen_assessment_dedupe_20261103.py           →  supabase/data_fixes/20261103_assessments_distinct_options.sql
  python3 -B scripts/gen_assessment_dedupe_20261103.py --report  →  таблиця замін (для звіту носію)

Що було: той самий хибний варіант траплявся у двох завданнях одного тесту (a0-final #11 і #12 — «Dosta je. Hvala ti!»),
а інколи хибний варіант одного завдання був правильною відповіддю іншого (a1-m02: «Daj mi žličicu.» — пастка в #7 і відповідь у #10).
Тепер gen_assessment.dedupe_options (через finalize у gen_assessment_a0_v4.py і gen_assessment_a1_v3.py) замінює такий
варіант запасним того самого завдання; решта завдань не змінюється.

Цей скрипт відтворює всі перевірки модулів, середини й фіналу A0 (v4) і A1 (v3) рівно як їхні генератори і бере лише
заміни: (завдання, старі варіанти → нові). SQL оновлює варіанти на місці (id, місце й правильна відповідь ті самі — старі
спроби лишаються чинними): стара версія завдання — у content_versions, запис — у content_reviews. Завдання, у якому
варіанти вже нові, пропускається; якщо варіанти не збігаються ні зі старими, ні з новими — помилка (усе відкочується).
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
_argv = sys.argv
sys.argv = [_argv[0]]  # генератори читають номери модулів з командного рядка під час імпорту
import gen_assessment as A  # noqa: E402
import gen_assessment_a0_v4 as A0  # noqa: E402
import gen_assessment_a1_v3 as A1  # noqa: E402
sys.argv = _argv

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'supabase' / 'data_fixes' / '20261103_assessments_distinct_options.sql'
REASON = 'assessments_distinct_options_20261103: хибний варіант повторювався в тесті — стара версія завдання'
NOTE = ('Хибний варіант повторювався в тесті (в іншому завданні або як правильна відповідь іншого завдання) — '
        'замінено запасним варіантом того самого завдання (scripts/gen_assessment_dedupe_20261103.py). Потрібна перевірка носієм.')


def a0_tests() -> list[dict]:
    out = []
    A0.LEVEL_MODE = False
    for target in ([1, 2], *[[m] for m in range(3, max(A0.V.MODULES) + 1)]):  # як файли 20261019/20 _assessments_a0_v4*.sql
        A0.TARGET = target
        A0.REBUILT = list(range(1, max(target) + 1))
        out += A0.tests()
    A0.LEVEL_MODE = True
    A0.TARGET = []
    A0.REBUILT = list(range(1, max(A0.V.MODULES) + 1))
    out += A0.tests()
    return out


def a1_tests() -> list[dict]:
    out = []
    A1.LEVEL_MODE = False
    for m in sorted(A1.V.MODULES):
        A1.TARGET = [m]
        out += A1.tests()
    A1.LEVEL_MODE = True
    out += A1.tests()
    return out


def changes() -> list[dict]:
    rows = []
    for t in a0_tests() + a1_tests():
        by_order = {it['order']: it for it in t['items']}
        fixed: dict[int, list[str]] = {}
        for order, old, new in t['dedupe']:
            it = by_order[order]
            before = fixed.setdefault(order, list(it['options']))
            before[before.index(new)] = old  # відновити старі варіанти (як у базі)
        for order, old_opts in sorted(fixed.items()):
            it = by_order[order]
            rows.append({'slug': t['slug'], 'id': it['id'], 'order': order, 'kind': it['kind'],
                         'old': old_opts, 'new': list(it['options']), 'correct': it['options'][it['correct_index']],
                         'prompt': it.get('prompt_hr') or it.get('audio_hr') or it['prompt_ua']})
    return rows


def sql(rows: list[dict]) -> str:
    data = json.dumps([{'id': r['id'], 'slug': r['slug'], 'ord': r['order'], 'old': r['old'], 'new': r['new']} for r in rows],
                      ensure_ascii=False, indent=0)
    slugs = sorted({r['slug'] for r in rows})
    return f"""-- =====================================================================
-- Перевірки рівня A0 / A1: хибні варіанти без повторів у тесті · 2026-11-03
-- Згенеровано: python3 -B scripts/gen_assessment_dedupe_20261103.py (не редагуйте вручну).
--
--   * {len(rows)} завдань у {len(slugs)} тестах ({', '.join(slugs)}):
--     хибний варіант повторював хибний варіант іншого завдання або правильну відповідь іншого завдання.
--   * Повтор замінено запасним хибним варіантом того самого завдання (ті самі правила добору, що й у генераторі).
--   * Змінюються лише варіанти (options); id, місце, правильна відповідь і решта тесту — ті самі, старі спроби чинні.
--     Стара версія завдання → content_versions, запис у content_reviews. Нічого не видаляється.
--   * Повторний запуск безпечний: завдання з новими варіантами пропускається.
-- Після нього тест supabase/tests/assessments_distinct_options.test.sql має пройти («ALL TESTS PASSED»).
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $fix$
declare
  d record;
  r public.assessment_items%rowtype;
  v_changed int := 0;
  v_skipped int := 0;
begin
  for d in select * from jsonb_to_recordset('{A.q(data)[1:-1]}'::jsonb) as t(id uuid, slug text, ord int, old jsonb, new jsonb)
  loop
    select * into r from public.assessment_items where id = d.id;
    if not found or r.status <> 'PUBLISHED' then
      raise exception 'Завдання % #% (%) не знайдено серед опублікованих — спершу пакети перевірок A0 v4 / A1 v3', d.slug, d.ord, d.id;
    end if;
    if r.options = d.new then
      v_skipped := v_skipped + 1;
      continue;
    end if;
    if r.options is distinct from d.old then
      raise exception 'Завдання % #%: варіанти не такі, як очікувалось (%), — нічого не змінено', d.slug, d.ord, r.options;
    end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('assessment_item', r.id,
            coalesce((select max(version) from public.content_versions where entity_type = 'assessment_item' and entity_id = r.id), 0) + 1,
            to_jsonb(r), '{REASON}');
    update public.assessment_items
       set options = d.new, version = coalesce(version, 1) + 1, updated_at = now()
     where id = r.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('assessment_item', r.id, r.status, r.status, 'auto_passed', 'script',
            jsonb_build_array(jsonb_build_object('old', d.old, 'new', d.new)), '{NOTE}');
    v_changed := v_changed + 1;
  end loop;
  raise notice 'Замінено варіантів у завданнях: %, уже були нові: %', v_changed, v_skipped;
end
$fix$;

-- Самоперевірка: у жодному опублікованому тесті модуля / середини / фіналу хибний варіант не повторюється
-- (ні як хибний варіант іншого завдання, ні як правильна відповідь іншого завдання). Інакше — усе відкочується.
do $$
declare v_bad int;
begin
  select count(*) into v_bad from (
    select w.assessment_id, w.opt
      from (select i.id, i.assessment_id, lower(btrim(e)) as opt
              from public.assessment_items i join public.assessments a on a.id = i.assessment_id,
                   jsonb_array_elements_text(i.options) with ordinality as x(e, n)
             where a.status = 'PUBLISHED' and i.status = 'PUBLISHED' and a.kind in ('module', 'mid', 'final') and a.cefr in ('A0', 'A1')
               and i.item_type = 'multiple_choice' and n - 1 <> i.correct_index
               and i.skill <> 'reading') w
     group by w.assessment_id, w.opt
    having count(*) > 1
    union all
    select w.assessment_id, w.opt
      from (select i.id, i.assessment_id, lower(btrim(e)) as opt
              from public.assessment_items i join public.assessments a on a.id = i.assessment_id,
                   jsonb_array_elements_text(i.options) with ordinality as x(e, n)
             where a.status = 'PUBLISHED' and i.status = 'PUBLISHED' and a.kind in ('module', 'mid', 'final') and a.cefr in ('A0', 'A1')
               and i.item_type = 'multiple_choice' and n - 1 <> i.correct_index
               and i.skill <> 'reading') w
      join (select i.id, i.assessment_id,
                   lower(btrim(case when i.item_type = 'multiple_choice' then i.options ->> i.correct_index else i.answer_text end)) as ans
              from public.assessment_items i
             where i.status = 'PUBLISHED') c
        on c.assessment_id = w.assessment_id and c.id <> w.id and c.ans = w.opt
  ) bad;
  if v_bad > 0 then raise exception 'Лишились повтори хибних варіантів у тестах: %', v_bad; end if;
  raise notice 'Готово: хибні варіанти в перевірках рівня A0 / A1 не повторюються';
end $$;

commit;
"""


def report(rows: list[dict]) -> str:
    lines = ['| Тест | # | Завдання | Правильна | Було (хибний) | Стало |', '|---|---|---|---|---|---|']
    for r in rows:
        olds = [o for o in r['old'] if o not in r['new']]
        news = [o for o in r['new'] if o not in r['old']]
        lines.append(f"| `{r['slug']}` | {r['order']} | {r['prompt'].replace(chr(10), ' ')} | {r['correct']} | "
                     f"{'; '.join(olds)} | {'; '.join(news)} |")
    return '\n'.join(lines)


def main():
    rows = changes()
    if '--report' in sys.argv:
        print(report(rows))
        return
    OUT.write_text(sql(rows), encoding='utf-8')
    print(f'{OUT.relative_to(ROOT)}: {len(rows)} завдань у {len({r["slug"] for r in rows})} тестах')


if __name__ == '__main__':
    main()
