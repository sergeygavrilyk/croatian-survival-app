#!/usr/bin/env python3
"""
Регістр лексем (`lexemes.register`): визначення, словник правил і ознаки · з 2026-11-12.

Визначення — docs/CONTENT_PIPELINE.md → «Регістр лексем» (рішення власника 2026-11-12):
  informal   — літературне, але неофіційне: bok, ćao, Kako si? (замість Kako ste?);
  colloquial — розмовне, нелітературне: kužiti, frka;
  slang      — мова групи: frend, fora.
  Порожньо (null) — стандартне / нейтральне слово. Регіон (`regionality`) — окремий вимір: регіональне слово
  отримує регістр за тими самими визначеннями (fjaka — colloquial + Dalmatia).

Модуль використовують:
  * scripts/gen_lexeme_register_20261112.py — позначки для наявних слів робочої бази;
  * будь-який новий батч слів (B1, «Živi hrvatski») — suggest_register() / check_register() перед видачею.

  python3 -B scripts/lexeme_register.py --selftest
"""
from __future__ import annotations

import re
import sys

# Значення, які пише цей модуль (визначення — вище)
REGISTERS = ('informal', 'colloquial', 'slang')
# Повний перелік майбутнього CHECK (M24, docs/LEARNING_SPEC.md §18): ще formal і vulgar — їх цей модуль не ставить
ALLOWED = REGISTERS + ('formal', 'vulgar')
# Старі значення в базі — нормалізує пакет M24 (regional → colloquial + regionality, non_standard → colloquial)
LEGACY = ('regional', 'non_standard')

# ---------------------------------------------------------------------------------------------------------------
# 1. Словник правил: лема (нижній регістр, з діакритикою) → (регістр, чому). Слова, яких ще немає в базі, теж тут —
#    для майбутніх батчів. Змінювати визначення — лише рішенням власника; нове слово — сюди, з причиною.
# ---------------------------------------------------------------------------------------------------------------
RULES: dict[str, tuple[str, str]] = {
    # informal — літературне, але неофіційне (друзі, родина, ровесники; «ти»)
    'bok': ('informal', 'неофіційне привітання й прощання (офіційно — dobar dan, doviđenja); приклад власника'),
    'ćao': ('informal', 'неофіційне привітання (з італ. ciao); приклад власника'),
    'čao': ('informal', 'інший запис ćao'),
    'kako si': ('informal', 'звертання на «ти» (офіційно — Kako ste?); приклад власника'),
    'kako si ti': ('informal', 'звертання на «ti»'),
    'čujemo se': ('informal', 'неофіційне прощання «зідзвонимось»'),
    'vidimo se': ('informal', 'неофіційне прощання «побачимось» (офіційно — doviđenja)'),
    'može': ('informal', '«Може!» як згода — неофіційно (офіційно — u redu, dogovoreno)'),
    'čekaj': ('informal', 'наказовий спосіб на «ти» (офіційно — čekajte)'),
    'javi se': ('informal', 'наказовий спосіб на «ти» (офіційно — javite se)'),
    'pazi': ('informal', 'наказовий спосіб на «ти» (офіційно — pazite)'),
    'nedostaješ mi': ('informal', 'звертання на «ти», близька людина'),
    # colloquial — розмовне, нелітературне (у словниках — «razg.»); регіональні діалектні слова — теж сюди
    'kužiti': ('colloquial', 'розмовне «розуміти» (стандартно — razumjeti); приклад власника'),
    'frka': ('colloquial', 'розмовне «паніка, проблема»; приклад власника'),
    'nema frke': ('colloquial', 'розмовне «без проблем» (стандартно — nema problema)'),
    'ful': ('colloquial', 'розмовне «дуже, повністю» (з англ. full)'),
    'super': ('colloquial', 'розмовна оцінка «супер» (стандартно — izvrsno, odlično)'),
    'okej': ('colloquial', 'розмовне «окей» (стандартно — u redu)'),
    'ok': ('colloquial', 'розмовне «окей» (стандартно — u redu)'),
    'ajde': ('colloquial', 'розмовна форма hajde'),
    'ma daj': ('colloquial', 'розмовний вигук «та ну!»'),
    'bezveze': ('colloquial', 'розмовне «безглуздо, нудно»'),
    'zezati': ('colloquial', 'розмовне «дражнити, жартувати»'),
    'zezati se': ('colloquial', 'розмовне «жартувати, дуріти»'),
    'fajn': ('colloquial', 'розмовне «гарно, добре» (з нім. fein)'),
    'fakat': ('colloquial', 'розмовне «справді» (стандартно — stvarno, zaista)'),
    'šparati': ('colloquial', 'розмовне «економити» (стандартно — štedjeti)'),
    'cuga': ('colloquial', 'розмовне «випивка» (з нім. Zug)'),
    'cugati': ('colloquial', 'розмовне «випивати»'),
    'klopa': ('colloquial', 'розмовне «їжа» (стандартно — hrana)'),
    'kila': ('colloquial', 'розмовне «кілограм» (стандартно — kilogram)'),
    'cura': ('colloquial', 'розмовне «дівчина, кохана» (стандартно — djevojka)'),
    'cimer': ('colloquial', 'розмовне «сусід по квартирі» (стандартно — sustanar)'),
    'cimerica': ('colloquial', 'розмовне «сусідка по квартирі» (стандартно — sustanarka)'),
    'gablec': ('colloquial', 'розмовне загребське «гарячий обід на роботі» (кайкавське)'),
    'fjaka': ('colloquial', 'регіональне розмовне (Далмація); приклад власника'),
    'gušt': ('colloquial', 'розмовне «задоволення, кайф» (з італ. gusto), найчастіше в Далмації'),
    'spiza': ('colloquial', 'регіональне розмовне «продукти» (Далмація; стандартно — namirnice)'),
    'marenda': ('colloquial', 'регіональне розмовне «перекус, пізній сніданок» (Далмація, Істрія; стандартно — užina)'),
    # slang — мова групи (молодь, інтернет, професія)
    'frend': ('slang', 'молодіжне «друг» (з англ. friend; стандартно — prijatelj); приклад власника'),
    'frendica': ('slang', 'молодіжне «подруга» (стандартно — prijateljica)'),
    'fora': ('slang', 'молодіжне «прикол, жарт»; приклад власника'),
    'kul': ('slang', 'молодіжне «круто» (з англ. cool)'),
    'buraz': ('slang', 'молодіжне «брат, друже»'),
    'lova': ('slang', '«гроші» (жаргон; стандартно — novac)'),
    'šljaka': ('slang', '«робота» (жаргон; стандартно — posao)'),
    'šljakati': ('slang', '«працювати» (жаргон; стандартно — raditi)'),
    'mobač': ('slang', '«мобільний» (стандартно — mobitel)'),
    'ae': ('slang', 'далматинське розмовне «так, ага» (уже позначено в базі 2026-11-12)'),
    'onak': ('slang', 'загребське слово-паразит «ну, типу» (уже позначено в базі 2026-10-20)'),
    'fejs': ('slang', 'інтернет-сленг «Facebook»'),
}

# 2. Сумнівні: позначку не ставимо автоматично — питання носію / власнику (лема → чому)
DOUBT: dict[str, str] = {
    'pauk': 'омонім: «евакуатор» — розмовне, «павук» — стандартне; одна лема на обидва значення',
    'kvadrat': 'омонім: «квадратний метр» — розмовне, «квадрат» — стандартне',
    'dečko': '«хлопець (романтично)» — у мовленні нейтральне; чи розмовне — носію',
    'pomalo': 'стандартне «потроху»; далматинське «не поспішай» — розмовне? носію',
    'ne da mi se': 'літературна конструкція, але неофіційна? носію',
    'dućan': 'у перекладі «(розмовно)», але dućan — стандартне слово; прибрати позначку з перекладу? носію',
    'bilježnik': 'у перекладі «(розм.)», але (javni) bilježnik — офіційний термін; прибрати позначку? носію',
    'kesa': 'у перекладі «(регіонально)»; стандартно — vrećica; яке регіон і регістр? носію',
}

# 3. Ознака «звертання на ти» для виразів (part_of_speech = phrase або vocabulary_type formulaic / chunk):
#    за визначенням informal (Kako si? замість Kako ste?). Регулярні вирази — спільні для Python і Postgres (~*).
TI_LEMMA = r"(^|[ ,])(ti|te|tebi|tobom|tvoj|tvoja|tvoje|tvoju|tvog|tvoga|si|nisi|jesi|izvoli|oprosti|molim te)([ ,!?.]|$)"
# 2-га особа однини теперішнього часу в багатослівному виразі: imaš, zoveš, osjećaš, nedostaješ…
TI_VERB = r"(^|[ ,])[a-zčćđšž]{2,}(aš|eš|iš)([ ,!?.]|$)"
NOT_TI_WORDS = ('još', 'naš', 'vaš', 'baš', 'koš', 'loš', 'miš', 'tuš', 'keš', 'krš', 'paprikaš', 'salaš', 'sitniš',
                'okoliš', 'sportaš', 'džeparoš', 'navlaš', 'kokoš', 'broš', 'kaš')
TI_TRANSLATION = r"(на «ти»|до тебе|до друга|(^|[^а-яіїєґ'])(ти|тебе|тобі|тобою)([^а-яіїєґ']|$))"
# Ознака ввічливої форми — тоді не informal (Kako ste?, molim vas, hvala vam, vaš)
VI_LEMMA = r"(^|[ ,])(vi|vas|vam|vama|ste|niste|jeste|vaš|vaša|vaše|vašu|izvolite|oprostite)([ ,!?.]|$)"
# Вирази з «ти» в загальному значенні (прислів'я) — не звертання
NOT_TI: dict[str, str] = {
    'nikad ne reci nikad': 'прислів\'я — «ти» в загальному значенні, не звертання',
}

# 4. Позначки в перекладі / поясненні — кандидат для ручного перегляду (не ставиться автоматично)
MARK_TRANSLATION = r"(\(розм|розмовно|розмовне|сленг|жарг|неофіц|фамільяр|просторіч|вульг)"

PHRASE_TYPES = ('formulaic', 'chunk')


def _is_phrase(row: dict) -> bool:
    return row.get('part_of_speech') == 'phrase' or row.get('vocabulary_type') in PHRASE_TYPES


def _ti_verb(lemma: str) -> bool:
    if ' ' not in lemma.strip():
        return False  # одне слово-форма (znaš) — не вираз; лема має бути інфінітивом, це окреме питання
    return any(re.fullmatch(r'[a-zčćđšž]{2,}(aš|eš|iš)', w) and w not in NOT_TI_WORDS
               for w in re.findall(r'[a-zčćđšž]+', lemma))


def ti_address(row: dict) -> str | None:
    """Причина, якщо вираз — звертання на «ти» (тоді informal), інакше None."""
    lemma = (row.get('lemma') or '').lower()
    tr = row.get('ukrainian_translation') or ''
    if not _is_phrase(row) or lemma in NOT_TI or re.search(VI_LEMMA, lemma):
        return None
    if re.search(TI_LEMMA, lemma) or _ti_verb(lemma):
        return 'звертання на «ти» в самому виразі (офіційно — на «ви»)'
    if re.search(TI_TRANSLATION, tr, re.I):
        return 'звертання на «ти» (видно з перекладу; офіційно — на «ви»)'
    return None


def suggest_register(row: dict) -> tuple[str | None, str, str]:
    """(регістр або None, причина, джерело: rule / ti / doubt / mark / none) для рядка lexemes."""
    lemma = (row.get('lemma') or '').lower()
    if lemma in DOUBT:
        return None, DOUBT[lemma], 'doubt'
    if lemma in RULES:
        reg, why = RULES[lemma]
        return reg, why, 'rule'
    why = ti_address(row)
    if why:
        return 'informal', why, 'ti'
    text = f"{row.get('ukrainian_translation') or ''} {row.get('ukrainian_explanation') or ''}"
    if re.search(MARK_TRANSLATION, text, re.I):
        return None, 'у перекладі / поясненні є позначка стилю — перевірити вручну', 'mark'
    return None, '', 'none'


def check_register(row: dict) -> tuple[list[str], list[str]]:
    """(помилки, попередження) для поля register у новому батчі слів."""
    e, w = [], []
    reg = row.get('register')
    if reg is not None and reg not in ALLOWED:
        (w if reg in LEGACY else e).append(
            f'register «{reg}» — дозволено: порожньо або {", ".join(ALLOWED)} (docs/CONTENT_PIPELINE.md → «Регістр лексем»)')
    sug, why, src = suggest_register(row)
    if src in ('rule', 'ti') and reg != sug and reg not in ('formal', 'vulgar'):
        w.append(f'register: очікується «{sug}» ({why}), а стоїть «{reg or "порожньо"}»')
    if src in ('doubt', 'mark'):
        w.append(f'register: {why}')
    return e, w


def export_query() -> str:
    """Запит (лише читання) для знімка робочої бази: усі слова, яких стосуються правила, ознаки й позначки."""
    lemmas = sorted(set(RULES) | set(DOUBT) | set(NOT_TI))
    lst = ', '.join("'" + l.replace("'", "''") + "'" for l in lemmas)
    return f"""select lemma, cefr, part_of_speech, vocabulary_type, register, regionality,
       ukrainian_translation, ukrainian_explanation
  from public.lexemes
 where status = 'PUBLISHED'
   and (lower(lemma) in ({lst})
        or register is not null or regionality is not null
        or ((part_of_speech = 'phrase' or vocabulary_type in ('formulaic', 'chunk'))
            and (lower(lemma) ~* '{TI_LEMMA}' or lower(lemma) ~* '{TI_VERB}' or ukrainian_translation ~* '{TI_TRANSLATION.replace("'", "''")}'))
        or coalesce(ukrainian_translation, '') || ' ' || coalesce(ukrainian_explanation, '') ~* '{MARK_TRANSLATION}')
 order by lower(lemma);"""


def _selftest() -> None:
    for reg, _ in RULES.values():
        assert reg in REGISTERS, reg
    assert not set(RULES) & set(DOUBT), set(RULES) & set(DOUBT)
    row = lambda lemma, tr='', pos='phrase', vt='formulaic': {  # noqa: E731
        'lemma': lemma, 'ukrainian_translation': tr, 'part_of_speech': pos, 'vocabulary_type': vt}
    assert suggest_register(row('bok', 'привіт', 'interjection', 'core'))[:1] == ('informal',)
    assert suggest_register(row('kužiti', 'розуміти', 'verb', 'core'))[0] == 'colloquial'
    assert suggest_register(row('frend', 'друг', 'noun', 'core'))[0] == 'slang'
    assert suggest_register(row('kako ste', 'як ви?'))[0] is None                       # ввічливе — не informal
    assert suggest_register(row('molim vas', 'будь ласка (до вас)'))[0] is None
    assert suggest_register(row('odakle si', 'звідки ти'))[0] == 'informal'
    assert suggest_register(row('koliko imaš godina', 'скільки тобі років', vt='chunk'))[0] == 'informal'
    assert suggest_register(row('kako se zoveš', 'як тебе звати', vt='chunk'))[0] == 'informal'
    assert suggest_register(row('fiš paprikaš', 'рибна юшка', vt='chunk'))[0] is None    # -š, але не дієслово
    assert suggest_register(row('još jedan', 'ще один', vt='chunk'))[0] is None
    assert suggest_register(row('nikad ne reci nikad', 'ніколи не кажи «ніколи»', vt='chunk'))[0] is None
    assert suggest_register(row('prijatelji iz razreda', 'друзі з класу', vt='chunk'))[0] is None
    assert suggest_register(row('znaš', 'ти знаєш', 'verb', 'core'))[0] is None            # не вираз
    assert suggest_register(row('razgovarati', 'розмовляти', 'verb', 'core'))[2] == 'none'  # «розм» ≠ «розмовляти»
    assert suggest_register(row('dućan', 'магазин (розмовно)', 'noun', 'core'))[2] == 'doubt'
    assert suggest_register(row('kuća', 'дім (розм.)', 'noun', 'core'))[2] == 'mark'
    assert check_register({'lemma': 'kuća', 'register': 'casual'})[0]
    assert not check_register({'lemma': 'pomidor', 'register': 'regional'})[0]           # старе — попередження
    assert check_register({'lemma': 'bok', 'register': None, 'ukrainian_translation': 'привіт'})[1]
    for rx in (TI_LEMMA, TI_VERB, TI_TRANSLATION, VI_LEMMA, MARK_TRANSLATION):
        re.compile(rx)
    assert 'select lemma' in export_query() and "'bok'" in export_query()
    print('selftest OK')


if __name__ == '__main__':
    if '--selftest' in sys.argv:
        _selftest()
    elif '--query' in sys.argv:
        print(export_query())
    else:
        print(__doc__)
