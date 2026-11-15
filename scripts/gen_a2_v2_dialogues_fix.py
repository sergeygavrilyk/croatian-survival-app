#!/usr/bin/env python3
"""
A2 v2: діалоги ≥ 6 реплік (2026-11-15) — пакет змін до вже запущених SQL A2 v2.

  python3 -B scripts/gen_a2_v2_dialogues_fix.py           →  supabase/data_fixes/20261115_a2_v2_dialogues_6_turns.sql
  python3 -B scripts/gen_a2_v2_dialogues_fix.py --report  →  що змінено (у консоль)

У базі 172 діалоги A2 v2, з них 97 мали 4–5 реплік (у середньому 5,3; правило — не менше 6). Репліки додано в даних модулів
(scripts/curriculum_a2_v2_m*.py) — у кінець діалогу, тож id і текст наявних реплік не змінюються. Цей скрипт будує
діалоги двічі — за комітом BASE_COMMIT (як у базі) і за поточними даними — і пише SQL лише з новими репліками.
Слова, вправи, письмо й перевірки рівня цей пакет не чіпає (скрипт зупиняється, якщо вони змінилися).
Завдання перевірок рівня, які генератор тепер добрав би інакше, не змінюються: перевірки A2 у базі «заморожені».
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
import tarfile
import tempfile
from io import BytesIO
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BASE_COMMIT = 'a87179d'  # main 2026-11-14 (PR #43): дані A2 v2 = база (останній пакет A2 v2 — u1_review_fix, PR #20)
OUT = ROOT / 'supabase' / 'data_fixes' / '20261115_a2_v2_dialogues_6_turns.sql'
NOTE = ('a2_v2_dialogues: діалоги A2 доповнено до ≥ 6 реплік (2026-11-15, рішення власника: у діалозі не менше 6 реплік). '
        'Бета, потрібна перевірка носієм.')
MIN_TURNS, MAX_TURNS = 6, 8
CYR = re.compile(r'[а-яіїєґА-ЯІЇЄҐ]')
LAT_IN_UA = re.compile(r'[a-zčćđšž]{2,}', re.I)
SERB = re.compile(r'\b(da li|treba da|biti ću|hiljad\w*|tačno|uopšte|šta|gde|lep\w*|ko je|vreme|mleko|dete|deca|sedi)\b', re.I)


def dump() -> dict:
    """Запускається в підпроцесі з потрібною копією scripts/ на sys.path; друкує JSON."""
    import gen_curriculum_a2_v2 as V
    out = {}
    for m in sorted(V.D.PROGRAM):
        c = V.build_course(m)
        for key in sorted(c.lessons):
            mm, o = key
            L = c.lessons[key]
            exs = [[ex['type'], ex['question'], ex['answer'], ex.get('options')] for ex in c.lesson_exercises(key)]
            scenes = []
            for si, (s_ua, s_hr, ts) in enumerate(L['scenes'], 1):
                scenes.append({'conv': V.uid('conversation_a2v2', V.LEVEL, mm, o, si), 'title': s_hr,
                               'turns': [{'id': V.uid('turn_a2v2', V.LEVEL, mm, o, si, ti), 'order': ti,
                                          'speaker': sp, 'hr': hr, 'ua': ua} for ti, (sp, hr, ua) in enumerate(ts, 1)]})
            out[V.lesson_id(mm, o)] = {'place': f'A2 урок {V.PLACE[key]}', 'words': L['words'], 'exercises': exs, 'scenes': scenes}
    return out


def snapshot(scripts_dir: Path) -> dict:
    code = (f'import sys, json; sys.path.insert(0, {str(scripts_dir)!r}); sys.argv = ["x"]; '
            f'sys.path.append({str(Path(__file__).parent)!r}); import gen_a2_v2_dialogues_fix as F; '
            f'print(json.dumps(F.dump(), ensure_ascii=False))')
    res = subprocess.run([sys.executable, '-B', '-c', code], cwd=scripts_dir, capture_output=True, text=True)
    if res.returncode:
        raise SystemExit(res.stderr[-3000:])
    return json.loads(res.stdout)


def base_scripts(tmp: Path) -> Path:
    data = subprocess.run(['git', 'archive', BASE_COMMIT, 'scripts', 'lib'], cwd=ROOT, capture_output=True, check=True).stdout
    with tarfile.open(fileobj=BytesIO(data)) as tf:
        tf.extractall(tmp, filter='data')
    return tmp / 'scripts'


def diff(old: dict, new: dict) -> tuple[list, list[str]]:
    added, errors = [], []
    for lid, nl in new.items():
        ol = old[lid]
        if ol['words'] != nl['words'] or ol['exercises'] != nl['exercises']:
            errors.append(f'{nl["place"]}: змінилися слова чи вправи — потрібен інший пакет')
        for so, sn in zip(ol['scenes'], nl['scenes']):
            n = len(sn['turns'])
            if not (MIN_TURNS <= n <= MAX_TURNS):
                errors.append(f'{nl["place"]} «{sn["title"]}»: {n} реплік (має бути {MIN_TURNS}–{MAX_TURNS})')
            if sn['turns'][:len(so['turns'])] != so['turns']:
                errors.append(f'{nl["place"]} «{sn["title"]}»: змінено наявні репліки (дозволено лише додати в кінець)')
            for t in sn['turns'][len(so['turns']):]:
                if CYR.search(t['hr']) or CYR.search(t['speaker']):
                    errors.append(f'{nl["place"]}: кирилиця в хорватській репліці {t["hr"]!r}')
                if not CYR.search(t['ua']) or LAT_IN_UA.search(t['ua']):
                    errors.append(f'{nl["place"]}: переклад не українською {t["ua"]!r}')
                if SERB.search(t['hr']):
                    errors.append(f'{nl["place"]}: сербізм / не хорватська норма {t["hr"]!r}')
                if t['hr'][-1] not in '.!?…' or t['ua'][-1] not in '.!?…':
                    errors.append(f'{nl["place"]}: без розділового знака в кінці {t["hr"]!r}')
                if (t['hr'][-1] == '?') != (t['ua'][-1] == '?'):
                    errors.append(f'{nl["place"]}: знак питання лише з одного боку {t["hr"]!r}')
                said = ' '.join(x['hr'] for x in so['turns'])
                if t['speaker'] not in {x['speaker'] for x in so['turns']} and t['speaker'][:4] not in said:
                    errors.append(f'{nl["place"]}: новий мовець {t["speaker"]!r} — у діалозі його немає й до нього не звертаються')
                added.append((nl['place'], sn['conv'], sn['title'], t))
    return added, errors


def q(s) -> str:
    return 'null' if s is None else "'" + str(s).replace("'", "''") + "'"


def build(added: list) -> str:
    convs = sorted({c for _p, c, _t, _x in added})
    data = [{'id': t['id'], 'conv': c, 'speaker': t['speaker'], 'hr': t['hr'], 'ua': t['ua'], 'ord': t['order']}
            for _p, c, _t, t in added]
    payload = q(json.dumps(data, ensure_ascii=False)) + '::jsonb'
    return f"""-- =====================================================================
-- A2 v2: діалоги ≥ 6 реплік · 2026-11-15
-- Згенеровано: python3 -B scripts/gen_a2_v2_dialogues_fix.py (не редагуйте вручну).
--
-- Пакети 20261112_curriculum_a2_v2_* уже запущено (PR #19, #20). Тут лише нові репліки в кінці {len(convs)} діалогів
-- (було 4–5 реплік, стало 6): нових реплік {len(added)}. Наявні репліки, слова, вправи й перевірки рівня не змінюються.
-- Ідемпотентно: id реплік детерміновані, on conflict do nothing — повторний запуск нічого не додає.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if (select count(*) from public.conversations where id in ({', '.join(q(c) for c in convs)})) <> {len(convs)} then
    raise exception 'Спершу мають бути запущені пакети 20261112_curriculum_a2_v2_m01…m14';
  end if;
end $$;

insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
select t.id, t.conv, t.speaker, t.hr, t.ua, t.ord
  from jsonb_to_recordset({payload})
    as t(id uuid, conv uuid, speaker text, hr text, ua text, ord int)
on conflict (id) do nothing;

-- журнал перевірки (один запис на діалог)
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'conversation', c.id, c.status, c.status, 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE)}
  from public.conversations c
 where c.id in ({', '.join(q(c) for c in convs)})
   and not exists (select 1 from public.content_reviews r where r.entity_id = c.id and r.notes = {q(NOTE)});

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_short int; v_long int; v_new int; v_gap int;
begin
  select count(*) into v_short from public.conversations c join public.lessons l on l.id = c.lesson_id
   where l.level_code = 'A2' and c.source = 'claude_curriculum_a2_v2'
     and (select count(*) from public.conversation_turns t where t.conversation_id = c.id) < {MIN_TURNS};
  select count(*) into v_long from public.conversations c join public.lessons l on l.id = c.lesson_id
   where l.level_code = 'A2' and c.source = 'claude_curriculum_a2_v2'
     and (select count(*) from public.conversation_turns t where t.conversation_id = c.id) > {MAX_TURNS};
  select count(*) into v_new from public.conversation_turns where id in (select (x->>'id')::uuid from jsonb_array_elements({payload}) x);
  -- порядок реплік без пропусків і повторів: 1…N
  select count(*) into v_gap from (
    select t.conversation_id from public.conversation_turns t
     where t.conversation_id in ({', '.join(q(c) for c in convs)})
     group by t.conversation_id having count(distinct t.order_index) <> count(*) or max(t.order_index) <> count(*)) g;
  if v_short > 0 then raise exception 'Діалоги A2: % діалогів коротші за {MIN_TURNS} реплік', v_short; end if;
  if v_long > 0 then raise exception 'Діалоги A2: % діалогів довші за {MAX_TURNS} реплік', v_long; end if;
  if v_new <> {len(added)} then raise exception 'Діалоги A2: нових реплік % замість {len(added)}', v_new; end if;
  if v_gap > 0 then raise exception 'Діалоги A2: у % діалогах порядок реплік з пропусками', v_gap; end if;
  raise notice 'Готово: діалоги A2 — додано {len(added)} реплік у {len(convs)} діалогів, коротших за {MIN_TURNS} реплік немає';
end $$;

commit;
"""


def main():
    with tempfile.TemporaryDirectory() as tmp:
        old = snapshot(base_scripts(Path(tmp)))
    new = snapshot(Path(__file__).resolve().parent)
    added, errors = diff(old, new)
    if errors:
        print('Перевірка не пройдена:', *errors, sep='\n  ', file=sys.stderr)
        sys.exit(1)
    if '--report' in sys.argv:
        print(f'нових реплік {len(added)} у {len({c for _p, c, _t, _x in added})} діалогах')
        for place, _c, title, t in added:
            print(f'{place} «{title}»: {t["speaker"]}: {t["hr"]} — {t["ua"]}')
        return
    sql = build(added)
    OUT.write_text(sql, encoding='utf-8')
    print(f'{OUT.relative_to(ROOT)}: {len(sql.encode()) // 1024} КБ, реплік {len(added)}')


if __name__ == '__main__':
    main()
