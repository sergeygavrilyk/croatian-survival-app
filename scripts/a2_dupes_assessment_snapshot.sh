#!/bin/bash
# Знімок для scripts/gen_a2_dupes.py assessments (PR 4, 2026-11-19): уроки й тексти A1 і A2 після пакета 20261119_a2_dupes_1
# (запит scripts/assessment_v5_source.sql, рівні A1 і A2). Локальна база curdb.sh, лише читання; файли пакета 2 ще не запущено.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
P="psql -h /tmp -p ${PGPORT_CURDB:-5491} -U postgres -At"
sed "s/unnest(array\['A0', 'A1'\])/unnest(array['A1', 'A2'])/" "$HERE/assessment_v5_source.sql" | $P > /tmp/a2dupes_levels.json
python3 - "$HERE/assessment_a2_dupes_snapshot.json" <<'PY'
import json, sys
d = json.load(open('/tmp/a2dupes_levels.json'))
levels = [L for L in d['levels'] if L['level'] in ('A1', 'A2')]
out = {'_note': 'Знімок для scripts/gen_a2_dupes.py assessments: уроки й тексти A1 і A2 після пакета 20261119_a2_dupes_1_lessons.sql '
                 '(локальна база curdb.sh, запит scripts/assessment_v5_source.sql для A1 і A2). Зроблено: bash scripts/a2_dupes_assessment_snapshot.sh',
       'levels': levels}
json.dump(out, open(sys.argv[1], 'w'), ensure_ascii=False, indent=0, sort_keys=True)
for L in levels:
    print(L['level'], 'modules', len(L['modules']), 'lessons', sum(len(m['lessons']) for m in L['modules']),
          'reading', sum(len(m['reading']) for m in L['modules']))
PY
