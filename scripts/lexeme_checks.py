#!/usr/bin/env python3
"""
Спільні перевірки словника (lexemes) для всіх генераторів і батчів слів · з 2026-10-21.

Правила — docs/CONTENT_PIPELINE.md → «Граматичні поля» і skill croatian-lexeme-batch. Генератор батчу
імпортує check_batch() і зупиняється, якщо є помилки; попередження (warnings) — у звіт для носія.

  python3 -B scripts/lexeme_checks.py <batch.json>   # перевірити JSON-масив рядків lexemes
  python3 -B scripts/lexeme_checks.py --selftest     # самоперевірка правил

Рядок (dict): lemma, normalized, ukrainian_translation, part_of_speech, cefr, vocabulary_type, forms, examples.
"""
import json
import re
import sys

POS = ('noun', 'verb', 'adjective', 'adverb', 'pronoun', 'preposition', 'conjunction', 'particle',
       'interjection', 'number', 'phrase')
GENDERS = ('m', 'f', 'n', 'm_pl', 'f_pl', 'n_pl')
ASPECTS = ('ipfv', 'pfv', 'biasp')
VOCAB_TYPES = ('core', 'function_word', 'formulaic', 'collocation', 'chunk')
CEFR = ('A0', 'A1', 'A2', 'B1', 'B2')

CYR = re.compile(r'[Ѐ-ӿ]')
LATIN_WORD = re.compile(r'[a-zčćđšž]{3,}', re.I)
HR_LETTERS = re.compile(r"^[A-Za-zČĆĐŠŽčćđšž' ,()\-]+$")
PLACEHOLDER = re.compile(
    r'(Važno je .* u ovoj situaciji|dio svakodnevnog života|često se koristi|Primjer rečenice|To je vrlo [a-zčćđšž]+\.'
    r'|\btodo\b|\bxxx\b|\.\.\.|базовий термін|переклад слова|приклад речення|osnovni_pojam)', re.I)
# Українська глоса в дужках у прикладі: «Vidimo se! (Побачимось)» — заборонено (переклад — окреме поле)
GLOSS = re.compile(r'\([^)]*[Ѐ-ӿ][^)]*\)')
FOLD = str.maketrans('čćđšž', 'ccdsz')


def normalize(text: str) -> str:
    """Те саме, що normalizeCroatian у lib/srs.ts: trim, нижній регістр, č ć → c, đ → d, š → s, ž → z."""
    return text.strip().lower().translate(FOLD)


def example_has_lemma(lemma: str, sentence: str) -> bool:
    """Груба перевірка: кожне змістове слово леми (≥ 3 літер) є в реченні хоча б основою з 3–4 літер.
    False — ще не помилка (відмінки, чергування: pas → psa, plakati → plače), а попередження для ручного перегляду."""
    words = [w for w in re.findall(r'[a-zčćđšž]+', lemma.lower()) if len(w) >= 3 and w not in ('sam', 'se')]
    text = normalize(sentence)
    for w in words or re.findall(r'[a-zčćđšž]+', lemma.lower()):
        if normalize(w)[:4 if len(w) >= 6 else 3] not in text:
            return False
    return True


def check_example(lemma: str, sentence: str, strict_lemma: bool = False) -> list[str]:
    errors = []
    if CYR.search(sentence):
        errors.append('кирилиця в прикладі' + (' (український переклад у дужках?)' if GLOSS.search(sentence) else ''))
    if PLACEHOLDER.search(sentence):
        errors.append('приклад схожий на заглушку / шаблон')
    if not re.match(r'^[A-ZČĆĐŠŽ„"]', sentence) or not re.search(r'[.!?]["“”]?$', sentence):
        errors.append('приклад має бути реченням: з великої літери, у кінці . ! ?')
    if not 8 <= len(sentence) <= 110:
        errors.append(f'довжина прикладу {len(sentence)} (8–110)')
    if strict_lemma and not example_has_lemma(lemma, sentence):
        errors.append('у прикладі немає слова-леми')
    return errors


def check_row(row: dict) -> tuple[list[str], list[str]]:
    """(помилки, попередження) для одного рядка."""
    e, w = [], []
    lemma = row.get('lemma') or ''
    ua = row.get('ukrainian_translation') or ''
    pos = row.get('part_of_speech')
    forms = row.get('forms') or {}
    examples = row.get('examples') or []

    if not lemma.strip() or lemma != lemma.strip():
        e.append('порожня лема або пробіли на краях')
    if CYR.search(lemma) or not HR_LETTERS.match(lemma):
        e.append('лема — лише хорватська латиниця (без кирилиці, цифр, «_», «->»)')
    if re.search(r'[?!.]$', lemma) or re.match(r'^[A-ZČĆĐŠŽ][a-zčćđšž]+:', lemma) or len(lemma.split()) > 5:
        e.append('лема схожа на речення / репліку — це для phrases / conversations')
    if lemma[:1].isupper() and pos != 'phrase' and not row.get('proper_noun'):
        w.append('лема з великої літери — це власна назва? (якщо так, додайте "proper_noun": true)')
    if row.get('normalized') is not None and row['normalized'] != normalize(lemma):
        e.append(f'normalized має бути «{normalize(lemma)}»')

    if not CYR.search(ua):
        e.append('переклад без кирилиці')
    if LATIN_WORD.search(re.sub(r'\([^)]*\)', '', ua)):
        w.append('у перекладі латиниця поза дужками — перевірити')
    if PLACEHOLDER.search(ua):
        e.append('переклад-заглушка')

    if pos not in POS:
        e.append(f'part_of_speech «{pos}» — дозволено: {", ".join(POS)}')
    if not isinstance(forms, dict):
        e.append('forms має бути об’єктом')
        forms = {}
    if pos == 'noun' and forms.get('gender') not in GENDERS:
        e.append(f'іменник без роду: forms.gender ∈ {GENDERS}')
    if pos == 'verb' and forms.get('aspect') not in ASPECTS:
        e.append(f'дієслово без виду: forms.aspect ∈ {ASPECTS}')
    if pos not in ('noun', 'phrase') and 'gender' in forms:
        e.append('forms.gender лише в іменника чи виразу')
    if pos == 'verb' and not re.search(r'(ti|ći)( se)?$', lemma):
        w.append('дієслово не в інфінітиві — лема має бути інфінітивом (форми — в forms)')
    if pos == 'phrase' and ' ' not in lemma:
        w.append('phrase з одного слова — може, це інша частина мови?')

    if row.get('vocabulary_type') not in VOCAB_TYPES:
        e.append(f'vocabulary_type ∈ {VOCAB_TYPES}')
    if row.get('cefr') not in CEFR:
        e.append(f'cefr ∈ {CEFR}')

    if not isinstance(examples, list) or not all(isinstance(x, str) for x in examples):
        e.append('examples — масив рядків')
        examples = []
    if not examples:
        w.append('немає прикладу')
    for s in examples:
        e += [f'приклад «{s}»: {m}' for m in check_example(lemma, s)]
        if not example_has_lemma(lemma, s):
            w.append(f'приклад «{s}»: основу леми не знайдено — перевірити')
    return e, w


def check_batch(rows: list[dict], existing: dict[str, str] | None = None) -> tuple[list[str], list[str]]:
    """Перевірка батчу. existing — {lower(lemma): cefr} з робочої бази (щоб не дублювати й не перезаписати інший рівень)."""
    errors, warnings = [], []
    seen: dict[str, int] = {}
    sentences: dict[str, str] = {}
    for i, row in enumerate(rows, 1):
        key = (row.get('lemma') or '').lower()
        e, w = check_row(row)
        errors += [f'#{i} {row.get("lemma")}: {m}' for m in e]
        warnings += [f'#{i} {row.get("lemma")}: {m}' for m in w]
        if key in seen:
            errors.append(f'#{i} {key}: повтор леми в батчі (рядок #{seen[key]}) — буде ON CONFLICT … second time')
        seen[key] = i
        if existing is not None and key in existing:
            warnings.append(f'#{i} {key}: уже є в базі (рівень {existing[key]}) — оновиться лише не опубліковане того ж рівня')
        for s in row.get('examples') or []:
            if s in sentences and sentences[s] != key:
                errors.append(f'#{i} {key}: той самий приклад, що в «{sentences[s]}»')
            sentences[s] = key
    return errors, warnings


def _selftest():
    good = {'lemma': 'kutlača', 'normalized': 'kutlaca', 'ukrainian_translation': 'ополоник', 'part_of_speech': 'noun',
            'cefr': 'A1', 'vocabulary_type': 'core', 'forms': {'gender': 'f'}, 'examples': ['Uzmi kutlaču i nalij juhu.']}
    assert check_batch([good]) == ([], []), check_batch([good])
    bad = dict(good, examples=['Vidimo se! (Побачимось)'])
    assert any('кирилиця' in m for m in check_row(bad)[0])
    assert any('normalized' in m for m in check_row(dict(good, normalized='kutlača'))[0])
    assert any('без виду' in m for m in check_row(dict(good, lemma='čuvati', normalized='cuvati',
                                                        part_of_speech='verb', forms={}))[0])
    assert any('part_of_speech' in m for m in check_row(dict(good, part_of_speech='word'))[0])
    assert any('без роду' in m for m in check_row(dict(good, forms={}))[0])
    assert any('повтор' in m for m in check_batch([good, good])[0])
    assert any('заглушку' in m for m in check_row(dict(good, examples=['Važno je kutlača u ovoj situaciji.']))[0])
    assert normalize(' Hitna pomoć ') == 'hitna pomoc' and normalize('događaj') == 'dogadaj'
    assert example_has_lemma('kuća', 'Moja kuća je blizu mora.') is True
    assert example_has_lemma('plakati', 'Dijete plače.') is False  # чергування — лише попередження
    print('selftest OK')


if __name__ == '__main__':
    if '--selftest' in sys.argv:
        _selftest()
        sys.exit(0)
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    rows = json.loads(open(sys.argv[1], encoding='utf-8').read())
    errs, warns = check_batch(rows)
    for m in warns:
        print('УВАГА', m)
    for m in errs:
        print('ПОМИЛКА', m)
    print(f'Рядків: {len(rows)}, помилок: {len(errs)}, попереджень: {len(warns)}')
    sys.exit(1 if errs else 0)
