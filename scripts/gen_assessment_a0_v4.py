#!/usr/bin/env python3
"""
Оновлення перевірок модулів A0 після перебудови уроків за темою (curriculum_a0_v4).

  python3 -B scripts/gen_assessment_a0_v4.py 1 2         →  supabase/data_fixes/20261019_assessments_a0_v4.sql (A0.1–A0.2, уже в базі)
  python3 -B scripts/gen_assessment_a0_v4.py 3           →  supabase/data_fixes/20261019_assessments_a0_v4_m03.sql
  python3 -B scripts/gen_assessment_a0_v4.py 4           →  supabase/data_fixes/20261019_assessments_a0_v4_m04.sql
  python3 -B scripts/gen_assessment_a0_v4.py 5 (6)       →  supabase/data_fixes/20261019_assessments_a0_v4_m05.sql (_m06.sql)
  python3 -B scripts/gen_assessment_a0_v4.py 7 (8)       →  supabase/data_fixes/20261019_assessments_a0_v4_m07.sql (_m08.sql)
  python3 -B scripts/gen_assessment_a0_v4.py 10          →  supabase/data_fixes/20261020_assessments_a0_v4_m10.sql
  python3 -B scripts/gen_assessment_a0_v4.py 3 --report  →  завдання нових перевірок (для звіту носію)
  Без номерів — останній перебудований модуль. Уроки замінюються для модулів 1…max(номерів), тож вихід для «1 2»
  не залежить від пізніших модулів.

Навіщо: перевірки модулів (assessment_v1, scripts/gen_assessment.py) зібрано зі старих реплік і вправ уроків.
Після перебудови модуля ці діалоги й вправи — DEPRECATED, тож перевірка має питати те, що тепер у уроках.

Як: знімок scripts/assessment_source_snapshot.json, де уроки перебудованих модулів замінено на нові
(вправи й діалоги — рівно ті, що пише scripts/gen_curriculum_a0_v4.py), → той самий build_level з gen_assessment.py →
беремо лише тести перебудованих модулів (a0-m01, a0-m02…). Середину й фінал рівня оновимо, коли перебудуємо весь A0.

SQL для кожного тесту (нічого не видаляє): стара версія завдань — у content_versions; старі завдання → DEPRECATED
(їхні місця зсуваються на +100, щоб звільнити 1…10); нові завдання — PUBLISHED (бета); запис у журналі перевірки.
Повторний запуск безпечний: оновлений тест пропускається.
"""
from __future__ import annotations

import copy
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
import gen_assessment as A  # noqa: E402
import gen_curriculum_a0_v4 as V  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT_FIRST = ROOT / 'supabase' / 'data_fixes' / '20261019_assessments_a0_v4.sql'  # A0.1–A0.2
OUT_MODULE = ROOT / 'supabase' / 'data_fixes' / '{}_assessments_a0_v4_m{:02d}.sql'  # дата — як у SQL уроків модуля


def ymd(m: int) -> str:
    return V.REVIEW_DATE[m].replace('-', '')


_args = [int(a) for a in sys.argv[1:] if a.isdigit()]
TARGET = _args or [max(V.MODULES)]  # тести яких модулів оновлюємо
REBUILT = list(range(1, max(TARGET) + 1))  # уроки цих модулів у знімку — нові (за темою)
NOTE = 'Бета: перевірку модуля оновлено під уроки за темою (curriculum_a0_v4) — завдання з нових діалогів і вправ. Потрібна перевірка носієм.'
VERSION_NOTE = 'curriculum_a0_v4: перевірку модуля оновлено під нові уроки — старі завдання'


def v4_lessons(module: int) -> list[dict]:
    """Уроки модуля у форматі знімка assessment_source_snapshot.json (як їх запише SQL curriculum_a0_v4)."""
    c = V.build_course(module)
    out = []
    for key in sorted(V.MODULES[module]['lessons']):
        L = c.lessons[key]
        m, o = key
        n = V.NUMBER[key]
        out.append({
            'id': V.lesson_id(m, o), 'order': o,
            'title_ua': f'Урок {n}: {L["title"][0]}', 'title_hr': f'Lekcija {n}: {L["title"][1]}',
            'dialogues': [{'id': V.uid('conversation_v4', V.LEVEL, m, o, si), 'title_ua': s_ua, 'title_hr': s_hr,
                           'turns': [{'speaker': sp, 'hr': hr, 'ua': ua} for sp, hr, ua in turns]}
                          for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1)],
            'exercises': [{'type': ex['type'], 'q': ex['question'], 'a': ex['answer'], 'options': ex['options'], 'skill': ex['skill']}
                          for ex in c.lesson_exercises(key)],
        })
    return out


# Репліки, що відповідають не на питання, а повторюють слово, яке пояснюють («Naravno. Hvala!» — тобто «Звісно. „Hvala“!»):
# поза діалогом як «доречна відповідь» вони заплутують, тож у «Спілкуюся» їх не беремо
META_REPLIES = {'naravno hvala'}
_generic = A.generic
A.generic = lambda s: _generic(s) or A.norm(s) in META_REPLIES


def level_a0() -> dict:
    data = json.loads(A.SNAPSHOT.read_text(encoding='utf-8'))
    level = copy.deepcopy(next(L for L in data['levels'] if L['level'] == 'A0'))
    for m in level['modules']:
        if m['order'] in REBUILT:
            m['lessons'] = v4_lessons(m['order'])
    return level


def tests() -> list[dict]:
    out = []
    for t in A.build_level(level_a0()):
        if t['kind'] == 'module' and t['module'] in TARGET:
            for it in t['items']:
                it['id'] = A.uid('assessment', t['slug'], 'v4', 'item', it['order'])  # нові id: старі завдання лишаються як DEPRECATED
            out.append(t)
    return out


def item_row(t: dict, it: dict) -> str:
    q, qj = A.q, A.qj
    lesson_sql = f"(select id from public.lessons where id = {q(it['lesson'])})" if it['lesson'] else 'null'
    return (f"  ({q(it['id'])}, v_aid, {it['order']}, 'A0', {q(it['skill'])}, {q(it['area'])}, {q(it['item_type'])}, "
            f"{q(it['prompt_ua'])}, {q(it['prompt_hr'])}, {qj(it['options'])}, "
            f"{it['correct_index'] if it['correct_index'] is not None else 'null'}, {q(it['answer_text'])}, "
            f"{q(it['audio_hr'])}, {q(it['passage_hr'])}, {q(it['passage_ua'])}, {q(it['explanation_ua'])}, {lesson_sql}, "
            f"{q(A.STATUS)}, {q(A.SOURCE)})")


def build() -> str:
    q = A.q
    ts = tests()
    needs = ('уроки curriculum_a0_v4 (A0.1 — m01, A0.2 — m02)' if TARGET == [1, 2]
             else ', '.join(f'уроки curriculum_a0_v4 модуля A0.{m} ({V.MODULES[m]["out"].name})' for m in TARGET))
    out = [f"""-- =====================================================================
-- Перевірки модулів A0 під уроки за темою (curriculum_a0_v4) · {'2026-10-19' if TARGET == [1, 2] else V.REVIEW_DATE[TARGET[0]]}
-- Згенеровано: python3 -B scripts/gen_assessment_a0_v4.py (не редагуйте вручну).
--
-- Тести: {', '.join(t['slug'] for t in ts)} — по {len(ts[0]['items'])} завдань із нових діалогів і вправ модулів A0.{', A0.'.join(str(m) for m in TARGET)}.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A0). Середину й фінал рівня A0 не змінено.
--   * Потрібні: 20261015_assessments_a0_v1.sql і {needs}.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;
"""]
    for t in ts:
        rows = ',\n'.join(item_row(t, it) for it in t['items'])
        out.append(f"""-- {t['title_ua']} · {t.get('module_title') or ''}
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = {q(t['slug'])};
  if v_aid is null then raise exception 'Немає тесту {t['slug']} — спершу 20261015_assessments_a0_v1.sql'; end if;
  if exists (select 1 from public.assessment_items where id = {q(t['items'][0]['id'])}) then return; end if;  -- уже оновлено
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
    first_ids = ', '.join(q(it['id']) for t in ts for it in t['items'])
    n_items = sum(len(t['items']) for t in ts)
    out.append(f"""-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ({first_ids}) and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ({slugs})
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'
                     and i.id not in ({first_ids})));
  if v_new <> {n_items} or v_bad > 0 then raise exception 'Перевірки модулів: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірки модулів {", ".join(t["slug"] for t in ts)} оновлено — % нових завдань', v_new;
end $$;

commit;
""")
    return '\n'.join(out)


def report() -> str:
    lines = ['## Перевірки модулів (оновлено під нові уроки)', '']
    for t in tests():
        lines += [f"### `{t['slug']}` {t['title_ua']}", '', '| # | Навичка | Завдання | Відповідь |', '|---|---|---|---|']
        for it in t['items']:
            prompt = it['prompt_ua'] + (f" *{it['prompt_hr']}*" if it['prompt_hr'] and it['kind'] != 'read' else '')
            if it['audio_hr'] and it['kind'] == 'listen':
                prompt += f" 🔊 *{it['audio_hr']}*"
            ans = it['options'][it['correct_index']] if it['correct_index'] is not None else it['answer_text']
            lines.append(f"| {it['order']} | {A.KIND_UA[it['kind']]} | {prompt.replace(chr(10), ' ')} | {ans} |")
        lines.append('')
    return '\n'.join(lines)


def main():
    if '--report' in sys.argv:
        print(report())
        return
    sql = build()
    out = OUT_FIRST if TARGET == [1, 2] else Path(str(OUT_MODULE).format(ymd(TARGET[0]), TARGET[0])) if len(TARGET) == 1 else None
    if out is None:
        raise SystemExit('Вкажіть «1 2» або один модуль')
    out.write_text(sql, encoding='utf-8')
    print(f'{out.relative_to(ROOT)}: {len(sql.encode()) // 1024} КБ')


if __name__ == '__main__':
    main()
