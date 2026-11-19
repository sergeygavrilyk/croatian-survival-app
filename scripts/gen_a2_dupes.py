#!/usr/bin/env python3
"""
Дублі A2 · 2026-11-19 — план docs/proposals/2026-11-16_lesson_duplicates.md, PR 4 (рішення власника 2026-11-17),
і перевірки рівнів A1 і A2 після плану (задача власника 2026-11-19: «Перезібрати перевірки рівнів A1 і A2 після цих змін»).

  python3 -B scripts/gen_a2_dupes.py               →  supabase/data_fixes/20261119_a2_dupes_1_lessons.sql
  python3 -B scripts/gen_a2_dupes.py --check       →  лише перевірка даних (нічого не пише)
  python3 -B scripts/gen_a2_dupes.py --review      →  content/reviews/2026-11-19_a2_dupes.md (для носія)
  python3 -B scripts/gen_a2_dupes.py assessments   →  supabase/data_fixes/20261119_a2_dupes_2_tests_*.sql
                                                       (знімок після пакета 1 — scripts/assessment_a2_dupes_snapshot.json,
                                                        bash scripts/a2_dupes_assessment_snapshot.sh)

Дані — scripts/curriculum_a2_dupes_data.py. Знімок — scripts/curriculum_a2_dupes_snapshot.json (запит — scripts/a2_dupes_source.sql).

Пакет 1 (уроки):
  1. нові слова (з мітками; PUBLISHED — бета); наявні слова без уроку — рівень A2 (стара версія — content_versions);
  2. уроки 33 і 44 (Д8: лікарняний — в уроці 44, урок 33 — лише відпустка), 9 (Д2), 27 (Д1), 29 (Д6), 38 (Д5), 70 (Д7):
     слова — заміна на тому самому місці, діалог — новий замість старого (старий — DEPRECATED), вправи на прибрані слова
     й діалоги — нові на тому самому місці (старі — DEPRECATED), нові цілі, назви уроків 29 і 33;
  3. новий урок A2.11 «Далмація: Задар і околиці» (місце 5, стане уроком 70): 23 слова (đir — лише впізнавати), 2 діалоги,
     15 вправ, письмо й переказ; уроки A2.11 «Звичаї й етикет» і «Клапа…» — місця 6 і 7;
  4. нові назви 6 діалогів з однаковими назвами (у пізнішому уроці);
  5. наскрізні номери всіх уроків A2 (86 → 87), порядок діалогів за новим номером.
  Копії — backup.lesson_items_a2dupes_20261119; старі версії уроків і діалогів — у content_versions.
Пакет 2 (перевірки): усі 15 тестів A1 і 16 тестів A2 наново за схемою 2026-11-07 (генератор v5) з уроків і текстів після
пакета 1: модулі — 2 завдання на урок (12–20), середина — 30, фінал — 48; у середині й фіналі — без джерел і речень тестів
модулів. Повторний запуск кожного пакета нічого не змінює.
"""
from __future__ import annotations

import json
import re
import sys
from collections import Counter
from pathlib import Path
from types import SimpleNamespace

sys.dont_write_bytecode = True
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE))
import curriculum_a2_dupes_data as D  # noqa: E402
import gen_curriculum_a2_v2 as V  # noqa: E402
import gen_writing as GW  # noqa: E402
from full_lessons import CYR, HELPERS_SQL, Place, fold_ua, q, qj, shuffled, uid  # noqa: E402
from lexeme_checks import check_batch, normalize  # noqa: E402

ROOT = HERE.resolve().parent
FIXES = ROOT / 'supabase' / 'data_fixes'
REVIEWS = ROOT / 'content' / 'reviews'
SNAPSHOT = json.loads((HERE / 'curriculum_a2_dupes_snapshot.json').read_text(encoding='utf-8'))
OUT = FIXES / f'{D.DATE}_a2_dupes_1_lessons.sql'
REVIEW_OUT = REVIEWS / '2026-11-19_a2_dupes.md'
LEVEL = 'A2'
MOD = 11
STATUS = 'PUBLISHED'        # бета (A2 — рішення власника 2026-11-12)
SOURCE = 'claude_a2_dupes'
MINUTES = 20
OLD_TOTAL, NEW_TOTAL = 86, 87
POS = V.POS
TASK_TYPES = ('listening_dialogue', 'write_message', 'mediation')
NOTE_LESSON = ('a2_dupes 20261119: план «Дублі й сенс уроків» (PR 4, рішення власника 2026-11-17) — {what}. '
               'Бета, потрібна перевірка носієм.')
NOTE_NEW = ('Бета: новий урок модуля A2.11 «Далмація: Задар і околиці» (рішення власника 2026-11-17: «без слів і діалогів A1-89»; '
            'далматинська говірка — лише впізнавання) за схемою уроків A2 (20–25 слів, 2 діалоги, 15 вправ, письмо й переказ). '
            'Потрібна перевірка носієм.')
NOTE_TASK = 'a2_dupes 20261119: нова вправа «{kind}» в уроці A2 замість старої (план «Дублі», PR 4). Бета, потрібна перевірка носієм.'

ITEMS = SNAPSHOT['items']
CONVS = {c['id']: c for c in SNAPSHOT['conversations']}
TAKEN = SNAPSHOT['lessons']        # lower(лема) → перший урок (усі рівні)
A2 = SNAPSHOT['a2']
BY_ID = {L['id']: L for L in A2}
EXIST = SNAPSHOT['lex']            # наявні слова пакета (лема, переклад, рівень)
NEW_SLUG = D.NEW_LESSON['slug']


# ----------------------------------------------------------------------------- слова
def forms_of(code: str) -> dict:
    return V.forms_of(code)


def vtype_of(pos: str, lemma: str) -> str:
    if lemma in D.FORMULAIC or pos == 'interjection':
        return 'formulaic'
    return {'phrase': 'chunk', 'preposition': 'function_word'}.get(pos, 'core')


def new_lexemes() -> list[dict]:
    rows = []
    for _n, vocab in D.NEW_LEXEMES.items():
        for v in vocab:
            lemma, ua, pos, forms, example = v[:5]
            labels = v[5] if len(v) > 5 else {}
            p = POS[pos]
            row = dict(lemma=lemma, normalized=normalize(lemma), ukrainian_translation=ua, part_of_speech=p, cefr=LEVEL,
                       vocabulary_type=vtype_of(p, lemma), forms=forms_of(forms), examples=[example],
                       register=labels.get('register', 'standard'), regionality=labels.get('regionality', 'general'),
                       usage_tags=list(labels.get('usage_tags', [])), ukrainian_interference=D.INTERFERENCE.get(lemma))
            if labels.get('standard_lemma'):
                row['standard_lemma'] = labels['standard_lemma']
            rows.append(row)
    return rows


NEW = {r['lemma'].lower(): r for r in new_lexemes()}


def lex_map() -> dict:
    lex = {}
    for L in A2:
        for lemma, ua in L['words']:
            lex[lemma.lower()] = (lemma, ua)
    for k, (lemma, ua, _cefr) in EXIST.items():
        lex[k] = (lemma, ua)
    for r in NEW.values():
        lex[r['lemma'].lower()] = (r['lemma'], r['ukrainian_translation'])
    return lex


LEX = lex_map()


def lesson_items(n: int) -> list[dict]:
    return [it for it in ITEMS if it['lesson'] == D.LESSON_IDS[n]]


def words_of(n: int) -> list[str]:
    return [it['lemma'] for it in lesson_items(n) if it['type'] == 'lexeme']


def words_after(n: int) -> list[str]:
    ch = D.CHANGES.get(n, {})
    swap = {o.lower(): w for o, w in ch.get('swap', [])}
    return [swap.get(w.lower(), w) for w in words_of(n)] + list(ch.get('add', []))


def removed_words() -> list[str]:
    return [o for n in sorted(D.CHANGES) for o, _ in D.CHANGES[n].get('swap', [])]


def display_ua(word: str) -> str:
    t = LEX[word.lower()][1].strip().rstrip('.')
    if LEX[word.lower()][0][:1].islower():
        t = ' / '.join(seg if seg[1:2].isupper() else seg[:1].lower() + seg[1:] for seg in t.split(' / '))
    return t


def old_convs(n: int) -> set[str]:
    return {old for old, _new in D.CHANGES[n].get('convs', [])}


def scene_texts(n: int) -> list[str]:
    """Тексти діалогів уроку після змін (для перевірки «прослухайте»)."""
    out = [' '.join(hr for _sp, hr, _ua in c['turns']) for c in SNAPSHOT['conversations']
           if c['lesson'] == D.LESSON_IDS[n] and c['id'] not in old_convs(n)]
    out += [' '.join(hr for _sp, hr, _ua in new[3]) for _old, new in D.CHANGES[n].get('convs', [])]
    return out


# ----------------------------------------------------------------------------- нумерація після змін
def new_order() -> list[tuple]:
    out = []
    for m in range(1, 15):
        keys = [L['id'] for L in A2 if L['module'] == m]
        if m == MOD:
            keys.insert(D.NEW_ORDER - 1, NEW_SLUG)
        out += [(m, k) for k in keys]
    return out


ORDER = new_order()
NUMBER = {k: i for i, (_m, k) in enumerate(ORDER, 1)}
OLD_NUMBER = {L['id']: int(re.match(r'Урок (\d+):', L['title']).group(1)) for L in A2}
NEW_LESSON_ID = uid('lesson_a2dupes', LEVEL, MOD, NEW_SLUG)
MOD11 = [L for L in A2 if L['module'] == MOD]


# ----------------------------------------------------------------------------- новий урок (курс A2 v2)
def build_course() -> V.CourseA2:
    N = D.NEW_LESSON
    L = dict(title=N['title'], situation=N['situation'], grammar=N['grammar'], objectives=N['objectives'], words=N['words'],
             scenes=N['scenes'], fill=N['fill'], build=N['build'], listen=N['listen'], speak=N['speak'], listening=N['listening'],
             write=N['write'], mediation=N['mediation'])
    key = (MOD, D.NEW_ORDER)
    # хибні варіанти — лише слова цього уроку (переклади інших слів A2 у робочій базі місцями інші, ніж у даних A2 v2)
    return V.CourseA2(level=LEVEL, lessons={key: L}, place={key: Place(MOD, D.NEW_ORDER, NUMBER[NEW_SLUG])}, lex=LEX,
                      situations=V.SITUATIONS, grammar_keys=set(V.D.GRAMMAR), seed_prefix='a2dupes', no_vocab=set(D.RECOGNITION),
                      extra_pool=[], extra_module_words={}, words_range=(20, 25), vocab_counts=(3, 2, 3))


def writing_ns() -> SimpleNamespace:
    N = D.NEW_LESSON
    med = dict(N['mediation'])
    med.setdefault('direction', 'ua_hr')
    med.setdefault('source', med['friend'])
    lessons = {NEW_LESSON_ID: dict(title=f'A2 урок {NUMBER[NEW_SLUG]} {N["title"][0]}', level=LEVEL, write=N['write'], mediation=med)}
    return SimpleNamespace(LESSONS=lessons, DATE=D.DATE, TITLE='урок A2.11 «Далмація»', LEVELS={LEVEL},
                           MEDIATION_SITUATION=V.MEDIATION_SITUATION)


def task_of(ex: dict) -> dict:
    """Завдання для вправи з task (як у gen_curriculum_a2_v2 / gen_writing)."""
    if ex['type'] == 'listening_dialogue':
        return V.listening_task({'listening': ex['listening']})
    ns = SimpleNamespace(MEDIATION_SITUATION=V.MEDIATION_SITUATION)
    if ex['type'] == 'write_message':
        return GW.task_of(ns, 'write_message', ex['write'])
    med = dict(ex['mediation'])
    med.setdefault('direction', 'ua_hr')
    med.setdefault('source', med['friend'])
    return GW.task_of(ns, 'mediation', med)


def task_question_answer(ex: dict, task: dict) -> tuple[str, str]:
    if ex['type'] == 'listening_dialogue':
        return V.LISTEN_Q[task['kind']], V.listening_answer(task)[:500]
    return task['situation_ua'], task['models'][0][:500]


def check_writing(kind: str, spec: dict, where: str) -> list[str]:
    """Як GW.validate для одного завдання (без перевірки «урок уже має вправи» — тут вправа замінює стару)."""
    e = []
    lang = 'hr'
    if kind == 'write_message':
        if not CYR.search(spec['situation']):
            e.append(f'{where}: ситуація не українською')
        for h in spec['hints']:
            if CYR.search(h):
                e.append(f'{where}: кирилиця в підказці «{h}»')
    else:
        if not CYR.search(spec['friend']):
            e.append(f'{where}: прохання друга не українською')
    for model in spec['models']:
        if CYR.search(model):
            e.append(f'{where}: кирилиця в хорватському зразку «{model}»')
        for ua, keys in spec['points']:
            if not GW.point_done(model, keys, lang):
                e.append(f'{where}: зразок «{model}» не виконує пункт «{ua}»')
    if not 1 <= len(spec['points']) <= 5:
        e.append(f'{where}: 1–5 пунктів')
    if all(GW.point_done('Da, ne.', keys, lang) for _, keys in spec['points']):
        e.append(f'{where}: пункти зараховуються на «Da, ne.»')
    return e


# ----------------------------------------------------------------------------- перевірка
def old_exercise(n: int, key: str) -> dict | None:
    if key in ('fill_in_the_blank', *TASK_TYPES):
        hits = [it for it in lesson_items(n) if it['type'] == 'exercise' and it['ex_type'] == key]
    else:
        hits = [it for it in lesson_items(n) if it['type'] == 'exercise' and it['answer'] == key]
    return hits[0] if len(hits) == 1 else None


def validate() -> tuple[list[str], list[str]]:
    errors: list[str] = []
    seen_new: dict[str, str] = {}
    for n, vocab in D.NEW_LEXEMES.items():
        for v in vocab:
            k = v[0].lower()
            if k in TAKEN:
                errors.append(f'«{v[0]}» уже є в уроці {TAKEN[k]}')
            if k in EXIST:
                errors.append(f'«{v[0]}» уже є в словнику — має бути серед EXISTING')
            if k in seen_new:
                errors.append(f'«{v[0]}» двічі серед нових ({seen_new[k]}, {n})')
            seen_new[k] = str(n)
    for w in D.EXISTING:
        if w.lower() not in EXIST:
            errors.append(f'наявного «{w}» немає в знімку словника')
        if w.lower() in TAKEN:
            errors.append(f'наявне «{w}» уже є в уроці {TAKEN[w.lower()]}')
    used = [w for n in D.CHANGES for _o, w in D.CHANGES[n].get('swap', [])] + [w for n in D.CHANGES for w in D.CHANGES[n].get('add', [])]
    used += D.NEW_LESSON['words']
    for w in set(seen_new) | {x.lower() for x in D.EXISTING}:
        if sum(1 for u in used if u.lower() == w) != 1:
            errors.append(f'слово «{w}» має бути рівно в одному уроці пакета')
    # прибрані слова: де їх учать далі
    removed = {w.lower() for w in removed_words()} - {w.lower() for w in D.MOVE_33_44}
    planned = {w.lower() for w in D.DICT_ONLY} | {w.lower() for w in D.ELSEWHERE}
    if removed != planned:
        errors.append(f'прибрані слова не розписано (DICT_ONLY / ELSEWHERE): {sorted(removed ^ planned)}')
    for w, where in D.ELSEWHERE.items():
        cur = TAKEN.get(w.lower(), '')
        if not cur.startswith(('A0 ', 'A1 ')):
            errors.append(f'«{w}»: перший урок {cur!r}, а очікувався {where}')
    for w in D.MOVE_33_44:
        moved_in = any(w.lower() == x.lower() for _o, x in D.CHANGES[44]['swap']) or w in D.CHANGES[44].get('add', [])
        if not moved_in or not any(w.lower() == o.lower() for o, _x in D.CHANGES[33]['swap']):
            errors.append(f'«{w}»: має перейти з уроку 33 в урок 44')
    # зміни уроків
    for n, ch in D.CHANGES.items():
        cur = [w.lower() for w in words_of(n)]
        for old, new in ch.get('swap', []):
            if old.lower() not in cur:
                errors.append(f'урок {n}: «{old}» немає серед слів')
            if new.lower() not in LEX:
                errors.append(f'урок {n}: «{new}» немає ні в знімку, ні серед нових')
        for w in ch.get('add', []):
            if w.lower() not in LEX:
                errors.append(f'урок {n}: «{w}» немає в знімку')
        after = words_after(n)
        if not 20 <= len(after) <= 25 or len({w.lower() for w in after}) != len(after):
            errors.append(f'урок {n}: після змін {len(after)} слів або слова повторюються')
        if 'title' in ch and (not CYR.search(ch['title'][0]) or CYR.search(ch['title'][1])):
            errors.append(f'урок {n}: мова нової назви')
        for o in ch.get('objectives', []):
            if not CYR.search(o):
                errors.append(f'урок {n}: ціль не українською')
        for old, (s_ua, s_hr, sit, turns) in ch.get('convs', []):
            if old not in CONVS or CONVS[old]['lesson'] != D.LESSON_IDS[n]:
                errors.append(f'урок {n}: діалогу {old} немає в уроці')
            if sit not in V.SITUATIONS or not 6 <= len(turns) <= 8:
                errors.append(f'урок {n}: ситуація чи кількість реплік нового діалогу «{s_hr}»')
            if not CYR.search(s_ua) or CYR.search(s_hr):
                errors.append(f'урок {n}: мова назви діалогу')
            for sp, hr, ua in turns:
                if CYR.search(hr) or CYR.search(sp) or not CYR.search(ua) or hr != hr.strip() or '  ' in hr:
                    errors.append(f'урок {n}: репліка {hr!r}')
        texts = scene_texts(n)
        ua_of = {display_ua(w): w for w in after}
        hr_of = {w.lower() for w in after}
        replaced = set()
        for key, ex in ch.get('ex', []):
            o = old_exercise(n, key)
            where = f'урок {n}, вправа замість «{key}»'
            if o is None:
                errors.append(f'{where}: стару вправу не знайдено (або їх кілька)')
                continue
            replaced.add(o['item'])
            if o['ex_type'] != ex['type']:
                errors.append(f'{where}: тип {ex["type"]} замість {o["ex_type"]}')
            if ex['type'] == 'multiple_choice':
                opts = ex['options']
                same = ex['question'] == o['question'] and ex['answer'] == o['answer']
                if len(set(opts)) != 4 or ex['answer'] not in opts:
                    errors.append(f'{where}: 4 різні варіанти з правильним')
                if ex['question'].startswith('Що означає'):
                    if any(x not in ua_of for x in opts if not (same and x == ex['answer'])):
                        errors.append(f'{where}: варіанти — переклади слів уроку {[x for x in opts if x not in ua_of]}')
                    if not same and ua_of.get(ex['answer'], '').lower() != ex['word'].lower():
                        errors.append(f'{where}: правильна відповідь — не переклад «{ex["word"]}»')
                else:
                    if any(x.lower() not in hr_of for x in opts) or ex['answer'] != LEX[ex['word'].lower()][0]:
                        errors.append(f'{where}: варіанти — слова уроку {opts}')
                    if display_ua(ex['word']) not in ex['question']:
                        errors.append(f'{where}: у питанні має бути переклад «{display_ua(ex["word"])}»')
                if same and sorted(opts) == sorted(o['options'] or []):
                    errors.append(f'{where}: варіанти не змінились')
            elif ex['type'] == 'type_answer':
                if ex['answer'] != LEX[ex['word'].lower()][0] or display_ua(ex['word']) not in ex['question']:
                    errors.append(f'{where}: «напишіть» — лема й переклад слова уроку')
                others = [w for w in after if w.lower() != ex['word'].lower()]
                if any(fold_ua(display_ua(w)) == fold_ua(display_ua(ex['word'])) for w in others):
                    errors.append(f'{where}: той самий переклад в іншого слова уроку')
                if len(ex['answer']) > 14 or len(ex['answer'].split()) > 2:
                    errors.append(f'{where}: задовга відповідь для «напишіть»')
            elif ex['type'] in ('listening', 'sentence_builder'):
                toks = ex['answer'].split(' ')
                if len(toks) != len(set(toks)) or len(toks) < 3 or CYR.search(ex['answer']):
                    errors.append(f'{where}: речення {ex["answer"]!r}')
                if ex['type'] == 'listening' and not any(ex['answer'] in t for t in texts):
                    errors.append(f'{where}: «прослухайте» не з діалогу уроку')
            elif ex['type'] == 'speaking':
                if CYR.search(ex['answer']) or not CYR.search(ex['question']):
                    errors.append(f'{where}: мова')
            elif ex['type'] == 'fill_in_the_blank':
                if '___' not in ex['question'] or len(set(ex['options'])) != 4 or ex['answer'] not in ex['options'] or CYR.search(ex['question']):
                    errors.append(f'{where}: «вставте» — пропуск і 4 різні варіанти')
            elif ex['type'] == 'listening_dialogue':
                errors += [f'{where}: {e}' for e in V.check_listening(task_of(ex), BY_ID[D.LESSON_IDS[n]]['module'])]
            elif ex['type'] in ('write_message', 'mediation'):
                spec = ex['write'] if ex['type'] == 'write_message' else ex['mediation']
                errors += check_writing(ex['type'], spec, where)
            if 'word' in ex and ex['word'].lower() not in hr_of:
                errors.append(f'{where}: слово «{ex["word"]}» не з уроку')
        # не лишилося вправ на прибрані слова й діалоги; хибних варіантів з прибраних слів
        rem = {o.lower() for o, _ in ch.get('swap', [])}
        rem_ua = {fold_ua(display_ua(o)) for o in rem if o in LEX}
        old_text = ' '.join(hr for cid in old_convs(n) for _s, hr, _u in CONVS[cid]['turns'])
        for it in lesson_items(n):
            if it['type'] != 'exercise' or it['item'] in replaced:
                continue
            if it['lexeme'] and it['lexeme'].lower() in rem:
                errors.append(f'урок {n}: вправа на прибране «{it["lexeme"]}» лишилась: {it["question"]}')
            if it['ex_type'] in ('sentence_builder', 'listening', 'speaking'):
                low = it['answer'].lower()
                for r in rem:
                    if re.search(r'\b' + re.escape(r if len(r) <= 5 else r[:-2]), low):
                        errors.append(f'урок {n}: у вправі «{it["answer"]}» лишилось прибране «{r}»')
                if it['ex_type'] == 'listening' and old_text and it['answer'] in old_text:
                    errors.append(f'урок {n}: «прослухайте» з прибраного діалогу: {it["answer"]}')
            for opt in it['options'] or []:
                if isinstance(opt, str) and it['ex_type'] == 'multiple_choice' and (opt.lower() in rem or fold_ua(opt) in rem_ua):
                    errors.append(f'урок {n}: хибний варіант з прибраного слова «{opt}» у «{it["question"]}»')
    # назви діалогів: нові — унікальні серед A0–A2
    titles_now = {t[2].lower() for t in SNAPSHOT['titles']}
    new_titles = [t[2][1] for t in D.RENAME_CONVS.values()] + [new[1] for n in D.CHANGES for _o, new in D.CHANGES[n].get('convs', [])]
    new_titles += [s[1] for s in D.NEW_LESSON['scenes']]
    for t in new_titles:
        if t.lower() in titles_now or new_titles.count(t) != 1:
            errors.append(f'назва діалогу «{t}» уже є або повторюється')
    for cid, (where, old_t, (t_ua, t_hr)) in D.RENAME_CONVS.items():
        c = CONVS.get(cid)
        if not c or c['title_hr'] != old_t:
            errors.append(f'діалог {where} «{old_t}»: немає в знімку')
        if not CYR.search(t_ua) or CYR.search(t_hr):
            errors.append(f'діалог {where}: мова нової назви')
    dupes = Counter(t[2].lower() for t in SNAPSHOT['titles']
                    if t[0] not in D.RENAME_CONVS and t[0] not in {o for n in D.CHANGES for o in old_convs(n)})
    for t in new_titles:
        dupes[t.lower()] += 1
    left = [t for t, c in dupes.items() if c > 1]
    if left:
        errors.append(f'після змін лишаються однакові назви діалогів A0–A2: {left}')
    # новий урок
    c = build_course()
    key = (MOD, D.NEW_ORDER)
    c.validate_lesson(key)
    exs = c.lesson_exercises(key)
    if len(exs) != 15 or len({e['type'] for e in exs}) < 7:
        c.errors.append(f'новий урок: {len(exs)} вправ, {len({e["type"] for e in exs})} типів')
    for e in exs:
        blob = ' '.join(str(e.get(f) or '') for f in ('answer', 'question')) + ' ' + ' '.join(map(str, e.get('options') or []))
        if e['type'] != 'listening_dialogue' and any(re.search(r'\b' + w + r'\b', blob.lower()) for w in D.RECOGNITION):
            c.errors.append(f'новий урок: вправа на слово «лише впізнавати»: {e["question"]}')
    for w in D.RECOGNITION:
        if w not in D.NEW_LESSON['words']:
            c.errors.append(f'«{w}» (лише впізнавати) немає серед слів нового уроку')
    errors += c.errors
    errors += GW.validate('a2_dupes', writing_ns())
    lessons_old = {w.lower() for L in A2 for w, _ua in L['words']} - {w.lower() for w in removed_words()}
    for w in D.NEW_LESSON['words']:
        if w.lower() in lessons_old:
            errors.append(f'новий урок: «{w}» уже є в уроці A2')
    e, warnings = check_batch(new_lexemes(), existing=dict(TAKEN))
    errors += e
    if len(ORDER) != NEW_TOTAL or NUMBER[NEW_SLUG] != 70:
        errors.append(f'уроків A2 після змін {len(ORDER)}, новий урок — {NUMBER[NEW_SLUG]} (очікувалось {NEW_TOTAL} і 70)')
    return errors, warnings


# ----------------------------------------------------------------------------- SQL: пакет 1
HELPER_TASK = V.HELPER_TASK + """
-- слово уроку: заміна на тому самому місці (рядок lesson_items той самий — змінюється лише слово)
create or replace function pg_temp.swap_word(p_lesson uuid, p_old text, p_new text) returns void language plpgsql as $f$
declare v_new uuid; v_n int;
begin
  select id into v_new from public.lexemes where lower(lemma) = lower(p_new) and status = 'PUBLISHED' order by created_at limit 1;
  if v_new is null then raise exception 'Немає опублікованого слова «%»', p_new; end if;
  update public.lesson_items set item_id = v_new
   where lesson_id = p_lesson and item_type = 'lexeme' and item_id in (select id from public.lexemes where lower(lemma) = lower(p_old));
  get diagnostics v_n = row_count;
  if v_n <> 1 then raise exception 'Слово «%» в уроці: % рядків замість 1 — звірте базу', p_old, v_n; end if;
end $f$;

-- вправа: нова на місці старої (той самий тип і місце); стара — DEPRECATED, якщо більше ніде не використовується
create or replace function pg_temp.swap_ex(p_lesson uuid, p_old uuid, p_new uuid, p_type text, p_question text, p_answer text,
                                           p_options jsonb, p_lemma text, p_task jsonb) returns void language plpgsql as $f$
declare v_lex uuid; v_n int;
begin
  if p_lemma is not null then
    select id into v_lex from public.lexemes where lower(lemma) = lower(p_lemma) and status = 'PUBLISHED' order by created_at limit 1;
    if v_lex is null then raise exception 'Немає опублікованого слова «%»', p_lemma; end if;
  end if;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id, task)
  select p_new, p_type, p_question, p_answer, p_options, e.level, e.order_index, 'PUBLISHED', v_lex, p_task
    from public.exercises e where e.id = p_old and e.exercise_type = p_type
  on conflict (id) do nothing;
  update public.lesson_items set item_id = p_new where lesson_id = p_lesson and item_type = 'exercise' and item_id = p_old;
  get diagnostics v_n = row_count;
  if v_n <> 1 or not exists (select 1 from public.exercises where id = p_new) then
    raise exception 'Вправу % в уроці не замінено — звірте базу', p_old;
  end if;
  update public.exercises e set status = 'DEPRECATED' where e.id = p_old and e.status = 'PUBLISHED'
     and not exists (select 1 from public.lesson_items x where x.item_type = 'exercise' and x.item_id = e.id);
end $f$;

-- копія складу уроку до змін і стара версія уроку (разом з опублікованими діалогами) — у content_versions
create or replace function pg_temp.snapshot_lesson(p_lesson uuid, p_reason text) returns void language plpgsql as $f$
begin
  insert into backup.lesson_items_a2dupes_20261119 select li.* from public.lesson_items li where li.lesson_id = p_lesson on conflict (id) do nothing;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'lesson', l.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = l.id), 0) + 1,
         jsonb_build_object('lesson', to_jsonb(l),
           'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = l.id),
           'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c
                              where c.lesson_id = l.id and c.status = 'PUBLISHED')), p_reason
    from public.lessons l where l.id = p_lesson;
end $f$;
"""


def backup_sql() -> str:
    return """-- 0. Копія складу уроків до змін (схема backup без доступу для anon / authenticated)
create schema if not exists backup;
create table if not exists backup.lesson_items_a2dupes_20261119 (like public.lesson_items including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'lesson_items_a2dupes_20261119_pkey') then
    alter table backup.lesson_items_a2dupes_20261119 add constraint lesson_items_a2dupes_20261119_pkey primary key (id);
  end if;
end $$;
revoke all on backup.lesson_items_a2dupes_20261119 from anon, authenticated;
"""


def lexemes_sql() -> list[str]:
    data = [dict(lemma=r['lemma'], normalized=r['normalized'], pos=r['part_of_speech'], ua=r['ukrainian_translation'],
                 vtype=r['vocabulary_type'], forms=r['forms'], examples=r['examples'], register=r['register'],
                 regionality=r['regionality'], usage_tags=r['usage_tags'], interference=r['ukrainian_interference'],
                 standard=r.get('standard_lemma'))
            for r in new_lexemes()]
    return [f'-- 1. Нові слова ({len(data)}): PUBLISHED (бета), з мітками (đir — розмовне, Далмація, італізм);'
            ' наявні в словнику не змінюються',
            'insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples,',
            '                            ukrainian_interference, register, regionality, usage_tags, standard_lexeme_id, status, source)',
            f"select t.lemma, t.normalized, 'hr', t.pos, {q(LEVEL)}, t.ua, t.vtype, t.forms, t.examples, t.interference,",
            '       t.register, t.regionality, array(select jsonb_array_elements_text(t.usage_tags)),',
            "       (select s.id from public.lexemes s where lower(s.lemma) = lower(t.standard) and s.status = 'PUBLISHED' order by s.created_at limit 1),",
            f'       {q(STATUS)}, {q(SOURCE)}',
            f'  from jsonb_to_recordset({qj(data)})',
            '    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb, interference text,',
            '         register text, regionality text, usage_tags jsonb, standard text)',
            ' where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))',
            'on conflict do nothing;', '']


def cefr_sql(words, level: str, reason: str, title: str) -> str:
    lemmas = ', '.join(q(w.lower()) for w in words)
    return f"""-- {title}; стара версія — у content_versions
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) in ({lemmas}) and status = 'PUBLISHED' and cefr is distinct from {q(level)} loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), {q(reason)});
    update public.lexemes set cefr = {q(level)}, version = version + 1 where id = r.id;
  end loop;
end $$;
"""


WHAT = {
    'Д1': 'урок «Аргументи й компроміс» без «згоден / не згоден / ти правий» — їх учать в A1 «Що ти думаєш?» (Д1)',
    'Д2': 'урок «Курси хорватської для дорослих» — уже на курсі: прогрес, розмовна практика, довідка; запис на курс — в A1-105 (Д2)',
    'Д5': 'урок «Майстер удома: кошторис і гарантія» без «тече кран» і «немає світла» — вони в A1-45 (Д5)',
    'Д6': 'урок «Сусіди: збори й шкода» без шуму — він в A1-48 «Новий сусід» (Д6)',
    'Д7': 'урок «Звичаї й етикет» без «ти чи Ви» — він в A1-77 (Д7)',
    'Д8': 'лікарняний — в уроці «Лікарняний для себе й для дитини», урок 33 — «Відпустка й вихідні дні»; симптоми — в A1-74 (Д8)',
}


def conv_id(n: int, old: str) -> str:
    return uid('conversation_a2dupes', LEVEL, D.LESSON_IDS[n], old)


def ex_id(n: int, old_id: str) -> str:
    return uid('exercise_a2dupes', LEVEL, D.LESSON_IDS[n], old_id)


def change_sql(n: int) -> list[str]:
    ch = D.CHANGES[n]
    lid = D.LESSON_IDS[n]
    what = WHAT[ch['note']]
    first_new = ch['swap'][0][1]
    s = [f'-- 2. Урок {OLD_NUMBER[lid]} (стане {NUMBER[lid]}): {what}', 'do $$', 'declare', f'  v_lesson constant uuid := {q(lid)};', 'begin',
         f"  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id where li.lesson_id = v_lesson "
         f"and li.item_type = 'lexeme' and lower(x.lemma) = {q(first_new.lower())}) then return; end if;  -- уже зроблено",
         f"  perform pg_temp.snapshot_lesson(v_lesson, {q('a2_dupes: ' + what + ' — стара версія')});"]
    for old, new in ch['swap']:
        s.append(f'  perform pg_temp.swap_word(v_lesson, {q(old)}, {q(new)});')
    for w in ch.get('add', []):
        s += ['  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill)',
              f"  select v_lesson, 'lexeme', (select id from public.lexemes where lower(lemma) = {q(w.lower())} and status = 'PUBLISHED' order by created_at limit 1),",
              "         (select max(order_index) + 1 from public.lesson_items where lesson_id = v_lesson), 'vocabulary';"]
    for key, ex in ch.get('ex', []):
        o = old_exercise(n, key)
        nid = ex_id(n, o['item'])
        task = 'null'
        question, answer = ex.get('question'), ex.get('answer')
        if ex['type'] in TASK_TYPES:
            t = task_of(ex)
            question, answer = task_question_answer(ex, t)
            task = qj(t)
            opts = 'null'
        elif ex['type'] in ('multiple_choice', 'fill_in_the_blank'):
            opts = qj(shuffled(ex['options'], f'a2dupes:{n}:{ex["answer"]}'))
        elif ex['type'] in ('listening', 'sentence_builder'):
            opts = qj(shuffled(ex['answer'].split(' '), f'a2dupes:{n}:{ex["answer"]}'))
        else:
            opts = 'null'
        s.append(f"  perform pg_temp.swap_ex(v_lesson, {q(o['item'])}, {q(nid)}, {q(ex['type'])}, {q(question)}, {q(answer)}, "
                 f"{opts}, {q(ex.get('word'))}, {task});")
        if ex['type'] in TASK_TYPES:
            s += ['  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
                  f"  values ('exercise', {q(nid)}, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE_TASK.format(kind=ex['type']))});"]
    for old, (s_ua, s_hr, sit, turns) in ch.get('convs', []):
        cid = conv_id(n, old)
        s += [f'  -- діалог «{CONVS[old]["title_hr"]}» → «{s_hr}» (старий — DEPRECATED, не видаляється)',
              f"  update public.conversations set status = 'DEPRECATED' where id = {q(old)} and status = 'PUBLISHED';",
              f"  if not found then raise exception 'Немає діалогу «{CONVS[old]['title_hr']}» — звірте базу'; end if;",
              '  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)',
              '  -- source — цього пакета (діалоги програми A2 v2 рахує тест a2_v2_dialogues); звідки діалог — у content_reviews',
              f"  values ({q(cid)}, v_lesson, {q(s_ua)}, {q(s_hr)}, {CONVS[old]['order']}, {q(LEVEL)}, {q(sit)}, {q(STATUS)}, {q(SOURCE)});"]
        for ti, (sp, hr, ua) in enumerate(turns, 1):
            s.append(f"  perform pg_temp.turn({q(uid('turn_a2dupes', cid, ti))}, {q(cid)}, {q(sp)}, {q(hr)}, {q(ua)}, {ti});")
    if 'objectives' in ch:
        s.append(f"  update public.lessons set objectives = {qj(ch['objectives'])} where id = v_lesson;")
    if 'title' in ch:
        t_ua, t_hr = ch['title']
        s.append(f"  update public.lessons set title_ua = regexp_replace(title_ua, ':.*$', '') || {q(': ' + t_ua)},"
                 f" title_hr = regexp_replace(title_hr, ':.*$', '') || {q(': ' + t_hr)} where id = v_lesson;")
    s += ['  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
          f"  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE_LESSON.format(what=what))});",
          'end $$;', '']
    return s


def new_lesson_sql(c: V.CourseA2) -> list[str]:
    key = (MOD, D.NEW_ORDER)
    L = c.lessons[key]
    n = NUMBER[NEW_SLUG]
    t_ua, t_hr = L['title']
    wrows = GW.rows(writing_ns())
    etiq, klapa = MOD11[4]['id'], MOD11[5]['id']
    s = [f'-- 3. Новий урок A2.{MOD}, місце {D.NEW_ORDER} (стане уроком {n}): «{t_ua}» — {len(L["words"])} слів, 2 діалоги, 15 вправ + письмо й переказ;',
         f'--    «{MOD11[4]["title"].split(": ", 1)[1]}» і «{MOD11[5]["title"].split(": ", 1)[1]}» — місця 6 і 7',
         'do $$', 'declare', f'  v_unit constant uuid := {q(D.UNIT_11)};', f'  v_lesson constant uuid := {q(NEW_LESSON_ID)};',
         f'  v_gid constant uuid := {q(V.topic_id(L["grammar"]))};', '  v_pos int := 0;', 'begin',
         '  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено',
         f"  if (select count(*) from public.lessons where unit_id = v_unit and status = 'PUBLISHED') <> 6",
         f"     or (select order_index from public.lessons where id = {q(etiq)}) <> 5 or (select order_index from public.lessons where id = {q(klapa)}) <> 6 then",
         f"    raise exception 'Модуль A2.{MOD}: очікувалось 6 уроків, «Звичаї й етикет» — 5, «Клапа…» — 6 — звірте базу';", '  end if;',
         f"  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики {L['grammar']}'; end if;",
         '  -- місця 5 → 6 і 6 → 7 (спершу останній); стара версія — у content_versions']
    for lid, new_o in ((klapa, 7), (etiq, 6)):
        s += ['  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)',
              "  select 'lesson', l.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = l.id), 0) + 1,",
              f"         to_jsonb(l), 'a2_dupes: нове місце в модулі A2.11 (перед уроком — новий «Далмація: Задар і околиці») — стара версія'",
              f'    from public.lessons l where l.id = {q(lid)};',
              f'  update public.lessons set order_index = {new_o} where id = {q(lid)};']
    s += ['  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)',
          f"  values (v_lesson, v_unit, {q(LEVEL)}, {q(f'Урок {n}: {t_ua}')}, {q(f'Lekcija {n}: {t_hr}')}, {qj(L['objectives'])}, {MINUTES}, {q(STATUS)}, {D.NEW_ORDER});",
          '  -- слова']
    for word in L['words']:
        s.append(f'  v_pos := pg_temp.word(v_lesson, {q(word)}, v_pos);')
    for w in sorted(D.RECOGNITION):
        s += [f'  -- «{w}» — лише впізнавати (розмовне далматинське слово): без «напишіть» і «скажіть»',
              "  update public.lesson_items set target_skill = 'recognition' where lesson_id = v_lesson and item_type = 'lexeme'",
              f"     and item_id = (select id from public.lexemes where lower(lemma) = {q(w)} and status = 'PUBLISHED' order by created_at limit 1);"]
    s += ['  -- граматика', '  v_pos := v_pos + 1;',
          "  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');",
          '  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;', '  -- вправи']
    for ei, ex in enumerate(c.lesson_exercises(key), 1):
        eid = uid('exercise_a2dupes', LEVEL, MOD, NEW_SLUG, ei)
        if ex['type'] == 'listening_dialogue':
            s.append(f"  v_pos := pg_temp.ex_task(v_lesson, v_pos, {q(eid)}, 'listening_dialogue', {q(ex['question'])}, {q(ex['answer'])}, "
                     f"{q(LEVEL)}, {q(STATUS)}, {qj(ex['task'])}, true, 'listening');")
            s += ['  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
                  f"  values ('exercise', {q(eid)}, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(V.LISTEN_NOTE)});"]
            continue
        opts = qj(ex['options']) if ex['options'] is not None else 'null'
        lemma = q(ex['word']) if ex.get('word') else 'null'
        s.append(f"  v_pos := pg_temp.ex(v_lesson, v_pos, {q(eid)}, {q(ex['type'])}, {q(ex['question'])}, "
                 f"{q(ex['answer'])}, {opts}, {q(LEVEL)}, {ei}, {q(STATUS)}, {lemma}, {q(ex['skill'])});")
    s.append('  -- письмо й переказ (необов’язкові)')
    for r in wrows:
        s.append(f"  v_pos := pg_temp.ex_task(v_lesson, v_pos, {q(r['id'])}, {q(r['type'])}, {q(r['question'])}, {q(r['answer'])}, "
                 f"{q(LEVEL)}, {q(STATUS)}, {qj(r['task'])}, false, {q(r['skill'])});")
        s += ['  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
              f"  values ('exercise', {q(r['id'])}, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(V.WRITING_NOTE)});"]
    for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1):
        cid = uid('conversation_a2dupes', LEVEL, MOD, NEW_SLUG, si)
        s += [f'  -- діалог {si}',
              '  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)',
              f"  values ({q(cid)}, v_lesson, {q(s_ua)}, {q(s_hr)}, {5000 + n * 10 + si}, {q(LEVEL)}, {q(L['situation'] if si == 1 else 'small_talk')}, "
              f"{q(STATUS)}, {q(SOURCE)}) on conflict (id) do nothing;"]
        for ti, (speaker, hr, ua) in enumerate(turns, 1):
            s.append(f"  perform pg_temp.turn({q(uid('turn_a2dupes', LEVEL, MOD, NEW_SLUG, si, ti))}, {q(cid)}, {q(speaker)}, {q(hr)}, {q(ua)}, {ti});")
    s += ['  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
          f"  values ('lesson', v_lesson, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE_NEW)});", 'end $$;', '']
    return s


def rename_sql() -> str:
    out = [f'-- 4. Нові назви {len(D.RENAME_CONVS)} діалогів з однаковими назвами (у пізнішому уроці; зміст інший); стара — у content_versions']
    for cid, (where, old_t, (t_ua, t_hr)) in D.RENAME_CONVS.items():
        out.append(f"""do $$
begin
  if (select title_hr from public.conversations where id = {q(cid)}) = {q(t_hr)} then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), {q(f'a2_dupes: нова назва діалогу уроку {where} (така сама — в іншому уроці) — стара версія')}
    from public.conversations c where c.id = {q(cid)} and c.title_hr = {q(old_t)} and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «{old_t}» уроку {where} — звірте базу'; end if;
  update public.conversations set title_ua = {q(t_ua)}, title_hr = {q(t_hr)} where id = {q(cid)};
end $$;""")
    return '\n'.join(out) + '\n'


RENUMBER_SQL = """-- 5. Наскрізні номери всіх уроків A2 («Урок N: …» / «Lekcija N: …»); стара назва — у content_versions;
--    порядок діалогів уроків A2 (5000 + N·10 + k) — за новим номером
do $$
declare r record; v_payload jsonb; v_new_ua text; v_new_hr text;
begin
  for r in select l.id, l.title_ua, l.title_hr,
                  row_number() over (order by m.order_index, u.order_index, l.order_index) as n
             from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
            where m.level_code = 'A2' and l.status = 'PUBLISHED' loop
    update public.conversations set order_index = 5000 + r.n * 10 + order_index % 10
     where lesson_id = r.id and order_index between 5000 and 5999 and order_index / 10 <> 500 + r.n;
    v_new_ua := regexp_replace(r.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':');
    v_new_hr := regexp_replace(r.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':');
    if v_new_ua is not distinct from r.title_ua and v_new_hr is not distinct from r.title_hr then continue; end if;
    select to_jsonb(l) into v_payload from public.lessons l where l.id = r.id;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'a2_dupes: новий номер уроку ' || r.n || ' (новий урок A2.11 «Далмація: Задар і околиці»)');
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;
"""


def selfcheck_sql() -> str:
    changed = [D.LESSON_IDS[n] for n in D.CHANGES]
    nlex = len(NEW)
    lemmas = ', '.join(q(k) for k in NEW)
    removed = sorted({w.lower() for w in removed_words()} - {w.lower() for w in D.MOVE_33_44})
    renamed = ', '.join(f'({q(cid)}::uuid, {q(t[2][1])})' for cid, t in D.RENAME_CONVS.items())
    titled = ', '.join(f"({q(D.LESSON_IDS[n])}::uuid, {q('Урок ' + str(NUMBER[D.LESSON_IDS[n]]) + ': ' + ch['title'][0])})"
                       for n, ch in D.CHANGES.items() if 'title' in ch)
    n_new = NUMBER[NEW_SLUG]
    moved = ', '.join(q(w) for w in D.MOVE_33_44)
    return f"""-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_lex int;
begin
  -- уроки A2: {NEW_TOTAL}, номери 1…{NEW_TOTAL} без пропусків; A2.11 — 7 уроків, новий — {n_new}
  if (select count(*) from public.lessons where level_code = 'A2' and status = 'PUBLISHED') <> {NEW_TOTAL}
     or exists (select 1 from (select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) n
                                 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                                where m.level_code = 'A2' and l.status = 'PUBLISHED') t
                 where t.title_ua !~ ('^Урок ' || t.n || ':') or t.title_hr !~ ('^Lekcija ' || t.n || ':')) then
    raise exception 'Уроки A2: очікувалось {NEW_TOTAL} з номерами 1…{NEW_TOTAL}';
  end if;
  if (select count(*) from public.lessons where unit_id = {q(D.UNIT_11)} and status = 'PUBLISHED') <> 7
     or (select title_ua from public.lessons where id = {q(NEW_LESSON_ID)}) <> {q(f'Урок {n_new}: {D.NEW_LESSON["title"][0]}')}
     or (select count(*) from (values {titled}) t(id, title) join public.lessons l on l.id = t.id and l.title_ua = t.title) <> 2 then
    raise exception 'Модуль A2.11 — 7 уроків, новий урок {n_new}; нові назви уроків 29 і 33';
  end if;
  -- діалоги уроків A2: порядок 5000 + N·10 + k
  if exists (select 1 from public.conversations c join public.lessons l on l.id = c.lesson_id
              where l.level_code = 'A2' and l.status = 'PUBLISHED' and c.status = 'PUBLISHED'
                and c.order_index / 10 <> 500 + substring(l.title_ua from '^Урок ([0-9]+):')::int) then
    raise exception 'Порядок діалогів A2 не за номером уроку';
  end if;
  -- змінені й новий уроки: 20–25 слів, 2 опубліковані діалоги (6–8 реплік), 15 обов’язкових вправ, письмо й переказ, «на слух»
  select count(*) into v_bad from public.lessons l
   where l.id in ({', '.join(q(x) for x in changed + [NEW_LESSON_ID])})
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or exists (select 1 from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED'
                      and (select count(*) from public.conversation_turns t where t.conversation_id = c.id) not between 6 and 8)
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and li.required) <> 15
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and not li.required
                 and e.exercise_type in ('write_message', 'mediation')) <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and e.exercise_type = 'listening_dialogue' and e.status = 'PUBLISHED') <> 1
          or exists (select 1 from public.lesson_items li join public.exercises e on e.id = li.item_id
                      where li.lesson_id = l.id and li.item_type = 'exercise' and e.status <> 'PUBLISHED'));
  if v_bad > 0 then raise exception 'Уроки пакета: % з неправильним складом', v_bad; end if;
  -- слова уроків A2 не повторюються між уроками; прибраних слів немає в уроках A2; лікарняний — в уроці 44, не в 33
  if exists (select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id and l.level_code = 'A2' and l.status = 'PUBLISHED'
              where li.item_type = 'lexeme' group by li.item_id having count(*) > 1) then
    raise exception 'A2: слова повторюються в кількох уроках';
  end if;
  if exists (select 1 from public.lesson_items li join public.lessons l on l.id = li.lesson_id and l.level_code = 'A2' and l.status = 'PUBLISHED'
              join public.lexemes x on x.id = li.item_id where li.item_type = 'lexeme' and lower(x.lemma) in ({', '.join(q(r) for r in removed)})) then
    raise exception 'Прибрані слова ще в уроках A2';
  end if;
  if (select count(*) from public.lesson_items li join public.lexemes x on x.id = li.item_id
       where li.item_type = 'lexeme' and li.lesson_id = {q(D.LESSON_IDS[44])} and lower(x.lemma) in ({moved})) <> 3 then
    raise exception 'Урок 44: немає слів лікарняного з уроку 33';
  end if;
  -- «лише впізнавати»: đir
  if (select count(*) from public.lesson_items li join public.lexemes x on x.id = li.item_id
       where li.lesson_id = {q(NEW_LESSON_ID)} and li.item_type = 'lexeme' and li.target_skill = 'recognition') <> {len(D.RECOGNITION)} then
    raise exception 'Новий урок: слово «лише впізнавати» без target_skill = recognition';
  end if;
  -- нові слова: опубліковані, з мітками; наявні — рівень A2
  select count(*) into v_lex from public.lexemes where lower(lemma) in ({lemmas}) and status = 'PUBLISHED'
     and register is not null and regionality is not null and usage_tags is not null;
  if v_lex <> {nlex} then raise exception 'Нових слів: % (очікувалось {nlex})', v_lex; end if;
  if exists (select 1 from public.lexemes where lower(lemma) in ({', '.join(q(w.lower()) for w in D.EXISTING)}) and status = 'PUBLISHED' and cefr <> 'A2')
     or not exists (select 1 from public.lexemes where lower(lemma) = 'đir' and register = 'colloquial' and regionality = 'Dalmatia') then
    raise exception 'Рівень наявних слів (A2) чи мітки đir';
  end if;
  -- діалоги: нові назви; однакових назв в A0–A2 більше немає
  if (select count(*) from (values {renamed}) t(id, title) join public.conversations c on c.id = t.id and c.title_hr = t.title) <> {len(D.RENAME_CONVS)} then
    raise exception 'Діалоги не перейменовано';
  end if;
  if exists (select 1 from public.conversations c join public.lessons l on l.id = c.lesson_id and l.level_code in ('A0', 'A1', 'A2') and l.status = 'PUBLISHED'
              where c.status = 'PUBLISHED' group by lower(c.title_hr) having count(*) > 1) then
    raise exception 'Однакові назви діалогів в A0–A2';
  end if;
  raise notice 'Готово: {OUT.name} — уроки 9, 27, 29, 33, 38, 44, 70 без дублів, новий урок {n_new} «Далмація: Задар і околиці», {nlex} нових слів, {len(D.RENAME_CONVS)} назв діалогів, уроків A2 — {NEW_TOTAL}';
end $$;
"""


def build(c: V.CourseA2) -> str:
    head = f"""-- =====================================================================
-- Дублі A2 · 2026-11-19 (план «Дублі й сенс уроків A0–A2», PR 4)
-- Згенеровано: python3 -B scripts/gen_a2_dupes.py (не редагуйте вручну).
--
-- Рішення власника 2026-11-17: Д1 (урок 27), Д2 (9), Д5 (38), Д6 (29), Д7 (70), Д8 (33 і 44) + назва уроку 33;
-- новий урок A2.11 «Далмація: Задар і околиці» (стане {NUMBER[NEW_SLUG]}); 6 назв діалогів. Уроків A2 {OLD_TOTAL} → {NEW_TOTAL}.
--   * Нові слова: {len(NEW)} (з мітками); наявні без уроку — {len(D.EXISTING)} (рівень → A2).
--   * Слово в уроці — заміна на тому самому місці; вправи на прибрані слова й діалоги — нові на тому самому місці.
--   * otvoriti / zatvoriti bolovanje, javiti se bolestan — з уроку 33 в урок 44 (слово не зникає з курсу).
--   * Нічого не видаляється: старі діалоги й вправи → DEPRECATED; копія складу уроків — backup.lesson_items_a2dupes_20261119;
--     старі версії уроків, діалогів і слів — у content_versions. Прогрес користувачів не змінюється.
--   * Далі за назвою: {D.DATE}_a2_dupes_2_tests_*.sql (перевірки рівнів A1 і A2 наново).
--   * Повторний запуск нічого не змінює. Бета: PUBLISHED.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: {OUT.name} — …».
-- =====================================================================

begin;
"""
    out = [head, backup_sql(), HELPERS_SQL, HELPER_TASK]
    out += lexemes_sql()
    out.append(cefr_sql(D.EXISTING, 'A2', 'a2_dupes: рівень слова A2 — його вперше вчать в уроці A2 — стара версія',
                        f'1а. Наявні слова без уроку ({len(D.EXISTING)}), які тепер учать в уроках A2: рівень — A2'))
    for n in [33, 44] + [x for x in sorted(D.CHANGES) if x not in (33, 44)]:
        out += change_sql(n)
    out += new_lesson_sql(c)
    out.append(rename_sql())
    out.append(RENUMBER_SQL)
    out.append(selfcheck_sql())
    out.append('commit;\n')
    return '\n'.join(out)


# ----------------------------------------------------------------------------- звіт для носія
def review(c: V.CourseA2) -> str:
    out = ['# Дублі A2 (план «Дублі й сенс уроків», PR 4) — для носія мови (2026-11-19)', '',
           'Згенеровано: `python3 -B scripts/gen_a2_dupes.py --review`. Бета (опубліковано одразу). Позначте рядок і напишіть, як краще.',
           f'Номери уроків — нові (після нового уроку {NUMBER[NEW_SLUG]} «Далмація: Задар і околиці» в A2.11; уроки 70–86 → 71–87).', '',
           '## Що варто глянути носію', '',
           '1. **Нові вирази**: *razina znanja*, *samostalno učiti*, *zamjena smjene*, *kolektivni godišnji odmor*, *prenijeti dane*, '
           '*pravo na godišnji*, *rok završetka*, *kašnjenje radova*, *nadoknada štete*, *nutkati*, *izvan sezone*, *tempo života*.',
           '2. **Видові пари й форми**: *procuriti* (pfv; *voda je procurila*), *popustiti* (pfv) / *popuštati*, *zaostajati* / *zaostati*; '
           '*Dogovorila sam se sa susjedima* (sa перед s-); *Majstor je došao bez dijelova*; *Evo ispričnice za vrtić*.',
           '3. **Регіональне слово**: *đir* — `colloquial`, Далмація, `italianism`; в уроці лише впізнаємо '
           '(«ići na đir po rivi»); нейтральний відповідник *šetnja* — у примітці до слова. Чи природно звучить у репліці Дар’ї?',
           '4. **Факти**: Нін — давнє королівське місто, пів години від Задара; ручна солеварня й лікувальна грязь; Паклениця — '
           'скелелазіння навесні; бухта Лоєна на Корнатах; невикористані дні відпустки — до кінця червня наступного року; '
           'щонайменше 4 тижні відпустки на рік.',
           '5. **Переклади**: *opravdan* — «обґрунтований, виправданий»; *penjalište* — «місце для скелелазіння»; '
           '*arheološko nalazište* — «археологічна пам’ятка (місце розкопок)»; *đir* — «прогулянка (щоб розвіятися)».', '']
    for n in sorted(D.CHANGES):
        ch = D.CHANGES[n]
        lid = D.LESSON_IDS[n]
        title = ch.get('title', (BY_ID[lid]['title'].split(': ', 1)[1], ''))[0]
        out += [f'## Урок {NUMBER[lid]} «{title}» (був {OLD_NUMBER[lid]}) — {ch["note"]}', '', '| Було | Стало | Переклад |', '|---|---|---|']
        out += [f'| *{o}* | *{w}* | {LEX[w.lower()][1]} |' for o, w in ch['swap']]
        out += [f'| — | *{w}* (з уроку 33) | {LEX[w.lower()][1]} |' for w in ch.get('add', [])] + ['']
        for old, (s_ua, s_hr, sit, turns) in ch.get('convs', []):
            out += [f'**Новий діалог: {s_hr}** ({s_ua}) (замість «{CONVS[old]["title_hr"]}»)', '']
            out += [f'- **{sp}:** {hr} — {ua}' for sp, hr, ua in turns] + ['']
        out += ['**Нові вправи (на місці старих)**', '', '| Тип | Завдання | Відповідь |', '|---|---|---|']
        for _key, ex in ch['ex']:
            if ex['type'] in TASK_TYPES:
                t = task_of(ex)
                qq, aa = task_question_answer(ex, t)
                if ex['type'] == 'listening_dialogue':
                    qq += ' — ' + ' '.join(x['hr'] for x in t['script'])
                elif ex['type'] == 'mediation':
                    qq += ' — ' + t['friend_ua']
                out.append(f"| {ex['type']} | {qq} | {aa} |")
            else:
                out.append(f"| {ex['type']} | {ex['question']} | {ex['answer']} |")
        out.append('')
    out += ['## Прибрані слова — де їх учать далі', '']
    out += [f'- *{w}* — {where}' for w, where in D.ELSEWHERE.items()]
    out += ['- лише в словнику (в уроках A1 — ширший чи синонімічний вираз): ' + ', '.join(f'*{w}*' for w in D.DICT_ONLY), '',
            '## Нові назви діалогів', '', '| Урок | Було | Стало |', '|---|---|---|']
    for cid, (where, old_t, (t_ua, t_hr)) in D.RENAME_CONVS.items():
        lid = CONVS[cid]['lesson']
        out.append(f'| {NUMBER[lid]} (був {where.split()[1]}) | {old_t} | {t_hr} ({t_ua}) |')
    out += ['', '## Нові слова', '', '| Слово | Переклад | Рід / вид | Мітки | Приклад |', '|---|---|---|---|---|']
    for r in NEW.values():
        f = r['forms']
        fv = f.get('gender') or (f.get('aspect', '') + (f' / {f["pair"]}' if f.get('pair') else ''))
        labels = '' if r['register'] == 'standard' else f"{r['register']}, {r['regionality']}, {', '.join(r['usage_tags'])}"
        out.append(f"| *{r['lemma']}* | {r['ukrainian_translation']} | {fv} | {labels} | {r['examples'][0]} |")
    key = (MOD, D.NEW_ORDER)
    L = c.lessons[key]
    out += ['', f'## Новий урок {NUMBER[NEW_SLUG]} «{L["title"][0]}» ({L["title"][1]})', '',
            f'Граматика: присвійні прикметники й прикметники від назв місць. Слова: ' + ', '.join(f'*{w}*' for w in L['words']), '']
    for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1):
        out += [f'**Діалог {si}: {s_hr}** ({s_ua})', ''] + [f'- **{sp}:** {hr} — {ua}' for sp, hr, ua in turns] + ['']
    out += ['**Вправи**', '', '| Тип | Завдання | Відповідь | Варіанти |', '|---|---|---|---|']
    for ex in c.lesson_exercises(key):
        opts = ' · '.join(ex['options']) if ex['options'] and ex['type'] not in ('sentence_builder', 'listening') else ''
        qq = ex['question'] + (' — ' + ' '.join(x['hr'] for x in ex['task']['script']) if ex['type'] == 'listening_dialogue' else '')
        out.append(f"| {ex['type']} | {qq} | {ex['answer']} | {opts} |")
    for r in GW.rows(writing_ns()):
        out.append(f"| {r['type']} | {r['question']} | {r['answer']} | |")
    out += ['', '## Перевірки рівнів A1 і A2 наново (пакет 2)', '',
            'Усі 15 тестів A1 (302 завдання) і 16 тестів A2 (260; a2-m11 — 14, бо в A2.11 тепер 7 уроків) — наново генератором v5 '
            '(схема 2026-11-07) з уроків і текстів, які є в курсі зараз. Нових хорватських речень немає: завдання — з діалогів, вправ і текстів.',
            '', '**Нові інші порядки слів у «Складіть» — перевірити, що звучать природно** (`scripts/sentence_order_alternatives.py`):', '',
            '| Головна відповідь | Інші порядки |', '|---|---|']
    from sentence_order_alternatives import ALTERNATIVES   # noqa: PLC0415
    src = (HERE / 'sentence_order_alternatives.py').read_text(encoding='utf-8')
    block = src.split('перевірки наново після плану «Дублі», 2026-11-19)', 1)[1].split('\n}', 1)[0]
    for main in re.findall(r"^    '([^']+)':", block, re.M):
        out.append(f"| {main} | {' · '.join(ALTERNATIVES[main])} |")
    return '\n'.join(out) + '\n'


# ----------------------------------------------------------------------------- перевірки (пакет 2): A1 і A2 наново
ASSESS_SNAPSHOT = HERE / 'assessment_a2_dupes_snapshot.json'
ASSESS_VER = 'v5rebuild20261119'
ASSESS_NOTE = ('Бета: перевірки рівня {lv} наново за схемою 2026-11-07 після плану «Дублі й сенс уроків» (PR 3–4) — '
               'завдання й хибні варіанти лише з уроків і текстів, які є в курсі зараз (задача власника 2026-11-19). Потрібна перевірка носієм.')
ASSESS_REASON = 'assessment_rebuild_20261119: перевірку зібрано наново після плану «Дублі й сенс уроків» — старі завдання'
ASSESS_PARTS = {'A1': [range(1, 8), None], 'A2': [range(1, 8), None]}   # ≤ ~300 КБ на файл; None — решта, середина й фінал


def assessments() -> dict[str, list[dict]]:
    import gen_assessment_a0_a1_v5 as V5   # noqa: PLC0415
    snap = json.loads(ASSESS_SNAPSHOT.read_text(encoding='utf-8'))
    levels = {L['level']: L for L in snap['levels']}
    a1, a2 = levels['A1'], levels['A2']
    per1 = {m['order']: len(m['lessons']) for m in a1['modules']}
    per2 = {m['order']: len(m['lessons']) for m in a2['modules']}
    if sum(per1.values()) != 111 or sum(per2.values()) != NEW_TOTAL or per2[MOD] != 7:
        raise SystemExit('Знімок перевірок — не після пакета 20261119_a2_dupes_1_lessons.sql')
    V5.LEVEL_DATA.clear()
    V5.LEVEL_DATA.update({'A1': a1, 'A2': a2})
    V5.LEVELS['A2'] = {'mid_after': 7}
    V5.VER = ASSESS_VER
    V5._CACHE.clear()
    out, problems = {}, []
    for lv in ('A1', 'A2'):
        problems += [f'{lv}: {p}' for p in V5.check(lv)]
        out[lv] = V5.tests(lv)
        for t in out[lv]:
            if t['db_kind'] == 'module' and any(it['lesson'] and it['module'] != t['module'] for it in t['items']):
                problems.append(f"{t['slug']}: завдання з іншого модуля")
    removed = {w.lower() for w in removed_words()} - {w.lower() for w in D.MOVE_33_44}
    for lv, ts in out.items():
        for t in ts:
            for it in t['items']:
                if lv == 'A2' and (it.get('answer_text') or '').lower() in removed:
                    problems.append(f"{t['slug']}: завдання на прибране слово «{it['answer_text']}»")
    if problems:
        raise SystemExit('Перевірка не пройдена:\n' + '\n'.join(problems))
    return out


def assessments_main():
    import gen_assessment_a0_a1_v5 as V5   # noqa: PLC0415
    tests = assessments()
    if '--check' in sys.argv:
        for lv, ts in tests.items():
            for t in ts:
                print(t['slug'], len(t['items']), dict(Counter(it['module'] for it in t['items'])))
        return tests
    snap = json.loads(ASSESS_SNAPSHOT.read_text(encoding='utf-8'))
    mods = {L['level']: {m['order']: m for m in L['modules']} for L in snap['levels']}
    for old in FIXES.glob(f'{D.DATE}_a2_dupes_2_tests_*.sql'):
        old.unlink()
    for lv, ts in tests.items():
        parts = []
        for spec in ASSESS_PARTS[lv]:
            taken = {t['slug'] for p in parts for t in p}
            parts.append([t for t in ts if t['slug'] not in taken and (spec is None or (t['db_kind'] == 'module' and t['module'] in spec))])
        for i, part in enumerate(parts, 1):
            path = FIXES / f'{D.DATE}_a2_dupes_2_tests_{lv.lower()}_part{i}.sql'
            path.write_text(assess_sql(V5, lv, part, mods[lv], i, len(parts), len(ts)), encoding='utf-8')
            print(f'{path.relative_to(ROOT)}: {len(path.read_bytes()) // 1024} КБ, тестів {len(part)}, завдань {sum(len(t["items"]) for t in part)}')
    return tests


def assess_sql(V5, lv: str, tests: list[dict], mods: dict, part: int, parts: int, n_tests: int) -> str:
    blocks = []
    for t in tests:
        desc, minutes = V5.description(lv, t)
        rows = ',\n'.join(V5.item_row(lv, it) for it in t['items'])
        mod = mods.get(t['module'])
        mod_check = (f"""  if (select module_id from public.assessments where id = v_aid) is distinct from {q(mod['id'])}::uuid then
    raise exception 'Тест {t['slug']} прив’язаний не до модуля {lv}.{t['module']} — звірте базу';
  end if;
""" if mod else '')
        blocks.append(f"""-- {t['title_ua']} · {len(t['items'])} завдань
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
          v_payload, {q(ASSESS_REASON)});
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = {q(desc)}, estimated_minutes = {minutes} where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
{rows};
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, {q(ASSESS_NOTE.format(lv=lv))});
end $$;
""")
    ids = ', '.join(q(it['id']) for t in tests for it in t['items'])
    total = sum(len(t['items']) for t in tests)
    expected = ', '.join(f"({q(t['slug'])}, {len(t['items'])})" for t in tests)
    sizes = ', '.join(f"{t['slug']} — {len(t['items'])}" for t in tests)
    name = f'{D.DATE}_a2_dupes_2_tests_{lv.lower()}_part{part}.sql'
    final_check = ''
    if any(t['db_kind'] == 'final' for t in tests):
        n_mods = len(mods)
        final_check = f"""  if (select count(distinct m.order_index) from public.assessment_items i join public.assessments a on a.id = i.assessment_id
        join public.lessons l on l.id = i.lesson_id join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
       where a.slug = {q(lv.lower() + '-final')} and a.cefr = {q(lv)} and i.status = 'PUBLISHED') < {n_mods - 1} then
    raise exception '{lv.lower()}-final: завдання не з усіх модулів';
  end if;
"""
    return f"""-- =====================================================================
-- Перевірки рівня {lv} наново після плану «Дублі й сенс уроків» (PR 3–4) · 2026-11-19 · частина {part} з {parts}
-- Згенеровано: python3 -B scripts/gen_a2_dupes.py assessments (не редагуйте вручну).
--
-- Задача власника 2026-11-19: «Перезібрати перевірки рівнів A1 і A2 після цих змін». Усі {n_tests} тестів {lv} — наново
-- генератором v5 (схема 2026-11-07: модуль — 2 завдання на урок (12–20), середина — 30, фінал — 48, кожен модуль — щонайменше 2)
-- з уроків і текстів, які є в курсі зараз: хибні варіанти більше не беруться з прибраних діалогів і слів.
-- Запускати після {OUT.name} (назва файлу стоїть після нього — «Apply SQL» запускає за назвою).
-- У цій частині {total} нових завдань: {sizes}.
--   * Завдання — з діалогів, вправ і текстів уроків; нових хорватських речень немає. Старі завдання — у content_versions і DEPRECATED.
--   * Спроби й результати користувачів не змінюються. Повторний запуск нічого не змінює.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: {name} — {len(tests)} тестів, {total} нових завдань».
-- =====================================================================

begin;

{chr(10).join(blocks)}
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
  if exists (select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id and a.cefr = {q(lv)} and a.kind = 'module'
               join public.lessons l on l.id = i.lesson_id join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
              where i.status = 'PUBLISHED' and i.id in ({ids}) and m.id is distinct from a.module_id) then
    raise exception 'Перевірки модулів {lv}: завдання з уроку іншого модуля';
  end if;
{final_check}  raise notice 'Готово: {name} — {len(tests)} тестів, % нових завдань', v_new;
end $$;

commit;
"""


# -----------------------------------------------------------------------------
def main():
    if 'assessments' in sys.argv:
        assessments_main()
        return
    errors, warnings = validate()
    if errors:
        raise SystemExit('ПОМИЛКИ:\n  ' + '\n  '.join(errors))
    for w in warnings:
        print('попередження:', w)
    c = build_course()
    if '--check' in sys.argv:
        print('OK: нових слів', len(NEW), '; новий урок', NUMBER[NEW_SLUG], '; уроків A2', len(ORDER))
        return
    if '--review' in sys.argv:
        REVIEW_OUT.write_text(review(c), encoding='utf-8')
        print(f'OK → {REVIEW_OUT.relative_to(ROOT)}')
        return
    sql = build(c)
    OUT.write_text(sql, encoding='utf-8')
    print(f'OK → {OUT.relative_to(ROOT)}: {len(sql.encode()) // 1024} КБ; нових слів {len(NEW)}')


if __name__ == '__main__':
    main()
