#!/bin/bash
# Знімок для scripts/gen_a1_dupes.py assessments (PR 3, 2026-11-17): уроки й тексти A1 після пакета 20261117_a1_dupes_1
# (scripts/assessment_v5_source.sql) і опубліковані завдання тестів A1, які пакет 2 не змінює. Локальна база curdb.sh, лише читання.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
P="psql -h /tmp -p ${PGPORT_CURDB:-5491} -U postgres -At"
$P -f "$HERE/assessment_v5_source.sql" > /tmp/a1dupes_levels.json
$P -c "select jsonb_object_agg(slug, items)::text from (select a.slug, jsonb_agg(jsonb_build_object('audio_hr', i.audio_hr,
  'answer_text', i.answer_text, 'prompt_hr', i.prompt_hr, 'passage_hr', i.passage_hr, 'options', i.options) order by i.order_index) items
  from public.assessments a join public.assessment_items i on i.assessment_id = a.id
  where a.cefr = 'A1' and i.status = 'PUBLISHED' and a.slug not in ('a1-m06', 'a1-m08', 'a1-m11', 'a1-m12', 'a1-final') group by a.slug) t" > /tmp/a1dupes_keep.json
python3 - "$HERE/assessment_a1_dupes_snapshot.json" <<'PY'
import json, sys
d = json.load(open('/tmp/a1dupes_levels.json'))
a1 = next(L for L in d['levels'] if L['level'] == 'A1')
keep = json.load(open('/tmp/a1dupes_keep.json'))
out = {'_note': 'Знімок для scripts/gen_a1_dupes.py assessments: уроки й тексти A1 після пакета 20261117_a1_dupes_1 '
                 '(локальна база curdb.sh, запит scripts/assessment_v5_source.sql) і опубліковані завдання тестів A1, які не '
                 'змінюються (a1-m01…m05, m07, m09, m10, m13, a1-mid). Зроблено: bash scripts/a1_dupes_assessment_snapshot.sh',
       'level': a1, 'items': keep}
json.dump(out, open(sys.argv[1], 'w'), ensure_ascii=False, indent=0, sort_keys=True)
print('modules', len(a1['modules']), 'kept tests', len(keep), 'items', sum(len(v) for v in keep.values()))
PY
