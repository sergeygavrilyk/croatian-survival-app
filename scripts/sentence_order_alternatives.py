"""
«Складіть речення» в перевірках рівня: інші правильні порядки тих самих плиток (колонка answer_alternatives, M27).

Рішення власника 2026-11-15: «Складіть» приймає кілька порядків слів; інші порядки Claude виписує вручну
й позначає для перевірки носієм (content/reviews/2026-11-16_sentence_orders.md).

Правила, за якими записано порядки:
  * лише природні для розмовної хорватської порядки з тим самим значенням (переклад завдання лишається правильним);
  * енклітики (je, sam, smo, se, mi, me, te, joj, mu, li, ću…) — на другому місці речення (Wackernagel);
  * не записуємо порядки, що звучать як наголос чи протиставлення (*Zahtjev želim predati.*, *Na posao idem.*);
  * без нових слів: ті самі плитки, інший порядок (перевіряє check_alternatives і сервер — lib/assessment.ts sameTiles).
Ключ — головна відповідь завдання (answer_text) дослівно. Речення без записаних порядків — лише один порядок.
"""
from __future__ import annotations

import re
from collections.abc import Iterable

ALTERNATIVES: dict[str, list[str]] = {
    # ---------------------------------------------------------------- A0 / A1 (перевірки v5, 2026-11-16)
    'Moj materinski jezik je ukrajinski.': ['Ukrajinski je moj materinski jezik.'],
    'Koliko ima jabuka?': ['Koliko jabuka ima?'],
    'Kakvo je danas vrijeme?': ['Kakvo je vrijeme danas?'],
    'Moja mačka spava cijeli dan.': ['Moja mačka cijeli dan spava.'],
    'Ne jedem meso.': ['Meso ne jedem.'],
    'Pošta je preko puta banke.': ['Preko puta banke je pošta.'],
    'Moje puno ime je Darja.': ['Darja je moje puno ime.'],
    'Vidimo se kasnije!': ['Kasnije se vidimo!'],
    'Koliko košta ulaznica?': ['Koliko ulaznica košta?'],
    'Gdje sada živiš?': ['Gdje živiš sada?'],
    'Dobro, hvala. A ti?': ['Hvala, dobro. A ti?'],
    'Daj joj dudu, molim te.': ['Molim te, daj joj dudu.'],
    'Šetam psa u parku.': ['U parku šetam psa.'],
    'Zagrij pećnicu na dvjesto stupnjeva.': ['Pećnicu zagrij na dvjesto stupnjeva.'],
    'Donesi pladanj iz kuhinje.': ['Iz kuhinje donesi pladanj.'],
    'Sviđa mi se tvoj stil.': ['Tvoj stil mi se sviđa.'],
    'Nemamo gela za tuširanje.': ['Gela za tuširanje nemamo.'],
    'Kada stiže vlak?': ['Kada vlak stiže?'],
    'Drži ljestve, molim te.': ['Molim te, drži ljestve.'],
    'Treba prozračiti kupaonicu.': ['Kupaonicu treba prozračiti.'],
    'Prvo napuni mobitel.': ['Napuni prvo mobitel.'],
    'Uzimajte lijek natašte.': ['Lijek uzimajte natašte.'],
    'Dijete povraća od jutra.': ['Od jutra dijete povraća.'],
    'Kada polazi trajekt?': ['Kada trajekt polazi?'],
    'U zgradi je požar!': ['Požar je u zgradi!'],
    'Odrasla sam u Kijevu.': ['U Kijevu sam odrasla.'],
    'Moramo odgoditi sastanak.': ['Sastanak moramo odgoditi.'],
    'Živimo blizu škole.': ['Blizu škole živimo.'],
    'Gdje se nalazimo sutra?': ['Gdje se sutra nalazimo?'],
    'Sljedeći tjedan radim od kuće.': ['Radim od kuće sljedeći tjedan.'],
    'Nisam primila mail.': ['Mail nisam primila.'],
    # ---------------------------------------------------------------- A2 v2 (перевірки 2026-11-12)
    'Tvoja poruka me jako obradovala.': ['Tvoja me poruka jako obradovala.', 'Jako me obradovala tvoja poruka.'],
    'Zabranjeno je hraniti životinje.': ['Hraniti životinje je zabranjeno.'],
    'Na sljedećem izlazu skrenite desno.': ['Skrenite desno na sljedećem izlazu.'],
    'U posezoni su cijene niže.': ['Cijene su niže u posezoni.'],
    'Za nezaposlene je tečaj besplatan.': ['Tečaj je besplatan za nezaposlene.'],
    'Iz matematike ide na instrukcije.': ['Ide na instrukcije iz matematike.'],
    'Izgubili smo se u starom gradu.': ['U starom gradu smo se izgubili.'],
    'Svakom kupcu treba izdati račun.': ['Račun treba izdati svakom kupcu.'],
    'Slavina kapa cijelu noć.': ['Slavina cijelu noć kapa.'],
    'Na pregled dođite natašte.': ['Dođite na pregled natašte.'],
    'Parking možete platiti SMS-om.': ['Možete platiti parking SMS-om.'],
    'Moramo čuvati okoliš.': ['Okoliš moramo čuvati.'],
    'Starijima se persira.': ['Persira se starijima.'],
    'Mama je primila novac jučer.': ['Mama je jučer primila novac.', 'Jučer je mama primila novac.'],
    'Doći ću, pod uvjetom da ne pada kiša.': ['Pod uvjetom da ne pada kiša, doći ću.'],
    'Natječaj se objavljuje u svibnju.': ['U svibnju se objavljuje natječaj.'],
    'Brzo smo se priviknuli na novi grad.': ['Na novi grad smo se brzo priviknuli.'],
}

CYR = re.compile(r'[Ѐ-ӿ]')


def words(s: str) -> str:
    """Як lib/mistakes.ts normalizeSentence + сортування: ті самі плитки, будь-який порядок."""
    return ' '.join(sorted(re.sub(r'[^\w]+', ' ', s.lower()).split()))


def flat(s: str) -> str:
    return ' '.join(re.sub(r'[^\w]+', ' ', s.lower()).split())


def check_alternatives(answers: Iterable[str] = ()) -> list[str]:
    """Помилки даних: інші плитки, повтор головної відповіді, кирилиця, > 6 порядків, ключ без завдання."""
    problems = []
    for main, alts in ALTERNATIVES.items():
        if not alts or len(alts) > 6:
            problems.append(f'«{main}»: порядків має бути 1–6')
        seen = {flat(main)}
        for alt in alts:
            if CYR.search(alt) or not alt.strip():
                problems.append(f'«{main}» → «{alt}»: порожньо чи кирилиця')
            if words(alt) != words(main):
                problems.append(f'«{main}» → «{alt}»: інші плитки')
            if flat(alt) in seen:
                problems.append(f'«{main}» → «{alt}»: повтор')
            seen.add(flat(alt))
    return problems
