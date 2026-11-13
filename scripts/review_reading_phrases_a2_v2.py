#!/usr/bin/env python3
"""
Мовна перевірка 36 нових текстів A2 і 56 фраз A2 (skill croatian-content-review, режим «згенерований контент») · 2026-11-13.

  python3 -B scripts/review_reading_phrases_a2_v2.py   →  автоматичні перевірки: сербізми / екавізми (ті самі шаблони, що
                                                           review_a2_v2_language.py), da li, treba da, «biti ću», кирилиця /
                                                           латиниця не там, російські літери й русизми, знаки питання й числа
                                                           в парах «хорватське ↔ українське», повторені речення.
Знахідки — підказки; остаточно вирішує людина (звіт — content/reviews/2026-11-13_reading_phrases_a2_v2.md).
"""
import re
import sys
from collections import defaultdict
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
from review_a2_v2_language import SERB, SERB_OK, RUS, CYR, LAT  # noqa: E402
import reading_data_a2_v2 as T  # noqa: E402
from phrases_a2_data import PHRASES  # noqa: E402


def pairs():
    for t in T.TEXTS:
        hr_lines, ua_lines = t['hr'].splitlines(), t['ua'].splitlines()
        yield (t['key'], 'title', t['title'][1], t['title'][0])
        yield (t['key'], 'text', t['hr'], t['ua'])
        if len(hr_lines) != len(ua_lines):
            yield (t['key'], 'lines', f'{len(hr_lines)} рядків', f'{len(ua_lines)} рядків')
    for i, (m, sit, hr, ua, reg, tags) in enumerate(PHRASES, 1):
        yield (f'phrase{i:02d} A2.{m}', 'phrase', hr, ua)


def main():
    find = defaultdict(list)
    sentences = defaultdict(list)
    for key, kind, hr, ua in pairs():
        if kind == 'lines':
            find['різна кількість рядків у тексті й перекладі'].append((key, hr, ua))
            continue
        if CYR.search(hr):
            find['кирилиця в хорватському'].append((key, hr[:80]))
        for mt in re.finditer(SERB, hr, re.I):
            t = mt.group(0).lower()
            if t not in SERB_OK:
                find[f'сербізм / екавізм? «{t}»'].append((key, hr[max(0, mt.start() - 30):mt.end() + 30]))
        if re.search(r"\b\w+ti (ću|ćeš|će|ćemo|ćete)\b", hr):
            find['інфінітив на -ti перед ću'].append((key, hr[:80]))
        if re.search(RUS, ua, re.I):
            find['русизм в українському?'].append((key, re.search(RUS, ua, re.I).group(0)))
        if re.search('[ыэъёЫЭЪЁ]', ua):
            find['російські літери'].append((key, ua[:80]))
        if re.search(r'[а-яіїєґ][a-z]|[a-z][а-яіїєґ]', ua):
            find['латиниця всередині українського слова'].append((key, ua[:80]))
        if kind in ('phrase', 'title') and hr.rstrip().endswith('?') != ua.rstrip().endswith('?'):
            find['питання ↔ не питання'].append((key, hr, ua))
        if kind != 'title' and sorted(re.findall(r'\d+', hr)) != sorted(re.findall(r'\d+', ua)):
            find['числа не збігаються'].append((key, sorted(re.findall(r'\d+', hr)), sorted(re.findall(r'\d+', ua))))
        if kind == 'text':
            for s in re.split(r'(?<=[.!?])\s+', hr):
                if len(s.split()) >= 5:
                    sentences[s.strip()].append(key)
            if hr.count('?') != ua.count('?'):
                find['кількість питань у тексті й перекладі'].append((key, hr.count('?'), ua.count('?')))
    for s, keys in sentences.items():
        if len(keys) > 1:
            find['однакове речення в різних текстах'].append((keys, s))
    total = 0
    for k, v in find.items():
        total += len(v)
        print(f'### {k} ({len(v)})')
        for x in v[:40]:
            print('  ', x)
    print(f'Разом знахідок: {total}')


if __name__ == '__main__':
    main()
