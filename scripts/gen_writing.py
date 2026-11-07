#!/usr/bin/env python3
"""
Письмо й переказ в уроках (§57, §58) — партії після пілоту 2026-11-05.

  python3 -B scripts/gen_writing.py <партія>            →  supabase/data_fixes/<DATE>_writing_<партія>.sql
  python3 -B scripts/gen_writing.py <партія> --review   →  content/reviews/<дата>_writing_<партія>.md (для носія)

Дані — scripts/writing_data_<партія>.py (LESSONS, DATE, TITLE, LEVELS, MEDIATION_SITUATION; формат як у пілоті).
На кожен урок — «Напишіть повідомлення» (write_message) і «Перекажіть другу» (mediation): у кінці вправ уроку,
необов’язкові (required = false). Перевірка даних — та сама логіка, що в lib/writing.ts: кожен зразок виконує всі пункти,
пункти не зараховуються на порожню відповідь, хорватське — без кирилиці, урок не з пілоту чи іншої партії.
Повторний запуск SQL нічого не змінює (id вправ — uuid5 від уроку й типу, той самий простір, що в пілоті).
Пілот (scripts/gen_writing_pilot_20261105.py) не змінено — його SQL уже в робочій базі.
"""
from __future__ import annotations

import importlib
import json
import re
import sys
import uuid
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE))

ROOT = HERE.resolve().parent
# Той самий простір імен, що в пілоті: id вправи однозначно визначається уроком і типом.
NS = uuid.uuid5(uuid.NAMESPACE_URL, 'croatia-survival/writing-pilot-20261105')
CYR = re.compile(r'[Ѐ-ӿ]')
DIRECTIONS = {'hr_ua', 'ua_hr'}


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


def load(batch: str):
    if not re.fullmatch(r'[a-z0-9_]+', batch):
        sys.exit(f'Невірна назва партії: {batch}')
    return importlib.import_module(f'writing_data_{batch}')


def direction(D, spec: dict) -> str:
    return spec.get('direction', 'hr_ua')


def task_of(D, kind: str, spec: dict) -> dict:
    points = [{'ua': ua, 'keys': keys} for ua, keys in spec['points']]
    if kind == 'write_message':
        return {'situation_ua': spec['situation'], 'points': points, 'hints': spec['hints'], 'models': spec['models']}
    d = direction(D, spec)
    task = {'situation_ua': spec.get('situation', D.MEDIATION_SITUATION), 'friend_ua': spec['friend'],
            'direction': d, 'points': points, 'hints': spec.get('hints', []), 'models': spec['models']}
    if d == 'hr_ua':
        task['source_hr'] = spec['source']
    else:
        task['source_ua'] = spec['source']
    return task


def other_lessons(batch: str) -> dict[str, str]:
    """Уроки пілоту й інших партій: урок не може отримати вправи двічі."""
    out = {}
    import writing_pilot_20261105_data as P  # noqa: PLC0415
    for lid in P.LESSONS:
        out[lid] = 'пілот 2026-11-05'
    for f in sorted(HERE.glob('writing_data_*.py')):
        name = f.stem.removeprefix('writing_data_')
        if name == batch:
            continue
        for lid in importlib.import_module(f.stem).LESSONS:
            out[lid] = f'партія {name}'
    return out


def validate(batch: str, D) -> list[str]:
    errors = []
    taken = other_lessons(batch)
    for lid, L in D.LESSONS.items():
        t = L['title']
        if lid in taken:
            errors.append(f'{t}: урок уже має вправи ({taken[lid]})')
        if L['level'] not in D.LEVELS:
            errors.append(f'{t}: рівень {L["level"]} не з {sorted(D.LEVELS)}')
        w, m = L['write'], L['mediation']
        d = direction(D, m)
        if d not in DIRECTIONS:
            errors.append(f'{t}: напрям переказу {d}')
        for model in w['models']:
            if CYR.search(model):
                errors.append(f'{t}: кирилиця в хорватському зразку «{model}»')
            for ua, keys in w['points']:
                if not point_done(model, keys, 'hr'):
                    errors.append(f'{t} / письмо: зразок «{model}» не виконує пункт «{ua}»')
        for h in w['hints']:
            if CYR.search(h):
                errors.append(f'{t}: кирилиця в підказці «{h}»')
        if not CYR.search(w['situation']):
            errors.append(f'{t}: ситуація має бути українською')
        m_lang = 'ua' if d == 'hr_ua' else 'hr'
        src_cyr = bool(CYR.search(m['source']))
        if src_cyr != (d == 'ua_hr'):
            errors.append(f'{t}: мова тексту для переказу не відповідає напряму {d}')
        for model in m['models']:
            if bool(CYR.search(model)) != (m_lang == 'ua'):
                errors.append(f'{t}: мова зразка переказу не відповідає напряму {d}')
            for ua, keys in m['points']:
                if not point_done(model, keys, m_lang):
                    errors.append(f'{t} / переказ: зразок «{model}» не виконує пункт «{ua}»')
        for kind, spec, lang in (('письмо', w, 'hr'), ('переказ', m, m_lang)):
            if not 1 <= len(spec['points']) <= 5:
                errors.append(f'{t} / {kind}: 1–5 пунктів')
            if not spec['models']:
                errors.append(f'{t} / {kind}: немає зразка')
            for ua, keys in spec['points']:
                if not ua or not keys or any(not k for k in keys):
                    errors.append(f'{t} / {kind}: порожній пункт або ключ')
            junk = 'Da, ne.' if lang == 'hr' else 'Так, ні.'
            if all(point_done(junk, keys, lang) for _, keys in spec['points']):
                errors.append(f'{t} / {kind}: пункти зараховуються на «{junk}»')
    return errors


def rows(D) -> list[dict]:
    out = []
    for lid, L in D.LESSONS.items():
        for kind, key, skill in (('write_message', 'write', 'writing'), ('mediation', 'mediation', 'mediation')):
            task = task_of(D, kind, L[key])
            out.append({
                'id': str(uuid.uuid5(NS, f'{lid}/{kind}')), 'lesson': lid, 'type': kind, 'level': L['level'], 'skill': skill,
                'question': task['situation_ua'], 'answer': task['models'][0][:500], 'task': task,
            })
    return out


def sql(batch: str, D) -> str:
    data = rows(D)
    n = len(D.LESSONS)
    lessons = ', '.join(q(x) + '::uuid' for x in D.LESSONS)
    note = (f'writing {D.DATE} ({batch}): «Напишіть повідомлення» і «Перекажіть другу» (§57, §58), {D.TITLE}. '
            'Бета (рішення власника 2026-11-07), потрібна перевірка носієм.')
    return f"""-- =====================================================================
-- Письмо й переказ в уроках: {D.TITLE} · {D.DATE[:4]}-{D.DATE[4:6]}-{D.DATE[6:]}
-- Згенеровано: python3 -B scripts/gen_writing.py {batch} (не редагуйте вручну).
-- Рішення власника 2026-11-07: «пілот підходить, додавай письмо й переказ у решту модулів A0 і A1».
--
--   * {n} уроків × 2 = {len(data)} вправ: у кінці вправ уроку, необов’язкові (required = false).
--   * Завдання (ситуація, пункти з ключами, підказки, зразки) — у колонці exercises.task. Статус PUBLISHED — бета.
--   * Потрібна міграція M19. Повторний запуск нічого не змінює.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $writing$
declare
  r record;
  v_ord int;
  v_ex int := 0;
  v_items int := 0;
begin
  if not exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'exercises' and column_name = 'task') then
    raise exception 'Спершу потрібна міграція M19 (supabase/migrations/20261105100000_m19_writing_mediation.sql)';
  end if;
  if (select count(*) from public.lessons where id in ({lessons}) and status = 'PUBLISHED') <> {n} then
    raise exception 'Не всі {n} уроків ({D.TITLE}) знайдено серед опублікованих';
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
      values ('exercise', r.id, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(note)});
    end if;
    if not exists (select 1 from public.lesson_items where lesson_id = r.lesson and item_type = 'exercise' and item_id = r.id) then
      select coalesce(max(order_index), 0) + 1 into v_ord from public.lesson_items where lesson_id = r.lesson;
      insert into public.lesson_items (id, lesson_id, item_type, item_id, order_index, required, target_skill)
      values (gen_random_uuid(), r.lesson, 'exercise', r.id, v_ord, false, r.skill);
      v_items := v_items + 1;
    end if;
  end loop;

  -- Самоперевірка: у кожному уроці партії — рівно по одній вправі кожного типу з коректним завданням
  if exists (
    select 1 from unnest(array[{lessons}]) as l(id), unnest(array['write_message', 'mediation']) as k(t)
    where (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
           where li.lesson_id = l.id and li.item_type = 'exercise' and e.exercise_type = k.t and e.status = 'PUBLISHED'
             and not li.required and jsonb_array_length(e.task -> 'points') between 1 and 5) <> 1) then
    raise exception 'Не в кожному уроці партії рівно одна вправа кожного типу';
  end if;
  raise notice 'Готово: письмо й переказ ({D.TITLE}) — вправ створено %, додано в уроки % (усього в партії {len(data)})', v_ex, v_items;
end
$writing$;

commit;
"""


def review(batch: str, D) -> str:
    d = f'{D.DATE[:4]}-{D.DATE[4:6]}-{D.DATE[6:]}'
    out = [f'# Письмо й переказ: {D.TITLE} — для носія мови ({d})', '',
           f'Згенеровано: `python3 -B scripts/gen_writing.py {batch} --review`. Бета (опубліковано одразу, рішення власника '
           '2026-11-07). Перевірка відповіді — без AI, за ключовими словами (`lib/writing.ts`).', '',
           '**Що глянути носію:** природність хорватських ситуацій і текстів для переказу (вивіски, SMS, оголошення), '
           'зразкові відповіді, підказки. Позначте рядок і напишіть, як краще.', '']
    for lid, L in D.LESSONS.items():
        w, m = L['write'], L['mediation']
        out += [f'## {L["title"]}', '', f'**Напишіть повідомлення.** {w["situation"]}', '',
                'Пункти: ' + '; '.join(ua for ua, _ in w['points']) + '.', '',
                'Підказки: ' + ', '.join(f'*{h}*' for h in w['hints']), '']
        out += [f'- Зразок: *{x}*' for x in w['models']]
        src = m['source'].replace('\n', ' / ')
        out += ['', f'**Перекажіть другу.** Текст: «*{src}*». Друг: «{m["friend"]}»', '',
                'Пункти: ' + '; '.join(ua for ua, _ in m['points']) + '.', '']
        out += [f'- Зразок: {x}' for x in m['models']]
        out += ['']
    return '\n'.join(out)


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    batch = sys.argv[1]
    D = load(batch)
    errors = validate(batch, D)
    if errors:
        print('ПОМИЛКИ:', *errors, sep='\n  ')
        sys.exit(1)
    if '--review' in sys.argv:
        out = ROOT / 'content' / 'reviews' / f'{D.DATE[:4]}-{D.DATE[4:6]}-{D.DATE[6:]}_writing_{batch}.md'
        out.write_text(review(batch, D), encoding='utf-8')
        print(f'OK → {out.relative_to(ROOT)}')
        return
    out = ROOT / 'supabase' / 'data_fixes' / f'{D.DATE}_writing_{batch}.sql'
    s = sql(batch, D)
    out.write_text(s, encoding='utf-8')
    print(f'OK → {out.relative_to(ROOT)}: {len(s.encode()) // 1024} КБ, вправ {len(rows(D))}')


if __name__ == '__main__':
    main()
