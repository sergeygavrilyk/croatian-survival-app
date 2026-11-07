#!/usr/bin/env python3
"""
Пілот письма й переказу в уроках A0.1 і A1.1 · 2026-11-05.

  python3 -B scripts/gen_writing_pilot_20261105.py  →  supabase/data_fixes/20261105_writing_pilot.sql

На кожен урок модулів A0.1 і A1.1 — «Напишіть повідомлення» (write_message) і «Перекажіть другу» (mediation, hr → ua).
Потрібна міграція M19. Вправи — у кінці списку вправ уроку, необов’язкові (required = false, можна пропустити).
Перевірка даних: кожен зразок має виконувати всі пункти (та сама логіка, що в lib/writing.ts), хорватське — без кирилиці.
Повторний запуск нічого не змінює (id вправ — uuid5 від уроку й типу).
"""
from __future__ import annotations

import json
import re
import sys
import uuid
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
import writing_pilot_20261105_data as D  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'supabase' / 'data_fixes' / '20261105_writing_pilot.sql'
NS = uuid.uuid5(uuid.NAMESPACE_URL, 'croatia-survival/writing-pilot-20261105')
NOTE = ('writing_pilot 2026-11-05: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58), модулі A0.1 і A1.1. '
        'Бета (рішення власника), потрібна перевірка носієм.')
CYR = re.compile(r'[Ѐ-ӿ]')


def q(s) -> str:
    return 'null' if s is None else "'" + str(s).replace("'", "''") + "'"


def qj(v) -> str:
    return q(json.dumps(v, ensure_ascii=False)) + '::jsonb'


# ---------------------------------------------------------------- та сама перевірка, що в lib/writing.ts
def words_of(text: str, lang: str) -> list[str]:
    t = re.sub(r"[’ʼ`]", "'", text.lower())
    if lang == 'hr':
        t = t.replace('č', 'c').replace('ć', 'c').replace('đ', 'd').replace('š', 's').replace('ž', 'z')
    return [w.strip("'") for w in re.split(r"[^\w']+", t) if w.strip("'") and not w.strip("'") == '_']


def stem_matches(words: list[str], stem: str, lang: str) -> bool:
    exact = stem.endswith('=')
    parts = words_of(stem[:-1] if exact else stem, lang)
    if not parts:
        return False
    for i in range(len(words) - len(parts) + 1):
        if all((words[i + j].startswith(p) if j == len(parts) - 1 and not exact else words[i + j] == p)
               for j, p in enumerate(parts)):
            return True
    return False


def point_done(text: str, keys: list[list[str]], lang: str) -> bool:
    w = words_of(text, lang)
    return any(all(stem_matches(w, s, lang) for s in key) for key in keys)


def task_of(kind: str, spec: dict) -> dict:
    points = [{'ua': ua, 'keys': keys} for ua, keys in spec['points']]
    if kind == 'write_message':
        return {'situation_ua': spec['situation'], 'points': points, 'hints': spec['hints'], 'models': spec['models']}
    return {'situation_ua': D.MEDIATION_SITUATION, 'source_hr': spec['source'], 'friend_ua': spec['friend'],
            'direction': 'hr_ua', 'points': points, 'hints': [], 'models': spec['models']}


def validate() -> list[str]:
    errors = []
    for lid, L in D.LESSONS.items():
        w, m = L['write'], L['mediation']
        for model in w['models']:
            if CYR.search(model):
                errors.append(f'{L["title"]}: кирилиця в хорватському зразку «{model}»')
            for ua, keys in w['points']:
                if not point_done(model, keys, 'hr'):
                    errors.append(f'{L["title"]} / письмо: зразок «{model}» не виконує пункт «{ua}»')
        for h in w['hints']:
            if CYR.search(h):
                errors.append(f'{L["title"]}: кирилиця в підказці «{h}»')
        if CYR.search(m['source']):
            errors.append(f'{L["title"]}: кирилиця в хорватському тексті переказу')
        for model in m['models']:
            if not CYR.search(model):
                errors.append(f'{L["title"]}: зразок переказу має бути українською')
            for ua, keys in m['points']:
                if not point_done(model, keys, 'ua'):
                    errors.append(f'{L["title"]} / переказ: зразок «{model}» не виконує пункт «{ua}»')
        for kind, spec in (('письмо', w), ('переказ', m)):
            if not 1 <= len(spec['points']) <= 5:
                errors.append(f'{L["title"]} / {kind}: 1–5 пунктів')
            # пункт не має зараховуватися на порожній / нерелевантній відповіді
            lang = 'hr' if kind == 'письмо' else 'ua'
            junk = 'Da, ne.' if lang == 'hr' else 'Так, ні.'
            if all(point_done(junk, keys, lang) for _, keys in spec['points']):
                errors.append(f'{L["title"]} / {kind}: пункти зараховуються на «{junk}»')
    return errors


def rows() -> list[dict]:
    out = []
    for lid, L in D.LESSONS.items():
        for kind, key, skill in (('write_message', 'write', 'writing'), ('mediation', 'mediation', 'mediation')):
            spec = L[key]
            task = task_of(kind, spec)
            out.append({
                'id': str(uuid.uuid5(NS, f'{lid}/{kind}')), 'lesson': lid, 'type': kind, 'level': L['level'], 'skill': skill,
                'question': task['situation_ua'], 'answer': task['models'][0][:500], 'task': task,
            })
    return out


def sql() -> str:
    data = rows()
    lessons = ', '.join(q(x) + '::uuid' for x in D.LESSONS)
    return f"""-- =====================================================================
-- Пілот: «Напишіть повідомлення» і «Перекажіть другу» в уроках A0.1 і A1.1 · 2026-11-05
-- Згенеровано: python3 -B scripts/gen_writing_pilot_20261105.py (не редагуйте вручну).
-- Рішення власника 2026-11-05: письмо й переказ у кожному уроці; перевірка без AI; вправи можна пропустити;
--   переказ хорватське → українське (до A1.10); зберігаємо лише текст відповіді.
--
--   * {len(D.LESSONS)} уроків (A0.1 — 4, A1.1 — 10) × 2 = {len(data)} вправ: у кінці вправ уроку, необов’язкові.
--   * Завдання (ситуація, пункти з ключами, підказки, зразки) — у колонці exercises.task. Статус PUBLISHED — бета.
--   * Потрібна міграція M19 (20261105100000_m19_writing_mediation.sql). Повторний запуск нічого не змінює.
-- Після нього: тест supabase/tests/writing_mediation.test.sql → «ALL TESTS PASSED».
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $pilot$
declare
  r record;
  v_ord int;
  v_ex int := 0;
  v_items int := 0;
begin
  if not exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'exercises' and column_name = 'task') then
    raise exception 'Спершу запустіть міграцію M19 (supabase/migrations/20261105100000_m19_writing_mediation.sql)';
  end if;
  if (select count(*) from public.lessons where id in ({lessons}) and status = 'PUBLISHED') <> {len(D.LESSONS)} then
    raise exception 'Не всі {len(D.LESSONS)} уроків A0.1 / A1.1 опубліковані';
  end if;

  for r in select * from jsonb_to_recordset({qj(data)})
      as t(id uuid, lesson uuid, type text, level text, skill text, question text, answer text, task jsonb)
  loop
    insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, task)
    values (r.id, r.type, r.question, r.answer, null, r.level, 0, 'PUBLISHED', r.task)
    on conflict (id) do nothing;
    if found then
      v_ex := v_ex + 1;
      insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
      values ('exercise', r.id, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE)});
    end if;
    if not exists (select 1 from public.lesson_items where lesson_id = r.lesson and item_type = 'exercise' and item_id = r.id) then
      select coalesce(max(order_index), 0) + 1 into v_ord from public.lesson_items where lesson_id = r.lesson;
      insert into public.lesson_items (id, lesson_id, item_type, item_id, order_index, required, target_skill)
      values (gen_random_uuid(), r.lesson, 'exercise', r.id, v_ord, false, r.skill);
      v_items := v_items + 1;
    end if;
  end loop;

  -- Самоперевірка: у кожному уроці пілоту — по одній вправі кожного типу з коректним завданням
  if (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
       where li.item_type = 'exercise' and li.lesson_id in ({lessons}) and e.status = 'PUBLISHED'
         and e.exercise_type in ('write_message', 'mediation') and jsonb_array_length(e.task -> 'points') between 1 and 5) <> {len(data)} then
    raise exception 'Не всі вправи пілоту на місцях';
  end if;
  raise notice 'Готово: вправ створено %, додано в уроки % (усього в пілоті {len(data)})', v_ex, v_items;
end
$pilot$;

commit;
"""


def main():
    errors = validate()
    if errors:
        print('ПОМИЛКИ:', *errors, sep='\n  ')
        sys.exit(1)
    s = sql()
    OUT.write_text(s, encoding='utf-8')
    print(f'OK → {OUT.relative_to(ROOT)}: {len(s.encode()) // 1024} КБ, вправ {len(rows())}')


if __name__ == '__main__':
    main()
