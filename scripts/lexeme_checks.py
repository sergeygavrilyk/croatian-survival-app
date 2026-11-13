#!/usr/bin/env python3
"""
Спільні перевірки словника (lexemes) для всіх генераторів і батчів слів · з 2026-10-21.

Правила — docs/CONTENT_PIPELINE.md → «Граматичні поля» і skill croatian-lexeme-batch. Генератор батчу
імпортує check_batch() і зупиняється, якщо є помилки; попередження (warnings) — у звіт для носія.

  python3 -B scripts/lexeme_checks.py <batch.json>   # перевірити JSON-масив рядків lexemes
  python3 -B scripts/lexeme_checks.py --selftest     # самоперевірка правил

Рядок (dict): lemma, normalized, ukrainian_translation, part_of_speech, cefr, vocabulary_type, forms, examples,
register, regionality, usage_tags; необов'язково — standard_lemma (стандартний відповідник → lexemes.standard_lexeme_id).

Мітки (з 2026-11-13, рішення власника; модель — docs/LEARNING_SPEC.md §18, переліки — CHECK міграції M24):
  register    — standard | formal | informal | colloquial | slang | vulgar (scripts/lexeme_register.py);
  regionality — general | Zagreb | Zagorje | Dalmatia | Istria | Kvarner | Slavonia | Lika | Dubrovnik;
  usage_tags  — список (може бути порожнім [] — ознак немає) з youth_slang, internet_slang, professional_jargon,
                anglicism, italianism, germanism, turkism, idiom, kajkavian, chakavian, offensive.
  Мітка без значення (немає поля, null, "") або з невідомим значенням — ПОМИЛКА, не попередження: стандартне слово
  теж позначається явно (standard / general / []).
"""
import json
import re
import sys
from pathlib import Path

POS = ('noun', 'verb', 'adjective', 'adverb', 'pronoun', 'preposition', 'conjunction', 'particle',
       'interjection', 'number', 'phrase')
GENDERS = ('m', 'f', 'n', 'm_pl', 'f_pl', 'n_pl')
ASPECTS = ('ipfv', 'pfv', 'biasp')
VOCAB_TYPES = ('core', 'function_word', 'formulaic', 'collocation', 'chunk')
CEFR = ('A0', 'A1', 'A2', 'B1', 'B2')
# Переліки міток — ті самі, що в CHECK міграції M24 (supabase/migrations/20261113100000_m24_lexeme_labels.sql)
REGIONS = ('general', 'Zagreb', 'Zagorje', 'Dalmatia', 'Istria', 'Kvarner', 'Slavonia', 'Lika', 'Dubrovnik')
USAGE_TAGS = ('youth_slang', 'internet_slang', 'professional_jargon', 'anglicism', 'italianism', 'germanism', 'turkism',
              'idiom', 'kajkavian', 'chakavian', 'offensive')

CYR = re.compile(r'[Ѐ-ӿ]')
LATIN_WORD = re.compile(r'[a-zčćđšž]{3,}', re.I)
HR_LETTERS = re.compile(r"^[A-Za-zČĆĐŠŽčćđšž' ,()\-]+$")
PLACEHOLDER = re.compile(
    r'(Važno je .* u ovoj situaciji|dio svakodnevnog života|često se koristi|Primjer rečenice|To je vrlo [a-zčćđšž]+\.'
    r'|\btodo\b|\bxxx\b|\.\.\.|базовий термін|переклад слова|приклад речення|osnovni_pojam)', re.I)
# Українська глоса в дужках у прикладі: «Vidimo se! (Побачимось)» — заборонено (переклад — окреме поле)
GLOSS = re.compile(r'\([^)]*[Ѐ-ӿ][^)]*\)')
FOLD = str.maketrans('čćđšž', 'ccdsz')
HERE = Path(__file__).resolve().parent


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


def _empty(value) -> bool:
    return value is None or (isinstance(value, str) and not value.strip())


def check_labels(row: dict) -> tuple[list[str], list[str]]:
    """(помилки, попередження) для міток register / regionality / usage_tags / standard_lemma.
    Значення register з переліку перевіряє check_register() (scripts/lexeme_register.py)."""
    e, w = [], []
    if _empty(row.get('register')):
        e.append('немає мітки register — значення обов’язкове (стандартне слово — "standard")')

    region = row.get('regionality')
    if _empty(region):
        e.append('немає мітки regionality — значення обов’язкове (загальне слово — "general")')
    elif region not in REGIONS:
        hint = next((r for r in REGIONS if r.lower() == str(region).lower()), None)
        e.append(f'regionality «{region}» — дозволено: {", ".join(REGIONS)}'
                 + (f' (регіон з великої літери: «{hint}»)' if hint and hint != 'general' else ''))

    tags = row.get('usage_tags')
    if tags is None:
        e.append('немає мітки usage_tags — значення обов’язкове (якщо ознак немає — порожній список [])')
    elif not isinstance(tags, list) or not all(isinstance(t, str) for t in tags):
        e.append('usage_tags має бути списком рядків ([] — ознак немає)')
    else:
        unknown = [t for t in tags if t not in USAGE_TAGS]
        if unknown:
            e.append(f'usage_tags: невідомі ознаки {unknown} — дозволено: {", ".join(USAGE_TAGS)}'
                     + (' (регіон — у regionality, не в ознаках)' if any(t in REGIONS for t in unknown) else ''))
        if len(set(tags)) != len(tags):
            e.append('usage_tags: ознака повторюється')

    std = row.get('standard_lemma')
    if std is not None:
        if not isinstance(std, str) or not std.strip():
            e.append('standard_lemma — непорожній рядок (лема стандартного відповідника) або поле відсутнє')
        elif std.strip().lower() == (row.get('lemma') or '').strip().lower():
            e.append('standard_lemma — інша лема, не саме слово')
        elif row.get('register') == 'standard':
            w.append('standard_lemma у слова з register = standard — точно стандартне?')
    return e, w


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

    # Мітки (з 2026-11-13): усі три — з явним значенням і з переліку M24
    le, lw = check_labels(row)
    e += le
    w += lw

    # Регістр (з 2026-11-12): значення — з переліку; якщо слово є в правилах — попередження про очікуваний регістр
    if str(HERE) not in sys.path:
        sys.path.insert(0, str(HERE))
    from lexeme_register import check_register  # noqa: E402 (модуль поруч)
    re_, rw = check_register(row)
    e += re_
    w += rw

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
            'cefr': 'A1', 'vocabulary_type': 'core', 'forms': {'gender': 'f'}, 'examples': ['Uzmi kutlaču i nalij juhu.'],
            'register': 'standard', 'regionality': 'general', 'usage_tags': []}
    assert check_batch([good]) == ([], []), check_batch([good])
    # Мітки: без значення або з невідомим значенням — помилка
    for field in ('register', 'regionality', 'usage_tags'):
        assert any(field in m for m in check_row({k: v for k, v in good.items() if k != field})[0]), field
        assert any(field in m for m in check_row(dict(good, **{field: None}))[0]), field
    assert any('register' in m for m in check_row(dict(good, register=''))[0])
    assert any('regionality' in m for m in check_row(dict(good, regionality=' '))[0])
    assert any('register' in m for m in check_row(dict(good, register='regional'))[0])          # старе значення
    assert any('«Dalmatia»' in m for m in check_row(dict(good, regionality='dalmatia'))[0])     # з малої
    assert any('regionality' in m for m in check_row(dict(good, regionality='Split'))[0])
    assert any('невідомі' in m for m in check_row(dict(good, usage_tags=['regionalism']))[0])
    assert any('у regionality' in m for m in check_row(dict(good, usage_tags=['Zagreb']))[0])
    assert any('повторюється' in m for m in check_row(dict(good, usage_tags=['idiom', 'idiom']))[0])
    assert any('списком' in m for m in check_row(dict(good, usage_tags='anglicism'))[0])
    frend = dict(good, lemma='frend', normalized='frend', ukrainian_translation='друг', forms={'gender': 'm'},
                 examples=['Idem na kavu s frendom.'], register='slang', usage_tags=['youth_slang', 'anglicism'],
                 standard_lemma='prijatelj')
    assert check_row(frend)[0] == [], check_row(frend)[0]
    assert check_row(dict(frend, register='vulgar', usage_tags=['offensive'], standard_lemma=None))[0] == []
    assert any('інша лема' in m for m in check_row(dict(frend, standard_lemma='Frend'))[0])
    assert any('standard_lemma' in m for m in check_row(dict(frend, register='standard'))[1])
    fjaka = dict(good, lemma='fjaka', normalized='fjaka', ukrainian_translation='млявість, ліньки (від спеки)',
                 examples=['Danas me uhvatila fjaka.'], register='colloquial', regionality='Dalmatia')
    assert check_row(fjaka)[0] == [], check_row(fjaka)[0]
    bad = dict(good, examples=['Vidimo se! (Побачимось)'])
    assert any('кирилиця' in m for m in check_row(bad)[0])
    assert any('normalized' in m for m in check_row(dict(good, normalized='kutlača'))[0])
    assert any('без виду' in m for m in check_row(dict(good, lemma='čuvati', normalized='cuvati',
                                                        part_of_speech='verb', forms={}))[0])
    assert any('part_of_speech' in m for m in check_row(dict(good, part_of_speech='word'))[0])
    assert any('без роду' in m for m in check_row(dict(good, forms={}))[0])
    assert any('повтор' in m for m in check_batch([good, good])[0])
    assert any('заглушку' in m for m in check_row(dict(good, examples=['Važno je kutlača u ovoj situaciji.']))[0])
    assert any('register' in m for m in check_row(dict(good, register='casual'))[0])
    assert any('informal' in m for m in check_row(dict(good, lemma='bok', normalized='bok', part_of_speech='interjection'))[1])
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
