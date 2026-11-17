#!/usr/bin/env python3
"""
Дублі A0 · 2026-11-17 — план docs/proposals/2026-11-16_lesson_duplicates.md, PR 2б (рішення власника 2026-11-17).

  python3 -B scripts/gen_a0_dupes.py               →  supabase/data_fixes/20261117_a0_dupes_1_lessons.sql
                                                       supabase/data_fixes/20261117_a0_dupes_2_reading.sql
  python3 -B scripts/gen_a0_dupes.py --check       →  лише перевірка даних (нічого не пише)
  python3 -B scripts/gen_a0_dupes.py --review      →  content/reviews/2026-11-17_a0_dupes.md (для носія)
  python3 -B scripts/gen_a0_dupes.py assessments   →  supabase/data_fixes/20261117_a0_dupes_3_tests.sql
                                                       (знімок після пакетів 1–2 — scripts/assessment_a0_dupes_snapshot.json)

Дані — scripts/curriculum_a0_dupes_data.py. Знімок — scripts/curriculum_a0_dupes_snapshot.json (запит — scripts/a0_dupes_source.sql).

Пакет 1 (уроки):
  1. нові слова (з мітками; PUBLISHED — бета); наявні слова, які вперше вчать в A0, — рівень A0 (стара версія — content_versions);
  2. новий урок 69 «В аптеці» (модуль A0.11 «Survival», місце 4; наступні уроки модуля — на місце далі): 8 слів з уроку 68,
     нові слова, діалог «U ljekarni» з уроку 68 + новий «Dežurna ljekarna», 15 вправ, письмо й переказ;
  3. уроки 30, 58, 64, 68: слова — заміна на тому самому місці (Д10, Д9, Д4, Д12), діалог — новий замість старого
     (старий — DEPRECATED), вправи на прибрані слова й діалоги — нові на тому самому місці (старі — DEPRECATED);
     урок 68 — «У лікаря»; урок 69 «Допоможіть!» (стане 70) — + zovite vatrogasce;
  4. kabina, probati, pristajati — в A1-24 «У приміряльні» (слово не зникає з курсу; рівень слова — A1);
  5. діалог уроку 26 «Na kolodvoru» → «Vlak za Rijeku» (така сама назва — в уроці 7);
  6. наскрізні номери всіх уроків A0 (72 → 73), порядок діалогів v4 за новим номером.
  Копії — backup.lesson_items_a0dupes_20261117; старі версії уроків і діалогу — у content_versions.
Пакет 2: 2 тексти для читання модуля A0.6 «Kućni ljubimci» (RD-A0-021, RD-A0-022).
Пакет 3 (перевірки): a0-m09 (1 завдання було з прибраного діалогу), a0-m11 (8 уроків — 16 завдань), фінал a0-final —
наново з усіх 11 модулів (з A0.6 і новими уроками). Середина (a0-mid, A0.1–A0.5) не змінюється.
Повторний запуск кожного пакета нічого не змінює.
"""
from __future__ import annotations

import json
import re
import sys
import uuid
from pathlib import Path
from types import SimpleNamespace

sys.dont_write_bytecode = True
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE))
import curriculum_a0_dupes_data as D  # noqa: E402
import gen_writing as GW  # noqa: E402
from full_lessons import CYR, HELPERS_SQL, Course, Place, fold_ua, q, qj, shuffled, uid  # noqa: E402
from lexeme_checks import check_batch, normalize  # noqa: E402

ROOT = HERE.resolve().parent
FIXES = ROOT / 'supabase' / 'data_fixes'
REVIEWS = ROOT / 'content' / 'reviews'
SNAPSHOT = json.loads((HERE / 'curriculum_a0_dupes_snapshot.json').read_text(encoding='utf-8'))
OUT = FIXES / '20261117_a0_dupes_1_lessons.sql'
OUT_READING = FIXES / '20261117_a0_dupes_2_reading.sql'
OUT_ASSESS = FIXES / '20261117_a0_dupes_3_tests.sql'
REVIEW_OUT = REVIEWS / '2026-11-17_a0_dupes.md'
LEVEL = 'A0'
MOD = 11                    # «Survival»
STATUS = 'PUBLISHED'        # бета (A0 — рішення власника 2026-10-15)
SOURCE = 'claude_curriculum_a0_dupes'
MINUTES = 15
OLD_TOTAL, NEW_TOTAL = 72, 73
SITUATIONS = set(re.findall(r"code: '([a-z_]+)'", (ROOT / 'lib' / 'situations.ts').read_text(encoding='utf-8')))
POS = {'n': 'noun', 'v': 'verb', 'adj': 'adjective', 'adv': 'adverb', 'ph': 'phrase', 'prep': 'preposition', 'int': 'interjection'}
GRAMMAR_A0 = {'Ввічливість: ti і Vi', 'Дієслово «imati» (мати)', 'Питальні слова'}
UNIT_ID = '7c5becd1-c264-59f4-972e-fd095492d394'      # юніт модуля A0.11 «Survival»
NEW_ORDER = 4                                          # місце нового уроку в юніті (після уроку 68)
NEW_LESSON_ID = uid('lesson_a0dupes', LEVEL, MOD, D.PHARMACY['slug'])
WRITING_NS = uuid.uuid5(uuid.NAMESPACE_URL, 'croatia-survival/writing-pilot-20261105')   # той самий простір, що в gen_writing.py
NOTE_LESSON = ('a0_dupes 20261117: план «Дублі й сенс уроків» (PR 2б, рішення власника 2026-11-17) — {what}. '
               'Бета, потрібна перевірка носієм.')
NOTE_NEW = ('Бета: новий урок «В аптеці» (A0-62 «У лікаря й в аптеці» → два уроки, рішення власника 2026-11-17, Д12) за схемою '
            'уроків за темою (curriculum_a0_v4: 20–25 слів, 2 діалоги, 15 вправ) + письмо й переказ. Потрібна перевірка носієм.')
NOTE_WRITING = ('a0_dupes 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) — {what}. '
                'Бета, потрібна перевірка носієм.')
NOTE_READING = ('Бета: тексти для читання модуля A0.6 «Kućni ljubimci» (план «Дублі й сенс уроків», PR 2б, 2026-11-17). '
                'Знайомі слова — уроки A0. Потрібна перевірка носієм.')

ITEMS = SNAPSHOT['items']
CONVS = {c['id']: c for c in SNAPSHOT['conversations']}
TAKEN = SNAPSHOT['lessons']        # lower(лема) → перший урок (усі рівні)
# lower(лема) → уроки A1, де є слово (зі знімка складу уроків — лише для прибраних слів)
TAKEN_A1 = {'prevelik': 'A1 Урок 24', 'premalen': 'A1 Урок 24', 'pisanica': 'A1 Урок 96', 'dan državnosti': 'A1 Урок 97',
            'neradni dan': 'A1 Урок 97'}


# ----------------------------------------------------------------------------- слова
def forms_of(code: str) -> dict:
    if not code:
        return {}
    if code.split(':')[0] in ('ipfv', 'pfv', 'biasp'):
        a, _, pair = code.partition(':')
        return {'aspect': a, **({'pair': pair} if pair else {})}
    return {'gender': code}


def vtype_of(pos: str, lemma: str) -> str:
    if lemma in D.FORMULAIC or pos == 'interjection':
        return 'formulaic'
    return {'phrase': 'chunk', 'preposition': 'function_word'}.get(pos, 'core')


def new_lexemes() -> list[dict]:
    rows = []
    for _n, vocab in D.NEW_LEXEMES.items():
        for lemma, ua, pos, forms, example in vocab:
            p = POS[pos]
            rows.append(dict(lemma=lemma, normalized=normalize(lemma), ukrainian_translation=ua, part_of_speech=p, cefr=LEVEL,
                             vocabulary_type=vtype_of(p, lemma), forms=forms_of(forms), examples=[example],
                             register='standard', regionality='general', usage_tags=[]))
    return rows


NEW = {r['lemma'].lower(): r for r in new_lexemes()}


def removed_words() -> list[str]:
    """Слова, які прибрано з уроків A0 (не ті, що переходять в «В аптеці»): їх учать в A1 (A1-24, A1-31, A1-96, A1-97)."""
    moved = {w.lower() for w in D.PHARMACY['moved']}
    return [o for n in sorted(D.CHANGES) for o, _ in D.CHANGES[n].get('swap', []) if o.lower() not in moved]


def to_a1_words() -> list[str]:
    """Прибрані слова, які тепер учать в уроках A1 (рівень слова — A1). mjesečna karta, presjesti, kontrolor — ні в якому уроці
    (в A1-31 — mjesečna pokazna karta, presjedati, kontrolor karata), їхній рівень не змінюється."""
    a1 = {w.lower() for w in D.TO_A1_24}
    return [w for w in removed_words() if w.lower() in a1 or ' A1 ' in f" {TAKEN_A1.get(w.lower(), '')} "]


def lex_map() -> dict:
    lex = {}
    for L in SNAPSHOT['a0']:
        for lemma, ua in L['words']:
            lex[lemma.lower()] = (lemma, ua)
    for lemma, (ua, _cefr) in D.EXISTING.items():
        lex[lemma.lower()] = (lemma, ua)
    for r in NEW.values():
        lex[r['lemma'].lower()] = (r['lemma'], r['ukrainian_translation'])
    return lex


LEX = lex_map()


def lesson_items(n: int) -> list[dict]:
    return [it for it in ITEMS if it['lesson'] == D.LESSON_IDS[n]]


def words_of(n: int) -> list[str]:
    return [it['lemma'] for it in lesson_items(n) if it['type'] == 'lexeme']


def words_after(n: int) -> list[str]:
    """Слова уроку після заміни (на тих самих місцях) і додавання."""
    ch = D.CHANGES.get(n, {})
    swap = {o.lower(): w for o, w in ch.get('swap', [])}
    return [swap.get(w.lower(), w) for w in words_of(n)] + list(ch.get('add', []))


def pharmacy_words() -> list[str]:
    P = D.PHARMACY
    return list(P['moved']) + [v[0] for v in D.NEW_LEXEMES[69]] + list(P['known'])


def scene_turns(n: int) -> list[str]:
    """Тексти діалогів уроку після змін (для перевірки «прослухайте»)."""
    ch = D.CHANGES[n]
    old, new = ch['conv']
    lid = D.LESSON_IDS[n]
    out = []
    for c in SNAPSHOT['conversations']:
        if c['lesson'] != lid or c['id'] == old or c['id'] == ch.get('move_conv'):
            continue
        out.append(' '.join(hr for _sp, hr, _ua in c['turns']))
    out.append(' '.join(hr for _sp, hr, _ua in new[3]))
    return out


def display_ua(word: str) -> str:
    t = LEX[word.lower()][1].strip().rstrip('.')
    if LEX[word.lower()][0][:1].islower():
        t = ' / '.join(seg if seg[1:2].isupper() else seg[:1].lower() + seg[1:] for seg in t.split(' / '))
    return t


# ----------------------------------------------------------------------------- новий урок «В аптеці»
class CourseDupes(Course):
    def validate_lesson(self, key):
        L = self.lessons[key]
        w = self.name(key)
        self.check_ua(L['title'][0], w)
        self.check_hr(L['title'][1], w)
        for o in L['objectives']:
            self.check_ua(o, w + '.objective')
        if L['situation'] not in self.situations:
            self.errors.append(f'{w}: невідома ситуація {L["situation"]!r}')
        if L['grammar'] not in self.grammar_keys:
            self.errors.append(f'{w}: невідома граматика {L["grammar"]!r}')
        words = L['words']
        if not 20 <= len(words) <= 25:
            self.errors.append(f'{w}: слів {len(words)} (має бути 20–25)')
        if len({x.lower() for x in words}) != len(words):
            self.errors.append(f'{w}: слова повторюються')
        texts = [' '.join(hr for _, hr, _ in turns) for _s_ua, _s_hr, turns in L['scenes']]
        question, answer, wrong = L['fill']
        if '___' not in question or len({answer, *wrong}) != 4:
            self.errors.append(f'{w}.fill: пропуск і 4 різні варіанти')
        for hint, sentence in L['build']:
            self.check_ua(hint, w + '.build')
            self.tokens(sentence, w + '.build')
        for li, sentence in enumerate(L['listen']):
            self.tokens(sentence, w + '.listen')
            if sentence not in texts[li]:
                self.errors.append(f'{w}: «прослухайте» {li + 1} не з діалогу {li + 1}: {sentence!r}')
        for ua, hr in L['speak']:
            self.check_ua(ua, w + '.speak')
            self.check_hr(hr, w + '.speak')


PH_KEY = (MOD, NEW_ORDER)


def pharmacy_lesson() -> dict:
    P = D.PHARMACY
    moved = CONVS[D.CHANGES[68]['move_conv']]
    s1 = (moved['title_ua'], moved['title_hr'], [tuple(t) for t in moved['turns']])
    return dict(title=P['title'], situation=P['situation'], grammar=P['grammar'], objectives=P['objectives'],
                words=pharmacy_words(), scenes=[s1, P['scene2']], fill=P['fill'], build=P['build'], listen=P['listen'],
                speak=P['speak'], write=P['write'], mediation=P['mediation'])


def build_course() -> CourseDupes:
    pool = [w for L in SNAPSHOT['a0'] for w, _ua in L['words']]
    module_words = [w for L in SNAPSHOT['a0'] if L['module'] == MOD for w, _ua in L['words']]
    module_words = [w for w in module_words if w.lower() not in {x.lower() for x in D.PHARMACY['moved']}] + words_after(68)
    return CourseDupes(level=LEVEL, lessons={PH_KEY: pharmacy_lesson()}, place={PH_KEY: Place(MOD, NEW_ORDER, 69)}, lex=LEX,
                       situations=SITUATIONS, grammar_keys=GRAMMAR_A0, seed_prefix='a0dupes', extra_pool=pool,
                       extra_module_words={MOD: module_words}, words_range=(20, 25), vocab_counts=(3, 2, 3))


def pharmacy_writing() -> SimpleNamespace:
    L = pharmacy_lesson()
    return SimpleNamespace(DATE=D.DATE, TITLE='урок A0 «В аптеці»', LEVELS={LEVEL},
                           MEDIATION_SITUATION='Друг не знає хорватської. Перекажіть йому українською головне.',
                           LESSONS={NEW_LESSON_ID: dict(title='A0 урок 69 В аптеці', level=LEVEL, write=L['write'], mediation=L['mediation'])})


# ----------------------------------------------------------------------------- перевірка
def check_writing(where: str, kind: str, spec: dict) -> list[str]:
    """Ті самі правила, що в gen_writing.validate (без перевірки «урок уже має вправи» — це заміна наявних)."""
    errors = []
    lang = 'hr' if kind == 'write_message' else 'ua'
    for model in spec['models']:
        if bool(CYR.search(model)) != (lang == 'ua'):
            errors.append(f'{where}: мова зразка «{model}»')
        for ua, keys in spec['points']:
            if not GW.point_done(model, keys, lang):
                errors.append(f'{where}: зразок «{model}» не виконує пункт «{ua}»')
    if kind == 'write_message' and not CYR.search(spec['situation']):
        errors.append(f'{where}: ситуація має бути українською')
    if kind == 'mediation' and CYR.search(spec['source']):
        errors.append(f'{where}: текст для переказу (hr → ua) — хорватською')
    if not 1 <= len(spec['points']) <= 5:
        errors.append(f'{where}: 1–5 пунктів')
    junk = 'Da, ne.' if lang == 'hr' else 'Так, ні.'
    if all(GW.point_done(junk, keys, lang) for _, keys in spec['points']):
        errors.append(f'{where}: пункти зараховуються на «{junk}»')
    return errors


def old_exercise(n: int, answer: str) -> dict | None:
    hits = [it for it in lesson_items(n) if it['type'] == 'exercise' and it['answer'] == answer]
    return hits[0] if len(hits) == 1 else None


def lesson_words_ua(words: list[str]) -> dict[str, str]:
    return {display_ua(w): w for w in words}


def validate() -> tuple[list[str], list[str]]:
    errors: list[str] = []
    seen_new: dict[str, str] = {}
    a0_after = {}
    for L in SNAPSHOT['a0']:
        a0_after[L['id']] = [w for w, _ in L['words']]
    # нові слова: ні в одному уроці, без повторів
    for n, vocab in D.NEW_LEXEMES.items():
        for v in vocab:
            k = v[0].lower()
            if k in TAKEN:
                errors.append(f'«{v[0]}» уже є в уроці {TAKEN[k]}')
            if k in seen_new:
                errors.append(f'«{v[0]}» двічі серед нових ({seen_new[k]}, {n})')
            seen_new[k] = str(n)
    for w in D.EXISTING:
        if w.lower() in TAKEN:
            errors.append(f'наявне «{w}» уже є в уроці {TAKEN[w.lower()]}')
    used = [w for n in D.CHANGES for w in [x[1] for x in D.CHANGES[n].get('swap', [])] + D.CHANGES[n].get('add', [])]
    used += [v[0] for v in D.NEW_LEXEMES[69]] + list(D.PHARMACY['known'])
    for w in set(seen_new) | {x.lower() for x in D.EXISTING}:
        if sum(1 for u in used if u.lower() == w) != 1:
            errors.append(f'слово «{w}» має бути рівно в одному уроці пакета')
    for w in D.PHARMACY['moved']:
        if w.lower() not in {x.lower() for x in words_of(68)}:
            errors.append(f'«{w}» немає в уроці 68')
        if w.lower() not in {o.lower() for o, _ in D.CHANGES[68]['swap']}:
            errors.append(f'«{w}» переходить в «В аптеці», але не прибране з уроку 68')
    # зміни уроків
    for n, ch in D.CHANGES.items():
        cur = [w.lower() for w in words_of(n)]
        for old, new in ch.get('swap', []):
            if old.lower() not in cur:
                errors.append(f'урок {n}: «{old}» немає серед слів')
            if new.lower() not in LEX:
                errors.append(f'урок {n}: «{new}» немає ні в знімку, ні серед нових')
        after = words_after(n)
        if not 20 <= len(after) <= 25:
            errors.append(f'урок {n}: слів після змін {len(after)} (має бути 20–25)')
        if len({w.lower() for w in after}) != len(after):
            errors.append(f'урок {n}: слова повторюються після змін')
        if 'conv' in ch:
            old, (s_ua, s_hr, sit, turns) = ch['conv']
            if old is not None and (old not in CONVS or CONVS[old]['lesson'] != D.LESSON_IDS[n]):
                errors.append(f'урок {n}: діалогу {old} немає в уроці')
            if sit not in SITUATIONS or not 6 <= len(turns) <= 8:
                errors.append(f'урок {n}: ситуація чи кількість реплік нового діалогу')
            if not CYR.search(s_ua) or CYR.search(s_hr):
                errors.append(f'урок {n}: мова назви діалогу')
            for sp, hr, ua in turns:
                if CYR.search(hr) or CYR.search(sp) or not CYR.search(ua) or hr != hr.strip() or '  ' in hr:
                    errors.append(f'урок {n}: репліка {hr!r}')
        texts = scene_turns(n) if 'conv' in ch else []
        ua_of = lesson_words_ua(after)
        hr_of = {w.lower() for w in after}
        for old_answer, ex in ch.get('ex', []):
            o = old_exercise(n, old_answer)
            where = f'урок {n}, вправа замість «{old_answer}»'
            if o is None:
                errors.append(f'{where}: стару вправу не знайдено (або їх кілька)')
                continue
            if o['ex_type'] != ex['type']:
                errors.append(f'{where}: тип {ex["type"]} замість {o["ex_type"]}')
            if ex['type'] == 'multiple_choice':
                opts = ex['options']
                if len(set(opts)) != 4 or ex['answer'] not in opts:
                    errors.append(f'{where}: 4 різні варіанти з правильним')
                if ex['question'].startswith('Що означає'):
                    if any(x not in ua_of for x in opts) or ua_of.get(ex['answer'], '').lower() != ex['word'].lower():
                        errors.append(f'{where}: варіанти — переклади слів уроку {opts}')
                else:
                    if any(x.lower() not in hr_of for x in opts) or ex['answer'] != LEX[ex['word'].lower()][0]:
                        errors.append(f'{where}: варіанти — слова уроку {opts}')
                    if display_ua(ex['word']) not in ex['question']:
                        errors.append(f'{where}: у питанні має бути переклад «{display_ua(ex["word"])}»')
            elif ex['type'] == 'type_answer':
                if ex['answer'] != LEX[ex['word'].lower()][0] or display_ua(ex['word']) not in ex['question']:
                    errors.append(f'{where}: «напишіть» — лема й переклад слова уроку')
                others = [w for w in after if w.lower() != ex['word'].lower()]
                if any(fold_ua(display_ua(w)) == fold_ua(display_ua(ex['word'])) for w in others):
                    errors.append(f'{where}: той самий переклад в іншого слова уроку')
            elif ex['type'] in ('listening', 'sentence_builder'):
                toks = ex['answer'].split(' ')
                if len(toks) != len(set(toks)) or len(toks) < 3 or CYR.search(ex['answer']):
                    errors.append(f'{where}: речення {ex["answer"]!r}')
                if ex['type'] == 'listening' and not any(ex['answer'] in t for t in texts):
                    errors.append(f'{where}: «прослухайте» не з діалогу уроку')
            elif ex['type'] == 'speaking':
                if CYR.search(ex['answer']) or not CYR.search(ex['question']):
                    errors.append(f'{where}: мова')
            elif ex['type'] == 'write_message':
                errors += check_writing(where, 'write_message', ex['write'])
            elif ex['type'] == 'mediation':
                errors += check_writing(where, 'mediation', ex['mediation'])
            if 'word' in ex and ex['word'].lower() not in hr_of:
                errors.append(f'{where}: слово «{ex["word"]}» не з уроку')
        # не лишилося вправ на прибрані слова
        removed = {o.lower() for o, _ in ch.get('swap', [])}
        replaced = {a for a, _ in ch.get('ex', [])}
        for it in lesson_items(n):
            if it['type'] == 'exercise' and it['lexeme'] and it['lexeme'].lower() in removed and it['answer'] not in replaced:
                errors.append(f'урок {n}: вправа на прибране «{it["lexeme"]}» лишилась: {it["question"]}')
            if it['type'] == 'exercise' and it['ex_type'] in ('sentence_builder', 'listening', 'speaking') and it['answer'] not in replaced:
                low = it['answer'].lower()
                for r in removed - {w.lower() for w in D.PHARMACY['moved']}:
                    if len(r) > 4 and re.search(r'\b' + re.escape(r[:-2]), low):
                        errors.append(f'урок {n}: у вправі «{it["answer"]}» лишилось прибране «{r}»')
    # A1-24
    a1 = [it for it in ITEMS if it['lesson'] == D.A1_24 and it['type'] == 'lexeme']
    if len(a1) + len(D.TO_A1_24) > 25 or any(w in TAKEN and not TAKEN[w].startswith('A0 Урок 58') for w in D.TO_A1_24):
        errors.append('A1-24: забагато слів або слово вже є в іншому уроці')
    # новий урок
    c = build_course()
    c.validate_lesson(PH_KEY)
    c.lesson_exercises(PH_KEY)
    errors += c.errors
    errors += GW.validate('a0_dupes', pharmacy_writing())
    # слова
    existing = {k: v for k, v in TAKEN.items()}
    e, warnings = check_batch(new_lexemes(), existing=existing)
    errors += e
    return errors, warnings


# ----------------------------------------------------------------------------- SQL: пакет 1
HELPER_TASK = """create or replace function pg_temp.ex_task(p_lesson uuid, p_pos int, p_id uuid, p_type text, p_question text, p_answer text,
                                          p_level text, p_status text, p_task jsonb, p_required boolean, p_skill text) returns int language plpgsql as $f$
begin
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, task)
  values (p_id, p_type, p_question, p_answer, null, p_level, 0, p_status, p_task) on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, required, target_skill)
  values (p_lesson, 'exercise', p_id, p_pos + 1, p_required, p_skill);
  return p_pos + 1;
end $f$;

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
  insert into backup.lesson_items_a0dupes_20261117 select li.* from public.lesson_items li where li.lesson_id = p_lesson on conflict (id) do nothing;
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
create table if not exists backup.lesson_items_a0dupes_20261117 (like public.lesson_items including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'lesson_items_a0dupes_20261117_pkey') then
    alter table backup.lesson_items_a0dupes_20261117 add constraint lesson_items_a0dupes_20261117_pkey primary key (id);
  end if;
end $$;
revoke all on backup.lesson_items_a0dupes_20261117 from anon, authenticated;
"""


def lexemes_sql() -> list[str]:
    data = [dict(lemma=r['lemma'], normalized=r['normalized'], pos=r['part_of_speech'], ua=r['ukrainian_translation'],
                 vtype=r['vocabulary_type'], forms=r['forms'], examples=r['examples'], register=r['register'],
                 regionality=r['regionality'], usage_tags=r['usage_tags']) for r in new_lexemes()]
    return [f'-- 1. Нові слова ({len(data)}): PUBLISHED (бета), з мітками; наявні в словнику не змінюються',
            'insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples,',
            '                            register, regionality, usage_tags, status, source)',
            f"select t.lemma, t.normalized, 'hr', t.pos, {q(LEVEL)}, t.ua, t.vtype, t.forms, t.examples,",
            f"       t.register, t.regionality, array(select jsonb_array_elements_text(t.usage_tags)), {q(STATUS)}, {q(SOURCE)}",
            f'  from jsonb_to_recordset({qj(data)})',
            '    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb, register text, regionality text, usage_tags jsonb)',
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


def new_lesson_sql(c: CourseDupes) -> list[str]:
    L = c.lessons[PH_KEY]
    t_ua, t_hr = L['title']
    wrows = GW.rows(pharmacy_writing())
    moved = D.CHANGES[68]['move_conv']
    s = [f'-- 2. Новий урок 69 «{t_ua}» (A0.{MOD}, місце {NEW_ORDER}): {len(L["words"])} слів, 2 діалоги, '
         f'{len(c.lesson_exercises(PH_KEY))} вправ + письмо й переказ; наступні уроки модуля — на місце далі',
         'do $$', 'declare', f'  v_unit constant uuid := {q(UNIT_ID)};', f'  v_lesson constant uuid := {q(NEW_LESSON_ID)};', '  v_gid uuid;',
         '  v_pos int := 0;', 'begin',
         '  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено',
         f"  if (select title_ua from public.lessons where id = {q(D.LESSON_IDS[68])}) not like 'Урок 68:%'",
         f"     or (select count(*) from public.lessons where unit_id = v_unit and status = 'PUBLISHED') <> 7 then",
         "    raise exception 'Модуль A0.11: очікувалось 7 уроків і урок 68 «У лікаря й в аптеці» — звірте базу';", '  end if;',
         f"  select id into v_gid from public.grammar_topics where cefr = {q(LEVEL)} and title_ua = {q(L['grammar'])} and status = 'PUBLISHED' order by created_at limit 1;",
         f"  if v_gid is null then raise exception 'Немає теми граматики «{L['grammar']}»'; end if;",
         '  -- місця 4–7 → 5–8 через 100+ (unique (unit_id, order_index))',
         f'  update public.lessons set order_index = order_index + 100 where unit_id = v_unit and order_index >= {NEW_ORDER};',
         '  update public.lessons set order_index = order_index - 99 where unit_id = v_unit and order_index > 100;',
         '  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)',
         f"  values (v_lesson, v_unit, {q(LEVEL)}, {q(f'Урок 69: {t_ua}')}, {q(f'Lekcija 69: {t_hr}')}, {qj(L['objectives'])}, {MINUTES}, {q(STATUS)}, {NEW_ORDER});",
         '  -- слова']
    for word in L['words']:
        s.append(f'  v_pos := pg_temp.word(v_lesson, {q(word)}, v_pos);')
    s += ['  -- граматика', '  v_pos := v_pos + 1;',
          "  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');",
          '  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;', '  -- вправи']
    for ei, ex in enumerate(c.lesson_exercises(PH_KEY), 1):
        opts = qj(ex['options']) if ex['options'] is not None else 'null'
        lemma = q(ex['word']) if ex.get('word') else 'null'
        s.append(f"  v_pos := pg_temp.ex(v_lesson, v_pos, {q(uid('exercise_a0dupes', LEVEL, MOD, NEW_ORDER, ei))}, {q(ex['type'])}, "
                 f"{q(ex['question'])}, {q(ex['answer'])}, {opts}, {q(LEVEL)}, {ei}, {q(STATUS)}, {lemma}, {q(ex['skill'])});")
    s.append('  -- письмо й переказ (необов’язкові)')
    note_w = NOTE_WRITING.format(what='новий урок «В аптеці»')
    for r in wrows:
        s.append(f"  v_pos := pg_temp.ex_task(v_lesson, v_pos, {q(r['id'])}, {q(r['type'])}, {q(r['question'])}, {q(r['answer'])}, "
                 f"{q(LEVEL)}, {q(STATUS)}, {qj(r['task'])}, false, {q(r['skill'])});")
        s.append('  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)')
        s.append(f"  values ('exercise', {q(r['id'])}, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(note_w)});")
    s += ['  -- діалог 1 «U ljekarni» — з уроку 68 (той самий запис, лише інший урок)',
          f"  update public.conversations set lesson_id = v_lesson, order_index = {2000 + 69 * 10 + 1} where id = {q(moved)} and status = 'PUBLISHED';",
          f"  if not found then raise exception 'Немає діалогу «U ljekarni» уроку 68 — звірте базу'; end if;"]
    s2_ua, s2_hr, turns = D.PHARMACY['scene2']
    cid = uid('conversation_a0dupes', LEVEL, MOD, NEW_ORDER, 2)
    s.append('  -- діалог 2')
    s.append('  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)')
    s.append('  -- source — як в інших діалогів уроків A0 за темою (програма curriculum_a0_v4); звідки діалог — у content_reviews')
    s.append(f"  values ({q(cid)}, v_lesson, {q(s2_ua)}, {q(s2_hr)}, {2000 + 69 * 10 + 2}, {q(LEVEL)}, {q(L['situation'])}, {q(STATUS)}, 'claude_curriculum_a0_v4') on conflict (id) do nothing;")
    for ti, (speaker, hr, ua) in enumerate(turns, 1):
        s.append(f"  perform pg_temp.turn({q(uid('turn_a0dupes', LEVEL, MOD, NEW_ORDER, 2, ti))}, {q(cid)}, {q(speaker)}, {q(hr)}, {q(ua)}, {ti});")
    s += ['  -- журнал перевірки',
          '  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
          f"  values ('lesson', v_lesson, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE_NEW)});",
          'end $$;', '']
    return s


def conv_id(n: int) -> str:
    return uid('conversation_a0dupes', LEVEL, D.LESSON_IDS[n], 'new')


def ex_id(n: int, old_id: str) -> str:
    return uid('exercise_a0dupes', LEVEL, D.LESSON_IDS[n], old_id)


def writing_task(kind: str, spec: dict) -> dict:
    ns = SimpleNamespace(MEDIATION_SITUATION='Друг не знає хорватської. Перекажіть йому українською головне.')
    return GW.task_of(ns, kind, spec)


def change_sql(n: int) -> list[str]:
    ch = D.CHANGES[n]
    lid = D.LESSON_IDS[n]
    what = {'Д10': 'урок «Свята й привітання» — лише привітання (Д10)', 'Д9': 'урок «Одяг: що купити?» без приміряльні (Д9)',
            'Д4': 'урок «Квиток на автобус» без проїзного й пересадки (Д4)', 'Д12': 'урок «У лікаря й в аптеці» → «У лікаря» (Д12)',
            'Д11': 'урок «Допоможіть!» + «zovite vatrogasce» (Д11)'}[ch['note']]
    s = [f'-- 3. Урок {n}: {what}', 'do $$', 'declare', f'  v_lesson constant uuid := {q(lid)};', 'begin']
    if 'conv' in ch:
        s.append(f'  if exists (select 1 from public.conversations where id = {q(conv_id(n))}) then return; end if;  -- уже зроблено')
    else:
        add = ch['add'][0]
        s.append(f"  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id where li.lesson_id = v_lesson "
                 f"and li.item_type = 'lexeme' and lower(x.lemma) = {q(add.lower())}) then return; end if;  -- уже зроблено")
    if n == 68:
        s.append(f"  if not exists (select 1 from public.lessons where id = {q(NEW_LESSON_ID)}) then raise exception 'Спершу — новий урок «В аптеці»'; end if;")
    s.append(f"  perform pg_temp.snapshot_lesson(v_lesson, {q('a0_dupes: ' + what + ' — стара версія')});")
    for old, new in ch.get('swap', []):
        s.append(f'  perform pg_temp.swap_word(v_lesson, {q(old)}, {q(new)});')
    for add in ch.get('add', []):
        s.append('  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill)')
        s.append(f"  select v_lesson, 'lexeme', (select id from public.lexemes where lower(lemma) = lower({q(add)}) and status = 'PUBLISHED' order by created_at limit 1),")
        s.append("         (select max(order_index) + 1 from public.lesson_items where lesson_id = v_lesson), 'vocabulary';")
    if n == 68:
        s.append('  -- 8 слів аптеки — у новому уроці «В аптеці» (вище), тут на їхніх місцях — слова про лікаря')
    for old_answer, ex in ch.get('ex', []):
        o = old_exercise(n, old_answer)
        nid = ex_id(n, o['item'])
        if ex['type'] in ('write_message', 'mediation'):
            spec = ex['write'] if ex['type'] == 'write_message' else ex['mediation']
            task = writing_task(ex['type'], spec)
            s.append(f"  perform pg_temp.swap_ex(v_lesson, {q(o['item'])}, {q(nid)}, {q(ex['type'])}, {q(task['situation_ua'])}, "
                     f"{q(task['models'][0][:500])}, null, null, {qj(task)});")
            s.append('  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)')
            s.append(f"  values ('exercise', {q(nid)}, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE_WRITING.format(what=what))});")
            continue
        if ex['type'] == 'multiple_choice':
            opts = qj(shuffled(ex['options'], f'a0dupes:{n}:{ex["answer"]}'))
        elif ex['type'] in ('listening', 'sentence_builder'):
            opts = qj(shuffled(ex['answer'].split(' '), f'a0dupes:{n}:{ex["answer"]}'))
        else:
            opts = 'null'
        s.append(f"  perform pg_temp.swap_ex(v_lesson, {q(o['item'])}, {q(nid)}, {q(ex['type'])}, {q(ex['question'])}, {q(ex['answer'])}, "
                 f"{opts}, {q(ex.get('word'))}, null);")
    if 'conv' in ch:
        old, (s_ua, s_hr, sit, turns) = ch['conv']
        cid = conv_id(n)
        if old:
            s.append(f'  -- діалог «{CONVS[old]["title_hr"]}» → «{s_hr}» (старий — DEPRECATED, не видаляється)')
            s.append(f"  update public.conversations set status = 'DEPRECATED' where id = {q(old)} and status = 'PUBLISHED';")
            s.append(f"  if not found then raise exception 'Немає діалогу «{CONVS[old]['title_hr']}» — звірте базу'; end if;")
            order = CONVS[old]['order']
            source = 'claude_curriculum_a0_v4'
        else:
            s.append(f'  -- новий другий діалог «{s_hr}» (на місці «U ljekarni», що перейшов в урок «В аптеці»)')
            order = 2000 + 68 * 10 + 2
            source = 'claude_curriculum_a0_v4'
        s.append('  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)')
        s.append('  -- source — як в інших діалогів уроку (програма curriculum_a0_v4); звідки діалог — у content_reviews')
        s.append(f"  values ({q(cid)}, v_lesson, {q(s_ua)}, {q(s_hr)}, {order}, {q(LEVEL)}, {q(sit)}, {q(STATUS)}, {q(source)});")
        for ti, (sp, hr, ua) in enumerate(turns, 1):
            s.append(f"  perform pg_temp.turn({q(uid('turn_a0dupes', cid, ti))}, {q(cid)}, {q(sp)}, {q(hr)}, {q(ua)}, {ti});")
    if 'title' in ch:
        t_ua, t_hr = ch['title']
        s.append(f"  update public.lessons set title_ua = {q(f'Урок {n}: {t_ua}')}, title_hr = {q(f'Lekcija {n}: {t_hr}')} where id = v_lesson;")
    if 'objectives' in ch:
        s.append(f"  update public.lessons set objectives = {qj(ch['objectives'])} where id = v_lesson;")
    s += ['  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
          f"  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE_LESSON.format(what=what))});",
          'end $$;', '']
    return s


def a1_24_sql() -> str:
    words = ', '.join(q(w) for w in D.TO_A1_24)
    what = 'kabina, probati, pristajati з уроку A0 «Одяг: що купити?» (Д9) — слова не зникають з курсу'
    return f"""-- 4. A1-24 «У приміряльні»: + {', '.join(D.TO_A1_24)} (з уроку A0-58 — їх більше ніде немає)
do $$
declare v_lesson constant uuid := {q(D.A1_24)}; w text;
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id
              where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = {q(D.TO_A1_24[0])}) then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, {q('a0_dupes: + ' + what + ' — стара версія')});
  foreach w in array array[{words}] loop
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill)
    select v_lesson, 'lexeme', (select id from public.lexemes where lower(lemma) = w and status = 'PUBLISHED' order by created_at limit 1),
           (select max(order_index) + 1 from public.lesson_items where lesson_id = v_lesson), 'vocabulary';
  end loop;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE_LESSON.format(what=what))});
end $$;
"""


def rename_sql() -> str:
    cid, (t_ua, t_hr) = D.RENAME_CONV
    c = CONVS[cid]
    return f"""-- 5. Назва діалогу уроку 26 «{c['title_hr']}» → «{t_hr}» (така сама назва — в уроці 7); стара — у content_versions
do $$
declare v_conv constant uuid := {q(cid)};
begin
  if (select title_hr from public.conversations where id = v_conv) = {q(t_hr)} then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), 'a0_dupes: нова назва діалогу (така сама — в уроці 7) — стара версія'
    from public.conversations c where c.id = v_conv and c.title_hr = {q(c['title_hr'])};
  if not found then raise exception 'Немає діалогу «{c['title_hr']}» уроку 26 — звірте базу'; end if;
  update public.conversations set title_ua = {q(t_ua)}, title_hr = {q(t_hr)} where id = v_conv;
end $$;
"""


RENUMBER_SQL = """-- 6. Наскрізні номери всіх уроків A0 («Урок N: …» / «Lekcija N: …»); стара назва — у content_versions;
--    порядок діалогів уроків v4 (2000 + N·10 + k) — за новим номером
do $$
declare r record; v_payload jsonb; v_new_ua text; v_new_hr text;
begin
  for r in select l.id, l.title_ua, l.title_hr,
                  row_number() over (order by m.order_index, u.order_index, l.order_index) as n
             from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
            where m.level_code = 'A0' and l.status = 'PUBLISHED' loop
    update public.conversations set order_index = 2000 + r.n * 10 + order_index % 10
     where lesson_id = r.id and order_index between 2000 and 2999 and order_index / 10 <> 200 + r.n;
    v_new_ua := regexp_replace(r.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':');
    v_new_hr := regexp_replace(r.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':');
    if v_new_ua is not distinct from r.title_ua and v_new_hr is not distinct from r.title_hr then continue; end if;
    select to_jsonb(l) into v_payload from public.lessons l where l.id = r.id;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'a0_dupes: новий номер уроку ' || r.n || ' (новий урок «В аптеці»)');
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;
"""


def selfcheck_sql() -> str:
    lids = [D.LESSON_IDS[n] for n in (30, 58, 64, 68, 69)] + [NEW_LESSON_ID]
    ids = ', '.join(q(x) for x in lids)
    nlex = len(NEW)
    lemmas = ', '.join(q(k) for k in NEW)
    removed = sorted(w.lower() for w in removed_words())
    return f"""-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_lex int;
begin
  -- уроки A0: {NEW_TOTAL}, номери 1…{NEW_TOTAL} без пропусків; у модулі A0.11 — 8 уроків, «В аптеці» — 69-й
  if (select count(*) from public.lessons where level_code = 'A0' and status = 'PUBLISHED') <> {NEW_TOTAL}
     or exists (select 1 from (select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) n
                                 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                                where m.level_code = 'A0' and l.status = 'PUBLISHED') t
                 where t.title_ua !~ ('^Урок ' || t.n || ':') or t.title_hr !~ ('^Lekcija ' || t.n || ':')) then
    raise exception 'Уроки A0: очікувалось {NEW_TOTAL} з номерами 1…{NEW_TOTAL}';
  end if;
  if (select count(*) from public.lessons where unit_id = {q(UNIT_ID)} and status = 'PUBLISHED') <> 8
     or (select title_ua from public.lessons where id = {q(NEW_LESSON_ID)}) <> 'Урок 69: В аптеці'
     or (select title_ua from public.lessons where id = {q(D.LESSON_IDS[68])}) <> 'Урок 68: У лікаря'
     or (select title_ua from public.lessons where id = {q(D.LESSON_IDS[69])}) <> 'Урок 70: Допоможіть!' then
    raise exception 'Модуль A0.11: очікувалось 8 уроків, 68 «У лікаря», 69 «В аптеці», 70 «Допоможіть!»';
  end if;
  -- змінені й новий уроки: 20–25 слів, 2 опубліковані діалоги по 5–8 реплік, 15 обов’язкових вправ (усі опубліковані) + письмо й переказ
  select count(*) into v_bad from public.lessons l
   where l.id in ({ids})
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or exists (select 1 from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED'
                      and (select count(*) from public.conversation_turns t where t.conversation_id = c.id) not between 5 and 8)
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and li.required) <> 15
          or exists (select 1 from public.lesson_items li join public.exercises e on e.id = li.item_id
                      where li.lesson_id = l.id and li.item_type = 'exercise' and e.status <> 'PUBLISHED')
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and not li.required
                 and e.exercise_type in ('write_message', 'mediation')) <> 2);
  if v_bad > 0 then raise exception 'Уроки пакета: % з неправильним складом', v_bad; end if;
  -- прибраних слів більше немає в уроках A0; kabina, probati, pristajati — в A1-24
  if exists (select 1 from public.lesson_items li join public.lessons l on l.id = li.lesson_id and l.level_code = 'A0' and l.status = 'PUBLISHED'
              join public.lexemes x on x.id = li.item_id where li.item_type = 'lexeme' and lower(x.lemma) in ({', '.join(q(r) for r in removed)})) then
    raise exception 'Прибрані слова ще в уроках A0';
  end if;
  if (select count(*) from public.lesson_items li join public.lexemes x on x.id = li.item_id
       where li.lesson_id = {q(D.A1_24)} and li.item_type = 'lexeme' and lower(x.lemma) in ({', '.join(q(w) for w in D.TO_A1_24)})) <> {len(D.TO_A1_24)} then
    raise exception 'A1-24: немає слів з уроку A0-58';
  end if;
  -- нові слова: опубліковані, з мітками
  select count(*) into v_lex from public.lexemes where lower(lemma) in ({lemmas}) and status = 'PUBLISHED'
     and register is not null and regionality is not null and usage_tags is not null;
  if v_lex <> {nlex} then raise exception 'Нових слів: % (очікувалось {nlex})', v_lex; end if;
  if exists (select 1 from public.lexemes where lower(lemma) in ({', '.join(q(w.lower()) for w in D.EXISTING)}) and status = 'PUBLISHED' and cefr <> 'A0') then
    raise exception 'Наявні слова нових уроків — не рівня A0';
  end if;
  -- діалог уроку 26 — нова назва
  if (select title_hr from public.conversations where id = {q(D.RENAME_CONV[0])}) <> {q(D.RENAME_CONV[1][1])} then
    raise exception 'Діалог уроку 26 не перейменовано';
  end if;
  raise notice 'Готово: 20261117_a0_dupes_1_lessons.sql — урок «В аптеці» (69), уроки 30, 58, 64, 68, 70 без дублів, {nlex} нових слів, уроків A0 — {NEW_TOTAL}';
end $$;
"""


def build(c: CourseDupes) -> str:
    head = f"""-- =====================================================================
-- Дублі A0 · 2026-11-17 (план «Дублі й сенс уроків A0–A2», PR 2б)
-- Згенеровано: python3 -B scripts/gen_a0_dupes.py (не редагуйте вручну).
--
-- Рішення власника 2026-11-17: Д12 (варіант Б) — урок 68 «У лікаря й в аптеці» → «У лікаря» (68) і новий «В аптеці» (69);
-- Д4 (урок 64), Д9 (58), Д10 (30), Д11 (69 → 70); назва діалогу уроку 26. Уроків A0 {OLD_TOTAL} → {NEW_TOTAL}.
--   * Нові слова: {len(NEW)} (з мітками), наявні — {len(D.EXISTING)} (рівень → A0). Прибрані з A0 слова, які вчать в A1 ({len(to_a1_words())}), —
--     рівень A1 (A1-24, A1-96, A1-97); kabina, probati, pristajati — в A1-24 (там їх ще не було).
--   * Слово в уроці — заміна на тому самому місці; вправи на прибрані слова й діалоги — нові на тому самому місці.
--   * Нічого не видаляється: старі діалоги й вправи → DEPRECATED; копія складу уроків — backup.lesson_items_a0dupes_20261117;
--     старі версії уроків і діалогу — у content_versions. Прогрес користувачів не змінюється.
--   * Далі за назвою: 20261117_a0_dupes_2_reading.sql (тексти A0.6), 20261117_a0_dupes_3_tests.sql (перевірки).
--   * Повторний запуск нічого не змінює. Бета: PUBLISHED.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: 20261117_a0_dupes_1_lessons.sql — …».
-- =====================================================================

begin;
"""
    out = [head, backup_sql(), HELPERS_SQL, HELPER_TASK]
    out += lexemes_sql()
    out.append(cefr_sql(D.EXISTING, 'A0', 'a0_dupes: рівень слова A0 — його вперше вчать в уроці A0 — стара версія',
                        f'1а. Наявні слова, які вперше вчать в уроках A0 ({len(D.EXISTING)}): рівень слова — A0'))
    out.append(cefr_sql(to_a1_words(), 'A1', 'a0_dupes: рівень слова A1 — в уроках A0 його більше немає, його вчать в A1 — стара версія',
                        f'1б. Прибрані з уроків A0 слова, які вчать в A1 ({len(to_a1_words())}; kabina, probati, pristajati — тепер в A1-24): рівень — A1'))
    out += new_lesson_sql(c)
    for n in (30, 58, 64, 68, 69):
        out += change_sql(n)
    out.append(a1_24_sql())
    out.append(rename_sql())
    out.append(RENUMBER_SQL)
    out.append(selfcheck_sql())
    out.append('commit;\n')
    return '\n'.join(out)


# ----------------------------------------------------------------------------- SQL: пакет 2 (тексти)
def reading_known() -> set[str]:
    import reading_lexicon as X  # noqa: PLC0415
    a0 = {w.lower() for L in SNAPSHOT['a0'] for w, _ in L['words']}
    a0 -= {o.lower() for n in D.CHANGES for o, _ in D.CHANGES[n].get('swap', []) if o not in D.PHARMACY['moved']}
    a0 |= set(NEW) | {w.lower() for w in D.EXISTING}
    return a0 | {k.lower() for k in X.KNOWN}


WORD = re.compile(r"[A-Za-zČĆĐŠŽčćđšžÀ-ž]+(?:-[A-Za-zČĆĐŠŽčćđšžÀ-ž]+)*")


def reading_rows() -> tuple[list[dict], list[str]]:
    errors = []
    known = reading_known()
    a0_a1 = {k for k, v in TAKEN.items() if v.startswith(('A0 ', 'A1 '))} | set(NEW) | {w.lower() for w in D.EXISTING}
    rows = []
    for i, t in enumerate(D.READING, 21):
        toks = [w.lower() for w in WORD.findall(t['body_hr'])]
        gl = {g[0]: g for g in t['gloss']}
        for tok in toks:
            if tok not in gl:
                errors.append(f"{t['code']}: «{tok}» немає в словничку")
        for form in gl:
            if form not in toks:
                errors.append(f"{t['code']}: «{form}» у словничку, але не в тексті")
        entries, n_known = [], 0
        for tok in toks:
            lemma = gl[tok][1] if tok in gl else tok
            n_known += lemma.lower() in known
        order = []
        for tok in toks:
            if tok in gl and tok not in order:
                order.append(tok)
        for form in order:
            f, lemma, pos, gram, ua = gl[form]
            e = {'form': f, 'lemma': lemma, 'ua': ua, 'lesson': lemma.lower() in a0_a1, 'pos': pos}
            if gram:
                e['gram'] = gram
            if not ua or not CYR.search(ua) or not CYR.search(pos):
                errors.append(f"{t['code']}: «{form}» без перекладу чи частини мови")
            if not gram and form != lemma.lower():
                errors.append(f"{t['code']}: «{form}» ≠ лема — потрібна граматична підказка")
            entries.append(e)
        ratio = n_known / len(toks)
        if ratio < 0.8:
            errors.append(f"{t['code']}: знайомих слів {ratio:.0%} (має бути ≥ 80 %)")
        if t['type'] not in ('sign', 'notice', 'ad', 'message') or t['situation'] not in SITUATIONS:
            errors.append(f"{t['code']}: тип чи ситуація")
        if CYR.search(t['body_hr']) or not CYR.search(t['body_ua']) or len(t['body_hr']) < 20:
            errors.append(f"{t['code']}: мова тексту")
        qs = []
        for qu, ans, opts in t['questions']:
            if ans not in opts or len(set(opts)) != 3:
                errors.append(f"{t['code']}: питання «{qu}» — 3 різні варіанти з правильним")
            qs.append({'question_ua': qu, 'options': opts, 'answer': ans})
        if len(qs) != 3:
            errors.append(f"{t['code']}: потрібно 3 питання")
        rows.append(dict(code=t['code'], type=t['type'], situation=t['situation'], title=t['title'], body_hr=t['body_hr'],
                         body_ua=t['body_ua'], glossary=entries, questions=qs, word_count=len(toks), known_ratio=ratio, order=i))
    return rows, errors


def reading_sql() -> str:
    rows, errors = reading_rows()
    if errors:
        raise SystemExit('ПОМИЛКИ (тексти):\n  ' + '\n  '.join(errors))
    codes = ', '.join(q(r['code']) for r in rows)
    out = [f"""-- =====================================================================
-- Тексти для читання модуля A0.6 «Kućni ljubimci» · 2026-11-17 (план «Дублі й сенс уроків», PR 2б)
-- Згенеровано: python3 -B scripts/gen_a0_dupes.py (не редагуйте вручну).
--
--   * {len(rows)} тексти ({rows[0]['code']}, {rows[-1]['code']}): табличка в парку для собак і оголошення про загублену кішку.
--   * У кожного: переклад, словничок «слово → лема → переклад» з граматичною підказкою, 3 питання, частка знайомих слів
--     з уроків A0 (known_ratio). Бета: PUBLISHED. Повторний запуск безпечний (наявні коди не перезаписуються).
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника (після 20261117_a0_dupes_1_lessons.sql).
-- Очікуване повідомлення: «Готово: 20261117_a0_dupes_2_reading.sql — текстів A0.6: 2».
-- =====================================================================

begin;
"""]
    for r in rows:
        ua_title, hr_title = r['title']
        out.append(
            'insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)\n'
            f"values ({q(r['code'])}, 'A0', {q(r['type'])}, {q(r['situation'])}, 6, {q(ua_title)}, {q(hr_title)},\n"
            f"        {q(r['body_hr'])},\n        {q(r['body_ua'])},\n"
            f"        {qj(r['glossary'])},\n        {qj(r['questions'])}, {r['word_count']}, {r['known_ratio']:.3f}, {r['order']}, {q(STATUS)}, {q(SOURCE)})\n"
            'on conflict (code) do nothing;\n')
    out.append(f"""-- Журнал перевірки (один запис на текст)
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'reading_text', r.id, null, r.status, 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE_READING)}
  from public.reading_texts r
 where r.source = {q(SOURCE)} and r.code in ({codes})
   and not exists (select 1 from public.content_reviews c where c.entity_id = r.id and c.notes = {q(NOTE_READING)});

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_total int; v_bad int;
begin
  select count(*) into v_total from public.reading_texts where cefr = 'A0' and module_order = 6 and status = 'PUBLISHED' and code in ({codes});
  select count(*) into v_bad from public.reading_texts r where r.code in ({codes})
     and (jsonb_array_length(r.questions) <> 3 or r.known_ratio < 0.8
          or exists (select 1 from jsonb_array_elements(r.glossary) e
                     where e->>'pos' is null or (e->>'gram' is null and e->>'form' <> lower(e->>'lemma'))));
  if v_total <> {len(rows)} then raise exception 'Текстів A0.6: % (очікувалось {len(rows)})', v_total; end if;
  if v_bad > 0 then raise exception '% текстів без питань, словничка чи граматичних підказок', v_bad; end if;
  raise notice 'Готово: 20261117_a0_dupes_2_reading.sql — текстів A0.6: %', v_total;
end $$;

commit;
""")
    return '\n'.join(out)


# ----------------------------------------------------------------------------- звіт для носія
def review(c: CourseDupes) -> str:
    out = ['# Дублі A0 (план «Дублі й сенс уроків», PR 2б) — для носія мови (2026-11-17)', '',
           'Згенеровано: `python3 -B scripts/gen_a0_dupes.py --review`. Бета (опубліковано одразу). Позначте рядок і напишіть, як краще.', '',
           '## Що варто глянути носію', '',
           '1. **Нові вирази**: *hvala na čestitki*, *zaželjeti želju* («Zaželi želju!»), *poželjeti*, *ostati u krevetu*, '
           '*sve zajedno*, *tablete za grlo*, *automat za karte* («kupiti kartu na automatu») — чи природно.',
           '2. **Аптека**: *ljekarnica* (фармацевтка) — чи кажуть так у розмові; табличка «Noću pozvonite na zvono» на черговій аптеці.',
           '3. **Регістр**: «Dobra večer» (ж. р., норма) у діалогах; «Jest, izvolite sjesti» — відповідь «так» на «Je li ovo mjesto slobodno?».',
           '4. **Тексти A0.6**: «Opasni psi – samo s brnjicom», «Ako je vidite, javite se!» — чи так пишуть на табличках і оголошеннях.',
           '5. **Вид**: *obući* (pfv; пара — *oblačiti*), *poželjeti* (pfv; пара — *željeti*).', '']
    for n in (30, 58, 64, 68, 69):
        ch = D.CHANGES[n]
        out += [f'## Урок {n if n != 69 else 70} — {ch["note"]}', '']
        if ch.get('swap'):
            out += ['| Було | Стало | Переклад |', '|---|---|---|']
            out += [f'| *{o}* | *{w}* | {LEX[w.lower()][1]} |' for o, w in ch['swap']]
            out.append('')
        if ch.get('add'):
            out += [f'Додано: *{w}* — {LEX[w.lower()][1]}' for w in ch['add']] + ['']
        if 'conv' in ch:
            old, (s_ua, s_hr, sit, turns) = ch['conv']
            was = f' (замість «{CONVS[old]["title_hr"]}»)' if old else ' (замість «U ljekarni», що перейшов в урок «В аптеці»)'
            out += [f'**Новий діалог: {s_hr}** ({s_ua}){was}', ''] + [f'- **{sp}:** {hr} — {ua}' for sp, hr, ua in turns] + ['']
        if ch.get('ex'):
            out += ['**Нові вправи (на місці старих)**', '', '| Тип | Завдання | Відповідь |', '|---|---|---|']
            for _old, ex in ch['ex']:
                if ex['type'] in ('write_message', 'mediation'):
                    spec = ex.get('write') or ex.get('mediation')
                    out.append(f"| {ex['type']} | {spec.get('situation') or spec['source'].replace(chr(10), ' / ')} | {spec['models'][0]} |")
                else:
                    out.append(f"| {ex['type']} | {ex['question']} | {ex['answer']} |")
            out.append('')
    newlex = {r['lemma'].lower(): r for r in new_lexemes()}
    out += ['## Нові слова', '', '| Слово | Переклад | Рід / вид | Приклад |', '|---|---|---|---|']
    for r in newlex.values():
        f = r['forms']
        fv = f.get('gender') or (f.get('aspect', '') + (f' / {f["pair"]}' if f.get('pair') else ''))
        out.append(f"| *{r['lemma']}* | {r['ukrainian_translation']} | {fv} | {r['examples'][0]} |")
    L = c.lessons[PH_KEY]
    out += ['', '## Новий урок 69 «В аптеці» (U ljekarni)', '', f'Граматика: {L["grammar"]}. Слова: ' + ', '.join(f'*{w}*' for w in L['words']), '']
    for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1):
        out += [f'**Діалог {si}: {s_hr}** ({s_ua}){" — з уроку 68" if si == 1 else ""}', ''] + [f'- **{sp}:** {hr} — {ua}' for sp, hr, ua in turns] + ['']
    out += ['**Вправи**', '', '| Тип | Завдання | Відповідь | Варіанти |', '|---|---|---|---|']
    for ex in c.lesson_exercises(PH_KEY):
        opts = ' · '.join(ex['options']) if ex['options'] and ex['type'] not in ('sentence_builder', 'listening') else ''
        out.append(f"| {ex['type']} | {ex['question']} | {ex['answer']} | {opts} |")
    out.append('')
    out.append(GW.review('a0_dupes', pharmacy_writing()).split('\n', 6)[-1])
    rows, _ = reading_rows()
    out += ['', '## Тексти для читання A0.6', '']
    for r in rows:
        out += [f"**{r['code']} · {r['title'][1]}** ({r['title'][0]}) — знайомих {r['known_ratio']:.0%}", '', '```', r['body_hr'], '```', '',
                r['body_ua'].replace('\n', ' / '), '']
        out += [f"- {x['question_ua']} → {x['answer']} ({' · '.join(x['options'])})" for x in r['questions']] + ['']
    return '\n'.join(out) + '\n'


# ----------------------------------------------------------------------------- перевірки (пакет 3)
ASSESS_SNAPSHOT = HERE / 'assessment_a0_dupes_snapshot.json'
ASSESS_SLUGS = ('a0-m09', 'a0-m11', 'a0-final')
ASSESS_NOTE = ('Бета: перевірки рівня A0 за схемою 2026-11-07 після плану «Дублі й сенс уроків» (PR 2б, рішення власника 2026-11-17): '
               '{what}. Завдання — з діалогів, вправ і текстів уроків. Потрібна перевірка носієм.')
ASSESS_WHAT = {'a0-m09': 'тест модуля A0.9 наново (урок 58 — новий діалог)',
               'a0-m11': 'тест модуля A0.11 наново (8 уроків з новим «В аптеці»)',
               'a0-final': 'фінал A0 наново з усіх 11 модулів (з A0.6 «Kućni ljubimci»)'}


def assessments_main():
    import gen_assessment_a0_a1_v5 as V5   # noqa: PLC0415
    import gen_assessment as A              # noqa: PLC0415
    snap = json.loads(ASSESS_SNAPSHOT.read_text(encoding='utf-8'))
    a0 = snap['level']
    orders = [m['order'] for m in a0['modules']]
    m11 = next(m for m in a0['modules'] if m['order'] == 11)
    if orders != list(range(1, 12)) or len(m11['lessons']) != 8 or not any(r['code'] == 'RD-A0-021' for m in a0['modules'] for r in m['reading']):
        raise SystemExit('Знімок перевірок — не після пакетів 20261117_a0_dupes_1/2')
    V5.LEVEL_DATA['A0'] = a0
    V5._CACHE.clear()
    split = V5.split

    def texts_of(items) -> set[str]:
        out: set[str] = set()
        for it in items:
            fields = [it.get('audio_hr'), it.get('answer_text'), it.get('prompt_hr')]
            fields += [line.split(': ', 1)[-1] for line in (it.get('passage_hr') or '').split('\n')]
            fields += [o for o in (it.get('options') or []) if isinstance(o, str)]
            out |= set(split([f for f in fields if f]))
        return out

    keep = snap['items']                                    # опубліковані завдання тестів A0, які не змінюються
    mid_seen = texts_of(keep['a0-mid'])
    _pools = A.Pools

    def pruned(seen):
        class PrunedPools(_pools):
            def __init__(self, data):
                super().__init__(data)
                V5.prune(self, seen)
        return PrunedPools

    VER = 'v5dupes'
    tests = []
    A.Pools = pruned(mid_seen)
    for m in (9, 11):
        slug = f'a0-m{m:02d}'
        items, plan = V5.module_test('A0', m)
        A.PLAN[slug] = plan
        for i, it in enumerate(items, 1):
            it['module'] = m
            it['order'] = i
            it['id'] = A.uid('assessment', slug, VER, 'item', i)
        tests.append({'slug': slug, 'kind': slug, 'db_kind': 'module', 'module': m, 'title_ua': f'Перевірка модуля A0.{m}', 'items': items})
    A.Pools = _pools
    # фінал: без джерел і речень тестів модулів (наявних і нових) і середини
    seen = mid_seen | texts_of(it for slug, its in keep.items() if slug != 'a0-mid' for it in its)
    seen |= {x for t in tests for it in t['items'] for x in V5.shown(it)}
    # і дослівно (тести SQL: репліка / відповідь фіналу ≠ репліці, відповіді чи питанню тестів модулів і середини — навіть коротка)
    exact: set[str] = set()
    for its in list(keep.values()) + [t['items'] for t in tests]:
        for it in its:
            exact |= {x.lower() for x in (it.get('audio_hr'), it.get('answer_text'), it.get('prompt_hr')) if x}

    def exact_ok(items) -> bool:
        return all((it.get('audio_hr') or it.get('answer_text') or '').lower() not in exact for it in items)

    def final_ok(items) -> bool:
        """Пройде A.finalize (хибні варіанти не повторюються, немає двох завдань з тією самою відповіддю)."""
        trial = {'slug': 'a0-final', 'kind': 'a0-final', 'db_kind': 'final', 'module': None, 'upto': 11,
                 'items': [dict(it, options=list(it['options']), order=i) for i, it in enumerate(json.loads(json.dumps(items)), 1)]}
        try:
            A.finalize([trial], 'A0')
        except SystemExit:
            return False
        return True

    slug = 'a0-final'
    A.PLAN[slug] = V5.LEVEL_PLANS['final']
    pools = A.Pools(V5.level('A0', 11))
    V5.prune(pools, seen)
    mods = sorted(pools.by_module)
    best = None
    for attempt in range(120):
        try:
            items = V5.fill_balanced(pools, set(), V5.LEVEL_PLANS['final'], mods, slug, seed=slug if attempt == 0 else f'{slug}:{attempt}')
        except SystemExit:
            continue
        from collections import Counter  # noqa: PLC0415
        per = Counter(it['module'] for it in items)
        hard, soft = V5.clashes(items)
        if all(per[m] >= 2 for m in mods) and hard == 0 and exact_ok(items) and final_ok(items) and (best is None or soft < best[0]):
            best = (soft, items)
            if soft == 0:
                break
    if best is None:
        raise SystemExit('a0-final: не вдалося покрити всі модулі без повторів')
    items = best[1]
    for i, it in enumerate(items, 1):
        it['order'] = i
        it['id'] = A.uid('assessment', slug, VER, 'item', i)
    tests.append({'slug': slug, 'kind': slug, 'db_kind': 'final', 'module': None, 'upto': 11, 'title_ua': 'Фінальна перевірка рівня A0',
                  'items': items})
    tests = V5.with_alternatives(A.finalize(tests, 'A0'))
    problems = []
    for t in tests:
        want = V5.n_items('A0', t['module']) if t['db_kind'] == 'module' else 48
        if len(t['items']) != want:
            problems.append(f"{t['slug']}: {len(t['items'])} завдань, а за схемою {want}")
        if t['db_kind'] == 'module' and any(it['lesson'] and it['module'] != t['module'] for it in t['items']):
            problems.append(f"{t['slug']}: завдання з іншого модуля")
    from collections import Counter  # noqa: PLC0415
    per = Counter(it['module'] for it in tests[-1]['items'])
    if any(per[m] < 2 for m in range(1, 12)):
        problems.append(f'a0-final: модулі з < 2 завдань: {[m for m in range(1, 12) if per[m] < 2]}')
    problems += V5.check_alternatives(it['answer_text'] for t in tests for it in t['items'] if it['item_type'] == 'sentence_builder')
    if problems:
        raise SystemExit('Перевірка не пройдена:\n' + '\n'.join(problems))
    if '--check' in sys.argv:
        for t in tests:
            print(t['slug'], len(t['items']), dict(Counter(it['module'] for it in t['items'])))
        return tests
    OUT_ASSESS.write_text(assess_sql(V5, A, tests, a0), encoding='utf-8')
    print(f'{OUT_ASSESS.relative_to(ROOT)}: {len(OUT_ASSESS.read_bytes()) // 1024} КБ')
    return tests


def assess_sql(V5, A, tests, a0) -> str:
    blocks = []
    for t in tests:
        desc, minutes = V5.description('A0', t)
        rows = ',\n'.join(V5.item_row('A0', it) for it in t['items'])
        mod = next((m for m in a0['modules'] if m['order'] == t['module']), None)
        mod_check = (f"""  if (select module_id from public.assessments where id = v_aid) is distinct from {q(mod['id'])}::uuid then
    raise exception 'Тест {t['slug']} прив’язаний не до модуля A0.{t['module']} — звірте базу';
  end if;
""" if mod else '')
        blocks.append(f"""-- {t['title_ua']} · {len(t['items'])} завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = {q(t['slug'])} and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту {t['slug']} — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = {q(t['items'][0]['id'])}) then return; end if;  -- уже оновлено
{mod_check}  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'a0_dupes: перевірку оновлено після плану «Дублі й сенс уроків» (PR 2б) — старі завдання');
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = {q(desc)}, estimated_minutes = {minutes} where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
{rows};
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, {q(ASSESS_NOTE.format(what=ASSESS_WHAT[t['slug']]))});
end $$;
""")
    ids = ', '.join(q(it['id']) for t in tests for it in t['items'])
    total = sum(len(t['items']) for t in tests)
    expected = ', '.join(f"({q(t['slug'])}, {len(t['items'])})" for t in tests)
    sizes = ', '.join(f"{t['slug']} — {len(t['items'])}" for t in tests)
    return f"""-- =====================================================================
-- Перевірки рівня A0 після плану «Дублі й сенс уроків» (PR 2б) · 2026-11-17
-- Згенеровано: python3 -B scripts/gen_a0_dupes.py assessments (не редагуйте вручну).
--
-- Запускати після 20261117_a0_dupes_1_lessons.sql і _2_reading.sql (назва файлу стоїть після них — «Apply SQL» запускає за назвою).
-- Схема 2026-11-07: модуль — 2 завдання на урок (12–20), фінал — 48 (кожен модуль — щонайменше 2). У файлі {total} нових завдань:
--   {sizes}.
--   * a0-m09 — наново (одне завдання було з діалогу «U trgovini odjećom», який замінено); a0-m11 — 8 уроків з новим «В аптеці»;
--   * a0-final — наново з усіх 11 модулів (з A0.6 «Kućni ljubimci» і новими текстами A0.6), без джерел і речень тестів модулів
--     і середини. Середина (a0-mid) і решта тестів модулів не змінюються.
--   * Завдання — з діалогів, вправ і текстів уроків; нових хорватських речень немає. Старі завдання — у content_versions і DEPRECATED.
--   * Спроби й результати користувачів не змінюються. Повторний запуск нічого не змінює.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: 20261117_a0_dupes_3_tests.sql — 3 тести, {total} нових завдань».
-- =====================================================================

begin;

{chr(10).join(blocks)}
-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ({ids}) and status = 'PUBLISHED';
  select count(*) into v_bad from (values {expected}) e(slug, n) left join public.assessments a on a.slug = e.slug and a.cefr = 'A0' and a.status = 'PUBLISHED'
   where a.id is null
      or (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> e.n
      or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ({ids}));
  if v_new <> {total} or v_bad > 0 then raise exception 'Перевірки A0: нових завдань % (очікувалось {total}), тестів з помилкою %', v_new, v_bad; end if;
  if (select count(distinct m.order_index) from public.assessment_items i join public.assessments a on a.id = i.assessment_id
        join public.lessons l on l.id = i.lesson_id join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
       where a.slug = 'a0-final' and a.cefr = 'A0' and i.status = 'PUBLISHED') <> 11 then
    raise exception 'a0-final: завдання не з усіх 11 модулів';
  end if;
  raise notice 'Готово: 20261117_a0_dupes_3_tests.sql — 3 тести, % нових завдань', v_new;
end $$;

commit;
"""


# -----------------------------------------------------------------------------
def main():
    if 'assessments' in sys.argv:
        assessments_main()
        return
    errors, warnings = validate()
    _rows, rerr = reading_rows()
    errors += rerr
    if errors:
        raise SystemExit('ПОМИЛКИ:\n  ' + '\n  '.join(errors))
    for w in warnings:
        print('попередження:', w)
    c = build_course()
    if '--check' in sys.argv:
        print('OK: нових слів', len(NEW), '; слів у «В аптеці»', len(c.lessons[PH_KEY]['words']))
        for r in _rows:
            print(r['code'], f"{r['known_ratio']:.3f}", r['word_count'])
        return
    if '--review' in sys.argv:
        REVIEW_OUT.write_text(review(c), encoding='utf-8')
        print(f'OK → {REVIEW_OUT.relative_to(ROOT)}')
        return
    sql = build(c)
    OUT.write_text(sql, encoding='utf-8')
    OUT_READING.write_text(reading_sql(), encoding='utf-8')
    print(f'OK → {OUT.relative_to(ROOT)}: {len(sql.encode()) // 1024} КБ; нових слів {len(NEW)}; {OUT_READING.relative_to(ROOT)}')


if __name__ == '__main__':
    main()
