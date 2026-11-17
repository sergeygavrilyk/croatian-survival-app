#!/bin/bash
# Знімок для scripts/gen_a0_dupes.py assessments (PR 2б, 2026-11-17): уроки й тексти A0 після пакетів 20261117_a0_dupes_1/2
# (scripts/assessment_v5_source.sql) і опубліковані завдання тестів A0, які пакет 3 не змінює. Локальна база curdb.sh, лише читання.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
P="psql -h /tmp -p ${PGPORT_CURDB:-5491} -U postgres -At"
$P -f "$HERE/assessment_v5_source.sql" > /tmp/a0dupes_levels.json
$P -c "select jsonb_object_agg(slug, items)::text from (select a.slug, jsonb_agg(jsonb_build_object('audio_hr', i.audio_hr,
  'answer_text', i.answer_text, 'prompt_hr', i.prompt_hr, 'passage_hr', i.passage_hr, 'options', i.options) order by i.order_index) items
  from public.assessments a join public.assessment_items i on i.assessment_id = a.id
  where a.cefr = 'A0' and i.status = 'PUBLISHED' and a.slug not in ('a0-m09', 'a0-m11', 'a0-final') group by a.slug) t" > /tmp/a0dupes_keep.json
python3 - "$HERE/assessment_a0_dupes_snapshot.json" <<'PY'
import json, sys
d = json.load(open('/tmp/a0dupes_levels.json'))
a0 = next(L for L in d['levels'] if L['level'] == 'A0')
keep = json.load(open('/tmp/a0dupes_keep.json'))
out = {'_note': 'Знімок для scripts/gen_a0_dupes.py assessments: уроки й тексти A0 після пакетів 20261117_a0_dupes_1/2 '
                 '(локальна база curdb.sh, запит scripts/assessment_v5_source.sql) і опубліковані завдання тестів A0, які не '
                 'змінюються (a0-m01…m08, m10, a0-mid). Зроблено: bash scripts/a0_dupes_assessment_snapshot.sh',
       'level': a0, 'items': keep}
json.dump(out, open(sys.argv[1], 'w'), ensure_ascii=False, indent=0, sort_keys=True)
print('modules', len(a0['modules']), 'kept tests', len(keep), 'items', sum(len(v) for v in keep.values()))
PY
