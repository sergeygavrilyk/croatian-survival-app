#!/usr/bin/env python3
"""Додати наявні слова робочої бази до знімка scripts/curriculum_a1_v3_snapshot.json (поле lex) і вивести,
яких із них немає в локальній копії бази (для сиду scripts/dev/seed/seed_a1v3_mNN_supplement.sql).

  python3 scripts/dev/a1v3_snapshot_add.py <файл> <номер модуля>

Файл — рядки «лема|переклад|cefr|normalized|частина мови|vocabulary_type|вид або рід» (з запиту до робочої бази).
Для локальної перевірки (Linux, локальна база з curdb.sh): пише сид з відсутніми в локальній базі словами."""
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
SNAP = ROOT / 'scripts' / 'curriculum_a1_v3_snapshot.json'


def q(s):
    return "'" + s.replace("'", "''") + "'"


def main():
    src, module = sys.argv[1], int(sys.argv[2])
    snap = json.loads(SNAP.read_text(encoding='utf-8'))
    rows = []
    for line in Path(src).read_text(encoding='utf-8').splitlines():
        if not line.strip():
            continue
        lemma, ua, cefr, norm, pos, vt, form = line.split('|')
        snap['lex'][lemma.lower()] = [lemma, ua, cefr, norm, pos, vt]
        rows.append((lemma, ua, cefr, norm, pos, vt, form))
    SNAP.write_text(json.dumps(snap, ensure_ascii=False, indent=1), encoding='utf-8')
    arr = ','.join(q(r[0]) for r in rows)
    missing = subprocess.check_output(['psql', '-h', '/tmp', '-p', '5491', '-U', 'postgres', '-Atc',
        f"select w from unnest(array[{arr}]) w where not exists (select 1 from lexemes x where lower(x.lemma) = lower(w) and status = 'PUBLISHED' and coalesce(source, '') <> 'local_test')"]).decode().split('\n')
    missing = {m for m in missing if m}
    out = [f'-- Слова робочої бази для модуля A1.{module} (curriculum_a1_v3), яких немає в локальній копії. Лише для локальної перевірки.']
    for lemma, ua, cefr, norm, pos, vt, form in rows:
        if lemma not in missing:
            continue
        forms = {}
        if form in ('ipfv', 'pfv', 'biasp'):
            forms['aspect'] = form
        elif form:
            forms['gender'] = form
        out.append('insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, status, source) '
                   f"values ({q(lemma)}, {q(norm)}, 'hr', {q(pos)}, {q(cefr)}, {q(ua)}, {q(vt)}, {q(json.dumps(forms, ensure_ascii=False))}::jsonb, 'PUBLISHED', 'local_test') on conflict do nothing;")
    seed = ROOT / 'scripts' / 'dev' / 'seed' / f'seed_a1v3_m{module:02d}_supplement.sql'
    seed.write_text('\n'.join(out) + '\n', encoding='utf-8')
    print(f'знімок: +{len(rows)} слів; сид {seed.name}: {len(out) - 1} слів')


if __name__ == '__main__':
    main()
