#!/usr/bin/env python3
"""
Дублі A1 · 2026-11-17 — план docs/proposals/2026-11-16_lesson_duplicates.md, PR 3 (рішення власника 2026-11-17).

  python3 -B scripts/gen_a1_dupes.py               →  supabase/data_fixes/20261117_a1_dupes_1_lessons.sql
  python3 -B scripts/gen_a1_dupes.py --check       →  лише перевірка даних (нічого не пише)
  python3 -B scripts/gen_a1_dupes.py --review      →  content/reviews/2026-11-17_a1_dupes.md (для носія)
  python3 -B scripts/gen_a1_dupes.py assessments   →  supabase/data_fixes/20261117_a1_dupes_2_tests.sql
                                                       (знімок після пакета 1 — scripts/assessment_a1_dupes_snapshot.json)

Дані — scripts/curriculum_a1_dupes_data.py. Знімок — scripts/curriculum_a1_dupes_snapshot.json (запит — scripts/a1_dupes_source.sql).

Пакет 1 (уроки):
  1. нові слова (з мітками; PUBLISHED — бета); наявні слова без уроку й слова A2-9, які тепер учать в A1, — рівень A1;
     прибрані з A1 слова, які тепер учать лише в A2, — рівень A2 (стара версія — content_versions);
  2. 3 нові уроки модуля A1.11 «Хорватська культура» (місця 6–8): «Символи й винаходи», «Фестивалі й карнавали»,
     «Казки й легенди» — по 22–23 слова, 2 діалоги, 15 вправ;
  3. уроки 54, 70, 93, 101: слова — заміна на тому самому місці (Д3, Д12, Д13, Д2), діалог — новий замість старого
     (старий — DEPRECATED), вправи на прибрані слова й діалоги — нові на тому самому місці (старі — DEPRECATED);
  4. svjedodžba → A2-11, porez і platna lista → A2-34 (слово не зникає з курсу);
  5. урок 105 «Надзвичайні ситуації» → модуль A1.8 «Здоров’я», місце 11;
  6. нові назви 9 діалогів з однаковими назвами (у пізнішому уроці);
  7. наскрізні номери всіх уроків A1 (108 → 111), порядок діалогів v3 за новим номером.
  Копії — backup.lesson_items_a1dupes_20261117; старі версії уроків і діалогів — у content_versions.
Пакет 2 (перевірки): a1-m06 (урок 54), a1-m08 (+ урок 105, урок 70), a1-m11 (8 уроків), a1-m12 (7 уроків, урок 101),
фінал a1-final — наново (одне завдання було на прибране слово). Середина (a1-mid) і решта тестів модулів не змінюються.
Повторний запуск кожного пакета нічого не змінює.
"""
from __future__ import annotations

import json
import re
import sys
from collections import Counter
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE))
import curriculum_a1_dupes_data as D  # noqa: E402
from full_lessons import CYR, HELPERS_SQL, Place, fold_ua, q, qj, shuffled, uid  # noqa: E402
from gen_curriculum_a1_v3 import CourseA1  # noqa: E402
from lexeme_checks import check_batch, normalize  # noqa: E402

ROOT = HERE.resolve().parent
FIXES = ROOT / 'supabase' / 'data_fixes'
REVIEWS = ROOT / 'content' / 'reviews'
SNAPSHOT = json.loads((HERE / 'curriculum_a1_dupes_snapshot.json').read_text(encoding='utf-8'))
OUT = FIXES / '20261117_a1_dupes_1_lessons.sql'
OUT_ASSESS = FIXES / '20261117_a1_dupes_2_tests.sql'
REVIEW_OUT = REVIEWS / '2026-11-17_a1_dupes.md'
LEVEL = 'A1'
MOD = 11                    # «Хорватська культура»
STATUS = 'PUBLISHED'        # бета (A1 — рішення власника 2026-10-21)
SOURCE = 'claude_curriculum_a1_dupes'
MINUTES = 15
OLD_TOTAL, NEW_TOTAL = 108, 111
SITUATIONS = set(re.findall(r"code: '([a-z_]+)'", (ROOT / 'lib' / 'situations.ts').read_text(encoding='utf-8')))
POS = {'n': 'noun', 'v': 'verb', 'adj': 'adjective', 'adv': 'adverb', 'ph': 'phrase', 'prep': 'preposition', 'int': 'interjection'}
GRAMMAR_A1 = {'Побудова питань', 'Орудний відмінок: autobusom, s prijateljem', 'Минулий час: radio sam, bila sam'}
NOTE_LESSON = ('a1_dupes 20261117: план «Дублі й сенс уроків» (PR 3, рішення власника 2026-11-17) — {what}. '
               'Бета, потрібна перевірка носієм.')
NOTE_NEW = ('Бета: новий урок модуля A1.11 «Хорватська культура» (рішення власника 2026-11-17: «Символи й винаходи», '
            '«Фестивалі й карнавали», «Казки й легенди» — «окей») за схемою уроків за темою (20–25 слів, 2 діалоги, 15 вправ). '
            'Потрібна перевірка носієм.')

ITEMS = SNAPSHOT['items']
CONVS = {c['id']: c for c in SNAPSHOT['conversations']}
TAKEN = SNAPSHOT['lessons']        # lower(лема) → перший урок (усі рівні)
A1 = SNAPSHOT['a1']
BY_ID = {L['id']: L for L in A1}


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
        for v in vocab:
            lemma, ua, pos, forms, example = v[:5]
            tags = list(v[5]) if len(v) > 5 else []
            p = POS[pos]
            rows.append(dict(lemma=lemma, normalized=normalize(lemma), ukrainian_translation=ua, part_of_speech=p, cefr=LEVEL,
                             vocabulary_type=vtype_of(p, lemma), forms=forms_of(forms), examples=[example],
                             register='standard', regionality='general', usage_tags=tags,
                             ukrainian_interference=D.INTERFERENCE.get(lemma),
                             **({'proper_noun': True} if lemma[:1].isupper() else {})))
    return rows


NEW = {r['lemma'].lower(): r for r in new_lexemes()}


def lex_map() -> dict:
    lex = {}
    for L in A1:
        for lemma, ua in L['words']:
            lex[lemma.lower()] = (lemma, ua)
    for lemma, (ua, _cefr) in D.EXISTING.items():
        lex[lemma.lower()] = (lemma, ua)
    for lemma, ua in D.FROM_A2_9.items():
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
    ch = D.CHANGES.get(n, {})
    swap = {o.lower(): w for o, w in ch.get('swap', [])}
    return [swap.get(w.lower(), w) for w in words_of(n)]


def removed_words() -> list[str]:
    return [o for n in sorted(D.CHANGES) for o, _ in D.CHANGES[n].get('swap', [])]


def scene_turns(n: int) -> list[str]:
    """Тексти діалогів уроку після змін (для перевірки «прослухайте»)."""
    ch = D.CHANGES[n]
    old = ch['conv'][0] if 'conv' in ch else None
    out = [' '.join(hr for _sp, hr, _ua in c['turns']) for c in SNAPSHOT['conversations']
           if c['lesson'] == D.LESSON_IDS[n] and c['id'] != old]
    if 'conv' in ch:
        out.append(' '.join(hr for _sp, hr, _ua in ch['conv'][1][3]))
    return out


def display_ua(word: str) -> str:
    t = LEX[word.lower()][1].strip().rstrip('.')
    if LEX[word.lower()][0][:1].islower():
        t = ' / '.join(seg if seg[1:2].isupper() else seg[:1].lower() + seg[1:] for seg in t.split(' / '))
    return t


# ----------------------------------------------------------------------------- нумерація після змін
def new_order() -> list[tuple]:
    """(модуль, ключ) у новому порядку: ключ — id наявного уроку або slug нового."""
    out = []
    for m in range(1, 14):
        keys = [L['id'] for L in A1 if L['module'] == m and L['id'] != D.LESSON_IDS[D.MOVE['lesson']]]
        if m == D.MOVE['to_module']:
            keys.append(D.LESSON_IDS[D.MOVE['lesson']])
        if m == MOD:
            keys += [N['slug'] for N in D.NEW_LESSONS]
        out += [(m, k) for k in keys]
    return out


ORDER = new_order()
NUMBER = {k: i for i, (_m, k) in enumerate(ORDER, 1)}
OLD_NUMBER = {L['id']: int(re.match(r'Урок (\d+):', L['title']).group(1)) for L in A1}


def new_lesson_id(slug: str) -> str:
    return uid('lesson_a1dupes', LEVEL, MOD, slug)


# ----------------------------------------------------------------------------- нові уроки A1.11
# Близькі слова, яких не ловить перетин перекладів: не ставимо їх хибним варіантом одне до одного
EXTRA_SYNONYMS = [{'жарт', 'жартувати'}, {'зло', 'злий'}, {'перевдягатися', 'перевдягнутися'}, {'розповідь', 'розповідати'},
                  {'винахід', 'винайти', 'винахідник'}, {'краватка', 'краватку'}]
# «Напишіть» / «як хорватською» лише з однією правильною відповіддю: junak — ще й heroj
NO_VOCAB = {'junak'}


class CourseA1Dupes(CourseA1):
    def too_close(self, a: str, b: str) -> bool:
        if super().too_close(a, b):
            return True
        ta, tb = self.ua_tokens(a), self.ua_tokens(b)
        return any(ta & g and tb & g for g in EXTRA_SYNONYMS)

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
        for x in words:
            if x.lower() not in self.lex:
                self.errors.append(f'{w}: слова «{x}» немає ні в знімку, ні серед нових')
        if len(L['scenes']) != 2:
            self.errors.append(f'{w}: потрібні 2 діалоги')
        texts = []
        for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1):
            self.check_ua(s_ua, f'{w}.scene{si}')
            self.check_hr(s_hr, f'{w}.scene{si}')
            if len(turns) != 6:
                self.errors.append(f'{w}.scene{si}: {len(turns)} реплік (має бути 6: аудит — щонайменше 6, діалоги A1 v3 — 4–6)')
            for sp, hr, ua in turns:
                self.check_hr(sp, f'{w}.scene{si}.speaker')
                self.check_hr(hr, f'{w}.scene{si}.turn')
                self.check_ua(ua, f'{w}.scene{si}.turn')
                if hr != hr.strip() or '  ' in hr:
                    self.errors.append(f'{w}.scene{si}: пробіли в {hr!r}')
            texts.append(' '.join(hr for _, hr, _ in turns))
        question, answer, wrong = L['fill']
        if '___' not in question or len({answer, *wrong}) != 4:
            self.errors.append(f'{w}.fill: пропуск і 4 різні варіанти')
        for hint, sentence in L['build']:
            self.check_ua(hint, w + '.build')
            self.tokens(sentence, w + '.build')
            if len(sentence.split(' ')) < 3:
                self.errors.append(f'{w}.build: «складіть» — щонайменше 3 слова')
        for li, sentence in enumerate(L['listen']):
            self.tokens(sentence, w + '.listen')
            if sentence not in texts[li]:
                self.errors.append(f'{w}: «прослухайте» {li + 1} не з діалогу {li + 1}: {sentence!r}')
        for ua, hr in L['speak']:
            self.check_ua(ua, w + '.speak')
            self.check_hr(hr, w + '.speak')


def new_lessons() -> dict:
    return {(MOD, N['order']): dict(title=N['title'], situation=N['situation'], grammar=N['grammar'], objectives=N['objectives'],
                                    words=N['words'], scenes=N['scenes'], fill=N['fill'], build=N['build'], listen=N['listen'],
                                    speak=N['speak'])
            for N in D.NEW_LESSONS}


def build_course() -> CourseA1Dupes:
    pool = [w for L in A1 for w, _ua in L['words']]
    module_words = [w for L in A1 if L['module'] == MOD for w in words_after_id(L['id'])]
    place = {(MOD, N['order']): Place(MOD, N['order'], NUMBER[N['slug']]) for N in D.NEW_LESSONS}
    return CourseA1Dupes(level=LEVEL, lessons=new_lessons(), place=place, lex=LEX, situations=SITUATIONS, grammar_keys=GRAMMAR_A1,
                         seed_prefix='a1dupes', no_vocab=NO_VOCAB, extra_pool=pool, extra_module_words={MOD: module_words}, words_range=(20, 25),
                         vocab_counts=(3, 2, 3))


def words_after_id(lid: str) -> list[str]:
    for n, x in D.LESSON_IDS.items():
        if x == lid and n in D.CHANGES:
            return words_after(n)
    return [w for w, _ua in BY_ID[lid]['words']]


# ----------------------------------------------------------------------------- перевірка
def old_exercise(n: int, answer: str) -> dict | None:
    hits = [it for it in lesson_items(n) if it['type'] == 'exercise' and it['answer'] == answer]
    return hits[0] if len(hits) == 1 else None


def validate() -> tuple[list[str], list[str]]:
    errors: list[str] = []
    seen_new: dict[str, str] = {}
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
    for w in D.FROM_A2_9:
        if TAKEN.get(w.lower()) != 'A2 Урок 9':
            errors.append(f'«{w}» — не з уроку A2-9 ({TAKEN.get(w.lower())})')
    used = [w for n in D.CHANGES for _o, w in D.CHANGES[n].get('swap', [])] + [w for N in D.NEW_LESSONS for w in N['words']]
    for w in set(seen_new) | {x.lower() for x in D.EXISTING} | {x.lower() for x in D.FROM_A2_9}:
        if sum(1 for u in used if u.lower() == w) != 1:
            errors.append(f'слово «{w}» має бути рівно в одному уроці пакета')
    # слова, прибрані з A1: де їх учать далі
    removed = {w.lower() for w in removed_words()}
    if removed != {w.lower() for w in D.TO_A2} | {w.lower() for w in D.DICT_ONLY} | {'katedrala', 'zidine', 'tableta'}:
        errors.append(f'прибрані слова: не всі розписано (TO_A2 / DICT_ONLY): {sorted(removed)}')
    for w, where in D.TO_A2.items():
        n_where = int(where.split('-')[1])
        added = any(w in ws for _t, ws in D.A2_ADD.values())
        if not added and not TAKEN.get(w.lower(), '').startswith(('A2 Урок', 'A1 Урок')):
            errors.append(f'«{w}»: немає в уроці {where}')
        if not added and f'A2 Урок {n_where}' not in TAKEN.get(w.lower(), '') and TAKEN.get(w.lower(), '').startswith('A2'):
            errors.append(f'«{w}»: перший урок {TAKEN.get(w.lower())}, а не {where}')
    for lid, (_t, ws) in D.A2_ADD.items():
        cur = [it['lemma'].lower() for it in ITEMS if it['lesson'] == lid and it['type'] == 'lexeme']
        if not cur or len(cur) + len(ws) > 25 or any(w.lower() in cur for w in ws):
            errors.append(f'{_t}: забагато слів або слово вже є ({len(cur)})')
    for w in ('katedrala', 'zidine', 'tableta'):
        if not TAKEN.get(w, '').startswith('A0 '):
            errors.append(f'«{w}» має лишатися в уроці A0')
    # зміни уроків
    for n, ch in D.CHANGES.items():
        cur = [w.lower() for w in words_of(n)]
        for old, new in ch.get('swap', []):
            if old.lower() not in cur:
                errors.append(f'урок {n}: «{old}» немає серед слів')
            if new.lower() not in LEX:
                errors.append(f'урок {n}: «{new}» немає ні в знімку, ні серед нових')
        after = words_after(n)
        if len(after) != len(cur) or len({w.lower() for w in after}) != len(after):
            errors.append(f'урок {n}: слова повторюються після змін')
        if 'conv' in ch:
            old, (s_ua, s_hr, sit, turns) = ch['conv']
            if old not in CONVS or CONVS[old]['lesson'] != D.LESSON_IDS[n]:
                errors.append(f'урок {n}: діалогу {old} немає в уроці')
            if sit not in SITUATIONS or len(turns) != 6:
                errors.append(f'урок {n}: ситуація чи кількість реплік нового діалогу')
            if not CYR.search(s_ua) or CYR.search(s_hr):
                errors.append(f'урок {n}: мова назви діалогу')
            for sp, hr, ua in turns:
                if CYR.search(hr) or CYR.search(sp) or not CYR.search(ua) or hr != hr.strip() or '  ' in hr:
                    errors.append(f'урок {n}: репліка {hr!r}')
        texts = scene_turns(n)
        ua_of = {display_ua(w): w for w in after}
        hr_of = {w.lower() for w in after}
        replaced = set()
        for old_answer, ex in ch.get('ex', []):
            o = old_exercise(n, old_answer)
            where = f'урок {n}, вправа замість «{old_answer}»'
            if o is None:
                errors.append(f'{where}: стару вправу не знайдено (або їх кілька)')
                continue
            replaced.add(old_answer)
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
                if ex['question'] == o['question'] and ex['answer'] == o['answer'] and sorted(opts) == sorted(o['options'] or []):
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
            if 'word' in ex and ex['word'].lower() not in hr_of:
                errors.append(f'{where}: слово «{ex["word"]}» не з уроку')
        # не лишилося вправ на прибрані слова й діалоги; хибних варіантів з прибраних слів
        rem = {o.lower() for o, _ in ch.get('swap', [])}
        rem_ua = {fold_ua(LEX.get(o.lower(), (o, ''))[1]) for o, _ in ch.get('swap', []) if o.lower() in LEX}
        rem_ua |= {fold_ua(display_ua(o)) for o, _ in ch.get('swap', []) if o.lower() in LEX}
        old_conv = ch['conv'][0] if 'conv' in ch else None
        old_texts = ' '.join(hr for _s, hr, _u in CONVS[old_conv]['turns']) if old_conv else ''
        for it in lesson_items(n):
            if it['type'] != 'exercise' or it['answer'] in replaced:
                continue
            if it['lexeme'] and it['lexeme'].lower() in rem:
                errors.append(f'урок {n}: вправа на прибране «{it["lexeme"]}» лишилась: {it["question"]}')
            if it['ex_type'] in ('sentence_builder', 'listening', 'speaking'):
                low = it['answer'].lower()
                for r in rem:
                    if re.search(r'\b' + re.escape(r if len(r) <= 5 else r[:-2]), low):
                        errors.append(f'урок {n}: у вправі «{it["answer"]}» лишилось прибране «{r}»')
                if it['ex_type'] == 'listening' and old_conv and it['answer'] in old_texts:
                    errors.append(f'урок {n}: «прослухайте» з прибраного діалогу: {it["answer"]}')
            for opt in it['options'] or []:
                if isinstance(opt, str) and (opt.lower() in rem or fold_ua(opt) in rem_ua) and it['ex_type'] == 'multiple_choice':
                    errors.append(f'урок {n}: хибний варіант з прибраного слова «{opt}» у «{it["question"]}»')
    # назви діалогів
    titles_now = {c['title_hr'].lower() for c in SNAPSHOT['conversations']}
    new_titles = [t[2][1] for t in D.RENAME_CONVS.values()]
    for cid, (where, old_t, (t_ua, t_hr)) in D.RENAME_CONVS.items():
        c = CONVS.get(cid)
        if not c or c['title_hr'] != old_t:
            errors.append(f'діалог {where} «{old_t}»: немає в знімку')
        if not CYR.search(t_ua) or CYR.search(t_hr) or t_hr.lower() in titles_now or new_titles.count(t_hr) != 1:
            errors.append(f'діалог {where}: нова назва «{t_hr}»')
    # нові уроки
    c = build_course()
    for key in c.lessons:
        c.validate_lesson(key)
        c.lesson_exercises(key)
    errors += c.errors
    e, warnings = check_batch(new_lexemes(), existing=dict(TAKEN))
    errors += e
    if len(ORDER) != NEW_TOTAL:
        errors.append(f'уроків A1 після змін {len(ORDER)} (очікувалось {NEW_TOTAL})')
    return errors, warnings


# ----------------------------------------------------------------------------- SQL: пакет 1
HELPER_TASK = """-- слово уроку: заміна на тому самому місці (рядок lesson_items той самий — змінюється лише слово)
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
                                           p_options jsonb, p_lemma text) returns void language plpgsql as $f$
declare v_lex uuid; v_n int;
begin
  if p_lemma is not null then
    select id into v_lex from public.lexemes where lower(lemma) = lower(p_lemma) and status = 'PUBLISHED' order by created_at limit 1;
    if v_lex is null then raise exception 'Немає опублікованого слова «%»', p_lemma; end if;
  end if;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  select p_new, p_type, p_question, p_answer, p_options, e.level, e.order_index, 'PUBLISHED', v_lex
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
  insert into backup.lesson_items_a1dupes_20261117 select li.* from public.lesson_items li where li.lesson_id = p_lesson on conflict (id) do nothing;
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
create table if not exists backup.lesson_items_a1dupes_20261117 (like public.lesson_items including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'lesson_items_a1dupes_20261117_pkey') then
    alter table backup.lesson_items_a1dupes_20261117 add constraint lesson_items_a1dupes_20261117_pkey primary key (id);
  end if;
end $$;
revoke all on backup.lesson_items_a1dupes_20261117 from anon, authenticated;
"""


def lexemes_sql() -> list[str]:
    data = [dict(lemma=r['lemma'], normalized=r['normalized'], pos=r['part_of_speech'], ua=r['ukrainian_translation'],
                 vtype=r['vocabulary_type'], forms=r['forms'], examples=r['examples'], register=r['register'],
                 regionality=r['regionality'], usage_tags=r['usage_tags'], interference=r['ukrainian_interference'])
            for r in new_lexemes()]
    return [f'-- 1. Нові слова ({len(data)}): PUBLISHED (бета), з мітками; наявні в словнику не змінюються',
            'insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples,',
            '                            ukrainian_interference, register, regionality, usage_tags, status, source)',
            f"select t.lemma, t.normalized, 'hr', t.pos, {q(LEVEL)}, t.ua, t.vtype, t.forms, t.examples, t.interference,",
            f"       t.register, t.regionality, array(select jsonb_array_elements_text(t.usage_tags)), {q(STATUS)}, {q(SOURCE)}",
            f'  from jsonb_to_recordset({qj(data)})',
            '    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb, interference text,',
            '         register text, regionality text, usage_tags jsonb)',
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


def new_lessons_sql(c: CourseA1Dupes) -> list[str]:
    unit = D.UNITS[MOD]
    first = D.NEW_LESSONS[0]
    s = [f'-- 2. Нові уроки модуля A1.{MOD} (місця 6–8): ' + ', '.join(f'«{N["title"][0]}»' for N in D.NEW_LESSONS),
         'do $$', 'declare', f'  v_unit constant uuid := {q(unit)};', '  v_lesson uuid;', '  v_gid uuid;', '  v_cid uuid;', '  v_pos int;',
         'begin',
         f'  if exists (select 1 from public.lessons where id = {q(new_lesson_id(first["slug"]))}) then return; end if;  -- уже створено',
         f"  if (select count(*) from public.lessons where unit_id = v_unit and status = 'PUBLISHED') <> 5 then",
         f"    raise exception 'Модуль A1.{MOD}: очікувалось 5 уроків — звірте базу';", '  end if;']
    for N in D.NEW_LESSONS:
        key = (MOD, N['order'])
        L = c.lessons[key]
        t_ua, t_hr = L['title']
        n = NUMBER[N['slug']]
        lid = new_lesson_id(N['slug'])
        s += [f'  -- урок {n} «{t_ua}»: {len(L["words"])} слів, 2 діалоги, {len(c.lesson_exercises(key))} вправ',
              f'  v_lesson := {q(lid)};', '  v_pos := 0;',
              f"  select id into v_gid from public.grammar_topics where cefr = {q(LEVEL)} and title_ua = {q(L['grammar'])} and status = 'PUBLISHED' order by created_at limit 1;",
              f"  if v_gid is null then raise exception 'Немає теми граматики «{L['grammar']}»'; end if;",
              '  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)',
              f"  values (v_lesson, v_unit, {q(LEVEL)}, {q(f'Урок {n}: {t_ua}')}, {q(f'Lekcija {n}: {t_hr}')}, {qj(L['objectives'])}, {MINUTES}, {q(STATUS)}, {N['order']});"]
        for word in L['words']:
            s.append(f'  v_pos := pg_temp.word(v_lesson, {q(word)}, v_pos);')
        s += ['  v_pos := v_pos + 1;',
              "  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');",
              '  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;']
        for ei, ex in enumerate(c.lesson_exercises(key), 1):
            opts = qj(ex['options']) if ex['options'] is not None else 'null'
            lemma = q(ex['word']) if ex.get('word') else 'null'
            s.append(f"  v_pos := pg_temp.ex(v_lesson, v_pos, {q(uid('exercise_a1dupes', LEVEL, MOD, N['slug'], ei))}, {q(ex['type'])}, "
                     f"{q(ex['question'])}, {q(ex['answer'])}, {opts}, {q(LEVEL)}, {ei}, {q(STATUS)}, {lemma}, {q(ex['skill'])});")
        for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1):
            cid = uid('conversation_a1dupes', LEVEL, MOD, N['slug'], si)
            sit = L['situation'] if si == 1 else SCENE2_SITUATION[N['slug']]
            s += [f'  v_cid := {q(cid)};',
                  '  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)',
                  f"  values (v_cid, v_lesson, {q(s_ua)}, {q(s_hr)}, {3000 + n * 10 + si}, {q(LEVEL)}, {q(sit)}, {q(STATUS)}, 'claude_curriculum_a1_v3') on conflict (id) do nothing;"]
            for ti, (speaker, hr, ua) in enumerate(turns, 1):
                s.append(f"  perform pg_temp.turn({q(uid('turn_a1dupes', LEVEL, MOD, N['slug'], si, ti))}, v_cid, {q(speaker)}, {q(hr)}, {q(ua)}, {ti});")
        s += ['  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
              f"  values ('lesson', v_lesson, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE_NEW)});"]
    s += ['end $$;', '']
    return s


SCENE2_SITUATION = {'symbols': 'travel', 'carnival': 'travel', 'tales': 'small_talk'}


def conv_id(n: int) -> str:
    return uid('conversation_a1dupes', LEVEL, D.LESSON_IDS[n], 'new')


def ex_id(n: int, old_id: str) -> str:
    return uid('exercise_a1dupes', LEVEL, D.LESSON_IDS[n], old_id)


WHAT = {'Д3': 'урок «Договір і зарплата» без бруто, нето й податків — їх пояснює A2-34 (Д3)',
        'Д12': 'урок «В аптеці: як приймати ліки» без tableta, lijek protiv bolova — їх учать в A0 «В аптеці» (Д12)',
        'Д13': 'урок «Дубровник і Спліт» без katedrala, zidine — вони в A0 «Старе місто» (Д13)',
        'Д2': 'урок «Навчання й мовні курси» — запис на курс і перше заняття; іспит і визнання — в A2-11…A2-13 (Д2)'}


def change_sql(n: int) -> list[str]:
    ch = D.CHANGES[n]
    lid = D.LESSON_IDS[n]
    what = WHAT[ch['note']]
    first_new = ch['swap'][0][1]
    s = [f'-- 3. Урок {OLD_NUMBER[lid]} (стане {NUMBER[lid]}): {what}', 'do $$', 'declare', f'  v_lesson constant uuid := {q(lid)};', 'begin',
         f"  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id where li.lesson_id = v_lesson "
         f"and li.item_type = 'lexeme' and lower(x.lemma) = {q(first_new.lower())}) then return; end if;  -- уже зроблено",
         f"  perform pg_temp.snapshot_lesson(v_lesson, {q('a1_dupes: ' + what + ' — стара версія')});"]
    for old, new in ch['swap']:
        s.append(f'  perform pg_temp.swap_word(v_lesson, {q(old)}, {q(new)});')
    for old_answer, ex in ch.get('ex', []):
        o = old_exercise(n, old_answer)
        nid = ex_id(n, o['item'])
        if ex['type'] == 'multiple_choice':
            same = ex['question'] == o['question'] and ex['answer'] == o['answer']
            opts = qj(ex['options'] if same else shuffled(ex['options'], f'a1dupes:{n}:{ex["answer"]}'))
        elif ex['type'] in ('listening', 'sentence_builder'):
            opts = qj(shuffled(ex['answer'].split(' '), f'a1dupes:{n}:{ex["answer"]}'))
        else:
            opts = 'null'
        s.append(f"  perform pg_temp.swap_ex(v_lesson, {q(o['item'])}, {q(nid)}, {q(ex['type'])}, {q(ex['question'])}, {q(ex['answer'])}, "
                 f"{opts}, {q(ex.get('word'))});")
    if 'conv' in ch:
        old, (s_ua, s_hr, sit, turns) = ch['conv']
        cid = conv_id(n)
        s += [f'  -- діалог «{CONVS[old]["title_hr"]}» → «{s_hr}» (старий — DEPRECATED, не видаляється)',
              f"  update public.conversations set status = 'DEPRECATED' where id = {q(old)} and status = 'PUBLISHED';",
              f"  if not found then raise exception 'Немає діалогу «{CONVS[old]['title_hr']}» — звірте базу'; end if;",
              '  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)',
              '  -- source — як в інших діалогів уроку (програма curriculum_a1_v3); звідки діалог — у content_reviews',
              f"  values ({q(cid)}, v_lesson, {q(s_ua)}, {q(s_hr)}, {CONVS[old]['order']}, {q(LEVEL)}, {q(sit)}, {q(STATUS)}, 'claude_curriculum_a1_v3');"]
        for ti, (sp, hr, ua) in enumerate(turns, 1):
            s.append(f"  perform pg_temp.turn({q(uid('turn_a1dupes', cid, ti))}, {q(cid)}, {q(sp)}, {q(hr)}, {q(ua)}, {ti});")
    if 'objectives' in ch:
        s.append(f"  update public.lessons set objectives = {qj(ch['objectives'])} where id = v_lesson;")
    s += ['  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
          f"  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE_LESSON.format(what=what))});",
          'end $$;', '']
    return s


def a2_add_sql() -> str:
    out = ['-- 4. Слова не зникають з курсу: svjedodžba → A2-11, porez і platna lista → A2-34 (у кінець уроку, без нових вправ)']
    for lid, (title, words) in D.A2_ADD.items():
        what = f'+ {", ".join(words)} з уроку A1 (план «Дублі», PR 3) — слова не зникають з курсу'
        arr = ', '.join(q(w) for w in words)
        out.append(f"""do $$
declare v_lesson constant uuid := {q(lid)}; w text;
begin
  if exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id
              where li.lesson_id = v_lesson and li.item_type = 'lexeme' and lower(x.lemma) = {q(words[0])}) then return; end if;  -- уже зроблено
  perform pg_temp.snapshot_lesson(v_lesson, {q('a1_dupes: ' + title + ' ' + what + ' — стара версія')});
  foreach w in array array[{arr}] loop
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill)
    select v_lesson, 'lexeme', (select id from public.lexemes where lower(lemma) = w and status = 'PUBLISHED' order by created_at limit 1),
           (select max(order_index) + 1 from public.lesson_items where lesson_id = v_lesson), 'vocabulary';
  end loop;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE_LESSON.format(what=title + ' ' + what))});
end $$;
""")
    return '\n'.join(out)


def move_sql() -> str:
    lid = D.LESSON_IDS[D.MOVE['lesson']]
    to_unit = D.UNITS[D.MOVE['to_module']]
    what = 'урок «Надзвичайні ситуації» → модуль A1.8 «Здоров’я», після «Здоровий спосіб життя» (рішення власника 2026-11-17)'
    return f"""-- 5. Урок 105 «Надзвичайні ситуації» → модуль A1.8 «Здоров’я», місце {D.MOVE['to_order']} (стане уроком {NUMBER[lid]}); стара версія — content_versions
do $$
declare v_lesson constant uuid := {q(lid)};
begin
  if (select unit_id from public.lessons where id = v_lesson) = {q(to_unit)}::uuid then return; end if;  -- уже зроблено
  if (select unit_id from public.lessons where id = v_lesson) is distinct from {q(D.UNITS[12])}::uuid
     or (select count(*) from public.lessons where unit_id = {q(to_unit)} and status = 'PUBLISHED') <> 10 then
    raise exception 'Урок 105 не в модулі A1.12 або в A1.8 не 10 уроків — звірте базу';
  end if;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'lesson', l.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = l.id), 0) + 1,
         to_jsonb(l), {q('a1_dupes: ' + what + ' — стара версія')}
    from public.lessons l where l.id = v_lesson;
  update public.lessons set unit_id = {q(to_unit)}, order_index = {D.MOVE['to_order']} where id = v_lesson;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE_LESSON.format(what=what))});
end $$;
"""


def rename_sql() -> str:
    out = [f'-- 6. Нові назви {len(D.RENAME_CONVS)} діалогів з однаковими назвами (у пізнішому уроці; зміст інший); стара — у content_versions']
    for cid, (where, old_t, (t_ua, t_hr)) in D.RENAME_CONVS.items():
        out.append(f"""do $$
begin
  if (select title_hr from public.conversations where id = {q(cid)}) = {q(t_hr)} then return; end if;  -- уже зроблено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'conversation', c.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation' and entity_id = c.id), 0) + 1,
         to_jsonb(c), {q(f'a1_dupes: нова назва діалогу уроку {where} (така сама — в іншому уроці) — стара версія')}
    from public.conversations c where c.id = {q(cid)} and c.title_hr = {q(old_t)} and c.status = 'PUBLISHED';
  if not found then raise exception 'Немає діалогу «{old_t}» уроку {where} — звірте базу'; end if;
  update public.conversations set title_ua = {q(t_ua)}, title_hr = {q(t_hr)} where id = {q(cid)};
end $$;""")
    return '\n'.join(out) + '\n'


RENUMBER_SQL = """-- 7. Наскрізні номери всіх уроків A1 («Урок N: …» / «Lekcija N: …»); стара назва — у content_versions;
--    порядок діалогів уроків v3 (3000 + N·10 + k) — за новим номером
do $$
declare r record; v_payload jsonb; v_new_ua text; v_new_hr text;
begin
  for r in select l.id, l.title_ua, l.title_hr,
                  row_number() over (order by m.order_index, u.order_index, l.order_index) as n
             from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
            where m.level_code = 'A1' and l.status = 'PUBLISHED' loop
    update public.conversations set order_index = 3000 + r.n * 10 + order_index % 10
     where lesson_id = r.id and order_index between 3000 and 4999 and order_index / 10 <> 300 + r.n;
    v_new_ua := regexp_replace(r.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':');
    v_new_hr := regexp_replace(r.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':');
    if v_new_ua is not distinct from r.title_ua and v_new_hr is not distinct from r.title_hr then continue; end if;
    select to_jsonb(l) into v_payload from public.lessons l where l.id = r.id;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'a1_dupes: новий номер уроку ' || r.n || ' (урок 105 → A1.8, 3 нові уроки A1.11)');
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;
"""


def selfcheck_sql() -> str:
    changed = [D.LESSON_IDS[n] for n in D.CHANGES]
    news = [new_lesson_id(N['slug']) for N in D.NEW_LESSONS]
    nlex = len(NEW)
    lemmas = ', '.join(q(k) for k in NEW)
    removed = sorted(w.lower() for w in removed_words())
    to_a1 = [w.lower() for w in list(D.EXISTING) + list(D.FROM_A2_9)]
    n105 = NUMBER[D.LESSON_IDS[105]]
    new_titles = ', '.join(f"({q(new_lesson_id(N['slug']))}::uuid, {q('Урок ' + str(NUMBER[N['slug']]) + ': ' + N['title'][0])})"
                           for N in D.NEW_LESSONS)
    renamed = ', '.join(f'({q(cid)}::uuid, {q(t[2][1])})' for cid, t in D.RENAME_CONVS.items())
    return f"""-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_lex int;
begin
  -- уроки A1: {NEW_TOTAL}, номери 1…{NEW_TOTAL} без пропусків; A1.8 — 11 уроків (105 → {n105}), A1.11 — 8, A1.12 — 7
  if (select count(*) from public.lessons where level_code = 'A1' and status = 'PUBLISHED') <> {NEW_TOTAL}
     or exists (select 1 from (select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) n
                                 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                                where m.level_code = 'A1' and l.status = 'PUBLISHED') t
                 where t.title_ua !~ ('^Урок ' || t.n || ':') or t.title_hr !~ ('^Lekcija ' || t.n || ':')) then
    raise exception 'Уроки A1: очікувалось {NEW_TOTAL} з номерами 1…{NEW_TOTAL}';
  end if;
  if (select count(*) from public.lessons where unit_id = {q(D.UNITS[8])} and status = 'PUBLISHED') <> 11
     or (select count(*) from public.lessons where unit_id = {q(D.UNITS[11])} and status = 'PUBLISHED') <> 8
     or (select count(*) from public.lessons where unit_id = {q(D.UNITS[12])} and status = 'PUBLISHED') <> 7
     or (select title_ua from public.lessons where id = {q(D.LESSON_IDS[105])}) <> 'Урок {n105}: Надзвичайні ситуації'
     or (select count(*) from (values {new_titles}) t(id, title) join public.lessons l on l.id = t.id and l.title_ua = t.title) <> {len(news)} then
    raise exception 'Модулі A1.8 / A1.11 / A1.12: очікувалось 11 / 8 / 7 уроків і нові номери';
  end if;
  -- діалоги уроків A1 v3: порядок 3000 + N·10 + k
  if exists (select 1 from public.conversations c join public.lessons l on l.id = c.lesson_id
              where l.level_code = 'A1' and l.status = 'PUBLISHED' and c.status = 'PUBLISHED'
                and c.order_index / 10 <> 300 + substring(l.title_ua from '^Урок ([0-9]+):')::int) then
    raise exception 'Порядок діалогів A1 не за номером уроку';
  end if;
  -- змінені й нові уроки: 2 опубліковані діалоги, 15 обов’язкових вправ (усі опубліковані)
  select count(*) into v_bad from public.lessons l
   where l.id in ({', '.join(q(x) for x in changed + news)})
     and ((select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and li.required) <> 15
          or exists (select 1 from public.lesson_items li join public.exercises e on e.id = li.item_id
                      where li.lesson_id = l.id and li.item_type = 'exercise' and e.status <> 'PUBLISHED'));
  if v_bad > 0 then raise exception 'Уроки пакета: % з неправильним складом', v_bad; end if;
  select count(*) into v_bad from public.lessons l where l.id in ({', '.join(q(x) for x in news)})
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or exists (select 1 from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED'
                      and (select count(*) from public.conversation_turns t where t.conversation_id = c.id) <> 6));
  if v_bad > 0 then raise exception 'Нові уроки A1.11: % без 20–25 слів чи 6 реплік', v_bad; end if;
  -- прибраних слів більше немає в уроках A1; svjedodžba — в A2-11, porez і platna lista — в A2-34
  if exists (select 1 from public.lesson_items li join public.lessons l on l.id = li.lesson_id and l.level_code = 'A1' and l.status = 'PUBLISHED'
              join public.lexemes x on x.id = li.item_id where li.item_type = 'lexeme' and lower(x.lemma) in ({', '.join(q(r) for r in removed)})) then
    raise exception 'Прибрані слова ще в уроках A1';
  end if;
  if (select count(*) from public.lesson_items li join public.lexemes x on x.id = li.item_id
       where li.item_type = 'lexeme' and ((li.lesson_id = {q(list(D.A2_ADD)[0])} and lower(x.lemma) = 'svjedodžba')
          or (li.lesson_id = {q(list(D.A2_ADD)[1])} and lower(x.lemma) in ('porez', 'platna lista')))) <> 3 then
    raise exception 'A2-11 / A2-34: немає слів з уроків A1';
  end if;
  -- нові слова: опубліковані, з мітками; рівні слів
  select count(*) into v_lex from public.lexemes where lower(lemma) in ({lemmas}) and status = 'PUBLISHED'
     and register is not null and regionality is not null and usage_tags is not null;
  if v_lex <> {nlex} then raise exception 'Нових слів: % (очікувалось {nlex})', v_lex; end if;
  if exists (select 1 from public.lexemes where lower(lemma) in ({', '.join(q(w) for w in to_a1)}) and status = 'PUBLISHED' and cefr <> 'A1')
     or exists (select 1 from public.lexemes where lower(lemma) in ({', '.join(q(w.lower()) for w in D.TO_A2)}) and status = 'PUBLISHED' and cefr <> 'A2') then
    raise exception 'Рівні слів: наявні слова нових уроків — не A1 або прибрані — не A2';
  end if;
  -- діалоги — нові назви, без повторів назв в A1
  if (select count(*) from (values {renamed}) t(id, title) join public.conversations c on c.id = t.id and c.title_hr = t.title) <> {len(D.RENAME_CONVS)} then
    raise exception 'Діалоги не перейменовано';
  end if;
  if exists (select 1 from public.conversations c join public.lessons l on l.id = c.lesson_id and l.level_code = 'A1' and l.status = 'PUBLISHED'
              where c.status = 'PUBLISHED' group by lower(c.title_hr) having count(*) > 1) then
    raise exception 'Однакові назви діалогів в A1';
  end if;
  raise notice 'Готово: 20261117_a1_dupes_1_lessons.sql — 3 нові уроки A1.11, урок 105 → A1.8 ({n105}), уроки 54, 70, 93, 101 без дублів, {nlex} нових слів, 9 назв діалогів, уроків A1 — {NEW_TOTAL}';
end $$;
"""


def build(c: CourseA1Dupes) -> str:
    head = f"""-- =====================================================================
-- Дублі A1 · 2026-11-17 (план «Дублі й сенс уроків A0–A2», PR 3)
-- Згенеровано: python3 -B scripts/gen_a1_dupes.py (не редагуйте вручну).
--
-- Рішення власника 2026-11-17: урок 105 «Надзвичайні ситуації» → модуль A1.8 «Здоров’я» (стане {NUMBER[D.LESSON_IDS[105]]});
-- Д2 (урок 101), Д3 (54), Д13 (93), Д12 (70); A1.11 «Хорватська культура» — 3 нові уроки; 9 назв діалогів. Уроків A1 {OLD_TOTAL} → {NEW_TOTAL}.
--   * Нові слова: {len(NEW)} (з мітками); наявні без уроку — {len(D.EXISTING)} і з A2-9 — {len(D.FROM_A2_9)} (рівень → A1);
--     прибрані, які тепер учать лише в A2 ({len(D.TO_A2)}), — рівень A2; svjedodžba → A2-11, porez і platna lista → A2-34.
--   * Слово в уроці — заміна на тому самому місці; вправи на прибрані слова й діалоги — нові на тому самому місці.
--   * Нічого не видаляється: старі діалоги й вправи → DEPRECATED; копія складу уроків — backup.lesson_items_a1dupes_20261117;
--     старі версії уроків, діалогів і слів — у content_versions. Прогрес користувачів не змінюється.
--   * Далі за назвою: 20261117_a1_dupes_2_tests.sql (перевірки модулів A1.6, A1.8, A1.11, A1.12 і фінал A1).
--   * Повторний запуск нічого не змінює. Бета: PUBLISHED.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: 20261117_a1_dupes_1_lessons.sql — …».
-- =====================================================================

begin;
"""
    out = [head, backup_sql(), HELPERS_SQL, HELPER_TASK]
    out += lexemes_sql()
    out.append(cefr_sql(list(D.EXISTING) + list(D.FROM_A2_9), 'A1',
                        'a1_dupes: рівень слова A1 — його вперше вчать в уроці A1 — стара версія',
                        f'1а. Слова без уроку ({len(D.EXISTING)}) і з A2-9 ({len(D.FROM_A2_9)}), які тепер учать в уроках A1: рівень — A1'))
    out.append(cefr_sql(list(D.TO_A2), 'A2', 'a1_dupes: рівень слова A2 — в уроках A1 його більше немає, його вчать в A2 — стара версія',
                        f'1б. Прибрані з уроків A1 слова, які вчать в A2 ({len(D.TO_A2)}): рівень — A2'))
    out += new_lessons_sql(c)
    for n in sorted(D.CHANGES):
        out += change_sql(n)
    out.append(a2_add_sql())
    out.append(move_sql())
    out.append(rename_sql())
    out.append(RENUMBER_SQL)
    out.append(selfcheck_sql())
    out.append('commit;\n')
    return '\n'.join(out)


# ----------------------------------------------------------------------------- звіт для носія
def review(c: CourseA1Dupes) -> str:
    out = ['# Дублі A1 (план «Дублі й сенс уроків», PR 3) — для носія мови (2026-11-17)', '',
           'Згенеровано: `python3 -B scripts/gen_a1_dupes.py --review`. Бета (опубліковано одразу). Позначте рядок і напишіть, як краще.',
           'Номери уроків — нові (після переносу уроку 105 в A1.8 і трьох нових уроків A1.11).', '',
           '## Що варто глянути носію', '',
           '1. **Нові вирази**: *raditi vikendom*, *opis posla*, *uvjeti rada*, *dvaput dnevno*, *bilo jednom* (початок казки — '
           'чи не краще *Bio jednom…*), *za laku noć* («priča za laku noć»), *svjetski poznat*.',
           '2. **Мітки походження**: *maškare* — `italianism`, *maskenbal* — `germanism`; чи *maškare* звучить нейтрально в усій Хорватії '
           '(у Загребі кажуть *fašnik*).',
           '3. **Факти в діалогах**: краватка від хорватських солдатів (XVII ст.), День краватки 18 жовтня; Пенкала — механічний олівець '
           'і авторучка; парашут Фауста Вранчича «понад 400 років тому»; дзвонарі з околиць Рієки; «Priče iz davnine» (1916) — '
           '«уже понад сто років»; 25 полів на гербі.',
           '4. **Форми**: *Je li ju hrabri kraljević spasio?* (ju, а не je), *gusarica*, *Maskirat ću se u gusaricu*, '
           '*Na karneval idem s prijateljima*.',
           '5. **Переклади**: *kostim* — «костюм (карнавальний, сценічний)»; *poklade* — «карнавальні дні перед Великим постом (масниця)»; '
           '*zvončari* — «дзвонарі»; *Pepelnica* — «Попільна середа».', '']
    for n in sorted(D.CHANGES):
        ch = D.CHANGES[n]
        lid = D.LESSON_IDS[n]
        out += [f'## Урок {NUMBER[lid]} (був {OLD_NUMBER[lid]}) — {ch["note"]}', '', '| Було | Стало | Переклад |', '|---|---|---|']
        out += [f'| *{o}* | *{w}* | {LEX[w.lower()][1]} |' for o, w in ch['swap']] + ['']
        if 'conv' in ch:
            old, (s_ua, s_hr, sit, turns) = ch['conv']
            out += [f'**Новий діалог: {s_hr}** ({s_ua}) (замість «{CONVS[old]["title_hr"]}»)', '']
            out += [f'- **{sp}:** {hr} — {ua}' for sp, hr, ua in turns] + ['']
        out += ['**Нові вправи (на місці старих)**', '', '| Тип | Завдання | Відповідь |', '|---|---|---|']
        for _old, ex in ch['ex']:
            note = ' (лише нові варіанти)' if ex['type'] == 'multiple_choice' and old_exercise(n, _old)['question'] == ex['question'] else ''
            out.append(f"| {ex['type']} | {ex['question']}{note} | {ex['answer']} |")
        out.append('')
    out += ['## Слова, які переходять в A2', '',
            '- *svjedodžba* → A2 урок 11 «Визнання диплома»; *porez*, *platna lista* → A2 урок 34 «Зарплата» (у кінець списку слів);',
            '- *polagati*, *položiti* — уже в A2 уроці 12, *uvjerenje* — в A2 уроці 13;',
            '- *bruto*, *neto*, *doprinosi*, *priznavanje*, *lijek protiv bolova* — лише в словнику (в A2-34 — *bruto plaća*, *neto plaća*, '
            '*mirovinski doprinos*; в A2-11 — *priznavanje diplome*; в A0 «В аптеці» — *lijek*, *protiv bolova*);',
            '- *upisati se*, *test razine*, *početni tečaj* — з A2 уроку 9 в A1 урок 105 (був 101; з A2-9 їх приберемо в PR 4).', '',
            '## Нові назви діалогів', '', '| Урок | Було | Стало |', '|---|---|---|']
    for cid, (where, old_t, (t_ua, t_hr)) in D.RENAME_CONVS.items():
        lid = CONVS[cid]['lesson']
        out.append(f'| {NUMBER[lid]} (був {where.split()[1]}) | {old_t} | {t_hr} ({t_ua}) |')
    out += ['', '## Нові слова', '', '| Слово | Переклад | Рід / вид | Ознаки | Приклад |', '|---|---|---|---|---|']
    for r in NEW.values():
        f = r['forms']
        fv = f.get('gender') or (f.get('aspect', '') + (f' / {f["pair"]}' if f.get('pair') else ''))
        out.append(f"| *{r['lemma']}* | {r['ukrainian_translation']} | {fv} | {', '.join(r['usage_tags'])} | {r['examples'][0]} |")
    for N in D.NEW_LESSONS:
        key = (MOD, N['order'])
        L = c.lessons[key]
        out += ['', f'## Новий урок {NUMBER[N["slug"]]} «{L["title"][0]}» ({L["title"][1]})', '',
                f'Граматика: {L["grammar"]}. Слова: ' + ', '.join(f'*{w}*' for w in L['words']), '']
        for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1):
            out += [f'**Діалог {si}: {s_hr}** ({s_ua})', ''] + [f'- **{sp}:** {hr} — {ua}' for sp, hr, ua in turns] + ['']
        out += ['**Вправи**', '', '| Тип | Завдання | Відповідь | Варіанти |', '|---|---|---|---|']
        for ex in c.lesson_exercises(key):
            opts = ' · '.join(ex['options']) if ex['options'] and ex['type'] not in ('sentence_builder', 'listening') else ''
            out.append(f"| {ex['type']} | {ex['question']} | {ex['answer']} | {opts} |")
    return '\n'.join(out) + '\n'


# ----------------------------------------------------------------------------- перевірки (пакет 2)
ASSESS_SNAPSHOT = HERE / 'assessment_a1_dupes_snapshot.json'
ASSESS_MODULES = (6, 8, 11, 12)
ASSESS_NOTE = ('Бета: перевірки рівня A1 за схемою 2026-11-07 після плану «Дублі й сенс уроків» (PR 3, рішення власника 2026-11-17): '
               '{what}. Завдання — з діалогів, вправ і текстів уроків. Потрібна перевірка носієм.')
ASSESS_WHAT = {'a1-m06': 'тест модуля A1.6 наново (урок 54 — без бруто, нето й податків, новий діалог)',
               'a1-m08': 'тест модуля A1.8 наново (11 уроків: + «Надзвичайні ситуації», урок 70 без tableta)',
               'a1-m11': 'тест модуля A1.11 наново (8 уроків з трьома новими)',
               'a1-m12': 'тест модуля A1.12 наново (7 уроків, урок 101 — запис на курс і перше заняття)',
               'a1-final': 'фінал A1 наново з усіх 13 модулів (одне завдання було на прибране слово priznavanje)'}


def assessments_main():
    import gen_assessment_a0_a1_v5 as V5   # noqa: PLC0415
    import gen_assessment as A              # noqa: PLC0415
    snap = json.loads(ASSESS_SNAPSHOT.read_text(encoding='utf-8'))
    a1 = snap['level']
    orders = [m['order'] for m in a1['modules']]
    per_mod = {m['order']: len(m['lessons']) for m in a1['modules']}
    if orders != list(range(1, 14)) or (per_mod[8], per_mod[11], per_mod[12]) != (11, 8, 7):
        raise SystemExit('Знімок перевірок — не після пакета 20261117_a1_dupes_1_lessons.sql')
    V5.LEVEL_DATA['A1'] = a1
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

    keep = snap['items']                                    # опубліковані завдання тестів A1, які не змінюються
    mid_seen = texts_of(keep['a1-mid'])
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
    for m in ASSESS_MODULES:
        slug = f'a1-m{m:02d}'
        items, plan = V5.module_test('A1', m)
        A.PLAN[slug] = plan
        for i, it in enumerate(items, 1):
            it['module'] = m
            it['order'] = i
            it['id'] = A.uid('assessment', slug, VER, 'item', i)
        tests.append({'slug': slug, 'kind': slug, 'db_kind': 'module', 'module': m, 'title_ua': f'Перевірка модуля A1.{m}', 'items': items})
    A.Pools = _pools
    seen = mid_seen | texts_of(it for slug, its in keep.items() if slug != 'a1-mid' for it in its)
    seen |= {x for t in tests for it in t['items'] for x in V5.shown(it)}
    exact: set[str] = set()
    for its in list(keep.values()) + [t['items'] for t in tests]:
        for it in its:
            exact |= {x.lower() for x in (it.get('audio_hr'), it.get('answer_text'), it.get('prompt_hr')) if x}

    def exact_ok(items) -> bool:
        return all((it.get('audio_hr') or it.get('answer_text') or '').lower() not in exact for it in items)

    def final_ok(items) -> bool:
        trial = {'slug': 'a1-final', 'kind': 'a1-final', 'db_kind': 'final', 'module': None, 'upto': 13,
                 'items': [dict(it, options=list(it['options']), order=i) for i, it in enumerate(json.loads(json.dumps(items)), 1)]}
        try:
            A.finalize([trial], 'A1')
        except SystemExit:
            return False
        return True

    slug = 'a1-final'
    A.PLAN[slug] = V5.LEVEL_PLANS['final']
    pools = A.Pools(V5.level('A1', 13))
    V5.prune(pools, seen)
    mods = sorted(pools.by_module)
    best = None
    for attempt in range(160):
        try:
            items = V5.fill_balanced(pools, set(), V5.LEVEL_PLANS['final'], mods, slug, seed=slug if attempt == 0 else f'{slug}:{attempt}')
        except SystemExit:
            continue
        per = Counter(it['module'] for it in items)
        hard, soft = V5.clashes(items)
        if all(per[m] >= 2 for m in mods) and hard == 0 and exact_ok(items) and final_ok(items) and (best is None or soft < best[0]):
            best = (soft, items)
            if soft == 0:
                break
    if best is None:
        raise SystemExit('a1-final: не вдалося покрити всі модулі без повторів')
    items = best[1]
    for i, it in enumerate(items, 1):
        it['order'] = i
        it['id'] = A.uid('assessment', slug, VER, 'item', i)
    tests.append({'slug': slug, 'kind': slug, 'db_kind': 'final', 'module': None, 'upto': 13, 'title_ua': 'Фінальна перевірка рівня A1',
                  'items': items})
    tests = V5.with_alternatives(A.finalize(tests, 'A1'))
    problems = []
    for t in tests:
        want = V5.n_items('A1', t['module']) if t['db_kind'] == 'module' else 48
        if len(t['items']) != want:
            problems.append(f"{t['slug']}: {len(t['items'])} завдань, а за схемою {want}")
        if t['db_kind'] == 'module' and any(it['lesson'] and it['module'] != t['module'] for it in t['items']):
            problems.append(f"{t['slug']}: завдання з іншого модуля")
    per = Counter(it['module'] for it in tests[-1]['items'])
    if any(per[m] < 2 for m in range(1, 14)):
        problems.append(f'a1-final: модулі з < 2 завдань: {[m for m in range(1, 14) if per[m] < 2]}')
    problems += V5.check_alternatives(it['answer_text'] for t in tests for it in t['items'] if it['item_type'] == 'sentence_builder')
    removed = {w.lower() for w in removed_words()}
    for t in tests:
        for it in t['items']:
            if (it.get('answer_text') or '').lower() in removed:
                problems.append(f"{t['slug']}: завдання на прибране слово «{it['answer_text']}»")
    if problems:
        raise SystemExit('Перевірка не пройдена:\n' + '\n'.join(problems))
    if '--check' in sys.argv:
        for t in tests:
            print(t['slug'], len(t['items']), dict(Counter(it['module'] for it in t['items'])))
        return tests
    OUT_ASSESS.write_text(assess_sql(V5, tests, a1), encoding='utf-8')
    print(f'{OUT_ASSESS.relative_to(ROOT)}: {len(OUT_ASSESS.read_bytes()) // 1024} КБ')
    return tests


def assess_sql(V5, tests, a1) -> str:
    blocks = []
    for t in tests:
        desc, minutes = V5.description('A1', t)
        rows = ',\n'.join(V5.item_row('A1', it) for it in t['items'])
        mod = next((m for m in a1['modules'] if m['order'] == t['module']), None)
        mod_check = (f"""  if (select module_id from public.assessments where id = v_aid) is distinct from {q(mod['id'])}::uuid then
    raise exception 'Тест {t['slug']} прив’язаний не до модуля A1.{t['module']} — звірте базу';
  end if;
""" if mod else '')
        blocks.append(f"""-- {t['title_ua']} · {len(t['items'])} завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = {q(t['slug'])} and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту {t['slug']} — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = {q(t['items'][0]['id'])}) then return; end if;  -- уже оновлено
{mod_check}  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'a1_dupes: перевірку оновлено після плану «Дублі й сенс уроків» (PR 3) — старі завдання');
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
-- Перевірки рівня A1 після плану «Дублі й сенс уроків» (PR 3) · 2026-11-17
-- Згенеровано: python3 -B scripts/gen_a1_dupes.py assessments (не редагуйте вручну).
--
-- Запускати після 20261117_a1_dupes_1_lessons.sql (назва файлу стоїть після нього — «Apply SQL» запускає за назвою).
-- Схема 2026-11-07: модуль — 2 завдання на урок (12–20), фінал — 48 (кожен модуль — щонайменше 2). У файлі {total} нових завдань:
--   {sizes}.
--   * a1-m06 — урок 54 без бруто, нето й податків і з новим діалогом; a1-m08 — 11 уроків (з «Надзвичайними ситуаціями»);
--     a1-m11 — 8 уроків (3 нові); a1-m12 — 7 уроків, урок 101 — запис на курс і перше заняття;
--   * a1-final — наново з усіх 13 модулів (одне завдання було на прибране слово priznavanje), без джерел і речень тестів
--     модулів і середини. Середина (a1-mid) і решта тестів модулів не змінюються.
--   * Завдання — з діалогів, вправ і текстів уроків; нових хорватських речень немає. Старі завдання — у content_versions і DEPRECATED.
--   * Спроби й результати користувачів не змінюються. Повторний запуск нічого не змінює.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: 20261117_a1_dupes_2_tests.sql — {len(tests)} тестів, {total} нових завдань».
-- =====================================================================

begin;

{chr(10).join(blocks)}
-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ({ids}) and status = 'PUBLISHED';
  select count(*) into v_bad from (values {expected}) e(slug, n) left join public.assessments a on a.slug = e.slug and a.cefr = 'A1' and a.status = 'PUBLISHED'
   where a.id is null
      or (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> e.n
      or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ({ids}));
  if v_new <> {total} or v_bad > 0 then raise exception 'Перевірки A1: нових завдань % (очікувалось {total}), тестів з помилкою %', v_new, v_bad; end if;
  if exists (select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id and a.cefr = 'A1' and a.kind = 'module'
               join public.lessons l on l.id = i.lesson_id join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
              where i.status = 'PUBLISHED' and m.id is distinct from a.module_id) then
    raise exception 'Перевірки модулів A1: завдання з уроку іншого модуля';
  end if;
  if (select count(distinct m.order_index) from public.assessment_items i join public.assessments a on a.id = i.assessment_id
        join public.lessons l on l.id = i.lesson_id join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
       where a.slug = 'a1-final' and a.cefr = 'A1' and i.status = 'PUBLISHED') <> 13 then
    raise exception 'a1-final: завдання не з усіх 13 модулів';
  end if;
  raise notice 'Готово: 20261117_a1_dupes_2_tests.sql — {len(tests)} тестів, % нових завдань', v_new;
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
        print('OK: нових слів', len(NEW), '; нові уроки', {N['slug']: NUMBER[N['slug']] for N in D.NEW_LESSONS},
              '; урок 105 →', NUMBER[D.LESSON_IDS[105]])
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
