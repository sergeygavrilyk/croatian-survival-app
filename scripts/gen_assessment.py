"""
Генератор тестів рівня A0 і A1 (§60 ТЗ): 10 тестів модуля + тест середини + фінальний тест на рівень.

Запуск:
  python3 scripts/gen_assessment.py A0 > supabase/data_fixes/20261015_assessments_a0_v1.sql
  python3 scripts/gen_assessment.py A1 > supabase/data_fixes/20261015_assessments_a1_v1.sql
  python3 scripts/gen_assessment.py --report > content/reviews/2026-10-15_assessments_a0_a1.md

Звідки хорватське: лише з уже опублікованих уроків і текстів для читання (знімок
scripts/assessment_source_snapshot.json — вивантажено з бази, збіг з робочою базою перевірено хешем).
Нових хорватських речень генератор не пише: він складає з перевірених реплік, вправ і текстів
завдання на 4 навички §60:
  розумію    — послухати репліку й вибрати переклад; прочитати текст і відповісти на питання;
  спілкуюся  — вибрати доречну відповідь на репліку з діалогу;
  переказую  — переказати другу українською відповідь з діалогу; передати хорватською прохання друга;
  кажу       — написати слово, скласти речення, сказати фразу вголос (можна пропустити).

Рішення власника 2026-10-15: тест не блокує уроки; пройдено = ≥ 70 % і ≥ 50 % у кожній навичці;
говоріння можна пропустити; бета — одразу PUBLISHED (як уроки A0/A1), носій перевіряє після.
"""
from __future__ import annotations

import json
import random
import re
import sys
import uuid
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SNAPSHOT = ROOT / 'assessment_source_snapshot.json'
NS = uuid.UUID('6f1c7a52-9a43-4b0e-9d1e-0c2a0a0a0a01')
SOURCE = 'claude_assessment_v1'
STATUS = 'PUBLISHED'  # бета за рішенням власника; 'DRAFT' — щоб спершу показати носію
CYR = re.compile(r'[Ѐ-ӿ]')
REVIEW_NOTE = 'Бета: тести рівня (§60) за рішенням власника 2026-10-15 (assessment_v1), як уроки A0/A1. Потрібна перевірка носієм.'

# Відповіді, які пасують майже до всього: не беремо ні правильною відповіддю «Спілкуюся», ні пасткою
GENERIC = {
    'hvala', 'hvala lijepa', 'da', 'ne', 'dobro', 'molim', 'može', 'u redu', 'izvolite', 'doviđenja', 'bok', 'oprostite',
    'naravno', 'super', 'odlično', 'nema problema', 'nema na čemu', 'da molim', 'ne hvala', 'hvala vam', 'dogovoreno',
    'vidimo se', 'u redu hvala', 'da hvala', 'može hvala', 'evo', 'izvoli', 'jasno', 'razumijem', 'točno', 'svakako',
}

# Пастки «Спілкуюся» не можуть починатися з «так / ні / маємо / можна…»: такі відповіді пасують до багатьох питань
YESNO_START = {'da', 'ne', 'nije', 'nisam', 'jesam', 'jest', 'imam', 'imamo', 'ima', 'imaju', 'imaš', 'nema', 'nemam', 'nemamo',
               'mogu', 'možete', 'može', 'možeš', 'naravno', 'hoću', 'mislim', 'možda', 'tamo', 'ovdje', 'evo', 'ondje', 'svakako'}


# Смислові групи відповідей: пастка не може бути з тієї самої групи, що й правильна відповідь
# («Je li daleko?» — «Ne, blizu je» vs «Preko puta, u knjižari» — обидві про місце, тож друга теж підходить).
CATEGORIES = {
    'place': {'lijevo', 'desno', 'ravno', 'preko', 'pored', 'iza', 'ispred', 'blizu', 'daleko', 'gore', 'dolje', 'kat', 'katu',
              'ulici', 'ugla', 'puta', 'kod', 'stanica', 'stanici', 'centru', 'tamo', 'ondje', 'ovdje', 'unutra', 'vani', 'pješice'},
    'time': {'sat', 'sata', 'sati', 'minuta', 'minute', 'sutra', 'danas', 'jučer', 'prekosutra', 'prijepodne', 'poslijepodne',
             'navečer', 'ujutro', 'podne', 'tjedan', 'tjedna', 'dana', 'dan', 'mjesec', 'godina', 'godine', 'godinu', 'pola',
             'ponedjeljak', 'utorak', 'srijedu', 'srijeda', 'četvrtak', 'petak', 'subotu', 'subota', 'nedjelju', 'nedjelja',
             'siječnju', 'veljači', 'ožujku', 'travnju', 'svibnju', 'lipnju', 'srpnju', 'kolovozu', 'rujnu', 'listopadu',
             'studenom', 'studenog', 'prosincu', 'prosinca', 'zimi', 'ljeti', 'proljeće', 'jesen', 'rano', 'kasno', 'uskoro', 'odmah'},
    'number': {'jedan', 'jedna', 'jedno', 'jednu', 'dva', 'dvije', 'tri', 'četiri', 'pet', 'šest', 'sedam', 'osam', 'devet',
               'deset', 'jedanaest', 'dvanaest', 'trinaest', 'četrnaest', 'petnaest', 'dvadeset', 'trideset', 'četrdeset',
               'pedeset', 'sto', 'sto', 'tristo', 'petsto', 'tisuća', 'eura', 'euro', 'centi', 'nula', 'broj', 'kila', 'kile',
               'kilogram', 'litru', 'pola', 'oko'},
    'request': {'molim', 'želim', 'trebam', 'htio', 'htjela', 'uzimam', 'uzet', 'daj', 'dajte'},
}


def categories(hr: str) -> set[str]:
    words = set(norm(hr).split()) | {w for w in norm(hr).split() if w.isdigit()}
    out = {c for c, keys in CATEGORIES.items() if words & keys}
    if any(w.isdigit() for w in words):
        out.add('number')
    return out


# Загальні питання «чим допомогти?»: доречних відповідей багато, тож у «Спілкуюся» їх не беремо
OPEN_PROMPTS = ('kako vam mogu pomoći', 'izvolite', 'što želite', 'što trebate', 'što ćete', 'što ćeš', 'što želiš', 'mogu li vam pomoći')


def self_contained(prompt_hr: str) -> bool:
    """Питання зрозуміле без попередніх реплік: «A stan?», «Što točno?», «Izvolite?» — ні."""
    last = re.split(r'(?<=[.!?])\s+', prompt_hr.strip())[-1]
    words = norm(last).split()
    if any(norm(last).startswith(op) for op in OPEN_PROMPTS) and not (set(words) - set(' '.join(OPEN_PROMPTS).split()) - {'li'}):
        return False
    if norm(last) in ('kako vam mogu pomoći', 'izvolite kako vam mogu pomoći') or norm(prompt_hr).startswith('izvolite kako'):
        return False
    if words in (['a', 'vi'], ['a', 'ti']):  # «Dobro, hvala. A Vi?» — зустрічне питання, зрозуміле з першої частини
        return nwords(prompt_hr) >= 4
    return len(words) >= 3 and words[0] != 'a'


# Склад тестів: (kind, джерело завдань, скільки)
PLAN = {
    'module': [('listen', 2), ('read', 1), ('reply', 2), ('relay', 1), ('ua2hr', 1), ('type', 1), ('build', 1), ('speak', 1)],
    'mid':    [('listen', 3), ('read', 2), ('reply', 5), ('relay', 3), ('ua2hr', 2), ('type', 2), ('build', 2), ('speak', 1)],
    'final':  [('listen', 5), ('read', 3), ('reply', 7), ('relay', 4), ('ua2hr', 3), ('type', 3), ('build', 3), ('speak', 2)],
}
AREA = {'listen': 'understand', 'read': 'understand', 'reply': 'interact', 'relay': 'mediate', 'ua2hr': 'mediate',
        'type': 'produce', 'build': 'produce', 'speak': 'produce'}
SKILL = {'listen': 'listening', 'read': 'reading', 'reply': 'interaction', 'relay': 'mediation', 'ua2hr': 'mediation',
         'type': 'writing', 'build': 'writing', 'speak': 'speaking'}
ITEM_TYPE = {'listen': 'multiple_choice', 'read': 'multiple_choice', 'reply': 'multiple_choice', 'relay': 'multiple_choice',
             'ua2hr': 'multiple_choice', 'type': 'type_answer', 'build': 'sentence_builder', 'speak': 'speaking'}
MINUTES = {'module': 5, 'mid': 10, 'final': 15}
DESCRIPTION = {
    'module': 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.',
    'mid': 'Середина рівня (модулі 1–5): 20 завдань на 4 навички. ~10 хв.',
    'final': 'Кінець рівня (усі 10 модулів): 30 завдань на 4 навички. ~15 хв.',
}


def uid(*parts) -> str:
    return str(uuid.uuid5(NS, ':'.join(str(p) for p in parts)))


def q(s) -> str:
    if s is None:
        return 'null'
    return "'" + str(s).replace("'", "''") + "'"


def qj(v) -> str:
    return q(json.dumps(v, ensure_ascii=False)) + '::jsonb'


def norm(s: str) -> str:
    return re.sub(r'[^\w]+', ' ', s.lower()).strip()


def nwords(s: str) -> int:
    return len(norm(s).split())


def is_question(s: str) -> bool:
    return s.strip().endswith('?')


def generic(s: str) -> bool:
    n = norm(s)
    return n in GENERIC or nwords(s) < 2


# ---------------------------------------------------------------- пули джерел
class Pools:
    """Усі можливі завдання рівня, згруповані за модулем. Кожне джерело — з ключем, щоб не повторювалось."""

    def __init__(self, level: dict):
        self.level = level['level']
        self.modules = level['modules']
        self.by_module: dict[int, dict[str, list[dict]]] = {}
        for m in self.modules:
            self.by_module[m['order']] = self._collect(m)

    def _collect(self, m: dict) -> dict[str, list[dict]]:
        p = {k: [] for k in AREA}
        for lesson in m['lessons']:
            lid = lesson['id']
            for e in lesson['exercises']:
                if e['type'] == 'type_answer':
                    p['type'].append({'key': ('w', norm(e['a'])), 'lesson': lid, 'prompt': e['q'], 'hr': e['a'],
                                      'ua': e['q'].split('«', 1)[-1].rstrip('»').strip()})
                elif e['type'] == 'sentence_builder':
                    p['build'].append({'key': ('s', norm(e['a'])), 'lesson': lid, 'prompt': e['q'], 'hr': e['a'],
                                       'ua': e['q'].split('«', 1)[-1].rstrip('»').strip()})
                elif e['type'] == 'speaking':
                    item = {'key': ('s', norm(e['a'])), 'lesson': lid, 'hr': e['a'], 'ua': e['q']}
                    p['speak'].append(item)
                    p['ua2hr'].append(dict(item))
            for d in lesson['dialogues']:
                turns = d['turns'] or []
                for i, t in enumerate(turns):
                    if 3 <= nwords(t['hr']) <= 9 and not CYR.search(t['hr']):
                        p['listen'].append({'key': ('s', norm(t['hr'])), 'lesson': lid, 'hr': t['hr'], 'ua': t['ua']})
                    if i + 1 < len(turns):
                        a, b = t, turns[i + 1]
                        if is_question(a['hr']) and a['speaker'] != b['speaker'] and not is_question(b['hr']) \
                                and not generic(b['hr']) and 2 <= nwords(b['hr']) <= 10 and nwords(a['hr']) <= 12 \
                                and self_contained(a['hr']):
                            p['reply'].append({'key': ('s', norm(b['hr'])), 'lesson': lid, 'prompt_hr': a['hr'], 'prompt_ua': a['ua'],
                                               'hr': b['hr'], 'ua': b['ua'], 'dialogue': d['title_ua']})
                            qwords = set(norm(a['ua']).split())
                            others = [x for j, x in enumerate(turns) if j not in (i, i + 1) and nwords(x['ua']) >= 2
                                      and norm(x['ua']) != norm(b['ua'])
                                      and len(set(norm(x['ua']).split()) & qwords) * 2 < len(set(norm(x['ua']).split()))]
                            statements = [x for x in others if not is_question(x['hr'])]
                            if len(statements) >= 2:
                                others = statements
                            if len(turns) >= 4 and len(others) >= 2:
                                p['relay'].append({'key': ('r', norm(b['hr'])), 'lesson': lid, 'turns': turns, 'q_hr': a['hr'],
                                                   'hr': b['hr'], 'ua': b['ua'], 'others': others, 'dialogue': d['title_ua']})
        for r in m['reading']:
            for qi, qq in enumerate(r['questions']):
                if qq.get('answer') in qq.get('options', []) and len(qq['options']) >= 3:
                    p['read'].append({'key': ('t', r['code'], qi), 'lesson': None, 'text': r, 'question': qq})
        return p

    def all_of(self, kind: str, modules: list[int]) -> list[dict]:
        return [x for mo in modules for x in self.by_module[mo][kind]]


# ---------------------------------------------------------------- завдання
def make_item(kind: str, src: dict, pools: Pools, module: int, rng: random.Random) -> dict | None:
    """Завдання з джерела; None — якщо не набралося чесних пасток."""
    lv = pools.level
    base = {'kind': kind, 'area': AREA[kind], 'skill': SKILL[kind], 'item_type': ITEM_TYPE[kind], 'lesson': src['lesson'],
            'cefr': lv, 'audio_hr': None, 'passage_hr': None, 'passage_ua': None, 'prompt_hr': None, 'answer_text': None,
            'options': [], 'correct_index': None}

    def choice(correct: str, distractors: list[str]):
        opts = [correct] + distractors[:2]
        rng.shuffle(opts)
        return opts, opts.index(correct)

    if kind == 'listen':
        cands = [x for x in pools.all_of('listen', list(pools.by_module))
                 if norm(x['ua']) != norm(src['ua']) and norm(x['hr']) != norm(src['hr'])
                 and is_question(x['hr']) == is_question(src['hr']) and abs(nwords(x['ua']) - nwords(src['ua'])) <= 3
                 and len(set(norm(x['ua']).split()) & set(norm(src['ua']).split())) <= 1]
        same = [x for x in cands if x in pools.by_module[module]['listen']]
        pick = (same if len(same) >= 2 else cands)
        if len(pick) < 2:
            return None
        ds = [x['ua'] for x in rng.sample(pick, 2)]
        if len({norm(d) for d in ds}) < 2:
            return None
        opts, ci = choice(src['ua'], ds)
        return {**base, 'prompt_ua': 'Послухайте. Що сказали?', 'audio_hr': src['hr'], 'options': opts, 'correct_index': ci,
                'explanation_ua': f'Прозвучало: «{src["hr"]}» — «{src["ua"]}».'}

    if kind == 'read':
        r, qq = src['text'], src['question']
        opts = list(qq['options'])
        rng.shuffle(opts)
        return {**base, 'prompt_ua': qq['question_ua'], 'passage_hr': r['body_hr'], 'passage_ua': r['body_ua'],
                'prompt_hr': r['title_hr'], 'options': opts, 'correct_index': opts.index(qq['answer']),
                'explanation_ua': f'Текст «{r["title_ua"]}». Правильна відповідь: «{qq["answer"]}».'}

    if kind == 'reply':
        first2 = norm(src['hr']).split()[:2]
        cands = [x for mo, pm in pools.by_module.items() if mo != module for x in pm['reply']
                 if norm(x['hr']).split()[:2] != first2 and norm(x['hr']) != norm(src['hr'])
                 and norm(x['hr']).split()[0] not in YESNO_START and norm(x['hr']).split()[0] != first2[0]
                 and not (categories(x['hr']) & categories(src['hr']))
                 and not (set(norm(x['hr']).split()) & set(norm(src['prompt_hr']).split()) - {'je', 'i', 'u', 'na', 'se', 'sam', 'li', 'a'})]
        if len(cands) < 2:
            return None
        ds = [x['hr'] for x in rng.sample(cands, 2)]
        if len({norm(d) for d in ds}) < 2:
            return None
        opts, ci = choice(src['hr'], ds)
        return {**base, 'prompt_ua': 'Вам кажуть. Що доречно відповісти?', 'prompt_hr': src['prompt_hr'], 'audio_hr': src['prompt_hr'],
                'options': opts, 'correct_index': ci,
                'explanation_ua': f'Діалог «{src["dialogue"]}»: «{src["prompt_hr"]}» ({src["prompt_ua"]}) — «{src["hr"]}» ({src["ua"]}).'}

    if kind == 'relay':
        ds = [x['ua'] for x in rng.sample(src['others'], 2)]
        if len({norm(d) for d in ds} | {norm(src['ua'])}) < 3:
            return None
        opts, ci = choice(src['ua'], ds)
        passage = '\n'.join(f'{t["speaker"]}: {t["hr"]}' for t in src['turns'])
        passage_ua = '\n'.join(f'{t["speaker"]}: {t["ua"]}' for t in src['turns'])
        return {**base, 'prompt_ua': 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:',
                'prompt_hr': src['q_hr'], 'passage_hr': passage, 'passage_ua': passage_ua, 'options': opts, 'correct_index': ci,
                'explanation_ua': f'Діалог «{src["dialogue"]}»: «{src["q_hr"]}» — «{src["hr"]}», тобто «{src["ua"]}».'}

    if kind == 'ua2hr':
        cands = [x for x in pools.by_module[module]['speak'] if norm(x['hr']) != norm(src['hr']) and norm(x['ua']) != norm(src['ua'])]
        if len(cands) < 2:
            cands = [x for x in pools.all_of('speak', list(pools.by_module)) if norm(x['hr']) != norm(src['hr'])]
        ds = [x['hr'] for x in rng.sample(cands, 2)]
        if len({norm(d) for d in ds}) < 2:
            return None
        opts, ci = choice(src['hr'], ds)
        return {**base, 'prompt_ua': f'Друг-українець просить вас сказати хорватською: «{src["ua"].rstrip(".")}». Що ви скажете?',
                'options': opts, 'correct_index': ci, 'explanation_ua': f'«{src["ua"]}» — «{src["hr"]}».'}

    if kind == 'type':
        return {**base, 'prompt_ua': src['prompt'], 'answer_text': src['hr'], 'explanation_ua': f'«{src["ua"]}» — {src["hr"]}.'}

    if kind == 'build':
        tiles = src['hr'].split()
        if len(tiles) < 2 or len(tiles) > 16:
            return None
        shuffled = tiles[:]
        for _ in range(5):
            rng.shuffle(shuffled)
            if shuffled != tiles:
                break
        return {**base, 'prompt_ua': src['prompt'], 'answer_text': src['hr'], 'options': shuffled,
                'explanation_ua': f'«{src["ua"]}» — «{src["hr"]}».'}

    if kind == 'speak':
        return {**base, 'prompt_ua': f'Скажіть хорватською: «{src["ua"]}»', 'answer_text': src['hr'],
                'explanation_ua': f'«{src["ua"]}» — «{src["hr"]}».'}
    raise ValueError(kind)


def fill_test(pools: Pools, used: set, kind_plan: list[tuple[str, int]], mods: list[int], slug: str,
              seed: str | None = None) -> list[dict]:
    """Завдання одного тесту з модулів mods. used — джерела, уже взяті іншими тестами рівня (доповнюється).
    seed — інше зерно випадковості (за замовчуванням slug)."""
    rng = random.Random(seed or slug)
    items = []
    in_test: set = set()  # одна й та сама репліка — не двічі в тесті (навіть у різних завданнях)
    # спершу рідкісні джерела (репліки з діалогів), потім решта; показуємо — у порядку PLAN
    scarce = ['relay', 'reply', 'read', 'ua2hr', 'speak', 'build', 'type', 'listen']
    for kind, count in sorted(kind_plan, key=lambda kc: scarce.index(kc[0])):
        got = 0
        # по черзі з модулів, щоб тест покривав увесь діапазон
        order = mods[:]
        rng.shuffle(order)
        tries = 0
        while got < count and tries < 40:
            mo = order[(got + tries) % len(order)]
            pool = [x for x in pools.by_module[mo][kind] if x['key'] not in used and x['key'][1:] not in in_test]
            tries += 1
            if not pool:
                continue
            src = rng.choice(pool)
            item = make_item(kind, src, pools, mo, rng)
            used.add(src['key'])
            if item is None:
                continue
            in_test.add(src['key'][1:])
            item['module'] = mo
            items.append(item)
            got += 1
        if got < count:
            raise SystemExit(f'{slug}: замало джерел для «{kind}» ({got} з {count})')
    display = [k for k, _ in kind_plan]
    return sorted(items, key=lambda it: display.index(it['kind']))


def build_level(level: dict) -> list[dict]:
    pools = Pools(level)
    lv = pools.level
    used: set = set()
    tests = []
    modules = sorted(pools.by_module)

    def fill(kind_plan: list[tuple[str, int]], mods: list[int], slug: str) -> list[dict]:
        return fill_test(pools, used, kind_plan, mods, slug)

    for mo in modules:
        slug = f'{lv.lower()}-m{mo:02d}'
        m = next(x for x in pools.modules if x['order'] == mo)
        tests.append({'slug': slug, 'kind': 'module', 'module': mo, 'order': mo, 'title_ua': f'Перевірка модуля {lv}.{mo}',
                      'module_title': m['title_ua'], 'items': fill(PLAN['module'], [mo], slug)})
    mid = {'slug': f'{lv.lower()}-mid', 'kind': 'mid', 'module': None, 'order': 50, 'title_ua': f'Перевірка середини рівня {lv}',
           'items': fill(PLAN['mid'], modules[:5], f'{lv.lower()}-mid')}
    final = {'slug': f'{lv.lower()}-final', 'kind': 'final', 'module': None, 'order': 100, 'title_ua': f'Фінальна перевірка рівня {lv}',
             'items': fill(PLAN['final'], modules, f'{lv.lower()}-final')}
    tests.insert(5, mid)
    tests.append(final)
    for t in tests:
        for i, it in enumerate(t['items']):
            it['order'] = i + 1
            it['id'] = uid('assessment', t['slug'], 'item', i + 1)
        t['id'] = uid('assessment', t['slug'])
    validate(tests, lv)
    return tests


def validate(tests: list[dict], lv: str):
    problems = []
    for t in tests:
        expected = Counter(AREA[k] for k, n in PLAN[t['kind']] for _ in range(n))
        got = Counter(it['area'] for it in t['items'])
        if got != expected:
            problems.append(f'{t["slug"]}: навички {dict(got)} ≠ {dict(expected)}')
        seen = set()
        for it in t['items']:
            where = f'{t["slug"]} #{it["order"]} ({it["kind"]})'
            for f in ('audio_hr', 'passage_hr', 'prompt_hr', 'answer_text'):
                if it[f] and CYR.search(it[f]):
                    problems.append(f'{where}: кирилиця в {f}')
            if not CYR.search(it['prompt_ua']):
                problems.append(f'{where}: питання не українською')
            if it['item_type'] == 'multiple_choice':
                opts = it['options']
                if len({norm(o) for o in opts}) != len(opts) or not (2 <= len(opts) <= 6):
                    problems.append(f'{where}: варіанти повторюються або їх не 2–6: {opts}')
                ua_opts = [bool(CYR.search(o)) for o in opts]
                if it['kind'] in ('listen', 'relay') and not all(ua_opts):
                    problems.append(f'{where}: варіанти мають бути українською')
                if it['kind'] in ('reply', 'ua2hr') and any(ua_opts):
                    problems.append(f'{where}: варіанти мають бути хорватською')
                langs = {'ua' if CYR.search(o) else 'hr' for o in opts if re.search(r'[^\W\d_]', o)}
                if it['kind'] == 'read' and len(langs) > 1:
                    problems.append(f'{where}: варіанти змішаними мовами')
            else:
                if not it['answer_text']:
                    problems.append(f'{where}: немає відповіді')
            sig = (it['kind'], norm(it.get('answer_text') or it['options'][it['correct_index']]))
            if sig in seen:
                problems.append(f'{where}: повтор у тесті')
            seen.add(sig)
            if re.search(r'osnovni_pojam|базовий термін|placeholder|todo', json.dumps(it, ensure_ascii=False), re.I):
                problems.append(f'{where}: заглушка')
    if problems:
        raise SystemExit('Перевірка не пройдена:\n' + '\n'.join(problems))


# ---------------------------------------------------------------- SQL
def sql_level(tests: list[dict], lv: str) -> str:
    out = [f"""-- =====================================================================
-- Тести рівня {lv} (§60): 10 тестів модуля + середина рівня + фінальний · assessment_v1 · 2026-10-15
-- Згенеровано: python3 scripts/gen_assessment.py {lv}  (джерело — опубліковані уроки й тексти {lv})
-- Потребує M17 (20261015160000_m17_level_assessments.sql). Безпечно запускати повторно:
-- наявні тести й завдання не перезаписуються. Статус: {STATUS} (бета за рішенням власника 2026-10-15).
-- Що змінить: додасть {len(tests)} тестів і {sum(len(t['items']) for t in tests)} завдань, запис у журнал перевірки.
-- =====================================================================
"""]
    for t in tests:
        module_sql = f"(select id from public.modules where level_code = {q(lv)} and order_index = {t['module']})" if t['module'] else 'null'
        out.append(f"-- {t['title_ua']}" + (f" · {t['module_title']}" if t.get('module_title') else ''))
        out.append(
            'insert into public.assessments (id, slug, kind, title_ua, cefr, module_id, order_index, pass_ratio, area_min_ratio, '
            'estimated_minutes, description_ua, status, source)\n'
            f"values ({q(t['id'])}, {q(t['slug'])}, {q(t['kind'])}, {q(t['title_ua'])}, {q(lv)}, {module_sql}, {t['order']}, 0.70, 0.50, "
            f"{MINUTES[t['kind']]}, {q(DESCRIPTION[t['kind']])}, {q(STATUS)}, {q(SOURCE)})\n"
            'on conflict (slug) do nothing;')
        rows = []
        for it in t['items']:
            lesson_sql = f"(select id from public.lessons where id = {q(it['lesson'])})" if it['lesson'] else 'null'
            rows.append(
                f"  ({q(it['id'])}, {q(t['id'])}, {it['order']}, {q(lv)}, {q(it['skill'])}, {q(it['area'])}, {q(it['item_type'])}, "
                f"{q(it['prompt_ua'])}, {q(it['prompt_hr'])}, {qj(it['options'])}, "
                f"{it['correct_index'] if it['correct_index'] is not None else 'null'}, {q(it['answer_text'])}, "
                f"{q(it['audio_hr'])}, {q(it['passage_hr'])}, {q(it['passage_ua'])}, {q(it['explanation_ua'])}, {lesson_sql}, "
                f"{q(STATUS)}, {q(SOURCE)})")
        out.append(
            'insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options, '
            'correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values\n'
            + ',\n'.join(rows) + '\non conflict (id) do nothing;\n')

    slugs = ', '.join(q(t['slug']) for t in tests)
    total = sum(len(t['items']) for t in tests)
    out.append(f"""-- Журнал перевірки (один запис на тест)
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'assessment', a.id, null, a.status, 'auto_passed', 'script', '[]'::jsonb, {q(REVIEW_NOTE)}
from public.assessments a
where a.source = {q(SOURCE)} and a.slug in ({slugs})
  and not exists (select 1 from public.content_reviews c where c.entity_id = a.id and c.notes = {q(REVIEW_NOTE)});

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_tests int; v_items int; v_bad int;
begin
  select count(*) into v_tests from public.assessments where source = {q(SOURCE)} and slug in ({slugs}) and cefr = {q(lv)};
  select count(*) into v_items from public.assessment_items i join public.assessments a on a.id = i.assessment_id
   where a.source = {q(SOURCE)} and a.slug in ({slugs});
  select count(*) into v_bad from public.assessments a
   where a.source = {q(SOURCE)} and a.slug in ({slugs}) and (a.kind = 'module' and a.module_id is null);
  if v_tests <> {len(tests)} then raise exception 'Тестів %, очікувалось {len(tests)}', v_tests; end if;
  if v_items <> {total} then raise exception 'Завдань %, очікувалось {total}', v_items; end if;
  if v_bad > 0 then raise exception '% тестів модуля без модуля', v_bad; end if;
  raise notice 'Готово: тести рівня {lv} — %, завдань — %', v_tests, v_items;
end $$;
""")
    return '\n'.join(out)


# ---------------------------------------------------------------- звіт для перевірки
KIND_UA = {'listen': 'на слух', 'read': 'читання', 'reply': 'відповідь у розмові', 'relay': 'переказати українською',
           'ua2hr': 'передати хорватською', 'type': 'написати', 'build': 'скласти речення', 'speak': 'сказати вголос'}


def report(all_tests: dict[str, list[dict]]) -> str:
    lines = ['# Тести рівня A0 і A1 (assessment_v1) — звіт для перевірки', '',
             '> Згенеровано `scripts/gen_assessment.py` 2026-10-15. Хорватське взято з опублікованих уроків і текстів для читання;',
             '> нових хорватських речень немає. Нове — лише **поєднання**: які варіанти стоять поруч як «неправильні».', '',
             '## Що варто глянути носію', '',
             '1. **«Спілкуюся»** — чи не підходить одна з «неправильних» відповідей теж (тоді тест несправедливий).',
             '   Пастки взято з діалогів інших модулів; загальні відповіді (*Hvala*, *Može*, *U redu*…) відкинуто.',
             '2. **«Переказую»** — чи переклад відповіді в діалозі точний (його взято з уроку).',
             '3. **«Складіть речення»** — чи немає іншого правильного порядку слів (зараз приймається лише один).',
             '4. **`a1-mid` #10** (і урок-джерело): *Umoran je. Prvo ga kupamo, a onda ga presvuci.* — «ми купаємо», але «ти переодягни»: чи природно, чи краще *…a onda ga presvučemo*.', '',
             '## Склад', '',
             '| Тест | Завдань | Розумію | Спілкуюся | Переказую | Кажу |', '|---|---|---|---|---|---|']
    for lv, tests in all_tests.items():
        for t in tests:
            c = Counter(it['area'] for it in t['items'])
            lines.append(f"| `{t['slug']}` {t['title_ua']} | {len(t['items'])} | {c['understand']} | {c['interact']} | {c['mediate']} | {c['produce']} |")
    lines.append('')
    for lv, tests in all_tests.items():
        lines.append(f'## Завдання «Спілкуюся» {lv} (усі)')
        lines.append('')
        for t in tests:
            for it in t['items']:
                if it['kind'] == 'reply':
                    opts = ' / '.join(('**' + o + '**') if i == it['correct_index'] else o for i, o in enumerate(it['options']))
                    lines.append(f"- `{t['slug']}` #{it['order']}: *{it['prompt_hr']}* → {opts}")
        lines.append('')
    return '\n'.join(lines) + '\n'


def main():
    data = json.loads(SNAPSHOT.read_text(encoding='utf-8'))
    levels = {L['level']: L for L in data['levels']}
    if len(sys.argv) > 1 and sys.argv[1] == '--report':
        print(report({lv: build_level(levels[lv]) for lv in ('A0', 'A1')}), end='')
        return
    if len(sys.argv) > 1 and sys.argv[1] == '--json':
        print(json.dumps({lv: build_level(levels[lv]) for lv in ('A0', 'A1')}, ensure_ascii=False, indent=1))
        return
    lv = sys.argv[1] if len(sys.argv) > 1 else 'A0'
    print(sql_level(build_level(levels[lv]), lv), end='')


if __name__ == '__main__':
    main()
